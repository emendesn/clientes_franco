#include "rwmake.ch"
#include "protheus.ch"
#include "TbiConn.ch"

/*/{Protheus.doc} JOBM712 - JOB para execucao da rotina MATA712 via Scheduler
	@author Edilson Nascimento
	@since 13/07/2021
/*/

USER FUNCTION jobm712()

Local aProcessa := {}
local cDescri
local cGrupo


    PREPARE ENVIRONMENT EMPRESA "02" FILIAL "01" USER "admin" PASSWORD "2Latin3" TABLES "SB1","SB2","SBM", "SC2","SC3","SC4","SC6" MODULO "PCP"

    AAdd( aProcessa, 7 )            //-- Tipo de período 1=Diário; 2=Semanal; 3=Quinzenal; 4=Mensal; 5=Trimestral; 6=Semestral; 7=Diversos
    AAdd( aProcessa, 5)             //-- Quantidade de períodos
    AAdd( aProcessa, .T.)           //-- Considera Pedidos em Carteir
    AAdd( aProcessa, {})            //-- Array contendo Tipos de produtos a serem considerados
    AAdd( aProcessa, {})            //-- Array contendo Grupos de produtos a serem considerados
    AAdd( aProcessa, .T.)           //-- Gera/Não Gera OPs e SCs depois do cálculo da necessidade
    AAdd( aProcessa, .T.)           //-- Indica se monta log
    AAdd( aProcessa, "00001")            //-- Número da Op Inicial
    AAdd( aProcessa, "02/10/2000")  //-- Database para inicio do cálculo
    AAdd( aProcessa, {1,3,5})       //-- Números dos períodos para geração de OPs
    AAdd( aProcessa, {1,3,5})       //-- Números dos períodos para geração de SCs
    AAdd( aProcessa, .F.)           //-- Máximo de 99 itens por OP
    AAdd( aProcessa, {"02/10/2018","04/10/2018","05/10/2018"})           //-- Datas para tipo de período diversos

    //****************************
    //* Carrega os tipos de produtos a serem processadas
    //****************************
    dbSelectArea("SX5")
    SX5->( dbSetOrder(1), dbSeek(xFilial("SX5")+"02") )
    While SX5->X5_FILIAL == xFilial("SX5") .and. ;
            SX5->X5_TABELA == "02" .and. ;
            .not. SX5->( Eof() )

        cDescri := OemToAnsi( Capital( X5Descri() ) )
        AAdd( aProcessa[ 4 ], { .T., Left( SX5->X5_CHAVE ,2) + " " + cDescri } )

        SX5->( dbSkip() )
    EndDo


    //****************************
    //* Carrega os grupos de produtos a serem processadas
    //****************************
    dbSelectArea("SBM")
    SBM->( dbSetOrder(1), dbSeek(xFilial("SBM") ) )
    //AAdd( aProcessa[ 5 ],   { .T., Criavar( "B1_GRUPO", .F. ) + " " + "Branco" } )

    While SBM->BM_FILIAL == xFilial("SBM") .and. ;
            .not. SBM->( Eof() )

        cGrupo := OemToAnsi( Capital( SBM->BM_DESC ) )
        AAdd( aProcessa[ 5 ] , { .T., Left( SBM->BM_GRUPO , 4 ) + " " + cGrupo } )

        SBM->( dbSkip() )
    EndDo

    conout(" [MATA712] Inicio (" + DtoC( Date() ) + ") - (" + Time() + ")" )

    MATA712( .T., aProcessa )   

    conout(" [MATA712] Fim (" + DtoC( Date() ) + ") - (" + Time() + ")" )

    RESET ENVIRONMENT

Return
