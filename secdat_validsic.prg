//	{% mh_LoadHrb( 'lib/tweb/tweb.hrb' ) %}

#include {% TWebInclude() %}

#include "hbclass.ch"  // Obligatorio para evitar errores de sintaxis en la definicion de las Clases
#define adUseClient    3
#define adOpenStatic    3
#define adOpenDynamic   2
#define adLockOptimistic    3

// Programa no se defini dentro de src, cuando no necesitamos refrescar la ventana solo ejecutar proceso en el Server 
Function main()
    local hParam  := GetMsgServer()
	local data
	local oSic	
	local hDataSic // Recibe Data desde el server
	local aParam  := {=>}
	local hSic := {} // Hash con Sics validados

	AP_SetContentType( "application/json" )

	data:=hParam['data']
	
	for i:=39 to 42
		if !empty(alltrim(data[i,2]))
			aParam :={=>}
			hDataSic:={}
			//Aadd( aParam, {'sic' => alltrim(data[i,2])})
			aParam := {'sic'=>alltrim(data[i,2])}
			Aadd(hSic,{'CODIGO' => alltrim(data[i,2]),;
				'INDUSTRIA' =>'';
				})			

			// Extraer informacion de la tabla SIC8DIG

			oSic := SicModel():New()
			hDataSic := oSic:SicGet(aParam)	
			If len(hDataSic) > 0
				hSic[len(hSic)]['INDUSTRIA'] := hb_strToUTF8(hDataSic[1]['INDUSTRIA'])				
			endif
			oSic := nil
		endif
	next

	hResponse := { 'success' => .t., 'hSic' => hSic }
	
	?? hb_jsonEncode( hResponse ) 
	
   		
return nil


//	Load Files	------------------------------------------

{% mh_LoadFile( "/src/model/provider/conexionsql.prg" ) %}
{% mh_LoadFile( "src/model/sicmodel.prg" ) %}
