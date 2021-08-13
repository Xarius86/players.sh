#!/bin/bash
# https://github.com/Xarius86/players.sh

# Script to generate a list of all players that have joined a Minecraft server.
# Place in /server/world/playerdata folder. Make executable, and run.
# Will generate players.txt that includes player names and UUID's.
# REQUIRES 'curl' and 'jq' to be installed on your system.
# REQUIRES 'nbted' from https://github.com/C4K3/nbted

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# Remove any existing players.txt file.
OLD_FILE="players.txt";
if test -f "$OLD_FILE"; then
    echo "Deleting old players.txt...";
    rm $OLD_FILE;
fi

# Remove any existing temporary files. (If user exited early or something.)
OLD_FILE="players2.tmp";
if test -f "$OLD_FILE"; then
    echo "Deleting old players2.tmp...";
    rm $OLD_FILE;
fi

OLD_FILE="uuids.tmp";
if test -f "$OLD_FILE"; then
    echo "Deleting old uuids.tmp...";
    rm $OLD_FILE;
fi

OLD_FILE="uuids2.tmp";
if test -f "$OLD_FILE"; then
    echo "Deleting old uuids2.tmp...";
    rm $OLD_FILE;
fi

# Get list of UUID's, excluding *.dat_old.
echo "Gathering list of players...";
ls | grep -Ei "dat" | grep -Eiv "dat_old" >> uuids.tmp;

# Trim .dat file extension from UUID's.
sed 's/\.dat *$//' uuids.tmp > uuids2.tmp && mv uuids2.tmp uuids.tmp;

# Loop through each UUID
echo "Retrieving player names...";
FILE="uuids.tmp";
LINES=$(cat $FILE);
i=1;

# Get total player count and determine if wait times are needed.
TOT_LINES=$(wc -l < $FILE);

if [ $TOT_LINES -lt 600 ]; then
    WAIT_TIME=0;
else
    WAIT_TIME=10;
    echo "To stay within Mojang API limits, wait time between requests is: $WAIT_TIME seconds.";
fi

for LINE in $LINES
do
    # Get name from UUID using Mojang API
    if [ $1 = "--nbtonly" ]; then
        UUID_NAME="";
    else
        UUID_JSON_STRING="curl -s 'https://api.mojang.com/user/profiles/$LINE/names'";
        UUID_NAME_STRING="$UUID_JSON_STRING | jq '.[-1].name'";
        UUID_NAME=$(eval $UUID_NAME_STRING | sed 's/"//g' );
    fi

    # Check for empty name.
    if [ -z $UUID_NAME ]; then

        # Check for Geyser name.
        GEYSER_NAME_STRING=$(eval nbted -p $LINE.dat | grep 'String "lastKnownName"');
        PREFIX='String lastKnownName';
        GEYSER_NAME=$(eval echo $GEYSER_NAME_STRING | sed -e "s/^$PREFIX//");

        # Check that Geyser name isn't empty.
        if [ -z "$GEYSER_NAME" ]; then
            UUID_NAME="N/A";
        else
            UUID_NAME="$GEYSER_NAME";
        fi
    fi

    # Show progress in terminal.
    echo "($i/$TOT_LINES)";

    # Add output to players.txt.
    echo "$i $UUID_NAME $LINE" >> players.txt;
    let i+=1;

    # Wait if needed to stay within API limits.
    sleep $WAIT_TIME;
done

# Format the text file...
echo "Formatting players.txt..."
awk '{ printf("%-5s %-40s %-10s\n", $1, $2, $3)}' players.txt > players2.tmp && mv players2.tmp players.txt; 

# Remove temporary UUID list.
echo "Removing temporary files...";
rm uuids.tmp;
echo "Done.";