<?

class Listado_cnac_m extends CI_Model{
    
    /*Funcion para devolver los intereses correspondientes al bcv por mes
     */
    function empresas_cnac()
    {
        $this->db
                ->select("datos_cnac.*")
                ->from("pre_aprobacion.datos_cnac");
        
        $query = $this->db->get();
         if( $query->num_rows()>0 ){
                
                foreach ($query->result() as $row):

                              $data[]= array("id"=> $row->id,
                                                     "razonsocia"=> $row->razonsocia,
                                                     "rif"=> $row->rif,
                                                     "dencomerci"=>$row->dencomerci,
                                                     "domfiscal"=>$row->domfiscal,
                                                     "estado"=>$row->estadoid,
                                                     "ciudad"=>$row->ciudadid
                                                     
                                                     );
                    
                endforeach;
                
                return $data;
            }
        
    }
     function contribuyentes_activos()
    {
        $this->db
                ->select("conusu.rif")
                ->from("datos.conusu")
                ->where(array('inactivo'=>'false'));
        
        $query = $this->db->get();
         if( $query->num_rows()>0 ){
                
                foreach ($query->result() as $row):

                              $data[]= array("rif"=> $row->rif);
                    
                endforeach;
                
                return $data;
            }
        
    }
    
}