<?php 
/*
 * Controlador: cuentas_banc_c.php
 * Acción: contiene los procesos vinculados al sub-modulo Cuentas Bancarias del modulo Finanzas
 * LCT - Diciembre 2013
 */

if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Cuentas_banc_c extends CI_Controller {

	
	public function index()
	{
            $this->load->model('cuentas_banc_m');
            $data=  $this->cuentas_banc_m->buscar_cuentas_banc();
            
            $datos=array('data'=>$data);
            $this->load->view('cuentas_banc_v',$datos);
	}
        
//        cargar_dialog_new_cuentasbanc
        
    public function cargar_dialog_new_cuentasbanc()
	{
		$this->load->model('cuentas_banc_m');
		//identificar 5 correspondiente al boton de agregar nueva cuenta bancaria
		if($this->input->post('identificador')==5)
		{
			
			//cargar la vista de cuenta_banc_nueva_v.php para agregar nuevos cuentas bancarias

			  //$datos=array();  
			  $datos['bancos'] = $this->cuentas_banc_m->combo_bancos();
			  
			  $vista=$this->load->view('cuentas_banc_nuevo_v',$datos,true);
			  //echo $vista;
			  //die();
			  $respuesta=array(
						 'resultado'=>true,
						 'vista'=>$vista
				);
			 
			 echo json_encode($respuesta);
		} 
    }
        
        
	function agregar_cuentasbanc()
	{
            $this->load->model('cuentas_banc_m');
            $cuenta=$this->input->post('num_cuenta');
            $existe_cuenta=$this->cuentas_banc_m->verifica_numero_cuenta($cuenta);
		
		//~ echo $existe_banco;
		//~ die();
		
		if(!$existe_cuenta)
		{
                    $array=array(                
                                                    'bancoid'=>  $this->input->post('bancoid'),
                                                    'tipo_cuenta'=>  $this->input->post('tipo_cuenta'),
                                                    'num_cuenta'=>  $cuenta,
                                                    'ip'=> $_SERVER['REMOTE_ADDR'],
                                                    'usuarioid'=>$this->session->userdata('id'),
                                                    'fecha_registro'=>date('Y-m-d')

                                            );

                    $tabla='datos.bacuenta';

                    $this->load->library('operaciones_bd');
                    $result=$this->operaciones_bd->insertar_BD(1,$array,$tabla,1);        
                    
                }else{
                    
			$result=array('resultado'=>FALSE,'mensaje'=>'La cuenta bancaria no puede ser registrada, porque ya existe registrada');
                }
              echo json_encode($result);  
	
	}




	//eliminar cuentas bancarias
	function eliminar_cuentasbanc()
	{
            //obtiene el id
		$id= $this->input->post('id');

		$datos=array(

					'dw'=>array('id'=>$id),

					'dac'=>array('bln_borrado'=>'true'),
					'tabla'=>'datos.bacuenta'


			);
		$this->load->library('operaciones_bd');
		$result=$this->operaciones_bd->actualizar_BD(1,$datos);
		echo json_encode($result);
		//obtiene el id
//		$id= $this->input->post('id');
//		//carga el modelo
//		$this->load->model('mod_finanzas/cuentas_banc_m');
//		
//		$delete = $this->cuentas_banc_m->eliminar_cuentasbancarias($id);
//		//condicion que muestra resultado verdadero o falso dependiendo de la ejecucion de la variable delete
//		if($delete){
//			$data=array('resultado'=>true);
//		}else
//		{
//			$data=array('resultado'=>false);
//		}
//		echo json_encode($data);
	}
	
	
	//funcion para el proceso de generar un excel de las cuentas bancarias
	//metodo sencillo para general excel
	function excel_cuentas_banc(){
		
		$this->load->model('cuentas_banc_m');

		$data=  $this->cuentas_banc_m->buscar_cuentas_banc();

		$datos=array('data'=>$data);

		$this->load->view('lista_cuentasbanc_excel_v',$datos);
		
	}
	
        

}

