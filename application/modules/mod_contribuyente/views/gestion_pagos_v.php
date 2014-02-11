<style>
    .ui-combobox {
        position: relative;
        display: inline-block;
    }
    .ui-combobox-toggle {
        position: absolute;
        top: 0;
        bottom: 0;
        margin-left: -1px;
        padding: 0;
        /* adjust styles for IE 6/7 */
        /*height: 1.7em;
        *top: 0.1em;*/
    }
    .ui-combobox-input {
        margin: 0;
        padding: 0.3em;
        
    }
  
    </style>
    <script>
   (function( $ ) {
        var n=$(this).attr("name");
        $.widget( "ui.combobox", {
            _create: function() {
                var n=$(this.element).attr("id");
                var t=$(this.element).attr("title");
                var input,
                    that = this,
                    select = this.element.hide(),
                    selected = select.children( ":selected" ),
                    value = selected.val() ? selected.text() : "",
                    wrapper = this.wrapper = $( "<span>" )
                        .addClass( "ui-combobox" )
                        .insertAfter( select );
 
                function removeIfInvalid(element) {
                    var value = $( element ).val(),
                        matcher = new RegExp( "^" + $.ui.autocomplete.escapeRegex( value ) + "$", "i" ),
                        valid = false;
                    select.children( "option" ).each(function() {
                        if ( $( this ).text().match( matcher ) ) {
                            this.selected = valid = true;
                            return false;
                        }
                    });
                    if ( !valid ) {
                        // remove invalid value, as it didn't match anything
                        $( element )
                            .val( "" )
                            .attr( "title", value + " no coincide con la busqueda" )
                            .tooltip( "open" );
                        select.val( "" );
                        setTimeout(function() {
                            input.tooltip( "close" ).attr( "title", "" );
                        }, 2500 );
                        input.data( "autocomplete" ).term = "";
                        return false;
                    }
                }
 
                input = $( "<input>" )                    
                    .appendTo( wrapper )
                    .val( value )
                    .attr( "name",n+"input" )
                    .attr("title",t)
                    .attr("id",n+"input")
                    .addClass( "ui-state-default ui-combobox-input" )
                    .autocomplete({
                        delay: 0,
                        minLength: 0,
                        source: function( request, response ) {
                            var matcher = new RegExp( $.ui.autocomplete.escapeRegex(request.term), "i" );
                            response( select.children( "option" ).map(function() {
                                var text = $( this ).text();
                                if ( this.value && ( !request.term || matcher.test(text) ) )
                                    return {
                                        label: text.replace(
                                            new RegExp(
                                                "(?![^&;]+;)(?!<[^<>]*)(" +
                                                $.ui.autocomplete.escapeRegex(request.term) +
                                                ")(?![^<>]*>)(?![^&;]+;)", "gi"
                                            ), "<strong>$1</strong>" ),
                                        value: text,
                                        option: this
                                    };
                            }) );
                        },
                        select: function( event, ui ) {
                            ui.item.option.selected = true;
                            that._trigger( "selected", event, {
                                item: ui.item.option
                            });
                        },
                        change: function( event, ui ) {
                            if ( !ui.item ){
//                                alert(this.value);
                                return removeIfInvalid( this );
                        }
//                        else{
//                            alert(this.value);
//                            comision(this.value);                      
//                        }
                        }
                    })
                    .addClass( "ui-widget ui-widget-content ui-corner-left" );
 
                input.data( "autocomplete" )._renderItem = function( ul, item ) {
                    return $( "<li>" )
                        .data( "item.autocomplete", item )
                        .append( "<a>" + item.label + "</a>" )
                        .appendTo( ul );
                };
 
                $( "<a>" )
                    .attr( "tabIndex", -1 )
                   
                    .tooltip()
                    .appendTo( wrapper )
                    .button({
                        icons: {
                            primary: "ui-icon-triangle-1-s"
                        },
                        text: false
                    })                    
                    .removeClass( "ui-corner-all" )
                    .addClass( "ui-corner-right ui-combobox-toggle" )
                    .click(function() {
                        // close if already visible
                        if ( input.autocomplete( "widget" ).is( ":visible" ) ) {
                            input.autocomplete( "close" );
                            removeIfInvalid( input );
                            return;
                        }
 
                        // work around a bug (likely same cause as #5265)
                        $( this ).blur();
 
                        // pass empty string as value to search for, displaying all results
                        input.autocomplete( "search", "" );
                        input.focus();
                    });
 
                    input
                        .tooltip({
                            position: {
                                  my: "center bottom",
                                 at: "center top-10"
                            },
                            tooltipClass: "ui-state-highlight"
                        });
            },
 
            destroy: function() {
                this.wrapper.remove();
                this.element.show();
                $.Widget.prototype.destroy.call( this );
            }
        });
    })( jQuery );
 
    $(function() {
        $( "#tipo_pago" ).combobox();
        $( "#toggle" ).click(function() {
            $( "#tipo_pago" ).toggle();
        });
        $('#buscar_tipo_pago').button({
                           icons: {
                           primary: "ui-icon-search"
                           },
                           text: false
                           });
        $("#respuesta_buscar_tipo_pago").hide();
        $("#respuesta_detalles").hide();
        $("#respuesta_mensage").hide();
    });
    
    </script>
    <label><b>Selecione el tipo de pago:</b></label><br />
    <select  name="tipo_pago" id="tipo_pago" title="Seleccione el estatus">
        <option  ></option>
        <option value="1" >AUTOLIQUIDACIONES</option>
        <option value="6" >SUSTITUTIVAS</option>
        <option value="2">REPAROS FISCALES</option>
        <option value="3" >RESOLUCION POR EXTEMPORANEIDAD</option>
        <option value="4" >CULMINATORIA DE FISCALIZACION</option>
        <option value="5" >CULMINATORIA DE SUMARIO</option>
        <!--<option value="notificado" >NOTIFICADO</option>-->
        



    </select>
    <button id="buscar_tipo_pago" onclick="buscar_tipo_pago();" style="width: 25px; height: 25px; margin-left:5%;"></button>
<!--    <div id="botonera_reportes" style="float: right">
        <button id="btn_pdf" style=" width: auto; height: 25px">Generar PDF</button>
       <button id="btn_excel" style=" width: auto; height: 25px">Hoja calculo</button>
        
    </div>-->
    <div id="respuesta_mensage" class="ui-state-error ui-corner-all" style=" width: 200px; height: auto; text-align: center; margin-top: 2%" ></div>
    <div id="respuesta_detalles" style="  margin-top: 2%"></div> 
     <div id="respuesta_buscar_tipo_pago" style=" margin-top: 2%">
         
     </div>
    <br /><br />
</html>
<script>
    
//    $("#buscar_tipo_pago").click(function(){
     buscar_tipo_pago=function(efecto){   
        if($("#tipo_pagoinput").val()==""){
            
            $("#respuesta_mensage").html("<p>Debe selecionar un tipo de pago</p>");
            $("#respuesta_mensage").show('slide',{ direction: "up" },500);
            
        }else{
            
            if(efecto==null){
             $("#respuesta_buscar_tipo_pago").hide();
             $("#respuesta_detalles").hide();
             $("#respuesta_mensage").hide();
            }
//            alert($("#tipo_pagoinput").val())
            $.ajax({
                    type:'post',
                    data:{estatus:$("#tipo_pago").val()},
                    dataType:'json',
                    url:'<?php echo base_url()."index.php/mod_contribuyente/gestion_pagos_c/carga_pagos_pendientes/"?>',
                    success:function(recibe_ctrl)
                    {
                        if(recibe_ctrl.resultado){
                            
                            $("#respuesta_buscar_tipo_pago").html(recibe_ctrl.html);
                            $("#respuesta_buscar_tipo_pago").show('slide',{ direction: "up" }); 
//                           $("#botonera_reportes").show('slide',{ direction: "up" })
                        }

                    }
                });
            
        }
         
//    });
}

   
    
</script>



