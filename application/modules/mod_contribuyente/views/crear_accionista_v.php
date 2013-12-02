<?php



?>
<script>
$(function() {            

     
    validador('frm_accionista','<?php echo base_url()."index.php/mod_contribuyente/contribuyente_c/guarda_accionista"; ?>','guarda_accionista');
    
        
 

});

guarda_accionista=function(form,url) {
    
    $.ajax({
        type:"post",
        data:$('#'+form).serialize(),
        dataType:"json",
        url:url,
        success:function(data){
            
            if(data.resultado==true){
                $("#frmaccionista").dialog( "close" );
                //$("#tabs").tabs("load",1);
                $("#trae_accionistas").load(
                    "<?php print(base_url()); ?>index.php/mod_contribuyente/contribuyente_c/carga_accionista", 
                        function(response, status, xhr) {
                            if (status == "error") {
                                var msg = "ERROR AL CONECTAR AL SERVIDOR:";
                                
                                $(".userDialog")
                                .html("<span class='ui-icon ui-icon-alert' style='float: left; text-align: left;margin-right: 0.3em;' >"+msg+"</span>")
                                .show('blind',500);
                                setTimeout("$('.userDialog').hide('blind',1000);" , 5000);
                            }});                 
            }    
           
            
        },
        error:function(o,estado,excepcion){
             if(excepcion=='Not Found'){
                 
             }else{
                 
             }
         }
     });
     
    
}

 
 </script>
<style>
    

    </style>
 
<form id="frm_accionista" class=" form-style focus-estilo">
    <input name="idcontribu" type="hidden" id="idcontribu" size="25" value="<?php echo $contribuid;?>" />
<!--        <table>
            <tr>
                <td>-->
                    <label><strong>Nombre</strong></label>
                    <input name="nombre" type="text" id="nombre" size="25" style=" height: 20px; " class=" ui-state-highlight ui-corner-all requerido" /><br />
                    
<!--                </td>
                <td>-->
                     <label><strong>Apellido</strong></label>
                    <input name="apellido" type="text" id="apellido" size="25" style=" height: 20px;" class=" ui-state-highlight ui-corner-all requerido"/><br />
<!--                </td>    
                
            </tr>
            <tr>
                
                <td colspan="2"> -->
                    <label><strong>Domicilio fiscal</strong></label><br/>
                    <textarea name="dfiscal" id="dfiscal" size="25"  class=" ui-state-highlight ui-corner-all requerido" ></textarea><br />
<!--                </td>
                  
            </tr>
            <tr>
                <td>                -->
                     <label><strong>Cedula de identidad</strong></label>
                    <input name="cedula" type="text" id="cedula" size="25" style=" height: 20px; " class=" ui-state-highlight ui-corner-all requerido"/><br /> 
<!--                </td>
                <td>-->
                    <label><strong>Numero de acciones</strong></label>
                    <input name="nacciones" type="text" id="nacciones" size="25" style=" height: 20px;" class=" ui-state-highlight ui-corner-all requerido" /><br />
                    
<!--                </td>
              
            </tr>-->
           
              
            
        </table>        
           

</form>
