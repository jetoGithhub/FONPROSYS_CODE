<html>
	<head>

            <script type="text/javascript" charset="utf-8">
                
                 $(document).ready(function() {
                     
						 $( '#listar button' ).button({
							icons: {
								primary: "ui-icon-mail-closed"
							},
							text: false
							}).next().button({
								icons: {
								primary: "ui-icon ui-icon-arrowthick-1-e"
								},
							text: false
							}).next().button({
								icons: {
								primary: "ui-icon-document"
								}
						});
                      
                 });
                 

                 /* cargar vista que contiene el formulario para el envio de correos */
                 cargar_form_enviar_correo=function(url,rif){
                                
						$( '#frm_envio_correo' ).dialog(
						{
							modal: true, //inhabilitada pantalla de atras
							autoOpen: false,
							draggable: true,
							resizable: false, //evita cambiar tamaño del cuadro del mensaje
							show: "show", //efecto para abrir cuadro de mensaje
							hide: "slide", //efecto para cerrar cuadro de mensaje
							title: "Enviar Correos",
							buttons: { 
								Enviar: function() { 
									$('#form_new').submit(); 
								},
								Cancelar: function() { 
									$( this ).dialog( "close" ); 
								}
							}
						});
						
						$.ajax({
							type:"post",
							data:{ rif:rif },
							dataType:"json",
							url:url,
							success:function(data){
								if (data.resultado==true){
									$('#frm_envio_correo').html(data.vista)
									$('#frm_envio_correo').dialog('open')
								}
							}
							

						});
						
					}
					
					
					//  funcion para cargar el Controlador y ejecutar el proceso correspopndiente
					//recarga la pagina del listar de vcontribuyentes una vez que se realizan el proceso de registrar y enviar correos
					envio_form=function(form,url){
						$('#espere_enviadoc').show();
						$.ajax({
							type:"post",
							data: $("#"+form).serialize(),
							dataType:"json",
							url:url,
							success:function(data){
								if (data.resultado==true){
                                                                        $('#espere_enviadoc').hide();    
                                                                        $('#espere_enviadoc').empty(); 
									
									$('#espere_enviadoc').html('<center><p>El correo electronico fue enviado exitosamente</p></center>');
									$('#espere_enviadoc').addClass('ui-widget-content ui-corner-all')
                                                                        $('#espere_enviadoc').show('slide',{direction:'left'});
                                                                        
                                                                        setTimeout(function(){
                                                                            $('#frm_envio_correo').dialog('close');
                                                                            $("#tabs").tabs("load",0);
                                                                            $('#espere_enviadoc').hide();    
                                                                            $('#espere_enviadoc').empty();
                                                                        },2000);
//									$('#muestra_cuerpo_message').load('<?php // echo base_url()."index.php/mod_administrador/principal_c?padre=159"; ?>')
								}
							}

						});
						
					}
					
					
					/*carga alert de confirmacion si desea activar el contribuyente*/

				ventana_confirmacion=function(url,id_usuario){
					
				  
					$( "#ventana-dialog" ).dialog({   
							resizable: false,
							show:"clip",
							modal: true,
							buttons: {
								"SI": function() {
										$( this ).dialog( "close" );

										$.ajax({
										type:"post",
										data:{ id_usuario:id_usuario },
										dataType:"json",
										url:url,
										global : false,
											success:function(data){

												if(data.resultado=='true'){    
														
														alert('El contribuyente fue activado correctamente')
														$('#muestra_cuerpo_message').load('<?php echo base_url()."index.php/mod_administrador/principal_c?padre=90"; ?>')
														
												}
											}
										});// fin del ajax
									

									},
								"NO": function() {
									$( this ).dialog( "close" );
									
									
								}
								
							}
							
						});
				//                
					$('#ventana-dialog').html('<span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 0px 0;"></span><b>SEGURO DESEA ACTIVAR ESTE CONTRIBUYENTE..?</b>')
					$("#ventana-dialog").dialog('open');
					
				}
					

            </script>
            
	</head>
<div class="ui-widget-header" style="text-align:center; font-size: 12px; font-style: italic; margin-bottom: 10px; width: 80%; margin-left: 10%">Listado de Contribuyentes Pendientes por Documentos</div>

<table cellpadding="0" cellspacing="0" border="0" class="display" id="listar" width="100%">
	<thead>
		<tr>
			<th>#</th>
			<th>RIF</th>
			<th>Razón Social</th>			
			<th>Opciones</th>
	</tr>
	</thead>
	<tbody>
           <?
           $baseurl=base_url();
           foreach ($data as $clave => $valor) {
            $con=$clave+1;
            $v=$valor['nombre'];
               echo '<tr>
                        <td>'. $con .'</td>
						<td>'. $valor["rif"].'</td>
                        <td>'. $valor["nombre"].'</td>
			
                        <td>';?>
							<button class="ayuda btnverdatos" id="<?php echo 'a'.$valor['rif'] ?>" onclick="cargar_form_enviar_correo('<?php echo $baseurl."index.php/mod_gestioncontribuyente/envio_correos_c/form_envio_correos" ?>','<?php echo $valor['rif']?>')" title="Enviar Correo"></button>

						<?php
							echo '
							
							<button class="ayuda btnverdatos" id="'.$valor["rif"].'" onclick="cargar_listar_correos_enviados('."'".$baseurl.'index.php/mod_gestioncontribuyente/envio_correos_c/listar_correos_enviados'."'".',this.id)" title="Ver Correos Enviados"></button>
							
							<button class="ayuda btnverdatos" id="'.$valor["id_usuario"].'" onclick="ventana_confirmacion('."'".$baseurl.'index.php/mod_gestioncontribuyente/buscar_planilla_c/activar_contribuyente'."'".',this.id)" title="Activar Contribuyente"></button>
							
						</td>

                    </tr>';

           }
           ?>
            
           </tbody> 
         </table>
         
        <!-- <button class="ayuda" id="a'.$valor["rif"].'" onclick="cargar_form_enviar_correo('."'".$baseurl.'index.php/mod_gestioncontribuyente/envio_correos_c/form_envio_correos'."'".','.$valor["rif"].')" title="Enviar Correo">
		</button>-->
        <!-- espacio para cargar la vista que contiene el formulario para el envio de correos-->
            <div id="frm_envio_correo"> 
            
            </div>
            
            <!-- espacio para cargar el alert para la activacion del contribuyente-->
            <div id="ventana-dialog" title="Mensaje Webmaster "></div>
        
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

                                            "sZeroRecords": "No hay registros a mostrar",

                                            "sProcessing": "Espere, por favor...",

                                            "sSearch": "Buscar:"

                                            }
				});
				
				cargar_listar_correos_enviados=function(url,valor){
                                    
					//alert(url+'?rif='+valor)
					$('#a0').attr('href',url+'/'+valor);                    
					$(".tabs-cine").tabs("load",0);

				}
                                
        </script>
        <style>
         /*#listar_wrapper{ width: 80%; margin-left: 10%}*/
        .btnverdatos{ width: 30px; height: 25px}

        </style>
	
</html>
