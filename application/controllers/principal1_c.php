<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Principal1_c extends CI_Controller {

	
	public function index()
	{
            if (!$this->session->userdata('logged')):
                $this->load->view('vista_re_login');
            else:
                $padre=  $this->input->get('padre');

                $data=array(
                    'padre'=>$padre
                );
                    $this->load->view('pruebatabs1_v',$data);
            endif;
	}
        
        function insertar_hijo(){
            $this->load->model('modelo_usuario');
            $array=array(                
                            'id_padre'=>  $this->input->post('idpadre'),
                            'str_nombre'=>  $this->input->post('nombreM'),
                            'str_descripcion'=>  $this->input->post('descripcionM'),
                            'str_enlace'=>  $this->input->post('urlM')
                         
                        );
            
            $tabla="seg.tbl_modulo";
            
//        $this->load->library('operaciones_bd');
            
        $result=$this->modelo_usuario->insertar_BD(1,$array,$tabla,1);        
        echo json_encode($result);
            
        }
}
