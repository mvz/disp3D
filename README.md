disp3D
=======

disp3D is a library for 3D application without call opengl function. Writing OpenGL function is time-cosuming and boring. You can display 3D objects very easily as you want with this library. 

INSTALLING
============

This library depends on these Gems.

- gmath3D
- ruby-opengl
- rmagick
- qtbindings(optional)

To install it, just type...

    $ gem install disp3D

RUNNING
============

Require 'disp3d', then you can use most of the classes in the lib (except for qt-components).

This is the first code you type.

    require 'disp3D'

    # create view with GLUTWindow, then set width, height and window title
    main_view = Disp3D::GLUTWindow.new(400,400, "01_HelloWorld")

    # open world scene graph view has
    main_view.world_scene_graph.open do
      # put TeaPod which color is Red and size is 10 
      add_new :type => :TeaPod,
              :material_color => [1,0,0,1],
              :size => 10.0
    end

    # set parameter for camera
    main_view.camera.projection = Disp3D::Camera::ORTHOGONAL

    # finally show window!
    main_view.start

You can see a teapod is shown in the window. you can rotate it with mouse L button and drag.
![image](https://github.com/toshi0328/wiki/blob/master/images/disp3D/HelloWorld01.png?raw=true)

see example/tutorial/*.rb for more details.

Copyright
============

Copyright (c) 2011 Toshiyasu Shimizu. See LICENSE.txt for
further details.

