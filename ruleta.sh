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
   echo -ne "${yellowColour}[+]${endColour} ${grayColour}Cuanto dinero deseas apostar? -> ${endColour}" && read bet
  fi

  while ! [[ "$bet" =~ ^[0-9]+$ ]] || [ "$bet" -le 0 ]; do
  echo -e "${redColour}[-] Error: Debes ingresar un número entero mayor que 0.${endColour}"
   echo -ne "${yellowColour}[+]${endColour} ${grayColour}Cuanto dinero deseas apostar? -> ${endColour}" && read bet

  done
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

  echo -e "\n${blueColour}[+]${endColour} ${grayColour}La ruleta está girando...${endColour}"
}

# Estadisticas
# Varibles que almacenaran las estadisticas
variablesEstadisticas () {
  # Estadisticas
  estado=""
  # Ganas
  declare -g -i vueltas=0
  declare -g -i vueltasGanadas=0
  declare -g -i mejorRacha=0
  declare -g -i rachaActualGanadas=0
  declare -g -i gananciaActual=0
  declare -g -i gananciaMaxima=0
  serieActualGanadas=""
  serieMaximaGanadas=""
  # Pierdes
  declare -g -i vueltasPerdidas=0
  declare -g -i peorRacha=0
  declare -g -i ultimaPerdida=0
  serieActualPerdidas=""
  serieMaximaPerdidas=""
  # Reinicio de serie InverseLabrouchere
  declare -g -i reinicioSerie=0
}

condicionalesEstadisticas() {
  if [[ "$estado" == "ganas" ]]; then
    serieActualPerdidas=""
    peorRacha=0
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
    serieActualGanadas=""
    rachaActualGanadas=0
    vueltasPerdidas+=1
    peorRacha+=1
    serieActualPerdidas+="$numero "
    count1=$(echo "$serieActualPerdidas" | wc -w)
    count2=$(echo "$serieMaximaPerdidas" | wc -w)
          
    if [[ "$count1" -gt "$count2" ]]; then
      serieMaximaPerdidas=$serieActualPerdidas
    fi    
  fi 
}

estadisticas() {
  sleep 2

  perdida=$(($money + $money_backup))

  echo -e "${purpleColour}//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////"
  echo -e "\n${redColour}[!] Te has quedado sin dinero para la siguiente apuesta\n"
  echo -e "${yellowColour}[+]${endColour} ${grayColour}La siguiente apuesta es de $bet, tu saldo actual es de \$$money${endColour}"

  if [[ "$technique" == "i" ]]; then
   vueltas=$(($vueltas - 1))
  fi

  echo -e "${yellowColour}[+]${endColour} ${grayColour}Numero de vueltas: ${blueColour}$vueltas${endColour}"
  echo -e "${yellowColour}[+]${endColour} ${grayColour}Numero de vueltas ganadas: ${greenColour}$vueltasGanadas${endColour}"
  echo -e "${yellowColour}[+]${endColour} ${grayColour}Numero de vueltas perdidas: ${redColour}$vueltasPerdidas${endColour}\n"

  if [[ "$technique" == "i" ]]; then
    echo -e "${yellowColour}[+]${endColour} ${grayColour}Numero de veces que se reinicio la serie: ${purpleColour}$reinicioSerie${endColour}\n"
  fi

  echo -e "${yellowColour}[+]${endColour} ${grayColour}Número de vueltas ganadas seguidas: ${greenColour}$mejorRacha${endColour}"
  echo -e "${yellowColour}[+]${endColour} ${grayColour}Serie de números de vueltas ganadas seguidas: ${greenColour}$serieMaximaGanadas${endColour}"
  echo -e "${yellowColour}[+]${endColour} ${grayColour}Ganancia máxima: ${greenColour}\$$(($gananciaMaxima - $money_backup))${endColour}"
  echo -e "${yellowColour}[+]${endColour} ${grayColour}Saldo máximo alcanzado: ${greenColour}\$$gananciaMaxima${endColour}\n"
  
  echo -e "${yellowColour}[+]${endColour} ${grayColour}Número de vueltas perdidas seguidas: ${redColour}$peorRacha${endColour}"
  echo -e "${yellowColour}[+]${endColour} ${grayColour}Serie de números de vueltas perdidas seguidas: ${redColour}$serieMaximaPerdidas${endColour}"
  echo -e "${yellowColour}[+]${endColour} ${grayColour}Pérdida en la última apuesta: ${redColour}\$$ultimaPerdida ${endColour}"
  echo -e "${yellowColour}[+]${endColour} ${grayColour}Perdida real: ${redColour}\$$perdida ${endColour}"
  echo -e "${yellowColour}[+]${endColour} ${grayColour}Perdida desde el pico: ${redColour}\$-$gananciaMaxima ${endColour}\n"

  echo -e "${blueColour}[+]${endColour} Saldo final: ${yellowColour}\$$money${endColour}\n"
  echo -e "${purpleColour}//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////"
}

# Tecnicas
tecnicaMartingala () {
  datos_apuesta
  parImpar
  variablesEstadisticas
  # Backup
  bet_backup=$bet
  money_backup=$money

  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Vamos a jugar con la cantidad inicial de ${yellowColour}\$${bet}${endColour} ${grayColour}a${endColour} ${blueColour}$par_impar${endColour}\n"
  
  tput civis
  
  case "$par_impar" in
    par)
      while [[ "$money" -ge 0 ]]; do
        declare -i vueltas+=1
        let -g -i numero=$(ruleta)
        # Pierdes
        if [[ "$numero" -eq 0 ]] || [[ "$(($numero % 2))" -eq 1 ]]; then
          estado="pierdes"
          money=$(($money - bet ))
          # Trazas
          #echo -e "${yellowColour}[+]${endColour} ${grayColour} Acabas de apostar${endColour} ${yellowColour}\$$bet ${endColour} ${grayColour}ahora tienes la cantida de${endColour} ${yellowColour}\$$money${endColour}"
          #echo -e "${redColour}[!] Ha salido $numero perdiste, ahora tienes \$${money}${endColour}\n"
          bet=$(($bet * 2))
          condicionalesEstadisticas
        # Ganas
        else
          estado="ganas"
          money=$(($money - $bet))
          # echo -e "${yellowColour}[+]${endColour} ${grayColour} Acabas de apostar${endColour} ${yellowColour}\$$bet ${endColour} ${grayColour}ahora tienes la cantida de${endColour} ${yellowColour}\$$money${endColour}"
          #echo -e "\n$numero"
          #echo -e "${greenColour}[+] Ha salido par, ganaste la cantidad de \$$reward  ahora tienes \$${money}${endColour}\n" 
          reward=$(($bet * 2))
          money=$(($money + $reward))
          bet=$bet_backup     
          condicionalesEstadisticas
        fi
        ultimaPerdida=bet
      done
      estadisticas
    ;;
    impar)
      while [[ "$money" -gt 0 ]]; do
        declare -i vueltas+=1
        numero=$(ruleta)
        # Pierdes
        if [[ "$numero" -eq 0 ]] || [[ "$(($numero % 2))" -eq 0 ]]; then
          estado="pierdes"
          money=$(($money - bet ))
          # Trazas
          #echo -e "${yellowColour}[+]${endColour} ${grayColour} Acabas de apostar${endColour} ${yellowColour}\$$bet ${endColour} ${grayColour}ahora tienes la cantida de${endColour} ${yellowColour}\$$money${endColour}"
          #echo -e "\n$numero"
          #echo -e "${redColour}[!] Ha salido 0 ó par perdiste, ahora tienes \$${money}${endColour}\n"
          bet=$(($bet * 2))
          condicionalesEstadisticas
        # Ganas
        else
          estado="ganas"
          money=$(($money - $bet))
          # echo -e "\n$numero"
          # echo -e "${yellowColour}[+]${endColour} ${grayColour} Acabas de apostar${endColour} ${yellowColour}\$$bet ${endColour} ${grayColour}ahora tienes la cantida de${endColour} ${yellowColour}\$$money${endColour}"
          # echo -e "${greenColour}[+] Es impar, ganaste la cantidad de \$$reward  ahora tienes \$${money}${endColour}\n" 
          reward=$(($bet * 2))
          money=$(($money + $reward))
          initial_bet=$bet_backup     
          condicionalesEstadisticas
        fi
        ultimaPerdida=bet
      done
      estadisticas
    ;;  
  esac
  tput cnorm
}

tecnicaInverseLabrouchere() {
  datos_apuesta
  parImpar
  variablesEstadisticas
  # Backup
  money_backup=$money
  # Secuencia de numeros para la apuesta
  declare -a serieNumerosBackup=(1 2 3 4)
  declare -a serieNumeros=(1 2 3 4)

  tput civis
  case "$par_impar" in
    par)
      while true; do
        declare -i vueltas+=1
        ganancia=$(($money - $money_backup))

        if [[ "$money" -le 0 ]]; then
          break
        fi

        if [[ "${#serieNumeros[@]}" -eq 0 ]] || [[ "$ganancia" -ge 100 ]]; then
          #echo -e "\n${purpleColour}[+] Se ha reiniciado la secuencia${endColour}"
          serieNumeros=(${serieNumerosBackup[@]})
          reinicioSerie+=1
          #echo -e "${serieNumeros[@]}\n"
        fi
        #sleep 0.2
        let -g -i numero=$(ruleta)

        # Pierdes
        # Logica
        if [[ "$numero" -eq 0 ]] || [[ "$(($numero % 2))" -eq 1 ]]; then
          estado="pierdes"
          bet=$((${serieNumeros[0]} + ${serieNumeros[-1]}))
          money=$(($money - $bet))
          # Borrar extremos
          if [[ "${#serieNumeros[@]}" -eq 1 ]]; then
            unset serieNumeros[0]
          else
            unset serieNumeros[0]
            unset serieNumeros[-1]
          fi
          serieNumeros=(${serieNumeros[@]})
          # Trazas
          #echo -e "\n[+] Acabas de apostar la cantidad de $bet"
          #echo -e "${redColour}[+] Ha salido $numero perdiste, ahora tienes la cantidad de \$$money${endColour}"  
          #echo -e "${serieNumeros[@]}\n"
          condicionalesEstadisticas
        # Ganas
        else
          estado="ganas"
          # Logica
          bet=$((${serieNumeros[0]} + ${serieNumeros[-1]}))
          money=$(($money - $bet))
          serieNumeros+=($bet)
          reward=$(($bet * 2))
          # Trazas
          #echo -e "\n ${serieNumeros[@]}"
          #echo "[+] Acabas de apostar la cantida de $bet, ahora tienes la cantidad de \$$money"
          money=$(($money + $reward))
          #echo -e "${greenColour}[+] Ha salido $numero que es par ganaste $reward, ahora tienes la cantidad de \$$money${endColour}"
          #echo -e "[+] Ahora tienes la cantidad de \$$money \n"
          condicionalesEstadisticas
        fi
        ultimaPerdida=bet
      done
      estadisticas
    ;;
    impar) 
      while true; do
        declare -i vueltas+=1
        ganancia=$(($money - $money_backup))

        if [[ "$money" -le 0 ]]; then
          break
        fi

        if [[ "${#serieNumeros[@]}" -eq 0 ]] || [[ "$ganancia" -ge 100 ]]; then
          #echo -e "\n${purpleColour}[+] Se ha reiniciado la secuencia${endColour}"
          serieNumeros=(${serieNumerosBackup[@]})
          reinicioSerie+=1
          #echo -e "${serieNumeros[@]}\n"
        fi
        #sleep 0.2
        let -g -i numero=$(ruleta)

        # Pierdes
        # Logica
        if [[ "$numero" -eq 0 ]] || [[ "$(($numero % 2))" -eq 0 ]]; then
          estado="pierdes"
          bet=$((${serieNumeros[0]} + ${serieNumeros[-1]}))
          money=$(($money - $bet))
          # Borrar extremos
          if [[ "${#serieNumeros[@]}" -eq 1 ]]; then
            unset serieNumeros[0]
          else
            unset serieNumeros[0]
            unset serieNumeros[-1]
          fi
          serieNumeros=(${serieNumeros[@]})
          # Trazas
          #echo -e "\n[+] Acabas de apostar la cantidad de $bet"
          #echo -e "${redColour}[+] Ha salido $numero perdiste, ahora tienes la cantidad de \$$money${endColour}"  
          #echo -e "${serieNumeros[@]}\n"
          condicionalesEstadisticas
        # Ganas
        else
          estado="ganas"
          # Logica
          bet=$((${serieNumeros[0]} + ${serieNumeros[-1]}))
          money=$(($money - $bet))
          serieNumeros+=($bet)
          reward=$(($bet * 2))
          # Trazas
          #echo -e "\n ${serieNumeros[@]}"
          #echo "[+] Acabas de apostar la cantida de $bet, ahora tienes la cantidad de \$$money"
          money=$(($money + $reward))
          #echo -e "${greenColour}[+] Ha salido $numero que es impar ganaste $reward, ahora tienes la cantidad de \$$money${endColour}"
          #echo -e "[+] Ahora tienes la cantidad de \$$money \n"
          condicionalesEstadisticas
        fi
        ultimaPerdida=bet
      done
      estadisticas
    ;; 
  esac
  tput cnorm
  #estadisticas

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