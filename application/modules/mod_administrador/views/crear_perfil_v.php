 <script>
    $(function() {
        //funcion para la validacion
        //Parametros: id del form, url del controlador, metodo ajax para el submit del boton
        validador('form_perfil','<?php echo base_url()."index.php/mod_administrador/roles_c/insertar_perfil"; ?>','envio_form');
        //funcion para el cambio de estilo de los radiobutton
      

    });
    

   
</script>

       <form class="form-style focus-estilo" id="form_perfil">
            <table border="0">
                <tr><td>Nombre del perfil: </br> 
                        <input name="nomperfil" type="text" id="nomperfil" size="40" class="text ui-widget-content ui-corner-all requerido" title=""/>
                    </td>
                </tr>
                <tr><td>Descripcion: </br> 
                        <textarea name="descripcion" id="descripcion"  class="text ui-widget-content ui-corner-all requerido" ></textarea>
                    </td>
                </tr>
              
                

            </table>
        </form> 