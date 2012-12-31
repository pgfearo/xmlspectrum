XMLSpectrum
-----------

XSLT 2.0 stylesheet that adds syntax-highlighting to plain-text XPath, XSLT 2.0 and XSD 1.1 files
An indentation option is available for XSLT, XSD or other XML vocabularies (line feeds not added)

Command line options required when using the Saxon Processor

   1. -s:[stylesheet] sets the stylesheet path/URI
   2. -it:main sets the inital template to 'main' (highlight-file.xsl only)
   3. -o:[op-destination] sets the output destination path (highlight-inline.xsl only)

XSLT parameters for both highlight-file and highlight-inline (unless specified otherwise)
Parameter Syntax: [param-name]=[param-value]

   1. 'sourcepath'  string sets the path to the file URL to be highlighted
   2. 'light-theme' [yes|no] sets generated CSS background color theme - default:no
   3. 'indent'      integer sets number of indent chars for each nest-level - default:-1
   4. 'auto-trim'   [yes|no] trims all left-hand indentation characters (use with 'indent')
   5. 'css-path'    optional. string sets custom URL for external CSS link element in output HTML
   6. 'output-path' optional. sets the directory path to send output files to (highlight-file.xsl only)

Themes

For the CSS generated, there are 2 color themes a light theme and a dark theme, the default is dark.
To set the light theme, set the 'light-theme' value to 'yes'


Examples running from the command-line using the Saxon-HE XSLT 2.0 processor:

Sample 1.Colorise XSLT 2.0 file
Sample 2 Colorise non-XML XPath text file "xpath-text.txt"
Sample 3 Colorise XSD 1.1 snippet file
Sample 4 Colorise and indent XSLT file (the xmlspectrum source code) - use default dark theme
Sample 5 Colorise and reformat highlight-file.xsl- use default light theme, recurse imports, creat toc and add hyper-links
Sample 6 Colorise and reformat docbook XSLT 2.0 from an absolute path - use default light theme, recurse imports, creat toc and add hyper-links
Sample 7 Colorise XSLT, XSD and XPath embedded within <pre lang="x"> elements in an HTML file - use default dark theme
Sample 8 Colorise XSLT, XSD and XPath embedded within <pre lang="x"> elements in an HTML file - use light-theme
Sample 9 Colorise and reformat XSLT file (the xmlspectrum source code) - use default dark theme
Sample 10 Colorise and reformat a blog entry containing XSLT, XSD and XPath - use default dark theme

1. java -cp "C:\Saxon\saxon9he.jar" net.sf.saxon.Transform -t -it:main -xsl:xsl/highlight-file.xsl sourcepath=../samples/xpathcolorer-x.xsl

2. java -cp "C:\Saxon\saxon9he.jar" net.sf.saxon.Transform -t -it:main -xsl:xsl/highlight-file.xsl sourcepath=../samples/xpath-text.txt light-theme=no

3. java -cp "C:\Saxon\saxon9he.jar" net.sf.saxon.Transform -t -it:main -xsl:xsl/highlight-file.xsl sourcepath=../samples/schema-assert.xsd

4. java -cp "C:\Saxon\saxon9he.jar" net.sf.saxon.Transform -t -it:main -xsl:xsl/highlight-file.xsl sourcepath=../xsl/xmlspectrum.xsl indent=2

5. java -cp "C:\Saxon\saxon9he.jar" net.sf.saxon.Transform -t -it:main -xsl:xsl/highlight-file.xsl sourcepath=../xsl/highlight-file.xsl indent=2 `
   link-names=yes light-theme=yes output-path="new-output"

6. java -cp "C:\Saxon\saxon9he.jar" net.sf.saxon.Transform -t -it:main -xsl:xsl/highlight-file.xsl`
   sourcepath="C:\docbook-xslt2-2.0.0\xslt\base\html\docbook.xsl" indent=0 link-names=yes

7. java -cp "C:\Saxon\saxon9he.jar" net.sf.saxon.Transform -t -xsl:xsl/highlight-inline.xsl -s:samples/html-inline-sample.html -o:output/highlighted-inline.html

8. java -cp "C:\Saxon\saxon9he.jar" net.sf.saxon.Transform -t -xsl:xsl/highlight-inline.xsl -s:samples/html-inline-sample.html -o:output/highlighted-inline.html light-theme=yes

9. java -cp "C:\Saxon\saxon9he.jar" net.sf.saxon.Transform -t -xsl:xsl/highlight-inline.xsl -s:samples/badly-formatted-extract.html indent=2 auto-trim=yes -o:output/reformatted-extract.html

10. java -cp "C:\Saxon\saxon9he.jar" net.sf.saxon.Transform -t -xsl:xsl/highlight-inline.xsl -s:samples/blog-sample.html indent=2 -o:output/blog-sample.html