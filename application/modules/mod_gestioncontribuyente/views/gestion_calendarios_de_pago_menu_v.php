<?php // print(base_url()); ?>
  <style>
      #barra_cal {
        padding: 4px;
        display: inline-block;
        /*border: 2px solid black;*/
        margin-bottom: 10px;
        width: 100%
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
                    primary: 'ui-icon ui-icon-plusthick'//,
                    //secondary: 'ui-icon ui-icon-mail-closed'
            }
	});
        $("#gestiona_cal").button( {
            icons: {
                primary: 'ui-icon ui-icon-pencil'
            }
        });

          $( ".btn_cal" ).click(function() {
              $("#cuerpo_cal").html('<center><p style="font-size:14px; font-weigh:bold">Espere por favor...</p><img  src="<?php print(base_url()); ?>include/imagenes/ajax-loader.gif" /></center>');
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
          $( ".btn_cal" ).buttonset();
      });

  </script>
<div class="ui-widget-header" style="text-align:center; font-size: 12px; font-style: italic; margin-bottom: 20px; width: 80%; margin-left:10%; ">Carga del Calendario de Pagos</div>

<div id="barra_cal" class=" ">
    <!--<span id="botonera_cal">-->
    <center>
        <input type="radio" id="consulta_cal" class="btn_cal" name="boton_cal" checked="checked" /><label style=" margin-right: 20px" for="consulta_cal">CONSULTAR</label>
        <input type="radio" id="crea_cal" class="btn_cal" name="boton_cal"  /><label style=" margin-right: 20px" for="crea_cal">CREAR</label>
        <!--<input type="radio" id="gestiona_cal" class="btn_cal" name="boton_cal" /><label for="gestiona_cal">GESTION</label>-->
    </center>
        <!--</span>-->
</div>
  <div id="cuerpo_cal" class="" style="margin-top: 5px">

  </div>
