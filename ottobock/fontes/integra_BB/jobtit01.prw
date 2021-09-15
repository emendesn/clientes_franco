#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "restful.ch"
#INCLUDE "topconn.ch"

//BRWAPIZPI

/*/{Protheus.doc} JOBTIT01 - JOB para pesquisa do titulos via API
	@author Edilson Nascimento
	@since 13/07/2021
/*/
USER FUNCTION JOBTIT01()

Local _cQuery

local _cKey
local _cID
local _cURL
local _aHeader
local _cParms
local _cHeaderGet
local _cRetPost
local _cURLBody
local _aHeaBody
local _cRetGetBody
local _cRetPostBody

local _cDataIni
local _cDataFim
local _cConvenio
local _cAgencia
local _cConta

local jJsonList     :=''
local cRetGet
local cGetParms
Local aHeadStr      := {} 
local cHeaderList   :=''
Local resp          :=""
local _aBaixa
local _nPos

local lHomologa     := .F.

private lMsErroAuto := .F.


   // PREPARE ENVIRONMENT EMPRESA "02" FILIAL "01" USER "admin" PASSWORD "2Latin3" TABLES "SM0", "SA1", "SE1", "SE9", "SEE", "ZPI", "SEA" MODULO "FIN"


    _cQuery := " SELECT ZPI.ZPI_AGEN AGENCIA, ZPI.ZPI_CONTA CONTA "                                                     + Chr(13)+Chr(10)
	_cQuery += "   FROM " + RetSqlName("ZPI") + " ZPI "												                    + Chr(13)+Chr(10)
	_cQuery += "  WHERE ZPI.D_E_L_E_T_ = ' ' "						                                                    + Chr(13)+Chr(10)
    _cQuery += "        AND ZPI.ZPI_DTBAIX = ' ' "						                                                + Chr(13)+Chr(10)
    _cQuery += "        AND ZPI.ZPI_DTREG <> ' ' "						                                                + Chr(13)+Chr(10)    
    _cQuery += "  GROUP BY ZPI.ZPI_AGEN, ZPI.ZPI_CONTA "						                                        + Chr(13)+Chr(10)
	_cQuery += "  ORDER BY ZPI.ZPI_AGEN, ZPI.ZPI_CONTA "                                                                + Chr(13)+Chr(10)

    _cQuery := ChangeQuery( _cQuery )

    TcQuery _cQuery Alias TMP_ZPI New

    TMP_ZPI->( dbGoTop() )
    If ! TMP_ZPI->( Eof() )

        if lHomologa

            _cKey           := "d27b977903ffab701360e17d00050f56b9e1a5b0"

// ED            _cID            := "Basic ZXlKcFpDSTZJakk1T0RrNFpESXRaV0UyTkMwME5HWXhMU0lzSW1OdlpHbG5iMUIxWW14cFkyRmtiM0lpT2pBc0ltTnZaR2xuYjFOdlpuUjNZWEpsSWpveE5Ea3dNQ3dpYzJWeGRXVnVZMmxoYkVsdWMzUmhiR0ZqWVc4aU9qRjk6ZXlKcFpDSTZJakV4WVRFaUxDSmpiMlJwWjI5UWRXSnNhV05oWkc5eUlqb3dMQ0pqYjJScFoyOVRiMlowZDJGeVpTSTZNVFE1TURBc0luTmxjWFZsYm1OcFlXeEpibk4wWVd4aFkyRnZJam94TENKelpYRjFaVzVqYVdGc1EzSmxaR1Z1WTJsaGJDSTZNU3dpWVcxaWFXVnVkR1VpT2lKb2IyMXZiRzluWVdOaGJ5SXNJbWxoZENJNk1UWXhPRFE1TVRRME1UazVPWDA="                    
            _cID            := "Basic ZXlKcFpDSTZJbVkyWVRWbU1qY3RaR1V5TkMwME1Ea2lMQ0pqYjJScFoyOVFkV0pzYVdOaFpHOXlJam93TENKamIyUnBaMjlUYjJaMGQyRnlaU0k2TVRReE16RXNJbk5sY1hWbGJtTnBZV3hKYm5OMFlXeGhZMkZ2SWpveGZROmV5SnBaQ0k2SWlJc0ltTnZaR2xuYjFCMVlteHBZMkZrYjNJaU9qQXNJbU52WkdsbmIxTnZablIzWVhKbElqb3hOREV6TVN3aWMyVnhkV1Z1WTJsaGJFbHVjM1JoYkdGallXOGlPakVzSW5ObGNYVmxibU5wWVd4RGNtVmtaVzVqYVdGc0lqb3hMQ0poYldKcFpXNTBaU0k2SW5CeWIyUjFZMkZ2SWl3aWFXRjBJam94TmpJeE1qY3hPREE0T0RBNWZR"
            _cURL           := "https://oauth.sandbox.bb.com.br/oauth/token"

            _aHeader        := {}
            _cParms         := ""
            _cHeaderGet     := ""
            _cRetPost       := ""

            _cURLBody       := "https://api.bb.com.br/cobrancas/v2/boletos?gw-dev-app-key=" + _cKey
            _aHeaBody       := {}
            _cRetGetBody    := ""
            _cRetPostBody   := ""

            _cDataIni       := "15.12.2020"
            _cDataFim       := "31.03.2021"
            _cConvenio      := "123873"
            _cAgencia       := "452"
            _cConta         := "23873"

        else

            _cKey           := "7091a08b05ffbed01360e18120050756b961a5b0"
// ED         _cID            := "Basic ZXlKcFpDSTZJbVkyWVRWbU1qY3RaR1V5TkMwME1Ea2lMQ0pqYjJScFoyOVFkV0pzYVdOaFpHOXlJam93TENKamIyUnBaMjlUYjJaMGQyRnlaU0k2TVRReE16RXNJbk5sY1hWbGJtTnBZV3hKYm5OMFlXeGhZMkZ2SWpveGZROmV5SnBaQ0k2SWlJc0ltTnZaR2xuYjFCMVlteHBZMkZrYjNJaU9qQXNJbU52WkdsbmIxTnZablIzWVhKbElqb3hOREV6TVN3aWMyVnhkV1Z1WTJsaGJFbHVjM1JoYkdGallXOGlPakVzSW5ObGNYVmxibU5wWVd4RGNtVmtaVzVqYVdGc0lqb3hMQ0poYldKcFpXNTBaU0k2SW5CeWIyUjFZMkZ2SWl3aWFXRjBJam94TmpJeE1qY3hPREE0T0RBNWZR"            
// ED 2            _cID            := "Basic ZXlKcFpDSTZJakk1T0RrNFpESXRaV0UyTkMwME5HWXhMU0lzSW1OdlpHbG5iMUIxWW14cFkyRmtiM0lpT2pBc0ltTnZaR2xuYjFOdlpuUjNZWEpsSWpveE5Ea3dNQ3dpYzJWeGRXVnVZMmxoYkVsdWMzUmhiR0ZqWVc4aU9qRjk6ZXlKcFpDSTZJakV4WVRFaUxDSmpiMlJwWjI5UWRXSnNhV05oWkc5eUlqb3dMQ0pqYjJScFoyOVRiMlowZDJGeVpTSTZNVFE1TURBc0luTmxjWFZsYm1OcFlXeEpibk4wWVd4aFkyRnZJam94TENKelpYRjFaVzVqYVdGc1EzSmxaR1Z1WTJsaGJDSTZNU3dpWVcxaWFXVnVkR1VpT2lKb2IyMXZiRzluWVdOaGJ5SXNJbWxoZENJNk1UWXhPRFE1TVRRME1UazVPWDA="
            _cID            := "Basic ZXlKcFpDSTZJbVkyWVRWbU1qY3RaR1V5TkMwME1Ea2lMQ0pqYjJScFoyOVFkV0pzYVdOaFpHOXlJam93TENKamIyUnBaMjlUYjJaMGQyRnlaU0k2TVRReE16RXNJbk5sY1hWbGJtTnBZV3hKYm5OMFlXeGhZMkZ2SWpveGZROmV5SnBaQ0k2SWlJc0ltTnZaR2xuYjFCMVlteHBZMkZrYjNJaU9qQXNJbU52WkdsbmIxTnZablIzWVhKbElqb3hOREV6TVN3aWMyVnhkV1Z1WTJsaGJFbHVjM1JoYkdGallXOGlPakVzSW5ObGNYVmxibU5wWVd4RGNtVmtaVzVqYVdGc0lqb3hMQ0poYldKcFpXNTBaU0k2SW5CeWIyUjFZMkZ2SWl3aWFXRjBJam94TmpJeE1qY3hPREE0T0RBNWZR"
// ED            _cURL           := AllTrim( GetMV("AP_URLBRP") ) + _cKey  // AllTrim( GetMV("AP_URLBTP") )
            _cURL           := "https://oauth.bb.com.br/oauth/token"
            _aHeader        := {}
            _cParms         := ""
            _cHeaderGet     := ""
            _cRetPost       := ""

            _cURLBody       := "https://api.bb.com.br/cobrancas/v2/boletos?gw-dev-app-key=" + _cKey
            _aHeaBody       := {}
            _cRetGetBody    := ""
            _cRetPostBody   := "" 

            _cDataIni       := StrZero( Day( SToD( TMP_ZPI->REGISTRO ) ), 2 ) + "." + StrZero( Month( SToD( TMP_ZPI->REGISTRO ) ), 2 ) + "." + StrZero( Year( SToD( TMP_ZPI->REGISTRO ) ), 4 )
            _cDataFim       := StrZero( Day( Date() ), 2 ) + "." + StrZero( Month( Date() ), 2 ) + "." + StrZero( Year( Date() ), 4 )
            _cConvenio      := AllTrim( TMP_ZPI->CONVENIO )
            _cAgencia       := AllTrim( TMP_ZPI->AGENCIA )
            _cConta         := AllTrim( TMP_ZPI->CONTA )


        Endif

        // Periodo de Pesquisa


        // Header
        Aadd( _aHeader, "Authorization: " +  _cID )
        Aadd( _aHeader, "Content-Type: application/x-www-form-urlencoded")

        /// Body Campos
        _cParms := "grant_type=client_credentials"
        _cParms += "&scope=cobrancas.boletos-requisicao cobrancas.boletos-info"
        //_cParms += "&scope=cobrancas.boletos-info cobrancas.boletos-requisicao"


        _cRetPost := HTTPPost( _cURL, /*cGetParms*/, _cParms, /*nTimeOut*/, _aHeader, @_cHeaderGet)

        //Transforma o retorno em um JSON
        jJsonToken := JsonObject():New()
        jJsonToken:FromJson( _cRetPost ) 


        // Body
        AAdd( _aHeaBody, "Content-Type: application/json")	
        Aadd( _aHeaBody, "Authorization: Bearer "+Escape(jJsonToken["access_token"] ) )
//        Aadd( _aHeaBody, "Accept: */*")
//        Aadd( _aHeaBody, "Connection: keep-alive")

        // _cParms := "gw-dev-app-key=" + _cKey
        _cParms := "numeroConvenio=" + _cConvenio
        _cParms += "&agenciaBeneficiario=" + _cAgencia
        _cParms += "&contaBeneficiario=" + _cConta
        _cParms += '&indicadorSituacao="B"'
        _cParms += "&indice=300"
        _cParms += "&codigoEstadoTituloCobranca=7"
        _cParms += "&dataInicioMovimento=" + _cDataIni
        _cParms += "&dataFimMovimento="  + _cDataFim

        cRetGet := HTTPGet( _cURLBody, _cParms,/*nTimeOut*/, _aHeaBody, @_cRetGetBody)

        _cRetPostBody := HttpPost( _cURLBody ,/*cGetParms*/, _cParms,/*nTimeOut*/, _aHeaBody, @_cRetGetBody)



//    --------- Alteracao Edilson

        //
        // Define a data para pesquisa dos registro no banco
        //
        cDataIni := StrZero( Day( SToD( TMP_ZPI->REGISTRO ) ), 2 ) + "." + StrZero( Month( SToD( TMP_ZPI->REGISTRO ) ), 2 ) + "." + StrZero( Year( SToD( TMP_ZPI->REGISTRO ) ), 4 )
        cDataFim := StrZero( Day( Date() ), 2 ) + "." + StrZero( Month( Date() ), 2 ) + "." + StrZero( Year( Date() ), 4 )


        cUrlListar := "https://api.sandbox.bb.com.br/cobrancas/v1/boletos"
        Aadd(aHeadStr, "Content-Type: application/x-www-form-urlencoded")
        Aadd(aHeadStr, "Authorization: Bearer " + Escape( BBrasilToken() ) )
        Aadd(aHeadStr, "Accept: */*")
        Aadd(aHeadStr, "Connection: keep-alive")
        Aadd(aHeadStr, "Host: 177.73.0.138")

        cGetParms := 'gw-dev-app-key|' + cKey
        cGetParms += "&agenciaBeneficiario|" + AllTrim( TMP_ZPI->AGENCIA )
        cGetParms += "&contaBeneficiario|" + AllTrim( TMP_ZPI->AGENCIA )
        cGetParms += '&indicadorSituacao|"B"'
        cGetParms += "&indice|300"
        cGetParms += "&codigoEstadoTituloCobranca|7"
        cGetParms += "&dataInicioMovimento|" + cDataIni
        cGetParms += "&dataFimMovimento|"  + cDataFim

        cPostParms:="gw-dev-app-key=SUA KEY AQUI &agenciaBeneficiario=452&contaBeneficiario=123873&indicadorSituacao=B&indice=300&codigoEstadoTituloCobranca=7&dataInicioMovimento=04.09.2020&dataFimMovimento=09.09.2020"

        //
        // Efetua o POST na API
        //
        cRetGet := HTTPGet(cUrlListar, "gw-dev-app-key=SUA KEY AQUI&agenciaBeneficiario=452&contaBeneficiario=123873&indicadorSituacao=B&indice=300&codigoEstadoTituloCobranca=7&dataInicioMovimento=04.09.2020&dataFimMovimento=09.09.2020",/*nTimeOut*/, aHeadStr, @cHeaderList)

        resp := HTTPGetStatus(cHeaderList)


        //
        // Transforma o retorno em um JSON
        //
        jJsonList := JsonObject():New()
        jJsonList:FromJson(cRetGet)


        If ValType( jJsonList ) == "A" .and. Len( jJsonList ) > 0

            for _nPos := 1 to len( jJsonList )

                    _aBaixa := {    {"E1_PREFIXO",  jJsonList['prefixo'] ,Nil },;
                                    {"E1_NUM",      jJsonList['titulo']  ,Nil },;
                                    {"E1_TIPO",     jJsonList['tipo'] ,Nil },;
                                    {"E1_CLIENTE",  jJsonList['cliente'] ,Nil },;
                                    {"E1_LOJA" ,    jJsonList['loja'] ,Nil },;
                                    {"E1_NATUREZ",  jJsonList['natureza'],Nil },;
                                    {"E1_PARCELA",  " " ,Nil },;
                                    {"AUTMOTBX",    "001" ,Nil },;
                                    {"CBANCO",      jJsonList['banco'] ,Nil },;
                                    {"CAGENCIA",    jJsonList['agencia'] ,Nil },;
                                    {"CCONTA",      jJsonList['conta'] ,Nil },;
                                    {"AUTDTBAIXA",  CtoD( jJsonList['baixa'] ) ,Nil },;
                                    {"AUTDTCREDITO", CtoD( jJsonList['credito'] ) ,Nil },;
                                    {"AUTHIST",     "BAIXA ROTINA AUTOMATICA" ,Nil } ;
                                }

                MSExecAuto({|x,y,b,a| Fina070(x,y,b,a)}, _aBaixa,6,.F., 3) 

                If lMsErroAuto
                    MostraErro()
                Else
                    conout("BAIXADO COM SUCESSO!" + jJsonList['titulo'] )
                Endif

            next

        Endif

    EndIf

    TMP_ZPI-> ( dbCloseArea() )

    RESET ENVIRONMENT

Return



/*/{Protheus.doc} BBrasilToken - Retorna o Token do banco
	@author Edilson Nascimento
	@since 13/07/2021
/*/
STATIC FUNCTION BBrasilToken()

local cUrl
local cPostParms
local aHeadStr   :={}//as array
local cHeaderGet
local cRetPost
local cBasic     := "Basic ZXlKcFpDSTZJbVkyWVRWbU1qY3RaR1V5TkMwME1Ea2lMQ0pqYjJScFoyOVFkV0pzYVdOaFpHOXlJam93TENKamIyUnBaMjlUYjJaMGQyRnlaU0k2TVRReE16RXNJbk5sY1hWbGJtTnBZV3hKYm5OMFlXeGhZMkZ2SWpveGZROmV5SnBaQ0k2SWlJc0ltTnZaR2xuYjFCMVlteHBZMkZrYjNJaU9qQXNJbU52WkdsbmIxTnZablIzWVhKbElqb3hOREV6TVN3aWMyVnhkV1Z1WTJsaGJFbHVjM1JoYkdGallXOGlPakVzSW5ObGNYVmxibU5wWVd4RGNtVmtaVzVqYVdGc0lqb3hMQ0poYldKcFpXNTBaU0k2SW5CeWIyUjFZMkZ2SWl3aWFXRjBJam94TmpJeE1qY3hPREE0T0RBNWZR"

    // 
    // Ambiente
    //
    If AllTrim( GetMV("AP_APBAMB") ) == '2'
        cUrl := AllTrim( GetMV("AP_URLBTP") )

    Else
        cUrl := AllTrim( GetMV("AP_URLBTH") )
    EndIf

    Aadd(aHeadStr, "Authorization: " + cBasic )
    Aadd(aHeadStr, "Content-Type: application/x-www-form-urlencoded")

    // 
    // Body campos
    //
    cPostParms := "grant_type=client_credentials"
    cPostParms += "&scope=cobrancas.boletos-info cobrancas.boletos-requisicao"

    // 
    // Efetua o POST na API
    //
    cRetPost := HTTPPost( cUrl, /*cGetParms*/, cPostParms, /*nTimeOut*/, aHeadStr, @cHeaderGet)

    // 
    // Transforma o retorno em um JSON
    //
    jJsonToken := JsonObject():New()
    jJsonToken:FromJson( cRetPost )

return (jJsonToken)


