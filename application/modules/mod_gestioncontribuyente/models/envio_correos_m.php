<?
/*
 * Modelo: envio_correos_m
 * Accion: Funciones vinculadas al modulo de envio de correos a los contribuyentes activos
 * LCT - 2013 
 */
class Envio_correos_m extends CI_Model{
    

    function listar_contrib_correos_enviados($id){        
        $data = array();
        $data_limpia=array();
        
        $this->db
                //seleccionasr todo de la tabla usfonpro
                   ->select("conusu.*",FALSE)
//                   ->select("*")
                    ->from("datos.conusu")
                    ->join('datos.contribu','contribu.rif=conusu.rif','left')
                    ->join('datos.correos_enviados','correos_enviados.rif=conusu.rif')
//                   ->from("datos.conusu")
                   //~ ->where(array("conusu.inactivo"=>"true","conusu.validado"=>"true"));
                   ->where(array("conusu.inactivo"=>"true","conusu.correo_enviado"=>"true",'correos_enviados.usuarioid'=>$id));
           
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
                for($i = 0; $i < count($data); $i++)
                {
                    $id_usuario=$data[$i]['id_usuario'];
                    $data_limpia[$id_usuario]=$data[$i];                    

                }

           }
           
           return $data_limpia;
        
        
    }
    
	
	//~ funcion que captura los datos del contribuyente
	function datos_contribuyente($rif){        
		 
		$this->db

				   ->select("conusu.*",FALSE)
					->from("datos.conusu")
					->join('datos.contribu','contribu.rif=conusu.rif','left')
					
					->where(array("conusu.rif"=>$rif));

		   $query = $this->db->get();
		   
			if( $query->num_rows()>0 ){
				   $data = $query->row();

				   return array(
						   'resultado'=>true,
						   'rif' => $data->rif,
						   'email' => $data->email
				   );
		   }else{
			   
					return array('resultado'=>false);
			   
		   }
		
		
	}
	
	
	//~ funcion listar correos enviados por contribuyente
	function listar_correos_enviados_contrib($rif){        
        $data = array();

        $this->db
                //seleccionasr todo de la tabla usfonpro
                   ->select("correos_enviados.*",FALSE)
                    ->from("datos.correos_enviados")
                   ->where(array("correos_enviados.rif"=>$rif));
           
            $query = $this->db->get();
            if( $query->num_rows()>0 ){
                
		//   recorrido con los datos necesarios para el listar de correos enviados  
                foreach ($query->result() as $row):
                            
                            $data[] = array(
                                            "id"	=> $row->id,
                                            "email_enviar"	=> $row->email_enviar,
                                            "asunto_enviar"   => $row->asunto_enviar,
                                            "contenido_enviar"=>$row->contenido_enviar,
                                            "fecha_envio"=>$row->fecha_envio,
											"procesado"=>$row->procesado
                                            );
                 endforeach;

           }
           
           return $data;
        
        
    }
    
    //~ funcion que captura los datos del correo seleccionado
	function ver_correo_contrib($id){        
		 
		$this->db

				   ->select("correos_enviados.*",FALSE)
					->from("datos.correos_enviados")
					
					->where(array("correos_enviados.id"=>$id));

		   $query = $this->db->get();
		   
			if( $query->num_rows()>0 ){
				   $data = $query->row();

				   return array(
						   'resultado'=>true,
						   'id'	=> $data->id,
                           'email_enviar'	=> $data->email_enviar,
                           'asunto_enviar'   => $data->asunto_enviar,
                           'contenido_enviar'=>$data->contenido_enviar,
                           'fecha_envio'=>$data->fecha_envio
				   );
		   }else{
			   
					return array('resultado'=>false);
			   
		   }
		
		
	}
    


}
