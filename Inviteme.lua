-----------------------------------------------------------------------------------------------
-- Client Lua Script for Inviteme
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
 
-----------------------------------------------------------------------------------------------
-- Inviteme Module Definition
-----------------------------------------------------------------------------------------------
local Inviteme = {} 
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
-- e.g. local kiExampleVariableMax = 999

-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function Inviteme:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- initialize variables here
	self.trigger = "inviteme invite"
	self.inviteMsg = "Welcomes~~"
	self.turnedOn = false
    return o
end

function Inviteme:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		-- "UnitOrPackageName",
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- Inviteme OnLoad
-----------------------------------------------------------------------------------------------
function Inviteme:OnLoad()
    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("Inviteme.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
end

-----------------------------------------------------------------------------------------------
-- Inviteme OnDocLoaded
-----------------------------------------------------------------------------------------------
function Inviteme:OnDocLoaded()

	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
	    self.wndMain = Apollo.LoadForm(self.xmlDoc, "InvitemeForm", nil, self)
		if self.wndMain == nil then
			Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
			return
		end
		-- if you have a GUI, you use Show(true, true) to display the GUI
	    self.wndMain:Show(false, true)

		-- if the xmlDoc is no longer needed, you should set it to nil
		self.xmlDoc = nil

		-- Register handlers for events, slash commands and timer, etc.
		-- e.g. Apollo.RegisterEventHandler("KeyDown", "OnKeyDown", self)
		Apollo.RegisterSlashCommand("inviteme", "OnInvitemeOn", self)
	end
end

-----------------------------------------------------------------------------------------------
-- Inviteme Functions
-----------------------------------------------------------------------------------------------

-- on SlashCommand "/inviteme"
function Inviteme:OnInvitemeOn(strCmd, strArg)
	if strArg == "on" then 
		-- Register chat event on on
		Apollo.RegisterEventHandler("ChatMessage", "OnChatMessage", self)
		self.turnedOn = true
		ChatSystemLib.PostOnChannel(ChatSystemLib.ChatChannel_Debug,"inviteme is now on")
	elseif strArg == "off" then 
		-- Remove chat event on off
		Apollo.RemoveEventHandler("ChatMessage", self)
		self.turnedOn = false
		ChatSystemLib.PostOnChannel(ChatSystemLib.ChatChannel_Debug,"inviteme is now off")
		
	else
		--display addon instructions and status
		ChatSystemLib.PostOnChannel(ChatSystemLib.ChatChannel_Debug,"type /inviteme on to turn on")
		ChatSystemLib.PostOnChannel(ChatSystemLib.ChatChannel_Debug,"/inviteme off to turn off")
		ChatSystemLib.PostOnChannel(
			ChatSystemLib.ChatChannel_Debug,"inviteme currently set to: " .. (self.turnedOn and "on" or "off"))
	end
end

-- on Chat Message received
function Inviteme:OnChatMessage(channelCurrent, tMessage)
	--get the message's chat channel type
	local channelType = channelCurrent:GetType()
	
	if channelType == ChatSystemLib.ChatChannel_Whisper 
		or channelType == ChatSystemLib.ChatChannel_AccountWhisper then
		--get message content from event message segment
		local command = string.lower(tMessage.arMessageSegments[1].strText);		
		--search for trigger in message content
		local a, b = string.find(command, self.trigger)
		--if found
		if a then
			--send chat invite and welcome msg
			ChatSystemLib.Command('/invite ' .. tMessage.strSender)
			for i = 1, 5, 1 do
				ChatSystemLib.Command('/w ' .. tMessage.strSender .. ' ' .. self.inviteMsg)
			end
		end
	end
end

-----------------------------------------------------------------------------------------------
-- Inviteme Instance
-----------------------------------------------------------------------------------------------
local InvitemeInst = Inviteme:new()
InvitemeInst:Init() --starts the addon


