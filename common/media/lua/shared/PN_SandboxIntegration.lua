--  ________________________________________________________________________
-- / Copyright (c) 2026 Phobos A. D'thorga                                \
-- |                                                                        |
-- |           /\_/\                                                         |
-- |         =/ o o \=    Phobos' PZ Modding                                |
-- |          (  V  )     All rights reserved.                              |
-- |     /\  / \   / \                                                      |
-- |    /  \/   '-'   \   This source code is part of the Phobos            |
-- |   /  /  \  ^  /\  \  mod suite for Project Zomboid (Build 42).         |
-- |  (__/    \_/ \/  \__)                                                  |
-- |     |   | |  | |     Unauthorised copying, modification, or            |
-- |     |___|_|  |_|     distribution of this file is prohibited.          |
-- |                                                                        |
-- \________________________________________________________________________/
--

---------------------------------------------------------------
-- PN_SandboxIntegration.lua
-- Sandbox option accessors for PhobosNotifications.
-- All defaults fall back to PN_Constants values.
---------------------------------------------------------------

require "PhobosLib"
require "PN_Constants"

PN_Sandbox = {}

function PN_Sandbox.getEnableNotifications()
    return PhobosLib.getSandboxVar("PN", "EnableNotifications", true)
end

function PN_Sandbox.getDefaultDuration()
    return PhobosLib.getSandboxVar("PN", "DefaultDuration",
        PN_Constants.SANDBOX_DEFAULT_DURATION)
end

function PN_Sandbox.getMaxVisible()
    return PhobosLib.getSandboxVar("PN", "MaxVisible",
        PN_Constants.SANDBOX_DEFAULT_MAX_VISIBLE)
end

function PN_Sandbox.getShowProgressBar()
    return PhobosLib.getSandboxVar("PN", "ShowProgressBar",
        PN_Constants.SANDBOX_DEFAULT_SHOW_PROGRESS)
end

--- Map enum integer (1-4) to position string.
local POSITION_MAP = {
    [1] = PN_Constants.POSITION_TOP_RIGHT,
    [2] = PN_Constants.POSITION_TOP_LEFT,
    [3] = PN_Constants.POSITION_BOTTOM_RIGHT,
    [4] = PN_Constants.POSITION_BOTTOM_LEFT,
}

function PN_Sandbox.getToastPosition()
    local val = PhobosLib.getSandboxVar("PN", "ToastPosition", 1)
    return POSITION_MAP[val] or PN_Constants.POSITION_TOP_RIGHT
end

function PN_Sandbox.getToastWidth()
    return PhobosLib.getSandboxVar("PN", "ToastWidth",
        PN_Constants.SANDBOX_DEFAULT_WIDTH)
end

function PN_Sandbox.getEnableSounds()
    return PhobosLib.getSandboxVar("PN", "EnableSounds",
        PN_Constants.SANDBOX_DEFAULT_ENABLE_SOUNDS)
end

function PN_Sandbox.getAnimationSpeed()
    return PhobosLib.getSandboxVar("PN", "AnimationSpeed",
        PN_Constants.SANDBOX_DEFAULT_ANIM_SPEED)
end

--- Effective slide duration in milliseconds, adjusted by animation speed %.
--- @return number milliseconds
function PN_Sandbox.getEffectiveSlideDuration()
    local speed = PN_Sandbox.getAnimationSpeed()
    if speed <= 0 then speed = PN_Constants.SANDBOX_DEFAULT_ANIM_SPEED end
    return PN_Constants.ANIM_SLIDE_DURATION_MS * (100 / speed)
end
