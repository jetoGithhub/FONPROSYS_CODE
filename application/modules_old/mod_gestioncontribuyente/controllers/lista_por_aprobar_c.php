<?php 
/*
 * Controlador: lista_por_aprobar_c
 * Proceso: Listar en el modulo de finanzas de las declaraciones que ya fueron calculadas
 * LCT - 2013 
 */


if ( ! defined('BASEPATH')) exit('No direct script access allowed');


class Lista_por_aprobar_c extends CI_Controller {

	
	public function index()
	{

            $this->load->view('lista_por_aprobar_v');
         }
         
         
         
       //carga vista con el listar dependiendo de la seleccion de la vista anterior (lista_por_aprobar_v)
         function consulta_extemp_calculados()
         {
              $this->load->model('lista_por_aprobar_m');
              
        //variables que estan pasando por la funcion ajax
              $rif          =  $this->input->post('rif');
              $fecha_desde  = $this->input->post('fecha_desde');
              $fecha_hasta  = $this->input->post('fecha_hasta');
              $valor_select = $this->input->post('valor_select');

              
              $data=array();
              switch ($this->input->post('tipo_calculo')) {
                  case 1:
                        if($valor_select=='reciente')
                        {
                              $fecha_sist =  date('d-m-Y');

                              $condiciones=array("to_char(multas.fechaelaboracion,'dd-mm-yyyy')"=>$fecha_sist,
                                                 "contrib_calc.proceso"=>'calculado',"detalles_contrib_calc.proceso"=>NULL);

                        }elseif ($valor_select=='todos') {

                              $condiciones= array("contrib_calc.proceso"=>'calculado',"detalles_contrib_calc.proceso"=>NULL);

                        }elseif($valor_select=='rif'){

          //                  echo 'Tu rif es:'.$rif;
                            $condiciones=array("conusu.rif"=>$rif,"contrib_calc.proceso"=>'calculado',"detalles_contrib_calc.proceso"=>NULL);

                        }elseif ($valor_select=='fecha') {

                            $condiciones=array("to_char(multas.fechaelaboracion,'dd-mm-yyyy')>="=>$fecha_desde, 
                                               "to_char(multas.fechaelaboracion,'dd-mm-yyyy')<="=>$fecha_hasta,
                                               "contrib_calc.proceso"=>'calculado',"detalles_contrib_calc.proceso"=>NULL);
                        }

                    $data['data']=  $this->lista_por_aprobar_m->lista_calculos_por_aprobar($condiciones);
                      break;
                  case 2:
                        if($valor_select=='reciente')
                        {
                              $fecha_sist =  date('d-m-Y');

                              $condiciones=array("to_char(multas.fechaelaboracion,'dd-mm-yyyy')"=>$fecha_sist,
                                                 "reparos.proceso"=>'calculado',"reparos.bln_sumario"=>'FALSE',"declara.proceso"=>null);

                        }elseif ($valor_select=='todos') {

                              $condiciones= array("reparos.proceso"=>'calculado',"reparos.bln_sumario"=>'FALSE',"declara.proceso"=>null);

                        }elseif($valor_select=='rif'){

          //                  echo 'Tu rif es:'.$rif;
                            $condiciones=array("conusu.rif"=>$rif,"reparos.proceso"=>'calculado',"reparos.bln_sumario"=>'FALSE',"declara.proceso"=>null);

                        }elseif ($valor_select=='fecha') {

                            $condiciones=array("to_char(multas.fechaelaboracion,'dd-mm-yyyy')>="=>$fecha_desde, 
                                               "to_char(multas.fechaelaboracion,'dd-mm-yyyy')<="=>$fecha_hasta,
                                               "reparos.proceso"=>'calculado',"reparos.bln_sumario"=>'FALSE',"declara.proceso"=>null);
                        }

                    $data['data']=  $this->lista_por_aprobar_m->lista_calculos_por_aprobar_culm($condiciones);
                      
                      break;
                  case 3:
                        if($valor_select=='reciente')
                        {
                              $fecha_sist =  date('d-m-Y');

                              $condiciones=array("to_char(multas.fechaelaboracion,'dd-mm-yyyy')"=>$fecha_sist,
                                                 "reparos.proceso"=>'calculado',"reparos.bln_sumario"=>'true',"declara.proceso"=>null);

                        }elseif ($valor_select=='todos') {

                              $condiciones= array("reparos.proceso"=>'calculado',"reparos.bln_sumario"=>'true',"declara.proceso"=>null);

                        }elseif($valor_select=='rif'){

          //                  echo 'Tu rif es:'.$rif;
                            $condiciones=array("conusu.rif"=>$rif,"reparos.proceso"=>'calculado',"reparos.bln_sumario"=>'true',"declara.proceso"=>null);

                        }elseif ($valor_select=='fecha') {

                            $condiciones=array("to_char(multas.fechaelaboracion,'dd-mm-yyyy')>="=>$fecha_desde, 
                                               "to_char(multas.fechaelaboracion,'dd-mm-yyyy')<="=>$fecha_hasta,
                                               "reparos.proceso"=>'calculado',"reparos.bln_sumario"=>'true',"declara.proceso"=>null);
                        }

                    $data['data']=  $this->lista_por_aprobar_m->lista_calculos_por_aprobar_culm($condiciones);
                      
                      break;    
                
              }
                //agregar claves al arreglo data para pasar las variables a la vista 
                $data['rif']          = $rif;         
                $data['fecha_desde']  = $fecha_desde; 
                $data['fecha_hasta']  = $fecha_hasta; 
                $data['$valor_select']=$valor_select;
                
                
              
              $listar_aprob_extemp=$this->load->view('lista_por_aprob_extemp_v',$data,true);
              
                    echo json_encode($listar_aprob_extemp);
              
         }
         
         
        function devolver_recaudacion()
        {
            sleep(3);
            $datos=explode(',',$this->input->post('valores'));
            $session=array('numero_session'=>$this->input->post('nsession'),'fecha_session'=>$this->input->post('fechasession'));
//            if(is_array($datos)):
//                 print_r($datos); die;
//                else:
//                 print_r(array('nooooooo')); die;
//            endif;
            
            $this->load->model('mod_gestioncontribuyente/lista_por_aprobar_m');             
            $data=  $this->lista_por_aprobar_m->devolver_recaudacion($datos,$this->input->post('tipo_calculo'),$session); 
                
           
            echo json_encode($data);
           
        }
        
        
        
      /*funcion para el proceso de generar un excel de los calculos por aprobar
      **de extemporaneos, desde la vista lista_por_aprobar_extemp_v 
       * la funcion es muy similar a la del listar de la vista principal lista_por_aprobar_extemp
       * la diferencia es que en el caso del excel se anexaron nuevas tablas al query en el modelo
       * para poder traer todos los datos que ameritaba el excel
       */
        function excel_calculos_extemp(){

             $this->load->model('lista_por_aprobar_m');
              
        //variables que estan pasando por la funcion ajax
              $rif          =  $this->input->get('rif');
              $fecha_desde  = $this->input->get('fecha_desde');
              $fecha_hasta  = $this->input->get('fecha_hasta');
              $valor_select = $this->input->get('valor_select');

              
              $data=array();
              switch ($this->input->get('tipo_calculo')) {
                  case 1:
                        if($valor_select=='reciente')
                        {
                              $fecha_sist =  date('d-m-Y');

                              $condiciones=array("to_char(multas.fechaelaboracion,'dd-mm-yyyy')"=>$fecha_sist,
                                                 "contrib_calc.proceso"=>'calculado',"detalles_contrib_calc.proceso"=>NULL);

                        }elseif ($valor_select=='todos') {

                              $condiciones= array("contrib_calc.proceso"=>'calculado',"detalles_contrib_calc.proceso"=>NULL);

                        }elseif($valor_select=='rif'){

          //                  echo 'Tu rif es:'.$rif;
                            $condiciones=array("conusu.rif"=>$rif,"contrib_calc.proceso"=>'calculado',"detalles_contrib_calc.proceso"=>NULL);

                        }elseif ($valor_select=='fecha') {

                            $condiciones=array("to_char(multas.fechaelaboracion,'dd-mm-yyyy')>="=>$fecha_desde, 
                                               "to_char(multas.fechaelaboracion,'dd-mm-yyyy')<="=>$fecha_hasta,
                                               "contrib_calc.proceso"=>'calculado',"detalles_contrib_calc.proceso"=>NULL);
                        }

                    $data=  $this->lista_por_aprobar_m->lista_calculos_por_aprobar_excel($condiciones);
                      break;
                  case 2:
                        if($valor_select=='reciente')
                        {
                              $fecha_sist =  date('d-m-Y');

                              $condiciones=array("to_char(multas.fechaelaboracion,'dd-mm-yyyy')"=>$fecha_sist,
                                                 "reparos.proceso"=>'calculado',"reparos.bln_sumario"=>'FALSE');

                        }elseif ($valor_select=='todos') {

                              $condiciones= array("reparos.proceso"=>'calculado',"reparos.bln_sumario"=>'FALSE');

                        }elseif($valor_select=='rif'){

          //                  echo 'Tu rif es:'.$rif;
                            $condiciones=array("conusu.rif"=>$rif,"reparos.proceso"=>'calculado',"reparos.bln_sumario"=>'FALSE');

                        }elseif ($valor_select=='fecha') {

                            $condiciones=array("to_char(multas.fechaelaboracion,'dd-mm-yyyy')>="=>$fecha_desde, 
                                               "to_char(multas.fechaelaboracion,'dd-mm-yyyy')<="=>$fecha_hasta,
                                               "reparos.proceso"=>'calculado',"reparos.bln_sumario"=>'FALSE');
                        }

                    $data=  $this->lista_por_aprobar_m->lista_calculos_por_aprobar_clum_excel($condiciones);
                      
                      break;
                  case 3:
                        if($valor_select=='reciente')
                        {
                              $fecha_sist =  date('d-m-Y');

                              $condiciones=array("to_char(multas.fechaelaboracion,'dd-mm-yyyy')"=>$fecha_sist,
                                                 "reparos.proceso"=>'calculado',"reparos.bln_sumario"=>'true');

                        }elseif ($valor_select=='todos') {

                              $condiciones= array("reparos.proceso"=>'calculado',"reparos.bln_sumario"=>'true');

                        }elseif($valor_select=='rif'){

          //                  echo 'Tu rif es:'.$rif;
                            $condiciones=array("conusu.rif"=>$rif,"reparos.proceso"=>'calculado',"reparos.bln_sumario"=>'true');

                        }elseif ($valor_select=='fecha') {

                            $condiciones=array("to_char(multas.fechaelaboracion,'dd-mm-yyyy')>="=>$fecha_desde, 
                                               "to_char(multas.fechaelaboracion,'dd-mm-yyyy')<="=>$fecha_hasta,
                                               "reparos.proceso"=>'calculado',"reparos.bln_sumario"=>'true');
                        }

                    $data= $this->lista_por_aprobar_m->lista_calculos_por_aprobar_clum_excel($condiciones);
                      
                      break;    
                
              }
                
            
            $this->load->library('libreria_generar_excel');  
            $this->libreria_generar_excel->generar_excel_extemporaneo($data);
        }
        
}
