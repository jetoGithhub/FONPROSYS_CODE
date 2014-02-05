
<script type="text/javascript" charset="utf-8">

        $(document).ready(function() {

            ayudas('.','und_tributarias','bottom right','top left','fold','up');
            
            $(".btn_reportes").button();
            
            $('#btn_excel').click(function() {
        
					window.location='<?php echo base_url()."index.php/mod_finanzas/und_tributarias_c/excel_und_tributarias"?>';
        
			});
            
            $( '#listar_und_tributarias button' ).button({
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
                            $( "#frm_und_tributarias" ).dialog(
                            {
                                modal: true, //inhabilitada pantalla de atras
                                autoOpen: false,
//                                width: 380,
                                draggable: true,
                                resizable: false, //evita cambiar tamaño del cuadro del mensaje
                                show: "show", //efecto para abrir cuadro de mensaje
                                hide: "slide", //efecto para cerrar cuadro de mensaje
                                title: "Unidades Tributarias"
                                
                            });


        });

//                    //funcion para cargar la vista con el formulario de agregar nuevas unidades tributarias
                    cargar_vista_dialog_undtributarias=function(url,ident,id_div){
//                       
//                        //si encuentra lleno el parametro id_div le agregara al formulario los botones de guardar y cancelar
                        $("#"+id_div).dialog(
                        {
                         //carga el div con el formulario para agregar nuevos und tributarias, haciendo submit al form
                            
                            buttons: {
                                Guardar:function(){
                                    $('#form_new_undtrib').submit();
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
                    };


                    envio_form_undtributarias=function(form,url){
                                    
                        $.ajax({
                            type:"post",
                            data: $("#"+form).serialize(),
                            dataType:"json",
                            url:url,
                            success:function(data){
                                if (data.resultado){
                                    $('#frm_und_tributarias').dialog('close');
                                    $('#tabs').tabs('load',0);
//                                    alert('La información fue registrada exitosamente')
//                                    $('#muestra_cuerpo_message').load('<?php // echo base_url()."index.php/mod_administrador/principal_c?padre=178"; ?>')
                                    //alert(data.mensaje)
                                }
                            },
                            error: function (request, status, error) {
                              $('#frm_und_tributarias').dialog('close');
                              var html='<p style=" margin-top: 15px">';
                                  html+='<span class="ui-icon ui-icon-alert" style="float: left; margin: 0 7px 50px 0;"></span>';
                                  html+='Disculpe ocurrio un error de conexion o el año que esta registrando ya existe. <br /> <b>ERROR:"'+error+'"</b>';
                                  html+='</p><br />';
                                  html+='<center><p>';
                                  html+='<b>Si el error persiste comuniquese al correo soporte@cnac.gob.ve</b>';
                                  html+='</p></center>';
                               $("#dialogo-error-conexion").html(html);
                               $("#dialogo-error-conexion").dialog('open');
                           }

                        });

                    };

                                //mensaje deconfirmacion al hacer clic en el boton eliminar
              cargar_alert_dialog=function(url,id,ident,id_div){

                         $( "#frm_und_tributarias" ).dialog(
                         {
                             modal: true, //inhabilitada pantalla de atras
                             autoOpen: false,
                             draggable: true,
                             width: 350,
                             resizable: false, //evita cambiar tamaño del cuadro del mensaje
                             show: "show", //efecto para abrir cuadro de mensaje
                             hide: "slide", //efecto para cerrar cuadro de mensaje
                             title: "Unidades Tributarias",
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
                                                  
                                                  $('#tabs').tabs('load',0);
//                                                 alert('La información fue eliminada exitosamente')
//                                                 $('#muestra_cuerpo_message').load('<?php // echo base_url()."index.php/mod_administrador/principal_c?padre=178"; ?>')

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
                     $( "#frm_und_tributarias" ).html('<h3>Procedera a eliminar la Unidad Tributaria. ¿Desea continuar?</h3>')
                     $( "#frm_und_tributarias" ).dialog('open')

                 };
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

<div class="ui-widget-header" style="text-align:center; font-size: 12px; font-style: italic; margin-bottom: 10px; width: 80%; margin-left: 10%">Listado de Unidades Tributarias</div>
<table cellpadding="0" cellspacing="0" border="0" class="display und_tributarias" id="listar_und_tributarias" width="100%">
	<thead>
		<tr>
			<th>#</th>
			<th>Valor</th>
            <th>Año</th>
            <th>Opciones</th> 
        </tr>
	</thead>
	<tbody>
           <?
           $baseurl=base_url();
           foreach ($data as $clave => $valor) {
            $con=$clave+1;
            $v=$valor['id_undtrib'];
               echo '<tr >
                        <td>'. $con .'</td>    
                        <td>'. $valor["valor"].'</td>
                        <td>'. $valor["anio"].'</td>
                        <td>
                            <button txtayuda="Eliminar Unidad Tributaria" class="ayuda" id="b'.$valor["id_undtrib"].'" onclick="cargar_alert_dialog('."'".$baseurl.'index.php/mod_finanzas/und_tributarias_c/eliminar_undtributarias'."'".','.$valor["id_undtrib"].',1,'."'frm_und_tributarias'".')" title="Eliminar Unidad Tributaria"></button>
                        </td>
                           
                    </tr>';
           }
           ?>
  
         </table>
        
         <table border="0" width="100%" class="und_tributarias">
                <tr>
                    <td align="right">
                        <button txtayuda="Ingresar nueva Unidad Tributaria" class="ayuda" id="boton_enviar" title="Agregar Nueva Unidad Tributaria" style="width:30px; height:30px;" onclick="cargar_vista_dialog_undtributarias('<?php echo base_url().'index.php/mod_finanzas/und_tributarias_c/cargar_dialog_new_undtributarias';?>',5,'frm_und_tributarias');"></button>
                       <?php if (!empty($data)){?>        
		<!-- botones generar excel y pdf -->
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
            <div id="frm_und_tributarias"> 

            </div>


         <script>
//            script para asignar atributos al listar diseñado con datatables
            oTable = $('#listar_und_tributarias').dataTable({
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
