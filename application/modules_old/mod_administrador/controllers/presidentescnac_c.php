<?php 
/*
 * Controlador: presidentescnac_c.php
 * Acción: contiene los procesos vinculados al sub-modulo Presidentes CNAC del modulo Administracion del Sistema
 * LCT - Diciembre 2013
 */

if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Presidentescnac_c extends CI_Controller {

	
	public function index()
	{
            $this->load->model('presidentescnac_m');
            $data=  $this->presidentescnac_m->buscar_presidentes();
            
            $datos=array('data'=>$data);
            $this->load->view('presidentescnac_v',$datos);
	}
	
	
	
	
        
//        cargar_dialog_new_bancos
        
    public function cargar_dialog_new_presidente()
	{
		//identificar 5 correspondiente al boton de agregar nuevo presidente 
		if($this->input->post('identificador')==5)
		{
		
			//cargar la vista de presidente_nuevo_v.php para agregar nuevos Presidentes

			  $datos=array();  
			  $vista=$this->load->view('presidente_nuevo_v',$datos,true);
			  //echo $vista;
			  //die();
			  $respuesta=array(
						 'resultado'=>true,
						 'vista'=>$vista
				);
			  
			 
			  
			  echo json_encode($respuesta);
		} 
    }
        
        
	//~ function agregar_bancos2()
	//~ {
		//~ $array=array(                
						//~ 'nombre'=>  $this->input->post('nombre'),
						//~ 'ip'=> $_SERVER['REMOTE_ADDR'],
						//~ 'usuarioid'=>$this->session->userdata('id'),
						//~ 'fecha_registro'=>date('Y-m-d')
				//~ 
					//~ );
		//~ 
		//~ $tabla='datos.bancos';
		//~ 
		//~ $this->load->library('operaciones_bd');
		//~ $result=$this->operaciones_bd->insertar_BD(1,$array,$tabla,1);        
		//~ echo json_encode($result);
	//~ 
	//~ }
	
	//funcion agregar bancos con la condicion de validar que no ingreses bancos repetidos
	function agregar_presidentes()
	{
		$this->load->model('mod_administrador/presidentescnac_m');
		
		//$nombre_bancos=$this->input->post('nombre');
		
		$existen_presidentes=$this->presidentescnac_m->verifica_presidente();
		
		//~ echo $existe_banco;
		//~ die();
                $array=array(                
                            'nombres'=> strtoupper($this->input->post('nombres')),
                            'apellidos'=> strtoupper($this->input->post('apellidos')),
                            'cedula'=>  strtoupper($this->input->post('cedula')),
                            'nro_decreto'=>  $this->input->post('nro_decreto'),
                            'nro_gaceta'=>  $this->input->post('nro_gaceta'),
                            'dtm_fecha_gaceta'=>  $this->input->post('dtm_fecha_gaceta'),
                            'ip'=> $_SERVER['REMOTE_ADDR'],
                            'usuarioid'=>$this->session->userdata('id'),

                            );
                $tabla='datos.presidente';
		if(!$existen_presidentes)
		{			
			$result=$this->operaciones_bd->insertar_BD(1,$array,$tabla,1);  // aqui retorna true   

		} else
		{
                        $bol=  $this->presidentescnac_m->inserta_presidente_activo($array);
                        if($bol):
                            $result=array('resultado'=>$bol,'mensaje'=>'Registro exitoso');
                            else:
                            $result=array('resultado'=>$bol,'mensaje'=>'Registro fallido');
                        endif;
			
		}    
		echo json_encode($result);
	
	}
	
	


//metodo sencillo para general excel de los bancos registrados
	function excel_bancos(){
		
		$this->load->model('bancos_m');

		$data=  $this->bancos_m->buscar_bancos();

		$datos=array('data'=>$data);

		$this->load->view('lista_bancos_excel_v',$datos);
		
	}
	

    
    //~ //agregar presidente, he inactivar todos los que ya esten registrados, quedando activo solo el nuevo presidente
	//~ function agregar_presidente_activo
	//~ {
		 //~ $array=array(                
						//~ 'nombres'=>  $this->input->post('nombres'),
						//~ 'apellidos'=>  $this->input->post('apellidos'),
						//~ 'cedula'=>  $this->input->post('cedula'),
						//~ 'nro_decreto'=>  $this->input->post('nro_decreto'),
						//~ 'nro_gaceta'=>  $this->input->post('nro_gaceta'),
						//~ 'dtm_fecha_gaceta'=>  $this->input->post('dtm_fecha_gaceta'),
						//~ 'bln_borrado'=>  'TRUE',
						//~ 'ip'=> $_SERVER['REMOTE_ADDR'],
						//~ 'usuarioid'=>$this->session->userdata('id'),
						//~ 'fecha_registro'=>date('Y-m-d')
					 //~ 
					//~ );
		//~ 
		//~ $tabla='datos.presidente';
		//~ 
		//~ $this->load->library('operaciones_bd');
		//~ $result=$this->operaciones_bd->insertar_BD(1,$array,$tabla,1);        
		//~ echo json_encode($result);	
		//~ 
	//~ }
	
        

}

