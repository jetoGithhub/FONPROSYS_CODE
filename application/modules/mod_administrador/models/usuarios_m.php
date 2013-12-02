<?
/*
 * Modelo: usuarios_m
 * Accion: Funcion que permite capturar todos los usuarios registrados en la tabla 'usfonpro'
 * LCT - 2013 
 */
class Usuarios_m extends CI_Model{
    
    //funcion para armar el combo del select de la pregunta secreta
    function preguntaSecreta(){
        
        $this->db
                ->select('*')
                ->from('datos.pregsecr');
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
    
    
        //funcion para armar el combo del select de los grupos
    function comboGrupos(){
        
        $this->db
                ->select('*')
                ->from('seg.tbl_rol')
                ->where(array("tbl_rol.bln_borrado"=>'FALSE','tbl_rol.id_rol <>'=>1));
        $query = $this->db->get();
        if ($query->num_rows()>0):
            $data = array();
            foreach ($query->result() as $row):
                    $data[] = array(
                        'id_rol'     => $row->id_rol,
                        'str_rol' => $row->str_rol
                    );
            endforeach;

            return $data;
    else:
            return false;
    endif;        
                
                
    }
    
    //funcion agregar usuarios, aplicando trans debido a que el registro se realizara en dos tablas
    function insertar_usuario_admin($datos = array(),$rol){
        if(is_array($datos)):
            $this->db->trans_start();
                $this->db->insert('datos.usfonpro',$datos);
                $id= $this->db->insert_id();
                $datospermiso= array(                    
                    'id_usuario'  => $id,
                    'id_rol' => $rol
                    );
                $this->db->insert('seg.tbl_rol_usuario',$datospermiso);
                 
            $this->db->trans_complete();
        
        
            if ($this->db->trans_status() === FALSE):
                $this->db->trans_rollback();
                return false;
            else:
                $this->db->trans_commit();
                return true;
            endif;
            
        else:
            return false;
        endif;
            
     }
    
    //funcion buscar usuarios
    function buscar_usuarios(){        
        $data = array();
        
        $this->db
                //seleccionasr todo de la tabla usfonpro
                   ->select("usfonpro.*")
                    ->select("dep.nombre as gerencia")
                    ->select("carg.nombre as cargo")
                   ->from("datos.usfonpro")
                   ->join("datos.departam as dep","dep.id=usfonpro.departamid")
                    ->join("datos.cargos as carg","carg.id=usfonpro.cargoid")
                   ->where(array('cod_estructura <>'=>'DESA-00','bln_borrado'=>'false'));
           
            $query = $this->db->get();
            if( $query->num_rows()>0 ){
                
//   recorrido con los datos necesarios para el listar de usuario   
                foreach ($query->result() as $row):
                            
                            $data[] = array(
                                            "nombre"	=> $row->nombre,
                                            "cedula"   => $row->cedula,
                                            "gerencia" =>$row->gerencia,
                                            "cargo"=>$row->cargo,
                                            "email"      => $row->email,
                                            "telefono"   => $row->telefofc,
                                            "registrador"      => $row->usuarioid,
                                            "ip"      => $row->ip,
                                            "id_usuario"=>$row->id,
                                            "estatus"=>$row->inactivo
                                
                                            );
                 endforeach;

           }
           
           return $data;
        
        
    }
    
    //mostrar datos de un usuario seleccionado para el editar y el ver detalle
        function datos_usuario($id){        
         
        $this->db
                //seleccion de las variables de las tablas necesarias con los join necesarios
                   ->select("usfonpro.*",FALSE)
                   ->select("pregsecr.nombre as nompreg",FALSE)
                   ->select("tbl_rol_usuario.*",FALSE)
                   ->select("tbl_rol.*",FALSE)
                   ->from("datos.usfonpro")
                   ->join('datos.pregsecr','pregsecr.id = usfonpro.pregsecrid','LEFT')
                   ->join('seg.tbl_rol_usuario', 'tbl_rol_usuario.id_usuario=usfonpro.id')
                   ->join('seg.tbl_rol', 'tbl_rol.id_rol=tbl_rol_usuario.id_rol')
                   ->where(array("usfonpro.id"=>$id));
                  
           $query = $this->db->get();
           
            if( $query->num_rows()>0 ){
                   $data = $query->row();
                    //retornar los valores del arreglo
                   return array(
                           'resultado'=>true,
                           "login"=>$data->login,
                           "nombre"=>$data->nombre,
                           "cedula"=>$data->cedula,
                           "email"=>$data->email,
                           "telefofc"=>$data->telefofc,
                           "nompreg"=>$data->nompreg,
                           "respuesta"=>$data->respuesta,
                           "inactivo"=>$data->inactivo,
                           "str_rol"=>$data->str_rol,
                           "id_rol"=>$data->id_rol
                           //"nombre"=>$data->nompreg,
//                           'usuarioid'=>$data->usuarioid
                   );
           }else{
               
                    return array('resultado'=>false);
               
           }
   }
   
   /*function para eliminar usuarios y el rol asignado
   **aplicando trans se declaran los delete en una sola funcion
   **evitando de esta forma la posibilidad de errores al eliminar 
   **en una sola tabla cuando el llamado es en un solo proceso*/

   function eliminar_usuario($id){

       
            $this->db->trans_start();
            //las condiciones del where deben establecerse como arreglos
                $this->db->where(array('id'=> $id));
                $this->db->delete('datos.usfonpro');
                
                //cada una de las condiciones y llamadas de tablas de forma independiente dentro del trans_start
                
                $this->db->where(array('id_usuario'=> $id));
                $this->db->delete('seg.tbl_rol_usuario');
                 
            $this->db->trans_complete();
        
        
            if ($this->db->trans_status() === FALSE):
                $this->db->trans_rollback();
                return false;
            else:
                $this->db->trans_commit();
                return true;
            endif;

            
     }
     
     function departamentos()
     {
          $data = array();
        
        $this->db
                //seleccionasr todo de la tabla usfonpro
                   ->select("*")
                   ->from("datos.departam")
                   ->where(array("cod_estructura <> "=>"DESA-00"));
                   //->where(array("inactivo"=>"false"));
           
            $query = $this->db->get();
            if( $query->num_rows()>0 ){
                
//   recorrido con los datos necesarios para el listar de usuario   
                foreach ($query->result() as $row):
                            
                            $data[] = array(
                                            "id_dep"=>$row->id,
                                            "nombre"	=> $row->nombre,
                                            "cod_estructura"   => $row->cod_estructura,                                           
                                
                                            );
                 endforeach;

           }
           
           return $data;
     }
     function cargos()
     {
          $data = array();
        
        $this->db
                //seleccionasr todo de la tabla usfonpro
                   ->select("*")
                   ->from("datos.cargos")
                   ->where(array("codigo_cargo <> "=>"C-000"));
           
            $query = $this->db->get();
            if( $query->num_rows()>0 ){
                
//   recorrido con los datos necesarios para el listar de usuario   
                foreach ($query->result() as $row):
                            
                            $data[] = array(
                                            "id_car"=>$row->id,
                                            "nombre"	=> $row->nombre,
                                            "cod_cargo"   => $row->codigo_cargo,                                           
                                
                                            );
                 endforeach;

           }
           
           return $data;
     }
     function verifica_gerentes($gerencia,$cargo){

        $this->db
                //seleccionasr todo de la tabla usfonpro
                   ->select("*")
                   ->from("datos.usfonpro")
                   ->where(array("departamid"=>$gerencia,"cargoid"=>$cargo));

            $query = $this->db->get();
            if( $query->num_rows()>0 ){

                $return=TRUE;
           }else{
               $return=FALSE;
           }
           
           return $return;


     }

}