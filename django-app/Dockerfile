# Dockerfile
FROM python:2.7.13-alpine

# Build App
COPY appcode/requirements.txt /usr/src/app/
WORKDIR /usr/src/app
RUN pip install --no-cache-dir -r requirements.txt
COPY appcode/ /usr/src/app
COPY appcode/reset_db.sh /reset_db.sh

# Get the "built" version of runapp.sh
COPY appcode/runapp.sh /runapp.sh
COPY cert.pem /cert.pem

# This will trigger a malware finding
ADD https://secure.eicar.org/eicar.com /eicar.com

# Update and Dependencies Installation
RUN apk update && apk add --no-cache --upgrade bash build-base libffi-dev

# Initialize app database
RUN ["/reset_db.sh"]

# Add Cloud One Application Security
#RUN pip install trend_app_protect
#ENV TREND_AP_LOG_FILE=STDERR
#ENV TREND_AP_KEY=e50635a3-7ca1-4d2e-8d74-dd11c6d43bf3
#ENV TREND_AP_SECRET=e6b041d0-e150-4c4c-b570-e80edde40e45

# Expose ports to internet
EXPOSE 8000

# Run the app
CMD ["/runapp.sh"]