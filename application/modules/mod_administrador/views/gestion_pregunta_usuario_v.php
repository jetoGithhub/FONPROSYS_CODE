<script>
$(function() {            

     $("#memsajerror").hide();
    validador('frmpregsecr','<?php echo base_url()."index.php/mod_administrador/gestion_usuario_c/actualizaPregunta"; ?>','actualiza_preg_secr');
    $( "#btn-frmpregsecr" ).button({
                icons: {
                    primary: "ui-icon-tag"
                }
                
      });
      
      $("#btn-frmpregsecr").click(function(){     
          
                
       $("#frmpregsecr").submit();    
          
      });    
      
      
      $( "#confirm-pregsecr" ).dialog({   
                autoOpen:false,
                resizable: false,
                show:"clip",
//                width:250,
//                height:200,
                modal: true
      });
 

});

actualiza_preg_secr=function(form,url){
//   alert($("#"+form).serialize())
     $( "#confirm-pregsecr" ).dialog({   
 
                buttons: {
                    "SI": function() {
                        
                           
                            
                             $.ajax({
                            type:"post",
                            data:$("#"+form).serialize(),
                            dataType:"json",
                            url:url,                           
                                success:function(data){

                                    if(data.resultado=='true'){
                                     
                                    $("#confirm-pregsecr").dialog( "close" ); 
                                    $('#memsajerror').html('<p style="font-family: sans-serif; color:#3C3B37"><span style="float: left; margin-right: .3em;"  class="ui-icon ui-icon-info"></span><strong>Alerta: </strong>Pregunta Secreta actualizada con exito.</p>')
                                    $("#memsajerror").addClass('ui-state-highlight'); 
                                    $("#memsajerror").css({background:'#FAF9EE',border:'1px solid #FCF0A8'});
                                    $("#memsajerror").show('drop',1000);;    
                                    $("#"+form).reset();
                                    $("#btn-frmpregsecr").removeAttr('disabled') 

                                   }else{
                                    $( "#confirm-pregsecr").dialog( "close" );
                                    $('#memsajerror').html('<p style="font-family: sans-serif;color:#CD0A0A;"><span style="float: left; margin-right: .3em;" class="ui-icon ui-icon-alert"></span><strong>Alerta: </strong>La respuesta actual ingresada es erronea</p>')
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
//                
        $('#confirm-pregsecr').html('<span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 0px 0;"></span><b>SEGURO DESEA ACTUALIZAR SU PREGUNTA SECRETA?</b>')
        $("#confirm-pregsecr").dialog('open');
        
        

    
}
 
 </script>
<style>
      #contenedor-frmpregsecr{
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
    margin-bottom: 50px ;
    color: #000;
    font: 62.5% "arial", sans-serif; 
    font-size: 11px;    
    }
    #contenedor-frmpregsecr ,label{
        
       text-align: left;

    } 

    </style>
 <div id="confirm-pregsecr" title="Mensaje Webmaster"></div>   
    
<div id="contenedor-frmpregsecr"  class="ui-widget-content ui-corner-all"  >
  
<form class="focus-estilo" id="frmpregsecr">    
    <fieldset class="secciones" style="margin-top:-30px; border:none; "><legend class="ui-widget-content ui-corner-all" style=" color: #654B24" align="center"><h4>Actualizar Pregunta Secreta del usuario</h4></legend><br />
        <center><label><strong><?php echo $preactual[0]['nombre']; ?></strong></label><br /><br /></center>
            
         <label><strong>Indique la Respuesta Actual</strong></label><br />             
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
    <input name="id" type="hidden" value="<?php echo $id; ?>"/>
</form>
    <div style="border: 0px solid blue; width: 15%; height: 20%; margin-top: -40%; margin-left: 64%; position: absolute">
        <img src="<?php echo base_url()."/include/imagenes/signo7.png"; ?>"/>
    </div>
    <br />
 <center><button id="btn-frmpregsecr" style="width:100px; height: 25px; margin-top:-10px; margin-left: 20px; position: relative" title="">Actualizar</button><br /><br /></center>
</div>
<div style="padding: 0 .7em; width: 450px; margin-top: 25px; margin-left: 220px" class="ui-corner-all" id="memsajerror">
		
 </div>