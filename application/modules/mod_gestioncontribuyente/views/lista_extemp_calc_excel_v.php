<?php // 
    header('Content-type: application/x-excel');
    header("Content-Disposition: attachment; filename=extemporaneos_calcular.xls");
    header("Pragma: no-cache");
    header("Expires: 0");
?>

<html>
	<head>

                
                <style type="text/css">
                    .greenBack{background-color:#d7e4bc}
                    .redFont{color:red}
                </style>
	</head>

<table cellpadding="0" cellspacing="0" border="0" class="display" id="listar" width="100%">
	<thead>
        
                <tr><td class="titulo"><b>CNAC</b></td></tr>
                <tr><td class="redFont"><b>FONPROCINE</b></td></tr>
                <tr><td><b>Listar Extemporaneos a calcular</b></td></tr>
                <tr><td>&nbsp;</td></tr> 
		<tr>
                    
			<th># </th>
			<th>Numero de Rif</th>
                        <th>Razon Social</th>
                        <th>Tipo de Contribuyente</th>
                        <th>Operaciones</th>
                </tr>
	</thead>
	<tbody>
           <?
           foreach ($data as $clave => $valor) {
            $con=$clave+1;
            $v=$valor['nombre'];
               echo '<tr>
                       
                        <td>'. $con .'</td>
			<td>'. $valor["rif"].'</td>
                        <td>'. $valor["nombre"].'</td>
                        <td>'. $valor["nomb_tcont"].'</td>
                        <td>
                            <span id="check_proc'.$valor["idconcalc"].'"><input type="checkbox" name="r_activar[]" value="'.$valor["idconcalc"].'"></span>
                            <span id="ic_proc'.$valor["idconcalc"].'"></span>
                        </td>
                        
                </tr>';
//                    
               
               
           }
           ?>
           
        </tbody>  
         </table>

	
</html>
