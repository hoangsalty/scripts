repeat task.wait() until game:IsLoaded() and game.Players and game.CoreGui

game.CoreGui.RobloxPromptGui.promptOverlay.DescendantAdded:Connect(function()
    local GUI = game.CoreGui.RobloxPromptGui.promptOverlay:FindFirstChild('ErrorPrompt')
    if GUI then
        local Reason = GUI.TitleFrame.ErrorTitle.Text
        if Reason == 'Disconnected' or Reason:find('Server Kick') or Reason:find('GameEnded') or Reason:find('Teleport Failed') then
            warn("Kicked Reason: "..Reason)

            game:GetService("TeleportService"):Teleport(2727067538)

            while task.wait(5) do
                game:GetService("TeleportService"):Teleport(2727067538)
            end
        end
    end
end)

--Save Settings
local Name = 'worldzero(ID_'..game.Players.LocalPlayer.UserId..').json'
local DefaultSettings = {
    ['DungeonID'] = 1,
    ['DifficultyID'] = 1,
    ['FarmDailyQuest'] = true,
    ['FarmWorldQuest'] = true,
    ['FarmGuildDungeon'] = true,
    ['RestartDungeon'] = true,
    ['StartFarm'] = false,

    ['KillAura'] = false,
    ['PickUp'] = true,
    ['NoBusy'] = false,

    ['SellTier1'] = true,
    ['SellTier2'] = true,
    ['SellTier3'] = true,
    ['SellTier4'] = true,
    ['SellEgg'] = true,
    ['AutoEquip'] = false,
    ['AutoSell'] = false,
}
if not pcall(function() readfile(Name) end) then writefile(Name, game:GetService('HttpService'):JSONEncode(DefaultSettings)) end
local Settings = game:GetService('HttpService'):JSONDecode(readfile(Name))
function Save() writefile(Name, game:GetService('HttpService'):JSONEncode(Settings)) end

local Lib = loadstring(game:HttpGet('https://raw.githubusercontent.com/hoangsalty/roblox_scripts/main/Materials/UISource/Mercury_Lib.lua'))()
local Window = Lib:Create{
    Name = 'World//Zero',
    Size = UDim2.fromOffset(600, 400),
    Theme = Lib.Themes.Dark,
    Link = 'World//Zero'
}

if game.PlaceId == 2727067538 then
    repeat task.wait() until game.ReplicatedStorage:FindFirstChild('ProfileCollections')
    repeat task.wait() until game.ReplicatedStorage.ProfileCollections:FindFirstChild(game.Players.LocalPlayer.Name)
    
    if Settings['StartFarm'] then
        Window:Prompt{
            Followup = false,
            Title = 'Notification',
            Text = 'Joining the game...',
            Buttons = {
                ['ok'] = function()
                    return true
                end,
            }
        }
        while task.wait(2) do
            game.ReplicatedStorage.Shared.Teleport.JoinGame:FireServer(game.ReplicatedStorage.ProfileCollections[game.Players.LocalPlayer.Name].LastProfile.Value)
        end
    else
        Window:Prompt{
            Followup = false,
            Title = 'Notification',
            Text = 'Please join the game in order to use all function',
            Buttons = {
                ['ok'] = function()
                    return true
                end,
            }
        }
    end
else
    repeat task.wait() until workspace:FindFirstChild('Characters') and workspace.Characters:FindFirstChild(game.Players.LocalPlayer.Name)
    repeat task.wait() until game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild('HumanoidRootPart')

    local Client = game:GetService("Players").LocalPlayer
    local Character = Client.Character or Client.Character:Wait()
    local ClientRoot = Character:WaitForChild('HumanoidRootPart')
    local ClientProfile = game.ReplicatedStorage.Profiles:WaitForChild(Client.Name)
    local ClientLevel = ClientProfile:WaitForChild('Level') and ClientProfile.Level.Value
    local ClientClass = ClientProfile:WaitForChild('Class') and ClientProfile.Class.Value
    local InDungeon = require(game.ReplicatedStorage.Shared.Missions):IsMissionPlace()

    Client.CameraMaxZoomDistance = 500
    Client.CharacterAdded:Connect(function(Character)
        ClientRoot = Character:WaitForChild('HumanoidRootPart')
    end)

    for i,v in next, getconnections(game:GetService("Players").LocalPlayer.Idled) do
        v:Disable()
    end

    workspace.ChildAdded:Connect(function(v)
        if ClientClass == 'Demon' and v:IsA('Part') and v.Name:find('Damage') then
            task.wait()
            v:Destroy()
        end
    end)

    --Semi-god
    local dangerTable = {} do
        for i,v in next, game.ReplicatedStorage.Shared.Mobs.Mobs:GetDescendants() do
            if v:IsA('RemoteEvent') then
                table.insert(dangerTable, v)
            end
        end

        local old_namecall
        old_namecall = hookmetamethod(game, '__namecall', function(self, ...)
            if getnamecallmethod() == 'FireServer' and table.find(dangerTable, self) then
                return
            end

            return old_namecall(self, ...)
        end)
    end

    --Block Inputs
    local old_useskill = require(game.ReplicatedStorage.Client.Actions).UseSkill
    require(game.ReplicatedStorage.Client.Actions).UseSkill = function(self, ...)
        if Settings['KillAura'] then
            return
        end
        
        return old_useskill(self, ...)
    end

    --Fill Attack Tables
    local AtkType = {
        ['Primary'] 	= {},
        ['Skill1'] 		= {},
        ['Skill2'] 		= {},
        ['Skill3'] 		= {},
        ['Ultimate'] 	= {},
    }
    function Refill(class)
        if class == 'Mage' then
            table.insert(AtkType['Primary'], 'Mage1')
            
            table.insert(AtkType['Skill1'], 'ArcaneBlast')
            table.insert(AtkType['Skill1'], 'ArcaneBlastAOE')
        
            for i=1,12 do
                table.insert(AtkType['Skill2'], 'ArcaneWave'..i)
            end
        elseif class == 'Swordmaster' then
            for i=1,6 do
                table.insert(AtkType['Primary'], 'Swordmaster'..i)
            end
        
            for i=1,2 do
                table.insert(AtkType['Skill1'], 'CrescentStrike'..i)
            end
        
            table.insert(AtkType['Skill2'], 'Leap')
        elseif class == 'Defender' then
            for i=1,5 do
                table.insert(AtkType['Primary'], 'Defender'..i)
            end
        
            table.insert(AtkType['Skill1'], 'Groundbreaker')
        
            for i=1,4 do
                table.insert(AtkType['Skill2'], 'Spin'..i)
            end
        elseif class == 'IcefireMage' then
            table.insert(AtkType['Primary'], 'IcefireMage1')
            
            for i=1,5 do
                table.insert(AtkType['Skill1'], 'IcySpikes'..i)
            end
        
            table.insert(AtkType['Skill2'], 'IcefireMageFireballBlast')
            table.insert(AtkType['Skill2'], 'IcefireMageFireball')
        
            table.insert(AtkType['Skill3'], 'LightningStrike')
        
            table.insert(AtkType['Ultimate'], 'IcefireMageUltimateFrost')
            for i=1,10 do
                table.insert(AtkType['Ultimate'], 'IcefireMageUltimateMeteor'..i)
            end
        elseif class == 'DualWielder' then
            for i=1,10 do
                table.insert(AtkType['Primary'], 'DualWield'..i)
            end
        
            table.insert(AtkType['Skill2'], 'DashStrike')
        
            for i=1,4 do
                table.insert(AtkType['Skill3'], 'CrossSlash'..i)
            end
        
            for i=1,12 do
                table.insert(AtkType['Ultimate'], 'DualWieldUltimateSword'..i)
                table.insert(AtkType['Ultimate'], 'DualWieldUltimateHit'..i)
            end
            table.insert(AtkType['Ultimate'], 'DualWieldUltimateSlam')
            for i=1,3 do
                table.insert(AtkType['Ultimate'], 'DualWieldUltimateSlam'..i)
            end
        elseif class == 'Guardian' then
            for i=1,4 do
                table.insert(AtkType['Primary'], 'Guardian'..i)
            end
        
            for i=1,5 do
                table.insert(AtkType['Skill2'], 'RockSpikes'..i)
            end
        
            for i=1,15 do
                table.insert(AtkType['Skill3'], 'SlashFury'..i)
            end
        
            for i=1,12 do
                table.insert(AtkType['Ultimate'], 'SwordPrison'..i)
            end
        elseif class == 'MageOfLight' then
            table.insert(AtkType['Primary'], 'MageOfLight')
            table.insert(AtkType['Primary'], 'MageOfLightBlast')
            table.insert(AtkType['Primary'], 'MageOfLightCharged')
            table.insert(AtkType['Primary'], 'MageOfLightBlastCharged')
        elseif class == 'Berserker' then
            for i=1,6 do
                table.insert(AtkType['Primary'], 'Berserker'..i)
            end
        
            table.insert(AtkType['Skill1'], 'AggroSlam')
        
            for i=1,8 do
                table.insert(AtkType['Skill2'], 'GigaSpin'..i)
            end
        
            for i=1,2 do
                table.insert(AtkType['Skill3'], 'Fissure'..i)
            end
        elseif class == 'Paladin' then  
            for i=1,4 do
                table.insert(AtkType['Primary'], 'Paladin'..i)
                table.insert(AtkType['Primary'], 'LightPaladin'..i)
            end
        
            table.insert(AtkType['Skill1'], 'Block')
        
            for i=1,2 do
                table.insert(AtkType['Skill3'], 'LightThrust'..i)
            end
        elseif class == 'Demon' then
            for i=1,25 do
                table.insert(AtkType['Primary'], 'Demon'..i)
            end
            for i=1,9 do
                table.insert(AtkType['Primary'], 'DemonDPS'..i)
            end
        
            for i=1,3 do
                table.insert(AtkType['Skill2'], 'ScytheThrow'..i)
                table.insert(AtkType['Skill2'], 'ScytheThrowDPS'..i)
            end
        
            table.insert(AtkType['Skill3'], 'DemonLifeStealAOE')
            table.insert(AtkType['Skill3'], 'DemonLifeStealDPS')
        elseif class == 'Dragoon' then
            for i=1,6 do
                table.insert(AtkType['Primary'], 'Dragoon'..i)
            end
        
            table.insert(AtkType['Skill1'], 'DragoonDash')
            for i=1,10 do
                table.insert(AtkType['Skill1'], 'DragoonCross'..i)
            end
        
            for i=1,5 do
                table.insert(AtkType['Skill2'], 'MultiStrike'..i)
            end
        
            table.insert(AtkType['Skill3'], 'DragoonFall')
        
            table.insert(AtkType['Ultimate'], 'DragoonUltimate')
            for i=1,7 do
                table.insert(AtkType['Ultimate'], 'UltimateDragon'..i)
            end
        elseif class == 'Archer' then
            table.insert(AtkType['Primary'], 'Archer')
            
            for i=1,9 do
                table.insert(AtkType['Skill1'], 'PiercingArrow'..i)
            end
        
            table.insert(AtkType['Skill2'], 'SpiritBomb')
        
            for i=1,5 do
                table.insert(AtkType['Skill3'], 'MortarStrike'..i)
            end
        
            for i=1,6 do
                table.insert(AtkType['Ultimate'], 'HeavenlySword'..i)
            end
        elseif class == 'Summoner' then
            for i=1,4 do
                table.insert(AtkType['Primary'], 'Summoner'..i)
            end

            for i=1,5 do
                table.insert(AtkType['Skill3'], 'SoulHarvest'..i)
            end
        elseif class == 'Warlord' then
            for i=1,4 do
                table.insert(AtkType['Primary'], 'Warlord'..i)
            end

            for i=1,3 do
                table.insert(AtkType['Skill1'], 'Piledriver'..i)
            end

            table.insert(AtkType['Skill2'], 'BlockingWarlord')

            table.insert(AtkType['Skill3'], 'ChainsOfWar')

            for i=1,4 do
                table.insert(AtkType['Ultimate'], 'WarlordUltimate'..i)
            end
        end
    end
    while task.wait() do
        Refill(ClientClass)
        if(#AtkType['Primary'] > 0) then break end
    end

    --print(#AtkType['Primary'])

    ClientProfile:WaitForChild('Class').Changed:connect(function(class)
        AtkType['Primary'] = {}
        AtkType['Skill1'] = {}
        AtkType['Skill2'] = {}
        AtkType['Skill3'] = {}
        AtkType['Ultimate'] = {}
        task.wait(0.5)
        Refill(class)

        --print('Class changed to '..class..' | Refill: '..#AtkType['Primary'])
    end)

    function IsAlive(target)
        return target:FindFirstChild('HealthProperties') and target.HealthProperties:FindFirstChild('Health') and target.HealthProperties.Health.Value > 0
    end

    --Clear death mobs
    if workspace:FindFirstChild('Mobs') then
        task.defer(function()
            while task.wait() do
                for i,v in next, workspace.Mobs:GetChildren() do
                    if v:FindFirstChild('Collider') and not IsAlive(v) then
                        v:Destroy()
                    end
                end
            end
        end)
    end

    local blacklist = {
        6510862058,
        4050468028,
        4646473427,
    }
    local bossPos
    if workspace:FindFirstChild('Mobs') then
        workspace.Mobs.ChildAdded:Connect(function(mob)
            if not mob.Name:find('#') and mob:FindFirstChild('Collider') and mob.MobProperties:FindFirstChild('CurrentAttack') then
                if not table.find(blacklist, game.PlaceId) and require(game.ReplicatedStorage.Shared.Mobs.Mobs[mob.Name]).BossTag ~= false then
                    bossPos = mob.Collider.Position.Y
                end
            end
        end)
    end

    --UI
    local AutoFarm = Window:Tab{Name = 'Auto Farm', Icon = 'rbxassetid://8569322835'}
        function GetMissions()
            local ListMissions = {}
            for i,v in next, require(game.ReplicatedStorage.Shared.Missions.MissionData) do
                if v.ShowOnProduction and v.ShowOnProduction == true then
                    if v.ID == 17 then
                        v.NameTag = 'Holiday Event'
                    elseif v.ID == 22 then
                        v.NameTag = 'Halloween Event'
                    end
                    
                    if v.Disabled == nil then
                        table.insert(ListMissions, v)
                    end
                end
            end

            table.sort(ListMissions, function(a,b)
                return a.LevelRequirement < b.LevelRequirement
            end)

            return ListMissions
        end

        function MissionDefValue(ID)
            for i,v in next, GetMissions() do
                if v.ID == ID then
                    return v.NameTag
                end
            end
        end

        function DifficultyList(ID)
            local DiffIDs = {}
            for i,v in next, GetMissions() do
                if v.difficulties and v.ID == ID then
                    for i1,v1 in next, v.difficulties do
                        if v1.id == 1 then
                            DiffIDs[1] = 'Normal'
                        elseif v1.id == 2 then
                            DiffIDs[2] = 'Hard'
                        elseif v1.id == 3 then
                            DiffIDs[3] = 'Challenge'
                        elseif v1.id == 4 then
                            DiffIDs[4] = 'MASTER'
                        elseif v1.id == 5 then
                            DiffIDs[5] = 'NIGHTMARE'
                        end
                    end
                end
            end

            return DiffIDs
        end

        function MissionList()
            local stringtable = {}
            for i,v in next, GetMissions() do
                table.insert(stringtable, v.NameTag)
            end

            return stringtable
        end

        local SelectDifficulty, SelectDungeonAfterMission do
            SelectDungeonAfterMission = AutoFarm:Dropdown{
                Name = 'Dungeons',
                StartingText = tostring(MissionDefValue(Settings['DungeonID'])),
                Description = nil,
                Items = MissionList(),
                Callback = function(item)
                    for i,v in next, GetMissions() do
                        if v.NameTag == item then
                            Settings['DungeonID'] = v.ID
                            Save()
        
                            SelectDifficulty:Clear()
                            task.wait(0.25)
                            SelectDifficulty:AddItems(DifficultyList(Settings['DungeonID']))
                        end
                    end
                end
            }

            SelectDifficulty = AutoFarm:Dropdown{
                Name = 'Difficulties',
                StartingText = tostring(DifficultyList(Settings['DungeonID'])[Settings['DifficultyID']]),
                Description = nil,
                Items = DifficultyList(Settings['DungeonID']),
                Callback = function(item)
                    if item == 'Normal' then
                        Settings['DifficultyID'] = 1
                    elseif item == 'Hard' then
                        Settings['DifficultyID'] = 2
                    elseif item == 'Challenge' then
                        Settings['DifficultyID'] = 3
                    elseif item == 'MASTER' then
                        Settings['DifficultyID'] = 4
                    elseif item == 'NIGHTMARE' then
                        Settings['DifficultyID'] = 5
                    end
                    Save()
                end
            }
        end

        AutoFarm:Toggle{Name = 'Daily Quests',
            StartingState = Settings['FarmDailyQuest'],
            Description = nil,
            Callback = function(state)
                Settings['FarmDailyQuest'] = state
                Save()
            end
        }

        AutoFarm:Toggle{Name = 'World Quests',
            StartingState = Settings['FarmWorldQuest'],
            Description = nil,
            Callback = function(state)
                Settings['FarmWorldQuest'] = state
                Save()
            end
        }

        AutoFarm:Toggle{Name = 'Guild Dungeons',
            StartingState = Settings['FarmGuildDungeon'],
            Description = nil,
            Callback = function(state)
                Settings['FarmGuildDungeon'] = state
                Save()
            end
        }

        AutoFarm:Toggle{Name = 'Restart Dungeon',
            StartingState = Settings['RestartDungeon'],
            Description = nil,
            Callback = function(state)
                Settings['RestartDungeon'] = state
                Save()
            end
        }

        AutoFarm:Toggle{Name = 'Start Farm',
            StartingState = Settings['StartFarm'],
            Description = nil,
            Callback = function(state)
                Settings['StartFarm'] = state
                Save()

                if not Settings['StartFarm'] then       
                    ClientRoot.CFrame = ClientRoot.CFrame + Vector3.new(0,30,0)
             
                    if ClientRoot:FindFirstChild('BodyVelocity') then
                        ClientRoot.CanCollide = true
                        ClientRoot.BodyVelocity:Destroy()
                    end

                    task.defer(function()
                        while not Settings['StartFarm'] and task.wait(0.1) do
                            if Character then
                                workspace.CurrentCamera.CameraSubject = Character
                            end
                        end
                    end)
                    Window:set_status('Status: Idle')
                else
                    function QuestFinished(QuestID)
                        return require(game.ReplicatedStorage.Shared.Quests):QuestCompleted(Client, QuestID)
                    end
        
                    function QuestLeft(QuestType)
                        local count = 0
                        for i,v in next, require(game.ReplicatedStorage.Shared.Quests.QuestList) do
                            if not QuestFinished(i) then
                                if QuestType == 'daily' then
                                    local DailyQuests = ClientProfile.DailyQuests
                                    local Slot1 = DailyQuests.Slot1Quest.Value
                                    local Slot2 = DailyQuests.Slot2Quest.Value
                                    local Slot3 = DailyQuests.Slot3Quest.Value
                                    if v.DailyQuest and (v.ID == Slot1 or v.ID == Slot2 or v.ID == Slot3) then
                                        count += 1
                                    end
                                elseif QuestType == 'world' then
                                    if v.WorldQuest and not v.Name:find('teleporter') then
                                        count += 1
                                    end
                                end
                            end
                        end
        
                        return count
                    end
                
                    function GetQuest(QuestType)
                        local minWorld = math.huge
                        local data = nil
        
                        for i,v in next, require(game.ReplicatedStorage.Shared.Quests.QuestList) do
                            if not QuestFinished(i) then
                                if QuestType == 'daily' then
                                    local DailyQuests = ClientProfile.DailyQuests
                                    local Slot1 = DailyQuests.Slot1Quest.Value
                                    local Slot2 = DailyQuests.Slot2Quest.Value
                                    local Slot3 = DailyQuests.Slot3Quest.Value
                                    if v.DailyQuest and (v.ID == Slot1 or v.ID == Slot2 or v.ID == Slot3) then
                                        if v.LinkedWorld < minWorld then
                                            minWorld = v.LinkedWorld
                                            data = v
                                        end
                                    end
                                elseif QuestType == 'world' then
                                    if v.WorldQuest and not v.Name:find('teleporter') then
                                        if v.LinkedWorld < minWorld then
                                            minWorld = v.LinkedWorld
                                            data = v
                                        end
                                    end
                                end
                            end
                        end
        
                        return data
                    end

                    function FarmDungeon()
                        if not ClientRoot:FindFirstChild('BodyVelocity') then
                            local bv = Instance.new('BodyVelocity')
                            bv.Parent = ClientRoot
                            bv.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
                            bv.Velocity = Vector3.new()
                            ClientRoot.CanCollide = false
                        end

                        function GetObject()
                            for i,v in next, workspace:GetChildren() do
                                if (v.Name:find('Pillar') or v.Name == 'Gate' or v.Name == 'TriggerBarrel') and v.PrimaryPart and IsAlive(v) then
                                    return v
                                elseif v.Name == 'FearNukes' then
                                    for i1,v1 in next, v:GetChildren() do
                                        if v1.PrimaryPart and IsAlive(v1) then
                                            return v1
                                        end
                                    end
                                end
                            end
        
                            if workspace:FindFirstChild('MissionObjects') then
                                for i,v in next, workspace.MissionObjects:GetChildren() do
                                    if v.Name == 'IceBarricade' and v.PrimaryPart and IsAlive(v) then
                                        return v
                                    elseif v.Name == 'SpikeCheckpoints' or v.Name == 'TowerLegs' then
                                        for i1,v1 in next, v:GetChildren() do
                                            if v1.PrimaryPart and IsAlive(v1) then
                                                return v1
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        
                        function GetTarget(type)
                            local closest = nil
                            local closestDistance = math.huge

                            for i,v in next, workspace.Mobs:GetChildren() do
                                if not v.Name:find('#') and not v.Name:find('SummonerSummon') and not v:FindFirstChild('NoHealthbar') and v:FindFirstChild('Collider') then
                                    if IsAlive(v) then
                                        if type == 'mob' and require(game.ReplicatedStorage.Shared.Mobs.Mobs[v.Name]).BossTag == false then
                                            local currentDistance = (ClientRoot.Position - v.Collider.Position).magnitude
                                            if currentDistance < closestDistance then
                                                closest = v
                                                closestDistance = currentDistance
                                            end
                                        elseif type == 'boss' and require(game.ReplicatedStorage.Shared.Mobs.Mobs[v.Name]).BossTag ~= false then
                                            local AvoidPos = {'DireCaveSpawn',}
                                            local CurrentPos = v:FindFirstChild("FromSpawnPart") and tostring(v.FromSpawnPart.Value)
                                            if not table.find(AvoidPos, CurrentPos) then
                                                closest = v
                                            end
                                        end
                                    end
                                end
                            end
        
                            return closest
                        end
        
                        function SubObject()
                            for i,v in next, workspace:GetChildren() do
                                if v.Name == 'IceWall' and v:FindFirstChild('Ring') then
                                    return v.Ring
                                elseif v.Name == 'CureFountainFallenKing' and v:FindFirstChild('ArcanePanel') then
                                    return v.ArcanePanel
                                end
                            end
        
                            if workspace:FindFirstChild('MissionObjects') and workspace.MissionObjects:FindFirstChild('IgnisShield') then
                                local shield = workspace.MissionObjects:FindFirstChild('IgnisShield')
                                if shield:FindFirstChild("Ring") and shield.Ring.Transparency == 0 then
                                    return shield.Ring
                                end
                            end
                        end
                
                        function Trigger()
                            -- function TowerChestMob()
                            --     if workspace:FindFirstChild('Map') then
                            --         for i,v in next, workspace.Map:GetDescendants() do
                            --             if v:IsA('Part') and v:FindFirstChild('MobName') and v.MobName.Value == 'Tower2ChestMob' then
                            --                 return v
                            --             end
                            --         end
                            --     end
                            -- end 
                
                            function FloorFinished()
                                if Client.PlayerGui.TowerVisual:FindFirstChild('TowerVisual') and Client.PlayerGui.TowerVisual.TowerVisual.Visible == true and Client.PlayerGui.TowerVisual.TowerVisual.KeyImage.TextLabel.Text:find('/') then
                                    local str = (Client.PlayerGui.TowerVisual.TowerVisual.KeyImage.TextLabel.Text):split('/')
                                    local current = tonumber(string.match(str[1] , '%d+'))
                                    local max = tonumber(string.match(str[2] , '%d+'))
                                    if current == max then
                                        return true
                                    end
                                end
                            end
                
                            function DangerPart(part)
                                local DangerParts = {'teleport','hearttele','a0','e0','s0','reset','push','temple','mushroom','water','lava','damage','fall','slider','part0','kill','arenaentry',}
                                for i,v in next, DangerParts do
                                    if part.Name:lower():find(v) or part.Name == 'Trigger' or tostring(part.Parent) == 'Geyser' then
                                        return true
                                    end
                                end
                            end
                
                            if workspace:FindFirstChild('MissionObjects') then
                                if workspace:FindFirstChild('KillerParts') then
                                    workspace.KillerParts:Destroy()
                                elseif workspace:FindFirstChild('CheckpointTriggers') then
                                    workspace.CheckpointTriggers:Destroy()
                                end

                                for i,v in next, workspace.MissionObjects:GetDescendants() do
                                    if v.Name == 'Cutscenes' or v.Name == 'WaterKillPart' or v.Name == 'CliffsideFallTriggers' or v.Name == 'DamageDroppers' or v.Name == 'FallAreas' or v.Name == 'TubeMarkers' then 
                                        v:Destroy()
                                    elseif v:IsA('Part') and not DangerPart(v) and v:FindFirstChildWhichIsA('TouchTransmitter') then
                                        v.CanCollide = false
                                        v.CFrame = ClientRoot.CFrame
                                        task.wait()
                                        v.CFrame = ClientRoot.CFrame + Vector3.new(0,500,0)
                                    end
                                end
        
                                for i,v in next, workspace:GetChildren() do
                                    if (v.Name:find('Cage') or v.Name:find('Treasure')) and v.PrimaryPart and v.PrimaryPart:FindFirstChildWhichIsA('TouchTransmitter') then
                                        v.PrimaryPart.CanCollide = false
                                        v.PrimaryPart.CFrame = ClientRoot.CFrame
                                        -- task.wait()
                                        -- v.PrimaryPart.CFrame = ClientRoot.CFrame + Vector3.new(0,500,0)
                                    end
                                end
                            end
                
                            if workspace:FindFirstChild('Map') and Client.PlayerGui.TowerVisual:FindFirstChild('TowerVisual') and Client.PlayerGui.TowerVisual.TowerVisual.Visible == true then
                                if FloorFinished() and workspace:FindFirstChild('Map') then
                                    Window:set_status('Move to exit')
                                    ClientRoot.CFrame = workspace.Map.Exit.BoundingBox.CFrame
                                -- elseif not FloorFinished() and workspace:FindFirstChild('Map') then
                                --     local chestMob = TowerChestMob()
                                --     if chestMob then
                                --         Window:set_status('Found chest mob')
                                --         ClientRoot.CFrame = chestMob.CFrame + Vector3.new(0,25,0)
                                --     else
                                --         if Client.PlayerGui.TowerVisual.TowerVisual.KeyImage.TextLabel.Text:find('/') then
                                --             local str = (Client.PlayerGui.TowerVisual.TowerVisual.KeyImage.TextLabel.Text):split('/')
                                --             local current = tonumber(string.match(str[1] , '%d+'))
                                --             local max = tonumber(string.match(str[2] , '%d+'))
                                --             local lastPoint = max - current
                                --             for i,v in next, workspace.Map:GetChildren() do
                                --                 if v:FindFirstChild('MobSpawns') then
                                --                     for a,b in next, v.MobSpawns:GetChildren() do
                                --                         if b:FindFirstChild('Spawns') and #b.Spawns:GetChildren() > 0 and #b.Spawns:GetChildren() <= lastPoint then
                                --                             for c,d in next, b.Spawns:GetChildren() do
                                --                                 if GetMob() or FloorFinished() or not Settings['StartFarm'] then break end
                                --                                 if d:IsA('Part') then
                                --                                     ClientRoot.CFrame = d.CFrame
                                --                                     task.wait(1)
                                --                                 end
                                --                             end
                                --                         end
                                --                     end
                                --                 end
                                --             end
                                --         end
                                --     end
                                end
                            end
                        end
                        Trigger()

                        function DodgeAlert()
                            local HurtfulSkills = {
                                'Slap','Sweep','Piledriver',
                                'BreathFire','FireBreath','Flamethrower',
                                'Attack1Fall','Attack2Fall',
                                'FireWall','Powerslash',
                                'DownwardIceFire','Attack1',
                            }
                    
                            for i,v in next, workspace.Mobs:GetChildren() do
                                if not v.Name:find('#') and v:FindFirstChild('Collider') and v:FindFirstChild('MobProperties') and v.MobProperties:FindFirstChild('CurrentAttack') and IsAlive(v) then
                                    if (v.Collider.Position - ClientRoot.Position).magnitude <= 50 then
                                        if table.find(HurtfulSkills, tostring(v.MobProperties.CurrentAttack.Value)) then
                                            return true
                                        end
                                    end
                                end
                            end

                            if workspace:FindFirstChild('FireBase') then
                                return true
                            end
                    
                            return false
                        end

                        local object = GetObject()
                        local mob = GetTarget('mob')
                        local boss = GetTarget('boss')
                        local ShortRanged = {'Swordmaster','Defender','DualWielder','Guardian','Berserker','Paladin','Demon','Dragoon','Warlord',}

                        if object then
                            Window:set_status('Attacking: Object')
                            workspace.CurrentCamera.CameraSubject = object
                            ClientRoot.CFrame = object.PrimaryPart.CFrame
                        else
                            if mob then
                                repeat task.wait()
                                    if GetObject() or not mob:FindFirstChild('Collider') or not IsAlive(Character) then break end

                                    workspace.CurrentCamera.CameraSubject = mob

                                    if Character:FindFirstChild('HealthProperties') and Character.HealthProperties.Health.Value <= Character.HealthProperties.MaxHealth.Value/2.5 then
                                        Window:set_status('Healing...')
                                        ClientRoot.CFrame = mob.Collider.CFrame + Vector3.new(0,100,0)
                                        repeat task.wait() until not IsAlive(Character) or Character.HealthProperties.Health.Value >= Character.HealthProperties.MaxHealth.Value
                                    else
                                        local mob_name = require(game.ReplicatedStorage.Shared.Mobs.Mobs[mob.Name])['NameTag']
                                        Window:set_status('Attacking: '..tostring(mob_name))

                                        if workspace:FindFirstChild('DireDeathballPink') then
                                            ClientRoot.CFrame = mob.Collider.CFrame + Vector3.new(5,40,0)
                                        else                                            
                                            if table.find(ShortRanged, ClientClass) then
                                                ClientRoot.CFrame = mob.Collider.CFrame + Vector3.new(0,-10,3)
                                                ClientRoot.CFrame = CFrame.lookAt(ClientRoot.Position, Vector3.new(mob.Collider.Position.X, ClientRoot.Position.Y, mob.Collider.Position.Z))
                                            else
                                                if ClientClass == 'Summoner' then
                                                    if Character.Properties.SummonCount.Value >= 4 then
                                                        ClientRoot.CFrame = mob.Collider.CFrame + Vector3.new(0,40,0)
                                                        task.wait(1)
                                                        game.ReplicatedStorage.Shared.Combat.Skillsets.Summoner.Summon:FireServer()
                                                        task.wait(2)
                                                    else
                                                        ClientRoot.CFrame = mob.Collider.CFrame + Vector3.new(0,-30,7)
                                                        ClientRoot.CFrame = CFrame.lookAt(ClientRoot.Position, Vector3.new(mob.Collider.Position.X, ClientRoot.Position.Y, mob.Collider.Position.Z))
                                                    end
                                                else
                                                    ClientRoot.CFrame = mob.Collider.CFrame + Vector3.new(0,-30,7)
                                                    ClientRoot.CFrame = CFrame.lookAt(ClientRoot.Position, Vector3.new(mob.Collider.Position.X, ClientRoot.Position.Y, mob.Collider.Position.Z))
                                                end
                                            end
                                        end
                                    end
                                until not mob or not Settings['StartFarm']
                                workspace.CurrentCamera.CameraSubject = Character
                                if game.PlaceId == 6386112652 and GetTarget('boss') then -- Dungeon 5-1
                                    ClientRoot.CFrame = ClientRoot.CFrame + Vector3.new(0,50,0)
                                end
                            else
                                if boss then
                                    repeat task.wait()
                                        if (
                                            GetObject()
                                            or GetTarget('mob')
                                            or not boss.Parent
                                            or not boss:FindFirstChild('Collider')
                                            or (bossPos ~= nil and boss.Collider.Position.Y < bossPos - 100)
                                            or boss.MobProperties.Busy:FindFirstChild('Before') 
                                            or workspace:FindFirstChild('GreaterTreeShield')
                                            or not IsAlive(Character)) then
                                            break
                                        end
                                        
                                        workspace.CurrentCamera.CameraSubject = boss

                                        if not boss.Name:find('Zeus') then
                                            boss.Collider.CanCollide = false
                                        end

                                        if boss.Name:find('Kraken') then
                                            ClientRoot.CFrame = boss.Collider.CFrame + Vector3.new(-10,-10,0)
                                        else
                                            if SubObject() then
                                                ClientRoot.CFrame = SubObject().CFrame + Vector3.new(0,5,0)
                                            else
                                                if Character:FindFirstChild('HealthProperties') and Character.HealthProperties.Health.Value <= Character.HealthProperties.MaxHealth.Value/2 then
                                                    Window:set_status('Healing...')
                                                    ClientRoot.CFrame = boss.Collider.CFrame + Vector3.new(0,100,0)
                                                    repeat task.wait() until not IsAlive(Character) or Character.HealthProperties.Health.Value >= Character.HealthProperties.MaxHealth.Value
                                                else
                                                    local boss_name = require(game.ReplicatedStorage.Shared.Mobs.Mobs[boss.Name])['NameTag']
                                                    Window:set_status('Attacking: '..tostring(boss_name))

                                                    if boss.Name == 'BOSSAnubis' then -- Dungeon 4-3
                                                        if (ClientRoot.Position - boss.Collider.Position).magnitude > 50 then
                                                            ClientRoot.CFrame = CFrame.new(-4904.49609375, 394.85925292969, -367.76528930664)
                                                            repeat task.wait() until boss:FindFirstChild('Collider') and (ClientRoot.Position - boss.Collider.Position).magnitude <= 50
                                                        end
                                                    elseif boss.Name == 'Hades' then -- Dungeon 7-1
                                                        if (ClientRoot.Position - boss.Collider.Position).magnitude > 50 then
                                                            ClientRoot.CFrame = CFrame.new(268.559814453125, 339.5906677246094, -620.95166015625)
                                                            repeat task.wait() until boss:FindFirstChild('Collider') and (ClientRoot.Position - boss.Collider.Position).magnitude <= 100
                                                        end
                                                    elseif game.PlaceId == 4050468028 then
                                                        if not Client.PlayerGui.BossHealthbar.BossHealthbar.Panels:FindFirstChild('Panel') then
                                                            ClientRoot.CFrame = boss.Collider.CFrame + Vector3.new(0,55,0)
                                                            task.wait(3)
                                                        end
                                                    end

                                                    local OneShotSkills = {'Thunderstorm','Shockwave','DarkOrbAttack','IceBeam','PillarSmash','Rage',}
                                                    if boss:FindFirstChild('MobProperties') and table.find(OneShotSkills, tostring(boss.MobProperties.CurrentAttack.Value)) then
                                                        ClientRoot.CFrame = ClientRoot.CFrame + Vector3.new(5,40,0)
                                                        repeat task.wait() until not boss or not boss:FindFirstChild('MobProperties') or not table.find(OneShotSkills, tostring(boss.MobProperties.CurrentAttack.Value))
                                                    else
                                                        if table.find(ShortRanged, ClientClass) then
                                                            if DodgeAlert() then
                                                                ClientRoot.CFrame = boss.Collider.CFrame + Vector3.new(0,-10,-15)
                                                            else
                                                                ClientRoot.CFrame = boss.Collider.CFrame + Vector3.new(0,-10,10)
                                                            end
                                                            
                                                            ClientRoot.CFrame = CFrame.lookAt(ClientRoot.Position, Vector3.new(boss.Collider.Position.X, ClientRoot.Position.Y, boss.Collider.Position.Z))
                                                        else
                                                            if ClientClass == 'Summoner' then
                                                                if Character.Properties.SummonCount.Value >= 3 then
                                                                    ClientRoot.CFrame = boss.Collider.CFrame + Vector3.new(0,50,10)
                                                                    task.wait(1)
                                                                    if not require(game.ReplicatedStorage.Client.Actions):IsOnCooldown('Ultimate') then
                                                                        require(game.ReplicatedStorage.Client.Actions):FireCooldown('Ultimate')
                                                                        game.ReplicatedStorage.Shared.Combat.Skillsets.Summoner.Ultimate:FireServer()
                                                                    end
                                                                    require(game.ReplicatedStorage.Client.Actions):FireCooldown('Skill1')
                                                                    game.ReplicatedStorage.Shared.Combat.Skillsets.Summoner.Summon:FireServer()
                                                                else
                                                                    ClientRoot.CFrame = boss.Collider.CFrame + Vector3.new(0,-30,5)
                                                                    ClientRoot.CFrame = CFrame.lookAt(ClientRoot.Position, Vector3.new(boss.Collider.Position.X, ClientRoot.Position.Y, boss.Collider.Position.Z))
                                                                end
                                                            else
                                                                ClientRoot.CFrame = boss.Collider.CFrame + Vector3.new(0,-30,5)
                                                                ClientRoot.CFrame = CFrame.lookAt(ClientRoot.Position, Vector3.new(boss.Collider.Position.X, ClientRoot.Position.Y, boss.Collider.Position.Z))
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    until not boss or not Settings['StartFarm']
                                    workspace.CurrentCamera.CameraSubject = Character
                                end
                            end
                        end
                    end
                
                    function FarmOpenWorld(target)
                        function GetMob()
                            local closest, closestDistance = nil, math.huge

                            for i,v in next, workspace.Mobs:GetChildren() do
                                if type(target) == 'table' and table.find(target, v.Name) and v:IsA('Model') and not v:FindFirstChild('NoHealthbar') and v:FindFirstChild('Collider') then
                                    local IsMob = require(game.ReplicatedStorage.Shared.Mobs.Mobs[v.Name]).BossTag == false
                                    
                                    if IsMob and IsAlive(v) then
                                        local currentDistance = (ClientRoot.Position - v.Collider.Position).magnitude
                                        if currentDistance < closestDistance then
                                            closest = v
                                            closestDistance = currentDistance
                                        end
                                    end
                                end
                            end
        
                            return closest
                        end
                        
                        function GetWorldBoss()
                            for i,v in next, workspace.Mobs:GetChildren() do
                                if target == nil and v:FindFirstChild('Collider') and v:FindFirstChild('BossTag') and IsAlive(v) then
                                    return v
                                end
                            end
                        end
                
                        function GetSpawn()
                            if workspace:FindFirstChild('MobAreas') then
                                for i,v in next, workspace.MobAreas:GetChildren() do
                                    if type(target) == 'table' and v:IsA('Part') and v:FindFirstChild('MobName') and table.find(target, v.MobName.Value) then
                                        return v
                                    end
                                end
                            end
                        end
                
                        function GetFlag()
                            for i,v in next, workspace:GetChildren() do
                                if target == nil and v:IsA('Folder') and v:FindFirstChild('BossSpawns') and v:FindFirstChild('Flag') then
                                    return v
                                end
                            end
                        end
        
                        -- function Tween(target)
                        --     if target then
                        --         local Speed = 0.35
                        --         if not ClientRoot:FindFirstChild('BodyVelocity') then
                        --             local bv = Instance.new('BodyVelocity')
                        --             bv.Parent = ClientRoot
                        --             bv.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
                        --             bv.Velocity = Vector3.new(0,0,0)
                        --             ClientRoot.CanCollide = false
                        --         end
        
                        --         if (ClientRoot.Position - (target.Position - Vector3.new(0,12,0))).magnitude > 15 then
                        --             ClientRoot.CFrame = CFrame.new(ClientRoot.Position + ((target.Position - Vector3.new(0,12,0)) - ClientRoot.Position).unit * Speed)
                        --         else
                        --             ClientRoot.CFrame = target.CFrame + Vector3.new(0,-12,5)
                        --             ClientRoot.CFrame = CFrame.lookAt(ClientRoot.Position, Vector3.new(target.Position.X, ClientRoot.Position.Y, target.Position.Z))
                        --         end

                        --     end
                        -- end

                        function Tween(target)
                            if target then
                                if not ClientRoot:FindFirstChild("BodyVelocity") then
                                    local BV = Instance.new("BodyVelocity", ClientRoot)
                                    BV.velocity = Vector3.new()
                                    BV.MaxForce = Vector3.new(0,math.huge,0)
                                end

                                local steps = (ClientRoot.Position - target.Position).magnitude
                                local startCFrame = ClientRoot.CFrame
                                local endCFrame = target.CFrame + Vector3.new(0,-10,0)
                                local speed = 0.3
                                for i = 0, steps, speed do
                                    if not ClientRoot then break end

                                    if (ClientRoot.Position - target.Position).magnitude > 15 then
                                        ClientRoot.CanCollide = false
                                        ClientRoot.CFrame = startCFrame:lerp(endCFrame, i/steps)
                                        game:GetService("RunService").Heartbeat:wait()
                                    else
                                        ClientRoot.CFrame = target.CFrame + Vector3.new(0,-10,5)
                                        ClientRoot.CFrame = CFrame.lookAt(ClientRoot.Position, Vector3.new(target.Position.X, ClientRoot.Position.Y, target.Position.Z))
                                    end
                                end
                            end
                        end
                
                        local bossFlag = GetFlag()
                        local worldBoss = GetWorldBoss()
                        local mob = GetMob()
                        local mobSpawn = GetSpawn()

                        if bossFlag then
                            game.ReplicatedStorage.Shared.WorldEvents.TeleportToEvent:FireServer(bossFlag)
                        else
                            if worldBoss then
                                repeat task.wait()
                                    if not worldBoss:FindFirstChild('Collider') or (worldBoss:FindFirstChild('HealthProperties') and worldBoss.HealthProperties.Health.Value <= 0) then break end
                                    Tween(worldBoss.Collider)
                                until not worldBoss or not Settings['StartFarm']
                            else
                                if mob then
                                    repeat task.wait()
                                        if not mob:FindFirstChild('Collider') or (mob:FindFirstChild('HealthProperties') and mob.HealthProperties.Health.Value <= 0) then break end

                                        if GetMob() then
                                            mob = GetMob()
                                        end
                                        
                                        Tween(mob.Collider)
                                    until not mob or not Settings['StartFarm']
                                else
                                    if mobSpawn then
                                        repeat task.wait()
                                            Tween(mobSpawn)
                                        until GetMob() or GetFlag() or GetWorldBoss() or not Settings['StartFarm']
                                    else
                                        if target ~= nil then
                                            if workspace:FindFirstChild('Waystones') then
                                                for i,v in next, workspace.Waystones:GetChildren() do
                                                    if v:FindFirstChild('SpawnZone') and v.SpawnZone:FindFirstChildWhichIsA('TouchTransmitter') then
                                                        v.SpawnZone.CanCollide = false
                                                        v.SpawnZone.CFrame = ClientRoot.CFrame
                                                        task.wait()
                                                        v.SpawnZone.CFrame = ClientRoot.CFrame + Vector3.new(0,500,0)
                                                    end
                                                end

                                                for i=1, #workspace.Waystones:GetChildren() do
                                                    if not Settings['StartFarm'] or GetFlag() or GetWorldBoss() or GetMob() or GetSpawn() then break end
                                                    game.ReplicatedStorage.Shared.Teleport.WaystoneTeleport:FireServer(i, 1)
                                                    task.wait(1)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                
                    function ListFarm()
                        local ListFarm = {}
                        for i,v in next, require(game.ReplicatedStorage.Shared.Missions.MissionData) do
                            if not v.NameTag:find('Event') and v.ShowOnProduction and v.ShowOnProduction == true and v.LevelRequirement <= ClientProfile.Level.Value then
                                table.insert(ListFarm, v)
                            end
                        end
                
                        table.sort(ListFarm, function(c,d)
                            return c.LevelRequirement < d.LevelRequirement
                        end)
                
                        return ListFarm
                    end
        
                    function DungeonList()
                        local FinalList = {}
                        for i,v in next, ListFarm() do
                            if v.difficulties then
                                for i1,v1 in next, v.difficulties do
                                    table.insert(FinalList, {v.ID, v1.id})
                                end
                            else
                                table.insert(FinalList, {v.ID, nil})
                            end
                        end
                    
                        return FinalList
                    end
                    
                    function NextDungeon()
                        local NextDungeon = 1
                        local NextDiff = 1
                    
                        for i=1, #DungeonList() do
                            local Dungeon = game.ReplicatedStorage.ActiveMission.Value
                            local Diff = game.TeleportService:GetLocalPlayerTeleportData().difficultyId
                            local v = DungeonList()[i]
                    
                            if v[1] == Dungeon and (v[2] == Diff or v[2] == nil) then
                                if i >= #DungeonList() then
                                    Settings['FarmGuildDungeon'] = false
                                    Save()
                                else
                                    v = DungeonList()[i+1]
                                    NextDungeon = v[1]
                                    NextDiff = v[2]
                                end
                            end
                        end
                        
                        return {NextDungeon, NextDiff}
                    end
                    
                    function QuestRoute(Mode, DoQuest)
                        local WorldIDs = {
                            [1] = 13,
                            [2] = 19,
                            [3] = 20,
                            [4] = 29,
                            [5] = 31,
                            [6] = 36,
                            [7] = 40,
                        }
                    
                        local TowerTargets = {
                            ['MagmaGigaBlob'] = 21,
                            ['Nautilus'] = 23,
                            ['BOSSZeus'] = 27,
                        }
            
                        local SpecialWorlds = {
                            7499964980, --Market
                            6510868181, --PvP Arena
                            5862275930, --Halloween Hub
                            4526768266, --Holiday Hub
                        }
                        
                        local QuestType = Mode.Objective[1]
                        local TargetTable = Mode.Objective[3]
                        local LinkedWorld = Mode.LinkedWorld
                        local CurrentWorld = require(game.ReplicatedStorage.Shared.Teleport):GetCurrentWorldData()['WorldOrderID']
                        local CorrectWorld = CurrentWorld == LinkedWorld

                        if QuestType == 'KillMob' then
                            if not TowerTargets[TargetTable[1]] then
                                if InDungeon or not CorrectWorld or table.find(SpecialWorlds, game.PlaceId) then
                                    if require(game.ReplicatedStorage.Shared.Teleport):WorldIsAvailableToPlayer(WorldIDs[LinkedWorld], Client) then
                                        Window:set_status('Move to: World '..tostring(LinkedWorld)..' | Quest: '..tostring(Mode.Name))
                                        game.ReplicatedStorage.Shared.Teleport.TeleportToHub:FireServer(WorldIDs[LinkedWorld])
                                    else
                                        Window:set_status('Farm level: '..(ListFarm()[#ListFarm()].NameTag))
                                        game.ReplicatedStorage.Shared.Teleport.StartRaid:FireServer(ListFarm()[#ListFarm()].ID)
                                    end
                                elseif not InDungeon and CorrectWorld and not table.find(SpecialWorlds, game.PlaceId) and DoQuest then
                                    Window:set_status('Do quest: '..tostring(Mode.Name))
                                    FarmOpenWorld(TargetTable)
                                end
                            else
                                local towerId = TowerTargets[TargetTable[1]]
                                if ClientLevel >= require(game.ReplicatedStorage.Shared.Missions):GetMissionData()[towerId].LevelRequirement then
                                    Window:set_status('Move to tower has: '..tostring(TargetTable[1]))
                                    game.ReplicatedStorage.Shared.Teleport.StartRaid:FireServer(towerId)
                                else
                                    Window:set_status('Farming level: '..(ListFarm()[#ListFarm()].NameTag))
                                    game.ReplicatedStorage.Shared.Teleport.StartRaid:FireServer(ListFarm()[#ListFarm()].ID)
                                end
                            end
                        elseif QuestType == 'DoDungeon' then
                            local LevelRequirement = require(game.ReplicatedStorage.Shared.Missions):GetMissionData()[Mode.Objective[3][1]].LevelRequirement
                            if ClientLevel >= LevelRequirement then
                                Window:set_status('Do quest: '..tostring(Mode.Name))
                                game.ReplicatedStorage.Shared.Teleport.StartRaid:FireServer(TargetTable[1])
                            else
                                Window:set_status('Farm level: '..(ListFarm()[#ListFarm()].NameTag))
                                game.ReplicatedStorage.Shared.Teleport.StartRaid:FireServer(ListFarm()[#ListFarm()].ID)
                            end
                        elseif QuestType == 'CompleteWorldEvent' then
                            if not CorrectWorld or table.find(SpecialWorlds, game.PlaceId) then
                                Window:set_status('Move to: World '..tostring(LinkedWorld)..' | Quest: '..tostring(Mode.Name))
                                game.ReplicatedStorage.Shared.Teleport.TeleportToHub:FireServer(WorldIDs[LinkedWorld])
                            elseif CorrectWorld and not table.find(SpecialWorlds, game.PlaceId) and DoQuest then
                                --Window:set_status('Do quest: '..tostring(Mode.Name))
                                FarmOpenWorld(nil)
                            end
                        elseif QuestType == 'DoDungeonInWorld' then
                            Window:set_status('Do quest: '..tostring(Mode.Name))
                            if Mode.Name:find('World 1') then
                                game.ReplicatedStorage.Shared.Teleport.StartRaid:FireServer(1)
                            elseif Mode.Name:find('World 2') then
                                game.ReplicatedStorage.Shared.Teleport.StartRaid:FireServer(11)
                            elseif Mode.Name:find('World 3') then 
                                game.ReplicatedStorage.Shared.Teleport.StartRaid:FireServer(14)
                            elseif Mode.Name:find('World 4') then
                                game.ReplicatedStorage.Shared.Teleport.StartRaid:FireServer(19)
                            end
                        elseif QuestType == 'LevelUp' then
                            Window:set_status('Do quest: '..tostring(Mode.Name))
                            game.ReplicatedStorage.Shared.Teleport.StartRaid:FireServer(ListFarm()[#ListFarm()].ID)
                        end
                    end
                    
                    function Action(DoQuest)
                        local Towers = {17,22,21,23,27,29}
        
                        if QuestLeft('daily') > 0 and Settings['FarmDailyQuest'] then
                            QuestRoute(GetQuest('daily'), DoQuest)
                        elseif QuestLeft('daily') <= 0 or not Settings['FarmDailyQuest'] then
                            if QuestLeft('world') > 0 and Settings['FarmWorldQuest'] then
                                QuestRoute(GetQuest('world'), DoQuest)
                            elseif QuestLeft('world') <= 0 or not Settings['FarmWorldQuest'] then
                                if Settings['FarmGuildDungeon'] then
                                    if not InDungeon then
                                        Window:set_status('Move to: '..(MissionDefValue(1))..' ('..(DifficultyList(1)[1])..')')
                                        game.ReplicatedStorage.Shared.Teleport.StartRaid:FireServer(1, 1)
                                    else
                                        local nextDungeon = NextDungeon()

                                        if table.find(Towers, (nextDungeon[1])) then
                                            Window:set_status('Move to: '..(MissionDefValue(nextDungeon[1])))
                                            game.ReplicatedStorage.Shared.Teleport.StartRaid:FireServer(nextDungeon[1])
                                        else
                                            Window:set_status('Move to: '..(MissionDefValue(nextDungeon[1]))..' ('..(DifficultyList(nextDungeon[1])[nextDungeon[2]])..')')
                                            game.ReplicatedStorage.Shared.Teleport.StartRaid:FireServer(nextDungeon[1], nextDungeon[2])
                                        end
                                    end
                                else
                                    if table.find(Towers, (Settings['DungeonID'])) then
                                        Window:set_status('Move to: '..(MissionDefValue(Settings['DungeonID'])))
                                        game.ReplicatedStorage.Shared.Teleport.StartRaid:FireServer(Settings['DungeonID'])
                                    else
                                        if Settings['DifficultyID'] == nil then
                                            Settings['DifficultyID'] = 1
                                        end
                                        
                                        Window:set_status('Move to: '..(MissionDefValue(Settings['DungeonID']))..' ('..(DifficultyList(Settings['DungeonID'])[Settings['DifficultyID']])..')')
                                        game.ReplicatedStorage.Shared.Teleport.StartRaid:FireServer(Settings['DungeonID'], Settings['DifficultyID'])
                                    end
                                end
                            end
                        end
                    end
        
                    local ItemCount = 0
                    if game.ReplicatedStorage:FindFirstChild('FloorCounter') then
                        game.ReplicatedStorage.FloorCounter.Changed:Connect(function(floor)
                            if floor == 5 then
                                ClientProfile.Inventory.Items.ChildAdded:Connect(function(item)
                                    local type = require(game.ReplicatedStorage.Shared.Items)[item.Name].Type
                                    if type == 'Weapon' then
                                        ItemCount += 1
                                    elseif type == 'Armor' then
                                        ItemCount += 1
                                    end
                                end)
                                ClientProfile.Inventory.Cosmetics.ChildAdded:Connect(function(item)
                                    ItemCount += 1
                                end)
                            end
                        end)
                    end
                    
                    local HolidayDungeonEnded = false
                    if game.PlaceId == 4526768588 then
                        if ClientProfile.Inventory.Items:FindFirstChild('HolidayPrizeTicket2') then
                            ClientProfile.Inventory.Items['HolidayPrizeTicket2'].Count:GetPropertyChangedSignal('Value'):Connect(function()
                                HolidayDungeonEnded = true
                            end)
                        else
                            ClientProfile.Inventory.Items.ChildAdded:Connect(function(item)
                                local type = require(game.ReplicatedStorage.Shared.Items)[item.Name].Type
                                if type == 'PrizeTicket' then
                                    HolidayDungeonEnded = true
                                end
                            end)
                        end
                    end
        
                    task.defer(function() -- mainfarm
                        while Settings['StartFarm'] and task.wait() do
                            if Client.PlayerGui.QuestList.QuestList.DailyQuests.Frame.Complete.Select.ImageColor3 ~= Color3.fromRGB(129,129,129) then
                                game.ReplicatedStorage.Shared.Quests.ClaimCrystals:FireServer()
                            end
        
                            if InDungeon then
                                FarmDungeon()

                                if Settings['RestartDungeon'] and (Client.PlayerGui.MissionRewards.MissionRewards.Visible == true or ItemCount >= 3 or HolidayDungeonEnded == true) then
                                    game.ReplicatedStorage.Shared.Missions.GetMissionPrize:InvokeServer()
                                    game.ReplicatedStorage.Shared.Missions.GetMissionPrize:InvokeServer()
                                    task.wait(3)
                                    Action(false)
                                end
                            else
                                Action(true)
                            end
                        end
                    end)
                end
            end
        }

    local Features = Window:Tab{Name = 'Features', Icon = 'rbxassetid://8569322835'}
        Features:Toggle{Name = 'Kill Aura',
            StartingState = Settings['KillAura'],
            Description = nil,
            Callback = function(state)
                Settings['KillAura'] = state
                Save()

                local ShortRanged = {
                    'Swordmaster','Defender',
                    'DualWielder','Guardian',
                    'Berserker','Paladin',
                    'Demon','Dragoon',
                    'Warlord',
                }

                local Delay = {
                    ['Mage']        = {0.35, 5, 8, 0, 0},
                    ['Swordmaster'] = {0.4, 5, 8, 0, 0},
                    ['Defender']    = {0.4, 5, 8, 0, 0},
        
                    ['IcefireMage'] = {0.4, 6, 10, 15, 30},
                    ['DualWielder'] = {0.65, 0, 6, 8, 30},
                    ['Guardian']    = {0.75, 0, 6, 8, 30},
        
                    ['MageOfLight'] = {0.35, 0, 0, 0, 0},
                    ['Berserker']   = {0.35, 5, 5, 5, 20},
                    ['Paladin']     = {0.3, 2, 0, 11, 0},
        
                    ['Demon']       = {0.8, 0, 5, 9, 0},
                    ['Dragoon']     = {0.4, 5, 5, 7, 25},
                    ['Archer']      = {0.45, 5, 10, 10, 25},

                    ['Summoner']    = {0.7, 0, 0, 5, 0},
                    ['Warlord']     = {0.35, 3, 2, 3, 10},
                }

                function GetObjectPos()
                    if workspace:FindFirstChild('MissionObjects') then
                        for i,v in next, workspace.MissionObjects:GetChildren() do
                            if v.Name == 'IceBarricade' and v.PrimaryPart and IsAlive(v) then
                                return v.PrimaryPart.Position
                            elseif v.Name == 'SpikeCheckpoints' or v.Name == 'TowerLegs' then
                                for i1,v1 in next, v:GetChildren() do
                                    if v1.PrimaryPart and IsAlive(v1) then
                                        return v1.PrimaryPart.Position
                                    end
                                end
                            end
                        end
        
                        for i,v in next, workspace:GetChildren() do
                            if (v.Name:find('Pillar') or v.Name == 'Gate' or v.Name == 'TriggerBarrel') and v.PrimaryPart and IsAlive(v) then
                                return v.PrimaryPart.Position
                            elseif v.Name == 'FearNukes' then
                                for i1,v1 in next, v:GetChildren() do
                                    if v1.PrimaryPart and IsAlive(v1) then
                                        return v1.PrimaryPart.Position
                                    end
                                end
                            end
                        end
                    end
                end

                function GetMobPos()
                    local closest, closestDistance = nil, 50
                    
                    for i,v in next, workspace.Mobs:GetChildren() do
                        if v:IsA('Model') and not v:FindFirstChild('NoHealthbar') and v:FindFirstChild('Collider') then
                            local CanDamage = require(game.ReplicatedStorage.Shared.Status):HasStatus(v, 'Invincible') == nil
                            if CanDamage and IsAlive(v) then
                                local currentDistance = (ClientRoot.Position - v.Collider.Position).magnitude
                                if currentDistance < closestDistance then
                                    closest = v.Collider.Position
                                    closestDistance = currentDistance
                                end
                            end
                        end
                    end
        
                    return closest
                end
                
                function DamagePos()
                    local object = GetObjectPos()
                    local mob = GetMobPos()

                    if object then
                        return object
                    else
                        return mob
                    end
                end

                function LoopAttack(skilltype)
                    local pos = DamagePos()
                    if pos and not require(game.ReplicatedStorage.Client.Actions):IsMounted() then                        
                        for index,attack in next, AtkType[skilltype] do
                            if table.find(ShortRanged, ClientClass) then
                                game.ReplicatedStorage.Shared.Combat.Attack:FireServer(attack, ClientRoot.Position, (pos - ClientRoot.Position).Unit)
                            else
                                game.ReplicatedStorage.Shared.Combat.Attack:FireServer(attack, pos)
                            end

                            task.wait(0.035)

                            if attack == AtkType[skilltype][#AtkType[skilltype]] then break end
                        end
                    end
                end

                if #AtkType['Primary'] > 0 then
                    task.defer(function()
                        while Settings['KillAura'] do
                            LoopAttack('Primary')
                            task.wait(Delay[ClientClass][1])
                        end
                    end)
                end

                if #AtkType['Skill1'] > 0 then
                    task.defer(function()
                        while Settings['KillAura'] do
                            LoopAttack('Skill1')
                            task.wait(Delay[ClientClass][2])
                        end
                    end)
                end

                if #AtkType['Skill2'] > 0 then
                    task.defer(function()
                        while Settings['KillAura'] do
                            LoopAttack('Skill2')
                            task.wait(Delay[ClientClass][3])
                        end
                    end)
                end

                if #AtkType['Skill3'] > 0 then
                    task.defer(function()
                        while Settings['KillAura'] do
                            LoopAttack('Skill3')
                            task.wait(Delay[ClientClass][4])
                        end
                    end)
                end

                if #AtkType['Ultimate'] > 0 then
                    task.defer(function()
                        while Settings['KillAura'] do
                            LoopAttack('Ultimate')
                            task.wait(Delay[ClientClass][5])
                        end
                    end)
                end

                task.defer(function()
                    while Settings['KillAura'] and task.wait(0.1) do
                        if not require(game.ReplicatedStorage.Client.Actions):IsMounted() then
                            if Character:WaitForChild('HealthProperties').Health.Value < Character:WaitForChild('HealthProperties').MaxHealth.Value then
                                if ClientClass == 'Demon' then
                                    game.ReplicatedStorage.Shared.Combat.Skillsets.Demon.LifeSteal:FireServer(workspace.Mobs:GetChildren())
                                elseif ClientClass == 'Paladin' then
                                    game.ReplicatedStorage.Shared.Combat.Skillsets.Paladin.GuildedLight:FireServer()
                                end
                            end
                                    
                            if DamagePos() then
                                if ClientClass == 'Demon' and InDungeon then
                                    for i=1,27 do
                                        game.ReplicatedStorage.Shared.Combat.Skillsets.Demon.Demonic:FireServer()
                                    end
                                    if require(game.ReplicatedStorage.Shared.Energy):GetEnergyRatio(Character) == 1 then
                                        game.ReplicatedStorage.Shared.Combat.Skillsets.Demon.Ultimate:FireServer()
                                        require(game.ReplicatedStorage.Shared.Combat.Skillsets.Demon):CleanupCharacter(Character)
                                        if Character:FindFirstChild('Statuses') and Character.Statuses:FindFirstChild('AttackBuffDemonPrince') then
                                            Character.Statuses.AttackBuffDemonPrince.Value = 0
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        }

        Features:Toggle{Name = 'Coin Magnets',
            StartingState = Settings['PickUp'],
            Description = nil,
            Callback = function(state)
                Settings['PickUp'] = state
                Save()

                task.defer(function()
                    while Settings['PickUp'] and task.wait(0.1) do
                        for i,v in next, getupvalue(require(game.ReplicatedStorage.Shared.Chests).Start, 7) do
                            if v.Parent and game.ReplicatedStorage.Shared.Chests.CheckCondition:InvokeServer(i) == true then
                                v:Destroy()
                                game.ReplicatedStorage.Shared.Chests.OpenChest:FireServer(i)
                            end
                        end
        
                        for i, v in next, getupvalue(require(game.ReplicatedStorage.Shared.Drops).Start, 4) do
                            v.model:Destroy()
                            v.followPart:Destroy()
                            game.ReplicatedStorage.Shared.Drops.CoinEvent:FireServer(v.id)
                            table.remove(getupvalue(require(game.ReplicatedStorage.Shared.Drops).Start, 4), i)
                        end
                    end
                end)
            end
        }

        Features:Toggle{Name = 'Upgrade Equipped',
            StartingState = false,
            Description = nil,
            Callback = function(upgrade)
                task.defer(function()
                    while upgrade and task.wait(0.1) do
                        for i,v in next, ClientProfile.Equip:GetChildren() do
                            if v:IsA('Folder') and (v.Name == 'Primary' or v.Name == 'Armor' or v.Name == 'Offhand') and v:FindFirstChildWhichIsA('Folder') then
                                local v1 = v:FindFirstChildWhichIsA('Folder')
                                if v1:FindFirstChild('Upgrade') and v1:FindFirstChild('UpgradeLimit') and v1.Upgrade.Value < v1.UpgradeLimit.Value then
                                    game.ReplicatedStorage.Shared.ItemUpgrade.Upgrade:FireServer(v1)
                                elseif not v1:FindFirstChild('Upgrade') or v1:FindFirstChild('UpgradeLimit') then
                                    game.ReplicatedStorage.Shared.ItemUpgrade.Upgrade:FireServer(v1)
                                end
                            end
                        end
                    end
                end)
            end
        }

        Features:Slider{Name = 'Sprint Speed',
            Default = 30,
            Min = 30,
            Max = 100,
            Callback = function(value)
                require(game.ReplicatedStorage.Shared.Settings).SPRINT_WALKSPEED = value
            end
        }

        -- local NameList, DistanceList = {}, {}
        -- Features:Toggle{Name = 'ESP (Players)',
        --     StartingState = false,
        --     Description = nil,
        --     Callback = function(esp_players)
        --         local EspLoop
        --         if esp_players then
        --             EspLoop = game:GetService('RunService').RenderStepped:Connect(function()
        --                 for i,v in next, NameList do if v then v:Remove() end end
        --                 for i,v in next, DistanceList do if v then v:Remove() end end
                        
        --                 NameList = {}
        --                 DistanceList = {}
        
        --                 for i,v in next, game.Players:GetPlayers() do
        --                     if v.Name ~= Client.Name and v.Character and v.Character.PrimaryPart ~= nil and IsAlive(v.Character) then
        --                         local pos = v.Character.PrimaryPart.Position
        --                         local ScreenSpacePos, IsOnScreen = workspace.CurrentCamera:WorldToViewportPoint(pos)
                                
        --                         if IsOnScreen then
        --                             local NAME = Drawing.new('Text')
        --                             NAME.Text = v.Name
        --                             NAME.Size = 16
        --                             NAME.Color = Color3.fromRGB(255, 248, 145)
        --                             NAME.Center = true
        --                             NAME.Visible = true
        --                             NAME.Transparency = 1
        --                             NAME.Position = Vector2.new(0, 0)
        --                             NAME.Outline = true
        --                             NAME.OutlineColor = Color3.fromRGB(10, 10, 10)
        --                             NAME.Font = 3
                                    
        --                             local DISTANCE = Drawing.new('Text')
        --                             DISTANCE.Text = '[]'
        --                             DISTANCE.Size = 14
        --                             DISTANCE.Color = Color3.fromRGB(255, 255, 255)
        --                             DISTANCE.Center = true
        --                             DISTANCE.Visible = true
        --                             DISTANCE.Transparency = 1
        --                             DISTANCE.Position = Vector2.new(0, 0)
        --                             DISTANCE.Outline = true
        --                             DISTANCE.OutlineColor = Color3.fromRGB(10, 10, 10)
        --                             DISTANCE.Font = 3
                                    
        --                             NAME.Position = Vector2.new(ScreenSpacePos.X, ScreenSpacePos.Y)
        --                             DISTANCE.Position = NAME.Position + Vector2.new(0, NAME.TextBounds.Y/1.2)
        --                             DISTANCE.Text = '['..math.round((game.Players.LocalPlayer.Character.PrimaryPart.Position - pos).magnitude)..'m]'
                    
        --                             NameList[#NameList+1] = NAME
        --                             DistanceList[#DistanceList+1] = DISTANCE
        --                         end
        --                     end
        --                 end
        --             end)
        --         else
        --             pcall(function() EspLoop:Disconnect() end)
        
        --             for i,v in next, NameList do v:Remove() end
        --             for i,v in next, DistanceList do v:Remove() end
                    
        --             NameList = {}
        --             DistanceList = {}
        --         end
        --     end
        -- }

    local Inventory = Window:Tab{Name = 'Inventory', Icon = 'rbxassetid://4483345998'}
        for i=1,4 do
            Inventory:Toggle{Name = 'Sell Tier'..tostring(i),
                StartingState = Settings['SellTier'..tostring(i)],
                Description = nil,
                Callback = function(state)
                    Settings['SellTier'..tostring(i)] = state
                    Save()
                end
            }
        end

        Inventory:Toggle{Name = 'Sell Egg',
            StartingState = Settings['SellEgg'],
            Description = nil,
            Callback = function(state)
                Settings['SellEgg'] = state
                Save()
            end
        }

        Inventory:Button{Name = 'Quick Sell',
            Description = nil,
            Callback = function()
                local sellTable = {}
                for i,v in next, ClientProfile.Inventory.Items:GetChildren() do
                    if v:IsA('Folder') then
                        local rarity = require(game.ReplicatedStorage.Shared.Inventory):GetItemTier(v)
                        local type = require(game.ReplicatedStorage.Shared.Items)[v.Name].Type
                        if type == 'Weapon' or type == 'Armor' then
                            if Settings['SellTier1'] and rarity == 1 then
                                table.insert(sellTable, v)
                            elseif Settings['SellTier2'] and rarity == 2 then
                                table.insert(sellTable, v)
                            elseif Settings['SellTier3'] and rarity == 3 then
                                table.insert(sellTable, v)
                            elseif Settings['SellTier4'] and rarity == 4 then
                                table.insert(sellTable, v)
                            end
                        elseif type == 'Egg' and Settings['SellEgg'] then
                            table.insert(sellTable, v)
                        end
                    end
                end
                game.ReplicatedStorage.Shared.Drops.SellItems:InvokeServer(sellTable)
            end
        }

        Inventory:Toggle{Name = 'Auto Equip',
            StartingState = Settings['AutoEquip'],
            Description = nil,
            Callback = function(state)
                Settings['AutoEquip'] = state
                Save()
            end
        }

        Inventory:Toggle{Name = 'Auto Sell',
            StartingState = Settings['AutoSell'],
            Description = nil,
            Callback = function(state)
                Settings['AutoSell'] = state
                Save()
            end
        }

        ClientProfile.Inventory.Items.ChildAdded:Connect(function(v)
            if Settings['AutoEquip'] then
                task.defer(function()
                    while Settings['AutoEquip'] and task.wait() do
                        if v.Parent ~= ClientProfile.Inventory.Items then break end

                        local type = require(game.ReplicatedStorage.Shared.Items)[v.Name].Type
                        if type == 'Weapon' then
                            local currentWeapon = ClientProfile.Equip.Primary:FindFirstChildWhichIsA('Folder')
                            if currentWeapon then
                                local currentDmg = require(game.ReplicatedStorage.Shared.Combat):GetItemStats(currentWeapon).Attack
                                local newDmg = require(game.ReplicatedStorage.Shared.Combat):GetItemStats(v).Attack
                                if newDmg > currentDmg then
                                    game.ReplicatedStorage.Shared.Inventory.EquipItem:FireServer(v, ClientProfile.Equip['Primary'])
                                end
                            end
                        elseif type == 'Armor' then
                            local currentArmor = ClientProfile.Equip.Armor:FindFirstChildWhichIsA('Folder')
                            if currentArmor then
                                local currentHealth = require(game.ReplicatedStorage.Shared.Combat):GetItemStats(currentArmor).Defense
                                local newHealth = require(game.ReplicatedStorage.Shared.Combat):GetItemStats(v).Defense
                                if newHealth > currentHealth then
                                    game.ReplicatedStorage.Shared.Inventory.EquipItem:FireServer(v, ClientProfile.Equip['Armor'])
                                end
                            end
                        end
                    end
                end)
            end
            
            task.wait(2)
            if v.Parent ~= ClientProfile.Inventory.Items then return end

            if Settings['AutoSell'] then
                local rarity = require(game.ReplicatedStorage.Shared.Inventory):GetItemTier(v)
                local type = require(game.ReplicatedStorage.Shared.Items)[v.Name].Type
                if type == 'Weapon' or type == 'Armor' then
                    if Settings['SellTier1'] and rarity == 1 then
                        game.ReplicatedStorage.Shared.Drops.SellItems:InvokeServer({v})
                    elseif Settings['SellTier2'] and rarity == 2 then
                        game.ReplicatedStorage.Shared.Drops.SellItems:InvokeServer({v})
                    elseif Settings['SellTier3'] and rarity == 3 then
                        game.ReplicatedStorage.Shared.Drops.SellItems:InvokeServer({v})
                    elseif Settings['SellTier4'] and rarity == 4 then
                        game.ReplicatedStorage.Shared.Drops.SellItems:InvokeServer({v})
                    end
                elseif type == 'Egg' and Settings['SellEgg'] then
                    game.ReplicatedStorage.Shared.Drops.SellItems:InvokeServer({v})
                end
            end
        end)

    local Misc = Window:Tab{Name = 'Misc', Icon = 'rbxassetid://3610245066'}
        Misc:Button{Name = 'Bank Menu',
            Description = nil,
            Callback = function()
                require(game.ReplicatedStorage.Client.Gui.GuiScripts.Bank):Open()
            end
        }

        Misc:Button{Name = 'Dungeons Menu',
            Description = nil,
            Callback = function()
                require(game.ReplicatedStorage.Client.Gui.GuiScripts.MissionSelect):Open()
            end
        }

        Misc:Button{Name = 'Worlds Menu',
            Description = nil,
            Callback = function()
                require(game.ReplicatedStorage.Client.Gui.GuiScripts.WorldTeleport):Open()
            end
        }

        Misc:Dropdown{Name = 'Egg Info',
            StartingText = 'Select...',
            Description = nil,
            Items = {'StarEgg','JungleEgg','CrystalEgg','DesertEgg','ChristmasEgg','MoltenEgg','OceanEgg','SkyEgg','CatEgg','CatEggHalloween'},
            Callback = function(item)
                require(game.ReplicatedStorage.Client.Gui.GuiScripts.PetShop):Open(item)
            end
        }
        
        Misc:Toggle{Name = 'Feed Pet',
            StartingState = false,
            Description = nil,
            Callback = function(feedpet)        
                task.defer(function()
                    while feedpet and task.wait(0.1) do
                        for i,v in next, ClientProfile.Inventory.Items:GetChildren() do
                            if v:FindFirstChild('Count') and v.Count.Value > 0 then
                                game.ReplicatedStorage.Shared.Pets.FeedPet:FireServer(v, true)
                            end
                        end
                    end
                end)
            end
        }

        Misc:Button{Name = 'Collect Battlepass',
            Description = nil,
            Callback = function()
                for i=1,40 do
                    game.ReplicatedStorage.Shared.Battlepass.RedeemItem:FireServer(i)
                    game.ReplicatedStorage.Shared.Battlepass.RedeemItem:FireServer(i, true)
                    task.wait(0.1)
                end
            end
        }

        Misc:Textbox{Name = 'Spin Wheel',
            Callback = function(text)
                for i=1,tonumber(text) do
                    require(game.ReplicatedStorage.Shared.EventSpinner).SPINNER_TIMER = 0
                    require(game.ReplicatedStorage.Shared.EventSpinner).SPINNER_INTERMISSION_TIMER = 0
                    require(game.ReplicatedStorage.Shared.EventSpinner):RequestJoinQueue(Client)
                    require(game.ReplicatedStorage.Shared.EventSpinner):RemoveFromQueue(Client)
                    task.wait(0.1)
                end
            end
        }
end