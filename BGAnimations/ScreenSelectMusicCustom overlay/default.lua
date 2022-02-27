local t = MenuInputActor()..{
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

function ResetState()
	ResetGridState()
	for i,pn in ipairs(GAMESTATE:GetHumanPlayers()) do
		SelectMusic.playerOptions[pn] = ReadOptionsTable(pn)
	end
end

function MainController(self, context)
	if SelectMusic.lockinput then return end

	-- SCREENMAN:SystemMessage("["..context.Player.."]: "..context.Input)
	
	
	if not OptionsListOpened(context.Player) then
			if SelectMusic.state == 0 then GridInputController(context) 
		elseif SelectMusic.state == 1 then StepsInputController(context) 
		end
	else
		OptionsInputController(context)
	end
	
	OptionsToggle(context)
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

return t