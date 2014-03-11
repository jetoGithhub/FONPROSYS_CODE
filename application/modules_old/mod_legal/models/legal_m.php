<?
/*
 * Modelo: usuarios_m
 * Accion: Funcion que permite capturar todos los usuarios registrados en la tabla 'usfonpro'
 * LCT - 2013 
 */
class Legal_m extends CI_Model{
    
    //funcion para armar el combo del select de la pregunta secreta
    function buscar_reparos_culminados(){
        
        $this->db
                ->select("*")
                ->from("seg.vista_listado_reparos_culminados")
//                ->where(array("proceso"=>''))
                ->order_by("semaforo");
        $query = $this->db->get();
        if( $query->num_rows()>0 ):
            $data = array();
        foreach ($query->result() as $row):
            $data[] = array(
                "razonsocial"	=> $row->razon_social,
                "email"       => $row->email,
                "estado"     => $row->nomest,
                "fiscal"	=> $row->fiscal,
                "fechaelab"	=> $row->fechaelab,
                "fechanoti"	=> $row->fecha_notificacion,
                "semaforo"      => $row->semaforo,
                "estatus"       =>$row->estado,
                "reparoid"      =>$row->reparoid
                            );
        endforeach;
        return $data;
        else:
            return false;
        endif;
                
                
    }
    
    public function insertar_descargos($data,$id)
    {
        $respuesta=array();
        $this->db->trans_begin();// iniciamos la transsaccion

                $this->db->where(array('id'=>$id));
                $this->db->update('datos.reparos',array('proceso'=>'en descargos'));

                $this->db->insert('datos.descargos',$data);  
                   
                /*
                 * inicio de logica de transacciones
                 */
                if ($this->db->trans_status() === FALSE){

                    $this->db->trans_rollback();

                    $respuesta['resultado']=false;
                    $respuesta['mensaje']='Ingreso Fallido';


                }else{

                    $this->db->trans_commit();
                    $respuesta['resultado']=true;
                    $respuesta['mensaje']='Ingreso Exitoso';

                }
                /*
                 * fin de la logica de las transsaciones
                 */

                return $respuesta;
        
    }
    
    function listar_reparos_condescargos(){
        
        $this->db
                ->select('rep.id as idreparo,rep.fechaelab as elaboracion_reparo,rep.fecha_notificacion as notifi_reparo',FALSE)
                ->select('des.compareciente,des.fecha as fecha_escrito',FALSE)
                ->select('conu.nombre as nombre,conu.rif as rif',FALSE)
                ->select('tcon.nombre as tcontribuyente',FALSE)
                ->from('datos.reparos as rep')
                ->join('datos.descargos as des','des.reparoid=rep.id')
                ->join('datos.conusu as conu','conu.id=rep.conusuid')
                ->join('datos.tipocont as tcon','tcon.id=rep.tipocontribuid')
                ->where(array('rep.proceso'=>'en descargos','des.estatus'=>'abierto'));
        $query = $this->db->get();
        if( $query->num_rows()>0 ):
            $data = array();
        foreach ($query->result() as $row):
            $data[] = array(
                "reparoid"      =>$row->idreparo,
                "razonsocial"	=> $row->nombre,
                "rif"           =>$row->rif,
                "tcontribu"     => $row->tcontribuyente,
                "elab_reparo"   => $row->elaboracion_reparo,
                "noti_reparo"	=> $row->notifi_reparo,
                "compareciente"	=> $row->compareciente,
                "fecha_escrito"	=> $row->fecha_escrito,
                );
        endforeach;
        return $data;
        else:
            return false;
        endif;
        
    }
    
    function datos_multas_interes($where){
        
        $this->db
                ->select('*')
                ->from('datos.vista_datos_multa_interes')
                ->where($where)
                ->order_by('idreparo');
        $query = $this->db->get();
        return ($query->num_rows()>0 ? $query->result_array() : FALSE);
    }
    
    function carga_notificacion_resolucion_multas($idreparo,$multasids,$fecha_noti){
        
         $this->db->trans_begin();// iniciamos la transsaccion

                $this->db->where(array('reparoid'=>$idreparo));
                $this->db->update('datos.declara',array('proceso'=>'notificado'));

                $this->db->where_in('id',explode(',',$multasids));
                $this->db->update('pre_aprobacion.multas',array('fechanotificacion'=>$fecha_noti)); 
                
                $this->db->where_in('multaid',explode(',',$multasids));
                $this->db->update('pre_aprobacion.intereses',array('fnotificacion'=>$fecha_noti));
                   
                /*
                 * inicio de logica de transacciones
                 */
                if ($this->db->trans_status() === FALSE){

                    $this->db->trans_rollback();

                    $respuesta['resultado']=false;
                    $respuesta['mensaje']='Ingreso Fallido';


                }else{

                    $this->db->trans_commit();
                    $respuesta['resultado']=true;
                    $respuesta['mensaje']='Ingreso Exitoso';

                }
                /*
                 * fin de la logica de las transsaciones
                 */

                return $respuesta;
    }
    
    function perido_gravable_contribuyente($tipocont)
    {
        $this->db
                ->select('tgrav.tipe as tipo_periodo')
                ->from('datos.tipocont as tcon')
                ->join('datos.tipegrav as tgrav','tgrav.id=tcon.tipegravid')
                ->where(array('tcon.id'=>$tipocont));
         $query = $this->db->get();
        if( $query->num_rows()>0 ):
            $data = array();
        foreach ($query->result() as $row):
            $data = array(
                "tipo_periodo" =>$row->tipo_periodo
                );
        endforeach;
        return $data;
        else:
            return false;
        endif;
        
    }
    function datos_declaraciones_reparo($reparoid)
    {
         $this->db
                ->select('declara.nudeposito,declara.montopagar,declara.calpagodid,declara.fechapago')
                ->from('datos.declara')
                ->where(array('reparoid'=>$reparoid));
         $query = $this->db->get();
        if( $query->num_rows()>0 ):
            $data = array();
        foreach ($query->result() as $row):
            $data[] = array(
                "nudeposito" =>$row->nudeposito,
                "nmontopagar" =>$row->montopagar,
                "calpagodid" =>$row->calpagodid,
                "fechapago"=>$row->fechapago
                );
        endforeach;
        return $data;
        else:
            return false;
        endif;
        
    }
    
    function periodo_gravable_interes($declarcion){
        $data=array();
        $this->db
                ->select('cd.periodo as periodo,c.ano as anio')
                ->from('datos.declara as d')
                ->join('datos.calpagod as cd','d.calpagodid=cd.id')
                ->join('datos.calpago as c','cd.calpagoid=c.id')
                ->where(array('d.id'=>$declarcion));
         $query = $this->db->get();
        if( $query->num_rows()>0 ):
            $data = array();
        foreach ($query->result() as $row):
            $data = array(
                "periodo" =>$row->periodo,
                "anio"=>$row->anio
                );
        endforeach;
        return $data;
        else:
            return false;
        endif;
    }
    
    function detalles_interes_resolucion($intereseid)
    {
        $data=array();
        $this->db
                ->select('detalle_interes.*')
//                ->select('(select tasa from datos.interes_bcv where mes=detalle_interes.mes) as porcentaje_tasa')
                ->from('datos.detalle_interes')
//                ->join('datos.interes_bcv ibcv','detalle_interes.anio=ibcv.anio')
                ->where(array('intereses_id'=>$intereseid))
                ->order_by('anio,mes');
         $query = $this->db->get();
        return ($query->num_rows()>0 ? $query->result_array() : FALSE);
        
    }
    
    
}