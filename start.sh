#!/bin/sh

INITIALSTART=0

echo "Running start.sh script"

# set initstart variable
if [ ! -f /home/appuser/data/firststart.flg ]
then
    echo "First start, set initialstart variable to 1"
    INITIALSTART=1
    echo `date +%Y-%m-%d_%H:%M:%S_%z` > /home/appuser/data/firststart.flg
else
	echo "It's not the first start, skip first start section"
fi


if [ "$INITIALSTART" == "1" ]
then
    echo "Initial start"
    /home/appuser/app/tools/createcerts.sh
else
	echo "It's not the first start, skip first start section"
fi 

# Configure rabbitmq (https://github.com/rabbitmq/rabbitmq-server/blob/v3.8.x/deps/rabbit/docs/rabbitmq.conf.example)
# Set the AMQP port
echo "listeners.ssl.default = $RBT_AMQPSSLLISTENER" > /home/appuser/data/rabbitmq.conf
# This will disable non-ssl connections
#echo "listeners.tcp = none" >> /home/appuser/data/rabbitmq.conf

echo "listeners.tcp.1 = 0.0.0.0:$RBT_AMQPLISTENER" >> /home/appuser/data/rabbitmq.conf

# Configure SSL for AMQP
echo "listeners.ssl.1 = $RBT_AMQPSSLLISTENER" >> /home/appuser/data/rabbitmq.conf
echo "ssl_options.verify = verify_peer" >> /home/appuser/data/rabbitmq.conf
echo "ssl_options.fail_if_no_peer_cert = false" >> /home/appuser/data/rabbitmq.conf
echo "ssl_options.cacertfile = /home/appuser/data/certificates/cer.crt" >> /home/appuser/data/rabbitmq.conf
echo "ssl_options.certfile = /home/appuser/data/certificates/cer.crt" >> /home/appuser/data/rabbitmq.conf
echo "ssl_options.keyfile = /home/appuser/data/certificates/key.key" >> /home/appuser/data/rabbitmq.conf
echo "ssl_options.verify = verify_none" >> /home/appuser/data/rabbitmq.conf
echo "ssl_options.fail_if_no_peer_cert = false" >> /home/appuser/data/rabbitmq.conf

# Set default user and vhost
echo "default_vhost = /" >> /home/appuser/data/rabbitmq.conf
echo "default_user = $RBT_AMQPDEFAULTUSER" >> /home/appuser/data/rabbitmq.conf
echo "default_pass = $RBT_AMQPDEFAULTUSERPWD" >> /home/appuser/data/rabbitmq.conf
echo "default_permissions.configure = .*" >> /home/appuser/data/rabbitmq.conf
echo "default_permissions.read = .*" >> /home/appuser/data/rabbitmq.conf
echo "default_permissions.write = .*" >> /home/appuser/data/rabbitmq.conf
echo "default_user_tags.administrator = true" >> /home/appuser/data/rabbitmq.conf

# Configure management server (ssl is not used because ssl is terminated at nginx)
echo "management.tcp.port = $RBT_MGMTLISTENER" >> /home/appuser/data/rabbitmq.conf
echo "management.tcp.ip = 0.0.0.0" >> /home/appuser/data/rabbitmq.conf

# Configure stomp plugin
# echo "stomp.listeners.tcp = none" >> /home/appuser/data/rabbitmq.conf
# echo "stomp.listeners.ssl.1 = $RBT_STOMPLISTENER" >> /home/appuser/data/rabbitmq.conf
# echo "stomp.default_user = stompadmin" >> /home/appuser/data/rabbitmq.conf
# echo "stomp.default_pass = stompadmin123" >> /home/appuser/data/rabbitmq.conf

# Enable stomp plugin
# echo "Enable stomp plugin"
# rabbitmq-plugins enable rabbitmq_stomp

# Start rabbitmq-server with original script from rabbitmq
/usr/local/bin/docker-entrypoint.sh rabbitmq-server