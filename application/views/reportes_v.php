<?php

    require_once('include/librerias/phpjasperxml_0.8c/phpjasperxml_0.8c/class/tcpdf/tcpdf.php');
    require_once("include/librerias/phpjasperxml_0.8c/phpjasperxml_0.8c/class/PHPJasperXML.inc.php");
    require_once('include/librerias/phpjasperxml_0.8c/phpjasperxml_0.8c/setting.php');
                
            $xml =  simplexml_load_file("include/reportes/".$archivo);

        $PHPJasperXML = new PHPJasperXML();
//        $PHPJasperXML->debugsql=true;
        $PHPJasperXML->arrayParameter=$parametros;
        $PHPJasperXML->xml_dismantle($xml);

        $PHPJasperXML->transferDBtoArray($server,$user,$pass,$db,$driver);
        $PHPJasperXML->outpage("I");    //page output method I:standard output  D:Download file
        
?>