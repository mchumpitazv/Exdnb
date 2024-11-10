//	{% mh_LoadHrb( '/../../lib/tweb/tweb.hrb' ) %}

#define adUseClient    3
#define adOpenStatic    3
#define adOpenDynamic   2
#define adLockOptimistic    3

function main()
         
    local dat 			:= {=>}
	local aDuns 		:= {}
	local hParam		:= AP_GetPairs()
	local cSearch 		:= hParam[ 'search' ] 
	local nOffset 		:= val( hParam[ 'offset' ] )
	local nLimit 		:= val( hParam[ 'limit' ] ) 
    local cTag          := hParam[ 'tag' ] 
	local n 			:= 0
	local nTotal 

    Aadd( aDuns, { 'RUC' => '123456789', 'DUNSNUM' => '987654321', 'NOMBRE' => 'Charly Aubia' } )
    Aadd( aDuns, { 'RUC' => '234567890', 'DUNSNUM' => '987654322', 'NOMBRE' => 'Maria de la O' } )
    Aadd( aDuns, { 'RUC' => '456789013', 'DUNSNUM' => '987654323', 'NOMBRE' => 'John Kocinsky' } )	
		
	
	//	-----------------------------------------------------
	//	Debemos devolver un hash con 3 keys
	//	total				-> Total registros filtrados, no paginados
	//	totalNotFiltered 	-> Total registros tabla
	//	rows				-> Array de hashes de cada registro 
	//	-----------------------------------------------------
	
	dat[ 'total' ] 				:= 50
	dat[ 'totalNotFiltered' ]	:= 100
	dat['seacrh']				:= cSearch
	dat[ 'rows' ] 				:= aDuns


	AP_SetContentType( "application/json" )
	
	?? hb_jsonEncode( dat ) 

retu nil