<?php

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 * Description of reportes_concilios_bancarios_c
 *
 * @author jetox
 */
class Reportes_concilios_bancarios_c extends CI_Controller {
    
    
    
    function __construct() {
            parent::__construct();
            $this->load->model('mod_reportes/reportes_concilios_bancarios_m');
            $this->load->library('reportes_excel');
            
    }
    
    
    
    function index()
    {
        $data['tipo_contribu']=  $this->reportes_concilios_bancarios_m->devuelve_tipo_contribuyente();
        $this->load->view('busqueda_concilios_bancarios_v',$data);
    }
     /*
         * funcion para mostrar los datos del reporte de rises de recaudacion
         * 
         * @acces public
         * @params void
         * @return json
         * 
         */
        public function reporte_conciliaciones($tipo)
	{
            
            switch ($tipo) {
                case 0://busquedda simple
                        $tipo_estado=  $this->input->post('tipo_estado');
                        $tipo_pago=$this->input->post('tipo_pago');
                        $anio=  $this->input->post('anio_concilio');
                        if($tipo_pago==0):
                            
                                switch ($tipo_estado) {
                                    case 0:
                                            $where=array('anio_calendario'=>$anio);
                                        break;
                                    case 1:
                                        $where=array('cobrada'=>'SI','anio_calendario'=>$anio);
                                        break;
                                    case 2:
                                        $where=array('cobrada'=>'NO','anio_calendario'=>$anio);
                                        break;
                                    
                                }
                               $tipo=$tipo_pago;
                               $devuelve=array('rif','contribuyente','nombre_tcon','tipe','periodo','cobrada');
                            else:
                               switch ($tipo_estado) {
                                    case 0:
                                            $where=array('anio_calendario'=>$anio,'tipo_multa'=>$tipo_pago);
                                        break;
                                    case 1:
                                        $where=array('cobrada'=>'SI','anio_calendario'=>$anio,'tipo_multa'=>$tipo_pago);
                                        break;
                                    case 2:
                                        $where=array('cobrada'=>'NO','anio_calendario'=>$anio,'tipo_multa'=>$tipo_pago);
                                        break;
                                    
                                }
                               $tipo=$tipo_pago;
                               $devuelve=array('rif','contribuyente','nombre_tcon','tipe','periodo','cobrada'); 
                                                     
                                
                            
                        endif;
                    break;

                case 1://busqueda avanzada
                        $tipo_filtro=  $this->input->post('tipo_filtro');
                        $tipo_pago=$this->input->post('tipo_pago2');
                        $anio=  $this->input->post('anio_concilio2');
                        if($tipo_pago==0):
                            
                                switch ($tipo_filtro) {
                                    case 0:
                                            $where=array('anio_calendario'=>$anio,'rif'=>  $this->input->post('rif'));
                                        break;
                                    case 1:
                                        $where=array('tipocontid'=>  $this->input->post('tipo_contribu'),'anio_calendario'=>$anio);
                                        break;
                                    case 2:
                                        $where=array('inicio_calendario >='=>$this->input->post('fecha-desde'),'fin_calendario <='=>$this->input->post('fecha-hasta'));
                                        break;
                                    
                                }
                               $tipo=$tipo_pago;
                               $devuelve=array('rif','contribuyente','nombre_tcon','tipe','periodo','cobrada');
                            else:
                              switch ($tipo_filtro) {
                                    case 0:
                                            $where=array('anio_calendario'=>$anio,'rif'=>  $this->input->post('rif'),'tipo_multa'=>$tipo_pago);
                                        break;
                                    case 1:
                                        $where=array('tipocontid'=>  $this->input->post('tipo_contribu'),'anio_calendario'=>$anio,'tipo_multa'=>$tipo_pago);
                                        break;
                                    case 2:
                                        $where=array('fechaelaboracion >='=>$this->input->post('fecha-desde'),'fechaelaboracion <='=>$this->input->post('fecha-hasta'),'tipo_multa'=>$tipo_pago);
                                        break;
                                    
                                }
                               $tipo=$tipo_pago;
                               $devuelve=array('rif','contribuyente','nombre_tcon','tipe','periodo','cobrada','banco','cuenta');  
                                
                                
                            
                        endif;  
                    
                    break;
            }
            
            $data['datos']=$this->reportes_concilios_bancarios_m->datos_busqueda_concilio($tipo,$where,$devuelve);
//            print_r($data); die;
            $html=$this->load->view('mod_reportes/resultado_busqueda_conciliacion_v',$data,true);          
//            print_r(array_values($data['datos'][0]));die;    
            $json=array('resultado'=>TRUE,'html'=>$html);
            
            echo json_encode($json);
//            print_r($data);die;
            
        }
        
        function generar_excel_concilio()
        {
//            print_r($this->input->get());die;
            $tipo=$this->input->get('tipo');
            switch ($tipo) {
                case 0://busquedda simple
                        $tipo_estado=$this->input->get('tipo_estado');
                        $tipo_pago=$this->input->get('tipo_pago');
                        $anio=$this->input->get('anio_concilio');
                        if($tipo_pago==0):
                            
                                switch ($tipo_estado) {
                                    case 0:
                                            $where=array('anio_calendario'=>$anio);
                                        break;
                                    case 1:
                                        $where=array('cobrada'=>'SI','anio_calendario'=>$anio);
                                        break;
                                    case 2:
                                        $where=array('cobrada'=>'NO','anio_calendario'=>$anio);
                                        break;
                                    
                                }
                                $t=$tipo_pago;
                                $devuelve=array('rif','contribuyente','nombre_tcon','periodo','anio_calendario','banco','cuenta','fechapago','cobrada','tipe');  
                            else:
                               switch ($tipo_estado) {
                                    case 0:
                                            $where=array('anio_calendario'=>$anio,'tipo_multa'=>$tipo_pago);
                                        break;
                                    case 1:
                                        $where=array('cobrada'=>'SI','anio_calendario'=>$anio,'tipo_multa'=>$tipo_pago);
                                        break;
                                    case 2:
                                        $where=array('cobrada'=>'NO','anio_calendario'=>$anio,'tipo_multa'=>$tipo_pago);
                                        break;
                                    
                                }
                               $t=$tipo_pago;
                               $devuelve=array('rif','contribuyente','nombre_tcon','periodo','anio_calendario','banco','cuenta','fechapago','cobrada','tipe');  
                                                     
                                
                            
                        endif;
                    break;

                case 1://busqueda avanzada
                        $tipo_filtro=  $this->input->get('tipo_filtro');
                        $tipo_pago=$this->input->get('tipo_pago2');
                        $anio=  $this->input->get('anio_concilio2');
                        if($tipo_pago==0):
                            
                                switch ($tipo_filtro) {
                                    case 0:
                                            $where=array('anio_calendario'=>$anio,'rif'=>  $this->input->get('rif'));
                                        break;
                                    case 1:
                                        $where=array('tipocontid'=>  $this->input->get('tipo_contribu'),'anio_calendario'=>$anio);
                                        break;
                                    case 2:
                                        $where=array('inicio_calendario >='=>$this->input->get('fecha-desde'),'fin_calendario <='=>$this->input->get('fecha-hasta'));
                                        break;
                                    
                                }
                               $t=$tipo_pago;
                                $devuelve=array('rif','contribuyente','nombre_tcon','periodo','anio_calendario','banco','cuenta','fechapago','cobrada','tipe');  
                            else:
                              switch ($tipo_filtro) {
                                    case 0:
                                            $where=array('anio_calendario'=>$anio,'rif'=>  $this->input->get('rif'),'tipo_multa'=>$tipo_pago);
                                        break;
                                    case 1:
                                        $where=array('tipocontid'=>  $this->input->get('tipo_contribu'),'anio_calendario'=>$anio,'tipo_multa'=>$tipo_pago);
                                        break;
                                    case 2:
                                        $where=array('fechaelaboracion >='=>$this->input->get('fecha-desde'),'fechaelaboracion <='=>$this->input->get('fecha-hasta'),'tipo_multa'=>$tipo_pago);
                                        break;
                                    
                                }
                               $t=$tipo_pago;
                               $devuelve=array('rif','contribuyente','nombre_tcon','periodo','anio_calendario','banco','cuenta','fechapago','cobrada','tipe');  
                                
                                
                            
                        endif;  
                    
                    break;
            }
//            print_r($where);die;
//            $data['datos']=$this->reportes_concilios_bancarios_m->datos_busqueda_concilio($t,$where,$devuelve);
//            print_r($data);die;
            $cuerpo=$this->reportes_concilios_bancarios_m->datos_busqueda_concilio($t,$where,$devuelve);
             foreach($cuerpo as $value){
              
              $array[]=array_values($value);
              
             }
//            print_r($cuerpo);die; 
          $titulo='Reportes de Conciliaciones Bancarias';
          
          $text_encabezado=array('Gerencia de Recaudación Impuesto FONPROCINE',
                                  'Fondo de Promoción y Financiamiento del Cine (FONPROCINE)',
                                  'Centro Nacional Autónomo de Cinematografía (CNAC)',
                                  'Conciliaciones Bancarias');
          
          $cabecera=array('A'=>'RIF.',
                          'B'=>'Contribuyente',
                          'C'=>'Tipo Contribuyente',
                          'D'=> 'Periodo',
                          'E'=>'Año',
                          'F'=>'Banco',
                          'G'=>'Cuenta Bancaria',
                          'H'=>'Fecha del Pago',
                          'I'=>'Cobrada',
                          );
                          
          $this->reportes_excel->genera_excel_basico($titulo,$text_encabezado,$cabecera,$array);
        }
    
}

?>
