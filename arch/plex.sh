#!/bin/bash

paru -Syuu plex-desktop
# sudo snap install plex-desktop
# PLEX_LOC="~/.local/share/plex"
PLEX_LOC="$HOME/snap/plex-desktop/common"

crudini --set "$PLEX_LOC"/plex.ini web myPlexAccessToken "$PLEX_TOKEN"
xmlstarlet ed -u "/Preferences/@PlexOnlineToken" -v "$PLEX_TOKEN" "$PLEX_LOC"/"Plex Media Server"/Preferences.xml >tmp.xml && mv tmp.xml ~/.local/share/plex/"Plex Media Server"/Preferences.xml
echo "Maybe you need to add the PLEX_AUTH_TOKEN: $PLEX_AUTH_TOKEN to the user json field in the plex.ini file"
