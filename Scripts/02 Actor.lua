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