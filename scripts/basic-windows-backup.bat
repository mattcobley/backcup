::@echo off
:: The @echo off turns off printing all the commands by default.  The @ prevents that command from being printed.
:: Can use @ to prevent printing specific commands if this is NOT desired for the whole file.
:: Can use REM or :: to comment out in batch files
:: Robocopy <from> <to>  *.* /e /b /copyall /r:5 /w:5 /purge
:: The purge option removes files at the destination when they are deleted at the source.
:: A good link for the other options was http://ubuntuforums.org/showthread.php?t=831380 and the last comment July 20th 2008.

::Note that the first section here checks if a backup is already running, and does not run if it is.  This prevent multiple versions ::of the program running at the same time, as Task Scheduler just kicks off the cmd process and then ignores the batch file.
::StackOverflow article link for this: http://stackoverflow.com/questions/162291/how-to-check-if-a-process-is-running-via-a-batch-::script

::tasklist /FI "IMAGENAME eq Robocopy.exe" 2>NUL|find /I /N "Robocopy.exe">NUL
::if "%ERRORLEVEL%"=="0" exit

::This only runs if the backup is not already running:

::This sets it up so that we can redirect the output to a log file for future reference:
For /f "tokens=2-4 delims=//" %%a in ('date /t') do (set mydate=%%c-%%a-%%b)
For /f "tokens=1-2 delims=/:" %%a in ("%TIME%") do (set mytime=%%a%%b)
::Note that I commented this out because for some reason it did not output the day.  In it's place, I've used %DATE:/=% which was another suggestion

set targetpath=C:\backup-test\target\matt\06042022_2232
::%DATE:/=%_%mytime%
if not exist %targetpath% mkdir %targetpath%

set sourcepath=C:\backup-test\source
set logfile=.\robocopy-backup-log-%DATE:/=%_%mytime%.log

Robocopy %sourcepath% %targetpath% /MIR /b /r:3 /w:1 /xo /fft /v /z > %logfile%

:: Used calc at https://yellowtriangle.wordpress.com/2012/06/28/bandwidth-throttling-with-robocopy/ to work out IPG based on 50000Kbps (50Mbps) line, and throttling at 20Mbps. Worked out at ipg of 15, but was REALLY slow, so removed the switch again.

exit