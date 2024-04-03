# HomeLab-Proxmox-Backup-Server

## Rozszerzony Poradnik: Zmiana Statusu Ochrony Snapshotów w Proxmox Backup Server

### Wstęp
Ten poradnik opisuje, jak zmienić status ochrony snapshotów w Proxmox Backup Server, używając linii poleceń. Poradnik zakłada, że masz podstawową wiedzę na temat pracy z Proxmox oraz narzędzi linii poleceń.

### Zrozumienie Składników

### Adres Repozytorium
`root@pam@pbs:BACKUP-PBS` to przykładowy adres repozytorium. Składa się on z kilku części:
- `root@pam` to poświadczenia użytkownika. `root` to nazwa użytkownika, a `pam` to metoda uwierzytelniania.
- `pbs` to nazwa hosta serwera Proxmox Backup Server.
- `BACKUP-PBS` to nazwa datastore na serwerze.

Zastąp te wartości odpowiednimi dla Twojego środowiska.

## Generowanie Listy Snapshotów

Wykonaj poniższe polecenie, aby wygenerować listę wszystkich snapshotów do pliku JSON:

 ```bash
proxmox-backup-client snapshots --repository root@pam@pbs:BACKUP-PBS > snapshots_output.json
 ```

## Filtrowanie Chronionych Snapshotów

Następnie użyj narzędzia `jq`, aby wyfiltrować snapshoty z włączoną ochroną:

 ```bash
jq -r 'map(select(.protected == true)) | .[] | .["backup-type"] + "/" + .["backup-id"] + "/" + (.["backup-time"] | strftime("%Y-%m-%dT%H:%M:%SZ"))' snapshots_output.json > protected_snapshots.txt
 ```

## Skrypt do Generowania Poleceń Zmiany Ochrony

Stwórz poniższy skrypt, który generuje polecenia do zmiany statusu ochrony snapshotów:

 ```bash
#!/bin/bash

# Path to the JSON file containing snapshot information
JSON_FILE="/root/snapshots_output.json"

# Repository information
REPOSITORY="root@pam@pbs:BACKUP-PBS"

# Command file
COMMAND_FILE="update_protection_commands.sh"

# Create or overwrite the command file
echo "#!/bin/bash" > $COMMAND_FILE

# Extracting necessary data from JSON and formatting it into the required command structure with success/failure messages
jq -r 'map(select(.protected == true)) | .[] | "proxmox-backup-client snapshot protected update " + .["backup-type"] + "/" + .["backup-id"] + "/" + (.["backup-time"] | strftime("%Y-%m-%dT%H:%M:%SZ")) + " false --repository '"'$REPOSITORY'"' && echo \"Pomyślnie zmieniono ochronę dla " + .["backup-type"] + "/" + .["backup-id"] + "/" + (.["backup-time"] | strftime("%Y-%m-%dT%H:%M:%SZ")) + "\" || echo \"Błąd przy zmianie ochrony dla " + .["backup-type"] + "/" + .["backup-id"] + "/" + (.["backup-time"] | strftime("%Y-%m-%dT%H:%M:%SZ")) + "\""' $JSON_FILE >> $COMMAND_FILE

# Make the command file executable
chmod +x $COMMAND_FILE

echo "Commands to update snapshot protection status, with success or failure messages, are written to $COMMAND_FILE"
echo "Run './$COMMAND_FILE' to execute them."

 ```

### Uruchomienie skryptu
Po utworzeniu skryptu `generate_update_commands.sh`, uruchom go:

 ```bash
chmod +x generate_update_commands.sh
./generate_update_commands.sh
```
Następnie uruchom wygenerowany skrypt update_protection_commands.sh:
    
```bash 
./update_protection_commands.sh
```
## Skrypt ten wykona wszystkie wygenerowane polecenia i wyświetli komunikat o powodzeniu lub niepowodzeniu aktualizacji ochrony dla każdego snapshota.

## Podsumowanie

Po wykonaniu tych kroków, status ochrony wybranych snapshotów zostanie zaktualizowany. Upewnij się, że rozumiesz konsekwencje wykonywanych działań i zawsze sprawdzaj polecenia przed ich wykonaniem.