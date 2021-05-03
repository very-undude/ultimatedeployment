@ECHO OFF

echo Starting windows7.cmd Command Script, press CONTROL+C to interrupt this script

echo.
echo Restoring the Setup environment
move %SYSTEMDRIVE%\setup.uda %SYSTEMDRIVE%\setup.exe
move %SYSTEMDRIVE%\sources\setup.uda %SYSTEMDRIVE%\sources\setup.exe


SET REGEXE=%SYSTEMDRIVE%\windows\system32\reg.exe

echo Getting UDA Template info from registry

for /f "tokens=2*" %%A IN ('%REGEXE% query HKLM\SYSTEM\CurrentControlSet\Control /f "SystemStartOptions" ^| find "UDA="') DO SET SSO=%%B

echo.
echo SYSTEMSTARTOPTIONS=%SSO%

echo.
for /f "tokens=1,2,3,4,5,6,7,8,9,10" %%A IN ( "%SSO%" ) DO (
  echo %%A | FIND "UDA=" && echo FOUND %%A && SET UDAOPTION=%%A
  echo %%B | FIND "UDA=" && echo FOUND %%B && SET UDAOPTION=%%B
  echo %%C | FIND "UDA=" && echo FOUND %%C && SET UDAOPTION=%%C
  echo %%D | FIND "UDA=" && echo FOUND %%D && SET UDAOPTION=%%D
  echo %%E | FIND "UDA=" && echo FOUND %%E && SET UDAOPTION=%%E
  echo %%F | FIND "UDA=" && echo FOUND %%F && SET UDAOPTION=%%F
  echo %%G | FIND "UDA=" && echo FOUND %%G && SET UDAOPTION=%%G
  echo %%H | FIND "UDA=" && echo FOUND %%H && SET UDAOPTION=%%H
  echo %%I | FIND "UDA=" && echo FOUND %%I && SET UDAOPTION=%%I
  echo %%J | FIND "UDA=" && echo FOUND %%J && SET UDAOPTION=%%J
)
echo.
echo UDAOPTION=%UDAOPTION%

for /f "delims=:= tokens=1,2,3,4,5" %%A IN ("%UDAOPTION%") DO (
  SET UDA_IPADDR=%%B
  SET UDA_TEMPLATE=%%C
  SET UDA_SUBTEMPLATE=%%D
  SET UDA_DRIVER=%%E
)

echo UDA Template info is:
echo.
echo UDA_IPADDR:       %UDA_IPADDR%
echo UDA_TEMPLATE:     %UDA_TEMPLATE%
echo UDA_SUBTEMPLATE:  %UDA_SUBTEMPLATE%
echo UDA_DRIVER:       %UDA_DRIVER%


SET UDADIR=%SYSTEMDRIVE%\sources\uda
SET DRVLOAD=%SYSTEMDRIVE%\windows\system32\drvload.exe
SET WPEINIT=%SYSTEMDRIVE%\windows\system32\wpeinit.exe
SET IPCONFIG=%SYSTEMDRIVE%\windows\system32\ipconfig.exe
SET NETEXE=%SYSTEMDRIVE%\windows\system32\net.exe
SET INSTALLDRIVE=I

SET PRESCRIPT=%INSTALLDRIVE%:\pxelinux.cfg\templates\%UDA_TEMPLATE%\%UDA_SUBTEMPLATE%.cmd

echo PRESCRIPT=%PRESCRIPT%

cd %UDADIR%

if "%UDA_DRIVER%"=="" goto tryall
FOR /F "eol=; tokens=1,2,3,4,5" %%A in ( %SYSTEMDRIVE%\sources\uda\drivers.txt ) DO (
  echo Driver=%%A Number=%%B file1=%%C file2=%%D Drvload=%%E
  if not "%%A"=="%UDA_DRIVER%" goto skipload
    echo Loading driver %%A
    cmd /c %%E %%C %%D && goto doneloading 
    echo Could not succesfully load driver %UDA_DRIVER%, trying all instead
    goto tryall
:skipload
    echo Skipping load of driver %%A
)

:tryall
echo Trying all network drivers
FOR /F "eol=; tokens=1,2,3,4,5" %%A in ( %SYSTEMDRIVE%\sources\uda\drivers.txt ) DO (
    echo Driver=%%A Number=%%B Inffile=%%C Ssysfile=%%D DRVLOAD=%%E
    cmd /c %%E %%C %%D && goto doneloading
    echo Could not succesfully load driver %%A, trying next one
)

echo No imported driver loaded, trying without
rem goto manual
:doneloading

echo.
echo Starting the network
%WPEINIT%
%IPCONFIG% /renew
if not %ERRORLEVEL%==0 goto manual

echo.
echo.
echo Mapping the network share
%NETEXE% use %INSTALLDRIVE%: \\%UDA_IPADDR%\REMINST /user:uda Uda12345
IF NOT EXIST %INSTALLDRIVE%: %NETEXE% use %INSTALLDRIVE%: \\%UDA_IPADDR%\REMINST

echo.
echo Handing over command to the remote template script and not coming back!
if EXIST %PRESCRIPT% %PRESCRIPT% %UDA_IPADDR% %UDA_TEMPLATE% %UDA_SUBTEMPLATE%

pause
:manual
echo.
echo Could not succesfully load a network driver, please try manually
echo you should do something like:
echo.
echo drvload x:\sources\uda\netamd.inf
echo wpeinit
echo net use i: \\%UDA_IPADDR%\REMINST
echo %PRESCRIPT% %UDA_IPADDR% %UDA_TEMPLATE% %UDA_SUBTEMPLATE%
echo.

pause
