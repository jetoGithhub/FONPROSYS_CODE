<?php

?>
<script>
    $(function(){
        $("#conten-busqueda-simple").hide();
        $("#conten-busqueda-avanzada").hide();
        $( ".radio" ).buttonset();
        $(".btnbuscar-rise").button({
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
//                changeMonth: true,
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
    #table-busqueda-rise{
        width: 40%;
        border: 0px solid #000;
        border-collapse: collapse;
    }
    .radio{
        height: 20px;
        font-size: 9px
    }
    .btnbuscar-rise{
        
        float: left;
        height: 20px
               
    }
    #busca_rise div{
        padding: 5px;
        width: 550px;
        margin-left: 11%;
        margin-top: 10px
            
    }
</style>
<div class="ui-widget-header" style="text-align:center; font-size: 12px; font-style: italic; margin-bottom: 10px; width: 80%; margin-left: 10%">Reportes de Resoluciòn de Multas por Extemporaneida (RISE) </div>
    <center>
        <div><center><p><b>Indique el tipo de busquedad</b></p></center></div>
        <table id="table-busqueda-rise"  class="form-style">
               <tr>
                   <td>
                        <div class="radio" id="content-busqueda-simple">
                            <input onchange='muestra_contenedor_busqueda(this.value)' type="radio" value='0' id="busqueda-simple" name="busqueda" /><label for="busqueda-simple"><span class=" ui-icon ui-icon-search" style=" float: left" ></span>Busqueda Simple</label>
                       </div>
                   </td>
                   <td>
                        <div class="radio" id="content-busqueda-avanzada">
                            <input onchange='muestra_contenedor_busqueda(this.value)' type="radio" value='1' id="busqueda-avanzada" name="busqueda" /><label for="busqueda-avanzada"><span class=" ui-icon ui-icon-search" style=" float: left" ></span>Busqueda Avanzada</label>
                       </div>
                   </td>

               </tr>
       </table>
     </center>
  <form id="busca_rise" class=' focus-estilo'>  
      <div class="ui-corner-all ui-widget-content" id='conten-busqueda-simple' >
          <center><table>
              <tr>
                  <td>
                      <label ><b>Estado de la RISE</b></label><br />
                       <select id="tipo_rise" name="tipo_rise" style=' width: 150px' class=' ui-widget-content ui-corner-all'>
                                <option selected='selected' value="0">Todos</option>
                                <option value="1" >Notificados</option>
                                <option value="2" >Por Notificar</option>
                                <option value="3" >Canceladas</option>
                                
                       </select> 
                  </td>
                  <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
                  <td>
                      <label ><b>A&ncaron;o</b></label><br />
                       <select id="anio_rise" name="anio_rise" style=' width: 100px' class=' ui-widget-content ui-corner-all'>
                           <?php
                           for($i=2000;$i<=date('Y');$i++){
                               
                               echo "<option value='$i' selected>$i</option>";
                           }
                           ?>
                                                                
                       </select> 
                  </td>
                  <td clospan='2'>
                      <label ></label><br />
                      <button class='btnbuscar-rise' ></button>
                  </td>
              </tr>
          </table></center>
      </div>
       <div class="ui-corner-all ui-widget-content" id='conten-busqueda-avanzada' >
         <center><table>
              <tr>
                  <td>
                      <label ><b>Indique el Tipo</b></label><br />
                       <select onChange='opciones_busqueda_avanzada(this.value)' id="tipo_rise" name="tipo_rise" class=' ui-widget-content ui-corner-all' >
                                <option selected='selected' value="0">Rif</option>
                                <option value="1" >Contribuyentes</option>
                                <option value="2" >Fechas</option>
                                
                       </select> 
                  </td>
                  
                  <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
                  <td>
                      <label ><b>A&ncaron;o</b></label><br />
                       <select id="anio_rise2" name="anio_rise2" style=' width: 50px' class=' ui-widget-content ui-corner-all'>
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
                     <input type='text' name='rif' id='rif' class=' ui-widget-content ui-corner-all'> 
                  </td>
                  <td id='td-tipo' style=' display: none'>
                     <label ><b>Tipo de contribuyente</b></label><br />
                       <select id="tipo_rise" name="tipo_rise" style=' width: 150px'class=' ui-widget-content ui-corner-all' >                               
                                
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
                      <button class='btnbuscar-rise' type='button' ></button>
                  </td>
              </tr>
          </table></center>  
      </div>


     
</form>
<div class="bavanz-respuesta"id="respuesta_consulta<?php // print($diferenciador_funciones); ?>"></div>
<div style="float:left;" id="revisa_asigna_omisos_fiscalizacion"></div>

<script>
opciones_busqueda_avanzada=function(valor){
//    alert(valor)
    switch(valor){
        case '0':
            $('#td-rif').css('display','block');
            $('.td-fechas').css('display','none');
            $('#td-tipo').css('display','none');
            break;
        case '1':
            $('#td-rif').css('display','none');
            $('.td-fechas').css('display','none');
            $('#td-tipo').css('display','block');
                   
            break;
        case '2':
            $('#td-rif').css('display','none');
            $('.td-fechas').css('display','block');
            $('#td-tipo').css('display','none');
            break;    
    }
    
};
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





</script>