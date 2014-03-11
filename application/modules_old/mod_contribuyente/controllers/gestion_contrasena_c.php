<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Gestion_contrasena_c extends CI_Controller {

	
	public function index(){           
          
             
            
             $this->load->view('gestion_contrasena_v');
             
             
	}
        
        function actualizaContrasena(){
            
            $data=array('id'=>$this->session->userdata('id'),
                        'password'=>do_hash($this->input->post('clvactual'))
                       );
            $clvnueva=$this->input->post('clvnueva');
            
            $this->load->model('mod_contribuyente/gestion_contrasena_m');
            $respuesta=$this->load->gestion_contrasena_m->actualiza_contrasena($data,$clvnueva);
            
            if($respuesta){
                
               echo json_encode($data=array('resultado'=>'true','p'=>$clvnueva));
                
                
            }else{
                
              echo json_encode($data=array('resultado'=>'false'));  
                
            }
            
            
        }
        
    
}