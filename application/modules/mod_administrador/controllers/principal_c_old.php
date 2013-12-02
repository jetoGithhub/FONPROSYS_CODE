<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Principal_c extends CI_Controller {

	
	public function index()
	{
            $padre=  $this->input->get('padre');
            $nombrerol=  $this->input->get('nombrerol');;
            $data=array(
                'padre'=>$padre,
                'nombrerol'=>$nombrerol
            );
		$this->load->view('pruebatabs_v',$data);
	}
        
        function insertar_hijo(){
            
            $array=array(                
                            'id_padre'=>  $this->input->post('idpadre'),
                            'str_nombre'=>  $this->input->post('nombreM'),
                            'str_descripcion'=>  $this->input->post('descripcionM'),
                            'str_enlace'=>  $this->input->post('urlM')
                         
                        );
            
            $tabla='seg.tbl_modulo';
            
        $this->load->library('operaciones_bd');
        $result=$this->operaciones_bd->insertar_BD(1,$array,$tabla,1);        
        echo json_encode($result);
            
        }
        
        function buscar_hijos(){
            
            $padre=  $this->input->post('padre');
            $this->load->model('mod_administrador/principal_m');
            $data=$this->principal_m->buscar_hijos($padre);
            echo json_encode($data);
            
        }
          function insertar_padre(){
            
            $array=array(                
                            'id_padre'=>  $this->input->post('idmpadre'),
                            'str_nombre'=>  $this->input->post('nombreMP'),
                            'str_descripcion'=>  $this->input->post('descripcionMP'),
                            'str_enlace'=>  $this->input->post('controladorMP')
                         
                        );           
            
            
        $this->load->model('mod_administrador/principal_m');
        $data=$this->principal_m->registro_modulo_padre($array,$this->input->post('nombre_grupo'));
        $result=array('resultado'=>$data);
        echo json_encode($result);
            
        }
        
        function cargar_dialog_abuelo_padre(){
            
            $data=array(
                'id'=>  $this->input->post('id'),
                'identificador'=>  $this->input->post('identificador')
                
                );
             $this->load->model('mod_administrador/principal_m');
             $data['slect_rol']=$this->principal_m->carga_select_rol();     
           
            $vista=$this->load->view('formdialog_v',$data,true); 
            
            $datos=array(
                
                'resultado'=>true,
                'vista'=>$vista
                
            );
            echo json_encode($datos);
               
        }
}
