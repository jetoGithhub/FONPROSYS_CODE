<?php

class Modelo_usuario extends CI_Model{
    function __construct(){  
	parent::__construct();
        
        }
        
        

    function login_valido($usuario,$clave){
        $this->db
                ->from("datos.usfonpro")
                ->where(array("login"=>$usuario,"password"=>  do_hash($clave),'bln_borrado'=>'false'));
        $query = $this->db->get();
        if( $query->num_rows()>0 ):
            $data = $query->row();
        return array(
            "id"	=> $data->id,
            "usuario"	=> $data->login,
            "nombre"	=> $data->nombre,
            "ingreso_sistema"	=> $data->ingreso_sistema,
            'inactivo'=>$data->inactivo
            );
            else:
                return false;
            endif;

    }
    
    //funcion para verificar el primer ingreso del usuario
    function verificar_primer_ingreso($id_usuario){
        $this->db
                ->from("datos.usfonpro")
                ->where(array("id"=>$id_usuario));
        $query = $this->db->get();
        if( $query->num_rows()>0 ):
            $data = $query->row();
        return array(
            "id"	=> $data->id,
            "usuario"	=> $data->login,
            "nombre"	=> $data->nombre,
            "ingreso_sistema"	=> $data->ingreso_sistema
            );
            else:
                return false;
            endif;

    }
    
    
    
    
    function get_permisos($id_usuario){
        $this->db
                ->select("*")
                ->from("seg.view_modulo_usuario_permiso")
                ->where(array("id"=>$id_usuario, "int_permiso >"=>"0"))
                ->order_by("int_orden");
        $query = $this->db->get();
        if( $query->num_rows()>0 ):
            $data = array();
        foreach ($query->result() as $row):
            $data[] = array(
                "str_usuario"	=> $row->nombre,
                "str_rol"       => $row->str_rol,
                "id_modulo"     => $row->id_modulo,
                "str_modulo"	=> $row->str_nombre,
                "int_permiso"	=> $row->int_permiso,
                "str_enlace"	=> $row->str_enlace,
                "id_padre"      => $row->id_padre
                            );
        endforeach;
        return $data;
        else:
            return false;
        endif;
    }
    
    function devuelve_tipo_tipegrav_contribuyente($id)
    {
        $this->db
                   ->select('tgrav.tipe tipo')
                   ->from('datos.tipocont as tcon')
                   ->join('datos.tipegrav as tgrav','tgrav.id=tcon.tipegravid')
                   ->where(array('tcon.id'=>$id));
         $query = $this->db->get();
        if( $query->num_rows()>0 ):
            $data = $query->row();
                return $data->tipo;
            else:
                return false;
            endif;
    }
    
}
?>
