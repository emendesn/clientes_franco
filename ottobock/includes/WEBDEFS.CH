            
#COMMAND WEB INIT <cHtml> USING <_P1> , <_P2> , <_P3> , <_P4> ;
         [ TABLES <aFiles,...>] ;
         [ TIMEOUT <tOut>] ;
         [ START <cInit>] ;
         [ CACHE <cId>] ;
         [ EXPIRES <cExpKey>] ;
         [ <lKill: NOTHREAD> ] => ;
         BEGIN SEQUENCE ;;
         WebEnvUser(<_P1>,<_P2>,<_P3>,<_P4>);;
         If !WebEnvSet(@<_P1>,@<_P2>,@<_P3>,@<_P4>,@<cHtml>, [\{ <aFiles> \} ] , [<tOut> ] , [<cInit> ], [<cId> ] , [<cExpKey> ] , [<.lKill.>]) ;;
            Return <cHtml> ;;
         Endif 
         
#COMMAND WEB END <cHtml> => ;
         END SEQUENCE;;
         WebHtmRet( @<cHtml> )

#COMMAND OPEN QUERY <cQuery> ALIAS <cAlias>  => WebOpenQuery( <cQuery>,<cAlias> )

#COMMAND CLOSE QUERY <cAlias> => ;
         WebCloseQuery(<cAlias>)
         
#TRANSLATE Criatrab(<xis> [,<y>] [,<z>] )   => Mytrab( <xis> [,<y>] [,<z>] )

#TRANSLATE ChangeQuery(<xis>)   => <xis>

#xcommand OPEN WEB TABLES <aRpcTables,...>                               ;
            =>  WebOpenTable ( \{ <aRpcTables> \} )  

