rem Licensed to the Apache Software Foundation (ASF) under one
rem or more contributor license agreements.  See the NOTICE file
rem distributed with this work for additional information
rem regarding copyright ownership.  The ASF licenses this file
rem to you under the Apache License, Version 2.0 (the
rem "License"); you may not use this file except in compliance
rem with the License.  You may obtain a copy of the License at
rem
rem   http://www.apache.org/licenses/LICENSE-2.0
rem
rem Unless required by applicable law or agreed to in writing,
rem software distributed under the License is distributed on an
rem "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
rem KIND, either express or implied.  See the License for the
rem specific language governing permissions and limitations
rem under the License.

rem 
rem Configure and start RDP service.
rem Configure RPD service to use custom key instead of autogenerated for Wireshark and Network Monitor Decrypt Expert.
rem rdp.pfx is necessary because it fingerprints are hardcoded in this script.
rem 

rem Turn off firewall

netsh advfirewall firewall set rule group="Remote Desktop" new enable=yes

rem Enable TS connections
rem 
rem Windows Registry Editor Version 5.00
rem 
rem [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server]
rem "AllowTSConnections"=dword:00000001
rem "fDenyTSConnections"=dword:00000000

reg add "HKLM\System\CurrentControlSet\Control\Terminal Server" /v "AllowTSConnections" /t REG_DWORD /d 1 /f
reg add "HKLM\System\CurrentControlSet\Control\Terminal Server" /v "fDenyTSConnections" /t REG_DWORD /d 0 /f

rem Disable RDP NLA

reg add "HKLM\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v UserAuthentication /t REG_DWORD /d 0 /f

rem Enable TS service

sc config TermService start=auto

rem Certificate Generation

rem Make self-signed certificate

rem makecert -r -pe -n "CN=%COMPUTERNAME%" -eku 1.3.6.1.5.5.7.3.1 -ss my -sr LocalMachine -sky exchange -sp "Microsoft RSA SChannel Cryptographic Provider" -sy 12

rem Import certificate

certutil -p test -importPFX "Remote Desktop" rdp.pfx

rem Configure RDP server to use certificate:

rem Windows Registry Editor Version 5.00
rem 
rem [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp]
rem "SSLCertificateSHA1Hash"=hex:c1,70,84,70,bc,56,42,0a,bb,f4,35,35,ba,a6,09,b0,4e,98,4a,47
reg add "HKLM\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v "SSLCertificateSHA1Hash" /t REG_HEX /d "" /f

rem  Grant permissions on certificate for everyone

rem  certutil -repairstore My "bcb40fb84ac891bd41068fe686864559" D:PAI(A;;GA;;;BA)(A;;GA;;;SY)(A;;GR;;;NS)
certutil -repairstore "Remote Desktop" "bcb40fb84ac891bd41068fe686864559" D:PAI(A;;GA;;;BA)(A;;GA;;;SY)(A;;GR;;;NS)

rem confirm with

rem certutil -store -v My
certutil -store -v "Remote Desktop"

rem Disable TLS 1.1 (for Network Monitor Decrypt Expert)
rem 
rem Windows Registry Editor Version 5.00
rem 
rem [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client]
rem "Enabled"=dword:00000000
rem "DisabledByDefault"=dword:00000001
rem 
rem [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server]
rem "Enabled"=dword:00000000
rem "DisabledByDefault"=dword:00000001

reg add "HKLM\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client" /v "Enabled" /t REG_DWORD /d 0 /f
reg add "HKLM\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client" /v "DisabledByDefault" /t REG_DWORD /d 1 /f
reg add "HKLM\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server" /v "Enabled" /t REG_DWORD /d 0 /f
reg add "HKLM\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server" /v "DisabledByDefault" /t REG_DWORD /d 1 /f


rem Disable TLS 1.2 (for Network Monitor Decrypt Expert)
rem 
rem Windows Registry Editor Version 5.00
rem 
rem [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client]
rem "Enabled"=dword:00000000
rem "DisabledByDefault"=dword:00000001
rem 
rem [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server]
rem "Enabled"=dword:00000000
rem "DisabledByDefault"=dword:00000001

reg add "HKLM\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client" /v "Enabled" /t REG_DWORD /d 0 /f
reg add "HKLM\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client" /v "DisabledByDefault" /t REG_DWORD /d 1 /f
reg add "HKLM\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server" /v "Enabled" /t REG_DWORD /d 0 /f
reg add "HKLM\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server" /v "DisabledByDefault" /t REG_DWORD /d 1 /f

rem Start TS service

net start Termservice

rem Enable logs

wevtutil sl Microsoft-Windows-TerminalServices-RemoteConnectionManager/Admin /enabled:true /quiet:true
wevtutil sl Microsoft-Windows-TerminalServices-RemoteConnectionManager/Analytic /enabled:true /quiet:true
wevtutil sl Microsoft-Windows-TerminalServices-RemoteConnectionManager/Debug /enabled:true /quiet:true
wevtutil sl Microsoft-Windows-TerminalServices-RemoteConnectionManager/Operational /enabled:true /quiet:true
wevtutil sl Microsoft-Windows-TerminalServices-SessionBroker-Client/Admin /enabled:true /quiet:true
wevtutil sl Microsoft-Windows-TerminalServices-SessionBroker-Client/Analytic /enabled:true /quiet:true
wevtutil sl Microsoft-Windows-TerminalServices-SessionBroker-Client/Debug /enabled:true /quiet:true
wevtutil sl Microsoft-Windows-TerminalServices-SessionBroker-Client/Operational /enabled:true /quiet:true
wevtutil sl Microsoft-Windows-NTLM/Operational /enabled:true /quiet:true



rem For Network Monitor Decrypt Expert.

rem Install .Net 3.5

rem dism /online /enable-feature /featurename:NetFx3ServerFeatures
rem dism /online /enable-feature /featurename:NetFx3

rem PS.
rem Don't forget to set Windows profile as active in Network Monitor, so SSL traffic branch will appear under
rem svnchost.exe, so you will be able to decrypt it (don't forget to save and reopen captured traffic to file first).
rem 

