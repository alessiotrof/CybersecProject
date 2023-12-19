# Da utilizzare cu container Docker!

# Percorso di output del log
LOG_FILE="/var/log/clamscan.log"
# Percorso della cartella di quarantena
QUARANTINE_DIR="/var/quarantine"

# Crea la cartella di quarantena se non esiste
mkdir -p "$QUARANTINE_DIR"

# Esegue la scansione con clamscan nella cartella /home/ e sposta i file infetti in quarantena
clamscan -r /home/ --log="$LOG_FILE" --move="$QUARANTINE_DIR"

# Aggiunge un timestamp al log
echo "Scan completed on $(date)" >> "$LOG_FILE"
