<?php
	//session_start();

	
	
	class Ingreso_c extends CI_Controller{
		
		function __construct(){
			parent::__construct();

			$this->load->model("mod_contribuyente/usuario_m");
                       
		}

		function index(){

			$usuario	= trim(strtoupper($this->input->post('usuario')));
			$clave		= $this->input->post('clave');
			$codigo		= trim($this->input->post('codigo'));

				//$verificacion = $this->usuario_m->login_valido($usuario,$clave);

			include("include/librerias/securimage/securimage.php");
			$captcha = new Securimage();
			if($captcha->check($codigo) ){
			
				
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

			}else{
				$response = array(
					"success"	=> FALSE,
					"message"	=> "Codigo de verificacion incorrecto"
				);
			}
			
			echo json_encode( $response );
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
?>
