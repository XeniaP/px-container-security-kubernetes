#!/bin/bash

# Variables de configuración FTP
FTP_HOST="ftp.example.com"
FTP_USER="ftp_user"
FTP_PASSWORD="ftp_password"
FTP_DIR="/path/on/ftp"

# Directorio donde se encuentran los archivos
FILES_DIR="/data"

# Enviar archivos al servidor FTP usando lftp
lftp -f "
open ftp://$FTP_USER:$FTP_PASSWORD@$FTP_HOST
lcd $FILES_DIR
cd $FTP_DIR
mput *.zip
bye
"
