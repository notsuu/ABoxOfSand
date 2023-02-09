--[[
/-----------------------------------------------\
| Lazy to write an explanation for this script. |
| https://love2d.org/wiki/Config_Files          |
\-----------------------------------------------/
]]--

function love.conf(t)
    t.identity = "ABoxOfSand"          
    t.version = "11.3"                 
    t.window.title = "A Box Of Sand"   
    t.window.icon = nil                
    t.window.width = 1280             
    t.window.height = 720             
    t.window.resizable = true          
    t.window.minwidth = 640             
    t.window.minheight = 480
    t.window.vsync = false            
end