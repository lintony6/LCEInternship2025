cd <folder> into directory of container project
docker compose up -d --build (Build container and start)
ipconfig (To get IP Address of container)
ssh someuser@<ip address> -p 2222 (Fill in IP Address from previous step)
ls in someuser ~ directory
cat hint.txt (Read the hint for someuser)
open in browser <ip address>:8080
Inspect element of webpage (Find hidden hacker credentials)
exit in terminal of someuser
ssh hacker@<ip address> -p 2222 (Fill in same IP Address to log in as hacker)
ls -a (To find hidden files with hints)
cat .hidden_hint (View hint)
sudo su (Privilege Escalation)
cat .final_hint (Read final hint)
cd /root (cd to /root with final flag)
ls -a (List all files even hidden)
cat secret.txt (Get flag)
