<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Planilla_c extends CI_Controller {

	
	public function index()
	{
//             if(empty($valor)){
//                 
//                 $valor=2;
//                 
//             }
             $data=array(
                 
                 'parametros'=>array('idusuario'=>$this->input->get('id_contribu'),'rutaimg'=>base_url()."/include/imagenes/logo.png"),
                 'archivo'=>'planilla_registro.jrxml',
                 
             );
//            $this->load->model('mod_contribuyente/buscar_planilla_m');
//          
//             $datos['infoplanilla']=  $this->load->buscar_planilla_m->datos_contribuyente($valor);
//            
//             $this->load->view('planilla_v',$datos);
              $this->load->view('reportes_v',$data);
             
	}
                function re_login(){

			$usuario	= trim($this->input->post('reusuario'));
			$clave		= $this->input->post('reclave');

			
				
				$data =$this->usuario_m->login_valido($usuario,$clave);
				if($data){
                       
                                     if ($data["validado"]=='t'):
                                        

					$response = array(
						"success"	=> TRUE//,
						//"message"	=> "Inicio de Sesion Exitoso"
					);
					
					$this->session->set_userdata( array(
						"logged"        => TRUE,
						"id"            => $data["id"],
						"usuario"	=> $data["usuario"],
						"nombre"	=> $data["nombre"]
						
					) );
                                        $this->session->set_userdata( array(
                                            "info_modulos" => $this->usuario_m->get_permisos($data["id"])
                                                ) );
                                     else:
 					$response = array(
						"success"	=> false,
						"message"	=> $data["validado"]."Verifique su correo electronico! Debe activar su cuenta!");                                        
                                     endif;
					
				}else{
					$response = array(
						"success"	=> FALSE,
						"message"	=> "Usuario o clave de acceso incorrectos"
					);
				}

			
			echo json_encode( $response );
		}	        
    
}
