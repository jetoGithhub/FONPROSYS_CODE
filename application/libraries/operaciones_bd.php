<? if ( ! defined('BASEPATH')) exit('No se permite acceso directo al script');
/*************************************************************************************************
 *Fecha:14-01-2013,                                                                              *
 *Empresa:LCT tecnologias,                                                                       *
 *Creador: Ing. Jefferson Lara,                                                                  *                               *
 *Descripcion: Librerias para el Manejo de Base de Datos Generica,                               *
 *Version:1.0                                                                                    *           *
 *************************************************************************************************/
class Operaciones_bd {
 protected $usoci;

   function __construct(){
       
      $this->usoci =& get_instance();
      
   }

    function insertar_BD($opc,$data=array(),$tabla,$devolver){

/*                              COMO FUNCIONA EL METODO
* como se deben pasar los datos del controlador al llamar este metodo del modelo
*
*      caso uno para insert a una tabla en especifico,
*      caso dos para insert a dos o mas tablas en la base de datos
*
* 1) la opcion 1 o 2 con esta opcion evalua el caso el modelo
* 2) un arreglo simple de datos donde la clave de las posciones en los
*    arreglos debe ser igual a los nombres de los campos en tablas
*    ejemplo caso1 del switc= $nombre=array(nombre_campo_tabla=>dato_formulario,nombre_campo_tabla=>dato_formulario);
*
*    ejemplo caso2 del switc= $nombre=array(
*                                             nombre_tabla_bd=>array(nombre_campo_tabla=>dato_formulario
*
*                                              nombre_tabla_bd=> array(nombre_campo_tabla=>dato_formulario
*                                           )
* 3) nombre de la tabla a insertar el nombre se pasa solo cuando sea el primer caso de lo contrario pasar 0
* 4)para retornar el id o los id se pasa 1 si no cero
**************************************************************************************************************************/

 /*************************************************************************************************************************
 *                                 INICIO DE LA FUNCIONALIDAD DEL METODO                                                  *             *
 **************************************************************************************************************************/
        
        $this->usoci->load->database();// cargamos la libreria de base de datos
        $tbls=array();// inizializamos el arreglo a usar en alguno de los casos

        switch ($opc){

            case '1':

                $this->usoci->db->insert($tabla,$data);// insert a la base de datos

                    if($this->usoci->db->affected_rows()>0){// verificamos si insert

                        $id= $this->usoci->db->insert_id();// obtenemos el id del insert

                        $respuesta=array('resultado'=>true,'id'=>$id,'mensaje'=>'Ingreso Exitoso');

                    }else{

                       $respuesta=array('resultado'=>false,'mensaje'=>'Ingreso Fallido');

                    }

                return $respuesta;

            break;//fin case1


            case '2':

                $arrayids=array();// arreglo para almacenar los datos que se retornan al controlador

                foreach ($data as $nombre=>$valor):

                     $tbls[].=$nombre; // armamos un arreglo con los nombres de las
                                      // tablas en la base de datos

                endforeach;

                $c=count($data);// obtenemos el tamaño del arreglo
                                // para determinar cuantas tablas  llevan los insert

                $this->usoci->db->trans_begin();// iniciamos la transsaccion

                for($i=0;$i<$c;$i++){// recorremos el arreglo que contiene los datos de las tablas
                                     // y valores a insertar en las mismas

                    $t=$tbls[$i];// obtenemos los nombres de las tablas que contienen las claves del arreglo
                    // en $data[$t] pasamos los valores a la base de datos

                    $respuesta=$this->usoci->db->insert($t,$data[$t]);// ejecutamos los insert

                        if($devolver==1){

                            $arrayids[$t.'id']= $this->usoci->db->insert_id();// agregamos al arreglo de respuesta
                                                                       //los id que genero en mcada insert
                        }



                }
                /*
                 * logica para las transsaciones
                 */
                if ($this->usoci->db->trans_status() === FALSE){

                    $this->usoci->db->trans_rollback();

                    $arrayids['resultado']=false;
                    $arrayids['mensaje']='Ingreso Fallido';


                }else{

                    $this->usoci->db->trans_commit();
                    $arrayids['resultado']=true;
                    $arrayids['mensaje']='Ingreso Exitoso';

                }
                /*
                 * fin de la logica de las transsaciones
                 */

                return $arrayids;

            break;//fin case 2




        }// fin del swicht


    }// fin de la funcion insertar_BD

    function actualizar_BD($opc,$datos=array()){

 /*                                 COMO FUNCIONA EL METODO
 * asi se debe armar los arreglos para ser enviado del controlador al modelo en el caso que el update sea a una sola tabla
 * dw= a las condiciones que van en el where
 * dac= a los datos que se vana aactualizar en las tabla las claves que contienen los arreglos deben ser iguales
 * a los nombres de los campos en la base de datos
 * tabla=nombre de la tabla a actualizar
 * ejemplo:
 * $array = array('name !=' => $name, 'id <' => $id, 'date >' => $date);<-- VUSTA Y PENDIENTE
 * los caracteres especiales que estan despues de las claves pero dentro de los parentesis ('name !='),
 * son para indicar el tipo de condicion que va a evaluar el where para cada uno de los datos si no se coloca
 * va por defecto el =

                $datos=array(

                        'dw'=>array('cedula'=>$this->input->post('cedula'),
                                    'usuario'=> $this->input->post('usuario')),
                        'dac'=>array('cedula'=>$this->input->post('cedula'),
                                    'txtnombre'=>$this->input->post('nombres'),
                                    'txtapellido'=>$this->input->post('apellidos')),
                        'tabla'=>'usuarios'


                );

 * asi se debe armar los arreglos para ser enviado del controlador al modelo en el caso que el update sea varias tablas
 *las claves que contengan los arreglos dw y dac deben ser igual a los nombres de las tablas a los que se quieren hacer update
 * dw= a las condiciones que van en el where
 * dac= a los datos que se vana aactualizar en las tabla las claves que contienen los arreglos deben ser iguales
 * a los nombres de los campos en la base de datos
 * tabla=nombre de la tabla a actualizar
 * ejemplo:
 * $array = array('name !=' => $name, 'id <' => $id, 'date >' => $date);<-- VISTA Y PENDIENTE
 * los caracteres especiales que estan despues de las claves pero dentro de los parentesis ('name !='),
 * son para indicar el tipo de condicion que va a evaluar el where para cada uno de los datos si no se coloca
 * va por defecto el =


//              $datos=array(
//
//               'usuarios'=>array('dw'=>array('cedula'=>$this->input->post('cedula'),
//                                            'usuario'=> $this->input->post('usuario')
//                                             ),
//                                'dac'=>array('cedula'=>$this->input->post('cedula'),
//                                            'txtnombre'=>$this->input->post('nombres'),
//                                            'txtapellido'=>$this->input->post('apellidos')
//                                             ),
//                                ),
//
//               'prueba'=>array('dw'=>array('txtnombre2'=>$this->input->post('nombres')),
//
//                                'dac'=>array('txtnombre2'=>$this->input->post('nombres'),
//                                             'txtapellido2'=>$this->input->post('apellidos')
//                                             ),
//
//                               )
//        );
*/
/**************************************************************************************************
 *                                 INICIO DE LA FUNCIONALIDAD DEL METODO                                                               *
 **************************************************************************************************/
      
        $tbls=array();// inizializamos el arreglo a usar en alguno de los casos
        $this->usoci->load->database();

        switch ($opc){

            case '1':

                $this->usoci->db->where($datos['dw']);
                $this->usoci->db->update($datos['tabla'],$datos['dac']);
                 if($this->usoci->db->affected_rows()>0){// verificamos si hizo el update


                        $respuesta=array('resultado'=>true,'mensaje'=>'Datos Actualizados Correctamente');

                    }else{

                       $respuesta=array('resultado'=>false,'mensaje'=>'Error al Actualizar los Datos');

                    }

                    return $respuesta;

                break;// fin case 1

            case '2':

                foreach ($datos as $nombre=>$valor):

                     $tbls[].=$nombre; // armamos un arreglo con los nombres de las
                                      // tablas en la base de datos

                endforeach;

                $c=count($datos);// obtenemos el tamaño del arreglo
                                // para determinar cuantas tablas  llevan los insert

               $this->usoci->db->trans_begin();// iniciamos la transsaccion

                for($i=0;$i<$c;$i++){// recorremos el arreglo que contiene los datos de las tablas
                                     // y valores a insertar en las mismas

                    $t=$tbls[$i];// obtenemos los nombres de las tablas que contienen las claves del arreglo
                    // en $data[$t] pasamos los valores a la base de datos
                    $this->usoci->db->where($datos[$t]['dw']);
                   $this->usoci->db->update($t,$datos[$t]['dac']);



                }
                 /*
                 * logica para las transsaciones
                 */
                if ($this->usoci->db->trans_status() === FALSE){

                    $this->usoci->db->trans_rollback();

                    $respuesta=array('resultado'=>false,'mensaje'=>'Error al Actualizar los Datos');


                }else{

                   $this->usoci->db->trans_commit();

                    $respuesta=array('resultado'=>true,'mensaje'=>'Datos Actualizados Correctamente');

                }
                 /*
                 * fin logica para las transsaciones
                 */

                return $respuesta;


            break;//fin case2


        }// fin de switch


    }// fin funcion actualizar


    
    
//    function buscar(){
//
//
//
//    }
//
//    function insertar ($parametros){
//
//        $nombre=$parametros['nombres'];
//        $apellido=$parametros['apellidos'];
//        $cedula=$parametros['cedula'];
//        $usuario=$parametros['usuario'];
//        $contrasena=$parametros['contrasena'];
//
//        $usoci=& get_instance();
//
//        $usoci->load->model('modelo_usuario');
//
//        if ($resultado=$usoci->modelo_usuario->inserta_usuario($nombre,  $apellido,  $cedula,  $usuario,  $contrasena)){
//
//            return $resultado;
//
//        }else{
//            $resultado='no se pudo';
//
//            return $resultado;
//
//        }
//
//
//
//
//    }
    
    function seleciona_BD($datos=array()){
        $this->usoci->load->database();
        
        $this->usoci->db
                ->select('*')
                ->from($datos['tabla'])
                ->where($datos['where']);

        $query = $this->usoci->db->get();
        
        if ($query->num_rows()>0):
//            $data = array();
            foreach ($query->result() as $row):
                
                $c=count($datos['respuesta']);
            
                    for($i=0;$i<$c;$i++){
                           $v=$datos['respuesta'][$i];
                           
                            $data['variable'.$i]= $row->$v;                 
                              
                    }
            endforeach;

            return $data;
    else:
            return $data=array();
    endif;          
        
        
    }
    
    
    
}

?>
