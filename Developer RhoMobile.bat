@ECHO off
REM Type 'help color' in a command window to view color options
color 1B
(title Developer RhoMobile)

REM Update the value with your Rhodes workspace path
(set rhoAppPath=C:\Users\Student\workspace)

REM Update the value with your RhoConnect project
(set rhoConnectProject=AdventureWorksProvider)

REM Update the path to your Command Prompt with Ruby
REM To locate, right click on the Command Prompt with Ruby link in the Ruby installation on the Start Menu
REM Choose Properties and copy the path from the target
(set rubyCmd=C:\Ruby193\bin\setrbvars.bat)

REM Present options to the user
:start
  ECHO Some options may take up to 1-2 minutes to complete.
  ECHO.
  ECHO    0 - Exit
  ECHO    1 - Start RhoConnect server
  ECHO    2 - Stop RhoConnect server and exit
  ECHO    4 - Open RhoConnect admin console
  ECHO    5 - Open Command Prompt with Ruby
  ECHO    7 - Build Android APK
  ECHO    8 - Start RhoConnect only for Build Errors
  ECHO.

  REM Prompt for a selection and handle it
  set /p choice="Enter your choice: "
    if "%choice%"=="0" exit
    if "%choice%"=="1" goto startserver
    if "%choice%"=="2" goto stopserver
    if "%choice%"=="4" goto openconsole
    if "%choice%"=="5" goto openprompt
    if "%choice%"=="7" goto buildapk
    if "%choice%"=="8" goto startonlyrho
  ECHO Invalid choice: %choice%
  ECHO.
  pause
  CLS
goto start

REM Load a Command Prompt window with Ruby, move to the applicable directory, and run the appropriate commands
:startserver
  CLS
  ECHO Starting the RhoConnect server:
  ECHO.
  ECHO    Starting Redis then...
    REM Exit command window after doing command because it launches in a new window
    START /MIN CMD /E:ON /K %rubyCmd% ^
               ^& cd %rhoAppPath%\%rhoConnectProject% ^
               ^& rhoconnect redis-start ^
               ^& exit
  
  ECHO    Starting RhoConnect...
    START /MIN CMD /E:ON /K %rubyCmd% ^
               ^& cd %rhoAppPath%\%rhoConnectProject% ^
               ^& rhoconnect start ^
               ^& exit
  
  ECHO.
  ECHO.
goto start

REM Load a Command Prompt window with Ruby, move to the applicable directory, and run the appropriate commands
:openconsole
  CLS
  ECHO Opening the RhoConnect admin console...
  ECHO If the browser page does not load, RhoConnect has not finished starting yet.
  ECHO Try refreshing the browser page if that is the case or check for errors.
    START /MIN CMD /E:ON /K %rubyCmd% ^
               ^& cd %rhoAppPath%\%rhoConnectProject% ^
               ^& rhoconnect web ^
               ^& exit

  ECHO.
  ECHO.
goto start

REM Load a Command Prompt window with Ruby, move to the applicable directory
:openprompt
  CLS
  ECHO Opening a Command Prompt with Ruby...
    START CMD /E:ON /K %rubyCmd% ^
          ^& cd %rhoAppPath%\%rhoConnectProject%

  ECHO.
  ECHO.
goto start

REM Load a Command Prompt window with Ruby, move to the applicable directory, and run the appropriate commands
:stopserver
  CLS
  ECHO Stopping the RhoConnect server:
  ECHO    Stopping RhoConnect then...
    START /MIN CMD /E:ON /K %rubyCmd% ^
               ^& cd %rhoAppPath%\%rhoConnectProject% ^
               ^& rhoconnect stop ^
               ^& exit

  ECHO    Stopping Redis...
    START /MIN CMD /E:ON /K %rubyCmd% ^
               ^& cd %rhoAppPath%\%rhoConnectProject% ^
               ^& rhoconnect redis-stop ^
               ^& exit

exit

REM Load a Command Prompt window, move to the Rhodes app directory, build
:buildapk
  CLS
  set /p app="Project name in workspace: "
  ECHO APK location: %rhoAppPath%\%app%\bin\target\android\
  ECHO Starting APK build...
    START CMD /E:ON /K cd %rhoAppPath%\%app% ^
    ^& rake device:android:production

  ECHO.
  ECHO.
goto start

REM Load a Command Prompt window with Ruby, move to the applicable directory, and run the appropriate commands
:startonlyrho
  CLS
  ECHO Starting the RhoConnect only:
  ECHO.
  ECHO    Starting RhoConnect...
    REM Remove ' ^& exit' from end if debugging to display build errors
    REM The command window closes immediately after encountering them otherwise
    START /MIN CMD /E:ON /K %rubyCmd% ^
               ^& cd %rhoAppPath%\%rhoConnectProject% ^
               ^& rhoconnect start

  ECHO.
  ECHO.
goto start
