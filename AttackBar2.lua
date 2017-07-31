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

function AttackBarCore_OnEvent()
  if event == "ADDON_LOADED" and arg1 == "AttackBar2" then
    log("AttackBar_OnEvent("..event..")")
    table.insert(attack_bars, AttackBar_PlayerMH)
    table.insert(attack_bars, AttackBar_PlayerOH)
    table.insert(attack_bars, AttackBar_EnemyMH)
    table.insert(attack_bars, AttackBar_EnemyOH)
    for i,f in ipairs(attack_bars) do
      f:SetPoint("CENTER", 0, -90-i*30)
      f.spark = _G[f:GetName().."Spark"]
    end

  elseif event == "CHAT_MSG_COMBAT_SELF_HITS"
    or event == "CHAT_MSG_COMBAT_SELF_MISSES" then
    log("AttackBar_OnEvent("..event..")")

  elseif event == "PLAYER_LEAVE_COMAT" then
    log("AttackBar_OnEvent("..event..")")
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

local delta = 3
local a, b = 0, 0
function AttackBar_OnUpdate()
  a = GetTime()
  if b < a then
    b = a + delta
    this:SetMinMaxValues(a, b)
  end
  this:SetValue(a)
  log(a)
end

function AttackBar_ToggleLocked(_locked)
  locked = _locked or (not locked)
  demo = not locked
  for i, f in ipairs(attack_bars) do
    if not locked then
      f:Show()
    else
      f:Hide()
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
