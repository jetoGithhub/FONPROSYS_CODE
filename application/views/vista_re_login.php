<?php print($controlador); ?>
<script>
   
    $(function() { 
validador('form_re_login','<?php print($controlador); ?>','envia_re_login');    
 envia_re_login = function(form,url){
        $.ajax({
            type:"post",
            data:$('#'+form).serialize(),
            dataType:"json",
            url:url,
            success:function(data){
            
            if (data.success){
                location.reload();
            }else{
                
                $("#dialog-respuesta_relogin")
                .dialog("open")
                .children("#dialog-respuesta_mensaje_relogin")
                .html(data.message);
            }
            },
            error:function(o,estado,excepcion){
                if(excepcion=='Not Found'){
                }else{
                    
                }
            }});
        }
    
          
        ventana_re_login = function(id_ventana,id_formulario,equis){

     $("#"+id_ventana).dialog({
        show: 'blind',
        modal:true,
        position: ["center","center"]})
	.dialog("open")
	.dialog("option", {
            title: "Mensaje del Sistema",
            buttons : {
                "Validar": function(){
                    $("#"+id_formulario).submit();
                },
                "Cancelar": function(){
                   
                    location.reload();
                }
            }
            })
            .children("#dialog-confirm_message")
            .html("Su sesion ha expirado. ¡Debe logearse nuevamente!");


            if (equis==1){
            $("#"+id_ventana)
            .siblings('.ui-dialog-titlebar')
            .find('a.ui-dialog-titlebar-close')
            .hide();
        }
        }
        ventana_re_login('re_login','form_re_login',1);
        
    
    $("#re_login").dialog({
        show: 'blind',
        resizable:false,
        draggable: false,
        modal: true,
        autoOpen: true,
        hide: "fade",
        stack: true,
        position: ["center","center"]
    });
    $("#dialog-respuesta_relogin").dialog({
        show: 'blind',
        resizable:false,
        draggable: false,
        modal: true,
        autoOpen: false,
        hide: "fade",
        stack: true,
        position: ["center","center"]
    });
   
    $(".btn").button();
    $(" input ").addClass('ui-state-highlight ui-corner-all');
    $(" select ").addClass('ui-state-highlight ui-corner-all');
    $(" textarea ").addClass('ui-state-highlight ui-corner-all'); 
    
    });
</script>

<div id="re_login">

    <fieldset class="ui-widget-content ui-corner-all ">
        <legend class="ui-widget-content ui-corner-all" style="border:1px solid #654b24;color:#654b24;padding: 0.7em;">
            Inicio de Sesion
        </legend>

        <table>
            <tr>
                <td>
                    <form id="form_re_login">
                        <label for="reusuario">Usuario:</label>
                        <input  type="text" name="reusuario" id="reusuario" class="requerido  ui-widget-content ui-corner-all"  />

                        <br/>
                        <label for="reclave">Clave de acceso:</label>
                        <input type="password" name="reclave" id="reclave" class="requerido  ui-widget-content ui-corner-all" />

                        <br/>

                    </form>
                </td>
                <td>
                    <img  src="<?php print(base_url()); ?>include/imagenes/token_caducado.png" width="99%" height="100" />
                </td>
            </tr>
            </table>
        </fieldset><br/>
                <div id="title_re" class="ui-state-highlight ui-corner-all">
            <p>Su sesion ha expirado por inactividad prolongada.
            Debe logearse nuevamente en el sistema.</p>
        </div>
<!--    <div class="ui-widget ui-helper-clearfix"></div>-->

<!--    <button id="btn_re_inicia_cont" class="btn">Iniciar Sesion</button>-->
 
    
</div>
<div id="dialog-respuesta_relogin" title="Mensaje">
    <p id="dialog-respuesta_mensaje_relogin"></p>
</div>
<style>
#re_login input select { display:block; height:20px;font-size: 11px;}
#re_login label{  font-size: 12px;}
#title_re{  font-size: 11px;padding: 0.7em;}
#btn_re_inicia_cont{ float:right }   

</style>