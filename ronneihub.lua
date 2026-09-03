-- ==============================================================================
--  RONNEI HUB - 100% VN + MUSIC TAB (12 TRACKS) + HIGH CONTRAST THEME
-- ==============================================================================

local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
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

-- 2. Khởi tạo Sound Object phát nhạc
local BG_SOUND = SoundService:FindFirstChild("RonneiMusicPlayer")
if not BG_SOUND then
    BG_SOUND = Instance.new("Sound")
    BG_SOUND.Name = "RonneiMusicPlayer"
    BG_SOUND.Volume = 0.5
    BG_SOUND.Looped = true
    BG_SOUND.Parent = SoundService
end

-- Danh sách 12 bài hát hoàn chỉnh
local MUSIC_TRACKS = {
    { id = "73197748961359",  titleVN = "Nhạc 1",  titleEN = "Track 1" },
    { id = "71566297131284",  titleVN = "Nhạc 2",  titleEN = "Track 2" },
    { id = "12139705178741",  titleVN = "Nhạc 3",  titleEN = "Track 3" },
    { id = "138323881451411", titleVN = "Nhạc 4",  titleEN = "Track 4" },
    { id = "73200486470465",  titleVN = "Nhạc 5",  titleEN = "Track 5" },
    { id = "119372546759640", titleVN = "Nhạc 6",  titleEN = "Track 6" },
    { id = "125463248456145", titleVN = "Nhạc 7",  titleEN = "Track 7" },
    { id = "80226192070089",  titleVN = "Nhạc 8",  titleEN = "Track 8" },
    { id = "135574505310",    titleVN = "Nhạc 9",  titleEN = "Track 9" },
    { id = "2602546138",      titleVN = "Nhạc 10", titleEN = "Track 10" },
    { id = "75537083584377",  titleVN = "Nhạc 11", titleEN = "Track 11" },
    { id = "80510130014912",  titleVN = "Nhạc 12", titleEN = "Track 12" }
}

local currentPlayingId = ""
local volumeLevels = {0.25, 0.5, 0.75, 1.0, 0}
local currentVolIdx = 2 -- Mặc định 50%

-- 3. Cấu hình bảng màu giao diện
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

-- 4. Kiểm tra các giá trị đo lường thuần túy
local function isPureMetric(txt)
    if not txt or txt == "" then return true end
    local low = txt:lower()
    if low:find("fps") or low:find("ms") or low:find("ping") then return true end
    if txt:match("^%s*[%$]?%d+[%d%.]*%s*[a-zA-Z%%/%$]*%s*$") then return true end
    if txt:match("%d+%s*studs/s") or txt:match("%d+%%") then return true end
    if txt:match("%d+m%s*%d+s") or txt:match("%d+:%d+") then return true end
    return false
end

-- 5. Bộ chuyển ngữ dòng thống kê đếm thời gian thực
local function translateDynamicCounters(txt)
    local res = txt
    res = res:gsub("Idle", "Đang chờ"):gsub("idle", "đang chờ")
    res = res:gsub("Banked", "Đã cất"):gsub("banked", "đã cất")
    res = res:gsub("Lost", "Mất"):gsub("lost", "mất")
    res = res:gsub("Re%-grabs", "Nhặt lại"):gsub("re%-grabs", "nhặt lại")
    res = res:gsub("Placed", "Đã đặt"):gsub("placed", "đã đặt")
    res = res:gsub("Hatched", "Đã nở"):gsub("hatched", "đã nở")
    res = res:gsub("not training", "đang nghỉ"):gsub("earned", "kiếm được"):gsub("this session", "phiên này")
    res = res:gsub("quietened", "đã giảm tải"):gsub("effects", "hiệu ứng")
    res = res:gsub("(%d+)%s*pages", "%1 trang"):gsub("up to (%d+) servers", "quét tới %1 server")
    res = res:gsub("banked (.+) Egg", "Đã cất Trứng %1")
    return res
end

-- 6. Từ điển dịch tiếng Việt chuẩn xác
local fullTransTable = {
    ["Monster"] = "Quái vật", ["Auto Steal"] = "Tự động trộm", ["Filters"] = "Bộ lọc",
    ["Plot"] = "Khu đất", ["Server"] = "Máy chủ", ["Misc"] = "Tính năng phụ",
    ["Webhook"] = "Webhook", ["Settings"] = "Cài đặt", ["Music"] = "Âm nhạc",
    
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
    ["pages of the server list to collect, 100 servers each · Roblox rate limits this, so more pages takes longer"] = "số trang danh sách server cần quét, 100 server mỗi trang · Roblox giới hạn tốc độ, quét nhiều trang sẽ lâu hơn",
    ["skip servers emptier than this · blank for any"] = "bỏ qua server vắng hơn mức này · để trống để chọn mọi server",
    ["skip servers busier than this · fewer players means less competition for the same eggs · blank for any"] = "bỏ qua server đông hơn mức này · ít người chơi hơn giúp giảm cạnh tranh trứng · để trống để chọn mọi server",

    -- Tab Tính năng phụ (Misc)
    ["Egg ESP"] = "ESP Trứng",
    ["each egg's $/s, rarity, weight and mutations floating over it · no distance limit"] = "hiển thị $/s, độ hiếm, trọng lượng và đột biến nổi trên quả · không giới hạn cự ly",
    ["Show ESP on"] = "Hiển thị ESP cho",
    ["\"matching my filters\" tracks whatever Auto Steal is set to"] = "\"khớp bộ lọc\" theo dõi mục tiêu theo thiết lập Tự động trộm",
    ["\"matching my filters\" tracks whatever Tự động trộm is set to"] = "\"khớp bộ lọc\" theo dõi mục tiêu theo thiết lập Tự động trộm",
    ["Eggs matching..."] = "Trứng khớp bộ lọc...",
    ["Beam to current target"] = "Tia dẫn đường tới mục tiêu",
    ["draws a line to the egg Auto Steal picked · easy to lose among fifty cards otherwise"] = "kẻ tia chỉ đường tới quả trứng đã chọn · tránh bị lạc giữa hàng tá quả trứng",
    ["draws a line to the egg Tự động trộm picked · easy to lose among fifty cards otherwise"] = "kẻ tia chỉ đường tới quả trứng đã chọn · tránh bị lạc giữa hàng tá quả trứng",
    ["Plot Egg ESP"] = "ESP Trứng trên đất",
    ["Khu đất Egg ESP"] = "ESP Trứng trên đất",
    ["your placed eggs: what each will pay, and the hatch timer · green when ready"] = "trứng đã đặt: thu nhập mỗi quả mang lại và thời gian ấp · màu xanh khi sẵn sàng nở",
    ["Show Stats Panel"] = "Hiện bảng thống kê",
    ["small draggable panel: money income, eggs banked, best egg so far"] = "bảng kéo thả nhỏ gọn: thu nhập, số trứng đã cất, quả trứng xịn nhất",
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
    ["your channel -> Edit -> Integrations -> Webhooks -> Sao chép URL · sends a test message"] = "kênh của bạn -> Sửa kênh -> Tích hợp -> Webhooks -> Sao chép URL · gửi tin nhắn thử nghiệm",
    ["your channel → Edit → Integrations → Webhooks → Sao chép URL · sends a test message"] = "kênh của bạn -> Sửa kênh -> Tích hợp -> Webhooks -> Sao chép URL · gửi tin nhắn thử nghiệm",
    ["Share my rare pulls"] = "Chia sẻ trứng hiếm nhặt được",
    ["What gets shared"] = "Dữ liệu được chia sẻ",
    ["the exact list, so you never have to take our word for it"] = "danh sách dữ liệu chính xác, minh bạch hoàn toàn",
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
    ["@everyone only works if the webhook channel allows it"] = "@everyone chỉ hoạt động nếu quyền hạn kênh webhook cho phép",
    ["Include my username"] = "Kèm tên tài khoản Roblox",
    ["puts your Roblox name in the footer · off keeps every message anonymous"] = "hiện tên Roblox của bạn ở chân tin nhắn · tắt để ẩn danh hoàn toàn",
    ["puts your Roblox name in the footer - off keeps every message anonymous"] = "hiện tên Roblox của bạn ở chân tin nhắn · tắt để ẩn danh hoàn toàn",
    ["Let exported configs carry the URL"] = "Cho phép xuất cấu hình kèm URL Webhook",
    ["off (recommended) — then a config you share cannot give away your channel"] = "tắt (khuyến nghị) — giúp chia sẻ cấu hình mà không bị lộ webhook",
    ["off (recommended) - then a config you share cannot give away your channel"] = "tắt (khuyến nghị) — giúp chia sẻ cấu hình mà không bị lộ webhook",
    ["Any"] = "Bất kỳ",

    -- Tab Auto Steal
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
    ["easiest first — you can reach all of them, so this is purely what you want — applies in every mode"] = "ưu tiên nơi dễ nhất - bạn có thể đến mọi nơi, tùy bạn chọn - áp dụng mọi chế độ",
    ["an egg counts if it is one of these"] = "trứng hợp lệ nếu thuộc một trong các loại này",
    ["an egg counts if it carries one of these"] = "trứng hợp lệ nếu mang một trong các đột biến này",
    ["Forest"] = "Rừng xanh", ["Lake"] = "Hồ nước", ["Desert"] = "Sa mạc",
    ["Jungle"] = "Rừng rậm", ["Snow"] = "Vùng tuyết", ["Volcano"] = "Núi lửa",
    ["Abyss Ocean"] = "Vực biển sâu", ["Prehistoric"] = "Tiền sử",

    -- Tab Cài đặt
    ["Import settings"] = "Nhập cài đặt", ["Import"] = "Nhập",
    ["Reset position & size"] = "Đặt lại vị trí & cỡ", ["Reset"] = "Đặt lại",
    ["Export settings"] = "Xuất cài đặt", ["UI scale"] = "Tỷ lệ giao diện",
    ["Theme"] = "Màu giao diện", ["Open / close the hub"] = "Mở / đóng hub",
    ["Start minimised"] = "Thu nhỏ khi chạy", ["Search settings..."] = "Tìm kiếm cài đặt...",
    ["Copy"] = "Sao chép",

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

-- 7. Hook Toggle gốc theo vị trí thực tế
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

-- 8. Nâng cấp đồ họa sáng sủa & font chữ
local function applyModernVisuals(obj)
    if obj:GetAttribute("IsLangToggle") or obj:GetAttribute("IsMusicModule") then return end

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

-- 9. MODULE TAB ÂM NHẠC (12 BÀI HÁT)
local function buildMusicTab(mainFrame)
    if mainFrame:FindFirstChild("RonneiMusicPage") then return end

    local tabSidebarContainer = nil
    local pagesContainer = nil

    for _, desc in ipairs(mainFrame:GetDescendants()) do
        if desc:IsA("TextLabel") and (desc.Text == "Settings" or desc.Text == "Cài đặt") then
            local btn = desc:FindFirstAncestorWhichIsA("GuiButton") or desc.Parent
            if btn and btn.Parent then
                tabSidebarContainer = btn.Parent
            end
        end
        if desc:IsA("TextLabel") and (desc.Text:find("AUTO STEAL") or desc.Text:find("TRỘM TRỨNG") or desc.Text:find("Auto Steal")) then
            local p = desc:FindFirstAncestorWhichIsA("ScrollingFrame") or desc.Parent
            while p and p.Parent ~= mainFrame and p.Parent ~= nil do
                if p.Parent:IsA("Frame") or p.Parent:IsA("ScrollingFrame") then
                    pagesContainer = p.Parent
                    break
                end
                p = p.Parent
            end
        end
    end

    if not tabSidebarContainer then
        for _, f in ipairs(mainFrame:GetChildren()) do
            if f:IsA("GuiObject") and f.AbsoluteSize.X >= 70 and f.AbsoluteSize.X <= 180 then
                tabSidebarContainer = f:FindFirstChildOfClass("ScrollingFrame") or f
                break
            end
        end
    end

    if not pagesContainer then
        for _, f in ipairs(mainFrame:GetChildren()) do
            if f:IsA("GuiObject") and f.AbsoluteSize.X >= 220 and f.AbsoluteSize.Y >= 160 then
                pagesContainer = f
                break
            end
        end
    end

    if not tabSidebarContainer or not pagesContainer then return end

    -- 9.1. Tạo Page hiển thị Tab Âm nhạc
    local musicPage = Instance.new("ScrollingFrame")
    musicPage.Name = "RonneiMusicPage"
    musicPage.Size = UDim2.new(1, 0, 1, 0)
    musicPage.BackgroundTransparency = 1
    musicPage.BorderSizePixel = 0
    musicPage.ScrollBarThickness = 4
    musicPage.Visible = false
    musicPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
    musicPage:SetAttribute("IsMusicModule", true)
    musicPage.Parent = pagesContainer

    local pageLayout = Instance.new("UIListLayout", musicPage)
    pageLayout.Padding = UDim.new(0, 8)
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local pagePad = Instance.new("UIPadding", musicPage)
    pagePad.PaddingTop = UDim.new(0, 10)
    pagePad.PaddingBottom = UDim.new(0, 15)
    pagePad.PaddingLeft = UDim.new(0, 12)
    pagePad.PaddingRight = UDim.new(0, 12)

    -- Header trạng thái
    local statusCard = Instance.new("Frame", musicPage)
    statusCard.Size = UDim2.new(1, 0, 0, 48)
    statusCard.BackgroundColor3 = THEME.Secondary
    Instance.new("UICorner", statusCard).CornerRadius = UDim.new(0, 6)
    local scStroke = Instance.new("UIStroke", statusCard)
    scStroke.Color = THEME.Stroke
    scStroke.Thickness = 1.2

    local statusHeader = Instance.new("TextLabel", statusCard)
    statusHeader.Size = UDim2.new(1, -20, 0, 18)
    statusHeader.Position = UDim2.new(0, 12, 0, 6)
    statusHeader.BackgroundTransparency = 1
    statusHeader.Font = THEME.FontBold
    statusHeader.TextSize = 11
    statusHeader.TextColor3 = THEME.Accent
    statusHeader.TextXAlignment = Enum.TextXAlignment.Left
    statusHeader.Text = "TRÌNH PHÁT NHẠC"

    local statusText = Instance.new("TextLabel", statusCard)
    statusText.Size = UDim2.new(1, -20, 0, 18)
    statusText.Position = UDim2.new(0, 12, 0, 24)
    statusText.BackgroundTransparency = 1
    statusText.Font = THEME.Font
    statusText.TextSize = 11
    statusText.TextColor3 = THEME.TextMain
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.Text = "Trạng thái: Đã dừng"

    local trackBtns = {}
    local trackTitleLabels = {}

    local function updateStatusUI()
        local isVN = getgenv().RonneiTranslateVN
        statusHeader.Text = isVN and "TRÌNH PHÁT NHẠC" or "MUSIC PLAYER"
        
        if currentPlayingId == "" or not BG_SOUND.IsPlaying then
            statusText.Text = isVN and "Trạng thái: Đã dừng" or "Status: Stopped"
        else
            local foundName = "Track"
            for _, trk in ipairs(MUSIC_TRACKS) do
                if trk.id == currentPlayingId then
                    foundName = isVN and trk.titleVN or trk.titleEN
                    break
                end
            end
            statusText.Text = (isVN and "Đang phát: " or "Playing: ") .. foundName
        end

        for id, btn in pairs(trackBtns) do
            if currentPlayingId == id and BG_SOUND.IsPlaying then
                btn.Text = isVN and "Dừng" or "Stop"
                btn.BackgroundColor3 = Color3.fromRGB(220, 50, 70)
            else
                btn.Text = isVN and "Phát" or "Play"
                btn.BackgroundColor3 = THEME.Accent
            end
        end

        for id, lbl in pairs(trackTitleLabels) do
            for _, trk in ipairs(MUSIC_TRACKS) do
                if trk.id == id then
                    lbl.Text = (isVN and trk.titleVN or trk.titleEN) .. " (" .. trk.id .. ")"
                    break
                end
            end
        end
    end

    -- Tạo các Card bài hát từ danh sách 12 bài
    for _, trk in ipairs(MUSIC_TRACKS) do
        local card = Instance.new("Frame", musicPage)
        card.Size = UDim2.new(1, 0, 0, 44)
        card.BackgroundColor3 = THEME.Secondary
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)
        local cStroke = Instance.new("UIStroke", card)
        cStroke.Color = THEME.Stroke
        cStroke.Thickness = 1.2

        local titleLbl = Instance.new("TextLabel", card)
        titleLbl.Size = UDim2.new(1, -85, 1, 0)
        titleLbl.Position = UDim2.new(0, 12, 0, 0)
        titleLbl.BackgroundTransparency = 1
        titleLbl.Font = THEME.FontBold
        titleLbl.TextSize = 11
        titleLbl.TextColor3 = THEME.TextMain
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        titleLbl.Text = trk.titleVN .. " (" .. trk.id .. ")"
        trackTitleLabels[trk.id] = titleLbl

        local pBtn = Instance.new("TextButton", card)
        pBtn.Size = UDim2.new(0, 65, 0, 26)
        pBtn.Position = UDim2.new(1, -75, 0.5, 0)
        pBtn.AnchorPoint = Vector2.new(0, 0.5)
        pBtn.BackgroundColor3 = THEME.Accent
        pBtn.Font = THEME.FontBold
        pBtn.TextSize = 11
        pBtn.TextColor3 = Color3.fromRGB(15, 18, 25)
        pBtn.Text = "Phát"
        Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0, 5)

        trackBtns[trk.id] = pBtn

        pBtn.MouseButton1Click:Connect(function()
            if currentPlayingId == trk.id and BG_SOUND.IsPlaying then
                BG_SOUND:Stop()
                currentPlayingId = ""
            else
                BG_SOUND:Stop()
                BG_SOUND.SoundId = "rbxassetid://" .. trk.id
                BG_SOUND:Play()
                currentPlayingId = trk.id
            end
            updateStatusUI()
        end)
    end

    -- Card Điều khiển tổng: Âm lượng & Dừng toàn bộ
    local ctrlCard = Instance.new("Frame", musicPage)
    ctrlCard.Size = UDim2.new(1, 0, 0, 46)
    ctrlCard.BackgroundColor3 = THEME.Secondary
    Instance.new("UICorner", ctrlCard).CornerRadius = UDim.new(0, 6)
    local ctStroke = Instance.new("UIStroke", ctrlCard)
    ctStroke.Color = THEME.Stroke
    ctStroke.Thickness = 1.2

    local volBtn = Instance.new("TextButton", ctrlCard)
    volBtn.Size = UDim2.new(0.48, -6, 0, 28)
    volBtn.Position = UDim2.new(0, 8, 0.5, 0)
    volBtn.AnchorPoint = Vector2.new(0, 0.5)
    volBtn.BackgroundColor3 = Color3.fromRGB(48, 54, 72)
    volBtn.Font = THEME.FontBold
    volBtn.TextSize = 11
    volBtn.TextColor3 = THEME.TextMain
    volBtn.Text = "Âm lượng: 50%"
    Instance.new("UICorner", volBtn).CornerRadius = UDim.new(0, 5)

    volBtn.MouseButton1Click:Connect(function()
        currentVolIdx = (currentVolIdx % #volumeLevels) + 1
        local newVol = volumeLevels[currentVolIdx]
        BG_SOUND.Volume = newVol
        local isVN = getgenv().RonneiTranslateVN
        volBtn.Text = (isVN and "Âm lượng: " or "Volume: ") .. (newVol == 0 and (isVN and "Tắt tiếng" or "Mute") or tostring(math.floor(newVol * 100)) .. "%")
    end)

    local stopAllBtn = Instance.new("TextButton", ctrlCard)
    stopAllBtn.Size = UDim2.new(0.48, -6, 0, 28)
    stopAllBtn.Position = UDim2.new(1, -8, 0.5, 0)
    stopAllBtn.AnchorPoint = Vector2.new(1, 0.5)
    stopAllBtn.BackgroundColor3 = Color3.fromRGB(60, 40, 50)
    stopAllBtn.Font = THEME.FontBold
    stopAllBtn.TextSize = 11
    stopAllBtn.TextColor3 = Color3.fromRGB(255, 120, 130)
    stopAllBtn.Text = "Dừng phát"
    Instance.new("UICorner", stopAllBtn).CornerRadius = UDim.new(0, 5)

    stopAllBtn.MouseButton1Click:Connect(function()
        BG_SOUND:Stop()
        currentPlayingId = ""
        updateStatusUI()
    end)

    -- 9.2. Nút Tab trên Sidebar
    local musicTabBtn = Instance.new("TextButton")
    musicTabBtn.Name = "RonneiMusicTabBtn"
    musicTabBtn.Size = UDim2.new(1, -12, 0, 30)
    musicTabBtn.BackgroundColor3 = THEME.Secondary
    musicTabBtn.Font = THEME.FontBold
    musicTabBtn.TextSize = 11
    musicTabBtn.TextColor3 = THEME.TextMain
    musicTabBtn.Text = getgenv().RonneiTranslateVN and "🎵 Âm nhạc" or "🎵 Music"
    musicTabBtn.TextXAlignment = Enum.TextXAlignment.Left
    musicTabBtn:SetAttribute("IsMusicModule", true)
    Instance.new("UICorner", musicTabBtn).CornerRadius = UDim.new(0, 6)
    local tStroke = Instance.new("UIStroke", musicTabBtn)
    tStroke.Color = THEME.Stroke
    tStroke.Thickness = 1
    
    local pad = Instance.new("UIPadding", musicTabBtn)
    pad.PaddingLeft = UDim.new(0, 10)
    musicTabBtn.Parent = tabSidebarContainer

    local function selectMusicTab()
        for _, page in ipairs(pagesContainer:GetChildren()) do
            if page:IsA("GuiObject") and page ~= musicPage then
                page.Visible = false
            end
        end
        musicPage.Visible = true
        musicTabBtn.BackgroundColor3 = THEME.Accent
        musicTabBtn.TextColor3 = Color3.fromRGB(15, 18, 25)
        updateStatusUI()
    end

    musicTabBtn.MouseButton1Click:Connect(selectMusicTab)

    for _, sibling in ipairs(tabSidebarContainer:GetChildren()) do
        if sibling:IsA("GuiButton") and sibling ~= musicTabBtn and not sibling:GetAttribute("TabMusicHooked") then
            sibling:SetAttribute("TabMusicHooked", true)
            sibling.MouseButton1Click:Connect(function()
                musicPage.Visible = false
                musicTabBtn.BackgroundColor3 = THEME.Secondary
                musicTabBtn.TextColor3 = THEME.TextMain
            end)
        end
    end

    task.spawn(function()
        local lastVN = getgenv().RonneiTranslateVN
        while musicPage and musicPage.Parent do
            if getgenv().RonneiTranslateVN ~= lastVN then
                lastVN = getgenv().RonneiTranslateVN
                musicTabBtn.Text = lastVN and "🎵 Âm nhạc" or "🎵 Music"
                stopAllBtn.Text = lastVN and "Dừng phát" or "Stop All"
                local newVol = volumeLevels[currentVolIdx]
                volBtn.Text = (lastVN and "Âm lượng: " or "Volume: ") .. (newVol == 0 and (lastVN and "Tắt tiếng" or "Mute") or tostring(math.floor(newVol * 100)) .. "%")
                updateStatusUI()
            end
            task.wait(0.3)
        end
    end)
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
                        for _, desc in ipairs(child:GetDescendants()) do
                            pcall(applyModernVisuals, desc)

                            -- 10.1. Dịch văn bản
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
                                    if not desc:GetAttribute("IsLangToggle") and not desc:GetAttribute("IsMusicModule") and not isPureMetric(txt) then
                                        local low = txt:lower()
                                        if low:find("placed") or low:find("hatched") or low:find("banked") or low:find("lost") 
                                           or low:find("re%-grabs") or low:find("idle") or low:find("training") or low:find("quietened") 
                                           or (low:find("pages") and low:find("server")) then
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

                        -- 10.2. Thay đổi Avatar
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

                        -- 10.3. Nhận diện MainFrame
                        local mainFrame = nil
                        for _, f in ipairs(child:GetDescendants()) do
                            if f:IsA("Frame") and f.AbsoluteSize.X >= 300 and f.AbsoluteSize.Y >= 200 then
                                mainFrame = f
                                break
                            end
                        end

                        if mainFrame then
                            pcall(buildMusicTab, mainFrame)

                            if not searchReplaced then
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
            end
        end)
        task.wait(0.35)
    end
end)
