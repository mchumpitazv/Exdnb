var oBrw = new TWebBrowse('ringo')
var hParam = new Object();

function MyQuery(params) {

    var cSearch = $('#search').val()
    var cTag = $('#search_name').data('tag')

    params.search = cSearch
    params.tag = cTag

    console.log('MyQuery',params)

    return params
}

// Load data...

function Load2() {

    oBrw.SetQuery(MyQuery)
}


//	----------------------------------

function Nom_Search() {

    var cUrl = "{{ mc_Route( 'd.duns_search' ) }}"
    var aHeader = { 'RUC': 'Ruc', 'NOMBRE': 'Empresa' }

    TWebBrwSearch(cUrl, aHeader, Post_Cli_Search, '', 'B�squeda de Clientes')
}

function Post_Cli_Search(row) {
    console.log('Post_Cli_Search',row)

    if (row) {
        $('#search').val(row.id_cli)
        Search_Select_Tag('cliente')
        Load()
    } else {

    }

}
//	----------------------------------

function DunsEdit() {

    var aSelect = oBrw.Select()
        
    if (aSelect.length == 1) {

        var oItem = aSelect[0]        
        var cDuns = oItem.DUNSNUM
        var cUrl = '{% mc_route( 'd.update' ) %}' + '/' + cDuns        

        window.location.href = cUrl
    }
}

// ------------------------------------

function DunsNew() {

    var cUrl = '{% mc_route( 'd.update' ) %}' + '/0'

    window.location.href = cUrl
}

//------------------------------------------

function DunsImport() {
    
    var aSelect = oBrw.Select()
        
    if (aSelect.length == 1) {
        hParam['action'] = 'import'
        hParam['duns'] = aSelect[0]['DUNSNUM']
        
        $("#importModal").modal({
            backdrop: 'static',        
            keyboard: false,
            show: true
        });

        $("#btnClose").click(function() {
            location.reload();
        });
        
        $("#btnAccept").click(function() {
            hParam['proceso'] = $("#proceso").val();
            $("#importModal").modal('hide');
            console.log('DunsImport=>', hParam);
            MsgServer( URL_ROUTE, hParam, dunPost_impor );
        });        
    }
}


function dunPost_impor(hres){

}

// -----------------------------------------

function loadFile() {
				
    var oParam = new Object()        

    var o = new TWebUpload( 'myupload', '/exdnb/load_file.prg', Post_loadFile, oParam )       

    o.Init()					
}

function Post_loadFile( dat ) {
				
    console.log( 'Post_loadFile', dat );
    hParam['filexls'] = dat['filexls'];
    //console.log($('#proceso').val());

    if(dat['success']==true){
        // Habilitar Selects

        $('#proceso').prop("disabled",false);
        $('#balance').prop("disabled",false);
        $('#tipo').prop("disabled",false);
        $('#posicion').prop("disabled",false);

        // Mostrar nombre del archivo
        $('#namexls').html(dat['namefile']);
    }    
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

    Search_Select_Tag('RUC')

    //TWebIntro( 'search', Load ) 						

    console.info('duns.js','Duns ready !')
});