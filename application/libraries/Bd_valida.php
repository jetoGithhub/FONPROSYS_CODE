<?php if (!defined('BASEPATH')) exit ('No direct script access allowed');

class Bd_valida{
    
    protected $ci;
	
    function __construct() {
        $this->ci =& get_instance();

	
        $this->ci->load->config('auth_database');

    }

    function inicializar_Bd_valida($parametros =array()){

        $this->servidor =   $this->ci->config->item('servidor');
        $this->usuario = '';   //$this->ci->config->item('usuario');
        $this->clave =   '';   //$this->ci->config->item('clave');
        $this->bd =         $this->ci->config->item('bd');
        $this->driver  =    $this->ci->config->item('driver');
        $this->dbprefix =   $this->ci->config->item('dbprefix');
        $this->pconnect =   $this->ci->config->item('pconnect');
        $this->db_debug =   $this->ci->config->item('db_debug');
        $this->cache_on =   $this->ci->config->item('cache_on');
        $this->cachedir =   $this->ci->config->item('cachedir');
        $this->char_set  =  $this->ci->config->item('char_set');
        $this->dbcollat =   $this->ci->config->item('dbcollat');
        $this->swap_pre =   $this->ci->config->item('swap_pre');
        $this->autoinit =   $this->ci->config->item('autoinit');
        $this->stricton =   $this->ci->config->item('stricton');
        
        
        if(is_array($parametros)):
            foreach ($parametros as $nombre => $valor):
		if(!$valor=="N/A"){
			$this->$nombre = $valor;
                }else if($valor=="N/A"){
                    $this->$nombre = $this->ci->config->item("$nombre");
                }
                









            endforeach;
        endif;
        $url_conexion = "$this->driver://$this->usuario:$this->clave@$this->servidor/$this->bd?pconnect=$this->pconnect";
        $this->ci->objeto_db = $this->ci->load->database($url_conexion,TRUE); 

	return $this->ci->objeto_db;       
    }    

    function valida_bd(){
        if ($this->ci->objeto_db->initialize()):

            return true;
        else:
            return false;
        endif;

        } 
        
     }
?>

