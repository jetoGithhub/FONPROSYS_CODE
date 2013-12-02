<?php
if (!defined('BASEPATH'))
    exit('No direct script access allowed');
 
class Temporal extends CI_Model {
 
    function construct() {
        parent::__construct();
    }
 
    //FUNCIÓN PARA INSERTAR LOS DATOS DE LA IMAGEN SUBIDA
    function guarda_imagen($datos_img_conusu)
    {
        if (is_array($datos_img_conusu)):
            $this->db->insert('datos.con_img_doc', $datos_img_conusu);
            if ( $this->db->affected_rows()>0 ):
                return true;
            else:
                return false;
            endif;
        else:
            return false;
        endif;
        
    }
    function busca_archivos_contribu($id){
        $data = array();
        $this->db
                ->select("*")
                ->from("datos.con_img_doc")
                ->where(array('conusuid'=>$id));
        $query = $this->db->get();
        if( $query->num_rows()>0 ){
            foreach ($query->result() as $row):
                $data[] = array(
                    'id'            => $row->id,
                    'fecha'         => $row->fecha,
                    'conusuid'      => $row->conusuid,
                    'descripcion'   => $row->descripcion,
                    'usuarioid'     => $row->usuarioid,
                    'ip'            => $row->ip,
                    'ruta_imagen'   =>$row->ruta_imagen);
                 endforeach;

           }
           
           return $data;
     }
     function elimina_archivo($id){
         $this->db->delete('datos.con_img_doc', array('id' => $id)); 
     }
     function elimina_accionista($id){
         
         $this->db->delete('datos.accionis', array('id' => $id));
         if($this->db->affected_rows()>0):
             return true;
         else:
             return false;
         endif;
     }
}