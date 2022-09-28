local Header = {
    width = 1080,
    height = 86,
}

local Glow = {
    width = 1020,
}

local offset = { -1, 0, 1 }
local align = { 1, 0.5, 0 }

local t = Def.ActorFrame{}

-- circuits
-- for i = -1, 1, 2 do
--     t[#t+1] = Def.Sprite{
--         Texture = "../graphics/header_circuits",
--         InitCommand=function(self)
--             self:zoomx(0.666666 * i)
--             self:zoomy(0.666666)
--             self:align(1, 0.333333)
--             self:xy((Header.width - 56) * 0.5 * -i, Header.height * 0.5 + 2)
--             self:fadeleft(1)

--             --self:diffuse( AccentColor("Blue", 1))
--             --self:diffusealpha(0.25)

--             self:rainbow()
--             -- self:effectcolor2( AccentColor( "Blue", 1 ))
--             -- self:effectcolor1( BoostColor( AccentColor( "Blue", 2 ), 0.25))
--             self:effectperiod(30)
--             self:blend("BlendMode_Add")
--         end
--     }
-- end



t[#t+1] = Def.Quad{
    InitCommand=function(self)
        self:align(0.5, 0)
        self:zoomto(Header.width + 32, Header.height - 20)
        self:diffuse( Color.White )
        self:diffusetopedge( BoostColor( Color.White, 0.9 ))
        self:y(6)
    end
}

t[#t+1] = Def.Sprite{
    Texture = THEME:GetPathG("", "patterns/dots"),
    InitCommand=function(self)
        self:zoomto(Header.width + 32, Header.height - 20)
        self:align(0.5, 0)
        
        local w = ( Header.width + 32 ) / 128.0 * 2
        local h = ( Header.height - 16 ) / 128.0 * 2
        self:customtexturerect(0,0.05,w,h)
        self:diffuse( BoostColor( Color.White, 0.1 )):diffusealpha(0.08)
        self:fadebottom(1)
        self:y(8)
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
            self:x(-Header.width * 0.5 * offset[i])
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
                self:xy( Glow.width * 0.5 * offset[x], 70)
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