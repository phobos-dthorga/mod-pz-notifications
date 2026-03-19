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
-- PhobosNotifications.lua
-- Public API for the Phobos Notifications system.
-- Other mods call these functions to display toast notifications.
---------------------------------------------------------------

require "PhobosLib"
require "PN_Constants"

PhobosNotifications = {}

PhobosNotifications.VERSION = PN_Constants.VERSION

---------------------------------------------------------------
-- Toast
---------------------------------------------------------------

--- Display a toast notification.
---
--- @param opts table
---   opts.title       string|nil   Bold header line
---   opts.message     string       Body text (required)
---   opts.icon        string|nil   Item fullType or texture path
---   opts.colour      string|nil   Preset: "info"|"success"|"warning"|"error"|"custom"
---   opts.customColour table|nil   {r,g,b,a} when colour="custom"
---   opts.duration    number|nil   Seconds (overrides sandbox default)
---   opts.priority    string|nil   "low"|"normal"|"high"|"critical"
---   opts.channel     string|nil   Mod-specific channel ID for filtering
---   opts.onClick     function|nil Callback when notification is clicked
---   opts.onDismiss   function|nil Callback when notification expires/dismissed
---   opts.sound       string|nil   Sound name to play on show
---   opts.sticky      boolean|nil  If true, doesn't auto-dismiss
---
--- @return string|nil notificationId, or nil if notifications are disabled
function PhobosNotifications.toast(opts)
    if not opts then
        PhobosLib.debug("PN", "[PN:API]", "toast() called with nil opts")
        return nil
    end

    if not opts.message or opts.message == "" then
        PhobosLib.debug("PN", "[PN:API]", "toast() requires a message")
        return nil
    end

    -- Check if notifications are globally disabled
    if not PN_Sandbox.getEnableNotifications() then
        return nil
    end

    -- Check if channel is muted
    local channel = opts.channel or PN_Constants.CHANNEL_DEFAULT
    local player = getSpecificPlayer(0)
    if player and PN_ChannelRegistry and not PN_ChannelRegistry.isEnabled(player, channel) then
        return nil
    end

    -- Delegate to manager (client-side only)
    if not PN_NotificationManager then
        PhobosLib.debug("PN", "[PN:API]", "NotificationManager not loaded (server-side?)")
        return nil
    end

    return PN_NotificationManager.enqueue(opts)
end

---------------------------------------------------------------
-- Dismiss
---------------------------------------------------------------

--- Manually dismiss a notification by ID.
--- @param notificationId string
function PhobosNotifications.dismiss(notificationId)
    if PN_NotificationManager then
        PN_NotificationManager.dismiss(notificationId)
    end
end

--- Dismiss all notifications, optionally filtered by channel.
--- @param channel string|nil If nil, dismisses all
function PhobosNotifications.dismissAll(channel)
    if PN_NotificationManager then
        PN_NotificationManager.dismissAll(channel)
    end
end

---------------------------------------------------------------
-- Channel management
---------------------------------------------------------------

--- Register a notification channel for a mod.
--- @param channelDef table { id = string, labelKey = string, defaultEnabled = boolean|nil }
function PhobosNotifications.registerChannel(channelDef)
    if PN_ChannelRegistry then
        PN_ChannelRegistry.register(channelDef)
    end
end

--- Set whether a channel is enabled for the current player.
--- @param channel string Channel ID
--- @param enabled boolean
function PhobosNotifications.setChannelEnabled(channel, enabled)
    local player = getSpecificPlayer(0)
    if player and PN_ChannelRegistry then
        PN_ChannelRegistry.setEnabled(player, channel, enabled)
    end
end

--- Check if a channel is enabled for the current player.
--- @param channel string Channel ID
--- @return boolean
function PhobosNotifications.isChannelEnabled(channel)
    local player = getSpecificPlayer(0)
    if player and PN_ChannelRegistry then
        return PN_ChannelRegistry.isEnabled(player, channel)
    end
    return true
end

---------------------------------------------------------------
-- Utility
---------------------------------------------------------------

--- Get the count of pending + active notifications.
--- @return number
function PhobosNotifications.getCount()
    if PN_NotificationManager then
        return PN_NotificationManager.getCount()
    end
    return 0
end
