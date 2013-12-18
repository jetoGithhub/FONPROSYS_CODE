<?php
if ( ! defined('BASEPATH')) exit('No esta permitido el acceso directo');
$primer_nombre = $info["nombre"];
$base_url=base_url()."index.php/";
?>
<script>
    $(function(){
        
        carga_vista_inicio_frontend();
        
        $('#cargando').hide();
        
         $( "#dialogarmamenu" ).dialog({    
        
               autoOpen:false,
               height: 300,
               width: 350,
               modal: true,
               buttons: {
               "Guardar": function() {
                   
                   $('#frmarmamenu').submit();
                   
               },
               Cancel: function() {
               $( this ).dialog( "close" );
               }
               }
               

            });
             $("#dialogo-error-conexion").dialog({       
               autoOpen:false,
               modal: true,
               show: "clip",
               hide:"clip"
            });
        
    });        

        

</script>

<script>

carga_vista_inicio_frontend=function(){
        $.ajax({
                dataType:"html",
                url:"<?php  echo base_url().'index.php/mod_contribuyente/principal_c/cargar_vista_inicio_frontend/'; ?>",
                success:function(data){
                    
                    $('#muestra_cuerpo_message').html(data)

                }
            });
}
</script>
<style>

/*            .ui-accordion-content a:link {
                text-decoration: none;
                color: #2209AE;
            }*/
            .ui-accordion-content a:hover {
                text-decoration: none;
                color: #E40101;
            }
            

            .color_vinculo b:hover {
                text-decoration: none;
                color: #FBDDDE;
               
            }
</style>
    <div id="dialog-alert" title="Mensaje"><p id="dialog-alert_message"></p>

    </div>
<div id="dialogo-error-conexion" title="Mensaje Web-master"></div>
   <img src="<?php echo base_url()."/include/imagenes/encabezado_final-1220.png"; ?>" style=" width:95%; margin-left:2%"/>
<!--
    <div id="menu-baner-home" style=" width: auto; position:absolute; margin-top: -27px; margin-left: 87%; border: 0px solid">
      <a href="#" id="btn_main_inicio"style=" font-size: 12px; color: #959595" ><span class="ui-icon ui-icon-home" style="float: left; margin: 0 0px 0px 0; width: 20px; height: 20px"></span><b>Inicio</b></a>
    </div> 
    
    <div id="menu-baner-salir" style=" width: auto; position:absolute; margin-top: -27px; margin-left: 92%; border: 0px solid">
     <a href="#"  id="btn_main_exit" style=" font-size: 12px; color: #959595" ><span class="ui-icon ui-icon-locked" style="float: left; margin: 0 0px 0px 0;"></span><b>Salir</b></a>
    </div>
       -->
       
       
       <div id="menu-baner-home" style="width: 4%; height: 2%; position:absolute; margin-top: -32px; margin-left: 85%; border-right: 1px solid white; padding-top: 5px; padding-bottom: 5px; padding-right: 16px " class="color_vinculo">
          <a href="#" id="btn_main_inicio" style="font-size: 11px; color:#D3D2D1; text-decoration:none;" >
              <!--<span class="ui-icon ui-icon-home" style="float: left; margin: 0 0px 0px 0; width: 20px; height: 20px"></span>-->
              <b>Inicio</b>
              <span style="position:absolute; margin-top:-10%;">
                <img src="<?php echo base_url()."/include/imagenes/iconos/home.png"; ?>" width="24px" height="24px"/>
              </span>
              
          </a>
            
        </div> 
        
        
        <div id="menu-baner-salir" style="width: 4%; height: 2%; position:absolute; margin-top: -32px; margin-left: 91%; padding-top: 5px; padding-bottom: 5px " class="color_vinculo">
         <a href="#"  id="btn_main_exit" style=" font-size: 12px; color:#D3D2D1; text-decoration:none; " >
             <!--<span class="ui-icon ui-icon-locked" style="float: left; margin: 0 0px 0px 0;"></span>-->
             <b style=" margin-right: 2px">Salir</b> 
             <span style="position:absolute; margin-top:-10%;">
                    <img src="<?php echo base_url()."/include/imagenes/iconos/right_grey.png"; ?>" width="20px" height="20px"/>
              </span>
              
         </a>
        </div>
       
       
<!--    <span style=" color:#888888;margin-top:3%; float: left; margin-left:21%;"><b><?php // echo "Bienvenido(a), ".$primer_nombre;?></b></span>
    -->
    <div id="muestra_cuerpo">
        
        <div id="muestra_cuerpo_message" style="text-align:justify;"></div>
        
    </div>
   
    <div id="main_menu_container">
        
        <div id="main_menu_subcontainer">
            <!--<img src="images/monitor.png" alt="Logotipo del sistema" />-->
            <center>
                <div class="ui-widget ui-helper-clearfix">

                </div>
            </center>
           
            <div id="main_menu">
                
            </div>

        </div>
        
        <div id="main_menu_bottom">
            
        </div>
        
    </div>
    <div id="dialog-ingreso" title="Ingreso al sistema">
        
        <p id="dialog-ingreso_message"></p>
        
    </div>
    <div id="dialog-confirm" title="Mensaje">
        
        <p id="dialog-confirm_message" style="text-align:justify;"></p>
        
    </div>

    <div id="dialog-prompt" title="Mensaje">
        
        <p id="dialog-prompt_message" style="text-align:justify;"></p>
        <input type="text" name="dialog-prompt_inmput" id="dialog-prompt_inmput" style="width:98%;" />
        
    </div>

    <div id="dialog-accion" title="Mensaje">
        
        <p id="accion_message"></p>
        
    </div>

    <div id="dialogarmamenu" title="Gestor para crear nuevos padres">


    </div>

<div style="padding: 0 .7em; width: 150px; left:100px; top:50px"   id="cargando"  >
    
    <center><img src='/fonprosys_code/include/imagenes/ajax-loader.gif' style='width: 20px;' alt='logo' /><br />
    <b>Cargando Espere....</p></b></center>
    
</div> 

<script>

<?php

//Construcción dinámica del menú, se trabaja con la estructura dentro de $info["info_modulos"]
foreach( $info["info_modulos"] as $item):
    if( $item["id_padre"]==0 ):
        echo "$(\"#main_menu\").append( menu_crear_titulo(\"title-".$item["id_modulo"]."\",\"".utf8_decode(utf8_encode($item["str_modulo"]))."\",\"".$base_url."\") );";
	echo "$(\"#main_menu\").append( menu_crear_cuerpo_elemento(\"belement-".$item["id_modulo"]."\") );";
    else:
        echo "$(\"#main_menu\").find(\"div#belement-".$item["id_padre"]."\").append( menu_crear_elemento(\"element-".$item["id_modulo"]."\", \"".utf8_decode(utf8_encode($item["str_modulo"]))."\", \"".$base_url.$item["str_enlace"]."\") );";
    endif;
    ?>
        $("#element-<?php print($item["id_modulo"]);?>").click(function() {
//              $('#cargando').ajaxStart(function(){$(this).show();});  
//              $('#cargando').ajaxComplete(function(){$(this).hide();}); 
              
         $("#muestra_cuerpo_message").empty();   
//alert("<?php //print(utf8_decode($base_url.$item["str_enlace"]."?padre=".$item["id_modulo"]));?>");
$("#muestra_cuerpo_message").load(
    "<?php print(utf8_decode($base_url.$item["str_enlace"]."?padre=".$item["id_modulo"]));?>", 
    function(response, status, xhr) {
        if (status == "error") {
            var msg = "ERROR AL CONECTAR AL SERVIDOR:";
            $("#dialog-alert")
            .children("#dialog-alert_message")
            .html(msg + xhr.status + " " + xhr.statusText);
            $("#dialog-alert").dialog("open");
  }
});
                    });
    <?php
    
    
endforeach;
    ?>   
        
$("div#dialog-alert, div#dialog-confirm, div#dialog-prompt, div#dialog-report").dialog({
    modal: true,
    autoOpen: false,
    hide: "fade",
    stack: true,
    position: ["center","center"]
});
$("div#dialog-ingreso").dialog({
    modal:false,
    autoOpen: false,
    hide: "fade",
    stack: true,
    position: ["center","center"]
});               

$("#main_menu").accordion({
    autoHeight: false,
    navigation: true
});
$("#btn_main_toggle_menu").button().click(function(){
    $("#main_menu").toggle( "blind", {}, 150 );
});
$("#btn_main_exit").click(function(){
    $("div#dialog-confirm").dialog({
        show: 'blind',
        position: ["center","top"]})
	.dialog("open")
	.dialog("option", {
            title: "Confirme la acción",
            buttons : {
                "Si": function(){
                    location.href="<?php print($base_url); ?>mod_contribuyente/salida_c";
                },
                "Cancelar": function(){
                    $(this).dialog("close");
                }
            }
            })
            .children("#dialog-confirm_message")
            .html("Esta accion cerrara su sesion. ¿Desea continuar?");
            });
            
            $("#btn_main_inicio").click(function(){
//                alert('Cargar Inicio');
                carga_vista_inicio_frontend();
                
            });
        
</script>
<style>
	div#banner_container, div#content_container{
		position:absolute;
		padding:10px;
                background-image:url('images/yWi3BY.png');background-repeat:repeat-x;
	}
	div#main_menu_container, div#content_container{
		position:absolute;
		padding:10px;
	}        
	div#banner_container{
		top:0px; left:0px; right:0px;
		height:100px;
		z-index:1;
		color:#3c5e29;
                border: 0px;
	}
	div#main_menu_container{
		top:110px; left:5px;
		width:200px;
		z-index:2;
		padding-top:0px !important;
		padding-bottom:0px !important;
	}
	div#main_menu{
		display:block;
	}
	div#main_menu div{
		padding:10px;
	}
	div#main_menu ul{
		padding-left:15px;
	}
	div#content_container{
		top:118px; left:0px; right:30px; bottom:0px;
		height:auto; width:auto;
		z-index:0;
		overflow:auto;
	}
 	div#cuerpo{
		top:118px; left:0px; right:0px; bottom:0px;
		height:auto; width:auto;
		z-index:0;
		overflow:auto;
	}       
	div#main_menu_container div#buttons{
		padding: 5px 0;
	}
	div#main_menu_subcontainer{
		background:url('images/main_menu_shadow.png') repeat-y -5px 0px;
		width:100%; height:100%;
		padding:10px;
	}
	div#main_menu_bottom{
		background:url('images/main_menu_bottom_shadow.png') no-repeat -5px 0px;
		width:100%; height:100%;
		padding:10px 10px 0 10px;
	}
 	div#muestra_cuerpo{
/*		background:url('images/main_menu_bottom_shadow.png') no-repeat -5px 0px;*/
/*		width:100%; height:100%;*/
/*		padding:10px 10px 0 10px;*/
                border: 0px solid #000000;
                top:120px; left:240px; right:0px;
                position:absolute;
                clear:both;
                height:auto;
                text-align:justify;               
	}     
	table#tabla th, table#tabla td{
		padding:2px !important;
	}
	table#tabla td{
		cursor:pointer;
	}
	table#tabla tbody tr:hover{
		background-color:#FFEB8F;
	}
        #cargando{
    position:absolute;
    margin-top: 150px;
    margin-left: 500px
/*background: url(vistas/loading.gif) no-repeat center;*/
        }

/*.ui-state-hover{ background:#BF3A2B }*/

 /*
    * estilos para los formularios que se creen en el sistema en las ventanas emergentes o dialog
    */
    .form-style input label { display:block;}
    .form-style td,label{ font-weight: bold;}
    .form-style input { margin-bottom:12px; width:95%; padding: .2em;  font-family: sans-serif, monospace; font-size: 12px }
    .form-style select{ margin-bottom:12px; width:98%; padding: .2em; font-family: sans-serif, monospace;  font-size: 12px}
    .form-style textArea,textarea{ margin-bottom:12px; width:95%; padding: .2em;  font-family: sans-serif, monospace; font-size: 12px }
    .form-style fieldset { padding:0; border:0; margin-top:25px; }
    .form-style h1 { font-size: 1.2em; margin: .6em 0; }
    
    
    /*
    *estylo para que cunado el cursor este sobre la caja coloque sombra en los bordes
    */   
    
    .focus-estilo input:focus{
        /*border: none;*/
        outline:0px;
        /*border-style: none;*/
          border-color: #BF4639;
          box-shadow: 1px 1px 7px #BF4639;
        -webkit-box-shadow:  1px 1px 7px #BF4639;
        -moz-box-shadow:  1px 1px 7px #BF4639;
        
        /*-moz-box-shadow: 10px inset 1px 1px #888;*/ 
    }
    .focus-estilo textArea:focus{
        /*border: none;*/
        outline:0px;
        /*border-style: none;*/
         border-color: #BF4639;
          box-shadow: 1px 1px 7px  #BF4639;
        -webkit-box-shadow:  1px 1px 7px  #BF4639;
        -moz-box-shadow:  1px 1px 7px #BF4639;
        
        /*-moz-box-shadow: 10px inset 1px 1px #888;*/ 
    }
    .focus-estilo select:focus{
         /*border: none;*/
         outline:0px;
         /*border-style: none;*/
          border-color: #BF4639; 
          box-shadow: 1px 1px 7px   #BF4639;
        -webkit-box-shadow:  1px 1px 7px  #BF4639;
        -moz-box-shadow:  1px 1px 7px   #BF4639 ;
        
        /*-moz-box-shadow: 10px inset 1px 1px #888;*/ 
    }
    
    .ui-tooltip-red{ 
     border: 5px solid black ;  
     color: white;
     font-family: monospace;
     font-style: oblique;
     font-weight: bold;
     background: #B20101;  
     max-width: 170px;
     text-align: center;
    }
    .ui-tooltip-cream{
      border: 5px solid #B20101  
    }
    
    .dataTables_wrapper{
        overflow: auto;
    }
</style>

