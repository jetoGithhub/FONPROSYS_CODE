<?

class Fiscalizacion_m extends CI_Model{
    
    /*Funcion para devolver los intereses correspondientes al bcv por mes
     */
    function contribuyentes_asignados($id)
    {
         $data=array();
         $this->db

                ->select("contri.*",FALSE)
                 ->select("conu.rif as conurif,conu.nombre as conunom, conu.id as id_conusu")
                ->select("est.nombre as estado",FALSE)
                ->select("ciu.nombre as ciudad",FALSE)
                ->select("acti.nombre as actividad")
                ->select("tipocont.nombre as tcontribuyente, tipocont.id as tcontribuyenteid",FALSE)
                ->select("asig.id as asignacionid, asig.nro_autorizacion",FALSE) 
//                ->from("datos.contribu as contri ")
                 ->from("datos.conusu as conu")
//                ->join('datos.asignacion_fiscales as asig','asig.conusuid=contri.usuarioid')
                 ->join('datos.asignacion_fiscales as asig','asig.conusuid=conu.id')
                ->join('datos.tipocont as tipocont','tipocont.id=asig.tipocontid')
                ->join('datos.contribu as contri','contri.rif=conu.rif','left') 
                ->join('datos.estados as est','est.id=contri.estadoid','left') 
                ->join('datos.ciudades as ciu','ciu.id=contri.ciudadid','left')
                ->join('datos.actiecon as acti','acti.id=contri.actieconid','left')
                ->where(array("asig.usfonproid"=>$id,"asig.estatus"=>1));
              $query = $this->db->get();

    
            if( $query->num_rows()>0 ){
                
//      
                foreach ($query->result() as $row):
                            
                            $data[]= array("nombre"=> $row->conunom,
                                            "rif"=> $row->conurif,
                                            "domfiscal"=> $row->domfiscal,
                                            "telef1"=> $row->telef1,                                            
                                            "estado"=> $row->estado,
                                            "ciudad"=> $row->ciudad,
                                            "id"=>$row->id_conusu,
                                            "idasignacion"=>$row->asignacionid,
                                            "actividad"=>$row->actividad,
                                            "fax"=>$row->fax1,
                                            "email"=>$row->email,
                                            "numregcine"=>$row->numregcine,
                                            "tcontribuyente"=>$row->tcontribuyente,
                                            "tcontribuid"=>$row->tcontribuyenteid,
                                            "nro_autorizacion"=>$row->nro_autorizacion
                                            );
                 endforeach;

           }
           
           return $data;

           
    }
    
    function contribuyentes_fiscalizado($id)
    {
        $data=array();
         $this->db

                ->select("contri.*",FALSE)
                ->select("conu.rif as conurif,conu.nombre as conunom, conu.id as id_conusu") 
                ->select("est.nombre as estado",FALSE)
                ->select("ciu.nombre as ciudad",FALSE)
                ->select("acti.nombre as actividad")
                ->select("tipocont.nombre as tcontribuyente, tipocont.id as idcontribu",FALSE)
                ->select("tgra.tipe as tipo")
                ->from("datos.asignacion_fiscales as asig")
                ->join("datos.conusu as conu","conu.id=asig.conusuid") 
                ->join('datos.contribu as contri','contri.rif=conu.rif','left') 
                ->join('datos.tipocont as tipocont','tipocont.id=asig.tipocontid')
                ->join('datos.tipegrav as tgra','tgra.id=tipocont.tipegravid') 
                ->join('datos.estados as est','est.id=contri.estadoid','left') 
                ->join('datos.ciudades as ciu','ciu.id=contri.ciudadid','left')
                 ->join('datos.actiecon as acti','acti.id=contri.actieconid','left')
                ->where(array("asig.id"=>$id));
              $query = $this->db->get();

    
            if( $query->num_rows()>0 ){
                
//      
                foreach ($query->result() as $row):
                            
                            $data= array("nombre"=> $row->conunom,
                                        "rif"=> $row->conurif,
                                        "domfiscal"=> $row->domfiscal,
                                        "telef1"=> $row->telef1,                                            
                                        "estado"=> $row->estado,
                                        "ciudad"=> $row->ciudad,
                                        "id"=>$row->id,
                                        "actividad"=>$row->actividad,
                                        "fax"=>$row->fax1,
                                        "email"=>$row->email,
                                        "numregcine"=>$row->numregcine,
                                        "tcontribuyente"=>$row->tcontribuyente,
                                        "idcontribu"=>$row->idcontribu,
                                        "conusuid"=>$row->id_conusu,
                                        "tipo"=>$row->tipo
                                            );
                 endforeach;

           }
           
           return $data;

           
    }
    
    function detalles_contribuyentes_fiscalizado($id,$bln_ident){
        
        $data=array();
         $this->db
                 ->select('dettalles_fizcalizacion.*')
                 ->from('datos.dettalles_fizcalizacion')
                 ->where(array('asignacionfid'=>$id,'bln_borrado'=>'false','bln_identificador'=>$bln_ident));
          $query = $this->db->get();

    
            if( $query->num_rows()>0 ){
                
//      
                foreach ($query->result() as $row):
                    
                     $data[]= array("id"=> $row->id,
                                            "periodo"=> $row->periodo,
                                            "anio"=> $row->anio,
                                            "base"=> $row->base,                                            
                                            "alicuota"=> $row->alicuota,
                                            "total"=> $row->total,
                                            'calpagodid'=>$row->calpagodid,
                                            'repafaltante'=>$row->bln_reparo_faltante,
                                            'reparo_faltante'=>$row->bln_reparo_faltante
                                            );
                    
                endforeach;
                
                return $data;
            }
    }
    
    function verifica_periodo_existe($calpago,$idasigna,$bln_ident){
        
         $this->db
                 ->select('dettalles_fizcalizacion.*')
                 ->from('datos.dettalles_fizcalizacion')
                 ->where(array('asignacionfid'=>$idasigna,'calpagodid'=>$calpago,'bln_borrado'=>'false'));
          $query = $this->db->get();

    
            if( $query->num_rows()>0 ):             

                return true;
            
            else:
                
                return false;
            
            endif;
        
        
        
        
    }
    function devuelve_monto_reparo($id){
        
        $data=0;
         $this->db
                 ->select('dettalles_fizcalizacion.total')
                 ->from('datos.dettalles_fizcalizacion')
                 ->where(array('asignacionfid'=>$id,'bln_borrado'=>'false'));
          $query = $this->db->get();

    
            if( $query->num_rows()>0 ){
                
//      
                foreach ($query->result() as $row):
                    
                     $data= $data+$row->total;
                    
                endforeach;
                
                return $data;
            }
        
    }
    //FUNCIÓN PARA INSERTAR LOS DATOS DE LA IMAGEN SUBIDA
    function guarda_actareparo($datos_img_conusu)
    {
        if (is_array($datos_img_conusu)):
            $this->db->insert('datos.actas_reparo', $datos_img_conusu);
            if ( $this->db->affected_rows()>0 ):
                return $this->db->insert_id();
            else:
                return false;
            endif;
        else:
            return false;
        endif;
        
    }
    
    function crea_reparo($array1,$array2,$valor){

           $this->db->trans_begin(); 
           
             $this->db->insert('datos.reparos',$array1);             
            
             $idreparo= $this->db->insert_id();
             
            
             for($i=0;$i<count($array2); $i++){
                 
                 $array2[$i]['reparoid']=$idreparo;
                 
                 $this->db->insert('datos.declara',$array2[$i]);  
                 
             }
              $this->db->where(array('id'=>$valor));
              $this->db->update('datos.asignacion_fiscales',array('estatus'=>2));
        
            if ($this->db->trans_status() === FALSE):
                $this->db->trans_rollback();
                return false;
            else:
                $this->db->trans_commit();           
             
                return true;
                
            endif;
        
        
        
    }
    
    function devuelve_reparos_creados(){
        
        $data=array();
         $this->db

                ->select("repa.*",FALSE)
                ->select("actrep.ruta_servidor") 
                ->select("conu.rif as conurif,conu.nombre as conunom")  
                ->select("contri.razonsocia, contri.rif",FALSE) 
                ->select("fonp.nombre as fiscal",FALSE)  
                ->select("tipocont.nombre as tcontribuyente, tipocont.id as idcontribu",FALSE)
                ->from("datos.reparos as repa")
                ->join("datos.actas_reparo as actrep","actrep.id=repa.actaid")
                ->join("datos.conusu as conu","conu.id=repa.conusuid") 
                ->join('datos.contribu as contri','contri.rif=conu.rif','left')
                ->join('datos.usfonpro as fonp','fonp.id=repa.usuarioid')
                ->join('datos.tipocont as tipocont','tipocont.id=repa.tipocontribuid')
                ->where(array('bln_activo'=>'false'));
                
              $query = $this->db->get();

    
            if( $query->num_rows()>0 ){
                
//      
                foreach ($query->result() as $row):
                            
                            $data[]= array("nombre"=> $row->conunom,
                                        "rif"=> $row->conurif,
                                        "felaboracion"=> $row->fechaelab,
                                        "total"=> $row->montopagar,                                            
                                        "id"=>$row->id,
                                        "fiscal"=>$row->fiscal,
                                        "tcontribuyente"=>$row->tcontribuyente,
                                        "idcontribu"=>$row->idcontribu,
                                        "bln_activo"=>$row->bln_activo,
                                        "idconusu"=>$row->conusuid,
                                        "ruta"=>$row->ruta_servidor
                                        );
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
                ->select("tgrav.tipe as tipo") 
                ->from("datos.declara as decl")
                ->join('datos.calpagod as calpd','calpd.id=decl.calpagodid')
                ->join('datos.calpago as calp','calp.id=calpd.calpagoid') 
                ->join('datos.tipocont as tcon','tcon.id=decl.tipocontribuid')
                ->join('datos.tipegrav as tgrav','tgrav.id=tcon.tipegravid') 
                ->where(array('reparoid'=>$id,'bln_reparo'=>'true'));
                
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
                                        "tipo"=>$row->tipo
                                        
                                        );
                 endforeach;

           }
           
           return $data;
        
        
        
    }
    
    function activa_reparo_contribuyente($id,$fecha,$recibido)
    {        
        $this->db->where('id',$id);
        $this->db->update('datos.reparos',array('bln_activo'=>'true','fecha_notificacion'=>$fecha,'recibido_por'=>$recibido));
        // verificamos si hizo el update 
        if($this->db->affected_rows()>0)
        {
            $respuesta=array('resultado'=>true,'mensaje'=>'Datos Actualizados Correctamente'); 
            return $respuesta;

        }else{

            $respuesta=array('resultado'=>FALSE,'mensaje'=>'Datos no Actualizados'); 
            return $respuesta;
        }                   
        
    }
    
    function devuelve_id_declara($tcontribu,$calpagoid,$conusuid){
        
       $data=0;
         $this->db
                 ->select('declara.id')
                 ->from('datos.declara')
                 ->where(array('tipocontribuid'=>$tcontribu,'conusuid'=>$conusuid,'calpagodid'=>$calpagoid));
          $query = $this->db->get();

    
            if( $query->num_rows()>0 ):
                foreach ($query->result() as $row):
                    
                     $data=$row->id;  
            
                 endforeach;
             endif;
            
        return $data;
        
    }
    
    function datos_actas_fiscalizacion($idconusu,$idtipocont,$nroautorizacion){
        
        $this->db
                ->select('conu.rif as rifconu, conu.nombre as conusunom',true)
                ->select('cont.domfiscal as domfiscal,cont.telef1 as telefono')
                ->select('tcont.nombre as tipocontribu, tcont.numero_articulo as art')
                ->select('asigf.periodo_afiscalizar as anio_fis')
                ->from('datos.conusu as conu')
                ->join('datos.contribu as cont','cont.rif=conu.rif','left')
                ->join('datos.conusu_tipocont as tconconu','tconconu.conusuid=conu.id')
                ->join('datos.tipocont as tcont','tcont.id=tconconu.tipocontid')
                ->join('datos.asignacion_fiscales as asigf','asigf.conusuid=conu.id')
                ->where(array('conu.id'=>$idconusu,'tcont.id'=>$idtipocont,'asigf.nro_autorizacion'=>$nroautorizacion));
         $query = $this->db->get();

    
            if( $query->num_rows()>0 ){
               foreach ($query->result() as $row):                   
                    $data= array("nombre"=> $row->conusunom,
                                   "rif"=> $row->rifconu,
                                   "domfiscal"=> $row->domfiscal,
                                   "telefono"=> $row->telefono, 
                                   "tipocontribu"=>$row->tipocontribu,
                                   "articulo"=>$row->art,
                                   "anio_fis"=>$row->anio_fis

                                   );  
               endforeach;
               return $data;
           }
           
        
    }
    
    function datos_gerente_general()
    {
         $this->db
                ->select('usfon.nombre as nombre, usfon.cedula as cedula',true)
                ->from('datos.usfonpro as usfon')
                ->join('datos.departam as dep','dep.id=usfon.departamid')
                ->join('datos.cargos as cargo','cargo.id=usfon.cargoid')
                ->where(array('cargo.codigo_cargo'=>'C-001','dep.cod_estructura'=>'G-GEN-05'));
          $query = $this->db->get();

    
            if( $query->num_rows()>0 ){
               foreach ($query->result() as $row):                   
                    $data= array("gerenteg"=> $row->nombre,
                                   "gerentegcedula"=> $row->cedula
                                   );  
               endforeach;
               return $data;
           }
    }
    
    function datos_complementarios_contribuyente($conusuid){
        $this->db
                ->select("contribu.*",FALSE)
                ->select("contribu.id as id_contribu",FALSE)
                ->select("estados.nombre as nomest",FALSE)
                ->select("ciudades.nombre as nomciu",FALSE)
                ->select("conusu.inactivo as inac",FALSE)
                ->select("conusu.rif as rifconusu, conusu.nombre as nombre",FALSE)
                ->select("conusu.email as emailconusu",FALSE)
                ->from("datos.conusu")
                ->join('datos.contribu', 'conusu.rif=contribu.rif','left' )
                ->join('datos.estados','estados.id = contribu.estadoid','left')                 
                ->join('datos.ciudades', 'ciudades.id=contribu.ciudadid ','left' )
                ->where(array("conusu.id"=>$conusuid));
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
                'ciudadid'=>$data->ciudadid,
                'conusuid'=>$conusuid);
       else:
           return array('resultado'=>false);
       endif;
        
        
    }
    
    
    
   
    
    
    
    
   
    

}