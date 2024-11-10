var oParam = new Object()

// Recepcionar variable desde Prg imporbal.view

oParam['hParam'] = <$  SetDataJS( aParam ) $>;
oParam['aHojas'] = <$  SetDataJS( aHojas ) $>;

function FImporSqr() {
            
    oParam['hoja']= $('#hoja').val();    

    console.log('ImporSqr.js',oParam);
    
    if(oParam['hoja']!=''){
        MsgServer('/exdnb/fimporsqr.prg',oParam, Post_ImpSqr);
    }else{
        MsgInfo("Archivo Excel no corresponde...");
        return false;
    }
};

function Post_ImpSqr(dat){
    console.log('Post_ImportSqr',dat);
};

function FSalir(){
    location.reload();
};


$(document).ready(function () {

    //$('#proceso').prop("disabled",true);
    //$('#balance').prop("disabled",true);
    //$('#tipo').prop("disabled",true);					
        
});