<?php
header('Content-type: application/x-excel');
header("Content-Disposition: attachment; filename=prueba_del_archivo.xls");
header("Pragma: no-cache");
header("Expires: 0");


?>

<style>
    #listar{
        border: 0px solid #555555;
        /*margin-top:200px;*/
        margin-left:30px;
        
    } 
    #listar-head tr{
        /*color: #003300;*/ 
        background:#888888;
        color: #D4CDC5 ;
       
    }
     #listar-head th{
        font-size: 12px;
        font-weight: bold;
        text-align: center;
/*        padding-top: 10px;
        padding-bottom: 10px;*/
        padding: 5px;
       
    }
    #listar-tbody td{
        font-size: 10px;      
        text-align: center; 
        padding: 10px;
       
    }
    .ui-widget-header{
      text-align:center;
      font-size: 14px; 
      font-style: italic; 
      margin-bottom: 10px;     
      margin-left:20px;
      margin-top: 100px
          
    }
     
    </style>
<div style="border: 0px solid blue; position: relative; margin-top: 0px">
<img src="<?php echo base_url()."/include/imagenes/encabezado_viejo.png"; ?>" style=" width:1000px; margin-left: 30px"/>
</div>
<div class="ui-widget-header">Listado de contribuyentes en espera de activacion de registro</div>    
<table  id="listar">
	<thead id="listar-head">
		<tr >
			<th>#</th>
			<th>Numero de Rif</th>
                        <th>Razon Social</th>
                        <th>Tipo de Contribuyente</th>
                        <th>Anio</th>
                        <th>Periodo</th>
                        <?php if($estatus!='enviado'):?>
                        <th>Fecha de elaboracion</th>
                        <th>Monto a pagar</th>
                        <?php endif;?>
                        <th>Estado</th>
                        
                </tr>
	</thead>
	<tbody id="listar-tbody">
           <?
           foreach ($data as $clave => $valor) {
            $con=$clave+1;
            $v=$valor['nombre'];
               echo '<tr>
                        <td>'. $con .'</td>
			<td>'. $valor["rif"].'</td>
                        <td style="width:150px">'. $valor["nombre"].'</td>
                        <td>'. $valor["nomb_tcont"].'</td>
                        <td>'. $valor["ano_calpago"].'</td>
                        <td>'. $valor["periodo"].'</td>';
                     ;
                  if($estatus!='enviado'):
                      
                      echo'<td>'. $valor["fechaelaboracion"].'</td>
                           <td>'. $valor["monto"].'</td>                           
                           <td>'. $estatus.'</td>    
                       </tr>';
                   else:
                       echo '<td>'. $estatus.'</td></tr>';
                   endif;
                   
           }
           ?>
           
        </tbody>  
</table>