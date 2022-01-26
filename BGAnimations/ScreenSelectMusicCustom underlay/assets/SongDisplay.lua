local ItemType = {
    Song = "Song",
    Folder = "Folder",
    Sort = "Sort",
}

return Def.ActorFrame{
    Def.Quad{
        OnCommand=function(self)
            self:valign(0)
            self:zoomto(1140, 64)
            self:x(SCREEN_CENTER_X)
            self:y(48)
            self:shadowlength(2)
        end
    },

    Def.BitmapText{
        Name = "Title",
        Font = "Common Normal",
        -- Font = "NewRodinB-24",
        Text = "Song Title",
        OnCommand=function(self)
            self:diffuse(0.1,0.1,0.1,1)
            self:halign(0)
            self:valign(0)
            self:x(SCREEN_CENTER_X - 520)
            self:y(58)
            self:zoom(0.75)
            self:strokecolor(0,0,0,0.2)
        end,
        GridSelectedMessageCommand=function(self,context)
            if not context or not context.type then return end
            if context.type == ItemType.Song then
                self:settext( context.content:GetMainTitle(), context.content:GetTranslitMainTitle() )
            elseif context.type == ItemType.Folder then
                self:settext( context.content )
            elseif context.type == ItemType.Sort then
                self:settext( context.content )
            end
        end,
    },
    
    Def.BitmapText{
        Name = "Artist",
        Font = "Common Normal",
        -- Font = "NewRodinB-24",
        Text = "Artist",
        OnCommand=function(self)
            self:diffuse( Color.Blue )
            self:halign(0)
            self:valign(0)
            self:x(SCREEN_CENTER_X - 520)
            self:y(80)
            self:zoom(0.6)
        end,
        GridSelectedMessageCommand=function(self,context)
            if not context or not context.type then return end
            if context.type == ItemType.Song then
                self:settext( context.content:GetDisplayArtist(), context.content:GetTranslitArtist() )
            elseif context.type == ItemType.Folder then
                self:settext( context.num_songs.." songs" )
            elseif context.type == ItemType.Sort then
                self:settext( "Sort Mode ")
            end
        end,
    },
    
    Def.BPMDisplay{
        Name = "BPM",
        Font = "Common Normal",
        -- Font = "NewRodinB-24",
        Text = "000",
        OnCommand=function(self)
            self:diffuse( Color.Blue )
            self:halign(1)
            self:valign(0)
            self:x(SCREEN_CENTER_X + 520)
            self:y(82)
            self:zoom(0.6)
        end,
        GridSelectedMessageCommand=function(self,context)
            if not context or not context.type then return end
            if context.type == ItemType.Song then
                self:SetFromSong( context.content )
                self:visible(true)
            else
                self:visible(false)
            end
        end,
    },

}