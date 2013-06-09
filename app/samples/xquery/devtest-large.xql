(:
: Module Name: Sample
: Module Version: 1.0
: Date: October 6, 2011
:)
xquery version "1.0";



(:~ so we have XPath 2.0 as default (:function namespace:) :)
declare default function namespace "http://www.w3.org/2005/xpath-functions"; 
(:~ this module outputs html  :)
declare default element namespace "http://www.w3.org/1999/xhtml";

(:~ This variable contains the first variable to process. :)
declare variable $operand-one as xs:integer external;

(:~ This variable contains the second integer to process. :)
declare variable $operand-two as xs:integer external;

(:~
: Generates title for html page
: <ul class="list">
:    <li>
        A list item and keywords 'and', 'some' + operators
:    </li>
: @returns string value for title
:)
declare function local:title() as xs:string{
'A Sample XQuery File'
};


declare function local:mytest() as xs:boolean
{
if (empty($operand-one))
    then false()
 else if ($operand-two eq 2)
    then
    $operand-two eq 3
 else false()
};

if (true()) then
<html attr="simple test" test="my {awkward/difficult} answer" class="{/abc[@name]}"> 
<head>
  <!-- this is ok -->
  <title>{local:title()}<bold>{local:mytest(), <nested>what {$operand-two, <nested/>} difficulty </nested>}</bold> mixed text</title>
  <?abc processing> instruction?>
</head>
<body> 
  <p>{$operand-one + $operand-two}</p>
  <p><![CDATA[this is <testing things> somewhat {testing}and div mod could be tricky/awkward]]></p>
</body>
</html>
else
(:
: Module Name: Sample
: Module Version: 1.0
: Date: October 6, 2011
:)
xquery version "1.0";



(:~ so we have XPath 2.0 as default (:function namespace:) :)
declare default function namespace "http://www.w3.org/2005/xpath-functions"; 
(:~ this module outputs html  :)
declare default element namespace "http://www.w3.org/1999/xhtml";

(:~ This variable contains the first variable to process. :)
declare variable $operand-one as xs:integer external;

(:~ This variable contains the second integer to process. :)
declare variable $operand-two as xs:integer external;

(:~
: Generates title for html page
: <ul class="list">
:    <li>
        A list item and keywords 'and', 'some' + operators
:    </li>
: @returns string value for title
:)
declare function local:title() as xs:string{
'A Sample XQuery File'
};


declare function local:mytest() as xs:boolean
{
if (empty($operand-one))
    then false()
 else if ($operand-two eq 2)
    then
    $operand-two eq 3
 else false()
};

if (true()) then
<html attr="simple test" test="my {awkward/difficult} answer" class="{/abc[@name]}"> 
<head>
  <!-- this is ok -->
  <title>{local:title()}<bold>{local:mytest(), <nested>what {$operand-two, <nested/>} difficulty </nested>}</bold> mixed text</title>
  <?abc processing> instruction?>
</head>
<body> 
  <p>{$operand-one + $operand-two}</p>
  <p><![CDATA[this is <testing things> somewhat {testing}and div mod could be tricky/awkward]]></p>
</body>
</html>
else
(:
: Module Name: Sample
: Module Version: 1.0
: Date: October 6, 2011
:)
xquery version "1.0";



(:~ so we have XPath 2.0 as default (:function namespace:) :)
declare default function namespace "http://www.w3.org/2005/xpath-functions"; 
(:~ this module outputs html  :)
declare default element namespace "http://www.w3.org/1999/xhtml";

(:~ This variable contains the first variable to process. :)
declare variable $operand-one as xs:integer external;

(:~ This variable contains the second integer to process. :)
declare variable $operand-two as xs:integer external;

(:~
: Generates title for html page
: <ul class="list">
:    <li>
        A list item and keywords 'and', 'some' + operators
:    </li>
: @returns string value for title
:)
declare function local:title() as xs:string{
'A Sample XQuery File'
};


declare function local:mytest() as xs:boolean
{
if (empty($operand-one))
    then false()
 else if ($operand-two eq 2)
    then
    $operand-two eq 3
 else false()
};

if (true()) then
<html attr="simple test" test="my {awkward/difficult} answer" class="{/abc[@name]}"> 
<head>
  <!-- this is ok -->
  <title>{local:title()}<bold>{local:mytest(), <nested>what {$operand-two, <nested/>} difficulty </nested>}</bold> mixed text</title>
  <?abc processing> instruction?>
</head>
<body> 
  <p>{$operand-one + $operand-two}</p>
  <p><![CDATA[this is <testing things> somewhat {testing}and div mod could be tricky/awkward]]></p>
</body>
</html>
else
(:
: Module Name: Sample
: Module Version: 1.0
: Date: October 6, 2011
:)
xquery version "1.0";



(:~ so we have XPath 2.0 as default (:function namespace:) :)
declare default function namespace "http://www.w3.org/2005/xpath-functions"; 
(:~ this module outputs html  :)
declare default element namespace "http://www.w3.org/1999/xhtml";

(:~ This variable contains the first variable to process. :)
declare variable $operand-one as xs:integer external;

(:~ This variable contains the second integer to process. :)
declare variable $operand-two as xs:integer external;

(:~
: Generates title for html page
: <ul class="list">
:    <li>
        A list item and keywords 'and', 'some' + operators
:    </li>
: @returns string value for title
:)
declare function local:title() as xs:string{
'A Sample XQuery File'
};


declare function local:mytest() as xs:boolean
{
if (empty($operand-one))
    then false()
 else if ($operand-two eq 2)
    then
    $operand-two eq 3
 else false()
};

if (true()) then
<html attr="simple test" test="my {awkward/difficult} answer" class="{/abc[@name]}"> 
<head>
  <!-- this is ok -->
  <title>{local:title()}<bold>{local:mytest(), <nested>what {$operand-two, <nested/>} difficulty </nested>}</bold> mixed text</title>
  <?abc processing> instruction?>
</head>
<body> 
  <p>{$operand-one + $operand-two}</p>
  <p><![CDATA[this is <testing things> somewhat {testing}and div mod could be tricky/awkward]]></p>
</body>
</html>
else
(:
: Module Name: Sample
: Module Version: 1.0
: Date: October 6, 2011
:)
xquery version "1.0";



(:~ so we have XPath 2.0 as default (:function namespace:) :)
declare default function namespace "http://www.w3.org/2005/xpath-functions"; 
(:~ this module outputs html  :)
declare default element namespace "http://www.w3.org/1999/xhtml";

(:~ This variable contains the first variable to process. :)
declare variable $operand-one as xs:integer external;

(:~ This variable contains the second integer to process. :)
declare variable $operand-two as xs:integer external;

(:~
: Generates title for html page
: <ul class="list">
:    <li>
        A list item and keywords 'and', 'some' + operators
:    </li>
: @returns string value for title
:)
declare function local:title() as xs:string{
'A Sample XQuery File'
};


declare function local:mytest() as xs:boolean
{
if (empty($operand-one))
    then false()
 else if ($operand-two eq 2)
    then
    $operand-two eq 3
 else false()
};

if (true()) then
<html attr="simple test" test="my {awkward/difficult} answer" class="{/abc[@name]}"> 
<head>
  <!-- this is ok -->
  <title>{local:title()}<bold>{local:mytest(), <nested>what {$operand-two, <nested/>} difficulty </nested>}</bold> mixed text</title>
  <?abc processing> instruction?>
</head>
<body> 
  <p>{$operand-one + $operand-two}</p>
  <p><![CDATA[this is <testing things> somewhat {testing}and div mod could be tricky/awkward]]></p>
</body>
</html>
else
(:
: Module Name: Sample
: Module Version: 1.0
: Date: October 6, 2011
:)
xquery version "1.0";



(:~ so we have XPath 2.0 as default (:function namespace:) :)
declare default function namespace "http://www.w3.org/2005/xpath-functions"; 
(:~ this module outputs html  :)
declare default element namespace "http://www.w3.org/1999/xhtml";

(:~ This variable contains the first variable to process. :)
declare variable $operand-one as xs:integer external;

(:~ This variable contains the second integer to process. :)
declare variable $operand-two as xs:integer external;

(:~
: Generates title for html page
: <ul class="list">
:    <li>
        A list item and keywords 'and', 'some' + operators
:    </li>
: @returns string value for title
:)
declare function local:title() as xs:string{
'A Sample XQuery File'
};


declare function local:mytest() as xs:boolean
{
if (empty($operand-one))
    then false()
 else if ($operand-two eq 2)
    then
    $operand-two eq 3
 else false()
};

if (true()) then
<html attr="simple test" test="my {awkward/difficult} answer" class="{/abc[@name]}"> 
<head>
  <!-- this is ok -->
  <title>{local:title()}<bold>{local:mytest(), <nested>what {$operand-two, <nested/>} difficulty </nested>}</bold> mixed text</title>
  <?abc processing> instruction?>
</head>
<body> 
  <p>{$operand-one + $operand-two}</p>
  <p><![CDATA[this is <testing things> somewhat {testing}and div mod could be tricky/awkward]]></p>
</body>
</html>
else
(:
: Module Name: Sample
: Module Version: 1.0
: Date: October 6, 2011
:)
xquery version "1.0";



(:~ so we have XPath 2.0 as default (:function namespace:) :)
declare default function namespace "http://www.w3.org/2005/xpath-functions"; 
(:~ this module outputs html  :)
declare default element namespace "http://www.w3.org/1999/xhtml";

(:~ This variable contains the first variable to process. :)
declare variable $operand-one as xs:integer external;

(:~ This variable contains the second integer to process. :)
declare variable $operand-two as xs:integer external;

(:~
: Generates title for html page
: <ul class="list">
:    <li>
        A list item and keywords 'and', 'some' + operators
:    </li>
: @returns string value for title
:)
declare function local:title() as xs:string{
'A Sample XQuery File'
};


declare function local:mytest() as xs:boolean
{
if (empty($operand-one))
    then false()
 else if ($operand-two eq 2)
    then
    $operand-two eq 3
 else false()
};

if (true()) then
<html attr="simple test" test="my {awkward/difficult} answer" class="{/abc[@name]}"> 
<head>
  <!-- this is ok -->
  <title>{local:title()}<bold>{local:mytest(), <nested>what {$operand-two, <nested/>} difficulty </nested>}</bold> mixed text</title>
  <?abc processing> instruction?>
</head>
<body> 
  <p>{$operand-one + $operand-two}</p>
  <p><![CDATA[this is <testing things> somewhat {testing}and div mod could be tricky/awkward]]></p>
</body>
</html>
else
(:
: Module Name: Sample
: Module Version: 1.0
: Date: October 6, 2011
:)
xquery version "1.0";



(:~ so we have XPath 2.0 as default (:function namespace:) :)
declare default function namespace "http://www.w3.org/2005/xpath-functions"; 
(:~ this module outputs html  :)
declare default element namespace "http://www.w3.org/1999/xhtml";

(:~ This variable contains the first variable to process. :)
declare variable $operand-one as xs:integer external;

(:~ This variable contains the second integer to process. :)
declare variable $operand-two as xs:integer external;

(:~
: Generates title for html page
: <ul class="list">
:    <li>
        A list item and keywords 'and', 'some' + operators
:    </li>
: @returns string value for title
:)
declare function local:title() as xs:string{
'A Sample XQuery File'
};


declare function local:mytest() as xs:boolean
{
if (empty($operand-one))
    then false()
 else if ($operand-two eq 2)
    then
    $operand-two eq 3
 else false()
};

if (true()) then
<html attr="simple test" test="my {awkward/difficult} answer" class="{/abc[@name]}"> 
<head>
  <!-- this is ok -->
  <title>{local:title()}<bold>{local:mytest(), <nested>what {$operand-two, <nested/>} difficulty </nested>}</bold> mixed text</title>
  <?abc processing> instruction?>
</head>
<body> 
  <p>{$operand-one + $operand-two}</p>
  <p><![CDATA[this is <testing things> somewhat {testing}and div mod could be tricky/awkward]]></p>
</body>
</html>
else
(:
: Module Name: Sample
: Module Version: 1.0
: Date: October 6, 2011
:)
xquery version "1.0";



(:~ so we have XPath 2.0 as default (:function namespace:) :)
declare default function namespace "http://www.w3.org/2005/xpath-functions"; 
(:~ this module outputs html  :)
declare default element namespace "http://www.w3.org/1999/xhtml";

(:~ This variable contains the first variable to process. :)
declare variable $operand-one as xs:integer external;

(:~ This variable contains the second integer to process. :)
declare variable $operand-two as xs:integer external;

(:~
: Generates title for html page
: <ul class="list">
:    <li>
        A list item and keywords 'and', 'some' + operators
:    </li>
: @returns string value for title
:)
declare function local:title() as xs:string{
'A Sample XQuery File'
};


declare function local:mytest() as xs:boolean
{
if (empty($operand-one))
    then false()
 else if ($operand-two eq 2)
    then
    $operand-two eq 3
 else false()
};

if (true()) then
<html attr="simple test" test="my {awkward/difficult} answer" class="{/abc[@name]}"> 
<head>
  <!-- this is ok -->
  <title>{local:title()}<bold>{local:mytest(), <nested>what {$operand-two, <nested/>} difficulty </nested>}</bold> mixed text</title>
  <?abc processing> instruction?>
</head>
<body> 
  <p>{$operand-one + $operand-two}</p>
  <p><![CDATA[this is <testing things> somewhat {testing}and div mod could be tricky/awkward]]></p>
</body>
</html>
else
(:
: Module Name: Sample
: Module Version: 1.0
: Date: October 6, 2011
:)
xquery version "1.0";



(:~ so we have XPath 2.0 as default (:function namespace:) :)
declare default function namespace "http://www.w3.org/2005/xpath-functions"; 
(:~ this module outputs html  :)
declare default element namespace "http://www.w3.org/1999/xhtml";

(:~ This variable contains the first variable to process. :)
declare variable $operand-one as xs:integer external;

(:~ This variable contains the second integer to process. :)
declare variable $operand-two as xs:integer external;

(:~
: Generates title for html page
: <ul class="list">
:    <li>
        A list item and keywords 'and', 'some' + operators
:    </li>
: @returns string value for title
:)
declare function local:title() as xs:string{
'A Sample XQuery File'
};


declare function local:mytest() as xs:boolean
{
if (empty($operand-one))
    then false()
 else if ($operand-two eq 2)
    then
    $operand-two eq 3
 else false()
};

if (true()) then
<html attr="simple test" test="my {awkward/difficult} answer" class="{/abc[@name]}"> 
<head>
  <!-- this is ok -->
  <title>{local:title()}<bold>{local:mytest(), <nested>what {$operand-two, <nested/>} difficulty </nested>}</bold> mixed text</title>
  <?abc processing> instruction?>
</head>
<body> 
  <p>{$operand-one + $operand-two}</p>
  <p><![CDATA[this is <testing things> somewhat {testing}and div mod could be tricky/awkward]]></p>
</body>
</html>

