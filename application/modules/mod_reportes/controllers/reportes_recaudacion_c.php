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
                    
                    
                    break;
            }
            
            $data['datos']=$this->reportes_recaudacion_m->datos_reporte_rise($where);
            $html=$this->load->view('mod_reportes/reportes_rise_v',$data,true);          
                
            $json=array('resultado'=>TRUE,'html'=>$html);
            
            echo json_encode($json);
//            print_r($data);die;
            
        }
        
        function generar_reporte_rise()
        {
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
          $this->funciones_complemento->genera_excel_basico($titulo,$text_encabezado,$cabecera);
            
        }
        
      
        
}

        