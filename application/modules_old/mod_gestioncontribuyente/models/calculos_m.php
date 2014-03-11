<?
/*
 * Modelo: calculos_m
 * Accion: Funcion que permite capturar todos los intereses registrados en la tabla 'interes_bcv'
 * LCT - 2013 
 */
class Calculos_m extends CI_Model{
    
    /*Funcion para devolver los intereses correspondientes al bcv por mes
     */
    function devuelve_tasa($anio,$mes)
    {
        /*Seleccionar de la base de datos los intereses del bcv, 
         * mostrando el que coincida con el mes que se pasa del arreglo fechas
         */    
        $this->db
                   //selecciona tasa de la tabla interes_bcv
                   ->select("interes_bcv.tasa as tasa")
                   ->from("datos.interes_bcv")
                   //condicion que indica que el año y mes de la tabla intereses_bcv debe ser igual a los que se estan pasando
                   ->where(array("interes_bcv.anio"=>$anio,"interes_bcv.mes"=>$mes));
                  
           $query = $this->db->get();
           
           if( $query->num_rows()>0 ){
                   $data = $query->row();
                   
                    return array('tasa'=>$data->tasa);
           }else{
               
                    return false;
               
           }
    }
    
    
    /*
     * funcion que inserta los detalles de los intereses, en las tablas
     * intereses y detalle_interes, donde se especifican toda la informacion
     * respecto a los intereses por mes
     */
    
    function inserta_detalle_interes($data=  array(), $datos_p=  array(),$inf_extemp,$tipo_multa,$opc_tipo_multa)
    {
        //con is_array se comprueba si $data es un arreglo
        if(is_array($data)):
            
            //contar la cantidad de posiciones del arreglo data, que es el contiene los periodos
            $limite_arreglo=count($data);
            
            //inicializar la variable contador en 0 *************
            $contador=0;

            //inicializar la variable contador_mes en 0
//            $j=0;
            
            $arreglo_i=  array();
            $arreglo_t=  array();
            $arreglo_d=  array();
            $arreglo_mes=  array();
            $arreglo_a=  array();
            
            
            
           
             if($opc_tipo_multa==2){
                $tipo_reso='reso-culminatoria';
                $nro_resolucion=$this->__numero_de_resolucion($tipo_reso);
                }if(($opc_tipo_multa==3)){
                    $tipo_reso='reso-sumario';
                    $nro_resolucion=$this->__numero_de_resolucion($tipo_reso);
                    }
                    
            //iniciar transacion que verifica el correcto ingreso de la información a la BD
            $this->db->trans_start();   
                
             /*ciclo for para insertar la información de cada una de ñas fechas de todos los periodos 
             * desde 0 hasta el limte_arreglo
             */    
            for ($i=0; $i<$limite_arreglo;$i++)
            { 
                //contar las posiciones de los arreglos correspondiente a cada periodo
                $limit_periodo=count($data['periodo'.$i]['dias']);
                //capturar los dias por el mes que corresponda de acuerdo al ciclo for
                $arreglo_dias[$i]=$data['periodo'.$i]['dias'];
                //capturar los anos por el mes que corresponda de acuerdo al ciclo for
                $arreglo_anio[$i]=$data['periodo'.$i]['anios'];
                //capturar la tasa por el mes que corresponda de acuerdo al ciclo for
                $arreglo_tasa[$i]=$data['periodo'.$i]['tasa'];
                //capturar la tasa porcentaje por el mes que corresponda de acuerdo al ciclo for
                $arreglo_tasa_porcentaje[$i]=$data['periodo'.$i]['tasa_porcentaje'];
                //capturar los intereses por el mes que corresponda de acuerdo al ciclo for
                $arreglo_interes[$i]=$data['periodo'.$i]['intereses'];
                //capturar las multas
                $total_multa=$data['periodo'.$i]['multas'];
                //capturar id de la declaracion extemporaneo
                $id_declara=$data['periodo'.$i]['id_declara'];
                // genera numero de resolucion para multas extemporaneas y actualiza la tabla de correlativos
                if($opc_tipo_multa==1){
                    
                        $tipo_reso='reso-extem';
                        //obtenemos el numero de resolcion
                        $nro_resolucion=$this->__numero_de_resolucion($tipo_reso);
                        //acrtualizamos el correlativo en la tabla que lleva los numeros
                        $partes=  explode('-', $nro_resolucion);
                        (intval($partes[0]==1)? $whre_act=array('correlativo'=>2,'anio'=>date('Y')) : $whre_act=array('correlativo'=>(intval($partes[0])+1)));
                        $datos_acta_corr=array(
                                                'dw'=>array("tipo"=>$tipo_reso),
                                                'dac'=>$whre_act,
                                                'tabla'=>'datos.correlativos_actas'

                                            );
                        $this->operaciones_bd->actualizar_BD(1,$datos_acta_corr);
                }
                
                //acumulador para calcular el total de los intereses
                $total_interes=0;
                //recorrido de cada uno de los intereses para ir acumulandolos en la variable total_intereses
                foreach ($arreglo_interes[$i] as $interes => $value) 
                {
                    $total_interes=$total_interes+$value;
                   
                }
                
                //ingresos tabla multas
                $this->db->insert('pre_aprobacion.multas',  array('nresolucion'=>$nro_resolucion,'fechaelaboracion'=>'now()',
                                   'montopagar'=>$total_multa,'declaraid'=>$id_declara,'ip'=>$this->input->ip_address(),
                                    'usuarioid'=>$this->session->userdata('id'),'tipo_multa'=>$tipo_multa));
//                
                $id_multa= $this->db->insert_id();
//                
                //ingresos tabla intereses
                $this->db->insert('pre_aprobacion.intereses',  array('numresolucion'=>$nro_resolucion,'totalpagar'=>$total_interes,'multaid'=>$id_multa,
                                   'ip'=>$this->input->ip_address(),'usuarioid'=>$this->session->userdata('id'),
                                   'fecha_inicio'=>$datos_p['periodo'.$i]['fecha_inicio'],'fecha_fin'=>$datos_p['periodo'.$i]['fecha_fin']));
//                
                $id= $this->db->insert_id();
                
                
                /*
                 * recorrido para cargar un arreglo con todos los meses segun cada periodo
                 * se cambian las claves del arreglo 
                 */
                foreach ($arreglo_dias[$i] as $mes => $value) 
                {
                    $piezas= explode ('-',$mes);
                    $arreglo_mes[$i][$contador]=$piezas['0'];
                    $contador++;
                }
                 $contador=0;
                 
                foreach ($arreglo_tasa[$i] as $tasa => $value) 
                {                    
                    $arreglo_t[$i][$contador]=$value;
                    $contador++;
                } 
                
                $contador=0;
                 
                foreach ($arreglo_tasa_porcentaje[$i] as $tasap => $value) 
                {                    
                    $arreglo_tp[$i][$contador]=$value;
                    $contador++;
                }
                
                $contador=0;
                
                foreach ($arreglo_dias[$i] as $dias => $value) 
                {                    
                    $arreglo_d[$i][$contador]=$value;
                    $contador++;
                }               
                
                $contador=0;
                foreach ($arreglo_interes[$i] as $interes => $value) 
                {                    
                    $arreglo_i[$i][$contador]=$value;
                    $contador++;
                }               
                
                $contador=0;
                foreach ($arreglo_anio[$i] as $anio => $value) 
                {                    
                    $arreglo_a[$i][$contador]=$value;
                    $contador++;
                }               
                
                $contador=0;
                /*ingreso a la tabla detalle_interes, 
                 **dentro del for que recorre los periodos, se establece otro for porque en este
                 **caso el limite sera la variable $limit_periodo que tal como se indico anteriormente
                 * hace referencia a las posiciones de los arreglos correspondiente a cada periodo
                 * Se identifican todos los datos por cada uno de los meses y son los que se almacenaran 
                 * uno por uno en la tabla detalle_interes
                */
                for ($j=0;$j<$limit_periodo;$j++)
                {
//                    $g=$arreglo_mes[$i][$j];
//                'cast('.$arreglo_i[$i][$j].' as numeric)'
                    $datos=  array('intereses'=>$arreglo_i[$i][$j],'tasa'=>$arreglo_t[$i][$j],
                                   'dias'=>$arreglo_d[$i][$j],'mes'=>$arreglo_mes[$i][$j],
                                   'anio'=>$arreglo_a[$i][$j], 'intereses_id'=>$id,
                                   'ip'=>$this->input->ip_address(),
                                   'usuarioid'=>$this->session->userdata('id'),
                                   'capital'=>$data['periodo'.$i]['capital'],
                                   'tasa%'=>$arreglo_tp[$i][$j]);

                    $this->db->insert('datos.detalle_interes',$datos);

            
      
//                    $j++;
                }
                
                
                //cambiar estatus - modificar campo 'proceso' a calculado
                if($opc_tipo_multa==1){
                $datos=array(

                        'dw'=>array("id"=>$inf_extemp
                                    ),
                        'dac'=>array('proceso'=>'calculado'
                                    ),
                        'tabla'=>'datos.contrib_calc'


                );
                }elseif(($opc_tipo_multa==2) || ($opc_tipo_multa==3)){
                    
                     $datos=array(

                        'dw'=>array("id"=>$inf_extemp
                                    ),
                        'dac'=>array('proceso'=>'calculado'
                                    ),
                        'tabla'=>'datos.reparos'


                );
                }
                
                $this->operaciones_bd->actualizar_BD(1,$datos); 
                
                
                
//                $j=0;
//                        $prueba[$i]=$limit_periodo;
            }
                //actualizamos numero de correlativo en la tabla que lleva estos aqui se ejucuta 
                //solo cuando sean multas distintas a extemporaneas
                if(($opc_tipo_multa!=1))
                {
                    $partes=  explode('-', $nro_resolucion);
                    (intval($partes[0]==1)? $whre_act=array('correlativo'=>2,'anio'=>date('Y')) : $whre_act=array('correlativo'=>(intval($partes[0])+1)));
                    $datos_acta_corr=array(

                                'dw'=>array("tipo"=>$tipo_reso),
                                'dac'=>$whre_act,
                                'tabla'=>'datos.correlativos_actas'

                        );
                    $this->operaciones_bd->actualizar_BD(1,$datos_acta_corr); 
                }
                
               
           
//            return $datos;
          
            //proceso para el fin de la transacion
                    $this->db->trans_complete();

                    if ($this->db->trans_status() === FALSE):
                        $this->db->trans_rollback();
                        return false;
                    else:
                        $this->db->trans_commit();
                        return true;
                    endif;
        endif;
            
    }
    
    
    //funcion para regresar el id multa de la tabla tdeclara
    function devuelve_id_multa($opc_tipo_multa)
    {
        $this->db
                ->select("tdeclara.id as id_tdeclara")
                ->from("datos.tdeclara")
                ->where(array("tdeclara.tipo"=>$opc_tipo_multa));
                  
           $query = $this->db->get();
           
           if( $query->num_rows()>0 ){
                   $data = $query->row();
                   
                    return $data->id_tdeclara;
           }else{
               
                    return false;
               
           }
        
    }
    
    public function unidad_tributaria_actual()
    {
        $this->db
                ->select("undtrib.valor as ut")
                ->from("datos.undtrib")
                ->where(array("undtrib.anio"=> date("Y")));
                  
           $query = $this->db->get();
           
           if( $query->num_rows()>0 ){
                   $data = $query->row();
                   
                    return $data->ut;
           }else{
               
                    return false;
               
           }
        
        
    }
    function __numero_de_resolucion($tipo_reso){
        $this->db
                    ->select("correlativos_actas.correlativo")
                    ->from('datos.correlativos_actas')
                    ->where(array('correlativos_actas.tipo'=>$tipo_reso,'correlativos_actas.anio'=>date('Y')));
//            if($this->db->count_all_results()>0):           
                $query = $this->db->get();           
               if( $query->num_rows()>0 ){
                     $data = $query->row();

                     return ($data->correlativo.'-'.date('Y'));
               }else{
                   
                   return '1-'.date('Y'); 
               }
    }
    

}