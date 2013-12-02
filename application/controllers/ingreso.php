<?php
	//session_start();

	
	
	class Ingreso extends CI_Controller{
		
		function __construct(){
			parent::__construct();

			$this->load->model("modelo_usuario");
                       
		}

		function index(){

			$usuario	= $this->input->post('usuario');
			$clave		= $this->input->post('clave');
			$codigo		= $this->input->post('codigo');

                        $verificacion = $this->modelo_usuario->login_valido($usuario,$clave);

//			include("include/librerias/securimage/securimage.php");
//			$captcha = new Securimage();
//			if( $captcha->check($codigo) ){
			
				
				
				if($verificacion){

                                    if($verificacion['inactivo']=='t'){
                                       $response = array(
						"success"	=> FALSE,
						"message"	=> "El usuario se Encuentra Inactivo en el sistema"
					);
                                    }else{
                       
                                         $data =$this->modelo_usuario->login_valido($usuario,$clave);
                                            $response = array(
                                                    "success"	=> TRUE//,
                                                    //"message"	=> "Inicio de Sesion Exitoso"
                                            );

                                            $this->session->set_userdata( array(
                                                    "logged"        => TRUE,
                                                    "id"            => $data["id"],
                                                    "usuario"	=> $data["usuario"],
                                                    "nombre"	=> $data["nombre"],
                                                    "ingreso_sistema"	=> $data["ingreso_sistema"]

                                            ) );
                                            $this->session->set_userdata( array(
                                                "info_modulos" => $this->modelo_usuario->get_permisos($data["id"])
                                                    ) );
                                    }
					
				}else{
					$response = array(
						"success"	=> FALSE,
						"message"	=> "Usuario o clave de acceso incorrectos"
					);
				}

//			}else{
//				$response = array(
//					"success"	=> FALSE,
//					"message"	=> "Codigo de verificacion incorrecto"
//				);
//			}
			
			echo json_encode( $response );
		}
		function re_login(){

			$usuario	= $this->input->post('reusuario');
			$clave		= $this->input->post('reclave');
			

			$verificacion = $this->modelo_usuario->login_valido($usuario,$clave);

			
				
				
				if($verificacion){
                       
                                     $data =$this->modelo_usuario->login_valido($usuario,$clave);
					$response = array(
						"success"	=> TRUE//,
						//"message"	=> "Inicio de Sesion Exitoso"
					);
					
					$this->session->set_userdata( array(
						"logged"        => TRUE,
						"id"            => $data["id"],
						"usuario"	=> $data["usuario"],
						"nombre"	=> $data["nombre"],
						"ingreso_sistema"	=> $data["ingreso_sistema"]
						
					) );
                                        $this->session->set_userdata( array(
                                            "info_modulos" => $this->modelo_usuario->get_permisos($data["id"])
                                                ) );

					
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
