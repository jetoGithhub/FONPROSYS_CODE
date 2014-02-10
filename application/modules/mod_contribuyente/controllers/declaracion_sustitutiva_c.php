<?php

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 * Description of declaracion_sustitutiva_c
 *
 * @author viewmed
 */
class Declaracion_sustitutiva_c extends CI_Controller {
    //put your code here
    
    function __construct() {
        parent::__construct();
        $this->load->model('mod_contribuyente/contribuyente_m');
        $this->load->model('mod_contribuyente/declaracion_sustitutiva_m');
    }
    
    function index()
    {
        
        $data['tipo_contribuyente'] = $this->contribuyente_m->tipo_contribuyente();
        $this->load->view('declaracion_sustitutiva_v',$data);
    }
    
    function declarciones_asustituir()
    {

            $id=$this->input->post('tcontribuid');
            $conusuid=  $this->session->userdata('id');
            $html='<option value="" selected="selected" >Seleccione</option>';
                
              $declaraciones=  $this->declaracion_sustitutiva_m->declaraciones_para_sustituir($id,$conusuid);
              
              foreach ($declaraciones as $key => $value) {
                  
                  $html.="<option value='$value[id]'>$value[nudeclara]</option>";
               }
                

        echo json_encode(array('resultado'=>true,'html'=>$html));
    }
    
    
    function datos_declarcion_asustituir()
    {
       $id=$this->input->post('valor'); 
        $query=array(
            "tabla"=>'datos.declara',
            "where"=>array('id'=>$id),
            "respuesta"=>array('baseimpo','montopagar')
            
        );
        $result=  $this->operaciones_bd->seleciona_BD($query);
        
        echo json_encode(array('baseimpo'=>  $this->funciones_complemento->devuelve_cifras_unidades_mil($result['variable0']),'montopagar'=>$this->funciones_complemento->devuelve_cifras_unidades_mil($result['variable1'])));
        
    }
    
    function calcula_declaracion_sustitutiva()
    {
//        sleep(5);
        $tcontribu=  $this->input->post('valor1');
        $declaid= $this->input->post('valor2');
        $baseimpo=  $this->input->post('valor3');
        $nuevabase=  $this->input->post('valor4');
        $anio=  $this->declaracion_sustitutiva_m->anio_declaracion_asustituir($declaid);
        
        if(intval(str_replace(".","",$nuevabase)) > intval(str_replace(".","",$baseimpo))){
        
                $base_limpia= (str_replace(".","",$nuevabase)-str_replace(".","",$baseimpo));
                $fueraRango=false;

                if($tcontribu==1 || $tcontribu==3){

                    $alicuota=$this->funciones_complemento->alicuotaIndirecta($tcontribu,$anio);
        //            $base_limpia=  str_replace(".","",$base);

                    $total=($alicuota['variable0'] * $base_limpia)/100;
                }


                if($tcontribu==4 || $tcontribu==5 || $tcontribu==6){            

                    $alicuota=$this->funciones_complemento->alicuotaDirecta($tcontribu);
        //            $base_limpia=  str_replace(".","",$base);

                    $total=($alicuota['variable0'] * $base_limpia)/100;

                }
                if($tcontribu==2){

                    $ut=$this->funciones_complemento->unidaTributariaDeclarada($periodo,$base_limpia);
        //            echo $ut[0]; die;
                    if($ut[0]<24999){

                        $alicuota['variable0']=0;
                        $fueraRango=true;

                    }else{

                    $resul=$this->funciones_complemento->alicuotaTributaria($tcontribu,$periodo,$base_limpia);

                    $total=$resul[0];
                    $alicuota['variable0']=$resul[1];

                    }
                }


                if(!$fueraRango):

                    $datos=array('resultado'=>'true','alicuota'=>$alicuota['variable0'],'total'=>  $this->funciones_complemento->devuelve_cifras_unidades_mil($total),'fueraRango'=>$fueraRango);

                else:

                    $datos=array('resultado'=>'false', 'P'=>$periodo,'fueraRango'=>$fueraRango);

                endif;
        }else{
            
            $datos=array('resultado'=>'false','fueraRango'=>FALSE,'fuera_monto'=>true);
            
        }        
        
        echo json_encode($datos);
        
    }
}

?>
