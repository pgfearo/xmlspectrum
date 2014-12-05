$shome = get-childitem -path env:SAXON_HOME
$SAXONJAR="$shome/saxon9he.jar"
# entry point is XMLSpectrum's highlight-file xsl stylesheet:
$XMLSPECTRUM="$PSScriptRoot\..\xsl/highlight-file.xsl"
echo jar path: $SAXONJAR
iex "java -jar $SAXONJAR"

