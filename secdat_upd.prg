//	{% mh_LoadHrb( 'lib/tweb/tweb.hrb' ) %}

#include {% TWebInclude() %}

#include "hbclass.ch"  // Obligatorio para evitar errores de sintaxis en la definicion de las Clases
#define adUseClient    3
#define adOpenStatic    3
#define adOpenDynamic   2
#define adLockOptimistic    3

Function main()

    local oString 
	local oDatos 
	local oLista1
	local hParam  		:= GetMsgServer()
	local hDataString	:= {}
	local hDataDatos	:= {}
	local hDataLista1	:= {}
	
	// Informacion de la tabla String
	oString := StringModel():New()
	hDataString := oString:StrSeccion(hParam)

	// Informacion de la tabla Datos
	oDatos := DatosModel():New()	
	hDataDatos := oDatos:DatSeccion(hParam)

	// Informacion de la tabla Lista1
	oLista1 := ListaModel():New()
	hDataLista1 := oLista1:ListaGetAll()

	DEFINE FORM o

			o:lDessign := .T.
		
			HTML o INLINE '<h3><i class="fa fa-credit-card" aria-hidden="true"></i>&nbsp;Informe Comercial</h3><hr>'
			
		INIT FORM o

            o:cType     := 'md'     //  xs,sm,md,lg
			o:cSizing   := 'sm'     //  sm,lg
			
			HTML o

                    <!-- Ventana Modal -->
                    <div class="modal fade" id="editModal" tabindex="-1" role="dialog" aria-labelledby="pickTitle" aria-hidden="true">
                      <div class="modal-dialog modal-dialog-scrollable modal-dialog-centered modal-lg modal-sm"  role="document">
                        <div class="modal-content">
                          <div class="modal-header">
                            <h5 class="modal-title" id="pickTitle">Seccion</h5>
                            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                              <span aria-hidden="true">&times;</span>
                            </button>
                          </div>

                          <div class="modal-body">

            ENDTEXT

			ROW o
				for i:= 1 to len(hDataString)
					aValueLista1 :={}
					aPromptLista1 :={}
					vid := 'id' + hDataString[i]['CAMPO']
					SAY value hDataString[i]['DESC'] Grid 6 Font 'Bold' OF o

					do case
						case hDataString[i]['TIPO'] = 'C'
							If hDataString[i]['LONG'] >= 60
								Get oGet MEMO id vid Grid 6 ROWS 2 OF o
							else
								Get oGet id vid Grid 6 OF o
							endif
						case hDataString[i]['TIPO'] = 'N'
							Get oGet id vid Grid 6 Type 'number' Align 'right' OF o
						case hDataString[i]['TIPO'] = 'D'
							Get oGet id vid Grid 6 Type 'date' OF o
						case hDataString[i]['TIPO'] = 'T'

							// Extaer valores de Lista
							
							For l:=1 to len(hDataLista1)
								If hDataLista1[l]['NOMBRE'] = hDataString[i]['TABLA']
									aadd(aValueLista1, hDataLista1[l]['CLAVE'])
									aadd(aPromptLista1, hDataLista1[l]['DESCRIP'])
								Endif
							next
							SELECT oSelect id vid PROMPT aPromptLista1  VALUES aValueLista1 Grid 6 OF o							
					endcase
				next

			ENDROW o

			HTML o

                          </div>
                          <div class="modal-footer">
                            <button type="button" id="btnClose" class="btn btn-secondary btn-sm" data-dismiss="modal">Cerrar</button>
                            <button type="button" id="btnSave" class="btn btn-primary btn-sm">Grabar</button>
                          </div>
                        </div>
                      </div>
                    </div>                    
            ENDTEXT

            HTML o PARAMS hParam, hDataString, hDataDatos  // Pasar variables de PRG a JS
		
				<script>
					var oParam = new Object()

					// Recepcionar variable desde Prg duns_upd.view

					oParam['duns']  = <$  SetDataJS( hParam ) $>
					oParam['dataS'] = <$  SetDataJS( hDataString ) $>
					oParam['dataD'] = <$  SetDataJS( hDataDatos ) $>

					console.log('secdat_upd',oParam['duns']['duns']);
					console.log('secdat_upd',oParam['dataS']);
					console.log('secdat_upd',oParam['dataD']);

					$(document).ready(function () {

						//Search_Select_Tag('Id')

						//TWebIntro( 'search', Load ) 
						$("#editModal").modal({
							backdrop: 'static',
							keyboard: false,
							show: true
						});   						
						
						console.log('secdat_upd')
					});

				</script>

				
						
			ENDTEXT			
		
		//END FORM o

    //AP_SetContentType( "application/json" )	
	//hResponse := { 'hParam' => hParam, 'hDataString' => hDataString, 'hDataDatos' =>hDataDatos, 'hDataLista1'=> hDataLista1 } 
	//?? hb_jsonEncode( hResponse ) 
	
return nil


//	Load Files	------------------------------------------

{% mh_LoadFile( "/src/model/provider/conexionsql.prg" ) %}
{% mh_LoadFile( "src/model/stringmodel.prg" ) %}
{% mh_LoadFile( "src/model/datosmodel.prg" ) %}
{% mh_LoadFile( "src/model/listamodel.prg" ) %}
