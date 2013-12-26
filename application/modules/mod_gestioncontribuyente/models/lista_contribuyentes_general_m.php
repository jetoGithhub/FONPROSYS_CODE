<?php
    class Lista_contribuyentes_general_m extends CI_Model{
        
        function __construct() {
            parent::__construct();
        }
        
        function verifica_conusu ($id){
            $this->db
                    ->select('id,fecha_registro,nombre,rif,email')
                    ->from('datos.conusu')
                    ->where(array('id'=>$id,'inactivo'=>'false'));
            $query = $this->db->get();
            return ($query->num_rows()>0 ? $query->result_array() : false);
            
        }
        function listar_contribuyentes ($rif,$tipocontid){


            if(!empty($rif) && empty($tipocontid)):
                $this->db
                        ->select('conusu.id',true)
                        ->select('conusu_tipocont.tipocontid',true)
                        ->select('tipocont.nombre as nombre_tipocont',true)
                        ->from('datos.conusu inner')
                        ->join('datos.conusu_tipocont','conusu.id = conusu_tipocont.conusuid inner')
                        ->join('datos.tipocont','conusu_tipocont.tipocontid = tipocont.id')
                        ->where(array('inactivo'=>'false'))
                        ->where(array('conusu.rif'=>$rif))
                        ->order_by('conusu.id,conusu_tipocont.tipocontid');
            elseif(empty($rif) && !empty($tipocontid)):
                $this->db
                        ->select('conusu.id',true)
                        ->select('conusu_tipocont.tipocontid',true)
                        ->select('tipocont.nombre as nombre_tipocont',true)
                        ->from('datos.conusu inner')
                        ->join('datos.conusu_tipocont','conusu.id = conusu_tipocont.conusuid inner')
                        ->join('datos.tipocont','conusu_tipocont.tipocontid = tipocont.id')
                        ->where(array('inactivo'=>'false'))
                        ->where(array('tipocont.id'=>$tipocontid))
                        ->order_by('conusu.id,conusu_tipocont.tipocontid');
            elseif(!empty($rif) && !empty($tipocontid)):
                $this->db
                        ->select('conusu.id',true)
                        ->select('conusu_tipocont.tipocontid',true)
                        ->select('tipocont.nombre as nombre_tipocont',true)
                        ->from('datos.conusu inner')
                        ->join('datos.conusu_tipocont','conusu.id = conusu_tipocont.conusuid inner')
                        ->join('datos.tipocont','conusu_tipocont.tipocontid = tipocont.id')
                        ->where(array('inactivo'=>'false'))
                        ->where(array('conusu.rif'=>$rif,'tipocont.id'=>$tipocontid))
                        ->order_by('conusu.id,conusu_tipocont.tipocontid');
            else:
                $this->db
                        ->select('conusu.id',true)
                        ->select('conusu_tipocont.tipocontid',true)
                        ->select('tipocont.nombre as nombre_tipocont',true)
                        ->from('datos.conusu inner')
                        ->join('datos.conusu_tipocont','conusu.id = conusu_tipocont.conusuid inner')
                        ->join('datos.tipocont','conusu_tipocont.tipocontid = tipocont.id')
                        ->where(array('inactivo'=>'false'))
                        ->order_by('conusu.id');                
            endif;            
            $query = $this->db->get();
            return ($query->num_rows()>0 ? $query->result_array() : false);
            
        }        
        function busca_tipocont_conusu ($conusuid,$tipocontribuyente=null){
            if (!empty($conusuid)):
                if ($tipocontribuyente==null || empty($tipocontribuyente)):
                    $this->db
                            ->select("conusu_tipocont.tipocontid as tcontid",true)
                            ->select('tipocont.nombre',true)
                            ->from("datos.conusu")
                            ->join('datos.conusu_tipocont','conusu_tipocont.conusuid = conusu.id left')
                            ->join('datos.tipocont','conusu_tipocont.tipocontid = tipocont.id')
                            ->where(array('conusu.id'=>$conusuid));
                elseif($tipocontribuyente!=null && !empty($tipocontribuyente)):
                    $this->db
                            ->select("conusu_tipocont.tipocontid as tcontid",true)
                            ->select('tipocont.nombre',true)
                            ->from("datos.conusu")
                            ->join('datos.conusu_tipocont','conusu_tipocont.conusuid = conusu.id left')
                            ->join('datos.tipocont','conusu_tipocont.tipocontid = tipocont.id')
                            ->where(array('conusu.id'=>$conusuid, 'conusu_tipocont.tipocontid'=>$tipocontribuyente));                    
                endif;

                    $query = $this->db->get();
                    if( $query->num_rows()>0 ):
                        $data = array();
                        foreach ($query->result() as $row):
                            $data[] = array(
                                "tcontid" => $row->tcontid,
                                "nombre_tipocont" => $row->nombre

                                            );
                        endforeach;
                        return $data;
                    else:
                        return false;
                    endif;
            endif;
        }
        
        function busca_periodo_gravable($id_tipocont,$anio){
            $this->db
                    ->select('calpagod.*',FALSE)
                    ->select('calpago.ano',FALSE)
                    ->select('tipegrav.nombre',FALSE)
                    ->select('tipocont.id as tipocontid',true)
                    ->select('tipegrav.nombre, tipegrav.tipe as tipo',FALSE)
                    ->from('datos.tipocont')
                    ->join('datos.tipegrav','tipegrav.id = tipocont.tipegravid')
                    ->join('datos.calpago','calpago.tipegravid = tipegrav.id')
                    ->join('datos.calpagod','calpagod.calpagoid = calpago.id')
                    ->where(array('tipocont.id'=>$id_tipocont,'calpago.ano >= '=>$anio))
                    ->order_by('calpago.ano, calpagod.periodo','asc');
            $query = $this->db->get();
            return ($query->num_rows()>0 ? $query->result_array() : false);

        }
        
        function busca_declaraciones($tipo,$idconusu){
            $this->db
                    ->select('declara.*',FALSE)
                    ->select('calpago.ano',FALSE)
                    ->select('calpagod.periodo',FALSE)
                    ->from('datos.declara')
                    ->join('datos.tdeclara','declara.tdeclaraid = tdeclara.id left')
                    ->join('datos.calpagod','declara.calpagodid = calpagod.id left')
                    ->join('datos.calpago','calpagod.calpagoid= calpago.id')
                    ->where(array('tdeclara.tipo'=>$tipo,'declara.conusuid'=>$idconusu));
            $query = $this->db->get();
            return ($query->num_rows()>0 ? $query->result_array() : false);
        }
        function busca_declarciones_enviadas_finanzas($idconusu,$declaracion){
            $this->db
                    ->select('detalles_contrib_calc.declaraid',FALSE)
                    ->select('contrib_calc.tipocontid',FALSE)
                    ->from('datos.contrib_calc')
                    ->join('datos.detalles_contrib_calc','detalles_contrib_calc.contrib_calcid = contrib_calc.id ')
                    ->where(array('contrib_calc.conusuid'=>$idconusu,'detalles_contrib_calc.declaraid'=>$declaracion));

            $query = $this->db->get();
            return($query->num_rows()>0 ? true : false);
//             if( $query->num_rows()>0 ):
//                $data = array();
//            foreach ($query->result() as $row):
//                
//                $data[]=array( $row->declaraid,$row->tipocontid);
//                   
//            endforeach;
//            return $data;
//            else:
//                return false;
//            endif;
            
        }
        function devuelve_detalle_periodo($id_tipocont){
            $this->db
                    ->select('tipegrav.peano')
                    ->from('datos.tipocont')
                    ->join('datos.tipegrav','tipegrav.id = tipocont.tipegravid')
                    ->where(array('tipocont.id'=>$id_tipocont));
            $query = $this->db->get();
            return($query->num_rows()>0 ? $query->result_array() : false);
        }
        function lista_tipo_contribuyente(){
            $this->db
                    ->select("*")
                    ->from("datos.tipocont")                
                    ->order_by("nombre");
            $query = $this->db->get();
            if( $query->num_rows()>0 ):
                $data = array();
            foreach ($query->result() as $row):
                $data[] = array(
                    "id"        => $row->id,
                    "nombre"    => $row->nombre
                    );
            endforeach;
            return $data;
            else:
                return false;
            endif;
        }
        function lista_anio_cal($id){
            $this->db
                    ->select("*")
                    ->from("datos.calpago")
                    ->where(array('tipegravid'=>$id))
                    ->order_by("nombre");
            $query = $this->db->get();
            if( $query->num_rows()>0 ):
                $data = array();
            foreach ($query->result() as $row):
                $data[] = array(
                    "id"        => $row->id,
                    "nombre"    => $row->nombre,
                    "tipegravid"      => $row->tipegravid,
                    "ano"     => $row->ano,

                                );
            endforeach;
            return $data;
            else:
                return false;
            endif;
        }
        function lista_periodo_cal($id){
            $this->db
                    ->select('calpagod.*',FALSE)
                    ->select('calpago.ano',FALSE)
                    ->select('tipegrav.nombre',FALSE)                    
                    ->from('datos.tipocont')
                    ->join('datos.tipegrav','tipegrav.id = tipocont.tipegravid')
                    ->join('datos.calpago','calpago.tipegravid = tipegrav.id')
                    ->join('datos.calpagod','calpagod.calpagoid = calpago.id')
                    ->where(array('calpago.id = '=>$id))
                    ->order_by('calpago.ano, calpagod.periodo','asc');
            $query = $this->db->get();
            return ($query->num_rows()>0 ? $query->result_array() : false);
        }
        function listar_fiscales (){

                $this->db
                        ->select('usfon.id',FALSE)
                        ->select('usfon.nombre',FALSE)
                        ->select('usfon.email',FALSE)
                        ->select('usfon.telefofc',FALSE)
                        ->from('datos.usfonpro usfon ')
                        ->join('datos.departam as dep','dep.id=usfon.departamid')
                        ->join('datos.cargos as cargo','cargo.id=usfon.cargoid')
                        ->where(array('dep.cod_estructura'=>'G-FIS-01','usfon.bln_borrado'=>'FALSE'));

            $query = $this->db->get();
            return ($query->num_rows()>0 ? $query->result_array() : false);
            
        }
        function inserta_asignaciones($id_fiscal,$idUsuario,$ip,$prioridad,$fechaFiscalizacion,$asignaciones=array(),$periodo_afiscalizar=array()){
            if(is_array($asignaciones) && is_array($periodo_afiscalizar)):
                $this->db->trans_start();
                    foreach ($asignaciones as $clave=>$valor):
                        $extrae = explode(':',$valor);
                        $separa=explode(':',$periodo_afiscalizar[$clave]);
                        $anio=$separa[0];
//                      $calpagoid=$separa[1];
                        $id_contribuyente=$extrae[0];
                        $tipo_contribuyente=$extrae[1];
                        $datosInserta = array(
                            'usfonproid'     => $id_fiscal,
                            'conusuid'  => $id_contribuyente,
                            'prioridad' => ($prioridad==0? 'false':'true'),
                            'estatus'   =>1,
                            'usuarioid'   =>$idUsuario,
                            'ip'   =>$ip,
                            'tipocontid'   =>$tipo_contribuyente,
                            'fecha_fiscalizacion'     => ($prioridad==1?$fechaFiscalizacion:'now()'),
                            'periodo_afiscalizar'=>$anio);
                        $this->db->insert('datos.asignacion_fiscales',$datosInserta);
                    endforeach;
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
        function revisa_fiscalizaciones(){
            $this->db
                    ->select('*')
                    ->from('datos.asignacion_fiscales')                 
                    ->where(array('estatus'=>1));
            $query = $this->db->get();
            return ($query->num_rows()>0 ? $query->result_array() : false);            
        }
        function envia_a_finanza($tabla_envia=array(),$tabla_declara=array()){
            
            $filas_quita_vista = array();
            
            $this->db->trans_begin();
                if (is_array($tabla_envia)):
                    foreach ($tabla_envia as $clave=>$datos_envia):
                        $this->db->insert('datos.contrib_calc',$datos_envia);
                        $ids_contri_calc[$clave]=  $this->db->insert_id();                        
                        $filas_quita_vista[] = $datos_envia['conusuid'].$datos_envia['tipocontid'];
                    endforeach;

                endif;
                if(is_array($tabla_declara)):
                    foreach ($ids_contri_calc as $clave2=>$id_contrib_calc):
                        foreach ($tabla_declara[$clave2] as $id_declara):
                        
                            $this->db->insert('datos.detalles_contrib_calc',array('declaraid'=>$id_declara,'contrib_calcid'=>$id_contrib_calc));
                          
                        endforeach;

                    endforeach;
                 endif;
                 
         if ($this->db->trans_status() === FALSE):
                $this->db->trans_rollback();
                return false;
            else:
                $this->db->trans_commit();
                return $filas_quita_vista;
            endif;
            unset($filas_quita_vista);
        }
        
        function verifica_periodo_omiso_enfiscalizacion($conusuid,$tipocontribuid,$anio,$nro)
        {
            if($nro==0):
                $where=array('conusuid'=>$conusuid,'tipocontid'=>$tipocontribuid,'periodo_afiscalizar'=>$anio,'estatus'=>1);
            else:
                $where=array('conusuid'=>$conusuid,'tipocontid'=>$tipocontribuid,'periodo_afiscalizar'=>$anio,'estatus'=>1,'nro_autorizacion'=>$nro);
            endif;
            $this->db
                    ->select('*')
                    ->from('datos.asignacion_fiscales')                 
                    ->where($where);
            $query = $this->db->get();
            return ($query->num_rows()>0 ? TRUE : FALSE);
        }        
    }
?>