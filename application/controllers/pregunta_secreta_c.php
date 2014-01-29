<?php 
/*
 * Controlador: pregunta_secreta_c.php
 * Acción: contiene procesos para registrar la pregunta secreta en el primer logueo de un usuario 
 * LCT - Agosto 2013
 */

if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Pregunta_secreta_c extends CI_Controller {
	
		function index()
		{
			$this->session->sess_destroy(); 
			$this->load->view('vista_ingreso'); 
		}
	

//funcion para la actualizacion de la pregunta secreta de usuarios
        function registrarPregunta(){
//            sleep(5);
            $data=array(

                        'dw'=>array('id'=>$this->input->post('identificador')),
                        
                        'dac'=>array('pregsecrid'=>$this->input->post('pregsecrid'),
                                     'respuesta'=>$this->input->post('respuesta'),
                                     'ingreso_sistema'=>$this->input->post('ingreso_sistema'), 
                                    ),
                        'tabla'=>'datos.usfonpro'


                );

            $this->load->library('operaciones_bd');
            $result=$this->operaciones_bd->actualizar_BD(1,$data);
            echo json_encode($result);
            
            
        }

        
}

        
