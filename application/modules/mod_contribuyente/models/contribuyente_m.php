<?php
class Contribuyente_m extends CI_Model{
    function __construct() {
        parent::__construct();

    }
    
    function registroContribuyente($datosCon = array()){
        if(is_array($datosCon)):
            $token=do_hash(random_string('alnum', 16));
            $this->db->trans_start();
                $this->db->insert('datos.conusu',$datosCon);
                $id= $this->db->insert_id();
                $datosToken = array(
                    'token'     => $token,
                    'conusuid'  => $id,
                    'fechacrea' => 'now()',
                    
                    'usado'     => 'false');
                $datosRolInicialContribuyente = array(
                    'id_rol'     => 4,
                    'id_usuario'  => $id);                
                $this->db->insert('datos.conusuto',$datosToken);
                $this->db->insert('segContribu.tbl_rol_usuario_contribu',$datosRolInicialContribuyente);
            $this->db->trans_complete();
        
        
            if ($this->db->trans_status() === FALSE):
                $this->db->trans_rollback();
                return false;
            else:
                $this->db->trans_commit();
                return array(
                    'registro' =>true,
                    'correo' => $datosCon['email'],
                    'token'  => $token,
                    'nombre' => $datosCon['nombre']
                );
                
            endif;
         else:
             return false;
         endif;
            
     }
    
    function verificaContribuyente($correo='',$rif='',$id=''){
        $idint = (int)$id; 
        $this->db
                ->from('datos.conusu')
                ->where(array('email'=>$correo,'login'=>strtoupper($rif)));
//        $this->db->or_where(array('rif'=>strtoupper($rif)));
        $this->db->or_where(array('id'=>$idint));
        $this->db->where(array('inactivo'=>'false'));
        $query = $this->db->get();
//        if ($query->num_rows()>0):
//            return true;
//        else:
//            return false;
//        endif;
        return ($query->num_rows()>0 ? $query->result_array() : false);
    }
    
    function preguntaSecreta($id=''){
        
        $this->db
                ->select('*')
                ->from('datos.pregsecr');
                if (!empty($id)){ $this->db->where(array('id'=>$id)); }
        $query = $this->db->get();
        if ($query->num_rows()>0):
            $data = array();
            foreach ($query->result() as $row):
                    $data[] = array(
                        'id'     => $row->id,
                        'nombre' => $row->nombre
                    );
            endforeach;

            return $data;
    else:
            return false;
    endif;        
                
                
    }
    function verificaToken($token,$modo){
        if ($modo == 1)://asi verifica
            $this->db->select('*');
            $this->db->from('datos.conusuto');
            $this->db->join('datos.conusu','conusu.id = conusuto.conusuid');
            $this->db->where(array('token'=>$token));
            $query = $this->db->get();
            
            return ($query->num_rows()>0 ? $query->result_array() : false);
            
            
        elseif ($modo == 2)://asi actualiza el token a usado
            $dataToken = array(
            'usado' => 'true');
             $dataConusu = array(
            'validado' => 'true');       
            $idContribu = array();
        $this->db->trans_start();
            $this->db->select('conusuid');
            $this->db->from('datos.conusuto');
            $this->db->where(array('token'=>$token));
            $query = $this->db->get();
            $idContribu = $query->result_array();
            //print_r($idContribu);
            $this->db
                    ->where('token', $token)
                    ->update('datos.conusuto', $dataToken);
            $this->db
                    ->where(array('id'=>$idContribu[0]['conusuid']))
                    ->update('datos.conusu',$dataConusu);
        $this->db->trans_complete();
        if ($this->db->trans_status() === FALSE):
            $this->db->trans_rollback();
            return false;
        else:
            $this->db->trans_commit();
            return true;
        endif;        
        
        
        else:
            return false;
        endif;

    }
    function lista_estados(){
        $this->db
                ->select('*')
                ->from('datos.estados');
        $query = $this->db->get();
        if ($query->num_rows()>0):
            $data = array();
            foreach ($query->result() as $row):
                    $data[] = array(
                        'id'     => $row->id,
                        'nombre' => $row->nombre
                    );
            endforeach;

            return $data;
    else:
            return false;
    endif;          
    }
    function lista_ciudad($id_estado){
        $this->db
                ->select('*')
                ->from('datos.ciudades')
                ->where(array('estadoid'=>$id_estado));
        $query = $this->db->get();
        if ($query->num_rows()>0):
            $data = array();
            foreach ($query->result() as $row):
                    $data[] = array(
                        'id'     => $row->id,
                        'nombre' => $row->nombre
                    );
            endforeach;

            return $data;
    else:
            return false;
    endif;          
    }
    function verifica_registro_completo($id){
        $this->db
                ->select("conusu.rif",FALSE)
                ->select("con_img_doc.id as id_doc",FALSE)
                ->select("replegal.id as id_replegal",FALSE)                
                ->from("datos.conusu")
                ->join('datos.con_img_doc', 'conusu.id=con_img_doc.conusuid','LEFT' )
                ->join('datos.replegal','conusu.id = replegal.contribuid','LEFT')                 
                ->where(array("conusu.id"=>$id));
        $query = $this->db->get();
        if( $query->num_rows()>0 ):
            $data = $query->row();
        
            return array("id_doc"=>$data->id_doc,"id_replegal"=>$data->id_replegal);        
        
        endif;
        
    }
    function registra_planilla_inicio($datosPlanillaInicia = array(),$tipo_contribu=array(),$tipo_registro,$idContribu,$fecha_registro){
        if(is_array($datosPlanillaInicia)):
            $this->db->trans_start();
                if ($tipo_registro==1):
                    $this->db->insert('datos.contribu',$datosPlanillaInicia);
                    $id= $this->db->insert_id();
                    
                    for($i=0;$i<count($tipo_contribu);$i++):
                        
                        $this->db->insert('datos.conusu_tipocont',array('conusuid'=>  $this->session->userdata('id'),'tipocontid'=>$tipo_contribu[$i],'ip'=>$this->input->ip_address()));
                        
                    endfor;
                   $this->db
                         ->where(array('id'=>$this->session->userdata('id')))
                         ->update('datos.conusu',array('fecha_registro'=>$fecha_registro)); 
                 else:
                     $this->db
                         ->where(array('id'=>$idContribu))
                         ->update('datos.contribu',$datosPlanillaInicia);
                 
                     $this->db
                         ->where(array('id'=>$this->session->userdata('id')))
                         ->update('datos.conusu',array('fecha_registro'=>$fecha_registro)); 
                 endif;
            $this->db->trans_complete();
        
        
            if ($this->db->trans_status() === FALSE):
                $this->db->trans_rollback();
                return false;
            else:
                $this->db->trans_commit();
                return true;
            endif;
         else:
             return false;
         endif;        
    }
    function actividad_economica(){
        $this->db
                ->select('*')
                ->from('datos.actiecon');
        $query = $this->db->get();
        if ($query->num_rows()>0):
            $data = array();
            foreach ($query->result() as $row):
                    $data[] = array(
                        'id'     => $row->id,
                        'nombre' => $row->nombre
                    );
            endforeach;

            return $data;
    else:
            return false;
    endif;          
    }
    function datos_contribuyente($id_usuario){
        $this->db
                ->select("contribu.*",FALSE)
                ->select("contribu.id as id_contribu",FALSE)
                ->select("estados.nombre as nomest",FALSE)
                ->select("ciudades.nombre as nomciu",FALSE)
                ->select("conusu.inactivo as inac",FALSE)
                ->select("conusu.rif as rifconusu, conusu.nombre as nombre",FALSE)
                ->select("conusu.email as emailconusu",FALSE)
                ->from("datos.conusu left")
                ->join('datos.contribu', 'conusu.id=contribu.usuarioid left' )
                ->join('datos.estados','estados.id = contribu.estadoid left')                 
                ->join('datos.ciudades', 'ciudades.id=contribu.ciudadid ' )
                ->where(array("conusu.id"=>$id_usuario));
        $query = $this->db->get();
        if( $query->num_rows()>0 ):
            $data = $query->row();
            return array(
               'resultado'=>true,
               "razonsocial" => $data->nombre,
               "denominacionc" => $data->dencomerci,
               "actividade" => $data->actieconid,
               "rif" => $data->rifconusu,
               "registrocine"=>$data->numregcine,
               "domifiscal"=>$data->domfiscal,
               "estado"=>$data->nomest,
               "ciudad"=>$data->nomciu,
               "zonapostal"=>$data->zonapostal,
               "telef1"=>$data->telef1,
               "telef2"=>$data->telef2,
                'telef3'=>$data->telef3, 
               'fax1' =>$data->fax1, 
                'fax2' =>$data->fax2,      
                'email'=>$data->emailconusu,    
                'pinbb'=>$data->pinbb,    
               'skype'=>$data-> skype,    
                'twitter'=>$data->twitter, 
                'facebook'=>$data->facebook,  
               'nuacciones'=>$data->nuacciones,
               'valaccion'=>$data->valaccion, 
                'capitalsus'=>$data->capitalsus,
                'capitalpag'=>$data->capitalpag,
                'regmerofc'=>$data->regmerofc, 
                'rmnumero'=>$data->rmnumero, 
               'rmfolio'=>$data->rmfolio, 
               'rmtomo'=>$data->rmtomo,  
                'rmfechapro'=>$data->rmfechapro,
                'rmncontrol'=>$data->rmncontrol,
                'rmobjeto'=>$data-> rmobjeto, 
                'domcomer'=>$data->domcomer,
                'inactivo'=>$data->inac,
                'usuarioid'=>$data->usuarioid,
                'id_contribu'=>$data->id_contribu,
                'estadoid'=>$data->estadoid,
                'ciudadid'=>$data->ciudadid);
       else:
           return array('resultado'=>false);
       endif;
        
        
    }
    function devuelve_tipo_contribuyente($id_conusu){
        $data=array();
        $this->db
                //seleccionasr todo de la tabla usfonpro
                   ->select("tcon.tipocontid as tc")                
                    ->from("datos.conusu_tipocont as tcon")
                    ->where(array('tcon.conusuid'=>$id_conusu));
        
           
            $query = $this->db->get();
            if( $query->num_rows()>0 ){
                
//   recorrido con los datos necesarios para el listar de usuario   
                foreach ($query->result() as $row):
                            
                            $data[] =$row->tc;
                 endforeach;

           }
           
           return $data;
    }
    function creaToken($idUsuario){
        if(!empty($idUsuario)):
            $token=do_hash(random_string('alnum', 16));
            $this->db->trans_start();
                $datosToken = array(
                    'token'     => $token,
                    'conusuid'  => $idUsuario,
                    'fechacrea' => 'now()',
                    
                    'usado'     => 'false');            
                $this->db->insert('datos.conusuto',$datosToken);                
            $this->db->trans_complete();
        
        
            if ($this->db->trans_status() === FALSE):
                $this->db->trans_rollback();
                return false;
            else:
                $this->db->trans_commit();
                return $token;
                
            endif;
         else:
             return false;
         endif;
            
     }
     function verificaRespuestaSecreta($login,$respuesta){
         $this->db
                 ->select("*")
                 ->from('datos.conusu')
                 ->where(array("login"=>$login,"respuesta"=>$respuesta));
         $query = $this->db->get();
         return ($query->num_rows()>0 ? $query->result_array() : false);
     }
     function creaNuevaClave($login,$clave){
         $dataNueva = array(
            'password' => do_hash($clave));         
         $this->db->trans_start();
             $this->db
                     ->where('login', $login)
                     ->update('datos.conusu', $dataNueva);
         $this->db->trans_complete();
         if ($this->db->trans_status() === FALSE):
             $this->db->trans_rollback();
            return false;
         else:
             $this->db->trans_commit();
             return true;
         endif;             
     }
     
     function busca_accionista($valor){
         
         $data = array();
        

        
        $this->db
                //seleccionasr todo de la tabla usfonpro
                   ->select("*")                
                    ->from("datos.accionis")
                    ->where(array('accionis.contribuid'=>$valor));
        
           
            $query = $this->db->get();
            if( $query->num_rows()>0 ){
                
//   recorrido con los datos necesarios para el listar de usuario   
                foreach ($query->result() as $row):
                            
                            $data[] = array(
                                            "nombre"	=> $row->nombre,
                                            "cedula"   => $row->ci,
                                            "domicilio"=>$row->domfiscal,
                                            "nacciones"=>$row->nuacciones,
                                            "id"=>$row->id
                                            );
                 endforeach;

           }
           
           return $data;
     }
     
     function id_contribuyente($valor){
          $this->db
                  ->select("*")
                  ->from("datos.contribu")
                  ->where(array("usuarioid"=>$valor));
          $query = $this->db->get();
            if( $query->num_rows()>0 ){
                
                   $data = $query->row();
                   
                   return $data->id;
                
            }
     }
    function verifica_replegal($id){
           
            $this->db
                    ->from('datos.replegal')
                    ->where(array('contribuid'=>$id));
            $query = $this->db->get();
            return ($query->num_rows()>0 ? true : false);
        }

     function datos_replegal($id_usuario){
         
          $this->db
                ->select("replegal.*",FALSE)
                ->select("estados.nombre as nomest",FALSE)
                ->select("ciudades.nombre as nomciu",FALSE)
                
                ->from("datos.replegal") 
               
                ->join('datos.estados','estados.id = replegal.estadoid')                 
                ->join('datos.ciudades', 'ciudades.id=replegal.ciudadid ' )
                ->where(array("replegal.contribuid"=>$id_usuario));
          $query = $this->db->get();
        if( $query->num_rows()>0 ):
            
            foreach ($query->result() as $row):
                            
                            $data[] = array(
                                'resultado'=>true,
                                 'cedula'=>$row->ci,
                                 'nombre'=>$row->nombre.' '.$row->apellido,
                                 'apellido'=>$row->apellido,
                                 'domicilio'=>$row->domfiscal,
                                 'estado'=>$row->nomest,
                                 'ciudad'=>$row->nomciu,
                                 'zona'=>$row->zonaposta,
                                 'thab'=>$row->telefhab,
                                 'tofi'=>$row->telefofc,
                                 'fax'=>$row->fax,
                                 'email'=>$row->email,
                                 'pinbb'=>$row->pinbb,
                                 'skype'=>$row->skype,         
                                 'id_replegal'=>$row->id,                
                                 'estadoid'=>$row->estadoid,
                                 'ciudadid'=>$row->ciudadid
             );
                 endforeach;

           
           
           return $data;
            
            
           
         
//         else:
//           return array('resultado'=>false,
//                        'cedula'=>'',
//                        'nombre'=>'',
//                        'apellido'=>'',
//                        'domicilio'=>'',
//                        'estado'=>'',
//                        'ciudad'=>'',
//                        'zona'=>'',
//                        'thab'=>'',
//                        'tofi'=>'',
//                        'fax'=>'',
//                        'email'=>'',
//                        'pinbb'=>'',
//                        'skype'=>'',                        
//                        'id_replegal'=>'',
//                        'estadoid'=>'',
//                        'ciudadid'=>''    
//                       );
       endif;
         
     }
     
     function elimina_accionista($id){
         
         $this->db->where('id',$id);
         return $this->db->delete('datos.accionis');        
         
     }
     
      function tipo_contribuyente(){
        $this->db
                ->select('tipocont.nombre,tipocont.id')
                ->from('datos.conusu_tipocont')
                ->join('datos.tipocont','tipocont.id=conusu_tipocont.tipocontid')
                ->where(array('conusu_tipocont.conusuid'=>  $this->session->userdata('id')));
        $query = $this->db->get();
        if ($query->num_rows()>0):
            $data = array();
            foreach ($query->result() as $row):
                    $data[] = array(
                        'id'     => $row->id,
                        'nombre' => $row->nombre
                    );
            endforeach;

            return $data;
    else:
            return false;
    endif;          
    }
    
     function tipo_declaracion(){
        $this->db
                ->select('*')
                ->from('datos.tdeclara')
                ->where(array('tipo'=>0));
        $query = $this->db->get();
        if ($query->num_rows()>0):
            $data = array();
            foreach ($query->result() as $row):
                    $data[] = array(
                        'id'     => $row->id,
                        'nombre' => $row->nombre
                    );
            endforeach;

            return $data;
    else:
            return false;
    endif;          
    }
    
    function verifica_pgravable($valor){
        $this->db  
                ->select('tipocont.*', FALSE)
                ->select('tipegrav.peano as periodo,tipegrav.tipe as tipo',FALSE)
                ->from('datos.tipocont')
                ->join('datos.tipegrav',' tipegrav.id=tipocont.tipegravid')
                ->where(array('tipocont.id'=>$valor));
        $query = $this->db->get();
            if( $query->num_rows()>0 ){
                
                   $data = $query->row();
                   
                   $datos=array('periodo'=>$data->periodo,'tipo'=>$data->tipo);
                   
                   return $datos;
                
            }
        
        
    }
    
    function anio_maximo_alicuota($id){
        $this->db
                  ->select_max("ano")
                  ->from("datos.alicimp")
                  ->where(array("tipocontid"=>$id));
          $query = $this->db->get();
            if( $query->num_rows()>0 ){
                
                   $data = $query->row();
                   
                   return $data->ano;
                
            }
        
        
    }
    
    function datos_declaracion($id){
        
        $this->db
                ->select('declara.*',FALSE)
                ->select('tipocont.nombre as tipocontribu')
                ->select('tdeclara.nombre as nomdeclara')
                ->from('datos.declara')
                ->join('datos.tipocont','tipocont.id=declara.tipocontribuid')
                ->join('datos.tdeclara','tdeclara.id=declara.tdeclaraid')
                ->where(array('declara.id'=>$id));
        $query = $this->db->get();
            if( $query->num_rows()>0 ){
                
                   $data = $query->row();
                   
                   $datos=array('tipocon'=>$data->tipocontribu,
                                'tipodeclara'=>$data->nomdeclara,
                                'fechaini'=>$data->fechaini,
                                'fechafin'=>$data->fechafin,
                                'base'=>$this->funciones_complemento->devuelve_cifras_unidades_mil($data->baseimpo),
                                'alicuota'=>$data->alicuota,
                                'exoneracion'=>$data->exonera,
                                'cfiscal'=>$data->credfiscal,
                                'nplanilla'=>$data->nudeclara,
                                'declaracionid'=>$id,
                                'total'=>$this->funciones_complemento->devuelve_cifras_unidades_mil($data->montopagar)
                                );
                   
                   return $datos;
                
            }
        
    }
    
    function devuelve_periodo_gravable($id,$periodo,$anio){

        $this->db
                ->select('calpagod.fechaini as fechaini, calpagod.fechafin as fechafin, calpagod.fechalim as fechalimite,calpagod.id as calpid')                         
                ->from('datos.tipocont')
                ->join('datos.tipegrav','tipocont.tipegravid=tipegrav.id')
                ->join('datos.calpago','calpago.tipegravid=tipegrav.id')
                ->join('datos.calpagod','calpagod.calpagoid=calpago.id')
                ->where(array('tipocont.id'=>$id,
                              'calpago.ano'=>$anio,
                              'calpagod.periodo'=>$periodo) );
        
        $query = $this->db->get();
            if( $query->num_rows()>0 ){
                
                   $data = $query->row();
                   $datos=array(
                       'finicio'=>$data->fechaini,
                       'ffinal'=>$data->fechafin,
                       'limite'=>$data->fechalimite,
                        'id'=>$data->calpid  
                       
                   );
                   return$datos;
        
         }    
    
    }
    
    function verifica_declarcion_existe($idconusu,$idcalpagod){
        
        $this->db
                ->select('declara.id as id')
                ->from('datos.declara')
                ->where(array('conusuid'=>$idconusu,'calpagodid'=>$idcalpagod));
        
         $query = $this->db->get();
            if( $query->num_rows()>0 ){
                
                $data = $query->row();
                   $datos=array(
                       'existe'=>'true',
                       'id'=>$data->id,
                       'mensage'=>'usted ya posee una declaracion para este periodo'                        
                       
                   );
                
            }else{
                
                 $datos=array('existe'=>'false');
                
            }
            
            return $datos;
        
        
    }
    function devuelve_reparos_activados(){
        
        $data=array();
         $this->db

                ->select("repa.*",FALSE)
                ->select("contri.razonsocia, contri.rif",FALSE) 
                ->select("fonp.nombre as fiscal",FALSE)  
                ->select("tipocont.nombre as tcontribuyente, tipocont.id as idcontribu",FALSE)
                ->select("actr.numero as nacta_reparo",FALSE) 
                ->from("datos.reparos as repa")
                ->join('datos.contribu as contri','contri.usuarioid=repa.conusuid')
                ->join('datos.usfonpro as fonp','fonp.id=repa.usuarioid')
                ->join('datos.tipocont as tipocont','tipocont.id=repa.tipocontribuid')
                ->join('datos.actas_reparo as actr','actr.id=repa.actaid') 
                ->where(array('bln_activo'=>'true','conusuid'=>  $this->session->userdata('id')));
                
              $query = $this->db->get();

    
            if( $query->num_rows()>0 ){
                
//      
            
                foreach ($query->result() as $row):
                  $this->db
                    ->select('count(declara.id)')
                    ->from('datos.declara')
                    ->where(array('declara.reparoid'=>$row->id,'declara.fechapago'=>NULL)); 
                   $query2 = $this->db->get();
                   $cuenta=$query2->result_array();
                        if($cuenta[0]['count']>0):
                                 $data[]= array("nombre"=> $row->razonsocia,
                                             "rif"=> $row->rif,
                                             "felaboracion"=> $row->fechaelab,
                                             "total"=> $row->montopagar,                                            
                                             "id"=>$row->id,
                                             "fiscal"=>$row->fiscal,
                                             "tcontribuyente"=>$row->tcontribuyente,
                                             "idcontribu"=>$row->idcontribu,
                                             "bln_activo"=>$row->bln_activo,
                                             "nacta_reparo"=>$row->nacta_reparo
                                             );
                         endif;
                 endforeach;

           }
           
           return $data;
        
    }
    function devuelve_detalles_reparos($id){
        
         $data=array();
         $this->db

                ->select("decl.*",FALSE)   
                ->select("calpd.periodo as periodo",FALSE) 
                ->select("calp.ano as anio",FALSE)
                 ->select("tgrav.tipe as periodo_gravable")
                ->from("datos.declara as decl")
                ->join('datos.calpagod as calpd','calpd.id=decl.calpagodid')
                ->join('datos.calpago as calp','calp.id=calpd.calpagoid')
                ->join('datos.tipocont tcon','tcon.id=decl.tipocontribuid')
                ->join('datos.tipegrav as tgrav','tgrav.id=tcon.tipegravid') 
                ->where(array('reparoid'=>$id,'bln_reparo'=>'true','fechapago'=>null))
                ->order_by('anio,periodo');
              $query = $this->db->get();

    
            if( $query->num_rows()>0 ){
                
//      
                foreach ($query->result() as $row):
                            
                            $data[]= array("baseimpo"=> $row->baseimpo,
                                        "alicuota"=> $row->alicuota,
                                        "monto"=> $row->montopagar,                                                                                 
                                        "id"=>$row->id,
                                        "periodo"=>$row->periodo,
                                        "anio"=>$row->anio,
                                        "periodo_gravable"=>$row->periodo_gravable
                                        
                                        );
                 endforeach;

           }
           
           return $data;
        
        
        
    }
    function devuelve_multas($conusuid,$tipo){
        
          $data = array();
        $fecha_sist =  date('d-m-Y');
        $this->db
                   ->select("multas.*")
                   ->select("declara.id as id_decl, declara.conusuid as id_contrib, declara.calpagodid, declara.tipocontribuid",FALSE)
                   ->select("conusu.nombre as nom, conusu.rif",FALSE)
                   ->select("tdeclara.nombre as nom_tdecl",FALSE)
                   ->select("calpagod.id as id_calpagod, calpagod.calpagoid, calpagod.periodo",FALSE)
                   ->select("calpago.id as id_calpago, calpago.ano as ano_calpago",FALSE)
                   ->select("tipocont.id as id_tcont, tipocont.nombre as nomb_tcont",FALSE)
                   ->select("intereses.id as idinteres, intereses.totalpagar as totalinteres")
                   ->select("tgrav.tipe as periodo_gravable")
                   ->from("pre_aprobacion.multas")
                   ->join('datos.declara','declara.id=multas.declaraid')
                   ->join('datos.conusu','conusu.id=declara.conusuid')
                   ->join('pre_aprobacion.intereses','intereses.multaid=multas.id')
                   ->join('datos.tdeclara','tdeclara.id=multas.tipo_multa')
                   ->join('datos.calpagod','calpagod.id=declara.calpagodid')
                   ->join('datos.calpago','calpago.id=calpagod.calpagoid')
                   ->join('datos.tipocont','tipocont.id=declara.tipocontribuid')
                   ->join('datos.tipegrav as tgrav','tgrav.id=tipocont.tipegravid')
                   ->where(array("declara.conusuid"=>$conusuid,'tipo_multa'=>$tipo,'multas.nudeposito'=>null));
        
        
            $query = $this->db->get();
            if( $query->num_rows()>0 ){
                 
                foreach ($query->result() as $row):
                            
                            $data[] = array(
//                                            "nresolucion"  => $row->nresolucion,
                                            "ano_calpago"    => $row->ano_calpago,
                                            "periodo"    => $row->periodo,
                                            "monto"   => $row->montopagar,
                                            "fechaelaboracion" => date("d-m-Y",strtotime($row->fechaelaboracion)),
                                            "nomb_tcont" => $row->nomb_tcont,
                                            "id"=>$row->id,
                                            "interesid"=>$row->idinteres,
                                            "totalinteres"=>$row->totalinteres,
                                            "periodo_gravable"=>$row->periodo_gravable,
                                            "resol_multa"=>$row->nresolucion
                                            );
                 endforeach;

           }
           
           return $data;
        
    }
    
    function datos_multas_culm_sum($where){
        
        $this->db
                ->select('*')
                ->from('datos.vista_datos_multa_interes')
                ->where($where)
                ->order_by('idreparo');
        $query = $this->db->get();
        return ($query->num_rows()>0 ? $query->result_array() : FALSE);
    }
    function datos_planilla_declara($id_declara){
         $this->db
                ->select("*")
                ->from("datos.datos_planilla_declaracion")
                ->where(array("id"=>$id_declara));
        $query = $this->db->get();
        return ($query->num_rows()>0 ? $query->result_array() : false);
    }
    function datos_planilla_multa_interes_extem($id_multa){
         $this->db
                ->select("*")
                ->from("datos.datos_planilla_multa_interese")
                ->where(array("id_multa"=>$id_multa));
        $query = $this->db->get();
        return ($query->num_rows()>0 ? $query->result_array() : false);
    }
    
    function detalles_interes($id){
       $this->db
                ->select("*")
                ->from("datos.detalle_interes")
                ->where(array("intereses_id"=>$id));
        $query = $this->db->get();
        return ($query->num_rows()>0 ? $query->result_array() : false); 
        
    }
    
    
    
}
?>
