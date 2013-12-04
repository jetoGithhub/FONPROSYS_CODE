
<script>
$(function(){
    $('#marca_todos').button().click(function () {
                            if($('#anio_cal').val()==''){
                                alert('Seleccione el año primero');
                            }else{
                                if ($(".fecha_periodo").is (':visible')) {

                                    $( ".fecha_periodo-1" ).hide("slide", { direction: "left" }, 1000);
                                    $( ".fecha_periodo-2" ).hide("slide", { direction: "right" }, 1000);
                                    $( ".fecha_periodo-1").attr('placeholder', 'Seleccione Fecha');
                                    $( ".fecha_periodo-2").attr('placeholder', 'Seleccione Fecha');
                                    $('.hijo_button').removeClass('ui-icon-closethick');
                                    $('.hijo_button').addClass(' ui-icon-circle-check');
                                    $(".fecha_periodo-1").addClass('ui-state-highlight ui-corner-all');
                                    $(".fecha_periodo-2").addClass('ui-state-highlight ui-corner-all');
                                }else
                                if ($(".fecha_periodo").is (':hidden')) {

                                    $( ".fecha_periodo-1" ).show("slide", { direction: "left" }, 1000);
                                    $( ".fecha_periodo-1").attr('placeholder', 'Seleccione Fecha');

                                    $( ".fecha_periodo-2" ).show("slide", { direction: "right" }, 1000);
                                    $( ".fecha_periodo-2").attr('placeholder', 'Seleccione Fecha');                        
                                    $('.hijo_button').removeClass(' ui-icon-circle-check');
                                    $('.hijo_button').addClass('ui-icon-closethick');
                                    $(".fecha_periodo-1").addClass('ui-state-highlight ui-corner-all');
                                    $(".fecha_periodo-2").addClass('ui-state-highlight ui-corner-all');
                                }
                        }
                }); 
});



</script>

<?


function div($id){
          echo '
              <button id="'.$id.'" type="button" style="float:right;width: 30px; height: 25px;" class="selecciona_fecha  ui-state-default  ui-button-icon-only" role="button" aria-disabled="false" title="Seleciona Fecha">
              
                    
                    
                    <span  id="hijo-'.$id.'"  class=" hijo_button ui-button-icon-primary ui-icon ui-icon-circle-check"></span>
                   
               </button>';
      }
function div_todos($id){
  echo '
      <button id="'.$id.'" type="button" style="float:right;width: 90px; height: 25px;"" class="selecciona_fecha  ui-state-default " role="button" aria-disabled="false" title="Seleciona Fecha">


            Todos
            <span style="float:right;" id="hijo-'.$id.'" class="ui-button-icon-primary  ui-icon ui-icon-circle-check"></span>

       </button>';
}

function fecha_calendario($id,$dia,$mes,$anio,$tipo){?>
        <script>
            $(function() {
                $("#<?php print($id); ?>" ).hide();
                $('#<?php print($mes); ?>').button().click(function () {
                    
                                
                    if($('#anio_cal').val()==''){
                        alert('Seleccione el año primero');
                    }else{
                        if ($("#<?php print($id); ?>").is (':visible')) {
                            $("#<?php print($id); ?>").val('');
                            $("#<?php print($id); ?>").val('');
                            $( "#<?php print($id); ?>").attr('placeholder', 'Seleccione Fecha');
                            $( "#<?php print($id); ?>" ).hide("slide", { direction: "left" }, 1000);
                            
                            $('#hijo-<?php print($mes); ?>').removeClass('ui-icon-closethick');
                            $('#hijo-<?php print($mes); ?>').addClass(' ui-icon-circle-check');
                        }else
                        if ($("#<?php print($id); ?>").is (':hidden')) {
                            $("#<?php print($id); ?>").val('');
                            $("#<?php print($id); ?>").val('');
                            $("#<?php print($id); ?>").attr('placeholder', 'Seleccione Fecha');
                            $("#<?php print($id); ?>").attr('placeholder', 'Seleccione Fecha');
                            $("#<?php print($id); ?>" ).show("slide", { direction: "left" }, 1000);
                            
                            $('#hijo-<?php print($mes); ?>').removeClass(' ui-icon-circle-check');
                            $('#hijo-<?php print($mes); ?>').addClass('ui-icon-closethick');
                            $("#<?php print($id); ?>").addClass('ui-state-highlight ui-corner-all');
                        }     
                    }               
                }); 
           
                    $( ".datepicker" ).datepicker({yearRange: "2002:2002",changeMonth: false,changeYear: false,showOtherMonths: true, stepMonths: 12,numberOfMonths: 1,showButtonPanel: false});
                    $( ".datepicker" ).datepicker( "setDate", "10/12/2012" );
                    $( ".datepicker" ).datepicker( { hideIfNoPrevNext: true, duration: '' } );

                    $( ".datepicker" ).click( function(){$("div.ui-datepicker-header a.ui-datepicker-prev,div.ui-datepicker-header a.ui-datepicker-next").hide(); } );

                    <?php
                    if($tipo==0):
                    ?>
                        $( "#<?php print($id); ?>" ).datepicker({
                            dateFormat: 'dd/mm/yy',
                            yearRange: "<?php print($anio); ?>:<?php print($anio+1); ?>",
                            changeMonth: true,
                            changeYear: true,
                            showOtherMonths: true,
                            stepMonths: 12,
                            numberOfMonths: 1,
                            showButtonPanel: false,
                            dayNamesMin: [ "Do", "Lu", "Ma", "Mi", "Ju", "Vi", "Sa" ],
                             monthNamesShort: [ "Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sept", "Oct", "Nov", "Dic" ]
                            });
                        //$( "#fecha-<?php print($id); ?>").datepicker( "setDate", "<?php  print("$mes/$dia/");?>" );
                        $( "#<?php print($id); ?>" ).datepicker( { hideIfNoPrevNext: true, duration: '' } );

                        $( "#<?php print($id); ?>" ).click( function(){
                            $( "#<?php print($id); ?>").datepicker( "setDate", "<?php  print("$dia/$mes/$anio");?>" );
                            $("div.ui-datepicker-header a.ui-datepicker-prev,div.ui-datepicker-header a.ui-datepicker-next").hide(); 
                        } );
                   <?php
                   else: ?>
                           
                     $("#<?php print($id); ?>").datepicker({
                            dateFormat: 'dd/mm/yy',
                            dayNamesMin: [ "Do", "Lu", "Ma", "Mi", "Ju", "Vi", "Sa" ],
//                            monthNames: [ "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre" ],
                            monthNamesShort: [ "Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sept", "Oct", "Nov", "Dic" ],
                            yearRange: "<?php print($anio); ?>:<?php print($anio+1); ?>",
                            changeMonth: true,
                            changeYear:true
                        });
                      $( "#<?php print($id); ?>" ).click( function(){
                            $( "#<?php print($id); ?>").datepicker( "setDate", "<?php print("$dia/$mes/$anio");?>");
                            } );                   
                            <?php
                   endif;
                   ?>     
            });
        </script>  
  <?php } 

function meses_tipegrav($periodo)
{          
           switch($periodo+1){
                    case '1':
                        print('PERIODO GRAVABLE');
                        break;
                    case '2':
                        print('ENERO');
                        div($periodo);
                        break;
                    case '3':
                        print('FEBRERO');
                        div($periodo);                      
                        break;
                    case '4':
                        print('MARZO');
                        div($periodo);
                        break;
                    case '5':
                        print('ABRIL');
                        div($periodo);
                        break;  
                    case '6':
                        print('MAYO');
                        div($periodo);
                        break;   
                    case '7':
                        print('JUNIO');
                        div($periodo);
                        break;
                    case '8':
                        print('JULIO');
                        div($periodo);
                        break;
                    case '9':
                        print('AGOSTO');
                        div($periodo);
                        break;
                    case '10':
                        print('SEPTIEMBRE');
                        div($periodo);
                        break;  
                    case '11':
                        print('OCTUBRE');
                        div($periodo);
                        break;
                    case '12':
                        print('NOVIEMBRE');
                        div($periodo);
                        break;
                    case '13':
                        print('DICIEMBRE');
                        div($periodo);
                        break;                    

                    case '14':
                         ?>
                        <button style="width:100%;"type="button" name="btn_calendario" id="btn_calendario"> Crear Calendario</button>
                        <?php break; 
            } 
}
function trimestres_tipegrav($periodo){
switch($periodo+1){
                    case '1':
                        print('PERIODO GRAVABLE');
                        break;
                    case '2':
                        print('1º TRIMESTRE');
                        div($periodo);
                        break;
                    case '3':
                        print('2º TRIMESTRE');
                        div($periodo);                      
                        break;
                    case '4':
                        print('3º TRIMESTRE');
                        div($periodo);
                        break;
                    case '5':
                        print('4º TRIMESTRE');
                        div($periodo);
                        break;  
                    
                    case '6':
                         ?>
                        <button style="width:100%;"type="button" name="btn_calendario" id="btn_calendario"> Crear Calendario</button>
                        <?php break; 
            } 
}
function anios_tipegrav($periodo,$anio){
switch($periodo+1){
                    case '1':
                        print('PERIODO GRAVABLE');
                        break;
                    case '2':
                        print('A&Nacute;O'.' '.$anio);
                        div($periodo);
                        break;
                    
                    case '3':
                         ?>
                        <button style="width:100%;"type="button" name="btn_calendario" id="btn_calendario"> Crear Calendario</button>
                        <?php break; 
            } 
}
?>
<table style=" width: 100%">                        
<?php                        
$dis=1;
        if($tipe_tipegrav==0):
          $fn_ciclo=13;   
        endif;
        if($tipe_tipegrav==1):
          $fn_ciclo=5;   
        endif;
         if($tipe_tipegrav==2):
          $fn_ciclo=2;   
        endif;
      for($i=0;$i<=$fn_ciclo;$i++):
          if($dis==1){ $dis=2;} else { $dis=1;}
      
      ?>
  
        <tr>
            
            <?php 
            $tope=2;
            if($i>($fn_ciclo-1)){ $tope=1; } ?>
            
            <?php for($j=1;$j<=$tope;$j++): ?>
            
                <?php
                if ($i==0){ ?>
                
           <?php  switch($j){ 
                    case '1': ?>
            <td <?php if($i>($fn_ciclo-1)){ echo ' colspan="" '; } ?> class="ui-widget-content <?php if($i==0){ echo ' ui-corner-header ui-widget-header '; } ?> ui-corner-all" style="<?php if($i==0){ echo ' '; } ?>width: 140px;border:1px #000 solid;padding:3px">     
         <?php          print('<b>MES</b>');
                        div_todos('marca_todos');
                        echo '</td>'; 
                        break;
                    case '2': ?>                
                        <td <?php if($i>($fn_ciclo-1)){ echo ' colspan="" '; } ?> class="ui-widget-content <?php if($i==0){ echo ' ui-corner-header ui-widget-header '; } ?> ui-corner-all" style="<?php if($i==0){ echo ' '; } ?>width: 140px;border:1px #000 solid;padding:3px">     
         <?php          print('<center><b>Fecha Inicio</b></center>');
                        echo '</td>'; ?> 
                        <td <?php if($i>($fn_ciclo-1)){ echo ' colspan="" '; } ?> class="ui-widget-content <?php if($i==0){ echo ' ui-corner-header ui-widget-header '; } ?> ui-corner-all" style="<?php if($i==0){ echo ' '; } ?>width: 140px;border:1px #000 solid;padding:3px">     
         <?php          print('<center><b>Fecha Fin</b></center>');
                        echo '</td>'; ?> 
                       <td <?php if($i>($fn_ciclo-1)){ echo ' colspan="" '; } ?> class="ui-widget-content <?php if($i==0){ echo ' ui-corner-header ui-widget-header '; } ?> ui-corner-all" style="<?php if($i==0){ echo ' '; } ?>width: 140px;border:1px #000 solid;padding:3px">     
         <?php          print('<center><b>Fecha Limite</b></center>');
                        echo '</td>'; 
                        break;

                        }
                       
                }else{
                    if($j==1){?> 
                <td <?php if($i>($fn_ciclo-1)){ echo ' colspan="4" '; } ?> class="ui-widget-content <?php if($i==0){ echo ' ui-corner-header ui-widget-header '; } ?> ui-corner-all" style="<?php if($i==0){ echo ' '; } ?>width: 140px;border:1px #000 solid;padding:3px">     
                    <?php
                        if($tipe_tipegrav==0):
                          meses_tipegrav($i);   
                        endif;
                        if($tipe_tipegrav==1):
                          trimestres_tipegrav($i);   
                        endif;
                        if($tipe_tipegrav==2):
                          anios_tipegrav($i,$anio_cal);   
                        endif;
                 echo '</td>';   
                    }else{
                        
                        ?>
                <center>
                    <td class="ui-widget-content ui-corner-all" style="padding:3px" >
                    <input id="fechai-<?php print($i); ?>" class="fecha-<?php print($i); ?> fecha_periodo calenput fecha_periodo-<?php print($dis); ?>" type="text" name="fecha_periodoi[<?php print($i); ?>]" />
                    <?php 
                    $id_fecha="fechai-".$i; 
                    fecha_calendario($id_fecha,'1',$i,$anio_cal,$tipe_tipegrav);
                    ?>
                    </td>
                    <td class="ui-widget-content ui-corner-all" style="padding:3px">
                    <input id="fechaf-<?php print($i); ?>" class="fecha-<?php print($i); ?> fecha_periodo calenput fecha_periodo-<?php print($dis); ?>" type="text" name="fecha_periodof[<?php print($i); ?>]" />
                    <?php 
                    $id_fecha="fechaf-".$i; 
                    fecha_calendario($id_fecha,'1',$i,$anio_cal,$tipe_tipegrav);
                    ?>
                    </td>
                    <td class="ui-widget-content ui-corner-all" style="padding:3px">
                    <input id="fechal-<?php print($i); ?>" class="fecha-<?php print($i); ?> fecha_periodo calenput fecha_periodo-<?php print($dis); ?>" type="text" name="fecha_periodol[<?php print($i); ?>]" />
                    <?php 
                    $id_fecha="fechal-".$i; ; 
                    fecha_calendario($id_fecha,'1',$i,$anio_cal,$tipe_tipegrav);
                    ?>
                    </td>
                </center>
                    
                   <?php }
                    
                
                
        }
                ?> 
            </td>
            <?php endfor; ?>
        </tr>
            
      <?php endfor; ?>
      <tr>
          <td colspan="4" >
              <div id="msj-cal" style="padding: 0 .7em; margin-left:25%; width: 300px; margin-top: 5px;margin-bottom: 5px;" class="ui-corner-all" ></div>
          </td>
      </tr>  
 </table>
 
<script>

    $('#btn_calendario').button().click(function(){
        $("div#msj-cal").hide();
         var contador=1;
//        alert($('#calendario').serialize());
        $(".calenput").each(function(){
            
            if( $(this).val()=='' ){
                contador=0;
            }
        });
        if(contador==0){
            
            $('div#msj-cal').html('<p style="font-family: sans-serif;color:#CD0A0A;"><span style="float: left; margin-right: .0em;" class="ui-icon ui-icon-alert"></span><strong>ERROR: </strong>Debe completar todas las fechas del calendario.</p>')
            $("div#msj-cal").addClass('ui-state-error'); 
            $("div#msj-cal").show('blind',{ direction: "up" },1000);
            setTimeout(function(){
                  $("div#msj-cal").hide('blind',{ direction: "up" },1000);
            },3000);
            
        
        }else{
            $.ajax({
                global:false,
                type:"post",
                data: $('#calendario').serialize(),
                dataType:"json",
                url:'<?php print(base_url().'index.php/mod_gestioncontribuyente/gestion_calendarios_de_pago_c/crea_calendario'); ?>',
                success:function(data){

                    if (data.success){
                        $('div#msj-cal').html('<p style="font-family: sans-serif;color:#CD0A0A;"><span style="float: left; margin-right: .0em;" class="ui-icon ui-icon-check"></span><strong>AVISO: </strong>'+data.mensaje+'</p>')
                        $("div#msj-cal").addClass('ui-state-error'); 
                        $("div#msj-cal").show('blind',{ direction: "up" },1000);
                        
                        setTimeout(function(){
                           var current_index = $("#tabs").tabs("option","selected");
                            $("#tabs").tabs('load',current_index);
                        },2000);
                    }else{
                        $('div#msj-cal').html('<p style="font-family: sans-serif;color:#000;"><span style="float: left; margin-right: .0em;" class="ui-icon ui-icon-alert"></span><strong>ERROR: </strong>'+data.mensaje+'</p>')
                        $("div#msj-cal").addClass('ui-state-error'); 
                        $("div#msj-cal").show('blind',{ direction: "up" },1000);
                         setTimeout(function(){
                                $("div#msj-cal").hide('blind',{ direction: "up" },1000);
                          },3000);
                    }
                },
                beforeSend:function(){    
                $('#btn_calendario').html('<span class="ui-button-text">Crear Calendario <img  src="<?php print(base_url()); ?>include/imagenes/ajax-loader.gif" /></span>');          
                },
                complete:function(){
                    $('#btn_calendario').html('<span class="ui-button-text">Crear Calendario </span>');
                }


            });
        }
    });

</script>                       
                        