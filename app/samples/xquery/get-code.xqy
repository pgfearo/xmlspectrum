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
 :  This main module controls the presentation of the code for either
 :  an entire mdoule or a particlur function within a module. 
 :  The mainline function invokes only the
 :  method to retrieve the source code.  The 'module' and 'function' parameters
 :  are extracted from the query-string.  If only a 'module' is specified, then
 :  the source code for the entire module will be returned.  If both a 'module'
 :  and a 'function' are specified, only the source code for the specified function
 :  within the module will be returned. A parameter of type xs:boolean 
 :  is passed to indicate whether links on the page should be constructed 
 :  to static HTML pages (for off-line viewing) or to XQuery scripts for dynamic
 :  real-time viewing.
 : 
 :  @author Darin McBeath
 :  @since June 9, 2006
 :  @version 1.3
 :)

import module namespace display="xqdoc/xqdoc-display" at "xqdoc-display.xqy";

(: Disable caching and set content type :)
xdmp:set-response-content-type("text/html"),
xdmp:add-response-header("Pragma", "no-cache"),
xdmp:add-response-header("Cache-Control", "no-cache"),
xdmp:add-response-header("Expires", "0"),

let $module := xdmp:get-request-field("module")
let $function := xdmp:get-request-field("function")
return
  
  display:get-code-html($module, $function, false()) 


