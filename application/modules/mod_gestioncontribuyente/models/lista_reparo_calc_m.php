<?
/*
 * Modelo: lista_reparo_calc_m
 * Accion: 
 * 1.- Funcion que listar permite los reparos desde finanzas para aplicarles los 
 * calculos de los pagos que deben realizar por cada declaracion.
 * LCT - 2013 
 */
class Lista_reparo_calc_m extends CI_Model{
    
    
    
    function buscar_reparo_calc($condicion,$dlt_duplicado){  
        $data = array();
        $data_limpia = array();
        
        $this->db
                ->select("reparos.id as idreparo,reparos.proceso,reparos.fechaelab,reparos.conusuid, reparos.tdeclaraid, reparos.usuarioid")
                ->select("declara.id as id_decl, declara.calpagodid, declara.reparoid",FALSE)
                ->select("usfonpro.nombre as nomusu,",FALSE)
                ->select("conusu.*",FALSE)
                ->select("tipocont.id as id_tcont, tipocont.nombre as nomb_tcont",FALSE)
                ->select("calpagod.periodo",FALSE)
                ->select("calpago.id as id_calpago, calpago.ano as ano_calpago",FALSE)
                ->from("datos.reparos")
                ->join('datos.declara','declara.reparoid=reparos.id')
                ->join('datos.usfonpro','usfonpro.id=reparos.usuarioid')
                ->join('datos.conusu','conusu.id=reparos.conusuid')
                ->join('datos.tipocont','tipocont.id=reparos.tipocontribuid')
                ->join('datos.calpagod','calpagod.id=declara.calpagodid')
                ->join('datos.calpago','calpago.id=calpagod.calpagoid')
                ->where($condicion);
        
        $query = $this->db->get();
            if( $query->num_rows()>0 ){
                 
                foreach ($query->result() as $row):
                            
                            $data[] = array(
                                            "conusuid"	=> $row->conusuid,
                                            "estatus" => $row->proceso,
                                            "fechaelaboracion"=>$row->fechaelab,
                                            "idreparo"=>$row->idreparo,
                                            "tdeclaraid"=>$row->tdeclaraid,
                                            "id_decl"=>$row->id_decl,
                                            "calpagodid"=>$row->calpagodid,
                                            "reparoid"=>$row->reparoid,
                                            "nomusu"=>$row->nomusu,
                                            "rif"=>$row->rif,
                                            "nombre"=>$row->nombre,
                                            "id_tcont"=>$row->id_tcont,
                                            "nomb_tcont"=>$row->nomb_tcont
                                            
                                            );
                 endforeach;
                 if($dlt_duplicado): 
                        for($i = 0; $i < count($data); $i++)
                      {
                          $idreparo=$data[$i]['idreparo'];;
                          $data_limpia[$idreparo]=$data[$i];                    

                      }
                 else:
                    $data_limpia=$data;
                endif;
                 //recorrido del arreglo data para determinar los registros duplicados y poder eliminarlos
                 
//                 if(($dlt_duplicado) && (count($data)>1)):
//                 //primer for donde se captura el registro que sera comparado con los demás en el siguiente recorrido
//                        for($i=0;$i<count($data);$i++):
//                            $r=$data[$i]['rif'];
//                            $t=$data[$i]['id_tcont'];
//                            $idreparo=$data[$i]['idreparo'];
//                            
//                            if($i==(count($data)-1)):
//                              
//                               $valj=$i; 
//                            
//                             else:
//                                 
//                                $valj=$i+1;
//                             
//                            endif;
//                            /**segundo recorrido donde se eliminara los registros duplicados
//                             * iniciara desde i+1 hasta que j sea menor o igual que el total 
//                             * de posiciones del arreglo data
//                             */
//                            for($j=$valj;$j<count($data);$j++):
//
//                                if($r==$data[$j]['rif'] && $t==$data[$j]['id_tcont']):
//                                   if($idreparo==$data[$j]['idreparo']):
//                                        //unset propiedad para eliminar el registro duplicado
//                                        unset($data[$j]);
//                                   
//                                    endif;
//
//                                endif;
//
//
//                            endfor;
//              /*reestructuracion de los indices de data con array_values
//               * ya que al ser eliminado los duplicados se generan saltos 
//               * de indices incorrectos en el arreglo y con el array_values
//               * se vuelven a enumerar con un orden desde 0 hasta n 
//               */
//                     
//                        $data=array_values($data);             
//                             endfor;
//                         endif;
 
           }
        
            
            return array_values($data_limpia);
    }
    
        //funcion buscar usuarios
    function buscar_decla_reparo($valor){        
        
//        $id_extemp = array();
        
        $this->db
                //seleccionasr todo de la tabla usfonpro
                   ->select("declara.*")
                   ->from("datos.reparos")
                   ->join('datos.declara','declara.reparoid=reparos.id') 
//                   ->where("conusuid","44");
                   ->where(array("reparos.id"=>$valor));
           
            $query = $this->db->get();
            if( $query->num_rows()>0 ){
                $cont=0;
                foreach ($query->result() as $row):
                            
                            $data['periodo'.$cont] = array(
                                            "fecha_inicio" => $row->fechafin,
                                            "fecha_fin" => $row->fechapago,
                                            "total_declara" => $row->montopagar,
                                            "id" => $row->id,
                                           );
                            $cont++;
                 endforeach;

           }
           
           
           return $data;
    }

    
}

