# Use an Ubuntu base image
FROM ubuntu:20.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update package lists and install required packages
RUN apt-get update && apt-get install -y \
    openssh-server \
    netcat \
    apache2 \
    sudo \
    apt-transport-https \
    && rm -rf /var/lib/apt/lists/*

# Create necessary directories as root BEFORE switching users
RUN mkdir -p /run/sshd /var/run/apache2 /var/lock/apache2
RUN chown -R root:root /run/sshd /var/run/apache2 /var/lock/apache2

# Create a low-privilege user (someuser) with a known password
RUN useradd -m -s /bin/bash someuser
RUN echo "someuser:Welcome123" | chpasswd
RUN mkdir -p /home/someuser
RUN echo "Check the webpage source on port 8080 for a hidden clue." > /home/someuser/hint.txt
RUN chown someuser:someuser /home/someuser/hint.txt

# Create a high-privilege user (hacker) with a hidden password
RUN useradd -m -s /bin/bash hacker
RUN echo "hacker:EscalateMe" | chpasswd
RUN usermod -aG sudo hacker
RUN echo "hacker ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Ensure someuser does NOT have sudo privileges
RUN sed -i '/someuser/d' /etc/sudoers

# Create a visually minimal Apache index.html with a visible hint and hidden credentials
RUN echo "<html><head><title>Vulnerable Server</title></head><body><h1>Look Deeper!</h1><p>The real secrets are hidden from plain sight...</p><div style=\"display:none;\" id=\"hiddenCredentials\">  <span id=\"username\">Username: hacker</span><br>  <span id=\"password\">Password: EscalateMe</span></div></body></html>" > /var/www/html/index.html

# Leave a hint for privilege escalation in hacker's home directory and grant read permission to others
RUN echo "Try escalating privileges with: sudo su" > /home/hacker/.hidden_hint && chmod 404 /home/hacker/.hidden_hint

# Create a root-only hidden file with a hint to check /root
RUN echo "Check the /root directory for the final flag." > /home/hacker/.final_hint && chmod 400 /home/hacker/.final_hint
# Fix Apache ServerName warning
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Create a root-only file that requires privilege escalation
RUN echo "Congrats! You escalated privileges. Flag: {ROOT_ACCESS_GRANTED}" > /root/secret.txt
RUN chmod 600 /root/secret.txt

# Copy startup script and make it executable
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Expose web and SSH ports
EXPOSE 22 80

# Ensure the script runs with root privileges
CMD ["sudo", "/bin/bash", "/start.sh"]