<?php
if ( ! defined('BASEPATH')) exit('No esta permitido el acceso directo');
$primer_nombre = $info["nombre"];
$base_url=base_url()."index.php/";
?>
<script>
    $(function(){
        var set;
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
            
            $("#re_login_2").dialog({
        show: 'blind',
        resizable:false,
        draggable: false,
        modal: true,
        autoOpen: false,
        hide: "fade",
        stack: true,
        position: ["center","center"]
      });     
       ventana_re_login_2 = function(id_ventana,id_formulario,equis){

            $("#"+id_ventana).dialog({
               show: 'blind',
               modal:true,
               position: ["center","center"]})
               .dialog("open")
               .dialog("option", {
                   title: "Mensaje del Sistema",
                   buttons : {
                       "Validar": function(){
                           $("#"+id_formulario).submit();
                       },
                       "Cancelar": function(){

                           location.reload();
                       }
                   }
                   })
                   .children("#dialog-confirm_message")
                   .html("Su sesion ha expirado. ¡Debe logearse nuevamente!");


                   if (equis==1){
                   $("#"+id_ventana)
                   .siblings('.ui-dialog-titlebar')
                   .find('a.ui-dialog-titlebar-close')
                   .hide();
               }
               $("#"+id_ventana).dialog('open');
           };
        
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
            
           #opciones-menu-home{
               position: absolute; 
               width: 93%;
               height: 7%;
               margin-left: 2%;
               /*border: 2px solid black;*/
               float: left;
               /*padding: 0.2em;*/
                 
            }
            .menu-banner-div{
                float: right;
                width: 6%;
                height:35%;
                /*border: 2px solid black;*/
                margin-top:3%;
                padding: 0.2em
                /*margin-right: 20px*/
                
            }
            #menu-baner-home{
                background:url('include/imagenes/iconos/home.png') no-repeat;
                /*background-color: #CFCFCF ;*/ 
                background-position: right center;
                background-size: 25%;                
                margin-right: 10px
                
                    
            }
            .menu-banner-div a{
                margin-left: 15%;
                font-size: 12px;
                margin-top: 2px;                
                color:#D3D2D1; 
                font-weight: bold;
                /*text-decoration:none;*/ 
                float: left                
            }
            .menu-banner-div a:hover{
                /*font-size: 20px;*/
                margin-top: 0px;
                font-size: 11px;
                color: #5A2D21;
            }
            #menu-baner-salir{
               background:url('include/imagenes/iconos/right_grey.png') no-repeat;
                /*background-color: #CFCFCF ;*/ 
                background-position: right center;
                background-size: 25%;
                border-left: 1px solid white;
            }
            #tbl-menu-baner{
                 background:url('../../include/imagenes/encabezado_final-1220.png') no-repeat;
                /*background-color: #CFCFCF ;*/ 
                /*background-position: center center;*/               
                background-size: 100%;                
                margin-top: 0px;
            }
            #tbl-menu-baner a{
                margin-left: 15%;
                font-size: 12px;
                /*margin-top: 2px;*/                
                color:#D3D2D1; 
                font-weight: bold;
                text-decoration:none; 
                float: left;
                width:70px;
               
            }
            #tbl-menu-baner a:hover{
                /*font-size: 20px;*/
/*                margin-top: 0px;
                font-size: 11px;*/
                color: #5A2D21;
            }
             .separador{
                border-right: 2px solid white;
                /*padding-right: 5px*/
            }
</style>
    <div id="dialog-alert" title="Mensaje"><p id="dialog-alert_message"></p>

    </div>
<div id="dialogo-error-conexion" title="Mensaje Web-master"></div>
<table id="tbl-menu-baner" style="width:95%; height: 150px; margin-left:2%" cellspacing="0" cellpadding="0" border="0">
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
        
        <td style=" width: 270px">
            <table  style=" position:absolute;margin-right: 10px; top: 0px; height: 18px" cellspacing="0" cellpadding="0" border="0">
                <tr>
                    <td>
                        <center>
                        <a href="#" id="btn_main_inicio" class="separador"  >
                            Inicio
                            <img src="<?php echo base_url()."include/imagenes/iconos/home2.png"; ?>" style=" width:18px; height: 18px; border: none"/>
                        </a>
                        </center>
                    </td>
                   
                    <td>
                        <center>
                        <a href="#" id="btn_main_exit" class="separador" >
                            Salir
                            <img src="<?php echo base_url()."include/imagenes/iconos/right_grey2.png"; ?>" style=" width:18px; height: 18px; border: none"/>
                        </a>
                        </center>
                    </td>
                    <td>
                        <center>
                        <a href="#" id="btn_main_ayuda"  >
                            Ayuda
                            <img src="<?php echo base_url()."include/imagenes/iconos/help.png"; ?>" style=" width:18px; height: 14px;border: none"/>
                        </a>
                        </center>
                    </td>
               </tr>
            </table>
            
        </td>
        
    </tr>   
    
</table>
   <!--<img src="<?php // echo base_url()."/include/imagenes/encabezado_final-1220.png"; ?>" style=" width:95%; margin-left:2%"/>-->
<!--
    <div id="menu-baner-home" style=" width: auto; position:absolute; margin-top: -27px; margin-left: 87%; border: 0px solid">
      <a href="#" id="btn_main_inicio"style=" font-size: 12px; color: #959595" ><span class="ui-icon ui-icon-home" style="float: left; margin: 0 0px 0px 0; width: 20px; height: 20px"></span><b>Inicio</b></a>
    </div> 
    
    <div id="menu-baner-salir" style=" width: auto; position:absolute; margin-top: -27px; margin-left: 92%; border: 0px solid">
     <a href="#"  id="btn_main_exit" style=" font-size: 12px; color: #959595" ><span class="ui-icon ui-icon-locked" style="float: left; margin: 0 0px 0px 0;"></span><b>Salir</b></a>
    </div>
       -->
       
       
<!--       <div id="menu-baner-home" style="width: 4%; height: 2%; position:absolute; margin-top: -32px; margin-left: 85%; border-right: 1px solid white; padding-top: 5px; padding-bottom: 5px; padding-right: 16px " class="color_vinculo">
          <a href="#" id="btn_main_inicio" style="font-size: 11px; color:#D3D2D1; text-decoration:none;" >
              <span class="ui-icon ui-icon-home" style="float: left; margin: 0 0px 0px 0; width: 20px; height: 20px"></span>
              <b>Inicio</b>
              <span style="position:absolute; margin-top:-10%;">
                <img src="<?php // echo base_url()."/include/imagenes/iconos/home.png"; ?>" width="24px" height="24px"/>
              </span>
              
          </a>
            
        </div> 
        
        
        <div id="menu-baner-salir" style="width: 4%; height: 2%; position:absolute; margin-top: -32px; margin-left: 91%; padding-top: 5px; padding-bottom: 5px " class="color_vinculo">
         <a href="#"  id="btn_main_exit" style=" font-size: 12px; color:#D3D2D1; text-decoration:none; " >
             <span class="ui-icon ui-icon-locked" style="float: left; margin: 0 0px 0px 0;"></span>
             <b style=" margin-right: 2px">Salir</b> 
             <span style="position:absolute; margin-top:-10%;">
                    <img src="<?php // echo base_url()."/include/imagenes/iconos/right_grey.png"; ?>" width="20px" height="20px"/>
              </span>
              
         </a>
        </div>-->
       
       
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
    
  <div id="re_login_2">

    <fieldset class="ui-widget-content ui-corner-all ">
        <legend class="ui-widget-content ui-corner-all" style="border:1px solid #654b24;color:#654b24;padding: 0.7em;">
            Inicio de Sesion
        </legend>

        <table>
            <tr>
                <td>
                    <form id="form_re_login" class=" focus-estilo form-style">
                        <label for="reusuario">Usuario:</label>
                        <input  type="text" name="reusuario" id="reusuario" class="requerido  ui-widget-content ui-corner-all"  />

                        <br/>
                        <label for="reclave">Clave de acceso:</label>
                        <input type="password" name="reclave" id="reclave" class="requerido  ui-widget-content ui-corner-all" />

                        <br/>

                    </form>
                </td>
                <td>
                    <img  src="<?php print(base_url()); ?>include/imagenes/token_caducado.png" width="99%" height="100" />
                </td>
            </tr>
            </table>
        </fieldset><br/>
                <div id="title_re" class="ui-state-highlight ui-corner-all" style=" padding: 0.7em; font-size: 11px; font-family: monospace; color:#000; font-weight: bold; text-align: justify; line-height: 1.5">
            <p>Su sesion ha expirado por inactividad prolongada.
            Debe logearse nuevamente en el sistema.</p>
        </div>
<!--    <div class="ui-widget ui-helper-clearfix"></div>-->

<!--    <button id="btn_re_inicia_cont" class="btn">Iniciar Sesion</button>-->
 
    
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
$("#btn_main_ayuda").click(function(){
    window.open('<?php echo base_url().'manual_html/manual_carga_fonprocine.html'?>');
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
<script>
monitorea_session=function(){    
    $.ajax({
           type:"post",
           dataType:"json",
           url:"<?php echo base_url().'index.php/mod_contribuyente/inicio_c/monitorea_session'?>",
           success:function(data){
   
   
            if(data.resultado){
             clearInterval(set);
             ventana_re_login_2('re_login_2','form_re_login',1);
             
             validador('form_re_login','<?php echo base_url().'index.php/mod_contribuyente/ingreso_c/re_login'?>','envia_re_login_2');  
                
                   
            }
            
       }
    });
};
set=setInterval(function()
    {     
       monitorea_session();

    },10000);
 envia_re_login_2 = function(form,url){
        $.ajax({
            type:"post",
            data:$('#'+form).serialize(),
            dataType:"json",
            url:url,
            success:function(data){
            
            if (data.success){
                location.reload();
            }else{
                
                $("#dialog-respuesta_relogin")
                .dialog("open")
                .children("#dialog-respuesta_mensaje_relogin")
                .html(data.message);
            }
            },
            error:function(o,estado,excepcion){
                if(excepcion=='Not Found'){
                }else{
                    
                }
            }});
};    
</script>
