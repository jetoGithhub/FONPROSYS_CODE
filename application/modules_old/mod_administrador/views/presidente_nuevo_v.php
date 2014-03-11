 <script>
    $(function() {
        ayudas('#','form_new_presidentes','bottom center','top center','slide','up');
        ayudas_input('#','form_new_presidentes');
        //funcion para la validacion
        //Parametros: id del form, url del controlador, metodo ajax para el submit del boton
        validador('form_new_presidentes','<?php echo base_url()."index.php/mod_administrador/presidentescnac_c/agregar_presidentes"; ?>','envio_form_presidentes');
        //funcion para el cambio de estilo de los radiobutton
        $( "#radio" ).buttonset();
        $( "#dtm_fecha_gaceta" ).datepicker({
            dateFormat: 'yy-mm-dd',
            dayNamesMin: [ "Do", "Lu", "Ma", "Mi", "Ju", "Vi", "Sa" ],
            monthNames: [ "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre" ],
            monthNamesShort: [ "Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sept", "Oct", "Nov", "Dic" ],
            yearRange: "1900:<?php echo date('Y');?>",
            changeMonth: true,
            changeYear: true
        });
        jQuery(function($){
        $.mask.definitions['#'] = '[VEve]';
        $("#cedula").mask("#-999999?99");
               

        });
	
    });

</script>

       <form class="form-style focus-estilo" id="form_new_presidentes">
            <label>Nombre: </label> 
            <input name="nombres" type="text" id="nombres" class="text ui-widget-content ui-corner-all requerido" title="Ingresar Nombre del Presidente" />
			
			<label>Apellidos: </label> 
			<input name="apellidos" type="text" id="apellidos" class="text ui-widget-content ui-corner-all requerido" title="Ingresar Apellido del Presidente" />

			<label>Cedula: </label> 
			<input name="cedula" type="text" id="cedula" class="ayuda-input text ui-widget-content ui-corner-all requerido" title="Ingresar Cedula del Presidente" txtayudai="Campo para colocar el documentos de identidad ejemplo V o E indistintamente de mayusculas y minusculas seguidas de un guion " />

			<label>Nro. Decreto: </label> 
			<input name="nro_decreto" type="text" id="nro_decreto" class="text ui-widget-content ui-corner-all requerido" title="Ingresar Numero de Decreto" />

			<label>Nro. Gaceta: </label> 
			<input name="nro_gaceta" type="text" id="nro_gaceta" class="text ui-widget-content ui-corner-all requerido" title="Ingresar Numero de Gaceta" />

			<label>Fecha Gaceta: </label> 
			<input name="dtm_fecha_gaceta" type="text" id="dtm_fecha_gaceta" class="text ui-widget-content ui-corner-all requerido" title="Seleccionar Fecha de Gaceta" />
                        
        </form>
