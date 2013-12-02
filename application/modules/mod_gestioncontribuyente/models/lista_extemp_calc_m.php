<?
/*
 * Modelo: lista_extemp_calc_m
 * Accion: 
 * 1.- Funcion que listar permite los extemporaneos desde finanzas para aplicarles los 
 * calculos de los pagos que deben realizar por cada declaracion.
 * LCT - 2013 
 */
class Lista_extemp_calc_m extends CI_Model{
    
    

    
    //funcion listar extemporaneos a los que se aplicaran los calculos en finanzas
    function buscar_extemp_calc($condicion,$dlt_duplicado){    
        $data = array();
        $data_limpia=array();
//         $this->db
//                   ->select("declara.proceso as proceso, declara.conusuid as conuid", FALSE)
//                   ->select("conusu.nombre as nom, conusu.rif",FALSE)
//                   ->select("calpagod.id as id_calpagod, calpagod.calpagoid, calpagod.periodo",FALSE)
//                   ->select("calpago.id as id_calpago, calpago.ano as ano_calpago",FALSE)
//                   ->select("tipocont.id as id_tcont, tipocont.nombre as nomb_tcont",FALSE)
//                   ->from("datos.declara")
//                   ->join('datos.conusu','conusu.id=declara.conusuid')
//                   ->join('datos.tipocont','tipocont.id=declara.tipocontribuid')
//                   ->join('datos.calpagod','calpagod.id=declara.calpagodid')
//                   ->join('datos.calpago','calpago.id=calpagod.calpagoid')
//                   ->where($condicion);
//
//            $query = $this->db->get();
//            if( $query->num_rows()>0 ){
//                 
//                foreach ($query->result() as $row):
//                            
//                            $data[] = array(
//                                            "conusuid"	=> $row->conuid,
//                                            "nombre"	=> $row->nom,
//                                            "rif"   => $row->rif,
//                                            "estatus" => $row->proceso,
//                                            "id_tcont" => $row->id_tcont,
//                                            "nomb_tcont" => $row->nomb_tcont,
//                                            "ano_calpago"=> $row->ano_calpago,
//                                            "periodo"=> $row->periodo,
//                                            
//                                            );
//                 endforeach;

        
        $this->db
                   ->select("contrib_calc.id as idconcalc,contrib_calc.proceso,contrib_calc.fecha_registro_fila,contrib_calc.conusuid")
                   ->select("declara.id as id_decl, declara.conusuid as id_contrib, declara.calpagodid, declara.tipocontribuid",FALSE)
                   ->select("conusu.*",FALSE)
                   ->select("calpagod.id as id_calpagod, calpagod.calpagoid, calpagod.periodo",FALSE)
                   ->select("calpago.id as id_calpago, calpago.ano as ano_calpago",FALSE)
                   ->select("tipocont.id as id_tcont, tipocont.nombre as nomb_tcont",FALSE)
                   ->select("usfonpro.nombre as nomusu,",FALSE)
                   ->select("detalles_contrib_calc.id as id_deta_concalc") 
                   ->from("datos.contrib_calc")
                   ->join('datos.detalles_contrib_calc','detalles_contrib_calc.contrib_calcid=contrib_calc.id') 
                   ->join('datos.declara','declara.id=detalles_contrib_calc.declaraid')
                   ->join('datos.usfonpro','usfonpro.id=contrib_calc.usuarioid')
                   ->join('datos.conusu','conusu.id=contrib_calc.conusuid')                                      
                   ->join('datos.tipocont','tipocont.id=contrib_calc.tipocontid')
                   ->join('datos.calpagod','calpagod.id=declara.calpagodid')
                   ->join('datos.calpago','calpago.id=calpagod.calpagoid')
                    ->where($condicion);
//                   ->where(array("declara.proceso"=>'enviado',"declara.bln_reparo"=>'false'));

            $query = $this->db->get();
            if( $query->num_rows()>0 ){
                 
                foreach ($query->result() as $row):
                            
                            $data[] = array(
                                            "conusuid"	=> $row->conusuid,
                                            "nombre"	=> $row->nombre,
                                            "rif"   => $row->rif,
                                            "estatus" => $row->proceso,
                                            "id_tcont" => $row->id_tcont,
                                            "nomb_tcont" => $row->nomb_tcont,
                                            "ano_calpago"=> $row->ano_calpago,
                                            "periodo"=> $row->periodo,
                                            "usuregi"=>$row->nomusu,
                                            "fechaelaboracion"=>$row->fecha_registro_fila,
                                            "idconcalc"=>$row->idconcalc,
                                            "id_deta_concalc"=>$row->id_deta_concalc,
                                            "declaraid"=>$row->id_decl
                                            
                                            );
                 endforeach;
                 
                 for($i = 0; $i < count($data); $i++)
                {
                    $idcontribcalc=$data[$i]['idconcalc'];
                    $data_limpia[$idcontribcalc]=$data[$i];                    

                }
                 //recorrido del arreglo data para determinar los registros duplicados y poder eliminarlos
                 
//                 if(($dlt_duplicado) && (count($data)>1)):
//                 //primer for donde se captura el registro que sera comparado con los demás en el siguiente recorrido
//                        for($i=0;$i<count($data);$i++):
//                            $r=$data[$i]['rif'];
//                            $t=$data[$i]['id_tcont'];
//                            $idconcalc=$data[$i]['idconcalc'];
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
//                                   if($idconcalc==$data[$j]['idconcalc']):
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
//                                $data=array_values($data);             
//                         endfor;
//                 endif;
//            //                 data=array_values($data);
// 
           }
          
           return array_values($data_limpia);
        
        
    }
    

    //funcion buscar usuarios
    function buscar_decla_extemp($valor){        
        
//        $id_extemp = array();
        
        $this->db
                //seleccionasr todo de la tabla usfonpro
                   ->select("declara.*")
                   ->from("datos.detalles_contrib_calc")
                   ->join('datos.declara','declara.id=detalles_contrib_calc.declaraid') 
//                   ->where("conusuid","44");
                   ->where(array("detalles_contrib_calc.contrib_calcid"=>$valor));
           
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
    
    function datos_rise_multas_interes($where){
        
        $this->db
                ->select('*')
                ->from('datos.vista_datos_rise_recaudacion')
                ->where($where)
                ->order_by('contribcalcid');
        $query = $this->db->get();
        return ($query->num_rows()>0 ? $query->result_array() : FALSE);
    }
    function datos_declaraciones_extemporaneas($id)
    {
          $this->db
                //seleccionasr todo de la tabla usfonpro
                   ->select("declara.*")
                   ->from("datos.detalles_contrib_calc")
                   ->join('datos.declara','declara.id=detalles_contrib_calc.declaraid')
                   ->where(array("detalles_contrib_calc.id"=>$id));
         $query = $this->db->get();
        if( $query->num_rows()>0 ):
            $data = array();
        foreach ($query->result() as $row):
            $data[] = array(
                "nudeposito" =>$row->nudeposito,
                "nmontopagar" =>$row->montopagar,
                "calpagodid" =>$row->calpagodid,
                "fechapago"=>$row->fechapago,
                "nudeclara"=>$row->nudeclara
                );
        endforeach;
        return $data;
        else:
            return false;
        endif;
        
    }
    
    function detalles_multa_rise($id)
    {
        $this->db
                //seleccionasr todo de la tabla usfonpro
                   ->select("declara.*")
                   ->select("calpagod.periodo")
                    ->select('calpago.ano anio_calpago')
                   ->from("datos.declara")
                   ->join('datos.calpagod','calpagod.id=declara.calpagodid')
                    ->join('datos.calpago','calpago.id=calpagod.calpagoid')
                   ->where(array("declara.id"=>$id));
         $query = $this->db->get();
        if( $query->num_rows()>0 ):
            $data = array();
        foreach ($query->result() as $row):
            $data[] = array(
                "nudeposito" =>$row->nudeposito,
                "nmontopagar" =>$row->montopagar,
                "calpagodid" =>$row->calpagodid,
                "fechapago"=>$row->fechapago,
                "nudeclara"=>$row->nudeclara,
                "periodo"=>$row->periodo,
                "anio_calpago"=>$row->anio_calpago
                );
        endforeach;
        return $data;
        else:
            return false;
        endif;
        
    }
    


    
}

