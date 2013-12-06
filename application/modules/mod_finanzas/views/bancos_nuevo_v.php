 <script>
    $(function() {
        ayudas('#','form_new_bancos','bottom center','top center','slide','up');
        //funcion para la validacion
        //Parametros: id del form, url del controlador, metodo ajax para el submit del boton
        validador('form_new_bancos','<?php echo base_url()."index.php/mod_finanzas/bancos_c/agregar_bancos"; ?>','envio_form_bancos');
        //funcion para el cambio de estilo de los radiobutton
        $( "#radio" ).buttonset();
		
	});

</script>

       <form class="form-style focus-estilo" id="form_new_bancos">
            <label>Nombre: </label> 
            <input name="nombre" type="text" id="nombre" class="text ui-widget-content ui-corner-all requerido" title="Ingresar Nombre del Banco" style="text-transform:uppercase;" onkeyup="javascript:this.value=this.value.toUpperCase();" />
