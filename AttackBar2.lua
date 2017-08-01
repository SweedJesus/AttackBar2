-- Some utility stuff
-- TODO: Remove later (move somewhere else)
local function log(msg)
    ChatFrame1:AddMessage(msg)
end
SlashCmdList["CLEAR"] = function()
    local _G = getfenv(0)
    local i = 1
    local f = _G["ChatFrame"..i]
    while f do
        f:Clear()
        i = i+1
        f = _G["ChatFrame"..i]
    end
end

-- https://en.wikipedia.org/wiki/HSL_and_HSL
-- @param h Hue (0-360)
-- @param s Saturation (0-1)
-- @param l Lightness (0-1)
function HSL(h, s, l)
    h, s, l = mod(abs(h), 360) / 60, abs(s), abs(l)
    if s > 1 then s = mod(s, 1) end
    if l > 1 then l = mod(l, 1) end
    local c = (1 - abs(2 * l - 1)) * s
    local x = c * (1 - abs(mod(h, 2) - 1))
    local r, g, b
    if h < 1 then
        r, g, b = c, x, 0
    elseif h < 2 then
        r, g, b = x, c, 0
    elseif h < 3 then
        r, g, b = 0, c, x
    elseif h < 4 then
        r, g, b = 0, x, c
    elseif h < 5 then
        r, g, b = x, 0, c
    else
        r, g, b = c, 0, x
    end
    local m = l - c / 2
    return r + m, g + m, b + m
end

-- -----------------------------------------------------------------------------
-- Attack Bar (v.2)

local _G = getfenv(0)

local locked = true
local active = false
local demo = false
local update = false

local attack_bars = {}

function AttackBarCore_OnLoad()
  this:RegisterEvent("ADDON_LOADED")
  --this:RegisterEvent("PLAYER_ENTER_COMBAT")
  this:RegisterEvent("PLAYER_LEAVE_COMBAT")
  --this:RegisterEvent("COMBAT_LOG_EVENT")
  --this:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  this:RegisterEvent("CHAT_MSG_COMBAT_SELF_HITS")
  this:RegisterEvent("CHAT_MSG_COMBAT_SELF_MISSES")
  --this:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS")
  --this:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES")
  --this:RegisterEvent("CHAT_MSG_COMBAT_HOSTILEPLAYER_HITS")
  --this:RegisterEvent("CHAT_MSG_COMBAT_HOSTILEPLAYER_MISSES")
  --this:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
  --this:RegisterEvent("UNIT_ATTACK_SPEED")
  --this:RegisterEvent("UNIT_SPELLCAST_SENT")
end

local function AttackBar_Activate(this)
  this.active = true
  this:Show()
end

local function AttackBar_Deactivate(this)
  this.active = false
  this:Hide()
end

local function AttackBar_Init(this, y, onUpdate)
  this:SetPoint("CENTER", 0, y)
  this.text = _G[this:GetName().."Text"]
  this.spark = _G[this:GetName().."Spark"]
  this.Activate = AttackBar_Activate
  this.Deactivate = AttackBar_Deactivate
  this.SetText = AttackBar_SetText
  if onUpdate then
    this:SetScript("OnUpdate", onUpdate)
  end
end

local function AttackBarOnUpdate(

local hue = 0
local function GamerPowerOnUpdate()
  local now = GetTime()
  this:SetValue(GetTime())
  hue = math.mod(hue + arg1*10, 360)
  this:SetStatusBarColor(HSL(hue, 1, 0.5))
  this.text:SetTextColor(HSL(hue+10, 1, 0.5))
  local min, max = this:GetMinMaxValues()
  if now > max then
    this:SetMinMaxValues(now, now+5)
  end
end

function AttackBarCore_OnEvent()
  if event == "ADDON_LOADED" and arg1 == "AttackBar2" then
    -- Setup attack bars
    table.insert(attack_bars, AttackBar_PlayerMH)
    table.insert(attack_bars, AttackBar_PlayerOH)
    table.insert(attack_bars, AttackBar_EnemyMH)
    table.insert(attack_bars, AttackBar_EnemyOH)
    table.insert(attack_bars, AttackBar_GamerPower)

    AttackBar_Init(AttackBar_PlayerMH,   -120)

    AttackBar_Init(AttackBar_PlayerOH,   -150)

    AttackBar_Init(AttackBar_EnemyMH,    -180)

    AttackBar_Init(AttackBar_EnemyOH,    -210)

    AttackBar_Init(AttackBar_GamerPower, -240, GamerPowerOnUpdate)
    AttackBar_GamerPower.text:SetText("Gamer Power")
    AttackBar_GamerPower:Activate()

  elseif event == "CHAT_MSG_COMBAT_SELF_HITS"
    or event == "CHAT_MSG_COMBAT_SELF_MISSES" then
    log("AttackBar_OnEvent("..event..")")
    AttackBar_PlayerMH:Activate()

  elseif event == "PLAYER_LEAVE_COMAT" then
    log("AttackBar_OnEvent("..event..")")
    AttackBar_PlayerMH:Deactivate()
  end
end

function AttackBar_OnMouseDown()
  if not locked and arg1 == "LeftButton" then
    this:StartMoving()
  end
end

function AttackBar_OnMouseUp()
  if arg1 == "LeftButton" then
    this:StopMovingOrSizing()
  end
end

function AttackBar_ToggleLocked(_locked)
  locked = _locked or (not locked)
  demo = not locked
  for i, f in ipairs(attack_bars) do
    if locked and not f.active then
      f:Hide()
    else
      f:Show()
    end
  end
end

local function SlashCommand(str)
  str = string.lower(str)
  if str == "lock" then
    AttackBar_ToggleLocked()
    log("AttackBar: "..(locked and "locked" or "unlocked"))
  else
    log("AttackBar: Usage")
    log("/ab [lock]")
  end
end

SlashCmdList["ATTACKBAR"] = SlashCommand
SLASH_ATTACKBAR1 = "/attackbar"
SLASH_ATTACKBAR2 = "/ab"
