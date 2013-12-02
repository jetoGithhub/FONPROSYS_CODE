<?php
class Gestion_calendarios_de_pago_m extends CI_Model{
    function __construct() {
        parent::__construct();
    }
    function lista_tipo_contribuyente(){
        $this->db
                ->select("*")
                ->from("datos.tipegrav")                
                ->order_by("nombre");
        $query = $this->db->get();
        if( $query->num_rows()>0 ):
            $data = array();
        foreach ($query->result() as $row):
            $data[] = array(
                "id"        => $row->id,
                "nombre"    => $row->nombre,
                "tipe"      => $row->tipe,
                "peano"     => $row->peano,

                            );
        endforeach;
        return $data;
        else:
            return false;
        endif;
    }
    function lista_anio_cal($id){
        $this->db
                ->select("*")
                ->from("datos.calpago")
                ->where(array('tipegravid'=>$id))
                ->order_by("nombre");
        $query = $this->db->get();
        if( $query->num_rows()>0 ):
            $data = array();
        foreach ($query->result() as $row):
            $data[] = array(
                "id"        => $row->id,
                "nombre"    => $row->nombre,
                "tipegravid"      => $row->tipegravid,
                "ano"     => $row->ano,

                            );
        endforeach;
        return $data;
        else:
            return false;
        endif;
    }
    function inserta_calendario($data_calpago = array(), $data_calpagod = array()){

        $this->db->trans_begin();

       
        $this->db->insert('datos.calpago', $data_calpago); 
        $id_calpago = $this->db->insert_id();
        
        foreach ($data_calpagod as $clave=>$valor):
            $data_calpagod_true = array(
                'calpagoid'     =>$id_calpago,
                'fechaini'      =>$valor,
                'fechafin'      =>$valor,
                'fechalim'      =>$valor,
                'usuarioid'     =>$this->session->userdata('id'),
                'ip'            =>$this->input->ip_address(),
                'periodo'=>$clave
            );
            $this->db->insert('datos.calpagod', $data_calpagod_true); 
        endforeach;
        if ($this->db->trans_status() === FALSE)
        {
            $this->db->trans_rollback();
            return FALSE;
        }
        else
        {
            $this->db->trans_rollback();
//            $this->db->trans_commit();
            return TRUE;
        }        
    }
    function trae_tipegrav($id){
        $this->db->select('nombre');
        $this->db->from('datos.tipegrav');
        $this->db->where(array('id'=>$id));
        $query = $this->db->get();
        return ($query->num_rows()>0 ? $query->result_array() : FALSE);
    }
}
?>