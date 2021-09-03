-- Functions for handling virtual inventories. These are used for the turtle to decide what to pick up from the inventory column,
-- before going to do building.

function reset_inventory()
    turtle.inventory = {
        {},
        {},
        {},
        {},
        {},
        {},
        {},
        {},
        {},
        {},
        {},
        {},
        {},
        {},
        {},
        {}
    }
end

function has_items(turtle_inventory)
    for slot,item in pairs(turtle_inventory) do
        if item ~= nil and item.quantity > 0 then
            return true
        end
    end
    return false
end

-- Add an item to virtual inventory. Adds the item if it can,
function inventory_add(id)
    print("Adding to inventory: " .. id)
    for slot,item in ipairs(turtle.inventory) do
        -- See if the item is already there in a non-full stack.
        if item ~= nil and item.id == id and item.quantity < 64 then -- TODO in later versions, non-64-stacking can be supported.
            turtle.inventory[slot].quantity = turtle.inventory[slot].quantity + 1
            return true
        end
    end
    for slot,item in ipairs(turtle.inventory) do
        if item == nil then
            turtle.inventory[slot] = {id = id, quantity = 1}
            return true
        end
    end
    return false
end