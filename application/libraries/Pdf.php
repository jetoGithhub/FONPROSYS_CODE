<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
 
require_once dirname(__FILE__) . '/fpdf/fpdf.php';
 
class Pdf extends FPDF
{
    protected $txt;
    var $B=0;
    var $I=0;
    var $U=0;
    var $HREF='';
    var $ALIGN='';
 
    function __construct()
    {
        parent::__construct();

    }
    
   
    function Header()
        {
        //Logo
        $this->Image(dirname(__FILE__) ."/encabezado_viejo.jpg" , 20 ,8, 175 , 15 , "JPG" );
        //Arial bold 15
        $this->SetFont('Arial','B',12);
        //Movernos a la derecha
        $this->Cell(80);
        //Título
        //$this->Cell(60,10,'Titulo del archivo',1,0,'C');
        //Salto de línea
        $this->Ln(5);

        }
        
        //Pie de página
        function Footer()
        {
        //Posición: a 1,5 cm del final
        $this->SetY(-15);
        //Arial italic 8
        $this->SetFont('Arial','B',8);
        //Número de página
        $this->Cell(0,10,'Pagina '.$this->PageNo(),0,0,'R');
        
        }
        function post_header($nro_autorizacion){
            $this->SetY(23);
            $this->SetFont('Arial','B',10);  
            $this->Cell(0,6, utf8_decode($nro_autorizacion) ,0,1,'L',FALSE);
            $this->Cell(0,6, utf8_decode('CARACAS,'.date("d-m-Y")) ,0,1,'R',FALSE);
            
        }

        function TituloArchivo($titulo)
        {
         $this->SetY(50);
        //Arial 12
        $this->SetFont('Arial','B',10);
        //Color de fondo
        //$this->SetFillColor(200,220,255);
        //Título
        //$this->Cell(0,6, $this->titulo ,0,1,'C',true);
        $this->Cell(0,6, $titulo ,0,1,'C',FALSE);
        //Salto de línea
        $this->Ln(8);
        }
        function DatosPrincipales($datos){
             
         $this->SetFont('Arial','B',10);         
             
         $this->Cell(0,5, utf8_decode('Sociedad mercantil: '.$datos['nombre']) ,0,1,'L',FALSE);
         $this->Cell(0,5, utf8_decode('Representante Legal: '.$datos['nombre']) ,0,1,'L',FALSE);
         $this->MultiCell(0,5, utf8_decode('Domicilio Fiscal: '.$datos['domfiscal']) ,0,1,'L',FALSE);
         $this->Cell(0,5, utf8_decode('Telefono(s): '.$datos['telefono']) ,0,1,'L',FALSE);
         $this->Cell(0,5, utf8_decode('R.I.F. Nº: '.$datos['rif']) ,0,1,'L',FALSE);
         $this->Cell(0,5, utf8_decode('R.N.C. N°: '.$datos['rif']) ,0,1,'L',FALSE);
         $this->Ln(4);
        }
        function DatosFirma($datos,$tipo_firma){
             
            $this->SetFont('Arial','B',11); 
            if($tipo_firma==1)
            {
                
                $this->Cell(0,6, utf8_decode($datos['variable0']."".$datos['variable1']),0,1,'C',FALSE);
                $this->Cell(0,6, utf8_decode('Presidente(a) (E)') ,0,1,'C',FALSE);
                $this->Cell(0,6, utf8_decode('Centro Nacional Autónomo de Cinematografía (CNAC)') ,0,1,'C',FALSE);
                $this->Cell(0,6, utf8_decode('Designada mediante Decreto No.'.$datos['variable2']) ,0,1,'C',FALSE);
                $this->Cell(0,6, utf8_decode('Publicada en la Gaceta Oficial de la República Bolivariana de Venezuela') ,0,1,'C',FALSE);
                $this->Cell(0,6, utf8_decode('No.'.$datos["variable3"].'del'.$datos["variable4"]),0,1,'C',FALSE);
                $this->Ln(4); 
            }elseif ($tipo_firma==2) {
                
                $this->Cell(100,6,'POR EL CONTRIBUYENTE ',0,0,'L'); 
                $this->Cell(60,6,'EL FUNCIONARIO ACTUANTE',0,1,'L');
                $this->Ln(10);
                $this->SetFont('Arial','',10); 
                $this->Cell(100,6,'Nombre y Apellido:__________________',0,0,'L'); 
                $this->Cell(60,6,' Nombre y Apellido:___________________',0,1,'L'); 
                
                $this->Cell(100,6,'Cedula de Identidad:_________________',0,0,'L'); 
                $this->Cell(60,6,'Cedula de Identidad:__________________',0,1,'L'); 
                
                $this->Cell(100,6,'Cargo:____________________________',0,0,'L'); 
                $this->Cell(60,6,' Firma:______________________________',0,1,'L'); 
                
                $this->Cell(100,6,'Telefonos:_________________________',0,1,'L'); 
                
                $this->Cell(100,6,'Feha de Notificacion:________________',0,1,'L'); 
            
            }
            
        }

        function CuerpoArchivo($file,$data)
        {
//          $variables_txt= $this->negritas($data);  
          $variables_txt= $data;
//        $cedula='17.042.979';
//        $nombre='jefferson lara';  
       
            //Leemos el fichero
            $f=fopen($file,'r');
            $this->txt=fread($f,filesize($file));
            fclose($f);
            //Times 12
            $this->SetFont('Arial','',10);
            //Imprimimos el texto justificado
            $this->txt = utf8_decode( eval('return "' . addslashes($this->txt) . '";'));

            $this->MultiCell(0,6,$this->txt);
            //Salto de línea
            $this->Ln();

        }
        /*
        * tabla_recepcion: crea un listar con todos los documentos que debe 
        *                  recaudar en el acta de recepcion de documentos el fiscal 
        * @access public         
        * 
        */
        function tabla_recepcion()
        {
           // color de linea 
           $this->SetDrawColor(255,0,0); 
           // cabecera
           $this->Cell(60,6,'DOCUMENTOS',1,0,'C'); 
           $this->Cell(60,6,'VERIFICACION DE ENTREGA',1,0,'C');
           $this->Cell(60,6,'OBSERVACIONES',1,1,'C');           
           $this->Cell(50,6,utf8_decode('Copia del Registro Mercantil (estatutario) y su (s) última (s) modificación (es) (Aumento o Disminución de Capital, Cambio de Junta Directiva, Sustitución de Representante Legal o Cambio de Razón y Objeto Social).'),1,0,FALSE);
           $this->Cell(10,6,'01',1,0);
           $this->Cell(10,6,'01',1,1);
           $this->Ln(10);
        }
        
        function TablaBasica($header,$cuerpo)
           {
            //Colores, ancho de línea y fuente en negrita de CABECERA
            $this->SetFillColor(255,0,0); // fondo de celda
//            $this->SetTextColor(); // color del texto
            $this->SetDrawColor(128,0,0); // color de linea
            $this->SetLineWidth(.3); // ancho de linea
            $this->SetFont('','B'); // negrita
//            //Colores, ancho de línea y fuente en negrita de CONTENIDO 
//            $this->SetFillColor(155, 49, 48); //
//            $this->SetTextColor(155, 49, 48);
//            $this->SetFont('');
//            //Cabecera
            foreach($header as $col):
                
             $this->Cell(40,7,$col,1);           
                
            endforeach;
            
            $this->Ln(); 
            foreach ($cuerpo as $col):
                
                $this->Cell(60,5,$col['nombre'],1);
                $this->Cell(40,5,$col['rif'],1,0,'C');
                $this->Cell(40,5,$col['estatus'],1,0,'C');
                $this->Cell(40,5,$col['nomb_tcont'],1,0,'C');
                $this->Ln();
                
            endforeach;
              

           }
           /*
            * negritas funcion para convertir a negritas los valores del arreglo
            * @access privado 
            * @param array 
            * @return array 
            * 
            */
           
           private function negritas($array=  array()){
               $resultado=array();
               if(is_array($array)):
                   
                   foreach ($array as $clave=>$valor):
                    $texto="[b]".$valor."[/b]";
                    $resultado[$clave]=preg_replace("/\[b\](.*?)\[\/b\]/is","<b>$1</b>",  strtoupper($texto));

//                       $resultado[$clave]="<b>".$valor."</b>";
                        
                   endforeach;
                   
                   return $resultado;
                   
               endif;
           }
           

        function ImprimirArchivo($opc,$title,$file,$datos,$nombre_pdf,$tipo_firma)
        { 
            
        
        
        
            //$this->PDF('P','mm','Letter');    
            //#Establecemos los márgenes izquierda, arriba y derecha: 
            $this->SetMargins(20, 25 , 20);
            #Establecemos el margen inferior: 
            $this->SetAutoPageBreak(true,25);        
            $this->SetTitle($title);

            //$this->SetY(65);   
            $this->AddPage();
            $this->post_header($datos['cuerpo']['nro_autorizacion']);
            $this->TituloArchivo($title);
            if($opc):

                $this->DatosPrincipales($datos['principales']);

            endif;
            $this->CuerpoArchivo($file,$datos['cuerpo']);

            if($title=='ACTA DE RECEPCION DE DOCUMENTOS')
            {
                $this->tabla_recepcion();
            }
            
//            $this->WriteHTML('You can<BR><P ALIGN="center">center a line</P>and add a horizontal rule:<BR><HR>');
            
            $this->DatosFirma($datos['firma'],$tipo_firma);

            $this->Output($nombre_pdf,'I');

        
        }
        
        function ImprimirTabla($cuerpo){
            $header=array('nombre','rif','estatus','tipo de contribuyente');
            $this->AddPage();
            $this->TablaBasica($header,$cuerpo); 
        }
}
/* application/libraries/Pdf.php */
