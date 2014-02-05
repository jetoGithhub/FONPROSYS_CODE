<?php
class Inicio_c extends CI_Controller {

	
	// --------------------------------------------------------------------
	
	/**
	 * 	Constructor -- Loads parent class
	 */
	function __construct() 
	{
		parent::__construct();

		
	}
    function index(){

        $data['titulo_pagina'] = "Ingreso al Sistema";
        
        $this->load->view('vista_cabecera',$data);
        $data['log'] = array();
        if ( !$this->session->userdata('logged') ){
            $data['log'][] = "No ha iniciado sesión";
            
            
            $this->load->view('vista_encabezado');
            $this->load->view('ingreso_v', $data);
            $this->load->view('vista_pie_pagina');            
            }else{
                $data['log'][] = "El usuario ya tiene sesion iniciada";
                $data['info'] = array (
                    "id_usuario"  =>  $this->session->userdata('id'),
                    "nombre"      =>  $this->session->userdata('nombre'),
                    "apellido"    =>  $this->session->userdata('apellido'),
                    "email"       =>  $this->session->userdata('email'),
                    "usuario"     =>  $this->session->userdata('usuario'),
                    "info_modulos"=>  $this->session->userdata("info_modulos")
                    
                );
                $this->load->view('sistema_v', $data);
                
                }
                $this->load->view('vista_pie');
        } 
        function monitorea_session()
        {
          if (!$this->session->userdata('logged')):
              
                echo json_encode(array('resultado'=>true));
          else:
              echo json_encode(array('resultado'=>FALSE));
          endif;
        }
      
    }
?>
