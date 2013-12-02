<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');

    include('include/librerias/phpjasperxml_0.8c/phpjasperxml_0.8c/class/tcpdf/tcpdf.php');
    include("include/librerias/phpjasperxml_0.8c/phpjasperxml_0.8c/class/PHPJasperXML.inc.php");
    include('include/librerias/phpjasperxml_0.8c/phpjasperxml_0.8c/setting.php');

    
    
if ( ! function_exists('genera_reporte_pdf'))
    { 
    
        function genera_reporte_pdf($archivo){

        $xml =  simplexml_load_file("include/reportes/".$archivo);

        $PHPJasperXML = new PHPJasperXML();
        //$PHPJasperXML->debugsql=true;
        $PHPJasperXML->arrayParameter=array("estado"=>3);
        $PHPJasperXML->xml_dismantle($xml);

        $PHPJasperXML->transferDBtoArray($server,$user,$pass,$db,$driver);
        $PHPJasperXML->outpage("I");    //page output method I:standard output  D:Download file
        }
}


?>