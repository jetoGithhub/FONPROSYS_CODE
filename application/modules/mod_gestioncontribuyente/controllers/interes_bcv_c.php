<?php 
/*
 * Controlador: interes_bcv_c.php
 * Acción: contiene los procesos vinculados al sub-modulo Interes BCV del modulo Finanzas
 * LCT - 2013
 */

if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Interes_bcv_c extends CI_Controller {

	
	public function index()
	{
            $this->load->model('interes_bcv_m');
            $data=  $this->interes_bcv_m->buscar_interes_bcv();
            
            $datos=array('data'=>$data);
            $this->load->view('interes_bcv_v',$datos);
	}
        
//        cargar_dialog_new_interesbcv
        
    public function cargar_dialog_new_interesbcv()
	{
		//identificar 5 correspondiente al boton de agregar nuevo interes bcv
		if($this->input->post('identificador')==5)
		{
		
			//cargar la vista de interes_bcv_nuevo_v.php para agregar nuevos intereses bcv

			  $datos=array();  
			  $vista=$this->load->view('interes_bcv_nuevo_v',$datos,true);
			  //echo $vista;
			  //die();
			  $respuesta=array(
						 'resultado'=>true,
						 'vista'=>$vista
				);
			  
			 
			  
			  echo json_encode($respuesta);
		} 
    }
        
        
	function agregar_interesbcv()
	{
		$array=array(                
						'anio'=>  $this->input->post('anio'),
						'tasa'=>  $this->input->post('tasa'),
						'ip'=> $_SERVER['REMOTE_ADDR'],
						'usuarioid'=>$this->session->userdata('id'),
						'mes'=>  $this->input->post('mes'),
					 
					);
		
		$tabla='datos.interes_bcv';
		
		$this->load->library('operaciones_bd');
		$result=$this->operaciones_bd->insertar_BD(1,$array,$tabla,1);        
		echo json_encode($result);
	
	}




	//eliminar usuarios
	function eliminar_interesbcv()
	{
		//obtiene el id
		$id= $this->input->post('id');
		//carga el modelo
		$this->load->model('mod_gestioncontribuyente/interes_bcv_m');
		//asigna a una variable, la funcion interes_bcv
		$delete = $this->interes_bcv_m->eliminar_interesbcv($id);
		//condicion que muestra resultado verdadero o falso dependiendo de la ejecucion de la variable delete
		if($delete){
			$data=array('resultado'=>true);
		}else
		{
			$data=array('resultado'=>false);
		}
		echo json_encode($data);
	}
	
	
	//funcion para el proceso de generar un excel de los calculos de extemporaneos, desde la vista lista_extemp_calc_v 
	//metodo sencillo para general excel
	function excel_interes_bcv(){
		
		$this->load->model('interes_bcv_m');

		$data=  $this->interes_bcv_m->buscar_interes_bcv();

		$datos=array('data'=>$data);

		$this->load->view('lista_bcv_excel_v',$datos);
		
	}
	
        

}

