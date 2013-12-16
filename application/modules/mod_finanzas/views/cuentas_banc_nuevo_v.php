 <script>
    $(function() {
        ayudas('#','form_new_cuentasbanc','bottom center','top center','slide','up');
        //funcion para la validacion
        //Parametros: id del form, url del controlador, metodo ajax para el submit del boton
        validador('form_new_cuentasbanc','<?php echo base_url()."index.php/mod_finanzas/cuentas_banc_c/agregar_cuentasbanc"; ?>','envio_form_cuentasbanc');
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

       <form class="form-style focus-estilo" id="form_new_cuentasbanc">
            
                        <label>Número de Cuenta: </label> 
                        <input name="num_cuenta" type="text" id="num_cuenta" class="text ui-widget-content ui-corner-all requerido" title="Ingresar Número de Cuenta" onkeydown="return soloNumeros(this, event);" />
                       <label>Tipo de Cuenta: </label> 
                        <select id="tipo_cuenta" name="tipo_cuenta" class="requerido  ui-widget-content ui-corner-all" >
                            <option value="">Seleccione Tipo de Cuenta</option>
                            <option value="CORRIENTE">CORRIENTE</option>
                            <option value="AHORRO">AHORRO</option>
                        </select>
                       <label>Entidad Bancaria: </label> 
                        <select id="bancoid" name="bancoid" class="requerido  ui-widget-content ui-corner-all" >
                            <option value="">Seleccione el Banco</option>
                                <?php
                                    if (sizeof($bancos)>0):
                                        foreach ($bancos as $banc):
                                        print("<option value='$banc[id]'>$banc[nombre]</option>");
                                        endforeach;
                                    endif;
                                ?>            
                        </select>
            </form> 
