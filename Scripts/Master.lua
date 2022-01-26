function Game()
	local game = string.upper(GAMESTATE:GetCurrentGame():GetName());
	local temp1 = string.sub(string.lower(game), 2);
	local text = string.gsub(string.upper(game),string.upper(temp1),temp1);
	return text
end;