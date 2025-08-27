@echo off

REM Get the default gateway IP by parsing the output of 'route print'
for /f "tokens=1,2,3,4 delims= " %%a in ('route print ^| findstr /i "0.0.0.0"') do (
    if /i not "%%c"=="On-link" (
        set "gateway_ip=%%c"
        goto :found
    )
)

:found

REM Resolve the IP address of the Xray server dynamically
REM Replace <hostname> with the hostname of your Xray server
set hostname=%1
for /f "tokens=2 delims=[]" %%A in ('ping -n 1 %hostname% ^| findstr "["') do set destination_ip=%%A


REM Print the resolved IPs for verification
REM echo Resolved destination IP: %destination_ip%
REM echo Default gateway IP: %gateway_ip%

REM pause

REM Start the tun2socks process
@REM Start "" "%userprofile%\Documents\OverWall\tun2socks.exe" -device "tun://wintun?guid={9D06A7A3-2A11-49A0-A0B9-A0093B57ECD3}" -proxy socks5://127.0.0.1:1080
set VBSFile=%TEMP%\run_tun2socks.vbs
echo Set WshShell = CreateObject("WScript.Shell") > "%VBSFile%"
echo WshShell.Run """%userprofile%\Documents\OverWall\tun2socks.exe"" -device ""tun://wintun?guid={9D06A7A3-2A11-49A0-A0B9-A0093B57ECD3}"" -proxy socks5://127.0.0.1:1080", 0 >> "%VBSFile%"
cscript //nologo "%VBSFile%"
del "%VBSFile%"

REM Pause to ensure tun2socks starts correctly
timeout /t 5

REM Set a static IP address for the Wintun interface
netsh interface ipv4 set address name="wintun" source=static addr=192.168.123.1 mask=255.255.255.0

REM Set DNS servers for the Wintun interface
netsh interface ipv4 set dnsservers name="wintun" static address=8.8.8.8 register=none validate=no
netsh interface ipv4 add dnsservers name="wintun" address=1.1.1.1 index=2

REM Add a route to bypass the local proxy for 127.0.0.1
route add 127.0.0.1 mask 255.255.255.255 0.0.0.0 metric 1

REM Add a route to bypass the destination server (Xray outbound server)
route add %destination_ip% mask 255.255.255.255 %gateway_ip% metric 1
route add 8.8.8.8 mask 255.255.255.255 %gateway_ip% metric 1
route add 1.1.1.1 mask 255.255.255.255 %gateway_ip% metric 1

REM Add a default route for traffic through the Wintun interface
netsh interface ipv4 add route 0.0.0.0/0 "wintun" 192.168.123.1 metric=1
