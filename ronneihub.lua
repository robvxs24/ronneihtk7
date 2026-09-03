-- ==============================================================================
--  RONNEI HUB - HIGH CONTRAST + AUTO TOGGLE HOOK + BRIGHT THEME + FULL VN
-- ==============================================================================

local TweenService = game:GetService("TweenService")
local CoreGui = (gethui and gethui()) or game:GetService("CoreGui")
local LocalPlayer = game:GetService("Players").LocalPlayer

-- 1. Khởi chạy script gốc từ Loader Luarmor
task.spawn(function()
    pcall(function()
        loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/9ee4edde227ac85f50872bf9e4226508.lua"))()
    end)
end)

local NEW_NAME = "Ronnei Hub"
local NEW_IMAGE = "rbxassetid://125111940452696"

getgenv().RonneiTranslateVN = false

-- 2. Cấu hình bảng màu sáng sủa, độ tương phản cao (High-Contrast Slate Theme)
local THEME = {
    Background = Color3.fromRGB(28, 31, 42),       -- Nền chính sáng hơn, có chiều sâu
    Secondary  = Color3.fromRGB(38, 42, 56),       -- Khối container/item nổi bật rõ ràng
    Accent     = Color3.fromRGB(0, 230, 120),      -- Xanh neon chủ đạo
    Stroke     = Color3.fromRGB(75, 83, 110),      -- Viền khung sắc nét, rõ biên giới
    
    -- Trạng thái Toggle dứt khoát
    ToggleOn      = Color3.fromRGB(0, 230, 118),   -- BẬT: Xanh Emerald sáng rực rỡ
    ToggleOnGlow  = Color3.fromRGB(100, 255, 180), -- Viền sáng bổ trợ khi Bật
    ToggleOff     = Color3.fromRGB(46, 50, 66),    -- TẮT: Xám graphite gọn gàng
    KnobOn        = Color3.fromRGB(255, 255, 255),  -- Trắng tinh khi Bật
    KnobOff       = Color3.fromRGB(145, 152, 172), -- Xám bạc khi Tắt
    
    -- Chữ hiển thị
    TextMain   = Color3.fromRGB(255, 255, 255),    -- Trắng sáng 100% cho tiêu đề
    TextSub    = Color3.fromRGB(195, 202, 220),    -- Bạc sáng rõ ràng cho mô tả
    Font       = Enum.Font.GothamMedium,
    FontBold   = Enum.Font.GothamBold
}

-- 3. Kiểm tra giá trị động (tránh dịch đè làm lỗi hiển thị số liệu)
local function isDynamicValue(txt)
    if not txt or txt == "" then return true end
    local low = txt:lower()
    
    if low:find("fps") or low:find("ms") or low:find("ping") then return true end
    if txt:match("^%s*[%$]?%d+[%d%.]*%s*[a-zA-Z%%/%$]*%s*$") then return true end
    if txt:match("%d+%s*studs/s") or txt:match("%d+%%") or txt:match("%d+%s*pages") then return true end
    if txt:match("%d+m%s*%d+s") or txt:match("%d+:%d+") then return true end
    
    return false
end

-- 4. Từ điển dịch tiếng Việt
local fullTransTable = {
    -- Sidebar / Tabs
    ["Monster"] = "Quái vật", ["Auto Steal"] = "Tự động trộm", ["Filters"] = "Bộ lọc",
    ["Plot"] = "Khu đất", ["Server"] = "Máy chủ", ["Misc"] = "Tính năng phụ",
    ["Webhook"] = "Webhook", ["Settings"] = "Cài đặt",
    
    -- Danh mục & Headers
    ["EVENT"] = "SỰ KIỆN", ["STEALING"] = "TRỘM TRỨNG", ["YOUR STUFF"] = "ĐỒ CỦA BẠN",
    ["CONFIG"] = "CẤU HÌNH", ["SELLING"] = "BÁN VẬT PHẨM", ["TREADMILL TRAINING"] = "LUYỆN TẬP MÁY CHẠY",
    ["AUTOMATE IT"] = "TỰ ĐỘNG HÓA", ["TARGETING"] = "MỤC TIÊU", ["SPEED"] = "TỐC ĐỘ",
    ["YOUR MONSTER"] = "QUÁI VẬT CỦA BẠN", ["WHAT NOT TO FEED"] = "KHÔNG NÊN CHO ĂN",
    ["WHICH SERVERS"] = "CHỌN MÁY CHỦ", ["APPEARANCE"] = "GIAO DIỆN", ["KEYBINDS"] = "PHÍM TẮT",
    ["RIGHT NOW"] = "NGAY BÂY GIỜ", ["WHERE TO LOOK"] = "NƠI TÌM KIẾM", ["WHAT QUALIFIES"] = "ĐIỀU KIỆN HỢP LỆ",
    ["EGGS & PETS"] = "TRỨNG & THÚ CƯNG", ["UPGRADES"] = "NÂNG CẤP", ["SERVER HOPPER"] = "TỰ ĐỔI MÁY CHỦ",
    ["FLIGHT"] = "BAY LƯỢN", ["PERFORMANCE"] = "HIỆU NĂNG", ["CONNECTION"] = "KẾT NỐI",
    ["GLOBAL FEED"] = "BẢNG TIN TOÀN CẦU", ["WHAT TO SEND"] = "LOẠI DỮ LIỆU GỬI",
    ["HOW MUCH NOISE"] = "MỨC ĐỘ THÔNG BÁO", ["THE MESSAGE"] = "NỘI DUNG TIN NHẮN", ["WINDOW"] = "CỬA SỔ",

    -- Các câu mô tả chức năng
    ["your Filters tab decides what counts, then takes the most valuable one that does"] = "tab Bộ lọc quyết định điều kiện, sau đó lấy quả giá trị nhất khớp lọc",
    ["IN PLAY: all areas · no other limits"] = "ĐANG CHẠY: tất cả khu vực · không giới hạn khác",
    ["IN PLAY: all areas - no other limits"] = "ĐANG CHẠY: tất cả khu vực · không giới hạn khác",
    ["not used by this mode — switch to Rarity snipe to use it"] = "không dùng ở chế độ này — chuyển sang Bắn tỉa độ hiếm để dùng",
    ["not used by this mode - switch to Rarity snipe to use it"] = "không dùng ở chế độ này — chuyển sang Bắn tỉa độ hiếm để dùng",
    ["not used by this mode — switch to Gen ($/s) snipe to use it"] = "không dùng ở chế độ này — chuyển sang Bắn tỉa Gen ($/s) để dùng",
    ["not used by this mode - switch to Gen ($/s) snipe to use it"] = "không dùng ở chế độ này — chuyển sang Bắn tỉa Gen ($/s) để dùng",
    ["move fast enough to reach every area, including the ones you are nowhere near unlocking"] = "di chuyển siêu tốc đến mọi khu vực, kể cả nơi chưa mở khóa",
    ["how fast you travel - very high values get you pulled back, so it eases down on its own"] = "tốc độ di chuyển — chỉnh quá cao sẽ bị giật lùi, script sẽ tự hãm lại",
    ["how fast you travel — very high values get you pulled back, so it eases down on its own"] = "tốc độ di chuyển — chỉnh quá cao sẽ bị giật lùi, script sẽ tự hãm lại",
    ["If nothing matches, take the best anyway"] = "Nếu không khớp lọc, vẫn lấy quả tốt nhất",
    ["when nothing fits your filters, take the most valuable egg out there instead of waiting"] = "khi không có trứng hợp bộ lọc, lấy quả đắt nhất thay vì chờ đợi",
    ["What to take"] = "Loại cần lấy",
    ["Best value"] = "Giá trị cao nhất",
    ["Rarity snipe"] = "Bắn tỉa độ hiếm",
    ["Gen ($/s) snipe"] = "Bắn tỉa Gen ($/s)",
    ["Rarity snipe floor"] = "Độ hiếm tối thiểu",
    ["Gen ($/s) snipe floor"] = "Mức Gen ($/s) tối thiểu",
    ["Bypassed Speed"] = "Vượt tốc độ tối đa",
    ["Bypassed speed cap"] = "Vượt tốc độ tối đa cap",

    -- Tab Quái vật
    ["Feed him one"] = "Cho quái ăn 1 quả", ["Feed"] = "Cho ăn",
    ["Claim the chest"] = "Nhận rương quái", ["Claim"] = "Nhận rương",
    ["Belly"] = "Bụng quái vật", ["Refresh"] = "Làm mới",
    ["Auto Hunt Infested Eggs"] = "Tự săn trứng nhiễm", ["Auto Feed"] = "Tự cho ăn",
    ["Auto Claim Chest"] = "Tự nhận rương", ["Keep infested eggs for him"] = "Giữ trứng cho quái",
    ["Never feed this rarity or rarer"] = "Không cho ăn độ hiếm này trở lên", ["Feed anything"] = "Cho ăn tất cả",
    ["takes the Monster Chest the moment he hits 100%"] = "nhận Rương Quái ngay khi đạt 100%",
    ["waits till theres nothing left worth stealing, then walks over and feeds"] = "đợi hết trứng ngon rồi tự đi cho ăn",
    ["Auto Steal picks up infested eggs as well as ur normal targets"] = "Tự động nhặt cả trứng nhiễm bệnh và mục tiêu thường",
    ["anything matching ur own filters still comes first - it grabs the good egg, then carries on hunting"] = "ưu tiên trứng khớp bộ lọc trước - nhặt trứng ngon rồi mới săn tiếp",
    ["anything matching ur own filters still comes first — it grabs the good egg, then carries on hunting"] = "ưu tiên trứng khớp bộ lọc trước - nhặt trứng ngon rồi mới săn tiếp",
    ["stops Auto-Place putting them on ur plot and Auto-Sell selling them"] = "chặn tự đặt lên đất và tự bán chúng",
    ["turn this off and ur fuel gets planted or sold behind ur back"] = "tắt đi sẽ khiến trứng bị đặt hoặc bán mất",
    ["feeding destroys the egg, so it always picks ur least valuable one"] = "cho ăn sẽ làm mất trứng, luôn chọn quả rẻ nhất",

    -- Tab Bộ lọc
    ["Matching right now"] = "Đang khớp điều kiện",
    ["Use rarity filter"] = "Lọc theo độ hiếm", ["Use mutation filter"] = "Lọc theo đột biến",
    ["Minimum weight (Kg)"] = "Trọng lượng tối thiểu (Kg)", ["Clear all"] = "Bỏ chọn tất cả",
    ["easiest first - you can reach all of them, so this is purely what you want - applies in every mode"] = "ưu tiên nơi dễ nhất - bạn có thể đến mọi nơi, tùy bạn chọn - áp dụng mọi chế độ",
    ["an egg counts if it is one of these"] = "trứng hợp lệ nếu thuộc một trong các loại này",
    ["an egg counts if it carries one of these"] = "trứng hợp lệ nếu mang một trong các đột biến này",
    ["Forest"] = "Rừng xanh", ["Lake"] = "Hồ nước", ["Desert"] = "Sa mạc",
    ["Jungle"] = "Rừng rậm", ["Snow"] = "Vùng tuyết", ["Volcano"] = "Núi lửa",
    ["Abyss Ocean"] = "Vực biển sâu", ["Prehistoric"] = "Tiền sử",

    -- Tab Máy chủ
    ["Auto Hop"] = "Tự động đổi server", ["Hop now"] = "Đổi server ngay", ["Hop"] = "Đổi ngay",
    ["How hard to look"] = "Độ sâu tìm server", ["Skip full servers"] = "Bỏ qua server đầy",
    ["Reload hub after hopping"] = "Nạp lại hub sau khi đổi", ["Fewest players"] = "Ít người nhất",
    ["Most players"] = "Đông người nhất",
    ["Hop after a while anyway"] = "Đổi server sau một khoảng thời gian",
    ["leave for another server straight away"] = "chuyển sang server khác ngay lập tức",
    ["a full server will just bounce you straight back out"] = "server đầy sẽ khiến bạn bị văng ra ngoài",

    -- Tab Cài đặt
    ["Import settings"] = "Nhập cài đặt", ["Import"] = "Nhập",
    ["Reset position & size"] = "Đặt lại vị trí & cỡ", ["Reset"] = "Đặt lại",
    ["Export settings"] = "Xuất cài đặt", ["UI scale"] = "Tỷ lệ giao diện",
    ["Theme"] = "Màu giao diện", ["Open / close the hub"] = "Mở / đóng hub",
    ["Toggle flight"] = "Bật / tắt bay", ["Start minimised"] = "Thu nhỏ khi chạy",
    ["Search settings..."] = "Tìm kiếm cài đặt...", ["Copy"] = "Sao chép",

    -- Độ hiếm
    ["Common"] = "Thường", ["Uncommon"] = "Không phổ biến", ["Rare"] = "Hiếm",
    ["Epic"] = "Sử thi", ["Legendary"] = "Huyền thoại", ["Mythic"] = "Thần thoại",
    ["Cosmic"] = "Vũ trụ", ["Secret"] = "Bí mật", ["Eternal"] = "Vĩnh hằng", ["Divine"] = "Thần thánh"
}

local sortedKeys = {}
for k in pairs(fullTransTable) do table.insert(sortedKeys, k) end
table.sort(sortedKeys, function(a, b) return #a > #b end)

local function safeReplace(text, target, replacement)
    local startIdx, endIdx = string.find(text, target, 1, true)
    if startIdx then
        return string.sub(text, 1, startIdx - 1) .. replacement .. string.sub(text, endIdx + 1)
    end
    return text
end

-- 5. Module can thiệp Toggle gốc (Ép hiển thị BẬT/TẮT siêu tương phản)
local function hookToggleElement(track)
    if track:GetAttribute("ToggleHooked") then return end

    -- Tìm con trượt (Knob hình tròn) bên trong Track
    local knob = nil
    for _, child in ipairs(track:GetChildren()) do
        if child:IsA("GuiObject") and math.abs(child.AbsoluteSize.X - child.AbsoluteSize.Y) <= 10 and child.AbsoluteSize.X >= 8 and child.AbsoluteSize.X < track.AbsoluteSize.X then
            knob = child
            break
        end
    end

    if not knob then return end
    track:SetAttribute("ToggleHooked", true)

    local stroke = track:FindFirstChild("ToggleStroke")
    if not stroke then
        stroke = Instance.new("UIStroke")
        stroke.Name = "ToggleStroke"
        stroke.Thickness = 1.2
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Parent = track
    end

    local updating = false
    local function updateVisual()
        if updating then return end
        updating = true

        local trackWidth = track.AbsoluteSize.X
        local knobX = knob.Position.X.Offset + (knob.Position.X.Scale * trackWidth)
        -- Knob nằm quá 35% chiều rộng -> Trạng thái BẬT
        local isOn = knobX > (trackWidth * 0.35) or knob.Position.X.Scale > 0.4

        track.BackgroundColor3 = isOn and THEME.ToggleOn or THEME.ToggleOff
        knob.BackgroundColor3 = isOn and THEME.KnobOn or THEME.KnobOff
        stroke.Color = isOn and THEME.ToggleOnGlow or THEME.Stroke
        stroke.Transparency = isOn and 0 or 0.2

        updating = false
    end

    updateVisual()

    -- Bắt sự kiện khi người dùng click bật/tắt để đổi màu ngay lập tức
    knob:GetPropertyChangedSignal("Position"):Connect(updateVisual)
    track:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
        if not updating then updateVisual() end
    end)
end

-- 6. Áp dụng phong cách đồ họa sáng sủa & font chữ sắc nét
local function applyModernVisuals(obj)
    if obj:GetAttribute("IsLangToggle") then return end

    -- 6.1. Nhận diện nút gạt Toggle gốc (Kích thước chuẩn dạng viên thuốc)
    if (obj:IsA("Frame") or obj:IsA("GuiButton")) and not obj:GetAttribute("ToggleHooked") then
        local sz = obj.AbsoluteSize
        if sz.X >= 26 and sz.X <= 65 and sz.Y >= 14 and sz.Y <= 32 and sz.X > (sz.Y * 1.2) then
            hookToggleElement(obj)
            return
        end
    end

    if obj:GetAttribute("RestyledModern") then return end
    obj:SetAttribute("RestyledModern", true)

    -- 6.2. Nâng cấp Panel & Khung chứa
    if obj:IsA("Frame") then
        if obj.BackgroundTransparency < 0.9 then
            if obj.AbsoluteSize.X >= 280 and obj.AbsoluteSize.Y >= 180 then
                obj.BackgroundColor3 = THEME.Background
            else
                obj.BackgroundColor3 = THEME.Secondary
            end

            if not obj:FindFirstChildOfClass("UIStroke") and obj.AbsoluteSize.X > 20 then
                local stroke = Instance.new("UIStroke")
                stroke.Color = THEME.Stroke
                stroke.Thickness = 1.2
                stroke.Transparency = 0.1
                stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                stroke.Parent = obj
            end

            if not obj:FindFirstChildOfClass("UICorner") and obj.AbsoluteSize.X > 20 then
                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(0, 7)
                corner.Parent = obj
            end
        end

    -- 6.3. Tối ưu văn bản: Chữ lớn/Tiêu đề trắng tinh 100%, chú thích màu bạc sáng
    elseif obj:IsA("TextLabel") then
        if obj.TextSize >= 13 then
            obj.Font = THEME.FontBold
            obj.TextColor3 = THEME.TextMain
        else
            obj.Font = THEME.Font
            obj.TextColor3 = THEME.TextSub
        end

    -- 6.4. Nút bấm thông thường (Không phải Toggle)
    elseif obj:IsA("TextButton") or obj:IsA("ImageButton") then
        if obj:IsA("TextButton") then
            obj.Font = THEME.FontBold
            obj.TextColor3 = THEME.TextMain
        end

        if not obj:FindFirstChildOfClass("UICorner") and obj.AbsoluteSize.X > 15 then
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 6)
            corner.Parent = obj
        end

        local origColor = obj.BackgroundColor3
        obj.MouseEnter:Connect(function()
            if obj.BackgroundTransparency < 0.9 and not obj:GetAttribute("ToggleHooked") then
                TweenService:Create(obj, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
                    BackgroundColor3 = THEME.Accent
                }):Play()
            end
        end)

        obj.MouseLeave:Connect(function()
            if obj.BackgroundTransparency < 0.9 and not obj:GetAttribute("ToggleHooked") then
                TweenService:Create(obj, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
                    BackgroundColor3 = origColor
                }):Play()
            end
        end)
    end
end

-- 7. Bộ điều phối chính kết hợp Dịch thuật + Nút gạt ngôn ngữ
task.spawn(function()
    local searchReplaced = false

    while true do
        pcall(function()
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
                            if d:IsA("TextLabel") and (d.Text:find("BK's Hub") or d.Text:find("Steal An Egg") or d.Text:find(NEW_NAME)) then
                                isHub = true
                                break
                            end
                        end
                    end)

                    if isHub then
                        for _, desc in ipairs(child:GetDescendants()) do
                            pcall(applyModernVisuals, desc)

                            -- 7.1. Xử lý dịch thuật
                            if desc:IsA("TextLabel") or desc:IsA("TextButton") then
                                local txt = desc.Text

                                if txt == "BK's Hub" or txt == "BKs Hub" then
                                    desc.Text = NEW_NAME
                                elseif txt:lower():find("discord") or txt:lower():find("bkshub") then
                                    desc.Text = ""
                                    desc.Visible = false
                                elseif txt == "B" or txt == "b" then
                                    local p = desc.Parent
                                    if p and p:IsA("GuiObject") and p.AbsoluteSize.X <= 65 then
                                        desc.Visible = false
                                    end
                                else
                                    if not desc:GetAttribute("IsLangToggle") and not isDynamicValue(txt) then
                                        if not desc:GetAttribute("OriginalText") and txt ~= "" then
                                            desc:SetAttribute("OriginalText", txt)
                                        end

                                        local original = desc:GetAttribute("OriginalText") or txt

                                        if getgenv().RonneiTranslateVN then
                                            if fullTransTable[original] then
                                                desc.Text = fullTransTable[original]
                                            else
                                                local translatedText = original
                                                for _, en in ipairs(sortedKeys) do
                                                    if string.find(translatedText, en, 1, true) then
                                                        translatedText = safeReplace(translatedText, en, fullTransTable[en])
                                                    end
                                                end
                                                desc.Text = translatedText
                                            end
                                        else
                                            if desc:GetAttribute("OriginalText") then
                                                desc.Text = desc:GetAttribute("OriginalText")
                                            end
                                        end
                                    end
                                end
                            elseif desc:IsA("TextBox") then
                                local pl = desc.PlaceholderText
                                if not desc:GetAttribute("OrigPlaceholder") and pl ~= "" then
                                    desc:SetAttribute("OrigPlaceholder", pl)
                                end
                                local origPl = desc:GetAttribute("OrigPlaceholder") or pl
                                if getgenv().RonneiTranslateVN then
                                    desc.PlaceholderText = fullTransTable[origPl] or origPl
                                else
                                    if desc:GetAttribute("OrigPlaceholder") then
                                        desc.PlaceholderText = desc:GetAttribute("OrigPlaceholder")
                                    end
                                end
                            end
                        end

                        -- 7.2. Thay thế Avatar
                        for _, img in ipairs(child:GetDescendants()) do
                            if img:IsA("ImageLabel") or img:IsA("ImageButton") then
                                local sz = img.AbsoluteSize
                                if sz.X >= 20 and sz.X <= 65 and math.abs(sz.X - sz.Y) <= 8 then
                                    local name = img.Name:lower()
                                    if not (name:find("check") or name:find("arrow") or name:find("close") or name:find("exit") or name:find("slider")) then
                                        if img.Image ~= NEW_IMAGE then
                                            img.Image = NEW_IMAGE
                                        end
                                    end
                                end
                            end
                        end

                        -- 7.3. Tích hợp thanh chuyển đổi ngôn ngữ
                        local mainFrame = nil
                        for _, f in ipairs(child:GetDescendants()) do
                            if f:IsA("Frame") and f.AbsoluteSize.X >= 300 and f.AbsoluteSize.Y >= 200 then
                                mainFrame = f
                                break
                            end
                        end

                        if mainFrame and not searchReplaced then
                            for _, obj in ipairs(mainFrame:GetDescendants()) do
                                local isSearch = false
                                if obj:IsA("TextBox") and (obj.PlaceholderText:find("Search settings") or obj.Text:find("Search settings")) then
                                    isSearch = true
                                elseif obj:IsA("TextLabel") and obj.Text:find("Search settings") then
                                    isSearch = true
                                end

                                if isSearch then
                                    local searchBarContainer = obj.Parent
                                    if searchBarContainer and not searchBarContainer:FindFirstChild("RonneiLangModule") then
                                        obj.Visible = false
                                        if obj:IsA("TextBox") then obj.TextEditable = false end
                                        for _, sibling in ipairs(searchBarContainer:GetChildren()) do
                                            if sibling:IsA("ImageLabel") or sibling:IsA("TextLabel") or sibling:IsA("TextBox") then
                                                sibling.Visible = false
                                            end
                                        end

                                        local langModule = Instance.new("Frame", searchBarContainer)
                                        langModule.Name = "RonneiLangModule"
                                        langModule.Size = UDim2.new(1, 0, 1, 0)
                                        langModule.BackgroundTransparency = 1
                                        langModule.ZIndex = 40

                                        local langLabel = Instance.new("TextLabel", langModule)
                                        langLabel.Name = "LangLabel"
                                        langLabel.Size = UDim2.new(1, -55, 1, 0)
                                        langLabel.Position = UDim2.new(0, 12, 0, 0)
                                        langLabel.Text = "ON = Tiếng Việt | OFF = English"
                                        langLabel.Font = THEME.FontBold
                                        langLabel.TextSize = 11
                                        langLabel.TextColor3 = THEME.TextMain
                                        langLabel.TextXAlignment = Enum.TextXAlignment.Left
                                        langLabel.BackgroundTransparency = 1
                                        langLabel.ZIndex = 41
                                        langLabel:SetAttribute("IsLangToggle", true)

                                        local sw = Instance.new("TextButton", langModule)
                                        sw.Size = UDim2.new(0, 42, 0, 22)
                                        sw.Position = UDim2.new(1, -50, 0.5, 0)
                                        sw.AnchorPoint = Vector2.new(0, 0.5)
                                        sw.BackgroundColor3 = getgenv().RonneiTranslateVN and THEME.ToggleOn or THEME.ToggleOff
                                        sw.Text = ""
                                        sw.AutoButtonColor = false
                                        sw.ZIndex = 41
                                        sw:SetAttribute("IsLangToggle", true)

                                        local swStroke = Instance.new("UIStroke", sw)
                                        swStroke.Color = getgenv().RonneiTranslateVN and THEME.ToggleOnGlow or THEME.Stroke
                                        swStroke.Thickness = 1.2

                                        Instance.new("UICorner", sw).CornerRadius = UDim.new(1, 0)

                                        local knob = Instance.new("Frame", sw)
                                        knob.Size = UDim2.new(0, 16, 0, 16)
                                        knob.Position = getgenv().RonneiTranslateVN and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
                                        knob.AnchorPoint = Vector2.new(0, 0.5)
                                        knob.BackgroundColor3 = getgenv().RonneiTranslateVN and THEME.KnobOn or THEME.KnobOff
                                        knob.BorderSizePixel = 0
                                        knob.ZIndex = sw.ZIndex + 1
                                        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

                                        sw.MouseButton1Click:Connect(function()
                                            getgenv().RonneiTranslateVN = not getgenv().RonneiTranslateVN
                                            local active = getgenv().RonneiTranslateVN
                                            sw.BackgroundColor3 = active and THEME.ToggleOn or THEME.ToggleOff
                                            swStroke.Color = active and THEME.ToggleOnGlow or THEME.Stroke
                                            knob.BackgroundColor3 = active and THEME.KnobOn or THEME.KnobOff
                                            knob.Position = active and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
                                        end)

                                        searchReplaced = true
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
        task.wait(0.35)
    end
end)
