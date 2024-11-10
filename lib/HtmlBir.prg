#define adUseClient    3
#define adOpenStatic    3
#define adOpenDynamic   2
#define adLockOptimistic    3
#define FC_NORMAL          0           /* No file attributes are set */
#define FO_WRITE           1           /* File is opened for writing */

Function HtmlBir(hParam,param2,param3,param4,param5)
    
    local oString
    local oDuns
    local oDatos
    local oLista1
    local hDataDuns     := {}
    local hDataDatos	:= {}
    local hDataString	:= {}
    local hDataLista1	:= {}
    local dato:=''
    local aParam  := {=>}

    matrizTxt:={}
    aFormat:=array(12,2)	
    nduns   :=hParam['duns']
    producto:=param3
    vsuscript:=hParam['suscriptor']
    flopen:=param4
    fldom:=param5
    yearlimite := hparam['yearlimite']
    public file2prn,dat_loc, cadenahtml:='', hHtmFile, vigencia:=''
    public campo:={}, valor:={}

    dat_loc := AppPathData()
    file2prn:=AppPathReport() + param2 + hParam['codigo'] + ".HTM"

    IF RAT(".HTM",file2prn)=0
        file2prn=file2prn+".HTM"
    ENDIF

    SET DATE BRITISH
    SET CENTURY ON    
    SET DELETED ON
    SET EXCLUSIVE OFF
    
    aFormat:={{4,"9,999"},{5,"99,999"},{6,"999,999"},{7,"9,999,999"},{8,"99,999,999"},{9,"999,999,999"},{10,"9,999,999,999"},{11,"99,999,999,999"},{12,"999,999,999,999"},{13,"9,999,999,999,999"},{14,"99,999,999,999,999"},{15,"999,999,999,999,999"}}

    oDuns:=DunsModel():New()
    hDataDuns := oDuns:DunsGet(hParam)
    if len(hDataDuns)=1 .and. !empty(hDataDuns[1]['DUNSNUM'])
        m->vigencia := dtoc(hDataDuns[1]['VIGENCIA'])
        db_open() // Abrir DBFs HTMLs para generar informes Web

        //  Buscar ruta dominio
        hcfg->(dbseek(m->producto))

        //  Crear archivos temporales por seccion    	
        m->secc:=''
        aSec:={}
        hsub->(dbsetorder(1))
        hsub->(dbgotop())
        hsub->(dbseek(m->producto))
        DO WHILE hsub->producto = m->producto .and. hsub->(!eof())
            aDbf:={}
            if empty(hsub->estado) // Inactivo            
                // Informacion de la tabla Datos
                hParam['seccion']:=hsub->seccion
                oDatos := DatosModel():New()
                hDataDatos := oDatos:DatSeccion(hParam)
                if len(hDataDatos)>=1 .and. !empty(hDataDatos[1]['DATO'])
                    aadd(aSec,{hsub->seccion, hsub->sechtml +alltrim(str(hsub->ordenhtml))})
                endif

                // Informacion de la tabla String
                oString := StringModel():New()
                hDataString := oString:StrSeccion(hParam)

                for i:= 1 to len(hDataString)
                    namecampo:=iif(left(AllTrim(hDataString[i]['CAMPO']),1)$'0123456789', 'V','') + AllTrim(hDataString[i]['CAMPO'])
                    if !empty(namecampo)
                        aadd(aDbf, {namecampo, 'M', 10, 0})
                    endif
                next

                if len(aDbf)>0
                    nameFileSec:=AppPathData()+'SEC'+hsub->seccion
                    DbCreate(nameFileSec, aDbf)
                endif
            Endif
            hsub->(dbskip())
        Enddo
        For s:=1 to len(aSec)
            nameFileSec:='SEC'+aSec[s,1]
            USE &dat_loc.&nameFileSec ALIAS TMP EXCLUSIVE NEW
            tmp->(dbappend())
            // Informacion de la tabla Datos

            dato:=''
            hParam['seccion']:=aSec[s,1]
            oDatos := DatosModel():New()	
            hDataDatos := oDatos:DatSeccion(hParam)
            for d:=1 to len(hDataDatos)
                dato += AllTrim(hDataDatos[d]['DATO'])
            Next

            // Informacion de la tabla String
            oString := StringModel():New()
            hDataString := oString:StrSeccion(hParam)

            valor := Array(len(hDataString))
            
            for i:= 1 to len(hDataString)
                fila := hDataString[i]
                pos_at := at('æ'+AllTrim(hDataString[i]['CAMPO']),dato)
                if pos_at > 0
                    valor[i] := Inicia(fila, pos_at, dato)
                else
                    do case
                        case hDataString[i]['TIPO'] $ 'CT'
                            valor[i]:=''
                        case hDataString[i]['TIPO'] = 'N'
                            valor[i]:='0'
                        case hDataString[i]['TIPO'] = 'D'
                            valor[i]:='  /  /  '
                    endcase
                endif
                if !empty(m->valor[i])
                    namecampo:=iif(left(AllTrim(hDataString[i]['CAMPO']),1)$'0123456789', 'V','') + AllTrim(hDataString[i]['CAMPO'])

                    // Verificar si el campo es porcentual %                
                    posi_porc:=0
                    if !empty(hDataString[i]['DESC'])
                        posi_porc:= at('%',hDataString[i]['DESC'])
                    endif
                    if posi_porc = 0
                        hstr->(dbsetorder(2))
                        hstr->(dbseek(m->producto + aSec[s,1] + alltrim(hDataString[i]['CAMPO'])))
                        posi_porc:= at('%',hstr->desc)
                        hstr->(dbsetorder(1))
                    endif

                    // Si el campo corresponde una Lista traer la descripcion correcta.

                    Do Case
                        case hDataString[i]['TIPO'] = 'T'
                            // Informacion de la tabla Lista1                                               
                            aParam :={'lista' => hDataString[i]['TABLA']}
                            oLista1 := ListaModel():New()
                            hDataLista1 := oLista1:ListaGet(aParam)
                            for d:=1 to len(hDataLista1)
                                if Alltrim(hDataLista1[d]['CLAVE']) = m->valor[i]
                                    m->valor[i]:=hDataLista1[d]['DESCRIP']        
                                endif
                            next
                        case hDataString[i]['TIPO'] = 'N'                                                
                            m->flagcero:= iif(val(m->valor[i])==0, .t., .f.)
                            if !m->flagcero .and.  LEN(alltrim(m->valor[i])) > 3
                                if posi_porc = 0
                                    IF LEN(m->valor[i])>3
                                        m->valor[i] := TRANSFORM(val(m->valor[i]),aformat[LEN(alltrim(m->valor[i]))-3,2])
                                    Endif
                                endif
                            endif
                        case hDataString[i]['TIPO'] = 'D'
                            if m->valor[i] <> '  /  /  '
                                m->valor[i] := right(m->valor[i],2) + '/' + substr(m->valor[i],6,2) + '/' + left(m->valor[i],4)
                            endif
                    Endcase
                    tmp->&namecampo := html_clear(alltrim(m->valor[i]))
                endif
            next        
            USE
        next

        // Armar codigo HTML

        // Cabecera Informe Html

        hbir->(dbseek(m->producto + '01'))
        IF !empty(hbir->html) .and. hbir->flhtml
            aHtml:={}
            m->html := hbir->html
            FMemo_Mat('html',aHtml, len(m->html))
            For k:=1 to len(aHtml)
                cadena:= aHtml[k]
                if substr(cadena,2,2)=='&&'
                    vmacro:=substr(cadena,4,len(cadena)-4)
                    vmacrovar:=&vmacro
                    //? vmacrovar
                    cadenahtml += vmacrovar
                else
                    //? &cadena	
                    cadenahtml += &cadena
                endif
            Next
        Endif

        // Crear Menu Html
                
        ASORT(aSec,,, { |x, y| x[2] < y[2] })
        hmen->(dbseek(m->producto))
        do while hmen->producto = m->producto .and. hmen->(!eof())
            if !empty(hmen->html) .and. hmen->flhtml
                aHtml:={}
                m->html := hmen->html
                FMemo_Mat('html',aHtml, len(m->html))
                For k:=1 to len(aHtml)
                    cadena:= aHtml[k]
                    if substr(cadena,2,2)=='&&'
                        vmacro:=substr(cadena,4,len(cadena)-4)
                        vmacrovar:=&vmacro
                        //? vmacrovar
                        cadenahtml += vmacrovar
                    else
                        //? &cadena	
                        cadenahtml += &cadena
                    endif
                Next
                For a:=1 to len(aSec)
                    if left(aSec[a,2],2)=hmen->sechtml
                        hsub->(dbseek(m->producto + aSec[a,1]))
                        if !empty(hsub->html) .and. hsub->flhtml
                            aHtml:={}
                            m->html := hsub->html
                            FMemo_Mat('html',aHtml, len(m->html))
                            For k:=1 to len(aHtml)
                                cadena:= aHtml[k]
                                if substr(cadena,2,2)=='&&'
                                    vmacro:=substr(cadena,4,len(cadena)-4)
                                    vmacrovar:=&vmacro
                                    //? vmacrovar
                                    cadenahtml += vmacrovar
                                else
                                    //? &cadena	
                                    cadenahtml += &cadena
                                endif
                            Next	
                        endif
                    endif
                Next
                //?'</ul>'
                cadenahtml += '</ul>'
                //?'</li>'
                cadenahtml += '</li>'
            endif
            hmen->(dbskip())
        enddo
        cadenahtml += '</div>'  // Fin Menu

        // Nombre de la Empresa

        hbir->(dbseek(m->producto + '02'))
        if !empty(hbir->html) .and. hbir->flhtml
            SELECT 0
            USE &dat_loc.SEC01 ALIAS TMP EXCLUSIVE
            aHtml:={}
            m->html := hbir->html
            FMemo_Mat('html',aHtml, len(m->html))
            For k:=1 to len(aHtml)
                cadena:= aHtml[k]
                if substr(cadena,2,2)=='&&'
                    vmacro:=substr(cadena,4,len(cadena)-4)
                    vmacrovar:=&vmacro
                    cadenahtml += vmacrovar
                else
                    cadenahtml += &cadena	
                endif
            Next
            USE
        Endif

        // Crear Cuerpo del Informe

        hsub->(dbsetorder(2))
        hsub->(dbseek(m->producto))
        do while hsub->producto = m->producto .and. hsub->(!eof())
            if !empty(hsub->sechtml) .and. hsub->estado<>'I'
                flsigue:=.f.
                For S:=1 to len(aSec)
                    if hsub->seccion = aSec[S,1]
                        S:=len(aSec)
                        flsigue:=.t.
                    Endif
                Next
                if flsigue

                    // Html Cabecera de la Seccion
                            
                    if !empty(hsub->htmlhead) .and. hsub->flhtmlhead
                        aHtml:={}
                        m->html := hsub->htmlhead
                        FMemo_Mat('html',aHtml, len(m->html))
                        For k:=1 to len(aHtml)
                            cadena:= aHtml[k]
                            if substr(cadena,2,2)=='&&'
                                vmacro:=substr(cadena,4,len(cadena)-4)
                                vmacrovar:=&vmacro
                                cadenahtml += vmacrovar
                            else
                                cadenahtml += &cadena	
                            endif
                        Next
                    Endif

                    // Si tiene Estructura Especial por Niveles

                    if hsub->flnivel
                        aBases:={}
                        m->bases := hsub->bases
                        FMemo_Mat('bases',aBases, len(m->bases))
                        For B:=1 to len(aBases)
                            nameFileSec:=aBases[b]
                            SELECT 0
                            USE &dat_loc.&nameFileSec ALIAS &nameFileSec EXCLUSIVE	
                        Next
                        nameFileSec:='SEC'+hsub->seccion
                        SELECT 0
                        USE &dat_loc.&nameFileSec ALIAS TMP EXCLUSIVE	
                        hniv->(dbseek(m->producto + hsub->seccion))
                        m->condition:=''
                        Do while hniv->producto = m->producto .and. hniv->seccion = hsub->seccion .and. hniv->(!eof())
                            m->condition:=iif(!empty(hniv->condicion), hniv->condicion, '1=1')
                            IF !empty(hniv->html) .and. hniv->flhtml .and. &condition
                                aHtml:={}
                                m->html := hniv->html
                                FMemo_Mat('html',aHtml, len(m->html))
                                For k:=1 to len(aHtml)
                                    cadena:= aHtml[k]
                                    if substr(cadena,2,2)=='&&'
                                        vmacro:=substr(cadena,4,len(cadena)-4)
                                        vmacrovar:=&vmacro
                                        cadenahtml += vmacrovar
                                    else
                                        cadenahtml += &cadena	
                                    endif
                                Next	
                            Endif
                            hniv->(dbskip())
                        Enddo
                        USE
                        For B:=1 to len(aBases)
                            nameFileSec:=aBases[b]
                            &nameFilesec->(dbclosearea())
                        Next
                    Endif

                    //  Html por Campos

                    hstr->(dbsetorder(3))
                    hstr->(dbseek(m->producto + hsub->seccion))
                    nameFileSec:='SEC'+hsub->seccion
                    SELECT 0
                    USE &dat_loc.&nameFileSec ALIAS TMP EXCLUSIVE
                    m->condition:=''
                    do while hstr->producto = m->producto .and. hstr->seccion = hsub->seccion .and. hstr->(!eof())
                        // Cabecera html del campo
                        m->condition:=iif(!empty(hstr->condicion), hstr->condicion, '1=1')
                        IF hstr->cab_pie='C' .and. !Empty(hstr->htmlcabpie) .and. hstr->flhtmlcapi .and. &condition
                            aHtml:={}
                            m->html := hstr->htmlcabpie
                            FMemo_Mat('html',aHtml, len(m->html))
                            For k:=1 to len(aHtml)
                                cadena:= aHtml[k]
                                if substr(cadena,2,2)=='&&'
                                    vmacro:=substr(cadena,4,len(cadena)-4)
                                    vmacrovar:=&vmacro
                                    cadenahtml += vmacrovar
                                else
                                    cadenahtml += &cadena	
                                endif
                            Next
                        Endif

                        // html del campo
                                
                        if !empty(hstr->html) .and. hstr->flhtml .and. &condition
                            aHtml:={}
                            m->html := hstr->html
                            FMemo_Mat('html',aHtml, len(m->html))
                            For k:=1 to len(aHtml)
                                cadena:= aHtml[k]
                                if substr(cadena,2,2)=='&&'
                                    vmacro:=substr(cadena,4,len(cadena)-4)
                                    vmacrovar:=&vmacro
                                    cadenahtml += vmacrovar
                                else
                                    cadenahtml += &cadena	
                                endif
                            Next
                        endif

                        m->conditionf:=iif(!empty(hstr->condifalse), hstr->condifalse, '1=2')						
                        if  &conditionf .and. !empty(hstr->htmlfalse) .and. hstr->flhtmlfals
                            aHtml:={}
                            m->html := hstr->htmlfalse
                            FMemo_Mat('html',aHtml, len(m->html))
                            For k:=1 to len(aHtml)
                                cadena:= aHtml[k]
                                if substr(cadena,2,2)=='&&'
                                    vmacro:=substr(cadena,4,len(cadena)-4)
                                    vmacrovar:=&vmacro
                                    cadenahtml += vmacrovar
                                else
                                    cadenahtml += &cadena	
                                endif								
                            Next
                        endif
                                

                        // Pie html del campo
                        IF hstr->cab_pie='P' .and. !Empty(hstr->htmlcabpie) .and. hstr->flhtmlcapi .and. &condition
                            aHtml:={}
                            m->html := hstr->htmlcabpie
                            FMemo_Mat('html',aHtml, len(m->html))
                            For k:=1 to len(aHtml)
                                cadena:= aHtml[k]
                                if substr(cadena,2,2)=='&&'
                                    vmacro:=substr(cadena,4,len(cadena)-4)
                                    vmacrovar:=&vmacro
                                    cadenahtml += vmacrovar
                                else
                                    cadenahtml += &cadena	
                                endif
                            Next
                        Endif
                        hstr->(dbskip())
                    enddo
                    hstr->(dbsetorder(1))
                            
                    // Html Pie de la Seccion

                    if !empty(hsub->htmlpie) .and. hsub->flhtmlpie
                        aHtml:={}
                        m->html := hsub->htmlpie
                        FMemo_Mat('html',aHtml, len(m->html))
                        For k:=1 to len(aHtml)
                            cadena:= aHtml[k]
                            if substr(cadena,2,2)=='&&'
                                vmacro:=substr(cadena,4,len(cadena)-4)
                                vmacrovar:=&vmacro
                                cadenahtml += vmacrovar
                            else
                                cadenahtml += &cadena	
                            endif
                        Next
                    Endif
                    USE
                endif
            endif
            hsub->(dbskip())
        enddo
        hsub->(dbsetorder(1))

        // Pie Informe Html

        hbir->(dbseek(m->producto + '07'))
        IF !empty(hbir->html) .and. hbir->flhtml
            aHtml:={}
            m->html := hbir->html
            FMemo_Mat('html',aHtml, len(m->html))
            For k:=1 to len(aHtml)
                cadena:= aHtml[k]
                if substr(cadena,2,2)=='&&'
                    vmacro:=substr(cadena,4,len(cadena)-4)
                    vmacrovar:=&vmacro
                    cadenahtml += vmacrovar
                else
                    cadenahtml += &cadena	
                endif
            Next
        Endif    
        
        //Crear Archivo de Salida HTML
        m->hHtmFile := hb_FCreate(file2prn, FC_NORMAL,FO_WRITE )    
        FWrite(m->hHtmFile, cadenahtml )
        FClose( m->hHtmFile )

        Filedelete(dat_loc+'SEC??.*')
    else
        file2prn := 'Archivo No Generado Duns: ' + hDataDuns[1]['DUNSNUM']
    Endif

    // Cerrar las tablas DBF
    hsec->(dbclosearea())
	hcfg->(dbclosearea())
	hape->(dbclosearea())
	hbir->(dbclosearea())
	hmen->(dbclosearea())
	hsub->(dbclosearea())
	hniv->(dbclosearea())
	hstr->(dbclosearea())

Return file2prn

Function db_open()        

    USE &dat_loc.HTMLSEC ALIAS HSEC NEW
    SET INDEX TO &dat_loc.HTMLSEC0

    USE &dat_loc.HTMLCFG ALIAS HCFG NEW
    SET INDEX TO &dat_loc.HTMLCFG1

    USE &dat_loc.HTMLAPE ALIAS HAPE NEW
    SET INDEX TO &dat_loc.HTMLAPE1

    USE &dat_loc.HTMLBIR ALIAS HBIR NEW
    SET INDEX TO &dat_loc.HTMLBIR1

    USE &dat_loc.HTMLMEN ALIAS HMEN NEW
    SET INDEX TO &dat_loc.HTMLMEN1

    USE &dat_loc.HTMLSUB ALIAS HSUB NEW
    SET INDEX TO &dat_loc.HTMLSUB3, &dat_loc.HTMLSUB2, &dat_loc.HTMLSUB1

    USE &dat_loc.HTMLNIV ALIAS HNIV NEW
    SET INDEX TO &dat_loc.HTMLNIV1

    USE &dat_loc.HTMLSTR ALIAS HSTR NEW
    SET INDEX TO &dat_loc.HTMLSTR1, &dat_loc.HTMLSTR2, &dat_loc.HTMLSTR3

return nil

Function FMemo_Mat(cnomfile,mattxt, largo)
    
    local ntotblo:=0
       
    if largo=nil
        ntotblo := filesize(cnomfile)
    else
        ntotblo := largo
    endif
    nblock  := 128
    npos    := 0
    posi13:=0
    posi10:=0
    do while ntotblo > 0
        if largo=nil
            cbuffer:=filestr(cnomfile,nblock,npos)
        else
            cbuffer:=substr(&cnomfile,npos)
        endif
        if !empty(cbuffer)
            posi13:=at(chr(13),cbuffer)
            posi10:=at(chr(10),cbuffer)
            if posi13>0 .or.  posi10 >0 .or. !empty(cbuffer)
                cbuffer:=charrem(chr(13)+chr(10),left(cbuffer,iif(posi13>0, posi13, posi10)-1))
                if largo=nil
                    aadd(mattxt,cbuffer)
                else
                    if !empty(cbuffer)
                        aadd(mattxt,cbuffer)
                    endif
                endif
                if posi13 >0
                    npos+=posi13
                    ntotblo-=posi13
                elseif posi10 > 0
                    npos+=posi10
                    ntotblo-=posi10
                elseif ntotblo < nblock
                    ntotblo:=0
                endif
            else
                if ntotblo <=0
                    ntotblo:=0
                endif
            endif
        else
            if cbuffer=chr(10) .or.  cbuffer=chr(13)+chr(10)
                ntotblo=0
            endif
        endif
    enddo
    
return(nil)

Function html_clear(cadena)    
    cadena:=STRTRAN(cadena,CHR(12) ,"")
    cadena:=STRTRAN(cadena,CHR(255)," ")
    cadena:=STRTRAN(cadena,"ÿ"," ")
    cadena:=STRTRAN(cadena," "     ,"&aacute")
    cadena:=STRTRAN(cadena,"‚"     ,"&eacute")
    cadena:=STRTRAN(cadena,"¡"     ,"&iacute")
    cadena:=STRTRAN(cadena,"¢"     ,"&oacute")
    cadena:=STRTRAN(cadena,"£"     ,"&uacute")
    cadena:=STRTRAN(cadena,"¤"     ,"&ntilde")
    cadena:=STRTRAN(cadena,"¥"     ,"&Ntilde")
    cadena:=STRTRAN(cadena,CHR(167),"&#186")
    cadena:=STRTRAN(cadena,CHR(128),"&#8364")
    cadena:=STRTRAN(cadena,CHR(129),"&#252")
return(cadena)

Function FMayMin(cadena)    
    newcadena:=lower(cadena)
    newcadena:=tokenupper(newcadena)
    newcadena:=STRTRAN(newcadena,"&Aacute","&aacute")
    newcadena:=STRTRAN(newcadena,"&Eacute","&eacute")
    newcadena:=STRTRAN(newcadena,"&Iacute","&iacute")
    newcadena:=STRTRAN(newcadena,"&Oacute","&oacute")
    newcadena:=STRTRAN(newcadena,"&Uacute","&uacute")
    newcadena:=STRTRAN(newcadena,"&Ntilde","&ntilde")
    newcadena:=STRTRAN(newcadena,"¥"     ,"&Ntilde")
    newcadena:=STRTRAN(newcadena,CHR(167),"&#186")
    newcadena:=STRTRAN(newcadena,CHR(128),"&#8364")
    newcadena:=STRTRAN(newcadena,CHR(129),"&#252")
Return(newcadena)

Function FDetSic(varsic)
    local aParam:={=>}
    local oSic
    local hDataSic:={}
    local vcadena:=''
    aParam := {'sic'=>alltrim(varsic)}
	
	// Extraer informacion de la tabla SIC8DIG

	oSic := SicModel():New()
	hDataSic := oSic:SicGet(aParam)
    vcadena := Alltrim(hDataSic[1]['INDUSTRIA'])
    
Return(vcadena)

Function FRiesgo(vriesgo, namefield)
    vcadena:=''
    hape->(dbseek(vriesgo))
    vcadena := alltrim(hape->&namefield)
Return(vcadena)

Function FHtml(cadena, separador, cabHtml, pieHtml)
    intPosIni := 1
    m->temp_ml := ""
    m->cad_temp = cadena
    IF AT(separador, m->cad_temp) > 0		
        DO WHILE .T.
            intPosIni := AT(separador, m->cad_temp)
            IF intPosIni > 0
                m->temp_ml := m->temp_ml + cabHtml  + ALLTRIM(SUBSTR(m->cad_temp, 1, intPosIni - 1)) + pieHtml
                m->cad_temp := ALLTRIM(SUBSTR(m->cad_temp, intPosIni + 1))
            ELSE
                m->temp_ml = m->temp_ml + cabHtml + ALLTRIM(m->cad_temp) + PieHtml
                EXIT
            ENDIF
        ENDDO		
    ENDIF
Return(m->temp_ml)

Function FCambio(cadena, char_old, char_new)    
    newcadena:=''
    IF cadena == char_old
        newcadena:=char_new
    ELSE
        newcadena := cadena
    Endif
Return(newcadena)
        
{% mh_LoadFile( "/src/model/provider/conexionsql.prg" ) %}
{% mh_LoadFile( "/src/model/stringmodel.prg" ) %}
{% mh_LoadFile( "/src/model/dunsmodel.prg" ) %}
{% mh_LoadFile( "/src/model/datosmodel.prg" ) %}
{% mh_LoadFile( "/src/model/listamodel.prg" ) %}
{% mh_LoadFile( "/src/model/sicmodel.prg" ) %}
{% mh_LoadFile( "/lib/FunGen.prg" ) %}