
<?php
//Variable para diferenciar eventos para llamadas en multiples modulos y tabs
$diferenciador = random_string('alnum', 16);
?>
<style>
    #volver_detalles_cont<?php print($diferenciador); ?>{
        float: right;
    }
</style>
<?php
if (!empty($metodo)):
    

?>
<script>
    $(function() {
        $("#volver_detalles_cont<?php print($diferenciador); ?>").click(function(){
            var volver_metodo= <?php print($metodo); ?>;

             if(typeof <?php print($metodo); ?> == 'function') {
                <?php print($metodo."()"); ?>;
                    }else{
                        alert('La función no existe');
                    }               

        });
        $( "#volver_detalles_cont<?php print($diferenciador); ?>" ).button({
            icons: {
                primary: "ui-icon ui-icon-arrowreturnthick-1-w"
            }});   
    });
</script>
<?php
else:
    ?>
<script>
    $(function() {
        $("#volver_detalles_cont<?php print($diferenciador); ?>").click(function(){

                        alert('La función no existe');

        });
        $( "#volver_detalles_cont<?php print($diferenciador); ?>" ).button({
            icons: {
                primary: "ui-icon ui-icon-arrowreturnthick-1-w"
            }});   
    });
</script>
<?php
endif;
    if($succes):
//        print('DATOS DEL USUARIO <br/>');
//        print_r($datos_usuario);
        ?>
<b>Contribuyente: </b><? print($datos_usuario[0]['nombre']); ?><br/>
<b>Rif: </b><? print($datos_usuario[0]['rif']); ?><br/>
<b>Email: </b><? print($datos_usuario[0]['email']); ?><br/>
<b>Tipo Contribuyente: </b><? print($nombre_tipocont); ?><br/>
<button  id="volver_detalles_cont<?php print($diferenciador); ?>" type="button" >Volver</button>
<?php
        $contador_resultados = 0;

        if($omisos):
            $contador_resultados++;
        ?>
<br/><br/><br/> <b>PERIODOS OMISOS</b><br/><br/>
        <table class="detalle_general_conusu_<?php print($diferenciador); ?>" cellpadding="0" cellspacing="0" border="0"  width="100%">
            <thead>
                <tr>
                    <th>Fecha Inicio</th>
                    <th>Fecha Fin</th>
                    <th>Fecha Limite</th>
                    <th>Año</th>
                    <th>Periodo</th>
                    <th>Nombre Periodo Gravable</th>

                </tr>
            </thead>
            <tbody>
            <?php  
            if(sizeof($omisos)>0): 
                foreach ($omisos as $valor): ?>
                    <tr>
                        <td>
                            <?php print($valor['id']); ?>
                        </td>
                        <td>
                            <?php print($valor['fechafin']); ?>
                        </td>
                        <td>
                            <?php print($valor['fechalim']); ?>
                        </td>
                        <td>
                            <?php print($valor['ano']); ?>
                        </td>
                        <td>
                            <?php print($valor['periodo']); ?>
                        </td>
                        <td>
                            <?php print($valor['nombre']); ?>
                        </td>                       
                    </tr>

            <?php endforeach;
            else: ?>
<!--                    <tr>
                        <td colspan="7">
                            No hay resultados
                        </td>

                    </tr>        -->      
            <?php 
            endif;?>
            </tbody>
        </table>
        <?php
        endif;

        if($omisos_declara):
            $contador_resultados++;
        ?>
        <br/><br/><br/> <b>PERIODOS OMISOS  DECLARADOS</b><br/><br/>
        <table class="detalle_general_conusu_<?php print($diferenciador); ?>" cellpadding="0" cellspacing="0" border="0" width="100%">
            <thead>
                <tr>
                    <th>Nro Planilla</th>
                    <th>Fecha Elaboracion</th>
                    <th>Fecha Inicio</th>
                    <th>Fecha Fin</th>
                    <th>Base Imponible</th>
                    <th>Alicuota</th>
                    <th>Total a Pagar</th>

                </tr>
            </thead>
            <tbody>
            <?php
            if(sizeof($omisos_declara)>0): 
                foreach ($omisos_declara as $valor): ?>
                    <tr>
                        <td>
                            <?php print($valor['calpagodid']); ?>
                        </td>
                        <td>
                            <?php print($valor['fechaelab']); ?>
                        </td>
                        <td>
                            <?php print($valor['fechaini']); ?>
                        </td>
                        <td>
                            <?php print($valor['fechafin']); ?>
                        </td>
                        <td>
                            <?php print($valor['baseimpo']); ?>
                        </td>
                        <td>
                            <?php print($valor['alicuota']); ?>
                        </td>   
                        <td>
                            <?php print($valor['montopagar']); ?>
                        </td>         
                    </tr>

            <?php endforeach;
            else: ?>
<!--                    <tr>
                        <td colspan="7">
                            No hay resultados
                        </td>

                    </tr>        -->    
            <?php 
            endif;?>
            </tbody>
        </table>
        <?php
        endif;

        if($pagados):
            $contador_resultados++;
        ?>
        <br/><br/><br/><b> PERIODOS PAGADOS</b><br/><br/>
        <table class="detalle_general_conusu_<?php print($diferenciador); ?>" cellpadding="0" cellspacing="0" border="0"  width="100%">
            <thead>
                <tr>
                    <th>Nro Planilla</th>
                    <th>Fecha Elaboracion</th>
                    <th>Fecha Inicio</th>
                    <th>Fecha Fin</th>
                    <th>Base Imponible</th>
                    <th>Alicuota</th>
                    <th>Total a Pagar</th>

                </tr>
            </thead>
            <tbody>
            <?php
            if(sizeof($pagados)>0): 
                foreach ($pagados as $valor): ?>
                    <tr>
                        <td>
                            <?php print($valor['calpagodid']); ?>
                        </td>
                        <td>
                            <?php print($valor['fechaelab']); ?>
                        </td>
                        <td>
                            <?php print($valor['fechaini']); ?>
                        </td>
                        <td>
                            <?php print($valor['fechafin']); ?>
                        </td>
                        <td>
                            <?php print($valor['baseimpo']); ?>
                        </td>
                        <td>
                            <?php print($valor['alicuota']); ?>
                        </td>   
                        <td>
                            <?php print($valor['montopagar']); ?>
                        </td>         
                    </tr>

            <?php endforeach;
            else: ?>
<!--                    <tr>
                        <td colspan="7">
                            No hay resultados
                        </td>

                    </tr>        -->      
            <?php 
            endif;?>
            </tbody>
        </table>
        <?php
        endif;

        if($extemporaneos):
            $contador_resultados++;
        ?>
        <br/><br/><br/><b> PERIODOS EXTEMPORANEOS</b><br/><br/>
        <table class="detalle_general_conusu_<?php print($diferenciador); ?>" cellpadding="0" cellspacing="0" border="0"  width="100%">
            <thead>
                <tr>
                    <th>Nro Planilla</th>
                    <th>Fecha Elaboracion</th>
                    <th>Fecha Inicio</th>
                    <th>Fecha Fin</th>
                    <th>Base Imponible</th>
                    <th>Alicuota</th>
                    <th>Total a Pagar</th>

                </tr>
            </thead>
            <tbody>
            <?php
            if(sizeof($extemporaneos)>0): 
                foreach ($extemporaneos as $valor): ?>
                    <tr>
                        <td>
                            <?php print($valor['calpagodid']); ?>
                        </td>
                        <td>
                            <?php print($valor['fechaelab']); ?>
                        </td>
                        <td>
                            <?php print($valor['fechaini']); ?>
                        </td>
                        <td>
                            <?php print($valor['fechafin']); ?>
                        </td>
                        <td>
                            <?php print($valor['baseimpo']); ?>
                        </td>
                        <td>
                            <?php print($valor['alicuota']); ?>
                        </td>   
                        <td>
                            <?php print($valor['montopagar']); ?>
                        </td>         
                    </tr>

            <?php endforeach;
            else: ?>
<!--                    <tr>
                        <td colspan="7">
                            No hay resultados
                        </td>

                    </tr>        -->    
            <?php 
            endif;?>
            </tbody>
        </table>
        <?php
        endif;

        if($dentro_limite_pago):
            $contador_resultados++;
        ?>
        <br/><br/><br/><b> DENTRO DEL LIMITE DE PAGO</b><br/><br/>
        <table class="detalle_general_conusu_<?php print($diferenciador); ?>" cellpadding="0" cellspacing="0" border="0"  width="100%">
            <thead>
                <tr>
                    <th>Nro Planilla</th>
                    <th>Fecha Elaboracion</th>
                    <th>Fecha Inicio</th>
                    <th>Fecha Fin</th>
                    <th>Base Imponible</th>
                    <th>Alicuota</th>
                    <th>Total a Pagar</th>

                </tr>
            </thead>
            <tbody>
            <?php
            if(sizeof($dentro_limite_pago)>0): 
                foreach ($dentro_limite_pago as $valor): ?>
                    <tr>
                        <td>
                            <?php print($valor['calpagodid']); ?>
                        </td>
                        <td>
                            <?php print($valor['fechaelab']); ?>
                        </td>
                        <td>
                            <?php print($valor['fechaini']); ?>
                        </td>
                        <td>
                            <?php print($valor['fechafin']); ?>
                        </td>
                        <td>
                            <?php print($valor['baseimpo']); ?>
                        </td>
                        <td>
                            <?php print($valor['alicuota']); ?>
                        </td>   
                        <td>
                            <?php print($valor['montopagar']); ?>
                        </td>         
                    </tr>

            <?php endforeach;
            else: ?>
<!--                    <tr>
                        <td colspan="7">
                            No hay resultados
                        </td>

                    </tr>        -->
            <?php 
            endif;?>
            </tbody>
        </table>

        <?php
        endif;
        ?>
        <script>
                $(function() {
            oTable = $('.detalle_general_conusu_<?php print($diferenciador); ?>').dataTable({
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
                                $('.detalle_general_conusu_<?php print($diferenciador); ?> input, select').addClass('ui-state-highlight ui-corner-all');
                                });
        </script>        
        <?php
        if($contador_resultados==0):
            print('No hay resultados');
        endif;
    else:
        print($mensaje);
    endif;
        ?>
