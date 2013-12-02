<?php
//    print_r($respuesta)
?>

<script>
    $(function() {
    ayudas('#','form_envia_fiscal_omisos_fiscalizacion','bottom right','top left','fold','up');
    });
    
    $("#detalles_contribuyentes_omisos_fiscalizacion").hide();
    function revisa_asigna_omisos_fiscalizacion(){

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
                        $("#asigna_fiscal_omisos_fiscalizacion"+lista[i].conusuid+lista[i].tipocontid).attr('disabled', true);
                        $("#asigna_fiscal_omisos_fiscalizacion"+lista[i].conusuid+lista[i].tipocontid).attr('checked', true);
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
//        setTimeout(function(){
//            revisa_asigna_omisos_fiscalizacion();
//        }, 60000);        
    }
//    revisa_asigna_omisos_fiscalizacion();

</script>
<form id="form_envia_fiscal_omisos_fiscalizacion" >
    <div style="width:100%;" id="muestra_consulta_omisos_fiscalizacion">
        <table  id="consulta" cellpadding="0" cellspacing="0" border="0" class="display" width="100%">
            <thead>
                <tr>
                    <th>#</th>
                    <th>Nombre</th>
                    <th>Rif</th>
                    <th>Email</th>
                    <th>Fecha Registro</th>
                    <th>Asignado</th>
                    <th>Detalles</th>
                    <th>Seleccion de Asignacion</th>
                    <!--<th>Acciones<table><tr><td>Todos</td></tr></table></th>-->
                    
                    
                </tr>        
            </thead>
            <tbody>
        <?php
        if (isset($respuesta) && sizeof($respuesta)>0):
            $cuenta=1;
            foreach($respuesta as $indice=>$valor):  ?>
                <tr>
                    <td><?php print($cuenta); ?></td>
                    <td><?php print($valor['datos_usuario'][0]['nombre']); ?></td>
                    <td><?php print($valor['datos_usuario'][0]['rif']); ?></td>
                    <td><?php print($valor['datos_usuario'][0]['email']); ?></td>
                    <td><?php print($valor['nombre_tipocont']); ?></td>
                    <td id="asig-<?php print($indice); ?>">NO</td>
                     <td>
                         <button txtayuda=" Informacion de los periodos omisos del contribuyente" id="<?php echo $cuenta ?>" type="button" class="ayuda detalles_consulta_omisos_fiscalizacion"  onclick='ver_detalles_conusu_omisos_fiscalizacion(<?php print($valor['datos_usuario'][0]['id']); ?>,<?php print($respuesta[$indice]['tipocontid']); ?>,"<?php print($respuesta[$indice]['anio_filtro']); ?>","<?php print($respuesta[$indice]['periodo_filtro']); ?>")' > 
                            Ver detalles
                        </button>
                    </td>
                    <td style=" max-width:15px; padding: 0px">
<!--                        <table>
                            <tr>
                                <td>-->
                                    <input ident="<?php print($indice); ?>" type="checkbox" id="asigna_fiscal_omisos_fiscalizacion<?php print($indice); ?>" onchange="muestra_select_periodo(<?php echo $indice?>,this)" name="asigna_fiscal[]" value="<?php print($valor['datos_usuario'][0]['id'].":".$valor['tipocontid']); ?>" />
<!--                                </td> 
                                <td>-->
                                    <select name="periodos_omisos[]" id="periodos_omisos<?php print($indice); ?>" txtayuda="Selecione un periodo para ser fiscalizado" class="ayuda select_periodo ui-widget-content" style="width:60px; font-family: sans-serif, monospace;  font-size: 12px; display: inline; position: absolute; margin-top: -20px; margin-left: 27px">
                                        <option value="0" selected="selected" >A&ntilde;os</option>

                                           <?php
               //                            isset($anio);
                                           foreach ($valor['omisos'] as $clv=>$vlr):

                                             if($clv==0):
                                                $anio=$vlr['ano']; 
                                               echo '<option value="'.$vlr['ano'].":".$vlr['calpagoid'].'">'.$vlr['ano'].'</option>';

                                             else:

                                                 if($anio!=$vlr['ano']):
                                                     echo '<option value="'.$vlr['ano'].":".$vlr['calpagoid'].'">'.$vlr['ano'].'</option>';
                                                     $anio=$vlr['ano'];
                                                 endif;

                                             endif;
                                           endforeach;
                                           ?>
                                   </select>
                                   
<!--                                </td>
                            </tr>
                        </table>-->
                                    
                              
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
<!--    <div style="float:left;" id="revisa_asigna_omisos_fiscalizacion"></div>-->
    <button id="envia_fiscal_omisos_fiscalizacion" type="button" txtayuda="Asignar fiscalizacion a funcionario" class="ayuda"  > <b>Asignar a Fiscal</b></button><br/>
</form> 
<div id="lista_fiscales_omisos_fiscalizacion" title="Asignacion de visitas"></div>
<div id="detalles_contribuyentes_omisos_fiscalizacion"></div>
<script>
$(function() {
  
    $("#revisa_asigna_omisos_fiscalizacion").hide();
    $(".select_periodo").hide();
    $(".select_periodo").attr('disabled','disabled');
    $( "#lista_fiscales_omisos_fiscalizacion" ).dialog({ autoOpen:false });
    $( "#envia_fiscal_omisos_fiscalizacion" ).button({
        icons: {
            primary: "ui-icon-document"
        },
        text: true});
    $( ".btnverdatos" ).button({
        icons: {
            primary: "ui-icon-document"
        },
        text: false});
    $( ".detalles_consulta_omisos_fiscalizacion" ).button({
        icons: {
            primary: "ui-icon-document"
        },
        text: false});
    $("#envia_fiscal_omisos_fiscalizacion").click(function(){
//        alert($('#form_envia_fiscal_omisos_fiscalizacion').serialize());
        var cajas=0;
        $("#form_envia_fiscal_omisos_fiscalizacion input:checked").each(function(){
//            alert($("#periodos_omisos"+$(this).attr('ident')).val())
            if(this.disabled==false){
                if($("#periodos_omisos"+$(this).attr('ident')).val()!=0){
                cajas=cajas+1
                }
            }
            
        });

        if(cajas>0){
            $("#revisa_asigna_omisos_fiscalizacion").hide("slide", { direction: "up" }, 1000);
            $.ajax({
                type:"post",
                data:$('#form_envia_fiscal_omisos_fiscalizacion').serialize(),
                dataType:"html",
                url:'<?php print(base_url().'index.php/mod_gestioncontribuyente/lista_contribuyentes_general_c/lista_fiscales'); ?>',
                success:function(html){
                    $( "#lista_fiscales_omisos_fiscalizacion" ).dialog({
                    autoOpen:true,
                    height: 300,
                    width: 350,
                    modal: true,
                    draggable:false,
                    buttons: {
                        Guardar: function() {
                        $('#fiscales_asigna_agrega_omisos_fiscalizacion').submit();
                    },
                        Cancel: function() {
                            $( this ).dialog( "close" );
                        }
                    }
                    });
                    $("#lista_fiscales_omisos_fiscalizacion").html(html);
                    },
                error:function(o,estado,excepcion){
                    if(excepcion=='Not Found'){
                 
                    }else{
                 
                    }
                }
            });                       
           }else{
               
                $("#revisa_asigna_omisos_fiscalizacion").html('<font color="red"><b>Seleccione al menos un Contribuyente.</b></font>');
                $("#revisa_asigna_omisos_fiscalizacion").show("slide", { direction: "up" }, 1000);
           }
           });

              
    oTable = $('#consulta').dataTable({
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
    $("#muestra_consulta_omisos_fiscalizacion input, select").addClass('ui-state-highlight ui-corner-all');
    $("#consulta_paginate").find("a").click(function(){        
        revisa_asigna_omisos_fiscalizacion();
    });
    vuelve_omisos_detalle_fiscalizacion=function (){
                $("#detalles_contribuyentes_omisos_fiscalizacion").hide("slide", { direction: "left" }, 1000,function() {
                    $(".clase_oculta_muestra").show("slide", { direction: "up" }, 1000,function() {
                        $("#form_envia_fiscal_omisos_fiscalizacion").show("slide", { direction: "down" }, 1000);

                      });

                  });
    }    
    ver_detalles_conusu_omisos_fiscalizacion = function(idconusu,tipocontribuid,anio,periodo){
        var detalle=24;
        var metodo_vuelve='vuelve_omisos_detalle_fiscalizacion';
        $.ajax({
            metodo:metodo_vuelve,
            global:false,
            type:"post",
            data:{metodo:metodo_vuelve,filtro_detalles:detalle,id:idconusu,tipocont:tipocontribuid,anio_filtro:anio,periodo_filtro:periodo},
            dataType:"html",
            url:'<?php print(base_url().'index.php/mod_gestioncontribuyente/lista_contribuyentes_general_c/ver_detalles_contribuyentes'); ?>',
            success:function(html){
                $(".clase_oculta_muestra").hide("slide", { direction: "up" }, 1000,function() {
                    $("#form_envia_fiscal_omisos_fiscalizacion").hide("slide", { direction: "down" }, 1000,function() {
                        $("#detalles_contribuyentes_omisos_fiscalizacion").html(html);
                        $("#detalles_contribuyentes_omisos_fiscalizacion").show("slide", { direction: "left" }, 1000);

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
    muestra_select_periodo=function(index,htmlrequest){
        
        $("#form_envia_fiscal_omisos_fiscalizacion input[type=checkbox]").each(function(i) {  
//                alert(htmlrequest.id+"-"+this.id)
              if(htmlrequest.id==this.id)
              {                  
                 if($(this).is(':checked')){
//                     alert('siiiiiiiiiiii')
                    $("#periodos_omisos"+index).show();
                    $("#periodos_omisos"+index).removeAttr('disabled');
                  }else{
//                      alert('noooooooooooo')
                    $("#periodos_omisos"+index).hide();
                    $("#periodos_omisos"+index).attr('disabled','true');
                  }    
              }else{
                  
                  $(this).removeAttr('checked');
                  $("#periodos_omisos"+$(this).attr('ident')).hide();
                  $("#periodos_omisos"+$(this).attr('ident')).attr('disabled','true');
              }
        });
        
        
       
       
    }
});
</script>

<style>
    #envia_fiscal_omisos_fiscalizacion{
        float: right;
    }
    
</style>