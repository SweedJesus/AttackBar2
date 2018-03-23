-- Some utility stuff
-- TODO: Remove later (move somewhere else)
function print(msg)
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
SLASH_CLEAR1 = "/clear"

SlashCmdList["PRINT"] = print
SLASH_PRINT1 = "/print"

SlashCmdList["RL"] = ReloadUI
SLASH_RL1 = "/rl"


--- HSL to RGB
-- From https://en.wikipedia.org/wiki/HSL_and_HSL
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

local bar_width = 195 -- see the XML template

local GAYMER_DELTA = 3

-- Bar initialization helper
local function AttackBar_InitBar(frame)
  frame.ltext = _G[frame:GetName().."LText"]
  frame.rtext = _G[frame:GetName().."RText"]
  frame.spark = _G[frame:GetName().."Spark"]
  frame.nextOnUpdate = nil
  frame.now = 0
  frame.later = 0
  frame.active = false
  frame.spark:SetAlpha(0)
end

--- Bar update handler
local function AttackBar_OnUpdate()
	-- TODO: Fix if for MH or OH, and if for player or target
  if this.active then
		local now = GetTime()
		local delta = this.later - now
		if delta <= 0 then
			this.active = false
			this.rtext:SetText("")
			return
		end
		this:SetValue(delta)
		this.rtext:SetText(format("%5.2f", max(0, delta)))
		this.spark:SetPoint("CENTER", this, "LEFT", delta / this.max * bar_width, 0)
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

--- Bar update handler (demo mode)
local function AttackBar_OnUpdateDemo()
	-- TODO: Fix if for MH or OH, and if for player or target
  local now = GetTime()
	local delta = this.later - now
	if delta <= 0 then
		local player_mh_speed, player_oh_speed = UnitAttackSpeed("player")
		this.max = player_mh_speed
		this.later = now + player_mh_speed
		this:SetMinMaxValues(0, player_mh_speed)
		return
  end
  this:SetValue(delta)
	this.rtext:SetText(format("%5.2f", max(0, delta)))
  this.spark:SetPoint("CENTER", this, "LEFT", delta / this.max * bar_width, 0)
end

--- Special bar (GaymerPower) update handler
local hue = 0
local function GamerPower_OnUpdate()
  local now = GetTime()
	local delta = this.later - now
  if delta <= 0 then
    this.max = GAYMER_DELTA
		this.later = now + GAYMER_DELTA
    this:SetMinMaxValues(0, GAYMER_DELTA)
		return
  end
  this:SetValue(delta)
  hue = math.mod(hue + arg1*10, 360)
	local r1, g1, b1 = HSL(hue, 1, 0.5)
	local r2, g2, b2 =  r1, g1, b1
  this:SetStatusBarColor(r1, g1, b1)
  this.ltext:SetTextColor(r2, g2, b2)
  this.rtext:SetTextColor(r2, g2, b2)
  this.spark:SetPoint("CENTER", this, "LEFT", delta / this.max * bar_width, 0)
end

--- Bar mouse down handler
function AttackBar_OnMouseDown()
  if not AttackBarCore.locked and arg1 == "LeftButton" then
    this:StartMoving()
  end
end

--- Bar mouse up handler
function AttackBar_OnMouseUp()
  if arg1 == "LeftButton" then
    this:StopMovingOrSizing()
  end
end

--- Startup handler
function AttackBar_OnLoad()
	this.locked = true
	-- Events I know I need
	this:RegisterEvent("VARIABLES_LOADED")
	this:RegisterEvent("PLAYER_ENTER_COMBAT")
	this:RegisterEvent("PLAYER_LEAVE_COMBAT")
	this:RegisterEvent("CHAT_MSG_COMBAT_SELF_HITS")
	this:RegisterEvent("CHAT_MSG_COMBAT_SELF_MISSES")
	this:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
	this:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS")
	this:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES")
	this:RegisterEvent("CHAT_MSG_COMBAT_HOSTILEPLAYER_HITS")
	this:RegisterEvent("CHAT_MSG_COMBAT_HOSTILEPLAYER_MISSES")
	-- Events that aren't implemented or that I have no idea about
	-- this:RegisterEvent("COMBAT_LOG_EVENT")
	-- this:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	-- this:RegisterEvent("UNIT_ATTACK_SPEED")
	-- this:RegisterEvent("UNIT_SPELLCAST_SENT")
end

--- Core and frame initialization
function AttackBar_Init()
	-- Enemy main-hand
	table.insert(attackBars, AttackBar_PlayerMH)
	AttackBar_InitBar(AttackBar_PlayerMH)
	AttackBar_PlayerMH.ltext:SetText("P MH")
	AttackBar_PlayerMH:SetStatusBarColor(HSL(240, 1, 0.5))
	AttackBar_PlayerMH:SetScript("OnUpdate", AttackBar_OnUpdate)

	-- Enemy off-hand
	table.insert(attackBars, AttackBar_PlayerOH)
	AttackBar_InitBar(AttackBar_PlayerOH)
	AttackBar_PlayerOH.ltext:SetText("P OH")
	AttackBar_PlayerOH:SetStatusBarColor(HSL(220, 1, 0.5))
	AttackBar_PlayerOH:SetScript("OnUpdate", AttackBar_OnUpdate)

	-- Enemy main-hand
	table.insert(attackBars, AttackBar_EnemyMH)
	AttackBar_InitBar(AttackBar_EnemyMH)
	AttackBar_EnemyMH.ltext:SetText("E MH")
	AttackBar_EnemyMH:SetStatusBarColor(HSL(0, 1, 0.5))
	AttackBar_EnemyMH:SetScript("OnUpdate", AttackBar_OnUpdate)

	-- Enemy off-hand
	table.insert(attackBars, AttackBar_EnemyOH)
	AttackBar_InitBar(AttackBar_EnemyOH)
	AttackBar_EnemyOH.ltext:SetText("E OH")
	AttackBar_EnemyOH:SetStatusBarColor(HSL(20, 1, 0.5))
	AttackBar_EnemyOH:SetScript("OnUpdate", AttackBar_OnUpdate)

	-- Gaymer Power bar
	AttackBar_InitBar(AttackBar_GamerPower)
	AttackBar_GamerPower.ltext:SetText("Gaymer Power")
	AttackBar_GamerPower.spark:SetAlpha(1)
	AttackBar_GamerPower:Show()
	AttackBar_GamerPower:SetScript("OnUpdate", GamerPower_OnUpdate)
	
	AttackBar_ToggleLocked(false) -- for testing, remove later
end

--- Attack hit handler
-- @global arg1 Combat log string for event
--		          e.g. "You hit Mottled Boar for 11"
function AttackBar_SelfHit()
	local mh_speed, oh_speed = UnitAttackSpeed("player")
	local mh_min_dmg, mh_max_dmg, oh_min_dmg, oh_max_dmg = UnitDamage("player")
	if oh_speed then
		
	end
	
	AttackBar_PlayerMH.max = mh_speed
	AttackBar_PlayerMH.later = GetTime() + mh_speed
	AttackBar_PlayerMH:SetMinMaxValues(0, mh_speed)
	AttackBar_PlayerMH.active = true
	AttackBar_PlayerMH.spark:SetAlpha(1)
	AttackBar_PlayerMH:Show()
end

--- Spell hit handler
-- @global arg1 Combat log string for event
--		          e.g. "Your Heroic Strike hits Mottled Boar for 24"
function AttackBar_SelfSpellHit()
	if string.find(arg1, "Heroic Strike") then
		AttackBar_SelfHit(logString)
	end
end

---	Registered event handler
function AttackBar_OnEvent()
	if event == "VARIABLES_LOADED" then
		AttackBar_Init()
  elseif event == "PLAYER_ENTER_COMBAT" then
		AttackBar_ToggleLocked(true, true)
  elseif event == "CHAT_MSG_COMBAT_SELF_HITS" or event == "CHAT_MSG_COMBAT_SELF_MISSES" then
		AttackBar_SelfHit()
	elseif event == "CHAT_MSG_SPELL_SELF_DAMAGE" then
		AttackBar_SelfSpellHit()
  end
end

---	Frame lock toggle
function AttackBar_ToggleLocked(locked, force)
  force = force or false
  if not force and UnitAffectingCombat("player") then
    print("Unlocking disabled while in combat!")
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
			f.later = 0
      f.spark:SetAlpha(1)
      f:Show()
    end
  end
end

---	Chat command function
function AttackBar_SlashCommand(str)
  str = string.lower(str)
  if str == "lock" then
    AttackBar_ToggleLocked()
    print("[AttackBar] Attack bars "..(AttackBarCore.locked and "locked" or "unlocked"))
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
    print("[AttackBar]")
    print("Usage: /ab <lock/reset-positions>")
  end
end

SlashCmdList["ATTACKBAR"] = AttackBar_SlashCommand
SLASH_ATTACKBAR1 = "/attackbar"
SLASH_ATTACKBAR2 = "/ab"