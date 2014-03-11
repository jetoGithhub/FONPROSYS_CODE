<html>
<style>

#tabla_fondo{height:100% !important; margin:0; padding:0; width:90% !important;}
body, #tabla_fondo { background-color:#FAFAFA; }
#separador{ border-right: 2px solid #000000}
 #tabla_fondo tr {
            color:#505050;
            font-family:Arial;
            font-size:14px;
            line-height:150%;
            text-align:justify;
	    
}
 #tabla_fondo p {padding:10px; }
#tabla_fondo div{
            height:5px;
            background:#707070;
            font-family:Arial;
            font-size:11px;
            text-align:left;
	    width:100%
}
</style>

<table  id='tabla_fondo' border="0" cellpadding="0" cellspacing="0" height="100%" width="100%">
	<tr>
		<td colspan='3'>
			<div></div>
		</td>
	</tr>    
	<tr>
	
        <td valign="top">
            <p style='text-align: center; font-size: 14px;'><b>Analista</b></p>
            <p style='text-align: left; font-size: 12px;'>
                <b>NOMBRE:</b><br /><?php echo $nombre_funcionario; ?><br />
                <b>Correo:</b><br /><?php echo $email_funcionario; ?>    
            </p>
        </td>
        <td  id='separador'>&nbsp;&nbsp;&nbsp;&nbsp;</td>
        <td valign="top">
 	    <p style='text-align: center; font-size: 14px;' ><b>Cuerpo del Mensaje</b></p>
            <p style='text-align: justify;font-size: 12px; ' >
           	<?php echo $mensaje; ?> 
            </p>
        </td>
    </tr>
    <tr>
        <td colspan='3' valign="middle">
		<p style='text-align: center; font-size: 10px;'><i>
		SI EL SIGUIENTE CORREO REQUIERE RESPUESTA POR FA VOR COMUNICARSE
		CON EL ANALISTA DE REGISTRO POR MEDIO DE LOS DATOS ANTES MENCIONADOS

		</i></p>
        </td>
    </tr>
	<tr>
		<td colspan='3'>
			<div></div>
		</td>
	</tr>
  </table>
</html>
