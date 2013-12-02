


<script>
     $(function() {
        $( "#botonera-actas button" ).button({
            icons: {
            primary: "ui-icon-arrowreturnthick-1-w"
            }
            }).next().button({
            icons: {
            primary: "ui-icon-document"
            }
            }).next().button({
            icons: {
            primary: "ui-icon-document"
            }
            }).next().button({
            icons: {
            primary: "ui-icon-document"
            }
        });
});

$(".btnvolver").click(function(){
     $("#detalles-asignacion-omisos").hide('slide',{ direction: "up" },500)
     $("#asignaciones-show").show('drop',{ direction: "left" },1500)
});
genera_actas=function(id,tipocont,nroaut,tactas){
        
        window.open('<?php echo base_url()."index.php/mod_gestioncontribuyente/fiscalizacion_c/actas_fiscalizacion?id="?>'+id+"&tipocont="+tipocont+"&nro_autorizacion="+nroaut+"&tipo_acta="+tactas);
}
    
</script>
<style>
    #botonera-actas{
        position: relative;
        float: right;
            
    }
    #botonera-actas button{
        width:auto;
        height: 25px;
        
            
    }    
    </style>
<? //print($nro_autorizacion) ?>
<br />
<b>Contribuyente: </b><? print($datos_usuario[0]['nombre']); ?><br/>
<b>Rif: </b><? print($datos_usuario[0]['rif']); ?><br/>
<b>Email: </b><? print($datos_usuario[0]['email']); ?><br/>
<b>Tipo Contribuyente: </b><? print($nombre_tipocont); ?><br/>

<div id="botonera-actas">
    <button class="btnvolver">Volver</button>
    <button id="btn_autfiscal" onclick="genera_actas(<?php echo $datos_usuario[0]['id']?>,<?php echo $idtipocont?>,'<?php echo $nro_autorizacion?>',1)" >Aut. fiscal</button>
    <button id="btn_actareque" onclick="genera_actas(<?php echo $datos_usuario[0]['id']?>,<?php echo $idtipocont?>,'<?php echo $nro_autorizacion?>',2)">Acta Reque</button>
    <button id="btn_actarecep" onclick="genera_actas(<?php echo $datos_usuario[0]['id']?>,<?php echo $idtipocont?>,'<?php echo $nro_autorizacion?>',3)">Acta Recep</button>
</div>

<br/><br/><br/> <b>PERIODOS OMISOS</b><br/><br/>
<table cellpadding="0" cellspacing="0" border="0" class="display listar" width="100%">
	<thead>
		<tr>
			<th>#</th>
			<th>Fecha Incio</th>
                        <th>Fecha fin</th>
                        <th>Fecha Limite</th>
                        <th>A&ntilde;io</th>
                        <th>Periodo</th>
                        <th>Nombre del Periodo gravable</th>
                </tr>
	</thead>
	<tbody>
           <?if(!empty($omisos)):
                foreach ($omisos as $clave => $valor) {
                 $con=$clave+1;
                 $v=$valor['nombre'];
                    echo '<tr>
                             <td>'. $con .'</td>
                             <td>'. $valor["fechaini"].'</td>
                             <td>'. $valor["fechafin"].'</td>
                             <td>'. $valor["fechalim"].'</td>
                             <td>'. $valor["ano"].'</td>';
                             if($tipo==0):
                                 echo '<td>'. $this->funciones_complemento->devuelve_meses_text($valor["periodo"]).'</td>';
                             endif;
                             if($tipo==1):
                                 echo '<td>'. $this->funciones_complemento->devuelve_trimestre_text($valor["periodo"]).'</td>';
                             endif;
                             if($tipo==2):
                                 echo '<td>'. $valor["ano"].'</td>';
                             endif;
                             echo '<td>'. $valor["nombre"].'</td>    
                             </tr>';     

                }
            endif;
           ?>
           
        </tbody>  
         </table>
<br />
<?php if(!empty($omisos_declara)):?>
<br/><br/><br/> <b>PERIODOS OMISOS DECLARADOS</b><br/><br/>
<table cellpadding="0" cellspacing="0" border="0" class="display listar" width="100%">
	<thead>
		<tr>
			<th>#</th>
			<th>Fecha Incio</th>
                        <th>Fecha fin</th>
                        <th>Fecha Limite</th>
                        <th>A&ntilde;io</th>
                        <th >Periodo</th>
                        <th>Nombre del Periodo gravable</th>
                </tr>
	</thead>
	<tbody>
           <?php
                foreach ($omisos_declara as $clave2 => $valor2) {
                 $con2=$clave2+1;
                 $v=$valor['nombre'];
                    echo '<tr>
                             <td>'. $con2 .'</td>
                             <td>'. $valor2["fechaini"].'</td>
                             <td>'. $valor2["fechafin"].'</td>
                             <td>'. $valor2["fechalim"].'</td>
                             <td>'. $valor2["ano"].'</td>
                             <td>'. $valor2["periodo"].'</td>
                             <td>'. $valor2["nombre"].'</td>    
                             </tr>';     

                }
            
           ?>
           
        </tbody>  
         </table>
 <?php endif;?>
<script>
//            script para asignar atributos al listar diseñado con datatables
oTable = $('.listar').dataTable({
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