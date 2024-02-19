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
  echo -e "\n\n${redColour}  Interrumped Execution${endColour}\n"
  exit 1
}

trap ctrl_c INT

function helpPanel()
{
  echo -e "\n${yellowColour}󰘥 ${endColour} ${grayColour}Help${endColour}"
  echo -e "\t-m\tWrite down how much money you want to play with."
  echo -e "\t\t${grayColour}Note${endColour}: This argument must be greater than or equal to \$50."
  echo -e "\t-t\tWrite down the technique you want to use. [martingala|inverse labrouchere]"
  echo -e "\t-h\tShow this help panel.\n"
  echo -e "\t${grayColour}Note${endColour}: You must set both arguments (-m,-t) to be able to play.\n"
}

function martingala()
{
  current_money=$money
  echo -e "\nDinero actual: \$$current_money"
  echo -ne "¿Cuanto dinero vas a apostar? >> " && read initial_bet

  declare -i even=0
  declare -i odd=0

  while [ $initial_bet -le 0 ]; do
    echo -ne "\nNo puedes apostar \$0 >> " && read initial_bet
  done

  echo -ne "¿A que vas a apostar continuamente, par o impar? >> " && read even_odd
  
  while [[ "$even_odd" != "par" && "$even_odd" != "impar" ]]; do
    echo -ne "\nSolo puedes seleccionar par o impar >> " && read even_odd
  done

  if [[ "$even_odd" == "par" ]]; then
    even=1
  else
    odd=1
  fi

  declare -i bet=$initial_bet
  let current_money-=bet
  echo -e "\nTu apuesta inicial es de ${blueColour}\$$bet${endColour} por tanto tu dinero actual es de ${greenColour}\$$current_money${endColour}\n"

  while [ $current_money -gt 0 ]; do
    rnd=$(($RANDOM % 37))
    echo -e "Número $rnd"
    if [ $(($rnd % 2)) -eq 0 ]; then
      if [ $even -eq 1 ] && [ $rnd -gt 0 ]; then
        let current_money=current_money+bet*2-initial_bet
        bet=$initial_bet
        echo -e "${greenColour}Ganaste${endColour}, apuestas ${blueColour}\$$bet${endColour}."
        echo -e "Dinero actual: ${greenColour}\$$current_money${endColour}\n"
      else
        let bet*=2
        let current_money-=bet
        if [ $current_money -ge 0 ]; then
          echo -e "${redColour}Perdiste${endColour}, aumentaste la apuesta a ${blueColour}\$$bet${endColour}."
          echo -e "Dinero actual: ${greenColour}\$$current_money${endColour}\n"
        else
          echo -e "${redColour}Perdiste${endColour}, No tienes dinero suficiente para aumentar la apuesta, ya no puedes seguir jugando.\n"
        fi
      fi
    else
      if [ $odd -eq 1 ] && [ $rnd -gt 0 ]; then
        let current_money=current_money+bet*2-initial_bet
        bet=$initial_bet
        echo -e "${greenColour}Ganaste${endColour}, apuestas ${blueColour}\$$bet${endColour}."
        echo -e "Dinero actual: ${greenColour}\$$current_money${endColour}\n"
      else
        let bet*=2
        let current_money-=bet
        if [ $current_money -ge 0 ]; then
          echo -e "${redColour}Perdiste${endColour}, aumentaste la apuesta a ${blueColour}\$$bet${endColour}."
          echo -e "Dinero actual: ${greenColour}\$$current_money${endColour}\n"
        else
          echo -e "${redColour}Perdiste${endColour}, No tienes dinero suficiente para aumentar la apuesta, ya no puedes seguir jugando.\n"
        fi
      fi
    fi
    sleep 0.4
  done
}

function inverseLabrouchere()
{
  current_money=$money
  echo -e "\nDinero actual: \$$current_money"

  declare -i even=0
  declare -i odd=0
  declare -ai initial_sequence=()
  declare -ai sequence=()

  echo -ne "¿A que vas a apostar continuamente, par o impar? >> " && read even_odd
  
  while [[ "$even_odd" != "par" && "$even_odd" != "impar" ]]; do
    echo -ne "\nSolo puedes seleccionar par o impar >> " && read even_odd
  done

  echo -ne "¿Cual sera tu secuencia?\nTu secuencia debe ir entre 2 comillas simples y separada por espacio\nEjemplo: '1 2 3 4' >> " && read input_sequence

  get_sequence=$(echo "${input_sequence}" | tr -d "'")
  for i in $get_sequence; do
    initial_sequence+=(i) 2>/dev/null
  done

  while [ "${#initial_sequence[@]}" -lt 4 ]; do
    sequence=()
    echo -ne "\nLa secuencia debe tener almenos 4 elementos >> " && read initial_sequence
    get_sequence=$(echo "${initial_sequence}" | tr -d "'")
    for i in $get_sequence; do
      initial_sequence+=(i) 2>/dev/null
    done
  done

  sequence=(${initial_sequence[@]})

  if [[ "$even_odd" == "par" ]]; then
    even=1
  else
    odd=1
  fi

  declare -i bet=$((sequence[0]+sequence[-1]))
  let current_money-=bet
  echo -e "\nTu apuesta inicial es de ${blueColour}\$$bet${endColour} por tanto tu dinero actual es de ${greenColour}\$$current_money${endColour}\n"
  
  while [ $current_money -gt 0 ]; do
    
    rnd=$(($RANDOM % 37))
    echo -e "Número $rnd"
    if [ $(($rnd % 2)) -eq 0 ]; then
      if [ $even -eq 1 ] && [ $rnd -gt 0 ]; then
        let current_money+=bet
        sequence+=(bet)
        bet=sequence[0]+sequence[-1]
        echo -e "${greenColour}Ganaste${endColour}, ahora tu secuencia es (${sequence[@]}).\nApuestas ${blueColour}\$$bet${endColour}."
        echo -e "Dinero actual: ${greenColour}\$$current_money${endColour}\n"
      else
        if [ ${#sequence[@]} -gt 2 ]; then
          unset sequence[0]
          unset sequence[-1]
          sequence=(${sequence[@]})
        else
          sequence=(${initial_sequence[@]})
        fi

        bet=sequence[0]+sequence[-1]
        let current_money-=bet
        if [ $current_money -ge 0 ]; then
          echo -e "${redColour}Perdiste${endColour}, ahora tu secuencia es (${sequence[@]}).\nApuestas ${blueColour}\$$bet${endColour}."
          echo -e "Dinero actual: ${greenColour}\$$current_money${endColour}\n"
        else
          echo -e "${redColour}Perdiste${endColour}, No tienes dinero suficiente para la apostar, ya no puedes seguir jugando.\n"
        fi
      fi
    else
      if [ $odd -eq 1 ] && [ $rnd -gt 0 ]; then
        let current_money+=bet
        sequence+=(bet)
        bet=sequence[0]+sequence[-1]
        echo -e "${greenColour}Ganaste${endColour}, ahora tu secuencia es (${sequence[@]}).\nApuestas ${blueColour}\$$bet${endColour}."
        echo -e "Dinero actual: ${greenColour}\$$current_money${endColour}\n"
      else
        if [ ${#sequence[@]} -gt 2 ]; then
          unset sequence[0]
          unset sequence[-1]
          sequence=(${sequence[@]})
        else
          sequence=(${initial_sequence[@]})
        fi

        bet=sequence[0]+sequence[-1]
        let current_money-=bet
        if [ $current_money -ge 0 ]; then
          echo -e "${redColour}Perdiste${endColour}, ahora tu secuencia es (${sequence[@]}).\nApuestas ${blueColour}\$$bet${endColour}."
          echo -e "Dinero actual: ${greenColour}\$$current_money${endColour}\n"
        else
          echo -e "${redColour}Perdiste${endColour}, No tienes dinero suficiente para la apostar, ya no puedes seguir jugando.\n"
        fi
      fi
    fi
    sleep 0.4
  done
}

declare -i money=0

while getopts "m:t:h" arg; do
  case $arg in
    m) money=$OPTARG;;
    t) technique="$OPTARG";;
    h) ;;
  esac
done

if [ $money -ge 50 ] && [[ "$technique" ]]; then
  if [[ "$technique" == "martingala" ]]; then
    martingala
  elif [[ "$technique" == "inverse labrouchere" ]]; then
    inverseLabrouchere
  else
    echo -e "\nThis technique is not yet available.\n"
  fi
else
  helpPanel
fi
