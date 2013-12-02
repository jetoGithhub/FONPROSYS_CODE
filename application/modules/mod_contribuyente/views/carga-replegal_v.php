<script>
    $(function(){
       ayudas('#','rep-legalay','bottom right','top lef','drop','left'); 
    });
</script>
<style>
    
    #frmreplegal{
        
        /*background-image: url('/fonprosys_code/include/imagenes/fondo-dialog2.png');*/
        background-repeat: no-repeat;
        background-position: center
        /*filter:alpha(opacity=25);-moz-opacity:.25;opacity:.25;*/
        
            
    }
    
    
</style>
<div id='rep-legalay'>
<div class="ui-widget-header" style="text-align:center; font-size: 12px; font-style: italic; margin-top: 30px; margin-bottom: 10px; width: 80%; margin-left: 10%">Gestion de representante legal de la empresa</div>

<table cellpadding="0" cellspacing="0" border="0" class="display " id="listar-replegal" width="">
	<thead>
		<tr>
			<th>#</th>
			<th>cedula</th>
                        <th>nombre</th>	
                        <th>domicilio fiscal</th>	
                        <th>telefono</th>	
                        <th>Operaciones</th>
                </tr>
	</thead>
	<tbody>
           <?
           $baseurl=base_url();
           if(!empty($inforeplegal)):
           foreach ($inforeplegal as $clave => $valor) {
            $con=$clave+1;
//            $v=$valor['nombre'];
               echo '<tr>
                        <td>'. $con .'</td>
			<td>'. $valor["cedula"].'</td>
                        <td>'. $valor["nombre"].'</td>
			<td>'. $valor["domicilio"].'</td>
                        <td>'. $valor["thab"].'</td>
                        <td>';?>
                        <button txtayuda=' Editar rep. legal' class=" ayuda btnverreplegal" id="<?php echo $valor['id_replegal']; ?>" onclick="cargar_vista_replegal('<?php echo base_url()."index.php/mod_contribuyente/contribuyente_c/carga_vista_dialog"; ?>',this.id,'edita-replegal','frmreplegal','edita_registro_replegal')" ></button>
                            
                <?php echo '</td></tr>';
//                       
           }
       endif;
           ?>
            <!--<button id="'.$valor["id_usuario"].'" onclick="if(confirma() == false) return false" href="<? //=base_url()?>index.php/mod_administrador/usuarios_c/eliminar_usuario/<?//=this.id?>" title="Eliminar Usuario"></button>-->
                        
           
         </table>
         <table border="0" style=" width: 80%; margin-left: 10%">
             
             <tr>
                 <td>
                    <button txtayuda='Cargar rep. legal' class='ayuda' id="btncreareplegal"  style="width:30px; height:30px; float: right" onclick="cargar_vista_replegal('<?php echo base_url().'index.php/mod_contribuyente/contribuyente_c/carga_vista_dialog';?>',this.id,'vista-replegal','frmreplegal','form_registra_replegal');"></button>
 
                 </td>
             </tr>
         </table>
            <div id="frmreplegal"> 
                
            
            </div>
            <div id="existe_replegal"></div>
            </div>
        <script>
//            script para asignar atributos al listar diseñado con datatables
            oTable = $('#listar-replegal').dataTable({
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
                                
                                 $( ".btnverreplegal" ).button({
                                    icons: {
                                    primary: "ui-icon-pencil"
                                    },
                                    text: false
                                })
                                $('#btncreareplegal').button(
                                {
                                    icons: 
                                        {
                                            primary: "ui-icon-person"
                                        },
                                    text: false
                                });
                                
                                
cargar_vista_replegal=function(url,id,ident,div,form){

//alert(id_div)   
$( "#"+div ).empty();
    $.ajax({
        type:"post",
        data:{ id:id,identificador:ident },
        dataType:"json",
        url:url,
        success:function(data){
            if (data.resultado){
//                alert(form)
                 $( "#"+div ).dialog(
                    {
                        autoOpen:false,                        
                        resizable: false,
                        width: 550,
                        height:380,
                        title: "Carga de representante legal" ,
                        show:"clip",
                        modal: true,
                        buttons: {  //propiedad de dialogo, agregar botones
                            Guardar: function() { 
                                //llamado del formulario, en este caso #form_new corresponde al id del form(en los archivos de las vistas)
//                                $("#"+div).dialog( "close" ); 
                                $("#"+form).submit();                                                
                                
                            },
                            Cancelar: function() { 
                                $("#"+div).dialog( "close" );
                            }
                        }
                    });
                $("#frmreplegal").css('background-image','url("/fonprosys_code/include/imagenes/fondo-dialog2.png")');     
                $("#"+div).html(data.vista);
                $("#"+div).dialog('open');
                
            }else{
                if(data.existe){
                    
                    $( "#existe_replegal" ).dialog(
                    {
                        autoOpen:false,
                        resizable: false,
//                        width: 300,
//                        height:200,
                        title: "Mensaje Web-Master" ,
                        show:"clip",
                        modal: true
                       
                       
                    });
                  $("#frmreplegal").css('background-image','url("")'); 
                $("#existe_replegal").html(data.vista);
                $("#existe_replegal").dialog('open');
                }
            
            }
        }


    });

};

//$(".btnverreplegal").click(function(){
////alert(this.id);
//    $.ajax({
//           type:"post",
//           data:{ id:this.id},
//           dataType:"json",
//           url:'<?php echo base_url().'index.php/mod_contribuyente/contribuyente_c/elimina_replegal';?>',
//           success:function(data){
//               
//               
//           }
//
//    });
//});
   
                                
                               
        </script>
        <style>
         #listar-replegal_wrapper{ width: 80%; margin-left: 10%}
        .btnverreplegal{ width: 30px; height: 25px; }

        </style>
	
