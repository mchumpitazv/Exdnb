#define adUseClient    3
#define adOpenStatic    3
#define adOpenDynamic   2
#define adLockOptimistic    3
#define adInteger    3
#define adVarChar    200
#define adParamInput   1
#define adParamReturnValue	4
#define adCmdStoredProc 4

CLASS Duns

	METHOD New(oController) 	CONSTRUCTOR
	
	METHOD Show(oController)
	METHOD Action(oController)
	METHOD Edit(oController)
	METHOD Save(oController)
	METHOD Import(oController)
	METHOD Load(oController)
	METHOD Update(oController)	
			
ENDCLASS

//	---------------------------------------------------------------	//

METHOD New( oController ) CLASS Duns

	AUTENTICATE CONTROLLER oController
	
RETU SELF

METHOD Show(oController) CLASS Duns

	//local oDuns	:= DunsModel():New()
	//local hData := oDuns:GetAllDuns()
	
	//oController:View( 'duns.view', 200, hData )
	oController:View( 'duns.view', 200)

RETURN NIL

METHOD Action( oController ) CLASS Duns		
	local hParam  		:= GetMsgServer()
	
	do case
		case hParam['action'] == 'edit'
			::Edit(oController, hParam)
		case hParam['action'] == 'save'
			::Save(oController, hParam)
		case hParam['action'] == 'validSic'
			::ValidSic(oController, hParam)
		case hParam['action'] == 'import'
			::Import(oController, hParam)
	endcase
	
RETU NIL

METHOD Edit(oController, hParam ) CLASS Duns

	local oString 
	local oDatos 
	local oLista1
	local hDataString	:= {}
	local hDataDatos	:= {}
	local hDataLista1	:= {}

	// Informacion de la tabla String
	oString := StringModel():New()
	hDataString := oString:StrSeccion(hParam)

	// Informacion de la tabla Datos
	oDatos := DatosModel():New()	
	hDataDatos := oDatos:DatSeccion(hParam)

	// Informacion de la tabla Lista1
	oLista1 := ListaModel():New()
	hDataLista1 := oLista1:ListaGetAll()

	If len(hDataString) > 0
		oController:View( 'secdat_upd.view', 200, hParam, hDataString, hDataDatos, hDataLista1 )
	endif

RETURN NIL

METHOD Save(oController, hParam ) CLASS Duns

	local duns
	local seccion
	local data	
	local oCmd
	local oParam
	local oRs
	local datacadena
	local aResume
	local hResponse
	local hParam33
	local oString 
	local oDatos 
	local oLista1
	local hDataString	:= {}
	local hDataDatos	:= {}
	local hDataLista1	:= {}
	local dato:=''
	local mformula:=''
	local extracto:=''
	public valor:={}
	public valor33 := {}
	public valor34 := {}
	

	duns := hParam['duns']['duns']
	seccion := hParam['seccion'] 
	data:=hParam['data']	
	valor := hParam['valor']

	if seccion='06'  // Si la seccion es "Balance General Empresas"
		hParam33 := hParam		
		hParam33['seccion'] := '33'

		// EXTRAER LA INFORMACION DE LA SECCION 33 (Balance %)

		// Informacion de la tabla String
		oString := StringModel():New()
		hDataString := oString:StrSeccion(hParam)

		// Informacion de la tabla Datos
		oDatos := DatosModel():New()	
		hDataDatos := oDatos:DatSeccion(hParam)

		// Informacion de la tabla Lista1
		oLista1 := ListaModel():New()
		hDataLista1 := oLista1:ListaGetAll()

		for d:=1 to len(hDataDatos)
			dato += AllTrim(hDataDatos[d]['DATO'])
		Next

		valor33 := Array(len(hDataString))

		for i:= 1 to len(hDataString)			
			fila := hDataString[i]
			pos_at := at('æ'+AllTrim(hDataString[i]['CAMPO']),dato)
			mformula:=AllTrim(hDataString[i]['FORMULA'])
			valor_at:=''
			if pos_at > 0
				valor_at := Inicia(fila, pos_at, dato)
			endif
			do case
				case hDataString[i]['TIPO'] = 'N'
					valor33[i]:=val(valor_at)
				case hDataString[i]['TIPO'] = 'D'
					//valor33[i]:=ctod(valor_at)
					valor33[i]:=right(valor_at,2) + '/' + substr(valor_at,6,2) + '/' + left(valor_at,4)
					otherwise
					valor33[i]:=valor_at
			endcase
			if !empty(mformula) .and. hDataString[i]['FLFOR']
				valor33[i]:= &(mformula)				
			endif			
		next

		//Generar datacadena para la seccion 33
		datacadena := ''
		for i:= 1 to len(hDataString)
			extracto:=''
			do case
				case hDataString[i]['TIPO'] = 'N'
					if valor33[i]<>0
						extracto := Alltrim(str(valor33[i],6,2))
					else
						extracto := ''
					endif					
				case hDataString[i]['TIPO'] = 'D'
					extracto := Alltrim(valor33[i])
					otherwise
					if valor33[i]<>Nil
						extracto := Alltrim(valor33[i])
					endif
			endcase
			if !empty(extracto)// .or. (val(extracto) > '0' .and. hDataString[i]['TIPO'] = 'N')
				datacadena += ("æ" + alltrim(hDataString[i]['CAMPO']) + extracto)
			endif
		next

		if !empty(datacadena)
			//datacadena+="æzz0100" + "æzz05"+oper_key + "æzz02"+oper_nmb + "æzz03"+DTOC(DATE()) + "æzz04"+AMPM(TIME()) + "æ"
			datacadena+='æzz0100' + 'æzz05LCV' + 'æzz02Luis Chumpitaz' + 'æzz03' + DTOC(DATE()) + 'æzz04' + TIME() + 'æ'
		endif

		// Grabar Seccion 33
		SaveSeccion(duns,'33',datacadena)

		// EXTRAER LA INFORMACION DE LA SECCION 34 (Cuadros Balance)

		hParam33['seccion'] := '34'
		// Informacion de la tabla String
		oString := StringModel():New()
		hDataString := oString:StrSeccion(hParam)

		// Informacion de la tabla Datos
		oDatos := DatosModel():New()	
		hDataDatos := oDatos:DatSeccion(hParam)

		// Informacion de la tabla Lista1
		oLista1 := ListaModel():New()
		hDataLista1 := oLista1:ListaGetAll()

		dato:=''
		for d:=1 to len(hDataDatos)
			dato += AllTrim(hDataDatos[d]['DATO'])
		Next

		valor34 := Array(len(hDataString))

		for i:= 1 to len(hDataString)			
			fila := hDataString[i]
			pos_at := at('æ'+AllTrim(hDataString[i]['CAMPO']),dato)
			mformula:=AllTrim(hDataString[i]['FORMULA'])
			valor_at:=''
			if pos_at > 0
				valor_at := Inicia(fila, pos_at, dato)
			endif
			do case
				case hDataString[i]['TIPO'] = 'N'					
					valor34[i]:=val(valor_at)
				case hDataString[i]['TIPO'] = 'D'
					//valor34[i]:=ctod(valor_at)
					valor34[i]:=right(valor_at,2) + '/' + substr(valor_at,6,2) + '/' + left(valor_at,4)
					otherwise
					valor34[i]:=valor_at
			endcase
			if !empty(mformula) .and. hDataString[i]['FLFOR']
				valor34[i]:= &(mformula)				
			endif			
		next

		//Generar datacadena para la seccion 34
		datacadena := ''
		for i:= 1 to len(hDataString)
			extracto:=''
			do case
				case hDataString[i]['TIPO'] = 'N'
					if valor34[i]<>0
						extracto := Alltrim(str(valor34[i]))
					else
						extracto := ''
					endif
				case hDataString[i]['TIPO'] = 'D'
					extracto := Alltrim(valor34[i])
					otherwise
					if valor34[i]<>Nil
						extracto := Alltrim(valor34[i])
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

		// Grabar Seccion 34
		SaveSeccion(duns,'34',datacadena)

	endif
	
	/*
	for i:=1 to len(data)
		if !empty(data[i,2]) .and. data[i,2]<>'0' 
			datacadena += "æ" + alltrim(data[i,1]) + alltrim(data[i,2])
		endif
	next
	*/
	
	datacadena:=hParam['datacadena']

	if !empty(datacadena)
		//datacadena+="æzz0100" + "æzz05"+oper_key + "æzz02"+oper_nmb + "æzz03"+DTOC(DATE()) + "æzz04"+AMPM(TIME()) + "æ"
		datacadena+='æzz0100' + 'æzz05LCV' + 'æzz02Luis Chumpitaz' + 'æzz03' + DTOC(DATE()) + 'æzz04' + TIME() + 'æ'
	endif	

	oDatos := DatosModel():New()
	
	oCmd:=TOleAuto():New( "ADODB.Command" )
	oCmd:ActiveConnection:=oConnection
	oCmd:CommandType:=adCmdStoredProc
	oCmd:CommandText:="dbo.sp_DunsSave"
    
	oParam := oCmd:CreateParameter( "Return_Value", adInteger, adParamReturnValue )
	oCmd:Parameters:Append( oParam )
	oParam := oCmd:CreateParameter( "@Duns", adVarChar, adParamInput, 9 )
	oCmd:Parameters:Append( oParam )
	oParam := oCmd:CreateParameter( "@seccion", adVarChar, adParamInput, 2 )
	oCmd:Parameters:Append( oParam )
	oParam := oCmd:CreateParameter( "@cadena", adVarChar, adParamInput, len(datacadena) )
	oCmd:Parameters:Append( oParam )

	oCmd:Parameters( "@Duns" ):Value := duns
	oCmd:Parameters( "@seccion" ):Value := seccion
	oCmd:Parameters( "@cadena" ):Value := HB_UTF8ToStr(datacadena)
	oCmd:Execute()
	
	if oCmd:Parameters("Return_Value"):Value = 0
		aResume := 'S'
	else
		aResume := 'N'
	endif

	oConnection:Close()

	hResponse := { 'success' => .T., 'resume' => aResume, 'valor' => valor, 'valor33' => valor33, 'valor34' => valor34 }				
	
	oController:oResponse:SendJson( hResponse )	

RETURN NIL

METHOD Import(oController, hParam ) CLASS Duns

	local oExcel
	local oWorkBook
	local oHoja
	local cFile:=''
	local aHojas:={=>}

	if valtype(oExcel) = 'O'  //Si hay otro libro abrierto se cierra
		oExcel:Quit()
		oExcel := nil
	endif

	cFile := hParam['filexls']

	//oExcel := TOleAuto():New( "Excel.Application" )	
	oExcel := CreateObject( "Excel.Application" )
	oWorkBook:=oExcel:WorkBooks:Open(cFile)
	
	aHojas:={=>}
	For K := 1 to oExcel:ActiveWorkBook:Sheets:Count
		//aadd(aHojas,alltrim(oExcel:ActiveWorkBook:Sheets(K):Name))
		//aHojas[str(k)] := alltrim(oExcel:ActiveWorkBook:Sheets(K):Name)
		aHojas[alltrim(oExcel:ActiveWorkBook:Sheets(K):Name)] := alltrim(oExcel:ActiveWorkBook:Sheets(K):Name)
	Next
	oExcel:Quit()
	oExcel := nil

	do case
		case hParam['proceso'] == 'B' // Importar Balance
			oController:View( 'imporbal.view', 200, hParam, aHojas)
		case hParam['proceso'] == 'D' // Importar DAOT
			oController:View( 'impordaot.view', 200, hParam,aHojas)
		case hParam['proceso'] == 'S' // Importar Cuadros SQR
			oController:View( 'imporsqr.view', 200, hParam,aHojas)
	endcase
	
RETURN NIL


METHOD Load( oController, hParam ) CLASS Duns
		
	local oDuns 		:= DunsModel():New()	
	local aRows 		:= oDuns:Search( hParam[ 'tag'],  hParam[ 'search' ] )

	oController:oResponse:SendJson( { 'rows' => aRows } )

RETU NIL

METHOD Update(oController)
	
	local oSeccion		:= SeccionModel():New()
	local hParam		:= oController:GetAll()
	local hData 		:= {}
	local oValidator
	DEFINE VALIDATOR oValidator WITH hParam
	PARAMETER 'DUNSNUM' NAME 'Duns' ROLES 'required|number|maxlen:9'  FORMATTER 'tostring' OF oValidator			
	PARAMETER 'RUC' 	NAME 'Ruc' ROLES  'required|number|maxlen:11' FORMATTER 'tostring' OF oValidator
	RUN VALIDATOR oValidator

	//if !oValidator:lError

	hData := oSeccion:GetSeccion(hParam)

	oController:View( 'duns_upd.view', 200, hParam, hData )
	//endif

	return nil


	//	Load datamodel		---------------------------------------------

	{% mh_LoadFile( "/src/model/provider/conexionsql.prg" ) %}
	{% mh_LoadFile( "/src/model/dunsmodel.prg" ) %}
	{% mh_LoadFile( "/src/model/seccionmodel.prg" ) %}
	{% mh_LoadFile( "/src/model/stringmodel.prg" ) %}
	{% mh_LoadFile( "/src/model/datosmodel.prg" ) %}
	{% mh_LoadFile( "/src/model/listamodel.prg" ) %}
	{% mh_LoadFile( "/src/model/sicmodel.prg" ) %}
	{% mh_LoadFile( "/src/model/tcanualmodel.prg" ) %}
{% mh_LoadFile( "/lib/FunGen.prg" ) %}