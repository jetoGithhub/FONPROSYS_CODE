<?
/*
 * Modelo: presidentescnac_m
 * Accion: Modelo que incluye las funciones vinculadas sub-modulo Presidentes CNAC del modulo Administracion del Sistema
 * LCT - Diciembre 2013 
 */
class Presidentescnac_m extends CI_Model{

    
    //funcion buscar Presidentes
    function buscar_presidentes(){        
        $data = array();
        
        $this->db
                   ->select("*")
                   ->from("datos.presidente")
//                   ->where(array("bancos.bln_borrado"=>'FALSE'))
                   ->order_by('bln_activo');
           
            $query = $this->db->get();
            if( $query->num_rows()>0 ){
                 
                foreach ($query->result() as $row):
                            
                            $data[] = array(
                                            "nombres"	=> $row->nombres,
                                            "apellidos"	=> $row->apellidos,
                                            "cedula"	=> $row->cedula,
                                            "nro_decreto"	=> $row->nro_decreto,
                                            "nro_gaceta"	=> $row->nro_gaceta,
                                            "dtm_fecha_gaceta"	=> $row->dtm_fecha_gaceta,
                                            "bln_activo"	=> $row->bln_activo,
                                            "fecha_registro"   => $row->fecha_registro,
                                            "bln_borrado"	=> $row->bln_borrado,
                                            "id_presidente"	=> $row->id,
                                
                                            );
                 endforeach;

           }
           
           return $data;
    }
    


     
     //funcion que verifica si existen presidentes registrados
     function verifica_presidente(){

        $this->db
                //seleccionar todo de la tabla presidente
                   ->select("*")
                   ->from("datos.presidente");

            $query = $this->db->get();
            if( $query->num_rows()>0 ){

                $return=TRUE;
           }else{
               $return=FALSE;
           }
           
           return $return;


     }
     
     function inserta_presidente_activo($insert)
     {       
        
        $this->db->trans_start();
            
           $this->db->update('datos.presidente', array('bln_activo'=>'false'));
                 
                 
           $this->db->insert('datos.presidente',$insert);
                 
                         
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
