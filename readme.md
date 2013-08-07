XMLSpectrum
===========================

###Syntax-highlighter and formatter for XQuery, XPath 2.0 - 3.0, XSLT 2.0 and any hosting XML

###Why
1. Many syntax-highlighters rely on generic processors that fail to accurately render XQuery or XPath 2.0, whether it is standalone or embedded in XML, such as XSLT, XSD, Schematron etc. 

2. The 'pretty-print' options of many XML editors can not align XML attributes and their contents properly. This omission is especially critical for the readability of XPath 2.0/3.0.

XMLSpectrum aims to remedy these problems.

###What
XMLSpectrum comprises a **principal XSLT 2.0 stylesheet** and supporting stylesheets designed specially to convert XQuery or XPath and any host XML code (such as XSLT) to HTML with syntax highlighting. There's also a simple **GUI application** XMLSpectrum-FX to provide a convenient front-end for the XSLT (designed for blogging editors).

***Main Roles***

- Syntax highlighter
- Code formatter
- Code hyper-linker

***Built-in language support***

- XQuery 1.0 - 3.0
- XPath 1.0, 2.0, 3.0
- XSLT 1.0, 2.0, 3.0
- XSD 1.1
- XProc
- Schematron

*Sample output for XSLT code:*

![Screenshot](http://www.qutoric.com/xslt/xmlspectrum/images/xsl-light.png)

*Sample output for XQuery code:*

![Screenshot](http://www.qutoric.com/samples/github-xquery.png)

Emphasis on accurate rendering of XQuery and XPath expressions, either within XSLT/XSD or standalone.
By default,  *all* formatting is preserved exactly as-is - with trim and formatting options

##Features

### Syntax Highlighting:

- Processes plain-text or XML-text (complete or otherwise)
- Optionally processes xsl:include and xsl:import referenced XSLT
- Uses standard XSLT 2.0 - no extensions required (tested on Saxon-HE)
- Complete with 6 color themes including: [Solarized](http://ethanschoonover.com/solarized) light/dark, [Tomorrow Night](https://github.com/ChrisKempson/Tomorrow-Theme) or [Roboticket](http://eclipsecolorthemes.org/?view=theme&id=93) color themes - or define your own
- Generates CSS file if required - or embeds CSS styling within content
- Option to use the new Adobe [Source Code Pro](http://blogs.adobe.com/typblography/2012/09/source-code-pro.html) font
- Extensible for any XML format containing embedded XPath

- XQuery XPath Highlighting:
	- State machine for context-aware processing
	- All whitespace formatting preserved
	- Supports latest XPath/XQuery 3.0 additions
- XML Highlighting
	- Supports fragments or complete XML
           - Target namespace prefix can be inferred from 1st element
	- Built-in XML parser (coded in XSLT) keeps all text, as-is
	- CDATA preserved intact and highlighted
	- Language identification (from namespace - if present)
           - CSS styled element/ancestor highlighting - on mouse hover
- XSLT Highlighting
	- Scheme colors help separate instructions from expressions
           - Literal Result Elements have different coloring
	- XPath colored for AVTs or native XPath attributes
	- All formatting preserved
- Other 'Host Language' Highlighting (built-in)
	- XSD 1.1
	- Schematron
	- XProc 1.0
	- Generic XML

### Formatting:

- Formatting including whitespace between attributes and within attribute contents preserved by default
- XML content is shown exactly as in the source - including intact entity references and CDATA sections etc.

_Formatting options - for use when original formatting requires correction_

- [Option] *Indent*
	- Indents XML proportional to the nesting level (Same as standard formatters)
	- Smart attribute formatting (advanced feature)
		- Aligned vertically with indentation consistent with the host element
		- Multi-line content vertically aligned with pre-existing indentation preserved
- [Option] *Auto-Trim*
	- Smart trim of pre-existing indentation (normally combined with the indent option)
           - Records and re-establishes indentation for the following:
		- text nodes
		- xpath comments
		- xml comments
		- xpath expressions
- [Option] *Force-Newline*
	- Inserts line-feeds to format XML elements
           - Preserves content of elements found with mixed-content

### Cross-referencing: 

Recursively processes all XSLT modules from a top-level stylesheet in a multi-file project

- Creates top-level 'map' to all modules
	- Global members listed for each module
	- Map entries hyperlinked to the code definitions
	- Module entries hyperlinked to syntax-highlighted file
	- Global members sorted alphabetically by name
- Adds hyperlinks in code for:
	- *xsl:include* and *xsl:import* hrefs
	- Global Parameters
	- Global Variables
	- Standard Functions
	- User-defined Functions
	- Named Templates
- Clark-notation based linking to ensure integrity of links

##XMLSpectrum in use

_XMLSpectrum-FX_  - A simple Java app included in this repository (latest build at gui-project/xmlspectrum-fx-dist.zip).
This provides a front-end useful for showcasing the XSLT, clipboard and drag and drop functionality make
it useful in its own right for highlighting code snippets for blogging etc. Tested by pasting clipboard contents
into WordPress and Blogger HTML text editors - (Blogger requires a surround div element with an overflow:auto style
attribute.)

![Screenshot](http://www.qutoric.com/xmlspectrum/xmlspectrum-grey-s.png)

###Sample Output from XMLSpectrum transforms

[demo output of Docbook XSLT 2.0 Project](http://qutoric.com/samples/docbook20demo/)

[demo output of DITA XSLT Project](http://qutoric.com/samples/dita-ot-175/)

[XMLSpectrum (highlight-file.xsl entry-file) run on itself](http://qutoric.com/samples/xmlspectrum-code/)

[Transformed web page with embedded code samples](http://qutoric.com/samples/inline/highlighted-inline.html)

[W3C XQuery 3.0 Specification Samples](http://qutoric.com/samples/xquery-3.0cr-samples.html)

[Syntax-highlighted XProc file](http://qutoric.com/samples/xproc/xproccorb.xpl.html)


### Included XSLT solutions

The *xmlspectrum.xsl* and *xq-spectrum.xsl* stylesheets are intended for use by other stylesheets that import these and exploit the main functions: `render`, `show-xquery` and `indent`:

- *highlight-inline.xsl* - transforms XHTML file containing descriptive text and XSLT, XSD or XPath code examples
-  *highlight-file.xsl*     - transforms files containing XSLT,XSD or XPath - can process multi-file XSLT projects

*Solarized Dark theme:*

![Screenshot](http://www.qutoric.com/xslt/xmlspectrum/images/xsd-dark.png)

*Tomorrow-Night theme + Source Code Pro font:*

![Screenshot](http://www.qutoric.com/xslt/xmlspectrum/images/xproc.png)

	
##Usage

For usage instructions, see [xmlspectrum/app/xsl/readme](https://github.com/pgfearo/xmlspectrum/blob/master/app/xsl/readme.md)





































