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
    local seccion := ''
    local data
    local oString
    local hDataString:={}
	local oDatos	
	local hDataDatos:={} // Recibe Data desde el server
    local oLista1
    local hDataLista1 := {}	
    local dato :=''
    local pos_at := 0
    local posi := 0
    local posic := 0
    local campo := ''
    local extracto := ''
    local valor := ''
	
	AP_SetContentType( "application/json" )

	seccion := hParam['seccion'] // Sección original
    data := hParam['exist']
    for i:=1 to len(data)

        // Necesario para los Model
        hParam['seccion'] :=data[i][1]

        dato:=''
        valor:=''

        // Informacion de la tabla String
	    oString := StringModel():New()
	    hDataString := oString:StrSeccion(hParam)

        // Informacion de la tabla Datos
	    oDatos := DatosModel():New()
	    hDataDatos := oDatos:DatSeccion(hParam)

        for d:=1 to len(hDataDatos)
            dato += AllTrim(hDataDatos[d]['DATO'])
        Next

        //Buscar campo requerido
        campo := AllTrim(data[i][2])
        for d:=1 to len(hDataString)
            if Alltrim(hDataString[d]['CAMPO']) = campo
                posi := d
            endif
        next

        // Si es una Lista
        if hDataString[posi]['TIPO']='T'
            hParam['lista'] := Alltrim(hDataString[posi]['TABLA'])
            oLista1 := ListaModel():New()
            hDataLista1 := oLista1:ListaGet(hParam)
        endif

        // Ubicar campo en la cadena y extraer valor
        pos_at := AT('æ'+campo, dato)
        if pos_at > 0            				
			posic:=AT( "æ", RIGHT( dato, LEN(dato) - (pos_at + LEN(campo) + 2)))
			extracto := SUBSTR( dato, pos_at + (LEN(campo)+2), posic )
            valor := extracto
        endif

        do case
            // Tipo Tabla
			case hDataString[posi]['TIPO'] = 'T'
                for d:=1 to len(hDataLista1)
                    if Alltrim(hDataLista1[d]['CLAVE']) = extracto
                        valor:=hDataLista1[d]['DESCRIP']        
                    endif
                next
							
			// Tipo Fecha
            case hDataString[posi]['TIPO'] = 'D'										
				valor := right(extracto,4) + "-" + substr(extracto,4,2)+ "-" + left(extracto,2)
		endcase

        // Guardar valor extraido
        data[i][3]:= valor

    next
    hParam['exist'] := data

    // Regresar a la seccion original
    hParam['seccion'] := seccion
                		
	hResponse := { 'success' => .t., 'data' =>data, 'hParam' => hParam}
	
	?? hb_jsonEncode( hResponse ) 
	   		
return nil


//	Load Files	------------------------------------------

{% mh_LoadFile( "/src/model/provider/conexionsql.prg" ) %}
{% mh_LoadFile( "/src/model/stringmodel.prg" ) %}
{% mh_LoadFile( "/src/model/datosmodel.prg" ) %}
{% mh_LoadFile( "/src/model/listamodel.prg" ) %}

