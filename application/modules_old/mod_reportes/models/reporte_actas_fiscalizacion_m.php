<?php

/**
 * 
 *
 * @author jefferson
 */
class Reporte_actas_fiscalizacion_m extends CI_Model {

    function busca_actas_fiscalizacion($tipo,$anio,$respuesta=null)
    {
        $select='';
        if($respuesta==NULL):
            $select='*';
        else:
            for($i=0;$i<count($respuesta);$i++)
            {
               $select.=$select.','.$respuesta[$i];    

            }
        endif;
        $this->db
                   ->select($select)                
                    ->from("datos.vista_reporte_actas_fizcalizacion");
                    if($tipo==3):
                        $this->db->where(array('anio'=>$anio,'reparo_encendido'=>1));
                    else:
                        $this->db->where(array('anio'=>$anio));
                    endif;
                    $this->db->order_by('nro_autorizacion');
            $query = $this->db->get();
            
            return ($query->num_rows()>0 ? $query->result_array() : array());
            
    }
}
?>
