local skullapi = require("./skullapi")

--[[

    This is the default type.
    It activates when no other type is found.
    If you already have a skull model, you should set this type's model to that.
    If you don't have a skull model and don't want one, you can safely delete this.

]]

local default = models:newPart("default","SKULL")

default:newText("explainer"):setScale(0.2):setOutline(true):setOutlineColor(0,0,0):setAlignment("CENTER"):setPos(0,6,0)
:setText("This is the default type.\n Read more in §ddefault.lua")

skullapi:newType("default")
:setModel(default)