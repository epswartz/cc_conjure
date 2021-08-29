-- Movement and Routing Functions

-- Relative movement system initialization
turtle.x = 1
turtle.z = 0
turtle.y = 1
turtle.build_height = 0 -- The highest level on which any block has already been placed.

-- Turtle facings:
-- 0: +Z
-- 1: +X
-- 2: -Z
-- 3: -X
turtle.facing = 0


-- Go to a particular relative location.
-- Routes in the following way:
-- Ascend to 1 greater than the current turtle.build_height
-- Move to the proper location in x/z
-- Descend to proper y
function go(x,y,z)
    if turtle.y < (turtle.build_height + 1) then
        upOrErr((turtle.build_height + 1) - turtle.y)
    end
    if x > turtle.x then
        face(1)
        fwdOrErr(x - turtle.x)
    elseif x < turtle.x then
        face(3)
        fwdOrErr(turtle.x - x)
    end

    if z > turtle.z then
        face(0)
        fwdOrErr(z - turtle.z)
    elseif z < turtle.z then
        face(2)
        fwdOrErr(turtle.z - z)
    end

    if turtle.y > y then
        downOrErr(turtle.y - y)
    elseif turtle.y < y then
        upOrErr(y - turtle.y)
    end

end

-- Turn function which tracks facing.
function face(direction)
    if direction > 3 or direction < 0 then
        error("Invalid direction in face(). Must be 0-3 inclusive.")
    end
    rotation = (turtle.facing - direction) % 4
    if rotation == 1 then
        turtle.turnLeft()
    elseif rotation == 2 then
        turtle.turnLeft()
        turtle.turnLeft()
    elseif rotation == 3 then
        turtle.turnRight()
    end
    turtle.facing = direction
end



-- Basic Movement
-- TODO: Build in automatic retries
function upOrErr(dist)
    for i=1,dist,1 do
        if not turtle.up() then
            error("Cannot move inside move or die function: upOrErr()")
        end
        turtle.y = turtle.y + 1
    end
end

function downOrErr(dist)
    for i=1,dist,1 do
        if not turtle.down() then
            error("Cannot move inside move or die function: downOrErr()")
        end
        turtle.y = turtle.y - 1
    end
end

function fwdOrErr(dist)
    for i=1,dist,1 do
        if not turtle.forward() then
            error("Cannot move inside move or die function: fwdOrErr()")
        end
        if turtle.facing == 0 then
            turtle.z = turtle.z + 1
        elseif turtle.facing == 1 then
            turtle.x = turtle.x + 1
        elseif turtle.facing == 2 then
            turtle.z = turtle.z - 1
        else
            turtle.x = turtle.x - 1
        end
    end
end

-- function bkOrErr(dist)
--     for i=1,dist,1 do
--         if not turtle.back() then
--             error("Cannot move inside move or die function: upOrErr()")
--         end
--     end
-- end