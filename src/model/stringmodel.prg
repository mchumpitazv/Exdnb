#include "hbclass.ch"
#define adUseClient    3
#define adOpenStatic    3
#define adOpenDynamic   2
#define adLockOptimistic    3

#include {% TWebInclude() %}

CLASS StringModel 
    
	METHOD New() CONSTRUCTOR    
    METHOD StrSeccion()
		
ENDCLASS

METHOD New() CLASS StringModel

    local oConexionsql

    oConexionsql:= ConexionSql():New()
        		
RETU SELF

METHOD StrSeccion(hParam) CLASS StringModel

    local oRs
    local aRows := {}
    local aParam := hParam
    local seccion := aParam['seccion']

    oRs := TOleAuto():New( "ADODB.Recordset" )
    WITH OBJECT oRs
        :ActiveConnection := oConnection        
        :CursorLocation   := adUseClient
        :CursorType       := adOpenDynamic
        :LockType         := adLockOptimistic     
    END     
    oRs:Source := "EXEC sp_StringSeccion '" + seccion + "'" 
    oRs:Open()
    if  !oRs:Bof() .and. !oRs:Eof()
        oRs:MoveFirst()
        do while !oRs:Eof()
            Aadd( aRows, {'RowNum' => oRs:fields("RowNum"):value,;
                'SECCION' => oRs:fields("SECCION"):value,;
                'CAMPO' => oRs:fields("CAMPO"):value,;
                'DESC' => oRs:fields("DESC"):value,;
                'TIPO' => oRs:fields("TIPO"):value,;
                'LONG' => oRs:fields("LONG"):value,;
                'PIC' => oRs:fields("PIC"):value,;
                'TABLA' => oRs:fields("TABLA"):value,;
                'ORDEN' => oRs:fields("ORDEN"):value,;
                'REQUERIDO' => oRs:fields("REQUERIDO"):value,;
                'FORMULA' => oRs:fields("FORMULA"):value,;
                'FLFOR' => oRs:fields("FLFOR"):value,;
                'FLVER' => oRs:fields("FLVER"):value;
            })
            oRs:MoveNext()
        enddo
    else
        Aadd( aRows, {'RowNum'=>0,;
            'SECCION'=>'',;
            'CAMPO'=>'',;
            'DESC'=>'',;
            'TIPO'=>'',;
            'LONG'=>0,;
            'PIC'=>'',;
            'TABLA'=>'',;
            'ORDEN'=>0,;
            'REQUERIDO'=>'',;
            'FORMULA'=>'',;
            'FLFOR'=>0,;
            'FLVER'=>0;
        })
    endif
    oRs:Close()
    oConnection:Close()

RETU aRows


{% mh_LoadFile( "/src/model/provider/conexionsql.prg" ) %}
