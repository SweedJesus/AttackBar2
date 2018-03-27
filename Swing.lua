-- Some utility stuff
-- TODO: Remove later (move somewhere else)

local print = print or function(msg)
	DEFAULT_CHAT_FRAME:AddMessage(msg)
end

local function contains(t, v)
	return t[v] ~= nil
end

local function patternMatch(patterns, text)
	local a, b, c, d, e, f, g, h
	for _, p in ipairs(patterns) do
		a, b, c, d, e, f, g, h = string.find(text, p)
		if a then return a, b, c, d, e, f, g, h end
	end
	return nil
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
local function HSL(h, s, l)
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
-- Swing addon

local _G = getfenv(0)

-- Upvalues, constants, enums

local gaymerDelta = 3
local gaymerHue = 0
local gaymerHueDelta = 20

local oldEnergy = UnitMana("player")

local bars = {}
local util, playerMH, playerOH, targetMH, targetOH

local pMHSpeed, pOHSpeed = 0, 0
local pMHCount, pOHCount = 0, 0

local tMHSpeed, tOHSpeed = 0, 0
local tMHCount, tOHCount = 0, 0

local BAR_WIDTH = 195 -- see the XML template
local MH, OH = 0, 1
local ATTACK_SPELLS = {
	["Heroic Strike"] = true,
	["Raptor Strike"] = true,
	["Maul"] = true,
	["Cleave"] = true
}
local PLAYER_SPELL_PATTERNS = {
	"Your (.+) hits",
	"Your (.+) crits",
	"Your (.+) missed",
	"Your (.+) was", -- dodged
	"Your (.+) is" -- parried
}
local ENEMY_ATTACK_PATTERNS = {
	"(.+) hits you",
	"(.+) crits you",
	"(.+) misses you",
	"(.+) attacks%. You" -- dodge/parry
}
local ENEMY_SPELL_PATTERNS = {
	"(.+)'s (.+) hits you",
	"(.+)'s (.+) crits you",
	"(.+)'s (.+) misses you",
	"(.+)'s (.+) was" -- dodged/parried
}

-- Bar initialization helper
local function InitBar(this, func, r, g, b)
  this.text = _G[this:GetName().."Text"]
  this.spark = _G[this:GetName().."Spark"]
	this.max = 0
	this.before = 0
  this.later = 0
  this.active = false
  this.spark:SetAlpha(1)
	this:SetScript("OnUpdate", func)
	this:SetStatusBarColor(r, g, b)
end

local function InitSwingBar(this, func, unit, hand, r, g, b)
	InitBar(this, func, r, g, b)
	this.unit = unit
	this.hand = hand
	-- this.minDmg = 0
	-- this.maxDmg = 0
	this.count = 0
end

--- Timer bar updater
local function UpdateBar(this, now)
	this:SetValue(now)
	this.spark:Show()
	this.spark:SetAlpha(1)
	this.spark:SetPoint("CENTER", this, "LEFT", (this.max - (this.later - now)) / this.max * BAR_WIDTH, 0)
end

--- Timer bar starter
local function StartBar(this, now, speed)
	this.max = speed
	this.before = now
	this.later = now + speed
	this:SetMinMaxValues(now, now + speed)
	this:Show()
	this.active = true
end

--- Bar update handler
local function BarOnUpdate()
  if this.active then
		local now = GetTime()
		if now >= this.later then
			this.active = false
		end
		UpdateBar(this, now)
		--this.text:SetText(format("%5.2f", max(0, delta)))
  else
    -- local sparkAlpha = this.spark:GetAlpha()
    -- if sparkAlpha > 0 then
      -- sparkAlpha = max(sparkAlpha - CASTING_BAR_ALPHA_STEP, 0)
      -- this.spark:SetAlpha(sparkAlpha)
    -- end
    if not UnitAffectingCombat("player") then
      this:Hide()
    end
  end
end

--- Bar update handler (demo mode)
local function BarDemoOnUpdate()
	local now = GetTime()
	if now >= this.later then
		local mhSpeed, ohSpeed = UnitAttackSpeed(this.unit)
		local speed = gaymerDelta
		if mhSpeed > 0 then
			if this.hand == MH then
				speed = mhSpeed
			elseif this.hand == OH then
				speed = ohSpeed or mhSpeed
			end
		end
		StartBar(this, now, speed)
  end
	UpdateBar(this, now)
	-- this.text:SetText(format("%5.2f", max(0, delta)))
end

local function EnergyOnUpdate()
	local now = GetTime()
	local energy = UnitMana("player")
	if now >= this.later or energy > oldEnergy then -- Energy tick time is 2 seconds
		oldEnergy = energy
		StartBar(this, now, 2)
	elseif energy < oldEnergy then
		oldEnergy = energy
	end
	UpdateBar(this, now)
end

--- Special bar (GaymerPower) update handler
local function GaymerPowerOnUpdate()
	local now = GetTime()
  gaymerHue = math.mod(gaymerHue + arg1*gaymerHueDelta, 360)
	local r1, g1, b1 = HSL(gaymerHue, 1, 0.5)
	local r2, g2, b2 = HSL(gaymerHue+180, 1, 0.5)
  this:SetStatusBarColor(r1, g1, b1)
  this.text:SetTextColor(r2, g2, b2)
  if now >= this.later then
		StartBar(this, now, gaymerDelta)
  end
	UpdateBar(this, now)
end

local function UtilToEnergy()
	local now = GetTime()
	util:SetStatusBarColor(255, 255, 0)
	util:SetScript("OnUpdate", EnergyOnUpdate)
	util.text:SetText("")
	StartBar(util, now, 2)
end

local function UtilToGaymer()
	local now = GetTime()
	util:SetStatusBarColor(HSL(gaymerHue, 1, 0.5))
	util:SetScript("OnUpdate", GaymerPowerOnUpdate)
	util.text:SetText("Gaymer Power")
	StartBar(util, now, gaymerDelta)
end

--- Get the ID of the weapon that the player swung
-- @return 1 (true) for MH, 0 (false) for OH
-- TODO: Describe the model behind this (for myself, because it seems accurate
-- but I mostly just guessed and tested until it looked so)
local function GetPlayerSwungWeapon(now)
	return
		(pMHCount == 0 and pOHCount == 0) or
		(abs(now - playerMH.before - pMHSpeed) <=
			abs(now - playerOH.before - pOHSpeed)) or
		(pMHCount >= pMHSpeed / pOHSpeed)
end

--- Player swing helper
local function PlayerSwing()
	local now = GetTime()
	pMHSpeed, pOHSpeed = UnitAttackSpeed("player")
	-- playerMH.minDmg, playerMH.maxDmg, playerOH.minDmg, playerOH.maxDmg = UnitDamage("player")
	if pOHSpeed then  -- Has OH
		if GetPlayerSwungWeapon(now) then  -- Swung MH
			pOHCount = 0
			pMHCount = pMHCount + 1
			StartBar(playerMH, now, pMHSpeed)
		else  -- Swung OH
			pMHCount = 0
			pOHCount = pOHCount + 1
			StartBar(playerOH, now, pOHSpeed)
		end
	else  -- Swung MH (no OH)
		pMHCount = 0
		pOHCount = 0
		StartBar(playerMH, now, pMHSpeed)
	end
end

--- Get the ID of the weapon that the target swung
local function GetTargetSwungWeapon()
	return
		tOHSpeed ~= nil or
		(tMHCount == 0 and tOHCount == 0) or
		(abs(now - targetMH.before - tMHSpeed) <=
			abs(now - targetOH.before - tOHSpeed)) or
		(tMHCount >= tMHSpeed / tOHSpeed)
end

--- Target swing helper
local function TargetSwing()
	local now = GetTime()
	tMHSpeed, tOHSpeed = UnitAttackSpeed("target")
	if tOHSpeed then  -- Has OH
		if GetTargetSwungWeapon() then  -- Swung MH
			StartBar(targetMH, now, tMHSpeed)
		else  -- Swung OH
			StartBar(targetOH, now, tOHSpeed)
		end
	else  -- Swung MH (no OH)
		StartBar(targetMH, now, tMHSpeed)
	end
end

--- Reset target timer bars
local function ResetTarget()
	local now = GetTime()
	if Swing.locked then
		targetMH:Hide()
		targetOH:Hide()
	else -- Demo mode
		if UnitExists("target") then
			local mhSpeed, ohSpeed = UnitAttackSpeed("target")
			StartBar(targetMH, now, mhSpeed)
			StartBar(targetOH, now, ohSpeed or mhSpeed)
		else
			StartBar(targetMH, now, gaymerDelta)
			StartBar(targetOH, now, gaymerDelta)
		end
	end
end
	
---	Bar lock toggle and demo mode
local function ToggleLocked(locked, force)
  force = force or false
  if not force and UnitAffectingCombat("player") then
    print("Unlocking disabled while in combat!")
    return
  end
  Swing.locked = locked or not Swing.locked
  for i, f in ipairs(bars) do
    if Swing.locked then
			if not UnitAffectingCombat("player") then
				f:SetScript("OnUpdate", BarOnUpdate)
				f.active = false
				f:Hide()
			end
    else
      f:SetScript("OnUpdate", BarDemoOnUpdate)
			f.later = 0
      f.spark:SetAlpha(1)
      f:Show()
    end
  end
end

--- Core and frame initialization
local function OnVarsLoaded()
	playerMH = Swing_PlayerMH
	playerOH = Swing_PlayerOH
	targetMH = Swing_TargetMH
	targetOH = Swing_TargetOH
	util = Swing_Util
	
	InitSwingBar(playerMH, BarOnUpdate, "player", MH, HSL(240, 1, 0.5))
	InitSwingBar(playerOH, BarOnUpdate, "player", OH, HSL(220, 1, 0.5))
	InitSwingBar(targetMH, BarOnUpdate, "target", MH, HSL(0,   1, 0.5))
	InitSwingBar(targetOH, BarOnUpdate, "target", OH, HSL(20,  1, 0.5))
	
	table.insert(bars, playerMH)
	table.insert(bars, playerOH)
	table.insert(bars, targetMH)
	table.insert(bars, targetOH)

	util:Show()
	_, class = UnitClass("player")
	if class == "ROGUE" then
		InitBar(util, EnergyOnUpdate, 255, 255, 0)
		UtilToEnergy()
	else
		InitBar(util, GaymerPowerOnUpdate)
		UtilToGaymer()
	end
end

local function ResetFrame(this, xOff, yOff)
	this:ClearAllPoints()
	this:SetPoint("BOTTOM", UIParent, xOff, yOff)
end

---	Registered event handler
function Swing_OnEvent()
	local now = GetTime()
	if event == "VARIABLES_LOADED" then
		OnVarsLoaded()
  elseif event == "PLAYER_ENTER_COMBAT" then
		ToggleLocked(true, true)
		playerMH.before = now
		playerOH.before = now
		targetMH.before = now
		targetOH.before = now
	elseif event == "PLAYER_TARGET_CHANGED" then
		ResetTarget()
  elseif event == "CHAT_MSG_COMBAT_SELF_HITS" or
	       event == "CHAT_MSG_COMBAT_SELF_MISSES" then
		PlayerSwing()
	elseif event == "CHAT_MSG_SPELL_SELF_DAMAGE" then
		local _, _, spell = patternMatch(PLAYER_SPELL_PATTERNS, arg1)
		if contains(ATTACK_SPELLS, spell) then
			PlayerSwing()
		end
	elseif event == "CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS" or
					event == "CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES" then
		TargetSwing()
	elseif event == "CHAT_MSG_COMBAT_HOSTILEPLAYER_HITS" or
					event == "CHAT_MSG_COMBAT_HOSTILEPLAYER_MISSES" then
		local _, _, hitter = patternMatch(ENEMY_ATTACK_PATTERNS, arg1)
		local target = UnitName("target")
		if target and hitter == target then
			TargetSwing()
		end
	elseif event == "CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE" or
					event == "CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE" then
		local _, _, hitter, spell = patternMatch(ENEMY_SPELL_PATTERNS, arg1)
		local target = UnitName("target")
		if target and hitter == target and contains(ATTACK_SPELLS, spell) then
			TargetSwing()
		end
	elseif event == "UNIT_MAXENERGY" then
		UtilToEnergy()
	elseif event == "UNIT_DISPLAYPOWER" then
		if UnitPowerType("player") == 3 then
			UtilToEnergy()
		else
			UtilToGaymer()
		end
	-- elseif event == "UNIT_ENERGY" then
		-- StartBar(util, now, 2)
  end
end

---	Slash command function
function SlashCommand(str)
  str = string.lower(str)
  if str == "lock" then
    ToggleLocked()
    print("[Swing] Attack bars "..(Swing.locked and "locked" or "unlocked"))
  elseif str == "reset-positions" then
		ResetFrame(util, 0, 170)
		ResetFrame(playerMH, -120, 230)
		ResetFrame(playerOH, -120, 200)
		ResetFrame(targetMH, 120, 230)
		ResetFrame(targetOH, 120, 200)
  else
    print("[Swing]")
    print("Usage: /ab <lock/reset-positions>")
  end
end

function Swing_OnLoad()
	this.locked = true
	
	this:RegisterEvent("VARIABLES_LOADED")
	-- this:RegisterEvent("UNIT_ENERGY")
	this:RegisterEvent("UNIT_MAXENERGY")
	this:RegisterEvent("UNIT_DISPLAYPOWER")
	this:RegisterEvent("PLAYER_ENTER_COMBAT")
	this:RegisterEvent("PLAYER_LEAVE_COMBAT")
	this:RegisterEvent("PLAYER_TARGET_CHANGED")
	this:RegisterEvent("CHAT_MSG_COMBAT_SELF_HITS")
	this:RegisterEvent("CHAT_MSG_COMBAT_SELF_MISSES")
	this:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
	this:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS")
	this:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES")
	this:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE")
	this:RegisterEvent("CHAT_MSG_COMBAT_HOSTILEPLAYER_HITS")
	this:RegisterEvent("CHAT_MSG_COMBAT_HOSTILEPLAYER_MISSES")
	this:RegisterEvent("CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE")
	-- this:RegisterEvent("COMBAT_LOG_EVENT")
	-- this:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	-- this:RegisterEvent("UNIT_ATTACK_SPEED")
	-- this:RegisterEvent("UNIT_SPELLCAST_SENT")
	
	SlashCmdList["SWING"] = SlashCommand
	SLASH_SWING1 = "/swing"
end

-- TODO: Remove when done testing
Swing_UtilToEnergy = UtilToEnergy
Swing_UtilToGaymer = UtilToGaymer