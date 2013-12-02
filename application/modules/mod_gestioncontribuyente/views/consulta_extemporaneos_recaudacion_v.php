<script>
    $(function() {
        ayudas('#','form_ext_recaudacion','bottom right','top left','fold','up');
    
           selecciona_recauda = function (id){
               if ( $('#'+id).hasClass('row_selected') ) {
                   $('#'+id).removeClass('row_selected');
               }else {
                   oTable.$('#'+id).removeClass('row_selected');
                   $('#'+id).addClass('row_selected');
               }
               oTable = $('#consulta_ext_recaudacion').dataTable( );
         
   }

        $("#detalles_contribuyentes_ext_recaudacion").hide();
    
    function revisa_asigna(){
  
        $.ajax({
            global: false,
            type:"post",
            dataType:"json",
            url:'<?php print(base_url().'index.php/mod_gestioncontribuyente/lista_contribuyentes_general_c/revisa_fiscalizaciones'); ?>',
            success:function(data){
                if(data.succes){
                    var lista =data.datos;
                    for(i in lista){
                        $("#asig-"+lista[i].conusuid+lista[i].tipocontid).html('SI');
                        $("#asigna_fiscal"+lista[i].conusuid+lista[i].tipocontid).attr('disabled', true);
                        $("#asigna_fiscal"+lista[i].conusuid+lista[i].tipocontid).attr('checked', true);
                    }
                }else{
//                    $("#asig-"+lista[i].conusuid+lista[i].tipocontid).html('SI');
                }
                
                },
            error:function(o,estado,excepcion){
                if(excepcion=='Not Found'){

                }else{

                }
            }
        });
        setTimeout(function(){
            //revisa_asigna();
        }, 60000);        
    }
    //revisa_asigna();
    });
</script>
<?php // var_dump($respuesta);?>
<form id="form_ext_recaudacion">
    <input type="hidden" id="modo1" name="modo" value="1" />
    <input type="hidden" name="filtro_extemporaneo" value="0" />
    
    <div style="width:100%;" id="muestra_ext_recaudacion">
        <table  id="consulta_ext_recaudacion" cellpadding="0" cellspacing="0" border="0" class="display" width="100%">
            <thead>
                <tr>
                    <th>#</th>
                    <th>Nombre</th>
                    <th>Rif</th>
                    <th>Email</th>
                    <th>Fecha Registro</th>
                    <th>Asignado</th>
                    <th>Acciones<table><tr><td>Todos</td></tr></table></th>
                </tr>        
            </thead>
            <tbody>
        <?php
        if (isset($respuesta) && sizeof($respuesta)>0):
            $cuenta=1;
            foreach($respuesta as $indice=>$valor): ?>
                <tr id="<?php print($indice); ?>">
                    <td>#</td>
                    <td><?php print($valor['datos_usuario'][0]['nombre']); ?></td>
                    <td><?php print($valor['datos_usuario'][0]['rif']); ?></td>
                    <td><?php print($valor['datos_usuario'][0]['email']); ?></td>
                    <td><?php print($valor['nombre_tipocont']); ?></td>
                    <td id="asig-<?php print($indice); ?>">NO</td>
                    <td><input onclick="selecciona_recauda('<?php print($indice); ?>')" type="checkbox" id="asigna_ext_recaudacion<?php print($indice); ?>" name="asigna_ext_recaudacion[]" value="<?php print($valor['datos_usuario'][0]['id']); ?>:<?php print($respuesta[$indice]['tipocontid']); ?>" />
                        <!--<button  class="detalles_consulta_ext_recaudacion" onclick='var periodo<?php print($indice); ?> = <?php print(json_encode($llena)); ?>; alert(JSON.stringify(periodo<?php print($indice); ?>));' ></button>-->
                        <button txtayuda='Informacion de los mese omisos del contribuyente' type="button" id='<?php echo $cuenta ?>' class=" ayuda detalles_consulta_ext_recaudacion"  onclick='ver_detalles_conusu_ext_recaudacion(<?php print($valor['datos_usuario'][0]['id']); ?>,<?php print($respuesta[$indice]['tipocontid']); ?>,"<?php print($respuesta[$indice]['anio_filtro']); ?>","<?php print($respuesta[$indice]['periodo_filtro']); ?>")' > Ver detalles</button>

                    </td>

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
    <div style="float:left;" id="revisa_cajas_ext_recaudacion"></div>
    <button id="pre_asigna_recaudacion_a_finanzas" class='ayuda' type="button" txtayuda='Enviar la seleccion para calculo a finanzas' > <b>Enviar a Finanzas</b></button><br/>
</form> 
<div id="lista_pre_asigna_recaudacion_a_finanzas"></div>
<div id="detalles_contribuyentes_ext_recaudacion"></div>
<script>
$(function() {
  
    $("#revisa_cajas_ext_recaudacion").hide();
    $( "#lista_pre_asigna_recaudacion_a_finanzas" ).dialog({ autoOpen:false });
    $( "#pre_asigna_recaudacion_a_finanzas" ).button({
        icons: {
            primary: "ui-icon-document"
        },
        text: true});
    $( ".btnverdatos" ).button({
        icons: {
            primary: "ui-icon-document"
        },
        text: false});
    $( ".detalles_consulta_ext_recaudacion" ).button({
        icons: {
            primary: "ui-icon-document"
        },
        text: false});
    $("#pre_asigna_recaudacion_a_finanzas").click(function(){
        var cajas=0;
        $("#form_ext_recaudacion input:checked").each(function(){

            if(this.disabled==false){
                cajas=cajas+1
            }
            
        });

        if(cajas>0){
            $("#revisa_cajas_ext_recaudacion").hide("slide", { direction: "up" }, 1000);
            $.ajax({
                global:false,
                type:"post",
                data:$('#form_ext_recaudacion').serialize(),
                dataType:"html",
                url:'<?php print(base_url().'index.php/mod_gestioncontribuyente/lista_contribuyentes_general_c/pre_asigna_recaudacion_a_finanzas'); ?>',
                success:function(html){
                    $( "#lista_pre_asigna_recaudacion_a_finanzas" ).dialog({
                    autoOpen:true,
                    height: 400,
                    width: 600,
                    show:'slide',
                    modal: true,
                    draggable:false,
                    buttons: {
                        Guardar: function() {
                        $('#form_pre_envio_guarda').submit();
                    },
                        Cancel: function() {
                            $( this ).dialog( "close" );
                        }
                    }
                    });
                    $("#lista_pre_asigna_recaudacion_a_finanzas").html(html);
                    },
                error:function(o,estado,excepcion){
                    if(excepcion=='Not Found'){
                 
                    }else{
                 
                    }
                }
            });                       
           }else{
               
                $("#revisa_cajas_ext_recaudacion").html('<font color="red"><b>Seleccione al menos un Contribuyente.</b></font>');
                $("#revisa_cajas_ext_recaudacion").show("slide", { direction: "up" }, 1000);
           }
           });

              
    oTable = $('#consulta_ext_recaudacion').dataTable({
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
    $("#muestra_ext_recaudacion input, select").addClass('ui-state-highlight ui-corner-all');
    $("#consulta_paginate").find("a").click(function(){
//        revisa_asigna();
    });
    vuelve_ext_detalle_recaudacion=function (){
                $("#detalles_contribuyentes_ext_recaudacion").hide("slide", { direction: "left" }, 1000,function() {
                    $(".clase_oculta_muestra").show("slide", { direction: "up" }, 1000,function() {
//                        $("#detalles_contribuyentes_ext_recaudacion").html(html);
                        $("#form_ext_recaudacion").show("slide", { direction: "down" }, 1000);

                      });

                  });
    }
    ver_detalles_conusu_ext_recaudacion = function(idconusu,tipocontribuid,anio,periodo){
        var detalle=4;
        var metodo_vuelve='vuelve_ext_detalle_recaudacion';
        var filtro_ext = 0;
        $.ajax({
            global: false,
            type:"post",
            data:{filtro_extemporaneo:filtro_ext,metodo:metodo_vuelve,filtro_detalles:detalle,id:idconusu,tipocont:tipocontribuid,anio_filtro:anio,periodo_filtro:periodo},
            dataType:"html",
            url:'<?php print(base_url().'index.php/mod_gestioncontribuyente/lista_contribuyentes_general_c/ver_detalles_contribuyentes'); ?>',
            success:function(html){

                $(".clase_oculta_muestra").hide("slide", { direction: "up" }, 1000,function() {
                    $("#form_ext_recaudacion").hide("slide", { direction: "down" }, 1000,function() {
                        $("#detalles_contribuyentes_ext_recaudacion").html(html);
                        $("#detalles_contribuyentes_ext_recaudacion").show("slide", { direction: "left" }, 1000);

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

<style>
    #pre_asigna_recaudacion_a_finanzas{
        float: right;
    }
    
</style>