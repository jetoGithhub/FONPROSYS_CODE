
<script type="text/javascript" charset="utf-8">

        $(document).ready(function() {
			
			$('#respuesta_buscar').hide();

            ayudas('.','presidentes','bottom right','top left','fold','up');
            
            $(".btn_reportes").button();
            
            $('#btn_excel').click(function() {
        
                            window.location='<?php echo base_url()."index.php/mod_administrador/presidentescnac_c/excel_presidentes"?>';
        
			});
            
            $( '#listar_presidentes button' ).button({
                                    icons: {
                                    primary: "ui-icon-trash"
                                    },
                                    text: false
                                   

                                 });
                    


                   $('#boton_enviar').button({
                        icons: 
                        {
                            primary: "ui-icon-plus"
                        },
                        text: false
                    });
                    
                    //id del div donde se mostrara el formulario
                            $( "#frm_presidentes" ).dialog(
                            {
                                modal: true, //inhabilitada pantalla de atras
                                autoOpen: false,
//                                width: 380,
                                draggable: true,
                                resizable: false, //evita cambiar tamaño del cuadro del mensaje
                                show: "show", //efecto para abrir cuadro de mensaje
                                hide: "slide", //efecto para cerrar cuadro de mensaje
                                title: "Presidentes CNAC",
                                dialogClass: "dialog-presidente"
                                
                            });


        });

//funcion para cargar la vista con el formulario de agregar nuevo presidente
cargar_vista_dialog_presidentes=function(url,ident,id_div){
 //si encuentra lleno el parametro id_div le agregara al formulario los botones de guardar y cancelar
    $("#"+id_div).dialog(
    {
 //carga el div con el formulario para agregar nuevos Presidentes, haciendo submit al form

        buttons: {
            Guardar:function(){
                $('#form_new_presidentes').submit();
            },
            Cancelar:function(){
                $( this ).dialog("close");
            }

        }
    });
///////////////////////////////////
    $.ajax({
        type:"post",
        data:{ identificador:ident },
        dataType:"json",
        url:url,
        success:function(data){

            if(data.resultado){
                $("#"+id_div).html(data.vista)
                $("#"+id_div).dialog('open')
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
};


envio_form_presidentes=function(form,url){

//    $.ajax({
//        type:"post",
//        data: $("#"+form).serialize(),
//        dataType:"json",
//        url:url,
//        success:function(data){
//            if (data.resultado){
//                $("#respuesta_buscar").hide();
//                $('#frm_presidentes').dialog('close');
//                alert('La información fue registrada exitosamente');
//                $('#muestra_cuerpo_message').load('<?php // echo base_url()."index.php/mod_administrador/principal_c?padre=177"; ?>')
//                //alert(data.mensaje)
//            } else
//            {
//        $('.dialog-presidente').hide('clip');
        $( "#dialog_confirmar_registro" ).dialog(
        {
                        modal: true, //inhabilitada pantalla de atras
                        autoOpen: false,
                        draggable: true,
                        width: 350,
                        resizable: false, //evita cambiar tamaño del cuadro del mensaje
                        show: "show", //efecto para abrir cuadro de mensaje
                        hide: "slide", //efecto para cerrar cuadro de mensaje
                        title: "Registrar Presidente?",
                        buttons: {
                                "SI": function() {
                                        $( this ).dialog( "close" );
                                                $.ajax({
                                                type:"post",
                                                data: $("#"+form).serialize(),
                                                dataType:"json",
                                                url:url,
                                                success:function(data){
                                                        if (data.resultado){
                                                                $("#respuesta_buscar").hide();
                                                                $('#frm_presidentes').dialog('close');
                                                                $("#tabs").tabs('load',0);
//                                                                alert('La información fue registrada exitosamente');
//                                                                $('#muestra_cuerpo_message').load('<?php echo base_url()."index.php/mod_administrador/principal_c?padre=177"; ?>')
                                                                //alert(data.mensaje)
                                                        } else
                                                        {
                                                                $('#form_activo_presidentes').dialog('close');
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

                                },

                                "NO": function() {
                                        $( this ).dialog( "close" );
//                                        $('.dialog-presidente').show('clip');
                                }
                        }
        });
        //mensaje que mostrara en el dialog de alerta o confirmacion
         $( "#dialog_confirmar_registro" ).html('<h3>El presidente que esta cargando sera el activo en el sistema. ¿Esta usted de acuerdo?</h3>')
         $( "#dialog_confirmar_registro" ).dialog('open');


//            }
//        }
//
//    });

};

              //mensaje deconfirmacion al hacer clic en el boton eliminar
              cargar_alert_dialog=function(url,id,ident,id_div){

                         $( "#frm_presidentes" ).dialog(
                         {
                             modal: true, //inhabilitada pantalla de atras
                             autoOpen: false,
                             draggable: true,
                             width: 350,
                             resizable: false, //evita cambiar tamaño del cuadro del mensaje
                             show: "show", //efecto para abrir cuadro de mensaje
                             hide: "slide", //efecto para cerrar cuadro de mensaje
                             title: "Presidentes CNAC",
                             buttons: {
                                 "SI": function() {
                                     $( this ).dialog( "close" );
                                     $.ajax({
                                         type:"post",
                                         data:{ id:id,identificador:ident },
                                         dataType:"json",
                                         url:url,
                                         success:function(data){
                                             if (data.resultado){
                                                 alert('El Presidente fue eliminado exitosamente')
                                                 $('#muestra_cuerpo_message').load('<?php echo base_url()."index.php/mod_administrador/principal_c?padre=177"; ?>')

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

                                     },

                                 "NO": function() {
                                     $( this ).dialog( "close" );
                                     }
                                 }
                     });
                     //mensaje que mostrara en el dialog de alerta o confirmacion
                     $( "#frm_presidentes" ).html('<h3>Procedera a eliminar el Presidente. ¿Desea continuar?</h3>')
                     $( "#frm_presidentes" ).dialog('open')

                 }
            </script>

                
<style>
		.botonera_reportes #btn_excel #btn_pdf{
             color:#000;
                        
         }
         
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

<div class="ui-widget-header" style="text-align:center; font-size: 12px; font-style: italic; margin-bottom: 10px; width: 80%; margin-left: 10%">Listado de Presidentes CNAC</div>
<table cellpadding="0" cellspacing="0" border="0" class="display presidentes" id="listar_presidentes" width="100%">
	<thead>
		<tr>
			<th>#</th>
			<th>Nombres</th>
			<th>Cedula</th>
			<th>Nro. Gaceta</th>
			<th>Estado</th>
			<th>Fecha</th>
            <th>Opciones</th> 
        </tr>
	</thead>
	<tbody>
           <?
           $baseurl=base_url();
           foreach ($data as $clave => $valor) {
            $con=$clave+1;
            if($valor["bln_activo"]=='t')
            {
				$estado='Activo';
			}else
			{
				$estado='Inactivo';
			}
            $v=$valor['id_presidente'];
               echo '<tr >
                        <td>'. $con .'</td>    
						<td>'. $valor["nombres"].' '. $valor["apellidos"].'</td>
						<td>'. $valor["cedula"].'</td>
						<td>'. $valor["nro_gaceta"].'</td>
						<td>'. $estado.'</td>
						<td>'. $valor["fecha_registro"].'</td>
						<td>
                            <button txtayuda="Eliminar Presidente" class="ayuda" id="b'.$valor["id_presidente"].'" onclick="cargar_alert_dialog('."'".$baseurl.'index.php/mod_administrador/presidentescnac_c/eliminar_presidente'."'".','.$valor["id_presidente"].',1,'."'frm_presidentes'".')" title="Eliminar Presidentes"></button>
                        </td>
                           
                </tr>';
           }
           ?>
  
         </table>
        
         <table border="0" width="100%" class="presidentes">
                <tr>
                    <td align="right">
                        <button txtayuda="Ingresar nuevo Presidente" class="ayuda" id="boton_enviar" title="Agregar Nuevo Presidente" style="width:30px; height:30px;" onclick="cargar_vista_dialog_presidentes('<?php echo base_url().'index.php/mod_administrador/presidentescnac_c/cargar_dialog_new_presidente';?>',5,'frm_presidentes');"></button>
                       <?php if (!empty($data)){?>        
		<!-- botones generar excel y pdf -->
                    <!--<td align="right">-->
                        <div class="botonera_reportes" style="float:left">
                                <button id="btn_excel" class="btn_reportes">
                                        <img src="<? echo base_url().'include/imagenes/iconos/ic_excel.png'?>" width="14px" height="12px"/>
                                        <b>Excel</b>
                                </button>
                        </div>
                    </td>
                <? } ?>
                    
		</tr>
        </table>
<!-- formularios-->
            <div id="frm_presidentes"> 
				<!-- div para cargar el formulario de agregar nuevos presidentes, cuando no hay ningun presidente registrado-->
            </div>
            
            <div id="dialog_confirmar_registro"> 
				<!-- div para cargar el mensaje de confirmacion si se desea continuar con el registro del presidente-->
            </div>
            
            <div id="form_activo_presidentes" >
				<!-- div donde se mostrara el formulario de nuevos presidentes, segunda vista implementada cuando ya hay presidentes
				registrados y se registrara uno nuevo -->
			</div>


         <script>
//            script para asignar atributos al listar diseñado con datatables
            oTable = $('#listar_presidentes').dataTable({
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
        </script>
