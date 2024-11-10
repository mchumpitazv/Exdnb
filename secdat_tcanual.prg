//	{% mh_LoadHrb( 'lib/tweb/tweb.hrb' ) %}

#include {% TWebInclude() %}

#include "hbclass.ch"  // Obligatorio para evitar errores de sintaxis en la definicion de las Clases
#define adUseClient    3
#define adOpenStatic    3
#define adOpenDynamic   2
#define adLockOptimistic    3

// Programa fuera de la carpeta src; para no refrescar la ventana solo ejecutar proceso en el Server 
Function main()
    local hParam  := GetMsgServer()
	local data
	local oTcanual	
	local hDataTcanual:={} // Recibe Data desde el server
	local aParam  := {}
	
	AP_SetContentType( "application/json" )

	data:=hParam['data']

    Aadd( aParam, {'year' => left(dtos(date()),4)})
			
	// Extraer informacion de la tabla TCANUAL

	oTcanual := TcanualModel():New()
	hDataTcanual := oTcanual:TcanualGet(aParam)	
		
	hResponse := { 'success' => .t., 'hDataTcanual' => hDatatcanual, 'data' =>data }
	
	?? hb_jsonEncode( hResponse ) 
	   		
return nil


//	Load Files	------------------------------------------

{% mh_LoadFile( "/src/model/provider/conexionsql.prg" ) %}
{% mh_LoadFile( "src/model/tcanualmodel.prg" ) %}
