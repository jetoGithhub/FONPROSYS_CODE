<?
class Principal_m extends CI_Model{
    
    function buscar_hijos($valor){        
        $data = array();
        
        $this->db
                   ->select("str_nombre,str_enlace")
                   ->from("seg.tbl_modulo")
                   ->where(array("id_padre"=>$valor,"bln_borrado"=>"false"));
           
            $query = $this->db->get();
            if( $query->num_rows()>0 ){
                
//      
                foreach ($query->result() as $row):
                            
                            $data[] = array(
                                            "nombre"	=> $row->str_nombre,
                                            "enlace"      => $row->str_enlace,
                                
                                            );
                 endforeach;

           }
           
           return $data;
        
        
    }
    
    function carga_select_rol(){
        
        $this->db
                ->select('*')
                ->from('seg.tbl_rol')
                ->where(array("bln_borrado"=>"false"));
        $query = $this->db->get();
        if ($query->num_rows()>0):
            $data = array();
            foreach ($query->result() as $row):
                    $data[] = array(
                        'id_rol'     => $row->id_rol,
                        'nombre' => $row->str_rol
                    );
            endforeach;

            return $data;
        else:
            return false;
        endif;        
                
                
    }
    function registro_modulo_padre($datos = array(),$rol){
        if(is_array($datos)):
            $this->db->trans_start();
                $this->db->insert('seg.tbl_modulo',$datos);
                $id= $this->db->insert_id();
                $datospermiso= array(                    
                    'id_modulo'  => $id,
                    'id_rol' => $rol,
                    'int_permiso' => 1
                    );
                $this->db->insert('seg.tbl_permiso',$datospermiso);
                 
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
}
