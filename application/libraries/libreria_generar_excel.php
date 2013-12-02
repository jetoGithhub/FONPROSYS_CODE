<? if ( ! defined('BASEPATH')) exit('No se permite acceso directo al script');
/*************************************************************************************************
 *Fecha:28-06-2013,                                                                              *
 *Empresa:LCT tecnologias,                                                                       *
 *Creador: Ing. Silvia Valladares,                                                               *                               
 *Descripcion: Librerias para las funciones que generan archivos excel,                          *
 *Version:1.0                                                                                    *         
 *************************************************************************************************/
require_once dirname(__FILE__) . '/html2pdf/html2pdf.php';
require_once dirname(__FILE__) . '/generar_excel/PHPExcel.php';

class Libreria_generar_excel extends HTML2PDF {


 function __construct(){
       
        $this->usoci =& get_instance();
//      $this->usoci->load->config('funciones_complemento');
        
   }
    
   
   
   /*funcion para generar excel con varias hojas
    * en Finanzas -> Calculos por aprobar -> excel
    */
   function generar_excel_extemporaneo($result1){
            
       /*
        * ESTILOS
        */     
       $styleArray = array(
                'font' => array(
                    'bold' => true,
                    ),
                
                //borde delgado
                'borders' => array(
                    'allborders' => array(
                        'style' => PHPExcel_Style_Border::BORDER_HAIR,
                       ),
                    ),
                'alignment' => array(
                    'horizontal' => PHPExcel_Style_Alignment::HORIZONTAL_CENTER,
                    'vertical' => PHPExcel_Style_Alignment::VERTICAL_CENTER,
                    ),
                'fill' => array(
                    'type' => PHPExcel_Style_Fill::FILL_GRADIENT_LINEAR,
                    'rotation' => 90,
                    'startcolor' => array(
                        'argb' => '3B3838',
                        ),
                    'endcolor' => array(
                        'argb' => 'FFFFFFF',
                        ),
                    ),
                );
            
       
            $styleArray2 = array(
                'font' => array(
                    'bold' => true,
                    ),
                );
            
            $styleArray3 = array(
                //borde delgado
                'borders' => array(
                    'allborders' => array(
                        'style' => PHPExcel_Style_Border::BORDER_HAIR,
                       ),
                    ),
                'alignment' => array(
                    'horizontal' => PHPExcel_Style_Alignment::HORIZONTAL_RIGHT,
                    ),
                
                'font' => array(
                    'bold' => true,
                    ),

                'fill' =>array(
                    'type' => PHPExcel_Style_Fill::FILL_GRADIENT_LINEAR,
                    'rotation' => 90,
                    'startcolor' => array(
//                        'argb' => 'E6443C',
                        'argb' => 'BFBFBF',
                        ),
                    'endcolor' => array(
                        'argb' => 'FFFFFFF',
                        ),
                    ),
                );
            
            $styleArray4 = array(
                //borde delgado
                'borders' => array(
                    'allborders' => array(
                        'style' => PHPExcel_Style_Border::BORDER_HAIR,
                       ),
                    ),
                
                
                );
            
            $styleArray5 = array(
                //borde delgado
                'borders' => array(
                    'allborders' => array(
                        'style' => PHPExcel_Style_Border::BORDER_HAIR,
                       ),
                    ),
                'alignment' => array(
                    'horizontal' => PHPExcel_Style_Alignment::HORIZONTAL_CENTER,
                    ),
                'font' => array(
                    'bold' => true,
                    ),
                );
            
            $styleArray6 = array(
                //borde delgado
                'borders' => array(
                    'right' => array(
                        'style' => PHPExcel_Style_Border::BORDER_HAIR,
                       ),
                    ),
                );
            
            
            $styleArray7 = array(
                //borde delgado
                'borders' => array(
                    'right' => array(
                        'style' => PHPExcel_Style_Border::BORDER_HAIR,
                       ),
                    'bottom' => array(
                        'style' => PHPExcel_Style_Border::BORDER_HAIR,
                       ),
                    ),
                );
            
            
            /*
             * FIN ESTILOS
             */


            $objPHPExcel = new PHPExcel();
            $objPHPExcel->getActiveSheet()->getHeaderFooter()->setOddHeader('&L&G');
            

            // Establecer propiedades
            $objPHPExcel->getProperties()
            ->setCreator("Fonprocine")
            ->setLastModifiedBy("Fonprocine")
            ->setTitle("Reporte Calculos Extemporaneos")
            ->setSubject("Reporte Calculos Extemporaneos")
            ->setKeywords("Excel Office 2007 openxml php")
            ->setCategory("Reporte Calculos Extemporaneos");

            
            //alto filas desde la 1 hasta la 3
            $objPHPExcel->getActiveSheet()->getRowDimension('1')->setRowHeight(22);
            $objPHPExcel->getActiveSheet()->getRowDimension('2')->setRowHeight(22);
            $objPHPExcel->getActiveSheet()->getRowDimension('3')->setRowHeight(22);
            
            
            //FILA DE CABECERA-TITULO, DESDE CELDA A1 HASTA Q7 DEL EXCEL
            $objPHPExcel->setActiveSheetIndex(0)
                    ->setCellValue('A1','CNAC')
                    ->setCellValue('A2','FONPROCINE')
                    ->setCellValue('A3','INTERESES MORATORIOS DE PAGOS EXTEMPORANEOS')
                    ->setCellValue('A4', '')
                    ->setCellValue('A5', '')
                    ->setCellValue('A6', '')
            ->setCellValue('A7', 'CONTRIBUYENTE')
            ->setCellValue('B7', 'TRIBUTO PAGADO')
            ->setCellValue('C7', 'FECHA DE PAGO')
            ->setCellValue('D7', 'N° DEPOSITO')
            ->setCellValue('E7', 'MES DE PAGO')
            ->setCellValue('F7', 'FECHA LIMITE DE PAGO')
            ->setCellValue('G7', 'PERIODO LIQUIDADO')
            ->setCellValue('H7', 'DIAS DE ATRASO')
            ->setCellValue('I7', 'MES DE PAGO-')
            ->setCellValue('J7', 'TIPO DE CONTRIBUYENTE')
            ->setCellValue('K7', 'MULTA 1% ART. 110 C.O.T.')
            ->setCellValue('L7', 'MULTA EN U.T.')
            ->setCellValue('M7', 'CAPITAL')
            ->setCellValue('N7', 'TASA DE INTERES')
            ->setCellValue('O7', 'RECARGO -ART. 66- C.O.T.')
            ->setCellValue('P7', 'TASA DIARIA')
            ->setCellValue('Q7', 'INTERES DEL MES EN Bs.');    
            
             
            /*Combinar celdas para dar mas height a las filas de los titulos-cabeceras
             * Array columnas para identificar las letras de las columnas
             */
            
            $columnas = array('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q');
            //recorrer el array de columnas para poder combinar la fila 7 y 8 para darle mas height a las celdas de los titulos-cabecera                    
            foreach ($columnas as $columnas) {
                //propiedad mergeCells para combinar celdas
               $objPHPExcel->getActiveSheet()->mergeCells($columnas.'7:'.$columnas.'8');

            }
            
            //el contador de las celdas (filas) inicia a partir de 9, fila consecutiva de las filas de los titulos
            $contador_celda=9;
                
            /*
             * acumuladores para los totales de las columnas: dias de atraso, capital, interes del mes en Bs
             */
                $acum_dias=0;
                $acum_interes_mes=0;
                $acum_capital=0;
                
                $ap=array();
                
                /*
                 * recorrido de todos los elementos que trae el array result,
                 * construido en el modelo lista_por_aprobar_m en la funcion
                 * lista_calculos_por_aprobar_excel, donde retornan todos los 
                 * contribuyentes que ya fueron previamente calculados.                 * 
                 * 
                 */
                for($i=0;$i<count($result1);$i++)
                {
                    
                    /*
                     * condiciones para indicar lo que se imprimira en la columna 'Periodo'
                     * segun  sea el tipo de contribuyente
                     */
                    //mensual
                    if($result1[$i]['peano']==12)
                    {
                        $result1[$i]['peano']=$result1[$i]['mes_pago_dec'].' '.$result1[$i]['ano_calpago'];
                    }else if($result1[$i]['peano']==4)  //trimestral
                    {
                         $result1[$i]['peano']=$result1[$i]['periodo'].'°'.' Trimestre'.' '.$result1[$i]['ano_calpago'];
                    } else if($result1[$i]['peano']==1) //anual
                    {
                        $result1[$i]['peano']=$result1[$i]['ano_calpago'];
                    }
                              
                    $ap[$i]=$result1[$i]['id_calpagod'];
                    
                    /*condicion para aplicar todos las caracteristicas al primer elemento del array result
                     * CONDICION PARA IMPRIMIR LA PRIMERA FILA SIEMPRE Y CUANDO SEA LA PRIMERA VUELTA DEL FOR
                     */
                    
                    if($i==0)
                    {
                        $contribuyente=$result1[$i]['nombre'];
                        $calpagod=$result1[$i]['id_calpagod'];
                        
                        $objPHPExcel->setActiveSheetIndex(0)
                        ->setCellValue('A'.$contador_celda.'', $result1[$i]['nombre'])
                        ->setCellValue('B'.$contador_celda.'', $result1[$i]['monto_declara'])
                        ->setCellValue('C'.$contador_celda.'', $result1[$i]['fecha_pago_dec'])
                        ->setCellValue('D'.$contador_celda.'', 'num deposito')
                        ->setCellValue('E'.$contador_celda.'', $result1[$i]['mes_anio_pago_dec'])
                        ->setCellValue('F'.$contador_celda.'', $result1[$i]['fechalim'])
                        ->setCellValue('G'.$contador_celda.'', $result1[$i]['peano'])
                        ->setCellValue('J'.$contador_celda.'', $result1[$i]['nomb_tcont'])
                        ->setCellValue('K'.$contador_celda.'', $result1[$i]['montopagar'])
                        ->setCellValue('L'.$contador_celda.'', 'ut');
                        
                    }  else {
                        // en caso contrario se toman en cuenta las siguientes condiciones
                        
                        
                        /*CON LA SIGUIENTE CONDICION SE DETERMINA LA FILA DE FINIQUITO DEL CONTRIBUYENTE QUE VIENE DE LA VUELTA
                         * ANTERIOR Y SE DETERMINA LA FILA DE INICIO DEL CONTRIBUYENTE QUE VIENE EN LA VUELTA ACTUAL, SIEMPRE Y
                         * CUANDO EL NOMBRE DEL CONTRIBUYENTE DE LA VUELTA ACTUAL SEA DIFERENTE AL NOMBRE DEL CONTRIBUYENTE
                         * DE LA VUELTA ANTERIOR       
                         */
                        if(($contribuyente!=$result1[$i]['nombre']))
                        {
                                
                                  $calpagod=$result1[$i]['id_calpagod'];
//                                  ECHO $result1[$i]['nombre'];
//                                  DIE();
                                 
                                  /*al imprimir el total, se coloca $contribuyente,
                                   * porque es que el que trae el nombre del contribuyente 
                                   * del ciclo anterior, ya que al ser distintos se necesita 
                                   * imprimir el total del contribuyente anterior y dicho
                                   *  nombre esta almacenado en $contribuyente 
                                   */
                                  
                                  
                                  //imprimir acumuladores bajo esta condicion -hola
                                 $objPHPExcel->setActiveSheetIndex(0)
                                 ->setCellValue('A'.$contador_celda.'', 'TOTAL '.$contribuyente)
                                 ->setCellValue('H'.$contador_celda.'', $acum_dias)
                                 ->setCellValue('M'.$contador_celda.'', $acum_capital)
                                 ->setCellValue('Q'.$contador_celda.'', $acum_interes_mes);
                            
                            /*aplicar estilo a fila de total por contribuyente
                             * construir un arreglo con las letras de las columnas y despues recorrerlo para aplicar estilos
                             */
                              $columnas = array('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q');
                                
                              foreach ($columnas as $columnas) {
                                 $objPHPExcel->getActiveSheet()->getStyle($columnas.$contador_celda)->applyFromArray($styleArray3);
                              
                              }


                                 $acum_dias=0;
                                 $acum_capital=0;
                                 $acum_interes_mes=0;
                                 $contador_celda=$contador_celda+1;

                                $contribuyente=$result1[$i]['nombre'];
                                $objPHPExcel->setActiveSheetIndex(0)

                                ->setCellValue('A'.$contador_celda.'', $result1[$i]['nombre'])
                                ->setCellValue('B'.$contador_celda.'', $result1[$i]['monto_declara'])
                                ->setCellValue('C'.$contador_celda.'', $result1[$i]['fecha_pago_dec'])
                                ->setCellValue('D'.$contador_celda.'', 'num deposito')
                                ->setCellValue('E'.$contador_celda.'', $result1[$i]['mes_anio_pago_dec'])
                                ->setCellValue('F'.$contador_celda.'', $result1[$i]['fechalim'])
                                ->setCellValue('G'.$contador_celda.'', $result1[$i]['peano'])
                                ->setCellValue('J'.$contador_celda.'', $result1[$i]['nomb_tcont'])
                                ->setCellValue('K'.$contador_celda.'', $result1[$i]['montopagar'])
                                ->setCellValue('L'.$contador_celda.'', 'ut');
                            
                        /*CON LA SIGUIENTE CONDICION SE DETERMINA LA FILA DE FINIQUITO DEL CONTRIBUYENTE QUE VIENE DE LA VUELTA
                         * ANTERIOR Y SE DETERMINA LA FILA DE INICIO DEL CONTRIBUYENTE QUE VIENE EN LA VUELTA ACTUAL, SIEMPRE Y
                         * CUANDO EL id_calpagod DEL CONTRIBUYENTE DE LA VUELTA ACTUAL SEA DIFERENTE AL id_calpagod DEL CONTRIBUYENTE
                         * DE LA VUELTA ANTERIOR. 'id_calpagod' -> hace referencia al periodo en el que el contribuyente quedó en omiso       
                         */
                       } else if($calpagod!=$result1[$i]['id_calpagod'])
                       {
                           $calpagod=$result1[$i]['id_calpagod'];

    //                            $contador_celda=$contador_celda+1;
    //                             echo $result1[$i]['nombre'].'-'.$contribuyente;
    //                             die();
                                 $objPHPExcel->setActiveSheetIndex(0)
                                 ->setCellValue('A'.$contador_celda.'', 'TOTAL '.$result1[$i]['nombre'])
                                 ->setCellValue('H'.$contador_celda.'', $acum_dias)
                                 ->setCellValue('M'.$contador_celda.'', $acum_capital)
                                 ->setCellValue('Q'.$contador_celda.'', $acum_interes_mes);
                                 
                                 
                                     
                            /*aplicar estilo a fila de total por contribuyente
                             * construir un arreglo con las letras de las columnas y despues recorrerlo para aplicar estilos
                             */
                              $columnas = array('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q');

                              foreach ($columnas as $columnas) {
                                 $objPHPExcel->getActiveSheet()->getStyle($columnas.$contador_celda)->applyFromArray($styleArray3);
                              
                              }
                              
                              /*
                               * y de forma consecutiva al total, imprime el siguiente contribuyentes
                               */

                                 $acum_dias=0;
                                 $acum_capital=0;
                                 $acum_interes_mes=0;
                                 $contador_celda=$contador_celda+1;

                                $contribuyente=$result1[$i]['nombre'];
                                $objPHPExcel->setActiveSheetIndex(0)

                                ->setCellValue('A'.$contador_celda.'', $result1[$i]['nombre'])
                                ->setCellValue('B'.$contador_celda.'', $result1[$i]['monto_declara'])
                                ->setCellValue('C'.$contador_celda.'', $result1[$i]['fecha_pago_dec'])
                                ->setCellValue('D'.$contador_celda.'', 'num deposito')
                                ->setCellValue('E'.$contador_celda.'', $result1[$i]['mes_anio_pago_dec'])
                                ->setCellValue('F'.$contador_celda.'', $result1[$i]['fechalim'])
                                ->setCellValue('G'.$contador_celda.'', $result1[$i]['peano'])
                                ->setCellValue('J'.$contador_celda.'', $result1[$i]['nomb_tcont'])
                                ->setCellValue('K'.$contador_celda.'', $result1[$i]['montopagar'])
                                ->setCellValue('L'.$contador_celda.'', 'ut');
                           
                       }
                        
                          

                    }
                    //fin de condiciones donde se analiza si es a partir del primer contribuyente a imprimir
                    
                   $objPHPExcel->setActiveSheetIndex(0)

                  ->setCellValue('H'.$contador_celda.'', $result1[$i]['dias'])
                  ->setCellValue('I'.$contador_celda.'', $result1[$i]['mes_anio_pago_i'])
                  ->setCellValue('M'.$contador_celda.'', $result1[$i]['monto_declara'])       
                  ->setCellValue('N'.$contador_celda.'', 'bcv')       
                  ->setCellValue('O'.$contador_celda.'', '1,2')
                  ->setCellValue('P'.$contador_celda.'', $result1[$i]['tasa_interes'])
                  ->setCellValue('Q'.$contador_celda.'', $result1[$i]['total_interes_mes']);
                    
                    $acum_dias=$acum_dias+$result1[$i]['dias'];
                    $acum_capital=$acum_capital+$result1[$i]['monto_declara'];
                    $acum_interes_mes=$acum_interes_mes+$result1[$i]['total_interes_mes'];
                    $contador_celda++;
                    
                    if($i==(count($result1)-1))
                    {
//                            print_r($result1);
//                           die();
//                        $contador_celda=$contador_celda+1;
                         $objPHPExcel->setActiveSheetIndex(0)
                            ->setCellValue('A'.$contador_celda.'', 'TOTAL '.$result1[$i]['nombre'])
                            ->setCellValue('H'.$contador_celda.'', $acum_dias)
                            ->setCellValue('M'.$contador_celda.'', $acum_capital)
                            ->setCellValue('Q'.$contador_celda.'', $acum_interes_mes);
                         
                             
                            /*aplicar estilo a fila de total por contribuyente
                             * construir un arreglo con las letras de las columnas y despues recorrerlo para aplicar estilos
                             */
                              $columnas = array('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q');

                              foreach ($columnas as $columnas) {
                                 $objPHPExcel->getActiveSheet()->getStyle($columnas.$contador_celda)->applyFromArray($styleArray3);
                              
                              }

                    }
                    
                    //estilo de bordes para todas las celdas a partir de la siguiente fila de los titulos
                    $objPHPExcel->getActiveSheet()->getStyle('A'.$contador_celda.':Q'.$contador_celda.'')->applyFromArray($styleArray4);
                
                }//fin del for
                
//cuadro que se ubica en la parte inferior del reporte, independiente de los ciclos declarados anteriormente
                
                $contador_celda_sum=$contador_celda+5;
                $cont_celda_sum_sig=$contador_celda_sum+1;
                $cont_celda_sum_sig_b=$cont_celda_sum_sig+1;
                
                
                //recorrido para estilo desde la columna A hasta la E
                $style_columnas = array('A', 'B', 'C', 'D', 'E');
                for($c=0; $c<count($style_columnas); $c++)
                {
                    $objPHPExcel->getActiveSheet()->getStyle($style_columnas[0].$contador_celda_sum.':'.$style_columnas[4].$contador_celda_sum)->applyFromArray($styleArray5);
                    $objPHPExcel->getActiveSheet()->getStyle($style_columnas[0].$cont_celda_sum_sig.':'.$style_columnas[4].$cont_celda_sum_sig)->applyFromArray($styleArray5);
                    $objPHPExcel->getActiveSheet()->getStyle($style_columnas[0].$cont_celda_sum_sig_b.':'.$style_columnas[4].$cont_celda_sum_sig_b)->applyFromArray($styleArray5);
                    
                }
                
                
                
                
                $columnas = array('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I');
                for($c=0; $c<count($columnas); $c++)
                {
                    
                    
                    //estilo desde la columna F hasta la I
                    $objPHPExcel->getActiveSheet()->getStyle($columnas[5].$contador_celda_sum.':'.$columnas[8].$contador_celda_sum)->applyFromArray($styleArray5);
                    
                    $objPHPExcel->getActiveSheet()->getStyle($columnas[5].$cont_celda_sum_sig.':'.$columnas[8].$cont_celda_sum_sig)->applyFromArray($styleArray6);
                    
                    $objPHPExcel->getActiveSheet()->getStyle($columnas[5].$cont_celda_sum_sig_b.':'.$columnas[8].$cont_celda_sum_sig_b)->applyFromArray($styleArray7);
                    //fin de estilo desde la columna F hasta la I
                    
//combinacion desde la columna B hasta la D de la fila $contador_celda_sum (primera)
                    $objPHPExcel->getActiveSheet()->mergeCells($columnas[1].$contador_celda_sum.':'.$columnas[2].$contador_celda_sum.'');

                    //combinacion desde la columna E hasta la G de la fila $contador_celda_sum (primera)
                    $objPHPExcel->getActiveSheet()->mergeCells($columnas[3].$contador_celda_sum.':'.$columnas[4].$contador_celda_sum.'');
                    
                    //combinacion desde la columna H hasta la K de la fila $contador_celda_sum (primera)
                    $objPHPExcel->getActiveSheet()->mergeCells($columnas[5].$contador_celda_sum.':'.$columnas[8].$contador_celda_sum.'');
                    
                    
                    
                    //combinacion desde la columna B hasta la D de la fila $cont_celda_sum_sig (segunda)
                    $objPHPExcel->getActiveSheet()->mergeCells($columnas[1].$cont_celda_sum_sig.':'.$columnas[2].$cont_celda_sum_sig.'');

                    //combinacion desde la columna E hasta la G de la fila $contador_celda_sum (primera)
                    $objPHPExcel->getActiveSheet()->mergeCells($columnas[3].$cont_celda_sum_sig.':'.$columnas[4].$cont_celda_sum_sig.'');
                    
                    //combinacion desde la columna B hasta la D de la fila $cont_celda_sum_sig_b (segunda)
                    $objPHPExcel->getActiveSheet()->mergeCells($columnas[1].$cont_celda_sum_sig_b.':'.$columnas[2].$cont_celda_sum_sig_b.'');

                    //combinacion desde la columna E hasta la G de la fila $cont_celda_sum_sig_b (primera)
                    $objPHPExcel->getActiveSheet()->mergeCells($columnas[3].$cont_celda_sum_sig_b.':'.$columnas[4].$cont_celda_sum_sig_b.'');
                    
                    
                    //combinacion desde la columna H hasta la K de la fila $cont_celda_sum_sig (segunda)
                    $objPHPExcel->getActiveSheet()->mergeCells($columnas[5].$cont_celda_sum_sig.':'.$columnas[8].$cont_celda_sum_sig.'');
                    
                    //combinacion desde la columna H hasta la K de la fila $cont_celda_sum_sig_b (segunda)
                    $objPHPExcel->getActiveSheet()->mergeCells($columnas[5].$cont_celda_sum_sig_b.':'.$columnas[8].$cont_celda_sum_sig_b.'');

                //textos
                $fecha=date('d/m/Y');

                $objPHPExcel->setActiveSheetIndex(0)
                            ->setCellValue($columnas[0].$contador_celda_sum.'', 'Elaborado por')
                            ->setCellValue($columnas[1].$contador_celda_sum.'', 'Revisado por')
                            ->setCellValue($columnas[3].$contador_celda_sum.'', 'Conformado por')
                            ->setCellValue($columnas[5].$contador_celda_sum.'', 'Aprobado en Reunión del Comité Ejecutivo N° XX-XX  Fecha:'.$fecha)


                            ->setCellValue($columnas[0].$cont_celda_sum_sig_b.'', 'Gerente de Finanzas Tributarias')
                            ->setCellValue($columnas[1].$cont_celda_sum_sig_b.'', 'Gerente General de FONPROCINE')
                            ->setCellValue($columnas[3].$cont_celda_sum_sig_b.'', 'Presidente del CNAC');
                    
                //Fin textos    
                    
                }
                
                //alto de la primera fila del cuadro
                $objPHPExcel->getActiveSheet()->getRowDimension($contador_celda_sum)->setRowHeight(30);
                $objPHPExcel->getActiveSheet()->getRowDimension($cont_celda_sum_sig)->setRowHeight(40);
                $objPHPExcel->getActiveSheet()->getRowDimension($cont_celda_sum_sig_b)->setRowHeight(30);

                    

//fin cuadro extra               
                
                //estilo para los titulos desde la fila 1 hasta la fila 3 de la columna A
                $objPHPExcel->getActiveSheet()->getStyle('A1:A3')->applyFromArray($styleArray2);

                /*construir un arreglo con las letras de las columnas y despues recorrerlo para aplicar estilos
                */
                $columnas = array('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q');
                //recorrido para aplicar estilo a los titulo
                foreach ($columnas as $columnas) {
                   $objPHPExcel->getActiveSheet()->getStyle($columnas.'7:'.$columnas.'8')->applyFromArray($styleArray);
                }  
                

              // Renombrar Hoja
            $objPHPExcel->getActiveSheet()->setTitle('Aspectos Operativos');

            
//**define una cabecera fija de impresion
            $objPHPExcel->getActiveSheet()->getPageSetup()->setRowsToRepeatAtTopByStartAndEnd(1, 6);


                    /*ancho automatico de las columnas, va dentro del foreach o for que recorre el arreglo columnas
                     * se elimino porque el ancho de las columnas se establecieron a continuacion de forma manual 
                     * $objPHPExcel->getActiveSheet()->getColumnDimension($columnas)->setAutoSize(true);
                     */
                    
            
            //ancho manual de las columnas - especifico de la columna A
             $objPHPExcel->getActiveSheet()->getColumnDimension('A')->setWidth(50);
            
            $columnas = array('B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q');
                //recorrido para aplicar anchos a partir de la columna B, la A toma un ancho especifico
                foreach ($columnas as $columnas) {
                   $objPHPExcel->getActiveSheet()->getColumnDimension($columnas)->setWidth(16);
                } 

            $objPHPExcel->getActiveSheet()->getStyle('A7:Q'.$i.'')->getAlignment()->setWrapText(true);
            

            $objPHPExcel->createSheet();

            // Establecer la hoja activa, para que cuando se abra el documento se muestre primero.
            $objPHPExcel->setActiveSheetIndex(0);

            // Se modifican los encabezados del HTTP para indicar que se envia un archivo de Excel.
            header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
            header('Content-Disposition: attachment;filename="intereses y multas extemporaneos.xlsx"');
            header('Cache-Control: max-age=0');
            $objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel2007');
            $objWriter->save('php://output');
            exit;
   }


}
