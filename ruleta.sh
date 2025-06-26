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
ctrl_C () {
  echo -e "\n\n${redColour}[!] Saliendo...${endColour}\n"
  exit 1
}

trap ctrl_C INT

helpPanel ()
{
  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Uso:${endColour} ${purpleColour}./ruleta.sh${endColour}\n"
  echo -e "\t${purpleColour}-m)${endColour} ${grayColour}Cantidad de dinero con el que se desea jugar${endColour}"
  echo -e "\t${purpleColour}-t)${endColour} ${grayColour}Técnica a utilizar${endColour} ${purpleColour}(${endColour}${blueColour}m:${endColour} ${grayColour}martingala${endColour}${greenColour}/${endColour}${blueColour}i:${endColour} ${grayColour}inverseLabrouchere${endColour}${purpleColour})${endColour}"
  echo -e "\t${purpleColour}-h)${endColour} ${grayColour}Panel de ayuda${endColour}"
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
    martingala
  else
    echo -e "${redColour}[!] La técnica proporcionada no existe"
    helpPanel
  fi
else
  helpPanel
fi
