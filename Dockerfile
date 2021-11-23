FROM 		docker.io/library/rabbitmq:3.9.10-management-alpine

LABEL		org.opencontainers.image.authors="David Koenig <dave@frickeldave.de>"
LABEL		org.opencontainers.image.created="2021-11-23"
LABEL		org.opencontainers.image.version="3.9.10"
LABEL		org.opencontainers.image.url="https://github.com/Frickeldave/ContainerRabbitMQ"
LABEL		org.opencontainers.image.documentation="https://github.com/Frickeldave/ContainerRabbitMQ/README.md"
LABEL		org.opencontainers.image.source="https://github.com/Frickeldave/ContainerRabbitMQ"
LABEL 		org.opencontainers.image.description "This is the rabbitmq image for the docker infrastructure of the frickeldave environment."


# ############################################################################################
# The following section is copied from alpine base image, because it was to complex to build
# rabbitmq by our own. Please keep this section in sync with the alpine Dockerfile.
#	Files to sync: 
#	- Dockerfile
# 	- createcerts.sh (You can copy the whole file)

# Define the groupname for the rabbitma users
ARG         rabbitmq_gname=rabbitmq

# add local user "appuser" which is used to run the application
RUN 		adduser -D -h "/home/appuser" -u 50000 -g 50000 -s /bin/sh appuser

RUN			mkdir /home/appuser/data; \
			mkdir /home/appuser/data/certificates; \
			mkdir /home/appuser/app; \
			mkdir /home/appuser/app/tools

RUN			chown -R appuser:appuser /home/appuser/data; \
			chown -R appuser:appuser /home/appuser/data/certificates; \
			chown -R appuser:appuser /home/appuser/app; \
			chown -R appuser:appuser /home/appuser/app/tools

# Install additionally required tools
RUN 		apk update; \
			apk --no-cache add jq \
				curl \
				ca-certificates \
				openssl && \
			rm -rf /var/lib/apt/lists/*; \
			rm -rf /var/cache/apk/*; \
			update-ca-certificates --fresh 2>/dev/null || true

# Get script file for certificate management
RUN 		curl https://raw.githubusercontent.com/Frickeldave/ScriptCollection/master/bash/create-self-signed-certificates/createcerts.sh --output /home/appuser/app/tools/createcerts.sh

# Set permission for newly created files and folders
RUN 		chown -R appuser:appuser /home/appuser/app/tools; \
			chmod +x /home/appuser/app/tools/createcerts.sh
#
#
# ############################################################################################

ENV 		RABBITMQ_DATA_DIR="/home/appuser/data/rabbitmq"
ENV 		HOME="/home/appuser/data/rabbitmq"
ENV			RABBITMQ_MNESIA_DIR="/home/appuser/data/rabbitmq/data"
ENV			RABBITMQ_CONFIG_FILE="/home/appuser/data/rabbitmq.conf"

RUN 		adduser appuser ${rabbitmq_gname}

RUN 		mkdir -p /home/appuser/data/rabbitmq/data; \
				mkdir /home/appuser/app/rabbitmq

COPY 		./start.sh /home/appuser/app/rabbitmq/start.sh

RUN 		chown -R appuser:appuser /home/appuser/data/rabbitmq \
				&& chown -R appuser:appuser /home/appuser/app/rabbitmq

USER 		appuser

ENTRYPOINT 	["/home/appuser/app/rabbitmq/start.sh"]
