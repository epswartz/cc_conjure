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