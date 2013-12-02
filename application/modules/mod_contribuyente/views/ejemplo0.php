<?php
/**
 * ARCHIVO QUE LLAMA EL HTML PARA  CONTRUIR EL PDF
 * LCT-2013
 */

    // get the HTML
    ob_start();
//    include('application/modules/mod_contribuyente/views/imp_planilla_cont_resp_v.php');
    include(dirname(__FILE__).'/imp_planilla_cont_resp_v.php');
    $content = ob_get_clean();

    // convert in PDF
//    require_once(dirname(__FILE__).'/../html2pdf.class.php');
    
    require_once('include/librerias/html2pdf/html2pdf.class.php');
    try
    {
        $html2pdf = new HTML2PDF('P', 'A4', 'fr');
//      $html2pdf->setModeDebug();
        $html2pdf->setDefaultFont('Arial');
        $html2pdf->writeHTML($content, isset($_GET['vuehtml']));
        $html2pdf->Output('planilla.pdf');
    }
    catch(HTML2PDF_exception $e) {
        echo $e;
        exit;
    }
