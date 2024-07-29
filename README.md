script para apagar el wifi en un dispositivo.


# Instalación 
```
git clone https://github.com/elchaka0/apagar-wifi
cd apagar-wifi
chmod +x apagar-wifi.sh
```

# Ejecución
```
./apagar-wifi.sh
```
# Requisitos
- Sistema Operativo: **Linux**
- **Aircrack-ng**: El script utiliza airodump-ng y aireplay-ng, que forman parte del paquete Aircrack-ng. Debes instalar este paquete para el escaneo y la desautenticación de redes Wi-Fi.
- **wpa_supplicant**: Se usa para manejar las conexiones Wi-Fi.
- **iw**: Se utiliza para gestionar la interfaz de red Wi-Fi. Puedes instalarlo con:

**Aircrack-ng** no viene instalado por defecto asi que lo vas a tener que instalar con:
```
sudo apt-get install aircrack-ng
```
**wpa_supplicant** y **iw** por lo general vienen instaldas, 
para ver si estan instalada ejecuta:
```
which aireplay-ng
which iw
```
Si no estan instaladas puedes instalarlas con:
```
sudo apt-get install iw
sudo apt-get install wpasupplicant
```
Para instalar todo junto: 
  ```
  sudo apt-get install aircrack-ng
  sudo apt-get install iw
  sudo apt-get install wpasupplicant
```

# Atajos de teclado
- <kbd>Ctrl</kbd> + <kbd>c</kbd> : te va a salir la opcion de parar o seguir a la siguiente etapa
- run                            : ejecuta el script
- --help                         : muestra los comandos

# Etapas
1. Muestra todas las redes wifi de tu alrededor.
2. mustra los dispositivos de una red wifi en especifico.
3. apagar la red wifi de un dispositivo

# Créditos
- Autor: elchaka0
