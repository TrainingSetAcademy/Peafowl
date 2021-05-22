@echo off
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
	regsvr32 /s KuShellExtension64.dll
	echo.
	echo KuShellExtension 64Bit installed.
	echo.
) else (
	regsvr32 /s KuShellExtension.dll
	echo.
	echo KuShellExtension 32Bit installed.
	echo.
)


