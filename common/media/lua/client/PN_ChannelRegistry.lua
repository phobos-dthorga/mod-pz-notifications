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
-- PN_ChannelRegistry.lua
-- Registration and muting state for notification channels.
-- Muted channels are persisted in player modData.
---------------------------------------------------------------

require "PN_Constants"

PN_ChannelRegistry = {}

local channels = {}

--- Register a notification channel.
--- @param def table { id = string, labelKey = string, defaultEnabled = boolean|nil }
function PN_ChannelRegistry.register(def)
    if not def or not def.id then return end
    channels[def.id] = {
        id = def.id,
        labelKey = def.labelKey or ("UI_PN_Channel_" .. def.id),
        defaultEnabled = def.defaultEnabled ~= false,
    }
end

--- Get a channel definition by ID.
--- @param channelId string
--- @return table|nil
function PN_ChannelRegistry.get(channelId)
    return channels[channelId]
end

--- Get all registered channels.
--- @return table[] Array of channel definitions
function PN_ChannelRegistry.getAll()
    local result = {}
    for _, ch in pairs(channels) do
        table.insert(result, ch)
    end
    table.sort(result, function(a, b) return a.id < b.id end)
    return result
end

---------------------------------------------------------------
-- Muting (per-player)
---------------------------------------------------------------

local function getMutedSet(player)
    if not player then return {} end
    local md = player:getModData()
    if not md then return {} end
    if not md[PN_Constants.MD_MUTED_CHANNELS] then
        md[PN_Constants.MD_MUTED_CHANNELS] = {}
    end
    return md[PN_Constants.MD_MUTED_CHANNELS]
end

--- Check if a channel is enabled (not muted) for the given player.
--- @param player any IsoPlayer
--- @param channelId string
--- @return boolean
function PN_ChannelRegistry.isEnabled(player, channelId)
    local muted = getMutedSet(player)
    if muted[channelId] then return false end

    local def = channels[channelId]
    if def then return def.defaultEnabled end

    return true
end

--- Set whether a channel is enabled for the given player.
--- @param player any IsoPlayer
--- @param channelId string
--- @param enabled boolean
function PN_ChannelRegistry.setEnabled(player, channelId, enabled)
    local muted = getMutedSet(player)
    if enabled then
        muted[channelId] = nil
    else
        muted[channelId] = true
    end
end

---------------------------------------------------------------
-- Default channel
---------------------------------------------------------------

PN_ChannelRegistry.register({
    id = PN_Constants.CHANNEL_DEFAULT,
    labelKey = "UI_PN_Channel_Default",
    defaultEnabled = true,
})
