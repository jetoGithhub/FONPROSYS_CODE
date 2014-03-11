<?php

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 * Description of estado_cuenta_c
 *
 * @author jetox
 */
class Estado_cuenta_c extends CI_Controller {
    
    /*
    * 
    * @acces public
    * @param void
    * @return void
    * 
    */
    function __construct() {
        parent::__construct();
        $this->load->model('estado_cuenta_m');
        $this->load->library('reportes_excel');
    }
    /*
    * 
    * @acces public
    * @param void
    * @return void
    * 
    */
    function index()
    {
        $data['tipocont']=$this->estado_cuenta_m->tipo_contribuyente();
//        print_r($data);
        $this->load->view('mod_reportesContribuyente/estado_cuenta_v',$data);
    }
    
    /*
     * funcion que devuelve la informacion del estado de cuenta ya montada en una tabla
     * 
     * @acces public
     * @param post
     * @return json
     * 
     */
    function busca_info_estado_cuenta()
    {
        $busqueda=$this->input->post('busqueda');
        $tipo_pago=  $this->input->post('tpago');
        $tipo_contribu=  $this->input->post('tipocont');
        $anio_acta=  $this->input->post('anio_acta');
        switch ($busqueda) {
            case 0:
                
                    if(($tipo_pago==0) or ($tipo_pago==3)){
                        
                        $where=array('declara.tipocontribuid'=>$tipo_contribu,'declara.conusuid'=>  $this->session->userdata('id'), 'declara.bln_reparo'=>($tipo_pago==0? "false" : "true"));
                        $data['datos']=$this->estado_cuenta_m->reporte_autoliquidaciones_reparo($where);
                        $data['ident']=0;
//                        print_r($data);die;
                    }else if($tipo_pago==1){
                        $where=array('declara.tipocontribuid'=>$tipo_contribu,'declara.conusuid'=>  $this->session->userdata('id'),'numero_session <>'=>'null');
                        $data['datos']=$this->estado_cuenta_m->reporte_multas_interese($where);
                        $data['ident']=1;
//                        print_r($data);die;
                    }

                break;
            case 1:
                if(($tipo_pago==0) or ($tipo_pago==3)){
                        
                        $where=array('calpago.ano'=>$anio_acta,'declara.conusuid'=>  $this->session->userdata('id'), 'declara.bln_reparo'=>($tipo_pago==0? "false" : "true"));
                        $data['datos']=$this->estado_cuenta_m->reporte_autoliquidaciones_reparo($where);
                        $data['ident']=0;
//                        print_r($data);die;
                    }else if($tipo_pago==1){
                        $where=array('calpago.ano'=>$anio_acta,'declara.conusuid'=>  $this->session->userdata('id'),'numero_session <>'=>'null');
                        $data['datos']=$this->estado_cuenta_m->reporte_multas_interese($where);
                        $data['ident']=1;
//                        print_r($data);die;  
                    }
                
                break;
           
           
        }
         $html=  $this->load->view('resultado_estado_cuenta_v',$data,true);
            
        print(json_encode(array('resultado'=>TRUE,'html'=>$html)));
    }
    
    /*
     * function que muestra la consulta del calendario de pago para el contribuyente
     * 
     * @acces public
     * @param void
     * @return view
     * 
     */
    
    function consulta_calendario_pago()
    {
        $datos['tipo_contribuyentes'] = $this->estado_cuenta_m->lista_tipo_contribuyente();
        $datos['ident']='contribuyente';
        $this->load->view('mod_gestioncontribuyente/consulta_calendario_de_pago_v',$datos);
    }
}

?>
