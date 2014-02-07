<?php

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 * Description of declaracion_sustitutiva_c
 *
 * @author viewmed
 */
class Declaracion_sustitutiva_c extends CI_Controller {
    //put your code here
    
    function __construct() {
        parent::__construct();
        $this->load->model('mod_contribuyente/contribuyente_m');
        $this->load->model('mod_contribuyente/declaracion_sustitutiva_m');
    }
    
    function index()
    {
        
        $data['tipo_contribuyente'] = $this->contribuyente_m->tipo_contribuyente();
        $this->load->view('declaracion_sustitutiva_v',$data);
    }
    
    function declarciones_asustituir()
    {

            $id=$this->input->post('tcontribuid');
            $conusuid=  $this->session->userdata('id');
            $html='<option value="" selected="selected" >Seleccione</option>';
                
              $declaraciones=  $this->declaracion_sustitutiva_m->declaraciones_para_sustituir($id,$conusuid);
              
              foreach ($declaraciones as $key => $value) {
                  
                  $html.="<option value='$value[id]'>$value[nudeclara]</option>";
               }
                

        echo json_encode(array('resultado'=>true,'html'=>$html));
    }
    
    
    function datos_declarcion_asustituir()
    {
       $id=$this->input->post('valor'); 
        $query=array(
            "tabla"=>'datos.declara',
            "where"=>array('id'=>$id),
            "respuesta"=>array('baseimpo','montopagar')
            
        );
        $result=  $this->operaciones_bd->seleciona_BD($query);
        
        echo json_encode(array('baseimpo'=>  $this->funciones_complemento->devuelve_cifras_unidades_mil($result['variable0']),'montopagar'=>$this->funciones_complemento->devuelve_cifras_unidades_mil($result['variable1'])));
        
    }
    
    function calculo_declaracion_sustitutiva()
    {
        $tcontribu=  $this->input->post();
        $decla= $this->input->post();
        $baseimpo=  $this->input->post();
        $nuevabase=  $this->input->post();
    }
}

?>
