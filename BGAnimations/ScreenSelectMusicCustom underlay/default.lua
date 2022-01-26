local t = MenuInputActor()..{
	PlayerJoinedMessageCommand=function() 
		GAMESTATE:SetCurrentStyle("versus")
		SCREENMAN:SetNewScreen("ScreenSelectMusicCustom")
	end;

	MenuInputMessageCommand=function(self,context) 
		if context and context.Player then
			MainController(self, context)
		end
	end;
}

function MainController(self, context)
	if context and context.Input then
		-- SCREENMAN:SystemMessage("["..context.Button.."]: "..context.Input)
	end
end

t[#t+1] = LoadActor("assets/SongGrid")
t[#t+1] = LoadActor("assets/SongDisplay");

return t