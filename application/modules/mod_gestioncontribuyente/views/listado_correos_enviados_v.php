<html>
	<head>

            <script type="text/javascript" charset="utf-8">
                
                 $(document).ready(function() {
                     
						 $( '#listar button' ).button({
							icons: {
								primary: "ui-icon-mail-open"
							},
							text: false
						});
						
						$( '#btn_volver' ).button({
							icons: {
								primary: "ui-icon-arrowthick-1-w"
							},
							text: false
						});
                       
                 });
                 
                 /* cargar vista que contiene informacion especifica del correo seleccionado - solo con el boton cancelar, 
                 debido a que ya fue procesado */
                 ver_correo=function(url,id){
					 
						$( '#frm_ver_correo' ).dialog(
						{
							modal: true, //inhabilitada pantalla de atras
							autoOpen: false,
							draggable: true,
							resizable: false, //evita cambiar tamaño del cuadro del mensaje
							show: "show", //efecto para abrir cuadro de mensaje
							hide: "slide", //efecto para cerrar cuadro de mensaje
							title: "Ver-Procesar Correos",
							buttons: { 
								Cancelar: function() { 
									$( this ).dialog( "close" ); 
								}
							}
						});
						
					
						$.ajax({
							type:"post",
							data:{ id:id },
							dataType:"json",
							url:url,
							success:function(data){
								if (data.resultado==true){
									$('#frm_ver_correo').html(data.vista)
									$('#frm_ver_correo').dialog('open')
								}
							},
                                                        error: function (request, status, error) {

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
					
					
/*
					cargar dialog con dos botones, procesar y cancelar, en este caso se le da la opcion de procesar
					el correo, debido a que este nunca ha sido procesado
*/

					procesar_correo=function(url,id){
					 
						$( '#frm_procesar_correo' ).dialog(
						{
							modal: true, //inhabilitada pantalla de atras
							autoOpen: false,
							draggable: true,
							resizable: false, //evita cambiar tamaño del cuadro del mensaje
							show: "show", //efecto para abrir cuadro de mensaje
							hide: "slide", //efecto para cerrar cuadro de mensaje
							title: "Ver-Procesar Correos",
							buttons: { 
								Procesar: function() { 
									$('#form_procesar_ver').submit(); 
								},
								Cancelar: function() { 
									$( this ).dialog( "close" ); 
								}
							}
						});
						
					
						$.ajax({
							type:"post",
							data:{ id:id },
							dataType:"json",
							url:url,
							success:function(data){
								if (data.resultado==true){
									$('#frm_procesar_correo').html(data.vista)
									$('#frm_procesar_correo').dialog('open')
								}
							},
                                                        error: function (request, status, error) {

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


					//  funcion para cargar el Controlador y ejecutar el proceso correspopndiente
					//recarga la pagina del listar de vcontribuyentes una vez que se realizan el proceso de registrar y enviar correos

					procesar_form=function(form,url){
						
						$.ajax({
							type:"post",
							data: $("#"+form).serialize(),
							dataType:"json",
							url:url,
							success:function(data){
								if (data.resultado){
									$('#frm_procesar_correo').dialog('close')
									alert('El correo electronico fue procesado exitosamente')
									$('#muestra_cuerpo_message').load('<?php echo base_url()."index.php/mod_administrador/principal_c?padre=159"; ?>')
								}
							},
                                                        error: function (request, status, error) {

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

					
					
					//funcion para el boton volver o regresar al listar de contribuyentes
					boton_volver=function(url){
                                        $('#muestra_cuerpo_message').load('<?php echo base_url()."index.php/mod_administrador/principal_c?padre=159"; ?>');
//						$( "#frm_regresar_correo" ).dialog(
//						{
//							modal: true, //inhabilitada pantalla de atras
//							autoOpen: false,
//							draggable: true,
//							width: 350,
//							resizable: false, //evita cambiar tamaño del cuadro del mensaje
//							show: "show", //efecto para abrir cuadro de mensaje
//							hide: "slide", //efecto para cerrar cuadro de mensaje
//							title: "Correos Electronicos",
//							buttons: {
//								"SI": function() {
//									$( this ).dialog( "close" );
//									$.ajax({
//										type:"post",
//										data:{ },
//										url:url,
//										success:function(data){
//											$('#muestra_cuerpo_message').load('<?php echo base_url()."index.php/mod_administrador/principal_c?padre=169"; ?>')
//							   
//										}
//									});
//
//									},
//
//								"NO": function() {
//										$( this ).dialog( "close" );
//								}
//						  }


//					});
//					//mensaje que mostrara en el dialog de alerta o confirmacion
//					$( "#frm_regresar_correo" ).html('<h3>¿Desea volver?</h3>')
//					$( "#frm_regresar_correo" ).dialog('open')
					
			};
                 

            </script>
            
	</head>
<div class="ui-widget-header" style="text-align:center; font-size: 12px; font-style: italic; margin-bottom: 10px; width: 80%; margin-left: 10%">Listado Correos Enviados</div>

<!--<div>
	<button class="ayuda" id="btn_volver" onclick="boton_volver('<?php // echo base_url()."index.php/mod_gestioncontribuyente/envio_correos_c/volver_listar_contribu" ?>')" title="Volver">Volver</button>
</div>-->

<table cellpadding="0" cellspacing="0" border="0" class="display" id="listar" width="100%">
	<thead>
		<tr>
			<th>#</th>
			<th>Asunto</th>
			<th>Fecha</th>			
			<th>Operaciones</th>
			<th>Status</th>
        </tr>
	</thead>
	<tbody>
           <?
           $baseurl=base_url();
           
           foreach ($data as $clave => $valor) {
					$con=$clave+1;
					$v=$valor['asunto_enviar'];
					   echo '<tr>
								<td>'. $con .'</td>
								<td>'. $valor["asunto_enviar"].'</td>
								<td>'. $valor["fecha_envio"].'</td>
					
								 <td>';
								 if($valor["procesado"]=='t')
								 { ?>
									<button class="ayuda" id="<?php echo 'a'.$valor['id'] ?>" onclick="ver_correo('<?php echo $baseurl."index.php/mod_gestioncontribuyente/envio_correos_c/cargar_ver_correos" ?>','<?php echo $valor['id']?>')" title="Ver Correo"></button>
									
								 <?php 
								  } else if($valor["procesado"]=='f')
								  {
								?>
									<button class="ayuda" id="<?php echo 'a'.$valor['id'] ?>" onclick="procesar_correo('<?php echo $baseurl."index.php/mod_gestioncontribuyente/envio_correos_c/cargar_ver_correos" ?>','<?php echo $valor['id']?>')" title="Ver Correo"></button>
									
								 
								<?php
								   }
									echo '</td>
									
									<td>';
									
									if($valor["procesado"]=='t')
									{ ?>
										<img class="ayuda" src="<? echo base_url().'include/imagenes/iconos/check_procesado.png'?>" title="Procesado" />
								<?php 
									} else if($valor["procesado"]=='f')
									{
								?>
										<img class="ayuda" src="<? echo base_url().'include/imagenes/reloj.png'?>" width="20px" height="18px" title="Sin Procesar"/>
								<?php
									}
									echo '</td></tr>';
									

				   }
				
           ?>
            
   </tbody> 
</table>
<table border='0' style=' width: 100%'>
    <tr>
        <td>
            	<button style=' float: left' class="ayuda" id="btn_volver" onclick="boton_volver('<?php echo base_url()."index.php/mod_gestioncontribuyente/envio_correos_c/volver_listar_contribu" ?>');" title="Volver">Volver</button>

            </td>
        </tr>
    </table>
         
        <!-- <button class="ayuda" id="a'.$valor["rif"].'" onclick="cargar_form_enviar_correo('."'".$baseurl.'index.php/mod_gestioncontribuyente/envio_correos_c/form_envio_correos'."'".','.$valor["rif"].')" title="Enviar Correo">
		</button>-->
        <!-- espacio para cargar la vista que contiene el formulario para el envio de correos-->
            <div id="frm_ver_correo"> 
            
            </div>
            
            <div id="frm_procesar_correo"> 
            
            </div>
            
            <div id="frm_regresar_correo"> 
            
            </div>
            
            
        <script>
            oTable = $('#listar').dataTable({
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

                                            "sZeroRecords": "NO SE HAN REALIZADO ENVIO DE CORREOS AL CONTRIBUYENTE SELECCIONADO",

                                            "sProcessing": "Espere, por favor...",

                                            "sSearch": "Buscar:"

                                            }
				});
                                
        </script>
        <style>
         /*#listar_wrapper{ width: 80%; margin-left: 10%}*/
        .btnverdatos{ width: 30px; height: 25px}

        </style>
	
</html>
