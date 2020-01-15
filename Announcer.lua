Announcer_Options = {}

function Announcer_OnLoad(self)
	SLASH_ANNOUNCER1 = "/announcer";
	SlashCmdList["ANNOUNCER"] = Announcer_SlashCommand;
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	Announcer_Message("Announcer loaded");
end

function Announcer_Color_Text(value)
	if (value) then
		return "|cff00FF00["..tostring(value).."]|r"
	end
	return "|cffFF0000["..tostring(value).."]|r"
end

function Announcer_SlashCommand(msg)
	msg = string.lower(msg);
	if (msg == nil or msg == "") then
		Announcer_Message("Announcer: /announcer announce : "..Announcer_Color_Text(Announcer_Options.announce))
		Announcer_Message("Announcer: /announcer taunt : "..Announcer_Color_Text(Announcer_Options.taunt))
	
	else
		if (msg == "announce") then
			Announcer_Options.announce = not Announcer_Options.announce;
			Announcer_Message("Announcements: "..Announcer_Color_Text(Announcer_Options.announce));
		elseif (msg == "debug") then
			Announcer_Options.debugging = not Announcer_Options.debugging;
			Announcer_Message("Debug: "..tostring(Announcer_Options.debugging));
		elseif (msg == "taunt") then
			Announcer_Options.taunt = not Announcer_Options.taunt;
			Announcer_Message("taunt: "..Announcer_Color_Text(Announcer_Options.taunt));
		end
	end
end

function Announcer_Message(msg)
	if msg == nil then
		msg = "nil";
	end
	DEFAULT_CHAT_FRAME:AddMessage("-[Announcer]- "..msg);
end


local missTypes = {
	ABSORB = true,
	BLOCK = true,
	DEFLECT = true,
	DODGE = true,
	EVADE = true,
	IMMUNE = true,
	MISS = true,
	PARRY = true,
	REFLECT = true,
	RESIST = true
}

local hitAbilities = {
	["Pummel"] = true,
	["Shield Bash"] = true,
	["Intercept Stun"] = true,
	["Concussion Blow"] = true,
	["Disarm"] = true,
}

local tauntAbilities = {
	["Mocking Blow"] = 6,
	["Taunt"] = 3,
	["Challenging Shout"] = 6,
}

local cooldownAbilities =  {
	["Last Stand"] = 20,
	["Shield Wall"] = 10,
}

	

function Announcer_OnEvent(self, event, ...)

	-- Grab Variables
	local PlayerName           = UnitName("player");
	local PlayerGUID           = UnitGUID("player");
	local AnnouncerEventMessage = "";
	
	if (event == "COMBAT_LOG_EVENT_UNFILTERED" ) then
		local timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, extraArg1, extraArg2, extraArg3, extraArg4, extraArg5, extraArg6, extraArg7, extraArg8, extraArg9, extraArg10 = CombatLogGetCurrentEventInfo()
	
		local spellName = extraArg2

		
		if (sourceGUID == PlayerGUID) then
			if ( event == "SPELL_MISSED" ) then
				local missType = extraArg4
				if ( hitAbilities[spellName] or tauntAbilities[spellName] ) then
					AnnouncerEventMessage = tostring(spellName).." > "..tostring(missType).." > "..tostring(destName);
				end
			elseif ( Announcer_Options.taunt and tauntAbilities[spellName] ) then
				if ( event == "SPELL_AURA_APPLIED" ) then 
					AnnouncerEventMessage = tostring(spellName).." > "..tostring(destName).." ends in "..tostring(tauntAbilities[spellName].." seconds!");
				elseif ( event == "SPELL_AURA_REMOVED" ) then
					AnnouncerEventMessage = tostring(spellName).." ended!"
				end
			end
		end
		

		if (destGUID == PlayerGUID) then
			--	warrior cds	
			if (cooldownAbilities[spellName]) then
				if ( event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REFRESH") then
					AnnouncerEventMessage = "Using "..tostring(spellName).." ending in "..tostring(cooldownAbilities[spellName].." seconds!")
				elseif (event == "SPELL_AURA_REMOVED") then
					AnnouncerEventMessage = tostring(spellName).." ended!"
				end
			end

		end

	end
	
	-- Broadcasts the AnnouncerEventMessage in the highest channel
	if (AnnouncerEventMessage ~= "" and Announcer_Options.announce) then
		if (IsInRaid() and IsInInstance()) then
			SendChatMessage(AnnouncerEventMessage, "SAY");
		elseif (IsInRaid()) then
			SendChatMessage(AnnouncerEventMessage, "RAID");
		elseif (IsInGroup()) then
			SendChatMessage(AnnouncerEventMessage, "PARTY");
		end
	end
end
