// ----------------------------------------------------------------------------
// -                        Open3D: www.open3d.org                            -
// ----------------------------------------------------------------------------
// The MIT License (MIT)
//
// Copyright (c) 2018-2021 www.open3d.org
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
// ----------------------------------------------------------------------------

#pragma once

#include "cub/cub.cuh"
#include "open3d/core/CUDAUtils.h"
#include "open3d/core/nns/NeighborSearchCommon.h"
#include "open3d/utility/Helper.h"
#include "open3d/utility/MiniVec.h"

namespace open3d {
namespace core {
namespace nns {
namespace impl {

namespace {

template <class T>
using Vec3 = utility::MiniVec<T, 3>;

template <int METRIC = L2, class T>
inline __device__ T NeighborsDist(const Vec3<T> &p1, const Vec3<T> &p2) {
    T dist;
    if (METRIC == Linf) {
        Vec3<T> d = (p1 - p2).abs();
        dist = d[0] > d[1] ? d[0] : d[1];
        dist = dist > d[2] ? dist : d[2];
    } else if (METRIC == L1) {
        Vec3<T> d = (p1 - p2).abs();
        dist = (d[0] + d[1] + d[2]);
    } else {
        Vec3<T> d = p1 - p2;
        dist = d.dot(d);
    }
    return dist;
}

template <class T>
inline __device__ void Swap(T *x, T *y) {
    T tmp = *x;
    *x = *y;
    *y = tmp;
}

template <class T, class TIndex>
inline __device__ void Heapify(T *dist, TIndex *idx, int root, int k) {
    int child = root * 2 + 1;

    while (child < k) {
        if (child + 1 < k && dist[child + 1] > dist[child]) {
            child++;
        }
        if (dist[root] > dist[child]) {
            return;
        }
        Swap<T>(&dist[root], &dist[child]);
        Swap<TIndex>(&idx[root], &idx[child]);
        root = child;
        child = root * 2 + 1;
    }
}

template <class T, class TIndex>
__device__ void HeapSort(T *dist, TIndex *idx, int k) {
    int i;
    for (i = k - 1; i > 0; i--) {
        Swap<T>(&dist[0], &dist[i]);
        Swap<TIndex>(&idx[0], &idx[i]);
        Heapify<T, TIndex>(dist, idx, 0, i);
    }
}

template <class T, class TIndex, int METRIC = L2>
__global__ void KnnQueryKernel(TIndex *__restrict__ indices_ptr,
                               T *__restrict__ distances_ptr,
                               size_t num_points,
                               const T *__restrict__ points,
                               size_t num_queries,
                               const T *__restrict__ queries,
                               int knn) {
    int query_idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (query_idx >= num_queries) return;

    Vec3<T> query_pos(queries[query_idx * 3 + 0], queries[query_idx * 3 + 1],
                      queries[query_idx * 3 + 2]);

    T best_dist[100];
    int best_idx[100];

    for (int i = 0; i < knn; i++) {
        best_dist[i] = 1e10;
        best_idx[i] = 0;
    }

    for (int i = 0; i < num_points; i++) {
        Vec3<T> dataset_pos(points[i * 3 + 0], points[i * 3 + 1],
                            points[i * 3 + 2]);
        T dist = NeighborsDist<METRIC, T>(query_pos, dataset_pos);
        if (dist < best_dist[0]) {
            best_dist[0] = dist;
            best_idx[0] = i;
            Heapify(best_dist, best_idx, 0, knn);
        }
    }
    HeapSort(best_dist, best_idx, knn);
    for (int i = 0; i < knn; i++) {
        indices_ptr[i + knn * query_idx] = best_idx[i];
        distances_ptr[i + knn * query_idx] = best_dist[i];
    }
}

template <class T, class TIndex>
void KnnQuery(const cudaStream_t &stream,
              TIndex *indices_ptr,
              T *distances_ptr,
              size_t num_points,
              const T *const points,
              size_t num_queries,
              const T *const queries,
              int knn) {
    // input: queries: (m, 3), points: (n, 3), idx: (m, knn)
    const int BLOCKSIZE = 256;
    dim3 block(BLOCKSIZE, 1, 1);
    dim3 grid(0, 1, 1);
    grid.x = utility::DivUp(num_queries, block.x);

    if (grid.x) {
        KnnQueryKernel<T, TIndex><<<grid, block, 0, stream>>>(
                indices_ptr, distances_ptr, num_points, points, num_queries,
                queries, knn);
    }
}

}  // namespace

template <class T, class OUTPUT_ALLOCATOR>
void KnnSearchCUDA(const cudaStream_t stream,
                   size_t num_points,
                   const T *const points,
                   size_t num_queries,
                   const T *const queries,
                   size_t points_row_splits_size,
                   const int64_t *const points_row_splits,
                   size_t queries_row_splits_size,
                   const int64_t *const queries_row_splits,
                   int knn,
                   OUTPUT_ALLOCATOR &output_allocator) {
    const int batch_size = points_row_splits_size - 1;

    const size_t num_indices = num_queries * knn;

    int32_t *indices_ptr;
    T *distances_ptr;

    output_allocator.AllocIndices(&indices_ptr, num_indices);
    output_allocator.AllocDistances(&distances_ptr, num_indices);

    for (int i = 0; i < batch_size; ++i) {
        const size_t num_queries_i =
                queries_row_splits[i + 1] - queries_row_splits[i];
        const size_t num_points_i =
                points_row_splits[i + 1] - points_row_splits[i];

        const T *const points_i = points + 3 * points_row_splits[i];
        const T *const queries_i = queries + 3 * queries_row_splits[i];
        int32_t *indices_ptr_i = indices_ptr + queries_row_splits[i] * knn;
        T *distances_ptr_i = distances_ptr + queries_row_splits[i] * knn;
        KnnQuery(stream, indices_ptr_i, distances_ptr_i, num_points_i, points_i,
                 num_queries_i, queries_i, knn);
    }
}

}  // namespace impl
}  // namespace nns
}  // namespace core
}  // namespace open3d
