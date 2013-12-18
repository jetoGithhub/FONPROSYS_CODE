<?php

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 * Description of getion_pagos_m
 *
 * @author viewmed
 */
class Gestion_pagos_m extends CI_Model{
    
    function busca_pagos_pendientes($where,$tipo_pago)
    {
        $data=array();
        if(($tipo_pago=='1') || ($tipo_pago=='2')){
        $this->db
                ->select("declara.id,declara.nudeclara,declara.fechaelab,declara.baseimpo,declara.montopagar,")
                ->select("calpd.periodo")
                ->select("calp.ano")
                ->select("tgrav.tipe as periodo_gravable")
                ->select("tipocont.nombre as contribuyente_text");
                if($tipo_pago=='2'): $this->db->select("actas_reparo.numero as nreparo"); endif;
                $this->db->from("datos.declara")
                ->join("datos.calpagod as calpd","calpd.id=declara.calpagodid")
                ->join("datos.calpago as calp","calp.id=calpd.calpagoid")
                ->join('datos.tipocont','tipocont.id=declara.tipocontribuid')
                ->join('datos.tipegrav as tgrav','tgrav.id=tipocont.tipegravid');
                if($tipo_pago=='2'):
                 $this->db->join('datos.reparos','reparos.id=declara.reparoid');
                 $this->db->join('datos.actas_reparo','actas_reparo.id=reparos.actaid');
                endif;
                $this->db->where($where);
                
                if($tipo_pago=='2'):
                    $this->db->order_by("fechaelab", "desc"); 
                    $this->db->group_by("nreparo,declara.id,nudeclara,declara.fechaelab,baseimpo,declara.montopagar,periodo,ano,periodo_gravable,contribuyente_text"); 
                endif;
                $query = $this->db->get();
                if( $query->num_rows()>0 ){

    //      
                    foreach ($query->result() as $row):
                            if($tipo_pago=='2'):
                                $data[] = array(
                                                "id_declra"	=> $row->id,
                                                "numero"      => $row->nudeclara,
                                                "nreparo"=>$row->nreparo,
                                                "fechaelab" =>$row->fechaelab,
                                                "base"      =>$row->baseimpo,
                                                "total"     =>$row->montopagar,
                                                "anio"      =>$row->ano,
                                                "periodo"   =>$row->periodo,
                                                "tipo_pago" =>$tipo_pago,
                                                "periodo_gravable"=>$row->periodo_gravable,
                                                "contribuyente_text"=>$row->contribuyente_text
                                                

                                                );
                            else:
                                 $data[] = array(
                                                "id_declra"	=> $row->id,
                                                "numero"      => $row->nudeclara,
                                                "fechaelab" =>$row->fechaelab,
                                                "base"      =>$row->baseimpo,
                                                "total"     =>$row->montopagar,
                                                "anio"      =>$row->ano,
                                                "periodo"   =>$row->periodo,
                                                "tipo_pago" =>$tipo_pago,
                                                "periodo_gravable"=>$row->periodo_gravable,
                                                "contribuyente_text"=>$row->contribuyente_text
                                                

                                                );
                            endif;
                     endforeach;

               }
               
            }elseif ($tipo_pago=='3'){
                $this->db
                ->select("multas.id, multas.fechaelaboracion as fechaelab,multas.montopagar,multas.nresolucion as nudeclara")        
                ->select("declara.id as iddeclara,declara.montopagar as baseimpo")
                ->select("calpd.periodo")
                ->select("calp.ano")
                ->select("tgrav.tipe as periodo_gravable")
                ->select("tipocont.nombre as contribuyente_text")
                ->select("intereses.totalpagar as total_interes")
                ->from("pre_aprobacion.multas")
                ->join("pre_aprobacion.intereses","intereses.multaid=multas.id")        
                ->join("datos.declara","declara.id=multas.declaraid")                        
                ->join("datos.calpagod as calpd","calpd.id=declara.calpagodid")
                ->join("datos.calpago as calp","calp.id=calpd.calpagoid")
                ->join('datos.tipocont','tipocont.id=declara.tipocontribuid')
                ->join('datos.tipegrav as tgrav','tgrav.id=tipocont.tipegravid')        
                ->where($where);
                 $query = $this->db->get();
                if( $query->num_rows()>0 ){

    //      
                    foreach ($query->result() as $row):

                                $data[] = array(
                                                "id_declra"	=> $row->id,
                                                "numero"      => $row->nudeclara,
                                                "fechaelab" =>$row->fechaelab,
                                                "base"      =>$row->baseimpo,
                                                "total"     =>$row->montopagar,
                                                "total_interes" =>$row->total_interes,
                                                "anio"      =>$row->ano,
                                                "periodo"   =>$row->periodo,
                                                "tipo_pago" =>$tipo_pago,
                                                "periodo_gravable"=>$row->periodo_gravable,
                                                "contribuyente_text"=>$row->contribuyente_text

                                                );
                     endforeach;

               }
                
//                    $query = $this->db->get();
//                    return ($query->num_rows()>0 ? $query->result_array() : FALSE);

            }elseif(($tipo_pago=='4') || ($tipo_pago=='5')){
                $this->db
                    ->select('*')
                    ->from('datos.vista_datos_multa_interes')
                    ->where($where)
                    ->order_by('idreparo');
                    $query = $this->db->get();
                    if( $query->num_rows()>0 ){

        //      
                        foreach ($query->result() as $row):

                                    $data[] = array(
                                                    "id_declra"	=> $row->resol_multa,
                                                    "idreparo" =>$row->idreparo,
                                                    "numero"      => $row->resol_multa,
                                                    "fechaelab" =>$row->fechaelaboracion,
                                                    "total_interes" =>$row->interes_pagar,
                                                    "total"     =>$row->multa_pagar,
                                                    "anio"      =>$row->periodo_afiscalizar,
                                                    "idmulta"   =>$row->idmulta,
                                                    "tipo_pago" =>$tipo_pago,
//                                                    "periodo_gravable"=>$row->periodo_gravable,
                                                    "contribuyente_text"=>$row->nombre

                                                    );
                         endforeach;

                   } 
                
            }                
        
           
           return $data;
    }
    
    function carga_pago_sumario_culminatoria($datos_multa,$where,$datos_interes,$ids)
    {
        $this->db->trans_begin();
        
        $this->db->where($where);
        $this->db->update('pre_aprobacion.multas',$datos_multa);
        
        $this->db->where_in('multaid',$ids);
        $this->db->update('pre_aprobacion.intereses',$datos_interes);
        
         /*
         * logica para las transsaciones
         */
        if ($this->db->trans_status() === FALSE){

            $this->db->trans_rollback();

            $respuesta=array('resultado'=>false,'mensaje'=>'Error al Actualizar los Datos');


        }else{

           $this->db->trans_commit();

            $respuesta=array('resultado'=>true,'mensaje'=>'Datos Actualizados Correctamente');

        }
         /*
         * fin logica para las transsaciones
         */

        return $respuesta;
    }
    
    function bancos()
    {
         $this->db
                ->from("datos.bancos")                      
                ->where(array('bln_borrado'=>'false'));
        
        $query = $this->db->get();
        if( $query->num_rows()>0 ){

//      
            foreach ($query->result() as $row):

                        $data[] = array(
                                        "id_banco"	=> $row->id,
                                        "banco" =>$row->nombre
                                        );
             endforeach;
             
             return $data;
        }
    }
     function numero_cuentas($id)
    {
         $this->db
                ->from("datos.bacuenta")                      
                ->where(array('bancoid'=>$id,'bln_borrado'=>'false'));
        
        $query = $this->db->get();
        if( $query->num_rows()>0 ){

//      
            foreach ($query->result() as $row):

                        $data[] = array(
                                        "id_cuenta"	=> $row->id,
                                        "cuenta" =>$row->num_cuenta
                                        );
             endforeach;
             
             return $data;
        }
    }
}

?>
