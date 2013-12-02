<?php
class Salida_c extends CI_Controller{
    function _construc(){
        parent::Controller();
        
    }
    
    function index(){
        
        
        $this->session->sess_destroy();
        header("location:".base_url()."index.php/mod_contribuyente/inicio_c");
        
    }
}
?>
