(:
 : Copyright (c)2006 Elsevier, Inc.
 :
 : Licensed under the Apache License, Version 2.0 (the "License");
 : you may not use this file except in compliance with the License.
 : You may obtain a copy of the License at
 :
 : http://www.apache.org/licenses/LICENSE-2.0
 :
 : Unless required by applicable law or agreed to in writing, software
 : distributed under the License is distributed on an "AS IS" BASIS,
 : WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 : See the License for the specific language governing permissions and
 : limitations under the License.
 :
 : The use of the Apache License does not indicate that this project is
 : affiliated with the Apache Software Foundation.
 :)

(:~ 
 :  This module provides the functions that control the Web presentation
 :  of xqDoc. The logic contained in this module is not specific to any
 :  XQuery implementation and is written to the Nov 2005 XQuery working
 :  draft specification.  
 :
 :  It should also be noted that these functions not only support the 
 :  real-time presentation of the xqDoc information but are also used
 :  for the static offline presentation mode as well.  The static offline
 :  presentation mode has advantages because access to a native XML 
 :  database is not needed when viewing the xqDoc information ... it is
 :  only needed when generating the offline materials. 
 : 
 :  @author Darin McBeath
 :  @since June 9, 2006
 :  @version 1.3
 :)

module namespace display="xqdoc/xqdoc-display";

declare namespace xq="http://www.xqdoc.org/1.0";

(:~ 
 :  This variable defines the name for the xqDoc collection.
 :  The xqDoc XML for all modules should be stored into the
 :  XML database with this collection value.
 :)
declare variable $display:XQDOC_COLLECTION as xs:string := "xqdoc"; 

(:~ 
 :  This variable contains the list of URIs for all of the modules
 :  available to xqDoc for presentation.  Each module should be identified by
 :  a unique URI in the XML databse. 
 :)
declare variable $display:XQDOC_URIS as xs:string* := for $x in fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc
                                                      order by $x/xq:module/xq:uri 
                                                      return fn:string($x/xq:module/xq:uri);
(:~ 
 :  Construct the welcome banner for the xqDoc home page.
 :
 :  @param $local indicates whether to build static HTML link for offline
 :                viewing or dynamic linke for real-time viewing.
 :  @return HTML.
 :)
declare function display:print-intro($local as xs:boolean) as element()+
{
  (<h3>Welcome to xqDoc</h3>,
  <div class="overview">
  <p>This site presents documentation and cross-referencing information for both XQuery library
  and main modules that have been converted into xqDoc XML.   
  Visit <a href="http://www.xqdoc.org">xqdoc.org</a> to find the latest developments for this XQuery
  open source tool.</p>
  </div>
  )
};

(:~
 :  Construct the welcome banner for the xqDoc module page.
 :
 :  @param $local indicates whether to build static HTML link for offline
 :                viewing or dynamic links for real-time viewing.
 :  @return HTML.
 :)
declare function display:print-module-intro($local as xs:boolean) as element()
{
  display:build-link("default", $local, (), ())
};

(:~
 :  Construct the list of modules available to xqDoc for presentation.
 :  The list of modules is availalbe on the xqDoc home page.
 :
 :  @param $local indicates whether to build static HTML link for offline
 :                viewing or dynamic links for real-time viewing.
 :  @return HTML.
 :)
declare function display:print-modules($local as xs:boolean) as element()+
{
  (<div class="home">
    {
    if (fn:exists(fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc/xq:module[@type="library"])) then
      (<h4>Library Modules</h4>,
        <br/>,<br/>,
        for $x in fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc[xq:module/@type="library"]
        order by $x/xq:module/xq:uri
        return
         ( display:build-link("get-module",
                              $local, 
                              (fn:string($x/xq:module/xq:uri)),
                               display:decode-uri(fn:string($x/xq:module/xq:uri))),
           <br/> )
        )           
    else
      ()
    }
    {
    if (fn:exists(fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc/xq:module[@type="main"])) then
      (<h4>Main Modules</h4>,
        <br/>,<br/>,
        for $x in fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc[xq:module/@type="main"]
        order by $x/xq:module/xq:uri
        return
         ( display:build-link("get-module",
                               $local, 
                               (fn:string($x/xq:module/xq:uri)),
                                display:decode-uri(xs:string($x/xq:module/xq:uri))),
           <br/> )
      )
    else
      ()
    }
    </div>)
};

(:~
 :  The controller for constructing the xqDoc HTML information for
 :  the specified module. The following information  for
 :  each module will be generated.
 :  <ul>
 :  <li> Module introductory information</li>
 :  <li> Global variables declared in this module</li>
 :  <li> Modules imported by this module</li>
 :  <li> Summary information for each function defined in the module</li>
 :  <li> Detailed information for each function defined in the module</li>
 :  </ul>
 :
 :  @param $uri the URI for the module
 :  @param $local indicates whether to build static HTML link for offline
 :                viewing or dynamic links for real-time viewing.
 :  @return HTML.
 :)
declare function display:print-module-control($uri as xs:string, $local as xs:boolean) as item()+ 
{
  ( display:print-module($uri, $local),
    display:print-variables($uri, $local),
    "&#160;",
    display:print-imports($uri, $local),
    "&#160;",
    display:print-method-summary($uri),
    "&#160;",
    display:print-method-detail($uri, $local),
    display:print-footer($uri) )
};

(:~
 :  Construct the high-level xqDoc HTML for the module.
 :  This is essentially any introductory xqDoc comments that might
 :  be associated with the module.
 :
 :  @param $uri the URI for the module
 :  @param $local indicates whether to build static HTML link for offline
 :                viewing or dynamic links for real-time viewing.
 :  @return HTML.
 :)
declare function display:print-module($uri as xs:string, $local as xs:boolean) as element()* 
{
   (<h4>Module URI</h4>,
    <h1>{ display:decode-uri(xs:string(fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc/xq:module/xq:uri[. = $uri])) }</h1>,
    if (fn:exists(fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc/xq:module[xq:uri = $uri]/xq:body)) then
        display:build-link("get-code",
                           $local, 
                           $uri,
                           ())
             else
              (),
    if (fn:exists(fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc/xq:module[xq:uri = $uri]/xq:comment/xq:description) or
         fn:exists(fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc/xq:module[xq:uri = $uri]/xq:comment/xq:author) or
         fn:exists(fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc/xq:module[xq:uri = $uri]/xq:comment/xq:version) or
         fn:exists(fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc/xq:module[xq:uri = $uri]/xq:comment/xq:since) or
         fn:exists(fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc/xq:module[xq:uri = $uri]/xq:comment/xq:see)) then
           (<h4>Module Description</h4>,
            display:print-comment(fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc/xq:module[xq:uri = $uri]/xq:comment/xq:description, (), $local),
            <ul>
              {
              (display:print-comment(fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc/xq:module[xq:uri = $uri]/xq:comment/xq:author, "Author:", $local),
              display:print-comment(fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc/xq:module[xq:uri = $uri]/xq:comment/xq:version, "Version:", $local),
              display:print-comment(fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc/xq:module[xq:uri = $uri]/xq:comment/xq:since, "Since:", $local),
              display:print-comment(fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc/xq:module[xq:uri = $uri]/xq:comment/xq:see, "See:", $local))
              }
            </ul>)
    else
         ()
   )
};

(:~
 :  Construct the high-level xqDoc HTML for any global variables
 :  declared in the module.  In addition, cross-reference
 :  links will be included for the following:
 :  <ul>
 :  <li>Functions (contained in this module) that <i>use</i> this variable</li>
 :  <li>Functions (not contained in this module) that <i>use</i> this variable</li>
 :  </ul>
 :  @param $uri the URI for the module
 :  @param $local indicates whether to build static HTML link for offline
 :                viewing or dynamic links for real-time viewing.
 :  @return HTML.
 :)
declare function display:print-variables($uri as xs:string, $local as xs:boolean) as element()* 
{
  if (fn:exists(fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc[xq:module/xq:uri = $uri]/xq:variables/xq:variable)) then
      (<h4>Variables</h4>, 
       <div id="variables">
       {
            for $v in fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc[xq:module/xq:uri = $uri]/xq:xqdoc/xq:variables/xq:variable
            return 
                <div>
                 <a name="{ fn:concat("$", xs:string($v/xq:uri)) }"/>
                 <ul class="method">
                   <li class="left">{ fn:concat("$", xs:string($v/xq:uri)) }</li>
                   <li class="right">{ $v/xq:comment/xq:description/node() }</li>
                 </ul>
                 <ul>
                 { display:print-comment($v/xq:comment/xq:since, "Since:", $local) }
                 { display:print-comment($v/xq:comment/xq:see, "See:", $local) }
                 </ul>
                 { display:print-internal-variable-references($v, $local) }
                 { display:print-external-variable-references($v, $local) }
                </div>
       }       
       </div>)
  else
    ()
};

(:~
 :  Construct the high-level xqDoc HTML for any modules
 :  imported by the module.  
 :
 :  @param $uri the URI for the module
 :  @param $local indicates whether to build static HTML link for offline
 :                viewing or dynamic links for real-time viewing.
 :  @return HTML.
 :)
declare function display:print-imports($uri as xs:string, $local as xs:boolean) as element()* 
{
  if (fn:exists(fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc[xq:module/xq:uri = $uri]/xq:imports/xq:import)) then
       (<h4>Imported Modules</h4>,
        <div id="imports">
          {
            for $v in fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc[xq:module/xq:uri = $uri]/xq:imports/xq:import
            return 
              <div>
               <ul class="method">
               <li class="left">
               {
               if (fn:exists(fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc/xq:module[xq:uri = $v/xq:uri])) then
                 display:build-link("get-module",
                                    $local, 
                                    display:module-uri(fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc/xq:module[xq:uri = $v/xq:uri]),
                                    display:decode-uri(xs:string($v/xq:uri)))
               else
                 display:decode-uri(xs:string($v/xq:uri)) 
               }
               </li>
               <li class="right"> {$v/xq:comment/xq:description/node() }</li>           
               </ul>
               <ul>
               { display:print-comment($v/xq:comment/xq:since, "Since:", $local) }
               { display:print-comment($v/xq:comment/xq:see, "See:", $local) }
               </ul>
              </div>
            }
        </div>)
  else
    ()
};

(:~
 :  Construct the xqDoc HTML method summary for each function defined
 :  in the module.  The method summary will contain the function
 :  signature and the first <i>sentence</i> of any xqDoc comments associated
 :  with the function.
 :
 :  @param $uri the URI for the module
 :  @return HTML.
 :)
declare function display:print-method-summary($uri as xs:string) as element()* 
{
  if (fn:exists(fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc[xq:module/xq:uri = $uri]/xq:functions/xq:function)) then
    (<h4>Function Summary</h4>,
     <div id="methods"> 
     <a name="methods"/>  
        {
         for $f in fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc[xq:module/xq:uri = $uri]/xq:functions/xq:function
         order by fn:normalize-space(xs:string($f/xq:name)) ascending
         return
            <ul class="method">
              <li class="left">
               <a href="{fn:concat('#', fn:normalize-space(xs:string($f/xq:name)))}">{fn:normalize-space(xs:string($f/xq:name))}</a>
               <div class="description">
               {
                 if (fn:exists($f/xq:comment/xq:description)) then 
                    if (fn:substring-before($f/xq:comment/xq:description, ".")) then
                      fn:concat(fn:substring-before($f/xq:comment/xq:description, "."), ".")
                    else
                      xs:string($f/xq:comment/xq:description)
                 else
                    ()
               }
               </div>
              </li>
              <li class="right">
               {display:print-signature($f/xq:signature, fn:true())}
              </li>
            </ul>
          }
    </div>)
  else
    ()
};

(:~
 :  Construct the xqDoc HTML method detail for each function defined
 :  in the module.  The method detail will contain the function
 :  signature and all xqDoc comments associated with the function.  In
 :  addition, cross-reference links will be included for the following:
 :  <ul>
 :  <li>Functions (contained in this module) that <i>are used</i> by this function</li>
 :  <li>Functions (not contained in this module) that <i>are used</i> by this function</li>
 :  <li>Functions (contained in this module) that <i>use</i> this function</li>
 :  <li>Functions (not contained in this module) that <i>use</i> this function</li>
 :  <li>Variables (contained in this module) that <i>are used</i> by this function</li>
 :  <li>Variables (not contained in this module) that <i>are used</i> by this function</li>
 :  </ul>
 :
 :  @param $uri the URI for the module
 :  @param $local indicates whether to build static HTML link for offline
 :                viewing or dynamic links for real-time viewing.
 :  @return HTML.
 :)
declare function display:print-method-detail($uri as xs:string, $local as xs:boolean) as item()* 
{
  if (fn:exists(fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc[xq:module/xq:uri = $uri]/xq:functions/xq:function)) then
    (<h4>Function Detail</h4>,
     <div id="methoddetail">
     {
      for $f in fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc[xq:module/xq:uri = $uri]/xq:functions/xq:function
      order by fn:normalize-space(xs:string($f/xq:name)) ascending
      return
        (<div id="{fn:normalize-space(xs:string($f/xq:name))}" class="methoddetail">
         <h5><a name="{fn:normalize-space(xs:string($f/xq:name))}"/>{fn:normalize-space(xs:string($f/xq:name))}</h5>
         <ul class="method">
           <li class="left">
           {
             if (fn:exists($f/xq:body)) then

              display:build-link("get-code",
                                 $local, 
                                 ($uri,fn:normalize-space(xs:string($f/xq:name))),
                                 fn:normalize-space(xs:string($f/xq:name)))
             else
              ()
           }
           </li>
           <li class="right">     
              { display:print-signature($f/xq:signature, fn:false()) }
           </li>
         </ul>
	   {display:print-detail-comment($f/xq:comment/xq:description, (), $local)}
         <ul>
         {
           (display:print-detail-comment($f/xq:comment/xq:param, "Parameters:", $local),
            display:print-detail-comment($f/xq:comment/xq:return, "Return:", $local),
            display:print-detail-comment($f/xq:comment/xq:error, "Errors:", $local),
            display:print-detail-comment($f/xq:comment/xq:since, "Since:", $local),
            display:print-detail-comment($f/xq:comment/xq:see, "See:", $local),
            display:print-detail-comment($f/xq:comment/xq:deprecated, "Deprecated:", $local) )
         }
         </ul>
         {
         display:print-external-functions-invoked($f, $local),   
         display:print-external-functions-invoked-by($f, $local),      
         display:print-internal-functions-invoked($f, $local),    
         display:print-internal-functions-invoked-by($f, $local),  
         display:print-internal-variables-referenced($f, $local),
         display:print-external-variables-referenced($f, $local)
         }
         </div>,  "&#160;")
    }
    </div>, "&#160;")
  else
    ()    
};

(:~
 :  Construct the xqDoc HTML for the function signature.
 :
 :  @param $sigs the signatures associated with the current function.  Although only one
 :               signature is allowed for user-defined functions, more than one signature
 :               is required to support other 'modules' such as XPath F &amp; O.
 :  @param $local indicates whether to build static HTML link for offline
 :                viewing or dynamic links for real-time viewing.
 :  @return String containing the marked up function signature.
 :)
declare function display:print-signature($sigs as xs:string*, $local as xs:boolean) as item()*
{
  for $sig at $cnt in $sigs
  return
  (let $params := fn:substring-after($sig, "(")
   let $tokens := fn:tokenize($params, ",")
   let $count := fn:count($tokens)
   return
     (if ($cnt > 1) then 
	  ("OR", <br/>,<br/>)
      else
        (),
      for $token at $index in $tokens
      return
       (if ($index = 1) then
          xs:string("(")
        else
          (),
        if ($index = 1) then
	    fn:normalize-space($token)
        else
          ("&#160;", fn:normalize-space($token)),
        if ($index < $count) then
          xs:string(",")
        else
          (),
        <br/>)), 
  <br/>)
};

(:~
 :  Construct the xqDoc HTML for the specified xqDoc comment.  The following
 :  xqDoc comment values are supported.
 :  <ul>
 :  <li>author</li>
 :  <li>version</li>
 :  <li>param</li>
 :  <li>return</li>
 :  <li>error</li>
 :  <li>deprecated</li>
 :  <li>see</li>
 :  <li>since</li>
 :  <li><i>empty</i> which indicates a <i>description</i></li>
 :  </ul>
 :
 :  @param $comment the xqDoc comment element associated with a function
 :  @param $name the xqDoc comment name to process (i.e. author, version, etc.)
 :  @param $local indicates whether to build static HTML link for offline
 :                viewing or dynamic links for real-time viewing.
 :  @return HTML
 :)
declare function display:print-comment($comment as element()*, $name as xs:string?, $local as xs:boolean) as element()* 
{
  if (fn:exists($comment)) then
     for $i in $comment
       return           
             if (fn:not(fn:exists($name))) then 
               <p>{$i/node()}</p>     
             else if ($name = "See:") then
               <li><strong>{fn:concat($name, "&#160;")}</strong>{display:print-comment-see($i, $local)}</li>
             else
               <li><strong>{fn:concat($name, "&#160;")}</strong>{$i/node()}</li>
  else
    ()
};

(:~
 :  Construct the <i>detailed</i> xqDoc HTML for the specified xqDoc comment.  
 :  Detailed essentially implies the xqDoc comments for the method detail. The following
 :  xqDoc comment values are supported.
 :  <ul>
 :  <li>author</li>
 :  <li>version</li>
 :  <li>param</li>
 :  <li>return</li>
 :  <li>error</li>
 :  <li>deprecated</li>
 :  <li>see</li>
 :  <li>since</li>
 :  <li><i>empty</i> which indicates a <i>description</i></li>
 :  </ul>
 :
 :  @param $comment the xqDoc comment element associated with a function
 :  @param $name the xqDoc comment name to process (i.e. author, version, etc.)
 :  @param $local indicates whether to build static HTML link for offline
 :                viewing or dynamic links for real-time viewing.
 :  @return HTML
 :)

declare function display:print-detail-comment($comment as element()*, $name as xs:string?, $local as xs:boolean) as element()*
{
  if (fn:exists($comment)) then
    if (fn:exists($name)) then       
      (<li>{$name}</li>,
       <ul>
          {
            for $i in $comment
            return
              if ($name = "Parameters:") then
                <li>{display:print-comment-param($i)}</li>             
              else if ($name = "See:") then
                <li>{display:print-comment-see($i, $local)}</li>
              else
                <li>{$i/node()}</li>
          }
      </ul>) 
    else
      <p>{$comment/node()}</p> 
  else
    ()  
};

(:~
 :  Construct the xqDoc HTML for the specified xqDoc <i>param</i> comment element.  
 :
 :  @param $entry the xqDoc <i>param</i> comment element associated with a function
 :  @return HTML
 :)
declare function display:print-comment-param($entry as element()) as item()* 
{
    let $tmp := xs:string(($entry/node())[1])
    let $bef :=  fn:substring-before(fn:normalize-space($tmp), " ")
    let $aft :=  fn:substring-after(fn:normalize-space($tmp), " ")
    return
       (if (fn:string-length($bef) > 0) then
		fn:concat($bef, " - ", $aft)
	  else
		$tmp,
	  (for $x at $y in $entry/node()
         return
           if ($y > 1) then
               (" ", $x, " ")
           else
               ()),
         <br/>)
};

(:~
 :  Construct the xqDoc HTML for the specified xqDoc <i>see</i> comment element. 
 :  If the comment is a URI that exists for a module contained within
 :  xqDoc, build a link to this module (and optionally method or variable
 :  name.  If the comment is a 'http://' URL, then build a link to the URL.  If the
 :  comment is simply text, return the text.  With version 1.1, it is now also
 :  possible to specify the visible display name for the link.  This is accomplished
 :  by specifying an option second semi-colon followed by the link name.  So, the
 :  format for the parameter would be as follows:
 :  <p/>
 :
 :    a mandatory uri (or text) ';' an optional variable or method name ';' an optional link name
 :
 :  @param $entry the xqDoc param comment element associated with a function
 :  @param $local indicates whether to build static HTML link for offline
 :                viewing or dynamic links for real-time viewing.
 :  @return HTML
 :)
declare function display:print-comment-see($entry as element(), $local as xs:boolean) as item()* 
{
  let $tmp := fn:normalize-space(xs:string($entry))
  let $tokens := fn:tokenize($tmp, ";")
  return

  if (fn:count($tokens) = 1) then

    if (fn:not(fn:contains($tokens,"#")) and fn:exists(fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc/xq:module[xq:uri = $tokens])) then

        display:build-link("get-module",
                           $local,
                           $tokens,
                           $tmp)

    else if (fn:starts-with($tokens, "http")) then

        <a href="{$tokens}">{$tokens}</a>

    else

        $entry/node()

  else if (fn:count($tokens) = 2) then

    if (fn:not(fn:contains($tokens[1],"#")) and fn:exists(fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc[xq:module/xq:uri = $tokens[1]]/xq:functions/xq:function[xq:name = fn:normalize-space($tokens[2])])) then

        display:build-link("get-module",
                           $local,
                           $tokens,
                           $tmp)

    else

      $entry/node()

  else if (fn:count($tokens) = 3) then

    if (fn:string-length($tokens[2]) = 0 and fn:not(fn:contains($tokens[1],"#")) and fn:exists(fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc/xq:module[xq:uri = $tokens[1]])) then

        display:build-link("get-module",
                           $local,
                           $tokens,
                           $tokens[3])

    else if (fn:string-length($tokens[2]) = 0 and fn:starts-with($tokens[1], "http")) then

        <a href="{$tokens[1]}">{$tokens[3]}</a>

    else if (fn:string-length($tokens[2]) > 0 and fn:not(fn:contains($tokens[1],"#")) and fn:exists(fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc[xq:module/xq:uri = $tokens[1]]/xq:functions/xq:function[xq:name = fn:normalize-space($tokens[2])])) then

        display:build-link("get-module",
                           $local,
                           $tokens,
                           $tokens[3])

    else

      $entry/node()

  else 

    $entry/node()
};

(:~
 :  Construct the information to identify those functions (contained in
 :  other modules) that are <i>used by</i> the current function.  If that 
 :  module exists in xqDoc, construct a link to the module and function.
 :  If that module does not exist in xqDoc, simply identify the 
 :  module and function name.
 :
 :  @param $function the current function
 :  @param $local indicates whether to build static HTML link for offline
 :                viewing or dynamic links for real-time viewing.
 :  @return HTML
 :)
declare function display:print-external-functions-invoked($function as element(), $local as xs:boolean) as element()*
{
  if (fn:exists($function/xq:invoked[xq:uri != display:module-uri($function)])) then
     <div class="methoddetail">
     <h6>External Functions that are used by this Function</h6>
     <table class="inexternal">
       <tr>
        <th align="left">Module URI</th>
        <th align="left">Function Name</th>
       </tr>
       {
       let $uris := for $x in fn:distinct-values($function/xq:invoked/xq:uri)
                    where $x != display:module-uri($function)
                    order by xs:string($x)
                    return xs:string($x)
       for $uri in $uris
       let $names := for $y in $function/xq:invoked[xq:uri=$uri]
                     order by xs:string($y/xq:name)
                     return xs:string($y/xq:name)
       for $name at $i in $names
       return
         if ($i = 1) then
		(<tr><td>{"&#160;"}</td><td>{"&#160;"}</td></tr>,
            <tr>
             <td rowspan="{fn:count($names)}">{display:decode-uri($uri)}</td>
             {
               if (fn:exists(fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc[xq:module/xq:uri = $uri]/xq:functions/xq:function[xq:name = $name])) then
                 <td>
                     {
                       display:build-link("get-module",
                                          $local, 
                                          ($uri, $name),
                                          $name)
                     }
                 </td>
               else
                 <td>{$name}</td>
             }
           </tr>)
         else
           <tr>
             {
               if (fn:exists(fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc[xq:module/xq:uri = $uri]/xq:functions/xq:function[xq:name = $name])) then
                 <td>
                     {
                       display:build-link("get-module",
                                          $local, 
                                          ($uri, $name),
                                          $name)
                     }                   
                 </td>
               else
                 <td>{$name}</td>
             }
           </tr>
      }
    </table>
   </div>

  else
    ()
};

(:~
 :  Construct the information to identify those functions (contained in
 :  other modules) that <i>use</i> the current function.  If that 
 :  module exists in xqDoc, construct a link to the module and function.
 :  If that module does not exist in xqDoc, simply identify the 
 :  module and function name.
 :
 :  @param $function the current function
 :  @param $local indicates whether to build static HTML link for offline
 :                viewing or dynamic links for real-time viewing.
 :  @return HTML
 :)
declare function display:print-external-functions-invoked-by($function as element(), $local as xs:boolean) as element()*
{
  if (fn:exists(fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc/xq:functions/xq:function/xq:invoked[display:module-uri(.) != display:module-uri($function) and xq:uri=display:module-uri($function) and xq:name=xs:string($function/xq:name)])) then
    <div class="methoddetail">
     <h6>External Functions that invoke this Function</h6>
     <table class="inexternal">
       <tr>
        <th align="left">Module URI</th>
        <th align="left">Function Name</th>
       </tr>
       {
        let $list := for $x in fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc/xq:functions/xq:function/xq:invoked[xq:uri=display:module-uri($function) and xq:name=xs:string($function/xq:name)]
                     return $x
        let $uris := fn:distinct-values(for $y in $list
                                     where display:module-uri($y) != display:module-uri($function)
                                     order by display:module-uri($y)
                                     return
                                       display:module-uri($y))
        for $uri in $uris
        let $entries := for $entry in $list
                        where display:module-uri($entry)=$uri
                        order by $entry/../xq:name
                        return $entry
        for $entry at $i in $entries
        return 
           if ($i = 1) then
		(<tr><td>{"&#160;"}</td><td>{"&#160;"}</td></tr>,
            <tr>
             <td rowspan="{fn:count($entries)}">{display:decode-uri($uri)}</td>
             {
               if (fn:exists(fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc[xq:module/xq:uri = $uri]/xq:functions/xq:function[xq:name = $entry/../xq:name])) then
                 <td>
                     {
                       display:build-link("get-module",
                                          $local, 
                                          ($uri, xs:string($entry/../xq:name)),
                                          xs:string($entry/../xq:name))
                     }
                 </td>
               else
                 <td>{xs:string($entry/../xq:name)}</td>
             }
            </tr>)
           else
            <tr>
             {
               if (fn:exists(fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc[xq:module/xq:uri = $uri]/xq:functions/xq:function[xq:name = $entry/../xq:name])) then
                 <td>
                     {
                       display:build-link("get-module",
                                          $local, 
                                          ($uri, xs:string($entry/../xq:name)),
                                          xs:string($entry/../xq:name))
                     }
                 </td>
               else
                 <td>{xs:string($entry/../xq:name)}</td>
             }
            </tr>
        }	  
        </table>
       </div>
   else
    ()
};

(:~
 :  Construct the information to identify those functions (contained in the module
 :  for the current function) that are <i>used by</i> the current function.  
 :  Construct a link to the module and function.
 :
 :  @param $function the current function
 :  @param $local indicates whether to build static HTML link for offline
 :                viewing or dynamic links for real-time viewing.
 :  @return HTML
 :)
declare function display:print-internal-functions-invoked($function as element(), $local as xs:boolean) as element()*
{
  if (fn:exists($function/xq:invoked[xq:uri = display:module-uri($function)])) then
    <div class="methoddetail">
     <h6>Internal Functions used by this Function</h6>
     <table class="inexternal">
       <tr>
        <th align="left">Module URI</th>
        <th align="left">Function Name</th>
       </tr>
      {
       let $uris := for $x in fn:distinct-values($function/xq:invoked/xq:uri)
                    where $x = display:module-uri($function)
                    order by xs:string($x)
                    return xs:string($x)
       for $uri in $uris
       let $names := for $y in $function/xq:invoked[xq:uri=$uri]
                     order by xs:string($y/xq:name)
                     return xs:string($y/xq:name)
       for $name at $i in $names
       return
         if ($i = 1) then
		(<tr><td>{"&#160;"}</td><td>{"&#160;"}</td></tr>,
            <tr>
             <td rowspan="{fn:count($names)}">{display:decode-uri($uri)}</td>
             {
               if (fn:exists(fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc[xq:module/xq:uri = $uri]/xq:functions/xq:function[xq:name = $name])) then
                 <td>
                     {
                       display:build-link("get-module",
                                          $local, 
                                          ($uri, $name),
                                          $name)
                     }
                 </td>
               else
                 <td>{$name}</td>
             }
           </tr>)
         else
           <tr>
             {
               if (fn:exists(fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc[xq:module/xq:uri = $uri]/xq:functions/xq:function[xq:name = $name])) then
                 <td>
                     {
                       display:build-link("get-module",
                                          $local, 
                                          ($uri, $name),
                                          $name)
                     }
                 </td>
               else
                 <td>{$name}</td>
             }
           </tr>
      }
    </table>
   </div>

  else
    ()
};

(:~
 :  Construct the information to identify those functions (contained in the module
 :  for the current function) that <i>use</i> the current function.  
 :  Construct a link to the module and function.
 :
 :  @param $function the current function
 :  @param $local indicates whether to build static HTML link for offline
 :                viewing or dynamic links for real-time viewing.
 :  @return HTML
 :)
declare function display:print-internal-functions-invoked-by($function as element(), $local as xs:boolean) as element()*
{
  if (fn:exists(fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc/xq:functions/xq:function/xq:invoked[display:module-uri(.) = display:module-uri($function) and xq:uri=display:module-uri($function) and xq:name=xs:string($function/xq:name)])) then
    <div class="methoddetail">
     <h6>Internal Functions that invoke this Function</h6>
     <table class="inexternal">
       <tr>
        <th align="left">Module URI</th>
        <th align="left">Function Name</th>
       </tr>
       {
        let $list := for $x in fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc/xq:functions/xq:function/xq:invoked[xq:uri=display:module-uri($function) and xq:name=xs:string($function/xq:name)]
                     return $x
        let $uris := fn:distinct-values(for $y in $list
                                     where display:module-uri($y) = display:module-uri($function)
                                     order by display:module-uri($y)
                                     return
                                       display:module-uri($y))
        for $uri in $uris
        let $entries := for $entry in $list
                        where display:module-uri($entry)=$uri
                        order by $entry/../xq:name
                        return $entry
        for $entry at $i in $entries
        return 
           if ($i = 1) then
		(<tr><td>{"&#160;"}</td><td>{"&#160;"}</td></tr>,
            <tr>
             <td rowspan="{fn:count($entries)}">{display:decode-uri($uri)}</td>
             {
               if (fn:exists(fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc[xq:module/xq:uri = $uri]/xq:functions/xq:function[xq:name = $entry/../xq:name])) then
                 <td>
                     {
                       display:build-link("get-module",
                                          $local, 
                                          ($uri, xs:string($entry/../xq:name)),
                                          xs:string($entry/../xq:name))
                     }
                 </td>
               else
                 <td>{xs:string($entry/../xq:name)}</td>
             }
            </tr>)
           else
            <tr>
             {
               if (fn:exists(fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc[xq:module/xq:uri = $uri]/xq:functions/xq:function[xq:name = $entry/../xq:name])) then
                 <td>
                     {
                       display:build-link("get-module",
                                          $local, 
                                          ($uri, xs:string($entry/../xq:name)),
                                          xs:string($entry/../xq:name))
                     }
                 </td>
               else
                 <td>{xs:string($entry/../xq:name)}</td>
             }
            </tr>
        }
        </table>
       </div>
   else
    ()
};

(:~
 :  Construct the information to identify those functions (defined in other modules
 :  from the current variable) that <i>used</i> the current variable.  If that 
 :  module exists in xqDoc, construct a link to the module and function.
 :  If that module does not exist in xqDoc, simply identify the 
 :  module and function name.
 :
 :  @param $variable the current variable
 :  @param $local indicates whether to build static HTML link for offline
 :                viewing or dynamic links for real-time viewing.
 :  @return HTML
 :)
declare function display:print-external-variable-references($variable as element(), $local as xs:boolean) as element()*
{
  if (fn:exists(fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc/xq:functions/xq:function/xq:ref-variable[display:module-uri(.) != display:module-uri($variable) and xq:uri=display:module-uri($variable) and xq:name=xs:string($variable/xq:uri)])) then
    <div class="methoddetail">
     <h6>External Functions that reference this Variable</h6>
     <table class="inexternal">
       <tr>
        <th align="left">Module URI</th>
        <th align="left">Function Name</th>
       </tr>
       {
        let $list := for $x in fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc/xq:functions/xq:function/xq:ref-variable[xq:uri=display:module-uri($variable) and xq:name=xs:string($variable/xq:uri)]
                     return $x
        let $uris := fn:distinct-values(for $y in $list
                                     where display:module-uri($y) != display:module-uri($variable)
                                     order by display:module-uri($y)
                                     return
                                       display:module-uri($y))
        for $uri in $uris
        let $entries := for $entry in $list
                        where display:module-uri($entry)=$uri
                        order by $entry/../xq:name
                        return $entry
        for $entry at $i in $entries
        return 
           if ($i = 1) then
		(<tr><td>{"&#160;"}</td><td>{"&#160;"}</td></tr>,
            <tr>
             <td rowspan="{fn:count($entries)}">{display:decode-uri($uri)}</td>
             {
               if (fn:exists(fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc[xq:module/xq:uri = $uri]/xq:functions/xq:function[xq:name = $entry/../xq:name])) then
                 <td>
                     {
                       display:build-link("get-module",
                                          $local, 
                                          ($uri, xs:string($entry/../xq:name)),
                                          xs:string($entry/../xq:name))
                     }
                 </td>
               else
                 <td>{xs:string($entry/../xq:name)}</td>
             }
            </tr>)
           else
            <tr>
             {
               if (fn:exists(fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc[xq:module/xq:uri = $uri]/xq:functions/xq:function[xq:name = $entry/../xq:name])) then
                 <td>
                     {
                       display:build-link("get-module",
                                          $local, 
                                          ($uri, xs:string($entry/../xq:name)),
                                          xs:string($entry/../xq:name))
                     }
                 </td>
               else
                 <td>{xs:string($entry/../xq:name)}</td>
             }
            </tr>
        }
        </table>
       </div>
   else
    ()
};

(:~
 :  Construct the information to identify those functions (defined in the module
 :  for the current variable) that <i>use</i> the current variable.  
 :  Construct a link to the module and function.
 :
 :  @param $variable the current variable
 :  @param $local indicates whether to build static HTML link for offline
 :                viewing or dynamic links for real-time viewing.
 :  @return HTML
 :)
declare function display:print-internal-variable-references($variable as element(), $local as xs:boolean) as element()*
{
  if (fn:exists(fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc/xq:functions/xq:function/xq:ref-variable[display:module-uri(.) = display:module-uri($variable) and xq:uri=display:module-uri($variable) and xq:name=xs:string($variable/xq:uri)])) then
    <div class="methoddetail">
     <h6>Internal Functions that reference this Variable</h6>
     <table class="inexternal">
       <tr>
        <th align="left">Module URI</th>
        <th align="left">Function Name</th>
       </tr>
       {
        let $list := for $x in fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc/xq:functions/xq:function/xq:ref-variable[xq:uri=display:module-uri($variable) and xq:name=xs:string($variable/xq:uri)]
                     return $x
        let $uris := fn:distinct-values(for $y in $list
                                     where display:module-uri($y) = display:module-uri($variable)
                                     order by display:module-uri($y)
                                     return
                                       display:module-uri($y))
        for $uri in $uris
        let $entries := for $entry in $list
                        where display:module-uri($entry)=$uri
                        order by $entry/../xq:name
                        return $entry
        for $entry at $i in $entries
        return 
           if ($i = 1) then
		(<tr><td>{"&#160;"}</td><td>{"&#160;"}</td></tr>,
            <tr>
             <td rowspan="{fn:count($entries)}">{display:decode-uri($uri)}</td>
             {
               if (fn:exists(fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc[xq:module/xq:uri = $uri]/xq:functions/xq:function[xq:name = $entry/../xq:name])) then
                 <td>
                     {
                       display:build-link("get-module",
                                          $local, 
                                          ($uri, xs:string($entry/../xq:name)),
                                          xs:string($entry/../xq:name))
                     }
                 </td>
               else
                 <td>{xs:string($entry/../xq:name)}</td>
             }
            </tr>)
           else
            <tr>
             {
               if (fn:exists(fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc[xq:module/xq:uri = $uri]/xq:functions/xq:function[xq:name = $entry/../xq:name])) then
                 <td>
                     {
                       display:build-link("get-module",
                                          $local, 
                                          ($uri, xs:string($entry/../xq:name)),
                                          xs:string($entry/../xq:name))
                     }
                 </td>
               else
                 <td>{xs:string($entry/../xq:name)}</td>
             }
            </tr>
        }
        </table>
       </div>
   else
    ()
};

(:~
 :  Construct the information to identify those functions (defined in other modules
 :  from the current variable) that <i>use</i> the current variable.  If that 
 :  module exists in xqDoc, construct a link to the module and function.
 :  If that module does not exist in xqDoc, simply identify the 
 :  module and function name.
 :
 :  @param $variable the current variable
 :  @param $local indicates whether to build static HTML link for offline
 :                viewing or dynamic links for real-time viewing.
 :  @return HTML
 :)
declare function display:print-external-variables-referenced($variable as element(), $local as xs:boolean) as element()*
{
  if (fn:exists($variable/xq:ref-variable[xq:uri != display:module-uri($variable)])) then
    <div class="methoddetail">
     <h6>External Variables used by this Function</h6>
     <table class="inexternal">
       <tr>
        <th align="left">Module URI</th>
        <th align="left">Variable Name</th>
       </tr>
      {
       let $uris := for $x in fn:distinct-values($variable/xq:ref-variable/xq:uri)
                    where $x != display:module-uri($variable)
                    order by xs:string($x)
                    return xs:string($x)
       for $uri in $uris
       let $names := for $y in $variable/xq:ref-variable[xq:uri=$uri]
                     order by xs:string($y/xq:name)
                     return xs:string($y/xq:name)
       for $name at $i in $names
       return
         if ($i = 1) then
		(<tr><td>{"&#160;"}</td><td>{"&#160;"}</td></tr>,
            <tr>
             <td rowspan="{fn:count($names)}">{display:decode-uri($uri)}</td>
             {
               if (fn:exists(fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc[xq:module/xq:uri = $uri]/xq:variables/xq:variable[xq:uri = $name])) then
                 <td>
                     {
                       display:build-link("get-module",
                                          $local, 
                                          ($uri, fn:concat("$",$name)),
                                          fn:concat("$",$name))
                     }
                 </td>
               else
                 <td>{fn:concat("$",$name)}</td>
             }
           </tr>)
         else
           <tr>
             {
               if (fn:exists(fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc[xq:module/xq:uri = $uri]/xq:variables/xq:variable[xq:uri = $name])) then
                 <td>
                     {
                       display:build-link("get-module",
                                          $local, 
                                          ($uri, fn:concat("$",$name)),
                                          fn:concat("$",$name))
                     }
                 </td>
               else
                 <td>{fn:concat("$",$name)}</td>
             }
           </tr>
      }
    </table>
   </div>

  else
    ()
};

(:~
 :  Construct the information to identify those functions (defined in the module
 :  for the current variable) that <i>use</i> the current variable.  
 :  Construct a link to the module and function.
 :
 :  @param $variable the current variable
 :  @param $local indicates whether to build static HTML link for offline
 :                viewing or dynamic links for real-time viewing.
 :  @return HTML
 :)
declare function display:print-internal-variables-referenced($variable as element(), $local as xs:boolean) as element()*
{
  if (fn:exists($variable/xq:ref-variable[xq:uri = display:module-uri($variable)])) then
    <div class="methoddetail">
     <h6>Internal Variables used by this Function</h6>
     <table class="inexternal">
       <tr>
        <th align="left">Module URI</th>
        <th align="left">Variable Name</th>
       </tr>
      {
       let $uris := for $x in fn:distinct-values($variable/xq:ref-variable/xq:uri)
                    where $x = display:module-uri($variable)
                    order by xs:string($x)
                    return xs:string($x)
       for $uri in $uris
       let $names := for $y in $variable/xq:ref-variable[xq:uri=$uri]
                     order by xs:string($y/xq:name)
                     return xs:string($y/xq:name)
       for $name at $i in $names
       return
         if ($i = 1) then
		(<tr><td>{"&#160;"}</td><td>{"&#160;"}</td></tr>,
            <tr>
             <td rowspan="{fn:count($names)}">{display:decode-uri($uri)}</td>
             {
               if (fn:exists(fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc[xq:module/xq:uri = $uri]/xq:variables/xq:variable[xq:uri = $name])) then
                 <td>
                     {
                       display:build-link("get-module",
                                          $local, 
                                          ($uri, fn:concat("$",$name)),
                                          fn:concat("$",$name))
                     }
                 </td>
               else
                 <td>{fn:concat("$",$name)}</td>
             }
           </tr>)
         else
           <tr>
             {
               if (fn:exists(fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc[xq:module/xq:uri = $uri]/xq:variables/xq:variable[xq:uri = $name])) then
                 <td>
                     {
                       display:build-link("get-module",
                                          $local, 
                                          ($uri, fn:concat("$",$name)),
                                          fn:concat("$",$name))
                     }
                 </td>
               else
                 <td>{fn:concat("$",$name)}</td>
             }
           </tr>
      }
    </table>
   </div>

  else
    ()
};

(:~
 : Decode the uri.  This routine is needed for some XML databases that
 : have problems with specific characters contained in a document URI.
 : This routine makes the URI more human readable ... by removing the
 : encoding.  Currently, the only character encoded is a "/".  Other
 : characters could easily be added.  However, they would also need to
 : be specified in the xqDoc conversion package (XQDocContext).
 :
 : @param $uri the string to be decoded
 : @return the decoded string
 :)
declare function display:decode-uri($uri as xs:string) as xs:string
{
  fn:replace($uri, "~2F", "/")
};

(:~
 : Find the module uri for the associated element.  This routine is needed 
 : since we can't rely soley on base-uri().  Instead, the xqDoc XML URI is
 : contained in the XML of the document (the xqDoc module section).
 :
 : @param $e the element (i.e. function or variable) that we want to find the module uri
 : @return the module URI associated with the element
 :)
declare function display:module-uri($e as element()) as xs:string
{
  xs:string($e/ancestor::xq:xqdoc/xq:module/xq:uri)
};

(:~
 :  Construct the fotter information for the current module.
 :  The footer will contain the version of the xqDoc conversion program
 :  used to generate the xqDoc XML stored in the XML database and the
 :  time when the XML was created.  If the xqDoc conversion program was not
 :  used (i.e. XPath F &amp; O) then this information will be marked as N/A.
 :
 :  @param $uri the current module uri
 :  @return HTML
 :)
declare function display:print-footer($uri as xs:string) as element()*
{

<div align="left">
     <i>Created by xqDoc version {xs:string(fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc[xq:module/xq:uri = $uri]/xq:control/xq:version) } on {xs:string(fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc[xq:module/xq:uri = $uri]/xq:control/xq:date) }</i>
</div>
};

(:~
 :  Construct the HTML for the xqDoc home page.  This will include the welcome
 :  text and the list of modules available in xqDoc.
 :
 :  @param $local indicates whether to build static HTML link for offline
 :                viewing or dynamic links for real-time viewing.
 :  @return HTML
 :)
declare function display:get-default-html($local as xs:boolean) as element()
{
  <html xml:space="preserve">
    <head>
      <title>xqDoc -- Module List</title>
      { display:get-stylesheet() }
    </head>
    <body>
    { display:print-intro($local) }
    { display:print-modules($local) }
    </body>
  </html>
};

(:~
 :  Construct the HTML for a xqDoc module page.  
 :
 :  @param $module the module uri
 :  @param $local indicates whether to build static HTML link for offline
 :                viewing or dynamic links for real-time viewing.
 :  @return HTML
 :)
declare function display:get-module-html($module as xs:string, $local as xs:boolean) as element()
{
  <html xml:space="preserve">
    <head>
      <title>xqDoc -- Module</title>
      <script language="JavaScript">
      <!--
        function popUp(URL) {
                 day = new Date();
                 id = day.getTime();
                 eval("page = window.open(URL, 'xqdoccode', 'toolbar=0,scrollbars=1,location=0,statusbar=0,menubar=0,resizable=1,width=600,height=400,left = 412,top = 334');")
                 page.focus();
        }
      -->
      </script>
      { display:get-stylesheet() }
    </head>
    <body>
    { display:print-module-intro($local) }
    { display:print-module-control($module, $local) }
    </body>
  </html>
};

(:~
 :  Construct a link.  Based on the parameters, the link will be built
 :  for the static (off-line viewing mode of xqDoc) or the dynamic viewing
 :  mode of xqDoc.   The parameters will also indicate which link to construct,
 :  supply the appropriate paramters for the link, and assign a name for the link.
 :
 :  @param $type the type of link to construct.  The link can be for the xqDoc home
 :               page, the module page for a particular module, or for the
 :               XQuery code for a specific function.
 :  @param $local indicates whether to build static HTML link for offline
 :                viewing or dynamic links for real-time viewing.
 :  @param $parms the parameters associated with the link <i>$type</i>
 :  @param $name the name to assign for the link
 :  @return HTML
 :)
declare function display:build-link($type as xs:string, $local as xs:boolean, $parms as xs:string*, $name as xs:string?) as element()?
{
  if ($type = "default") then

    if ($local = fn:true()) then
      <a href="default.html">
         <h1>xqDoc Home</h1>
      </a>

    else
      <a href="default.xqy">
         xqDoc Home
      </a>

  else if ($type = "get-module") then

    if ($local = fn:true()) then
      <a href="{fn:concat('xqdoc-file-', xs:string(fn:index-of(display:get-module-uris(), $parms[1])), '.html',
         if (fn:exists($parms[2])) then
           fn:concat('#', $parms[2])
         else
           ()
         )}">
        { $name }
      </a>

    else
      <a href="{fn:concat('get-module.xqy?module=', $parms[1],
         if (fn:exists($parms[2])) then
           fn:concat('#', $parms[2])
         else
           ()
         )}">
        { $name }
      </a>


  else if ($type = "get-code") then

    if ($local = fn:true()) then
	if (fn:count($parms) > 1) then
        <a href="{fn:concat("javascript:popUp('xqdoc-file-", xs:string(fn:index-of(display:get-module-uris(), $parms[1])), "-", $parms[2], ".html')")}">
          view code
        </a>
      else
        <a href="{fn:concat("javascript:popUp('xqdoc-file-", xs:string(fn:index-of(display:get-module-uris(), $parms[1])), "_source.html')")}">
          view code
        </a>

    else
      if (fn:count($parms) > 1) then
        <a href="{fn:concat("javascript:popUp('get-code.xqy?module=", $parms[1], "&#38;", "function=", $parms[2], "')")}">
          view code
        </a>
      else
        <a href="{fn:concat("javascript:popUp('get-code.xqy?module=", $parms[1], "')")}">
          view code
        </a>
  else
    ()

};

(:~
 :  Construct a list of module uris contained in xqDoc.
 :
 :  @return List of module uris contained in xqDoc
 :)
declare function display:get-module-uris() as xs:string*
{
  $display:XQDOC_URIS
};

(:~
 :  Construct a list of function names defined in the current module.
 :
 :  @param $module the uri for the current module
 :  @return List of function names defined in the current module 
 :)
declare function display:get-function-names($module as xs:string) as xs:string*
{
  for $function in fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc[xq:module/xq:uri = $module]/xq:functions/xq:function
  return
  if (fn:exists($function/xq:body)) then
    fn:normalize-space(xs:string($function/xq:name))
  else
    ()
};

(:~
 :  Construct the HTML that will contain the XQuery code for the function
 :  in the current module (or the entire module).  The code will be 
 :  presented via a Javascript popup Window from the module.  The lack
 :  of a $name parameter indicates  to construct the HTML for entire module.
 :  
 :
 :  @param $module the uri associated with the current module
 :  @param $name the name associated with the current function contained in the module
 :  @param $local indicates whether to build static HTML link for offline
 :                viewing or dynamic links for real-time viewing.
 :  @return HTML ... the XQuery code for the function
 :)
declare function display:get-code-html($module as xs:string, $name as xs:string?, $local as xs:boolean) as element()
{
  <html xml:space="preserve">
    <head>
      <title>xqDoc -- Code Sample</title>
    </head>
    <body xml:space="preserve">
    <pre>{
      if (fn:empty($name)) then
        let $body := fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc[xq:module/xq:uri = $module]/xq:module
        return    
            if (fn:exists($body/*:body[@xml:space])) then
              display:print-preserve-newlines(xs:string($body/*:body[@xml:space])) 
            else
              ()
      else
        let $body := fn:collection($display:XQDOC_COLLECTION)/xq:xqdoc[xq:module/xq:uri = $module]/xq:functions/xq:function[xq:name = $name]   
        return      
          display:print-preserve-newlines(xs:string($body/*:body[@xml:space])) 
    }
    </pre>
    </body>
  </html>
};   

(:~
 :  Modify the markup (i.e. newlines) associated with an XQuery function so that 
 :  it presents cleanly in HTML. 
 :
 :  @param $strin the code associated with an XQuery function
 :  @return the presentation friendly version of the code 
 :)
declare function display:print-preserve-newlines($strin as xs:string?) as item()*
{
  for $i in fn:tokenize($strin, "\n") 
  return ($i, <br/>) 

};

(:~
 :  Get the xqDoc presentation stylesheet.  This is embedded into
 :  the returned XHTML for all of the presentation pages.  It is
 :  embedded into pages (instead of referencing a link) to keep 
 :  things simple for the off-line viewing mode.
 :
 :  @return the stylesheet
 :)
declare function display:get-stylesheet() as element()
{
<style>
<!--
body		{
		font: 80% Verdana;
		}
table		{
		font-size: 100%;
		}
h1, h2, h3, h4, h5, h6
		{
		clear: both;
		float: none;
		}
h1		{
		font-size: 100%;
		margin: 0em;
		}
h2		{
		font-size: 180%;
		margin-bottom: -1em;
		margin-top: .3em;
		}
h3		{
		font-size: 150%;
		}	
h4		{
		font-size: 140%;
		background-color: #ccf;
		border-bottom: 1px solid #99f;
		width: 100%;
		}
h5		{
		margin: 1em 0em 0em 0em;
		font-size: 120%;
		}
h6		{
		margin: 0em 0em 0em 3em;
		font-style: italic;
		font: bold italic;
		font-size: 100%;
		}
#variables, #methods, #methoddetail
		{
		padding-left: 3em;
		margin-bottom: 1.4em;
		clear: both;
		float: none;
		}
#methods ul.method, #variables ul.method
		{
		margin: 1em 0em 0em;
		}
#methoddetail ul.method
		{
		margin: 0em;
		}
div.inexternal
		{
		padding-left: 2em;
		margin-bottom: 1em;
		}
div.methoddetail p
		{
		float: none;
		clear: both;
		padding-left: 2em;
		margin-bottom: 1em;
		}
div.methoddetail{
		padding-bottom: 1em;
		}
div.methoddetail li
		{
		list-style-type: none;
		font-weight: bold;
		}
div.methoddetail li li
		{
		list-style-type: circle;
		font-weight: normal;
		}
div.methoddetail li ul
		{
		padding-bottom: 0.5em;
		font-weight: normal;
		}
table.inexternal{
		clear: both;
		float: none;
		width: 80%;
		margin-left: 3em;
		padding: 0em;
		
		}
table.inexternal th
		{
		background-color:#dedede;
		width: 50%;
		}			
td		{
		vertical-align: top;
		}
div.description {
		margin-top: .5em;
		font-weight: normal;
		padding-left: 1em;
		}
ul.method	{
		clear: both;
		float: none;
		width: 90%;
		list-style-type: none;
		border-top: 1px solid #ccc;
		}
ul.method li.left
		{
		float: left;
		clear: none;
		width: 40%;
		font-weight: bold;
		margin-bottom: 2em;
		}
ul.method li.right
		{
		position: relative;
            top: 0em;
		float: left;
            width: 55%;
		margin-bottom: 2em;
		padding-left: 2em;
		}
div.home 	{
		width: 60%;
		float: left;
		margin-right: 1%;
		border: 1px
		}
div.home h4	{
		font-size: 120%;
		background-color: #fff;
		border-bottom: 1px solid #99f;
		width: 100%;
		margin-bottom: -1em;
		}
div.overview p {
               width: 60%;
               }
     
 -->
</style>
};


(: Stylus Studio meta-information - (c) 2004-2006. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext><MapperFilter side="source"></MapperFilter></MapperMetaTag>
</metaInformation>
:)