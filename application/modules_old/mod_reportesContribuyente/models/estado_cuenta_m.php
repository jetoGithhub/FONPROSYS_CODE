<?php

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 * Description of estado_cuenta_m
 *
 * @author jetox
 */
class Estado_cuenta_m extends CI_Model{
    //put your code here
    
    /*
    * 
    * @acces public
    * @param integer
    * @return array
    * 
    */
   function tipo_contribuyente()
   {
       $this->db
                ->select('tcon.id as tipocontid, tcon.nombre as tipo_contribu')
                ->from("datos.conusu_tipocont conut")
               ->join("datos.tipocont as tcon","conut.tipocontid=tcon.id")
                ->where(array("conut.conusuid"=>  $this->session->userdata('id')));
        $query = $this->db->get();
            
        return ($query->num_rows()>0 ? $query->result_array() : array());
   }
}

?>
