#INCLUDE "totvs.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "fwbrowse.ch"
#INCLUDE "fwmvcdef.ch"
#INCLUDE "rwmake.ch"


// Array com os pedidos seleconados
#DEFINE pPED_MRK_STEP_2                   1
#DEFINE pPED_MRK_STEP_3                   2
#DEFINE pPED_PEDIDO                       3
#DEFINE pPED_COD_PROD                     4
#DEFINE pPED_DESC_PROD                    5
#DEFINE pPED_PESO_MINIMO_PRODUTO_TRANSP   6
#DEFINE pPED_PESO_PRODUTO                 7
#DEFINE pPED_CAIXA_PRODUTO                8
#DEFINE pPED_SALDO_PEDIDO                 9
#DEFINE pPED_SALDO_CORTE                 10
#DEFINE pPED_MANIFESTO                   11
#DEFINE pPED_MOTIVO_CORTE                12
#DEFINE pPED_PERCENTUAL_CORTE            13
#DEFINE pPED_CODIGO_CLIENTE              14
#DEFINE pPED_LOJA_CLIENTE                15
#DEFINE pPED_NOME_CLIENTE                16
#DEFINE pPED_BAIRRO_CLIENTE              17
#DEFINE pPED_CIDADE_CLIENTE              18



// Contantes para o Step 2
#DEFINE pST2_CORTE                        1
#DEFINE pST2_PRODUTO                      2
#DEFINE pST2_DESCRICAO                    3
#DEFINE pST2_SALDO_PEDIDO                 4
#DEFINE pST2_SALDO_CORTE                  5
#DEFINE pST2_MOTIVO_CORTE                 6
#DEFINE pST2_MANIFESTO                    7
#DEFINE pST2_PERCENTUAL_CORTE             8
#DEFINE pST2_ITEMS                        9

#DEFINE pST2_ITEM_PEDIDO                  1
#DEFINE pST2_ITEM_SALDO_PEDIDO            2
#DEFINE pST2_ITEM_SALDO_CORTE             3



// Contantes para o Step 3
#DEFINE pST3_CORTE                        1
#DEFINE pST3_PRODUTO                      2
#DEFINE pST3_DESC_PROD                    3
#DEFINE pST3_NOME_CLIENTE                 4
#DEFINE pST3_BAIRRO                       5
#DEFINE pST3_CIDADE                       6
#DEFINE pST3_PEDIDO                       7
#DEFINE pST3_MANIFESTO                    8
#DEFINE pST3_QTDE_DISP                    9
#DEFINE pST3_QTDE_CORTE                  10
#DEFINE pST3_PESO_MINIMO_PRODUTO_TRANSP  11
#DEFINE pST3_PESO_PRODUTO                12
#DEFINE pST3_PESO_ATUAL                  13
#DEFINE pST3_QTD_CAIXA                   14



/*/{Protheus.doc} GERACOR01 - Rotina de Gera Corte
	@author Edilson Nascimento
	@since 13/07/2021
/*/
USER FUNCTION GERACO01()

local _lContinua        := .T.
local _nFase            := 1
local _oDlg1
local _aTblMotvCort      := { }

local _cPedidoDe	:= '932257'   //'823295'   //  Space(6)
local _cPedidoAte       := '932258'   //'930610'   // Space(6)
local _cManiDe          := '      '   // Space(6)
local _cManiAte         := '999999'   // Space(6)
local _dEmissaoDe       := CTod('01/01/20')
local _dEmissaoAte      := CTod('31/12/21')
local _cFormaProce      := Space(1)
local _oCboFormaProce
local _cFilRate         := Space(1)
local _oCboFilRate
local _cVldPeso         := Space(1)
local _oCboVldPeso
local _cCboMotivoCorte  := Space(1)
local _oCboMotivoCorte
local _nPercCorte       := 50
local _cQuery
local _cArqQRY

local _aSize            := MsAdvSize()
local _oDlg2
local _oPainel2
local _oBrowStep2
local _aStep2
local _aButtons2        := {}
local _oDlg3
local _oPainel3
local _oBrowStep3
local _aStep3
local _lValidPesoTransp
local _aButtons3        := {}
local _nPesoAtual

local _aPedidos
local _nPos
local _nPointer
local _nCount
local _lAtuFase2        := .F.
local _lAtuFase3        := .F.

local _oOk              := LoadBitMap(GetResources(), "LBOK")
local _oNo              := LoadBitMap(GetResources(), "LBNO")

local _aCabec
local _aItens
local _aLinha
local _nQtdVen
local _nPrcTotal
local _nQtdUnsVen
local _cMtvCorte
local _dDtaCorte
local _nTotItens
local _lDeletItem
local _aErroAuto
local _cLogErro
local _nOpcX

private lMSHelpAuto := .T.
private lMsErroAuto := .F.


	If LockByName("GERACO01", .F., .F.)

                while _lContinua

                        while _nFase == 1

                                // Carrega o motivo do Corte para Selecao
                                If SX5->( dbSetOrder(1), dbSeek( xFilial("SX5") + "Z4" ) )
                                        while SX5->X5_TABELA == 'Z4' .and. ;
                                                SX5->( .not. Eof() )
                                                AAdd( _aTblMotvCort, Alltrim( SX5->X5_CHAVE ) + "-" + Alltrim( SX5->X5_DESCRI ) )
                                                SX5->( dbSkip() )
                                        enddo
                                Else
                                        AAdd( _aTblMotvCort, " " )
                                EndIf

                                // Monta a tela de parametros para o usuario
                                @ 00,00 TO 510,370 DIALOG _oDlg1 TITLE OemToAnsi( "Parametros para Corte de Pedido." )
                                @ 05,05 TO 230,180 TITLE OemToAnsi( " Parametros " )

                                @ 20,018        SAY     "Pedido de:"
                                @ 20,085        GET     _cPedidoDe                ;
                                                PICTURE "@99"                     ;
                                                VALID   .T.

                                @ 35,018        SAY     "Pedido Ate:"
                                @ 35,085        GET     _cPedidoAte               ;
                                                PICTURE "@9999"                   ;
                                                VALID   .T.

                                @ 50,018        SAY     "Manifesto de:"
                                @ 50,085        GET     _cManiDe                  ;
                                                PICTURE "@!"                      ;
                                                VALID   .T.

                                @ 70,018        SAY     "Manifesto de:"
                                @ 70,085        GET     _cManiAte                 ;
                                                PICTURE "@!"                      ;
                                                VALID   .T.

                                @ 90,018        SAY     "Emissao de:"
                                @ 90,085        GET     _dEmissaoDe               ;
                                                PICTURE "@D"                      ;
                                                SIZE    40,20                     ;
                                                VALID   iif( .not. empty( _dEmissaoDe ), .T., ( msgAlert("Informa o data de Emissao!","Atencao"), .F. ) )

                                @ 110,018       SAY     "Emissao ate:"
                                @ 110,085       GET     _dEmissaoAte              ;
                                                PICTURE "@D"                      ;
                                                SIZE    40,20                     ;
                                                VALID   iif( .not. empty( _dEmissaoAte ), .T., ( msgAlert("Data da emissao deve ser maior que a data incial!","Atencao"), .F. ) )

                                @ 130,018       SAY     "Forma de Processamento:"

                                @ 130,085       COMBOBOX _oCboFormaProce          ;
                                                VAR     _cFormaProce              ;
                                                ITEMS   {  "1 - Do Maior p/ Menor", "2 - Do Menor p/ Maior" }  ;
                                                SIZE    70,20                     ;
                                                PIXEL                             ;
                                                OF      _oDlg1

                                @ 150,018       SAY     "Fill Rate:"
                                @ 150,085       COMBOBOX _oCboFilRate             ;
                                                VAR     _cFilRate                 ;
                                                ITEMS   {  "1 - Sim", "2 - Nao" } ;
                                                SIZE    40,20                     ;
                                                PIXEL                             ;
                                                OF      _oDlg1

                                @ 170,018       SAY     "Valida Peso:  : "
                                @ 170,085       COMBOBOX _oCboVldPeso             ;
                                                VAR     _cVldPeso                 ;
                                                ITEMS   {  "1 - Sim", "2 - Nao" } ;
                                                SIZE    40,20                     ;
                                                PIXEL                             ;
                                                OF      _oDlg1

                                @ 190,018       SAY     "Motivo Corte:"
                                @ 190,085       COMBOBOX _oCboMotivoCorte         ;
                                                VAR      _cCboMotivoCorte         ;
                                                ITEMS   _aTblMotvCort             ;
                                                SIZE    90,20                     ;
                                                PIXEL                             ;
                                                OF      _oDlg1

                                @ 210,018       SAY     "Percentual Corte:"
                                @ 210,085       GET     _nPercCorte               ;
                                                PICTURE "@E 999"+"%"              ;
                                                SIZE    40,20                     ;
                                                VALID   iif( _nPercCorte > 0 .and. _nPercCorte <= 100, .T., ( msgAlert("Percentual de corte incorreto !","Atencao"), .F. ) )


                                @ 240,110 BMPBUTTON TYPE 01 ACTION ( _nFase++, Close(_oDlg1) )
                                @ 240,140 BMPBUTTON TYPE 02 ACTION ( _nFase--, _lContinua := .F., Close(_oDlg1) )

                                ACTIVATE  DIALOG _oDlg1 CENTER

                                // Seleciona as informacoes conforme o parametro
                                If _lContinua

                                        _cArqQRY := GetNextAlias()

                                        _cQuery := " SELECT SC5.C5_NUM PEDIDO, SC5.C5_TIPO TIPO_PEDIDO, SC5.C5_X_MAN MANIFESTO, SC5.C5_CONDPAG CONDPAG, "           + Chr(13)+Chr(10)
                                        _cQuery += "        SC5.R_E_C_N_O_ RECNO, SB1.B1_DESC DESCRICAO, SB1.B1_PESO PESO_PRODUTO, SB1.B1_CONV QTD_CAIXA, "         + Chr(13)+Chr(10)
                                        _cQuery += "        SC6.C6_PRODUTO PRODUTO,  SC6.C6_ITEM ITEM_PRODUTO, SC6.C6_X_MTVCT MOT_CORTE, SC6.C6_QTDVEN VENDIDO, "   + Chr(13)+Chr(10)
                                        _cQuery += "        SC6.C6_QTDENT ENTREGUE, SC6.C6_TES TES, SC6.C6_PRCVEN PRECO_VENDA, SC6.C6_PRUNIT PRECO_UNITARIO, "      + Chr(13)+Chr(10)
                                        _cQuery += "        SC6.C6_UNSVEN UNSVEN, SA1.A1_COD CODIGO, SA1.A1_LOJA LOJA, A1_NOME CLIENTE, SA1.A1_BAIRRO BAIRRO, "     + Chr(13)+Chr(10)
                                        _cQuery += "        SA1.A1_MUN CIDADE, SA4.A4_X_PSMIN PESO_MINIMO_TRANSP"                                                          + Chr(13)+Chr(10)
                                        _cQuery += "   FROM " + RetSqlName("SC5") + " SC5 (NOLOCK) "								    + Chr(13)+Chr(10)
                                        _cQuery += "  INNER JOIN " + RetSqlName("SC6") + " SC6 (NOLOCK) ON SC6.D_E_L_E_T_ = ''"					    + Chr(13)+Chr(10)
                                        _cQuery += "                               AND SC6.C6_FILIAL = '" + xFilial("SC6") + "' AND SC5.C5_NUM = SC6.C6_NUM"	    + Chr(13)+Chr(10)
                                        _cQuery += "                               AND SC5.C5_NUM = SC6.C6_NUM"						            + Chr(13)+Chr(10)
                                        _cQuery += "                               AND SC6.C6_BLQ NOT IN('S ')"					                    + Chr(13)+Chr(10)
                                        _cQuery += "  INNER JOIN " + RetSqlName("SB1") + " SB1 (NOLOCK) ON SB1.D_E_L_E_T_ = ''"					    + Chr(13)+Chr(10)
                                        _cQuery += "                               AND SB1.B1_FILIAL = '" + xFilial("SB1") + "'"		                    + Chr(13)+Chr(10)
                                        _cQuery += "                               AND SC6.C6_PRODUTO = SB1.B1_COD"					            + Chr(13)+Chr(10)
                                        _cQuery += "  INNER JOIN " + RetSqlName("SA1") + " SA1 (NOLOCK) ON SA1.D_E_L_E_T_ = ''"					    + Chr(13)+Chr(10)
                                        _cQuery += "                               AND SA1.A1_FILIAL = '" + xFilial("SA1") + "'"		                    + Chr(13)+Chr(10)
                                        _cQuery += "                               AND SA1.A1_COD = SC5.C5_CLIENTE"					            + Chr(13)+Chr(10)
                                        _cQuery += "                               AND SA1.A1_LOJA = SC5.C5_LOJACLI"					            + Chr(13)+Chr(10)
                                        _cQuery += "  LEFT JOIN " + RetSqlName("SA4") + " SA4 (NOLOCK) ON SA4.D_E_L_E_T_ = ''"					    + Chr(13)+Chr(10)
                                        _cQuery += "                               AND SA4.A4_FILIAL = '" + xFilial("SA4") + "'"		                    + Chr(13)+Chr(10)
                                        _cQuery += "                               AND SA4.A4_COD = SC5.C5_TRANSP"					            + Chr(13)+Chr(10)
                                        _cQuery += "  LEFT JOIN " + RetSqlName("Z20") + " Z20 (NOLOCK) ON Z20.D_E_L_E_T_ = ''"					    + Chr(13)+Chr(10)
                                        _cQuery += "                               AND Z20.Z20_FILIAL = '" + xFilial("Z20") + "'"		                    + Chr(13)+Chr(10)
                                        _cQuery += "                               AND Z20.Z20_NUMERO = SC5.C5_X_MAN"					            + Chr(13)+Chr(10)
                                        _cQuery += "  LEFT JOIN " + RetSqlName("SZP") + " SZP (NOLOCK) ON SZP.D_E_L_E_T_ = ''"					    + Chr(13)+Chr(10)
                                        _cQuery += "                               AND SZP.ZP_FILIAL = '" + xFilial("SZP") + "'"		                    + Chr(13)+Chr(10)
                                        _cQuery += "                               AND SZP.ZP_PEDIDO = SC5.C5_NUM"					            + Chr(13)+Chr(10)
                                        _cQuery += "                               AND SZP.ZP_STATUS = 'Liberado' "                                                 + Chr(13)+Chr(10)
                                        _cQuery += "  LEFT OUTER JOIN " + RetSqlName("SC9") + " SC9 (NOLOCK) ON SC9.D_E_L_E_T_ = ''"			            + Chr(13)+Chr(10)
                                        _cQuery += "                               AND SC9.C9_FILIAL = '" + xFilial("SC9") + "'"		                    + Chr(13)+Chr(10)
                                        _cQuery += "                               AND SC9.C9_PEDIDO = SC5.C5_NUM"					            + Chr(13)+Chr(10)
                                        _cQuery += "                               AND SC9.C9_ITEM = SC6.C6_ITEM"					            + Chr(13)+Chr(10)
                                        _cQuery += "  WHERE SC5.D_E_L_E_T_ <> '*' "						                                    + Chr(13)+Chr(10)
                                        _cQuery += "        AND SC5.C5_FILIAL = '" + xFilial("SC5") + "'"						            + Chr(13)+Chr(10)
                                        _cQuery += "        AND SC5.C5_NUM >= '" + _cPedidoDe + "'"					                            + Chr(13)+Chr(10)
                                        _cQuery += "        AND SC5.C5_NUM <= '" + _cPedidoAte + "'"						                    + Chr(13)+Chr(10)
                                        _cQuery += "        AND SC5.C5_EMISSAO BETWEEN '" + dToS(_dEmissaoDe) + "' AND '" + dToS(_dEmissaoAte) + "'"                + Chr(13)+Chr(10)
                                        _cQuery += "        AND SC5.C5_NOTA = ' '"                                                                                  + Chr(13)+Chr(10)
                                        _cQuery += "        AND SC5.C5_BLQ = ' '"                                                                                   + Chr(13)+Chr(10)
                                        if .not. Empty( _cManiDe ) .or. .not. Empty( _cManiAte )
                                                _cQuery += "        AND SC5.C5_X_MAN BETWEEN '" + _cManiDe + "' AND '" + _cManiAte + "'"                         + Chr(13)+Chr(10)
                                        EndIf
                                        _cQuery += "  ORDER BY SC5.C5_FILIAL, SC5.C5_NUM "                                                                       + Chr(13)+Chr(10)

                                        _cQuery := ChangeQuery( _cQuery )

                                        TCQUERY _cQuery Alias (_cArqQRY) New

                                        (_cArqQRY)->( dbGoTop() )
                                        If ! (_cArqQRY)->( Eof() )

                                                _aPedidos := { }
                                                while (_cArqQRY)->( ! Eof() )

                                                        AAdd( _aPedidos,{ ;
                                                                                _oOk,                           ;   // MARK STEP 2
                                                                                _oNo,                           ;   // MARK STEP 3
                                                                                (_cArqQRY)->PEDIDO,             ;   // PEDIDO
                                                                                (_cArqQRY)->PRODUTO,            ;   // PRODUTO
                                                                                (_cArqQRY)->DESCRICAO,          ;   // DESCRICAO
                                                                                (_cArqQRY)->PESO_MINIMO_TRANSP, ;   // PESO MINIMO PRODUTO TRANSPORTADORA
                                                                                (_cArqQRY)->PESO_PRODUTO,       ;   // PESO PRODUTO                                                                        
                                                                                (_cArqQRY)->QTD_CAIXA,          ;   // CAIXA PRODUTO
                                                                                (_cArqQRY)->UNSVEN,             ;   // iif( (_cArqQRY)->ENTREGUE < (_cArqQRY)->VENDIDO, ( (_cArqQRY)->VENDIDO - (_cArqQRY)->ENTREGUE ), (_cArqQRY)->VENDIDO ), ;   // SALDO PEDIDO
                                                                                (_cArqQRY)->UNSVEN,             ;   // Val( Transform( iif( (_cArqQRY)->ENTREGUE < (_cArqQRY)->VENDIDO, ( (_cArqQRY)->VENDIDO - (_cArqQRY)->ENTREGUE ), (_cArqQRY)->VENDIDO ), PesqPict("SB1","B1_CONV") ) ) , ;
                                                                                (_cArqQRY)->MANIFESTO,          ;   // MANIFESTO
                                                                                _cCboMotivoCorte,               ;   // MOTIVO CORTE
                                                                                _nPercCorte,                    ;   // PERCENTUAL CORTE
                                                                                (_cArqQRY)->CODIGO,             ;   // CODIGO CLIENTE
                                                                                (_cArqQRY)->LOJA,               ;   // LOJA CLIENTE
                                                                                (_cArqQRY)->CLIENTE,            ;   // NOME DO CLIENTE CLIENTE
                                                                                (_cArqQRY)->BAIRRO,             ;   // BAIRRO
                                                                                (_cArqQRY)->CIDADE              ;   // CIDADE
                                                                        } )

                                                        (_cArqQRY)->( dbSkip() )

                                                enddo

                                        EndIf

                                        (_cArqQRY)->( dbCloseArea() )

                                EndIf

                        enddo


                        // SELECAO DE PRODUTOS - STEP 2
                        while _nfase == 2

                                If Valtype( _aPedidos ) == 'A' .and. Len( _aPedidos ) > 0

                                        _aStep2 := { }
                                        for _nPos := 1 to Len( _aPedidos )

                                                if ( _nPointer := AScan( _aStep2, { |x| x[ pST2_PRODUTO ] == _aPedidos[ _nPos ][ pPED_COD_PROD ] } ) ) == 0

                                                        AAdd( _aStep2,  {       ;
                                                                                _aPedidos[ _nPos ][ pPED_MRK_STEP_2 ],                          ;   // CORTE
                                                                                _aPedidos[ _nPos ][ pPED_COD_PROD ],                            ;   // PRODUTO
                                                                                _aPedidos[ _nPos ][ pPED_DESC_PROD ],                           ;   // DESCRICAO
                                                                                _aPedidos[ _nPos ][ pPED_SALDO_PEDIDO ],                        ;   // SALDO TOTAL PEDIDO
                                                                                _aPedidos[ _nPos ][ pPED_SALDO_CORTE ],                         ;   // SALDO TOTAL CORTE
                                                                                _aPedidos[ _nPos ][ pPED_MOTIVO_CORTE ],                        ;   // MOTIVO CORTE
                                                                                _aPedidos[ _nPos ][ pPED_MANIFESTO ],                           ;   // MANIFESTO
                                                                                _aPedidos[ _nPos ][ pPED_PERCENTUAL_CORTE ],                    ;   // PERCENTUAL CORTE
                                                                                {  }                                                            ;   // ITENS
                                                                        }       ;
                                                        )

                                                        AAdd( ATail( _aStep2 )[  pST2_ITEMS ],  {       ;
                                                                                                        _aPedidos[ _nPos ][ pPED_PEDIDO ],      ;   // PEDIDO
                                                                                                        _aPedidos[ _nPos ][ pPED_SALDO_PEDIDO ],;   // SALDO TOTAL PEDIDO
                                                                                                        _aPedidos[ _nPos ][ pPED_SALDO_CORTE ]  ;   // SALDO TOTAL CORTE
                                                                                                } )

                                                Else

                                                        _aStep2[ _nPointer ][ pST2_SALDO_PEDIDO ] += _aPedidos[ _nPos ][ pPED_SALDO_PEDIDO ]   // SALDO TOTAL PEDIDO
                                                        _aStep2[ _nPointer ][ pST2_SALDO_CORTE ]  += _aPedidos[ _nPos ][ pPED_SALDO_CORTE ]    // SALDO TOTAL CORTE

                                                        AAdd( _aStep2[ _nPointer ][ pST2_ITEMS ],       {       ;
                                                                                                                _aPedidos[ _nPos ][ pPED_PEDIDO ],       ;   // PEDIDO
                                                                                                                _aPedidos[ _nPos ][ pPED_SALDO_PEDIDO ], ;   // SALDO TOTAL PEDIDO
                                                                                                                _aPedidos[ _nPos ][ pPED_SALDO_CORTE ]   ;   // SALDO TOTAL CORTE
                                                                                                        }       ;
                                                        )

                                                EndIf

                                        next


                                        If Len( _aStep2 ) > 0

                                                // Calcula o percentual do Corte
                                                _aStep2 := CalcPercCorte( _aStep2, _nPercCorte )

                                                // Calcula o percentual do Corte
                                                AEval( _aStep2, { |xItem| xItem[ pST2_CORTE ]        := iif( xItem[ pST2_SALDO_CORTE ] > 0, xItem[ pST2_CORTE ],        _oNo )} )
                                                AEval( _aStep2, { |xItem| xItem[ pST2_MOTIVO_CORTE ] := iif( xItem[ pST2_SALDO_CORTE ] > 0, xItem[ pST2_MOTIVO_CORTE ], '  ' )} )

                                                // Define a ordem de exibicao dos dados
                                                if Left( _cFormaProce, 1 ) == "1"
                                                        _aStep2 := aSort( _aStep2, , , {|x,y| x[ pST2_PRODUTO ] + Str( x[ pST2_SALDO_CORTE ] ) > y[ pST2_PRODUTO ] + Str( y[ pST2_SALDO_CORTE ] ) } )
                                                else
                                                        _aStep2 := aSort( _aStep2, , , {|x,y| x[ pST2_PRODUTO ] + Str( x[ pST2_SALDO_CORTE ] ) < y[ pST2_PRODUTO ] + Str( y[ pST2_SALDO_CORTE ] ) } )
                                                endif


                                                // Monta a Janela para Exibicao dos dados
                                                DEFINE MSDIALOG _oDlg2 FROM 0,0 TO _aSize[6], _aSize[5] TITLE OemToAnsi( 'SELECAO DE PRODUTOS - STEP 2' ) Of oMainWnd PIXEL

                                                if _aSize[6] < 700
                                                        _oPainel2 := TPanel():New(060,000,,_oDlg2, NIL, .T., .F., NIL, NIL,_aSize[6]+73,_aSize[4]-60, .T., .F. )
                                                else
                                                        _oPainel2 := TPanel():New(060,000,,_oDlg2, NIL, .T., .F., NIL, NIL,_aSize[6]+39,_aSize[4]-60, .T., .F. )
                                                endif

                                                _oBrowStep2 := TwBrowse():New(005, 005, _aSize[6], _aSize[5],, {        " ",                ;
                                                                                                                        "PRODUTO",          ;
                                                                                                                        "DESCRICAO" ,       ;
                                                                                                                        "SALDO EM PEDIDO",  ;
                                                                                                                        "QUANTIDADE CORTE", ;
                                                                                                                        "MOTIVO CORTE",     ;
                                                                                                                        "%"                 ;
                                                                                                                        },,_oPainel2,,,,,,,,,,,, .F.,, .T.,, .T.,,,)

                                                _oBrowStep2:bLDblClick := {||   (       iif( _aStep2[_oBrowStep2:nAt, pST2_CORTE ]:CNAME == "LBNO", ;
                                                                                                        iif(    Inf_Step2( @_aStep2[_oBrowStep2:nAt] ),;
                                                                                                                _aStep2[_oBrowStep2:nAt, pST2_CORTE ] := _oOk, ;
                                                                                                                _aStep2[_oBrowStep2:nAt, pST2_CORTE ] := _oNo ), ;
                                                                                                        ( _aStep2[_oBrowStep2:nAt, pST2_CORTE ] := _oNo, ;
                                                                                                        _aStep2[_oBrowStep2:nAt, pST2_SALDO_CORTE  ] := 0, ;
                                                                                                        _aStep2[_oBrowStep2:nAt, pST2_MOTIVO_CORTE ] := ' ', ;
                                                                                                        _aStep2[_oBrowStep2:nAt, pST2_CORTE ]:CNAME := "LBNO"  ) ;
                                                                                                ), _oBrowStep2:refresh() ;
                                                                                        ) ;
                                                                        }

                                                _oBrowStep2:SetArray( _aStep2 )

                                                _oBrowStep2:bLine := {  ||      { ;     
                                                                                        _aStep2[_oBrowStep2:nAt, pST2_CORTE        ],   ;
                                                                                        _aStep2[_oBrowStep2:nAt, pST2_PRODUTO      ],   ;
                                                                                        _aStep2[_oBrowStep2:nAt, pST2_DESCRICAO    ],   ;
                                                                                        _aStep2[_oBrowStep2:nAt, pST2_SALDO_PEDIDO ],   ;
                                                                                        Transform( _aStep2[_oBrowStep2:nAt, pST2_SALDO_CORTE  ], PesqPict("SB1","B1_CONV") ) ,;
                                                                                        _aStep2[_oBrowStep2:nAt, pST2_MOTIVO_CORTE ],   ;
                                                                                        Transform( _aStep2[_oBrowStep2:nAt, pST2_PERCENTUAL_CORTE ], "@E 999"+"%" )  ;
                                                                                }}


                                                _oBrowStep2:Align       := CONTROL_ALIGN_ALLCLIENT
                /*                                _oBrowStep2:bChange     := {||  iif( Left( _cFormaProce, 1 ) == "1", _oBrowStep2:aArray := aSort( _oBrowStep2:aArray, , , {|x,y| x[ pST2_SALDO_PEDIDO ] > y[ pST2_SALDO_PEDIDO ]}), ;
                                                                                                                _oBrowStep2:aArray := aSort( _oBrowStep2:aArray, , , {|x,y| x[ pST2_SALDO_PEDIDO ] < y[ pST2_SALDO_PEDIDO ]}) ), ;
                                                                                _oBrowStep2:refresh() } */
                                                _oBrowStep2:nScrollType := 1

                                                _oBrowStep2:setFocus()
                                                _oBrowStep2:refresh()

                                                // AAdd( _aButtons2, { '',{ || Nil }, "Teste 1"} )
                                                // AAdd( _aButtons2, { '',{ || Nil }, "Teste 2"} )

                                                ACTIVATE MSDIALOG _oDlg2 ON INIT EnchoiceBar( _oDlg2, { || _lAtuFase2 := .T. , _oDlg2:End() } , { || _lAtuFase2 := .F., _oDlg2:End() },, _aButtons2)

                                                if _lAtuFase2
                                                        for _nPos := 1 to Len( _aPedidos )

                                                                // Buscando o Produto
                                                                if ( _nPointer := AScan( _aStep2, { |x| x[ pST2_PRODUTO ] == _aPedidos[ _nPos ][ pPED_COD_PROD ] } ) ) > 0

                                                                        _aPedidos[ _nPos ][ pPED_MRK_STEP_2 ]   := _aStep2[ _nPointer ][ pST2_CORTE ]
                                                                        _aPedidos[ _nPos ][ pPED_MOTIVO_CORTE ] := _aStep2[ _nPointer ][ pST2_MOTIVO_CORTE ]

                                                                        // Buscando o Pedido
                                                                        if ( _nCount := AScan( _aStep2[ _nPointer ][ pST2_ITEMS ], { |x| x[ pST2_ITEM_PEDIDO ] == _aPedidos[ _nPos ][ pPED_PEDIDO ] } ) ) > 0

                                                                                _aPedidos[ _nPos ][ pPED_SALDO_CORTE ] := _aStep2[ _nPointer ][ pST2_ITEMS ][ _nCount ][ pST2_ITEM_SALDO_CORTE ]

                                                                        EndIf

                                                                EndIf

                                                        next
                                                        _nfase++
                                                Else
                                                        _nfase--
                                                EndIf

                                        Else
                                                _nfase--
                                        EndIf

                                Else
                                        _nfase--
                                EndIf

                        enddo


                        // SELECAO DE PRODUTOS - STEP 3
                        while _nfase == 3

                                If Len( _aPedidos ) > 0

                                        // Carrega os titulos seleciionados
                                        _aStep3           := { }
                                        _lValidPesoTransp := .F.
                                        for _nPos := 1 to len( _aPedidos )

                                                if _aPedidos[ _nPos ][ pPED_MRK_STEP_2 ]:CNAME == "LBOK" .and. _aPedidos[ _nPos ][ pPED_SALDO_CORTE ] > 0

                                                        //
                                                        // Incluida a validacao para desconsiderar produtos onde o peso esta abaixo do definido no cadastro.
                                                        //
                                                        If Left( _cVldPeso, 1 ) == '1'

                                                            _nPesoAtual := 0
                                                            AEval( _aPedidos, { |xItem| _nPesoAtual += iif( xItem[ pPED_MRK_STEP_2 ] :CNAME == "LBOK" .and. ;
                                                                                                            xItem[ pPED_CODIGO_CLIENTE ] ==_aPedidos[ _nPos ][ pPED_CODIGO_CLIENTE ] .and. ;
                                                                                                            xItem[ pPED_LOJA_CLIENTE ] == _aPedidos[ _nPos ][ pPED_LOJA_CLIENTE  ] ,;
                                                                                                            xItem[ pPED_SALDO_CORTE ], 0 ) } )

                                                            _nPesoAtual := _nPesoAtual * _aPedidos[ _nPos ][ pPED_PESO_PRODUTO ]
                                                            _nPesoAtual := _nPesoAtual * _aPedidos[ _nPos ][ pPED_CAIXA_PRODUTO ]

                                                            If  _nPesoAtual >= _aPedidos[ _nPos ][ pPED_PESO_MINIMO_PRODUTO_TRANSP ]

                                                                    AAdd( _aStep3,  {         ;
                                                                                            _oOk,                                                           ;   // CORTE
                                                                                            _aPedidos[ _nPos ][ pPED_COD_PROD ],                            ;   // PRODUTO
                                                                                            _aPedidos[ _nPos ][ pPED_DESC_PROD ],                           ;   // DESCRICAO
                                                                                            '(' + _aPedidos[ _nPos ][ pPED_CODIGO_CLIENTE ] + '-' +         ;
                                                                                            _aPedidos[ _nPos ][ pPED_LOJA_CLIENTE  ] + ')' +          ;
                                                                                            Alltrim( _aPedidos[ _nPos ][ pPED_NOME_CLIENTE ] ),       ;   // (COD+LOJA+CLIENTE)
                                                                                            _aPedidos[ _nPos ][ pPED_BAIRRO_CLIENTE ],                      ;   // BAIRRO
                                                                                            _aPedidos[ _nPos ][ pPED_CIDADE_CLIENTE ],                      ;   // CIDADE
                                                                                            _aPedidos[ _nPos ][ pPED_PEDIDO ],                              ;   // PEDIDO
                                                                                            _aPedidos[ _nPos ][ pPED_MANIFESTO ],                           ;   // MANITESTO
                                                                                            _aPedidos[ _nPos ][ pPED_SALDO_PEDIDO ],                        ;   // QTDE DISP
                                                                                            _aPedidos[ _nPos ][ pPED_SALDO_CORTE ],                         ;   // QTDE A CORTAR
                                                                                            _aPedidos[ _nPos ][ pPED_PESO_MINIMO_PRODUTO_TRANSP ],          ;   // PESO MINIMO PRODUTO TRANSPORTADORA
                                                                                            _aPedidos[ _nPos ][ pPED_PESO_PRODUTO ],                        ;   // PESO PRODUTO
                                                                                            _nPesoAtual,                                                    ;   // PESO ATUAL
                                                                                            _aPedidos[ _nPos ][ pPED_CAIXA_PRODUTO ]                        ;   // QUANTIDADE CAIXA
                                                                                    } )
                                                            Else
                                                                    _lValidPesoTransp := .T.
                                                            EndIf

                                                        Else

                                                            _nPesoAtual := _aPedidos[ _nPos ][ pPED_SALDO_CORTE ]
                                                            _nPesoAtual := _nPesoAtual * _aPedidos[ _nPos ][ pPED_PESO_PRODUTO ]
                                                            _nPesoAtual := _nPesoAtual * _aPedidos[ _nPos ][ pPED_CAIXA_PRODUTO ]

                                                            AAdd( _aStep3,  {         ;
                                                                                    _oOk,                                                           ;   // CORTE
                                                                                    _aPedidos[ _nPos ][ pPED_COD_PROD ],                            ;   // PRODUTO
                                                                                    _aPedidos[ _nPos ][ pPED_DESC_PROD ],                           ;   // DESCRICAO
                                                                                    '(' + _aPedidos[ _nPos ][ pPED_CODIGO_CLIENTE ] + '-' +         ;
                                                                                          _aPedidos[ _nPos ][ pPED_LOJA_CLIENTE  ] + ')' +          ;
                                                                                          Alltrim( _aPedidos[ _nPos ][ pPED_NOME_CLIENTE ] ),       ;   // (COD+LOJA+CLIENTE)
                                                                                    _aPedidos[ _nPos ][ pPED_BAIRRO_CLIENTE ],                      ;   // BAIRRO
                                                                                    _aPedidos[ _nPos ][ pPED_CIDADE_CLIENTE ],                      ;   // CIDADE
                                                                                    _aPedidos[ _nPos ][ pPED_PEDIDO ],                              ;   // PEDIDO
                                                                                    _aPedidos[ _nPos ][ pPED_MANIFESTO ],                           ;   // MANITESTO
                                                                                    _aPedidos[ _nPos ][ pPED_SALDO_PEDIDO ],                        ;   // QTDE DISP
                                                                                    _aPedidos[ _nPos ][ pPED_SALDO_CORTE ],                         ;   // QTDE A CORTAR
                                                                                    _aPedidos[ _nPos ][ pPED_PESO_MINIMO_PRODUTO_TRANSP ],          ;   // PESO MINIMO PRODUTO TRANSPORTADORA
                                                                                    _aPedidos[ _nPos ][ pPED_PESO_PRODUTO ],                        ;   // PESO PRODUTO
                                                                                    _nPesoAtual,                                                    ;   // PESO ATUAL
                                                                                    _aPedidos[ _nPos ][ pPED_CAIXA_PRODUTO ]                        ;   // QUANTIDADE CAIXA
                                                                            } )
                                                        EndIf

                                                endif

                                        next


                                        //
                                        // Exibe a mensagem ao usuario onformando que existem produtos que nao atigiram o peso minimo para corte.
                                        //
                                        If _lValidPesoTransp
                                                msgAlert("Exitem produtos que nao atingiram o peso minimo para corte!","Atencao")
                                        EndIf

                                        //
                                        // Processa somente se existirem produtos disponiveis para corte.
                                        //
                                        if len( _aStep3 ) > 0

                                                //
                                                // Define a ordem de exibicao dos produtos na grade.
                                                //
                                                if Left( _cFormaProce, 1 ) == "1"
                                                        _aStep3 := aSort( _aStep3, , , {|x,y| x[ pST3_QTDE_DISP ] > y[ pST3_QTDE_DISP ]})
                                                else
                                                        _aStep3 := aSort( _aStep3, , , {|x,y| x[ pST3_QTDE_DISP ] < y[ pST3_QTDE_DISP ]})
                                                endif

                                                DEFINE MSDIALOG _oDlg3 FROM 0,0 TO _aSize[6], _aSize[5] TITLE OemToAnsi( 'SELECAO DE PRODUTOS - STEP 3' ) Of oMainWnd PIXEL

                                                if _aSize[6] < 700
                                                        _oPainel3 := TPanel():New(060,000,,_oDlg3, NIL, .T., .F., NIL, NIL,_aSize[6]+73,_aSize[4]-60, .T., .F. )
                                                else
                                                        _oPainel3 := TPanel():New(060,000,,_oDlg3, NIL, .T., .F., NIL, NIL,_aSize[6]+39,_aSize[4]-60, .T., .F. )
                                                endif

                                                _oBrowStep3 := TwBrowse():New(005, 005, _aSize[6], _aSize[5],, {  " ",           ;
                                                                                                                "PRODUTO",       ;
                                                                                                                "DESCRICAO" ,    ;
                                                                                                                "CLIENTE",       ;
                                                                                                                "BAIRRO",        ;
                                                                                                                "CIDADE",        ;
                                                                                                                "PEDIDO",        ;
                                                                                                                "MANITESTO",     ;
                                                                                                                "QTDE DISP",     ;
                                                                                                                "QTDE A CORTAR", ;
                                                                                                                "PESO MIN",      ;
                                                                                                                "PESO ATUAL"     ;
                                                                                                                },,_oPainel3,,,,,,,,,,,, .F.,, .T.,, .T.,,,)

                /*                                _oBrowStep3:bLDblClick := {||   ( iif(  _aStep3[_oBrowStep3:nAt, pST3_CORTE ]:CNAME == "LBNO", ;
                                                                                        _aStep3[_oBrowStep3:nAt, pST3_CORTE ] := _oOk, ;
                                                                                        _aStep3[_oBrowStep3:nAt, pST3_CORTE ] := _oNo ), ;
                                                                                _oBrowStep3:refresh() ) ;
                                                                        } */

                                                _oBrowStep3:bLDblClick := {||   (       iif( _aStep3[_oBrowStep3:nAt, pST3_CORTE]:CNAME == "LBNO", ;
                                                                                                        iif(    Inf_Step3( @_aStep3[_oBrowStep2:nAt] ),;
                                                                                                                _aStep3[_oBrowStep3:nAt, pST3_CORTE ] := _oOk, ;
                                                                                                                _aStep3[_oBrowStep3:nAt, pST3_CORTE ] := _oNo ), ;
                                                                                                        _aStep3[_oBrowStep3:nAt, pST3_CORTE ] := _oNo ) ;
                                                                                ),      Calc_Step3( @_aStep3 ), _oBrowStep3:refresh() ;
                                                                        }

                                                _oBrowStep3:SetArray( _aStep3 )

                                                _oBrowStep3:bLine :=    {||     ;
                                                                                {       ;     
                                                                                        _aStep3[_oBrowStep3:nAt, pST3_CORTE                      ], ;
                                                                                        _aStep3[_oBrowStep3:nAt, pST3_PRODUTO                    ], ;
                                                                                        _aStep3[_oBrowStep3:nAt, pST3_DESC_PROD                  ], ;
                                                                                        _aStep3[_oBrowStep3:nAt, pST3_NOME_CLIENTE               ], ;
                                                                                        _aStep3[_oBrowStep3:nAt, pST3_BAIRRO                     ], ;
                                                                                        _aStep3[_oBrowStep3:nAt, pST3_CIDADE                     ], ;
                                                                                        _aStep3[_oBrowStep3:nAt, pST3_PEDIDO                     ], ;
                                                                                        _aStep3[_oBrowStep3:nAt, pST3_MANIFESTO                  ], ;
                                                                                        _aStep3[_oBrowStep3:nAt, pST3_QTDE_DISP                  ], ;
                                                                                        _aStep3[_oBrowStep3:nAt, pST3_QTDE_CORTE                 ], ;
                                                                                        _aStep3[_oBrowStep3:nAt, pST3_PESO_MINIMO_PRODUTO_TRANSP ], ;
                                                                                        Transform( _aStep3[_oBrowStep3:nAt, pST3_PESO_ATUAL  ], PesqPict("SB1","B1_PESO") ) ;
                                                                                }       ;
                                                                        }


                /*                                _oBrowStep3:bChange     := {|| iif( Left( _cFormaProce, 1 ) == "1", aSort( _oBrowStep3:aArray, , , {|x,y| x[ pST3_QTDE_DISP ] > y[ pST3_QTDE_DISP ]}), ;
                                                                                                                aSort( _oBrowStep3:aArray, , , {|x,y| x[ pST3_QTDE_DISP ] < y[ pST3_QTDE_DISP ]}) ) } */
                                                _oBrowStep3:Align := CONTROL_ALIGN_ALLCLIENT
                                                _oBrowStep3:nScrollType := 1

                                                _oBrowStep3:setFocus()
                                                _oBrowStep3:refresh()                                

                                                ACTIVATE MSDIALOG _oDlg3 ON INIT EnchoiceBar( _oDlg3, { || _lAtuFase3 := .T., _oDlg3:End() } , { || _lAtuFase2 := .F., _oDlg3:End() },, _aButtons3)

                                                if _lAtuFase3
                                                        for _nPos := 1 to Len( _aPedidos )

                                                                // Buscando o Produto
                                                                if ( _nPointer := AScan( _aStep3, { |x| x[ pST3_PRODUTO ] == _aPedidos[ _nPos ][ pPED_COD_PROD ] .and. ;
                                                                                                        x[ pST3_PEDIDO ] == _aPedidos[ _nPos ][ pPED_PEDIDO ]  } ) ) > 0

                                                                        _aPedidos[ _nPos ][ pPED_MRK_STEP_3 ]  := _aStep3[ _nPointer ][ pST3_CORTE ]
                                                                        _aPedidos[ _nPos ][ pPED_SALDO_CORTE ] := _aStep3[ _nPointer ][ pST3_QTDE_CORTE ]

                                                                EndIf

                                                        next
                                                        _nfase++
                                                Else
                                                        _nfase--
                                                EndIf

                                        
                                        else
                                                msgAlert("Nao existe registros selecionados!","Atencao")
                                                _nfase--
                                        endif

                                Else
                                        _nfase--
                                EndIf

                        enddo


                        // Gera o pedido de venda com os registros selecionados
                        while _nfase == 4

                                if msgYesNo("O Processo e Irreversivel e ira ajustar os pedidos conforme o parametro.","DESEJA CONFIRMAR CORTE")

                                        // Tratamento para evitar erro no momento do processamento dos itens
                                        if len( _aPedidos ) > 0

                                                // Com os pedidos selecionados, monta a estrutura para alteracao no ppedido e excluir caso a
                                                // Quantidade de corte seja igual a 0
                                                for _nPos := 1 to len( _aPedidos )

                                                        If _aPedidos[ _nPos ][ pPED_MRK_STEP_3 ]:CNAME == "LBOK"

                                                                begin transaction

                                                                        If SC5->( dbSetOrder(1), dbSeek( xFilial("SC5") + _aPedidos[ _nPos ][ pPED_PEDIDO ] ) )

                                                                                _aCabec   := {}
                                                                                _aItens   := {}

                                                                                AAdd( _aCabec, { "C5_NUM",     SC5->C5_NUM,     Nil})
                                                                                AAdd( _aCabec, { "C5_TIPO",    SC5->C5_TIPO,    Nil})
                                                                                AAdd( _aCabec, { "C5_CLIENTE", SC5->C5_CLIENTE, Nil})
                                                                                AAdd( _aCabec, { "C5_LOJACLI", SC5->C5_LOJACLI, Nil})
                                                                                AAdd( _aCabec, { "C5_LOJAENT", SC5->C5_LOJAENT, Nil})
                                                                                AAdd( _aCabec, { "C5_CONDPAG", SC5->C5_CONDPAG, Nil})

                                                                                if SC6->( dbSetOrder(1), dbSeek( xFilial("SC6") + SC5->C5_NUM ) )

                                                                                        // Variavel para controlar se o pedido deve ser excluido complemtamente
                                                                                        _nTotItens := 0
                                                                                        while SC6->C6_FILIAL == SC5->C5_FILIAL .and. ;
                                                                                                SC6->C6_NUM == SC5->C5_NUM .and. ;
                                                                                                ! SC6->( Eof() )

                                                                                                // Variavel para controle para definir se o item deve ou nao ser includo no array
                                                                                                _lDeletItem := .F.
                                                                                                if _aPedidos[ _nPos ][ pPED_COD_PROD ] == SC6->C6_PRODUTO
                                                                                                        if ( _aPedidos[ _nPos ][ pPED_SALDO_PEDIDO ] - _aPedidos[ _nPos ][ pPED_SALDO_CORTE ] ) <= 0
                                                                                                                _lDeletItem := .T.

                                                                                                                // Atualiza as informacoes antes da delecao
                                                                                                                _nQtdQTDCT  := SC6->C6_X_QTDCT + _aPedidos[ _nPos ][ pPED_SALDO_CORTE ]
                                                                                                                _cMtvCorte  := Left( _aPedidos[ _nPos ][ pPED_MOTIVO_CORTE ], 2 )
                                                                                                                _dDtaCorte  := dDataBase
                                                                                                                _cPercCorte := AllTrim( Str( _aPedidos[ _nPos ][ pPED_PERCENTUAL_CORTE ] ) )

                                                                                                                RecLock("SC6",.F.)
                                                                                                                        SC6->C6_X_MTVCT := _cMtvCorte
                                                                                                                        SC6->C6_X_DATCT := _dDtaCorte
                                                                                                                        SC6->C6_X_QTDCT := _nQtdQTDCT
                                                                                                                        SC6->C6_X_PERCE := _cPercCorte
                                                                                                                SC6->(msUnLock())                                                                                                        

                                                                                                                // Elimina o registro da tabela
                                                                                                                RecLock("SC6",.F.)
                                                                                                                        SC6->(dbDelete())
                                                                                                                SC6->(msUnLock())
                                                                                                        EndIf
                                                                                                endif

                                                                                                if ! _lDeletItem

                                                                                                        _nTotItens++

                                                                                                        _aLinha := {}
                                                                                                        AAdd( _aLinha, { "LINPOS",     "C6_ITEM",       SC6->C6_ITEM } )
                                                                                                        AAdd( _aLinha, { "AUTDELETA",  "N",             Nil})
                                                                                                        AAdd( _aLinha, { "C6_PRODUTO", SC6->C6_PRODUTO, Nil})

                                                                                                        if  _aPedidos[ _nPos ][ pPED_COD_PROD ] == SC6->C6_PRODUTO   

                                                                                                                _nQtdVen    := ( _aPedidos[ _nPos ][ pPED_SALDO_PEDIDO ] - _aPedidos[ _nPos ][ pPED_SALDO_CORTE ] ) * _aPedidos[ _nPos ][ pPED_CAIXA_PRODUTO ]
                                                                                                                _nPrcTotal  := SC6->C6_PRUNIT * _nQtdVen
                                                                                                                _nQtdUnsVen := SC6->C6_UNSVEN - _aPedidos[ _nPos ][ pPED_SALDO_CORTE ]
                                                                                                                _nQtdQTDCT  := SC6->C6_X_QTDCT + _aPedidos[ _nPos ][ pPED_SALDO_CORTE ]
                                                                                                                _cMtvCorte  := Left( _aPedidos[ _nPos ][ pPED_MOTIVO_CORTE ], 2 )
                                                                                                                _dDtaCorte  := dDataBase
                                                                                                                _cPercCorte := AllTrim( Str( _aPedidos[ _nPos ][ pPED_PERCENTUAL_CORTE ] ) )
                                                                                                                

                                                                                                                AAdd( _aLinha, { "C6_QTDVEN",  _nQtdVen,         Nil})
                                                                                                                AAdd( _aLinha, { "C6_PRCVEN",  SC6->C6_PRCVEN,   Nil})
                                                                                                                AAdd( _aLinha, { "C6_PRUNIT",  SC6->C6_PRUNIT,   Nil})
                                                                                                                AAdd( _aLinha, { "C6_VALOR",   _nPrcTotal,       Nil})
                                                                                                                AAdd( _aLinha, { "C6_UNSVEN",  _nQtdUnsVen,      Nil})

                                                                                                                AAdd( _aLinha, { "C6_X_MTVCT", _cMtvCorte,       Nil})
                                                                                                                AAdd( _aLinha, { "C6_X_DATCT", _dDtaCorte,       Nil})
                                                                                                                AAdd( _aLinha, { "C6_X_QTDCT", _nQtdQTDCT,       Nil})
                                                                                                                AAdd( _aLinha, { "C6_X_PERCE", _cPercCorte,      Nil})

                                                                                                        Else
                                                                                                                AAdd( _aLinha, { "C6_QTDVEN",  SC6->C6_QTDVEN,   Nil})
                                                                                                                AAdd( _aLinha, { "C6_PRCVEN",  SC6->C6_PRCVEN,   Nil})
                                                                                                                AAdd( _aLinha, { "C6_PRUNIT",  SC6->C6_PRUNIT,   Nil})
                                                                                                                AAdd( _aLinha, { "C6_VALOR",   SC6->C6_VALOR,    Nil})
                                                                                                                AAdd( _aLinha, { "C6_UNSVEN",  SC6->C6_UNSVEN,   Nil})

                                                                                                                AAdd( _aLinha, { "C6_X_MTVCT", SC6->C6_X_MTVCT,  Nil})
                                                                                                                AAdd( _aLinha, { "C6_X_DATCT", SC6->C6_X_DATCT,  Nil})
                                                                                                                AAdd( _aLinha, { "C6_X_QTDCT", SC6->C6_X_QTDCT,  Nil})
                                                                                                                AAdd( _aLinha, { "C6_X_PERCE", SC6->C6_X_PERCE,  Nil})

                                                                                                        EndIf
                                                                                                        AAdd( _aLinha, { "C6_TES", SC6->C6_TES, Nil})
                                                                                                        AAdd( _aItens, _aLinha )

                                                                                                EndIf

                                                                                                SC6->( dbSkip() )

                                                                                        enddo

                                                                                endif

                                                                        EndIf

                                                                        // Caso nao seja atendido em 100%, somente altera, do contrario exclui o pedido
                                                                        If _nTotItens > 0
                                                                                _nOpcX := 4 // Alteracao
                                                                        Else
                                                                                _nOpcX := 5 // Exclusao
                                                                        EndIf

                                                                        LjMsgRun("Aguarde...   Alterando o Pedido de Venda...",,{|| MSExecAuto({| a, b, c, d| MATA410(a, b, c, d)}, _aCabec, _aItens, _nOpcX, .F.) } )

                                                                        If !lMsErroAuto

                                                                                If SC5->( dbSetOrder(1), dbSeek( xFilial("SC5") + _aPedidos[ _nPos ][ pPED_PEDIDO ] ) )
                                                                                        RecLock("SC5",.F.)
                                                                                                SC5->C5_X_OBSD := '[' + DToS( dDataBase) + ']-[' + Time() + ']-[' + "Alteracao realizada com sucesso."
                                                                                        SC5->(msUnLock())
                                                                                Endif

                                                                                ConOut("Alteracao realizada com sucesso!")                                                                        

                                                                        Else
                                                                        
                                                                                disarmTransaction()

                                                                                If SC5->( dbSetOrder(1), dbSeek( xFilial("SC5") + _aPedidos[ _nPos ][ pPED_PEDIDO ] ) )
                                                                                        RecLock("SC5",.F.)
                                                                                                SC5->C5_X_OBSD := '[' + DToS( dDataBase) + ']-[' + Time() + ']-[' + "Erro na ateracao do pedido."
                                                                                        SC5->(msUnLock())
                                                                                Endif

                                                                                ConOut("Erro na Alteracao!")

                                                                                _aErroAuto := GetAutoGRLog()
                                                                                For _nCount := 1 To Len(_aErroAuto)
                                                                                        _cLogErro += StrTran(StrTran(_aErroAuto[_nCount], "<", ""), "-", "") + " "
                                                                                        ConOut(_cLogErro)
                                                                                Next
                                                                                
                                                                        EndIf

                                                                end transaction

                                                        EndIf

                                                next

                                        endif

                                        //// Finaliza Rotina
                                        _nFase := 0
                                        _lContinua := .F.

                                Else
                                        // Caso o usuario tenha selecionado nao, volta a etapa anterior.
                                        _nFase--
                                EndIf

                        enddo

                enddo

                // Controle de Semaforo
                UnLockByName("GERACO01", .F., .F.)

        Else
                msgAlert("Rotina sendo executado por outro usuario !","Atencao")
        EndIf

RETURN


/*=====================================================================================
Programa............: INF_STEP2( _cDescriProd, _nQuantPedido, _nQuantCorte, _cMotivoCorte )
Autor...............: Edilson Nascimento
Data................: 13/07/2021
Descricao / Objetivo: RotinaRotina para que seja alimentada a quantidade e o motivo do corte.
Doc. Origem.........:
Solicitante.........: 
Uso.................: 
=======================================================================================*/
//STATIC FUNCTION Inf_Step2( _aArray, _cDescriProd, _nQuantPedido, _nQuantCorte, _cMotivoCorte )
STATIC FUNCTION Inf_Step2( _aArray )


local _oDlg1
local _oCboMotivoCorte
local _aTblMotvCort      := { }
local _lRetValue         := .F.

local _cDescriProd       := _aArray[ pST2_DESCRICAO ]
local _nQuantPedido      := _aArray[ pST2_SALDO_PEDIDO ]
local _nQuantCorte       := _aArray[ pST2_SALDO_CORTE ]
local _cMotivoCorte      := _aArray[ pST2_MOTIVO_CORTE ]

local _nPos
local _nPerc
local _nResult
local _nSoma

 // _aStep2[_oBrowStep2:nAt, pST2_DESCRICAO ], _aStep2[_oBrowStep2:nAt, pST2_SALDO_PEDIDO ], @_aStep2[_oBrowStep2:nAt, pST2_SALDO_CORTE ], @_aStep2[_oBrowStep2:nAt, pST2_MOTIVO_CORTE ] ),;

	If SX5->( dbSetOrder(1), dbSeek( xFilial("SX5") + "Z4" ) )
		while SX5->X5_TABELA == 'Z4' .and. ;
                        SX5->( .not. Eof() )
                        AAdd( _aTblMotvCort, Alltrim( SX5->X5_CHAVE ) + "-" + Alltrim( SX5->X5_DESCRI ) )
                        SX5->( dbSkip() )
			enddo
	Else
                AAdd( _aTblMotvCort, " " )
	EndIf

        @ 00,00 TO 210,470 DIALOG _oDlg1 TITLE OemToAnsi( "Dados para o Corte" )

        @ 20,018        SAY     "Produto:"
        @ 20,085        GET     _cDescriProd                    ;
                        PICTURE PesqPict("SB1","B1_DESC")       ;
                        WHEN   .F.

        @ 35,018        SAY     "Quantidade de Corte:"
        @ 35,085        GET     _nQuantCorte                    ;
                        PICTURE PesqPict("SB1","B1_CONV")       ;
                        VALID   iif( _nQuantCorte > _nQuantPedido, ( msgAlert("Valor do corte nao pode ser maior que a quantidade disponivel !","Atencao"), .F. ), .T. )

        @ 50,018        SAY     "Motivo Corte:"
        @ 50,085        COMBOBOX _oCboMotivoCorte;
                        VAR     _cMotivoCorte                   ;
                        ITEMS   _aTblMotvCort                   ;
                        SIZE    90,20                           ;
                        PIXEL                                   ;
                        OF      _oDlg1

        @ 090,110 BMPBUTTON TYPE 01 ACTION ( _lRetValue := .T., Close(_oDlg1) )
        @ 090,140 BMPBUTTON TYPE 02 ACTION ( _lRetValue := .F., Close(_oDlg1) )

        ACTIVATE  DIALOG _oDlg1 CENTER

        // Case tenha sido pressionado o botao de cancelamento da janela.
	If _lRetValue

                _nPerc := ( _nQuantCorte / _nQuantPedido ) * 100

                _nSoma := 0
		for _nPos := 1 to len( _aArray[ pST2_ITEMS ] )
                        _nResult := _aArray[ pST2_ITEMS ][ _nPos ][ pST2_ITEM_SALDO_PEDIDO ] * _nPerc
                        _nResult /= 100
                        _nResult := Int( _nResult )
                        _aArray[ pST2_ITEMS ][ _nPos ][ pST2_ITEM_SALDO_CORTE ] := _nResult
                        _nSoma += _nResult
		next

                _aArray[ pST2_DESCRICAO ]        := _cDescriProd
                _aArray[ pST2_SALDO_PEDIDO ]     := _nQuantPedido
                _aArray[ pST2_SALDO_CORTE ]      := _nQuantCorte
                _aArray[ pST2_MOTIVO_CORTE ]     := _cMotivoCorte
                _aArray[ pST2_PERCENTUAL_CORTE ] := _nPerc
                _aArray[ pST2_SALDO_CORTE ]      := _nSoma

	EndIf

return _lRetValue


/*=====================================================================================
Programa............: INF_STEP3( _aArray )
Autor...............: Edilson Nascimento
Data................: 13/07/2021
Descricao / Objetivo: Rotina para que sejam alteradas os valores de quantidade disponivel e quantidade de corte.
Doc. Origem.........: 
Solicitante.........: 
Uso.................: 
=======================================================================================*/
STATIC Function Inf_Step3( _aArray )

local _oDlg1
local _lRetValue  := .F.
local _nPesoAtual

local _nQtdDisp   := _aArray[ pST3_QTDE_DISP ]
local _nQtdCorte  := _aArray[ pST3_QTDE_CORTE ]


        @ 00,00 TO 210,340 DIALOG _oDlg1 TITLE OemToAnsi( "Dados para o Corte" )

        @ 20,018        SAY     "Quantidade Disponivel:"
        @ 20,085        GET     _nQtdDisp                       ;
                        PICTURE PesqPict("SB1","B1_CONV")       ;
                        WHEN   .F.

        @ 35,018        SAY     "Quantidade de Corte:"
        @ 35,085        GET     _nQtdCorte                      ;
                        PICTURE  "@E 9999"                      ; // PesqPict("SB1","B1_CONV")       ;
                        VALID   iif(_nQtdCorte > _nQtdDisp, ( msgAlert("Valor do corte nao pode ser maior que a quantidade disponivel !","Atencao"), .F. ), .T. )

        @ 090,090 BMPBUTTON TYPE 01 ACTION ( _lRetValue := .T., Close(_oDlg1) )
        @ 090,120 BMPBUTTON TYPE 02 ACTION ( _lRetValue := .F., Close(_oDlg1) )

        ACTIVATE  DIALOG _oDlg1 CENTER

        // Case tenha sido pressionado o botao de cancelamento da janela.
        If _lRetValue
//                _aArray[ pST3_QTDE_DISP ]  := _nQtdDisp
//                _aArray[ pST3_QTDE_CORTE ] := _nQtdCorte

                _nPesoAtual := _nQtdDisp -  _nQtdCorte
                _nPesoAtual := _nPesoAtual * _aArray[ pST3_PESO_PRODUTO ]
                _nPesoAtual := _nPesoAtual * _aArray[ pST3_QTD_CAIXA  ]

                _aArray[ pST3_QTDE_DISP  ] := _nQtdDisp
                _aArray[ pST3_QTDE_CORTE ] := _nQtdCorte
                _aArray[ pST3_PESO_ATUAL ] := _nPesoAtual

        EndIf

return _lRetValue


/*=====================================================================================
Programa............: Calc_STEP3( _aArray )
Autor...............: Edilson Nascimento
Data................: 22/07/2021
Descricao / Objetivo: Rotiina para atualizacao da coluna com o peso atual.
Doc. Origem.........: 
Solicitante.........: 
Uso.................: 
=======================================================================================*/
STATIC Procedure Calc_Step3( _aArray )

local _nPos
local _nCount
local _nPeso
local _nSomaPeso
local _aTemp


    if len( _aArray ) > 0

        _aTemp := Aclone( _aArray )

        for _nPos := 1 to len( _aArray )

            _nSomaPeso := 0

            for _nCount := 1 to len( _aTemp )


                if _aTemp[ _nCount ][ pST3_CORTE ]:CNAME == "LBOK" .and. ;
                      Alltrim( _aTemp[ _nCount ][ pST3_NOME_CLIENTE ] ) == Alltrim( _aArray[ _nPos ][ pST3_NOME_CLIENTE ] ) .and. ;
                      Alltrim( _aTemp[ _nCount ][ pST3_NOME_CLIENTE ] ) == Alltrim( _aArray[ _nPos ][ pST3_NOME_CLIENTE ] ) .and. ;                      

                    _nPeso := _aTemp[ _nCount ][ pST3_QTDE_CORTE ]
                    _nPeso := _nPeso * _aTemp[ _nCount ][ pST3_PESO_PRODUTO ]
                    _nPeso := _nPeso * _aTemp[ _nCount ][ pST3_QTD_CAIXA ]

                    _nSomaPeso += _nPeso

                endif

            next

            _aArray[ _nPos ][ pST3_PESO_ATUAL ] := _nSomaPeso

        next

    endif

return



/*=====================================================================================
Programa............: CalcPercCorte( _aArray, nPerc )
Autor...............: Edilson Nascimento
Data................: 11/08/2021
Descricao / Objetivo: Realiza o calculo do percentual para corte.
Doc. Origem.........: 
Solicitante.........: 
Uso.................: 
=======================================================================================*/
STATIC FUNCTION CalcPercCorte( _aArray, _nPerc )

local _nPos
local _nCount
local _nResult
local _nSoma     := 0
local _aRetValue := aClone( _aArray )


        for _nPos := 1 to len( _aRetValue )

                If _aRetValue[ _nPos ][ pST2_CORTE ]:CNAME == "LBOK"

                        _nSoma := 0
                        for _nCount := 1 to len( _aRetValue[ _nPos ][ pST2_ITEMS ] )
                                _nResult := _aRetValue[ _nPos ][ pST2_ITEMS ][ _nCount ][ pST2_ITEM_SALDO_PEDIDO ] * _nPerc
                                _nResult /= 100
                                _nResult := Int( _nResult )
                                _aRetValue[ _nPos ][ pST2_ITEMS][ _nCount ][ pST2_ITEM_SALDO_CORTE ] := _nResult
                                _nSoma += _nResult
                        next

                        _aRetValue[ _nPos ][ pST2_SALDO_CORTE ] := _nSoma

                EndIf

        next

return( _aRetValue )
