<?php 
/*
 * Controlador: usuarios_c.php
 * Acción: contiene el proceso para listar en la vista usuarios_v.php los usuarios registrados
 * LCT - 2013
 */

if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Usuarios_c extends CI_Controller {

	
	public function index()
	{
            $this->load->model('usuarios_m');
            $data=  $this->usuarios_m->buscar_usuarios();
            
            $datos=array('data'=>$data);
            $this->load->view('usuarios_v',$datos);
	}
        
}
        