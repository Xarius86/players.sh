# players.sh

A script to generate a list of all players that have joined a Minecraft server.

# Prerequisites

You must have `curl` and `jq` installed.

You must have `nbted` installed from https://github.com/C4K3/nbted

# How to Use

1. Download `players.sh`
2. Place script inside your `/server/<worldname>/playerdata` folder.
3. Make the script executable using `chmod 755`
4. Run the script using `./players.sh <options>`
5. A file named `players.txt` will be generated. 

# Options

## \-\-nbtonly
This will produce faster, but less accurate results. 
