 <script>
    $(function() {
        ayudas('#','form_new_intbcv','bottom center','top center','slide','up');
        //funcion para la validacion
        //Parametros: id del form, url del controlador, metodo ajax para el submit del boton
        validador('form_new_intbcv','<?php echo base_url()."index.php/mod_gestioncontribuyente/interes_bcv_c/agregar_interesbcv"; ?>','envio_form_intbcv');
        //funcion para el cambio de estilo de los radiobutton
        $( "#radio" ).buttonset();
		
	});
	
	//funcion para validar el campo de anio para que acepte solo numeros
	soloNumeros=function(obj, e)
	{
		var keynum

		 if(window.event){ /*/ IE*/
			keynum = e.keyCode
		 }
		 else if(e.which){ /*/ Netscape/Firefox/Opera/*/
			 keynum = e.which
		 }
	  
		 if((keynum>=35 && keynum<=37) ||keynum==8||keynum==9||keynum==46||keynum==39) {
			  return true;
		 }
		 if((keynum>=95&&keynum<=105)||(keynum>=48&&keynum<=57)){
			 return true;
		 }else {
			 return false;
		 }

	}


</script>

       <form class="form-style focus-estilo" id="form_new_intbcv">
            <table border="0">
                <tr><td>Mes: </br> 
                        <select id="mes" name="mes" class="requerido  ui-widget-content ui-corner-all" >
                            <option value="">Seleccione Mes</option>
                            <option value="Enero">Enero</option>
                            <option value="Febrero">Febrero</option>
                            <option value="Marzo">Marzo</option>
                            <option value="Abril">Abril</option>
                            <option value="Mayo">Mayo</option>
                            <option value="Junio">Junio</option>
                            <option value="Julio">Julio</option>
                            <option value="Agosto">Agosto</option>
                            <option value="Septiembre">Septiembre</option>
                            <option value="Octubre">Octubre</option>
                            <option value="Noviembre">Noviembre</option>
                            <option value="Diciembre">Diciembre</option>
                        </select>
                    </td>
                </tr>
                <tr><td>Año: </br> 
                        <input name="anio" type="text" id="anio" size="20" class="text ui-widget-content ui-corner-all requerido" title="Ingresar Año" maxlength="4" onkeydown="return soloNumeros(this, event);" />
                    </td>
                </tr>
                <tr><td>Tasa: </br> 
                        <input name="tasa" type="text" id="tasa" size="20" class="text ui-widget-content ui-corner-all requerido" title="Ingresar Tasa"/>
                    </td>
                </tr>

                </br>
                

            </table>
            </form> 
