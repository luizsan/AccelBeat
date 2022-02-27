return Def.Quad{
	OnCommand=function(self)
		self:FullScreen()
        self:diffuse(0, 0.05, 0.1, 1)
		self:diffusebottomedge(0, 0.1, 0.15, 1)
	end
}