<?php // print(base_url()); ?>
  <style>
      #barra_cal {
        padding: 4px;
        display: inline-block;
      }
      /* support: IE7 */
      *+html #barra_cal {
        display: inline;
      }
      #cuerpo_cal{
          width:100%;
          display:block;
      }
  </style>
  <script>
      $(function() {
          $("#consulta_cal").button({
              icons: {
                    primary: 'ui-icon ui-icon-search'
            }
		
	});
	
	$("#crea_cal").button({
            icons: {
                    primary: 'ui-icon ui-icon-pencil'//,
                    //secondary: 'ui-icon ui-icon-mail-closed'
            }
	});
        $("#gestiona_cal").button( {
            icons: {
                primary: 'ui-icon ui-icon-refresh'
            }
        });

          $( ".btn_cal" ).click(function() {
              $("#cuerpo_cal").html('Espere procesando envio...<img  src="<?php print(base_url()); ?>include/imagenes/ajax-loader.gif" />');
              $("#cuerpo_cal").load(
              "<?php print(base_url().'index.php/mod_gestioncontribuyente/gestion_calendarios_de_pago_c/'); ?>"+this.id, 
              function(response, status, xhr) {
                  if (status == "error") {
                      var msg = "ERROR AL CONECTAR AL SERVIDOR:";
                      $("#cuerpo_cal").html('')
                      $("#dialog-alert")
                      .children("#dialog-alert_message")
                      .html(msg + xhr.status + " " + xhr.statusText);
                      $("#dialog-alert").dialog("open");
                  }
              });  
          });
          
          $( ".btn_cal" ).button();
          $( "#botonera_cal" ).buttonset();
      });

  </script>

<div id="barra_cal" class="ui-widget-header ui-corner-all">
    <span id="botonera_cal">
        <input type="radio" id="consulta_cal" class="btn_cal" name="boton_cal" checked="checked" /><label for="consulta_cal">Consultar</label>
        <input type="radio" id="crea_cal" class="btn_cal" name="boton_cal"  /><label for="crea_cal">Crear</label>
        <input type="radio" id="gestiona_cal" class="btn_cal" name="boton_cal" /><label for="gestiona_cal">Gestion</label>
    </span>
</div>
  <div id="cuerpo_cal" class="ui-widget-content ui-corner-all">

  </div>
