<br/><br/>
<table id="table_cal_contri">
    <tr>
        <td style=" border-right: 0px #000 solid;width:130px" class="ui-widget-content  ui-corner-tl ui-corner-bl">
<!--            <div id="menu_cal" >
                
            </div>-->
            Tipo de contribuyente
        </td>
        <td style=" border-left:  0px #000 solid;" class="ui-widget-content   ui-corner-tr ui-corner-br ">
            <select class="ui-widget-content ui-corner-all" id="contri_cal" onchange="lista_anio_cal('<?php print(base_url().'index.php/mod_gestioncontribuyente/gestion_calendarios_de_pago_c/lista_anios_cal/'); ?>',this.value)">
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
        <td id="anio_cal" style=" border-left:  0px #000 solid;" class="ui-widget-content   ui-corner-tr ui-corner-br ">
            <select class="ui-widget-content ui-corner-all"  onchange="lista_meses_cal('<?php print(base_url().'index.php/mod_gestioncontribuyente/gestion_calendarios_de_pago_c/lista_anios_cal/'); ?>',this.value)">
                <option value="">Seleccione</option>
                

            </select>
        </td>
    </tr>
</table>

<?php // print_r($tipo_contribuyentes); ?>

<script>
 $(function() {
     
    $( ".datepicker" ).datepicker({yearRange: "2002:2002",changeMonth: false,changeYear: false,showOtherMonths: true, stepMonths: 12,numberOfMonths: 1,showButtonPanel: false});
    $( ".datepicker" ).datepicker( "setDate", "10/12/2012" );
    $( ".datepicker" ).datepicker( { hideIfNoPrevNext: true, duration: '' } );
    
     $( ".datepicker" ).click( function(){$("div.ui-datepicker-header a.ui-datepicker-prev,div.ui-datepicker-header a.ui-datepicker-next").hide(); } );
});
  
  
  

  </script>

 
Date: <input type="text" id="datepicker" class="datepicker" />
<br/>
<div class="datepicker"> dfd</div>
<script >

<?php
//echo "$(\"#menu_cal\").append( menu_crear_titulo(\"menu_caltitle_-tipo-contribuyente\",\"".utf8_decode(utf8_encode('Tipo de contribuyente'))."\",\"".base_url()."\") );";
//echo "$(\"#menu_cal\").append( menu_crear_cuerpo_elemento(\"menu_calbelement-tipo-contribuyente\") );";
//foreach( $tipo_contribuyentes as $clave=>$item):
//
//        echo "$(\"#menu_cal\").find(\"div#menu_calbelement-tipo-contribuyente\").append( menu_crear_elemento(\"element-".$item["nombre"]."\", \"".utf8_decode(utf8_encode($item["nombre"]))."\", \"".base_url().$item["nombre"]."\") );";


    
//endforeach;
    ?> 
        
//    $("#menu_cal").accordion({
//    autoHeight: false,
//    navigation: true
//});

lista_anio_cal = function(url,id){
    $('#anio_cal')
    .ajaxStart(function(){
        $(this).show();
        $(this).html('Cargando años  <img  src="<?php print(base_url()); ?>include/imagenes/ajax-loader.gif" />');
    })
    .ajaxComplete(function(){
        //$(this).hide();
    });      
    $.ajax({
        type:"post",
        data:{ id:id },
        dataType:"json",
        url:url,
        success:function(data){
            
            if (data.success){
                var url_select='<?php print(base_url().'index.php/mod_gestioncontribuyente/gestion_calendarios_de_pago_c/lista_anios_cal/'); ?>';
                var muestra='';
                var lista = data.datos;
                var select_abre='<select class="ui-widget-content ui-corner-all" onchange="lista_meses_cal(\''+url_select+'\',this.value)">';
                var option_vacio='<option value="">Seleccione</option>';
                var select_cierra='</select>';
                muestra+=select_abre+option_vacio;
                for(i in lista){
                    
                    var opt_abre = ('<option value="'+lista[i].id+'">');
                    var opt_cierra = ('</option>');
                    muestra+=opt_abre+lista[i].ano+opt_cierra;
                }
                muestra+=select_cierra;
                $('#anio_cal').html(muestra);
            }else{
                alert('error')
            }
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

lista_meses_cal = function(url,id){

    $('#anio_caldf')
    .ajaxStart(function(){
        $(this).show();
        $(this).html('Cargando años  <img  src="<?php print(base_url()); ?>include/imagenes/ajax-loader.gif" />');
    })
    .ajaxComplete(function(){
        //$(this).hide();
    });      
    $.ajax({
        type:"post",
        data:{ id:id },
        dataType:"json",
        url:url,
        success:function(data){
            
            if (data.success){
                var muestra='';
                var lista = data.datos;
                var select_abre='<select class="ui-widget-content ui-corner-all">';
                var option_vacio='<option value="">Seleccione</option>';
                var select_cierra='</select>';
                muestra+=select_abre+option_vacio;
                for(i in lista){
                    
                    var opt_abre = ('<option value="'+lista[i].id+'">');
                    var opt_cierra = ('</option>');
                    muestra+=opt_abre+lista[i].ano+opt_cierra;
                }
                muestra+=select_cierra;
                $('#anio_cal').html(muestra);
            }else{
                alert('error')
            }
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
  <style>
      #table_cal_contri ,#table_cal_calpago{
          /*width:100%;*/
          border-top: 0px #000 solid;
          border-left: 0px #000 solid;
          border-right: 0px #000 solid;
          border-bottom:0px #000 solid;
      }
  </style>
  
  <table class="ui-widget-content   ui-corner-all" style="border:1px #000 solid;">
      <tr class="ui-widget-header   ui-corner-all"><td style="border:0px #000 solid;" colspan="13"><center>Calendario de Obligaciones Tributarias</center></td></tr>
      
      <?php for($i=0;$i<=sizeof($tipo_contribuyentes);$i++): ?>
  
        <tr class="ui-widget-content   ui-corner-header" style="border:1px #000 solid;">
            <?php for($j=1;$j<=13;$j++): ?>
            <td class="ui-widget-content   ui-corner-all" style="border:1px #000 solid;"> 
                <?php
                if ($i==0){
                switch($j){
                    case '1':
                        print('CONTRIBUYENTES');
                        break;
                    case '2':
                        print('ENE');
                        break;
                    case '3':
                        print('FEB');
                        break;
                    case '4':
                        print('MAR');
                        break;
                    case '5':
                        print('ABR');
                        break;  
                    case '6':
                        print('MAY');
                        break;   
                    case '7':
                        print('JUN');
                        break;
                    case '8':
                        print('JUL');
                        break;
                    case '9':
                        print('AGO');
                        break;
                    case '10':
                        print('SEP');
                        break;  
                    case '11':
                        print('OCT');
                        break;
                    case '12':
                        print('NOV');
                        break;
                    case '13':
                        print('DIC');
                        break;                    
                    		

                        }
                }else{
                    if($j==1){
                        print($tipo_contribuyentes[$i-1]['nombre']);
                    }
                    
                
                
        }
                ?> 
            </td>
            <?php endfor; ?>
        </tr>
      <?php endfor; ?>
      
  </table>
  