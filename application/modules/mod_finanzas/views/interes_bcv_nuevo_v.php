 <script>
    $(function() {
        ayudas('#','form_new_intbcv','bottom center','top center','slide','up');
        //funcion para la validacion
        //Parametros: id del form, url del controlador, metodo ajax para el submit del boton
        validador('form_new_intbcv','<?php echo base_url()."index.php/mod_finanzas/interes_bcv_c/agregar_interesbcv"; ?>','envio_form_intbcv');
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
            
                        <label>Mes: </label> 
                        <select id="mes" name="mes" class="requerido  ui-widget-content ui-corner-all" >
                            <option value="">Seleccione Mes</option>
                            <option value="01">Enero</option>
                            <option value="02">Febrero</option>
                            <option value="03">Marzo</option>
                            <option value="04">Abril</option>
                            <option value="05">Mayo</option>
                            <option value="06">Junio</option>
                            <option value="07">Julio</option>
                            <option value="08">Agosto</option>
                            <option value="09">Septiembre</option>
                            <option value="10">Octubre</option>
                            <option value="11">Noviembre</option>
                            <option value="12">Diciembre</option>
                        </select>
                       <label>Año: </label> 
                        <input name="anio" type="text" id="anio" class="text ui-widget-content ui-corner-all requerido" title="Ingresar Año" maxlength="4" onkeydown="return soloNumeros(this, event);" />
                       <label>Tasa: </label> 
                        <input name="tasa" type="text" id="tasa" class="text ui-widget-content ui-corner-all requerido" title="Ingresar Tasa"/>
            </form> 
