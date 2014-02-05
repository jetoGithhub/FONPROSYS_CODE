<?php
//print_r($data);
/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
?>
<script>
$(function(){
   $(".btnbuscar").button({
            icons: {
            primary: "ui-icon-search"
            },
            text: false
            }); 
});

$("#btn-buscarrecau").click(function(){
   $.ajax({
           type:"post",
            data:{anio:$('#anio_recau').val()},
            dataType:"json",
            url:'<?php print(base_url().'index.php/mod_reportes/reportes_recaudacion_c/buscar_reporte_recaudacion'); ?>',
            success:function(data){
              if(data.resultado){
                 $("#resul-busqueda-recau").empty();
                 $("#resul-busqueda-recau").html(data.html);
                 
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
           }
            
        }); 
});
</script>
<style>
      
    .btnbuscar{
        
        float: left;
        height: 20px
               
    }
    
    #rep-principal-rec td{
        height: 25px;
        padding: 2px;
        border-left: 1px solid #EEEEEE;
            
    }  
   #frm-principal-recau div{
        padding: 5px;
        width: 30%;
        margin-left: 250px;
        margin-top: 10px;
        margin-bottom: 10px
            
            
    }
    .montos{
        
        text-align: center;
        
    }
    #meses{
        font-weight: bold;
    }
    
</style>
 <form id="frm-principal-recau" class=' focus-estilo'>  
      <div class="ui-corner-all ui-widget-content" id='conten-busqueda-recau' >
          <center><table>
              <tr>
                  <td>
                      <label ><b>A&ntilde;o a Consultar</b></label><br />
                      <select id="anio_recau" name="anio_recau" style=' width: 100px' class=' ui-widget-content ui-corner-all'>
                           <?php
                           for($i=2000;$i<=date('Y');$i++){
                               
                               echo "<option value='$i' selected >$i</option>";
                           }
                           ?>
                                                                
                       </select> 
                       
                  </td>
                  <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
                 
                  <td clospan='2'>
                      <label ></label><br />
                      <button class='btnbuscar' id='btn-buscarrecau' type='button' ></button>&nbsp;&nbsp;&nbsp;<span class="cargando"></span>
                  </td>
                  
              </tr>
          </table>
          </center>
      </div>
 </form> 
<div id="resul-busqueda-recau">
    
    <?php print($table); ?>
    
</div>
