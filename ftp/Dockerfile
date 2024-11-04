# Usa una imagen base ligera como Alpine
FROM public.ecr.aws/docker/library/alpine:latest

# Instala lftp
RUN apk add --no-cache lftp bash

# Copia el script de envío al contenedor
COPY send_to_ftp.sh /usr/local/bin/send_to_ftp.sh

# Asegúrate de que el script tenga permisos de ejecución
RUN chmod +x /usr/local/bin/send_to_ftp.sh

# Directorio donde se montarán los archivos a enviar
WORKDIR /data

# Comando para ejecutar el script
CMD ["/usr/local/bin/send_to_ftp.sh"]
