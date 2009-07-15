
--[[
    Copyright (C) 2008  Samuel Stauffer <samuel@descolada.com>
    See LICENSE and COPYING for license details.
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
    local oleft   = x or object.x
    local otop    = y or object.y
    local oright  = oleft + object.width - 1
    local obottom = otop + object.height - 1

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
