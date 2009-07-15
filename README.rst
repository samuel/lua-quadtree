
===================
QuadTree Lua module
===================

Copyright
=========

Copyright (C) 2008  Samuel Stauffer <samuel@descolada.com>

License
=======

GPLv2 - See LICENSE and COPYING for license details.

API Documentation
=================

QuadTree.new(left, top, width, height)
  Creates and returns a new instance of the QuadTree class with
  the given position and size.

QuadTree:subdivide()
  Subdivides (splits) the QuadTree into four sub QuadTrees

QuadTree:addObject(object)
  Adds an object to the QuadTree

QuadTree:removeObject(object, usePrevious)
  Removes an object from the QuadTree with an option to use the previous
  coordinates of the object.

QuadTree:removeAllObjects()
  Removes all the objects from the QuadTree

QuadTree:updateObject(object)
  Updates an object that's already in the QuadTree, moving
  it from its previous location to its current location.

QuadTree:getCollidableObjects(object, moving)
  Returns a table of all objects near the given object

The objects used by the QuadTree must support the following properties:

* object.x      - current X coordinate
* object.y      - current Y coordinate
* object.prev_x - previous X coordinate
* object.prev_y - previous Y coordinate
* object.width  - width of object
* object.height - height of object
