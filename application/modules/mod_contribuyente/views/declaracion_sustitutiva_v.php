<?php

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
?>
<script>
$(function() {            
//    jQuery.fn.reset = function () {
//      $(this).each (function() { this.reset(); });
//    }

$( "#confirm-declaracion-sus" ).dialog({ autoOpen: false });
     $("#memsajerror").hide();
      $("#anio-declara").hide();

    validador('frmdeclara','<?php echo base_url()."index.php/mod_contribuyente/contribuyente_c/guardaDeclaracion"; ?>','guarda_declarcion');
   
   $( "#btn-frmcontrasena" ).button({
                icons: {
                    primary: "ui-icon-tag"
                }
                
      });
      
      $("#btn-frmcontrasena").click(function(){     
          
                
       $("#frmcontrasena").submit();    
          
      });    

      $('button').button() 
 

});    
carga_declara_sus=function(valor){
    
    $.ajax({       
       type:'post',
       data:{tcontribuid:valor},
       dataType:'json',
       url:'<?php echo base_url()."index.php/mod_contribuyente/declaracion_sustitutiva_c/declarciones_asustituir"; ?>',
       success:function(data){
           
           if(data.resultado){              
               
                   
                   $('#declasus').html(data.html);
           }
               

              
          
       }
    });
    
};
datos_declaracion=function(valor){
$.ajax({       
       type:'post',
       data:{valor:valor},
       dataType:'json',
       url:'<?php echo base_url()."index.php/mod_contribuyente/declaracion_sustitutiva_c/datos_declarcion_asustituir"; ?>',
       success:function(data){
         
         $("#bimponible").val(data.baseimpo);
         $("#mpagado").val(data.montopagar);
         $("#nbimponible").removeAttr('readonly');
         $("#nbimponible").css('background','');        
          
       }
    });
};

calcula_nuevo_monto=function(){
  
};





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
    $('#nbimponible').mask('000.000.000.000.000,00', {reverse: true});
//    $('#tpagar').mask('000.000.000.000.000,00', {reverse: true});

});




</script>
<style>
      #contenedor-frmdeclara-sus{
      width:600px;
      left:10%;
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
    #contenedor-frmdeclara-sus ,label{
        
       text-align: left;
       /*margin-left: 10px*/
       
       
    }
   
    
    #tbldeclarasus{        
       width: 100%;    
       
    } 
    .linea-right{
        
        border-right: 2px solid;
        border-right-color: darkgrey;
    }
 
    
    #tedeclarasus, label{
        
        float: left
    }
    #tedeclarasus, select, input{
        
        float:right;
        margin-bottom:3px
    }

    
    </style>
<div id="confirm-declaracion-sus" title="Mensaje Webmaster "></div>   
    
<div id="contenedor-frmdeclara-sus"  class="ui-widget-content ui-corner-all"  >
  
<form id="frmdeclarasus">    
    <fieldset class="secciones" style="margin-top:-30px; border:none; "><legend class="ui-widget-content ui-corner-all" style=" color: #654B24; font-size: 10px" align="center"><h4>FORMULARIO PARA DECLARACIONES SUSTITUTIVAS</h4></legend><br />

        
        <table id="tdeclarasus" style=" border-top: 2px solid; border-top-color: darkgray; width: 67%; margin-left:5%" class="ui-corner-top">
           <tr>
                <td class="linea-right">
                    <label><strong>Tipo de declaracion:</strong></label><br />
                    
                </td>
                
                    <td>
                     <select name="tdeclaracion" class="ui-state-highlight" id="tdeclaracion" style=" width: 250px; height:20px ;font-size:12px;" onChange="limpia_formulario(this.id)" >
                        <option value="3" selected="selected" >SUSTITUTIVA</option>
                    

                    </select>
               
                </td>
                
            </tr>
            <tr >
                <td class="linea-right">
                 <label><strong>Tipo de contribuyente:</strong></label><br />   
                </td>
                <td>
                  <select name="tcotribuyente" class="ui-state-highlight" id="tcotribuyente" style=" width: 250px; height:20px ;font-size:12px;" onChange="carga_declara_sus(this.value)">
                        <option value="">Seleccione</option>
                        <?php
                       if (sizeof($tipo_contribuyente)>0):
                           foreach ($tipo_contribuyente as $tipo_contribuyente):
                           print("<option value='$tipo_contribuyente[id]'>$tipo_contribuyente[nombre]</option>");
                           endforeach;
                       endif;

                       ?>  

                    </select>   
                </td>
                
            </tr>
            
            <tr>
                <td class="linea-right">
                    <label><strong>Declaraciones:</strong></label><br />
                </td>
                <td >
                   <select name="declasus" class=" ui-state-highlight" id="declasus" style="width: 250px;height:20px ;font-size:12px;" onChange="datos_declaracion(this.value)" >
                        <option value="">Seleccione</option>
                           

                    </select>   
                </td>
            
            </tr>
           
            <tr>
                <td class="linea-right">
                     <label><strong>Base imponible:</strong></label><br />
                </td>
                <td class="">
                    <input type="text" placeholder="0"  name="bimponible" id="bimponible" readonly="readonly" class=" ui-state-highlight" style="width: 250px; height:15px ;font-size:12px; font-weight: bold; text-align: right;background: #D9D3CC" /> 
                </td>
                
            </tr>
            <tr>
            <td class="linea-right">
                     <label><strong>Monto pagado:</strong></label><br />
                </td>
                <td class="">
                    <input type="text" placeholder="0" readonly="readonly" name="mpagado" id="mpagado" class=" ui-state-highlight" style="width: 250px; height:15px ;font-size:12px; font-weight: bold; text-align: right; background: #D9D3CC"  /> 
                     
                </td>
            </tr>
            <tr>
            <td class="linea-right">
                <label><strong>Nueva base imponible::</strong></label><br />
                </td>
                <td class="">
                    <input type="text" placeholder="0" readonly="readonly" name="nbimponible"  id="nbimponible" class="ui-state-highlight" style="width: 250px; height:15px ;font-size:12px; font-weight: bold; text-align: right; background: #D9D3CC"  /> 
                </td>
            </tr>
             <tr>
            <td class="linea-right">
                <label><strong>Nuevo total a pagar:</strong></label><br />
                </td>
                <td class="">
                    <input type="text" placeholder="0" name="tpagar" id="tpagar" class=" requerido ui-state-highlight" style="width: 250px; height:15px ;font-size:12px; font-weight: bold; text-align: right; background: #D9D3CC"  /> 
                </td>
            </tr>
               

            
         </table>
 
  </fieldset>  
  
         <button type="button" id="btncalcular" onclick="calcula_nuevo_monto()" style=" margin-left: 20%;"> <img style=" float:left; margin-right: 5px; "  border="0" width="18px" height="15px" src="<?php echo base_url().'/include/imagenes/iconos/calculator.png'?>"  />Calcular</button>
         <button type="button" id="compromiso"> <img style=" float:left; margin-right: 5px "  border="0" width="18px" height="15px" src="<?php echo base_url().'/include/imagenes/iconos/icono_declarar.png'?>" />Compromiso de pago</button>
    
</form>
     <div style="border: 0px solid blue; width: 15%; height: 20%; margin-top: -35%; margin-left: 75%; position: absolute">
        <img src="<?php echo base_url()."/include/imagenes/iconos/percent.png"; ?>"/>
    </div>

 <br />
 <!--<center><button id="btn-frmcontrasena" style="width:100px; height: 25px; margin-top:-10px; margin-left: 20px; position: relative" title="">Actualizar</button><br /><br /></center>-->
<div style="padding: 0 .7em; width: 400px; margin-top: 15px; margin-left:20%; margin-bottom: 10px" class="ui-corner-all" id="memsajerror">
		
 </div>
</div>