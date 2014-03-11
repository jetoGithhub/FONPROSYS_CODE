
<script type="text/javascript" charset="utf-8">

        $(document).ready(function() {
            $('#respuesta_buscar').hide();
            ayudas('.','cuentas_banc','bottom right','top left','fold','up');
            
            $(".btn_reportes").button();
            
            $('#btn_excel').click(function() {
        
					window.location='<?php echo base_url()."index.php/mod_finanzas/cuentas_banc_c/excel_cuentas_banc"?>';
        
			});
            
            $( '#listar_cuentas_banc button' ).button({
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
                            $( "#frm_cuentas_banc" ).dialog(
                            {
                                modal: true, //inhabilitada pantalla de atras
                                autoOpen: false,
//                                width: 380,
                                draggable: true,
                                resizable: false, //evita cambiar tamaño del cuadro del mensaje
                                show: "show", //efecto para abrir cuadro de mensaje
                                hide: "slide", //efecto para cerrar cuadro de mensaje
                                title: "Cuentas Bancarias"
                                
                            });


        });
                    

//                    //funcion para cargar la vista con el formulario de agregar nuevo cuentas bancarias
                    cargar_vista_dialog_cuentasbanc=function(url,ident,id_div){
//                       
//                        //si encuentra lleno el parametro id_div le agregara al formulario los botones de guardar y cancelar
                        $("#"+id_div).dialog(
                        {
                         //carga el div con el formulario para agregar nuevos intereses bcv, haciendo submit al form
                            
                            buttons: {
                                Guardar:function(){
                                    $('#form_new_cuentasbanc').submit();
                                },
                                Cancelar:function(){
                                    $( this ).dialog("close");
                                }
                               
                            }
                        });
                       
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
                    }


                    envio_form_cuentasbanc=function(form,url){
                                    
                        $.ajax({
                            type:"post",
                            data: $("#"+form).serialize(),
                            dataType:"json",
                            url:url,
                            success:function(data){
                                if (data.resultado){
                                    $('#frm_cuentas_banc').dialog('close')
//                                    alert('La información fue registrada exitosamente')
//                                    $('#muestra_cuerpo_message').load('<?php // echo base_url()."index.php/mod_administrador/principal_c?padre=182"; ?>')
                                    //alert(data.mensaje)
                                    $('#tabs').tabs('load',0);
                                } else
                                {
                                    $('#frm_cuentas_banc').dialog('close');
                                    $("#respuesta_buscar").html("<p>"+data.mensaje+"</p>");
                                    $("#respuesta_buscar").show('slide',{ direction: "up" },500);
									
                                }
                            },
                            error: function (request, status, error) {
                              $('#frm_cuentas_banc').dialog('close')
                              var html='<p style=" margin-top: 15px">';
                                  html+='<span class="ui-icon ui-icon-alert" style="float: left; margin: 0 7px 50px 0;"></span>';
                                  html+='Disculpe ocurrio un error de conexion intente de nuevo. Verifique que no este Registrando una cuenta Repetida <br /> <b>ERROR:"'+error+'"</b>';
                                  html+='</p><br />';
                                  html+='<center><p>';
                                  html+='<b>Si el error persiste comuniquese al correo soporte@cnac.gob.ve</b>';
                                  html+='</p></center>';
                               $("#dialogo-error-conexion").html(html);
                               $("#dialogo-error-conexion").dialog('open');
                           }

                        });

                    }

                                //mensaje deconfirmacion al hacer clic en el boton eliminar
              cargar_alert_dialog=function(url,id,ident,id_div){

                         $( "#frm_cuentas_banc" ).dialog(
                         {
                             modal: true, //inhabilitada pantalla de atras
                             autoOpen: false,
                             draggable: true,
                             width: 350,
                             resizable: false, //evita cambiar tamaño del cuadro del mensaje
                             show: "show", //efecto para abrir cuadro de mensaje
                             hide: "slide", //efecto para cerrar cuadro de mensaje
                             title: "Cuentas Bancarias",
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
//                                                 alert('La información fue eliminada exitosamente')
//                                                 $('#muestra_cuerpo_message').load('<?php // echo base_url()."index.php/mod_administrador/principal_c?padre=182"; ?>')
                                                    $('#tabs').tabs('load',0);
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
                     $( "#frm_cuentas_banc" ).html('<h3>Procedera a eliminar la Cuenta Bancaria. ¿Desea continuar?</h3>')
                     $( "#frm_cuentas_banc" ).dialog('open')

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


<div class="ui-widget-header" style="text-align:center; font-size: 12px; font-style: italic; margin-bottom: 10px; width: 80%; margin-left: 10%">Listado de Cuentas Bancarias</div>
<table cellpadding="0" cellspacing="0" border="0" class="display cuentas_banc" id="listar_cuentas_banc" width="100%">
	<thead>
		<tr>
			<th>#</th>
			<th>Número</th>
            <th>Tipo</th>
			<th>Banco</th>
            <th>Opciones</th> 
         </tr>
	</thead>
	<tbody>
           <?
           $baseurl=base_url();
           foreach ($data as $clave => $valor) {
            $con=$clave+1;
            $v=$valor['id_cuentabanc'];
               echo '<tr >
                        <td>'. $con .'</td>    
						<td>'. $valor["num_cuenta"].'</td>
						<td>'. $valor["tipo_cuenta"].'</td>
						<td>'. $valor["nombre_banco"].'</td>
                        <td>
                            <button txtayuda="Eliminar Cuenta Bancaria" class="ayuda" id="b'.$valor["id_cuentabanc"].'" onclick="cargar_alert_dialog('."'".$baseurl.'index.php/mod_finanzas/cuentas_banc_c/eliminar_cuentasbanc'."'".','.$valor["id_cuentabanc"].',1,'."'frm_cuentas_banc'".')" title="Eliminar Cuentas Bancarias"></button>
                        </td>
                           
                </tr>';
           }
           ?>
  
         </table>
        
         <table border="0" width="100%" class="cuentas_banc">
                <tr>
                    <td align="right">
                        <button txtayuda="Ingresar nueva Cuenta Bancaria" class="ayuda" id="boton_enviar" title="Agregar Nueva Cuenta Bancaria" style="width:30px; height:30px;" onclick="cargar_vista_dialog_cuentasbanc('<?php echo base_url().'index.php/mod_finanzas/cuentas_banc_c/cargar_dialog_new_cuentasbanc';?>',5,'frm_cuentas_banc');"></button>
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
            <div id="frm_cuentas_banc"> 

            </div>
            <div id="respuesta_buscar" class="ui-state-error ui-corner-all" style=" width: 200px; height: auto; text-align: center; margin-top: 2%" >
				<!--div donde se mostrara el mensaje de alerta al seleccionar una opcion invalida en la busqueda-->
	    </div>

         <script>
//            script para asignar atributos al listar diseñado con datatables
            oTable = $('#listar_cuentas_banc').dataTable({
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
