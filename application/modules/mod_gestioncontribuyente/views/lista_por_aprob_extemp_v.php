
            
<script type="text/javascript" charset="utf-8">

    $(function() {
        ayudas('.','botonera_reportes','bottom right','left top','fold','up');
        ayudas('#','botonera_calc_por_aprobar','top right','left bottom','fold','up');
        $("#error-aprobar-activa").hide();


       //script para los botones de generar excel y pdf
       $(".btn_reportes").button();

        $('#btn_excel').click(function() {

            var valor_select=$('#filtro_basico').val();
            var tipo_calculo=null;
            $(".por-aprobar input[type=radio]").each(function(index) {  

                if($(this).is(':checked')){
                 
                    tipo_calculo=$(this).val();                    
                    return false;
                }              
                
            });

//                alert(valor_select);

            if(valor_select=='todos' ||  valor_select=='reciente')
            {
                var datos_url='?valor_select='+valor_select+'&tipo_calculo='+tipo_calculo;  

            }else if(valor_select=='rif'){
                 var rif=$('#campo_rif').val();
                 var datos_url='?valor_select='+valor_select+'&rif='+rif+'&tipo_calculo='+tipo_calculo;

            }else if(valor_select=='fecha'){
                   var fecha_desde=$('#from').val();
                   var fecha_hasta=$('#to').val();

                   var datos_url='?valor_select='+valor_select+'&fecha_desde='+fecha_desde+'&fecha_hasta='+fecha_hasta+'&tipo_calculo='+tipo_calculo;
            }

            window.location='<?php echo base_url()."index.php/mod_gestioncontribuyente/lista_por_aprobar_c/excel_calculos_extemp"?>'+datos_url;

        });

    });
</script>

                
<style>

    .botonera_reportes #btn_excel #btn_pdf{
        /*background:url("<? echo base_url().'include/imagenes/iconos/ic_excel.png'?>");*/
        /*border:0px;*/
/*                        width:24px;
        height:24px;*/
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
	
  <div class="ui-widget-header" style="text-align:center; font-size: 12px; font-style: italic; margin-bottom: 10px; width: 80%; margin-left: 10%">Listado extemporáneo con calculos por aprobar</div>

  
     <table cellpadding="0" cellspacing="0" border="0" class="display" id="listar" width="100%">
	<thead>
		<tr>
			<th>#</th>
			<th>RIF</th>
                        <th>Razon Social</th>
                        <th>Tipo Contribuyente</th>
                        <!--<th>Fecha Elaboración</th>-->
                        <th>Periodo</th>
                        
                        <th>Año</th>
<!--                        <th>Tipo de Multa</th>
                        <th>Fecha del sistema</th>-->
                        <th>Opciones</th>
                        
                </tr>
	</thead>
	<tbody>
           <?
           foreach ($data as $clave => $valor) {
            $con=$clave+1;
//            $v=$valor['nombre'];
            ?>
                 <tr>
                        <td><?php print($con); ?></td>
			<td><?php print($valor['rif']); ?></td>
                        <td><?php print($valor['nombre']); ?></td>
                        <td><?php print($valor['nomb_tcont']); ?></td>
                        <!--<td><?php // print($valor['fechaelaboracion']); ?></td>-->
                        <?php if($valor['tipo']==0):?>
                            <td><?php print($this->funciones_complemento->devuelve_meses_text($valor['periodo'])); ?></td>
                        <?php endif;?> 
                        <?php if($valor['tipo']==1):?>
                            <td><?php print($this->funciones_complemento->devuelve_trimestre_text($valor['periodo'])); ?></td>
                        <?php endif;?>   
                        <?php if($valor['tipo']==2):?>
                            <td><?php print($valor['ano_calpago']); ?></td>
                        <?php endif;?>       
                        <td><?php print($valor['ano_calpago']); ?></td>
                        <!--<td><?php // print($valor['nom_tdecl']); ?></td>-->
                        <!--<td><?php // print($fecha=  date('d-m-Y')); ?></td>-->
                        <td>
                            <input style=" float: right; margin-right: 50px"type="checkbox" id="devuelve_recaudacion" name="devuelve_recaudacion[]" value="<?php echo $valor['id_contrib_calc'] ?>" />
                        </td>
                  </tr>
         
          <!--Condicion para que no se muestren los botones de activar y marcar sino existe ningun calculo listado-->     
         <?php } if (!empty($data)){?>
           
        </tbody>  
      </table><br/>
      <table id="botonera_calc_por_aprobar" border="0" style=" width: 100%" >
          <tr>
              <td style=" width: 750px">
                  <button style="" id="btn_excel" class="ayuda btn_reportes" txtayuda='generar el listado de las multas calculadas'>
                    <img src="<? echo base_url().'include/imagenes/iconos/ic_excel.png'?>" width="14px" height="12px"/>
                    <b>Generar Excel</b>
                </button>
              </td>
              <td id="btndevuelve">
                 <button txtayuda='enviar a recaudacion los calculos aprobados' class='ayuda' id="devuelve_recaudac" style="width: 80px; height: 25px; margin-right: 15px;float: right ; " onclick="boton_aprobar();">Aprobar</button>

              </td>
              <td id="btnmarca">
                <button txtayuda='seleccionar todos los calculos' class='ayuda' id="marcar_todos" style="width: 25px; height: 25px; " value="marca" >Marcar</button>
 
              </td>
          </tr>
      </table>
      
<!--          <div id="botonera_calc_por_aprobar" style=" margin-left:820px; width:130px; border: 0px solid black;">

            </div>-->
        

      <?php } ?>
       <div style="padding: 0 .7em; width: 400px; margin-top: 15px; margin-left:35%; margin-bottom: 10px" class="ui-corner-all" id="error-aprobar-activa">
            <!--espacio para la carga de error en caso de no realizar la aprobacion del calculo de forma correcta-->
       </div>

<?php // echo $fecha=  time() ?>
        <script>
            
            //script para el funcionamiento de los botones marcar y aprobar
            
            //atributos botones
            $('#btndevuelve button').button({
                           icons: {
                           primary: "ui-icon-tag"
                           },
                           text:true
                           });
            $('#btnmarca button').button({
                   icons: {
                   primary: "ui-icon-circle-check"
                   }, text:false                                           

                   });   
                           
            
            //boton marcar
            $("#marcar_todos").click(function(){
                if(this.value=='marca'){
                        $("#listar input[type=checkbox]").each(function(index) {   

                               $(this).attr("checked", true );    
                                if(index==9){
                    
                                    return false
                                 }
                        }); 
                       
                        $(this).val('desmarca');              
                
                }else{

                     $("#listar input[type=checkbox]").each(function() {
                         
                           $(this).attr("checked", false );
                     });
                     
                     $(this).val('marca');
                }
                
                       
             });
             
             
             
            
//            script para asignar atributos al listar diseñado con datatables
            oTable = $('#listar').dataTable({
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
           $('#botonera-extemp button').button({
                icons: {
                primary: "ui-icon-circle-check"
                },
                text:true
                }).next().button({
                icons: {
                primary: "ui-icon-calculator"
                }, text:true                                           

           });


                                
          $("#selec_todos").click(function(){
//        alert(this.value)
                if(this.value=='marca'){
                        $("#listar input[type=checkbox]").each(function() {   

                               $(this).attr("checked", true );       
                        }); 

                        $(this).val('desmarca');
//                      $(this).html('desmarcar')//               
                
                }else{

                     $("#listar input[type=checkbox]").each(function() {
                         
                           $(this).attr("checked", false );
                     });
                     
                     $(this).val('marca');
//                   $(this).html('marcar')
                }
                
                       
        });
        
        </script>
