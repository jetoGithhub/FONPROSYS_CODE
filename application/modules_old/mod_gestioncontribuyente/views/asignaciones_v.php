<?php //print_r($data)?>
<html>
    <script type="text/javascript" charset="utf-8">
                
 $(function() {
     ayudas('#','listar-asignacion','bottom right','left top','fold','up');
     $("#asignaciones-show").hide();
     $("#detalles-asignacion-omisos").hide();
     
 });
 
 ver_detalles_omisos=function(url,valor,valor2,valor3){
   
            $("#asignaciones-show").hide('drop',{ direction: "left" },1000)
                 setTimeout(function(){
                         $.ajax({       
                         type:'post',
                         data:{id:valor,tipocont:valor2,nro_autorizacion:valor3},
                         dataType:'html',
                         url:url,
                         success:function(html){

                            $("#detalles-asignacion-omisos").html(html);
//                            setTimeout('addDot()',1000);
                            $("#detalles-asignacion-omisos").show('drop',{ direction: "right" },1000)

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
                    },900);
     
 }
 </script>
 <div id="detalles-asignacion-omisos"></div>
<div id="asignaciones-show"> 
<div class="ui-widget-header" style="text-align:center; font-size: 12px; font-style: italic; margin-bottom: 10px; width: 80%; margin-left: 10%">Listado de contribuyentes omisos con fiscalizacion asignada</div>

<table cellpadding="0" cellspacing="0" border="0" class="display" id="listar-asignacion" >
	<thead>
		<tr>
			<th>#</th>
			<th>RIF</th>
                        <th>Raz&oacute;n Social</th>
                        <th>Tipo contribuyente</th>
                        <!--<th>Estado</th>-->
                        <th>Ciudad</th>
                        <th>Domicilio</th>
                        <th>Telefono</th>
                        <th>Opciones</th>
                </tr>
	</thead>
	<tbody>
           <?
           
           $baseurl=base_url();
           foreach ($data as $clave => $valor) :
            $con=$clave+1;
//            $v=$valor['nombre'];
               ?>'<tr>
                        <td><?php echo  $con ?></td>
			<td><?php echo  $valor["rif"]?></td>
                        <td><?php echo  $valor["nombre"]?></td>
                        <td><?php echo  $valor["tcontribuyente"]?></td>    
                        <!--<td><?php echo  $valor["estado"]?></td>-->
                        <td><?php echo  $valor["ciudad"]?></td>
                        <td><?php echo  $valor["domfiscal"]?></td>
                        <td><?php echo  $valor["telef1"]?></td>    
			
                        <td >
                        <button txtayuda='Información de los periodos a fiscalizar' class="ayuda btnverdatos" id="<?php echo $valor["id"]?>" title="" onclick="ver_detalles_omisos('<? echo $baseurl."index.php/mod_gestioncontribuyente/lista_contribuyentes_general_c/detalles_contribuyente_afiscalizar "?>','<?php echo $valor["id"]?>',<? echo $valor['tcontribuid'] ?>,'<? echo $valor['nro_autorizacion'] ?>')" title=""></button>
                        <button txtayuda=' Carga de información de los periodos con faltas y omisos' class="ayuda cargafiscalizacion" id="<? echo $valor["idasignacion"]?>"  title=""></button>
                        <button txtayuda='Carga de la información de los periodos pagados faltantes en el sistema' class="ayuda cargaperiodospag" id="<?php echo 'cp-'.$valor["idasignacion"]?>" title=""></button>
                        </td>    
                </tr>                       
           <?php endforeach;
           ?>
            <!--<button id="'.$valor["id_usuario"].'" onclick="if(confirma() == false) return false" href="<? //=base_url()?>index.php/mod_administrador/usuarios_c/eliminar_usuario/<?//=this.id?>" title="Eliminar Usuario"></button>-->
                        
           </tbody> 
         </table>
    </div>    
        <script>                            
        $('#listar-asignacion button').button({
                           icons: {
                           primary: "ui-icon-document"
                           },
                           text: false
                           }).next().button({
                           icons: {
                           primary: "ui-icon-key"
                           }                          

                           }).next().button({
                           icons: {
                           primary: "ui-icon-pin-s"
                           }                          

                           });

        $('.cargafiscalizacion').click(function(){  
       // alert(this.id)
           $('#a0').attr('href','<?php echo base_url()."index.php/mod_gestioncontribuyente/fiscalizacion_c/cargar_datos_inspeccion?valor="?>'+this.id);                    
           $('#a0').text('Carga de reparos');
           $("#tabs").tabs("load",0);    

        }); 
        
        $('.cargaperiodospag').click(function(){  
//        var recibeid=this.id; 
        var elemento=this.id.split('-');
        var id=elemento[1];
//        alert(id)
           $('#a0').attr('href','<?php echo base_url()."index.php/mod_gestioncontribuyente/fiscalizacion_c/cargar_datos_liquidados?valor="?>'+id);                    
           $('#a0').text('Carga de Periodos liquidados');
           $("#tabs").tabs("load",0);    

        }); 
       $(document).ready(function() {
            $("#asignaciones-show").show( "blind", 1000 )
      
            });
            
            //            script para asignar atributos al listar diseñado con datatables
            oTable = $('#listar-asignacion').dataTable({
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
        <style>
         /*#listar_wrapper{ width: 80%; margin-left: 10%}*/
        #listar-asignacion button{ width: 20px; height: 20px;}

        </style>
	
</html>
