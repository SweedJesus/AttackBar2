local function log(msg)
  ChatFrame1:AddMessage(msg)
end

pont = 0.000
pofft = 0.000
ont = 0.000
offt = 0.000
ons = 0.000
offs = 0.000
offh = 0
onh = 0
epont = 0.000
epofft = 0.000
eont = 0.000
eofft = 0.000
eons = 0.000
eoffs = 0.000
eoffh = 0
eonh = 0
testvar = 0
if not(Abar) then Abar = {} end
function Abar_LOADED()
  SlashCmdList["ATKBAR"] = Abar_CHAT;
  SLASH_ATKBAR1 = "/Abar";
  SLASH_ATKBAR2 = "/atkbar";
  if Abar.range == nil then
    Abar.range = true
  end
  if Abar.h2h == nil then
    Abar.h2h = true
  end
  if Abar.timer == nil then
    Abar.timer = true
  end
  if Abar.mob == nil then
    Abar.mob = true
  end
  if Abar.pvp == nil then
    Abar.pvp = true
  end
  if Abar.text == nil then
    Abar.text = "standard"
  end
  if Abar.info == nil then
    Abar.info = true
  end
  Abar_MHR:SetPoint("LEFT",Abar_FRAME,"TOPLEFT",6,-13)
  Abar_OH:SetPoint("LEFT",Abar_FRAME,"TOPLEFT",6,-35)
  Abar_MHRText:SetJustifyH("Left")
  Abar_OHText:SetJustifyH("Left")
  Ebar_VL()
  local Border = "Border"
  local Bordern = "Bordern"
  if Abar.text == "thin" then
    getglobal(Abar_MHR:GetName()..Border):Hide()
    getglobal(Abar_OH:GetName()..Border):Hide()
    getglobal(Ebar_MH:GetName()..Border):Hide()
    getglobal(Ebar_OH:GetName()..Border):Hide()
    getglobal(Abar_MHR:GetName()..Bordern):Show()
    getglobal(Abar_OH:GetName()..Bordern):Show()
    getglobal(Ebar_MH:GetName()..Bordern):Show()
    getglobal(Ebar_OH:GetName()..Bordern):Show()
  elseif Abar.text == "none" then
    getglobal(Abar_MHR:GetName()..Bordern):Hide()
    getglobal(Abar_OH:GetName()..Bordern):Hide()
    getglobal(Ebar_MH:GetName()..Bordern):Hide()
    getglobal(Ebar_OH:GetName()..Bordern):Hide()
    getglobal(Abar_MHR:GetName()..Border):Hide()
    getglobal(Abar_OH:GetName()..Border):Hide()
    getglobal(Ebar_MH:GetName()..Border):Hide()
    getglobal(Ebar_OH:GetName()..Border):Hide()
  else
    Abar.text = "standard"
    getglobal(Abar_MHR:GetName()..Bordern):Hide()
    getglobal(Abar_OH:GetName()..Bordern):Hide()
    getglobal(Ebar_MH:GetName()..Bordern):Hide()
    getglobal(Ebar_OH:GetName()..Bordern):Hide()
    getglobal(Abar_MHR:GetName()..Border):Show()
    getglobal(Abar_OH:GetName()..Border):Show()
    getglobal(Ebar_MH:GetName()..Border):Show()
    getglobal(Ebar_OH:GetName()..Border):Show()
  end
end
function Abar_CHAT(msg)
  msg = strlower(msg)
  if msg == "fix" then
    Abar_RESET()
  elseif msg == "lock" then
    Abar_FRAME:Hide()
    Ebar_FRAME:Hide()
  elseif msg == "unlock" then
    Abar_FRAME:Show()
    Ebar_FRAME:Show()
  elseif msg == "range" then
    Abar.range = not(Abar.range)
    DEFAULT_CHAT_FRAME:AddMessage('range is'.. Abar_BOO(Abar.range));
  elseif msg == "h2h" then
    Abar.h2h = not(Abar.h2h)
    DEFAULT_CHAT_FRAME:AddMessage('H2H is'.. Abar_BOO(Abar.h2h));
  elseif msg == "timer" then
    Abar.timer = not(Abar.timer)
    DEFAULT_CHAT_FRAME:AddMessage('timer is'.. Abar_BOO(Abar.timer));
  elseif msg == "pvp" then
    Abar.pvp = not(Abar.pvp)
    DEFAULT_CHAT_FRAME:AddMessage('pvp is'.. Abar_BOO(Abar.pvp));
  elseif msg == "text" then
    local Border = "Border"
    local Bordern = "Bordern"
    if Abar.text == "standard" then
      Abar.text = "thin"
      getglobal(Abar_MHR:GetName()..Border):Hide()
      getglobal(Abar_OH:GetName()..Border):Hide()
      getglobal(Ebar_MH:GetName()..Border):Hide()
      getglobal(Ebar_OH:GetName()..Border):Hide()
      getglobal(Abar_MHR:GetName()..Bordern):Show()
      getglobal(Abar_OH:GetName()..Bordern):Show()
      getglobal(Ebar_MH:GetName()..Bordern):Show()
      getglobal(Ebar_OH:GetName()..Bordern):Show()
    elseif Abar.text == "thin" then
      Abar.text = "none"
      getglobal(Abar_MHR:GetName()..Bordern):Hide()
      getglobal(Abar_OH:GetName()..Bordern):Hide()
      getglobal(Ebar_MH:GetName()..Bordern):Hide()
      getglobal(Ebar_OH:GetName()..Bordern):Hide()
      getglobal(Abar_MHR:GetName()..Border):Hide()
      getglobal(Abar_OH:GetName()..Border):Hide()
      getglobal(Ebar_MH:GetName()..Border):Hide()
      getglobal(Ebar_OH:GetName()..Border):Hide()
    else
      Abar.text = "standard"
      getglobal(Abar_MHR:GetName()..Bordern):Hide()
      getglobal(Abar_OH:GetName()..Bordern):Hide()
      getglobal(Ebar_MH:GetName()..Bordern):Hide()
      getglobal(Ebar_OH:GetName()..Bordern):Hide()
      getglobal(Abar_MHR:GetName()..Border):Show()
      getglobal(Abar_OH:GetName()..Border):Show()
      getglobal(Ebar_MH:GetName()..Border):Show()
      getglobal(Ebar_OH:GetName()..Border):Show()
    end
    DEFAULT_CHAT_FRAME:AddMessage("Attack bar textures are ".. Abar.text)
  elseif msg == "mob" then
    Abar.mob = not(Abar.mob)
    DEFAULT_CHAT_FRAME:AddMessage('mobs are'.. Abar_BOO(Abar.mob))
  elseif msg == "info" then
    Abar.info = not (Abar.info)
    DEFAULT_CHAT_FRAME:AddMessage('mobs are'.. Abar_BOO(Abar.info))
  else
    DEFAULT_CHAT_FRAME:AddMessage('use any of these to control Abar:')
    DEFAULT_CHAT_FRAME:AddMessage('Lock- to lock and hide the anchor')
    DEFAULT_CHAT_FRAME:AddMessage('unlock- to unlock and show the anchor')
    DEFAULT_CHAT_FRAME:AddMessage('fix- to reset the values should they go awry, wait 5 sec after attacking to use this command')
    DEFAULT_CHAT_FRAME:AddMessage('h2h- to turn on and off the melee bar(s)')
    DEFAULT_CHAT_FRAME:AddMessage('range- to turn on and off the ranged bar')
    DEFAULT_CHAT_FRAME:AddMessage('pvp- to turn on and off the enemy player bar(s)')
    DEFAULT_CHAT_FRAME:AddMessage('mob- to turn on and off the enemy mob bar(s)')
    DEFAULT_CHAT_FRAME:AddMessage('text- toggle from standard to line to no texture')
    DEFAULT_CHAT_FRAME:AddMessage('info- toggle the info')
  end
end
function Abar_SELFHIT()
  local go = true;
  ons,offs = UnitAttackSpeed("player");
  hd,ld,ohd,old = UnitDamage("player")
  hd,ld = hd-math.mod(hd,1),ld-math.mod(ld,1)
  if old then
    ohd,old = ohd-math.mod(ohd,1),old-math.mod(old,1)
  end	
  if offs then
    ont,offt = GetTime(),GetTime()
    if ((math.abs((ont-pont)-ons) <= math.abs((offt-pofft)-offs))and not(onh <= offs/ons)) or offh >= ons/offs then
      if pofft == 0 then pofft = offt end
      pont = ont
      tons = ons
      offh = 0
      onh = onh +1
      ons = ons - math.mod(ons,0.01)
      Abar_MHRS(tons,"Main["..ons.."s]("..hd.."-"..ld..")",0,0,1)
    else
      pofft = offt
      offh = offh+1
      onh = 0
      ohd,old = ohd-math.mod(ohd,1),old-math.mod(old,1)
      offs = offs - math.mod(offs,0.01)
      Abar_OHS(offs,"Off["..offs.."s]("..ohd.."-"..old..")",0,0,1)
    end
  else
    ont = GetTime()
    tons = ons
    ons = ons - math.mod(ons,0.01)
    Abar_MHRS(tons,"Main["..ons.."s]("..hd.."-"..ld..")",0,0,1)
    --	end
  end
end
function Abar_RESET()
  pont = 0
  pofft = 0
  ont = 0
  offt = 0
  onid = 0
  offid = 0
  lastus = 0
end
function Abar_EVENT(event)
  log(event)
  log("arg1: "..tostring(arg1))
  if event == "VARIABLES_LOADED" then Abar_LOADED() end
  --[[
  -- Below are the old functions that they deprecated for no apparent reason
  -- if event == "CHAT_MSG_COMBAT_HOSTILEPLAYER_MISSES" or event ==
  -- "CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES" then Abar_PARRY(arg1) en
  ]]--
  if event == "CHAT_MSG_SPELL_SELF_DAMAGE" then
    Abar_SELFHIT()
  end
  if event == "COMBAT_LOG_EVENT_UNFILTERED" then
    if arg3 and arg7 then
      if arg3 == UnitGUID("player") and arg6 == UnitGUID("playertarget") then
        if arg2 == "SWING_DAMAGE" or arg2 == "SWING_MISSED" then
          Abar_SELFHIT()
          return
        end
        if arg2 == "RANGE_DAMAGE" or arg2 == "RANGE_MISSED" then
          Abar_SPELLDIR(arg10, 1)
          return
        end
      end
      if arg3 == UnitGUID("playertarget") and arg6 == UnitGUID("playertargettarget") and Abar.mob == true then
        if arg2 == "SWING_DAMAGE" or arg2 == "SWING_MISSED" then
          Ebar_SET("")
          if arg2 == "SWING_MISSED" and arg9 == "PARRY" and arg6 == UnitGUID("player") then
            Abar_PARRY("")
            -- if arg9 then message(arg9) end
          end
          return
        end
      end
    end  
  end
  if event == "UNIT_SPELLCAST_SENT" then Abar_SPELLDIR(arg2, 0) end	
  if event == "PLAYER_ENTER_COMBAT" then Abar_RESET() end
  if event == "PLAYER_LEAVE_COMBAT" then Abar_RESET() end 
  if event == "UNIT_ATTACK_SPEED" then
    a,b = UnitAttackSpeed("player")
    if (not(lastus == a) and Abar_MHR.st) then
      lastus = a
      Abar_MHR.et = Abar_MHR.st + a
      Abar_MHR:SetMinMaxValues(Abar_MHR.st,Abar_MHR.et)
      Abar_MHR:SetValue(GetTime())
      if b then
        Abar_OH.et = Abar_OH.st + b
        Abar_OH:SetMinMaxValues(Abar_OH.st,Abar_OH.et)
        Abar_OH:SetValue(GetTime())
      end
    end
  end
end
function Abar_PARRY(arg1)
  --	local a,b, hitter = string.find (arg1, "(.+) attacks. You parry")
  --	if hitter then
  local curtime = GetTime()
  local stt = Abar_MHR.st
  local ett = Abar_MHR.et
  local wspd = UnitAttackSpeed("player")
  local bpos = curtime - stt
  if .4 * wspd < (wspd - bpos) then
    Abar_MHR.et = Abar_MHR.et - .4 * wspd
    Abar_MHR:SetMinMaxValues(Abar_MHR.st,Abar_MHR.et)
    Abar_MHR:SetValue(curtime)
  end
  --	end
end
function Abar_SPELLHIT(arg1)

end
function Abar_SPELLDIR(spellname, prs)
  spell = spellname
  if (spell == "Raptor Strike" or spell == "Heroic Strike" or
    spell == "Maul" or spell == "Cleave" or spell == "Slam") and Abar.h2h == true and prs == 1 then
    hd,ld,ohd,lhd = UnitDamage("player")
    hd,ld = hd-math.fmod(hd,1),ld-math.fmod(ld,1)
    if pofft == 0 then pofft = offt end
    pont = ont
    tons = ons
    ons = ons - math.fmod(ons,0.01)
    Abar_MHRS(tons,"Main["..ons.."s]("..hd.."-"..ld..")",0,0,1)
  elseif Abar.range then
    rs,rhd,rld = UnitRangedDamage("player");
    rhd,rld = rhd-math.fmod(rhd,1),rld-math.fmod(rld,1)
    if prs == 0 then 					
      if spellname == "Throw" then
        rs = rs-math.fmod(rs,0.01)
        Abar_MHRS(.5,spellname .. "["..(rs).."s]("..rhd.."-"..rld..")",1,.5,0)
      elseif spellname == "Shoot" then
        rs = rs-math.fmod(rs,0.01)
        Abar_MHRS(.5,"Range["..(rs).."s]("..rhd.."-"..rld..")",.5,0,1)
      elseif spellname == "Shoot Bow" then
        rs = rs-math.fmod(rs,0.01)
        Abar_MHRS(.5,"Bow["..(rs).."s]("..rhd.."-"..rld..")",1,.5,0)
      elseif spellname == "Shoot Gun" then
        rs = rs-math.fmod(rs,0.01)
        Abar_MHRS(.5,"Gun["..(rs).."s]("..rhd.."-"..rld..")",1,.5,0)
      elseif spellname == "Shoot Crossbow" then
        rs = rs-math.fmod(rs,0.01)
        Abar_MHRS(.5,"X-Bow["..(rs).."s]("..rhd.."-"..rld..")",1,.5,0)
      elseif spellname == "Aimed Shot" then
        Abar_MHRS(3,"Aiming["..(3).."s]",1,.1,.1)
      end
    elseif prs == 1 then
      trs = rs
      rs = rs-math.fmod(rs,0.01)
      Abar_MHRS(trs,spellname .. "["..(rs).."s]("..rhd.."-"..rld..")",1,.5,0)
    end
  end
end

function Abar_UPDATE()
  local ttime = GetTime()
  local left = 0.00
  tSpark = getglobal(this:GetName().. "Spark")
  tText = getglobal(this:GetName().. "Tmr")
  if Abar.timer == true then
    left = (this.et-GetTime()) - (math.fmod((this.et-GetTime()),.01))
    tText:SetText("{"..left.."}")
    tText:Show()
  else
    tText:Hide()
  end
  this:SetValue(ttime)
  tSpark:SetPoint("CENTER", this, "LEFT", (ttime-this.st)/(this.et-this.st)*195, 2);
  if ttime >= this.et then 
    this:Hide() 
    tSpark:SetPoint("CENTER", this, "LEFT",195, 2);
  end
end
function Abar_MHRS(bartime,text,r,g,b)
  Abar_MHR:Hide()
  if Abar.info == true then
    Abar_MHR.txt = text
    Abar_MHRText:SetText(text)
  else
    Abar_MHR.txt = ""
    Abar_MHRText:SetText("")
  end
  Abar_MHR.st = GetTime()
  Abar_MHR.et = GetTime() + bartime
  Abar_MHR:SetStatusBarColor(r,g,b)
  Abar_MHR:SetMinMaxValues(Abar_MHR.st,Abar_MHR.et)
  Abar_MHR:SetValue(Abar_MHR.st)
  Abar_MHR:Show()
end
function Abar_OHS(bartime,text,r,g,b)
  Abar_OH:Hide()
  if Abar.info == true then
    Abar_OH.txt = text
    Abar_OHText:SetText(text)
  else
    Abar_OH.txt = ""
    Abar_OHText:SetText("")
  end
  Abar_OH.st = GetTime()
  Abar_OH.et = GetTime() + bartime
  Abar_OH:SetStatusBarColor(r,g,b)
  Abar_OH:SetMinMaxValues(Abar_OH.st,Abar_OH.et)
  Abar_OH:SetValue(Abar_OH.st)
  Abar_OH:Show()
end
function Abar_BOO(inpt)
  if inpt == true then return " ON" else return " OFF" end
end
-----------------------------------------------------------------------------------------------------------------------
-- ENEMY BAR CODE --
-----------------------------------------------------------------------------------------------------------------------

function Ebar_VL()
  Ebar_MH:SetPoint("LEFT",Ebar_FRAME,"TOPLEFT",6,-13)
  Ebar_OH:SetPoint("LEFT",Ebar_FRAME,"TOPLEFT",6,-35)
  Ebar_MHText:SetJustifyH("Left")
  Ebar_OHText:SetJustifyH("Left")
end
function Ebar_EVENT(event)
  if event == "VARIABLES_LOADED" then
    Ebar_VL()
  end
  --[[	if (event == "CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS" or event == "CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES") and Abar.mob == true then
  Ebar_START(arg1)
  --	message(arg1)
  elseif (event == "CHAT_MSG_COMBAT_HOSTILEPLAYER_HITS" or event == "CHAT_MSG_COMBAT_HOSTILEPLAYER_MISSES") and Abar.pvp == true then
  Ebar_START(arg1)
  end]]--
  --message("ya")
end
--[[function Ebar_START(arg1)
local a
local b
local pname = UnitName("playerpet")
hitter = nil
a,b, hitter = string.find (arg1, "(.+) hits you")
if not hitter then a,b, hitter = string.find (arg1, "(.+) crits you") end
if not hitter then a,b, hitter = string.find (arg1, "(.+) misses you")end
if not hitter then a,b, hitter = string.find (arg1, "(.+) attacks. You ")end
if not hitter then a,b, hitter = string.find (arg1, "(.+) hits ".. pname) end
if not hitter then a,b, hitter = string.find (arg1, "(.+) crits ".. pname) end
if not hitter then a,b, hitter = string.find (arg1, "(.+) misses ".. pname)end
if not hitter then a,b, hitter = string.find (arg1, "(.+) attacks.  ".. pname)end
if hitter == UnitName("target") then Ebar_SET(hitter) end
end]]--
function Ebar_SET(targ)
  eons,eoffs = UnitAttackSpeed("playertarget")
  --[[	
  Mob duel weild code.... I cant get their off hand speed to return

  if eoffs then 		
  eont,eofft = GetTime(),GetTime()
  if ((math.abs((eont-epont)-eons) <= math.abs((eofft-epofft)-eoffs))and not(eonh <= eoffs/eons)) or eoffh >= eons/eoffs then
  if epofft == 0 then epofft = eofft end
  epont = eont
  etons = eons
  eoffh = 0
  eonh = eonh +1
  eons = eons - math.fmod(eons,0.01)
  Ebar_MHS(eons,"Target Main["..eons.."s]",1,.1,.1)
  else
  epofft = eofft
  eoffh = eoffh+1
  eonh = 0
  eohd,eold = ohd-math.fmod(eohd,1),old-math.fmod(eold,1)
  eoffs = eoffs - math.fmod(eoffs,0.01)
  Ebar_OHS(eoffs,"Target Off["..eoffs.."s]",1,.1,.1)
  end
  else ]]--
  eons = eons - math.fmod(eons,0.01)
  Ebar_MHS(eons,"Target".."["..eons.."s]",1,.1,.1)
  --end
end
function Ebar_MHS(bartime,text,r,g,b)
  Ebar_MH:Hide()
  if Abar.info == true then
    Ebar_MH.txt = text
    Ebar_MHText:SetText(text)
  else
    Ebar_MH.txt = ""
    Ebar_MHText:SetText("")
  end
  Ebar_MH.st = GetTime()
  Ebar_MH.et = GetTime() + bartime
  Ebar_MH:SetStatusBarColor(r,g,b)
  Ebar_MH:SetMinMaxValues(Ebar_MH.st,Ebar_MH.et)
  Ebar_MH:SetValue(Ebar_MH.st)
  Ebar_MH:Show()
end
function Ebar_OHS(bartime,text,r,g,b)
  Ebar_OH:Hide()
  Ebar_OH.txt = text
  Ebar_OH.st = GetTime()
  Ebar_OH.et = GetTime() + bartime
  Ebar_OH:SetStatusBarColor(r,g,b)
  Ebar_OHText:SetText(text)
  Ebar_OH:SetMinMaxValues(Ebar_OH.st,Ebar_OH.et)
  Ebar_OH:SetValue(Ebar_OH.st)
  Ebar_OH:Show()
end

