<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

require_once APPPATH.'modules/mod_contribuyente/controllers/contribuyente_c.php';
//sleep(2);
class Fiscalizacion_c extends Contribuyente_c {


	
	public function index()
	{
             $this->load->model('mod_gestioncontribuyente/fiscalizacion_m');
             $data['data']=$this->fiscalizacion_m->contribuyentes_asignados($this->session->userdata('id'));
            
		$this->load->view('asignaciones_v',$data);
	}
        
        function cargar_datos_inspeccion(){
            
            $id=$this->input->get('valor');
            
            $this->load->model('mod_gestioncontribuyente/fiscalizacion_m');
           $data=$this->fiscalizacion_m->contribuyentes_fiscalizado($id);
           $data['inspeccionid']=$id;
           $data['detalles']=  $this->fiscalizacion_m->detalles_contribuyentes_fiscalizado($id,'true');
//           print_r($data);die;
            $this->load->view('carga_fiscalizacion_v',$data);
            
            
        }
        function cargar_datos_liquidados(){
            
           $id=$this->input->get('valor');
          
            
           $this->load->model('mod_gestioncontribuyente/fiscalizacion_m');
           $data=$this->fiscalizacion_m->contribuyentes_fiscalizado($id);
           $data['inspeccionid']=$id;
           $data['detalles']=  $this->fiscalizacion_m->detalles_contribuyentes_fiscalizado($id,'false');        
//           $data['detalles']='';
//           print_r($data);die;
            $this->load->view('carga_periodos_cancelados_v',$data);
        }


        function muestra_dialog_cragafis(){
             $id=$this->input->post('id');
             $idasigna=$this->input->post('idasig');
             $conusuid=$this->input->post('conusuid');
              $query=array('tabla'=>'datos.asignacion_fiscales','where'=>array('id'=>$idasigna),'respuesta'=>array('periodo_afiscalizar')); 
              $result_query=$this->operaciones_bd->seleciona_BD($query);
              
            $vista= $this->load->view('mod_administrador/formdialog_v',$data=array('identificador'=>$this->input->post('identificador'),'idcontribu'=>$id,'idasig'=>$idasigna,'conusuid'=>$conusuid,'anio'=>$result_query['variable0']),true);
            $respuesta=array('resultado'=>true,'vista'=>$vista);
           echo json_encode($respuesta);
        }
        
        function carga_vistas_pestanas_fiscalizacion(){
            
          $vista=  $this->input->get('vista');
          $conusuid=$this->input->get('conusuid');
          $this->load->model('mod_gestioncontribuyente/fiscalizacion_m');
          $datos=$this->fiscalizacion_m->datos_complementarios_contribuyente($conusuid);
          //          print_r($datos);die;
          $this->load->view($vista,$datos);
        }
        
        function actualizar_datos_regisro_mercantil(){
            
            $datos=array(

                        'dw'=>array('rif'=>$this->input->post('rifconusu')),
                        'dac'=>array('domfiscal'=>$this->input->post('domifiscal'),
                                    'capitalpag'=>$this->input->post('capitalpag'),
                                    'capitalsus'=>$this->input->post('capitalsus'),
                                    'rmfechapro'=>$this->input->post('rmfechapro'),
                                    'rmfolio'=>$this->input->post('rmfolio'),
                                    'rmncontrol'=>$this->input->post('rmncontrol'),
                                    'rmnumero'=>$this->input->post('rmnumero'),
                                    'rmobjeto'=>$this->input->post('rmobjeto'),
                                    'rmtomo'=>$this->input->post('rmtomo'),
                                    'regmerofc'=>$this->input->post('regmerofc')
                    
                                    ),
                        'tabla'=>'datos.contribu'
                );
            $result=  $this->operaciones_bd->actualizar_BD(1,$datos);
            $result['conusuid']=$this->input->post('conusuid');
             echo json_encode($result);
            
        }


        function carga_detalles_fizcalizacion(){
           
           $id=$this->input->post('tcontribuid');
           $anio=$this->input->post('anio');  
           $base=$this->input->post('base');  
           $periodo=$this->input->post('periodo');
           $idasigna=$this->input->post('idasigna');
           $descripcion=$this->input->post('descripcion');
           $conusuid=$this->input->post('conusuid');
           
//           $base_limpia=  str_replace(",",".",str_replace(array('.',','),"", $base));
//                 
            $base_limpia=str_replace(",",".",str_replace(".","", $base));      
//            print_r($base_limpia);die;  
           $data=$this->calculoDeclaracion(1,$id,$anio,$base_limpia,$periodo);
//          print_r($data); die;
          
                  
                     if(empty($anio)):
                         
                            $fechas=  $this->contribuyente_m->devuelve_periodo_gravable($id,'01',$periodo); 

                        else:
                            
                            $fechas=  $this->contribuyente_m->devuelve_periodo_gravable($id,$periodo,$anio);

                      endif;
                       $busca=array('tabla'=>'datos.declara','where'=>array('calpagodid'=>$fechas['id'],'conusuid'=>$conusuid),'respuesta'=>array('id')); 
                       $verifica=$this->operaciones_bd->seleciona_BD($busca);
                       if($descripcion=='true'):                          
                      
                          (empty($verifica)? $pasa=false: $pasa=true);
                       
                          $mensaje='No existe declaracion para este periodo a la cual se le va referenciar el faltante';
                          $mensaje2='"PARA CORREGIR CARGUE LA DECLARCION CORRESPONDDIENTE"';
                          else:                          
                          
                          (empty($verifica)? $pasa=true : $pasa=false);
                          
                          $mensaje='ya existe una declarcion para este periodo';
                          $mensaje2='"PARA ESTE PERIODO SOLO PUEDE CARGAR UN REPARO POR FALTANTE"';
                          
                      endif;                     

                      
                      if($pasa):
                        
                  
                            $this->load->model('mod_gestioncontribuyente/fiscalizacion_m');
                            $existe=  $this->fiscalizacion_m->verifica_periodo_existe($fechas['id'],$idasigna,'true'); 
                 //           
                 //          print_r($existe); die;
                            if(!$existe):  

                                if(!$data['fueraRango']):  

                                     $datos=array('periodo'=>$periodo,
                                                  'anio'=>$anio,
                                                  'base'=>$base_limpia,
                                                  'alicuota'=>$data['alicuota'],
                                                  'total'=>$data['total'],
                                                  'asignacionfid'=>$idasigna,
                                                  'calpagodid'=>$fechas['id'],
                                                  'bln_reparo_faltante'=>$descripcion
                                                                 );
                                     $tabla='datos.dettalles_fizcalizacion';


                                else:

                                      $datos=array('periodo'=>$periodo,
                                                  'anio'=>$anio,
                                                  'base'=>$base_limpia,
                                                  'alicuota'=>0,
                                                  'total'=>0,
                                                  'asignacionfid'=>$idasigna,
                                                  'calpagodid'=>$fechas['id'],
                                                  'bln_reparo_faltante'=>$descripcion
                                                                 );
                                     $tabla='datos.dettalles_fizcalizacion';


                                endif;
                                $result=$this->operaciones_bd->insertar_BD(1,$datos,$tabla,0);

                             else:

                                     $result=array('resultado'=>"false",'existe_p'=>$existe);

                             endif;
                    else:
                        
                         $result=array('resultado'=>"false",'faltadeclara'=>true,'mensaje'=>$mensaje,'mensaje2'=>$mensaje2);        
                             
                    endif;
            
            echo json_encode($result);
           
       }
       
       function elimina_detalles_fiscalizacion(){           
          
           
            $datos=array(

                        'dw'=>array('id'=>$this->input->post('id')),
                        'dac'=>array('bln_borrado'=>'true'),
                        'tabla'=>'datos.dettalles_fizcalizacion'


                );
            $result=$this->operaciones_bd->actualizar_BD(1,$datos);
            
            echo json_encode($result);
       }
       /*
        * busquedad del correlativo que sigue segun su acta
        * 
        * @access public
        * @param null
	* @return array_json  
        *      
        */
       function busca_correlativo()
       {
         $tipo=$this->input->post('tipo'); 
         ($tipo=='true'? $identificador='act-cfis-2' : $identificador='act-rpfis-1' );
         $query=array('tabla'=>'datos.correlativos_actas','where'=>array('tipo'=>$identificador),'respuesta'=>array('correlativo','anio')); 
         $result_query=$this->operaciones_bd->seleciona_BD($query);
//         print_r($result_query);die;
         ($result_query['variable1']==date('Y')? $return=$result_query['variable0'] : $return=1);
         
         if(isset($return)): echo json_encode(array('resultado'=>true,'nacta'=>$return)); else: echo json_encode(array('resultado'=>FALSE) ); endif;
           
       }
       /*
        * subida al servidor del acta de reparo e insert en la tabla actas_reparo
        * 
        * @access public
        * @param null
	* @return array_json  
        *      
        */
       function subir_acta_reparo()
       {
//            sleep(3);
            $this->load->library(array('upload', 'form_validation'));
            $this->load->helper(array('form', 'string'));
            
            $estatus = '';
            $background = '';
            $idacta='';
             $query=array('tabla'=>'datos.correlativos_actas','where'=>array('tipo'=>'act-rpfis-1','anio'=>date('Y')),'respuesta'=>array('correlativo')); 
             $result_query=$this->operaciones_bd->seleciona_BD($query);
             
//             print_r($result_query);die;
            if(count($result_query)>0): 
                
                 if($result_query['variable0']!=$this->input->post('title')): $estatus='error'; $mensaje = 'el numero de acta no es el correcto, el numero que sigue es'.$result_query['variable0'].'por favor modifiquelo e intente de nuevo'; endif;

            else: 
                
               if($this->input->post('title')!='1'): $estatus='error'; $mensaje = 'el numero de acta no es el correcto, el numero que sigue es "1" por favor modifiquelo e intente de nuevo'; endif;    

            endif;
            // se obtiene la extencion del archivo a subir en el servidor
            $extencion=strtolower(ltrim('.'.end(explode('.',$_FILES['archivo_adjunto']['name'])),'.'));
            
            //el name del campo del formulario que es type=file
            $nombre_elemento_archivo = 'archivo_adjunto';
            
            //trampa para evitar que se suban archivos distintos que .doc y pdf ya que la libreria upload de codeignier
            // sube estos archico unicamente si en a el allowed_types le colocas igual a *, el * le dice a upload que suba todo los tipos de archivos
            // existentes si no le pones * no reconoces los .doc            
            if(($extencion!='doc') and ($extencion!='pdf') ): $estatus='error'; $mensaje = 'Solo puede adjuntar archivos pdf(.pdf) o word(.doc)';  endif;
            
            if ($estatus != 'error')
            {  
                //Ruta donde se guarda la imagen completa
                $configuracion['upload_path'] = './archivos/fiscalizacion/'.date("Y").'/';
                //formatos del allowed_types:'gif|jpg|png|doc|docx|pdf|txt|xsl|xslx|html|odf|rar|zip|7zip';
                $configuracion['allowed_types'] = '*';//le decimos que tome todo los formatos con *
                // tamaño maximo que permite la liberia upload de codeigniter del archivo a subir
                $configuracion['max_size'] = '1024';
                // le indicamo si queremos que sobreescriba archios con el mismo nombre valor true si no false
                $configuracion['overwrite'] = FALSE;
                // le indicamo que encripte el nombre del archivo subido valor true si no false
                $configuracion['encrypt_name'] = TRUE;
                // le indicamos que a los espacios en blancos los cambie por piso valor true si no false
                $configuracion['remove_spaces'] = TRUE;
                // inicializamos la configuracion en la libreria upload
                $this->upload->initialize($configuracion);
                
                // verificamos que exista la carpeta y si no existe se crea con permisos 777
                if(!$this->upload->validate_upload_path()): mkdir($_SERVER['DOCUMENT_ROOT'] .'/fonprosys_code/archivos/fiscalizacion/'.date("Y").'/',0777); endif;

                //Se verifica si el archivo fue cargado al servidor
                if (!$this->upload->do_upload($nombre_elemento_archivo)) {    
                        $estatus = FALSE;
                        // obtenemos que tipo de error tuvo la carga para mostrar en la vista
                        $mensaje = $this->upload->display_errors('', '');
                }else{
//                        // obtenemos toda la informacion del archivo subido
                        $data = $this->upload->data();

                        $data_imagen = array(
                            'ruta_servidor'=>$configuracion['upload_path'].$data['file_name'],
                            'usuarioid'=>$this->session->userdata('id'),
                            'ip'=>$this->input->ip_address());
//
//                        //Se guarda los datos del archivo en BD
                        $this->load->model('mod_gestioncontribuyente/fiscalizacion_m');
                        $resul_acta_reparo=$this->fiscalizacion_m->guarda_actareparo($data_imagen);                            

                        if ($resul_acta_reparo!=FALSE) {  // Archivo agregado correctamente a la BD
                            $estatus = true;
                            $mensaje = 'Archivo subido correctamente';
                            $idacta=$resul_acta_reparo;


                        } else {    // Si no fue agregado
                            
                             unlink($configuracion['upload_path'].$data['file_name']); #borra archivo
                            $estatus = false;
                            $mensaje = 'No se pudo adjuntar el archivo';

                        }
                    }

                    @unlink($_FILES[$nombre_elemento_archivo]);

                }else{

                    $estatus = FALSE;
                                
                }

                print json_encode(array('idacta'=>$idacta,'mensaje' =>$mensaje,'estatus' => $estatus, 'background' => $background,'autorizacion'=>  $this->input->post('autorizacion'),'requerimiento'=>  $this->input->post('requerimiento'),'recepcion'=>  $this->input->post('recepcion')));
 
          
       }
       
       function crea_reparo(){
//           sleep(5);
           $conusuid=$this->input->post('idconusu');
           $idacta=$this->input->post('idacta');
//           echo $this->session->userdata('id'); die;
           $tcontribu=$this->input->post('tcontribu');
           $id=$this->input->post('inspeccionid');
           $this->load->model('mod_gestioncontribuyente/fiscalizacion_m');
           $monto=$this->fiscalizacion_m->devuelve_monto_reparo($id);
           $reparo=  array(               
                    'tdeclaraid'=>6,
                    'fechaelab'=>'now()',
                    'montopagar'=>$monto,
                    'usuarioid'=>$this->session->userdata('id'),
                    'ip'=>$this->input->ip_address(),
                    'tipocontribuid'=>$tcontribu,
                    'conusuid'=>$conusuid,
                    'actaid'=>$idacta,
                    'asignacionid'=>$id,
                    'fecha_autorizacion'=>  $this->input->post('autorizacion'),
                    'fecha_requerimiento'=>  $this->input->post('requerimiento'),
                    'fecha_recepcion'=>  $this->input->post('recepcion')
                    );          

           $declarciones=$this->datos_para_declara($tcontribu,$id,$conusuid);
//           print_r($reparo);die;
           $data=$this->fiscalizacion_m->crea_reparo($reparo,$declarciones,$id);

           if($data){
               
              echo json_encode(array('resultado'=>true));
           }
       }
       
       function datos_para_declara($tcontribuyente,$id,$conusuid){
           $this->load->model('mod_contribuyente/contribuyente_m');
//         $periodo=$this->contribuyente_m->verifica_pgravable($tcontribuyente);
           $result= $this->fiscalizacion_m->detalles_contribuyentes_fiscalizado($id,'true');
           
           foreach ($result as $clave=>$valor):
               $totalVerificado=  $this->funciones_complemento->numero_depostido_bancario($valor['total']);
                    if($valor['anio']==0):
                        
                         $fechas=  $this->contribuyente_m->devuelve_periodo_gravable($tcontribuyente,'01',$valor['periodo']);           
                         $periodo='01';
                         $anio=$valor['periodo'];
                         else:
                             
                             if($valor['periodo']<10):
                                 
                                 $periodo='0'.$valor['periodo'];
                             else:
                                 
                                 $periodo=$valor['periodo'];
                             
                             endif;
                             
                          $fechas=  $this->contribuyente_m->devuelve_periodo_gravable($tcontribuyente,$periodo,$valor['anio']);           
                          $anio=$valor['anio']; 
                     endif;
                     
               $posicion=explode('-', $fechas['limite']);
               $inicio='01-'.$posicion[1].'-'.$posicion[0]; 
               
               //OBTENGO LOS DOS ULTIMS DIGITOS DEL AÑO 
                  $aniVeri=  substr($anio,2,2);
                  //BUSCO EL RIF DEL CONTRIBUYENTE LOGUEADO
                  $data=array('tabla'=>'datos.conusu','where'=>array('id'=>$conusuid),'respuesta'=>array('rif','id')); 

                  $valor2=$this->operaciones_bd->seleciona_BD($data);
                  //ARMO EL NUMERO DE DEPOSITO
                  ($valor['repafaltante']=='t'? $tdeclara='3': $tdeclara='6' );
                  
                  $ndeposito=$valor2['variable0'].$tcontribuyente.$tdeclara.$periodo.$aniVeri.$totalVerificado;
                  //OBRTENGO EL NUMERO VALIDADOR DEL BANCO
                  $validadorBanco=$this->funciones_complemento->numero_verificador($ndeposito);
               
               
               if($valor['repafaltante']=='t'):                                      
                   
                   
                        $id_declara=  $this->fiscalizacion_m->devuelve_id_declara($tcontribuyente,$valor['calpagodid'],$conusuid);
                        $datos[]=array(
                                     'nudeclara'=>$ndeposito.$validadorBanco,
                                     'tdeclaraid'=>3,
                                     'fechaelab'=>'now()',
                                     'fechaini'=>$inicio,
                                     'fechafin'=>$fechas['limite'], 
                                     'replegalid'=>"4",
                                     'baseimpo'=>$valor['base'],
                                     'alicuota'=>$valor['alicuota'],
                                     'exonera'=>0, 
                                     'credfiscal'=>0, 
                                     'plasustid'=>$id_declara,
                                     'usuarioid'=>"17",
                                     'ip'=>$this->input->ip_address(),
                                     'tipocontribuid'=>$tcontribuyente,
                                     'conusuid'=>$conusuid,
                                     'montopagar'=>$valor['total'],
                                     'bln_reparo'=>'true',
                                     'calpagodid'=>$valor['calpagodid'],
                                     'bln_declaro0'=>($valor['total']==0 ? 'true' : 'false')
                                     

                                 );
               else:
                   
                   
               
//                    echo $id_declara;die;
                    $datos[]=array(
                                     'nudeclara'=>$ndeposito.$validadorBanco,
                                     'tdeclaraid'=>6,
                                     'fechaelab'=>"now()",
                                     'fechaini'=>$inicio,
                                     'fechafin'=>$fechas['limite'], 
                                     'replegalid'=>"4",
                                     'baseimpo'=>$valor['base'],
                                     'alicuota'=>$valor['alicuota'],
                                     'exonera'=>0, 
                                     'credfiscal'=>0,                                     
                                     'usuarioid'=>"17",
                                     'ip'=>$this->input->ip_address(),
                                     'tipocontribuid'=>$tcontribuyente,
                                     'conusuid'=>$conusuid,
                                     'montopagar'=>$valor['total'],
                                     'bln_reparo'=>'true',
                                     'calpagodid'=>$valor['calpagodid'],
                                     'bln_declaro0'=>($valor['total']==0 ? 'true' : 'false')

                                 );
                   
               endif;
           endforeach;
       return $datos;
           
           
       }
       
       function carga_periodos_pagados(){
           
          
           $total=$this->input->post('tpagado');
           $fecha_pago=  $this->input->post('fpago');
           $id=$this->input->post('tcontribuid');
           $anio=$this->input->post('anio');  
           $base=$this->input->post('base');  
           $periodo=$this->input->post('periodopcancelado');
           $idasigna=$this->input->post('idasigna');
           $conusuid=$this->input->post('conusuid');
          $base_limpia=  str_replace(",",".",str_replace(array('.',','),"", $base));
          $total_limpio=str_replace(",",".",str_replace(array('.',','),"", $total));
          $data=$this->calculoDeclaracion(1,$id,$anio,$base_limpia,$periodo);
//          print_r($data); die;

                  
                     if(empty($anio)):
                         
                            $fechas=  $this->contribuyente_m->devuelve_periodo_gravable($id,'01',$periodo); 

                        else:
                            
                            $fechas=  $this->contribuyente_m->devuelve_periodo_gravable($id,$periodo,$anio);

                      endif;
                    $busca=array('tabla'=>'datos.declara','where'=>array('calpagodid'=>$fechas['id'],'conusuid'=>$conusuid),'respuesta'=>array('id')); 
                    $verifica=$this->operaciones_bd->seleciona_BD($busca);
                    
                    if(empty($verifica)):
                        
                                $this->load->model('mod_gestioncontribuyente/fiscalizacion_m');
                                $existe=  $this->fiscalizacion_m->verifica_periodo_existe($fechas['id'],$idasigna,'false'); 
                     //           
                     //          print_r($existe); die;
                                if(!$existe):  

                                            if(!$data['fueraRango']):  

                                                            $datos['datos.dettalles_fizcalizacion']=array('periodo'=>$periodo,
                                                              'anio'=>$anio,
                                                              'base'=>$base_limpia,
                                                              'alicuota'=>$data['alicuota'],
                                                              'total'=>$total_limpio,
                                                              'asignacionfid'=>$idasigna,
                                                              'calpagodid'=>$fechas['id'],
                                                                'bln_identificador'=>'false');
            //                                     $tabla='datos.dettalles_fizcalizacion';


                                            else:

                                                            $datos['datos.dettalles_fizcalizacion']=array('periodo'=>$periodo,
                                                              'anio'=>$anio,
                                                              'base'=>$base_limpia,
                                                              'alicuota'=>0,
                                                              'total'=>0,
                                                              'asignacionfid'=>$idasigna,
                                                              'calpagodid'=>$fechas['id'],
                                                              'bln_identificador'=>'false');
            //                                     $tabla='datos.dettalles_fizcalizacion';


                                            endif;                    
                                $posicion=explode('-', $fechas['limite']);
                                $inicio='01-'.$posicion[1].'-'.$posicion[0];


                                $datos['datos.declara']=array(
                                                 'tdeclaraid'=>2,
                                                 'fechaelab'=>"now()",
                                                 'fechaini'=>$inicio,
                                                 'fechafin'=>$fechas['limite'], 
                                                 'replegalid'=>"4",
                                                 'baseimpo'=>$base_limpia,
                                                 'alicuota'=>$data['alicuota'],
                                                 'exonera'=>0, 
                                                 'credfiscal'=>0,                                     
                                                 'usuarioid'=>"17",
                                                 'ip'=>$this->input->ip_address(),
                                                 'tipocontribuid'=>$id,
                                                 'conusuid'=>$conusuid/*ojo*/,
                                                 'montopagar'=>$total_limpio,
                                                 'bln_reparo'=>'false',
                                                 'fechapago'=>$fecha_pago,
                                                 'calpagodid'=>$fechas['id']/*ojo*/,
                                                 'reparoid'=>0,
                                                 'bln_declaro0'=>($total_limpio==0 ? 'true' : 'false')

                                             );
            //                    print_r($datos); die;

                                $result=$this->operaciones_bd->insertar_BD(2,$datos,0,0);
                        else:

                                $result=array('resultado'=>"false",'existe_p'=>$existe);

                        endif;
                        
                    
                
               else:
                    $result=array('resultado'=>"false",'faltadeclara'=>true,'mensaje'=>'ya existe una declarcion para este periodo','mensaje2'=>'"PARA ESTE PERIODO SOLO PUEDE CARGAR UN REPARO POR FALTANTE"'); 
                    
                endif;    
            echo json_encode($result);
           
       }
       
        /*
        * actas_fiscalizacion:funcion donde se genera el pdf de las actas para fiscalizacion
        *                               
        * @access public
        *
        */       
       function actas_fiscalizacion()
       {           
            $id=$this->input->get('id'); 
            $tipocont=  $this->input->get('tipocont');
            $tipo_acta=$this->input->get('tipo_acta'); 
            
            switch ($tipo_acta)
             {
                 case 1:

                     $datos=$this->datos_autorizacion_fiscal($id,$tipocont,$this->input->get('nro_autorizacion'));                  
                     $datos['cuerpo']['nro_autorizacion']='CNAC/FONPROCINE/GFT/AF-'.$this->input->get('nro_autorizacion');
                     $nombre_pdf='Autorizacion Fiscal.pdf';
//                     print_r($datos);die;            
                     $this->funciones_complemento->generar_pdf_html('html_pdfs/autorizacion_fiscal_v',$datos,$nombre_pdf,'D');
//                     
                     break;
                     case 2:
                        
                        $datos=$this->datos_acta_requerimento($id,$tipocont,$this->input->get('nro_autorizacion'));                       
                        $datos['cuerpo']['nro_autorizacion']='CNAC/FONPROCINE/GFT/AR-'.$this->input->get('nro_autorizacion');
                        $datos['cuerpo']['correlativo']=$this->input->get('nro_autorizacion');
                        $nombre_pdf='Acta de requerimientos.pdf';  
//                        print_r($datos);die;  
                        $this->funciones_complemento->generar_pdf_html('html_pdfs/acta_requerimientos_v',$datos,$nombre_pdf,'D');
//                        $this->load->library('pdf');        
//                        $this->pdf->FPDF('P','mm','Legal');   
//                        $this->pdf->ImprimirArchivo($post_header,$titulo_acta,$ruta_txt,$datos,$nombre_pdf,$tipo_firma);
                         break;
                         case 3:
                             $datos=$this->datos_acta_requerimento($id,$tipocont,$this->input->get('nro_autorizacion'));                       
                        $datos['cuerpo']['nro_autorizacion']='CNAC/FONPROCINE/GFT/AR-'.$this->input->get('nro_autorizacion');
                        $datos['cuerpo']['correlativo']=$this->input->get('nro_autorizacion');                       
                        $nombre_pdf='Acta de Recepcion.pdf';
                        
                        $this->funciones_complemento->generar_pdf_html('html_pdfs/acta_recepcion_v.php',$datos,$nombre_pdf,'D');
//                                            
                        break;
             }
                   
            
            
            
       }
       
       /*
        * datos_atorizacion_fiscal:funcion donde se obtienen los datos necesarios para 
        *                          armar el pdf con el acta que autoriza la fiscalizacion                                  
        * @access private
        * @param integer 
        * @return array      
        */       
       private function datos_autorizacion_fiscal($id,$tipocont,$nroautorizacion)
       {   
           // armamos los datos principales de la cabecera despues del titulo
           $this->load->model('fiscalizacion_m');
           $result['principales']=$this->fiscalizacion_m->datos_actas_fiscalizacion($id,$tipocont,$nroautorizacion);
           
           // armamos el arreglo que va a contener los datos del cuerdpo del pdf
           $datos_gerente_general=$this->fiscalizacion_m->datos_gerente_general();
           
           $query_datos_fiscal=array('tabla'=>'datos.usfonpro',
                         'where'=>array("id"=>  $this->session->userdata('id')),
                         'respuesta'=>array('nombre','cedula'));           
            $result['cuerpo']=$this->operaciones_bd->seleciona_BD($query_datos_fiscal);
            
            $result['cuerpo']['tipocont']=$result['principales']['tipocontribu'];
            $result['cuerpo']['articulo']=$result['principales']['articulo'];
            $result['cuerpo']['gerenteg']=$datos_gerente_general['gerenteg']; 
            $result['cuerpo']['cedulagg']=$datos_gerente_general['gerentegcedula'];
            
            // armamos los datos de la firma del documento
            $query_datos_presidente=array('tabla'=>'datos.presidente',
                         'where'=>array("bln_activo"=>'true'),
                         'respuesta'=>array('nombres','apellidos','nro_decreto','nro_gaceta','dtm_fecha_gaceta'));
            $result['firma']=$this->operaciones_bd->seleciona_BD($query_datos_presidente);
           
           return $result;
       }
       /*
        * datos_acta_requerimento:funcion donde se obtienen los datos necesarios para 
        *                          armar el pdf con el acta de requerimientos                                  
        * @access private
        * @param integer 
        * @return array      
        */       
       private function datos_acta_requerimento($id,$tipocont,$nroautorizacion)
       {   
           $this->load->model('fiscalizacion_m');
           $result['cuerpo']=$this->fiscalizacion_m->datos_actas_fiscalizacion($id,$tipocont,$nroautorizacion); 
           
           $query_datos_fiscal=array('tabla'=>'datos.usfonpro',
                         'where'=>array("id"=>  $this->session->userdata('id')),
                         'respuesta'=>array('nombre','cedula'));           
            $fiscal=$this->operaciones_bd->seleciona_BD($query_datos_fiscal);
            
            $result['cuerpo']['nomfiscal']=$fiscal['variable0'];
            $result['cuerpo']['cedfiscal']=$fiscal['variable1'];
            
            return $result;
       }
       
       

//       
}