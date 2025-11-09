local function printF(message)
    notify.push('Extras', message)
    print(message)
end

local root = menu.root()

-- Heist Utilities start
local bypassMenu = root:submenu('Heist Utilities')

-- Heist Utilities Diamond Heist start

local diamondHeistUtilMenu = bypassMenu:submenu('Diamond Heist')

diamondHeistUtilMenu:button('Reload Table'):event(0, function()
    script.locals(joaat("gb_casino_heist_planning"), 210).int32 = 2
end)

local diamondCrewCut = diamondHeistUtilMenu:button('Set Crew Cut to 1%'):event(0, function()
    script.tunables(joaat("CH_LESTER_CUT")).int32 = 1
    script.tunables(joaat("HEIST3_PREPBOARD_GUNMEN_KARL_CUT")).int32 = 1
    script.tunables(joaat("HEIST3_DRIVERS_KARIM_CUT")).int32 = 1
    script.tunables(joaat("HEIST3_HACKERS_AVI_CUT")).int32 = 1
    printF('Diamond Crew Cut set to 1%')
end)

diamondHeistUtilMenu:button('Bypass Fingerprint/Keypad Hack'):event(0, function()
    if script.locals("fm_mission_controller", 54037).int32 == 4 then
        script.locals("fm_mission_controller", 54037).int32 = 5
        printF("Fingerprint hack bypassed.")
    else
        printF("Fingerprint hack is not active.")
    end

    if script.locals("fm_mission_controller", 55103).int32 ~= 4 then
        script.locals("fm_mission_controller", 55103).int32 = 5
        printF("Keypad hack bypassed.")
    else
        printF("Keypad hack is already complete.")
    end
end)
-- Heist Utilities Diamond Heist end

-- Heist Utilities Cayo Perico Heist start

local cayoHeistUtilMenu = bypassMenu:submenu('Cayo Perico Heist')

cayoHeistUtilMenu:button("Bypass Fingerprint Hack"):event(0, function()
    script.locals(joaat("fm_mission_controller_2020"), 25460).int32 = 5
    printF("Cayo Perico Fingerprint hack bypassed.")
end)

cayoHeistUtilMenu:button("Reload Table"):event(0, function()
    script.locals(joaat("heist_island_planning"), 1568).int32 = 2
end)

-- Bag size options: Small (1), Medium (2), Large (3), Maximum (4)
local cayoBagSizeOptions = {{'1x', 1}, {'2x', 2}, {'3x', 3}, {'4x', 4}}
local cayoBagSize = cayoHeistUtilMenu:combo_int('Set Bag Size', cayoBagSizeOptions, 0)

cayoHeistUtilMenu:button("Apply Bag Size"):event(0, function()
    local size = 1800 * cayoBagSize.value
    script.tunables(joaat("HEIST_BAG_MAX_CAPACITY")).int32 = size
    printF("Cayo Perico Bag Size set to " .. size)
end)

-- Heist Utilities Cayo Perico Heist end

-- Heist Utilities end

-- Cut Editor start
local missionCutOptions = {{'APARTMENT', 0}, {'DIAMOND', 1}, {'DOOMSDAY', 2}, {'CAYO', 3}}

local missionCutEditor = root:submenu('Edit Cuts')
local missionCutSel = missionCutEditor:combo_int('Select Mission', missionCutOptions, 0)

local cutsMenu = missionCutEditor:submenu('Cuts')

local missionList = {}
for i = 0, 300, 5 do
    table.insert(missionList, {i .. '%', i})
end

local cut_player1 = cutsMenu:combo_int('Player 1 Cut', missionList, 0)
local cut_player2 = cutsMenu:combo_int('Player 2 Cut', missionList, 0)
local cut_player3 = cutsMenu:combo_int('Player 3 Cut', missionList, 0)
local cut_player4 = cutsMenu:combo_int('Player 4 Cut', missionList, 0)

local function selected_cut_value(combo)
    return missionList[combo.value][2]
end

local function editCuts(heist_type)
    local cuts = {selected_cut_value(cut_player1), selected_cut_value(cut_player2), selected_cut_value(cut_player3),
                  selected_cut_value(cut_player4)}

    local base_values = {
        CAYO = 1975799 + 831 + 56,
        DOOMSDAY = 1964170 + 812 + 50,
        DIAMOND = 1968996 + 1497 + 736 + 92,
        APARTMENT = 1933768 + 3008
    }

    local base = base_values[heist_type]
    if not base then
        printF('Invalid heist type')
        return
    end

    for i, cut in ipairs(cuts) do
        script.globals(base + i).int32 = cut
    end

    printF(string.format('[%s] Cuts set successfully!', heist_type))
end

missionCutEditor:button('Modify Cuts'):event(0, function()
    util.create_thread(function(thread)
        editCuts(missionCutOptions[missionCutSel.value][1])
        thread:remove()
    end)
end)
-- Cut Editor end

-- Instant Finish start
local missionInstantOptions = {{'APARTMENT', 0}, {'DIAMOND', 1}, {'DOOMSDAY', 2}, {'CAYO', 3}, {'AUTOSHOP', 4},
                               {'AGENCY', 5}}

local instantFinishMenu = root:submenu('Instant Finish')
local missionInstantSel = instantFinishMenu:combo_int('Select Mission', missionInstantOptions, 0)

local function finish(heist_type)
    -- This isn't working for some reason
    -- if not (script.is_running('fm_mission_controller') or script.is_running('fm_mission_controller_2020')) then
    --   printF('You are not in a mission!')
    -- return
    -- end

    if heist_type == 'APARTMENT' then
        local heist = account.stats('HEIST_MISSION_RCONT_ID_1').string
        if heist == 'zCxFg29teE2ReKGnr0L4Bg' then -- PacificJob
            script.locals("fm_mission_controller", 20391 + 1062).int32 = 5 -- 2
            script.locals("fm_mission_controller", 20391 + 1740 + 1).int32 = 80 -- 3
            script.locals("fm_mission_controller", 20391 + 2686).int32 = 10000000 -- 4
            script.locals("fm_mission_controller", 29011 + 1).int32 = 99999 -- 5
            script.locals("fm_mission_controller", 32467 + 1 + 68).int32 = 99999 -- 6
        else
            script.locals("fm_mission_controller", 20391).int32 = 12 -- 1
            script.locals("fm_mission_controller", 20391 + 2686).int32 = 99999 -- 4
            script.locals("fm_mission_controller", 29011 + 1).int32 = 99999 -- 5
            script.locals("fm_mission_controller", 32467 + 1 + 68).int32 = 99999 -- 6
        end
    elseif heist_type == 'DIAMOND' then
        local approach = account.stats('H3OPT_APPROACH').int32
        if approach == 3 then
            script.locals("fm_mission_controller", 20391).int32 = 12 -- 1
            script.locals("fm_mission_controller", 20391 + 1740 + 1).int32 = 80 -- 3
            script.locals("fm_mission_controller", 20391 + 2686).int32 = 10000000 -- 4
            script.locals("fm_mission_controller", 29011 + 1).int32 = 99999 -- 5
            script.locals("fm_mission_controller", 32467 + 1 + 68).int32 = 99999 -- 6
        else
            script.locals("fm_mission_controller", 20391 + 1062).int32 = 5 -- 2
            script.locals("fm_mission_controller", 20391 + 1740 + 1).int32 = 80 -- 3
            script.locals("fm_mission_controller", 20391 + 2686).int32 = 10000000 -- 4
            script.locals("fm_mission_controller", 29011 + 1).int32 = 99999 -- 5
            script.locals("fm_mission_controller", 32467 + 1 + 68).int32 = 99999 -- 6
        end
    elseif heist_type == 'DOOMSDAY' then
        script.locals("fm_mission_controller", 20391).int32 = 12 -- 1
        script.locals("fm_mission_controller", 20391 + 1740 + 1).int32 = 150 -- 2
        script.locals("fm_mission_controller", 29011 + 1).int32 = 99999 -- 3
        script.locals("fm_mission_controller", 32467 + 1 + 68).int32 = 99999 -- 4
        script.locals("fm_mission_controller", 32467 + 97).int32 = 80 -- 5
    elseif heist_type == 'CAYO' then
        script.locals("fm_mission_controller_2020", 54763).int32 = 9 -- 1
        script.locals("fm_mission_controller_2020", 54763 + 1776 + 1).int32 = 50 -- 2
    elseif heist_type == 'AUTOSHOP' then
        script.locals("fm_mission_controller_2020", 54763 + 1).int32 = 51338977 -- 1
        script.locals("fm_mission_controller_2020", 54763 + 1776 + 1).int32 = 101 -- 2
    elseif heist_type == 'AGENCY' then
        script.locals("fm_mission_controller_2020", 54763 + 1).int32 = 51338752 -- 1
        script.locals("fm_mission_controller_2020", 54763 + 1776 + 1).int32 = 50 -- 2
    end

    printF(string.format('[%s] Instant Finished!', heist_type))
end

instantFinishMenu:button('Finish'):event(0, function()
    util.create_thread(function(thread)
        finish(missionInstantOptions[missionInstantSel.value][1])
        thread:remove()
    end)
end)
-- Instant Finish end
