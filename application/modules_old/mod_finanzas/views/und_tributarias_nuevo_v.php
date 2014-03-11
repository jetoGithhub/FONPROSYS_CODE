 <script>
    $(function() {
        ayudas('#','form_new_undtrib','bottom center','top center','slide','up');
        //funcion para la validacion
        //Parametros: id del form, url del controlador, metodo ajax para el submit del boton
        validador('form_new_undtrib','<?php echo base_url()."index.php/mod_finanzas/und_tributarias_c/agregar_undtributarias"; ?>','envio_form_undtributarias');
        //funcion para el cambio de estilo de los radiobutton
        $( "#radio" ).buttonset();
		
	});
	
	//funcion para validar que el campo valor, acepte solo numeros decimales con punto
	function decimales(e){
		obj=e.srcElement || e.target;
		tecla_codigo = (document.all) ? e.keyCode : e.which;
		if(tecla_codigo==8)return true;
		patron =/[\d.]/;
		tecla_valor = String.fromCharCode(tecla_codigo);
		control=(tecla_codigo==46 && (/[.]/).test(obj.value))?false:true
		return patron.test(tecla_valor) &&  control;
	}

	
	
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

       <form class="form-style focus-estilo" id="form_new_undtrib">

                       <label>Valor: </label> 
                         <input name="valor" type="text" id="valor" class="text ui-widget-content ui-corner-all requerido" title="Ingresar Valor" onkeypress="return decimales(event)"/>
            
                       <label>Año: </label> 
                       <input name="anio" type="text" id="anio" class="text ui-widget-content ui-corner-all requerido" title="Ingresar Año" maxlength="4" onkeydown="return soloNumeros(this, event);" />
                      
                        
            </form> 
