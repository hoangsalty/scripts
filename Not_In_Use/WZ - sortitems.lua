function DelCosmetics()
    local GuiNames = {
        'Back Cauldron',
        'Slime Head',
        'Dire Boarwolf Mask',
        'Bat Wings',
        'Back Tendrils',
        'Half Mask',
        'Snowman Mask',
        'Christmas Stocking',
        'Reindeer Antlers',
        'Scented Pinecone',
        'Bag Of Snowballs',
        'Turkey Head',
        'Nutcracker',
    }

    local ItemsName = {}
    for i,v in next, require(game.ReplicatedStorage.Shared.Items) do
        if table.find(GuiNames, v.DisplayKey) then
            table.insert(ItemsName, v.Name)
        end
    end
    
    return ItemsName
end

function Amount(name)
    local count = 0
    for i,v in next, game.ReplicatedStorage.Profiles[game.Players.LocalPlayer.Name].Inventory.Cosmetics:GetChildren() do
        if v.Name == name then
            count += 1
        end
    end

    return count
end

function Item()
    for i,v in next, game.ReplicatedStorage.Profiles[game.Players.LocalPlayer.Name].Inventory.Cosmetics:GetChildren() do
        if table.find(DelCosmetics(), v.Name) and Amount(v.Name) > 0 then
            return v
        end
    end
end

repeat task.wait()
    game.ReplicatedStorage.Shared.Inventory.DeleteItem:FireServer(Item())
until not Item() or Amount(Item().Name) == 0