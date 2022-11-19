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

local _cKey         := "7091a08b05ffbed01360e18120050756b961a5b0"
local _cID          := "Basic ZXlKcFpDSTZJbVkyWVRWbU1qY3RaR1V5TkMwME1Ea2lMQ0pqYjJScFoyOVFkV0pzYVdOaFpHOXlJam93TENKamIyUnBaMjlUYjJaMGQyRnlaU0k2TVRReE16RXNJbk5sY1hWbGJtTnBZV3hKYm5OMFlXeGhZMkZ2SWpveGZROmV5SnBaQ0k2SWlJc0ltTnZaR2xuYjFCMVlteHBZMkZrYjNJaU9qQXNJbU52WkdsbmIxTnZablIzWVhKbElqb3hOREV6TVN3aWMyVnhkV1Z1WTJsaGJFbHVjM1JoYkdGallXOGlPakVzSW5ObGNYVmxibU5wWVd4RGNtVmtaVzVqYVdGc0lqb3hMQ0poYldKcFpXNTBaU0k2SW5CeWIyUjFZMkZ2SWl3aWFXRjBJam94TmpJeE1qY3hPREE0T0RBNWZR"
local _cURL         := "https://oauth.bb.com.br/oauth/token?"
local _aHeader
local _cHeaderPost
local _cRetPost

local _cURLBody     := "https://api.bb.com.br/cobrancas/v2/boletos"
local _aHeaBody     := {}
local _cHeadGetBody
local _cRetGetBody

local _jJsonToken
local _jJsonList

local _lContinua
local _cIndice

local _cNossoNum
local _cMenssage
local _dDataBaixa
local _dCredito
local _nValor

local _aBaixa
local _cAliasZPI
local _nPos

private lMsErroAuto := .F.


 //   PREPARE ENVIRONMENT EMPRESA "02" FILIAL "01" USER "admin" PASSWORD "2Latin3" TABLES "SM0", "SA1", "SE1", "SE9", "SEE", "ZPI", "SEA" MODULO "FIN"


    _cQuery := " SELECT ZPI.ZPI_FILIAL FILIAL, ZPI.ZPI_AGEN AGENCIA, ZPI.ZPI_CONTA CONTA, MIN( ZPI.ZPI_DTREG ) REGISTRO " + Chr(13)+Chr(10)
	_cQuery += "   FROM " + RetSqlName("ZPI") + " ZPI "												                    + Chr(13)+Chr(10)
	_cQuery += "  WHERE ZPI.D_E_L_E_T_ = ' ' "						                                                    + Chr(13)+Chr(10)
    _cQuery += "        AND ZPI.ZPI_FILIAL = '" + xFilial("ZPI") + "'"						                            + Chr(13)+Chr(10)
    _cQuery += "        AND ZPI.ZPI_DTBAIX = ' ' "						                                                + Chr(13)+Chr(10)
    _cQuery += "        AND ZPI.ZPI_DTREG <> ' ' "						                                                + Chr(13)+Chr(10)    
    _cQuery += "  GROUP BY ZPI.ZPI_FILIAL, ZPI.ZPI_AGEN, ZPI.ZPI_CONTA "						                        + Chr(13)+Chr(10)
	_cQuery += "  ORDER BY ZPI.ZPI_FILIAL, ZPI.ZPI_AGEN, ZPI.ZPI_CONTA "                                                + Chr(13)+Chr(10)

    _cQuery := ChangeQuery( _cQuery )

    TcQuery _cQuery Alias TMP_ZPI New

    TMP_ZPI->( dbGoTop() )
    while ! TMP_ZPI->( Eof() )

        // Variavel para definir se continua a pesquisa de registros no banco
        _lContinua := .T.
        _cIndice   := '0'

        while _lContinua

            // 
            // Token - Header
            // 
            _aHeader     := {}
            _cParms      := ""
            _cHeaderPost := ""
            _cRetPost    := ""

            Aadd( _aHeader, "Authorization: " +  _cID )
            Aadd( _aHeader, "Content-Type: application/x-www-form-urlencoded")

            _cParms := "grant_type=client_credentials"
            _cParms += "&scope=cobrancas.boletos-requisicao cobrancas.boletos-info"

            _cRetPost := HTTPPost( _cURL, /*cGetParms*/, _cParms, /*nTimeOut*/, _aHeader, @_cHeaderPost)

            // Transforma o retorno do token em JSON
            _jJsonToken := JsonObject():New()
            _jJsonToken:FromJson( _cRetPost ) 


            // 
            // Body
            // 
            _aHeaBody     := {}
            _cParms       := ""
            _cHeadGetBody := ""
            _cRetGetBody  := "" 

            AAdd( _aHeaBody, "Content-Type: application/json")	
            Aadd( _aHeaBody, "Authorization: Bearer "+Escape( _jJsonToken["access_token"] ) )

            _cParms := "gw-dev-app-key=" + _cKey
            _cParms += "&indicadorSituacao=B"        
            _cParms += "&agenciaBeneficiario=" + AllTrim( TMP_ZPI->AGENCIA )
            _cParms += "&contaBeneficiario=" + AllTrim( TMP_ZPI->CONTA )
            _cParms += "&dataInicioMovimento=" + StrZero( Day( SToD( TMP_ZPI->REGISTRO ) ), 2 ) + "." + StrZero( Month( SToD( TMP_ZPI->REGISTRO ) ), 2 ) + "." + StrZero( Year( SToD( TMP_ZPI->REGISTRO ) ), 4 )
            _cParms += "&indice=" + _cIndice

            _cRetGetBody := HTTPGet( _cURLBody, _cParms,/*nTimeOut*/, _aHeaBody, @_cHeadGetBody)

            // Transforma o retorno do dos titulos em JSON
            _jJsonList := JsonObject():New()
            _jJsonList:FromJson( _cRetGetBody ) 


            // Processa as informacoes do Json
            If ValType( _jJsonList ) == "J" .and. _jJsonList["quantidadeRegistros"] > 0

                // Indica no retorno se exitem mais registros para pesquisas no banco
                if _jJsonList["indicadorContinuidade"] == 'S'
                    _lContinua := .T.
                    _cIndice   := _jJsonList["proximoIndice"]
                Else
                    _lContinua := .F.                    
                Endif

                for _nPos := 1 to len( _jJsonList["boletos"] )

                    _cNossoNum  := _jJsonList["boletos"][ _nPos ]["numeroBoletoBB"]
                    _cMenssage  := _jJsonList["boletos"][ _nPos ]["estadoTituloCobranca"]
                    _dDataBaixa := CTod( StrTran( _jJsonList["boletos"][ _nPos ]["dataMovimento"], ".", "/" ) )
                    _nValor     := _jJsonList["boletos"][ _nPos ]["valorAtual"]
                    
                    _cAliasZPI := GetNextAlias()

                    _cQuery := " SELECT ZPI.R_E_C_N_O_ RECNO, ZPI.ZPI_PREFIX PREFIXO, ZPI.ZPI_NUM NUM, ZPI.ZPI_TIPO TIPO, "         + Chr(13)+Chr(10)
                    _cQuery += "        ZPI.ZPI_BANCO BANCO, ZPI.ZPI_AGEN AGENCIA, ZPI.ZPI_CONTA CONTA, "                           + Chr(13)+Chr(10)
                    _cQuery += "        SE1.E1_CLIENTE CLIENTE, SE1.E1_LOJA LOJA, SE1.E1_NATUREZ NATUREZA, ZPI.ZPI_PARC PARCELA"    + Chr(13)+Chr(10)
                    _cQuery += "   FROM " + RetSqlName("ZPI") + " ZPI (NOLOCK) "                                                    + Chr(13)+Chr(10)
                    _cQuery += "   LEFT JOIN " + RetSqlName("SE1") + " SE1 (NOLOCK) ON SE1.D_E_L_E_T_ = ' ' "                       + Chr(13)+Chr(10)
                    _cQuery += "                                                   AND SE1.E1_FILIAL = '" + xFilial("SE1") + "' "   + Chr(13)+Chr(10)
                    _cQuery += "                                                   AND SE1.E1_PREFIXO = ZPI.ZPI_PREFIX "            + Chr(13)+Chr(10)
                    _cQuery += "                                                   AND SE1.E1_NUM = ZPI.ZPI_NUM "                   + Chr(13)+Chr(10)
                    _cQuery += "                                                   AND SE1.E1_TIPO = ZPI.ZPI_TIPO "                 + Chr(13)+Chr(10)
                    _cQuery += "                                                   AND SE1.E1_PARCELA = ZPI.ZPI_PARC "              + Chr(13)+Chr(10)
                    _cQuery += "  WHERE ZPI.D_E_L_E_T_ = ' ' "                                                                      + Chr(13)+Chr(10)
                    _cQuery += "        AND ZPI.ZPI_FILIAL = '" + xFilial("ZPI") + "'"                                              + Chr(13)+Chr(10)
                    _cQuery += "        AND ZPI.ZPI_TITCLI = '" + _cNossoNum + "'"                                                  + Chr(13)+Chr(10)

                    _cQuery := ChangeQuery( _cQuery )                    

                    PLSQuery( _cQuery, _cAliasZPI )

                    (_cAliasZPI)->( dbGoTop() )
                    if .not. (_cAliasZPI)->( Eof() )

                        If AllTrim( Upper( _jJsonList["boletos"][ _nPos ]["estadoTituloCobranca"] ) ) == 'LIQUIDADO'

                            // 
                            // Baixas realizadas somente em titulos LIQUIDADOS
                            // 
                            _dCredito := CTod( StrTran( _jJsonList["boletos"][ _nPos ]["dataCredito"], ".", "/" ) )

                            Conout( "Processando Boleto Numero [" + _cNossoNum + "]" )

                            _aBaixa := {    {"E1_PREFIXO",   (_cAliasZPI)->PREFIXO,         Nil },;
                                            {"E1_NUM",       (_cAliasZPI)->NUM,             Nil },;
                                            {"E1_TIPO",      (_cAliasZPI)->TIPO,            Nil },;
                                            {"E1_CLIENTE",   (_cAliasZPI)->CLIENTE,         Nil },;
                                            {"E1_LOJA" ,     (_cAliasZPI)->LOJA,            Nil },;
                                            {"E1_NATUREZ",   (_cAliasZPI)->NATUREZA,        Nil },;
                                            {"E1_PARCELA",   (_cAliasZPI)->PARCELA,         Nil },;
                                            {"AUTMOTBX",     "NOR",                         Nil },;
                                            {"CBANCO",       (_cAliasZPI)->BANCO,           Nil },;
                                            {"CAGENCIA",     (_cAliasZPI)->AGENCIA ,        Nil },;
                                            {"CCONTA",       (_cAliasZPI)->CONTA,           Nil },;
                                            {"AUTDTBAIXA",   _dDataBaixa,                   Nil },;
                                            {"AUTDTCREDITO", _dCredito,                     Nil },;
                                            {"AUTHIST",      "BAIXA TESTE API AUTOMATICA",  Nil },;
                                            {"AUTVALREC",    _nValor,                       Nil } ;
                                        }

                            lMsErroAuto := .F.
                            MSExecAuto({|x,y,b,a| Fina070(x,y)}, _aBaixa, 3) 

                            If lMsErroAuto
                                // MostraErro()
                                Conout( "Boleto Numero [" + _cNossoNum + "] erro no momento da baixa." )

                                (_cAliasZPI)->( dbGoTo( (_cAliasZPI)->RECNO ) )
                                RecLock( "ZPI" ,.F.)
                                    ZPI->ZPI_DTREC	:= Date()
                                    ZPI->ZPI_HRREC	:= Time()
                                    ZPI->ZPI_STBAIX	:= " Erro na baixa do titulo "
                                ZPI->(dbUnlock())

                            Else

                                (_cAliasZPI)->( dbGoTo( (_cAliasZPI)->RECNO ) )
                                RecLock( "ZPI" ,.F.)
                                    ZPI->ZPI_STREC	:= _cMenssage
                                    ZPI->ZPI_DTREC	:= Date()
                                    ZPI->ZPI_HRREC	:= Time()
                                    ZPI->ZPI_DTBAIX	:= _dDataBaixa
                                    ZPI->ZPI_STBAIX	:= " Registro Baixado Corretamente "
                                ZPI->(dbUnlock())

                                Conout( "Boleto Numero [" + _cNossoNum + "] baixado corretaente." )
                            Endif

                        ElseIf AllTrim( Upper( _jJsonList["boletos"][ _nPos ]["estadoTituloCobranca"] ) ) == 'BAIXADO'

                            // 
                            // Para os titulos PROTESTADOS deve-se realizar a transferencia pra a carteira "0"
                            // 
                            _dCredito := CTod( StrTran( _jJsonList["boletos"][ _nPos ]["dataMovimento"], ".", "/" ) )

                            _aBaixa := {    {"E1_PREFIXO",   (_cAliasZPI)->PREFIXO,         Nil },;
                                            {"E1_NUM",       (_cAliasZPI)->NUM,             Nil },;
                                            {"E1_PARCELA",   (_cAliasZPI)->PARCELA,         Nil },;                                            
                                            {"E1_TIPO",      (_cAliasZPI)->TIPO,            Nil },;
                                            {"AUTDATAMOV",   _dCredito,                     Nil },;
                                            {"CBANCO",       "",                            Nil },;
                                            {"CAGENCIA",     "",                            Nil },;
                                            {"CCONTA",       "",                            Nil },;
                                            {"AUTSITUACA",   "0",                           Nil },;
                                            {"AUTNUMBCO",    "",                            Nil },;
                                            {"AUTGRVFI2",    .T.,                           Nil } ;
                                        }

                            lMsErroAuto := .F.
                            MsExecAuto({ |x, y| FINA060( x, y)}, 2, _aBaixa )

                            If lMsErroAuto
                                // MostraErro()
                                Conout( "Boleto Numero [" + _cNossoNum + "] erro no momento da trasnferencia para a certeira." )

                                (_cAliasZPI)->( dbGoTo( (_cAliasZPI)->RECNO ) )
                                RecLock( "ZPI" ,.F.)
                                    ZPI->ZPI_DTREC	:= Date()
                                    ZPI->ZPI_HRREC	:= Time()
                                    ZPI->ZPI_STBAIX	:= "Erro na transferencia para a carteira"
                                ZPI->(dbUnlock())

                            Else

                                (_cAliasZPI)->( dbGoTo( (_cAliasZPI)->RECNO ) )
                                RecLock( "ZPI" ,.F.)
                                    ZPI->ZPI_STREC	:= _cMenssage
                                    ZPI->ZPI_DTREC	:= Date()
                                    ZPI->ZPI_HRREC	:= Time()
                                    ZPI->ZPI_DTBAIX	:= _dDataBaixa
                                    ZPI->ZPI_STBAIX	:= "Transferencia realizada com sucesso"
                                ZPI->(dbUnlock())

                                Conout( "Boleto Numero [" + _cNossoNum + "] transferido corretaente." )
                            Endif


                        ElseIf AllTrim( Upper( _jJsonList["boletos"][ _nPos ]["estadoTituloCobranca"] ) ) == 'PROTESTADO'

                            // 
                            // Para os titulos PROTESTADOS deve-se realizar a transferencia pra a carteira "F"
                            // 

                            _dCredito := CTod( StrTran( _jJsonList["boletos"][ _nPos ]["dataMovimento"], ".", "/" ) )

                            _aBaixa := {    {"E1_PREFIXO",   (_cAliasZPI)->PREFIXO,         Nil },;
                                            {"E1_NUM",       (_cAliasZPI)->NUM,             Nil },;
                                            {"E1_PARCELA",   (_cAliasZPI)->PARCELA,         Nil },;                                            
                                            {"E1_TIPO",      (_cAliasZPI)->TIPO,            Nil },;
                                            {"AUTDATAMOV",   _dCredito,                     Nil },;
                                            {"CBANCO",       (_cAliasZPI)->BANCO,           Nil },;
                                            {"CAGENCIA",     (_cAliasZPI)->AGENCIA,         Nil },;
                                            {"CCONTA",       (_cAliasZPI)->CONTA,           Nil },;
                                            {"AUTSITUACA",   "F",                           Nil },;
                                            {"AUTNUMBCO",    Alltrim(_cNossoNum),           Nil },;
                                            {"AUTGRVFI2",    .T.,                           Nil } ;
                                        }

                            lMsErroAuto := .F.
                            MsExecAuto({ |x, y| FINA060( x, y)}, 2, _aBaixa )

                            If lMsErroAuto
                                // MostraErro()
                                Conout( "Boleto Numero [" + _cNossoNum + "] erro no momento da trasnferencia para a certeira." )

                                (_cAliasZPI)->( dbGoTo( (_cAliasZPI)->RECNO ) )
                                RecLock( "ZPI" ,.F.)
                                    ZPI->ZPI_DTREC	:= Date()
                                    ZPI->ZPI_HRREC	:= Time()
                                    ZPI->ZPI_STBAIX	:= "Erro na transferencia para a carteira"
                                ZPI->(dbUnlock())

                            Else

                                (_cAliasZPI)->( dbGoTo( (_cAliasZPI)->RECNO ) )
                                RecLock( "ZPI" ,.F.)
                                    ZPI->ZPI_STREC	:= _cMenssage
                                    ZPI->ZPI_DTREC	:= Date()
                                    ZPI->ZPI_HRREC	:= Time()
                                    ZPI->ZPI_DTBAIX	:= _dDataBaixa
                                    ZPI->ZPI_STBAIX	:= "Transferencia realizada com sucesso"
                                ZPI->(dbUnlock())

                                Conout( "Boleto Numero [" + _cNossoNum + "] enviado para a carteira de protesto." )
                            Endif

                        Endif

                    EndIF

                    (_cAliasZPI)->( dbCloseArea() )                    

                next

            Else
                _lContinua := .F.
            Endif

            TMP_ZPI-> ( dbSkip() )

        enddo

    enddo

    TMP_ZPI-> ( dbCloseArea() )

 //   RESET ENVIRONMENT

Return
