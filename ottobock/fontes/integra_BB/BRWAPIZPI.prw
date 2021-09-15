/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRWAPIZPI º Autor ³ Osvaldo Cruz   
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ ZPI - Boletos Cobranca API/REST
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
#INCLUDE "PROTHEUS.CH"    
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "FWCOMMAND.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "DBTREE.CH"
#INCLUDE "MYFINA150.CH"
#include "restful.ch"
#include 'parmtype.ch'

//-- Variaveis para mensagens em caixas de dialogo.
#DEFINE _fTt0 OemToAnsi("Atenção !")
#DEFINE _fTt1 OemToAnsi("Específico TI Ottobock. ["+Lower(Alltrim(FunName()))+"]")
#DEFINE _fTt2 OemToAnsi("A T E N Ç Ã O")
#DEFINE _fTt3 OemToAnsi("A V I S O")
#DEFINE _fTt4 OemToAnsi("Processando...")
#DEFINE _fTt5 OemToAnsi("S U C E S S O")
#DEFINE _fTt6 OemToAnsi("E R R O")
#DEFINE _fCx0 OemToAnsi("INFO")
#DEFINE _fCx1 OemToAnsi("STOP")
#DEFINE _fCx2 OemToAnsi("OK")
#DEFINE _fCx3 OemToAnsi("ALERT")
#DEFINE _fCx4 OemToAnsi("YESNO")
#DEFINE _fCx5 OemToAnsi("NOYES")
#DEFINE _fCx6 OemToAnsi("FECHAR")


User Function BRWAPIZPI()		

	//-- Declaracao de Variaveis - mBrowse.
	Private aRotina 	:= MenuDef()				// Padronizacao para visualizacao no menu padrao.
	Private cCadastro 	:= OemToAnsi("Boletos Cobranca API REST")		// Padrao para o mBrowse
	Private cDelFunc 	:= ".F." 					// Validacao para a exclusao. Pode-se utilizar ExecBlock
	Private lSeeAll		:= .F.						// Define se o browse mostrara todas (.T.) as filiais.
	Private lChgAll		:= .F.						// Define se os registros de outras filiais poderao ser alterados (.T.).
	Private nInterval	:= 999						// Quantidade de tempo passada para a funcao Timer.
	Private cString 	:= "ZPI"
  
	//axCadastro('ZPI','Boletos Cobranca API REST','.T.','.T.')

	//dbSelectArea("ZPI")
	//Retindex("ZPI")

//	ZPI_STREC C 50 // STATUS DO RECEBIMENTO
//	ZPI_DTREC D 8 // DaATA RECEBIMENTO
//	ZPI_HRREC C 8 // HORA DO RECEBIMENTO
	
	aCores  := {}

	aAdd( aCores , { " AllTrim(ZPI_STREME) == ' '"													, "BR_AZUL"   })
	aAdd( aCores , { " AllTrim(ZPI_STREME) == 'Retorno com Erros' "							  	    , "BR_VERMELHO"   })
	aAdd( aCores , { " AllTrim(ZPI_STREME) == 'Transmissao OK' "							  	    , "BR_VERDE"   })
	aAdd( aCores , { " AllTrim(ZPI_STREC)  == 'Baixado' "							  	            , "BR_VIOLETA"   })
	aAdd( aCores , { " AllTrim(ZPI_STREC)  == 'Liquidado' "							  	            , "BR_AMARELO"   })
	aAdd( aCores , { " AllTrim(ZPI_STREC)  == 'Protestado' "							  	        , "BR_PRETO"   })

	cOper 	:= cOper := ""
	n := n 	:= 1
	
	dbSelectArea("ZPI")
	ZPI->(dbSetOrder(1))
	ZPI->(dbGoTop())
 
	//mBrowse(C(006),C(001),C(022),C(075),"ZPI",,,,,,aCores,,,,,,lSeeAll,lChgAll,,nInterval,,)
	mBrowse(C(006),C(001),C(022),C(075),"ZPI",,,,,,aCores)
Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ MENUDEF    º Autor ³ Osvaldo Cruz   
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Utilizacao de menu Funcional.                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MenuDef()

 	//lUsu_UTI	:= IIf( RetCodUsr() $ "|000000|001268|000928|001352|000409|000978",.T.,.F.)
  	
	//aRotinaOU := {}
	//aAdd( aRotinaOU  , { OemToAnsi( "Parar Processos")					,"U_MLSTOP()"		,0,3,43,Nil,,})
	//aAdd( aRotinaOU  , { OemToAnsi( "Ativar Processos")					,"U_ZSCSTART()"		,0,3,43,Nil,,})
	//aAdd( aRotinaOU  , { OemToAnsi( "Executar Processos")				,"U_MLSTARTGrd()"		,0,3,43,Nil,,})

	aRotina	:= {}
	aAdd( aRotina , { OemToAnsi( "Registro por Bordero" )			, "u_BOR_Fina150()"  ,0,1,42,Nil,,})
//	aAdd( aRotina , { OemToAnsi( "Registrar Cobranca " )			, "u_RegBoletos(.T.)",0,1,42,Nil,,})
//	aAdd( aRotina , { OemToAnsi( "Enviar eMail/Boleto TOTVSIP" )	, "u_IMPRIMEBOL()"   ,0,1,42,Nil,,})
//	aAdd( aRotina , { OemToAnsi( "Consulta Pgto" )					, "u_ConsRecAPI())"    ,0,1,42,Nil,,})
//	aAdd( aRotina , { OemToAnsi( "Pesquisar")						, "AxPesqui" 	     ,0,1,43,Nil,,})
	aAdd( aRotina , { OemToAnsi( "JOB Registro")				    , "U_JOBTIT01()" 	     ,0,1,43,Nil,,})
	aAdd( aRotina , { OemToAnsi( "Relatorio Mexico")				, "U_m_GeraCSV()" 	     ,0,1,43,Nil,,})	
	aAdd( aRotina , { OemToAnsi( "Legenda")							, "u_MLLEGLOG()" 	     ,0,1,43,Nil,,})


Return(aRotina)

USER Function MLLEGLOG()

	Local cLegenda	:= _fTt1
	Local cSubLeg	:= OemToAnsi("Legenda - Boletos Cobranca API/REST ")

	aLegenda := { 	{"BR_AZUL",     "Nao Registrado"},     ;                 // 2
   				  	{"BR_VERDE",    "Registrado"},         ;      //  3
   				  	{"BR_VERMELHO", "Erro no Registro"},   ;        //  6
					{"BR_VIOLETA",  "Baixado"},            ;
					{"BR_AMARELO",  "Liquidado"},          ;
					{"BR_PRETO",    "Protestado"}          ;
				}

	BrwLegenda(cCadastro,"Status",aLegenda)

Return .T.

/*

Static Function mlleglog()
	Local cLegenda	:= _fTt1
	Local cSubLeg	:= OemToAnsi("Legenda - Boletos Cobranca API/REST ")
	Local aCores	:= {}
	Local aSavArea 	:= SaveArea1({Alias()})		

	//-- Chamada da funcao para legenda.
	BrwLegenda( cLegenda , cSubLeg , aCores )

	//-- Retorna o posicionamento das tabelas utilizados na rotina.
	RestArea1(aSavArea)

Return()
*/
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ MyFina150  ³ Autor ³ Osvaldo Cruz 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Geracao do Arquivo de Envio de Titulos ao Banco            ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BOR_Fina150(nPosAuto)

Local lOk		:= .F.
Local aSays 	:= {}
Local aButtons := {}

Local lPanelFin := IsPanelFin()
Local lPergunte := .F.
Local aArea      := GetArea()
	
	
//    RestArea(aArea)
Private aJsonCobranca as array

PRIVATE cCadastro := OemToAnsi(STR0005)  // "Comunica‡„o Banc ria - Envio Cobrança"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ A fun‡„o SomaAbat reabre o SE1 com outro nome pela ChkFile, pois ³
//³ o filtro do SE1, desconsidera os abatimentos							|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//SomaAbat("","","","R")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros   ³
//³ mv_par01		 // Do Bordero 		   ³
//³ mv_par02		 // Ate o Bordero 	   ³
//³ mv_par03		 // Banco     		   ³
//³ mv_par04		 // Agenciao     	   ³
//³ mv_par05		 // Conta   		   ³
//³ mv_par06		 // Sub-Conta  		   ³
//³ mv_par07		 // Considera Filiais  ³
//³ mv_par08		 // De Filial   	   ³
//³ mv_par09		 // Ate Filial         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lPanelFin
	lPergunte := PergInPanel("AFIMY150",.T.)
Else
   lPergunte := pergunte("AFIMY150",.T.)
Endif

If lPergunte
	dbSelectArea("SE1")
	dbSetOrder(1)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa o log de processamento                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcLogIni( aButtons )
	
	If nPosAuto <> Nil
		lOk	:= .T.
	Else
		aADD(aSays,STR0015) // "Esta rotina permite gerar o arquivo de envio do CNAB de cobrança, com base nas ocorrências"
		aADD(aSays,STR0016) // "cadastradas e com os borderôs de cobrança gerados."
		
		If lPanelFin  //Chamado pelo Painel Financeiro			
			aButtonTxt := {}			
			If Len(aButtons) > 0
				AADD(aButtonTxt,{STR0021,STR0021,aButtons[1][3]}) // Visualizar			
			Endif
			AADD(aButtonTxt,{STR0003,STR0003, {||Pergunte("AFI150",.T. )}}) // Parametros						
			FaMyFormBatch(aSays,aButtonTxt,{||lOk:=.T.},{||lOk:=.F.})
      Else		
			aADD(aButtons, { 5,.T.,{|| Pergunte("AFI150",.T. ) } } )
			aADD(aButtons, { 1,.T.,{|| lOk := .T.,FechaBatch()}} )
			aADD(aButtons, { 2,.T.,{|| FechaBatch() }} )
	
			FormBatch( cCadastro, aSays, aButtons ,,,540)
		Endif
			
	Endif	

	If lOk
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o log de processamento   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ProcLogAtu("INICIO")
		
		cRet := fa150Gera("SE1")


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o log de processamento   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ProcLogAtu("FIM")
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Recupera a Integridade dos dados                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SE1")
	dbSetOrder(1)
EndIf

RestArea(aArea)


Return .T.	

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ fA150Gera³ Autor ³ Osvaldo Cruz
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Comunicacao Bancaria - Envio                               ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
static Function fa150Gera(cAlias)

Local aArea         := GetArea()
Local cRet			:= ""
PRIVATE cBanco,cAgencia,xConteudo
PRIVATE nHdlBco    	:= 0
PRIVATE nHdlSaida  	:= 0
PRIVATE nSeq       	:= 0

PRIVATE nQtdTitLote	:= 0
PRIVATE nSomaAcres	:= 0
PRIVATE nSomaDecre	:= 0
PRIVATE nBorderos		:= 0
PRIVATE xBuffer,nLidos 	:= 0
PRIVATE nTotCnab2			:= 0 // Contador de Lay-out nao deletar 
PRIVATE nLinha				:= 0 // Contador de Linhas nao deletar 
PRIVATE nQtdLinLote			:= 0 // Contador de linhas do detalhe do lote


Processa({|lEnd| cRet := u_fa150Ger(cAlias,"","","","","" )})  // Chamada com regua

nBorderos  := 0
 
FCLOSE(nHdlBco)
FCLOSE(nHdlSaida)


RestArea(aArea)    
Return cRet

// fA150Ger (cAlias)
// A função recebe chamada de duas origens
// remessa de cobrança a partir da rotina padrão de transferencia - para um único titulo 
// emessa de lote de boletos através de borderos - neste mesmo fonte.
// na chamadapor lote - recebe apenas o alias como parâmetro pois vai pesquisar ZPI em condições de envio.

user Function fA150Ger( cAlias, cBanco, cAgencia, cConta, cSubCta, cNumBor ) 


LOCAL nTamArq:=0,lResp:=.t.
LOCAL lHeader:=.F.,lFirst:=.F.,lFirst2:=.F.
LOCAL nTam,nDec,nUltDisco:=0,nGrava:=0,aBordero:={}
LOCAL nSavRecno := recno()

Local cDbf
LOCAL oDlg,oBmp,nMeter := 1

LOCAL nRegEmp := SM0->(RecNo())
LOCAL cFilDe
LOCAL cFilAte
LOCAL cNumBorAnt := CRIAVAR("E1_NUMBOR",.F.)
LOCAL cCliAnt	  := CRIAVAR("E1_CLIENTE",.F.)
LOCAL lFirstBord := .T.
LOCAL lBorBlock := .F.
LOCAL lAchouBord := .F.
LOCAL lIdCnab := .T.
Local lAtuDsk := .F.
Local lCnabEmail := .F.
Local cFilBor := ""
Local nOrdSE1:=5
Local lNovoLote := .F.
Local lBCOBORD := .T.


Local cLstSit := ""
Local aHlpSit := {}
Local cHlpSit := ""
//--- Tratamento Gestao Corporativa
Local lGestao	:= FWSizeFilial() > 2	// Indica se usa Gestao Corporativa
Local cFilFwSE1 := FwFilial("SE1")
Local cIndexSe1 
Local nIndexSe1 
Local cQuery 	:= ""
Local lHeadMod2 := .F.
Local bWhile2
Local cOrder
Local nValor
Local cCart	:= "R"
//Gestao
Local lQuery 	:= IfDefTopCTB() // verificar se pode executar query (TOPCONN)
Local aSelFil	:= {}
Local lSE1Acces := Iif( lGestao, FWModeAccess("SE1",1) == "C", FWModeAccess("SE1",3) == "C")
Local bWhile 	:= {||.T.}
Local cSelFil	:= ""
Local cLastFil	:= ""
Local nX		:= 1
Local bObject 	:= {|| JsonObject():New()}
Local oJson   	:= Eval(bObject)
Local cNossoNum := ""

Local aArea         := GetArea()
Private cMensgem 	:= ""

DEFAULT cAlias		:= ""
DEFAULT cBanco		:= ""
DEFAULT cAgencia	:= ""
DEFAULT cConta		:= ""
DEFAULT cSubCta		:= ""
DEFAULT cNumBor		:= ""

ProcRegua(SE1->(RecCount()))

// SE a chamada da funcao é pelo PE traz dados para registro e não seleciona perguntas.
// Se a chamada da funcao é pela rotina BRWAPIZPI (esta) vai selecionar perguntas. 
IF 			!empty( cBanco ) .and. !empty( cAgencia ) .and. !empty( cConta );
	.and. 	!empty( cSubCta ) .and. !empty( cNumBor ) 

	mv_par01 := cNumBor
	mv_par02 := cNumBor
	mv_par03 := cBanco  
	mv_par04 := cAgencia
	mv_par05 := cConta  
	mv_par05 := cSubCta 

ELSE 

	cBanco  := mv_par03
	cAgencia:= mv_par04
	cConta  := mv_par05
	cSubCta := mv_par06

ENDIF 
dbSelectArea("SA6")
If !(dbSeek(xFilial("SA6")+cBanco+cAgencia+cConta))
	Help(" ",1,"FA150BCO")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento com o erro  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcLogAtu("ERRO","FA150BCO",Ap5GetHelp("FA150BCO"))

	Return .F.
ElseIf Max(SA6->A6_MOEDA,1) > 1

	Help( "  ", 1, "MOEDACNAB" )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento com o erro  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcLogAtu("ERRO","FA150BCO",Ap5GetHelp("FA150BCO"))

	Return .F.

Endif

dbSelectArea("SEE")
if !(SEE->( dbSeek(xFilial("SEE") + cBanco + cAgencia + cConta + cSubCta) ))

	Help(" ",1,"PAR150")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento com o erro  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcLogAtu("ERRO","PAR150",Ap5GetHelp("PAR150"))

	Return .F.
Endif

cConvenio := alltrim(SEE->EE_CODEMP) 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no Bordero Informado pelo usuario                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if mv_par07 == 2
	cFilDe := cFilAnt
	cFilAte:= cFilAnt
Else
	cFilDe := mv_par08
	cFilAte:= mv_par09
Endif

nTotCnab2 := 0
nSeq := 0
mv_par14 := 2
//Gestao
If lQuery
	If mv_par14 == 1	
		//SE1 totalmente compartilhado nao habilita tela de selecao de filiais				
		If lSE1Acces
			aSelFil := { cFilAnt }	 				
		Else
			aSelFil := AdmGetFil(.F.,.T.,"SE1")
			nLenFil := Len( aSelFil )
			If nLenFil <= 0
				Return
			EndIf	
		Endif
	Else
		aSelFil := { cFilAnt }	 				
	Endif			

	bWhile :=	{||.T. }
	
	For nX := 1 to Len(aSelFil)
		cSelFil  += aSelFil[nX]+"|" 
		If nX == 1	
			cFilDe := aSelFil[nX]
		Endif
	    cLastFil := aSelFil[nX]
	Next		

	dbSelectArea("SM0")
	MsSeek(cEmpAnt+cFilDe,.T.)
	
Else
	dbSelectArea("SM0")
	dbSeek(cEmpAnt+cFilDe,.T.)
	lAchouBord := .F.
	bWhile := {||FWGETCODFILIAL <= cFilAte}
Endif	

While SM0->(!Eof()) .and. SM0->M0_CODIGO == cEmpAnt .and. Eval(bWhile)

	cFilAnt := FWGETCODFILIAL

	//Gestao
	If lQuery

		//Verifico se processei a ultima filial do range de filiais selecionadas pelo usuario
		If lGestao .and. Left(SM0->M0_CODFIL,FWSizeFilial()) > cLastFil
			Exit
		Endif

		//Verifico se a filial esta contida no range de filiais selecionadas pelo usuario
		If !(cFilAnt $ cSelFil)
			SM0->(dbSkip())
			Loop
		Endif

	Endif

	dbSelectArea("SE1")
	SE1->( dbSetOrder(nOrdSE1) )

	SE1->( MSSeek(xFilial("SE1")+mv_par01,.T.))
	bWhile2 := { || !SE1->( Eof()) .and. E1_NUMBOR >= mv_par01 .AND. E1_NUMBOR <= mv_par02 .and. xFilial("SE1")==E1_FILIAL }
	// Processa SE1 filtrado por bordero em ordem de cliente ou em ordem de bordero
	While Eval(bWhile2)
			
		lAchouBord := .T.
		IncProc()

		//PCREQ-3782 - Bloqueio por situação de cobrança
		cLstSit := F023VerBlq("2","0009")
		// Valida se está em situação de cobrança que bloqueia o envio de CNAB 
		If E1_SITUACA $ cLstSit .AND. aScan(aHlpSit,SE1->E1_NUMBOR) == 0
			aadd(aHlpSit,SE1->E1_NUMBOR)//{SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA}
		Endif

		IF Empty(SE1->E1_NUMBOR) .or. E1_SITUACA $ cLstSit .or. (SE1->E1_NUMBOR == cNumBorAnt .and. lBorBlock )
			SE1->( dbSkip() )
			Loop
		EndIF
		/*
		IF SE1->E1_PORTADO<>cBanco .And. cAgencia<>SE1->E1_AGEDEP .And. SE1->E1_CONTA<>cConta .And. lBCOBORD
			SE1->( dbSkip() )
			Loop
		EndIF
		*/
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o portador do bordero ‚ o mesmo dos parametros   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		// Se mudou o bordero 
		If SE1->E1_NUMBOR != cNumBorAnt .or. lFirstBord
			// Se CNAB modelo 2 e mudou o bordero ou cliente
			lFirstBord := .F.
			dbSelectArea("SEA")
			If Fa150PesqBord(SE1->E1_NUMBOR,@cFilBor,cCart)
				While SEA->EA_NUMBOR == SE1->E1_NUMBOR .and. SEA->EA_FILIAL == cFilBor .and. !Eof()
					If SEA->EA_CART == "R"
						cNumBorAnt := SE1->E1_NUMBOR
						cCliAnt	  := SE1->E1_CLIENTE
						lBorBlock := .F.
						If cBanco+cAgencia+cConta != SEA->(EA_PORTADO+EA_AGEDEP+EA_NUMCON) .And. lBCOBORD
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Bordero pertence a outro Bco/Age/Cta ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							Help(" ",1,"NOBCOBORD",,cNumBorAnt,4,1) 

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Atualiza o log de processamento com o erro  ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							ProcLogAtu("ERRO","NOBCOBORD",Ap5GetHelp("NOBCOBORD")+cNumBorAnt)
						
							lBorBlock := .T.
						Endif
						Exit
					Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Bordero pertence a outra Carteira (Pagar) ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						lBorBlock := .T.
						SEA->(dbSkip())
						Loop
					Endif
				Enddo
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Bordero nÆo foi achado no SEA        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Help(" ",1,"BORNOXADO",,SE1->E1_NUMBOR,4,1)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza o log de processamento com o erro  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				ProcLogAtu("ERRO","BORNOXADO",Ap5GetHelp("BORNOXADO")+SE1->E1_NUMBOR)

				lBorBlock := .T.
			Endif
		Endif
		dbSelectArea("SE1")
		If lBorBlock
			SE1->( dbSkip() )
			Loop
		Endif

		IF SE1->E1_TIPO $ MVRECANT+"/"+MVPROVIS
			SE1->( dbSkip() )
			Loop
		EndIF
		
		// Posiciona no Contrato bancario                               
		dbSelectArea("SE9")
		dbSetOrder(1)
		MsSeek(xFilial("SE9")+SE1->(E1_CONTRAT+E1_PORTADO+E1_AGEDEP))
		
		// Posiciona no cliente
		dbSelectArea("SA1")
		MsSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA)
		cPagador	:= SA1->A1_NOME
		if len(alltrim(SA1->A1_CGC)) = 14 
			cTpoInsPaga		:= "2"				//	0251	S	1 ou 2
		Else
			cTpoInsPaga		:= "1"				//	0251	S	1 ou 2
		ENDIF   		
		cNroInsPaga			:= alltrim(SA1->A1_CGC)
		cNomePaga			:= alltrim(SA1->A1_NOME)	//	0253	S	“Odorico Paraguassu”	
		cEndePaga			:= alltrim(SA1->A1_END)	//	0254	S	“Avenida Dias Gomes 1970”	
		cCEPPaga			:= alltrim(SA1->A1_CEP) 		//	0255	S	77458000	
		cCidPaga			:= alltrim(SA1->A1_MUN)		//	0256	S	“Sucupira”	
		cBairPaga			:= alltrim(SA1->A1_BAIRRO)	//	0257	S	“Centro”	
		cUFPaga				:= alltrim(SA1->A1_EST)	//	0258	S	"PARA"	
		cFonePaga			:= alltrim(SA1->A1_DDD) + "-" + alltrim(SA1->A1_TEL)	//	0259		“63987654321”	
 	
		cTpoInsFina			:= cTpoInsPaga	//	0261		1 ou 2	
		cNroInsFina			:= cNroInsPaga	//	0262		66779051870 (PF) ou 98959112000179 (PJ)	
		cNomeFina			:= cNomePaga	//	0263		“Dirceu Borboleta”	oJson["code"]
		dbSelectArea("SE1")
	
		nSeq++
		
		
	  	nSomaAcres += SE1->E1_SDACRES
	  	nSomaDecre += SE1->E1_SDDECRE

		//nGrava := fA150Grava(,,,@aBordero,,lFinCnab2,@lIdCnab)
		// aqui comeca
		lNewIndice	:= .T.
		nOrdCNAB    := 1
		cIdCnab 	:= GetSxENum("ZPI", "ZPI_IDCNAB","ZPI_IDCNAB"+cEmpAnt,nOrdCNAB)
		cChaveID 	:= If(lNewIndice,cIdCnab,xFilial("ZPI")+cIdCnab)
		dbSelectArea("ZPI")
		aOrdZPI	 	:= ZPI->(GetArea())
		dbSetOrder(nOrdCNAB)
		While ZPI->(MsSeek(cChaveID))
			ConOut("Id CNAB " + cIdCnab + " já existe para o arquivo ZPI. Gerando novo número ")
			If ( __lSx8 )
				ConfirmSX8()
			EndIf
			cIdCnab := GetSxENum("ZPI", "ZPI_IDCNAB","ZPI_IDCNAB"+cEmpAnt,nOrdCNAB)
			cChaveID := If(lNewIndice,cIdCnab,xFilial("ZPI")+cIdCnab)
		EndDo

		// - Bloqueio por situação de cobrança
		//Informa quais títulos não serão enviados por bloqueio de siuação de cobrança
		/*
		If len(aHlpSit) >= 1
			cHlpSit := CRLF
		For nX := 1 to len(aHlpSit)
			cHlpSit += aHlpSit[nX] + CRLF//aHlpSit[nX,1] +" - "+ aHlpSit[nX,2] +" - "+ aHlpSit[nX,3]
		Next nX
		Help(" ",1,"BLQENCNAB",,STR0024+CRLF+cHlpSit,1,0) //Os borderôs abaixo não foram enviados devido bloqueio por situação de cobrança
	
		*/

		cChaveZPI := SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO
		dbSelectArea("ZPI")
	    dbSetOrder(2)
		If ZPI->( MsSeek( cChaveZPI ) ) .AND. ALLTRIM(UPPER(ZPI->ZPI_STREME)) = "TRANSMISSAO OK"
			dbSelectArea("SE1")
			SE1->( dbSkip())
			Loop
		ENDIF 	
		cNossoNum := ""
		//cChaveZPI := cFilBor + cPREFIXO + cNUM + cPARCELA + cTIPO
		if cBanco == "341"
			cNossoNum := strzero(VAL(NossoNum( cBanco, cAgencia,  cConta, cSubCta )),10)
		ENDIF 
		if cBanco == "001"	
			cNossoNum := "000" + ALLTRIM(cConvenio) + strzero(VAL(NossoNum( cBanco, cAgencia,  cConta, cSubCta )),10)
		ENDIF 	
		if val(cNossoNum) = 0 .OR. EMPTY(cNossoNum)
			return 
		endif 	

		cChaveZPI := SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO
		dbSelectArea("ZPI")
	    dbSetOrder(2)
		If !(ZPI->( MsSeek( cChaveZPI ) )) 
		
			RecLock( "ZPI" ,.T.)
				
			ZPI->ZPI_FILIAL	:= SE1->E1_FILIAL
			ZPI->ZPI_PREFIX	:= SE1->E1_PREFIXO
			ZPI->ZPI_NUM	:= SE1->E1_NUM
			ZPI->ZPI_PARC	:= SE1->E1_PARCELA
			ZPI->ZPI_TIPO	:= SE1->E1_TIPO

		else

			RecLock( "ZPI" ,.F.)
		ENDIF 

		ZPI->ZPI_BANCO	:= SE1->E1_PORTADO
		ZPI->ZPI_AGEN	:= SE1->E1_AGEDEP
		ZPI->ZPI_CONTA	:= SEE->EE_CONTA
		ZPI->ZPI_SUBCON	:= SEE->EE_SUBCTA
		ZPI->ZPI_IDCNAB	:= cIdCnab 
		ZPI->ZPI_DVCTA	:= SEE->EE_DVCTA
		ZPI->ZPI_NROCON := SEE->EE_CODEMP
		ZPI->ZPI_NROCAR	:= "17"				// TORNAR CAMPO SEE  SEE->EE_XCARTE
		ZPI->ZPI_NRVARC := "19"				// TORNAR CAMPO SEE
		ZPI->ZPI_CODMOD	:= "1"				// TORNAR CAMPO SEE	
		ZPI->ZPI_DTEMIS	:= SE1->E1_EMISSAO
		ZPI->ZPI_DTVENC	:= SE1->E1_VENCREA 
		ZPI->ZPI_VLRORI := SE1->E1_VALOR
		ZPI->ZPI_VLRABA := SE1->E1_DESCONT
		ZPI->ZPI_QTDPRO := "0"				// TORNAR CAMPO SEE
		ZPI->ZPI_TITVEN := "N"				// TORNAR CAMPO SEE
		ZPI->ZPI_DIAREC := "0"				// TORNAR CAMPO SEE
		ZPI->ZPI_CODACE := "A"				// TORNAR CAMPO SEE
		ZPI->ZPI_TIPTIT := "2"				// TORNAR CAMPO SEE	
		ZPI->ZPI_DESTPT := "DM"				// TORNAR CAMPO SEE
		ZPI->ZPI_RECPAR := "S"				// TORNAR CAMPO SEE
		ZPI->ZPI_NRTITB := SE1->E1_FILIAL + ALLTRIM(SE1->E1_PREFIXO) + SE1->E1_NUM	
		//	ZPI->ZPI_CPOBEN := SE1->E1_CLIENTE + SE1->E1_LOJA
		ZPI->ZPI_CPOBEN := "COBRANCA API"
    	//ZPI->ZPI_TITCLI := "000" + ALLTRIM(cConvenio) + strzero(VAL(NossoNum()),10)
		//	ZPI->ZPI_TITCLI := "000" + ALLTRIM(cConvenio) + strzero(VAL(SE1->E1_NUMBCO),10)
		ZPI->ZPI_TITCLI := cNossoNum
		ZPI->ZPI_BLQOCO := ""
		ZPI->ZPI_DESTIP	:= ""
		ZPI->ZPI_DESEXP	:= CTOD("")
		ZPI->ZPI_DESPER	:= 0
		ZPI->ZPI_DESVAL	:= 0
		ZPI->ZPI_2DEEXP	:= CTOD("")
		ZPI->ZPI_2DEPER	:= 0
		ZPI->ZPI_2DEVAL	:= 0
		ZPI->ZPI_3DEEXP	:= CTOD("")
		ZPI->ZPI_3DEPER	:= 0
		ZPI->ZPI_3DEVAL	:= 0
		ZPI->ZPI_JURTIP	:= ""
		ZPI->ZPI_JURPER	:= 0
		ZPI->ZPI_JURVAL := 0
		ZPI->ZPI_MULTIP := ""
		ZPI->ZPI_MULDAD := ""
		ZPI->ZPI_MULPER := 0
		ZPI->ZPI_MULVAL := 0
		ZPI->ZPI_PAGTIN := cTpoInsPaga
		ZPI->ZPI_PAGINS := cNroInsPaga
		ZPI->ZPI_PAGNOM := cNomePaga
		ZPI->ZPI_PAGEND := cEndePaga
		ZPI->ZPI_PAGCEP := cCEPPaga
		ZPI->ZPI_PAGCID := cCidPaga
		ZPI->ZPI_PAGBAI := cBairPaga 
		ZPI->ZPI_PAGUF  := cUFPaga
		ZPI->ZPI_PAGTEL := cFonePaga
		ZPI->ZPI_BENTIN := cTpoInsFina
		ZPI->ZPI_BENINS := cNroInsFina
		ZPI->ZPI_BENNOM := cNomeFina
		ZPI->ZPI_QTDINE := ""
		ZPI->ZPI_ORGNEG := "10"
		ZPI->ZPI_INDPIX := ""
		ZPI->ZPI_DTREME := CTOD("")
		ZPI->ZPI_HRREME := ""
		ZPI->ZPI_STREME := ""
		ZPI->ZPI_NRORET := ""
		ZPI->ZPI_LINDIG := ""
		ZPI->ZPI_CODBAR := ""
		ZPI->ZPI_DTBAIX := CTOD("")
		ZPI->ZPI_DTRECE := CTOD("")
	

		ZPI->(MsUnlock())

//		aArea  := GetArea()

//	    u_RegBoletos(  SE1->E1_FILIAL  + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO )
			 
//		RestArea(aArea)    

		dbSelectArea("SE1")
		SE1->( dbSkip())
	Enddo
	

	If lGestao
		If lAchouBord .And. Empty( cFilFwSE1 )
			Exit
		EndIf
	Else		
		If Empty( cFilFwSE1 )
			Exit
		Endif
	EndIf	
	dbSelectArea("SM0")
	dbSkip()
EndDO

SM0->(dbgoto(nRegEmp))
cFilAnt := FWGETCODFILIAL

If !lAchouBord
	Help(" ",1,"BORD150")

	// Atualiza o log de processamento com o erro  
	ProcLogAtu("ERRO","BORD150",Ap5GetHelp("BORD150"))

	Return "Erro - Nao achou bordero"
EndIF


dbSelectArea( cAlias )
dbGoTo( nSavRecno )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// Recupera a Integridade dos dados                              
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RetIndex("SE1")
dbSetOrder(1)
dbClearFilter()

// Envia cobranca pela API.
// realiza registro a partir da rotina BRQAPIZPI e pelo PE quando o titulo selecionado na transferencia tem bordero.  
cRetorno  :=  u_RegBoletos(  SE1->E1_FILIAL  + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO )
//cRetorno := "Erros = " + alltrim(str(nErro)) + " - Ok = " + alltrim(str(nOk))
MSGALERT("Processamento Encerrado A Rotina de Registro de Cobrança Retornou: " + cRetorno )

return cRetorno

//**************************************************************
// REGISTRA ZPI A PARTIR DA TRANSFERENCIA 
//**************************************************************
 
user Function fA150Reg( cFilBor  , cPREFIXO, cNUM  , cPARCELA , cTIPO,;
                      	cBanco   , cAgencia, cConta , cSubCta ) 
     
LOCAL cFilDe
LOCAL cFilAte
LOCAL lIdCnab := .T.
Local nOrdSE1:=5

Local lGestao	:= FWSizeFilial() > 2	// Indica se usa Gestao Corporativa
Local cFilFwSE1 := FwFilial("SE1")
Local cIndexSe1 
Local nIndexSe1 
Local cCart	:= "R"
//Gestao
Local cNossoNum := ""
Local nErro		:= 0
Local nOk 		:= 0
Local aArea          := GetArea()
Local cDVcta	:= ""
Private cMensagem 	:= ""
Private cBarras		:= ""
cMensagem 			:= ""
cBarras				:= ""


	DbSelectArea("SE1")
	SE1->( dbSetOrder( 1 ) )
	if !(SE1->( DbSeek( cFilBor + cPREFIXO + cNUM + cPARCELA + cTIPO )))
		RETURN .F.
	ENDIF

	dbSelectArea("SEE")
	SEE->( dbSetOrder( 1 ) )
	CChaveSEE := xFilial("SEE") + PADR( cBanco, TamSx3("EE_CODIGO")[1])   +  PADR( cAgencia, TamSx3("EE_AGENCIA")[1] ) + PADR( cConta , TamSx3("EE_CONTA")[1]) + PADR( cSubCta, TamSx3("EE_SUBCTA")[1])
	if !(SEE->( dbSeek( cChaveSEE )))
		Return .F.
	endif 
	cConvenio := alltrim(SEE->EE_CODEMP) 
	cDvCta		:= SEE->EE_DVCTA
	lNewIndice	:= .T.
	nOrdCNAB    := 1
	cIdCnab 	:= GetSxENum("ZPI", "ZPI_IDCNAB","ZPI_IDCNAB"+cEmpAnt,nOrdCNAB)
	cChaveID 	:= If(lNewIndice,cIdCnab,xFilial("ZPI")+cIdCnab)
	dbSelectArea("ZPI")
	aOrdZPI	 	:= ZPI->(GetArea())
	dbSetOrder(nOrdCNAB)
	While ZPI->(MsSeek(cChaveID))
		ConOut("Id CNAB " + cIdCnab + " já existe para o arquivo ZPI. Gerando novo número ")
		If ( __lSx8 )
			ConfirmSX8()
		EndIf
		cIdCnab := GetSxENum("ZPI", "ZPI_IDCNAB","ZPI_IDCNAB"+cEmpAnt,nOrdCNAB)
		cChaveID := If(lNewIndice,cIdCnab,xFilial("ZPI")+cIdCnab)
	EndDo

	// Posiciona no cliente
	dbSelectArea("SA1")
	MsSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA)
	cPagador	:= SA1->A1_NOME
	if len(alltrim(SA1->A1_CGC)) = 14 
		cTpoInsPaga		:= "2"				//	0251	S	1 ou 2
	Else
		TpoInsPaga		:= "1"				//	0251	S	1 ou 2
	ENDIF   		
	cNroInsPaga			:= alltrim(SA1->A1_CGC)
	cNomePaga			:= alltrim(SA1->A1_NOME)	//	0253	S	“Odorico Paraguassu”	
	cEndePaga			:= alltrim(SA1->A1_END)	//	0254	S	“Avenida Dias Gomes 1970”	
	cCEPPaga			:= alltrim(SA1->A1_CEP) 		//	0255	S	77458000	
	cCidPaga			:= alltrim(SA1->A1_MUN)		//	0256	S	“Sucupira”	
	cBairPaga			:= alltrim(SA1->A1_BAIRRO)	//	0257	S	“Centro”	
	cUFPaga				:= alltrim(SA1->A1_EST)	//	0258	S	"PARA"	
	cFonePaga			:= alltrim(SA1->A1_DDD) + "-" + alltrim(SA1->A1_TEL)	//	0259		“63987654321”	
	
	cTpoInsFina			:= cTpoInsPaga	//	0261		1 ou 2	
	cNroInsFina			:= cNroInsPaga	//	0262		66779051870 (PF) ou 98959112000179 (PJ)	
	cNomeFina			:= cNomePaga	//	0263		“Dirceu Borboleta”	oJson["code"]
	dbSelectArea("SE1")

	cNossoNum := ""
	cChaveZPI := cFilBor + cPREFIXO + cNUM + cPARCELA + cTIPO
	if cBanco == "341"
		cNossoNum := strzero(VAL(NossoNum( cBanco, cAgencia,  cConta, cSubCta )),10)
	ENDIF 
	if cBanco == "001"	
		cNossoNum := "000" + ALLTRIM(cConvenio) + strzero(VAL(NossoNum( cBanco, cAgencia,  cConta, cSubCta )),10)
	ENDIF 	
	if val(cNossoNum) = 0 .OR. EMPTY(cNossoNum)
		return 
	endif 	
	dbSelectArea("ZPI")
    dbSetOrder(2)
	If !(ZPI->( MsSeek( cChaveZPI ) )) 
	
		RecLock( "ZPI" ,.T.)
			
		ZPI->ZPI_FILIAL	:= SE1->E1_FILIAL
		ZPI->ZPI_PREFIX	:= SE1->E1_PREFIXO
		ZPI->ZPI_NUM	:= SE1->E1_NUM
		ZPI->ZPI_PARC	:= SE1->E1_PARCELA
		ZPI->ZPI_TIPO	:= SE1->E1_TIPO

	else
		RecLock( "ZPI" ,.F.)
	ENDIF 
	ZPI->ZPI_BANCO	:= SE1->E1_PORTADO
	ZPI->ZPI_AGEN	:= SE1->E1_AGEDEP
	ZPI->ZPI_CONTA	:= SEE->EE_CONTA
	ZPI->ZPI_SUBCON	:= SEE->EE_SUBCTA
	ZPI->ZPI_IDCNAB	:= cIdCnab 
	ZPI->ZPI_DVCTA	:= SEE->EE_DVCTA
	ZPI->ZPI_NROCON := SEE->EE_CODEMP
	ZPI->ZPI_NROCAR	:= "17"				// TORNAR CAMPO SEE  SEE->EE_XCARTE
	ZPI->ZPI_NRVARC := "19"				// TORNAR CAMPO SEE
	ZPI->ZPI_CODMOD	:= "1"				// TORNAR CAMPO SEE	
	ZPI->ZPI_DTEMIS	:= SE1->E1_EMISSAO
	ZPI->ZPI_DTVENC	:= SE1->E1_VENCREA 
	ZPI->ZPI_VLRORI := SE1->E1_VALOR
	ZPI->ZPI_VLRABA := SE1->E1_DESCONT
	ZPI->ZPI_QTDPRO := "0"				// TORNAR CAMPO SEE
	ZPI->ZPI_TITVEN := "N"				// TORNAR CAMPO SEE
	ZPI->ZPI_DIAREC := "0"				// TORNAR CAMPO SEE
	ZPI->ZPI_CODACE := "A"				// TORNAR CAMPO SEE
	ZPI->ZPI_TIPTIT := "2"				// TORNAR CAMPO SEE	
	ZPI->ZPI_DESTPT := "DM"				// TORNAR CAMPO SEE
	ZPI->ZPI_RECPAR := "S"				// TORNAR CAMPO SEE
	ZPI->ZPI_NRTITB := SE1->E1_FILIAL + ALLTRIM(SE1->E1_PREFIXO) + SE1->E1_NUM	
	//	ZPI->ZPI_CPOBEN := SE1->E1_CLIENTE + SE1->E1_LOJA
	ZPI->ZPI_CPOBEN := "COBRANCA API"
    //ZPI->ZPI_TITCLI := cNossoNum"000" + ALLTRIM(cConvenio) + strzero(VAL(NossoNum()),10)
	//	ZPI->ZPI_TITCLI := "000" + ALLTRIM(cConvenio) + strzero(VAL(SE1->E1_NUMBCO),10)
	ZPI->ZPI_TITCLI := cNossoNum
	ZPI->ZPI_BLQOCO := ""
	ZPI->ZPI_DESTIP	:= ""
	ZPI->ZPI_DESEXP	:= CTOD("")
	ZPI->ZPI_DESPER	:= 0
	ZPI->ZPI_DESVAL	:= 0
	ZPI->ZPI_2DEEXP	:= CTOD("")
	ZPI->ZPI_2DEPER	:= 0
	ZPI->ZPI_2DEVAL	:= 0
	ZPI->ZPI_3DEEXP	:= CTOD("")
	ZPI->ZPI_3DEPER	:= 0
	ZPI->ZPI_3DEVAL	:= 0
	ZPI->ZPI_JURTIP	:= ""
	ZPI->ZPI_JURPER	:= 0
	ZPI->ZPI_JURVAL := 0
	ZPI->ZPI_MULTIP := ""
	ZPI->ZPI_MULDAD := ""
	ZPI->ZPI_MULPER := 0
	ZPI->ZPI_MULVAL := 0
	ZPI->ZPI_PAGTIN := cTpoInsPaga
	ZPI->ZPI_PAGINS := cNroInsPaga
	ZPI->ZPI_PAGNOM := cNomePaga
	ZPI->ZPI_PAGEND := cEndePaga
	ZPI->ZPI_PAGCEP := cCEPPaga
	ZPI->ZPI_PAGCID := cCidPaga
	ZPI->ZPI_PAGBAI := cBairPaga 
	ZPI->ZPI_PAGUF  := cUFPaga
	ZPI->ZPI_PAGTEL := cFonePaga
	ZPI->ZPI_BENTIN := cTpoInsFina
	ZPI->ZPI_BENINS := cNroInsFina
	ZPI->ZPI_BENNOM := cNomeFina
	ZPI->ZPI_QTDINE := ""
	ZPI->ZPI_ORGNEG := "10"
	ZPI->ZPI_INDPIX := ""
	ZPI->ZPI_DTREME := CTOD("")
	ZPI->ZPI_HRREME := ""
	ZPI->ZPI_STREME := ""
	ZPI->ZPI_NRORET := ""
	ZPI->ZPI_LINDIG := ""
	ZPI->ZPI_CODBAR := ""
	ZPI->ZPI_DTBAIX := CTOD("")
	ZPI->ZPI_DTRECE := CTOD("")
	

	ZPI->(MsUnlock())

	aArea  := GetArea()

//	u_RegBoletos(  .T., SE1->E1_FILIAL, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO )

	cMensagem	:= "Erro de Processamento"
	aArea2          := GetArea()
	IF cBanco == "001" .AND. cSubCta == "API"
		cRet := u_BBBOLCOBR(   cPREFIXO, cNUM, cPARCELA, cTIPO , cFilBor, cBanco, cAgencia, cConta, cSubCta, @cMensagem, @cBarras )
	ELSEIF cBanco == "341" .AND. cSubCta == "API"
		cRet := u_ITAUBOLCOBR( cPREFIXO, cNUM,    cPARCELA, cTIPO , cFilBor, cBanco    ,   cAgencia ,   cConta    , cSubCta, cDVcta    , @cMensagem, @cBarras )
				 // ITAUBOLCOBR( cPrefixo, cTitulo, cParcela, cTipo , cFilBol, pZPI_BANCO,   pZPI_AGEN,   pZPI_CONTA, pZPI_SUBCON, cMensagem , cBarras  )
	ELSE 
		cMensagem := "Banco Invalido! " + cBanco + " - SubConta: " + cSubCta
		cRet := "Erro"
	ENDIF 
	if "Erro" $ cRet
		nErro++
	else 
		nOk++
	endif 		 

	RestArea(aArea)    
	cRetorno := "Erros = " + alltrim(str(nErro)) + " - Ok = " + alltrim(str(nOk))
	MSGALERT("A Rotina de Registro de Cobrança Retornou: " + cRetorno )

return cRetorno

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
 Retorna digito de controle                                
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function NossoNum(  cBanco, cAgencia, cConta, cSubCta )

Local cNumTOTVSIP 	:= ""
Local cNumero 		:= ""
//Local nTam := TamSx3("EE_FAXATU")[1]
//Local nTam2:= TamSx3("E1_NUMBCO")[1] 
Local nTam2:= 15
Local nTam := 12
Local nRegSEE := 0
// Enquanto nao conseguir criar o semaforo, indica que outro usuario
// esta tentando gerar o nosso numero.

dbSelectArea("SEE")
SEE->( dbSetOrder( 1 ) )
cChaveSEE := xFilial("SEE") + PADR( cBanco, TamSx3("EE_CODIGO")[1])  +  PADR( cAgencia, TamSx3("EE_AGENCIA")[1] ) + PADR( cConta , TamSx3("EE_CONTA")[1]) + PADR( "001", TamSx3("EE_SUBCTA")[1])
if SEE->( dbSeek( cChaveSEE ))
	cNumTOTVSIP   := StrZero(Val(SEE->EE_FAXATU),nTam)
	nReg001 := recno()
endif 

dbSelectArea("SEE")
SEE->( dbSetOrder( 1 ) )
CChaveSEE := xFilial("SEE") + PADR( cBanco, TamSx3("EE_CODIGO")[1])   +  PADR( cAgencia, TamSx3("EE_AGENCIA")[1] ) + PADR( cConta , TamSx3("EE_CONTA")[1]) + PADR( cSubCta, TamSx3("EE_SUBCTA")[1])
if !(SEE->( dbSeek( cChaveSEE )))
	Return .F.
endif 

cNumero    := StrZero(Val(SEE->EE_FAXATU),nTam)

While !MayIUseCode( SEE->(EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA))  //verifica se esta na memoria, sendo usado
	cNumero := Soma1(cNumero)										// busca o proximo numero disponivel 
EndDo

cNumeroSE1 := StrZero(Val( cNumero ),nTam2)

If Empty(SE1->E1_ZZNNBCO)


	IF VAL(cNumTOTVSIP) >  VAL(cNumeroSE1)
		cNumeroSE1 := cNumTOTVSIP
    endif 

	RecLock("SE1",.F.)
	Replace SE1->E1_NUMBCO With StrZero(Val( cNumeroSE1 ),nTam2)
	SE1->( MsUnlock( ) )
	nRegSEE := SEE->(RECNO())
	RecLock("SEE",.F.)
	cNumeroSE1 := Soma1(cNumeroSE1, 15 )
	Replace SEE->EE_FAXATU With StrZero(Val(cNumeroSE1),nTam)
	SEE->( MsUnlock() )

	dbSelectArea("SEE")
	SEE->( dbSetOrder( 1 ) )
	cChaveSEE := xFilial("SEE") + PADR( cBanco, TamSx3("EE_CODIGO")[1])  +  PADR( cAgencia, TamSx3("EE_AGENCIA")[1] ) + PADR( cConta , TamSx3("EE_CONTA")[1]) + PADR( "001", TamSx3("EE_SUBCTA")[1])
	if SEE->( dbSeek( cChaveSEE ))
		RecLock("SEE",.F.)
		Replace SEE->EE_FAXATU With StrZero(Val(cNumeroSE1),nTam)
		SEE->( MsUnlock() )
	endif 
	SEE->(dbGoto(nRegSEE))	
	// falta alterar api 001
EndIf	

Leave1Code(SEE->(EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA))
DbSelectArea("SE1")

       
Return(SE1->E1_NUMBCO)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
 Pesquisa Bordero em todas as filiais e atualiza o parametro|±±
  cFilBor com a filial em que foi encontrada o bordero    
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/  
STATIC Function Fa150PesqBord(cNumBor,cFilBor,cCart)
Local cFilOld 	:= cFilAnt
Local lRet 		:= .F.
Local nInc		:= 0
Local cAlias	:= Alias()
Local aSM0		:= AdmAbreSM0()
Local aFiliais  := {}        
Local nPos      := 0

//--- Tratamento Gestao Corporativa
Local cFilFwSEA := FwFilial("SEA")
Local nRecBordero := 0

Default cCart	:= ""

// Se deve pesquisar com a carteira do bordero "P" ou "R"
If !Empty( cCart )
	SEA->( dbSetOrder( 2 ) )
Else	
	SEA->( dbSetOrder( 1 ) )
EndIf

If !Empty( cFilFwSEA ) // Se o SEA for exclusivo, pesquisa o bordero em todas as filiais  
	For nInc := 1 To Len( aSM0 )
		If aSM0[nInc][1] == cEmpAnt
			cFilAnt := aSM0[nInc][2]
			If SEA->( MsSeek( xFilial( "SEA" ) + cNumBor + cCart ) )
				aadd(aFiliais,SEA->EA_FILIAL)
				lRet	:= .T.
				nRecBordero := SEA->(Recno())
			EndIf
		EndIf
	Next
	SEA->(dbGoto(nRecBordero))
Else
	lRet := SEA->( MsSeek( xFilial( "SEA" ) + cNumBor + cCart ) )
	cFilBor := SEA->EA_FILIAL
Endif	
nPos := aScan(aFiliais,cFilOld)
If nPos > 0
	cFilBor := aFiliais[nPos]
ElseIf Len(aFiliais)>=1
	cFilBor := aFiliais[1]
Endif

// Restaura ambiente
cFilAnt := cFilOld

dbSelectArea( cAlias )

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
 Retorna um array com as informacoes das filias das empresas  
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AdmAbreSM0()
	Local aArea			:= SM0->( GetArea() )
	Local aRetSM0		:= FWLoadSM0()

	RestArea( aArea )
Return aRetSM0
//******************************************************




//***************************************************************************************
//  GravaZPI									 Autor  Osvaldo Cruz 
//  Geracao do Arquivo de Envio de Titulos ao Banco 
//  Rotina chamada a partir do browse BRWAPIZPI
//  Regostros no banco em lote a partir de ZPI sem registros
//***************************************************************************************     

User Function RegBoletos(  lAll, cFilBol , cPrefixo , cTitulo , cParcela , cTipo )

// retorna mensagem com erros ou sucesso

LOCAL aArea		:= GETAREA()
Local cQuery	:= ""
Local lAll		:= .T.
Local cAliasTrb := "TRBLE"
Local nErro		:= 0
Local nOk		:= 0
/*
Local cFilBol 		:= aRegRest[01]	//  ZB1->ZB1_FILIAL	//ARRAY
Local cBanco  		:= aRegRest[02]	// 	ZB1_BANCO 	ARRAY
Local cAgencia 		:= aRegRest[03]	//		ZB1_AGENCI	ARRAY
Local cConta 		:= aRegRest[04]	//		ZB1_CONTA	ARRAY
Local cSubConta 	:= aRegRest[05]	//		ZP1_SUBCON	ARRAY
Local dVencto 		:= aRegRest[06]	//  	ZB1_VENCTO  	ARRAY
Local dDataDoc 		:= aRegRest[07]	// 		ZB1_DTDOC	ARRAY
Local cNumDoc 		:= aRegRest[08]	// 		ZB1_NUMDOC	ARRAY
Local cEspDoc 		:= aRegRest[09]	//		ZB1_ESPDOC	ARRAY  DM
Local cAceite 		:= aRegRest[10]	//		ZB1_ACEITE	ARRAY  N
Local cNossoNum 	:= aRegRest[11]	//		ZB1_NOSSON	ARRAY  - &(oBol:getValue("ZB1_CONVEN"))+Right(oBol:GetNumeroBanco(), 10)                                                                                                                                                                                                                                                                                                                                                                                                                                                     
Local cCarteira 	:= aRegRest[12]	//		ZB1_CARTEI	ARRAY
Local nValdoc 		:= aRegRest[13]	//		ZB1_VLDOC	ARRAY	
Local nDescAbat 	:= aRegRest[14]	//		ZB1_DESABA	ARRAY
Local nOutrasDed 	:= aRegRest[15]	//		ZB1_OUTDED	ARRAY
Local nMoraMulta 	:= aRegRest[16]	// 		ZB1_MORMUL	ARRAY
Local nOutrosAcre 	:= aRegRest[17]	//		ZB1_OUTACR	ARRAY
Local cConvenio 	:= aRegRest[18]	//		ZB1_CONVEN
Local cCodBarras 	:= aRegRest[19]		
Local cPrefixo		:= aRegRest[20]
Local cTitulo		:= aRegRest[21]
Local cParcela		:= aRegRest[22]
Local cTipo			:= aRegRest[23]
Local cErro 		:= aRegRest[24]	
*/
Private cMensagem 	:= ""
Private cBarras		:= ""
Private PrivateErro := 0
Private PrivateOk 	:= 0

cMensagem 			:= ""
cBarras				:= ""

// FILIAL PREFIXO NUM PARCELA TIPO

if lAll // Envia todos
	cQuery := " SELECT ZPI.R_E_C_N_O_ ZPIREC   " 										+ CRLF
	cQuery += "    FROM ZPI020 ZPI "													+ CRLF
	cQuery += " WHERE ZPI.ZPI_DTREG = ' ' AND ZPI.ZPI_DTBAIX = ' '"						+ CRLF  
	cQuery += " AND ZPI.D_E_L_E_T_ = ' ' "							 					+ CRLF
   	 
	IIf(Select("TRBLE")>0,TRBLE->(dbCloseArea()),.T.)
	dbUseArea(.F.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),"TRBLE",.T.,.T.)
	dbSelectArea("TRBLE")
	Count To _nConta
	If _nConta = 0
		return(.F.)
	ENDIF 
	dbSelectArea("TRBLE")     
	TRBLE->(dbGoTop())
	
	ProcRegua(_nConta)
	nX 	:= 0

	nCt	:= 0
	lJob := .F.	
	nOk	:= 0
	nErro := 0
	DO WHILE !TRBLE->(EOF())

		IncProc("Processando " + " Registro : " + TRIM(STR(nX++)) + " / " + TRIM(STR(_nConta))  )
		
		nRecZPI := TRBLE->ZPIREC
		dbSelectArea("ZPI")
		ZPI->(dbGoTo(nRecZPI))

		cFilBol 	:= ZPI->ZPI_FILIAL
		cPrefixo 	:= ZPI->ZPI_PREFIX
		cTitulo		:= ZPI->ZPI_NUM
		cParcela	:= ZPI->ZPI_PARC
		cTipo		:= ZPI->ZPI_TIPO
		cBanco		:= ZPI->ZPI_BANCO
		cAgencia	:= ZPI->ZPI_AGEN
		cConta		:= ZPI->ZPI_CONTA
		cSubConta	:= ZPI->ZPI_SUBCON
		/*
		dbSelectArea("SE1")
		SE1->( dbSetOrder( 1 ) )
		if !(SE1->( DbSeek( cFilBol + cPrefixo + cTitulo + cParcela + cTipo )))
   			return(.F.)
		endif    

		cChaveZPI := SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO

   		// Posiciona no cliente
		dbSelectArea("SA1")
		MsSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA)
		cPagador	:= SA1->A1_NOME
		if len(alltrim(SA1->A1_CGC)) = 14 
			cTpoInsPaga		:= "2"				//	0251	S	1 ou 2
		Else
			cTpoInsPaga		:= "1"				//	0251	S	1 ou 2
		ENDIF   		
		cNroInsPaga			:= alltrim(SA1->A1_CGC)
		cNomePaga			:= alltrim(SA1->A1_NOME)	//	0253	S	“Odorico Paraguassu”	
		cEndePaga			:= alltrim(SA1->A1_END)	//	0254	S	“Avenida Dias Gomes 1970”	
		cCEPPaga			:= alltrim(SA1->A1_CEP) 		//	0255	S	77458000	
		cCidPaga			:= alltrim(SA1->A1_MUN)		//	0256	S	“Sucupira”	
		cBairPaga			:= alltrim(SA1->A1_BAIRRO)	//	0257	S	“Centro”	
		cUFPaga				:= alltrim(SA1->A1_EST)	//	0258	S	"PARA"	
		cFonePaga			:= alltrim(SA1->A1_DDD) + "-" + alltrim(SA1->A1_TEL)	//	0259		“63987654321”	
		cReduzido			:= alltrim(SA1->A1_NREDUZ)
		cTpoInsFina			:= cTpoInsPaga	//	0261		1 ou 2	
		cNroInsFina			:= cNroInsPaga	//	0262		66779051870 (PF) ou 98959112000179 (PJ)	
		cNomeFina			:= cNomePaga	//	0263		“Dirceu Borboleta”	oJson["code"]
		*/
		cMensagem	:= "Erro de Processamento"

//		aZPI 		:= ZPI->(GETAREA())
//		aTRBLE 		:= TRBLE->(GETAREA())

		Processa( {|| ;
			cMensagem := GravaBancos( cPrefixo, cTitulo, cParcela, cTipo , cFilBol, cBanco, cAgencia, cConta, cSubConta, @cMensagem, @cBarras );
			}, "Atencao", "Registrando Cobrancas...", .F.)
	
		if "ERRO" $ UPPER(cMensagem)
			nErro++	
		else 
			nOk++
		endif 
//		TRBLE->(RESTAREA(aTRBLE))
		RESTAREA(aArea)

		dÇbSelectArea("TRBLE")     
		TRBLE->(DbSkip())

	ENDDO
endif 

RestArea(aArea) 

cRetorno := "Status de Transmissao em Lote - Erros: " + str(PrivateErro) + " - Sucesso: " + str(PrivateOk)

Return( cRetorno )

//**************************************

Static Function GravaBancos( cPrefixo, cTitulo, cParcela, cTipo , cFilBol, cBanco, cAgencia, cConta, cSubConta, cMensagem, cBarras )

Local aArea	:= GETAREA()

        IF cBanco == "001" .AND. cSubConta == "API"
			cMensagem := u_BBBOLCOBR( cPrefixo, cTitulo, cParcela, cTipo , cFilBol, cBanco, cAgencia, cConta, cSubConta, @cMensagem, @cBarras )
		ELSEIF cBanco == "341" .AND. cSubConta == "API"
			cMensagem := u_ITAUBOLCOBR( cPrefixo, cTitulo, cParcela, cTipo , cFilBol, cBanco    , cAgencia , cConta    , cSubConta  , @cMensagem, @cBarras )
			               //ITAUBOLCOBR( cPrefixo, cTitulo, cParcela, cTipo , cFilBol, pZPI_BANCO, pZPI_AGEN, pZPI_CONTA, pZPI_SUBCON, cMensagem , cBarras  )
		ELSE 

			cMensagem := "Erro Banco Invalido! " + cBanco + " - SubConta: " + cSubConta
			MSGALERT("A Rotina de Registro de Cobrança Retornou: " + cMensagem )
			cRet := "Erro"
		ENDIF 
		if "Erro" $ cMensagem
			PrivateErro++
		else 
			PrivateOk++
		endif 		 


RestArea(aArea)

cMensagem := "Erros = " + alltrim(str(PrivateErro)) + " - Ok = " + alltrim(str(PrivateOk))
//	MSGALERT("A Rotina de Registro de Cobrança Retornou: " + cRetorno )

// retorna erro ou status de OK.
return cMensagem
//*****************************************************************************************************
// ROTINA DE REMESSA DE BOLETOS VIA REST PARA O BANCO DO BRASIL
//*****************************************************************************************************
user Function BBBOLCOBR( pcPrefixo, pcTitulo, pcParcela, pcTipo , pFilBol, pZPI_BANCO, pZPI_AGEN, pZPI_CONTA, pZPI_SUBCON, cMensagem, cBarras  )

Local aHeader 		as array
Local cResource 	as char
Local cURI 			as char
Local cHeadRet 		:= ""
Local sPostRet 		:= ""
Local cQuery 		:= ""	

Local cBanco		:= pZPI_BANCO
Local cAgencia		:= PZPI_AGEN
Local cConta		:= PZPI_CONTA
Local cSubConta		:= PZPI_SUBCON
Local cFilBol		:= pFilBol

Local cURLBTH		:= AllTrim( GetMV("AP_URLBTH") )	// URL BBRASIL TOKEN HOMOLOGACAO
Local cURLBTP		:= AllTrim( GetMV("AP_URLBTP") )	// URL BBRASIL TOKEN PRODUCAO
Local cURLBRH		:= AllTrim( GetMV("AP_URLBRH") )	// URL BBRASIL REQUISICAO HOMOLOGACAO
Local cURLBRP		:= AllTrim( GetMV("AP_URLBRP") )	// URL BBRASIL REQUISICAO PRODUCAO
Local cAPIAMB		:= AllTrim( GetMV("AP_APBAMB") )	// AMBIENTE 1- HOMOLOGACAO - 2 PRODUCAO


// 
// Em Ambiente de Teste, o primeiro item disponibilizado, o “developer_application_key”, 
// deve ser informado como parâmetro gw-dev-app-key nas APIs. (ex: api.sandbox.bb.com.br/api/v2/recurso?gw-dev-app-key)
// developer_application_key := "d27b977903ffab701360e17d00050f56b9e1a5b0"
Local cKey			as Char
Local cRet			:= ""
Local cCLIDHM		:= "" // SEE->SEE_CLIDHM  // ClientID Homologacao	 
Local cCLIDPR		:= "" // SEE->SEE_CLIDPR	// ClientID Producao	 
Local cCLSEHM		:= "" // SEE->SEE_CLSEHM  // ClientSecret Homologacao
Local cCLSEPR		:= "" // SEE->SEE_CLSEPR	// ClientSecret Producao
Local cCHKEYH		:= "" // SEE->SEE_CHKEYH	// CLIDHM	// Chave Key para API
Local cCHKEYP		:= "" // SEE->SEE_CHKEYP	// Chave Key para API


// FILIAL, COD AGENCIA CONTA SUBCONTA
/*
// precisa criar os campos na producao
dbSelectArea("SEE")
SEE->(dbSelectArea("SEE"))
if !( SEE->( dbSeek( cFilBol + cBanco + cAgencia + cConta + cSubConta ) ) )
	return .F.
endif 	
cCLIDHM		:= SEE->EE_CLIDHM  // ClientID Homologacao	 
cCLIDPR		:= SEE->EE_CLIDPR	// ClientID Producao	 
cCLSEHM		:= SEE->EE_CLSEHM  // ClientSecret Homologacao
cCLSEPR		:= SEE->EE_CLSEPR	// ClientSecret Producao
cCHKEYH		:= SEE->EE_CHKEYH	// CLIDHM	// Chave Key para API
cCHKEYP		:= SEE->EE_CHKEYP	// Chave Key para API
*/
// Credenciais OAuth
// PRODUCAO

// BASIC UTILIZADA SOMENTE NO TOKEN
Local cBasic	:= "Basic ZXlKcFpDSTZJbVkyWVRWbU1qY3RaR1V5TkMwME1Ea2lMQ0pqYjJScFoyOVFkV0pzYVdOaFpHOXlJam93TENKamIyUnBaMjlUYjJaMGQyRnlaU0k2TVRReE16RXNJbk5sY1hWbGJtTnBZV3hKYm5OMFlXeGhZMkZ2SWpveGZROmV5SnBaQ0k2SWlJc0ltTnZaR2xuYjFCMVlteHBZMkZrYjNJaU9qQXNJbU52WkdsbmIxTnZablIzWVhKbElqb3hOREV6TVN3aWMyVnhkV1Z1WTJsaGJFbHVjM1JoYkdGallXOGlPakVzSW5ObGNYVmxibU5wWVd4RGNtVmtaVzVqYVdGc0lqb3hMQ0poYldKcFpXNTBaU0k2SW5CeWIyUjFZMkZ2SWl3aWFXRjBJam94TmpJeE1qY3hPREE0T0RBNWZR"

// HOMOLOGACAO
//Local cBasicHom	:= "Basic ZXlKcFpDSTZJakk1T0RrNFpESXRaV0UyTkMwME5HWXhMU0lzSW1OdlpHbG5iMUIxWW14cFkyRmtiM0lpT2pBc0ltTnZaR2xuYjFOdlpuUjNZWEpsSWpveE5Ea3dNQ3dpYzJWeGRXVnVZMmxoYkVsdWMzUmhiR0ZqWVc4aU9qRjk6ZXlKcFpDSTZJakV4WVRFaUxDSmpiMlJwWjI5UWRXSnNhV05oWkc5eUlqb3dMQ0pqYjJScFoyOVRiMlowZDJGeVpTSTZNVFE1TURBc0luTmxjWFZsYm1OcFlXeEpibk4wWVd4aFkyRnZJam94TENKelpYRjFaVzVqYVdGc1EzSmxaR1Z1WTJsaGJDSTZNU3dpWVcxaWFXVnVkR1VpT2lKb2IyMXZiRzluWVdOaGJ5SXNJbWxoZENJNk1UWXhPRFE1TVRRME1UazVPWDA="

// KEY HOMOLOGAÇÃO
//cKeyHom			:= "d27b977903ffab701360e17d00050f56b9e1a5b0"

// Key PRODUCAO



IF EMPTY( cAPIAMB )
	cAPIAMB 		:= "1"
ENDIF 

//  VERSOES DE LAYOUT V1 DIFERENT DE V2 - V2 INSTAVEL SE OPTAR POR V1 Swagger com nova estrutura 
cResource 			:= "/boletos" 


IF cAPIAMB == "1"

	//cKeyHom			:= "d27b977903ffab701360e17d00050f56b9e1a5b0"
	cKey			:= cCHKEYH 
	if empty(cKey)
		cKey		:= "d27b977903ffab701360e17d00050f56b9e1a5b0"
	endif 	

	cClIENTid 		:= cCLIDHM
	cClIENTSecret	:= cCLSEHM	

	// HOMOLOGACAO
	IF EMPTY(cURLBRH)
		cURI := "https://api.hm.bb.com.br/cobrancas/v1/boletos?gw-dev-app-key=" + cKey		
	ELSE 
		cURI := ALLTRIM(cURLBRH) + cKey
	ENDIF 


ELSE

	//cKeyHom	:= "d27b977903ffab701360e17d00050f56b9e1a5b0"
	//cKey		:= cCHKEYP
	cKey		:= "7091a08b05ffbed01360e18120050756b961a5b0"
	if empty(cKey)
		//cKey				:= "7091a08b05ffbed01360e18120050756b961a5b0"
		cKey	:=	"7091a08b05ffbed01360e18120050756b961a5b0"
	endif 	


	cClIENTid 		:= cCLIDPR
	cClIENTSecret	:= cCLSEPR	

	IF EMPTY(cURLBRP)
		cURI := "https://api.bb.com.br/cobrancas/v2/boletos?gw-dev-app-key=" + cKey
	ELSE 
		cURI := ALLTRIM(cURLBRP) + cKey		
	ENDIF 

ENDIF 	
		 
// 
//cURI 				:= "https://api.sandbox.bb.com.br/cobrancas/v1/boletos?gw-dev-app-key=" + cKey""
// URL - ENDPOINT PRODUCAO
// cURI 				:= "https://api.bb.com.br/cobrancas/v2/boletos?gw-dev-app-key=" + cKey"
// URL - ENDPOINT HOMOLOGACAO
//cURI 				:= "https://api.hm.bb.com.br/cobrancas/v1/boletos?gw-dev-app-key=" + cKey"

//cURI 				:= "https://api.sandbox.bb.com.br/cobrancas/v2//boletos?gw-dev-app-key=" + cKey"
//cURI 				:= "https://api.hm.bb.com.br/cobrancas/v2"
// Geracao do TOKE para a Requisicao
jJsonToken			:= u_BBgtoken(cFilBol, cBanco, cAgencia, cConta, cSubConta)
	
// Query oara consulta na tabela de REGISTROS DE BOLETOS SEM REGISTRO DE COBRANCA	
cQuery := " SELECT ZPI.R_E_C_N_O_ RECZPI" 						+ CRLF
cQuery += "  FROM " + RetSqlName("ZPI") + " ZPI "				+ CRLF
cQuery += "  WHERE ZPI.ZPI_FILIAL = '" + cFilBol	 + "'"		+ CRLF
cQuery += "   AND ZPI.ZPI_DTRECE  = ' '	 " 						+ CRLF
cQuery += "   AND ZPI.ZPI_BANCO   = '" + cBanco		 + "'"		+ CRLF
cQuery += "   AND ZPI.ZPI_AGEN    = '" + cAgencia	 + "'"		+ CRLF
cQuery += "   AND ZPI.ZPI_CONTA   = '" + cConta		 + "'"		+ CRLF
cQuery += "   AND ZPI.ZPI_SUBCON  = '" + cSubConta	 + "'"		+ CRLF
cQuery += "   AND ZPI.ZPI_PREFIX  = '" + pcPrefixo   + "'"		+ CRLF
cQuery += "   AND ZPI.ZPI_NUM     = '" + pcTitulo    + "'"		+ CRLF
cQuery += "   AND ZPI.ZPI_PARC    = '" + pcParcela 	 + "'"		+ CRLF
cQuery += "   AND ZPI.D_E_L_E_T_ = ' '"							+ CRLF
cQuery += "  ORDER BY ZPI_IDCNAB "								+ CRLF
	
IIf(Select("TRBBB")>0,TRBBB->(dbCloseArea()),.T.)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),"TRBBB",.T.,.T.)
dbSelectArea("TRBBB")
Count To _nConta
If _nConta <> 1
	return("Erro")
ENDIF 
dbSelectArea("TRBBB")     
TRBBB->(dbGoTop())

nRecno	:= TRBBB->RECZPI

ZPI->( dbSetOrder(1) ) // FILIAL + IDCNAB
dbSelectArea("ZPI")
ZPI->( dbGoTo(nRecno) )


// Configurações do POST para registro de boleto
aHeader := {} 
AAdd(aHeader, "Content-Type: application/json")	
Aadd(aHeader, "Authorization: Bearer "+Escape(jJsonToken["access_token"] ) )
	
cPostParms := BBgetJson()                                                                            //Conteúdo do Parametro

cNumAPI 	:= ""
cLinDig		:= ""
cCodBar  	:= ""
sPostRet 	:= ""
    
sPostRet := HttpPost( cURI ,/*cGetParms*/,cPostParms,/*nTimeOut*/,aHeader,@cHeadRet)


if !empty(sPostRet)
	oObjRet	:= nil
	FWJsonDeserialize( sPostRet, @oObjRet ) 

	// GRava campo Status na ZPI
	If  (" 200 " $ cHeadRet ) .OR. (" 201 " $ cHeadRet )

		cMensagem := 'Transmissao OK' 

		dbSelectArea("ZPI")
		RecLock( "ZPI" ,.F.)
		ZPI->ZPI_DTREME := Date()
		
		ZPI->ZPI_STREME	:= cMensagem

		ZPI->(DbUnlock())
		ZPI->(DbCommit())
		cRet := "Ok"

		if  'codigoBarraNumerico' $ sPostRet	

			cType := valtype(oObjRet:numero )
			if cType == "C"
				/*
					"numero": "00029960290000002471",
    				"numeroCarteira": 17,
    				"numeroVariacaoCarteira": 19,
    				"codigoCliente": 203405050,
    				"linhaDigitavel": "00190000090299602900100002471175586670000000100",
    				"codigoBarraNumerico": "00195866700000001000000002996029000000247117",
    				"numeroContratoCobranca": 19398035,
				*/
				cNumAPI  := oObjRet:numero
				cLinDig  := oObjRet:LinhaDigitavel
				cCodBar  := oObjRet:codigoBarraNumerico
				dbSelectArea("ZPI")
				RecLock( "ZPI" ,.F.)
				ZPI->ZPI_STREME	:= cMensagem
				ZPI->ZPI_DTREG	:= DATE()
				ZPI->ZPI_RETORN := sPostRet
				ZPI->ZPI_NRORET := cNumAPI 
				ZPI->ZPI_LINDIG	:= cLinDig
				ZPI->ZPI_CODBAR	:= cCodBar
				
				ZPI->(DbUnlock())
				ZPI->(DbCommit())
			endif 
			
			cRet := "Ok"
			
			cBarras	  := cCodBar
		else
			dbSelectArea("ZPI")
			RecLock( "ZPI" ,.F.)
			ZPI->ZPI_DTREME	:= Date()
			ZPI->ZPI_HRREME	:= Time() 
			
			ZPI->ZPI_RETORN := sPostRet
			ZPI->(DbUnlock())
			ZPI->(DbCommit())
		endif 
		
		dbSelectArea("SE1")
		SE1->( dbSetOrder( 1 ) )
		if SE1->( DbSeek( cFilBol + pcPrefixo + pcTitulo + pcParcela + pcTipo ))
			RecLock( "SE1" ,.F.)
			SE1->E1_ZZNNBCO := strzero(VAL(SE1->E1_NUMBCO),10)
			SE1->E1_LINDIG	:= cLinDig
			SE1->E1_CODBAR	:= cCodBar

			SE1->(DbUnlock())
			SE1->(DbCommit())
		ENDIF
			 	 
	else
		cRet := "Erro"
		
		cMensagem	 := "Retorno com Erros"
		IF 'erro' $ sPostRet 
		
			//cType := valtype(oObjRet:erros[1]:code )
		//	cType := valtype(oObjRet:erros[3]:MESSAGE )
		
		//	if cType == "C"
				//cCodigo  := oObjRet:erros[1]:code
		//		cMensagem	 := oObjRet:erros[3]:MESSAGE
		//	endif 	
		endif 
		
		dbSelectArea("ZPI")
		RecLock( "ZPI" ,.F.)
		ZPI->ZPI_DTREME	:= Date()
		ZPI->ZPI_HRREME	:= Time() 
		ZPI->ZPI_STREME	:= cMensagem
		ZPI->ZPI_RETORN := sPostRet
		ZPI->(DbUnlock())
		ZPI->(DbCommit())
	endif  	

else

	cMensagem	 := "Erro de Execucao do POST"
	cRet := "Erro"

ENDIF


TRBBB->( DBCloseArea() )
	
return cMensagem

//*****************************************************************************************************
// FUNCAO PARA GERACAO DE TOKEN PARA PAUTENTICAÇÃO 
// TOKEM DO BANCO DO BRASIL
//*****************************************************************************************************

user Function BBgtoken(cFilBol, cBanco, cAgencia, cConta, cSubConta)

local cUrl as char
local cPostParms as char
local aHeadStr :={}//as array
local cHeaderGet as char
local cRetPost as char

Local cURLBTH		:= AllTrim( GetMV("AP_URLBTH") )	// URL BBRASIL TOKEN HOMOLOGACAO
Local cURLBTP		:= AllTrim( GetMV("AP_URLBTP") )	// URL BBRASIL TOKEN PRODUCAO
Local cAPBAMB		:= AllTrim( GetMV("AP_APBAMB") )	// AMBIENTE 1- HOMOLOGACAO - 2 PRODUCAO
// 
// Em Ambiente de Teste, o primeiro item disponibilizado, o “developer_application_key”, 
// deve ser informado como parâmetro gw-dev-app-key nas APIs. (ex: api.sandbox.bb.com.br/api/v2/recurso?gw-dev-app-key)
// developer_application_key := "d27b977903ffab701360e17d00050f56b9e1a5b0"
Local cKey			as Char
Local cRet			:= ""

Local cCLIDHM		:= "" // SEE->SEE_CLIDHM  // ClientID Homologacao	 
Local cCLIDPR		:= "" // SEE->SEE_CLIDPR	// ClientID Producao	 
Local cCLSEHM		:= "" // SEE->SEE_CLSEHM  // ClientSecret Homologacao
Local cCLSEPR		:= "" // SEE->SEE_CLSEPR	// ClientSecret Producao
Local cHKEYHM		:= "" // SEE->SEE_CHKEYH	// CLIDHM	// Chave Key para API
Local cHKEYPR		:= "" // SEE->SEE_CHKEYP	// Chave Key para API


// FILIAL, COD AGENCIA CONTA SUBCONTA
/*
// incluir campos na producao
dbSelectArea("SEE")
SEE->(dbSetOrder(1))
if !SEE->(dbSeek( cFilBol + cBanco + cAgencia + cConta + cSubConta ) )
	return .F.
endif 	

cCLIDHM		:= SEE->EE_CLIDHM  		// ClientID Homologacao	 
cCLIDPR		:= SEE->EE_CLIDPR		// ClientID Producao	 
cCLSEHM		:= SEE->EE_CLSEHM  		// ClientSecret Homologacao
cCLSEPR		:= SEE->EE_CLSEPR		// ClientSecret Producao
cCHKEYH		:= SEE->EE_CHKEYH		// CLIDHM	// Chave Key para API
cCHKEYP		:= SEE->EE_CHKEYP		// Chave Key para API
*/
// Credenciais OAuth
// PRODUCAO

// BASIC UTILIZADA SOMENTE NO TOKEN
// Local cBasic	:= "Basic ZXlKcFpDSTZJbVkyWVRWbU1qY3RaR1V5TkMwME1Ea2lMQ0pqYjJScFoyOVFkV0pzYVdOaFpHOXlJam93TENKamIyUnBaMjlUYjJaMGQyRnlaU0k2TVRReE16RXNJbk5sY1hWbGJtTnBZV3hKYm5OMFlXeGhZMkZ2SWpveGZROmV5SnBaQ0k2SWlJc0ltTnZaR2xuYjFCMVlteHBZMkZrYjNJaU9qQXNJbU52WkdsbmIxTnZablIzWVhKbElqb3hOREV6TVN3aWMyVnhkV1Z1WTJsaGJFbHVjM1JoYkdGallXOGlPakVzSW5ObGNYVmxibU5wWVd4RGNtVmtaVzVqYVdGc0lqb3hMQ0poYldKcFpXNTBaU0k2SW5CeWIyUjFZMkZ2SWl3aWFXRjBJam94TmpJeE1qY3hPREE0T0RBNWZR"

// HOMOLOGACAO
// Local cBasicHom	:= "Basic ZXlKcFpDSTZJakk1T0RrNFpESXRaV0UyTkMwME5HWXhMU0lzSW1OdlpHbG5iMUIxWW14cFkyRmtiM0lpT2pBc0ltTnZaR2xuYjFOdlpuUjNZWEpsSWpveE5Ea3dNQ3dpYzJWeGRXVnVZMmxoYkVsdWMzUmhiR0ZqWVc4aU9qRjk6ZXlKcFpDSTZJakV4WVRFaUxDSmpiMlJwWjI5UWRXSnNhV05oWkc5eUlqb3dMQ0pqYjJScFoyOVRiMlowZDJGeVpTSTZNVFE1TURBc0luTmxjWFZsYm1OcFlXeEpibk4wWVd4aFkyRnZJam94TENKelpYRjFaVzVqYVdGc1EzSmxaR1Z1WTJsaGJDSTZNU3dpWVcxaWFXVnVkR1VpT2lKb2IyMXZiRzluWVdOaGJ5SXNJbWxoZENJNk1UWXhPRFE1TVRRME1UazVPWDA="

// KEY HOMOLOGAÇÃO
//cKeyHom			:= "d27b977903ffab701360e17d00050f56b9e1a5b0"

// Key PRODUCAO

IF EMPTY( cAPBAMB )
	cAPIAMB 		:= "1"  // 1 - HOMOLOGACAO - 2 -  0,PRODUCAO
ENDIF 

//cKey				:= "7091a08b05ffbed01360e18120050756b961a5b0"
//  VERSOES DE LAYOUT V1 DIFERENT DE V2 - V2 INSTAVEL SE OPTAR POR V1 Swagger com nova estrutura 
cResource 			:= "/boletos" 
// homologacao
// cUrl := "https://oauth.hm.bb.com.br/oauth/token"

// producao
// cUrl := "https://oauth.bb.com.br/oauth/token"
		//"https://oauth.hm.bb.com.br/oauth/token 
//cUrl := "https://oauth.sandbox.bb.com.br/oauth/token"


IF cAPBAMB == "1"

	//cKeyHom			:= "d27b977903ffab701360e17d00050f56b9e1a5b0"
	// cKey			:= cCHKEYH 
	cClIENTid 		:= cCLIDHM
	cClIENTSecret	:= cCLSEHM	
	cKey			:= "d27b977903ffab701360e17d00050f56b9e1a5b0"
	if empty(cKey)
		cKey		:= "d27b977903ffab701360e17d00050f56b9e1a5b0"
	endif 	

	// HOMOLOGACAO
	IF EMPTY(cURLBTH)
		cURI := "https://oauth.hm.bb.com.br/oauth/token"
	ELSE 
		cURI := ALLTRIM(cURLBTH)
	ENDIF 


ELSE

	//cKeyHom			:= "d27b977903ffab701360e17d00050f56b9e1a5b0"
	
	cClIENTid 		:= cCLIDPR
	cClIENTSecret	:= cCLSEPR	

	//cKey			:= cCHKEYp 
	cKey			:= "7091a08b05ffbed01360e18120050756b961a5b0"
	if empty(cKey)
		cKey		:= "7091a08b05ffbed01360e18120050756b961a5b0"
	endif 	
	
	IF EMPTY(cURLBTP)
		cURI := "https://oauth.bb.com.br/oauth/token" 
	ELSE 
		cURI := ALLTRIM(cURLBTP)
	ENDIF 

ENDIF 	

//  VERSOES DE LAYOUT V1 DIFERENT DE V2 - V2 INSTAVEL SE OPTAR POR V1 Swagger com nova estrutura 
cResource 			:= "/boletos" 

// Credenciais OAuth
// PRODUCAO

// BASIC UTILIZADA SOMENTE NO TOKEN
// Local cBasic	:= "Basic ZXlKcFpDSTZJbVkyWVRWbU1qY3RaR1V5TkMwME1Ea2lMQ0pqYjJScFoyOVFkV0pzYVdOaFpHOXlJam93TENKamIyUnBaMjlUYjJaMGQyRnlaU0k2TVRReE16RXNJbk5sY1hWbGJtTnBZV3hKYm5OMFlXeGhZMkZ2SWpveGZROmV5SnBaQ0k2SWlJc0ltTnZaR2xuYjFCMVlteHBZMkZrYjNJaU9qQXNJbU52WkdsbmIxTnZablIzWVhKbElqb3hOREV6TVN3aWMyVnhkV1Z1WTJsaGJFbHVjM1JoYkdGallXOGlPakVzSW5ObGNYVmxibU5wWVd4RGNtVmtaVzVqYVdGc0lqb3hMQ0poYldKcFpXNTBaU0k2SW5CeWIyUjFZMkZ2SWl3aWFXRjBJam94TmpJeE1qY3hPREE0T0RBNWZR"
cClIENTid := "Basic ZXlKcFpDSTZJbVkyWVRWbU1qY3RaR1V5TkMwME1Ea2lMQ0pqYjJScFoyOVFkV0pzYVdOaFpHOXlJam93TENKamIyUnBaMjlUYjJaMGQyRnlaU0k2TVRReE16RXNJbk5sY1hWbGJtTnBZV3hKYm5OMFlXeGhZMkZ2SWpveGZROmV5SnBaQ0k2SWlJc0ltTnZaR2xuYjFCMVlteHBZMkZrYjNJaU9qQXNJbU52WkdsbmIxTnZablIzWVhKbElqb3hOREV6TVN3aWMyVnhkV1Z1WTJsaGJFbHVjM1JoYkdGallXOGlPakVzSW5ObGNYVmxibU5wWVd4RGNtVmtaVzVqYVdGc0lqb3hMQ0poYldKcFpXNTBaU0k2SW5CeWIyUjFZMkZ2SWl3aWFXRjBJam94TmpJeE1qY3hPREE0T0RBNWZR"
// HOMOLOGACAO
//Local cBasicHom	:= "Basic ZXlKcFpDSTZJakk1T0RrNFpESXRaV0UyTkMwME5HWXhMU0lzSW1OdlpHbG5iMUIxWW14cFkyRmtiM0lpT2pBc0ltTnZaR2xuYjFOdlpuUjNZWEpsSWpveE5Ea3dNQ3dpYzJWeGRXVnVZMmxoYkVsdWMzUmhiR0ZqWVc4aU9qRjk6ZXlKcFpDSTZJakV4WVRFaUxDSmpiMlJwWjI5UWRXSnNhV05oWkc5eUlqb3dMQ0pqYjJScFoyOVRiMlowZDJGeVpTSTZNVFE1TURBc0luTmxjWFZsYm1OcFlXeEpibk4wWVd4aFkyRnZJam94TENKelpYRjFaVzVqYVdGc1EzSmxaR1Z1WTJsaGJDSTZNU3dpWVcxaWFXVnVkR1VpT2lKb2IyMXZiRzluWVdOaGJ5SXNJbWxoZENJNk1UWXhPRFE1TVRRME1UazVPWDA="

// KEY HOMOLOGAÇÃO
//cKeyHom			:= "d27b977903ffab701360e17d00050f56b9e1a5b0"

// homologacao
//Aadd(aHeadStr, "Authorization: Basic ZXlKcFpDSTZJakk1T0RrNFpESXRaV0UyTkMwME5HWXhMU0lzSW1OdlpHbG5iMUIxWW14cFkyRmtiM0lpT2pBc0ltTnZaR2xuYjFOdlpuUjNZWEpsSWpveE5Ea3dNQ3dpYzJWeGRXVnVZMmxoYkVsdWMzUmhiR0ZqWVc4aU9qRjk6ZXlKcFpDSTZJakV4WVRFaUxDSmpiMlJwWjI5UWRXSnNhV05oWkc5eUlqb3dMQ0pqYjJScFoyOVRiMlowZDJGeVpTSTZNVFE1TURBc0luTmxjWFZsYm1OcFlXeEpibk4wWVd4aFkyRnZJam94TENKelpYRjFaVzVqYVdGc1EzSmxaR1Z1WTJsaGJDSTZNU3dpWVcxaWFXVnVkR1VpT2lKb2IyMXZiRzluWVdOaGJ5SXNJbWxoZENJNk1UWXhPRFE1TVRRME1UazVPWDA=")
// producao
							   
//Aadd(aHeadStr, "Authorization: Basic ZXlKcFpDSTZJakk1T0RrNFpESXRaV0UyTkMwME5HWXhMU0lzSW1OdlpHbG5iMUIxWW14cFkyRmtiM0lpT2pBc0ltTnZaR2xuYjFOdlpuUjNZWEpsSWpveE5Ea3dNQ3dpYzJWeGRXVnVZMmxoYkVsdWMzUmhiR0ZqWVc4aU9qRjk6ZXlKcFpDSTZJakV4WVRFaUxDSmpiMlJwWjI5UWRXSnNhV05oWkc5eUlqb3dMQ0pqYjJScFoyOVRiMlowZDJGeVpTSTZNVFE1TURBc0luTmxjWFZsYm1OcFlXeEpibk4wWVd4aFkyRnZJam94TENKelpYRjFaVzVqYVdGc1EzSmxaR1Z1WTJsaGJDSTZNU3dpWVcxaWFXVnVkR1VpT2lKb2IyMXZiRzluWVdOaGJ5SXNJbWxoZENJNk1UWXhPRFE1TVRRME1UazVPWDA=")
//Aadd(aHeadStr, "Authorization: Basic ZXlKcFpDSTZJbVkyWVRWbU1qY3RaR1V5TkMwME1Ea2lMQ0pqYjJScFoyOVFkV0pzYVdOaFpHOXlJam93TENKamIyUnBaMjlUYjJaMGQyRnlaU0k2TVRReE16RXNJbk5sY1hWbGJtTnBZV3hKYm5OMFlXeGhZMkZ2SWpveGZROmV5SnBaQ0k2SWlJc0ltTnZaR2xuYjFCMVlteHBZMkZrYjNJaU9qQXNJbU52WkdsbmIxTnZablIzWVhKbElqb3hOREV6TVN3aWMyVnhkV1Z1WTJsaGJFbHVjM1JoYkdGallXOGlPakVzSW5ObGNYVmxibU5wWVd4RGNtVmtaVzVqYVdGc0lqb3hMQ0poYldKcFpXNTBaU0k2SW5CeWIyUjFZMkZ2SWl3aWFXRjBJam94TmpJeE1qY3hPREE0T0RBNWZR")
Aadd(aHeadStr, "Authorization: " +  cClIENTid)
Aadd(aHeadStr, "Content-Type: application/x-www-form-urlencoded")

//Body campos
cPostParms := "grant_type=client_credentials"
cPostParms += "&scope=cobrancas.boletos-requisicao cobrancas.boletos-info" // NAO FUNCIONA SEM O "&"
//cPostParms += "&scope=cob.read cob.write"	// ORIENTACAO DO PORTAL DESENV - NÃO FUNCIONA 

//Efetua o POST na API 
cRetPost := HTTPPost(cURI, /*cGetParms*/, cPostParms, /*nTimeOut*/, aHeadStr, @cHeaderGet)

//Exibe o retorno do POST e também o header de retorno
ConOut("Retorno do POST gToken:", cRetPost)
ConOut("Header do POST gToken:", cHeaderGet)

//Transforma o retorno em um JSON
jJsonToken := JsonObject():New()
jJsonToken:FromJson(cRetPost)

//Exibe os dados com base no JSON
Conout("Tipo do token:", jJsonToken["token_type"])
Conout("Token_access gerado:", jJsonToken["access_token"])////Conout("refresh_token gerado:", jJsonToken["refresh_token"])//Conout("id_token gerado:", jJsonToken["id_token"])

return (jJsonToken)

//*****************************************************************************************************
// FUNCAO PARA GERACAO DE JSON DO BRANCO DO BRASIL
// Pega dados da SE1 e monta JSON
//*****************************************************************************************************

Static Function BBGetJson()
    Local cJson   := ""
	/*	
//cJson :='{"numeroConvenio":3128557,"numeroCarteira":17,"numeroVariacaoCarteira":35,"codigoModalidade":1,';
	        '"dataEmissao":"15.12.2020","dataVencimento":"31.03.2021","valorOriginal":123.45,"valorAbatimento":12.34,';
			'"quantidadeDiasProtesto":0,"indicadorAceiteTituloVencido":"N","numeroDiasLimiteRecebimento":0,';
			'"codigoAceite":"A","codigoTipoTitulo":2,"descricaoTipoTitulo":"DM","indicadorPermissaoRecebimentoParcial":"S",';
			'"numeroTituloBeneficiario":"123456","campoUtilizacaoBeneficiario":"UM TEXTO","numeroTituloCliente":"00031285570C",';
			'"mensagemBloquetoOcorrencia":"outro texto","desconto":{ "tipo":0,"dataExpiracao":"30.01.2021","porcentagem":5.00,';
			'"valentia":12.34},"segundodesconto":{ "dataExpiracao":"10.02.2021","porcentagem":5.00,"valentia":12.34},';
			'"terceirodesconto":{ "dataExpiracao":"20.02.2021","porcentagem":5,00,"valentia":12,34},"jurosmora":{"tipo":0,';
			'"porcentagem":1.00 ,"valentia":0.33},"multa":{"tipo":0,"dados":"01.04.2021","porcentagem":2.00,"valentia":10.00},';
			'"pagador":{ "tipoInscricao":2,"numeroInscricao":74910037000193,"nome":"Odorico Paraguassu",';
			'"endereco":"Avenida Dias Gomes 1970","cep":77458000,"cidade":"Sucupira","bairro":"Centro","uf":"PARA",';
			'"telefone":"63987654321"},"beneficiarioFinal":{ "tipoInscricao":2,"numeroInscricao":98959112000179,';
			'"nome":"Dirceu Borboleta"},"quantidadeDiasNegativacao":0,"orgaoNegativador":10,"indicadorPix":"N"}'
*/
	Local nZPI_DESTIP := "0"
	Local dZPI_DESEXP := CTOD("  /  /  ")
	Local nZPI_DESPER := 0
	Local nZPI_DESVAL := 0
	Local dZPI_2DEEXP := CTOD("  /  /  ")
	Local nZPI_2DEPER := 0
	Local nZPI_2DEVAL := 0
	Local dZPI_3DEEXP := CTOD("  /  /  ")
	Local nZPI_3DEPER := 0
	Local nZPI_3DEVAL := 0
	Local nZPI_JURTIP := "0"
	Local nZPI_JURPER := 0
	Local nZPI_JURVAL := 0
	Local nZPI_MULTIP := "0"
	Local dZPI_MULDAD := CTOD("  /  /  ")
	Local nZPI_MULPER := 0
	Local nZPI_MULVAL := 0
	//',"dataEmissao":'							+ '"' + SUBSTR(DTOC(ZPI->ZPI_DTEMIS),1,2) + "." + SUBSTR(DTOC(ZPI->ZPI_DTEMIS),4,2) + "." + SUBSTR(DTOC(ZPI->ZPI_DTEMIS),7,4) + '"' + ;	//	005		S	“15.12.2020”	
	//',"dataVencimento":'						+ '"' + SUBSTR(DTOC(ZPI->ZPI_DTVENC),1,2) + "." + SUBSTR(DTOC(ZPI->ZPI_DTVENC),4,2) + "." + SUBSTR(DTOC(ZPI->ZPI_DTVENC),7,4) + '"' + ;   //	006		S	“31.03.2021”	
		
	cEmissao	:= DTOS(ZPI_DTEMIS)
	cEmissao	:= substr(cEmissao,7,2) + "." + substr(cEmissao, 5,2) + "." + substr(cEmissao,1,4) 
	cVencto     := DTOS(ZPI->ZPI_DTVENC)
	cVencto		:= substr(cVencto,7,2) + "." + substr(cVencto, 5,2) + "." + substr(cVencto,1,4) 		
	cJson :='{' +;
			'"numeroConvenio":' 						+ ALLTRIM(ZPI->ZPI_NROCON) 						+ ;		// 	001 	S	3128557	
			',"numeroCarteira":'						+ ALLTRIM(ZPI->ZPI_NROCAR)						+ ;	// 	002		S	17	
			',"numeroVariacaoCarteira":'				+ '19' + ; //ALLTRIM(ZPI->ZPI_NRVARC)						+ ; // 	003		S	35	
			',"codigoModalidade":'						+ ALLTRIM(ZPI->ZPI_CODMOD) 						+ ; //	004		S	1 ou 4	
			',"dataEmissao":'							+ '"' + cEmissao + 	'"' 						+ ;	//	005		S	“15.12.2020”	
			',"dataVencimento":'						+ '"' + cVencto  + '"' 							+ ;   //	006		S	“31.03.2021”	
			',"valorOriginal":'							+ alltrim(str(ZPI->ZPI_VLRORI,10,2))			+ ;//	007		S	123,45	
			',"valorAbatimento":'	 					+ IIF( ZPI->ZPI_VLRABA = 0,"0", alltrim(str(ZPI->ZPI_VLRABA,10,2)))			+ ;//	008			12,34	
			',"quantidadeDiasProtesto":'	 			+ ALLTRIM(ZPI->ZPI_QTDPRO)						+ ;			//	009			0 
			',"indicadorAceiteTituloVencido":'	 		+ '"' + ALLTRIM(ZPI->ZPI_TITVEN) + '"'			+ ;					//	010			S ou N	
			',"numeroDiasLimiteRecebimento":'	 		+ ALLTRIM(ZPI->ZPI_DIAREC)						+ ;			//	011			0 
			',"codigoAceite":'							+ '"' + ALLTRIM(ZPI->ZPI_CODACE) + '"'			+ ;					//	012		S	A 
			',"codigoTipoTitulo":'						+ ALLTRIM(ZPI->ZPI_TIPTIT)						+ ;			//	013		S	2	 
			',"descricaoTipoTitulo":'	 				+ '"' + ALLTRIM(ZPI->ZPI_DESTPT) + '"'			+ ;					//	014			“DM”	  
			',"indicadorPermissaoRecebimentoParcial":'	+ '"' + ALLTRIM(ZPI->ZPI_RECPAR) + '"'			+ ;	 				//	015		S	S  
			',"numeroTituloBeneficiario":'	 			+ '"' + ALLTRIM(ZPI->ZPI_NRTITB) + '"'			+ ;					//	016			“123456”	 
			',"campoUtilizacaoBeneficiario":'	 		+ '"COBRANCA REST BB"'							+ ;					//	017			“UM TEXTO”	   
			',"numeroTituloCliente":'					+ '"' + ALLTRIM(ZPI->ZPI_TITCLI) + '"'			+ ;					//	018		S	“00031285570000030000”	 
			',"mensagemBloquetoOcorrencia":'	 		+ '"' + ALLTRIM(ZPI->ZPI_BLQOCO) + '"'			+ ;					//	019			“Outro texto”	 
			',"desconto":{'																				+ ;
			'"tipo":'	 								+ nZPI_DESTIP									+ ;		//	0201		0 ou 1 ou 2	 
			',"dataExpiracao":'	 						+ '""'											+ ;
			',"porcentagem":'	 						+ IIF( nZPI_DESPER = 0,"0", alltrim(str(nZPI_DESPER,10,2)))				+ ;//	0203		5,00	
			',"valor":'	    	 						+ IIF( nZPI_DESPER = 0,"0", alltrim(str(nZPI_DESVAL,10,2)))				+ ;//	0204		12,34	
			'}' 																						+ ;
			',"segundoDesconto":{'	 	 																+ ;
			'"dataExpiracao":'	 						+ '""'											+ ;				//	0211		“10/02/2021”	
			',"porcentagem":'	 						+ IIF( nZPI_2DEPER = 0,"0", alltrim(str(nZPI_2DEPER,10,2)))				+ ;//	0212		5,00	
			',"valor":'	 								+ IIF( nZPI_2DEVAL = 0,"0", alltrim(str(nZPI_2DEVAL,10,2)))				+ ;//	0213		12,34	
			'}' 																						+ ;
			',"terceiroDesconto":{'	 	 																+ ;
			'"dataExpiracao":'		 					+ '""'											+ ;				//	0221		“20.02.2021”	
			',"porcentagem":'	 						+ IIF( nZPI_3DEPER = 0,"0", alltrim(str(nZPI_3DEPER,10,2)))				+ ;//	0222		5,00	
			',"valor":' 	 	 						+ IIF( nZPI_3DEVAL = 0,"0", alltrim(str(nZPI_3DEVAL,10,2)))				+ ;//	0223		12,34	
			'}' 																						+ ;
			',"jurosMora":{'	 	 																	+ ;		
			'"tipo":'	 								+ nZPI_JURTIP									+ ;		//	0231		0 ou 1 ou 2 ou 3	
			',"porcentagem":'	 						+ IIF( nZPI_JURPER = 0,"0", alltrim(str(nZPI_JURPER,10,2)))				+ ;//	0232		1,00	
			',"valor":' 	 							+ IIF( nZPI_JURVAL = 0,"0", alltrim(str(nZPI_JURVAL,10,2)))				+ ;//	0233		0,33	
			'}' 																						+ ;
			',"multa":{' 																				+ ;	 	 						
			'"tipo":'	 								+ nZPI_MULTIP									+ ;		//	0241		0 ou 1 ou 2	
			',"dados":'	 								+ '""'											+ ;		//	0242		“01.04.2021”	
			',"porcentagem":'	 						+ IIF( nZPI_MULPER = 0,"0", alltrim(str(nZPI_MULPER,10,2)))				+ ;		//	0243		2,00	
			',"valor":'	 								+ IIF( nZPI_MULVAL = 0,"0", alltrim(str(nZPI_MULVAL,10,2)))				+ ;		//	0244		10,00	
			'}' 																						+ ;
			',"pagador":{'																				+ ;				
			' "tipoInscricao":'							+ ALLTRIM(ZPI->ZPI_PAGTIN)						+ ;			//	0251	S	1 ou 2	
			',"numeroInscricao":'						+ cValToChar(val(ZPI->ZPI_PAGINS))				+ ;			//	0252	S	97965940132 (PF) ou 74910037000193 (PJ)
			',"nome":'									+ '"' + SUBSTR(ALLTRIM(ZPI->ZPI_PAGNOM),1,30) + '"'+ ;					//	0253	S	“Odorico Paraguassu”	
			',"endereco":'								+ '"' + ALLTRIM(STRTRAN(ZPI->ZPI_PAGEND,',','')) + '"'			+ ;					//	0254	S	“Avenida Dias Gomes 1970”	
			',"cep":'									+ ALLTRIM(STRTRAN(ZPI->ZPI_PAGCEP,'-',''))				+ ;					//	0255	S	77458000	
			',"cidade":'								+ '"' + ALLTRIM(ZPI->ZPI_PAGCID) + '"'			+ ;			//	0256	S	“Sucupira”	
			',"bairro":'								+ '"' + ALLTRIM(ZPI->ZPI_PAGBAI) + '"'			+ ;			//	0257	S	“Centro”	
			',"uf":'									+ '"' + ALLTRIM(ZPI->ZPI_PAGUF)	 + '"'			+ ;			//	0258	S	"PARA"	
			',"telefone":'	 							+ '"' + ALLTRIM(STRTRAN(ZPI->ZPI_PAGTEL,'-','')) + '"'+ ;			//	0259		“63987654321”	
			'}' 																						+ ;
			',"beneficiarioFinal":{'																	+ ;	//	026	 	
			' "tipoInscricao":'	 						+ ALLTRIM(ZPI->ZPI_BENTIN)						+ ;	//	0261		1 ou 2	
			',"numeroInscricao":'						+ cValToChar(val(ZPI->ZPI_BENINS))				+ ;	//	0262		66779051870 (PF) ou 98959112000179 (PJ)	
			',"nome":'	 								+ '"' + SUBSTR(ALLTRIM(ZPI->ZPI_BENNOM),1,20) + '"'+ ;	
	'},"indicadorPix":"N"}'

Return ( cJson )


//************************************************************************
// REMESSA DE BOLETOS API REST BANCO ITAU
//************************************************************************
//*****************************************************************************************************
// ROTINA DE REMESSA DE BOLETOS VIA REST PARA O BANCO DO BRASIL
//*****************************************************************************************************
user Function ITAUBOLCOBR( cPrefixo, cTitulo, cParcela, cTipo , cFilBol, pZPI_BANCO, pZPI_AGEN, pZPI_CONTA, pZPI_SUBCON, cDvCta, cMensagem, cBarras  )


Local aHeader 		as array
Local cResource 	as char
Local cURI 			as char
Local cHeadRet 		:= ""
Local sPostRet 		:= ""
Local cQuery 		:= ""	
Local cPostParms 	:= ""
Local jJsonToken	:= Nil 
Local cNomeCedente	:= ""
Local cMensagem 	:= ""
Local cRet 			:= ""
Local cLinDig 		:= ""
Local cCodBar 		:= ""
Local cCNPJ         := ""

Local cBanco		:= pZPI_BANCO
Local cAgencia		:= PZPI_AGEN
Local cConta		:= PZPI_CONTA
Local cSubConta		:= PZPI_SUBCON

Local cURLITH		:= AllTrim( GetMV("AP_URLITH") )	// URL ITAU TOKEN HOMOLOGACAO
Local cURLITP		:= AllTrim( GetMV("AP_URLITP") )	// URL ITAU TOKEN PRODUCAO
Local cURLIRH		:= AllTrim( GetMV("AP_URLIRH") )	// URL ITAU REQUISICAO HOMOLOGACAO
Local cURLIRP		:= AllTrim( GetMV("AP_URLIRP") )	// URL ITAU REQUISICAO PRODUCAO
Local cAPIAMB		:= AllTrim( GetMV("AP_APIAMB") )	// AMBIENTE 1- HOMOLOGACAO - 2 PRODUCAO

Local cKey			as Char
// Credenciais OAuth

Local cKey			as Char
Local cRet			:= ""
Local cCLIDHM		:= "" // SEE->SEE_CLIDHM  // ClientID Homologacao	 
Local cCLIDPR		:= "" // SEE->SEE_CLIDPR	// ClientID Producao	 
Local cCLSEHM		:= "" // SEE->SEE_CLSEHM  // ClientSecret Homologacao
Local cCLSEPR		:= "" // SEE->SEE_CLSEPR	// ClientSecret Producao
Local cCHKEYH		:= "" // SEE->SEE_CHKEYH	// CLIDHM	// Chave Key para API
Local cCHKEYP		:= "" // SEE->SEE_CHKEYP	// Chave Key para API
/*
// FILIAL, COD AGENCIA CONTA SUBCONTA
dbSelectArea("SEE")
SEE->(dbSelectArea("SEE"))
if !(SEE->( dbSeek( cFilBol + cBanco + cAgencia + cConta + cSubConta ) ))
	return .F.
endif 	

cCLIDHM		:= SEE->EE_CLIDHM  // ClientID Homologacao	 
cCLIDPR		:= SEE->EE_CLIDPR	// ClientID Producao	 
cCLSEHM		:= SEE->EE_CLSEHM  // ClientSecret Homologacao
cCLSEPR		:= SEE->EE_CLSEPR	// ClientSecret Producao
cCHKEYH		:= SEE->EE_CHKEYH	// CLIDHM	// Chave Key para API
cCHKEYP		:= SEE->EE_CHKEYP	// Chave Key para API
*/

/*
Carteira 109

Chave Itau Key: 9a6a013b-54df-49a5-bf99-f674761f5775

0652 35198-2
Id Cliente: k3vB20nQ6OTS0
Segredo: vAKnzg1VWJUuxL2iODo6KdQsExGfUVgp7cYsR_jgBMu1PrHlBvBUZoy1K7TrdqqoXiDPzLVM73G4Gm1XZMphOQ2

(6696 22200-6)
Id Cliente: LIQzokHT4HXz0
Segredo: 2HqV2zke-1uLAyIVtsoTLyb63ti172_B3QElmcGgQeIOXQyNYv-cZv5A-Xk2wgxY4f5rHKyUMJI2gt13gGa4YQ2
*/
 
IF EMPTY( cAPIAMB )
	cAPIAMB := "1"
ENDIF 

IF cAPIAMB == "1"
	// HOMOLOGACAO
	cKey			:= cCHKEYH 
	if empty(cKey)
		cKey		:= "4151ec4a-9893-4409-b2e967b0f3017c77"
	endif 	

	cClIENTid 		:= cCLIDHM
	cClIENTSecret	:= cCLSEHM	

	IF EMPTY(cURLIRH)
		// URL - ENDPOINT PRODUCAO // NO MANUAL NÃO ESTÁ DESCRITO UMA URL ESÉCÍFICA PARA HML/PRODUCAO
		cURI := "https://gerador-boletos.itau.com.br/router-gateway-app/public/codigo_barras/registro" 
	ELSE 
		cURI := ALLTRIM(cURLIRH)
	ENDIF 

ELSE

	cKey			:= cCHKEYH 
	if empty(cKey)
		cKey		:= "4151ec4a-9893-4409-b2e967b0f3017c77"
	endif 	

	cClIENTid 		:= cCLIDHM
	cClIENTSecret	:= cCLSEHM	


	IF EMPTY(cURLIRP)
		// URL - ENDPOINT PRODUCAO // NO MANUAL NÃO ESTÁ DESCRITO UMA URL ESÉCÍFICA PARA HML/PRODUCAO
		cURI := "https://gerador-boletos.itau.com.br/router-gateway-app/public/codigo_barras/registro" 
	ELSE 
		cURI := ALLTRIM(cURLIRH)
	ENDIF 

ENDIF 	

Private	cCNPJCedente := ""

/*Itau-chave é um parâmetro que irá no header da requisição a URL da API de geração de 
boleto. Cada parceiro receberá um itau-chave distinto no formato: 
4151ec4a-9893-4409-b2e967b0f3017c77.

Header: 
Accept: application/vnd.itau access_token: Token gerado pelo 
autorizador. 
itau-chave: Token para identificar o parceiro (cada parceiro receberá um 
token). 
identificador: Enviar CNPJ com 14 posições e Formato: 00000000000000. 
Preencher com zeros a esquerda. 
Body: 
Campos de entrada descritos nas outras seções. 
Atenção: no POST do body para geração de boletos, utilizar o Content-Type: RAW
*/

// substituir AQUI Chave do Cliente 



//AAdd(aHeader, "Content-Type: RAW")	
/*
A URL base da API está definida como https://gerador-boletos.itau.com.br/router-gatewayapp/public/codigo_barras/registro.
Todas as requisições devem usar o sc
*/

// Geracao do TOKEN para a Requisicao
jJsonToken := u_Itaugtoken( cBanco, cAgencia, cConta, cSubConta, cFilBol )


// Query oara consulta na tabela de REGISTROS DE BOLETOS SEM REGISTRO DE COBRANCA	
cQuery := " SELECT ZPI.R_E_C_N_O_ RECZPI" 							+ CRLF
cQuery += "  FROM " + RetSqlName("ZPI") + " ZPI "					+ CRLF
cQuery += "  WHERE ZPI.ZPI_FILIAL = '" + cFilBol + "'"				+ CRLF
cQuery += "   AND ZPI.ZPI_STREME  <> 'Transmissao OK' " 			+ CRLF
cQuery += "   AND ZPI.ZPI_BANCO   = '" + cBanco		 	+ "'"		+ CRLF
cQuery += "   AND ZPI.ZPI_AGEN    = '" + cAgencia	 	+ "'"		+ CRLF
cQuery += "   AND ZPI.ZPI_CONTA   = '" + cConta		  	+ "'"		+ CRLF
cQuery += "   AND ZPI.ZPI_SUBCON  = '" + cSubConta	 	+ "'"		+ CRLF
cQuery += "   AND ZPI.ZPI_PREFIX  = '" + cPrefixo   	+ "'"		+ CRLF
cQuery += "   AND ZPI.ZPI_NUM     = '" + cTitulo    	+ "'"		+ CRLF
cQuery += "   AND ZPI.ZPI_PARC    = '" + cParcela 	 	+ "'"		+ CRLF
cQuery += "   AND ZPI.D_E_L_E_T_ = ' '"								+ CRLF
cQuery += "  ORDER BY ZPI_IDCNAB "									+ CRLF
	
IIf(Select("TRBIT")>0,TRBIT->(dbCloseArea()),.T.)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),"TRBIT",.T.,.T.)
dbSelectArea("TRBIT")
Count To _nConta
If _nConta <> 1
	return("Erro")
ENDIF 
dbSelectArea("TRBIT")     
TRBIT->(dbGoTop())

nRecno	:= TRBIT->RECZPI

ZPI->( dbSetOrder(1) ) // FILIAL + IDCNAB
dbSelectArea("ZPI")
ZPI->( dbGoTo(nRecno) )


cNomeCedente		:= SM0->M0_NOMECOM
//cCNPJCedente		:= SM0->M0_CGC
cCNPJCedente		:= "42.463.513/0001-89"
cCNPJCedente		:= StrTran(cCNPJCedente, "/", "")
cCNPJCedente		:= StrTran(cCNPJCedente, "-", "")
cCNPJCedente		:= StrTran(cCNPJCedente, ".", "")
cCNPJCedente		:= StrZero(VAL(cCNPJCedente), 14 )

// Configurações do POST para registro de boleto
aHeader := {} 
Aadd(aHeader, "Accept: application/vnd.itau "+Escape(jJsonToken["access_token"] ) )
Aadd(aHeader, "itau-chave: " + cKey )
Aadd(aHeader, "identificador: " + cCNPJCedente )


cBarras		:= ""	
cPostParms := ""
//cPostParms := "Content-Type: RAW&"
cPostParms += ItaugetJson(cBanco, cAgencia, cConta, cSubConta, cDVcta,cCNPJCedente)                                                                            //Conteúdo do Parametro
    
tRet := HttpPost( cURI ,/*cGetParms*/,cPostParms,/*nTimeOut*/,aHeader,@cHeadRet)


if !empty(sPostRet)
	oObjRet	:= nil
	FWJsonDeserialize( sPostRet, @oObjRet ) 

	// GRava campo Status na ZPI
	If  (" 200 " $ sPostRet ) .OR. (" 201 " $ sPostRet )

		dbSelectArea("SE1")
		SE1->( dbSetOrder( 1 ) )
		if SE1->( DbSeek( cFilBol + pcPrefixo + pcTitulo + pcParcela + pcTipo ))
			RecLock( "SE1" ,.F.)
		
			SE1->E1_ZZNNBCO := strzero(VAL(SE1->E1_NUMBCO),10)
			SE1->(DbUnlock())
			SE1->(DbCommit())
		
		endif    

		dbSelectArea("ZPI")
		RecLock( "ZPI" ,.F.)
		ZPI->ZPI_DTRECE := Date()
		ZPI->ZPI_STREME	:= cMensagem
		ZPI->ZPI_DTREG	:= Date()
		ZPI->(DbUnlock())
		ZPI->(DbCommit())
		cRet := "Ok"

		cMensagem 	:= 'Transmissao OK'
		cRet 		:= "Ok"
		cLinDig 	:= ""
		cCodBar 	:= ""
	
		if  'codigo_barras' $ sPostRet	
		
			cType := valtype(oObjRet:codigo_barras )

			if cType == "C"
				
				cLinDig  := oObjRet:codigo_barras
				cCodBar  := oObjRet:numero_linha_digitavel
			
			endif 	
			
			dbSelectArea("ZPI")
			RecLock( "ZPI" ,.F.)
			ZPI->ZPI_DTREME	:= Date()
			ZPI->ZPI_HRREME	:= Time() 
			ZPI->ZPI_STREME	:= cMensagem
			ZPI->ZPI_LINDIG	:= cLinDig
			ZPI->ZPI_CODBAR	:= cCodBar
			ZPI->ZPI_RETORN := sPostRet
			ZPI->ZPI_DTREG	:= Date()
			ZPI->(DbUnlock())
			ZPI->(DbCommit())
			
			cBarras	  := cCodBar

		endif 

	elseIF 'Erro' $ sPostRet 
		
		cMensagem 	:= ""
		cRet 		:= "Erro"
		cLinDig 	:= ""
		cCodBar 	:= ""

		cType := valtype(oObjRet:erros[1]:mensagem )

		if cType == "C"
	
			cMensagem	 := oObjRet:erros[1]:mensagem

		endif 	
			
		dbSelectArea("ZPI")
		RecLock( "ZPI" ,.F.)
		ZPI->ZPI_DTREME	:= Date()
		ZPI->ZPI_HRREME	:= Time() 
		ZPI->ZPI_STREME	:= cMensagem
		ZPI->ZPI_RETORN := sPostRet
		ZPI->(DbUnlock())
		ZPI->(DbCommit())
		cRet := "Erro"

	else

		cMensagem	 := "Sem Tratamento de Erros"
		cRet := "Erro"
			
	endif

else

	cMensagem	 := "Erro de Execucao do POST"
	cRet := "Erro"

ENDIF 
/*

{ 
 "codigo": "validation_error", 
 "mensagem": "Erro na validacao de campos", 
 "campos": [ 
 { 
 "campo": "cpf", 
 "mensagem": "CPF invalido", 
 "valor": "12345678910" 
 }, 
 { 
 "campo": "finalidade", 
 "mensagem": "O Parametro finalidade e invalido" 
 } 
 ] 
} 
*/

TRBIT->( DBCloseArea() )
	
return cRet

//*****************************************************************************************************
// obtem token do Itau
//*****************************************************************************************************

user Function Itaugtoken( cBanco, cAgencia, cConta, cSubcon, pFilBol )

local cUrl as char
local cPostParms as char
local aHeadStr :={}//as array
local cHeaderGet as char
local cRetPost as char

// INSERIR AS CHAVES FORNECIDAS PELO BANCO
Local clientId 		:= "" 
Local clientSecret 	:= "" 

Local encoding 		:= ""
Local credentials 	:= ""
Local headerValue 	:= ""

Local cZPI_BANCO	:= cBanco
Local cZPI_AGEN		:= cAgencia
Local cZPI_CONTA	:= cConta
Local cZPI_SUBCON	:= cSubcon
Local cFilBol		:= pFilBol

Local cKey			as Char
Local cRet			:= ""
Local cCLIDHM		:= "" // SEE->SEE_CLIDHM  // ClientID Homologacao	 
Local cCLIDPR		:= "" // SEE->SEE_CLIDPR	// ClientID Producao	 
Local cCLSEHM		:= "" // SEE->SEE_CLSEHM  // ClientSecret Homologacao
Local cCLSEPR		:= "" // SEE->SEE_CLSEPR	// ClientSecret Producao
Local cCHKEYH		:= "" // SEE->SEE_CHKEYH	// CLIDHM	// Chave Key para API
Local cCHKEYP		:= "" // SEE->SEE_CHKEYP	// Chave Key para API

Local cURLITH		:= AllTrim( GetMV("AP_URLITH") )	// URL ITAU TOKEN HOMOLOGACAO
Local cURLITP		:= AllTrim( GetMV("AP_URLITP") )	// URL ITAU TOKEN PRODUCAO
Local cURLIRH		:= AllTrim( GetMV("AP_URLIRH") )	// URL ITAU REQUISICAO HOMOLOGACAO
Local cURLIRP		:= AllTrim( GetMV("AP_URLIRP") )	// URL ITAU REQUISICAO PRODUCAO
Local cAPIAMB		:= AllTrim( GetMV("AP_APIAMB") )	// AMBIENTE 1- HOMOLOGACAO - 2 PRODUCAO
/*
// FILIAL, COD AGENCIA CONTA SUBCONTA
dbSelectArea("SEE")
SEE->(dbSelectArea("SEE"))
if !( SEE->( dbSeek( cFilBol + cZPI_BANCO + cZPI_AGEN + cZPI_CONTA + cZPI_SUBCON ) ))
	return .F.
endif 	

cCLIDHM		:= SEE->EE_CLIDHM  // ClientID Homologacao	 
cCLIDPR		:= SEE->EE_CLIDPR	// ClientID Producao	 
cCLSEHM		:= SEE->EE_CLSEHM  // ClientSecret Homologacao
cCLSEPR		:= SEE->EE_CLSEPR	// ClientSecret Producao
cCHKEYH		:= SEE->EE_CHKEYH	// CLIDHM	// Chave Key para API
cCHKEYP		:= SEE->EE_CHKEYP	// Chave Key para API
*/
/*
// DADOS DE HOMOLOGACAO
0652 35198-2
Id Cliente: k3vB20nQ6OTS0
Segredo: vAKnzg1VWJUuxL2iODo6KdQsExGfUVgp7cYsR_jgBMu1PrHlBvBUZoy1K7TrdqqoXiDPzLVM73G4Gm1XZMphOQ2


(6696 22200-6)
Id Cliente: LIQzokHT4HXz0
Segredo: 2HqV2zke-1uLAyIVtsoTLyb63ti172_B3QElmcGgQeIOXQyNYv-cZv5A-Xk2wgxY4f5rHKyUMJI2gt13gGa4YQ2
*/
/*
Para o período de testes BETA, o EndPoint utilizado será: 
 EndPoint https://oauth.itau.com.br/identify/connect/token)
*/
/*
encoding 		:= 'encoding=UTF8' 
credentials 	:= string.Format("{0}:{1}", clientId, clientSecret) 
headerValue 	:= Convert.ToBase64String(encoding.GetBytes(credentials))
*/

IF EMPTY( cAPIAMB )
	cAPIAMB := "1"
ENDIF 

IF cAPIAMB == "1"
	// HOMOLOGACAO
	//cKey			:= cCHKEYH 
	cKey			:= "4151ec4a-9893-4409-b2e967b0f3017c77"
	if empty(cKey)
		cKey		:= "4151ec4a-9893-4409-b2e967b0f3017c77"
	endif 	

	clientId 		:= cCLIDHM
	clientSecret 	:= cCLSEHM	 
	clientId 		:= "k3vB20nQ6OTS0"
	clientSecret 	:= "vAKnzg1VWJUuxL2iODo6KdQsExGfUVgp7cYsR_jgBMu1PrHlBvBUZoy1K7TrdqqoXiDPzLVM73G4Gm1XZMphOQ2"

	IF EMPTY(cURLITH)
		// URL - ENDPOINT PRODUCAO // NO MANUAL NÃO ESTÁ DESCRITO UMA URL ESÉCÍFICA PARA HML/PRODUCAO
		cURI := "https://oauth.itau.com.br/identity/connect/token"

	ELSE 
		cURI := ALLTRIM(cURLITH)
	ENDIF 
 	cURI := "https://oauth.itau.com.br/identity/connect/token"
ELSE

	//cKey			:= cCHKEYP 
	cKey			:= "4151ec4a-9893-4409-b2e967b0f3017c77"
	if empty(cKey)
		cKey		:= "4151ec4a-9893-4409-b2e967b0f3017c77"
	endif 	

	clientId 		:= cCLIDPR
	clientSecret 	:= cCLSEPR	 

	IF EMPTY(cURLITP)
		// URL - ENDPOINT PRODUCAO // NO MANUAL NÃO ESTÁ DESCRITO UMA URL ESÉCÍFICA PARA HML/PRODUCAO
		cURI := "https://autorizador-boletos.itau.com.br"
	ELSE 
		cURI := ALLTRIM(cURLITP)
	ENDIF 

ENDIF 	

//Header: 
//Authorization: Basic headerValue 
//Content-Type: application/x-www-form-urlencoded 
//Body:
//scope: readonly 
//grant_type: client_credentials 
// homologacao
// cUrl := "https://oauth.itau.com.br/identify/connect/token"
// producao
//cUrl := "https://autorizador-boletos.itau.com.br"


Aadd(aHeadStr, "Authorization: Basic headerValue ")
Aadd(aHeadStr, "Content-Type: application/x-www-form-urlencoded")

//Body campos
//cPostParms := "grant_type=client_credentials"
//cPostParms += "&scope=readonly" // NAO FUNCIONA SEM O "&" no bb itau testar
//cPostParms += "&client_id=" + clientId 
//cPostParms += "&client_secret=" + clientSecret

cPostParms := "grant_type=client_credentials"
cPostParms += "&scope=readonly" // NAO FUNCIONA SEM O "&" no bb itau testar
cPostParms += "&client_id=" + clientId 
cPostParms += "&client_secret=" + clientSecret

//Efetua o POST na API 
cRetPost := HTTPPost(cURI, /*cGetParms*/, cPostParms, /*nTimeOut*/, aHeadStr, @cHeaderGet)

//Exibe o retorno do POST e também o header de retorno
ConOut("Retorno do POST gToken:", cRetPost)
ConOut("Header do POST gToken:", cHeaderGet)

//Transforma o retorno em um JSON
jJsonToken := JsonObject():New()
jJsonToken:FromJson(cRetPost)

//Exibe os dados com base no JSON
Conout("Tipo do token:", jJsonToken["token_type"])
Conout("Token_access gerado:", jJsonToken["access_token"])////Conout("refresh_token gerado:", jJsonToken["refresh_token"])//Conout("id_token gerado:", jJsonToken["id_token"])

return (jJsonToken)

// Cria Token para autenticacao
//*****************************************************************************************************
Static Function ItauGetJson(cBanco, cAgencia, cConta, cSubConta, cDVcta, cCNPJCedente )                                                                           //Conteúdo do Parametro

    Local cJson   := ""
	Local nZPI_DESTIP := "0"
	Local dZPI_DESEXP := CTOD("  /  /  ")
	Local nZPI_DESPER := 0
	Local nZPI_DESVAL := 0
	Local dZPI_2DEEXP := CTOD("  /  /  ")
	Local nZPI_2DEPER := 0
	Local nZPI_2DEVAL := 0
	Local dZPI_3DEEXP := CTOD("  /  /  ")
	Local nZPI_3DEPER := 0
	Local nZPI_3DEVAL := 0
	Local nZPI_JURTIP := "0"
	Local nZPI_JURPER := 0
	Local nZPI_JURVAL := 0
	Local nZPI_MULTIP := "0"
	Local dZPI_MULDAD := CTOD("  /  /  ")
	Local nZPI_MULPER := 0
	Local nZPI_MULVAL := 0

	cJson :='{' +;
		'"tipo_ambiente": 1,'												+ ; 
		'"tipo_registro": 1,' 												+ ; 
		'"tipo_cobranca": 1,' 												+ ; 
		'"tipo_produto": "00006",' 											+ ; 
		'"subproduto": "00008",' 											+ ; 
		'"beneficiario": {' 												+ ; 
			'"cpf_cnpj_beneficiario": "' + cCNPJCedente + '"'				+ ; 
			'"agencia_beneficiario": "'  + cAgencia		 + '"'				+ ;
			'"conta_beneficiario":  "'  + cConta		 + '"'				+ ;
			'"digito_verificador_conta_beneficiario": "'  + cDVcta + '"'	+ ;
		'},'																+ ;  
		'"titulo_aceite": "S",' 											+ ; 
		'"pagador": { '														+ ; 
			'"cpf_cnpj_pagador":"' + ALLTRIM(ZPI->ZPI_PAGINS) + '"'		+ ;
			'"nome_pagador": "' + ALLTRIM(ZPI->ZPI_PAGNOM) + '"'			+ ;
			'"logradouro_pagador": "' + ALLTRIM(ZPI->ZPI_PAGEND)	+ '"'	+ ;
			'"cidade_pagador": "' + ALLTRIM(ZPI->ZPI_PAGCID)	+ '"'		+ ;
			'"uf_pagador": "' + ALLTRIM(ZPI->ZPI_PAGUF)		+ '"'			+ ;
			'"cep_pagador": "' + ALLTRIM(ZPI->ZPI_PAGCEP) + '"'			+ ;
		'}, '																+ ; 
		'"tipo_carteira_titulo": "109", '									+ ; 
		'"moeda": { '														+ ; 
			'"codigo_moeda_cnab": "09" '									+ ; 
		'}, '																+ ; 
		'"nosso_numero": "12345678", '										+ ; 
		'"digito_verificador_nosso_numero": "1", '							+ ; 
		'"data_vencimento": ' + '"' + SUBSTR(DTOC(ZPI->ZPI_DTVENC),1,2) + "." + SUBSTR(DTOC(ZPI->ZPI_DTVENC),4,2) + "." + SUBSTR(DTOC(ZPI->ZPI_DTVENC),7,4) + '"' + ;
		'"valor_cobrado":"' + strzero(VAL(str(ZPI->ZPI_VLRORI,17,2)),17)	+ ; //"00000000000015000", '							+ ; 
		'"especie": 01, '													+ ; 
		'"data_emissao": ' + '"' + SUBSTR(DTOC(ZPI->ZPI_DTEMIS),1,2) + "." + SUBSTR(DTOC(ZPI->ZPI_DTEMIS),4,2) + "." + SUBSTR(DTOC(ZPI->ZPI_DTEMIS),7,4) + '"' + ;
		'"tipo_pagamento": 3, '												+ ; 
		'"indicador_pagamento_parcial": "false", '							+ ; 
		'"juros": { '														+ ; 
			'"tipo_juros": 5 '												+ ; 
		'}, '																+ ; 
		'"multa": { '														+ ; 
			'"tipo_multa": 3 '												+ ; 
		'}, '																+ ; 
		'"grupo_desconto": [{ '												+ ; 
			'"tipo_desconto": 0 '											+ ; 
		'}], '																+ ; 
		'"recebimento_divergente": { '										+ ; 
 			'"tipo_autorizacao_recebimento": "1" '							+ ; 
 		'} ' 																+ ; 
	'} '


/*	
cJson :='
{ 
	"tipo_ambiente": 1, 
	"tipo_registro": 1, 
	"tipo_cobranca": 1, 
	"tipo_produto": "00006", 
	"subproduto": "00008", 
	"beneficiario": { 
		"cpf_cnpj_beneficiario": "12345678000100", 
		"agencia_beneficiario": "1500", 
		"conta_beneficiario": "0005206", 
		"digito_verificador_conta_beneficiario": "1" 
	}, 
	"debito": { 
		"agencia_debito": "", 
		"conta_debito": "", 
		"digito_verificador_conta_debito": "" 
	}, 
	"identificador_titulo_empresa": "", 
	"uso_banco": "", 
	"titulo_aceite": "S", 
	"pagador": { 
		"cpf_cnpj_pagador": "000012345678910", 
		"nome_pagador": "PAGADORVIAAPI", 
		"logradouro_pagador": "RUADOPAGADOR", 
		"bairro_pagador": "BAIRRO", 
		"cidade_pagador": "CIDADE", 
		"uf_pagador": "SP", 
		"cep_pagador": "00000000", 
		"grupo_email_pagador": [{ 
									"email_pagador": "" 
								}] 
		}, 
 	"sacador_avalista": { 
		"cpf_cnpj_sacador_avalista": "000012345678900", 
		"nome_sacador_avalista": "SACADORAVALISTA", 
		"logradouro_sacador_avalista": "ENDERECOSACADORAVALISTA", 
		"bairro_sacador_avalista": "BAIRRO", 
		"cidade_sacador_avalista": "CIDADE", 
		"uf_sacador_avalista": "SP", 
		"cep_sacador_avalista": "00000000" 
	}, 
	"tipo_carteira_titulo": "109", 
	"moeda": { 
		"codigo_moeda_cnab": "09", 
		"quantidade_moeda": "" 
	}, 
	"nosso_numero": "12345678", 
	"digito_verificador_nosso_numero": "1", 
	"codigo_barras": "02020202020202020202020202020202020202020202", 
	"data_vencimento": "2016-12-31", 
	"valor_cobrado": "00000000000015000", 
	"seu_numero": "1234567890", 
	"especie": 01, 
	"data_emissao": "2016-11-21", 
	"data_limite_pagamento": "2016-12-31", 
	"tipo_pagamento": 3, 
	"indicador_pagamento_parcial": "false", 
	"quantidade_pagamento_parcial": "0", 
	"quantidade_parcelas": "0", 
	"instrucao_cobranca_1": "", 
	"quantidade_dias_1": "", 
	"data_instrucao_1": "", 
	"instrucao_cobranca_2": "", 
	"quantidade_dias_2": "", 
	"data_instrucao_2": "", 
	"instrucao_cobranca_3": "", 
	"quantidade_dias_3": "", 
	"data_instrucao_3": "", 
	"valor_abatimento": "10", 
	"juros": { 
		"data_juros": "", 
		"tipo_juros": 5, 
		"valor_juros": "", 
		"percentual_juros": "" 
	}, 
	"multa": { 
		"data_multa": "", 
		"tipo_multa": 3, 
		"valor_multa": "", 
		"percentual_multa": "" 
	}, 
	"grupo_desconto": [{ 
		"data_desconto": "2016-10-10", 
		"tipo_desconto": 2, 
		"valor_desconto": "", 
		"percentual_desconto": "10" 
	}], 
	"recebimento_divergente": { 
		"tipo_autorizacao_recebimento": "3", 
		"tipo_valor_percentual_recebimento": "", 
		"valor_minimo_recebimento": "", 
		"percentual_minimo_recebimento": "", 
		"valor_maximo_recebimento": "", 
		"percentual_maximo_recebimento": "" }, 
	"grupo_rateio": [] 
} 

Exemplo reduzido de entrada 

{ 
"tipo_ambiente": 1, 
"tipo_registro": 1, 
"tipo_cobranca": 1, 
"tipo_produto": "00006", 
"subproduto": "00008", 
"beneficiario": { 
		"cpf_cnpj_beneficiario": "12345678000100", 
		"agencia_beneficiario": "1500", 
		"conta_beneficiario": "0005206", 
		"digito_verificador_conta_beneficiario": "1" 
	}, 
	"titulo_aceite": "S", 
	"pagador": { 
		"cpf_cnpj_pagador": "000012345678910", 
		"nome_pagador": "PAGADORVIAAPI", 
		"logradouro_pagador": "RUADOPAGADOR", 
		"cidade_pagador": "CIDADE", 
		"uf_pagador": "SP", 
		"cep_pagador": "00000000" 
	}, 
	"tipo_carteira_titulo": "109", 
	"moeda": { 
		"codigo_moeda_cnab": "09" 
	}, 
	"nosso_numero": "12345678", 
	"digito_verificador_nosso_numero": "1", 
	"data_vencimento": "2016-12-31", 
	"valor_cobrado": "00000000000015000", 
	"especie": 01, 
	"data_emissao": "2016-11-21", 
	"tipo_pagamento": 3, 
	"indicador_pagamento_parcial": "false", 
	"juros": { 
		"tipo_juros": 5 
	}, 
	"multa": { 
		"tipo_multa": 3 
	}, 
	"grupo_desconto": [{ 
		"tipo_desconto": 0 
	}], 
	"recebimento_divergente": { 
 		"tipo_autorizacao_recebimento": "1" 
 	} 
} 
*/


Return ( cJson )

//*****************************************************************************

user Function ConsRecAPI()

return 

user Function BaixaRecAPI()

return 



User Function CONS_Pag(nPosAuto)

local lPanelFin    := IsPanelFin()
local lPergunte
local aArea        := GetArea()
local cBanco
local cAgencia
local cConta
local cSubCta
local jJsonToken


	If lPanelFin
		lPergunte := PergInPanel("AFIMY150",.T.)
	Else
		lPergunte := pergunte("AFIMY150",.T.)
	Endif

	if lPergunte

		cBanco  := mv_par03
		cAgencia:= mv_par04
		cConta  := mv_par05
		cSubCta := mv_par06

		If .not. Empty( cBanco ) .and. .not. Empty( cAgencia ) .and. ;
			.not. Empty( cConta ) .and. .not. Empty( cSubCta )

			dbSelectArea("SA6")
			If SA6->( dbSetOrder(1), dbSeek(xFilial("SA6")+cBanco+cAgencia+cConta ) )

			Else
				Help(" ",1,"FA150BCO")

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza o log de processamento com o erro  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				ProcLogAtu("ERRO","FA150BCO",Ap5GetHelp("FA150BCO"))

			EndIf

		EndIf

	EndIf

	RestArea(aArea)

Return
