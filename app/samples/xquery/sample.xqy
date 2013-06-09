(:
: Module Name: Sample
: Module Version: 1.0
: Date: October 6, 2011
: Copyright: None
: Proprietary 
: Extensions: None
: 
: XQuery 
: Specification : XQuery v1.0
: Module Overview: Example for xqdoc processing
:)
xquery version "1.0";


(:~ This module provides a sample main module authored according 
: to the proposed XQuery Style Guidelines 
: @author John Snelson
: @since January 17, 2006 
: @version 1.0 :)
import module namespace math="http://xqdoc.org/sample-math-lib" at "sample-math-lib.xqy";

(:~ so we have XPath 2.0 as default function namespace :)
declare default function namespace "http://www.w3.org/2005/xpath-functions"; 
(:~ this module outputs html  :)
declare default element namespace "http://www.w3.org/1999/xhtml";

(:~ This variable contains the first variable to process. :)
declare variable $operand-one as xs:integer external;

(:~ This variable contains the second integer to process. :)
declare variable $operand-two as xs:integer external;

(:~
: Generates title for html page
: @returns string value for title
:)
declare function local:title() as xs:string{
'A Sample XQuery File'
};

<html> 
<head>
  <title>{local:title()}</title> 
</head>
<body> 
  <p>{$operand1 + $operand2}</p> 
</body>
</html>
