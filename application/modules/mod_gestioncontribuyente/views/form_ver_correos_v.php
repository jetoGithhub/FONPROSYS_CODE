 <script>
    $(function() {
        //funcion para la validacion
        //Parametros: id del form, url del controlador, metodo ajax para el submit del boton
        validador('form_procesar_ver','<?php echo base_url()."index.php/mod_gestioncontribuyente/envio_correos_c/proc_ver_correo"; ?>','procesar_form');
        //funcion para el cambio de estilo de los radiobutton
	});
	
</script>
<style>
    /*color para el boton activado en estatus*/
    #radio .ui-state-active
    {
        background: #BF3A2B;
    }
</style>
       <form id="form_procesar_ver">
           <input name="id" type="hidden" id="id" value="<?php echo $infoplanilla['id'] ?>" />
           <input name="procesado" type="hidden" id="procesado" value="true" />
            <table border="0">
				
				<tr><td><strong>Fecha y Hora:</strong> </br> 
                        <?php echo  $infoplanilla['fecha_envio']; ?></br></br>
                    </td>
                </tr>  

                <tr><td><strong>Correo electronico: </strong></br> 
                        <?php echo  $infoplanilla['email_enviar']; ?></br></br>
                    </td>
                </tr>
                
                <tr><td><strong>Asunto:</strong> </br> 
                        <?php echo  $infoplanilla['asunto_enviar']; ?>
                    </td>
                </tr>
                
                <tr><td><strong>Contenido: </strong></br> 
						<?php echo  $infoplanilla['contenido_enviar']; ?>
                     </td>
                </tr>

                </br>
                

            </table>
      </form> 

