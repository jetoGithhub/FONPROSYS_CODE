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
    
}

?>
