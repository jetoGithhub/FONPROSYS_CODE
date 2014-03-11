<script type="text/javascript" charset="utf-8">
//funcion para el cambio de estilo de los radiobutton
        $( "#radio" ).buttonset(); 
</script>
<style>
    /*color para el boton activado en estatus*/
    #radio .ui-state-active
    {
        background: #BF3A2B;
    }
</style>
       <form id="form_new">
            <table border="0">
                <tr><td><b>Usuario:</b></br></br> </td><td><?php echo  $infousuario['login']; ?> </br></br></td></tr>
                
                <tr><td><b>Nombre:</b></br></br> </td><td><?php echo  $infousuario['nombre']; ?></br></br></td></tr>
                
                <tr><td><b>Cedula de Indentidad:</b> </br></br></td><td><?php echo  $infousuario['cedula']; ?></br></br></td></tr>
                
<!--                <tr><td><b>Correo electronico:</b> </br></br></td><td><?php echo  $infousuario['email']; ?></br></br></td></tr>
                
                <tr><td><b>Telefono oficina:</b> </br></br></td><td> <?php echo  $infousuario['telefofc']; ?></br></br></td></tr>
                
                <tr><td><b>Pregunta Secreta:</b> </br></br></td><td><?php echo  $infousuario['nompreg']; ?></br></br></td></tr>
                
                
                <tr><td><b>Respuesta:</b> </br></br></td><td><?php echo  $infousuario['respuesta']; ?></b></br></br></td></tr> -->
                
               <tr><td><b>Grupo:</b></br></br></td><td><?php echo $infousuario['str_rol']; ?></br></br></td></tr>
                
                <tr><td><b>Status: </b></td><td>                       
                        <?php if ($infousuario['inactivo']=='t') { echo "Inactivo"; } else { echo "Activo"; }  ?>
                  </td>
                </tr>
                
                <tr><td colspan="2"><b>_________________________________________</b></td></tr>
               
                <tr><td colspan="2"><b>Cambiar Status:</td></tr>
                <tr><td colspan="2">
                        <div id="radio"> 
                            <input type="radio" id="radio2" name="inactivo" value="f" <?php if ($infousuario['inactivo']=='f') { ?> checked="checked" <?php } ?> />
                            <label for="radio2">Activar</label>
                            <input type="radio" id="radio1" name="inactivo" value="t" <?php if ($infousuario['inactivo']=='t') { ?> checked="checked" <?php } ?> />
                            <label for="radio1">Desactivar</label>
                            
                        </div>
                    </td>
                </tr>
               
                
                
                </br>
                

            </table>
            </form> 