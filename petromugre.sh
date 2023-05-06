#!/bin/bash

# Definir la ruta del archivo JSON
config_file="/root/udp/config.json"

# Función para agregar una contraseña
function add_password() {
  # Leer las nuevas contraseñas desde el usuario
  echo -e "\e[32mIngrese las nuevas contraseñas separadas por comas: \e[0m"
  read new_passwords

  # Convertir las contraseñas a un array
  IFS=',' read -ra passwords_arr <<< "$new_passwords"

  # Leer las contraseñas existentes desde el archivo JSON
  existing_passwords=$(jq -r '.auth.pass | join(",")' "$config_file")

  # Concatenar las contraseñas existentes con las nuevas
  updated_passwords="$existing_passwords,${passwords_arr[@]}"

  # Actualizar el archivo JSON con las nuevas contraseñas
  jq ".auth.pass = [\"$(echo $updated_passwords | sed 's/,/", "/g')\"]" "$config_file" > tmp.json && mv tmp.json "$config_file"

  # Confirmar que se actualizaron las contraseñas correctamente
  if [ "$?" -eq 0 ]; then
    echo -e "\e[32mContraseñas actualizadas correctamente.\e[0m"
  else
    echo -e "\e[31mNo se pudo actualizar las contraseñas.\e[0m"
  fi

  # Recargar el daemon de systemd y reiniciar el servicio
  sudo systemctl daemon-reload
  sudo systemctl restart udp-custom
}

# Función para eliminar una contraseña
function delete_password() {
  # Leer las contraseñas existentes desde el archivo JSON
  existing_passwords=$(jq -r '.auth.pass | join(",")' "$config_file")

  # Leer la contraseña que se quiere eliminar desde el usuario
  echo -e "\e[32mIngrese la contraseña que desea eliminar: \e[0m"
  read password_to_delete

  # Eliminar la contraseña del array de contraseñas
  updated_passwords=$(echo "$existing_passwords" | sed "s/$password_to_delete//g;s/,,/,/g;s/^,//;s/,$//")

  # Actualizar el archivo JSON con las nuevas contraseñas
  jq ".auth.pass = [\"$(echo $updated_passwords | sed 's/,/", "/g')\"]" "$config_file" > tmp.json && mv tmp.json "$config_file"

  # Confirmar que se eliminó la contraseña correctamente
  if [ "$?" -eq 0 ]; then
    echo -e "\e[32mContraseña eliminada correctamente.\e[0m"
  else
    echo -e "\e[31mNo se pudo eliminar la contraseña.\e[0m"
  fi

  # Recargar el daemon de systemd y reiniciar el servicio
  sudo systemctl daemon-reload
  sudo systemctl restart udp-custom
}

# Loop para mostrar el menú de opciones
while true; do
  echo -e "\e[34mSeleccione una opción:\e[0m"
  echo -e "\e[32m1. Agregar una contraseña\e[0m"
  echo -e "\e[32m2. Eliminar una contraseña\e[0m"
  echo -e "\e[32m3. Salir\e[0m"

  # Leer la opción seleccionada desde el usuario
  read option

  # Evaluar la opción seleccionada
case $option in
  1) add_password;;
  2) delete_password;;
  3) break;;
  *) echo -e "\e[31mOpción inválida. Inténtelo de nuevo.\e[0m";;
  esac
done
