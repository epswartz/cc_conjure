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
    inventory = {}

    chest = peripheral.find(CHEST_PERIPHERAL)
    if chest == nil then
        error("Cannot find an adjacent chest. Please see setup document.")
    end

    if turtle.getFuelLevel() < INITIAL_FUEL then
        error("Please inset more fuel before beginning: " .. INITIAL_FUEL .. " total fuel is required.")
    end

    height = 0

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

print(dump(all_inventory()))