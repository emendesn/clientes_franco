///////////////////////////////////////////////////////////////
// GERACSV.PRW                                    07/11/2005 //
//															 //
// DES.: NOV/2005  POR: MARIO AZEVEDO JUNIOR                 //
// ALT.:        4  POR:                     				 //
//															 //
// FUN.: GERAR ARQUIVO DE CLIENTES E MOVIMENTAǕES MENSAIS   //
//       PARA ENVIO  JANINE DARMER - ALEMANHA               //
///////////////////////////////////////////////////////////////
#include "rwmake.ch"        
#include "topconn.ch"

User Function u_GeraCSV()
	_cHeader	:= Space(150)	
	_cMonth     := Space(002)
	_cYear      := "2017"
	_cDetail	:= Space(100)
	_cLocal     := Space(050)
    _cLocal1    := Space(050)
    _cLocal2    := Space(050)
	_cPais    	:= Space(003)       

	@ 00,00 TO 300,370 DIALOG oDlgX TITLE OemToAnsi( "Geracao dos arquivos com TurnOver(CSV)." )
	@ 05,05 TO 110,180 TITLE OemToAnsi( " Parametros " )

	@ 20,018 SAY "M고a ser processado: "
	@ 35,018 SAY "Ano a ser processado: "
	@ 50,018 SAY "Local do Arquivo    : "
	@ 70,018 SAY "Pais Unidade Medida : "

	@ 20,085 GET _cMonth   PICTURE "@99"	VALID fMonth()
	@ 35,085 GET _cYear	   PICTURE "@9999"	VALID fYear()
	@ 50,085 GET _cLocal   PICTURE "@!" 	VALID fCampo()
	@ 70,085 GET _cPais    PICTURE "@!" 	VALID fPais( _cPais )

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

	_cLocal := "C:\TURNOVER\                                               
	
Return(.T.)    


//////////////////////////////////////////////////////////////
// Fun磯 fMonth()                                          //
// Valida o mes digitado pelo usuᲩo						//
//////////////////////////////////////////////////////////////                                                          
Static Function fMonth()

local _lRetValue := .T.

	If val(_cMonth) < 1 .or. val(_cMonth) > 12
		msgAlert( OemToAnsi( "Digite o mes com valores entre 1 e 12." ), OemToAnsi( "Geracao de CSV" ) )
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
			MsgBox( OemToAnsi( "Pais nao cadastrado !" ), OemToAnsi( "Geracao de CSV" ),"INFO" )
			_lRetValue := .F.
		Endif

		_TMP_PAIS->( dbCloseArea() )

Return( _lRetValue )


/////////////////////////////////////////////////////////////
// Fun磯 fYear()                                          //
// Valida o Ano digitado pelo usuario                      //
/////////////////////////////////////////////////////////////
Static Function fYear()
	
	If val(_cYear) < 2005
		msgAlert( OemToAnsi( "O ano inicial para processamento no SIGA 頲005"), OemToAnsi( "Geracao de CSV" ) )
		Return(.F.)
	EndIf

	_cLocal := "C:\" + SPACE(47)                                               

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
local csql
local _csql


// Cria e abre o arquivo texto.
	_cMonth  := strzero(val(_cMonth),2)
	_cLocal1 := ALLTRIM(_cLocal) + "90367_CUST_" + _cMonth + "_" + strzero(val(substr(_cYear,3,2)),2)+ ".csv"


	If ( _fFile1 := FCreate(_cLocal1) ) > 0
	
			// Grava Cabe硬ho do Arquivo
		cLine := "KUNNR;Land1;Name1;Stras;PSTLZ;Ort01;Regio"
		Fwrite(_fFile1, cLine + CHR(13) + CHR(10))             


	// Montagem do Arquivo 90014_CUST_MM_YY.CSV

		cSql:= "SELECT distinct(D2_CLIENTE), A1_NOME, A1_END, A1_CEP, A1_MUN, A1_EST "
		cSql+= "FROM SD2010 INNER JOIN SA1010 ON A1_COD=D2_CLIENTE "
		cSql+= "WHERE D2_TES IN (SELECT F4_CODIGO FROM SF4010  WHERE F4_TIPO = 'S' AND F4_DUPLIC = 'S') AND (D2_EMISSAO >='" + _cYear + _cMonth + "01' AND "
		cSql+= "D2_EMISSAO <='" + _cYear + _cMonth + "31') AND SD2010.D_E_L_E_T_ <> '*' "
		cSql+= "ORDER BY D2_CLIENTE"

		//TCQUERY cSql //NEW VIA "TOPCONN"
		//  dbUseArea(.T.,"TOPCONN", TCGenQry(,,cSql),"CUS") 
		//  dbSelectArea("CUS")

		cArqTrb := "TRBARQ1"
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cSql),cArqTrb)
		
		TRBARQ1->( dbGoTop() )
		
		While ! TRBARQ1->( eof() )
		
			cLine := alltrim(D2_CLIENTE) + ";"
			cLine += "UR;"
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
		_cLocal2 := ALLTRIM(_cLocal) + "90367_TRANS_" + _cMonth + "_" + strzero(val(substr(_cYear,3,2)),2)+ ".csv"
		_fFile  := FCreate(_cLocal2)
		
		//Grava cabe硬ho do arquivo
		cLine := "VW;Kunde;Material;Bezeichnung;WG;Fakturadat;Nettoabsatz;Nettowert;Netto VW;currency"
		fWrite(_fFile, cLine+ CHR(13) + CHR(10) ) 
						
		
	//	csql:= "SELECT CODCLI, MAX(DATA) AS DATA, OBSAP, MAX(DESCR) AS DESCR, MAX(GRUP) AS GRUP, "
	//	csql+= "SUM(QTDEVDS)-SUM(QTDEDEV) AS QTDE, "
	//	csql+= "SUM(TOTALVDS)-SUM(TOTALDEV) AS TOTAL, "
	//	csql+= "SUM(CUSTOVDS)-SUM(CUSTODEV) AS CUSTO "
	//	csql+= "FROM bockViewCsv "
	//	csql+= "WHERE (DATA >='" + _cYear + _cMonth + "01' AND "
	//    csql+= "DATA <='" + _cYear + _cMonth + "31') "
	//	csql+= "GROUP BY CODCLI, OBSAP ORDER BY CODCLI, OBSAP"
		//TCQUERY csql
		_cSql:= "SELECT CSV.[CODIGO CLIENTE] AS CODCLI, MAX(CSV.[FECHA REDUZIDA]) AS DATA, CSV.[REFERENCIA SAP] AS OBSAP, MAX(CSV.DESCRIPCION) AS DESCR, MAX(CSV.[GRUPO DEL PRODUCTO]) AS GRUP, " + Chr(13)+Chr(10)
		_cSql+= "       SUM(CSV.[CTD VENDIDA]) AS QTDE, " 														+ Chr(13)+Chr(10)
		_cSql+= "       SUM(CSV.[VALOR BRUTO]) AS TOTAL, " 														+ Chr(13)+Chr(10)
		_cSql+= "       SUM(CSV.[COSTO TOTAL]) AS CUSTO, " 														+ Chr(13)+Chr(10)
		_csql+= "        ZAA.ZAA_UMEXT AS UNIDADE " 															+ Chr(13)+Chr(10)
		_cSql+= "  FROM bockSalesDataManagement CSV " 															+ Chr(13)+Chr(10)
		_csql+= " INNER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_COD = CSV.OBSAP and SB1.D_E_L_E_T_ <> '*'"	+ Chr(13)+Chr(10)
		_csql+= "  LEFT JOIN " + RetSqlName("ZAA") + " ZAA ON ZAA.ZAA_UMINT = SB1.B1_UM and ZAA.ZAA_PASEXT = '" + _cPais + "' AND ZAA.D_E_L_E_T_ <> '*' " + Chr(13)+Chr(10)
		_cSql+= " WHERE (CSV.[FECHA REDUZIDA] >='" + _cYear + _cMonth + "01' AND " 								+ Chr(13)+Chr(10)
		_cSql+= "       CSV.[FECHA REDUZIDA] <='" + _cYear + _cMonth + "31') " 									+ Chr(13)+Chr(10)
		_cSql+= " GROUP BY CSV.[CODIGO CLIENTE], CSV.[REFERENCIA SAP], ZAA.ZAA_UMEXT" 							+ Chr(13)+Chr(10)
		_cSql+= " ORDER BY CSV.[CODIGO CLIENTE], CSV.[REFERENCIA SAP]" 											+ Chr(13)+Chr(10)
		
		//dbUseArea(.T.,"TOPCONN", TCGenQry(,,cSql),"TRN")

		cArqTrb := "TRBARQ1"
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,_cSql),cArqTrb)	  
		
	//	dbSelectArea("TRN")
		TRBARQ1->( dbGoTop() )
		
		While ! TRBARQ1->( Eof() )
					
			cLine := "V01;"
			cLine += alltrim(CODCLI) + ";"
			cLine += alltrim(OBSAP) + ";"
			cLine += alltrim(DESCR) + ";"
			cLine += alltrim(GRUP) + ";"
			cLine += "01/" + _cMonth + "/" + _cYear + ";"
			cLine += Transform(QTDE, "@E 999999999.999") + ";"                 
			cLine += Transform(TOTAL, "@E 999999999.99") + ";"
			cLine += Transform(CUSTO, "@E 999999999.99") + ";"
			cLine += "URU" + ";"
			cLine += Transform(UNIDADE, "@")
			
			fWrite(_fFile, cLine + CHR(13) + CHR(10) )

			TRBARQ1->( dbSkip() )
		
		End

		TRBARQ1->( dbCloseArea() )

		FClose(_fFile)		//Fecha o arquivo texto

		MsgBox( OemToAnsi( "Archivo creado con éxito !" ), OemToAnsi( "Gera磯 de CSV") ,"INFO")

	Else
		MsgBox("Nao foi possivel criar o arquivo: " + AllTrim( _cLocal2 ), "Geracaoo de CSV", "ALERT")
	Endif

Return(.T.)
