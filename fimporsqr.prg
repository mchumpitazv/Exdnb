//	{% mh_LoadHrb( 'lib/tweb/tweb.hrb' ) %}

#include {% TWebInclude() %}

#include "hbclass.ch"  // Obligatorio para evitar errores de sintaxis en la definicion de las Clases
#define adUseClient    3
#define adOpenStatic    3
#define adOpenDynamic   2
#define adLockOptimistic    3
#define adInteger    3
#define adVarChar    200
#define adParamInput   1
#define adParamReturnValue	4
#define adCmdStoredProc 4


// Programa no se defini dentro de src, cuando no necesitamos refrescar la ventana solo ejecutar proceso en el Server 
Function main()

    local hParam  := GetMsgServer()
    FProcesaDaot(hParam)        
         	   		
Return nil

Function FProcesaDaot(hParam)
    local oExcel
    local oWorkBook
    local oHoja	
    local duns := hParam['hParam']['duns']    
    local aHojas := hParam['aHojas']
    local cFile := hParam['hParam']['filexls']    
    local vSeccion:=''    
    local hParamI:={=>}
    local vHoja:=''    
    local oString 
    local oDatos 
    local oLista1
    local hDataString	:= {}
    local hDataDatos	:= {}
    local hDataLista1	:= {}
    local dato:=''	
    local extracto:=''
    local valor_ori
    public valor:={}

    SET DATE FORMAT "dd/mm/yyyy"
    Set( _SET_DATEFORMAT, "dd/mm/yyyy" )
    
    AP_SetContentType( "application/json" )
    vHoja := hParam['hoja']    
    vSeccion:='34'
    
    hParamI['duns'] := duns
    hParamI['seccion'] := vSeccion

    // Abrir Archivo Excel
    oExcel := CreateObject( "Excel.Application" )
    oWorkBook:=oExcel:WorkBooks:Open(cFile)

    // EXTRAER LA INFORMACION DE LA SECCION 
    
    // Informacion de la tabla String
    oString := StringModel():New()
    hDataString := oString:StrSeccion(hParamI)

    // Informacion de la tabla Datos
    oDatos := DatosModel():New()	
    hDataDatos := oDatos:DatSeccion(hParamI)

    // Informacion de la tabla Lista1
    oLista1 := ListaModel():New()
    hDataLista1 := oLista1:ListaGetAll()

    dato:=''
    for d:=1 to len(hDataDatos)
        dato += AllTrim(hDataDatos[d]['DATO'])
    Next
    
    valor := Array(len(hDataString))
    for i:= 1 to len(hDataString)			
        fila := hDataString[i]
        pos_at := at('æ'+AllTrim(hDataString[i]['CAMPO']),dato)        
        valor_at:=''
        if pos_at > 0
            valor_at := Inicia(fila, pos_at, dato)
        endif
        do case
            case hDataString[i]['TIPO'] = 'N'
                valor[i]:=val(valor_at)
            case hDataString[i]['TIPO'] = 'D'                
                valor[i]:=right(valor_at,2) + '/' + substr(valor_at,6,2) + '/' + left(valor_at,4)
                otherwise
                valor[i]:=valor_at
        endcase        
    next

    oHoja := oExcel:Sheets( vHoja )
    
    IF !empty(vHoja)

        // Registrar los Valores del XLS en Matriz

        // Titulos de los cuadros
        For nRow:=3 to 13
            xcampo:=oHoja:Cells(nRow,1):Value
            IF !empty(xcampo)
                xcampo:=alltrim(xcampo)
                posi:=0
                posi:=ascan(hDataString,{|aVal| aVal['CAMPO']=xcampo})
                IF posi > 0
                    vdato:= oHoja:Cells(nRow,3):Value	
                    valor[posi]:=vdato	
                Endif
            Endif				
        Next

        // Valores Numericos
        For nRow:=17 to 23
            For nCol:=3 to 5
                xcampo:=oHoja:Cells(nRow,1):Value + oHoja:Cells(15,nCol):Value				
                IF !empty(xcampo)
                    xValue:=alltrim(xcampo)
                    posi:=0
                    posi:=ascan(hDataString,{|aVal| aVal['CAMPO']=xcampo})
                    IF posi > 0
                        vdato:= oHoja:Cells(nRow,nCol):Value								
                        valor[posi]:=vdato		
                    Endif
                Endif
            Next
        Next                                    
    
        // GRABAR
        
        //Generar datacadena
        datacadena := ''
        for i:= 1 to len(hDataString)
            extracto:=''
            do case
                case hDataString[i]['TIPO'] = 'N'
                    if valor[i]<>0
                        extracto := Alltrim(str(valor[i]))
                    else
                        extracto := ''
                    endif
                case hDataString[i]['TIPO'] = 'D' .and. valtype(valor[i])='D'
                    extracto := dtoc(valor[i])                
                    otherwise
                    if valor[i]<>Nil
                        extracto := Alltrim(valor[i])
                    endif
            endcase
            if !empty(extracto) //.or. (val(extracto) > '0' .and. hDataString[i]['TIPO'] = 'N')
                datacadena += ("æ" + alltrim(hDataString[i]['CAMPO']) + extracto)
            endif
        next

        if !empty(datacadena)
            //datacadena+="æzz0100" + "æzz05"+oper_key + "æzz02"+oper_nmb + "æzz03"+DTOC(DATE()) + "æzz04"+AMPM(TIME()) + "æ"
            datacadena+='æzz0100' + 'æzz05LCV' + 'æzz02Luis Chumpitaz' + 'æzz03' + DTOC(DATE()) + 'æzz04' + TIME() + 'æ'
        endif
        
        // Grabar Seccion
        SaveSeccion(duns,vSeccion,datacadena)    
    
        hResponse := { 'success' => .t., 'valor'=> valor, 'duns'=> duns}
    else
        hResponse := { 'success' => .f.}
    endif
    
    
    // Cerrar Archivo Excel

    oExcel:Quit()
    oExcel := nil
        			    	
    //hResponse := { 'success' => .t.,'xFecBal' => xFecBal, 'vFecBal' => vFecBal,'hParamI'=> hParamI, 'valor'=> valor, 'dato'=> dato}
    ?? hb_jsonEncode( hResponse )
Return nil


    //	Load Files	------------------------------------------

{% mh_LoadFile( "/src/model/provider/conexionsql.prg" ) %}
{% mh_LoadFile( "/src/model/stringmodel.prg" ) %}
{% mh_LoadFile( "/src/model/datosmodel.prg" ) %}
{% mh_LoadFile( "/src/model/listamodel.prg" ) %}
{% mh_LoadFile( "/lib/FunGen.prg" ) %}

