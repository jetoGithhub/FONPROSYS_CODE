 <script>
    $(function() {
        //funcion para la validacion
        //Parametros: id del form, url del controlador, metodo ajax para el submit del boton
        validador('form_new','<?php echo base_url()."index.php/mod_gestioncontribuyente/envio_correos_c/proc_enviar_correo"; ?>','envio_form');
        //funcion para el cambio de estilo de los radiobutton
        $('#espere_enviadoc').hide();
	});
	
	                 
		 /*
				probar textareas editables
*/
/*
				tinyMCE.init({
					// General options
					mode : "textareas",
					theme : "advanced",
					plugins : "safari,pagebreak,style,layer,table,save,advhr,advimage,advlink,emotions,iespell,inlinepopups,insertdatetime,preview,searchreplace,print,contextmenu,paste,directionality,fullscreen,noneditable,visualchars,nonbreaking,xhtmlxtras,template",

					// Theme options
					theme_advanced_buttons1 : "bold,italic,underline,|,justifyleft,justifycenter,justifyright,justifyfull,bullist,numlist,fontselect,fontsizeselect,formatselect",
					theme_advanced_buttons2 : "outdent,indent,|,link,unlink,image,|,forecolor,backcolor",		
					
					theme_advanced_toolbar_location : "top",
					theme_advanced_toolbar_align : "left",

					// Replace values for the template plugin
					template_replace_values : {
						username : "Some User",
						staffid : "991234"
					}
				});
*/
                 
</script>
<style>
    /*color para el boton activado en estatus*/
    #radio .ui-state-active
    {
        background: #BF3A2B;
    }
</style>
       <form class="form-style focus-estilo" id="form_new">
           <input name="rif" type="hidden" id="rif" value="<?php echo $infoplanilla['rif'] ?>" />
           <input name="procesado" type="hidden" id="procesado" value="false" />
            <table border="0">

                <tr><td>Correo electronico: </br> 
                        <input name="email_enviar" value="<?php echo  $infoplanilla['email']; ?>" type="text" id="email_enviar" size="40" class="text ui-widget-content ui-corner-all requerido" title="Correo electronico"/>
                    </td>
                </tr>
                
                <tr><td>Asunto: </br> 
                        <input name="asunto_enviar" type="text" id="asunto_enviar" size="40" class="text ui-widget-content ui-corner-all requerido" title="Ingrese Asunto"/>
                    </td>
                </tr>
                
                 <tr><td>Contenido: </br> 
                        <textarea name="contenido_enviar" rows="10" cols="30" type="text" id="contenido_enviar" class="requerido" title="Ingrese contenido del email"></textarea>
					</td>
                </tr>

                <br />
                

            </table>
           <div id='espere_enviadoc' class=' espere'>Espere procesando envio...<img  src="<?php print(base_url()); ?>include/imagenes/ajax-loader.gif" /></div>
       </form> 
