<?php

class Usuario_m extends CI_Model{
    function __construct(){  
	parent::__construct();
        
        }

    function login_valido($usuario,$clave){
        $this->db
                ->from("datos.conusu")
                ->where(array("login"=>$usuario,"password"=>do_hash($clave)));
        $query = $this->db->get();
        if( $query->num_rows()>0 ):
            $data = $query->row();
        return array(
            "acceso"    => true,
            "id"	=> $data->id,
            "usuario"	=> $data->login,
            "nombre"	=> $data->nombre,
            "validado"  => $data->validado);
            else:
                return false;
            endif;

    }
    function get_permisos($id_usuario){
        $this->db
                ->select("*")
                ->from("segContribu.view_modulo_usuariocontribuyente_permiso")
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
    
}
?>