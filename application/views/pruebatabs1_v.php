<?

?>

<html>
    
   

         
<!--         <style>-->
<script>
 $(function() {
 validador('crea-tabs','<?php echo base_url()."index.php/principal1_c/insertar_hijo"; ?>','envia_tabs');

var tabs = $( "#tabs" ).tabs({

            beforeLoad: function( event, ui ) {
//                ui.jqXHR.Start(function() {
//                    $("#cargando").show();
//
//                });
                ui.jqXHR.error(function() {
                    ui.panel.html(
                        "Error al Mostrar los Datos Intente Nuevamente.." +
                        "Si Persiste el Error Comuiquese con el area de Tecnologia." );
                });

            }

        });
// modal dialog init: custom buttons and a "close" callback reseting the form inside
var dialog = $( "#dialogtabsj" ).dialog({
    autoOpen: false,
    modal: true,
    buttons: {
        Agregar: function() {
        
            $('#crea-tabs').submit();
        
        },
        Cancelar: function() {
        $( this ).dialog( "close" );
        }
    }
});

// addTab button: just opens the dialog
$( "#add_tab" )
.button()
.click(function() {
dialog.dialog( "open" );
});

     
 });   
</script>
    
<style type="text/css">
#dialogtabsj label, #dialog input { display:block; }
#dialogtabsj label { margin-top: 0.5em; }
#dialogtabsj input, #dialog textarea { width: 95%; }
#tabs { margin-top: 1em; }
#tabs li .ui-icon-close { float: left; margin: 0.4em 0.2em 0 0; cursor: pointer; }
#add_tab { cursor: pointer; }
</style>
         
        
        </head>
    
    <body>
<div id="dialogtabsj" title="Creacion de Modulos">
<form id="crea-tabs">
<fieldset class="ui-helper-reset">
<input type="text" name="idpadre" id="idpadre" value="<?php echo $padre;?>" />
<label >Nombre del sub-modulo</label>
<input type="text" name="nombreM" id="nombreM" value="" class="requerido ui-widget-content ui-corner-all" />
<label >Descripcion del sub-modulo</label>
<input type="text" name="descripcionM" id="descripcionM" value=""class="requerido ui-widget-content ui-corner-all" />
<label >Url del Metodo</label>
<input name="urlM" id="urlM" class=" requerido ui-widget-content ui-corner-all" />
</fieldset>
</form>
</div>
<button id="add_tab">Agregar</button>
<div id="tabs">
<ul>


</ul>

</div>
        
        
        
        
        </body>
    
    
    
    
    </html
