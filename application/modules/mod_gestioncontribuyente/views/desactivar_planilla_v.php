 <script>
    $(function() {
        //funcion para la validacion
        //Parametros: id del form, url del controlador, metodo ajax para el submit del boton
        validador('envio_observacion','<?php echo base_url()."index.php/mod_gestioncontribuyente/buscar_planilla_c/envia_correo"; ?>','envio_observ');
        //funcion para el cambio de estilo de los radiobutton
        $( "#radio" ).buttonset();

    });
    
    //funcion que indicara el proceso a realizar una vez que se haga succes al boton enviar
                                envio_observ=function(form,url){
                                    alert('<?php echo $infoplanilla['rif']; ?>');
                                    $.ajax({
                                        type:"get",
                                        data: $("#"+form).serialize(),
                                        dataType:"json",
                                        url:url+'?rif=<?php echo $infoplanilla['rif']; ?>',
                                        success:function(data){
                                            
                                            $('#falta_doc_enviar_correo').dialog('close')
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


<!--        <script type="text/javascript" src="<?php // echo base_url()."include/js/latest/markitup/jquery.markitup.js"; ?>"></script>
        <script type="text/javascript" src="<?php // echo base_url()."include/js/latest/markitup/sets/default/set.js"; ?>"></script>
        
        <link rel="stylesheet" type="text/css" href="<?php // echo base_url()."include/js/latest/markitup/skins/markitup/style.css"; ?>" />
        <link rel="stylesheet" type="text/css" href="<?php // echo base_url()."include/js/latest/markitup/sets/default/style.css"; ?>" />
-->

<form id="envio_observacion" style=" margin-top: 35px">
         <table border="0" id="sample">
             <tr><td><b>Contribuyente:</b> <br/><?php echo  $infoplanilla['razonsocial']; ?><br/><br/></td></tr>
             <tr>
                 <td><b>Email:</b> <br/><?php echo  $infoplanilla['email']; ?><br/><br/></td>
                 <td><img src="<?php echo base_url()."/include/imagenes/send.png"; ?>"/></td>
             </tr>
             <tr>
                <td colspan="2">
                    <b>Mensaje: </b>
                    <textarea name="mensaje" id="mensaje" rows="10%" cols="60%" class="requerido"></textarea>      
               </td>
            </tr>
        </table>
</form>


    
     