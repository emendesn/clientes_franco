#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

#define Confirma 1
#define Redigita 2
#define Abandona 3
                                        
User Function zzGeraCsv()
	Private _cTitulo := ""
	Private _cText1  := ""
	Private _cText2  := ""
	Private cPerg    := "ZZGCSV"

	If !Pergunte(cPerg,.f.)
		ValidPerg(cPerg)
	EndIf
	
	_cTitulo:= OemToAnsi("Gera磯 do Arquivo Transaction")
	_cText1 := OemToAnsi("Esta rotina tem como objetivo Gerar o Transaction File")
	_cText2 := OemToAnsi("para envio de informa絥s com Turnover Mensal.")

	While .T.
		DEFINE MSDIALOG oDlg TITLE _cTitulo FROM  150,100 TO 400,600 PIXEL OF oMainWnd
		@ 10, 10 TO 95, 240 LABEL ""    OF oDlg PIXEL
		@ 30, 20 SAY _cText1 SIZE 200, 8 OF oDlg PIXEL
		@ 40, 20 SAY _cText2 SIZE 200, 8 OF oDlg PIXEL

		DEFINE SBUTTON FROM 105, 150 TYPE 5 ACTION Pergunte(cPerg)      ENABLE OF oDlg
		DEFINE SBUTTON FROM 105, 180 TYPE 1 ACTION (nOpc:=1,oDlg:End()) ENABLE OF oDlg
		DEFINE SBUTTON FROM 105, 210 TYPE 2 ACTION (nOpc:=3,oDlg:End()) ENABLE OF oDlg
		ACTIVATE MSDIALOG oDlg
	
		If nOpc == 1
			RptStatus({||zzOkProc()},"Processando Gera磯 de Arquivo...")
		EndIf
	
		Exit
	End
	
Return
                


STATIC PROCEDURE zzOkProc() 

	Local cAlias:= GetNextAlias() 
	Local cAlia2:= GetNextAlias()
	Local _cMes	:= mv_par01 
	Local _cAno	:= mv_par02
	Local _cDir	:= mv_par03
	Local _cPais:= mv_par04
	Local _cArq	:= ""
	Local _cCod := GetMv("ZZ_TRANSAC")
	Local _lGera:= .T. 	
	Local _cLin := ""
	Local _cSql := ""

	_cMes := strzero(_cMes, 2)
	_cAno := strzero(_cAno, 4)
	
	_cArq := AllTrim(_cDir)+AllTrim(_cCod)+"_CUST_"+_cMes+"_"+_cAno+".csv" 
	_cArq := FCreate(_cArq)
		
	_cLin := "KUNNR;Land1;Name1;Stras;PSTLZ;Ort01;Regio"
	
	Fwrite(_cArq, _cLin + CHR(13) + CHR(10))             
	     
		if(Select(cAlias) > 0)
			(cAlias)->(DBCloseArea())
		endIf
		
		_cSql := " SELECT "
		_cSql += "		distinct(D2_CLIENTE) AS CLIENTE, A1_NOME, A1_END, A1_CEP, A1_MUN, A1_EST "
		_cSql += " FROM "
		_cSql += " 		"+RetSQLName("SD2")+" INNER JOIN "+RetSQLName("SA1")+" ON A1_COD = D2_CLIENTE AND A1_LOJA = D2_LOJA "
		_cSql += " WHERE "
		_cSql += " 		D2_TES IN (SELECT F4_CODIGO FROM "+RetSQLName("SF4")+" WHERE F4_FILIAL = '"+ xFilial("SF4") + "' AND F4_TIPO = 'S' AND F4_DUPLIC = 'S' AND F4_ZZTRANS = 'S') AND "    
		_cSql += " 		D2_EMISSAO LIKE '"+_cAno+_cMes+"%' AND SD2010.D_E_L_E_T_ <> '*' "
		_cSql += " ORDER BY "	
		_cSql += "	D2_CLIENTE"	                       
  
	  	TCQUERY _cSql NEW ALIAS &cAlias
		
		ProcRegua((cAlias)->(RecCount()))                                          	

		(cAlias)->(dbGotop())
		
		if (cAlias)->(Eof())
			msgAlert("Registro n㯠encontrado para Gerar " + _cDir + "!!!","Aten磯")
			_lGera := .F.
		else
		
			While !(cAlias)->(Eof())
				IncProc()
				_cLin := alltrim((cAlias)->CLIENTE) + ";"
				_cLin += "BR;"
				_cLin += ALLTRIM((cAlias)->A1_NOME) + ";"
				_cLin += ALLTRIM((cAlias)->A1_END) + ";"
				_cLin += ALLTRIM((cAlias)->A1_CEP) + ";"
				_cLin += ALLTRIM((cAlias)->A1_MUN) + ";"
				_cLin += ALLTRIM((cAlias)->A1_EST)
								
				FWrite(_cArq, _cLin + CHR(13) + CHR(10) )	
				
				(cAlias)->(dbskip())		
			End			         
		Endif
		
		(cAlias)->(dbCloseArea())          
		
	FClose(_cArq)		  

	
	_cArq := AllTrim(_cDir)+AllTrim(_cCod)+"_TRANS_"+_cMes+"_"+_cAno+".csv" 
	_cArq := FCreate(_cArq)
		
	_cLin := "VW;Kunde;Material;Bezeichnung;WG;Fakturadat;Nettoabsatz;Nettowert;Netto VW;currency"

	Fwrite(_cArq, _cLin + CHR(13) + CHR(10))             
	
		if(Select(cAlia2) > 0)
			(cAlia2)->(DBCloseArea())
		endIf
		
		_cSql := " SELECT "
		_cSql += "		CSV.CODCLI, MAX(CSV.DATA) AS DATA, CSV.OBSAP, MAX(CSV.DESCR) AS DESCR, MAX(CSV.GRUP) AS GRUP, "
		_cSql += "		SUM(CSV.QTDEVDS)-SUM(CSV.QTDEDEV) AS QTDE, SUM(CSV.TOTALVDS)-SUM(CSV.TOTALDEV) AS TOTAL,  "
		_cSql += "		SUM(CSV.CUSTOVDS)-SUM(CSV.CUSTODEV) AS CUSTO, "	
		_cSql += "      ZAA.ZAA_UMEXT AS UNIDADE "
		_cSql += " FROM "
		_cSql += " 		bockViewCsv CSV"
		_cSql += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_COD = CSV.OBSAP and SB1.D_E_L_E_T_ <> '*'"			
		_cSql += "  LEFT JOIN " + RetSqlName("ZAA") + " ZAA ON ZAA.ZAA_UMINT = SB1.B1_UM and ZAA.ZAA_PASEXT = '" + _cPais + "' AND ZAA.D_E_L_E_T_ <> '*' "
		_cSql += " WHERE "
		_cSql += " 		CSV.DATA LIKE '"+_cAno+_cMes+"%'"    
		_cSql += " GROUP BY "	
		_cSql += "		CSV.CODCLI, CSV.OBSAP, ZAA.ZAA_UMEXT"
		_cSql += " ORDER BY "	
		_cSql += "		CSV.CODCLI, CSV.OBSAP"
	
		TCQUERY _cSql NEW ALIAS &cAlia2
		
		ProcRegua((cAlia2)->(RecCount()))                                          	

		(cAlia2)->(dbGotop())
	
		if (cAlia2)->(Eof())
			msgAlert("Registro n㯠encontrado para Gerar " + _cDir + "!!!","Aten磯")       
			_lGera := .F.
		else
		
			While !(cAlia2)->(Eof())
				IncProc()
				
				_cLin := iif(Posicione("SA1",1, xFilial("SA1")+AllTrim((cAlia2)->CODCLI),"A1_ZZTRANS")= "S","V03;","V01;")    
				_cLin += AllTrim((cAlia2)->CODCLI) + ";"
				_cLin += AllTrim((cAlia2)->OBSAP) + ";"
				_cLin += alltrim((cAlia2)->DESCR) + ";"
				_cLin += alltrim((cAlia2)->GRUP) + ";"
				_cLin += "01/"+_cMes+"/"+_cAno+";"
				_cLin += AllTrim(Transform((cAlia2)->QTDE, "@E 999999999.999")) + ";"
				_cLin += Alltrim(Transform((cAlia2)->TOTAL, "@E 999999999.999")) + ";"
				_cLin += AllTrim(Transform((cAlia2)->CUSTO, "@E 999999999.999")) + ";"
				_cLin += "BRL" + ";"                                
				_cLin += Transform(UNIDADE, "@")
								
				FWrite(_cArq, _cLin + CHR(13) + CHR(10) )	
							
				(cAlia2)->(dbskip())		
			End			         
		Endif
		
		(cAlia2)->(dbCloseArea())          
		
	FClose(_cArq)
                         
	if _lGera
		MsgAlert("Arquivos Gerados com Sucesso!!","Alerta")
	endif
Return


STATIC PROCEDURE ValidPerg(cPerg)

	Local aHelpPor := {}
	Local aHelpSpa := {}
	Local aHelpEng := {}

	PutSx1( cPerg,"01", "M고? ", "M고? ", "Month ? ", "mv_ch1","N",02,0,0,"C","","","","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",".ZZGCSV501.") 
	PutSx1( cPerg,"02", "Ano ? ", "Ano ? ", "Ano ?   ", "mv_ch2","N",04,0,0,"C","","","","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",".ZZGCSV502.")
	PutSx1( cPerg,"03", "Diret󲩯 ? ", "Directorio ? ", "Directory  ? ", "mv_ch2","C",99,0,0,"F","","","","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",".ZZGCSV503.")
	PutSx1( cPerg,"04", "UN Pais ? ", "UN Pais ? ", "UN Pais ? ", "mv_ch3","C",03,0,0,"F","","","","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",".ZZGCSV504.")
	
	AADD(aHelpPor,"M고de Referꮣia para")
	AADD(aHelpPor,"gera磯 do arquivo.")
	AADD(aHelpEng,"M고de Referꮣia para")
	AADD(aHelpEng,"gera磯 do arquivo.")
	AADD(aHelpSpa,"M고de Referꮣia para") 
	AADD(aHelpSpa,"gera磯 do arquivo.")
	PutSX1Help("P.ZZGCSV501.",aHelpPor,aHelpEng,aHelpSpa)

	aHelpPor := {}
	aHelpSpa := {}
	aHelpEng := {}

	AADD(aHelpPor,"Ano de Referꮣia para")
	AADD(aHelpPor,"gera磯 do arquivo.")
	AADD(aHelpEng,"Ano de Referꮣia para")
	AADD(aHelpEng,"gera磯 do arquivo.")
	AADD(aHelpSpa,"Ano de Referꮣia para") 
	AADD(aHelpSpa,"gera磯 do arquivo.")
	PutSX1Help("P.ZZGCSV502.",aHelpPor,aHelpEng,aHelpSpa)
	
	aHelpPor := {}
	aHelpSpa := {}
	aHelpEng := {}

	AADD(aHelpPor,"Diret󲩯 para Grava磯 do Arquivo.")
	AADD(aHelpEng,"Diret󲩯 para Grava磯 do Arquivo.")
	AADD(aHelpSpa,"Diret󲩯 para Grava磯 do Arquivo.") 
	PutSX1Help("P.ZZGCSV503.",aHelpPor,aHelpEng,aHelpSpa)

	aHelpPor := {}
	aHelpSpa := {}
	aHelpEng := {}

	AADD(aHelpPor,"Unidade de medida do pais.")
	AADD(aHelpEng,"Unidade de medida do pais.")
	AADD(aHelpSpa,"Unidade de medida do pais.") 
	PutSX1Help("P.ZZGCSV504.",aHelpPor,aHelpEng,aHelpSpa)

Return
