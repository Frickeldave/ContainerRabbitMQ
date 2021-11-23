

## Exampples for executing rabbitmq

### CAll with custom ports and self signed certificate
docker run --env RBT_AMQPLISTENER=50034 --env RBT_AMQPSSLLISTENER=50035 --env RBT_AMQPDEFAULTUSER=rbtadmin --env RBT_AMQPDEFAULTUSERPWD=rbtadmin123 --env RBT_MGMTLISTENER=50032 --env CRT_VALIDITY=3650 --env CRT_C=DE --env CRT_S=Bavarian --env CRT_L=Hörgertshausen --env CRT_OU=home --env CRT_CN=mq.frickeldave.local --env CRT_LENGTH=4096 ghcr.io/frickeldave/fd_rabbitmq:3.9.10
