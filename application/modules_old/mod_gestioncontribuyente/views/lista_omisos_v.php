<html>
	<head>

            <script type="text/javascript" charset="utf-8">
                
                 $(function() {
                     
                     
                       
                 });
                 
            </script>
            
	</head>
<div class="ui-widget-header" style="text-align:center; font-size: 12px; font-style: italic; margin-bottom: 10px; width: 80%; margin-left: 10%">listado de contribuyentes en espera de activacion de registro</div>

<table cellpadding="0" cellspacing="0" border="0" class="display" id="listar" width="100%">
	<thead>
		<tr>
			<th>#</th>
			<th>Numero de Rif</th>
                        <th>Razon Social</th>			
                        <th>Operaciones</th>
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
			
                        <td><button class="btnverdatos" id="'.$valor["rif"].'" onclick="busca_planilla('."'".$baseurl.'index.php/mod_gestioncontribuyente/lista_contribuyentes_inactivos_c/buscar_planilla'."'".',this.id)" title=""></button></td>
                            
                </tr>';
//                       
           }
           ?>
            <!--<button id="'.$valor["id_usuario"].'" onclick="if(confirma() == false) return false" href="<? //=base_url()?>index.php/mod_administrador/usuarios_c/eliminar_usuario/<?//=this.id?>" title="Eliminar Usuario"></button>-->
                        
           </tbody> 
         </table>
        
        <script>
//            script para asignar atributos al listar diseñado con datatables
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
                                
                                 $( ".btnverdatos" ).button({
                                icons: {
                                primary: "ui-icon-document"
                                },
                                text: false
                                })
                                
                                busca_planilla=function(url,valor){
                                    
                                    //alert(url+'?rif='+valor)
                                    $('#a0').attr('href',url+'/'+valor);                    
                                    $(".tabs-cine").tabs("load",0);

                                }
        </script>
        <style>
         #listar_wrapper{ width: 80%; margin-left: 10%}
        .btnverdatos{ width: 30px; height: 25px}

        </style>
	
</html>