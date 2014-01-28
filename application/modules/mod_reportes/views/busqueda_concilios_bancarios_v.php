<?php

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
?>
<script>

 $(function(){
        $("#conten-busqueda-simple").hide();
        $("#conten-busqueda-avanzada").hide();
        $( ".radio" ).buttonset();
        $(".btnbuscar-concilio").button({
            icons: {
            primary: "ui-icon-search"
            },
            text: false
            });
            
            $( "#fecha-desde" ).datepicker({
                defaultDate: "+1w",
                dateFormat: 'dd/mm/yy',
                changeMonth: true,
                changeYear: true,
                numberOfMonths:1,
                dayNamesMin: [ "Do", "Lu", "Ma", "Mi", "Ju", "Vi", "Sa" ],
                monthNames: [ "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre" ],
                monthNamesShort: [ "Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sept", "Oct", "Nov", "Dic" ],
                yearRange: "2000:<?php echo date('Y');?>",
                onClose: function( selectedDate ) {
                $( "#fecha-hasta" ).datepicker( "option", "minDate", selectedDate );
                }
        });
        $( "#fecha-hasta" ).datepicker({
                defaultDate: "+1w",
               dateFormat: 'dd/mm/yy',
                changeMonth: true,
                changeYear: true,
                numberOfMonths: 1,
                dayNamesMin: [ "Do", "Lu", "Ma", "Mi", "Ju", "Vi", "Sa" ],
                monthNames: [ "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre" ],
                monthNamesShort: [ "Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sept", "Oct", "Nov", "Dic" ],
                yearRange: "2000:<?php echo date('Y');?>",
                onClose: function( selectedDate ) {
                $( "#fecha-desde" ).datepicker( "option", "maxDate", selectedDate );
                }
        });
 });

</script>
<style>
    #table-busqueda-concilio{
        width: 40%;
        border: 0px solid #000;
        border-collapse: collapse;
    }
    .radio{
        height: 20px;
        font-size: 9px
    }
    .btnbuscar-concilio{
        
        float: left;
        height: 20px
               
    }
    #conten-busqueda-simple{
        padding: 5px;
        width: 80%;
        margin-left:70px;
        margin-top: 10px
            
    }
    #conten-busqueda-avanzada{
           padding: 5px;
           width: 95%;
           margin-left:0px;
           margin-top: 10px

       }
    
</style>
<div class="ui-widget-header" style="text-align:center; font-size: 12px; font-style: italic; margin-bottom: 10px; width: 80%; margin-left: 10%">Reportes de Conciliacion Bancaria </div>
    <center>
        <div><center><p><b>Indique el T&iacute;po de B&uacute;squeda</b></p></center></div>
        <table id="table-busqueda-concilio"  class="form-style">
               <tr>
                   <td>
                        <div class="radio" id="content-busqueda-simple">
                            <input onchange='muestra_contenedor_busqueda(this.value)' type="radio" value='0' id="busqueda-simple" name="busqueda" /><label for="busqueda-simple"><span class=" ui-icon ui-icon-search" style=" float: left" ></span>B&uacute;squeda Simple</label>
                       </div>
                   </td>
                   <td>
                        <div class="radio" id="content-busqueda-avanzada">
                            <input onchange='muestra_contenedor_busqueda(this.value)' type="radio" value='1' id="busqueda-avanzada" name="busqueda" /><label for="busqueda-avanzada"><span class=" ui-icon ui-icon-search" style=" float: left" ></span>B&uacute;squeda Avanzada</label>
                       </div>
                   </td>

               </tr>
       </table>
     </center>

  <form id="busca_concilio" class=' focus-estilo'>  
      <div class="ui-corner-all ui-widget-content" id='conten-busqueda-simple' >
          <center><table>
              <tr>
                  <td>
                      <label ><b>Estado</b></label><br />
                       <select id="tipo_estado" name="tipo_estado" style=' width: 150px' class=' ui-widget-content ui-corner-all'>
                                <option selected='selected' value="0">Todos</option>
                                <option value="1" >Cobradas</option>
                                <option value="2" >Por Cobrar</option>
                                
                       </select> 
                  </td>
                  <td>
                      <label ><b>T&iacute;po de Pago</b></label><br />
                       <select id="tipo_pago" name="tipo_pago" style=' width: 150px' class=' ui-widget-content ui-corner-all'>
                                <option selected='selected' value="0">Autoliquidaciones</option>
                                <option value="4" >Rise</option>
                                <option value="8" >Res. Sumario</option>
                                <option value="5" >Res. Culm fisc</option>
                       </select> 
                  </td>
                  <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
                  <td>
                      <label ><b>A&ntilde;o</b></label><br />
                       <select id="anio_concilio" name="anio_concilio" style=' width: 100px' class=' ui-widget-content ui-corner-all'>
                           <?php
                           for($i=2000;$i<=date('Y');$i++){
                               
                               echo "<option value='$i' selected>$i</option>";
                           }
                           ?>
                                                                
                       </select> 
                  </td>
                  <td clospan='2'>
                      <label ></label><br />
                      <button class='btnbuscar-concilio' id='btn-buscar-simple' type='button' ></button>&nbsp;&nbsp;&nbsp;<span class="cargando-conci"></span>
                  </td>
                  
              </tr>
          </table></center>
      </div>
       
      
      
      
      <div class="ui-corner-all ui-widget-content" id='conten-busqueda-avanzada' >
         <center><table>
              <tr>
                  <td>
                      <label ><b>Indique el Tipo</b></label><br />
                       <select onChange='opciones_busqueda_avanzada(this.value)' id="tipo_filtro" name="tipo_filtro" class=' ui-widget-content ui-corner-all' >
                                <option selected='selected' value="0">Rif</option>
                                <option value="1" >Contribuyentes</option>
                                <option value="2" >Fechas</option>
                                
                       </select> 
                  </td>
                   <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
                  <td>
                      <label ><b>Tipo de pago</b></label><br />
                       <select id="tipo_pago2" name="tipo_pago2" style=' width: 150px' class=' ui-widget-content ui-corner-all'>
                                <option selected='selected' value="0">Autoliquidaciones</option>
                                <option value="4" >Rise</option>
                                <option value="8" >Res. Sumario</option>
                                <option value="5" >Res. Culm fisc</option>
                       </select> 
                  </td>
                  <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
                  <td id="anio-avan">
                      <label ><b>A&ncaron;o</b></label><br />
                       <select id="anio_rise2" name="anio_concilio2" style=' width: 50px' class=' ui-widget-content ui-corner-all'>
                           <?php
                           for($i=2000;$i<=date('Y');$i++){
                               
                               echo "<option value='$i' selected>$i</option>";
                           }
                           ?>
                                                                
                       </select> 
                  </td>
                  <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
                  <td id='td-rif'>
                      <label ><b>Indique el Rif</b></label><br />
                     <input type='text' name='rif' id='rif' class=' ui-widget-content ui-corner-all' placeholder="VJE000000000"> 
                  </td>
                  <td id='td-tipo' style=' display: none'>
                     <label ><b>Tipo de contribuyente</b></label><br />
                       <select id="tipo_contribu" name="tipo_contribu" style=' width: 150px'class=' ui-widget-content ui-corner-all' >                               
                        <option value='' selected >Seleccione</option> 
                        <?php
                            foreach ($tipo_contribu as $key => $value) {
                                echo "<option value='$value[id]'>$value[nombre]</option>";
                            }
                         ?>       
                       </select> 
                  </td>
                  <td class='td-fechas' style=' display: none'>
                      <label ><b>Desde</b></label>
                      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                       <label ><b>Hasta</b></label><br />
                      <input type='text' name='fecha-desde' id='fecha-desde' class=' ui-widget-content ui-corner-all' readonly='readonly' >
                      &nbsp;&nbsp;&nbsp;&nbsp;
                     <input type='text' name='fecha-hasta' id='fecha-hasta' class=' ui-widget-content ui-corner-all' readonly='readonly'>
                  </td>
                 
                  <td clospan='2'>
                      <label ></label><br />
                      <button class='btnbuscar-concilio' type='button' id='btn-buscar-avanzada' ></button>&nbsp;&nbsp;&nbsp;<span class="cargando-conci"></span>
                  </td>
              </tr>
          </table></center>  
      </div>


     
</form>
<div id="respuesta_consulta_concilio" style=' margin-top: 20px'></div>
<script>
muestra_contenedor_busqueda=function(valor){
//    alert(valor)
    switch(valor){
    case '0':
        $("#conten-busqueda-simple").show('blind',{direction:'up'});
        $("#conten-busqueda-avanzada").hide();
        break;
        case '1':
            $("#conten-busqueda-simple").hide();
            $("#conten-busqueda-avanzada").show('blind',{direction:'up'});
             break;
    }
};    
    opciones_busqueda_avanzada=function(valor){
//    alert(valor)
    switch(valor){
        case '0':
            $('#td-rif').css('display','block');
            $('.td-fechas').css('display','none');
            $('#td-tipo').css('display','none');
            $('#anio-avan').css('display','block');
            break;
        case '1':
            $('#td-rif').css('display','none');
            $('.td-fechas').css('display','none');
            $('#td-tipo').css('display','block');
            $('#anio-avan').css('display','block');
                   
            break;
        case '2':
            $('#td-rif').css('display','none');
            $('.td-fechas').css('display','block');
            $('#td-tipo').css('display','none');
            $('#anio-avan').css('display','none');
//            $("#conten-busqueda-avanzada").css('width','5000');
            break;    
    }
    
};
$(".btnbuscar-concilio").click(function(){
    $(".cargando-conci").html('<img src="<?php print(base_url()); ?>include/imagenes/ajax-loader.gif" width="18px" heigth="18px"/>');
    var tipo;
    $("#table-busqueda-concilio input[type=radio]").each(function(i) { 
        if($(this).is(':checked')){
             tipo=$(this).val();
       }

    });   
    $.ajax({
           type:"post",
            data:$('#busca_concilio').serialize(),
            dataType:"json",
            url:'<?php print(base_url().'index.php/mod_reportes/reportes_concilios_bancarios_c/reporte_conciliaciones/'); ?>'+tipo,
            success:function(data){
              if(data.resultado){
                 
                 $("#respuesta_consulta_concilio").html(data.html);
                 $(".cargando-conci").empty();
              }
                      
                      
            },
            error:function(o,estado,excepcion){
                if(excepcion=='Not Found'){

                }else{

                }
            }
            
        });
});    
    
</script>