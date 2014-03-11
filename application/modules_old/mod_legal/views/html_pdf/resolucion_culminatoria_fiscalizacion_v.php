<style type="text/css">
    body,p,label,table{
        font-family:Arial, Helvetica, sans-serif;
        font-style: normal;
        font-size: 12px;
        text-align: justify;
        line-height: 1.5;
    }
    
    .page_footer {
                    width: 87%; 
                    border: none; 
                    background-color: red; 
                    border-top: solid 1mm black; 
                    padding:1mm; 
                    margin-left:55px
    }
    .firma{margin-left: 300px}
    .tabla_body{ margin-left: 30px}
    .tabla_body th{ width: 80px; font-size: 10px; text-align: center;}
    .tabla_body tr#head{ background: #B5B5B5 }
    .tabla_body table{ border-collapse: collapse; border-color: #868686 }
    
    .tabla_body2{ margin-left: 30px}
    .tabla_body2 th{ width: 105px; font-size: 10px; text-align: center;}
    .tabla_body2 tr#head{ background: #B5B5B5 }
    .tabla_body2 table{ border-collapse: collapse; border-color: #868686 }
    
    .firma table{ width: 100%}
    .right p{ padding-left: 70px}
    .citas1{
         padding-left: 30px;
        padding-right: 30px;
/*        font-size: 14px;*/
        font-style: italic;
        /*text-align: justify;*/
        line-height: 2.0;
        text-decoration: underline;
    }
    .tr-body{
        font-size: 10px; 
        text-align: center;
    }
/*    .citas2{ 
        font-family:Arial, Helvetica, sans-serif;
        font-size: 10px;
        font-style: italic;
        padding-left: 30px;
        padding-right: 30px;
         text-align: justify;
        line-height: 1.5;
       
    }*/
</style>

<page backtop="16mm" backbottom="30mm" backleft="16mm" backright="16mm" style="font-size: 12pt" >
                            <!-- seccion de la cabecera con el logo de la institucion-->
    <page_header>
        <div style=" position: absolute; width: 87%;  margin-left:55px">
            <img src="<?php echo base_url()."/include/imagenes/encabezado_viejo.png"; ?>" style=" width:100%; height: 55px ;"/>
        </div>        
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
    
    <p style=" text-align: left; margin-top: 1px"><b>CNAC/RCF-<?php echo $data[$reparoid]['resol_multa']; ?></b></p>
    <p style=" text-align: right;"><b>Caracas,</b></p>
    <br /><br />
    <!-- Titulo del acta de autorizacion fiscal-->
    <p style=" text-align: center;"><b>RESOLUCION DE CULMINATORIA DE FISCALIZACI&Oacute;N</b></p>
    
                                    <!-- contenido de la resolucion-->
    <p>
        De conformidad con lo establecido en los artículos 185 y 186 del Código Orgánico Tributario publicado en Gaceta Oficial de la República Bolivariana de Venezuela Número 37.305, de fecha 17 de octubre de 2001 y según lo previsto con los artículos 41 y 63 de la Ley de la Cinematografía Nacional (LCN), publicada en la Gaceta Oficial de la República Bolivariana de Venezuela No. 38.281 y reimpresa, por error del ente emisor, en fecha 26 de octubre de 2005 publicada en la Gaceta Oficial de la República Bolivariana Extraordinario Nº 5.789, se procede a emitir la presente Resolución que concluye el procedimiento de determinación de oficio sobre base cierta,
        en relación al Acta Fiscal Nº<b> CNAC/FONPROCINE/GFT/AFR-<?php echo $data[$reparoid]['nacta_reparo']; ?></b>, notificada en fecha <?php echo date('d-m-Y',strtotime($data[$reparoid]['fechanoti_reparo'])); ?>, 
        según lo dispuesto en el numeral 1º del artículo 162 del referido Código, para el ejercicio fiscal comprendido desde el 01 de enero de <b><?php echo $data[$reparoid]['periodo_afiscalizar']; ?></b>, hasta el 31 de diciembre de <b><?php echo $data[$reparoid]['periodo_afiscalizar']; ?></b>,
        ambos inclusive; y levantada según lo establecido en el artículo 63 de la referida Ley de la Cinematografía Nacional, mediante la cual se dejó constancia de los resultados de la fiscalización practicada a la sociedad mercantil <b><?php echo $data[$reparoid]['contribuyente']; ?></b> 
        , identificada con el Registro de Información Fiscal (R.I.F.)&nbsp; <b><?php echo $data[$reparoid]['rif']; ?></b>, inscrita en la Oficina del <?php echo $data[$reparoid]['oficina_registro']; ?>, en fecha <?php echo $data[$reparoid]['fecha_registro']; ?>
        , bajo el Nº <?php echo $data[$reparoid]['numero_registro']; ?>, Tomo <b><?php echo $data[$reparoid]['rmtomo']; ?></b>, y domiciliada en <b><?php echo $data[$reparoid]['domicilio_fisal']; ?></b>, sobre  la  base  de  los  ingresos  brutos  efectivamente percibidos por la contribuyente para el período comprendido desde el 31 de Enero de <b><?php echo $data[$reparoid]['periodo_afiscalizar']; ?> </b> hasta el 31 de diciembre de <b><?php echo $data[$reparoid]['periodo_afiscalizar']; ?></b>  
    </p>
    <br />
    <p style=" text-align: center;"><b>EXPOSICI&Oacute;N DE LOS HECHOS</b></p>
    <br />
    <p>
        Mediante Autorización Fiscal Nº<b> CNAC/FONPROCINE/GFT/AF-<?php echo $data[$reparoid]['nro_autorizacion']; ?></b> &nbsp;de fecha <?php echo date('d-m-Y',strtotime($data[$reparoid]['fecha_autorizacion'])); ?> 
        , el Presidente del Centro Nacional Autónomo de Cinematografía (CNAC), facultado para éste acto conforme al numeral 1 del artículo 13  y 41 de la Ley de la Cinematografía Nacional, en uso de las facultades conferidas en el numeral 1 del artículo 127 y 178 del Código Orgánico Tributario, publicado en Gaceta Oficial Número 37.305, de fecha 17 de octubre de 2001,
        designó al funcionario <b><?php echo $data[$reparoid]['fiscal_ejecutor']; ?></b>, titular de la cédula de Identidad Nº <b><?php echo $data[$reparoid]['cedula_fiscal']; ?></b>
        en su condición de Auditor Fiscal, adscrito a la Gerencia de Fiscalización Tributaria del Fondo de Promoción y Financiamiento del Cine (FONPROCINE), para fiscalizar y determinar de oficio sobre base cierta, la autoliquidación y
        pago de la Contribución Especial causada según lo dispuesto en el artículo &nbsp;<b><?php echo $data[$reparoid]['narticulo']; ?></b>&nbsp; de la Ley de la Cinematografía Nacional, por &nbsp;<?php echo $data[$reparoid]['text_articulo']; ?>,&nbsp; con fundamento a lo dispuesto en la Sección Segunda, Capítulo I, Título IV del Código Orgánico Tributario.
     </p>
     <br />
     <p>
        En este sentido, el Fiscal de Rentas designado, levantó el Acta de Requerimiento Nº <b>CNAC/FONPROCINE/GFT/AR-<br /><?php echo $data[$reparoid]['nro_autorizacion']; ?>,</b> de fecha <?php echo date('d-m-Y',strtotime($data[$reparoid]['fecha_requerimiento'])); ?>, 
        de conformidad con el numeral 4 del artículo 137 del Código Orgánico Tributario, para obtener los elementos necesarios que se requieren en la determinación oficiosa tributaria sobre base cierta, tal como lo establece el artículo 131 del Código Orgánico Tributario, concediendo al contribuyente <b><?php echo $data[$reparoid]['contribuyente']; ?></b>, un plazo de 3 días hábiles para suministrar la documentación solicitada. 
     </p>
     <br />
     <p>
        La referida documentación fue consignada a la funcionaria por parte de la contribuyente, según consta en Acta de Recepción de Documentos Nº <b>CNAC/FONPROCINE/GFT/AR-<?php echo $data[$reparoid]['nro_autorizacion']; ?></b>, de fecha <?php echo date('d-m-Y',strtotime($data[$reparoid]['fecha_recepcion'])); ?>,
        en la cual se señala la recepción de los siguientes documentos: copia de las facturas, notas de crédito y notas de débito sobre las ventas, copia de la declaración definitiva de Impuesto Sobre la Renta (SENIAT), copia de las declaraciones del Impuesto al Valor Agregado (SENIAT) acompañado de sus respectivos libros de venta, copia del Balance General y Estado de Resultados correpondientes al período fiscalizado, balance de comprobación menual y Mayor (es) Analítico (s) de las cuentas de ingreso correpondientes al período fiscalizado. 
     </p>
     <p>
         De la revisión practicada se levantó el Acta Fiscal Nº <b> CNAC/FONPROCINE/GFT/AFR-<?php echo $data[$reparoid]['nacta_reparo']; ?></b>, de fecha <?php echo date('d-m-Y',strtotime($data[$reparoid]['fechanoti_reparo'])); ?>,en la cual se determinó lo siguiente:
     </p>
     <br /><br /><br />
     <p class="citas1">
         <b>“PRIMERO:</b> Imponer un reparo fiscal a la sociedad mercantil <b><?php echo $data[$reparoid]['contribuyente']; ?></b>, por la cantidad de <?php echo $this->monedas_texto->num_to_letras(trim($data[$reparoid]['total_reparo'])); ?>, correspondiente a la contribución especial y no pagada para los períodos fiscalizados.<br />
         <b>SEGUNDO:</b> Aceptado el reparo impuesto en la conclusión primera, la sociedad mercantil<b><?php echo $data[$reparoid]['contribuyente']; ?></b>, debe presentar las planillas de autoliquidación correspondientes a los periodos reparados, y proceder a su respectivo pago, dentro de los<b>quince (15)</b> días hábiles posteriores a la fecha de notificación de la presente acta, de acuerdo a lo dispuesto en el <b>artículo 185</b> del Código Orgánico Tributario vigente.<br />
         <b>TERCERO:</b> El Fondo de Promoción y Financiamiento del Cine <b>(FONPROCINE)</b>, cumple con informarle, que la cuenta dispuesta para la cancelación de los montos expresados, por concepto de reparo, en el cuerpo de esta Acta, es la identificada como  <b>cuenta corriente, Nº 0134-0861-18-8613000268,</b> a nombre de: <b>CENTRO NACIONAL AUTÓNOMO DE CINEMATOGRAFÍA  (CNAC),</b> de la institución financiera <b>Banesco Banco Universal,</b> o en su defecto mediante planilla de pago a FONPROCINE correspondiente al  Banco Provincial, la cual puede ser retiradas por nuestras oficinas.<br />
         <b>CUATRO:</b> Notificar a la sociedad de comercio <b><?php echo $data[$reparoid]['contribuyente']; ?></b>, de los resultados del procedimiento de determinación tributaria reflejados a lo largo del cuerpo de la presente Acta Fiscal a tenor de lo previsto en el <b>artículo 162</b> del Código Orgánico Tributario  vigente.<b>”</b>
     </p>
     <br />
     <p style=" text-align: center;"><b>ACEPTACIÓN Y PAGO DEL REPARO</b></p>
     <p>
        El Código Orgánico Tributario en su artículo 186 establece lo siguiente:         
     </p>
     <br />
     <p class="citas1">
         <b>“Artículo 186</b>. Aceptado el reparo y pagado el tributo omitido, la Administración Tributaria, mediante resolución, procederá a dejar constancia de ello y liquidará los intereses moratorios, la multa establecida en el parágrafo segundo del artículo 111 de este Código, y demás multas a que hubiere lugar, conforme a lo previsto en este Código, La resolución que dicte la Administración Tributaria pondrá fin al procedimiento.” (Subrayado nuestro).
     </p>
     <br />
     <p>
         Así, esta Administración Tributaria recibió por parte de la sociedad mercantil <b><?php echo $data[$reparoid]['contribuyente']; ?></b> el pago correspondiente al Reparo Fiscal levantado por omisión del tributo determinado según Acta Fiscal Nº <b>CNAC/<br />FONPROCINE/GFT/AFR-<?php echo $data[$reparoid]['nacta_reparo']; ?></b>, notificada en fecha <?php echo date('d-m-Y',strtotime($data[$reparoid]['fechanoti_reparo'])); ?>,
         por la cantidad de <?php echo $this->monedas_texto->num_to_letras(trim($data[$reparoid]['total_reparo'])); ?>,dicho pago fue realizado en la Institución Financiera Banco Universal Banesco,  como se explica a continuación:
         
     </p>
     <br />
     <div class="tabla_body">
         <table border="2" >
             <thead>
               <tr id="head">
                     <th>Periodo<br />Fiscalizado</th><th>Nº de Planilla<br />FONPROCINE</th><th>Nº de Planilla de<br />Deposito Bancario</th><th>Fecha de Pago<br/>del Tributo</th><th>Monto Cancelado<br />en Bs</th><th>Fecha de Recibido</th><th>Obeservaciones</th>                

                 </tr>
              </thead>
                 
                     <?php 
                        foreach ($detalle_reparo as $clave =>$valor):
                            echo "<tr class='tr-body'>
                                        <td>".$valor['periodo']."</td>
                                        <td></td>
                                        <td>".$valor['nudeposito']."</td>
                                        <td>".$valor['fechapago']."</td>
                                        <td>".$valor['nmontopagar']."</td>
                                        <td></td>
                                        <td></td>
                                  </tr>";
                      endforeach;
                     ?>
                     
                     
                 
                 <tr>
                     <td colspan="7" style=" background: #B5B5B5; text-align: center; padding-top: 2px; padding-bottom: 2px; font-size: 10px"><b>Total Reparo Pagado:<?php echo round($data[$reparoid]['total_reparo'],2); ?></b></td>
                 </tr>
         </table>
     </div>
      <p style=" text-align: center;"><b>IMPOSICIÓN DE MULTA Y LIQUIDACIÓN DE INTERESES</b></p>
      <br />
      <p>
         Asimismo, el Centro Nacional Autónomo de Cinematografía concluye que se debe aplicar a la sociedad mercantil <b><?php echo $data[$reparoid]['contribuyente']; ?></b>,  
         la sanción contemplada en el artículo 111, Parágrafo Segundo del Código Orgánico Tributario; que será equivalente de un diez por ciento (10%) del tributo omitido, la cual fue aprobada en Acta del Comité Ejecutivo <b>No. <?php echo $data[$reparoid]['nsession']; ?></b> de fecha <b><?php echo date('d-m-Y',strtotime($data[$reparoid]['fsession'])); ?>.</b>
      </p>
      <br />
      <p>
          Adicionalmente, cumpliendo con lo establecido en el Parágrafo Segundo del artículo 94 del Código Orgánico Tributario, esta instancia administrativa debe convertir las multas expresadas en términos porcentuales a su valor en Unidades Tributarias (U.T.), para luego establecer su valor al momento de la emisión de la presente Resolución, tal como se demuestra a continuación:
      </p>
      <br />
      <div class="tabla_body2">
         <table border="2"  >
             <thead>
               <tr id="head">
                     <th >Periodo<br />Economico</th><th>Tributo<br />Omitido</th><th>Multa en Bolivares<br />Art. 111 COT (10%)</th><th>Unidad<br/>Tributaria</th><th>Multa en<br />Unidades Tributaria</th>                

                 </tr> 
               </thead>
                 <tr class='tr-body'>
                     <td >
                         31 de Enero de <?php echo $data[$reparoid]['periodo_afiscalizar']; ?><br />
                         hasta el 31 de diciembre de <?php echo $data[$reparoid]['periodo_afiscalizar']; ?>
                     </td>
                     <td>
                         <?php echo round($data[$reparoid]['total_reparo'],2); ?>
                     </td>
                     <td>
                         <?php echo round($data[$reparoid]['multa_pagar'],2); ?>
                     </td>
                     <td>
                         <?php echo $ut['variable0']; ?>
                     </td>
                     <td>
                          <?php echo round($data[$reparoid]['multa_pagar']/$ut['variable0'],2); ?>
                     </td>
                     
                 </tr>
         </table>
     </div>
      <p>
         Cabe destacar el criterio de la Sala Político Administrativa del Tribunal Supremo de Justicia respecto a este mismo tema: 
      </p>
      <br />
      <p class="citas1">
          “Así, esta Sala de manera reiterada ha establecido que a los efectos de considerar cuál es la unidad tributaria aplicable para la fijación del monto de la sanción de multa con las infracciones cometidas bajo la vigencia del Código Tributario de 2001,<b> ha expresado que debe tomarse en cuenta la fecha de emisión del acto administrativo, pues es ése el momento cuando la Administración Tributaria determina -previo procedimiento- la comisión de la infracción que consecuentemente origina la aplicación de la sanción respectiva.</b> (Vid. Sentencias Nos. 0314, 0882 y 01170 de fecha 06 de junio de 2007; 22 de febrero de 2007, y 12 de julio de 2006, respectivamente.).” (Cursivas y negritas del redactor).
      </p>
      <br />
      <p>
          Ahora bien, como consecuencia del contenido normativo establecido en el artículo 66 del Código Orgánico Tributario, este Centro Nacional Autónomo de Cinematografía, por Órgano del Fondo de Promoción y Financiamiento del Cine FONPROCINE procede a realizar el cálculo de intereses moratorios sobre la base de la contribución especial pagada extemporáneamente, desde la fecha de vencimiento del plazo fijado para el pago de la obligación tributaria hasta la fecha del pago de la contribución especial, aplicados según la tasa activa bancaria promedio de los seis (6) principales bancos comerciales y universales del país con mayor volumen de depósitos, excluidas las carteras con intereses preferenciales, calculada por el Banco Central de Venezuela para el mes calendario, por cada uno de los períodos en que dichas tasas estuvieron vigentes, tal como se demuestra a continuación:
      </p>   
         
             <?php foreach ($detalles_intereses as $clave => $valor): 
                 $total_interes=0;
              echo "<div class='tabla_body'>
                        <table border='2'  >
                        <thead>
                            <tr id='head'>
                                <th>Intereses<br />$clave</th><th>Dias</th><th>Capital</th><th>Tasa de<br/>Interes Fijada<br />Por el BCV</th><th>Recargo<br />Segun Art.66<br />C.O.T</th><th>Tasa Aplicada<br />Diaria</th><th>Total Interes<br />BS</th>                

                            </tr>
                        </thead>";
                            foreach ($valor as $key => $value) {
              //                  foreach ($value as $key2 => $value2) {                      

                                echo"<tr class='tr-body'>
                                          <td>".$this->funciones_complemento->devuelve_meses_text($value['mes'])." (".$value['anio'].")"."</td>
                                              <td>$value[dias]</td>
                                                  <td>$value[capital]</td>
                                                      <td>".$value['tasa%']."</td>
                                                          <td>1,2</td>
                                                              <td>$value[tasa]</td>
                                                                  <td>$value[intereses]</td>
                                     </tr>";
              //                  }
                                $total_interes=$total_interes+$value['intereses'];
                            }
                            echo ' <tr>
                                        <td colspan="6" style=" background: #B5B5B5; text-align: center; padding-top: 2px; padding-bottom: 2px; font-size: 14px"><b>Total Interes '.$clave.':</b></td>
                                           <td style=" background: #B5B5B5; text-align: center; padding-top: 2px; padding-bottom: 2px; font-size: 14px"><b> '.round($total_interes,2).'</b></td> 
                                    </tr>';
                echo "</table>
                    </div>
                    <br />";
             endforeach; ?>          
                <p style=" text-align: center;"><b>DECISIÓN</b></p>
                <p>
                   En virtud de la Fiscalización practicada a la sociedad mercantil <b><?php echo $data[$reparoid]['contribuyente']; ?>,</b>  el Centro Nacional Autónomo de Cinematografía (CNAC), emite la presente Resolución Culminatoria de Fiscalización, por la omisión del tributo contemplado en el artículo 52 de la Ley de la Cinematografía Nacional, y en consecuencia resuelve: 
                             
                </p>
                <p>
                    <b>PRIMERO: </b>Imponer e intimar el pago de la deuda tributaria del contribuyente por la cantidad de <b><?php echo $this->monedas_texto->num_to_letras(trim($data[$reparoid]['multa_pagar'])); ?></b>, por sanción de multa, con fundamento en los artículos 111, 186 y 136 del Código Orgánico Tributario.
                </p>
                <p>
                    <b>SEGUNDO: </b>Liquidar e intimar al pago de la deuda tributaria del contribuyente por la cantidad de <b><?php echo $this->monedas_texto->num_to_letras(trim($data[$reparoid]['interes_pagar'])); ?></b>, por los intereses moratorios de los tributos no pagados causados de conformidad con el artículo 66 del Código Orgánico Tributario.
                </p>
                <p>
                    <b>TERCERO:</b> Informar al contribuyente <b><?php echo $data[$reparoid]['contribuyente']; ?>,</b> , que las cuentas dispuestas para la cancelación de la cifra especificada en la disposición PRIMERA de esta Resolución son las identificadas como cuenta corriente Nº 0134-0031-88-0311126075, a nombre del Centro Nacional Autónomo de Cinematografía (CNAC), de la Institución Financiera Banesco Banco Universal, o a través de la cuenta corriente, Nº 0108-0581-13-0200023302, de la institución financiera Banco Provincial.
                </p>
                <p>
                    <b>CUARTO:</b> Informar al contribuyente <b><?php echo $data[$reparoid]['contribuyente']; ?>,</b> ,  que la cuenta dispuesta para la cancelación de la cifra especificada en la disposición SEGUNDA de esta Resolución es la identificada como cuenta corriente Nº 0134-0861-18-8613000268, a nombre del Centro Nacional Autónomo de Cinematografía (CNAC), de la Institución Financiera Banesco Banco Universal, o a través de las planillas de autoliquidación emitidas por la institución financiera Banco Provincial, las cuales deben ser retiradas en nuestras oficinas.
                </p>
                <p>
                    <b>QUINTO:</b> Notificar a la sociedad mercantil <b><?php echo $data[$reparoid]['contribuyente']; ?>,</b> ,el contenido de la presente Resolución de conformidad con lo dispuesto en el artículo 162 del Código Orgánico Tributario.
                    <br />
                    Se participa a la sociedad mercantil <b><?php echo $data[$reparoid]['contribuyente']; ?>,</b> que podrá interponer el Recurso Jerárquico establecido en el artículo 242 y siguientes del Código Orgánico Tributario, así como el Recurso Contencioso Tributario según lo previsto en el artículo 259 y siguientes ejusdem, teniendo un plazo de veinticinco (25) días hábiles contados a partir del día siguiente a la fecha de notificación del acto que se impugna, para interponer dichos recursos.  
                </p>
                <br /><br />
                <p style=" text-align: center; line-height:1.0">
                        <b><?php echo $firma['variable0']." ".$firma['variable1'] ?></b><br />
                        <b>Presidenta (E)</b><br />
                        <b>Centro Nacional Autónomo de Cinematografía (CNAC)</b><br />
                        <b>Designada mediante Decreto No. <?php echo $firma['variable2'] ?></b><br />
                        <b>Publicada en la Gaceta Oficial de la República Bolivariana de Venezuela</b><br />
                        <b>No.<?php echo $firma['variable3']." del ".$firma['variable4'] ?></b>

                </p>    
                            <!-- seccion de la firma de la notificacion-->
                <br />            

    <div class="firma">
        <table >
            <tr>
               <td><p><b>POR EL CONTRIBUYENTE</b></p></td> 
            </tr>
            <tr>
                <td >
                   <p>Firma:_____________________________________________</p>
                </td>
            </tr>
            <tr>                
                <td>
                   <p>Nombre y Apellido:_________________________________ </p>
                </td>
                            
            </tr>
             <tr>
                <td>
                   <p>Cedula de Identidad:________________________________ </p>
                </td>                
            </tr>
             <tr>
                <td>
                   <p>Cargo:_______________________________________________ </p>
                </td>                
            </tr>
            <tr>
                <td >
                   <p>Telefonos:___________________________________________</p> 
                </td>
            </tr>
            <tr>
                <td >
                   <p>Feha de Notificacion:________________________________</p>
                </td>
            </tr>
                    
        </table>

    </div>
    <br />
    <p style=" text-align: left"><b>SIGLAS PERSONAS QUE REVISAN EL DOCUMENTO Ej.: ADA/CL/hv</b></p>
    
                            
    
</page>
