<?
class Gestion_contrasena_m extends CI_Model{
    
    function actualiza_contrasena($valor, $clavenueva){        
         
        $this->db
                   ->select("password")
                    
                   ->from("datos.conusu")
                   
                   ->where($valor);
                  
           $query = $this->db->get();
           
            if( $query->num_rows()>0 ){
                
                $datos=array(

                        'dw'=>array('id'=>$valor['id'],
                                    ),
                        'dac'=>array('password'=>do_hash($clavenueva)
                                    ),
                        'tabla'=>'datos.conusu'


                );
                
                    $this->load->library('operaciones_bd');
                    $result=$this->operaciones_bd->actualizar_BD(1,$datos); 
                
//                $this->db->where('password', $valor['id']);
//                $this->db->update('datos.conusu',$data=array('password'=>$clavenueva));          
//              
//            
                    if( $result['resultado']){
                    
                           return true;
                       
                    }else{
                        
                            return false;   
                    }
                       
                      
                       
           }else{
                       
                return false; 
            }
            

                  
        
        
    }
    
    
    function actualiza_pregunta($valor, $valor2){        
         
        $this->db
                   ->select("respuesta")
                    
                   ->from("datos.conusu")
                   
                   ->where($valor);
                  
           $query = $this->db->get();
           
            if( $query->num_rows()>0 ){
                
                $datos=array(

                        'dw'=>array('id'=>$valor['id'],
                                    ),
                        'dac'=>array('pregsecrid'=>$valor2['pregunta'],'respuesta'=>$valor2['respactual']
                                    ),
                        'tabla'=>'datos.conusu'


                );
                
                    $this->load->library('operaciones_bd');
                    $result=$this->operaciones_bd->actualizar_BD(1,$datos); 
                
//                $this->db->where('password', $valor['id']);
//                $this->db->update('datos.conusu',$data=array('password'=>$clavenueva));          
//              
//            
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
