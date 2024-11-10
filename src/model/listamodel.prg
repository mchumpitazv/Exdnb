#define adUseClient    3
#define adOpenStatic    3
#define adOpenDynamic   2
#define adLockOptimistic    3

#include {% TWebInclude() %}

CLASS ListaModel 

    METHOD New() CONSTRUCTOR
    METHOD ListaGetAll()
    METHOD ListaGet()
		
ENDCLASS

METHOD New() CLASS ListaModel

    local oConexionsql

    oConexionsql:= ConexionSql():New()
        							

RETU SELF

METHOD ListaGetAll() CLASS ListaModel

    local oRs
    local aListas := {}    
    oRs := TOleAuto():New( "ADODB.Recordset" )
    WITH OBJECT oRs
        :ActiveConnection := oConnection        
        :CursorLocation   := adUseClient
        :CursorType       := adOpenDynamic
        :LockType         := adLockOptimistic     
    END     
    oRs:Source := "EXEC sp_ListaGetAll" 
    oRs:Open()
    if  !oRs:Bof() .and. !oRs:Eof()
        oRs:MoveFirst()
        do while !oRs:Eof()
            Aadd( aListas, {'NOMBRE' => Alltrim(oRs:fields("NOMBRE"):value),;
                'CLAVE' => Alltrim(oRs:fields("CLAVE"):value),;
                'LENGUAGE' => Alltrim(oRs:fields("LENGUAGE"):value),;
                'DESCRIP' => Alltrim(oRs:fields("DESCRIP"):value),;
                'ENGLISH' => Alltrim(oRs:fields("ENGLISH"):value);
            })
            oRs:MoveNext()
        enddo
    else
        Aadd( aListas, {'NOMBRE'=>'',;
            'CLAVE'=>'',;
            'LENGUAGE'=>'',;
            'DESCRIP'=>'',;
            'ENGLISH'=>'';   
        })
    endif
    oRs:Close()
    oConnection:Close()

RETU aListas

METHOD ListaGet(hParam) CLASS ListaModel
    
    //local lista := hParam['lista']
    local lista := hParam['lista']
    local oRs
    local aListas := {}
    local vtabla:=''
    if valtype(lista)='C'
        vtabla := lista
    else
        vtabla := lista['lista']
    endif
    oRs := TOleAuto():New( "ADODB.Recordset" )
    WITH OBJECT oRs
        :ActiveConnection := oConnection        
        :CursorLocation   := adUseClient
        :CursorType       := adOpenDynamic
        :LockType         := adLockOptimistic     
    END     
    oRs:Source := "EXEC sp_ListaGet '" + lista +"'" 
    oRs:Open()
    if  !oRs:Bof() .and. !oRs:Eof()
        oRs:MoveFirst()
        do while !oRs:Eof()
            Aadd( aListas, {'NOMBRE' => Alltrim(oRs:fields("NOMBRE"):value),;
                'CLAVE' => Alltrim(oRs:fields("CLAVE"):value),;
                'LENGUAGE' => Alltrim(oRs:fields("LENGUAGE"):value),;
                'DESCRIP' => Alltrim(oRs:fields("DESCRIP"):value),;
                'ENGLISH' => Alltrim(oRs:fields("ENGLISH"):value);
            })
            oRs:MoveNext()
        enddo
    else
        Aadd( aListas, {'NOMBRE'=>'',;
            'CLAVE'=>'',;
            'LENGUAGE'=>'',;
            'DESCRIP'=>'',;
            'ENGLISH'=>'';   
        })
    endif
    oRs:Close()
    oConnection:Close()

RETU aListas

{% mh_LoadFile( "/src/model/provider/conexionsql.prg" ) %}
