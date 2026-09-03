-- ==============================================================================
--  RONNEI HUB - 100% PRESERVED LOGIC + FIXED PET TEXTURE + PURGED EXTERNAL JUNK
-- ==============================================================================

local TweenService = game:GetService("TweenService")
local CoreGui = (gethui and gethui()) or game:GetService("CoreGui")
local LocalPlayer = game:GetService("Players").LocalPlayer

-- 1. Khởi chạy Script Gốc và Lennon Hub chạy ngầm
task.spawn(function()
    pcall(function()
        loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/9ee4edde227ac85f50872bf9e4226508.lua"))()
    end)
end)

task.spawn(function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/lennonxscripts/lennonhub/main/stealaegg.lua"))()
    end)
end)

local NEW_NAME = "Ronnei Hub"
local NEW_IMAGE = "rbxassetid://125111940452696"

getgenv().RonneiTranslateVN = false

-- 2. Bảng màu tương phản cao (High-Contrast Slate Theme)
local THEME = {
    Background    = Color3.fromRGB(28, 31, 42),
    Secondary     = Color3.fromRGB(38, 42, 56),
    Accent        = Color3.fromRGB(0, 230, 120),
    Stroke        = Color3.fromRGB(75, 83, 110),
    
    ToggleOn      = Color3.fromRGB(0, 230, 118),
    ToggleOnGlow  = Color3.fromRGB(100, 255, 180),
    ToggleOff     = Color3.fromRGB(46, 50, 66),
    KnobOn        = Color3.fromRGB(255, 255, 255),
    KnobOff       = Color3.fromRGB(145, 152, 172),
    
    TextMain      = Color3.fromRGB(255, 255, 255),
    TextSub       = Color3.fromRGB(195, 202, 220),
    Font          = Enum.Font.GothamMedium,
    FontBold      = Enum.Font.GothamBold
}

-- 3. Bộ lọc kiểm tra giá trị đo lường thuần túy
local function isPureMetric(txt)
    if not txt or txt == "" then return true end
    local low = txt:lower()
    if low:find("fps") or low:find("ms") or low:find("ping") then return true end
    if txt:match("^%s*[%$]?%d+[%d%.]*%s*[a-zA-Z%%/%$]*%s*$") then return true end
    if txt:match("%d+%s*studs/s") or txt:match("%d+%%") then return true end
    if txt:match("%d+m%s*%d+s") or txt:match("%d+:%d+") then return true end
    return false
end

-- 4. Bộ chuyển ngữ dòng dữ liệu và trạng thái động
local function translateDynamicCounters(txt)
    local res = txt
    res = res:gsub("Idle", "Đang chờ"):gsub("idle", "đang chờ")
    res = res:gsub("Banked", "Đã cất"):gsub("banked", "đã cất")
    res = res:gsub("Lost", "Mất"):gsub("lost", "mất")
    res = res:gsub("Re%-grabs", "Nhặt lại"):gsub("re%-grabs", "nhặt lại")
    res = res:gsub("Placed", "Đã đặt"):gsub("placed", "đã đặt")
    res = res:gsub("Hatched", "Đã nở"):gsub("hatched", "đã nở")
    res = res:gsub("going for (.+) Egg", "Đang săn Trứng %1")
    res = res:gsub("not training", "đang nghỉ"):gsub("earned", "kiếm được"):gsub("this session", "phiên này")
    res = res:gsub("quietened", "đã giảm tải"):gsub("effects", "hiệu ứng")
    res = res:gsub("(%d+)%s*pages", "%1 trang"):gsub("up to (%d+) servers", "quét tới %1 server")
    res = res:gsub("banked (.+) Egg", "Đã cất Trứng %1")
    return res
end

-- 5. Từ điển dịch tiếng Việt chuẩn xác toàn bộ hệ thống
local fullTransTable = {
    ["Monster"] = "Quái vật", ["Auto Steal"] = "Tự động trộm", ["Filters"] = "Bộ lọc",
    ["Plot"] = "Khu đất", ["Server"] = "Máy chủ", ["Misc"] = "Tính năng phụ",
    ["Webhook"] = "Webhook", ["Settings"] = "Cài đặt",
    
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
    ["EGGS ON THE MAP"] = "TRỨNG TRÊN BẢN ĐỒ", ["EGGS ON YOUR PLOT"] = "TRỨNG TRÊN ĐẤT CỦA BẠN",
    ["STATS PANEL"] = "BẢNG THỐNG KÊ",

    -- Tab Khu đất
    ["Auto Place Eggs"] = "Tự động đặt trứng",
    ["Never place this rarity or rarer"] = "Không đặt từ độ hiếm này trở lên",
    ["keeps your best eggs in the bag instead of committing them to a hatch timer"] = "giữ trứng xịn nhất trong túi thay vì đưa vào thời gian đếm ấp",
    ["place everything"] = "Đặt tất cả",
    ["Only place eggs worth ($/s)"] = "Chỉ đặt trứng có giá trị ($/s)",
    ["the pen has limited room, so it fills with your best eggs first · blank for any"] = "chuồng có chỗ giới hạn, ưu tiên đặt trứng ngon nhất · để trống để chọn mọi quả",
    ["the pen has limited room, so it fills with your best eggs first - blank for any"] = "chuồng có chỗ giới hạn, ưu tiên đặt trứng ngon nhất · để trống để chọn mọi quả",
    ["Auto Hatch"] = "Tự động ấp nở",
    ["hatches every egg the moment its timer is up"] = "tự mở tất cả trứng ngay khi hết thời gian ấp",
    ["Auto Equip Best Pets"] = "Tự trang bị pet xịn nhất",
    ["keeps your best pets out at all times — hatch something better and it swaps, even when your pen is full"] = "luôn dùng pet mạnh nhất — mở ra con tốt hơn sẽ tự thay thế kể cả khi chuồng đầy",
    ["keeps your best pets out at all times - hatch something better and it swaps, even when your pen is full"] = "luôn dùng pet mạnh nhất — mở ra con tốt hơn sẽ tự thay thế kể cả khi chuồng đầy",
    ["Auto Upgrade Trails"] = "Tự nâng cấp vệt sáng (Trails)",

    -- Tab Bán & Luyện tập
    ["What selling will never touch"] = "Những thứ không bao giờ bị bán",
    ["favourited · equipped · in the fuse machine · in the pen · placed on your plot"] = "yêu thích · đang trang bị · trong máy ghép · trong chuồng · đặt trên đất",
    ["Sell anything earning under ($/s)"] = "Bán mọi thứ kiếm dưới ($/s)",
    ["required — nothing is sold while this is blank · type 250k, 1.5m or 2b"] = "bắt buộc — không bán gì nếu để trống · gõ 250k, 1.5m hoặc 2b",
    ["required - nothing is sold while this is blank · type 250k, 1.5m or 2b"] = "bắt buộc — không bán gì nếu để trống · gõ 250k, 1.5m hoặc 2b",
    ["Auto Sell Pets"] = "Tự động bán thú cưng",
    ["sells the worst ones first, and only below the floor above"] = "bán con yếu nhất trước, và chỉ bán dưới mức sàn ở trên",
    ["Auto Sell Eggs"] = "Tự động bán trứng",
    ["spare eggs only · anything on your plot is never touched"] = "chỉ bán trứng thừa · không bao giờ đụng đến trứng trên đất",
    ["Train when Auto Steal is off"] = "Tập khi tắt Tự động trộm",
    ["Train when Tự động trộm is off"] = "Tập khi tắt Tự động trộm",
    ["on = trains whenever there is nothing worth stealing"] = "bật = tập luyện bất cứ khi nào không có gì đáng trộm",

    -- Tab Máy chủ
    ["Auto Hop"] = "Tự động đổi server", ["Hop now"] = "Đổi server ngay", ["Hop"] = "Đổi ngay",
    ["How hard to look"] = "Độ sâu tìm server", ["Skip full servers"] = "Bỏ qua server đầy",
    ["Reload hub after hopping"] = "Nạp lại hub sau khi đổi",
    ["turn off if your autoexec already loads the hub in every server"] = "tắt nếu autoexec của bạn đã tự nạp hub khi vào server",
    ["Fewest players"] = "Ít người nhất", ["Most players"] = "Đông người nhất",
    ["Hop after a while anyway"] = "Đổi server sau một khoảng thời gian",
    ["leave for another server straight away"] = "chuyển sang server khác ngay lập tức",
    ["a full server will just bounce you straight back out"] = "server đầy sẽ khiến bạn bị văng ra ngoài",
    ["pages of the server list to collect, 100 servers each · Roblox rate limits this, so more pages takes longer"] = "số trang server cần quét, 100 server mỗi trang · Roblox giới hạn tốc độ, quét nhiều trang sẽ lâu hơn",
    ["skip servers emptier than this · blank for any"] = "bỏ qua server vắng hơn mức này · để trống để chọn mọi server",
    ["skip servers busier than this · fewer players means less competition for the same eggs · blank for any"] = "bỏ qua server đông hơn mức này · ít người chơi hơn giúp giảm cạnh tranh · để trống cho mọi server",

    -- Tab Tiện ích (Misc)
    ["Egg ESP"] = "ESP Trứng",
    ["each egg's $/s, rarity, weight and mutations floating over it · no distance limit"] = "hiển thị $/s, độ hiếm, trọng lượng và đột biến trên quả · không giới hạn cự ly",
    ["Show ESP on"] = "Hiển thị ESP cho",
    ["\"matching my filters\" tracks whatever Auto Steal is set to"] = "\"khớp bộ lọc\" theo dõi mục tiêu theo thiết lập Tự động trộm",
    ["\"matching my filters\" tracks whatever Tự động trộm is set to"] = "\"khớp bộ lọc\" theo dõi mục tiêu theo thiết lập Tự động trộm",
    ["Eggs matching..."] = "Trứng khớp bộ lọc...",
    ["Beam to current target"] = "Tia dẫn đường tới mục tiêu",
    ["draws a line to the egg Auto Steal picked · easy to lose among fifty cards otherwise"] = "kẻ tia chỉ đường tới quả trứng đã chọn · tránh bị lạc giữa hàng tá quả",
    ["draws a line to the egg Tự động trộm picked · easy to lose among fifty cards otherwise"] = "kẻ tia chỉ đường tới quả trứng đã chọn · tránh bị lạc giữa hàng tá quả",
    ["Plot Egg ESP"] = "ESP Trứng trên đất",
    ["Khu đất Egg ESP"] = "ESP Trứng trên đất",
    ["your placed eggs: what each will pay, and the hatch timer · green when ready"] = "trứng đã đặt: thu nhập mỗi quả mang lại và thời gian ấp · màu xanh khi sẵn sàng nở",
    ["Show Stats Panel"] = "Hiện bảng thống kê",
    ["small draggable panel: money income, eggs banked, best egg so far"] = "bảng kéo thả: thu nhập, số trứng đã cất, quả xịn nhất",
    ["WASD to fly, space up, Left Ctrl down · holds its altitude when you let go"] = "WASD để bay, Space bay lên, Ctrl trái hạ xuống · giữ nguyên độ cao khi thả phím",
    ["Flight speed"] = "Tốc độ bay",
    ["studs per second while flying"] = "studs mỗi giây khi đang bay",
    ["Flight keybind"] = "Phím tắt bay",
    ["Unbound"] = "Chưa gán",
    ["toggles flight without opening the hub"] = "bật / tắt bay mà không cần mở hub",
    ["Game optimizer"] = "Tối ưu hóa game",
    ["Cap the frame rate"] = "Khóa tốc độ khung hình (FPS)",
    ["a low frame rate breaks Bypassed Speed — you get pulled back instead of moving faster, so auto steal gets slower the lower you go"] = "FPS thấp làm lỗi Vượt tốc độ — bạn sẽ bị kéo giật lùi, FPS càng thấp trộm càng chậm",
    ["a low frame rate breaks Vượt tốc độ tối đa — you get pulled back instead of moving faster, so auto steal gets slower the lower you go"] = "FPS thấp làm lỗi Vượt tốc độ tối đa — bạn sẽ bị kéo giật lùi, FPS càng thấp trộm càng chậm",
    ["a low frame rate breaks Vượt tốc độ tối đa - you get pulled back instead of moving faster, so auto steal gets slower the lower you go"] = "FPS thấp làm lỗi Vượt tốc độ tối đa — bạn sẽ bị kéo giật lùi, FPS càng thấp trộm càng chậm",
    ["FPS cap"] = "Giới hạn FPS",
    ["30 is the lowest — under that the speed bypass stops helping"] = "30 là mức thấp nhất — dưới mức đó việc vượt tốc độ sẽ mất tác dụng",
    ["30 is the lowest - under that the speed bypass stops helping"] = "30 là mức thấp nhất — dưới mức đó việc vượt tốc độ sẽ mất tác dụng",

    -- Tab Webhook
    ["Webhook URL"] = "Đường dẫn Webhook",
    ["your channel -> Edit -> Integrations -> Webhooks -> Sao chép URL · sends a test message"] = "kênh của bạn -> Sửa kênh -> Tích hợp -> Webhooks -> Sao chép URL · gửi tin thử nghiệm",
    ["your channel → Edit → Integrations → Webhooks → Sao chép URL · sends a test message"] = "kênh của bạn -> Sửa kênh -> Tích hợp -> Webhooks -> Sao chép URL · gửi tin thử nghiệm",
    ["Share my rare pulls"] = "Chia sẻ trứng hiếm nhặt được",
    ["What gets shared"] = "Dữ liệu được chia sẻ",
    ["the exact list, so you never have to take our word for it"] = "danh sách dữ liệu chính xác, minh bạch",
    ["Show"] = "Xem", ["Preview"] = "Xem trước",
    ["Egg stolen"] = "Khi trộm được trứng",
    ["Egg hatched"] = "Khi trứng nở",
    ["Mutation rolled"] = "Khi ra đột biến",
    ["Sold pets or eggs"] = "Khi bán thú cưng hoặc trứng",
    ["Rewards claimed"] = "Khi nhận phần thưởng",
    ["Only eggs earning over ($/s)"] = "Chỉ gửi trứng kiếm trên ($/s)",
    ["stolen + hatched only · blank sends everything · type 250k, 1.5m or 2b"] = "chỉ trứng trộm + nở · để trống để gửi tất cả · gõ 250k, 1.5m hoặc 2b",
    ["stolen + hatched only - blank sends everything - type 250k, 1.5m or 2b"] = "chỉ trứng trộm + nở · để trống để gửi tất cả · gõ 250k, 1.5m hoặc 2b",
    ["everything · e.g. 50m"] = "tất cả · vd: 50m",
    ["Rarity floor"] = "Mức độ hiếm sàn",
    ["this rarity and rarer · stolen + hatched only"] = "độ hiếm này trở lên · chỉ tính trứng trộm + nở",
    ["this rarity and rarer - stolen + hatched only"] = "độ hiếm này trở lên · chỉ tính trứng trộm + nở",
    ["Session digest"] = "Báo cáo tóm tắt phiên chơi",
    ["a running total every so often, whatever else is switched on"] = "gửi bảng tổng kết định kỳ các thông số thu hoạch",
    ["Ping"] = "Tag nhắc tên",
    ["No ping"] = "Không tag",
    ["@everyone only works if the webhook channel allows it"] = "@everyone chỉ hoạt động nếu quyền hạn kênh cho phép",
    ["Include my username"] = "Kèm tên tài khoản Roblox",
    ["puts your Roblox name in the footer · off keeps every message anonymous"] = "hiện tên Roblox của bạn ở chân tin nhắn · tắt để ẩn danh",
    ["puts your Roblox name in the footer - off keeps every message anonymous"] = "hiện tên Roblox của bạn ở chân tin nhắn · tắt để ẩn danh",
    ["Let exported configs carry the URL"] = "Cho phép xuất cấu hình kèm URL Webhook",
    ["off (recommended) — then a config you share cannot give away your channel"] = "tắt (khuyên dùng) — tránh bị lộ liên kết webhook khi chia sẻ cài đặt",
    ["off (recommended) - then a config you share cannot give away your channel"] = "tắt (khuyên dùng) — tránh bị lộ liên kết webhook khi chia sẻ cài đặt",
    ["Any"] = "Bất kỳ",

    -- Trộm & Quái vật & Cài đặt
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
    ["What to take"] = "Loại cần lấy",
    ["Best value"] = "Giá trị cao nhất",
    ["Rarity snipe"] = "Bắn tỉa độ hiếm",
    ["Gen ($/s) snipe"] = "Bắn tỉa Gen ($/s)",
    ["Rarity snipe floor"] = "Độ hiếm tối thiểu",
    ["Gen ($/s) snipe floor"] = "Mức Gen ($/s) tối thiểu",
    ["Bypassed Speed"] = "Vượt tốc độ tối đa",
    ["Bypassed speed cap"] = "Vượt tốc độ tối đa cap",
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
    ["Matching right now"] = "Đang khớp điều kiện",
    ["Use rarity filter"] = "Lọc theo độ hiếm", ["Use mutation filter"] = "Lọc theo đột biến",
    ["Minimum weight (Kg)"] = "Trọng lượng tối thiểu (Kg)", ["Clear all"] = "Bỏ chọn tất cả",
    ["Import settings"] = "Nhập cài đặt", ["Import"] = "Nhập",
    ["Reset position & size"] = "Đặt lại vị trí & cỡ", ["Reset"] = "Đặt lại",
    ["Export settings"] = "Xuất cài đặt", ["UI scale"] = "Tỷ lệ giao diện",
    ["Theme"] = "Màu giao diện", ["Open / close the hub"] = "Mở / đóng hub",
    ["Start minimised"] = "Thu nhỏ khi chạy", ["Search settings..."] = "Tìm kiếm cài đặt...",
    ["Copy"] = "Sao chép",

    -- Map & Độ hiếm
    ["Forest"] = "Rừng xanh", ["Lake"] = "Hồ nước", ["Desert"] = "Sa mạc",
    ["Jungle"] = "Rừng rậm", ["Snow"] = "Vùng tuyết", ["Volcano"] = "Núi lửa",
    ["Abyss Ocean"] = "Vực biển sâu", ["Prehistoric"] = "Tiền sử",
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

-- 6. Hook trực tiếp Toggle theo vị trí thực tế
local function hookToggleElement(track)
    if track:GetAttribute("ToggleHooked") then return end

    local knob = nil
    for _, child in ipairs(track:GetChildren()) do
        if child:IsA("GuiObject") and child.Name ~= "ToggleStroke" and not child:IsA("UIStroke") and not child:IsA("UICorner") then
            local sz = child.AbsoluteSize
            if math.abs(sz.X - sz.Y) <= 12 and sz.X >= 8 and sz.X < track.AbsoluteSize.X then
                knob = child
                break
            end
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

        local trackW = track.AbsoluteSize.X
        if trackW > 0 and knob then
            local relX = knob.AbsolutePosition.X - track.AbsolutePosition.X
            local isOn = relX > (trackW * 0.28)

            track.BackgroundColor3 = isOn and THEME.ToggleOn or THEME.ToggleOff
            knob.BackgroundColor3 = isOn and THEME.KnobOn or THEME.KnobOff
            stroke.Color = isOn and THEME.ToggleOnGlow or THEME.Stroke
            stroke.Transparency = isOn and 0 or 0.2
        end

        updating = false
    end

    updateVisual()

    knob:GetPropertyChangedSignal("Position"):Connect(updateVisual)
    track:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
        if not updating then updateVisual() end
    end)
end

-- Biến lưu trữ đối tượng thẻ Best Pet duy nhất
local mountedBestEggCard = nil

local function isInsideBestPet(obj)
    if not mountedBestEggCard then return false end
    return obj == mountedBestEggCard or obj:IsDescendantOf(mountedBestEggCard)
end

-- 7. Tìm đúng Card Best Pet từ Lennon Hub
local function findOriginalBestPetCard()
    if mountedBestEggCard and mountedBestEggCard.Parent then
        return mountedBestEggCard
    end

    local containers = {CoreGui}
    if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
        table.insert(containers, LocalPlayer.PlayerGui)
    end
    if gethui then table.insert(containers, gethui()) end

    for _, cont in ipairs(containers) do
        for _, gui in ipairs(cont:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Name ~= "RonneiHub" and not gui:FindFirstChild("RonneiLangModule", true) then
                for _, desc in ipairs(gui:GetDescendants()) do
                    if desc:IsA("TextLabel") and desc.Text:upper() == "BEST EGG" then
                        local card = desc.Parent
                        while card and card.Parent and not card.Parent:IsA("ScreenGui") do
                            local hasImg = false
                            for _, sub in ipairs(card:GetDescendants()) do
                                if sub:IsA("ImageLabel") or sub:IsA("ViewportFrame") then
                                    hasImg = true
                                    break
                                end
                            end
                            if hasImg and card.AbsoluteSize.Y >= 35 and card.AbsoluteSize.Y <= 95 then
                                mountedBestEggCard = card
                                return card
                            end
                            card = card.Parent
                        end
                    end
                end
            end
        end
    end
    return nil
end

-- 8. Quét dọn sạch sẽ toàn bộ UI thừa của Lennon Hub ngoài màn hình
local function purgeLennonExternalJunk(activeRonneiChild)
    local containers = {CoreGui}
    if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
        table.insert(containers, LocalPlayer.PlayerGui)
    end
    if gethui then table.insert(containers, gethui()) end

    for _, cont in ipairs(containers) do
        for _, gui in ipairs(cont:GetChildren()) do
            if gui:IsA("ScreenGui") and gui ~= activeRonneiChild and gui.Name ~= "RonneiHub" and not gui:FindFirstChild("RonneiLangModule", true) then
                local isLennonGui = false
                for _, desc in ipairs(gui:GetDescendants()) do
                    if desc:IsA("TextLabel") and (desc.Text:find("LENNON") or desc.Text:find("TOP 4 SYSTEM") or desc.Text:find("TELEPORT")) then
                        isLennonGui = true
                        break
                    end
                end

                if isLennonGui then
                    for _, child in ipairs(gui:GetChildren()) do
                        if not isInsideBestPet(child) then
                            child.Visible = false
                        end
                    end
                    for _, desc in ipairs(gui:GetDescendants()) do
                        if desc:IsA("GuiObject") and not isInsideBestPet(desc) then
                            local t = (desc:IsA("TextLabel") or desc:IsA("TextButton")) and desc.Text:upper() or ""
                            local n = desc.Name:lower()
                            if t:find("TOP 4 SYSTEM") or t:find("LENNON") or t:find("RESET GUI") 
                               or t:find("TELEPORT") or n:find("logo") or n:find("button") then
                                desc.Visible = false
                            end
                        end
                    end
                end
            end
        end
    end
end

-- 9. Nâng cấp đồ họa sáng sủa (Bỏ qua hoàn toàn Best Pet Card)
local function applyModernVisuals(obj)
    if obj:GetAttribute("IsLangToggle") or isInsideBestPet(obj) then return end

    if (obj:IsA("Frame") or obj:IsA("GuiButton")) and not obj:GetAttribute("ToggleHooked") then
        local sz = obj.AbsoluteSize
        if sz.X >= 26 and sz.X <= 65 and sz.Y >= 14 and sz.Y <= 32 and sz.X > (sz.Y * 1.2) then
            hookToggleElement(obj)
            return
        end
    end

    if obj:GetAttribute("RestyledModern") then return end
    obj:SetAttribute("RestyledModern", true)

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

    elseif obj:IsA("TextLabel") then
        if obj.TextSize >= 13 then
            obj.Font = THEME.FontBold
            obj.TextColor3 = THEME.TextMain
        else
            obj.Font = THEME.Font
            obj.TextColor3 = THEME.TextSub
        end

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

-- 10. Vòng lặp điều phối chính
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
                        local bestPetCard = findOriginalBestPetCard()
                        pcall(purgeLennonExternalJunk, child)

                        -- Tự động dọn sạch thanh header Lennon Hub nếu bị sót vào Ronnei Hub
                        for _, desc in ipairs(child:GetDescendants()) do
                            if desc:IsA("TextLabel") and desc.Text:upper():find("LENNON HUB") and not isInsideBestPet(desc) then
                                local junk = desc
                                while junk.Parent and junk.Parent ~= child and not junk.Parent:IsA("ScreenGui") do
                                    if junk.Parent:FindFirstChildOfClass("UIListLayout") then break end
                                    junk = junk.Parent
                                end
                                junk.Visible = false
                                junk:Destroy()
                            end
                        end

                        for _, desc in ipairs(child:GetDescendants()) do
                            pcall(applyModernVisuals, desc)

                            -- 10.1. Ghim thẻ Best Pet vào ngay TRÊN hàng "Tự động trộm"
                            if desc:IsA("TextLabel") and (desc.Text == "Tự động trộm" or desc.Text == "Auto Steal") and desc.AbsolutePosition.X > 160 and not isInsideBestPet(desc) then
                                local autoStealRow = desc
                                while autoStealRow.Parent and not autoStealRow.Parent:IsA("ScreenGui") do
                                    if autoStealRow.Parent:FindFirstChildOfClass("UIListLayout") then
                                        break
                                    end
                                    autoStealRow = autoStealRow.Parent
                                end

                                local listContainer = autoStealRow.Parent
                                if listContainer and bestPetCard and bestPetCard.Parent ~= listContainer then
                                    bestPetCard.Parent = listContainer
                                    bestPetCard.Visible = true
                                    bestPetCard.Active = false
                                    bestPetCard.Draggable = false
                                    bestPetCard.Size = UDim2.new(1, 0, 0, 56)
                                    bestPetCard.Position = UDim2.new(0, 0, 0, 0)
                                    bestPetCard.AnchorPoint = Vector2.new(0, 0)
                                    bestPetCard.BackgroundColor3 = THEME.Secondary

                                    -- Ẩn nút mũi tên v bên trong thẻ để tránh bấm làm bung cửa sổ TOP 4
                                    for _, sub in ipairs(bestPetCard:GetDescendants()) do
                                        if sub:IsA("GuiButton") or (sub:IsA("TextLabel") and (sub.Text == "v" or sub.Text == "V" or sub.Text == "⌄")) then
                                            sub.Visible = false
                                        end
                                    end

                                    -- Điều chỉnh LayoutOrder để Best Pet luôn nằm ngay trước hàng Auto Steal
                                    local listLayout = listContainer:FindFirstChildOfClass("UIListLayout")
                                    if listLayout then
                                        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
                                        local order = 10
                                        for _, sibling in ipairs(listContainer:GetChildren()) do
                                            if sibling:IsA("GuiObject") and sibling ~= bestPetCard then
                                                if sibling == autoStealRow then
                                                    bestPetCard.LayoutOrder = order
                                                    order = order + 10
                                                end
                                                sibling.LayoutOrder = order
                                                order = order + 10
                                            end
                                        end
                                    end
                                end
                            end

                            -- 10.2. Dịch thuật toàn văn (Bỏ qua hoàn toàn thẻ Pet)
                            if (desc:IsA("TextLabel") or desc:IsA("TextButton")) and not isInsideBestPet(desc) then
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
                                    if not desc:GetAttribute("IsLangToggle") and not isPureMetric(txt) then
                                        local low = txt:lower()
                                        if low:find("placed") or low:find("hatched") or low:find("banked") or low:find("lost") 
                                           or low:find("re%-grabs") or low:find("idle") or low:find("training") or low:find("quietened") 
                                           or low:find("going for") or (low:find("pages") and low:find("server")) then
                                            if getgenv().RonneiTranslateVN then
                                                desc.Text = translateDynamicCounters(txt)
                                            end
                                        else
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
                                end
                            elseif desc:IsA("TextBox") and not isInsideBestPet(desc) then
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

                        -- 10.3. Bảo dưỡng camera ViewportFrame và phục hồi hiển thị hình ảnh Pet
                        if mountedBestEggCard then
                            for _, vf in ipairs(mountedBestEggCard:GetDescendants()) do
                                if vf:IsA("ViewportFrame") then
                                    vf.BackgroundTransparency = 1
                                    local cam = vf.CurrentCamera
                                    if not cam or not cam:IsDescendantOf(game) then
                                        local existingCam = vf:FindFirstChildOfClass("Camera")
                                        if not existingCam then
                                            local model = vf:FindFirstChildOfClass("Model") or vf:FindFirstChildWhichIsA("PVInstance")
                                            if model then
                                                existingCam = Instance.new("Camera")
                                                existingCam.Parent = vf
                                                vf.CurrentCamera = existingCam
                                                local cf, size = model:GetBoundingBox()
                                                local dist = math.max(size.X, size.Y, size.Z) * 2.2
                                                existingCam.CFrame = CFrame.new(cf.Position + Vector3.new(dist * 0.7, dist * 0.5, dist * 0.7), cf.Position)
                                            end
                                        else
                                            vf.CurrentCamera = existingCam
                                        end
                                    end
                                elseif vf:IsA("ImageLabel") then
                                    vf.ImageTransparency = 0
                                    vf.Visible = true
                                end
                            end
                        end

                        -- 10.4. Thay thế Avatar Header (Tuyệt đối không đụng vào ảnh Pet)
                        for _, img in ipairs(child:GetDescendants()) do
                            if (img:IsA("ImageLabel") or img:IsA("ImageButton")) and not isInsideBestPet(img) then
                                local sz = img.AbsoluteSize
                                if sz.X >= 20 and sz.X <= 65 and math.abs(sz.X - sz.Y) <= 8 then
                                    local name = img.Name:lower()
                                    if not (name:find("check") or name:find("arrow") or name:find("close") or name:find("exit") or name:find("slider") or name:find("pet") or name:find("egg")) then
                                        local rootFrame = child:FindFirstChildWhichIsA("Frame") or child
                                        local relY = img.AbsolutePosition.Y - rootFrame.AbsolutePosition.Y
                                        if relY >= 0 and relY <= 65 and img.Image ~= NEW_IMAGE then
                                            img.Image = NEW_IMAGE
                                        end
                                    end
                                end
                            end
                        end

                        -- 10.5. Thanh công tắc ngôn ngữ Tiếng Việt & English
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
