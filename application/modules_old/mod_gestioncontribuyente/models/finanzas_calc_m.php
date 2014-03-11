<?
/*
 * Modelo: finanzas_calc_m
 * Accion: Modelo que incluye las funciones correspondientes al modulo de Finanzas
 * LCT - 2013 
 */
class Finanzas_calc_m extends CI_Model{


    //funcion buscar extemporaneos
    function buscar_extemporaneos1(){        
        $data = array();
        
        $this->db
                   ->select("*")
                   ->from("datos.declara")
                   ->where(array("proceso"=>"enviado"));
           
            $query = $this->db->get();
            if( $query->num_rows()>0 ){
                  
                foreach ($query->result() as $row):
                            
                            $data[] = array(
                                            "contribuyente" => $row->conusuid,
                                
                                            );
                 endforeach;

           }
           
           return $data;
        
        
    }
    
    
    
    
    //funcion prueba
    function buscar_extemporaneos(){        
        $data = array();
        
        $this->db
                   ->select("*")
                   ->from("datos.declara")
                   ->where(array("proceso"=>"enviado", "bln_reparo"=>"FALSE"));
           
            $query = $this->db->get();
            if( $query->num_rows()>0 ){
                  
                foreach ($query->result() as $row):
                            
                            $data[] = array(
                                            "contribuyente" => $row->conusuid,
                                
                                            );
                 endforeach;

           }
           
           return $data;
        
        
    }
   

}