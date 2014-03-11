<?php

//print_r($data);
?>
<script type="text/javascript" >
                
 $(function() {
    
    $("#dialogo_envio_finanzas_legal").dialog({
            modal: true, //inhabilitada pantalla de atras
            autoOpen: false,
            draggable: true,
            resizable: false, //evita cambiar tamaño del cuadro del mensaje
            show: "show", //efecto para abrir cuadro de mensaje
            hide: "slide", //efecto para cerrar cuadro de mensaje
            
        });

 });    
 
 espera_repa_culmi=function(){
    $.blockUI({ 
        message: $('#espera_repa_culmi'),
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
 </script>
<div id="espera_repa_culmi"></div>
<div class="ui-widget-header" style="text-align:center; font-size: 12px; font-style: italic; margin-bottom: 20px; width: 80%; margin-left:10%; ">Listado de Reparos con Escritos de Descargos</div>

<table cellpadding="0" cellspacing="0" border="0" class="display usuario" id="listar-descrepa" width="100%">
	<thead>
		<tr>
			<th>#</th>
                        <th>RIF</th>
                        <th>Raz&oacute;n social</th>
                        <th>Tipo de Contribuyente</th>
			<th>Fecha de Reparo</th>
			<th>Notificaci&oacute;n del Reparo</th>
                        <th>Fecha de Descargos</th>
                        <th>Compareciente</th>
                        <th>Opciones</th> 
                </tr>
	</thead>
	<tbody>
           <?
           $baseurl=base_url();
           if(!empty($data)):
                foreach ($data as $clave => $valor) {
                                 
         
                    echo '<tr >
                             <td>'.($clave+1).'</td>
                             <td>'. $valor["rif"].'</td>    
                             <td>'. $valor["razonsocial"].'</td>
                             <td>'. $valor["tcontribu"].'</td>
                             <td>'. $valor["elab_reparo"].'</td>
                             <td>'. $valor["noti_reparo"].'</td>
                             <td>'. $valor["fecha_escrito"].'</td>
                             <td>'. $valor["compareciente"].'</td>
                             <td>
                             <button txtayuda="sumario" txtdialog="En estos momentos se dispone a enviar a finanzas el reparo<br /><center><b>¿Esta usted seguro del envio?</b>" funcion="envia_finanzas_descargos" class="ayuda operaciones-descar" id="ds-'.$valor["reparoid"].'"></button>
                             <button txtayuda="Cerrar caso" txtdialog="En estos momentos se dispone a cerrar el el procedimiento de descargo<br /><center><b>¿Esta usted seguro del cierre del caso?</b>" funcion="cerrar_descargos" class="ayuda operaciones-descar" id="dc-'.$valor["reparoid"].'"></button>

                            </td>
                     </tr>';
                 }
            endif;
           ?>
            <!--<button id="'.$valor["id_usuario"].'" onclick="if(confirma() == false) return false" href="<? //=base_url()?>index.php/mod_administrador/usuarios_c/eliminar_usuario/<?//=this.id?>" title="Eliminar Usuario"></button>-->
                        
            
 </table>
 <div id="dialogo_envio_finanzas_legal">
            

 </div>
<script>
$("#listar-descrepa button").button({
                           icons: {
                           primary: "ui-icon-document"
                           },
                           text: false
                           }).next().button({
                           icons: {
                           primary: "ui-icon-key"
                           }
                       });
//            script para asignar atributos al listar diseñado con datatables
oTable = $('#listar-descrepa').dataTable({
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
$(".operaciones-descar").click(function(){

//    alert($(this).attr('funcion'));
$("#dialogo_envio_finanzas_legal").html('<p style="font-family: sans-serif; line-height: 1.5; text-align: justify"><span style="float: left; margin-right: .0em;" class="ui-icon ui-icon-alert"></span><b>Alerta:</b> '+$(this).attr("txtdialog")+'</center></p>');
    var valorid=this.id;
    $("#dialogo_envio_finanzas_legal").dialog({
        title: "Envio a Finanzas",
        buttons: {  //propiedad de dialogo, agregar botones
                SI: function() {
                        $( this ).dialog( "close" );
                        $.ajax({  

                              type:'post',
                              data:{id:valorid},
                              dataType:'json',
                              url:'<?php echo base_url()."index.php/mod_legal/legal_c/"?>'+$("#"+valorid).attr('funcion'),
                              success:function(data){

                               if(data.resultado===true){
                                   
                                   $("#tabs").tabs("load",0); 

                               }


                              },
                              beforeSend:function(){
                              
                                $("#espera_repa_culmi").html('<p><b>POR FA VOR ESPERE EL SISTEMA ESTA PROCESANDO SU SOLICITUD...</b></p><br /><br /><img  src="<?php print(base_url()); ?>include/imagenes/loader.gif" width="35" height="35" />');             
                                espera_repa_culmi();
                              },
                              complete:function(){
                                 $.unblockUI();//cierra mensaje de espera
                                 $("#espera_repa_culmi").empty();
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
                    }
                    ,
                NO: function() { 
                       
                        $( this ).dialog( "close" ); 
                }

            }
    });
    
     $("#dialogo_envio_finanzas_legal").dialog('open');
});

 ayudas('#','listar-descrepa','bottom right','left top','fold','up');
</script>
        
<style>
     #listar-descrepa button{ width: 20px; height: 20px;}
</style>