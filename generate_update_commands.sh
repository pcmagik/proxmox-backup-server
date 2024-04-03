#!/bin/bash

# Path to the JSON file containing snapshot information
JSON_FILE="/root/snapshots_output.json"

# Repository information
REPOSITORY="root@pam@pbs:BACKUP-PBS"

# Command file
COMMAND_FILE="update_protection_commands.sh"

# Create or overwrite the command file
echo "#!/bin/bash" > $COMMAND_FILE

# Extracting necessary data from JSON and formatting it into the required command structure
jq -r 'map(select(.protected == true)) | .[] | "proxmox-backup-client snapshot protected update " + .["backup-type"] + "/" + .["backup-id"] + "/" + (.["backup-time"] | strftime("%Y-%m-%dT%H:%M:%SZ")) + " false --repository '$REPOSITORY'"' $JSON_FILE >> $COMMAND_FILE

# Make the command file executable
chmod +x $COMMAND_FILE

echo "Commands to update snapshot protection status are written to $COMMAND_FILE"
echo "Run './$COMMAND_FILE' to execute them."
