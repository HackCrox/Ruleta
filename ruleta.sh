#!/bin/bash

#Colors
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

# ctrl_C
ctrl_C () 
{
  echo -e "\n\n${redColour}[!] Saliendo...${endColour}\n"
  tput cnorm && exit 1
}

trap ctrl_C INT

# Panel de ayuda
helpPanel () {
  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Uso:${endColour} ${purpleColour}./ruleta.sh${endColour}\n"
  echo -e "\t${purpleColour}-m)${endColour} ${grayColour}Cantidad de dinero con el que se desea jugar${endColour}"
  echo -e "\t${purpleColour}-t)${endColour} ${grayColour}Técnica a utilizar${endColour} ${purpleColour}(${endColour}${blueColour}m:${endColour} ${grayColour}martingala${endColour}${greenColour}/${endColour}${blueColour}i:${endColour} ${grayColour}inverseLabrouchere${endColour}${purpleColour})${endColour}"
  echo -e "\t${purpleColour}-h)${endColour} ${grayColour}Panel de ayuda${endColour}\n"
}

# Utilidades
ruleta () {
  random_number="$((RANDOM % 37))"
  echo "$random_number"
}

datos_apuesta() {
  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Dinero actual:${endColour} ${yellowColour}\$${money}${endColour}"
  
  if [ "$technique" == "m" ]; then
   echo -ne "${yellowColour}[+]${endColour} ${grayColour}Cuanto dinero deseas apostar? -> ${endColour}" && read initial_bet
  fi
}

parImpar () {
  while true; do
    echo -ne "${yellowColour}[+]${endColour} ${grayColour}A que quieres apostar continuamente (par/impar)? -> ${endColour}" && read par_impar
    par_impar=$(echo "$par_impar" | tr '[:upper:]' '[:lower:]')

    if [ "$par_impar" == "par" ] || [ "$par_impar" == "impar" ]; then
      break 
    else
      echo -e "${redColour}[!] Opción no válida, selecciona (par/impar)${endColour}\n"
    fi
  done
}

estadisticas() {
  perdida=$(($money_backup - $gananciaMaxima))

  sleep 3

  echo -e "${yellowColour}[+]${endColour} ${grayColour}La siguiente apuesta es de $initial_bet, tu saldo actual es de \$$money${endColour}"

  echo -e "${redColour}[!] Te haz quedado sin dinero para la siguiente apuesta\n"

  echo -e "${yellowColour}[+]${endColour} ${grayColour}Numero de vueltas: ${blueColour}$vueltas${endColour}"
  echo -e "${yellowColour}[+]${endColour} ${grayColour}Numero de vueltas ganadas: ${greenColour}$vueltasGanadas${endColour}"
  echo -e "${yellowColour}[+]${endColour} ${grayColour}Numero de vueltas perdidas: ${redColour}$vueltasPerdidas${endColour}\n"

  echo -e "${yellowColour}[+]${endColour} ${grayColour}Número de vueltas ganadas seguidas: ${greenColour}$mejorRacha${endColour}"
  echo -e "${yellowColour}[+]${endColour} ${grayColour}Serie de números de vueltas ganadas seguidas: ${greenColour}$serieMaximaGanadas${endColour}"
  echo -e "${yellowColour}[+]${endColour} ${grayColour}Ganancia máxima: ${greenColour}\$$(($gananciaMaxima - $money_backup))${endColour}"
  echo -e "${yellowColour}[+]${endColour} ${grayColour}Ganancia total: ${greenColour}\$$gananciaMaxima${endColour}\n"
  
  echo -e "${yellowColour}[+]${endColour} ${grayColour}Número de vueltas perdidas seguidas: ${redColour}$peorRacha${endColour}"
  echo -e "${yellowColour}[+]${endColour} ${grayColour}Serie de números de vueltas perdidas seguidas: ${redColour}$serieMaximaPerdidas${endColour}"
  echo -e "${yellowColour}[+]${endColour} ${grayColour}Pérdida en la última apuesta: ${redColour}\$$ultimaPerdida ${endColour}"
  echo -e "${yellowColour}[+]${endColour} ${grayColour}Perdida real: ${redColour}\$$perdida ${endColour}"
  echo -e "${yellowColour}[+]${endColour} ${grayColour}Perdida desde el pico: ${redColour}\$-$gananciaMaxima ${endColour}\n"

  echo -e "${blueColour}[+]${endColour} Saldo final: ${yellowColour}\$$money${endColour}\n"
}

# Tecnicas
tecnicaMartingala () {
  datos_apuesta
  parImpar

  initial_bet_backup=$initial_bet
  money_backup=$money
  # Estadisticas
  # Ganas
  declare -i vueltas=0
  declare -i vueltasGanadas=0
  declare -i mejorRacha=0
  declare -i rachaActualGanadas=0
  declare -i gananciaActual=0
  declare -i gananciaMaxima=0
  serieActualGanadas=""
  serieMaximaGanadas=""
  # Pierdes
  declare -i vueltasPerdidas=0
  declare -i peorRacha=0
  declare -i ultimaPerdida=0
  serieActualPerdidas=""
  serieMaximaPerdidas=""

  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Vamos a jugar con la cantidad inicial de ${yellowColour}\$${initial_bet}${endColour} ${grayColour}a${endColour} ${blueColour}$par_impar${endColour}\n"
  
  tput civis
  
  serieActualPerdidas=""
  serieMaximaPerdidas=""

  case "$par_impar" in
    par)
      while [[ "$money" -gt 0 ]]; do
        declare -i vueltas+=1
        numero=$(ruleta)
        # Pierdes

        ultimaPerdida=initial_bet

        if [ "$numero" -eq 0 ]; then
          #echo "$numero"
          serieActualGanadas=""
          rachaActualGanadas=0

          money=$(($money - initial_bet ))
          #echo -e "${yellowColour}[+]${endColour} ${grayColour} Acabas de apostar${endColour} ${yellowColour}\$$initial_bet ${endColour} ${grayColour}ahora tienes la cantida de${endColour} ${yellowColour}\$$money${endColour}"
          initial_bet=$(($initial_bet * 2))
          #echo -e "${redColour}[!] Ha salido 0 perdiste, ahora tienes \$${money}${endColour}\n"
          
          vueltasPerdidas+=1
          peorRacha+=1
          serieActualPerdidas+="$numero "
          count1=$(echo "$serieActualPerdidas" | wc -w)
          count2=$(echo "$serieMaximaPerdidas" | wc -w)
          
          if [[ "$count1" -gt "$count2" ]]; then
              serieMaximaPerdidas=$serieActualPerdidas
          fi

         # Ganas
        else
          if [ "$(($numero % 2))" -eq 0 ]; then
            serieActualPerdidas=""
            peorRacha=0

           # echo "$numero"
            money=$(($money - $initial_bet))
            #echo -e "${yellowColour}[+]${endColour} ${grayColour} Acabas de apostar${endColour} ${yellowColour}\$$initial_bet ${endColour} ${grayColour}ahora tienes la cantida de${endColour} ${yellowColour}\$$money${endColour}"

            reward=$(($initial_bet * 2))
            money=$(($money + $reward))
            #echo -e "${greenColour}[+] Es par, ganaste la cantidad de \$$reward  ahora tienes \$${money}${endColour}\n" 
            
            initial_bet=$initial_bet_backup
            vueltasGanadas+=1
            rachaActualGanadas+=1
            gananciaActual=$money
            serieActualGanadas+="$numero "
            count1=$(echo "$serieActualGanadas" | wc -w)
            count2=$(echo "$serieMaximaGanadas" | wc -w)

            if [[ "$gananciaActual" -gt "$gananciaMaxima" ]]; then
              gananciaMaxima=$gananciaActual
            fi

            if [ "$rachaActualGanadas" -gt "$mejorRacha" ]; then
              mejorRacha=$rachaActualGanadas
            fi
            
            if [[ "$count1" -gt "$count2" ]]; then
                serieMaximaGanadas=$serieActualGanadas
            fi

          # Pierdes
          else
            ultimaPerdida=initial_bet
            #echo "$numero"
            rachaActualGanadas=0
            serieActualGanadas=""
            money=$(($money - $initial_bet))
            #echo -e "${yellowColour}[+]${endColour} ${grayColour} Acabas de apostar${endColour} ${yellowColour}\$$initial_bet ${endColour} ${grayColour}ahora tienes la cantida de${endColour} ${yellowColour}\$${money}${endColour}"
            initial_bet=$(($initial_bet * 2))
            vueltasPerdidas+=1
            peorRacha+=1
            #echo -e "${redColour}[!] Ha salido impar perdiste, ahora tienes \$${money}${endColour}\n"
            serieActualPerdidas+="$numero "
            count1=$(echo "$serieActualPerdidas" | wc -w)
            count2=$(echo "$serieMaximaPerdidas" | wc -w)
            
            if [[ "$count1" -gt "$count2" ]]; then
                serieMaximaPerdidas=$serieActualPerdidas
            fi
            
          fi
        fi
      done
      estadisticas
    ;;
    impar)
      while [[ "$money" -gt 0 ]]; do
        #if [[ "$initial_bet" -gt "$money" ]]; then
         # break 
        #fi

        declare -i vueltas+=1
        numero=$(ruleta)

        ultimaPerdida=initial_bet

        if [ "$numero" -eq 0 ]; then
          serieActualGanadas=""
          rachaActualGanadas=0

          money=$(($money - initial_bet ))
          #echo -e "${yellowColour}[+]${endColour} ${grayColour} Acabas de apostar${endColour} ${yellowColour}\$$initial_bet ${endColour} ${grayColour}ahora tienes la cantida de${endColour} ${yellowColour}\$$money${endColour}"
          initial_bet=$(($initial_bet * 2))
          #echo -e "${redColour}[!] Ha salido 0 perdiste, ahora tienes \$${money}${endColour}\n"
          
          vueltasPerdidas+=1
          peorRacha+=1
          serieActualPerdidas+="$numero "
          count1=$(echo "$serieActualPerdidas" | wc -w)
          count2=$(echo "$serieMaximaPerdidas" | wc -w)
          
          if [[ "$count1" -gt "$count2" ]]; then
              serieMaximaPerdidas=$serieActualPerdidas
          fi

        else
          if [ "$(($numero % 2))" -eq 1 ]; then
            serieActualPerdidas=""
            peorRacha=0

            money=$(($money - $initial_bet))
           # echo -e "${yellowColour}[+]${endColour} ${grayColour} Acabas de apostar${endColour} ${yellowColour}\$$initial_bet ${endColour} ${grayColour}ahora tienes la cantida de${endColour} ${yellowColour}\$$money${endColour}"

            reward=$(($initial_bet * 2))
            money=$(($money + $reward))
            #echo -e "${greenColour}[+] Es impar, ganaste la cantidad de \$$reward  ahora tienes \$${money}${endColour}\n" 
            
            initial_bet=$initial_bet_backup
            vueltasGanadas+=1
            rachaActualGanadas+=1
            gananciaActual=$money
            serieActualGanadas+="$numero "
            count1=$(echo "$serieActualGanadas" | wc -w)
            count2=$(echo "$serieMaximaGanadas" | wc -w)

            if [[ "$gananciaActual" -gt "$gananciaMaxima" ]]; then
              gananciaMaxima=$gananciaActual
            fi

            if [ "$rachaActualGanadas" -gt "$mejorRacha" ]; then
              mejorRacha=$rachaActualGanadas
            fi
            
            if [[ "$count1" -gt "$count2" ]]; then
                serieMaximaGanadas=$serieActualGanadas
            fi

          else
            ultimaPerdida=initial_bet
            rachaActualGanadas=0
            serieActualGanadas=""
            money=$(($money - $initial_bet))
            #echo -e "${yellowColour}[+]${endColour} ${grayColour} Acabas de apostar${endColour} ${yellowColour}\$$initial_bet ${endColour} ${grayColour}ahora tienes la cantida de${endColour} ${yellowColour}\$${money}${endColour}"
            initial_bet=$(($initial_bet * 2))
            vueltasPerdidas+=1
            peorRacha+=1
            #echo -e "${redColour}[!] Ha salido par perdiste, ahora tienes \$${money}${endColour}\n"
            serieActualPerdidas+="$numero "
            count1=$(echo "$serieActualPerdidas" | wc -w)
            count2=$(echo "$serieMaximaPerdidas" | wc -w)
            
            if [[ "$count1" -gt "$count2" ]]; then
                serieMaximaPerdidas=$serieActualPerdidas
            fi
          fi
        fi
      done
      estadisticas
    ;;  
  esac
  tput cnorm
}

tecnicaInverseLabrouchere() {
  datos_apuesta
  parImpar

declare -a serieNumerosBackup=(1 2 3 4)
declare -a serieNumeros=(1 2 3 4)

  case "$par_impar" in
    par)
      while true; do
        sleep 2
        numero=$(ruleta)
        # Pierdes
        if [ "$numero" -eq 0 ]; then
          bet=$((${serieNumeros[0]} + ${serieNumeros[-1]}))
          money=$(($money - $bet))
          unset serieNumeros[0]
          unset serieNumeros[-1]
          serieNumeros=(${serieNumeros[@]})

          echo "$numero"
          echo -e "${redColour}[+] Ha salido 0 perdiste${endColour}"  
          echo "[+] Acabas de apostar la cantida de $bet"
          echo "[+] Ahora tienes la cantidad de \$$money"
          echo "${serieNumeros[@]}"
          echo ""
        else
        # Ganas
          if [ "$(($numero % 2))" -eq 0 ]; then
            bet=$((${serieNumeros[0]} + ${serieNumeros[-1]}))
            serieNumeros+=($bet)
            money=$(($money - $bet))
            reward=$(($bet * 2))
            echo ""

            echo "${serieNumeros[@]}"
            echo "$numero"
            echo "[+] Acabas de apostar la cantida de $bet"
            echo "[+] Ahora tienes la cantidad de \$$money"
            echo -e "${greenColour}[+] Ha salido par ganaste${endColour}"
            money=$(($money + $reward))
            echo -e "[+] Ahora tienes la cantidad de \$$money \n"
            #echo ""

          # Pierdes
          else
            bet=$((${serieNumeros[0]} + ${serieNumeros[-1]}))
            money=$(($money - $bet))
            unset serieNumeros[0]
            unset serieNumeros[-1]
            serieNumeros=(${serieNumeros[@]})
            echo ""

            echo "$numero"
            echo -e "${redColour}[+] Ha salido impar perdiste${endColour}"
            echo "[+] Acabas de apostar la cantida de $bet"
            echo "[+] Ahora tienes la cantidad de \$$money"
            echo "${serieNumeros[@]}"
            echo ""

          fi
        fi
      done
    ;;
    impar) 
      while [[ 1 -eq 1 ]]; do
        sleep 1
        numero=$(ruleta)
        # Pierdes
        if [ "$numero" -eq 0 ]; then
          echo "$numero"
          echo "[+] Ha salido 0 perdiste"
        else
          # Pierdes
          if [ "$(($numero % 2))" -eq 0 ]; then
            echo "$numero"
            echo "[+] Ha salido par perdiste"
          # Ganas
          else
            echo "$numero"
            echo "[+] Ha salido impar ganaste"
          fi
        fi
      done
    ;; 
  esac

}

#getopts
while getopts "m:t:h" arg; do
  case "$arg" in
    m) money=$OPTARG;;
    t) technique=$OPTARG;;
    h) ;;
  esac
done

if [ $money ] && [ $technique ]; then
  if [ "$technique" == "m" ]; then
    tecnicaMartingala
  elif [ "$technique" == "i" ]; then
    tecnicaInverseLabrouchere
  else
    echo -e "${redColour}[!] La técnica proporcionada no existe"
    helpPanel
  fi
else
  helpPanel
fi