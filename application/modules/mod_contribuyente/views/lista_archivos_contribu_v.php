<style>
     #listar-archivos_wrapper{ width: 80%; margin-left: 10%}
     .btn_elimina_archivo{ width: 30px; height: 25px;float:left;}
     .btn_descarga_archivo{ width: 30px; height: 25px;float:left;}
  

</style>

    
    <div class="ui-widget-header" style="text-align:center; font-size: 12px; font-style: italic; margin-bottom: 10px; width: 80%; margin-left: 10%">Lista de Archivos Cargados</div>
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
                            <button title="Eliminar" id="<?php print($valor["id"]); ?>" class="btn_elimina_archivo" onclick="elimina_archivo_img(this.id,'<?php print(base_url()); ?>index.php/mod_contribuyente/filecontroller/archivo_elimina/')"></button>
                            
                           
                        </td>

                            
                </tr>
<?php                    
           }
           ?> 
           
         </table>


<script>
        $( "#confirma-eliminacion" ).dialog({
                           autoOpen: false, 
                resizable: false,
                modal: true
        } );       elimina_archivo_img= function(id,url){
            $( "#confirma-eliminacion" ).dialog('open').dialog({       


                
                buttons: {
                    "SI": function() {
                        $( this ).dialog( "close" );
                        $.ajax({
                            type:"post",
                            data:{id:id},
                            dataType:"json",
                            url:url+id,
                            success:function(data){
                                if (data.success){
                                    $("#trae_datos").load(
                                    "<?php print(base_url()); ?>index.php/mod_contribuyente/filecontroller/lista_documentos", 
                                    function(response, status, xhr) {
                                        if (status == "error") {
                                            var msg = "ERROR AL CONECTAR AL SERVIDOR:";                                        
//                                            $("#dialog-alert")
//                                            .children("#dialog-alert_message")
//                                            .html(msg + xhr.status + " " + xhr.statusText);
//                                            $("#dialog-alert").dialog("open");
                                            }});    
                                    }else{
                

                                    }
                        },
                        error:function(o,estado,excepcion){
                        if(excepcion=='Not Found'){
                        }else{
                    
                        }
                    }});

                        },
                    "NO": function() {
                        $( this ).dialog( "close" );
                        }
                    }
                }).html('<h3>Procedera Eliminar el archivo. ¿Desea continuar?</h3>');          

        }
        $( ".btn_elimina_archivo" ).button({
            icons: {
                primary: "ui-icon-closethick"
            },
            text: false
        });
        $( ".btn_descarga_archivo" ).button({
            icons: {
                primary: "ui-icon-circle-arrow-s"
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
</script>
<div id="confirma-eliminacion"></div>

                                    