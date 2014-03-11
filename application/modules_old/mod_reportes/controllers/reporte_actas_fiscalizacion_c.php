<?php


/**
 * controlador para el manejo de los reportes de actas de fizcalizacion
 *
 * @author jefferson lara 
 * @package fonprocine
 */
class Reporte_actas_fiscalizacion_c extends CI_Controller {

    
   function __construct() {
            parent::__construct();
            $this->load->model('mod_reportes/reporte_actas_fiscalizacion_m');
            $this->load->library('reportes_excel');
            
   }
   
   /*
    * 
    * @acces public
    * @param void
    * @return void
    * 
    */
   function index()
   {
      $data=array();
      $this->load->view('reporte_actas_fiscalizacion_v',$data);
   }
   /*
    * 
    * @acces public
    * @param post
    * @return json
    * 
    */
   
   function buscar_actas_fiscalizacion_anio()
   {
       $tipo_acta=$this->input->post('tipo_acta');
       $anio=$this->input->post('anio_acta');
       $data['datos']=  $this->reporte_actas_fiscalizacion_m->busca_actas_fiscalizacion($tipo_acta,$anio);
       $data['tipo']=$tipo_acta;
       $html=  $this->load->view('resultado_busqueda_actas_v',$data,true);
       echo json_encode(array('resultado'=>true,'html'=>$html));
//       print_r($data);die;
       
       
   }
   
   /*
    * 
    * @acces public
    * @param get
    * @return void
    * 
    */
   function genera_excel_actas_fiscalizacion()
   {
       $tipo_acta=$this->input->get('tipo_acta');
       $anio=$this->input->get('anio_acta');
       $text_encabezado=array( 'Fondo de Promoción y Financiamiento del Cine (FONPROCINE)',
                                  'Gerencia de Recaudación Tributaria');
       if($tipo_acta==0){
               $text_encabezado[]='AUTORIZACIONES FISCALES';
               $respuesta=array('nro_autorizacion','fecha_asignacion','fecha_autorizacion','contribuyente','tipo_contribuyente','anio_fiscalizar');
                $letras= 'CNAC/FONPROCINE/GFT/AF';
            }elseif ($tipo_acta==1) {
                $text_encabezado[]='ACTAS DE REQUERIMIENTOS DE DOCUMENTOS';
                $respuesta=array('nro_autorizacion','fecha_asignacion','fecha_requerimiento','contribuyente','tipo_contribuyente','anio_fiscalizar');
                $letras= 'CNAC/FONPROCINE/GFT/AR';
            }elseif ($tipo_acta==2){
                $text_encabezado[]='ACTAS DE RECEPCION DE DOCUMENTOS';
                $respuesta=array('nro_autorizacion','fecha_asignacion','fecha_recepcion','contribuyente','tipo_contribuyente','anio_fiscalizar');
                $letras= 'CNAC/FONPROCINE/GFT/ARD';
            }elseif ($tipo_acta==3){
                $text_encabezado[]='ACTAS FISCAL DE REPARO';
                $respuesta=array('numero_acta_rep','fecha_creacion_rep','fecha_recepcion','contribuyente','tipo_contribuyente','anio_fiscalizar');
                $letras= 'CNAC/FONPROCINE/GFT/AFR';
            }
       $cuerpo=  $this->reporte_actas_fiscalizacion_m->busca_actas_fiscalizacion($tipo_acta,$anio,$respuesta);
       foreach($cuerpo as $value){
              
              $array[]=array_values($value);
              
          }
       
       for($i=0;$i<count($array);$i++){
           
           array_unshift($array[$i],$letras);
           
       }
//       print_r($array);die;
        $titulo='Reportes de Actas de Fiscalizacion'; 
          
          $cabecera=array('A'=>'LETRAS.',
                          'B'=>'Nº',
                          'C'=>'FECHA DE ELABORACION',
                          'D'=> 'FECHA DE NOTIFICACION',
                          'E'=>'CONTRIBUYENTE',
                          'F'=>'TIPO DE CONTRIBUYENTE',
                          'G'=>'PERIODO A FISCALIZAR'                         
                          );
          $this->reportes_excel->genera_excel_basico($titulo,$text_encabezado,$cabecera,$array);
       
   }
   
}
?>
