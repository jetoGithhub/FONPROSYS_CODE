<?
/*
 * Modelo: interes_bcv_m
 * Accion: Modelo que incluye las funciones vinculadas sub-modulo Interes BCV del modulo Finanzas
 * LCT - 2013 
 */
class Interes_bcv_m extends CI_Model{

    
    //funcion buscar interes bcv
    function buscar_interes_bcv(){        
        $data = array();
        
        $this->db
                   ->select("*")
                   ->from("datos.interes_bcv")
                   ->order_by('anio');
           
            $query = $this->db->get();
            if( $query->num_rows()>0 ){
                 
                foreach ($query->result() as $row):
                            
                            $data[] = array(
                                            "anio"	=> $row->anio,
                                            "tasa"   => $row->tasa,
                                            "mes"      => $row->mes,
                                            "id_interesbcv"   => $row->id,
                                
                                            );
                 endforeach;

           }
           
           return $data;
    }
    


    function eliminar_interesbcv($id){

       
            $this->db->trans_start();
            //las condiciones del where deben establecerse como arreglos
                $this->db->where(array('id'=> $id));
                $this->db->delete('datos.interes_bcv');
                
                 
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
