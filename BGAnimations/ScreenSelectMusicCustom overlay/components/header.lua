local Header = {
    width = 1082,
    height = 86,
    y = 32
}

local Glow = {
    width = 1020,
}

local offset = { -1, 0, 1 }
local align = { 1, 0.5, 0 }

local t = Def.ActorFrame{}

t[#t+1] = Def.Quad{
    InitCommand=function(self)
        self:align(0.5, 0)
        self:zoomto(Header.width + 32, Header.height - 20)
        self:diffuse( Color.White )
        self:diffusetopedge( BoostColor( Color.White, 0.9 ))
        self:xy(SCREEN_CENTER_X, Header.y + 6)
    end
}

t[#t+1] = Def.Sprite{
    Texture = THEME:GetPathG("", "patterns/diagonal"),
    InitCommand=function(self)
        self:zoomto(Header.width + 32, Header.height - 20)
        self:align(0.5, 0)
        
        local w = ( Header.width + 32 ) / 128.0 * 1.5
        local h = ( Header.height - 16 ) / 128.0 * 1.5
        self:customtexturerect(0,0,w,h)
        self:diffuse( BoostColor( Color.White, 0.1 )):diffusealpha(0.075)
        self:fadebottom(1)
        self:xy(SCREEN_CENTER_X, Header.y + 8)
    end
}


-- panel
for i = 1,3 do
    t[#t+1] = Def.Sprite{
        Texture = "../graphics/header_panel",
        InitCommand=function(self)
            self:animate(0)
            self:setstate(i-1)
            self:align( align[i], 0 )
            self:zoomto(i == 2 and Header.width or (self:GetWidth() * (2/3) * -1), Header.height)
            self:xy(SCREEN_CENTER_X - ((Header.width * 0.5 * offset[i])), Header.y)
        end
    }

end

-- glow
for y = 3, 1, -1 do
    for x = 1, 3 do
        t[#t+1] = Def.Sprite{
            Texture = "../graphics/header_glow",
            InitCommand=function(self)
                self:animate(0)
                self:setstate( (x-1) + ((y-1)*3) )
                self:align( align[x], 0.5 )
                self:zoomto(x == 2 and Glow.width or (self:GetWidth() * 0.75), self:GetHeight() * 0.75)
                self:xy( SCREEN_CENTER_X + (Glow.width * 0.5 * offset[x]) , Header.y + 70)
                self:blend( y > 1 and "BlendMode_Add" or "BlendMode_Normal" )
                self:diffuse( AccentColor("Blue", y + 1) )

                if y > 1 then
                    local c = AccentColor("Blue", y + 1)
                    self:diffuseshift()
                    self:effectcolor1( c )
                    self:effectcolor2( BoostColor(c, 0) )
                    self:effectclock("beat")
                else
                    local a = AccentColor("Blue", 1)
                    local b = AccentColor("Blue", 2)
                    self:diffuseshift()
                    self:effectcolor1( b )
                    self:effectcolor2( a )
                    self:effectclock("beat")
                end
            end
        }
    end
end


return t