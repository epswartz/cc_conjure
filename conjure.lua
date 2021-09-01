--
--        _.---._    /\\
--      ./'       "--`\//
--    ./     Ethan    o \
--   /./\  )______   \__ \
--  ./  / /\ \   | \ \  \ \
--     / /  \ \  | |\ \  \7
--      "     "    "  "


json = require "conjure_lib/json"

require "conjure_lib/move"
require "conjure_lib/log"
require "conjure_lib/convert"
require "conjure_lib/tables"
require "conjure_lib/inventory"


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


-- Read entire file into string.
function slurp(path)
  local f = io.open(path)
  local s = f:read("*a")
  f:close()
  return s
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
    local needed = {}
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


-- Returns a bool representing whether everything in needed can be found in inventory.
-- Also returns a list of items needed.
function missing_inventory(inventory, needed)
    local ret = true
    local missing = {}
    for id,quantity in pairs(needed) do
        amount_in_inv = inventory[id] or 0
        missing_amount = quantity - amount_in_inv
        if missing_amount > 0 then
            missing[id] = missing_amount
            ret = false
        end
    end
    return ret, missing
end


-- Find the block with given id in inventory, and place it below the turtle.
-- Returns bool successful
function place_block_down(id)
    for slot=1,16,1 do
        turtle.select(slot)
        item = itemDetailToItemKey(turtle.getItemDetail())
        if item == id then
            if not turtle.placeDown() then
                error("Cannot place down: place_block_down()")
            end
            return true
        end
    end
    return false
end


-- Place a block with given id at the given location.
-- Returns bool successful
function place_at(id, x, y, z)
    go(x,y+1,z)
    success = place_block_down(id)
    if success and (y > turtle.build_height) then
        build_height = y
    end
    return success
end


-- Reads turtle.inventory, and grabs everything out of the inventory column that is listed there.
function fetch_from_inventory_column()
    if turtle.x ~= 0 or turtle.y ~= 0 or turtle.z ~= -1 then
        error("Turtle is not in starting spot when fetch_from_inventory_column() was called.")
    end
    while has_items(turtle.inventory) do
        local chest = peripheral.find(CHEST_PERIPHERAL)
        if chest == nil then
            error("Cannot find chest: fetch_from_inventory_column()")
        end
        for c_slot,c_item in pairs(chest.list()) do
            for t_slot,t_item in pairs(turtle.inventory) do
                if (c_item.name .. "/" .. c_item.damage) == t_item.id then
                    chest.pullItems(peripheral.getName(chest), c_slot, math.min(c_item.quantity, t_item.quantity), t_slot)
                end
            end
        end
        upOrErr(1)
    end
    go(1,1,0)
    face(0)
end


function main()

    -- Check inventory readiness,
    -- whether we have all the required mats.
    local inventory = all_inventory() -- All in inventory column.
    local schematic = read_schematic()
    local needed = needed_inventory(schematic)
    local inventory_ready, missing_mats = missing_inventory(inventory, needed)
    if not inventory_ready then
        print("Inventory column is missing building materials.")
        print("Please insert: ")
        for id, quantity in pairs(missing_mats) do
            print(quantity .. "x " .. id)
        end
        print()
        error()
    end

    local layers = schematic.layers

    -- Schematic size / layer symmetry check.
    local correct = true
    if len(layers) ~= schematic.size.y then
        print("Unexpected number of layers. Actual: ".. len(layers) .. ", Expected: " .. schematic.size.y)
        correct = false
    end
    for idx, layer in ipairs(layers) do
        if len(layer) ~= schematic.size.z then
            print("Layer " .. idx .. " has incorrect number of rows, based on schematic z-axis size.")
            correct = false
        end
        for row_idx, row in ipairs(layer) do
            if len(row) ~= schematic.size.x then
                print("Row " .. row_idx .. " of layer " .. idx .. " has incorrect number of items, based on schematic x-axis size.")
            end
        end
    end

    if not correct then
        error("Cannot continue, schematic is malformed. Change layers or size declaration.")
    end

    next_place_pos = {0,0,0} -- Track blocks placed
    while next_place_pos[1] < schematic.size.y + 1 do
        local next_pickup_pos = clone(next_place_pos) -- Track blocks picked up into inventory
        print("next_pickup_pos: " .. dump(next_pickup_pos))

        -- Figure out what to pick up from inventory.
        while inventory_add(schematic.layers[next_pickup_pos[1]][next_pickup_pos[2]][next_pickup_pos[3]]) do
            print(next_pickup_pose[1] .. ", " .. next_pickup_pose[2] .. ", " .. next_pickup_pose[3] .. ": ",
                schematic.layers[next_pickup_pos[1]][next_pickup_pos[2]][next_pickup_pos[3]])
            if next_pickup_pos[3] == schematic.size.x then
                next_pickup_pos[3] = 1
                next_pickup_pos[2] = next_pickup_pos[2] + 1
            elseif next_pickup_pos[2] == schematic.size.z then
                next_pickup_pos[2] = 1
                next_pickup_pos[1] = next_pickup_pos[1] + 1
            elseif next_pickup_pos[1] > schematic.size.y then
                break
            else
                next_pickup_pos[3] = next_pickup_pos[3] + 1
            end
        end

        -- Actually obtain those items from inventory column
        fetch_from_inventory_column()

        -- Place blocks!
        while place_at(
            schematic.layers[next_pickup_pos[1]][next_pickup_pos[2]][next_pickup_pos[3]], -- Block id
            next_place_pos[1], -- Layer (y)
            next_place_pos[2], -- Row (z)
            next_place_pos[3] -- Column (x)
        ) do
            if next_place_pos[3] == schematic.size.x then
                next_place_pos[3] = 1
                next_place_pos[2] = next_place_pos[2] + 1
            elseif next_place_pos[2] == schematic.size.z then
                next_place_pos[2] = 1
                next_place_pos[1] = next_place_pos[1] + 1
            elseif next_place_pos[1] > schematic.size.y then
                break
            else
                next_place_pos[3] = next_place_pos[3] + 1
            end
        end

        -- Return to base
        go(1,1,0)
        face(0)
        reset_inventory()
    end
end

main()