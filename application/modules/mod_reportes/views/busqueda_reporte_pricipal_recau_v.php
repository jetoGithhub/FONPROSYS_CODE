<?php

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
?>
 <?php 
 if(!empty($data)):
 ?>
<div class="botonera_reportes" style="float: right">
<!--    <button id="btn_pdf" class="btn_reportes">
        <img src="<? // echo base_url().'include/imagenes/iconos/ic_pdf.png'?>" width="14px" height="12px"/>
        <b>PDF</b>
    </button>-->
    <button id="btn_excel_recau_principal" class="btn_reportes">
        <img src="<? echo base_url().'include/imagenes/iconos/ic_excel.png'?>" width="14px" height="12px"/>
        <b>Generar Excel</b>
    </button>
</div>
<?php endif;?> 
<table cellpadding="0" cellspacing="0" border="0" class="display" id="rep-principal-rec" width="100%">
    
                <thead>
                        <tr>
                                <th>MES</th>
                                <th>Exhibidores</th>
                                <th>Señal Abierta</th>
                                <th>TV Suscripcion</th>
                                <th>Distribuidores</th>
                                <th>Venta y <br /> Alquiler de<br />Videogramas</th>
                                <th>Productores</th>
                                <th>Recaudado <br /> Mensual</th>
                                

                        </tr>
                </thead>
                <tbody> 
                    <?php
                    foreach ($data as $key => $value) {
                        echo"<tr>
                                <td id='meses'>".$this->funciones_complemento->devuelve_meses_text($key,2)."</td>
                                <td class='montos' >".($value['exhibidores']==0? '0,00':$this->funciones_complemento->devuelve_cifras_unidades_mil($value['exhibidores']))."</td>
                                <td class='montos' >".($value['tvAbierta']==0? '0,00':$this->funciones_complemento->devuelve_cifras_unidades_mil($value['tvAbierta']))."</td>
                                <td class='montos' >".($value['tvSuscrip']==0? '0,00':$this->funciones_complemento->devuelve_cifras_unidades_mil($value['tvSuscrip']))."</td>
                                <td class='montos' >".($value['distribuidores']==0? '0,00':$this->funciones_complemento->devuelve_cifras_unidades_mil($value['distribuidores']))."</td>
                                <td class='montos' >".($value['ventaAlquiler']==0? '0,00':$this->funciones_complemento->devuelve_cifras_unidades_mil($value['ventaAlquiler']))."</td>
                                <td class='montos' >".($value['servProduccion']==0? '0,00':$this->funciones_complemento->devuelve_cifras_unidades_mil($value['servProduccion']))."</td>
                                <td class='montos' >".($value['total_autoli']==0? '0,00':$this->funciones_complemento->devuelve_cifras_unidades_mil($value['total_autoli']))."</td>   
                                   
                            </tr>";
                    }
                    
                    
                    ?>
                </tbody>
</table>
<script>
 oTable = $('.display').dataTable({
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
</script>