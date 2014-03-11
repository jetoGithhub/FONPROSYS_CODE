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
       $tcontribu=$this->input->post('valor2');
        $query=array(
            "tabla"=>'datos.declara',
            "where"=>array('id'=>$id,'nudeposito !='=>'','tdeclaraid'=>2,'tipocontribuid'=>$tcontribu,'conusuid'=>  $this->session->userdata('id')),
            "respuesta"=>array('baseimpo','montopagar','id')
            
        );
        $result=  $this->operaciones_bd->seleciona_BD($query);
        
        if(!empty($result)):
        
            echo json_encode(array('resultado'=>true,'baseimpo'=>  $this->funciones_complemento->devuelve_cifras_unidades_mil($result['variable0']),'montopagar'=>$this->funciones_complemento->devuelve_cifras_unidades_mil($result['variable1']),'declaraid'=>$result['variable2']));
        else:
         echo json_encode(array('resultado'=>false));
           
        endif;
    }
    
    function calcula_declaracion_sustitutiva()
    {
//        sleep(5);
        $tcontribu=  $this->input->post('valor1');
        $declaid= $this->input->post('valor2');
        $baseimpo=  $this->input->post('valor3');
        $nuevabase=  $this->input->post('valor4');
        $monto_anterior=$this->input->post('valor5');
        $anio=  $this->declaracion_sustitutiva_m->anio_declaracion_asustituir($declaid);
        
        
        if(intval(str_replace(".","",$nuevabase)) > intval(str_replace(".","",$baseimpo))){
        
                $base_limpia= (str_replace(".","",$nuevabase));
                $fueraRango=false;

                if($tcontribu==1 || $tcontribu==3){

                    $alicuota=$this->funciones_complemento->alicuotaIndirecta($tcontribu,$anio);
        //            $base_limpia=  str_replace(".","",$base);

                    $total=($alicuota['variable0'] * $base_limpia)/100;
                    $total_sustitutiva=$total-(str_replace(".","",$monto_anterior));
                }


                if($tcontribu==4 || $tcontribu==5 || $tcontribu==6){            

                    $alicuota=$this->funciones_complemento->alicuotaDirecta($tcontribu);
        //            $base_limpia=  str_replace(".","",$base);

                    $total=($alicuota['variable0'] * $base_limpia)/100;
                     $total_sustitutiva=$total-(str_replace(".","",$monto_anterior));

                }
                if($tcontribu==2){

                    $ut=$this->funciones_complemento->unidaTributariaDeclarada($anio,$base_limpia);
        //            echo $ut[0]; die;
                    if($ut[0]<24999){

                        $alicuota['variable0']=0;
                        $fueraRango=true;

                    }else{

                    $resul=$this->funciones_complemento->alicuotaTributaria($tcontribu,$anio,$base_limpia);

                    $total=$resul[0];
                    $alicuota['variable0']=$resul[1];
                    $total_sustitutiva=$total-(str_replace(".","",$monto_anterior));

                    }
                }

               
                if(!$fueraRango):

                    $datos=array('h'=>$base_limpia,'resultado'=>'true','alicuota'=>$alicuota['variable0'],'total'=>$total_sustitutiva,'fueraRango'=>$fueraRango,'total_base'=>$total);

                else:

                    $datos=array('resultado'=>'false', 'P'=>$periodo,'fueraRango'=>$fueraRango);

                endif;
        }else{
            
            $datos=array('resultado'=>'false','fueraRango'=>FALSE,'fuera_monto'=>true);
            
        }        
        
        echo json_encode($datos);
        
    }
    
    function guarda_declaracion_sustitutiva()
    {
        $tcontribu=  $this->input->post('tcotribuyente');
        $declaid= $this->input->post('declasus');
        $baseimpo=  $this->input->post('bimponible');
        $nuevabase=  $this->input->post('nbimponible');
        $total=$this->input->post('tpagar');
        $tdeclaracion=$this->input->post('tdeclaracion');
//        $base_limpia= (str_replace(".","",$nuevabase)-str_replace(".","",$baseimpo));
        // obtenemos los datos de la declaracion a la cual vamos a sustituir para asi 
        // cargar la nueva con los mismos datos a diferencia de el monto la base imponible 
        // y el tipo de declaracion. 
        
        $datos_decl=array('tabla'=>'datos.declara',
                            'where'=>array('id'=>$declaid),
                            'respuesta'=>array('fechaini','fechafin','replegalid','alicuota','calpagodid')); 

        $resul=$this->operaciones_bd->seleciona_BD($datos_decl);
        
        // buscamos el periodo de esa declaracion que se esta sustituyendo
        $query_periodo=array('tabla'=>'datos.calpagod',
                            'where'=>array('id'=>$resul['variable4']),
                            'respuesta'=>array('calpagoid','periodo')); 

        $resul_periodo=$this->operaciones_bd->seleciona_BD($query_periodo);
        
        //buscamos el año dede esa declaracion que se esta sustituyendo
        $query_anio=array('tabla'=>'datos.calpago',
                            'where'=>array('id'=>$resul_periodo['variable0']),
                            'respuesta'=>array('ano')); 

        $resul_anio=$this->operaciones_bd->seleciona_BD($query_anio);
        
        // verificamos que la cantidad de declaraciones sustitutivas no pasen de tres para la declaracion
        // que se esta sustituyendo
         $query=array('tabla'=>'datos.declara',
                            'where'=>array('plasustid'=>$declaid),
                            'respuesta'=>array('id')); 

        $resul2=$this->operaciones_bd->seleciona_BD($query);
        
        if(count($resul2) < 1):
            $data=array('tabla'=>'datos.conusu','where'=>array('id'=>$this->session->userdata('id')),'respuesta'=>array('rif','id')); 

            $valor=$this->operaciones_bd->seleciona_BD($data); 

            $aniVeri=  substr($resul_anio['variable0'],2,2);
            
            $totalVerificado=  $this->funciones_complemento->numero_depostido_bancario($total);

            $ndeposito=$valor['variable0'].$tcontribu.'3'.$resul_periodo['variable1'].$aniVeri.$totalVerificado;

            $validadorBanco=$this->funciones_complemento->numero_verificador($ndeposito);
//            print_r(array($ndeposito.'-'.$validadorBanco));die;
             $datos=array(
//                                            'nudeclara'=>$ndeposito.$validadorBanco,
                                            'tdeclaraid'=>$tdeclaracion,
                                            'fechaelab'=>"now()",
                                            'fechaini'=>$resul['variable0'],
                                            'fechafin'=>$resul['variable1'], 
                                            'replegalid'=>$resul['variable2'],
                                            'baseimpo'=>str_replace(",",".",str_replace(".","",$nuevabase)),
                                            'alicuota'=>$resul['variable3'],
                                            'exonera'=>0, 
                                            'credfiscal'=>0, 
                                            'usuarioid'=>$this->session->userdata('id'),
                                            'ip'=>$this->input->ip_address(),
                                            'tipocontribuid'=>$tcontribu,
                                            'conusuid'=>$this->session->userdata('id'),
                                            'plasustid'=>$declaid,
                                            'montopagar'=>$total,
                                            'calpagodid'=>$resul['variable4'],
                                            'bln_declaro0'=>($total==0 ? 'true' : 'false'),
                                            'ident_banco'=>$validadorBanco,
                                            'plasus_alicuota'=>$this->input->post('total_base')
                                            
                                        );
                            $tabla='datos.declara';

                            $result=$this->operaciones_bd->insertar_BD(1,$datos,$tabla,0);
                        
            else:

               $result=array('resultado'=>false,'mensaje'=>'Disculpe usted a superado el numero de declaraciones sustitutivas permitidas para una autoliquidacion'); 

        endif;
        echo json_encode($result); 
        
    }
}

?>
