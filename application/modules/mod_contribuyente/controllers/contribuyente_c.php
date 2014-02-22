<?php
class Contribuyente_c extends CI_Controller{
    function __construct() {
        parent::__construct();
        $this->load->model('mod_contribuyente/contribuyente_m');
        $this->load->library('funciones_complemento');
    }
    //capturo el metodo de la url para determinar si lo crea un usuario interno o viene externo
    function __remap($metodo){
        switch($metodo){
            case 'interno':
                $this->interno();
                break;
            case 'externo':
                $this->externo();
                break;  
        }
    }

    function interno(){
        
        $dataC['preguntaSecreta'] = $this->contribuyente_m->preguntaSecreta();
        $this->load->view('contribuyente_v',$dataC);
      
    }
    
    function externo(){
        
        $dataC['preguntaSecreta'] = $this->contribuyente_m->preguntaSecreta();
        $data['titulo_pagina'] = "Registro Contribuyentes";
        $this->load->view('vista_cabecera',$data);
        $this->load->view('vista_encabezado');
        $this->load->view('contribuyente_v',$dataC);
        $this->load->view('vista_pie_pagina');
        $this->load->view('vista_pie');
             
           
                    
    }
 
    function verificaRif(){
        //sleep(5);
        $rif=$this->input->get('rif');
        $response_json=array('code_result'=>'','response'=>false);
        $msj['-1'] = "No Hay Soporte a Curl";
        $msj['0'] = "No Hay Conexiòn a Internet";
        $msj['1'] = "Existe RIF Consultado";
        $msj['450'] = "Formato de RIF Invalido";
        $msj['452'] = "RIF no Existe";
        if(!empty($rif)):
        if(function_exists('curl_init')){// Comprobamos si hay soporte para cURL
            $url="http://contribuyente.seniat.gob.ve/getContribuyente/getrif?rif=$rif";
            $ch = curl_init();
            curl_setopt($ch, CURLOPT_URL, $url);
            curl_setopt($ch, CURLOPT_TIMEOUT, 30);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
            $resultado = curl_exec ($ch);
            if($resultado){
                try{
                    if(substr($resultado,0,1)!='<')
                            throw new Exception($resultado);
                    $xml = simplexml_load_string($resultado);
                    if(!is_bool($xml)){
                        $elements=$xml->children('rif');
                        $seniat=array();
                        $response_json['code_result']=1;
                        foreach($elements as $indice => $node){
                            $index=strtolower($node->getName());
                            $response_json[$index]=(string)$node;                            
                            }
                               
                       }
                    }catch(Exception $e){
                       $result=explode(' ', $resultado, 2);
                       $response_json['code_result']=(int) $result[0];
               }
           }else{
               $response_json['code_result']=0;//No hay conexion a internet
            }
        }else{
            $response_json['code_result']=-1;//No hay soporte a curl_php

        }
        if ($response_json['code_result']==1):
            $response_json['response']=true;
        endif;
        $response_json['mensaje'] = $msj[$response_json['code_result']];
        else:
          $response_json['mensaje'] ='Debe Verificar el RIF';  
        endif;
        echo json_encode($response_json);
    }
    
    
    function registraContribuyente(){
        //sleep(5);
        $id='';
        $correo =     $this->input->post('correo');
        $rif =        $this->input->post('rif');
        $nombre =     $this->input->post('nombre');
        $clave_1 =    $this->input->post('clave_1');
        $clave_2 =    $this->input->post('clave_2');
        $pregunta =   $this->input->post('pregunta');
        $respuesta =  $this->input->post('respuesta');
        $codigo =     $this->input->post('codigo_registra');

        
        include("include/librerias/securimage/securimage.php");
        $captcha = new Securimage();
        if ($captcha->check($codigo)):            
            $existe = ($this->contribuyente_m->verificaContribuyente($correo,$rif,$id) ? true : false);

            if(!$existe):
                $datosCon = array(
                    'login'     => strtoupper($rif),
                    'password'  => do_hash($clave_1),
                    'nombre'    => $nombre,
                    'inactivo'  => 'true',
                    'conusutiid'=> 1,
                    'email'     => $correo,
                    'pregsecrid'=> $pregunta,       
                    'respuesta' => $respuesta,
                    'ultlogin'  => 'now()',
                    'usuarioid' => null,
                    'ip'        => $this->input->ip_address(),
                    'rif'       =>strtoupper($rif));
                $recibe=$this->contribuyente_m->registroContribuyente($datosCon);
                if($recibe['registro']):
                        $asunto='Activacion de Registro FRONPROCINE';
                        $datosVista['token']=$recibe["token"];
                        $datosVista['nombre']=strtoupper($rif);
                         $datosVista['clave']=$clave_2;
                        $datosVista['modo']='html';
                    
                       $cuerpoCorreoHTML = $this->parser->parse('correo_token_crea_contribuyente_v', $datosVista,true);
                
                       $datosVista['modo']='text';
                       $cuerpoCorreoTEXT = $this->parser->parse('correo_token_crea_contribuyente_v', $datosVista,true);
                
//                        $cuerpoCorreoHTML = 'Estimado(a). Sr(a).'.$recibe['nombre'].' <br/> Este mensaje fue enviado con el fin de verificar si su cuenta de correo es valida.<br/> Siga el siguiente enlace para continuar con el registro:<br/> '.base_url().'index.php/mod_contribuyente/contribuyente_c/validaToken/'.$recibe["token"].' <br/> No responda este mensaje, esta es una cuenta de correo no monitoreada! <br/> Enviado desde el Sitio Web Fonprocine.';
//                        $cuerpoCorreoTEXT = 'Estimado(a). Sr(a).'.$recibe['nombre'].' <br/> Este mensaje fue enviado con el fin de verificar si su cuenta de correo es valida.<br/> Siga el siguiente enlace para continuar con el registro:<br/> '.base_url().'index.php/mod_contribuyente/contribuyente_c/validaToken/'.$recibe["token"].' <br/> No responda este mensaje, esta es una cuenta de correo no monitoreada! <br/> Enviado desde el Sitio Web Fonprocine.';
                        if($this->funciones_complemento->envio_correo($recibe["nombre"],$asunto,$cuerpoCorreoHTML,$cuerpoCorreoTEXT,'fonprocine@gmail.com',$recibe["correo"])):
                            $respuesta = array(
                                'respuesta' => true,
                                'mensaje'=>'Registro exitoso, Se ha enviado un mensaje de validaciòn a su correo');
                        else:
                            $respuesta = array(
                                'respuesta' => false,
                                'mensaje'=>'Registro fallido y Correo no Enviado');                          
                        endif;
                else:
                    $respuesta = array(
                        'respuesta' => false,
                        'mensaje'=>'Registro Fallido');
                endif;
            else:
                $respuesta = array(
                    'respuesta' => false,
                    'mensaje'=>'Ya existe un usuario Registrado con este correo electronico y RIF'
                );
            endif;
                        
        else:
            $respuesta = array(
                'respuesta' => false,
                'mensaje'   =>'Codigo Captcha No Valido'
            );
        endif;
        print(json_encode($respuesta));

          
          


    }
    function __correoEnvia($nombre_remitente,$asunto,$cuerpoCorreoHTML,$cuerpoTEXT,$remitente,$destinatario){
    //function correoEnvia($nombre_remitente='lct',$asunto='prueba',$cuerpo='<h1>hoola</h1>',$remitente='frederickdanielb@gmail.com',$destinatario='frederickdanielb@gmail.com'){
        //DATOS RECIBIDOS DEL FORMULARIO
//        $nombre_remitente=$this->input->post('nombre_remitente');
//        $asunto=$this->input->post('asunto');
//        $cuerpo=$this->input->post('cuerpo');
//        $remitente=$this->input->post('remitente');
//        $destinatario=$this->input->post('destinatario');
        
        //VARIABLES DE CONFIGURACION DEL SERVIDOR DE CORREO
        $config['protocol']    = 'smtp'; 
        $config['smtp_host']    = 'ssl://smtp.gmail.com'; 
        $config['smtp_port']    = '465'; 
        $config['smtp_timeout'] = '5'; 
        $config['smtp_user']    = 'fonprocine@gmail.com'; 
        $config['smtp_pass']    = 'fonprocine.123'; 
        $config['charset']    = 'utf-8'; 
        $config['newline']    = "\r\n"; 
        $config['mailtype'] = 'html'; // or html 
//        $config['validation'] = TRUE; // bool whether to validate email or not       
        
        //INICIALIZACION DE VARIABLES DE CONFIGURACION DEL SERVIDOR DE CORREO
        $this->email->clear();
        $this->email->initialize($config); 
 
        
        //ENVIO Y EVALUACION DE CORREO
        $this->email->from($remitente,$nombre_remitente); 
        $this->email->to($destinatario);
        $this->email->subject($asunto); 
        $this->email->message($cuerpoCorreoHTML);
        $this->email->set_alt_message($cuerpoTEXT);    
 
         
        try{
            if($this->email->send() === false) :
                return false;
            throw new Exception("Error al Enviar en correo !");
 
            else:
                return true;
            throw new Exception("exito al Enviar en correo !");
            endif;

            }
            catch (Exception $e){
                //$response['mensaje'] = $e->getMessage();
                //print(json_encode($response));
                
                }
        //echo $this->email->print_debugger();        
    }
    function validaToken($token){
        if($datos=$this->contribuyente_m->verificaToken($token,1)):
            //print_r($datos);
            $fechaActual = now();
            if (strtotime($datos[0]['fechacadu'])>$fechaActual):
                if(($datos[0]['usado'])=='t'):
                    $datosVistaToken['mensaje'] = 'Este token ha sido usado';
                    $datosVistaToken['estatus'] = 'usado';
                    
                else:
                    if($this->contribuyente_m->verificaToken($datos[0]['token'],2)):
                        $datosVistaToken['mensaje'] = 'Cuenta Validada';
                        $datosVistaToken['estatus'] = 'Activo';                                 
                    else:
                        print('No se Actualizo');
                    endif;
                endif;
            else:
                $datosVistaToken['mensaje'] = 'Token se encuentra vencido';
                $datosVistaToken['estatus'] = 'vencido';
                              
            endif;

        else:
            $datosVistaToken['mensaje'] = 'Token No existe';
            $datosVistaToken['estatus'] = 'falso';
        endif;
        $data['titulo_pagina'] = "Verificacion de Token";
        $this->load->view('vista_cabecera',$data);
        $this->load->view('vista_encabezado');
        $this->load->view('gestion_token_v',$datosVistaToken);
        $this->load->view('vista_pie_pagina');
        $this->load->view('vista_pie');
    }
    
    function planilla_inicial(){
        //PARA LA CARGA DE EL REGISTRO DE ACCIONISTA
        $data_accionista=  $this->contribuyente_m->busca_accionista($this->session->userdata('id'));
        $datos=array('data'=>$data_accionista);        
        $data_planilla['accionistas_carga'] = $this->load->view('carga_accionista_v', $datos, true);
        $data_planilla['infoplanilla']=  $this->load->contribuyente_m->datos_contribuyente(strtoupper($this->session->userdata('id')));
        $data_planilla['estados'] = $this->__lista_estado();
        $data_planilla['tpscont'] = $this->__devuelve_tipo_contribuyente();        
        $data_planilla['actividad_economica'] = $this->contribuyente_m->actividad_economica();
        $this->load->view('planilla_inicial_contribuyente_v',$data_planilla);
    }
    function __lista_estado(){
        return $this->contribuyente_m->lista_estados();
    }
    function __lista_ciudades($id_estado){
        return $this->contribuyente_m->lista_ciudad($id_estado);
    } 
    function __devuelve_tipo_contribuyente(){
        
        return$this->contribuyente_m->devuelve_tipo_contribuyente($this->session->userdata('id'));
    }
    function ciudades($id_estado){
        $data_ciudad['ciudades'] = $this->__lista_ciudades($id_estado);
        $this->load->view('ciudades_v',$data_ciudad);
    }
    function registro_planilla_inicial(){
        
        $id_contribu=$this->input->post('id_contribu');
        $tcontribu=  $this->input->post('tcontribu');
        $fecha_registro=$this->input->post('fregistro');
        $verifica=$this->contribuyente_m->verifica_registro_completo($this->session->userdata('id'));
//        print_r($verifica); die;
        if((!empty($verifica['id_doc'])) && !empty($verifica['id_replegal'])){
        
                $datosPlanillaInicial=array(
                    'razonsocia'=>strtoupper($this->input->post('rsocial')),
                    'dencomerci'=>strtoupper($this->input->post('dcomercial')),
                    'actieconid'=>$this->input->post('aecono'),
                    'rif'=>strtoupper($this->input->post('nrif')),
                    'numregcine'=>$this->input->post('nrcinema'),
                    'domfiscal'=>strtoupper($this->input->post('dfiscal')),
                    'estadoid'=>$this->input->post('estado'),
                    'ciudadid'=>$this->input->post('ciudad'),
                    'zonapostal'=>$this->input->post('zpostal'),
                    'telef1'=>$this->input->post('telefono1'),
                    'telef2'=>$this->input->post('telefono2'),
                    'telef3'=>$this->input->post('telefono3'),
                    'fax1'=>$this->input->post('fax1'),
                    'fax2'=>$this->input->post('fax2'),
                    'email'=>$this->input->post('email'),
                    'pinbb'=>$this->input->post('pinbb'),
                    'skype'=>$this->input->post('skype'),
                    'twitter'=>$this->input->post('twiter'),
                    'facebook'=>$this->input->post('facebook'),
                    'nuacciones'=>$this->input->post('nacciones'),
                    'valaccion'=>$this->input->post('vacciones'),
                    'capitalsus'=>$this->input->post('csuscrito'),
                    'capitalpag'=>$this->input->post('cpagado'),
                    'regmerofc'=>$this->input->post('oregistradora'),
                    'rmnumero'=>$this->input->post('nrmercantil'),
                    'rmfolio'=>$this->input->post('nfolio'),
                    'rmtomo'=>$this->input->post('ntomo'),
                    'rmfechapro'=>$fecha_registro,
                    'rmncontrol'=>$this->input->post('ncontrol'),
                    'rmobjeto'=>$this->input->post('objempresa'),
                    'domcomer'=>strtoupper($this->input->post('domcomer')),
                    'usuarioid'     =>$this->session->userdata('id'),
                    'ip'            =>$this->input->ip_address()
                        );
                if(empty($id_contribu)):
                    if ($this->contribuyente_m->registra_planilla_inicio($datosPlanillaInicial,$tcontribu,1,$id_contribu,$fecha_registro))
                    {
                        $response = array(
                            "success"	=> true,
                            "message"	=> "Registro Exitoso<br /> En los próximos días estaremos enviándole un correo electronico para verificar la activación de su registro."
                            );
                    }
                    else
                    {
                                    $response = array(
                            "success"	=> false,
                            "message"	=> "Registro Fallido"
                            );
                    }
                elseif(!empty($id_contribu)):
                    if ($this->contribuyente_m->registra_planilla_inicio($datosPlanillaInicial,NULL,2,$id_contribu,$fecha_registro))
                    {
                        $response = array(
                            "success"	=> true,
                            "message"	=> "Actualizacion Exitosa"
                            );
                    }
                    else
                    {
                                    $response = array(
                            "success"	=> false,
                            "message"	=> "Actualizacion Fallida"
                            );
                    }
                 else:
                     $response = array(
                            "success"	=> false,
                            "message"	=> "No llega variable tipo operacion"
                            );                
                endif;
        }else{
            $response = array(
                            "success"	=> false,
                            "message"	=> "Disculpe para formalizar el registro debe cargar un representante legal y el registro mercantil de la empresa"
                            );
        }

           
        echo json_encode( $response );

    }
    function restauraClaveEnvia(){
        //sleep(5);
        $correo = $this->input->post('correo_restaura');
        $rif = $this->input->post('rif_restaura');
        $datos = $this->contribuyente_m->verificaContribuyente($correo,$rif);
//        print_r($datos);
        if($datos):
            if ($token=$this->contribuyente_m->creaToken($datos[0]['id'])):
                $asunto='Restauracion de contraseña FRONPROCINE';
                //$cuerpoCorreo = 'Estimado(a). Sr(a).'.$datos[0]['nombre'].'  '.base_url().'index.php/mod_contribuyente/contribuyente_c/restauraClaveRecibe/'.$token;
            
               
                $datosVista['muestra'] =$datos;
                $datosVista['token']=$token;
                $datosVista['modo']='html';
                    
                $cuerpoCorreoHTML = $this->parser->parse('correo_token_recupera_clave_v', $datosVista,true);
                
                $datosVista['modo']='text';
                $cuerpoTEXT = $this->parser->parse('correo_token_recupera_clave_v', $datosVista,true);
                if($this->funciones_complemento->envio_correo($datos[0]["nombre"],$asunto,$cuerpoCorreoHTML,$cuerpoTEXT,'fonprocine@gmail.com',$correo)):
                    $response = array(
                        'success' => true,
                        'message'=>'Se ha enviado un correo para la restauracion de contraseña');
                else:
                    $response = array(
                        'success' => false,
                        'message'=>'Error al enviar correo');                          
                endif;                
            endif;

        else:
            $response = array(
                "success"	=> false,
                "message"	=> "No existe");           
        endif;
        echo json_encode( $response );
    }
    function restauraClaveRecibe($token){
        if($datos=$this->contribuyente_m->verificaToken($token,1)):
            $datosVistaClave['datoscontribu']=$this->contribuyente_m->verificaToken($token,1);
            $datosVistaClave['pregunta']=$this->contribuyente_m->preguntaSecreta($datos[0]['pregsecrid']);
            $fechaActual = now();
            if (strtotime($datos[0]['fechacadu'])>$fechaActual):
                if(($datos[0]['usado'])=='t'):
                    $datosVistaClave['mensaje'] = 'Este token ha sido usado';
                    $datosVistaClave['estatus'] = 'usado';
                    
                else:
                    if($this->contribuyente_m->verificaToken($datos[0]['token'],2)):
                        $datosVistaClave['mensaje'] = 'Se actualizo Correctamente a usado';
                        $datosVistaClave['estatus'] = 'activo';                                 
                    else:
                        print('Nose actualizo');
                    endif;
                endif;
            else:
                $datosVistaClave['mensaje'] = 'Token se encuentra vencido';
                $datosVistaClave['estatus'] = 'vencido';
                              
            endif;

        else:
            $datosVistaClave['mensaje'] = 'Token No existe';
            $datosVistaClave['estatus'] = 'falso';
        endif;
        $data['titulo_pagina'] = "Restauracion de Contraseña";
        $this->load->view('vista_cabecera',$data);
	$this->load->view('vista_encabezado');
        $this->load->view('restaura_correo_v',$datosVistaClave);
	$this->load->view('vista_pie_pagina');
        $this->load->view('vista_pie');
    }
    
    function enviaClaveNueva(){
        //sleep(6);
        $nuevaClave=random_string('alnum', 6);
        $login = $this->input->post('login');
        $idUsuario = $this->input->post('idusuario');
        $nombre = $this->input->post('nombre');
        $correo = $this->input->post('correo');
        $rsecreta = $this->input->post('rsecreta');
        $codigo  = $this->input->post('codigo');
        include("include/librerias/securimage/securimage.php");
        $captcha = new Securimage();
        if($captcha->check($codigo)):     
        
            if($datos=$this->contribuyente_m->verificaRespuestaSecreta($login,$rsecreta)):
                if($this->contribuyente_m->creaNuevaClave($login,$nuevaClave)):
                    $asunto='Nueva contraseña sistema FONPROCINE';
//                    $cuerpoCorreoHTML = 'Estimado(a). Sr(a). '.$nombre." su nueva clave para el sistema FONPROCINE es $nuevaClave";
//                    $cuerpoCorreoTEXT = 'Estimado(a). Sr(a). '.$nombre." su nueva clave para el sistema FONPROCINE es $nuevaClave";
                    $datosVista['login'] =$login;
                    $datosVista['nuevaclave']=$nuevaClave;
                    $datosVista['modo']='html';
                    
                    $cuerpoCorreoHTML = $this->parser->parse('correo_nueva_clave_v', $datosVista,true);
                
                    $datosVista['modo']='text';
                    $cuerpoCorreoTEXT = $this->parser->parse('correo_nueva_clave_v', $datosVista,true);
                    if($this->funciones_complemento->envio_correo($nombre,$asunto,$cuerpoCorreoHTML,$cuerpoCorreoTEXT,'fonprocine@gmail.com',$correo)):
                        $response = array(
                            'success' => true,
                            'message'=>'Se ha enviado un correo con su nueva contraseña');
                    else:
                        $response = array(
                            'success' => false,
                            'message'=>'Error al enviar correo');                          
                    endif;
             else:
                 $response = array(
                     'success' => false,
                     'message'=>'Contraseña No Actualizada ni enviada');                         
             endif;
            else:
                $response = array(
                    "success"	=> false,
                    "message"	=> "Pregunta Secreta Incorrecta!");                
            endif;
            
        else:
            $response = array(
                "success"	=> false,
                "message"	=> "Codigo Captca Incorrecto!");           
        endif;
        echo json_encode( $response );
    }
    function documentos(){
        $this->load->view('correo_token_recupera_clave_v');
        
    }
    
    function carga_accionista(){
        
//                $this->load->model('contribuyente_m');
//                $contribuid=  $this->load->contribuyente_m->id_contribuyente(strtoupper($this->session->userdata('id')));
                $data=  $this->contribuyente_m->busca_accionista($this->session->userdata('id'));
            
                $datos=array('data'=>$data);
        
                $this->load->view('carga_accionista_v', $datos);
    }
    function carga_vista_dialog(){
        
        if($this->input->post('identificador')==1)
            {
            
                  $vista=$this->load->view('crear_accionista_v',$datos=array('contribuid'=>$this->session->userdata('id')),true);
                  $respuesta_ctrl=array('resultado'=>true,'vista'=>$vista);
                  echo json_encode($respuesta_ctrl);
            } 
            
             if($this->input->post('identificador')=='vista-replegal')
            {
                 $pasa=$this->contribuyente_m->verifica_replegal($this->session->userdata('id'));
//                 print_r($pasa);die;
                 if(!$pasa):
                    $data_planilla['estados'] = $this->__lista_estado();
   //                  $contribuid=  $this->load->contribuyente_m->id_contribuyente(strtoupper($this->session->userdata('id')));
                     $data_planilla['id_conusu']=$this->session->userdata('id');
                     $vista=$this->load->view('formulario_replegal_v',$data_planilla,true);
                     $respuesta_ctrl=array('resultado'=>true,'vista'=>$vista);
                  else:
                        $vista='<p style=" margin-top: 15px;font-size: 12px; font-family: sans-serif; text-aling:justify">
                                        <span class="ui-icon ui-icon-alert" style="float: left; margin: 0 7px 50px 0;"></span>
                                        Disculpe ya tiene un representante legal cargado, si deseas cambiar el representate legal edite los datos del existente                                         
                                        </p><br />';
                      $respuesta_ctrl=array('resultado'=>false,'existe'=>TRUE,'vista'=>$vista);
                      
                  endif;
                  echo json_encode($respuesta_ctrl);
            } 
            if($this->input->post('identificador')=='edita-replegal')
            {
                $datos['info']=$this->contribuyente_m->datos_replegal($this->session->userdata('id'));
                $datos['estados'] = $this->__lista_estado();
                $datos['id_conusu']=$this->session->userdata('id');
//                print_r($datos);
                $vista=$this->load->view('edita_replegal_v',$datos,true);
                $respuesta_ctrl=array('resultado'=>true,'vista'=>$vista);
                echo json_encode($respuesta_ctrl);
            }
            
        
    }
    
    function guarda_accionista(){
        
        $datos=array(
                    'contribuid'=>  $this->input->post('idcontribu'),
                    'nombre'=>  $this->input->post('nombre'),
                    'apellido'=>  $this->input->post('apellido'),
                    'ci'=>  $this->input->post('cedula'),
                    'domfiscal'=>$this->input->post('dfiscal'),
                    'nuacciones'=>  $this->input->post('nacciones'),
//                    'valaccion'=>  $this->input->post('vacciones'),
                    //'usuarioid'=> '',
                    'ip'=>$this->input->ip_address()
        );
        $tabla='datos.accionis';
        
        $this->load->library('operaciones_bd');
        $result=$this->operaciones_bd->insertar_BD(1,$datos,$tabla,0);
        echo json_encode($result);
        
    }
    
    function representante_legal(){
        
//        $contribuid=  $this->load->contribuyente_m->id_contribuyente(strtoupper($this->session->userdata('id')));
        
        $data_planilla['inforeplegal']=  $this->load->contribuyente_m->datos_replegal($this->session->userdata('id'));
//        $data_planilla['estados'] = $this->__lista_estado();
//        $data_planilla['id_contribu']=$contribuid;
        $this->load->view('carga-replegal_v', $data_planilla);
    }
    
    function elimina_accionista()
    {
        $id=$this->input->post('id');
        $result=  $this->contribuyente_m->elimina_accionista($id);
        if($result):
            
            $json=array('resultado'=>true);
        endif;
        print json_encode($json);
        
    }
    
    function registro_replegal(){
        
//        $id_rep=$this->input->post('id_replegal');
        
         if($this->input->post('tipo_operacion')=='insert'){  
        
                $datos=array(
                            'contribuid'=>$this->input->post('id_contribu'),
                            'nombre'=>  $this->input->post('nombre'),
                            'apellido'=>  $this->input->post('apellido'),
                            'ci'=>  $this->input->post('ci'),
                            'domfiscal'=>$this->input->post('dfiscal'),
                            'estadoid'=>  $this->input->post('estado'),
                            'ciudadid'=>  $this->input->post('ciudad'),
                            'zonaposta'=>  $this->input->post('zpostal'),
                            'telefhab'=>  $this->input->post('telefono1'),
                            'telefofc'=>  $this->input->post('telefono2'),
                            'fax'=>  $this->input->post('fax1'),
                            'email'=>  $this->input->post('email'),
                            'pinbb'=>  $this->input->post('pinbb'),
                            'skype'=>  $this->input->post('skype'),             
                            'usuarioid'=> '17',
                            'ip'=>$this->input->ip_address()
                );
                $tabla='datos.replegal';

                $this->load->library('operaciones_bd');
                $result=$this->operaciones_bd->insertar_BD(1,$datos,$tabla,0);
                echo json_encode($result);
         }elseif ($this->input->post('tipo_operacion')=='update') {
            $datos=array(
                 
                 'dw'=>array('id'=>  $this->input->post('id_replegal')),
                 'dac'=>array(
                            'nombre'=>  $this->input->post('nombre'),
                            'apellido'=>  $this->input->post('apellido'),
                            'ci'=>  $this->input->post('ci'),
                            'domfiscal'=>$this->input->post('dfiscal'),
                            'estadoid'=>  $this->input->post('estado'),
                            'ciudadid'=>  $this->input->post('ciudad'),
                            'zonaposta'=>  $this->input->post('zpostal'),
                            'telefhab'=>  $this->input->post('telefono1'),
                            'telefofc'=>  $this->input->post('telefono2'),
                            'fax'=>  $this->input->post('fax1'),
                            'email'=>  $this->input->post('email'),
                            'pinbb'=>  $this->input->post('pinbb'),
                            'skype'=>  $this->input->post('skype'),                        
                            ),
                 'tabla'=>'datos.replegal'
             );
             
                $this->load->library('operaciones_bd');
                $result=$this->operaciones_bd->actualizar_BD(1,$datos);
//                print_r($result);die;
                echo json_encode($result);
        }
        
        
//        }
//        
//         if(!empty($id_rep)){ 
//             
//             $datos=array(
//                 
//                 'dw'=>array('id'=>$id_rep),
//                 'dac'=>array(
//                            'nombre'=>  $this->input->post('nombre'),
//                            'apellido'=>  $this->input->post('apellido'),
//                            'ci'=>  $this->input->post('ci'),
//                            'domfiscal'=>$this->input->post('dfiscal'),
//                            'estadoid'=>  $this->input->post('estado'),
//                            'ciudadid'=>  $this->input->post('ciudad'),
//                            'zonaposta'=>  $this->input->post('zpostal'),
//                            'telefhab'=>  $this->input->post('telefono1'),
//                            'telefofc'=>  $this->input->post('telefono2'),
//                            'fax'=>  $this->input->post('fax1'),
//                            'email'=>  $this->input->post('email'),
//                            'pinbb'=>  $this->input->post('pinbb'),
//                            'skype'=>  $this->input->post('skype'),                        
//                            ),
//                 'tabla'=>'datos.replegal'
//             );
//             
//                $this->load->library('operaciones_bd');
//                $result=$this->operaciones_bd->actualizar_BD(1,$datos);
//                echo json_encode($result);
//         }
    }
    
    function declaracion(){       
        
        
        $data_declara['tipo_contribuyente'] = $this->contribuyente_m->tipo_contribuyente();
        $data_declara['tipo_declaracion'] = $this->contribuyente_m->tipo_declaracion();
        $this->load->view('declaracion_v',$data_declara);
    }
    
    function carga_anio_declara(){
        
        $id=$this->input->post('tcontribuid');
        $periodo=$this->contribuyente_m->verifica_pgravable($id);
//        $where=array('tipegravid'=>$periodo['tgravid'],'ano <= '=>date('Y',time()));
//        $anios=$this->contribuyente_m->devuelve_anios_calendario_pago($where);
//        print_r($anios);
//      die;
        if($periodo['periodo']==1):
            
          $htmloption=$this->funciones_complemento->select_anio($periodo['periodo'],$periodo['tgravid']); 
          $aniosdeclara=0;
          $estado='true';
            
        endif;
        
        if($periodo['periodo']==4 or $periodo['periodo']==12 ):
            
//            $htmloption=$this->funciones_complemento->select_trimestre();
            $aniosdeclara=$this->funciones_complemento->select_anio($periodo['periodo'],$periodo['tgravid'],$id);
            $htmloption=0;
            $estado='true';
             
        endif;
        
//        if($periodo['periodo']==12):
//            
////            $htmloption=$this->funciones_complemento->select_meses();
//            $aniosdeclara=$this->funciones_complemento->select_anio($periodo['periodo'],$id);
//            $estado='true';
//             
//        endif;
        
        $data=array(
            
            'resultado'=>$estado,
            'htmloption'=>$htmloption,
            'tipo'=>$periodo['tipo'],
            'aniosD'=>$aniosdeclara
            
        );
        
        echo json_encode($data);
    }
    
    function carga_periodo(){
        
        $id=$this->input->post('tcontribuid');
        $anio=$this->input->post('anio');
        $periodo=$this->contribuyente_m->verifica_pgravable($id);
//        print_r($periodo); 
//        die;
        if($periodo['periodo']==4 ):
            
            $htmloption=$this->funciones_complemento->select_trimestre($anio,$id);
            $estado='true';
             
        endif;
        
        if($periodo['periodo']==12):
            
            $htmloption=$this->funciones_complemento->select_meses($anio);            
            $estado='true';
             
        endif;
        
        $data=array(
            
            'resultado'=>$estado,
            'htmloption'=>$htmloption,
            
            
        );
        
        echo json_encode($data);
        
        
        
    }
    function calculoDeclaracion($verifica=0,$id=0,$anio=0,$base=0,$periodo=0){
        
        if($verifica==0){
            
            $id=$this->input->post('tcontribuid');
            $anio=$this->input->post('anio');  
            $base=$this->input->post('base');  
            $periodo=$this->input->post('periodo');
        }
        
        $fueraRango=false;
        
        if($id==1 || $id==3){
            
            $alicuota=$this->funciones_complemento->alicuotaIndirecta($id,$anio);
            $base_limpia=  str_replace(".","",$base);

            $total=($alicuota['variable0'] * $base_limpia)/100;
        }
        

        if($id==4 || $id==5 || $id==6){            
            
            $alicuota=$this->funciones_complemento->alicuotaDirecta($id);
            $base_limpia=  str_replace(".","",$base);

            $total=($alicuota['variable0'] * $base_limpia)/100;
            
        }
        if($id==2){
            $base_limpia= str_replace(".","",$base);
            $ut=$this->funciones_complemento->unidaTributariaDeclarada($periodo,$base_limpia);
//            echo $ut[0]; die;
            if($ut[0]<24999){
                
                $alicuota['variable0']=0;
                $fueraRango=true;
                
            }else{
            
            $resul=$this->funciones_complemento->alicuotaTributaria($id,$periodo,$base_limpia);
            
            $total=$resul[0];
            $alicuota['variable0']=$resul[1];
            
            }
        }
        
        
        if(!$fueraRango):
        
            $datos=array('resultado'=>'true','alicuota'=>$alicuota['variable0'],'total'=>$total,'fueraRango'=>$fueraRango);
        
        else:
            
            $datos=array('resultado'=>'false', 'P'=>$periodo,'fueraRango'=>$fueraRango);
        
        endif;
        if($verifica==0){
            
        echo json_encode($datos);
        
        }else{
            
            return $datos;
        }
    }
    
    function guardaDeclaracion(){
        
        $id=$this->input->post('tcotribuyente');
        $anio=  $this->input->post('aniod');
        $tperiodo=$this->input->post('tperiodo'); 
        $tdeclaracion=$this->input->post('tdeclaracion');
        $base=  $this->input->post('bimponible');
        $alicuota=  $this->input->post('aimpositiva');
        $exhoneracion=$this->input->post('exhoneracion');
        $cfiscal=  $this->input->post('cfiscal');
        $total=  $this->input->post('tpagar');
        
 	$replegal=array('tabla'=>'datos.replegal','where'=>array('contribuid'=>$this->session->userdata('id')),'respuesta'=>array('id')); 

        $replegalid=$this->operaciones_bd->seleciona_BD($replegal);
            if($tdeclaracion==2):       
        
                      $periodo=$this->contribuyente_m->verifica_pgravable($id);
                  
                     if($periodo['tipo']==2):

                          $anioDeclara=$tperiodo;
                          $periadeclarar='01';
                     else:

                          $anioDeclara=$anio;
                          $periadeclarar=$tperiodo;

                      endif;
                  
                      $fechas=  $this->contribuyente_m->devuelve_periodo_gravable($id,$periadeclarar,$anioDeclara); 
                      
                      $existe=  $this->contribuyente_m->verifica_declarcion_existe($this->session->userdata('id'),$fechas['id']);
                     
                      if($existe['existe']=='false'):
                      
                              $posicion=explode('-', $fechas['limite']);
                              $inicio='01-'.$posicion[1].'-'.$posicion[0];
            //                $fechas=$this->funciones_complemento->periodo_grvable_fechas($periodo['periodo'],$tperiodo,$anio); 
        //                      $contribuid=  $this->load->contribuyente_m->id_contribuyente(strtoupper($this->session->userdata('id')));                      
                              $data=array('tabla'=>'datos.conusu','where'=>array('id'=>$this->session->userdata('id')),'respuesta'=>array('rif','id')); 

                              $valor=$this->operaciones_bd->seleciona_BD($data); 
//                              print_r($valor);
                              $aniVeri=  substr($anioDeclara,2,2);
//                                V181643907-1-2-01-13-0000500000-4
//                                V181643907-4-6-01-11-0025000000-3
//                                V181643907-4-6-01-10-0025000000-6
//                                V181643907-1-2-09-13-0050000000-10
                              $totalVerificado=  $this->funciones_complemento->numero_depostido_bancario($total);

                              $ndeposito=$valor['variable0'].$id.$tdeclaracion.$periadeclarar.$aniVeri.$totalVerificado;

                              $validadorBanco=$this->funciones_complemento->numero_verificador($ndeposito);

                              $datos=array(
//                                            'nudeclara'=>$ndeposito.$validadorBanco,
                                            'tdeclaraid'=>$tdeclaracion,
                                            'fechaelab'=>"now()",
                                            'fechaini'=>$inicio,
                                            'fechafin'=>$fechas["limite"], 
                                            'replegalid'=>$replegalid['variable0'],
                                            'baseimpo'=>str_replace(",",".",str_replace(".","",$base)),
                                            'alicuota'=>$alicuota,
                                            'exonera'=>$exhoneracion, 
                                            'credfiscal'=>$cfiscal, 
                                            'usuarioid'=>$this->session->userdata('id'),
                                            'ip'=>$this->input->ip_address(),
                                            'tipocontribuid'=>$id,
                                            'conusuid'=>$this->session->userdata('id'),
                                            'montopagar'=>$total,
                                            'calpagodid'=>$fechas['id'],
                                            'bln_declaro0'=>($total==0 ? 'true' : 'false'),
                                            'ident_banco'=>$validadorBanco
                                        );
                            $tabla='datos.declara';

                            $result=$this->operaciones_bd->insertar_BD(1,$datos,$tabla,0);
                        
                        else:
                         
                           $result=array('resultado'=>false,'mensaje'=>$existe['mensage'],'iddeclara'=>$existe['id']); 
                            
                    endif;
                    echo json_encode($result);
            
                
            endif;
        
        

    }
    function declaracion_exitosa(){
        
         $id=  $this->input->get('declaraid');
         
     
         $result=$this->contribuyente_m->datos_declaracion($id);
            $result['ident']=$this->input->get('ident');
         $this->load->view('declaracion_exitosa_v',$result);
    }
    
    function imprime_declaracion(){
//        $this->load->view('ejemplo0');
        $datos['planilla']=$this->contribuyente_m->datos_planilla_declara($this->input->get('id_declara'));
//        print_r($datos);die;
        $this->funciones_complemento->generar_pdf_html('vistas_pdf/planilla_declaracion_v',$datos,'planilla de declaracion.pdf','D');
//        $data=array(
//                 //id_declaracion parametro que recibe de la vista, al hacer clic en el boton
//                 //declara_id parametro que recibe de el jrxml
//                 'parametros'=>array('declaraid'=>$this->input->get('id_declaracion')),
//                 'archivo'=>'planilladecl.jrxml',
//                 
//             );
//              $this->load->view('reportes_v',$data);
    }
    function imprime_planilla_multa_interes(){
      $tipo=$this->input->get('tipo');  
      $id=$this->input->get('id_multa'); 
      switch ($tipo) {
          case 1:
                $datos['planilla']=$this->contribuyente_m->datos_planilla_multa_interes_extem($id);
//                print_r($datos);die;
              $this->funciones_complemento->generar_pdf_html('vistas_pdf/planilla_multas_intereses_extemp_v',$datos,'planilla_multa_extemporanea.pdf','D');

              break;

          case 2:
                $condiciones=array("idreparo"=>$id);
                $data=  $this->contribuyente_m->datos_multas_culm_sum($condiciones);
                $datos['planilla']=  $this->__limpia_datos_multa($data);
                $datos['cadena']='CNAC/RCF-';
                $this->funciones_complemento->generar_pdf_html('vistas_pdf/planilla_multas_intereses_culm_sum_v',$datos,'planilla_multa_culm.pdf','D');
              break;
          case 3:
                $condiciones=array("idreparo"=>$id);
                $data=  $this->contribuyente_m->datos_multas_culm_sum($condiciones);
                $datos['planilla']=  $this->__limpia_datos_multa($data);
                $datos['cadena']='CNAC/RCS-';
                $this->funciones_complemento->generar_pdf_html('vistas_pdf/planilla_multas_intereses_culm_sum_v',$datos,'planilla_multa_sum.pdf','D');
              

              break;
      }
        
      

    }
    function declaraciones_realizadas_enreparo(){
        
        $result['data']=$this->contribuyente_m->devuelve_reparos_activados();
//        print_r($result);die;
        
        $this->load->view('declaraciones_realizadas_enreparo_v',$result);
    }
    
    function listado_multas_extemporaneas(){
        
        $result['data']=$this->contribuyente_m->devuelve_multas($this->session->userdata('id'),4);
//        print_r($result);die;
        $this->load->view('listado_multas_extemporaneas_v',$result);
    }
    function listado_multas_culminatoria(){
        $condiciones=array("idconusu"=>$this->session->userdata('id'),"proceso_multa"=>'notificado',"tipo_multa"=>5,"deposito_multa"=>NULL);
        $data=  $this->contribuyente_m->datos_multas_culm_sum($condiciones);
        $result['data']=  $this->__limpia_datos_multa($data);
//        print_r($result);die;
        $this->load->view('listado_multas_culminatoriaf_v',$result);
    }
    function listado_multas_sumario(){
        
        $condiciones=array("idconusu"=>$this->session->userdata('id'),"proceso_multa"=>'notificado',"tipo_multa"=>8,"deposito_multa"=>NULL);
        $data=  $this->contribuyente_m->datos_multas_culm_sum($condiciones);
        $result['data']=  $this->__limpia_datos_multa($data);;
//        print_r($result);die;
        $this->load->view('listado_multas_sumario_v',$result);
    }
    
    function listado_detalle_intereses(){
        $result['dinteres']=  $this->contribuyente_m->detalles_interes($this->input->post('id'));
        $result['id']=$this->input->post('id');
         $vista=$this->load->view('detalles_interes_v',$result,true);
         echo json_encode(array('resultado'=>true,'vista'=>$vista));
    }
    
    function detalles_reparo(){
            
            $id_reparo=$this->input->post("id");        
            $data['data']=  $this->contribuyente_m->devuelve_detalles_reparos($id_reparo);
            $vista=$this->load->view('detalles_reparos_v',$data,true);
            
            if($vista):
                
                echo json_encode(array('resultado'=>true,'vista'=>$vista));
            
            endif;
            
            
        }
        
        function __limpia_datos_multa($data){
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
        return array_values($data_limpia);   

    }
    
    
}
?>
