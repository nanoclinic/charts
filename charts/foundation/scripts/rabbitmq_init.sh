#!/bin/sh
echo "overwriting variable"
export RABBITMQ_PASSWOR=$(echo $RABBITMQ_PASSWORD | awk -F: '/password/ {print $4}'| sed -e "s/password//g" | sed -E 's/"|"}//g')
rabbitmqctl change_password $RABBITMQ_USERNAME $RABBITMQ_PASSWOR