
local size = SCREEN_HEIGHT * 1.666666

return Def.ActorFrame{

	Def.Quad{
		OnCommand=function(self)
			self:FullScreen()
			self:diffuse(0, 0.05, 0.1, 1)
			self:diffusebottomedge(0, 0.1, 0.15, 1)
		end
	},

	Def.ActorFrame{
		InitCommand=function(self) self:Center() end,
	
		Def.Sprite{
			Texture = THEME:GetPathG("", "shapes/circle_outline"),
			InitCommand=function(self)
				self:zoomto(size, size)
				self:diffusealpha(0.15)
			end,
		},
		
		Def.Sprite{
			Texture = THEME:GetPathG("", "shapes/circle_dashed"),
			InitCommand=function(self)
				self:zoomto(size - 32, size - 32)
				self:diffusealpha(0.075)
				self:spin():effectmagnitude(0,0,math.pi)
			end,
		}
	},


	
}