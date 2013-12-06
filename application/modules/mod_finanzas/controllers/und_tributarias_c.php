<?php 
/*
 * Controlador: und_tributarias_c.php
 * Acción: contiene los procesos vinculados al sub-modulo Unidades Tributarias del modulo Finanzas
 * LCT - Diciembre 2013
 */

if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Und_tributarias_c extends CI_Controller {

	
	public function index()
	{
            $this->load->model('und_tributarias_m');
            $data=  $this->und_tributarias_m->buscar_und_tributarias();
            
            $datos=array('data'=>$data);
            $this->load->view('und_tributarias_v',$datos);
	}
        
//        cargar_dialog_new_undtributarias
        
    public function cargar_dialog_new_undtributarias()
	{
		//identificar 5 correspondiente al boton de agregar nuevas und tributarias
		if($this->input->post('identificador')==5)
		{
		
			//cargar la vista de und_tributarias_nuevo_v.php para agregar nuevos unidades

			  $datos=array();  
			  $vista=$this->load->view('und_tributarias_nuevo_v',$datos,true);
			  //echo $vista;
			  //die();
			  $respuesta=array(
						 'resultado'=>true,
						 'vista'=>$vista
				);
			  
			 
			  
			  echo json_encode($respuesta);
		} 
    }
        
        
	function agregar_undtributarias()
	{
		$array=array(                
						'anio'=>  $this->input->post('anio'),
						'valor'=>  $this->input->post('valor'),
						'ip'=> $_SERVER['REMOTE_ADDR'],
						'usuarioid'=>$this->session->userdata('id'),
						'fecha'=>  date('Y-m-d')
					 
					);
		
		$tabla='datos.undtrib';
		
		$this->load->library('operaciones_bd');
		$result=$this->operaciones_bd->insertar_BD(1,$array,$tabla,1);        
		echo json_encode($result);
	
	}




	//eliminar unidad tributaria
	function eliminar_undtributarias()
	{
		//obtiene el id
		$id= $this->input->post('id');
		//carga el modelo
		$this->load->model('mod_finanzas/und_tributarias_m');
		//asigna a una variable, la funcion und_tributarias
		$delete = $this->und_tributarias_m->eliminar_undtributarias($id);
		//condicion que muestra resultado verdadero o falso dependiendo de la ejecucion de la variable delete
		if($delete){
			$data=array('resultado'=>true);
		}else
		{
			$data=array('resultado'=>false);
		}
		echo json_encode($data);
	}
	
	

	//metodo sencillo para general excel
	function excel_und_tributarias(){
		
		$this->load->model('und_tributarias_m');

		$data=  $this->und_tributarias_m->buscar_und_tributarias();

		$datos=array('data'=>$data);

		$this->load->view('lista_undtrib_excel_v',$datos);
		
	}
	
        

}

