--[[
/----------------------------------------------------------\
| A set of helper functions to aid in game logic handling. |
\----------------------------------------------------------/
]]--

--Checks if a particle exists at a certain coordinate.
function particleAlreadyExists(x,y)
    found = false
    for _,v in ipairs(game.simulation) do
        if v.x == x and v.y == y then
            found = true
        end
    end
    return found
end

--Returns a table with all pixels from sx and sy to ex and ey.
function getPixelsInArea(sx,sy,ex,ey)
    pixels = {}
    for x=sx,ex,1 do 
        for y=sy,ey,1 do
            table.insert(pixels,{x=x,y=y})
        end
    end
    return pixels
end

--WHY ISNT THIS A BUILT IN FUNCTION
function math.clamp(num,min,max)
    if num < min then return min elseif num > max then return max else return num end
end

--Returns true if a number is between a specified range
function rangeCheck(num,min,max,inclusive)
    inclusive = inclusive or false
    if inclusive then return num >= min and num <= max else return num > min and num < max end
end

return {particleAlreadyExists,getPixelsInArea,math.clamp,rangeCheck}