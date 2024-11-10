var oParam = new Object()

// Recepcionar variable desde Prg secdat_upd.view

oParam['duns']  = <$  SetDataJS( hParam ) $>;
oParam['dataS'] = <$  SetDataJS( hDataString ) $>;
oParam['dataD'] = <$  SetDataJS( hDataDatos ) $>;
oParam['dato'] = <$  SetDataJS( dato ) $>;
oParam['Inicia'] = <$  SetDataJS( aInicia ) $>;

console.log('secdat_upd',oParam['duns']['duns']);
console.log('secdat_upd',oParam['duns']['seccion']);
console.log('Arreglo Strings',oParam['dataS']);
console.log('Arreglo Datos',oParam['dataD']);
console.log('dato',oParam['dato']);
console.log('Inicia', oParam['Inicia']);

$(document).ready(function () {

    //$("#pickTitle").val(0).text()=oParam['duns']['seccion'];
    $("#pickTitle").html('Seccion ' + oParam['duns']['nomsec']);
    $("#editModal").modal({
        backdrop: 'static',        
        keyboard: false,
        show: true
    });   						
    
    console.log('secdat_upd')
});

$("#btnClose").click(function() {
    location.reload();
});

$("#btnSave").click(function() {
    var sParam = new Object();
    var aStrings=new Array();
    var aValores = new Array();
    var aValoresChg = new Array();
    var valor = new Array(); // Para poder utilizar las formulas de la tabla string
    var fvalid = false;
    var vid;
    var loop=0;
    //MsgInfo("Guardando Informacion 000010640...");
    
	sParam[ 'action' ] = 'save';
    sParam['duns'] = oParam['duns']['duns'];
    sParam['seccion'] = oParam['duns']['seccion'];
    aStrings = oParam['dataS'];    
    

    //MsgInfo(aCampos.length);
		
	MsgYesNo( '¿Desea Grabar la informacion?', 'Grabar', null, 
		function(){
            // Recuperar datos a guardar en una matriz
            for (var i = 0; i < (aStrings.length); i++) {
                vid="#id" + aStrings[i]["CAMPO"];                
                aValores.push([aStrings[i]["CAMPO"],$(vid).val()]);                                           
            }
            sParam['data']=aValores;
            console.log("aValores",aValores);
                     
            // Realizar validaciones

            switch(oParam['duns']['seccion']){
                case "01":
                    fvalid = sec01_ok(aValores);
                    break;
                case "02":
                    fvalid = sec02_ok(aValores);
                    break;
                case "06":
                    fvalid = sec06_ok(aValores,aStrings,"S");
                    break;
                case "07":
                    fvalid = sec07_ok(aValores,aStrings);
                    if(fvalid){                        
                        aValoresChg = aValores;

                        // Los campos numericos vacios ponerlos a "0"                        
                        for (var i = 65; i < 75; i++) {
                            if(aStrings[i]["TIPO"]=='N'){
                                if(aValoresChg[i][1]==''){
                                    aValoresChg[i][1]='0';
                                }
                            }
                        }
                        
                        // Si hay informacion L4, reacomodar informacion de L3,L2;L1

                        for(var i=65;i<75;i++){
                            loop += parseFloat(aValoresChg[i][1]);                
                        }
                        if(loop !=0){
                            for(var i=0;i<63;i++){
                                aValores[i][1]=aValores[i+21][1];
                            }
                        }

                        // Dejar en blanco L4
                        
                        for(var i=63;i<84;i++){
                            aValores[i][1]='';                
                        }
                    }
                    break;
                case "09":
                    fvalid = sec09_ok(aValores,aStrings);
                    break;                
                case "22":
                    fvalid = sec06_ok(aValores,aStrings,"N");                    
                    break;
                default:
                    break;
            }

            //fvalid = false;

            if(fvalid==true){
                var datacadena="";
                for(var i=0;i<aValores.length;i++){
                    switch(aStrings[i]['TIPO']){
                        case 'N':
                            valor.push(parseFloat(aValores[i][1]));
                            break;
                        case 'D':
                            valor.push((aValores[i][1]).substr(8,2) + '/' + (aValores[i][1]).substr(5,2) + '/' + (aValores[i][1]).substr(0,4));
                            break;
                        default:
                            valor.push(aValores[i][1]);
                            break;
                    }                    
                    if(aValores[i][1] !='' && aValores[i][1]!='0'){
                        
                        //datacadena = datacadena + "æ" + aValores[i][0] + aValores[i][1];
                        datacadena = datacadena + "æ" + aValores[i][0] + valor[i];
                    }                    
                }
                sParam['valor'] = valor;
                sParam['datacadena'] = datacadena;
                //console.log('valor->save',valor);
                //console.log('datacadena->save',datacadena);
                
                MsgServer( URL_ROUTE, sParam, Post_Save )
            }
            else{
                //MsgInfo("Datos Incorrectos...");
            }
			
		})
    //location.reload();
});

function Post_Save( dat ) {
    console.log('valor->postsave',dat['valor']);
    console.log('valor33->postsave',dat['valor33']);
    console.log('valor34->postsave',dat['valor34']);
    //location.reload();
}

function sec01_ok(aValores){
    var sParam = new Object();
    var aAreaTel = new Array('41','43','83','54','66','76','1','84','67','62','56','64','44','74','1','65','82','53','63','73','51','42','52','72','61');
    var areaok = '';

    sParam['action'] = 'ValidSic';
    sParam['data']=aValores;
    
    // Razon Social
    if(aValores[6][1]==''){
        MsgInfo("Debe registrar la Razon Social...");
        return false;
    }
    // Direccion
    if(aValores[11][1]==''){
        MsgInfo("Debe registrar la Direccion...");
        return false;
    }

    // Ciudad
    if(aValores[14][1]==''){
        MsgInfo("Debe registrar la Ciudad...");
        return false;
    }
    // Codigo Postal
    if((aValores[14][1]=="LIMA" || aValores[14][1]=="CALLAO") && aValores[15][1]==""){
        MsgInfo("Debe registrar el Codigo Postal...");
        return false;
    }
    // Ubigeo
    if(aValores[16][1]==''){
        MsgInfo("Debe registrar el Ubigeo...");
        return false;
    }

    if(aValores[16][1]!='' && aValores[18][1]!='' ){
        //areaok = (aValores[16][1]).slice(0,2);
        areaok = aAreaTel[parseInt((aValores[16][1]).slice(0,2)) - 1];        
    }

    // Area Telefonica
    if(aValores[17][1]!=''){
        if(aValores[17][1]!= areaok){
            
            MsgYesNo("Area Telefonica No Corresponde al Ubigeo"+"<br></br>"+"¿Desea Continuar?","Informacion",null,
                function(lyesno){
                    if(lyesno==false){
                        return false;
                    }                    
                }); 
        }

    }
    //Telefonos
    for (var i = 18; i < 23; i++) {
        if(aValores[i][1]!='' && aValores[17][1] ==''){
            MsgInfo("Debe registrar el Area Telefonica...");
            return false;
        }
    }

    // SIC
    if(aValores[38][1]==''){
        MsgInfo("Debe registrar al menos un SIC...");
        return false;
    }
    
    MsgServer('/exdnb/secdat_validsic.prg',sParam, Post_ValidSic);
    //MsgServer( URL_ROUTE, sParam, Post_ValidSic )

    // RUC
    var aRuc = new Array(11);
    var aRucValid = new Array(5,4,3,2,7,6,5,4,3,2)
    var rucsumdig = 0;
    var rucresiduo = 0;

    if(aValores[55][1]!=''){
        for(var i=0;i<11;i++){
            aRuc[i] = new Array(2);            
            aRuc[i][0] = parseInt((aValores[55][1]).substr(i,1));
            if(i<10){
                aRuc[i][1] = aRuc[i][0] * aRucValid[i];
                rucsumdig+=aRuc[i][1];
            } 
            
        }
        residuo = rucsumdig % 11;
        var digval=0;
        switch(residuo){
            case 0:
                digval = 1;
                break;
            case 1:
                digval = 0;
                break;
            default:
                digval = 11 - residuo;
                break;
        }
        if(digval != aRuc[10][0]){
            //console.log(digval);
            //console.log(aRuc);            
            MsgInfo("El RUC es invalido...");
            return false;
        }
        
    }

    // Valida Rating
    MsgServer('/exdnb/secdat_tcanual.prg',sParam, Post_Tcanual);
    
    return true;

}

function Post_ValidSic(dat) {  
  //location.reload();
  var aSic;  
  aSic = dat['hSic'];
    
  for(var i=0;i<aSic.length;i++){
    if(aSic[i]["INDUSTRIA"]==''){
        MsgInfo("El SIC " + aSic[i]["CODIGO"] + " esta errado...");
        return false;
    }  
  }
    
}

function Post_Tcanual(dat){
    var aValores;
    var hDataTcanual={};
    aValores = dat['data'];
    hDataTcanual = dat['hDataTcanual'];
    ValidaRating(aValores, hDataTcanual);
    //console.log(aValores);
}

function ValidaRating(aValores, hDataTcanual){
    var aVar = {}
    var monCapital;
    var monPatrimonio;

    aVar['califPat'] = false;
    aVar['califCap'] = false;
    aVar['ajuste'] = false;
    aVar['moneda']='';
    aVar['montoCapital']=0;
    aVar['montoPatrimonio']=0;
    aVar['monto']=0;
    aVar['montoPatnegativo']=false;
    aVar['rating']='';
    aVar['desrating']='';
    
    
    // Definir tipo de Cambio
    var ntipocambio = 1;
    if(hDataTcanual[0]['YEAR']!=''){
        ntipocambio = parseFloat(hDataTcanual[0]['TC']);
    }

    // Validar NQ
    if(aValores[3][1]=='15' || aValores[3][1]=='32' || aValores[3][1]=='30' || aValores[3][1]=='33' ){
        aValores[4][1]='';
        return true;
    }

    // Validar Entidades del estado / Personas naturales sin negocio / Operaciones paralizadas.
    if(aValores[3][1]=='14' && aValores[4][1]=='01'){
        return true;
    }

    // Validacion de Monedas

    if((aValores[46][1]).substr(0,3)!="S/ " && (aValores[46][1]).substr(0,3)!="S/." && (aValores[46][1]).substr(0,3)!="US$" && (aValores[46][1]).substr(0,3)!=""){
        MsgInfo("La Moneda del Capital es Incorrecta...");
        return false;
    }

    if((aValores[47][1]).substr(0,3)!="S/ " && (aValores[47][1]).substr(0,3)!="S/." && (aValores[47][1]).substr(0,3)!="US$" && (aValores[47][1]).substr(0,3)!=""){
        MsgInfo("La Moneda del Patrimonio es Incorrecta...");
        return false;
    }

    // Validad Capital Negativo
    if((aValores[46][1]).indexOf("(") != -1){
        MsgInfo("El monto del Capital no puede ser Negativo...");
        return false;
    }
    

    // Validacion de la Capacidad Financiera
    aVar['monCapital'] = parseFloat((((aValores[46][1]).substr(3)).replace(/,/g,"")).replace("(","-"));
    aVar['monPatrimonio'] = parseFloat((((aValores[47][1]).substr(3)).replace(/,/g,"")).replace("(","-"));

    // Patrimonio Negativo
    if((aValores[47][1]).indexOf("(") != -1){
        aVar['montoPatnegativo']=true;
    }

    if(aVar['monPatrimonio'] > 0){
        aVar['monto'] = aVar['monPatrimonio'];
        aVar['califPat']=true;
        aVar['califCap']=false;
        aVar['moneda'] = (aValores[47][1]).substr(0,3);
    }else{
        aVar['monto'] = aVar['monCapital'];
        aVar['califPat']=false;
        aVar['califCap']=true;
        aVar['moneda'] = (aValores[46][1]).substr(0,3);
    }

    if(aVar['moneda']=='S/' || aVar['moneda']=='S/.'){
        aVar['monto'] = Math.trunc(aVar['monto'] / ntipocambio);
    }

    if(aVar['monPatrimonio']==0 && aVar['monCapital']==0){
        aVar['rating']='13';
        aVar['desrating']='O';
    }else if(aVar['montoPatnegativo'] == true && aValores[3][1] != "34"){
        aVar['rating']='31';
        aVar['desrating']='N';
    }else if(aVar['montoPatnegativo'] == true && aValores[3][1] == "34"){
        aVar['rating']='34';
        aVar['desrating']='N';
    }else{
        aVar['ajuste']=true;
        if(aVar['monto'] >= 50000000){
            if(aVar['califPat']==true){
                aVar['rating']='12';
            }else{
                aVar['rating']='27';
            }
            aVar['desrating']='5A';
        }else if(aVar['monto'] >= 10000000 && aVar['monto'] < 50000000){
            if(aVar['califPat']==true){
                aVar['rating']='11';
            }else{
                aVar['rating']='26';
            }
            aVar['desrating']='4A';
        }else if(aVar['monto'] >= 1500000 && aVar['monto'] < 10000000){
            if(aVar['califPat']==true){
                aVar['rating']='10';
            }else{
                aVar['rating']='25';
            }
            aVar['desrating']='3A';
        }else if(aVar['monto'] >= 750000 && aVar['monto'] < 1500000){
            if(aVar['califPat']==true){
                aVar['rating']='09';
            }else{
                aVar['rating']='24';
            }
            aVar['desrating']='2A';
        }else if(aVar['monto'] >= 375000 && aVar['monto'] < 750000){
            if(aVar['califPat']==true){
                aVar['rating']='08';
            }else{
                aVar['rating']='23';
            }
            aVar['desrating']='1A';
        }else if(aVar['monto'] >= 188000 && aVar['monto'] < 375000){
            if(aVar['califPat']==true){
                aVar['rating']='07';
            }else{
                aVar['rating']='22';
            }
            aVar['desrating']='A';
        }else if(aVar['monto'] >= 94000 && aVar['monto'] < 188000){
            if(aVar['califPat']==true){
                aVar['rating']='06';
            }else{
                aVar['rating']='21';
            }
            aVar['desrating']='B';
        }else if(aVar['monto'] >= 47000 && aVar['monto'] < 94000){
            if(aVar['califPat']==true){
                aVar['rating']='05';
            }else{
                aVar['rating']='20';
            }
            aVar['desrating']='C';
        }else if(aVar['monto'] >= 24000 && aVar['monto'] < 47000){
            if(aVar['califPat']==true){
                aVar['rating']='04';
            }else{
                aVar['rating']='19';
            }
            aVar['desrating']='D';
        }else if(aVar['monto'] >= 12000 && aVar['monto'] < 24000){
            if(aVar['califPat']==true){
                aVar['rating']='03';
            }else{
                aVar['rating']='18';
            }
            aVar['desrating']='E';
        }else if(aVar['monto'] >= 6000 && aVar['monto'] < 12000){
            if(aVar['califPat']==true){
                aVar['rating']='02';
            }else{
                aVar['rating']='17';
            }
            aVar['desrating']='F';
        }else if(aVar['monto'] < 6000){
            if(aVar['califPat']==true){
                aVar['rating']='01';
            }else{
                aVar['rating']='16';
            }
            aVar['desrating']='G';
        }

        // Validar Calificacion
        
        if(aVar['califCap']==true && aVar['ajuste']==true){
            aVar['desrating'] = aVar['desrating'] + (aVar['desrating']).substr((aVar['desrating']).length-1,1);
        }
        if(aValores[3][1] != aVar['rating']){
            MsgInfo("Calificacion Incorrecta, corresponde un " + aVar['desrating'] + "...");
        }

        // Asignar Calificacion
        aValores[3][1]= aVar['rating'];
        //console.log('rating', aValores);
    }

}

function sec02_ok(aValores){

    // Tipo de Empresas
    if(aValores[0][1]=='' || aValores[0][1]=='..'){
        MsgInfo("Debe registrar el tipo de FIRMA...");
        return false;
    }

    // Validar % de Participacion
    var totpar=0.0;
    for(var i=23;i<52;i++){
        if((i % 2)>0){                        
            if(parseFloat(aValores[i][1])>0){
                totpar+=parseFloat(aValores[i][1]);
            }
        }
    }    
    if(totpar > 0 && totpar < 100){
        MsgInfo("Porcentaje de Participación Total incorrecto...");
        return false;
    }

    return true;
}

function sec06_ok(aValores,aStrings,flanual){
    var date = Date.now();
    var fecha = new Date(date);
    var fecha_act = format_date(fecha);
    var corr_gen = 0;
    var nocorr_gen = 0;
    var aValoresChg=new Array()
    aValoresChg = aValores;

    // Los campos numericos vacios ponerlos a "0"
    for (var i = 0; i < (aStrings.length - 1); i++) {
        if(aStrings[i]["TIPO"]=='N'){
            if(aValoresChg[i][1]==''){
                aValoresChg[i][1]='0';
            }
        }
    }
    
    if(aValoresChg[0][1]!=''){
        if(aValoresChg[0][1] > fecha_act){
            console.log('fecha_act',fecha_act);
            MsgInfo("La Fecha de Actualizacion no puede ser a Futuro...");
            return false;
        }
    }

    // Balance General
    if(aValoresChg[6][1]!=''){
        if(Date.parse(aValoresChg[6][1]) - Date.parse(fecha_act) > 1095){
            if(flanual=="S"){
                MsgInfo("La Fecha de Balance General es mayor a tres(03) años ...");
            }else{
                MsgInfo("La Fecha de Balance Parcial(BP) es mayor a tres(03) años ...");
            }
            
            return false;
        }

    }

    // Activo Corriente Balance General
    for(var i=8;i<21;i++){
        corr_gen += parseFloat(aValoresChg[i][1]);                
    }

    if(corr_gen != 0 && parseFloat(aValoresChg[21][1]) != 0 && corr_gen != parseFloat(aValoresChg[21][1])){
        if(flanual=="S"){
            MsgInfo("Hay un Error en el Activo Corriente...");
        }else{
            MsgInfo("Hay un Error en el Activo Corriente(BP)...");
        }
        
        return false;
    }

    // Activo No Corriente Balance General
    for(var i=22;i<29;i++){
        nocorr_gen += parseFloat(aValoresChg[i][1]);
    }

    if(nocorr_gen != 0 && parseFloat(aValoresChg[29][1]) != 0 && nocorr_gen != parseFloat(aValoresChg[29][1])){
        if(flanual=="S"){
            MsgInfo("Hay un Error en el Activo No Corriente...");
        }else{
            MsgInfo("Hay un Error en el Activo No Corriente(BP)...");
        }
        
        return false;
    }

    // Sub totales del Activo (Balance General)
    if(parseFloat(aValoresChg[21][1]) + parseFloat(aValoresChg[29][1])!= parseFloat(aValoresChg[30][1])){
        if(flanual=="S"){
            MsgInfo("Sub-Totales del Activo No Cuadran...");
        }else{
            MsgInfo("Sub-Totales del Activo(BP) No Cuadran...");
        }        
        return false;
    }

    // Pasivo Corriente (Balance General)
    corr_gen = 0;
    nocorr_gen = 0;
    for(var i=31;i<42;i++){
        corr_gen += parseFloat(aValoresChg[i][1]);
    }

    if(corr_gen != 0 && parseFloat(aValoresChg[42][1]) != 0 && corr_gen != parseFloat(aValoresChg[42][1])){
        if(flanual=="S"){
            MsgInfo("Hay un Error en el Pasivo Corriente...");
        }else{
            MsgInfo("Hay un Error en el Pasivo Corriente(BP)...");
        }
        
        return false;
    }

    // Pasivo No Corriente
    for(var i=43;i<46;i++){
        nocorr_gen += parseFloat(aValoresChg[i][1]);
    }

    if(nocorr_gen != 0 && parseFloat(aValoresChg[46][1]) != 0 && nocorr_gen != parseFloat(aValoresChg[46][1])){
        if(flanual=="S"){
            MsgInfo("Hay un Error en el Pasivo No Corriente...");
        }else{
            MsgInfo("Hay un Error en el Pasivo No Corriente(BP)...");
        }
        
        return false;
    }

    // Patrimonio (Balance General)
    corr_gen = 0;
    nocorr_gen = 0;
    for(var i=48;i<56;i++){
        corr_gen += parseFloat(aValoresChg[i][1]);
    }

    if(corr_gen != 0 && parseFloat(aValoresChg[56][1]) != 0 && corr_gen != parseFloat(aValoresChg[56][1])){
        if(flanual=="S"){
            MsgInfo("Hay un Error en el Patrimonio...");
        }else{
            MsgInfo("Hay un Error en el Patrimonio(BP)...");
        }
        
        return false;
    }

    // Sub Totales del pasivo y patrimonio (Balance General)
    if((parseFloat(aValoresChg[42][1]) + parseFloat(aValoresChg[46][1]) + parseFloat(aValoresChg[47][1]) + parseFloat(aValoresChg[56][1])) != parseFloat(aValoresChg[57][1])){
        if(flanual=="S"){
            MsgInfo("Sub-Totales Pasivo No Cuadran...");
        }else{
            MsgInfo("Sub-Totales Pasivo(BP) No Cuadran...");
        }
        
        return false;
    }

    // Total activo vs Total pasivo (Balance General)
    if(parseFloat(aValoresChg[30][1]) != parseFloat(aValoresChg[57][1])){
        if(flanual=="S"){
            MsgInfo("Total Activo difiere del Total Pasivo y patrimonio...");
        }else{
            MsgInfo("Total Activo difiere del Total Pasivo y patrimonio(BP)...");
        }
        
        return false;
    }

    // Estado de Ganancias y Perdidas (Balance General)
    corr_gen = parseFloat(aValoresChg[61][1]) + parseFloat(aValoresChg[63][1]);
    for(var i=65;i<73;i++){
        corr_gen += parseFloat(aValoresChg[i][1]);
    }
    corr_gen += parseFloat(aValoresChg[74][1]);
    if(corr_gen !=0){
        if((corr_gen + parseFloat(aValoresChg[60][1])) != parseFloat(aValoresChg[75][1]) ){
            if(flanual=="S"){
                MsgInfo("Error en el Estado de Ganancias Perdidas...");
            }else{
                MsgInfo("Error en el Estado de Ganancias Perdidas(BP)...");
            }
            
            return false;
        }
    }

    return true;
}

function format_date(fecha){
    var dia = fecha.getDate();
    var mes = fecha.getMonth() + 1;
    var year = fecha.getFullYear();
    
    dia = dia
        .toString()
        .padStart(2, '0');
    
    mes = mes
        .toString()
        .padStart(2, '0');
    
    return `${year}-${mes}-${dia}`;
    
}

function sec07_ok(aValores,aStrings){
    var aValoresChg = new Array();
    aValoresChg = aValores;

    // Los campos numericos vacios ponerlos a "0"
    for (var i = 0; i < (aStrings.length - 1); i++) {
        if(aStrings[i]["TIPO"]=='N'){
            if(aValoresChg[i][1]==''){
                aValoresChg[i][1]='0';
            }
        }
    }

    // Capital de Trabajo
    if(aValoresChg[4][1]!='' && ((parseFloat(aValoresChg[2][1]) - parseFloat(aValoresChg[3][1])) != parseFloat(aValoresChg[4][1]))){   
        MsgInfo("Error en el Capital de Trabajo; No Cuadra...");            
        return false;
    }

    if(aValoresChg[25][1]!='' && ((parseFloat(aValoresChg[23][1]) - parseFloat(aValoresChg[24][1])) != parseFloat(aValoresChg[25][1]))){   
        MsgInfo("Error en el Capital de Trabajo; No Cuadra...");            
        return false;
    }

    if(aValoresChg[46][1]!='' && ((parseFloat(aValoresChg[44][1]) - parseFloat(aValoresChg[45][1])) != parseFloat(aValoresChg[46][1]))){   
        MsgInfo("Error en el Capital de Trabajo; No Cuadra...");            
        return false;
    }

    if(aValoresChg[67][1]!='' && ((parseFloat(aValoresChg[65][1]) - parseFloat(aValoresChg[66][1])) != parseFloat(aValoresChg[67][1]))){   
        MsgInfo("Error en el Capital de Trabajo; No Cuadra...");            
        return false;
    }
    return true;
}

function sec09_ok(aValores,aStrings){
    var aValoresChg = new Array();
    var date = Date.now();
    var fecha = new Date(date);
    var fecha_act = format_date(fecha);
    var corr_gen = 0;
    var nocorr_gen = 0;
    aValoresChg = aValores;

    // Los campos numericos vacios ponerlos a "0"
    for (var i = 0; i < (aStrings.length - 1); i++) {
        if(aStrings[i]["TIPO"]=='N'){
            if(aValoresChg[i][1]==''){
                aValoresChg[i][1]='0';
            }
        }
    }
    
    // Fecha de Actualizacion

    if(aValoresChg[0][1]!=''){
        if(aValoresChg[0][1] > fecha_act){
            MsgInfo("La Fecha de Actualizacion no puede ser a Futuro...");
            return false;
        }
    }

    // Fecha de Balance
    if(aValoresChg[4][1]!=''){
        return true;
    }

    if(aValoresChg[4][1]!=''){
        if(Date.parse(aValoresChg[4][1]) - Date.parse(fecha_act) > 1095){
            MsgInfo("La Fecha de Balance General es mayor a tres(03) años ...");
            return false;
        }

    }

    // Activo Corriente (Balance Bancos)
    for(var i=6;i<13;i++){
        corr_gen += parseFloat(aValoresChg[i][1]);                
    }

    if(corr_gen != 0 && corr_gen != parseFloat(aValoresChg[13][1])){
        MsgInfo("Hay un Error en el Activo Corriente...");        
        return false;
    }

    // Activo No Corriente (Balance Bancos)
    for(var i=14;i<24;i++){
        nocorr_gen += parseFloat(aValoresChg[i][1]);
    }

    if(nocorr_gen != 0 && nocorr_gen != parseFloat(aValoresChg[24][1])){
        MsgInfo("Hay un Error en el Activo No Corriente...");
        return false;
    }

       // Totales del Activo (Balance Bancos)
       if(parseFloat(aValoresChg[13][1]) + parseFloat(aValoresChg[24][1])!= parseFloat(aValoresChg[25][1])){
        MsgInfo("Total del Activo No Cuadra...");
        return false;
    }

    // Pasivo Corriente (Balance Bancos)
    corr_gen = 0;
    nocorr_gen = 0;
    for(var i=26;i<35;i++){
        corr_gen += parseFloat(aValoresChg[i][1]);
    }

    if(corr_gen != 0 && corr_gen != parseFloat(aValoresChg[35][1])){
        MsgInfo("Hay un Error en el Pasivo Corriente...");
        return false;
    }

    // Pasivo No Corriente (Balance Bancos)
    for(var i=36;i<43;i++){
        nocorr_gen += parseFloat(aValoresChg[i][1]);
    }

    if(nocorr_gen != 0 && nocorr_gen != parseFloat(aValoresChg[43][1])){
        MsgInfo("Hay un Error en el Pasivo No Corriente...");
        return false;
    }

    // Patrimonio (Balance Bancos)
    corr_gen = 0;
    nocorr_gen = 0;
    for(var i=44;i<50;i++){
        corr_gen += parseFloat(aValoresChg[i][1]);
    }

    if(corr_gen != 0 && corr_gen != parseFloat(aValoresChg[50][1])){
        MsgInfo("Hay un Error en el Patrimonio...");
        return false;
    }

    // Pasivo y Patrimonio (Balance Bancos)

    if((parseFloat(aValoresChg[35][1]) + parseFloat(aValoresChg[43][1]) + parseFloat(aValoresChg[50][1])) != parseFloat(aValoresChg[51][1])){
        MsgInfo("Pasivo y Patrimonio No Cuadran...");
        return false;
    }

    // Total activo vs Total pasivo (Balance Bancos)
    if(parseFloat(aValoresChg[25][1]) != parseFloat(aValoresChg[51][1])){
        MsgInfo("Total Activo difiere del Total Pasivo y patrimonio...");
        return false;
    }

    // Estado de Ganancias y Perdidas (Balance Bancos)
    corr_gen = parseFloat(aValoresChg[54][1]) + parseFloat(aValoresChg[55][1]) + parseFloat(aValoresChg[57][1]) + parseFloat(aValoresChg[59][1]) 
        + parseFloat(aValoresChg[60][1]) + parseFloat(aValoresChg[62][1]) + parseFloat(aValoresChg[64][1]) + parseFloat(aValoresChg[66][1])
        + parseFloat(aValoresChg[67][1]) + parseFloat(aValoresChg[69][1]) + parseFloat(aValoresChg[70][1]) + parseFloat(aValoresChg[72][1])
        + parseFloat(aValoresChg[73][1]);
    
    if(corr_gen != 0 && corr_gen != parseFloat(aValoresChg[74][1])){
        MsgInfo("Error en el Estado de Ganancias Perdidas...");
        return false;
    }    
    
    // BALANCE PARCIAL BANCOS 
    var corr_gen = 0;
    var nocorr_gen = 0;

    // Activo Corriente (Balance Parcial Bancos)
    for(var i=78;i<85;i++){
        corr_gen += parseFloat(aValoresChg[i][1]);                
    }

    if(corr_gen != 0 && corr_gen != parseFloat(aValoresChg[85][1])){
        MsgInfo("Hay un Error en el Activo Corriente(BP)...");        
        return false;
    }

    // Activo No Corriente (Balance Parcial Bancos)
    for(var i=86;i<96;i++){
        nocorr_gen += parseFloat(aValoresChg[i][1]);
    }

    if(nocorr_gen != 0 && nocorr_gen != parseFloat(aValoresChg[96][1])){
        MsgInfo("Hay un Error en el Activo No Corriente(BP)...");
        return false;
    }

       // Totales del Activo (Balance Parcial Bancos)
       if(parseFloat(aValoresChg[85][1]) + parseFloat(aValoresChg[96][1])!= parseFloat(aValoresChg[97][1])){
        MsgInfo("Total del Activo(BP) No Cuadra...");
        return false;
    }

    // Pasivo Corriente (Balance Parcial Bancos)
    corr_gen = 0;
    nocorr_gen = 0;
    for(var i=98;i<107;i++){
        corr_gen += parseFloat(aValoresChg[i][1]);
    }

    if(corr_gen != 0 && corr_gen != parseFloat(aValoresChg[107][1])){
        MsgInfo("Hay un Error en el Pasivo Corriente(BP)...");
        return false;
    }

    // Pasivo No Corriente (Balance Parcial Bancos)
    for(var i=108;i<115;i++){
        nocorr_gen += parseFloat(aValoresChg[i][1]);
    }

    if(nocorr_gen != 0 && nocorr_gen != parseFloat(aValoresChg[115][1])){
        MsgInfo("Hay un Error en el Pasivo No Corriente(BP)...");
        return false;
    }

    // Patrimonio (Balance Parcial Bancos)
    corr_gen = 0;
    nocorr_gen = 0;
    for(var i=116;i<122;i++){
        corr_gen += parseFloat(aValoresChg[i][1]);
    }

    if(corr_gen != 0 && corr_gen != parseFloat(aValoresChg[122][1])){
        MsgInfo("Hay un Error en el Patrimonio(BP)...");
        return false;
    }

    // Pasivo y Patrimonio (Balance Parcial Bancos)

    if((parseFloat(aValoresChg[107][1]) + parseFloat(aValoresChg[115][1]) + parseFloat(aValoresChg[122][1])) != parseFloat(aValoresChg[123][1])){
        MsgInfo("Pasivo y Patrimonio(BP) No Cuadran...");
        return false;
    }

    // Total activo vs Total pasivo (Balance Parcial Bancos)
    if(parseFloat(aValoresChg[97][1]) != parseFloat(aValoresChg[123][1])){
        MsgInfo("Total Activo difiere del Total Pasivo y patrimonio(BP)...");
        return false;
    }
    
    // Estado de Ganancias y Perdidas (Balance Parcial Bancos)
    corr_gen = parseFloat(aValoresChg[126][1]) + parseFloat(aValoresChg[127][1]) + parseFloat(aValoresChg[129][1]) + parseFloat(aValoresChg[131][1]) 
        + parseFloat(aValoresChg[132][1]) + parseFloat(aValoresChg[134][1]) + parseFloat(aValoresChg[136][1]) + parseFloat(aValoresChg[138][1])
        + parseFloat(aValoresChg[139][1]) + parseFloat(aValoresChg[141][1]) + parseFloat(aValoresChg[142][1]) + parseFloat(aValoresChg[144][1])
        + parseFloat(aValoresChg[145][1]);
    
    if(corr_gen != 0 && corr_gen != parseFloat(aValoresChg[146][1])){
        MsgInfo("Error en el Estado de Ganancias Perdidas(BP)...");
        return false;
    }
    return true;
}
