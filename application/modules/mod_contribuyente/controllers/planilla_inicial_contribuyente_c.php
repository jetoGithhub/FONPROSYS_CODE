<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Planilla_inicial_contribuyente_c extends CI_Controller {

	
	public function index()
	{
            
		$this->load->view('planilla_inicial_contribuyente_v');
	}
        
         function buscar_planilla(){
           
               
          $rif= $this->input->post('rifcontri');
          $this->load->model('mod_gestioncontribuyente/buscar_planilla_m');
          
          $datos=  $this->load->buscar_planilla_m->datos_contribuyente($rif);
             
             if($datos['resultado']=='true'){
                 
                 $vista=$this->load->view('planilla_inicial_contribuyente_v',$datos,true);
           
                $data=array(
                         'resultado'=>true,
                         'vista'=>$vista
                );
               
             
             }else{
                 
               $data=array('resultado'=>false);  
                 
             }
          
          echo json_encode($data);
        
            
        }
}
