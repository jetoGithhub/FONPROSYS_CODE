<?php



?>
<script>
$(function() {  
    
//      $('#cargando-pregunta').ajaxStart(function(){$(this).show();});
//  
//      $('#cargando-pregunta').ajaxComplete(function(){$(this).hide(); }); 
//    jQuery.fn.reset = function () {
//      $(this).each (function() { this.reset(); });
//    }
     $("#memsajerror-pregunta").hide();
//     $('#cargando-pregunta').hide();
    validador('frmrespuesta','<?php echo base_url()."index.php/mod_contribuyente/gestion_pregunta_secreta_c/actualizaPregunta"; ?>','actualiza_respuesta');
    $( "#btn-frmrespuesta" ).button({
                icons: {
                    primary: "ui-icon-tag"
                }
                
      });
      
      $("#btn-frmrespuesta").click(function(){     
          
                
       $("#frmrespuesta").submit();    
          
      });    
      
 

});

actualiza_respuesta=function(form,url){
//   alert($("#"+form).serialize())
     
     $( "#confirm-respuesta" ).dialog({   
                resizable: false,
                show:"clip",
//                width:250,
//                height:200,
                modal: true,
                buttons: {
                    "SI": function() {
                        
                            $("#confirm-respuesta").dialog( "close" ); 
                             $("#btn-frmrespuesta").attr('disabled','disabled')
                             $.ajax({
                            type:"post",
                            data:$("#"+form).serialize(),
                            dataType:"json",
                            url:url,                           
                                success:function(data){

                                    if(data.resultado=='true'){
                                    $('#tabs').tabs('load',0)    
                                     
                                    $('#memsajerror-pregunta').html('<p style="font-family: sans-serif; color:#3C3B37"><span style="float: left; margin-right: .3em;"  class="ui-icon ui-icon-info"></span><strong>Alerta: </strong>Pregunta secreta Actualizada con exito.</p>')
                                    $("#memsajerror-pregunta").addClass('ui-state-highlight'); 
                                    $("#memsajerror-pregunta").css({background:'#FAF9EE',border:'1px solid #FCF0A8'});
                                    $("#memsajerror-pregunta").show('drop',1000);;    
                                    $("#"+form).reset();
                                     $("#btn-frmrespuesta").removeAttr('disabled') 



                                    }else{
                                    
                                    $('#memsajerror-pregunta').html('<p style="font-family: sans-serif;color:#CD0A0A;"><span style="float: left; margin-right: .3em;" class="ui-icon ui-icon-alert"></span><strong>Alerta: </strong>Respuesta Actual Invalidad Verifique.</p>')
                                    $("#memsajerror-pregunta").addClass('ui-state-error'); 
                                    $("#memsajerror-pregunta").css({background:'#FEF6F3',border:'1px solid #CD0A0A'});
                                    $("#memsajerror-pregunta").show('drop',1000);
                                    $("#"+form).reset();
                                     $("#btn-frmrespuesta").removeAttr('disabled') 
                                    }
                                    
                                }
                            });// fin del ajax
                            

                        },
                    "NO": function() {
                        $( this ).dialog( "close" );
                        
                        
                        
                        
                    }
                    
                }
                
            });
//                
        $('#confirm-respuesta').html('<span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 0px 0;"></span><b>SEGURO DESEA ACUTUALIZAR SU PREGUNTA SECRETA..?</b>')
        $("#confirm-respuesta").dialog('open');
    
}
 
 </script>
<style>
      #contenedor-frmrespuesta{
      width: 400px;
      left:25%;
      margin-top:50px;
      position: relative;
      /*background:#CFCFCF;*/
      border:1px solid #654B24;    
      -moz-box-shadow: 3px 3px 4px #111;
      -webkit-box-shadow: 3px 3px 4px #111;
      box-shadow: 3px 3px 4px #111;
      /* IE 8 */
     -ms-filter: "progid:DXImageTransform.Microsoft.Shadow(Strength=4, Direction=135, Color='#111111')";
    /* IE 5.5 - 7 */
    filter: progid:DXImageTransform.Microsoft.Shadow(Strength=4, Direction=135, Color='#111111');    
    margin-bottom: 50px;
    color: #000;
    font: 62.5% "arial", sans-serif; 
    font-size: 11px;     
       
    }
    #contenedor-frmrespuesta ,label{
        
       text-align: left;
       /*margin-left: 10px*/
       
       
    } 
      #frmrespuesta ,input{
        
       /*margin-left: 20px;*/
/*       width: 100%;*/
/*       padding-left: 10px;
       padding-right: 10px*/
       
    }
    
    </style>
     
 <div id="confirm-respuesta" title="Mensaje Webmaster "></div>   
 
 
<div id="contenedor-frmrespuesta" class="ui-widget-content ui-corner-all">
  
    
    <form id="frmrespuesta">    
    <fieldset class="secciones" style="margin-top:-30px; border:none;"><legend class="ui-widget-content ui-corner-all" style=" color: #654B24" align="center"><h4>Formulario Cambio de Pregunta Secreta</h4></legend><br />
          
            <center><label><strong><?php echo $preactual[0]['nombre']; ?></strong></label><br /><br /></center>
            
            <label><strong>Indique la Respuesta</strong></label><br />             
            <input type="password" id="respactual" name="respactual" class="requerido  ui-corner-all ui-state-highlight" style="width:50%; height:20px ;font-size:12px;"  />
            <br /><br />
            
            <label><strong>Nueva Pregunta Secreta</strong></label><br />   
           <select name="nombre_pregunta" class="requerido ui-state-highlight" id="nombre_pregunta" style="width: 50%;  height:20px ;font-size:12px;">
                <option value="">Seleccione pregunta secreta</option>
                <?php
               if (sizeof($preguntas)>0):
                   foreach ($preguntas as $pregunta):
                   print("<option value='$pregunta[id]'>$pregunta[nombre]</option>");
                   endforeach;
               endif;

               ?>     

            </select> 
            <br /><br />
            
             <label><strong>Nueva Respuesta Secreta</strong></label><br />  
            <input type="password" id="respnueva" name="respnueva" class="requerido  ui-corner-all ui-state-highlight" style=" width:50%; height:20px ;font-size:12px;"  />
            <br /><br />
            
            <label><strong>Repita Respuesta Secreta</strong></label><br />  
            <input type="password" condicion=' equalTo: "#respnueva"' id="respnuevarep" name="respnuevarep" class="requerido  ui-corner-all ui-state-highlight" style=" width:50%; height:20px ;font-size:12px;"  />
    
 </fieldset>
    
</form>
    <div style="border: 0px solid blue; width: 15%; height: 20%; margin-top: -40%; margin-left: 58%; position: absolute">
        <img src="<?php echo base_url()."/include/imagenes/signo7.png"; ?>"/>
    </div>
    <br />
 <button id="btn-frmrespuesta"  style="width:100px; height: 25px; margin-top:-10px; margin-left: 40%; position: relative" title="">Actualizar</button><br /><br />
</div>
<div style="padding: 0 .7em; width: 450px; margin-top: 25px; margin-left: 220px" class="ui-corner-all" id="memsajerror-pregunta">
		
 </div>