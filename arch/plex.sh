#!/bin/bash

snap install plex-desktop
crudini --set ~/snap/plex-desktop/common/plex.ini web myPlexAccessToken "$PLEX_TOKEN"
xmlstarlet ed -u "/Preferences/@PlexOnlineToken" -v "$PLEX_TOKEN" ~/snap/plex-desktop/common/Plex Media Server/Preferences.xml >tmp.xml && mv tmp.xml Preferences.xml
echo "Maybe you need to add the PLEX_AUTH_TOKEN: $PLEX_AUTH_TOKEN to the user json field in the plex.ini file"
