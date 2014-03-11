<?
class Buscar_planilla_m extends CI_Model{
    
    function datos_contribuyente($rif){        
         
        $this->db
                   ->select("contribu.*",FALSE)
                    ->select("estados.nombre as nomest",FALSE)
                    ->select("ciudades.nombre as nomciu",FALSE)
                    ->select("conusu.inactivo as inac",FALSE)
                   ->from("datos.contribu")
                   ->join('datos.estados','estados.id = contribu.estadoid')                 
                   ->join('datos.ciudades', 'ciudades.estadoid=estados.id' )
                   ->join('datos.conusu', 'conusu.id=contribu.usuarioid' )
                   ->where(array("contribu.rif"=>$rif));
                  
           $query = $this->db->get();
           
            if( $query->num_rows()>0 ){
                   $data = $query->row();

                   return array(
                           'resultado'=>true,
                           "razonsocial" => $data->razonsocia,
                           "denominacionc" => $data->dencomerci,
                           "actividade" => $data->actieconid,
                           "rif" => $data->rif,
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
                            'email'=>$data->email,    
                            'pinbb'=>$data->pinbb,    
                           'skype'=>$data-> skype,    
                            'twitter'=>$data->twitter, 
                            'facebook'=>$data->facebook,  
                           'nuacciones'=>$data->nuacciones,
                           'valaccion'=>$data->valaccion, 
                            'capitalsus'=>$data->capitalsus,
                            'capitalpag'=>$data->capitalpag,
                            'regmerofc '=>$data->regmerofc, 
                            'rmnumero'=>$data->rmnumero, 
                           'rmfolio'=>$data->rmfolio, 
                           'rmtomo'=>$data->rmtomo,  
                            'rmfechapro'=>$data->rmfechapro,
                            'rmncontrol'=>$data->rmncontrol,
                            'rmobjeto'=>$data-> rmobjeto, 
                            'domcomer'=>$data->domcomer,
                            'inactivo'=>$data->inac,
                            'usuarioid'=>$data->usuarioid
                   );
           }else{
               
                    return array('resultado'=>false);
               
           }
        
        
    }
    
    function activar_contribuyente($valor){
         $this->db->trans_start();
         
            $this->db->where('id', $valor);
            $this->db->update('datos.conusu',$data=array('inactivo'=>'false'));
            
            $this->db->where('id_usuario', $valor);
            $this->db->update('segContribu.tbl_rol_usuario_contribu',$data=array('id_rol'=>1));
//            $this->db->insert('segContribu.tbl_rol_usuario_contribu',$datosRolInicialContribuyente=array('id_rol'=>1,'id_usuario'=>$valor));
            $this->db->trans_complete();

          if ($this->db->trans_status() === FALSE):
                $this->db->trans_rollback();
          
               return array('resultado'=>'false');
            
          else:
                
                $this->db->trans_commit();
                return array('resultado'=>'true');
                
            endif;
                  
        
        
    }
    
  
}
