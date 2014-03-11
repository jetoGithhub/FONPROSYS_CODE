<?
/*
 * Modelo: bancos_m
 * Accion: Modelo que incluye las funciones vinculadas sub-modulo Bancos del modulo Finanzas
 * LCT - 2013 
 */
class Bancos_m extends CI_Model{

    
    //funcion buscar Bancos
    function buscar_bancos(){        
        $data = array();
        
        $this->db
                   ->select("*")
                   ->from("datos.bancos")
                   ->where(array("bancos.bln_borrado"=>'FALSE'))
                   ->order_by('fecha_registro');
           
            $query = $this->db->get();
            if( $query->num_rows()>0 ){
                 
                foreach ($query->result() as $row):
                            
                            $data[] = array(
                                            "nombre"	=> $row->nombre,
                                            "id_bancos"   => $row->id,
                                            "fecha_registro"   => $row->fecha_registro,
                                
                                            );
                 endforeach;

           }
           
           return $data;
    }
    


    /*la eliminacion sera logica, cambiando solo el campo bln_borrado a true, de esta forma el banco no podra ser visualizado 
    desde el listar y el usuario pensara que este fue eliminado; sin embargo, permanecera el registro oculto en la tabla*/
    function eliminar_bancos($id){

       
            $this->db->trans_start();
            //las condiciones del where deben establecerse como arreglos
                $this->db->where(array('id'=> $id));
                $this->db->delete('datos.interes_bcv');
                
                 
            $this->db->trans_complete();
        
        
            if ($this->db->trans_status() === FALSE):
                $this->db->trans_rollback();
                return false;
            else:
                $this->db->trans_commit();
                return true;
            endif;

            
     }
     
     //funcion que verifica si el banco que se intenta registrar ya se encuentra registrado
     function verifica_bancos($nombre_bancos){
		
		/* OJO con esto... estaba pensando, si el usario elimina un banco, por ejemplo Bicentanario
		 * ya nosotros sabemos que en realidad no lo elimino, fue solo un borrado logico, porque en
		 * la BD sigue registrado.... entonces resulta que despues vienen y registran ese mismo banco,
		 * no lo va a dejar porque va a decir que el banco ya esta y el usuario va a preguntarse 
		 * POR QUEEEEEÉ??? si no lo veo por ningún lado .... jejeje es un decir de su posible reacción...
		 * entonces se me ocurrió colocar otra condición en el where, para que ademas de comparar que no sea
		 * un nombre repetido que el bln_borrado este en false (es decir que se este mostrando en el listar), solo 
		 * asi no lo dejara registrar... Pero que pasó??? las condiciones de la tabla no lo permite
		 * muestra el error de base de datos que ya el banco existe... entonces, hasta ahí llegue yop
		 * O SE ELIMINA EL BORRADO LOGICO Y SE BORRAN COMPLETAMENTE O SE ELIMINA ESA CONDICION DE LA TABLA DE EVITAR REPETIDOS
		 */
		
		//~ $borrado='FALSE';
		
        $this->db
                //seleccionar todo de la tabla bancos
                   ->select("*")
                   ->from("datos.bancos")
//                   ->where(array("nombre"=>$nombre_bancos));
                   ->where(array("nombre"=>$nombre_bancos,"bln_borrado"=>'FALSE'));

            $query = $this->db->get();
            if( $query->num_rows()>0 ){

                $return=TRUE;
           }else{
               $return=FALSE;
           }
           
           return $return;


     }

}
