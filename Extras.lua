local function printF(message)
    notify.push('Extras', message)
    print(message)
end

local root = menu.root()

-- Cut Editor start
local missionCutOptions = {
    { 'APARTMENT', 0 },
    { 'DIAMOND',   1 },
    { 'DOOMSDAY',  2 },
    { 'CAYO',      3 },
}

local missionCutEditor = root:submenu('Edit Cuts')
local missionCutSel = missionCutEditor:combo_int('Select Mission', missionCutOptions, 0)

local cutsMenus = missionCutEditor:submenu('Cuts')

local missionList = {}
for i = 0, 300, 10 do
    table.insert(missionList, { i .. '%', i })
end

local cut_player1 = cutsMenus:combo_int('Player 1 Cut', missionList, 0)
local cut_player2 = cutsMenus:combo_int('Player 2 Cut', missionList, 0)
local cut_player3 = cutsMenus:combo_int('Player 3 Cut', missionList, 0)
local cut_player4 = cutsMenus:combo_int('Player 4 Cut', missionList, 0)

local function selected_cut_value(combo)
    return missionList[combo.value][2]
end

local function editCuts(heist_type)
    local cuts = {
        selected_cut_value(cut_player1),
        selected_cut_value(cut_player2),
        selected_cut_value(cut_player3),
        selected_cut_value(cut_player4),
    }

    local base_values = {
        CAYO      = 1976686,
        DOOMSDAY  = 1965032,
        DIAMOND   = 1971321,
        APARTMENT = 1931801,
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
local missionInstantOptions = {
    { 'APARTMENT', 0 },
    { 'DIAMOND',   1 },
    { 'DOOMSDAY',  2 },
    { 'CAYO',      3 },
    { 'AUTOSHOP',  4 },
}

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
        if heist == 'zCxFg29teE2ReKGnr0L4Bg' then                                 -- PacificJob
            script.locals("fm_mission_controller", 20391 + 1062).int32 = 5        -- 2
            script.locals("fm_mission_controller", 20391 + 1740 + 1).int32 = 80   -- 3
            script.locals("fm_mission_controller", 20391 + 2686).int32 = 10000000 -- 4
            script.locals("fm_mission_controller", 29011 + 1).int32 = 99999       -- 5
            script.locals("fm_mission_controller", 32467 + 1 + 68).int32 = 99999  -- 6
        else
            script.locals("fm_mission_controller", 20391).int32 = 12              -- 1
            script.locals("fm_mission_controller", 20391 + 2686).int32 = 99999    -- 4
            script.locals("fm_mission_controller", 29011 + 1).int32 = 99999       -- 5
            script.locals("fm_mission_controller", 32467 + 1 + 68).int32 = 99999  -- 6
        end
    elseif heist_type == 'DIAMOND' then
        local approach = account.stats('H3OPT_APPROACH').int32
        if approach == 3 then
            script.locals("fm_mission_controller", 20391).int32 = 12              -- 1
            script.locals("fm_mission_controller", 20391 + 1740 + 1).int32 = 80   -- 3
            script.locals("fm_mission_controller", 20391 + 2686).int32 = 10000000 -- 4
            script.locals("fm_mission_controller", 29011 + 1).int32 = 99999       -- 5
            script.locals("fm_mission_controller", 32536).int32 = 99999           -- 6
        else
            script.locals("fm_mission_controller", 20391 + 1062).int32 = 5        -- 2
            script.locals("fm_mission_controller", 20391 + 1740 + 1).int32 = 80   -- 3
            script.locals("fm_mission_controller", 20391 + 2686).int32 = 10000000 -- 4
            script.locals("fm_mission_controller", 29011 + 1).int32 = 99999       -- 5
            script.locals("fm_mission_controller", 32467 + 1 + 68).int32 = 99999  -- 6
        end
    elseif heist_type == 'DOOMSDAY' then
        script.locals("fm_mission_controller", 20391).int32 = 12                  -- 1
        script.locals("fm_mission_controller", 20391 + 1740 + 1).int32 = 150      -- 2
        script.locals("fm_mission_controller", 29011 + 1).int32 = 99999           -- 3
        script.locals("fm_mission_controller", 32467 + 1 + 68).int32 = 99999      -- 4
        script.locals("fm_mission_controller", 32467 + 97).int32 = 80             -- 5
    elseif heist_type == 'CAYO' then
        script.locals("fm_mission_controller_2020", 54763).int32 = 9              -- 1
        script.locals("fm_mission_controller_2020", 54763 + 1776 + 1).int32 = 50  -- 2
    elseif heist_type == 'AUTOSHOP' then
        script.locals("fm_mission_controller_2020", 54763 + 1).int32 = 51338977   -- 1
        script.locals("fm_mission_controller_2020", 54763 + 1776 + 1).int32 = 101 -- 2
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
