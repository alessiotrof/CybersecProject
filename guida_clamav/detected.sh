#!/bin/bash

# Dichiarazione di variabili per salvare lo stato della scansione e il riepilogo degli elementi infetti.
export SCAN_STATUS
export INFECTED_SUMMARY
export XUSERS

export LOG="/var/log/clamav/scan.log"
export TARGET="/"
export SUMMARY_FILE=`mktemp`

# Aggiunta di un'intestazione al file di log che indica l'inizio della scansione.
echo "------------ SCAN START ------------" >> "$LOG"
echo "Running scan on `date`" >> "$LOG"

# Esecuzione di clamdscan per la scansione.
sudo clamdscan --log "$LOG" --infected --multiscan --fdpass "$TARGET" > "$SUMMARY_FILE"

# Salvataggio dello stato della scansione e del riepilogo degli elementi infetti.
SCAN_STATUS="$?"
INFECTED_SUMMARY=`cat $SUMMARY_FILE | grep Infected`
rm "$SUMMARY_FILE"

# Verifica se sono stati rilevati elementi infetti.
if [[ "$SCAN_STATUS" -ne "0" ]] ; then

  # Invio di un messaggio di emergenza al logger di systemd se disponibile.
  if [[ -n $(command -v systemd-cat) ]] ; then
    echo "Virus signature found - $INFECTED_SUMMARY" | /usr/bin/systemd-cat -t clamav -p emerg
  fi

  # Invio di un avviso a tutti gli utenti grafici connessi.
  XUSERS=($(who|awk '{print $1$NF}'|sort -u))
  for XUSER in $XUSERS; do
    NAME=(${XUSER/(/ })
    DISPLAY=${NAME[1]/)/}
    DBUS_ADDRESS=unix:path=/run/user/$(id -u ${NAME[0]})/bus

    # Invio di una notifica utilizzando notify-send.
    echo "run $NAME - $DISPLAY - $DBUS_ADDRESS -" >> /tmp/testlog
    /usr/bin/sudo -u ${NAME[0]} DISPLAY=${DISPLAY} \
      DBUS_SESSION_BUS_ADDRESS=${DBUS_ADDRESS} \
      PATH=${PATH} \
      /usr/bin/notify-send -i security-low "Virus signature(s) found" "$INFECTED_SUMMARY"
  done

fi
