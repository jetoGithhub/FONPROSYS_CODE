<?php

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 * Description of gestion_multas_legal_c
 *
 * @author jefferson
 */
class Gestion_multas_legal_c extends CI_Controller {
    
    public function __construct() {
        parent::__construct();
        $this->load->model('mod_legal/legal_m');
    }
    
    function multas_culminatoria_aprobadas()
    {
        $condiciones=array("proceso_multa"=>'aprobado',"tipo_multa"=>5,"deposito_multa"=>NULL);
        $data=  $this->legal_m->datos_multas_interes($condiciones);
        $datos=  $this->__total_multa_interes($data);
//        print_r($this->monedas_texto->num_to_letras(trim(254)));
//        echo '<br />'.round(254.454545454,2);
//        print_r($datos); die;
        $this->load->view('listado_multas_culminatoria_aprobadas_v',array('data'=>$datos));        
//        print_r($totales);
//        echo 'multas culminatoria';
    }
    
    
    
    function multas_sumario_aprobadas()
    {   
        $condiciones=array("proceso_multa"=>'aprobado',"tipo_multa"=>8,"deposito_multa"=>NULL);
        $data=  $this->legal_m->datos_multas_interes($condiciones);
        $datos=  $this->__total_multa_interes($data);
//        print_r($datos); die;
        $this->load->view('listado_multas_sumario_aprobadas_v',array('data'=>$datos));        
//        print_r($totales);
//        echo 'multas culminatoria';
    }
    
    function __total_multa_interes($data){
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
        return $data_limpia;   

    }
    
    function carga_notificacion(){
        sleep(3);
        $partes=  explode('-',$this->input->post('idreparo'));
        $idreparo=$partes[1];
        
        $result=  $this->legal_m->carga_notificacion_resolucion_multas($idreparo,$this->input->post('multaids'),$this->input->post('fecha_noti'));
        $this->load->model('mod_gestioncontribuyente/lista_contribuyentes_general_m');
        $datos=$this->lista_contribuyentes_general_m->verifica_conusu($this->input->post('idconusu'));
        $nombre=$datos[0]['nombre'];
        $rif=$datos[0]['rif'];
        $email=$datos[0]['email'];
        $cuerpo_html=$this->load->view('email_pdfs/html_email_notifcacion_multa_legal',array('contribuyente'=>$nombre,'multa'=>  $this->input->post('nombre_multa')),true);
        $asunto='Notificacion FONPROCINE';
        $respuesta_email=$this->funciones_complemento->envio_correo($nombre,$asunto,$cuerpo_html,$cuerpo_html,'fonprocine@gmail.com',$email); 
        
        echo json_encode($result);
    }
    
    function genera_resolucion_culm()
    {
        $condiciones=array("idreparo"=>  $this->input->get('idreparo'));
        $identificador=$this->input->get('tipo');
        $data=  $this->legal_m->datos_multas_interes($condiciones);
//        print_r($data);die;
        $datos['data']=  $this->__total_multa_interes($data);
        $datos['reparoid']=  $this->input->get('idreparo');
        $result=$this->legal_m->datos_declaraciones_reparo($this->input->get('idreparo')); 
//        print_r($result);die;
        $tipo=  $this->legal_m->perido_gravable_contribuyente($data[0]['idtipocont']);
        $datos['detalle_reparo']=$this->__arma_periodo_fiscalizado($tipo, $result);
        $datos['detalles_intereses']=$this->__arma_detalle_interes($tipo, $data);
//        print_r($datos['detalles_intereses']);die;
        $data=array('tabla'=>'datos.undtrib',
                                  'where'=>array('anio'=>$data[0]['periodo_afiscalizar']),
                                  'respuesta'=>array('valor'));
        $datos['ut']=$this->operaciones_bd->seleciona_BD($data);
        
        $query_datos_presidente=array('tabla'=>'datos.presidente',
                         'where'=>array("bln_activo"=>'true'),
                         'respuesta'=>array('nombres','apellidos','nro_decreto','nro_gaceta','dtm_fecha_gaceta'));
        $datos['firma']=$this->operaciones_bd->seleciona_BD($query_datos_presidente);
//        print_r($datos['data']);die;
        if( $identificador=='culminatoria')
        {
            $this->funciones_complemento->generar_pdf_html('html_pdf/resolucion_culminatoria_fiscalizacion_v',$datos,'Resolucion culminatoria.pdf','D');
               
        }if( $identificador=='sumario'){
            $this->funciones_complemento->generar_pdf_html('html_pdf/resolucion_sumario_fiscalizacion_v',$datos,'Resolucion sumario.pdf','D'); 
        }
        
    }
    
    function __arma_periodo_fiscalizado($tipo,$datos)
    {
         switch ($tipo['tipo_periodo']) {
            case 0:
                for ($i=0;$i<count($datos);$i++):
                      $data=array('tabla'=>'datos.calpagod',
                                  'where'=>array('id'=>$datos[$i]['calpagodid']),
                                  'respuesta'=>array('periodo'));
                      $periodo=$this->operaciones_bd->seleciona_BD($data);
                      $datos[$i]['periodo']=$this->funciones_complemento->devuelve_meses_text($periodo['variable0']);
                     endfor;
                break;

            case 1:
                    for ($i=0;$i<count($datos);$i++):
                      $data=array('tabla'=>'datos.calpagod',
                                  'where'=>array('id'=>$datos[$i]['calpagodid']),
                                  'respuesta'=>array('periodo'));
                      $periodo=$this->operaciones_bd->seleciona_BD($data);
                      $datos[$i]['periodo']=$this->funciones_complemento->devuelve_trimestre_text($periodo['variable0']);
                     endfor;
                break;
            case 2:
                for ($i=0;$i<count($datos);$i++):
                      $data=array('tabla'=>'datos.calpagod',
                                  'where'=>array('id'=>$datos[$i]['calpagodid']),
                                  'respuesta'=>array('periodo'));
                      $periodo=$this->operaciones_bd->seleciona_BD($data);
                      $datos[$i]['periodo']=$periodo['variable0'];
                     endfor;
                break;
        }
        return $datos;
        
    }
    function __arma_detalle_interes($tipo,$data){
        $result=array();
        switch ($tipo['tipo_periodo']) {
            case 0:
                for ($i=0;$i<count($data);$i++):
                      
                      $datos_periodo=$this->legal_m->periodo_gravable_interes($data[$i]['multdclaid']);
                      $perido_text=$this->funciones_complemento->devuelve_meses_text($datos_periodo['periodo']);
                      $result[$perido_text]=$this->legal_m->detalles_interes_resolucion($data[$i]['idinteres']);
                      
                 endfor;

                break;

           case 1:
                 for ($i=0;$i<count($data);$i++):
                      
                      $datos_periodo=$this->legal_m->periodo_gravable_interes($data[$i]['multdclaid']);
                      $perido_text=$this->funciones_complemento->devuelve_trimestre_text($datos_periodo['periodo']);
                      $result[$perido_text]=$this->legal_m->detalles_interes_resolucion($data[$i]['idinteres']);
                      
                 endfor;

                break;
            case 2:
                for ($i=0;$i<count($data);$i++):
                      
                      $datos_periodo=$this->legal_m->periodo_gravable_interes($data[$i]['multdclaid']);
//                      $perido_text=$this->funciones_complemento->devuelve_meses_text($datos_periodo['periodo']);
                      $result[$datos_periodo['anio']]=$this->legal_m->detalles_interes_resolucion($data[$i]['idinteres']);
                      
                 endfor;

                break;
        }
        
        return $result;
        
        
    }
}

?>
