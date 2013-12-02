<?

class Recaudacion_m extends CI_Model{

    
    function activa_multa_extem_contribuyente($array){
        
                $this->db->where_in('id',$array);
                $this->db->update('datos.detalles_contrib_calc',array('proceso'=>'notificado'));
                 if($this->db->affected_rows()>0){// verificamos si hizo el update


                        $respuesta=true;

                    }

                    return $respuesta;
        
    }
    
   
    
    
   
    

}