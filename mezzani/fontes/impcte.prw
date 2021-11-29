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



    // PREPARE ENVIRONMENT EMPRESA "02" FILIAL "01" USER "admin" PASSWORD "2Latin3" TABLES "SA1", "SA2", "SA4", "ZZ2", "Z30", "Z31", "Z32" MODULO "FAT"
    PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" USER "admin" PASSWORD "2018@0521" TABLES "SA1", "SA2", "SA4", "ZZ2", "Z30", "Z31", "Z32" MODULO "FAT"

    // Diretorio com os arquivos XML a processar
    _cDirIn := SuperGetMV( "MV_CTE_IN",, "\xmlcte\in\")
    _cDirOu := SuperGetMV( "MV_CTE_OU",, "\xmlcte\ou\")
    _cDirEr := SuperGetMV( "MV_CTE_ER",, "\xmlcte\er\")


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

                        // Transportadoras
                        if  .not. XmlChildEx( _oXml:_CTEPROC:_CTE:_INFCTE, "_EMIT") == Nil .OR. ;
                            .not. XmlChildEx( _oXml:_CTEPROC:_CTE:_INFCTE:_EMIT, "_ENDEREMIT")  == Nil

                            // Remetente
                            if  .not. XmlChildEx( _oXml:_CTEPROC:_CTE:_INFCTE, "_REM") == Nil .OR. ;
                                .not. XmlChildEx( _oXml:_CTEPROC:_CTE:_INFCTE:_REM, "_ENDERREME")  == Nil 

                                // Cliente
                                if  .not. XmlChildEx( _oXml:_CTEPROC:_CTE:_INFCTE, "_DEST") == Nil .AND. ;
                                    .not. XmlChildEx( _oXml:_CTEPROC:_CTE:_INFCTE:_DEST, "_ENDERDEST")  == Nil .AND. ;
                                    .not. XmlChildEx( _oXml:_CTEPROC:_CTE:_INFCTE:_DEST, '_CNPJ' ) == Nil

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
                                                              Z22->Z22_STATUS  := 'I'
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

                                                        _cQuery := ChangeQuery( _cQuery )

                                                        TCQUERY _cQuery Alias (_cArqQRY) New

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
                                    FClose( _nHandle )
                                    If __CopyFile( _cDirIn + _aArquivos[ _nPos ], _cDirOu + _aArquivos[ _nPos ] )
                                      FErase( _cDirIn + _aArquivos[ _nPos ] )
                                    Endif

                                Endif

                            Endif


                        EndIf


                    EndIf

                Else
                    //
                    // Caso Erro ao processar o arquivo XML, move para a pasta de erros
                    //
                    FClose( _nHandle )
                    If __CopyFile( _cDirIn + _aArquivos[ _nPos ], _cDirEr + _aArquivos[ _nPos ] )
                      FErase( _cDirIn + _aArquivos[ _nPos ] )
                    Endif
                EndIf

                FClose( _nHandle )

            Else

              //
              // Caso tenha ocorrido algum erro na abertura do arquivo move para a pasta de erros
              //
              If __CopyFile( _cDirIn + _aArquivos[ _nPos ], _cDirEr + _aArquivos[ _nPos ] )
                FErase( _cDirIn + _aArquivos[ _nPos ] )
              Endif

            EndIf

        next


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
    
        _cQuery := ChangeQuery( _cQuery )

        TCQUERY _cQuery Alias (_cArqQRY) New

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




User Function ShowCTE()		// 

	//-- Declaracao de Variaveis - mBrowse.
	Private aRotina 	:= MenuDef()				// Padronizacao para visualizacao no menu padrao.
	Private cCadastro 	:= OemToAnsi("Monitor para integração CTE")		// Padrao para o mBrowse
	Private cDelFunc 	:= ".T." 					// Validacao para a exclusao. Pode-se utilizar ExecBlock
	Private lSeeAll		:= .T.						// Define se o browse mostrara todas (.T.) as filiais.
	Private lChgAll		:= .T.						// Define se os registros de outras filiais poderao ser alterados (.T.).
	Private nInterval	:= 999						// Quantidade de tempo passada para a funcao Timer.
	Private cString 	:= "ZZ2"


	//-- Abre a Tabela e posiciona no primeiro registro.
	dbSelectArea(cString)
	(cString)->(dbSetOrder(1))
	(cString)->(dbGoTop())

	//-- Interface com o usuario.
	mBrowse( ,,,,cString,,,,,, /*aCores*/,,,,,,lSeeAll,lChgAll,,nInterval,,)

Return()
