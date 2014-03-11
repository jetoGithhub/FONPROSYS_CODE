<?
//echo 'hola';


?>

 <script>
    $(function() {
         
           $( "#ventana-dialog" ).dialog({autoOpen: false});
               //mensajes que se desplazan y se van difuminando 
//         $(document).ready(parpadear);
//            function parpadear(){ 
//                $('.f').show( "slide",'10000').delay(5000).fadeOut(5000, parpadear) 
//
//            }
        $('#prueba input, textarea').attr('readonly','readonly')
        
//        $( "#activacontribu" ).button({
//                icons: {
//                    primary: "ui-icon-check"
//                } 
//      });
      
      
      //botones
      $( "#activacontribu" ).button({
                icons: {
                    primary: "ui-icon-check"
                } 
      });
      $( "#falta_doc_contrib" ).button({
                icons: {
                    primary: "ui-icon-mail-closed"
                } 
      });
      //fin botones
      //
      //estilo asigando para los inputs y textareas
      $(" input ").addClass('ui-state-highlight ui-corner-all');
      $(" select ").addClass('ui-state-highlight ui-corner-all');
      $(" textarea ").addClass('ui-state-highlight ui-corner-all');  
    
            
    });
    jQuery(function($){
        $.mask.definitions['#'] = '[JVGEjvge]';
        $("#rif").mask("#999999999");

      
     
      
        
    });
    
    //cargar ventana para el envio de observaciones por la falta de documentos
    
    
    
    
    cargar_vista_dialog2=function(url,id,ident,id_div,vrif){
                                
                                //alert(id_div)
                                    
                                    $( "#"+id_div ).dialog(
                                    {
                                        buttons: {  //propiedad de dialogo, agregar botones
                                            Enviar: function() { 
                                                
                                                alert('El correo fue enviado exitosamente')
                                                
                                                $('#envio_observacion').submit(); 
                                                
          
                                            },
                                            Cancelar: function() { 
                                                $( this ).dialog( "close" ); 
                                            }
                                        }
                                    });
                                    
                                    $.ajax({
                                        type:"post",
                                        data:{ id:id,identificador:ident,rif:vrif },
                                        dataType:"json",
                                        url:url,
                                        success:function(data){
                                            if (data.resultado){
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
                                
                                
    
    ///
    
      
    ventana_confirmacion=function(){
        
      
        $( "#ventana-dialog" ).dialog({   
                resizable: false,
                show:"clip",
//                width:250,
//                height:200,
                modal: true,
                buttons: {
                    "SI": function() {
                            $( this ).dialog( "close" );

                            $.ajax({
                            type:"post",
                            data:{idcontri:<? echo $infoplanilla['usuarioid']; ?>},
                            dataType:"json",
                            url:'<?php echo base_url()."index.php/mod_gestioncontribuyente/buscar_planilla_c/activar_contribuyente"; ?>',
                            global : false,
                                success:function(data){

                                    if(data.resultado=='true'){                                            
                                            $( "#ventana-dialog" ).dialog({                                        
                                                    modal:true,
                                                    show:"clip",
                                                    hide:"slide",
                                                    buttons: {
                                                            Ok: function() {
                                                                    $( this ).dialog( "close" );

                                                                     $("#planilla_contribu").empty();
                                                                    $("#planilla_contribu").hide();
                                                                    $("#rifcontri").val('');
                                                            }
                                                    }
                                            });
                                    $('#ventana-dialog').html('<span class="ui-icon ui-icon-check" style="float:left; margin:0 7px 0px 0;"></span><b>ACTIVACION EXITOSA..?</b>')
                                    $("#ventana-dialog").dialog('open');    




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
                            });// fin del ajax
                        

                        },
                    "NO": function() {
                        $( this ).dialog( "close" );
                        
                        
                    }
                    
                }
                
            });
//                
        $('#ventana-dialog').html('<span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 0px 0;"></span><b>SEGURO DESEA ACTIVAR ESTE CONTRIBUYENTE..?</b>')
        $("#ventana-dialog").dialog('open');
        
    }
   
  </script> 
<style>
    .encabezado{
        
        /*border:2px solid blue;*/
        width: 100%;
        text-align: center;
        background: #DDA15A;
        
    }
    #planilla table{
        margin-left:2%;
        width: 100%            
    }
   #planilla table input, textArea{
        
        width: 100%
            
    }
    .input_sin_borde{
    
        width: 89%;
        float:left;
    }
    
    label {
    display: inline-block;
/*    width: 2em;*/
}
#planilla { 
/*    background-image: url('/code2.1.3/imagenes/logo-medicina.jpg'); */
    background-repeat: no-repeat;
    border:1px solid #969494; 
/*    border con sombreado*/
    -moz-box-shadow: 3px 3px 4px #111;
    -webkit-box-shadow: 3px 3px 4px #111;
    box-shadow: 3px 3px 4px #111;
    /* IE 8 */
    -ms-filter: "progid:DXImageTransform.Microsoft.Shadow(Strength=4, Direction=135, Color='#111111')";
    /* IE 5.5 - 7 */
    filter: progid:DXImageTransform.Microsoft.Shadow(Strength=4, Direction=135, Color='#111111');
/*    fin border con sombreado*/
/*    position: relative;  */
    bottom:10%; 
    width: 85%;
    margin-left: 7%;
    color: #000;
    font: 62.5% "arial", sans-serif; 
    font-size: 11px;
 }   
.cerrar{
background-color:#5C9CCC;
    padding: 6px 12px;
border-radius: 4px;
color: black;
font-size:10px ;
    margin-left: 180px;
    margin-top: 5px;
position: relative;

}
.cerrar:before{  /*Este es un truco para crear una flechita */
    content: '';
    border-top: 8px solid #BF273C ;
    border-bottom: 8px solid transparent ;
    border-right: 8px solid transparent;
    border-left: 8px solid transparent;
    left: 180px;
    position: absolute;
    top: 23px;
}

.cerrar2{
background-color:#5C9CCC;
    padding: 6px 12px;
border-radius: 4px;
color: black;
font-size:10px ;
    margin-left: 45px;
    margin-top: 5px;
position: relative;

}
.cerrar2:before{  /*Este es un truco para crear una flechita */
    content: '';
    border-top: 8px solid transparent ;
    border-bottom: 8px solid transparent ;
    border-right: 8px solid #BF273C;
    border-left: 8px solid transparent;
    left: -16px;
    position: absolute;
    top: 3px;
}

.secciones{
            border-top:2px solid #654b24;
            border-bottom: 0px;
            border-left: 0px;
            border-right: 0px;
            
            
            
        }
        .secciones legend{
            border:1px solid #654b24;
            color:#654b24;
            padding: 0 .7em;
            
            
        }
        #cargando2{
        position:absolute;
        margin-top: 150px;
        margin-left: 500px
    /*background: url(vistas/loading.gif) no-repeat center;*/
    }


    </style>

    <div id="ventana-dialog" title="Mensaje Webmaster "></div>
     <div id="falta_doc_enviar_correo">  </div>

     
    
    <!--<button id="btn-frmbuscarcontri2" style="width:30px; height: 25px; margin-top:-25px; margin-left: 220px; position: absolute" title=" Buscar planilla"></button>-->
 <div id="planilla"  class="ui-widget-content">
    
     
  <!--mensajes de activacion o descativacion-->   
 <? // if($infoplanilla['inactivo']=='f'){?> <!--<label class="f cerrar ui-widget-header">El contribuyente con el Rif: <b><? echo $infoplanilla['rif'];?></b> ya se encuentra activo en el sistema</label>--> <? // }else{?><!--<label class="f cerrar2 ui-widget-header">activar el contribuyente</label>--><? // }?>
        
     
 <form id="prueba" style=" margin-top: 35px">
         <fieldset class='secciones' style="float:top;border-top:1px solid #654b24;"><legend class="ui-widget-content ui-corner-all" align= "center" ><h3>Datos del Contribuyente</h3></legend>
           <table border="0">
            <tr>
                <td colspan="2">
                <br /><label ><strong>1). Razon Social:</strong></label>
                <?php echo  $infoplanilla['razonsocial']; ?>
                </td>
                <td colspan="">
                <br /><label><strong>2). Denominacion Comercial:</strong></label>
                <?php echo  $infoplanilla['denominacionc']; ?>
                </td>
            </tr>
            <tr>
                <td colspan="">
                    <br /><label ><strong>3). Actividad Economica:</strong></label>
                    <?php echo  $infoplanilla['actividade']; ?>
                </td>
                <td>
                    <br /><label style="margin-right:120px"><strong>4). N° de rif:</strong></label>
                    <?php echo  $infoplanilla['rif']; ?>
                </td>
                <td>
                    <br /><label><strong>5). Registro Cinematografico:</strong></label>     
                    <?php echo  $infoplanilla['registrocine']; ?>
                </td>    
            </tr>
            <tr>
                <td colspan="3">
                    <br /><label><strong>6). Domicilio Fiscal:</strong></label>
                    <?php echo  $infoplanilla['domifiscal']; ?>
                </td>
                
            </tr>
            <tr>
                <td colspan="">
                    <br /><label ><strong>7). Ciudad o lugar:</strong></label>
                    <?php echo  $infoplanilla['ciudad']; ?>
                </td>
                <td>
                    <br /><label ><strong>8). Estado o Entidad Federal:</strong></label>
                     <?php echo  $infoplanilla['estado']; ?> 
                </td>
                <td>
                   <br /> <label><strong>9). Zona Postal:</strong></label>
                    <?php echo  $infoplanilla['zonapostal']; ?><br />
                </td>    
            </tr>
            <tr>
                <td>
                    <br /> <label ><strong>10). Telefono1:</strong></label>
                    <?php echo  $infoplanilla['telef1']; ?>
                </td>
                <td>
                   <br /><label ><strong>11). Telefono2:</strong></label>
                    <?php echo  $infoplanilla['telef2']; ?>
                </td>            
                <td>
                     <br /><label><strong>12). Telefono3:</strong></label>
                      <?php echo  $infoplanilla['telef3']; ?><br />
                   
                </td>    
            </tr>
            <tr>
                <td>
                     <br /><label ><strong>13). Fax1:</strong></label>
                    <?php echo  $infoplanilla['fax1']; ?>
                 </td>
                  <td>
                     <br /><label ><strong>14). Fax2:</strong></label>
                      <?php echo  $infoplanilla['fax2']; ?> 
                 </td>
                  <td>
                     <br /><label ><strong>15). Email:</strong></label>
                     <?php echo  $infoplanilla['email']; ?>
                 </td>      
            
            </tr>
            <tr>
                <td>
                   <br /><label ><strong>16). PINBB:</strong></label>
                    <?php echo  $infoplanilla['pinbb']; ?>
                </td>
                <td>
                     <br /><label ><strong>17). Skype:</strong></label>
                    <?php echo  $infoplanilla['skype']; ?>"
                </td>
                <td>
                    <br /><label ><strong>18). Twitter:</strong></label>
                    <?php echo  $infoplanilla['twitter']; ?>
                </td>
               
            
             </tr>
             <tr>
                 <td colspan="3">
                     <br /><label ><strong>19). Facebook :</strong></label>
                    <?php echo  $infoplanilla['facebook']; ?>
                  </td>   
             </tr>    
          </table><br />
       </fieldset>
      <fieldset class='secciones'><legend class="ui-widget-content ui-corner-all" align= "center" ><h3>Datos de las Acciones </h3></legend> 
      <table border="0">
             <tr>                
                 <td colspan="2">
                    <br /> <label ><strong>20). Numero de acciones:</strong></label>
                     <?php echo  $infoplanilla['nuacciones']; ?>
                 </td>
                 <td>
                   <br /><label colspan="2"><strong>22). Valor de las acciones:</strong></label>
                    <?php echo  $infoplanilla['valaccion']; ?>
                 </td>  
        
           
            </tr>
            
      </table><br />      
       </fieldset>     
       <fieldset class='secciones'><legend class="ui-widget-content ui-corner-all" align= "center" ><h3>Datos del registro mercatil </h3></legend> 
          <table border="0"> 
              <tr>
                  <td>
                      <br /><label ><strong>23). Capital suscrito:</strong></label>
                      <?php echo  $infoplanilla['capitalsus']; ?>
                   </td>
                  <td>
                      <br /><label style=" margin-right: "><strong>24). Capital pagado:</strong></label>
                      <?php echo  $infoplanilla['capitalpag']; ?>
                   </td>
                   <td>
                       <br /><label style=" margin-right: "><strong>25). Oficina registradora:</strong></label>
                       <?php echo  $infoplanilla['estado']; ?>
                   </td>
              </tr>
              <tr>
                  <td>
                     <br /> <label ><strong>26). N° Registro mercantil:</strong></label>
                      <?php echo  $infoplanilla['rmnumero']; ?>
                  </td>
                  <td>
                      <br /><label ><strong>27). Numero del folio:</strong></label>
                      <?php echo  $infoplanilla['rmfolio']; ?>
                  </td>
                  <td>
                      <br /><label ><strong>28). Numero del tomo:</strong></label>
                       <?php echo  $infoplanilla['rmtomo']; ?><br />
                  </td>
                  
             </tr>
             <tr>
                 <td>
                     <br /><label ><strong>29).Fecha del registro:</strong></label>
                     <?php echo  $infoplanilla['rmfechapro']; ?>
                 </td>
                  <td>
                     <br /><label ><strong>30). Numero de control:</strong></label>
                     <?php echo  $infoplanilla['rmncontrol']; ?>
                 </td>
                  <td>
                     <br /><label ><strong>31). Objeto de la empresa:</strong></label>
                     <?php echo  $infoplanilla['rmobjeto']; ?>
                 </td>
             </tr>
            <tr>
                <td colspan="3">
                    <br /><label><strong>32).Domicilio comercial:</strong></label>
                    <?php echo  $infoplanilla['domcomer']; ?>
                </td>
            </tr>
<!--             <input type="hidden" value="<?php // echo $infoplanilla['rif']; ?>" />-->
        
        </table>
       </fieldset>    
    </form>
 
      
     <p>
         <center>
             <button id="activacontribu" onClick="ventana_confirmacion(); " <?php if( $infoplanilla['inactivo']=='f'){ ?> disabled="true" <? } ?> title=" Activar Contribuyente">Activar Contribuyente</button>
             <button id="falta_doc_contrib" title="Notificar" onclick="cargar_vista_dialog2('<?php echo base_url().'index.php/mod_gestioncontribuyente/buscar_planilla_c/vista_enviar_observacion';?>',this.id,1,'falta_doc_enviar_correo','<?php echo $infoplanilla['rif']?>');">Enviar observación</button></center>
    </p>  
    </div>
    
    <!-- Estilos aplicados solo a esta página -->
<style>

 label{ display:block;}
 input{ display:block; height:20px;font-size: 12px}
 select { display:block; height:25px;font-size: 12px}
 
</style>
    
     