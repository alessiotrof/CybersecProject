#!/bin/bash

# Parametri dello script
user_dir="home/default_user_dir" # La cartella radice di default da cui partire
group_dir="home/default_group_dir" # La cartella radice di default del gruppo
populate_group_dir=false # Flag che indica se popolare o meno la cartella del gruppo
max_depth=5 # La profondità massima della gerarchia
max_files=10 # Il numero massimo di file per cartella
max_folders=5 # Il numero massimo di sottocartelle per cartella

# Nomi dei file che usa lo script
file_filenames="file_names.txt"
file_foldernames="folder_names.txt"
file_paragraphs="paragraphs.txt"
file_titles="titles.txt"


# Funzione che genera un nome casuale di una cartella
gen_folder_name() {

  if [ -f "$file_foldernames" ]; then
    readarray -t words < $file_foldernames
  else
    echo "ERRORE: Il file $file_foldernames non esiste."
    exit 1
  fi

  local index=$((RANDOM % ${#words[@]}))
  echo "${words[$index]}"
}

# Funzione che genera un nome casuale di un file
gen_file_name() {
  
  if [ -f "$file_filenames" ]; then
    readarray -t prefixes < $file_filenames
  else
    echo "ERRORE: Il file $file_filenames non esiste."
    exit 1
  fi


  local suffixes=(.txt) # è possibile anche aggiungere più suffissi qui per i file intermedi
  local prefix_index=$((RANDOM % ${#prefixes[@]}))
  local suffix_index=$((RANDOM % ${#suffixes[@]}))
  echo "${prefixes[$prefix_index]}${suffixes[$suffix_index]}"
}

# Funzione che genera il contenuto casuale di un file .md con più titoli
gen_file_content() {

  # Genera un numero casuale tra 3 e 5 per il numero di titoli da includere
  NUM_TITLES=$((3 + RANDOM % 10))

  local content=""

  # Per ogni titolo da scrivere
  for ((k=1; k<=NUM_TITLES; k++))
  do
    # Sceglie un titolo casuale dall'array dei titoli
    TITLE=${TITLES[$((RANDOM % ${#TITLES[@]}))]}

    # Aggiunge il titolo al contenuto del file .md usando la sintassi del markdown
    content+="# $TITLE\n\n"

    # Genera un numero casuale tra 5 e 10 per il numero di paragrafi da scrivere per ogni titolo
    NUM_PARAGRAPHS=$((5 + RANDOM % 15))

    # Per ogni paragrafo da scrivere per il titolo corrente
    for ((j=1; j<=NUM_PARAGRAPHS; j++))
    do
      # Sceglie un paragrafo casuale dall'array dei paragrafi
      PARAGRAPH=${PARAGRAPHS[$((RANDOM % ${#PARAGRAPHS[@]}))]}

      # Aggiunge il paragrafo al contenuto del file .md usando la sintassi del markdown
      content+="$PARAGRAPH\n\n"
    done
  done

  echo -e "$content"
}


# Funzione che genera una gerarchia di file verosimile
gen_file_hierarchy() {

  local root_dir=$1 # La cartella radice da cui partire
  local max_depth=$2 # La profondità massima della gerarchia
  local max_files=$3 # Il numero massimo di file per cartella
  local max_folders=$4 # Il numero massimo di sottocartelle per cartella
  local depth=$5 # La profondità corrente della gerarchia

  if [[ $depth -le $max_depth ]]; then
    local num_files=$((RANDOM % $max_files + 1)) # Il numero di file da creare in questa cartella
    local num_folders=$((RANDOM % $max_folders + 1)) # Il numero di sottocartelle da creare in questa cartella
    
    for ((i=0; i<$num_files; i++)); do
      local file_name=$(gen_file_name) # Il nome del file da creare
      local file_content=$(gen_file_content) # Il contenuto del file da creare
      echo -e "$file_content" > "$root_dir/$file_name" # Creazione del file

      # Sceglie casualmente se convertire il file appena creato in .pdf, .docx oppure odt
      convert_choice=$((RANDOM % 3))
      case $convert_choice in
        0)
          pandoc "$root_dir/$file_name" --pdf-engine=xelatex -o "$root_dir/$(basename -s .txt $file_name).pdf"
          ;;
        1)
          pandoc -s "$root_dir/$file_name" -o "$root_dir/$(basename -s .txt $file_name).docx"
          ;;
        2) 
          pandoc "$root_dir/$file_name" -o "$root_dir/$(basename -s .txt $file_name).odt"
          ;;
      esac
    done

    for ((i=0; i<$num_folders; i++)); do
      local folder_name=$(gen_folder_name) # Il nome della sottocartella da creare
      mkdir "$root_dir/$folder_name" # Creazione della sottocartella
      gen_file_hierarchy "$root_dir/$folder_name" $max_depth $max_files $max_folders $((depth + 1)) # Chiamata ricorsiva per creare la gerarchia nella sottocartella
    done

  fi
}


#
# Verifica dei parametri
#

# Verifica se ci sono argomenti passati
if [ "$#" -ne 0 ]; then
  echo "Lo script non accetta argomenti. Utilizzo: $0"
  exit 1
fi

# Verifica se pandoc è installato
if ! command -v pandoc &> /dev/null; then
  echo "Errore: Pandoc non è installato. Installalo prima di eseguire lo script."
  exit 1
fi


#
# TUTTO OK! Proseguo!
#


# Ciclo while che continua fino a quando l'utente fornisce un numero valido
while true; do
    # Chiedi all'utente di inserire un numero
    read -p "Inserisci il numero degli utenti da aggiungere all'albero LDAP: " user_number

    # Controlla se l'input è un numero intero
    if [[ "$user_number" =~ ^[0-9]+$ ]]; then
        NUMBER="$user_number"
        break  # Esce dal ciclo se l'input è un numero valido
    else
        echo "ERRORE: Inserisci un numero valido."
    fi
done

# Legge i titoli e i paragrafi da dei file esterni
if [ -f "$file_titles" ]; then
  readarray -t TITLES < $file_titles
else
  echo "ERRORE: Il file $file_titles non esiste."
  exit 1
fi

if [ -f "$file_paragraphs" ]; then
  readarray -t PARAGRAPHS < $file_paragraphs
else
  echo "ERRORE: Il file $file_paragraphs non esiste."
  exit 1
fi


# Itera attraverso il numero di utenti specificato
for ((user_index=1; user_index<=NUMBER; user_index++)); do

  user_name=""

  while [ -z "$user_name" ]; do
    read -p "Inserisci il nome dell'utente numero $user_index da aggiungere all'albero LDAP: " user_name

    if [ -z "$user_name" ]; then
        echo "La stringa inserita è vuota. Inserisci una stringa valida."
    fi
  done

  # Controllo se l'utente esiste già in LDAP
  user_search_res=$(ldapsearch -Q -LLL -Y EXTERNAL -H ldapi:/// -b "ou=users,dc=cyber,dc=samba,dc=org" "(uid=$user_name)")
  if [ $? -eq 0 ] && [ -z "$user_search_res" ]; then
    # L'utente non esiste, lo creo
    echo "OK! L'utente $user_name non è già esistente! Lo creo!"
    smbldap-useradd -m -P -a $user_name -s ""
  else 
    # L'utente esiste già!
    echo "ERRORE! L'utente $user_name esiste già!"
    exit 1
  fi

  answer=""

  # Controllo la risposta dell'utente 
  while [[ ! "$answer" =~ ^[YyNn]$ ]]; do
    read -p "Vuoi creare un gruppo per l'utente $user_name? (y/n): " answer
  done

  # Ora puoi fare qualcosa con la risposta
  if [[ "$answer" =~ ^[Yy]$ ]]; then
      echo "OK! Verrà creato un gruppo per l'utente $user_name"

      group_name=""
      while [ -z "$group_name" ]; do
        read -p "Inserisci il nome del gruppo: " group_name
        
        if [ -z "$group_name" ]; then
          echo "La stringa inserita è vuota. Inserisci una stringa valida."
        fi
      done

      group_search_res=$(ldapsearch -Q -LLL -Y EXTERNAL -H ldapi:/// -b "ou=groups,dc=cyber,dc=samba,dc=org" "(cn=$group_name)")
      
      # Controllo se il gruppo esiste già
      if [ $? -eq 0 ] && [ -z "$group_search_res" ]; then
        # Il gruppo non esiste, lo creo
        echo "OK! Il gruppo $group_name non è già esistente! Lo creo!"
        smbldap-groupadd -a $group_name

        echo "OK! Metto l'utente $user_name nel gruppo $group_name"
        smbldap-groupmod -m $user_name $group_name

        group_dir="/home/$group_name"
        if [ -d "$group_dir" ]; then
          echo "La cartella $group_dir esiste già. Non la ricreo!"
          populate_group_dir=false
        else
          echo "La cartella $group_dir non esiste. Verrà creata e riempita!"
          populate_group_dir=true
        fi

      else
        # Il gruppo esiste già!
        echo "Il gruppo $group_name esiste già! L'utente $user_name verrà ora inserito nel gruppo $group_name"
        smbldap-groupmod -m $user_name $group_name

        group_dir="/home/$group_name"
        if [ -d "$group_dir" ]; then
          echo "La cartella $group_dir esiste già. Non la ricreo!"
          populate_group_dir=false
        else
          echo "La cartella $group_dir non esiste. Verrà creata e riempita!"
          populate_group_dir=true
        fi

      fi

  else
    echo "OK! Non verrà creato un gruppo per l'utente $user_name"
    populate_group_dir=false
  fi


  # Controllo se la cartella Desktop esiste nella home dell'utente
  user_dir="/home/$user_name/Desktop"
  if [ -d "$user_dir" ]; then
    echo "La cartella 'Desktop' dentro alla home dell'utente esiste. Popolo quella!"
  else
    echo "La cartella 'Desktop' dentro alla home dell'utente non esiste. La creo!"
    mkdir $user_dir
  fi


  # Riempimento della cartella dell'utente
  echo "Riempimento della cartella dell'utente $user_name... Attendere..."

  # Creazione della gerarchia di file verosimile
  gen_file_hierarchy "$user_dir" $max_depth $max_files $max_folders 1

  # Elimina i file .txt generati
  find "$user_dir" -type f -name "*.txt" -delete

  echo "Aggiungo la cartella $user_dir alle cartelle da scansionare con ClamAV"
  echo "OnAccessIncludePath $user_dir" >> /etc/clamav/clamd.conf

  echo "Fatto!"

  if $populate_group_dir; then
    # Creazione della cartella del gruppo
    echo "Creazione e riempimento della cartella del gruppo $group_name... Attendere..."
    mkdir "$group_dir"

    # Creazione della gerarchia di file verosimile
    gen_file_hierarchy "$group_dir" $max_depth $max_files $max_folders 1

    # Elimina i file .txt generati
    find "$group_dir" -type f -name "*.txt" -delete

    #
    # Per settare i permessi del gruppo
    #
    chown root:$group_name /home/$group_name
    chmod g+rwx /home/$group_name
    echo "" >> /etc/samba/smb.conf
    echo "[$group_name]" >> /etc/samba/smb.conf
    echo "   path = /home/$group_name" >> /etc/samba/smb.conf
    echo "   read only = no" >> /etc/samba/smb.conf
    echo "   browseable = yes" >> /etc/samba/smb.conf
    echo "   valid users = @$group_name" >> /etc/samba/smb.conf
    service smbd restart

    echo "Fatto!"
    
  fi

  echo "Fine!"

done


