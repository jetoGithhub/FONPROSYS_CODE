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
//        sleep(2);
        $string=$this->input->post('id');
        $separa=  explode(':', $string);       
        $id=$separa[0];
        
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
    function cuerpo_crea_calendario($valor,$valor2){
        $string=  $valor;
        $partes=  explode(':', $string);
        $tipe=$partes[1];
        
        $this->load->view('mod_gestioncontribuyente/calendario_segun_tiprgrav_v',array('tipe_tipegrav'=>$tipe,'anio_cal'=>$valor2));
    }
    function crea_calendario(){
        extract($this->input->post());
        $string=  $contri_cal;
        $partes=  explode(':', $string);
        $existe=$this->gestion_calendarios_de_pago_m->verifica_calendario($partes[0],$anio_cal);
//        print_r($existe);die;
        if(!$existe):
        
                $tipegrav = $this->gestion_calendarios_de_pago_m->trae_tipegrav($partes[0]); 

                $data_calpago = array(
                    'nombre'=>"CALENDARIO DE OBLIGACIONES TRIBUTARIAS ".$tipegrav[0]['nombre']." $anio_cal", 
                    'ano'=>$anio_cal, 
                    'tipegravid'=>$partes[0],
                    'usuarioid'=>  $this->session->userdata('id'), 
                    'ip'=>$this->input->ip_address());

        //        $data_calpagod = array(
        //                        
        //                            "f_inicio"=>$fecha_periodoi,
        //                            "f_fin"=>$fecha_periodof,
        //                            "f_limite"=>$fecha_periodol
        //        );
        //        foreach ($fecha_periodoi as $clave=>$valor):
        //            if(!empty($valor)):
        //                $fecha_i = explode('/', $valor);
        //                $fecha_ini = "$fecha_i[2]-$fecha_i[0]-$fecha_i[1]";
        //                $data_calpagod[$clave]=$fecha_ini;                
        //            endif;            
        //        endforeach;

                $exito = FALSE;
                $exito = $this->gestion_calendarios_de_pago_m->inserta_calendario($data_calpago,$fecha_periodoi,$fecha_periodof,$fecha_periodol);

                if ($exito):        
                    $repuesta = array (
                        'success'=>true,
                        'mensaje'=> 'Calendario Creado Exitosamente'
                    );
                else:
                    $repuesta = array (
                        'success'=>FALSE,
                        'mensaje'=> 'Calendario no Creado'
                    );            
                endif;
        else:
            $repuesta = array (
                    'success'=>FALSE,
                    'mensaje'=> 'Ya existe un calendario para este año y contribuyente'
                );
        endif;
        print(json_encode($repuesta));
    }    
}
?>