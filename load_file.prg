//	{% mh_LoadHrb( 'lib/tweb/tweb.hrb' ) %}

#include {% TWebInclude() %}


/*	---------------------------------------------------------------------------
	GetMsgUpload() devuelve la informacion de subida de un fichero en un hash:
	blob - Fichero decodificado
	file - hash con info de fichero: name, type, size, ext
	data - hash con variables adicionales que se han enviado junto al fichero
	--------------------------------------------------------------------------- */

function main()

	local cPath 	:= hb_getenv( 'PRGPATH' ) + '/upload/'
	local h 		:= GetMsgUpload()	
	local lSuccess 	:= .f.
	local cFile
	local cnamefile
	
	AP_SetContentType( "application/json" )		
	
	cFile 		:= cPath + h[ 'file' ][ 'name' ]
	cnamefile	:= h[ 'file' ][ 'name' ]

	if ( h[ 'file' ][ 'ext' ] $ 'xls,xlsx' )
		
		lSuccess 	:= hb_MemoWrit( cFile , h[ 'blob' ] )		
		hresponse	:= { 'success' => lSuccess, 'filexls' => cFile, 'namefile' => cnamefile ,'info' => h[ 'file' ], 'data' => h[ 'data' ] }
	else
		hresponse	:= { 'success' => lSuccess, 'msg' => 'Extension no Permitida: ' + h[ 'file' ][ 'ext' ] }		
	endif

	?? hb_jsonencode( hresponse )			
retu nil
