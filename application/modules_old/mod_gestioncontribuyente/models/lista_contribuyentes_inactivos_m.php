<?
/*
 * Modelo: usuarios_m
 * Accion: Funcion que permite capturar todos los usuarios registrados en la tabla 'usfonpro'
 * LCT - 2013 
 */
class Lista_contribuyentes_inactivos_m extends CI_Model{
    
    

    
    //funcion buscar usuarios
    function buscar_usuarios_inactivos(){        
        $data = array();
        
//         $this->db
//                   ->select("contribu.*",FALSE)
//                    ->select("estados.nombre as nomest",FALSE)
//                    ->select("ciudades.nombre as nomciu",FALSE)
//                    ->select("conusu.inactivo as inac",FALSE)
//                   ->from("datos.contribu")
//                   ->join('datos.estados','estados.id = contribu.estadoid')                 
//                   ->join('datos.ciudades', 'ciudades.estadoid=estados.id' )
//                   ->join('datos.conusu', 'conusu.id=contribu.usuarioid' )
//                   ->where(array("contribu.rif"=>$rif));
        
        $this->db
                //seleccionasr todo de la tabla usfonpro
                   ->select("conusu.*",FALSE)
//                   ->select("*")
                    ->from("datos.conusu")
                    ->join('datos.contribu','contribu.rif=conusu.rif')
//                   ->from("datos.conusu")
                   ->where(array("conusu.inactivo"=>"true","conusu.validado"=>"true","conusu.correo_enviado"=>"false"));
           
            $query = $this->db->get();
            if( $query->num_rows()>0 ){
                
//   recorrido con los datos necesarios para el listar de usuario   
                foreach ($query->result() as $row):
                            
                            $data[] = array(
                                            "nombre"	=> $row->nombre,
                                            "rif"   => $row->rif,
                                            "id_usuario"=>$row->id
                                
                                            );
                 endforeach;

           }
           
           return $data;
        
        
    }
    


}
