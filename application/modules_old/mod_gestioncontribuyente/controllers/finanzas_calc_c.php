<?php 
/*
 * Controlador: finanzas_calc_c.php
 * Acción: contiene los procesos vinculados al modulo de finanzas
 * LCT - 2013
 */

if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Finanzas_calc_c extends CI_Controller {


        public function index()
	{
            $this->load->model('finanzas_calc_m');
            $data=  $this->finanzas_calc_m->buscar_extemporaneos();
            
            $datos=array('data'=>$data);
            $this->load->view('lista_extemp_calc_v',$datos);
	}

        
}

        