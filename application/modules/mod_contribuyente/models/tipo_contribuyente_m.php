<?php

class Tipo_contribuyente_m extends CI_Model{
    function __construct(){  
	parent::__construct();
        
        }

       function trae_registro_tcontribu($id_usuario){
        $this->db
                ->select("*")
                ->select("conu.nombre empresa")
                ->select("tcon.nombre as contribuyente")
                ->from("datos.conusu_tipocont as conu_t")
                ->join("datos.conusu as conu","conu.id=conu_t.conusuid")
                ->join("datos.tipocont as tcon","tcon.id=conu_t.tipocontid")
                ->where(array("conusuid"=>$id_usuario));
               
        $query = $this->db->get();
        if( $query->num_rows()>0 ):
            $data = array();
        foreach ($query->result() as $row):
            $data[] = array(
            "tcontribu"	=> $row->contribuyente,
            "felab"=> $row->fecha_elaboracion);
        endforeach;
        return $data;
        else:
            return false;
        endif;
    }
    
}
