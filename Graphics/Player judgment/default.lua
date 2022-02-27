local player = Var "Player";
local reverse_judgment = false
local marvelous_timing = PREFSMAN:GetPreference("AllowW1") == "AllowW1_Everywhere"

local pulse = function(self)
	self:stoptweening()
	self:zoomx(1.3):zoomy(1.5)
	self:decelerate(0.075)
	self:zoom(1)
	self:sleep(0.725):linear(0.12)
	self:zoom(0.5)
	self:sleep(0.5):linear(0.15)
	self:zoom(0.25)
end

local fadeout = function(self)
	self:stoptweening()
	self:diffusealpha(1)
	self:sleep(0.8):linear(0.15)
	self:diffusealpha(0)
end

local TNSFramesNormal = {
	TapNoteScore_W1 = marvelous_timing and 0 or 1,
	TapNoteScore_W2 = 1,
	TapNoteScore_W3 = 2,
	TapNoteScore_W4 = 3,
	TapNoteScore_W5 = 4,
	TapNoteScore_Miss = 5,
	TapNoteScore_CheckpointHit = marvelous_timing and 0 or 1,
	TapNoteScore_CheckpointMiss = 5,
}

local TNSFramesReverse = {
	TapNoteScore_W1 = 5,
	TapNoteScore_W2 = 4,
	TapNoteScore_W3 = 3,
	TapNoteScore_W4 = 2,
	TapNoteScore_W5 = 1,
	TapNoteScore_Miss = marvelous_timing and 0 or 1,
	TapNoteScore_CheckpointHit = 5,
	TapNoteScore_CheckpointMiss = marvelous_timing and 0 or 1,
}

local max_judgment = marvelous_timing and 0 or 1
local target_frames = reverse_judgment and TNSFramesReverse or TNSFramesNormal
local early_color = { 1,0.9,0.5,1 }
local late_color = { 0.4,0.8,1,1 }

local t = Def.ActorFrame{
	InitCommand=function(self) 
		self:draworder(500); 
	end,

	JudgmentMessageCommand=function(self,context) 
		if context.TapNoteScore == "TapNoteScore_HitMine" then return end
		if context.TapNoteScore == "TapNoteScore_AvoidMine" then return end
		if context.Player == player and context.TapNoteScore then 
			pulse(self)
		end
	end,

	LoadActor("Judgment")..{
		OnCommand=function(self)
			self:valign(1):zoom(0.45):animate(false):y(12):diffusealpha(0)
		end,
		JudgmentMessageCommand=function(self,context)
			if context.TapNoteScore == "TapNoteScore_HitMine" then return end
			if context.TapNoteScore == "TapNoteScore_AvoidMine" then return end
			if context.Player == player and context.TapNoteScore then 
				self:stoptweening()
				self:setstate( target_frames[context.TapNoteScore] )
				fadeout(self)
			else
				return 
			end
		end
	},	

	Def.BitmapText{
		Font = "NewRodinEB-32",
		InitCommand=function(self)
			self:zoom(0.35):y(-40):visible(true)
		end,
		PulseCommand=function(self,context)
			self:stoptweening()
			self:strokecolor( BoostColor(context, 0.3 ))
			self:diffuse( BoostColor(context, 1.5 ))
			self:decelerate(0.2)
			self:diffuse(context)
			self:sleep(0.6)
			self:linear(0.15)
			self:diffusealpha(0)
		end,
		JudgmentMessageCommand=function(self,context)
			if context.Player == player and context.TapNoteOffset and context.TapNoteScore then
				if TNSFramesNormal[context.TapNoteScore] <= max_judgment then
					self:stoptweening()
					self:diffusealpha(0)
					return
				end

				if context.TapNoteOffset > 0 then	
					self:settext(string.upper("Late"))
					self:playcommand("Pulse", late_color)
				elseif context.TapNoteOffset < 0 then
					self:settext(string.upper("Early"))
					self:playcommand("Pulse", early_color)
				end
			end;
		end;
	}
};


return t