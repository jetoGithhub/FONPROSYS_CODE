<html>
    <table  id="consulta_cnac" cellpadding="0" cellspacing="0" border="0" class="display" width="100%">
            <thead>
                <tr>
                    <th>Nombre</th>
                    <th>Rif</th>
                    <th>Denominacion comercial</th>
                    <th>Direccion</th>
                    <th>Estado</th>
                    <th>Ciudad</th>
                    <th>Operaciones</th>
                </tr>        
            </thead>
            <tbody>
        <?php
        if (isset($datos) && sizeof($datos)>0):
            foreach($datos as $indice=>$valor): ?>
                <tr>
                    <td><?php print($valor['razonsocia']); ?></td>
                    <td><?php print($valor['rif']); ?></td>      
                    <td><?php print($valor['dencomerci']); ?></td>  
                    <td><?php print($valor['domfiscal']); ?></td>  
                    <td><?php print($valor['estado']); ?></td>  
                    <td><?php print($valor['ciudad']); ?></td>  
                    <td>
                        <input style="float: right" type="checkbox" id="asigna_recaudador" name="asigna_recaudador[]" value="<?php echo $valor['rif'] ?>" />
                        <button type="button" class="detalles_empresa" > Ver detalles</button>
                    </td>

                </tr>
                <?php
            endforeach;
        else:
            
        endif;
        ?>        
            </tbody>

        </table><br/>
          <div id="botonera-empcnac" style=" margin-left: 87%">
               <button id="asigno_recaudador" style="width: 70px; height: 25px; margin-right: 15px">Asignar</button>
               <button id="marcar_todos_recaudador" style="width: 25px; height: 25px" value="marca" >marcar</button>
        </div>
        <script>
            $('.detalles_empresa').button({
                icons: {
                 primary: "ui-icon-document"
                },
                text: false
            });
             $('#botonera-empcnac button').button({
                           icons: {
                           primary: "ui-icon-tag"
                           },
                           text:true
                           }).next().button({
                           icons: {
                           primary: "ui-icon-circle-check"
                           }, text:false                                           

                           });   
                           
             $("#marcar_todos_recaudador").click(function(){
                // alert(this.value)
                if(this.value=='marca'){
                        $("#consulta_cnac input[type=checkbox]").each(function(index) {   

                               $(this).attr("checked", true );    
                                if(index==9){
                    
                                    return false
                                 }
                        }); 
                       
                        $(this).val('desmarca');
                        //  $(this).html('desmarcar')//               
                
                }else{

                     $("#consulta_cnac input[type=checkbox]").each(function() {
                         
                           $(this).attr("checked", false );
                     });
                     
                     $(this).val('marca');
                    //  $(this).html('marcar')
                }
                
                       
            });        
            
             oTable = $('#consulta_cnac').dataTable({
                                "bJQueryUI": true,
                                "sPaginationType": "full_numbers",
                                "oLanguage": {
                                    "oPaginate": {
                                    "sPrevious": "Anterior",
                                    "sNext": "Siguiente",
                                    "sLast": "Ultima",
                                    "sFirst": "Primera"
                                    },

                                    "sLengthMenu": 'Mostrar <select disabled="true">'+
                                    '<option value="10">10</option>'+
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
    
    
    </html>