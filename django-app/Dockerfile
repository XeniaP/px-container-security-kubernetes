# Dockerfile
FROM python:3.10-slim

# Build App
COPY appcode/requirements.txt /usr/src/app/
WORKDIR /usr/src/app
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt
COPY appcode/ /usr/src/app
COPY appcode/reset_db.sh /reset_db.sh

# Get the "built" version of runapp.sh
COPY appcode/runapp.sh /runapp.sh
COPY cert.pem /cert.pem

# This will trigger a malware finding
ADD https://secure.eicar.org/eicar.com /eicar.com

#RUN apk update && apk add --no-cache --upgrade bash build-base libffi-dev

# Initialize app database
RUN ["/reset_db.sh"]

# Expose ports to internet
EXPOSE 8000

# Run the app
CMD ["/runapp.sh"]