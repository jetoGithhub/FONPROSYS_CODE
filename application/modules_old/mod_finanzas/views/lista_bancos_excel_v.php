<?php // 
    header('Content-type: application/x-excel');
    header("Content-Disposition: attachment; filename=entidades_bancarias.xls");
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
		<tr><td><b>Listar Bancos</b></td></tr>
		<tr><td>&nbsp;</td></tr> 
		<tr>
            <th># </th>
			<th>Nombres</th>
			<th>Fecha</th>
        </tr>
	</thead>
	<tbody>
           <?
			   foreach ($data as $clave => $valor) {
					$con=$clave+1;
					$v=$valor['id_bancos'];
					   echo '<tr>
							   
								<td>'. $con .'</td>
								<td>'. $valor["nombre"].'</td>
								<td>'. $valor["fecha_registro"].'</td>
								
						</tr>';
				}
           ?>
           
     </tbody>  
</table>

	
</html>
