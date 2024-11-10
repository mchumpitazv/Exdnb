#define adUseClient    3
#define adOpenStatic    3
#define adOpenDynamic   2
#define adLockOptimistic    3
#define adInteger    3
#define adVarChar    200
#define adParamInput   1
#define adParamReturnValue	4
#define adCmdStoredProc 4

CLASS Pedidos

	METHOD New(oController) 	CONSTRUCTOR
	
	METHOD Show(oController)
    METHOD Action(oController)		
	METHOD Print(oController)
			
ENDCLASS

//	---------------------------------------------------------------	//

METHOD New( oController ) CLASS Pedidos

	AUTENTICATE CONTROLLER oController
	
RETU SELF

METHOD Show(oController) CLASS Pedidos
	
	oController:View( 'pedidos.view', 200)

RETURN NIL

METHOD Action( oController ) CLASS Pedidos		
	local hParam  		:= GetMsgServer()
	
	do case
		case hParam['action'] == 'print'
			::Print(oController, hParam)				
	endcase
	
RETU NIL

METHOD Print(oController, hParam ) CLASS Pedidos

	local hResponse
	local vletra 		:=''
	local vproducto		:=''
	local texto:=''
	
	do case
		case hParam['producto'] = '1'
			vproducto := '1'
			vletra := 'B'
		case hParam['producto'] = '2'
			vproducto := '2'
			vletra := 'B'
		case hParam['producto'] $ ('478')
			vproducto := '4'
			vletra := 'S'
		case hParam['producto'] = '5'
			vproducto := '5'
			vletra := 'B'
		case hParam['producto'] = '9'
			vproducto := '9'
			vletra := 'Q'				
	endcase
	
	texto := HTMLBIR(hParam,vletra,vproducto,'S','S' )
	//HTMLBIR(hParam,vletra,vproducto,'S','S' )

	hResponse := { 'success' => .T., 'texto' => texto}			
	
	oController:oResponse:SendJson( hResponse )	
RETURN NIL


//	Load datamodel		---------------------------------------------

{% mh_LoadFile( "/src/model/provider/conexionsql.prg" ) %}
{% mh_LoadFile( "/lib/Htmlbir.prg" ) %}