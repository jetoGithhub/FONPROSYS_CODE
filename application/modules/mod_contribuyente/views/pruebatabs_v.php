
<? // sleep(2)?>
<script>
     

 $(function() {       
        
      
     
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
         //              $('#cargando').ajaxStart(function(){$(this).show();});  
//              $('#cargando').ajaxComplete(function(){$(this).hide();}); 

         $( "#tabs" ).tabs({

             beforeLoad: function( event, ui ) {
//                 $("#tabs-load").show();
                //mintras carga los datos el ajax colocamos un mensaje
                if (ui.panel.is(":empty")) {
                    ui.panel.html(
                        '<center><img id="tabs-load" width="25" height="25"  src="./include/imagenes/loader.gif" /><br />' +
                        "Cargando el contenido de la pestaña.....</centen>" ),
    //             ui.jqXHR.complete(function() {
    //                    $("#tabs-load").hide();
    //                }),
                    ui.jqXHR.error(function() {
                    ui.panel.html(
                    "Disculpe al momento de cargar el contenido de esta opcion ocurrio algo inesperado . " +
                    "Intente nuevamente." );
                    });
               }else{
                   
                    ui.jqXHR.error(function() {
                    ui.panel.html(
                    "Disculpe al momento de cargar el contenido de esta opcion ocurrio algo inesperado . " +
                    "Intente nuevamente." );
                    });
               }
            }
//            ,
//            load: function (event, ui) {
//                $('#cargando').hide();
//             },
//             select: function (e, ui) {
//                 var $panel = $(ui.panel);
//                 if ($panel.is(":empty")) {
//                     $('#cargando').show();
//                 }
//             }
         });
//          
           
            
        }
        
     });
     
     
}

recarga_div=function(div,url,valor){

    $("#"+div).load(url+'?padre='+valor);

}

</script>
    
<style type="text/css">
    #formtabs label, #dialog input { display:block; }
    #formtabs label { margin-top: 0.5em; }
    #formtabs input, #formtabs textarea { width: 95%; }
   #tabs { margin-top: 1em; width:95%; margin-top: 0px; /*background: #fff;*/ }
    #tabs li .ui-icon-close { float: left; margin: 0.4em 0.2em 0 0; cursor: pointer; }
    #add_tab { cursor: pointer; }
    /*#tabs .ui-tabs-nav{ background: #BF3A2B; border-top:none; border-left: none;border-right: none }*/
    /*#tabs .ui-state-hover{ background:#BF3A2B; }*/
 
</style>
         
</head>
<!--    <div style=" width: 150px; margin-left: 370px; position:absolute; top: 8px;"   id="cargando-pregunta"  >
    
            <center><img src='/fonprosys_code/include/imagenes/ajax-loader.gif' style='width: 20px;' alt='logo' /><br />
            <b>Cargando Espere....</p></b></center>

    </div>-->
   
        

    <div id="tabs" >
 
        <ul id="ul">
             
        </ul>

    </div>

 

<script>
    
    armatabs(<?php echo $padre ?>,'<?php echo base_url()."index.php/mod_contribuyente/principal_c/buscar_hijos"; ?>');

</script>


        

