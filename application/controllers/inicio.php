
<?php
class Inicio extends CI_Controller {

	
	// --------------------------------------------------------------------
	
	/**
	 * 	Constructor -- Loads parent class
	 */
	function __construct() 
	{
		parent::__construct();

		$this->load->model("modelo_usuario");
	}
    function index()
    {

        $data['titulo_pagina'] = "Ingreso al Sistema";
        
        $this->load->view('vista_cabecera',$data);
        
        $data['log'] = array();
        if ( !$this->session->userdata('logged') ){
            $data['log'][] = "No ha iniciado sesión";
            $this->load->view('vista_encabezado');
            $this->load->view('vista_ingreso', $data);
            $this->load->view('vista_pie_pagina');
         }else{
                $data['log'][] = "El usuario ya tiene sesion iniciada";
                $data['info'] = array (
                    "id_usuario"  =>  $this->session->userdata('id'),
                    "nombre"      =>  $this->session->userdata('nombre'),
                    "apellido"    =>  $this->session->userdata('apellido'),
                    "email"       =>  $this->session->userdata('email'),
                    "usuario"     =>  $this->session->userdata('usuario'),
                    "ingreso_sistema"  =>  $this->session->userdata('ingreso_sistema'),
                    "info_modulos"=>  $this->session->userdata("info_modulos")
                    
                );

                //en la variable verificar se carga la funcion que retorna el valor de ingreso_sistema del usuario que se esta logueando
                $verificar = $this->modelo_usuario->verificar_primer_ingreso($this->session->userdata('id'));

  
                if($verificar['ingreso_sistema']=="f")
				{
					$this->load->model('pregunta_secreta_m');
					
					$data['preguntaSecreta'] = $this->pregunta_secreta_m->preguntaSecreta();
					
					$this->load->view('ingreso_sist_preg_secreta',$data);
				
				} else if($verificar['ingreso_sistema']=="t")
				{
					$this->load->view('vista_sistema', $data);
				
				}
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
