#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")

source "${scriptDir}/../utils.sh"

_VERBOSE=1

# Install only packages that Ubuntu actually publishes for the running release
# and architecture. This keeps one unavailable package from preventing the rest
# of the curated educational collection from being installed.
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

# Some applications have substantially newer/better-supported upstream releases
# on Flathub than in Ubuntu 26.04, or are not packaged in Ubuntu 26.04 at all.
# Add Flathub system-wide so these applications are available to every local user.
function ensureFlathub () {
	if ! command -v flatpak >/dev/null 2>&1; then
		echo "Flatpak: installing"
		sudo apt-get install --yes flatpak
	fi

	if ! flatpak remotes --system --columns=name 2>/dev/null | grep -Fxq "flathub"; then
		echo "Flathub: adding system remote"
		sudo flatpak remote-add --system --if-not-exists flathub \
			https://flathub.org/repo/flathub.flatpakrepo
	fi
}

# Check the stable Flathub catalog before installing each application. This also
# naturally skips applications not published for the machine's architecture.
function installAvailableFlatpaks () {
	local appId

	for appId in "$@"; do
		if flatpak info --system "$appId" >/dev/null 2>&1; then
			echo "${appId}: already installed"
		elif flatpak remote-info --system flathub "$appId" >/dev/null 2>&1; then
			echo "${appId}: installing from Flathub"
			sudo flatpak install --system --noninteractive --assumeyes flathub "$appId"
		else
			echo "${appId}: not available from stable Flathub for $(dpkg --print-architecture); skipping"
		fi
	done
}

function installEducational2604 () {
	# Curated modern FOSS educational software for Ubuntu/Kubuntu 26.04 LTS.
	#
	# Selection rules:
	#   * Free/open-source software.
	#   * Actively maintained and suitable for a modern desktop.
	#   * Interactive rather than primarily static/reference material.
	#   * Strong reputation, substantial real-world use, or strong educator/student
	#     recommendations. No filler is included simply to increase the app count.
	#   * Playable/usable locally without a subscription or mandatory account/login.
	#   * Prefer Ubuntu packages when Ubuntu 26.04 carries a current release.
	#   * Prefer stable Flathub builds where Ubuntu's package is stale/missing and
	#     the upstream/Flathub release provides a materially better current UI.
	#   * Avoid obsolete educational software and unnecessary near-duplicates.
	#
	# Optional online/sync features in applications such as Anki, Zotero, MuseScore,
	# and Godot are not required for normal local use.

	local -a educationalPackages=(
		# Broad learning and younger learners
		gcompris-qt          # ~200 interactive activities: math, reading, logic, science, computing
		tuxpaint             # Modern child-friendly drawing/creative learning environment
		ktouch               # Interactive touch-typing tutor with lessons and progress tracking

		# Geography and astronomy
		kgeography           # Interactive countries, capitals, flags, maps, and geography quizzes
		marble               # Interactive virtual globe and world atlas
		stellarium           # Modern interactive planetarium and astronomy exploration

		# Mathematics, geometry, and physics
		kbruch               # Fractions, arithmetic, factoring, and percentage practice
		kalgebra             # Algebra calculator plus interactive 2D/3D graphing
		kig                  # Dynamic interactive geometry
		step                 # Interactive physics simulator for mechanics and dynamics
		qalculate-qt         # Modern scientific/unit calculator with a strong GUI
		cantor               # KDE interactive mathematical worksheet/notebook interface
		octave               # GNU Octave numerical mathematics and scientific programming

		# Chemistry and molecular science
		kalzium              # Interactive periodic table and chemistry tools
		avogadro             # Modern 3D molecular editor and visualization environment

		# Programming and computer science
		kturtle              # Friendly Logo/turtle-style introductory programming
		thonny               # Beginner-focused Python IDE and visual debugger
		rocs                 # Interactive graph theory and data-structure IDE

		# Languages, vocabulary, and memory
		parley               # KDE vocabulary/language trainer
		mnemosyne            # Spaced-repetition flash-card learning
		kwordquiz            # Simple flashcards and question/answer vocabulary practice

		# Music education
		minuet               # Ear training, intervals, scales, chords, and music theory

		# Advanced STEM / project-based learning
		kicad                # Professional schematic/PCB design; excellent electronics learning tool
		labplot              # Interactive scientific plotting and data analysis
		qgis                 # Professional GIS for geography, geology, mapping, and spatial analysis
	)

	# These packages support the applications above but are not additional apps.
	local -a supportingPackages=(
		cantor-backend-kalgebra
		cantor-backend-octave
		cantor-backend-python3
		tuxpaint-plugins-default
		tuxpaint-stamps-default
		kicad-libraries
		kicad-demos
		kicad-doc-en
	)

	# Curated stable Flatpaks. These are deliberately used only where the current
	# Flathub application is the preferred Ubuntu 26.04 installation path.
	local -a educationalFlatpaks=(
		net.ankiweb.Anki                  # Modern spaced repetition; excellent for serious study
		org.musescore.MuseScore           # Current MuseScore Studio for notation/composition/music learning
		org.freecad.FreeCAD               # Current parametric 3D CAD for engineering/design/3D-printing learning
		com.github.reds.LogisimEvolution  # Modern digital-logic/circuit simulator; replaces classic Logisim
		net.sonic_pi.SonicPi              # Learn coding through live music composition and performance
		ch.openboard.OpenBoard            # Interactive whiteboard designed for schools and universities
		org.zotero.Zotero                 # Research organization, annotation, bibliography, and citations
		org.turbowarp.TurboWarp           # Fast, modern Scratch-compatible block programming environment
		org.godotengine.Godot             # Modern FOSS game engine for project-based programming/design learning
		org.jaspstats.JASP                # Modern GUI for classical/Bayesian statistics; strong teaching reputation
	)

	echo "Educational software: refreshing Ubuntu package indexes"
	sudo apt-get update

	echo "Educational software: installing curated Ubuntu 26.04 applications"
	installAvailableAptPackages "${educationalPackages[@]}"

	echo "Educational software: installing supporting packages and learning content"
	installAvailableAptPackages "${supportingPackages[@]}"

	echo "Educational software: preparing Flathub for current upstream applications"
	ensureFlathub

	echo "Educational software: installing curated stable Flathub applications"
	installAvailableFlatpaks "${educationalFlatpaks[@]}"
}

if [[ "$(getOsVers)" == "26.04" ]]; then
	installEducational2604
else
	echo "Unsupported Ubuntu version: $(getOsVers). This educational collection has been validated for Ubuntu 26.04 only."
fi
