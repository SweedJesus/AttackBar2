-- Some utility stuff
-- TODO: Remove later (move somewhere else)
local function print(msg)
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

AttackBarCore.locked = true
local core = AttackBarCore

local attack_bars = {}

-- AttackBar initialization
local function AttackBar_Init(this, y)
  this:SetPoint("CENTER", 0, y)
  this.text = _G[this:GetName().."Text"]
  this.spark = _G[this:GetName().."Spark"]
  this.nextOnUpdate = nil
end

-- AttackBar OnUpdate script handler (combat)
local function AttackBar_OnUpdate()
  local now = GetTime()
  this:SetValue(now)
  if now > this.max then
    this:SetScript(this.nextOnUpdate)
    if not UnitAffectingCombat("player") then
      this:Hide()
    end
  end
end

-- AttackBar OnUpdate script handler (demo)
local function AttackBar_OnUpdateDemo()
  local now = GetTime()
  this:SetValue(now)
  if now > this.max then
    this.max = now + 3
    this:SetMinMaxValue(now, this.max)
  end
end

-- GamerPower OnUpdate script handler
local hue = 0
local function GamerPower_OnUpdate()
  local now = GetTime()
  this:SetValue(now)
  hue = math.mod(hue + arg1*10, 360)
  this:SetStatusBarColor(HSL(hue, 1, 0.5))
  this.text:SetTextColor(HSL(hue+10, 1, 0.5))
  if now > this.max then
    this.max = now+5
    this:SetMinMaxValues(now, this.max)
  end
end

-- AttackBar OnMouseDown script handler
function AttackBar_OnMouseDown()
  if not locked and arg1 == "LeftButton" then
    this:StartMoving()
  end
end

-- AttackBar OnMouseUp script handler
function AttackBar_OnMouseUp()
  if arg1 == "LeftButton" then
    this:StopMovingOrSizing()
  end
end

-- AttackBarCore OnLoad script handler
function AttackBarCore_OnLoad()
  this:RegisterEvent("ADDON_LOADED")
  this:RegisterEvent("PLAYER_ENTER_COMBAT")
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

-- AttackBarCore OnEvent script handler
function AttackBarCore_OnEvent()
  if event == "ADDON_LOADED" and arg1 == "AttackBar2" then
    -- Setup attack bars
    table.insert(attack_bars, AttackBar_PlayerMH)
    table.insert(attack_bars, AttackBar_PlayerOH)
    table.insert(attack_bars, AttackBar_EnemyMH)
    table.insert(attack_bars, AttackBar_EnemyOH)
    table.insert(attack_bars, AttackBar_GamerPower)

    AttackBar_Init(AttackBar_PlayerMH, -120)
    AttackBar_PlayerMH.text:SetText(UnitName("player").." MH")

    AttackBar_Init(AttackBar_PlayerOH, -150)
    AttackBar_PlayerOH.text:SetText(UnitName("player").." OH")

    AttackBar_Init(AttackBar_EnemyMH, -180)
    AttackBar_EnemeyMH.text:SetText(UnitName("target")or"Enemy".." MH")

    AttackBar_Init(AttackBar_EnemyOH, -210)
    AttackBar_EnemeyOH.text:SetText(UnitName("target")or"Enemy".." OH")

    AttackBar_Init(AttackBar_GamerPower, -240)
    AttackBar_GamerPower.text:SetText("Gamer Power")
    AttackBar_GamerPower:Show()
    AttackBar_GamerPower:SetScript("OnUpdate", GamerPower_OnUpdate)

  elseif event == "PLAYER_ENTER_COMBAT" then
    AttackBarCore_ToggleLocked(true, true)

  elseif event == "PLAYER_LEAVE_COMBAT" then
    f.nextOnUpdate = nil

  elseif event == "CHAT_MSG_COMBAT_SELF_HITS"
    or event == "CHAT_MSG_COMBAT_SELF_MISSES" then
    local now = GetTime()
    local player_mh_speed = 1 -- TODO: Get attack speed value
    f.max = now + player_mh_speed
    f:SetMinMaxValues(now, this.max)
    f:SetScript("OnUpdate", AttackBar_OnUpdate)
  end
end

function AttackBarCore_ToggleLocked(locked, force)
  force = force or false
  if not force and UnitAffectingCombat("player") then
    print("In combat!")
    return
  end
  core.locked = locked or not core.locked
  for i, f in ipairs(attack_bars) do
    if core.locked then
      f.nextOnUpdate = nil
      if not f.active then
        f.active = true
        f:Hide()
      end
    else
      f:SetScript("OnUpdate", AttackBar_OnUpdateDemo)
      f:Show()
    end
  end
end

local function SlashCommand(str)
  str = string.lower(str)
  if str == "lock" then
    AttackBarCore_ToggleLocked()
    print("AttackBar: "..(locked and "locked" or "unlocked"))
  else
    print("AttackBar: Usage")
    print("/ab [lock]")
  end
end

SlashCmdList["ATTACKBAR"] = SlashCommand
SLASH_ATTACKBAR1 = "/attackbar"
SLASH_ATTACKBAR2 = "/ab"
