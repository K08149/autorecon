# AUTORECON:
a tool to automate recon of bug bounty which includes major tools. 
##  INCLUDE TOOLS:

| Tool         | Purpose                                  |
|--------------|------------------------------------------|
| **subfinder**| Subdomain enumeration                    |
| **dnsx**     | DNS probing and resolution               |
| **httpx**    | Web server probing and fingerprinting    |
| **naabu**    | Fast and reliable port scanning          |
| **nuclei**   | Vulnerability scanning with templates    |
| **gau**      | Gathering archived URLs                  |
| **gowitness**| Screenshotting discovered URLs           |
| **ffuf**     | Fuzzing for directories and files        |

###  SYSTEM REQUIREMENTS:
- Go => 1.21+
- Python 3
- Bash shell
###  INSTALLATION:
1. git clone "https://github.com/K08149/autorecon.git"
2. cd autorecon
3. chmod +x bootstrap.sh
4. ./bootstrap.sh
### (OPTIONAL) VERIFY SETUP:
5. python3 setup.py
6. bash ./autorecon.sh -d <domain> [flags]
EXAMPLE :
bash ./autorecon.sh -d example.com --quick
### AVAILABLE FLAGS: 
FLAGS DESCRIPTION :
-d <domain>	(Required) Target domain
--quick	Run quick mode (skips some heavy fuzzing)
-o <outputdir>	Custom output directory (default: recon0/)
-v	Verbose output
### EXAMPLE OUTPUT DIRECTORY OUTPUT:
recon0/
└── example.com/
    ├── subdomains.txt
    ├── ports/
    ├── js/
    ├── nuclei/
    ├── ffuf/
    ├── screenshots/
    ├── logs/
### NOTES:
1. Make sure your $PATH includes $HOME/go/bin

2. nuclei will automatically update templates on first run

3. If any tools fail to install, re-run bootstrap.sh or check your Go setup

4. FOR WINDOWS/WSL USERS:

If you're using WSL (Windows Subsystem for Linux) or cloning the repo from Windows:
You may see "/usr/bin/env: ‘bash\r’: No such file or directory"

To fix this:

Set Git to use Unix line endings by running:
git config --global core.autocrlf input
sudo apt update
sudo apt install dos2unix
dos2unix bootstrap.sh
dos2unix *.sh


### OPTIONAL:
if you want to  confirm a file has Unix-style endings, run:
file bootstrap.sh
### EXPECTED OUTPUT:
bootstrap.sh: ASCII text
### even If you see:
bootstrap.sh: ASCII text, with CRLF line terminators
### then it still has Windows line endings.

