<script >
$(function() {
    

    $("#busca_general<?php print($diferenciador_funciones); ?> input, select").addClass('ui-state-highlight ui-corner-all');
    $("#busca_general<?php print($diferenciador_funciones); ?> select ").addClass('ui-state-highlight ui-corner-all');
    $('#rif<?php print($diferenciador_funciones); ?>').attr('placeholder', 'Busqueda General');
    $('#rif<?php print($diferenciador_funciones); ?>').attr('disabled', 'disabled');    
    
    filtro<?php print($diferenciador_funciones); ?> = function(valor){
        if(valor==0){
            $('#rif<?php print($diferenciador_funciones); ?>').val('');
            $('#rif<?php print($diferenciador_funciones); ?>').attr('placeholder', 'Busqueda General');
            $('#rif<?php print($diferenciador_funciones); ?>').attr('disabled', 'disabled');
            
        }else if(valor==1){
            $('#rif<?php print($diferenciador_funciones); ?>').val('');
            $('#rif<?php print($diferenciador_funciones); ?>').removeAttr("disabled");
            $('#rif<?php print($diferenciador_funciones); ?>').removeAttr("placeholder");
        }
        
    }
    $("#omisos_btn<?php print($diferenciador_funciones); ?>").button({
        icons: {
                primary: ' ui-icon-search'
                
        }

    }); 
    $("#avanzada_btn<?php print($diferenciador_funciones); ?>").button({
        icons: {
                primary: ' ui-icon-plusthick'
                
        }

    });
    $("#avanzada_btn<?php print($diferenciador_funciones); ?>").click(function(){
        if ($('#mas<?php print($diferenciador_funciones); ?>').is (':visible')){
            $("#mas<?php print($diferenciador_funciones); ?>").hide("slide", { direction: "up" }, 1000);
            $("#avanzada_btn<?php print($diferenciador_funciones); ?>").button({
                icons: {
                        primary: ' ui-icon-plusthick'

                }

            });         
        }
        if ($('#mas<?php print($diferenciador_funciones); ?>').is (':hidden')){
            $("#mas<?php print($diferenciador_funciones); ?>").show("slide", { direction: "up" }, 1000);
            $("#tipocont_cal<?php print($diferenciador_funciones); ?>").val(0).attr('selected', 'selected');
            $("#anio_cal<?php print($diferenciador_funciones); ?>").val(0).attr('selected', 'selected');
            $("#meses_cal<?php print($diferenciador_funciones); ?>").val(0).attr('selected', 'selected');
            $("#avanzada_btn<?php print($diferenciador_funciones); ?>").button({
                icons: {
                        primary: 'ui-icon-minusthick'

                }

            });           
        }     
//            $("#detalle").remove();
            
//            argumentos = "<div id='detalle'>  <p><strong>DROP</strong></p>  <p><strong>direction</strong> tipo string y puede ser vertical - horizontal  <strong><br />  mode</strong> tipo string y puede ser show - hide</p></div>";
//            $(argumentos).appendTo("#argumentos");
            return false;			
    });

    lista_anio_cal<?php print($diferenciador_funciones); ?> = function(url,id){
        if(id>0){
            $('#carga_omiso<?php print($diferenciador_funciones); ?>').ajaxStart(function(){
                $(this).show();
                $(this).html('<img  src="<?php print(base_url()); ?>include/imagenes/ajax-loader.gif" />');
            }).ajaxComplete(function(){
                $(this).html('');
                $(this).hide();
            });      
            $.ajax({
                type:"post",
                data:{ id:id },
                dataType:"json",
                url:url,
                success:function(data){

                    if (data.success){
                        var url_select='<?php print(base_url().'index.php/mod_gestioncontribuyente/lista_contribuyentes_general_c/lista_anios_cal/'); ?>';
                        var muestra='';
                        var lista = data.datos;
                        var select_abre='<select class="ui-widget-content ui-corner-all" onchange="lista_meses_cal<?php print($diferenciador_funciones); ?>(\''+url_select+'\',this.value)">';
                        var option_vacio='<option value="">Todos</option>';
                        var select_cierra='</select>';
                        muestra+=select_abre+option_vacio;
                        for(i in lista){

                            var opt_abre = ('<option value="'+lista[i].id+':'+lista[i].ano+'">');
                            var opt_cierra = ('</option>');
                            muestra+=opt_abre+lista[i].ano+opt_cierra;
                        }
                        muestra+=select_cierra;
                        $('#anio_cal<?php print($diferenciador_funciones); ?>').html(muestra);
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


      
    }
    lista_meses_cal<?php print($diferenciador_funciones); ?> = function(url,cadenaIdAnio){
        arregloSeparado = cadenaIdAnio.split(':');
        if(arregloSeparado[0]>0){

            $('#carga_omiso<?php print($diferenciador_funciones); ?>')
            .ajaxStart(function(){
                $(this).show();
                $(this).html('<img  src="<?php print(base_url()); ?>include/imagenes/ajax-loader.gif" />');
            })
            .ajaxComplete(function(){
                $(this).html('');
                $(this).hide();
            });      
            $.ajax({
                type:"post",
                data:{ id:cadenaIdAnio },
                dataType:"json",
                url:url,
                success:function(data){

                    if (data.success){
                        var muestra='';
                        var lista = data.datos;
                        var select_abre='<select class="ui-widget-content ui-corner-all">';
                        var option_vacio='<option value="">Todos</option>';
                        var select_cierra='</select>';
                        muestra+=select_abre+option_vacio;
                        for(i in lista){

                            var opt_abre = ('<option value="'+lista[i].periodo+'">');
                            var opt_cierra = ('</option>');
                            muestra+=opt_abre+lista[i].periodo+opt_cierra;
                        }
                        muestra+=select_cierra;
                        $('#meses_cal<?php print($diferenciador_funciones); ?>').html(muestra);
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
    } 
    busqueda_omisos<?php print($diferenciador_funciones); ?> = function(form,url) {
//    event.preventDefault();
        $('#carga_omiso<?php print($diferenciador_funciones); ?>')
        .ajaxStart(function(){
            $(this).show();
            $(this).html('<img  src="<?php print(base_url()); ?>include/imagenes/ajax-loader.gif" />');
        })
        .ajaxComplete(function(){
            $(this).html('');
            $(this).hide();
        });
        $.ajax({
            type:"post",
            data:$('#'+form).serialize(),
            dataType:"html",
            url:url,
            success:function(html){
                $("#respuesta_consulta<?php print($diferenciador_funciones); ?>").empty();
                $("#respuesta_consulta<?php print($diferenciador_funciones); ?>").hide();
                $("#respuesta_consulta<?php print($diferenciador_funciones); ?>").html(html);
                $("#respuesta_consulta<?php print($diferenciador_funciones); ?>").show("slide", { direction: "up" }, 1000);
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
        return false;
        }   
//        $("#omisos_btn<?php print($diferenciador_funciones); ?>").click(function() {
          ejecutaBusquedadOmisos=function(){
            <?php print("busqueda_omisos".$diferenciador_funciones); ?>('busca_general<?php print($diferenciador_funciones); ?>','<?php print(base_url().'index.php/mod_gestioncontribuyente/lista_contribuyentes_general_c/consulta_responde/'); ?>');
          }
//        });
        });
</script>
<style>


    
    
</style>

<form class="clase_oculta_muestra" id="busca_general<?php print($diferenciador_funciones); ?>">
    <b><?php print($descripcion);?></b><br/><br/>
    <input type="hidden" value="<?php print($vista); ?>" name="vista" />
    <input type="hidden" value="<?php print($filtro); ?>" name="filtro" />
    <input type="hidden" value="<?php print($filtro_extemporaneo); ?>" name="filtro_extemporaneo" />
    <center>
        <div style="width:80%;border: 0px #000 solid;">
            <div id="mas<?php print($diferenciador_funciones); ?>" class="ui-corner-all ui-widget-content" style="display:none;width: 88%">
                <table style="width:100%">
                    <tr>
                        <td>
                            <label ><b>Tipo Contribuyente</b></label>
                        </td>
                        <td>
                            <select id="tipocont_cal<?php print($diferenciador_funciones); ?>" name="tipocont_cal" onchange="<?php print("lista_anio_cal".$diferenciador_funciones); ?> ('<?php print(base_url().'index.php/mod_gestioncontribuyente/lista_contribuyentes_general_c/lista_anios_cal/'); ?>',this.value)">
                                <option value="0" selected>Todos</option>
                                <?php 
                                foreach ($tipo_contribuyentes as $valor):
                                    print("<option value='$valor[id]'> $valor[nombre] </option>");
                                endforeach;
                                ?>
                            </select>                 
                        </td>

                    </tr>
                    <tr>


                        <td colspan='2'>
                            <label ><b>Año a Consultar</b></label>

                            <select id="anio_cal<?php print($diferenciador_funciones); ?>" name="anio_cal" onchange="<?php print("lista_meses_cal".$diferenciador_funciones); ?>('<?php print(base_url().'index.php/mod_gestioncontribuyente/lista_contribuyentes_general_c/lista_periodos_cal/'); ?>',this.value)" >
                                <option value="0" selected>Todos</option>

                            </select>
                            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                            <label ><b>Periodo Gravable</b></label>
                            <select id="meses_cal<?php print($diferenciador_funciones); ?>" name="meses_cal">
                                <option value="0" selected>Todos</option>

                            </select>  
                        </td>

                    </tr>
        <!--            <tr>
                        <td>
                            <label ><b>Periodo Gravable</b></label>
                        </td>
                        <td>
                            <select id="meses_cal" name="meses_cal">
                                <option value="0" selected>Todos</option>

                            </select>                 

                        </td>
                        <td id="carga_periodos"></td>
                    </tr>-->
                </table>

            </div>       
            <table>
                <tr>
                    <td>
                        <label ><b>Filtro</b></label>
                        <select id="" onchange="<?php print("filtro".$diferenciador_funciones); ?>(this.value)">
                            <option value="0" selected>Todos</option>
                            <option value="1">Rif</option>
                        </select>               
                    </td>
                    <td><input class="rif<?php print($diferenciador_funciones); ?>" id="rif<?php print($diferenciador_funciones); ?>" name="rif" type="text" /></td>
                    <td><button id="omisos_btn<?php print($diferenciador_funciones); ?>" onclick="ejecutaBusquedadOmisos()"  type="button" >Buscar</button></td>
                    <td><button id="avanzada_btn<?php print($diferenciador_funciones); ?>" type="button" >Busqueda Avanzada</button></td>
                    <td id="carga_omiso<?php print($diferenciador_funciones); ?>"></td>
                </tr>
            </table>
        </div>
    </center>

     
</form>
<div class="bavanz-respuesta"id="respuesta_consulta<?php print($diferenciador_funciones); ?>"></div>
<div style="float:left;" id="revisa_asigna_omisos_fiscalizacion"></div>
