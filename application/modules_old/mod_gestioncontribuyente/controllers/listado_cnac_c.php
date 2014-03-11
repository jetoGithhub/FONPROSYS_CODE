<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Listado_cnac_c extends CI_controller {

	
	public function index()
	{
            $this->load->model('listado_cnac_m');
            $data_cnac=  $this->listado_cnac_m->empresas_cnac();
            $data_fonpro=$this->listado_cnac_m->contribuyentes_activos();
            
//            print_r($data_fonpro);
//            echo '<br><br>';
//            print_r($data_cnac);echo '<br><br>';
//            die;
            
            
            for($i=0;$i<count($data_fonpro);$i++):
                $rif=$data_fonpro[$i]['rif'] ;
            
                for($j=0;$j<count($data_cnac);$j++):

                    if($data_cnac[$j]['rif']==$rif):
                        
                        unset($data_cnac[$j]);
                       
                    endif;
                    
                
                endfor;

             $data_cnac=array_values($data_cnac); 
             endfor;
//             print_r($data_cnac);die;
             $data['datos']=$data_cnac;
            $this->load->view('listado_cnac_v',$data);
           
            
        }
        
}