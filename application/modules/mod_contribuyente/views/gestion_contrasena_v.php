<?php



?>
<script>
$(function() {            
//    jQuery.fn.reset = function () {
//      $(this).each (function() { this.reset(); });
//    }
     $("#memsajerror").hide();
    validador('frmcontrasena','<?php echo base_url()."index.php/mod_contribuyente/gestion_contrasena_c/actualizaContrasena"; ?>','actualiza_contrasena');
    $( "#btn-frmcontrasena" ).button({
                icons: {
                    primary: "ui-icon-tag"
                }
                
      });
      
      $("#btn-frmcontrasena").click(function(){     
          
                
       $("#frmcontrasena").submit();    
          
      });    
      
 

});

actualiza_contrasena=function(form,url){
//   alert($("#"+form).serialize())
     $( "#confirm-contraseña" ).dialog({   
                resizable: false,
                show:"clip",
//                width:250,
//                height:200,
                modal: true,
                buttons: {
                    "SI": function() {
                        
                           
                            
                             $.ajax({
                            type:"post",
                            data:$("#"+form).serialize(),
                            dataType:"json",
                            url:url,                           
                                success:function(data){

                                    if(data.resultado=='true'){
                                        
                                      $("#confirm-contraseña").dialog( "close" ); 
                                    $('#memsajerror').html('<p style="font-family: sans-serif; color:#3C3B37"><span style="float: left; margin-right: .3em;"  class="ui-icon ui-icon-info"></span><strong>Alerta: </strong>Contraeña Actualizada con exito.</p>')
                                    $("#memsajerror").addClass('ui-state-highlight'); 
                                    $("#memsajerror").css({background:'#FAF9EE',border:'1px solid #FCF0A8'});
                                    $("#memsajerror").show('drop',1000);;    
                                    $("#"+form).reset();
                                    $("#btn-frmcontrasena").removeAttr('disabled') 


                                    }else{
                                    $( "#confirm-contraseña").dialog( "close" );
                                    $('#memsajerror').html('<p style="font-family: sans-serif;color:#CD0A0A;"><span style="float: left; margin-right: .3em;" class="ui-icon ui-icon-alert"></span><strong>Alerta: </strong>Contraeña Actual Invalidad Verifique.</p>')
                                    $("#memsajerror").addClass('ui-state-error'); 
                                    $("#memsajerror").css({background:'#FEF6F3',border:'1px solid #CD0A0A'});
                                    $("#memsajerror").show('drop',1000);
                                    $("#"+form).reset();
                                    $("#btn-frmcontrasena").removeAttr('disabled') 
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
        $('#confirm-contraseña').html('<span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 0px 0;"></span><b>SEGURO DESEA ACUTUALIZAR SU CONTRASEÑA..?</b>')
        $("#confirm-contraseña").dialog('open');
    
}
 
 </script>
<style>
      #contenedor-frmcontrasena{
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
    #contenedor-frmcontrasena ,label{
        
       text-align: left;
       /*margin-left: 10px*/
       
       
    } 
      #frmcontrasena ,input{
        
       /*margin-left: 20px*/
/*       width: 100%;*/
/*       padding-left: 10px;
       padding-right: 10px*/
       
    }
/*    .secciones legend {
    border: 1px solid #654B24;
    color: #654B24;
    padding: 0 0.7em;
    }*/
   
    
    </style>
 <div id="confirm-contraseña" title="Mensaje Webmaster "></div>   
    
<div id="contenedor-frmcontrasena"  class="ui-widget-content ui-corner-all"  >
  
<form id="frmcontrasena">    
    <fieldset class="secciones" style="margin-top:-30px; border:none; "><legend class="ui-widget-content ui-corner-all" style=" color: #654B24" align="center"><h4>Formulario Cambio de Contrase&ntilde;a</h4></legend><br />
        
            <label><strong>Ingrese la Contrase&ntilde;a Actual</strong></label><br />   
            <input type="password" id="clvactual" name="clvactual" class="requerido  ui-corner-all ui-state-highlight" style=" padding-left: 10px; padding-right: 10px; width:50%; height:20px ;font-size:12px;"  />
            <br /><br />
            <label><strong>Ingrese la Nueva Contrase&ntilde;a</strong></label><br />   
            <input type="password" condicion="minlength:6" id="clvnueva" name="clvnueva" class="requerido ui-corner-all ui-state-highlight" style=" padding-left: 10px; padding-right: 10px; width:50%; height:20px ;font-size:12px;"  />
            <br /><br />
            <label><strong>Repita la nueva contrase&ntilde;a</strong></label><br />   
            <input type="password" condicion='minlength: 6, equalTo: "#clvnueva"' id="clvnuevarepetida" name="clvnuevarepetida" class="requerido  ui-corner-all ui-state-highlight" style=" padding-left: 10px; padding-right: 10px; width:50%; height:20px ;font-size:12px;"  />
    
 
  </fieldset>  
</form>
    <div style="border: 0px solid blue; width: 15%; height: 20%; margin-top: -40%; margin-left: 62%; position: absolute">
        <img src="<?php echo base_url()."/include/imagenes/img_form_contrasenia.png"; ?>"/>
    </div>
    <br />
 <center><button id="btn-frmcontrasena" style="width:100px; height: 25px; margin-top:-10px; margin-left: 20px; position: relative" title="">Actualizar</button><br /><br /></center>
</div>
<div style="padding: 0 .7em; width: 450px; margin-top: 25px; margin-left: 220px" class="ui-corner-all" id="memsajerror">
		
 </div>