@echo off
color c
cls
: ------------------
echo.
echo ######  ######  #######  #####   #####     #     # #######  #####  
echo #     # #     # #       #     # #     #     #   #  #       #     # 
echo #     # #     # #       #       #            # #   #       #       
echo ######  ######  #####    #####   #####        #    #####    #####  
echo #       #   #   #             #       #       #    #             # 
echo #       #    #  #       #     # #     #       #    #       #     # 
echo #       #     # #######  #####   #####        #    #######  #####    
echo.
echo.
echo ######  #     # ####### ####### ####### #     #              
echo #     # #     #    #       #    #     # ##    #              
echo #     # #     #    #       #    #     # # #   #              
echo ######  #     #    #       #    #     # #  #  #              
echo #     # #     #    #       #    #     # #   # #              
echo #     # #     #    #       #    #     # #    ##              
echo ######   #####     #       #    ####### #     #           
: ------------------
echo.
set MainPath=%~d0%~p0
set RegMainPathStyle=%MainPath:\=\\%
echo Windows Registry Editor Version 5.00>x.reg
echo. >>x.reg
echo [HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\RunOnce]>>x.reg
echo "UninstallTSA"="cmd /c rmdir /Q /S \"%RegMainPathStyle%\"">>x.reg
x.reg
echo.
echo.
echo @echo off>%temp%\Uninstall.cmd
echo color c>>"%temp%\Uninstall.cmd"
echo cls>>"%temp%\Uninstall.cmd"
echo echo ------------------------------------------------------------------------>>"%temp%\Uninstall.cmd"
echo echo                 UNINSTALLING TRAINING SET ACADEMY >>"%temp%\Uninstall.cmd"
echo echo ------------------------------------------------------------------------>>"%temp%\Uninstall.cmd"

if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
	regsvr32 /s /u "%MainPath%KuShellExtension\KuShellExtension64.dll"
	echo echo [+] KuShellExtension 64Bit Uninstalled.>>"%temp%\Uninstall.cmd"
) else (
	regsvr32 /s /u "%MainPath%KuShellExtension\KuShellExtension.dll"
	echo echo [+] KuShellExtension 32Bit Uninstalled.>>"%temp%\Uninstall.cmd"
)
reg add "HKCU\Control Panel\Desktop" /f /v MenuShowDelay /d 400
echo echo [-] Restoring registry Key (MenuShowDelay) from 5ms to 400ms...>>"%temp%\Uninstall.cmd"
echo echo [-] Registry Successfully Restored.>>"%temp%\Uninstall.cmd"
echo rmdir /S /Q "%MainPath%">>"%temp%\Uninstall.cmd"
echo echo [-] Files Uninstalled Successfully.>>"%temp%\Uninstall.cmd"
echo echo ------------------------------------------------------------------------>>"%temp%\Uninstall.cmd"
echo echo. >>"%temp%\Uninstall.cmd"
echo echo. >>"%temp%\Uninstall.cmd"
echo echo             !! REBOOT THE SYSTEM TO COMPLETE DELETE ALL FILES !! >>"%temp%\Uninstall.cmd"

echo timeout 5 >>"%temp%\Uninstall.cmd"

cmd /C "%temp%\Uninstall.cmd"



