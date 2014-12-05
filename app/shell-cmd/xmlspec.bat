@echo off
REM script for calling xmlspectrum with command line such as: xmlspec sample.xml auto-trim=yes indent=2
REM loop is required to combine name/value pairs with an '=' as args are split as they are passed to CMD
set source=%1
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
echo source: %source%
echo args:  %cmd%
java -cp "C:\Saxon\saxon9he.jar" net.sf.saxon.Transform -xsl:C:\Users\Philip\Documents\GitHub\xmlspectrum\app\xsl\highlight-file.xsl -it:main sourcepath=%CD%\%source% output-path=c:\temp\output%cmd%
