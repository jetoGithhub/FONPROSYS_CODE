<?
/*
 * Modelo: gestion_usuario_m
 * Accion: modelo que contiene las funciones correspondientes al modulo gestion de usuarios
 * LCT - 2013 
 */
class Gestion_usuario_m extends CI_Model{
    
    //funcion para capturar los datos del usuario segun el id capturado
    function ver_datos_usuarios($id)
    { 
        
        $this->db
                   ->select("*")
                   ->from("datos.usfonpro")
                   ->where(array("usfonpro.id"=>$id));
                  
           $query = $this->db->get();
    
            if( $query->num_rows()>0 ){
                
//      
                foreach ($query->result() as $row):
                            
                            $data= array("id"=> $row->id,
                                         "login" => $row->login,
                                         "nombre" => $row->nombre,
                                         "cedula" => $row->cedula,
                                         "email"  => $row->email,
                                         "telefono" => $row->telefofc,
                                         "pregsecrid" => $row->pregsecrid);
                 endforeach;

           }
           
           return $data;
    }
    
    
    //funcion para la actualizacion de contraseña de los usuarios
    function actualiza_contrasenia($valor, $clavenueva)
    {        
        //se hace la busqueda del usuario para verificar que exista y modificar solo la contraseña
        $this->db
                   ->select("password")
                    
                   ->from("datos.usfonpro")
                   
                   ->where($valor);
                  
           $query = $this->db->get();
           
            if( $query->num_rows()>0 ){
                
          //aplicar libreria generica para la actualizacion del campo contraseña
                $datos=array(

                        'dw'=>array('id'=>$valor['id'],
                                    ),
                        'dac'=>array('password'=>do_hash($clavenueva)
                                    ),
                        'tabla'=>'datos.usfonpro'


                );
                
                    $this->load->library('operaciones_bd');
                    $result=$this->operaciones_bd->actualizar_BD(1,$datos); 
                

                    if( $result['resultado']){
                    
                           return true;
                       
                    }else{
                        
                            return false;   
                    }
                       
                      
                       
           }else{
                       
                return false; 
            }
    }
    
    
    //funciones que aplica el formulario de cambio de pregunta secreta por parte del usuario

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
    
    
    
    //funcion para la actualizacion de la prregunta secreta en la tabla usfonpro
    function actualiza_pregunta($valor, $valor2){        
         
        $this->db
                   ->select("respuesta")
                    
                   ->from("datos.usfonpro")
                   
                   ->where($valor);
                  
           $query = $this->db->get();
           
            if( $query->num_rows()>0 ){
                
                $datos=array(

                        'dw'=>array('id'=>$valor['id'],
                                    ),
                        'dac'=>array('pregsecrid'=>$valor2['pregunta'],'respuesta'=>$valor2['respactual']
                                    ),
                        'tabla'=>'datos.usfonpro'


                );
                
                    $this->load->library('operaciones_bd');
                    $result=$this->operaciones_bd->actualizar_BD(1,$datos); 

                    if( $result['resultado']){
                    
                           return true;
                       
                    }else{
                        
                            return false;   
                    }
                       
                      
                       
           }else{
                       
                return false; 
            }
            

                  
        
        
    }

    
}