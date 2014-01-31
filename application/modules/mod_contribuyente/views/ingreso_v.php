<?php
if ( ! defined('BASEPATH')) exit('No esta permitido el acceso directo');
$base_url=base_url()."index.php/";
?>
<script type="text/javascript" >
   
    $(function() {
        
    ayudas_input('#','form_ingreso');
    
        envia_formulario = function(form,url){
            $.ajax({
            type:"post",
            data:$('#'+form).serialize(),
            dataType:"json",
            url:url,
            success:function(data){
            
            if (data.success){
                location.reload();
            }else{
                cambiar_codigo('form_ingreso','captcha_login',"<?php print(base_url()); ?>include/librerias/securimage/captcha.php");
                $("#dialog-alert")
                .dialog("open")
                .children("#dialog-alert_message")
                .html(data.message);
            }
            },
            error:function(o,estado,excepcion){
                if(excepcion=='Not Found'){
                }else{
                    
                }
            }});
        }
    
envia_formulario_restaura = function(form,url){
            $.ajax({
            type:"post",
            data:$('#'+form).serialize(),
            dataType:"json",
            url:url,
            success:function(data){
            
            if (data.success){
                setTimeout(function(){
                    $('#form_restaura').reset();
                    $('#carga').show();
                    $('#carga').html('<p style="text-align: left;width:90%;font-size: 12px;"><span class="ui-icon ui-icon-check" style="float:left"></span><strong style="color:green;float:left">Mensaje:&nbsp;&nbsp;</strong>'+data.message+'</p>')
                },50);
            }else{                
                setTimeout(function(){
                    $('#carga').show();
                    $('#carga').html('<p style="text-align: left;width:60%;font-size: 12px;"><span class="ui-icon ui-icon-alert" style="float:left"></span><strong style="color:#CD0A0A;float:left">Mensaje:&nbsp;&nbsp;</strong>'+data.message+'</p>')
                    //$("#carga").css({background:'#FEF6F3',border:'1px solid #CD0A0A'});
                    //$("#carga").addClass('ui-state-error');
                },50);
            }
            },
            error:function(o,estado,excepcion){
                if(excepcion=='Not Found'){
                }else{
                    
                }
            },beforeSend:function(){
            
            
            $("#carga").empty();
            $('#carga').show();
            $('#carga').html('Espere procesando envio...<img  src="<?php print(base_url()); ?>include/imagenes/ajax-loader.gif" />');
            $("#btn_form_restaura").attr('disabled','disabled');}
            ,complete: function(){
            $('#carga').hide();
            $("#btn_form_restaura").removeAttr('disabled');}});
        }               
        ventana_ingreso_contri = function(id_ventana,id_formulario,equis){
            $("#"+id_ventana).dialog({
                resizable: false,
                draggable: false,
                autoOpen:true,
                show: 'blind',
                position: ["center","center"],
                beforeClose: function(){ return false; }});


            if (equis==1){
            $("#"+id_ventana)
            .siblings('.ui-dialog-titlebar')
            .find('a.ui-dialog-titlebar-close')
            .hide();
        }
        }
        ventana_ingreso_contri('dialogo_ingreso','form_ingreso',1);
        
        validador('form_ingreso','<?php print($base_url); ?>mod_contribuyente/ingreso_c','envia_formulario');
        validador('form_restaura','<?php print($base_url); ?>mod_contribuyente/contribuyente_c/restauraClaveEnvia','envia_formulario_restaura');


        
        $("#captcha_login").click(function() {
            cambiar_codigo('form_ingreso','captcha_login',"<?php print(base_url()); ?>include/librerias/securimage/captcha.php");
        });
    
        $("#btn_inicia_cont").click(function() {
            $("#form_ingreso").submit();});
         $("#btn_envio").click(function() {
            $("#form_registra").submit();});       
         $("#btn_form_restaura").click(function() {
             $("#form_restaura").submit();});        
        $("#btn_registro_cont").click(function() {
            $('#dialogo_ingreso').dialog('close').toggle( "blind", {}, 150 );
            setTimeout("window.location='<?php print($base_url); ?>mod_contribuyente/contribuyente_c/externo';", 300);

        }); 
    $("div#dialog-alert").dialog({
        modal: true,
        autoOpen: false,
        hide: "fade",
        stack: true,
        position: ["center","center"]
    });       
        $("#btn_olvida_cont").click(function() {
            $("#carga").empty();
            $("#dialog_olvida_cont").dialog('open');
            $("#form_restaura").reset();
        });
        $("#dialog_olvida_cont").dialog({
            modal: true,
            autoOpen: false,
            hide: "fade",
            width:320,
            
            stack: true,
            position: ["center","center"]
        });         
        $(".btn").button();
    $(" input ").addClass('ui-state-highlight ui-corner-all');
    $(" select ").addClass('ui-state-highlight ui-corner-all');
    $(" textarea ").addClass('ui-state-highlight ui-corner-all');         
    });

</script>

<!-- Estructura -->
<div id="dialogo_ingreso" title="Inicio de Sesiòn de Contribuyentes">
    <form id="form_ingreso" class=" focus-estilo form-style">
        <label for="usuario">Usuario:</label>
        <input  type="text" name="usuario" id="usuario" class="requerido  ui-widget-content ui-corner-all"  />
        
        <br/>
        <label for="clave">Clave de Acceso:</label>
	<input type="password" name="clave" id="clave" class="requerido  ui-widget-content ui-corner-all" />
	
        <br/>
        
	<div id="captcha_login_container" class="captcha_container ui-widget-content ui-corner-top ayuda-input" align="center" txtayudai=" Haga click sobre el codigo de confirmacion para cambiarlo." >
            <img id="captcha_login" src="<?php print(base_url()); ?>include/librerias/securimage/captcha.php" width="99%" height="100" />
	</div><br />
        <label for="codigo">Código de confirmación:</label>
        <input id="Field3" type="text" name="codigo" id="codigo" class="requerido ui-widget-content ui-corner-bottom "  />
    </form>
    <div class="ui-widget ui-helper-clearfix"></div>
    <button id="btn_olvida_cont" class="btn"> Olvid&oacute; su Contraseña?</button>
    <button id="btn_inicia_cont" class="btn">Iniciar Sesi&oacute;n</button>
    <button id="btn_registro_cont" class="btn">Registro de Usuarios Nuevos</button>

</div>
<div id="dialog-alert" title="Mensaje">
    <p id="dialog-alert_message"></p>
</div>
<div id="dialog_olvida_cont" title="¿Restauracion de Contraseña?">
    <p id="dialog_olvida_cont_message"> </p>
        
    <form id="form_restaura" class=" focus-estilo form-style">
        <center><p>Ingrese su Correo Electronico o Login del usuario que desea retaurar su contraseña.</p></center>
        <br />
        <!--        
<table>
            <tr>
                <td>-->
                    <label for="usuario">Usuario / RIF:</label>
                    <input  type="text" size="35" name="rif_restaura" id="rif_restaura" class="requerido  ui-widget-content ui-corner-all"  />
                    <label for="correo">Correo:</label>
                    <input  type="text" size="35" name="correo_restaura" id="correo_restaura" class="requerido  ui-widget-content ui-corner-all" condicion="email:true" />
<!--                </td>
                <td>-->
                    <button id="btn_form_restaura" class="btn">Enviar</button>
                <!--</td>-->
<!--            </tr>
        </table>-->
        
        
        
    </form>        
        <center>
            
            <div style="display:none;"id="carga" title="Mensaje">


        </div>          
        </center>

</div>

<!-- Estilos aplicados solo a esta página -->
<style>    
 #dialogo_ingreso input select { display:block; height:20px;font-size: 12px}
 #dialogo_ingreso label{ display:block;}
#btn_inicia_cont{ float:right }   

#btn_registro_cont{ margin-left: 25%; margin-top: 10%; } 
#btn_form_restaura{ float: right; margin-top: 20px }

/*
    * estilos para los formularios que se creen en el sistema en las ventanas emergentes o dialog
    */
    .form-style input label { display:block;}
    .form-style td,label{ font-weight: bold;}
    .form-style input { margin-bottom:12px; width:95%; padding: .2em;  font-family: sans-serif, monospace; font-size: 12px }
    .form-style select{ margin-bottom:12px; width:98%; padding: .2em; font-family: sans-serif, monospace;  font-size: 12px}
    .form-style textArea,textarea{ margin-bottom:12px; width:95%; padding: .2em;  font-family: sans-serif, monospace; font-size: 12px }
    .form-style fieldset { padding:0; border:0; margin-top:25px; }
    .form-style h1 { font-size: 1.2em; margin: .6em 0; }
    
    
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
