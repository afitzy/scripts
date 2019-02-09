#!/bin/bash

export WINEDEBUG="-all"
export WINEPREFIX="${HOME}/.wine"
cd "${WINEPREFIX}/drive_c/Program Files (x86)/Pharaoh/"
wine "Pharaoh.exe"
