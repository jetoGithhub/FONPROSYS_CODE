 <script>
    $(function() {
        ayudas('#','form_new','bottom center','top center','slide','up');
        ayudas_input('#','form_new');
        //funcion para la validacion
        //Parametros: id del form, url del controlador, metodo ajax para el submit del boton
        validador('form_new','<?php echo base_url()."index.php/mod_administrador/usuarios_c/insertar_usuario"; ?>','envio_form');
        //funcion para el cambio de estilo de los radiobutton
        $( "#radio" ).buttonset();

    });
    
   //mascara para los numeros telefonicos
   jQuery(function($){
       $.mask.definitions['#'] = '[VEve]';
       $("#telefofc").mask('0999-9999999');
       $("#cedula").mask('#-999999?99');
   });
   
</script>
<style>
    /*color para el boton activado en estatus*/
    #radio .ui-state-active
    {
        background: #BF3A2B;
    }
    

   
</style>
       <form class=" form-style focus-estilo" id="form_new">
            <table border="0" style=" width: 100%">
               <!-- <tr><td>Usuario: </br> 
                        <input  name="login" type="text" id="login" size="20" class="text ui-widget-content ui-corner-all requerido " title="Ingresar Usuario o Login" disabled="disabled"/>
                    </td>
                </tr>-->
                <tr><td>Nombre: </br> 
                        <input name="nombre" type="text" id="nombre"  class="ui-widget-content ui-corner-all requerido" title="Ingresar Nombre"/>
                    </td>
                    <td>Cedula de Indentidad: </br> 
                        <input name="cedula" type="text" id="cedula"  class="ayuda-input ui-widget-content ui-corner-all requerido" title="Ingresar Cedula de identidad" txtayudai="Campo para colocar el documentos de identidad ejemplo V o E indistintamente de mayusculas y minusculas seguidas de un guion " />
                    </td>
                </tr>
               
                <tr><td>Correo electronico: </br> 
                        <input name="email" type="text" id="email" condicion="email:true" class="ayuda-input ui-widget-content ui-corner-all requerido" title="Ingresar Correo electronico" txtayudai="Campo para agregar el correo institucional ejemplo XXXXXXX@cnac.gob.ve, Recuerde que lo que esta antes del arroba se convertira en el usuario para ingreso en el sistema."/>
                    </td>
                    <td>Telefono oficina: </br> 
                        <input name="telefofc" type="text" id="telefofc"  class="ui-widget-content ui-corner-all requerido" title="Ingresar telefono de oficina"/>
                    </td>
                </tr>
                
                
               <!-- <tr><td>
                    <label for="pregunta">Pregunta Secreta</label></br>
                        <select id="pregsecrid" name="pregsecrid" class="requerido  ui-widget-content ui-corner-all" >
                            <option value="">Seleccione su Pregunta</option>
                                <?php
                                    /*if (sizeof($preguntaSecreta)>0):
                                        foreach ($preguntaSecreta as $pregunta):
                                        print("<option value='$pregunta[id]'>$pregunta[nombre]</option>");
                                        endforeach;
                                    endif;*/
                                ?>            
                        </select>
                  </td></tr> 
                
                <tr><td>Respuesta: </br> 
                    <input name="respuesta" type="text" id="respuesta" size="40" class="text ui-widget-content ui-corner-all requerido" title="Ingresar respuesta de seguridad"/>
                    </td>
                </tr> -->
                <tr><td>
                    <label for="departamento">Gerencia</label></br>
                        <select id="departamento" name="departamento" class="requerido  ui-widget-content ui-corner-all" >
                            <option value="">Seleccione el grupo</option>
                                <?php
                                    if (sizeof($departamentos)>0):
                                        foreach ($departamentos as $dep):
                                        print("<option value='$dep[id_dep]'>$dep[nombre]</option>");
                                        endforeach;
                                    endif;
                                ?>            
                        </select>
                  </td>
                <td>
                    <label for="cargo">Cargo</label></br>
                        <select id="cargo" name="cargo" class="requerido  ui-widget-content ui-corner-all" >
                            <option value="">Seleccione el grupo</option>
                                <?php
                                    if (sizeof($cargos)>0):
                                        foreach ($cargos as $car):
                                        print("<option value='$car[id_car]'>$car[nombre]</option>");
                                        endforeach;
                                    endif;
                                ?>            
                        </select>
                  </td>
                </tr>
                                
                <tr><td colspan="2">
                    <label for="pregunta">Grupo</label></br>
                        <select id="grupo" name="grupo" class="requerido  ui-widget-content ui-corner-all" >
                            <option value="">Seleccione el grupo</option>
                                <?php
                                    if (sizeof($comboGrupos)>0):
                                        foreach ($comboGrupos as $grupo):
                                        print("<option value='$grupo[id_rol]'>$grupo[str_rol]</option>");
                                        endforeach;
                                    endif;
                                ?>            
                        </select>
                  </td></tr>
                
                <tr><td>Status: <br />
                        <div id="radio">
                            <input type="radio" id="radio1" name="inactivo" value="t" /><label for="radio1">Inactivo</label>
                            <input type="radio" id="radio2" name="inactivo" value="f" checked="checked"/><label for="radio2">Activo</label>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td>
                        <div id="msj-usuario">

                        </div>
                    </td>
                </tr>
                

            </table>
            </form> 
