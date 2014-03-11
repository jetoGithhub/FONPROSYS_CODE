<style>
    
    #calendario_consu{
        margin-left: 10%
    }
    
</style>
<?php if(isset($ident)): ?>
<div class="ui-widget-header" style="text-align:center; font-size: 12px; font-style: italic; margin-bottom: 10px; width: 80%; margin-left: 10%">Calendario de Obligaciones Tributarias FONPROCINE</div>

<?php endif;?>
<form id="calendario_consu" class="" name="calendario_consu">
<br/><br/>
<table id="table_consu_contri">
    <tr>
        <td style=" border-right: 0px #000 solid;width:130px" class="ui-widget-content  ui-corner-tl ui-corner-bl">
            <strong>Tipo de contribuyente</strong>
        </td>
        <td style=" border-left:  0px #000 solid;" class="ui-widget-content   ui-corner-tr ui-corner-br ">
            <select class="ui-widget-content ui-corner-all" id="contri_cal_cnsu" name="contri_cal_cnsu" onchange="lista_anio_consucal('<?php print(base_url().'index.php/mod_gestioncontribuyente/gestion_calendarios_de_pago_c/lista_anios_cal/') ?>',this.value);">
                <option value="">Seleccione</option>
                <?php 
                foreach ($tipo_contribuyentes as $valor):
                    print("<option value='$valor[id]:$valor[tipe]'> $valor[nombre] </option>");
                endforeach;
                ?>
            </select>
        </td>
    </tr>
</table>
<br/>
<table id="table_consu_calpago">
    <tr>
        <td style=" border-right: 0px #000 solid;width:130px" class="ui-widget-content  ui-corner-tl ui-corner-bl">
             <strong>Calendarios por año </strong>
        </td>
        <td id="anio_consu_cal_td" style=" border-left:  0px #000 solid;" class="ui-widget-content   ui-corner-tr ui-corner-br ">
            <select class="ui-widget-content ui-corner-all"  id="anio_cal_consu" name="anio_cal_consu" onchange="dispara_anio_consulta(); muestra_cuerpo_consulta(this.value);" >
                <option value="">Seleccione</option>
<!--                <?php 
//                for ($an=2006;$an<=2021;$an++):
//                    print("<option class='val_anio' value='$an'> $an </option>");
//                endfor;
                ?>                -->

            </select>&nbsp;&nbsp;<div id="img_anio" style="float: right;"></div>
        </td>
    </tr>
</table>

<script>
 $(function() {
     muestra_cuerpo_consulta=function(anio){
         var val=$('#contri_cal_cnsu').val();
     
         $("#cuerpo_crea_consulta").load(
              "<?php print(base_url().'index.php/mod_gestioncontribuyente/gestion_calendarios_de_pago_c/cuerpo_consulta_calendario/');?>"+val+'/'+anio, 
              function(response, status, xhr) {
                  if (status == "error") {
                      var msg = "ERROR AL CONECTAR AL SERVIDOR:";
                      $("#cuerpo_cal").html('')
                      $("#dialog-alert")
                      .children("#dialog-alert_message")
                      .html(msg + xhr.status + " " + xhr.statusText);
                      $("#dialog-alert").dialog("open");
                  }
              });
     };
     dispara_anio_consulta=function(){
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
    $( ".datepicker" ).datepicker({yearRange: "2002:2002",changeMonth: false,changeYear: false,showOtherMonths: true, stepMonths: 12,numberOfMonths: 1,showButtonPanel: false});
    $( ".datepicker" ).datepicker( "setDate", "10/12/2012" );
    $( ".datepicker" ).datepicker( { hideIfNoPrevNext: true, duration: '' } );
    
    $( ".datepicker" ).click( function(){$("div.ui-datepicker-header a.ui-datepicker-prev,div.ui-datepicker-header a.ui-datepicker-next").hide(); } );
});
  


lista_anio_consucal = function(url,id){
//    $('#img_anio')
//    .ajaxStart(function(){
//        $(this).show();
//        $(this).html('Cargando años  <img  src="<?php print(base_url()); ?>include/imagenes/ajax-loader.gif" />');
//    })
//    .ajaxComplete(function(){
//        //$(this).hide();
//    });
$("#cuerpo_crea_consulta").empty();
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
                var select_abre='<select class="ui-widget-content ui-corner-all"  id="anio_cal_consu" name="anio_cal_consu" onchange="dispara_anio_consulta(); muestra_cuerpo_consulta(this.value);">';
                var option_vacio='<option  class="val_anio" value="">Seleccione</option>';
                var opt_cierra = ('</option>');
                for(var i_a=2000;i_a<=2021;i_a++){
                    option_vacio+='<option class="val_anio" value="'+i_a+'">'+i_a+'</option>';
                    
                }
                var select_cierra='</select>&nbsp;&nbsp;<div id="img_anio" style="float: right;"></div>';
                muestra+=select_abre+option_vacio+select_cierra;
//                alert(muestra)
                $('#anio_consu_cal_td').html(muestra);
//                for(i in lista){
//                $('.val_anio').each(function(r){
//                    if(lista[i].ano==$(this).val()){
//                        $(this).attr('disabled', 'disabled'); 
//                        
//                    }
//                });
//
//                }

            }else{
                
               var div='<div id="error_calp" style="padding: 0 .7em; width: 250px; margin-top:5px; margin-left: 220px" class="ui-corner-all ui-state-highlight" >';
                   div=+'<p style="font-family: sans-serif;color:#CD0A0A;"><span style="float: left; margin-right: .3em;" class="ui-icon ui-icon-info"></span><strong>alert: </strong>No existe calendarios cargados para este tipo de contribuyente</p>';
                   div+="</div>";
                   $("#cuerpo_crea_consulta").html(div);
                   $("#error_calp").css({background:'#FEF6F3',border:'1px solid #CD0A0A'});
               
                
            }
        },
        beforeSend:function(){    
        $('#img_anio').html('<img  src="<?php print(base_url()); ?>include/imagenes/ajax-loader.gif" />');          
        },
        complete:function(){
            $('#img_anio').html('');
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
      #table_consu_contri ,#table_consu_calpago{
          /*width:100%;*/
          border-top: 0px #000 solid;
          border-left: 0px #000 solid;
          border-right: 0px #000 solid;
          border-bottom:0px #000 solid;
      }
  </style>
  <br /><br />
  <table id="fecha_table"class="ui-widget-content   ui-corner-all focus-estilo form-style" style="border:1px #000 solid; width: 90%">
      <tr class="ui-widget-header   ui-corner-all"><td style="border:0px #000 solid; padding: 5px" colspan="2"><center>CONSULTA DE CALENDARIO DE OBLIGACIONES TRIBUTARIAS</center></td></tr>
        <tr class="ui-widget-content   ui-corner-header" style="border:1px #000 solid;">
          <td id="cuerpo_crea_consulta">  
             
          </td>
        </tr>
        <!--///////aqui va el cuerpo que esta en la vista nueva ojo/////////////-->
      
  </table>
  
</form>

