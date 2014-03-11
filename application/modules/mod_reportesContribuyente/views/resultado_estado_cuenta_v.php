<?php
//echo date("d",mktime(0,0,0,3,0,2014));
//$sum=0;
//for($i=3;$i<=12;$i++):
//    
//    $sum=$sum+date("d",mktime(0,0,0,($i-1),0,2013));
//    
//endfor;
//echo $sum;
?>
<script>
    $(function() {
      $("#inprimir-estcuenta").button();    

    });
oTable = $('#resul-busq-estdcuenta').dataTable({
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
//$("#btn_excel_conciliados").click(function(){
//   
//   window.location='<?php echo base_url()."index.php/mod_reportes/reporte_actas_fiscalizacion_c/genera_excel_actas_fiscalizacion?"?>'+$("#busca_acta").serialize();
//});
 
</script>
<?php 
 if(!empty($datos)):
 ?>
<!--<div class="botonera_reportes" style="float: right">
    <button id="btn_pdf" class="btn_reportes">
        <img src="<? // echo base_url().'include/imagenes/iconos/ic_pdf.png'?>" width="14px" height="12px"/>
        <b>PDF</b>
    </button>
    <button id="btn_excel_conciliados" class="btn_reportes">
        <img src="<? echo base_url().'include/imagenes/iconos/ic_excel.png'?>" width="14px" height="12px"/>
        <b>Generar Excel</b>
    </button>
</div>-->
<?php endif;?>
<table cellpadding="0" cellspacing="0" border="0" class="" id="resul-busq-estdcuenta" class="display" width="100%">
    <thead  >
        
        <tr>
            <th>#</th>
            <th>Tipo de contribuyente</th>
            <th>Periodo Fiscal</th>
            <?php ($ident==0? print('<th>Fecha Limite</th>') : print('<th>Tipo Multa</th>')) ?>
            <th>Fecha Pago</th>
            <th>Pago</th>
             <?php ($ident==0? print('<th>Extemporaneos</th>') : '') ?>
            <!--<th>Dias</th>-->
                
        </tr>
    </thead>
    <tbody>
        
        <?php
        if(!empty($datos)):
        $i=1;
        foreach ($datos as $key => $value) {
            
            
            echo ' <tr>
                        <td>'.$i.'</td>
                        <td>'.$value["nom_contribu"].'</td>';
                        if($value['tipo']==0):
                          echo "<td>".$this->funciones_complemento->devuelve_meses_text($value['periodo']).'-'.$value['ano']."</td>";  
                        endif;
                        if($value['tipo']==1):
                             echo "<td>".$this->funciones_complemento->devuelve_trimestre_text($value['periodo']).'-'.$value['ano']."</td>"; 
                        endif;
                        if($value['tipo']==2):
                            echo "<td>".$value['ano']."</td>"; 
                        endif;
                        if($value['tipo']==3):
                            echo "<td></td>";
                        endif;
                                               
                        echo '<td>'.($ident==0? date('d-m-Y',strtotime($value['fechafin'])) : $value['tipo_multa'] ).'</td>
                        <td>'.(empty($value['fechapago'])? "" : date('d-m-Y',strtotime($value['fechapago']))).'</td>
                        <td>'.(empty($value['fecha_carga_pago'])? "NO" : "SI").'</td>';
                        if($ident==0){
                                if(!empty($value['fecha_carga_pago'])):

                                    if( strtotime($value['fechapago']) > strtotime($value['fechafin']) ):
                                           echo "<td>SI</td>
                                                 "; 
                                       else:
                                           echo "<td>NO</td>
                                                 "; 
                                   endif;

                               else:
                                   echo "<td>NO</td> 
                                      "; 

                               endif;
                        }
                       
            echo '</tr>';
            $i++;
        }
        endif;
        
        ?>
        
    </tbody>
</table>
<br />
<center>
    <button id="inprimir-estcuenta"><span class=" ui-icon ui-icon-print" style=" float:left"></span>Imprimir</button>
    
</center>

<style>
    #resul-busq-estdcuenta td{
        height: 25px;
        padding: 5px;
        border-left: 1px solid #EEEEEE;
        text-align: center;            
            
    }  
     #resul-busq-estdcuenta thead, th{
       text-align: center;
       font-weight: bold;
            
    } 
    th.ui-state-default div{
        padding-top: 15px;
        height: 25px;
    }
/*    .botonera_reportes button{
      color:#000;
                        
    }
    #btn_excel{
        padding: 2px;
    }*/
</style>
