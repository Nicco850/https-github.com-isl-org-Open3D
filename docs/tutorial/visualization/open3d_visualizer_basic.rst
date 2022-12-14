.. _open3d_visualizer_basic:

Open3D Visualizer
=================

Introduction
---------------

Open3D provides a convenient function for visualizing geometric objects: ``draw``. The ``draw`` function allows you to visualize multiple geometry objects *(PointClouds, LineSets, TriangleMesh)* and images together along with optional, high-quality, physically based (PBR) materials. As will be demonstrated in the subsequent sections, ``draw`` can be used for both - simple, quick visualization or complex use-cases.

Getting Started
---------------

.. note::
	 This **Getting Started** section applies to all subsequent examples below
	 
For all examples in this tutorial, we will be running a Python session. Please follow these preliminary steps :

1. First, open a command-line terminal. From there, Change Directory (``cd``) to ``Open3D``:
 
.. code-block:: sh

	$ cd <... Path to Open3D on your computer...>
	
.. image:: https://user-images.githubusercontent.com/93158890/148607427-9391c499-9fc5-4a38-89a4-fb088019ca0b.jpg
    :width: 700px	
    
2. **Optionally**, if you have a ``conda`` virtual environment, activate it from the command line like so:

.. code-block:: sh

    $ conda activate <...your virtual environment name...>
    
3. Run the ``python`` command:

.. code-block:: sh

    $ python

4. At the Python prompt, enter the following lines to create Open3D objects:

.. code-block:: python

		>>> import open3d as o3d
		>>> import open3d.visualization as vis
		>>> import numpy as np
		
These objects will be used throughout the following examples.


Basic Examples
--------------

In the Overview section, we activated a ``conda`` environment, started a Python session, and declared an Open3D object to be used throughout this tutorial. Let’s now test various Open3D ``draw()`` function capabilities with various geometries.

Drawing a TriangleMesh Box 
::::::::::::::::::::::::::

This example shows how to create and visualize a simple 3D box.


At the python prompt, enter the following four lines to open the 3D Visualizer:

.. code-block:: python

		>>> cube = o3d.geometry.TriangleMesh.create_box(1, 2, 4)
		>>> vis.draw(cube)

At the end of the process, the Open3D Visualizer window should appear:

.. image:: https://user-images.githubusercontent.com/93158890/148607529-ee0ae0de-05af-423d-932c-2a5a6c8d7bda.jpg
    :width: 600px
    

Drawing a TriangleMesh-based Sphere
:::::::::::::::::::::::::::::::::::

At the Python prompt in your terminal, enter the following lines of code:

.. code-block:: python

		>>> sphere = o3d.geometry.TriangleMesh.create_sphere(2.0)
		>>> vis.draw(sphere)
		
A rendered sphere appears:

.. image:: https://user-images.githubusercontent.com/93158890/148607694-18e130f5-259d-483f-8d37-04e7d895dedb.jpg
    :width: 600px

To see what type of rendering was used to draw our sphere above, at the Python prompt, enter: 

.. code-block:: python
	
		>>> sphere

Open3D returns:

.. code-block:: sh
	
		TriangleMesh with 762 points and 1520 triangles.



Drawing a Tensor-based Sphere
:::::::::::::::::::::::::::::

In examples above we rendered ``TriangleMesh`` versions of objects. Now, we will do the same using a Tensor-based object. Continuing from the previous example, at the Python prompt in your terminal, enter:

.. code-block:: python

		>>> sphere_t = o3d.t.geometry.TriangleMesh.from_legacy(sphere)
		>>> vis.draw(sphere_t)
		
		
A sphere similar to that shown in the previous example is rendered, but this time using a Tensor data type. Now, enter ``sphere_t`` at the Python prompt:

.. code-block:: python

		>>> sphere_t

Open3D returns:

.. code-block:: sh

	TriangleMesh on CPU:0 [762 vertices (Float32) and 1520 triangles (Int64)]. 
	Vertices Attributes: None. 
	Triangles Attributes: None.

**This is how Tensor objects are denoted - by vertices and triangles.**



Rendering Point Cloud Data (pcd) files
:::::::::::::::::::::::::::::::::::::::::

Enter the following code at the Python prompt:

.. code-block:: python

	>>> pcd = o3d.io.read_point_cloud("examples/test_data/fragment.pcd")
	>>> vis.draw(pcd)
	
Open3D returns:
	
.. image:: https://user-images.githubusercontent.com/93158890/148607866-3de802e2-34ea-499e-a6ad-ee2b44ab9994.jpg
    :width: 600px
    

Working with Line Sets
::::::::::::::::::::::::

Line Sets are used to display a wireframe of a 3D model.

Let's start by creating a custom ``LineSet`` object:

.. code-block:: python

	>>> ls = o3d.geometry.LineSet.create_from_triangle_mesh(sphere)

Now, let's make sure our object is of the ``LineSet`` type:

.. code-block:: python

	>>> ls
  LineSet with 2280 lines.
  
OK, now render it:

.. code-block:: python

	>>> vis.draw(ls)

Object wireframe is displayed:

.. image:: https://user-images.githubusercontent.com/93158890/148608068-bd244820-a6c9-47e2-8ae8-1cabaeec907d.jpg
    :width: 600px
    

Specifying Wireframe ``line_width``
"""""""""""""""""""""""""""""""""""

Aside from rendering ``LineSet`` wireframes, we can change the wireframe thickness by passing in a ``line_width`` parameter with a values typically ranging **from 1** (thinnest) **to 5** (thickest):

.. code-block:: python

	>>> vis.draw(ls, line_width=5)

As you can see from the rendered sphere, its wireframe lines appear much thicker:

.. image:: https://user-images.githubusercontent.com/93158890/148608552-9c77846a-1cca-4a2e-8f05-5b062eea89be.jpg
    :width: 600px
    
Below is a more complex example of ``line_width``. This is where we superimpose a *LineSet* wireframe object upon a *sphere*:

.. code-block:: python

	>>> vis.draw([sphere, ls], line_width=1)

.. image:: https://user-images.githubusercontent.com/93158890/148608657-0780bc13-1b32-4875-89ba-d8f8320a7469.jpg
    :width: 600px
	
	
   
Rendering Multiple Objects
::::::::::::::::::::::::::

The ``draw()`` function can be used to render multiple 3D objects simultaneously. You can pass as may objects to the ``draw()`` as you need. In this example, we will render two objects: the **Sphere** and the **PCD**. 


At the Python prompt, enter this line of code:

.. code-block:: python

	>>> vis.draw([sphere, pcd])
	
Both objects appear and can be moved and rotated:

.. image:: https://user-images.githubusercontent.com/93158890/148608769-647de97c-c530-4bf4-8db3-fc75ef646dc3.jpg
    :width: 600px
	
Objects can also be separated from each other by specifying distance. In the code below, we are separating the **sphere** from the **PCD**:

.. code-block:: python

  >>> sphere.translate([0, 6, 0])
  TriangleMesh with 762 points and 1520 triangles.
  >>> vis.draw([sphere, pcd])


As you can see, this time, our objects are separated by a greater distance, and just like in the previous example, they can be moved, panned, and rotated:

.. image:: https://user-images.githubusercontent.com/93158890/148608860-361aa4e8-bf20-4435-bda0-fb27899f0f07.jpg
    :width: 600px
	
Displaying UI / Control Panel
"""""""""""""""""""""""""""""

By default, the ``draw()`` function renders 3D models without showing the user interface (UI) / control panel where users can interactively modify 3D model rendering parameters of the Visualizer. Let's now render our models with the UI shown:

.. code-block:: python

	>>> vis.draw([sphere, pcd], show_ui=True)

.. image:: https://user-images.githubusercontent.com/93158890/148608987-bd0a741d-f516-4a06-8f1b-0463d656c036.jpg
    :width: 600px

At the bottom of the UI / control panel, you can see the section titled "*Geometries*" (outlined in a yellow box). This section contains a list of rendered objects that can be individually turned on or off by clicking a checkbox to the left of their names.


Displaying Window Titles and Specifying Window Dimensions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""

Aside from displaying UI / control panel, it is also possible to add a Visualizer window title along with window dimensions (i.e. *Width* and *Height*). This code example illustrates how to rename a Visualizer title bar and set window ``width`` and ``height``:

.. code-block:: python

	>>> vis.draw([sphere, pcd], show_ui=True, title="Sphere and PCD", width=700, height=700)
	
.. image:: https://user-images.githubusercontent.com/93158890/148609189-e52bb398-e84e-4f83-9a54-53102ea0e80b.jpg
    :width: 600px


 

Working with Geometries and Materials
:::::::::::::::::::::::::::::::::::::

With the ``draw()`` function you can create customized materials and geometries. First, we will create a custom material:


.. code-block:: python

	>>> mat = o3d.visualization.rendering.MaterialRecord()
	>>> mat.shader = "defaultLit"
	>>> mat.base_color = np.asarray([1.0, 0.0, 1.0, 1.0])

We declare ``mat`` as a material rendering object and initialize it with a default lighting scheme. The ``numpy`` object we declared in the very beginning of this tutorial will help us pass the RGB-Alpha values as an array to the ``mat.base_color`` property.

To find out what the mat object is, we type in ``mat`` at the Python prompt:
	
.. code-block:: python

	>>> mat
	<open3d.cpu.pybind.visualization.rendering.MaterialRecord object at 0x7f2be5e34430>

Now, let's create some geometries and use the above custom material we just created:

.. code-block:: python

  >>> geoms = {'name': 'sphere', 'geometry': sphere, 'material': mat}
  >>> vis.draw(geoms)
  
.. image:: https://user-images.githubusercontent.com/93158890/148609355-929ebd00-0adb-4634-9da7-0a82c4965cc9.jpg
    :width: 600px
    
``compute_vertex_normals()``  Method
""""""""""""""""""""""""""""""""""""
    
Note that after the ``draw()`` call of ``o3d.visualization.draw(geoms)`` Open3D displays a warning related to the absence of ``normals``:

.. code-block:: python

  [Open3D WARNING] Using a shader with lighting but geometry has no normals.
  
In the image above, the sphere shading looks somewhat jagged. To improve that, we need to call the ``compute_vertex_normals()`` method on our sphere object:

.. code-block:: python

  >>> sphere.compute_vertex_normals()
  TriangleMesh with 762 points and 1520 triangles.
  >>> vis.draw(geoms)
  
The result of calling ``compute_vertex_normals()`` speaks for itself, - the rendered sphere looks way better:

.. image:: https://user-images.githubusercontent.com/93158890/148609453-fecf75bc-4cb9-4961-9197-26a250c9cacc.jpg
    :width: 600px
    

Assigning Names to Objects in the UI
""""""""""""""""""""""""""""""""""""

Earlier, we explicitly declared the name for our object in the ``geoms`` collection (``'name': 'sphere'``). We can now display the UI and confirm that our custom object is named appropriately:

.. code-block:: python

	>>> geoms = {'name': 'sphere', 'geometry': sphere, 'material': mat}
	>>> vis.draw(geoms, show_ui=True)

And here is the named object:

.. image:: https://user-images.githubusercontent.com/93158890/148609614-dcea315f-b937-445f-ac1e-f461f94eb55d.jpg
    :width: 600px
    
So far, our ``geoms`` collection defined only a single object: *sphere*. But we can turn it into a list and define multiple objects there. Let's see how it's done:

.. code-block:: python

	>>> geoms = [{'name': 'sphere', 'geometry': sphere, 'material': mat}, {'name': 'pointcloud', 'geometry': pcd}]
	>>> vis.draw(geoms, show_ui=True)

.. image:: https://user-images.githubusercontent.com/93158890/148609730-69d90faa-7083-42c5-9c5f-6f12d2e3efc4.jpg
    :width: 600px





More ``draw()`` Options
:::::::::::::::::::::::

``show_skybox`` and ``bg_color``
""""""""""""""""""""""""""""""""

Aside from naming Open3D Visualizer status bar, geometries, and displaying the UI, you also have options to programmatically turn the light blue *skybox* on or off (``show_skybox=False/True``) as well as change the background color (``bg_color=(x.x, x.x, x.x, x.x)``).

First, we'll demonstrate how to turn off the *skybox*. At your Python prompt, enter:

.. code-block:: python

	>>> vis.draw(geoms, show_ui=True, show_skybox=False)
	
And the Visualizer window opens without the default *skybox* blue background:

.. image:: https://user-images.githubusercontent.com/93158890/148610012-98d2fbef-1a81-43b5-a076-0335f5f4ee1e.jpg
    :width: 600px

Next, we will explore the *background color* (``bg_color``) parameter. At the Python prompt, enter:

.. code-block:: python

	>>> vis.draw(geoms, show_ui=True, title="Green Background", show_skybox=False, bg_color=(0.0, 1.0, 0.0, 1.0))

Here, we have displayed the UI, renamed the title bar to *"Green Background"*, turned off the default *skybox* background, and explicitly specified RGB-Alfa values for the ``bg_color``:

.. image:: https://user-images.githubusercontent.com/93158890/148610167-6a61f94b-8b1f-4f5a-ae36-038fdab25acd.jpg
    :width: 600px

Specifying ``point_size``
"""""""""""""""""""""""""

In this section, we will learn how to control 3D model rendering by passing in ``point_size`` as a parameter to the ``draw()`` function. To do this, let's enter the following code at the Python prompt:

.. code-block:: python

	>>> vis.draw(pcd, point_size=9, show_ui=True)

Here we have programmatically specified a custom ``point_size`` for rendering. It is recommended to set ``show_ui=True`` to make sure Open3D Visualizer interprets ``draw()`` function input parameters correctly. You can experiment with different point sizes by moving a slider in the UI:

.. image:: https://user-images.githubusercontent.com/93158890/148610297-0243c452-074f-4d44-a169-cd01a4f9e62a.jpg
    :width: 600px