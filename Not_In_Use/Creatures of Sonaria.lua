spawn(function()
    while wait() do
        game.Players.LocalPlayer.RemoteEvent:FireServer("DamageSelf", -999999999)
        for i,v in next, workspace.Water:GetChildren() do
            if v:FindFirstChild("Part") then
                game.Players.LocalPlayer.RemoteEvent:FireServer("drink", v)
            end
        end
        for i,v in next, workspace.Dinosaurs:GetChildren() do
            if v ~= game.Players.LocalPlayer.Character and v:FindFirstChild("HumanoidRootPart") then
                if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).magnitude <= 50 then
                    game.Players.LocalPlayer.RemoteEvent:FireServer("Bite", {[v] = v})
                end
            end
        end
        for i,v in next, game.Players.LocalPlayer.Character.Data:GetChildren() do
            if v.Name:find("Speed") then
                v.Value = 150
            end
        end
        for i,v in next, game.Players.LocalPlayer.Character:GetChildren() do
            if v.Name == "Grabbed" then
                v.Value = false
            end
        end
    end
end)