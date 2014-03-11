<?php // print_r($data) ?>


<html>
	
<div class="ui-widget-header" style="text-align:center; font-size: 12px; font-style: italic; margin-bottom: 10px; width: 80%; margin-left: 10%">Detalles de la operacion</div>
<table cellpadding="0" cellspacing="0" border="0" class="display" id="listar-detalles-calculos-recau" width="100%">
	<thead>
		<tr>
			<th>#</th>
			<th>Numero de Rif</th>
                        <th>Razon Social</th>
                        <th>Tipo de Contribuyente</th>
                        <th>A&ntilde;io</th>
                        <th>periodo</th>
                        <?php if($estatus!='enviado'):?>
                        <th>Fecha de elaboracion</th>
                        <th>Monto a pagar</th>
                        <?php endif;?>
                        <th>Estado</th>
                        
                </tr>
	</thead>
	<tbody>
           <?
           foreach ($data as $clave => $valor) {
            $con=$clave+1;
            $v=$valor['nombre'];
               echo '<tr>
                        <td>'. $con .'</td>
			<td>'. $valor["rif"].'</td>
                        <td>'. $valor["nombre"].'</td>
                        <td>'. $valor["nomb_tcont"].'</td>
                        <td>'. $valor["ano_calpago"].'</td>
                        <td>'. $valor["periodo"].'</td>';
                     ;
                  if($estatus!='enviado'):
                      
                      echo'<td>'. $valor["fechaelaboracion"].'</td>
                           <td>'. $valor["monto"].'</td>                           
                           <td>'. $estatus.'</td>    
                       </tr>';
                   else:
                       echo '<td>'. $estatus.'</td></tr>';
                   endif;
                   
           }
           ?>
           
        </tbody>  
         </table>
     

<!--<button id="btn-frmcontras" style="width:100px; height: 25px; margin-top:-10px; margin-left: 20px; position: relative" title="">Actualizar</button><br /><br /></center>-->


        <script>
//            script para asignar atributos al listar diseñado con datatables
            oTable = $('#listar-detalles-calculos-recau').dataTable({
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
	
</html>