#define adUseClient    3
#define adOpenStatic    3
#define adOpenDynamic   2
#define adLockOptimistic    3

#include {% TWebInclude() %}

CLASS TcanualModel 
    
	METHOD New() CONSTRUCTOR    
    METHOD TcanualGet()
		
ENDCLASS

METHOD New() CLASS TcanualModel

    local oConexionsql

    oConexionsql:= ConexionSql():New()
        		
RETU SELF

METHOD TcanualGet(hParam) CLASS TcanualModel

    local oRs
    local aRows := {}
    local aParam := hParam
    local year := aParam[1]['year']
    
    oRs := TOleAuto():New( "ADODB.Recordset" )
    WITH OBJECT oRs
        :ActiveConnection := oConnection        
        :CursorLocation   := adUseClient
        :CursorType       := adOpenDynamic
        :LockType         := adLockOptimistic     
    END     

    oRs:Source := "EXEC dbo.sp_TcanualGet '" + year +"'" 
    oRs:Open()
    if  !oRs:Bof() .and. !oRs:Eof()
            oRs:MoveFirst()
            do while !oRs:Eof()
                Aadd( aRows, {'YEAR' => oRs:fields("YEAR"):value,;                
                    'TC' =>  oRs:fields("TC"):value;
                })
                oRs:MoveNext()
            enddo
        else
            Aadd( aRows, {'YEAR' => '',;
                'TC' => '';
            })
        endif

        oRs:Close()
        oConnection:Close()

RETU aRows

{% mh_LoadFile( "/src/model/provider/conexionsql.prg" ) %}
