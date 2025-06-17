# Start with Ubuntu 20.04
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Install services and tools
RUN apt-get update && \
    apt-get install -y openssh-server netcat-traditional apache2 sudo nmap curl vsftpd inetutils-ftp net-tools && \
    rm -rf /var/lib/apt/lists/*

# Create run directories
RUN mkdir -p /run/sshd /var/run/apache2 /var/lock/apache2

# vsftpd secure chroot directory
RUN mkdir -p /var/run/vsftpd/empty && chmod 700 /var/run/vsftpd/empty

# --- SSH Configuration ---
# Allow root login and password authentication (WARNING: Insecure)
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# --- Wordlists ---
RUN mkdir -p /opt/wordlists
RUN echo "someuser\nhacker\nroot" > /opt/wordlists/users.txt
RUN echo "Welcome123\nEscalateMe\npassword\n123456" > /opt/wordlists/passwords.txt

# --- User Setup for Privilege Escalation ---
RUN useradd -m -s /bin/bash someuser && \
    echo "someuser:Welcome123" | chpasswd && \
    echo "Check the webpage source on port 8080 for a hidden clue." > /home/someuser/hint.txt && \
    chown someuser:someuser /home/someuser/hint.txt

RUN useradd -m -s /bin/bash hacker && \
    echo "hacker:EscalateMe" | chpasswd && \
    usermod -aG sudo hacker && \
    echo "hacker ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN sed -i '/someuser/d' /etc/sudoers.d/someuser || true

RUN echo "Try escalating privileges with: sudo su" > /home/hacker/.hidden_hint && \
    chmod 404 /home/hacker/.hidden_hint && \
    echo "Check the /root directory for the final flag." > /home/hacker/.final_hint && \
    chmod 400 /home/hacker/.final_hint

RUN echo "Congrats! You escalated privileges. Flag: {ROOT_ACCESS_GRANTED}" > /root/secret.txt && \
    chmod 600 /root/secret.txt

# --- Apache2 Web Server Configuration ---
RUN a2enmod autoindex
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
RUN mkdir -p /var/www/html/secrets
RUN echo "FLAG{OPEN_DIRECTORY_LISTING_EXPOSED_SECRETS}" > /var/www/html/secrets/flag.txt && \
    echo "Another file in this secret directory." > /var/www/html/secrets/another_file.txt
RUN sed -i '/<Directory \/var\/www\/html>/a\ \tOptions Indexes FollowSymLinks' /etc/apache2/sites-available/000-default.conf

# Modify Apache's default DocumentRoot to point to the social media page
RUN sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html/social|g' /etc/apache2/sites-available/000-default.conf
RUN sed -i 's|<Directory /var/www/html>|<Directory /var/www/html/social>|g' /etc/apache2/sites-available/000-default.conf

# --- Mock Social Media Page Setup ---
RUN mkdir -p /var/www/html/social
# Copies the social_media_index.html from the build context into the container
COPY social_media_index.html /var/www/html/social/index.html

# --- VSFTPD SETUP FOR ANONYMOUS READ-ONLY ACCESS ---
RUN mkdir -p /var/ftp && chown ftp:ftp /var/ftp

# Anonymous chroot root directory. Owned by root, not writable by FTP user.
RUN mkdir -p /var/ftp/pub && chown root:root /var/ftp/pub && chmod 755 /var/ftp/pub

# Flag file readable by anonymous users.
RUN echo "FLAG{ANONYMOUS_FTP_ACCESS_GRANTED}" > /var/ftp/pub/ftp_flag.txt && chmod 644 /var/ftp/pub/ftp_flag.txt

# --- IMPORTANT: Remove 'uploads' directory if only read access is needed ---
# RUN mkdir -p /var/ftp/pub/uploads && chmod 777 /var/ftp/pub/uploads && chown ftp:ftp /var/ftp/pub/uploads

# --- Copy Configuration Files and Startup Script ---
COPY vsftpd.conf /etc/vsftpd.conf
COPY start.sh /start.sh
RUN chmod +x /start.sh

# --- Expose Ports ---
EXPOSE 22 80 21 21100-21110

# --- Container Entrypoint ---
CMD ["/start.sh"]
