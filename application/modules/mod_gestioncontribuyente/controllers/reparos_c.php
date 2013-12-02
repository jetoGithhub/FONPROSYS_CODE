<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
//sleep(2);
class Reparos_c extends CI_Controller  {

	
	public function index()
	{
             $this->load->model('mod_gestioncontribuyente/fiscalizacion_m');
             $data['data']=  $this->fiscalizacion_m->devuelve_reparos_creados();
             $this->load->view('reparos_v',$data);
	}
        
        function detalles_reparo(){
            
            $id_reparo=$this->input->post("id");
            $this->load->model('mod_gestioncontribuyente/fiscalizacion_m');
            $data['data']=  $this->fiscalizacion_m->devuelve_detalles_reparos($id_reparo);
            $vista=$this->load->view('detalles_reparos_v',$data,true);
            
            if($vista):
                
                echo json_encode(array('resultado'=>true,'vista'=>$vista));
            
            endif;
            
            
        }
        
        function activa_reparo_contribuyente()
        {
            sleep(3);
            $string=$this->input->post('ids');
            $fecha=$this->input->post('fnreparo');
            $recibido=  $this->input->post('recibidopor');
                
                $datos_eval = explode(':', $string);                    
                $id_reparo=$datos_eval[0]; 
                $id_conusu=$datos_eval[1];

            
            $this->load->model('mod_gestioncontribuyente/fiscalizacion_m');
            $data=  $this->fiscalizacion_m->activa_reparo_contribuyente($id_reparo,$fecha,$recibido);
            
            if($data['resultado']):
                
                $this->load->model('mod_gestioncontribuyente/lista_contribuyentes_general_m');
                        
                        $datos=$this->lista_contribuyentes_general_m->verifica_conusu($id_conusu);
                        $nombre=$datos[0]['nombre'];
                        $rif=$datos[0]['rif'];
                        $email=$datos[0]['email'];
//                        $cuerpo_html='<p>Sr representante de la empresa '.$nombre.',
//                                        por medio de la presente le informamos que
//                                        se le a cargado a su cuenta un reparo fiscal por el
//                                        incumplimiento en las declarciones.</p>
//                                        <br />
//                                        <p>para visualizar la informacion de los reparos 
//                                        dirijase a la siguiente direcion</p>';
//                        $asunto='Informacion de reparos fiscales FONPROCINE';
//                        $respuesta_email=$this->funciones_complemento->envio_correo($nombre,$asunto,$cuerpo_html,$cuerpo_html,'fonprocine@gmail.com',$email);
//                        $respuesta[]['email']=$respuesta_email.":".$id_conusu;
                         $cuerpo_html=$this->load->view('email_pdfs/html_email_notifcacion_reparo',array('contribuyente'=>$nombre),true);
                         $asunto='Notificacion FONPROCINE';
                         $respuesta_email=$this->funciones_complemento->envio_correo($nombre,$asunto,$cuerpo_html,$cuerpo_html,'fonprocine@gmail.com',$email); 
        

            endif;
            echo json_encode($data);
           
        }

}