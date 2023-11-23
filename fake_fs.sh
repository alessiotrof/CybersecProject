#!/bin/bash

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
  )
  local suffixes=(.txt .docx .pdf .pptx .xlsx .odt .rtf .doc .ppt .xls)
  local prefix_index=$((RANDOM % ${#prefixes[@]}))
  local suffix_index=$((RANDOM % ${#suffixes[@]}))
  echo "${prefixes[$prefix_index]}${suffixes[$suffix_index]}"
}

# Funzione che genera un contenuto casuale di un file
gen_file_content() {
  local sentences=("Questo è un file di prova." "Non contiene informazioni importanti." "Può essere cancellato senza problemi." "È stato generato automaticamente da uno script bash." "Serve solo per simulare una gerarchia di file verosimile." "Non ha alcun valore pratico o didattico." "Non è necessario leggerlo o modificarlo." "È solo un esempio di come creare dei file con dei nomi plausibili.")
  local num_sentences=$((RANDOM % 5 + 1))
  local content=""
  for ((i=0; i<$num_sentences; i++)); do
    local sentence_index=$((RANDOM % ${#sentences[@]}))
    content+="${sentences[$sentence_index]} "
  done
  echo "$content"
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
      echo "$file_content" > "$root_dir/$file_name" # Creazione del file
    done
    for ((i=0; i<$num_folders; i++)); do
      local folder_name=$(gen_folder_name) # Il nome della sottocartella da creare
      mkdir "$root_dir/$folder_name" # Creazione della sottocartella
      gen_file_hierarchy "$root_dir/$folder_name" $max_depth $max_files $max_folders $((depth + 1)) # Chiamata ricorsiva per creare la gerarchia nella sottocartella
    done
  fi
}

# Parametri dello script
root_dir="fake_fs" # La cartella radice da cui partire
max_depth=10 # La profondità massima della gerarchia
max_files=10 # Il numero massimo di file per cartella
max_folders=5 # Il numero massimo di sottocartelle per cartella

# Creazione della cartella radice
mkdir "$root_dir"

# Creazione della gerarchia di file verosimile
gen_file_hierarchy "$root_dir" $max_depth $max_files $max_folders 1
