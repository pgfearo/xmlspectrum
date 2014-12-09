@echo off
REM script for calling xmlspectrum with command line such as: xmlspec sample.xml auto-trim=yes indent=2
REM loop is required to combine name/value pairs with an '=' as args are split as they are passed to CMD
set source=%~f1
set xslpath=%~dp0\..\xsl\highlight-file.xsl
set opath=%CD%\xms-out
set ofpath=%~nx1.html
set fullofpath=%opath%\%ofpath%
shift
set iter=0
set prev=
set cmd=
set current=%1
:loop
shift
if [%1]==[] goto afterloop
set prev=%current%
set current=%1
set /a "iter=%iter%+1"
set /a "mod=%iter%%%2
if [%mod%]==[1] set cmd=%cmd% %prev%=%current%
goto loop
:afterloop
echo args:  %cmd%
java -cp "%SAXON_HOME%\saxon9he.jar" net.sf.saxon.Transform -xsl:%xslpath% -it:main sourcepath=%source% output-path=%opath%%cmd%
start %fullofpath%
