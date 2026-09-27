local fallback = {}

function fallback.initialize()
    local env = getgenv()
    local default_font = Font.fromEnum(Enum.Font.Gotham)

    env.lexend = env.lexend or {
        regular = default_font,
        medium = default_font,
        bold = default_font,
    }
    lexend = env.lexend

    env.aztup = env.aztup or {}
    env.aztup.silent_mode = false
    env.aztup.flags = env.aztup.flags or {}
    env.aztup.features = env.aztup.features or {}
    env.aztup.tabs = env.aztup.tabs or {}
    env.aztup.farms = env.aztup.farms or {}
    aztup = env.aztup

    env.aztup_toggles = env.aztup_toggles or {}
    env.aztup_options = env.aztup_options or {}
    aztup_toggles = env.aztup_toggles
    aztup_options = env.aztup_options

    local signal = require("@src/utility/signal")
    env.signal = signal
    env.loaded_signal = signal.new()
    loaded_signal = env.loaded_signal

    local Library = require("@src/utility/librarys/ui")
    env.Library = Library

    local window = Library:CreateWindow({
        Title = string.format("pr <font color=\"#%s\">nextgen</font> | Universal", Library.AccentColor:ToHex()),
        Center = true,
        AutoShow = true,
        MenuFadeTime = 0,
        TabPadding = 0,
        Size = UDim2.fromOffset(760, 560),
    })
    Library.PRWindow = window
    aztup.ui = Library

    local settings_tab = window:AddTab("Settings")
    local settings_group = settings_tab:AddLeftGroupbox("Interface")
    settings_group:AddLabel("Menu keybind"):AddKeyPicker("MenuKeybind", {
        Default = "RightAlt",
        NoUI = true,
        Text = "Menu keybind",
    })
    Library.ToggleKeybind = aztup_options.MenuKeybind

    settings_group:AddSlider("Universal_UIScale", {
        Text = "UI scale",
        Default = 100,
        Min = 70,
        Max = 130,
        Rounding = 0,
        Suffix = "%",
        Callback = function(value)
            Library:SetUIScale(value / 100)
        end,
    })

    local settings_ready, settings_error = pcall(function()
        local SaveManager = require("@src/utility/librarys/managers/SaveManager")
        local ThemeManager = require("@src/utility/librarys/managers/ThemeManager")

        SaveManager:SetLibrary(Library)
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreIndexes({ "Universal_UIScale" })
        SaveManager:SetFolder("Project Rain/Universal-Config")
        ThemeManager:SetLibrary(Library)
        ThemeManager:SetFolder("Project Rain/Universal-Config")
        SaveManager:BuildConfigSection(settings_tab)
        ThemeManager:ApplyToTab(settings_tab)
    end)

    if not settings_ready then
        warn("[Project Rain universal] standard config controls unavailable: " .. tostring(settings_error))
    end

    local universal_tab = window:AddTab("Universal")
    local placeholder_group = universal_tab:AddLeftGroupbox("Placeholder settings")
    placeholder_group:AddToggle("Universal_Placeholder_1", {
        Text = "Placeholder setting 1",
        Default = false,
        Tooltip = "Placeholder only. Does not change game behavior.",
        Callback = function() end,
    })
    placeholder_group:AddToggle("Universal_Placeholder_2", {
        Text = "Placeholder setting 2",
        Default = false,
        Tooltip = "Placeholder only. Does not change game behavior.",
        Callback = function() end,
    })

    loaded_signal:fire()
    return true
end

return fallback
