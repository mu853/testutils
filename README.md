# ping_check.ps1

When tesing network connection with linux ping command,
finding packet loss timing from log takes a lot of time.

```ping_check.ps1``` helps you to find packet loss timing by checking icmp_seq no.
if you use ping -D option (add timestamp), it converts that timestamp from unixtime to localtime string.

## Usage

1. Locate ```ping_check.ps1``` to your log directory.
2. Start PowerShell and change directory to the log directory.
3. Execute ```.\ping_check.ps1```.

```ping_check.ps1``` searches files named [*ping.log] recursively from current directory.

