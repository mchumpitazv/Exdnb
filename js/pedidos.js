var oBrw = new TWebBrowse('ringo')

function MyQuery(params) {

    var cSearch = $('#search').val()
    var cTag = $('#search_name').data('tag')

    params.search = cSearch
    params.tag = cTag

    console.log('MyQuery',params)

    return params
}

// Load data...

function Load() {

    oBrw.SetQuery(MyQuery)
}


//	----------------------------------

function ImpHtml() {
    
    var hParam = new Object();
    var aSelect = oBrw.Select()
        
    if(aSelect.length == 1){
        hParam['action'] = 'print'
        hParam['codigo'] = aSelect[0].CODIGO;
        hParam['duns'] = aSelect[0].DUNS_PED;
        hParam['producto'] = aSelect[0].PRODUCTO;
        hParam['suscriptor'] = aSelect[0].SUSCRIPTOR;
        hParam['ruc'] = aSelect[0].RUC;
        hParam['yearlimite'] = 5;

        if(hParam['duns']==''){
            MsgInfo("El Ticket no registra DUNS...");
            return false;
        }else{
            console.log('Print Ticket',hParam);   
            console.log('Print Ticket', URL_ROUTE);
            MsgServer( URL_ROUTE, hParam, Post_html );
        }                
                                               
    }else{
        MsgInfo("Debe Seleccionar uno de los Tickets...");
    }
}

function Post_html(hres){
    console.log('Post_html',hres);
    //console.log('hDataString->',hres.hDataString);    
    //MsgInfo('Aqui');
    //location.reload();
    
}


//	----------------------------------

function Search_Select_Tag(cTag) {
    $('#search_name').data('tag', cTag)
    $('#search_total').html('0')
    $('#search_name').html(cTag)
    $('#search').focus()

}
//	----------------------------------

$(document).ready(function () {

    Search_Select_Tag('CODIGO')

    //TWebIntro( 'search', Load ) 						

    console.info('pedidos.js','Pedidos ready !')
});
