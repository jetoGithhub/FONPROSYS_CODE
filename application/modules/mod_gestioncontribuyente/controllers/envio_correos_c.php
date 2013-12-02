<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

//~ Controlador para las funciones correspondientes 
//~ al envio de correos a los contribuyentes

class Envio_correos_c extends CI_Controller {

	//~ cargar vista para listar los contribuyentes activos con la opcion de enviar correos
	public function index()
	{
                        
			$this->load->model('envio_correos_m');
			$data=  $this->envio_correos_m->listar_contrib_correos_enviados($this->session->userdata('id'));
		
			$datos=array('data'=>$data);
            
			$this->load->view('envio_correos_v',$datos);
	}
	
	//funcion para el boton volver desde el listar de ver los correos electronicos enviados a el listar de los contribuyentes
	function volver_listar_contribu()
	{
			$this->load->model('envio_correos_m');
			$data=  $this->envio_correos_m->listar_contrib_correos_enviados($this->session->userdata('id'));
		
			$datos=array('data'=>$data);
            
			$this->load->view('envio_correos_v',$datos);
	}
	

	/* carga vista form_envio_correos_v que contiene el formulario para el envio de 
	 * correos, desde el modulo 'Envio Correo Electronico'; 
	 * el del modulo Envio de Correos, aplica un proceso similar, pero en este caso, no modificara el campo correo_enviado
	 * este debe mantenerse en true.
	 */
	function form_envio_correos(){

          $rif= $this->input->post('rif');
          $this->load->model('mod_gestioncontribuyente/envio_correos_m');
          
          $datos['infoplanilla']=  $this->load->envio_correos_m->datos_contribuyente(strtoupper($rif));
             
             if($datos['infoplanilla']['resultado']=='true'){
                
                 
                 $vista=$this->load->view('form_envio_correos_v',$datos,true);
           
                $data=array(
                         'resultado'=>true,
                         'vista'=>$vista
                );
               
             
             }else{
                 
               $data=array('resultado'=>false);  
                 
             }
          
          echo json_encode($data);
          
     }
     
     /* Aplica para cargar la vista form_envio_correo_contri_inaci_v que contiene
	  * el formulario para el envio de correos lista_cont del modulo 'Activacion del Contribuyente', 
	  * En el del Activacion de contribuyente, envia correo, guarda en la tabla de correos y además 
	  * modifica a true el campo correo_enviado de la tabla conusu; 
      */
     function form_envio_correo_contrib_inactivos(){

          $rif= $this->input->post('rif');
          $this->load->model('mod_gestioncontribuyente/envio_correos_m');
          
          $datos['infoplanilla']=  $this->load->envio_correos_m->datos_contribuyente(strtoupper($rif));
             
             if($datos['infoplanilla']['resultado']=='true'){
                
                 
                 $vista=$this->load->view('form_envio_correo_contri_inact_v',$datos,true);
           
                $data=array(
                         'resultado'=>true,
                         'vista'=>$vista
                );
               
             
             }else{
                 
               $data=array('resultado'=>false);  
                 
             }
          
          echo json_encode($data);
          
     }
     
     
     /* proceso para enviar correo al contribuyente seleccionado y registrar el envio 
      * en la tabla correos_enviados para el modulo Activacion de Contribuyente*/
     function proc_enviar_correo_contri_inact(){
			
			$email_contrib=$this->input->post('email_enviar');
			$asunto=$this->input->post('asunto_enviar');
			$mensaje=$this->input->post('contenido_enviar');
			
//			$this->load->library('email');
//
//			// configuracion para el envio de correos, usando como servidor de email, una cuenta de gmail
//			$config['protocol']    = 'smtp'; 
//			$config['smtp_host']    = 'ssl://smtp.gmail.com'; 
//			$config['smtp_port']    = '465'; 
//			$config['smtp_timeout'] = '5'; 
//			$config['smtp_user']    = 'fonprocine@gmail.com'; 
//			$config['smtp_pass']    = 'fonprocine.123'; 
//			$config['charset']    = 'utf-8'; 
//			$config['newline']    = "\r\n"; 
//			$config['mailtype'] = 'html'; // or html 
//	   
//			$this->email->clear();
//			$this->email->initialize($config); 
// 
//        
//			//ENVIO Y EVALUACION DE CORREO
//			$this->email->from('fonprocine@gmail.com', 'Fonprocine');
//			$this->email->to($email_contrib);
//			$this->email->subject($asunto);
//			$this->email->message($mensaje);
//			
//			$envio=$this->email->send();
////~ 
//			//~ 
//			//~ //si el correo fue enviado, procede a registrar en la tabla correos_enviados
//			if($envio==true)
//			{
			
					//registra en la tabla, una vez enviado el correo electronico
					$array=array(                
									'rif'=>  $this->input->post('rif'),
									'email_enviar'=>  $this->input->post('email_enviar'),
									'asunto_enviar'=>  $this->input->post('asunto_enviar'),
									'contenido_enviar'=>  $this->input->post('contenido_enviar'),
									'ip'=> $_SERVER['REMOTE_ADDR'],
									'usuarioid'=>$this->session->userdata('id'),
									'fecha_envio'=> date('Y-m-d H:i:s',now()),
									'procesado'=>  $this->input->post('procesado')
								);
					
					$tabla='datos.correos_enviados';
					$respuesta_insert=$this->operaciones_bd->insertar_BD(1,$array,$tabla,1);
                                        
                                        if($respuesta_insert['resultado']):
                                            $datos=array(

                                                'dw'=>array('rif'=>$this->input->post('rif')),

                                                'dac'=>array('correo_enviado'=>$this->input->post('correo_enviado')),
                                                'tabla'=>'datos.conusu'


                                            );
                                            $result=$this->operaciones_bd->actualizar_BD(1,$datos);
                                          
                            
                                            $query=array('tabla'=>'datos.usfonpro','where'=>array('id'=>  $this->session->userdata('id')),'respuesta'=>array('email','nombre')); 
                                            $result_query=$this->operaciones_bd->seleciona_BD($query);


                                           $cuerpoCorreoHTML=$this->load->view('email_pdfs/html_email_enviado_registro',array('nombre_funcionario'=>$result_query['variable1'],'email_funcionario'=>$result_query['variable0'],'mensaje'=>$mensaje),true);
                                           $this->funciones_complemento->envio_correo('FONPROCINE',$asunto,$cuerpoCorreoHTML,$cuerpoCorreoHTML,'fonprocine@gmail.com',$email_contrib);
                          
                
					
			
                                        else:
                                           $result=array('resultado'=>FALSE,'mensaje'=>'Se produjo un error al enviar el correo. Por favor, intente nuevamente <br /> '.$this->email->print_debugger());
                                       endif;
					
					
									
								
					//OJO - NO MUESTRA EL MENSAJE. NO SE COMO ARREGLAR ESO 
					
			
                        echo json_encode($result);
	 }
     
     
     /* proceso para enviar correo al contribuyente seleccionado y registrar el envio 
      * en la tabla correos_enviados para el modulo Envio de Correos*/
     function proc_enviar_correo(){
			
			$email_contrib=$this->input->post('email_enviar');
			$asunto=$this->input->post('asunto_enviar');
			$mensaje=$this->input->post('contenido_enviar');
			
//			$this->load->library('email');
//
//			// configuracion para el envio de correos, usando como servidor de email, una cuenta de gmail
//			$config['protocol']    = 'smtp'; 
//			$config['smtp_host']    = 'ssl://smtp.gmail.com'; 
//			$config['smtp_port']    = '465'; 
//			$config['smtp_timeout'] = '5'; 
//			$config['smtp_user']    = 'fonprocine@gmail.com'; 
//			$config['smtp_pass']    = 'fonprocine.123'; 
//			$config['charset']    = 'utf-8'; 
//			$config['newline']    = "\r\n"; 
//			$config['mailtype'] = 'html'; // or html 
//	   
//			$this->email->clear();
//			$this->email->initialize($config); 
// 
//        
//			//ENVIO Y EVALUACION DE CORREO
//			$this->email->from('fonprocine@gmail.com', 'Fonprocine');
//			$this->email->to($email_contrib);
//			$this->email->subject($asunto);
//			$this->email->message($mensaje);
//			
//			$envio=$this->email->send();

			
			//si el correo fue enviado, procede a registrar en la tabla correos_enviados
//			if($envio==true)
//			{
			
					//registra en la tabla, una vez enviado el correo electronico
					$array=array(                
									'rif'=>  $this->input->post('rif'),
									'email_enviar'=>  $this->input->post('email_enviar'),
									'asunto_enviar'=>  $this->input->post('asunto_enviar'),
									'contenido_enviar'=>  $this->input->post('contenido_enviar'),
									'ip'=> $_SERVER['REMOTE_ADDR'],
									'usuarioid'=>$this->session->userdata('id'),
									'fecha_envio'=> date('Y-m-d H:i:s',now()),
									'procesado'=>  $this->input->post('procesado')
								);
					
					$tabla='datos.correos_enviados';
					
					$this->load->library('operaciones_bd');
					$result=$this->operaciones_bd->insertar_BD(1,$array,$tabla,1);
                        if($result['resultado']){ 
                            
                            $query=array('tabla'=>'datos.usfonpro','where'=>array('id'=>  $this->session->userdata('id')),'respuesta'=>array('email','nombre')); 
                            $result_query=$this->operaciones_bd->seleciona_BD($query);

                           
                           $cuerpoCorreoHTML=$this->load->view('email_pdfs/html_email_enviado_registro',array('nombre_funcionario'=>$result_query['variable1'],'email_funcionario'=>$result_query['variable0'],'mensaje'=>$mensaje),true);
                           $this->funciones_complemento->envio_correo('FONPROCINE',$asunto,$cuerpoCorreoHTML,$cuerpoCorreoHTML,'fonprocine@gmail.com',$email_contrib);
                            $response=$result;  
                
					
			} else{
				 $response = array(
                                    'resultado' => false,
                                    'mensaje'=>"Se produjo un error al enviar el correo. Por favor, intente nuevamente");
			}
                        
                        echo json_encode($response);
	 }
	 
	 
	 //~ funcion cargar vista con el listar de los correos enviados por contribuyente
	 function listar_correos_enviados($rif){

		  //~ echo $rif;
		  //~ die();
          $this->load->model('mod_gestioncontribuyente/envio_correos_m');
          
          //~ $datos['infoplanilla']=  $this->load->envio_correos_m->datos_contribuyente(strtoupper($rif));
		  
		  $data=  $this->load->envio_correos_m->listar_correos_enviados_contrib(strtoupper($rif));
		  
		  //~ print_r($data);
		  //~ die();
		  
		  $datos=array('data'=>$data);
		  
		  $this->load->view('listado_correos_enviados_v',$datos);
		  
	 
	 }
	 
	 //~ cargar vista para ver datos especificos de un correo seleccionado por contribuyente

	function cargar_ver_correos(){

          $id= $this->input->post('id');
          $this->load->model('mod_gestioncontribuyente/envio_correos_m');
          
          $datos['infoplanilla']=  $this->load->envio_correos_m->ver_correo_contrib($id);
             
             if($datos['infoplanilla']['resultado']=='true'){
                
                 
                 $vista=$this->load->view('form_ver_correos_v',$datos,true);
           
                $data=array(
                         'resultado'=>true,
                         'vista'=>$vista
                );
               
             
             }else{
                 
               $data=array('resultado'=>false);  
                 
             }
          
          echo json_encode($data);
          
     }
     
     
     //proceso para enviar correo al contribuyente seleccionado y registrar el envio en la tabla correos_enviados
     function proc_ver_correo(){
            
            $array=array(

                        'dw'=>array('id'=>$this->input->post('id')),
                        'dac'=>array('procesado'=>$this->input->post('procesado')),
                        'tabla'=>'datos.correos_enviados'


                );
			
			//~ $tabla='datos.correos_enviados';
			
			$this->load->library('operaciones_bd');
			$result=$this->operaciones_bd->actualizar_BD(1,$array);        
			echo json_encode($result);

	 }

}
