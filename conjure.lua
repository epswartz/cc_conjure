--
--        _.---._    /\\
--      ./'       "--`\//
--    ./     Ethan    o \
--   /./\  )______   \__ \
--  ./  / /\ \   | \ \  \ \
--     / /  \ \  | |\ \  \7
--      "     "    "  "


require "conjure_lib/move"
require "conjure_lib/log"
json = require "conjure_lib/json"
require "conjure_lib/convert"

-- Constants
CHEST_PERIPHERAL = "minecraft:chest"
INITIAL_FUEL = 200 -- Fuel requirement to check inventory column.

-- Returns a table of inventory entries. Each entry is itself a table,
-- with the item/damage value as key, and counts as the values.
-- At time of call:
    -- Turtle is at bottom of the inventory column
    -- There are no other inventories (this means none of the chests are doubles)
    -- Turtle has at least 200 fuel (to reach top of inventory column).
function all_inventory()
    local inventory = {}

    local chest = peripheral.find(CHEST_PERIPHERAL)
    if chest == nil then
        error("Cannot find an adjacent chest. Please see setup document.")
    end

    if turtle.getFuelLevel() < INITIAL_FUEL then
        error("Please inset more fuel before beginning: " .. INITIAL_FUEL .. " total fuel is required.")
    end

    local height = 0

    while chest ~= nil do
        for idx,item in pairs(chest.list()) do
            item_id = item.name .. "/" .. tostring(item.damage)
            if inventory[item_id] == nil then
                inventory[item_id] = 0
            end
            inventory[item_id] = inventory[item_id] + item.count
        end
        upOrErr(1)
        height = height + 1
        chest = peripheral.find(CHEST_PERIPHERAL)
    end

    downOrErr(height)

    return inventory
end


-- Load a table from given file.
function load_table(filepath)
  return json.decode(slurp(filepath))
end

-- Read the schematic file passed in by cli.
function read_schematic()
    return load_table(arg[1])
end

-- Given a schematic table, read through the layers and determine the items needed.
-- Outputs in the same format as the all_inventory - single string ids as key, counts as value.
function needed_inventory(schematic)
    needed = {}
    for _,layer in ipairs(schematic.layers) do
        for _,row in ipairs(layer) do
            for _, id in ipairs(row) do
                if id ~= "" then
                    if needed[id] == nil then
                        needed[id] = 1
                    else
                        needed[id] = needed[id] + 1
                    end
                end
            end
        end
    end
    return needed
end

function inventory_is_subset(inventory, needed)
    for _,id in ipairs(needed) do
        if inventory[id] == nil or inventory[id] < needed[id] then
            return false
        end
    end
    return true
end

function inventory_has_needed()
    inventory = all_inventory()
    schematic = read_schematic()
    needed = needed_inventory(schematic)

    return inventory_is_subset(inventory, needed)
end

print(inventory_has_needed())