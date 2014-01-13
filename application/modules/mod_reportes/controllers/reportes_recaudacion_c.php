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
//            $this->load->model('mod_reportes/reportes_recaudacion_m');
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
            
            $this->load->view($vista);
        }
    /*
         * funcion para mostrar los datos del reporte de rises de recaudacion
         * 
         * @acces public
         * @params void
         * @return json
         * 
         */
        public function reporte_rise_recaudacion()
	{
            
//            $data=$this->reportes_recaudacion_m->datos_rise($where=array());
            
	    $this->load->view('gestion_editar_usuario_v',$data);

        }
        
      
        
}

        