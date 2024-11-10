//	{% mh_LoadHrb( '/../../lib/tweb/tweb.hrb' ) %}

#define adUseClient    3
#define adOpenStatic    3
#define adOpenDynamic   2
#define adLockOptimistic    3

function main()
	 
    local oSqlConnection
    local oRs
    
    local dat 			:= {=>}
	local aRows 		:= {}
	local hParam		:= AP_GetPairs()
	local cSearch 		:= hParam[ 'search' ] 
	local nOffset 		:= val( hParam[ 'offset' ] )
	local nLimit 		:= val( hParam[ 'limit' ] ) 
    local cTag          := hParam[ 'tag' ] 
	local n 			:= 0
	local nTotal 

  	
	nOffset := IF( nOffset == 0, 1, nOffset )

    oSqlConnection := DBConnect()

    oRs := TOleAuto():New( "ADODB.Recordset" )
    WITH OBJECT oRs
        :ActiveConnection := oSqlConnection        
        :CursorLocation   := adUseClient
        :CursorType       := adOpenDynamic
        :LockType         := adLockOptimistic     
    END

    oRs:Source := "EXEC sp_GetPedidosNumeroDePaginas " + alltrim(str(nLimit)) + ",'" + cTag + "','" + cSearch +"'"
    oRs:Open()
    if  !oRs:Bof() .and. !oRs:Eof()
        oRs:MoveFirst()
        nTotal := oRs:fields("totalFilas"):value
    endif
    oRs:Close()

    oRs:Source := "EXEC sp_GetPedidosPaginado " + alltrim(str((nOffset / nLimit)+1)) + "," + alltrim(str(nLimit)) + ",'" + cTag + "','" + cSearch +"'"
    oRs:Open()
    if  !oRs:Bof() .and. !oRs:Eof()    
        oRs:MoveFirst()
        do while !oRs:Eof()
            Aadd( aRows, {'CODIGO' => oRs:fields("CODIGO"):value,;
                'SUSCRIPTOR' => oRs:fields("SUSCRIPTOR"):value,;
                'CONTRATO' => oRs:fields("CONTRATO"):value,;            
                'RUC' => oRs:fields("RUC"):value,;
                'DUNS_PED' => oRs:fields("DUNS_PED"):value,;
                'NOMBRE' => oRs:fields("NOMBRE"):value,;
                'FECHA_PED' => oRs:fields("FECHA_PED"):value,;
                'PRODUCTO' => oRs:fields("PRODUCTO"):value;
            })
            oRs:MoveNext()
        enddo
    else
        Aadd( aRows, {'CODIGO' => '',;
            'SUSCRIPTOR' => '',;
            'CONTRATO' => '',;
            'RUC' => '',;
            'DUNS_PED' => '',;
            'NOMBRE' => '',;
            'FECHA_PED' => '',;
            'PRODUCTO' => '';
        })
    endif
    
    oRs:Close()
    oSqlConnection:Close()
	
	//	-----------------------------------------------------
	//	Devolver un Hash con 3 keys
	//	total				-> Total registros filtrados, no paginados
	//	totalNotFiltered 	-> Total registros tabla
	//	rows				-> Array de hashes de cada registro 
	//	-----------------------------------------------------
	
	dat[ 'total' ] 				:= nTotal
	dat[ 'totalNotFiltered' ] 	:= nTotal
	dat[ 'rows' ] 				:= aRows


	AP_SetContentType( "application/json" )
	
	?? hb_jsonEncode( dat ) 

retu nil

{% mh_LoadFile( "/../../lib/FunGen.prg" ) %}