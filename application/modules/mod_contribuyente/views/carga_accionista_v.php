<script>
    
    </script>
<style>
    
    #frmaccionista{
        
        background-image: url('/fonprosys_code/include/imagenes/fondo-dialog2.png');
        background-repeat: no-repeat;
        background-position: center
        /*filter:alpha(opacity=25);-moz-opacity:.25;opacity:.25;*/
        
            
    }
    
    
</style>
<!--<div class="ui-widget-header" style="text-align:center; font-size: 12px; font-style: italic; margin-bottom: 10px; width: 100%; ">listado de accionistas activos en la empresa</div>-->

<table cellpadding="0" cellspacing="0" border="0" class="display" id="listar-accionista" width="">
	<thead>
		<tr>
			<th><input mensaje="Debe cargar el/los accionista(s) de la empresa."style="float:left;width:0px;height:0px;" id="accionagrega" name="accionagrega" type="text" class="requerido"  />#</th>
                        <th>C&eacute;dula</th>
                        <th>Nombre</th>	
                        <th>Domicilio Fiscal</th>	
                        <th>N&uacute;mero de Acciones</th>	
                        <th>Opciones</th>
                </tr>
	</thead>
	<tbody>
           <?php
           $con=0;
           $totalacciones=0;
           $baseurl=base_url();
           foreach ($data as $clave => $valor) {
            $con=$clave+1;
            $totalacciones=$totalacciones+$valor["nacciones"];
               print('<tr>
                        <td>'. $con .'</td>
			<td>'. $valor["cedula"].'</td>
                        <td>'. $valor["nombre"].'</td>
			<td>'. $valor["domicilio"].'</td>
                        <td>'. $valor["nacciones"].'</td>');
               ?>
               <td>
                   <center><button type="button" class="btnveraccionista" id="<?php print($valor["id"]); ?>" title=""></button></center>
               </td>
               <?php print('</tr>');
                     
           }
           ?>
            
                        
         </tbody>
         </table>
            
            
            <script> 
                $('#nacciones').val(<?php print ($totalacciones); ?>);
                $('#accionagrega').val(<?php print($con>0?$con:''); ?>);
            </script><br/>
            <button type="button" id="btncreaaccionista" title="Agregar Nuevo Accionista" style="width:80px; height:30px;" onclick="cargar_vista_accionista('<?php echo base_url().'index.php/mod_contribuyente/contribuyente_c/carga_vista_dialog';?>',this.id,1,'frmaccionista');">Nuevo</button>
            <div id="frmaccionista"> 
                
            
            </div>
        <script>
//            script para asignar atributos al listar diseñado con datatables
            oTable = $('#listar-accionista').dataTable({
                                           "sScrollY": "100px",
                                           "bPaginate": false,
                                           "bScrollCollapse": true,
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
                                            '</select>registros',

                                            "sInfo": "Mostrando del _START_ a _END_ (Total: _TOTAL_ resultados)",

                                            "sInfoFiltered": " - filtrados de _MAX_ registros",

                                            "sInfoEmpty": "No hay resultados de búsqueda",

                                            "sZeroRecords": "No hay registros a mostrar",

                                            "sProcessing": "Espere, por favor...",

                                            "sSearch": "Buscar:"

                                            }
				});
                                
                                 $( ".btnveraccionista" ).button({
                                    icons: {
                                    primary: "ui-icon-closethick"
                                    },
                                    text: false
                                })
                                $('#btncreaaccionista').button(
                                {
                                    icons: 
                                        {
                                            primary: "ui-icon-person"
                                        },
                                    text: true
                                });
                                
                               
cargar_vista_accionista=function(url,id,ident,div){

//alert(id_div)

    $( "#"+div ).dialog(
    {
        autoOpen:false,
//        height: 300,
//        width: 350,
        resizable: false,
        title: "Carga de accionistas" ,
        show:"clip",
        modal: true,
        buttons: {  //propiedad de dialogo, agregar botones
            Guardar: function() { 
                //llamado del formulario, en este caso #form_new corresponde al id del form(en los archivos de las vistas)
                $('#frm_accionista').submit(); 



            },
            Cancelar: function() { 
                $("#"+div).dialog( "close" ); 
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
                $("#"+div).html(data.vista)
                $("#"+div).dialog('open')
            }
        }


    });

};
$(".btnveraccionista").click(function(){

//    alert(this.id);
    $.ajax({
        type:"post",
        data:{id:this.id},
        dataType:"json",
        url:"<?php print(base_url()); ?>index.php/mod_contribuyente/contribuyente_c/elimina_accionista",
        success:function(data){
            
            if(data.resultado==true){
                //$("#tabs").tabs("load",1);
                $("#trae_accionistas").load(
                    "<?php print(base_url()); ?>index.php/mod_contribuyente/contribuyente_c/carga_accionista", 
                        function(response, status, xhr) {
                            if (status == "error") {
                                var msg = "ERROR AL CONECTAR AL SERVIDOR:";
                                
                                $(".userDialog")
                                .html("<span class='ui-icon ui-icon-alert' style='float: left; text-align: left;margin-right: 0.3em;' >"+msg+"</span>")
                                .show('blind',500);
                                setTimeout("$('.userDialog').hide('blind',1000);" , 5000);
                            }});                 
            }    
           
            
        },
        error:function(o,estado,excepcion){
             if(excepcion=='Not Found'){
                 
             }else{
                 
             }
         }
     });
});

//$("#listar-accionista_filter").hide();
$("#listar-accionista_filter").css('width','100%')
$("#listar-accionista_filter").html('<div class="" style="text-align:center; font-size: 12px; font-style: italic; margin-bottom: 10px; width: 100%; ">Listado de Accionista de la Empresa</div>')
 
                                
                               
        </script>
        <style>
         #listar-accionista_wrapper{ width: 100%; }
        .btnveraccionista{ width: 30px; height: 25px}
        #listar-accionista_wrapper .odd{background:#ECECEC}
       
        </style>
	
