
<html>
    <script type="text/javascript" charset="utf-8">
                
 $(function() {
     ayudas('#','reparos-show','bottom right','top left','fold','up');
     $("#reparos-show").hide();
     $("#detalles-reparo").hide();
     $("#error-reparo-activa").hide();
     
 });
 </script>
<div id="reparos-show"> 
<div class="ui-widget-header" style="text-align:center; font-size: 12px; font-style: italic; margin-bottom: 10px; width: 80%; margin-left: 10%">Listado de reparos en espera de aprobacion</div>

<table cellpadding="0" cellspacing="0" border="0" class="display" id="listar-reparos" >
	<thead>
		<tr>
			<th>#</th>
                        <th>Nº Acta Reparo</th>
			<th>Rif</th>
                        <th>Razon Social</th>
                        <th>Tipo contribuyente</th>
                        <th>Fecha elaboracion</th>
                        <th>Fiscal ejecutador</th>
                        <th>Operaciones</th>
                </tr>
	</thead>
	<tbody>
           <?
           
           $baseurl=base_url();
           foreach ($data as $clave => $valor) {
            $con=$clave+1;
//            $v=$valor['nombre'];
//            if($valor["bln_activo"]=='t'): $estatus='ACTIVO'; else: $estatus='INACTIVO'; endif;?>
              <tr>
                        <td><?php echo  $con ?></td>
                        <td><?php echo 'CNAC/FONPROCINE/GFT/AFR-'.$valor['nacta_reparo'] ?></td>
			<td><?php echo $valor["rif"] ?></td>
                        <td><?php echo $valor["nombre"] ?></td>
                        <td><?php echo $valor["tcontribuyente"] ?></td>    
                        <td><?php echo date('d-m-Y',strtotime($valor["felaboracion"])) ?></td>
                        <td><?php echo $valor["fiscal"] ?></td>
                        <!--<td><?php // echo $estatus ?></td>-->    
                        <td>
                        <button style=" margin-left:25px" txtayuda="Ver detalles" class=" ayuda btndetareparo" id="<?php echo $valor["id"]?>"  title=""></button>
                       
                        </td>    
                </tr>
        <?php              
           }
           ?>
           
                        
           </tbody>
         
           
         </table>

       </div>
      
 <div style="padding: 0 .7em; width: 400px; margin-top: 15px; margin-left:35%; margin-bottom: 10px" class="ui-corner-all" id="error-reparo-activa">
		
 </div>
 <div id="detalles-reparo" style=" margin-top:50px ">
     
     
 </div>
        <script>
                      
                            
        $('#listar-reparos button').button({
                           icons: {
                           primary: "ui-icon-gear"
                           },
                           text: false
                           });
        //            script para asignar atributos al listar diseñado con datatables
            oTable = $('#listar-reparos').dataTable({
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

        $('.btndetareparo').click(function(){  
                $.ajax({  

                           type:'post',
                           data:{id:this.id},
                           dataType:'json',
                           url:'<?php echo base_url()."index.php/mod_contribuyente/contribuyente_c/detalles_reparo"?>',
                           success:function(data){

                            if(data.resultado==true){

                                $("#detalles-reparo").html(data.vista);
                                $("#detalles-reparo").show("drop",{ direction: "up" }, 1000 )

                            }


                           }
                    });  

        });         

        
      $(document).ready(function() {
            $("#reparos-show").show( "blind", 1000 )
       });

        </script>
        <style>
         #listar-reparos_wrapper{ width: 100%; margin-left: 0%}
        .btndetareparo{ width: 25px; height: 25px}

        </style>
	
</html>
