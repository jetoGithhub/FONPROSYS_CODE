<?php
class Gestion_calendarios_de_pago_m extends CI_Model{
    function __construct() {
        parent::__construct();
    }
    function lista_tipo_contribuyente(){
        $this->db
                ->select("tipocont.nombre as ntcon")
                ->select("tipegrav.*")
                ->from("datos.tipocont") 
                ->join('datos.tipegrav','tipegrav.id=tipocont.tipegravid')
                ->order_by("peano");
        $query = $this->db->get();
        if( $query->num_rows()>0 ):
            $data = array();
        foreach ($query->result() as $row):
            $data[] = array(
                "id"        => $row->id,
                "nombre"    => $row->ntcon,
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
    function inserta_calendario($data_calpago = array(), $fecha_periodoi= array(),$fecha_periodof= array(),$fecha_periodol= array()){

        $this->db->trans_begin();

       
        $this->db->insert('datos.calpago', $data_calpago); 
        $id_calpago = $this->db->insert_id();
        $tamanio=  count($fecha_periodoi);
//        foreach ($data_calpagod as $clave=>$valor):
        for($i=1;$i<=$tamanio;$i++):
            if($i<10):
                
                $clave='0'.$i;
            else:
                $clave=$i;   
                
            endif;
            $data_calpagod_true = array(
                'calpagoid'     =>$id_calpago,
                'fechaini'      =>$fecha_periodoi[$i],
                'fechafin'      =>$fecha_periodof[$i],
                'fechalim'      =>$fecha_periodol[$i],
                'usuarioid'     =>$this->session->userdata('id'),
                'ip'            =>$this->input->ip_address(),
                'periodo'=>$clave
            );
            $this->db->insert('datos.calpagod', $data_calpagod_true); 
        endfor;
//        endforeach;
        if ($this->db->trans_status() === FALSE)
        {
            $this->db->trans_rollback();
            return FALSE;
        }
        else
        {
            $this->db->trans_commit();
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
    
    function verifica_calendario($tipegrav,$anio){
       $this->db->select('*');
        $this->db->from('datos.calpago');
        $this->db->where(array('ano'=>$anio,'tipegravid'=>$tipegrav));
        $query = $this->db->get();
       if($query->num_rows()>0): 
               
           return TRUE;
       else:
           return FALSE;
       endif;
               
    }
    
    function consulta_calendario($tipe_grav,$anio)
    {
        $this->db
                ->select("calpago.ano as anio")
                ->select("calpagod.*")
                ->from("datos.calpago") 
                ->join('datos.calpagod','calpagod.calpagoid=calpago.id')
                ->where(array('calpago.tipegravid'=>$tipe_grav,'calpago.ano'=>$anio))
                ->order_by("calpagod.periodo");
        $query = $this->db->get();
        if( $query->num_rows()>0 ):
            $data = array();
        foreach ($query->result() as $row):
            $data[] = array(
                "id"        => $row->id,
                "fechai"    => $row->fechaini,
                "fechaf"      => $row->fechafin,
                "fechal"     => $row->fechalim,
                "periodo"     => $row->periodo,

                            );
        endforeach;
        return $data;
        else:
            return false;
        endif;
        
    }
}
?>