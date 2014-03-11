<?php
 
class Tipo_contribuyente_c extends CI_Controller {
    
    public function index()
    {
        $this->load->model('tipo_contribuyente_m');
        $data['data']=  $this->tipo_contribuyente_m->trae_registro_tcontribu($this->session->userdata('id'));
        $this->load->view('tipo_contribuyente_v',$data);
        
    }
    
   
    
    
}
 
   