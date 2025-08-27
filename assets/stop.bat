@echo off

REM Remove the default route
netsh interface ipv4 delete route 0.0.0.0/0 "wintun" 192.168.123.1

REM Remove the bypass route for 127.0.0.1
route delete 127.0.0.1


set hostname=%1
for /f "tokens=2 delims=[]" %%A in ('ping -n 1 %hostname% ^| findstr "["') do set destination_ip=%%A


REM Remove the bypass route for the destination server
route delete %destination_ip%
route delete 8.8.8.8
route delete 8.8.4.4

REM Optional: Stop the tun2socks process (by name or manually)
taskkill /f /im tun2socks.exe

netsh interface ip set address "Loopback Pseudo-Interface 1" static address=127.0.0.1 mask=255.0.0.0 gateway=none
