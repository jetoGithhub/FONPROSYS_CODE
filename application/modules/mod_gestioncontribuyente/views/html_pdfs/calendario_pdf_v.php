<page backtop="16mm" backbottom="16mm" backleft="16mm" backright="16mm" style="font-size: 12pt" >
<page_header>
    <div style=" position: absolute; width: 87%;  margin-left:55px">
        <img src="<?php echo base_url()."/include/imagenes/encabezado_viejo.png"; ?>" style=" width:100%; height: 55px ;"/>
    </div> 
    <br /><br /><br />
    <p style="margin-left:55px"><b>Tipo de contribuyente:</b>&nbsp;&nbsp;&nbsp;<?php echo $nombre; ?></p>
</page_header>
                        <!-- seccion del pie de pagina del acta-->    
<page_footer>
    <div class="page_footer" >
        <p style=" text-align: center; color: white"><b>Avenida Francisco de Miranda con Calle Los Laboratorios, Centro Empresarial 
        Quórum, Piso 1, Oficinas 1F, 1G y 1H, Urbanización Los Ruices. Estado Miranda 
        Teléfonos: (0212)  235 21 94 / 238 24 84 / 239 21 71. Correo electrónico 
        fiscalizaciontributaria@cnac.gob.ve</b>
        </p>
    </div>
<p style=" text-align: right">Pagina [[page_cu]]/[[page_nb]]</p> 
</page_footer> 
<br /><br /><br />                        
  <p style=" text-align: center; font-weight: bold"><b>Listado de fechas de pago del año <?php echo  $anio?> </b></p>                      
<br /><br /><br />
  <table style=" border: 1px solid black; border-collapse: collapse" id="tbl_consulta_cal" >
    <tr >
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
    
    foreach ($datos_calendario as $key => $value) {
        
        echo "<tr style=''>
                    <td class='ui-widget-content ui-corner-all' style='padding:3px;' >";
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
                    <td class='ui-widget-content ui-corner-all' style='padding:3px; text-align:center' >".date('d-m-Y',strtotime($value["fechai"]))."</td>
                    <td class='ui-widget-content ui-corner-all' style='padding:3px; text-align:center' >".date('d-m-Y',strtotime($value["fechaf"]))."</td>
                    <td class='ui-widget-content ui-corner-all' style='padding:3px; text-align:center' >".date('d-m-Y',strtotime($value["fechal"]))."</td>
                    
              </tr>";
        
    }
    
    ?>
    
    
</table>
</page>
<style>
    table#tbl_consulta_cal h2{
        
        font-size: 12px;
        font-style: italic;
        color: #333333; font-family: Tahoma, Geneva, sans-serif; 
        padding: 10px;
        width: 400px;
        line-height: 2.0;
          
    }
    table#tbl_consulta_cal td {
        border: 1px solid black
    }
    
</style>