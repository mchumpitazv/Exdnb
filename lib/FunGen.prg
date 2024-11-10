#define adUseClient    3
#define adOpenStatic    3
#define adOpenDynamic   2
#define adLockOptimistic    3
#define adInteger    3
#define adVarChar    200
#define adParamInput   1
#define adParamReturnValue	4
#define adCmdStoredProc 4

Function DBConnect()

	local cStr
	local cServer  := "PERU-MCHUMPITAZ\MSQLSERVER2008"
	local cDB      := "PERU"
	local cUser    := "exdnb"
	local cPwd     := "P3rusql$"
	local n, oField
	public oConnection

    
	// Prepare Connection String
	// using default 32-bit provider installed on all windows PCs
    
	cStr  := "Provider=SQLOLEDB;" + ;
		"Data Source="     + cServer + ";" + ;
		"Initial Catalog=" + cDB     + ";" + ;
		"User ID="         + cUser   + ";" + ;
		"Password="        + cPwd    + ";"
    
	// ---- Conexion al SQL -------
	oConnection := TOleAuto():New( "ADODB.Connection" )
	WITH OBJECT oConnection
	:ConnectionString := cStr
	:CursorLocation   := adUseClient
	:Open()
	END
    
return(oConnection)

Function Inicia(fila,pos_at,dato)
	local campo:=''
	local extracto:=''
	local posi:=0
	local aInicia:={}			
	campo := AllTrim(fila['CAMPO'])
	do case
		case fila['TIPO'] = 'C' .or. fila['TIPO'] = 'T'
			valor_ini := ''					
			posi:=AT( "æ", RIGHT( dato, LEN(dato) - (pos_at + LEN(campo) + 2)))
			extracto := SUBSTR( dato, pos_at + (LEN(campo)+2), posi )
			//valor_ini := extracto + REPLICATE(" ", fila['LONG'] - LEN(AllTrim( extracto)))
			valor_ini:=extracto
		case fila['TIPO'] = 'N'
			valor_ini:=''
			posi := AT( "æ", RIGHT( dato, LEN(dato) - (pos_at + LEN(campo) + 2)))
			extracto := SUBSTR( dato, pos_at + (LEN(campo)+2), posi )
			valor_ini := extracto
		case fila['TIPO'] = 'D'
			valor_ini:=''
			posi := AT( "æ", RIGHT( dato, LEN(dato) - (pos_at + LEN(campo) + 2)))
			extracto := SUBSTR( dato, pos_at + (LEN(campo)+2), posi )
			valor_ini := right(extracto,4) + "-" + substr(extracto,4,2)+ "-" + left(extracto,2)
	endcase
			
	/*
	// Lineas a usar cuando queremos verificar el resultado obtenido

	Aadd( aInicia, {'pos_at' => pos_at,;
		'lencampo' => len(campo)+2,;
		'operacion' => LEN(dato) - pos_at - (LEN(campo)+2),;
		'right' => RIGHT( dato, LEN(dato) - pos_at - (LEN(campo)+2)),;
		'posi' => posi,;
        'lendato' => len(dato),;
		'extracto' => extracto,;
        'valor_ini' => valor_ini,;
		'tipo' => valtype(valor_ini),;
		'fila' => fila;
    })

	return(aInicia)
	*/
			

Return(valor_ini)

Function FFecha(vfecha)
	
	do case
		case MONTH(vfecha) = 1
			mes := "ENE"
		case MONTH(vfecha) = 2
			mes := "FEB"
		case MONTH(vfecha) = 3
			mes := "MAR"
		case MONTH(vfecha) = 4
			mes := "ABR"
		case MONTH(vfecha) = 5
			mes := "MAY"
		case MONTH(vfecha) = 6
			mes := "JUN"
		case MONTH(vfecha) = 7
			mes := "JUL"
		case MONTH(vfecha) = 8
			mes := "AGO"
		case MONTH(vfecha) = 9
			mes := "SEP"
		case MONTH(vfecha) = 10
			mes := "OCT"
		case MONTH(vfecha) = 11
			mes := "NOV"
		case MONTH(vfecha) = 12
			mes := "DIC"
	endcase
	
	ret = STRZERO(DAY(vfecha),2) + " " +  mes + " " + STR(YEAR(vfecha),4)
Return (ret)

Function SaveSeccion(duns,seccion,datacadena)
	local oDatos
	local oCmd
	local oParam

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
	oConnection:Close()

Return


