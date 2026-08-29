local skullapi = require("./skullapi")

local fumos = models.fumo.SKULL.fumos

skullapi:newType("fumo")
:setNames({"fumo","plush"})
:setModel(fumos)
:setRenderFunction(function(skull,delta,block,item,entity,mode)
    if not skull.animTime then
        skull.animTime = 1
    end
    local type = skull.name:lower():gsub("fumo",""):gsub(" ","")
    if textures["textures.fumo."..type] then
        fumos:setPrimaryTexture("CUSTOM",textures["textures.fumo."..type])
    end

    fumos:setPos(0,mode:find("HEAD") and 8 or 0,0)
    :setScale(
        1,
        skull.animTime+(skull.animTime == 1 and 0 or math.lerp(0,0.05,delta)),
        1
    )

end):setTriggerFunction(function(skull,delta,block,item,entity,mode)
    -- if not block then return end
    skull.animTime = 0.8
    sounds["squeak"]
    :setPos(skull.pos)
    :setSubtitle(skull.name.." squeaks")
    :setVolume(0.5)
    :setPitch(0.75+math.random()/2)
    :play()
end):setTickFunction(function(skull)
    if skull.animTime < 1 then
        skull.animTime = skull.animTime + 0.05
    end
    if skull.animTime > 1 then
        skull.animTime = 1
    end
end)