#!/bin/bash

# Ensure SSH directory exists
mkdir -p /run/sshd

# Start SSH in foreground mode
/usr/sbin/sshd -D &

# Start Apache in foreground (keeps container running)
apachectl -D FOREGROUND 

# Switch to someuser after services start
exec su - someuser
