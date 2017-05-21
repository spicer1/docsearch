#!/bin/bash
# docsearch.sh necessita dei seguenti pacchetti per funzionare correttamente
# sudo apt install catdoc docx2txt odt2txt  python-pdfminer
#
# catdoc converte .doc into testo
# docx2txt converte .docx into testo
# odt2txt converte .odt and .sxw into testo
# python-pdfminer contine l'eseguibile pdf2txt che converte pdf in testo
command -v catdoc >/dev/null 2>&1 || { echo >&2 "Per una corretta esecuzione occore che il programma catdoc sia installato."; exit 1; }
command -v docx2txt >/dev/null 2>&1 || { echo >&2 "Per una corretta esecuzione occore che il programma docx2txt sia installato."; exit 1; }
command -v odt2txt >/dev/null 2>&1 || { echo >&2 "Per una corretta esecuzione occore che il programma odt2txt sia installato."; exit 1; }
command -v pdf2txt >/dev/null 2>&1 || { echo >&2 "Per una corretta esecuzione occore che il programma pdf2txt del pacchetto python-pdfminer sia installato."; exit 1; }

PROG_NAME="$(basename "$0")"
function usage
{
cat <<ENDHELP
NAME
       ${PROG_NAME} - ricerca le parole indicate all'interno di documenti .doc .docx .odt .sxw .pdf 

SYNOPSIS
       ${PROG_NAME} [parole-da-cercare]
       ${PROG_NAME}

DESCRIPTION
       Ricerca delle parole all'interno di documenti .doc .docx .odt .sxw .pdf 
       nella directory corrente e in tutte le sottodirectory
       
       Le parole-da-cercare, se non sono indicate nella riga di comando, verrano richieste dopo aver
       invocato il comando.
       
       Le parole devono essere separate da un solo spazio oppure dal carattere |

       -h
           Stampa questo messaggio
	   
	per verificare il corretto funzionamento del programma entrare nella directory docsearch.test.files 
	e digitare il comando
	    ${PROG_NAME} doc

ENDHELP
}
if [ $# -eq 1 ] && [ $1 == '-h' ]; then
	usage
	exit
fi


if [ $# -eq 0 ]; then 
	echo -e "
	${PROG_NAME} ricerca delle parole all'interno di documenti .doc .docx .odt .sxw .pdf
        nella directory corrente e in tutte le sottodirectory.\n
	${PROG_NAME} -h stampa un messaggio di aiuto\n
	digita le parole che desideri ricarcare e premi invio\n"
	read response
else 
	response="${@:1}"
	echo "search word[s]: $response"
fi
# replace all blanks
response=${response// /|}
echo $response

find . -name  "*.doc"  2> /dev/null | while read i; do catdoc "$i" 2> /dev/null | grep --color=auto -iEH --label="$i" "$response"; done
find . -name "*.docx"  2> /dev/null | while read i; do docx2txt "$i" - 2> /dev/null | grep --color=auto -iEH --label="$i" "$response"; done
find . -name "*.odt"  2> /dev/null | while read i; do odt2txt "$i"  2> /dev/null | grep --color=auto -iEH --label="$i" "$response"; done
find . -name "*.sxw"  2> /dev/null | while read i; do odt2txt "$i"  2> /dev/null | grep --color=auto -iEH --label="$i" "$response"; done
find . -name "*.pdf"  2> /dev/null | while read i; do pdf2txt "$i"  2> /dev/null | grep --color=auto -iEH --label="$i" "$response"; done

