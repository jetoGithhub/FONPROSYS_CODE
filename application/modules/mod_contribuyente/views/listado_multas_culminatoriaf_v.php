
<html>
    <script type="text/javascript" charset="utf-8">
                
 $(function() {
     
//     $("#multasculmf-show").hide();
     $("#detalles-multasculmf").hide();
     $("#error-reparo-activa").hide();
     
 });
 </script>
<div id="multasculmf-show"> 
<div class="ui-widget-header" style="text-align:center; font-size: 12px; font-style: italic; margin-bottom: 10px; width: 80%; margin-left: 10%">Listado de Multas por Culminatoria de Fizcalizacion</div>

<table cellpadding="0" cellspacing="0" border="0" class="display" id="listar-multasculmf" >
	<thead>
		<tr>
			<th>#</th>
                        <th>Nº de Resolucion</th>
			<th>Tipo contribuyente</th>
                        <th>Fecha elaboracion</th>
                        <th>Total Multa</th>
                        <th>Total Interes</th>
                        <th>A&ntilde;o</th>
                        <!--<th>Periodo</th>-->
                        <th>Detalles</th>
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
                        <td><?php echo 'CNAC/RCF-'.$valor["resol_multa"] ?></td>
			<td><?php echo $valor["nombre"] ?></td>
                        <td><?php echo date('d-m-Y',strtotime($valor["fechaelaboracion"])) ?></td>
                        <td><?php echo $this->funciones_complemento->devuelve_cifras_unidades_mil(round($valor["multa_pagar"],2)) ?></td> 
                        <td><?php echo $this->funciones_complemento->devuelve_cifras_unidades_mil(round($valor['interes_pagar'],2))?></td> 
                        <td><?php echo $valor["periodo_afiscalizar"] ?></td> 
                        <!--<td><?php // echo $valor["periodo"] ?></td>-->                           
                        <td>
                       <button style=" margin-left:25px" class="btndetamultarepf"  id="<?php echo $valor["idreparo"]?>"  title=""></button>
                       <!--<button style="" class="btninteres" onClick="detalles_interes_reparof(<?php // echo $valor["idinteres"]?>);" id="i-<?php // echo $valor["idinteres"]?>"  title="">Det. Interes</button>-->

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
 <div id="detalles-multasculmf" style=" margin-top:50px ">
     
     
 </div>
        <script>
                      
                            
       ;
           $('#listar-multasculmf button').button({
           icons: {
           primary: "ui-icon-print"
           },
           text:true
           }).next().button({
                icons: {
                primary: "ui-icon-tag"
                }
           });
        //            script para asignar atributos al listar diseñado con datatables
            oTable = $('#listar-multasculmf').dataTable({
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

        detalles_interes_reparof=function(id){  
                $.ajax({  

                           type:'post',
                           data:{id:id},
                           dataType:'json',
                           url:'<?php echo base_url()."index.php/mod_contribuyente/contribuyente_c/listado_detalle_intereses"?>',
                           success:function(data){

                            if(data.resultado==true){

                                $("#detalles-multasculmf").html(data.vista);
                                $("#detalles-multasculmf").show("drop",{ direction: "up" }, 1000 )

                            }


                           }
                    });  

        };         
        $(".btndetamultarepf").click(function() {
                  
                  location.href='<?php echo base_url()."index.php/mod_contribuyente/contribuyente_c/imprime_planilla_multa_interes/?id_multa="?>'+this.id+'&tipo=2'; 

             });
        
//      $(document).ready(function() {
//            $("#multasculmf-show").show( "blind", 1000 )
//       });

        </script>
        <style>
         #listar-multasculmf{ width: 100%; margin-left: 0%}
        .btndetamultarepf{ width: 30px; height: 30px}
        .btninteres{ width: 90px; height: 30px}

        </style>
	
</html>
