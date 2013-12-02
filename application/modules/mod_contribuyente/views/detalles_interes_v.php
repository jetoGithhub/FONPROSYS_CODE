<?php

?>


<div class="ui-widget-header" style="text-align:center; font-size: 12px; font-style: italic; margin-bottom: 10px; width: 80%; margin-left: 10%" > Detalles del calculo de los intereses por mes</div>

<table cellpadding="0" cellspacing="0" border="0" class="display" id="<?php echo 'linteres'.$id?>" >
	<thead>
		<tr>
			<th>#</th>
                        <th>a&ntilde;io</th>                        
                        <th>Mes</th>
                        <th>Dias</th>
                        <th>Tasa  BCV</th>
                        <th>Sub total</th>
               </tr>
	</thead>
	<tbody>
           <?
           
           $baseurl=base_url();
           foreach ($dinteres as $clave => $valor) {
            $con=$clave+1;
//            $v=$valor['nombre'];
               echo '<tr>
                        <td>'. $con .'</td>
                        <td>'. $valor["anio"].'</td>
                        <td>'. $this->funciones_complemento->devuelve_meses_text($valor["mes"]).'</td>    
                        <td>'. $valor["dias"].'</td>
                        <td>'. $valor["tasa"].'</td>
                        <td>'. $valor["intereses"].'</td>                        
                        
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
            oTable = $('#<?php echo 'linteres'.$id?>').dataTable({
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
        
