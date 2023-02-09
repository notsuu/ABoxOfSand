--[[
/---------------------------------------------------------------------------------------\
| If you couldn't guess from the main.lua name, this script handles the main game loop. |
| It, however, probably does not, because i am a terrible programmer.                   |
| Either that, or WHY CAN'T VSCODE SHOW ME THE ERRORS RIGHT IN THE SCRIPT               |
\---------------------------------------------------------------------------------------/
]]--

require 'lua.utils'

function love.load()
    game = {
        material = 'sand',
        materials = {
            'sand', 'stone', 'wood', 'metal'
        },
        materialColors = {
            sand = {0.9, 0.75, 0.4},
            stone = {0.25, 0.25, 0.25},
            wood = {0.5, 0.25, 0.0},
            metal = {0.65, 0.65, 0.65}
        },
        brushSize = 10,
        simulation = {}
    }
    ui = {
        colors = {
            standard = {1,1,1,1},
            info = {0,0.5,1,1},
            ok = {0,1,0,1},
            warn = {1,0.75,1,1},
            error = {1,0,0,1}
        },
        message = {
            time = 0,
            content = "",
            color = {0,0,0,1},
        },
        sendMessage = function(text,color)
            ui.message.content = text or ""
            ui.message.color = color or ui.colors.standard
            ui.message.time = os.time()
        end
    }
    --once everything has been initialized, call ready message
    ui.sendMessage("Simulation ready", ui.colors.ok)
end

function love.update()
    mouseX, mouseY = love.mouse.getX(), love.mouse.getY()
    if love.mouse.isDown(1) then
        --left click, handle spawning
        sx = mouseX - game.brushSize
        sy = mouseY - game.brushSize
        ex = mouseX + game.brushSize
        ey = mouseY + game.brushSize
        brushArea = getPixelsInArea(sx,sy,ex,ey)
        if not particleAlreadyExists(mouseX, mouseY) then
            for _, v in ipairs(brushArea) do
                table.insert(game.simulation,{x = v.x, y = v.y, type = 'sand'}) 
            end
        end
    elseif love.mouse.isDown(2) then
        --right click, handle eraser
        for i, v in ipairs(game.simulation) do
            if rangeCheck(v.x,mouseX-game.brushSize,mouseX+game.brushSize,true) and rangeCheck(v.y,mouseY-game.brushSize,mouseY+game.brushSize,true) then table.remove(game.simulation,i) end
        end
    end
end

function love.draw()
    width, height, flags = love.window.getMode()
    --draw particles
    for _,v in ipairs(game.simulation) do
        love.graphics.setColor(game.materialColors[v.type])
        love.graphics.rectangle("fill",v.x,v.y,1,1)
    end
    --draw debug
    love.graphics.setColor(1,1,1)
    love.graphics.print(love.timer.getFPS().." fps\n"..#game.simulation.." particles\nBrush size: "..game.brushSize,15,15)
    --draw notification message
    love.graphics.setColor(ui.message.color[1],ui.message.color[2],ui.message.color[3])
    if os.time() - ui.message.time <= 4 then love.graphics.print(ui.message.content,15,height-30) end
end

function love.wheelmoved(x,y)
    if y > 0 then
        game.brushSize = math.clamp(game.brushSize + 1,1,32)
    elseif y < 0 then
        game.brushSize = math.clamp(game.brushSize - 1,1,32)
    end
end

function love.keypressed(key)
    if key == 'q' then
        game.simulation = {}
        ui.sendMessage('Simulation cleared')
    elseif key == 'tab' then
    
    end
end