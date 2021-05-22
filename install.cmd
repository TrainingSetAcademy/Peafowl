@echo off
color a
cls
set MainPath=%~d0%~p0
echo.
echo.
echo ------------------------------------------------------------------------
echo                           TRAINING SET ACADEMY
echo ------------------------------------------------------------------------
echo [+] Path is Detected : %MainPath%
FindAndReplaceText %MainPath%KuShellExtension\config.xml "r3pl4ce_m3" %MainPath%
echo [+] Default Config Path Replaced with %MainPath%
@echo off
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
	regsvr32 /s %MainPath%KuShellExtension\KuShellExtension64.dll
	echo [+] KuShellExtension 64Bit installed.
) else (
	regsvr32 /s %MainPath%KuShellExtension\KuShellExtension.dll
	echo [+] KuShellExtension 32Bit installed.
)

echo [+] Editing registry Key (MenuShowDelay) from 400ms to 5ms...
reg add "HKCU\Control Panel\Desktop" /f /v MenuShowDelay /d 5 
echo [+] Registry Successfully Edited.
echo [+] Done.
echo ------------------------------------------------------------------------
echo               REBOOT THE SYSTEM TO COMPLETE INSTALL
echo ------------------------------------------------------------------------

FindAndReplaceText "%MainPath%01 Debugging\Ollydbg 1.10\ollydbg.ini" "Plugin path=" "Plugin path=%MainPath%01 Debugging\Ollydbg 1.10\Plugins"
FindAndReplaceText "%MainPath%01 Debugging\Ollydbg 1.10\ollydbg.ini" "UDD path=" "UDD path=%MainPath%01 Debugging\Ollydbg 1.10\Plugins"
FindAndReplaceText "%MainPath%01 Debugging\Ollydbg 2.01\ollydbg.ini" "Data directory=" "Data directory=%MainPath%01 Debugging\Ollydbg 2.01\Plugins"
FindAndReplaceText "%MainPath%01 Debugging\Ollydbg 2.01\ollydbg.ini" "Plugin directory=" "Plugin directory=%MainPath%01 Debugging\Ollydbg 2.01\Plugins"
FindAndReplaceText "%MainPath%01 Debugging\Ollydbg 2.01\ollydbg.ini" "Standard library directory=" "Standard library directory=%MainPath%01 Debugging\Ollydbg 2.01"
FindAndReplaceText "%MainPath%01 Debugging\x96dbg\release\x96dbg.ini" "x32dbg=" "x32dbg=%MainPath%01 Debugging\x96dbg\release\x32\x32dbg.exe"
FindAndReplaceText "%MainPath%01 Debugging\x96dbg\release\x96dbg.ini" "x64dbg=" "x64dbg=%MainPath%01 Debugging\x96dbg\release\x64\x64dbg.exe"
timeout 5



