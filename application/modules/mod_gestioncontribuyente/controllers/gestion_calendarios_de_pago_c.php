<?php
class Gestion_calendarios_de_pago_c extends CI_Controller{
    function __construct() {
        parent::__construct();
        $this->load->model('gestion_calendarios_de_pago_m');
    }
    function index (){
        $data_relogin['controlador'] = base_url()."index.php/ingreso/re_login";
        if (!$this->session->userdata('logged')):
            $this->load->view('vista_re_login',$data_relogin);
        else:
            $datos['tipo_contribuyentes'] = $this->gestion_calendarios_de_pago_m->lista_tipo_contribuyente();
            $this->load->view('mod_gestioncontribuyente/gestion_calendarios_de_pago_menu_v',$datos);
        endif;  
        
    }
    
    function crea_cal(){
        sleep(1);
            $datos['tipo_contribuyentes'] = $this->gestion_calendarios_de_pago_m->lista_tipo_contribuyente();
            $this->load->view('mod_gestioncontribuyente/crea_calendario_de_pago_v_1',$datos);
        
    }
    function consulta_cal(){
        sleep(1);
        echo 'consulta;';
        
    }
    function gestiona_cal(){
        sleep(1);
        echo 'gestiona;';
        
    }
    function lista_anios_cal(){
        sleep(4);
        $id=$this->input->post('id');
        
        if ($lista_anio_cal = $this->gestion_calendarios_de_pago_m->lista_anio_cal($id)):
            $respuesta = array(
                'success' => true,
                'datos'   => $lista_anio_cal
                
            );
        else:
            $respuesta = array(
                'success' => false
                
                
            );            
        endif;
        print(json_encode($respuesta));
        
    }
    function crea_calendario(){
        extract($this->input->post());
        
        $tipegrav = $this->gestion_calendarios_de_pago_m->trae_tipegrav($contri_cal); 
        
        $data_calpago = array(
            'nombre'=>"CALENDARIO DE OBLIGACIONES TRIBUTARIAS ".$tipegrav[0]['nombre']." $anio_cal", 
            'ano'=>$anio_cal, 
            'tipegravid'=>$contri_cal,
            'usuarioid'=>17, 
            'ip'=>'192.168.1.115');
        
        $data_calpagod = array();
        foreach ($fecha_periodo as $clave=>$valor):
            if(!empty($valor)):
                $fecha_i = explode('/', $valor);
                $fecha_ini = "$fecha_i[2]-$fecha_i[0]-$fecha_i[1]";
                $data_calpagod[$clave]=$fecha_ini;                
            endif;            
        endforeach;
        
        $exito = FALSE;
        $exito = $this->gestion_calendarios_de_pago_m->inserta_calendario($data_calpago,$data_calpagod);
        
        if ($exito):        
            $repuesta = array (
                'success'=>true,
                'mensaje'=> 'Calendario Creado Exitosamente'
            );
        else:
            $repuesta = array (
                'success'=>true,
                'mensaje'=> 'Calendario no Creado'
            );            
        endif;
        print(json_encode($repuesta));
    }    
}
?>