
---------------------------------------------------------
--------------------- QuadTree Test ---------------------
---------------------------------------------------------

require("quadtree")

local QuadTree = quadtree.QuadTree

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
