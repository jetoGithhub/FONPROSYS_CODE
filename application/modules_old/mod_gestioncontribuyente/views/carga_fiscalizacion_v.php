
<?php
//print_r($inspeccionid);
//echo $conusuid;
//$data=array();
?>

<html>
<script type="text/javascript" charset="utf-8">
                
 $(function() {
     
//     $("#prueba-show").hide();
     $("#memsajerror").hide();
//     $("#error_adjunto").hide();
     $("#respuesta-divs").hide();
     $( "#dialog_reparo_confirmacion" ).dialog(
        {
            modal: true, //inhabilitada pantalla de atras
            autoOpen: false,
            draggable: true,
            resizable: false, //evita cambiar tamaño del cuadro del mensaje
            show: "show", //efecto para abrir cuadro de mensaje
            hide: "slide", //efecto para cerrar cuadro de mensaje
            title: "Adjuntar acta de reparo"
        });

        $('#dialog-cargafis').dialog({

            modal: true, //inhabilitada pantalla de atras
            autoOpen: false,
            draggable: false,
            resizable: false, //evita cambiar tamaño del cuadro del mensaje
            show: "clip", //efecto para abrir cuadro de mensaje
            hide: "clip", //efecto para cerrar cuadro de mensaje
            title: "detalles del reparo",
            buttons: {  //propiedad de dialogo, agregar botones
                Guardar: function() { 
                        //llamado del formulario, en este caso #form_new corresponde al id del form(en los archivos de las vistas)
                        $('#form_carga_asignacion').submit(); 
                    }
//                    ,
//                Cancelar: function() { 
//                        $( this ).dialog( "close" ); 
//                }

            }
        });


 });
 
espera_crea_reparo=function(){
    $.blockUI({ 
        message: $('#espera_crea_reparo'),
        css: { 
            border: 'none',
            padding: '15px', 
            backgroundColor: '#fff', 
            '-webkit-border-radius': '10px', 
            '-moz-border-radius': '10px', 
            opacity: .7, 
            color: '#CD0A0A' 
        } });  
    
};
cargar_dialog_cargafis=function(url,id,asignaid,conusuid,ident,id_div){

//    alert(id_div);
    $.ajax({
        type:"post",
        data:{ id:id,identificador:ident,idasig:asignaid,conusuid:conusuid },
        dataType:"json",
        url:url,
        success:function(data){
//             alert(data.vista);
            if (data.resultado){
                
                $("#dialog-cargafis").html(data.vista);              
                
                $("#dialog-cargafis").dialog('open');
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

}
                 
</script>  
    <style>
        .tp input, textArea{ width: 100%}
        #carga-fiz{ width: 100%}
        .tp td{  border-color: #E9E9E9; }
        
        
        </style>
        
        <div id="dialog_reparo_confirmacion">
            
            
        </div>
        <div id="espera_crea_reparo" class="ui-corner-all"></div>
        <div class="ui-widget-header" style="text-align:center; font-size: 12px; font-style: italic; margin-bottom: 20px; width: 80%; margin-left:10%; ">Informacion del contribuyente</div>
<div id="prueba-show">
<center>
    <div id="carga-fiz " class="ui-widget-content ui-corner-all tp">
     <table id="tablatext " style="width: 100%; padding: 10px; border-collapse: collapse; border-color: #F8F7F6" border="1" >
                <tr >
                <td colspan="" style=" width: 30%" ><strong>N&deg; RCN</strong></td>                
                <td colspan="" style=" width: 30%" ><strong>Actividad economica</strong></td>
                <td colspan="" style=" width: 40%" ><strong>Razon Social</strong></td>
                
                </tr>
                <tr  >
                        
                        <td ><?php echo $numregcine ?></td>                        
                        <td ><?php echo $actividad ?></td>
                        <td ><?php echo $nombre?></td>
                        
                </tr>
                <tr >
                
                <td colspan="" style=""   ><strong>Estado</strong></td>
                <td colspan=""><strong>Ciudad</strong></td>
                 <td colspan=""><strong>Tipo de contribuyente</strong></td>
                </tr>
                   <tr >
                        
                       
                        <td colspan=""><?php echo $estado  ?></td>
                        <td colspan=""><?php echo $ciudad  ?></td>
                        <td colspan=""><?php echo $tcontribuyente  ?></td>
                </tr>
                <tr >
                <td colspan=""><strong>Telefono</strong></td>
                <td colspan=""><strong>Correo electronico</strong></td>
                <td colspan=""><strong>Fax</strong></td>
             </tr>
             
                <tr >
                        <td colspan=""><?php echo $telef1 ?></td>
                         <td colspan=""><?php echo $email ?></td>  
                         <td colspan=""><?php echo $fax ?></td>
                </tr>
                <tr >
                     <td colspan="3"><strong>Domicilio fizcal</strong></td>
                </tr>
                <tr >             
                 <td colspan="3"><p><?php echo $domfiscal ?></p></td>

                </tr>
              
            </table>
    </div></center>
    <!--style=" border:0.1em solid #A52121; width: 100px; padding: 2px; background:#EBEBEB; float: left; text-align: center; font-weight: bold; cursor:pointer "-->
<!--    <div id="contenedor-pestañas" style="padding-top:2px; padding-bottom: 20px">
        <div onclick="manejo_pestañas(this,'datos_registro_mercantil_v')" estado="cerrado" id="dregistro" class="ui-corner-top" style="width:auto; padding: 2px; float: left; text-align: center; font-weight: bold; cursor:pointer "><span class="ui-icon ui-icon-circle-arrow-e" style="float: left"></span><u>Datos registro</u></div>
        <div onclick="manejo_pestañas(this,'p')" estado="cerrado" id="daccionistas" class="ui-corner-top" style="width:auto; padding: 2px;float: left;text-align: center; font-weight: bold;cursor:pointer "><span class="ui-icon ui-icon-circle-arrow-e" style="float: left"></span><u>Datos accionista</u></div>
        <div onclick="manejo_pestañas(this,'p')" estado="cerrado" id="dreplegal" class="ui-corner-top" style=" width:auto; padding: 2px; float: left;text-align: center; font-weight: bold; cursor:pointer"><span class="ui-icon ui-icon-circle-arrow-e" style="float: left"></span><u>Datos rep. legal</u></div>
      
    </div>-->
    
    <div class="ui-corner-bottom" visibilidad="hide" id="respuesta-divs" style=" background: #EDE4E4; width: 100%; height:300px;  border:0.1em solid #A52121; "></div>    
    <div id="lista-cargas-detalles" >
    <div class="ui-widget-header" style="text-align:center; font-size: 12px; font-style: italic; margin-bottom: 20px; width: 80%; margin-left:10%; margin-top: 20px ">Informacion de los detalles del reparo</div>
    <table cellpadding="0" cellspacing="0" border="0" class="display" id="listar-detalles" width="100%">
	
    <thead>
		<tr>
			<th>#</th>
			<th>periodo gravable</th>
                        <?php if($tipo!=2){ ?><th>anio</th><?php } ?>	
                        <th>base imponible</th>
                        <th>alicuota impositiva</th>
                        <th>total</th> 
                        <th>Tipo de reparo</th>
                        <th>Operaciones</th>
                </tr>
	</thead>
	<tbody>
           <?
        if(!empty($detalles)):   
           $baseurl=base_url();
           
           foreach ($detalles as $clave => $valor) {
            ($valor['reparo_faltante']=='t'? $treparo='LIQUIDACION SUSTITUTIVA' : $treparo='AUTOLIQUIDACION' );
            $con=$clave+1;
//            $v=$valor['nombre'];
            if($tipo!=2):
               echo '<tr>
                        <td>'. $con .'</td>';
                        if($tipo==0):
                            echo'<td>'.$this->funciones_complemento->devuelve_meses_text($valor["periodo"],1).'</td>';
                        endif;
			 if($tipo==1):
                        echo'<td>'. $this->funciones_complemento->devuelve_trimestre_text($valor["periodo"],1).'</td>';
                        endif;
                        
                        echo '<td>'. $valor["anio"].'</td>
                        <td>'. $this->funciones_complemento->devuelve_cifras_unidades_mil($valor["base"]).'</td>
                        <td>'. $valor["alicuota"].'</td>
                        <td>'. $this->funciones_complemento->devuelve_cifras_unidades_mil($valor["total"]).'</td>                   
			<td>'.$treparo.'</td>  
                        
                       <td> <button class="eliminadetalle" id="'.$valor["id"].'" style=" width: 30px; height: 25px;"  title=""></button></td>    
                         
                    </tr>';
            else:
                echo '<tr>
                        <td>'. $con .'</td>
			<td>'. $valor["periodo"].'</td>                       
                        <td>'. $this->funciones_complemento->devuelve_cifras_unidades_mil($valor["base"]).'</td>
                        <td>'. $valor["alicuota"].'</td>
                        <td>'. $this->funciones_complemento->devuelve_cifras_unidades_mil($valor["total"]).'</td>                    
			<td>'.$treparo.'</td>  
                        
                       <td> <button class="eliminadetalle" id="'.$valor["id"].'" style=" width: 30px; height: 25px;"  title=""></button></td>    
                </tr>';
                
            endif;
//                       
           }
           endif;
           ?>
            <!--<button id="'.$valor["id_usuario"].'" onclick="if(confirma() == false) return false" href="<? //=base_url()?>index.php/mod_administrador/usuarios_c/eliminar_usuario/<?//=this.id?>" title="Eliminar Usuario"></button>-->
                        
           </tbody> 
         </table>
        <table id="botoneria-cargar" style=" width: 100%; border: 0px solid">
             <tr>                 
                   <td><button style=" height: 25px; margin-top: 10px; " class="btnvolver" id="btnvolver"  title="">volver</button></td>
                   <td><button  style=" height: 25px;margin-top: 10px; margin-left: 70%" class="btndialos-cargareparo" <?php if(empty($detalles)):?> disabled="disabled"<?php endif;?>  id="btndialos-cargareparo"  title="">nuevo reparo</button>
                   <button style="  height: 25px; margin-top: 10px; float: right" class="btndialos-cargafis" id="btndialos-cargafis"  title="">detalles</button></td>
            </tr>
        </table>

<div id="dialog-cargafis"></div>
<div style="padding: 0 .7em; width: 400px; margin-top: 15px; margin-left:30%; margin-bottom: 10px" class="ui-corner-all" id="memsajerror">
		
 </div>
</div>
</div>
<script>


$( '#btnvolver' ).button({
                icons: {
                primary: "ui-icon-arrowthick-1-w"
                }

});

$( '#btndialos-cargafis' ).button({
                        icons: {
                        primary: "ui-icon-plusthick"
                        }                                          

});

$( '#btndialos-cargareparo' ).button({
                            icons: {
                            primary: "ui-icon-clipboard"
                            }                                           

});

$( '.eliminadetalle' ).button({
                    icons: {
                    primary: "ui-icon-trash"
                    }                                           

});

$('.btnvolver').click(function(){  
//                               alert(this.id)
    $('#a0').attr('href','<?php echo base_url()."index.php/mod_gestioncontribuyente/fiscalizacion_c"?>'); 
    $('#a0').text('asignaciones');
    $("#tabs").tabs("load",0);    

}); 

$('.btndialos-cargafis').click(function(){  
//                                  url,id,ident,id_div
    cargar_dialog_cargafis('<?php echo base_url()."index.php/mod_gestioncontribuyente/fiscalizacion_c/muestra_dialog_cragafis"?>','<?php echo $idcontribu?>','<?php echo $inspeccionid?>','<?php echo $conusuid?>',2,'dialog-cargafis');

});
manejo_pestañas=function(htmlrequest,vista){
//    alert(vista)
    if($(htmlrequest).attr('estado')=='cerrado'){
        
        if($("#respuesta-divs").attr('visibilidad')=='show'){
           
           $("#respuesta-divs").hide('blind',{ direction: "up" });
           $("#contenedor-pestañas div").css('border','none');
           $("#contenedor-pestañas div").css('background','#F8F7F6');
//           $("#contenedor-pestañas div").css('border-bottom','0.1em solid #A52121');
           $("#contenedor-pestañas span").removeClass('ui-icon-circle-arrow-s');
           $("#contenedor-pestañas span").addClass('ui-icon-circle-arrow-e');
           $("#contenedor-pestañas div").attr('estado','cerrado')
        }
        $("#respuesta-divs").load('<?php echo base_url()."index.php/mod_gestioncontribuyente/fiscalizacion_c/carga_vistas_pestanas_fiscalizacion?vista="?>'+vista+'&conusuid='+<?php echo $conusuid?>, function(response, status, xhr) {
            if (status == "error") {
            var msg = "Sorry but there was an error: ";
            $("#respuesta-divs").html(msg + xhr.status + " " + xhr.statusText);
            }
        });
        $("#respuesta-divs").show('blind',{ direction: "up" });
        $("#respuesta-divs").attr('visibilidad','show')
        $(htmlrequest).css('border','0.1em solid #A52121');
        $(htmlrequest).css('border-bottom','none');
        $(htmlrequest).attr('estado','abierto')
        $('#'+htmlrequest.id+' span').removeClass('ui-icon-circle-arrow-e');
        $('#'+htmlrequest.id+' span').addClass('ui-icon-circle-arrow-s');
        $(htmlrequest).css('background','#EDE4E4');    
        $('#lista-cargas-detalles').hide();
    }else{
        
        $("#respuesta-divs").hide('blind',{ direction: "up" });
//        $(htmlrequest).css('border-bottom','0.1em solid #A52121');  
        $(htmlrequest).css('border','none');
        $(htmlrequest).attr('estado','cerrado')
        $('#'+htmlrequest.id+' span').removeClass('ui-icon-circle-arrow-s');
        $('#'+htmlrequest.id+' span').addClass('ui-icon-circle-arrow-e');
        $(htmlrequest).css('background','#F8F7F6');
        $('#lista-cargas-detalles').show();
    }
}


$('.eliminadetalle').click(function(){
   $.ajax({
        type:"post",
        data:{ id:this.id},
        dataType:"json",
        url:'<?php echo base_url()."index.php/mod_gestioncontribuyente/fiscalizacion_c/elimina_detalles_fiscalizacion"?>',
        success:function(data){
//             alert(data.vista);
            if (data.resultado){

                var current_index = $("#tabs").tabs("option","selected");             
                $("#tabs").tabs("load",current_index);  

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

});

$('.btndialos-cargareparo').click(function(){ 
            var frm_adjuntar_actareparo='<form class="focus-estilo form-style" action="" method="post" id="uploadFile" >';
                frm_adjuntar_actareparo+='<input type="hidden" id="asignacionid" name="asignacionid" value="<? echo $inspeccionid?>" />';
                frm_adjuntar_actareparo+='<label ><strong>Fecha Autorizacion Fiscal</strong></label><br/>';
                frm_adjuntar_actareparo+='<input class="fecha_acta requerido ui-widget-content ui-corner-all" type="text" id="fautofis" name="fautofis" /><br/>';
                frm_adjuntar_actareparo+='<label ><strong>Fecha Acta Requerimiento</strong></label><br/>';
                frm_adjuntar_actareparo+='<input class="fecha_acta requerido ui-widget-content ui-corner-all" type="text" id="factareq" name="factareq" /><br/>';
                frm_adjuntar_actareparo+='<label ><strong>Fecha Acta de Recepcion</strong></label><br/>';
                frm_adjuntar_actareparo+='<input class="fecha_acta requerido ui-widget-content ui-corner-all" type="text" id="factarec" name="factarec" /><br/>';
                frm_adjuntar_actareparo+='<label><strong>Tipo de Acta</strong><label></br>';
                frm_adjuntar_actareparo+='<select onChange="muestra_nacta(this.value)" id="tipo_reparo" name="tipo_reparo" class=" requerido ui-widget-content ui-corner-all" >';
                frm_adjuntar_actareparo+='<option value="" >Selecione</option>';
                frm_adjuntar_actareparo+='<option value="false" >Acta de Reparo</option>';
                frm_adjuntar_actareparo+='<option value="true" >Acta de Conformida</option>';
                frm_adjuntar_actareparo+='</select><br>';
                frm_adjuntar_actareparo+='<div id="content-nacta"></div>';
                frm_adjuntar_actareparo+='<label ><strong>Adjuntar Archivo</strong></label><br/>';
                frm_adjuntar_actareparo+='<input class="requerido" mensaje="Debe adjuntar el archivo" type="file" id="archivo_adjunto" name="archivo_adjunto" size="14" /><br/><br/>';
                frm_adjuntar_actareparo+='</form><div id="carga_img"></div>';
                frm_adjuntar_actareparo+='<div style="padding: 0 .7em;" class="ui-corner-all" id="error_adjunto">';
                frm_adjuntar_actareparo+='</div>';
                $( "#dialog_reparo_confirmacion" ).html(frm_adjuntar_actareparo)
                $("#error_adjunto").hide();
            $( ".fecha_acta" ).datepicker({
                dateFormat: 'yy-mm-dd',
                dayNamesMin: [ "Do", "Lu", "Ma", "Mi", "Ju", "Vi", "Sa" ],
                monthNames: [ "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre" ],
                monthNamesShort: [ "Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sept", "Oct", "Nov", "Dic" ],
                yearRange: "2000:<?php echo date('Y');?>",
                changeMonth: true,
                changeYear: true
            });
        //    $( "#dialog_reparo_confirmacion" ).html('<h3>Procedera a generar el acta de reparo. ¿Desea continuar?</h3>')
                $( "#dialog_reparo_confirmacion" ).dialog('open')

                validador('uploadFile','<?php print(base_url()); ?>index.php/mod_gestioncontribuyente/fiscalizacion_c/subir_acta_reparo','sube_acta_reparo');

                 
    });
 muestra_nacta=function(val){
//     alert(val)

$.ajax({
             type:"post",
             dataType:"json",
             data:{tipo:val},
             url:'<?php echo base_url()."index.php/mod_gestioncontribuyente/fiscalizacion_c/busca_correlativo"?>',
             success:function(data){
         //             alert(data.vista);
                 if (data.resultado){
            
                    if(val=='true'){
                        var html='<label ><strong>Indique Nº de acta</strong></label><br/>';
                            html+='<label style="display: inline ;" >CNAC/FONPROCINE/GFT/AFC-</label><input style="margin-bottom:12px; width:10%; padding: .1em;  font-family: sans-serif, monospace; font-size: 12px" class="requerido ui-widget-content" mensaje="Debe indicar el numero del acta" type="text" name="descripcion_archivo" id="descripcion_archivo" size="20" readonly="readonly" value="'+data.nacta+'" /><label> - <?php echo date('Y');?></label><br/>';
                            html+='<div class="ui-corner-all  ui-state-highlight" style="padding:2px"><p style="font-family: sans-serif;color:#000;font-size:9px; text-align: justify"><span style="float: left; margin-top: .3em; padding-left:0.7em; padding-bottom:0.5em" class="ui-icon ui-icon-info"></span><strong>Aviso: </strong>Recuerde colocar en el documento que esta adjuntando el mismo numero de acta que le muestra el sistema</p></div><br/>';
                    }else{
                        
                        var html='<label ><strong>Indique Nº de acta</strong></label><br/>';
                            html+='<label style="display: inline ;" >CNAC/FONPROCINE/GFT/AFR-</label> <input style="margin-bottom:12px; width:10%; padding: .1em;  font-family: sans-serif, monospace; font-size: 12px" class="requerido ui-widget-content" mensaje="Debe indicar el numero del acta" type="text" name="descripcion_archivo" id="descripcion_archivo" size="20" readonly="readonly" value="'+data.nacta+'"/><label> - <?php echo date('Y');?></label><br/>';
                            html+='<div class="ui-corner-all  ui-state-highlight" style="padding:2px" ><p style="font-family: sans-serif;color:#000;font-size:9px; text-align: justify"><span style="float: left; margin-top: .3em; padding-left:0.7em; padding-bottom:0.5em" class="ui-icon ui-icon-info"></span><strong>Aviso: </strong>Recuerde colocar en el documento que esta adjuntando el mismo numero de acta que le muestra el sistema</p></div><br/>';
                    }
                    $("#content-nacta").html(html);
                    $("#dialog_reparo_confirmacion").dialog(
                    {          
                        buttons: {
                            "subir acta": function() { 

                                $('#uploadFile').submit();

                            },"cancelar": function() {
                                $( this ).dialog( "close" );
                                }
                            }

                    });
                    
                }//fin si
             },//fin succes
             error: function (request, status, error) {
              $("#dialog_reparo_confirmacion").dialog('close');
              var html='<p style=" margin-top: 15px">';
                  html+='<span class="ui-icon ui-icon-alert" style="float: left; margin: 0 7px 50px 0;"></span>';
                  html+='Disculpe ocurrio un error de conexion intente de nuevo <br /> <b>ERROR:"'+error+'"</b>';
                  html+='</p><br />';
                  html+='<center><p>';
                  html+='<b>Si el error persiste comuniquese al correo soporte@cnac.gob.ve</b>';
                  html+='</p></center>';
               $("#dialogo-error-conexion").html(html);
               $("#dialogo-error-conexion").dialog('open');
           },
            beforesend:function(){
                
                var div='<div>';
                    div='<p><b>POR FA VOR ESPERE...</b></p><br /><br /><img  src="<?php print(base_url()); ?>include/imagenes/loader.gif" width="35" height="35" />'
                    div+='</div>';
                    ("#content-nacta").html(div);
            }
             
         });//fin ajax  
 };
 sube_acta_reparo=function(form,url){
    $("#error_adjunto").hide();
    $('#carga_img')
      .ajaxStart(function(){
         $(this).show();
         $(this).html('Espere procesando envio...<img  src="<?php print(base_url()); ?>include/imagenes/ajax-loader.gif" />');
      })
      .ajaxComplete(function(){
         $(this).hide();
          //$('#fileToUpload').replaceWith('<input id="fileToUpload" type="file" size="45" name="fileToUpload" class="input">'); 
      });           

            var subir_archivoURL = url;
            $.ajaxFileUpload({
                url : subir_archivoURL,
                secureuri : false,
                fileElementId :'archivo_adjunto',
                dataType : 'json',
                data : { title : $('#descripcion_archivo').val(),autorizacion:$("#fautofis").val(),requerimiento:$("#factareq").val(),recepcion:$("#factarec").val(),tipo_reparo:$("#tipo_reparo").val() },
                success  : function (data) {
            
//                    alert(data.estatus);
                    if(data.estatus){
                        
//                    alert(data.idacta);
                       $("#dialog_reparo_confirmacion").dialog( "close" );
                       $("#espera_crea_reparo").html('<p><b>POR FA VOR ESPERE EL SISTEMA ESTA CEANDO EL REPARO...</b></p><br /><br /><img  src="<?php print(base_url()); ?>include/imagenes/loader.gif" width="35" height="35" />');             
                       espera_crea_reparo();// mensage de espera
                       
                        $.ajax({
                             type:"post",
                             data:{ idconusu:<?php echo $conusuid?>,tcontribu:<?php echo$idcontribu;?>,inspeccionid:<?php echo $inspeccionid?>,idacta:data.idacta,autorizacion:data.autorizacion,requerimiento:data.requerimiento,recepcion:data.recepcion},
                             dataType:"json",
                             url:'<?php echo base_url()."index.php/mod_gestioncontribuyente/fiscalizacion_c/crea_reparo"?>',
                             success:function(result){
                     //             alert(data.vista);
                                 if (result.resultado){
                                     $.unblockUI();//cierra mensaje de espera
                                     $("#espera_crea_reparo").empty();
                                     $('#a0').attr('href','<?php echo base_url()."index.php/mod_gestioncontribuyente/fiscalizacion_c"?>');                    
                                     $("#tabs").tabs("load",0); 

                                 }
                             }

                         });
                    }else{
//                        
                        $('#error_adjunto').html('<p style="font-family: sans-serif;color:#CD0A0A;"><span style="float: left; margin-right: .0em;" class="ui-icon ui-icon-alert"></span><strong>ERROR: </strong>'+data.mensaje+'</p>')
                        $("#error_adjunto").addClass('ui-state-error'); 
                        $("#error_adjunto").show('blind',{ direction: "right" },1000);
//                        $('#descripcion_archivo').val('');
                        $('#archivo_adjunto').val('');
                                      
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
     
 }
 //            script para asignar atributos al listar diseñado con datatables
oTable = $('#listar-detalles').dataTable({
                                "bJQueryUI": true,
                                "sPaginationType": "full_numbers",
                                "oLanguage": {
                                    "oPaginate": {
                                    "sPrevious": "Anterior",
                                    "sNext": "Siguiente",
                                    "sLast": "Ultima",
                                    "sFirst": "Primera"
                                    },

                                    "sLengthMenu": 'Mostrar <select>'+
                                    '<option value="10">10</option>'+
                                    '<option value="20">20</option>'+
                                    '<option value="30">30</option>'+
                                    '<option value="40">40</option>'+
                                    '<option value="50">50</option>'+
                                    '<option value="-1">Todos</option>'+
                                    '</select> registros',

                                    "sInfo": "Mostrando del _START_ a _END_ (Total: _TOTAL_ resultados)",

                                    "sInfoFiltered": " - filtrados de _MAX_ registros",

                                    "sInfoEmpty": "No hay resultados de búsqueda",

                                    "sZeroRecords": "No hay registros a mostrar",

                                    "sProcessing": "Espere, por favor...",

                                    "sSearch": "Buscar:"

                                    }
});

     
     /*
     *function que actualiza los datos del registro mercantil
     */
     actualizar_datos_registromercantil=function(){
//     $('.Actualizar_dfis').click(function(){
      var array_html=new Array('input','textarea','select','textArea');
      var pasa=0;
      // validamos que los elementos dentro del for no se necuentren vacio ni esten bloqueados
         for(var i=0; i<array_html.length; i++)
         {
            $("#frm_actualiza_regempresa").find(array_html[i]).each(function() {
//                alert($(this).val())
                if(($(this).val()=="") || ($(this).attr('disabled')=='disabled') ){
                    
                    pasa=1;
                    return false;
                }

            });
         }
        // evaluamos lo que viene del validador anteriormente señalado si pasa mandamos a actualizar si no mostramos un mensaje de errror
        if(pasa==0){
//             alert($('#frm_actualiza_regempresa').serialize())
             $.ajax({  

                           type:'post',
                           data:$('#frm_actualiza_regempresa').serialize(),
                           dataType:'json',
                           url:'<?php echo base_url()."index.php/mod_gestioncontribuyente/fiscalizacion_c/actualizar_datos_regisro_mercantil"?>',
                           success:function(data){

                            if(data.resultado==true){

                               $("#respuesta-divs").load('<?php echo base_url()."index.php/mod_gestioncontribuyente/fiscalizacion_c/carga_vistas_pestanas_fiscalizacion?vista=datos_registro_mercantil_v&conusuid="?>'+data.conusuid)
                               $('#error-acturegi').html('<p style="font-family: sans-serif;color:#CD0A0A;"><span style="float: left; margin-right: .0em;" class="ui-icon ui-icon-alert"></span><strong>ERROR: </strong>'+ data.mensaje+'</p>')
                               $("#error-acturegi").addClass('ui-state-error'); 
//                $("#error-reparo-activa").css({background:'#FEF6F3',border:'1px solid #CD0A0A'});
                               $("#error-acturegi").show('blind',{ direction: "right" },1000);
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
           
        }else{
            $('#error-acturegi').html('<p style="font-family: sans-serif;color:#CD0A0A;"><span style="float: left; margin-right: .0em;" class="ui-icon ui-icon-alert"></span><strong>ERROR: </strong>Verifique que los campos esten habilitados o que no esten vacios.</p>')
            $("#error-acturegi").addClass('ui-state-error'); 
//                $("#error-reparo-activa").css({background:'#FEF6F3',border:'1px solid #CD0A0A'});
            $("#error-acturegi").show('blind',{ direction: "right" },1000);
        }
      
     }
     // fin funcion que actualiza los datos del registro mercantil 
  
//        $(document).ready(function() {
//            $("#prueba-show").show( "blind", 1000 )
//       });

</script>
        <style>
         /*#listar_wrapper{ width: 80%; margin-left: 10%}*/
        .btnverdatos { width: 10px; height: 15px}

        </style>    



</html>
