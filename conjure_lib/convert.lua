-- Conversion utils between various table formats.

-- Input: the output of a getItemDetail() call
-- Output: The string key returned by inventory functions
function itemDetailToItemKey(itemDetail)
    return itemDetail.name .. "/" .. itemDetail.damage
end