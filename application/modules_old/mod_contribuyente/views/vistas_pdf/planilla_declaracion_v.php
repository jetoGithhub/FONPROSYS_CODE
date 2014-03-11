<style type="text/css">
    body{
        font-family:Arial, Helvetica, sans-serif;
        font-style: normal;
        font-size: 8px;
    }
    .tabla-cuerpo p{
        padding: 3px;
         font-size:9px
    }
    .tercer_bloque { font-size: 9px; vertical-align:middle;}

    
   .page_footer { margin-left:30px;}
/*  .tabla_padre{ width: 100%;} */
/* #hija1{ width: 1500px;}*/ 
/* .tabla_padre #hija2 { width: 50%; margin-top: 30px;}
       .tabla_padre #hija3 { width: 50%; margin-top: 20px;}*/
       td.cabecera{ text-align: center; font-weight: bold; font-size: 11px;}
       .info-recepcion{ width:150px}
       .observaciones{ width:200px }
       /*.menor{ width:10px}*/
      
    
</style>

<page backtop="16mm" backbottom="16mm" backleft="8mm" backright="12mm" style="" >
  <page_header>
        
          <table width="90%" border="0">
				<tr>
					<td>
						<img src="<?php echo base_url()."/include/imagenes/logo_cnac.png"; ?>" style=" margin-left:40px; width:50px; height: 50px ;"/>
					</td>
					<td>&nbsp;</td>
					<td>
						<table border="0" style="margin-left:320px; font-size: 9px;" cellspacing="0">
<!--								<tr>
									<td>
										<b>Periodo Grabable:&nbsp;</b>
									</td>
									<td>
										<table border="1" cellpadding="0" cellspacing="1" bordercolor="#000000" style="border-collapse:collapse;">
											<tr>
												<td>
													&nbsp;&nbsp;Desde: &nbsp;&nbsp;
												</td>
												<td>
													&nbsp;&nbsp;<?php echo strtoupper($planilla[0]['fechai']) ?>&nbsp;&nbsp;
												</td>
												<td>
													&nbsp;&nbsp;Hasta: &nbsp;&nbsp;
												</td>
												<td>
													&nbsp;&nbsp;<?php echo strtoupper( $planilla[0]['fechafin']) ?>&nbsp;&nbsp;
												</td>
											</tr>
										</table>
									</td>
								</tr>-->
                                                                <tr>
                                                                     <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
                                                                        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
                                                                        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
									<td>
                                                                            <p><b>Declaraci&oacute;n Nº</b></p>
									</td>
									<td>
										<p><b><?php echo $planilla[0]['nudeclara'] ?></b></p>
									</td>
                                                                   
                                                                </tr>
								<tr>
                                                                        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
                                                                        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
                                                                        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
									<td>
										<p><b>Tipo de documento:&nbsp;&nbsp;</b></p>
									</td>
									<td>
										<p>&nbsp;&nbsp;<?php echo strtoupper( $planilla[0]['ntdeclara']) ?></p>
									</td>
								</tr>
						</table>		
					</td>
				</tr>
            
           </table>
 
    </page_header>
    <page_footer>
      
                
        <p style=" text-align: right">Pagina [[page_cu]]/[[page_nb]]</p> 
     </page_footer>
     <br /> 

<table class="tabla-cuerpo" border="1" style=" border-collapse: collapse; border-color: black;">
       <tbody align="justify" valign="top"> 
        <tr bgcolor="#AEADAC">
            
            <td colspan="3" class="cabecera">A. DATOS DEL CONTRIBUYENTE</td>
            
        </tr>
         <tr>
             <td  style=" width: 300px"><p>1. Razon Social:
                  <?php echo strtoupper( $planilla[0]['razonsocia']) ?></p>
             </td>
             <td colspan="2" style=" width: 300px"><p>2. Denominacion Comercial:
                <?php echo strtoupper( $planilla[0]['dencomerci']) ?></p>
             </td>
         </tr>
         <tr>
             <td style=" width: 150px">
                    <p>3. Actividad Economica:
                     <?php echo strtoupper( $planilla[0]['actiecon']) ?>
                    </p>
             </td>
             <td style=" width: 150px">
                 <p>4. N° RIF: <?php echo strtoupper( $planilla[0]['rif']) ?></p></td>
             <td  style=" width: 200px">
                 <p>5. Numero RCN: <?php echo strtoupper( $planilla[0]['numregcine']) ?></p>
             </td>
         </tr>
         <tr>
             <td colspan="3">
                 <p>6. Domicilio Fiscal: <?php echo strtoupper( $planilla[0]['domfiscal']) ?></p>
             </td>
         </tr>
         <tr>
             <td>
                 <p>7. Ciudad: <?php echo strtoupper( $planilla[0]['nciudades']) ?></p>
             </td>
             <td>
                 <p>8. Estado: <?php echo strtoupper( $planilla[0]['nestados']) ?></p>
             </td>
             <td>
                 <p>9. Zona Postal: <?php echo strtoupper( $planilla[0]['zonapostal']) ?></p>
             </td>
         </tr>
          <tr>
             <td>
                 <p>10. Telefono: <?php echo strtoupper( $planilla[0]['telef1']) ?></p>
             </td>
             <td colspan="2">
                 <p>11. Correo Electronico: <?php echo strtoupper( $planilla[0]['email']) ?></p>
             </td>
         </tr>
       <tr  bgcolor="#AEADAC" >
            <td colspan="3" class="cabecera" >B. DATOS DEL REPRESENTATE LEGAL</td>
        </tr>
        <tr>
            <td style=" width: 300px">
                <p>12. Apellidos y Nombres: <?php echo strtoupper( $planilla[0]['nrplegal']) ?></p>
            </td>
            <td colspan="2" >
                <p>13. N° Cédula identidad: <?php echo strtoupper( $planilla[0]['cedulareplegal']) ?></p>
            </td>
        </tr>
        <tr>
             <td colspan="3" >
                 <p>14. Dirección de Residencia o Domicilio Fiscal: <?php echo strtoupper( $planilla[0]['direccionreplegal']) ?></p>
             </td>
            
         </tr>
         <tr>
              <td>
                 <p>15. Telefono: <?php echo strtoupper( $planilla[0]['telereplegal']) ?></p>
             </td>
             <td colspan="2">
                 <p>16. Correo Electronico: <?php echo strtoupper( $planilla[0]['emailreplegal']) ?></p>
             </td>
             
         </tr>
          <tr  bgcolor="#AEADAC" >
             <td colspan="3" class="cabecera" >C. DATOS DE LA AUTOLIQUIDACIO DE LA CONTRIBUCION ESPECIAL</td>
         </tr>
         <tr>
             <td colspan="2" class="tercer_bloque">17. BASE IMPONIBLE .......................................................................................</td>
             <td style=" text-align: right" ><p><b><?php echo $this->funciones_complemento->devuelve_cifras_unidades_mil($planilla[0]['baseimpo']) ?></b></p></td>
         </tr>
         <tr>
             <td colspan="2" class="tercer_bloque">18. ALICUOTA IMPOSITIVA ( <?php echo strtoupper( $planilla[0]['alicuota']) ?>% ) ............................................................</td>
             <td style=" text-align: right" ><p><b><?php echo ($planilla[0]['tdeclaraid']==2? $this->funciones_complemento->devuelve_cifras_unidades_mil($planilla[0]['montopagar']) : $this->funciones_complemento->devuelve_cifras_unidades_mil($planilla[0]['plasus_alicuota']) )?></b></p></td>
         </tr>
         <tr>
             <td colspan="2" class="tercer_bloque">19. MENOS EXONERACIÓN O REBAJA (SEGÚN ACTO N°_________)............</td>
             <td style=" text-align: right" ><p><b>0</b></p></td>
         </tr>
         <tr>
             <td colspan="2" class="tercer_bloque">20. MENOS CRÉDITO FISCAL ...........................................................................</td>
             <td style=" text-align: right" ><p><b>0</b></p></td>
         </tr>
         <tr>
             <td colspan="2" class="tercer_bloque">21. MENOS CONTRIBUCIÓN PAGADA EN PERIODOS ANTERIORES ..............</td>
             <td style=" text-align: right" ><p><b><?php echo ($planilla[0]['tdeclaraid']==2? 0 : $this->funciones_complemento->devuelve_cifras_unidades_mil($planilla[0]['monto_anterior']) ) ?></b></p></td>
         </tr>
         <tr>
             <td colspan="2" class="tercer_bloque">22. TOTAL CONTRIBUCIÓN A PAGAR .............................................................</td>
             <td style=" text-align: right" ><p><b><?php echo $this->funciones_complemento->devuelve_cifras_unidades_mil($planilla[0]['montopagar']) ?></b></p></td>
         </tr>
          <tr  bgcolor="#AEADAC" >
             <td colspan="3" class="cabecera" >D. TARIFA POR TIPO DE CONTRIBUYENTE</td>
         </tr>
         <tr>
             <td class="cabecera">Tipo de contribuyente:</td>
             <td class="cabecera">Alicuota Impositiva:</td>
             <td class="cabecera">Periodo Impositivo:</td>
         </tr>
         <tr>
             <td class="tercer_bloque">EXHIBIDORES CINEMÁTOGRAFICOS (ART. 50):</td>
             <td class="tercer_bloque">
                 3% .......................................... 2005<br />
                 4% .......................................... 2006<br />
                 5% .............................. 2007(en adelante)

             </td>
             <td align="center" class="tercer_bloque">MENSUAL</td>
         </tr>
         <tr>
             <td class="tercer_bloque">EMPRESA DE SERVICIO DE TELEVISIÓN ABIERTA (ART. 51):</td>
             <td class="tercer_bloque">
                 Desde 25.000 UT hasta 40.000 UT .................... 0.5%<br />
                 Más de 40.000 UT hasta 80.000 UT ................... 1.0%<br />
                 Más de 80.000 UT.......... 1.5%

             </td>
             <td align="center" class="tercer_bloque">ANUAL</td>
         </tr>
         <tr>
             <td class="tercer_bloque">EMPRESAS DE SERVICIOS DE DIFUSION SE&Ntilde;AL DE TELEVISIÓN <br>POR SUSCRIPCIÓN (ART. 52):</td>
             <td class="tercer_bloque">
                 0.5% .......................................... 2006<br />
                 1.0% .......................................... 2007<br />
                 1.5% ................. 2008 (en adelante)

             </td>
             <td align="center" class="tercer_bloque">TRIMESTRAL</td>
         </tr>
         <tr>
             <td class="tercer_bloque" >DISTRIBUIDORES DE OBRAS CINEMÁTOGRAFICAS (ART. 53):</td>
             <td align="center" style=" padding:5px;" class="tercer_bloque" >5%</td>
             <td align="center" class="tercer_bloque">ANUAL</td>
         </tr>
         <tr>
             <td class="tercer_bloque">VENTA Y ALQUILER DE VIDEORAMAS (ART. 54):</td>
             <td align="center" style=" padding: 5px;" class="tercer_bloque" >5%</td>
             <td align="center" class="tercer_bloque">MENSUAL</td>
         </tr>
         <tr>
             <td class="tercer_bloque">SERVICIO TÉCNICO, TECNOLÓGICO O LOGÍSTICO PARA LA <br>PRODUCCIÓN  DE OBRAS CINEMÁTOGRAFICAS (ART. 56):</td>
             <td align="center" style=" padding: 5px;" class="tercer_bloque">1%</td>
             <td align="center" class="tercer_bloque">TRIMESTRAL</td>
         </tr>
         </tbody>
    </table> 
    
    <!--<table class="page_footer" >-->
    <table class="tabla-cuerpo">
            <tr>
                <td style=" text-align: center; font-weight: bold; font-size:10px;" colspan="3" class="info-recepcion"> DECLARACION JURADA</td>
            </tr>
            <tr style="border:1px solid black;">
				<td style=" border: 1px solid black; text-align: justify; width: 700px; padding: 5px; font-size: 8px; line-height: 1.5">
				   YO, _______________________________________________, TITULAR DE LA CULA DE IDENTIDAD N _____________________, DE CONFORMIDAD CON LO DISPUESTO EN EL ARTULO
				   147 DEL CODIGO ORGANICO TRIBUTARIO, DECLARO QUE LOS DATOS Y CIFRAS QUE APARECEN EN LA  PRESENTE PLANILLA DE AUTOLIQUIDACI SON REFLEJO FIEL Y EXACTO DE LOS
				   DATOS CONTENIDOS EN LOS REGISTROS DE CONTABILIDAD Y CONTROL TRIBUTARIO QUE HAN SIDO LLEVADOS CONFORME A LAS LEYES QUE REGULAN LA MATERIA.<br /><br />

				   EN___________________ A LOS____ DIAS DEL MES DE__________________DEL AÑO________________
				   <br /><br />

				   <div style=" width: 300px;text-align: center; border: 0px solid black; margin-left: 220px">
					   __________________________________<br />
						   FIRMA DEL REPRESENTANTE LEGAL
				   </div>
                 </td> 
                 <td></td>
                 <td></td>
            </tr>

     </table> <br>   
     
     <!--tabla con los datos especificos-->
     <table style="border:1px solid black;" class="tercer_bloque">
		<tr>
			<td>
				<br>  <b>N° RIF: </b> <br> 
			</td>
			<td style="width: 620px;">
				<br> &nbsp;&nbsp;&nbsp;&nbsp;  <?php echo strtoupper( $planilla[0]['rif']) ?> <br> 
			</td>
		</tr>
		
		<tr>
			<td>
				<br>  <b>Tipo de Contribuyente: </b> <br>  
			</td>
			<td>
				<br>  &nbsp;&nbsp;&nbsp;&nbsp; <?php echo $planilla[0]['tipocontid'] ?> <br> 
			</td>
		</tr>
		
		<tr>
			<td>
				 <br>  <b>Tipo de Declaración: </b> <br> 
			</td>
			<td>
				<br>  &nbsp;&nbsp;&nbsp;&nbsp; <?php echo $planilla[0]['tdeclaraid'] ?> <br>
			</td>
		</tr>
		
		<tr>
			<td>
				<br>  <b>periodo: </b> <br>  
			</td>
			<td>
				<br> &nbsp;&nbsp;&nbsp;&nbsp;  <?php echo $planilla[0]['periodo_declara'] ?> <br> 
			</td>
		</tr>
		
		<tr>
			<td>
				<br>  <b>Año: </b> <br> 
			</td>
			<td>
                            <br> &nbsp;&nbsp;&nbsp;&nbsp;  <?php echo $planilla[0]['anio_declara'] ?>  <br>  
			</td>
		</tr>
		
		<tr>
			<td>
				<br>  <b>Importe a Cancelar: </b> <br>  
			</td>
			<td>
				<br> &nbsp;&nbsp;&nbsp;&nbsp; <?php echo $this->funciones_complemento->devuelve_cifras_unidades_mil($planilla[0]['montopagar']) ?><br> 
			</td>
		</tr>
                <tr>
			<td>
				<br>  <b>Validador: </b> <br>  
			</td>
			<td>
				<br> &nbsp;&nbsp;&nbsp;&nbsp; <?php echo $planilla[0]['ident_banco'] ?><br> 
			</td>
		</tr>
	 </table>	 
     <!-- fin tabla datos especificos -->                                            
                 
    
</page>
