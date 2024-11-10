var oBrw = new TWebBrowse( ID_BROWSE )		

//	Styles

function MyRowStyle(row, index) {

	if ( oBrw.IsRowIdUpdated( row[ UNIQUEID ] ) == true ) {				
		return { classes: 'myrow' }	
	} else {
		return {}			
	}										
}				

function MyCssId( value, row, index ) {			
			
	return { classes: 'myid' }
}

function MyId( value ) {													
	
	if ( typeof value == 'string' && value.substring(0, 1) == '$' ) {
		return '<i class="far fa-edit"></i>'					
	} else
		return value 
}				