<?php

class Roles_m extends CI_Model{
    function __construct() {
        parent::__construct();

    }
    
    function perfiles_registrados(){
        
        $this->db
                ->select('*')
                ->from('seg.tbl_rol')
                ->where(array('bln_borrado'=>'false'));
        $query = $this->db->get();
        if ($query->num_rows()>0):
            $data = array();
            foreach ($query->result() as $row):
                    $data[] = array(
                        'id'     => $row->id_rol,
                        'nombre' => $row->str_rol,
                        'descripcion' => $row->str_descripcion
                    );
            endforeach;

            return $data;
    else:
            return false;
    endif;          
        
    }
    
    function modulos_segun_rol($id){
        
        $this->db
//                ->select("tbl_rol.*",FALSE)
                ->select("mod.str_nombre,mod.id_padre,mod.id_modulo",FALSE)
                ->from("seg.tbl_rol as rol ")
                ->join('seg.tbl_permiso as perm','perm.id_rol=rol.id_rol')
                ->join('seg.tbl_modulo as mod ','mod.id_modulo=perm.id_modulo')                 
                ->where(array("rol.id_rol"=>$id,"mod.bln_borrado"=>'false','perm.bln_borrado'=>'false'));
              $query = $this->db->get();

              if( $query->num_rows()>0 ){
                  
                    foreach ($query->result() as $data):
                            
                            $modulos[] = array('nombre'=>$data->str_nombre,'padreid'=>$data->id_padre,'moduloid'=>$data->id_modulo);
                    endforeach;
                 
                    return $modulos;
            
              }
        
        
    }
    
    function inserta_modulos_perfil($perfil,$datos=array()){
        
            $this->db->trans_start();
             $this->db->where('id_rol', $perfil);
            $this->db->delete('seg.tbl_permiso');
             for($i=0;$i<count($datos);$i++){
                 
                 
                 $this->db->insert('seg.tbl_permiso',array('id_modulo'=>$datos[$i],'id_rol'=>$perfil,'int_permiso'=>1));
                 
             }
             
         $this->db->trans_complete();
         if ($this->db->trans_status() === FALSE):
             $this->db->trans_rollback();
            return false;
         else:
             $this->db->trans_commit();
             return true;
         endif;
        
        
    }
    
    function eliminar_perfil($id){
   
            $this->db->where('id_rol', $id);
            $this->db->update('seg.tbl_rol', array('bln_borrado'=>'true'));
            
            if($this->db->affected_rows()>0){// verificamos si hizo el update
                
                        $this->db->where('id_rol', $id);
                        $this->db->delete('seg.tbl_permiso');

                        $respuesta=array('resultado'=>true,'mensaje'=>'Datos Actualizados Correctamente');

                    }else{

                       $respuesta=array('resultado'=>false,'mensaje'=>'Error al Actualizar los Datos');

            }

            return $respuesta;
        
    }
}
?>