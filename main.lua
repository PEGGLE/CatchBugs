local lp = game:GetService("Players").LocalPlayer
local mouse = lp:GetMouse()

local auto_catching_enabled = false

local function check_frame_visible(frame)
    if not frame then return end
    local result = memory_read("byte", frame.Address + 0x5B5)
    return result
end

local function click_on_max_luck()
    local player_gui = lp:FindFirstChild("PlayerGui")
    if not player_gui then return end
    local ui = player_gui:FindFirstChild("UI")
    if not ui then return end
    local casting_frame = ui:FindFirstChild("CastingFrame")
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
    local ui = player_gui:FindFirstChild("UI")
    if not ui then return end
    local slider_minigame = ui:FindFirstChild("SliderMinigame")
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
    local ui = player_gui:FindFirstChild("UI")
    if not ui then return end
    local ground_reel_frame = ui:FindFirstChild("GroundReelFrame")
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
    local ui = player_gui:FindFirstChild("UI")
    if not ui then return end

    local casting_frame = ui:FindFirstChild("CastingFrame")
    local ground_reel_frame = ui:FindFirstChild("GroundReelFrame")
    local slider_minigame = ui:FindFirstChild("SliderMinigame")

    local any_active = (
        (casting_frame and check_frame_visible(casting_frame) == 1) or
        (ground_reel_frame and check_frame_visible(ground_reel_frame) == 1) or
        (slider_minigame and check_frame_visible(slider_minigame) == 1)
    )

    if not any_active then
        mouse1press()
    end
end

task.spawn(function()
    while true do
        if not isrbxactive() then break end
        if iskeypressed(0x46) then
            auto_catching_enabled = not auto_catching_enabled
            task.wait(0.3)
        end
        task.wait()
    end
end)

task.spawn(function()
    while true do
        if not isrbxactive() then continue end
        if auto_catching_enabled then
            check_for_idle()
            click_on_max_luck()
            play_clicker_minigame()
            play_slider_minigame()
        end
        task.wait()
    end
end)
