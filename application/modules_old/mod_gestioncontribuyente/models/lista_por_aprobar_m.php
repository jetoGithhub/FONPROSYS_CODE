<?
/*
 * Modelo: lista_por_aprobar_m
 * Accion: 
 * 1.- Funcion que permite listar aquellos calculos que hayan sido realizados y deben ser aprobados
 * tramitandolos a la gerencia de recaudacion.
 * LCT - 2013 
 */
class Lista_por_aprobar_m extends CI_Model{
    
        //funcion lista calculos por aprobar en la vista lista_por_aprobar_extemp_v
    function lista_calculos_por_aprobar($condiciones){        
        $data = array();
        $this->db
                ->select("contrib_calc.id as id_contrib_calc",FALSE)
                   ->select("declara.id as id_decl, declara.conusuid as id_contrib, declara.calpagodid, declara.tipocontribuid",FALSE)
                   ->select("multas.montopagar as montom,multas.fechaelaboracion as felab,multas.tipo_multa as tipo_multa ",FALSE)
                   ->select("conusu.nombre as nom, conusu.rif",FALSE)
                   ->select("intereses.totalpagar as montoi",FALSE)
                   ->select("tdeclara.nombre as nom_tdecl",FALSE)
                   ->select("calpagod.id as id_calpagod, calpagod.calpagoid, calpagod.periodo",FALSE)
                   ->select("calpago.id as id_calpago, calpago.ano as ano_calpago",FALSE)
                   ->select("tipocont.id as id_tcont, tipocont.nombre as nomb_tcont",FALSE)
                   ->select("tipegrav.tipe as tipo")
                   ->from("datos.contrib_calc")                
                   ->join('datos.conusu','conusu.id=contrib_calc.conusuid')
                   ->join('datos.tipocont','tipocont.id=contrib_calc.tipocontid')
                   ->join('datos.tipegrav','tipegrav.id=tipocont.tipegravid')
                   ->join('datos.detalles_contrib_calc','detalles_contrib_calc.contrib_calcid=contrib_calc.id') 
                   ->join('datos.declara','declara.id=detalles_contrib_calc.declaraid')
                   ->join('pre_aprobacion.multas','multas.declaraid=detalles_contrib_calc.declaraid')
                   ->join('pre_aprobacion.intereses','intereses.multaid=multas.id') 
                   ->join('datos.tdeclara','tdeclara.id=multas.tipo_multa')
                   ->join('datos.calpagod','calpagod.id=declara.calpagodid')
                   ->join('datos.calpago','calpago.id=calpagod.calpagoid')
                 
//                   ->select("*")
//                   ->select("declara.id as id_decl, declara.conusuid as id_contrib, declara.calpagodid, declara.tipocontribuid",FALSE)
//                   ->select("conusu.nombre as nom, conusu.rif",FALSE)
//                   ->select("tdeclara.nombre as nom_tdecl",FALSE)
//                   ->select("calpagod.id as id_calpagod, calpagod.calpagoid, calpagod.periodo",FALSE)
//                   ->select("calpago.id as id_calpago, calpago.ano as ano_calpago",FALSE)
//                   ->select("tipocont.id as id_tcont, tipocont.nombre as nomb_tcont",FALSE)
//                   ->from("pre_aprobacion.multas")
//                   ->join('datos.declara','declara.id=multas.declaraid')
//                   ->join('datos.conusu','conusu.id=declara.conusuid')
//                   ->join('datos.tdeclara','tdeclara.id=multas.tipo_multa')
//                   ->join('datos.calpagod','calpagod.id=declara.calpagodid')
//                   ->join('datos.calpago','calpago.id=calpagod.calpagoid')
//                   ->join('datos.tipocont','tipocont.id=declara.tipocontribuid')
//                   ->where(array("to_char(multas.fechaelaboracion,'dd-mm-yyyy')"=>$fecha_sist));
                   ->where($condiciones);
        
        
            $query = $this->db->get();
            if( $query->num_rows()>0 ){
                 
                foreach ($query->result() as $row):
                            
                            $data[] = array(
//                                            "nresolucion"  => $row->nresolucion,
//                                            "montopagar"   => $row->montopagar,
                                                "id_decl"          => $row->id_decl,
                                                "id_calpagod"      => $row->id_calpagod,
                                                "id_contrib"       => $row->id_contrib,
                                                "tipo_multa"       => $row->tipo_multa,
                                                "rif"              => $row->rif,
                                                "nombre"           => $row->nom,
                                                "nom_tdecl"        => $row->nom_tdecl,
                                                "ano_calpago"      => $row->ano_calpago,
                                                "periodo"          => $row->periodo,
                                                "fechaelaboracion" => date("d-m-Y",strtotime($row->felab)),
                                                "nomb_tcont" => $row->nomb_tcont,
                                                "monto"=>$row->montom,
                                                "monto_interes"=>$row->montoi,
                                                "id_contrib_calc"=>$row->id_decl,
                                                "tipo"=>$row->tipo
                                            );
                 endforeach;

           }
           
           return $data;
        
        
    }
    
     function lista_calculos_por_aprobar_culm($condiciones){        
        $data = array();
        $this->db
                ->select("reparos.id as id_reparos",FALSE)
                   ->select("declara.id as id_decl, declara.conusuid as id_contrib, declara.calpagodid, declara.tipocontribuid",FALSE)
                   ->select("multas.montopagar as montom,multas.fechaelaboracion as felab,multas.tipo_multa as tipo_multa ",FALSE)
                   ->select("conusu.nombre as nom, conusu.rif",FALSE)
                   ->select("intereses.totalpagar as montoi",FALSE)
                   ->select("tdeclara.nombre as nom_tdecl",FALSE)
                   ->select("calpagod.id as id_calpagod, calpagod.calpagoid, calpagod.periodo",FALSE)
                   ->select("calpago.id as id_calpago, calpago.ano as ano_calpago",FALSE)
                   ->select("tipocont.id as id_tcont, tipocont.nombre as nomb_tcont",FALSE)
                   ->select("tipegrav.tipe as tipo")
                   ->from("datos.reparos")                
                   ->join('datos.conusu','conusu.id=reparos.conusuid')
                   ->join('datos.tipocont','tipocont.id=reparos.tipocontribuid')
                   ->join('datos.tipegrav','tipegrav.id=tipocont.tipegravid')
//                   ->join('datos.detalles_contrib_calc','detalles_contrib_calc.contrib_calcid=contrib_calc.id') 
                   ->join('datos.declara','declara.reparoid=reparos.id')
                   ->join('pre_aprobacion.multas','multas.declaraid=declara.id')
                   ->join('pre_aprobacion.intereses','intereses.multaid=multas.id') 
                   ->join('datos.tdeclara','tdeclara.id=multas.tipo_multa')
                   ->join('datos.calpagod','calpagod.id=declara.calpagodid')                
                   ->join('datos.calpago','calpago.id=calpagod.calpagoid')
                   ->where($condiciones);
        
        
            $query = $this->db->get();
            if( $query->num_rows()>0 ){
                 
                foreach ($query->result() as $row):
                            
                            $data[] = array(
//                                            "nresolucion"  => $row->nresolucion,
//                                            "montopagar"   => $row->montopagar,
                                                "id_decl"          => $row->id_decl,
                                                "id_calpagod"      => $row->id_calpagod,
                                                "id_contrib"       => $row->id_contrib,
                                                "tipo_multa"       => $row->tipo_multa,
                                                "rif"              => $row->rif,
                                                "nombre"           => $row->nom,
                                                "nom_tdecl"        => $row->nom_tdecl,
                                                "ano_calpago"      => $row->ano_calpago,
                                                "periodo"          => $row->periodo,
                                                "fechaelaboracion" => date("d-m-Y",strtotime($row->felab)),
                                                "nomb_tcont" => $row->nomb_tcont,
                                                "monto"=>$row->montom,
                                                "monto_interes"=>$row->montoi,
                                                "id_contrib_calc"=>$row->id_decl,
                                                "tipo"=>$row->tipo
                                            );
                 endforeach;

           }
           
           return $data;
        
        
    }
    function devolver_recaudacion($array,$tc,$session)
    {
       $this->db->trans_begin();// iniciamos la transsaccion
        if($tc==1)
        {
            $this->db->where_in('declaraid',$array);
            $this->db->update('datos.detalles_contrib_calc',array('proceso'=>'aprobado'));          
            
            
        }elseif (($tc==2)||($tc==3))
            {
                $this->db->where_in('id',$array);
                $this->db->update('datos.declara',array('proceso'=>'aprobado'));
            }
            
        //actualizamos los datos de la sesion que aprobo los calculos
        $this->db->where_in('declaraid',$array);
        $this->db->update('pre_aprobacion.multas',$session);   
//        if($this->db->affected_rows()>0){// verificamos si hizo el update
//            $respuesta=array('resultado'=>true,'mensaje'=>'Calculos aprobados correctamente');
//        }
        /*
         * logica para las transsaciones
         */
        if ($this->db->trans_status() === FALSE){

            $this->db->trans_rollback();

            $respuesta=array('resultado'=>false,'mensaje'=>'Error al Aprobar los Calculos');


        }else{

           $this->db->trans_commit();

            $respuesta=array('resultado'=>true,'mensaje'=>'Calculos aprobados correctamente');

        }
        return $respuesta;
    }
    
    
    
        
    //funcion para el generar en el excel listar de los calculos de extemporaneos

       function lista_calculos_por_aprobar_excel($condiciones){        
        $data = array();
        $this->db
                ->select("*")
                   ->select("declara.id as id_decl, declara.conusuid as id_contrib, declara.calpagodid, declara.tipocontribuid, 
                             declara.montopagar as monto_pagar_d, declara.fechapago as fechapagod, declara.fechafin as ffin_decla",FALSE)
                   ->select("multas.montopagar,multas.fechaelaboracion as felab,multas.tipo_multa as tipo_multa ",FALSE)
                   ->select("conusu.nombre as nom, conusu.rif",FALSE)
                   ->select("tdeclara.nombre as nom_tdecl",FALSE)
                   ->select("calpagod.id as id_calpagod, calpagod.calpagoid, calpagod.periodo, calpagod.fechalim",FALSE)
                   ->select("calpago.id as id_calpago, calpago.ano as ano_calpago, calpago.tipegravid as tipo_period_grav, calpago.ano as ano_calpago",FALSE)
                   ->select("tipocont.id as id_tcont, tipocont.nombre as nomb_tcont",FALSE)
                   ->select("tipegrav.id as id_tipegrav, tipegrav.nombre as nomb_tgrav, tipegrav.tipe, tipegrav.peano",FALSE)
                   ->select("intereses.totalpagar as montoi",FALSE)
                   ->select("detalle_interes.dias, detalle_interes.tasa as tasabcv, detalle_interes.mes as mpagoi, 
                             detalle_interes.anio as apagoi, detalle_interes.intereses as total_interes_mes",FALSE)
                   ->from("datos.contrib_calc")                
                   ->join('datos.conusu','conusu.id=contrib_calc.conusuid')
                   ->join('datos.tipocont','tipocont.id=contrib_calc.tipocontid')
                   ->join('datos.detalles_contrib_calc','detalles_contrib_calc.contrib_calcid=contrib_calc.id') 
                   ->join('datos.declara','declara.id=detalles_contrib_calc.declaraid')
                   ->join('pre_aprobacion.multas','multas.declaraid=detalles_contrib_calc.declaraid') 
                   ->join('datos.tdeclara','tdeclara.id=multas.tipo_multa')
                   ->join('datos.calpagod','calpagod.id=declara.calpagodid')
                   ->join('datos.calpago','calpago.id=calpagod.calpagoid')
                   ->join('datos.tipegrav','tipegrav.id=calpago.tipegravid')
                   ->join('pre_aprobacion.intereses','intereses.multaid=multas.id')
                   ->join('datos.detalle_interes','detalle_interes.intereses_id=intereses.id')

                   ->where($condiciones);
        
        
            $query = $this->db->get();
            if( $query->num_rows()>0 ){
                 
                foreach ($query->result() as $row):
                            
                            $data[] = array(
                                                "id_decl"          => $row->id_decl,
                                                "id_calpagod"      => $row->id_calpagod,
                                                "id_contrib"       => $row->id_contrib,
                                                "tipo_multa"       => $row->tipo_multa,
                                                "rif"              => $row->rif,
                                                "nombre"           => $row->nom,
                                                "nom_tdecl"        => $row->nom_tdecl,
                                                "ano_calpago"      => $row->ano_calpago,
                                                "periodo"          => $row->periodo,
                                                "fechalim"         => date("d-m-Y",strtotime($row->fechalim)), 
                                                "fechaelaboracion" => date("d-m-Y",strtotime($row->felab)),
                                                "nomb_tcont" => $row->nomb_tcont,
                                                "montopagar"=>$row->montopagar,
                                                "dias"=>$row->dias,
                                                "tasa_interes"=>$row->tasabcv,
                                                "monto_interes"=>$row->montoi,
                                                "monto_declara"=>$row->monto_pagar_d,
                                                "id_contric_calc"=>$row->id,
                                                'mes_anio_pago_i'=>date("M",strtotime($row->mpagoi)).'/'.$row->apagoi,
                                                'anio_periodo_pago_i'=>date("Y",strtotime($row->ffin_decla)),
                                                "fecha_pago_dec"=>date("d-m-Y",strtotime($row->fechapagod)),
                                                "mes_anio_pago_dec"=>date("M/Y",strtotime($row->fechapagod)),
                                                "mes_pago_dec"=>date("F",strtotime($row->fechapagod)),
                                                "anio_pago_dec"=>date("Y",strtotime($row->fechapagod)),
                                                "total_interes_mes"=>$row->total_interes_mes,
                                                "tipo_period_grav"=> $row->tipo_period_grav,
                                                "id_tipegrav" => $row->id_tipegrav,
                                                "peano" => $row->peano,
                                                "ano_calpago" => $row->ano_calpago
                                            );
                 endforeach;

           }
           
           return $data;
        
        
    }
    function lista_calculos_por_aprobar_clum_excel($condiciones){        
        $data = array();
        $this->db
                ->select("*")
                   ->select("declara.id as id_decl, declara.conusuid as id_contrib, declara.calpagodid, declara.tipocontribuid, 
                             declara.montopagar as monto_pagar_d, declara.fechapago as fechapagod, declara.fechafin as ffin_decla",FALSE)
                   ->select("multas.montopagar,multas.fechaelaboracion as felab,multas.tipo_multa as tipo_multa ",FALSE)
                   ->select("conusu.nombre as nom, conusu.rif",FALSE)
                   ->select("tdeclara.nombre as nom_tdecl",FALSE)
                   ->select("calpagod.id as id_calpagod, calpagod.calpagoid, calpagod.periodo, calpagod.fechalim",FALSE)
                   ->select("calpago.id as id_calpago, calpago.ano as ano_calpago, calpago.tipegravid as tipo_period_grav, calpago.ano as ano_calpago",FALSE)
                   ->select("tipocont.id as id_tcont, tipocont.nombre as nomb_tcont",FALSE)
                   ->select("tipegrav.id as id_tipegrav, tipegrav.nombre as nomb_tgrav, tipegrav.tipe, tipegrav.peano",FALSE)
                   ->select("intereses.totalpagar as montoi",FALSE)
                   ->select("detalle_interes.dias, detalle_interes.tasa as tasabcv, detalle_interes.mes as mpagoi, 
                             detalle_interes.anio as apagoi, detalle_interes.intereses as total_interes_mes",FALSE)
                   ->from("datos.reparos")                
                   ->join('datos.conusu','conusu.id=reparos.conusuid')
                   ->join('datos.tipocont','tipocont.id=reparos.tipocontribuid')
//                   ->join('datos.detalles_contrib_calc','detalles_contrib_calc.contrib_calcid=contrib_calc.id') 
                   ->join('datos.declara','declara.reparoid=reparos.id')
                   ->join('pre_aprobacion.multas','multas.declaraid=declara.id') 
                   ->join('datos.tdeclara','tdeclara.id=multas.tipo_multa')
                   ->join('datos.calpagod','calpagod.id=declara.calpagodid')
                   ->join('datos.calpago','calpago.id=calpagod.calpagoid')
                   ->join('datos.tipegrav','tipegrav.id=calpago.tipegravid')
                   ->join('pre_aprobacion.intereses','intereses.multaid=multas.id')
                   ->join('datos.detalle_interes','detalle_interes.intereses_id=intereses.id')

                   ->where($condiciones);
        
        
            $query = $this->db->get();
            if( $query->num_rows()>0 ){
                 
                foreach ($query->result() as $row):
                            
                            $data[] = array(
                                                "id_decl"          => $row->id_decl,
                                                "id_calpagod"      => $row->id_calpagod,
                                                "id_contrib"       => $row->id_contrib,
                                                "tipo_multa"       => $row->tipo_multa,
                                                "rif"              => $row->rif,
                                                "nombre"           => $row->nom,
                                                "nom_tdecl"        => $row->nom_tdecl,
                                                "ano_calpago"      => $row->ano_calpago,
                                                "periodo"          => $row->periodo,
                                                "fechalim"         => date("d-m-Y",strtotime($row->fechalim)), 
                                                "fechaelaboracion" => date("d-m-Y",strtotime($row->felab)),
                                                "nomb_tcont" => $row->nomb_tcont,
                                                "montopagar"=>$row->montopagar,
                                                "dias"=>$row->dias,
                                                "tasa_interes"=>$row->tasabcv,
                                                "monto_interes"=>$row->montoi,
                                                "monto_declara"=>$row->monto_pagar_d,
                                                "id_contric_calc"=>$row->id,
                                                'mes_anio_pago_i'=>date("M",strtotime($row->mpagoi)).'/'.$row->apagoi,
                                                'anio_periodo_pago_i'=>date("Y",strtotime($row->ffin_decla)),
                                                "fecha_pago_dec"=>date("d-m-Y",strtotime($row->fechapagod)),
                                                "mes_anio_pago_dec"=>date("M/Y",strtotime($row->fechapagod)),
                                                "mes_pago_dec"=>date("F",strtotime($row->fechapagod)),
                                                "anio_pago_dec"=>date("Y",strtotime($row->fechapagod)),
                                                "total_interes_mes"=>$row->total_interes_mes,
                                                "tipo_period_grav"=> $row->tipo_period_grav,
                                                "id_tipegrav" => $row->id_tipegrav,
                                                "peano" => $row->peano,
                                                "ano_calpago" => $row->ano_calpago
                                            );
                 endforeach;

           }
           
           return $data;
        
        
    }
    
    

    
}

