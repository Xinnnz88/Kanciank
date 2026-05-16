-- ============================================================
--  XINNZ HUB  |  Loader v1.0
--  GitHub Private Repo Loader
-- ============================================================

-- ┌─────────────────────────────────────────────────────────┐
-- │  KONFIGURASI — Ganti sesuai repo kamu                   │
-- └─────────────────────────────────────────────────────────┘

local CONFIG = {
    -- Raw URL dari GitHub private repo (pakai token)
    -- Format: https://raw.githubusercontent.com/{user}/{repo}/{branch}/{file}?token={PAT}
    SCRIPT_URL = "https://raw.githubusercontent.com/USERNAME/REPO_NAME/main/Sour_lua_fixed.lua?token=GITHUB_PAT_TOKEN_HERE",

    -- Nama hub (untuk pesan error)
    HUB_NAME   = "Xinnz Hub",

    -- Versi loader
    VERSION    = "1.0",
}

-- ┌─────────────────────────────────────────────────────────┐
-- │  LOADER CORE — Jangan diubah kecuali kamu paham         │
-- └─────────────────────────────────────────────────────────┘

local function showError(msg)
    -- Tampilkan error di layar jika PlayerGui tersedia
    pcall(function()
        local lp = game:GetService("Players").LocalPlayer
        local sg  = Instance.new("ScreenGui")
        sg.Name          = "XinnzLoaderError"
        sg.ResetOnSpawn  = false
        sg.DisplayOrder  = 99999
        sg.Parent        = lp:WaitForChild("PlayerGui")

        local bg = Instance.new("Frame", sg)
        bg.Size                = UDim2.fromScale(1, 1)
        bg.BackgroundColor3    = Color3.fromRGB(10, 10, 10)
        bg.BorderSizePixel     = 0

        local lbl = Instance.new("TextLabel", bg)
        lbl.Size               = UDim2.fromScale(1, 1)
        lbl.BackgroundTransparency = 1
        lbl.Font               = Enum.Font.GothamBold
        lbl.TextSize           = 18
        lbl.TextColor3         = Color3.fromRGB(255, 60, 60)
        lbl.TextWrapped        = true
        lbl.Text               = "⛔ " .. CONFIG.HUB_NAME .. " Loader Error\n\n" .. msg
    end)
    error("⛔ [" .. CONFIG.HUB_NAME .. " Loader] " .. msg, 0)
end

local function httpGet(url)
    -- Coba semua metode HTTP yang tersedia di executor
    local methods = {
        function() return game:HttpGet(url) end,
        function()
            local fn = request or http_request or (syn and syn.request)
            if not fn then return nil end
            local ok, res = pcall(fn, { Url = url, Method = "GET" })
            return (ok and res and res.StatusCode == 200) and res.Body or nil
        end,
    }

    for _, method in ipairs(methods) do
        local ok, result = pcall(method)
        if ok and result and #result > 0 then
            return result
        end
    end
    return nil
end

-- ── Main Load ────────────────────────────────────────────────
print(string.format("◆ [%s Loader v%s] Loading...", CONFIG.HUB_NAME, CONFIG.VERSION))

-- Validasi URL belum diganti
if CONFIG.SCRIPT_URL:find("USERNAME") or CONFIG.SCRIPT_URL:find("REPO_NAME") or CONFIG.SCRIPT_URL:find("GITHUB_PAT_TOKEN_HERE") then
    showError("Loader belum dikonfigurasi!\nGanti USERNAME, REPO_NAME, dan GITHUB_PAT_TOKEN_HERE\ndi bagian CONFIG atas file loader.lua")
end

-- Fetch script
local scriptContent = httpGet(CONFIG.SCRIPT_URL)

if not scriptContent then
    showError(
        "Gagal mengambil script dari GitHub!\n\n" ..
        "Kemungkinan penyebab:\n" ..
        "• Token GitHub expired / salah\n" ..
        "• URL salah\n" ..
        "• Executor tidak support HTTP\n" ..
        "• Repo dihapus / private tanpa token"
    )
end

-- Pastikan bukan error page GitHub (404 / 401)
if scriptContent:find("404: Not Found") or scriptContent:find("This repository is private") then
    showError("GitHub mengembalikan 404 atau repo private!\nCek URL dan token kamu.")
end

if scriptContent:find("401: Unauthorized") or scriptContent:find("Bad credentials") then
    showError("Token GitHub tidak valid atau expired!\nBuat ulang PAT di GitHub Settings.")
end

-- Execute
print(string.format("◆ [%s Loader] Script fetched (%d bytes). Executing...", CONFIG.HUB_NAME, #scriptContent))

local fn, err = loadstring(scriptContent)
if not fn then
    showError("Compile error:\n" .. tostring(err))
end

fn()
