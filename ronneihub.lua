-- ============================================================================
--  RONNEI HUB - BEST PET TRACKER (CHỈ GIỮ BẢNG BESTPET)
--  PHIÊN BẢN: 5.0.0 (GHÉP VÀO TAB AUTO STEAL)
-- ============================================================================

local TweenService = game:GetService("TweenService")
local CoreGui = (gethui and gethui()) or game:GetService("CoreGui")
local LocalPlayer = game:GetService("Players").LocalPlayer

-- ================== PHẦN 1: BẢNG MÀU ==================
local THEME = {
    Background    = Color3.fromRGB(28, 31, 42),
    Secondary     = Color3.fromRGB(38, 42, 56),
    Accent        = Color3.fromRGB(0, 230, 120),
    Stroke        = Color3.fromRGB(75, 83, 110),
    ToggleOn      = Color3.fromRGB(0, 230, 118),
    ToggleOff     = Color3.fromRGB(46, 50, 66),
    TextMain      = Color3.fromRGB(255, 255, 255),
    TextSub       = Color3.fromRGB(195, 202, 220),
    Font          = Enum.Font.GothamMedium,
    FontBold      = Enum.Font.GothamBold
}

-- Bảng màu theo độ hiếm
local RARITY_COLORS = {
    ["Common"] = Color3.fromRGB(150, 150, 150),
    ["Uncommon"] = Color3.fromRGB(50, 200, 50),
    ["Rare"] = Color3.fromRGB(50, 100, 255),
    ["Epic"] = Color3.fromRGB(150, 50, 255),
    ["Legendary"] = Color3.fromRGB(255, 150, 50),
    ["Mythic"] = Color3.fromRGB(255, 50, 150),
    ["Cosmic"] = Color3.fromRGB(100, 255, 255),
    ["Secret"] = Color3.fromRGB(255, 215, 0),
    ["Eternal"] = Color3.fromRGB(200, 50, 200),
    ["Divine"] = Color3.fromRGB(255, 200, 100)
}

-- ================== PHẦN 2: QUÉT PET TỪ GAME ==================
local function scanPets()
    local petData = {}
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    -- Quét các vị trí có thể chứa pet
    local targets = {
        LocalPlayer.leaderstats,
        LocalPlayer.PlayerGui,
        LocalPlayer.Character,
        workspace,
        game:GetService("ReplicatedStorage")
    }
    
    for _, target in ipairs(targets) do
        if target then
            for _, child in pairs(target:GetChildren()) do
                local name = child.Name
                if name:find("Pet") or name:find("Egg") then
                    local rarity = "Unknown"
                    local image = "rbxassetid://125111940452696"
                    
                    -- Tìm rarity
                    for _, sub in pairs(child:GetChildren()) do
                        if sub.Name:find("Rarity") then
                            if sub:IsA("TextLabel") or sub:IsA("StringValue") then
                                local r = sub.Value or sub.Text
                                if r and r ~= "" then
                                    rarity = r
                                    break
                                end
                            end
                        end
                        -- Tìm ảnh
                        if sub:IsA("ImageLabel") and sub.Image ~= "" then
                            image = sub.Image
                        end
                    end
                    
                    table.insert(petData, {
                        name = name,
                        rarity = rarity,
                        image = image,
                        tier = RARITY_WEIGHT[rarity] or 0
                    })
                end
            end
        end
    end
    
    return petData
end

-- ================== PHẦN 3: RARITY WEIGHT ==================
local RARITY_WEIGHT = {
    ["Common"] = 1,
    ["Uncommon"] = 2,
    ["Rare"] = 3,
    ["Epic"] = 4,
    ["Legendary"] = 5,
    ["Mythic"] = 6,
    ["Cosmic"] = 7,
    ["Secret"] = 8,
    ["Eternal"] = 9,
    ["Divine"] = 10
}

-- ================== PHẦN 4: TÌM HUB CHÍNH ==================
local function findHub()
    local containers = {CoreGui}
    if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
        table.insert(containers, LocalPlayer.PlayerGui)
    end
    if gethui then table.insert(containers, gethui()) end
    
    for _, container in ipairs(containers) do
        for _, child in ipairs(container:GetChildren()) do
            local isHub = false
            pcall(function()
                for _, d in ipairs(child:GetDescendants()) do
                    if d:IsA("TextLabel") and (d.Text:find("BK's Hub") or d.Text:find("Auto Steal") or d.Text:find("Ronnei Hub")) then
                        isHub = true
                        break
                    end
                end
            end)
            if isHub then
                return child
            end
        end
    end
    return nil
end

-- ================== PHẦN 5: THÊM BESTPET VÀO TAB AUTO STEAL ==================
local function addBestPetToTab(hub)
    if not hub then return end
    
    -- Tìm tab Auto Steal
    local autoStealTab = nil
    for _, child in ipairs(hub:GetDescendants()) do
        if child:IsA("TextButton") and child.Text:find("Auto Steal") then
            autoStealTab = child
            break
        end
    end
    
    if not autoStealTab then return end
    
    -- Tìm frame chứa tab
    local tabFrame = autoStealTab.Parent
    if not tabFrame then return end
    
    -- Tìm nội dung của tab Auto Steal
    local contentFrame = nil
    for _, child in ipairs(tabFrame:GetDescendants()) do
        if child:IsA("Frame") and child.Visible == true and child.AbsoluteSize.X > 200 then
            contentFrame = child
            break
        end
    end
    
    if not contentFrame then return end
    
    -- ====== TẠO BEST PET SECTION ======
    local bestPetFrame = Instance.new("Frame", contentFrame)
    bestPetFrame.Name = "RonneiBestPetSection"
    bestPetFrame.Size = UDim2.new(1, -20, 0, 80)
    bestPetFrame.Position = UDim2.new(0, 10, 0, 10)
    bestPetFrame.BackgroundColor3 = THEME.Secondary
    bestPetFrame.BackgroundTransparency = 0.3
    bestPetFrame.BorderSizePixel = 0
    bestPetFrame.ClipsDescendants = true
    
    local corner = Instance.new("UICorner", bestPetFrame)
    corner.CornerRadius = UDim.new(0, 8)
    
    -- Border
    local border = Instance.new("UIStroke", bestPetFrame)
    border.Color = THEME.Stroke
    border.Thickness = 1
    border.Transparency = 0.3
    
    -- Title
    local title = Instance.new("TextLabel", bestPetFrame)
    title.Size = UDim2.new(1, -20, 0, 24)
    title.Position = UDim2.new(0, 10, 0, 4)
    title.Text = "🏆 PET TỐT NHẤT"
    title.TextColor3 = THEME.TextMain
    title.TextSize = 14
    title.Font = THEME.FontBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1
    
    -- Divider
    local divider = Instance.new("Frame", bestPetFrame)
    divider.Size = UDim2.new(1, -20, 0, 1)
    divider.Position = UDim2.new(0, 10, 0, 30)
    divider.BackgroundColor3 = THEME.Stroke
    divider.BackgroundTransparency = 0.5
    
    -- Pet avatar
    local avatarFrame = Instance.new("Frame", bestPetFrame)
    avatarFrame.Size = UDim2.new(0, 44, 0, 44)
    avatarFrame.Position = UDim2.new(0, 10, 0, 34)
    avatarFrame.BackgroundColor3 = Color3.fromRGB(38, 42, 56)
    avatarFrame.BorderSizePixel = 0
    avatarFrame.ClipsDescendants = true
    
    local avatarCorner = Instance.new("UICorner", avatarFrame)
    avatarCorner.CornerRadius = UDim.new(0, 6)
    
    local petImage = Instance.new("ImageLabel", avatarFrame)
    petImage.Name = "PetImage"
    petImage.Size = UDim2.new(1, -4, 1, -4)
    petImage.Position = UDim2.new(0, 2, 0, 2)
    petImage.BackgroundTransparency = 1
    petImage.Image = "rbxassetid://125111940452696"
    petImage.ScaleType = Enum.ScaleType.Fit
    
    -- Pet info
    local petName = Instance.new("TextLabel", bestPetFrame)
    petName.Name = "PetName"
    petName.Size = UDim2.new(0.5, 0, 0, 22)
    petName.Position = UDim2.new(0, 62, 0, 34)
    petName.Text = "Đang tìm..."
    petName.TextColor3 = THEME.TextMain
    petName.TextSize = 15
    petName.Font = THEME.FontBold
    petName.TextXAlignment = Enum.TextXAlignment.Left
    petName.BackgroundTransparency = 1
    
    local petRarity = Instance.new("TextLabel", bestPetFrame)
    petRarity.Name = "PetRarity"
    petRarity.Size = UDim2.new(0.5, 0, 0, 20)
    petRarity.Position = UDim2.new(0, 62, 0, 56)
    petRarity.Text = "✨ Unknown"
    petRarity.TextColor3 = THEME.TextSub
    petRarity.TextSize = 12
    petRarity.Font = THEME.Font
    petRarity.TextXAlignment = Enum.TextXAlignment.Left
    petRarity.BackgroundTransparency = 1
    
    -- Refresh button
    local refreshBtn = Instance.new("TextButton", bestPetFrame)
    refreshBtn.Size = UDim2.new(0, 50, 0, 24)
    refreshBtn.Position = UDim2.new(1, -60, 0, 32)
    refreshBtn.Text = "⟳ Làm mới"
    refreshBtn.TextColor3 = THEME.TextMain
    refreshBtn.TextSize = 11
    refreshBtn.Font = THEME.Font
    refreshBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
    refreshBtn.BorderSizePixel = 0
    refreshBtn.AutoButtonColor = false
    
    local refreshCorner = Instance.new("UICorner", refreshBtn)
    refreshCorner.CornerRadius = UDim.new(0, 4)
    
    refreshBtn.MouseButton1Click:Connect(function()
        refreshBtn.Text = "⟳ Đang tải..."
        refreshBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 50)
        task.delay(0.5, function()
            refreshBestPet()
            refreshBtn.Text = "⟳ Làm mới"
            refreshBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
        end)
    end)
    
    -- ====== BIẾN LƯU PET TỐT NHẤT ======
    local currentBestPet = {
        name = "Chưa có",
        rarity = "Unknown",
        image = "rbxassetid://125111940452696",
        tier = 0
    }
    
    -- ====== HÀM LÀM MỚI ======
    local function refreshBestPet()
        local pets = scanPets()
        local best = nil
        
        for _, pet in ipairs(pets) do
            if not best or pet.tier > best.tier then
                best = pet
            end
        end
        
        if best then
            currentBestPet = best
            petName.Text = best.name
            petRarity.Text = "✨ " .. best.rarity
            petRarity.TextColor3 = RARITY_COLORS[best.rarity] or THEME.TextSub
            if best.image and best.image ~= "" then
                petImage.Image = best.image
            end
        else
            petName.Text = "Chưa có pet"
            petRarity.Text = "✨ Unknown"
            petRarity.TextColor3 = THEME.TextSub
            petImage.Image = "rbxassetid://125111940452696"
        end
    end
    
    -- ====== VÒNG LẶP CẬP NHẬT ======
    task.spawn(function()
        while true do
            pcall(refreshBestPet)
            task.wait(1.5)
        end
    end)
    
    print("[Ronnei] ✅ Đã thêm Best Pet vào tab Auto Steal!")
end

-- ================== PHẦN 6: CHỜ HUB LOAD ==================
task.spawn(function()
    local hub = nil
    local attempts = 0
    
    while attempts < 20 do
        hub = findHub()
        if hub then
            -- Đợi hub load đầy đủ
            task.wait(2)
            pcall(addBestPetToTab, hub)
            break
        end
        attempts = attempts + 1
        task.wait(1)
    end
    
    if not hub then
        print("[Ronnei] ⚠️ Không tìm thấy hub, thử tìm lại...")
        -- Thử lại sau 5 giây
        task.wait(5)
        hub = findHub()
        if hub then
            pcall(addBestPetToTab, hub)
        end
    end
end)

-- ================== PHẦN 7: KHÔNG LOAD LENNONHUB ==================
-- Script này KHÔNG load script LennonHub
-- Chỉ thêm bảng BestPet vào tab Auto Steal

-- ================== PHẦN 8: THÔNG BÁO ==================
print([[
╔═══════════════════════════════════════════╗
║  RONNEI BEST PET v5.0.0                  ║
║  🏆 Chỉ thêm bảng BestPet vào Auto Steal ║
║  ❌ KHÔNG load script LennonHub          ║
║  🔄 Tự động cập nhật mỗi 1.5 giây       ║
╚═══════════════════════════════════════════╝
]])
