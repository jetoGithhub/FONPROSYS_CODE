<?php

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 * Description of estado_cuenta_m
 *
 * @author jetox
 */
class Estado_cuenta_m extends CI_Model{
    //put your code here
    
    /*
    * 
    * @acces public
    * @param integer
    * @return array
    * 
    */
   function tipo_contribuyente()
   {
       $this->db
                ->select('tcon.id as tipocontid, tcon.nombre as tipo_contribu')
                ->from("datos.conusu_tipocont conut")
               ->join("datos.tipocont as tcon","conut.tipocontid=tcon.id")
                ->where(array("conut.conusuid"=>  $this->session->userdata('id')));
        $query = $this->db->get();
            
        return ($query->num_rows()>0 ? $query->result_array() : array());
   }
   /*
    * function para obtener el reporte de la autoliquidaciones y reparos
    * 
    * @acces public
    * @param array
    * return array
    * 
    */
   function reporte_autoliquidaciones_reparo($where)
   {
       $this->db
               ->select("(tipocont.nombre||'( Art. '||tipocont.numero_articulo||' )') as nom_contribu, calpagod.periodo,calpago.ano,declara.fechaelab,declara.fechaconci,declara.fecha_carga_pago,declara.fechafin,tipegrav.tipe as tipo,declara.fechapago")
//               ->select('(case when declara.fecha_carga_pago<= declara.fechafin then "NO" else "SI" end as extem) ')
//               ->select('(case when declara.fecha_carga_pago<= declara.fechafin then 0 else (declara.fecha_carga_pago-declara.fechafin) end as dias)')
               ->from('datos.declara')
               ->join('datos.tipocont','declara.tipocontribuid=tipocont.id')
               ->join('datos.tipegrav','tipocont.tipegravid=tipegrav.id')
               ->join('datos.calpagod','declara.calpagodid=calpagod.id')
               ->join('datos.calpago','calpagod.calpagoid=calpago.id')
               ->where($where);
               $query = $this->db->get();
            
        return ($query->num_rows()>0 ? $query->result_array() : array());
   }
   /*
    * function para obtrener los datos del estado de cuneta para las multas y los interese
    * 
    * @acces public
    * @param array
    * return array
    * 
    */
   function reporte_multas_interese($where){
       
   $this->db
               ->select("(tipocont.nombre||'( Art. '||tipocont.numero_articulo||' )') as nom_contribu, calpagod.periodo,calpago.ano,declara.fechaelab,declara.fechaconci,multas.fecha_carga_pago,declara.fechafin,tipegrav.tipe as tipo,multas.fechapago,tdeclara.nombre as tipo_multa")
               ->from('pre_aprobacion.multas')
               ->join('datos.declara','declara.id=multas.declaraid')
               ->join('datos.tipocont','declara.tipocontribuid=tipocont.id')
               ->join('datos.tipegrav','tipocont.tipegravid=tipegrav.id')
               ->join('datos.calpagod','declara.calpagodid=calpagod.id')
               ->join('datos.calpago','calpagod.calpagoid=calpago.id')
              ->join('datos.tdeclara','tdeclara.id=multas.tipo_multa')
               ->where($where);
               $query = $this->db->get();
            
        return ($query->num_rows()>0 ? $query->result_array() : array());;
   
   
   }
   function lista_tipo_contribuyente(){
        $this->db
                ->select("tipocont.nombre as ntcon")
                ->select("tipegrav.*")
                ->from("datos.conusu_tipocont")
                ->join("datos.tipocont",'tipocont.id=conusu_tipocont.tipocontid')
                ->join('datos.tipegrav','tipegrav.id=tipocont.tipegravid')
                ->where(array('conusu_tipocont.conusuid'=>  $this->session->userdata('id')))
                ->order_by("peano");
        $query = $this->db->get();
        if( $query->num_rows()>0 ):
            $data = array();
        foreach ($query->result() as $row):
            $data[] = array(
                "id"        => $row->id,
                "nombre"    => $row->ntcon,
                "tipe"      => $row->tipe,
                "peano"     => $row->peano,

                            );
        endforeach;
        return $data;
        else:
            return false;
        endif;
    }
}

?>
