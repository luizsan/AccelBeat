function Game()
	local game = string.upper(GAMESTATE:GetCurrentGame():GetName());
	local temp1 = string.sub(string.lower(game), 2);
	local text = string.gsub(string.upper(game),string.upper(temp1),temp1);
	return text
end;

function pnSide(pn)
	if pn == PLAYER_1 then return -1 end
	if pn == PLAYER_2 then return 1 end
	return 0
end

function pnAlign(pn)
	if pn == PLAYER_1 then return 0 end
	if pn == PLAYER_2 then return 1 end
	return 0
end