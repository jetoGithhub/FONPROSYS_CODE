<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
//sleep(2);
class Buscar_planilla_c extends CI_Controller {

	
	public function index()
	{
            
		$this->load->view('buscar_planilla_v');
	}
        
        public function desactivar_planilla()
	{
            
		$this->load->view('carga_planilla_v');
	}
        
        public function falta_doc_contribuyente()
	{
            
		$this->load->view('desactivar_planilla_v');
	}
        
         function buscar_planilla(){
           
               
          $rif= $this->input->post('rifcontri');
          $this->load->model('mod_gestioncontribuyente/buscar_planilla_m');
          
          $datos['infoplanilla']=  $this->load->buscar_planilla_m->datos_contribuyente(strtoupper($rif));
             
             if($datos['infoplanilla']['resultado']=='true'){
                
                 
                 $vista=$this->load->view('carga_planilla_v',$datos,true);
           
                $data=array(
                         'resultado'=>true,
                         'vista'=>$vista
                );
               
             
             }else{
                 
               $data=array('resultado'=>false);  
                 
             }
          
          echo json_encode($data);
        
            
        }
        
        function activar_contribuyente(){
            $conusuid=$this->input->post('id_usuario');
            $this->load->model('mod_gestioncontribuyente/buscar_planilla_m');          
            $result=  $this->load->buscar_planilla_m->activar_contribuyente($conusuid);
            
                $this->load->model('mod_gestioncontribuyente/lista_contribuyentes_general_m');
                $datos=$this->lista_contribuyentes_general_m->verifica_conusu($conusuid);
//                print_r($datos);die;
                $nombre=$datos[0]['nombre'];
                $rif=$datos[0]['rif'];
                $email=$datos[0]['email'];
                $cuerpo_html=$this->load->view('email_pdfs/html_email_activacion_contribu',array('contribuyente'=>$nombre),true);
                $asunto='Notificacion FONPROCINE';
                $respuesta_email=$this->funciones_complemento->envio_correo($nombre,$asunto,$cuerpo_html,$cuerpo_html,'fonprocine@gmail.com',$email); 
            
           echo json_encode($result); 
            
        }
        
        //funcion para cargar la vista del formulario para enviar las observaciones por falta de documentos
        public function vista_enviar_observacion()
	{

//identificar 1 correspondiente al boton de enviar observacion por falta de documentos - pasando los datos del contribuyente para capturar el correo
            if($this->input->post('identificador')==1)
            {
                //obtiene el id
                $rif= $this->input->post('rif');
                
                //carga el modelo 
                $this->load->model('mod_gestioncontribuyente/buscar_planilla_m');
//          
//                //asigna al arreglo datos 
                $datos['infoplanilla']=  $this->load->buscar_planilla_m->datos_contribuyente(strtoupper($rif));

                
                if($datos['infoplanilla']['resultado']=='true')
                {
                    //editar usuario
                    $vista=$this->load->view('desactivar_planilla_v',$datos,true);

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
        
        
        //enviar correo de notificacion de falta de documento
        function envia_correo(){
        //sleep(5);
            
            $this->load->library('funciones_complemento');
            $asunto='Observación Registor FONPROCINE';
//            $cuerpoCorreoHTML='Buenos  Días';
//            $cuerpoTEXT='Silvia Valladares Sandoval';
//            $correo='spvsr8@gmail.com';
            $mensaje=$this->input->get('mensaje');
            //datos funcionarios
            
             $query=array('tabla'=>'datos.usfonpro','where'=>array('id'=>  $this->session->userdata('id')),'respuesta'=>array('email,nombre')); 
             $result_query=$this->operaciones_bd->seleciona_BD($query);
            
            //obtiene el id
                $rif= $this->input->get('rif');
                $cuerpoCorreoHTML=$this->load->view('email_pdfs/html_email_enviado_registro',array('nombre_funcionario'=>$result_query['variable1'],'email_funcionario'=>$result_query['variable0'],'mensaje'=>$mensaje),true);
                
//                
                
                //carga el modelo 
                $this->load->model('mod_gestioncontribuyente/buscar_planilla_m');
//          
//                //asigna al arreglo datos 
                $datos['infoplanilla']=  $this->load->buscar_planilla_m->datos_contribuyente(strtoupper($rif));
                
                
                    if($this->funciones_complemento->envio_correo($datos['infoplanilla']['razonsocial'],$asunto,$cuerpoCorreoHTML,$cuerpoCorreoHTML,'fonprocine@gmail.com',$datos['infoplanilla']['email'])):
                        $response = array(
                            'success' => true,
                            'message'=>'Se ha enviado un correo con la observacion de los documentos enviados');
                    else:
                        $response = array(
                            'success' => false,
                            'message'=>'Error al enviar correo');                          
                    endif;                
                
            echo json_encode( $response );
    }
       
}
