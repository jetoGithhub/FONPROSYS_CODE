<?php
//background-image: url('fonprosys_code/include/imagenes/bannerCenac.jpg';
//include("include/librerias/securimage/securimage.php");
//<img src='http://192.168.1.102/fonprosys_code/include/imagenes/cnac.gif' style='width: 80px;' alt='logo' />
ob_start();  
echo "<page>    
  
    <div  style='margin-top: 50px; margin-bottom: 50px; text-align: center;'><strong>PLANILLA DE REGISTRO PARA CONTRIBUYENTES FONPROCINE</strong></div>
    <div id='planilla'>
  
    <table  style=' border: solid 2px #000000; margin-left: 50px' border='1'>
        <tr><td colspan='3'><div  style='text-align: center; background: #D8D8D8;' >A). Datos del Contribuyente</div></td></tr>
        <tr>
            <td colspan='2' style='border: solid 1px #000000; color: #000000; width: 230px; padding: 5px 0 5px 5px' ><label ><strong>1). Razon Social:</strong></label><br /> $infoplanilla[razonsocial] </td>
            <td style='border: solid 1px #000000; color: #000000; width: 230px; padding: 5px 0 5px 5px' ><label><strong>2). Denominacion Comercial:</strong></label><br />$infoplanilla[denominacionc]</td>
           
        </tr>
   
        <tr>
            <td style='border: solid 1px #000000; color: #000000; width: 230px; padding: 5px 0 5px 5px' ><label ><strong>3). Actividad Economica:</strong></label><br />$infoplanilla[actividade]</td>
            <td style='border: solid 1px #000000; color: #000000; width: 230px; padding: 5px 0 5px 5px' ><label ><strong>4). N de rif:</strong></label><br />$infoplanilla[rif]</td>
             <td style='border: solid 1px #000000; color: #000000; width: 230px; padding: 5px 0 5px 5px' ><label><strong>5).registro cinematografico:</strong></label><br />$infoplanilla[registrocine]</td>
        </tr>
        <tr>
        <td colspan='3' style='border: solid 1px #000000; color: #000000; width: 230px; padding: 5px 0 5px 5px' >
                    <label><strong>6).Domicilio Fiscal:</strong></label><br />$infoplanilla[domifiscal]
                    
        </td>
        </tr>
          <tr>
                <td colspan='' style='border: solid 1px #000000; color: #000000; width: 230px; padding: 5px 0 5px 5px'>
                    <label ><strong>7). Ciudad o lugar:</strong></label><br />$infoplanilla[ciudad]
                   
                </td>
                <td style='border: solid 1px #000000; color: #000000; width: 230px; padding: 5px 0 5px 5px' >
                    <label ><strong>8).estado o entidad federal:</strong></label><br />$infoplanilla[estado]
                    
                </td>
                <td style='border: solid 1px #000000; color: #000000; width: 230px; padding: 5px 0 5px 5px' >
                    <label><strong>9).zona postal:</strong></label><br />$infoplanilla[zonapostal] 
                    
                </td>    
            </tr>
         <tr>
                <td style='border: solid 1px #000000; color: #000000; width: 230px; padding: 5px 0 5px 5px' >
                     <label ><strong>10). Telefono1:</strong></label><br />$infoplanilla[telef1]
                    
                </td>
                <td style='border: solid 1px #000000; color: #000000; width: 230px; padding: 5px 0 5px 5px' >
                   <label ><strong>11). Telefono2:</strong></label><br />$infoplanilla[telef2]
                    
                </td>            
                <td style='border: solid 1px #000000; color: #000000; width: 230px; padding: 5px 0 5px 5px' >
                     <label><strong>12). Telefono3:</strong></label><br />$infoplanilla[telef3]
                    
                   
                </td>    
            </tr>
            <tr>
                <td style='border: solid 1px #000000; color: #000000; width: 230px; padding: 5px 0 5px 5px' >
                     <label ><strong>13). Fax1:</strong></label><br />$infoplanilla[fax1]
                    
                 </td>
                  <td style='border: solid 1px #000000; color: #000000; width: 230px; padding: 5px 0 5px 5px' >
                     <label ><strong>14). Fax2:</strong></label><br />$infoplanilla[fax2]
                     
                 </td>
                  <td style='border: solid 1px #000000; color: #000000; width: 230px; padding: 5px 0 5px 5px' >
                     <label ><strong>15). Email:</strong></label><br />$infoplanilla[email]
                     
                 </td>      
            
            </tr>
            <tr>
                <td style='border: solid 1px #000000; color: #000000; width: 230px; padding: 5px 0 5px 5px' >
                   <label ><strong>16). PINBB:</strong></label><br />$infoplanilla[pinbb]
                    
                </td>
                <td style='border: solid 1px #000000; color: #000000; width: 230px; padding: 5px 0 5px 5px' >
                     <label ><strong>17). Skype:</strong></label><br />$infoplanilla[skype]
                   
                </td>
                <td style='border: solid 1px #000000; color: #000000; width: 230px; padding: 5px 0 5px 5px' >
                    <label ><strong>18). twitter:</strong></label><br />$infoplanilla[twitter]
                    
                </td>
               
            
             </tr>
             <tr>
                 <td colspan='3' style='border: solid 1px #000000; color: #000000; width: 230px; padding: 5px 0 5px 5px'>
                     <label ><strong>19).facebook :</strong></label><br />$infoplanilla[facebook]
                    
                  </td>   
             </tr>    
       </table><br />
    
      
      <table style=' border: solid 2px #000000; margin-left: 10px' border='1'>
           <tr><td colspan='2'><div style='text-align: center; background: #D8D8D8;' >B). Datos de las Acciones </div></td></tr>
             <tr>                 
                 <td colspan='' style='border: solid 1px #000000; color: #000000; width: 351px; padding: 5px 0 5px 6px'>
                     <label ><strong>1). Numero de acciones:</strong></label><br />$infoplanilla[nuacciones]
                     
                 </td>
                 <td style='border: solid 1px #000000; color: #000000; width: 351px; padding: 5px 0 5px 6px'>
                   <label colspan=''><strong>2).valor de las acciones:</strong></label><br />$infoplanilla[valaccion] 
                   
                 </td>  
        
           
            </tr>
      </table ><br />    
      
          <table style=' border: solid 2px #000000; margin-left: 10px' border='1'> 
             <tr><td colspan='3'><div style='text-align: center; background: #D8D8D8;' >C). Datos del registro mercatil </div></td></tr>
              <tr>
                  <td style='border: solid 1px #000000; color: #000000; width: 230px; padding: 5px 0 5px 5px'>
                      <label ><strong>1). Capital suscrito:</strong></label><br />$infoplanilla[capitalsus]
                      
                   </td>
                  <td style='border: solid 1px #000000; color: #000000; width: 230px; padding: 5px 0 5px 5px' >
                      <label style=' margin-right: '><strong>2). Capital pagado:</strong></label><br />$infoplanilla[capitalpag]
                      
                   </td>
                   <td style='border: solid 1px #000000; color: #000000; width: 230px; padding: 5px 0 5px 5px' >
                       <label style=' margin-right: '><strong>3). Oficina registradora:</strong></label><br />
                       
                   </td>
              </tr>
              <tr>
                  <td style='border: solid 1px #000000; color: #000000; width: 230px; padding: 5px 0 5px 5px'>
                      <label ><strong>4).N Registro mercantil:</strong></label><br />$infoplanilla[rmnumero]
                      
                  </td>
                  <td style='border: solid 1px #000000; color: #000000; width: 230px; padding: 5px 0 5px 5px' >
                      <label ><strong>5).Numero del folio:</strong></label><br />$infoplanilla[rmfolio]
                      
                  </td>
                  <td style='border: solid 1px #000000; color: #000000; width: 230px; padding: 5px 0 5px 5px' >
                      <label ><strong>6). Numero del tomo:</strong></label><br />$infoplanilla[rmtomo]
                      
                  </td>
                  
             </tr>
             <tr>
                 <td style='border: solid 1px #000000; color: #000000; width: 230px; padding: 5px 0 5px 5px' >
                     <label ><strong>7).Fecha del registro:</strong></label><br />$infoplanilla[rmfechapro]
                     
                 </td>
                  <td style='border: solid 1px #000000; color: #000000; width: 230px; padding: 5px 0 5px 5px' >
                     <label ><strong>8). Numero de control:</strong></label><br />$infoplanilla[rmncontrol]
                     
                 </td>
                  <td style='border: solid 1px #000000; color: #000000; width: 230px; padding: 5px 0 5px 5px' >
                     <label ><strong>9). Objeto de la empresa:</strong></label><br />$infoplanilla[rmobjeto]
                     
                 </td>
             </tr>
            <tr>
                <td colspan='3' style='border: solid 1px #000000; color: #000000; width: 230px; padding: 5px 0 5px 5px' >
                    <label><strong>10).Domicilio comercial:</strong></label><br />$infoplanilla[domcomer]
                   
                </td>
            </tr>
             
        
        </table>
      
    </div>
    <div style='width: 400px; margin-left:180px; margin-top:100px' >
        <hr />
        <h4 style='text-align: center;'>FIRMA DEL CONTRIBUEYENTE</h4>
    </div>    
</page>";
    
//ob_start();
//
//require_once ('include/librerias/html_planilla.php');
//
//$content = ob_get_clean();

$content = ob_get_clean();


    require_once('include/librerias/html2pdf/html2pdf.class.php');
    $html2pdf = new HTML2PDF('P','A4','fr');
    $html2pdf->WriteHTML($content);
    $html2pdf->Output('exemple2.pdf','D');
?>
