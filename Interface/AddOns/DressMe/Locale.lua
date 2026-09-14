local addon, ns = ...

local locales = {}

locales.en = {
    TABS_PREVIEW = "Items Preview",
    TABS_APPEARANCES = "Appearances",
    TABS_SETTINGS = "Settings",
    RESET = "Reset",
    UNDRESS = "Undress",
    USE_TARGET = "Use Target",
    USE_TARGET_TIP1 = "Use target player's model.",
    USE_TARGET_TIP2 = "The target must be in range of inspection.",
    ROOM_TIP = "|cff00ff00Left Mouse:|r rotate  |cff00ff00Right Mouse:|r pan|n|cff00ff00Wheel:|r zoom",
    SAVE = "Save",
    SAVE_AS = "Save As...",
    REMOVE = "Remove",
    TRY_ON = "Try on",
    TRY_ON_TIP1 = "Try On",
    TRY_ON_TIP2 = "Can be not immediate if there are items in the chosen look that must be queried and cached.",
    SLOT_TIP_SHIFT = "|n|cff00ff00Shift + Left Click:|r create a hyperlink for the item.",
    SLOT_TIP_RIGHT = "|cff00ff00Right Click:|r undress the slot.",
    SLOT_TIP_CTRL = "|cff00ff00Ctrl + Left Click:|r create a Wowhead URL for the item.",
    USED_MODELS = "Used models:",
    USED_MODELS_TIP1 = "Used models",
    USED_MODELS_TIP2 = "There's a fanmade modification for WotLK client that brings modern high quality character models from \"Warlords of Draenor\" expansion. Unfortunately, preview for the modern models has different setup. If your game client's using the modern models, choose \"modern\" in this popup menu and \"classic\" otherwise.",
    BG_COLOR = "Character background color:",
    RESET_COLOR = "Reset Color",
    SHOW_DRESSME_BTN = "Show \"DressMe\" button:",
    SHOW_DRESSME_TIP1 = "Show \"DressMe\" button",
    SHOW_DRESSME_TIP2 = "Show or hide \"DressMe\" button in the character window.",
    SHOW_DRESSME_TIP3 = "The addon can still be accessed via \"/dressme\" chat command.",
    LANGUAGE = "Language:",
    LANGUAGE_TIP = "Interface language (English / Español).",
    CREDITS = "|cff888888Original:|r |cffffffffGetLocalPlayer|r\n|cff6666ccgithub.com/GetLocalPlayer/DressMe|r\n|cff888888Modified by:|r |cffffffffLleguito|r\n|cff6666ccgithub.com/LleguitoWoW|r",
    BY_AUTHOR = "|cff888888By Lleguito|r",
    TITLE_MAIN = "DressMe AzerothCore By Lleguito",
    TITLE_SUB = "",
    MINIMAP_TITLE = "DressMe AzerothCore",
    MINIMAP_AUTHOR = "Original: GetLocalPlayer",
    MINIMAP_MODIFIED = "Modified by Lleguito",
    MINIMAP_GITHUB_MOD = "github.com/LleguitoWoW",
    MINIMAP_CLICK = "Click: open / close wardrobe",
    MINIMAP_DRAG = "Drag: move around minimap",
    MINIMAP_REQ = "Requires unlocked appearances (private server)",
    CHAT_UPDATED = "|cff00ff00[DressMe]|r Unlocked appearances list updated: |cffffffff%d|r items loaded.",
    CHAT_EMPTY = "|cff00ff00[DressMe]|r No unlocked list (showing all appearances).",
    LANG_EN = "English",
    LANG_ES = "Español",
    PROGRESS_FMT = "%d / %d",
    PROGRESS_TIP = "Unlocked / Total appearances",
}

locales.es = {
    TABS_PREVIEW = "Vista previa",
    TABS_APPEARANCES = "Apariencias",
    TABS_SETTINGS = "Ajustes",
    RESET = "Reiniciar",
    UNDRESS = "Desvestir",
    USE_TARGET = "Usar objetivo",
    USE_TARGET_TIP1 = "Usar el modelo del jugador objetivo.",
    USE_TARGET_TIP2 = "El objetivo debe estar a distancia de inspeccion.",
    ROOM_TIP = "|cff00ff00Clic izquierdo:|r rotar  |cff00ff00Clic derecho:|r mover|n|cff00ff00Rueda:|r zoom",
    SAVE = "Guardar",
    SAVE_AS = "Guardar como...",
    REMOVE = "Eliminar",
    TRY_ON = "Probar",
    TRY_ON_TIP1 = "Probar",
    TRY_ON_TIP2 = "Puede no ser inmediato si hay objetos del look que deben consultarse y cachearse.",
    SLOT_TIP_SHIFT = "|n|cff00ff00Shift + Clic izquierdo:|r crear un enlace del objeto.",
    SLOT_TIP_RIGHT = "|cff00ff00Clic derecho:|r quitar el hueco.",
    SLOT_TIP_CTRL = "|cff00ff00Ctrl + Clic izquierdo:|r crear URL de Wowhead del objeto.",
    USED_MODELS = "Modelos usados:",
    USED_MODELS_TIP1 = "Modelos usados",
    USED_MODELS_TIP2 = "Hay una modificacion fan del cliente WotLK con modelos modernos de Warlords of Draenor. La vista previa de esos modelos requiere otra configuracion. Si usas modelos modernos, elige \"modern\"; si no, \"classic\".",
    BG_COLOR = "Color de fondo del personaje:",
    RESET_COLOR = "Restablecer color",
    SHOW_DRESSME_BTN = "Mostrar boton \"DressMe\":",
    SHOW_DRESSME_TIP1 = "Mostrar boton \"DressMe\"",
    SHOW_DRESSME_TIP2 = "Mostrar u ocultar el boton \"DressMe\" en la ventana del personaje.",
    SHOW_DRESSME_TIP3 = "El addon sigue accesible con el comando \"/dressme\".",
    LANGUAGE = "Idioma:",
    LANGUAGE_TIP = "Idioma de la interfaz (English / Español).",
    CREDITS = "|cff888888Original:|r |cffffffffGetLocalPlayer|r\n|cff6666ccgithub.com/GetLocalPlayer/DressMe|r\n|cff888888Modificado por:|r |cffffffffLleguito|r\n|cff6666ccgithub.com/LleguitoWoW|r",
    BY_AUTHOR = "|cff888888By Lleguito|r",
    TITLE_MAIN = "DressMe AzerothCore By Lleguito",
    TITLE_SUB = "",
    MINIMAP_TITLE = "DressMe AzerothCore",
    MINIMAP_AUTHOR = "Original: GetLocalPlayer",
    MINIMAP_MODIFIED = "Modificado por Lleguito",
    MINIMAP_GITHUB_MOD = "github.com/LleguitoWoW",
    MINIMAP_CLICK = "Clic: abrir / cerrar el vestidor",
    MINIMAP_DRAG = "Arrastrar: mover alrededor del minimapa",
    MINIMAP_REQ = "Requiere apariencias desbloqueadas (servidor privado)",
    CHAT_UPDATED = "|cff00ff00[DressMe]|r Lista de apariencias actualizada: |cffffffff%d|r items desbloqueados enviados al addon.",
    CHAT_EMPTY = "|cff00ff00[DressMe]|r Sin lista de desbloqueados (se muestran todas las apariencias).",
    LANG_EN = "English",
    LANG_ES = "Español",
    PROGRESS_FMT = "%d / %d",
    PROGRESS_TIP = "Desbloqueadas / Total apariencias",
}

local function build(code)
    local base = locales.en
    local t = locales[code] or base
    local out = {}
    for k, v in pairs(base) do
        out[k] = t[k] or v
    end
    return out
end

ns.locale = "en"
ns.L = build("en")

function ns.SetLocale(code)
    if code ~= "es" then code = "en" end
    ns.locale = code
    ns.L = build(code)
    if type(ns.ApplyLocale) == "function" then
        ns.ApplyLocale()
    end
end

function ns.GetLocale()
    return ns.locale or "en"
end
