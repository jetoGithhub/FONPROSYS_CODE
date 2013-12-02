<? if ( ! defined('BASEPATH')) exit('No se permite acceso directo al script');
/*************************************************************************************************
 *Fecha:08-02-2013,                                                                              *
 *Empresa:LCT tecnologias,                                                                       *
 *Creador: Ing. Jefferson Lara,                                                                  *                               *
 *Descripcion: Librerias para el manejo de metodos de complemento,                               *
 *Version:1.0                                                                                    *         
 *************************************************************************************************/
require_once dirname(__FILE__) . '/html2pdf/html2pdf.php';
require_once dirname(__FILE__) . '/generar_excel/PHPExcel.php';

class Funciones_complemento extends HTML2PDF {
 protected $usoci;
 protected $option_mes;
 protected $option_anio;
 protected $option_tri;

 function __construct(){
       
        $this->usoci =& get_instance();
//      $this->usoci->load->config('funciones_complemento');
        
   }
    
   
   function generar_pdf_html($vista,$datos,$nombre_archivo,$accion)
   {
       // init HTML2PDF
        $html2pdf = new HTML2PDF('P', 'Legal', 'fr', true, 'UTF-8', array(5, 5, 5, 5));
        
        // convert
        $html2pdf->writeHTML($this->usoci->load->view($vista,$datos,true), isset($_GET['vuehtml']));

        // send the PDF
        $html2pdf->Output($nombre_archivo,$accion);
       
   }
   
   function devuelve_meses_text($mes,$digitos=2){
       if($digitos==2):
            $meses=array("01"=>'Enero',"02"=>'Febrero',"03"=>'Marzo',"04"=>'Abril',"05"=>'Mayo',"06"=>'Junio',"07"=>'Julio',"08"=>'Agosto',"09"=>'Septiembre',"10"=>'Octubre',"11"=>'Noviembre',"12"=>'Diciembre');
       else:
           $meses=array("1"=>'Enero',"2"=>'Febrero',"3"=>'Marzo',"4"=>'Abril',"5"=>'Mayo',"6"=>'Junio',"7"=>'Julio',"8"=>'Agosto',"9"=>'Septiembre',"10"=>'Octubre',"11"=>'Noviembre',"12"=>'Diciembre'); 
       endif;
       return $meses[$mes];
   }
   function devuelve_trimestre_text($trimestre,$digitos=2){
       if($digitos==2):
            $trimestres=array("01"=>'1er trimestre',"02"=>'2do trimestre',"03"=>'3er trimestre',"04"=>'4to trimestre');
       else:
             $trimestres=array("1"=>'1er trimestre',"2"=>'2do trimestre',"3"=>'3er trimestre',"4"=>'4to trimestre');
  
       endif;
       return $trimestres[$trimestre];
   }
   function devuelve_tipegrav_contribu($id){
       
       $this->usoci->load->model('modelo_usuario');
       
       $tipo=  $this->usoci->modelo_usuario->devuelve_tipo_tipegrav_contribuyente($id);
       
       return $tipo;
   }
   
   function devuelve_cifras_unidades_mil($cifra){
       if(!empty($cifra))
       {
//            $monto=round($cifra,2);
            $partes=explode('.',$cifra);
            $enteros=$partes[0];
            if(count($partes)>1):
                $decimales=$partes[1];
            else:
                $decimales='00';
            endif;
            $enteros_rev=strrev($enteros);
            $cont=1;
            $sub_total='';
            for($i=0;$i<strlen($enteros_rev);$i++){


                    if((($cont+3)%3)==0){

                            $sub_total.=$enteros_rev[$i].'.';
                    }else{
                            $sub_total.=$enteros_rev[$i];
                    }
                    $cont++;


            }

                      
            $cifra_total=strrev(trim($sub_total,'.')).','.$decimales;

            return $cifra_total;
       }
       
   }






   //funcion para generar excel con varias hojas
   function generar_excel($result1){
            
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


   function envio_correo($nombre_remitente,$asunto,$cuerpoCorreoHTML,$cuerpoTEXT,$remitente,$destinatario){
         
//         $config['protocol']=$this->usoci->config->item('protocol');    
//         $config['smtp_host']=$this->usoci->config->item('smtp_hos');    
//         $config['smtp_port']=$this->usoci->config->item('smtp_port');    
//         $config['smtp_timeout']=$this->usoci->config->item('smtp_timeout'); 
//         $config['smtp_user']=$this->usoci->config->item('smtp_user');    
//         $config['smtp_pass']=$this->usoci->config->item('smtp_pass');    
//         $config['charset']=$this->usoci->config->item('charset'); 
//         $config['newline']=$this->usoci->config->item('newline'); 
//         $config['mailtype']=$this->usoci->config->item('mailtype'); 
        $config['protocol']    = 'smtp'; 
        $config['smtp_host']    = 'ssl://smtp.gmail.com'; 
        $config['smtp_port']    = '465'; 
        $config['smtp_timeout'] = '5'; 
        $config['smtp_user']    = 'fonprocine@gmail.com'; 
        $config['smtp_pass']    = 'fonprocine.123'; 
        $config['charset']    = 'utf-8'; 
        $config['newline']    = "\r\n"; 
        $config['mailtype'] = 'html'; // or html 
//        $config['validation'] = TRUE; // bool whether to validate email or not   
//       
        $this->usoci->email->clear();
        $this->usoci ->email->initialize($config); 
 
        
        //ENVIO Y EVALUACION DE CORREO
        $this->usoci ->email->from($remitente,$nombre_remitente); 
        $this->usoci ->email->to($destinatario);
        $this->usoci ->email->subject($asunto); 
        $this->usoci ->email->message($cuerpoCorreoHTML);
        $this->usoci ->email->set_alt_message($cuerpoTEXT);    
        $envio=$this->usoci->email->send();
         
        try{
            if( $envio=== false) :
                return false;
            throw new Exception("Error al Enviar en correorrr !".$envio);
 
            else:
                return true;
            throw new Exception("exito al Enviar en correo !");
            endif;

            }
            catch (Exception $e){
                //$response['mensaje'] = $e->getMessage();
                //print(json_encode($response));
                
             }
       
       
   }
   
   
   


   function select_meses($anio){
       $mes_actual=date('n');
       $anio_actual=date('Y',time());
//       $anio=2013;
        
       $meses= array('Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre');
       
       $mes_numero=1;
       $index=0;
       $index2=0;
       
       if($anio==$anio_actual):
       
                 while($index<($mes_actual-1)){
                     
                     if($index2==0):
                       $this->option_mes.="<option value=''>Seleccione</option> \n";   
                         $index2++; 
                     else:
                     
                            if($mes_numero<10):

                                $mesn='0'.$mes_numero;
                            else:
                                $mesn=$mes_numero;

                            endif;       
                            $this->option_mes.="<option value=".$mesn.">".$meses[$index]."</option> \n";                     

                               $mes_numero++;
                               $index++;
                    endif;
                    
                 }
                 
         else:
                     
                  while($index<12){

                 if($index2==0):
                   $this->option_mes.="<option value=''>Seleccione</option> \n";   
                     $index2++; 
                 else:

                        if($mes_numero<10):

                            $mesn='0'.$mes_numero;
                        else:
                            $mesn=$mes_numero;

                        endif;       
                        $this->option_mes.="<option value=".$mesn.">".$meses[$index]."</option> \n";                     

                           $mes_numero++;
                           $index++;
                endif;

             }
                 
         endif;
                 
                if(!empty($this->option_mes)):      

                    return $this->option_mes;     
               else:

                   return FALSE;

               endif;  
   }
   
   function select_anio($periodo,$id=null){ 
   
       $anio_max=date('Y',time());
       if(is_null($id)){
           
       $anio_min=($anio_max-13);
       
       }else{
           
           if($id==1):
               
               $anio_min=2005;               
           else:
               
               $anio_min=2006;
           endif;
           
       }
       
       
       if($periodo==1):
           
           $i=0; 
                while($anio_min<$anio_max){
                    
                    if($i==0):
                       $this->option_anio.="<option value=''>Seleccione</option> \n";   
                        $i++; 
                     else: 
                         
                        $this->option_anio.="<option value=".$anio_min.">".$anio_min."</option> \n";
                        $anio_min++;
                       
                    endif;
                 }
           
           else:
               
                $i=0; 
                while($anio_min<=$anio_max){
                    
                    if($i==0):
                       $this->option_anio.="<option value=''>Seleccione</option> \n";   
                        $i++; 
                     else: 
                         
                        $this->option_anio.="<option value=".$anio_min.">".$anio_min."</option> \n";
                        $anio_min++;
                       
                    endif;
                 }
           
           
           
       endif;
      
                  if(!empty($this->option_anio)):      

                    return $this->option_anio;     
               else:

                   return FALSE;

               endif;  
       
   }
   
   function select_trimestre($anio,$id){
         $mes_actual=date('n');         
         $anio_actual=date('Y',time()); 
         $tri_actual=$this->define_periodo($id,$mes_actual);
         $trimestre=array('primer trimestre','segundo trimestre','tercer trimestre','cuarto trimestre');
         $tri_numero=1;
         $indextri=0;
         $it=0;
         
         if($anio==$anio_actual):
             
               while($indextri<($tri_actual-1)){
                     
                     if($it==0):
                       $this->option_tri.="<option value=''>Seleccione</option> \n";   
                        $it++; 
                     else: 
                     
                     $this->option_tri.="<option value=".'0'.$tri_numero.">".$trimestre[$indextri]."</option> \n";                     
                    
                        $tri_numero++;
                        $indextri++;
                    endif;
                 }
             
             else:
                 
                 while($indextri<4){
                     
                     if($it==0):
                       $this->option_tri.="<option value=''>Seleccione</option> \n";   
                        $it++; 
                     else: 
                     
                     $this->option_tri.="<option value=".'0'.$tri_numero.">".$trimestre[$indextri]."</option> \n";                     
                    
                        $tri_numero++;
                        $indextri++;
                    endif;
                 }
             
             
         endif;        
                 
                 
                if(!empty($this->option_tri)):      

                    return $this->option_tri;     
               else:

                   return FALSE;

               endif;  
       
   }
   
   function periodo_grvable_fechas($periodo,$tperiodo,$anio){
       $fecha_inicio=0;
       $fecha_fin=0;
     
       switch ($periodo){
            
             case'12':
                $a=$anio;
                
                if($tperiodo==12):
                    
                    $a=$anio+1;
                    $fecha_inicio="15-".$tperiodo."-".$anio;
                    $fecha_fin="15-01-".$a;
                
                    else:
                    
                    $fecha_inicio="15-".$tperiodo."-".$anio;
                    $fecha_fin="15-".($tperiodo+1)."-".$a;
                
                endif;
                
                
                
                 break;  
            
             case'4':
                if($tperiodo==1):
                    
                    $fecha_inicio="15-01-".$anio;
                    $fecha_fin="15-04-".$anio; 
                    
                endif;
                if($tperiodo==2):
                    
                    $fecha_inicio="15-04-".$anio;
                    $fecha_fin="15-07-".$anio; 
                    
                endif;
                if($tperiodo==3):
                    
                    $fecha_inicio="15-07-".$anio;
                    $fecha_fin="15-10-".$anio; 
                    
                endif;
                
                if($tperiodo==4):
                    
                    $fecha_inicio="15-10-".$anio;
                    $fecha_fin="15-01-".($anio+1);
                
                endif;
               
                
                break;
             case'1':
                    $fecha_inicio="15-01-".$tperiodo;
                    $fecha_fin="15-01-".($tperiodo+1);
                 
                 break;
        
        }  
        
        $data=array('fecha_ini'=>$fecha_inicio,'fecha_fin'=>$fecha_fin);
        
        return $data;
       
   }


   function calculaUnidad($monto, $periodo){
       
       
       
   }
   
   function alicuotaDirecta($idtcontribu){
       
//       $this->usoci->load->library('operaciones_bd');
        $datos=array(

                'tabla'=>'datos.alicimp',
                'where'=>array('tipocontid'=>$idtcontribu),
                'respuesta'=>array('alicuota','id')

            ); 
        
       $result=$this->usoci->operaciones_bd->seleciona_BD($datos);
      
      return $result;
       
   }
   
   function alicuotaIndirecta($idtcontribu,$anio){
       
       $this->usoci->load->model('mod_contribuyente/contribuyente_m');
       
       $anio_maximo=$this->usoci->contribuyente_m->anio_maximo_alicuota($idtcontribu);
       
       switch ($idtcontribu){
           case'1':
                if($anio>=$anio_maximo):

                    $where=array('tipocontid'=>$idtcontribu,'ano'=>$anio_maximo);

                else:

                    $where=array('tipocontid'=>$idtcontribu,'ano'=>$anio);

                endif;
           break;
           
           case'3':
               if($anio>=$anio_maximo):

                    $where=array('tipocontid'=>$idtcontribu,'ano'=>$anio_maximo);

                else:

                    $where=array('tipocontid'=>$idtcontribu,'ano'=>$anio);

                endif;
           break;
       }
          
       
      $datos=array(

                'tabla'=>'datos.alicimp',
                'where'=>$where,
                'respuesta'=>array('alicuota','id')

            ); 
        
       $result=$this->usoci->operaciones_bd->seleciona_BD($datos);
      
      return $result; 
       
       
   }
   
   function alicuotaTributaria($idtcontribu,$anio,$base){
//        echo " +++".$anio;
//       die;
      $alicuota=array();
      $data=$this->unidaTributariaDeclarada($anio,$base);
      $unida=round($data[0]);
      
//      echo $unida.'<br />'; 
//      die;
//      
      
     
      $datos=array(

                'tabla'=>'datos.alicimp',
                'where'=>array('tipocontid'=>$idtcontribu),
                'respuesta'=>array('liminf1','limsup1','alicuota1','liminf2','limsup2','alicuota2','liminf3','limsup3','alicuota3')

            );      
        
       $result=$this->usoci->operaciones_bd->seleciona_BD($datos);
       
      $resta_principal=$unida-($result['variable0']-1);
      $total=0;
      $resta2=0;
      $resta3=0;
//      echo $resta_principal; die;
      
      if($resta_principal>($result['variable1']-$result['variable0'])){
         
          $total_ut=round((($result['variable1']-$result['variable0']) * $result['variable2'])/100);
          
          $total=$total+($total_ut*$data[1]); 
          
          $resta2=$resta_principal-($result['variable1']-$result['variable0']);  
          
          $alicuota=$result['variable2'];
          
          
      }else{
          
          
          $total_ut=round(($resta_principal*$result['variable2'])/100);
          
          $total=$total+($total_ut*$data[1]); 
          
          $alicuota=$result['variable2'];
          
          
      }
      
      if($resta2>($result['variable4']-$result['variable3'])-1){
                    
          $total_ut=round((($result['variable4']-$result['variable3']) * $result['variable5'])/100);
          
          $total=$total+($total_ut*$data[1]);
          
          $resta3=$resta2-(($result['variable4']-$result['variable3'])-1);
          
          $alicuota=$result['variable5'];
          
      }elseif (($resta2<($result['variable4']-$result['variable3'])-1) && ($resta2>0)) {
       
           $total_ut=round(($resta2*$result['variable5'])/100);
          
           $total=$total+($total_ut*$data[1]);     
           
           $alicuota=$result['variable5'];
          
      }
      
      if($resta3>$result['variable6']){
          
          $total_ut=round(($resta3*$result['variable8'])/100);
          
           $total=$total+($total_ut*$data[1]); 
           
           $alicuota=$result['variable8'];
          
      }

   
       return array($total,$alicuota);
   }
   
   function unidaTributariaDeclarada($anio,$base){
       
       $datos=array(

                'tabla'=>'datos.undtrib',
                'where'=>array("cast(to_char(fecha,'yyyy') as integer)="=>$anio),
                'respuesta'=>array('valor','id')

            ); 
       $result=$this->usoci->operaciones_bd->seleciona_BD($datos);
       
       $utdeclarada=($base/$result['variable0']);
//       echo $utdeclarada." +++".$anio;
//       die;
       return array($utdeclarada,$result['variable0']);
       
   }
   
   function numero_depostido_bancario($total){
      
        $remplace=array('.',',');
        
        $tot=number_format($total,2);
        
        $totalVeri=str_replace($remplace,'',$tot); 
//                                die;

        $t=strlen($totalVeri);
        
            if($t<10):

                for($i=$t; $t<10;$i++){

                    $totalVeri='0'.$totalVeri;
                    $t=  strlen($totalVeri);
                }


            endif;
            
    return $totalVeri;
    
   }
   
   function numero_verificador($cadena){
       
//       $cadena='12345614122012000052512311';
       $par=0;
       $impar=0;
       
       for ($i = 0 ; $i < strlen($cadena) ; $i ++){ 

            if(($cadena[$i]%2)==0): 
                
                $par=($par+$cadena[$i]);
            
            else:
                
                $impar=($impar+$cadena[$i]);
                
            endif; 

        }
        
        $Mimpares=$impar*3;

//        return $par.'-----'.$impar.'-----'.$cadena.'-------'.strlen($cadena);

        $sumatoria=$par+$Mimpares;
        
        $residuo=$sumatoria%10;
        
        $numunico=10-$residuo;
        
        return $numunico;
        
       
   }
   
     function define_periodo($id_tipocont,$mes){
         
            $this->usoci->load->model('mod_gestioncontribuyente/lista_contribuyentes_general_m');
            $datos_detalle_periodo = $this->usoci->lista_contribuyentes_general_m->devuelve_detalle_periodo($id_tipocont);
//            print_r($datos_detalle_periodo);
            if($datos_detalle_periodo):
                $periodo=0;
                switch ($datos_detalle_periodo[0]['peano']){
                    case '1':
                        $periodo = '01';
                        return $periodo;
                        break;
                    case '4':
                        if($mes==01 || $mes==02 || $mes==03):
                            $periodo = '01';
                        elseif($mes==04 || $mes==05 || $mes==06):
                            $periodo = '02';
                        elseif($mes==07 || $mes==08 || $mes==09):
                            $periodo = '03';
                        elseif($mes==10 || $mes==11 || $mes==12):
                            $periodo = '04';
                        endif;
                        return  $periodo;
                        break;
                    case '12':
                        $periodo = $mes;
                        return  $periodo;
                        break;
                        
                }
            endif;
            
        }
        
        
        //calculos
        
        function calculos_finanzas($datos_p,$opc_tipo_multa,$inf_extemp)
	{
            

            //contar posiciones del arreglo de los periodos
            $limite=count($datos_p);
            
            $data=  array();
            
            for ($i=0; $i<$limite;$i++)
            {
                //capturar las fechas inicios de cada periodo, esta en la posicion 0
                $fecha_inicio=$datos_p['periodo'.$i]['fecha_inicio'];
                
                //capturar las fechas finales de cada periodo, esta en la posicion 1
                $fecha_fin=$datos_p['periodo'.$i]['fecha_fin'];
                
                $total_declara=$datos_p['periodo'.$i]['total_declara'];
                
                
                //calculos multas - llamado de la funcion correspondiente
                    $multas=  $this->calc_multas($total_declara,$opc_tipo_multa);
                
                
                //separar  dia-mes-año inicio y fin de cada una de las fechas
               $piezas_inicio= explode ('-',$fecha_inicio);
               //posiciones del arreglo fecha
               $anio_inicio=$piezas_inicio['0'];
               $mes_inicio=$piezas_inicio['1'];
               $dia_inicio=$piezas_inicio['2'];
               
               //echo $anio_inicio.$mes_inicio.$dia_inicio;
               
               $piezas_fin= explode ('-',$fecha_fin);
               $anio_fin=$piezas_fin['0'];
               $mes_fin=$piezas_fin['1'];
               $dia_fin=$piezas_fin['2'];
               
               if($anio_inicio==$anio_fin)
               {

                       $data['periodo'.$i]=  $this->calc_dia_interes_meses_anio_igual($dia_inicio, $dia_fin, $mes_inicio,$mes_fin,$anio_fin,$total_declara);
//                       print_r($data);
//$calc_dias=  $this->calc_dia_interes_meses_anio_igual($dia_inicio, $dia_fin, $mes_inicio,$mes_fin,$anio_fin,$total_declara);
               }
               
               if($anio_inicio!=$anio_fin)
               {
                   $data['periodo'.$i]=  $this->calc_dia_interes_meses_anio_diferente($dia_inicio,$mes_inicio,$anio_inicio,$dia_fin,$mes_fin,$anio_fin,$total_declara);
                   
               }
               
               //incluir en el arreglo data las multas
               $data['periodo'.$i]['multas']=$multas;
               
               
               //captura el id por cada periodo
               $data['periodo'.$i]['id_declara']=$datos_p['periodo'.$i]['id'];;
               
            }//cierra for
            
            $this->usoci->load->model('calculos_m'); 

            $tipo_multa=  $this->usoci->calculos_m->devuelve_id_multa($opc_tipo_multa);
            
            
            $imprimir=$this->usoci->calculos_m->inserta_detalle_interes($data, $datos_p,$inf_extemp,$tipo_multa,$opc_tipo_multa);
//            
//            print_r($imprimir);
//            print_r($data['periodo1']);
            
        return $imprimir;
            
        } 
        
        //INICIO DE LA FUNCION calc_dia_interes_meses_anio_igual en el caso de que el año inicio sea igual al año final
        
        /*funcion para capturar los dias y los intereses de acuerdo a la tasa calculada por el interes
        del bcv, de los meses intermedios y los del mes inicio*/
        function calc_dia_interes_meses_anio_igual($dia_inicio, $dia_fin, $mes_inicio,$mes_final,$anio,$total_declara)
        {
            //carga modelo que trae el interes correspondiente al mes inicial
            $this->usoci->load->model('calculos_m');
            //carga la funcion en el modelo que devuelve la tasa, parametro anio y mes inicial
            $tasa_bcv_i=  $this->usoci->calculos_m->devuelve_tasa($anio,$mes_inicio);
            
            if($mes_inicio==$mes_final)
            {
                $tasa_mes[$mes_inicio.'-'.$anio]=($tasa_bcv_i['tasa']*1.20)/360;
                $tas_mes_porcentaje[$mes_inicio.'-'.$anio]=$tasa_bcv_i['tasa'];    
                //print_r($tasa_mes);

                $dias_mes_igual=$dia_fin-$dia_inicio;

                $arreglo_dias[$mes_inicio.'-'.$anio]=$dias_mes_igual;

                $arreglo_anio[$mes_inicio.'-'.$anio]=$anio;

                $arreglo_interes[$mes_inicio.'-'.$anio]=$dias_mes_igual*$total_declara*$tasa_mes[$mes_inicio.'-'.$anio];

                $data=  array('dias'=>$arreglo_dias,'intereses'=>$arreglo_interes, 'tasa'=>$tasa_mes, 'anios'=>$arreglo_anio,'capital'=>$total_declara,'tasa_porcentaje'=>$tas_mes_porcentaje);
            } else
            {
                /*
                 * se empieza a construir el arreglo de los interese con la variable tasa_mes
                 * con la variable, en este caso $mes_inicio - tasa que corresponde a ese mes
                 * en la formula incluye la variable $tasa_bcv_i['tasa'] que trae la tasa del bcv
                 * del mes inicial, el 1.20 y el 360 son datos fijos de la formula
                 */
                $tasa_mes[$mes_inicio.'-'.$anio]=($tasa_bcv_i['tasa']*1.20)/360;
                $tas_mes_porcentaje[$mes_inicio.'-'.$anio]=$tasa_bcv_i['tasa'];
                //calculo de dia de mes inicio -aplicando mktime
                $calc_dias=date("d",mktime(0,0,0,$mes_inicio+1,0,$anio));

                /*dias mes incio es igual a la resta de los dias del mes inicio menos el dia de inicio
                 * para determinar los dias del mes inicio, se debe aplicar la resta entre el dia del mes
                 * con el dia tope, esos seran los dias necesarios para el calculo de interes del mes inicio
                 */
                $dia_mes_inicio=$calc_dias-$dia_inicio;

                //construir el arreglo_dias se agrega dias mes inicio
                $arreglo_dias[$mes_inicio.'-'.$anio]=$dia_mes_inicio;

                /*---------------------PRUEBA-----------------*/

                $arreglo_anio[$mes_inicio.'-'.$anio]=$anio;
    //            print_r($arreglo_anio);
                /*----------------FIN PRUEBA-----------------*/

                /*formula general para el calculo de los interes a pagar por el contribuyente
                 * el arreglo se asigna a la variable $arreglo_interes del mes inicio es igual
                 * a los dias del mes inicio por el total de la declaracion por la tasa mes del mes inicio
                 */
                $arreglo_interes[$mes_inicio.'-'.$anio]=$dia_mes_inicio*$total_declara*$tasa_mes[$mes_inicio.'-'.$anio];

                //for para los dias y los intereses de meses intermedios
                //inicializa en mes inicio mas 1, porque debe empezar a partir del meses siguiente al mes inicio
                $inicializador=$mes_inicio+1;
                //menor que el mes final, non debe ser igual porque los dias del mes final son los que pasan en la variable
    //            $acum_interes_mi=0;
                for ($i=$inicializador; $i<$mes_final; $i++)
                {

                    /*condicion para concatenar un 0 a los meses que sean menor a 10
                     * debido a que en la tabla se guardan del 1 al 9, sin incluir un 0 previo
                     */
                    if($i<10):
                        $mesn='0'.$i;
                    else:
                        /*si es mayor convertir esa caddena en un entero para que lo muestre 
                        exactamente como esta en la tabla, ademas de que en la tabla mes es varying
                         * la variable i del for se esta reemplazando por la variable $mesn */
                        $mesn=(string)$i;
                    endif;

                    /*
                     * calculo interes de los meses intermedios
                     * en el segundo parametro, correspondiente al mes, no pasa $i, sino $mesn
                     * por la condicion planteada anteriormente
                     */

                    //carga funcion en el modelo que devuelvve la tasa
                    $tasa_bcv=  $this->usoci->calculos_m->devuelve_tasa($anio,$mesn);
                    //calculo de la tasa por cada mes
                    $tasa_mes[$mesn.'-'.$anio]=($tasa_bcv['tasa']*1.20)/360;
                    $tas_mes_porcentaje[$mesn.'-'.$anio]=$tasa_bcv['tasa'];
                    /*construir arreglo_dias se agrega dias mes intermedio
                     * en este caso se puede segyir pasando $i y no es necesario
                     * reemplazarla por $mesn
                     */
                    $arreglo_dias[$mesn.'-'.$anio]=date("d",mktime(0,0,0,$i+1,0,$anio));

                    /*-------------PRUEBA---------------------*/

                    $arreglo_anio[$mesn.'-'.$anio]=$anio;

                    /*------------FIN PRUEBA------------------*/

    //                $arreglo_dias_anio[$anio]= $arreglo_dias[$mesn];

                    //construir arreglo intereses - reemplaza $i por $mesn
                    $arreglo_interes[$mesn.'-'.$anio]=$arreglo_dias[$mesn.'-'.$anio]*$total_declara*$tasa_mes[$mesn.'-'.$anio];

                }


                /*carga funcion en el modelo
                 * con segundo parametros $mes_final
                 */
                $tasa_bcv_f=  $this->usoci->calculos_m->devuelve_tasa($anio,$mes_final);

                /*calculo tasa mes final, agregandola al arreglo tasa_mes que ya trae
                la tasa del mes inicial y la tasa de los meses intermedios
                */
                $tasa_mes[$mes_final.'-'.$anio]=($tasa_bcv_f['tasa']*1.20)/360;
                $tas_mes_porcentaje[$mes_final.'-'.$anio]=$tasa_bcv_f['tasa'];

                //arreglo_dias se agrega dias mes final
                $arreglo_dias[$mes_final.'-'.$anio]=$dia_fin;

                /*---------------------PRUEBA-----------------*/

                $arreglo_anio[$mes_final.'-'.$anio]=$anio;
    //            print_r($arreglo_anio);
                /*----------------FIN PRUEBA-----------------*/

                //agregar al arreglo intereses el interes del mes final
                $arreglo_interes[$mes_final.'-'.$anio]=$dia_fin*$total_declara*$tasa_mes[$mes_final.'-'.$anio];

                /*variable que contiene todos los arreglos a retornar, que son dias de los meses,
                intereses de los meses tasa por mes*/

                $data=  array('dias'=>$arreglo_dias,'intereses'=>$arreglo_interes, 'tasa'=>$tasa_mes, 'anios'=>$arreglo_anio,'capital'=>$total_declara,'tasa_porcentaje'=>$tas_mes_porcentaje);
            }
            return $data;
        }
        
//FIN DE LA FUNCION calc_dia_interes_meses_anio_igual
        
        
         //Funcion para el calculo de los dias, intereses del pago en un mismo mes para años iguales
        
        function calc_dia_interes_mes_igual_anio_igual($dia_inicio,$dia_fin,$mes_inicio,$anio,$total_declara)
        {
            $this->usoci->load->model('calculos_m');
            $tasa_bcv_i=  $this->usoci->calculos_m->devuelve_tasa($anio,$mes_inicio);
//            echo $mes_inicio;

            $tasa_mes[$mes_inicio.'-'.$anio]=($tasa_bcv_i['tasa']*1.20)/360;
            
            //print_r($tasa_mes);
            
            $dias_mes_igual=$dia_fin-$dia_inicio;
          
            $arreglo_dias[$mes_inicio.'-'.$anio]=$dias_mes_igual;

            $arreglo_anio[$mes_inicio.'-'.$anio]=$anio;

            $arreglo_interes[$mes_inicio.'-'.$anio]=$dias_mes_igual*$total_declara*$tasa_mes[$mes_inicio.'-'.$anio];

            $data=  array('dias'=>$arreglo_dias,'intereses'=>$arreglo_interes, 'tasa'=>$tasa_mes, 'anios'=>$arreglo_anio);
            
            return $data;
        }
        
//FIN DE LA FUNCION calc_dia_interes_mes_igual_anio_igual
        
        
        /*
         * Funcion que calcula los dias, tasas, intereses del año inicio cuando
         * fecha inicia y fecha fin son distintas
         */
        
        function calc_inicio_anio_intermedio($dia_inicio,$mes_inicio,$anio_inicio,$total_declara)
        {

            $this->usoci->load->model('calculos_m');
            $tasa_bcv_i=  $this->usoci->calculos_m->devuelve_tasa($anio_inicio,$mes_inicio);
            
  
            $tasa_mes[$mes_inicio.'-'.$anio_inicio]=($tasa_bcv_i['tasa']*1.20)/360;
            $tas_mes_porcentaje[$mes_inicio.'-'.$anio_inicio]=$tasa_bcv_i['tasa'];
            $calc_dias=date("d",mktime(0,0,0,$mes_inicio+1,0,$anio_inicio));
            

            $dia_mes_inicio=$calc_dias-$dia_inicio;
            
            $arreglo_dias[$mes_inicio.'-'.$anio_inicio]=$dia_mes_inicio;

            $arreglo_anio[$mes_inicio.'-'.$anio_inicio]=$anio_inicio;

            $arreglo_interes[$mes_inicio.'-'.$anio_inicio]=$dia_mes_inicio*$total_declara*$tasa_mes[$mes_inicio.'-'.$anio_inicio];

            $inicializador=$mes_inicio+1;

            for ($i=$inicializador; $i<=12; $i++)
            {

                if($i<10):
                    $mesn='0'.$i;
                else:

                    $mesn=(string)$i;
                endif;
  
                $tasa_bcv=  $this->usoci->calculos_m->devuelve_tasa($anio_inicio,$mesn);

                $tasa_mes[$mesn.'-'.$anio_inicio]=($tasa_bcv['tasa']*1.20)/360;
                $tas_mes_porcentaje[$mesn.'-'.$anio_inicio]=$tasa_bcv['tasa'];
                $arreglo_dias[$mesn.'-'.$anio_inicio]=date("d",mktime(0,0,0,$i+1,0,$anio_inicio));

                
                $arreglo_anio[$mesn.'-'.$anio_inicio]=$anio_inicio;
                

                $arreglo_interes[$mesn.'-'.$anio_inicio]=$arreglo_dias[$mesn.'-'.$anio_inicio]*$total_declara*$tasa_mes[$mesn.'-'.$anio_inicio];

            }
            
            $data=  array('dias'=>$arreglo_dias,'intereses'=>$arreglo_interes, 'tasa'=>$tasa_mes,'anios'=>$arreglo_anio,'tasa_porcentaje'=>$tas_mes_porcentaje);
             return $data;
        }//Fin de la funcion calculo año inicio

        /*
         * Funcion que calcula los dias, tasas, intereses del año final cuando
         * fecha inicia y fecha fin son distintas
         */
        
        function calc_final_anio_intermedio($dia_fin,$mes_fin,$anio_fin,$total_declara)
        {

            $this->usoci->load->model('calculos_m');
            
            for ($i=1; $i<$mes_fin; $i++)
            {

                if($i<10):
                    $mesn='0'.$i;
                else:

                    $mesn=(string)$i;
                endif;
  
                $tasa_bcv=  $this->usoci->calculos_m->devuelve_tasa($anio_fin,$mesn);

                $tasa_mes[$mesn.'-'.$anio_fin]=($tasa_bcv['tasa']*1.20)/360;
                $tas_mes_porcentaje[$mesn.'-'.$anio_fin]=$tasa_bcv['tasa'];
                $arreglo_dias[$mesn.'-'.$anio_fin]=date("d",mktime(0,0,0,$i+1,0,$anio_fin));

                
                $arreglo_anio[$mesn.'-'.$anio_fin]=$anio_fin;
                

                $arreglo_interes[$mesn.'-'.$anio_fin]=$arreglo_dias[$mesn.'-'.$anio_fin]*$total_declara*$tasa_mes[$mesn.'-'.$anio_fin];

            }
            
            //los dias en el que dejó de declarar en el ultimo mes es el que trae en la variable de la fecha - $dia_fin 
            $tasa_bcv_f=  $this->usoci->calculos_m->devuelve_tasa($anio_fin,$mes_fin);
            

            $tasa_mes[$mes_fin.'-'.$anio_fin]=($tasa_bcv_f['tasa']*1.20)/360;
            $tas_mes_porcentaje[$mes_fin.'-'.$anio_fin]=$tasa_bcv_f['tasa'];
            $arreglo_dias[$mes_fin.'-'.$anio_fin]=$dia_fin;

            
            $arreglo_anio[$mes_fin.'-'.$anio_fin]=$anio_fin;

            $arreglo_interes[$mes_fin.'-'.$anio_fin]=$dia_fin*$total_declara*$tasa_mes[$mes_fin.'-'.$anio_fin];
            
            
            $data=  array('dias'=>$arreglo_dias,'intereses'=>$arreglo_interes, 'tasa'=>$tasa_mes,'anios'=>$arreglo_anio,'tasa_porcentaje'=>$tas_mes_porcentaje);
             return $data;
        }//Fin de la funcion calculo año final
        
        
        
        //FUNCION PARA EL CALCULO DE LOS AÑOS DIFERENTES
        
        function calc_dia_interes_meses_anio_diferente($dia_inicio,$mes_inicio,$anio_inicio,$dia_fin,$mes_fin,$anio_fin,$total_declara)  
        {
            
            $data=$this->calc_inicio_anio_intermedio($dia_inicio,$mes_inicio,$anio_inicio,$total_declara);
            
            $this->usoci->load->model('calculos_m');
            /*
             * DIAS DE LOS MESES DE LOS AÑOS INTERMEDIOS
             */
            //inicializa el ciclo en el año inicial mas 1
            $inicializador=$anio_inicio+1;
            
            for ($i=$inicializador; $i<$anio_fin; $i++)
            {
//                print_r($arreglo_anio);
                
                for($j=1; $j<=12; $j++)
                {
                    if($j<10):
                        $mesn='0'.$j;
                    else:
                        $mesn=(string)$j;
                    endif;
                    
                    //carga funcion en el modelo que devuelvve la tasa
                    $tasa_bcv=  $this->usoci->calculos_m->devuelve_tasa($i,$mesn);
                     //calculo de la tasa por cada mes
                    $data['tasa'][$mesn.'-'.$i]=(($tasa_bcv['tasa']*1.20)/360);
                    $data['tasa_porcentaje'][$mesn.'-'.$i]=$tasa_bcv['tasa'];
                    /*dias de cada uno de los mesese del año que este pasando
                    se van agregando al arreglo data las demas variables, dias, tasas, interes
                     * data es el arreglko que devuelve la funcion que se esta llamando en esta
                     */
                    $data['dias'][$mesn.'-'.$i]=date("d",mktime(0,0,0,$j+1,0,$i));
                    
                    $data['intereses'][$mesn.'-'.$i]=$data['dias'][$mesn.'-'.$i]*$total_declara*$data['tasa'][$mesn.'-'.$i];
                    
                    $data['anios'][$mesn.'-'.$i]=$i;

                }
//                
             }
             $data_fin=$this->calc_final_anio_intermedio($dia_fin,$mes_fin,$anio_fin,$total_declara);
//             $cont_data_f=count($data_fin);
//             
//             for($x=0; $x<=$cont_data_f;$x++)
//             {
                 for($j=1; $j<=$mes_fin; $j++)
                 {
                    if($j<10):
                        $mesn='0'.$j;
                    else:
                        $mesn=(string)$j;
                    endif;
                    
                    $data['tasa'][$mesn.'-'.$anio_fin]=$data_fin['tasa'][$mesn.'-'.$anio_fin];
                    $data['tasa_porcentaje'][$mesn.'-'.$anio_fin]=$data_fin['tasa_porcentaje'][$mesn.'-'.$anio_fin];
                    $data['dias'][$mesn.'-'.$anio_fin]=$data_fin['dias'][$mesn.'-'.$anio_fin];
                    $data['intereses'][$mesn.'-'.$anio_fin]=$data_fin['intereses'][$mesn.'-'.$anio_fin];
                    $data['anios'][$mesn.'-'.$anio_fin]=$data_fin['anios'][$mesn.'-'.$anio_fin];
                }
                $data['capital']=$total_declara;
               
//             }
             
             return $data;
         }/*
             * FIN - DIAS DE LOS MESES DE LOS AÑOS INTERMEDIOS
             */
        
       
        //funcion para el calculo de las MULTAS
        function calc_multas($total_declara,$opc_tipo_multa)  
        {
            //condiciones para aplicar multa de acuerdo sea el caso
                
                if($opc_tipo_multa==1)
                {
                    $multas=$total_declara*1/100;

                }elseif($opc_tipo_multa==2)
                {
                    $multas=$total_declara*10/100;
                    
                }elseif($opc_tipo_multa==3)
                {
                    //obtenemos el valor de la undad tributaria actual
                    $this->usoci->load->model('calculos_m');
                    $ut=  $this->usoci->calculos_m->unidad_tributaria_actual();
                    $multas=(($total_declara*112.5)/$ut)*$ut;
                }
                return $multas;
        }
   
}
