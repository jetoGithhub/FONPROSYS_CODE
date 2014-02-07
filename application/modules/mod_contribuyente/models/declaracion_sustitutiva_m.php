<?php

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 * Description of declaracion_sustitutiva_m
 *
 * @author viewmed
 */
class Declaracion_sustitutiva_m extends CI_Model {
    
    function declaraciones_para_sustituir($tcontribu,$counusid)
    {
        $this->db
                ->select('decl.nudeclara,decl.id,decl.baseimpo,decl.montopagar,decl.tipocontribuid,decl.conusuid,decl.calpagodid,decl.fechapago')
//                ->select('calpd.periodo,calp.tipegravid,calpd.calpagoid,calp.ano')
//                ->select('tgrav.tipe')
                ->from('datos.declara decl')
                ->join('datos.calpagod calpd','decl.calpagodid = calpd.id')
                ->join('datos.calpago calp','calpd.calpagoid = calp.id')
                ->join('datos.tipegrav tgrav','calp.tipegravid = tgrav.id')
                ->where(array( 'decl.tipocontribuid'=>$tcontribu,'decl.conusuid'=>$counusid,'decl.fechapago'=> NULL,'decl.bln_declaro0'=>'false'));
        $query = $this->db->get();
        return ($query->num_rows()>0 ? $query->result_array() : false);
//        'decl.tipocontribuid'=>$tcontribu,'decl.conusuid'=>$counusid,
        
    }
    
}

?>
