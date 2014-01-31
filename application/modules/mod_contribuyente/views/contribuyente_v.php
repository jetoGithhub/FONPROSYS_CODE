<?php
if ( ! defined('BASEPATH')) exit('No esta permitido el acceso directo');
$base_url=base_url()."index.php/";
?>
<script type="text/javascript" >
    $(function() {
        ayudas_input('#','form_registra');
        //**************FUNCION DE VERIFICACION DE RIF*******
        verificarif = function(form,url,img,divimg){
         //var $contenidoAjaximg = $('div#'+divimg).html('<p><img src="'+img+'" /></p>');
         var $contenidoAjax = $('div#'+divimg).html('');
            $.ajax({
                type:"get",
                data:$('#'+form).serialize(),
                dataType:"json",
                url:url,
                global : false,
                success:function(data){
                    //alert(data.success)
                    if (data.response){
                        $contenidoAjax.html("<span class='ui-icon ui-icon-check' style='float: left; margin-right: 0.3em;'/>"+data.mensaje);
                        $('#nombre').val(data.nombre);
                        $("#btn_envio").removeAttr("disabled");
                        $('#cargarif').removeClass('ui-state-error');
                        $('#cargarif').addClass('ui-state-highlight');
                    }else{
                        $('#cargarif').removeClass('ui-state-highlight');
                        $('#cargarif').addClass('ui-state-error');
                        $contenidoAjax.html("<span class='ui-icon ui-icon-alert' style='float: left; margin-right: 0.3em;'/>"+data.mensaje);    
           }
                },
                 error:function(o,estado,excepcion){
                     if(excepcion=='Not Found'){

                     }else{

                     }
                 },beforeSend:function(){
                     $('#'+divimg).removeClass('ui-state-error');
                     $('#'+divimg).addClass('ui-state-highlight');                     
                     $('#'+divimg).empty();
                     $('#'+divimg).show();
                     $('#'+divimg).html('Verificando RIF <img  src="<?php print(base_url()); ?>include/imagenes/ajax-loader.gif" />');
                     $("#btn_envio").attr('disabled','disabled');}
                ,complete: function(){
                    $('#carga').hide();
                    $("#btn_envio").removeAttr('disabled');}
             });


         }// fin verifica rif
        ventana_registra = function(id_ventana,id_formulario,equis){
            $("#"+id_ventana).dialog({
                modal:false,
               
                closeOnEscape: false,
                resizable: false,
                autoOpen: true,	
                draggable: false,
                
                show: 'blind',
                stack: true,
                position: ["center","center"],
                buttons: {
                    "Enviar": function() { 
                        $("#form_registra").submit(); 
                    },
                    "Volver": function() { 
                        $('#dialogo_registra').dialog('close').toggle( "blind", {}, 150 );                    
                        //$('div#dialogo_registra').dialog('open');
                        setTimeout("window.location='<?php print(base_url()); ?>index.php/mod_contribuyente/inicio_c';", 300);}
                },
                beforeClose: function(){ return false; }});
            if (equis==1){
                $("#"+id_ventana)
                .siblings('.ui-dialog-titlebar')
                .find('a.ui-dialog-titlebar-close')
                .hide();
            }
            }

        ventana_registra('dialogo_registra','form_registra',1);
        $('div#dialogo_registra').dialog('open');
        
        validador('form_registra','<?php print($base_url); ?>mod_contribuyente/contribuyente_c/registraContribuyente','envia_preregistro');
        
  
        envia_preregistro = function(form,url){
            $.ajax({
                type:"post",
                data:$('#'+form).serialize(),
                dataType:"json",
                url:url,

                success:function(data){

                    if (data.respuesta){
                        setTimeout(function(){
                        $("#dialog-alert")
                        .dialog("open")
                        .dialog({beforeClose: function(){ setTimeout("window.location='<?php print(base_url()); ?>index.php/mod_contribuyente/inicio_c';", 20); }})
                        .children("#dialog-alert_message")
                        .html(data.mensaje);},50);
                    }else{
                        cambiar_codigo(cambiar_codigo('form_registra','captcha_registra',"<?php print(base_url()); ?>include/librerias/securimage/captcha.php"));
                        setTimeout(function(){
                        $("#dialog-alert")
                        .dialog("open")                        
                        .children("#dialog-alert_message")
                        .html(data.mensaje);},50);                
                    }
                },

                 error:function(o,estado,excepcion){
                     if(excepcion=='Not Found'){

                     }else{

                     }
                 },beforeSend:function(){
                     $("#carga").empty();
                     $('#carga').show();
                     $('#carga').html('Espere procesando Envio...<img  src="<?php print(base_url()); ?>include/imagenes/ajax-loader.gif" />');
                     $("#btn_envio").attr('disabled','disabled');}
                ,complete: function(){
                    $('#carga').hide();
                    $("#btn_envio").removeAttr('disabled');}});
         }       

         $("#captcha_registra").click(function() {
            cambiar_codigo('form_registra','captcha_registra',"<?php print(base_url()); ?>include/librerias/securimage/captcha.php");
        });       

//         $("#btn_envio").click(function() {
//            $("#form_registra").submit();
//        });       
//        $("#btn_volver").click(function() {
//        $('#dialogo_registra').dialog('close').toggle( "blind", {}, 150 );
//            //$('div#dialogo_registra').dialog('open');
//            setTimeout("window.location='<?php // print(base_url()); ?>index.php/mod_contribuyente/inicio_c';", 300);
//        });        

       
        $("div#dialog-alert").dialog({
        modal: true,
        autoOpen: false,
        hide: "fade",
        stack: true,
        position: ["center","center"]});
    $(".btn").button();


    $(" input ").addClass('ui-state-highlight ui-corner-all');
    $(" select ").addClass('ui-state-highlight ui-corner-all');
    $(" textarea ").addClass('ui-state-highlight ui-corner-all');  
    
            
    });
    jQuery(function($){
        $.mask.definitions['#'] = '[JVGEjvge]';
        $("#rif").mask("#999999999");
        
    });
</script>


<!-- Estructura -->
<div id="dialogo_registra" title="Pre - Registro" style="height:auto">   
    <form id="form_registra" style="" class=" focus-estilo form-style "> 
         
         <label style=" margin-right:43%" for="rif">RIF:</label>
         <label for="correo">Correo Electr&Oacute;nico:</label><br />
            <input  type="text" onblur="verificarif('form_registra','<?php print($base_url); ?>mod_contribuyente/contribuyente_c/verificaRif','<?php print(base_url()); ?>include/imagenes/ajax-loader.gif','cargarif');" name="rif" id="rif" class=" tamaño requerido  ui-widget-content ui-corner-all" />
            <input  condicion="email: true" type="text" name="correo" id="correo" class="tamaño requerido  ui-widget-content ui-corner-all"  />
        
        <br /><div class=" ui-widget " id="cargarif" style=" padding: 0px 0.7em; margin-left: 25%;margin-top: 0.5em; margin-bottom: 10px; position:absolute"></div><br />       
        <label for="nombre">Nombre:</label><br />            
            <input style=" width: 98%" readonly name="nombre" id="nombre" class="requerido  ui-widget-content ui-corner-all" />
        <br /><br />
        <label style=" margin-right:28%" for="clave_1">Contraseña:</label>            
        <label for="clave_2"  style="">Repetir Contraseña:</label><br />        
            <input condicion="minlength:6" type="password" name="clave_1" id="clave_1" class=" tamaño requerido  ui-widget-content ui-corner-all"  />
            <input style=""  condicion='minlength: 6, equalTo: "#clave_1"' type="password" name="clave_2" id="clave_2" class=" tamaño requerido  ui-widget-content ui-corner-all"  />
        <br /><br />
        <label style=" margin-right:19%" for="pregunta">Pregunta Secreta</label>
        <label for="respuesta" style="">Repuesta Secreta:</label><br />        
            <select id="pregunta" name="pregunta" class="requerido  ui-widget-content ui-corner-all">
                <option value="">Seleccione</option>
                    <?php
                    if (sizeof($preguntaSecreta)>0):
                        foreach ($preguntaSecreta as $pregunta):
                        print("<option value='$pregunta[id]'>$pregunta[nombre]</option>");
                        endforeach;
                    endif;

                    ?>            
            </select>         
            <input style="" type="password" name="respuesta" id="respuesta" class="tamaño requerido  ui-widget-content ui-corner-all"  />
          <br /><br />
            
            <!--        <label for="no_cnac">Tiene Nro. CNAC</label>
            <input type="checkbox" id="nro_cnac" name="nro_cnac" />-->           
            <div id="captcha_registra_container" class="captcha_container ui-widget-content ui-corner-top ayuda-input" align="center" txtayudai=" Haga click sobre el codigo de confirmacion para cambiarlo." >
                <img id="captcha_registra" src="<?php print(base_url()); ?>include/librerias/securimage/captcha.php" width="99%" height="60" />
            </div><br />
            <label for="codigo_registra">C&oacute;digo de Confirmaci&oacute;n:</label><br />
        <input id="Field3_r" style=" width: 98%" type="text" name="codigo_registra" id="codigo_registra" class="requerido ui-widget-content ui-corner-bottom" />
    </form>
    <div  class="ui-widget ui-helper-clearfix"></div>
<!--    <button id="btn_volver" class="btn"> Volver</button>
    <button   id="btn_envio" class="btn">Enviar</button>-->
    <div id="dialog-alert" title="Mensaje">
        <p id="dialog-alert_message"></p>
    </div>
        <center>
            <br/>
            <div style="display:none"id="carga" title="Mensaje">


        </div>          
        </center>    
</div>

<!-- Estilos aplicados solo a esta página -->
<style>

#btn_volver  { margin-left: 35px; }
#btn_envio   { margin-left: 25%; margin-top: 10%; } 
#cargarif    { margin-right: 2%; float:left;  }
/*label{ display:block;}*/
 input{ height:18px; font-size: 12px;margin-bottom:5px;font-family: sans-serif, monospace;}
 select { height:18px;font-size: 12px; width: 48%;margin-bottom:5px;font-family: sans-serif, monospace;}
 label{ font-weight: bold;}
 .tamaño{ width: 48%}
 /*textArea{ width: 70%}*/
 /* estilos para los formularios que se creen en el sistema en las ventanas emergentes o dialog
    */
    /*.form-style input label { display:block;}*/
/*    .form-style td,label{ font-weight: bold;}
    .form-style input { margin-bottom:12px;padding: .2em;  font-family: sans-serif, monospace; font-size: 12px }
    .form-style select{ margin-bottom:12px; padding: .2em; font-family: sans-serif, monospace;  font-size: 12px}
    .form-style textArea,textarea{ margin-bottom:12px; padding: .2em;  font-family: sans-serif, monospace; font-size: 12px }
    .form-style fieldset { padding:0; border:0; margin-top:25px; }
    .form-style h1 { font-size: 1.2em; margin: .6em 0; }*/
    
    
    /*
    *estylo para que cunado el cursor este sobre la caja coloque sombra en los bordes
    */   
    
    .focus-estilo input:focus{
        /*border: none;*/
        outline:0px;
        /*border-style: none;*/
          border-color: #BF4639;
          box-shadow: 1px 1px 7px #BF4639;
        -webkit-box-shadow:  1px 1px 7px #BF4639;
        -moz-box-shadow:  1px 1px 7px #BF4639;
        
        /*-moz-box-shadow: 10px inset 1px 1px #888;*/ 
    }
    .focus-estilo textArea:focus{
        /*border: none;*/
        outline:0px;
        /*border-style: none;*/
         border-color: #BF4639;
          box-shadow: 1px 1px 7px  #BF4639;
        -webkit-box-shadow:  1px 1px 7px  #BF4639;
        -moz-box-shadow:  1px 1px 7px #BF4639;
        
        /*-moz-box-shadow: 10px inset 1px 1px #888;*/ 
    }
    .focus-estilo select:focus{
         /*border: none;*/
         outline:0px;
         /*border-style: none;*/
          border-color: #BF4639; 
          box-shadow: 1px 1px 7px   #BF4639;
        -webkit-box-shadow:  1px 1px 7px  #BF4639;
        -moz-box-shadow:  1px 1px 7px   #BF4639 ;
        
        /*-moz-box-shadow: 10px inset 1px 1px #888;*/ 
    }
 
</style>
