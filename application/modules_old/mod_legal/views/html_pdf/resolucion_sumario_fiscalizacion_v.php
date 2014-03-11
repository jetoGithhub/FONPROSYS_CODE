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
    
    <p style=" text-align: left; margin-top: 1px"><b><b>CNAC/RCF-<?php echo $data[$reparoid]['resol_multa']; ?></b></b></p>
    <p style=" text-align: right;"><b>Caracas,</b></p>
    <br /><br />
    <!-- Titulo del acta de autorizacion fiscal-->
    <p style=" text-align: center;"><b>RESOLUCI&Oacute;N CULMINATORIA DE SUMARIO</b></p>
    
    <p>
        De conformidad con lo establecido en los artículos 191 y 192 del Código Orgánico Tributario publicado en Gaceta Oficial Número 37.305 de fecha diecisiete (17) de octubre de dos mil uno (2001) y según lo previsto con los artículos 41 y 63 de la Ley de la Cinematografía Nacional (LCN), publicada en la Gaceta Oficial de la República Bolivariana de Venezuela No. 38.281 y reimpresa, por error del ente emisor, en fecha veintiséis (26) de octubre de 2005 en la Gaceta Oficial de la República Bolivariana de Venezuela Extraordinario Nº 5.789, se procede a emitir la presente Resolución que concluye el procedimiento de determinación de oficio sobre base cierta, en relación al Acta Fiscal Nº
        <b> CNAC/FONPROCINE/GFT/AFR-<?php echo $data[$reparoid]['nacta_reparo']; ?></b>, notificada en fecha <?php echo date('m-d-Y',strtotime($data[$reparoid]['fechanoti_reparo'])); ?>  según lo dispuesto en el numeral 1º del artículo 162 del referido Código, para el ejercicio fiscal comprendido desde el 01 de enero de <b><?php echo $data[$reparoid]['periodo_afiscalizar']; ?></b>, hasta el 31 de diciembre de <b><?php echo $data[$reparoid]['periodo_afiscalizar']; ?></b>,
        levantada según lo establecido en el artículo 63 de la referida Ley de la Cinematografía Nacional, mediante la cual se dejó constancia de los resultados de la fiscalización practicada a la sociedad mercantil <b><?php echo $data[$reparoid]['contribuyente']; ?></b> identificada con el Registro de Información Fiscal <b>(R.I.F.)<?php echo $data[$reparoid]['rif']; ?></b>, ubicada en la direccion fiscal <b><?php echo $data[$reparoid]['domicilio_fisal']; ?></b>, sobre la base de los ingresos brutos efectivamente percibidos por el contribuyente para el período comprendido desde el 01 de Enero de <b><?php echo $data[$reparoid]['periodo_afiscalizar']; ?> </b> hasta el 31 de diciembre de  <b><?php echo $data[$reparoid]['periodo_afiscalizar']; ?></b>
        
    </p>
     <br />
   <p style=" text-align: center;"><b>EXPOSICI&Oacute;N DE LOS HECHOS</b></p>
    <br />
    <p>
        Mediante Autorización Fiscal Nº<b> CNAC/FONPROCINE/GFT/AF-<?php echo $data[$reparoid]['nro_autorizacion']; ?></b> de fecha <?php echo date('d-m-Y',strtotime($data[$reparoid]['fecha_autorizacion'])); ?>, el Presidente del Centro Nacional Autónomo de Cinematografía (CNAC), facultado para éste acto conforme al numeral 1 del artículo 13  y 41 de la Ley de la Cinematografía Nacional, en uso de las facultades conferidas en el numeral 1 del artículo 127 y 178 del Código Orgánico Tributario, publicado en la Gaceta Oficial de la República Bolivariana de Venezuela  Número 37.305, de fecha diecisiete (17) de octubre de 2001, designó al funcionario <b><?php echo $data[$reparoid]['fiscal_ejecutor']; ?></b>, titular de la cédula de Identidad Nº <b><?php echo $data[$reparoid]['cedula_fiscal']; ?></b>
        en su condición de Gerente de Fiscalización Tributaria, adscrito al Fondo de Promoción y Financiamiento del Cine (FONPROCINE), para fiscalizar y determinar de oficio sobre base cierta, la autoliquidación y pago de la Contribución Especial causada, según lo dispuesto en el artículo &nbsp;<b><?php echo $data[$reparoid]['narticulo']; ?></b>&nbsp; de la Ley de la Cinematografía Nacional, por &nbsp;<?php echo $data[$reparoid]['text_articulo']; ?>,&nbsp;; llevándose a cabo las siguientes actuacionesde conformidad con lo dispuesto en la Sección Segunda, Capítulo I, Título IV del Código Orgánico Tributario:
    </p>
    <p>
        1). En fecha <?php echo date('d-m-Y',strtotime($data[$reparoid]['fecha_requerimiento'])); ?>, el Fiscal de Renta designado, levantó Acta de Requerimiento Nº <b>CNAC/FONPROCINE/<br />GFT/AR-<?php echo $data[$reparoid]['nro_autorizacion']; ?>,</b> de conformidad con lo previsto en el numeral 4 del artículo 137 del Código Orgánico Tributario, a fin de obtener los elementos necesarios para la determinación oficiosa sobre base cierta, tal como lo establece el artículo 131 del Código Orgánico Tributario, concediendo a la empresa <b><?php echo $data[$reparoid]['contribuyente']; ?></b>,un plazo de tres (3) días hábiles para suministrar la documentación solicitada.
    </p>
    <p>
        2). En fecha <?php echo date('d-m-Y',strtotime($data[$reparoid]['fecha_recepcion'])); ?>, fue consignada la referida documentación según consta de Acta de Recepción de Documentos Nro. <b>CNAC/FONPROCINE/GFT/AR-<?php echo $data[$reparoid]['nro_autorizacion']; ?></b>,en la cual se dejó constancia de la entrega de: Copia de la Declaración Definitiva de Impuestos Sobre la Renta (SENIAT), copia de la declaración de Impuesto al Valor Agregado (SENIAT), copia del Balance Genral y Estado de Resultados correspondiente al periodo fiscalizado y Mayor Analítico. 
    </p>
    <p>
        3). En fecha <?php echo date('d-m-Y',strtotime($data[$reparoid]['fechanoti_reparo'])); ?>, se levantó Acta Fiscal Nº <b> CNAC/FONPROCINE/GFT/AFR-<?php echo $data[$reparoid]['nacta_reparo']; ?></b>, en la cual se determinó lo siguiente:
    </p>
    <br />
   <p style=" text-align: center;"><b>DETERMINACI&Oacute;N DEL REPARO</b></p>
   <br />
     <p>
       Una vez determinados los ingresos brutos efectivamente percibidos por el contribuyente en los períodos fiscales comprendidos entre el 01 de Enero de <b><?php echo $data[$reparoid]['periodo_afiscalizar']; ?> </b> hasta el 31 de diciembre de  <b><?php echo $data[$reparoid]['periodo_afiscalizar']; ?></b> se procedió a cuantificar la suma por concepto de Contribución Especial causada y no pagada por la sociedad mercantil
       <b><?php echo $data[$reparoid]['contribuyente']; ?></b> tal y como se muestra en el siguiente cuadro: 
   </p>
   <br />
   <p style=" text-align: left;"><b> Cuadro N° 3. Determinaci&oacute;n de la contribuci&oacute;n especial causada y no pagada</b></p>
   <br /><br /><br /><br />
   
    <p style=" text-align: center;">pendiente este cuadro aclarar con el señor laos</p>
   <br /><br /><br /><br />  
   
  <p style=" text-align: center;"><b>CONCLUSIONES</b></p>
   <br />
   <p>
       En consecuencia, ajustados a los resultados del procedimiento de fiscalización y a los razonamientos de hecho y derecho expuestos en el cuerpo de la presente Acta Fiscal, se concluye:
   </p>
   <p>
       <b>PRIMERO:</b> Imponer un reparo fiscal a la sociedad mercantil <b><?php echo $data[$reparoid]['contribuyente']; ?></b> por la cantidad de <?php echo $this->monedas_texto->num_to_letras(trim($data[$reparoid]['total_reparo'])); ?>, correspondiente a la contribución especial causada y no pagada para los periodos fiscalizados. 
   </p>
   <p>
       <b>SEGUNDO:</b> Aceptado el reparo impuesto en la conclusión primera, la sociedad mercantil <b><?php echo $data[$reparoid]['contribuyente']; ?></b> debe presentar las planillas de autoliquidación correspondientes a los periodos reparados, y proceder a su respectivo pago, dentro de los quince (15) días hábiles posteriores a la fecha de notificación de la presente acta, de acuerdo a lo dispuesto en el artículo 185 del Código Orgánico Tributario vigente.
   </p>
   <p>
       <b>TERCERO:</b> El Fondo de Promoción y Financiamiento del Cine (FONPROCINE), cumple con informarle, que la cuenta dispuesta para la cancelación de los montos expresados, por concepto de reparo, en el cuerpo de esta Acta, es la identificada como cuenta corriente N° 0134-0861-18-8613000268 a nombre de: CENTRO NACIONAL AUTÓNOMO DE CINEMATOGRAFÍA (CNAC) de la institución financiera Banesco Banco Universal; o en su defecto mediante planilla de pago a FONPROCINE correspondiente al Banco Provincial, la cual puede ser retiradas por nuestras oficinas.
   </p>
   <p>
       <b>CUARTO:</b> Notificar a la sociedad de comercio  <b><?php echo $data[$reparoid]['contribuyente']; ?></b> de los resultados del procedimiento de determinación tributaria reflejados a lo largo del cuerpo de la presente Acta Fiscal a tenor de lo previsto en el artículo 162 del Código Orgánico Tributario vigente.
   </p>
   <p>
       Ahora bien, en vista a lo antes señalado pasamos a exponer lo siguiente:
   </p>
   <br />
   <p style=" text-align: center;"><b>MOTIVACIONES PARA DECIDIR</b></p>
   <br />
   <p>
       Analizada como ha sido la argumentación fiscal, y en consideración que el contribuyente no presentó escrito de descargos, resulta necesario verificar la legalidad y legitimidad de la actuación de la administración, para lo cual es menester referirnos, en primera instancia al Principio de Legalidad Tributaria, establecido en el artículo 317 de la Constitución de la República Bolivariana de Venezuela, que señala:
   </p>
   <br />
   <p class="citas1">
       “No podrá cobrarse impuesto, tasa, ni contribución alguna que no estén establecidos en la Ley...”. Así como, a lo indicado en el artículo 3 del Código Orgánico Tributario (publicado en la Gaceta Oficial de la República Bolivariana de Venezuela No. 37.305 de fecha diecisiete (17) de octubre de 2001), que recoge de igual manera este principio, al señalar: “Sólo a las leyes corresponde regular con sujeción a las normas generales de este Código las siguientes materias: 1. Crear, modificar o suprimir tributos…”. 
   </p>
   <p>
       Razón por la cual, podemos afirmar que los tributos sólo pueden establecerse por medio de leyes, tanto desde el punto de vista material como formal; es decir, por medio de disposiciones de carácter general, abstractas, impersonales, emanadas del Poder Legislativo.
   </p>
   <p>
       Asimismo, es menester indicar que dicha máxima constituye una garantía en el derecho constitucional tributario, tal y como lo indicamos previamente al hacer mención del artículo 317 de nuestra Carta Magna, por cuanto el mismo dispone que los tributos requieren ser sancionados por una ley, entendida ésta como la disposición que emana del órgano constitucional que tiene potestad legislativa conforme a los procedimientos establecidos por la Constitución. (Héctor Villegas, Curso de Finanzas, Derecho Financiero y Tributario, 1991).  
   </p>
   <p>
       Ahora bien, partiendo de las anteriores consideraciones y en el entendido que los tributos son prestaciones dinerarias que el Estado exige en ejercicio de su Poder de Imperio, comprendidos dentro del marco de una ley para cubrir los gastos que le demanda el cumplimiento de sus fines,  se puede inferir, que los tributos establecidos en el artículo 52 de la Ley de la Cinematografía Nacional, y en el cual se fundamento en su oportunidad el Reparo impuesto al contribuyente, cumple con dichos parámetros, pues su existencia deviene de una ley, creada conforme al procedimiento de formación de leyes previsto en los artículos 202 y siguientes de la Constitución de la República Bolivariana de Venezuela. 
   </p>
   <p>
       En ese sentido, una vez aclarado el principio de legalidad del tributo antes indicado, pasamos a analizar el procedimiento aplicado al caso concreto; como bien señala el Acta Fiscal, el procedimiento se instruyó conforme a los artículos 121, 127, 129, 130, 131.183 y 184 del Código Orgánico Tributario vigente, indicándosele al administrado en el texto de la referida acta los medios de defensa de los cuales podía hacer uso de acuerdo a lo previsto en los artículos 188 y 189 ejusdem, pudiendo concluir que estamos en presencia de un procedimiento que se ha instruido en cumplimiento de los parámetros previstos en la normativa establecida en el referido Código Orgánico Tributario.
   </p>
   <p>
       Ahora bien, después de iniciada la Fiscalización y notificado el contribuyente, se dictó un acta de reparo, frente a la cual el sujeto pasivo tenía las alternativas siguientes:
   </p>
   <p>
       1.- Aceptar el reparo, lo cual puede realizar de acuerdo con el artículo 185 del Código Orgánico Tributario, dentro de los 15 días siguientes a la notificación del Acta, presentando las declaraciones omitidas o rectificando las presentadas y pagando la diferencia de impuesto resultante y los intereses moratorios. En este supuesto y de acuerdo con lo que indica el artículo 111, parágrafo segundo del Código Orgánico Tributario, el sujeto fiscalizado tiene derecho a que se le imponga una sanción reducida, equivalente al 10% del tributo omitido, en vez de la del 112,5% del tributo omitido que es la normalmente aplicable.
   </p>
   <p>
       2.- Aceptar parcialmente el reparo formulado, en cuyo caso se aplicará la multa establecida en el artículo 111, parágrafo segundo del Código Orgánico Tributario, equivalente al diez por ciento (10%) a la parte que hubiere sido aceptada y pagada; abriéndose el sumario administrativo sobre la parte no aceptada.
   </p>
   <p>
       3.- No aceptar en su totalidad el reparo y presentar un escrito de descargos en un plazo de 25 días hábiles contados a partir del vencimiento de los 15 días a los que ya se hizo referencia, todo de acuerdo con el artículo 188 del Código Orgánico Tributario, este escrito de descargos contendrá los argumentos de hecho y de derecho que expondrá el sujeto fiscalizado para desvirtuar el contenido del acta de reparo. Junto con los descargos el sujeto fiscalizado puede presentar las pruebas que sustenten los argumentos expuestos, pero también puede solicitarse en el escrito que el procedimiento se abra a pruebas, para consignar las mismas en una oportunidad posterior o evacuar una prueba de experticia o cualquier otra prueba que fuere legal y pertinente.
   </p>
   <p>
       Ahora bien, como quiera que el Acta de Reparo Fiscal no constituye el acto con el cual finaliza el procedimiento de fiscalización, sino que constituye un acto preparatorio o de trámite, y en virtud que en el presente caso luego de haber dejado transcurrir los lapsos previstos en los artículos 185 y 188 del Código Orgánico Tributario, respectivamente, el contribuyente no procedió a formular descargos, es por lo que nos encontramos en presencia de esta Resolución Culminatoria de Sumario,  a objeto de poner fin al trabajo de fiscalización realizado por esta Administración Tributaria. En tal sentido,  se pasa a exponer lo siguiente:
   </p>
   <br />
   <p style=" text-align: center;"><b>DE LA PROCEDENCIA DEL REPARO POR CONCEPTO DEL ARTÍCULO <?php echo $data[$reparoid]['narticulo']; ?> DE LA LEY DE LA<br /> CINEMATOGRAFÍA NACIONAL</b></p>
   <br />
   <p>
       A los efectos de desarrollar este punto es menester hacer referencia en primer término a la interpretación sobre la aplicación de la norma prevista en el artículo <?php echo $data[$reparoid]['narticulo']; ?> de la Ley de la Cinematografía Nacional, la cual consagra la obligación que tienen las empresas de pagar una contribución especial al Fondo de Promoción y Financiamiento del Cine (FONPROCINE).
   </p>
   <p>
       En este sentido, establece el artículo <?php echo $data[$reparoid]['narticulo']; ?> de la Ley de la Cinematografía Nacional, lo siguiente:
   </p>
   <br />
  <p class="citas1">
       “Artículo 52:  <?php echo $data[$reparoid]['text_articulo']; ?>” 
   </p>
   <br />
   <p>
       En este mismo orden de ideas, según se evidencia de la cláusula tercera del Documento Constitutivo y Estatutario de <b><?php echo $data[$reparoid]['contribuyente']; ?></b> el objeto social de la mencionada sociedad mercantil es:
   </p>
   <p class="citas1">
       "<b><?php echo $data[$reparoid]['objeto_empresa']; ?></b>" (Resaltado y subrayado nuestro)
   </p>
   <p>
       Verificándose así el hecho imponible establecido en la norma in comento, el cual origina el nacimiento de la obligación tributaria. 
       Para concluir, esta Administración Tributaria considera que el Contribuyente no demostró elementos que desvirtuaran lo contemplado en el Acta de Reparo Fiscal y  por lo tanto se ratifica en todas y cada una de sus partes el Acto Administrativo N° <b> CNAC/FONPROCINE/GFT/AFR-<?php echo $data[$reparoid]['nacta_reparo']; ?></b>, de fecha <?php echo date('d-m-Y',strtotime($data[$reparoid]['fechanoti_reparo'])); ?>
        
   </p>
   <br />
  <p style=" text-align: center;"><b>IMPOSICIÓN DE MULTA Y LIQUIDACIÓN DE INTERESES</b></p>
   <br />
   <p>
       Vistas las anteriores consideraciones, el Centro Nacional Autónomo de Cinematografía concluye que se debe aplicar a la sociedad mercantil <b><?php echo $data[$reparoid]['contribuyente']; ?></b> la sanción contemplada en el artículo 111 del Código Orgánico Tributario, en su encabezamiento; que será equivalente de un veinticinco por ciento (25%) hasta el doscientos por ciento  (200%) del tributo omitido, por haber causado una disminución ilegítima de los ingresos tributarios, la cual fue aprobada en Acta del Comité Ejecutivo <b>No. <?php echo $data[$reparoid]['nsession']; ?></b> de fecha <b><?php echo date('d-m-Y',strtotime($data[$reparoid]['fsession'])); ?>.</b> En consecuencia, siguiendo lo previsto en el artículo 37 del Código Penal, se impone multa en su término medio, pues no existen circunstancias atenuantes ni agravantes que modifiquen la pena normalmente aplicable, es decir, multa de ciento doce punto cinco por ciento (112,5%). 
   </p>
   <p>
       Adicionalmente, cumpliendo con lo establecido en el Parágrafo Segundo del artículo 94 del Código Orgánico Tributario, esta instancia administrativa debe convertir las multas expresadas en términos porcentuales a su valor en Unidades Tributarias (U.T.) vigente que corresponden al momento del pago, para establecer su valor al momento de la emisión de la presente Resolución, tal como se demuestra a continuación:
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
    <br />
    <p>
        Ahora bien, como consecuencia del contenido normativo establecido en el artículo 66 del Código Orgánico Tributario, este Centro Nacional Autónomo de Cinematografía, por Órgano del Fondo de Promoción y Financiamiento del Cine FONPROCINE procede a realizar el cálculo de intereses moratorios sobre la base de la contribución especial pagada extemporáneamente, desde la fecha de vencimiento del plazo fijado para el pago de la obligación tributaria hasta la fecha de pago efectivamente realizado, aplicados según 1.2 veces la  tasa activa bancaria promedio de los seis (6) principales bancos comerciales y universales del país con mayor volumen de depósitos, excluidas las cartera con intereses preferenciales, calculada por el Banco Central de Venezuela para el mes calendario, por cada uno de los períodos en que dichas tasas estuvieron vigentes, tal como se demuestra a continuación:
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
         En virtud de la Fiscalización practicada a la sociedad mercantil <b><?php echo $data[$reparoid]['contribuyente']; ?></b> el    Centro   Nacional   Autónomo   de Cinematografía (CNAC), emite la presente Resolución Culminatoria de Sumario, de conformidad con lo establecido en el artículo 192 del Código Orgánico Tributario y ordena se expidan las planillas de liquidación correspondientes por la omisión del tributo contemplado en el artículo 52 de la Ley de la Cinematografía Nacional, en consecuencia:
    </p>
    <br />
    <p>
        <b>PRIMERO:</b> Se intima a la empresa <b><?php echo $data[$reparoid]['contribuyente']; ?></b> al  pago  de  la  cantidad  de <?php echo $this->monedas_texto->num_to_letras(trim($data[$reparoid]['total_reparo'])); ?> correspondiente al Reparo Fiscal no pagado señalado en el Acta de Reparo Fiscal Nº <b> CNAC/FONPROCINE/GFT/AFR-<?php echo $data[$reparoid]['nacta_reparo']; ?></b> correspondiente a la contribución especial contenida en el Artículo 52 de la Ley de la Cinematografía Nacional, causada y no pagada para el período comprendido entre el 01 de Enero de <b><?php echo $data[$reparoid]['periodo_afiscalizar']; ?> </b> hasta el 31 de diciembre de  <b><?php echo $data[$reparoid]['periodo_afiscalizar']; ?></b>.
    </p>
   <br />
   <p>
        <b>SEGUNDO:</b> Imponer e intimar el pago de la deuda tributaria del contribuyente por la cantidad de <b><?php echo $this->monedas_texto->num_to_letras(trim($data[$reparoid]['multa_pagar'])); ?></b>, por sanción de multa, con fundamento en el artículo 111  del Código Orgánico Tributario, en su encabezamiento, y el artículo 136 ejusdem., de acuerdo a lo aprobado en comité ejecutivo en la reunión <b>No. <?php echo $data[$reparoid]['nsession']; ?></b> de fecha <b><?php echo date('d-m-Y',strtotime($data[$reparoid]['fsession'])); ?>.</b>, para el período comprendido entre el 01 de Enero de <b><?php echo $data[$reparoid]['periodo_afiscalizar']; ?> </b> hasta el 31 de diciembre de  <b><?php echo $data[$reparoid]['periodo_afiscalizar']; ?></b>.  
   </p>
   <br />
   <p>
        <b>TERCERO:</b> Liquidar e intimar al pago de la deuda tributaria del contribuyente por la cantidad de <b><?php echo $this->monedas_texto->num_to_letras(trim($data[$reparoid]['interes_pagar'])); ?></b>, por los intereses moratorios de los tributos no pagados causados de conformidad con el artículo 66 del Código Orgánico Tributario,  correspondiente a el período comprendido entre el 01 de enero de 2008 y el 31 de diciembre de 2008.
   </p>
    <br />
   <p>
       Notifíquese a la sociedad mercantil <b><?php echo $data[$reparoid]['contribuyente']; ?></b> el contenido de la presente Resolución de conformidad con lo dispuesto en el artículo 162 del Código Orgánico Tributario.
   </p>
    <br />
    <p>
        Se participa a la sociedad mercantil <b><?php echo $data[$reparoid]['contribuyente']; ?></b> que podrá interponer el Recurso Jerárquico establecido en el artículo 242 y siguientes del Código Orgánico Tributario, así como el Recurso Contencioso Tributario  según  lo  previsto en el artículo 259 y siguientes ejusdem, teniendo un plazo de veinticinco (25) días hábiles contados a partir del día siguiente a la fecha de notificación del acto que se impugna, para interponer dichos recursos.  
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
                             <!--seccion de la firma de la notificacion-->
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