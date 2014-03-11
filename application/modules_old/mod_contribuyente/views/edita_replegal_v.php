
<script>
       $(function() {
         validador('edita_registro_replegal','<?php echo base_url()."index.php/mod_contribuyente/contribuyente_c/registro_replegal"; ?>','edita_representante');    
        
     
        edita_representante = function(form,url){
//            alert($('#'+form).serialize())
            $.ajax({
            type:"post",
            data:$('#'+form).serialize(),
            dataType:"json",
            url:url,
            success:function(data){
            
            if (data.resultado){
             $("#frmreplegal").dialog( "close" );  
             var tabId=$('#tabs').tabs('option', 'selected')
             $("#tabs").tabs("load",tabId);

            }
//            else{
//                
//                $("#dialog-alert")
//                .dialog("open")
//                .children("#dialog-alert_message")
//                .html(data.mensaje);
//            }
            },
            error:function(o,estado,excepcion){
                if(excepcion=='Not Found'){
                }else{
                    
                }
            }});
        } 
        busca_ciudad = function(id,url){
         $("#muestra_ciudad2").load(url);
        } 
 

         
    
});
    jQuery(function($){
//        $.mask.definitions['#'] = '[JVGEjvge]';
//        $("#nrif").mask("#999999999");
        $("#telefono_hab").mask('0999-9999999');
        $("#telefono_ofi").mask('0999-9999999');
        $("#telefono3").mask('0999-9999999');
        $("#fax_rep").mask('0999-9999999');
        $("#fax2").mask('0999-9999999');
        

    });

    
</script>     
 <form id="edita_registro_replegal" style=" width: 20px" class=" focus-estilo">

 <input value="<?php echo $info[0]['id_replegal']; ?>" type="hidden"   name="id_replegal" id="id_replegal" />
 <input value="update" type="hidden"   name="tipo_operacion" id=" tipo_operacion" />
    <table border="0" >
            <tr>
                <td colspan="">
                <label ><strong>Cedula de identidad:</strong></label><br /> 
                <input  value='<?php echo $info[0]['cedula']; ?>' type="text" size="25" style=" height: 20px; " class=" ui-state-highlight ui-corner-all requerido" name="ci" id="ci" />
                </td>
                <td colspan="">
                <label><strong>Nombre:</strong></label><br />
                <input value='<?php echo $info[0]['nombre']; ?>' type="text" size="25" style=" height: 20px; " class=" ui-state-highlight ui-corner-all requerido" name="nombre" id="nombre" />
                </td>
                <td colspan="">
                <label><strong>Apellido:</strong></label><br />
                <input value='<?php echo $info[0]['apellido']; ?>' type="text" size="25" style=" height: 20px; " class=" ui-state-highlight ui-corner-all requerido" name="apellido" id="apellido" />
                </td>
            </tr>
              <tr>
                <td colspan="3">
                    <label><strong>Domicilio Fiscal:</strong></label><br />
                    <textarea type="text" name="dfiscal" class=" ui-state-highlight ui-corner-all requerido" style=" width: 100%; "id="dfiscal"><?php echo $info[0]['domicilio']; ?></textarea>
                </td>
                
            </tr>       
        
            <tr>
                <td>
                    <label ><strong>Estado o Entidad Federal:</strong></label><br />
     
                    <select id="estado" name="estado" class="requerido ui-state-highlight ui-corner-all" onchange="busca_ciudad('muestra_ciudad','<?php print(base_url().'index.php/mod_contribuyente/contribuyente_c/ciudades/');?>'+this.value)">
                        <option  value="">Seleccione un Estado</option>
                            <?php
                            if (sizeof($estados)>0):
                                $selecciona='';
                                foreach ($estados as $estado):
                                
                                if($estado['id']==$info[0]['estadoid']){ 
                                    $selecciona='selected';
                                    
                                    } else{ 
                                        $selecciona='';
                                        
                                        }
                                print("<option $selecciona id='estado".$estado['id']."'value='".$estado['id']."'>".$estado['nombre']."</option>");
                                endforeach;
                            endif;

                            ?>
                      </select>

                   
                      
                </td>               
                <td colspan="">
                    <label ><strong>Municipio donde reside:</strong></label><br />
                    <div id="muestra_ciudad2">                       
                    <select id="ciudad" name="ciudad" class="requerido ui-state-highlight ui-corner-all"   >
                       <option selected value="<?php echo $info[0]['ciudadid']?>"><?php echo $info[0]['ciudad']; ?></option>
                        
                        
                    </select>                                          
                    </div>
                </td>
 
                <td>
                    <label><strong>zona postal:</strong></label><br /> 
                    <input value='<?php echo $info[0]['zona']; ?>' type="text"   name="zpostal" id="zpostal" size="25" style=" height: 20px; " class=" ui-state-highlight ui-corner-all " />
                </td>    
            </tr>
            <tr>
                <td>
                     <label ><strong>Telefono de hab:</strong></label><br />
                    <input  value='<?php echo $info[0]['thab']; ?>' type="text" size="25" style=" height: 20px; " class=" ui-state-highlight ui-corner-all " name="telefono1" id="telefono_hab"  />
                </td>
                <td>
                   <label ><strong>Telefono de oficina:</strong></label><br />
                    <input  value='<?php echo $info[0]['tofi']; ?>' type="text" size="25" style=" height: 20px; " class=" ui-state-highlight ui-corner-all requerido" name="telefono2" id="telefono_ofi" />
                </td>            
                <td>
                     <label ><strong>Fax:</strong></label><br />
                    <input  value='<?php echo $info[0]['fax']; ?>' type="text" size="25" style=" height: 20px; " class=" ui-state-highlight ui-corner-all " name="fax1" id="fax_rep" />
                 </td>   
            </tr>
            <tr>
                
                  <td>
                     <label ><strong>Email:</strong></label><br />
                     <input  value='<?php echo $info[0]['email']; ?>' type="text" size="25" style=" height: 20px; " class=" ui-state-highlight ui-corner-all requerido" name="email" id="email" condicion=" email:true "/>
                 </td> 
                 <td>
                   <label ><strong>PINBB:</strong></label><br />
                    <input value='<?php echo $info[0]['pinbb']; ?>' type="text" maxlength="8" size="25" style=" height: 20px; " class=" ui-state-highlight ui-corner-all " name="pinbb" size="10px" id="pinbb" />
                </td>
                <td>
                     <label ><strong>Skype:</strong></label><br />
                    <input value='<?php echo $info[0]['skype']; ?>' type="text" size="25" style=" height: 20px; " class=" ui-state-highlight ui-corner-all " name="skype" id="skype" />
                </td>
            
            </tr>
             
          </table> 


    </form>
