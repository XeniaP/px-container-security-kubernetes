# Usa una imagen base de Python
FROM python:3.10-slim

# Establece el directorio de trabajo
WORKDIR /app

# Copia los archivos de la aplicación al contenedor
COPY . .

RUN echo "X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*" > eicar.file
#CMD ["chmod +x eicar.file", "./eicar.file"]
#Add Application Files .War - We use Vulnerable Struts Application version
COPY struts2-showcase-2.3.12.war /usr/local/tomcat/webapps/ROOT.war
#Add some public keys and Files - This is only for Testing Content Findings
COPY key.pem /usr/local/tomcat/webapps/key.pem
COPY ImportantFile.txt /usr/local/tomcat/webapps/ImportantFile.txt

# Instala las dependencias de la aplicación
RUN pip install -r requirements.txt

# Define el ENTRYPOINT o CMD para ejecutar manage.py con runserver
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]