<?php
    class Lista_contribuyentes_general_c extends CI_Controller{
        
        function __construct() {
            parent::__construct();
            $this->load->model('mod_gestioncontribuyente/lista_contribuyentes_general_m');
        }
        function info_contribuyente($parametros_consulta=array()){      
            if(is_array($parametros_consulta)):
                foreach ($parametros_consulta as $nombre => $valor):
                    $this->$nombre = $valor;
                endforeach;
            endif;
            $nroaut=0;
            $omisos =array();
            $omisos_declara =array();
            $extemporaneos =array();
            $pagados = array();
            $dentro_limite_pago = array();
            $reparo = array();
            $dia_actual = date("d");
            $mes_actual = date("m");
            $anio_actual = date("Y");          
            $datos_periodos_grav= array();
//            print($this->vienefis);die;
            if(isset($this->vienefis)): $condicion_omiso=TRUE; $nroaut=$this->vienefis;  else: $condicion_omiso=FALSE;  endif;
            
            if (isset($this->filtro_extemporaneo)):

                    $estatus_proceso_declara = array();
                    $estatus_proceso_declara[0] = '';
                    $estatus_proceso_declara[1] = 'enviado';
                    $estatus_proceso_declara[2] = 'calculado';
                    $estatus_compara = $estatus_proceso_declara[$this->filtro_extemporaneo];


            endif;

            if(isset($this->id)):
                $datos_conusu = $this->lista_contribuyentes_general_m->verifica_conusu($this->id);
            else:
                $datos_conusu = false;
            endif;

            //inicio si existe el contribuyente
            if ($datos_conusu):
              $fecha_registro = explode('-',$datos_conusu[0]['fecha_registro']);
              $anio_registro = $fecha_registro[0];
              $mes_registro = $fecha_registro[1];
              $dia_registro = $fecha_registro[2];
              $datos_conusu_tcont = $this->lista_contribuyentes_general_m->busca_tipocont_conusu($datos_conusu[0]['id'],(isset($this->tipocontid_conusu) && !empty($this->tipocontid_conusu)? $this->tipocontid_conusu : ''));
            //inicio condicion si tipo contribuyente existe

              if ($datos_conusu_tcont):
                  //inicio ciclo tipo contribuyente
                  foreach ($datos_conusu_tcont as $valor_tipocont):

                      $periodo_registro = $this->funciones_complemento->define_periodo($valor_tipocont['tcontid'],$mes_registro);
                      $periodo_vigente = $this->funciones_complemento->define_periodo($valor_tipocont['tcontid'],$mes_actual);
                      $datos_periodos_grav = $this->lista_contribuyentes_general_m->busca_periodo_gravable($valor_tipocont['tcontid'],$anio_registro);
                      $datos_busca_declaraciones = $this->lista_contribuyentes_general_m->busca_declaraciones(0,$datos_conusu[0]['id']);
//                      print_r($datos_busca_declaraciones);die;
                      //inicio ciclo de periodos
                      foreach ($datos_periodos_grav as $periodos):
                         
                          if(!empty($this->anio_filtro)):
                              if($periodos['ano']==$this->anio_filtro):
                              if(!empty($this->periodo_filtro) ):
                                  if($periodos['periodo']==$this->periodo_filtro):
                                      if ($datos_busca_declaraciones):
                                          $verifica=0;

                                               foreach ($datos_busca_declaraciones as $declaraciones):
                                                   
                                                    //Si existe en la tabla declara
                                                    if($periodos['id']==$declaraciones['calpagodid']):
                                                        $verifica++;
                                                       //si es distinta de cero la declaracion 
                                                       if($declaraciones['bln_declaro0']=='f'):
                                                        
                                                           if ($declaraciones['bln_reparo']=='f'):
                                                            
                                                                if ($periodos['ano']==$anio_registro):
                                                                    if($periodos['periodo']>=$periodo_registro):
                                                                        if($periodos['periodo']==$this->periodo_filtro):
                                                                            if (empty($declaraciones['fechapago'])):
                                                                                // verificamos si existe es año enviado a fiscalizar
                                                                                $verifica_period=$this->lista_contribuyentes_general_m->verifica_periodo_omiso_enfiscalizacion($this->id,$valor_tipocont['tcontid'],$declaraciones['ano'], $nroaut);
                                                                                if($verifica_period==$condicion_omiso):
                                                                                    if (strtotime("$anio_actual-$mes_actual-$dia_actual") > strtotime($periodos['fechalim'])):
                                                                                        if ($declaraciones['bln_reparo']=='f'):
                                                                                            $omisos_declara[] = $declaraciones;
                                                                                        else:
                                                                                            $reparo[] = $declaraciones;
                                                                                        endif; 
                                                                                    else:
                                                                                        $dentro_limite_pago[] = $declaraciones;
                                                                                    endif;
                                                                                endif;
                                                                            else:
                                                                                if (strtotime($declaraciones['fechapago']) > strtotime($periodos['fechalim'])):
                                                                                    if ($declaraciones['bln_reparo']=='f'):
                                                                                    // jefferosn 28/05/2013                                                                                
                                                                                        if (isset($this->filtro_extemporaneo)):
                                                                                            $datos_busca_declarciones_enviadas_finanzas= $this->lista_contribuyentes_general_m->busca_declarciones_enviadas_finanzas($datos_conusu[0]['id'],$declaraciones['id']);
                                                                                            if(!$datos_busca_declarciones_enviadas_finanzas): 
    //                                                                                            
                                                                                                $extemporaneos[] = $declaraciones;

                                                                                            endif;

                                                                                        else:
                                                                                            $extemporaneos[] = $declaraciones;
    //                                                                                    endif;
                                                                                    // fin jefferon

    //                                                                                    if (isset($this->filtro_extemporaneo)):
    //                                                                                        
    //                                                                                        if($declaraciones['proceso']==$estatus_compara):
    //                                                                                            $extemporaneos[] = $declaraciones;
    //                                                                                        endif;
    //                                                                                    else:
    //                                                                                        $extemporaneos[] = $declaraciones;
                                                                                        endif;

                                                                                    else:
                                                                                        $reparo[] = $declaraciones;
                                                                                    endif;
                                                                                else:
                                                                                    $pagados[] = $declaraciones;
                                                                                endif;

                                                                            endif;
                                                                        endif;

                                                                    endif;

                                                                else:
                                                                    if($periodos['ano']==$this->anio_filtro):
                                                                        if($periodos['periodo']==$this->periodo_filtro):
                                                                            if (empty($declaraciones['fechapago'])):
                                                                                // verificamos si existe es año enviado a fiscalizar
                                                                                $verifica_period=$this->lista_contribuyentes_general_m->verifica_periodo_omiso_enfiscalizacion($this->id,$valor_tipocont['tcontid'],$declaraciones['ano'], $nroaut);
                                                                                if($verifica_period==$condicion_omiso):
                                                                                    if (strtotime("$anio_actual-$mes_actual-$dia_actual") > strtotime($periodos['fechalim'])):
                                                                                        if ($declaraciones['bln_reparo']=='f'):
                                                                                            $omisos_declara[] = $declaraciones;
                                                                                        else:
                                                                                            $reparo[] = $declaraciones;
                                                                                        endif; 
                                                                                    else:
                                                                                        $dentro_limite_pago[] = $declaraciones;
                                                                                    endif;
                                                                                endif;
                                                                            else:
                                                                                if (strtotime($declaraciones['fechapago']) > strtotime($periodos['fechalim'])):
                                                                                    if ($declaraciones['bln_reparo']=='f'):
                                                                                    // jefferosn 28/05/2013                                                                                
                                                                                        if (isset($this->filtro_extemporaneo)):
                                                                                            $datos_busca_declarciones_enviadas_finanzas= $this->lista_contribuyentes_general_m->busca_declarciones_enviadas_finanzas($datos_conusu[0]['id'],$declaraciones['id']);
                                                                                            if(!$datos_busca_declarciones_enviadas_finanzas):  
    //                                                                                            
                                                                                                $extemporaneos[] = $declaraciones;

    //
                                                                                            endif;

                                                                                        else:
                                                                                            $extemporaneos[] = $declaraciones;
    //                                                                                    endif;
                                                                                    // fin jefferon

    //                                                                                    if (isset($this->filtro_extemporaneo)):
    //                                                                                        
    //                                                                                        if($declaraciones['proceso']==$estatus_compara):
    //                                                                                            $extemporaneos[] = $declaraciones;
    //                                                                                        endif;
    //                                                                                    else:
    //                                                                                        $extemporaneos[] = $declaraciones;
                                                                                        endif;

                                                                                    else:
                                                                                        $reparo[] = $declaraciones;
                                                                                    endif;
                                                                                else:
                                                                                    $pagados[] = $declaraciones;
                                                                                endif;

                                                                            endif;
                                                                        endif;
                                                                    endif;
                                                                endif;
        //                                                    else:
                                                        
                                                      // fin de la verificacion de si la declaracion fue cargada por reparo fiscal o no  
                                                      endif;
                                                      
                                                      else:
                                                          
                                                      endif;// fin si no es declarado en 0
                                                    //fin Si existe en la tabla declara
                                                    endif;
                                                    
                                                    endforeach;
                                                    if($verifica==0):
                                                        $verifica_period=$this->lista_contribuyentes_general_m->verifica_periodo_omiso_enfiscalizacion($this->id,$valor_tipocont['tcontid'],$periodos['ano'], $nroaut);
                                                        if($verifica_period==$condicion_omiso):
                                                            if(($periodos['ano']==$anio_actual) && ($periodos['periodo']==$periodo_vigente)):
                                                            else:
                                                                if ($periodos['ano']==$anio_registro):
                                                                    if($periodos['periodo']>=$periodo_registro):
                                                                        $omisos []= $periodos;

                                                                    endif;

                                                                else:
                                                                    $omisos []= $periodos;

                                                                endif;                                            
                                                            endif;
                                                        endif;
                                                    endif;

                                      else:                          
                                          $verifica_period=$this->lista_contribuyentes_general_m->verifica_periodo_omiso_enfiscalizacion($this->id,$valor_tipocont['tcontid'],$periodos['ano'], $nroaut);
                                                        if($verifica_period==$condicion_omiso):
                                                            if(($periodos['ano']==$anio_actual) && ($periodos['periodo']==$periodo_vigente)):
                                                            else:
                                                                if ($periodos['ano']==$anio_registro):
                                                                    if($periodos['periodo']>=$periodo_registro):
                                                                        $omisos []= $periodos;

                                                                    endif;

                                                                else:
                                                                    $omisos []= $periodos;

                                                                endif;                                            
                                                            endif;
                                                        endif;
                                      endif;
                                  if(($periodos['ano']==$anio_actual) && ($periodos['periodo']==$periodo_vigente)):
                                      break;
                                  endif; 
                               endif;
                              else: //sino periodo filtro vacio
//                                  
                                  if ($datos_busca_declaraciones):
                                      $verifica=0;

                                              foreach ($datos_busca_declaraciones as $declaraciones):
                                               
                                                //Si existe en la tabla declara
                                                if($periodos['id']==$declaraciones['calpagodid']):
                                                    $verifica++;
                                                    //si es distinta de cero la declaracion 
                                                  if($declaraciones['bln_declaro0']=='f'):
                                                    
                                                      if ($declaraciones['bln_reparo']=='f'):
                                                        
//                                                    print($this->anio_filtro); die;
                                                        if ($periodos['ano']==$anio_registro):
                                                            if($periodos['periodo']>=$periodo_registro):
                                                                if (empty($declaraciones['fechapago'])):
                                                                    // verificamos si existe es año enviado a fiscalizar
                                                                                $verifica_period=$this->lista_contribuyentes_general_m->verifica_periodo_omiso_enfiscalizacion($this->id,$valor_tipocont['tcontid'],$declaraciones['ano'], $nroaut);
                                                                                if($verifica_period==$condicion_omiso):
                                                                                    if (strtotime("$anio_actual-$mes_actual-$dia_actual") > strtotime($periodos['fechalim'])):
                                                                                        if ($declaraciones['bln_reparo']=='f'):
                                                                                            $omisos_declara[] = $declaraciones;
                                                                                        else:
                                                                                            $reparo[] = $declaraciones;
                                                                                        endif; 
                                                                                    else:
                                                                                        $dentro_limite_pago[] = $declaraciones;
                                                                                    endif;
                                                                                endif;

                                                                else:
                                                                    if (strtotime($declaraciones['fechapago']) > strtotime($periodos['fechalim'])):
                                                                        if ($declaraciones['bln_reparo']=='f'):
                                                                                  // jefferosn 28/05/2013                                                                                
                                                                                    if (isset($this->filtro_extemporaneo)):
                                                                                       $datos_busca_declarciones_enviadas_finanzas= $this->lista_contribuyentes_general_m->busca_declarciones_enviadas_finanzas($datos_conusu[0]['id'],$declaraciones['id']);
                                                                                        if(!$datos_busca_declarciones_enviadas_finanzas): 
//                                                                                            
                                                                                            $extemporaneos[] = $declaraciones;
//                                            
                                                                                        endif;
                                                                                    else:
                                                                                        $extemporaneos[] = $declaraciones;
//                                                                                    endif;
                                                                                // fin jefferon
                                                                                    
//                                                                                    if (isset($this->filtro_extemporaneo)):
//                                                                                        
//                                                                                        if($declaraciones['proceso']==$estatus_compara):
//                                                                                            $extemporaneos[] = $declaraciones;
//                                                                                        endif;
//                                                                                    else:
//                                                                                        $extemporaneos[] = $declaraciones;
                                                                                    endif;
                                                                                   
                                                                                else:
                                                                            $reparo[] = $declaraciones;
                                                                        endif;
                                                                    else:
                                                                        $pagados[] = $declaraciones;
                                                                    endif;

                                                                endif;


                                                            endif;

                                                        else:
                                                            if($periodos['ano']==$this->anio_filtro):
                                                                if (empty($declaraciones['fechapago'])):
                                                                   // verificamos si existe es año enviado a fiscalizar
                                                                                $verifica_period=$this->lista_contribuyentes_general_m->verifica_periodo_omiso_enfiscalizacion($this->id,$valor_tipocont['tcontid'],$declaraciones['ano'], $nroaut);
                                                                                if($verifica_period==$condicion_omiso):
                                                                                    if (strtotime("$anio_actual-$mes_actual-$dia_actual") > strtotime($periodos['fechalim'])):
                                                                                        if ($declaraciones['bln_reparo']=='f'):
                                                                                            $omisos_declara[] = $declaraciones;
                                                                                        else:
                                                                                            $reparo[] = $declaraciones;
                                                                                        endif; 
                                                                                    else:
                                                                                        $dentro_limite_pago[] = $declaraciones;
                                                                                    endif;
                                                                                endif;
                                                                else:
                                                                    if (strtotime($declaraciones['fechapago']) > strtotime($periodos['fechalim'])):
                                                                        if ($declaraciones['bln_reparo']=='f'):
                                                                                // jefferosn 28/05/2013                                                                                
                                                                                    if (isset($this->filtro_extemporaneo)):
                                                                                       $datos_busca_declarciones_enviadas_finanzas= $this->lista_contribuyentes_general_m->busca_declarciones_enviadas_finanzas($datos_conusu[0]['id'],$declaraciones['id']);
                                                                                        if(!$datos_busca_declarciones_enviadas_finanzas): 
//                                                                                           
                                                                                            $extemporaneos[] = $declaraciones;
//                                                   
                                                                                        endif;
                                                                                    else:
                                                                                        $extemporaneos[] = $declaraciones;
//                                                                                    endif;
                                                                                // fin jefferon
                                                                                    
//                                                                                    if (isset($this->filtro_extemporaneo)):
//                                                                                        
//                                                                                        if($declaraciones['proceso']==$estatus_compara):
//                                                                                            $extemporaneos[] = $declaraciones;
//                                                                                        endif;
//                                                                                    else:
//                                                                                        $extemporaneos[] = $declaraciones;
                                                                                    endif;
                                                                                   
                                                                                else:
                                                                            $reparo[] = $declaraciones;
                                                                        endif;
                                                                    else:
                                                                        $pagados[] = $declaraciones;
                                                                    endif;

                                                                endif;
                                                            endif;
                                                        endif;
//                                                    else:

                                                    endif;
                                                  
                                                  else:
                                                      
                                                  endif; // fin bln declaro 0 

                                                endif;
                                                
                                                endforeach;
                                                if($verifica==0):
                                                    $verifica_period=$this->lista_contribuyentes_general_m->verifica_periodo_omiso_enfiscalizacion($this->id,$valor_tipocont['tcontid'],$periodos['ano'], $nroaut);
                                                        if($verifica_period==$condicion_omiso):
                                                            if(($periodos['ano']==$anio_actual) && ($periodos['periodo']==$periodo_vigente)):
                                                            else:
                                                                if ($periodos['ano']==$anio_registro):
                                                                    if($periodos['periodo']>=$periodo_registro):
                                                                        $omisos []= $periodos;

                                                                    endif;

                                                                else:
                                                                    $omisos []= $periodos;

                                                                endif;                                            
                                                            endif;
                                                        endif;
                                                endif;

                                  else:                          
                                      $verifica_period=$this->lista_contribuyentes_general_m->verifica_periodo_omiso_enfiscalizacion($this->id,$valor_tipocont['tcontid'],$periodos['ano'], $nroaut);
                                                        if($verifica_period==$condicion_omiso):
                                                            if(($periodos['ano']==$anio_actual) && ($periodos['periodo']==$periodo_vigente)):
                                                            else:
                                                                if ($periodos['ano']==$anio_registro):
                                                                    if($periodos['periodo']>=$periodo_registro):
                                                                        $omisos []= $periodos;

                                                                    endif;

                                                                else:
                                                                    $omisos []= $periodos;

                                                                endif;                                            
                                                            endif;
                                                        endif;
                                  endif;
                                  if(($periodos['ano']==$anio_actual) && ($periodos['periodo']==$periodo_vigente)):
                                      break;
                                  endif; 
                             
                              endif;// fin verifica periodo
                              endif;
                          else:
                              if ($datos_busca_declaraciones):
                                  $verifica=0;

                                          foreach ($datos_busca_declaraciones as $declaraciones):
                                        
                                            //Si existe en la tabla declara
                                            if($periodos['id']==$declaraciones['calpagodid']):
                                                $verifica++;
                                                //si es distinta de cero la declaracion 
                                               if($declaraciones['bln_declaro0']=='f'):
                                                
                                                   if ($declaraciones['bln_reparo']=='f'):
                                                    
                                                    if ($periodos['ano']==$anio_registro):
                                                        if($periodos['periodo']>=$periodo_registro):
                                                            if (empty($declaraciones['fechapago'])):
                                                                // verificamos si existe es año enviado a fiscalizar
                                                                                $verifica_period=$this->lista_contribuyentes_general_m->verifica_periodo_omiso_enfiscalizacion($this->id,$valor_tipocont['tcontid'],$declaraciones['ano'], $nroaut);
                                                                                if($verifica_period==$condicion_omiso):
                                                                                    if (strtotime("$anio_actual-$mes_actual-$dia_actual") > strtotime($periodos['fechalim'])):
                                                                                        if ($declaraciones['bln_reparo']=='f'):
                                                                                            $omisos_declara[] = $declaraciones;
                                                                                        else:
                                                                                            $reparo[] = $declaraciones;
                                                                                        endif; 
                                                                                    else:
                                                                                        $dentro_limite_pago[] = $declaraciones;
                                                                                    endif;
                                                                                endif;

                                                            else:
                                                                if (strtotime($declaraciones['fechapago']) > strtotime($periodos['fechalim'])):
                                                                    if ($declaraciones['bln_reparo']=='f'):
                                                                                    // jefferosn 28/05/2013                                                                                
                                                                                    if (isset($this->filtro_extemporaneo)):
                                                                                        $datos_busca_declarciones_enviadas_finanzas= $this->lista_contribuyentes_general_m->busca_declarciones_enviadas_finanzas($datos_conusu[0]['id'],$declaraciones['id']);
                                                                                        if(!$datos_busca_declarciones_enviadas_finanzas): 
//                                                                                            
                                                                                            $extemporaneos[] = $declaraciones;
//                                                                                                    
                                                                                        endif;
                                                                                    else:
                                                                                        $extemporaneos[] = $declaraciones;
//                                                                                    endif;
                                                                                // fin jefferon
                                                                                    
//                                                                                    if (isset($this->filtro_extemporaneo)):
//                                                                                        
//                                                                                        if($declaraciones['proceso']==$estatus_compara):
//                                                                                            $extemporaneos[] = $declaraciones;
//                                                                                        endif;
//                                                                                    else:
//                                                                                        $extemporaneos[] = $declaraciones;
                                                                                    endif;
                                                                                   
                                                                                else:
                                                                        $reparo[] = $declaraciones;
                                                                    endif;
                                                                else:
                                                                    $pagados[] = $declaraciones;
                                                                endif;

                                                            endif;


                                                        endif;

                                                    else:
                                                        if (empty($declaraciones['fechapago'])):
                                                            // verificamos si existe es año enviado a fiscalizar
                                                                                $verifica_period=$this->lista_contribuyentes_general_m->verifica_periodo_omiso_enfiscalizacion($this->id,$valor_tipocont['tcontid'],$declaraciones['ano'], $nroaut);
                                                                                if($verifica_period==$condicion_omiso):
                                                                                    if (strtotime("$anio_actual-$mes_actual-$dia_actual") > strtotime($periodos['fechalim'])):
                                                                                        if ($declaraciones['bln_reparo']=='f'):
                                                                                            $omisos_declara[] = $declaraciones;
                                                                                        else:
                                                                                            $reparo[] = $declaraciones;
                                                                                        endif; 
                                                                                    else:
                                                                                        $dentro_limite_pago[] = $declaraciones;
                                                                                    endif;
                                                                                endif;
                                                        else:
                                                            if (strtotime($declaraciones['fechapago']) > strtotime($periodos['fechalim'])):
                                                                if ($declaraciones['bln_reparo']=='f'):
                                                                               // jefferosn 28/05/2013                                                                                
                                                                                    if (isset($this->filtro_extemporaneo)):
                                                                                       $datos_busca_declarciones_enviadas_finanzas= $this->lista_contribuyentes_general_m->busca_declarciones_enviadas_finanzas($datos_conusu[0]['id'],$declaraciones['id']);
                                                                                        if(!$datos_busca_declarciones_enviadas_finanzas): 
//                                                                                            for($i=0;$i<count($declaraciones);$i++):
//                                                                                                foreach ($datos_busca_declarciones_enviadas_finanzas as $vcontrib_calc):
//                                                                                                    if(($declaraciones[$i]['id']!==$vcontrib_calc['declaraid']) && ($declaraciones[$i]['tipocontribuid']===$vcontrib_calc['tipocontid']) ):
                                                                                                        $extemporaneos[] = $declaraciones;
//                                                                                                    endif;
//
//                                                                                                endforeach;
//                                                                                            endfor;
//                                                                                        else:
//                                                                                            $extemporaneos[] = $declaraciones;
                                                                                        endif;
                                                                                    else:
                                                                                        $extemporaneos[] = $declaraciones;
//                                                                                    endif;
                                                                                // fin jefferon
                                                                                    
//                                                                                    if (isset($this->filtro_extemporaneo)):
//                                                                                        
//                                                                                        if($declaraciones['proceso']==$estatus_compara):
//                                                                                            $extemporaneos[] = $declaraciones;
//                                                                                        endif;
//                                                                                    else:
//                                                                                        $extemporaneos[] = $declaraciones;
                                                                                    endif;
                                                                                   
                                                                                else:
                                                                    $reparo[] = $declaraciones;
                                                                endif;
                                                                
                                                            else:
                                                                $pagados[] = $declaraciones;
                                                            endif;

                                                        endif;

                                                    endif;
//                                                else:

                                                endif;
                                                
                                             else:

                                             endif; //fin blndeclaro 0

                                            endif;
                                           
                                            endforeach;
                                            if($verifica==0):
                                               $verifica_period=$this->lista_contribuyentes_general_m->verifica_periodo_omiso_enfiscalizacion($this->id,$valor_tipocont['tcontid'],$periodos['ano'], $nroaut);
                                                        if($verifica_period==$condicion_omiso):
                                                            if(($periodos['ano']==$anio_actual) && ($periodos['periodo']==$periodo_vigente)):
                                                            else:
                                                                if ($periodos['ano']==$anio_registro):
                                                                    if($periodos['periodo']>=$periodo_registro):
                                                                        $omisos []= $periodos;

                                                                    endif;

                                                                else:
                                                                    $omisos []= $periodos;

                                                                endif;                                            
                                                            endif;
                                                        endif;
                                            endif;

                              else:                          
                                  $verifica_period=$this->lista_contribuyentes_general_m->verifica_periodo_omiso_enfiscalizacion($this->id,$valor_tipocont['tcontid'],$periodos['ano'], $nroaut);
                                                        if($verifica_period==$condicion_omiso):
                                                            if(($periodos['ano']==$anio_actual) && ($periodos['periodo']==$periodo_vigente)):
                                                            else:
                                                                if ($periodos['ano']==$anio_registro):
                                                                    if($periodos['periodo']>=$periodo_registro):
                                                                        $omisos []= $periodos;

                                                                    endif;

                                                                else:
                                                                    $omisos []= $periodos;

                                                                endif;                                            
                                                            endif;
                                                        endif;
                              endif;
                              if(($periodos['ano']==$anio_actual) && ($periodos['periodo']==$periodo_vigente)):
                                  break;
                              endif; 
                            
                          endif; 
                      endforeach;//fin ciclo de periodos
                      
                      
                   endforeach;
//                   print($this->metodo); die;
                   $respuesta= array(
                       'datos_usuario'=>$datos_conusu,
                       'nombre_tipocont' =>$datos_conusu_tcont[0]['nombre_tipocont'],
                       'metodo'=>(isset($this->metodo)?$this->metodo:''),
                       'succes'=>true,
                       'mensaje'=>'Si existe',
                       'omisos'=>(isset($this->omisos) && $this->omisos==1 ? (sizeof($omisos)>0 ? $omisos : false) : false),
                       'omisos_declara'=>(isset($this->omisos_declara) && $this->omisos_declara==1 ? (sizeof($omisos_declara)>0 ? $omisos_declara : false): false),
                       'extemporaneos'=>(isset($this->extemporaneos) && $this->extemporaneos==1 ? (sizeof($extemporaneos)>0 ? $extemporaneos : false): false),
                       'pagados'=>(isset($this->pagados) && $this->omisos==1 ?(sizeof($pagados)>0 ? $pagados : false): false),
                       'dentro_limite_pago'=>(isset($this->dentro_limite_pago) && $this->dentro_limite_pago==1 ? (sizeof($dentro_limite_pago)>0 ? $dentro_limite_pago : false): false)
                  );                    

               else:///sino se cumple condicion si tipo contribuyente existe
                  $respuesta= array(
                      'succes'=>false,
                      'mensaje'=>'No existe',
                      'omisos'=>false,
                      'omisos_declara'=>false,
                      'extemporaneos'=>false,
                      'pagados'=>false,
                      'dentro_limite_pago'=>false
                  );                    
               endif;//fin condicion si tipo contribuyente existe
            else://sino  si existe el contribuyente
              $respuesta= array(
                      'succes'=>false,
                      'mensaje'=>'No existe',
                      'omisos'=>false,
                      'omisos_declara'=>false,
                      'extemporaneos'=>false,
                      'pagados'=>false,
                      'dentro_limite_pago'=>false
                  ); 
            endif;//fin  si existe el contribuyente
            if(isset($this->modo) && $this->modo==1):
                $vista=$this->load->view('mod_gestioncontribuyente/lista_contribuyentes_general_v',$respuesta,true);
                return $vista;               
            
            else:
//                print_r($datos_busca_declaraciones);
//                        print_r($datos_busca_declarciones_enviadas_finanzas);
//                print_r($respuesta['extemporaneos']); die;
                return $respuesta;
            endif;
          
        }
        
        
        /**
         * consulta_general()
         *
         * Se crea el panel de busqueda avanzada de contribuyentes 
         * largo deseado de la cadena de salida.
         * 
         * VARIABLES        TIPO            DESCRIPCION
         * @descripcion  string   Descripcion del Modulo cargado
         * @filtro        array    Define el tipo de busqueda para cada posicion de @vista
         * @vista         array    Define la vista para cada busqueda
         * @datos         array    Valores pasados a las vista de retorno
         * @vista_bd      int      Valor para diferenciar eventos en las vistas 
         *                          (Obtenido desde la BD, en la definicion del módulo)
         *                          El valor pasado como parametro se tiene que crear como
         *                          un vector aqui en la funcion.
         * 
         * @return        string   Retorna vista con la busqueda
         */                     
        function consulta_general($vista_bd){
            
            
            $datos['tipo_contribuyentes'] = $this->lista_contribuyentes_general_m->lista_tipo_contribuyente();

            
            //Vista y filtro #0
            $descripcion[0]  = 'Consulta Avanzada de Contribuyentes <font color="red">Omisos</font>';
            $filtro[0] = 1; 
            $vista[0]  = 'mod_gestioncontribuyente/consulta_omisos_recaudacion_v';
            
            
            //Vista y filtro #1
            $descripcion[1]  = 'Consulta Avanzada de Contribuyentes <font color="red">Extemporáneos</font>';
            $filtro[1] = 3;
            $filtro_extemporaneo[1] = 0;
            $vista[1]  = 'mod_gestioncontribuyente/consulta_extemporaneos_recaudacion_v';

            //Vista y filtro #2
            $descripcion[2]  = 'Consulta Avanzada de Contribuyentes <font color="red">Omisos</font>';
            $filtro[2] = 1;
            $vista[2]  = 'mod_gestioncontribuyente/consulta_avanzada_fiscalizacion_v';
            
            //Preparacion de datos de salida.
            $datos['descripcion'] = $descripcion[$vista_bd];
            $datos['filtro'] = $filtro[$vista_bd];
            $datos['filtro_extemporaneo'] = $filtro_extemporaneo[1];
            $datos['vista'] = $vista[$vista_bd];
            
            $datos['diferenciador_funciones'] = random_string('alnum', 16);
            $this->load->view('mod_gestioncontribuyente/consulta_general_v',$datos);
            
        }
        function consulta_responde(){
            //sleep(1);
            if($this->input->post('vista')!=''):
                $vista=$this->input->post('vista');
            else:
                print('Especifique la vista a cargar.');
                die;
            endif;            

            if($this->input->post('filtro')!=''):
                $filtro=$this->input->post('filtro');
            else:
                $filtro=3;                
            endif;
           if($this->input->post('filtro_extemporaneo')!=''):
                $filtro_extemporaneo=$this->input->post('filtro_extemporaneo');
            else:
                $filtro_extemporaneo=0;              
            endif;            
            if($this->input->post('rif')!=''):
                $rif=$this->input->post('rif');
            else:
                $rif='';                
            endif;   
            
            

            if($this->input->post('anio_cal')==0):
                $anio='';
            else:
                $id_ano=explode(':',$this->input->post('anio_cal'));
                $anio=$id_ano[1];                
            endif;

            if($this->input->post('meses_cal')!=''):
                $periodo=$this->input->post('meses_cal');
            else:
                $periodo='';                
            endif;  
            
            if($this->input->post('tipocont_cal')==0):
                $tipo_cont='';
            else:
                $tipo_cont=$this->input->post('tipocont_cal');
                               
            endif;            
            $filtro = array(
               'omisos'=>($filtro==1?true:false),
               'dentro_limite_pago'=>($filtro==2?true:false),
               'extemporaneos'=>($filtro==3?true:false),
               'pagados'=>($filtro==4?true:false),
               'omisos_declara'=>($filtro==5?true:false)
               );
            $info=array();
            $respuesta = array();
            $listar_contribuyentes = $this->lista_contribuyentes_general_m->listar_contribuyentes ($rif,$tipo_cont);
//            print_r($listar_contribuyentes); die;
            if($listar_contribuyentes):
                
                foreach($listar_contribuyentes as $indice=>$valor):

                   $parametros_info=array(
                       'id'=>$valor['id'],
                       'modo'=>0,
                       'omisos'=>1,
//                       'filtro_extemporaneo'=>0,
                       'omisos_declara'=>1,
                       'extemporaneos'=>1,
                       'pagados'=>1,
                       'dentro_limite_pago'=>1,
                       'tipocontid_conusu' =>$valor['tipocontid']
                   );
//                   if (!empty($filtro_extemporaneo)): 
                       $parametros_info['filtro_extemporaneo'] = $filtro_extemporaneo;

//                   endif;
                   $info=$this->info_contribuyente($parametros_info);
//                   print_r($info);
//                   print_r ($info['omisos_declara'][0]['ano']);
                   
                   //FILTRO PARA OMISOS
                   if($info['omisos'] && $filtro['omisos']):
                       if(!empty($valor['tipocontid'])):
                               $omd = array();
                               $oms = array();
                               if($info['omisos_declara']):                         
                                   foreach($info['omisos_declara'] as $om_d):
 
                                    if(($om_d['tipocontribuid']==$valor['tipocontid'])):
                                        $omd[]=$om_d;
                                        
                                    endif;                                    

                                   endforeach;

                               endif;
                               if($info['omisos']):
                                   foreach($info['omisos'] as $om_s):
                                        if($om_s['tipocontid']==$valor['tipocontid']):
                                            $oms[]=$om_s;
                                        endif;                                   
                                                                        
                                   endforeach;
                               endif;                               

                               if((sizeof($omd)>0) || (sizeof($oms)>0)):
                               $respuesta['respuesta'][$valor['id'].$valor['tipocontid']]= array(
                                   'datos_usuario'=>$info['datos_usuario'],

                                   'omisos'=>$oms,
                                   'omisos_declara'=>$omd,
                                   'nombre_tipocont'=>$valor['nombre_tipocont'],
                                   'tipocontid'=>$valor['tipocontid'],
                                   'anio_filtro'=>$anio,
                                   'periodo_filtro'=>$periodo
                                   );
                                endif;                      
                       else:
                           $respuesta['respuesta'][$valor['id'].$valor['tipocontid']]= array(
                               'datos_usuario'=>$info['datos_usuario'],

                               'omisos'=>$info['omisos'],
                               'omisos_declara'=>$info['omisos_declara'],
                               'nombre_tipocont'=>$valor['nombre_tipocont'],
                               'tipocontid'=>$valor['tipocontid'],
                               'anio_filtro'=>$anio,
                               'periodo_filtro'=>$periodo
                               );                                
                       endif;


                   endif;
                   //FIN FITRO OMISOS
               
                   //FILTRO EXTEMPORANEOS
                   if($info['extemporaneos'] && $filtro['extemporaneos']):
                       if(!empty($anio)):
                           $extemp = array();

                           
                               foreach($info['extemporaneos'] as $ext):
                                if(!empty($periodo)):
                                    if(($ext['ano']==$anio) && ($ext['periodo']==$periodo)):
                                        $extemp[]=$ext;
                                    endif;
                                else:
                                    if(($ext['ano']==$anio)):
                                        $extemp[]=$ext;
                                    endif;                                    
                                endif;
                               endforeach;
                           

                               if((sizeof($extemp)>0) ):
                               $respuesta['respuesta'][$valor['id'].$valor['tipocontid']]= array(
                                   'datos_usuario'=>$info['datos_usuario'],
                                   'nombre_tipocont'=>$valor['nombre_tipocont'],
                                   'extemporaneos'=>$extemp,
                                   'tipocontid'=>$valor['tipocontid'],
                                   'anio_filtro'=>$anio,
                                   'periodo_filtro'=>$periodo
                              );
                                endif;
                       else:                           
//                           $extemp = array();
//                           foreach($info['extemporaneos'] as $ext):
////                                if(($ext['proceso']=='enviado') ):
////                                    
////                                else:
//                                    $extemp[]=$ext;
////                                endif;
//                           endforeach;
//                           if((sizeof($extemp)>0) ):
                               $respuesta['respuesta'][$valor['id'].$valor['tipocontid']]= array(
                                   'datos_usuario'=>$info['datos_usuario'],
                                   'nombre_tipocont'=>$valor['nombre_tipocont'],
                                   'extemporaneos'=>$info['extemporaneos'],
                                   'tipocontid'=>$valor['tipocontid'],
                                   'anio_filtro'=>$anio,
                                   'periodo_filtro'=>$periodo
                              );
//                           endif;
                       endif;


                   endif;
                   //FIN FITRO EXTEMPORANEOS
                   
                   //FILTRO OMISOS DECLARA
                   if($info['omisos_declara'] && $filtro['omisos_declara']):
                        $respuesta['respuesta'][$valor['id']]= array(
                           'datos_usuario'=>$info['datos_usuario'],
                           'omisos_declara'=>$info['omisos_declara']
                      );                      
                   endif;
                   //FIN FILTRO OMISOS DECLARA
                   
                   //FILTRO PAGADOS
                   if($info['pagados'] && $filtro['pagados']):
                       if(!empty($anio)):
                           $pgdos = array();

                           if($info['pagados']):
                               foreach($info['pagados'] as $pg):
                                if(!empty($periodo)):
                                    if(($pg['ano']==$anio) && ($pg['periodo']==$periodo)):
                                        $pgdos[]=$pg;
                                    endif;
                                else:
                                    if(($pg['ano']==$anio)):
                                        $pgdos[]=$pg;
                                    endif;                                    
                                endif;
                               endforeach;
                           endif;

                               if((sizeof($pgdos)>0) ):
                               $respuesta['respuesta'][$valor['id']]= array(
                                   'datos_usuario'=>$info['datos_usuario'],

                                   'pagados'=>$pgdos
                              );
                                endif;
                       else:
                           $respuesta['respuesta'][$valor['id']]= array(
                               'datos_usuario'=>$info['datos_usuario'],

                               'pagados'=>$info['pagados']
                          );                           
                       endif;


                   endif;
                   //FIN FITRO PAGADOS
                   
                   
                   
                   //FILTRO DENTRO LIMITE PAGO
                   if($info['dentro_limite_pago'] && $filtro['dentro_limite_pago']):
                       $respuesta['respuesta'][$valor['id']]= array(
                           'datos_usuario'=>$info['datos_usuario'],

                           'dentro_limite_pago'=>$info['dentro_limite_pago']
                      );
                   endif;
                   //FIN FILTRO DENTRO LIMITE DE PAGO
               endforeach;
//               print_r($respuesta);
//               die;
//               die;
//               (sizeof($respuesta)>0?print(json_encode($respuesta)):print('No hay resultados'));
               //print(json_encode($respuesta));
//               $this->load->view('mod_contribuyente/cabecera_v');
               $this->load->view($vista,$respuesta);
//               $this->load->view('mod_contribuyente/pie_v');
           else:
               $this->load->view($vista,$respuesta);
           endif;
        }
        function compararFechas($primera='2001-05-02', $segunda='2013-05-02')
         {
          $valoresPrimera = explode ("-", $primera);   
          $valoresSegunda = explode ("-", $segunda); 

          $diaPrimera    = $valoresPrimera[2];  
          $mesPrimera  = $valoresPrimera[1];  
          $anyoPrimera   = $valoresPrimera[0]; 

          $diaSegunda   = $valoresSegunda[2];  
          $mesSegunda = $valoresSegunda[1];  
          $anyoSegunda  = $valoresSegunda[0];

          $diasPrimeraJuliano = gregoriantojd($mesPrimera, $diaPrimera, $anyoPrimera);  
          $diasSegundaJuliano = gregoriantojd($mesSegunda, $diaSegunda, $anyoSegunda);     

          if(!checkdate($mesPrimera, $diaPrimera, $anyoPrimera)){
            // "La fecha ".$primera." no es v&aacute;lida";
            return 0;
          }elseif(!checkdate($mesSegunda, $diaSegunda, $anyoSegunda)){
            // "La fecha ".$segunda." no es v&aacute;lida";
            return 0;
          }else{
            return  $diasPrimeraJuliano - $diasSegundaJuliano;
          } 

        }
        function lista_fiscales(){
            $datos['asigna_fiscal'] = $this->input->post('asigna_fiscal');
            $datos['periodo_fiscalizar']=$this->input->post('periodos_omisos');
//            $this->anios_omisos_afiscalizar($datos['asigna_fiscal']);
//            print_r($datos);
            $datos['lista_fiscales'] = $this->lista_contribuyentes_general_m->listar_fiscales();
            $this->load->view('mod_gestioncontribuyente/lista_fiscales_v',$datos);
           
        }
        function lista_anios_cal(){
            sleep(1);
            $id=$this->input->post('id');

            if ($lista_anio_cal = $this->lista_contribuyentes_general_m->lista_anio_cal($id)):
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
        function lista_periodos_cal(){
            sleep(1);
            $id_ano=explode(':',$this->input->post('id'));
            $id = $id_ano[0];
            
            
            
            if(isset($id) && !empty($id) ):

                if ($lista_anio_cal = $this->lista_contribuyentes_general_m->lista_periodo_cal($id)):
                    $respuesta = array(
                        'success' => true,
                        'datos'   => $lista_anio_cal

                    );
                else:
                    $respuesta = array(
                        'success' => false


                    );            
                endif;
            else:
                $respuesta = array(
                    'success' => false


                );                
            endif;
            print(json_encode($respuesta));            
        }
        function asigna_fiscalizaciones(){
            $id_fiscal = $this->input->post('fiscal');
            $asignaciones = $this->input->post('asignaciones');
            $idUsuario=$this->session->userdata('id');
            $ip=$this->input->ip_address();
            $prioridad=$this->input->post('prioridad_fiscal');
            $fechaFiscalizacion=$this->input->post('fecha_fiscaliza');
            $periodo_afiscalizar= $this->input->post('periodos');
//            $separa=explode(':',$this->input->post('periodos'));
//            $anio=$separa[0];
//            $calpagoid=$separa[1];
            
            $inserta_asignaciones = $this->lista_contribuyentes_general_m->inserta_asignaciones($id_fiscal,$idUsuario,$ip,$prioridad,$fechaFiscalizacion,$asignaciones,$periodo_afiscalizar);

            if($inserta_asignaciones):
                $respuesta = array(
                    'succes' => true,
                    'mensaje'=> 'Asignacion exitosa'
                );
            else: 
                $respuesta = array(
                    'succes' => false,
                    'mensaje'=> 'Asignacion fallida'
                );
            endif;
            print(json_encode($respuesta));
        }
        function revisa_fiscalizaciones(){
            //sleep(4);
//            $id_conusu = $this->input->post('idconusu');
//            $id_tipocont = $this->input->post('tipocontid');
            $revisa_fiscalizaciones = $this->lista_contribuyentes_general_m->revisa_fiscalizaciones();
            print(($revisa_fiscalizaciones?json_encode(array('succes'=>true,'mensaje'=>'SI','datos'=>$revisa_fiscalizaciones)):json_encode(array('succes'=>true,'mensaje'=>'NO'))));
        }
        function ver_detalles_contribuyentes(){
            
            $filtro_detalles = $this->input->post('filtro_detalles');
            $ArregloOpciones = str_split($this->zerofill(decbin($filtro_detalles), 5));
//            print_r($ArregloOpciones);die;
            $parametros_info=array(
               'id'=>$this->input->post('id'),
               'modo'=>1,
               'metodo'=>$this->input->post('metodo'),
               'omisos'=>$ArregloOpciones[0],
               'omisos_declara'=>$ArregloOpciones[1],
               'extemporaneos'=>$ArregloOpciones[2],
               'filtro_extemporaneo'=>$this->input->post('filtro_extemporaneo'),
               'pagados'=>$ArregloOpciones[3],
               'dentro_limite_pago'=>$ArregloOpciones[4],
               'tipocontid_conusu' =>$this->input->post('tipocont'),
               'anio_filtro' =>($this->input->post('anio_filtro')==0?'':$this->input->post('anio_filtro')),
               'periodo_filtro' =>($this->input->post('periodo_filtro')==0?'':$this->input->post('periodo_filtro'))
            );
            $info=$this->info_contribuyente($parametros_info);
            print($info);
               
        }
        
        
        /**
         * zerofill()
         *
         * Devuelve el número ingresado con ceros a la izquierda dependiendo del
         * largo deseado de la cadena de salida.
         *
         * @param   int $entero
         * @param   int $largo
         * @return  string numero_formateado_ceros_izquierda
         */
        function zerofill($entero, $largo){
            // Limpiamos por si se encontraran errores de tipo en las variables
            $entero = (int)$entero;
            $largo = (int)$largo;

            $relleno = '';

            /**
             * Determinamos la cantidad de caracteres utilizados por $entero
             * Si este valor es mayor o igual que $largo, devolvemos el $entero
             * De lo contrario, rellenamos con ceros a la izquierda del número
             **/
            if (strlen($entero) < $largo) {
                $relleno = str_repeat('0', $largo - strlen($entero));
            }
            return $relleno . $entero;
        }
        function pre_asigna_recaudacion_a_finanzas(){
            $respuesta = array('succes'=>false);
            
            
            
            $datos['id_declaracion_asignados'] = $this->input->post('asigna_ext_recaudacion');
            
            if ($this->input->post('modo')==1):
                foreach ($datos['id_declaracion_asignados'] as $recibe):
                    $separa = explode(':',$recibe);
                    $id = $separa[0];
                    $tipocontid = $separa[1];                    
                    $filtro_detalles = 4;
                    $ArregloOpciones = str_split($this->zerofill(decbin($filtro_detalles), 5));
                    $parametros_info=array(
                       'id'=>$id,
                       'modo'=>0,                       
                       'omisos'=>$ArregloOpciones[0],
                       'omisos_declara'=>$ArregloOpciones[1],
                       'extemporaneos'=>$ArregloOpciones[2],
                       'filtro_extemporaneo'=>$this->input->post('filtro_extemporaneo'),
                       'pagados'=>$ArregloOpciones[3],
                       'dentro_limite_pago'=>$ArregloOpciones[4],
                       'tipocontid_conusu' =>$tipocontid,
                       'anio_filtro' =>0,
                       'periodo_filtro' =>0
                    );
                    $info[]=$this->info_contribuyente($parametros_info);
                    
                endforeach;
                $datos_envia['pre_datos'] = $info;
//                print_r($datos_envia['pre_datos'][0]['extemporaneos'][0]['id']);
                $datos_vista=$datos_envia;
                $this->load->view('mod_gestioncontribuyente/asigna_recaudacion_a_finanzas_v',$datos_envia);
            elseif($this->input->post('modo')==0):
                $datos_id_cambia_declara = array();
                $datos_id['id_para_enviar'] = $this->input->post('id');
                $datos_id_cambia_declara = $this->input->post('id_cambia_declara');
//                print_r($datos_id_cambia_declara);echo "fin primero<br />";
        /**********************************************************************
         * modificado por jeto en el dia 23 de mayo a las 5:30 de la tarde
         * 
         ***********************************************************************/
                $ids_decls=array();
                $clv_iguales=array();
                for($j=0;$j<count($datos_id_cambia_declara); $j++)
                { 
                    $datos_eval = explode(':', $datos_id_cambia_declara[$j]);
                    
                    $ids_decls[$j][$j]=$datos_eval[0];
                    
                    // evaluamos desde donde va a empezar a correr el siguiente for 
                    // para evitar errores logicos en el recorrido
                    if($j==(count($datos_id_cambia_declara))):
                        
                        $vali=$j; 
                            
                     else:
                                 
                        $vali=$j+1;
                             
                    endif;
                    
                    for($i=$vali;$i<count($datos_id_cambia_declara); $i++)
                    {
                        
                        $datos_eval2 = explode(':',$datos_id_cambia_declara[$i]);
                        
                        if(($datos_eval[1]==$datos_eval2[1]) && ($datos_eval[2]==$datos_eval2[2])):
                            
                            $clv_iguales[]=$i;
                        
                            $ids_decls[$j][$i]=$datos_eval2[0];                           
                            
                        endif;
                    }
                   if(!empty($clv_iguales)): 
                       
                        foreach ($clv_iguales as $iguales):
                                 // eliminamos la posicion que es igual para que 
                                 // en la siguinete vuelta no sea tomada por el primer for
                                 unset($datos_id_cambia_declara[$iguales]);

                        endforeach; 

                         // restablecemos las claves de array para que sigan 
                         // trabajando los ciclos de manera continua
                         $datos_id_cambia_declara=  array_values($datos_id_cambia_declara);  
                    endif; 
                    // seteamos el arreglo para la proxima vuelta del for
                    unset($clv_iguales);
                }
//                print_r(count($datos_id_cambia_declara));
//                $ids_decls=  array_values($ids_decls);
//            print_r($clv_iguales);
//                print_r($ids_decls);
//                die;
         /**********************************************************************
         * fin jeto
         * 
         ***********************************************************************/
                
                foreach ($datos_id['id_para_enviar'] as $datos_separa):
                    $separa = explode(':', $datos_separa);
                    $datos_inserta[]=array(
                        'conusuid'=>$separa[0],
                        'usuarioid'=>$this->session->userdata('id'),
                        'ip'=>$this->input->ip_address(),
                        'tipocontid'=>$separa[1],
                        'proceso'=>'enviado'
                        );
                endforeach;
                $envia_a_finanza = $this->lista_contribuyentes_general_m->envia_a_finanza($datos_inserta,$ids_decls );
                
                if($envia_a_finanza):
                    $respuesta = array(
                        'succes'=>true,
                        'mensaje'=>'Enviado',
                        'filas_insertadas'=>$envia_a_finanza
                        );
                else:
                    $respuesta = array(
                        'succes'=>false,
                        'mensaje'=>'No Enviado'                        
                        );
                endif;
                //$datos_inserta[] = array('succes'=>true);
                print(json_encode($respuesta));
            endif;
      
            
           
        }
        
               
       function detalles_contribuyente_afiscalizar(){   
           
            $parametros_info=array(
                       'id'=>$this->input->post('id'),
                       'modo'=>0,
                       'omisos'=>1,
//                       'filtro_extemporaneo'=>0,
                       'omisos_declara'=>1,
                       'extemporaneos'=>0,
                       'pagados'=>0,
                       'dentro_limite_pago'=>0,
                       'tipocontid_conusu' =>$this->input->post('tipocont'),
                       'vienefis'=>$this->input->post('nro_autorizacion'),
                   );
            
           $info=$this->info_contribuyente($parametros_info);
           $info['idtipocont']=$this->input->post('tipocont');
           $info['nro_autorizacion']=  $this->input->post('nro_autorizacion');
           $info['tipo']=  $this->funciones_complemento->devuelve_tipegrav_contribu($info['idtipocont']);
//           print_r($info['tipo']);die;
           if(is_array($info)):
              
              $this->load->view('detalles_contribuyente_afiscalizar_v',$info);
//               return $vista_detalles;
//               $return=array('resultado'=>true,'vista'=>$vista_detalles);
           endif;
           
//           echo json_encode($return);
//           print_r($info);
           
       }
       /*
        *  anios_omisos_afiscalizar: determina los años en que quedo omiso el contribueyente
        *                            y debuelve un arreglo con ellos                                  
        * @access public
        * @param integer 
        * @return array      
        */
       function anios_omisos_afiscalizar($id,$tipocont){
           
            $parametros_info=array(                       
                       'id'=>$id,
                       'modo'=>0,
                       'omisos'=>1,
//                       'filtro_extemporaneo'=>0,
                       'omisos_declara'=>1,
                       'extemporaneos'=>0,
                       'pagados'=>0,
                       'dentro_limite_pago'=>0,
                       'tipocontid_conusu' =>$tipocont,
                       
                   );
                      
           $info=$this->info_contribuyente($parametros_info);
           $clv_iguales=array();
           foreach ($info['omisos'] as $clave=>$valor):
               
               $anio_compara=$valor['ano'];
               for($i=$clave+1;$i<count($info['omisos']);$i++)
               {
                   if($anio_compara==$info['omisos'][$i]['ano'])
                   {
                       $clv_iguales[]=$i;
                   }
               }
               if(!empty($clv_iguales)):
                    foreach ($clv_iguales as $iguales):
                         // eliminamos la posicion que es igual para que 
                         // en la siguinete vuelta no sea tomada por el primer for
                         unset($info['omisos'][$iguales]);

                     endforeach;
                     $info['omisos']=  array_values($info['omisos']);
                endif;              
              unset($clv_iguales); 
           endforeach;
           
           return $info['omisos'];
           
       }
    
    }
