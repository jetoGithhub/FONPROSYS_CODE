
<?php
//print_r($inspeccionid);
//echo $conusuid;
//$data=array();
?>

<html>
<script type="text/javascript" charset="utf-8">
                
 $(function() {
     
//     $("#prueba-show").hide();
     $("#memsajerror").hide();
     $( "#dialog_pcancelados_confirmacion" ).dialog(
        {
            modal: true, //inhabilitada pantalla de atras
            autoOpen: false,
            draggable: true,
            resizable: false, //evita cambiar tamaño del cuadro del mensaje
            show: "show", //efecto para abrir cuadro de mensaje
            hide: "slide", //efecto para cerrar cuadro de mensaje
            title: "Mensaje web-master"
        });

        $('#dialog-cargapcancelados').dialog({

            modal: true, //inhabilitada pantalla de atras
            autoOpen: false,
            draggable: false,
            resizable: false, //evita cambiar tamaño del cuadro del mensaje
            show: "clip", //efecto para abrir cuadro de mensaje
            hide: "clip", //efecto para cerrar cuadro de mensaje
            title: "detalles del reparo",
            buttons: {  //propiedad de dialogo, agregar botones
                Guardar: function() { 
                        //llamado del formulario, en este caso #form_new corresponde al id del form(en los archivos de las vistas)
                        $('#form_carga_pcancelados').submit(); 
                    }
//                    ,
//                Cancelar: function() { 
//                        $( this ).dialog( "close" ); 
//                }

            }
        });


 });
 
 
cargar_dialog_cargapcancelados=function(url,id,asignaid,conusuid,ident,id_div){

//    alert(id_div);
    $.ajax({
        type:"post",
        data:{ id:id,identificador:ident,idasig:asignaid,conusuid:conusuid },
        dataType:"json",
        url:url,
        success:function(data){
//             alert(data.vista);
            if (data.resultado){
                
                $("#"+id_div).html(data.vista);              
                
                $("#"+id_div).dialog('open');
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
                 
</script>  
    <style>
        .tp input, textArea{ width: 100%}
        #carga-cargapcancelados{ width: 100%}
        .tp td{  border-color: #E9E9E9; }
        
        
        </style>
        
        <div id="dialog_pcancelados_confirmacion"></div>
        <div class="ui-widget-header" style="text-align:center; font-size: 12px; font-style: italic; margin-bottom: 20px; width: 80%; margin-left:10%; ">Informacion del contribuyente</div>
<div id="prueba-show">
<center>
    <div id="carga-cargapcancelados " class="ui-widget-content ui-corner-all tp">
     <table id="tablatext " style="width: 100%; padding: 10px; border-collapse: collapse; border-color: #F8F7F6" border="1" >
                <tr >
                <td colspan="" style=" width: 30%" ><strong>N&deg; RCN</strong></td>                
                <td colspan="" style=" width: 30%" ><strong>Actividad economica</strong></td>
                <td colspan="" style=" width: 40%" ><strong>Razon Social</strong></td>
                
                </tr>
                <tr  >
                        
                        <td ><?php echo $numregcine ?></td>                        
                        <td ><?php echo $actividad ?></td>
                        <td ><?php echo $nombre?></td>
                        
                </tr>
                <tr >
                
                <td colspan="" style=""   ><strong>Estado</strong></td>
                <td colspan=""><strong>Ciudad</strong></td>
                 <td colspan=""><strong>Tipo de contribuyente</strong></td>
                </tr>
                   <tr >
                        
                       
                        <td colspan=""><?php echo $estado  ?></td>
                        <td colspan=""><?php echo $ciudad  ?></td>
                        <td colspan=""><?php echo $tcontribuyente  ?></td>
                </tr>
                <tr >
                <td colspan=""><strong>Telefono</strong></td>
                <td colspan=""><strong>Correo electronico</strong></td>
                <td colspan=""><strong>Fax</strong></td>
             </tr>
             
                <tr >
                        <td colspan=""><?php echo $telef1 ?></td>
                         <td colspan=""><?php echo $email ?></td>  
                         <td colspan=""><?php echo $fax ?></td>
                </tr>
                <tr >
                     <td colspan="3"><strong>Domicilio fizcal</strong></td>
                </tr>
                <tr >             
                 <td colspan="3"><p><?php echo $domfiscal ?></p></td>

                </tr>
              
            </table>
    </div></center>
        
<div class="ui-widget-header" style="text-align:center; font-size: 12px; font-style: italic; margin-bottom: 20px; width: 80%; margin-left:10%; margin-top: 20px ">Detalles de los periodos liquidados encontrados en la auditoria </div>
<table cellpadding="0" cellspacing="0" border="0" class="display" id="listar-cargapcancelados" width="100%">
	
    <thead>
		<tr>
			<th>#</th>
			<th>periodo gravable</th>
                        <?php if($tipo!=2){ ?><th>anio</th><?php } ?>	
                        <th>base imponible</th>
                        <th>alicuota impositiva</th>
                        <th>total</th>                        
                        <th>Operaciones</th>
                </tr>
	</thead>
	<tbody>
           <?
        if(!empty($detalles)):   
           $baseurl=base_url();
           foreach ($detalles as $clave => $valor) {
            $con=$clave+1;
//            $v=$valor['nombre'];
            if($tipo!=2):
               echo '<tr>
                        <td>'. $con .'</td>';
                        if($tipo==0):
                            echo'<td>'.$this->funciones_complemento->devuelve_meses_text($valor["periodo"],1).'</td>';
                        endif;
			 if($tipo==1):
                        echo'<td>'. $this->funciones_complemento->devuelve_trimestre_text($valor["periodo"],1).'</td>';
                        endif;
                        echo '<td>'. $valor["anio"].'</td>
                        <td>'. $this->funciones_complemento->devuelve_cifras_unidades_mil($valor["base"]).'</td>
                        <td>'. $valor["alicuota"].'</td>
                        <td>'. $this->funciones_complemento->devuelve_cifras_unidades_mil($valor["total"]).'</td>                    
			
                        
                       <td> <button class="eliminadetallepcancelados" id="'.$valor["id"].":".$valor["calpagodid"].":".$valor["conusuid"].'" style=" width: 30px; height: 25px;"  title=""></button></td>    
                         
                    </tr>';
            else:
                echo '<tr>
                        <td>'. $con .'</td>
			<td>'. $valor["periodo"].'</td>                       
                        <td>'. $this->funciones_complemento->devuelve_cifras_unidades_mil($valor["base"]).'</td>
                        <td>'. $valor["alicuota"].'</td>
                        <td>'. $this->funciones_complemento->devuelve_cifras_unidades_mil($valor["total"]).'</td>                    
			
                        
                       <td> <button class="eliminadetallepcancelados" id="'.$valor["id"].":".$valor["calpagodid"].":".$valor["conusuid"].'" style=" width: 30px; height: 25px;"  title=""></button></td>    
                </tr>';
                
            endif;
//                       
           }
           endif;
           ?>
            <!--<button id="'.$valor["id_usuario"].'" onclick="if(confirma() == false) return false" href="<? //=base_url()?>index.php/mod_administrador/usuarios_c/eliminar_usuario/<?//=this.id?>" title="Eliminar Usuario"></button>-->
                        
           </tbody> 
         </table>
        <table id="botoneria-cargar-pcancelados" style=" width: 100%; border: 0px solid">
             <tr>                 
                   <td><button style=" height: 25px; margin-top: 10px" class="btnvolver" id="btnvolver"  title="">volver</button></td>
                   <button style="  height: 25px; margin-top: 10px; float: right" class="btndialos-detpcancelados" id="btndialos-detpcancelados"  title="">periodo</button></td>
            </tr>
        </table>

<div id="dialog-cargapcancelados"></div>
<div style="padding: 0 .7em; width: 400px; margin-top: 15px; margin-left:30%; margin-bottom: 10px" class="ui-corner-all" id="memsajerror">
		
 </div>

</div>
<script>


$( '#btnvolver' ).button({
                icons: {
                primary: "ui-icon-arrowthick-1-w"
                }

});

$( '#btndialos-detpcancelados' ).button({
                        icons: {
                        primary: "ui-icon-plusthick"
                        }                                          

});



$( '.eliminadetallepcancelados' ).button({
                    icons: {
                    primary: "ui-icon-trash"
                    }                                           

});

$('.btnvolver').click(function(){  
//                               alert(this.id)
    $('#a0').attr('href','<?php echo base_url()."index.php/mod_gestioncontribuyente/fiscalizacion_c"?>'); 
    $('#a0').text('asignaciones');
    $("#tabs").tabs("load",0);    

}); 

$('.btndialos-detpcancelados').click(function(){  
//                                  url,id,ident,id_div
    cargar_dialog_cargapcancelados('<?php echo base_url()."index.php/mod_gestioncontribuyente/fiscalizacion_c/muestra_dialog_cragafis"?>','<?php echo $idcontribu?>','<?php echo $inspeccionid?>','<?php echo $conusuid?>',3,'dialog-cargapcancelados');

});

$('.eliminadetallepcancelados').click(function(){
//  alert(this.id)
     $.ajax({
        type:"post",
        data:{ id:this.id},
        dataType:"json",
        url:'<?php echo base_url()."index.php/mod_gestioncontribuyente/fiscalizacion_c/elimina_carga_periodo_cancelado"?>',
        success:function(data){
//             alert(data.vista);
            if (data.resultado){

                var current_index = $("#tabs").tabs("option","selected");             
                $("#tabs").tabs("load",current_index);  

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

});
//            script para asignar atributos al listar diseñado con datatables
oTable = $('#listar-cargapcancelados').dataTable({
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

 
  
//        $(document).ready(function() {
//            $("#prueba-show").show( "blind", 1000 )
//       });

</script>
        <style>
         /*#listar_wrapper{ width: 80%; margin-left: 10%}*/
        .btnverdatos { width: 10px; height: 15px}

        </style>    



</html>
