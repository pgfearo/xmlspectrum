(:
 : search-ui.xqy
 :
 : Copyright (c) 2008 Mark Logic Corporation. All rights reserved.
 :
 : Licensed under the Apache License, Version 2.0 (the "License");
 : you may not use this file except in compliance with the License.
 : You may obtain a copy of the License at
 :
 :     http://www.apache.org/licenses/LICENSE-2.0
 :
 : Unless required by applicable law or agreed to in writing, software
 : distributed under the License is distributed on an "AS IS" BASIS,
 : WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 : See the License for the specific language governing permissions and
 : limitations under the License.
 :
 :
 : Search UI Library
 : This library has over 1,000 lines of code used specifically for
 : creating search experiences in an end-to-end XQuery application.
 : Primarily used in demos and prototypes to speed development of common
 : search-related tasks.
 : 
 : This library is meant to be changed to suit your application's needs.
 : Please test your application when using this library.
 :
 : Coordinator:
 : @author <a href="mailto:chris.welch@marklogic.com">Chris Welch</a>
 :
 : @requires MarkLogic Server 3.2
 : @requires Versi
 : @requires lib-search
 : @requires lib-uitools
 : All are available for download on developer.marklogic.com
 : Format: 3.2-YYYY-MM-DD.[Incremental]
 : @version 3.2-2008-06-10
 :
 :)

module "http://www.marklogic.com/ps/versi/search-ui"

import module namespace search="http://www.marklogic.com/ps/lib/lib-search" at "lib-search.xqy"
import module "http://www.marklogic.com/ps/lib/lib-search" at "lib-search-custom.xqy"
import module namespace uit="http://www.marklogic.com/ps/lib/lib-uitools" at "lib-uitools.xqy"

(: Defines the fields in which a user can search in. Each item should be in the format "[scope-id]|[display-name]" :)
define variable $SEARCH-FIELDS as xs:string* {( ("|Anywhere"), ("title|Headline") )}

(: Enable the date range search boxes in the advance search forms :)
define variable $ENABLE-DATE-CRITERIA as xs:boolean { fn:false() }

(: The default rendering mode for value facets :)
define variable $DEFAULT-FACET-MODE as xs:string { "add" } (: "mixed | one | add" :)

(:-- Search UI Functions --:)

(:~
:
: (Public) Converts <params> into <search:search-criteria>.  
:
: @param $params The parameters from the page request.
: @return The equivalent search-criteria XML.
:)
define function params-to-query($params as element(params)?) as element(search:search-criteria)
{
	let $start-date := uit:build-date($params/start-year[1], $params/start-month[1], $params/start-day[1])
	let $end-date := uit:build-date($params/end-year[1], $params/end-month[1], $params/end-day[1])
	return
    	build-query-element(
    		if ($params/q) then fn:string(xdmp:url-decode($params/q[1])) else (),
    		if ($params/field) then $params/field[1] else (), 
    		$params/coll,
    		($params/val, $params/hval),
    		$start-date,
    		$end-date,
    		$params/dur,
    		$params/sort
        )
}

define function build-query-element(
    $text as xs:string?,
    $field as xs:string?,
    $collections as xs:string*,
    $values as xs:string*,
    $start-date as xs:date?,
    $end-date as xs:date?,
    $duration as xs:duration?,
    $sort as xs:string?
    ) as element(search:search-criteria)
{
    <search-criteria fast-pagination="true" xmlns="http://www.marklogic.com/ps/lib/lib-search">
        {
        if ($text) then
        <term>
            <text>{$text}</text>
            {
            if ($field) then
                <scope-id>{$field}</scope-id>
            else ()
            }
        </term>
        else ()
        }
        {construct-collection-criteria($collections)}
        {construct-value-criteria($values)}
        {
        if ($start-date or $end-date) then
            <date-range>
                {if ($start-date) then <from>{$start-date}</from> else ()}
                {if ($end-date) then <to>{$end-date}</to> else ()}
            </date-range>
        else if ($duration) then
            <date-range>
                <trailing-duration>{$duration}</trailing-duration>
            </date-range>
        else
            ()
        }
        {
        if ($text) then
            if ($sort = "rel") then
                ()
            else if ($sort) then
                <sort><sort-field-id>{$sort}</sort-field-id></sort>
            else
                ()
        else
            <sort><sort-field-id>date</sort-field-id></sort>
    }
    </search-criteria>
}

define function construct-collection-criteria($collections as xs:string*) as element()*
{
    let $set-ids :=
        fn:distinct-values(
            for $coll in $collections
            let $tokens := split-search-item($coll)
            where fn:count($tokens) = 2
            return
               $tokens[1]
        )
    let $criteria :=
        for $set-id in $set-ids
        let $names :=
            for $coll in $collections
            let $tokens := split-search-item($coll)
            where fn:count($tokens) = 2 and $tokens[1] = $set-id
            return <search:value>{$tokens[2]}</search:value>
        where fn:not($names = "all") 
        return
            <collections xmlns="http://www.marklogic.com/ps/lib/lib-search">
                <set-id>{$set-id}</set-id>
                {$names}
            </collections>
    return
        $criteria
}

define function construct-value-criteria($search-values as xs:string*) as element()*
{
    let $scope-ids :=
        fn:distinct-values(
            for $val in $search-values
            let $tokens := split-search-item($val)
            where fn:count($tokens) = 2
            return
               $tokens[1]
        )
    let $criteria :=
        for $set-id in $scope-ids
        let $values :=
            for $val in $search-values
            let $tokens := split-search-item($val)
            where fn:count($tokens) = 2 and $tokens[1] = $set-id
            return <search:value>{$tokens[2]}</search:value>
        where fn:not($values = "all") 
        return
            <values xmlns="http://www.marklogic.com/ps/lib/lib-search">
                <scope-id>{$set-id}</scope-id>
                {$values}
            </values>
    return
        $criteria
}

define function split-search-item($val)
{
    let $raw := fn:tokenize($val, ':')
    return
        if (fn:count($raw) > 2) then
        ($raw[1], fn:string-join($raw[2 to fn:last()], ":"))
        else $raw
}

(:-- Search Form Controls --:)

(:~
:
: (Public) Renders an advanced search form, including building
: parametric select boxes based on facet information. 
:
: @param $params The parameters from the page request.
: @param $facet-defs The facets to use to build the advanced search form.
: @return A <form> containing the rendered search form.
:)
define function search-form(
	$params as element(params)?,
	$facet-defs as element(search:facet-defs)
	) as element()
{
    <form action="search.xqy" method="get">	    
        <div style="background:#F8F8F8;border:1px solid #D0D0D0;width:38em;padding:.6em .7em;">
            {element input {
                    attribute id {"adv-search-terms"}
                    ,attribute name {"q"}
                    ,attribute type {"text"}
                    ,attribute style {"display:inline;width:250px;padding:.2em .3em;"}
                    ,if (fn:string($params/q)) then (attribute value {fn:string($params/q)}) else ()
            }}
            { if ($SEARCH-FIELDS) then
            <select name="field" style="display:inline;margin-left:.3em;">
            	{     
    			for $option in $SEARCH-FIELDS
    			return
					let $items := fn:tokenize($option, "\|")
					return 
						element option {
							attribute value {$items[1]},
							if((fn:not($params/field) and $items[1] = "") or $params/field eq $items[1]) then 
								attribute selected {"selected"}
							else (),
							$items[2]
						}
    			}
		    </select>
		    else () }
        </div>
        {
        for $facet at $pos in $facet-defs/search:facet-def[search:collection-set-facet]
        return
            search-form-control-collection-set(
                $params,
                $facet,
                $pos
                )}
        {if ($ENABLE-DATE-CRITERIA) then search-form-control-discrete-date($params) else ()}
		<input value="Search" type="submit" class="button" style="display:block;margin:.5em .5em;" />
	</form>
}

define function search-form-control-collection-set(
    $params as element(params),
    $facet-def as element(search:facet-def),
    $position as xs:integer
    ) as element()*
{
    let $collection-set-id := fn:string($facet-def/search:collection-set-facet/search:set-id)
    let $title := fn:string($facet-def/search:custom/search:title)
    let $resolved-facet :=
        search:resolve-facet(<search:search-criteria />, $facet-def)
    return
    <div style="margin: .7em .7em;">
        {$title} [Article Count]:<br/>
        <select id="select-{$position}" multiple="multiple" name="coll" size="4" style="width:300px;" >
            <option value="{fn:concat($collection-set-id, ":all")}">
                {if (fn:not($params/coll) or $params/coll/text() = fn:concat($collection-set-id, ":all")) then
                attribute selected {"selected"}
                else ()}
                All {$title}
            </option>
            {for $item in facet-item-sort($resolved-facet/search:item, $facet-def/search:custom/search:sort)
            let $value := fn:concat($collection-set-id, ":",fn:string($item/@value))
            return 
                <option value="{$value}">
                	{if ($params/coll/text() = $value) then
                	attribute selected {"selected"}
                	else ()}
                	{fn:concat($item/text()," [",fn:string($item/@count),"]")}
                </option>}
     	</select>
     </div>
}

define function search-form-control-discrete-date($params as element(params)) as element()*
{
    <div style="margin: .7em .7em;">
        Date:<br/>
        <div style="margin-top:.3em">
            <label style="font-weight:bold;float:left;margin-top:.4em;width:4em;">Start: </label>
            <select name="start-month">
            	<option value="01">{select-option($params/start-month,"01")}January</option>
            	<option value="02">{select-option($params/start-month,"02")}February</option>
            	<option value="03">{select-option($params/start-month,"03")}March</option>
            	<option value="04">{select-option($params/start-month,"04")}April</option>
            	<option value="05">{select-option($params/start-month,"05")}May</option>
            	<option value="06">{select-option($params/start-month,"06")}June</option>
            	<option value="07">{select-option($params/start-month,"07")}July</option>
            	<option value="08">{select-option($params/start-month,"08")}August</option>
            	<option value="09">{select-option($params/start-month,"09")}September</option>
            	<option value="10">{select-option($params/start-month,"10")}October</option>
            	<option value="11">{select-option($params/start-month,"11")}November</option>
            	<option value="12">{select-option($params/start-month,"12")}December</option>
            </select>
            {" / "}
            <input type="text" name="start-day" value="{fn:string($params/start-day)}" style="width:2em;" />
            {" / "}
            <input type="text" name="start-year" value="{fn:string($params/start-year)}" style="width:4em;" />
        </div>
        <div>
            <label style="font-weight:bold;float:left;margin-top:.4em;width:4em;">End: </label>
            <select name="end-month">
            	<option value="01">{select-option($params/end-month,"01")}January</option>
            	<option value="02">{select-option($params/end-month,"02")}February</option>
            	<option value="03">{select-option($params/end-month,"03")}March</option>
            	<option value="04">{select-option($params/end-month,"04")}April</option>
            	<option value="05">{select-option($params/end-month,"05")}May</option>
            	<option value="06">{select-option($params/end-month,"06")}June</option>
            	<option value="07">{select-option($params/end-month,"07")}July</option>
            	<option value="08">{select-option($params/end-month,"08")}August</option>
            	<option value="09">{select-option($params/end-month,"09")}September</option>
            	<option value="10">{select-option($params/end-month,"10")}October</option>
            	<option value="11">{select-option($params/end-month,"11")}November</option>
            	<option value="12">{select-option($params/end-month,"12")}December</option>
            </select>
            {" / "}
            <input type="text" name="end-day" value="{fn:string($params/end-day)}" style="width:2em;" />
            {" / "}
            <input type="text" name="end-year" value="{fn:string($params/end-year)}" style="width:4em;" />
        </div>
 	</div>
}

define function select-option($param as element()?, $value as xs:string) as attribute()?
{
	if ($param = $value) then attribute selected {"selected"} else ()
}

(: Search Facets Functions :)

(: 
   The format of the facet definitions is proscribed by lib-search. You can also
   include custom elements which search-ui.xqy will use when rendering your facet.
   Make sure to pass the custom section for each facet, which contains:
   facet-def/custom/title : The heading used to display all related UI controls.
   facet-def/custom/sort : default (default), count, name-asc, name-desc
   facet-def/custom/icon : an image filename, used in the analysis panel only
   facet-def/custom/qs-id : for collection and value facets, scope-ids should be used,
       and this should match the name of the scope-id
   facet-def/custom/mode : currently used only in value facets, changes how the user
       interacts with the facet.
   
   For more information on defining facets, see the Search Library Guide.

    <facet-defs xmlns="http://www.marklogic.com/ps/lib/lib-search">
        <facet-def>
        ...
        <custom>
            <sort>name-asc</sort>
            <qs-id>comp</qs-id>
            <title>Companies</title>
            <icon>/images/silk/building.png</icon>
            <mode>mixed|one|add</mode>
        </custom>
        </facet-def>
    </facet-defs>
:)

(:~
:
: (Public) Renders an facets meant to be displayed on the sidebar of
: the search page.
:
: @param $params The parameters from the page request.
: @param $facet-defs The facets to use to build the advanced search form.
: @return The rendered HTML facets.
:)
define function search-facets($params as element(), $facet-defs as element(search:facet-defs)) as element()?
{
    let $rendered-facets :=
        let $query := params-to-query($params)
        let $facets := search:resolve-facets($query, $facet-defs)
        for $facet in $facets/search:facet
        return
            if ($facet[search:facet-def/search:collection-set-facet]) then
                (collection-facet($params, $facet))
            else if ($facet[search:facet-def/search:value-facet]) then
                (value-facet($params, $facet))
            else if ($facet[search:facet-def/search:trailing-date-facet]) then
                (trailing-date-facet($params, $facet))
            (: Unhandled facet type
            else if ($facet[search:facet-def/search:date-group-facet]) then
                (date-group-facet($params, $facet)):)
            else ()
    return
        if ($rendered-facets) then
            <div>{$rendered-facets}</div>
        else ()
}

(:~
:
: (Public) Renders tag clouds meant to be displayed on the top of
: the search page. The items in the tag cloud are given a 1-6 "heat" rating,
: which can be individually styled. The heat rating is determined, and can
: be customized using the "determine-heat" function.
:
: @param $params The parameters from the page request.
: @param $facet-defs The facets to use to build the advanced search form.
: @return The rendered HTML tag clouds
:)
define function search-results-analysis($params as element(params), $facet-defs as element(search:facet-defs)) as element()*
{
	let $query := params-to-query($params)
	let $facets := search:resolve-facets($query, $facet-defs)
    return
    if ($facets/search:facet/search:item) then
    <div class="analysis-panel">
        <div class="header">These documents contain references to:&nbsp;&nbsp;<a href="search.xqy?{uit:build-querystring($params, ("p", "hval"))}">[CLEAR FILTERS]</a></div>
        {
        for $facet in $facets/search:facet
        return value-heatmap($params, $facet)
        }
    </div>
    else ()
}

(: NB: This facet doesn't yet support facet modes. It must be added later :)
define function collection-facet($params as element(), $facet as element(search:facet)) as element()*
{
    let $title := fn:string($facet/search:facet-def/search:custom/search:title)
    let $param-name := "coll"
    let $params := uit:modify-param-set($params, "p", ())
    let $collection-set-id := fn:string($facet/search:facet-def/search:collection-set-facet/search:set-id)
    let $set-selector := fn:concat($collection-set-id, ":all")
    
    (: Collection Management :)
    (: Selects the param values that are within scope (ie have been returned from) of the current facet :)
    let $facet-colls as xs:string* := $facet/search:item/@value
    let $facet-colls := ($set-selector, for $value in $facet-colls return fn:concat($collection-set-id, ":", $value))
    let $passed-colls :=
        for $coll as xs:string in $params/coll
        where fn:starts-with($coll, $collection-set-id)
        return $coll
    let $out-of-scope-colls :=
        for $coll in $passed-colls
        where fn:not($coll = $facet-colls)
        return $coll
    let $params :=
        if ($out-of-scope-colls) then
            uit:modify-param-set($params,$param-name,$out-of-scope-colls,())
        else $params
    
	return
	<div>
		{ if ($title) then <h3>{$title}</h3> else () }
		<div class="search_facet">
		{ (: ALL :)
		let $newParams := uit:modify-param-set($params,$param-name,$facet-colls,$set-selector)
		let $count := fn:data($facet/search:all/@count)
		let $qs := uit:build-querystring($newParams,())
		let $link := fn:concat("All [",$count,"]")
		return			
        	<div><a href="search.xqy?{$qs}">
        		{
        		if (fn:empty($params/coll) or
        		    fn:not($params/coll = $facet-colls) or
        			$params/coll = $set-selector) then
	     			(<img src="images/silk/bullet_black.png" class="selected_icon"/>,<strong>{$link}</strong>)
        		else $link
        		}
        	</a></div>
        }
    	{ (: COLLECTIONS :)
    	for $item in facet-item-sort($facet/search:item, $facet/search:facet-def/search:custom/search:sort)
		let $value := fn:concat($collection-set-id, ":", $item/@value)
		let $count := fn:data($item/@count)
		let $link := fn:concat($item/text()," [",$count,"]")
		let $qs :=
 			(: If the current collection exists in the params, then remove
			   from params, else add to the params :)
			if (fn:not($params/coll/text() = $set-selector) and 
	    		$params/coll = $value) then
				uit:build-querystring(uit:modify-param-set($params,$param-name,$value, ()),())
			else
				fn:string-join((
					uit:build-querystring(uit:modify-param-set($params,$param-name,$set-selector, ()),()),
					fn:concat($param-name,"=",$value)),"&")
    	return
    		if ($count > 0) then
	    		<div><a href="search.xqy?{$qs}">
	    			{
	    			if (fn:not($params/coll/text() = $set-selector) and 
	    				$params/coll = $value) then
	     				(<img src="images/silk/bullet_delete.png" class="selected_icon"/>,<strong>{$link}</strong>)
	    			else $link
	    			}
	    		</a></div>
	    	else ()
 		}
 		</div>
 	</div>
}

define function value-facet($params as element(), $facet as element(search:facet)) as element()*
{ value-facet($params, $facet, ()) }

define function value-facet($params as element(), $facet as element(search:facet), $mode as xs:string?) as element()*
{
    (: mode == (one, add, mixed) :)
	let $mode :=
	    if ($mode) then $mode else
            if ($facet[search:facet-def/search:custom/search:mode]) then
                fn:string(($facet/search:facet-def/search:custom/search:mode)[1])
            else
	            $DEFAULT-FACET-MODE
	let $title := fn:string($facet/search:facet-def/search:custom/search:title)
    let $param-name := "val"
    let $params := uit:modify-param-set($params, "p", ())
    let $qs-id := fn:string($facet/search:facet-def/search:custom/search:qs-id)
    let $set-selector := fn:concat($qs-id, ":all")
    
    (: Value Management :)
    (: Selects the param values that are within scope (ie have been returned from) of the current facet :)
    let $facet-vals as xs:string* := $facet/search:item/@value
    let $facet-vals := ($set-selector, for $value in $facet-vals return fn:concat($qs-id, ":", $value))
    let $passed-vals :=
        for $val as xs:string in $params/val
        where fn:starts-with($val, $qs-id)
        return $val
    let $out-of-scope-vals :=
        for $val in $passed-vals
        where fn:not($val = $facet-vals)
        return $val
    let $params :=
        if ($out-of-scope-vals) then
            uit:modify-param-set($params,$param-name,$out-of-scope-vals,())
        else $params
    
	return
	<div>
		{ if ($title) then <h3>{$title}</h3> else () }
		<div class="search_facet">
		{ (: ALL :)
		let $newParams := uit:modify-param-set($params,$param-name,$facet-vals,$set-selector)
		let $count := fn:data($facet/search:all/@count)
		let $qs := uit:build-querystring($newParams,())
		let $link := fn:concat("All [",$count,"]")
		return			
        	<div><a href="search.xqy?{$qs}">
        		{
        		if (fn:empty($params/val) or
        		    fn:not($params/val = $facet-vals) or
        			$params/val = $set-selector) then
	     			(<img src="images/silk/bullet_black.png" class="selected_icon" />,<strong>{$link}</strong>)
        		else $link
        		}
        	</a></div>
        }
    	{ (: VALUES :)
    	for $item in facet-item-sort($facet/search:item, $facet/search:facet-def/search:custom/search:sort)
		let $value := fn:concat($qs-id, ":", $item/@value)
		let $count := fn:data($item/@count)
		let $link := fn:concat(capitalize-first-chars($item/text())," [",$count,"]")
		let $add-qs :=
     		(: If the current collection exists in the params, then remove
    		   from params, else add to the params :)
    		if (fn:not($params/val/text() = $set-selector) and 
        		$params/val = $value) then
    			uit:build-querystring(uit:modify-param-set($params,$param-name,$value, ()),())
    		else
    			fn:string-join((
    				uit:build-querystring(uit:modify-param-set($params,$param-name,$set-selector, ()),()),
    				fn:concat($param-name,"=",xdmp:url-encode($value))),"&")
        let $one-qs :=
     		(: If the current collection exists in the params, then remove
    		   from params, else add to the params :)
    		let $stripped-params := 
    			if ($passed-vals) then
    			    uit:modify-param-set($params,$param-name,$passed-vals, ())
    			else
    			    $params
            return
        		fn:string-join((
        			uit:build-querystring($stripped-params,()),
        			fn:concat($param-name,"=",xdmp:url-encode($value))),"&")
        return
    		if ($count > 0) then
	    		if ($mode = "add") then
    	    		<div><a href="search.xqy?{$add-qs}">
    	    			{
    	    			if (fn:not($params/val/text() = $set-selector) and 
    	    				$params/val = $value) then
    	     				(<img src="images/silk/bullet_delete.png" class="selected_icon"/>,<strong>{$link}</strong>)
    	    			else $link
    	    			}
    	    		</a></div>
                else if ($mode = "mixed") then
    	    		<div><a href="search.xqy?{$add-qs}">
    	    			{
    	    			if (fn:not($params/val/text() = $set-selector) and 
    	    				$params/val = $value) then
    	     				(<img src="images/silk/bullet_delete.png" class="selected_icon"/>,<strong>{$link}</strong>)
    	    			else $link
    	    			}
    	    		</a>{" "}<a href="search.xqy?{$one-qs}">(only)</a></div>
                else
    	    		<div><a href="search.xqy?{$one-qs}">
    	    			{
    	    			if (fn:not($params/val/text() = $set-selector) and 
    	    				$params/val = $value) then
    	     				(<img src="images/silk/bullet_black.png" class="selected_icon"/>,<strong>{$link}</strong>)
    	    			else $link
    	    			}
    	    		</a></div>
                
	    	else ()
 		}
 		</div>
 	</div>
}

define function value-heatmap($params as element(), $facet as element(search:facet)) as element()*
{
	if ($facet/search:item) then
    	let $title := fn:string($facet/search:facet-def/search:custom/search:title)
    	let $icon := fn:string($facet/search:facet-def/search:custom/search:icon)
    	let $all-count as xs:integer? := $facet/search:all/@count
    	let $max-count as xs:integer* := $facet/search:item/@count
    	let $max-count as xs:integer? := fn:max($max-count)
        let $param-name := "hval"
        let $params := uit:modify-param-set($params, "p", ())
        let $qs-id := fn:string($facet/search:facet-def/search:custom/search:qs-id)
        let $set-selector := fn:concat($qs-id, ":all")
        
        (: Value Management :)
        (: Selects the param values that are within scope of (ie have been returned from) the current facet :)
        let $facet-vals as xs:string* := $facet/search:item/@value
        let $facet-vals := ($set-selector, for $value in $facet-vals return fn:concat($qs-id, ":", $value))
        let $passed-vals :=
            for $val as xs:string in $params/hval
            where fn:starts-with($val, $qs-id)
            return $val
        let $out-of-scope-vals :=
            for $val in $passed-vals
            where fn:not($val = $facet-vals)
            return $val
        let $params :=
            if ($out-of-scope-vals) then
                uit:modify-param-set($params,$param-name,$out-of-scope-vals,())
            else $params
        
    	return
    	<div>
            {if ($icon) then (<img class="icon" src="{$icon}" />," ") else ()}<strong>{$title}</strong>: 
            <span class="heatmap" xml:space="preserve">
    		{ (: ALL :)
    		let $newParams := uit:modify-param-set($params,$param-name,$facet-vals,$set-selector)
    		let $count := fn:data($facet/search:all/@count)
    		let $qs := uit:build-querystring($newParams,())
    		let $link := fn:concat("[CLEAR &raquo;]")
    		return			
            	if (fn:empty($params/hval) or
            	    fn:not($params/hval = $facet-vals) or
            		$params/hval = $set-selector) then ()
                else <a href="search.xqy?{$qs}"><strong>{$link}</strong></a>
            }
        	{ (: VALUES :)
        	for $item in facet-item-sort($facet/search:item, $facet/search:facet-def/search:custom/search:sort)
    		let $value := fn:concat($qs-id, ":", $item/@value)
    		let $count as xs:integer := fn:data($item/@count)
    		let $link := capitalize-first-chars($item/text())
    		let $qs :=
     			(: If the current collection exists in the params, then remove
    			   from params, else add to the params :)
    			if (fn:not($params/hval/text() = $set-selector) and 
    	    		$params/hval = $value) then
    				uit:build-querystring(uit:modify-param-set($params,$param-name,$value, ()),())
    			else
    				fn:string-join((
    					uit:build-querystring(uit:modify-param-set($params,$param-name,$set-selector, ()),()),
    					fn:concat($param-name,"=",xdmp:url-encode($value))),"&")
        	return
        		if ($count > 0) then
    	    		(" ",<a href="search.xqy?{$qs}"><span title="{$count} documents" class="heat{determine-heat($all-count, $max-count, $count)}">
    	    			{
    	    			if (fn:not($params/hval/text() = $set-selector) and 
    	    				$params/hval = $value) then
    	     				(<strong class="selected">{$link}</strong>)
    	    			else $link
    	    			}
    	    		</span></a>)
    	    	else ()
     		}
             
            </span>
     	</div>
 	else ()
}

define function trailing-date-facet($params as element(), $facet as element(search:facet)) as element()*
{
    let $title := fn:string($facet/search:facet-def/search:custom/search:title)
    let $params := uit:modify-param-set($params, "p", ())
    return
        <div>
        	{(: Only display the date facets when there is no start and non-valid end fields :)}
    	    {if ($title) then <h3>{$title}</h3> else ()}
            <div class="search_facet">
    		{
    			(: ALL :)
    			let $newParams :=
    				uit:modify-param-set($params, "dur", ())
    			let $count := fn:data($facet/search:all/@count)
                let $qs := uit:build-querystring($newParams,())
                let $link := fn:concat("All [",$count,"]")
    			return					
    				<div><a href="search.xqy?{$qs}">
    				{
    				if (fn:empty($params/dur/text())) then
    					(<img src="images/silk/bullet_go.png" class="selected_icon"/>,<strong>{$link}</strong>)
    				else
    					$link
    				}
    				</a>
    				</div>
    			,
    			(: DURATIONS :)
                for $item at $pos in $facet/search:item
    			let $value := xs:duration($item/@value)
    			let $desc := fn:string($item)
    			let $newParams :=
    				uit:modify-param-set($params, "dur", <dur>{$value}</dur>)
                let $count := fn:data($item/@count)
                let $qs := uit:build-querystring($newParams,())
                let $link := fn:concat($desc, " [",$count,"]")
                return			
                    <div><a href="search.xqy?{$qs}">
                        {
                        if ($params/dur = $value) then
                         	(<img src="images/silk/bullet_go.png" class="selected_icon"/>,<strong>{$link}</strong>)
                        else $link
                        }
                    </a></div>
            }
    		</div>
        </div>
}

define function determine-heat(
    $all-count as xs:integer,
    $max-count as xs:integer,
    $item-count as xs:integer) as xs:integer
{
    (: With this formula, an item can range from 0-67% :)
    (: Lower ranges are wider than higher ranges :)
    let $comp-num := $max-count + ($all-count * .5)
    let $item-pct := $item-count div $comp-num
    let $max-pct := $max-count div $comp-num
    let $xfrm-pct := $item-pct div $max-pct 
    return
    
    (: apply specific controls :)
    (: These are a hack for now. Will need to tune this later :)
    if ($max-count = 1 and $item-count = 1) then 
        2
    else if ($all-count <= 3 and $max-count = $item-count) then
        4
    else
    
    if ($xfrm-pct <= .25) then
        1
    else if ($xfrm-pct <= .46) then
        2
    else if ($xfrm-pct <= .63) then
        3
    else if ($xfrm-pct <= .77) then
        4
    else if ($xfrm-pct <= .89) then
        5
    else 6
}

define function facet-item-sort($items as element(search:item)*, $type as xs:string?) as element(search:item)*
{
    if (fn:lower-case($type) = "name-asc") then
        for $item in $items
        order by fn:string($item) ascending
        return $item
    else if (fn:lower-case($type) = "name-desc") then
        for $item in $items
        order by fn:string($item) descending
        return $item
    else if (fn:lower-case($type) = "count") then
        for $item in $items
        order by xs:integer($item/@count) descending
        return $item
    else
        $items        
} 

(: Highlighting functions :)

(:~
:
: (Public) Will highlight a node based on the full-text search inside
: a search-criteria. Compatible with the create-snippet and create-summary functions.
:
: @param $node The node to be highlighted
: @param $query The search-criteria to be used to perform the highlighting.
: @return The highlighted node. If not highlighting query can be built, then returns nothing.
:)
define function highlight($node as node(), $query as element(search:search-criteria)) as node()?
{
	let $highlight-query := create-highlight-query($query)
    return
        if ($highlight-query) then
            cts:highlight($node,$highlight-query,<span class="ml-highlight">{$cts:text}</span>)
        else ()
}

(:~
:
: (Public) Builds a cts:query from a search-criteria element suitable for highlighting a node. 
:
: @param $query The search-criteria to be used to perform the highlighting.
: @return The highlight query. If not highlighting query can be built, then returns nothing.
:)
define function create-highlight-query($query as element(search:search-criteria)) as cts:query?
{
    search:build-term-query(search:resolve($query/search:term))
}

(: Search snippet functions :)

(:~
:
: (Public) Renders a search result summary, which can be either the abstract of the document or
: snippets of the document if it has been highlighted as a result of a full-text search.
: If snippets are available, then a click-and-zoom link can also be enabled. To enable click-and-zoom
: there must be a page that can handle a request in the format:
: 
: request.xqy?action=show-section&uri=[*]&path=[*]
: 
: The function sdis:show-section (below), can then be called to fullfil the request.
:
: @param $orig-node The original document. Should be an active reference to a node in the
    repository and not dynamically constructed.
: @param $snippet-node A highligted node, that contains the portions of the original
    document that should be snippeted. A common design pattern is to pass only the body
    of an article as the $snippet-node.
: @param $default-summary If a snippet-node is not included, or nothing was highlighted,
    then this variable will be used. This commonly is the first 1 or 2 paragraphs or the
    abstract of a document.
: @return A rendered HTML summary or snippet interface.
:)
define function create-summary($orig-node as node(), $snippet-node as node()?, $default-summary as item()*, $do-zoom as xs:boolean) as element()*
{
	let $uri := xdmp:node-uri($orig-node)
	let $snippets := if ($snippet-node) then create-snippets($snippet-node) else ()
	let $summary :=
		if (fn:exists($snippets)) then
			(<p class="summary">{
			for $item in $snippets/span
			return 
			    if (fn:not($do-zoom)) then
    			    <span>
    			    {$item/@title}
    			    <span>
    			    {$item/node()}
    			    <b>...</b>&nbsp;
    				</span>
    				</span>
			    else
    			    <a href="javascript:void(0);" onmouseout="$('abs_{$uri}').addClassName(hideClass);" onclick="toggleLoadedContent('abs_{fn:data($uri)}','request.xqy',{{method:'post',postBody:'action=show-section&uri={xdmp:url-encode($uri)}&path={fn:string($item/@title)}',asynchronous:true},true);">
    			    {$item/@title}
    			    <span>
    			    {$item/node()}
    			    <b>...</b>&nbsp;
    				</span>
    				</a>
			}</p>)
		else
		   $default-summary
    return
		(<div class="summary">
		{$summary, " "}
		</div>,
        <div id="abs_{$uri}" class="abstract hidden">|</div>)
}

(:~
:
: (Public) Renders snippets based on a highlighted node. The element used for
: highlighting should be <span class="ml-highlight">. sdis:highlight is a great option
: as a compatible highlighting function.
:
: @param $highlighted-node The node highlighted with <span class="ml-highlight">
: @return A <div> containing the rendered snippets.
:)
define function create-snippets($highlighted-node as node())
{ create-snippets($highlighted-node, 4, 11) }

(:~
:
: (Public) Renders snippets based on a highlighted node. The element used for
: highlighting should be <span class="ml-highlight">. sdis:highlight is a great option
: as a compatible highlighting function.
:
: @param $highlighted-node The node highlighted with <span class="ml-highlight">
: @param $max-snippet-matches The total number of snippets that are returned.
: @param $truncate-words The total number of words a snippet will contain.
: @return A <div> containing the rendered snippets.
:)
define function create-snippets($highlighted-node as node(), $max-snippet-matches as xs:integer, $truncate-words as xs:integer) as element(div)*
{
    let $matches := ($highlighted-node//span[@class="ml-highlight"])[1 to $max-snippet-matches]
    let $hits :=
        for $hit at $pos in $matches return
            (if ($pos gt 1) then " ... " else (), <span title="{xpath($hit/parent::*)}" class="ml-snippet">{
                truncate-text(<span class="ml-wrapper">{($hit/preceding-sibling::node()[1], $hit, $hit/following-sibling::node()[1])}</span>, $truncate-words)
            }</span>)
    return
    if ($hits) then
        <div class="snippets">{$hits}</div>
    else
        ()
}

(: In order for this function to work properly, you must declare all the
namespaces used in your content at the top of this file :)
define function xpath($node as node())
{
    xdmp:path($node)
}

(:~
:
: Returns the configured number of words before and after the highlight term.
:
: @param $x An item to be trucated.
: @return The truncated text.
:)
define function truncate-text($x as item(), $truncate-words as xs:integer) as item()*
{
    if (fn:empty($x)) then () else
       typeswitch($x)
       case text() return
            (: is there a highlight node before? :)
             (if ( $x/preceding-sibling::node()[1][self::span/@class = "ml-highlight"] )
                     then ((: if so, print the first $g_num words :)
                        let $tokens := cts:tokenize($x)
                        let $count := fn:count($tokens)
                        let $truncateTokens := if ( $count < $truncate-words ) (: > :)
                                          then ( $tokens )
                                          else ( $tokens[1 to $truncate-words] )
                        return
                        if ( $count < $truncate-words ) (: > :)
                        then ( (: is there a highlight node after? :)
                              if ( $x/following-sibling::node()[1][self::span/@class = "ml-highlight"] )
                              then ( (: if there is a highlight node after, we do
                                        not want to double count it :) )
                              else (
                                fn:concat(
                   (: If the first token is punctuation, then no space before :)
                                 if ($tokens[1] instance of cts:punctuation )
                                 then ("")
                                 else (" "), fn:string-join($tokens, "") )
                             ) )
                        else ( fn:concat(
                     (: If the first token is punctuation, then no space before :)
                                 if ($truncateTokens[1] instance of cts:punctuation )
                                 then ("")
                                 else (" "), fn:string-join( $truncateTokens , ""),
                                      " ")
                             )
                      )

                     else (""),
            (: is there a highlight node after? :)
            if ( $x/following-sibling::node()[1][self::span/@class = "ml-highlight"] )
            then ( (: if so, print the last $g_num words :)
                     let $tokens := cts:tokenize($x)
                     let $count := fn:count($tokens)
                     let $truncateTokens := if ( $count < $truncate-words )  (: > :)
                                 then ( $tokens )
                                 else ( $tokens[fn:last() - $truncate-words to fn:last()] )
                     return
                     if ( $count < $truncate-words ) (: > :)
                     then ( fn:concat(fn:string-join($tokens, ""),
                  (: If the last token is not punctuation, then add space after :)
                               if (fn:not($tokens[fn:last()] instance of cts:punctuation) )
                               then (" ")
                               else ("") )
                           )
                     else ( fn:concat(fn:string-join( $truncateTokens , ""),
                  (: If the last token is not punctuation, then add space after :)
                               if (fn:not($tokens[fn:last()] instance of cts:punctuation) )
                               then (" ")
                               else ("") )
                           )
                   )
              else ("" )
               )
       case element (span) return if ($x/@class = "ml-highlight") then $x else for $z in $x/node() return truncate-text($z, $truncate-words)
       default return for $z in $x/node() return truncate-text($z, $truncate-words)
}

(:~
:
: (Public) Returns a string version of any xpath in a document
:
: @param $params The parameters from the page request.
: @return The string version of any xpath in a document.
:)
define function show-section($params as element())
{
	let $uri := $params/uri
	let $path := $params/path
	let $nodeInstr := fn:concat(search:construct-prolog(), " ",
							" fn:doc('",$uri,"')",$path)
	let $node := xdmp:eval($nodeInstr)
	let $preview :=
		if(fn:exists($node)) then
			$node
		else
			"No preview available."
	return
		fn:string($preview)
}

(: Search Widgets :)

(:~
:
: (Public) A description of the query being displayed that will also
: allow users to remove individual items from their search. 
:
: @param $params The parameters from the page request.
: @return An HTML rendered, interactive description of the user's search.
:)
define function query-description($params as element(params)) as element()*
{
    if (fn:string($params/q) != "") then
    <div class="query_description">
        {("Results ",<span>for <b>{$params/q}</b></span>," ",
        if (fn:string($params/field)) then <span>in <i>{$params/field}</i></span> else (), 
        <a href="search.xqy?{uit:build-querystring($params, ("q"))}">[x]</a>)}
    </div>
    else (),
    filter-description($params)
}


(:~
:
: (Public) Information on the quanity of results and the time to render the results.
:
: @param $params The parameters from the page request.
: @param $query-time The amount of time required to execute the search.
: @param $page-info The pagination element created by lib-uitools.
: @return A rendered HTML <div> containing information on the quanity of results and the time to render the results.
:)
define function results-info(
    $params as element(params),
    $query-time as xs:duration,
	$page-info as element(pagination)
	) as element()*
{
    let $time := fn:string($query-time)
    let $time := fn:substring($time, 3, fn:string-length($time) - 3)
    return
    <div class="results_info">
	    <span>Displaying <strong>{fn:string($page-info/start)} to {fn:string($page-info/end)}</strong> of about <strong>{fn:string($page-info/count)}</strong> results. Searched in <strong>{$time}s</strong>.</span> {if ($params/*) then (" ",<a href="search.xqy">[Reset Search]</a>) else ()}</div>
}

(:~
:
: (Public) A widget which is meant to be displayed on the sidebar
: and will allow the user to choose a sort order for their results.
: Appears only when there is a full-text search. Default browse
: sort-order is used otherwise.
:
: @param $params The parameters from the page request.
: @return A select box which will allow the user to select the sort order.
:)
define function sort($params as element(params)) as element()?
{
    if (fn:string($params/q)) then
    <div style="margin: 7px 0 5px 0;">
    	<form method="get" action="search.xqy">
            <select name="sort" onchange="this.form.submit();">
            <option value="rel">
                {if (fn:empty($params/sort) or $params/sort = ("rel", "")) then attribute selected {"selected"} else ()}
                Sort by Relevence
            </option>
            <option value="date">
                {if ($params/sort = ("date")) then attribute selected {"selected"} else ()}
                Sort by Date
            </option>
            </select>
    		{for $param in uit:modify-param-set($params, ("sort"), ())/* return
            <input type="hidden" name="{fn:local-name($param)}" class="hide" value="{$param}" />}
    	</form>
    </div>
    else ()
}

(:~
:
: (Public) A widget meant for the sidebar that includes a search box and
: field select box which a user can modify their current full-text search parameters.
:
: @param $params The parameters from the page request.
: @return A search filter widget.
:)
define function search-filter($params as element()) as element()?
{
    let $hparams := uit:modify-param-set($params, "q", ())
    return
    	<form method="get" action="search.xqy">
    		<input type="text" name="q" style="width:95%;" id="quicksearch_q" class="textbox" value="{if (fn:string($params/q)) then fn:string($params/q) else ()}" />{" "}
    		{ if ($SEARCH-FIELDS) then
	            <select name="field" style="display:inline;margin:3px 3px 0 0;">
	            	{     
	    			for $option in $SEARCH-FIELDS
	    			return
						let $items := fn:tokenize($option, "\|")
						return 
							element option {
								attribute value {$items[1]},
								if((fn:not($params/field) and $items[1] = "") or $params/field eq $items[1]) then 
									attribute selected {"selected"}
								else (),
								$items[2]
							}
	    			}
			    </select>
			    else () }
    		<input type="submit" value="Filter" class="button" />
    		{for $param in $params/*[fn:not(fn:local-name(.) = ("q", "field"))] return
            <input type="hidden" name="{fn:local-name($param)}" class="hide" value="{$param}" />}
    	</form>
}

(:~
:
: (Public) Pagination controls for a page.
:
: @param $params The parameters from the page request.
: @param $page-info The pagination element created by lib-uitools.
: @return A fully functional pagination control
  Disclaimer: We acknowledge that this function is seriously lacking, so
   if you have the time and desire, please do. :)
define function pagination(
    $params as element(params),
	$page-info as element(pagination)
	) as element()*
{
    let $page := xs:integer($page-info/page)
    let $pages := xs:integer($page-info/pages)
	return
	(
        <div class="pages">
            {if ($page > 1) then
            <a class="nextprev" title="Go to Previous Page" href="search.xqy?{uit:build-querystring($params, ("p"))}&p={$page - 1}">&laquo; Previous Page</a>
            else ()
            }
            {if (($page = $pages) and ($page - 4 > 0)) then
            <a class="lastpage" title="{fn:string($page - 4)}" href="search.xqy?{uit:build-querystring($params, ("p"))}&p={$page - 4}">{fn:string($page - 4)}</a>
            else ()
            }
            {if ((($page = $pages) or ($page > $pages - 2)) and ($page - 3 > 0)) then
            <a class="lastpage" title="{fn:string($page - 3)}" href="search.xqy?{uit:build-querystring($params, ("p"))}&p={$page - 3}">{fn:string($page - 3)}</a>
            else ()
            }
            {if ((($page = $pages) or ($page > $pages - 3)) and ($page - 2 > 0)) then
            <a class="lastpage" title="{fn:string($page - 2)}" href="search.xqy?{uit:build-querystring($params, ("p"))}&p={$page - 2}">{fn:string($page - 2)}</a>
            else ()
            }
            {if (($page > 1) and ($page - 1 > 0)) then
            <a class="lastpage" title="{fn:string($page - 1)}" href="search.xqy?{uit:build-querystring($params, ("p"))}&p={$page - 1}">{fn:string($page - 1)}</a>
            else ()
            }
            {if ($page <= $pages) then
            <a class="thispage" title="{fn:string($page)}" href="search.xqy?{uit:build-querystring($params, ("p"))}&p={$page}"><strong>{fn:string($page)}</strong></a>
            else ()
            }
            {if ($page + 1 <= $pages) then
            <a class="nextpage" title="{fn:string($page + 1)}" href="search.xqy?{uit:build-querystring($params, ("p"))}&p={$page + 1}">{fn:string($page + 1)}</a>
            else ()
            }
            {if ($page + 2 <= $pages) then
            <a class="nextpage2" title="{fn:string($page + 2)}" href="search.xqy?{uit:build-querystring($params, ("p"))}&p={$page + 2}">{fn:string($page + 2)}</a>
            else ()
            }
            {if ($page + 3 <= $pages) then
            <a class="nextpage3" title="{fn:string($page + 3)}" href="search.xqy?{uit:build-querystring($params, ("p"))}&p={$page + 3}">{fn:string($page + 3)}</a>
            else ()
            }
            {if ($page + 4 <= $pages) then
            <a class="nextpage4" title="{fn:string($page + 4)}" href="search.xqy?{uit:build-querystring($params, ("p"))}&p={$page + 4}">{fn:string($page + 4)}</a>
            else ()
            }
            {if ($page + 5 <= $pages) then
            <a class="nextpage5" title="{fn:string($page + 5)}" href="search.xqy?{uit:build-querystring($params, ("p"))}&p={$page + 5}">{fn:string($page + 5)}</a>
            else ()
            }
            {if ($page + 6 <= $pages) then
            <a class="nextpage6" title="{fn:string($page + 6)}" href="search.xqy?{uit:build-querystring($params, ("p"))}&p={$page + 6}">{fn:string($page + 6)}</a>
            else ()
            }
            {if ($page + 7 <= $pages) then
            <a class="nextpage7" title="{fn:string($page + 7)}" href="search.xqy?{uit:build-querystring($params, ("p"))}&p={$page + 7}">{fn:string($page + 7)}</a>
            else ()
            }
            {if ($page + 8 <= $pages) then
            <a class="nextpage8" title="{fn:string($page + 8)}" href="search.xqy?{uit:build-querystring($params, ("p"))}&p={$page + 8}">{fn:string($page + 8)}</a>
            else ()
            }
            {if (($page = 1) and ($page + 9 <= $pages)) then
            <a class="nextpage9" title="{fn:string($page + 9)}" href="search.xqy?{uit:build-querystring($params, ("p"))}&p={$page + 9}">{fn:string($page + 9)}</a>
            else ()
            }
            {if ($page + 1 <= $pages) then
            <a class="nextpage" title="Go to Next Page" href="search.xqy?{uit:build-querystring($params, ("p"))}&p={$page + 1}">Next Page &raquo;</a>
            else ()
            }
        </div>
	)
}

define function filter-description($params as element(params)) as element()*
{
    let $search-items := report-on-search-items($params)
    return
        if ($search-items/param) then
        <div class="query_description">
            Filters <span>for</span>{" "}
            {
            for $type at $tpos in $search-items/param/type
            let $param-name as xs:string := $type/parent::param/@value
            let $type-name as xs:string := $type/@value
            let $items := get-search-items-of-type($param-name, $type-name, $params)
            return
                (if ($tpos > 1) then ", " else (),
                <span>{$type-name} = 
                {
                    for $item at $ipos in $items
                    return
                        (if ($ipos > 1) then " OR " else (), <b>{capitalize-first-chars($item)}</b>, " ",
                        <a href="search.xqy?{uit:build-querystring(uit:modify-param-set($params, $param-name, fn:concat($type-name,":",$item), ()))}">[x]</a>)
                }
                </span>
                )
            }
            {if ($params/dur[1]) then
            (" during the last ", <b>{fn:translate(fn:string($params/dur[1]), "PD", "")}{" days"}</b>, " ",
            <a href="search.xqy?{uit:build-querystring(uit:modify-param-set($params, "dur", $params/dur[1], ()))}">[x]</a>)
            else ()}
        </div>
        else ()
}

define function get-search-items-of-type (
    $param-name as xs:string,
    $type-name as xs:string,
    $params as element(params)) as xs:string*
{
    for $i in $params/*[fn:local-name(.) = $param-name]
    let $tokens := split-search-item($i)
    where $tokens[1] = $type-name
    return $tokens[2]
}

define function report-on-search-items($params as element(params))
{
    <search-item-types>{
    for $i in ("hval", "val", "col")
    let $types :=
        fn:distinct-values(
        for $item in $params/*[fn:local-name(.) = $i]
        let $tokens := split-search-item($item) 
        where fn:not(fn:lower-case($tokens[2]) = "all")
        return $tokens[1]
        )
    where $types
    return
    <param value="{$i}">{
    for $type in $types
    return
        <type value="{$type}"/>
    }</param>
    }</search-item-types>
}

define function capitalize-first-chars($text as xs:string)
{
    fn:string-join(
        for $tok in fn:tokenize($text," ") 
        return 
            fn:concat( 
                fn:upper-case(fn:substring($tok,1,1)),
                fn:substring($tok,2)
            ),
        " "
    )
}