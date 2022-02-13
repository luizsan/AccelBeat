SelectMusic = {
	state = 0,
	steps = {},

	currentSteps = {
		[PLAYER_1] = 1,
		[PLAYER_2] = 1,
	},

	playerSteps = {
		[PLAYER_1] = nil,
		[PLAYER_2] = nil,
	},

	options = {
		[PLAYER_1] = false,
		[PLAYER_2] = false,
	},
}

local t = MenuInputActor()..{
	OnCommand=function()
		MESSAGEMAN:Broadcast("StateChanged")
		SetupGrid()
	end,

	PlayerJoinedMessageCommand=function() 
		GAMESTATE:SetCurrentStyle("versus")
		SCREENMAN:SetNewScreen("ScreenSelectMusicCustom")
	end,
	
	MenuInputMessageCommand=function(self, context) 
		MainController(self, context)
	end
}

function MainController(self, context)
	--SCREENMAN:SystemMessage("["..context.Button.."]: "..context.Input)
	if SelectMusic.state == 0 then GridInputController(context) return end
	if SelectMusic.state == 1 then StepsInputController(context) return end
end

t[#t+1] = LoadActor("components/grid")
t[#t+1] = LoadActor("components/gradient")
t[#t+1] = LoadActor("components/steps")
t[#t+1] = LoadActor("components/preview")
t[#t+1] = LoadActor("components/header")
t[#t+1] = LoadActor("components/info")
t[#t+1] = LoadActor("components/audio")

return t