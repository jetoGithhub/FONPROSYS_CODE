<?php

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 * Description of Gestion_pagos_c
 *
 * @author viewmed
 */
class Gestion_pagos_c extends CI_Controller {
    
    function __construct() {
        parent::__construct();
        
        $this->load->library('funciones_complemento');
        $this->load->model('mod_contribuyente/gestion_pagos_m');
    }
    function index()
    {
        
        $this->load->view('gestion_pagos_v');
    }
    function carga_pagos_pendientes()
    {
        
        
        $tipo_pago=  $this->input->post("estatus");
        
        switch ($tipo_pago) {
            case "1":
                $where=array("declara.conusuid"=>  $this->session->userdata("id"),"declara.fechapago"=>NULL,"declara.bln_reparo"=>"false","declara.bln_declaro0"=>'false');    
                $data = $this->gestion_pagos_m->busca_pagos_pendientes($where,$tipo_pago);
                $tipo="Autoliquidaciones";
                break;
            case "2":
                 $where=array("declara.conusuid"=>  $this->session->userdata("id"),"declara.fechapago"=>NULL,"declara.bln_reparo"=>"true");    
                 $data = $this->gestion_pagos_m->busca_pagos_pendientes($where,$tipo_pago);
                $tipo="Reparos fiscales";
                 break;
            case "3":
                 $where=array("declara.conusuid"=>  $this->session->userdata("id"),"multas.fechapago"=>NULL,"multas.tipo_multa"=>4);    
                 $data = $this->gestion_pagos_m->busca_pagos_pendientes($where,$tipo_pago);
                 $tipo="Resolucion por Extemporaneidad";
                break;
            case "4":
                 $where=array("idconusu"=>$this->session->userdata("id"),"proceso_multa"=>'notificado',"tipo_multa"=>5,"deposito_multa"=>NULL);    
                 $datos = $this->gestion_pagos_m->busca_pagos_pendientes($where,$tipo_pago);
                 $data=  $this->__limpia_datos_multa($datos);
                 $tipo="Culminatoria de Fiscalizacion";
                break;
            case "5":
                 $where=array("idconusu"=>$this->session->userdata("id"),"proceso_multa"=>'notificado',"tipo_multa"=>8,"deposito_multa"=>NULL);;    
                 $datos = $this->gestion_pagos_m->busca_pagos_pendientes($where,$tipo_pago);
                 $data=  $this->__limpia_datos_multa($datos);
                 $tipo="Culminatoria de Sumario";
                break;
            default:
                break;
        }
        
        
        $bancos= $this->gestion_pagos_m->bancos();
//        print_r($bancos);die;
        $html=  $this->load->view('listado_gestion_pagos_v',array("data"=>$data,"tipo"=>$tipo,'tipo_pago'=>$tipo_pago,"bancos"=>$bancos),true);
        //        print_r($html);die;
        echo json_encode(array("resultado"=>true,"html"=>$html));
    }
    function numero_cuentas($id)
    {
      $cuentas= $this->gestion_pagos_m->numero_cuentas($id);
      $html='<option value="" >Seleccione</option> ';
      if(is_array($cuentas)):
          foreach ($cuentas as $key => $value) {
            $html.="<option value='$value[id_cuenta]' >$value[cuenta]</option>";
          
          }
          
      endif;
      
      echo json_encode(array('html'=>$html));
      
    }
            
    function cargar_pago(){
//        sleep(3);
        $cadena=  $this->input->post('cadena');
        $partes= explode(':', $cadena);
        $id=$partes[1];
        $tipo=$partes[2];
//        print_r($partes);die;
        $select=array(
            "tabla"=>'datos.declara',
            "where"=>array('nudeposito'=>$this->input->post('deposito')),
            "respuesta"=>array('id')            
        );
        $result=$this->operaciones_bd->seleciona_BD($select);
        if(empty($result)){
        if(($tipo=='1') || ($tipo=='2')){
            
             $tabla='datos.declara'; 
             $datos=array(

                        'dw'=>array('id'=>$id),
                        'dac'=>array('nudeposito'=>$this->input->post('deposito'),
                                     'fechapago'=> $this->input->post('fdeposito'),
                                     'fecha_carga_pago'=>'now()',
                                     'banco'=>$this->input->post('bancos'),
                                     'cuenta'=>$this->input->post('cuentas')),
                        'tabla'=>$tabla


                );
             $json=  $this->operaciones_bd->actualizar_BD(1,$datos);
             
        }if ($tipo=='3'){
             $datos=array(
                        "pre_aprobacion.multas"=>array(

                                                    'dw'=>array('id'=>$id),
                                                    'dac'=>array('nudeposito'=>$this->input->post('deposito'),
                                                                 'fechapago'=> $this->input->post('fdeposito'),
                                                                 'fecha_carga_pago'=>'now()',
                                                                'banco'=>$this->input->post('bancos'),
                                                                'cuenta'=>$this->input->post('cuentas'))
                                                    ),
                        "pre_aprobacion.intereses"=>array(
                                                    
                                                        'dw'=>array('multaid'=>$id),
                                                        'dac'=>array('nudeposito'=>$this->input->post('depositoi'),
                                                                     'fecha_pago'=> $this->input->post('fdepositoi'),
                                                                     'fecha_carga_pago'=>'now()',
                                                                    'banco'=>$this->input->post('bancosi'),
                                                                    'cuenta'=>$this->input->post('cuentasi')) 
                            
                                                    )


                );
            $json=  $this->operaciones_bd->actualizar_BD(2,$datos);  
            
        }if(($tipo=='4') || ($tipo=='5')){
            
            ($tipo=='4'? $multa=5 : $multa=8);
             

                        $where=array('nresolucion'=>$id,'tipo_multa'=>$multa);
                        
                        $datos_multa=array('nudeposito'=>$this->input->post('deposito'),
                                     'fechapago'=> $this->input->post('fdeposito'),
                                     'fecha_carga_pago'=>'now()',
                                     'banco'=>$this->input->post('bancos'),
                                     'cuenta'=>$this->input->post('cuentas'));
                        
                        $datos_interes=array('nudeposito'=>$this->input->post('depositoi'),
                                            'fecha_pago'=> $this->input->post('fdepositoi'),
                                            'fecha_carga_pago'=>'now()',
                                            'banco'=>$this->input->post('bancosi'),
                                            'cuenta'=>$this->input->post('cuentasi'));
                        $ids=  explode(',', $partes[3]);
//                        print_r($ids);die;


                
             
          $json=  $this->gestion_pagos_m->carga_pago_sumario_culminatoria($datos_multa,$where,$datos_interes,$ids);   
            
        }
        }else{
          $json=array('resultado'=>FALSE);  
        }
       
        
        echo json_encode($json);
        
    }
    
    function __limpia_datos_multa($data){
        $data_limpia=array();
        
        if(is_array($data)){
                     
            for($i = 0; $i < count($data); $i++)
            {
                $idreparo=$data[$i]['idreparo'];
                $data_limpia[$idreparo]=$data[$i];                    
                    
            }
            
            foreach ($data_limpia as $clave=>$valor):
                $multaids=null;
                for($j=0; $j< count($data); $j++){
                    
                    if($clave==$data[$j]['idreparo']):
                        
                       $multaids=$multaids.','.$data[$j]['idmulta'];                        
                        
                    endif;
                
                }
                $data_limpia[$clave]['multaids']=  trim($multaids,',');
                
            endforeach;
                
            
        }
        return array_values($data_limpia);   

    }
    
}

?>
