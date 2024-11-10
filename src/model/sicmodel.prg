#define adUseClient    3
#define adOpenStatic    3
#define adOpenDynamic   2
#define adLockOptimistic    3

#include {% TWebInclude() %}

CLASS SicModel 
    
	METHOD New() CONSTRUCTOR    
    METHOD SicGet()
		
ENDCLASS

METHOD New() CLASS SicModel

    local oConexionsql

    oConexionsql:= ConexionSql():New()
        		
RETU SELF

METHOD SicGet(hParam) CLASS SicModel

    local oRs
    local aRows := {}
    local aParam := hParam
    //local sic := aParam[1]['sic']
    local sic := aParam['sic']
    
    oRs := TOleAuto():New( "ADODB.Recordset" )
    WITH OBJECT oRs
        :ActiveConnection := oConnection        
        :CursorLocation   := adUseClient
        :CursorType       := adOpenDynamic
        :LockType         := adLockOptimistic     
    END     

    oRs:Source := "EXEC dbo.sp_SicGet '" + sic +"'" 
    oRs:Open()
    if  !oRs:Bof() .and. !oRs:Eof()
            oRs:MoveFirst()
            do while !oRs:Eof()
                Aadd( aRows, {'CODIGO' => oRs:fields("CODIGO"):value,;                
                    'INDUSTRIA' =>  oRs:fields("INDUSTRIA"):value;
                })
                oRs:MoveNext()
            enddo
        else
            Aadd( aRows, {'CODIGO' => '',;
                'INDUSTRIA' => '';
            })
        endif

        oRs:Close()
        oConnection:Close()

RETU aRows

{% mh_LoadFile( "/src/model/provider/conexionsql.prg" ) %}
