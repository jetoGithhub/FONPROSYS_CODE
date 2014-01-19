<?php

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
?>
 <script>
    $(function() {
          

    });

//            script para asignar atributos al listar diseñado con datatables
            oTable = $('#listado_conciliados').dataTable({
					"bJQueryUI": true,
//					"sPaginationType": "full_numbers",
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
 <!--botones generar excel y pdf--> 
 <?php 
 if(!empty($datos)):
 ?>
<div class="botonera_reportes" style="float: right">
<!--    <button id="btn_pdf" class="btn_reportes">
        <img src="<? // echo base_url().'include/imagenes/iconos/ic_pdf.png'?>" width="14px" height="12px"/>
        <b>PDF</b>
    </button>-->
    <button id="btn_excel_conciliados" class="btn_reportes">
        <img src="<? echo base_url().'include/imagenes/iconos/ic_excel.png'?>" width="14px" height="12px"/>
        <b>Generar Excel</b>
    </button>
</div>
<?php endif;?> 
<table cellpadding="0" cellspacing="0" border="0" class="" id="listado_conciliados" width="100%">
	<thead>
            <tr>
               <th>#</th>
               <th>Rif</th>
                <th>Contribuyente</th> 
                <th>Tipo Contribuyente</th> 
                <th>Periodo</th> 
                <!--<td>Estado</td>-->
                <th>Cobrada</th>

            </tr>
        </thead>
	<tbody>
           <?
           $baseurl=base_url();
           if(!empty($datos)):
                foreach ($datos as $clave => $valor) {
               $con=$clave+1;
               echo '<tr >
                          <td class="numero" >'. $con.'</td>
                                <td>'. $valor["rif"].'</td>
                                    <td>'. $valor["contribuyente"].'</td>
                                        <td>'. $valor["nombre_tcon"].'</td>';
                                            if( $valor["tipe"]==0):
                                                echo'<td>'. $this->funciones_complemento->devuelve_meses_text($valor["periodo"]).'</td>';
                                            endif;
                                             if( $valor["tipe"]==1):
                                                echo'<td>'. $this->funciones_complemento->devuelve_trimestre_text($valor["periodo"]).'</td>';
                                            endif;
                                             if( $valor["tipe"]==2):
                                                echo'<td>'.$valor["periodo"].'</td>';
                                            endif;
//                                            if($valor['estado']=='omiso1'){
//                                              
//                                                echo '<td>Omiso no Decl</td>';
//                                            
//                                            }else if($valor['estado']=='omiso2'){
//                                                echo '<td>Omiso Declarado</td>';
//                                            }else{
//                                                 
//                                                echo '<td>'. $valor["estado"].'</td>';
//                                            }
                                            echo '<td>'. $valor["cobrada"].'</td>
                                                        


                     </tr>';
                }
          endif;
          ?>
          </tbody>  
            
         </table>


<style>
    #listado_conciliados td{
        height: 25px;
        padding: 5px;
        border-left: 1px solid #EEEEEE;
            
    }   
    .numero{
        
        width: 25px;
        text-align: center;
    }
    .botonera_reportes button{
      color:#000;
                        
    }
    #btn_excel{
        padding: 2px;
    }
</style>
<script>

$("#btn_excel_conciliados").click(function(){
   
    var tipo;
    $("#table-busqueda-rise input[type=radio]").each(function(i) { 
        if($(this).is(':checked')){
             tipo=$(this).val();
       }

    });
//    alert($("#busca_rise").serialize()+'&tipo='+tipo);
   window.location='<?php echo base_url()."index.php/mod_reportes/reportes_recaudacion_c/generar_reporte_rise?"?>'+$("#busca_rise").serialize()+'&tipo='+tipo;
});


</script>