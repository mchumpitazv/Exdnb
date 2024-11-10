var oParam = new Object()

// Recepcionar variable desde Prg imporbal.view

oParam['hParam'] = <$  SetDataJS( aParam ) $>;
oParam['aHojas'] = <$  SetDataJS( aHojas ) $>;

function FImporDaot() {
        
    oParam['tipo']= $('#tipo').val();
    oParam['hoja']= $('#hoja').val();    

    console.log('ImporDaot.js',oParam);
    
    if(oParam['hoja']!=''){
        MsgServer('/exdnb/fimpordaot.prg',oParam, Post_ImpDaot);
    }else{
        MsgInfo("Archivo Excel no corresponde...");
        return false;
    }
};

function Post_ImpDaot(dat){
    console.log('Post_ImportDaot',dat);
};

function FSalir(){
    location.reload();
};


$(document).ready(function () {

    //$('#proceso').prop("disabled",true);
    //$('#balance').prop("disabled",true);
    //$('#tipo').prop("disabled",true);					
        
});