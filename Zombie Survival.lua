-- game https://www.roblox.com/games/7253840385/NEW-CODE-Zombie-Survival

-- game.Players.LocalPlayer.Character['Glock 17'].ReloadFunction:InvokeServer('ReloadEnd') <------ [INSTANT RELOAD]

-- // Variables // --
local main_module = loadstring(game:HttpGet('https://raw.githubusercontent.com/Sinscrips/source_scripts/main/Main%20Module.lua', true))()
local library = main_module['Library']
local esp = main_module['Esp']
local aimbot = main_module['Aimbot']
local uis = game:GetService('UserInputService')

local _plr = game.Players.LocalPlayer
local _game = game.Workspace.Game
local _bullets = game.Workspace.CosmeticBulletsFolder
local _zombies = _game.Zombies

getgenv().gun_mods = false

local _client = { 
    InGame = _plr:GetAttribute('IsInGame');
    sprint_speed = 22;
}
local _shared = { 
    old_shove = require(game.ReplicatedStorage.Client.Modules.Utils.Spring).create().shove;
    ignore_list = getupvalue(require(game.ReplicatedStorage.Shared.Modules.WeaponReplication).AddToList, 1);
}
local _settings = {
    god_mode = false;
    inf_stamina = false;
    loop_kill = false;
    zombies_anchored = false;
    gun_mods = false;
}

-- // Functions // --
function KillZombie(v1)
    spawn(function()
        repeat
            local tool = _plr.PlayerScripts:WaitForChild('WeaponClient').ToolRef.Value
            local fire_event = tool:WaitForChild('FireEvent')

            tool.Parent = _plr.Character
            fire_event:FireServer("'\226\160\128RayHita\226\160\128'", v1, v1.Head) 

            wait() 
        until v1.Humanoid.Health <= 0 or v1.Parent == nil
    end)
end

-- // Data Grab // --
function updateClient()
    if _client.InGame then

        _client.tool = _plr.PlayerScripts:WaitForChild('WeaponClient').ToolRef.Value
        for i,v in pairs(getgc(true)) do
            if type(v) == 'table' then
                if rawget(v, 'Sprinting') then
                    _client.movement = v
                    if _client.sprint_speed then
                        _client.movement.Sprinting = _client.sprint_speed
                    end
                end
            elseif type(v) == 'function' then
                if getinfo(v).name == 'FireBullet' and getinfo(v).source:find('WeaponClient') then
                    _shared.spring = getupvalue(v, 25)
                    _shared.old_shove = _shared.spring.shove
                    if _settings.gun_mods then
                        _shared.spring.shove = function() return end
                    end
                end
            end
        end 

        if _settings.loop_kill then
            for i,v in pairs(_zombies:GetChildren()) do
                KillZombie(v)
            end
        end
        print('client updated')

    end
    return
end

-- // Library 1 Buttons // --
Frame1 = library:AddFrame({name = 'Character Cheats'})

Frame1:AddToggle('God Mode', function(v1) -- god
    _settings.god_mode = v1
end)

Frame1:AddToggle('Gun Mods', function(v1) -- gun mods
    getgenv().gun_mods = v1
    _settings.gun_mods = v1
    if _client.InGame then
        _plr.PlayerScripts.WeaponClient.Disabled = true
        _plr.PlayerScripts.WeaponClient.Disabled = false

        updateClient()

        if v1 then
            _shared.spring.shove = function() return end

            require(game.ReplicatedStorage.Shared.Modules.WeaponReplication).AddToList(game.Workspace.Game.ActiveMap)
            require(game.ReplicatedStorage.Shared.Modules.WeaponReplication).AddToList(game.Workspace.Game.GlobalMapItems)
            require(game.ReplicatedStorage.Shared.Modules.WeaponReplication).AddToList(game.Workspace.Game.Perks)
        else
            _client.tool.ReloadFunction:InvokeServer('ReloadEnd')
            _shared.spring.shove = _shared.old_shove

            for i,v in pairs(getupvalue(require(game.ReplicatedStorage.Shared.Modules.WeaponReplication).AddToList, 1)) do
                if tostring(v) == 'ActiveMap' or tostring(v) == 'GlobalMapItems' or tostring(v) == 'Perks' then
                    table.remove(getupvalue(require(game.ReplicatedStorage.Shared.Modules.WeaponReplication).AddToList, 1), i)
                end
            end
        end
    end
end)

Frame1:AddToggle('Inf Stamina', function(v1) -- inf stamina
    _settings.inf_stamina = v1
end)

local sequences = { 
    current_sequence = 'Default';

    ['Red'] = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0)),
        ColorSequenceKeypoint.new(1, Color3.new(1, 0, 0))
    };
    ['Green'] = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.new(0, 1, 0)),
        ColorSequenceKeypoint.new(1, Color3.new(0, 1, 0))
    };
    ['Blue'] = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.new(0, 0, 1)),
        ColorSequenceKeypoint.new(1, Color3.new(0, 0, 1))
    };
}
Frame1:AddSwitch('Bullet Color', {'Default', 'Red', 'Green', 'Blue'}, function(v1)
    if v1 ~= 'Default' then
        for i,v in pairs(sequences) do
            if i == v1 then
                sequences.current_sequence = v
                
                if _client.InGame then            
                    _plr.PlayerScripts.WeaponClient.Disabled = true
                    _plr.PlayerScripts.WeaponClient.Disabled = false
                end

                updateClient()

                return
            end
        end
    end
    sequences.current_sequence = 'Default'
    
    if _client.InGame then
        _plr.PlayerScripts.WeaponClient.Disabled = true
        _plr.PlayerScripts.WeaponClient.Disabled = false
    end

    updateClient()
end)

Frame1:AddBox('Sprint Speed', function(v1) -- sprint speed
    _client.sprint_speed = tonumber(v1) or 22
end)

local jump_height = _plr.Character.Humanoid.JumpHeight
Frame1:AddBox('Jump Multiplier', function(v1) -- jump power
    _plr.Character.Humanoid.JumpHeight = jump_height*(tonumber(v1) or 1)
end)

-- // Library 2 Buttons // --
Frame2 = library:AddFrame({name = 'Environment Cheats'})

Frame2:AddButton('Kill All Zombies', function() -- kill zombies
    if _client.InGame then
        for i,v in pairs(_zombies:GetChildren()) do
            KillZombie(v)
        end
    end  
end)

Frame2:AddToggle('Loop Kill Zombies', function(v1) -- loopkill
    _settings.loop_kill = v1
    if v1 and _client.InGame then
        for i,v in pairs(_zombies:GetChildren()) do
            KillZombie(v)
        end
    end  
end)

Frame2:AddToggle('Anchor Zombies', function(v1) -- anchor zombies
    _settings.zombies_anchored = v1
    for i,v in pairs(_zombies:GetChildren()) do
        if v:FindFirstChild('HumanoidRootPart') then
            v.HumanoidRootPart.Anchored = v1
        end
    end
end)

Frame2:AddToggle('Disable Barriers', function(v1) -- anchor zombies
    for i,v in pairs(game:GetService('CollectionService'):GetTagged('InvisibleWall')) do
        v.CanCollide = not v1
        v.Transparency = v1 and 0.9 or not v1 and 1
    end
end)

local head_size = 1
Frame2:AddBox('Zombie Head Size', function(v1) -- zombie hitbox
    head_size = tonumber(v1) or 1
    for i,v in pairs(_zombies:GetChildren()) do
        if v:FindFirstChild('Head') then
            v.Head.CanCollide = false
            wait()
            v.Head.Size = Vector3.new(1,1,1)*head_size 
            if v.Head:FindFirstChild('Mesh') then
                v.Head.Mesh.Scale = Vector3.new(1,1,1)*head_size
            end
        end
    end
end)

local grav = tonumber(game.Workspace.Gravity)
Frame2:AddBox('Gravity Multiplier', function(v1) -- gravity
    game.Workspace.Gravity = grav*(tonumber(v1) or 1)
end)

-- // Hooks // --
spawn(function()
    weapon_hook = hookfunc(require(game.ReplicatedStorage.Shared.Modules.WeaponReplication).GetSettings, function(...) -- gun stats
        if getgenv().gun_mods == true then
            return {
                BULLET_SPEED = 2000;
                BULLETS_PER_SHOT = 15;
                BULLET_MAXDIST = 100000;
                MAX_BULLET_SPREAD_ANGLE = 0;
                FIRE_DELAY = 0.05;
                MIN_BULLET_SPREAD_ANGLE = 0;
                BULLET_GRAVITY = Vector3.new();
            }
        end
        return weapon_hook(...)
    end)
end)
spawn(function()
    bullet_hook = hookfunc(require(game.ReplicatedStorage.Shared.Modules.PartCache).GetPart, function(...) -- bullet lag
        local args = {...}
        
        if _settings.gun_mods then
            args[1].CurrentCacheParent:ClearAllChildren()
        end

        return bullet_hook(unpack(args))
    end)
end)


--// Metatables //--
m = getrawmetatable(game)
oldindex = m.__index
oldnc = m.__namecall

setreadonly(m, false)

m.__index = function(t, k)


    if tostring(t) == 'OriginalSize' and k == 'Value' and (tostring(t:FindFirstAncestorWhichIsA('Part')) == 'Head' or tostring(t:FindFirstAncestorWhichIsA('MeshPart')) == 'Head') then
        return Vector3.new(1,1,1)*head_size
    end

    return oldindex(t, k)
end

m.__namecall = function(self, ...)
    local args = {...}
    if getnamecallmethod() == 'SetAttribute' then -- set inf stamina
        
        if args[1] == 'Stamina' and _settings.inf_stamina then
            args[2] = 100  
        end

    elseif getnamecallmethod() == 'GetAttribute' then

        if _settings.gun_mods then  -- gun mods

            if args[1] == 'Ammo' or args[1] == 'MaxMagAmmo' or args[1] == 'ReserveAmmo' then
                return math.huge
            end
            if args[1] == 'FireType' then
                return 'FullAuto'
            end

        end

        if args[1] == 'BulletBeamColor' and tostring(sequences.current_sequence) ~= 'Default' then
            return sequences.current_sequence
        end

    elseif getnamecallmethod() == 'FireServer' then

        if (args[1] == 'TouchedZombie' or args[1] == 'HitPipeBomb') and _settings.god_mode then -- god mode
            return
        end


    elseif getnamecallmethod() == 'SetCore' then

        local custom_hints = {
            'Enjoy the script';
            'Check out my other scripts on v3rmillion @Sinsane';
            'For any questions message me on discord @jaames#9911';
            'Boring ass game';
            'New UI coming soon';
            'Dont forget to vouch/upvote';
            'Dont feel bad these kids are losers';
        }

        if args[1] == 'ChatMakeSystemMessage' and args[2]['Text']:find('HINT') then -- custom hints
            args[2]['Text'] = '[SINSANE] '..custom_hints[math.random(1, #custom_hints)]
            args[2]['Color'] = Color3.fromRGB(115, 80, 146)
        end
        
    end

    return oldnc(self, unpack(args))
end

-- // Client Update // --
_plr.PlayerScripts.ChildAdded:connect(function(z)
    wait(0.05)
    if z.Name == 'WeaponClient' then
        updateClient()
    end
end)

_game.ActiveMap.ChildAdded:connect(function(z)
    if _settings.gun_mods then
        wait(0.05)
        for i,v in pairs(getupvalue(require(game.ReplicatedStorage.Shared.Modules.WeaponReplication).AddToList, 1)) do
            if tostring(v) == 'ActiveMap' or tostring(v) == 'GlobalMapItems' or tostring(v) == 'Perks' then
                table.remove(getupvalue(require(game.ReplicatedStorage.Shared.Modules.WeaponReplication).AddToList, 1), i)
            end
        end
        wait(0.05)
        require(game.ReplicatedStorage.Shared.Modules.WeaponReplication).AddToList(game.Workspace.Game.ActiveMap)
        require(game.ReplicatedStorage.Shared.Modules.WeaponReplication).AddToList(game.Workspace.Game.GlobalMapItems)
        require(game.ReplicatedStorage.Shared.Modules.WeaponReplication).AddToList(game.Workspace.Game.Perks)
        print('wallhacks updated for new map')
    end
end)

-- // Zombie Editor // --
_zombies.ChildAdded:connect(function(z)
    z:WaitForChild('HumanoidRootPart')
    z:WaitForChild('Head')
    z.Head:WaitForChild('OriginalSize')

    if _settings.loop_kill and _client.InGame then -- kill on spawn
        KillZombie(z)
    else -- edit on spawn
        z.HumanoidRootPart.Anchored = _settings.zombies_anchored
        z.Head.CanCollide = false
        wait()
        z.Head.Size = z.Head.Size*head_size
        if z.Head:FindFirstChild('Mesh') then
            z.Head.Mesh.Scale = z.Head.Mesh.Scale*head_size
        end
    end
end)

updateClient()

-- // Loops // --
_plr:GetAttributeChangedSignal('IsInGame'):connect(function()
    _client.InGame = _plr:GetAttribute('IsInGame')
    updateClient()
end)
spawn(function()
    while wait() do
        if _client.movement and _client.sprint_speed then
            _client.movement.Sprinting = _client.sprint_speed
        end
    end
end)
spawn(function() -- lag reduce
    while wait(1) do
        _bullets:ClearAllChildren()
    end
end)
