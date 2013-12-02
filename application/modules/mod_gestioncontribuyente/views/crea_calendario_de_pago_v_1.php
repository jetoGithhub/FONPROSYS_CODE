<form id="calendario" name="calendario">
<br/><br/>
<table id="table_cal_contri">
    <tr>
        <td style=" border-right: 0px #000 solid;width:130px" class="ui-widget-content  ui-corner-tl ui-corner-bl">
<!--            <div id="menu_cal" >
                
            </div>-->
            Tipo de contribuyente
        </td>
        <td style=" border-left:  0px #000 solid;" class="ui-widget-content   ui-corner-tr ui-corner-br ">
            <select class="ui-widget-content ui-corner-all" id="contri_cal" name="contri_cal" onchange="lista_anio_cal('<?php print(base_url().'index.php/mod_gestioncontribuyente/gestion_calendarios_de_pago_c/lista_anios_cal/'); ?>',this.value)">
                <option value="">Seleccione</option>
                <?php 
                foreach ($tipo_contribuyentes as $valor):
                    print("<option value='$valor[id]'> $valor[nombre] </option>");
                endforeach;
                ?>
            </select>
        </td>
    </tr>
</table>
<br/>
<table id="table_cal_calpago">
    <tr>
        <td style=" border-right: 0px #000 solid;width:130px" class="ui-widget-content  ui-corner-tl ui-corner-bl">
<!--            <div id="menu_cal" >
                
            </div>-->
            Calendarios por año
        </td>
        <td id="anio_cal_td" style=" border-left:  0px #000 solid;" class="ui-widget-content   ui-corner-tr ui-corner-br ">
            <select class="ui-widget-content ui-corner-all"  id="anio_cal" name="anio_cal" onchange="dispara_anio()" >
                <option value="">Seleccione</option>
<!--                <?php 
                for ($an=2006;$an<=2021;$an++):
                    print("<option class='val_anio' value='$an'> $an </option>");
                endfor;
                ?>                -->

            </select>&nbsp;&nbsp;<div id="img_anio" style="float: right;"></div>
        </td>
    </tr>
</table>

<script>
 $(function() {
     dispara_anio=function(){
         $('.fecha_periodo-1').val('');
         $('.fecha_periodo-2').val('');        
         $( ".fecha_periodo-1" ).hide("slide", { direction: "left" }, 1000);
         $( ".fecha_periodo-2" ).hide("slide", { direction: "right" }, 1000);
         $( ".fecha_periodo-1").attr('placeholder', 'Seleccione Fecha');
         $( ".fecha_periodo-2").attr('placeholder', 'Seleccione Fecha');
         $('.hijo_button').removeClass('ui-icon-closethick');
         $('.hijo_button').addClass(' ui-icon-circle-check');
         $(".fecha_periodo-1").addClass('ui-state-highlight ui-corner-all');
         $(".fecha_periodo-2").addClass('ui-state-highlight ui-corner-all');         
         
     }
     $('.fecha_periodo').attr('placeholder', 'Seleccione Fecha');
      
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
               

    $( ".datepicker" ).datepicker({yearRange: "2002:2002",changeMonth: false,changeYear: false,showOtherMonths: true, stepMonths: 12,numberOfMonths: 1,showButtonPanel: false});
    $( ".datepicker" ).datepicker( "setDate", "10/12/2012" );
    $( ".datepicker" ).datepicker( { hideIfNoPrevNext: true, duration: '' } );
    
    $( ".datepicker" ).click( function(){$("div.ui-datepicker-header a.ui-datepicker-prev,div.ui-datepicker-header a.ui-datepicker-next").hide(); } );
});
  


lista_anio_cal = function(url,id){
//    $('#img_anio')
//    .ajaxStart(function(){
//        $(this).show();
//        $(this).html('Cargando años  <img  src="<?php print(base_url()); ?>include/imagenes/ajax-loader.gif" />');
//    })
//    .ajaxComplete(function(){
//        //$(this).hide();
//    });      
    $.ajax({
        global:false,
        type:"post",
        data:{ id:id },
        dataType:"json",
        url:url,
        success:function(data){
            
            if (data.success){
                var muestra='';
                var lista = data.datos;
                var select_abre='<select class="ui-widget-content ui-corner-all"  id="anio_cal" name="anio_cal" onchange="dispara_anio()">';
                var option_vacio='<option  class="val_anio" value="">Seleccione</option>';
                var opt_cierra = ('</option>');
                for(var i_a=2006;i_a<=2021;i_a++){
                    option_vacio+='<option class="val_anio" value="'+i_a+'">'+i_a+'</option>';
                    
                }
                var select_cierra='</select>&nbsp;&nbsp;<div id="img_anio" style="float: right;"></div>';
                muestra+=select_abre+option_vacio+select_cierra;
//                alert(muestra)
                $('#anio_cal_td').html(muestra);
                for(i in lista){
                $('.val_anio').each(function(r){
                    if(lista[i].ano==$(this).val()){
                        $(this).attr('disabled', 'disabled'); 
                        
                    }
                });

                }

            }else{
                alert('error')
            }
        },
        beforeSend:function(){    
        $('#img_anio').html('<img  src="<?php print(base_url()); ?>include/imagenes/ajax-loader.gif" />');          
        },
        complete:function(){
            $('#img_anio').html('');
        }


    });    
}
  </script>      
  <style>
      #table_cal_contri ,#table_cal_calpago{
          /*width:100%;*/
          border-top: 0px #000 solid;
          border-left: 0px #000 solid;
          border-right: 0px #000 solid;
          border-bottom:0px #000 solid;
      }
  </style>
  
  <table id="fecha_table"class="ui-widget-content   ui-corner-all" style="border:1px #000 solid;">
      <tr class="ui-widget-header   ui-corner-all"><td style="border:0px #000 solid;" colspan="2"><center>Calendario de Obligaciones Tributarias</center></td></tr>
      
      <?php
      function div($id){
          echo '
              <button id="'.$id.'" type="button" style="float:right;width: 25px; height: 25px;" class="selecciona_fecha  ui-state-default  ui-button-icon-only" role="button" aria-disabled="false" title="Seleciona Fecha">
              
                    
                    
                    <span  id="hijo-'.$id.'" class=" hijo_button ui-button-icon-primary ui-icon ui-icon-circle-check"></span>
                   
               </button>';
      }
      function div_todos($id){
          echo '
              <button id="'.$id.'" type="button" style="float:right;width: 90px; height: 25px;"" class="selecciona_fecha  ui-state-default " role="button" aria-disabled="false" title="Seleciona Fecha">
              
                    
                    Todos
                    <span style="float:right;" id="hijo-'.$id.'" class="ui-button-icon-primary  ui-icon ui-icon-circle-check"></span>
                    
               </button>';
      }      
      function fecha_calendario($id,$dia,$mes,$anio){?>
        <script>
            $(function() {
                $( "#fecha-<?php print($id); ?>" ).hide();
                $('#<?php print($id); ?>').button().click(function () {
                    
                                
                    if($('#anio_cal').val()==''){
                        alert('Seleccione el año primero');
                    }else{
                        if ($("#fecha-<?php print($id); ?>").is (':visible')) {
                            $("#fecha-<?php print($id); ?>").val('');
                            $("#fecha-<?php print($id); ?>").val('');
                            $( "#fecha-<?php print($id); ?>").attr('placeholder', 'Seleccione Fecha');
                            $( "#fecha-<?php print($id); ?>").attr('placeholder', 'Seleccione Fecha');
                            $( "#fecha-<?php print($id); ?>" ).hide("slide", { direction: "left" }, 1000);
                            
                            $('#hijo-<?php print($id); ?>').removeClass('ui-icon-closethick');
                            $('#hijo-<?php print($id); ?>').addClass(' ui-icon-circle-check');
                        }else
                        if ($("#fecha-<?php print($id); ?>").is (':hidden')) {
                            $("#fecha-<?php print($id); ?>").val('');
                            $("#fecha-<?php print($id); ?>").val('');
                            $( "#fecha-<?php print($id); ?>").attr('placeholder', 'Seleccione Fecha');
                            $( "#fecha-<?php print($id); ?>").attr('placeholder', 'Seleccione Fecha');
                            $( "#fecha-<?php print($id); ?>" ).show("slide", { direction: "left" }, 1000);
                            
                            $('#hijo-<?php print($id); ?>').removeClass(' ui-icon-circle-check');
                            $('#hijo-<?php print($id); ?>').addClass('ui-icon-closethick');
                            $("#fecha-<?php print($id); ?>").addClass('ui-state-highlight ui-corner-all');
                        }     
                    }               
                }); 

                $( "#fecha-<?php print($id); ?>" ).datepicker({yearRange: "2002:2002",changeMonth: false,changeYear: false,showOtherMonths: true, stepMonths: 12,numberOfMonths: 1,showButtonPanel: false});
                //$( "#fecha-<?php print($id); ?>").datepicker( "setDate", "<?php  print("$mes/$dia/");?>" );
                $( "#fecha-<?php print($id); ?>" ).datepicker( { hideIfNoPrevNext: true, duration: '' } );

                $( "#fecha-<?php print($id); ?>" ).click( function(){
                    $( "#fecha-<?php print($id); ?>").datepicker( "setDate", "<?php  print("$mes/$dia/");?>"+$('#anio_cal').val() );
                    $("div.ui-datepicker-header a.ui-datepicker-prev,div.ui-datepicker-header a.ui-datepicker-next").hide(); 
                } );
            });
        </script>  
  <?php }
      $dis=1;
      for($i=0;$i<=13;$i++):
          if($dis==1){ $dis=2;} else { $dis=1;}
      
      ?>
  
        <tr class="ui-widget-content   ui-corner-header" style="border:1px #000 solid;">
            
            <?php 
            $tope=2;
            if($i>12){ $tope=1; } ?>
            
            <?php for($j=1;$j<=$tope;$j++): ?>
            <td <?php if($i>12){ echo ' colspan="2" '; } ?> class="ui-widget-content <?php if($i==0){ echo ' ui-corner-header ui-widget-header '; } ?> ui-corner-all" style="<?php if($i==0){ echo ' '; } ?>width: 140px;border:1px #000 solid;"> 
                <?php
                if ($i==0){
                switch($j){
                    case '1':
                        print('<b>MES</b>');
                        div_todos('marca_todos');
                        break;
                    case '2':
                        print('<b>FECHA</b>');                        
                        break;

                        }
                }else{
                    if($j==1){?>
                       
                    <?php
                    
                   switch($i+1){
                    case '1':
                        print('PERIODO GRAVABLE');
                        break;
                    case '2':
                        print('ENERO');
                        div($i);
                        break;
                    case '3':
                        print('FEBRERO');
                        div($i);                      
                        break;
                    case '4':
                        print('MARZO');
                        div($i);
                        break;
                    case '5':
                        print('ABRIL');
                        div($i);
                        break;  
                    case '6':
                        print('MAYO');
                        div($i);
                        break;   
                    case '7':
                        print('JUNIO');
                        div($i);
                        break;
                    case '8':
                        print('JULIO');
                        div($i);
                        break;
                    case '9':
                        print('AGOSTO');
                        div($i);
                        break;
                    case '10':
                        print('SEPTIEMBRE');
                        div($i);
                        break;  
                    case '11':
                        print('OCTUBRE');
                        div($i);
                        break;
                    case '12':
                        print('NOVIEMBRE');
                        div($i);
                        break;
                    case '13':
                        print('DICIEMBRE');
                        div($i);
                        break;                    
                    		
                    case '14':
                         ?>
                        <button style="width:100%;"type="button" name="btn_calendario" id="btn_calendario"> Crear Calendario</button>
                        <?php break;                    
                    		

                         
                        }                 
                    }else{
                        fecha_calendario($i,'1',$i,'2013');
                        ?>
                <center>
                    <input id="fecha-<?php print($i); ?>" class="fecha_periodo calenput fecha_periodo-<?php print($dis); ?>" type="text" name="fecha_periodo[<?php print($i); ?>]" />
                </center>
                    
                   <?php }
                    
                
                
        }
                ?> 
            </td>
            <?php endfor; ?>
        </tr>
      <?php endfor; ?>
      
  </table>
  
</form>


<script>

    $('#btn_calendario').button().click(function(){
        var contador=0;
        $(".calenput").each(function(){
            
            if( $(this).val()!='' ){
                contador=contador+1;
            }
        })
        if(contador==0){
            alert('Seleccione al menos un mes')
        }else{
            $.ajax({
                global:false,
                type:"post",
                data: $('#calendario').serialize(),
                dataType:"json",
                url:'<?php print(base_url().'index.php/mod_gestioncontribuyente/gestion_calendarios_de_pago_c/crea_calendario'); ?>',
                success:function(data){

                    if (data.success){
                        alert(data.mensaje);
                    }else{
                        alert(data.mensaje);
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
    })

</script>