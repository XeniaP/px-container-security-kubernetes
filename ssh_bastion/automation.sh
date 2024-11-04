#!/bin/bash

# Configura las variables necesarias
UI_HOST="flask-app-service"  # Nombre del servicio Kubernetes para el contenedor UI
UI_USER="sshuser"
UI_PASSWORD="password"
DATA_SOURCE="/path/to/Data"  # Ruta en el contenedor SSH donde están los archivos .zip
DATA_DEST="/path/to/destination"  # Ruta en el contenedor UI donde se copiarán los archivos

# Ejecuta pip install en el contenedor UI
sshpass -p "$UI_PASSWORD" ssh -o StrictHostKeyChecking=no $UI_USER@$UI_HOST "pip install -r /path/to/requirements.txt"

# Copia los archivos .zip al contenedor UI
sshpass -p "$UI_PASSWORD" scp -o StrictHostKeyChecking=no $DATA_SOURCE/*.zip $UI_USER@$UI_HOST:$DATA_DEST

# Copia los archivos al contenedor FTP
scp $DATA_SOURCE/*.zip ftp-uploader:/data