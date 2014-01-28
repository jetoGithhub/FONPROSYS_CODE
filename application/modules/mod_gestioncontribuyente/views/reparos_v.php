
<html>
    <script type="text/javascript" charset="utf-8">
  
 $(function() {
     
     $("#reparos-show").hide();
     $("#detalles-reparo").hide();
     $("#error-reparo-activa").hide();
     $("#esperando_notificaciones_reparo").hide();
     $("#dialog_activando_reparo").dialog({
            autoOpen: false,
            height: 220,
            width: 350,
            modal: true,
            title:'Datos de la notificacion',
            show:'slide',
            hide:'clip',
            buttons:{
                "activar":function(){
                    $("#frm_activando_reparo").submit();
                    
                },
                "Cancelar":function(){

                    $(this).dialog('close');
                }
             }
         
     });
     
     espera_activa_reparo=function(){
        $.blockUI({ 
            message: $('#esperando_notificaciones_reparo'),
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
 
 arma_dialog_activador=function(valor){
 
    var cuerpo_dialog;
    
    cuerpo_dialog="<form id='frm_activando_reparo' class='form-style focus-estilo' style='padding:10px'>";
    cuerpo_dialog+="<input type='hidden' value='"+valor+"' name='ids' id='ids' class=' ui-widget-content ui-corner-all' />";
    cuerpo_dialog+="<label>Fecha de la Notificacion</label>";
    cuerpo_dialog+="<input type='text' readonly name='fnreparo' id='fnreparo' class='requerido ui-widget-content ui-corner-all' />";
    cuerpo_dialog+="<label>Recibido por:</label>";
    cuerpo_dialog+="<select name='recibidopor' id='recibidopor' class='requerido ui-widget-content ui-corner-all'><option value=''>Seleccione</option><option value='1'>Secretaria</option><option value='2'>Recepcionista</option><option value='3'>Rep. legal</option><option value='4'>Otros</option></select>";
//    cuerpo_dialog+="<input type='text' name='recibidopor' id='recibidopor' class='requerido ui-widget-content ui-corner-all' />";
    cuerpo_dialog+="</form>";
    $("#dialog_activando_reparo").html(cuerpo_dialog);
    
    $("#dialog_activando_reparo").dialog('open');
    $( "#fnreparo" ).datepicker({
        dateFormat: "dd-mm-yy",
        dayNamesMin: [ "Do", "Lu", "Ma", "Mi", "Ju", "Vi", "Sa" ],
        monthNames: [ "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre" ],
        showAnim: "slide",
        navigationAsDateFormat: true
    });
    validador('frm_activando_reparo','<?php echo base_url()."index.php/mod_gestioncontribuyente/reparos_c/activa_reparo_contribuyente"?>','activar_reparo');
 };
// $(document).ready(function() 
//{
    
    
   // Match all link elements with href attributes within the content div
//   $('#reparos-show button').qtip(
//   {
//       
//     content:'prueba', // Set the tooltip content to the current corner
//           
//      position: {
////		target: 'mouse',
//                my: 'right bottom', // se mueve el apuntador de pocicion
//                at: 'top left' //se mueve el cuerpo del mensaje
//	},
//        style:{
//            classes: 'ui-tooltip-red ui-tooltip-rounded' // clases para cambiar el estilo ojo en 
//                                                         //la pagina salen unos pero hay que remplazar
//                                                         // la palabra qtip por ui-tooltip
//        },
//        show: {
//		effect: function(offset) {
//			$(this).show( "slide",{direction:'right'}, 500 ); // "this" refers to the tooltip
//		}
//	}
//        
//      
//       
//       
//
//    });
//});


 </script>
<div id="reparos-show"> 
    <div class="ui-widget-header" style="text-align:center; font-size: 12px; font-style: italic; margin-bottom: 10px; width: 80%; margin-left: 10%">Listado de Reparos en espera de aprobaci&oacute;n</div>

<table cellpadding="0" cellspacing="0" border="0" class="display" id="listar-reparos" width="100%">
	<thead>
		<tr>
			<th>#</th>
			<th>RIF</th>
                        <th>Raz&oacute;n Social</th>
                        <th>Tipo contribuyente</th>
                        <th>Fecha de Elaboraci&oacute;n</th>
                        <th>Monto del Reparo</th>
                        <th>Fiscal Ejecutante</th>
                        <th>Tipo</th>
                        <th >Opciones</th>
<!--                        <th><button txtayuda="Marcar todos" class=" ayuda" id="marcar_todos" style="width: 25px; height: 25px; border: none" value="marca" >marcar</button></th>-->
                        
                </tr>
	</thead>
	<tbody>
           <?
           
           $baseurl=base_url();
           foreach ($data as $clave => $valor) {
            $con=$clave+1;
//            $v=$valor['nombre'];
//            if($valor["bln_activo"]=='t'): $estatus='ACTIVO'; else: $estatus='INACTIVO'; endif;?>
              <tr>
                        <td><?php echo  $con ?></td>
			<td><?php echo $valor["rif"] ?></td>
                        <td><?php echo $valor["nombre"] ?></td>
                        <td><?php echo $valor["tcontribuyente"] ?></td>    
                        <td><?php echo date('d/m/Y',strtotime($valor["felaboracion"])) ?></td>
                        <td><?php echo $this->funciones_complemento->devuelve_cifras_unidades_mil($valor["total"]) ?></td>
                        <td><?php echo $valor["fiscal"] ?></td>
                        <td><?php ($valor['conformida']=='f'? print('REPARO') : print('CONFORMIDA') ); ?></td>    
                        <td  id="btnoperaciones">                        
                        <a href="<?php print($valor['ruta']); ?>" txtayuda="Generar acta de reparo" class=" ayuda" id="<?php echo 'btnar-'.$valor["id"]?>" download="<?php print($valor['ruta']); ?>" ></a>
                        <button txtayuda="Muestra el detalle del reparo" class=" ayuda btndetareparo" id="<?php echo $valor["id"]?>"></button>
                        <button txtayuda="Cargar Notificacion" class=" ayuda" id="activo_reparo" onClick="arma_dialog_activador('<?php echo $valor["id"].":".$valor['idconusu'].":".$valor['conformida'] ?>')"></button>
                        </td>
<!--                        <td>
                             <input   type="checkbox" id="<?php // echo $valor["id"] ?>" name="reparo_activo[]" value="<?php echo $valor["id"].":".$valor['idconusu'] ?>">
                        </td>-->
                </tr>
        <?php              
           }
           ?>
            <!--<button id="'.$valor["id_usuario"].'" onclick="if(confirma() == false) return false" href="<? //=base_url()?>index.php/mod_administrador/usuarios_c/eliminar_usuario/<?//=this.id?>" title="Eliminar Usuario"></button>-->
                        
           </tbody>
         
           
         </table>
         

   </div>
   <div id="dialog_activando_reparo"></div>
   
   <div id="esperando_notificaciones_reparo"></div>
   
   <div id="detalles-reparo" style=" margin-top:50px "></div>
<script>                                                    
$('#btnoperaciones a').button({
                                icons: {
                                primary: "ui-icon-document"
                                },
                                text: false
                                }).next().button({
                                icons: {
                                primary: "ui-icon-key"
                                }, text:false
                                }).next().button({
                                icons: {
                                primary: "ui-icon-tag"
                                }, text:false
                                
                                });

                         
// script para asignar atributos al listar diseñado con datatables
oTable = $('#listar-reparos').dataTable({
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

$('.btndetareparo').click(function(){  
        $.ajax({  

                   type:'post',
                   data:{id:this.id},
                   dataType:'json',
                   url:'<?php echo base_url()."index.php/mod_gestioncontribuyente/reparos_c/detalles_reparo"?>',
                   success:function(data){

                    if(data.resultado===true){

                        $("#detalles-reparo").html(data.vista);
                        $("#detalles-reparo").show("drop",{ direction: "up" }, 1000 );

                    }


                   }
            });  

}); 

activar_reparo=function(form,url){
$("#dialog_activando_reparo").dialog('close');
$("#esperando_notificaciones_reparo").html('<p><b>POR FA VOR ESPERE EL SISTEMA ESTA CARGANDO LA NOTIFICACION...</b></p><br /><br /><img  src="<?php print(base_url()); ?>include/imagenes/loader.gif" width="35" height="35" />');             
espera_activa_reparo();// mensage de espera
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


                            }
                 });
};


        
$(document).ready(function() {
    ayudas('#','reparos-show');
    $("#reparos-show").show( "blind", 1000 );

});
ayudas('#','reparos-show','bottom right','top left','fold','up'); 
        </script>
        <style>
         /*#listar_wrapper{ width: 80%; margin-left: 10%}*/
        #listar-reparos button{ width: 20px; height: 20px}
         #listar-reparos a{ width: 20px; height: 20px}

        </style>
	
</html>
