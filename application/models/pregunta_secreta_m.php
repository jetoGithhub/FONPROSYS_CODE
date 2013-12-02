<?
/*
 * Modelo: pregunta_secreta_m
 * Accion: modelo que contiene las funciones correspondientes para registrar 
 * la pregunta secreta en el primer logueo por parte de un usuario
 * LCT - Agosto 2013 
 */
class Pregunta_secreta_m extends CI_Model{

    
    
    //funciones que aplica el formulario de registro de pregunta secreta por parte del usuario

    //armar combo de preguntas secretas
    function preguntaSecreta($id=''){
        
        $this->db
                ->select('*')
                ->from('datos.pregsecr');
                if (!empty($id)){ $this->db->where(array('id'=>$id)); }
        $query = $this->db->get();
        if ($query->num_rows()>0):
            $data = array();
            foreach ($query->result() as $row):
                    $data[] = array(
                        'id'     => $row->id,
                        'nombre' => $row->nombre
                    );
            endforeach;

            return $data;
    else:
            return false;
    endif;        
                
                
    }
    
    
  

    
}
