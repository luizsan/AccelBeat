SelectMusic = {

	-- custom inputs are ignored if true
	lockinput = false,

	-- current sort mode
    currentSort = SortMode.All,

	-- current folder
	-- applies to every sort mode except "All"
    currentFolder = "",	

	-- current filter
	-- only show steps that match criteria
	currentFilter = FilterMode.All,

	-- search results
	searchResults = {},

	-- 0: music
	-- 1: steps
	state = 0,

	-- current Song object
	song = nil,

	-- list of Steps objects currently available for selection
	steps = {},

	-- selected steps indices
	stepsIndex = {
		[PLAYER_1] = 1,
		[PLAYER_2] = 1,
	},

	-- selected steps object
	playerSteps = {
		[PLAYER_1] = nil,
		[PLAYER_2] = nil,
	},

	-- 0: steps not ready
	-- 1: steps ready
	confirm = {
		[PLAYER_1] = 0,
		[PLAYER_2] = 0,
	},

	playerOptions = {
		[PLAYER_1] = {},
		[PLAYER_2] = {},
	}

}