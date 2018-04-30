#!/bin/bash

# Link the two MIME files. Since it's unclear which KDE is using, better that they match
ln -s  "${HOME}/.local/share/applications/mimeapps.list" "${HOME}/.config/mimeapps.list"
