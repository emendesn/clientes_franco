#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "restful.ch"
#INCLUDE "topconn.ch"

/*/{Protheus.doc} JOBTIT01 - JOB para pesquisa do titulos via API
	@author Edilson Nascimento
	@since 13/07/2021
/*/
USER FUNCTION JOBTIT01()

Local cQuery

local jJsonList   :=''
local cRetGet
local cGetParms
Local aHeadStr    := {} 
local cHeaderList :=''
Local resp        :=""
local cKey        := "7091a08b05ffbed01360e18120050756b961a5b0"
local cDataIni
local cDataFim


    PREPARE ENVIRONMENT EMPRESA "02" FILIAL "01" USER "admin" PASSWORD "2Latin3" TABLES "SM0", "SA1", "SE1", "SE9", "SEE", "ZPI", "SEA" MODULO "FIN"


    cQuery := " SELECT ZPI.ZPI_BANCO, ZPI.ZPI_DTREG REGISTRO, SEE.EE_OPER, SEE.EE_AGENCIA AGENCIA, SEE.EE_CONTA CONTA "     + Chr(13)+Chr(10)
	cQuery += "    FROM " + RetSqlName("ZPI") + " ZPI "												                        + Chr(13)+Chr(10)
    cQuery += "    LEFT JOIN " + RetSqlName("SE1") + " SE1 ON  "                                                            + Chr(13)+Chr(10)
    cQuery += "              ZPI.ZPI_PREFIX = SE1.E1_PREFIXO and ZPI.ZPI_NUM = SE1.E1_NUM "                                 + Chr(13)+Chr(10)
    cQuery += "              AND ZPI.ZPI_NUM = SE1.E1_NUM "                                                                 + Chr(13)+Chr(10)
    cQuery += "    LEFT JOIN " + RetSqlName("SEE") + " SEE ON ZPI.ZPI_BANCO = SEE.EE_CODIGO "                               + Chr(13)+Chr(10)
	cQuery += " WHERE ZPI.ZPI_DTBAIX = ' ' "						                                                        + Chr(13)+Chr(10)
    cQuery += "       AND ZPI.ZPI_DTREG <> ' ' "						                                                    + Chr(13)+Chr(10)
    cQuery += "       AND ZPI.ZPI_BANCO = '001' "						                                                    + Chr(13)+Chr(10)    
    cQuery += "       AND ZPI.D_E_L_E_T_ <> '*' "						                                                    + Chr(13)+Chr(10)
	cQuery += " ORDER BY ZPI.ZPI_DTREG "                                                                                    + Chr(13)+Chr(10)

    TCQUERY cQuery Alias TMP_ZPI New

    TMP_ZPI->( dbGoTop() )

    If ! TMP_ZPI->( Eof() )

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


