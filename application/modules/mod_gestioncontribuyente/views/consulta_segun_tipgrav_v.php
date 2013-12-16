<?php

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
?>
<script>
 $(function() {
     ayudas('#','tbl_consulta_cal','bottom right','left top','fold','up');
     
     
 });
 genera_pdf_calenda=function(tipe_grav,tipo,anio){
        
        window.open('<?php echo base_url()."index.php/mod_gestioncontribuyente/gestion_calendarios_de_pago_c/genera_pdf_calenda/"?>'+tipe_grav+"/"+tipo+"/"+anio);
};
 </script>
<table style=" width: 100%" id="tbl_consulta_cal" >
    <tr>
        <td class="ui-widget-content ui-corner-header ui-widget-header ui-corner-all" style="width: 140px;border:1px #000 solid;padding:3px; text-align: center">
           <b>PERIODOS</b> 
        </td>
        <td class="ui-widget-content ui-corner-header ui-widget-header ui-corner-all" style="width: 140px;border:1px #000 solid;padding:3px;text-align: center">
           <b>FECHA INICIO</b>  
        </td>
        <td class="ui-widget-content ui-corner-header ui-widget-header ui-corner-all" style="width: 140px;border:1px #000 solid;padding:3px; text-align: center">
            <b>FECHA FIN</b> 
        </td>
        <td class="ui-widget-content ui-corner-header ui-widget-header ui-corner-all" style="width: 140px;border:1px #000 solid;padding:3px; text-align: center">
           <b>FECHA LIMITE</b>  
        </td>
    </tr>
    <?php
    if(!empty($datos_calendario)):
    foreach ($datos_calendario as $key => $value) {
        
        echo "<tr>
                    <td class='ui-widget-content ui-corner-all' style='padding:3px; text-align:center' >";
                    if($tipo==0):
                        echo $this->funciones_complemento->devuelve_meses_text($value['periodo']);                            
                    endif; 
                     if($tipo==1):
                        echo $this->funciones_complemento->devuelve_trimestre_text($value['periodo']);                            
                    endif;
                     if($tipo==2):
                       echo $anio;                            
                    endif;
        
                  echo "</td>
                    <td class='ui-widget-content ui-corner-all' style='padding:3px' ><center>".date('d-m-Y',strtotime($value["fechai"]))."</center></td>
                    <td class='ui-widget-content ui-corner-all' style='padding:3px' ><center>".date('d-m-Y',strtotime($value["fechaf"]))."</center></td>
                    <td class='ui-widget-content ui-corner-all' style='padding:3px' ><center>".date('d-m-Y',strtotime($value["fechal"]))."</center></td>
                    
              </tr>";
        
    }
    echo "<tr> 
                <td colspan='4' class='ui-widget-content ui-corner-all' style='padding:10px' > 
                <center>
                        <a href='#' onclick='genera_pdf_calenda($tipe_grav,$tipo,$anio)' id='pdf_calp' class='ayuda' txtayuda='Generar pdf' ><img src='".base_url().'include/imagenes/iconos/ic_pdf.png'."' style='margin-right:50px' width='32' height='32' /></a>
                        <a href='#' id='excel_calp' class='ayuda' txtayuda='Generar excel' ><img src='".base_url().'include/imagenes/iconos/ic_excel.png'."' width='32' height='32' /></a>
                </center>            
                </td>
          </tr>";
    else:
        echo    "<tr>
                        <td colspan='4' >
                            <center><h2><span class='ui-icon ui-icon-alert' style=' float:left; padding: 0px'></span> NO SE ENCONTRO CALENDARIO DE PAGOS PARA ESTE AÑO Y CONTRIBUYENTE ESPECIFICO</h2></center>
                        </td>
                </tr>";       
        
    endif;
    ?>
    
    
</table>

<style>
    table#tbl_consulta_cal h2{
        
        font-size: 12px;
        font-style: italic;
        color: #333333; font-family: Tahoma, Geneva, sans-serif; 
        padding: 10px;
        width: 400px;
        line-height: 2.0
          
    } 
    
</style>