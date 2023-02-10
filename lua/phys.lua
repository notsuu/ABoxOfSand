--[[
/----------------------------------------------------------------------\
| The physics loop handler. Dear god this is probably gonna be a mess. |
\----------------------------------------------------------------------/
]]--

local gravity = 5

function particleOnFloor(particle)
    if particle.y >= love.graphics.getHeight() then return true else return false end
end

function anyParticlesBelow(particle,simulation)
    local found, fx, fy = false, 0, 0
    for i,v in ipairs(simulation) do
        if v.x == particle.x and v.y == particle.y + 1 then found = true; fx = v.x; fy = v.y; break end
    end
    return found, fx, fy
end

function simulateGravity()
    --loop through all particles and see which must be dropped and which must not
    for i,v in ipairs(game.simulation) do
        --check if particle is not on ground and theres nothing below it
        if not particleOnFloor(v) and not anyParticlesBelow(v,game.simulation) then
            v.falling = true
        else
            v.falling = false
        end
    end
    --The cycle shall begin anew. Loop through particles again and drop the ones that, well, need to fall
    for i,v in ipairs(game.simulation) do
        if v.falling then v.y = v.y + 1 end
    end
end

return {particleOnFloor, anyParticlesBelow, simulateGravity}