<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
session_start();
class Principal_c extends CI_Controller {

	
	public function index()
	{
            $data_relogin['controlador'] = base_url()."index.php/mod_contribuyente/ingreso_c/re_login";
            if (!$this->session->userdata('logged')):
                
                $this->load->view('vista_re_login',$data_relogin);
                 
            else:
            
                $padre=  $this->input->get('padre');

                $data=array(
                    'padre'=>$padre
                );
                    $this->load->view('pruebatabs_v',$data);
//                $this->load->view('vista_re_login',$data_relogin);
            endif;

	}
        
        
        
        function buscar_hijos(){
            
            $padre=  $this->input->post('padre');
            $this->load->model('mod_contribuyente/principal_m');
            $data=$this->principal_m->buscar_hijos($padre);
            echo json_encode($data);
            
        }
        
        
        //cargar inicio
        function cargar_vista_inicio_frontend()
        {
            $this->load->view('inicio_v',array('nombre'=>$this->session->userdata("nombre"))); 
            
        }
          
}
