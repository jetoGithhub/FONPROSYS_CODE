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
                    'bold' => false,
                    'color'=>array('rgb'=>'FFFFFF'),
                    'size'	  => '10',
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
                    'vertical' => PHPExcel_Style_Alignment::VERTICAL_CENTER,
                    ),
                'fill' => array(
                    'type' => PHPExcel_Style_Fill::FILL_GRADIENT_LINEAR,
                    'rotation' => 90,
                    'startcolor' => array(
                        'argb' => '800000',
                        ),
                    'endcolor' => array(
                        'argb' => '000000',
                        ),
                    ),
                   
                );
        return $estilo_cabecera;
    }
    
    function genera_excel_recaudacion($array,$cabecera)
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

    //          $objecto_excel->getActiveSheet()->getColumnDimension($key)->setAutoSize(true);
              $objecto_excel->getActiveSheet()->getColumnDimension($key)->setWidth(15);
            }
            // colocamos el ancho de la fila de cabecera
             $objecto_excel->getActiveSheet()->getRowDimension(7)->setRowHeight(30);
             $objecto_excel->setActiveSheetIndex(0);
             
             //cuerpo
             $estilo_cuerpo=array(
               'borders' => array(
                    'allborders' => array(
                        'style' => PHPExcel_Style_Border::BORDER_DASHDOT,
                       ),
                    )  
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
                  
                 $objecto_excel->getActiveSheet()->getRowDimension($fila)->setRowHeight(15);
                 $objecto_excel->getActiveSheet()->getStyle('A'.$fila.':T'.$fila)->applyFromArray($estilo_cuerpo);
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
