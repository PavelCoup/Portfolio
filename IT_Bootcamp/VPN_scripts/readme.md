# Scripts for automating the creation of VPN connections

## *For use, you must have a valid file with data for connection, it is issued separately*

- Upon running the script, the user is prompted to specify the location of VPN_access.json (for windows). The script creates a connection with a name, for example, VPN_L2TP_IT_BOOTCAMP_2023, and deletes any pre-existing connection with the same name. This is done to recreate the connection in case there are any changes to the server settings. If you have renamed the connection created by the script before, the script will simply create a new connection. Renaming the connection created by the script is possible, but not recommended to avoid confusion.

- In addition, entries are created in the hosts file in the form of dev.example.com (for example), after deleting all lines containing example.com (for example). The remaining data in the file is preserved in its original form.

### Windows 10+ (Testing is necessary)

#### with administrator rights

```powershell
Invoke-WebRequest -Uri "https://example.com/VPN_connection_win.ps1" -OutFile "$env:TEMP\VPN_connection_win.ps1";
PowerShell.exe -ExecutionPolicy bypass -File "$env:TEMP\VPN_connection_win.ps1";
exit;
```

### Ubuntu / Mint / Debian / etc (Testing is necessary)

```bash
curl -ofCL /home/user/VPN_connection_linux.sh https://example.com/VPN_connection_linux.sh \
&& bash /home/user/VPN_connection_linux.sh -p /home/user/VPN_access.json
```
