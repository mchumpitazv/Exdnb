#define adUseClient    3
#define adOpenStatic    3
#define adOpenDynamic   2
#define adLockOptimistic    3

CLASS Access

	METHOD New() 	CONSTRUCTOR
	
	METHOD Login() 
	METHOD Auth() 
	METHOD Logout() 
	
   
ENDCLASS

//	---------------------------------------------------------------	//

METHOD New( o ) CLASS Access	


RETU SELF

//	---------------------------------------------------------------	//

METHOD Login( o ) CLASS Access


	//	Crearemos una pagina para entrar datos para posteriormente valorarlos...

		o:View( 'sys/login.view' )
	
RETU NIL

//	---------------------------------------------------------------	//

METHOD Auth( oController ) CLASS Access
	
	local hData 		:= GetMsgServer()
	LOCAL hTokenData 	:= {=>}
	LOCAL hUser	 	:= {=>}
	local oValidator, oTrace, cRol
	local cUsuario, aUsuarios
		

	DEFINE VALIDATOR oValidator WITH hData
		PARAMETER 'user' 	NAME 'User' ROLES 'required|string|maxlen:3' OF oValidator
		PARAMETER 'psw' 	NAME 'Psw'  ROLES 'required|maxlen:20' OF oValidator		
	RUN VALIDATOR oValidator
	
	if oValidator:lError	
		oController:oResponse:SendJson( { 'success' => .f., 'error' => oValidator:ErrorString() } )			
		retu 
	endif
	
	// Activar y modificar si se desea dejar registro de seguimiento Trace 

	//oTrace		:= TraceModel():New()
	//oTrace:Insert()

	//cUsuario := oController:oRequest:Post( 'mystate' )    
	cUsuario := hData['user']
    oConexionsql:= ConexionSql():New()	
    aUsuarios := oConexionsql:Usuario(cUsuario)
	oConnection := nil

	//	Validacion de Usuario. Puedes poner un modelo de datos y validar... :-)
	
		//IF hData[ 'user' ] == 'demo' .AND. ( hData[ 'psw'] == '1234' .or. hData[ 'psw'] == '777' )
		IF cUsuario == aUsuarios[1,1]
		
			//	Recojo datos de Usuario (from model)
			
				cRol := if( hData[ 'psw'] == '777', 'A', '' )
			
				hUser := { 'id' => cUsuario, 'user' => cUsuario, 'name' => aUsuarios[1,2], 'rol' => cRol }
			
			//	Datos que incrustar en el token...	
				
				hTokenData := { 'entrada' => time(), 'empresa' => 'ExDNB', 'user' => hUser } 			
			
			//	Inicamos nuestro sistema de Validación del sistema basado en JWT
			
				CREATE JWT cJWT OF oController WITH hTokenData			
				
			
			//	Mostramos página principal
			
				oController:oResponse:SendJson( { 'success' => .t. } )
				
		ELSE					
			oController:oResponse:SendJson( { 'success' => .f., 'error' => 'Error de indentificacion' } )
		ENDIF	

RETU NIL

//	---------------------------------------------------------------	//

METHOD Logout( oController ) CLASS Access	
	
	CLOSE TOKEN OF oController

	oController:View( 'splash.view' )

RETU NIL


//	Load datamodel		------------------------------------------ //

//	{% mh_LoadFile( "/src/model/tracemodel.prg" ) %}
	{% mh_LoadFile( "/src/model/provider/conexionsql.prg" ) %}