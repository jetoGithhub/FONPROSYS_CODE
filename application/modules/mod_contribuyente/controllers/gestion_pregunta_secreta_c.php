<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
//sleep(3);
class Gestion_pregunta_secreta_c extends CI_Controller {

	
	public function index(){           
          
            $iduser=$this->session->userdata('id');
            
            $this->load->model('mod_contribuyente/contribuyente_m');
            
            $respuestacontri=$this->load->contribuyente_m->verificaContribuyente($coreeo='',$rif='',$iduser);
            
            $respuesta['preguntas']=$this->load->contribuyente_m->preguntaSecreta($id='');
            
            $respuesta['preactual']=$this->load->contribuyente_m->preguntaSecreta($respuestacontri[0]['pregsecrid']);
            
            $this->load->view('gestion_pregunta_secreta_v',$respuesta);
             
             
	}
        
        function actualizaPregunta(){
            
            $data=array('id'=>$this->session->userdata('id'),
                        'respuesta'=>$this->input->post('respactual')
                       );
            $respnueva= array('pregunta'=>$this->input->post('nombre_pregunta'),
                              'respactual'=>$this->input->post('respnueva')
                            );
            
            $this->load->model('mod_contribuyente/gestion_contrasena_m');
            $respuesta=$this->load->gestion_contrasena_m->actualiza_pregunta($data,$respnueva);
            
            if($respuesta){
                
               echo json_encode($data=array('resultado'=>'true','p'=>$respnueva['respactual']));
                
                
            }else{
                
              echo json_encode($data=array('resultado'=>'false','p'=>$respnueva['respactual']));  
                
            }
            
            
        }
        
    
}