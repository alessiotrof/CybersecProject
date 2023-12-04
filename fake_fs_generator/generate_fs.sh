#!/bin/bash

# Parametri dello script
user_dir="home/default_user_dir" # La cartella radice di default da cui partire
group_dir="home/default_group_dir"
populate_group_dir=false # flag che mi dice se devo popolare la directory del gruppo o meno
max_depth=5 # La profondità massima della gerarchia
max_files=10 # Il numero massimo di file per cartella
max_folders=5 # Il numero massimo di sottocartelle per cartella


#
# Verifica dei parametri
#


# Verifica se ci sono argomenti passati
if [ "$#" -ne 0 ]; then
    echo "Lo script non accetta argomenti. Utilizzo: $0"
    exit 1
fi

# Controlla se lo script è stato invocato tramite sudo
if [ "$EUID" -ne 0 ]; then
    echo "Lo script deve essere eseguito con i privilegi di amministratore (sudo)."
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

while [ -z "$user_name" ]; do
    echo "Inserisci il nome dell'utente da aggiungere all'albero LDAP: "
    read -r user_name

    if [ -z "$user_name" ]; then
        echo "La stringa inserita è vuota. Per favore, inserisci una stringa valida."
    fi
done

# Controllo se l'utente esiste già in LDAP
user_search_res=$(ldapsearch -Q -LLL -Y EXTERNAL -H ldapi:/// -b "ou=users,dc=cyber,dc=samba,dc=org" "(uid=$user_name)")
if [ $? -eq 0 ] && [ -z "$user_search_res" ]; then
  # L'utente non esiste, lo creo
  echo "OK! L'utente $user_name non è già esistente! Lo creo!"
  #smbldap-useradd -P -a $user_name -s ""
  smbldap-useradd -m -P -a $user_name -s ""
  #user_dir="/home/$user_name"
else 
  # L'utente esiste già!
  echo "ERRORE! L'utente $user_name esiste già!"
  exit 1
fi

# Controllo la risposta dell'utente 
while [[ ! "$answer" =~ ^[YyNn]$ ]]; do
    echo "Vuoi creare un gruppo per l'utente $user_name? (y/n): "
    read -r answer
done

# Ora puoi fare qualcosa con la risposta
if [[ "$answer" =~ ^[Yy]$ ]]; then
    echo "OK! Verrà creato un gruppo per l'utente $user_name"

    while [ -z "$group_name" ]; do
      echo "Inserisci il nome del gruppo: "
      read -r group_name

      if [ -z "$group_name" ]; then
        echo "La stringa inserita è vuota. Per favore, inserisci una stringa valida."
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
      echo "ERRORE! Il gruppo $group_name esiste già! L'utente $user_name verrà ora inserito nel gruppo $group_name"
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



# Legge i titoli e i paragrafi da dei file esterni
readarray -t TITLES < titles.txt
readarray -t PARAGRAPHS < paragraphs.txt

# Funzione che genera un nome casuale di una cartella
gen_folder_name() {
  local words=(
    Documenti Immagini Progetti Download Musica Video Backup Appunti Presentazioni Archivi
    Risorse Applicazioni Foto Lavori Manuali Progetti_Personali Pubblicazioni Sviluppo_Personale
    Finanze Personale_2023 Viaggi Tecnologia Creativita Apprendimento Lavoro Progetti_Futuri
    Salute Fitness Ricette Design Arte Cultura Vacanze Sogni Libri Scrittura
    Famiglia Amici Sostenibilita Innovazione Risparmio Ricerca Progetto_Web Viaggio_Spaziale
    Programmazione Podcast Film_Serie_Storiche Obiettivi Educazione Divertimento Risoluzione_Problemi
    Risorse_Umane Carriera Scienza Natura Esplorazione_Territoriale Innovazione_Tecnologica
    Studio Hobby Creativita_Tecnologica Fotografia Social_Media Archivio_Documenti
    Progetti_Aziendali Finanze_Personali Fitness_Benessere Cucina_Artistica Viaggi_Avventura 
    Cultura_Moderna Sogni_Ambiziosi Letture_Appassionanti Famiglia_Condivisione
    Ecologia_Innovativa Sviluppo_Personale_Avanzato Risoluzione_Problemi_Efficienti
    Obiettivi_Professionali Podcast_Creativi Serie_TV_Scientifiche Educazione_Continua
    Divertimento_Sano Gestione_Tempo Risorse_Umane_Efficaci Carriera_Professionale
    Scienza_Avanzata Natura_Esplorativa Esplorazione_Spaziale Tecnologia_Sostenibile
    Cinema Miei_Documenti Arte_Digitale Fotografia_Creativa Progetti_Sociali
    Imparare_Programmazione Apprendimento_Linguistico Risparmio_Energia Viaggi_Culinarie
    Sviluppo_Apps Fitness_Spirituale Sogno_Artistico Innovazione_Sociale
    Studiare_Natura Creazioni_Manuali Progetti_Futuristici Innovazione_Ambientale
    Carriera_Creativa Podcast_Culturali Serie_TV_Avventurose Risoluzione_Problemi_Ecologici
    Sostenibilita_Energetica Ricette_Creative Letture_Inspiranti Scrittura_Creativa
    Famiglia_Felice Amici_Avventurosi Viaggi_Educativi Sogno_Tecnologico
    Programmazione_Creativa Podcast_Educativi Film_Documentari Educazione_Scientifica
    Sviluppo_Personale_Sostenibile Risorse_Umane_Innovative Carriera_Ambiziosa
    Scienza_Avanzata_Espansiva Esplorazione_Naturale Tecnologia_Progressiva
  )
  local index=$((RANDOM % ${#words[@]}))
  echo "${words[$index]}"
}

# Funzione che genera un nome casuale di un file
gen_file_name() {
  local prefixes=(
    documento foto progetto canzone video backup appunti presentazione archivio relazione immagine
    codice rapporto brano film script tesi budget idee_spunti spese_2023 nota_diario presentazione_quarterly ricette_itinerario
    codice_sorgente progetto_website costi_viaggio playlist_mood progetto_app idee_design progetto_libro documento_finanziario
    lista_spese_itinerario ricerca_progetto_arte articolo_blog video_tutorial video_blogging idea_apprendimento lista_creativita
    progetto_scienza ricetta_cucina itinerario_vacanza codice_promozionale investimenti_borsa immagini_prodotto progetto_fotografia
    archivio_familiare documentazione_progetto progetto_manifattura 
    scrittura_narrativa presentazione_prodotto analisi_dati presentazione_finale 
    intervista riepilogo_mensile grafico_finanziario programma_vacanze analisi_trend 
    programmazione_web studio_fotografico lista_spesa_itinerario ricerca_arte_storia 
    documento_fiscale foto_ricordo progetto_innovativo canzone_rilassante video_tutorial backup_importante appunti_importanti 
    presentazione_cliente archivio_progetti relazione_finale immagine_diagramma
    codice_sicurezza rapporto_annuale brano_inedito film_sci-fi script_avanzato tesi_sperimentale 
    budget_mensile idee_creative spese_mensili_2023 nota_diario_personale presentazione_trimestrale 
    ricette_squisite_itinerario codice_sorgente_avanzato progetto_web_design costi_viaggio_affari playlist_energizzante
    progetto_app_mobile idee_interior_design progetto_romanzo documento_contabile 
    lista_spese_vacanza ricerca_storia_arte articolo_blog_interessante video_tutorial_fotografia 
    idea_apprendimento_personale lista_creativita_2023 progetto_scienza_esplorativa ricetta_cucina_sana 
    itinerario_vacanza_relax codice_promozionale_investimenti immagini_prodotto_ecologico progetto_fotografia_naturale
    archivio_familiare_foto documentazione_progetto_importante progetto_manifattura_avanzato
    scrittura_narrativa_avanzata presentazione_prodotto_nuovo analisi_dati_mensili 
    presentazione_finale_approfondita intervista_professionale riepilogo_mensile_finanziario 
    grafico_finanziario_dettagliato programma_vacanze_avventuroso analisi_trend_di_mercato
    programmazione_web_avanzata studio_fotografico_professionale 
    lista_spesa_itinerario_viaggio ricerca_arte_storia_creativa
  )

  local suffixes=(.txt) # è possibile aggiungere anche più suffissi qui
  local prefix_index=$((RANDOM % ${#prefixes[@]}))
  local suffix_index=$((RANDOM % ${#suffixes[@]}))
  echo "${prefixes[$prefix_index]}${suffixes[$suffix_index]}"
}

# Funzione che genera il contenuto casuale di un file .md con più titoli
gen_md_file_content() {

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
      local file_content=$(gen_md_file_content) # Il contenuto del file da creare
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



# Riempimento della cartella dell'utente
echo "Riempimento della cartella dell'utente $user_name... Attendere..."
#mkdir "$user_dir"

user_dir="/home/$user_name/Desktop"
# Creazione della gerarchia di file verosimile
gen_file_hierarchy "$user_dir" $max_depth $max_files $max_folders 1

# Elimina i file .txt generati
find "$user_dir" -type f -name "*.txt" -delete
#chown $user_name $user_dir


echo "Fatto!"

if $populate_group_dir; then
  # Creazione della cartella del gruppo
  echo "Creazione e riempimento della cartella del gruppo $group_name... Attendere..."
  mkdir "$group_dir"

  # Creazione della gerarchia di file verosimile
  gen_file_hierarchy "$group_dir" $max_depth $max_files $max_folders 1

  # Elimina i file .txt generati
  find "$group_dir" -type f -name "*.txt" -delete

  chown $user_name:$group_name $group_dir

  echo "Fatto!"
fi


