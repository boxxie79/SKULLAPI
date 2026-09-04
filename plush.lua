local skullapi = require("./skullapi")

local fumos = models.fumo.SKULL.fumos

local default = models.fumo.SKULL.default

default:newText("explainer"):setText("This is the default model.\nIt shows when no valid type is selected.\nIt's optional, and you can remove the\n§d:setDefaultModel()§r function to disable it.")
:setScale(0.2):setAlignment("CENTER"):setPos(0,8,0)
skullapi:setDefaultModel(default)


skullapi:newType("fumo")
:setNames({"fumo","plush"})
:setModel(fumos)
:setRenderFunction(function(skull,delta,block,item,entity,mode)

    --[[
        The skull argument returns a table unique to every interactable
        instance of the skull. Already set up, you'll find:
        - pos: vector3
        - name: string
        - active: returns either nil or entity that triggered it.
        The other 5 arguments are passed through directly from SKULL_RENDER.
        You can set up your own skull specific variables with the code below.
    ]]

    if not skull.animTime then
        skull.animTime = 1
        skull.rotation = 0
    end

    fumos:setPos(0,mode:find("HEAD") and 8 or 0,0)
    :setRot(0,skull.rotation+math.lerp(0,skull.redstone,delta),0)
    :setScale(
        1,
        skull.animTime+(skull.animTime == 1 and 0 or math.lerp(0,0.05,delta)),
        1
    )

end):setTriggerFunction(function(skull,delta,block,item,entity,mode)
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
    if skull.redstone > 0 then
        skull.rotation = skull.rotation + skull.redstone
    else
        skull.rotation = 0
    end
end)
