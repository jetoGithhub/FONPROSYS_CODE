<?php

?>
<script>
$(function(){
    
   $("#btnbuscaracta").button({
            icons: {
            primary: "ui-icon-search"
            },
            text: false
            });


});




</script>

<style>
     .buscaracta{
        
        float: left;
        height: 20px
               
    }
    #busca_acta div{
        padding: 5px;
        width: 60%;
        margin-left: 170px;
        margin-top: 10px
            
    }
    #result-busqueda-acta{
        margin-top: 35px
    }
    
    
</style>
<div class="ui-widget-header" style="text-align:center; font-size: 12px; font-style: italic; margin-bottom: 10px; width: 80%; margin-left: 10%">Reportes de Actas Fiscales </div>

  <form id="busca_acta" class=' focus-estilo'>  
      <div class="ui-corner-all ui-widget-content" id='conten-busqueda-acta' >
          <center><table>
              <tr>
                  <td>
                      <label ><b>Tipo de Acta</b></label><br />
                       <select id="tipo_acta" name="tipo_acta" style=' width: 150px' class=' ui-widget-content ui-corner-all'>
                                <option selected='selected' value="">Seleccione</option>
                                <option value="0" >Autorizaciones Fiscales</option>
                                <option value="1" >Actas de Requerimientos</option>
                                <option value="2" >Actas de Recepcion</option>
                                <option value="3" >Actas de Reparo</option>
                                
                       </select> 
                  </td>
                  <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
                  <td>
                      <label ><b>A&ntilde;o</b></label><br />
                       <select id="anio_acta" name="anio_acta" style=' width: 100px' class=' ui-widget-content ui-corner-all'>
                           <option value="" selected >Seleccione</option>
                           <?php
                           for($i=2000;$i<=date('Y');$i++){
                               
                               echo "<option value='$i'>$i</option>";
                           }
                           ?>
                                                                
                       </select> 
                  </td>
                  <td clospan='2'>
                      <label ></label><br />
                      <button class='buscaracta' id='btnbuscaracta' type='button' ></button>&nbsp;&nbsp;&nbsp;<span class="cargando-bactas"></span>
                  </td>
                  
              </tr>
          </table></center>
      </div>
</form>
<div id="result-busqueda-acta"></div>

<script>
$("#btnbuscaracta").click(function(){    

  $.ajax({
           type:"post",
            data:$('#busca_acta').serialize(),
            dataType:"json",
            url:'<?php print(base_url().'index.php/mod_reportes/reporte_actas_fiscalizacion_c/buscar_actas_fiscalizacion_anio'); ?>',
            success:function(data){
              if(data.resultado){
                 
                 $("#result-busqueda-acta").html(data.html);
                 $(".cargando-bactas").empty();
              }
                      
                      
            },
            error: function (request, status, error) {
                
              var html='<p style=" margin-top: 15px">';
                  html+='<span class="ui-icon ui-icon-alert" style="float: left; margin: 0 7px 50px 0;"></span>';
                  html+='Disculpe ocurrio un error de conexion intente de nuevo <br /> <b>ERROR:"'+error+'"</b>';
                  html+='</p><br />';
                  html+='<center><p>';
                  html+='<b>Si el error persiste comuniquese al correo soporte@cnac.gob.ve</b>';
                  html+='</p></center>';
               $("#dialogo-error-conexion").html(html);
               $("#dialogo-error-conexion").dialog('open');
           },
            beforesend:function(){
                $(".cargando-bactas").html('<img src="<?php print(base_url()); ?>include/imagenes/ajax-loader.gif" width="18px" heigth="18px"/>');
            }
            
        });  
    
});



</script>