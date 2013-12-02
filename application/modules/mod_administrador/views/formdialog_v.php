<script>
 jQuery(function($){
    // jQuery Mask Plugin v0.11.4
    // github.com/igorescobar/jQuery-Mask-Plugin
    (function(l){var m=function(g,h,k){var a=this;g=l(g);a.init=function(){k=k||{};a.byPassKeys=[8,9,37,38,39,40,46];a.maskChars={":":":","-":"-",".":"\\.","(":"\\(",")":"\\)","/":"/",",":",",_:"_"," ":"\\s","+":"\\+"};a.translationNumbers={0:"\\d",1:"\\d",2:"\\d",3:"\\d",4:"\\d",5:"\\d",6:"\\d",7:"\\d",8:"\\d",9:"\\d"};a.translation={A:"[a-zA-Z0-9]",S:"[a-zA-Z]"};a.translation=l.extend({},a.translation,a.translationNumbers);a=l.extend(!0,{},a,k);a.specialChars=l.extend({},a.maskChars,a.translation);
    g.each(function(){h=c.resolveMask();h=c.fixRangeMask(h);g.attr("maxlength",h.length).attr("autocomplete","off");c.destroyEvents();c.keyUp();c.paste()})};var c={paste:function(){g.on("paste",function(){setTimeout(function(){g.trigger("keyup")},100)})},keyUp:function(){g.on("keyup",c.maskBehaviour).trigger("keyup")},destroyEvents:function(){g.off()},resolveMask:function(){return"function"==typeof h?h(c.val(),k):h},val:function(b){var f="input"===g.get(0).tagName.toLowerCase();return 0<arguments.length?
    f?g.val(b):g.text(b):f?g.val():g.text()},specialChar:function(b,f){return a.specialChars[b.charAt(f)]},maskChar:function(b,f){return a.maskChars[b.charAt(f)]},maskBehaviour:function(b){b=b||window.event;var f=b.keyCode||b.which,e=c.applyMask(h);if(-1<l.inArray(f,a.byPassKeys))return c.seekCallbacks(b,e);e!==c.val()&&c.val(e).trigger("change");return c.seekCallbacks(b,e)},applyMask:function(b){if(""!==c.val()){var f=function(b,a){for(;a<b.length;){if(void 0!==b[a])return!0;a++}return!1},e=function(a){a=
    "string"===typeof a?a:a.join("");a=a.match(RegExp(c.maskToRegex(b)))||[];a.shift();return a},d=c.val();b=c.getMask(d,b);for(var d=k.reverse?c.removeMaskChars(d):d,a=e(d);a.join("").length<c.removeMaskChars(d).length;)a=a.join("").split(""),d=c.removeMaskChars(a.join("")+d.substring(a.length+1)),b=c.getMask(d,b),a=e(d);for(d=0;d<a.length;d++)if(e=c.specialChar(b,d),c.maskChar(b,d)&&f(a,d))a[d]=b.charAt(d);else if(e)if(void 0!==a[d]){if(null===a[d].match(RegExp(e)))break}else if(null==="".match(RegExp(e))){a=
    a.slice(0,d);break}return a.join("")}},getMask:function(a){if(k.reverse){a=c.removeMaskChars(a);for(var f=0,e=0,d=0,f=h.length,e=f=1<=f?f:f-1;d<a.length;){for(;c.maskChar(h,e-1);)e--;e--;d++}e=1<=h.length?e:e-1;a=h.substring(f,e)}else a=h;return a},maskToRegex:function(a){for(var f,e=0,d="";e<a.length;e++)(f=c.specialChar(a,e))&&(d+="("+f+")?");return d},fixRangeMask:function(b){return b.replace(/([A-Z0-9])\{(\d+)?,([(\d+)])\}/g,function(){var b=arguments,e=[],d=a.translationNumbers[b[1]]?String.fromCharCode(parseInt("6"+
    b[1],16)):b[1].toLowerCase();e[0]=b[1];e[1]=Array(b[2]-1+1).join(b[1]);e[2]=Array(b[3]-b[2]+1).join(d).toLowerCase();a.specialChars[d]=c.specialChar(b[1])+"?";return e.join("")})},removeMaskChars:function(b){l.each(a.maskChars,function(c,e){b=b.replace(RegExp("("+a.maskChars[c]+")?","g"),"")});return b},seekCallbacks:function(a,c){if(k.onKeyPress&&void 0===a.isTrigger&&"function"==typeof k.onKeyPress)k.onKeyPress(c,a,g,k);if(k.onComplete&&void 0===a.isTrigger&&c.length===h.length&&"function"==typeof k.onComplete)k.onComplete(c,
    a,g,k)}};"boolean"===typeof QUNIT&&(a.p=c);a.remove=function(){c.destroyEvents();c.val(c.removeMaskChars(c.val())).removeAttr("maxlength")};a.getCleanVal=function(){return c.removeMaskChars(c.val())};a.init()};l.fn.mask=function(g,h){return this.each(function(){l(this).data("mask",new m(this,g,h))})};l("input[data-mask]").each(function(){l(this).mask(l(this).attr("data-mask"))})})(window.jQuery||window.Zepto);
    $('.basei').mask('000.000.000.000.000,00', {reverse: true});
    $('#tpagado').mask('000.000.000.000.000,00', {reverse: true});

}); 


</script>
<?
    if($identificador==0){
        
?>
<script> 
        $(function(){
    
        validador('frmarmamenu','<?php echo base_url()."index.php/mod_administrador/principal_c/insertar_padre"; ?>','envia_tabs');
     

     
        });
        
</script>
<!--<style>
#frmarmamenu label, #dialog input { display:block; }
#frmarmamenu label { margin-top: 0.5em; }
#frmarmamenu input , #frmarmamenu textarea { width: 95%; }
#frmarmamenu select { width: 95%; }
 #frmarmamenu .ui-combobox-input{width: 220px; }
</style>-->
  
<form class="form-style focus-estilo" id="frmarmamenu" > 
    <input type="hidden" name="idmpadre" id="idmpadre" value="<?php echo $id; ?>"  /> 
    
    <label class="label" >Nombre del modulo: </label></br> 
    <!--onkeyup="javascript:this.value=this.value.toUpperCase();"-->
    <input  type="text"  name="nombreMP" id="nombreMP" class=" requerido ui-widget-content ui-corner-all" />

    <label class="label" >Descripcion del modulo:</label></br> 
    <input class="  requerido ui-widget-content ui-corner-all" type="text" name="descripcionMP" id="descripcionMP"   />

    <label class="label" >Ruta del controlador:</label> </br> 
    <input name="controladorMP" value="./mod_administrador/principal_c" type="text" readonly class=" requerido ui-widget-content ui-corner-all" id="controladorMP"  />
    
    <label class="label" >Grupos disponibles:</label> </br> 
     <select name="nombre_grupo" class="requerido ui-widget-content ui-corner-all" id="nombre_grupo" title="Seleccione el Tipo de Requerimiento">
         <option value="">Seleccione Grupo</option>
         <?php
        if (sizeof($slect_rol)>0):
            foreach ($slect_rol as $rol):
            print("<option value='$rol[id_rol]'>$rol[nombre]</option>");
            endforeach;
        endif;

        ?>     

    </select> 
    
</form> 
<?php 
}

if($identificador==1){
?>
<script> 
    $(function(){

        validador('crea-tabs','<?php echo base_url()."index.php/mod_administrador/principal_c/insertar_hijo"; ?>','envia_tabs');



    });
        
</script>
<!--<style>
#crea-tabs label, #dialog input { display:block; }
#crea-tabs label { margin-top: 0.5em; }
#crea-tabs input , #frmarmamenu textarea { width: 95%; }
#crea-tabs select { width: 95%; }
 #crea-tabs .ui-combobox-input{width: 220px; }
</style>-->

<form class="form-style focus-estilo" id="crea-tabs">
    <!--<fieldset class="ui-helper-reset">-->
    <input type="hidden" name="idpadre" id="idpadre" value="<?php echo $id;?>" />
    
    <label >Nombre del sub-modulo</label>
    <input type="text" name="nombreM" id="nombreM" value="" class="requerido ui-widget-content ui-corner-all" />
    
    <label >Descripcion del sub-modulo</label>
    <textarea type="text" name="descripcionM" id="descripcionM" value=""class="requerido ui-widget-content ui-corner-all" /></textarea>
    
    <label >Url del Metodo</label>
    <input name="urlM" id="urlM" class=" requerido ui-widget-content ui-corner-all" />
    <!--</fieldset>-->
</form>
<?
}

if($identificador==2){
?>
<script>

    $(function(){
           
        validador('form_carga_asignacion','<?php echo base_url()."index.php/mod_administrador/principal_c/insertar_hijo"; ?>','busca_alicuota_omisos');
    
       

    });

    

  carga_anio_omiso=function(valor,anio){
            
  $.ajax({       
       type:'post',
       data:{tcontribuid:valor},
       dataType:'json',
       url:'<?php echo base_url()."index.php/mod_contribuyente/contribuyente_c/carga_anio_declara"; ?>',
       success:function(data){
           
           if(data.resultado=='true'){
               if(data.tipo==2){
//               if(data.tipo!=2){
//                   var select='<select name="anio" class=" requerido ui-widget-content ui-corner-all" id="anio" onChange=" carga_periodo_omiso(this.value)" >';
//                       select+='</select>';
//                    $('#tperiodo').empty();   
//                    $('#anio').empty(); 
//                    $('#tperiodo').html('<option value="">Seleccione</option>');
//                    $("#tdanioD").html(select);   
//                    $("#anio-declara").show();                    
//                    $('#anio').html(data.aniosD);
//                    
//               }else{
                   
                   $("#tdanioD").empty();
                   $("#anio-declara").hide();
                   $('#periodo').html('<option value="">Seleccione</option><option value="'+anio+'">'+anio+'</option>');
//                   $('#periodo').html(data.htmloption);
               }
               

              
               
           }
           
       }
    });
    
}
        
carga_periodo_omiso=function(valor){
//alert(valor)
       $.ajax({       
       type:'post',
       data:{tcontribuid:$('#tcontribuid').val(),anio:valor},
       dataType:'json',
       url:'<?php echo base_url()."index.php/mod_contribuyente/contribuyente_c/carga_periodo"; ?>',
       success:function(data){
           
           if(data.resultado=='true'){       
                  if(data.htmloption==false){
                      
                        $('#periodo').empty();   
                        $('#periodo').html('<option value="">Seleccione</option>');
                         
                  }else{
                      
                        $('#periodo').html(data.htmloption);
                  }
           }
           
       }
    });
    
}


busca_alicuota_omisos=function(){
var data=$('#form_carga_asignacion').serialize();

    $('#dialog-cargafis').dialog( "close" );  
    $.ajax({       
           type:'post',
           data:data,
           dataType:'json',
           url:'<?php echo base_url()."index.php/mod_gestioncontribuyente/fiscalizacion_c/carga_detalles_fizcalizacion"; ?>',
           success:function(data){

               if(data.resultado==true){
               
                var current_index = $("#tabs").tabs("option","selected");             
                $("#tabs").tabs("load",current_index);   
                 
               }else{

                   if(data.existe_p){

                       
                        $('#memsajerror').html('<p style="font-family: sans-serif;color:#CD0A0A;"><span style="float: left; margin-right: .3em;" class="ui-icon ui-icon-alert"></span><strong>Alerta: </strong>El periodo ya se encuentra cargado<br /><center> "PARA CORREGIR ELIMINE EL ANTERIOR"</center></p>')
                        $("#memsajerror").addClass('ui-state-error'); 
                        $("#memsajerror").css({background:'#FEF6F3',border:'1px solid #CD0A0A'});
                        $("#memsajerror").show('drop',1000);

                   }
                    if(data.faltadeclara){

                       
                        $('#memsajerror').html('<p style="font-family: sans-serif;color:#CD0A0A;"><span style="float: left; margin-right: .3em;" class="ui-icon ui-icon-alert"></span><strong>Alerta: </strong>'+data.mensaje+'<br /><center> '+data.mensaje2+'</center></p>')
                        $("#memsajerror").addClass('ui-state-error'); 
                        $("#memsajerror").css({background:'#FEF6F3',border:'1px solid #CD0A0A'});
                        $("#memsajerror").show('drop',1000);

                   }

               }

           }
        });
   

}
</script>
<!--<style>
#form_carga_asignacion label, #dialog input { display:block; }
#form_carga_asignacion label { margin-top: 0.5em; }
#form_carga_asignacion input , #frmarmamenu textarea { width: 95%; }
#form_carga_asignacion select { width: 95%; }
#form_carga_asignacion .ui-combobox-input{width: 220px; }
</style>-->

<form class="form-style focus-estilo" id="form_carga_asignacion">
           <input type="hidden" name="idasigna" id="idasigna" value="<?php echo $idasig  ?>" />
           <input type="hidden" name="tcontribuid" id="tcontribuid" value="<?php echo $idcontribu?>" />
           <input type="hidden" name="conusuid" id="conusuid" value="<?php echo $conusuid?>" />
        <table id="tdeclara" style="" class="ui-corner-top">
            
         
            <tr id="anio-declara">
                <td class="linea-right">
                    <label><strong>A&ntilde;o omiso:</strong></label><br />
                </td>
                <td class="" id="tdanioD">
                     <select name="anio" class=" requerido ui-widget-content ui-corner-all" id="anio"  onChange=" carga_periodo_omiso(this.value)" >';
                      <option value="">Seleccione</option>
                      <option value="<?php echo $anio?>"><?php echo $anio?></option>
                     </select>
                </td>
            
            </tr>
            <tr>
                <td class="linea-right">
                     <label><strong>Periodo omiso:</strong></label><br />
                </td>
                <td class="">
                     <select name="periodo" class=" requerido ui-widget-content ui-corner-all" id="periodo"   >
                        <option value="">Seleccione</option>
                           

                    </select> 
                </td>
                
            </tr>
            <tr>
                <td class="linea-right">
                     <label><strong>Base imponible:</strong></label><br />
                </td>
                <td class="">
                    <input type="text" name="base" placeholder="0" id="base" class="requerido ui-widget-content ui-corner-all basei"   /> 
                </td>
                
            </tr>
            
            <tr>
                <td class="linea-right">
                     <label><strong>Descripcion:</strong></label><br />
                </td>
                <td class="">
                     <select name="descripcion" class=" requerido ui-widget-content ui-corner-all" id="descripcion"   >
                        <option value="">Seleccione</option>
                        <option value="false">Reparo por omiso</option>
                        <option value="true">Reparo por faltante</option>                          

                    </select> 
                </td>
                
            </tr>
        </table>
</form>
<script>

        
        $(document).ready(function() {
            carga_anio_omiso(<?php echo $idcontribu?>,<?php echo $anio?>);
       });
    
  
</script>
<?
}

if($identificador==3){
?>
<script>

    $(function(){
           
        validador('form_carga_pcancelados','<?php echo base_url()."index.php/mod_gestioncontribuyente/fiscalizacion_c/carga_periodos_pagados"; ?>','carga_periodos_pagados');
     
        $( "#fpago" ).datepicker({ 
            dateFormat: "dd-mm-yy",
            dayNamesMin: [ "Dom", "Lun", "Mar", "Mier", "Jue", "Vie", "Sab" ],
            monthNames: [ "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septimbre", "Octubre", "Noviembre", "Diciembre" ],
            changeYear: true
        });

       

    });

    

  carga_anio_omiso=function(valor,anio){
            
  $.ajax({       
       type:'post',
       data:{tcontribuid:valor},
       dataType:'json',
       url:'<?php echo base_url()."index.php/mod_contribuyente/contribuyente_c/carga_anio_declara"; ?>',
       success:function(data){
           
           if(data.resultado=='true'){
               if(data.tipo==2){
//               if(data.tipo!=2){
//                   var select='<select name="anio" class=" requerido ui-widget-content ui-corner-all" id="anio" onChange=" carga_periodo_omiso(this.value)" >';
//                       select+='</select>';
//                    $('#tperiodo').empty();   
//                    $('#anio').empty(); 
//                    $('#tperiodo').html('<option value="">Seleccione</option>');
//                    $("#tdanioD").html(select);   
//                    $("#anio-declara").show();                    
//                    $('#anio').html(data.aniosD);
//                    
//               }else{
                   
                   $("#tdanioD").empty();
                   $("#anio-declara").hide();
                   $('#periodo').html('<option value="">Seleccione</option><option value="'+anio+'">'+anio+'</option>');
//                   $('#periodo').html(data.htmloption);
               }
               

              
               
           }
           
       }
    });
    
}
        
carga_periodo_omiso=function(valor){
//alert(valor)
       $.ajax({       
       type:'post',
       data:{tcontribuid:$('#tcontribuid').val(),anio:valor},
       dataType:'json',
       url:'<?php echo base_url()."index.php/mod_contribuyente/contribuyente_c/carga_periodo"; ?>',
       success:function(data){
           
           if(data.resultado=='true'){       
                  if(data.htmloption==false){
                      
                        $('#periodopcancelado').empty();   
                        $('#periodopcancelado').html('<option value="">Seleccione</option>');
                         
                  }else{
                      
                        $('#periodopcancelado').html(data.htmloption);
                  }
           }
           
       }
    });
    
}

carga_periodos_pagados=function(form,url){
    var data=$('#'+form).serialize();
//    alert(data);
    $('#dialog-cargapcancelados').dialog( "close" );  
    $.ajax({       
           type:'post',
           data:data,
           dataType:'json',
           url:url,
           success:function(data){

               if(data.resultado==true){
               
                var current_index = $("#tabs").tabs("option","selected");             
                $("#tabs").tabs("load",current_index);   
                 
               }else{

                   if(data.existe_p){

                       
                        $('#memsajerror').html('<p style="font-family: sans-serif;color:#CD0A0A;"><span style="float: left; margin-right: .3em;" class="ui-icon ui-icon-alert"></span><strong>Alerta: </strong>El periodo ya se encuentra cargado en la seccion de reparo<br /><center> "PARA CORREGIR ELIMINE EL ANTERIOR"</center></p>')
                        $("#memsajerror").addClass('ui-state-error'); 
                        $("#memsajerror").css({background:'#FEF6F3',border:'1px solid #CD0A0A'});
                        $("#memsajerror").show('drop',1000);

                   }
                   if(data.faltadeclara){

                       
                        $('#memsajerror').html('<p style="font-family: sans-serif;color:#CD0A0A;"><span style="float: left; margin-right: .3em;" class="ui-icon ui-icon-alert"></span><strong>Alerta: </strong>'+data.mensaje+'<br /><center> '+data.mensaje2+'</center></p>')
                        $("#memsajerror").addClass('ui-state-error'); 
                        $("#memsajerror").css({background:'#FEF6F3',border:'1px solid #CD0A0A'});
                        $("#memsajerror").show('drop',1000);

                   }

               }

           }
        });
   
    
    
};

</script>
<!--<style>
#form_carga_pcancelados label, #dialog input { display:block; }
#form_carga_pcancelados label { margin-top: 0.5em; }
#form_carga_pcancelados input , #frmarmamenu textarea { width: 95%; }
#form_carga_pcancelados select { width: 95%; }
#form_carga_pcancelados .ui-combobox-input{width: 220px; }
</style>-->

<form class="form-style focus-estilo" id="form_carga_pcancelados">
           <input type="hidden" name="idasigna" id="idasigna" value="<?php echo $idasig  ?>" />
           <input type="hidden" name="tcontribuid" id="tcontribuid" value="<?php echo $idcontribu?>" />
           <input type="hidden" name="conusuid" id="conusuid" value="<?php echo $conusuid?>" />
        <table id="tdeclara" style="" class="ui-corner-top">
            
         
            <tr id="anio-declarapcancelado">
                <td class="linea-right">
                    <label><strong>A&ntilde;o:</strong></label><br />
                </td>
                <td class="" id="tdaniopcancelado">
                     <select name="anio" class=" requerido ui-widget-content ui-corner-all" id="aniopcancelado" onChange=" carga_periodo_omiso(this.value)" >';
                      <option value="">Seleccione</option>
                      <option value="<?php echo $anio?>"><?php echo $anio?></option>
                     </select>
                </td>
            
            </tr>
            <tr>
                <td class="linea-right">
                     <label><strong>Periodo:</strong></label><br />
                </td>
                <td class="">
                     <select name="periodopcancelado" class=" requerido ui-widget-content ui-corner-all" id="periodopcancelado"  >
                        <option value="">Seleccione</option>
                           

                    </select> 
                </td>
                
            </tr>
            <tr>
                <td class="linea-right">
                     <label><strong>Base imponible:</strong></label><br />
                </td>
                <td class="">
                    <input type="text" name="base" placeholder="0" id="base" class="requerido ui-widget-content ui-corner-all basei"  /> 
                </td>
                
            </tr>
            <tr>
                <td class="linea-right">
                     <label><strong>Fecha del pago:</strong></label><br />
                </td>
                <td><input readonly="readonly" type="text" id="fpago" name="fpago" class="requerido ui-widget-content ui-corner-all"  /></td>
            </tr>
            
            <tr>
                <td class="linea-right">
                     <label><strong>Total pagado:</strong></label><br />
                </td>
                <td class="">
                     <input type="text" name="tpagado" placeholder="0" id="tpagado" class="requerido ui-widget-content ui-corner-all"   /> 
                </td>
                
            </tr>
        </table>
</form>
<script>

        
        $(document).ready(function() {
            carga_anio_omiso(<?php echo $idcontribu?>,<?php echo $anio?>);
       });
   
    
</script>


<? } ?>


