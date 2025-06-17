#!/bin/bash
set -e

mkdir -p /run/sshd /var/run/vsftpd/empty

# Start SSH
/usr/sbin/sshd

# Start Apache
apachectl start

# Start vsftpd
touch /var/log/vsftpd.log
chmod 644 /var/log/vsftpd.log
/usr/sbin/vsftpd /etc/vsftpd.conf > /var/log/vsftpd_startup.log 2>&1 &

# Keep container alive
tail -f /dev/null
