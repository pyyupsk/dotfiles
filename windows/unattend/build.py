"""Build autounattend.xml from Specialize.ps1. --share builds the version for friends."""
import sys
from xml.sax.saxutils import escape

share = "--share" in sys.argv
ps = open("Specialize.ps1").read()
if share:
    ps = ps.replace("Set-Dword 'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\TimeZoneInformation' RealTimeIsUniversal 1\n", "")

extract = ("powershell.exe -NoProfile -Command \"$x=[xml](Get-Content $env:windir\\Panther\\unattend.xml -Raw);"
           "$x.unattend.Extensions.File|%{$p=$_.path;mkdir (Split-Path $p) -ea 0|Out-Null;Set-Content $p $_.InnerText}\"")
run = r"powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\Windows\Setup\Scripts\Specialize.ps1"
assert len(extract) <= 259 and len(run) <= 259

A = 'processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS"'
intl = """<InputLocale>0409:00000409;041e:0000041e</InputLocale>
      <SystemLocale>en-US</SystemLocale>
      <UILanguage>en-US</UILanguage>
      <UserLocale>en-US</UserLocale>"""

pe_intl = "" if share else f"""
    <component name="Microsoft-Windows-International-Core-WinPE" {A}>
      <SetupUILanguage><UILanguage>en-US</UILanguage></SetupUILanguage>
      {intl}
    </component>"""
key = "" if share else """
        <ProductKey><Key>VK7JG-NPHTM-C97JM-9MPGT-3V66T</Key><WillShowUI>OnError</WillShowUI></ProductKey>"""
computer = "" if share else "\n      <ComputerName>PYYUPSK-PC</ComputerName>"
oobe_intl = "" if share else f"""
    <component name="Microsoft-Windows-International-Core" {A}>
      {intl}
    </component>"""
accounts = "" if share else """
      <UserAccounts>
        <LocalAccounts>
          <LocalAccount wcm:action="add">
            <Name>pyyupsk</Name>
            <Group>Administrators</Group>
            <Password><Value></Value><PlainText>true</PlainText></Password>
          </LocalAccount>
        </LocalAccounts>
      </UserAccounts>"""

xml = f"""<?xml version="1.0" encoding="utf-8"?>
<!-- Lightest Windows 11 that still runs Valorant. Disk partitioning stays manual. -->
<unattend xmlns="urn:schemas-microsoft-com:unattend" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State">
  <settings pass="windowsPE">{pe_intl}
    <component name="Microsoft-Windows-Setup" {A}>
      <UserData>{key}
        <AcceptEula>true</AcceptEula>
      </UserData>
      <Diagnostics><OptIn>false</OptIn></Diagnostics>
    </component>
  </settings>
  <settings pass="specialize">
    <component name="Microsoft-Windows-Shell-Setup" {A}>{computer}
      <TimeZone>SE Asia Standard Time</TimeZone>
    </component>
    <component name="Microsoft-Windows-Deployment" {A}>
      <RunSynchronous>
        <RunSynchronousCommand wcm:action="add"><Order>1</Order><Path>{escape(extract)}</Path></RunSynchronousCommand>
        <RunSynchronousCommand wcm:action="add"><Order>2</Order><Path>{escape(run)}</Path></RunSynchronousCommand>
      </RunSynchronous>
    </component>
  </settings>
  <settings pass="oobeSystem">{oobe_intl}
    <component name="Microsoft-Windows-Shell-Setup" {A}>
      <OOBE>
        <HideEULAPage>true</HideEULAPage>
        <HideOEMRegistrationScreen>true</HideOEMRegistrationScreen>
        <HideOnlineAccountScreens>true</HideOnlineAccountScreens>
        <HideWirelessSetupInOOBE>true</HideWirelessSetupInOOBE>
        <ProtectYourPC>3</ProtectYourPC>
      </OOBE>{accounts}
    </component>
  </settings>
  <Extensions xmlns="https://github.com/pyyupsk/unattend">
    <File path="C:\\Windows\\Setup\\Scripts\\Specialize.ps1">{escape(ps)}</File>
  </Extensions>
</unattend>
"""
out = "autounattend.share.xml" if share else "autounattend.xml"
open(out, "w", newline="\r\n").write(xml)
print(out)
