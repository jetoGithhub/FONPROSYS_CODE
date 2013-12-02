<?
class Manejo_modulo_m extends CI_Model{
    
    function buscar_modulos(){        
        $data = array();
        
        $this->db
                   ->select("*")
                   ->from("seg.tbl_modulo")
                   ->where(array("bln_borrado"=>"false"))
                   ->order_by("id_modulo");
           
            $query = $this->db->get();
            if( $query->num_rows()>0 ){
                
//      
                foreach ($query->result() as $row):
                            
                            $data[] = array(
                                            "id_modulo"     => $row->id_modulo,
                                            "str_modulo"	=> $row->str_nombre,                                            
                                            "str_enlace"	=> $row->str_enlace,
                                            "id_padre"      => $row->id_padre
                                
                                            );
                 endforeach;

           }
           
           return $data;
        
        
    }
    
   
}