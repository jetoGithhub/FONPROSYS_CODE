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
      $estilo_encabezado=array(
                'font' => array(
                    'bold' => true,
                    'size'	  => '10',
                    'name'	  => 'Arial',
                    )
          );
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
      $objecto_excel= new PHPExcel();   
      $objecto_excel->getActiveSheet()->getHeaderFooter()->setOddHeader('&L&G');           
      $objecto_excel->getActiveSheet()->setTitle('RISE');

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
            $objecto_excel->getActiveSheet()->getStyle('A'.$count)->applyFromArray($estilo_encabezado);
            $count ++;
        }
       
        // aramamos Encabezado de los datos     
        foreach ($cabecera as $key=>$value)
        {
               
          $objecto_excel->setActiveSheetIndex(0)->setCellValue($key.(count($text_encabezado)+3),$value);
           
          $objecto_excel->getActiveSheet()->getStyle($key.(count($text_encabezado)+3))->applyFromArray($estilo_cabecera);
          
//          $objecto_excel->getActiveSheet()->getColumnDimension($key)->setAutoSize(true);
          $objecto_excel->getActiveSheet()->getColumnDimension($key)->setWidth(15);
        }
        // colocamos el ancho de la fila de cabecera
         $objecto_excel->getActiveSheet()->getRowDimension((count($text_encabezado)+3))->setRowHeight(20);
         $objecto_excel->setActiveSheetIndex(0);

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
