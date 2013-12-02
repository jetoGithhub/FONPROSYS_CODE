

 
<div class="ui-widget-header" style="text-align:center; font-size: 12px; font-style: italic; margin-bottom: 10px; width: 80%; margin-left: 10%" > Detalles del reparo</div>

<table cellpadding="0" cellspacing="0" border="0" class="display" id="listar-detareparos" width="100%">
	<thead>
		<tr>
			<th>#</th>
                        <th>a&ntilde;io</th>
                        <th>Periodo gravable</th>
                        <th>Base imponible</th>
                        <th>Alicuota</th>
                        <th>Total a pagar</th>
                        
                </tr>
	</thead>
	<tbody>
           <?
           
           $baseurl=base_url();
           foreach ($data as $clave => $valor) {
            $con=$clave+1;
//            $v=$valor['nombre'];
               echo '<tr>
                        <td>'. $con .'</td>
                        <td>'. $valor["anio"].'</td>';
                        if($valor['tipo']==0):
                            echo'<td>'. $this->funciones_complemento->devuelve_meses_text($valor["periodo"]).'</td>';
                        endif;                           
                         if($valor['tipo']==1):
                            echo'<td>'. $this->funciones_complemento->devuelve_trimestre_text($valor["periodo"]).'</td>';
                        endif;
                         if($valor['tipo']==2):
                            echo'<td>'. $valor["anio"].'</td>';
                        endif;
			echo '<td>'. $this->funciones_complemento->devuelve_cifras_unidades_mil($valor["baseimpo"]).'</td>
                        <td>'. $valor["alicuota"].'</td>
                        <td>'. $this->funciones_complemento->devuelve_cifras_unidades_mil($valor["monto"]).'</td>    
                        
                </tr>';
//                       
           }
           ?>
            <!--<button id="'.$valor["id_usuario"].'" onclick="if(confirma() == false) return false" href="<? //=base_url()?>index.php/mod_administrador/usuarios_c/eliminar_usuario/<?//=this.id?>" title="Eliminar Usuario"></button>-->
                        
           </tbody> 
         </table>
       </div> 
        <script>
//            script para asignar atributos al listar diseñado con datatables
            oTable = $('#listar-detareparos').dataTable({
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
                            
        
        </script>
        <style>
         /*#listar_wrapper{ width: 80%; margin-left: 10%}*/
        .btndetareparo{ width: 10px; height: 15px}

        </style>
	

