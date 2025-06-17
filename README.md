Getting Started
Set up the container:
Navigate to your project directory and run docker compose up -d --build.

Find the container's IP:
Use ipconfig on your host machine to locate the container's private IP address (e.g., 172.x.x.x).

Initial Access (someuser)
SSH as someuser:
Connect via ssh someuser@<CONTAINER_IP_ADDRESS> -p 2222. The password is Welcome123.

Explore the environment:
Once logged in, check for hints with ls and cat hint.txt.

Perform default nmap script scan:
nmap -sC -sV localhost

Anonymously login to FTP server:
Login to the ftp server with ftp localhost with anonymous and no password to retrieve the flag.

Access the web app:
Open http://<CONTAINER_IP_ADDRESS>:8080 in your browser. Use browser developer tools (F12) to inspect the page for hidden credentials.

Exit someuser:
Type exit in the SSH terminal.

Privilege Escalation (hacker & Root)
SSH as hacker:
Connect using ssh hacker@<CONTAINER_IP_ADDRESS> -p 2222 with the password found from the web app.

Find hidden clues:
List all files using ls -a and read the hidden hint with cat .hidden_hint.

Escalate privileges:
Use sudo su to gain root access.

Get the flag:
Read the final hint with cat .final_hint, then cd /root and cat secret.txt to reveal the flag.