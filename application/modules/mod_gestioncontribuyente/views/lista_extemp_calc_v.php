<?php // print_r($data) ?>

<script>
    
    $(function(){
       $("#error-extem-calc").hide(); 
    });
     ayudas('#','botonera-extemp','top right','bottom left','fold','up');
    
    $(".btn_reportes").button();
    
    $('#btn_excel').click(function() {
        
        window.location='<?php echo base_url()."index.php/mod_gestioncontribuyente/lista_extemp_calc_c/excel_calculos"?>';
        
    });
    
    
    
    $('#calcular').click(function() {
        $("#listar input[type=checkbox]").each(function() { 
            
                if($(this).is(':checked'))
                {
                    $("#ic_proc"+$(this).val()).html('<img src="<?php print(base_url()); ?>include/imagenes/cargando.gif", width="16px", heigth="16px"/>');
                    var span_ic="#ic_proc"+$(this).val();
                    var span_check="#check_proc"+$(this).val();
//                    alert($(this).val());
                    $.ajax({
                        type:'post',
                        data:{valores:$(this).val(),opc_tipo_multa:1},
                        dataType:'json',
                        url:'<?php echo base_url()."index.php/mod_gestioncontribuyente/lista_extemp_calc_c/calcular_extemporaneo"?>',
                        success:function(recibe_ctrl)
                        {
                            if(recibe_ctrl.resultado)
                            {
//                                alert('si'+div);
                                $(span_ic).empty();
                                $(span_check).empty();
                                $(span_ic).html('<img  src="<?php print(base_url()); ?>include/imagenes/iconos/check_procesado.png" />');
                            }else
                            {
//                                alert('no'+div);
                                $(span_ic).empty();
                                $(span_ic).html('<img  src="<?php print(base_url()); ?>include/imagenes/iconos/error_procesado.png" />');
                            
                            }
                             $('#error-extem-calc').html('<p style="font-family: sans-serif;color:#CD0A0A;"><span style="float: left; margin-right: .3em;" class="ui-icon ui-icon-check"></span><strong>Aviso: </strong>Calculo realizado con exito.<br /><br /><center><i>Dirigase a calculos por aprobar si desea ver los detalles.</i></center></p>')
                             $("#error-extem-calc").addClass('ui-state-highlight ui-corner-all'); 
                             $("#error-extem-calc").css({background:'#FAF9EE',border:'1px solid #FEEE12'});
                             $("#error-extem-calc").show('slide',{ direction: "up" },1000);
                        }


                    });
                }else{
                    $('#error-extem-calc').html('<p style="font-family: sans-serif;color:#CD0A0A;"><span style="float: left; margin-right: .3em;" class="ui-icon ui-icon-alert"></span><strong>ERROR: </strong>Marque al menos una para calcular.</p>')
                    $("#error-extem-calc").addClass('ui-state-error ui-corner-all'); 
                    $("#error-extem-calc").css({background:'#FEF6F3',border:'1px solid #CD0A0A'});
                    $("#error-extem-calc").show('slide',{ direction: "up" },1000);
                }
            
            

        });
        
    });


//}


</script>
<html>
	<head>

                
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
	</head>


          <!--condicion para que no se muestren los botones de excel y pdf en el caso de no existir data-->
 <?php if (!empty($data)){?>        
<!-- botones generar excel y pdf -->
<!--<div class="botonera_reportes" style="float: right">
    <button id="btn_pdf" class="btn_reportes">
        <img src="<? // echo base_url().'include/imagenes/iconos/ic_pdf.png'?>" width="14px" height="12px"/>
        <b>PDF</b>
    </button>
    <button id="btn_excel" class="btn_reportes">
        <img src="<? // echo base_url().'include/imagenes/iconos/ic_excel.png'?>" width="14px" height="12px"/>
        <b>Excel</b>
    </button>
</div>-->
<? } ?>
        <!--<p>&nbsp;</p>-->
 <div class="ui-widget-header " style="text-align:center; font-size: 12px; font-style: italic; margin-bottom: 20px; margin-top: 20px; width: 80%; margin-left: 10%">Listado de Contribuyentes Extemporaneos para calcular</div>
        
<table cellpadding="0" cellspacing="0" border="0" class="display" id="listar" width="100%">
	<thead>
		<tr>
                    
			<th># </th>
			<th>Numero de Rif</th>
                        <th>Razon Social</th>
                        <th>Tipo de Contribuyente</th>
                        <th>Operaciones</th>
                </tr>
	</thead>
	<tbody>
           <?
           foreach ($data as $clave => $valor) {
            $con=$clave+1;
            $v=$valor['nombre'];
               echo '<tr>
                       
                        <td>'. $con .'</td>
			<td>'. $valor["rif"].'</td>
                        <td>'. $valor["nombre"].'</td>
                        <td>'. $valor["nomb_tcont"].'</td>
                        <td>
                            <span id="check_proc'.$valor["idconcalc"].'"><input style=" float: right; margin-right: 50px" type="checkbox" name="r_activar[]" value="'.$valor["idconcalc"].'"></span>
                            <span id="ic_proc'.$valor["idconcalc"].'"></span>
                        </td>
                        
                </tr>';
//                    
               
               
           }
           ?>
           
        </tbody>  
         </table><br />
         <?php if (!empty($data)){?> 
        <table id="botonera-extemp" border="0" style=" width: 100%" >
          <tr>
              <td style=" width: 750px">
                  &nbsp; &nbsp;&nbsp;
              </td>
              <td id="btnselec_todos">
                <button txtayuda="Selecionar para calcular la multa" class="ayuda" id="selec_todos" style="width: 80px; height: 25px" value="marca" >Marcar</button>

              </td>
              <td id="btncalcular">
                <button txtayuda="ejecutar la operacion de calculo" class="ayuda" id="calcular" style="width: 80px; height: 25px" value="calculo" >Calcular</button>
 
              </td>
          </tr>
      </table>
         
         <div id="error-extem-calc" style=" width: 300px; margin-left: 200px"></div>  
         <?php };?>
<!--         <div id="botonera-extemp" style=" margin-left: 84%; margin-top:10px">
               <button txtayuda="Selecionar para calcular la multa" class="ayuda" id="selec_todos" style="width: 80px; height: 25px" value="marca" >Marcar</button>
               <button txtayuda="ejecutar la operacion de calculo" class="ayuda" id="calcular" style="width: 80px; height: 25px" value="calculo" >Calcular</button>
        </div>
        -->
        

<!--<button id="btn-frmcontras" style="width:100px; height: 25px; margin-top:-10px; margin-left: 20px; position: relative" title="">Actualizar</button><br /><br /></center>-->


        <script>
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
	
</html>