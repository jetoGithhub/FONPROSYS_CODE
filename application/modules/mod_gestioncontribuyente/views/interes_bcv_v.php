
<script type="text/javascript" charset="utf-8">

        $(document).ready(function() {

            ayudas('.','interes_bcv','bottom right','top left','fold','up');
            
            $(".btn_reportes").button();
            
            $('#btn_excel').click(function() {
        
					window.location='<?php echo base_url()."index.php/mod_gestioncontribuyente/interes_bcv_c/excel_interes_bcv"?>';
        
			});
            
            $( '#listar_interes_bcv button' ).button({
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
                            $( "#frm_interes_bcv" ).dialog(
                            {
                                modal: true, //inhabilitada pantalla de atras
                                autoOpen: false,
                                width: 380,
                                draggable: true,
                                resizable: false, //evita cambiar tamaño del cuadro del mensaje
                                show: "show", //efecto para abrir cuadro de mensaje
                                hide: "slide", //efecto para cerrar cuadro de mensaje
                                title: "Interes BCV"
                                
                            });


        });
                    
////                    //funcion para cargar la vista con el formulario de agregar nuevo interes bcv
//                    //funcion para cargar la vista con el formulario de agregar nuevo interes bcv
                    cargar_vista_dialog_interesbcv=function(url,ident,id_div){
//                       
//                        //si encuentra lleno el parametro id_div le agregara al formulario los botones de guardar y cancelar
                        $("#"+id_div).dialog(
                        {
                         //carga el div con el formulario para agregar nuevos intereses bcv, haciendo submit al form
                            
                            buttons: {
                                Guardar:function(){
                                    $('#form_new_intbcv').submit();
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
                                   
                            }
                           
                        });
                    }


                    envio_form_intbcv=function(form,url){
                                    
                        $.ajax({
                            type:"post",
                            data: $("#"+form).serialize(),
                            dataType:"json",
                            url:url,
                            success:function(data){
                                if (data.resultado){
                                    $('#frm_interes_bcv').dialog('close')
                                    alert('La información fue registrada exitosamente')
                                    $('#muestra_cuerpo_message').load('<?php echo base_url()."index.php/mod_administrador/principal_c?padre=168"; ?>')
                                    //alert(data.mensaje)
                                }
                            }

                        });

                    }

                                //mensaje deconfirmacion al hacer clic en el boton eliminar
              cargar_alert_dialog=function(url,id,ident,id_div){

                         $( "#frm_interes_bcv" ).dialog(
                         {
                             modal: true, //inhabilitada pantalla de atras
                             autoOpen: false,
                             draggable: true,
                             width: 350,
                             resizable: false, //evita cambiar tamaño del cuadro del mensaje
                             show: "show", //efecto para abrir cuadro de mensaje
                             hide: "slide", //efecto para cerrar cuadro de mensaje
                             title: "Interes BCV",
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
                                                 $('#muestra_cuerpo_message').load('<?php echo base_url()."index.php/mod_administrador/principal_c?padre=168"; ?>')

                                              }
                                         }
                                     });

                                     },

                                 "NO": function() {
                                     $( this ).dialog( "close" );
                                     }
                                 }
                     });
                     //mensaje que mostrara en el dialog de alerta o confirmacion
                     $( "#frm_interes_bcv" ).html('<h3>Procedera a eliminar el Interes BCV. ¿Desea continuar?</h3>')
                     $( "#frm_interes_bcv" ).dialog('open')

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

          <!--condicion para que no se muestren los botones de excel y pdf en el caso de no existir data-->
 <?php if (!empty($data)){?>        
		<!-- botones generar excel y pdf -->
		<div class="botonera_reportes" style="float: right">
			<button id="btn_excel" class="btn_reportes">
				<img src="<? echo base_url().'include/imagenes/iconos/ic_excel.png'?>" width="14px" height="12px"/>
				<b>Excel</b>
			</button>
		</div>
<? } ?>
        <p>&nbsp;</p>


<table cellpadding="0" cellspacing="0" border="0" class="display interes_bcv" id="listar_interes_bcv" width="100%">
	<thead>
		<tr>
			<th>#</th>
			<th>Mes</th>
                        <th>Año</th>
			<th>Tasa</th>
                        <th>Opciones</th> 
                </tr>
	</thead>
	<tbody>
           <?
           $baseurl=base_url();
           foreach ($data as $clave => $valor) {
            $con=$clave+1;
            $v=$valor['mes'];
               echo '<tr >
                        <td>'. $con .'</td>    
			<td>'. $valor["mes"].'</td>
                        <td>'. $valor["anio"].'</td>
			<td>'. $valor["tasa"].'</td>
                        <td>
                            <button txtayuda="Eliminar Interes BCV" class="ayuda" id="b'.$valor["id_interesbcv"].'" onclick="cargar_alert_dialog('."'".$baseurl.'index.php/mod_gestioncontribuyente/interes_bcv_c/eliminar_interesbcv'."'".','.$valor["id_interesbcv"].',1,'."'frm_interes_bcv'".')" title="Eliminar Interese BCV"></button>
                        </td>
                           
                </tr>';
           }
           ?>
  
         </table>
        
         <table border="0" width="100%" class="interes_bcv">
                <tr>
                    <td align="right">
                        <button txtayuda="Ingresar nuevo Interes BCV" class="ayuda" id="boton_enviar" title="Agregar Nuevo Interes BCV" style="width:30px; height:30px;" onclick="cargar_vista_dialog_interesbcv('<?php echo base_url().'index.php/mod_gestioncontribuyente/interes_bcv_c/cargar_dialog_new_interesbcv';?>',5,'frm_interes_bcv');"></button>
                    </td>
		</tr>
        </table>
<!-- formularios-->
            <div id="frm_interes_bcv"> 

            </div>


         <script>
//            script para asignar atributos al listar diseñado con datatables
            oTable = $('#listar_interes_bcv').dataTable({
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
