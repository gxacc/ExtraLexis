-- Silent Night Heists Manager Lexis Port [SKID] { Credits: https://github.com/SilentSalo/SilentNight | https://github.com/xnightli06x/Silent-Night }
-- Ported by @lrxxh & @piuro with the help of: Derkek, melonarmy122
-- Testers: Derkek, 223, camera, Plex, Nexus
-- TODO: Doomsday, Cayo, Casino EXTRA options, Solo Launch [Apartment is done? - Need to copy over], whatever else is missing.
-- HAVE FUN | VERSION: 1.0
local success, error = pcall(function()
    
    local function log_notify(message)
        notify.push('[Heist Utils]', message, 2000)
        print(message)
    end
    
    local function MPX()
        return "MP" .. account.stats("MPPLY_LAST_MP_CHAR").int32 .. "_"
    end
    
    local function SetBit(value, position)
        return value | (1 << position)
    end
    
    local function SetBits(value, positions)
        for _, position in ipairs(positions) do
            value = SetBit(value, position)
        end
        return value
    end
    
    local function setCuts(heist, cuts)
        local base_values = {
            CAYO = 1975799 + 831 + 56,
            DOOMSDAY = 1964170 + 812 + 50,
            DIAMOND = 1968996 + 1497 + 736 + 92
        }
        
        local base = base_values[heist]
        
        if not base and heist ~= 'APARTMENT' then
            log_notify('Invalid heist type')
            return
        elseif heist == 'APARTMENT' and not base then
            base = 1931800 + 1
            for i, cut in ipairs(cuts) do
                if i == 1 then
                    script.globals(base + i).int32 = 100 - (4 * cut)
                    script.globals(1933768 + 3008 + 1).int32 = cut
                else
                    script.globals(base + i).int32 = cut
                end
            end
        else
            for i, cut in ipairs(cuts) do
                script.globals(base + i).int32 = cut
            end
        end
    end
    
    local function DoomsdayActSetter(progress, status)
        account.stats(MPX() .. "GANGOPS_FLOW_MISSION_PROG").int32 = progress
        account.stats(MPX() .. "GANGOPS_HEIST_STATUS").int32 = status
        account.stats(MPX() .. "GANGOPS_FLOW_NOTIFICATIONS").int32 = 1557
    end
    
    local function DoomsdayReloadTable() -- Doomsday Reload Planning Screen
        script.locals("gb_gang_ops_planning", 209).int32 = 6
    end
    
    local function CasinoReloadTable() -- Diamond Heist Reload Planning Screen
        script.locals("gb_casino_heist_planning", 210).int32 = 2
    end
    
    local function CayoReloadTable() -- Cayo Perico Heist Reload Planning Screen
        script.locals("heist_island_planning", 1568).int32 = 2
    end
    
    local function ApartmentReloadTable() -- Apartment Heists Reload Planning Screen
        script.globals(1931835).int32 = 22
    end
    
    local agencyContracts = {
        {'None',           3},
        {'Nightclub',      4},
        {'Marina',         12},
        {'Nightlife Leak', 28},
        {'Country Club',   60},
        {'Guest List',     123},
        {'High Social Leak', 254},
        {'Davis',          508},
        {'Ballas',         1020},
        {'South Central Leak', 2044},
        {'Studio Time',    2045},
        {"Don't Fuck W. Dre", 4095}
    }
    
    local function agencyCompletePreps(contractIndex)
        account.stats(MPX() .. "FIXER_STORY_BS").int32 = contractIndex
        if contractIndex < 18 then
            account.stats(MPX() .. "FIXER_STORY_STRAND").int32 = 0
        elseif contractIndex < 128 then
            account.stats(MPX() .. "FIXER_STORY_STRAND").int32 = 1
        elseif contractIndex < 2044 then
            account.stats(MPX() .. "FIXER_STORY_STRAND").int32 = 2
        else
            account.stats(MPX() .. "FIXER_STORY_STRAND").int32 = -1
        end
        account.stats(MPX() .. "FIXER_GENERAL_BS").int32 = -1
        account.stats(MPX() .. "FIXER_COMPLETED_BS").int32 = -1
    end
    
    local function agencyInstantFinish()
        script.locals("fm_mission_controller_2020", 54763 + 1).int32 = 51338752
        script.locals("fm_mission_controller_2020", 54763 + 1776 + 1).int32 = 50
        log_notify('[Instant Finish (Agency)] Heist should have been finished.')
    end

    local function agencyApplyPayout(payout)
        script.tunables(joaat("FIXER_FINALE_LEADER_CASH_REWARD")).int32 = payout
        log_notify('Payout should\'ve been applied')
    end

    local cutPercentages = {}
    local agencyPayoutOptions = {}

    for i = 0, 200, 5 do
        table.insert(cutPercentages, {i .. '%', i})
    end

    for payout = 0, 2500000, 100000 do
        table.insert(agencyPayoutOptions, {tostring(payout), payout})
    end

    local Menu = menu.root()
    
    local heist_types = {{'APARTMENT', 0}, {'DIAMOND', 1}, {'DOOMSDAY', 2}, {'CAYO', 3}, {'AUTOSHOP', 4}, {'AGENCY', 5}}
    
    local heistSelector = Menu:combo_int('Select Heist', heist_types, 0)
    
    local function _heistType(heist)
        return heist_types[heistSelector.value][1]
    end
    
    local cutsMenu = Menu:submenu('Player Cut Editor')
    
    local cut_player1 = cutsMenu:combo_int('Player 1 Cut', cutPercentages, 0)
    local cut_player2 = cutsMenu:combo_int('Player 2 Cut', cutPercentages, 0)
    local cut_player3 = cutsMenu:combo_int('Player 3 Cut', cutPercentages, 0)
    local cut_player4 = cutsMenu:combo_int('Player 4 Cut', cutPercentages, 0)
    
    local cutsApplyButton = cutsMenu:button('Apply Cuts'):tooltip(
    'Apply the selected cut percentages to the selected heist.'):event(0, function()
        local success, error = pcall(function()
            local heist = _heistType(heistSelector.value)
            local cuts = function()
                return {cutPercentages[cut_player1.value][2], cutPercentages[cut_player2.value][2],
                cutPercentages[cut_player3.value][2], cutPercentages[cut_player4.value][2]}
            end
            
            setCuts(heist, cuts())
        end)
        
        if not success then
            log_notify('Error applying cuts: ' .. tostring(error))
            return
        end
        
        log_notify(string.format('[%s] Cuts set successfully!', heist))
    end)
    
    local instantFinishMenu = Menu:submenu('Instant Finisher')
    
    instantFinishMenu:button('Old Method'):tooltip(
    'Use the old method to instantly finish heist missions, slower, works for all players, saves the preps.'):event(
    0, function()
        local success, error = pcall(function()
            local heistType = _heistType(heistSelector.value)
            if heistType == 'APARTMENT' then
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
            elseif heistType == 'DIAMOND' then
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
        end)
        if not success then
            log_notify('Error applying instant finish [OLD]: ' .. tostring(error))
            return
        end
        log_notify('Instant finish applied with the old method :)')
    end)
    
    local newInstantFinishMenu = instantFinishMenu:button('New Method'):tooltip(
    'Use the new method to instantly finish heist missions, faster, may not work for all players, does not save the preps.')
    :event(0, function()
        local success, error = pcall(function()
            
            local Finish = {
                Old = {
                    Step1 = {
                        vLocal = 20391 + 1062
                    },
                    Step2 = {
                        vLocal = 20391 + 1232 + 1
                    },
                    Step3 = {
                        vLocal = 20391 + 1
                    }
                },
                New = {
                    Step1 = {
                        vLocal = 54763 + 1589
                    },
                    Step2 = {
                        vLocal = 54763 + 1776 + 1
                    },
                    Step3 = {
                        vLocal = 54763 + 1
                    }
                }
            }
            
            local heistType = _heistType(heistSelector.value)
            local hlist = {'CAYO', 'AUTOSHOP', 'AGENCY'}
            if hlist[heistType] then
                local Script = "fm_mission_controller_2020"
                script.locals(Script, Finish.New.Step1.vLocal).int32 = 5
                script.locals(Script, Finish.New.Step2.vLocal).int32 = 999999
                script.locals(Script, Finish.New.Step3.vLocal).int32 = SetBits(
                script.locals(Script, Finish.New.Step3.vLocal).int32, {9, 16})
            else
                local Script = "fm_mission_controller"
                script.locals(Script, Finish.Old.Step1.vLocal).int32 = 5
                script.locals(Script, Finish.Old.Step2.vLocal).int32 = 999999
                local value = SetBits(script.locals(Script, Finish.Old.Step3.vLocal).int32, {9, 16})
                script.locals(Script, Finish.Old.Step3.vLocal).int32 = value
            end
        end)
        if not success then
            log_notify('Error applying instant finish [NEW]: ' .. tostring(error))
            return
        end
        log_notify('Instant finish applied with the new method :)')
    end)
    
    Menu:button('Reload Planning Table'):tooltip('Reload the planning table for the selected heist.'):event(0,
    function()
        local success, error = pcall(function()
            local heist = _heistType(heistSelector.value)
            
            local heistFunc = {
                APARTMENT = ApartmentReloadTable,
                DIAMOND = CasinoReloadTable,
                DOOMSDAY = DoomsdayReloadTable,
                CAYO = CayoReloadTable
            }
            
            if not heistFunc[heist] then
                log_notify('Reloading planning table is not currently supported for ' .. heist .. '.')
                return
            end
            
            heistFunc[heist]()
        end)
        if not success then
            log_notify('Error reloading planning table: ' .. tostring(error))
            return
        end
        log_notify('Reloaded planning table for ' .. heist .. '...')
    end)
    
    Menu:button('Solo Launch'):tooltip('Heists will be made launchable with less than min ammount of players required')
    :event(0, function()
        local Launch = {
            locals = {
                Step1 = {
                    vLocal = 19992 + 15
                },
                Step2 = {
                    vLocal = 19992 + 34
                }
            },
            globals = {
                Step1 = {
                    global = 4718592 + 3539
                },
                Step2 = {
                    global = 4718592 + 3540
                },
                Step3 = {
                    global = 4718592 + 3542 + 1
                },
                Step4 = {
                    global = 4718592 + 190507 + 1
                }
            }
        }
        
        script.locals("fmmc_launcher", Launch.locals.Step1.vLocal).int32 = 1
        script.globals(794954 + 4 + 1 + (script.locals("fmmc_launcher", Launch.locals.Step2.vLocal).int32 * 95) + 75)
        .int32 = 1
        script.globals(Launch.globals.Step1.global).int32 = 1
        script.globals(Launch.globals.Step2.global).int32 = 1
        script.globals(Launch.globals.Step3.global).int32 = 1
        script.globals(Launch.globals.Step4.global).int32 = 0
    end)
    
    local extraMenu = Menu:submenu('Other Options')
    
    local agencyMenu = extraMenu:submenu('Agency')
    
    local agencyContractCombo = agencyMenu:combo_int('VIP Contract', agencyContracts, 0)
    
    agencyMenu:button('Apply & Complete Preps'):event(0, function()
        local success, error = pcall(function()
            local idx = agencyContractCombo.value
            local entry = agencyContracts[idx]
            if not entry then
                log_notify('[Agency Preps] No contract selected')
                return
            end
            local name = entry[1]
            local contractIndex = entry[2]
            log_notify(string.format('[Agency Preps] Selected contract: %s (index %d)', name, contractIndex))
            agencyCompletePreps(contractIndex)
        end)
        if not success then
            log_notify('[Agency Preps] Error: ' .. tostring(error))
        end
    end)
    
    agencyMenu:button('Instant Finish VIP Contract'):tooltip('Finishes the current Agency mission instantly. Use after you can see the minimap.'):event(0, function()
        local success, error = pcall(function()
            agencyInstantFinish()
        end)
        if not success then
            log_notify('[Instant Finish (Agency)] Error: ' .. tostring(error))
        end
    end)

    local agencyPayoutCombo = agencyMenu:combo_int('Payout', agencyPayoutOptions, 0)

    agencyMenu:button('Max Payout'):tooltip('Maximizes the payout, but does not apply it.'):event(0, function()
        local success, error = pcall(function()
            agencyPayoutCombo.value = #agencyPayoutOptions
            log_notify('Payout should\'ve been maximized. Don\'t forget to apply')
        end)
        if not success then
            log_notify('Error: ' .. tostring(error))
        end
    end)

    agencyMenu:button('Apply Payout'):tooltip('Applies the selected payout. Use after you can see the minimap.'):event(0, function()
        local success, error = pcall(function()
            local idx = agencyPayoutCombo.value
            local entry = agencyPayoutOptions[idx]
            if not entry then
                log_notify(' No payout selected')
                return
            end
            local payout = entry[2]
            agencyApplyPayout(payout)
        end)
        if not success then
            log_notify('Error: ' .. tostring(error))
        end
    end)

    local cayoMenu = extraMenu:submenu('Cayo Perico')
    
    cayoMenu:button("Bypass Fingerprint Hack"):event(0, function()
        script.locals("fm_mission_controller_2020", 25460).int32 = 5
        log_notify("Cayo Perico Fingerprint hack bypassed.")
    end)
    
    local cayoBagSize = cayoMenu:combo_int('Set Bag Size', {{'1x', 1}, {'2x', 2}, {'3x', 3}, {'4x', 4}, {'5x', 5}}, 1)
    
    cayoMenu:button("Apply Bag Size"):event(0, function()
        local size = 1800 * cayoBagSize.value
        script.tunables(joaat("HEIST_BAG_MAX_CAPACITY")).int32 = size
        log_notify("Cayo Perico Bag Size set to " .. size)
    end)
    
    local doomsdayMenu = extraMenu:submenu('Doomsday Heist')
    
    local doomsdayActsMenu = doomsdayMenu:submenu('Doomsday Acts Progress Setter')
    
    doomsdayActsMenu:button("Set Act 1 Complete"):event(0, function()
        DoomsdayActSetter(503, 229383)
    end)
    
    doomsdayActsMenu:button("Set Act 2 Complete"):event(0, function()
        DoomsdayActSetter(240, 229378)
    end)
    
    doomsdayActsMenu:button("Set Act 3 Complete"):event(0, function()
        DoomsdayActSetter(16368, 229380)
    end)
    
    doomsdayMenu:button("Complete Preps"):event(0, function()
        account.stats(MPX() .. "GANGOPS_FM_MISSION_PROG").int32 = -1
        reloadTable()
    end)
    
    doomsdayMenu:button("Reset Preps"):event(0, function()
        DoomsdayActSetter(503, 0)
        reloadTable()
    end)
    
    doomsdayMenu:button("Act 3 Pass Hack"):event(0, function()
        script.locals("fm_mission_controller", 1294 + 135).int32 = 3
    end)
    
    local diamondMenu = extraMenu:submenu('Diamond Heist')
    
    diamondMenu:button('Set Crew Cut to 1%'):event(0, function()
        script.tunables(joaat("CH_LESTER_CUT")).int32 = 1
        script.tunables(joaat("HEIST3_PREPBOARD_GUNMEN_KARL_CUT")).int32 = 1
        script.tunables(joaat("HEIST3_DRIVERS_KARIM_CUT")).int32 = 1
        script.tunables(joaat("HEIST3_HACKERS_AVI_CUT")).int32 = 1
        log_notify('Diamond Crew Cut set to 1%')
    end)
    
    diamondMenu:button('Bypass Fingerprint/Keypad Hack'):event(0, function()
        if script.locals("fm_mission_controller", 54037).int32 == 4 then
            script.locals("fm_mission_controller", 54037).int32 = 5
            log_notify("Fingerprint hack bypassed.")
        else
            log_notify("Fingerprint hack is not active.")
        end
        
        if script.locals("fm_mission_controller", 55103).int32 ~= 4 then
            script.locals("fm_mission_controller", 55103).int32 = 5
            log_notify("Keypad hack bypassed.")
        else
            log_notify("Keypad hack is already complete.")
        end
    end)
    
    local apartmentMenu = extraMenu:submenu('Apartment Heists')
    
    apartmentMenu:button('Unlock All Jobs'):event(0, function()
        account.stats(MPX() .. "HEIST_SAVED_STRAND_0").int32 =
        script.tunables(joaat("ROOT_ID_HASH_THE_FLECCA_JOB")).int32
        account.stats(MPX() .. "HEIST_SAVED_STRAND_0_L").int32 = 5
        account.stats(MPX() .. "HEIST_SAVED_STRAND_1").int32 =
        script.tunables(joaat("ROOT_ID_HASH_THE_PRISON_BREAK")).int32
        account.stats(MPX() .. "HEIST_SAVED_STRAND_1_L").int32 = 5
        account.stats(MPX() .. "HEIST_SAVED_STRAND_2").int32 = script.tunables(
        joaat("ROOT_ID_HASH_THE_HUMANE_LABS_RAID")).int32
        account.stats(MPX() .. "HEIST_SAVED_STRAND_2_L").int32 = 5
        account.stats(MPX() .. "HEIST_SAVED_STRAND_3").int32 =
        script.tunables(joaat("ROOT_ID_HASH_SERIES_A_FUNDING")).int32
        account.stats(MPX() .. "HEIST_SAVED_STRAND_3_L").int32 = 5
        account.stats(MPX() .. "HEIST_SAVED_STRAND_4").int32 = script.tunables(joaat(
        "ROOT_ID_HASH_THE_PACIFIC_STANDARD_JOB")).int32
        account.stats(MPX() .. "HEIST_SAVED_STRAND_4_L").int32 = 5
    end)
    
    apartmentMenu:button("Complete Preps"):event(0, function()
        account.stats(MPX() .. "HEIST_PLANNING_STAGE").int32 = -1
        util.yield(100)
        ApartmentReloadTable()
    end)
    
    apartmentMenu:button("Reset Preps"):event(0, function()
        account.stats(MPX() .. "HEIST_PLANNING_STAGE").int32 = 0
        util.yield(100)
        ApartmentReloadTable()
    end)
    
    apartmentMenu:button('Reset Cooldown'):tooltip("Also allows you to play unvailable heists!"):event(0, function()
        script.globals(1876941 + 1 + (players.me().id * 77) + 76).int32 = -1
    end)
    
    apartmentMenu:button('Set 3mil Payout Cuts (Pacific Standard)'):tooltip(
    "Preset cut, everyone gets $3 Million, Pacific Standard ONLY.\nYou will see 160% cut only for yourself, everyone else will see -540% cut for you but 160% for everyone else.")
        :event(0, function()
            local success, error = pcall(function()
                setCuts('APARTMENT', {160, 160, 160, 160})
            end)
            
            if not success then
                log_notify('Error applying preset cuts: ' .. tostring(error))
                return
            end
            
            log_notify("Set payout cuts for players to $3,000,000 each.")
        end)
        
        log_notify('Heist Utils initialized successfully!')
    end)
    
    if not success then
        notify.push('[Heist Utils]', 'Error initializing Heist Utils: ' .. tostring(error), 5000)
        print('Error initializing Heist Utils: ' .. tostring(error))
        return
    end
    