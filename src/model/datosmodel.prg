#define adUseClient    3
#define adOpenStatic    3
#define adOpenDynamic   2
#define adLockOptimistic    3

#include {% TWebInclude() %}

CLASS DatosModel 
    
	METHOD New() CONSTRUCTOR    
    METHOD DatSeccion()    
		
ENDCLASS

METHOD New() CLASS DatosModel

    local oConexionsql

    oConexionsql:= ConexionSql():New()
        		
RETU SELF

METHOD DatSeccion(hParam) CLASS DatosModel

    local oRs
    local aRows := {}
    local aParam := hParam
    local duns := aParam['duns'] 
    local seccion := aParam['seccion']
    local vduns :=''
    
    if valtype(duns)='C'
        vduns := duns
    else
        vduns := duns['duns']
    endif

    oRs := TOleAuto():New( "ADODB.Recordset" )
    WITH OBJECT oRs
        :ActiveConnection := oConnection        
        :CursorLocation   := adUseClient
        :CursorType       := adOpenDynamic
        :LockType         := adLockOptimistic     
    END     
    oRs:Source := "EXEC sp_DatSeccion '" + vduns + "','" + seccion +"'" 
    oRs:Open()
    if  !oRs:Bof() .and. !oRs:Eof()
        oRs:MoveFirst()
        do while !oRs:Eof()
            Aadd( aRows, {'SECCION' => oRs:fields("SECCION"):value,;                
                'DATO' =>  hb_strToUTF8(oRs:fields("DATO"):value),;
                'NUMERO' => oRs:fields("NUMERO"):value;            
            })
            oRs:MoveNext()
        enddo
    else
        Aadd( aRows, {'SECCION'=> seccion,;
            'DATO'=>'',;
            'NUMERO'=>0;
        })
    endif
    oRs:Close()
    oConnection:Close()

RETU aRows


{% mh_LoadFile( "/src/model/provider/conexionsql.prg" ) %}
