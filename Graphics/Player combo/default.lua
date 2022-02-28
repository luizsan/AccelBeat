local player = Var "Player"
local pulse = function(self)
	self:stoptweening()
	self:zoomx(1.25):zoomy(1.2)
	self:decelerate(0.075)
	self:zoom(1)
	self:sleep(0.725):linear(0.12)
	self:zoom(0.5)
	self:sleep(0.5):linear(0.15)
	self:zoom(0.25)
end

local fadeout = function(self)
	self:stoptweening()
	self:sleep(0.8):linear(0.15)
	self:diffusealpha(0)
end

local reverse_judgment = false

local t = Def.ActorFrame{

	InitCommand=function(self) self:draworder(600) end,
	JudgmentMessageCommand=function(self,context) 
		if context.TapNoteScore == "TapNoteScore_HitMine" or context.TapNoteScore == "TapNoteScore_AvoidMine" then return end
		if context.Player == player and context.TapNoteScore then pulse(self) end
	end,

	--accuracy
	Def.BitmapText{
		Font = Font.UIHeavy,
		Text = "Accuracy",
		InitCommand=function(self) self:textglowmode("TextGlowMode_Inner") end,
		OnCommand=function(self)
			self:halign(1)
			self:diffuse(0.75,0.75,0.75,1)
			self:strokecolor(0,0,0,0.66)
			self:shadowlength(1)
			self:diffusealpha(0)
			self:zoomx(0.4):zoomy(0.4)
			self:xy(48,9)
		end,

		ComboCommand=function(self,context)
			local accuracy = string.format("%.2f", 100)
			local combo = context.Misses or context.Combo
			local stats = nil

			if context.Player or player then
				if context.currentDP and context.possibleDP then
					if context.possibleDP > 0 then
						accuracy = string.format("%.2f",(context.currentDP/context.possibleDP)*100)
					else
						accuracy = string.format("%.2f",100)
					end
				else
					stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
					accuracy = string.format("%.2f",(stats:GetActualDancePoints()/stats:GetCurrentPossibleDancePoints())*100)
				end
			end

			self:stoptweening()
			self:diffusealpha(1)

            if stats and not stats:GetFailed() then
                self:x(48)
                self:halign(1)
                self:diffuse(0.75,0.75,0.75,1)
			    self:settextf("%s Accuracy", accuracy.."%")
            else
                self:x(0)
                self:halign(0.5)
                self:diffuse(0.75,0.5,0.5,1)
                self:settext("Failed")
            end

			self:visible(combo and true or false)
			fadeout(self)
		end
	},

	--combo
	Def.BitmapText{
		Font = Font.Combo,
		OnCommand=function(self)
			self:halign(1)
			self:diffuse(1,1,1,0)
			self:zoomx(0.466666):zoomy(0.45)
			self:xy(0,38)
		end,

		ComboCommand=function(self,context)
			self:stoptweening()

			self:diffuse(1,1,1,1);
			if (not reverse_judgment and context.Misses) or (reverse_judgment and context.Combo) then
				self:diffuse(1,0,0.2,1);
			end

			local combo = context.Misses or context.Combo
			if combo then
				self:settext(string.rep("0",3-string.len(combo))..combo)
			end

			if not combo or combo < 4 then self:visible(false) else self:visible(true) end
			fadeout(self)
		end,
	},

	--label
	Def.BitmapText{
		Font = Font.UIHeavy,
		OnCommand=function(self)
			self:halign(0):valign(0)
			self:diffuse(1,1,1,0)
			self:strokecolor(0,0,0,0.95)
			self:shadowlength(1)
			self:zoom(0.375)
			self:vertspacing(-2)
			self:xy(8,19)
		end,

		ComboCommand=function(self,context)
			local combo = context.Misses or context.Combo
			local stats = nil

			self:stoptweening()
			self:diffuse(1,1,1,1)

            local text = ""
            local color = Color.White

			if context.Player or player then
				stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
				if stats:FullComboOfScore("TapNoteScore_W1") then
					text = "Flawless\nCombo"
                    color = {1,0.95,0.5,1}
                    
				elseif stats:FullComboOfScore("TapNoteScore_W2") then
					text = "Perfect\nCombo"
                    color = {0.666666,0.9,1,1}
                    
				elseif stats:FullComboOfScore("TapNoteScore_W3") then
					text = "Full\nCombo"
                    color = {0.5,1,0.75,1}
                    
				elseif stats:FullComboOfScore("TapNoteScore_W5") then
					text = "No Miss\nCombo"
                    
				elseif context.Combo then
					text = "\nCombo"
					color = {0.8,0.8,0.8,1}
                    
				elseif context.Misses then
					text = "Miss\nCombo"
                    color = {1,0.25,0.25,1}
				end
			end

            self:settext(string.upper(text))
            self:diffuse(color)

			-- if (not reverse_judgment and context.Misses) or (reverse_judgment and context.Combo) then
			-- 	self:diffuse(1,0,0.2,1)
			-- end

			self:visible(combo and combo >= 4 or false)
			fadeout(self)
		end
	}

}

return t