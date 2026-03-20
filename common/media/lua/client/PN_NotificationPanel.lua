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
-- PN_NotificationPanel.lua
-- ISPanel subclass for rendering an individual toast notification.
-- Handles background, accent bar, icon, title, message, close
-- button, and progress bar.
---------------------------------------------------------------

require "ISUI/ISPanel"
require "PN_Constants"

PN_NotificationPanel = ISPanel:derive("PN_NotificationPanel")

local C = PN_Constants

---------------------------------------------------------------
-- Colour lookup for presets
---------------------------------------------------------------

local COLOUR_MAP = {
    [C.COLOUR_PRESET_INFO]     = C.COLOUR_INFO,
    [C.COLOUR_PRESET_SUCCESS]  = C.COLOUR_SUCCESS,
    [C.COLOUR_PRESET_WARNING]  = C.COLOUR_WARNING,
    [C.COLOUR_PRESET_ERROR]    = C.COLOUR_ERROR,
    [C.COLOUR_PRESET_TUTORIAL] = C.COLOUR_TUTORIAL,
}

local function resolveAccentColour(notification)
    if notification.colour == C.COLOUR_PRESET_CUSTOM and notification.customColour then
        return notification.customColour
    end
    return COLOUR_MAP[notification.colour] or C.COLOUR_DEFAULT
end

---------------------------------------------------------------
-- Font helpers
---------------------------------------------------------------

local function getTitleFont()
    return UIFont[C.TITLE_FONT_SIZE] or UIFont.Medium
end

local function getMessageFont()
    return UIFont[C.MESSAGE_FONT_SIZE] or UIFont.Small
end

---------------------------------------------------------------
-- Constructor
---------------------------------------------------------------

--- Create a new notification panel.
--- @param x number
--- @param y number
--- @param width number
--- @param notification table The notification data from the queue
--- @return PN_NotificationPanel
function PN_NotificationPanel:new(x, y, width, notification)
    local height = self:calculateHeight(notification, width)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o.notification = notification
    o.accentColour = resolveAccentColour(notification)
    o.hovered = false
    o.closeHovered = false
    o.moveWithMouse = false
    o.backgroundColor = C.COLOUR_BG

    return o
end

--- Calculate toast height based on content.
--- @param notification table
--- @param width number
--- @return number
function PN_NotificationPanel:calculateHeight(notification, _width) -- luacheck: no unused args
    local h = C.TOAST_PADDING * 2

    if notification.title then
        local titleFont = getTitleFont()
        local titleH = getTextManager():MeasureStringY(titleFont, notification.title)
        h = h + titleH + 2
    end

    local msgFont = getMessageFont()
    local lines = getTextManager():MeasureStringY(msgFont, notification.message or "")
    h = h + lines

    h = h + C.PROGRESS_BAR_HEIGHT + 4

    return math.max(C.TOAST_MIN_HEIGHT, math.min(h, C.TOAST_MAX_HEIGHT))
end

---------------------------------------------------------------
-- Rendering
---------------------------------------------------------------

function PN_NotificationPanel:prerender()
    ISPanel.prerender(self)

    local bg = self.backgroundColor
    self:drawRect(0, 0, self.width, self.height,
        bg.a, bg.r, bg.g, bg.b)

    local ac = self.accentColour
    self:drawRect(0, 0, C.ACCENT_BAR_WIDTH, self.height,
        ac.a, ac.r, ac.g, ac.b)
end

function PN_NotificationPanel:render()
    ISPanel.render(self)

    local notif = self.notification
    local textX = C.ACCENT_BAR_WIDTH + C.TOAST_PADDING
    local textY = C.TOAST_PADDING
    local textWidth = self.width - textX - C.TOAST_PADDING - C.CLOSE_BUTTON_SIZE - C.CLOSE_BUTTON_MARGIN

    -- Icon
    if notif.iconTexture then
        self:drawTextureScaled(notif.iconTexture,
            textX, textY, C.ICON_SIZE, C.ICON_SIZE, 1.0)
        textX = textX + C.ICON_SIZE + C.ICON_MARGIN_RIGHT
        textWidth = textWidth - C.ICON_SIZE - C.ICON_MARGIN_RIGHT
    end

    -- Title
    if notif.title then
        local tc = C.COLOUR_TITLE
        local titleFont = getTitleFont()
        local truncTitle = notif.title
        local titleW = getTextManager():MeasureStringX(titleFont, truncTitle)
        if titleW > textWidth then
            while getTextManager():MeasureStringX(titleFont, truncTitle .. "...") > textWidth and #truncTitle > 1 do
                truncTitle = string.sub(truncTitle, 1, #truncTitle - 1)
            end
            truncTitle = truncTitle .. "..."
        end
        self:drawText(truncTitle, textX, textY, tc.r, tc.g, tc.b, tc.a, titleFont)
        textY = textY + getTextManager():MeasureStringY(titleFont, truncTitle) + 2
    end

    -- Message
    if notif.message then
        local mc = C.COLOUR_MESSAGE
        local msgFont = getMessageFont()
        local truncMsg = notif.message
        local msgW = getTextManager():MeasureStringX(msgFont, truncMsg)
        if msgW > textWidth then
            while getTextManager():MeasureStringX(msgFont, truncMsg .. "...") > textWidth and #truncMsg > 1 do
                truncMsg = string.sub(truncMsg, 1, #truncMsg - 1)
            end
            truncMsg = truncMsg .. "..."
        end
        self:drawText(truncMsg, textX, textY, mc.r, mc.g, mc.b, mc.a, msgFont)
    end

    -- Close button
    local closeBtnX = self.width - C.CLOSE_BUTTON_SIZE - C.CLOSE_BUTTON_MARGIN
    local closeBtnY = C.CLOSE_BUTTON_MARGIN
    local cc = self.closeHovered
        and { r = 1.0, g = 1.0, b = 1.0, a = 1.0 }
        or C.COLOUR_CLOSE
    self:drawText("x", closeBtnX + 3, closeBtnY, cc.r, cc.g, cc.b, cc.a, getMessageFont())

    -- Progress bar
    if notif.showProgress and notif.progress then
        local barY = self.height - C.PROGRESS_BAR_HEIGHT
        local barWidth = self.width * math.max(0, math.min(1, notif.progress))
        local ac = self.accentColour
        self:drawRect(0, barY, barWidth, C.PROGRESS_BAR_HEIGHT,
            ac.a * 0.6, ac.r, ac.g, ac.b)
    end
end

---------------------------------------------------------------
-- Input handling
---------------------------------------------------------------

function PN_NotificationPanel:onMouseMove(dx, dy)
    ISPanel.onMouseMove(self, dx, dy)
    self.hovered = true

    local mx = self:getMouseX()
    local my = self:getMouseY()
    local closeBtnX = self.width - C.CLOSE_BUTTON_SIZE - C.CLOSE_BUTTON_MARGIN
    local closeBtnY = C.CLOSE_BUTTON_MARGIN
    self.closeHovered = mx >= closeBtnX and mx <= closeBtnX + C.CLOSE_BUTTON_SIZE
        and my >= closeBtnY and my <= closeBtnY + C.CLOSE_BUTTON_SIZE
end

function PN_NotificationPanel:onMouseMoveOutside(dx, dy)
    ISPanel.onMouseMoveOutside(self, dx, dy)
    self.hovered = false
    self.closeHovered = false
end

function PN_NotificationPanel:onMouseUp(x, y)
    ISPanel.onMouseUp(self, x, y)

    local closeBtnX = self.width - C.CLOSE_BUTTON_SIZE - C.CLOSE_BUTTON_MARGIN
    local closeBtnY = C.CLOSE_BUTTON_MARGIN
    if x >= closeBtnX and x <= closeBtnX + C.CLOSE_BUTTON_SIZE
        and y >= closeBtnY and y <= closeBtnY + C.CLOSE_BUTTON_SIZE then
        if self.onCloseClick then
            self.onCloseClick(self.notification)
        end
        return
    end

    if self.notification.onClick then
        local ok, err = pcall(self.notification.onClick, self.notification)
        if not ok then
            PhobosLib.debug("PN", "[PN:Panel]", "onClick error: " .. tostring(err))
        end
    end
end

function PN_NotificationPanel:isMouseOver()
    if not self:isVisible() then return false end
    local mx = self:getMouseX()
    local my = self:getMouseY()
    return mx >= 0 and mx < self.width and my >= 0 and my < self.height
end
