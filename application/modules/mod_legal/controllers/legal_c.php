<?php 
/*
 * Controlador: usuarios_c.php
 * Acción: contiene el proceso para listar en la vista usuarios_v.php los usuarios registrados
 * LCT - 2013
 */

if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Legal_c extends CI_Controller {

    function __construct() {
        parent::__construct();
        $this->load->model('legal_m');
    }

    public function index()
    {

        $data=  $this->legal_m->buscar_reparos_culminados();
//            print_r($data);die;
        $datos=array('data'=>$data);
        $this->load->view('listado_reparos_culminados_v',$datos);
    }
        
    public function envia_finanzas(){
        sleep(2);
        $valor=$this->input->post('id');

        $partes=  explode('-', $valor);
//            print_r($partes);die;
        $id=$partes[1];

        ($partes[0]!=='rs'? $boleano='FALSE' : $boleano='TRUE');

         $datos=array(

                    'dw'=>array('id'=>$id),
                    'dac'=>array('proceso'=>'enviado','bln_sumario'=>$boleano),
                    'tabla'=>'datos.reparos'
            );
            $json=$this->operaciones_bd->actualizar_BD(1,$datos);

            echo json_encode($json);
    }
        
    public function descargos(){
        sleep(2);
        $partes=  explode('-', $this->input->post('id_reparo'));
        $datos=array(
               'fecha'          => $this->input->post('fech_comp'),
               'compareciente'  => $this->input->post('nom_comp'),
               'cargo_comp'     => $this->input->post('carg_comp'),
               'reparoid'       => $partes[1],
               'usuario'        => $this->session->userdata('id'),
               'ip'             => $this->input->ip_address(),
               'estatus'        =>'abierto'
        );
        $json=  $this->legal_m->insertar_descargos($datos,$partes[1]);
        echo json_encode($json);

    }

    public function listado_descargos()
    {
         $data=  $this->legal_m->listar_reparos_condescargos();
        $datos=array('data'=>$data);
        $this->load->view('listado_reparos_condescargos_v',$datos);
    }
    
    public function envia_finanzas_descargos(){
        sleep(2);
        $valor=$this->input->post('id');

        $partes=  explode('-', $valor);
        $id=$partes[1];

        $datos=array(
                'datos.reparos'=>array(
                                        'dw'=>array('id'=>$id),
                                        'dac'=>array('proceso'=>'enviado','bln_sumario'=>'TRUE')
                                       ),
                'datos.descargos'=>array(
                                        'dw'=>array('reparoid'=>$id),
                                        'dac'=>array('estatus'=>'sumario')
                                        )
            );
            $json=$this->operaciones_bd->actualizar_BD(2,$datos);

            echo json_encode($json);
    }
    
    public function cerrar_descargos(){
        sleep(2);
        $valor=$this->input->post('id');

        $partes=  explode('-', $valor);
        $id=$partes[1];

         $datos=array(
                     'dw'=>array('reparoid'=>$id),
                    'dac'=>array('estatus'=>'cerrado'),
                    'tabla'=>'datos.descargos'
            );
            $json=$this->operaciones_bd->actualizar_BD(1,$datos);

            echo json_encode($json);
    }
        
        
      
                 
}

        