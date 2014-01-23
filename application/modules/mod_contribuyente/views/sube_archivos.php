
<script type="text/javascript" >
    $(function() {
        $(" input ").addClass('ui-state-highlight ui-corner-all');
      validador('uploadFile','<?php print(base_url()); ?>index.php/mod_contribuyente/filecontroller/subir_archivo','sube_archivo_img');
      
        sube_archivo_img = function(form,url){
       $('#carga_img')
      .ajaxStart(function(){
         $(this).show();
         $(this).html('Espere procesando envio...<img  src="<?php print(base_url()); ?>include/imagenes/ajax-loader.gif" />');
      })
      .ajaxComplete(function(){
         $(this).hide();
          //$('#fileToUpload').replaceWith('<input id="fileToUpload" type="file" size="45" name="fileToUpload" class="input">'); 
      });           
//        $('#uploadFile').submit(function(e) {
//            e.preventDefault();
            var subir_archivoURL = url;
            $.ajaxFileUpload({
                url : subir_archivoURL,
                secureuri : false,
                fileElementId :'archivo_adjunto',
                dataType : 'json',
                data : { 'title' : $('#descripcion_archivo').val() },
                success  : function (data) {
                    if(data.estatus){
                        
                        $(".userDialog")
                        .html("<span class='ui-icon ui-icon-check' style='float: left; text-align: left;margin-right: 0.3em;' />"+data.mensaje+"</span>")
                        .show('blind',500);
                        setTimeout("$('.userDialog').hide('blind',1000);" , 5000);
                    }else{
                        
                         $(".userDialog")
                        .html("<span class='ui-icon ui-icon-alert' style='float: left;text-align: left; margin-right: 0.3em;'/>"+data.mensaje+" </span>")
                        .show('blind',500);
                        setTimeout("$('.userDialog').hide('blind',1000);" , 5000);               
                    }
                    $("#trae_datos").load(
                        "<?php print(base_url()); ?>index.php/mod_contribuyente/filecontroller/lista_documentos", 
                        function(response, status, xhr) {
                            if (status == "error") {
                                var msg = "ERROR AL CONECTAR AL SERVIDOR:";
                                
                                $(".userDialog")
                                .html("<span class='ui-icon ui-icon-alert' style='float: left; text-align: left;margin-right: 0.3em;' >"+msg+"</span>")
                                .show('blind',500);
                                setTimeout("$('.userDialog').hide('blind',1000);" , 5000); 
  }
});                 
                    
                    if(data.estatus != 'error') {
                        $('#descripcion_archivo').val('');
                    }
                }
//                ,beforeSend:function(){
//                    //$('#cargando').hide();
//                    alert('hola');
//                    $("#carga_img").empty();
//                    $('#carga_img').show();
//                    $('#carga_img').html('Espere procesando envio...<img  src="<?php print(base_url()); ?>include/imagenes/ajax-loader.gif" />');
////                    $("#btn_form_restaura").attr('disabled','disabled');
//                },complete: function(){
////                    $('#carga_img').hide();
//                }
            })
//                });
}
        $( ".btn_sube" ).button({
            icons: {
                primary: "ui-icon-circle-arrow-n"
            }
            
        });
        $(".btn_sube").click(function() {
        $('#uploadFile').submit();
    });
});
                
</script>
<style type="text/css" >
    .userDialog{
        display: none;
    }
    #sec{
        border-top:2px solid #654b24;
        border-bottom: 0px;
        border-left: 0px;
        border-right: 0px;
    }
    #sec legend{
        border:0px solid #654b24;
        color:#654b24;
        /*padding: 0 .1em;*/
    }
    #sec label input select file{ 
        display:block; 
        height:20px;
        font-size: 12px;
    }
</style>
<br/><br/>
<fieldset id="sec" class=' ui-widget-content ui-corner-all' style="width: 77%; margin-left: 10%;border:1px solid #654b24;"><legend class="ui-widget-content ui-corner-all"  ><h3>Documentos Requeridos</h3></legend>
    
        <table border="0" width="100%">
            <tr>
                <td width="50%"> 
                    <form action="" method="post" id="uploadFile" >
                        <label ><strong>Descripci&oacute;n</strong></label><br/>
                        <input class="requerido" mensaje="Debe especificar la descripcion del archivo" type="text" name="descripcion_archivo" id="descripcion_archivo" size="20"/><br/>
                         <label ><strong>Adjuntar Archivo</strong></label><br/>
                        <input class="requerido" mensaje="Debe Adjuntar el Archivo" type="file" id="archivo_adjunto" name="archivo_adjunto" size="14" /><br/><br/>
                        <button type="button" class="btn_sube" > Cargar Documento </button>
                        
                    </form>
                                        
                </td>
                <td>
                    <center>
                        <img  width="100" height="100" src="<?php print(base_url()); ?>include/imagenes/subir-archivos-internet.png" />
                    </center>
                </td>
            </tr>
            <tr>
                <td colspan="2">
                    
                    <div style="width:70%;border:0px #000 solid;" class="userDialog"></div>
                </td>
            </tr>
        </table>


           
    
</fieldset>

<div id="carga_img"></div>
<br/>
<div id="trae_datos"><?php print($total);?></div>
