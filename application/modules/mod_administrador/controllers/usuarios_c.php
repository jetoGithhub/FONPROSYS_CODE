<?php 
/*
 * Controlador: usuarios_c.php
 * Acción: contiene el proceso para listar en la vista usuarios_v.php los usuarios registrados
 * LCT - 2013
 */

if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Usuarios_c extends CI_Controller {

	
	public function index()
	{
            $this->load->model('usuarios_m');
            $data=  $this->usuarios_m->buscar_usuarios();
//            print_r($data);
            $datos=array('data'=>$data);
            $this->load->view('usuarios_v',$datos);
	}
        
        
        /*funcion para cargar las vistas del listar de usuario
         *Dependiendo del valor de la variable identificador que 
         *recibe se dirige a la condicion correspondiente  
         */
        public function cargar_vista()
	{
            //identificar 5 correspondiente al boton de agregar nuevo usuario
            if($this->input->post('identificador')==5)
            {
                //carga el modelo
                $this->load->model('usuarios_m');
                
                //asigna al arreglo datos el combo de grupos y de la pregunta secreta  
                $datos['comboGrupos'] = $this->usuarios_m->comboGrupos();
                $datos['preguntaSecreta'] = $this->usuarios_m->preguntaSecreta();
                $datos['departamentos'] = $this->usuarios_m->departamentos();
                $datos['cargos'] = $this->usuarios_m->cargos();
                
                  //agregar nuevo usuario
                //cargar la vista de crear_usuario_v.php
                  $vista=$this->load->view('crear_usuario_v',$datos,true);
                  $respuesta_ctrl=array('resultado'=>true,'vista'=>$vista);
                  echo json_encode($respuesta_ctrl);
            } 
            
            //identificador 1 correspondiente al boton de modificar usuario
            if($this->input->post('identificador')==1)
            {
                //obtiene el id
                $id= $this->input->post('id');
                
                //carga el modelo
                $this->load->model('usuarios_m');
                
                //asigna al arreglo datos el combo de grupos y de la pregunta secreta  
                $datos['infousuario']=  $this->load->usuarios_m->datos_usuario($id);
                $datos['comboGrupos'] = $this->usuarios_m->comboGrupos();
                
                //agregar al arreglo datos que trae a infousuaro, el id
                $datos['infousuario']['id']=$id;
//                print_r($datos);
                //si el arreglo es verdadero se cargara la vista editar_usuario_v.php
                if($datos['infousuario']['resultado']=='true')
                {
                    //editar usuario
                    $vista=$this->load->view('editar_usuario_v',$datos,true);

                    $data=array(
                             'resultado'=>true,
                             'vista'=>$vista
                    );


                }else{

                    $data=array('resultado'=>false);  

                }
                echo json_encode($data);
            }
            
            //identificador 1 correspondiente al boton de ver usuario
            if($this->input->post('identificador')==2)
            {
                //obtiene el id
                $id= $this->input->post('id');
                
                //carga el modelo
                $this->load->model('usuarios_m');
                
                //asigna al arreglo datos el combo de grupos y de la pregunta secreta  
                $datos['infousuario']=  $this->load->usuarios_m->datos_usuario($id);
                $datos['comboGrupos'] = $this->usuarios_m->comboGrupos();
                
                //agregar al arreglo datos que trae a infousuaro, el id
                $datos['infousuario']['id']=$id;
                //si el arreglo es verdadero se cargara la vista editar_usuario_v.php
                if($datos['infousuario']['resultado']=='true')
                {
                    //editar usuario
                    $vista=$this->load->view('ver_usuario_v',$datos,true);

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
        
        
        
        
        //agregar nuevos usuarios desde crear_usuario_v.php
        
//        public function insertar_usuario2()
//	 {
//             $datos=array(
//                            'login'=>  $this->input->post('login'),
//                            'password'=>  $this->input->post('login'),
//                            'nombre'=>  $this->input->post('nombre'),
//                            'cedula'=>  $this->input->post('cedula'),
//                            'email'=>  $this->input->post('email'),
//                            'telefofc'=>  $this->input->post('telefofc'),
//                            'inactivo'=>  $this->input->post('inactivo'),
//                            'pregsecrid'=>  $this->input->post('pregsecrid'),
//                            'respuesta'=>  $this->input->post('respuesta'),
//                            'ip'=> $_SERVER['REMOTE_ADDR']
//                 
//                        );
//             
//             
//             $tabla='datos.usfonpro';
//             $this->load->library('operaciones_bd');
//             $result=$this->operaciones_bd->insertar_BD(1,$datos,$tabla,1);
//             echo json_encode($result);
//
//	}
        
        //agregar nuevos usuarios en datos.usfonpro y el permiso seleccionado en seg.tbl_rol_usuario
        //en este caso se establecen funciones independientes en el modelo y no se trabaja con la 
        //funcion generica de insertar, debido a que la segunda tabla depende del registro en la 1era
        function insertar_usuario(){
            $this->load->model('mod_administrador/usuarios_m');
            $gerencia=$this->input->post('departamento');
            $cargo=$this->input->post('cargo');
            $var_email=$this->input->post('email');
            $exp_email = explode("@",$var_email);
            $query=array('tabla'=>'datos.cargos','where'=>array('id'=>$cargo),'respuesta'=>array('codigo_cargo'));
            $result_query=$this->operaciones_bd->seleciona_BD($query);
            $existe_gerente=FALSE;
            /*echo $exp_email[0]; // Imprime "usuario"

            die();*/
            if($result_query['variable0']=='C-001'){
               
                $existe_gerente=$this->usuarios_m->verifica_gerentes($gerencia,$cargo);
            }
			
            if(!$existe_gerente):
                $datos=array(
                                'login'=>  $exp_email[0],
                                //'password'=>  $this->input->post('login'),
                                'password'=>do_hash($exp_email[0]),
                                'nombre'=>  $this->input->post('nombre'),
                                'cedula'=>  $this->input->post('cedula'),
                                'email'=>  $this->input->post('email'),
                                'telefofc'=>  $this->input->post('telefofc'),
                                'departamid'=>  $this->input->post('departamento'),
                                'cargoid'=>  $this->input->post('cargo'),
                                'inactivo'=>  $this->input->post('inactivo'),
                                'ingreso_sistema' => 'f',
                                'ip'=>$this->input->ip_address()

                            );


                
                $data=$this->usuarios_m->insertar_usuario_admin($datos,$this->input->post('grupo'));
                $result=array('resultado'=>$data,'gerente_exis'=>$existe_gerente);
           else:
                $result=array('resultado'=>FALSE,'gerente_exis'=>$existe_gerente);
           endif;
        echo json_encode($result);
            
        }
        
        /*editar usuarios, solo campos grupos y estatus
         * Implementado el modelo generico operaciones_bd
         * correspondiente al caso de dicha funcion, donde
         * se pueden realizar update a mas de una tabla
         */
        function editar_usuario() 
        {

            
            $datos=array(
                /*arreglo de primera tabla donde dw corresponde a los where para realizar el update
                **y dac a las variables a modificar. Las que estan dentro del post, son las que obtiene 
                **del formulario*/
                'datos.usfonpro'=>array('dw'=>array('id'=>$this->input->post('id')
                                             ),
                                  'dac'=>array('inactivo'=>$this->input->post('inactivo')
                                            ),
                                  
                                ),
                 /*arreglo de segunda tabla donde dw corresponde a los where para realizar el update
                **y dac a las variables a modificar. Las que estan dentro del post, son las que obtiene 
                **del formulario*/
                'seg.tbl_rol_usuario'=>array('dw'=>array('id_usuario'=>$this->input->post('id')
                                             ),
                                     'dac'=>array('id_rol'=>$this->input->post('grupo')
                                            ),
                                )
                        
            );
            //cargar la libreria que contiene el modelo generico del update 
            $this->load->library('operaciones_bd');
            //los parametros corresponden al numero de la opcion que buscara en la libreria
            //en este caso es en 2
            $result=$this->operaciones_bd->actualizar_BD(2,$datos);
            echo json_encode($result);
        }
        
        //ver usuario
        
        
        //eliminar usuarios
        function eliminar_usuario()
        {
            //obtiene el id
            $id= $this->input->post('id');
            //carga el modelo
//            $this->load->model('mod_administrador/usuarios_m');
//            //asigna a una variable, la funcion eliminar_usuario
//            $delete = $this->usuarios_m->eliminar_usuario($id);
//            //condicion que muestra resultado verdadero o falso dependiendo de la ejecucion de la variable delete
//            if($delete){
//                $data=array('resultado'=>true);
//            }else
//            {
//                $data=array('resultado'=>false);
//            }
//            echo json_encode($data);

            $datos=array(

                        'dw'=>array('id'=>$id),

                        'dac'=>array('bln_borrado'=>'true'),
                        'tabla'=>'datos.usfonpro'


                );
            $this->load->library('operaciones_bd');
            $result=$this->operaciones_bd->actualizar_BD(1,$datos);
            echo json_encode($result);
        }
        
        
        //implementado la libreria generica de operaciones_bd
        function restablecer_contras_usuario() 
        {

            $datos=array(

                        'dw'=>array('id'=>$this->input->post('id')),
                        
                        'dac'=>array('password'=>do_hash($this->input->post('valorc'))),
                        'tabla'=>'datos.usfonpro'


                );
            $this->load->library('operaciones_bd');
            $result=$this->operaciones_bd->actualizar_BD(1,$datos);
            echo json_encode($result);
        }
                 
}

        
