<?
/*
 * Modelo: und_tributarias_m
 * Accion: Modelo que incluye las funciones vinculadas sub-modulo Unidades tributarias del modulo Finanzas
 * LCT - Diciembre 2013 
 */
class Und_tributarias_m extends CI_Model{

    
    //funcion buscar unidades tributarias
    function buscar_und_tributarias(){        
        $data = array();
        
        $this->db
                   ->select("*")
                   ->from("datos.undtrib")
                   ->order_by('anio',"desc");
           
            $query = $this->db->get();
            if( $query->num_rows()>0 ){
                 
                foreach ($query->result() as $row):
                            
                            $data[] = array(
                                            "anio"	=> $row->anio,
                                            "valor"   => $row->valor,
                                            "id_undtrib"   => $row->id,
                                
                                            );
                 endforeach;

           }
           
           return $data;
    }
    


    function eliminar_undtributarias($id){

       
            $this->db->trans_start();
            //las condiciones del where deben establecerse como arreglos
                $this->db->where(array('id'=> $id));
                $this->db->delete('datos.undtrib');
                
                 
            $this->db->trans_complete();
        
        
            if ($this->db->trans_status() === FALSE):
                $this->db->trans_rollback();
                return false;
            else:
                $this->db->trans_commit();
                return true;
            endif;

            
     }

}
