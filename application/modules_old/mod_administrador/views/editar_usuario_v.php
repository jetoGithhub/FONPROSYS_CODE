 <script>
    $(function() {
        //funcion para la validacion
        //Parametros: id del form, url del controlador, metodo ajax para el submit del boton
        validador('form_editusu','<?php echo base_url()."index.php/mod_administrador/usuarios_c/editar_usuario"; ?>','envio_form');
        //funcion para el cambio de estilo de los radiobutton
        $( "#radioedi" ).buttonset();
    });
    
     jQuery(function($){
       $("#telefofc").mask('0999-9999999');
   });
   
</script>
<style>
    /*color para el boton activado en estatus*/
    #radio .ui-state-active
    {
        background: #BF3A2B;
    }
</style>
       <form class="form-style focus-estilo" id="form_editusu">
           <input name="id" type="hidden" id="id" value="<?php echo $infousuario['id'] ?>" />
            <table border="0">
<!--                <tr><td> Usuario: </br> 
                        <input name="login" type="text" id="login" size="20" class="text ui-widget-content ui-corner-all requerido" title="Ingresar Usuario o Login" value="<?php echo  $infousuario['login']; ?>" disabled="disabled"/>
                    </td>
                </tr>
                <tr><td>Nombre: </br> 
                        <input name="nombre" type="text" id="nombre" size="40" class="text ui-widget-content ui-corner-all requerido" title="Ingresar Nombre" value="<?php echo  $infousuario['nombre']; ?>" disabled="disabled"/>
                    </td>
                </tr>
                <tr><td>Cedula de Indentidad: </br> 
                        <input name="cedula" type="text" id="cedula" size="40" class="text ui-widget-content ui-corner-all requerido" title="Ingresar Cedula de identidad" value="<?php echo  $infousuario['cedula']; ?>" disabled="disabled"/>
                    </td>
                </tr>
                <tr><td>Correo electronico: </br> 
                        <input name="email" type="text" id="email" size="40" class="text ui-widget-content ui-corner-all requerido" title="Ingresar Correo electronico" value="<?php echo  $infousuario['email']; ?>" disabled="disabled"/>
                    </td>
                </tr>
                <tr><td>Telefono oficina: </br> 
                        <input name="telefofc" type="text" id="telefofc" size="40" class="text ui-widget-content ui-corner-all requerido" title="Ingresar telefono de oficina" value="<?php echo  $infousuario['telefofc']; ?>" disabled="disabled"/>
                    </td>
                </tr>
                
                <tr><td>
                    <label for="pregunta">Pregunta Secreta</label></br>
                        <select id="pregsecrid" name="pregsecrid" class="requerido  ui-widget-content ui-corner-all" style="width:250px" disabled="disabled">
                            <option value=""><?php echo  $infousuario['nompreg']; ?></option> 
                                
                        </select>
                  </td></tr>
                
                
                <tr><td>Respuesta: </br> 
                    <input name="respuesta" type="text" id="respuesta" size="40" class="text ui-widget-content ui-corner-all requerido" title="Ingresar respuesta de seguridad" value="<?php echo  $infousuario['respuesta']; ?>" disabled="disabled"/>
                    </td>
                </tr> 
                
                <tr><td>
                    <label for="pregunta">Grupo</label></br>
                        <select id="grupo" name="grupo" class="requerido  ui-widget-content ui-corner-all" style="width:250px">
                            <option value=""><?php //echo  $infousuario['str_rol']; ?></option> 
                            <?php
                                    if (sizeof($comboGrupos)>0):
                                        foreach ($comboGrupos as $grupo):?>
                                       <option value='<?php echo $grupo["id_rol"]?>' <?if ($grupo["str_rol"]==$infousuario["str_rol"]){?> selected <? } ?> ><?php echo $grupo["str_rol"]?></option>
                                       <? endforeach;
                                    endif;
                                ?>      
                        </select>
                  </td></tr>
                
                <tr><td>Status: </br>                        
                        <div id="radio"> 
                            <input type="radio" id="radio1" name="inactivo" value="t" <?php if ($infousuario['inactivo']=='t') { ?> checked="checked" <?php } ?> />
                            <label for="radio1">Inactivo</label>
                            <input type="radio" id="radio2" name="inactivo" value="f" <?php if ($infousuario['inactivo']=='f') { ?> checked="checked" <?php } ?> />
                            <label for="radio2">Activo</label>
                        </div>
                    </td>
                </tr>-->
                
                <tr><td><b>Usuario:</b></br></br> </td><td><?php echo  $infousuario['login']; ?> </br></br></td></tr>
                
                <tr><td><b>Nombre:</b></br></br> </td><td><?php echo  $infousuario['nombre']; ?></br></br></td></tr>
                
                <tr><td><b>Cedula de Indentidad:</b> </br></br></td><td><?php echo  $infousuario['cedula']; ?></br></br></td></tr>
                
<!--                <tr><td><b>Correo electronico:</b> </br></br></td><td><?php // echo  $infousuario['email']; ?></br></br></td></tr>
                
                <tr><td><b>Telefono oficina:</b> </br></br></td><td> <?php // echo  $infousuario['telefofc']; ?></br></br></td></tr>
                
                <tr><td><b>Pregunta Secreta:</b> </br></br></td><td><?php // echo  $infousuario['nompreg']; ?></br></br></td></tr>
                
                
                <tr><td><b>Respuesta:</b> </br></br></td><td><?php // echo  $infousuario['respuesta']; ?></b></br></br></td></tr> -->
                
               <tr><td><b>Grupo:</b></br></br></td><td><?php echo $infousuario['str_rol']; ?></br></br></td></tr>
                
                <tr><td><b>Status: </b></td><td>                       
                        <?php if ($infousuario['inactivo']=='t') { echo "Inactivo"; } else { echo "Activo"; }  ?>
                  </td>
                </tr>
                
                <tr><td colspan="2"><b>_________________________________________</b></td></tr>
                
                <tr><td colspan="2"><b>Cambiar Grupo</b></td></tr>
                <tr><td colspan="2">
                    <label for="pregunta"></label>
                        <select id="grupo" name="grupo" class="requerido  ui-widget-content ui-corner-all" >
                            <option value="">Seleccione</option> 
                            <?php
                                    if (sizeof($comboGrupos)>0):
                                        foreach ($comboGrupos as $grupo):?>
                                       <option value='<?php echo $grupo["id_rol"]?>' <?if ($grupo["str_rol"]==$infousuario["str_rol"]){?> selected <? } ?> ><?php echo $grupo["str_rol"]?></option>
                                       <? endforeach;
                                    endif;
                                ?>      
                        </select>
                  </td></tr>
                
                <tr><td colspan="2"><b>_________________________________________</b></td></tr>
               
                <tr><td colspan="2"><b>Cambiar Status:</td></tr>
                <tr><td colspan="2">
                        <div id="radioedi"> 
                            <input type="radio" id="radio3" name="inactivo" value="f" <?php if ($infousuario['inactivo']=='f') { ?> checked="checked" <?php } ?> />
                            <label for="radio3">Activar</label>
                            <input type="radio" id="radio4" name="inactivo" value="t" <?php if ($infousuario['inactivo']=='t') { ?> checked="checked" <?php } ?> />
                            <label for="radio4">Desactivar</label>
                            
                        </div>
                    </td>
                </tr>
                </br>
                

            </table>
            </form> 