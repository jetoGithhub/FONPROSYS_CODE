

<script type="text/javascript" charset="utf-8">

function abrir(URL) { 
    window.open(URL,"ventana1","width=990,height=600,scrollbars=yes,left=10px,top=10px")
 }

//dialogo que muestra el formulario - vistas
$(function(){

       ayudas('.','usuario','bottom right','top left','fold','up');

        $( '#listar button' ).button({
                            icons: {
                            primary: "ui-icon-copy"
                            },
                            text: false
                            }).next().button({
                            icons: {
                            primary: "ui-icon-trash"
                            }
                            }).next().button({
                            icons: {
                            primary: "ui-icon-key"

                            }

        });

$( "#frm_nvousuario" ).dialog(
    {
        modal: true, //inhabilitada pantalla de atras
        autoOpen: false,
//        width:500,
        draggable: false,
        resizable: false, //evita cambiar tamaño del cuadro del mensaje
        show: "clip", //efecto para abrir cuadro de mensaje
        hide: "clip", //efecto para cerrar cuadro de mensaje
        title: "Creacion de Usuarios"

    });


    //id del div donde se mostrara el formulario
    $( "#frm_usuario" ).dialog(
    {
        modal: true, //inhabilitada pantalla de atras
        autoOpen: false,
//        width:500,
        draggable: false,
        resizable: false, //evita cambiar tamaño del cuadro del mensaje
        show: "clip", //efecto para abrir cuadro de mensaje
        hide: "clip", //efecto para cerrar cuadro de mensaje
        title: "Gestion de Usuarios"

    });

    // atributos del boton enviar
    $('#boton_enviar').button(
        {
            icons: 
                {
                    primary: "ui-icon-person"
                },
            text: false
        });


});
//fuera del document las funciones manuales
//mensaje deconfirmacion al hacer clic en el boton eliminar
cargar_alert_dialog=function(url,id,ident,id_div){

        $( "#frm_usuario" ).dialog(
        {                                           
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
                                alert('La información fue eliminada exitosamente')
                                $('#muestra_cuerpo_message').load('<?php echo base_url()."index.php/mod_administrador/principal_c?padre=6"; ?>')

                             }
                        }
                    });

                    },

                "NO": function() {
                    $( this ).dialog( "close" );
                    }
                }
//                                                 .dialog("option", {title: "Mensaje Del Sistema"})


    });
    //mensaje que mostrara en el dialog de alerta o confirmacion
    $( "#frm_usuario" ).html('<h3>Procedera a eliminar el Usuario. ¿Desea continuar?</h3>')
    $( "#frm_usuario" ).dialog('open')

}


//mensaje deconfirmacion al hacer clic en el boton restablecer contraseña
cargar_alert_restablecer=function(url,id,ident,cedula){
//alert(cedula)
        
        $( "#frm_usuario" ).dialog(
        {
           
            buttons: {
                "SI": function() {
                    $( this ).dialog( "close" );
                    $.ajax({
                        type:"post",
                        data:{ id:id,identificador:ident,valorc:cedula },
                        dataType:"json",
                        url:url,
                        success:function(data){
                            if (data.resultado){
                                alert('La contraseña fue restablecida correctamente')
                                $('#muestra_cuerpo_message').load('<?php echo base_url()."index.php/mod_administrador/principal_c?padre=6"; ?>')

                             }
                        }
                    });

                    },

                "NO": function() {
                    $( this ).dialog( "close" );
                    }
                }
//                                                 .dialog("option", {title: "Mensaje Del Sistema"})


    });
    //mensaje que mostrara en el dialog de alerta o confirmacion
    $( "#frm_usuario" ).html('<h3>Procedera a reestablecer la contraseña del Usuario. ¿Desea continuar?</h3>');
    $( "#frm_usuario" ).dialog('open');

};



//Funcion generica para cargar las vistas - Controlador -> Vista
//Parametros->
//url: apunta al metodo del controlador que carga las vistas
//id: identificador de la tabla - en el caso de requerir paso de parametros a la vista
//ident: identifica el boton seleccionado para establecer condiciones que indicaran cual vista se mostrara
//id_div: nombre del id del div en el cual se incluira la vista

cargar_vista_dialog_usuario=function(url,id,ident,id_div){

//alert(id_div)

    $( "#"+id_div ).dialog(
    {
        width:500,
        buttons: {  //propiedad de dialogo, agregar botones
            Guardar: function() { 
                //llamado del formulario, en este caso #form_new corresponde al id del form(en los archivos de las vistas)
                $('#form_new').submit(); 
            },
            Cancelar: function() { 
                $( this ).dialog( "close" ); 
            }
        }
    });

    $.ajax({
        type:"post",
        data:{ id:id,identificador:ident },
        dataType:"json",
        url:url,
        success:function(data){
            if (data.resultado){
                $("#"+id_div).html(data.vista)
                $("#"+id_div).dialog('open')
            }
        }


    });

};

//funcion para mostrar el dialogo de ver detalle de usuarios, solo con el botón cancelar
cargar_vista_ver_usuario=function(url,id,ident,id_div){

//alert(id_div)

    $( "#"+id_div ).dialog(
    {
        buttons: {
            Guardar: function() { 
                //llamado del formulario, en este caso #form_new corresponde al id del form(en los archivos de las vistas)
                $('#form_editusu').submit();
            },
            Cancelar: function() { 
                $( this ).dialog( "close" ); 
            }
        }
    });

    $.ajax({
        type:"post",
        data:{ id:id,identificador:ident },
        dataType:"json",
        url:url,
        success:function(data){
            if (data.resultado){
                $("#"+id_div).html(data.vista)
                $("#"+id_div).dialog('open')
            }
        }


    });

};

//  funcion para cargar el Controlador y ejecutar el proceso correspopndiente
//recarga la pagina del listar usuario una vez que se realizan los distintos procesos(eliminar, editar...)
envio_form=function(form,url){

    $.ajax({
        type:"post",
        data: $("#"+form).serialize(),
        dataType:"json",
        url:url,
        success:function(data){
            if (data.resultado){
                $('#frm_usuario').dialog('close');
                $('#frm_nvousuario').dialog('close');
                $('#muestra_cuerpo_message').load('<?php echo base_url()."index.php/mod_administrador/principal_c?padre=6"; ?>')
                //alert(data.mensaje)
            }else{
                if(data.gerente_exis){

                    $('#msj-usuario').html('<p style="font-family: sans-serif; color:#000"><span style="float: left; margin-right: .3em;"  class="ui-icon ui-icon-info"></span><strong>Alerta: </strong>Disculpe ya existe un gerente para esta oficina.</p>')
                    $("#msj-usuario").addClass('ui-state-highlight ui-corner-all');
                    $("#msj-usuario").css({background:'#FAF9EE',border:'1px solid #FCF0A8',"margin-top":" 30px"});
                }

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
                    td#botonera-usu button{
                        /*width: 25px;
                        height: 25px*/

                    }

                </style>



<table cellpadding="0" cellspacing="0" border="0" class="display usuario" id="listar" width="100%">
	<thead>
		<tr>
			<th>#</th>
			<th>Nombre y Apellido</th>
                        <!--<th>Cedula de Identidad</th>-->
			<th>Gerencia</th>
			<th>Cargo</th>
                        <th>Estado</th>
                        <th>Opciones</th> 
                </tr>
	</thead>
	<tbody>
           <?
           $baseurl=base_url();
           foreach ($data as $clave => $valor) {
            $con=$clave+1;
            $v=$valor['nombre'];
            ($valor["estatus"]=='f'? $estado='ACTIVO' : $estado='INACTIVO');
            $partes=explode('-', $valor['cedula']);
            $cedula_limpia=$partes[1];
               echo '<tr >
                        <td>'. $con .'</td>
			<td>'. $valor["nombre"].'</td>';
//                        <td>'. $valor["cedula"].'</td>
			echo '<td>'. $valor["gerencia"].'</td>
			<td>'. $valor["cargo"].'</td>
                        <td>'.$estado.'</td>
                           
                            
                        <td id="botonera-usu">
                        <button txtayuda="Edicion de usuario" class="ayuda" id="a'.$valor["id_usuario"].'" onclick="cargar_vista_ver_usuario('."'".$baseurl.'index.php/mod_administrador/usuarios_c/cargar_vista'."'".','.$valor["id_usuario"].',1,'."'frm_usuario'".')" title="Gestión Usuario">
                        </button>
                        <button txtayuda="Eliminar usuario" class="ayuda" id="b'.$valor["id_usuario"].'" onclick="cargar_alert_dialog('."'".$baseurl.'index.php/mod_administrador/usuarios_c/eliminar_usuario'."'".','.$valor["id_usuario"].',1,'."'frm_usuario'".')" title="Eliminar Usuario">
                        
                        </button>
                        
                        <button txtayuda="Restablecer usuario" class="ayuda" id="c'.$valor["id_usuario"].'" onclick="cargar_alert_restablecer('."'".$baseurl.'index.php/mod_administrador/usuarios_c/restablecer_contras_usuario'."'".','.$valor["id_usuario"].',1,'. $cedula_limpia.')" title="Restablecer Contraseña">
                        
                        </button></td>
                </tr>';
           }
           ?>
            <!--<button id="'.$valor["id_usuario"].'" onclick="if(confirma() == false) return false" href="<? //=base_url()?>index.php/mod_administrador/usuarios_c/eliminar_usuario/<?//=this.id?>" title="Eliminar Usuario"></button>-->
                        
            
         </table>
         
            <table border="0" width="100%" class="usuario">
		<tr>
                    <td align="right">
<!--                        En el onclick recibe el paso de los parametros de la funcion ajax
                        onclick="nom_funcion_ajax('url_metodo'),this.variableId,identificador_boton,id_divParaLaVista"-->
                        <button txtayuda="Crear nuevo usuario" class="ayuda" id="boton_enviar" title="Agregar Nuevo Usuario" style="width:30px; height:30px;" onclick="cargar_vista_dialog_usuario('<?php echo base_url().'index.php/mod_administrador/usuarios_c/cargar_vista';?>',this.id,5,'frm_nvousuario');"></button>
<!--                        <span class="btn1"><a href="javascript:abrir('<?php // echo base_url().'application/modules/mod_administrador/views/imp_planilla_cont_resp_v.php';?>')" target="_self" class="enlaces_2">Imprimir Planilla</a></span>
              -->
                    </td>
		</tr>
            </table>
<!-- formularios-->
            <div id="frm_usuario"> 
            
            </div>
            <div id="frm_nvousuario"> 
            
            </div>
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
        </script>
	
