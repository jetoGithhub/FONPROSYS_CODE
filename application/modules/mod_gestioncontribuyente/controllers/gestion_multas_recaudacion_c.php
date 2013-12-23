<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
//sleep(2);
class Gestion_multas_recaudacion_c extends CI_Controller  {
        
    public function __construct() {
        parent::__construct();
        
           $this->load->model('mod_gestioncontribuyente/lista_extemp_calc_m');
           $this->load->model('mod_legal/legal_m');
    }
	
	public function index()
	{
           $where=array('contrib_calc.proceso'=>'calculado','detalles_contrib_calc.proceso'=>'aprobado');
           $boleano=false;
           $data['data']=  $this->lista_extemp_calc_m->buscar_extemp_calc($where,$boleano);
           $data['estatus']='aprobado';
//           print_r($data);die;
           $this->load->view('listado_multas_recaudacion_v',$data);
//            $this->load->view('gestion_multas_recaudacion_v');
	}
        function genera_rise()
        {   
//            print_r($this->input->get());
             $condiciones=array("proceso_multa"=>'aprobado',"detacontribcalcid"=>$this->input->get('id'));
             
             $datos=  $this->lista_extemp_calc_m->datos_rise_multas_interes($condiciones);
//             print_r($datos);die;
             $data['data']=  $this->__limpia_ordena_arreglo($datos);
              
             $result=$this->lista_extemp_calc_m->datos_declaraciones_extemporaneas($this->input->get('id'));
//             print_r($result);die;
             $tipo=  $this->legal_m->perido_gravable_contribuyente($datos[0]['idtipocont']);
             
             $data['declarciones_extem']=$this->__arma_periodo_fiscalizado($tipo,$result);
             
             $data['detalles_multa']=  $this->__detalles_multa_rise($tipo,$datos);
             
             $data['detalles_intereses']=$this->__arma_detalle_interes_rise($tipo, $datos);
//             print_r($data['detalles_multa']);die;
             $ut=array('tabla'=>'datos.undtrib',
                                  'where'=>array('anio'=>date('Y')),
                                  'respuesta'=>array('valor'));
             $data['ut']=$this->operaciones_bd->seleciona_BD($ut);
             $query_datos_presidente=array('tabla'=>'datos.presidente',
                     'where'=>array("bln_activo"=>'true'),
                     'respuesta'=>array('nombres','apellidos','nro_decreto','nro_gaceta','dtm_fecha_gaceta'));
             $data['firma']=$this->operaciones_bd->seleciona_BD($query_datos_presidente);
             $data['id']=  $this->input->get('id');
//             print_r($data['detalles_intereses']);die;
             $this->funciones_complemento->generar_pdf_html('html_pdfs/pdf_rise_v',$data,'Rise.pdf','D');
        }
        
        function __limpia_ordena_arreglo($data)
        {
            $data_limpia=array();

            if(is_array($data)){

                for($i = 0; $i < count($data); $i++)
                {
                    $idcontribcalc=$data[$i]['detacontribcalcid'];
                    $data_limpia[$idcontribcalc]=$data[$i];                    

                }

                foreach ($data_limpia as $clave=>$valor):
                    $multaids=null;
                    for($j=0; $j< count($data); $j++){

                        if($clave==$data[$j]['detacontribcalcid']):

                           $multaids=$multaids.','.$data[$j]['idmulta'];                        

                        endif;


                    }
                    $data_limpia[$clave]['multaids']=  trim($multaids,',');

                endforeach;


            }
            return $data_limpia;   

        }  
        function __arma_periodo_fiscalizado($tipo,$datos)
        {
         switch ($tipo['tipo_periodo']) {
            case 0:
                for ($i=0;$i<count($datos);$i++):
                      $data=array('tabla'=>'datos.calpagod',
                                  'where'=>array('id'=>$datos[$i]['calpagodid']),
                                  'respuesta'=>array('periodo','fechalim'));
                      $periodo=$this->operaciones_bd->seleciona_BD($data);
                      $datos[$i]['periodo']=$this->funciones_complemento->devuelve_meses_text($periodo['variable0']);
                     
                      endfor;
                break;

            case 1:
                    for ($i=0;$i<count($datos);$i++):
                      $data=array('tabla'=>'datos.calpagod',
                                  'where'=>array('id'=>$datos[$i]['calpagodid']),
                                  'respuesta'=>array('periodo','fechalim'));
                      $periodo=$this->operaciones_bd->seleciona_BD($data);
                      $datos[$i]['periodo']=$this->funciones_complemento->devuelve_trimestre_text($periodo['variable0']);
                    
                      endfor;
                break;
            case 2:
                for ($i=0;$i<count($datos);$i++):
                      $data=array('tabla'=>'datos.calpagod',
                                  'where'=>array('id'=>$datos[$i]['calpagodid']),
                                  'respuesta'=>array('periodo','fechalim'));
                      $periodo=$this->operaciones_bd->seleciona_BD($data);
                      $datos[$i]['periodo']=$periodo['variable0'];
                     endfor;
                break;
        }
        return $datos;
        
        }
        function __detalles_multa_rise($tipo,$array)
        {
            if(is_array($array))
            {
                foreach ($array as $key => $value)
                {
                    $return[$key]=  $this->lista_extemp_calc_m->detalles_multa_rise($array[$key]['multdclaid']);
                    
                    foreach ($return[$key] as $key2 => $value2) {
                        switch ($tipo['tipo_periodo']) {
                            
                            case 0:
                                $return[$key][$key2]['text_periodo']=$this->funciones_complemento->devuelve_meses_text($return[$key][$key2]['periodo']);
                                break;
                            case 1:
                                $return[$key][$key2]['text_periodo']=$this->funciones_complemento->devuelve_trimestre_text($return[$key][$key2]['periodo']);
                                break;
                            case 2:
                                $return[$key][$key2]['text_periodo']=$return[$key][$key2]['periodo'];
                                break;
                        }
                        $return[$key][$key2]['total_multa']= $array[$key]['total_multa'];  
                        
                    }
                    

                }
            }
            
            return $return;
            
        }
        function __arma_detalle_interes_rise($tipo,$data){
        $result=array();
        $this->load->model('legal_m');
        switch ($tipo['tipo_periodo']) {
            case 0:
                for ($i=0;$i<count($data);$i++):
                      
                      $datos_periodo=$this->legal_m->periodo_gravable_interes($data[$i]['multdclaid']);
                      $perido_text=$this->funciones_complemento->devuelve_meses_text($datos_periodo['periodo']);
                      $result[$perido_text]=$this->legal_m->detalles_interes_resolucion($data[$i]['idinteres']);
                      
                      $declara=array('tabla'=>'datos.declara',
                                  'where'=>array('id'=>$data[$i]['multdclaid']),
                                  'respuesta'=>array('calpagodid','nudeclara','fechapago'));
                      $resul_declara=$this->operaciones_bd->seleciona_BD($declara);
                      $result[$perido_text]['nudeclara']=$resul_declara['variable1'];
                      $result[$perido_text]['fechapago']= $resul_declara['variable2'];
                      $calpagod=array('tabla'=>'datos.calpagod',
                                  'where'=>array('id'=>$resul_declara['variable0']),
                                  'respuesta'=>array('fechalim'));
                      $periodo=$this->operaciones_bd->seleciona_BD($calpagod);
                      $result[$perido_text]['fechalim']=$periodo['variable0'];
                      $result[$perido_text]['anio']=$datos_periodo['anio'];
                      
                 endfor;

                break;

           case 1:
                 for ($i=0;$i<count($data);$i++):
                      
                      $datos_periodo=$this->legal_m->periodo_gravable_interes($data[$i]['multdclaid']);
                      $perido_text=$this->funciones_complemento->devuelve_trimestre_text($datos_periodo['periodo']);
                      $result[$perido_text]=$this->legal_m->detalles_interes_resolucion($data[$i]['idinteres']);
                      
                      $declara=array('tabla'=>'datos.declara',
                                  'where'=>array('id'=>$data[$i]['multdclaid']),
                                  'respuesta'=>array('calpagodid','nudeclara','fechapago'));
                      $resul_declara=$this->operaciones_bd->seleciona_BD($declara);
                      $result[$perido_text]['nudeclara']=$resul_declara['variable1'];
                      $result[$perido_text]['fechapago']=$resul_declara['variable2'];
                      $calpagod=array('tabla'=>'datos.calpagod',
                                  'where'=>array('id'=>$resul_declara['variable0']),
                                  'respuesta'=>array('fechalim'));
                      $periodo=$this->operaciones_bd->seleciona_BD($calpagod);
                      $result[$perido_text]['fechalim']=$periodo['variable0'];
                      $result[$perido_text]['anio']=$datos_periodo['anio'];
                 endfor;

                break;
            case 2:
                for ($i=0;$i<count($data);$i++):
                      
                      $datos_periodo=$this->legal_m->periodo_gravable_interes($data[$i]['multdclaid']);
//                      $perido_text=$this->funciones_complemento->devuelve_meses_text($datos_periodo['periodo']);
                      $result[$datos_periodo['anio']]=$this->legal_m->detalles_interes_resolucion($data[$i]['idinteres']);
                      
                      $declara=array('tabla'=>'datos.declara',
                                  'where'=>array('id'=>$data[$i]['multdclaid']),
                                  'respuesta'=>array('calpagodid','nudeclara','fechapago'));
                      $resul_declara=$this->operaciones_bd->seleciona_BD($declara);
                      $result[$datos_periodo['anio']]['nudeclara']=$resul_declara['variable1'];
                      $result[$datos_periodo['anio']]['fechapago']=$resul_declara['variable2'];
                      $calpagod=array('tabla'=>'datos.calpagod',
                                  'where'=>array('id'=>$resul_declara['variable0']),
                                  'respuesta'=>array('fechalim'));
                      $periodo=$this->operaciones_bd->seleciona_BD($calpagod);
                      $result[$datos_periodo['anio']]['fechalim']=$periodo['variable0'];
                      $result[$datos_periodo['anio']]['anio']="";
                 endfor;

                break;
        }
        
        return $result;
        
        
    }
        function carga_notificacion()
        {
            
            
          $datos=array(

               'datos.detalles_contrib_calc'=>array('dw'=>array('id'=>$this->input->post('id_detaconcalc')),
                                                    'dac'=>array('proceso'=> 'notificado'),
                                                    ),

               'pre_aprobacion.multas'=>array('dw'=>array('declaraid'=>$this->input->post('declaraid')),

                                               'dac'=>array('fechanotificacion'=>$this->input->post('fecha_noti'))
                                              ),
              
//               'datos.contrib_calc'=>array('dw'=>array('id'=>$this->input->post('idconcalc')),
//                                                    'dac'=>array('fecha_notificacion'=>$this->input->post('fecha_noti')),
//                                                  ),
                     );
            $result=  $this->operaciones_bd-> actualizar_BD(2,$datos);
            
            if($result['resultado']):
            
                $this->load->model('mod_gestioncontribuyente/lista_contribuyentes_general_m');
                $datos=$this->lista_contribuyentes_general_m->verifica_conusu($this->input->post('idconusu'));
                $nombre=$datos[0]['nombre'];
                $rif=$datos[0]['rif'];
                $email=$datos[0]['email'];
                $cuerpo_html=$this->load->view('email_pdfs/html_email_notifcacion_rise',array('contribuyente'=>$nombre),true);
                $asunto='Notificacion FONPROCINE';
                $respuesta_email=$this->funciones_complemento->envio_correo($nombre,$asunto,$cuerpo_html,$cuerpo_html,'fonprocine@gmail.com',$email); 
                $json=array('resultado'=>true);
                
             else:
                $json=array('resultado'=>FALSE);
            endif;
            
           echo json_encode($json);
        }
        function listado_multas_recaudacion(){
            
           $estatus=  $this->input->post('estatus');
           if($estatus=='enviado'):
            $where=array('contrib_calc.proceso'=>$estatus);
            $boleano=true;
            else:
               $where=array('contrib_calc.proceso'=>'calculado','detalles_contrib_calc.proceso'=>$estatus);
               $boleano=false; 
            endif;
           $this->load->model('mod_gestioncontribuyente/lista_extemp_calc_m');
           $data['data']=  $this->lista_extemp_calc_m->buscar_extemp_calc($where,$boleano);
//           print_r($data['data']);die;
           $data['estatus']=$estatus;
           $vista=$this->load->view('listado_multas_recaudacion_v',$data,TRUE);
           echo json_encode(array('resultado'=>'true','vista'=>$vista));
           
        }
         function detalles_multas_recaudacion(){
            
           $estatus=  $this->input->post('estatus');
           $id_concalc= $this->input->post('id_concalc');
//           $contid= $this->input->post('idcont');           
          
           
           if($estatus=='enviado'):
            $where=array('contrib_calc.id'=>$id_concalc);    
           $this->load->model('mod_gestioncontribuyente/lista_extemp_calc_m');
           $data['data']=  $this->lista_extemp_calc_m->buscar_extemp_calc($where,FALSE);           
           else:
             $where=array('detalles_contrib_calc.proceso'=>$estatus,'contrib_calc.id'=>$id_concalc);   
           $this->load->model('mod_gestioncontribuyente/lista_por_aprobar_m');
           $data['data']=  $this->lista_por_aprobar_m->lista_calculos_por_aprobar($where); 
           
           endif;
           $data['estatus']=$estatus;
//           print_r($data['data']); die;
           $vista=$this->load->view('detalles_multas_recaudacion_v',$data,TRUE);
           echo json_encode(array('resultado'=>'true','vista'=>$vista));
           
        }
        function notificar_contrribuyente(){
            
            $valores=$this->input->post('valores');
//            print_r($valores);
                $clv_iguales=array();
                $ids_conusu=array();
                $ids_deta_contrib_clac=array();
                /* logica para obtener del arreglo enviado
                 * desde de lavista los valores de los ids
                 * respectivos a la tabla detalles_contrib_calc
                */
                for($j=0;$j<count($valores); $j++){                    
               
                    $datos_eval = explode(':', $valores[$j]);                    
                    $ids_deta_contrib_clac[$j]=$datos_eval[0];                   
                    
                } 
                /* logica para obtener del arreglo enviado
                 * desde de la vista los valores de los ids
                 * respectivos a la tabla conusu y verificando si se repiten 
                 * se elminan para que solo quede uno esto es para el envio
                 * de notificaciones al correo
                */
                for($i=0;$i<count($valores); $i++){  
                    $datos_eval = explode(':', $valores[$i]); 
                    $ids_conusu[$i]=$datos_eval[1];
                     if($i==(count($valores))):
                        
                        $vali=$i; 
                            
                     else:
                                 
                        $vali=$i+1;
                             
                    endif;
                    for($n=$vali;$n<count($valores);$n++):
                        $datos_eval2 = explode(':', $valores[$n]); 
                        if($datos_eval[1]==$datos_eval2[1]):
                            
                           $clv_iguales[]=$n;
                           
                        endif;
                       
                    endfor;
                
                    if(!empty($clv_iguales)): 
                       
                        foreach ($clv_iguales as $iguales):
                                 // eliminamos la posicion que es igual para que 
                                 // en la siguinete vuelta no sea tomada por el primer for
                                 unset($valores[$iguales]);

                        endforeach; 

                         // restablecemos las claves de array para que sigan 
                         // trabajando los ciclos de manera continua
                         $valores=  array_values($valores);  
                    endif; 
                    // seteamos el arreglo para la proxima vuelta del for
                    unset($clv_iguales);
                }
//                print_r($ids_deta_contrib_clac);
//                print_r($ids_conusu);die;
                $this->load->model('mod_gestioncontribuyente/recaudacion_m');
                $result=$this->recaudacion_m->activa_multa_extem_contribuyente($ids_deta_contrib_clac);
                if($result):
                    
                  $this->load->model('mod_gestioncontribuyente/lista_contribuyentes_general_m');
                    foreach ($ids_conusu as $valor):  
                        
                        $datos=$this->lista_contribuyentes_general_m->verifica_conusu($valor);
//                        print_r($datos);
                        $nombre=$datos[0]['nombre'];
                        $rif=$datos[0]['rif'];
                        $email=$datos[0]['email'];
                        $cuerpo_html='<p>Sr representante de la empresa '.$nombre.',
                                        por medio de la presente le informamos que
                                        tiene un conjunto de periodos cancelados 
                                        en forma extemporanea. Lo cual le acarreo una 
                                        multa por el concepto antes mencionado.</p>
                                        <br />
                                        <p>para visualizar la informacion de las multas 
                                        dirijase a la siguiente direcion</p>';
                        $asunto='Informacion de multas FONPROCINE';
                        $respuesta_email=$this->funciones_complemento->envio_correo($nombre,$asunto,$cuerpo_html,$cuerpo_html,'fonprocine@gmail.com',$email);
                        $respuesta[]['email']=$respuesta_email.":".$valor;
                    endforeach; 
                     $data_result=array('resultado'=>TRUE);
                else:
                     $data_result=array('resultado'=>FALSE);
                endif;
                echo json_encode($data_result);
//                print_r($respuesta);
        }
        function pdf_multa_recaudacion($estatus){
//            $estatus='calculado'; 
//        print_r($estatus);
            
            if($estatus=='enviado'):
                $where=array('contrib_calc.proceso'=>$estatus);
                $this->load->model('mod_gestioncontribuyente/lista_extemp_calc_m');
                $data['data']=  $this->lista_extemp_calc_m->buscar_extemp_calc($where,FALSE); 
                $data['encabezado']=array('#','Rif','Nombre','Tipo Contribuyente','Anio','periodo','Elaboracion','usuario');
                
            else:
                $where=array('contrib_calc.proceso'=>'calculado','detalles_contrib_calc.proceso'=>$estatus);
                $this->load->model('mod_gestioncontribuyente/lista_por_aprobar_m');
                $data['data']=  $this->lista_por_aprobar_m->lista_calculos_por_aprobar($where);
                $data['encabezado']=array('#','Rif','Nombre','Tipo Contribuyente','Anio','Periodo','Elaboracion','Multa','Interes');

            endif;           
            $data['estatus']=$estatus;
//            $data['fecha']['dia']=25;
//           $data['fecha']['mes']=25;
//           $data['fecha']['anio']=2013;
//           $this->load->library('Pdf');
//           $this->Pdf->ImprimirArchivo($num,$title,'',$file2);
            
//            print_r($data);die;
            $this->load->view('html_pdfs/prueba1',$data);
            $this->funciones_complemento->generar_pdf_html('html_pdfs/prueba1',$data,'probando-jeto.pdf','D');
         }
        
        
        function excel_multa_recaudacion(){
            
         $where=array('declara.usuarioid'=>17);
           $this->load->model('mod_gestioncontribuyente/lista_extemp_calc_m');
           $data['data']=  $this->lista_extemp_calc_m->buscar_extemp_calc($where,FALSE);
           $data['estatus']='enviado';
           
           $this->load->view('gestion_multas_recaudacion_excel',$data);
        
        }







//       
}