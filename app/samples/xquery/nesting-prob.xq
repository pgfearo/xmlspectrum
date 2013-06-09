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