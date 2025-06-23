-- Games/BloxFruits.luau

return function(fetcher, ...)

    -- Load modules
    local GuideModule = fetcher.load("{Utils}BloxFruits/GameModules/GuideModule.lua")()
    local Quests = fetcher.load("{Utils}BloxFruits/GameModules/Quests.lua")()

    print("[BloxFruits] GuideModule and Quests loaded successfully.")

    -- Store player's current quest and progress
    local PlayerData = {
        CurrentQuestKey = nil,
        CurrentQuestIndex = nil,
        KillCounts = {},
    }

    -- Helper to get NPC name for a quest key (e.g., "SkyQuest")
    local function GetNPCNameForQuestKey(questKey)
        -- The GuideModule.Data.NPCs table uses quest keys as keys, or you can adjust accordingly
        return GuideModule.Data.NPCs[questKey] or "Unknown NPC"
    end

    -- Get all available quests for a player level, filtered by quest key
    local function GetAvailableQuests(questKey, playerLevel)
        local questList = Quests[questKey]
        if not questList then
            print("[BloxFruits] No quests found for key:", questKey)
            return {}
        end

        local available = {}
        for i, quest in ipairs(questList) do
            if playerLevel >= quest.LevelReq then
                table.insert(available, {index = i, data = quest})
            end
        end

        return available
    end

    -- Assign a quest to player given a quest key and index
    local function AssignQuest(questKey, questIndex)
        local questList = Quests[questKey]
        if not questList then
            print("[BloxFruits] Quest key not found:", questKey)
            return false
        end

        local quest = questList[questIndex]
        if not quest then
            print("[BloxFruits] Quest index not found:", questIndex, "for questKey:", questKey)
            return false
        end

        PlayerData.CurrentQuestKey = questKey
        PlayerData.CurrentQuestIndex = questIndex
        PlayerData.KillCounts = {}

        -- Initialize kill counts for all required mobs
        for mobName, count in pairs(quest.Task) do
            PlayerData.KillCounts[mobName] = 0
        end

        print("[BloxFruits] Assigned quest:", quest.Name, "from", GetNPCNameForQuestKey(questKey))
        return true
    end

    -- Increment kill count for a mob if it is part of current quest
    local function RecordKill(mobName)
        if not PlayerData.CurrentQuestKey or not PlayerData.CurrentQuestIndex then
            print("[BloxFruits] No active quest to track kills.")
            return
        end

        local quest = Quests[PlayerData.CurrentQuestKey][PlayerData.CurrentQuestIndex]
        if quest.Task[mobName] then
            PlayerData.KillCounts[mobName] = PlayerData.KillCounts[mobName] + 1
            print("[BloxFruits] Recorded kill for mob:", mobName, "Total:", PlayerData.KillCounts[mobName])

            -- Check if quest is complete after this kill
            if IsQuestComplete() then
                print("[BloxFruits] Quest complete:", quest.Name)
                -- Call reward function or other completion logic
                RewardPlayer()
                -- Reset quest after completion
                ResetQuest()
            end
        end
    end

    -- Check if the current quest is complete based on kill counts
    function IsQuestComplete()
        if not PlayerData.CurrentQuestKey or not PlayerData.CurrentQuestIndex then
            return false
        end

        local quest = Quests[PlayerData.CurrentQuestKey][PlayerData.CurrentQuestIndex]

        for mobName, requiredCount in pairs(quest.Task) do
            if PlayerData.KillCounts[mobName] < requiredCount then
                return false
            end
        end

        return true
    end

    -- Reset quest progress
    function ResetQuest()
        PlayerData.CurrentQuestKey = nil
        PlayerData.CurrentQuestIndex = nil
        PlayerData.KillCounts = {}
        print("[BloxFruits] Quest reset.")
    end

    -- Reward the player upon quest completion (customize as needed)
    function RewardPlayer()
        local quest = Quests[PlayerData.CurrentQuestKey][PlayerData.CurrentQuestIndex]
        print("[BloxFruits] Rewarding player for completing quest:", quest.Name)
        -- Example reward logic here, e.g., give EXP, items, or money
        -- This depends on your game/bot implementation
    end

    -- Example function to print current quest progress
    local function PrintQuestProgress()
        if not PlayerData.CurrentQuestKey or not PlayerData.CurrentQuestIndex then
            print("[BloxFruits] No active quest.")
            return
        end

        local quest = Quests[PlayerData.CurrentQuestKey][PlayerData.CurrentQuestIndex]
        print("[BloxFruits] Quest progress for:", quest.Name)
        for mobName, requiredCount in pairs(quest.Task) do
            local current = PlayerData.KillCounts[mobName] or 0
            print(string.format(" - %s: %d/%d", mobName, current, requiredCount))
        end
    end

    -- Example: automatically assign first available quest in a category for a player level
    local playerLevel = 150 -- Replace with actual player level logic

    local questKey = "SkyQuest"
    local availableQuests = GetAvailableQuests(questKey, playerLevel)

    if #availableQuests > 0 then
        local firstQuest = availableQuests[1]
        AssignQuest(questKey, firstQuest.index)
    else
        print("[BloxFruits] No available quests for player level:", playerLevel)
    end

    -- Simulated kills for testing
    -- In your bot, you would hook into mob kill events and call RecordKill(mobName)
    RecordKill("Sky Bandit")
    RecordKill("Sky Bandit")
    RecordKill("Sky Bandit")
    RecordKill("Sky Bandit")
    RecordKill("Sky Bandit")
    RecordKill("Sky Bandit")
    RecordKill("Sky Bandit") -- 7 kills should complete "Sky Bandit" quest

    PrintQuestProgress()

    -- Your main bot/game logic should continue from here, handling quests dynamically
end
