-- ==============================================================================
--  RONNEI HUB - ZERO STARTUP FLASH + EVENT-DRIVEN NO-LAG + LIVE BEST PET FIXED
-- ==============================================================================
local TS = game:GetService("TweenService")
local CG = (gethui and gethui()) or game:GetService("CoreGui")
local LP = game:GetService("Players").LocalPlayer
local NEW_NAME = "Ronnei Hub"
local NEW_IMG = "rbxassetid://125111940452696"

getgenv().RonneiTranslateVN = false

-- 1. BẢNG MÀU TƯƠNG PHẢN CAO
local T = {
    BG = Color3.fromRGB(28, 31, 42), Sec = Color3.fromRGB(38, 42, 56), Acc = Color3.fromRGB(0, 230, 120),
    Strk = Color3.fromRGB(75, 83, 110), TG_On = Color3.fromRGB(0, 230, 118), TG_Off = Color3.fromRGB(46, 50, 66),
    TG_Glow = Color3.fromRGB(100, 255, 180), KB_On = Color3.fromRGB(255, 255, 255), KB_Off = Color3.fromRGB(145, 152, 172),
    TxtM = Color3.fromRGB(255, 255, 255), TxtS = Color3.fromRGB(195, 202, 220), F_M = Enum.Font.GothamMedium, F_B = Enum.Font.GothamBold
}

local mountedPetCard = nil
local function isInsidePet(o)
    return mountedPetCard and (o == mountedPetCard or o:IsDescendantOf(mountedPetCard))
end

-- 2. ĐẶT BẪY CHẶN GIAO DIỆN LENNON TRƯỚC KHI TẢI (CHỐNG HIỆN FLASH MENU)
local function interceptLennonGui(gui)
    if not gui:IsA("ScreenGui") or gui.Name == "RonneiHub" then return end
    local function process(d)
        if not d:IsA("GuiObject") or isInsidePet(d) then return end
        local n = d.Name:lower()
        if n:find("logo") or n:find("topbar") or n:find("header") or n:find("teleport") or n:find("reset") then
            d.Visible = false
        end
        if d:IsA("TextLabel") or d:IsA("TextButton") then
            local txt = d.Text:upper()
            if txt:find("LENNON") or txt:find("TOP 4") or txt:find("TELEPORT") or txt:find("RESET GUI") then
                d.Visible = false
                if d.Parent and d.Parent:IsA("GuiObject") and not isInsidePet(d.Parent) then
                    if txt:find("LENNON HUB") or txt:find("TOP 4") or txt:find("TELEPORT") then
                        d.Parent.Visible = false
                    end
                end
            end
        end
    end
    gui.DescendantAdded:Connect(process)
    for _, d in ipairs(gui:GetDescendants()) do process(d) end
end

local containers = {CG}
if LP and LP:FindFirstChild("PlayerGui") then table.insert(containers, LP.PlayerGui) end
if gethui then table.insert(containers, gethui()) end

for _, c in ipairs(containers) do
    c.ChildAdded:Connect(interceptLennonGui)
    for _, g in ipairs(c:GetChildren()) do interceptLennonGui(g) end
end

-- 3. KHỞI CHẠY 2 SCRIPT
task.spawn(function() pcall(function() loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/9ee4edde227ac85f50872bf9e4226508.lua"))() end) end)
task.spawn(function() pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/lennonxscripts/lennonhub/main/stealaegg.lua"))() end) end)

-- 4. BỘ DỊCH THUẬT TOÀN DIỆN
local function isPureMetric(t)
    if not t or t == "" then return true end
    local l = t:lower()
    return l:find("fps") or l:find("ms") or l:find("ping") or t:match("^%s*[%$]?%d+[%d%.]*%s*[a-zA-Z%%/%$]*%s*$")
        or t:match("%d+%s*studs/s") or t:match("%d+%%") or t:match("%d+m%s*%d+s") or t:match("%d+:%d+")
end

local function transDynamic(t)
    return t:gsub("Idle","Đang chờ"):gsub("idle","đang chờ"):gsub("Banked","Đã cất"):gsub("banked","đã cất")
        :gsub("Lost","Mất"):gsub("lost","mất"):gsub("Re%-grabs","Nhặt lại"):gsub("re%-grabs","nhặt lại")
        :gsub("Placed","Đã đặt"):gsub("placed","đã đặt"):gsub("Hatched","Đã nở"):gsub("hatched","đã nở")
        :gsub("going for (.+) Egg","Đang săn Trứng %1"):gsub("banked (.+) Egg","Đã cất Trứng %1")
        :gsub("not training","đang nghỉ"):gsub("earned","kiếm được"):gsub("this session","phiên này")
        :gsub("quietened","đã giảm tải"):gsub("effects","hiệu ứng"):gsub("(%d+)%s*pages","%1 trang")
        :gsub("up to (%d+) servers","quét tới %1 server")
end

local Dict = {
    ["Monster"]="Quái vật",["Auto Steal"]="Tự động trộm",["Filters"]="Bộ lọc",["Plot"]="Khu đất",["Server"]="Máy chủ",
    ["Misc"]="Tính năng phụ",["Webhook"]="Webhook",["Settings"]="Cài đặt",["EVENT"]="SỰ KIỆN",["STEALING"]="TRỘM TRỨNG",
    ["YOUR STUFF"]="ĐỒ CỦA BẠN",["CONFIG"]="CẤU HÌNH",["SELLING"]="BÁN VẬT PHẨM",["TREADMILL TRAINING"]="LUYỆN TẬP MÁY CHẠY",
    ["AUTOMATE IT"]="TỰ ĐỘNG HÓA",["TARGETING"]="MỤC TIÊU",["SPEED"]="TỐC ĐỘ",["YOUR MONSTER"]="QUÁI VẬT CỦA BẠN",
    ["WHAT NOT TO FEED"]="KHÔNG NÊN CHO ĂN",["WHICH SERVERS"]="CHỌN MÁY CHỦ",["APPEARANCE"]="GIAO DIỆN",["KEYBINDS"]="PHÍM TẮT",
    ["RIGHT NOW"]="NGAY BÂY GIỜ",["WHERE TO LOOK"]="NƠI TÌM KIẾM",["WHAT QUALIFIES"]="ĐIỀU KIỆN HỢP LỆ",["EGGS & PETS"]="TRỨNG & THÚ CƯNG",
    ["UPGRADES"]="NÂNG CẤP",["SERVER HOPPER"]="TỰ ĐỔI MÁY CHỦ",["FLIGHT"]="BAY LƯỢN",["PERFORMANCE"]="HIỆU NĂNG",["CONNECTION"]="KẾT NỐI",
    ["GLOBAL FEED"]="BẢNG TIN TOÀN CẦU",["WHAT TO SEND"]="LOẠI DỮ LIỆU GỬI",["HOW MUCH NOISE"]="MỨC ĐỘ THÔNG BÁO",["THE MESSAGE"]="NỘI DUNG TIN NHẮN",
    ["WINDOW"]="CỬA SỔ",["EGGS ON THE MAP"]="TRỨNG TRÊN BẢN ĐỒ",["EGGS ON YOUR PLOT"]="TRỨNG TRÊN ĐẤT CỦA BẠN",["STATS PANEL"]="BẢNG THỐNG KÊ",
    ["Auto Place Eggs"]="Tự động đặt trứng",["Never place this rarity or rarer"]="Không đặt từ độ hiếm này trở lên",
    ["keeps your best eggs in the bag instead of committing them to a hatch timer"]="giữ trứng xịn nhất trong túi thay vì đưa vào thời gian đếm ấp",
    ["place everything"]="Đặt tất cả",["Only place eggs worth ($/s)"]="Chỉ đặt trứng có giá trị ($/s)",
    ["the pen has limited room, so it fills with your best eggs first · blank for any"]="chuồng có chỗ giới hạn, ưu tiên đặt trứng ngon nhất · để trống để chọn mọi quả",
    ["the pen has limited room, so it fills with your best eggs first - blank for any"]="chuồng có chỗ giới hạn, ưu tiên đặt trứng ngon nhất · để trống để chọn mọi quả",
    ["Auto Hatch"]="Tự động ấp nở",["hatches every egg the moment its timer is up"]="tự mở tất cả trứng ngay khi hết thời gian ấp",
    ["Auto Equip Best Pets"]="Tự trang bị pet xịn nhất",
    ["keeps your best pets out at all times — hatch something better and it swaps, even when your pen is full"]="luôn dùng pet mạnh nhất — mở ra con tốt hơn sẽ tự thay thế kể cả khi chuồng đầy",
    ["keeps your best pets out at all times - hatch something better and it swaps, even when your pen is full"]="luôn dùng pet mạnh nhất — mở ra con tốt hơn sẽ tự thay thế kể cả khi chuồng đầy",
    ["Auto Upgrade Trails"]="Tự nâng cấp vệt sáng (Trails)",["What selling will never touch"]="Những thứ không bao giờ bị bán",
    ["favourited · equipped · in the fuse machine · in the pen · placed on your plot"]="yêu thích · đang trang bị · trong máy ghép · trong chuồng · đặt trên đất",
    ["Sell anything earning under ($/s)"]="Bán mọi thứ kiếm dưới ($/s)",
    ["required — nothing is sold while this is blank · type 250k, 1.5m or 2b"]="bắt buộc — không bán gì nếu để trống · gõ 250k, 1.5m hoặc 2b",
    ["required - nothing is sold while this is blank · type 250k, 1.5m or 2b"]="bắt buộc — không bán gì nếu để trống · gõ 250k, 1.5m hoặc 2b",
    ["Auto Sell Pets"]="Tự động bán thú cưng",["sells the worst ones first, and only below the floor above"]="bán con yếu nhất trước, và chỉ bán dưới mức sàn ở trên",
    ["Auto Sell Eggs"]="Tự động bán trứng",["spare eggs only · anything on your plot is never touched"]="chỉ bán trứng thừa · không bao giờ đụng đến trứng trên đất",
    ["Train when Auto Steal is off"]="Tập khi tắt Tự động trộm",["Train when Tự động trộm is off"]="Tập khi tắt Tự động trộm",
    ["on = trains whenever there is nothing worth stealing"]="bật = tập luyện bất cứ khi nào không có gì đáng trộm",
    ["Auto Hop"]="Tự động đổi server",["Hop now"]="Đổi server ngay",["Hop"]="Đổi ngay",["How hard to look"]="Độ sâu tìm server",
    ["Skip full servers"]="Bỏ qua server đầy",["Reload hub after hopping"]="Nạp lại hub sau khi đổi",
    ["turn off if your autoexec already loads the hub in every server"]="tắt nếu autoexec của bạn đã tự nạp hub khi vào server",
    ["Fewest players"]="Ít người nhất",["Most players"]="Đông người nhất",["Hop after a while anyway"]="Đổi server sau một khoảng thời gian",
    ["leave for another server straight away"]="chuyển sang server khác ngay lập tức",["a full server will just bounce you straight back out"]="server đầy sẽ khiến bạn bị văng ra ngoài",
    ["pages of the server list to collect, 100 servers each · Roblox rate limits this, so more pages takes longer"]="số trang server cần quét, 100 server mỗi trang · Roblox giới hạn tốc độ, quét nhiều trang sẽ lâu hơn",
    ["skip servers emptier than this · blank for any"]="bỏ qua server vắng hơn mức này · để trống để chọn mọi server",
    ["skip servers busier than this · fewer players means less competition for the same eggs · blank for any"]="bỏ qua server đông hơn mức này · ít người chơi hơn giúp giảm cạnh tranh · để trống cho mọi server",
    ["Egg ESP"]="ESP Trứng",["each egg's $/s, rarity, weight and mutations floating over it · no distance limit"]="hiển thị $/s, độ hiếm, trọng lượng và đột biến trên quả · không giới hạn cự ly",
    ["Show ESP on"]="Hiển thị ESP cho",["\"matching my filters\" tracks whatever Auto Steal is set to"]="\"khớp bộ lọc\" theo dõi mục tiêu theo thiết lập Tự động trộm",
    ["\"matching my filters\" tracks whatever Tự động trộm is set to"]="\"khớp bộ lọc\" theo dõi mục tiêu theo thiết lập Tự động trộm",
    ["Eggs matching..."]="Trứng khớp bộ lọc...",["Beam to current target"]="Tia dẫn đường tới mục tiêu",
    ["draws a line to the egg Auto Steal picked · easy to lose among fifty cards otherwise"]="kẻ tia chỉ đường tới quả trứng đã chọn · tránh bị lạc giữa hàng tá quả",
    ["draws a line to the egg Tự động trộm picked · easy to lose among fifty cards otherwise"]="kẻ tia chỉ đường tới quả trứng đã chọn · tránh bị lạc giữa hàng tá quả",
    ["Plot Egg ESP"]="ESP Trứng trên đất",["Khu đất Egg ESP"]="ESP Trứng trên đất",
    ["your placed eggs: what each will pay, and the hatch timer · green when ready"]="trứng đã đặt: thu nhập mỗi quả mang lại và thời gian ấp · màu xanh khi sẵn sàng nở",
    ["Show Stats Panel"]="Hiện bảng thống kê",["small draggable panel: money income, eggs banked, best egg so far"]="bảng kéo thả: thu nhập, số trứng đã cất, quả xịn nhất",
    ["WASD to fly, space up, Left Ctrl down · holds its altitude when you let go"]="WASD để bay, Space bay lên, Ctrl trái hạ xuống · giữ nguyên độ cao khi thả phím",
    ["Flight speed"]="Tốc độ bay",["studs per second while flying"]="studs mỗi giây khi đang bay",["Flight keybind"]="Phím tắt bay",
    ["Unbound"]="Chưa gán",["toggles flight without opening the hub"]="bật / tắt bay mà không cần mở hub",["Game optimizer"]="Tối ưu hóa game",
    ["Cap the frame rate"]="Khóa tốc độ khung hình (FPS)",
    ["a low frame rate breaks Bypassed Speed — you get pulled back instead of moving faster, so auto steal gets slower the lower you go"]="FPS thấp làm lỗi Vượt tốc độ — bạn sẽ bị kéo giật lùi, FPS càng thấp trộm càng chậm",
    ["a low frame rate breaks Vượt tốc độ tối đa — you get pulled back instead of moving faster, so auto steal gets slower the lower you go"]="FPS thấp làm lỗi Vượt tốc độ tối đa — bạn sẽ bị kéo giật lùi, FPS càng thấp trộm càng chậm",
    ["a low frame rate breaks Vượt tốc độ tối đa - you get pulled back instead of moving faster, so auto steal gets slower the lower you go"]="FPS thấp làm lỗi Vượt tốc độ tối đa — bạn sẽ bị kéo giật lùi, FPS càng thấp trộm càng chậm",
    ["FPS cap"]="Giới hạn FPS",["30 is the lowest — under that the speed bypass stops helping"]="30 là mức thấp nhất — dưới mức đó việc vượt tốc độ sẽ mất tác dụng",
    ["30 is the lowest - under that the speed bypass stops helping"]="30 là mức thấp nhất — dưới mức đó việc vượt tốc độ sẽ mất tác dụng",
    ["Webhook URL"]="Đường dẫn Webhook",["your channel -> Edit -> Integrations -> Webhooks -> Sao chép URL · sends a test message"]="kênh của bạn -> Sửa kênh -> Tích hợp -> Webhooks -> Sao chép URL · gửi tin thử nghiệm",
    ["your channel → Edit → Integrations → Webhooks → Sao chép URL · sends a test message"]="kênh của bạn -> Sửa kênh -> Tích hợp -> Webhooks -> Sao chép URL · gửi tin thử nghiệm",
    ["Share my rare pulls"]="Chia sẻ trứng hiếm nhặt được",["What gets shared"]="Dữ liệu được chia sẻ",
    ["the exact list, so you never have to take our word for it"]="danh sách dữ liệu chính xác, minh bạch",["Show"]="Xem",["Preview"]="Xem trước",
    ["Egg stolen"]="Khi trộm được trứng",["Egg hatched"]="Khi trứng nở",["Mutation rolled"]="Khi ra đột biến",
    ["Sold pets or eggs"]="Khi bán thú cưng hoặc trứng",["Rewards claimed"]="Khi nhận phần thưởng",["Only eggs earning over ($/s)"]="Chỉ gửi trứng kiếm trên ($/s)",
    ["stolen + hatched only · blank sends everything · type 250k, 1.5m or 2b"]="chỉ trứng trộm + nở · để trống để gửi tất cả · gõ 250k, 1.5m hoặc 2b",
    ["stolen + hatched only - blank sends everything - type 250k, 1.5m or 2b"]="chỉ trứng trộm + nở · để trống để gửi tất cả · gõ 250k, 1.5m hoặc 2b",
    ["everything · e.g. 50m"]="tất cả · vd: 50m",["Rarity floor"]="Mức độ hiếm sàn",["this rarity and rarer · stolen + hatched only"]="độ hiếm này trở lên · chỉ tính trứng trộm + nở",
    ["this rarity and rarer - stolen + hatched only"]="độ hiếm này trở lên · chỉ tính trứng trộm + nở",["Session digest"]="Báo cáo tóm tắt phiên chơi",
    ["a running total every so often, whatever else is switched on"]="gửi bảng tổng kết định kỳ các thông số thu hoạch",["Ping"]="Tag nhắc tên",
    ["No ping"]="Không tag",["@everyone only works if the webhook channel allows it"]="@everyone chỉ hoạt động nếu quyền hạn kênh cho phép",
    ["Include my username"]="Kèm tên tài khoản Roblox",["puts your Roblox name in the footer · off keeps every message anonymous"]="hiện tên Roblox của bạn ở chân tin nhắn · tắt để ẩn danh",
    ["puts your Roblox name in the footer - off keeps every message anonymous"]="hiện tên Roblox của bạn ở chân tin nhắn · tắt để ẩn danh",
    ["Let exported configs carry the URL"]="Cho phép xuất cấu hình kèm URL Webhook",
    ["off (recommended) — then a config you share cannot give away your channel"]="tắt (khuyên dùng) — tránh bị lộ liên kết webhook khi chia sẻ cài đặt",
    ["off (recommended) - then a config you share cannot give away your channel"]="tắt (khuyên dùng) — tránh bị lộ liên kết webhook khi chia sẻ cài đặt",
    ["Any"]="Bất kỳ",["your Filters tab decides what counts, then takes the most valuable one that does"]="tab Bộ lọc quyết định điều kiện, sau đó lấy quả giá trị nhất khớp lọc",
    ["IN PLAY: all areas · no other limits"]="ĐANG CHẠY: tất cả khu vực · không giới hạn khác",["IN PLAY: all areas - no other limits"]="ĐANG CHẠY: tất cả khu vực · không giới hạn khác",
    ["not used by this mode — switch to Rarity snipe to use it"]="không dùng ở chế độ này — chuyển sang Bắn tỉa độ hiếm để dùng",
    ["not used by this mode - switch to Rarity snipe to use it"]="không dùng ở chế độ này — chuyển sang Bắn tỉa độ hiếm để dùng",
    ["not used by this mode — switch to Gen ($/s) snipe to use it"]="không dùng ở chế độ này — chuyển sang Bắn tỉa Gen ($/s) để dùng",
    ["not used by this mode - switch to Gen ($/s) snipe to use it"]="không dùng ở chế độ này — chuyển sang Bắn tỉa Gen ($/s) để dùng",
    ["move fast enough to reach every area, including the ones you are nowhere near unlocking"]="di chuyển siêu tốc đến mọi khu vực, kể cả nơi chưa mở khóa",
    ["how fast you travel - very high values get you pulled back, so it eases down on its own"]="tốc độ di chuyển — chỉnh quá cao sẽ bị giật lùi, script sẽ tự hãm lại",
    ["how fast you travel — very high values get you pulled back, so it eases down on its own"]="tốc độ di chuyển — chỉnh quá cao sẽ bị giật lùi, script sẽ tự hãm lại",
    ["What to take"]="Loại cần lấy",["Best value"]="Giá trị cao nhất",["Rarity snipe"]="Bắn tỉa độ hiếm",["Gen ($/s) snipe"]="Bắn tỉa Gen ($/s)",
    ["Rarity snipe floor"]="Độ hiếm tối thiểu",["Gen ($/s) snipe floor"]="Mức Gen ($/s) tối thiểu",["Bypassed Speed"]="Vượt tốc độ tối đa",
    ["Bypassed speed cap"]="Vượt tốc độ tối đa cap",["Feed him one"]="Cho quái ăn 1 quả",["Feed"]="Cho ăn",["Claim the chest"]="Nhận rương quái",
    ["Claim"]="Nhận rương",["Belly"]="Bụng quái vật",["Refresh"]="Làm mới",["Auto Hunt Infested Eggs"]="Tự săn trứng nhiễm",["Auto Feed"]="Tự cho ăn",
    ["Auto Claim Chest"]="Tự nhận rương",["Keep infested eggs for him"]="Giữ trứng cho quái",["Never feed this rarity or rarer"]="Không cho ăn độ hiếm này trở lên",
    ["Feed anything"]="Cho ăn tất cả",["takes the Monster Chest the moment he hits 100%"]="nhận Rương Quái ngay khi đạt 100%",
    ["waits till theres nothing left worth stealing, then walks over and feeds"]="đợi hết trứng ngon rồi tự đi cho ăn",
    ["Auto Steal picks up infested eggs as well as ur normal targets"]="Tự động nhặt cả trứng nhiễm bệnh và mục tiêu thường",
    ["anything matching ur own filters still comes first - it grabs the good egg, then carries on hunting"]="ưu tiên trứng khớp bộ lọc trước - nhặt trứng ngon rồi mới săn tiếp",
    ["anything matching ur own filters still comes first — it grabs the good egg, then carries on hunting"]="ưu tiên trứng khớp bộ lọc trước - nhặt trứng ngon rồi mới săn tiếp",
    ["stops Auto-Place putting them on ur plot and Auto-Sell selling them"]="chặn tự đặt lên đất và tự bán chúng",
    ["turn this off and ur fuel gets planted or sold behind ur back"]="tắt đi sẽ khiến trứng bị đặt hoặc bán mất",
    ["feeding destroys the egg, so it always picks ur least valuable one"]="cho ăn sẽ làm mất trứng, luôn chọn quả rẻ nhất",
    ["Matching right now"]="Đang khớp điều kiện",["Use rarity filter"]="Lọc theo độ hiếm",["Use mutation filter"]="Lọc theo đột biến",
    ["Minimum weight (Kg)"]="Trọng lượng tối thiểu (Kg)",["Clear all"]="Bỏ chọn tất cả",["Import settings"]="Nhập cài đặt",["Import"]="Nhập",
    ["Reset position & size"]="Đặt lại vị trí & cỡ",["Reset"]="Đặt lại",["Export settings"]="Xuất cài đặt",["UI scale"]="Tỷ lệ giao diện",
    ["Theme"]="Màu giao diện",["Open / close the hub"]="Mở / đóng hub",["Start minimised"]="Thu nhỏ khi chạy",["Search settings..."]="Tìm kiếm cài đặt...",
    ["Copy"]="Sao chép",["Forest"]="Rừng xanh",["Lake"]="Hồ nước",["Desert"]="Sa mạc",["Jungle"]="Rừng rậm",["Snow"]="Vùng tuyết",
    ["Volcano"]="Núi lửa",["Abyss Ocean"]="Vực biển sâu",["Prehistoric"]="Tiền sử",["Common"]="Thường",["Uncommon"]="Không phổ biến",
    ["Rare"]="Hiếm",["Epic"]="Sử thi",["Legendary"]="Huyền thoại",["Mythic"]="Thần thoại",["Cosmic"]="Vũ trụ",["Secret"]="Bí mật",
    ["Eternal"]="Vĩnh hằng",["Divine"]="Thần thánh"
}

local sortedKeys = {}
for k in pairs(Dict) do table.insert(sortedKeys, k) end
table.sort(sortedKeys, function(a, b) return #a > #b end)

-- 5. HOOK TOGGLE HIỆN ĐẠI
local function hookToggle(track)
    if track:GetAttribute("ToggleHooked") or isInsidePet(track) then return end
    local knob
    for _, c in ipairs(track:GetChildren()) do
        if c:IsA("GuiObject") and not c:IsA("UIStroke") and not c:IsA("UICorner") and c.Name ~= "ToggleStroke" and math.abs(c.AbsoluteSize.X - c.AbsoluteSize.Y) <= 12 then
            knob = c; break
        end
    end
    if not knob then return end
    track:SetAttribute("ToggleHooked", true)
    local stroke = track:FindFirstChild("ToggleStroke") or Instance.new("UIStroke", track)
    stroke.Name, stroke.Thickness, stroke.ApplyStrokeMode = "ToggleStroke", 1.2, Enum.ApplyStrokeMode.Border

    local updating = false
    local function updateVisual()
        if updating then return end
        updating = true
        local w = track.AbsoluteSize.X
        if w > 0 and knob then
            local on = (knob.AbsolutePosition.X - track.AbsolutePosition.X) > (w * 0.28)
            track.BackgroundColor3 = on and T.TG_On or T.TG_Off
            knob.BackgroundColor3 = on and T.KB_On or T.KB_Off
            stroke.Color = on and T.TG_Glow or T.Strk
            stroke.Transparency = on and 0 or 0.2
        end
        updating = false
    end
    updateVisual()
    knob:GetPropertyChangedSignal("Position"):Connect(updateVisual)
    track:GetPropertyChangedSignal("BackgroundColor3"):Connect(function() if not updating then updateVisual() end end)
end

-- 6. TÌM CARD BEST PET NGUYÊN BẢN & PHỤC HỒI ĐỒ HỌA 3D (KHÔNG ĐEN HÌNH)
local function getLennonBestPetCard()
    if mountedPetCard and mountedPetCard.Parent then return mountedPetCard end
    for _, cont in ipairs(containers) do
        for _, gui in ipairs(cont:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Name ~= "RonneiHub" and not gui:FindFirstChild("RonneiLangModule", true) then
                for _, d in ipairs(gui:GetDescendants()) do
                    if d:IsA("TextLabel") and d.Text:upper() == "BEST EGG" then
                        local c = d.Parent
                        while c and c.Parent and not c.Parent:IsA("ScreenGui") do
                            local hasImg = false
                            for _, s in ipairs(c:GetDescendants()) do 
                                if s:IsA("ImageLabel") or s:IsA("ViewportFrame") then hasImg = true break end 
                            end
                            if hasImg and c.AbsoluteSize.Y >= 35 and c.AbsoluteSize.Y <= 95 then
                                mountedPetCard = c
                                c:SetAttribute("IsBestPetCard", true)
                                for _, sub in ipairs(c:GetDescendants()) do sub:SetAttribute("IsBestPetCard", true) end
                                return c
                            end
                            c = c.Parent
                        end
                    end
                end
            end
        end
    end
    return nil
end

local function restorePet3DLighting(card)
    if not card then return end
    for _, vf in ipairs(card:GetDescendants()) do
        if vf:IsA("ViewportFrame") then
            vf.BackgroundTransparency = 1
            vf.Ambient = Color3.fromRGB(240, 240, 240)
            vf.LightColor = Color3.fromRGB(255, 255, 255)
            vf.LightDirection = Vector3.new(-1, -1, -1)

            local cam = vf.CurrentCamera
            if not cam or cam.Parent ~= vf then
                cam = vf:FindFirstChildOfClass("Camera") or Instance.new("Camera")
                cam.CameraType = Enum.CameraType.Scriptable
                cam.FieldOfView = 50
                cam.Parent = vf
                vf.CurrentCamera = cam
            end

            local model = vf:FindFirstChildWhichIsA("Model") or vf:FindFirstChildWhichIsA("BasePart")
            if model then
                local cf, sz
                if model:IsA("Model") then cf, sz = model:GetBoundingBox() else cf, sz = model.CFrame, model.Size end
                local maxDim = math.max(sz.X, sz.Y, sz.Z)
                if maxDim < 0.1 then maxDim = 2 end
                cam.CFrame = CFrame.new(cf.Position + Vector3.new(maxDim * 1.3, maxDim * 0.9, maxDim * 1.3), cf.Position)
            end
        elseif vf:IsA("ImageLabel") then
            vf.ImageTransparency = 0
            vf.Visible = true
        end
    end
end

-- 7. LÀM ĐẸP GIAO DIỆN (CHỈ CHẠY 1 LẦN CHO MỖI PHẦN TỬ - KHÔNG GÂY LAG MENU)
local function applyVisualOnce(o)
    if o:GetAttribute("RonneiReady") or isInsidePet(o) or o:GetAttribute("IsLangToggle") then return end
    o:SetAttribute("RonneiReady", true)

    if (o:IsA("Frame") or o:IsA("GuiButton")) and not o:GetAttribute("ToggleHooked") then
        local sz = o.AbsoluteSize
        if sz.X >= 26 and sz.X <= 65 and sz.Y >= 14 and sz.Y <= 32 and sz.X > (sz.Y * 1.2) then hookToggle(o); return end
    end

    if o:IsA("Frame") and o.BackgroundTransparency < 0.9 then
        o.BackgroundColor3 = (o.AbsoluteSize.X >= 280 and o.AbsoluteSize.Y >= 180) and T.BG or T.Sec
        if not o:FindFirstChildOfClass("UIStroke") and o.AbsoluteSize.X > 20 then
            local s = Instance.new("UIStroke", o); s.Color, s.Thickness, s.Transparency, s.ApplyStrokeMode = T.Strk, 1.2, 0.1, Enum.ApplyStrokeMode.Border
        end
        if not o:FindFirstChildOfClass("UICorner") and o.AbsoluteSize.X > 20 then
            Instance.new("UICorner", o).CornerRadius = UDim.new(0, 7)
        end
    elseif o:IsA("TextLabel") then
        o.Font, o.TextColor3 = (o.TextSize >= 13) and T.F_B or T.F_M, (o.TextSize >= 13) and T.TxtM or T.TxtS
    elseif o:IsA("TextButton") or o:IsA("ImageButton") then
        if o:IsA("TextButton") then o.Font, o.TextColor3 = T.F_B, T.TxtM end
        if not o:FindFirstChildOfClass("UICorner") and o.AbsoluteSize.X > 15 then Instance.new("UICorner", o).CornerRadius = UDim.new(0, 6) end
        local orig = o.BackgroundColor3
        o.MouseEnter:Connect(function() if o.BackgroundTransparency < 0.9 and not o:GetAttribute("ToggleHooked") then TS:Create(o, TweenInfo.new(0.18), {BackgroundColor3 = T.Acc}):Play() end end)
        o.MouseLeave:Connect(function() if o.BackgroundTransparency < 0.9 and not o:GetAttribute("ToggleHooked") then TS:Create(o, TweenInfo.new(0.18), {BackgroundColor3 = orig}):Play() end end)
    end
end

-- 8. BỘ ĐIỀU PHỐI EVENT-DRIVEN (CHỐNG DELAY, CHỐNG NHẢY GIAO DIỆN)
task.spawn(function()
    local searchDone = false
    local cardMountedPermanently = false
    local hubGui = nil

    while true do
        pcall(function()
            -- Tìm Root Ronnei Hub
            if not hubGui or not hubGui.Parent then
                for _, cont in ipairs(containers) do
                    for _, child in ipairs(cont:GetChildren()) do
                        for _, d in ipairs(child:GetDescendants()) do
                            if d:IsA("TextLabel") and (d.Text:find("BK's Hub") or d.Text:find("Steal An Egg") or d.Text:find(NEW_NAME)) then
                                hubGui = child
                                break
                            end
                        end
                        if hubGui then break end
                    end
                    if hubGui then break end
                end
            end

            if hubGui then
                local bestCard = getLennonBestPetCard()

                -- Áp dụng phong cách làm đẹp cho toàn bộ Hub
                for _, desc in ipairs(hubGui:GetDescendants()) do
                    if not desc:GetAttribute("RonneiReady") then
                        applyVisualOnce(desc)
                    end

                    -- GHIM CỐ ĐỊNH DUY NHẤT 1 LẦN THẺ BEST PET VÀO TRÊN "TỰ ĐỘNG TRỘM"
                    if not cardMountedPermanently and bestCard and desc:IsA("TextLabel") and (desc.Text == "Tự động trộm" or desc.Text == "Auto Steal") and desc.AbsolutePosition.X > 160 then
                        local autoStealRow = desc
                        while autoStealRow.Parent and not autoStealRow.Parent:IsA("ScreenGui") do
                            if autoStealRow.Parent:FindFirstChildOfClass("UIListLayout") then break end
                            autoStealRow = autoStealRow.Parent
                        end
                        local parentList = autoStealRow.Parent
                        if parentList and bestCard.Parent ~= parentList then
                            bestCard.Parent = parentList
                            bestCard.Visible = true
                            bestCard.Active = false
                            bestCard.Draggable = false
                            bestCard.Size = UDim2.new(1, 0, 0, 56)
                            bestCard.Position = UDim2.new(0, 0, 0, 0)
                            bestCard.AnchorPoint = Vector2.new(0, 0)
                            bestCard.BackgroundColor3 = T.Sec

                            -- Ẩn nút v mở rộng của Lennon
                            for _, sub in ipairs(bestCard:GetDescendants()) do
                                if sub:IsA("GuiButton") or (sub:IsA("TextLabel") and (sub.Text == "v" or sub.Text == "V" or sub.Text == "⌄" or sub.Text:find("▼"))) then
                                    sub.Visible = false
                                end
                            end

                            -- Thiết lập thứ tự hiển thị chuẩn xác
                            bestCard.LayoutOrder = (autoStealRow.LayoutOrder or 2) - 1
                            cardMountedPermanently = true
                        end
                    end

                    -- XỬ LÝ DỊCH THUẬT VÀ LIVE TEXT
                    if isInsidePet(desc) then
                        -- Thẻ Pet được cập nhật thời gian thực không qua cache tĩnh
                        if desc:IsA("TextLabel") and getgenv().RonneiTranslateVN then
                            local cur = desc.Text
                            if Dict[cur] then desc.Text = Dict[cur] end
                        end
                    else
                        if desc:IsA("TextLabel") or desc:IsA("TextButton") then
                            local txt = desc.Text
                            if txt == "BK's Hub" or txt == "BKs Hub" then desc.Text = NEW_NAME
                            elseif txt:lower():find("discord") or txt:lower():find("bkshub") then desc.Text = ""; desc.Visible = false
                            elseif (txt == "B" or txt == "b") and desc.Parent and desc.Parent:IsA("GuiObject") and desc.Parent.AbsoluteSize.X <= 65 then desc.Visible = false
                            elseif not desc:GetAttribute("IsLangToggle") and not isPureMetric(txt) then
                                local l = txt:lower()
                                if l:find("placed") or l:find("hatched") or l:find("banked") or l:find("lost") or l:find("re%-grabs") or l:find("idle") or l:find("training") or l:find("quietened") or l:find("going for") or (l:find("pages") and l:find("server")) then
                                    if getgenv().RonneiTranslateVN then desc.Text = transDynamic(txt) end
                                else
                                    if not desc:GetAttribute("OrigText") and txt ~= "" then desc:SetAttribute("OrigText", txt) end
                                    local orig = desc:GetAttribute("OrigText") or txt
                                    if getgenv().RonneiTranslateVN then
                                        if Dict[orig] then desc.Text = Dict[orig]
                                        else
                                            local res = orig
                                            for _, k in ipairs(sortedKeys) do
                                                if res:find(k, 1, true) then
                                                    local s, e = res:find(k, 1, true)
                                                    res = res:sub(1, s - 1) .. Dict[k] .. res:sub(e + 1)
                                                end
                                            end
                                            desc.Text = res
                                        end
                                    else
                                        if desc:GetAttribute("OrigText") then desc.Text = desc:GetAttribute("OrigText") end
                                    end
                                end
                            end
                        elseif desc:IsA("TextBox") then
                            local pl = desc.PlaceholderText
                            if not desc:GetAttribute("OrigPl") and pl ~= "" then desc:SetAttribute("OrigPl", pl) end
                            local orig = desc:GetAttribute("OrigPl") or pl
                            desc.PlaceholderText = getgenv().RonneiTranslateVN and (Dict[orig] or orig) or (desc:GetAttribute("OrigPl") or pl)
                        end
                    end
                end

                -- Bảo dưỡng nguồn sáng 3D ViewportFrame của Pet
                if mountedPetCard then pcall(restorePet3DLighting, mountedPetCard) end

                -- Thay thế Logo Avatar Header (Bảo vệ ảnh Pet)
                for _, img in ipairs(hubGui:GetDescendants()) do
                    if (img:IsA("ImageLabel") or img:IsA("ImageButton")) and not isInsidePet(img) then
                        local sz = img.AbsoluteSize
                        if sz.X >= 20 and sz.X <= 65 and math.abs(sz.X - sz.Y) <= 8 then
                            local n = img.Name:lower()
                            if not (n:find("check") or n:find("arrow") or n:find("close") or n:find("exit") or n:find("slider") or n:find("pet") or n:find("egg")) then
                                local root = hubGui:FindFirstChildWhichIsA("Frame") or hubGui
                                if (img.AbsolutePosition.Y - root.AbsolutePosition.Y) <= 65 and img.Image ~= NEW_IMG then img.Image = NEW_IMG end
                            end
                        end
                    end
                end

                -- Nút chuyển đổi Ngôn ngữ
                local mainF
                for _, f in ipairs(hubGui:GetDescendants()) do if f:IsA("Frame") and f.AbsoluteSize.X >= 300 and f.AbsoluteSize.Y >= 200 then mainF = f; break end end
                if mainF and not searchDone then
                    for _, obj in ipairs(mainF:GetDescendants()) do
                        if (obj:IsA("TextBox") and obj.PlaceholderText:find("Search settings")) or (obj:IsA("TextLabel") and obj.Text:find("Search settings")) then
                            local p = obj.Parent
                            if p and not p:FindFirstChild("RonneiLangModule") then
                                obj.Visible = false
                                for _, sib in ipairs(p:GetChildren()) do if sib:IsA("GuiObject") and sib ~= obj then sib.Visible = false end end
                                local mod = Instance.new("Frame", p); mod.Name, mod.Size, mod.BackgroundTransparency, mod.ZIndex = "RonneiLangModule", UDim2.new(1, 0, 1, 0), 1, 40
                                local lbl = Instance.new("TextLabel", mod); lbl.Size, lbl.Position, lbl.Text, lbl.Font, lbl.TextSize, lbl.TextColor3, lbl.TextXAlignment, lbl.BackgroundTransparency, lbl.ZIndex = UDim2.new(1, -55, 1, 0), UDim2.new(0, 12, 0, 0), "ON = Tiếng Việt | OFF = English", T.F_B, 11, T.TxtM, Enum.TextXAlignment.Left, 1, 41
                                lbl:SetAttribute("IsLangToggle", true)
                                local btn = Instance.new("TextButton", mod); btn.Size, btn.Position, btn.AnchorPoint, btn.BackgroundColor3, btn.Text, btn.AutoButtonColor, btn.ZIndex = UDim2.new(0, 42, 0, 22), UDim2.new(1, -50, 0.5, 0), Vector2.new(0, 0.5), getgenv().RonneiTranslateVN and T.TG_On or T.TG_Off, "", false, 41
                                btn:SetAttribute("IsLangToggle", true); Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
                                local bs = Instance.new("UIStroke", btn); bs.Color, bs.Thickness = getgenv().RonneiTranslateVN and T.TG_Glow or T.Strk, 1.2
                                local kn = Instance.new("Frame", btn); kn.Size, kn.Position, kn.AnchorPoint, kn.BackgroundColor3, kn.BorderSizePixel, kn.ZIndex = UDim2.new(0, 16, 0, 16), getgenv().RonneiTranslateVN and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0), Vector2.new(0, 0.5), getgenv().RonneiTranslateVN and T.KB_On or T.KB_Off, 0, 42
                                Instance.new("UICorner", kn).CornerRadius = UDim.new(1, 0)
                                btn.MouseButton1Click:Connect(function()
                                    getgenv().RonneiTranslateVN = not getgenv().RonneiTranslateVN
                                    local a = getgenv().RonneiTranslateVN
                                    btn.BackgroundColor3 = a and T.TG_On or T.TG_Off
                                    bs.Color = a and T.TG_Glow or T.Strk
                                    kn.BackgroundColor3 = a and T.KB_On or T.KB_Off
                                    kn.Position = a and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
                                end)
                                searchDone = true
                            end
                        end
                    end
                end
            end
        end)
        task.wait(0.3)
    end
end)
