<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
//sleep(2);
class Lista_contribuyentes_inactivos_c extends CI_Controller {

	
	public function index()
	{
                $this->load->model('lista_contribuyentes_inactivos_m');
                $id=  $this->session->userdata('id');
                $data=  $this->lista_contribuyentes_inactivos_m->buscar_usuarios_inactivos();
            
                $datos=array('data'=>$data);
            
		$this->load->view('lista_contribuyentes_inactivos_v',$datos);
	}
        
         function buscar_planilla($rif){
           

          $this->load->model('mod_gestioncontribuyente/buscar_planilla_m');
//          
          $datos['infoplanilla']=  $this->load->buscar_planilla_m->datos_contribuyente(strtoupper($rif));

//             
             if($datos['infoplanilla']['resultado']=='true'){
                
                 
                $this->load->view('carga_planilla_v',$datos);
           
               
        
            
                }
         }
        
        function activar_contribuyente(){
            
            $conusuid=$this->input->post('idcontri');
            $this->load->model('mod_gestioncontribuyente/buscar_planilla_m');          
            $result=  $this->load->buscar_planilla_m->activar_contribuyente($conusuid);
            
            
                $this->load->model('mod_gestioncontribuyente/lista_contribuyentes_general_m');
                $datos=$this->lista_contribuyentes_general_m->verifica_conusu($conusuid);
                print_r($datos);die;
                $nombre=$datos[0]['nombre'];
                $rif=$datos[0]['rif'];
                $email=$datos[0]['email'];
                $cuerpo_html=$this->load->view('email_pdfs/html_email_activacion_contribu',array('contribuyente'=>$nombre),true);
                $asunto='Notificacion FONPROCINE';
                $respuesta_email=$this->funciones_complemento->envio_correo($nombre,$asunto,$cuerpo_html,$cuerpo_html,'fonprocine@gmail.com',$email); 
            
            
            echo json_encode($result); 
            
        }
}