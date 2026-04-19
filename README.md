# 2048-ps
## About
This is a PowerShell implementation of a famous game 2048.

Use arrow keys to navigate, q to quit the game.

To run the game on Windows, execute:
```
powershell .\2048.ps1
```
On macOS/Linux:
```
pwsh 2048.ps1
```
## Execution policy
Windows can restrict running custom PowerShell scripts on your machine.
To fix that, you have to set execution policy in your system. To do that:
1. Open PowerShell
2. Run `Set-ExecutionPolicy Unrestricted -Scope CurrentUser`.
3. If the problem persists, try unblocking the file by running `Unblock-File <C:\path\to\2048.ps1>`
Also you can bypass the execution policy: `powershell -ExecutionPolicy Bypass -File <C:\path\to\2048.ps1>`

## Known issues
This script doesn`t work in ISE and some custom terminals on Windows (like mintty). Idk how to fix that.