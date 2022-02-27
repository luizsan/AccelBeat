BANNER_CACHE = nil

function BannerCache()
    return Def.Banner{
        InitCommand=function(self)
            if BANNER_CACHE ~= nil then return end
            BANNER_CACHE = {}
            local count = 0
            for i, song in ipairs( SONGMAN:GetAllSongs() ) do
                local path = song:GetBannerPath()
                if path then 
                    self:LoadFromCachedBanner(path)
                    BANNER_CACHE[path] = self:GetTexture()
                    count = count + 1
                end
            end
            SCREENMAN:SystemMessage("Cached "..count.." banners")
            self:visible(false)
        end
    }
end