<?php //  print_r($pre_datos); ?>
<form id="form_pre_envio_guarda">
    <input type="hidden" id="modo0" name="modo" value="0" />
    <div id="muestra_pre_envia">
    <?php  foreach ($pre_datos as $clave=>$valor): ?>
        
                <h3>  
                    <?php  print($valor['datos_usuario'][0]['nombre']); ?>
                    <?php //  print($valor['datos_usuario'][0]['email']); ?>
                <input type="hidden" id="modo0" name="id[]" value="<?php print($valor['datos_usuario'][0]['id'].":".$valor['extemporaneos'][0]['tipocontribuid']); ?>" />
                </h3>
                <div>
                    <b>Tipo Contribuyente:</b><?php print($valor['nombre_tipocont']); ?><br/>
                    
                    <b>Email:</b><?php print($valor['datos_usuario'][0]['email']); ?>
            <table class="pre_detalle_recaudacion" cellpadding="0" cellspacing="0" border="0"  width="100%">
                <thead>
                    <tr>
                        <th>Nro Planilla</th>
                        <th>Fecha Elaboracion</th>
                        <th>Fecha Inicio</th>
                        <th>Fecha Fin</th>
                        <th>Base Imponible</th>
                        <th>Alicuota</th>
                        <th>Total a Pagar</th>

                    </tr>
                </thead>
                <tbody>            

                    <?php foreach ($valor['extemporaneos'] as  $periodos): ?>                         
                        <tr>
                            <td>
                                <input type="hidden"  name="id_cambia_declara[]" value="<?php print($periodos['id'].":".$periodos['conusuid'].":".$periodos['tipocontribuid']); ?>" />
                                <?php print($periodos['calpagodid']); ?>
                            </td>
                            <td>
                                <?php print($periodos['fechaelab']); ?>
                            </td>
                            <td>
                                <?php print($periodos['fechaini']); ?>
                            </td>
                            <td>
                                <?php print($periodos['fechafin']); ?>
                            </td>
                            <td>
                                <?php print($periodos['baseimpo']); ?>
                            </td>
                            <td>
                                <?php print($periodos['alicuota']); ?>
                            </td>   
                            <td>
                                <?php print($periodos['montopagar']); ?>
                            </td>         
                        </tr>                         

            <?php endforeach; ?>
                </tbody>
                </table>
               </div>
    <?php endforeach; ?>

    </div>
</form>
 <script>
$(function() {
oTable = $('.pre_detalle_recaudacion').dataTable({
                            "bJQueryUI": true,
                            //"sPaginationType": "full_numbers",
                            "oLanguage": {
                                "oPaginate": {
                                "sPrevious": "Anterior",
                                "sNext": "Siguiente",
                                "sLast": "Ultima",
                                "sFirst": "Primera"
                                },

                                "sLengthMenu": 'Mostrar <select>'+
                                '<option value="10">10</option>'+
                                '<option value="20">20</option>'+
                                '<option value="30">30</option>'+
                                '<option value="40">40</option>'+
                                '<option value="50">50</option>'+
                                '<option value="-1">Todos</option>'+
                                '</select> registros',

                                "sInfo": "Mostrando del _START_ a _END_ (Total: _TOTAL_ resultados)",

                                "sInfoFiltered": " - filtrados de _MAX_ registros",

                                "sInfoEmpty": "No hay resultados de búsqueda",

                                "sZeroRecords": "No hay registros a mostrar",

                                "sProcessing": "Espere, por favor...",

                                "sSearch": "Buscar:"

                                }
                    });
$( "#muestra_pre_envia" ).accordion({
event: "click hoverintent"
});
});
/*
* hoverIntent | Copyright 2011 Brian Cherne
* http://cherne.net/brian/resources/jquery.hoverIntent.html
* modified by the jQuery UI team
*/
$.event.special.hoverintent = {
setup: function() {
$( this ).bind( "mouseover", jQuery.event.special.hoverintent.handler );
},
teardown: function() {
$( this ).unbind( "mouseover", jQuery.event.special.hoverintent.handler );
},
handler: function( event ) {
var currentX, currentY, timeout,
args = arguments,
target = $( event.target ),
previousX = event.pageX,
previousY = event.pageY;
function track( event ) {
currentX = event.pageX;
currentY = event.pageY;
};
function clear() {
target
.unbind( "mousemove", track )
.unbind( "mouseout", clear );
clearTimeout( timeout );
}
function handler() {
var prop,
orig = event;
if ( ( Math.abs( previousX - currentX ) +
Math.abs( previousY - currentY ) ) < 7 ) {
clear();
event = $.Event( "hoverintent" );
for ( prop in orig ) {
if ( !( prop in event ) ) {
event[ prop ] = orig[ prop ];
}
}
// Prevent accessing the original event since the new event
// is fired asynchronously and the old event is no longer
// usable (#6028)
delete event.originalEvent;
target.trigger( event );
} else {
previousX = currentX;
previousY = currentY;
timeout = setTimeout( handler, 100 );
}
}
timeout = setTimeout( handler, 100 );
target.bind({
mousemove: track,
mouseout: clear
});
}
};


envia_recaudacion_a_finanzas = function(form,url){
        $.ajax({
        global:false,
        type:"post",
        data:$('#'+form).serialize(),
        dataType:"json",
        url:url,
        success:function(data){
            if(data.succes){
                $( "#lista_pre_asigna_recaudacion_a_finanzas" ).dialog('close');
                $.each(data.filas_insertadas, function(index, value) {                
    //  
                    $('#'+value).remove();


             });

                $("#revisa_cajas_ext_recaudacion").html('<font color="green"><b>'+data.mensaje+'</b></font>');
                $("#revisa_cajas_ext_recaudacion").show("slide", { direction: "up" }, 1000);
                setTimeout(function(){
                    $("#revisa_cajas_ext_recaudacion").hide("slide", { direction: "up" }, 1000);
                }, 4000); 

//oTable = $('#consulta_ext_recaudacion').dataTable( );
            }else{
                alert('no'); 
//                $("#revisa_asigna_omisos_fiscalizacion").html(data.mensaje);
//                setTimeout(function(){
//                    $("#revisa_asigna_omisos_fiscalizacion").hide("slide", { direction: "up" }, 1000);
//                }, 4000);                  
            }
            

        },
        error:function(o,estado,excepcion){
            if(excepcion=='Not Found'){
            }else{

            }
        }});
    }
validador('form_pre_envio_guarda','<?php print(base_url().'index.php/mod_gestioncontribuyente/lista_contribuyentes_general_c/pre_asigna_recaudacion_a_finanzas'); ?>','envia_recaudacion_a_finanzas');
</script>

