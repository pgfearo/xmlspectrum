xquery version "1.0" encoding "UTF-8";

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
 :  This main module controls the presentation of the home page for
 :  xqDoc.  The home page will list all of the library and main modules
 :  contained in the 'xqDoc' collection.
 :  The mainline function invokes only the
 :  method to generate the HTML for the xqDoc home page.  A parameter of type 
 :  xs:boolean is passed to indicate whether links on the page should be constructed 
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

display:get-default-html(false()) 

