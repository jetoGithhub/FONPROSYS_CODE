<?php

?>
<script>
$(function(){
    
   $("#btnestdcuenta").button({
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
    #busca_stdcuenta div{
        padding: 5px;
        width: 60%;
        margin-left: 170px;
        margin-top: 10px
            
    }
    #result-stdcuenta{
        margin-top: 35px
    }
    
    
</style>
<div class="ui-widget-header" style="text-align:center; font-size: 12px; font-style: italic; margin-bottom: 10px; width: 80%; margin-left: 10%">Estado de Cuenta Contribuyentes FONPROCINE</div>

  <form id="busca_stdcuenta" class=' focus-estilo '>  
      <div class="ui-corner-all ui-widget-content" id='conten-busqueda-acta' >
          <center>
        <table id="tbl-content-bus">
              <tr>
                  <td>
                      <label ><b>Buscar por:</b></label><br />
                       <select id="busqueda" name="busqueda" style=' width: 150px' class=' ui-widget-content ui-corner-all' onchange="muestra_busqueda(this.value)">
                                <!--<option selected='selected' value="">Seleccione</option>-->
                                <option selected='selected' value="0" >Tipo de contribuyente</option>
                                <option value="1" >A&ntilde;o Fiscal</option>
                                <!--<option value="2" >Tipo de pago</option>-->
                                
                                
                       </select> 
                  </td>
                  <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
<!--                  <td id="tcontribu">
                      <label ><b>Tipo de Contribuyente</b></label><br />
                       <select id="anio_acta" name="anio_acta" style=' width: 150px' class=' ui-widget-content ui-corner-all'>
                           <option value="" selected >Seleccione</option>
                           <?php
//                           foreach ($tipocont as $key => $value) {
//                               
//                               echo "<option value='$value[tipocontid]'>$value[tipo_contribu]</option>";
//                           }
                           ?>
                                                                
                       </select> 
                  </td>-->
                  
                  <!--<td>&nbsp;&nbsp;&nbsp;&nbsp;</td>-->
                  <td>
                    <div id="tcontribu" style=" margin-left: 0px; margin-top: 0px; width: 160px">
                      <label ><b>Tipo de Contribuyente:</b></label><br />
                       <select id="tipocont" name="tipocont" style=' width: 150px' class=' ui-widget-content ui-corner-all requerido'>
                           <option value="" selected >Seleccione</option>
                           <?php
                           foreach ($tipocont as $key => $value) {
                               
                               echo "<option value='$value[tipocontid]'>$value[tipo_contribu]</option>";
                           }
                           ?>
                                                                
                       </select> 
                  </div>   
                   <div id="afiscal" style=" display: none; margin-left: 0px;margin-top: 0px; width: 160px">   
                      <label ><b>A&ntilde;o Fiscal:</b></label><br />
                       <select id="anio_acta" name="anio_acta" style=' width: 150px' class=' ui-widget-content ui-corner-all requerido'>
                           <option value="" selected >Seleccione</option>
                           <?php
                           for($i=2000;$i<=date('Y');$i++){
                               
                               echo "<option value='$i'>$i</option>";
                           }
                           ?>
                                                                
                       </select> 
                   </div>   
                  </td>                  
                  <!--<td>&nbsp;&nbsp;&nbsp;&nbsp;</td>-->
                  <td style="" id="tpago">
                      <label ><b>Tipo de Pago</b></label><br />
                       <select id="tpago" name="tpago" style=' width: 150px' class=' ui-widget-content ui-corner-all requerido'>
                           <option value="" selected >Seleccione</option>
                           <option value="0"  >Autoliquidacion</option>
                           <option value="1"  >Multas</option>
                           <!--<option value="2"  >Intereses</option>-->
                           <option value="3" >Reparos</option>                          
                                                                
                       </select> 
                  </td>
                  <td clospan='2'>
                      <br />
                      <button class='buscaracta' id='btnestdcuenta' type='button' ></button>&nbsp;&nbsp;&nbsp;<span class="cargando-bactas"></span>
                  </td>
                  
              </tr>
          </table></center>
      </div>
</form>
<div id="result-stdcuenta"></div>

<script>
    
muestra_busqueda=function(opc){
//   alert(opc)
   if(opc==0){
       
       $('#tcontribu').css('display','block');
       $('#afiscal').css('display','none');
//       $('#tpago').css('display','none');
   }
   if(opc==1){
       
       $('#tcontribu').css('display','none');
       $('#afiscal').css('display','block');
//       $('#tpago').css('display','none');
   }
   if(opc==2){
       
       $('#tcontribu').css('display','none');
       $('#afiscal').css('display','none');
//       $('#tpago').css('display','block');
   }
};    
    
$("#btnestdcuenta").click(function(){    

  $.ajax({
           type:"post",
            data:$('#busca_stdcuenta').serialize(),
            dataType:"json",
            url:'<?php print(base_url().'index.php/mod_reportesContribuyente/estado_cuenta_c/busca_info_estado_cuenta'); ?>',
            success:function(data){
              if(data.resultado){
                 
                 $("#result-stdcuenta").html(data.html);
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
