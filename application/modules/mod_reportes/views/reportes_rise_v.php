 <script>
    $(function() {
        //funcion para la validacion
        //Parametros: id del form, url del controlador, metodo ajax para el submit del boton
        validador('form_perfil','<?php echo base_url()."index.php/mod_administrador/roles_c/insertar_perfil"; ?>','envio_form');
        //funcion para el cambio de estilo de los radiobutton
      

    });

//            script para asignar atributos al listar diseñado con datatables
            oTable = $('#reportes-rise').dataTable({
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
    <button id="btn_excel_rise" class="btn_reportes">
        <img src="<? echo base_url().'include/imagenes/iconos/ic_excel.png'?>" width="14px" height="12px"/>
        <b>Generar Excel</b>
    </button>
</div>
<?php endif;?> 
<table cellpadding="0" cellspacing="0" border="0" class="" id="reportes-rise" width="100%">
	<thead>
            <tr>
               <td>#</td>
                <td>Razon Social</td> 
                <td>Tipo Contribuyente</td> 
                <td>Monto Multa</td> 
                <td>Monto Interes</td>
                <td>Cobrada</td>

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
                                <td>'. $valor["contribuyente"].'</td>
                                    <td>'. $valor["tipo_cont"].'</td>
                                        <td>'. $valor["total_multa"].'</td>
                                            <td>'. $valor["total_interes"].'</td>
                                                <td>'. $valor["cobrada"].'</td>
                                                        


                     </tr>';
                }
          endif;
          ?>
          </tbody>  
            
         </table>


<style>
    #reportes-rise td{
        height: 25px
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

$("#btn_excel_rise").click(function(){
   
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