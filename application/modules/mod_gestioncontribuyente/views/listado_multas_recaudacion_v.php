<?php // print_r($data)
if(empty($data)):
    
 ?><script>
     
     $("#btn_pdf").attr('disabled','disabled');
     $("#btn_excel").attr('disabled','disabled');
     
    </script>
<?php    
endif;

?>

<script>
ayudas('#','listado_multas_recaudacion','bottom right','top left','fold','up');
$("#esperando_notificaciones").hide();
     
$('#notificar').click(function() {
    $("#esperando_notificaciones").html('<p style="color:#B20000; font-size:12px"><b>Por favor espere..</b><img src="<?php print(base_url()); ?>include/imagenes/ajax-loader.gif", width="16px", heigth="16px"/></p>');
    var array_value= new Array()
        var i=0
        $("#listar input[type=checkbox]").each(function(index) {  

            if($(this).is(':checked')){
//                    alert(this.value)
                array_value[i]=$(this).val();   

                i++;
            }
        });
        if(i!=0){ 
         $("#respuesta_mensage").hide();
         $("#esperando_notificaciones").show();

          $.ajax({
                    type:'post',
                    data:{valores:array_value},
                    dataType:'json',
                    url:'<?php echo base_url()."index.php/mod_gestioncontribuyente/gestion_multas_recaudacion_c/notificar_contrribuyente"?>',
                    success:function(data)
                    {
                        if(data.resultado){
                           $("#esperando_notificaciones").hide(); 
//                             $(".cargaimg <img>").empty(); 
                         buscar_extemcalc(1);
                          $("#respuesta_mensage").html("<p>Notificacion exitosa</p>");
                          $("#respuesta_mensage").show('slide',{ direction: "up" },1000);

                        }

//                           $.each(data, function(index,valor){
//                               
//                               alert(valor.email);
//                           });


                    }


                })

    }else{

        $("#respuesta_mensage").html("<p>Debe selecionar un contribuyente</p>");
        $("#respuesta_mensage").show('slide',{ direction: "up" });
    }
});
$(".rise").click(function(){
 window.open('<?php echo base_url()."index.php/mod_gestioncontribuyente/gestion_multas_recaudacion_c/genera_rise?id="?>'+this.id);

});
$(function(){
 $("#dialog-carga-noti-rise").dialog({
            autoOpen: false,
            height: 150,
            width: 350,
            modal: true,
            title:'Fecha de la Notificacion',
            show:'slide',
            hide:'clip',
            buttons:{
                "activar":function(){
                     $("#frmrisenoti").submit();
                     $(this).dialog('close');
                },
                "Cancelar":function(){

                    $(this).dialog('close');
                }
             }
         
     });
   espera_cargando_notificacion_rise=function(){
        $.blockUI({ 
            message: $('#esperando_notificaciones_rise'),
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
});    
dialog_notificacion_rise=function(valor1,valor2,valor3,valor4){
 
     var htmlform='<form id="frmrisenoti" class="form-style focus-estilo">';
         htmlform+='<input type="hidden" name="id_detaconcalc" id="id_detaconcalc" value="'+valor1+'" />';
         htmlform+='<input type="hidden" name="idconusu" id="idconusu" value="'+valor2+'" />';
         htmlform+='<input type="hidden" name="declaraid" id="declaraid" value="'+valor3+'" />';
         htmlform+='<input type="hidden" name="idconcalc" id="idconcalc" value="'+valor4+'" />';
         htmlform+='<label>Fecha de Notificacion</label>';
         htmlform+='<input type="text" id="fecha_notiextem" name="fecha_noti" class="requerido ui-corner-all ui-widget-content"/>';
         htmlform+='</form>';
     $("#dialog-carga-noti-rise").html(htmlform); 
     
     $("#dialog-carga-noti-rise").dialog('open');
     
     $( "#fecha_notiextem" ).datepicker({
        dateFormat: "dd-mm-yy",
        dayNamesMin: [ "Do", "Lu", "Ma", "Mi", "Ju", "Vi", "Sa" ],
        monthNames: [ "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre" ],
        showAnim: "slide",
        navigationAsDateFormat: true
    });
    
     validador('frmrisenoti','<?php echo base_url()."index.php/mod_gestioncontribuyente/gestion_multas_recaudacion_c/carga_notificacion"?>','carga_notificacion_rise');

};
carga_notificacion_rise=function(form,url){
$("#dialog-carga-noti-rise").dialog('close');
$("#esperando_notificaciones_rise").html('<p><b>POR FA VOR ESPERE EL SISTEMA ESTA GUARDANDO LA NOTIFICACION...</b></p><br /><br /><img  src="<?php print(base_url()); ?>include/imagenes/loader.gif" width="35" height="35" />');             
espera_cargando_notificacion_rise();// mensage de espera    
        $.ajax({
            type:'post',
            data:$("#"+form).serialize(),
            dataType:'json',
            url:url,
            success:function(data){

                if(data.resultado===true){

                     $.unblockUI();//cierra mensaje de espera
                     var current_index = $("#tabs").tabs("option","selected");             
                     $("#tabs").tabs("load",current_index);

                }else{
                    alert('Error Intente de Nuevo')
                }


            }
        }); 
};
</script>


                
                <style>
                    .btn1 a {
                        width: 10px;
                        padding: 15px 25px 10px 25px;
                        font-family: Arial;
                        font-size: 12px;
                        text-decoration: none; color: #ffffff;
                        text-shadow: -1px -1px 2px #618926;
                        background: -moz-linear-gradient(#98ba40, #a6c250 35%, #618926);
                        background: -webkit-gradient(linear,left top,left bottom,color-stop(0, #98ba40),color-stop(.35, #a6c250),color-stop(1, #618926));
                        border: 1px solid #618926;
                        border-radius: 3px; -moz-border-radius: 3px;
                        -webkit-border-radius: 3px;
                        }

                        .btn1 a:hover {
                        text-shadow: -1px -1px 2px #465f97;
                        background: -moz-linear-gradient(#245192, #1e3b73 75%, #12295d);
                        background: -webkit-gradient(linear,left top,left bottom,color-stop(0, #245192),color-stop(.75, #1e3b73),color-stop(1, #12295d));
                        border: 1px solid #0f2557;
                    } 

                </style>
	

<!-- <div id="botonera_reportes" style="float: right; position: relative">
    <button id="btn_pdf" style=" width: auto; height: 25px; border: none">
        <img src="<? // echo base_url().'include/imagenes/iconos/ic_pdf.png'?>" width="14px" height="12px"/>
        <b>PDF</b>
    </button>
    <button id="btn_excel" style=" width: auto; height: 25px; border: none">
        <img src="<? // echo base_url().'include/imagenes/iconos/ic_excel.png'?>" width="14px" height="12px"/>
        <b>Excel</b>
    </button>
            <button id="btn_pdf" style=" width: auto; height: 25px; border: none">Generar PDF</button>
    <button id="btn_excel" style=" width: auto; height: 25px; border: none">Hoja calculo</button>

</div>       -->
<div class="ui-widget-header" style="text-align:center; font-size: 12px; font-style: italic; margin-bottom: 10px; width: 70%; margin-left: 12%;">Listado de Multas por Pagos Extemporáneos</div>

   
<div id="listado_multas_recaudacion">
<table cellpadding="0" cellspacing="0" border="0" class="display" id="listar" width="100%">
	<thead>
		<tr>
			<th>#</th>
                        <th>Identificador</th>
			<th>RIF</th>
                        <th>Razón Social </th>
                        <th>Tipo de Contribuyente </th>
                        <!--<th>Estado</th>-->
                        <?php if($estatus=='aprobado' or $estatus=='negado' ): 
                            echo "<th>A&ntilde;o</th>
                                 <th>Per&iacute;odo</th>";  
                        endif;
                        if($estatus=='enviado'):
                            echo "<th>Fecha envio</th>";
                        endif;
                        ?>
                        <th>Opciones</th>
                </tr>
	</thead>
	<tbody>
           <?
           foreach ($data as $clave => $valor) {
            $con=$clave+1;
            $v=$valor['nombre'];
               echo '<tr>
                        <td>'. $con .'</td>
                        <td>'. $valor["declaraid"].'</td>    
			<td>'. $valor["rif"].'</td>
                        <td>'. $valor["nombre"].'</td>
                        <td>'. $valor["nomb_tcont"].'</td>';
//                        <td>'. $valor["estatus"].'</td>
               echo '  <td>'. $valor["ano_calpago"].'</td>';
                        if($valor['tipo']==0):
                            echo'<td>'. $this->funciones_complemento->devuelve_meses_text($valor["periodo"]).'</td>';
                        endif;    
                        if($valor['tipo']==1):
                            echo'<td>'. $this->funciones_complemento->devuelve_trimestre_text($valor["periodo"]).'</td>';
                        endif;
                        if($valor['tipo']==2):
                            echo'<td>'.$valor["ano_calpago"].'</td>';
                        endif;
                        echo '<td>
                            <button style="width: 25px; height: 25px;" type="button" name="carga-noti"  txtayuda="Cargar Notificacion" class=" ayuda carga-noti" id="carga-noti-'.$valor["id_deta_concalc"].'" onClick="dialog_notificacion_rise('.$valor["id_deta_concalc"].','.$valor["conusuid"].','.$valor['declaraid'].','.$valor["idconcalc"].');" ></button>
                            <button style="width: 25px; height: 25px;" txtayuda="generar RISE" class=" ayuda rise" id="'.$valor['id_deta_concalc'].'"  title=""></button>
                        </td>
                   </tr>';
           }
           ?>
            </tbody>  
         </table>
  
        <div id="dialog-carga-noti-rise"></div>
        <div id="esperando_notificaciones_rise" ></div>
        
</div>
<!--<button id="btn-frmcontras" style="width:100px; height: 25px; margin-top:-10px; margin-left: 20px; position: relative" title="">Actualizar</button><br /><br /></center>-->

        <script>
//            script para asignar atributos al listar diseñado con datatables
            oTable = $('#listar').dataTable({
					"bJQueryUI": true,
					"sPaginationType": "full_numbers",
                                        "oLanguage": {
                                            "oPaginate": {
                                            "sPrevious": "Anterior",
                                            "sNext": "Siguiente",
                                            "sLast": "Ultima",
                                            "sFirst": "Primera"
                                            },

                                            "sLengthMenu": 'Mostrar <select>'+
                                            '<option value="10">10</option>'+
                                            '<option value="20">20</option>'+
                                            '<option value="30">30</option>'+
                                            '<option value="40">40</option>'+
                                            '<option value="50">50</option>'+
                                            '<option value="-1">Todos</option>'+
                                            '</select> registros',

                                            "sInfo": "Mostrando del _START_ a _END_ (Total: _TOTAL_ resultados)",

                                            "sInfoFiltered": " - filtrados de _MAX_ registros",

                                            "sInfoEmpty": "No hay resultados de búsqueda",

                                            "sZeroRecords": "No hay registros a mostrar",

                                            "sProcessing": "Espere, por favor...",

                                            "sSearch": "Buscar:"

                                            }
				});       
                                
       
            $('.rise').button({
                    icons: {
                    primary: "ui-icon-document"
                    },
                    text: false
            }); 
             $('.carga-noti').button({
                    icons: {
                    primary: "ui-icon-tag"
                    },
                    text: false
            });
          


        
 $(".detalle_estatus").click(function(){
        
$("#respuesta_buscar_extemcalc").hide();

var elem = this.id.split('-');
var idconusu=elem[0];
var idcontri=elem[1];
var id_concalc=elem[2];
//            alert(id_concalc)
$.ajax({
           type:'post',
           data:{estatus:$("#estatusCalculo").val(),id_concalc:id_concalc},
           dataType:'json',
           url:'<?php echo base_url()."index.php/mod_gestioncontribuyente/gestion_multas_recaudacion_c/detalles_multas_recaudacion"?>',
           success:function(recibe_ctrl)
           {
               if(recibe_ctrl.resultado=='true'){

                   $("#respuesta_detalles").html(recibe_ctrl.vista);
                   $("#respuesta_detalles").show('slide',{ direction: "right" },1000);  
               }

           }
       });
        
});
     
        </script>
