<?php // print_r($respuesta)?>
<script>
    $(function() {
    ayudas('#','form_omisos_recaudacion','bottom right','top left','fold','up');
    });
    $("#detalles_contribuyentes_omisos_recaudacion").hide();
</script>
    
    
<form id="form_omisos_recaudacion">
    <div style="width:100%;" id="muestra_omisos_recaudacion">
        <table  id="consulta_omisos_recaudacion" cellpadding="0" cellspacing="0" border="0" class="display" width="100%">
            <thead>
                <tr>
                    <th>#</th>
                    <th>Nombre</th>
                    <th>Rif</th>
                    <th>Email</th>
                    <th>Tipo Contribuyente</th>
                    <th>Ver Detalles</th>
                </tr>        
            </thead>
            <tbody>
        <?php
        if (isset($respuesta) && sizeof($respuesta)>0):

            $cuenta=1;
            foreach($respuesta as $indice=>$valor):
                
                (isset($respuesta[$indice]['omisos']) && sizeof($respuesta[$indice]['omisos'])>0? $detalle[]=$respuesta[$indice]['omisos']: '');
//                (isset($respuesta[$indice]['pagados']) && sizeof($respuesta[$indice]['pagados'])>0? $detalle[]=$respuesta[$indice]['pagados']: '');
                (isset($respuesta[$indice]['omisos_declara']) && sizeof($respuesta[$indice]['omisos_declara'])>0? $detalle[]=$respuesta[$indice]['omisos_declara']: '');
//                (isset($respuesta[$indice]['extemporaneos']) && sizeof($respuesta[$indice]['extemporaneos'])>0? $detalle[]=$respuesta[$indice]['extemporaneos']: '');
//                (isset($respuesta[$indice]['dentro_limite_pago']) && sizeof($respuesta[$indice]['dentro_limite_pago'])>0? $detalle[]=$respuesta[$indice]['dentro_limite_pago']: '');?>
                <tr>
                    <td><?php print($cuenta); ?></td>
                    <td><?php print($valor['datos_usuario'][0]['nombre']); ?></td>
                    <td><?php print($valor['datos_usuario'][0]['rif']); ?></td>
                    <td><?php print($valor['datos_usuario'][0]['email']); ?></td>
                    <td><?php print($valor['nombre_tipocont']); ?></td>                   
                    <td><button id="<?php echo $cuenta ?>" txtayuda="Informacion de los mese omisos del contribuyente" type="button" class=" ayuda detalles_consulta_omisos_recaudacion"  onclick='ver_detalles_conusu_omisos_recaudacion(<?php print($valor['datos_usuario'][0]['id']); ?>,<?php print($respuesta[$indice]['tipocontid']); ?>,"<?php print($respuesta[$indice]['anio_filtro']); ?>","<?php print($respuesta[$indice]['periodo_filtro']); ?>")' > Ver detalles</button></td>

                </tr>
                <?php
                $cuenta++;
            endforeach;
        else:
            
        endif;
        ?>        
            </tbody>

        </table><br/>

    </div>
</form> 

<div id="detalles_contribuyentes_omisos_recaudacion"></div>
<script>
$(function() {
   
    
    $("#revisa_cajas").hide();
    $( "#lista_fiscales" ).dialog({ autoOpen:false });
    $( "#envia_fiscal" ).button({
        icons: {
            primary: "ui-icon-document"
        },
        text: true});
    $( ".btnverdatos" ).button({
        icons: {
            primary: "ui-icon-document"
        },
        text: false});
    $( ".detalles_consulta_omisos_recaudacion" ).button({
        icons: {
            primary: "ui-icon-document"
        },
        text: false});
    $("#envia_fiscal").click(function(){
        var cajas=0;
        $("#form_omisos_recaudacion input:checked").each(function(){

            if(this.disabled==false){
                cajas=cajas+1
            }
            
        });

        if(cajas>0){
            $("#revisa_cajas").hide("slide", { direction: "up" }, 1000);
            $.ajax({
                type:"post",
                data:$('#form_omisos_recaudacion').serialize(),
                dataType:"html",
                url:'<?php print(base_url().'index.php/mod_gestioncontribuyente/lista_contribuyentes_general_c/lista_fiscales'); ?>',
                success:function(html){
                    $( "#lista_fiscales" ).dialog({
                    autoOpen:true,
                    height: 300,
                    width: 350,
                    modal: true,
                    draggable:false,
                    buttons: {
                        Guardar: function() {
                        $('#fiscales_asigna_agrega').submit();
                    },
                        Cancel: function() {
                            $( this ).dialog( "close" );
                        }
                    }
                    });
                    $("#lista_fiscales").html(html);
                    },
                error:function(o,estado,excepcion){
                    if(excepcion=='Not Found'){
                 
                    }else{
                 
                    }
                }
            });                       
           }else{
               
                $("#revisa_cajas").html('<font color="red"><b>Seleccione al menos un Contribuyente.</b></font>');
                $("#revisa_cajas").show("slide", { direction: "up" }, 1000);
           } 

                        //        alert($('#form_omisos_recaudacion').serialize());
//                                if ($('#muestra_omisos_recaudacion').is (':visible')){
//                                    $("#muestra_omisos_recaudacion").hide("slide", { direction: "up" }, 1000);
//
//                                }
//                                if ($('#muestra_omisos_recaudacion').is (':hidden')){
//                                    $("#muestra_omisos_recaudacion").show("slide", { direction: "up" }, 1000);
//
//                                }         
                            });

              
    oTable = $('#consulta_omisos_recaudacion').dataTable({
                                "bJQueryUI": true,
                                "sPaginationType": "full_numbers",
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
    $("#muestra_omisos_recaudacion input, select").addClass('ui-state-highlight ui-corner-all');
    $("#consulta_paginate").find("a").click(function(){
//        revisa_asigna();
    });
    vuelve_omisos_detalle_recaudacion=function (){
                $("#detalles_contribuyentes_omisos_recaudacion").hide("slide", { direction: "left" }, 1000,function() {
                    $(".clase_oculta_muestra").show("slide", { direction: "up" }, 1000,function() {
//                        $("#detalles_contribuyentes_ext_recaudacion").html(html);
                        $("#form_omisos_recaudacion").show("slide", { direction: "down" }, 1000);

                      });

                  });
    }   
    
    ver_detalles_conusu_omisos_recaudacion = function(idconusu,tipocontribuid,anio,periodo){
        var detalle=24;
        var metodo_vuelve='vuelve_omisos_detalle_recaudacion';
        $.ajax({
            global: false,
            type:"post",
            data:{metodo:metodo_vuelve,filtro_detalles:detalle,id:idconusu,tipocont:tipocontribuid,anio_filtro:anio,periodo_filtro:periodo},
            dataType:"html",
            url:'<?php print(base_url().'index.php/mod_gestioncontribuyente/lista_contribuyentes_general_c/ver_detalles_contribuyentes'); ?>',
            success:function(html){
                $(".clase_oculta_muestra").hide("slide", { direction: "up" }, 1000,function() {
                    $("#form_omisos_recaudacion").hide("slide", { direction: "down" }, 1000,function() {
                        $("#detalles_contribuyentes_omisos_recaudacion").html(html);
                        $("#detalles_contribuyentes_omisos_recaudacion").show("slide", { direction: "left" }, 1000);

                      });

                  });

                },
            error:function(o,estado,excepcion){
                if(excepcion=='Not Found'){

                }else{

                }
            }
        });
    }    


});
</script>

