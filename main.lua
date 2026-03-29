local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local lp = Players.LocalPlayer
local mouse = lp:GetMouse()

loadstring(game:HttpGet("https://raw.githubusercontent.com/PEGGLE/PeggleUI/refs/heads/main/PeggleLib.lua"))()

local settings = {
    theme = "slate",
    auto_catch_keybind = 0x46,
    anti_afk_enabled = true,
    anti_afk_interval = 60,
    anti_afk_hold_time = 3,
}

local auto_catching_enabled = false

local teleport_locations = {
    ["Grasslands (Spawn)"] = Vector3.new(152, 8.50, -407),
    ["Forest"] = Vector3.new(20, 4.59, 2),
    ["Caves"] = Vector3.new(343, -31.50, 632),
}

local teleport_names = {}
for name in pairs(teleport_locations) do
    table.insert(teleport_names, name)
end
table.sort(teleport_names)

local selected_teleport = teleport_names[1]

local col = {}
local function apply_theme(name)
    local t = ui.themes[name]
    col.header = t.titlebar
    col.accent = t.accent
    col.border = t.border
    col.text = t.text
end
apply_theme(settings.theme)

local function magnitude(a, b)
    local dx = b.X - a.X
    local dy = b.Y - a.Y
    local dz = b.Z - a.Z
    return math.sqrt(dx*dx + dy*dy + dz*dz)
end

local function check_frame_visible(frame)
    if not frame then return end
    return memory_read("byte", frame.Address + 0x5B5)
end

local function click_on_max_luck()
    local player_gui = lp:FindFirstChild("PlayerGui")
    if not player_gui then return end
    local ui_folder = player_gui:FindFirstChild("UI")
    if not ui_folder then return end
    local casting_frame = ui_folder:FindFirstChild("CastingFrame")
    if not casting_frame then return end
    local luck_count = casting_frame:FindFirstChild("LuckCount")
    if not luck_count then return end
    if check_frame_visible(casting_frame) == 1 and luck_count.Text == "2.0x Luck" then
        mouse1release()
    end
end

local function mouse_click(pos)
    if not pos then return end
    local steps = 10
    local delay = 0.01
    for i = 1, steps do
        local delta_x = (pos.X - mouse.X) / (steps - i + 1)
        local delta_y = (pos.Y - mouse.Y) / (steps - i + 1)
        mousemoverel(delta_x, delta_y)
        task.wait(delay)
    end
    if math.abs(mouse.X - pos.X) > 5 or math.abs(mouse.Y - pos.Y) > 5 then return end
    mouse1click()
end

local function play_slider_minigame()
    local player_gui = lp:FindFirstChild("PlayerGui")
    if not player_gui then return end
    local ui_folder = player_gui:FindFirstChild("UI")
    if not ui_folder then return end
    local slider_minigame = ui_folder:FindFirstChild("SliderMinigame")
    if not slider_minigame then return end
    local slider = slider_minigame:FindFirstChild("SlidingWindow")
    if not slider then return end
    local bug_indicator = slider_minigame:FindFirstChild("BugIndicator")
    if not bug_indicator then return end
    if check_frame_visible(slider_minigame) == 1 then
        local slider_center_x = slider.AbsolutePosition.X + (slider.AbsoluteSize.X / 2)
        local bug_center_x = bug_indicator.AbsolutePosition.X + (bug_indicator.AbsoluteSize.X / 2)
        if bug_center_x < slider_center_x then
            mouse1release()
        elseif bug_center_x > slider_center_x then
            mouse1press()
        end
    end
end

local function play_clicker_minigame()
    local player_gui = lp:FindFirstChild("PlayerGui")
    if not player_gui then return end
    local ui_folder = player_gui:FindFirstChild("UI")
    if not ui_folder then return end
    local ground_reel_frame = ui_folder:FindFirstChild("GroundReelFrame")
    if not ground_reel_frame then return end
    local click_button = ground_reel_frame:FindFirstChild("ClickButton")
    if not click_button then return end
    local button_center = click_button.AbsolutePosition + (click_button.AbsoluteSize / 2)
    if check_frame_visible(ground_reel_frame) == 1 then
        mouse_click(button_center)
    end
end

local function check_for_idle()
    local player_gui = lp:FindFirstChild("PlayerGui")
    if not player_gui then return end
    local ui_folder = player_gui:FindFirstChild("UI")
    if not ui_folder then return end
    local casting_frame = ui_folder:FindFirstChild("CastingFrame")
    local ground_reel_frame = ui_folder:FindFirstChild("GroundReelFrame")
    local slider_minigame = ui_folder:FindFirstChild("SliderMinigame")
    local any_active = (
        (casting_frame and check_frame_visible(casting_frame) == 1) or
        (ground_reel_frame and check_frame_visible(ground_reel_frame) == 1) or
        (slider_minigame and check_frame_visible(slider_minigame) == 1)
    )
    if not any_active then
        mouse1press()
    end
end

local function teleport_to(name)
    local pos = teleport_locations[name]
    if not pos then return end
    local character = lp.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.Position = pos 
    end
end

local win = ui.create_window("main", "Catch Bugs! | PeggleUI", 200, 150, 600, 400)
ui.set_theme(settings.theme, win)

local tab_main = ui.add_tab(win, "main", "Main", "Automation & More")

local sec_automation = ui.add_section(win, tab_main, "Automation", ui.Side.Left)
ui.add_header_text(win, tab_main, sec_automation, "Settings")
ui.add_keybind(win, tab_main, sec_automation, "Auto Catch Key", settings.auto_catch_keybind, function(new_key)
    settings.auto_catch_keybind = new_key
end)

local sec_teleport = ui.add_section(win, tab_main, "Teleport", ui.Side.Left)
ui.add_header_text(win, tab_main, sec_teleport, "Settings")
ui.add_dropdown(win, tab_main, sec_teleport, "Location", teleport_names, 1, function(name)
    selected_teleport = name
end)
ui.add_button(win, tab_main, sec_teleport, "Teleport", function()
    teleport_to(selected_teleport)
end)

local sec_afk = ui.add_section(win, tab_main, "Anti-AFK", ui.Side.Right)
ui.add_header_text(win, tab_main, sec_afk, "Settings")
ui.add_toggle(win, tab_main, sec_afk, "Enabled", true, function(state)
    settings.anti_afk_enabled = state
end)
ui.add_slider(win, tab_main, sec_afk, "Interval (s)", 15, 300, settings.anti_afk_interval, function(value)
    settings.anti_afk_interval = value
end)
ui.add_slider(win, tab_main, sec_afk, "Hold Time (s)", 1, 10, settings.anti_afk_hold_time, function(value)
    settings.anti_afk_hold_time = value
end)

local tab_settings = ui.add_tab(win, "settings", "Settings", "Keybinds & appearance")
local sec_keybinds = ui.add_section(win, tab_settings, "Keybinds", ui.Side.Left)
local sec_appearance = ui.add_section(win, tab_settings, "Appearance", ui.Side.Right)
ui.add_keybind(win, tab_settings, sec_keybinds, "Menu Toggle", 0x72, function()
    ui.set_window_visible(win, not win.visible)
end)
ui.add_dropdown(win, tab_settings, sec_appearance, "Theme", ui.theme_names, 1, function(name)
    settings.theme = name
    apply_theme(name)
    ui.set_theme(name, win)
end)

task.spawn(function()
    while true do
        if isrbxactive() and iskeypressed(settings.auto_catch_keybind) then
            auto_catching_enabled = not auto_catching_enabled
            task.wait(0.3)
        end
        task.wait()
    end
end)

local last_afk_time = os.clock()
local afk_pending = false

task.spawn(function()
    while true do
        if isrbxactive() and auto_catching_enabled then
            if settings.anti_afk_enabled then
                if not afk_pending and os.clock() - last_afk_time >= settings.anti_afk_interval then
                    afk_pending = true
                end
                if afk_pending then
                    local player_gui = lp:FindFirstChild("PlayerGui")
                    local ui_folder = player_gui and player_gui:FindFirstChild("UI")
                    local casting_frame = ui_folder and ui_folder:FindFirstChild("CastingFrame")
                    local ground_reel_frame = ui_folder and ui_folder:FindFirstChild("GroundReelFrame")
                    local slider_minigame = ui_folder and ui_folder:FindFirstChild("SliderMinigame")
                    local any_active = (
                        (casting_frame and check_frame_visible(casting_frame) == 1) or
                        (ground_reel_frame and check_frame_visible(ground_reel_frame) == 1) or
                        (slider_minigame and check_frame_visible(slider_minigame) == 1)
                    )
                    if not any_active then
                        local character = lp.Character
                        local hrp = character and character:FindFirstChild("HumanoidRootPart")
                        local humanoid = character and character:FindFirstChild("Humanoid")
                        if hrp and humanoid and humanoid.Health > 0 then
                            local old_pos = hrp.Position
                            local wasd = { 0x57, 0x41, 0x53, 0x44 }
                            local chosen_key = wasd[math.random(1, #wasd)]
                            keypress(chosen_key)
                            keypress(0x20)
                            task.wait(settings.anti_afk_hold_time)
                            keyrelease(chosen_key)
                            keyrelease(0x20)
                            task.wait(0.2)
                            for _ = 1, 10 do
                                hrp.Position = old_pos
                                task.wait(0.1)
                                if magnitude(hrp.Position, old_pos) <= 1 then break end
                            end
                        end
                        afk_pending = false
                        last_afk_time = os.clock()
                    end
                end
            else
                last_afk_time = os.clock()
                afk_pending = false
            end
            check_for_idle()
            click_on_max_luck()
            play_clicker_minigame()
            play_slider_minigame()
        end
        task.wait()
    end
end)
