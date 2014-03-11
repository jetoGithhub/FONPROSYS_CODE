<?php // print_r($data) ?>


<html>
 <head>
     <style>
         
         /*estilo para agregar una imagen a un boton como fondo*/
         .btn_buscar_img{
              background:url("<? echo base_url().'include/imagenes/iconos/ic_buscar_a.png'?>");
              border:0px;
              width:32px;
              height:32px;
         }
         
        .ui-combobox {
           position: relative;
           display: inline-block;
        }
        .ui-combobox-toggle {
            position: absolute;
            top: 0;
            bottom: 0;
            margin-left: -1px;
            padding: 0;
            /* adjust styles for IE 6/7 */
            /*height: 1.7em;
            *top: 0.1em;*/
        }
        .ui-combobox-input {
            margin: 0;
            padding: 0.3em;

        }
     </style>     

<script>

//ocultar el campo rif al cargar la página
$(function() {
        ayudas('.','por-aprobar','bottom left','top right','fold','up');
        $( "#radio" ).buttonset();
        $('#rif_buscar').hide();
        $('#fechas_buscar').hide();
        $('#listar_por_calcular').hide();
        $('#respuesta_buscar').hide();
        $('#error-reparo-activa').hide();

        //calendarios desde - hasta
         //desde
         $( "#from" ).datepicker({

            dateFormat: 'dd-mm-yy',
            defaultDate: "+1w",
            changeMonth: true,
            numberOfMonths: 1,
            onClose: function( selectedDate ) {
                $( "#to" ).datepicker( "option", "minDate", selectedDate );
            }
         });
        //hasta
        $( "#to" ).datepicker({

            dateFormat: 'dd-mm-yy',
            defaultDate: "+1w",
            changeMonth: true,
            numberOfMonths: 1,
            onClose: function( selectedDate ) {
                $( "#from" ).datepicker( "option", "maxDate", selectedDate );
            }
         });
                
      $('#dialog_session_aprueba').dialog({

            modal: true, //inhabilitada pantalla de atras
            autoOpen: false,
            draggable: false,
            resizable: false, //evita cambiar tamaño del cuadro del mensaje
            show: "clip", //efecto para abrir cuadro de mensaje
            hide: "clip", //efecto para cerrar cuadro de mensaje
            title: "Aprobacion de Multas"
//            buttons: {  //propiedad de dialogo, agregar botones
//                Guardar: function() { 
//                        //llamado del formulario, en este caso #form_new corresponde al id del form(en los archivos de las vistas)
//                        $('#form_carga_asignacion').submit(); 
//                    }
//                    ,
//                Cancelar: function() { 
//                        $( this ).dialog( "close" ); 
//                }

//            }
        });           
                
                
});
espera_aprueba_calculo=function(){
    $.blockUI({ 
        message: $('#espera_aprueba_calculo'),
        css: { 
            border: 'none',
            padding: '15px', 
            backgroundColor: '#fff', 
            '-webkit-border-radius': '10px', 
            '-moz-border-radius': '10px', 
            opacity: .7, 
            color: '#CD0A0A' 
        } });  
    
};

        //formato para el campo rif
        jQuery(function($){
            $.mask.definitions['#'] = '[JVGEjvge]';
            $("#campo_rif").mask("#999999999");
        
        });
        
        // atributos del boton enviar
        $('#btn_consulta').button({
            icons: 
            {
                primary: "ui-icon-search"
             },
             text: false
        });
        
        function mostrarOpcion(elemento) 
        {
            if(elemento.value=='0')
            {
//                $('#btn_consulta').prop('disabled', true);
                $("#rif_buscar").css('display','none');
                $("#fechas_buscar").css('display','none');
            }if(elemento.value=='todos' || elemento.value=='reciente')
            {
//                $('#btn_consulta').prop('disabled', false);
                $("#rif_buscar").css('display','none');
                $("#fechas_buscar").css('display','none');
            }if(elemento.value=='rif') {
//               $("#rif_buscar").show();
//               $("#fechas_buscar").style.display = "none";
                    $("#rif_buscar").css('display','inline');
                    $("#fechas_buscar").css('display','none');
//                    $('#btn_consulta').prop('disabled', false);
            } if(elemento.value=='fecha') {
                $("#rif_buscar").css('display','none');
                $("#fechas_buscar").css('display','inline'); 
//                $('#btn_consulta').prop('disabled', false);
            }
        }
        

        //funcion boton buscar
        boton_buscar=function(efecto){

                $("#respuesta_buscar").hide();
            /*efecto=parametro que identifica si se mostrara o no el efecto de movimiento
             *en el caso del onclick del boton buscar se pasa true y en el onclick del boton 
             *aprobar se pasa false*/
            if(efecto){
                $('#listar_por_calcular').hide();
            }
            
            /*$('#listar_por_calcular').hide("slide", {direction:'up'} ,1000 );
             *Aplica en el caso de colocar el efecto slide con movimiento up - de arriba hacia abajo-
             *al momento de ocultar el div
             */
            
            /*con el this se captura los atributos que esten dentro de etiquetas de html
             * en este caso catura el id de la etiqueta que tienen por class btn_consulta
             * this.id;*/
            
            /*capturar variables, pueden ser antes del ajax o dentro en el data
             * var se declara la variable
             * indicar el id del campo
             * el .val captura el valor
             */
            var rif=$('#campo_rif').val();
            var fecha_desde=$('#from').val();
            var fecha_hasta=$('#to').val();
            var valor_radio=false;
            var tipo_calculo=null;
            
            //capturar el name de etiquetas con attr
//            var namerif=$('#campo_rif').attr('name');

            //capturar el value del select para identificar la opcion seleccionada
            var valor_select=$('#filtro_basico').val();
//            alert(valor_select);
            $(".por-aprobar input[type=radio]").each(function(index) {   

                     if($(this).attr("checked")=='checked'){
//                         alert($(this).val());
                         tipo_calculo=$(this).val();   
                         valor_radio=true;
                         return false;
                      }
            }); 
            
            if((valor_select=='0') || (valor_radio==false)){
//                alert('vacio')
                $("#respuesta_buscar").html("<p>Debe selecionar un estado y un tipo de calculo</p>");
                $("#respuesta_buscar").addClass('ui-state-error');		                            
	        $("#respuesta_buscar").css({background:'#FEF6F3',border:'1px solid #CD0A0A'});
                $("#respuesta_buscar").show('slide',{ direction: "up" },500);

                
            }else
            {
                $("#respuesta_buscar").hide();
//                alert(tipo_calculo)
            //funcion ajax
            
                $.ajax({
                    //tipo de envio
                    type:"post",
                    //variables que pasan
                    data:{ rif:rif,fecha_desde:fecha_desde,fecha_hasta:fecha_hasta,valor_select:valor_select,tipo_calculo:tipo_calculo },
                    //tipo de recibir datos
                    dataType:"json",
                    //url asi donde se dirigen los datos al hacer clic, al controlador
                    url:"<?php echo base_url().'index.php/mod_gestioncontribuyente/lista_por_aprobar_c/consulta_extemp_calculados'; ?>",
                    success:function(data){
                         $('#listar_por_calcular').html(data);  
                         //efecto fold - movimiento
                         $( "#listar_por_calcular" ).show( "fold",1000 );

                         //efecto slide
    //                     $( "#listar_por_calcular" ).show( "slide", {direction:'down'} ,1000 );
                    }
                });
             }
                
           }
            
            
            
    //boton aprobar de la segunda vista
    //boton aprobar
    boton_aprobar=function(){
            $("#error-reparo-activa").hide();
            var array_value= new Array()
            var i=0
            $("#listar input[type=checkbox]").each(function(index) {  

                if($(this).is(':checked')){
                 
                    array_value[i]=$(this).val();                    
                    i++;
                }              
                
            });
            var tipo_calculo=null;
            $(".por-aprobar input[type=radio]").each(function(index) {  

                if($(this).is(':checked')){
                 
                    tipo_calculo=$(this).val();                    
                    return false;
                }              
                
            });
            if(i!=0){
//                alert(array_value);
                $('#dialog_session_aprueba').dialog({
                      buttons: {  //propiedad de dialogo, agregar botones
                            Aprobar: function() { 
                                //llamado del formulario, en este caso #form_new corresponde al id del form(en los archivos de las vistas)
                                $('#frmdiagaprueba').submit(); 
                            }
                            ,
                            Cancelar: function() { 
                                    $( this ).dialog( "close" ); 
                            }

                        }  
                    });
                var html='<form id="frmdiagaprueba" class="focus-estilo form-style">';
                    html+='<input type="hidden" id="tipo_calculo" name="tipo_calculo" value="'+tipo_calculo+'" />';
                    html+='<input type="hidden" id="valores" name="valores" value="'+array_value+'" />';
                    html+='<label>Nº de Session</label>';
                    html+='<input type="text" id="nsession" name="nsession" class=" requerido ui-widget-content ui-corner-all" />';
                    html+='<label>Fecha de Session</label>';
                    html+='<input type="text" id="fechasession" name="fechasession" class=" requerido ui-widget-content ui-corner-all" />';
                    html+='</form>'
                    $('#dialog_session_aprueba').html(html);
                    
                 $( "#fechasession" ).datepicker({
                   dateFormat: 'dd-mm-yy',
                    dayNamesMin: [ "Do", "Lu", "Ma", "Mi", "Ju", "Vi", "Sa" ],
                    monthNames: [ "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre" ],
                    monthNamesShort: [ "Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sept", "Oct", "Nov", "Dic" ],
                    yearRange: "2000:<?php echo date('Y');?>",
                    changeMonth: true,
                    changeYear: true
                });
                $( "#dialog_session_aprueba" ).dialog('open');

                validador('frmdiagaprueba','<?php echo base_url()."index.php/mod_gestioncontribuyente/lista_por_aprobar_c/devolver_recaudacion"?>','procesa_aprobacion_calculo');
 
                
  
            }else{
            
                $('#error-reparo-activa').html('<p style="font-family: sans-serif;color:#CD0A0A;"><span style="float: left; margin-right: .3em;" class="ui-icon ui-icon-alert"></span><strong>ERROR: </strong>Marque al menos una para aprobar.</p>')
                $("#error-reparo-activa").addClass('ui-state-error ui-corner-all'); 
                $("#error-reparo-activa").css({background:'#FEF6F3',border:'1px solid #CD0A0A'});;
                $("#error-reparo-activa").show('slide',{ direction: "up" },1500);
                
            }
  };
            
 procesa_aprobacion_calculo=function(form,url){
 
     $.ajax({  
          type:'post',
          data:$("#"+form).serialize(),
          dataType:'json',
          url:url,
          success:function(data){

                if(data.resultado==true){

                 // $("#tabs").tabs("load",0); 
                   $.unblockUI();//cierra mensaje de espera
                   $("#espera_aprueba_calculo").empty();
                   /*Llamar la funcion que carga la vista lista_por_aprob_extemp una vez que sea 
                    *aprobado el calculo recarga la pagina sin efecto, por eso el parametro false*/
                   boton_buscar(false);
                 }


          },
           error: function (request, status, error) {
                    var html='<p style=" margin-top: 15px">';
                                  html+='<span class="ui-icon ui-icon-alert" style="float: left; margin: 0 7px 50px 0;"></span>';
                                  html+='Disculpe ocurrio un problema. <br /> <b>ERROR:"'+error+'"</b>';
                                  html+='</p><br />';
                                  html+='<center><p>';
                                  html+='<b>Si el error persiste comuniquese al correo soporte@cnac.gob.ve</b>';
                                  html+='</p></center>';
                               $("#dialogo-error-conexion").html(html);
                               $("#dialogo-error-conexion").dialog('open');
            },
            beforeSend:function(){

                $("#dialog_session_aprueba").dialog( "close" );
                $("#espera_aprueba_calculo").html('<p><b>POR FA VOR ESPERE EL SISTEMA ESTA APROBANDO LOS CALCULOS SELECIONADOS...</b></p><br /><br /><img  src="<?php print(base_url()); ?>include/imagenes/loader.gif" width="35" height="35" />');             
                espera_aprueba_calculo();// mensage de espera
             },
             complete:function(){

                
             }  
       }); 
 
 };
        </script>
        
 </head>
<div id="espera_aprueba_calculo" class="ui-corner-all"></div> 
<div id="dialog_session_aprueba"></div> 
<!--espacio para el filtro-->
<table class="por-aprobar"  style="font-size: 11px; margin-bottom: 10px; width: 100%;">
    <tr>
        <td>
            <b>Consultar C&aacute;lculos por Aprobar:</b>
            <p>
                <select style="margin-bottom:0px; width:18%; padding: .2em; font-family: sans-serif, monospace;  font-size: 12px" name="filtro_basico" onchange="mostrarOpcion(this)" id="filtro_basico">
                    <option value="0">Seleccione</option>
                    <option value="todos">Todos</option>
                    <option value="reciente">Recientes</option>
                    <option value="rif">RIF</option>
                    <option value="fecha">Fecha</option>

               </select>
                
                <span id="rif_buscar">
                    <input txtayuda="Debe colocar el rif que desee buscar ejemplo: 'V-1234567890', la v debe ir en mayuscula" class='ayuda' style="margin-bottom:0px; width:20%; padding: .2em; font-family: sans-serif, monospace;  font-size: 12px" name="campo_rif" type="text" id="campo_rif" size="30"/>
                </span>
                
                <span id="fechas_buscar">
                    <label for="from">Desde</label>
                    <input style="margin-bottom:0px; width:15%; padding: .2em; font-family: sans-serif, monospace;  font-size: 12px" type="text" id="from" name="from" />
                    <label for="to">Hasta</label>
                    <input style="margin-bottom:0px; width:15%; padding: .2em; font-family: sans-serif, monospace;  font-size: 12px" type="text" id="to" name="to" />
                </span>
                
                <span>
<!--con el estilo que coloca una imagen en el boton                    
<button id="btn_consulta" onclick="boton_buscar(true)" class="btn_buscar_img" disabled="disabled">-->
                        <!--<img src="<?php // echo base_url()."/include/imagenes/iconos/ic_buscar_a.png"; ?>" width="28px" height="28px" />-->
                    <button txtayuda='Buscar los cálculos realizados' class='ayuda' id="btn_consulta" onclick="boton_buscar(true)" style="width: 30px; height: 25px" ></button>    

                </span>
                
            </p>
            <div id="radio" style="margin-bottom:12px;">
                <b>Tipo de C&aacute;lculo:</b><br />
                <input type="radio" id="radio1" name="radio" value="1" onChange="javascript:$('#listar_por_calcular').empty();" /><label for="radio1">Extempor&aacute;neos</label>
                <input type="radio" id="radio2" name="radio" value="2" onChange="javascript:$('#listar_por_calcular').empty();" /><label for="radio2">Culminatoria de Fiscalizaci&oacute;n</label>
                <input type="radio" id="radio3" name="radio" value="3" onChange="javascript:$('#listar_por_calcular').empty();" /><label for="radio3">Culminatoria de Sumario</label>
            </div>
            
        </td>
    </tr>
</table>
<!-- Fin espacio para el filtro-->

<div id="respuesta_buscar" class="ui-state-error ui-corner-all" style=" width: 200px; height: auto; text-align: center; margin-top: 2%" >
    <!--div donde se mostrara el mensaje de alerta al seleccionar una opcion invalida en la busqueda-->
</div>

<div id="listar_por_calcular">
    <!--div donde se mostrar el listar dependiendo de la seleccion en el buscar-->
</div>
<div id="error-reparo-activa" style=" width: 250px; height: auto; text-align:justify; margin-top: 2%; margin-left:200px"></div>    

<?php // echo $fecha=  time() ?>

	
</html>