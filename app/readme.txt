XMLSpectrum
-----------

XSLT 2.0 stylesheet that adds syntax-highlighting to plain-text XPath, XSLT 2.0 and XSD 1.1 files
An indentation option is available for XSLT, XSD or other XML vocabularies (line feeds not added)

Command line options required when using the Saxon Processor

   1. Use -s:[stylesheet] to set the stylesheet path
   2. Use -it:main to set the inital template to 'main'

XSLT parameters when using highlight-file.xsl implementation
Syntax: [param-name]=[param-value]

   3. 'sourcepath' sets the path to the file URL to be highlighted
   4. 'light-theme' [yes|no] Sets generated CSS background color theme - default:no
   5. 'indent'      [yes|no] Adds indentation - default:no
   5. 'css-path'  set URL for external CSS link element in output HTML

Themes

For the CSS generated, there are 2 color themes a light theme and a dark theme, the default is dark.
To set the light theme, set the 'light-theme' value to 'yes'

Example implementations of XMLSpectrum:

1. highlight-file.xsl    - highlights any source file with URL provided as an XSLT parameter
2. highlight-inline.xsl  - highlights <samp> elements within an HTML file that is the input to the stylesheet

Examples running from the command-line using the Saxon-HE XSLT 2.0 processor:

Sample 1.Colorise XSLT and embedded XPath
Sample 2 Colorise non-XML XPath text file "xpath-text.txt"
Sample 3 Colorise XSD 1.1 and embedded XPath
Sample 4 Colorise XSLT, XSD and XPath embedded within <pre lang="x"> elements in an HTML file - use default dark theme
Sample 5 Colorise XSLT, XSD and XPath embedded within <pre lang="x"> elements in an HTML file - use light-theme
Sample 6 Colorise and indent XSLT file (the xmlspectrum source code) - use default dark theme
Sample 7 Colorise and reformat XSLT file (the xmlspectrum source code) - use default dark theme
Sample 8 Colorise and reformat a blog entry containing XSLT, XSD and XPath - use default dark theme
Sample 9 Colorise and reformat highlight-file.xsl- use default light theme, recurse imports, creat toc and add hyper-links
Sample 10 Colorise and reformat docbook XSLT 2.0 from an absolute path - use default light theme, recurse imports, creat toc and add hyper-links

1. java -cp "C:\Program Files (x86)\Saxon\saxon9he.jar" net.sf.saxon.Transform -t -it:main -xsl:xsl/highlight-file.xsl sourcepath=../samples/xpathcolorer-x.xsl

2. java -cp "C:\Program Files (x86)\Saxon\saxon9he.jar" net.sf.saxon.Transform -t -it:main -xsl:xsl/highlight-file.xsl sourcepath=../samples/xpath-text.txt light-theme=no

3. java -cp "C:\Program Files (x86)\Saxon\saxon9he.jar" net.sf.saxon.Transform -t -it:main -xsl:xsl/highlight-file.xsl sourcepath=../samples/schema-assert.xsd

4. java -cp "C:\Program Files (x86)\Saxon\saxon9he.jar" net.sf.saxon.Transform -t -xsl:xsl/highlight-inline.xsl -s:samples/html-inline-sample.html -o:output/highlighted-inline.html

5. java -cp "C:\Program Files (x86)\Saxon\saxon9he.jar" net.sf.saxon.Transform -t -xsl:xsl/highlight-inline.xsl -s:samples/html-inline-sample.html -o:output/highlighted-inline.html light-theme=yes

6. java -cp "C:\Program Files (x86)\Saxon\saxon9he.jar" net.sf.saxon.Transform -t -it:main -xsl:xsl/highlight-file.xsl sourcepath=../xsl/xmlspectrum.xsl indent=2

7. java -cp "C:\Program Files (x86)\Saxon\saxon9he.jar" net.sf.saxon.Transform -t -xsl:xsl/highlight-inline.xsl -s:samples/badly-formatted-extract.html indent=2 auto-trim=yes -o:output/reformatted-extract.html

8. java -cp "C:\Program Files (x86)\Saxon\saxon9he.jar" net.sf.saxon.Transform -t -xsl:xsl/highlight-inline.xsl -s:samples/blog-sample.html indent=2 -o:output/blog-sample.html

9. java -cp "C:\Program Files (x86)\Saxon\saxon9he.jar" net.sf.saxon.Transform -t -it:main -xsl:xsl/highlight-file.xsl sourcepath=../xsl/highlight-file.xsl indent=2 link-names=yes light-theme=yes

10. C:\Users\Philip\Documents\xmlspectrum\app>java -cp "C:\Program Files (x86)\Saxon\saxon9he.jar" net.sf.saxon.Transform -t
 -it:main -xsl:xsl/highlight-file.xsl sourcepath="C:\Users\Philip\Documents\docbook-xslt2-2.0.0\xslt\base\html\docbook".
xsl indent=0 link-names=yes