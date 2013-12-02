<?php
if ( ! defined('BASEPATH')) exit('No esta permitido el acceso directo');
$primer_nombre = $info["nombre"];
$identificador = $info["id_usuario"];
$base_url=base_url()."index.php/";
?>
<script type="text/javascript" >
    $(function() {
        
        
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
                        
                            $.ajax({
                            type:"post",
                            data:$("#"+form).serialize(),
                            dataType:"json",
                            url:url,                           
                                success:function(data){

                                    if(data.resultado==true){
                                     

										$("#confirm-pregsecr").dialog( "close" ); 
										alert('La información fue registrada exitosamente');
										window.location="<?php echo base_url() ?>";
/*
										$('#memsajerror').html('<p style="font-family: sans-serif; color:#3C3B37"><span class="ui-icon ui-icon-info" style="float: left; margin-right: .3em;"></span>Pregunta secreta registrada con exito.</p>')
										$("#memsajerror").addClass('ui-state-highlight'); 
										$("#memsajerror").css({background:'#FAF9EE',border:'1px solid #FCF0A8'});
										$("#memsajerror").show('drop',1000);    
										$("#"+form).reset();
										$("#btn-ingresar").removeAttr('disabled'); //elimina el atributo disabled 
										$("#btn-frmpregsecr").attr('disabled','-1'); //deshabilita un boton-no es necesario colocar el atributo disabled
*/
										


                                   }else{
										$( "#confirm-pregsecr").dialog( "close" );
										$('#memsajerror').html('<p style="font-family: sans-serif;color:#CD0A0A;"><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em;"></span><strong>Alerta: </strong>Error en el registro de datos</p>')
										$("#memsajerror").addClass('ui-state-error'); 
										$("#memsajerror").css({background:'#FEF6F3',border:'1px solid #CD0A0A'});
										$("#memsajerror").show('drop',1000);
										$("#"+form).reset();
										$("#btn-frmpregsecr").removeAttr('disabled') 
                                   }
                                    
                                }
                            });// fin del ajax
                            

                        },
					"NO": function() {
						$( this ).dialog( "close" );
					}
                    
                }
                
            });            
			
			$('#confirm-pregsecr').html('<span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 0px 0;"></span><b>DESEA REGISTRAR SU PREGUNTA SECRETA?</b>')
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
<div id="dialogo_preg" title="Registro Pregunta Secreta">
    <form class="form-style focus-estilo" id="form_new">
            <table border="0">
				<tr>
					<td colspan="2">
						<span style="font-size:11px;">
							<center>Por favor registre una pregunta secreta <br> para poder ingresar al sistema</center>
						</span>
					</td>
				</tr>
				<tr><td>&nbsp;</td></tr>
				<tr>
					<td>
						<img src="<?php echo base_url()."/include/imagenes/signo7.png"; ?>" width="100px"/>
                    </td>
					
					<td>
						<table border="0">
							  <tr><td>
									<label for="pregunta">Pregunta Secreta</label>
										<select id="pregsecrid" name="pregsecrid" class="requerido  ui-widget-content ui-corner-all" >
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
								
								<tr><td></br>Respuesta: </br> 
									<input name="respuesta" type="text" id="respuesta" size="40" class="text ui-widget-content ui-corner-all requerido" title="Ingresar respuesta de seguridad"/>
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

</style>
