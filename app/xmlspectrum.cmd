echo %1
java -cp "C:\Program Files (x86)\Saxon\saxon9he.jar" net.sf.saxon.Transform -t -it:main -xsl:xsl/xmlspectrum.xsl sourcepath=%1