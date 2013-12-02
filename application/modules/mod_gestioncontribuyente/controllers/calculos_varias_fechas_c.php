<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Calculos_c extends CI_Controller {
    
        
        function calc_dia_interes_meses_anio_diferente($dia_inicio, $dia_fin, $mes_inicio,$mes_final,$anio_inicio,$anio_fin,$total_declara)
        {
            //inicializa el ciclo en el año inicial
            $inicializador=$anio_inicio;
            $final_ciclo=$anio_fin-1;
            for ($i=$inicializador; $i=$final_ciclo; $i++)
            {
                $i++;
                
                $arreglo_anio[]=$i;
                
                for($j=$mes_inicio; $j=12; $j++)
                {
                    $arreglo_dias[$j]=date("d",mktime(0,0,0,$i+1,0,$arreglo_anio[$i]));
                }
                
//                if($i<10):
//                    $mesn='0'.$i;
//                else:
//                    $mesn=(string)$i;
//                endif;
               
//                $tasa_bcv=  $this->calculos_m->devuelve_tasa($anio,$mesn);
//             
//                $tasa_mes[$mesn]=($tasa_bcv['tasa']*1.20)/360;
//
//                
//                
//                $arreglo_anio[$mesn]=$anio;
//                
//                $arreglo_interes[$mesn]=$arreglo_dias[$mesn]*$total_declara*$tasa_mes[$mesn];

            }

//            $data=  array('dias'=>$arreglo_dias,'intereses'=>$arreglo_interes, 'tasa'=>$tasa_mes, 'anios'=>$arreglo_anio);
//            return $data;
        }
        
        
//FIN DE LA FUNCION calc_dia_interes_meses_anio_igual
//        
//        public function dias()
//	{
//            $ano=2009;
//            $mes=04;
//
//           //genera los dias del mes
//            echo date("d",mktime(0,0,0,$mes+1,0,$ano)).'<br />';
//        } 
        
        
        /*EXTEMPORANEO*/
        
        //-MULTA
        public function calc_multa_extemp($total_declara)
        {
            $multa_e=($total_declara*1)/100;
            return $multa_e;
        } 
        

        
        /*OMISOS*/
        
        //-MULTA -> Si Pago Deuda
        public function multa_extemp_pago()
	{
            
            $total_reparo=25000;
            
            $multa_e=$total_reparo*(10/100);
            
            echo $multa_e.' Bs.';
        }
       

        
        //-MULTA -> No Pago Deuda
        public function multa_extemp_npago()
	{
            
            
            $total_reparo=25000;
            $ut_actual=117;
            $A=$total_reparo*(112.5/100);
            
            //regla de 3
            $B=$A/$ut_actual;
            
            $multa_e_np=$B*$ut_actual;
            
            echo $multa_e_np.' Bs.';
        }
        
        

        
        /*
         * Funcion que calcula los dias, tasas, intereses del año inicio cuando
         * fecha inicia y fecha fin son distintas
         */
        
        function calc_inicio_anio_intermedio($dia_inicio, $dia_fin, $mes_inicio,$mes_final,$anio,$total_declara)
        {

            $this->load->model('calculos_m');
            $tasa_bcv_i=  $this->calculos_m->devuelve_tasa($anio,$mes_inicio);
            
  
            $tasa_mes[$mes_inicio.'-'.$anio]=($tasa_bcv_i['tasa']*1.20)/360;

            $calc_dias=date("d",mktime(0,0,0,$mes_inicio+1,0,$anio));
            

            $dia_mes_inicio=$calc_dias-$dia_inicio;
            
            $arreglo_dias[$mes_inicio.'-'.$anio]=$dia_mes_inicio;

            $arreglo_anio[$mes_inicio.'-'.$anio]=$anio;

            $arreglo_interes[$mes_inicio.'-'.$anio]=$dia_mes_inicio*$total_declara*$tasa_mes[$mes_inicio.'-'.$anio];

            $inicializador=$mes_inicio+1;

            for ($i=$inicializador; $i<=12; $i++)
            {

                if($i<10):
                    $mesn='0'.$i;
                else:

                    $mesn=(string)$i;
                endif;
  
                $tasa_bcv=  $this->calculos_m->devuelve_tasa($anio,$mesn);

                $tasa_mes[$mesn.'-'.$anio]=($tasa_bcv['tasa']*1.20)/360;

                $arreglo_dias[$mesn.'-'.$anio]=date("d",mktime(0,0,0,$i+1,0,$anio));

                
                $arreglo_anio[$mesn.'-'.$anio]=$anio;
                

                $arreglo_interes[$mesn.'-'.$anio]=$arreglo_dias[$mesn.'-'.$anio]*$total_declara*$tasa_mes[$mesn.'-'.$anio];

            }
            
            $data=  array('dias'=>$arreglo_dias,'intereses'=>$arreglo_interes, 'tasa'=>$tasa_mes, 'anios'=>$arreglo_anio);
             return $data;
        }//Fin de la funcion calculo año inicio
        
        
        //Funcion para el calculo de los dias, intereses del pago en un mismo mes para años iguales
        
        function calc_dia_interes_mes_igual_anio_igual($dia_inicio, $dia_fin, $mes_inicio,$anio,$total_declara)
        {
            $this->load->model('calculos_m');
            $tasa_bcv_i=  $this->calculos_m->devuelve_tasa($anio,$mes_inicio);

            $tasa_mes[$mes_inicio.'-'.$anio]=($tasa_bcv_i['tasa']*1.20)/360;
            
            $dias_mes_igual=$dia_fin-$dia_inicio;
            
            $arreglo_dias[$mes_inicio.'-'.$anio]=$dias_mes_igual;
            

            $arreglo_anio[$mes_inicio.'-'.$anio]=$anio;

            $arreglo_interes[$mes_inicio.'-'.$anio]=$dias_mes_igual*$total_declara*$tasa_mes[$mes_inicio.'-'.$anio];


            $data=  array('dias'=>$arreglo_dias,'intereses'=>$arreglo_interes, 'tasa'=>$tasa_mes, 'anios'=>$arreglo_anio);
            return $data;
        }
        
//FIN DE LA FUNCION calc_dia_interes_mes_igual_anio_igual

        
        function index()
	{
               $tipo_multa=4;
               $total_declara=10000;
               
            $fechas = array(
                
                "periodo0"=>  array(
                    "fecha_inicio" => "29-04-2005",
                    "fecha_fin" => "15-11-2007"),
                
                "periodo1"=>array(
                    "fecha_inicio" => "05-10-2008",
                    "fecha_fin" => "06-10-2008"),
                
                "periodo2"=>array(
                    "fecha_inicio" => "20-05-2010",
                    "fecha_fin" => "08-10-2010"),
            );
            
            $limite=count($fechas);
            
            $data=  array();
            
            for ($i=0; $i<$limite;$i++)
            {
               $fecha_inicio=$fechas['periodo'.$i]['fecha_inicio'];
                
               $fecha_fin=$fechas['periodo'.$i]['fecha_fin'];
                
                
               $piezas_inicio= explode ('-',$fecha_inicio);
               $anio_inicio=$piezas_inicio['2'];
               $mes_inicio=$piezas_inicio['1'];
               $dia_inicio=$piezas_inicio['0'];
               
               $piezas_fin= explode ('-',$fecha_fin);
               $anio_fin=$piezas_fin['2'];
               $mes_fin=$piezas_fin['1'];
               $dia_fin=$piezas_fin['0'];
               
               if($anio_inicio==$anio_fin)
               {

                       $data['periodo'.$i]=  $this->calc_dia_interes_meses_anio_igual($dia_inicio, $dia_fin, $mes_inicio,$mes_fin,$anio_fin,$total_declara);
               }
               
               if($anio_inicio!=$anio_fin)
               {
                   $data['periodo'.$i]=  $this->calc_dia_interes_meses_anio_diferente($dia_inicio,$mes_inicio,$anio_inicio,$dia_fin,$mes_fin,$anio_fin,$total_declara);
                   
               }
               
            }
            
            $this->load->model('calculos_m');
            $imprimir=$this->calculos_m->inserta_detalle_interes($data, $fechas);
//            
            print_r($imprimir);
//            print_r($data['periodo1']);
            
            
            
        }  
        
        /*PRUEBA
         
         if($status_declara=='o')
         {
            
         } else if($status_declara=='e')
         {
            if(status_decl_rep=='p')
            {
                
            } else if(status_decl_rep=='np')
            {
            }
         }
         
         */
        
}