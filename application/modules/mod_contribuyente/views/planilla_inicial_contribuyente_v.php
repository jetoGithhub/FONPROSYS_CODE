
<script>
function bloqueaInputs(form,tipo)
{

	var aqEstado = 'X'//rtrim(document.Cliente.AQESTADO.value);

	if(aqEstado == "X")
	{
		var formCliente = document.getElementById(form); //--> donde Cliente es es form
		Elementos1 = document.getElementsByTagName("input"); //--> donde Elementos es un array que lo declaramos así directamente
		Elementos2 = document.getElementsByTagName("textarea");
                Elementos3 = document.getElementsByTagName("select");//--> donde input son el tipo de elementos de la página que queremos deshabilitar
		var i=0;
                
		for(i=0; i<Elementos1.length; i++)
		{
                    if(Elementos1[i].getAttribute('type')!='checkbox'){
                        
                        if(tipo==false ){ 
                            Elementos1[i].disabled =false;
                        }else{ 
                            Elementos1[i].disabled = true;
                        }
                        
                    }else{
                        
                        Elementos1[i].disabled = true; 
                        
                    }
		}
 		for(i=0; i<Elementos2.length; i++)
		{
                    if(tipo==false){ 
                        Elementos2[i].disabled =false;
                    }else{ 
                        Elementos2[i].disabled = true;
                    }
		}
		for(i=0; i<Elementos3.length; i++)
		{
                    if(tipo==false){ 
                        Elementos3[i].disabled =false;
                    }else{ 
                        Elementos3[i].disabled = true;
                    }
		}   
	}

}    
    $(function() {

 $(".subir").hide(); //Esto hace que el div Inicialice Oculto
    $(function () {
        $(window).scroll(function () {
            if ($(this).scrollTop() > 100) { //Esto hace que el Div aparezca de despues de haber bajado 100px con el scroll
                $('.subir').fadeIn(); //Aparece con un efecto Fade
            } else {
                $('.subir').fadeOut(); // Desaparece con un efecto Fade
            }
        });
        $('.subir a').click(function () {
            $('body,html').animate({
                scrollTop: 0
            }, 500); // Todo esto hace que se la pagina se desplace hasta el tope con una lentitud de 500 milisegundos
            return false;
        });
    });
         $('#btn_edita_planilla').click(function () {
            $(" input ").removeClass('ui-state-highlight ui-corner-all');
            $(" select ").removeClass('ui-state-highlight ui-corner-all');
            $(" textarea ").removeClass('ui-state-highlight ui-corner-all');
            bloqueaInputs('form_registra_planilla',false);
            document.getElementById("btn_registro_planilla").disabled='';
//            $( "#fregistro" ).datepicker();
            $( "#fregistro" ).datepicker( "option", "showAnim",'slideDown');
            $('#fregistro').datepicker({
                dateFormat: 'yy-mm-dd',
                dayNamesMin: [ "Do", "Lu", "Ma", "Mi", "Ju", "Vi", "Sa" ],
                monthNames: [ "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre" ],
                monthNamesShort: [ "Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sept", "Oct", "Nov", "Dic" ],
                yearRange: "1900:<?php echo date('Y');?>",
                changeMonth: true,
                changeYear: true
            });
//            $.datepicker.setDefaults( $.datepicker.regional[ "" ] );
//            $( "#fregistro" ).datepicker( $.datepicker.regional[ "es" ] );
            $("#fregistro").val('<?php echo  $infoplanilla['rmfechapro']; ?>');
        });       
//       $( document ).tooltip({
//      track: true
//    });
//    $( "<button>" )
//      .text( "Show help" )
//      .button()
//      .click(function() {
//        tooltips.tooltip( "open" );
//      })
//      .insertAfter( "form" );

           $( "#confirma-planilla" ).dialog({                
                autoOpen: false, 
                resizable: false,

                modal: true,
                buttons: {
                    "SI": function() {
                        $( this ).dialog( "close" );

                        $("#form_registra_planilla").submit();

                        },
                    "NO": function() {
                        $( this ).dialog( "close" );
                        }
                    }
                }).html('<h3>Procedera a registrar sus Datos. ¿Desea continuar?</h3>');
      validador('form_registra_planilla','<?php echo base_url()."index.php/mod_contribuyente/contribuyente_c/registro_planilla_inicial"; ?>','registra_planilla');
      
        registra_planilla = function(form,url){
            //alert($('#'+form).serialize())
            var cajas=0;
//            alert ($('#id_contribu').val())
            if($('#id_contribu').val()==""){
                
                $("#form_registra_planilla input:checked").each(function(){

                    if(this.disabled==false){
                        cajas=cajas+1
                    }

                });
                    if(cajas>0){
                    $.ajax({
                    type:"post",
                    data:$('#'+form).serialize(),
                    dataType:"json",
                    url:url,
                    success:function(data){

                    if (data.success){
                          var htmlerror="<p style =' line-height:1.5; font-size:12px;text-align: justify '>"; 
                                htmlerror+="<span class='ui-icon ui-icon-check' style='float: left; margin: 10px 10px 0px 0;'></span>";
                                htmlerror+="<strong>INFO: </strong>"+data.message;                            
                                htmlerror+="</p>";       
                        $('#dialog-alert').html(htmlerror);
                        refresca_d('refresca','<?php print(base_url().'index.php/mod_contribuyente/contribuyente_c/planilla_inicial/');?>');
                        setTimeout("$('#dialog-alert').dialog({show: 'blind', position: ['center','center']}).dialog('open');" , 1000);               
                    }else{
                                var htmlerror="<p style =' line-height:1.5; font-size:14px;text-align: justify '>"; 
                                htmlerror+="<span class='ui-icon ui-icon-alert' style='float: left; margin: 10px 10px 0px 0;'></span>";
                                htmlerror+="<strong>ALERTA: </strong>"+data.message;                            
                                htmlerror+="</p>";
                        $("#dialog-alert")
                        .dialog("open")
                        .html(htmlerror);
                    }
                    },
                    error:function(o,estado,excepcion){
                        if(excepcion=='Not Found'){
                        }else{

                        }
                    }});
                }else{

                    alert('debe seleccionar un tipo de contribuyente')
                }
            }else{
            
                $.ajax({
                type:"post",
                data:$('#'+form).serialize(),
                dataType:"json",
                url:url,
                success:function(data){

                if (data.success){
                    var htmlerror="<p style =' line-height:1.5; font-size:14px;text-align: justify '>"; 
                                htmlerror+="<span class='ui-icon ui-icon-check' style='float: left; margin: 10px 10px 0px 0;'></span>";
                                htmlerror+="<strong>INFO: </strong>"+data.message;                            
                                htmlerror+="</p>";
                    $('#dialog-alert').html(htmlerror);
                    refresca_d('refresca','<?php print(base_url().'index.php/mod_contribuyente/contribuyente_c/planilla_inicial/');?>');
                    setTimeout("$('#dialog-alert').dialog({show: 'blind', position: ['center','center']}).dialog('open');" , 1000);               
                }else{
                    var htmlerror="<p style =' line-height:1.5; font-size:14px;text-align: justify '>"; 
                                htmlerror+="<span class='ui-icon ui-icon-alert' style='float: left; margin: 10px 10px 0px 0;'></span>";
                                htmlerror+="<strong>ALERTA: </strong>"+data.message;                            
                                htmlerror+="</p>";
                    $("#dialog-alert")
                    .dialog("open")
                    .html(htmlerror);
                }
                },
                error:function(o,estado,excepcion){
                    if(excepcion=='Not Found'){
                    }else{

                    }
                }});
            
            }
        } ;
        busca_ciudad = function(id,url){
        $("#"+id).load(url, function(response, status, xhr) {
            if (status == "error") {
                
            }
        }); 
        
    }; 
        refresca_d = function(id,url){
        $("#"+id).load(url, function(response, status, xhr) {
            if (status == "error") {
                
            }
        }); 
                   $('body,html').animate({
                scrollTop: 0
            }, 500); // Todo esto hace que se la pagina se desplace hasta el tope con una lentitud de 500 milisegundos

    }    
    $(" input ").addClass('ui-state-highlight ui-corner-all');
    $(" select ").addClass('ui-state-highlight ui-corner-all');
    $(" textarea ").addClass('ui-state-highlight ui-corner-all');  
//    $("#form_registra_planilla input ").removeClass('ui-state-disabled');
//    $("#form_registra_planilla select ").removeClass('ui-state-disabled');
//    $("#form_registra_planilla textarea ").removeClass('ui-state-disabled');  
    $("#btn_registro_planilla").click(function() {
        $( "#confirma-planilla" ).dialog('open');
    });
    $("#btn_imprime_planilla").click(function() {
        window.open('<?php print(base_url().'index.php/mod_contribuyente/planilla_c?id_contribu='.$infoplanilla['usuarioid']);?>', 'noimporta3', 'width=800, height=600, scrollbars=NO'); 
    });    
    $("div#dialog-alert").dialog({
        modal: true,
        autoOpen: false,
        hide: "fade",
        stack: true,
        position: ["center","center"]
    });
    $( "#btn_registro_planilla" ).button({
                icons: {
                    primary: "ui-icon ui-icon-folder-collapsed"
                } 
      });
    $( "#btn_imprime_planilla" ).button({
                icons: {
                    primary: "ui-icon ui-icon-print"
                } 
      });
    
//   setInterval(function()
//    {     
////        $('#msjmarque').animate({'color': random_color()}, 900);
//
//    },1000); 
});
function random_color()
{
 return "#"+("000"+(Math.random()*(1<<24)|0).toString(16)).substr(-6);

}
    jQuery(function($){
        $.mask.definitions['#'] = '[JVGEjvge]';
        $("#nrif").mask("#999999999");
        $("#telefono1").mask('0999-9999999');
        $("#telefono2").mask('0999-9999999');
        $("#telefono3").mask('0999-9999999');
        $("#fax1").mask('0999-9999999');
        $("#fax2").mask('0999-9999999');
        

    });
        <?php
              
          if(is_array($tpscont)):
               foreach ($tpscont as $clave => $valor) { ?>
                    $("#form_registra_planilla input[type=checkbox]").each(function(index){                
                    
                        if($(this).val()==<?php echo $valor?>){

                            $(this).attr("checked", true ); 

                         }
                     });
             
              
          <?php     
               }  
          else:                 
                
              
          endif;
          
        if(empty($infoplanilla['rmfechapro'])): ?> 
//          $( "#fregistro" ).datepicker();
          $( "#fregistro" ).datepicker( "option", "showAnim",'slideDown');
          $('#fregistro').datepicker({
                dateFormat: 'yy-mm-dd',
                dayNamesMin: [ "Do", "Lu", "Ma", "Mi", "Ju", "Vi", "Sa" ],
                monthNames: [ "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre" ],
                monthNamesShort: [ "Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sept", "Oct", "Nov", "Dic" ],
                yearRange: "1900:<?php echo date('Y');?>",
                changeMonth: true,
                changeYear: true
            });
//          $.datepicker.setDefaults( $.datepicker.regional[ "" ] );
//          $( "#fregistro" ).datepicker( $.datepicker.regional[ "es" ] );
          
          <?php 
          else:
              
          endif;
        if(!empty($infoplanilla['id_contribu'])): ?> 
             bloqueaInputs('form_registra_planilla',true);
             document.getElementById("btn_registro_planilla").disabled='disabled'
          <?php 
          else:
              
          endif;
    
          
          ?> 
              $(".btn").button();
</script>
<style>
    .encabezado{
        
        /*border:2px solid blue;*/
        width: 100%;
        text-align: center;
        background: #DDA15A;
        
    }
    #planilla table{
        margin-left:2%;
        width: 95%; 
        
    }
   #planilla table textArea{
        
        width: 95%
            
    }
    .input_sin_borde{
    
    width: 89%;
        float:left;
    }
    label {
    display: inline-block;
/*    width: 2em;*/
}
.rojo{
    color:#86000A;
    float:left;
    font-size: 18px; 
    
}
#planilla { 
/*    background-image: url('/code2.1.3/imagenes/logo-medicina.jpg'); */
    background-repeat: no-repeat;
    border:1px solid #969494; 
/*    border con sombreado*/
    -moz-box-shadow: 3px 3px 4px #111;
    -webkit-box-shadow: 3px 3px 4px #111;
    box-shadow: 3px 3px 4px #111;
    /* IE 8 */
    -ms-filter: "progid:DXImageTransform.Microsoft.Shadow(Strength=4, Direction=135, Color='#111111')";
    /* IE 5.5 - 7 */
    filter: progid:DXImageTransform.Microsoft.Shadow(Strength=4, Direction=135, Color='#111111');
/*    fin border con sombreado*/
/*    position: relative;  */
    bottom:10%; 
     
    
    color: #000;
    font: 62.5% "arial", sans-serif; 
    font-size: 11px;
 }   
.cerrar{
background-color:#5C9CCC;
    padding: 6px 12px;
border-radius: 4px;
color: black;
font-size:10px ;
    margin-left: 200px;
    margin-top: 5px;
position: relative;

}
.cerrar:before{  /*Este es un truco para crear una flechita */
    content: '';
    border-top: 8px solid #BF273C ;
    border-bottom: 8px solid transparent ;
    border-right: 8px solid transparent;
    border-left: 8px solid transparent;
    left: 180px;
    position: absolute;
    top: 23px;
}

.cerrar2{
background-color:#5C9CCC;
    padding: 6px 12px;
border-radius: 4px;
color: black;
font-size:10px ;
    margin-left: 50px;
    margin-top: 5px;
position: relative;

}
.cerrar2:before{  /*Este es un truco para crear una flechita */
    content: '';
    border-top: 8px solid transparent ;
    border-bottom: 8px solid transparent ;
    border-right: 8px solid #BF273C;
    border-left: 8px solid transparent;
    left: -16px;
    position: absolute;
    top: 3px;
}
	
	.floatr { float:left; }
        .floatl { float:left; width: 82% }
        .secciones{
            border-top:2px solid #654b24;
            border-bottom: 0px;
            border-left: 0px;
            border-right: 0px;
            
            
            
        }
        .secciones legend{
            border:1px solid #654b24;
            color:#654b24;
            padding: 0 .7em;
            
            
        }

.subir{
   position:fixed; /*Importante*/
   bottom:0; right:10px; /*Lo ubicamos abajo y a la derecha*/
   line-height:30px;
   height:30px;
   width:65px;
   text-align:center;
}
.subir a {
   display:block;color: #000;
}
.subir a:hover {
   color:#fff;
}
/*#planilla_contribu label{ font-weight: bold}*/
 .planilla_inicial_form input{ display:block; font-size: 12px; padding: .2em;}
 .planilla_inicial_form label{ display:block;}
 .planilla_inicial_form select{ display:block; font-size: 12px;padding: .2em;}
 
    </style>
      <div id="refresca" style="width:100%">
    <!--<button id="btn-frmbuscarcontri2" style="width:30px; height: 25px; margin-top:-25px; margin-left: 220px; position: absolute" title=" Buscar planilla"></button>-->
    <p style="color:#86000A;"><span><b>Planilla de Datos del Contribuyente:<b/></span></p>
    
    <div id="confirma-planilla" ></div>



    <center>
        <?php if(empty($infoplanilla['id_contribu'])): ?> 
        
            <div style="margin-left: 5% ;"><marquee scrollamount="5" width="40"><span class="ui-icon ui-icon-triangle-1-w"></span></marquee><b id="msjmarque" style=" font-family: monospace; font-size: 12px">IMPORTANTE: Para llenar la planilla debe cargar el representante legal y el registro mercantil primero.<br /> Dirigase a las pestañas carga de documentos y carga de rep. legal<br /> antes de llenar esta planilla </b><marquee scrollamount="5" direction="right" width="40"><span class="ui-icon ui-icon-triangle-1-e"></span></marquee></div>
        
        <?php endif; ?>
   <div  id="planilla_contribu" style="padding: 0 .7em; width: 80%; margin-left: 5% ; ">
   <br/>
    <div id="planilla"  class="ui-widget-content ui-corner-all" > 
     <?php if(!empty($infoplanilla['id_contribu'])): ?>
    <button style="float:left;margin-top:-2px;margin-left:-2px" id="btn_edita_planilla" class="btn">Activar Modo Edicion</button><br/><br/>
    <?php
    else:
        
    endif;
    ?> 
 <form id="form_registra_planilla" class=" planilla_inicial_form" >
 <input value="<?php echo  $infoplanilla['id_contribu']; ?>" type="hidden"   name="id_contribu" id="id_contribu" /> 
<!--        <div  class="encabezado ui-widget-header">A). Datos del Contribuyente</div><br />-->
<fieldset class='secciones' style="float:top;border-top:1px solid #654b24;"><legend class="ui-widget-content ui-corner-all" align= "center" ><h3>Datos del Contribuyente</h3></legend>

    <table border="0">
            <tr>
                <td colspan="2">
                <label ><strong>1). Razon Social:</strong></label>
                <input value="<?php echo  $infoplanilla['razonsocial']; ?>" type="text" class=" requerido "  style=" width: 96%; float:left;" name="rsocial" id="rsocial" /><strong class="rojo">*</strong>
                </td>
                <td colspan="">
                <label><strong>2). Denominacion Comercial:</strong></label>
                <input value="<?php echo  $infoplanilla['denominacionc']; ?>"type="text" class="requerido " style=" width: 86%; float:left;" name="dcomercial" id="dcomercial" /><strong class="rojo">*</strong>
                </td>
            </tr>
            <tr>
                <td colspan="">
                    <label ><strong>3). Actividad Economica:</strong></label>

                    <select style=" width: 200px" id="aecono" name="aecono" class="requerido  ui-widget-content ui-corner-all input_sin_borde " >
                        <option value="">Seleccione su Actividad Economica</option>
                            <?php
                            if (sizeof($actividad_economica)>0):
                                $seleccionaActividad = '';
                                foreach ($actividad_economica as $actividad):
                                if($actividad[id]==$infoplanilla['actividade']){ 
                                    $seleccionaActividad='selected';
                                    
                                    } else{ 
                                        $seleccionaActividad='';
                                        
                                        }                                
                                
                                print("<option $seleccionaActividad value='$actividad[id]'>". utf8_encode(utf8_decode(strtoupper($actividad['nombre'])))."</option>");
                                endforeach;
                            endif;

                            ?>
                      </select>

                    <strong class="rojo">*</strong>                
                    
                </td>
                <td>
                    <label style="margin-right:120px"><strong>4). N de rif:</strong></label>
                    <input readonly="readonly" value="<?php echo  $infoplanilla['rif']; ?>" type="text" class="requerido input_sin_borde" name="nrif" id="nrif" /><strong class="rojo">*</strong>
                </td>
                <td>
                    <label><strong>5).Registro Cinematografico:</strong></label>     
                    <input  value="<?php echo  $infoplanilla['registrocine']; ?>" type="text" class=" " name="nrcinema" style=" width: 86%; float:left;" id="nrcinama" condicion="number:true"/>
                </td>    
            </tr>
            <tr>
                <td colspan="3">
                    <label><strong>6).Domicilio Fiscal:</strong></label>
                    <textarea type="text" name="dfiscal" class="requerido " style=" width: 95%; float:left;"id="dfiscal"><?php echo  $infoplanilla['domifiscal']; ?></textarea><strong class="rojo">*</strong>
                </td>
                
            </tr>
        
            <tr>
                <td>
                    <label ><strong>7).Estado o Entidad Federal:</strong></label>
     
                    <select class="requerido input_sin_borde floatl" id="estado" name="estado" class="requerido  ui-widget-content ui-corner-all" onchange="busca_ciudad('muestra_ciudad','<?php print(base_url().'index.php/mod_contribuyente/contribuyente_c/ciudades/');?>'+this.value)"><strong class="rojo">*</strong>
                        <option  value="">Seleccione un Estado</option>
                            <?php
                            if (sizeof($estados)>0):
                                $selecciona='';
                                foreach ($estados as $estado):
                                
                                if($estado['id']==$infoplanilla['estadoid']){ 
                                    $selecciona='selected';
                                    
                                    } else{ 
                                        $selecciona='';
                                        
                                        }
                                print("<option $selecciona id='estado".$estado['id']."'value='".$estado['id']."'>".$estado['nombre']."</option>");
                                endforeach;
                            endif;

                            ?>
                      </select>

                    <strong class="rojo">*</strong>
                      
                </td>               
                <td colspan="">
                    <label ><strong>8). Municipio donde reside:</strong></label>
                    <div id="muestra_ciudad">
                       
                    <select id="ciudad" name="ciudad" class="requerido  ui-widget-content ui-corner-all floatl"  >
                        <?php (!empty($infoplanilla['ciudadid'])?'<option value="">Seleccione una Ciudad</option>':'') ?>
                        <?php 
                        if (!empty($infoplanilla['ciudadid'])):
                            print("<option  selected value='".$infoplanilla['ciudadid']."'>".$infoplanilla['ciudad']."</option>");
                        endif;
                        ?>
                        
                    </select>

                    <strong class="rojo">*</strong>                          
                    </div>
                </td>
 
                <td>
                    <label><strong>9).zona postal:</strong></label>
                    <input value="<?php echo  $infoplanilla['zonapostal']; ?>" type="text"   name="zpostal" id="zpostal" class="input_sin_borde floatl" /><strong class="rojo">*</strong>
                </td>    
            </tr>
            <tr>
                <td>
                     <label ><strong>10). Telefono1:</strong></label>
                    <input value="<?php echo  $infoplanilla['telef1']; ?>"  type="text" class=" requerido floatl" name="telefono1" id="telefono1"  /><img class="floatr" src="<?php echo base_url(); ?>include/imagenes/iconos/iconos_tlf.gif"  />
                </td>
                <td>
                   <label ><strong>11). Telefono2:</strong></label>
                    <input value="<?php echo  $infoplanilla['telef2']; ?>"  type="text" class=" floatl" name="telefono2" id="telefono2" />
                </td>            
                <td>
                     <label><strong>12). Telefono3:</strong></label>
                    <input value="<?php echo  $infoplanilla['telef3']; ?>"  type="text" class=" floatl" name="telefono3" id="telefono3"/><br />
                   
                </td>    
            </tr>
            <tr>
                <td>
                     <label ><strong>13). Fax1:</strong></label>
                    <input value="<?php echo  $infoplanilla['fax1']; ?>" type="text" class="floatl" name="fax1" id="fax1" /><img class="floatr" src="<?php echo base_url(); ?>include/imagenes/iconos/icono_fax.png"  />
                 </td>
                  <td>
                     <label ><strong>14). Fax2:</strong></label>
                      <input value="<?php echo  $infoplanilla['fax2']; ?>" type="text" class="floatl" name="fax2" id="fax2"  /><img class="floatr" src="<?php echo base_url(); ?>include/imagenes/iconos/icono_fax.png"  />
                 </td>
                  <td>
                     <label ><strong>15). Email:</strong></label>
                     <input readonly="readonly" value="<?php echo  $infoplanilla['email']; ?>" type="text" class="requerido floatl" name="email" id="email" condicion=" email:true "/>
                 </td>      
            
            </tr>
            <tr>
                <td>
                   <label ><strong>16). PINBB:</strong></label>
                    <input value="<?php echo  $infoplanilla['pinbb']; ?>" type="text" maxlength="8" class="floatl" name="pinbb" size="10px" id="pinbb" /><img class="floatr" src="<?php echo base_url(); ?>include/imagenes/iconos/BBM_Logo_Redux.png"  />
                </td>
                <td>
                     <label ><strong>17). Skype:</strong></label>
                    <input value="<?php echo  $infoplanilla['skype']; ?>" style='width:75%;' type="text" class="floatl" name="skype" id="skype" /><img class="floatr" src="<?php echo base_url(); ?>include/imagenes/iconos/logo-sksype2.png"  width='35' style="margin-top:-3%;margin-left: -2%;"/>
                </td>
                <td>
                    <label ><strong>18). twitter:</strong></label>
                    <input value="<?php echo  $infoplanilla['twitter']; ?>" type="text" class=" floatl" name="twiter" id="twiter" /><img class="floatr" src="<?php echo base_url(); ?>include/imagenes/iconos/icono-twitter.thumbnail.gif"  />
                </td>
               
            
             </tr>
             <tr>
                 <td colspan="3">
                     <label ><strong>19).facebook :</strong></label>
                    <input value="<?php echo  $infoplanilla['facebook']; ?>" type="text" style="float:left; width: 20%" class="input_sin_borde " name="facebook" id="facebook"/><img class="floatr" src="<?php echo base_url(); ?>include/imagenes/iconos/icono_facebook.gif"  />
                  </td>   
             </tr>    
          </table><br />  
           </fieldset>
<!--      <div  class="encabezado ui-widget-header">A). Datos de las Acciones </div><br />-->
    <fieldset class='secciones'><legend class="ui-widget-content ui-corner-all" align= "center" ><h3>Datos de las Acciones </h3></legend> 
      <table border="0">
             <tr>
                 <td >
                     <label ><strong>20). Numero de acciones:</strong></label>
                     <input readonly="readonly" value="<?php echo  $infoplanilla['nuacciones']; ?>" type="text" class="requerido input_sin_borde" name="nacciones" id="nacciones" condicion="number:true"/><strong class="rojo">*</strong>
                 </td>
                 <td>
                   <label colspan="2"><strong>21).valor de las acciones:</strong></label> 
                    <input value="<?php echo  $infoplanilla['valaccion']; ?>" type="text" class="requerido input_sin_borde" name="vacciones" id="vacciones" condicion=" number:true "/><strong class="rojo">*</strong>
                 </td>            
            </tr>
            <tr>
                <td colspan="2">
                    <div id="trae_accionistas">
                        <?php print($accionistas_carga); ?>
                    </div>
                </td>
            </tr>
      </table>      
    </fieldset>
<!--       <div class="encabezado ui-widget-header">A). Datos del registro mercatil </div><br />-->
<fieldset class='secciones'>
    <legend class="ui-widget-content ui-corner-all" align= "center" >
        <h3>Datos del registro mercatil </h3>
    </legend> 
          <table border="0">
              <tr>
                  <td>
                      <label ><strong>22). Capital suscrito:</strong></label>
                      <input value="<?php echo  $infoplanilla['capitalsus']; ?>"  type="text" class="requerido input_sin_borde" name="csuscrito" condicion="number:true" id="csuscrito" /><strong class="rojo">*</strong>
                   </td>
                  <td>
                      <label style=" margin-right: "><strong>23). Capital pagado:</strong></label>
                      <input value="<?php echo  $infoplanilla['capitalpag']; ?>" type="text" class="requerido input_sin_borde" condicion="number:true" name="cpagado" condicion=" digits:true " id="cpagado"/><strong class="rojo">*</strong>
                   </td>
                   <td>
                       <label style=" margin-right: "><strong>24). Oficina registradora:</strong></label>
                       <input value="<?php echo  $infoplanilla['regmerofc']; ?>" type="text" class="requerido input_sin_borde" name="oregistradora" id="oregistradora" /><strong class="rojo">*</strong>
                   </td>
              </tr>
              <tr>
                  <td>
                      <label ><strong>25).N Registro mercantil:</strong></label>
                      <input value="<?php echo  $infoplanilla['rmnumero']; ?>"  type="text" class="requerido input_sin_borde" name="nrmercantil" id="nrmercantil" /><strong class="rojo">*</strong>
                  </td>
                  <td>
                      <label ><strong>26).Numero del folio:</strong></label>
                      <input value="<?php echo  $infoplanilla['rmfolio']; ?>"  type="text" class=" requerido input_sin_borde" name="nfolio" id="nfolio"  /><strong class="rojo">*</strong>
                  </td>
                  <td>
                      <label ><strong>27). Numero del tomo:</strong></label>
                       <input value="<?php echo  $infoplanilla['rmtomo']; ?>"  type="text" class="requerido input_sin_borde" name="ntomo" id="ntomo" /><br /><strong class="rojo">*</strong>
                  </td>
                  
             </tr>
             <tr>
                 <td>
                     <label ><strong>28).Fecha del registro:</strong></label>
                     <input value="<?php echo  $infoplanilla['rmfechapro']; ?>" type="text" class="requerido input_sin_borde" name="fregistro" condicion="date:true" id="fregistro" /></textarea><strong class="rojo">*</strong>
                 </td>
                  <td>
                     <label ><strong>29). Numero de control:</strong></label>
                     <input value="<?php echo  $infoplanilla['rmncontrol']; ?>" type="text" class="requerido input_sin_borde" name="ncontrol" id="ncontrol" /><strong class="rojo">*</strong>
                 </td>
                  <td>
                     <label ><strong>30). Objeto de la empresa:</strong></label>
                     <input value="<?php echo  $infoplanilla['rmobjeto']; ?>"  type="text" class="requerido input_sin_borde" name="objempresa" id="objempresa" /></textarea><strong class="rojo">*</strong>
                 </td>
             </tr>
            <tr>
                <td colspan="3">
                    <label><strong>32).Domicilio comercial:</strong></label>
                    <textarea type="text" class="input_sin_borde" style=" width: 95%; float:left;" name="domcomer" id="domcomer"><?php echo  $infoplanilla['domcomer']; ?></textarea>
                </td>
            </tr>
             
        
        </table>
</fieldset>
<fieldset class='secciones'>
    <legend class="ui-widget-content ui-corner-all" align= "center" >
        <h3>Indique el tipo de contribuyente</h3>
    </legend> 
          <table border="0">
              <tr>
                  <td>
                      <label ><strong>33).Exhibidor:</strong></label>
                  </td>
                  <td>
                     <input  type="checkbox" id="tcontribu1" name="tcontribu[]" value="1">
                   </td>
                  <td>
                      <label ><strong>33).TV señal abierta:</strong></label>
                  </td>
                  <td>
                     <input  type="checkbox" id="tcontribu2" name="tcontribu[]" value="2">
                   </td>
                   <td>
                      <label ><strong>33).TV suscripcion:</strong></label>
                  </td>
                  <td>
                     <input  type="checkbox" id="tcontribu3" name="tcontribu[]" value="3">
                   </td>
              </tr>
              <tr>
                  <td>
                      <label ><strong>33).Distribuidores:</strong></label>
                  </td>
                  <td>
                     <input  type="checkbox" id="tcontribu4" name="tcontribu[]" value="4">
                   </td>
                  <td>
                      <label ><strong>33).Venta y alquiler:</strong></label>
                  </td>
                  <td>
                     <input  type="checkbox" id="tcontribu5" name="tcontribu[]" value="5">
                   </td>
                  <td>
                      <label ><strong>33).Servicios para la produccion :</strong></label>
                  </td>
                  <td>
                     <input  type="checkbox" id="tcontribu6" name="tcontribu[]" value="6">
                   </td>
                  
             </tr>          
        
        </table>
</fieldset>
    </form><br/>
         <center>
             <button id="btn_registro_planilla" class="btn">Guardar</button>
                 <?php
                 if(!empty($infoplanilla['id_contribu'])): 
                     ?>
                    <button id="btn_imprime_planilla" class="btn">Imprimir</button>
                         <?php 
                 else:
                     
                 endif;  ?>             

   
   
        
         </center><br/><br/>
    </div>
    </div>
        </center>
<div id="dialog-alert" title="Mensaje">
    <p id="dialog-alert_message"></p>
</div>
<!--<div class="subir">
    <a href="#refresca">Subir</a>
</div>-->
</div>

    
