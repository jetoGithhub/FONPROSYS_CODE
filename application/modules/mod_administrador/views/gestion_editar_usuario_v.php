<?php



?>
<script>
$(function() {            

     $("#memsajerror").hide();
    validador('frmdatos','<?php echo base_url()."index.php/mod_administrador/gestion_usuario_c/actualizarDatos"; ?>','actualiza_datos');
    $( "#btn-frmdatos" ).button({
                icons: {
                    primary: "ui-icon-tag"
                }
                
      });
      
      $("#btn-frmdatos").click(function(){     
          
                
       $("#frmdatos").submit();    
          
      });    
      
      
      $( "#confirm-datos" ).dialog({   
                autoOpen:false,
                resizable: false,
                show:"clip",
//                width:250,
//                height:200,
                modal: true
      });
 

});

actualiza_datos=function(form,url){
//   alert($("#"+form).serialize())
     $( "#confirm-datos" ).dialog({   
 
                buttons: {
                    "SI": function() {
                        
                           
                            
                             $.ajax({
                            type:"post",
                            data:$("#"+form).serialize(),
                            dataType:"json",
                            url:url,                           
                                success:function(data){

                                    if(data.resultado==true){
                                    //recargar pagina con datos actualizados
//                                    $('#tabs-cine').tabs('load',0)   
                                    
//                                  $('#tabs-cine').load('<?php // echo base_url()."index.php/mod_administrador/principal_c?padre=129"; ?>')
                                               
                                     
                                    $("#confirm-datos").dialog( "close" ); 
                                    $('#memsajerror').html('<p style="font-family: sans-serif; color:#3C3B37"><span style="float: left; margin-right: .3em;"  class="ui-icon ui-icon-info"></span><strong>Alerta: </strong>Datos Actualizados con exito.</p>')
                                    $("#memsajerror").addClass('ui-state-highlight'); 
                                    $("#memsajerror").css({background:'#FAF9EE',border:'1px solid #FEEE12'});
                                    $("#memsajerror").show('drop',1000);   
                                    $("#"+form).reset();
                                    $("#btn-frmdatos").removeAttr('disabled') 


                                    }else{
                                    $( "#confirm-datos").dialog( "close" );
                                    $('#memsajerror').html('<p style="font-family: sans-serif;color:#CD0A0A;"><span style="float: left; margin-right: .3em;" class="ui-icon ui-icon-alert"></span><strong>Alerta: </strong>Error en la actualizacion de datos</p>')
                                    $("#memsajerror").addClass('ui-state-error'); 
                                    $("#memsajerror").css({background:'#FEF6F3',border:'1px solid #CD0A0A'});
                                    $("#memsajerror").show('drop',1000);
                                    $("#"+form).reset();
                                    $("#btn-frmdatos").removeAttr('disabled') 
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
        $('#confirm-datos').html('<span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 0px 0;"></span><b>SEGURO DESEA ACTUALIZAR SUS DATOS?</b>')
        $("#confirm-datos").dialog('open');
        
        

    
}
 
 </script>
<style>
      #contenedor-frmdatos{
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
    #contenedor-frmdatos ,label{
        
       text-align: left;

    } 

    </style>
 <div id="confirm-datos" title="Mensaje Webmaster "></div>   
    
<div id="contenedor-frmdatos"  class="ui-widget-content ui-corner-all"  >
  
<form class="focus-estilo" id="frmdatos">    
    <fieldset class="secciones" style="margin-top:-30px; border:none; "><legend class="ui-widget-content ui-corner-all" style=" color: #654B24" align="center"><h4>Formulario actualizar datos usuario</h4></legend><br />
        
            <label><strong>Usuario:</strong></label><br /> 
                <input name="login" type="text" id="login" size="35" class="requerido  ui-corner-all ui-state-highlight" title="Ingresar Usuario o Login" style=" padding-left: 10px; padding-right: 10px; width:50%; height:20px ;font-size:12px;" value="<?php echo $login;?>" disabled="disabled"/>
            <br /><br /> 
            
            <label><strong>Nombre:</strong></label><br /> 
                <input name="nombre" type="text" id="nombre" size="35" class="requerido  ui-corner-all ui-state-highlight" title="Ingresar Nombre" style=" padding-left: 10px; padding-right: 10px; width:50%; height:20px ;font-size:12px;" value="<?php echo $nombre;?>"/>
            <br /><br />
            
            <label><strong>Cedula de Indentidad:</strong></label><br /> 
                <input name="cedula" type="text" id="cedula" size="35" class="requerido  ui-corner-all ui-state-highlight" title="Ingresar cedula de identidad" style=" padding-left: 10px; padding-right: 10px; width:50%; height:20px ;font-size:12px;" value="<?php echo $cedula;?>" disabled="disabled"/>
            <br /><br />
            
            <label><strong>Correo electronico:</strong></label><br /> 
                <input name="email" type="text" id="email" size="35" class="requerido  ui-corner-all ui-state-highlight" title="Ingresar correo electronico" style=" padding-left: 10px; padding-right: 10px; width:50%; height:20px ;font-size:12px;" value="<?php echo $email;?>"/>
            <br /><br />
            
            <label><strong>Telefono oficina:</strong></label><br /> 
                <input name="telefofc" type="text" id="telefofc" size="35" class="requerido  ui-corner-all ui-state-highlight" title="Ingresar telefono de oficina" style=" padding-left: 10px; padding-right: 10px; width:50%; height:20px ;font-size:12px;" value="<?php echo $telefono;?>"/>
            <br /><br />
            
  </fieldset>  
    <input name="id" type="hidden" value="<?php echo $id; ?>"/>
</form>
    <div style="border: 0px solid blue; width: 15%; height: 20%; margin-top: -40%; margin-left: 68%; position: absolute">
        <img src="<?php echo base_url()."/include/imagenes/gestion_editar_usuarios.png"; ?>"/>
    </div>
    <br />
 <center><button id="btn-frmdatos" style="width:100px; height: 25px; margin-top:-10px; margin-left: 20px; position: relative" title="">Actualizar</button><br /><br /></center>
</div>
<div style="padding: 0 .7em; width: 250px; margin-top: 25px; margin-left: 250px" class="ui-corner-all" id="memsajerror">
		
 </div>