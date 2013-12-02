<?php 
/*
 * Controlador: lista_extemp_calc_c
 * Proceso: Seleccionar los extemporaneos desde finanzas para aplicarles los calculos de los pagos que deben realizar por cada declaracion
 * LCT - 2013 
 */


if ( ! defined('BASEPATH')) exit('No direct script access allowed');


class Lista_extemp_calc_c extends CI_Controller {

	
	public function index()
	{
                $this->load->model('lista_extemp_calc_m');
                $condicion=array("contrib_calc.proceso"=>'enviado');
               /*parametro TRUE hace referencia al campo dlt_duplicado que recibe el modelo 
                * para determinar si elimina o no los datos duplicados en la consulta
                */
                $data=  $this->lista_extemp_calc_m->buscar_extemp_calc($condicion,TRUE);
            
                $datos=array('data'=>$data);
            
		$this->load->view('lista_extemp_calc_v',$datos);
	}
        
        
        function calcular_extemporaneo()
        {
            sleep(4);
            $this->load->model('lista_extemp_calc_m');
            
            $opc_tipo_multa = $this->input->post('opc_tipo_multa');
            $inf_extemp = $this->input->post('valores');

            $extemporaneo=  $this->lista_extemp_calc_m->buscar_decla_extemp($inf_extemp);
//            print_r($extemporaneo);die;
            $resultado=$this->funciones_complemento->calculos_finanzas($extemporaneo,$opc_tipo_multa,$inf_extemp);

                
            if($resultado)
            {
                
                    echo json_encode(array('resultado'=>TRUE));
                
            }  else {
                echo json_encode(array('resultado'=>False));
            }
           
        }
        
        //funcion para el proceso de generar un excel de los calculos de extemporaneos, desde la vista lista_extemp_calc_v 
        //metodo sencillo para general excel
        function excel_calculos(){
            
            $this->load->model('lista_extemp_calc_m');
            $condicion=array("contrib_calc.proceso"=>'enviado');
               /*parametro TRUE hace referencia al campo dlt_duplicado que recibe el modelo 
                * para determinar si elimina o no los datos duplicados en la consulta
                */
            $data=  $this->lista_extemp_calc_m->buscar_extemp_calc($condicion,TRUE);

            $datos=array('data'=>$data);

            $this->load->view('lista_extemp_calc_excel_v',$datos);
            
        }
        
        
        

        
}
