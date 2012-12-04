XMLSpectrum
-----------

XSLT 2.0 stylesheet adds syntax-highlighting for plain-text XPath, XSLT 2.0 and XSD 1.1 files

   1. Use -s:[stylesheet] to set the stylesheet path
   2. Use -it:main to set the inital template to 'main'
   3. Use XSLT parameter 'sourcepath' to set the path to the file URL to be highlighted
   3. [optional] Use light-theme='yes' XSLT parameter for CSS with white-background theme
   4. [optional] Use css-path='[path]' to set CSS link path and inhibit creation of CSS file

Themes

For the CSS generated, there are 2 color themes a light theme and a dark theme, the default is dark.
To set the light theme, set the 'light-theme' value to 'yes'

Example implementations of XMLSpectrum:

1. highlight-file.xsl    - highlights any source file with URL provided as an XSLT parameter
2. highlight-inline.xsl  - highlights <samp> elements within an HTML file that is the input to the stylesheet

Example running from the command-line using the Saxon-HE XSLT 2.0 processor:

Sample 1.Colorise XSLT and embedded XPath
Sample 2 Colorise non-XML XPath text file "xpath-text.txt"
Sample 3 Colorise XSD 1.1 and embedded XPath
Sample 4 Colorise XSLT, XSD and XPath embedded within <pre lang="x"> elements in an HTML file - use default dark theme
Sample 5 Colorise XSLT, XSD and XPath embedded within <pre lang="x"> elements in an HTML file - use light-theme

1. java -cp "C:\Program Files (x86)\Saxon\saxon9he.jar" net.sf.saxon.Transform -t -it:main -xsl:xsl/highlight-file.xsl sourcepath=../samples/xpathcolorer-x.xsl

2. java -cp "C:\Program Files (x86)\Saxon\saxon9he.jar" net.sf.saxon.Transform -t -it:main -xsl:xsl/highlight-file.xsl sourcepath=../samples/xpath-text.txt light-theme=no

3. java -cp "C:\Program Files (x86)\Saxon\saxon9he.jar" net.sf.saxon.Transform -t -it:main -xsl:xsl/highlight-file.xsl sourcepath=../samples/schema-assert.xsd

4. java -cp "C:\Program Files (x86)\Saxon\saxon9he.jar" net.sf.saxon.Transform -t -xsl:xsl/highlight-inline.xsl -s:samples html-inline-sample.html -o:output/highlighted-inline.html

5. java -cp "C:\Program Files (x86)\Saxon\saxon9he.jar" net.sf.saxon.Transform -t -xsl:xsl/highlight-inline.xsl -s:samples html-inline-sample.html -o:output/highlighted-inline.html light-theme=yes