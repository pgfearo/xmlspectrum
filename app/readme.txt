XMLSpectrum
-----------

XSLT 2.0 stylesheet adds syntax-highlighting for plain-text XPath, XSLT 2.0 and XSD 1.1 files

   1. Use -s:[stylesheet] to set the stylesheet path
   2. Use -it:main to set the inital template to 'main'
   3. [optional] Use light-theme='yes' xsl parameter for CSS with white-background theme
   4. [optional] Use css-path='[path]' to set CSS link path and inhibit creation of CSS file

2 output

For the CSS generated, there are 2 color themses a light theme and a dark theme, the default is dark.
To set the light theme, set the 'light-theme' value to 'yes'

Example running from the command-line using the Saxon-HE XSLT 2.0 processor:

Sample 1.Colorise XSLT and embedded XPath
Sample 2 Colorise non-XML XPath text file "xpath-text.txt"
Sample 3 Colorise XSD 1.1 and embedded XPath


java -cp "C:\Program Files (x86)\Saxon\saxon9he.jar" net.sf.saxon.Transform -t -it:main -xsl:xsl/xmlspectrum.xsl sourcepath=../samples/xpathcolorer-x.xsl

java -cp "C:\Program Files (x86)\Saxon\saxon9he.jar" net.sf.saxon.Transform -t -it:main -xsl:xsl/xmlspectrum.xsl sourcepath=../samples/xpath-text.txt light-theme=no

java -cp "C:\Program Files (x86)\Saxon\saxon9he.jar" net.sf.saxon.Transform -t -it:main -xsl:xsl/xmlspectrum.xsl sourcepath=../samples/schema-assert.xsd