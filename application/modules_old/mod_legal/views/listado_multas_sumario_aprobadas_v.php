<?php // echo date('Y'); ?>
<script>
$(function(){
   $("#espera_cargando_notificacion").hide();
   
   $("#dialog_notifi_multas_sumario").dialog({
            autoOpen: false,
            height: 150,
            width: 350,
            modal: true,
            title:'Fecha de la Notificacion',
            show:'slide',
            hide:'clip',
            buttons:{
                "activar":function(){
                     $("#frmsumarionoti").submit(); 
                },
                "Cancelar":function(){

                    $(this).dialog('close');
                }
             }
         
     }); 
   espera_cargando_notificacion=function(){
        $.blockUI({ 
            message: $('#espera_cargando_notificacion'),
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

dialog_notificacion_sumario=function(valor1,valor2,valor3){
 
     var htmlform='<form id="frmsumarionoti" class="form-style focus-estilo">';
         htmlform+='<input type="hidden" name="idreparo" id="idreparo" value="'+valor1+'" />';
         htmlform+='<input type="hidden" name="multaids" id="multaids" value="'+valor2+'" />';
         htmlform+='<input type="hidden" name="idconusu" id="idconusu" value="'+valor3+'" />';
         htmlform+='<input type="hidden" name="nombre_multa" id="nombre_multa" value="Resolucion de Sumario" />';
         htmlform+='<label>Fecha de Notificacion</label>';
         htmlform+='<input type="text" id="fecha_noti" name="fecha_noti" class="requerido ui-corner-all ui-widget-content"/>';
         htmlform+='</form>';
     $("#dialog_notifi_multas_sumario").html(htmlform); 
     
     $("#dialog_notifi_multas_sumario").dialog('open');
     
     $( "#fecha_noti" ).datepicker({
        dateFormat: "dd-mm-yy",
        dayNamesMin: [ "Do", "Lu", "Ma", "Mi", "Ju", "Vi", "Sa" ],
        monthNames: [ "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre" ],
        showAnim: "slide",
        navigationAsDateFormat: true
    });
    
     validador('frmsumarionoti','<?php echo base_url()."index.php/mod_legal/gestion_multas_legal_c/carga_notificacion"?>','carga_notificacion_sumario');

};

carga_notificacion_sumario=function(form,url){
$("#dialog_notifi_multas_sumario").dialog('close');
$("#espera_cargando_notificacion").html('<p><b>POR FA VOR ESPERE EL SISTEMA ESTA GUARDANDO LA NOTIFICACION...</b></p><br /><br /><img  src="<?php print(base_url()); ?>include/imagenes/loader.gif" width="35" height="35" />');             
espera_cargando_notificacion();// mensage de espera    
        $.ajax({
            type:'post',
            data:$("#"+form).serialize(),
            dataType:'json',
            url:url,
            success:function(data){

                if(data.resultado===true){

                     $.unblockUI();//cierra mensaje de espera
                     $("#tabs").tabs("load",0);

                }


            },
            error: function (request, status, error) {
                $.unblockUI();//cierra mensaje de espera
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
};
genera_resolucion_sumario=function(idreparo,multasid){
        
        window.open('<?php echo base_url()."index.php/mod_legal/gestion_multas_legal_c/genera_resolucion_culm?idreparo="?>'+idreparo+"&multasid="+multasid+"&tipo=sumario");
};

</script>




<div class="contenedor-gm-legal"> 
<div class="ui-widget-header" style="text-align:center; font-size: 12px; font-style: italic; margin-bottom: 10px; width: 80%; margin-left: 10%">Listado de Multas por Sumario Aprobadas </div>

<table cellpadding="0" cellspacing="0" border="0" class="display" id="listar-multas-sumario" width="100%">
	<thead>
		<tr>
			<th>#</th>
			<th>RIF</th>
                        <th>Raz&oacute;n Social</th>
                        <th>Per&iacute;odo Fiscalizado</th>
                        <th>Fiscal</th>
                        <th>Monto de la Multa</th>
                        <th>Monto del Inter&eacute;s</th>
                        <th >Opciones</th>
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
                            <td><?php echo $this->funciones_complemento->devuelve_cifras_unidades_mil($valor["multa_pagar"]) ?></td>
                            <td><?php echo $this->funciones_complemento->devuelve_cifras_unidades_mil($valor["interes_pagar"]) ?></td>
                            <td  id="btnoperaciones_sumario">                        
                            <button txtayuda="Generar Resolución " class=" ayuda resolucion-sum" id="acts-<?php echo $valor["idreparo"]?>" onClick="genera_resolucion_sumario(<?php echo $valor["idreparo"]?>,'<?php echo $valor['multaids']?>')" ></button>
                            <button txtayuda="Cargar Notificación" class=" ayuda carga-notificacion-sum" id="nos-<?php echo $valor["idreparo"]?>" onclick="dialog_notificacion_sumario(this.id,'<?php echo $valor['multaids']?>',<?php echo $valor['idconusu']?>);"  ></button>
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
   <div id="dialog_notifi_multas_sumario" ></div>
   
   <div id="espera_cargando_notificacion"></div>   
<script>                                                    
$('#btnoperaciones_sumario button').button({
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
oTable = $('#listar-multas-sumario').dataTable({
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
#listar-multas-sumario button{ width: 25px; height: 25px}
/* #listar-reparos a{ width: 20px; height: 20px}*/

</style>
