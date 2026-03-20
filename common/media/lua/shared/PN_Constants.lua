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
-- PN_Constants.lua
-- Centralised named constants for PhobosNotifications.
-- No magic numbers or strings anywhere else.
---------------------------------------------------------------

PN_Constants = {}

---------------------------------------------------------------
-- Version
---------------------------------------------------------------

PN_Constants.VERSION = "0.2.0"

---------------------------------------------------------------
-- Animation
---------------------------------------------------------------

PN_Constants.ANIM_SLIDE_DURATION_MS  = 300
PN_Constants.ANIM_STATE_ENTERING     = "entering"
PN_Constants.ANIM_STATE_VISIBLE      = "visible"
PN_Constants.ANIM_STATE_EXITING      = "exiting"
PN_Constants.ANIM_STATE_DONE         = "done"

---------------------------------------------------------------
-- Toast dimensions and layout
---------------------------------------------------------------

PN_Constants.DEFAULT_TOAST_DURATION  = 5        -- seconds
PN_Constants.MAX_VISIBLE_TOASTS      = 3
PN_Constants.TOAST_WIDTH             = 350      -- pixels
PN_Constants.TOAST_MIN_HEIGHT        = 60       -- pixels (min, grows with content)
PN_Constants.TOAST_MAX_HEIGHT        = 120      -- pixels (max, truncates beyond)
PN_Constants.TOAST_GAP               = 8        -- pixels between toasts
PN_Constants.TOAST_MARGIN_TOP        = 40       -- pixels from top of screen
PN_Constants.TOAST_MARGIN_RIGHT      = 20       -- pixels from right edge
PN_Constants.TOAST_PADDING           = 10       -- inner padding
PN_Constants.TOAST_CORNER_RADIUS     = 6        -- rounded corner radius

---------------------------------------------------------------
-- Toast visual elements
---------------------------------------------------------------

PN_Constants.ACCENT_BAR_WIDTH        = 4        -- colour accent bar on left
PN_Constants.ICON_SIZE               = 32       -- icon width and height
PN_Constants.ICON_MARGIN_RIGHT       = 8        -- space between icon and text
PN_Constants.CLOSE_BUTTON_SIZE       = 16       -- "x" button dimensions
PN_Constants.CLOSE_BUTTON_MARGIN     = 4        -- margin from toast edge
PN_Constants.PROGRESS_BAR_HEIGHT     = 3        -- countdown bar at bottom
PN_Constants.TITLE_FONT_SIZE         = "Medium" -- ISFont size key
PN_Constants.MESSAGE_FONT_SIZE       = "Small"  -- ISFont size key

---------------------------------------------------------------
-- Queue limits
---------------------------------------------------------------

PN_Constants.MAX_QUEUE_SIZE          = 50       -- prevent unbounded growth

---------------------------------------------------------------
-- Colour presets
---------------------------------------------------------------

PN_Constants.COLOUR_PRESET_INFO      = "info"
PN_Constants.COLOUR_PRESET_SUCCESS   = "success"
PN_Constants.COLOUR_PRESET_WARNING   = "warning"
PN_Constants.COLOUR_PRESET_ERROR     = "error"
PN_Constants.COLOUR_PRESET_TUTORIAL  = "tutorial"
PN_Constants.COLOUR_PRESET_CUSTOM    = "custom"

PN_Constants.COLOUR_INFO     = { r = 0.30, g = 0.70, b = 1.00, a = 0.95 }
PN_Constants.COLOUR_SUCCESS  = { r = 0.30, g = 0.85, b = 0.40, a = 0.95 }
PN_Constants.COLOUR_WARNING  = { r = 1.00, g = 0.80, b = 0.20, a = 0.95 }
PN_Constants.COLOUR_ERROR    = { r = 1.00, g = 0.35, b = 0.30, a = 0.95 }
PN_Constants.COLOUR_TUTORIAL = { r = 0.20, g = 0.80, b = 0.75, a = 0.95 }
PN_Constants.COLOUR_DEFAULT  = { r = 0.60, g = 0.60, b = 0.60, a = 0.90 }

PN_Constants.COLOUR_BG       = { r = 0.12, g = 0.12, b = 0.14, a = 0.92 }
PN_Constants.COLOUR_TITLE    = { r = 1.00, g = 1.00, b = 1.00, a = 1.00 }
PN_Constants.COLOUR_MESSAGE  = { r = 0.85, g = 0.85, b = 0.85, a = 1.00 }
PN_Constants.COLOUR_CLOSE    = { r = 0.60, g = 0.60, b = 0.60, a = 0.80 }
PN_Constants.COLOUR_PROGRESS = { r = 1.00, g = 1.00, b = 1.00, a = 0.30 }

---------------------------------------------------------------
-- Priority levels
---------------------------------------------------------------

PN_Constants.PRIORITY_LOW      = "low"
PN_Constants.PRIORITY_NORMAL   = "normal"
PN_Constants.PRIORITY_HIGH     = "high"
PN_Constants.PRIORITY_CRITICAL = "critical"

---------------------------------------------------------------
-- Channel defaults
---------------------------------------------------------------

PN_Constants.CHANNEL_DEFAULT = "default"

---------------------------------------------------------------
-- Toast position presets
---------------------------------------------------------------

PN_Constants.POSITION_TOP_RIGHT     = "TopRight"
PN_Constants.POSITION_TOP_LEFT      = "TopLeft"
PN_Constants.POSITION_BOTTOM_RIGHT  = "BottomRight"
PN_Constants.POSITION_BOTTOM_LEFT   = "BottomLeft"

---------------------------------------------------------------
-- ModData keys
---------------------------------------------------------------

PN_Constants.MD_MUTED_CHANNELS = "PN_MutedChannels"

---------------------------------------------------------------
-- Sandbox defaults (used as fallbacks)
---------------------------------------------------------------

PN_Constants.SANDBOX_DEFAULT_DURATION        = 5
PN_Constants.SANDBOX_DEFAULT_MAX_VISIBLE     = 3
PN_Constants.SANDBOX_DEFAULT_SHOW_PROGRESS   = true
PN_Constants.SANDBOX_DEFAULT_POSITION        = "TopRight"
PN_Constants.SANDBOX_DEFAULT_WIDTH           = 350
PN_Constants.SANDBOX_DEFAULT_ENABLE_SOUNDS   = true
PN_Constants.SANDBOX_DEFAULT_ANIM_SPEED      = 100
