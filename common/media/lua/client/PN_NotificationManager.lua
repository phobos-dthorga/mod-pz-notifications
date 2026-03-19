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
-- PN_NotificationManager.lua
-- Core notification queue, animation state machine, and
-- render loop. Manages toast lifecycle from queue to screen.
---------------------------------------------------------------

require "ISUI/ISPanel"
require "PN_Constants"
require "PN_SandboxIntegration"
require "PN_NotificationPanel"
require "PN_ChannelRegistry"

PN_NotificationManager = {}

local C = PN_Constants

---------------------------------------------------------------
-- Internal state
---------------------------------------------------------------

local queue = {}           -- pending notifications (not yet visible)
local active = {}          -- currently visible/animating notifications
local nextId = 1
local lastTickMs = 0

---------------------------------------------------------------
-- ID generation
---------------------------------------------------------------

local function generateId()
    local id = "pn_" .. tostring(nextId)
    nextId = nextId + 1
    return id
end

---------------------------------------------------------------
-- Icon resolution
---------------------------------------------------------------

local function resolveIcon(iconStr)
    if not iconStr then return nil end

    -- Try as item fullType first
    local ok, result = pcall(function()
        local script = ScriptManager.instance:getItem(iconStr)
        if script then
            return script:getIconTexture()
        end
        return nil
    end)
    if ok and result then return result end

    -- Try as texture path
    local texOk, tex = pcall(function()
        return getTexture(iconStr)
    end)
    if texOk and tex then return tex end

    return nil
end

---------------------------------------------------------------
-- Position calculation
---------------------------------------------------------------

local function getScreenDimensions()
    local sw = getCore():getScreenWidth()
    local sh = getCore():getScreenHeight()
    return sw, sh
end

local function getToastX(toastWidth)
    local sw = getScreenDimensions()
    local pos = PN_Sandbox.getToastPosition()
    if pos == C.POSITION_TOP_LEFT or pos == C.POSITION_BOTTOM_LEFT then
        return C.TOAST_MARGIN_RIGHT
    end
    return sw - toastWidth - C.TOAST_MARGIN_RIGHT
end

local function isBottomPosition()
    local pos = PN_Sandbox.getToastPosition()
    return pos == C.POSITION_BOTTOM_LEFT or pos == C.POSITION_BOTTOM_RIGHT
end

local function getToastTargetY(slotIndex)
    local _, sh = getScreenDimensions()
    local toastH = C.TOAST_MIN_HEIGHT
    local offset = slotIndex * (toastH + C.TOAST_GAP)

    if isBottomPosition() then
        return sh - C.TOAST_MARGIN_TOP - toastH - offset
    end
    return C.TOAST_MARGIN_TOP + offset
end

local function getOffscreenY()
    if isBottomPosition() then
        local _, sh = getScreenDimensions()
        return sh + C.TOAST_MAX_HEIGHT
    end
    return -(C.TOAST_MAX_HEIGHT)
end

---------------------------------------------------------------
-- Animation helpers
---------------------------------------------------------------

local function easeOutCubic(t)
    local t1 = t - 1
    return t1 * t1 * t1 + 1
end

local function easeInCubic(t)
    return t * t * t
end

local function lerp(a, b, t)
    return a + (b - a) * t
end

---------------------------------------------------------------
-- Enqueue
---------------------------------------------------------------

--- Add a notification to the queue.
--- @param opts table Notification options (validated by PhobosNotifications.toast)
--- @return string notificationId
function PN_NotificationManager.enqueue(opts)
    if #queue >= C.MAX_QUEUE_SIZE then
        table.remove(queue, 1)
    end

    local id = generateId()
    local notification = {
        id = id,
        title = opts.title,
        message = opts.message or "",
        icon = opts.icon,
        iconTexture = resolveIcon(opts.icon),
        colour = opts.colour or C.COLOUR_PRESET_INFO,
        customColour = opts.customColour,
        duration = opts.duration or PN_Sandbox.getDefaultDuration(),
        priority = opts.priority or C.PRIORITY_NORMAL,
        channel = opts.channel or C.CHANNEL_DEFAULT,
        onClick = opts.onClick,
        onDismiss = opts.onDismiss,
        sound = opts.sound,
        sticky = opts.sticky or false,
        showProgress = PN_Sandbox.getShowProgressBar() and not opts.sticky,
        progress = 1.0,
        state = nil,
        stateStartMs = 0,
        currentY = getOffscreenY(),
        targetY = 0,
        startY = getOffscreenY(),
        slotIndex = 0,
        panel = nil,
    }

    -- High/critical priority: insert at front of queue
    if opts.priority == C.PRIORITY_HIGH or opts.priority == C.PRIORITY_CRITICAL then
        table.insert(queue, 1, notification)
    else
        table.insert(queue, notification)
    end

    -- Critical notifications are sticky by default
    if opts.priority == C.PRIORITY_CRITICAL then
        notification.sticky = true
        notification.showProgress = false
    end

    return id
end

---------------------------------------------------------------
-- Dismiss
---------------------------------------------------------------

--- Dismiss a notification by ID.
--- @param notificationId string
function PN_NotificationManager.dismiss(notificationId)
    -- Check active
    for _, notif in ipairs(active) do
        if notif.id == notificationId and notif.state ~= C.ANIM_STATE_EXITING
            and notif.state ~= C.ANIM_STATE_DONE then
            notif.state = C.ANIM_STATE_EXITING
            notif.stateStartMs = lastTickMs
            notif.startY = notif.currentY
            notif.targetY = getOffscreenY()
            return
        end
    end

    -- Check queue
    for i, notif in ipairs(queue) do
        if notif.id == notificationId then
            table.remove(queue, i)
            return
        end
    end
end

--- Dismiss all notifications, optionally filtered by channel.
--- @param channel string|nil
function PN_NotificationManager.dismissAll(channel)
    -- Dismiss active
    for _, notif in ipairs(active) do
        if (not channel or notif.channel == channel)
            and notif.state ~= C.ANIM_STATE_EXITING
            and notif.state ~= C.ANIM_STATE_DONE then
            notif.state = C.ANIM_STATE_EXITING
            notif.stateStartMs = lastTickMs
            notif.startY = notif.currentY
            notif.targetY = getOffscreenY()
        end
    end

    -- Remove from queue
    if channel then
        for i = #queue, 1, -1 do
            if queue[i].channel == channel then
                table.remove(queue, i)
            end
        end
    else
        queue = {}
    end
end

---------------------------------------------------------------
-- Promote from queue to active
---------------------------------------------------------------

local function promoteFromQueue(nowMs)
    local maxVisible = PN_Sandbox.getMaxVisible()
    local toastWidth = PN_Sandbox.getToastWidth()
    local toastX = getToastX(toastWidth)

    while #active < maxVisible and #queue > 0 do
        local notif = table.remove(queue, 1)

        -- Assign slot
        notif.slotIndex = #active
        notif.targetY = getToastTargetY(notif.slotIndex)
        notif.startY = getOffscreenY()
        notif.currentY = notif.startY
        notif.state = C.ANIM_STATE_ENTERING
        notif.stateStartMs = nowMs

        -- Create panel
        notif.panel = PN_NotificationPanel:new(toastX, notif.currentY, toastWidth, notif)
        notif.panel:addToUIManager()
        notif.panel:setVisible(true)
        notif.panel.onCloseClick = function(_n)
            PN_NotificationManager.dismiss(notif.id)
        end

        -- Play sound
        if notif.sound and PN_Sandbox.getEnableSounds() then
            pcall(function()
                getSoundManager():playUISound(notif.sound)
            end)
        end

        table.insert(active, notif)
    end
end

---------------------------------------------------------------
-- Update loop (called every frame)
---------------------------------------------------------------

--- Update all notification animations. Called from Events.OnPreUIDraw.
function PN_NotificationManager.update()
    if not PN_Sandbox.getEnableNotifications() then return end

    local nowMs = getTimestampMs()
    if lastTickMs == 0 then lastTickMs = nowMs end
    lastTickMs = nowMs

    local slideDuration = PN_Sandbox.getEffectiveSlideDuration()
    local toastWidth = PN_Sandbox.getToastWidth()
    local toastX = getToastX(toastWidth)

    -- Promote queued notifications
    promoteFromQueue(nowMs)

    -- Recalculate slot positions for active (non-exiting) notifications
    local slotIdx = 0
    for _, notif in ipairs(active) do
        if notif.state ~= C.ANIM_STATE_EXITING and notif.state ~= C.ANIM_STATE_DONE then
            local newTarget = getToastTargetY(slotIdx)
            if notif.state == C.ANIM_STATE_VISIBLE and notif.targetY ~= newTarget then
                -- Smoothly adjust position when toasts above exit
                notif.targetY = newTarget
            end
            notif.slotIndex = slotIdx
            slotIdx = slotIdx + 1
        end
    end

    -- Update each active notification
    for _, notif in ipairs(active) do
        local elapsed = nowMs - notif.stateStartMs

        if notif.state == C.ANIM_STATE_ENTERING then
            local t = math.min(1.0, elapsed / slideDuration)
            notif.currentY = lerp(notif.startY, notif.targetY, easeOutCubic(t))

            if t >= 1.0 then
                notif.currentY = notif.targetY
                notif.state = C.ANIM_STATE_VISIBLE
                notif.stateStartMs = nowMs
            end

        elseif notif.state == C.ANIM_STATE_VISIBLE then
            -- Smooth slot repositioning
            if math.abs(notif.currentY - notif.targetY) > 1 then
                notif.currentY = lerp(notif.currentY, notif.targetY, 0.15)
            else
                notif.currentY = notif.targetY
            end

            -- Update progress bar
            if not notif.sticky then
                local durationMs = notif.duration * 1000
                notif.progress = 1.0 - math.min(1.0, elapsed / durationMs)

                -- Pause countdown when hovered
                if notif.panel and notif.panel.hovered then
                    notif.stateStartMs = notif.stateStartMs + (nowMs - lastTickMs)
                end

                if elapsed >= durationMs then
                    notif.state = C.ANIM_STATE_EXITING
                    notif.stateStartMs = nowMs
                    notif.startY = notif.currentY
                    notif.targetY = getOffscreenY()
                end
            end

        elseif notif.state == C.ANIM_STATE_EXITING then
            local t = math.min(1.0, elapsed / slideDuration)
            notif.currentY = lerp(notif.startY, notif.targetY, easeInCubic(t))

            if t >= 1.0 then
                notif.state = C.ANIM_STATE_DONE
                if notif.panel then
                    notif.panel:removeFromUIManager()
                    notif.panel = nil
                end
                if notif.onDismiss then
                    pcall(notif.onDismiss, notif)
                end
            end
        end

        -- Update panel position
        if notif.panel then
            notif.panel:setX(toastX)
            notif.panel:setY(notif.currentY)
            notif.notification = notif
        end
    end

    -- Remove completed notifications
    for i = #active, 1, -1 do
        if active[i].state == C.ANIM_STATE_DONE then
            table.remove(active, i)
        end
    end
end

---------------------------------------------------------------
-- Query
---------------------------------------------------------------

--- Get the count of queued + active notifications.
--- @return number
function PN_NotificationManager.getCount()
    return #queue + #active
end

--- Get the count of active (visible) notifications.
--- @return number
function PN_NotificationManager.getActiveCount()
    return #active
end

---------------------------------------------------------------
-- Event hook registration
---------------------------------------------------------------

local function onPreUIDraw()
    PN_NotificationManager.update()
end

local function onGameStart()
    Events.OnPreUIDraw.Add(onPreUIDraw)
end

Events.OnGameStart.Add(onGameStart)
