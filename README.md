cd <folder> into directory of container project
docker compose up -d -- build (Build container and start)
Launch webpage from container
Find hidden message with credentials in webpage
in terminal: ipconfig (To get IP Address of container)
ssh someuser@<ip address> -p 2222 (Fill in IP Address from previous step) (use password from webpage)
Is as someuser ~ directory
cat hint.txt
exit in terminal to logout of someuser
ssh hacker@<ip address> -p 2222 (Fill in same IP Address to log in as hacker)
Use credentials from hint.txt
Is -a (To find hidden files with hints)
cat.hidden_hint (View hint)
sudo su (Privilege Escalation)
cat.final_hint (Read final hint)
cd /root (cd to /root with final flag)
Is -a (List all files even hidden)
cat secret.txt (Get flag)
