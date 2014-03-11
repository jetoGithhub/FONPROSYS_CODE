<?
class Principal_m extends CI_Model{
    
    function buscar_hijos($valor){        
        $data = array();
        
        $this->db
                   ->select("str_nombre,str_enlace,orden_pestanas")
                   ->from("segContribu.tbl_modulo_contribu")
                   ->where(array("id_padre"=>$valor,"bln_borrado"=>"false"))
                    ->order_by('orden_pestanas');
           
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
    
    
}