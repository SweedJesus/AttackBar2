p_mh_time=0.000
p_oh_time= 0.000
now = 0.000
now = 0.000
p_mh_speed = 0.000
p_oh_speed= 0.000
p_oh_swings = 0
p_mh_swings  = 0
epont=0.000
epofft= 0.000
eont = 0.000
eofft= 0.000
eons = 0.000
eoffs= 0.000
eoffh = 0
eonh  = 0
testvar = 0
if not(abar) then abar={} end
-- cast spell by name hook
--preabar_csbn = CastSpellByName
--function abar_csbn(pass, onSelf)
--	preabar_csbn(pass, onSelf)
--	abar_spelldir(pass)
--end
--CastSpellByName = abar_csbn
--use action hook
--preabar_useact = UseAction
--function abar_useact(p1,p2,p3)
--	preabar_useact(p1,p2,p3)
--    local a,b = IsUsableAction(p1)
--    if a then
--    	if UnitCanAttack("player","target" )then
--    		if IsActionInRange(p1) == 1 then
--			Abar_Tooltip:ClearLines()
--			Abar_Tooltip:SetAction(p1)
--    	local spellname = Abar_TooltipTextLeft1:GetText()
--	local spellname = UnitCastingInfo("player") 
--    	if spellname then abar_spelldir(spellname) end
--    	end
--    	end
--    end
--end
--UseAction = abar_useact
--castspell hook
--preabar_cassple = CastSpell
--function abar_casspl(p1,p2)
--	preabar_cassple(p1,p2)
--	local spell = GetSpellName(p1,p2)
--		abar_spelldir(spell)
--end
--CastSpell = abar_casspl
function Abar_loaded()
	SlashCmdList["ATKBAR"] = Abar_chat;
	SLASH_ATKBAR1 = "/abar";
	SLASH_ATKBAR2 = "/atkbar";
	if abar.range == nil then
		abar.range=true
	end
	if abar.h2h == nil then
		abar.h2h=true
	end
	if abar.timer == nil then
		abar.timer=true
	end
	Abar_Mhr:SetPoint("LEFT",Abar_Frame,"TOPLEFT",6,-13)
	Abar_Oh:SetPoint("LEFT",Abar_Frame,"TOPLEFT",6,-35)
	Abar_MhrText:SetJustifyH("Left")
	Abar_OhText:SetJustifyH("Left")
	ebar_VL()
end

function Abar_chat(msg)
	msg = strlower(msg)
	if msg == "fix" then
		Abar_reset()
	elseif msg=="lock" then
		Abar_Frame:Hide()
		ebar_Frame:Hide()
	elseif msg=="unlock" then
		Abar_Frame:Show()
		ebar_Frame:Show()
	elseif msg=="range" then
		abar.range= not(abar.range)
		DEFAULT_CHAT_FRAME:AddMessage('range is'.. Abar_Boo(abar.range));
	elseif msg=="h2h" then
		abar.h2h = not(abar.h2h)
		DEFAULT_CHAT_FRAME:AddMessage('H2H is'.. Abar_Boo(abar.h2h));
	elseif msg=="timer" then
		abar.timer = not(abar.timer)
		DEFAULT_CHAT_FRAME:AddMessage('timer is'.. Abar_Boo(abar.timer));
	elseif msg=="pvp" then
		abar.pvp = not(abar.pvp)
		DEFAULT_CHAT_FRAME:AddMessage('pvp is'.. Abar_Boo(abar.pvp));
	elseif msg=="mob" then
		abar.mob = not(abar.mob)
		DEFAULT_CHAT_FRAME:AddMessage('mobs are'.. Abar_Boo(abar.mob));
	else
		DEFAULT_CHAT_FRAME:AddMessage('use any of these to control Abar:');
		DEFAULT_CHAT_FRAME:AddMessage('Lock- to lock and hide the anchor');
		DEFAULT_CHAT_FRAME:AddMessage('unlock- to unlock and show the anchor');
		DEFAULT_CHAT_FRAME:AddMessage('fix- to reset the values should they go awry, wait 5 sec after attacking to use this command');
		DEFAULT_CHAT_FRAME:AddMessage('h2h- to turn on and off the melee bar(s)');
		DEFAULT_CHAT_FRAME:AddMessage('range- to turn on and off the ranged bar');
		DEFAULT_CHAT_FRAME:AddMessage('pvp- to turn on and off the enemy player bar(s)');
		DEFAULT_CHAT_FRAME:AddMessage('mob- to turn on and off the enemy mob bar(s)');
	end
end

function Abar_selfhit(arg1)
  local go = true;
  a,b,spell=string.find (arg1, "Your (.+) hits")
  if not spell then a,b,spell=string.find (arg1, "Your (.+) crits") end
  if not spell then a,b,spell=string.find (arg1, "Your (.+) is") end
  if not spell then	a,b,spell=string.find (arg1, "Your (.+) misses") end
  if spell then go = false end
  if go == false then 
    Abar_spellhit(spell);
  else
		p_mh_speed, p_oh_speed = UnitAttackSpeed("player")
		p_mh_max, p_mh_min, p_oh_max, p_oh_min = UnitDamage("player")
		p_mh_max, p_mh_min = p_mh_max - math.fmod(p_mh_max, 1), p_mh_min - math.fmod(p_mh_min, 1)
		if p_oh_min then
			p_oh_max,p_oh_min = p_oh_max - math.fmod(p_oh_max, 1), p_oh_min - math.fmod(p_oh_min, 1)
		end	
		if p_oh_speed then
      now = GetTime()
      if (math.abs((now - p_mh_time) - p_mh_speed) <= math.abs((now - p_oh_time) - p_oh_speed))
        and not(p_mh_swings <= p_oh_speed / p_mh_speed)
        or p_oh_swings >= p_mh_speed / p_oh_speed then
        -- Player mainhand
        -- if the absolute value of the difference between now, the last mainhand swing time, and the mainhand speed is
        -- less-than or equal-to absolute value of now, the last offhand swing time and the offhand speed
        -- and the number of mainhand swings is not less-than or equal-to the ratio the offhand speed to the mainhand speed
        -- or if the number of offhand swings is greater than the ration of mainhand speed to offhand speed
				if p_oh_time == 0 then p_oh_time = now end
				p_mh_time = now
				p_oh_swings = 0
				p_mh_swings = p_mh_swings +1
				p_mh_speed = p_mh_speed - math.fmod(p_mh_speed,0.01)
				Abar_Mhrs(p_mh_speed,"Main["..p_mh_speed.."s]("..p_mh_max.."-"..p_mh_min..")",0,0,1)
			else
        -- Player offhand
				p_oh_time = now
				p_oh_swings = p_oh_swings+1
				p_mh_swings = 0
				p_oh_max,p_oh_min = p_oh_max-math.fmod(p_oh_max,1),p_oh_min-math.fmod(p_oh_min,1)
				p_oh_speed = p_oh_speed - math.fmod(p_oh_speed,0.01)
				Abar_Ohs(p_oh_speed,"Off["..p_oh_speed.."s]("..p_oh_max.."-"..p_oh_min..")",0,0,1)
			end
		else
			now=GetTime()
			p_mh_speed = p_mh_speed - math.fmod(p_mh_speed,0.01)
			Abar_Mhrs(p_mh_speed,"Main["..p_mh_speed.."s]("..p_mh_max.."-"..p_mh_min..")",0,0,1)
		end
	end
end

function Abar_reset()
	p_mh_time=0.000
	p_oh_time= 0.000
	now=0.000
	now= 0.000
	onid=0
	offid=0
end

function Abar_event(event)
  if (event=="CHAT_MSG_COMBAT_SELF_MISSES" or event=="CHAT_MSG_COMBAT_SELF_HITS") and abar.h2h == true then Abar_selfhit(arg1) end
  if event=="PLAYER_LEAVE_COMBAT" then Abar_reset() end
  if event == "VARIABLES_LOADED" then Abar_loaded() end
  if event == "CHAT_MSG_SPELL_SELF_DAMAGE" then Abar_spellhit(arg1) end
  if event == "VARIABLES_LOADED" then Abar_loaded() end
  if event == "UNIT_SPELLCAST_SENT" then abar_spelldir(arg2) end
end

function Abar_spellhit(arg1)
	--message("spell");
	a,b,spell=string.find (arg1, "Your (.+) hits")
	if not spell then 	a,b,spell=string.find (arg1, "Your (.+) crits") end
	if not spell then 	a,b,spell=string.find (arg1, "Your (.+) is") end
	if not spell then	a,b,spell=string.find (arg1, "Your (.+) misses") end
	if not spell then spell = arg1 end
	rs,rhd,rld =UnitRangedDamage("player");
	rhd,rld= rhd-math.fmod(rhd,1),rld-math.fmod(rld,1)
	if spell == "Auto Shot" and abar.range == true then
		trs=rs
		rs = rs-math.fmod(rs,0.01)
		Abar_Mhrs(trs,"Auto Shot["..rs.."s]("..rhd.."-"..rld..")",0,1,0)
	elseif spell == "Shoot" and abar.range==true then
		trs=rs
		rs = rs-math.fmod(rs,0.01)
		Abar_Mhrs(trs,"Wand["..p_mh_speed.."s]("..rhd.."-"..rld..")",.7,.1,1)
	elseif (spell == "Raptor Strike" or spell == "Heroic Strike" or
	spell == "Maul" or spell == "Cleave") and abar.h2h==true then
		p_mh_max,p_mh_min,p_oh_max,lhd = UnitDamage("player")
		p_mh_max,p_mh_min= p_mh_max-math.fmod(p_mh_max,1),p_mh_min-math.fmod(p_mh_min,1)
		if p_oh_time == 0 then p_oh_time=now end
		p_mh_time = now
		p_mh_speed = p_mh_speed - math.fmod(p_mh_speed,0.01)
		Abar_Mhrs(p_mh_speed,"Main["..p_mh_speed.."s]("..p_mh_max.."-"..p_mh_min..")",0,0,1)
	end
end

function abar_spelldir(spellname)
	if abar.range then
		local a,b,sparse = string.find (spellname, "(.+)%(")
		if sparse then spellname = sparse end
		rs,rhd,rld =UnitRangedDamage("player");
		rhd,rld= rhd-math.fmod(rhd,1),rld-math.fmod(rld,1)
		if spellname == "Throw" then
			trs=rs
			rs = rs-math.fmod(rs,0.01)
			Abar_Mhrs(trs-1,"Thrown["..(rs).."s]("..rhd.."-"..rld..")",1,.5,0)
		elseif spellname == "Shoot" then
			rs =UnitRangedDamage("player")
			trs=rs
			rs = rs-math.fmod(rs,0.01)
			Abar_Mhrs(trs-1,"Range["..(rs).."s]("..rhd.."-"..rld..")",.5,0,1)
		elseif spellname == "Shoot Bow" then
			trs = rs
			rs = rs-math.fmod(rs,0.01)
			Abar_Mhrs(trs-1,"Bow["..(rs).."s]("..rhd.."-"..rld..")",1,.5,0)
		elseif spellname == "Shoot Gun" then
			trs = rs
			rs = rs-math.fmod(rs,0.01)
			Abar_Mhrs(trs-1,"Gun["..(rs).."s]("..rhd.."-"..rld..")",1,.5,0)
		elseif spellname == "Shoot Crossbow" then
			trs=rs
			rs = rs-math.fmod(rs,0.01)
			Abar_Mhrs(trs-1,"X-Bow["..(rs).."s]("..rhd.."-"..rld..")",1,.5,0)
		elseif spellname == "Aimed Shot" then
			trs=rs
			rs = rs-math.fmod(rs,0.01)
			Abar_Mhrs(trs-1,"Aiming["..(3).."s]",1,.1,.1) 
		end
	end
end
	
function Abar_Update()
	local ttime = GetTime()
	local left = 0.00
	tSpark=getglobal(this:GetName().. "Spark")
	tText=getglobal(this:GetName().. "Tmr")
	if abar.timer==true then
		left = (this.et-GetTime()) - (math.fmod((this.et-GetTime()),.01))
		--	tText:SetText(this.txt.. "{"..left.."}")
		tText:SetText("{"..left.."}")
		tText:Show()
	else
		tText:Hide()
	end
	this:SetValue(ttime)
	tSpark:SetPoint("CENTER", this, "LEFT", (ttime-this.st)/(this.et-this.st)*195, 2);
	if ttime>=this.et then 
		this:Hide() 
		tSpark:SetPoint("CENTER", this, "LEFT",195, 2);
	end
end

function Abar_Mhrs(bartime,text,r,g,b)
	Abar_Mhr:Hide()
	Abar_Mhr.txt = text
	Abar_Mhr.st = GetTime()
	Abar_Mhr.et = GetTime() + bartime
	Abar_Mhr:SetStatusBarColor(r,g,b)
	Abar_MhrText:SetText(text)
	Abar_Mhr:SetMinMaxValues(Abar_Mhr.st,Abar_Mhr.et)
	Abar_Mhr:SetValue(Abar_Mhr.st)
	Abar_Mhr:Show()
end

function Abar_Ohs(bartime,text,r,g,b)
	Abar_Oh:Hide()
	Abar_Oh.txt = text
	Abar_Oh.st = GetTime()
	Abar_Oh.et = GetTime() + bartime
	Abar_Oh:SetStatusBarColor(r,g,b)
	Abar_OhText:SetText(text)
	Abar_Oh:SetMinMaxValues(Abar_Oh.st,Abar_Oh.et)
	Abar_Oh:SetValue(Abar_Oh.st)
	Abar_Oh:Show()
end

function Abar_Boo(inpt)
	if inpt == true then return " ON" else return " OFF" end
end

-----------------------------------------------------------------------------------------------------------------------
-- ENEMY BAR CODE --
-----------------------------------------------------------------------------------------------------------------------

function ebar_VL()
	if not abar.pvp then abar.pvp = true end
	if not abar.mob then abar.mob = true end
	ebar_mh:SetPoint("LEFT",ebar_Frame,"TOPLEFT",6,-13)
	ebar_oh:SetPoint("LEFT",ebar_Frame,"TOPLEFT",6,-35)
	ebar_mhText:SetJustifyH("Left")
	ebar_ohText:SetJustifyH("Left")
end
function ebar_event(event)
	if event=="VARIABLES_LOADED" then
	ebar_VL()
	end
	if (event == "CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS" or event == "CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES") and abar.pvp == true then
	ebar_start(arg1)
--	message(arg1)
	elseif (event=="CHAT_MSG_COMBAT_HOSTILEPLAYER_HITS" or event=="CHAT_MSG_COMBAT_HOSTILEPLAYER_MISSES") and abar.mob then
	ebar_start(arg1)
	end
	--message("ya")
end
function ebar_start(arg1)
	local a
	local b
 hitter = nil
	a,b, hitter = string.find (arg1, "(.+) hits you")
	if not hitter then a,b, hitter = string.find (arg1, "(.+) crits you") end
	if not hitter then a,b, hitter = string.find (arg1, "(.+) misses you")end
	if not hitter then a,b, hitter = string.find (arg1, "(.+) attacks. You ")end
	if hitter == UnitName("target") then ebar_set(hitter) end
end
function ebar_set(targ)
 --[[eons = nil
 eoffs = nil]]
	eons,eoffs = UnitAttackSpeed("target")
--[[	
	Mob duel weild code.... I cant get there off hand speed to return
	
	if eoffs then 		
			eont,eofft=GetTime(),GetTime()
	if ((math.abs((eont-epont)-eons) <= math.abs((eofft-epofft)-eoffs))and not(eonh <= eoffs/eons)) or eoffh >= eons/eoffs then
		if epofft == 0 then epofft=eofft end
		epont = eont
		etons = eons
		eoffh = 0
		eonh = eonh +1
		eons = eons - math.fmod(eons,0.01)
		ebar_mhs(eons,"Target Main["..eons.."s]",1,.1,.1)
	else
		epofft = eofft
		eoffh = eoffh+1
		eonh = 0
		eohd,eold = p_oh_max-math.fmod(eohd,1),p_oh_min-math.fmod(eold,1)
		eoffs = eoffs - math.fmod(eoffs,0.01)
		ebar_ohs(eoffs,"Target Off["..eoffs.."s]",1,.1,.1)
	end
	else ]]
	eons = eons - math.fmod(eons,0.01)
	ebar_mhs(eons,"Target".."["..eons.."s]",1,.1,.1)
	--message("work")
end
--end
function ebar_mhs(bartime,text,r,g,b)
ebar_mh:Hide()
ebar_mh.txt = text
ebar_mh.st = GetTime()
ebar_mh.et = GetTime() + bartime
ebar_mh:SetStatusBarColor(r,g,b)
ebar_mhText:SetText(text)
ebar_mh:SetMinMaxValues(ebar_mh.st,ebar_mh.et)
ebar_mh:SetValue(ebar_mh.st)
ebar_mh:Show()
end
function ebar_ohs(bartime,text,r,g,b)
ebar_oh:Hide()
ebar_oh.txt = text
ebar_oh.st = GetTime()
ebar_oh.et = GetTime() + bartime
ebar_oh:SetStatusBarColor(r,g,b)
ebar_ohText:SetText(text)
ebar_oh:SetMinMaxValues(ebar_oh.st,ebar_oh.et)
ebar_oh:SetValue(ebar_oh.st)
ebar_oh:Show()
end

