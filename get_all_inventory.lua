--
--        _.---._    /\\
--      ./'       "--`\//
--    ./     Ethan    o \
--   /./\  )______   \__ \
--  ./  / /\ \   | \ \  \ \
--     / /  \ \  | |\ \  \7
--      "     "    "  "

-- Constants
CHEST_PERIPHERAL = "minecraft:chest"

-- Utilities

-- Dump a table to string.
function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
 end


-- Movement Functions
function upOrErr(dist)
    for i=1,dist,1 do
        if not turtle.up() then
            error("Cannot move inside move or die function: upOrErr()")
        end
    end
end

function downOrErr(dist)
    for i=1,dist,1 do
        if not turtle.down() then
            error("Cannot move inside move or die function: downOrErr()")
        end
    end
end

function fwdOrErr(dist)
    for i=1,dist,1 do
        if not turtle.forward() then
            error("Cannot move inside move or die function: fwdOrErr()")
        end
    end
end

function bkOrErr(dist)
    for i=1,dist,1 do
        if not turtle.back() then
            error("Cannot move inside move or die function: upOrErr()")
        end
    end
end


-- Returns a table of inventory entries. Each entry is itself a table,
-- with the item/damage value as key, and counts as the values.
-- At time of call:
    -- Turtle is at bottom of the inventory column
    -- There are no other inventories (this means none of the chests are doubles)
    -- Turtle has at least 200 fuel (to reach top of inventory column).
function all_inventory()
    inventory = {}

    chest = peripheral.find(CHEST_PERIPHERAL)

    height = 0

    while chest ~= nil do
        for idx,item in chest.list() do
            item_id = item.name .. "/" .. tostring(item.damage)
            if inventory[item_id] == nil then
                inventory[item_id] = 0
            end
            inventory[item_id] = inventory[item_id] + item.count
        end
        turtle.upOrErr(1)
        chest = peripheral.find(CHEST_PERIPHERAL)
    end

    turtle.downOrErr(height)

    return inventory
end

print(dump(all_inventory()))