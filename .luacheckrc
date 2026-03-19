-- luacheck configuration for PhobosNotifications
std = "lua51"
max_line_length = 200

globals = {
    -- PhobosNotifications modules
    "PhobosNotifications",
    "PN_Constants",
    "PN_Sandbox",
    "PN_NotificationManager",
    "PN_NotificationPanel",
    "PN_ChannelRegistry",

    -- PZ engine (writable)
    "Events",
    "ISPanel",
}

read_globals = {
    -- PhobosLib (dependency)
    "PhobosLib",

    -- PZ engine
    "getCore",
    "getGameTime",
    "getSpecificPlayer",
    "getSoundManager",
    "getTextManager",
    "getTexture",
    "getTimestampMs",
    "ScriptManager",
    "UIFont",
    "UIManager",

    -- PZ UI framework
    "ISButton",
    "ISLabel",
    "ISRichTextPanel",
    "ISCollapsableWindow",

    -- PZ globals
    "sendClientCommand",
    "sendServerCommand",
    "isClient",
    "isServer",
    "SandboxVars",
    "ModData",
    "getActivatedMods",

    -- PZ text
    "getText",
    "getTextOrNull",
}
