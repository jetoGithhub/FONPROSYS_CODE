//CAMBIA EL CODIGO CAPTCHA Y LO MUESTRA DENTRO DEL DIV CORRESPONDIENTE
cambiar_codigo_captcha = function(id_captcha,url_captcha){
    id_captcha="captcha_login";
    url_captcha="include/librerias/securimage/captcha.php";
    $("#"+id_captcha).attr("src", url_captcha+"?"+Math.random().toString() );
}


//RESALTA EL ITEM QUE TENGA ERROR Y MUESTRA MENSAJE DENTRO DE UN TOOLTIP
muestra_errores_tooltip = function(item, mensaje){
//    alert(message)
    if( !$(item).hasClass('ui-state-highlight') ){
        $(item).addClass('ui-state-highlight');
    }
    var elem = $(item),
    corners = ['center left', 'center right'],
    flipIt = elem.parents('span.right').length > 0;
    $(item).qtip({
        content: mensaje,
        style: {
            name: 'cream',
            border: {
                width: 3,
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
            classes: 'ui-tooltip-red ui-tooltip-rounded' //COLOR DE TOOLTIP
        }
    });
}

//QUITA EL RESALTADO DE LOS ERRORES Y OCULTA LOS TOOLTIPS
limpia_errorres = function(){
    $("#form_ingreso input").removeClass('ui-state-highlight');
    try{
        $(".qtip").remove();
    }
    catch(e){
        
    }
}

//REVISA LOS CAMPOS QUE TENGAN ERRORES Y MUESTRA SUS ERRORES
muestra_errores = function(error_map, error_list){
    limpia_errorres();
    for( var i=0; i<error_list.length; i++ ){
        muestra_errores_tooltip( error_list[i].element, error_list[i].message );
    }
    return false;
}


envia_form = function(id_form,url,id_carga){
    var form = "#"+id_form;
    $.ajax({
        type:"post",
        data:$(form).serialize(),
        dataType:"json",
        url:url,
        ajaxStart:function(){
            $("#"+id_carga).show();
        },
        success:function(data){
            alert(data.success)
            if (data.success){
                location.reload();
            }
        },
        ajaxComplete:function(){
            $("#"+id_carga).hide();
        },
        error:function(o,estado,excepcion){
            if(excepcion=='Not Found'){
                
            }else{
                
            }
        }
    });	
}

valida_form = function(id_form){
    $("#"+id_form).find('.requerido').each(function() {
        var elemento= this;
        var arregloElementos = new Array();
        arregloElementos[elemento.name] = elemento.name;
        arregloElementos[elemento.value] = elemento.value;



alert('nombre: ' + arregloElementos[elemento.name] + 'es ' +arregloElementos[elemento.value]);
        
        });
}
//CONFIGURACION PARA LA VALIDACION DE FORMULARIOS
$('#form_ingreso').validate({
    
			rules: {
                            

                       
				usuario:	{ required: true },
				clave:		{ required: true },
				codigo:		{ required: true }
			},
			messages: {
				usuario:	{ required: 'Indique el usuario' },
				clave:		{ required: 'Indique la clave de acceso' },
				codigo:		{ required: 'Indique el código de seguridad' }
			},
			submitHandler: submit_ingreso,
			showErrors: show_errors,
			onfocusout: false,
			onkeyup: false,
			onclick: false
		});