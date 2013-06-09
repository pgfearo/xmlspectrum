xquery version "1.0-ml";
module namespace json = "http://marklogic.com/json";
(:~
 : Module Name: Sample Library Module 
 : Module Version: 1.0 
 : Date: October 6, 2011 
 : Copyright: none
 : Proprietary XQuery Extensions Used: None 
 : XQuery Specification: November 2005 
 : Module Overview: This is a sample library module 
 : <ul>
 : <li> Module introductory information</li> 
 : <li> Global variables declared in this module</li> 
 : <li> Modules imported by this module</li> 
 : <li> Summary information for each function defined in the module</li> 
 : <li> Detailed information for each function defined in the module</li> 
 : </ul>
 : @author Jim Fuller
 : @version 1.0
 :)

declare namespace test="test";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare variable $new-line-regex as xs:string := concat('[',codepoints-to-string((13, 10)),']+');

(: Need to backslash escape any double quotes, backslashes, newlines and tabs :)


(:~
 : Escapes json string managing newlines as well
 :
 : @param $s the json to be escaped
 : @return escaped json string
 :)
declare function json:escape($s as xs:string) as xs:string {
  let $s := replace($s, "(\\|"")", "\\$1")
  let $s := replace($s, $new-line-regex, "\\n")
  let $s := replace($s, codepoints-to-string(9), "\\t")
  return $s
};

(: Print the thing that comes after the colon :)
declare function json:print-value($x as element()) as xs:string {
  if (count($x/*) = 0) then
    json:atomize($x)
  else if ($x/@quote = "true") then
    concat('"', json:escape(xdmp:quote($x/node())), '"')
  else
    string-join(('{',
      string-join(for $i in $x/* return json:print-name-value($i), ","),
    '}'), "")
};

(: Print the name and value both :)
declare function json:print-name-value($x as element()) as xs:string? {
  let $name := name($x)
  let $later-in-array := some $s in $x/following-sibling::* satisfies name($s) = $name
  return
  if ($later-in-array) then
    ()
  else 
    ()
};

(:~
 : Transforms an XML element into a JSON string representation.  See http://json.org.
 : 
 : Sample usage:
 : <pre>
 :   xquery version "1.0-ml";
 :   import module namespace json="http://marklogic.com/json" at "json.xqy";
 :   json:serialize(&lt;foo&gt;&lt;bar&gt;kid&lt;/bar&gt;&lt;/foo&gt;)
 : </pre>
 : Sample transformations:
 : 
 : Namespace URIs are ignored.  Namespace prefixes are included in the JSON name.
 :
 : Attributes are ignored, except for the special attribute @array="true" that
 : indicates the JSON serialization should write the node, even if single, as an
 : array, and the attribute @type that can be set to "boolean" or "number" to
 : dictate the value should be written as that type (unquoted).  There's also
 : an @quote attribute that when set to true writes the inner content as text
 : rather than as structured JSON, useful for sending some XHTML over the
 : wire.
 :
 : Text nodes within mixed content are ignored.
 :
 : @param $x Element node to convert
 : @return String holding JSON serialized representation of $x
 :
 : @author Jason Hunter
 : @version 1.0.1
 : 
 : Ported to xquery 1.0-ml; double escaped backslashes in json:escape
:)
declare function json:serialize($x as element())  as xs:string {
  string-join(('{', json:print-name-value($x), '}'), "")
};

