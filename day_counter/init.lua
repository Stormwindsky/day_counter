--[[
    Day Counter Mod for Luanti (Minetest)
    Author: Stormwindsky
    License: MIT-0
]]--

day_counter = {}

-- Load translation system
local S = minetest.get_translator("day_counter")

-- Load global settings
local unlimited_default = minetest.settings:get_bool("day_counter_unlimited", true)
local max_days_default = tonumber(minetest.settings:get("day_counter_max_days")) or 100

-- Function to create or recreate a player's HUD
local function setup_player_hud(player)
    -- Remove any residual old HUD to prevent duplicates
    local old_hud_id = player:get_meta():get_int("day_counter_hud_id")
    if old_hud_id ~= 0 then
        player:hud_remove(old_hud_id)
    end

    -- Create the new HUD element
    local new_id = player:hud_add({
        hud_elem_type = "text",
        position = {x = 0.01, y = 0.01}, -- Top left corner
        offset = {x = 0, y = 0},
        text = S("Day") .. ": 1",
        alignment = {x = 1, y = 1},
        scale = {x = 100, y = 100},
        number = 0xFFFFFF, -- White color
    })
    
    player:get_meta():set_int("day_counter_hud_id", new_id)
end

-- Initialize or create the HUD when a player joins
minetest.register_on_joinplayer(function(player)
    setup_player_hud(player)
end)

-- Clear the meta when a player leaves
minetest.register_on_leaveplayer(function(player)
    player:get_meta():set_int("day_counter_hud_id", 0)
end)

-- Global step to update the counter periodically
minetest.register_globalstep(function(dtime)
    local player_list = minetest.get_connected_players()
    if #player_list == 0 then return end

    local total_time = minetest.get_gametime()
    local current_day = math.floor(total_time / 86400) + 1

    for _, player in ipairs(player_list) do
        local is_unlimited = unlimited_default
        local max_days = max_days_default

        local display_days = current_day
        if not is_unlimited and current_day > max_days then
            display_days = max_days
        end

        local day_text = ""
        if display_days >= 1000000 then
            day_text = "1M+"
        else
            day_text = tostring(display_days)
        end

        local hud_string = string.format("%s: %s", S("Day"), day_text)
        local hud_id = player:get_meta():get_int("day_counter_hud_id")
        
        if hud_id == 0 then
            setup_player_hud(player)
        else
            player:hud_change(hud_id, "text", hud_string)
        end
    end
end)
