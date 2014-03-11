<?php 
/*
 * Controlador: bancos_c.php
 * Acción: contiene los procesos vinculados al sub-modulo Bancos del modulo Finanzas
 * LCT - Diciembre 2013
 */

if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Bancos_c extends CI_Controller {

	
	public function index()
	{
            $this->load->model('bancos_m');
            $data=  $this->bancos_m->buscar_bancos();
            
            $datos=array('data'=>$data);
            $this->load->view('bancos_v',$datos);
	}
	
	
	
	
        
//        cargar_dialog_new_bancos
        
    public function cargar_dialog_new_bancos()
	{
		//identificar 5 correspondiente al boton de agregar banco nuevo 
		if($this->input->post('identificador')==5)
		{
		
			//cargar la vista de banco_nuevo_v.php para agregar nuevos Bancos

			  $datos=array();  
			  $vista=$this->load->view('bancos_nuevo_v',$datos,true);
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
	function agregar_bancos()
	{
		$this->load->model('mod_finanzas/bancos_m');
		
		$nombre_bancos=$this->input->post('nombre');
		
		$existe_banco=$this->bancos_m->verifica_bancos($nombre_bancos);
		
		//~ echo $existe_banco;
		//~ die();
		
		if(!$existe_banco)
		{
			$array=array(                
						'nombre'=>  $this->input->post('nombre'),
						'ip'=> $_SERVER['REMOTE_ADDR'],
						'usuarioid'=>$this->session->userdata('id'),
						'fecha_registro'=>date('Y-m-d')
				
						);
		
			$tabla='datos.bancos';
		
			$this->load->library('operaciones_bd');
			$result=$this->operaciones_bd->insertar_BD(1,$array,$tabla,1);  // aqui retorna true   

		} else
		{
			$result=array('resultado'=>FALSE,'mensaje'=>'La entidad bancaria no puede ser registrada, porque ya existe un Banco con ese nombre');
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
	
	
	/*la eliminacion sera logica, cambiando solo el campo bln_borrado a true, de esta forma el banco no podra ser visualizado 
    desde el listar y el usuario pensara que este fue eliminado; sin embargo, permanecera el registro oculto en la tabla*/
    
	function eliminar_bancos()
    {
		//obtiene el id
		$id= $this->input->post('id');

		$datos=array(

					'dw'=>array('id'=>$id),

					'dac'=>array('bln_borrado'=>'true'),
					'tabla'=>'datos.bancos'


			);
		$this->load->library('operaciones_bd');
		$result=$this->operaciones_bd->actualizar_BD(1,$datos);
		echo json_encode($result);
    }
	
        

}

