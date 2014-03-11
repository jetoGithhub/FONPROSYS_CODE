<br /><br />
<div class="ui-widget-header" style="text-align:center; font-size: 12px; font-style: italic; margin-bottom: 10px; margin-left: 10%; width: 80%; ">Tipos de contribueyentes asociados al registro</div>

<table cellpadding="0" cellspacing="0" border="0" class="display" id="listar-tcontribu" width="">
	<thead>
		<tr>
			<th>#</th>
			<th>Tipo de contribuyente</th>
                        <th>Fecha de creacion</th>	
                        	
                </tr>
	</thead>
	<tbody>
           <?php
           if(is_array($data)):
                $con=0;
                $baseurl=base_url();

                foreach ($data as $clave => $valor) {
                 $con=$clave+1;        
                    print('<tr>
                             <td>'. $con .'</td>
                             <td>'. $valor["tcontribu"].'</td>
                             <td>'. $valor["felab"].'</td>
                           </tr>');

                }
            endif;
           ?>
            
                        
         </tbody>
         </table>
         <button type="button" id="btn_agrega_tcontribu" title="" style="width:70px; height:30px; margin-left: 82%" onclick="cargar_vista_guarda_tcontribu('<?php echo base_url().'index.php/mod_contribuyente/tipo_contribuyente_c/carga_formulario_ingreso_tcontribu';?>',this.id,1,'frmtcontribu');">Agregar</button>
            <div id="frmtcontribu"> 
                
            
            </div>
        <script>
//            script para asignar atributos al listar diseñado con datatables
            oTable = $('#listar-tcontribu').dataTable({
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
                              $('#btn_agrega_tcontribu').button(
                                {
                                    icons: 
                                        {
                                            primary: "ui-icon-plusthick"
                                        },
                                    text: true
                                });
                                
                                
cargar_vista_guarda_tcontribu=function(url,id,ident,div){

//alert(id_div)

    $( "#"+div ).dialog(
    {
        autoOpen:false,
        height: 300,
        width: 350,
        resizable: false,
        title: "Carga de tipo contribuyente" ,
        show:"clip",
        modal: true,
        buttons: {  //propiedad de dialogo, agregar botones
            Guardar: function() { 
                //llamado del formulario, en este caso #form_new corresponde al id del form(en los archivos de las vistas)
                $('#frmtcontribu').submit(); 



            },
            Cancelar: function() { 
                $("#"+div).dialog( "close" ); 
            }
        }
    });

    $.ajax({
        type:"post",
        data:{ id:id,identificador:ident },
        dataType:"json",
        url:url,
        success:function(data){
            if (data.resultado){
                $("#"+div).html(data.vista)
                $("#"+div).dialog('open')
            }
        }


    });

}
   
                                
                               
        </script>
        <style>
         #listar-tcontribu_wrapper{ width: 80%;margin-left: 10% }
       
        #listar-tcontribu_wrapper .odd{background:#ECECEC}
       
        </style>
	
