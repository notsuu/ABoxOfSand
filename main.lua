--[[
/---------------------------------------------------------------------------------------\
| If you couldn't guess from the main.lua name, this script handles the main game loop. |
| It, however, probably does not, because i am a terrible programmer.                   |
| Either that, or WHY CAN'T VSCODE SHOW ME THE ERRORS RIGHT IN THE SCRIPT               |
\---------------------------------------------------------------------------------------/
]]--

require 'lua.utils'
json = require 'lua.json'

function love.load()
    game = {
        materials = {
            current = 'sand',
            index = 1,
            names = {'sand','stone','wood','metal'},
            sand = {type='powder', color = {0.9, 0.75, 0.4}},
            stone = {type='solid', color = {0.25, 0.25, 0.25}},
            wood = {type='solid', color = {0.5, 0.25, 0.0}},
            metal = {type='solid', color = {0.65, 0.65, 0.65}},
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
            timeout = 0,
        },
        sendMessage = function(text,color,time)
            ui.message.content = text or ""
            ui.message.color = color or ui.colors.standard
            ui.message.time = os.time()
            ui.message.timeout = time or 4
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
                table.insert(game.simulation,{x = v.x, y = v.y, type = game.materials.current}) 
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
        love.graphics.setColor(game.materials[v.type].color)
        love.graphics.rectangle("fill",v.x,v.y,1,1)
    end
    --draw debug
    love.graphics.setColor(1,1,1)
    love.graphics.print(love.timer.getFPS().." fps\n"..#game.simulation.." particles\nMaterial: "..game.materials.current.."\nBrush size: "..game.brushSize,15,15)
    --draw notification message
    love.graphics.setColor(ui.message.color)
    if os.time() - ui.message.time <= ui.message.timeout then love.graphics.print(ui.message.content,15,height-30) end
end

function love.wheelmoved(x,y)
    if y > 0 then
        game.brushSize = math.clamp(game.brushSize + 1,1,32)
    elseif y < 0 then
        game.brushSize = math.clamp(game.brushSize - 1,1,32)
    end
end

function love.keypressed(key)
    binds = {
        q = function()
            game.simulation = {}
            ui.sendMessage('Simulation cleared')
        end,
        tab = function()
            game.materials.index = game.materials.index + 1; if game.materials.index > #game.materials.names then game.materials.index = 1 end
            game.materials.current = game.materials.names[game.materials.index]
        end,
        o = function()
            jsonEncode = json.encode(game.simulation)
            success, message = love.filesystem.write('save.json',jsonEncode)
            if success then ui.sendMessage('Simulation saved', ui.colors.ok)
            else ui.sendMessage('Failed to save: '..message, ui.colors.error,6) end
        end,
        p = function()
            contents, sizeOrError = love.filesystem.read('save.json')
            if contents then 
                success, data = pcall(json.decode, contents)
                if not success then
                     ui.sendMessage('Failed to decode JSON: '..data, ui.colors.error,6);
                else
                game.simulation = data
                ui.sendMessage('Simulation loaded', ui.colors.ok) end
            else ui.sendMessage('Failed to load: '..sizeOrError, ui.colors.error,6) end
        end
    }
    if binds[key] then binds[key]() end
end