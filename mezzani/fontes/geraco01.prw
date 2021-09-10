#INCLUDE "totvs.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "fwbrowse.ch"
#INCLUDE "fwmvcdef.ch"
#INCLUDE "rwmake.ch"


// Contantes para o Step 2
#DEFINE pST2_CORTE            1
#DEFINE pST2_PRODUTO          2
#DEFINE pST2_DESCRICAO        3
#DEFINE pST2_SALDO_PEDIDO     4
#DEFINE pST2_SALDO_CORTE      5
#DEFINE pST2_MOTIVO_CORTE     6
#DEFINE pST2_MANIFESTO        7
#DEFINE pST2_PEDIDO           8
#DEFINE pST2_CODIGO_CLIENTE   9
#DEFINE pST2_LOJA_CLIENTE    10
#DEFINE pST2_NOME_CLIENTE    11
#DEFINE pST2_BAIRRO          12
#DEFINE pST2_CIDADE          13
#DEFINE pST2_TOTAL_PESO      14
#DEFINE pST2_TOTAL_MINIMO    15
#DEFINE pST2_CONDICAO_PAGTO  16
#DEFINE pST2_TES             17
#DEFINE pST2_PRECO_VENDA     18
#DEFINE pST2_PRECO_UNITARIO  19
#DEFINE pST2_PEDIDO_TIPO     20
#DEFINE pST2_ITEM_PRODUTO    21
#DEFINE pST2_C5_RECNO        22


// Contantes para o Step 3
#DEFINE pST3_CORTE            1
#DEFINE pST3_pPRODUTO         2
#DEFINE pST3_pDESCRICAO       3
#DEFINE pST3_CLIENTE          4
#DEFINE pST3_COD_CLIENTE      5
#DEFINE pST3_LOJ_CLIENTE      6
#DEFINE pST3_CONDICAO_PAGTO   7
#DEFINE pST3_BAIRRO           8
#DEFINE pST3_CIDADE           9
#DEFINE pST3_PEDIDO          10
#DEFINE pST3_MANIFESTO       11
#DEFINE pST3_QTDE_DISP       12
#DEFINE pST3_QTDE_CORTE      13
#DEFINE pST3_PESO_MINIMO     14
#DEFINE pST3_PESO_ATUAL      15
#DEFINE pST3_TES             16
#DEFINE pST3_PRECO_VENDA     17
#DEFINE pST3_PRECO_UNITARIO  18
#DEFINE pST3_PEDIDO_TIPO     19
#DEFINE pST3_ITEM_PRODUTO    20
#DEFINE pST3_MOTIVO_CORTE    21


// Contantes para o Pedido
#DEFINE pPED_PEDIDO           1
#DEFINE pPED_PRODUTO          2
#DEFINE pPED_ITEM             3
#DEFINE pPED_CORTE            4
#DEFINE pPED_MOTIVO_CORTE     5


/*/{Protheus.doc} GERACOR01 - Rotina de Gera Corte
	@author Edilson Nascimento
	@since 13/07/2021
/*/
USER FUNCTION GERACO01()

local _lContinua        := .T.
local _nFase            := 1
local _oDlg1
local _aTblMotvCort      := { }

local _cPedidoDe	:= '924917'   //'823295'   //  Space(6)
local _cPedidoAte       := '924917'   //'930610'   // Space(6)
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
local _aButtons3        := {}
local _nPos
local _nPesoAtual

local _oOk              := LoadBitMap(GetResources(), "LBOK")
local _oNo              := LoadBitMap(GetResources(), "LBNO")

local _aCabec
local _aItens
local _aLinha
local _nCount
local _nQtdVen
local _nPrcTotal
local _nQtdUnsVen
local _cMtvCorte
local _dDtaCorte
local _aErroAuto
local _cLogErro
local _nOpcX

private lMSHelpAuto := .T.
private lMsErroAuto := .F.


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
                        @ 00,00 TO 470,370 DIALOG _oDlg1 TITLE OemToAnsi( "Parametros para Corte de Pedido." )
                        @ 05,05 TO 210,180 TITLE OemToAnsi( " Parametros " )

                        @ 20,018        SAY     "Pedido de:"
                        @ 20,085        GET     _cPedidoDe      ;
                                        PICTURE "@99"           ;
                                        VALID   .T.

                        @ 35,018        SAY     "Pedido Ate:"
                        @ 35,085        GET     _cPedidoAte     ;
                                        PICTURE "@9999"         ;
                                        VALID   .T.

                        @ 50,018        SAY     "Manifesto de:"
                        @ 50,085        GET     _cManiDe        ;
                                        PICTURE "@!"            ;
                                        VALID   .T.

                        @ 70,018        SAY     "Manifesto de:"
                        @ 70,085        GET     _cManiAte       ;
                                        PICTURE "@!"            ;
                                        VALID   .T.

                        @ 90,018        SAY     "Emissao de:"
                        @ 90,085        GET     _dEmissaoDe     ;
                                        PICTURE "@D"            ;
                                        SIZE    40,20           ;
                                        VALID   iif( .not. empty( _dEmissaoDe ), .T., ( msgAlert("Informa o data de Emissao!","Atencao"), .F. ) )

                        @ 110,018       SAY     "Emissao ate:"
                        @ 110,085       GET     _dEmissaoAte    ;
                                        PICTURE "@D"            ;
                                        SIZE    40,20           ;
                                        VALID   iif( .not. empty( _dEmissaoAte ), .T., ( msgAlert("Data da emissao deve ser maior que a data incial!","Atencao"), .F. ) )

                        @ 130,018       SAY     "Forma de Processamento:"

                        @ 130,085       COMBOBOX _oCboFormaProce;
                                        VAR     _cFormaProce    ;
                                        ITEMS   {  "1 - Do Maior p/ Menor", "2 - Do Menor p/ Maior" }  ;
                                        SIZE    70,20           ;
                                        PIXEL                   ;
                                        OF      _oDlg1

                        @ 150,018       SAY     "Fill Rate:"
                        @ 150,085       COMBOBOX _oCboFilRate   ;
                                        VAR     _cFilRate       ;
                                        ITEMS   {  "1 - Sim", "2 - Não" }  ;
                                        SIZE    40,20           ;
                                        PIXEL                   ;
                                        OF      _oDlg1

                        @ 170,018       SAY     "Valida Peso:  : "
                        @ 170,085       COMBOBOX _oCboVldPeso   ;
                                        VAR     _cVldPeso       ;
                                        ITEMS   {  "1 - Sim", "2 - Não" } ;
                                        SIZE    40,20           ;
                                        PIXEL                   ;
                                        OF      _oDlg1

                        @ 190,018       SAY     "Motivo Corte:"
                        @ 190,085       COMBOBOX _oCboMotivoCorte       ;
                                        VAR      _cCboMotivoCorte       ;
                                        ITEMS   _aTblMotvCort           ;
                                        SIZE    90,20                   ;
                                        PIXEL                           ;
                                        OF      _oDlg1


                        @ 220,110 BMPBUTTON TYPE 01 ACTION ( _nFase++, Close(_oDlg1) )
                        @ 220,140 BMPBUTTON TYPE 02 ACTION ( _nFase--, _lContinua := .F., Close(_oDlg1) )

                        ACTIVATE  DIALOG _oDlg1 CENTER

                enddo


                // SELECAO DE PRODUTOS - STEP 2
                while _nfase == 2

                        _cArqQRY := GetNextAlias()

                        _cQuery := " SELECT SC5.C5_NUM PEDIDO, SC5.C5_TIPO TIPO_PEDIDO, SC5.C5_X_MAN MANIFESTO, SC5.C5_CONDPAG CONDPAG, "           + Chr(13)+Chr(10)
                        _cQuery += "        SC5.R_E_C_N_O_ RECNO, SB1.B1_DESC DESCRICAO, SB1.B1_PESO PESO_TOTAL, SC6.C6_PRODUTO PRODUTO, "          + Chr(13)+Chr(10)
                        _cQuery += "        SC6.C6_ITEM ITEM_PRODUTO, SC6.C6_X_MTVCT MOT_CORTE, SC6.C6_QTDVEN VENDIDO, SC6.C6_QTDENT ENTREGUE, "    + Chr(13)+Chr(10)
                        _cQuery += "        SC6.C6_TES TES, SC6.C6_PRCVEN PRECO_VENDA, SC6.C6_PRUNIT PRECO_UNITARIO, SC6.C6_UNSVEN UNSVEN, "        + Chr(13)+Chr(10)
                        _cQuery += "        SA1.A1_COD CODIGO, SA1.A1_LOJA LOJA, A1_NOME CLIENTE, SA1.A1_BAIRRO BAIRRO, SA1.A1_MUN CIDADE, "        + Chr(13)+Chr(10)
                        _cQuery += "        SA4.A4_X_PSMIN PESO_MINIMO"                                                                             + Chr(13)+Chr(10)
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

                                _aStep2 := { }
                                while (_cArqQRY)->( ! Eof() )

                                        AAdd( _aStep2,{ _oOk,                           ;   // CORTE
                                                        (_cArqQRY)->PRODUTO,            ;   // PRODUTO
                                                        (_cArqQRY)->DESCRICAO,          ;   // DESCRICAO
                                                        (_cArqQRY)->UNSVEN,             ;   // iif( (_cArqQRY)->ENTREGUE < (_cArqQRY)->VENDIDO, ( (_cArqQRY)->VENDIDO - (_cArqQRY)->ENTREGUE ), (_cArqQRY)->VENDIDO ), ;   // SALDO PEDIDO
                                                        (_cArqQRY)->UNSVEN,             ;   // Val( Transform( iif( (_cArqQRY)->ENTREGUE < (_cArqQRY)->VENDIDO, ( (_cArqQRY)->VENDIDO - (_cArqQRY)->ENTREGUE ), (_cArqQRY)->VENDIDO ), PesqPict("SB1","B1_CONV") ) ) , ;
                                                        _cCboMotivoCorte,               ;   // (_cArqQRY)->MOT_CORTE,          ;   // MOTIVO CORTE
                                                        (_cArqQRY)->MANIFESTO,          ;   // MANIFESTO
                                                        (_cArqQRY)->PEDIDO,             ;   // PEDIDO
                                                        (_cArqQRY)->CODIGO,             ;   // CODIGO CLIENTE
                                                        (_cArqQRY)->LOJA,               ;   // LOJA CLIENTE
                                                        (_cArqQRY)->CLIENTE,            ;   // NOME DO CLIENTE CLIENTE
                                                        (_cArqQRY)->BAIRRO,             ;   // BAIRRO
                                                        (_cArqQRY)->CIDADE,             ;   // CIDADE
                                                        (_cArqQRY)->PESO_TOTAL,         ;   // PESO
                                                        (_cArqQRY)->PESO_MINIMO,        ;   // PESO MINIMO
                                                        (_cArqQRY)->CONDPAG,            ;   // CONDICAO DE PAGAMENTO
                                                        (_cArqQRY)->TES,                ;   // TES
                                                        (_cArqQRY)->PRECO_VENDA,        ;   // PRECO DE VENDA
                                                        (_cArqQRY)->PRECO_UNITARIO,     ;   // PRECO UNITARIO
                                                        (_cArqQRY)->TIPO_PEDIDO,        ;   // TIPO PEDIDO
                                                        (_cArqQRY)->ITEM_PRODUTO,       ;   // ITEM PRODUTO
                                                        (_cArqQRY)->RECNO               ;   // RECNO
                                                        } )

                                        (_cArqQRY)->( dbSkip() )

                                enddo


                                // Define a ordem de exibicao dos dados
                                if Left( _cFormaProce, 1 ) == "1"
                                        _aStep2 := aSort( _aStep2, , , {|x,y| x[ pST2_SALDO_PEDIDO ] > y[ pST2_SALDO_PEDIDO ]})
                                else
                                        _aStep2 := aSort( _aStep2, , , {|x,y| x[ pST2_SALDO_PEDIDO ] < y[ pST2_SALDO_PEDIDO ]})
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
                                                                                                        "MOTIVO CORTE"      ;
                                                                                                        },,_oPainel2,,,,,,,,,,,, .F.,, .T.,, .T.,,,)

                                _oBrowStep2:bLDblClick := {||   (       iif( _aStep2[_oBrowStep2:nAt, pST2_CORTE]:CNAME == "LBNO", ;
                                                                                        iif(    Inf_Step2( _aStep2[_oBrowStep2:nAt, pST2_DESCRICAO ], _aStep2[_oBrowStep2:nAt, pST2_SALDO_PEDIDO ], @_aStep2[_oBrowStep2:nAt, pST2_SALDO_CORTE ], @_aStep2[_oBrowStep2:nAt, pST2_MOTIVO_CORTE ] ),;
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

                                _oBrowStep2:bLine := {  || { ;     
                                                                _aStep2[_oBrowStep2:nAt, pST2_CORTE        ] ,;
                                                                _aStep2[_oBrowStep2:nAt, pST2_PRODUTO      ] ,;
                                                                _aStep2[_oBrowStep2:nAt, pST2_DESCRICAO    ] ,;
                                                                _aStep2[_oBrowStep2:nAt, pST2_SALDO_PEDIDO ] ,;
                                                                Transform( _aStep2[_oBrowStep2:nAt, pST2_SALDO_CORTE  ], PesqPict("SB1","B1_CONV") ) ,;
                                                                _aStep2[_oBrowStep2:nAt, pST2_MOTIVO_CORTE ]  ;
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

                                ACTIVATE MSDIALOG _oDlg2 ON INIT EnchoiceBar( _oDlg2, { || _nfase++, _oDlg2:End() } , { || _nfase--, _oDlg2:End() },, _aButtons2)

                        Else
                                msgAlert("Nao existe registros selecionados!","Atencao")
                                _nfase := 1
                        EndIf

                        (_cArqQRY)->( dbCloseArea() )

                enddo


                // SELECAO DE PRODUTOS - STEP 3
                while _nfase == 3

                        // Carrega os titulos seleciionados
                        _aStep3 := { }
                        for _nPos := 1 to len( _aStep2 )

                                if _aStep2[ _nPos, pST2_CORTE ]:CNAME == "LBOK"

                                        _nPesoAtual := _aStep2[ _nPos, pST2_TOTAL_PESO ] *  _aStep2[ _nPos, pST2_SALDO_PEDIDO ]

                                        AAdd( _aStep3,{ _oOk,                                                                       ;   // CORTE
                                                        _aStep2[ _nPos, pST2_PRODUTO ],                                             ;   // PRODUTO
                                                        _aStep2[ _nPos, pST2_DESCRICAO ],                                           ;   // DESCRICAO
                                                        '(' + _aStep2[ _nPos, pST2_CODIGO_CLIENTE] + '-' +                          ;
                                                              _aStep2[ _nPos, pST2_LOJA_CLIENTE  ] + ')' +                          ;
                                                              Alltrim( _aStep2[ _nPos, pST2_NOME_CLIENTE ] ),                       ;   // (COD+LOJA+CLIENTE)
                                                        _aStep2[ _nPos, pST2_CODIGO_CLIENTE ],                                      ;   // CODIGO CLIENTE
                                                        _aStep2[ _nPos, pST2_LOJA_CLIENTE ],                                        ;   // CODIGO LOJA
                                                        _aStep2[ _nPos, pST2_CONDICAO_PAGTO  ],                                     ;   // CONDICAO PAGAMENTO
                                                        _aStep2[ _nPos, pST2_BAIRRO ],                                              ;   // BAIRRO
                                                        _aStep2[ _nPos, pST2_CIDADE ],                                              ;   // CIDADE
                                                        _aStep2[ _nPos, pST2_PEDIDO ],                                              ;   // PEDIDO
                                                        _aStep2[ _nPos, pST2_MANIFESTO ],                                           ;   // MANITESTO
                                                        _aStep2[ _nPos, pST2_SALDO_PEDIDO ],                                        ;   // QTDE DISP
                                                        _aStep2[ _nPos, pST2_SALDO_CORTE ],                                         ;   // QTDE A CORTAR
                                                        _aStep2[ _nPos, pST2_TOTAL_MINIMO ],                                        ;   // PESO MIN
                                                        _nPesoAtual,                                                                ;   // PESO ATUAL
                                                        _aStep2[ _nPos, pST2_TES ],                                                 ;   // TES
                                                        _aStep2[ _nPos, pST2_PRECO_VENDA ],                                         ;   // PRECO VENDA
                                                        _aStep2[ _nPos, pST2_PRECO_UNITARIO ],                                      ;   // PRECO UNITARIO
                                                        _aStep2[ _nPos, pST2_PEDIDO_TIPO ],                                         ;   // TIPO PEDIDO
                                                        _aStep2[ _nPos, pST2_ITEM_PRODUTO ],                                        ;   // ITEM DO PEDIDO
                                                        _aStep2[ _nPos, pST2_MOTIVO_CORTE ]                                         ;   // MOTIVO CORTE
                                                } )

                                endif

                        next

                        if len( _aStep3 ) > 0

                                // Define a ordem de exibicao dos dados
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
                                                                                        iif(    Inf_Step3( @_aStep3[_oBrowStep3:nAt, pST3_QTDE_DISP ], @_aStep3[_oBrowStep3:nAt, pST3_QTDE_CORTE ] ),;
                                                                                                _aStep3[_oBrowStep3:nAt, pST3_CORTE ] := _oOk, ;
                                                                                                _aStep3[_oBrowStep3:nAt, pST3_CORTE ] := _oNo ), ;
                                                                                        _aStep3[_oBrowStep3:nAt, pST3_CORTE ] := _oNo ) ;
                                                                ),      _oBrowStep3:refresh() ;
                                                        }

                                _oBrowStep3:SetArray( _aStep3 )

                                _oBrowStep3:bLine :=    {|| { ;     
                                                                _aStep3[_oBrowStep3:nAt, pST3_CORTE       ] ,;
                                                                _aStep3[_oBrowStep3:nAt, pST3_pPRODUTO    ] ,;
                                                                _aStep3[_oBrowStep3:nAt, pST3_pDESCRICAO  ] ,;
                                                                _aStep3[_oBrowStep3:nAt, pST3_CLIENTE     ] ,;
                                                                _aStep3[_oBrowStep3:nAt, pST3_BAIRRO      ] ,;
                                                                _aStep3[_oBrowStep3:nAt, pST3_CIDADE      ] ,;
                                                                _aStep3[_oBrowStep3:nAt, pST3_PEDIDO      ] ,;
                                                                _aStep3[_oBrowStep3:nAt, pST3_MANIFESTO   ] ,;
                                                                _aStep3[_oBrowStep3:nAt, pST3_QTDE_DISP   ] ,;
                                                                _aStep3[_oBrowStep3:nAt, pST3_QTDE_CORTE  ] ,;
                                                                _aStep3[_oBrowStep3:nAt, pST3_PESO_MINIMO ] ,;
                                                                _aStep3[_oBrowStep3:nAt, pST3_PESO_ATUAL  ]  ;
                                                        }}

/*                                _oBrowStep3:bChange     := {|| iif( Left( _cFormaProce, 1 ) == "1", aSort( _oBrowStep3:aArray, , , {|x,y| x[ pST3_QTDE_DISP ] > y[ pST3_QTDE_DISP ]}), ;
                                                                                                    aSort( _oBrowStep3:aArray, , , {|x,y| x[ pST3_QTDE_DISP ] < y[ pST3_QTDE_DISP ]}) ) } */
                                _oBrowStep3:Align := CONTROL_ALIGN_ALLCLIENT
                                _oBrowStep3:nScrollType := 1

                                _oBrowStep3:setFocus()
                                _oBrowStep3:refresh()                                

                                ACTIVATE MSDIALOG _oDlg3 ON INIT EnchoiceBar( _oDlg3, { || _nfase++, _oDlg3:End() } , { || _nfase--, _oDlg3:End() },, _aButtons3)
                        
                        else
                                msgAlert("Nao existe registros selecionados!","Atencao")
                                _nfase--
                        endif

                enddo


                // Gera o pedido de venda com os registros selecionados
                while _nfase == 4

                        if msgYesNo("O Processo e Irrversivel e ira ajustar os pedidos conforme o parametro.","DESEJA CONFIRMAR CORTE")

                                // Monta a estrutura com os pedidos selecionados
                                _aPed := {}
                                for _nPos := 1 to len( _aStep3 )

                                        if _aStep3[ _nPos, pST3_CORTE ]:CNAME == "LBOK"
                                                if AScan( _aPed, { |x|  x[ pPED_PEDIDO ] == _aStep3[ _nPos, pST3_PEDIDO] .and. ;
                                                                        x[ pPED_PRODUTO ] == _aStep3[ _nPos, pST3_pPRODUTO ] .and. ;
                                                                        x[ pPED_ITEM ] == _aStep3[ _nPos, pST3_ITEM_PRODUTO ] }  ) == 0
                                                                AAdd( _aPed,    {       _aStep3[ _nPos, pST3_PEDIDO         ], ;
                                                                                        _aStep3[ _nPos, pST3_pPRODUTO     ], ;
                                                                                        _aStep3[ _nPos, pST3_ITEM_PRODUTO ], ;
                                                                                        _aStep3[ _nPos, pST3_QTDE_CORTE   ], ;
                                                                                        _aStep3[ _nPos, pST3_MOTIVO_CORTE ]  ;
                                                                                } )

                                                endif
                                        EndIf

                                Next


                                // Tratamento para evitar erro no momento do processamento dos itens
                                if len( _aPed ) > 0

                                        _aPed := aSort( _aPed, , , {|x,y| x[ pPED_PEDIDO ]+x[ pPED_PRODUTO ]+x[ pPED_ITEM ] < y[ pPED_PEDIDO ]+y[ pPED_PRODUTO ]+y[ pPED_ITEM ] } )

                                        // Com os pedidos selecionados, monta a estrutura para alteracao no ppedido e excluir caso a
                                        // Quantidade de corte seja igual a 0
                                        for _nPos := 1 to len( _aPed )

                                                If SC5->( dbSetOrder(1), dbSeek( xFilial("SC5") + _aPed[ _nPos ][ pPED_PEDIDO ] ) )

                                                        _aCabec   := {}
                                                        _aItens   := {}

                                                        AAdd( _aCabec, { "C5_NUM",     SC5->C5_NUM,     Nil})
                                                        AAdd( _aCabec, { "C5_TIPO",    SC5->C5_TIPO,    Nil})
                                                        AAdd( _aCabec, { "C5_CLIENTE", SC5->C5_CLIENTE, Nil})
                                                        AAdd( _aCabec, { "C5_LOJACLI", SC5->C5_LOJACLI, Nil})
                                                        AAdd( _aCabec, { "C5_LOJAENT", SC5->C5_LOJAENT, Nil})
                                                        AAdd( _aCabec, { "C5_CONDPAG", SC5->C5_CONDPAG, Nil})

                                                        if SC6->( dbSetOrder(1), dbSeek( xFilial("SC6") + SC5->C5_NUM ) )

                                                                while SC6->C6_FILIAL == SC5->C5_FILIAL .and. ;
                                                                        SC6->C6_NUM == SC5->C5_NUM .and. ;
                                                                        ! SC6->( Eof() )

                                                                        _aLinha := {}
                                                                        AAdd( _aLinha, { "LINPOS",     "C6_ITEM",       SC6->C6_ITEM } )
                                                                        AAdd( _aLinha, { "AUTDELETA",  "N",             Nil})
                                                                        AAdd( _aLinha, { "C6_PRODUTO", SC6->C6_PRODUTO, Nil})

                                                                        // Alteracao do Item do pedido com a quantidade de Corte
                                                                        //If SC6->C6_NUM == _aPed[ _nPos ][ pPED_PEDIDO ] .and. ;
                                                                        //        SC6->C6_PRODUTO == _aPed[ _nPos ][ pPED_PRODUTO ] .and. ;
                                                                        //        SC6->C6_ITEM == _aPed[ _nPos ][ pPED_ITEM ]
                                                                        if ( _nPointer := AScan( _aPed, { |x| x[ pPED_PEDIDO ] == SC6->C6_NUM .and. x[ pPED_PRODUTO ] == SC6->C6_PRODUTO .and. x[ pPED_ITEM ] == SC6->C6_ITEM } ) ) > 0

                                                                                _nQtdVen    := SC6->C6_QTDVEN - _aPed[ _nPos ][ pPED_CORTE        ]
                                                                                _nPrcTotal  := SC6->C6_PRUNIT * _nQtdVen
                                                                                _nQtdUnsVen := SC6->C6_UNSVEN - _aPed[ _nPos ][ pPED_CORTE        ]
                                                                                _nQtdQTDCT  := _aPed[ _nPos ][ pPED_CORTE        ]                                                                                
                                                                                _cMtvCorte  := Left( _aPed[ _nPos ][ pPED_MOTIVO_CORTE ], 2 )
                                                                                _dDtaCorte  := Date()

                                                                                AAdd( _aLinha, { "C6_QTDVEN",  _nQtdVen,         Nil})
                                                                                AAdd( _aLinha, { "C6_PRCVEN",  SC6->C6_PRCVEN,   Nil})
                                                                                AAdd( _aLinha, { "C6_PRUNIT",  SC6->C6_PRUNIT,   Nil})
                                                                                AAdd( _aLinha, { "C6_VALOR",   _nPrcTotal,       Nil})
                                                                                AAdd( _aLinha, { "C6_UNSVEN",  _nQtdUnsVen,      Nil})

                                                                                AAdd( _aLinha, { "C6_X_MTVCT", _cMtvCorte,       Nil})
                                                                                AAdd( _aLinha, { "C6_X_DATCT", _dDtaCorte,       Nil})
                                                                                AAdd( _aLinha, { "C6_X_QTDCT", _nQtdQTDCT,       Nil})

                                                                        Else
                                                                                AAdd( _aLinha, { "C6_QTDVEN",  SC6->C6_QTDVEN,   Nil})
                                                                                AAdd( _aLinha, { "C6_PRCVEN",  SC6->C6_PRCVEN,   Nil})
                                                                                AAdd( _aLinha, { "C6_PRUNIT",  SC6->C6_PRUNIT,   Nil})
                                                                                AAdd( _aLinha, { "C6_VALOR",   SC6->C6_VALOR,    Nil})
                                                                                AAdd( _aLinha, { "C6_UNSVEN",  SC6->C6_UNSVEN,   Nil})                                                                                

                                                                                AAdd( _aLinha, { "C6_X_MTVCT", " ",              Nil})
                                                                                AAdd( _aLinha, { "C6_X_DATCT", CTod(''),         Nil})
                                                                                AAdd( _aLinha, { "C6_X_QTDCT", 0,                Nil})

                                                                        EndIf
                                                                        AAdd( _aLinha, { "C6_TES", SC6->C6_TES, Nil})
                                                                        AAdd( _aItens, _aLinha )

                                                                        SC6->( dbSkip() )

                                                                enddo

                                                        endif

                                                EndIf

                                                _nOpcX := 4
                                                LjMsgRun("Aguarde...   Alterando o Pedido de Venda...",,{|| MSExecAuto({| a, b, c, d| MATA410(a, b, c, d)}, _aCabec, _aItens, _nOpcX, .F.) } )

                                                If !lMsErroAuto
                                                        // Confirma a numeracao 
                                                        ConOut( "Incluido com sucesso! " )
                                                Else
                                                        ConOut("Erro na inclusao!")
                                                        _aErroAuto := GetAutoGRLog()
                                                        For _nCount := 1 To Len(_aErroAuto)
                                                                _cLogErro += StrTran(StrTran(_aErroAuto[_nCount], "<", ""), "-", "") + " "
                                                                ConOut(_cLogErro)
                                                        Next
                                                        
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
STATIC FUNCTION Inf_Step2( _cDescriProd, _nQuantPedido, _nQuantCorte, _cMotivoCorte )

local _oDlg1
local _oCboMotivoCorte
local _aTblMotvCort      := { }
local _lRetValue         := .F.
local _nOldQuantCorte    := _nQuantCorte
local _cOldMtCorte       := _cMotivoCorte

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
        If .not. _lRetValue
                _nQuantCorte  :=  _nOldQuantCorte
                _cMotivoCorte := _cOldMtCorte
        EndIf

return _lRetValue


/*=====================================================================================
Programa............: INF_STEP3(  _nQtdDisp, _nQtdCorte )
Autor...............: Edilson Nascimento
Data................: 13/07/2021
Descricao / Objetivo: Rotina para que sejam alteradas os valores de quantidade disponivel e quantidade de corte.
Doc. Origem.........: 
Solicitante.........: 
Uso.................: 
=======================================================================================*/
STATIC Function Inf_Step3(  _nQtdDisp, _nQtdCorte )

local _oDlg1
local _lRetValue         := .F.
local _nOldQtdDisp       := _nQtdDisp
local _nOldQtdCorte      := _nQtdCorte


        @ 00,00 TO 210,340 DIALOG _oDlg1 TITLE OemToAnsi( "Dados para o Corte" )

        @ 20,018        SAY     "Quantidade Disponivel:"
        @ 20,085        GET     _nQtdDisp                       ;
                        PICTURE PesqPict("SB1","B1_CONV")       ;
                        WHEN   .F.

        @ 35,018        SAY     "Quantidade de Corte:"
        @ 35,085        GET     _nQtdCorte                      ;
                        PICTURE PesqPict("SB1","B1_CONV")       ;
                        VALID   iif(_nQtdCorte > _nQtdDisp, ( msgAlert("Valor do corte nao pode ser maior que a quantidade disponivel !","Atencao"), .F. ), .T. )

        @ 090,090 BMPBUTTON TYPE 01 ACTION ( _lRetValue := .T., Close(_oDlg1) )
        @ 090,120 BMPBUTTON TYPE 02 ACTION ( _lRetValue := .F., Close(_oDlg1) )

        ACTIVATE  DIALOG _oDlg1 CENTER

        // Case tenha sido pressionado o botao de cancelamento da janela.
        If .not. _lRetValue
                _nQtdDisp  := _nOldQtdDisp
                _nQtdCorte := _nOldQtdCorte
        EndIf

return _lRetValue



