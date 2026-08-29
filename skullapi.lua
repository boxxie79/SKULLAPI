--[[
         /##'                                        ########  .n#%%#n.
        ##/'                             💮               ##  ##     #\
       ##                                                ##  |#.    %#
 d#-  ######b.d##b  #.  .n$n.  #.  /## /##n   .n##n.    ##   "^#%%^%#
#;   ##;  '###/ \#b \#/##/\XX\ \#/##/ # ##   ##___##   ##         /#
\## d##.  .###\ /#p .##/#\ \XX /##/#\  ## # ##''''..  ##  /#n   ./#
 "^#^":#### "^%#%^ #^"  \#  '^$^'  \# ^##/  "^###^"  ##   "^#%%#^"
]]

--[[
    boxxie79's skull api
    v1.0.1 (hotfix)
    https://github.com/boxxie79/SKULLAPI
]]

local skullapi = {}
skullapi.__index = skullapi

skullapi.types = {}
skullapi.skulls = {}
skullapi.debugMode = false
local pivot = models:newPart("skullapitextpivot","SKULL"):setPos(0,16,0)
local ptext = pivot:newPart("idc","CAMERA"):newText("skullapidebugtext")
:setOutline(true):setOutlineColor(0,0,0):setSeeThrough(true)
:setScale(0.15):setAlignment("CENTER")

function events.skull_render(delta,block,item,entity,mode)
    local id = ""

    local name = ""
    local redstone = 0
    local pos

    if block then
        local data = block:getEntityData()
        if data and data.custom_name then
            name = data.custom_name:sub(2,#data.custom_name-1)
        end
        pos = block:getPos()
        redstone = world.getRedstonePower(pos)
        id = tostring(pos)
    end
    if item and not block then
        name = item:getName()
        pos = nil
    end
    if entity and entity:isLiving() then
        pos = entity:getPos()
        id = entity:getName().."_"..mode
    end

    if not skullapi.skulls[id] then
        skullapi.skulls[id] = {}
    end
    skullapi.skulls[id].name = name
    skullapi.skulls[id].redstone = redstone
    skullapi.skulls[id].pos = pos
    skullapi.skulls[id].triggered = false
    
    --interact
    if entity then
        if entity:isSwingingArm() and not skullapi.skulls[id].active then
            skullapi.skulls[id].active = true
            skullapi.skulls[id].triggered = true
        elseif not entity:isSwingingArm() and skullapi.skulls[id].active then
            skullapi.skulls[id].active = false
        end
    end
    if block then
        for name,entity in pairs(world:getPlayers()) do
            if entity:getTargetedBlock():getPos() == block:getPos() and entity:getSwingTime() > 1 and not skullapi.skulls[id].active then
                skullapi.skulls[id].active = entity
                skullapi.skulls[id].triggered = true
                -- log(block)
            end
            if skullapi.skulls[id].active and skullapi.skulls[id].active:getSwingTime() < 1 then
                skullapi.skulls[id].active = false
            end 
        end
    end

    --render
    for _,type in pairs(skullapi.types) do
        local isThisType = false
        for i=1,#type.names do
            if name:lower():find(type.names[i]:lower()) then
                isThisType = true
                skullapi.skulls[id].type = _
            end
        end
        type.modelpart:setVisible(isThisType)
        if isThisType then
            if type.func.render then
                type.func.render(skullapi.skulls[id],delta,block,item,entity,mode)
            end
            if type.func.trigger and skullapi.skulls[id].triggered then
                type.func.trigger(skullapi.skulls[id],delta,block,item,entity,mode)
            end
        end
    end

    local debugText

    if skullapi.debugMode then
        debugText = ":pencil: "..name..
        "\n:4k: "..mode..
        "\n:paw: "..tostring(skullapi.skulls[id].triggered)
        if entity then
            debugText = debugText..
            "\n:chess: "..entity:getName()..
            " :mci_diamond_sword: "..tostring(entity:isSwingingArm())
        elseif block then
            debugText = debugText..
            " :mcb_redstone: "..redstone..
            -- " :eyes: "..tostring(lib.focused)..
            "\n:mcb_grass_block: "..tostring(pos)
        end
        ptext
        :setAlignment(mode:find("RIGHT") and "RIGHT" or mode:find("LEFT") and "LEFT" or "CENTER")
        :setScale(mode:find("FIRST") and 0.03 or 0.2)
        :setPos(mode == "FIRST_PERSON_RIGHT_HAND" and 2 or mode == "FIRST_PERSON_LEFT_HAND" and -2 or 0,mode:find("FIRST_PERSON") and 0 or 6,0)
    end
    
    ptext:setText(debugText)
end

function events.tick()
    for k,skull in pairs(skullapi.skulls) do
        if skullapi.types[skull.type] and skullapi.types[skull.type].func.tick then
            skullapi.types[skull.type].func.tick(skull)
        end
    end
end

function skullapi:newType(name)
    skullapi.types[name] = setmetatable({},skullapi)
    skullapi.types[name].func = {}
    return skullapi.types[name]
end

function skullapi:setNames(t)
    self.names = t
    return self
end

-- function skullapi:setMode(t)
--     -- 0 - default, usable everywhere
--     -- 1 - only usable as item
--     -- 2 - only usable as block
--     self.names = t
--     return self
-- end

function skullapi:setModel(t)
    self.modelpart = t
    return self
end

function skullapi:setRenderFunction(f)
    self.func.render = f
    return self
end

function skullapi:setTickFunction(f)
    self.func.tick = f
    return self
end

function skullapi:setTriggerFunction(f)
    self.func.trigger = f
    return self
end

return skullapi