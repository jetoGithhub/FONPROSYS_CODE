<?php 
/*
 * Controlador: gestion_usuario_c.php
 * Acción: contiene procesos del modulo gestion de usuarios. Actualizar datos, 
 * Cambiar contraseña y Cambiar pregunta secreta
 * LCT - 2013
 */

if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Gestion_usuario_c extends CI_Controller {

	
	
        /*funcion para cargar el modelo y pasarle el la captura del id del usuario logueado y asi
         * mostrar los datos correspondientes en la vista gestion_editar_usuario_v 
         */
        public function index()
	{
            $this->load->model('mod_administrador/gestion_usuario_m');
            $data=$this->gestion_usuario_m->ver_datos_usuarios($this->session->userdata('id'));
            
	    $this->load->view('gestion_editar_usuario_v',$data);
//            print_r($data);
        }
        
        /* Actualizar datos usuarios,
         * implementado el modelo generico operaciones_bd
         */
        function actualizarDatos() 
        {
            
            $datos=array(

                        'dw'=>array('id'=>$this->input->post('id')),
                        
                        'dac'=>array('nombre'=>$this->input->post('nombre'),
                                               'email'=>$this->input->post('email'), 
                                               'telefofc'=>$this->input->post('telefofc')
                                            ),
                        'tabla'=>'datos.usfonpro'


                );

            $this->load->library('operaciones_bd');
            $result=$this->operaciones_bd->actualizar_BD(1,$datos);
            echo json_encode($result);
        }

        
        
        /*
         * funciones para el modulo de cambiar contraseña
         */
        
        //cargar vista
        function frm_cambio_contrasenia()
	{
            $this->load->model('mod_administrador/gestion_usuario_m');
            $data=$this->gestion_usuario_m->ver_datos_usuarios($this->session->userdata('id'));
            
	    $this->load->view('gestion_contrasenia_usuario_v',$data);
//            print_r($data);
        }
        
        //funcion para la actualizacion de la contraseña - llamando el modelo gestion_contrasena_m
        function actualizarContrasenia(){
            
            $data=array('id'=>$this->session->userdata('id'),
                        'password'=>do_hash($this->input->post('clvactual'))
                       );
            $clvnueva=$this->input->post('clvnueva');
            
            $this->load->model('mod_administrador/gestion_usuario_m');
            $respuesta=$this->load->gestion_usuario_m->actualiza_contrasenia($data,$clvnueva);
            
            if($respuesta){
                
               echo json_encode($data=array('resultado'=>'true','p'=>$clvnueva));
                
                
            }else{
                
              echo json_encode($data=array('resultado'=>'false'));  
                
            }
            
            
        }
        
        
        /*
         * funciones para el modulo de cambiar contraseña
         */
        
        //cargar vista
        function frm_cambio_pregsecr()
	{
            $this->load->model('mod_administrador/gestion_usuario_m');
            $data=$this->gestion_usuario_m->ver_datos_usuarios($this->session->userdata('id'));
            
            $data['preguntas']=$this->load->gestion_usuario_m->preguntaSecreta($id='');
	    
            $data['preactual']=$this->load->gestion_usuario_m->preguntaSecreta($data['pregsecrid']);
            
            $this->load->view('gestion_pregunta_usuario_v',$data);
//            print_r($data);
            
        }
        
        
        //funcion para la actualizacion de la pregunta secreta de usuarios
        function actualizaPregunta(){
            
            $data=array('id'=>$this->session->userdata('id'),
                        'respuesta'=>$this->input->post('respactual')
                       );
            $respnueva= array('pregunta'=>$this->input->post('nombre_pregunta'),
                              'respactual'=>$this->input->post('respnueva')
                            );
            
            $this->load->model('mod_administrador/gestion_usuario_m');
            $respuesta=$this->load->gestion_usuario_m->actualiza_pregunta($data,$respnueva);
            
            if($respuesta){
                
               echo json_encode($data=array('resultado'=>'true','p'=>$respnueva['respactual']));
                
                
            }else{
                
              echo json_encode($data=array('resultado'=>'false','p'=>$respnueva['respactual']));  
                
            }
            
            
        }
        
}

        