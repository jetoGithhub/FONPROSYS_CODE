<? 
//header('Content-type: application/msword');
//header("Content-Disposition: attachment; filename=nombre_del_archivo.doc");
//header("Pragma: no-cache");
//header("Expires: 0");
?>
<style>
    #listar{
        border: 0px solid #555555;
        /*margin-top:200px;*/
        margin-left:20px;
        
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
        padding-top: 10px;
        padding-bottom: 10px;
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
<div style="">
<img src="<?php echo base_url()."/include/imagenes/encabezado_viejo.png"; ?>" style=" width:700px; margin-left: 5px"/>
</div>
<div class="ui-widget-header">Listado de contribuyentes con calculos en estatus <?php echo $estatus?></div>    
<table  id="listar" >
	<thead id="listar-head">
            <tr>
            <?            
           foreach ($encabezado as $clave1 => $valor1):
               
                echo '<th>'.$valor1.'</th>';
               
           endforeach;           
           ?>
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
                        <td style="width:100px">'. $valor["nombre"].'</td>
                        <td>'. $valor["nomb_tcont"].'</td>
                        <td>'. $valor["ano_calpago"].'</td>
                        <td>'. $valor["periodo"].'</td>';
                     ;
                  if($estatus!='enviado'):
                      
                      echo'<td style="width:50px">'. $valor["fechaelaboracion"].'</td>
                           <td>'. $valor["monto"].'</td>
                          <td>'. $valor["monto_interes"].'</td>';
                    else:
                        echo'<td style="width:50px">'. $valor["fechaelaboracion"].'</td>
                           <td style="width:40px">'. $valor["usuregi"].'</td>';
                   endif;
                        
                 echo '</tr>';
                   
           }
           ?>
           
        </tbody>
        
         </table>

<!-- <table style="background: #FFAAAA; color: #000022; border: 3px solid #555555;">
        <tr>
            <td style="width: 40mm; border: solid 1px #000000; color: #003300">Case A1</td>
            <td style="width: 50mm; border: solid 1px #000000; font-weight: bold;">Case A2</td>
            <td style="width: 60mm; border: solid 1px #000000;font-size: 20px;">Case A3</td>
        </tr>
        <tr>
            <td style="border: solid 1px #000000; text-align: left;   vertical-align: top; ">Case B1</td>
            <td style="border: solid 1px #000000; text-align: center; vertical-align: middle; height: 20mm">Case B2<hr style="color: #22AA22">test de hr</td>
            <td style="border: solid 1px #000000; text-align: right;  vertical-align: bottom; border-radius: 3mm; ">Case B3</td>
        </tr>
    </table>-->