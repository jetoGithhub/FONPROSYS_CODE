<?php

ob_start();  
echo "<page>   

    <table cellspacing='2' border='1px' style='border-color: #000; border-collapse: collapse;' width='100%'>
        <tr>
            <td class='titulos' colspan='4'>
              <br/> <center>A. DATOS DEL CONTRIBUYENTE </center><br/>
            </td>
        </tr>
        
        <tr>
            <td class='datos' width='50%'>
                8. Razón Social: <br/> <br/>
            </td>
            <td class='datos' width='50%' colspan='3'>
                9. Denominación Comercial: <br/> <br/>
            </td>
        </tr>
        
        <tr>
            <td class='datos' width='50%'>
                10. Actividad Económica: <br/> <br/>
            </td>
            <td>
                <table border='0px' width='100%'>
                <tr>
                   
                    <td class='datos' width='30%'>
                        11. N° de R.I.F.: <br/> <br/>
                    </td>
                     <td class='datos bordes_vert_td' width='30%'>
                        12. N° Registro de Cinematografía: <br/> <br/>
                    </td>
                  </tr>
              </table>
            </td>
        </tr>
        <tr>
            <td class='datos' colspan='3'>
                13. Domicilio Fiscal: <br/> <br/>
            </td>
        </tr>
        
        <tr>
          <td colspan='4' width='50%'>
              <table border='0px' width='100%'>
                <tr>
                   
                    <td class='datos' width='30%'>
                        14. Ciudad o Lugar: <br/> 
                    </td>
                     <td class='datos bordes_vert_td' width='30%'>
                        15. Estado o Entidad Federal: <br/> 
                    </td>
                    <td class='datos bordes_vert_td' width='20%'>
                        16. Zona Postal: <br/> 
                    </td><!--    -->
                  </tr>
              </table>
            </td>
         </tr>
        
        <tr>
            <td class='datos' width='50%'>
                17. Teléfonos: <br/> <br/>
            </td>
            <td class='datos' width='50%' colspan='3'>
                18. Correo Electrónico: <br/> <br/>
            </td>
        </tr>
        
        <tr>
            <td class='titulos' colspan='4'>
              <br/> <center>B. DATOS DEL REPRESENTANTE LEGAL </center><br/>
            </td>
        </tr>
        
        <tr>
            <td class='datos' width='50%'>
                19. Apellidos y Nombres Representante(s) Legal(es): <br/> <br/>
            </td>
            <td class='datos' width='50%' colspan='3'>
                20. N° de Cédula(s) de Identidad: <br/> <br/>
            </td>
        </tr>
        
         <tr>
            <td width='50%'>
                <table width='100%' border='0'>
                    <tr>
                        <td class='datos'>19.1.</td>
                        <td class='datos'>19.3.</td>
                    </tr>
                </table>
            </td>
            
            <td class='datos' width='50%'>
                <table width='100%' border='0'>
                    <tr>
                        <td class='datos' width='50%'>20.1. V-</td>
                        <td class='datos'>20.3.</td>
                    </tr>
                </table>
            </td>
         </tr>

         <tr>
            <td width='50%'>
                <table width='100%' border='0'>
                    <tr>
                        <td class='datos'>19.2.</td>
                        <td class='datos'>19.4.</td>
                    </tr>
                </table>
            </td>
            
            <td class='datos' width='50%'>
                <table width='100%' border='0'>
                    <tr>
                        <td class='datos' width='50%'>20.2.</td>
                        <td class='datos'>20.4.</td>
                    </tr>
                </table>
            </td>
         </tr>
         
         <tr>
             <td colspan='2'>
                 <table width='100%' border='0'>
                     <tr>
                         <td class='datos bordes_vert_der_td' rowspan=2 width='75%' valign='top'>21. Dirección de Residencia o Domicilio Fiscal:</td>
                         <td class='datos'>22. Teléfonos:</td>
                     </tr>
                     <tr>
                        <td class='datos bordes_sup_td'>23. Correo Electrónico:</td>
                    </tr>
                 </table>
             </td> 
         </tr>
         
         <tr>
            <td class='titulos' colspan='4'>
              <br/> <center>C. DATOS DE LA AUTOLIQUIDACIÓN DE LA CONTRIBUCIÓN ESPECIAL</center><br/>
            </td>
        </tr>
        
        
         <tr>
            <td class='datos' width='50%'>
                24. BASE IMPONIBLE 
                 .........................................................................................................................................
              <br/> <br/>
            </td>
            <td class='datos' width='50%' colspan='3'>
                <br/> <br/>
            </td>
        </tr>
        
        <tr>
            <td class='datos' width='50%'>
                25. ALICUOTA IMPOSITIVA (<u>1,0%</u>) 
                 ....................................................................................................................
              <br/><span style=' font-size: 9px'>(según tabla F)</span> <br/>
            </td>
            <td class='datos' width='50%' colspan='3'>
                <br/> <br/>
            </td>
        </tr>
        
        <tr>
            <td class='datos' width='50%'>
                26. MENOS EXONERACIÓN O REBAJA (SEGÚN ACTO N° __________________)
                 .......................................
              <br/> <br/>
            </td>
            <td class='datos' width='50%' colspan='3'>
                <br/> <br/>
            </td>
        </tr>
        
        <tr>
            <td class='datos' width='50%'>
                27. MENOS CRÉDITO FISCAL
                 ...........................................................................................................................
              <br/> <br/>
            </td>
            <td class='datos' width='50%' colspan='3'>
                <br/> <br/>
            </td>
        </tr>
            
        <tr>
            <td class='datos' width='50%'>
                28. MENOS CONTRIBUCIÓN PAGADA EN PERIODOS ANTERIORES
                 ............................................................
              <br/> <br/>
            </td>
            <td class='datos' width='50%' colspan='3'>
                <br/> <br/>
            </td>
        </tr>
        
        <tr>
            <td class='datos' width='50%'>
                29. TOTAL CONTRIBUCIÓN A PAGAR
                 ...............................................................................................................
              <br/> <br/>
            </td>
            <td class='datos' width='50%' colspan='3'>
                <br/> <br/>
            </td>
        </tr>
        
        <tr>
            <td class='titulos'>
              <br/> <center>D. DATOS DEL PAGO DE INTERES MORATORIO POR PAGO EXTEMPORANEO O REPARO FISCAL</center><br/>
            </td>
            <td class='titulos'>
              <br/> <center>E. DATOS DEL PAGO DE MULTA</center><br/>
            </td>
        </tr>
        
        <tr>
            <td class='datos' width='50%'>
                <table border='0' width='100%'>
                    <tr>
                        <td class='datos bordes_vert_der_td' width='40%'>
                            30. N° RESOLUCIÓN
                        </td>
                        <td rowspan='2' class='datos'><br /></td>
                    </tr>
                    <tr>
                        <td class='datos bordes_sup_td bordes_vert_der_td'>
                            30.1. N° ACTA FISCAL
                        </td>
                    </tr>
                    <tr>
                        <td class='datos bordes_sup_td bordes_vert_der_td'>
                            31. FECHA DE NOTIFICACIÓN
                        </td>
                        <td class='datos bordes_sup_td'>
                            <br /> 
                        </td>
                    </tr>
                    <tr>
                        <td class='datos bordes_sup_td bordes_vert_der_td'>
                            32. INTERESES MORATORIOS
                        </td>
                        <td class='datos bordes_sup_td'>
                            <br /> 
                        </td>
                    </tr>
                    <tr>
                        <td class='datos bordes_sup_td bordes_vert_der_td'>
                            33. REPARO FISCAL
                        </td>
                        <td class='datos bordes_sup_td'>
                            <br /> 
                        </td>
                    </tr>
                    <tr>
                        <td class='datos bordes_sup_td bordes_vert_der_td'>
                            34. DEUDA TOTAL (32+33)
                        </td>
                        <td class='datos bordes_sup_td'>
                            <br /> 
                        </td>
                    </tr>
                    <tr>
                        <td class='datos bordes_sup_td bordes_vert_der_td'>
                            35. DEPOSITO DEL BANCO <br /><br />
                        </td>
                        <td class='datos bordes_sup_td'>
                            36. N° PLANILLA DE DEPOSITO <br /><br />
                        </td>
                    </tr>
                </table>
            </td>
            <td class='datos' width='50%'>
                <table border='0' width='100%'>
                    <tr>
                        <td class='datos bordes_vert_der_td' width='40%'>
                           <br /> 37. N° RESOLUCIÓN<br /><br />
                        </td>
                        <td class='datos'><br /><br /></td>
                    </tr>
                    <tr>
                        <td class='datos bordes_sup_td bordes_vert_der_td' width='40%'>
                           <br /> 38. FECHA DE NOTIFICACIÓN<br /><br />
                        </td>
                        <td class='datos bordes_sup_td'><br /><br /></td>
                    </tr>
                    <tr>
                        <td class='datos bordes_sup_td bordes_vert_der_td' width='40%'>
                           <br /> 39. MULTA<br /><br />
                        </td>
                        <td class='datos bordes_sup_td'><br /><br /></td>
                    </tr>
                    <tr>
                        <td class='datos bordes_sup_td bordes_vert_der_td'>
                            40. DEPOSITO DEL BANCO <br /><br />
                        </td>
                        <td class='datos bordes_sup_td'>
                            41. N° PLANILLA DE DEPOSITO <br /><br />
                        </td>
                    </tr>
                    
                    
                </table>
            </td>
        </tr>
        
        <tr>
            <td class='titulos' colspan='4'>
              <br/> <center>F. TARIFA POR TIPO DE CONTRIBUYENTE </center><br/>
            </td>
        </tr>
        
        <tr>
            <td colspan='4'>
                <table border='0' width='100%'>
                    <tr>
                        
                        <td class='datos bordes_vert_der_td'>
                          <center><b>Art.</b></center>
                        </td>
                        <td class='datos bordes_vert_der_td'>
                            <center><b>Tipo de Contribuyente</b></center>
                        </td>
                        <td class='datos bordes_vert_der_td'>
                            <center><b>Alícuota Impositiva</b></center>
                        </td>
                        <td class='datos'>
                            <center><b>Período Impositivo</b></center>
                        </td>
                    </tr>
                    
                    <tr>
                        <td class='datos bordes_sup_td bordes_vert_der_td'>
                            <br /><center>50</center><br />
                        </td>
                        <td class='datos bordes_sup_td bordes_vert_der_td'>
                            <br />
                            EXHIBIDORES CINEMATOGRÁFICOS
                            </bR>
                        </td>
                        <td class='datos bordes_sup_td bordes_vert_der_td'>
                            <center>
                                3% ............................. 2005 <br />
                                4% ............................. 2006 <br />
                                5% ....... 2007 (en adelante)
                            </center>
                        </td>
                        <td class='datos bordes_sup_td'>
                            <br /><center>MENSUAL</center><br />
                        </td>
                    </tr>
                    <tr>
                        <td class='datos bordes_sup_td bordes_vert_der_td'>
                            <br /><center>51</center><br />
                        </td>
                        <td class='datos bordes_sup_td bordes_vert_der_td'>
                            <br />
                            EMPRESA DE SERVICIO TELEVISIÓN SEÑAL ABIERTA
                            </bR>
                        </td>
                        <td class='datos bordes_sup_td bordes_vert_der_td'>
                            <center>
                                Desde 25.000 UT hasta 40.000 UT ......... 0.5% <br />
                                Más de 40.000 UT hasta 80.000 UT ........ 1.0%  <br />
                                Más de 80.000 UT .................................... 1.5%
                            </center>
                        </td>
                        <td class='datos bordes_sup_td'>
                            <br /><center>ANUAL</center><br />
                        </td>
                    </tr>
                    
                    <tr>
                        <td class='datos bordes_sup_td bordes_vert_der_td'>
                            <br /><center>52</center><br />
                        </td>
                        <td class='datos bordes_sup_td bordes_vert_der_td'>
                            <br />
                            EMPRESAS DE SERVICIOS DE DIFUSIÓN SEÑAL DE TELEVISIÓN POR SUSCRIPCIÓN
                            </bR>
                        </td>
                        <td class='datos bordes_sup_td bordes_vert_der_td'>
                            <center>
                                0.5% ............................. 2006 <br />
                                1.0% ............................. 2007 <br />
                                1.5% ....... 2008 (en adelante)
                            </center>
                        </td>
                        <td class='datos bordes_sup_td'>
                            <br /><center>TRIMESTRAL</center><br />
                        </td>
                    </tr>
                    
                    <tr>
                        <td class='datos bordes_sup_td bordes_vert_der_td'>
                            <br /><center>53</center><br />
                        </td>
                        <td class='datos bordes_sup_td bordes_vert_der_td'>
                            <br />
                            DISTRIBUIDORES DE OBRAS CINEMATOGRÁFICAS
                            </bR>
                        </td>
                        <td class='datos bordes_sup_td bordes_vert_der_td'>
                            <center>5%</center>
                        </td>
                        <td class='datos bordes_sup_td'>
                            <br /><center>ANUAL</center><br />
                        </td>
                    </tr>
                    
                    <tr>
                        <td class='datos bordes_sup_td bordes_vert_der_td'>
                            <br /><center>54</center><br />
                        </td>
                        <td class='datos bordes_sup_td bordes_vert_der_td'>
                            <br />
                            VENTA Y ALQUILER DE VIDEOGRAMAS
                            </bR>
                        </td>
                        <td class='datos bordes_sup_td bordes_vert_der_td'>
                            <center>5%</center>
                        </td>
                        <td class='datos bordes_sup_td'>
                            <br /><center>MENSUAL</center><br />
                        </td>
                    </tr>
                    
                    <tr>
                        <td class='datos bordes_sup_td bordes_vert_der_td'>
                            <br /><center>56</center><br />
                        </td>
                        <td class='datos bordes_sup_td bordes_vert_der_td'>
                            <br />
                            SERVICIO TÉCNICO, TECNOLOGICO O LOGÍSTICO PARA LA PRODUCCIÓN DE OBRAS CINEMATOGRÁFICAS 
                            </bR>
                        </td>
                        <td class='datos bordes_sup_td bordes_vert_der_td'>
                            <center>1%</center>
                        </td>
                        <td class='datos bordes_sup_td'>
                            <br /><center>TRIMESTRAL</center><br />
                        </td>
                    </tr>
                    
                </table>
            </td>
        </tr>
    </table>
    <table width='100%'>
        <tr>
            <td class='datos'>
                <center><b>DECLARACIÓN JURADA</b></center>
            </td>
        </tr>
    </table>
    <table width='100%' border='1px' style='border-color: #000; border-collapse: collapse;' width='100%'>
        <tr>
            <td class='datos'>
                <p align='justify'>YO, ___________________________________, TITULAR DE LA CEDULA DE IDENTIDAD N° ___________, DE CONFORMIDAD
                CON LO DISPUESTO EN EL ARTÍCULO 147 DEL CÓDIGO ORGÁNICO TRIBUTARIO, DECLARO QUE LOS DATOS Y CIFRAS QUE 
                APARECEN EN LA PRESENTE PLANILLA DE AUTOLIQUIDACIÓN SON REFLEJO FIEL Y EXACTO DE LOS CONTENIDOS EN LOS 
                REGISTROS DE CONTABILIDAD Y CONTROL TRIBUTARIO QUE HAN SIDO LLEVADOS CONFORME A LAS LEYES QUE REGULAN LA MATERIA.</p>
                <br />
                EN ___________________ A LOS ____ DIAS DEL MES DE ___________ DEL AÑO _______
                <br /><br /><br />
                <center>_________________________________<br />
                FIRMA DEL REPRESENTANTE LEGAL</center>
            </td>
                
            </td>
        </tr>
    </table>
</page>";



$content = ob_get_clean();


    require_once('include/librerias/html2pdf/html2pdf.class.php');
    $html2pdf = new HTML2PDF('P','A4','fr');
    $html2pdf->WriteHTML($content);
    $html2pdf->Output('exemple2.pdf','D');