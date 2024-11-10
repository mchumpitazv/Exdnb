#define adUseClient    3
#define adOpenStatic    3
#define adOpenDynamic   2
#define adLockOptimistic    3

#include {% TWebInclude() %}

CLASS SeccionModel 
    
	METHOD New() CONSTRUCTOR    
    METHOD GetSeccion()
		
ENDCLASS

METHOD New() CLASS SeccionModel

    local oConexionsql

    oConexionsql:= ConexionSql():New()
        		
RETU SELF

METHOD GetSeccion(hParam) CLASS SeccionModel

    local oRs
    local aRows := {}
    local aParam := hParam
    local duns := aParam['duns'] 
    oRs := TOleAuto():New( "ADODB.Recordset" )
    WITH OBJECT oRs
        :ActiveConnection := oConnection        
        :CursorLocation   := adUseClient
        :CursorType       := adOpenDynamic
        :LockType         := adLockOptimistic     
    END     
    oRs:Source := "EXEC sp_SeccionDuns '" + duns + "'" 
    oRs:Open()
    if  !oRs:Bof() .and. !oRs:Eof()
        oRs:MoveFirst()
        do while !oRs:Eof()
            Aadd( aRows, {'SECCION' => oRs:fields("SECCION"):value,;
                'NOMBRE' => oRs:fields("NOMBRE"):value,;
                'EXISTE' => oRs:fields("EXISTE"):value;            
            })
            oRs:MoveNext()
        enddo
    else
        Aadd( aRows, {'',;
            '',;
            '';            
        })
    endif
    oRs:Close()
    oConnection:Close()

RETU aRows


{% mh_LoadFile( "/src/model/provider/conexionsql.prg" ) %}
