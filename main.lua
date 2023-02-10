--[[
/---------------------------------------------------------------------------------------\
| If you couldn't guess from the main.lua name, this script handles the main game loop. |
| It, however, probably does not, because i am a terrible programmer.                   |
| Either that, or WHY CAN'T VSCODE SHOW ME THE ERRORS RIGHT IN THE SCRIPT               |
\---------------------------------------------------------------------------------------/
]]--

require 'lua.utils'
json = require 'lua.json'
phys = require 'lua.phys'
save = require 'lua.save'

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
        simulation = {},
        simulationRunning = true
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
    if game.simulationRunning then simulateGravity() end
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
            ok, data = pcall(json.encode,game.simulation)
            if not ok then ui.sendMessage('Failed to encode JSON: '..data, ui.colors.error,6) else
            success, message = love.filesystem.write('save.json',data)
            if success then ui.sendMessage('Simulation saved', ui.colors.ok)
            else ui.sendMessage('Failed to save: '..message, ui.colors.error,6) end end
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
        end,
        f9 = function()
            error('The operation completed successfully.')
        end,
        k = function()
            success, ret = pcall(encodeSave, game.simulation)
            if success then
                fsuccess, status = love.filesystem.write('save.sand',ret)
                if fsuccess then ui.sendMessage('Simulation saved',ui.colors.ok) else ui.sendMessage('Failed to save: '..status,ui.colors.error,6) end
            else
                ui.sendMessage('Failed to encode save: '..ret,ui.colors.error,6)
            end
        end,
        f7 = function()
            game.simulationRunning = not game.simulationRunning
            if game.simulationRunning then ui.sendMessage('Simulation unpaused') else ui.sendMessage('Simulation paused') end
        end
    }
    if binds[key] then binds[key]() end
end

local utf8 = require("utf8")

local function error_printer(msg, layer)
	print((debug.traceback("Error: " .. tostring(msg), 1+(layer or 1)):gsub("\n[^\n]+$", "")))
end

function love.errorhandler(msg)
	msg = tostring(msg)

	error_printer(msg, 2)

	if not love.window or not love.graphics or not love.event then
		return
	end

	if not love.graphics.isCreated() or not love.window.isOpen() then
		local success, status = pcall(love.window.setMode, 800, 600)
		if not success or not status then
			return
		end
	end

	-- Reset state.
	if love.mouse then
		love.mouse.setVisible(true)
		love.mouse.setGrabbed(false)
		love.mouse.setRelativeMode(false)
		if love.mouse.isCursorSupported() then
			love.mouse.setCursor()
		end
	end
	if love.joystick then
		-- Stop all joystick vibrations.
		for i,v in ipairs(love.joystick.getJoysticks()) do
			v:setVibration()
		end
	end
	if love.audio then love.audio.stop() end

	love.graphics.reset()
	local font = love.graphics.setNewFont(14)

	love.graphics.setColor(0, 0, 0)

	local trace = debug.traceback()

	love.graphics.origin()

	local sanitizedmsg = {}
	for char in msg:gmatch(utf8.charpattern) do
		table.insert(sanitizedmsg, char)
	end
	sanitizedmsg = table.concat(sanitizedmsg)

	local err = {}

	table.insert(err, sanitizedmsg)

	if #sanitizedmsg ~= #msg then
		table.insert(err, "Invalid UTF-8 string in error message.")
	end

	table.insert(err, "")

	for l in trace:gmatch("(.-)\n") do
		if not l:match("boot.lua") then
			l = l:gsub("stack traceback:", "Error traceback:\n")
			table.insert(err, l)
		end
	end

	local p = table.concat(err, "\n")

	p = p:gsub("\t", "")
	p = p:gsub("%[string \"(.-)\"%]", "%1")
    largeFont = love.graphics.newFont(32)

	local function draw()
		if not love.graphics.isActive() then return end
		local pos = 30
		love.graphics.clear(1, 0, 0)
        love.graphics.rectangle('line',pos/2,pos/2,love.graphics.getWidth()-pos,love.graphics.getHeight()-pos)
        love.graphics.printf("FATAL ERROR", largeFont, pos, pos, love.graphics.getWidth()-pos, "center")
		love.graphics.printf(p, pos, pos+44, love.graphics.getWidth() - pos)
		love.graphics.present()
	end
    
	local fullErrorText = p
	local function copyToClipboard()
		if not love.system then return end
		love.system.setClipboardText(fullErrorText)
		p = p .. "\nCopied to clipboard!"
	end
    logname = "crash_"..os.date('%d-%m-%Y_%H-%M-%S')..".log"
    success, content = love.filesystem.write(logname,p)
    if success then p = p.."\n\nTraceback dumped, see "..love.filesystem.getSaveDirectory().."/"..logname else p = p.."Traceback dump failed ("..content..")" end
	if love.system then
		p = p .. "\n\nPress Ctrl+C or tap to copy this error"
	end
   

	return function()
		love.event.pump()

		for e, a, b, c in love.event.poll() do
			if e == "quit" then
				return 1
			elseif e == "keypressed" and a == "escape" then
				return 1
			elseif e == "keypressed" and a == "c" and love.keyboard.isDown("lctrl", "rctrl") then
				copyToClipboard()
			elseif e == "touchpressed" then
				local name = love.window.getTitle()
				if #name == 0 or name == "Untitled" then name = "Game" end
				local buttons = {"OK", "Cancel"}
				if love.system then
					buttons[3] = "Copy to clipboard"
				end
				local pressed = love.window.showMessageBox("Quit "..name.."?", "", buttons)
				if pressed == 1 then
					return 1
				elseif pressed == 3 then
					copyToClipboard()
				end
			end
		end

		draw()

		if love.timer then
			love.timer.sleep(0.1)
		end
	end

end