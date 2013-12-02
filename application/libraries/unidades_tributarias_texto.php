<?php

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 * Description of unidades_tributarias_texto
 *
 * @author jefferson
 */
class unidades_tributarias_texto
{
    public function convertir_a_letras($numero) { 
         global $importe_parcial;
         $importe_parcial = $numero;
         if ($numero < 1000000000) {
             if ($numero >= 1000000 && $numero <= 999999999.99)
                 $num_letras = $this->millon().$this->cien_mil().$this->cien();
             else if ($numero >= 1000 && $numero <= 999999.99)
                 $num_letras = $this->cien_mil().$this->cien();
             else if ($numero >= 1 && $numero <= 999.99)
                 $num_letras = $this->cien();
             else if ($numero >= 0.01 && $numero <= 0.99) {
                 if ($numero == 0.01) 
                     $num_letras = "un CENTÉSIMAS DE UNIDADES TRIBUTARIAS";
                 else 
                     $num_letras = $this->convertir_a_letras(($numero * 100)."/100")." CENTÉSIMAS DE UNIDADES TRIBUTARIAS";
                 }
         } 
        return $num_letras; 
     
     }
    private function centimos()
    { 
        global $importe_parcial; 
        $importe_parcial = number_format($importe_parcial, 2, ".", "") * 100; 
        if ($importe_parcial > 0) $num_letra = " con ".$this->decena_centimos($importe_parcial); 
        else $num_letra = ""; 
        return $num_letra; 
        
    }
    
    private function unidad_centimos($numero) {
        switch ($numero) { 
            case 9: { $num_letra = "nueve CENTÉSIMAS DE UNIDADES TRIBUTARIAS"; 
            break; 
        
            } 
            case 8: { 
                $num_letra = "ocho CENTÉSIMAS DE UNIDADES TRIBUTARIAS";
                break; } 
                case 7: { 
                    $num_letra = "siete CENTÉSIMAS DE UNIDADES TRIBUTARIAS";
                    break;
                } 
                case 6: {
                    $num_letra = "seis CENTÉSIMAS DE UNIDADES TRIBUTARIAS";
                    break; 
                
                } 
                case 5: { 
                    $num_letra = "cinco CENTÉSIMAS DE UNIDADES TRIBUTARIAS";
                    break;
                } 
                case 4: {
                    $num_letra = "cuatro CENTÉSIMAS DE UNIDADES TRIBUTARIAS";
                    break;
                } 
                case 3: { 
                    $num_letra = "tres CENTÉSIMAS DE UNIDADES TRIBUTARIAS";
                    break;
                } 
                case 2: { 
                    $num_letra = "dos CENTÉSIMAS DE UNIDADES TRIBUTARIAS";
                    break;
                } 
                case 1:
                    { $num_letra = "un CENTÉSIMAS DE UNIDADES TRIBUTARIAS"; 
                    break;
                }
                
            } 
        return $num_letra;
    }
    
    private function decena_centimos($numero) 
    { 
        if ($numero >= 10) {
            if ($numero >= 90 && $numero <= 99) { 
                if ($numero == 90) 
                    return "noventa CENTÉSIMAS DE UNIDADES TRIBUTARIAS"; 
                else if ($numero == 91) 
                    return "noventa y un CENTÉSIMAS DE UNIDADES TRIBUTARIAS";
                else return "noventa y ".$this->unidad_centimos($numero - 90);
                } if ($numero >= 80 && $numero <= 89) { 
                    if ($numero == 80)
                        return "ochenta CENTÉSIMAS DE UNIDADES TRIBUTARIAS"; 
                    else if ($numero == 81) 
                        return "ochenta y un CENTÉSIMAS DE UNIDADES TRIBUTARIAS"; 
                    else 
                        return "ochenta y ".$this->unidad_centimos($numero - 80);
                    } if ($numero >= 70 && $numero <= 79) {
                        if ($numero == 70) 
                            return "setenta CENTÉSIMAS DE UNIDADES TRIBUTARIAS";
                        else if ($numero == 71) 
                            return "setenta y un CENTÉSIMAS DE UNIDADES TRIBUTARIAS";
                        else 
                            return "setenta y ".$this->unidad_centimos($numero - 70); 
                        
                    }
                    if ($numero >= 60 && $numero <= 69) { 
                        if ($numero == 60)
                            return "sesenta CENTÉSIMAS DE UNIDADES TRIBUTARIAS"; 
                        else if ($numero == 61) 
                            return "sesenta y un CENTÉSIMAS DE UNIDADES TRIBUTARIAS"; 
                        else 
                            return "sesenta y ".$this->unidad_centimos($numero - 60); }
                            if ($numero >= 50 && $numero <= 59) {
                                if ($numero == 50) 
                                    return "cincuenta CENTÉSIMAS DE UNIDADES TRIBUTARIAS"; 
                                else if ($numero == 51) 
                                    return "cincuenta y un CENTÉSIMAS DE UNIDADES TRIBUTARIAS"; 
                                else
                                    return "cincuenta y ".$this->unidad_centimos($numero - 50); 
                                
                            } 
                            if ($numero >= 40 && $numero <= 49) {
                                if ($numero == 40)
                                    return "cuarenta CENTÉSIMAS DE UNIDADES TRIBUTARIAS"; 
                                else if ($numero == 41) 
                                    return "cuarenta y un CENTÉSIMAS DE UNIDADES TRIBUTARIAS";
                                else 
                                    return "cuarenta y ".$this->unidad_centimos($numero - 40); 
                                
                            } 
                            if ($numero >= 30 && $numero <= 39) {
                                if ($numero == 30)
                                    return "treinta CENTÉSIMAS DE UNIDADES TRIBUTARIAS"; 
                                else if ($numero == 91) 
                                    return "treinta y un CENTÉSIMAS DE UNIDADES TRIBUTARIAS";
                                else 
                                    return "treinta y ".$this->unidad_centimos($numero - 30);
                                } 
                                if ($numero >= 20 && $numero <= 29) {
                                    if ($numero == 20)
                                        return "veinte CENTÉSIMAS DE UNIDADES TRIBUTARIAS"; 
                                    else if ($numero == 21)
                                        return "veintiun CENTÉSIMAS DE UNIDADES TRIBUTARIAS"; 
                                    else
                                        return "veinti".$this->unidad_centimos($numero - 20);
                                    } 
                                    if ($numero >= 10 && $numero <= 19) { 
                                        if ($numero == 10) 
                                            return "diez CENTÉSIMAS DE UNIDADES TRIBUTARIAS";
                                        else if ($numero == 11) 
                                            return "once CENTÉSIMAS DE UNIDADES TRIBUTARIAS"; 
                                        else if ($numero == 11) 
                                            return "doce CENTÉSIMAS DE UNIDADES TRIBUTARIAS"; 
                                        else if ($numero == 11) 
                                            return "trece CENTÉSIMAS DE UNIDADES TRIBUTARIAS"; 
                                        else if ($numero == 11) 
                                            return "catorce CENTÉSIMAS DE UNIDADES TRIBUTARIAS"; 
                                        else if ($numero == 11) 
                                            return "quince CENTÉSIMAS DE UNIDADES TRIBUTARIAS"; 
                                        else if ($numero == 11) 
                                            return "dieciseis CENTÉSIMAS DE UNIDADES TRIBUTARIAS"; 
                                        else if ($numero == 11) 
                                            return "diecisiete CENTÉSIMAS DE UNIDADES TRIBUTARIAS"; 
                                        else if ($numero == 11) 
                                            return "dieciocho CENTÉSIMAS DE UNIDADES TRIBUTARIAS"; 
                                        else if ($numero == 11) 
                                            return "diecinueve CENTÉSIMAS DE UNIDADES TRIBUTARIAS";
                                        }
        } else 
            return $this->unidad_centimos($numero);
        }
        
private function unidad($numero) { 
    switch ($numero) { 
        case 9: { 
            $num = "nueve"; 
            break;
        } case 8: { 
            $num = "ocho";
            break;
        
        } case 7: { 
            $num = "siete";
            break; 
        
        } case 6: {
            $num = "seis";
            break;
        } case 5: {
            $num = "cinco";
            break;
        } case 4: {
            $num = "cuatro"; 
            break;
        } case 3: { 
            $num = "tres";
            break;
        } case 2: { 
            $num = "dos";
            break;
        } case 1: { 
            $num = "uno";
            break;
        } 
        
    } 
    return $num;
}
private function decena($numero) 
{ 
    if ($numero >= 90 && $numero <= 99) { 
        $num_letra = "noventa ";
        if ($numero > 90) 
            $num_letra = $num_letra."y ".$this->unidad($numero - 90);
        } else if ($numero >= 80 && $numero <= 89) { 
            $num_letra = "ochenta ";
            if ($numero > 80) $num_letra = $num_letra."y ".$this->unidad($numero - 80);
            } else if ($numero >= 70 && $numero <= 79) { 
                $num_letra = "setenta ";
                if ($numero > 70) $num_letra = $num_letra."y ".$this->unidad($numero - 70);
                } else if ($numero >= 60 && $numero <= 69) {
                    $num_letra = "sesenta ";
                    if ($numero > 60) $num_letra = $num_letra."y ".$this->unidad($numero - 60);
                    } else if ($numero >= 50 && $numero <= 59) { 
                        $num_letra = "cincuenta ";
                        if ($numero > 50) $num_letra = $num_letra."y ".$this->unidad($numero - 50);
                        } else if ($numero >= 40 && $numero <= 49) {
                            $num_letra = "cuarenta "; 
                            if ($numero > 40) $num_letra = $num_letra."y ".$this->unidad($numero - 40);
                            } else if ($numero >= 30 && $numero <= 39) { 
                                $num_letra = "treinta ";
                                if ($numero > 30) $num_letra = $num_letra."y ".$this->unidad($numero - 30);
                                } else if ($numero >= 20 && $numero <= 29) { 
                                    if ($numero == 20) $num_letra = "veinte ";
                                    else $num_letra = "veinti".$this->unidad($numero - 20);
                                    } else if ($numero >= 10 && $numero <= 19) { 
                                        switch ($numero) {
                                            case 10: { 
                                                $num_letra = "diez ";
                                                break;
                                            } case 11: { 
                                                $num_letra = "once ";
                                                break;
                                            } case 12: { 
                                                $num_letra = "doce ";
                                                break;
                                            } case 13: {
                                                $num_letra = "trece "; 
                                                break;
                                            } case 14: {
                                                $num_letra = "catorce ";
                                              break;
                                            } case 15: {
                                                $num_letra = "quince ";
                                                break;
                                            } case 16: { 
                                                $num_letra = "dieciseis ";
                                                break;
                                            } case 17: {
                                                $num_letra = "diecisiete ";
                                                break;
                                            } case 18: { 
                                                $num_letra = "dieciocho ";
                                                break;
                                            } case 19: {
                                                $num_letra = "diecinueve ";
                                                break;
                                            }
                                }
                    } else 
                        $num_letra = $this->unidad($numero);
                    return $num_letra;
        }
        
private function centena($numero)
{ 
    if ($numero >= 100) { 
        if ($numero >= 900 & $numero <= 999) {
            $num_letra = "novecientos ";
            if ($numero > 900)
                $num_letra = $num_letra.$this->decena($numero - 900);
            } else if ($numero >= 800 && $numero <= 899) {
                $num_letra = "ochocientos ";
                if ($numero > 800)
                    $num_letra = $num_letra.$this->decena($numero - 800);
                } else if ($numero >= 700 && $numero <= 799) {
                    $num_letra = "setecientos "; 
                    if ($numero > 700) 
                        $num_letra = $num_letra.$this->decena($numero - 700);
                    } else if ($numero >= 600 && $numero <= 699) {
                        $num_letra = "seiscientos "; 
                        if ($numero > 600)
                            $num_letra = $num_letra.$this->decena($numero - 600);
                        } else if ($numero >= 500 && $numero <= 599) {
                            $num_letra = "quinientos ";
                            if ($numero > 500)
                                $num_letra = $num_letra.$this->decena($numero - 500);
                            } else if ($numero >= 400 && $numero <= 499) { 
                                $num_letra = "cuatrocientos ";
                                if ($numero > 400) 
                                    $num_letra = $num_letra.$this->decena($numero - 400);
                                } else if ($numero >= 300 && $numero <= 399) {
                                    $num_letra = "trescientos ";
                                    if ($numero > 300) 
                                        $num_letra = $num_letra.$this->decena($numero - 300); 
                                    
                                } else if ($numero >= 200 && $numero <= 299) {
                                    $num_letra = "doscientos ";
                                    if ($numero > 200) 
                                        $num_letra = $num_letra.$this->decena($numero - 200);
                                    } else if ($numero >= 100 && $numero <= 199) { 
                                        if ($numero == 100) 
                                            $num_letra = "cien "; 
                                        else $num_letra = "ciento ".$this->decena($numero - 100);
                                        }
            } else 
                $num_letra = $this->decena($numero); 
            return $num_letra;
    } 
    private function cien()
    {
        global $importe_parcial;
        $parcial = 0; 
        $car = 0;
        while (substr($importe_parcial, 0, 1) == 0)
                $importe_parcial = substr($importe_parcial, 1, strlen($importe_parcial) - 1); 
        if ($importe_parcial >= 1 && $importe_parcial <= 9.99) 
            $car = 1;
        else if ($importe_parcial >= 10 && $importe_parcial <= 99.99)
            $car = 2; 
        else if ($importe_parcial >= 100 && $importe_parcial <= 999.99)
            $car = 3; 
        $parcial = substr($importe_parcial, 0, $car);
        $importe_parcial = substr($importe_parcial, $car); 
        $num_letra = $this->centena($parcial).$this->centimos();
        return $num_letra;
    }
    private function cien_mil() {
        global $importe_parcial;
        $parcial = 0; 
        $car = 0;
        while (substr($importe_parcial, 0, 1) == 0)
                $importe_parcial = substr($importe_parcial, 1, strlen($importe_parcial) - 1);
        if ($importe_parcial >= 1000 && $importe_parcial <= 9999.99)
            $car = 1;
        else if ($importe_parcial >= 10000 && $importe_parcial <= 99999.99)
            $car = 2; 
        else if ($importe_parcial >= 100000 && $importe_parcial <= 999999.99)
            $car = 3;
        $parcial = substr($importe_parcial, 0, $car);
        $importe_parcial = substr($importe_parcial, $car);
        if ($parcial > 0) { 
            if ($parcial == 1) 
                $num_letra = "mil "; 
            else 
                $num_letra = $this->centena($parcial)." mil ";
        } 
     return $num_letra;
    }
    
     private function millon() {
         global $importe_parcial; 
         $parcial = 0;
         $car = 0; 
         while (substr($importe_parcial, 0, 1) == 0)
                 $importe_parcial = substr($importe_parcial, 1, strlen($importe_parcial) - 1); 
         if ($importe_parcial >= 1000000 && $importe_parcial <= 9999999.99)
             $car = 1; 
         else if ($importe_parcial >= 10000000 && $importe_parcial <= 99999999.99)
             $car = 2; 
         else if ($importe_parcial >= 100000000 && $importe_parcial <= 999999999.99)
             $car = 3; 
         $parcial = substr($importe_parcial, 0, $car);
         $importe_parcial = substr($importe_parcial, $car);
         if ($parcial == 1) 
             $num_letras = "un millón ";
         else 
             $num_letras = $this->centena($parcial)." millones ";
         return $num_letras;
     }
     
     

        /**
         * Convierte un número en una cadena de letras, para el idioma
         * castellano, pero puede funcionar para español de mexico, de  
         * españa, colombia, argentina, etc.
         * 
         * Máxima cifra soportada: 18 dígitos con 2 decimales
         * 999,999,999,999,999,999.99
         * NOVECIENTOS NOVENTA Y NUEVE MIL NOVECIENTOS NOVENTA Y NUEVE BILLONES
         * NOVECIENTOS NOVENTA Y NUEVE MIL NOVECIENTOS NOVENTA Y NUEVE MILLONES
         * NOVECIENTOS NOVENTA Y NUEVE MIL NOVECIENTOS NOVENTA Y NUEVE PESOS 99/100 M.N.
         * 
         * @author Ultiminio Ramos Galán <contacto@ultiminioramos.com>
         * @param string $numero La cantidad numérica a convertir 
         * @param string $moneda La moneda local de tu país
         * @param string $subfijo Una cadena adicional para el subfijo
         * 
         * @return string La cantidad convertida a letras
         */
        public function num_to_letras($numero, $moneda = '', $subfijo = 'U.T')
        {
            $numero_min=  round($numero,2);
            $xarray = array(
                0 => 'Cero'
                , 1 => 'UN', 'DOS', 'TRES', 'CUATRO', 'CINCO', 'SEIS', 'SIETE', 'OCHO', 'NUEVE'
                , 'DIEZ', 'ONCE', 'DOCE', 'TRECE', 'CATORCE', 'QUINCE', 'DIECISEIS', 'DIECISIETE', 'DIECIOCHO', 'DIECINUEVE'
                , 'VEINTI', 30 => 'TREINTA', 40 => 'CUARENTA', 50 => 'CINCUENTA'
                , 60 => 'SESENTA', 70 => 'SETENTA', 80 => 'OCHENTA', 90 => 'NOVENTA'
                , 100 => 'CIENTO', 200 => 'DOSCIENTOS', 300 => 'TRESCIENTOS', 400 => 'CUATROCIENTOS', 500 => 'QUINIENTOS'
                , 600 => 'SEISCIENTOS', 700 => 'SETECIENTOS', 800 => 'OCHOCIENTOS', 900 => 'NOVECIENTOS'
            );

            $numero = trim($numero);
            $xpos_punto = strpos($numero, '.');
            $xaux_int = $numero;
            $xdecimales = '00';
            if (!($xpos_punto === false)) {
                if ($xpos_punto == 0) {
                    $numero = '0' . $numero;
                    $xpos_punto = strpos($numero, '.');
                }
                $xaux_int = substr($numero, 0, $xpos_punto); // obtengo el entero de la cifra a covertir
                $xdecimales = substr($numero . '00', $xpos_punto + 1, 2); // obtengo los valores decimales
            }

            $XAUX = str_pad($xaux_int, 18, ' ', STR_PAD_LEFT); // ajusto la longitud de la cifra, para que sea divisible por centenas de miles (grupos de 6)
            $xcadena = '';
            for ($xz = 0; $xz < 3; $xz++) {
                $xaux = substr($XAUX, $xz * 6, 6);
                $xi = 0;
                $xlimite = 6; // inicializo el contador de centenas xi y establezco el límite a 6 dígitos en la parte entera
                $xexit = true; // bandera para controlar el ciclo del While
                while ($xexit) {
                    if ($xi == $xlimite) { // si ya llegó al límite máximo de enteros
                        break; // termina el ciclo
                    }

                    $x3digitos = ($xlimite - $xi) * -1; // comienzo con los tres primeros digitos de la cifra, comenzando por la izquierda
                    $xaux = substr($xaux, $x3digitos, abs($x3digitos)); // obtengo la centena (los tres dígitos)
                    for ($xy = 1; $xy < 4; $xy++) { // ciclo para revisar centenas, decenas y unidades, en ese orden
                        switch ($xy) {
                            case 1: // checa las centenas
                                $key = (int) substr($xaux, 0, 3);
                                if (100 > $key) { // si el grupo de tres dígitos es menor a una centena ( < 99) no hace nada y pasa a revisar las decenas
                                    /* do nothing */
                                } else {
                                    if (TRUE === array_key_exists($key, $xarray)) {  // busco si la centena es número redondo (100, 200, 300, 400, etc..)
                                        $xseek = $xarray[$key];
                                        $xsub = $this->subfijo($xaux); // devuelve el subfijo correspondiente (Millón, Millones, Mil o nada)
                                        if (100 == $key) {
                                            $xcadena = ' ' . $xcadena . ' CIEN ' . $xsub;
                                        } else {
                                            $xcadena = ' ' . $xcadena . ' ' . $xseek . ' ' . $xsub;
                                        }
                                        $xy = 3; // la centena fue redonda, entonces termino el ciclo del for y ya no reviso decenas ni unidades
                                    } else { // entra aquí si la centena no fue numero redondo (101, 253, 120, 980, etc.)
                                        $key = (int) substr($xaux, 0, 1) * 100;
                                        $xseek = $xarray[$key]; // toma el primer caracter de la centena y lo multiplica por cien y lo busca en el arreglo (para que busque 100,200,300, etc)
                                        $xcadena = ' ' . $xcadena . ' ' . $xseek;
                                    } // ENDIF ($xseek)
                                } // ENDIF (substr($xaux, 0, 3) < 100)
                                break;
                            case 2: // checa las decenas (con la misma lógica que las centenas)
                                $key = (int) substr($xaux, 1, 2);
                                if (10 > $key) {
                                    /* do nothing */
                                } else {
                                    if (TRUE === array_key_exists($key, $xarray)) {
                                        $xseek = $xarray[$key];
                                        $xsub = $this->subfijo($xaux);
                                        if (20 == $key) {
                                            $xcadena = ' ' . $xcadena . ' VEINTE ' . $xsub;
                                        } else {
                                            $xcadena = ' ' . $xcadena . ' ' . $xseek . ' ' . $xsub;
                                        }
                                        $xy = 3;
                                    } else {
                                        $key = (int) substr($xaux, 1, 1) * 10;
                                        $xseek = $xarray[$key];
                                        if (20 == $key)
                                            $xcadena = ' ' . $xcadena . ' ' . $xseek;
                                        else
                                            $xcadena = ' ' . $xcadena . ' ' . $xseek . ' Y ';
                                    } // ENDIF ($xseek)
                                } // ENDIF (substr($xaux, 1, 2) < 10)
                                break;
                            case 3: // checa las unidades
                                $key = (int) substr($xaux, 2, 1);
                                if (1 > $key) { // si la unidad es cero, ya no hace nada
                                    /* do nothing */
                                } else {
                                    $xseek = $xarray[$key]; // obtengo directamente el valor de la unidad (del uno al nueve)
                                    $xsub = $this->subfijo($xaux);
                                    $xcadena = ' ' . $xcadena . ' ' . $xseek . ' ' . $xsub;
                                } // ENDIF (substr($xaux, 2, 1) < 1)
                                break;
                        } // END SWITCH
                    } // END FOR
                    $xi = $xi + 3;
                } // ENDDO
                # si la cadena obtenida termina en MILLON o BILLON, entonces le agrega al final la conjuncion DE
                if ('ILLON' == substr(trim($xcadena), -5, 5)) {
                    $xcadena.= ' DE';
                }

                # si la cadena obtenida en MILLONES o BILLONES, entonces le agrega al final la conjuncion DE
                if ('ILLONES' == substr(trim($xcadena), -7, 7)) {
                    $xcadena.= ' DE';
                }

                # depurar leyendas finales
                if ('' != trim($xaux)) {
                    switch ($xz) {
                        case 0:
                            if ('1' == trim(substr($XAUX, $xz * 6, 6))) {
                                $xcadena.= 'UN BILLON ';
                            } else {
                                $xcadena.= ' BILLONES ';
                            }
                            break;
                        case 1:
                            if ('1' == trim(substr($XAUX, $xz * 6, 6))) {
                                $xcadena.= 'UN MILLON ';
                            } else {
                                $xcadena.= ' MILLONES ';
                            }
                            break;
                        case 2:
                            if (1 > $numero) {
                                $xcadena = "CERO {$moneda} CON {$xdecimales} CENTÉSIMAS DE UNIDADES TRIBUTARIAS ( {$numero_min} {$subfijo} )";
                            }
                            if ($numero >= 1 && $numero < 2) {
                                $xcadena = "UN {$moneda} CON {$xdecimales} CENTÉSIMAS DE UNIDADES TRIBUTARIAS ( {$numero_min} {$subfijo} )";
                            }
                            if ($numero >= 2) {
                                $xcadena.= " {$moneda} CON {$xdecimales} CENTÉSIMAS DE UNIDADES TRIBUTARIAS ( {$numero_min} {$subfijo} )"; //
                            }
                            break;
                    } // endswitch ($xz)
                } // ENDIF (trim($xaux) != "")

                $xcadena = str_replace('VEINTI ', 'VEINTI', $xcadena); // quito el espacio para el VEINTI, para que quede: VEINTICUATRO, VEINTIUN, VEINTIDOS, etc
                $xcadena = str_replace('  ', ' ', $xcadena); // quito espacios dobles
                $xcadena = str_replace('UN UN', 'UN', $xcadena); // quito la duplicidad
                $xcadena = str_replace('  ', ' ', $xcadena); // quito espacios dobles
                $xcadena = str_replace('BILLON DE MILLONES', 'BILLON DE', $xcadena); // corrigo la leyenda
                $xcadena = str_replace('BILLONES DE MILLONES', 'BILLONES DE', $xcadena); // corrigo la leyenda
                $xcadena = str_replace('DE UN', 'UN', $xcadena); // corrigo la leyenda
            } // ENDFOR ($xz)
            return trim($xcadena);
        }

        /**
         * Esta función regresa un subfijo para la cifra
         * 
         * @author Ultiminio Ramos Galán <contacto@ultiminioramos.com>
         * @param string $cifras La cifra a medir su longitud
         */
        private function subfijo($cifras)
        {
            $cifras = trim($cifras);
            $strlen = strlen($cifras);
            $_sub = '';
            if (4 <= $strlen && 6 >= $strlen) {
                $_sub = 'MIL';
            }

            return $_sub;
        }
}


?>
