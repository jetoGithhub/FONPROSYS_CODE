<?php

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 * Description of reportes_excel
 *
 * @author jetox
 */
require_once dirname(__FILE__) . '/generar_excel/PHPExcel.php';
class Reportes_excel {
    protected $usoci;
    protected $cont_cabecera;
    protected $color_cabecera='#800000';
    protected $colortext_cabecera='#fff';
    protected $tamanio_text='10px';
    protected $tipo_text='Arial';
            
    function __construct()
    {
       
        $this->usoci =& get_instance();
        
    }
    function genera_excel_basico($titulo,$text_encabezado,$cabecera,$cuerpo=array(),$forma=array())
    {
     
        $estilo1=$this->estilo_encabezado();   
        $estilo2=$this->estilo_cabecera();
     
        $objecto_excel= new PHPExcel();   
        $objecto_excel->getActiveSheet()->getHeaderFooter()->setOddHeader('&L&G');           
//        $objecto_excel->getActiveSheet()->setTitle('RISE');

        // Establecer propiedades
        $objecto_excel->getProperties()
         ->setCreator("Fonprocine")
         ->setLastModifiedBy("Fonprocine")
         ->setTitle($titulo)
         ->setSubject($titulo)
         ->setKeywords("Excel Office 2007 openxml php")
         ->setCategory($titulo);
       
            //alto filas del encabezado        
            for($i=1;$i<=count($text_encabezado);$i++)
            {
                 $objecto_excel->getActiveSheet()->getRowDimension($i)->setRowHeight(15);
            }
       
            //armamos la  informacion de la cabecera
            $count=2; 
            foreach ($text_encabezado as $key=>$value)
            {              
                $objecto_excel->setActiveSheetIndex(0)->setCellValue('A'.$count,$value);
                //unimos las celdas desde la columna A hasta la F
                if($key==0):
                    $objecto_excel->getActiveSheet()->mergeCells('A'.($key+1).':F'.($key+1));
                endif;
                $objecto_excel->getActiveSheet()->mergeCells('A'.$count.':F'.$count);
                $objecto_excel->getActiveSheet()->getStyle('A'.$count)->applyFromArray($estilo1);
                $count ++;
            }
       
            // aramamos Encabezado de los datos     
            foreach ($cabecera as $key=>$value)
            {

              $objecto_excel->setActiveSheetIndex(0)->setCellValue($key.(count($text_encabezado)+3),$value);

              $objecto_excel->getActiveSheet()->getStyle($key.(count($text_encabezado)+3))->applyFromArray($estilo2);

    //          $objecto_excel->getActiveSheet()->getColumnDimension($key)->setAutoSize(true);
              $objecto_excel->getActiveSheet()->getColumnDimension($key)->setWidth(15);
            }
            // colocamos el ancho de la fila de cabecera
             $objecto_excel->getActiveSheet()->getRowDimension((count($text_encabezado)+3))->setRowHeight(30);
             $objecto_excel->setActiveSheetIndex(0);

            //llenamos el cuerpo con los datos segun la busqueda
             $columnas = array('A','B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q','R','S','T','U','V','w','x','Y','Z');
             $fila=(count($text_encabezado)+4);
             $pos_colum=0;
             for($j=0;$j<count($cuerpo);$j++){
                for($k=0;$k<count($cuerpo[$j]);$k++){
                    array_values($cuerpo[$j]);
                    $objecto_excel->setActiveSheetIndex(0)->setCellValue($columnas[$k].$fila,$cuerpo[$j][$k]);
                    
                    if($k==(count($cabecera)-1)):
                        break;
                    endif;
                }
                $objecto_excel->getActiveSheet()->getRowDimension($fila)->setRowHeight(15);
             
                $fila ++; 
             }
             
                 
             
             
             
            // Se modifican los encabezados del HTTP para indicar que se envia un archivo de Excel.
            header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
            header('Content-Disposition: attachment;filename="reportes de resolucion de multa por extemporaneidad.xlsx"');
            header('Cache-Control: max-age=0');
            $objWriter = PHPExcel_IOFactory::createWriter($objecto_excel, 'Excel2007');
            $objWriter->save('php://output');
        exit;  
    }
    
    private function estilo_encabezado()
    {
        
         $estilo_encabezado=array(
                'font' => array(
                    'bold' => true,
                    'size'	  => $this->tamanio_text,
                    'name'	  => $this->tipo_text,
                    )
          );
         
         return $estilo_encabezado;
        
    }
    private function estilo_cabecera()
    {
        $estilo_cabecera=array(
                'font' => array(
                    'bold' => TRUE,
                    'color'=>array('rgb'=>'FFFFFF'),
                    'size'	  => '9',
                    'name'	  => 'Arial',
                    
                    ),
                
                //borde delgado
                'borders' => array(
                    'allborders' => array(
                        'style' => PHPExcel_Style_Border::BORDER_HAIR,
                       ),
                    ),
                'alignment' => array(
                    'horizontal' => PHPExcel_Style_Alignment::HORIZONTAL_CENTER,
                    'vertical' => PHPExcel_Style_Alignment::VERTICAL_JUSTIFY,
                    ),
                'fill' => array(
                    'type' => PHPExcel_Style_Fill::FILL_GRADIENT_LINEAR,
                    'rotation' => 90,
                    'startcolor' => array(
                        'argb' => '800000',
                        ),
                    'endcolor' => array(
                        'argb' => '800000',
                        ),
                    ),
                   
                );
        return $estilo_cabecera;
    }
    
    function genera_excel_recaudacion($array,$cabecera,$anio,$recau_poranio)
    {
       $estilo1=$this->estilo_encabezado();   
        $estilo2=$this->estilo_cabecera();
     
        $objecto_excel= new PHPExcel();   
        $objecto_excel->getActiveSheet()->getHeaderFooter()->setOddHeader('&L&G');           
//        $objecto_excel->getActiveSheet()->setTitle('RISE');

        // Establecer propiedades
        $objecto_excel->getProperties()
         ->setCreator("Fonprocine")
         ->setLastModifiedBy("Fonprocine")
         ->setTitle('Recaudacion en el año')
         ->setSubject('Recaudacion en el año')
         ->setKeywords("Excel Office 2007 openxml php")
         ->setCategory('Recaudacion en el año'); 
       // datos del encabezado titulo
        $objecto_excel->setActiveSheetIndex(0)->setCellValue('A2','Gerencia de Recaudación Tributaria');
        $objecto_excel->setActiveSheetIndex(0)->setCellValue('A3','Fondo de Promoción y Financiamiento del Cine (FONPROCINE)');
        $objecto_excel->setActiveSheetIndex(0)->setCellValue('A4','Centro Nacional Autónomo de Cinematografía (CNAC)');
        $objecto_excel->setActiveSheetIndex(0)->setCellValue('A5','Recaudación');
        
        //unimos las celdas necesarias 
         $objecto_excel->getActiveSheet()->mergeCells('A2'.':F2');
         $objecto_excel->getActiveSheet()->mergeCells('A3'.':F3');
         $objecto_excel->getActiveSheet()->mergeCells('A4'.':F4');
         $objecto_excel->getActiveSheet()->mergeCells('A5'.':F5');
            
            $objecto_excel->getActiveSheet()->mergeCells('A2:F2');
            $objecto_excel->getActiveSheet()->mergeCells('A3:F3');
            $objecto_excel->getActiveSheet()->mergeCells('A4:F4');
            $objecto_excel->getActiveSheet()->mergeCells('A5:F5');
            
        // le aplicamos el estilo a las celda A
         $objecto_excel->getActiveSheet()->getStyle('A2')->applyFromArray($estilo1);
         $objecto_excel->getActiveSheet()->getStyle('A3')->applyFromArray($estilo1);
         $objecto_excel->getActiveSheet()->getStyle('A4')->applyFromArray($estilo1);
         $objecto_excel->getActiveSheet()->getStyle('A5')->applyFromArray($estilo1);
         // aramamos Encabezado de los datos     
            foreach ($cabecera as $key=>$value)
            {

              $objecto_excel->setActiveSheetIndex(0)->setCellValue($key.'7',$value);

              $objecto_excel->getActiveSheet()->getStyle($key.'7')->applyFromArray($estilo2);

//              $objecto_excel->getActiveSheet()->getColumnDimension($key)->setAutoSize(true);
//              $objecto_excel->getActiveSheet()->getColumnDimension($key)->setWidth(10);
            }
            $objecto_excel->getActiveSheet()->getColumnDimension('A')->setWidth(19);
            $objecto_excel->getActiveSheet()->getColumnDimension('B')->setWidth(15);
            $objecto_excel->getActiveSheet()->getColumnDimension('C')->setWidth(15);
            $objecto_excel->getActiveSheet()->getColumnDimension('D')->setWidth(15);
            $objecto_excel->getActiveSheet()->getColumnDimension('E')->setWidth(15);
            $objecto_excel->getActiveSheet()->getColumnDimension('F')->setWidth(15);
            $objecto_excel->getActiveSheet()->getColumnDimension('G')->setWidth(12);
            $objecto_excel->getActiveSheet()->getColumnDimension('H')->setWidth(15);
            $objecto_excel->getActiveSheet()->getColumnDimension('I')->setWidth(10);
            $objecto_excel->getActiveSheet()->getColumnDimension('J')->setWidth(10);
            $objecto_excel->getActiveSheet()->getColumnDimension('K')->setWidth(15);
            $objecto_excel->getActiveSheet()->getColumnDimension('L')->setWidth(10);
            $objecto_excel->getActiveSheet()->getColumnDimension('M')->setWidth(8);
            $objecto_excel->getActiveSheet()->getColumnDimension('N')->setWidth(10);
            $objecto_excel->getActiveSheet()->getColumnDimension('O')->setWidth(10);
            $objecto_excel->getActiveSheet()->getColumnDimension('P')->setWidth(10);
            $objecto_excel->getActiveSheet()->getColumnDimension('Q')->setWidth(15);
            $objecto_excel->getActiveSheet()->getColumnDimension('R')->setWidth(10);
            $objecto_excel->getActiveSheet()->getColumnDimension('S')->setWidth(15);
            $objecto_excel->getActiveSheet()->getColumnDimension('T')->setWidth(12);

            
            // colocamos el ancho de la fila de cabecera
             $objecto_excel->getActiveSheet()->getRowDimension(7)->setRowHeight(35);
             $objecto_excel->setActiveSheetIndex(0);
             
             //cuerpo
             $estilo_cuerpo=array(
               'borders' => array(
                    'allborders' => array(
                        'style' => PHPExcel_Style_Border::BORDER_HAIR,
                       ),
                    )  
             );
             $estilo_filaA=array(
                'font' => array(
                    'bold' => true)
                 );
             $fila=8;
             
             foreach ($array as $key => $value) {
                      
                 $objecto_excel->setActiveSheetIndex(0)->setCellValue('A'.$fila,$this->usoci->funciones_complemento->devuelve_meses_text($key,2));
                 $objecto_excel->setActiveSheetIndex(0)->setCellValue('C'.$fila,($value['exhibidores']==0? '0,00':$this->usoci->funciones_complemento->devuelve_cifras_unidades_mil($value['exhibidores'])));
                  $objecto_excel->setActiveSheetIndex(0)->setCellValue('D'.$fila,($value['tvAbierta']==0? '0,00':$this->usoci->funciones_complemento->devuelve_cifras_unidades_mil($value['tvAbierta'])));
                   $objecto_excel->setActiveSheetIndex(0)->setCellValue('E'.$fila,($value['tvSuscrip']==0? '0,00':$this->usoci->funciones_complemento->devuelve_cifras_unidades_mil($value['tvSuscrip'])));
                    $objecto_excel->setActiveSheetIndex(0)->setCellValue('F'.$fila,($value['distribuidores']==0? '0,00':$this->usoci->funciones_complemento->devuelve_cifras_unidades_mil($value['distribuidores'])));
                     $objecto_excel->setActiveSheetIndex(0)->setCellValue('G'.$fila,($value['ventaAlquiler']==0? '0,00':$this->usoci->funciones_complemento->devuelve_cifras_unidades_mil($value['ventaAlquiler'])));
                      $objecto_excel->setActiveSheetIndex(0)->setCellValue('H'.$fila,($value['servProduccion']==0? '0,00':$this->usoci->funciones_complemento->devuelve_cifras_unidades_mil($value['servProduccion'])));
                       $objecto_excel->setActiveSheetIndex(0)->setCellValue('I'.$fila,($value['total_autoli']==0? '0,00':$this->usoci->funciones_complemento->devuelve_cifras_unidades_mil($value['total_autoli'])));
                       $objecto_excel->setActiveSheetIndex(0)->setCellValue('J'.$fila,($value['interise']==0? '0,00':$this->usoci->funciones_complemento->devuelve_cifras_unidades_mil($value['interise'])));
                       $objecto_excel->setActiveSheetIndex(0)->setCellValue('L'.$fila,($value['interesrc']==0? '0,00':$this->usoci->funciones_complemento->devuelve_cifras_unidades_mil($value['interesrc'])));
                       $objecto_excel->setActiveSheetIndex(0)->setCellValue('N'.$fila,($value['reparosaf']==0? '0,00':$this->usoci->funciones_complemento->devuelve_cifras_unidades_mil($value['reparosaf'])));
                       $objecto_excel->setActiveSheetIndex(0)->setCellValue('O'.$fila,($value['reparosrc']==0? '0,00':$this->usoci->funciones_complemento->devuelve_cifras_unidades_mil($value['reparosrc'])));
                       $objecto_excel->setActiveSheetIndex(0)->setCellValue('S'.$fila,$this->usoci->funciones_complemento->devuelve_cifras_unidades_mil(($value['total_autoli']+$value['interise']+$value['interesrc']+$value['reparosaf']+$value['reparosrc'])));
                  
                 $objecto_excel->getActiveSheet()->getRowDimension($fila)->setRowHeight(15);
                 $objecto_excel->getActiveSheet()->getStyle('A'.$fila.':T'.$fila)->applyFromArray($estilo_cuerpo);
                 $objecto_excel->getActiveSheet()->getStyle('A8:A19')->applyFromArray($estilo_filaA);
                 $fila++;
                
//                 echo"<tr>
//                                <td id='meses'>".$this->funciones_complemento->devuelve_meses_text($key,2)."</td>
//                                <td class='montos' >".($value['exhibidores']==0? '0,00':$this->funciones_complemento->devuelve_cifras_unidades_mil($value['exhibidores']))."</td>
//                                <td class='montos' >".($value['tvAbierta']==0? '0,00':$this->funciones_complemento->devuelve_cifras_unidades_mil($value['tvAbierta']))."</td>
//                                <td class='montos' >".($value['tvSuscrip']==0? '0,00':$this->funciones_complemento->devuelve_cifras_unidades_mil($value['tvSuscrip']))."</td>
//                                <td class='montos' >".($value['distribuidores']==0? '0,00':$this->funciones_complemento->devuelve_cifras_unidades_mil($value['distribuidores']))."</td>
//                                <td class='montos' >".($value['ventaAlquiler']==0? '0,00':$this->funciones_complemento->devuelve_cifras_unidades_mil($value['ventaAlquiler']))."</td>
//                                <td class='montos' >".($value['servProduccion']==0? '0,00':$this->funciones_complemento->devuelve_cifras_unidades_mil($value['servProduccion']))."</td>
//                                <td class='montos' >".($value['total_autoli']==0? '0,00':$this->funciones_complemento->devuelve_cifras_unidades_mil($value['total_autoli']))."</td>   
//                                   
//                            </tr>";
             }
             //LEYENDA
             $estilo_total=array(
                            'font' => array(
                                'bold' => true),
                            'alignment' => array(
                               'horizontal' => PHPExcel_Style_Alignment::HORIZONTAL_CENTER,
                               'vertical' => PHPExcel_Style_Alignment::VERTICAL_CENTER,
                               )
                        );
             $objecto_excel->setActiveSheetIndex(0)->setCellValue('A20','TOTAL');
             $objecto_excel->getActiveSheet()->getStyle('A20')->applyFromArray($estilo_total);
             
             $estilo_leyenda=array('font' => array(
                    'bold' => FALSE,
                    'size'	  => '8',
                    'name'	  => 'Arial',)
                 );
             
             $objecto_excel->setActiveSheetIndex(0)->setCellValue('A22','LEYENDA');
             $objecto_excel->setActiveSheetIndex(0)->setCellValue('A23','RISE');
             $objecto_excel->setActiveSheetIndex(0)->setCellValue('B23','Resolución de Imposición de Sanción por Extemporaneidad (RISE)');
             $objecto_excel->setActiveSheetIndex(0)->setCellValue('A24','RC');
             $objecto_excel->setActiveSheetIndex(0)->setCellValue('B24','Resolución Culminatoria');
             $objecto_excel->setActiveSheetIndex(0)->setCellValue('A25','A.F.');
             $objecto_excel->setActiveSheetIndex(0)->setCellValue('B25','Acta Fiscal');
             $objecto_excel->getActiveSheet()->getStyle('A22:A25')->applyFromArray($estilo_leyenda);
             $objecto_excel->getActiveSheet()->getStyle('B22:B25')->applyFromArray($estilo_leyenda);
             
             //cuadro de metas
             $estilo_metas=array(
                 'font' => array(
                    'bold' => true,
                    'size'	  => '10',
                    'name'	  => 'Arial'
                     ),
                 'borders' => array(
                    'allborders' => array(
                        'style' => PHPExcel_Style_Border::BORDER_HAIR,
                       ),
                    ),
                'alignment' => array(
                    'horizontal' => PHPExcel_Style_Alignment::HORIZONTAL_CENTER,
                    'vertical' => PHPExcel_Style_Alignment::VERTICAL_JUSTIFY,
                    ),
             );
             $objecto_excel->setActiveSheetIndex(0)->setCellValue('A27','Plan de la Cinematografía Nacional Año '.$anio);
             $objecto_excel->setActiveSheetIndex(0)->setCellValue('B27','');
             $objecto_excel->getActiveSheet()->getRowDimension(27)->setRowHeight(40);
             
             $objecto_excel->setActiveSheetIndex(0)->setCellValue('A28','Ingresos acumulados Año '.$anio);
             $objecto_excel->setActiveSheetIndex(0)->setCellValue('B28','');
             $objecto_excel->getActiveSheet()->getRowDimension(28)->setRowHeight(25);
             
             $objecto_excel->getActiveSheet()->getStyle('A29:B29')->applyFromArray($estilo2);
             
             $objecto_excel->setActiveSheetIndex(0)->setCellValue('A30','Cumplimiento en %');
             $objecto_excel->setActiveSheetIndex(0)->setCellValue('B30','');
             
             $objecto_excel->getActiveSheet()->getStyle('A27:A30')->applyFromArray($estilo_metas);
             $objecto_excel->getActiveSheet()->getStyle('B27:B30')->applyFromArray($estilo_metas);
             
             $objecto_excel->setActiveSheetIndex(0)->setCellValue('A32','EXCEDENTE');
             $objecto_excel->setActiveSheetIndex(0)->setCellValue('B32','');
             
             $objecto_excel->getActiveSheet()->getStyle('A32:B32')->applyFromArray($estilo_metas);
             
             // totalizacion por años
                //enxcabezado tabla con los meses
             $estilo4=array(
                'font' => array(
                    'bold' => TRUE,
                    'color'=>array('rgb'=>'FFFFFF'),
                    'size'	  => '6',
                    'name'	  => 'Arial',
                    
                    ),
                
                //borde delgado
                'borders' => array(
                    'allborders' => array(
                        'style' => PHPExcel_Style_Border::BORDER_HAIR,
                       ),
                    ),
                'alignment' => array(
                    'horizontal' => PHPExcel_Style_Alignment::HORIZONTAL_CENTER,
                    'vertical' => PHPExcel_Style_Alignment::VERTICAL_JUSTIFY,
                    ),
                'fill' => array(
                    'type' => PHPExcel_Style_Fill::FILL_GRADIENT_LINEAR,
                    'rotation' => 90,
                    'startcolor' => array(
                        'argb' => '800000',
                        ),
                    'endcolor' => array(
                        'argb' => '800000',
                        ),
                    ),
                   
                );
             $columnas = array('A','B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q','R','S','T','U','V','w','x','Y','Z');
             
             $fila2=36;
             $fila3=37;
             $col=1;
             $objecto_excel->setActiveSheetIndex(0)->setCellValue('A36','MES');
             $objecto_excel->getActiveSheet()->getStyle('A36')->applyFromArray($estilo4);
             for($i=2006;$i<=date('Y');$i++){
                
                 $objecto_excel->setActiveSheetIndex(0)->setCellValue($columnas[$col].$fila2,'RECAUDACION'.$i);
                 $objecto_excel->getActiveSheet()->getStyle($columnas[$col].$fila2)->applyFromArray($estilo4);
                 $colum_final=$columnas[$col];
                 $col++;
                 
             }
             //CUERPO TABLE CON LOS MESES RECAUDADO POR AÑO
             $estilo5=array(
                 'font' => array(
                    'bold' => true,
                    'size'	  => '6',
                    'name'	  => 'Arial'
                     ),
                 'borders' => array(
                    'allborders' => array(
                        'style' => PHPExcel_Style_Border::BORDER_HAIR,
                       ),
                    ),
                'alignment' => array(
                    'horizontal' => PHPExcel_Style_Alignment::HORIZONTAL_RIGHT,
                    'vertical' => PHPExcel_Style_Alignment::VERTICAL_JUSTIFY,
                    ),
             );
             $estiloMes=array(
                 'font' => array(
                    'bold' => true,
                    'size'	  => '6',
                    'name'	  => 'Arial'
                     ),
                 'borders' => array(
                    'allborders' => array(
                        'style' => PHPExcel_Style_Border::BORDER_HAIR,
                       ),
                    ),
                 'alignment' => array(
                    'horizontal' => PHPExcel_Style_Alignment::HORIZONTAL_LEFT,
                    'vertical' => PHPExcel_Style_Alignment::VERTICAL_JUSTIFY,
                    ),
                 );
             $objecto_excel->setActiveSheetIndex(0)->setCellValue('A37','ENERO');
             $objecto_excel->setActiveSheetIndex(0)->setCellValue('A38','FEBRERO');
             $objecto_excel->setActiveSheetIndex(0)->setCellValue('A39','MARZO');
             $objecto_excel->setActiveSheetIndex(0)->setCellValue('A40','ABRIL');
             $objecto_excel->setActiveSheetIndex(0)->setCellValue('A41','MAYO');
             $objecto_excel->setActiveSheetIndex(0)->setCellValue('A42','JUNIO');
             $objecto_excel->setActiveSheetIndex(0)->setCellValue('A43','JULIO');
             $objecto_excel->setActiveSheetIndex(0)->setCellValue('A44','AGOSTO');
             $objecto_excel->setActiveSheetIndex(0)->setCellValue('A45','SEPTIEMBRE');
             $objecto_excel->setActiveSheetIndex(0)->setCellValue('A46','OCTUBRE');
             $objecto_excel->setActiveSheetIndex(0)->setCellValue('A47','NOVIEMBRE');
             $objecto_excel->setActiveSheetIndex(0)->setCellValue('A48','DICIEMBRE');
             $objecto_excel->getActiveSheet()->getStyle('A37:A48')->applyFromArray($estiloMes);
             $objecto_excel->getActiveSheet()->getStyle('B37:'.$colum_final.'48')->applyFromArray($estilo5);
             $objecto_excel->setActiveSheetIndex(0)->setCellValue('A49','TOTAL:');
             $objecto_excel->getActiveSheet()->getStyle('A49:'.$colum_final.'49')->applyFromArray($estilo4);
            
             // lleno los montos por cada mes y cada anio
             $meses=array('37'=>'01','38'=>'02',"39"=>'03',"40"=>'04',"41"=>'05',"42"=>'06',"43"=>'07',"44"=>'08',"45"=>'09',"46"=>'10',"47"=>'11',"48"=>'12');
             $col=1;
             $total_anio=0;
             // recorro los años desde el 2006 que fue cuando comenzo a recaudar la institucion 
             //hasta el año actual
             for($i=2006;$i<=date('Y');$i++){
                 //recorro el arreglo con los totales por año y lo comparo con cada uno de los años del
                 // ciclo anterior esto es para determinar en que columna del excel debo llenar los datos
                 foreach ($recau_poranio as $key => $value) {
                 //verifico si esxiste el año
                 if($key==$i):
                     //recorro el valor del arreglo anterior el cual tambien es un aareglo que contiene los totales 
                     // por mes segun el año
                     foreach ($value as $key2 => $value2) {
                     // recorro el arrecglo mes para obtener a que fila le pertenece el mes que viene del arreglo anterior
                     // lo cual es el valor de las key de cada mes
                         foreach ($meses as  $key3=>$mes) {
                             // si los meses son iguales vacio la informacion segun la colummna que le corresponde al anio y la fila que le corresponda al mes
                             if($mes==$key2):
                               $objecto_excel->setActiveSheetIndex(0)->setCellValue($columnas[$col].$key3,$this->usoci->funciones_complemento->devuelve_cifras_unidades_mil($value2[0]));
                               $total_anio=$total_anio+$value2[0];
                                
                             endif;
                            
                         }
                         
                     }
                 endif; 
                     
                      
                 } 
                 $col++;
                $totales[$i]=$total_anio;
                $total_anio=0;
             }
             $col=1;
             // lleno el pie de totales por año
             for($i=2006;$i<=date('Y');$i++){
                 foreach ($totales as $key6 => $total_a) {
                   if($key6==$i):
                     $objecto_excel->setActiveSheetIndex(0)->setCellValue($columnas[$col].'49',$this->usoci->funciones_complemento->devuelve_cifras_unidades_mil($total_a)); 
                   endif;
                 }
                 $col++;

             }
             
             
             $objecto_excel->getActiveSheet()->setTitle('RECAUDACION'); 
             
             
       
          // Se modifican los encabezados del HTTP para indicar que se envia un archivo de Excel.
            header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
            header('Content-Disposition: attachment;filename="reportes de resolucion de multa por extemporaneidad.xlsx"');
            header('Cache-Control: max-age=0');
            $objWriter = PHPExcel_IOFactory::createWriter($objecto_excel, 'Excel2007');
            $objWriter->save('php://output');
        exit;  
    }
   
   
   
}

?>
