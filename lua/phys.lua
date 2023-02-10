--[[
/----------------------------------------------------------------------\
| The physics loop handler. Dear god this is probably gonna be a mess. |
\----------------------------------------------------------------------/
]]--
local gravity = 1

function particleOnFloor(particle)
    if particle.y >= love.graphics.getHeight() then return true else return false end
end

function anyParticlesBelow(particle,simulation)
    local found = false
    for i,v in ipairs(simulation) do
        if v.x == particle.x and v.y == particle.y + 1 then found = true; break end
    end
    return found
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
        if v.falling then v.y = v.y + gravity end
    end
end

return {particleOnFloor, anyParticlesBelow, simulateGravity}