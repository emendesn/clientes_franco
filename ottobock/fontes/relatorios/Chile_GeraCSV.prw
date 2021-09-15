///////////////////////////////////////////////////////////////
// GERACSV.PRW                                    01/10/2009 //
//															 //
// DES.: OUT/2009  POR: MARIO AZEVEDO JUNIOR                 //
// ALT.:        4  POR:                     				 //
//															 //
// FUN.: GERAR ARQUIVO DE CLIENTES E MOVIMENTAǕES MENSAIS   //
//       PARA ENVIO  JANINE DARMER - ALEMANHA               //
///////////////////////////////////////////////////////////////
#include "rwmake.ch"        
#include "topconn.ch"

User Function c_GeraCSV()
	_cHeader	:= Space(150)	
	_cMonth     := Space(002)
	_cYear      := "2017"
	_cDetail	:= Space(100)
	_cLocal     := Space(050)
    _cLocal1    := Space(050)
    _cLocal2    := Space(050)       
    _cSql       := ""
	_cPais    	:= Space(003)
    
	@ 00,00 TO 300,370 DIALOG oDlgX TITLE OemToAnsi( "Gera磯 dos arquivos com TurnOver(CSV)." )
	@ 05,05 TO 110,180 TITLE OemToAnsi( " Parametros " )

	@ 20,018 SAY "M고a ser processado: "
	@ 35,018 SAY "Ano a ser processado: "
	@ 50,018 SAY "Local do Arquivo    : "
	@ 70,018 SAY "Unidad de medida del pa�: "

	@ 20,085 GET _cMonth   PICTURE "@99"	VALID fMonth()
	@ 35,085 GET _cYear	   PICTURE "@9999"	VALID fYear()
	@ 50,085 GET _cLocal   PICTURE "@!" 	VALID fCampo()
	@ 70,085 GET _cPais    PICTURE "@!" 	VALID fPais( cPais )

	@ 090,020 SAY OemToAnsi( PadL( "Esta Rotina tem como objetivo gerar um Arquivo CSV", 53 ) )
    @ 097,020 SAY OemToAnsi( PadL( "para envio de informa絥s com o Turnover mensal.", 53 ) )

	@ 120,110 BMPBUTTON TYPE 01 ACTION OkProc()
	@ 120,140 BMPBUTTON TYPE 02 ACTION Close(oDlgX)

	ACTIVATE  DIALOG oDlgX CENTER

Return(.T.)                                                        

//////////////////////////////////////////////////////////////
// Fun磯 fCampo()                                          //
//////////////////////////////////////////////////////////////                                                          
Static Function fCampo()

	_cLocal := "C:\TURNOVER\"                                              

Return(.T.)    

        
//////////////////////////////////////////////////////////////
// Fun磯 fMonth()                                          //
// Valida o mes digitado pelo usuᲩo						//
//////////////////////////////////////////////////////////////                                                          
Static Function fMonth()

local _lRetValue := .T.

	If val(_cMonth) < 1 .or. val(_cMonth) > 12		
		msgAlert( OemToAnsi( "Digite o m고com valores entre 1 e 12." ), OemToAnsi( "Geracao de CSV" ) )
		_lRetValue := .F.
	EndIf  

Return( _lRetValue )


//////////////////////////////////////////////////////////////
// Fun磯 fPais()                                           //
// Valida o mes digitado pelo usuᲩo						//
//////////////////////////////////////////////////////////////
STATIC FUNCTION fPais( _cPas )

local _lRetValue := .T.
local _cQuery

		_cQuery := "SELECT ZAA.ZAA_PASEXT"								+ Chr(13)+Chr(10)
		_cQuery += "  FROM " + RetSqlName("ZAA") + " ZAA "				+ Chr(13)+Chr(10)
		_cQuery += " WHERE ZAA.ZAA_PASEXT = '" + _cPas + "' AND "		+ Chr(13)+Chr(10)
		_cQuery += "       ZAA.D_E_L_E_T_ <> '*'"					 	+ Chr(13)+Chr(10)

		_cQuery := ChangeQuery(_cQuery)

		TCQUERY _cQuery Alias _TMP_PAIS New

		If _TMP_PAIS->( Eof() )
			MsgBox( OemToAnsi( "País no registrado !" ), OemToAnsi( "Generación CSV" ) )
			_lRetValue := .F.
		Endif

		_TMP_PAIS->( dbCloseArea() )

Return( _lRetValue )


/////////////////////////////////////////////////////////////
// Fun磯 fYear()                                          //
// Valida o Ano digitado pelo usuario                      //
/////////////////////////////////////////////////////////////
Static Function fYear()
	
	If val(_cYear) < 2009
		msgAlert(OemToAnsi("O ano inicial para processamento no SIGA 頲005"), OemToAnsi( "Geracao de CSV" ) )
	   Return(.F.)
	EndIf

	_cLocal := "C:\TURNOVER\" + SPACE(47)                                               

Return(.T.)


//////////////////////////////////////////////////////////////////////
// Fun磯 OkProc()                                                  //
// Cria o arquivo txt e inicializa a barra de progress㯮           //
//////////////////////////////////////////////////////////////////////
Static Function OkProc()      
                              

	Processa({||RunProc()},"Processando dados para Alemanha.")
	
	Close(oDlgX)       

	
Return(.T.)
////////////////////////////////// FIM ///////////////////////////////


//////////////////////////////////////////////////////////////////////
// Fun磯 RunProc()                                                 //
// Monta o Arquivo CSV.                                             //
//////////////////////////////////////////////////////////////////////
STATIC PROCEDURE RunProc()

local _fFile1
local cLine

// Cria e abre o arquivo texto.
	_cMonth  := strzero(val(_cMonth),2)
	_cLocal1 := ALLTRIM(_cLocal) + "90265_CUST_" + _cMonth + "_" + strzero(val(substr(_cYear,3,2)),2)+ ".csv"

	If ( _fFile1 := FCreate(_cLocal1) ) > 0

		// Grava Cabe硬ho do Arquivo
		cLine := "KUNNR;Land1;Name1;Stras;PSTLZ;Ort01;Regio"
		Fwrite(_fFile1, cLine + CHR(13) + CHR(10))             

		// Montagem do Arquivo 90014_CUST_MM_YY.CSV

		_cSql:= "SELECT distinct(D2_CLIENTE), A1_NOME, A1_END, A1_CEP, A1_MUN, A1_EST "
		_cSql+= "FROM SD2010 INNER JOIN SA1010 ON A1_COD=D2_CLIENTE "
		_cSql+= "WHERE D2_TES IN (SELECT F4_CODIGO FROM SF4010  WHERE F4_TIPO = 'S' AND F4_DUPLIC = 'S') AND (D2_EMISSAO >='" + _cYear + _cMonth + "01' AND "
		_cSql+= "D2_EMISSAO <='" + _cYear + _cMonth + "31') AND SD2010.D_E_L_E_T_ <> '*' "
		_cSql+= "ORDER BY D2_CLIENTE"

		// TCQUERY _cSql //NEW VIA "TOPCONN"
		cArqTrb := "TRBARQ1"
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,_cSql),cArqTrb)

		TRBARQ1->( dbGoTop() )
		
		While ! TRBARQ1->( eof() )
		
			cLine := alltrim(D2_CLIENTE) + ";"
			cLine += "CH;"
			cLine += alltrim(A1_NOME) + ";"
			cLine += alltrim(A1_END) + ";"
			cLine += alltrim(A1_CEP) + ";"
			cLine += alltrim(A1_MUN) + ";"
			cLine += alltrim(A1_EST)

			FWrite(_fFile1, cLine + CHR(13) + CHR(10) )	

			TRBARQ1->( dbSkip() )

		End
		
		TRBARQ1->( dbCloseArea() )

		FClose(_fFile1)			//Fecha o arquivo texto


	// Cria e abre o arquivo texto.
		_cLocal2 := ALLTRIM(_cLocal) + "90265_TRANS_" + _cMonth + "_" + strzero(val(substr(_cYear,3,2)),2)+ ".csv"
		_fFile  := FCreate(_cLocal2)               
									
				//Grava cabe硬ho do arquivo
		cLine := "VW;Kunde;Material;Bezeichnung;WG;Fakturadat;Nettoabsatz;Nettowert;Netto VW;currency"
		fWrite(_fFile, cLine+ CHR(13) + CHR(10) ) 
		
		_cSql:= "SELECT CSV.CODCLI, MAX(CSV.DATA) AS DATA, CSV.OBSAP, MAX(CSV.DESCR) AS DESCR, MAX(CSV.GRUP) AS GRUP, "	+ Chr(13)+Chr(10)
		_cSql+= "       SUM(CSV.QTDEVDS)-SUM(CSV.QTDEDEV) AS QTDE, "													+ Chr(13)+Chr(10)
		_cSql+= "       SUM(CSV.TOTALVDS)-SUM(CSV.TOTALDEV) AS TOTAL, "													+ Chr(13)+Chr(10)
		_cSql+= "       SUM(CSV.CUSTOVDS)-SUM(CSV.CUSTODEV) AS CUSTO, "													+ Chr(13)+Chr(10)
		_cSql+= "       ZAA.ZAA_UMEXT AS UNIDADE " 																		+ Chr(13)+Chr(10)		
		_cSql+= "  FROM bockViewCsv CSV	"																				+ Chr(13)+Chr(10)
		_cSql+= " INNER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_COD = CSV.OBSAP and SB1.D_E_L_E_T_ <> '*'"			+ Chr(13)+Chr(10)
		_cSql+= "  LEFT JOIN " + RetSqlName("ZAA") + " ZAA ON ZAA.ZAA_UMINT = SB1.B1_UM and ZAA.ZAA_PASEXT = '" + _cPais + "' AND ZAA.D_E_L_E_T_ <> '*' " + Chr(13)+Chr(10)		
		_cSql+= " WHERE (CSV.DATA >='" + _cYear + _cMonth + "01' AND "													 + Chr(13)+Chr(10)
		_cSql+= "        CSV.DATA <='" + _cYear + _cMonth + "31') "														+ Chr(13)+Chr(10)
		_cSql+= " GROUP BY CSV.CODCLI, CSV.OBSAP, ZAA.ZAA_UMEXT "														+ Chr(13)+Chr(10)
		_cSql+= " ORDER BY CSV.CODCLI, CSV.OBSAP"																		+ Chr(13)+Chr(10)

	//	TCQUERY _cSql

		cArqTrb := "TRBARQ1"
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,_cSql),cArqTrb)
		
		TRBARQ1->( dbGoTop() )
		
		While ! TRBARQ1->( eof() )
					
			cLine := "V04;"                                 	// Tiago Dias 12/11/19
			cLine += alltrim(CODCLI) + ";"
			cLine += alltrim(OBSAP) + ";"
			cLine += alltrim(DESCR) + ";"
			cLine += alltrim(GRUP) + ";"
			cLine += "01/" + _cMonth + "/" + _cYear + ";"
			cLine += Transform(QTDE, "@E 999999999.999") + ";"                 
			cLine += Transform(TOTAL, "@E 999999999.99") + ";"
			cLine += Transform(CUSTO, "@E 999999999.99") + ";"
			cLine += "CHP" + ";"
			cLine += Transform(UNIDADE, "@")

			fWrite(_fFile, cLine + CHR(13) + CHR(10) )

			TRBARQ1->( dbSkip() )
		
		End
		
		TRBARQ1->( dbCloseArea() )

		FClose(_fFile)		//Fecha o arquivo texto

		MsgBox( OemToAnsi( "Arquivo criado com sucesso !" ), OemToAnsi( "Gera磯 de CSV" ) ,"INFO")

	Else
		msgAlert( OemToAnsi( "No se pudo crear el archivo: " + AllTrim( _cLocal2 ) ), OemToAnsi( "Geracao de CSV" ) )
	EndIf

Return
