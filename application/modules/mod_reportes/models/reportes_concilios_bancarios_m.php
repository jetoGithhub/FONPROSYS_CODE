<?php

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 * Description of reportes_concilios_bancarios_m
 *
 * @author jetox
 */
class Reportes_concilios_bancarios_m extends CI_Model {
   
    function devuelve_tipo_contribuyente(){
        
        $this->db
                   ->select("tcon.id as id, tcon.nombre as nombre")                
                    ->from("datos.tipocont as tcon");
        
           
            $query = $this->db->get();
            return ($query->num_rows()>0 ? $query->result_array() : false);
    }
    
    function datos_busqueda_concilio($tipo,$where,$respuesta)
    {
        if($tipo==0):
            
            $this->db
                   ->select("*")                
                    ->from("datos.vista_conciliacion_bancaria_autoliquidaciones")
                    ->where($where);       
            
         else:
        $this->db
                   ->select("*")                
                    ->from("datos.vista_conciliacion_bancaria_multas")
                    ->where($where);  
            
        endif;
       $query = $this->db->get();
       $c=count($respuesta);
        if ($query->num_rows()>0):
//            $data = array();
            foreach ($query->result() as $key=>$row):    
                for($i=0;$i<$c;$i++){
                       $v=$respuesta[$i];

                        $data[$key][$v]= $row->$v;                 

                }
            endforeach;
        else:
            $data=FALSE;
        endif;
      return $data;  
    }
}

?>
