<div class="ui-widget-header" style="text-align:center; font-size: 12px; font-style: italic; margin-bottom: 10px; width: 80%; margin-left: 10%" > Detalles del reparo</div>

<table cellpadding="0" cellspacing="0" border="0" class="display" id="listar-detareparos" >
	<thead>
		<tr>
			<th>#</th>
                        <th>a&ntilde;io</th>
                        <th>Periodo gravable</th>
                        <th>Base imponible</th>
                        <th>Alicuota</th>
                        <th>Total a pagar</th>
                        <th>Planilla</th>
                </tr>
	</thead>
	<tbody>
           <?
           
           $baseurl=base_url();
           foreach ($data as $clave => $valor) {
            $con=$clave+1;
//            $v=$valor['nombre'];
               echo '<tr>
                        <td>'.$con.'</td>
                        <td>'. $valor["anio"].'</td>
                        <td>';
                            if($valor['periodo_gravable']==0):
                               echo $this->funciones_complemento->devuelve_meses_text($valor["periodo"]); 
                            endif;
                             if($valor['periodo_gravable']==1):
                               echo $this->funciones_complemento->devuelve_trimestre_text($valor["periodo"]);
                             endif;
                            if($valor['periodo_gravable']==2):
                               echo $valor["anio"];
                            endif;
                       echo '</td>
                        <td>'. $this->funciones_complemento->devuelve_cifras_unidades_mil($valor["baseimpo"]).'</td>
                         <td>'. $valor["alicuota"].'</td>
                         <td>'. $this->funciones_complemento->devuelve_cifras_unidades_mil($valor["monto"]).'</td>
                        <td>
                         <button  style=" margin: 10px " class="btn_imprplani" id="'. $valor["id"].'"  title="">Imprimir</button>
                       
                        </td>  
                        
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
                                $(".btn_imprplani").button({
                                    icons: {
                                    primary: "ui-icon-print"
                                    }
                                    });
                            $(".btn_imprplani").click(function() {
                              
                                window.open('<?php echo base_url()."index.php/mod_contribuyente/contribuyente_c/imprime_declaracion/?id_declara="?>'+this.id); 
                            }); 
        
        </script>
        <style>
         #listar_wrapper{ width: 100%; margin-left: 0%}
        .btndetareparo{ width: 10px; height: 15px}

        </style>
	

