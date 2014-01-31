//$(function() {
//    
//  $("#cargando").hide();   
//  $("#cargando").ajaxStart(function(){$(this).show();});
//  
//  $('#cargando').ajaxComplete(function(){$(this).hide(); }); 
//
//});

//***********APLICAR RESET A UN FORM CON $('formulario').reset() ****/////
  jQuery.fn.reset = function () {
  $(this).each (function() { this.reset(); });
}


//********PARA DETERMINAR SI UN ELEMENTO O VARIABLE ESTA DEFINIDO (RETORNA BOOLEANO)*****
function variableDefinida( variable) { return (typeof(variable) == "undefined")?  false: true;}

//*****ESTABLECE LOS ERRORES EN LOS CAMPOS AFECTADOS Y DENTRO DE UN TOOLTIP****
establece_error_campo = function(item, message){
 /*   if( !$(item).css({ border:"1px solid red" }) ){
        $(item).css({ border:"1px solid red" });
    }*/
    var elem = $(item),
    corners = ['center left', 'center right'],
    flipIt = elem.parents('span.right').length > 0;
    $(item).qtip({
        content: message,
        style: {
            name: 'cream',
            border: {
                width: 2,
                radius: 3
            },
            tip: 'lefttMiddle'
        },
        position: {
            my: corners[flipIt ? 0 : 1],
            at: corners[flipIt ? 1 : 0],
            viewport: $(window)
        },
        show: {
            event: false,
            ready: true,
            effect: function(offset) {
                $(this).show('slide', null, 300);
            }
        },
        hide: false,
        style: {
            classes: 'ui-tooltip-cream ui-tooltip-rounded'
//                classes: 'ui-tooltip-red ui-tooltip-rounded'
        }
    });
    }
//*********LIMPIA EL RESALTADO DE LOS CAMPOS Y QUITA LOS TOOLTIP*******
limpia_errores = function(item){
        //$(item).removeClass('ui-state-highlight');
	//$(item).css({ border:"0px solid red" });


        try{ $(".ui-tooltip-cream").remove(); }catch(e){}
}

//REVISA LOS CAMPOS QUE 
muestra_errores = function(error_map, listado_errores){
        //limpia_errores('#form_ingreso input');
        for( var i=0; i<listado_errores.length; i++ ){
                establece_error_campo( listado_errores[i].element, listado_errores[i].message );
        }
        //setTimeout("limpia_errores();", 3000);function(){alert("Hello")}
	setTimeout(function(){
        for( var ii=0; ii<listado_errores.length; ii++ ){
                limpia_errores( listado_errores[ii].element);
        }

}, 3000);
        return false;
}                             
//*************CAMBIA LA IMAGEN DEL CAPTCHA*******        
cambiar_codigo = function(id,id_c,dir_c){
        $("#"+id_c).attr("src", dir_c+"?"+Math.random().toString() );
}

//*************CREACION DE LA VENTANA DE INGRESO AL SISTEMA****
ventana_ingreso = function(id_ventana,id_formulario,equis,modal){
    $("#"+id_ventana).dialog({
//        modal:modal,
//        closeOnEscape: true, 
        width: 350,
        resizable: false,
        draggable: false,
        show: 'blind',
//        stack: true,
        position: ["center","center"],
        beforeClose: function(){ return false; }//,
//        buttons: [
//            {
//                text: "Cambiar código",
//                click: function(){cambiar_codigo('form_ingreso')}
//            },
//            {
//                text: "Ingresar",
//                click: function(){ $("#"+id_formulario).submit(); }
//            }
//        ]
    });


    if (equis==1){
        $("#"+id_ventana)
        .siblings('.ui-dialog-titlebar')
        .find('a.ui-dialog-titlebar-close')
        .hide();
    };
};
//*****************Arma las ayudas dinamicasmente en el documento*******///
ayudas=function(tipo,elemento,my,at,effect,direction){   
    
    
    $(tipo+elemento).find('.ayuda').each(function() {
        var script   = document.createElement("script");
        script.type  = "text/javascript";  
        
        var abre_qtip='$("#'+this.id+'").qtip({';
        var content='content:{ text:"'+$(this).attr("txtayuda")+'"},';
        var posicion=' position: {my: "'+my+'",at: "'+at+'"},';
        var estilo='style:{classes: "ui-tooltip-red ui-tooltip-rounded myCustomClass"},';
        var show='show: {effect: function(offset) {$(this).show( "'+effect+'",{direction:"'+direction+'"}, 500 );}}';
        var cierra_qtip='});';
        
         script.text  = abre_qtip+content+posicion+estilo+show+cierra_qtip;             // use this for inline script
        
         document.body.appendChild(script);
    });
    
};

ayudas_input=function(tipo,elemento){   
    
    
    $(tipo+elemento).find('.ayuda-input').each(function() {
        var script   = document.createElement("script");
        script.type  = "text/javascript";  
        
        var abre_qtip='$("#'+this.id+'").qtip({';
        var content='content:{ text:"'+$(this).attr("txtayudai")+'"},';
        var posicion=' position: {my: "left center ",at: "right center"},';
        var estilo='style:{classes: "ui-tooltip-youtube ui-tooltip-rounded"},';
//        var show='show: {event: " focus hover"},';
//        var hide='hide: {event:"unfocus "}';
//        var show='show: {effect: function(offset) {$(this).show( "'+effect+'",{direction:"'+direction+'"}, 500 );}}';
        var cierra_qtip='});';
        
//         script.text  = abre_qtip+content+posicion+estilo+show+hide+cierra_qtip;             // use this for inline script
        script.text  = abre_qtip+content+posicion+estilo+cierra_qtip;
         document.body.appendChild(script);
    });
};

//***********VALIDA EL FORMULARIO DE INGRESO DINAMICAMENTE********
validador = function(formulario_id,url_envio,funcion){
    $.extend($.validator, {
        messages: {
        required: "Este campo es requerido",
        remote: "Porfavor, corrije el valor de este campo.",
        email: "Ingresa una dirección de correo válida.",
        url: "Ingresa una URL válida.",
        date: "Ingresa una fecha válida.",
        dateISO: "Ingresa una fehca válida (ISO).",
        number: "Ingresa un número válido.",
        digits: "Ingresa sólo letras.",
        creditcard: "Ingresa un número de tarjeta de crédito válido.",
        equalTo: "Debe ser igual a la anterior.",
        accept: "Ingresa un valor con extensión válida.",
        maxlength: $.validator.format("Porfavor ingresa menos de {0} caractéres."),
        minlength: $.validator.format("Porfavor ingresa almenos {0} caractéres."),
        rangelength: $.validator.format("Porfavor ingresa un valor entre {0} y {1} caractéres de longitud."),
        range: $.validator.format("Ingresa un valor entre {0} y {1}."),
        max: $.validator.format("Ingresa un valor menor o igual que {0}."),
        min: $.validator.format("Ingresa un valor mayor o igual a {0}.")
    }
});
    
    var abre_validate='$("#'+formulario_id+'").validate({';
    var cierra_validate=',submitHandler:function(form){'+funcion+'("'+formulario_id+'","'+url_envio+'");},showErrors: muestra_errores,onfocusout: false,onkeyup: false,onclick: false});';
    //VARIABLES DEL ARREGLOS DEL RULES////
    var abre_rules='rules: {';
    var cuerpo_rules = [];
    var cierra_rules='}';
    
    //VARIABLES DEL ARREGLOS MESSAGES/////
    var abre_messages=',messages: {';
    var cuerpo_messages = [];
    var cierra_messages='}';
        
    $("#"+formulario_id).find('.requerido').each(function() {
        var elemento= this;
        var mensaje= $(this).attr("mensaje");
        var condicion= $(this).attr("condicion");
        var arregloInput = new Array();

        arregloInput[elemento.name] = elemento.name;
        arregloInput[elemento.value] = elemento.value;
        arregloInput[mensaje] = mensaje;
        arregloInput[condicion] = condicion;
        if (variableDefinida(arregloInput[condicion])){
            cuerpo_rules.push(arregloInput[elemento.name]+':{ required: true ,'+arregloInput[condicion]+' }');
        }else{
            cuerpo_rules.push(arregloInput[elemento.name]+':{ required: true }');
        }
        if (variableDefinida(arregloInput[mensaje])){
            cuerpo_messages.push(arregloInput[elemento.name]+':{ required:"'+arregloInput[mensaje]+'" }');
        }
    });
    var script   = document.createElement("script");
    script.type  = "text/javascript";
//    script.src   = "path/to/your/javascript.js";    // use this for linked script
    script.text  = abre_validate+abre_rules+cuerpo_rules+cierra_rules+abre_messages+cuerpo_messages+cierra_messages+cierra_validate;             // use this for inline script
    document.body.appendChild(script);
//    alert(abre_validate+abre_rules+cuerpo_rules+cierra_rules+abre_messages+cuerpo_messages+cierra_messages+cierra_validate);

}

//*******GESTIONAN EL MENU PRINCIPAL DEL SISTEMA********
function menu_crear_titulo(id, caption,baseurl,rol){
    var url=baseurl+'mod_administrador/principal_c/cargar_dialog_abuelo_padre';
    var idmodulo = id.split("-");
     var hr
    if(rol=='SUPER_ADMINISTRADOR'){
       hr = $("<h3 class='principal'><a bandera='principal-"+idmodulo[1]+"' href=\"javascript:;\">"+caption+"</a><span txtayuda='Crear nuevo hijo en el menu' style='position: absolute; margin-top:-20px; margin-left:160px' class=' ayuda ui-icon ui-icon-arrow-4' id='iconoabuelo-"+idmodulo[1]+"' onClick=\"javascript:cargar_vista_dialog('"+url+"',"+idmodulo[1]+",0,'dialogarmamenu');\"></span></h3>"); 
    }else{
       hr = $("<h3 class='principal'><a bandera='principal-"+idmodulo[1]+"' href=\"javascript:;\">"+caption+"</a></h3>");
    }
    hr.attr("id",id);
    return hr;
}
function menu_crear_cuerpo_elemento(id){
    
    var div = $("<div><ul ></ul></div>");
    div.attr("id",id);
    return div;
}
function menu_crear_elemento(id, caption, link){
     var idmodulo = id.split("-");    
    var li = $("<li><span style='position: absolute; float:left;' class='ui-icon ui-icon-radio-off'></span><a style='margin-left:15px' bandera='secundario-"+idmodulo[1]+"' href=\"#\"  >"+caption+"</a></li>");
    li.attr("id",id)
    return li;
}

//******GESTIONAN LA FOTO DEL USUARIO EN EL MENU*******
function viewLargerImage( $link ) {
    var src = $link.attr( "href" ),
        title = $link.siblings( "img" ).attr( "alt" ),
        $modal = $( "img[src$='" + src + "']" );

    if ( $modal.length ) {
        $modal.dialog( "open" );
    } else {
        var img = $( "<img alt='" + title + "' width='384' height='288' style='display: none; padding: 8px;' />" )
            .attr( "src", src ).appendTo( "body" );
        setTimeout(function() {
            img.dialog({
                title: title,
                width: 400,
                modal: true,
                draggable:false,
                resizable: false
            });
        }, 1 );
    }
}

// resolve the icons behavior with event delegation
$( "ul.fotousuario > li" ).click(function( event ) {
    var $item = $( this ),
        $target = $( event.target );

    if ( $target.is( "a.ui-icon-trash" ) ) {
        deleteImage( $item );
    } else if ( $target.is( "a.ui-icon-zoomin" ) ) {
        viewLargerImage( $target );
    } else if ( $target.is( "a.ui-icon-refresh" ) ) {
        recycleImage( $item );
    }

    return false;
});


//**************FUNCION DE ENVIO DE FORMULARIO PARA LA CREACION DE LAS PESTAÑAS EN LA TABS 
//              Y PARA CREACION DE DE SUB MODULOS DENTRO DEL MENU                 *******
envia_tabs = function(form,url){
//    alert('#'+form)
//    data=$('#'+form).serialize();
//    alert(data);
    $.ajax({
        type:"post",
        data:$('#'+form).serialize(),
        dataType:"json",
        url:url,
        success:function(data){
            
            if(data.resultado==true){                
                
                if(form=='crea-tabs'){
                
                    $('#formtabs').dialog('close'); 

                    
                }
                if(form=='frmarmamenu'){
                
                    $('#dialogarmamenu').dialog('close');            

                }
                if(form=='frmbuscarcontri'){
                    $("#memsajerror").hide();
                    $('#frmbuscarcontri')[0].reset();
                    $("#planilla_contribu").html(data.vista);      
                    $("#planilla_contribu").show('drop',1000);
                }
                
            }else{
                
                if(form=='frmbuscarcontri'){ 
                    
                    $('#frmbuscarcontri')[0].reset();    
                    $("#memsajerror").show('drop',1000);
                    $("#planilla_contribu").empty();
                    $("#planilla_contribu").hide();
                }
                
            }
            
        },
        error:function(o,estado,excepcion){
             if(excepcion=='Not Found'){
                 
             }else{
                 
             }
         }
     });
     
 
}

//Funcion generica para cargar las vistas - Controlador -> Vista
//Parametros->
//url: apunta al metodo del controlador que carga las vistas
//id: identificador de la tabla - en el caso de requerir paso de parametros a la vista
//ident: identifica el boton seleccionado para establecer condiciones que indicaran cual vista se mostrara
//id_div: nombre del id del div en el cual se incluira la vista
                    
cargar_vista_dialog=function(url,id,ident,id_div){

//    alert(id_div);
    $.ajax({
        type:"post",
        data:{ id:id,identificador:ident },
        dataType:"json",
        url:url,
        success:function(data){
//             alert(data.vista);
            if (data.resultado){
                
                $("#"+id_div).html(data.vista);              
                
                $("#"+id_div).dialog('open');
            }
        }

    });

};


