<script>
$(function(){
   $("#espera_cargando_notificacion_culm").hide();
   
   $("#dialog_notifi_multas_culm").dialog({
            autoOpen: false,
            height: 150,
            width: 350,
            modal: true,
            title:'Fecha de la Notificacion',
            show:'slide',
            hide:'clip',
            buttons:{
                "activar":function(){
                     $("#frmculmnoti").submit();
                     $(this).dialog('close');
                },
                "Cancelar":function(){

                    $(this).dialog('close');
                }
             }
         
     }); 
   espera_cargando_notificacion_culm=function(){
        $.blockUI({ 
            message: $('#espera_cargando_notificacion_culm'),
            css: { 
                border: 'none',
                padding: '15px', 
                backgroundColor: '#fff', 
                '-webkit-border-radius': '10px', 
                '-moz-border-radius': '10px', 
                opacity: .7, 
                color: '#CD0A0A' 
            } });  

        };  
});

dialog_notificacion_culm=function(valor1,valor2,valor3){
 
     var htmlform='<form id="frmculmnoti" class="form-style focus-estilo">';
         htmlform+='<input type="hidden" name="idreparo" id="idreparo" value="'+valor1+'" />';
         htmlform+='<input type="hidden" name="multaids" id="multaids" value="'+valor2+'" />';
         htmlform+='<input type="hidden" name="idconusu" id="idconusu" value="'+valor3+'" />';
         htmlform+='<input type="hidden" name="nombre_multa" id="nombre_multa" value="Culiminatoria de Fiscalizacion" />';
         htmlform+='<label>Fecha de Notificacion</label>';
         htmlform+='<input type="text" id="fecha_notic" name="fecha_noti" class="requerido ui-corner-all ui-widget-content"/>';
         htmlform+='</form>';
     $("#dialog_notifi_multas_culm").html(htmlform); 
     
     $("#dialog_notifi_multas_culm").dialog('open');
     
     $( "#fecha_notic" ).datepicker({
        dateFormat: "dd-mm-yy",
        dayNamesMin: [ "Do", "Lu", "Ma", "Mi", "Ju", "Vi", "Sa" ],
        monthNames: [ "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre" ],
        showAnim: "slide",
        navigationAsDateFormat: true
    });
    
     validador('frmculmnoti','<?php echo base_url()."index.php/mod_legal/gestion_multas_legal_c/carga_notificacion"?>','carga_notificacion_culm');

};

carga_notificacion_culm=function(form,url){
$("#dialog_notifi_multas_culm").dialog('close');
$("#espera_cargando_notificacion_culm").html('<p><b>POR FA VOR ESPERE EL SISTEMA ESTA GUARDANDO LA NOTIFICACION...</b></p><br /><br /><img  src="<?php print(base_url()); ?>include/imagenes/loader.gif" width="35" height="35" />');             
espera_cargando_notificacion_culm();// mensage de espera    
        $.ajax({
            type:'post',
            data:$("#"+form).serialize(),
            dataType:'json',
            url:url,
            success:function(data){

                if(data.resultado==true){
                    
                     $.unblockUI();//cierra mensaje de espera
                     var current_index = $("#tabs").tabs("option","selected"); 
//                     alert(current_index)
                     $("#tabs").tabs("load",current_index);

                }


            }
        }); 
};
genera_resolucion_culm=function(idreparo,multasid){
        
        window.open('<?php echo base_url()."index.php/mod_legal/gestion_multas_legal_c/genera_resolucion_culm?idreparo="?>'+idreparo+"&multasid="+multasid+"&tipo=culminatoria");
};

</script>


<div class="contenedor-gm-legal"> 
<div class="ui-widget-header" style="text-align:center; font-size: 12px; font-style: italic; margin-bottom: 10px; width: 80%; margin-left: 10%">Listado de Multas por Culimnatorias de Fiscalizacion Aprobadas </div>

<table cellpadding="0" cellspacing="0" border="0" class="display" id="listar-multas-resolucion" width="100%">
	<thead>
		<tr>
			<th>#</th>
			<th>Rif</th>
                        <th>Razon Social</th>
                        <th>Periodo Fiscalizado</th>
                        <th>Fiscal</th>
                        <th>Monto Multa</th>
                        <th>Monto Interes</th>
                        <th >Operaciones</th>
                </tr>
	</thead>
	<tbody>
           <?
           
           $baseurl=base_url();
           if(!empty($data)):
               $cont=1;
               foreach ($data as $clave => $valor) {
            ?>
                  <tr>
                            <td><?php echo  $cont ?></td>
                            <td><?php echo $valor["rif"] ?></td>
                            <td><?php echo $valor["contribuyente"] ?></td>
                           <td><?php echo $valor["periodo_afiscalizar"] ?></td>    
                            <td><?php echo $valor["fiscal_ejecutor"] ?></td>
                            <td><?php echo $valor["multa_pagar"] ?></td>
                            <td><?php echo $valor["interes_pagar"] ?></td>
                            <td  id="btnoperaciones_rculminatoria">                        
                            <button txtayuda="Generar Resolucion " class=" ayuda resolucion-culminatoria" id="act-<?php echo $valor["idreparo"]?>" onClick="genera_resolucion_culm(<?php echo $valor["idreparo"]?>,'<?php echo $valor['multaids']?>')"></button>
                            <button txtayuda="Cargar notificacion" class=" ayuda carga-notificacion-culmi" id="no-<?php echo $valor["idreparo"]?>" onclick="dialog_notificacion_culm(this.id,'<?php echo $valor['multaids']?>',<?php echo $valor['idconusu']?>);"  ></button>
                            </td>

                    </tr>
            <?php
            $cont ++;
               }
           endif;
           ?>     
           </tbody>
         
           
         </table>
         

   </div>
   <div id="dialog_notifi_multas_culm"></div>
   <div id="espera_cargando_notificacion_culm"></div> 
   
   <div ></div>   
<script>                                                    
$('#btnoperaciones_rculminatoria button').button({
                                icons: {
                                primary: "ui-icon-document"
                                },
                                text: false
                                }).next().button({
                                icons: {
                                primary: "ui-icon-tag"
                                }, text:false
                                
                                });

                         
// script para asignar atributos al listar diseñado con datatables
oTable = $('#listar-multas-resolucion').dataTable({
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




ayudas('.','contenedor-gm-legal','bottom right','top left','fold','up'); 
</script>
<style>
 /*#listar_wrapper{ width: 80%; margin-left: 10%}*/
#listar-multas-resolucion button{ width: 25px; height: 25px}
/* #listar-reparos a{ width: 20px; height: 20px}*/

</style>
