var oParam = new Object()
var oBrw = new TWebBrowse('ringo')


// Recepcionar variable desde Prg duns_upd.view

oParam['duns'] = <$  SetDataJS( aParam ) $>


//console.log(oParam['duns'])

function checkFormatter(value,row) {
    
    if ( row.EXISTE == "S" ){
        //return '<img src="/exdnb/images/ball_green.png">' + value            
        return '<img src="{{ AppUrlImg() + 'ball_green.png' }}">';
    }        
    else {
        return '<img src="{{ AppUrlImg() + 'ball_red.png' }}">';       
    }               
}

function editRow() {
    var hParam = new Object();
    var row = oBrw.Select();
        
    if(row.length > 0){
        hParam['action'] = 'edit'
        hParam['duns'] = oParam['duns'];
        hParam['seccion'] = row[0].SECCION;
        hParam['nomsec'] = row[0].NOMBRE;
        hParam['recopila'] = false;
        hParam['exist'] = new Array();

        switch(true) {

            case (hParam['seccion']!="01") :
                //console.log('editRow',hParam);                
                MsgServer( URL_ROUTE, hParam, dunPost_edt );
                //MsgServer('/exdnb/secdat_upd.prg',hParam, dunPost_edt);  
                break;
            case (hParam['seccion'] == '01') :                
                if($('#switch').prop('checked' )){// Recopilacion desde otras secciones
                    console.log('Recopilando...');
                    hParam['recopila'] = true;                    
                    var aExist = new Array();
                    // aExist[seccion,campo,valor,fila,tipo]                    
                    aExist=[['02','ac','',44,''],['02','av02','',47,''],['02','aw02','',47,''],
                    ['06','02d1','',48,''],['06','ps31','',48,''],['06','02d1','',49,''],['06','70a1','',49,''],
                    ['09','ga02','',48,''],['09','ga57','',48,''],['09','ga02','',49,''],['09','ga63','',49,''],
                    ['14','af00','',48,''],['14','af42','',48,''],['14','af00','',49,''],['14','ag03','',49,''],
                    ['04','au01','',54,'N'],['04','au02','',54,'N']];
                    hParam['exist'] = aExist;
                    MsgServer('/exdnb/exist.prg',hParam, dunPost_Exist);                    
                }else{
                    MsgServer( URL_ROUTE, hParam, dunPost_edt );
                }                                  
                break;
             default:
                break;
           }                                       
    }else{
        MsgInfo("Debe Seleccionar la Seccion a Editar...");
    }
    
}

function dunPost_Exist(hres){
    var hParam = new Object();
    hParam = hres['hParam']
    console.log('Exist',hres['hParam']);
    // Fundada (02 - 44)                    
    // Capital (02 - 47)
    // Patrimonio (06 - 48)
    // Ventas (06 - 49)
    // Personal (04 - 54)
    MsgServer( URL_ROUTE, hParam, dunPost_edt );
}

function dunPost_edt(hres){
    //console.log('dunPost_edt',hres);
    //console.log('hDataString->',hres.hDataString);    
    //MsgInfo('Aqui');    
    $("#editModal").modal({
        backdrop: 'static',
        keyboard: false,
        show: true
    });
}

$(document).ready(function () {

    //Search_Select_Tag('Id')

    //TWebIntro( 'search', Load ) 						
        
});