#INCLUDE "totvs.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "fwbrowse.ch"
#INCLUDE "fwmvcdef.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "fileio.ch"


#DEFINE pXML_CNPJ_TRANSPORTADORA      1
#DEFINE pXML_END_TRANSPORTADORA       2
#DEFINE pXML_CNPJ_REMETENTE           3
#DEFINE pXML_END_REMETENTE            4
#DEFINE pXML_CNPJ_CLIENTE             5
#DEFINE pXML_END_CLIENTE              6
#DEFINE pXML_CTE_ID                   7
#DEFINE pXML_CTE_TP                   8
#DEFINE pXML_CTE_SERIE                9
#DEFINE pXML_CTE_NUM                 10
#DEFINE pXML_CTE_CHAVE               11
#DEFINE pXML_CTE_EMISSAO             12
#DEFINE pXML_CTE_MODELO              13
#DEFINE pXML_CTE_MERCADORIA          14
#DEFINE pXML_CTE_VALOR               15
#DEFINE pXML_CTE_EMISSAO             16
#DEFINE pXML_CTE_ICMSB               17
#DEFINE pXML_CTE_ICMSA               18
#DEFINE pXML_CTE_ICMSV               19
#DEFINE pXML_CTE_CARGA               20
#DEFINE pXML_CTE_CHAVE_NFE           21

#DEFINE pXML_TOTAL_ARRAY             21


/*/{Protheus.doc} IMPCTE - Rotina de Importacao de CTE
	@author Edilson Nascimento
	@since 01/01/2021
/*/
USER FUNCTION JOBIMPCTE()

Local _cDirIn
local _aArquivos := {}
local _aTam      := {}

local _nHandle
local _nPos
local _nTam
local _nBytesReads
local _cXML       := ''
local _cError     := ''
local _cWarning   := ''
local _oXml
local _aDadosCTE
local _nCount

local _cChave

local _cSerie
local _cDoc
local _cData
local _cValor

local _cArqQRY
local _cQuery
local _nItem

local _dDtImp
local _cHhImp
local _dDtEmiss
local _cHrEmiss
local _cMsg

local _nTotLinhas
local _nPreco
local _nValor
local _nRateio
local _nPrecoLinha
local _nValorLinha

local _lOk          := .F.
local _cMessage     := " "



    // PREPARE ENVIRONMENT EMPRESA "02" FILIAL "01" USER "admin" PASSWORD "2Latin3" TABLES "SA1", "SA2", "SA4", "Z22", "Z30", "Z31", "Z32" MODULO "FAT"
    PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" USER "admin" PASSWORD "2018@0521" TABLES "SA1", "SA2", "SA4", "Z22", "Z30", "Z31", "Z32" MODULO "FAT"


    // Tratamento para o parametro In        
    _cDirIn := SuperGetMV( "MV_CTE_IN",, "\xmlcte\in\")
    If Right( AllTrim( _cDirIn ), 1 ) != '\'
        _cDirIn := AllTrim( _cDirIn) + '\'
    EndIf

    // Tratamento para o parametro Ou
    _cDirOu := SuperGetMV( "MV_CTE_OU",, "\xmlcte\ou\")
    If Right( AllTrim( _cDirOu ), 1 ) != '\'
        _cDirIn := AllTrim( _cDirOu) + '\'
    EndIf
    
    // Tratamento para o parametro Er
    _cDirEr := SuperGetMV( "MV_CTE_ER",, "\xmlcte\er\")
    If Right( AllTrim( _cDirEr ), 1 ) != '\'
        _cDirEr := AllTrim( _cDirEr) + '\'
    EndIf
    


    ADir( _cDirIn + '*.xml', _aArquivos, _aTam )
    If Len( _aArquivos ) > 0

        for _nPos  := 1 to len( _aArquivos )

            If ( _nHandle := FOpen( _cDirIn + _aArquivos[ _nPos ], FO_SHARED ) ) > 0
                
                // Dados do arquivo a ser processado
                _nTam        := FSeek( _nHandle, FS_SET, FS_END )
                FSeek( _nHandle, FS_SET, FS_SET )
                _cXML        := Space( _nTam )                
                _nBytesReads := fRead( _nHandle, @_cXML, _nTam )

                _oXml := XmlParser( _cXML, "_", @_cError, @_cWarning)

                If Empty( _cError ) .and. Empty( _cWarning )

                    If .not. XmlChildEx( _oXml ,"_CTEPROC") == Nil

                        // Emitente
                        if  .not. XmlChildEx( _oXml:_CTEPROC:_CTE:_INFCTE, "_EMIT") == Nil .OR. ;
                            .not. XmlChildEx( _oXml:_CTEPROC:_CTE:_INFCTE:_EMIT, "_ENDEREMIT")  == Nil

                            // Remetente
                            if  .not. XmlChildEx( _oXml:_CTEPROC:_CTE:_INFCTE, "_REM") == Nil .OR. ;
                                .not. XmlChildEx( _oXml:_CTEPROC:_CTE:_INFCTE:_REM, "_ENDERREME")  == Nil 

                                // Cliente
                                if  .not. XmlChildEx( _oXml:_CTEPROC:_CTE:_INFCTE, "_DEST") == Nil .AND. ;
                                    .not. XmlChildEx( _oXml:_CTEPROC:_CTE:_INFCTE:_DEST, "_ENDERDEST")  == Nil

                                    // CNPJ CLiente
                                    If .not. XmlChildEx( _oXml:_CTEPROC:_CTE:_INFCTE:_DEST, '_CNPJ' ) == Nil

                                        // Itens no documento
                                        If  .not. XmlChildEx( _oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC, "_INFNFE" ) == Nil

                                            _cChave                                := ''
                                            _aDadosCTE                             := Array( pXML_TOTAL_ARRAY )
                                            _aDadosCTE[ pXML_CTE_CHAVE_NFE       ] := { }


                                            _aDadosCTE[ pXML_CNPJ_TRANSPORTADORA ] := _oXml:_CTEPROC:_CTE:_INFCTE:_EMIT:_CNPJ:TEXT
                                            _aDadosCTE[ pXML_END_TRANSPORTADORA  ] := XMLEndereco( _oXml:_CTEPROC:_CTE:_INFCTE:_EMIT:_ENDEREMIT )
                                            _aDadosCTE[ pXML_CNPJ_REMETENTE      ] := _oXml:_CTEPROC:_CTE:_INFCTE:_REM:_CNPJ:TEXT
                                            _aDadosCTE[ pXML_END_REMETENTE       ] := XMLEndereco( _oXml:_CTEPROC:_CTE:_INFCTE:_REM:_ENDERREME )
                                            _aDadosCTE[ pXML_CNPJ_CLIENTE        ] := _oXml:_CTEPROC:_CTE:_INFCTE:_DEST:_CNPJ:TEXT
                                            _aDadosCTE[ pXML_END_CLIENTE         ] := XMLEndereco( _oXml:_CTEPROC:_CTE:_INFCTE:_DEST:_ENDERDEST )
                                            _aDadosCTE[ pXML_CTE_ID              ] := _oXml:_CTEPROC:_CTE:_INFCTE:_ID:TEXT
                                            _aDadosCTE[ pXML_CTE_TP              ] := _oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_TPCTE:TEXT
                                            _aDadosCTE[ pXML_CTE_SERIE           ] := _oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_SERIE:TEXT
                                            _aDadosCTE[ pXML_CTE_NUM             ] := _oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_NCT:TEXT
                                            _aDadosCTE[ pXML_CTE_CHAVE           ] := _oXml:_CTEPROC:_PROTCTE:_INFPROT:_CHCTE:TEXT
                                            _aDadosCTE[ pXML_CTE_EMISSAO         ] := _oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_DHEMI:TEXT
                                            _aDadosCTE[ pXML_CTE_MODELO          ] := _oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_MOD:TEXT
                                            _aDadosCTE[ pXML_CTE_MERCADORIA      ] := _oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_VCARGA:TEXT
                                            _aDadosCTE[ pXML_CTE_VALOR           ] := _oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_VREC:TEXT


                                            _aDadosCTE[ pXML_CNPJ_TRANSPORTADORA ] := PadR( _aDadosCTE[ pXML_CNPJ_TRANSPORTADORA ], TamSX3('A2_CGC')[ 1] )
                                            _aDadosCTE[ pXML_CNPJ_CLIENTE        ] := PadR( _aDadosCTE[ pXML_CNPJ_CLIENTE        ], TamSX3('A1_CGC')[ 1] )
                                            _aDadosCTE[ pXML_CTE_ID              ] := Upper( PadR( _aDadosCTE[ pXML_CTE_ID              ], TamSX3('Z22_CTEID')[ 1] ) )


                                            If .not. XmlChildEx( _oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS ,"_ICMS00") == Nil
                                                _aDadosCTE[ pXML_CTE_ICMSB           ] := _oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_VBC:TEXT
                                                _aDadosCTE[ pXML_CTE_ICMSA           ] := _oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_PICMS:TEXT
                                                _aDadosCTE[ pXML_CTE_ICMSV           ] := _oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_VICMS:TEXT
                                            Else 
                                                _aDadosCTE[ pXML_CTE_ICMSB           ] := "0.00"
                                                _aDadosCTE[ pXML_CTE_ICMSA           ] := "0.00"
                                                _aDadosCTE[ pXML_CTE_ICMSV           ] := "0.00"
                                            Endif


                                            // Informações da carga
                                            If  .not. XmlChildEx( _oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM, "_INFCARGA") == Nil .OR. ;
                                                .not. XmlChildEx( _oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFCARGA, "_INFQ")  == Nil 

                                                if ValType( _oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ) == 'O'
                                                    XmlNode2Arr( _oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ,"_INFQ" )
                                                Endif

                                                For _nCount := 1 to Len( _oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ )

                                                    _cUnMedida := Upper( AllTrim( _oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ[ _nCount ]:_TPMED:TEXT ) )

                                                    If  'PESO/PES./BRU/KG/KG./KILO'  $ _cUnMedida
                                                        _aDadosCTE[ pXML_CTE_CARGA           ] := _oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ[ _nCount ]:_QCARGA:TEXT
                                                    Else 
                                                        if Empty( _aDadosCTE[ pXML_CTE_CARGA           ] )
                                                            _aDadosCTE[ pXML_CTE_CARGA           ] := _oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ[ _nCount ]:_QCARGA:TEXT
                                                        Endif
                                                    endif
                                                    
                                                Next

                                                if Empty( _aDadosCTE[ pXML_CTE_CARGA           ] )
                                                    _aDadosCTE[ pXML_CTE_CARGA           ] := 0
                                                Else
                                                    _aDadosCTE[ pXML_CTE_CARGA           ] := StrTran( _aDadosCTE[ pXML_CTE_CARGA           ],",",".")
                                                Endif

                                            Else
                                                _aDadosCTE[ pXML_CTE_CARGA           ] := 0
                                            Endif


                                            // Informações de NFs de Saida
                                            If .not. XmlChildEx( _oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC ,"_INFNFE") == Nil

                                                XmlNode2Arr( _oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE,"_INFNFE" )

                                                If Len( _oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE ) > 0 
                                                    For _nCount := 1 To Len( _oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE )
                                                        _cChave := _oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE[ _nCount ]:_CHAVE:TEXT
                                                        AAdd( _aDadosCTE[ pXML_CTE_CHAVE_NFE       ], { 0 , _cChave } )
                                                    Next
                                                Endif	

                                            // Por Documento
                                            Else 

                                                XmlNode2Arr( _oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF,"_INFNF" )

                                                if Len( _oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF ) > 0 
                                                    For _nCount := 1 To Len( _oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF )
                                                        _cSerie := StrZero( Val( _oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF[nY]:_SERIE:TEXT),TamSX3('F2_SERIE')[ 1] )
                                                        _cDoc   := StrZero( Val( _oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF[nY]:_NDOC:TEXT), 6 )
                                                        _cData  := StrTran( _oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF[nY]:_DEMI:TEXT, '-', '' )
                                                        _cValor := _oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF[nY]:_VPROD:TEXT
                                                        AAdd( _aDadosCTE[ pXML_CTE_CHAVE_NFE       ], { 1 , _cSerie, _cDoc, _cData, _cValor } )
                                                    Next
                                                Endif

                                            Endif

                                            begin transaction

                                                /* ZERAR NOTAS e RATEIOS SSOCIADOS */    
                                                _cQuery := " UPDATE " + RetSQLName("Z30")
                                                _cQuery += "    SET D_E_L_E_T_ = ' ', R_E_C_D_E_L_ = R_E_C_N_O_ "
                                                _cQuery += "  WHERE D_E_L_E_T_ = ' '"
                                                _cQuery += "        AND Z30_FILIAL = '" + xFilial("Z30") + "'"
                                                _cQuery += "        AND Z30_CTEID = '" + _aDadosCTE[ pXML_CTE_ID              ] + "'"

                                                If ( tcSQLExec( _cQuery ) < 0)
                                                    conout( TcSQLError() )
                                                EndIf

                                                _nItem := 0
                
                                                for _nCount := 1 to Len( _aDadosCTE[ pXML_CTE_CHAVE_NFE       ] )

                                                    _cArqQRY := GetNextAlias()

                                                    _cQuery := " SELECT SF2.R_E_C_N_O_ AS REG "
                                                    _cQuery += "   FROM " + RetSQLName('SF2') + " SF2 "
                                                    _cQuery += " WHERE SF2.D_E_L_E_T_ = ' ' AND SF2.F2_FILIAL = '" + xFilial('SF2') + "' "
                                                    if _aDadosCTE[ pXML_CTE_CHAVE_NFE       ][ _nCount ][ 1] == 0
                                                        _cQuery += "   AND SF2.F2_SERIE = '001' "
                                                        _cQuery += "   AND LTRIM(RTRIM(SF2.F2_CHVNFE)) = '" + AllTrim( _aDadosCTE[ pXML_CTE_CHAVE_NFE       ][ _nCount ][ 2]) + "' "
                                                    else
                                                        _cQuery += "   AND SF2.F2_SERIE = '"   + _aDadosCTE[ pXML_CTE_CHAVE_NFE       ][ _nCount ][ 2] + "' "
                                                        _cQuery += "   AND SF2.F2_DOC = '"     + _aDadosCTE[ pXML_CTE_CHAVE_NFE       ][ _nCount ][ 3] + "' "
                                                        _cQuery += "   AND SF2.F2_EMISSAO = '" + _aDadosCTE[ pXML_CTE_CHAVE_NFE       ][ _nCount ][ 4] + "' "
                                                        _cQuery += "   AND SF2.F2_VALMERC = '" + _aDadosCTE[ pXML_CTE_CHAVE_NFE       ][ _nCount ][ 5] + "' "
                                                    endif

                                                    dbUseArea( .T., "TOPCONN", TCGENQRY( ,, ChangeQuery( _cQuery )), (_cArqQRY), .T., .T. )

                                                    (_cArqQRY)->( dbGoTop() )
                                                    If .not. (_cArqQRY)->( Eof() )

                                                        while .not. (_cArqQRY)->( Eof() )

                                                            SF2->( dbGoTo( (_cArqQRY)->REG) )
                                                            if .not. SF2->( Eof() )
                                                                
                                                                _nItem += 1

                                                                dbSelectArea("Z30")
                                                                RecLock("Z30",.T.)
                                                                    Z30->Z30_FILIAL := xFilial("Z30")
                                                                    Z30->Z30_CTEID  := _aDadosCTE[ pXML_CTE_ID              ]
                                                                    Z30->Z30_ITEM   := StrZero( _nItem, 2 )
                                                                    Z30->Z30_SERIE  := SF2->F2_SERIE
                                                                    Z30->Z30_DOC    := SF2->F2_DOC
                                                                    Z30->Z30_PESO   := SF2->F2_PBRUTO
                                                                    Z30->Z30_VMERCA := SF2->F2_VALMERC
                                                                    Z30->Z30_AICMS  := 0
                                                                    Z30->Z30_BICMS  := 0
                                                                    Z30->Z30_VICMS  := 0 
                                                                Z30->( msUnlock() )

                                                                if ValType( _aDadosCTE[ pXML_CTE_CARGA           ] ) == 'N'
                                                                    _aDadosCTE[ pXML_CTE_CARGA           ] += SF2->F2_PBRUTO
                                                                Endif

                                                            Endif

                                                            (_cArqQRY)->( dbSkip() )

                                                        enddo

                                                    EndIf

                                                    (_cArqQRY)->( dbCloseArea() )

                                                next


                                                // Transportadora
                                                dbSelectArea('SA4')
                                                If SA4->( dbSetOrder(3), dbSeek( xFilial('SA4') + _aDadosCTE[ pXML_CNPJ_TRANSPORTADORA ] ) )

                                                    // Fornecedor
                                                    dbSelectArea('SA2')
                                                    If SA2->( dbSetOrder(3), dbSeek( xFilial('SA2') + _aDadosCTE[ pXML_CNPJ_TRANSPORTADORA ] ) )

                                                        // Cliente
                                                        dbSelectArea('SA1')
                                                        If SA1->(dbSetOrder(3), dbSeek( xFilial('SA1') + _aDadosCTE[ pXML_CNPJ_CLIENTE        ] ) )


                                                            if ValType( _aDadosCTE[ pXML_CTE_CARGA           ] ) <> 'N' 
                                                              _aDadosCTE[ pXML_CTE_CARGA           ] := Val( _aDadosCTE[ pXML_CTE_CARGA           ] )
                                                            Endif

                                                            _dDtImp   := Date()
                                                            _cHhImp   := Substr( Time(), 1, 2) + Substr( Time(), 4, 2) + Substr( Time(), 7, 2 )

                                                            _dDtEmiss := SToD( StrTran( SubStr( _aDadosCTE[ pXML_CTE_EMISSAO         ], 1, 10), '-', '' ) )
                                                            _cHrEmiss := StrTran( SubStr( _aDadosCTE[ pXML_CTE_EMISSAO         ], 12, 8), ':', '' )

                                                            _cMsg     := '<strong>Transportadora:</strong> (' + SA4->A4_COD + ') ' + SubStr( SA2->A2_NOME, 1, 40) + '<br />'
                                                            _cMsg     += '<strong>Serie:</strong> ' + Alltrim( _aDadosCTE[ pXML_CTE_SERIE           ] ) + ' - <strong>Documento:</strong> ' + StrZero( Val( _aDadosCTE[ pXML_CTE_NUM             ] ),TamSX3('F1_DOC')[1]) + '<br />'
                                                            _cMsg     += '<strong>Emissão:</strong> ' + DToC( _dDtEmiss ) + ' - <strong>Valor:</strong> R$ ' + StrTran( _aDadosCTE[ pXML_CTE_VALOR           ], '.', ',' )

                                                            dbSelectArea('Z22')
                                                            If .not. Z22->( dbSetOrder(2), dbSeek( xFilial('Z22') + _aDadosCTE[ pXML_CTE_ID              ] ) )

                                                                  RecLock('Z22',.T.)
                                                                      Z22->Z22_FILIAL  := xFilial('Z22')
                                                                      Z22->Z22_SERIE   := _aDadosCTE[ pXML_CTE_SERIE           ]
                                                                      Z22->Z22_DOC     := StrZero( Val( _aDadosCTE[ pXML_CTE_NUM             ] ), TamSX3('F1_DOC')[ 1] )
                                                                      Z22->Z22_TIPO    := _aDadosCTE[ pXML_CTE_TP              ]
                                                                      Z22->Z22_CHAVE   := _aDadosCTE[ pXML_CTE_CHAVE           ]
                                                                      Z22->Z22_CTEID   := _aDadosCTE[ pXML_CTE_ID              ]
                                                                      Z22->Z22_DTEMIS  := _dDtEmiss
                                                                      Z22->Z22_HREMIS  := _cHrEmiss
                                                                      Z22->Z22_FORNEC  := SA2->A2_COD
                                                                      Z22->Z22_LOJAF   := SA2->A2_LOJA
                                                                      Z22->Z22_NOMEF   := SubStr( SA2->A2_NOME, 1, 40 )
                                                                      Z22->Z22_CNPJF   := _aDadosCTE[ pXML_CNPJ_TRANSPORTADORA ]
                                                                      Z22->Z22_CLIENT  := SA1->A1_COD
                                                                      Z22->Z22_LOJAC   := SA1->A1_LOJA
                                                                      Z22->Z22_NOMEC   := SubStr( SA1->A1_NOME, 1, 40 )
                                                                      Z22->Z22_CNPJC   := _aDadosCTE[ pXML_CNPJ_CLIENTE        ]
                                                                      Z22->Z22_TRANSP  := SA4->A4_COD
                                                                      Z22->Z22_QTDNFS  := Len( _aDadosCTE[ pXML_CTE_CHAVE_NFE       ] )
                                                                      Z22->Z22_VLRMER  := Val( _aDadosCTE[ pXML_CTE_MERCADORIA      ] )
                                                                      Z22->Z22_PBRUTO  := _aDadosCTE[ pXML_CTE_CARGA           ]
                                                                      Z22->Z22_AICMS   := Val( _aDadosCTE[ pXML_CTE_ICMSA           ] )
                                                                      Z22->Z22_VICMS   := Val( _aDadosCTE[ pXML_CTE_ICMSV           ] )
                                                                      Z22->Z22_XML     := _cXML
                                                                      Z22->Z22_DTIMP   := _dDtImp
                                                                      Z22->Z22_HRIMP   := _cHhImp
                                                                      Z22->Z22_UIMP    := cUserName
                                                                      Z22->Z22_VALOR   := Val( _aDadosCTE[ pXML_CTE_VALOR           ] )
                                                                      Z22->Z22_STATUS  := ' '
                                                                      // Transportadora
                                                                      Z22->Z22_EMUN    := _aDadosCTE[ pXML_END_TRANSPORTADORA  ][ 1]
                                                                      Z22->Z22_EUF     := _aDadosCTE[ pXML_END_TRANSPORTADORA  ][ 2]
                                                                      Z22->Z22_ECEP    := _aDadosCTE[ pXML_END_TRANSPORTADORA  ][ 3]
                                                                      // Mezzani
                                                                      Z22->Z22_RMUN    := _aDadosCTE[ pXML_END_REMETENTE       ][ 1]
                                                                      Z22->Z22_RUF     := _aDadosCTE[ pXML_END_REMETENTE       ][ 2]
                                                                      Z22->Z22_RCEP    := _aDadosCTE[ pXML_END_REMETENTE       ][ 3]
                                                                      // Cliente
                                                                      Z22->Z22_DMUN    := _aDadosCTE[ pXML_END_CLIENTE         ][1]
                                                                      Z22->Z22_DUF     := _aDadosCTE[ pXML_END_CLIENTE         ][2]
                                                                      Z22->Z22_DCEP    := _aDadosCTE[ pXML_END_CLIENTE         ][3]
                                                                      // Distancias
                                                                      Z22->Z22_KMED    := Distancia( _aDadosCTE[ pXML_END_TRANSPORTADORA  ], _aDadosCTE[ pXML_END_CLIENTE         ] )
                                                                      Z22->Z22_KMRD    := Distancia( _aDadosCTE[ pXML_END_REMETENTE       ], _aDadosCTE[ pXML_END_CLIENTE         ] )
                                                                  Z22->( msUnlock() )

                                                            EndIf

                                                            dbSelectArea('Z22')
                                                            If( Z22->( dbSetOrder(2), dbSeek( xFilial('Z22') + _aDadosCTE[ pXML_CTE_ID              ] ) ) )

                                                                /* ZERAR NOTAS e RATEIOS SSOCIADOS */    
                                                                _cQuery := " UPDATE " + RetSQLName("Z30")
                                                                _cQuery += "    SET D_E_L_E_T_ = ' ', R_E_C_D_E_L_ = R_E_C_N_O_ "
                                                                _cQuery += "  WHERE D_E_L_E_T_ = ' '"
                                                                _cQuery += "        AND Z30_FILIAL = '" + xFilial("Z30") + "'"
                                                                _cQuery += "        AND Z30_CTEID = '" + _aDadosCTE[ pXML_CTE_ID              ] + "'"

                                                                If ( tcSQLExec( _cQuery ) < 0)
                                                                  conout( TcSQLError() )
                                                                EndIf

                                                            Else

                                                                _cArqQRY := GetNextAlias()

                                                                // GERAR RATEIO
                                                                _cQuery := " SELECT SD2.D2_CCUSTO AS CENTRO_CUSTO, SD2.CTT_DESC01 AS DESCRICAO, "
                                                                _cQuery += "        ROUND(SUM(SD2.D2_TOTAL),2,1) AS VALOR, ROUND(SUM(SD2.D2_PESO),2,1) AS PESO "                                                    
                                                                _cQuery += "   FROM " + RetSQLName("SD2") + " SD2 (NOLOCK) "
                                                                _cQuery += "   LEFT JOIN " + RetSQLName("CTT") + " CTT (NOLOCK) ON CTT.D_E_L_E_T_ <> '*' "
                                                                _cQuery += "                             AND CTT.CTT_FILIAL = ''"
                                                                _cQuery += "                             CTT.CTT_CUSTO = SD2.D2_CCUSTO"                                                    
                                                                _cQuery += "  WHERE SD2.D_E_L_E_T_ <> '*'"
                                                                _cQuery += "        AND SD2.D2_FILIAL = '" + xFilial("SD2") + "' "                                                    
                                                                _cQuery += "        AND SD2.D2_SERIE + SD2.D2_DOC IN "
                                                                _cQuery += "            ( SELECT Z30_SERIE + Z30_DOC FROM " + RetSQLName("Z30") + " Z30 (NOLOCK) "
                                                                _cQuery += "               WHERE Z30.D_E_L_E_T_ <> '*'"
                                                                _cQuery += "                     AND Z30.Z30_FILIAL = '" + xFilial("Z30") + "'"
                                                                _cQuery += "                     AND Z30.Z30_CTEID = '" + _aDadosCTE[ pXML_CTE_ID              ] + "' ) "
                                                                _cQuery += "  GROUP BY SD2.D2_CCUSTO, CTT.CTT_DESC01 "
                                                                _cQuery += "  ORDER BY ROUND( SUM( SD2.D2_PESO ), 2, 1)"

                                                                dbUseArea( .T., "TOPCONN", TCGENQRY( ,, ChangeQuery( _cQuery )), (_cArqQRY), .T., .T. )

                                                                (_cArqQRY)->( dbGoTop() )
                                                                If ! (_cArqQRY)->( Eof() )

                                                                  _nTotLinhas := 0
                                                                  dbSelectArea( _cArqQRY )
                                                                  (_cArqQRY)->( dbGoTop() )
                                                                  Count To _nTotLinhas
                                                                  (_cArqQRY)->( dbGoTop() )

                                                                    _nPreco  := 100
                                                                    _nValor  := Val( _aDadosCTE[ pXML_CTE_VALOR           ] )
                                                                    _nRateio := 0

                                                                    While .not. (_cArqQRY)->( Eof() )

                                                                        _nRateio += 1

                                                                        if _nRateio == _nTotLinhas
                                                                            _nPrecoLinha := _nPreco
                                                                            _nValorLinha := _nValor
                                                                        else 
                                                                            _nPrecoLinha := Round( ( (_cArqQRY)->PESO / _aDadosCTE[ pXML_CTE_CARGA           ] ) * 100 , 2 )
                                                                            _nValorLinha := Val( _nValor ) * ( _nPrecoLinha / 100 )
                                                                            _nPreco      -= _nPrecoLinha
                                                                            _nValor      -= _nValorLinha
                                                                        Endif

                                                                        dbSelectArea("Z32")
                                                                        RecLock("Z32",.T.)
                                                                            Z32->Z32_FILIAL := xFilial("Z32")
                                                                            Z32->Z32_CTEID  := _aDadosCTE[ pXML_CTE_ID              ]
                                                                            Z32->Z32_ITEM   := StrZero( _nRateio, 3 )
                                                                            Z32->Z32_CC     := (_cArqQRY)->CENTRO_CUSTO
                                                                            Z32->Z32_VALOR  := (_cArqQRY)->VALOR
                                                                            Z32->Z32_PESO   := (_cArqQRY)->PESO
                                                                            Z32->Z32_PERC   := _nPrecoLinha
                                                                            Z32->Z32_VRATEI := _nValorLinha
                                                                            Z32->Z32_AICMS  := Val( _aDadosCTE[ pXML_CTE_ICMSA           ] )
                                                                            Z32->Z32_BICMS  := _nValorLinha
                                                                            Z32->Z32_VICMS  := _nValorLinha * ( Val( _aDadosCTE[ pXML_CTE_ICMSA           ] ) / 100 )
                                                                        Z32->(MsUnlock())     

                                                                        (_cArqQRY)->( dbSkip() )

                                                                    EndDo

                                                                EndIf

                                                                (_cArqQRY)->( dbCloseArea() )

                                                            EndIf

                                                        EndIf

                                                    EndIf

                                                EndIf

                                            end transaction

                                            //
                                            // Arquivo processado com sucesso
                                            //
                                            _lOk := .T.

                                        Else
                                            //
                                            // Nao foram identificados itens no documento
                                            //
                                            _lOk := .F.

                                            _cMessage := "Nao foi identificada itens no documento importado"

                                            conout( "[" + DToS( Date() ) + "][" + Time() + "] Nao foram identificados itens no documento : " + _aArquivos[ _nPos ] )
                                        Endif

                                    else
                                        //
                                        // Problemas com o CNPJ do clieente informando no arquivo
                                        //
                                        _lOk := .F.

                                        _cMessage := "Nao foi identificada informacoes de CNPJ do cliente"

                                        conout( "[" + DToS( Date() ) + "][" + Time() + "] Problemas com o CNPJ do clieente informando no arquivo : " + _aArquivos[ _nPos ] )
                                    endif

                                Else
                                    //
                                    // Caso Erro ao processar o arquivo XML, move para a pasta de erros
                                    //
                                    _lOk := .F.

                                    _cMessage := "Nao foi identificada informacoes do destino"

                                    conout( "[" + DToS( Date() ) + "][" + Time() + "] Problema na estrutura do arquivo : " + _aArquivos[ _nPos ] )
                                Endif

                            Else
                                _lOk := .F.

                                _cMessage := "Nao foi identificada informacoes do remetente"
                            Endif

                        Else
                            _lOk := .F.

                            _cMessage := "Nao foi identificada informacoes do emitente"
                        EndIf

                    Else
                        _lOk := .F.

                        _cMessage := "Nao foi identificada a TAG _CTEPROC no arquivo importado"

                    EndIf 

                Else
                    //
                    // Caso Erro ao processar o arquivo XML, move para a pasta de erros
                    //
                    _lOk := .F.

                    _cMessage := "Erro XML - " + AllTrim( _cError ) + " - " + AllTrim( _cWarning )

                EndIf

                FClose( _nHandle )

            Else
                //
                // Caso Erro ao processar o arquivo XML, move para a pasta de erros
                //
                _lOk := .F.

                _cMessage := "Nao foi possival realiar a abertura do arquivo - " + AllTrim( _cDirIn + _aArquivos[ _nPos ] )

            EndIf

            if _lOk
                //
                // Arquivo Processado Corretamente
                //

                EnvEmail( 1, _aArquivos[ _nPos ], _cMessage )                
                If __CopyFile( _cDirIn + _aArquivos[ _nPos ], _cDirOu + _aArquivos[ _nPos ] )
                  FErase( _cDirIn + _aArquivos[ _nPos ] )
                Endif

            else
                //
                // Caso tenha ocorrido algum erro na abertura do arquivo move para a pasta de erros
                //

                EnvEmail( 2, _aArquivos[ _nPos ], _cMessage )
                If __CopyFile( _cDirIn + _aArquivos[ _nPos ], _cDirEr + _aArquivos[ _nPos ] )
                    FErase( _cDirIn + _aArquivos[ _nPos ] )
                Endif
            Endif

        next

    Else
        conout( "[" + DToS( Date() ) + "][" + Time() + "] Nao existem arquivos a serem processados" )
    EndIf

    RESET ENVIRONMENT

Return


/*/{Protheus.doc} XMLEndereco - Rotina para desmebramento do endereco
	@author Edilson Nascimento
	@since 01/01/2021
/*/
STATIC FUNCTION XMLEndereco( oEndereco )

Local _aRetValue := { '', '', '' }

    // _aRetValue[ 1] - MUNICIPIO
    // _aRetValue[ 2] - UF
    // _aRetValue[ 3] - CEP

    if .not. XmlChildEx ( oEndereco ,"_XMUN") == Nil
        _aRetValue[ 1] := Alltrim( Upper( oEndereco:_XMUN:TEXT))
    Endif

    if .not. XmlChildEx ( oEndereco ,"_UF") == Nil
        _aRetValue[ 2] := Alltrim( Upper( oEndereco:_UF:TEXT))
    Endif

    if .not. XmlChildEx ( oEndereco ,"_CEP") == Nil
        _aRetValue[ 3] := Alltrim( Upper( oEndereco:_CEP:TEXT))
    Endif

Return _aRetValue


/*/{Protheus.doc} XMLEndereco - Rotina para retornar a distancia entre enderecos
	@author Edilson Nascimento
	@since 01/01/2021
/*/
STATIC FUNCTION Distancia( aOrigem, aDestino )

Local _nRetValue := 0
Local _cOrigem
Local _cDestino
local _cArqQRY
local _cQuery


    // Algum Campo Vazio .... não processa nada e retorna 0
    if .not. Empty( aOrigem[ 1]) .or. .not. Empty( aOrigem[ 2]) .or. .not. Empty( aDestino[ 1] ) .or. Empty( aDestino[ 2] )

        aOrigem[ 1]  := StrTran( aOrigem[ 1], "'", " ")
        aOrigem[ 2]  := StrTran( aOrigem[ 2], "'", " ")

        aDestino[ 1] := StrTran( aDestino[ 1], "'", " ")
        aDestino[ 2] := StrTran( aDestino[ 2], "'", " ")

        _cArqQRY := GetNextAlias()

        _cQuery := " SELECT TOP 1 Z3.Z31_KM AS KM"
        _cQuery += "   FROM " + RetSQLName("Z31") + " Z3 "
        _cQuery += " WHERE D_E_L_E_T_ = ' ' AND Z31_FILIAL = '" + xFilial("Z31") + "' "
        _cQuery += "       AND ( ( Z3.Z31_OMUN = '" + NoAcento(aOrigem[ 1]) + "' AND Z3.Z31_OUF = '" + NoAcento(aOrigem[ 2]) + "' AND Z3.Z31_DMUN = '" + NoAcento(aDestino[ 1]) + "' AND Z3.Z31_DUF = '" + NoAcento(aDestino[ 2]) + "' )"
        _cQuery += "       OR   ( Z3.Z31_OMUN = '" + NoAcento(aDestino[ 1]) + "' AND Z3.Z31_OUF = '" + NoAcento(aDestino[ 2]) + "' AND Z3.Z31_DMUN = '" + NoAcento(aOrigem[ 1]) + "' AND Z3.Z31_DUF = '" + NoAcento(aDestino[ 2]) + "' ) ) "
    
        dbUseArea( .T., "TOPCONN", TCGENQRY( ,, ChangeQuery( _cQuery )), (_cArqQRY), .T., .T. )

        // se encontrou uma referencia não precisa cadastrar
        if .not. (_cArqQRY)->( Eof() )
            _nRetValue := (_cArqQRY)->KM
        else 

            _cOrigem := iif( .not. Empty( aOrigem[ 2] ), iif( Empty( _cOrigem ), '', ',' ) + AllTrim( NoAcento(aOrigem[ 2]) ), '' )
            _cOrigem += iif( .not. Empty( aOrigem[ 1] ), iif( Empty( _cOrigem ), '', ',' ) + AllTrim( NoAcento(aOrigem[ 1]) ), '' )

            _cDestino := iif( .not. Empty( aDestino[ 2]), iif( Empty( _cDestino ), '', ',') + AllTrim( NoAcento(aDestino[ 2]) ), '')
            _cDestino += iif( .not. Empty( aDestino[ 1]), iif( Empty( _cDestino ), '', ',') + AllTrim( NoAcento(aDestino[ 1]) ) , '' )


            //// - Edilson - Implementar API
            ////_nRetValue := u_GMapsDist(cOrigAux,cDestAux)

            dbSelectArea("Z31")
            RecLock("Z31",.T.)
                Z31->Z31_FILIAL := xFilial("Z31")
                Z31->Z31_OMUN   := _cOrigem
                Z31->Z31_OUF    := _cOrigem
                Z31->Z31_OCEP   := ''
                Z31->Z31_DMUN   := _cDestino
                Z31->Z31_DUF    := _cDestino
                Z31->Z31_DCEP   := ''
                Z31->Z31_TEMPO  := 0
                Z31->Z31_KM     := _nRetValue
            Z31->(MsUnlock())

        Endif

        (_cArqQRY)->( dbCloseArea() )

    EndIf

Return _nRetValue


/*/{Protheus.doc} XMLEndereco - Monta o email informando o status do arquivo importado
	@author Edilson Nascimento
	@since 29/11/2021
/*/
Static Procedure EnvEmail( nCodEnv, cNomeArq, cMsg)

Local cXServer 	:= SuperGetMV( "MV_RELACNT",, " ") // Conta de email para o envio
Local cXConta  	:= SuperGetMV( "MV_RELAUSR",, " ") // Usuario para autenticacao na conta
Local cPasswrd 	:= SuperGetMV( "MV_RELAPSW",, " ") // Senha para autenticacao no servidor de email
Local cXDestin 	:= SuperGetMV( "MV_USR_ENV",, " ") // Relacao de usuario que irao recber o status do arquivo importado
Local cEmRemet 	:= SuperGetMV( "MV_USR_REM",, " ") // Relacao do usuario que esta realizando o envio do status para o usuario
Local cXAssunt  := "INTEGRACAO CTE"

    DEFAULT cMsg := " "


    cHTML := '<!DOCTYPE html>'
    cHTML += '<html>'
    cHTML += '<head>'
    cHTML += '<meta charset="UTF-8"/>'
    cHTML += '<title>Importador CTE</title>'
    cHTML += '</head>'
    cHTML += '<body>; 
      do case
        case nCodEnv == 1
          cHTML += 'Arquivo: ' + cNomeArq + ' - Importado Corretamente'
        case nCodEnv == 2
          cHTML += 'Arquivo: ' + cNomeArq + ' - Erro na Importacao'
          cHTML += '   Erro: ' + cMsg
      endcase
    cHTML += '</body>'
    cHTML += '</html>'


    // EnvMailC(cXDestin , cXServer , cXConta , cEmRemet , cPasswrd , cHTML, cXAssunt)
    U_NewEmail( cXConta, cXDestin, cEmRemet , cXAssunt, cHTML, .F. )

Return


/*/{Protheus.doc} EnvMailC - Rotina para o envio do email para o usuario
	@author Edilson Nascimento
	@since 29/11/2021
/*/
STATIC PROCEDURE EnvMailC(cEmDest,cXServer,cXConta,cEmRemet,cPasswrd,cHTML,cXAssunt,lJob)

	Local cUser := "", cPass := "", cSendSrv := ""
	Local cMsg := ""
	Local nSendPort := 0, nSendSec := 1, nTimeout := 0
	Local xRet
	Local oServer, oMessage


	cUser 	  := cXConta  //define the e-mail account username
	cPass 	  := cPasswrd //define the e-mail account password
	cSendSrv 	:= cXServer // define the send server
	cEmRemet	:= cEmRemet //define the e-mail remetente
	nTimeout 	:= 60 // define the timout to 60 seconds

	oServer := TMailManager():New()

	oServer:SetUseSSL( .F. )
	oServer:SetUseTLS( .F. )

	if nSendSec == 0
		nSendPort := 25
	elseif nSendSec == 1
		nSendPort := 465
		oServer:SetUseSSL( .T. )
	else
		nSendPort := 587
    oServer:SetUseSSL( .T. )
	endif

	xRet := oServer:Init( "", cSendSrv, cUser, cPass, , nSendPort )
	if xRet != 0
		cMsg := "Could not initialize SMTP server: " + oServer:GetErrorString( xRet )
		conout( cMsg )
		return
	endif

	xRet := oServer:SetSMTPTimeout( nTimeout )
	if xRet != 0
		cMsg := "Could not set " + cProtocol + " timeout to " + cValToChar( nTimeout )
		conout( cMsg )
		RETURN
	ENDIF

	xRet := oServer:SMTPConnect()
	if xRet <> 0
		cMsg := "Could not connect on SMTP server: " + oServer:GetErrorString( xRet )
		conout( cMsg )
		RETURN
	ENDIF

	xRet := oServer:SmtpAuth( cUser, cPass )
	if xRet <> 0
		cMsg := "Could not authenticate on SMTP server: " + oServer:GetErrorString( xRet )
		conout( cMsg )
		oServer:SMTPDisconnect()
		RETURN
	ENDIF

	oMessage := TMailMessage():New()
	oMessage:Clear()

	//oMessage:cDate := DTOC(Date()) //cValToChar( Date() )
	oMessage:cFrom := cEmRemet
	oMessage:cTo 	 := cEmDest
	oMessage:cSubject := cXAssunt
	oMessage:cBody := cHTML

	xRet := oMessage:Send( oServer )
	if xRet <> 0
		cMsg := "Could not send message: " + oServer:GetErrorString( xRet )
		conout( cMsg )
		RETURN
	ENDIF

	xRet := oServer:SMTPDisconnect()
	if xRet <> 0
		cMsg := "Could not disconnect from SMTP server: " + oServer:GetErrorString( xRet )
		conout( cMsg )
		RETURN
	ENDIF

return 


/*/{Protheus.doc} ShowCTE - Exibe os dados dos CTE importados
	@author Edilson Nascimento
	@since 3/12/2021
/*/
User Function ShowCTE()

	Local aArea       := GetArea()
	Local cTabela     := "Z22"

	Private aCores    := {}
	Private cCadastro := "Manutencao CTE"
	Private aRotina   := {}
	
	//Montando o Array aRotina, com funções que serão mostradas no menu
	aAdd(aRotina,{"Pesquisar",         "AxPesqui",     0, 1})
	aAdd(aRotina,{"Visualizar",        "AxVisual",     0, 2})
	// aAdd(aRotina,{"Incluir",          "AxInclui",     0, 3})
	aAdd(aRotina,{"Alterar",           "AxAltera",     0, 4})
	aAdd(aRotina,{"Excluir",           "AxDeleta",     0, 5})
	aAdd(aRotina,{"Legenda",           "U_LegendaCT",  0, 6})
  aAdd(aRotina,{"Gerar Doc Entrada", "U_GerPreNota", 0, 7})

	//Montando as cores da legenda
	aAdd(aCores,{"Z22_STATUS == 'C' ", "BR_AMARELO" })
  aAdd(aCores,{"Z22_STATUS == 'I' ", "BR_VERDE" })
	aAdd(aCores,{"Z22_STATUS == ' ' ", "BR_VERMELHO" })
	
	//Selecionando a tabela e ordenando
	DbSelectArea(cTabela)
	(cTabela)->(DbSetOrder(1))
	
	//Montando o Browse
	//mBrowse(6, 1, 22, 75, cArquivo, , , , , , aCores )
    mBrowse(6, 1, 22, 75, cTabela, , , , , , aCores )
	
	//Encerrando a rotina
	(cTabela)->(DbCloseArea())
	RestArea(aArea)

Return


/*/{Protheus.doc} GerPreNota - Rotina para a geracao da Pre-Nota
	@author Edilson Nascimento
	@since 13/12/2021
/*/
User Function GerPreNota()

local _aCabec := {}
local _aItens
local _aLInha
local _oXml
local _cError
local _cWarning
local _nPos
local _cPedido
local _cProduto
local _nQuant
local _nVlrUni
local _nVlrTot

local _aArea     := Z22->(GetArea())
local _lContinua := .T.
local _nFase     := 1

local _oDlg
local _cCTEIni   := Space( 9 )
local _cCTEFim   := Space( 9 )
local _cAlias
local _cQuery

private lMsErroAuto

    If Empty( Z22->Z22_STATUS )

        While _lContinua

            while _nFase == 1

                  @ 00,00 TO 160,370 DIALOG _oDlg TITLE OemToAnsi( "Parametros para geracao de pre-pedido." )
                  @ 05,05 TO 075,180 TITLE OemToAnsi( " Parametros " )

                  @ 20,018        SAY     "CTE Inicial:"
                  @ 20,085        GET     _cCTEIni                  ;
                                  PICTURE PesqPict("Z22","Z22_DOC") ;

                  @ 35,018        SAY     "CTE Final:"
                  @ 35,085        GET     _cCTEFim                  ;
                                  PICTURE PesqPict("Z22","Z22_DOC") ;

                  @ 55,110 BMPBUTTON TYPE 01 ACTION ( _nFase++, Close(_oDlg) )
                  @ 55,140 BMPBUTTON TYPE 02 ACTION ( _nFase--, _lContinua := .F., Close(_oDlg) )

                  ACTIVATE  DIALOG _oDlg CENTER

            enddo

            while _nFase == 2

                If Alltrim( _cCTEIni ) <= Alltrim( _cCTEFim )
                    _nFase++
                Else
                    msgAlert("Valores informados no parametros estao incorreto !","Atencao")
                    _nFase--
                EndIf

            enddo            

            while _nFase == 3

                _cAlias := GetNextAlias()

                _cQuery := " SELECT Z22.Z22_DOC, Z22.Z22_CHAVE, Z22.Z22_SERIE, Z22.Z22_DTEMIS, Z22.Z22_FORNEC, Z22.Z22_LOJAF,"              + Chr(13)+Chr(10)
                _cQuery += "        Z22.R_E_C_N_O_ RECNO"                                                                                   + Chr(13)+Chr(10)
                _cQuery += "   FROM " + RetSqlName("Z22") + " Z22 (NOLOCK) "								                                                + Chr(13)+Chr(10)
                _cQuery += "  WHERE Z22.D_E_L_E_T_ <> '*'"						                                                                      + Chr(13)+Chr(10)
                _cQuery += "        AND Z22.Z22_FILIAL = '" + xFilial("Z22") + "'"						                                              + Chr(13)+Chr(10)
                _cQuery += "        AND Z22.Z22_DOC >= '" + PAdL(_cCTEIni, 9 ) + "'"                                                        + Chr(13)+Chr(10)
                _cQuery += "        AND Z22.Z22_DOC <= '" + PAdL(_cCTEFim, 9 ) + "'"                                                        + Chr(13)+Chr(10)                
                _cQuery += "        AND Z22.Z22_STATUS = ' '"                                                                               + Chr(13)+Chr(10)
                _cQuery += "  ORDER BY Z22.Z22_FILIAL, Z22.Z22_DOC"                                                                         + Chr(13)+Chr(10)

                MsAguarde({|| dbUseArea(.T.,"TOPCONN", TCGENQRY(,,ChangeQuery(_cQuery)),(_cAlias),.T.,.T. )} , OemToAnsi("Aguarde...") , OemToAnsi("Selecionando registros...") )

                (_cAlias)->( dbGoTop() )
                If .not. (_cAlias)->( Eof() )

                    while .not. (_cAlias)->( Eof() )

                        begin sequence

                            Z22->( dbGoTo( (_cAlias)->RECNO ) )

                            aadd( _aCabec,{"F1_TIPO"   , "N",                   Nil, Nil})
                            aadd( _aCabec,{"F1_FORMUL" , "N",                   Nil, Nil})
                            aadd( _aCabec,{"F1_DOC"    , (_cAlias)->Z22_DOC,    Nil, Nil})
                            aadd( _aCabec,{"F1_CHVNFE" , (_cAlias)->Z22_CHAVE,  Nil, Nil})    
                            aadd( _aCabec,{"F1_SERIE"  , (_cAlias)->Z22_SERIE,  Nil, Nil})     
                            aadd( _aCabec,{"F1_EMISSAO", (_cAlias)->Z22_DTEMIS, Nil, Nil})
                            aadd( _aCabec,{"F1_FORNECE", (_cAlias)->Z22_FORNEC, Nil, Nil})
                            aadd( _aCabec,{"F1_LOJA"   , (_cAlias)->Z22_LOJAF,  Nil, Nil})
                            aadd( _aCabec,{"F1_ESPECIE", "CTR",                 Nil, Nil})

                            _aItens 	:= {}
                            _cError   := ''
                            _cWarning := ''

                            _cPedido	:= ''
                            _cProduto := ''
                            _nQuant   := 0
                            _nVlrUni  := 0
                            _nVlrTot  := 0

                            _oXml := XmlParser( Z22->Z22_XML, "_", @_cError, @_cWarning)

                            if Empty( _cError ) .and. Empty( _cWarning )

                                If ValType( _oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ) == "O"			//-- So existe UM produto na Nota Fiscal

                                    _cPedido  := Alltrim( Str(_nPos) )
                                    _cProduto := _oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_PROPRED:TEXT
                                    _nQuant   := Val(_oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ:_CUNID:TEXT)
                                    _nVlrUni  := Val(_oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ:_QCARGA:TEXT)
                                    _nVlrTot  := _nQuant * _nVlrUni

                                    _aLinha   := {}
                                    aadd( _aLinha,{"D1_COD"   , _cProduto , Nil, Nil})
                                    aadd( _aLinha,{"D1_QUANT" , _nQuant   , Nil, Nil})
                                    aadd( _aLinha,{"D1_VUNIT" , _nVlrUni  , Nil, Nil})
                                    aadd( _aLinha,{"D1_TOTAL" , _nVlrTot  , Nil, Nil})
                                    aadd( _aLinha,{"D1_PEDIDO", _cPedido  , Nil, Nil})
                                    aadd( _aLinha,{"D1_ITEMPC", "0001"    , Nil, Nil})
                                    aadd( _aItens,aLinha)

                                ElseIf ValType( _oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ) == "A"		//-- Ha MAIS de UM Item da Nota Fiscal
                                    For _nPos := 1 to Len(_oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ)

                                        _cItem	  := "[" + Alltrim( Str(_nPos) ) + "]"
                                        _cPedido  := Alltrim( Str(_nPos) )
                                        _cProduto := _oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ[ _nPos ]:_TPMED:TEXT
                                        _nQuant   := Val(_oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ[ _nPos ]:_CUNID:TEXT)
                                        _nVlrUni  := Val(_oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ[ _nPos ]:_QCARGA:TEXT)
                                        _nVlrTot  := _nQuant * _nVlrUni

                                        _aLinha 	:= {}
                                        aadd( _aLinha,{"D1_COD"   , _cProduto,           Nil, Nil})
                                        aadd( _aLinha,{"D1_QUANT" , _nQuant,             Nil, Nil})
                                        aadd( _aLinha,{"D1_VUNIT" , _nVlrUni,            Nil, Nil})
                                        aadd( _aLinha,{"D1_TOTAL" , _nVlrTot,            Nil, Nil})
                                        aadd( _aLinha,{"D1_PEDIDO", _cPedido,            Nil, Nil})
                                        aadd( _aLinha,{"D1_ITEMPC", StrZero( _nPos, 4 ), Nil, Nil})
                                        aadd( _aItens, _aLinha)

                                    Next
                                EndIf

                                    lMsErroAuto := .F.

                                    //-- Definicao para entrada por pre-nota.
                                    MsgRun("Aguarde gerando Pré-Nota de Entrada...",,{|| MSExecAuto ( {|x,y,z| MATA140(x,y,z) }, _aCabec, _aItens, 3)})                             

                                    If lMsErroAuto
                                        MostraErro()
                                    Else
                                        RecLock("Z22",.F.)
                                            Z22->Z22_STATUS  := 'I'
                                        Z22->(MsUnlock())
                                    Endif

                            Else
                                msgAlert("Nao foram encontrados itens a CTE!","Atencao")
                            EndIf

                        end sequence

                        (_cAlias)->(dbSkip())

                    EndDo

                Else
                    msgAlert("Nao foram encontrados registros a serem processados !","Atencao")
                EndIf

                (_cAlias)->(dbCloseArea())

                _nFase := 1                

            enddo

        enddo

    Else
        msgAlert("Documento ja gerado!","Atencao")
    Endif

    Z22->(RestArea(_aArea))

Return


User Function LegendaCT()

cCadastro := "Manutencao CTE"

aCores2 := {  { "BR_VERDE"    , "Pre-nota gerada" },;
              { "BR_VERMELHO" , "CTE Importado" },;
              { "BR_AMARELO"  , "CTE Cancelada" } }

BrwLegenda(cCadastro,"Legenda do Browse",aCores2)

Return
