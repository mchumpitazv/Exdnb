#define adUseClient    3
#define adOpenStatic    3
#define adOpenDynamic   2
#define adLockOptimistic    3


CLASS ConexionSql

    METHOD New(oController) CONSTRUCTOR
    METHOD Close(oController)
    METHOD Usuario(cUsuario)
    
ENDCLASS

METHOD New(oController) CLASS ConexionSql

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
    
RETU SELF

METHOD Close(oController) CLASS ConexionSql

    oConnection:Close()  

RETURN SELF

METHOD Usuario( cUsuario ) CLASS ConexionSql

    local oRs
    local aUsuarios := {}    
    oRs := TOleAuto():New( "ADODB.Recordset" )
    WITH OBJECT oRs
        :ActiveConnection := oConnection        
        :CursorLocation   := adUseClient
        :CursorType       := adOpenDynamic
        :LockType         := adLockOptimistic     
    END
    oRs:Source := "EXEC sp_Usuario '" + cUsuario + "' " 
    oRs:Open()
    if  !oRs:Bof() .and. !oRs:Eof()
        oRs:MoveFirst()
        do while !oRs:Eof()
            Aadd( aUsuarios, {oRs:fields("CODIGO"):value,;
                oRs:fields("NOMBRE"):value,;
                oRs:fields("PASSWORD"):value;            
            })           
            oRs:MoveNext()
        enddo
    else
        Aadd( aUsuarios, {'',;
            '',;
            '';            
        })
    endif
    oRs:Close()
    oConnection:Close()

RETU aUsuarios
    
    