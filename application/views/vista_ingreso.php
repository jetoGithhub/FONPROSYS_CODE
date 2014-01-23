<?php
if ( ! defined('BASEPATH')) exit('No esta permitido el acceso directo');
$base_url=base_url()."index.php/";
echo 'quede en la hoja 17 de las correciones';
?>
<script type="text/javascript" >
    $(function() {
        
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
                .html(data.message)
                .dialog("option", {title: "Alerta!!!"});
            }
            },
            error:function(o,estado,excepcion){
                if(excepcion=='Not Found'){
                }else{
                    
                }
            }});
        }          
        ventana_ingreso('dialogo_ingreso','form_ingreso',1,true);
        $('div#dialogo_ingreso').dialog('open');
        validador('form_ingreso','<?php print($base_url); ?>ingreso','envia_formulario');


        
        $("#captcha_login").click(function() {
            cambiar_codigo('form_ingreso','captcha_login',"<?php print(base_url()); ?>include/librerias/securimage/captcha.php");
        });
    
        $("#btn_inicia_cont").click(function() {
            $("#form_ingreso").submit();
        });
         $("#btn_envio").click(function() {
            $("#form_registra").submit();
        });       
        
        $("#btn_registro_cont").click(function() {
            $('#dialogo_ingreso').dialog('close').toggle( "blind", {}, 150 );
            setTimeout("window.location='<?php print($base_url); ?>mod_contribuyente/contribuyente_c/externo';", 300);

        });
        $("div#dialog-alert").dialog({
            modal: true,
            autoOpen: false,
            hide: "fade",
            stack: true,
            position: ["center","center"]}); 
        
        $("#btn_olvida_cont").click(function() {
            $("#dialog_olvida_cont").dialog({
                modal: true,
                autoOpen: true,
                hide: "fade",
                stack: true,
                position: ["center","center"]});
        });
        $(".btn").button();
    $(" input ").addClass('ui-state-highlight ui-corner-all');
    $(" select ").addClass('ui-state-highlight ui-corner-all');
    $(" textarea ").addClass('ui-state-highlight ui-corner-all'); 
    });

</script>
<!--encabezado-->
<!--<div id="logo_encab" style="border: 0px solid blue; position: relative;  height: 370px;">
    <center><img src="<?php // echo base_url()."/include/imagenes/encabezado.png"; ?>"/></center>
</div>-->
<!-- Estructura -->
<div id="dialogo_ingreso"   title="Ingreso al sistema">
    <form id="form_ingreso" class="form-style focus-estilo">
        <table border="0" style=" width: 100%">
            <tr>
                <td rowspan="2">
                <img src="<?php echo base_url()."/include/imagenes/logo_cnac.png"; ?>" width="100px"/>
                <td>
                <td>
                    <label for="usuario" style=" text-align: center; margin-top: 20px"><b>USUARIO</b></label>
                    <input type="text" name="usuario" id="usuario" class="requerido  ui-widget-content ui-corner-all"  /> 
                    <label for="clave" style=" text-align: center"><b>CLAVE DE ACCESO</b></label>
                    <input type="password" name="clave" id="clave" class="requerido  ui-widget-content ui-corner-all" />
                                        <!--                <label for="codigo">Código de confirmación:</label>
                <div id="captcha_login_container" class="captcha_container ui-widget-content ui-corner-top" align="center">
                    <img id="captcha_login" src="include/librerias/securimage/captcha.php" width="99%" height="100" />
                </div>
                 <input id="Field3" type="text" name="codigo" id="codigo" class="requerido ui-widget-content ui-corner-bottom" />-->
                </td>                
            <tr>
            <tr ><td colspan="3" style=" border-bottom: 1px solid; border-bottom-color: #D3D3D3;  "></td></tr>    
           
        </table>
<!--        <label for="usuario">Usuario:</label>
        <input  type="text" name="usuario" id="usuario" class="requerido  ui-widget-content ui-corner-all"  />
        
        
        <label for="clave">Clave de acceso:</label>
	<input type="password" name="clave" id="clave" class="requerido  ui-widget-content ui-corner-all" />
	
        
        <label for="codigo">Código de confirmación:</label>
	<div id="captcha_login_container" class="captcha_container ui-widget-content ui-corner-top" align="center">
            <img id="captcha_login" src="include/librerias/securimage/captcha.php" width="99%" height="100" />
	</div>
        <input id="Field3" type="text" name="codigo" id="codigo" class="requerido ui-widget-content ui-corner-bottom" />-->
    </form>
    <div class="ui-widget ui-helper-clearfix"></div>
    <br />
    <!--<button id="btn_olvida_cont" class="btn"> ¿Olvido su contraseña?</button>-->
    <button id="btn_limpiar_cont" class="btn">Limpiar</button>
    <button id="btn_inicia_cont" class="btn">Iniciar Sesion</button>
    <!--<button id="btn_registro_cont" class="btn">Registro Nuevos Usuarios</button> -->

</div>

<div id="dialog-alert" title="Mensaje">
    <p id="dialog-alert_message"></p>
</div>
<div id="dialog_olvida_cont" title="¿Restauracion de Contraseña?">
    <p id="dialog_olvida_cont_message"></p>
</div>

<!--pie-->
<!--<div id="pie" style="border: 0px solid; background-image:url('/fonprosys_code/include/imagenes/pie_con_logo.png'); background-repeat: no-repeat; height: 200px; margin-left: 160px">
</div>-->


<!-- Estilos aplicados solo a esta página -->
<style>    
 /*#dialogo_ingreso input  select {margin-bottom:12px; width:95%; padding: .2em;  font-family: sans-serif, monospace; font-size: 12px}*/
 #dialogo_ingreso label{ display:block;}
#btn_inicia_cont{ float:right; }   

#btn_registro_cont{ margin-left: 25%; margin-top: 10%; } 
.form-style input label { display:block;}
.form-style td,label{ font-weight: bold; margin-bottom: 5px}
.form-style input { margin-bottom:12px; width:95%; padding: .2em;  font-family: sans-serif, monospace; font-size: 14px }
 .focus-estilo input:focus{
      border-color: #BF4639;
      /*border:none;*/
      outline:0px;/* elimina bordes en crom safari y firefox*/
      box-shadow: 1px 1px 7px   #BF4639;
    -webkit-box-shadow:  1px 1px 7px  #BF4639;
    -moz-box-shadow:  1px 1px 7px   #BF4639 ;
}
.ui-dialog{
    
  max-width: 50%
}

</style>
