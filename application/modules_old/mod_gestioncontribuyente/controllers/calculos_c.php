<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Calculos_c extends CI_Controller {
    
        function index()
	{
            //variables
               $tipo_multa=4;
               
//            construir arreglos de fechas
            $datos_p = array(
                
                //periodo I
                "periodo0"=>  array(
                    "fecha_inicio" => "29-04-2005",
                    "fecha_fin" => "15-11-2007",
                    "total_declara" => "25000"),
                
                //periodo II
                "periodo1"=>array(
                    "fecha_inicio" => "05-10-2008",
                    "fecha_fin" => "06-10-2008",
                    "total_declara" => "10000"),
                
                //periodo III
                "periodo2"=>array(
                    "fecha_inicio" => "20-05-2010",
                    "fecha_fin" => "08-10-2010",
                    "total_declara" => "10000"),
            );
            
            
            
            
            //contar posiciones del arreglo de los periodos
            $limite=count($datos_p);
            
            $data=  array();
            
            for ($i=0; $i<$limite;$i++)
            {
                //capturar las fechas inicios de cada periodo, esta en la posicion 0
                $fecha_inicio=$datos_p['periodo'.$i]['fecha_inicio'];
                
                //capturar las fechas finales de cada periodo, esta en la posicion 1
                $fecha_fin=$datos_p['periodo'.$i]['fecha_fin'];
                
                $total_declara=$datos_p['periodo'.$i]['total_declara'];
                
                
                $multas=  $this->calc_multas($total_declara);
//                      
                
                
                //separar  dia-mes-año inicio y fin de cada una de las fechas
               $piezas_inicio= explode ('-',$fecha_inicio);
               //posiciones del arreglo fecha
               $anio_inicio=$piezas_inicio['2'];
               $mes_inicio=$piezas_inicio['1'];
               $dia_inicio=$piezas_inicio['0'];
               
               //echo $anio_inicio.$mes_inicio.$dia_inicio;
               
               $piezas_fin= explode ('-',$fecha_fin);
               $anio_fin=$piezas_fin['2'];
               $mes_fin=$piezas_fin['1'];
               $dia_fin=$piezas_fin['0'];
               
               if($anio_inicio==$anio_fin)
               {

                       $data['periodo'.$i]=  $this->calc_dia_interes_meses_anio_igual($dia_inicio, $dia_fin, $mes_inicio,$mes_fin,$anio_fin,$total_declara);
//                       print_r($data);
//$calc_dias=  $this->calc_dia_interes_meses_anio_igual($dia_inicio, $dia_fin, $mes_inicio,$mes_fin,$anio_fin,$total_declara);
               }
               
               if($anio_inicio!=$anio_fin)
               {
                   $data['periodo'.$i]=  $this->calc_dia_interes_meses_anio_diferente($dia_inicio,$mes_inicio,$anio_inicio,$dia_fin,$mes_fin,$anio_fin,$total_declara);
                   
               }
               
               $data['periodo'.$i]['multas']=$multas;
               
            }//cierra for
            
//            $this->load->model('calculos_m');
//            $imprimir=$this->calculos_m->inserta_detalle_interes($data, $datos_p);
//            
//            print_r($imprimir);
            print_r($data);
            
            
            
        }     

//INICIO DE LA FUNCION calc_dia_interes_meses_anio_igual en el caso de que el año inicio sea igual al año final
        
        /*funcion para capturar los dias y los intereses de acuerdo a la tasa calculada por el interes
        del bcv, de los meses intermedios y los del mes inicio*/
        function calc_dia_interes_meses_anio_igual($dia_inicio, $dia_fin, $mes_inicio,$mes_final,$anio,$total_declara)
        {
            //carga modelo que trae el interes correspondiente al mes inicial
            $this->load->model('calculos_m');
            //carga la funcion en el modelo que devuelve la tasa, parametro anio y mes inicial
            $tasa_bcv_i=  $this->calculos_m->devuelve_tasa($anio,$mes_inicio);
            
            if($mes_inicio==$mes_final)
            {
                $tasa_mes[$mes_inicio.'-'.$anio]=($tasa_bcv_i['tasa']*1.20)/360;
            
                //print_r($tasa_mes);

                $dias_mes_igual=$dia_fin-$dia_inicio;

                $arreglo_dias[$mes_inicio.'-'.$anio]=$dias_mes_igual;

                $arreglo_anio[$mes_inicio.'-'.$anio]=$anio;

                $arreglo_interes[$mes_inicio.'-'.$anio]=$dias_mes_igual*$total_declara*$tasa_mes[$mes_inicio.'-'.$anio];

                $data=  array('dias'=>$arreglo_dias,'intereses'=>$arreglo_interes, 'tasa'=>$tasa_mes, 'anios'=>$arreglo_anio);
            } else
            {
                /*
                 * se empieza a construir el arreglo de los interese con la variable tasa_mes
                 * con la variable, en este caso $mes_inicio - tasa que corresponde a ese mes
                 * en la formula incluye la variable $tasa_bcv_i['tasa'] que trae la tasa del bcv
                 * del mes inicial, el 1.20 y el 360 son datos fijos de la formula
                 */
                $tasa_mes[$mes_inicio.'-'.$anio]=($tasa_bcv_i['tasa']*1.20)/360;

                //calculo de dia de mes inicio -aplicando mktime
                $calc_dias=date("d",mktime(0,0,0,$mes_inicio+1,0,$anio));

                /*dias mes incio es igual a la resta de los dias del mes inicio menos el dia de inicio
                 * para determinar los dias del mes inicio, se debe aplicar la resta entre el dia del mes
                 * con el dia tope, esos seran los dias necesarios para el calculo de interes del mes inicio
                 */
                $dia_mes_inicio=$calc_dias-$dia_inicio;

                //construir el arreglo_dias se agrega dias mes inicio
                $arreglo_dias[$mes_inicio.'-'.$anio]=$dia_mes_inicio;

                /*---------------------PRUEBA-----------------*/

                $arreglo_anio[$mes_inicio.'-'.$anio]=$anio;
    //            print_r($arreglo_anio);
                /*----------------FIN PRUEBA-----------------*/

                /*formula general para el calculo de los interes a pagar por el contribuyente
                 * el arreglo se asigna a la variable $arreglo_interes del mes inicio es igual
                 * a los dias del mes inicio por el total de la declaracion por la tasa mes del mes inicio
                 */
                $arreglo_interes[$mes_inicio.'-'.$anio]=$dia_mes_inicio*$total_declara*$tasa_mes[$mes_inicio.'-'.$anio];

                //for para los dias y los intereses de meses intermedios
                //inicializa en mes inicio mas 1, porque debe empezar a partir del meses siguiente al mes inicio
                $inicializador=$mes_inicio+1;
                //menor que el mes final, non debe ser igual porque los dias del mes final son los que pasan en la variable
    //            $acum_interes_mi=0;
                for ($i=$inicializador; $i<$mes_final; $i++)
                {

                    /*condicion para concatenar un 0 a los meses que sean menor a 10
                     * debido a que en la tabla se guardan del 1 al 9, sin incluir un 0 previo
                     */
                    if($i<10):
                        $mesn='0'.$i;
                    else:
                        /*si es mayor convertir esa caddena en un entero para que lo muestre 
                        exactamente como esta en la tabla, ademas de que en la tabla mes es varying
                         * la variable i del for se esta reemplazando por la variable $mesn */
                        $mesn=(string)$i;
                    endif;

                    /*
                     * calculo interes de los meses intermedios
                     * en el segundo parametro, correspondiente al mes, no pasa $i, sino $mesn
                     * por la condicion planteada anteriormente
                     */

                    //carga funcion en el modelo que devuelvve la tasa
                    $tasa_bcv=  $this->calculos_m->devuelve_tasa($anio,$mesn);
                    //calculo de la tasa por cada mes
                    $tasa_mes[$mesn.'-'.$anio]=($tasa_bcv['tasa']*1.20)/360;

                    /*construir arreglo_dias se agrega dias mes intermedio
                     * en este caso se puede segyir pasando $i y no es necesario
                     * reemplazarla por $mesn
                     */
                    $arreglo_dias[$mesn.'-'.$anio]=date("d",mktime(0,0,0,$i+1,0,$anio));

                    /*-------------PRUEBA---------------------*/

                    $arreglo_anio[$mesn.'-'.$anio]=$anio;

                    /*------------FIN PRUEBA------------------*/

    //                $arreglo_dias_anio[$anio]= $arreglo_dias[$mesn];

                    //construir arreglo intereses - reemplaza $i por $mesn
                    $arreglo_interes[$mesn.'-'.$anio]=$arreglo_dias[$mesn.'-'.$anio]*$total_declara*$tasa_mes[$mesn.'-'.$anio];

                }


                /*carga funcion en el modelo
                 * con segundo parametros $mes_final
                 */
                $tasa_bcv_f=  $this->calculos_m->devuelve_tasa($anio,$mes_final);

                /*calculo tasa mes final, agregandola al arreglo tasa_mes que ya trae
                la tasa del mes inicial y la tasa de los meses intermedios
                */
                $tasa_mes[$mes_final.'-'.$anio]=($tasa_bcv_f['tasa']*1.20)/360;


                //arreglo_dias se agrega dias mes final
                $arreglo_dias[$mes_final.'-'.$anio]=$dia_fin;

                /*---------------------PRUEBA-----------------*/

                $arreglo_anio[$mes_final.'-'.$anio]=$anio;
    //            print_r($arreglo_anio);
                /*----------------FIN PRUEBA-----------------*/

                //agregar al arreglo intereses el interes del mes final
                $arreglo_interes[$mes_final.'-'.$anio]=$dia_fin*$total_declara*$tasa_mes[$mes_final.'-'.$anio];

                /*variable que contiene todos los arreglos a retornar, que son dias de los meses,
                intereses de los meses tasa por mes*/

                $data=  array('dias'=>$arreglo_dias,'intereses'=>$arreglo_interes, 'tasa'=>$tasa_mes, 'anios'=>$arreglo_anio);
            }
            return $data;
        }
        
//FIN DE LA FUNCION calc_dia_interes_meses_anio_igual
        
        
         //Funcion para el calculo de los dias, intereses del pago en un mismo mes para años iguales
        
        function calc_dia_interes_mes_igual_anio_igual($dia_inicio,$dia_fin,$mes_inicio,$anio,$total_declara)
        {
            $this->load->model('calculos_m');
            $tasa_bcv_i=  $this->calculos_m->devuelve_tasa($anio,$mes_inicio);
//            echo $mes_inicio;

            $tasa_mes[$mes_inicio.'-'.$anio]=($tasa_bcv_i['tasa']*1.20)/360;
            
            //print_r($tasa_mes);
            
            $dias_mes_igual=$dia_fin-$dia_inicio;
          
            $arreglo_dias[$mes_inicio.'-'.$anio]=$dias_mes_igual;

            $arreglo_anio[$mes_inicio.'-'.$anio]=$anio;

            $arreglo_interes[$mes_inicio.'-'.$anio]=$dias_mes_igual*$total_declara*$tasa_mes[$mes_inicio.'-'.$anio];

            $data=  array('dias'=>$arreglo_dias,'intereses'=>$arreglo_interes, 'tasa'=>$tasa_mes, 'anios'=>$arreglo_anio);
            
            return $data;
        }
        
//FIN DE LA FUNCION calc_dia_interes_mes_igual_anio_igual
        
        
        
         /*
         * Funcion que calcula los dias, tasas, intereses del año inicio cuando
         * fecha inicia y fecha fin son distintas
         */
        
        function calc_inicio_anio_intermedio($dia_inicio,$mes_inicio,$anio_inicio,$total_declara)
        {

            $this->load->model('calculos_m');
            $tasa_bcv_i=  $this->calculos_m->devuelve_tasa($anio_inicio,$mes_inicio);
            
  
            $tasa_mes[$mes_inicio.'-'.$anio_inicio]=($tasa_bcv_i['tasa']*1.20)/360;

            $calc_dias=date("d",mktime(0,0,0,$mes_inicio+1,0,$anio_inicio));
            

            $dia_mes_inicio=$calc_dias-$dia_inicio;
            
            $arreglo_dias[$mes_inicio.'-'.$anio_inicio]=$dia_mes_inicio;

            $arreglo_anio[$mes_inicio.'-'.$anio_inicio]=$anio_inicio;

            $arreglo_interes[$mes_inicio.'-'.$anio_inicio]=$dia_mes_inicio*$total_declara*$tasa_mes[$mes_inicio.'-'.$anio_inicio];

            $inicializador=$mes_inicio+1;

            for ($i=$inicializador; $i<=12; $i++)
            {

                if($i<10):
                    $mesn='0'.$i;
                else:

                    $mesn=(string)$i;
                endif;
  
                $tasa_bcv=  $this->calculos_m->devuelve_tasa($anio_inicio,$mesn);

                $tasa_mes[$mesn.'-'.$anio_inicio]=($tasa_bcv['tasa']*1.20)/360;

                $arreglo_dias[$mesn.'-'.$anio_inicio]=date("d",mktime(0,0,0,$i+1,0,$anio_inicio));

                
                $arreglo_anio[$mesn.'-'.$anio_inicio]=$anio_inicio;
                

                $arreglo_interes[$mesn.'-'.$anio_inicio]=$arreglo_dias[$mesn.'-'.$anio_inicio]*$total_declara*$tasa_mes[$mesn.'-'.$anio_inicio];

            }
            
            $data=  array('dias'=>$arreglo_dias,'intereses'=>$arreglo_interes, 'tasa'=>$tasa_mes,'anios'=>$arreglo_anio);
             return $data;
        }//Fin de la funcion calculo año inicio
        
        
        /*
         * Funcion que calcula los dias, tasas, intereses del año final cuando
         * fecha inicia y fecha fin son distintas
         */
        
        function calc_final_anio_intermedio($dia_fin,$mes_fin,$anio_fin,$total_declara)
        {

            $this->load->model('calculos_m');
            
            for ($i=1; $i<$mes_fin; $i++)
            {

                if($i<10):
                    $mesn='0'.$i;
                else:

                    $mesn=(string)$i;
                endif;
  
                $tasa_bcv=  $this->calculos_m->devuelve_tasa($anio_fin,$mesn);

                $tasa_mes[$mesn.'-'.$anio_fin]=($tasa_bcv['tasa']*1.20)/360;

                $arreglo_dias[$mesn.'-'.$anio_fin]=date("d",mktime(0,0,0,$i+1,0,$anio_fin));

                
                $arreglo_anio[$mesn.'-'.$anio_fin]=$anio_fin;
                

                $arreglo_interes[$mesn.'-'.$anio_fin]=$arreglo_dias[$mesn.'-'.$anio_fin]*$total_declara*$tasa_mes[$mesn.'-'.$anio_fin];

            }
            
            //los dias en el que dejó de declarar en el ultimo mes es el que trae en la variable de la fecha - $dia_fin 
            $tasa_bcv_f=  $this->calculos_m->devuelve_tasa($anio_fin,$mes_fin);
            

            $tasa_mes[$mes_fin.'-'.$anio_fin]=($tasa_bcv_f['tasa']*1.20)/360;

            $arreglo_dias[$mes_fin.'-'.$anio_fin]=$dia_fin;

            
            $arreglo_anio[$mes_fin.'-'.$anio_fin]=$anio_fin;

            $arreglo_interes[$mes_fin.'-'.$anio_fin]=$dia_fin*$total_declara*$tasa_mes[$mes_fin.'-'.$anio_fin];
            
            
            $data=  array('dias'=>$arreglo_dias,'intereses'=>$arreglo_interes, 'tasa'=>$tasa_mes,'anios'=>$arreglo_anio);
             return $data;
        }//Fin de la funcion calculo año final
        
        
        
        //FUNCION PARA EL CALCULO DE LOS AÑOS DIFERENTES
        
        function calc_dia_interes_meses_anio_diferente($dia_inicio,$mes_inicio,$anio_inicio,$dia_fin,$mes_fin,$anio_fin,$total_declara)  
        {
            
            $data=$this->calc_inicio_anio_intermedio($dia_inicio,$mes_inicio,$anio_inicio,$total_declara);
            
            $this->load->model('calculos_m');
            /*
             * DIAS DE LOS MESES DE LOS AÑOS INTERMEDIOS
             */
            //inicializa el ciclo en el año inicial mas 1
            $inicializador=$anio_inicio+1;
            
            for ($i=$inicializador; $i<$anio_fin; $i++)
            {
//                print_r($arreglo_anio);
                
                for($j=1; $j<=12; $j++)
                {
                    if($j<10):
                        $mesn='0'.$j;
                    else:
                        $mesn=(string)$j;
                    endif;
                    
                    //carga funcion en el modelo que devuelvve la tasa
                    $tasa_bcv=  $this->calculos_m->devuelve_tasa($i,$mesn);
                     //calculo de la tasa por cada mes
                    $data['tasa'][$mesn.'-'.$i]=(($tasa_bcv['tasa']*1.20)/360);

                    /*dias de cada uno de los mesese del año que este pasando
                    se van agregando al arreglo data las demas variables, dias, tasas, interes
                     * data es el arreglko que devuelve la funcion que se esta llamando en esta
                     */
                    $data['dias'][$mesn.'-'.$i]=date("d",mktime(0,0,0,$j+1,0,$i));
                    
                    $data['intereses'][$mesn.'-'.$i]=$data['dias'][$mesn.'-'.$i]*$total_declara*$data['tasa'][$mesn.'-'.$i];
                    
                    $data['anios'][$mesn.'-'.$i]=$i;

                }
//                
             }
             $data_fin=$this->calc_final_anio_intermedio($dia_fin,$mes_fin,$anio_fin,$total_declara);
//             $cont_data_f=count($data_fin);
//             
//             for($x=0; $x<=$cont_data_f;$x++)
//             {
                 for($j=1; $j<=$mes_fin; $j++)
                 {
                    if($j<10):
                        $mesn='0'.$j;
                    else:
                        $mesn=(string)$j;
                    endif;
                    
                    $data['tasa'][$mesn.'-'.$anio_fin]=$data_fin['tasa'][$mesn.'-'.$anio_fin];
                    $data['dias'][$mesn.'-'.$anio_fin]=$data_fin['dias'][$mesn.'-'.$anio_fin];
                    $data['intereses'][$mesn.'-'.$anio_fin]=$data_fin['intereses'][$mesn.'-'.$anio_fin];
                    $data['anios'][$mesn.'-'.$anio_fin]=$data_fin['anios'][$mesn.'-'.$anio_fin];
                }
                 
//             }
             
             return $data;
             /*
             * FIN - DIAS DE LOS MESES DE LOS AÑOS INTERMEDIOS
             */

             
        }
        
        
        
        
        //funcion para el calculo de las MULTAS
        function calc_multas($total_declara)  
        {
            $multas=$total_declara*1/100;
            
            
            return $multas;
        }
}


