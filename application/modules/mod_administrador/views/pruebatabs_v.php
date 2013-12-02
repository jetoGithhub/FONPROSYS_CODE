<?

//echo $nombrerol;
//sleep(4);
?>
<script>
 

 $(function() { 
     ayudas('#','tabs','bottom right','top left','drop','right');
     $('#add_tab').button({
                           icons: {
                           primary: "ui-icon-tag"
                           }
                           });
        
    var dialog = $( "#formtabs" ).dialog({
        autoOpen: false,
        modal: true,
        width: 380,
        buttons: {
            Agregar: function() {
                var padre=$("#idpadre").val();
                $('#crea-tabs').submit();
    //            $('#crea-tabs')[0].reset();
//                $( this ).dialog( "close" );
//                  var padre=$("#idpadre").val();
                  recarga_div('muestra_cuerpo_message','<?php echo base_url()."index.php/mod_administrador/principal_c"; ?>',padre,'<?php echo $nombrerol?>');

            },
            Cancelar: function() {
            $( this ).dialog( "close" );
            }
        }
    });


    $( "#add_tab" ).button().click(function() {

        cargar_vista_dialog('<?php echo base_url()."index.php/mod_administrador/principal_c/cargar_dialog_abuelo_padre"; ?>',<?php echo $padre;?>,1,'formtabs');

    });

     
}); 
armatabs=function(id_padre,url){
    
//    alert(url)
    
        $.ajax({
        type:"post",
        data:{padre:id_padre},
        dataType:"json",
        url:url,
        success:function(data){
            $.each(data, function(index, value) {                
//  
                $('#ul').append('<li><a id="a'+index+'" href=<?php echo base_url()."index.php/"; ?>'+data[index]['enlace']+'>'+data[index]['nombre']+'</a></li>');

                
         });
         

         $( "#tabs" ).tabs({
            beforeLoad: function( event, ui ) {
                ui.jqXHR.error(function() {
                ui.panel.html(
                "Disculpe al momento de cargar el contenido de esta opcion ocurrio algo inesperado . " +
                "Intente nuevamente." );
                });
            }
        });
//          
           
            
        }
        
     });
     
     
}

recarga_div=function(div,url,valor,valor2){

    $("#"+div).load(url+'?padre='+valor+'&nombrerol='+valor2);

}

</script>
    
<style type="text/css">
    #formtabs label, #dialog input { display:block; }
    #formtabs label { margin-top: 0.5em; }
    #formtabs input, #formtabs textarea { width: 95%; }
    #tabs { margin-top: 1em; width:95%; height:auto; position:relative;margin-bottom:10%; }
    #tabs li .ui-icon-close { float: left; margin: 0.4em 0.2em 0 0; cursor: pointer; }
    #add_tab { cursor: pointer; }
/*    #tabs .ui-tabs-nav{ background: #BF3A2B; border-top:none; border-left: none;border-right: none }*/
/*#tabs .ui-state-hover{ background:#BF3A2B; color:#fff }*/

  
</style>
         
</head>
    


         <div id="formtabs" title="Gestor para crear nuevos hijos">

         </div>

        

    <div id="tabs" class="tabs-cine">
        
        <ul id="ul">
            <?php if($nombrerol=='SUPER_ADMINISTRADOR'){?> <button txtayuda="crear nueva pestaña" id="add_tab" class=" ayuda" style=" float: right">Nuevo</button><?php }?>

        </ul>

    </div>

 

<script>
    
    armatabs(<?php echo $padre ?>,'<?php echo base_url()."index.php/mod_administrador/principal_c/buscar_hijos"; ?>');

</script>


        

