var oParam = new Object()

// Recepcionar variable desde Prg imporbal.view

oParam['hParam'] = <$  SetDataJS( aParam ) $>;
oParam['aHojas'] = <$  SetDataJS( aHojas ) $>;

function FImporBal() {
    
    oParam['balance']= $('#balance').val();
    oParam['tipo']= $('#tipo').val();
    oParam['hoja']= $('#hoja').val();
    oParam['posicion']= $('#posicion').val();
    oParam['opcion']='imporbal'

    console.log('Imporbal.js',oParam);
    
    if(oParam['hoja']!=''){
        MsgServer('/exdnb/fimporbal.prg',oParam, Post_Import);
    }else{
        MsgInfo("Archivo Excel no corresponde...");
        return false;
    }
};

function Post_Import(dat){
    console.log('Post_Import',dat);
};

function FvalPosicion(){
    var vposicion;
    vposicion = parseInt($("#posicion").val());
    if(vposicion<0 || vposicion>4){
        MsgInfo("Valor fuera de rango...",null, function() { $('#posicion').focus()  });
    }
};

function FDesplaza(){
    oParam['balance']= $('#balance').val();
    oParam['tipo']= $('#tipo').val();
    oParam['hoja']= $('#hoja').val();
    oParam['posicion']= $('#posicion').val();
    oParam['opcion']='desplazar'

    console.log('Imporbal.js',oParam);
    
    if(oParam['hoja']!=''){
        MsgServer('/exdnb/fimporbal.prg',oParam, Post_Import);
    }else{
        MsgInfo("Archivo Excel no corresponde...");
        return false;
    }

};

function FSalir(){
    location.reload();

};


$(document).ready(function () {

    //$('#proceso').prop("disabled",true);
    //$('#balance').prop("disabled",true);
    //$('#tipo').prop("disabled",true);					
        
});