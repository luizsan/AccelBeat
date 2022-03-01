local t = Def.ActorFrame{
	InitCommand=function(self)
		ResetState()
	end,

	OnCommand=function(self)
		SelectMusic.lockinput = true
		InitializeGrid()
		self:sleep(0.2)
		self:queuecommand("Unlock")
	end,

	UnlockCommand=function()
		SelectMusic.lockinput = false
	end,

	PlayerJoinedMessageCommand=function() 
		SCREENMAN:SetNewScreen("ScreenSelectMusicCustom")
		ResetState()
	end,
	
	MenuInputMessageCommand=function(self, context) 
		MainController(self, context)
	end
}

t[#t+1] = MenuInputActor()

function ResetState()
	ResetGridState()
	for i,pn in ipairs(GAMESTATE:GetHumanPlayers()) do
		SelectMusic.playerOptions[pn] = ReadOptionsTable(pn)
	end
end

function MainController(self, context)
	if SelectMusic.lockinput then return end

	if not OptionsListOpened(context.Player) then
			if SelectMusic.state == 0 then GridInputController(context) 
		elseif SelectMusic.state == 1 then StepsInputController(context) 
		end
	else
		OptionsInputController(context)
	end
	
	OptionsToggle(context)
	MESSAGEMAN:Broadcast("Debug", context)
end

t[#t+1] = LoadActor("components/grid")
t[#t+1] = LoadActor("components/preview")
t[#t+1] = LoadActor("components/gradient")
t[#t+1] = LoadActor("components/steps")
t[#t+1] = LoadActor("components/sub")
t[#t+1] = LoadActor("components/options")
t[#t+1] = LoadActor("components/header")
t[#t+1] = LoadActor("components/info")
t[#t+1] = LoadActor("components/audio")

-- debug
t[#t+1] = Def.BitmapText{
	Font = Font.System,
	Text = "",
	InitCommand=function(self) 
		self:halign(0):valign(0)
		self:xy(SCREEN_LEFT + 8,SCREEN_TOP + 8)
		self:shadowlength(1) 
		self:zoom(0.5)
		self:playcommand("Debug")
	end,

	DebugMessageCommand=function(self, context)
		local d = {}
		local pn = context and context.Player or "None"
		d[#d+1] = "Last Input"
		d[#d+1] = "Player: "..string.gsub(pn, "PlayerNumber_", "")
		d[#d+1] = "Menu: "..(context and context.Menu or "---")
		d[#d+1] = "Direction: "..(context and context.Direction or "---")
		d[#d+1] = "GameButton: "..(context and context.Button or "---")
		d[#d+1] = "Players: "..string.gsub(table.concat( GAMESTATE:GetHumanPlayers(), ", "), "PlayerNumber_", "")
		d[#d+1] = "Confirm P1: "..(SelectMusic.confirm[PLAYER_1] or 0)
		d[#d+1] = "Confirm P2: "..(SelectMusic.confirm[PLAYER_2] or 0)
		self:settext(table.concat(d, "\n"))
	end
}

return t