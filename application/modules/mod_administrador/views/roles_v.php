<script type="text/javascript" charset="utf-8">
$(document).ready(function() {   
    ayudas('.','roles','bottom right','top left','fold','up');
 $('.asocia-modulo').hide(); 
 $('#btn-diagperfil').button({
                            icons: 
                                {
                                    primary: "ui-icon-person"
                                },
                            text: false
                        });
 $( "#dialog-perfiles" ).dialog(
                            {
                                modal: true, //inhabilitada pantalla de atras
                                autoOpen: false,
                                draggable: true,
                                width: 380,
                                resizable: false, //evita cambiar tamaño del cuadro del mensaje
                                show: "show", //efecto para abrir cuadro de mensaje
                                hide: "slide", //efecto para cerrar cuadro de mensaje
                                title: "creacion de perfiles"
                                
                            }); 
                            
$( "#dialog_delete" ).dialog(
        {
            modal: true, //inhabilitada pantalla de atras
            autoOpen: false,
            draggable: true,
            width: 350,
            resizable: false, //evita cambiar tamaño del cuadro del mensaje
            show: "show", //efecto para abrir cuadro de mensaje
            hide: "slide", //efecto para cerrar cuadro de mensaje
            title: "Mensaje web-master"
            });
});

cargar_modulos=function(id,nombre,url){
// $("#cart").empty();   
//    alert(nombre+' '+id)
$(".asocia-modulo").hide();
$.ajax({
    type:"post",
    dataType:"json",
    data:{id:id},
    url:url,
    success:function(data){
        if (data.resultado){ 
            
            $("#cart").html('<form id="frmgrupos" style="overflow:auto; height: 190px;" class="ui-widget-content"></form>')
            
            $(".asocia-modulo #modulos").html(data.vista)          
            $( ".perfil").remove()
            $( "<center><div class='perfil ui-widget-header'><label style='margin-right:115px; margin-left:115px'><b>Pefil "+nombre+"</b></label><button txtayuda='Actualizar el perfil' class='ayuda' id='guardamod' style='width:30px;height: 20px;'></button></div></center>" ).appendTo('#cart');
            $( "<center><div style='height: 20px;' class='perfil ui-widget-header'><label><b>Modulos activos en el sistema</b></label></div></center>" ).appendTo('#modulos');
            $("<input id='rol' name='rol' type='hidden'/>" ).val(id).appendTo('#frmgrupos');
            
             $('#guardamod').button({icons:{primary: "ui-icon-refresh"}});
             $('#guardamod').click(function(){inserta_modulos(id,nombre);});
             
                if(data.modulos!=null){
                
                   $.each(data.modulos, function(index, value) {
       //		$("#data").append('<p>index: ' + index + ' value1: ' + data.modulos[index]['padreid']  + ' value2: ' + data.modulos[index]['moduloid'] + '</p>');
//onmouseover=\"javascript:$('.eliminaMod').show();\" onmouseout=\"javascript:$('.eliminaMod').hide();\"
                       if(data.modulos[index]['padreid']==null){
                         $("<div style=' border:solid 0px; margin-bottom:5px; margin-left:-30px'  id='modulo"+data.modulos[index]['moduloid']+"'><input type='hidden' name='modulo[]' value='"+data.modulos[index]['moduloid']+"'/><div style=' width:90%; height:15px; padding:3px 0px 0px 20px' class='ui-widget-header ui-corner-all'>"+data.modulos[index]['nombre']+" <a href=\"javascript:;\" onClick=\"javascript:remueve_modulo('modulo"+data.modulos[index]['moduloid']+"','#');\" style='position: relative; margin-top:-5px; float:right' class='ui-icon ui-icon-trash'></a></div><br /></div>").appendTo("#frmgrupos");  

                       }

                   });

                   $.each(data.modulos, function(index, value) {
      //		$("#data").append('<p>index: ' + index + ' value1: ' + data.modulos[index]['padreid']  + ' value2: ' + data.modulos[index]['moduloid'] + '</p>');
//                      var contador=1;
                      if(data.modulos[index]['padreid']!=null){
                          

                           $( "<label  class='modulo"+data.modulos[index]['moduloid']+"'  style='margin-left:20px;'>*"+data.modulos[index]['nombre']+"</label><a id='a"+data.modulos[index]['moduloid']+"' href=\"javascript:;\" onClick=\"javascript:remueve_modulo('modulo"+data.modulos[index]['moduloid']+"','.',this.id);\" style='position: relative; margin-top:-20px; margin-left:160px' class='eliminaMod ui-icon ui-icon-trash'></a>" ).appendTo('#modulo'+data.modulos[index]['padreid']);
                           $( "<input name='modulo[]' class='modulo"+data.modulos[index]['moduloid']+"'  type='hidden'/><br />" ).val(data.modulos[index]['moduloid']).appendTo('#modulo'+data.modulos[index]['padreid']);
                           $("#modulo"+data.modulos[index]['moduloid']).hide();
//                             contador++;
                        }

                  });
               }else{
               
                $('<ol><li class="placeholder">Arrastre el modulo aqui</li></ol>').appendTo("#frmgrupos");
                
               }
               $(".asocia-modulo").show("clip", 1000);

            }
    }


});

}
                                
cargar_dialog_perfil=function(url,id_div){

//alert(id_div)

$( "#"+id_div ).dialog(
{
    buttons: {  //propiedad de dialogo, agregar botones
        Guardar: function() { 
            //llamado del formulario, en este caso #form_new corresponde al id del form(en los archivos de las vistas)
            $('#form_perfil').submit(); 
        },
        Cancelar: function() { 
            $( this ).dialog( "close" ); 
        }
    }
});

$.ajax({
    type:"post",
    dataType:"json",
    url:url,
    success:function(data){
        if (data.resultado){
            $("#"+id_div).html(data.vista)
            $("#"+id_div).dialog('open')
        }
    }


});

}
envio_form=function(form,url){
                                    
        $.ajax({
            type:"post",
            data: $("#"+form).serialize(),
            dataType:"json",
            url:url,
            success:function(data){
                if (data.resultado){
//                    alert(data.id)
                    $('#dialog-perfiles').dialog('close');
                    $('#muestra_cuerpo_message').load('<?php echo base_url()."index.php/mod_administrador/principal_c?padre=104"; ?>')
                    
                   
                }else{
                    $('#dialog-perfiles').dialog('close');
                    alert('Ya existe un perfil con ese nombre');
                }
            }

        });

    }
 inserta_modulos=function(id,nombre){
 
    var datos=$('#frmgrupos').serialize();
//    alert(datos);
     $.ajax({
            type:"post",
            data:datos,
            dataType:"json",
            url:'<?php echo base_url()."index.php/mod_administrador/roles_c/gestion_perfiles"; ?>',
            success:function(data){
                if (data.resultado){
               alert("perfil actualizado exitosamente");
                    cargar_modulos(id,nombre,"<?php echo base_url().'index.php/mod_administrador/roles_c/carga_modulos'?>");
                 
                }
            }

        });
 
 }
 
dialog_elimina_perfil=function(url,id){
//alert(id)
        $("#dialog_delete").dialog(
        {          
            buttons: {
                "SI": function() {                    
//                    alert(id)
                    $( "#dialog_delete" ).dialog( "close" );
                    $.ajax({
                        type:"post",
                        data:{perfil:id},
                        dataType:"json",
                        url:url,
                        success:function(data){
                            if (data.resultado){
//                               $( this ).dialog('close');
                               $('#muestra_cuerpo_message').load('<?php echo base_url()."index.php/mod_administrador/principal_c?padre=104"; ?>')

                             }
                        }
                    });
                   
                    },

                "NO": function() {
                    $( this ).dialog( "close" );
                    }
                }



    });
    //mnsaje que mostrara en el dialog de alerta o confirmacion
    $( "#dialog_delete" ).html("<h3>Procedera a eliminar el perfil seleccionado. ¿Desea continuar?</h3>")
    $( "#dialog_delete" ).dialog('open')

}
 

    
</script>
<div class="ui-widget-header" style=" text-align:center; font-size: 12px; font-style: italic; margin-bottom: 10px; width: 80%; margin-left: 10%">Listado de los perfiles de usuario existentes en el sistema</div>

<table cellpadding="0" cellspacing="0" border="0" class="display roles" id="listar-perfiles" width="100%">
	<thead>
		<tr>
			<th>#</th>
			<th>Nombre del perfil</th>
                        <th>Descripcion del peril</th>			
                        <th>Opciones</th> 
                </tr>
	</thead>
	<tbody>
           <?
           $baseurl=base_url();
           foreach ($data as $clave => $valor) {
            $con=$clave;
            $v=$valor['nombre'];
                if($valor["nombre"]!='SUPER_ADMINISTRADOR'){
                   echo '<tr >
                            <td>'. $con .'</td>
                            <td>'. $valor["nombre"].'</td>
                            <td>'. $valor["descripcion"].'</td>         

                            <td>

                            <button txtayuda="Eliminar el perfil" class="ayuda" id="eli-'.$valor["id"].'" onclick="dialog_elimina_perfil('."'".$baseurl.'index.php/mod_administrador/roles_c/eliminar_perfil'."'".','.$valor["id"].')" title="Eliminar perfil">

                            </button>
                             <button txtayuda="Editar permisos del perfil" class="ayuda" id="edi-'.$valor["id"].'" onclick="cargar_modulos('.$valor["id"].','."'".$valor["nombre"]."'".','."'".$baseurl.'index.php/mod_administrador/roles_c/carga_modulos'."'".')" title="">

                            </button>
                          </td>
                    </tr>';
               }
           }
           ?>
            <!--<button id="'.$valor["id_usuario"].'" onclick="if(confirma() == false) return false" href="<? //=base_url()?>index.php/mod_administrador/usuarios_c/eliminar_usuario/<?//=this.id?>" title="Eliminar Usuario"></button>-->
                        
            
         </table>
        <table border="0" width="100%" class="roles">
		<tr>
                    <td align="right">

                        <button txtayuda="Crear nuevo perfil del sistema" class="ayuda" id="btn-diagperfil" title="Agregar Nuevo perfil" style="width:30px; height:30px;" onclick="cargar_dialog_perfil('<?php echo base_url().'index.php/mod_administrador/roles_c/cargar_vista';?>','dialog-perfiles');"></button>
                                     
                    </td>
		</tr>
         </table>
    <div id="dialog_delete"> 
            
    </div>
<!-- formularios-->
<div id="dialog-perfiles"> 

</div>

<div class="asocia-modulo">
    <div class="ui-widget-header" style="text-align:center; font-size: 12px; font-style: italic; margin-bottom: 10px; width: 80%; margin-left: 10%">Configuracion de modulos para los perfiles de usuario</div>

    <div id="modulos" style=" margin-bottom: 15px; width: 50%; border: solid 0px; "></div>

    <div id="cart" style=" margin-top:-250px; width: 40%;  border: solid 0px; float: right ">  
        
       
<!--    <form id="frmgrupos" class="ui-widget-content">
        
    </form>-->
    </div>
</div>

        <script>
            
//            script para asignar atributos al listar diseñado con datatables
            oTable = $('#listar-perfiles').dataTable({
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
                                
                                  $( '#listar-perfiles button' ).button({
                                                    icons: {
                                                    primary: "ui-icon-trash"
                                                    },
                                                    text: false
                                                    }).next().button({
                                                    icons: {
                                                    primary: "ui-icon-key"
                                                    }                                           
                                                    
                                                    });
        </script>