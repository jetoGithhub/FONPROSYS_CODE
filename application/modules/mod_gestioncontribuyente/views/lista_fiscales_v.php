<script>
    $('#prioridad_fiscal_btn').button();
    $("#prioridad_fiscal_btn").click(function(){
        if($('#prioridad_fiscal').val()==1){
            $('#prioridad_fiscal').val(0);
            $('#prioridad_fiscal_btn').find('.ui-button-text').html('Normal');
        }else
        if($('#prioridad_fiscal').val()==0){
            $('#prioridad_fiscal').val(1);
            $('#prioridad_fiscal_btn').find('.ui-button-text').html('<font color="red"><b>Urgente</b></font>');
        }       
    });   
    envia_asigna_fiscal = function(form,url){
        $.ajax({
        global:false,
        type:"post",
        data:$('#'+form).serialize(),
        dataType:"json",
        url:url,
        success:function(data){
            if(data.succes){
                
                $( "#lista_fiscales_omisos_fiscalizacion" ).dialog('close');
//                revisa_asigna_omisos_fiscalizacion();
                ejecutaBusquedadOmisos();                
                $("#revisa_asigna_omisos_fiscalizacion").html('<font color="green"><b>'+data.mensaje+'</b></font>');
                $("#revisa_asigna_omisos_fiscalizacion").show("slide", { direction: "up" }, 1000);
//                setTimeout(function(){
//                    $("#revisa_asigna_omisos_fiscalizacion").hide("slide", { direction: "up" }, 1000);
//                }, 4000);                
            }else{
                $("#revisa_asigna_omisos_fiscalizacion").html(data.mensaje);
//                setTimeout(function(){
//                    $("#revisa_asigna_omisos_fiscalizacion").hide("slide", { direction: "up" }, 1000);
//                }, 4000);                  
            }
            

        },
        error: function (request, status, error) {
          
          var html='<p style=" margin-top: 15px">';
              html+='<span class="ui-icon ui-icon-alert" style="float: left; margin: 0 7px 50px 0;"></span>';
              html+='Disculpe ocurrio un error de conexion intente de nuevo <br /> <b>ERROR:"'+error+'"</b>';
              html+='</p><br />';
              html+='<center><p>';
              html+='<b>Si el error persiste comuniquese al correo soporte@cnac.gob.ve</b>';
              html+='</p></center>';
           $("#dialogo-error-conexion").html(html);
           $("#dialogo-error-conexion").dialog('open');
       }
    });
  };
    validador('fiscales_asigna_agrega_omisos_fiscalizacion','<?php print(base_url().'index.php/mod_gestioncontribuyente/lista_contribuyentes_general_c/asigna_fiscalizaciones'); ?>','envia_asigna_fiscal');
          $( "#fecha_fiscaliza" ).datepicker();
          $( "#fecha_fiscaliza" ).datepicker( "option", "showAnim",'slideDown');
          $('#fecha_fiscaliza').datepicker('option', {dateFormat: 'yy-mm-dd'});
          $.datepicker.setDefaults( $.datepicker.regional[ "" ] );
          $( "#fecha_fiscaliza" ).datepicker( $.datepicker.regional[ "es" ] );

</script>
<?php
//    print_r($lista_fiscales);
//print(json_encode($lista_fiscales));
    
?>
<form class="form-style focus-estilo" id="fiscales_asigna_agrega_omisos_fiscalizacion" style=" width: 85%; margin-left: 20px">
    <center><label for="num_asignaciones">N°  de asignaciones:</label><?php print( sizeof($asigna_fiscal) ); ?></center>  
    <br />
    <label for="fiscales"><b>Fiscales</b></label>
     <select id="fiscal" name="fiscal" class=" requerido  ui-widget-content ui-corner-all">
            <option value="" >Seleccione</option>
            <?php
            foreach ($lista_fiscales as $indice=>$valor):
             ?>
            <option value="<?php print($valor['id']);?>"><?php print($valor['nombre']);?></option>
            <?php
            endforeach;
            ?>
    </select>
     <label for="fecha_fiscaliza">Fecha Fiscalizacion:</label>              
     <input type="text" name="fecha_fiscaliza"  id="fecha_fiscaliza" class=" requerido  ui-widget-content ui-corner-all" /><br/>
     <label for="prioridad">Prioridad:</label><br />
    
     <button id="prioridad_fiscal_btn" type="button" >Normal</button><br/>       
     <input type="hidden" name="prioridad_fiscal"  id="prioridad_fiscal"value="0" />
            
   
    <?php foreach ($asigna_fiscal as $contenido):?>
             <input type="hidden" name="asignaciones[]" value="<?php print($contenido); ?>"/>
    <?php endforeach;?>
             
    <?php foreach ($periodo_fiscalizar as $valor):?>
            <input type="hidden" name="periodos[]" value="<?php print($valor); ?>"/>
    <?php endforeach;?>
</form>

<div id="juju"></div>