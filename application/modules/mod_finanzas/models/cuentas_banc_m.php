<?
/*
 * Modelo: cuentas_banc_m
 * Accion: Modelo que incluye las funciones vinculadas sub-modulo Cuentas Bancarias del modulo Finanzas
 * LCT - Diciembre 2013 
 */
class Cuentas_banc_m extends CI_Model{

    
    //funcion buscar interes bcv
    function buscar_cuentas_banc(){        
        $data = array();
        
        $this->db
                   ->select("bacuenta.*")
                   ->select("banc.nombre as nombre_banco")
                   ->from("datos.bacuenta")
                   ->join("datos.bancos as banc","banc.id=bacuenta.bancoid")
                   ->where(array("bacuenta.bln_borrado"=>'FALSE'))
                   ->order_by('bacuenta.fecha_registro');
           
            $query = $this->db->get();
            if( $query->num_rows()>0 ){
                 
                foreach ($query->result() as $row):
                            
                            $data[] = array(
                                            "num_cuenta"	=> $row->num_cuenta,
                                            "tipo_cuenta"   => $row->tipo_cuenta,
                                            "nombre_banco"      => $row->nombre_banco,
                                            "id_cuentabanc"   => $row->id,
                                
                                            );
                 endforeach;

           }
           
           return $data;
    }
    
    //funcion para armar el combo de las entidades bancarias registradas

    function combo_bancos(){
        
        $this->db
                ->select('*')
                ->from('datos.bancos')
                ->where(array("bancos.bln_borrado"=>'FALSE'));
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
    


    function eliminar_cuentasbancarias($id){

       
            $this->db->trans_start();
            //las condiciones del where deben establecerse como arreglos
                $this->db->where(array('id'=> $id));
                $this->db->delete('datos.bacuenta');
                
                 
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
     function verifica_numero_cuenta($cuenta){
		
		
        $this->db
                //seleccionar todo de la tabla bancos
                   ->select("*")
                   ->from("datos.bacuenta")
//                   ->where(array("nombre"=>$nombre_bancos));
                   ->where(array("num_cuenta"=>$cuenta,"bln_borrado"=>'FALSE'));

            $query = $this->db->get();
            if( $query->num_rows()>0 ){

                $return=TRUE;
           }else{
               $return=FALSE;
           }
           
           return $return;


     }

}
