<?php 
/*
 * Controlador: usuarios_c.php
 * Acción: contiene el proceso para listar en la vista usuarios_v.php los usuarios registrados
 * LCT - 2013
 */

if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Manejo_modulo_c extends CI_Controller {

	
	public function index()
	{
            $this->load->model('manejo_modulo_m');
            $data=  $this->manejo_modulo_m-> buscar_modulos();
            
            $datos=array('data'=>$data);
            $this->load->view('manejo_modulo_v',$datos);
	}
        
}
        