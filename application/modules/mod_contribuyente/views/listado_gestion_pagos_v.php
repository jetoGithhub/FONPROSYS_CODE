<script>
$(function(){
    ayudas('#','listar-getion','bottom right','top left','fold','up'); 
   $("#contenedor_cargar_pago").dialog({   
                autoOpen:false,
                resizable: false,
                show:"clip",
                hide:"clip",
//                width:250,
//                height:200,
                modal: true
  });
 espera_carga_pago=function(){
        $.blockUI({ 
            message: $('#espera_cargar_pago'),
            css: { 
                border: 'none',
                padding: '15px', 
                backgroundColor: '#fff', 
                '-webkit-border-radius': '10px', 
                '-moz-border-radius': '10px', 
                opacity: .7, 
                color: '#CD0A0A' 
            } });  

        };  
   
});
$(".cargar_pago").click(function(){
        var tipo_pago=<?php echo $tipo_pago;?>;
        var legend;
        if((tipo_pago!=1) && (tipo_pago!=2)){
             
             legend='Deposito de la Multa';

        }else{           
             legend='Datos del Deposito';
        }
        
        
        var html="<fieldset class='secciones' style='margin-top:0px; border:1px solid #CDCCCB;padding:0px 10px 10px 10px '><legend class='ui-widget-content ui-corner-all' style=' color: #654B24' align='center'><h4>"+legend+"</h4></legend><br />";
            html+="<form id='frm_carga_pago' class='form-style focus-estilo' >";
            html+="<input type='hidden' name='cadena' id='cadena' value='"+this.id+"' />";
            html+="<label>Numero del deposito</label>";
            html+="<input type='text' name='deposito' id='deposito' class=' requerido ui-widget-content ui-corner-all' />";
            html+="<label>Fecha del deposito</label>";
            html+="<input type='text' name='fdeposito' id='fdeposito' class=' fecha requerido ui-widget-content ui-corner-all' />";
            if((tipo_pago!=1) && (tipo_pago!=2)){
                html+="<fieldset class='secciones' style='margin-top:0px; border-top:1px solid #CDCCCB;padding:0px 0px 0px 0px '><legend class='ui-widget-content ui-corner-all'style=' color: #654B24' align= 'center' ><h4 style=''>Deposito de intereses</h4></legend><br />";
                html+="<label>Numero del deposito</label>";
                html+="<input type='text' name='depositoi' id='depositoi' class=' requerido ui-widget-content ui-corner-all' />";
                html+="<label>Fecha del deposito</label>";
                html+="<input type='text' name='fdepositoi' id='fdepositoi' class='fecha requerido ui-widget-content ui-corner-all' />";
                html+="</fieldset>";
            }
            html+="</form>";
            html+="</fieldset>";
    $("#contenedor_cargar_pago").html(html);
    $("#contenedor_cargar_pago").dialog({
        buttons: {
               "Guardar": function() {
                   
                   $('#frm_carga_pago').submit();
                   
               },
               Cancel: function() {
               $( this ).dialog( "close" );
               }
               }
    });
    $("#contenedor_cargar_pago").dialog('open');
    $( ".fecha" ).datepicker({
        dateFormat: "dd-mm-yy",
        dayNamesMin: [ "Do", "Lu", "Ma", "Mi", "Ju", "Vi", "Sa" ],
        monthNames: [ "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre" ],
        showAnim: "slide",
        navigationAsDateFormat: true
    });
    validador('frm_carga_pago','<?php echo base_url()."index.php/mod_contribuyente/gestion_pagos_c/cargar_pago"?>','cargar_pago');
});
</script>

<div id="contenedor_cargar_pago" title="Cargar pagos" ></div>
<div id="espera_cargar_pago"></div>

<div class="ui-widget-header" style="text-align:center; font-size: 12px; font-style: italic; margin-bottom: 10px; width: 80%; margin-left: 10%"><?php echo "Listado de ".$tipo." Pendientes por Pagos " ?></div>

  
     <table cellpadding="0" cellspacing="0" border="0" class="display" id="listar-getion" width="100%">
	<?php 
        if(($tipo_pago==1) || ($tipo_pago==2)){
        ?>
         
                <thead>
                       <tr>
                               <th>#</th>
                               <th>Numero</th>
                               <th>Fecha de la declaracion</th>
                               <th>Tipo Contribuyente</th>
                               <th>Base imponible</th>
                               <th>Año declarado</th>
                               <th>Periodo declarado</th>
                               <th>Total a pagar</th>
                               <th>Opciones</th>

                       </tr>
               </thead>
               <tbody>
                  <?
                  if (!empty($data)) {               

                  foreach ($data as $clave => $valor) {
                   $con=$clave+1;
       //            $v=$valor['nombre'];
                   ?>
                        <tr>
                               <td><?php print($con); ?></td>
                               <td><?php ($tipo_pago==1? print($valor['numero']) : print('CNAC/FONPROCINE/GFT/AFR-'.$valor['nreparo']) ) ?></td>
                               <td><?php print(date('d-m-Y',strtotime($valor['fechaelab']))); ?></td>
                               <td><?php print($valor['contribuyente_text']); ?></td>
                               <td><?php print($this->funciones_complemento->devuelve_cifras_unidades_mil($valor['base'])); ?></td>
                               <td><?php print($valor['anio']); ?></td>
                               <?php if($valor['periodo_gravable']==0):?>
                               <td><?php echo $this->funciones_complemento->devuelve_meses_text($valor["periodo"]); ?></td> 
                               <?php endif;?>

                                <?php if($valor['periodo_gravable']==1):?>
                               <td><?php echo $this->funciones_complemento->devuelve_trimestre_text($valor["periodo"]); ?></td> 
                               <?php endif;?>

                                <?php if($valor['periodo_gravable']==2):?>
                               <td><?php echo $valor["anio"] ?></td> 
                               <?php endif;?>
                               <td><?php print($this->funciones_complemento->devuelve_cifras_unidades_mil(round($valor['total'],2))); ?></td>
                       
                        <td id="botonera">
                            <!--<button style=" float: left" txtayuda="Ver planilla" class=" ayuda imprime_planilla" id="i-<?php ///echo $valor['id_declra'].'-'.$valor['tipo_pago'] ?>"></button>-->
                            <button style=" float: right" txtayuda="Cargar pago" class=" ayuda cargar_pago" id="c:<?php echo $valor['id_declra'].':'.$valor['tipo_pago'] ?>"></button>
                        </td>
                  </tr>
           <?php }
               }
           echo '</tbody>'; 
           }else{
               if($tipo_pago==3): $cadena='CNAC/FONPROCINE/GRT/RISE-'; endif;
               if($tipo_pago==4): $cadena='CNAC/RCF-'; endif;
               if($tipo_pago==5): $cadena='CNAC/RCS-'; endif;
               
               ?>
                  
                <thead>
                        <tr>
                                <th>#</th>
                                <th>Resolucion</th>
                                <th>Fecha</th>
                                <th>Tipo Contribuyente</th>
                                <?php if($tipo_pago==3){ echo "<th>Base Imponible</th>"; }?>
                                <th>Año</th>
                                <?php if($tipo_pago==3){ echo "<th>Periodo</th>"; }?>
                                <th>Total Multa</th>
                                <th>Total Interes</th>
                                <th>Opciones</th>

                        </tr>
                </thead>
                <tbody>
                    <?
                  if (!empty($data)) {               

                  foreach ($data as $clave => $valor) {
                   $con=$clave+1;
       //            $v=$valor['nombre'];
                   ?>
                        <tr>
                               <td><?php print($con); ?></td>
                               <td><?php print($cadena.$valor['numero']); ?></td>
                               <td><?php print(date('d-m-Y',strtotime($valor['fechaelab']))); ?></td>
                               <td><?php print($valor['contribuyente_text']); ?></td>
                               <?php if($tipo_pago==3){ echo '<td>'.$this->funciones_complemento->devuelve_cifras_unidades_mil($valor['base']).'</td>'; }?>
                               <td><?php print($valor['anio']); ?></td>
                               <?php if($tipo_pago==3){?>
                                   <?php if($valor['periodo_gravable']==0):?>
                                   <td><?php echo $this->funciones_complemento->devuelve_meses_text($valor["periodo"]); ?></td> 
                                   <?php endif;?>

                                    <?php if($valor['periodo_gravable']==1):?>
                                   <td><?php echo $this->funciones_complemento->devuelve_trimestre_text($valor["periodo"]); ?></td> 
                                   <?php endif;?>

                                    <?php if($valor['periodo_gravable']==2):?>
                                   <td><?php echo $valor["anio"] ?></td> 
                                   <?php endif;
                               }
                               ?>
                               <td><?php print($this->funciones_complemento->devuelve_cifras_unidades_mil(round($valor['total'],2))); ?></td>
                               <td><?php print($this->funciones_complemento->devuelve_cifras_unidades_mil(round($valor['total_interes'],2))); ?></td>
                       
                        <td id="botonera">
                            <!--<button style=" float: left" txtayuda="Ver planilla" class=" ayuda imprime_planilla" id="i-<?php //echo $valor['id_declra'].'-'.$valor['tipo_pago'] ?>"></button>-->
                            <?php if($tipo_pago==3){ ?>
                            <button style=" float: right" txtayuda="Cargar pago" class="ayuda cargar_pago" id="c:<?php echo $valor['id_declra'].':'.$valor['tipo_pago']?>" ></button>
                            <?php }else{?>
                            <button style=" float: right" txtayuda="Cargar pago" class="ayuda cargar_pago" id="c:<?php echo $valor['id_declra'].':'.$valor['tipo_pago'].':'.$valor['multaids'] ?>" ></button>

                            <?php } ?>
                        </td>
                  </tr>
                  <?php }
                    }?>
              </tbody>
           <?php 
           }?>
          <!--Condicion para que no se muestren los botones de activar y marcar sino existe ningun calculo listado-->     
         
           
         
      </table>
<script>
            
            //script para el funcionamiento de los botones marcar y aprobar
            
            //atributos botones
            $('td#botonera button').button({
//                           icons: {
//                           primary: "ui-icon-tag"
//                           },
//                           text:true
//                           }).next().button({
                           icons: {
                           primary: "ui-icon-pencil"
                           }, text:false                                           

                           });   
                           
            
           
//            script para asignar atributos al listar diseñado con datatables
    oTable = $('.display').dataTable({
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
                                
//                                
cargar_pago=function(form,url){
$("#contenedor_cargar_pago").dialog('close');
$("#espera_cargar_pago").html('<p><b>POR FA VOR ESPERE EL SISTEMA ESTA REGISTRANDO SU PAGO...</b></p><br /><br /><img  src="<?php print(base_url()); ?>include/imagenes/loader.gif" width="35" height="35" />');             
espera_carga_pago();// mensage de espera
    $.ajax({
            type:'post',
            data:$("#"+form).serialize(),
            dataType:'json',
            url:url,
            success:function(data)
            {
                if(data.resultado){
                    $("#espera_cargar_pago").empty();
                    $("#espera_cargar_pago").html('<p><span class="ui-icon ui-icon-circle-check" style="float: left; margin: 0px 0px 0px 0px;"></span><b>PAGO REGISTRADO CON EXITO, GRACIAS...</b></p>'); 
                    setTimeout(function(){
                         $.unblockUI();//cierra mensaje de espera
                         $("#espera_cargar_pago").empty();
                         $("#tabs").tabs("load",0); 
                    },3000);
                    
                    
                }

            }
        });
};
        
        </script>
<style>
    td#botonera button{
        width: 30px;
        height: 25px
            
    }
    
    </style>