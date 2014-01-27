<?php 
/*
 * Controlador: reportes_recaudacion_c
 * Acción:controla la generacion de reportes para la gerencia de recaudacion
 * LCT - 2013
 */

if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Reportes_recaudacion_c extends CI_Controller {

	
        function __construct() {
            parent::__construct();
            $this->load->model('mod_reportes/reportes_recaudacion_m');
            $this->load->library('reportes_excel');
            
        }

        /*
         * funcion para montar la vistas principal de busqueda de los reportes
         * 
         * @acces public
         * @params string
         * @return void
         * 
         */
        public function index($vista)
        {
            $data['tipo_contribu']=  $this->reportes_recaudacion_m->devuelve_tipo_contribuyente();
            $this->load->view($vista,$data);
            
        }
    /*
         * funcion para mostrar los datos del reporte de rises de recaudacion
         * 
         * @acces public
         * @params void
         * @return json
         * 
         */
        public function reporte_rise_recaudacion($tipo)
	{
            
            switch ($tipo) {
                case 0://busquedda simple
                        $tipo_rise=  $this->input->post('tipo_rise');
                        $anio=  $this->input->post('anio_rise');
                        switch ($tipo_rise) {
                            case 0:
                                    $where=array('anio'=>$anio);
                                break;
                            case 1:
                                $where=array('notificada'=>'SI','anio'=>$anio);
                                break;
                            case 2:
                                $where=array('notificada'=>'NO','anio'=>$anio);
                                break;
                            case 3:
                                $where=array('cobrada'=>'SI','anio'=>$anio);
                                break;
                        }                   
                    break;

                case 1://busqueda avanzada
                    $tipo_filtro=  $this->input->post('tipo_filtro');
                    $anio=  $this->input->post('anio_rise2');
                    switch ($tipo_filtro) {
                            case 0:
                                    $where=array('anio'=>$anio,'rif'=>$this->input->post('rif'));
                                break;
                            case 1:
                                $where=array('tipo_contribu'=>$this->input->post('tipo_contribu'),'anio'=>$anio);
                                break;
                            case 2:
                                $where=array('anio'=>$anio,'fecha_multa >='=>$this->input->post('fecha-desde'),'fecha_multa <='=>$this->input->post('fecha-hasta'));
                                break;
                            
                        }   
                    
                    break;
            }
            
            $data['datos']=$this->reportes_recaudacion_m->datos_reporte_rise($where);
            $html=$this->load->view('mod_reportes/reportes_rise_v',$data,true);          
//            print_r(array_values($data['datos'][0]));die;    
            $json=array('resultado'=>TRUE,'html'=>$html);
            
            echo json_encode($json);
//            print_r($data);die;
            
        }
        
        function generar_reporte_rise()
        {
         $tipo=$this->input->get('tipo'); 
         switch ($tipo) {
                case 0://busquedda simple
                        $tipo_rise=  $this->input->get('tipo_rise');
                        $anio=  $this->input->get('anio_rise');
                        switch ($tipo_rise) {
                            case 0:
                                    $where=array('anio'=>$anio);
                                break;
                            case 1:
                                $where=array('notificada'=>'SI','anio'=>$anio);
                                break;
                            case 2:
                                $where=array('notificada'=>'NO','anio'=>$anio);
                                break;
                            case 3:
                                $where=array('cobrada'=>'SI','anio'=>$anio);
                                break;
                        }                   
                    break;

                case 1://busqueda avanzada
                    $tipo_filtro=  $this->input->get('tipo_filtro');
                    $anio=  $this->input->get('anio_rise2');
                    switch ($tipo_filtro) {
                            case 0:
                                    $where=array('anio'=>$anio,'rif'=>$this->input->get('rif'));
                                break;
                            case 1:
                                $where=array('tipo_contribu'=>$this->input->get('tipo_contribu'),'anio'=>$anio);
                                break;
                            case 2:
                                $where=array('anio'=>$anio,'fecha_multa >='=>$this->input->get('fecha-desde'),'fecha_multa <='=>$this->input->get('fecha-hasta'));
                                break;
                            
                        }    
                    
                    break;
            }
            
          $cuerpo=$this->reportes_recaudacion_m->datos_reporte_rise($where);
          foreach($cuerpo as $value){
              
              $array[]=array_values($value);
              
          }
//          print_r($array);die;
          $titulo='Reportes de RISE';
          
          $text_encabezado=array('Gerencia de Recaudación Tributaria',
                                  'Fondo de Promoción y Financiamiento del Cine (FONPROCINE)',
                                  'Centro Nacional Autónomo de Cinematografía (CNAC)',
                                  'Resolución de Imposición de Sanción por Extemporaneidad (RISE)');
          
          $cabecera=array('A'=>'Fecha Not.',
                          'B'=>'Mes de Notificación',
                          'C'=>'Resolución Nº',
                          'D'=> 'Contribuyente',
                          'E'=>'Tipo Contribuyente',
                          'F'=>'Monto Multa',
                          'G'=>'Monto Interés',
                          'H'=>'Cobrada',
                          'I'=>'Notificada',
                          );
          $this->reportes_excel->genera_excel_basico($titulo,$text_encabezado,$cabecera,$array);
            
        }
        
        function reporte_principal_recaudacion()
        {
            $data=  $this->reportes_recaudacion_m->datos_reporte_principal_recaudacion(array('anio'=>date('Y')));
            $datos['data']=  $this->ordena_datos_reporte_principal($data);
            $table['table']=$this->load->view('busqueda_reporte_pricipal_recau_v',$datos,true);
//            print_r($datos);die;
            $this->load->view('reporte_principal_recaudacion_v',$table);
            
        }
        
        private function ordena_datos_reporte_principal($array)
        {
            $meses=array('01','02','03','04','05','06','07','08','09','10','11','12');
            $data=array();
            if((!empty($array)) && (is_array($array))):
                // limpio el arreglo dejando solo los mese con sus valores
                    foreach ($array as $key => $value) {

                        $data[$value['mes']]=array(
                                                    'exhibidores'=>(empty($value['tot_1'])? 0 : $value['tot_1']),
                                                    'tvAbierta'=>(empty($value['tot_2'])? 0 : $value['tot_2']),
                                                    'tvSuscrip'=>(empty($value['tot_3'])? 0 : $value['tot_3']),
                                                    'distribuidores'=>(empty($value['tot_4'])? 0 : $value['tot_4']),
                                                    'ventaAlquiler'=>(empty($value['tot_5'])? 0 : $value['tot_5']),
                                                    'servProduccion'=>(empty($value['tot_6'])? 0 : $value['tot_6']),
                                                    'total_autoli'=>(empty($value['tot_anio'])? 0 : $value['tot_anio']),
                                                    'interise'=>(empty($value['interes_rise'])? 0 : $value['interes_rise']),
                                                    'interesrc'=>(empty($value['interes_rc'])? 0 : $value['interes_rc']),
                                                    'reparosaf'=>(empty($value['total_af'])? 0 : $value['total_af']),
                                                    'reparosrc'=>(empty($value['reparos_rc'])? 0 : $value['reparos_rc']),
                                                    );

                    }
                    //obtengo las claves de los valores del arreglo meses que existen en el arreglo data 
                    foreach ($data as $key => $value) {

                        foreach ($meses as $key2=>$mes) {
                            if($key==$mes):
                                $claves[]=$key2;
                            endif;
                        }

                    }
                    //elimino los meses del arreglo meses que existen en el arreglo data
                    foreach ($claves as $remove) {
                        unset($meses[$remove]);

                    }
                    // con los mese que quedaron despues de la eliminacion armo los valores por defecto para los demas meses
                    if(!empty($meses)):
                        foreach ($meses as $key => $value) {
                            $data[$value]=array(
                                                    'exhibidores'=>0,
                                                    'tvAbierta'=>0,
                                                    'tvSuscrip'=>0,
                                                    'distribuidores'=>0,
                                                    'ventaAlquiler'=>0,
                                                    'servProduccion'=>0,
                                                    'total_autoli'=>0,
                                                    'interise'=>0,
                                                    'interesrc'=>0,
                                                    'reparosaf'=>0,
                                                    'reparosrc'=>0,
                                                    ); 
                        } 
                        
                        
                    endif;
                    
                  
               endif;
               // ordeno el arreglo por sus claves de menor a mayor antes de retornarlo
               ksort($data);
            return $data;
            
        }
        function buscar_reporte_recaudacion()
        {
             $data=  $this->reportes_recaudacion_m->datos_reporte_principal_recaudacion(array('anio'=>  $this->input->post('anio')));
            $datos['data']=  $this->ordena_datos_reporte_principal($data);
            $html=$this->load->view('busqueda_reporte_pricipal_recau_v',$datos,true);
            echo json_encode(array('resultado'=>true,'html'=>$html));
            
        }
        
        function genera_excel_reporte_recaudacion(){
             $anio=$this->input->get('anio');
             $cabecera=array('A'=>'MES',
                            'B'=>'META AÑO'.$anio,
                            'C'=>'EXHIBIDORES',
                            'D'=> 'SEÑAL ABIERTA',
                            'E'=>'TV SUSCRIPCION',
                            'F'=>'DISTRIBUIDORES',
                            'G'=>'VENTA Y ALQUILER DE VIDEOGRAMAS',
                            'H'=>'PRODUCTORES',
                            'I'=>'RECAUDADO MENSUAL Bs F',
                            'J'=>'INTERES MORATORIO RISE',
                            'K'=>'INTERES FINANCIAMIENTO',
                            'L'=>'INTERES MORATORIOS RC',
                            'M'=>'INTERES EN CUENTA',
                            'N'=>'REPAROS FISCALES A.F.',
                            'O'=>'REPAROS FISCALES R.C.',
                            'P'=>'DEPOSITOS SIN IDENTIFICAR',
                            'Q'=>'DEPOSITOS IDENTIFICADOS',
                            'R'=>'EGRESO POR COMISIONES BANCARIAS',
                            'S'=>'RECAUDACION',
                            'T'=>'% CUMPLIMIENTO MENSUAL',
                          );
            $data=  $this->reportes_recaudacion_m->datos_reporte_principal_recaudacion(array('anio'=>  $anio));
            $datos=  $this->ordena_datos_reporte_principal($data);
             $this->reportes_excel->genera_excel_recaudacion($datos,$cabecera);
        }
      
        
}

        