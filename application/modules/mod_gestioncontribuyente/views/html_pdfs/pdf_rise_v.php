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
    .tabla_body{ margin-left: 0px; width: auto}
    .tabla_body th{ width: 80px; font-size: 10px; text-align: center;font-weight: bold; color: #ffffff;}
    .tabla_body tr#head{ background: #993300 }
    .tabla_body table{ border-collapse: collapse; border-color: #868686;  }
    
    .tabla_body2{ margin-left: 30px}
    .tabla_body2 th{ width: 105px; font-size: 10px; text-align: center;font-weight: bold; color: #ffffff}
    .tabla_body2 tr#head{ background: #993300 }
    .tabla_body2 table{ border-collapse: collapse; border-color: #868686}
    
    .tabla_body3{ margin-left:0px}
    .tabla_body3 th{ width:60px; font-size: 10px; text-align: center;font-weight: bold; color: #ffffff}
    .tabla_body3 tr#head{ background: #800000 }
    .tabla_body3 table{ border-collapse: collapse; border-color: #868686}
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

<page backtop="25mm" backbottom="30mm" backleft="16mm" backright="16mm" style="font-size: 12pt" >
                            <!-- seccion de la cabecera con el logo de la institucion-->
    <page_header>
        <div style=" position: absolute; width: 87%;  margin-left:55px">
            <p style=" text-align: left; margin-top: 1px"><b>CNAC/FONPROCINE/GRT/RISE-<?php echo $data[$id]['resol_multa']; ?></b></p>
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
    
    
                             <p style=" text-align: right;"><b>Caracas,&nbsp;<?php echo date('d').' de '.$this->funciones_complemento->devuelve_meses_text(date('m')).' del '.date('Y'); ?></b></p>
    <br /><br />
    <!-- Titulo del acta de autorizacion fiscal-->
    <p style=" text-align: center;"><b>RESOLUCIÓN <br /> IMPOSICIÓN DE SANCIÓN POR EXTEMPORANEIDAD</b></p>
    <br />
    <p>
        El Centro Nacional Autónomo de Cinematografía (CNAC), de conformidad con lo establecido en los artículos 41 y 63 de la Ley de la Cinematografía Nacional (LCN) de fecha 27 de septiembre de 2005, publicada en Gaceta Oficial de la República Bolivariana de Venezuela Nº 38.281, reimpresa por error en fecha 26 de octubre de 2005, según Gaceta Oficial de la República Bolivariana de Venezuela Extraordinaria Nº 5.789, y de conformidad con el artículo 121 del Código Orgánico Tributario, publicado en Gaceta Oficial de la República Bolivariana de Venezuela Número 37.305 de fecha 17 de octubre de 2001, emite la presente Resolución al contribuyente <b><?php echo $data[$id]['contribuyente']; ?></b>,
        identificado con el Registro de Información Fiscal <b><?php echo $data[$id]['rif']; ?></b> <?if(!empty($data[$id]['registro_cnac'])):?>número de Registro de la Cinematografía Nacional <b><?php echo $data[$id]['registro_cnac']?></b><?php endif; ?>,inscrito en el Registro Mercantil <?php echo $data[$id]['oficina_registro']; ?>, con fecha <?php echo $data[$id]['fecha_registro']; ?>, inscrito Bajo el Nro <?php echo $data[$id]['numero_registro']; ?>, Tomo <b><?php echo $data[$id]['rmtomo']; ?></b>, y domiciliado en <b><?php echo $data[$id]['domicilio_fisal']; ?></b>, como consecuencia de haber realizado el pago correspondiente a la contribución especial consagrada en el Artículo 52 de la Ley de la Cinematografía Nacional fuera de la oportunidad legal  establecida para ello. 
    </p>
    <br />
    <p style=" text-align: center;"><b>I. DE LOS HECHOS</b></p>
    <br />
    <p>
        En fecha <b><?php echo date('d-m-Y',strtotime($data[$id]['fecha_registro_fila'])); ?></b>, el funcionario <b><?php echo $data[$id]['grente_reca']?></b> titular de la cedula de identidad <b><?php echo "Nº ".$data[$id]['cedula_reca']?></b>,en su carácter de Gerente de Recaudación Tributaria (E) del Fondo de Promoción y Financiamiento del Cine (FONPROCINE), órgano adscrito al Centro Nacional Autónomo de Cinematografía (CNAC), previa verificación practicada en sede administrativa a los comprobantes y demás registros legales y administrativos que reposan en el expediente del Contribuyente <b><?php echo $data[$id]['contribuyente']; ?></b>,plenamente identificado con anterioridad, constató que de acuerdo con el artículo segundo de sus estatutos sociales, su objeto social es: <i>"<?php echo $data[$id]['objeto_empresa']; ?>; (omissis).."</i>
    </p>
    <br />
    <p>
        <b><u>De la misma  manera se constató que <!--el ciudadano Rubén Alejandro , titular de la Cédula de Identidad Nº E-82.195.693, actuando en su condición de Presidente de la referida--> la antes señanla sociedad mercantil, consignó ante el Fondo de Promoción y Financiamiento del Cine (FONPROCINE), la Planilla de Autoliquidación y de pago en la forma y fecha que se detalla a continuación:</u></b>
    </p>
    <br />
    <br />
     <div class="tabla_body">
         <table border="2" >
             <thead>
               <tr id="head">
                     <th>Fecha de<br />Recepcion</th><th>Nº de<br /> Planilla</th><th>Nº de<br />Deposito</th><th>Fecha de<br/> Deposito</th><th>Banco</th><th>Periodo Imositivo</th><th>Monto en Bs</th>                

                 </tr>
              </thead>
                 
                     <?php
                     $total=0;
                        foreach ($declarciones_extem as $clave =>$valor):
                            echo "<tr class='tr-body'>
                                        <td>".$valor['fecha_recepcion']."</td>
                                        <td>".$valor['nudeclara']."</td>
                                        <td>".$valor['nudeposito']."</td>
                                        <td>".$valor['fechapago']."</td>
                                        <td>".$valor['banco']."</td>
                                        <td>".$valor['periodo']."</td>
                                        <td>".$this->funciones_complemento->devuelve_cifras_unidades_mil($valor['nmontopagar'])."</td>
                                  </tr>";
                        $total=$this->funciones_complemento->devuelve_cifras_unidades_mil($total+$valor['nmontopagar']);
                      endforeach;
                     ?>
                     
                     
                 
                 <tr>
                     <td colspan="5" style=" border-color: #CCC"></td>
                     <td  style=" background: #993300; color: #ffffff; text-align: center;font-weight: bold ; padding-top: 2px; padding-bottom: 2px; font-size: 10px"><b>TOTAL</b></td>
                     <td  style=" background: #993300;color: #ffffff; text-align: center;font-weight: bold ; padding-top: 2px; padding-bottom: 2px; font-size: 10px"><b><?php echo round($total,2); ?></b></td>
                 </tr>
         </table>
     </div>
    <br />
    <p style=" text-align: center;"><b>II. DEL DERECHO</b></p>
    <br />
    <p>
       Establece el artículo <?php echo $data[$id]['numero_articulo']; ?>, de la Ley de la Cinematografía Nacional lo siguiente: "<i><?php echo $data[$id]['cita_articulo']; ?></i>"
    </p>
    <br />
    <p>
        De manera que resulta mas que evidente que los contribuyentes que se encuentren dentro del supuesto planteado por la misma norma, contarán con un plazo equivalente a 15 días contínuos para formalizar por ante esta administración tributaria el pago de la obligación a la cual están sujetos de acuerdo con el ejercicio de su actividad comercial.
    </p>
    <br />
    <p>
        Por su parte reza el artículo 41 del Código Orgánico Tributario lo siguiente:<i>“El pago debe efectuarse en el lugar y la forma que indique la ley o en su defecto la reglamentación. (omissis) Los pagos realizados fuera de esta fecha, incluso los provenientes de ajustes o reparos, se considerarán extemporáneos y generarán los intereses moratorios previstos en el artículo 66 de este Código.(omissis)”</i>
        subrayado y cursivas nuestras). Seguidamente, se trae a colación el contenido del artículo 66 del Código Orgánico Tributario, cuyo texto establece lo siguiente:<i>“La falta de pago de la obligación tributaria dentro del plazo establecido para ello, hace surgir, de pleno derecho y sin necesidad de requerimiento previo de la Administración Tributaria, la obligación de pagar intereses moratorios desde el vencimiento del plazo establecido para la autoliquidación y pago del tributo hasta la extinción total de la deuda, equivalentes a la tasa máxima activa bancaria incrementada en veinte por ciento (20 %), aplicable, respectivamente, por cada uno de los períodos en que dichas tasas estuvieron vigentes. (omissis).”</i>
    </p>
    <br />
    <p>
        Ahora bien, concretamente con el fin de establecer la base sobre la cual se ha de dictar esta resolución y en consecuencia establecer la responsabilidad del sujeto pasivo de esta obligación, se remite esta Administración Tributaria al contenido normativo dispuesto en el artículo 109 del Código Orgánico Tributario, a saber:<i>“Constituyen ilícitos materiales:
            <br /><br />
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1. El retraso u omisión en el pago de tributos o de sus porciones. <br />
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2. El retraso u omisión en el pago de anticipos. <br />
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;3. El incumplimiento de la obligación de retener o percibir. <br />
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;4. La obtención de devoluciones o reintegros indebidos.” <br />
        
        </i>
    </p>
    <br />
    <p>
        En el mismo orden de ideas y estableciendo una concordancia y exposición lógica, esta Administración Tributaria cita el artículo 110 del Código Orgánico Tributario cuyo texto reza: <i>“Quien pague con retraso los tributos debidos, será sancionado con multa del uno por ciento (1%) de aquellos. Incurre en retraso el que paga la deuda tributaria después de la fecha establecida al efecto, sin haber obtenido prórroga, y sin que medie una verificación, investigación o fiscalización por la Administración Tributaria respecto del tributo de que se trate. En caso de que el pago del tributo se realice en el curso de una investigación o fiscalización, se aplicará la sanción prevista en el artículo siguiente.”</i>
    </p>
    <br />
    <p style=" text-align: center;"><b>III. DE LA SUBSUNCIÓN DE LOS HECHOS EN EL DERECHO</b></p>
    <br />
    <p>
        Una vez cotejado el artículo Segundo de los estatutos de la sociedad mercantil in comento con respecto al artículo <?php echo $data[$id]['numero_articulo']; ?>, de la Ley de la Cinematografía Nacional, determinó esta Administración que dicho contribuyente efectivamente se encuentra dentro del presupuesto de hecho establecido, toda vez que encuadra perfectamente en la situación prevista en la norma según la cual se materializa el hecho imponible.
    </p>
    <br />
    <p>
        En este caso, visto como fue que el contribuyente señalado ut supra presentó el recibo bancario ampliamente descritos con anterioridad, mediante los cuales se deja constancia que realizó el pago de la obligación establecida en el artículo <?php echo $data[$id]['numero_articulo']; ?>, de la Ley de la Cinematografía, en la fecha que se detallan a continuación de acuerdo al sello  o validación bancaria:
    </p>
    <br />
     <div class="tabla_body" style=" border: 1px solid; border-color: #CCC">
         <table border="2" >
             <thead>
               <tr id="head">
                     <th>Periodo<br />Impositivo</th><th>Fecha<br />Deposito</th><th>Fecha<br />Calendario</th><th>Tributo<br/>Pagado</th><th>Alicuota Segun<br />Art. 110 COT</th><th>Multa (*)</th>                

                 </tr>
              </thead>
                 
                     <?php
                     $totalm=0;
                     $totald=0;
                        foreach ($detalles_multa as $clave =>$valor):
                            foreach ($valor as $key => $value) {                                
                           
                                echo "<tr class='tr-body'>
                                            <td>".$value['text_periodo']."</td>
                                            <td>".$value['fechapago']."</td>
                                            <td>".$value['fecha_calendario']."</td>
                                            <td>".$this->funciones_complemento->devuelve_cifras_unidades_mil($value['nmontopagar'])."</td>
                                            <td>1 %</td>
                                            <td>".$this->funciones_complemento->devuelve_cifras_unidades_mil($value['total_multa'])."</td>                                        
                                      </tr>";
                                $totalm=$totalm+$value['total_multa'];
                                $totald=$totald+$value['nmontopagar'];
                            }
                      endforeach;
                     ?>
                     
                     
                 
                 <tr>
                     <td colspan="2" style=" border-color: #ffffff"></td>
                     <td  style=" background: #993300; color: #ffffff; text-align: center;font-weight: bold ; padding-top: 2px; padding-bottom: 2px; font-size: 10px"><b>TOTAL</b></td>
                      <td  style=" background: #993300; color: #ffffff; text-align: center;font-weight: bold ; padding-top: 2px; padding-bottom: 2px; font-size: 10px"><b><?php echo round($totald,2); ?></b></td>
                       <td  style=" background: #993300; color: #ffffff; text-align: center;font-weight: bold ; padding-top: 2px; padding-bottom: 2px; font-size: 10px"></td>
                     <td  style=" background: #993300;color: #ffffff; text-align: center;font-weight: bold ; padding-top: 2px; padding-bottom: 2px; font-size: 10px"><b><?php echo round($totalm,2); ?></b></td>
                 </tr>
         </table>
         <p style=" font-size: 9px"> 
             Elaborado por: CNAC-FONPROCINE<br />
             Fuente: Aprobacion del Comite Ejecutivo <b>PREGUNTAR</b> de Fecha <b>PREGUNTAR</b><br />
             (*)Aproximacion aplicada segun articulo 136 del Codigo Organico Tributario Vigente.  
             <br />
         </p>
     </div>
    <br />
    <p>
        De manera que, como ha quedado comprobado mediante los hechos narrados en esta resolución, se evidencia que entre el momento de pago y el momento de exigibilidad del pago de la contribución existen días considerados como atraso en el cumplimiento de la obligación para cada uno de los períodos previamente indicados, por lo que el citado contribuyente es susceptible de la sanción prevista en el artículo 110 del Código Orgánico Tributario, toda vez que la obligación no fue satisfecha dentro del tiempo hábil para hacerlo, aunado al hecho de que todo pago extemporáneo de la obligación genera, además, el pago de intereses moratorios, según lo establecido en el artículo 66 del Código Orgánico Tributario, previamente reseñado.
    </p>
    <br />
    <p>
        En relación a la sanción de multa que debe imponerse a los contribuyentes, es justo hacer referencia al contenido del artículo 94 del Código Orgánico Tributario, cuyos parágrafos primero y segundo se reproducen de inmediato: 
    </p>
    <p>
        <i><b>Parágrafo Primero:</b></i>“Cuando las multas establecidas en este Código estén expresadas en unidades tributarias (U.T.), se utilizará el valor de la unidad tributaria que estuviere vigente para el momento del pago”.<br />
        <i><b>Parágrafo Segundo:</b></i>“Las multas establecidas en este Código expresadas en términos porcentuales, se convertirán al equivalente de unidades tributarias (U.T.) que correspondan al momento de la comisión del ilícito, y se cancelarán utilizando el valor de la misma que estuviere vigente para el momento del pago.”
    </p>
    <br />
    <p>
        En ese sentido, de conformidad con el criterio reiterado y pacífico de la Sala Político Administrativa del Tribunal Supremo de Justicia, en relación al momento de la comisión del ilícito se ha sentado lo siguiente: “Así, esta Sala de manera reiterada ha establecido que a los efectos de considerar cuál es la unidad tributaria aplicable para la fijación del monto de la sanción de multa con las infracciones cometidas bajo la vigencia del Código Tributario de 2001, ha expresado que debe tomarse en cuenta la fecha de emisión del acto administrativo, pues es ése el momento cuando la Administración Tributaria determina -previo procedimiento- la comisión de la infracción que consecuentemente origina la aplicación de la sanción respectiva. (Vid. Sentencias Nos. 0314, 0882 y 01170 de fecha 06 de junio de 2007; 22 de febrero de 2007, y 12 de julio de 2006, respectivamente.).
    </p>
    <br />
    <p>
       De lo anterior se colige que en el presente caso, visto que con la notificación de este acto administrativo se hace del conocimiento del contribuyente su condición de infractor de la norma, que en estricto apego a la jurisprudencia pacífica y reiterada del Tribunal Supremo de Justicia es ese el momento de la comisión del ilícito, que de acuerdo con el artículo 94 previamente traído a colación, se deben convertir las multas expresadas en términos porcentuales a su equivalente en unidades tributarias, y que de acuerdo con la providencia administrativa
       <b>Agregar este campo a la tabla de unidades tributarias</b> de fecha <b>Agregar este campo a la tabla de unidades tributarias</b> y publicada en la Gaceta Oficial de la República Bolivariana de Venezuela N° <b>Agregar este campo a la tabla de unidades tributarias</b> de fecha <b>Agregar este campo a la tabla de unidades tributarias</b>, la unidad tributaria vigente equivale a la cantidad de <b><?php echo $this->monedas_texto->num_to_letras(trim($ut['variable0'])); ?>,</b> se concluye que es este monto el que se debe utilizar para realizar la conversión de las sanciones a la que hace referencia el Código.
    </p>
    <p>
      Dicho esto, la sanción en términos porcentuales correspondiente a la actitud infractora del contribuyente es equivalente al uno por ciento (1%) del tributo pagado fuera del plazo, lo que en este caso equivale a <b><?php echo $this->monedas_texto->num_to_letras(trim($totalm)) ?>,</b> una vez realizadas las operaciones aritméticas correspondientes se tiene que, en términos de unidades tributarias, la sanción equivale a <b><?php echo $this->unidades_tributarias_texto->num_to_letras(trim(round($totalm/ $ut['variable0'],2)))?>,</b> según se evidencia del siguiente cuadro: 
    </p>
    <br />
     <div class="tabla_body2">
         <table border="2"  >
             <thead>
               <tr id="head">
                   <th >A&ntilde;o</th><th>Multa en Unidades<br />Tributarias</th><th>Unidad Tributaria<br />Aplicable</th><th>Multa en Bs.</th>                

                 </tr> 
               </thead>
                 <tr class='tr-body'>
                     <td >
                         <?php echo date('Y') ?>
                     </td>
                     <td>
                         <?php echo round($totalm/ $ut['variable0'],2); ?>
                     </td>
                     <td>
                         <?php echo $ut['variable0']; ?>
                     </td>
                     <td>
                         <?php echo $totalm; ?>
                     </td>
                     
                     
                 </tr>
                  <tr>
                     <td  style=" border-color: #ffffff"></td>
                     <td colspan="2" style=" background: #993300; color: #ffffff; text-align: center;font-weight: bold ; padding-top: 2px; padding-bottom: 2px; font-size: 10px"><b>TOTAL</b></td>
                      <td  style=" background: #993300;color: #ffffff; text-align: center;font-weight: bold ; padding-top: 2px; padding-bottom: 2px; font-size: 10px"><b><?php echo round($totalm,2); ?></b></td>
                 </tr>
         </table>
     </div>
    <br />
    <p>
        De modo que, como consecuencia del contenido normativo establecido en el artículo 66 del Código Orgánico Tributario, este Centro Nacional Autónomo de Cinematografía (CNAC), por órgano del Fondo de Promoción y Financiamiento del Cine (FONPROCINE) procede a realizar el cálculo de intereses moratorios sobre la base de la contribución especial pagada extemporáneamente, desde la fecha de vencimiento del plazo fijado para el pago de la obligación tributaria hasta la fecha de pago efectivamente realizado, aplicados según 1.2 veces la tasa activa bancaria promedio de los seis (6) principales bancos comerciales y universales del país con mayor volumen de depósitos, excluidas las carteras con intereses preferenciales, calculada por el Banco Central de Venezuela para el mes calendario, por cada uno de los períodos en que dichas tasas estuvieron vigentes, tal como se demuestra a continuación:
    </p>
    <?php 
    foreach ($detalles_intereses as $clave => $valor): 
                 $total_interes=0;
//    <th>Planilla<br />Nº</th>
              echo "<div class='tabla_body3'>
                        <table border='2'  >
                        <thead>
                            <tr id='head'>
                                <th>Mes de<br />pago</th><th>Fecha limite<br />de pago</th><th>Periodo Liquidado</th><th>Dias<br />Atarso</th><th>Capital</th><th>Tasa de<br/>Interes</th><th>Recargo<br />Segun Art.66<br />C.O.T</th><th>Tasa<br />Diaria</th><th>Interes del<br />Mes en BS</th>                

                            </tr>
                        </thead>";
                            foreach ($valor as $key => $value) {
              //                  foreach ($value as $key2 => $value2) {                      
                               if(is_array($value)){
                                echo"<tr class='tr-body'>";
                                        if($key==0){
                                             $p=count($valor);
//                                             <td valign='middle' width='10'  rowspan='".(count($valor)-4)."'>$valor[nudeclara]</td>
                                            echo "
                                                  <td valign='middle' rowspan='".(count($valor)-4)."'>".$this->funciones_complemento->devuelve_meses_text(date('m',strtotime($valor['fechapago']))).' / '.date('Y',strtotime($valor['fechapago']))."</td>
                                                  <td valign='middle' rowspan='".(count($valor)-4)."'>$valor[fechalim]</td>
                                                  <td valign='middle' rowspan='".(count($valor)-4)."'>$clave $valor[anio]</td>
                                                ";
                                        }
                                         echo"<td>$value[dias]</td>
                                                  <td>".$this->funciones_complemento->devuelve_cifras_unidades_mil($value['capital'])."</td>
                                                      <td>".$value['tasa%']."</td>
                                                          <td>1,2</td>
                                                              <td>$value[tasa]</td>
                                                                  <td>".$this->funciones_complemento->devuelve_cifras_unidades_mil($value['intereses'])."</td>
                                     </tr>";
              //                  }
                                $total_interes=$total_interes+$value['intereses'];
                               }
                            }
                            echo ' <tr>
                                        <td colspan="8" style=" background: #800000;color: #ffffff; text-align: center; padding-top: 2px; padding-bottom: 2px; font-size: 10px"><b>TOTAL INTERES '.$data[$id]['contribuyente'].':</b></td>
                                           <td style=" background: #800000;color: #ffffff; text-align: center; padding-top: 2px; padding-bottom: 2px; font-size: 12px"><b> '.$this->funciones_complemento->devuelve_cifras_unidades_mil(round($total_interes,2)).'</b></td> 
                                    </tr>';
                echo "</table>
                    </div>
                    <br />";
             endforeach; 
             ?> 
    
             <p>
                 Para concluir, habiendo nacido la obligación tributaria desde el momento mismo en que se produjo el hecho generador y no habiéndose efectuado el pago dentro del término establecido, el cual se cuenta desde el día en que se hace exigible el pago, se declara procedente el cobro de los intereses moratorios a partir del vencimiento del lapso para el pago de la contribución especial, hasta la fecha efectiva de la compensación bancaria efectuada, cuyo cálculo resulta la cantidad de <b><?php echo $this->monedas_texto->num_to_letras(trim(round($total_interes,2))) ?>,</b>
                  <br />tal como se señala supra.
             </p>
             <br />
                <p style=" text-align: center; "><b>V. DECISIÓN</b></p>
            <br />
            <p>
                Visto lo anteriormente señalado, El Centro Nacional Autónomo de Cinematografía (CNAC), procediendo de conformidad con la competencia atribuida en el artículo 63 de la Ley de la Cinematografía Nacional resuelve:
            </p>
            <p>
                <b>PRIMERO:</b>&nbsp; Imponer multa según lo previsto en el artículo 110 de Código Orgánico Tributario, en concordancia con el artículo 136 ejusdem, por la cantidad de&nbsp;<b><?php echo $this->monedas_texto->num_to_letras(trim($totalm)) ?>,</b>&nbsp;equivalente a&nbsp;<b><?php echo $this->unidades_tributarias_texto->num_to_letras(trim(round($totalm/ $ut['variable0'],2)))?>,</b>
            </p>
            <p>
                <b>SEGUNDO:</b>&nbsp;Liquidar intereses moratorios de conformidad con lo establecido en el artículo 66 del Código Orgánico Tributario, por la cantidad de&nbsp;<b><?php echo $this->monedas_texto->num_to_letras(trim(round($total_interes,2))) ?>,</b>,&nbsp;para el período ya señalado.
            </p>
            <p>
                <b>TERCERO:</b>&nbsp;Notificar a la sociedad mercanti&nbsp;<b><?php echo $data[$id]['contribuyente']; ?></b>,&nbsp;de los resultados plasmados en la presente Resolución, de conformidad con lo previsto en el Artículo 162 del Código Orgánico Tributario.
            </p>
            <p>
                <b>CUARTO:</b>&nbsp;El Fondo de Promoción y Financiamiento del Cine (FONPROCINE), cumple con informarle, que la cuenta dispuesta para la cancelación del monto expresado en la conclusión primera, correspondiente a la multa, es la identificada como cuenta corriente, Nº 0134-0031-88-0311126075, a nombre del Centro Nacional Autónomo de Cinematografía (CNAC), de la institución financiera Banesco Banco Universal.
            </p>
            <p>
                <b>QUINTO:</b>&nbsp;Así mismo de acuerdo a lo dispuesto en la conclusión segunda, correspondiente a los intereses moratorios, el pago se realiza en la cuenta de corriente, Nº 0134-0861-18-8613000268, a nombre de Centro Nacional Autónomo de Cinematografía (CNAC), de la institución financiera Banesco Banco Universal, o a través de las planillas de autoliquidación emitidas por la institución financiera Banco Provincial, las cuales deben ser retiradas en nuestras oficinas.
            </p>
            <p>
               Aceptando la imposición de sanción por extemporaneidad y pagada la multa e intereses moratorios se deberán consignar las planillas de pago ante la Gerencia de Recaudación Tributaria, ubicada en la Avenida Francisco de Miranda con Calle los Laboratorios, Edificio Quórum, Piso 01, Oficinas F, G y H, CNAC-FONPROCINE, Urbanización Los Ruices, Municipio Sucre del Estado Miranda, dentro de los 15 días hábiles siguientes contados a partir de la notificación de la presente resolución. De no estar de acuerdo con su contenido, el interesado podrá interponer el Recurso Jerárquico establecido en el artículo 242 y siguientes del Código Orgánico Tributario, teniendo un lapso de 25 días hábiles contados a partir del día siguiente a la fecha de notificación del acto que se impugna, así como el Recurso Contencioso Tributario según lo previsto en el artículo 259 y siguientes ejusdem, el cual podrá ser interpuesto independiente, subsidiaria o conjuntamente con el Recurso Jerárquico, dentro de los 25 días hábiles siguientes contados a partir de la notificación del presente acto. 
            </p>
            <p>
                Para que así conste y a los fines consiguientes, se levanta la presente resolución en 2 ejemplares de un mismo tenor y a un solo efecto, de los cuales uno queda en poder de la contribuyente.
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
                
                <table id="firma_recibido" border="0" cellspacing="0" cellpadding="0">
                    <tr>
                        <td ><b>POR EL CONTRIBUYENTE</b></td>
                        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>                       
                        <td ><b> EL FUNCIONARIO ACTUANTE</b></td>
                    </tr>
                    <tbody valign="top">
                        <tr>
                            <td class="td-border">Apellidos y Nombres:</td>
                            <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>                       
                            <td class="td-border" >Apellidos y Nombres:</td>
                        </tr>
                        <tr>
                            <td class="td-border">Cédula de Identidad:</td>
                            <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>                       
                            <td class="td-border" >Cédula de Identidad:</td>
                        </tr>
                        <tr>
                            <td class="td-border">Cargo:</td>
                            <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>                       
                            <td class="td-border" >Cargo:</td>
                        </tr>
                        <tr>
                            <td class="td-border">Fecha:</td>
                            <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>                       
                            <td class="td-border" >Fecha:</td>
                        </tr>
                        <tr>
                            <td class="td-border">Firma:</td>
                            <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>                       
                            <td class="td-border" >Firma:</td>
                        </tr>
                    </tbody>
                    
                </table>
                <br />
                <p>SELLO:</p>
</page>
<style>
    
/*    #firma_recibido td{
        width: 200px
    }*/
    .td-border{
         border-collapse: collapse;
         border:1px solid #000000;
         height: 25px;
         width: 300px
    }
</style>