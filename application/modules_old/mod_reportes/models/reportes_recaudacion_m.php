<?
/*
 * Modelo: gestion_usuario_m
 * Accion: modelo que contiene las funciones correspondientes al modulo gestion de usuarios
 * LCT - 2013 
 */
class Reportes_recaudacion_m extends CI_Model{
    
   function devuelve_tipo_contribuyente(){
        
        $this->db
                   ->select("tcon.id as id, tcon.nombre as nombre")                
                    ->from("datos.tipocont as tcon");
        
           
            $query = $this->db->get();
            return ($query->num_rows()>0 ? $query->result_array() : false);
    }
    
    function datos_reporte_rise($where)
    {
        $this->db
                   ->select("*")                
                    ->from("datos.vista_reportes_recaudacion_rise")
                   ->where($where);        
           
            $query = $this->db->get();
            return ($query->num_rows()>0 ? $query->result_array() : array());
        
    }
    function datos_reporte_principal_recaudacion($where)
    {
        $this->db
                   ->select("*")                
                    ->from("datos.vista_reporte_principal_recaudacion")
                   ->where($where);        
           
            $query = $this->db->get();
            return ($query->num_rows()>0 ? $query->result_array() : array());
    }
    function total_recaudacion_poranio()
    {
        $this->db
                   ->select("*")                
                    ->from("datos.vista_total_recaudacion_poranio");
           
            $query = $this->db->get();
            return ($query->num_rows()>0 ? $query->result_array() : array());
    }
    
}