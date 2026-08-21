#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")

source "${scriptDir}/../utils.sh"

_VERBOSE=1

# Install only packages that Ubuntu actually publishes for the running release
# and architecture.  This keeps one missing/unsupported game from preventing the
# rest of the curated list from being installed.
function installAvailableAptPackages () {
	local packageName
	local -a availablePackages=()

	for packageName in "$@"; do
		if apt-cache show "$packageName" >/dev/null 2>&1; then
			availablePackages+=("$packageName")
		else
			echo "${packageName}: not available for Ubuntu $(getOsVers) / $(dpkg --print-architecture); skipping"
		fi
	done

	if [[ ${#availablePackages[@]} -gt 0 ]]; then
		sudo apt-get install --yes "${availablePackages[@]}"
	fi
}

function installGames2604 () {
	# Curated FOSS games for Ubuntu 26.04 LTS.
	#
	# Selection rules:
	#   * Open-source packages from Ubuntu's supported repositories.
	#   * Playable locally without a subscription or mandatory account/login.
	#   * No separately purchased/commercial game data is required.
	#   * Prefer one strong representative per game type rather than installing
	#     many near-duplicates.
	#   * KDE/Qt applications are preferred where there is a strong equivalent,
	#     making the collection a natural fit on Kubuntu as well as Ubuntu.
	#
	# The 50 entries below are logical games.  Engine/data/helper packages used
	# by a few games are installed separately afterward and are not counted.
	local -a gamePackages=(
		# Strategy, tactics, building, and management
		0ad                 # Historical real-time strategy
		wesnoth             # Fantasy turn-based tactical strategy
		widelands           # Settlement/economy strategy
		freeciv-client-qt   # Civilization-style 4X strategy
		openttd             # Transport management simulation
		lincity-ng          # City-building simulation
		hedgewars           # Turn-based artillery tactics
		pioneers            # Settlers-of-Catan-style board strategy

		# Action, arcade, simulation, and adventure
		supertuxkart        # 3D kart racing
		supertux            # 2D platformer
		neverball           # 3D rolling-ball obstacle game
		frozen-bubble       # Bubble shooter
		kbreakout           # Breakout / brick breaker
		kapman              # Pac-Man-style maze chase
		granatier           # Bomberman-style action
		kgoldrunner         # Lode-Runner-style action puzzle
		openarena           # First-person shooter
		luanti              # Voxel sandbox (formerly Minetest engine)
		endless-sky         # Space exploration, trading, and combat
		flightgear          # Flight simulator
		xmoto               # 2D motocross physics game
		armagetronad        # Light-cycle arena game
		pinball             # Pinball
		billard-gl          # 3D billiards / pool
		slimevolley         # Arcade volleyball
		crawl               # Dungeon Crawl Stone Soup roguelike
		fillets-ng          # Sokoban-style puzzle adventure
		pingus              # Lemmings-style puzzle game

		# Board, tile, dice, and card games
		knights             # Chess GUI; Stockfish installed below
		kigo                # Go GUI; GNU Go installed below
		gnubg               # Backgammon
		kreversi            # Reversi / Othello
		bovo                # Gomoku / five-in-a-row
		kfourinline         # Connect Four
		ksquares            # Dots and Boxes
		kajongg             # Traditional four-player Mahjong
		kiriki              # Yahtzee-style dice game
		kpat                # Solitaire card collection
		pokerth             # Texas Hold'em poker; local bots supported
		lskat               # Skat card game
		kmahjongg           # Mahjong tile-matching solitaire

		# Puzzle and word games
		kblocks             # Tetris-style falling blocks
		ksudoku             # Sudoku
		kmines              # Minesweeper
		2048-qt             # 2048 sliding-number puzzle
		palapeli            # Jigsaw puzzles
		picmi               # Nonogram / picross
		knetwalk            # Network-rotation logic puzzle
		kblackbox           # Black Box deduction puzzle
		tanglet             # Boggle-style word-finding game
	)

	# Supporting FOSS packages needed to make several of the games above fully
	# useful offline.  These are engines, local servers, free assets, or tables,
	# not additional games in the 50-game count.
	local -a supportingPackages=(
		stockfish           # Chess engine for Knights
		gnugo               # Go engine for Kigo
		freeciv-server      # Local single-player/server support for Freeciv
		openttd-opengfx     # Free OpenTTD graphics
		openttd-openmsx     # Free OpenTTD music
		luanti-game-minetest # Self-contained Minetest Game for Luanti
		pinball-table-gnu   # Free table for Emilia Pinball
	)

	echo "FOSS games: refreshing Ubuntu package indexes"
	sudo apt-get update

	echo "FOSS games: installing curated Ubuntu 26.04 games"
	installAvailableAptPackages "${gamePackages[@]}"

	echo "FOSS games: installing supporting engines and free game data"
	installAvailableAptPackages "${supportingPackages[@]}"
}

if [[ "$(getOsVers)" == "16.04" || "$(getOsVers)" == "18.04" || "$(getOsVers)" == "20.04" || "$(getOsVers)" == "22.04" || "$(getOsVers)" == "24.04" ]]; then
	# Preserve the historical behavior on older Ubuntu releases.  The larger
	# curated collection below has been specifically validated for Ubuntu 26.04
	# rather than assuming package compatibility on old releases.
	sudo apt-get install --yes blockout2
	sudo snap install lucas-chess
elif [[ "$(getOsVers)" == "26.04" ]]; then
	installGames2604
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
