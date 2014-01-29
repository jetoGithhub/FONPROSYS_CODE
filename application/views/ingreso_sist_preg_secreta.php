<?php
if ( ! defined('BASEPATH')) exit('No esta permitido el acceso directo');
$primer_nombre = $info["nombre"];
$identificador = $info["id_usuario"];
$base_url=base_url()."index.php/";
?>
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
//                        .css('height','20px')
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
                    .addClass( "ui-combobox-input ui-corner-bl ui-corner-tl" )
                    .css('width','174px')
                    .css('height',' 19px')
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



</script>
<script type="text/javascript" >
    $(function() {
        $("#procesando-preg").hide();
        $( "#pregsecrid" ).combobox();
        $( "#toggle" ).click(function() {
            $( "#pregsecrid" ).toggle();
        });
        
        
        $("#btn-frmpregsecr").button();
        ventana_ingreso('dialogo_preg','form_new',1,true);
        $('div#dialogo_preg').dialog('open');
        
        //validador('form_new','<?php print($base_url); ?>ingreso','envia_formulario');
        
         $("#memsajerror").hide();
         validador('form_new','<?php print($base_url); ?>pregunta_secreta_c/registrarPregunta','registrar_preg_secr'); 
        
       
		
		
		$(" input ").addClass('ui-state-highlight ui-corner-all');
		$(" select ").addClass('ui-state-highlight ui-corner-all');
		
		$("#btn-frmpregsecr").click(function()
		{
			$("#form_new").submit();  
		});
		
	
		
		//atributos de mensaje de confirmacion
		$( "#confirm-pregsecr" ).dialog({   
			autoOpen:false,
			resizable: false,
			show:"clip",
			modal: true
        });
        
/*
 funcion para cargar la vista_ingreso una vez que el usuario le de clic al boton salir       
*/
        $('#btn-salir').click(function() {  
			$.ajax({  
				url: '<?php print($base_url); ?>pregunta_secreta_c',  
				success: function(data) {  
					
					window.location="<?php echo base_url() ?>";
				}  
			});  
		}); 
	
    
    
    }); 
	//fin funcion principal
	
	
	
	//funcion ajax para el registro de pregunta secreta
	registrar_preg_secr=function(form,url){
		
		$( "#confirm-pregsecr" ).dialog({   
 
                buttons: {
                    "SI": function() {
                            $(this).dialog('close');
                            
                            $.ajax({
                            type:"post",
                            data:$("#"+form).serialize(),
                            dataType:"json",
                            url:url,                           
                                success:function(data){

                                    if(data.resultado==true){                                   

										
										
                                            window.location="<?php echo base_url() ?>";						

										


                                   }else{
										$( "#confirm-pregsecr").dialog( "close" );
										$('#memsajerror').html('<p style="font-family: sans-serif;color:#CD0A0A;"><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em;"></span><strong>Alerta: </strong>Error en el registro de datos</p>')
										$("#memsajerror").addClass('ui-state-error'); 
										$("#memsajerror").css({background:'#FEF6F3',border:'1px solid #CD0A0A'});
										$("#memsajerror").show('drop',1000);
										$("#"+form).reset();
										$("#btn-frmpregsecr").removeAttr('disabled') 
                                   }
                                    
                                },
                                 beforeSend:function(){
                            
                                    $("#procesando-preg").show();
                                    $("#btn-frmpregsecr").hide();
                                    
                                },complete:function(){
                                   
                                },
                                error:function(){
                                    $("#procesando-preg").hide();
                                    $('#memsajerror').html('<p style="font-family: sans-serif;color:#CD0A0A;"><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em;"></span><strong>Alerta: </strong>Error en el registro de la pregunta secreta</p>')
                                    $("#memsajerror").addClass('ui-state-error'); 
                                    $("#memsajerror").css({background:'#FEF6F3',border:'1px solid #CD0A0A'});
                                    $("#memsajerror").show('drop',1000);
                                    $("#"+form).reset();
                                    $("#btn-frmpregsecr").show();
                                    
                                }
                            });// fin del ajax
                            

                        },
					"NO": function() {
						$( this ).dialog( "close" );
					}
                    
                }
                
            });            
			
			$('#confirm-pregsecr').html('<p><span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 0px 0;"></span><b>EL SISTEMA PROCEDERA A REGISTRAR SU PREGUNTA SECRETA.<br /> <center>Esta usted Deacuerdo?</center></b></p>')
			$("#confirm-pregsecr").dialog('open');
}

</script>

<!--encabezado-->
<img src="<?php echo base_url()."/include/imagenes/encabezado_final-1220.png"; ?>" style=" width:95%; margin-left:2%"/>

<div style="width: 4%; height: 2%; position:absolute; margin-top: -45px; margin-left: 92%; padding-top: 5px; padding-bottom: 5px ">

	<a href="#" id="btn-salir" style=" font-size: 12px; color:#D3D2D1; text-decoration:none; ">
		<b style=" margin-right: 2px;">Salir</b> 
		<span style="position:absolute; margin-top:1%; margin-left: 4px;">
				<img src="<?php echo base_url()."/include/imagenes/iconos/right_grey.png"; ?>" width="20px" height="20px"/>
		</span>
	</a>
</div>    

<div id="div_salir"></div>
<!-- mensaje de confirmacion para el registro de pregunta secreta -->
<div id="confirm-pregsecr" title="Mensaje Webmaster"></div>  

<!-- Estructura -->
<div id="dialogo_preg" title="Registro de la Pregunta Secreta">
    <form class="form-style focus-estilo" id="form_new">
            <table border="0">
<!--				<tr>
					<td colspan="2">
						<span style="font-size:11px;">
							<center>Por favor registre una pregunta secreta <br> para poder ingresar al sistema</center>
						</span>
					</td>
				</tr>-->
				<tr><td>&nbsp;</td></tr>
				<tr>
					<td>
						<img src="<?php echo base_url()."/include/imagenes/signo7.png"; ?>" width="100px"/>
                    </td>
					
					<td>
						<table border="0">
							  <tr><td>
									<label for="pregunta">Pregunta Secreta</label>
										<select id="pregsecrid" name="pregsecrid" class="requerido  ui-widget-content " style=" width: 90%; height: 20px" >
											<option value="">Seleccione su Pregunta</option>
												<?php
													if (sizeof($preguntaSecreta)>0):
														foreach ($preguntaSecreta as $pregunta):
														print("<option value='$pregunta[id]'>$pregunta[nombre]</option>");
														endforeach;
													endif;
												?>            
										</select>
								  </td></tr> 
								
								<tr><td>
                                                                        Respuesta: </br> 
									<input name="respuesta" type="password" id="respuesta" size="40" class="text ui-widget-content ui-corner-all requerido" title="Ingresar respuesta de seguridad"/>
									</td>
								</tr>
                                                                <tr><td>
                                                                        Repita la Respuesta: </br> 
									<input name="respuestaR" condicion='equalTo:respuesta' type="password" id="respuestaR" size="40" class="text ui-widget-content ui-corner-all requerido" title=""/>
									</td>
								</tr>
						</table>
					</td>
				</tr>
                
            </table>
            <input name="identificador" type="hidden" value="<?php echo $identificador; ?>" />
            <input name="ingreso_sistema" type="hidden" value="t" />
     
    </form> 
    
    <br />
    
    <button id="btn-frmpregsecr" style="margin-left: 250px; position: relative" title="Registrar">Registrar</button>
    <div style="padding: 0 .7em; width: 250px; margin-top: 25px;" class="ui-corner-all" id="memsajerror"></div>
    <div id="procesando-preg" style=" float: left;margin-top: -30px; margin-left: 100px"><center><img  src="./include/imagenes/loader.gif" width=25px; height=25px; style="margin-left:0px; margin-top: 0px" /><br /><p style=" width:120px;">Procesando.</p></center></div>
            
</div>


<!-- Pie de página -->
<div style="border: 0px solid red; bottom: 0px; margin-top: 62%; position: absolute; width: 100%">
    <center><img src="<?php echo base_url()."/include/imagenes/pie_new_usar_boton.png"; ?>" style=" width: 95%"/></center>
</div>

<!-- Estilos aplicados solo a esta página -->
<style>    
 /*#dialogo_preg input  select {margin-bottom:12px; width:95%; padding: .2em;  font-family: sans-serif, monospace; font-size: 12px}*/
 #dialogo_preg label{ display:block;}
#btn_inicia_cont{ float:right; }   

#btn_registro_cont{ margin-left: 25%; margin-top: 10%; } 
.form-style input label { display:block;}
.form-style td,label{ font-weight: bold; margin-bottom: 5px}
.form-style input { margin-bottom:12px; width:95%; padding: .2em;  font-family: sans-serif, monospace; font-size: 14px }
 .focus-estilo input:focus{
      border-color: #BF4639;
      /*border:none;*/
      outline:0px;/* elimina bordes en crom safari y firefox*/
      box-shadow: 1px 1px 7px   #BF4639;
    -webkit-box-shadow:  1px 1px 7px  #BF4639;
    -moz-box-shadow:  1px 1px 7px   #BF4639 ;
}
.ui-dialog{
    
  max-width: 50%
}
 .custom-combobox {
position: relative;
display: inline-block;
}
.custom-combobox-toggle {
position: absolute;
top: 0;
bottom: 0;
margin-left: -1px;
padding: 0;
/* support: IE7 */
/**height: 1.7em;
*top: 0.1em;*/
}
.custom-combobox-input {
margin: 0;
padding: 0.0em;
}
.ui-combobox-toggle {
        /*position: absolute;*/
        top: -1px;
        bottom: 0;
        margin-left:-2px;
        padding: 0;
        /* adjust styles for IE 6/7 */
        height: 23px;
        /**top: 0.1em;*/
    }
</style>
