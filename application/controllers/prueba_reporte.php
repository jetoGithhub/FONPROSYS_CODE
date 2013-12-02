<?php
    
class Prueba_reporte extends CI_Controller {

	
       
	// --------------------------------------------------------------------
	
	/**
	 * 	Constructor -- Loads parent class
	 */
	function __construct() 
	{
		parent::__construct();

		
	}
        
        function index(){
            
            $this->load->library('funciones_complemento');
            if($this->funciones_complemento->envio_correo('jefferson','prueba','<p><h2>holaaa</h2></p>','prueba','jetox21@gmail.com','jetox21@gmail.com')){
                
                echo'siiiiii';
                
            }else{
                
                echo 'nooooo';
            }
            
//            $config['protocol']    = 'smtp'; 
//        $config['smtp_host']    = 'ssl://smtp.gmail.com'; 
//        $config['smtp_port']    = '465'; 
//        $config['smtp_timeout'] = '5'; 
//        $config['smtp_user']    = 'fonprocine@gmail.com'; 
//        $config['smtp_pass']    = 'fonprocine.123'; 
//        $config['charset']    = 'utf-8'; 
//        $config['newline']    = "\r\n"; 
//        $config['mailtype'] = 'html'; // or html 
////        $config['validation'] = TRUE; // bool whether to validate email or not       
//        
//        //INICIALIZACION DE VARIABLES DE CONFIGURACION DEL SERVIDOR DE CORREO
//        $this->email->clear();
//        $this->email->initialize($config); 
// 
//        
//        //ENVIO Y EVALUACION DE CORREO
//        $this->email->from('jetox21@gmail.com','jefferosn'); 
//        $this->email->to('jetox21@gmail.com');
//        $this->email->subject('prueba'); 
//        $this->email->message('<h2>prueba</h2>');
//        $this->email->set_alt_message('prueba');    
// 
//         
//        try{
//            if($this->email->send() === false) :
//                return false;
//            throw new Exception("Error al Enviar en correo !");
// 
//            else:
//                return true;
//            throw new Exception("exito al Enviar en correo !");
//            endif;
//
//            }
//            catch (Exception $e){
//                //$response['mensaje'] = $e->getMessage();
//                //print(json_encode($response));
//                
//                }
//        //echo $this->email->print_debugger();      
//            
//            
//        }


        function reporte(){
            
//            $this->load->helper('generareporte');
//           genera_reporte_pdf('report5.jrxml');

           
            
        }
}
}
        
?>