--[[

QuadTree module

Copyright (C) 2008  Samuel Stauffer <samuel@descolada.com>
See LICENSE and COPYING for license details.



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

  object.x      - current X coordinate
  object.y      - current Y coordinate
  object.width  - width of object
  object.height - height of object
  object.prev_x - previous X coordinate
  object.prev_y - previous Y coordinate

]]



local print, pairs, assert, setmetatable = print, pairs, assert, setmetatable
local math, table = math, table

module("quadtree")

------------------------------------------------------------
---------------------- QuadTree class ----------------------
------------------------------------------------------------

QuadTree = {}
QuadTree_mt = {}

function QuadTree.new(_left, _top, _width, _height)
    return setmetatable(
    {
        left   = _left,
        top    = _top,
        width  = _width,
        height = _height,
        children = nil,
        objects = {}
    }, QuadTree_mt)
end

function QuadTree:subdivide()
    if self.children then
        for i,child in pairs(self.children) do
            child:subdivide()
        end
    else
        local x = self.left
        local y = self.top
        local w = math.floor(self.width / 2)
        local h = math.floor(self.height / 2)
        -- Note: This only works for even width/height
        --   for odd the size of the far quadrant needs to be
        --    (self.width - w, wself.height - h)
        self.children = {
            QuadTree.new(x    , y    , w, h),
            QuadTree.new(x + w, y    , w, h),
            QuadTree.new(x    , y + h, w, h),
            QuadTree.new(x + w, y + h, w, h)
        }
    end
end

function QuadTree:check(object, func, x, y)
    local oleft   = x or object:getX()
    local otop    = y or object:getY()
    local oright  = oleft + object:getWidth() - 1
    local obottom = otop + object:getHeight() - 1

    for i,child in pairs(self.children) do
        local left   = child.left
        local top    = child.top
        local right  = left + child.width - 1
        local bottom = top  + child.height - 1

        if oright < left or obottom < top or oleft > right or otop > bottom then
            -- Object doesn't intersect quadrant
        else
            func(child)
        end
    end
end

function QuadTree:addObject(object)
    assert(not self.objects[object], "You cannot add the same object twice to a QuadTree")

    if not self.children then
        self.objects[object] = object
    else
        self:check(object, function(child) child:addObject(object) end)
    end
end

function QuadTree:removeObject(object, usePrevious)
    if not self.children then
        self.objects[object] = nil
    else
        -- if 'usePrevious' is true then use prev_x/y else use x/y
        local x = (usePrevious and object.prev_x) or object:getX()
        local y = (usePrevious and object.prev_y) or object:getY()
        self:check(object,
            function(child)
                child:removeObject(object, usePrevious)
            end, x, y)
    end
end

function QuadTree:updateObject(object)
    self:removeObject(object, true)
    self:addObject(object)
end

function QuadTree:removeAllObjects()
    if not self.children then
        self.objects = {}
    else
        for i,child in pairs(self.children) do
            child:removeAllObjects()
        end
    end
end

function QuadTree:getCollidableObjects(object, moving)
    if not self.children then
        return self.objects
    else
        local quads = {}

        self:check(object, function (child) quads[child] = child end)
        if moving then
            self:check(object, function (child) quads[child] = child end,
                object.prev_x, object.prev_y)
        end

        local near = {}
        for q in pairs(quads) do
            for i,o in pairs(q:getCollidableObjects(object, moving)) do
                -- Make sure we don't return the object itself
                if i ~= object then
                    table.insert(near, o)
                end
            end
        end

        return near
    end
end

QuadTree_mt.__index = QuadTree

---------------------------------------------------------
--------------------- QuadTree Test ---------------------
---------------------------------------------------------

--[[
    quadtree = QuadTree.new(0, 0, 1000, 1000)
    quadtree:subdivide()

    -- Add object to (0,0)
    obj1 = {
                name   = "obj1",
                x      = 10,
                y      = 10,
                prev_x = 10,
                prev_y = 10,
                width  = 50,
                height = 50
            }
    quadtree:addObject(obj1)

    -- Add object to (0,0)
    obj2 = {
                name   = "obj2",
                x      = 100,
                y      = 10,
                prev_x = 100,
                prev_y = 10,
                width  = 50,
                height = 50
            }
    quadtree:addObject(obj2)

    -- Add object to (0,0) + (1,0)
    obj3 = {
                name   = "obj3",
                x      = 100,
                y      = 10,
                prev_x = 100,
                prev_y = 10,
                width  = 700,
                height = 50
            }
    quadtree:addObject(obj3)

    -- Add object to (1,0)
    obj4 = {
                name   = "obj4",
                x      = 700,
                y      = 10,
                prev_x = 700,
                prev_y = 10,
                width  = 50,
                height = 50
            }
    quadtree:addObject(obj4)

    print("Should be objects 2,3")
    near = quadtree:getCollidableObjects(obj1, false)
    for i,j in pairs(near) do print(j.name) end

    print("Should be objects 1,3")
    near = quadtree:getCollidableObjects(obj2, false)
    for i,j in pairs(near) do print(j.name) end

    print("Should be objects 1,2,4")
    near = quadtree:getCollidableObjects(obj3, false)
    for i,j in pairs(near) do print(j.name) end

    print("Should be object 3")
    near = quadtree:getCollidableObjects(obj4, false)
    for i,j in pairs(near) do print(j.name) end

    -- Move obj1 to (1,0)
    obj1.prev_x, obj1.prev_y = obj1.x, obj1.y
    obj1.x     , obj1.y      = 900   , 200
    quadtree:updateObject(obj1)

    print("Should be objects 3,4")
    near = quadtree:getCollidableObjects(obj1, false)
    for i,j in pairs(near) do print(j.name) end

    print("Should be object 3")
    near = quadtree:getCollidableObjects(obj2, false)
    for i,j in pairs(near) do print(j.name) end

    print("Should be objects 1,2,4")
    near = quadtree:getCollidableObjects(obj3, false)
    for i,j in pairs(near) do print(j.name) end

    print("Should be object 1,3")
    near = quadtree:getCollidableObjects(obj4, false)
    for i,j in pairs(near) do print(j.name) end
]]
