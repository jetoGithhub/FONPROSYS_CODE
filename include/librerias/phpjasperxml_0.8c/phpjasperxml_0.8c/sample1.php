<?php
/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
include_once('class/tcpdf/tcpdf.php');
include_once("class/PHPJasperXML.inc.php");
include_once ('setting.php');



$xml =  simplexml_load_file("archivos_fonprocine/".$_REQUEST['archivo']);


$PHPJasperXML = new PHPJasperXML();
//$PHPJasperXML->debugsql=true;
$PHPJasperXML->arrayParameter=array("parameter1"=>$_REQUEST['id_declaracion']);
$PHPJasperXML->xml_dismantle($xml);

$PHPJasperXML->transferDBtoArray($server,$user,$pass,$db,$driver);
$PHPJasperXML->outpage("D");    //page output method I:standard output  D:Download file


?>
