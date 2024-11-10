#define adUseClient    3
#define adOpenStatic    3
#define adOpenDynamic   2
#define adLockOptimistic    3

#include {% TWebInclude() %}

CLASS DunsModel 

    DATA cId
	DATA oDataset	
	DATA hSearch 					INIT {=>}
	DATA lCanLoadAll				INIT .t.
	DATA nMax						INIT 1000

	METHOD New() CONSTRUCTOR
    METHOD DunsGetAll(oController)
    METHOD DunsGet(oController)
		
ENDCLASS

METHOD New() CLASS DunsModel

    local oConexionsql

    oConexionsql:= ConexionSql():New()
        	
	//	Define main tag index

		::cId 		:= 'id'

	//	Define data Dataset. These will be the only fields that I will allow to work
	
		DEFINE BROWSE DATASET ::oDataset ALIAS 'Duns'

			//FIELD 'ruc' 	    UPDATE  VALID {|o,uValue,hRow,cAction| ValidProd( o, uValue, hRow, cAction  ) } OF ::oDataset
            FIELD 'RUC' 	    UPDATE  OF ::oDataset
			FIELD 'DUNSNUM' 	UPDATE  OF ::oDataset
			FIELD 'NOMBRE' 		UPDATE  OF ::oDataset
			

		
	//	Define if can Loading all records...  (for small tables)
	
		::lCanLoadAll := .t. 
	
	
	//	Define Searchs by Tag 
	
		::hSearch[ 'RUC' ] 	    := { 'RUC', 'RUC' }
		::hSearch[ 'DUNSNUM' ] 	:= { 'DUNSNUM', 'DUNSNUM'}
		::hSearch[ 'NOMBRE' ] 	:= { 'NOMBRE', 'NOMBRE', {|u| lower(u) } }
						

RETU SELF

METHOD DunsGetAll(oController) CLASS DunsModel

    local oRs
    local aDuns := {}    
    oRs := TOleAuto():New( "ADODB.Recordset" )
    WITH OBJECT oRs
        :ActiveConnection := oConnection        
        :CursorLocation   := adUseClient
        :CursorType       := adOpenDynamic
        :LockType         := adLockOptimistic     
    END     
    oRs:Source := "EXEC sp_DunsGetAll" 
    oRs:Open()
    if  !oRs:Bof() .and. !oRs:Eof()
        oRs:MoveFirst()
        do while !oRs:Eof()
            Aadd( aDuns, {'RUC' => oRs:fields("RUC"):value,;
                'DUNSNUM' => oRs:fields("DUNSNUM"):value,;
                'NOMBRE' => oRs:fields("NOMBRE"):value;            
            })
            oRs:MoveNext()
        enddo
    else
        Aadd( aDuns, {'RUC'=>'',;
            'DUNSNUM'=>'',;
            'NOMBRE'=>'';            
        })
    endif
    oRs:Close()
    oConnection:Close()

RETU aDuns

METHOD DunsGet(hParam) CLASS DunsModel

    local oRs
    local aDuns := {}
    local duns := hParam['duns']
    local ruc := hParam['ruc']
    oRs := TOleAuto():New( "ADODB.Recordset" )
    WITH OBJECT oRs
        :ActiveConnection := oConnection        
        :CursorLocation   := adUseClient
        :CursorType       := adOpenDynamic
        :LockType         := adLockOptimistic     
    END     
    oRs:Source := "EXEC sp_DunsGet '" + duns + "','" + ruc + "'" 
    oRs:Open()
    if  !oRs:Bof() .and. !oRs:Eof()
        oRs:MoveFirst()
        do while !oRs:Eof()
            Aadd( aDuns, {'RUC' => oRs:fields("RUC"):value,;
                'DUNSNUM' => oRs:fields("DUNSNUM"):value,;
                'NOMBRE' => oRs:fields("NOMBRE"):value,;
                'VIGENCIA' => oRs:fields("VIGENCIA"):value,;
                'BALANCE' => oRs:fields("BALANCE"):value;
            })
            oRs:MoveNext()
        enddo
    else
        Aadd( aDuns, {'RUC'=>'',;
            'DUNSNUM'=>'',;
            'NOMBRE'=>'',;
            'VIGENCIA' =>'',;
            'BALANCE' =>'';
        })
    endif
    oRs:Close()
    oConnection:Close()

RETU aDuns

{% mh_LoadFile( "/src/model/provider/conexionsql.prg" ) %}
