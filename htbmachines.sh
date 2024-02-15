#!/bin/bash

#Colours
greenColour="\e[0;32m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m"
blueColour="\e[0;34m"
yellowColour="\e[0;33m"
purpleColour="\e[0;35m"
turquoiseColour="\e[0;36m"
grayColour="\e[0;37m\033[1m"

function ctrl_c()
{
  echo -e "\n\n${redColour}  Interrumped execution${endColour}\n"
  exit 1
}

# Ctrl+c
trap ctrl_c INT

main_url="https://htbmachines.github.io/bundle.js" 

function helpPanel()
{
  echo -e "\n${yellowColour} ${endColour} ${grayColour}Help${endColour}"  
  echo -e "\t-m\tSearch for a machine by name." 
  echo -e "\t\t${grayColour}Note${endColour}: This argument is case-sensitive."
  echo -e "\t-d\tSearch machines by difficulty level. [easy|medium|hard|insane]."
  echo -e "\t-u\tDownload or update available files."
  echo -e "\t-h\tShow this help panel.\n"
}

function searchMachine()
{
  machineName="$1"
  machine="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE 'id:|sku:|resuelta:' | tr -d '"' | tr -d ',' | tr -s ' *')"
  if [[ ! "$machine" ]]; then
    echo -e "\n${redColour}󰗖 ${endColour} HTB machine with name ${purpleColour}${machineName}${endColour} not found.\n"
  else
    echo -e "\n$machine\n"
  fi
}

function searchMachinesByDifficulty()
{
  difficulty=""
  if [[ "$1" == "easy" ]]; then
    difficulty="Fácil"
  elif [[ "$1" == "medium" ]]; then
    difficulty="Media"
  elif [[ "$1" == "hard" ]]; then
    difficulty="Difícil"
  elif [[ "$1" == "insane" ]]; then
    difficulty="Insane"
  else
    echo -e "\n${redColour}󰗖 ${endColour} This level of difficulty doesn’t exist. Use -h for help\n"
    exit 1
  fi
  echo -e "\n${purpleColour}$(echo ${1^})${endColour} difficulty level machines:\n"
  cat /opt/htbmachines/bundle.js | grep -B 5 "dificultad: \"$difficulty\"" | grep "name:" | tr -d '"' | tr -d ',' | awk 'NF{print $NF}' | column
  echo -e "\n"
}

function updateFiles()
{
  if [ ! -f /opt/htbmachines/bundle.js ]; then
    echo -e "\n${blueColour}󰭽 ${endColour} Downloading files...\n" 
    curl -s $main_url > /opt/htbmachines/bundle.js
    js-beautify /opt/htbmachines/bundle.js | sponge /opt/htbmachines/bundle.js
    echo -e "${greenColour}󱋌 ${endColour} Download finished.\n"
  else 
    echo -e "\n${purpleColour}󰢪 ${endColour} Checking updates..." 
    curl -s $main_url > /opt/htbmachines/tmp_bundle.js
    js-beautify /opt/htbmachines/tmp_bundle.js | sponge /opt/htbmachines/tmp_bundle.js

    bundle="$(md5sum /opt/htbmachines/bundle.js | awk '{print $1}')"
    tmp_bundle="$(md5sum /opt/htbmachines/tmp_bundle.js | awk '{print $1}')" 

    if [[ "$bundle" != "$tmp_bundle" ]]; then
      rm /opt/htbmachines/bundle.js && mv /opt/htbmachines/tmp_bundle.js /opt/htbmachines/bundle.js
      echo -e "\n${greenColour}󰄴 ${endColour} The files have been upgraded.\n"
    else
      echo -e "\n${greenColour}󰄴 ${endColour} There are no updates available.\n"
      if [ -f /opt/htbmachines/tmp_bundle.js ]; then
        rm /opt/htbmachines/tmp_bundle.js 
      fi
    fi
  fi
}

declare -i counter=0

while getopts "m:d:uh" arg; do
  case $arg in
    m) machineName="$OPTARG"; let counter+=1;;
    u) let counter+=2;;
    d) difficulty="$OPTARG"; let counter+=3;;
    h);;
  esac
done

if [ $counter -eq 1 ]; then
 searchMachine $machineName
elif [ $counter -eq 2 ]; then
  updateFiles
elif [ $counter -eq 3 ]; then
  searchMachinesByDifficulty $difficulty
else
  helpPanel
fi
