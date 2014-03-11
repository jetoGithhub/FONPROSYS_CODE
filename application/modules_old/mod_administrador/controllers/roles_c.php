<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Roles_c extends CI_Controller{
    
    function __construct() {
        parent::__construct();
        $this->load->model('mod_administrador/roles_m');
        $this->load->library('funciones_complemento');
    }
    
        public function index()
	{        
                $data['data']=  $this->roles_m->perfiles_registrados();  
//                print_r($data); die;
                $this->load->view('roles_v',$data);
                      
	}
         public function cargar_vista()
	{
            //identificar 5 correspondiente al boton de agregar nuevo usuario
            
         
                  $vista=$this->load->view('crear_perfil_v',$datos=array(),true);
                  $respuesta_ctrl=array('resultado'=>true,'vista'=>$vista);
                  echo json_encode($respuesta_ctrl);
            
    
        }
         public function carga_modulos()	{
            //identificar 5 correspondiente al boton de agregar nuevo usuario
            
            $this->load->model('manejo_modulo_m');
            $data=  $this->manejo_modulo_m-> buscar_modulos();
            
            $datos=array('data'=>$data);
                  
            $vista=$this->load->view('manejo_modulo_v',$datos,true);
            $id_perfil=  $this->input->post('id');
            $info_rol=  $this->roles_m->modulos_segun_rol($id_perfil); 
//            print_r($info_rol); die;
            $respuesta_ctrl=array('resultado'=>true,'vista'=>$vista,'modulos'=>$info_rol);
            echo json_encode($respuesta_ctrl);
            
    
        }
        
        function insertar_perfil(){
            $nombre_p=$this->input->post('nomperfil');
            $nombre_convertido=str_replace(" ","_", $nombre_p);
            $select=array(
                    "tabla"=>'seg.tbl_rol',
                    "where"=>array('tbl_rol.str_rol'=>$nombre_convertido,'tbl_rol.bln_borrado'=>'FALSE'),
                    "respuesta"=>array("id_rol")
            );
            $verifica=  $this->operaciones_bd->seleciona_BD($select);
            if(empty($verifica)){
                $datos=array('str_rol'=>$nombre_convertido,'str_descripcion'=>  $this->input->post('descripcion'));
                $tabla='seg.tbl_rol';

                $result=$this->operaciones_bd->insertar_BD(1,$datos,$tabla,0);
            }else{
                
                $result=array("resultado"=>FALSE);
            }
                      
                    echo json_encode($result);           
      
        
            
        }
        
        function gestion_perfiles(){
            $perfil=  $this->input->post('rol');
            $data=$this->input->post('modulo');
             

            $result=$this->roles_m-> inserta_modulos_perfil($perfil,$data);
            echo json_encode(array('resultado'=>$result));
             
//             print_r($datos);
        }
        
        function eliminar_perfil(){
            
            $perfil_id=  $this->input->post('perfil');
            $result=$this->roles_m-> eliminar_perfil($perfil_id);
            echo json_encode($result);
            
        }
}

?>