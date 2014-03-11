<script type="text/javascript" >
    function bloqueaInputs(form,tipo)
{

	var aqEstado = 'X'//rtrim(document.Cliente.AQESTADO.value);

	if(aqEstado == "X")
	{
		var formCliente = document.getElementById(form); //--> donde Cliente es es form
		Elementos1 = document.getElementsByTagName("input"); //--> donde Elementos es un array que lo declaramos así directamente
		Elementos2 = document.getElementsByTagName("textarea");
                Elementos3 = document.getElementsByTagName("select");//--> donde input son el tipo de elementos de la página que queremos deshabilitar
		var i=0;
		for(i=0; i<Elementos1.length; i++)
		{
                    if(tipo==false){ 
                        Elementos1[i].disabled =false;
                    }else{ 
                        Elementos1[i].disabled = true;
                    }
		}
 		for(i=0; i<Elementos2.length; i++)
		{
                    if(tipo==false){ 
                        Elementos2[i].disabled =false;
                    }else{ 
                        Elementos2[i].disabled = true;
                    }
		}
		for(i=0; i<Elementos3.length; i++)
		{
                    if(tipo==false){ 
                        Elementos3[i].disabled =false;
                    }else{ 
                        Elementos3[i].disabled = true;
                    }
		}   
	}

} 
//    $(document).ajaxStart(function() {
//            var mensaje='Espere procesando envio...<br/><img  src="<?php print(base_url()); ?>include/imagenes/ajax-loader.gif" />'
//            $('#carga').html(mensaje);
//            $('#carga').show();
//}).ajaxComplete(function() {
//           
//            $('#carga').hide();
//});     
    $(function() {
   
        
      
        //$('#btn_restaura_cont2').ajaxStart(function(){$(this).text('Restaurar Contraseña1');});
//            $(this).dialog({
//            dialogClass:'transparent',
//            resizable: false,
//            draggable: true,
//            modal: true,
//            height: 200,
//            width: 200,
//            autoOpen: false,
//            overlay: { opacity: 0 }});
//        $('#dialog_empty').dialog('open');
//        $('#dialog_empty').css('display','');});
       // $('#cargando').ajaxComplete(function(){$(this).hide();
        validador('form_restaura_clave','<?php print(base_url()); ?>index.php/mod_contribuyente/contribuyente_c/enviaClaveNueva','envia_form_clave');
        $("#dialogo_clave").dialog({
            modal:false,
            closeOnEscape: false,
            resizable: false,
            autoOpen: true,
            width:300,
            //height:500,
            show: 'blind',
            stack: true,
            position: ["center",'center'],
            beforeClose: function(){ return false; }});
        
        
        $("#btn_restaura_cont").click(function() {
            $("#form_restaura_clave").submit();
        });
        
        
        $(" input ").addClass('ui-state-highlight ui-corner-all');
        $(" select ").addClass('ui-state-highlight ui-corner-all');
        $(" textarea ").addClass('ui-state-highlight ui-corner-all');
        
        $("#captcha_restaura_container").click(function() {
            cambiar_codigo('form_restaura_clave','captcha_restaura',"<?php print(base_url()); ?>include/librerias/securimage/captcha.php");});
        
        $(".btn").button();
        envia_form_clave = function(form,url){
            $.ajax({
            type:"post",
            data:$('#'+form).serialize(),
            dataType:"json",
            url:url,
            success:function(data){
                if (data.success){
                    setTimeout(function(){
                    $("#dialog-alert")
                    .dialog("open")
                    .dialog({beforeClose: function(){ setTimeout("window.location='<?php print(base_url()); ?>index.php/mod_contribuyente/inicio_c';", 20); }})
                    .children("#dialog-alert_message")
                    .html(data.message)
                    .dialog("option", {title: "Alerta!!!"});},50);
                }else{
                    setTimeout(function(){
                    $("#dialog-alert")
                    .dialog("open")
                    .dialog({beforeClose: function(){ return false }})
                    .children("#dialog-alert_message")
                    .html(data.message)
                    .dialog("option", {title: "Alerta!!!"});},50);
                }
            },
            error:function(o,estado,excepcion){
                if(excepcion=='Not Found'){
                    
                }else{
                    
                }
            },beforeSend:function(){
            
           
            $('#carga').show();
            bloqueaInputs('#form_restaura_clave',true);
            document.getElementById("btn_restaura_cont").disabled='disabled'}
            ,complete: function(){
            $('#carga').hide();
            bloqueaInputs('#form_restaura_clave',false);
            document.getElementById("btn_restaura_cont").disabled=''}
        
        
    });
        }           
     $("div#dialog-alert").dialog({
        modal: true,
        autoOpen: false,
        hide: "fade",
        stack: true,
        position: ["center","center"]
    });
     $("div#dialog-alert2").dialog({
        modal: true,
        autoOpen: false,
        hide: "fade",
        position: ["center","center"]
    });     
        });
</script>
<div id="dialogo_clave" title="Restauracion de Contraseña"><?php //   print($estatus);?>
    
    <form id="form_restaura_clave">
    <input  type="hidden" name="idusuario" id="idusuario" value="<?php print($datoscontribu[0]['id']); ?>"/>
    <input  type="hidden" name="login" id="login" value="<?php print($datoscontribu[0]['login']); ?>"/>
    <input  type="hidden" name="nombre" id="nombre" value="<?php print($datoscontribu[0]['nombre']); ?>"/>
    <input  type="hidden" name="correo" id="correo" value="<?php print($datoscontribu[0]['email']); ?>"/>
    <label for="usuario"><b>Usuario:</b></label>
        <p><span> <?php print($datoscontribu[0]['nombre']); ?></span></p>
        
    <label for="login"><b>Login:</b></label>
        <p><span><?php print($datoscontribu[0]['login']); ?></span></p>
      
    <label for="psecreta"><b>Pregunta Secreta:</b></label>
        <p><select id="psecreta" name="psecreta" >
            <option value="<?php print($pregunta[0]['id']); ?>"><?php print($pregunta[0]['nombre']); ?></option>
        </select></p>
        
    <label for="rsecreta"><b>Respuesta Secreta:</b></label>
        <p><input  type="password" name="rsecreta" id="rsecreta" class="requerido  ui-widget-content ui-corner-all"  /></p>
    
    <label for="codigo"><b>Código de confirmación:</b></label>
	<div id="captcha_restaura_container" class=" ui-widget-content ui-corner-top" align="center">
            <img id="captcha_restaura" src="<?php print(base_url()); ?>include/librerias/securimage/captcha.php" width="99%" height="100" />
	</div>
        <input id="codigo" type="text" name="codigo" id="codigo" class="requerido ui-widget-content ui-corner-bottom" />
    </form>
    <div class="ui-widget ui-helper-clearfix"></div><br />
    <center>
        <button id="btn_restaura_cont" class="btn">Restaurar Contraseña</button>
        <div style="display:none"id="carga" title="Mensaje">
            Espere procesando envio...
                <img  src="<?php print(base_url()); ?>include/imagenes/ajax-loader.gif" />

        </div>        
    </center>

</div>
<div id="dialog-alert" title="Mensaje">
    <p id="dialog-alert_message"></p>
</div>
