<?php



?>
<script>
    $(function() {
          

    });
oTable = $('#resul-actas').dataTable({
                                "bJQueryUI": true,
//					"sPaginationType": "full_numbers",
                                "aaSorting": [[ 1, "desc" ]],
                                "bPaginate": false,
                                "sScrollX": "100%",
                                "sScrollXInner": "110%",
                                "bScrollCollapse": true,

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
$("#btn_excel_conciliados").click(function(){
   
   window.location='<?php echo base_url()."index.php/mod_reportes/reporte_actas_fiscalizacion_c/genera_excel_actas_fiscalizacion?"?>'+$("#busca_acta").serialize();
});
 
</script>
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
<table cellpadding="0" cellspacing="0" border="0" class="" id="resul-actas" class="display" width="100%">
    <thead>
        
        <tr>
            <th>Letras</th>
            <th>Nº</th>
            <th>Fecha de<br />Elaboracion</th>
            <th>Fecha<br />Notificacion</th>
            <th>Contribuyente</th>
            <th>T&iacute;po de<br />Contribuyente</th>
            <th>Per&iacute;odo a<br />Fiscalizar</th>
                
        </tr>
    </thead>
    <tbody>
        
        <?php
        if(!empty($datos)):
        if($tipo==0){
               $letras= 'CNAC/FONPROCINE/GFT/AF';
            }elseif ($tipo==1) {
                $letras= 'CNAC/FONPROCINE/GFT/AR';
            
            }elseif ($tipo==2){
                $letras= 'CNAC/FONPROCINE/GFT/ARD';
            }elseif ($tipo==3){
                $letras= 'CNAC/FONPROCINE/GFT/AFR';
            }
        foreach ($datos as $key => $value) {
            
            
            echo ' <tr>
                        <td>'.$letras.'</td>
                        <td>'.($tipo!=3? $value["nro_autorizacion"]: $value['numero_acta_rep']).'</td>
                        <td>'.($tipo!=3? date('d/m/Y',strtotime($value['fecha_asignacion'])) : date('d/m/Y',strtotime($value['fecha_creacion_rep']))).'</td>';
                        if($tipo==0):
                          echo "<td>".(!empty($value['fecha_autorizacion'])? date('d/m/Y',strtotime($value['fecha_autorizacion'])) :'' )."</td>";  
                        endif;
                        if($tipo==1):
                            echo "<td>".(!empty($value['fecha_requerimiento'])?date('d/m/Y',strtotime($value['fecha_requerimiento'])): '')."</td>";
                        endif;
                        if($tipo==2):
                            echo "<td>".(!empty($value['fecha_recepcion'])?date('d/m/Y',strtotime($value['fecha_recepcion'])):'' )."</td>";
                        endif;
                        if($tipo==3):
                            echo "<td></td>";
                        endif;
                                               
                        echo '<td>'.$value['contribuyente'].'</td>
                        <td>'.$value['tipo_contribuyente'].'</td>
                        <td>'.$value['anio_fiscalizar'].'</td>
                    </tr>';
        }
        endif;
        
        ?>
        
    </tbody>
</table>    

<style>
    #resul-actas tbody,td{
        height: 25px;
        padding: 5px;
        border-left: 1px solid #EEEEEE;
        text-align: center;
            
    }  
     #resul-actas thead,th{
       text-align: center;
       font-weight: bold;
            
    } 
    
    .botonera_reportes button{
      color:#000;
                        
    }
    #btn_excel{
        padding: 2px;
    }
</style>