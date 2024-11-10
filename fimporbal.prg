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
    local opcion := hParam['opcion']    

    do case
        case opcion = 'imporbal'
            FProcesaImpor(hParam)
        case opcion = 'desplazar'
            FProcesaDesplaza(hParam)
    endcase     
	   		
Return nil

Function FProcesaImpor(hParam)
    local oExcel
    local oWorkBook
    local oHoja	
    local duns := hParam['hParam']['duns']    
    local aHojas := hParam['aHojas']
    local cFile := hParam['hParam']['filexls']
    local aBalSec :={}
    local vSeccion:=''
    local vBalance := hParam['balance']
    local vBalTipo := hParam['tipo']
    local vposicion:=val(hParam['posicion'])
    local nitem:=0
    local hParamI:={=>}
    local vHoja:=''
    local maxRow:=0    
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

    do case
        case vBalance='E'
            nitem:=1
        case vBalance='B'
            nitem:=2
        case vBalance='S'
            nitem:=3
    endcase
    AP_SetContentType( "application/json" )
    vHoja := hParam['hoja']
    aBalSec:={{'06','22'},{'09','09'},{'14','14'}}
    vSeccion:=aBalSec[nitem,iif(vBalTipo='G', 1,2)]

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
    maxRow:=oHoja:UsedRange:Rows:Count()
    xFecBal := oHoja:Cells(5,4):Value
    vFecBal := iif(vBalance='E',valor[7], valor[5])
    vFecBal := right(vFecBal,4) +  substr(vFecBal,4,2) + left(vFecBal,2)
    iF Dtos(xFecBal) > vFecBal .OR. vposicion >0
        // Reservar Espacio para el Balance General
        IF vBalance='E' .and. vBalTipo='G' .and. vposicion=0
            cta:=Array(352)
            FOR i=1 TO 352
                cta[i] := valor[i]
            NEXT
            
            valor[1]:='' //CTOD("  /  /    ")
            valor[2]:=SPACE(80)
            valor[3]:=SPACE(5)
            valor[4]:=SPACE(500)
            valor[5]:=SPACE(5)
            valor[6]:='' //CTOD("  /  /    ")
            valor[7]:='' //CTOD("  /  /    ")
            valor[8]:=SPACE(5)
            FOR i=9 TO 58
                valor[i]:=0
            NEXT
            valor[59]:='' //CTOD("  /  /    ")
            valor[60]:='' //CTOD("  /  /    ")
            FOR i=61 TO 77
                valor[i]:=0
            NEXT
            valor[78]:=SPACE(5)
            FOR i=79 TO 88
                valor[i]:=SPACE(500)
            NEXT
            
            FOR i=89 TO 352
                valor[i]:=cta[i-88]
            NEXT
        Endif
        
        // Si vposicion > 0 poner valores numericos de la matriz en cero 
            
        IF vposicion >0  .OR. vBalTipo='P'            
            For nCol:=1 to 4
                For nRow:=5 to maxRow 						
                    IF vBalTipo='G' .and. nCol < 4
                        xcampo := oHoja:Cells(nRow,nCol + ((nCol-1)*3)):Value 							
                        if !empty(xcampo)
                            xcampo:=left(xcampo,3)+alltrim(str(vposicion))
                        endif
                    Else
                        xcampo := oHoja:Cells(nRow,nCol + ((nCol-1)*3) +1):Value 
                    Endif
                    IF !empty(xcampo)
                        posi:=0	
                        posi:=ascan(hDataString,{|aVal| aVal['CAMPO']=xcampo})
                        IF posi > 0                            
                            vdato:= oHoja:Cells(nRow,nCol + (nCol * 3)):Value
                            If (valtype(vdato) = 'N' .and. hDataString[posi]['TIPO']='N')
                                valor[posi]:=0
                            endif
                        Endif
                    Endif
                Next
            Next
        Endif
        // Registrar los Valores del XLS en Matriz
                            
        For nCol:=1 to 4
            For nRow:=5 to maxRow 
                //oExcel:Sheets( "Informe Mensual" ):Cells( 8, 6 ):Value := "US$ Actual"
                IF vBalTipo='G' .and. nCol < 4
                    xcampo := oHoja:Cells(nRow,nCol + ((nCol-1)*3)):Value 							
                    if vposicion>0 .and. !empty(xcampo) .and. vBalance='E'
                        xcampo:=left(xcampo,3)+alltrim(str(vposicion))
                    endif
                Else
                    xcampo := oHoja:Cells(nRow,nCol + ((nCol-1)*3) +1):Value 
                Endif
                IF !empty(xcampo)
                    xcampo:=alltrim(xcampo)
                    posi:=0
                    posi:=ascan(hDataString,{|aVal| aVal['CAMPO']=xcampo})                    		
                    IF posi > 0
                        vdato:= oHoja:Cells(nRow,nCol + (nCol * 3)):Value
                        If valtype(vdato) = 'N' .and. hDataString[posi]['TIPO']='N'
                            IF LEFT(vBalance,1)='E'
                                valor[posi]+= int(round(vdato,0))
                            ELSE
                                valor[posi]:= int(round(vdato,0))
                            ENDIF
                        Elseif valtype(vdato) = 'N' .and. hDataString[posi]['TIPO'] = 'C'
                            valor[posi]:=Alltrim(str(round(vdato,2)))
                        Elseif valtype(vdato) = 'D'
                            valor[posi]:=dtoc(vdato)
                        Else
                            valor[posi]:=vdato
                        Endif
            
                        // Poner Nulo en los campos identificados como "Por"
                        IF vBalance='E' .and. vBalTipo='G'
                            valor[94]:= space(50)
                            valor[182]:=space(50)
                            valor[270]:=space(50)
                        Endif
                    Endif
                Endif
            Next
        Next
        
        // GRABAR BALANCE
            
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
        valor_pri := valor

        // SECCION COMPARATIVOS
            
        IF vBalTipo = 'G'
            
            hParamI['seccion'] := '07'
            
            // Informacion de la tabla String
            oString := StringModel():New()
            hDataString := oString:StrSeccion(hParamI)
            
            // Informacion de la tabla Datos
            oDatos := DatosModel():New()	
            hDataDatos := oDatos:DatSeccion(hParamI)            
            
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
                        
            // Si vposicion > 0 poner valores numericos de la matriz en cero 
                                            
            For nRow:=5 to maxRow 							
                xcampo := oHoja:Cells(nRow,13):Value 
                if  !empty(xcampo)
                    xcampo:=chr(100 - vposicion)+right(xcampo,1)
                endif
                IF !empty(xcampo)
                    posi:=0
                    posi:=ascan(hDataString,{|aVal| aVal['CAMPO']=xcampo})
                    IF posi > 0
                        vdato:= oHoja:Cells(nRow,16):Value
                        If valtype(vdato) = 'N' .and. hDataString[posi]['TIPO'] = 'N'
                            valor[posi]:=0
                        endif
                    Endif
                Endif
            Next
            
            // Registrar los Valores del XLS en Matriz
            For nRow:=5 to maxRow 							
                xcampo := oHoja:Cells(nRow,13):Value 							
                if vposicion>0 .and. !empty(xcampo)
                    xcampo:=chr(100 - vposicion)+right(xcampo,1)
                endif
                IF !empty(xcampo)
                    xcampo:=alltrim(xcampo)
                    posi:=0
                    posi:=ascan(hDataString,{|aVal| aVal['CAMPO']=xcampo})                    
                    IF posi > 0
                        vdato:= oHoja:Cells(nRow,16):Value
                        If valtype(vdato) = 'N' .and. hDataString[posi]['TIPO'] = 'N'
                            valor[posi]+= int(vdato)
                        else
                            IF xcampo$'da-ca-ba-aa'
                                valor[posi]:=FFecha(vdato)
                            Elseif valtype(vdato) = 'N' .and.  hDataString[posi]['TIPO'] = 'C'
                                valor[posi]:=Alltrim(str(vdato))
                            Elseif valtype(vdato) = 'D'
                                valor[posi]:= dtoc(vdato)
                            Else
                                valor[posi]:=vdato
                            Endif
                        endif
                    Endif
                Endif
            Next

            if vposicion=0
                valor_ori:=valor						
                FOR c:=1 TO 63						       
                    valor[c]:=valor_ori[c+21]
                NEXT
                valor[64]:=SPACE(11)
                valor[65]:=SPACE(5)
                valor[66]:=0
                valor[67]:=0
                valor[68]:=0
                valor[69]:=0
                valor[70]:=0
                valor[71]:=0
                valor[72]:=0
                valor[73]:=0
                valor[74]:=0
                valor[75]:=0
                valor[76]:=SPACE(8)
                valor[77]:=SPACE(8)
                valor[78]:=SPACE(8)
                valor[79]:=SPACE(8)
                valor[80]:=SPACE(8)
                valor[81]:=SPACE(8)
                valor[82]:=SPACE(8)
                valor[83]:=SPACE(8)
                valor[84]:=SPACE(8)						
            Endif

            // Grabar
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
            SaveSeccion(duns,'07',datacadena)
            
        Endif
        hResponse := { 'success' => .t., 'valorg'=> valor_pri,'valorc' => valor, 'duns'=> duns}
    else
        hResponse := { 'success' => .f.}
    endif
    
    
    // Cerrar Archivo Excel

    oExcel:Quit()
    oExcel := nil
        			    	
    //hResponse := { 'success' => .t.,'xFecBal' => xFecBal, 'vFecBal' => vFecBal,'hParamI'=> hParamI, 'valor'=> valor, 'dato'=> dato}
    ?? hb_jsonEncode( hResponse )
Return nil

Function FProcesaDesplaza(hParam)
    local duns := hParam['hParam']['duns']       
    local vSeccion:=''
    local vBalance := hParam['balance']
    local vBalTipo := hParam['tipo']
    local vposicion:=val(hParam['posicion'])    
    local hParamI:={=>}
    local oString 
    local oDatos 
    local oLista1
    local hDataString	:= {}
    local hDataDatos	:= {}
    local hDataLista1	:= {}
    local dato:=''
    local extracto:=''
    local valor_ori
    local valor06:={}
    public valor:={}

    SET DATE FORMAT "dd/mm/yyyy"
    Set( _SET_DATEFORMAT, "dd/mm/yyyy" )

    
    AP_SetContentType( "application/json" )    
    
    vSeccion:='06'

    hParamI['duns'] := duns
    hParamI['seccion'] := vSeccion
    IF vBalance='E' .and. vBalTipo='G' .and. vposicion=0
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

        // Desplazar Balance General
        cta:=Array(352)
        FOR i=1 TO 352
            cta[i] := valor[i]
        NEXT

        valor[1]:='' //CTOD("  /  /    ")
        valor[2]:=SPACE(80)
        valor[3]:=SPACE(5)
        valor[4]:=SPACE(500)
        valor[5]:=SPACE(5)
        valor[6]:='' //CTOD("  /  /    ")
        valor[7]:='' //CTOD("  /  /    ")
        valor[8]:=SPACE(5)
        FOR i=9 TO 58
            valor[i]:=0
        NEXT
        valor[59]:='' //CTOD("  /  /    ")
        valor[60]:='' //CTOD("  /  /    ")
        FOR i=61 TO 77
            valor[i]:=0
        NEXT
        valor[78]:=SPACE(5)
        FOR i=79 TO 88
            valor[i]:=SPACE(500)
        NEXT

        FOR i=89 TO 352
            valor[i]:=cta[i-88]
        NEXT

        // Grabar
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

        // Grabar Seccion Balance
        SaveSeccion(duns,'06',datacadena)
        valor06:=valor

        // Desplazar Comparativos

        vSeccion:='07'
        hParamI['seccion'] := '07'
            
        // Informacion de la tabla String
        oString := StringModel():New()
        hDataString := oString:StrSeccion(hParamI)
            
        // Informacion de la tabla Datos
        oDatos := DatosModel():New()	
        hDataDatos := oDatos:DatSeccion(hParamI)            
            
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
        
        valor_ori:=valor

        FOR c:=1 TO 63						       
            valor[c]:=valor_ori[c+21]
        NEXT
        valor[64]:=SPACE(11)
        valor[65]:=SPACE(5)
        valor[66]:=0
        valor[67]:=0
        valor[68]:=0
        valor[69]:=0
        valor[70]:=0
        valor[71]:=0
        valor[72]:=0
        valor[73]:=0
        valor[74]:=0
        valor[75]:=0
        valor[76]:=SPACE(8)
        valor[77]:=SPACE(8)
        valor[78]:=SPACE(8)
        valor[79]:=SPACE(8)
        valor[80]:=SPACE(8)
        valor[81]:=SPACE(8)
        valor[82]:=SPACE(8)
        valor[83]:=SPACE(8)
        valor[84]:=SPACE(8)

        // Grabar Seccion Comparativos 07
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
        SaveSeccion(duns,'07',datacadena)

        hResponse := { 'success' => .t., 'valor06'=> valor06,'valor07' => valor, 'duns'=> duns}
    else
        hResponse := { 'success' => .f.}
    endif

    ?? hb_jsonEncode( hResponse )
Return nil


    //	Load Files	------------------------------------------

    {% mh_LoadFile( "/src/model/provider/conexionsql.prg" ) %}
    {% mh_LoadFile( "/src/model/stringmodel.prg" ) %}
    {% mh_LoadFile( "/src/model/datosmodel.prg" ) %}
    {% mh_LoadFile( "/src/model/listamodel.prg" ) %}
    {% mh_LoadFile( "/lib/FunGen.prg" ) %}

