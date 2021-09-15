#include "rwmake.ch"
#include "protheus.ch"
#include "TbiConn.ch"

/*/{Protheus.doc} CADZZA01 - Rotina para o cadastro de unidade de medidas, relacionando com as unidades de outros paises
	@author Edilson Nascimento
	@since 14/07/2021
/*/

USER FUNCTION CADZZA01()
	
Local _cTitulo := "Cadastro de Unidades de Medida"

    AxCadastro( "ZAA", _cTitulo )

Return
