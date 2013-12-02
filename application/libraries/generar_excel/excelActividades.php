<?php
//include("../../../librerias/sesion.php");
//$usuario = $_SESSION['intifenix']['contacto'];
require_once("../clases/conectbd.php");
require_once("../clases/Classes/PHPExcel.php");
// extract ($_REQUEST);
//
$objDatos = new Datos();
$conex = $objDatos->Conectar("dato");

$queryoperativo="SELECT aop_clvcodigo, aop_strdetalle,aop_blnprioridad from novedades.tblaspectosoperativos where aop_clvreporte=18 and not aop_blnborrado";
$result=$objDatos->Ejecutarsql($queryoperativo,$conex);

$querylogistico="SELECT  a.alo_clvcodigo, CASE when a.alo_clvtipoaspecto=1 then 'Requerimiento' 
		else CASE when a.alo_clvtipoaspecto=2 then 'Reparaci�n'
		else CASE when a.alo_clvtipoaspecto=3 then 'Desincorporaci�n'
		END END END as tipo_aspecto, a.alo_strdetalle 

FROM novedades.tblaspectoslogisticos a

 WHERE a.alo_clvreporte=21 --and not a.alo_blnborrado";
$result1=$objDatos->Ejecutarsql($querylogistico,$conex);
//print_r($result1);
//while($row_reg = pg_fetch_array($result1))
// {
//    print $row_reg[0];
//}
//die;
// Crea un nuevo objeto PHPExcel
$styleArray =
array('font' =>
    array('bold' => true,),'alignment' =>
        array('horizontal' => PHPExcel_Style_Alignment::HORIZONTAL_CENTER,),'borders' =>
            array('top' =>
                array('style' => PHPExcel_Style_Border::BORDER_THIN,),),'fill' =>
                    array('type' => PHPExcel_Style_Fill::FILL_GRADIENT_LINEAR,'rotation' => 90,'startcolor' =>
                        array('argb' => '4A9595',),'endcolor' => array('argb' => 'FFFFFFF',),),);


$objPHPExcel = new PHPExcel();
$objDrawing = new PHPExcel_Worksheet_HeaderFooterDrawing();
$objDrawing->setName('Inti logo');
$objDrawing->setPath('bannerInti.jpg');
//$objDrawing->setHeight(771);

$objPHPExcel->getActiveSheet()->getHeaderFooter()->setOddHeader('&L&G');
$objPHPExcel->getActiveSheet()->getHeaderFooter()->addImage($objDrawing,PHPExcel_Worksheet_HeaderFooter::IMAGE_HEADER_LEFT);
// Establecer propiedades
$objPHPExcel->getProperties()
->setCreator("Siscoi")
->setLastModifiedBy("Siscoi")
->setTitle("Reporte de Novedades Diarias")
->setSubject("Reporte de Novedades Diarias")
->setKeywords("Excel Office 2007 openxml php")
->setCategory("Reporte de Novedades Diarias");



//$objDrawing->setWorksheet($objPHPExcel->getActiveSheet());
// Agregar Informacion

//
//
//HOJA Logisticos
//
$objPHPExcel->setActiveSheetIndex(0)
        ->setCellValue('A3',utf8_encode('C�digo de Reporte: '))
        ->setCellValue('A4',utf8_encode('Servidor P�blico: '))
        ->setCellValue('A5', 'Gerencia Responsable: ')
->setCellValue('A6', 'CODIGO')
->setCellValue('B6', 'TIPO ASPECTO')
->setCellValue('C6', 'DETALLE')
->setCellValue('D6', 'GERENCIA RESPONSABLE');
 $i=7;
while($row_reg = pg_fetch_array($result))
 {
  $objPHPExcel->setActiveSheetIndex(0)
   ->setCellValue('A'.$i.'', $row_reg[0])
   ->setCellValue('b'.$i.'', $row_reg[1])
   ->setCellValue('c'.$i.'', $row_reg[2])
   ->setCellValue('d'.$i.'', $row_reg[2]);
          
   $i++;

}
  $objPHPExcel->getActiveSheet()->getStyle('A6:D6')->applyFromArray($styleArray);
// Renombrar Hoja
$objPHPExcel->getActiveSheet()->setTitle('Aspectos Operativos');

//**define una cabecera fija de impresi�n
$objPHPExcel->getActiveSheet()->getPageSetup()->setRowsToRepeatAtTopByStartAndEnd(1, 6);
// **
// 
$objPHPExcel->getActiveSheet()->getColumnDimension('A')->setAutoSize(true);
//$objPHPExcel->getActiveSheet()->getColumnDimension('B')->setAutoSize(true);
$objPHPExcel->getActiveSheet()->getColumnDimension('C')->setAutoSize(true);
$objPHPExcel->getActiveSheet()->getColumnDimension('D')->setAutoSize(true);
//
$objPHPExcel->getActiveSheet()->getStyle('A7:D'.$i.'')->getAlignment()->setWrapText(true);

$objPHPExcel->createSheet();
// 
//HOJA Logisticos
$objPHPExcel->setActiveSheetIndex(1)
       
        ->setCellValue('B4',utf8_encode('Servidor P�blico: '))
        ->setCellValue('B6', 'Gerencia Actual')
->setCellValue('A6', '#')
->setCellValue('c6', 'TIPO ASPECTO')
->setCellValue('d6', 'DETALLE')
->setCellValue('e6', 'GERENCIA RESPONSABLE');
 $i=7;
 $j=1;
while($row_reg = pg_fetch_array($result1))
 {
  $objPHPExcel->setActiveSheetIndex(1)
   ->setCellValue('A'.$i.'', $j)
   ->setCellValue('c'.$i.'', utf8_encode($row_reg[1]))
   ->setCellValue('d'.$i.'', $row_reg[2])
   ->setCellValue('e'.$i.'', $row_reg[3]);
          
   $i++;
   $j++;
}
  $objPHPExcel->getActiveSheet()->getStyle('A6:D6')->applyFromArray($styleArray);
// Renombrar Hoja
$objPHPExcel->getActiveSheet()->setTitle('Aspectos Logisticos');

//**define una cabecera fija de impresi�n
$objPHPExcel->getActiveSheet()->getPageSetup()->setRowsToRepeatAtTopByStartAndEnd(1, 6);
// **
// 
$objPHPExcel->getActiveSheet()->getColumnDimension('A')->setAutoSize(true);
$objPHPExcel->getActiveSheet()->getColumnDimension('B')->setAutoSize(true);
$objPHPExcel->getActiveSheet()->getColumnDimension('C')->setAutoSize(true);
$objPHPExcel->getActiveSheet()->getColumnDimension('D')->setAutoSize(true);



// Establecer la hoja activa, para que cuando se abra el documento se muestre primero.
$objPHPExcel->setActiveSheetIndex(0);

// Se modifican los encabezados del HTTP para indicar que se envia un archivo de Excel.
header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
header('Content-Disposition: attachment;filename="Reporte.xlsx"');
header('Cache-Control: max-age=0');
$objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel2007');
$objWriter->save('php://output');
exit;

?>

