Announcer_Options = {
	announce = true,
	debugging = false 
};

function Announcer_OnLoad(self)
	SLASH_ANNOUNCER1 = "/announcer";
	SlashCmdList["ANNOUNCER"] = Announcer_SlashCommand;
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	Announcer_Message("Announcer loaded");
end

function Announcer_SlashCommand(msg)
	msg = string.lower(msg);
	if (msg == nil or msg == "") then
	
	else
		if (msg == "announce") then
			Announcer_Options.announce = not Announcer_Options.announce;
			Announcer_Message("Announcements: "..tostring(Announcer_Options.announce));
		elseif (msg == "debug") then
			Announcer_Options.debugging = not Announcer_Options.debugging;
			Announcer_Message("Debug: "..tostring(Announcer_Options.debugging));
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
	["Mocking Blow"] = true,
	["Taunt"] = true,
	["Concussion Blow"] = true,
	["Disarm"] = true,
}

local cooldownAbilities =  {
	["Challenging Shout"] = 6,
	["Last Stand"] = 20,
	["Shield Wall"] = 10,
}

	

function Announcer_OnEvent(self, event, ...)

	-- Grab Variables
	local PlayerName           = UnitName("player");
	local PlayerGUID           = UnitGUID("player");
	local AnnouncerEventMessage = "";
	
	if (event == "COMBAT_LOG_EVENT_UNFILTERED" )then
		local timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, extraArg1, extraArg2, extraArg3, extraArg4, extraArg5, extraArg6, extraArg7, extraArg8, extraArg9, extraArg10 = CombatLogGetCurrentEventInfo()
	
		
		if (event == "SPELL_MISSED" and sourceGUID == PlayerGUID) then
			local extraSpellName = extraArg2
			local missType = extraArg4
			if( hitAbilities[extraSpellName] ) then
				AnnouncerEventMessage = tostring(extraSpellName).." > "..tostring(missType).." > "..tostring(destName);
			end
		end
		
		
		if (destGUID == PlayerGUID) then
			local spellName = extraArg2
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
		if (IsInRaid()) then
			SendChatMessage(AnnouncerEventMessage, "SAY");
		elseif (IsInGroup()) then
			SendChatMessage(AnnouncerEventMessage, "PARTY");
		else
			SendChatMessage(AnnouncerEventMessage, "SAY");
		end
	end
end
