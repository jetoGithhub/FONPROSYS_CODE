 <script>
    $(function() {
        ayudas('#','form_activo_presidentes','bottom center','top center','slide','up');
        //funcion para la validacion
        //Parametros: id del form, url del controlador, metodo ajax para el submit del boton
        validador('form_activo_presidentes','<?php echo base_url()."index.php/mod_administrador/presidentescnac_c/agregar_presidente_activo"; ?>','envio_form_presidentes');
        //funcion para el cambio de estilo de los radiobutton
        $( "#radio" ).buttonset();
		
	});

</script>

       <form class="form-style focus-estilo" id="form_activo_presidentes">
            <label>Nombre: </label> 
            <input name="nombres" type="text" id="nombres" class="text ui-widget-content ui-corner-all requerido" title="Ingresar Nombre del Presidente" />
			
			<label>Apellidos: </label> 
			<input name="apellidos" type="text" id="apellidos" class="text ui-widget-content ui-corner-all requerido" title="Ingresar Apellido del Presidente" />

			<label>Cedula: </label> 
			<input name="cedula" type="text" id="cedula" class="text ui-widget-content ui-corner-all requerido" title="Ingresar Cedula del Presidente" />

			<label>Nro. Decreto: </label> 
			<input name="nro_decreto" type="text" id="nro_decreto" class="text ui-widget-content ui-corner-all requerido" title="Ingresar Numero de Decreto" />

			<label>Nro. Gaceta: </label> 
			<input name="nro_gaceta" type="text" id="nro_gaceta" class="text ui-widget-content ui-corner-all requerido" title="Ingresar Numero de Gaceta" />

			<label>Fecha Gaceta: </label> 
			<input name="dtm_fecha_gaceta" type="text" id="dtm_fecha_gaceta" class="text ui-widget-content ui-corner-all requerido" title="Seleccionar Fecha de Gaceta" />
