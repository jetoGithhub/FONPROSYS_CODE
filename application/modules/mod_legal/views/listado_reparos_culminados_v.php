
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
<div class="ui-widget-header" style="text-align:center; font-size: 12px; font-style: italic; margin-bottom: 20px; width: 80%; margin-left:10%; ">Listado de Reparos Culminados por la Gerencia de Fiscalizaci&oacute;n</div>
<table cellpadding="0" cellspacing="0" border="0" class="display usuario" id="listar-repculm" width="100%">
	<thead>
		<tr>
			<th>#</th>
                        <th>Raz&oacute;n social</th>
                        <th>Email</th>
			<!--<th>Estado</th>-->
			<th>Fiscal</th>
                        <!--<th>Fecha elaboracion</th>-->
                        <th>Fecha de Notificaci&oacute;n</th>
                        <th>Estatus</th>
                        <th>Opciones</th> 
                </tr>
	</thead>
	<tbody>
           <?
           $baseurl=base_url();
           if(!empty($data)):
                foreach ($data as $clave => $valor) {
                 $con=$clave+1;
                 $class=$valor["semaforo"];
                 
                 if($valor["semaforo"]=='verde'): $imagen='green_light.png'; endif; 
                 if ($valor["semaforo"]=='amarillo'): $imagen='yellow_light.png'; endif;
                 if ($valor["semaforo"]=='rojo'): $imagen='red_light.png'; endif;            
         
                 
         //         ($valor["semaforo"]=='verde'? $class='green_light.png' : $class='');
//                 ($valor["semaforo"]=='amarillo'? $class='yellow_light.png' : $class='');
//                 ($valor["semaforo"]=='rojo'? $class='red_light.png' : $class='');
     //            $v=$valor['nombre'];
                    echo '<tr class='.$class.' >
                             <td> <img src="'.base_url().'include/imagenes/iconos/'.$imagen.'" width="24" height="24" ></td>
                             <td>'. $valor["razonsocial"].'</td>
                             <td>'. $valor["email"].'</td>';
//                             <td>'. $valor["estado"].'</td>
                             echo '<td>'. $valor["fiscal"].'</td>';
//                             <td>'. date('d-m-Y',strtotime($valor["fechaelab"])).'</td>
                             echo '<td>'. date('d/m/Y',strtotime($valor["fechanoti"])).'</td>
                             <td>'. $valor["estatus"].'</td> 
                             <td>';
                            if (($class=="verde") && ($valor["estatus"]=='CANCELADO')) {
                                
                                echo '<button txtayuda="Culm. fiscalizacion" class="ayuda envio" id="v-'.$valor["reparoid"].'"></button>';  
                                
                             }elseif(($class=="verde")){
                                 
                                  echo'<button txtayuda="Culm. fiscalizacion" class="ayuda envio" style="display:none" id="ac-'.$valor["reparoid"].'"></button>
                                      <button txtayuda="Escrito de descargos" class="ayuda descargos" id="ae-'.$valor["reparoid"].'"></button>';
                             }
                             if(($class=="amarillo")&& ($valor["estatus"]=='CANCELADO')){
                                 
                                 echo'<button txtayuda="Culm. fiscalizacion" class="ayuda envio" id="ac-'.$valor["reparoid"].'"></button>';
                                 
                             }elseif(($class=="amarillo")){
                                 
                                  echo'<button txtayuda="Culm. fiscalizacion" class="ayuda envio" style="display:none" id="ac-'.$valor["reparoid"].'"></button>
                                      <button txtayuda="Escrito de descargos" class="ayuda descargos" id="ae-'.$valor["reparoid"].'"></button>';
                             }
                             if(($class=="rojo")){
                                
                                 echo'<button txtayuda="Sumario" class="ayuda envio" id="rs-'.$valor["reparoid"].'"></button>';
                             }
                             
                            echo' </td>
                     </tr>';
                 }
            endif;
           ?>
            <!--<button id="'.$valor["id_usuario"].'" onclick="if(confirma() == false) return false" href="<? //=base_url()?>index.php/mod_administrador/usuarios_c/eliminar_usuario/<?//=this.id?>" title="Eliminar Usuario"></button>-->
                        
            
         </table>
         <div id="dialogo_envio_finanzas_legal">
            

         </div>
        <center><table style=" width: 80%; margin-top: 30px" border="0">
            <tr>
                <td>            
                    <img src="<?php echo base_url()."/include/imagenes/iconos/green_light.png"; ?>" style=" float: left;" width="32"/>
                 </td>   

                <td>
                    <b> Dentro de los 15 días h&aacute;biles</b>
                </td>

                <td >            
                    <img src="<?php echo base_url()."/include/imagenes/iconos/yellow_light.png"; ?>" style=" float: left;" width="32"/>
                 </td>   

                <td>
                    <b> Dentro de los 40 d&iacute;as h&aacute;biles Esperando Descargos</b>
                </td>

                <td>            
                    <img src="<?php echo base_url()."/include/imagenes/iconos/red_light.png"; ?>" style=" float: left;" width="32"/>
                 </td>   

                <td>
                    <b> Calcular Sumario</b>
                </td>

        </table></center>
        <script>
            $("#listar-repculm button").button({
                           icons: {
                           primary: "ui-icon-document"
                           },
                           text: false
                           }).next().button({
                           icons: {
                           primary: "ui-icon-key"
                           }                          

                           }).next().button({
                           icons: {
                           primary: "ui-icon-pin-s"
                           }                          

                           });
//            script para asignar atributos al listar diseñado con datatables
            oTable = $('#listar-repculm').dataTable({
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
$(".envio").click(function(){

//    alert(this.id);
$("#dialogo_envio_finanzas_legal").html('<p style="font-family: sans-serif; line-height: 1.5; text-align: justify"><span style="float: left; margin-right: .0em;" class="ui-icon ui-icon-alert"></span><b>Alerta:</b> En estos momentos se dispone a enviar a finanzas el reparo<br /><center><b>¿Esta usted seguro del envio?</b></center></p>');
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
                              url:'<?php echo base_url()."index.php/mod_legal/legal_c/envia_finanzas"?>',
                              success:function(data){

                               if(data.resultado===true){
                                   
                                   $("#tabs").tabs("load",0); 

                               }


                              },
                              beforeSend:function(){
                              
                                $("#espera_repa_culmi").html('<p><b>POR FA VOR ESPERE EL SISTEMA ESTA ENVIANDO A FINANZAS...</b></p><br /><br /><img  src="<?php print(base_url()); ?>include/imagenes/loader.gif" width="35" height="35" />');             
                                espera_repa_culmi();
                              },
                              complete:function(){
                                 $.unblockUI();//cierra mensaje de espera
                                 $("#espera_repa_culmi").empty();
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

$(".descargos").click(function(){
var html;
    html='<form id="frmdescargos" class="form-style focus-estilo" style="margin-top: 10px">';
    html+='<input type="hidden" name="id_reparo" id="id_reparo" value="'+this.id+'">';
    html+='<label>Nombre del compareciente</label>';
    html+='<input type="text" name="nom_comp" id="nom_comp" class="requerido ui-widget-content ui-corner-all">';
    html+='<label>Cargo del compareciente</label>';
    html+='<input type="text" name="carg_comp" id="carg_comp" class="requerido ui-widget-content ui-corner-all">';
    html+='<label>Fecha de comparecencia</label>';
    html+='<input type="text" name="fech_comp" id="fech_comp" class="requerido ui-widget-content ui-corner-all">';
    html+='</form>'
 $("#dialogo_envio_finanzas_legal").html(html);

    $("#dialogo_envio_finanzas_legal").dialog({
        title: "Descargos",
        buttons: {  //propiedad de dialogo, agregar botones
                Enviar: function() {
                        
                        $("#frmdescargos").submit();
                        $( this ).dialog( "close" ); 
                    }
                    ,
                cancelar: function() { 
                
                        $( this ).dialog( "close" ); 
                }

            }
    });
     $("#dialogo_envio_finanzas_legal").dialog('open');
     $( "#fech_comp" ).datepicker({
        dateFormat: "dd-mm-yy",
        dayNamesMin: [ "Do", "Lu", "Ma", "Mi", "Ju", "Vi", "Sa" ],
        monthNames: [ "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre" ],
        showAnim: "slide",
        navigationAsDateFormat: true
    });
    validador('frmdescargos','<?php echo base_url()."index.php/mod_legal/legal_c/descargos"?>','activar_descargos');

});
activar_descargos=function(form,url){

                        $.ajax({  

                              type:'post',
                              data:$("#frmdescargos").serialize(),
                              dataType:'json',
                              url:url,
                              success:function(data){

                               if(data.resultado===true){
                                   
                                   $("#tabs").tabs("load",0); 

                               }


                              },
                              beforeSend:function(){
                              
                                $("#espera_repa_culmi").html('<p><b>POR FA VOR ESPERE EL SISTEMA ESTA CEANDO EL DESCARGO...</b></p><br /><br /><img  src="<?php print(base_url()); ?>include/imagenes/loader.gif" width="35" height="35" />');             
                                espera_repa_culmi();
                              },
                              complete:function(){
                                 $.unblockUI();//cierra mensaje de espera
                                 $("#espera_repa_culmi").empty();
                              }        
                          });

}
//         $("#listar-repculm tr").removeClass('odd even')    
 ayudas('#','listar-repculm','bottom right','left top','fold','up');
        </script>
        
 <style>
/*     
     #listar-repculm tr.amarillo{ background:#FFF6A2; border-top: 1px solid #C69B53;  }
     #listar-repculm tr.verde{ background:#337E00 ;border-top: 1px solid #C69B53;color: white }
     #listar-repculm tr.rojo{ background: #E30202;border-top: 1px solid #C69B53; color: white}*/
     #listar-repculm button{ width: 20px; height: 20px;}
     </style>