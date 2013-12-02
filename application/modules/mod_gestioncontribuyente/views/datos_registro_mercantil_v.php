<html>
    
   <form id="frm_actualiza_regempresa" class="form-style focus-estilo" style=" float: left; margin-left: 50px; margin-top: 25px"> 
    <input type="hidden" name="rifconusu" id="rifconusu" value="<?php echo $rif; ?>"  />
    <input type="hidden" name="conusuid" id="conusuid" value="<?php echo $conusuid; ?>"  />
       <table >
        <tr>
            <td>
                <label>N de registro mercantil</label><br />
                <input type="text" name="rmnumero" id="rmnumero" disabled="disabled" class="ui-widget-content ui-corner-all" onclick="desbloquea_campos(this)" value="<?php echo $rmnumero?>" />
            </td>
            <td>
               <label>N de Folio</label><br />
                <input type="text" disabled="disabled" class="ui-widget-content ui-corner-all" name="rmfolio" value="<?php echo $rmfolio ?>" />
            </td>
            <td>
                <label>N de tomo</label><br />
                <input type="text" disabled="disabled" class="ui-widget-content ui-corner-all" name="rmtomo" value="<?php echo $rmtomo?>" />
            </td>
        </tr>
        <tr>
            <td>
                <label>Capital sucrito</label><br />
                <input type="text" disabled="disabled"  class="ui-widget-content ui-corner-all" name="capitalsus" value="<?php echo $capitalsus?>" />
            </td>
            <td>
               <label>Capital pagado </label><br />
                <input type="text" disabled="disabled" class="ui-widget-content ui-corner-all" name="capitalpag" value="<?php echo $capitalpag?>" />
            </td>
            <td>
                <label>Oficina del registro</label><br />
                <input type="text" disabled="disabled"  class="ui-widget-content ui-corner-all" name="regmerofc" value="<?php echo $regmerofc?>" />
            </td>
        </tr>
        <tr>
            <td>
                <label>Fecha del registro</label><br />
                <input type="text" disabled="disabled" class="ui-widget-content ui-corner-all" name="rmfechapro" value="<?php echo $rmfechapro ?>" />
            </td>
            <td>
               <label>Numero de control</label><br />
                <input type="text" disabled="disabled" class="ui-widget-content ui-corner-all" name="rmncontrol" value="<?php echo $rmncontrol ?>" />
            </td>
            <td>
                <label>Objeto de la empresa</label><br />
                <input type="text" disabled="disabled" class="ui-widget-content ui-corner-all" name="rmobjeto" value="<?php echo $rmobjeto ?>" />
            </td>
        </tr>
        <tr>
            <td colspan="3">
                <label>Domicilio de la empresa</label><br />
                <textarea disabled="disabled" class="ui-widget-content ui-corner-all" name="domifiscal" ><?php echo $domifiscal ?></textarea>
            </td>
        </tr>
        
        
        </table>
      
   </form>
    
   <div id="btn-remer"style="position:relative; margin-top: 5px; padding: 5px; margin-left: 72%"> 
        <button style=" width:100px; height: 20px;" class="desbloqueador" onclick="desbloquea_campos()">Desbloquear</button>
        <button onclick="actualizar_datos_registromercantil()" style=" width:100px; height: 20px;" class="Actualizar_dfis">Actualizar</button>
    </div>
    <div id="error-acturegi"style="padding: 0.1em;position: absolute; width:150px; text-align: justify; margin-top: 5%; margin-left: 75%" class="ui-corner-all"></div>
   <script>
     $('#error-acturegi').hide();  
     $('#btn-remer button').button({
                        icons: {
                           primary: "ui-icon-unlocked"
                           }
                           }).next().button({
                           icons: {
                           primary: "ui-icon-refresh"
                           }                          
                   });
    
     desbloquea_campos=function(){
         var array_html=new Array('input','textarea','select','textArea');
         for(var i=0; i<array_html.length; i++)
         {
            $("#frm_actualiza_regempresa").find(array_html[i]).each(function() {

                $(this).removeAttr('disabled');

            });
         }
         $('#rmnumero').focus();
     }

     
     </script>
</html>