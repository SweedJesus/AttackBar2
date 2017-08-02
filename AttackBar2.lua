-- Some utility stuff
-- TODO: Remove later (move somewhere else)
local function print(msg)
    DEFAULT_CHAT_FRAME:AddMessage(msg)
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
if not HSL then
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
end

-- -----------------------------------------------------------------------------
-- AttackBar2

local _G = getfenv(0)

local attackBars = {}

-- AttackBar initialization
local function AttackBar_Init(this)
  this.text = _G[this:GetName().."Text"]
  this.spark = _G[this:GetName().."Spark"]
  this.nextOnUpdate = nil
  this.min = 0
  this.max = 0
  this.active = false
  this.spark:SetAlpha(0)
end

-- AttackBar OnUpdate script handler (combat)
local function AttackBar_OnUpdate()
  if this.active then
    local now = GetTime()
    this:SetValue(now)
    local sparkPos = (now - this.min) / (this.max - this.min) * 195
    this.spark:SetPoint("CENTER", this, "LEFT", sparkPos, 0)
    if now > this.max then
      this.active = false
    end
  else
    local sparkAlpha = this.spark:GetAlpha()
    if sparkAlpha > 0 then
      sparkAlpha = math.max(sparkAlpha - CASTING_BAR_ALPHA_STEP, 0)
      this.spark:SetAlpha(sparkAlpha)
    end
    if not UnitAffectingCombat("player") then
      this:Hide()
    end
  end
end

-- AttackBar OnUpdate script handler (demo)
local function AttackBar_OnUpdateDemo()
  local now = GetTime()
  this:SetValue(now)
  local sparkPos = (now - this.min) / (this.max - this.min) * 195
  this.spark:SetPoint("CENTER", this, "LEFT", sparkPos, 0)
  if now > this.max then
    this.min = now
    this.max = now + 3
    this:SetMinMaxValues(now, this.max)
  end
end

-- GamerPower OnUpdate script handler
local hue = 0
local function GamerPower_OnUpdate()
  local now = GetTime()
  this:SetValue(now)
  --CastingBarFrame_OnUpdate(this, arg1)
  hue = math.mod(hue + arg1*10, 360)
  this:SetStatusBarColor(HSL(hue, 1, 0.5))
  this.text:SetTextColor(HSL(hue+10, 1, 0.5))
  local sparkPos = (now - this.min) / (this.max - this.min) * 195
  this.spark:SetPoint("CENTER", this, "LEFT", sparkPos, 0)
  if now > this.max then
    this.min = now
    this.max = now+5
    this:SetMinMaxValues(now, this.max)
  end
end

-- AttackBar OnMouseDown script handler
function AttackBar_OnMouseDown()
  if not AttackBarCore.locked and arg1 == "LeftButton" then
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
  this.locked = true
  -- Events I know I need:
  this:RegisterEvent("ADDON_LOADED")
  this:RegisterEvent("PLAYER_ENTER_COMBAT")
  this:RegisterEvent("PLAYER_LEAVE_COMBAT")
  this:RegisterEvent("CHAT_MSG_COMBAT_SELF_HITS")
  this:RegisterEvent("CHAT_MSG_COMBAT_SELF_MISSES")
  this:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
  -- Events that aren't implemented or have no idea about:
  --this:RegisterEvent("COMBAT_LOG_EVENT")
  --this:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  --this:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS")
  --this:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES")
  --this:RegisterEvent("CHAT_MSG_COMBAT_HOSTILEPLAYER_HITS")
  --this:RegisterEvent("CHAT_MSG_COMBAT_HOSTILEPLAYER_MISSES")
  --this:RegisterEvent("UNIT_ATTACK_SPEED")
  --this:RegisterEvent("UNIT_SPELLCAST_SENT")
end

-- AttackBarCore OnEvent script handler
function AttackBarCore_OnEvent()
  if event == "ADDON_LOADED" and arg1 == "AttackBar2" then
    -- Enemy main-hand
    table.insert(attackBars, AttackBar_PlayerMH)
    AttackBar_Init(AttackBar_PlayerMH)
    AttackBar_PlayerMH.text:SetText("Player MH")
    AttackBar_PlayerMH:SetStatusBarColor(HSL(240, 1, 0.5))
    AttackBar_PlayerMH:SetScript("OnUpdate", AttackBar_OnUpdate)

    -- Enemy off-hand
    table.insert(attackBars, AttackBar_PlayerOH)
    AttackBar_Init(AttackBar_PlayerOH)
    AttackBar_PlayerOH.text:SetText("Player OH")
    AttackBar_PlayerOH:SetStatusBarColor(HSL(220, 1, 0.5))
    AttackBar_PlayerOH:SetScript("OnUpdate", AttackBar_OnUpdate)

    -- Enemy main-hand
    table.insert(attackBars, AttackBar_EnemyMH)
    AttackBar_Init(AttackBar_EnemyMH)
    AttackBar_EnemyMH.text:SetText("Enemy MH")
    AttackBar_EnemyMH:SetStatusBarColor(HSL(0, 1, 0.5))
    AttackBar_EnemyMH:SetScript("OnUpdate", AttackBar_OnUpdate)

    -- Enemy off-hand
    table.insert(attackBars, AttackBar_EnemyOH)
    AttackBar_Init(AttackBar_EnemyOH)
    AttackBar_EnemyOH.text:SetText("Enemy OH")
    AttackBar_EnemyOH:SetStatusBarColor(HSL(20, 1, 0.5))
    AttackBar_EnemyOH:SetScript("OnUpdate", AttackBar_OnUpdate)

    -- Gaymer Power joke bar
    AttackBar_Init(AttackBar_GamerPower)
    AttackBar_GamerPower.text:SetText("Gaymer Power")
    AttackBar_GamerPower.spark:SetAlpha(1)
    AttackBar_GamerPower:Show()
    AttackBar_GamerPower:SetScript("OnUpdate", GamerPower_OnUpdate)

  elseif event == "PLAYER_ENTER_COMBAT" then
    AttackBarCore_ToggleLocked(true, true)

  elseif
    event == "CHAT_MSG_COMBAT_SELF_HITS" or
    event == "CHAT_MSG_COMBAT_SELF_MISSES" or
    event == "CHAT_MSG_SPELL_SELF_DAMAGE" and
    string.find(arg1, "Heroic Strike") then
    local now = GetTime()
    local player_mh_speed, player_oh_speed = UnitAttackSpeed("player")
    AttackBar_PlayerMH.min = now
    AttackBar_PlayerMH.max = now + player_mh_speed
    AttackBar_PlayerMH:SetMinMaxValues(now, AttackBar_PlayerMH.max)
    AttackBar_PlayerMH.active = true
    AttackBar_PlayerMH.spark:SetAlpha(1)
    AttackBar_PlayerMH:Show()
  end
end

function AttackBarCore_ToggleLocked(locked, force)
  force = force or false
  if not force and UnitAffectingCombat("player") then
    print("In combat!")
    return
  end
  AttackBarCore.locked = locked or not AttackBarCore.locked
  for i, f in ipairs(attackBars) do
    f.max = 0
    if AttackBarCore.locked then
      --f.nextOnUpdate = nil
      f:SetScript("OnUpdate", AttackBar_OnUpdate)
      f.active = false
      f:Hide()
    else
      f:SetScript("OnUpdate", AttackBar_OnUpdateDemo)
      f.spark:SetAlpha(1)
      f:Show()
    end
  end
end

local function AttackBar_SlashCommand(str)
  str = string.lower(str)
  if str == "lock" then
    AttackBarCore_ToggleLocked()
    print("AttackBar: Attack bars "..(locked and "locked" or "unlocked"))
  elseif str == "reset-positions" then
    AttackBar_PlayerMH:ClearAllPoints()
    AttackBar_PlayerMH:SetPoint("CENTER", 0, -120)

    AttackBar_PlayerOH:ClearAllPoints()
    AttackBar_PlayerOH:SetPoint("CENTER", 0, -150)

    AttackBar_EnemyMH:ClearAllPoints()
    AttackBar_EnemyMH:SetPoint("CENTER", 0, -180)

    AttackBar_EnemyOH:ClearAllPoints()
    AttackBar_EnemyOH:SetPoint("CENTER", 0, -210)

    AttackBar_GamerPower:ClearAllPoints()
    AttackBar_GamerPower:SetPoint("CENTER", 0, -240)
  else
    print("AttackBar: Usage")
    print("/ab [lock] [reset-positions]")
  end
end

SlashCmdList["ATTACKBAR"] = AttackBar_SlashCommand
SLASH_ATTACKBAR1 = "/attackbar"
SLASH_ATTACKBAR2 = "/ab"
