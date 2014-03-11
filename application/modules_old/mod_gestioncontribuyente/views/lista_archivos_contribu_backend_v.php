<style>
     #listar-archivos_wrapper{ width: 80%; margin-left: 10%}
     .btn_elimina_archivo{ width: 30px; height: 25px;float:left;}
     .btn_descarga_archivo{ width: 30px; height: 25px;float:left;}
  

</style>

    
    <div class="ui-widget-header" style="text-align:center; font-size: 12px; font-style: italic; margin-bottom: 10px; width: 80%; margin-left: 10%">Lista de Archivos Cargados por el Contribuyente</div>
    <table cellpadding="0" cellspacing="0" border="0" class="display" id="listar-archivos" width="">
	<thead>
		<tr>
			<th>#</th>
			<th>Imagen</th>
			<th>Descripción</th>	
			<th>Fecha</th>	
			<th>Accion</th>
	</tr>
	</thead>
	<tbody>
          <?php 
           foreach ($lista_img as $clave => $valor) {
            $con=$clave+1;
            $descarga_ruta=base_url().'archivos/contribuyente/documentos_planilla/'.$valor["ruta_imagen"];
            ?>
               <tr>
                        <td><?php print($con); ?></td>
                        <td><img  src="<?php print(base_url()); ?>archivos/contribuyente/documentos_planilla/miniaturas/<?php print($valor["ruta_imagen"]); ?>" /> </td>
                        <td><?php print($valor["descripcion"]); ?></td>
                        
                        <td><?php print($valor["fecha"]); ?></td>
                        <td>
                            <a  title="Descargar" href="<?php print($descarga_ruta); ?>" class="btn_descarga_archivo" download="<?php print($descarga_ruta); ?>"></a>
                            
                        </td>

                            
                </tr>
<?php                    
           }
           ?> 
           
         </table>
         
         <table border='0' style=' width: 100%'>
			<tr>
					<td>
						<button style=' float: left' class="ayuda" id="btn_volver" onclick="boton_volver('<?php echo base_url()."index.php/mod_gestioncontribuyente/lista_contribuyentes_inactivos_c" ?>');" title="Volver">Volver</button>

					</td>
				</tr>
    </table>


<script>

        $( ".btn_descarga_archivo" ).button({
            icons: {
                primary: "ui-icon-circle-arrow-s"
            },
            text: false
        });
        
        $( '#btn_volver' ).button({
			icons: {
				primary: "ui-icon-arrowthick-1-w"
			},
			text: false
		});    
		
		   
    oTable = $('#listar-archivos').dataTable({
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
            '</select>registros',

            "sInfo": "Mostrando del _START_ a _END_ (Total: _TOTAL_ resultados)",

            "sInfoFiltered": " - filtrados de _MAX_ registros",

            "sInfoEmpty": "No hay resultados de búsqueda",

            "sZeroRecords": "No hay registros a mostrar",

            "sProcessing": "Espere, por favor...",

            "sSearch": "Buscar:"
        }
        });
        
        //funcion para el boton volver o regresar al listar de contribuyentes inactivos
		boton_volver=function(url){
			$('#muestra_cuerpo_message').load('<?php echo base_url()."index.php/mod_administrador/principal_c?padre=90"; ?>');
		}; 
</script>
<div id="confirma-eliminacion"></div>

                                    
