<?php 
//print_r($data);
?>  
          
<div  id="menu2" style="overflow:auto; height: 220px;">

</div>
<!--<div id="cart">     
<form id="frmgrupos" class="ui-widget-content">
    
</form>
</div>-->
<style>
    
    /*#cart{ width: 200px; float: left; margin-top: 1em; }*/
    /*#cart { width: 200px; float: left; margin-top: 1em; }*/
	/* style the list to maximize the droppable hitarea */
	#cart form{ margin: 0; padding: 1em 0 1em 3em;    }
        /*#modulos{ margin: 0; padding: 1em 0 1em 3em;   }*/
        
    </style>
<script>
    
 remueve_modulo=function(id,signo,aid){
// alert(aid)
 $( signo+id ).remove();
 if(aid!=null){
     
    $("#"+aid).remove();
 }
 }
<?php

$base_url=base_url()."index.php/";

//Construcción dinámica del menú, se trabaja con la estructura dentro de $info["info_modulos"]
foreach( $data as $item):    

 if( $item["id_padre"]==0 ):
        echo "$(\"#menu2\").append( menu_crear_titulo(\"title-".$item["id_modulo"]."\",\"".utf8_decode(utf8_encode($item["str_modulo"]))."\",\"".$base_url."\") );";
	echo "$(\"#menu2\").append( menu_crear_cuerpo_elemento(\"belement-".$item["id_modulo"]."\") );";
    else:
        echo "$(\"#menu2\").find(\"div#belement-".$item["id_padre"]."\").append( menu_crear_elemento(\"element-".$item["id_modulo"]."\", \"".utf8_decode(utf8_encode($item["str_modulo"]))."\", \"".$base_url.$item["str_enlace"]."\") );";
    endif;
endforeach;
    ?>   
               
$( "#menu2" ).accordion({active:true,collapsible: true,disabled: true });

$( "#menu2 .principal a" ).draggable({
			appendTo: "body",
			helper: "clone"
		});
		$( "#frmgrupos" ).droppable({
			activeClass: "ui-state-default",
			hoverClass: "ui-state-hover",
			accept: ":not(.ui-sortable-helper)",
			drop: function( event, ui ) {
                              var idmodulo = ui.draggable.attr('bandera').split("-");
                              
//                              alert(idmodulo[1]);

                              if( ($( this ).find( "#modulo"+idmodulo[1] )) || ($( this ).find()==idmodulo[1])){
                                  
                                  $( this ).find( "#modulo"+idmodulo[1] ).remove()
//                                  $( this ).find("<br>").remove()
                              }
                             
                              // principal nos indica si el elemneto que se esta arrastrando es el abuelo
//                               onmouseover=\"javascript:$('.eliminaMod').show();\" onmouseout=\"javascript:$('.eliminaMod').hide();\"
                                  if(idmodulo[0]=='principal'){
                                     $("<div style=' border:solid 0px; margin-bottom:5px; margin-left:-30px'  id='modulo"+idmodulo[1]+"'><input type='hidden' name='modulo[]' value='"+idmodulo[1]+"'/><div style=' width:90%; height:15px; padding:3px 0px 0px 20px' class='ui-widget-header ui-corner-all'>"+ui.draggable.text()+"<a href=\"javascript:;\" onClick=\"javascript:remueve_modulo('modulo"+idmodulo[1]+"','#');\" style='position: relative; margin-top:-5px; float:right' class='ui-icon ui-icon-trash'></a></div><br /></div>").appendTo( this );
                                     $( this ).find( ".placeholder" ).remove(); 
//                                     $("<div id='p'>").appendTo( this );
//                                     $( "<input type='hidden'/>" ).val(idmodulo[1] ).appendTo( this );
//                                     $( "<label style='margin-left:-30px;' class='ui-widget-header'>"+ui.draggable.text()+"</label><br /><br />" ).appendTo( this );
//                                      $("</div>").appendTo( this );
                                     
                                        <?
                                        foreach( $data as $item):  ?> 

                                           if((idmodulo[1]=='<? echo $item['id_padre']?>')){
//                                               alert(ui.draggable.text());
                                               var mod=<? echo $item['id_modulo']?> ;
//                                               $( this ).find( ui.draggable.text() ).remove(); 
                                               $( "<label class='modulo"+mod+"' style='margin-left:20px;' >*<? echo $item['str_modulo']?></label><a id='a"+mod+"' href=\"javascript:;\" onClick=\"javascript:remueve_modulo('modulo"+mod+"','.',this.id);\" style='position: relative; margin-top:-20px; margin-left:160px' class='eliminaMod ui-icon ui-icon-trash'></a>" ).appendTo('#modulo'+idmodulo[1]);
                                               $( "<input name='modulo[]' class='modulo"+mod+"' type='hidden'/><br />" ).val(<? echo $item['id_modulo']?> ).appendTo('#modulo'+idmodulo[1]);
//                                               $(".eliminaMod").hide();
                                       }

                                       <?endforeach;?>  
                                       
                                       

                                  }else{
                                      
                                      $( this ).find( ".placeholder" ).remove();
                                      $("<div id='modulo"+idmodulo[1]+"'></div>").appendTo( this )
                                      $( "<label></label><br />" ).text( ui.draggable.text() ).appendTo('#modulo'+idmodulo[1] );
                                      $( "<div id='modulo"+idmodulo[1]+"'><input name='modulo[]' type='hidden'/>" ).val(idmodulo[1] ).appendTo('#modulo'+idmodulo[1]);

                                  }
                                  
                            
//				$( this ).find( ".placeholder" ).remove();
//				$( "<input type='text'/>" ).val( ui.draggable.text() ).appendTo( this );
			}
                        
		}).sortable({
			items: "li:not(.placeholder)",
			sort: function() {
				// gets added unintentionally by droppable interacting with sortable
				// using connectWithSortable fixes this, but doesn't allow you to customize active/hoverClass options
				$( this ).removeClass( "ui-state-default" );
			}
		});
     
</script>







<!--<style>
	h1 { padding: .2em; margin: 0; }
	#products { float:left; width: 500px; margin-right: 2em; }
	/*#cart { width: 200px; float: left; margin-top: 1em; }*/
	/* style the list to maximize the droppable hitarea */
	#cart ol { margin: 0; padding: 1em 0 1em 3em; }
	</style>
	<script>
	$(function() {
		$( "#catalog" ).accordion();
		$( "#catalog li" ).draggable({
			appendTo: "body",
			helper: "clone"
		});
		$( "#cart ol" ).droppable({
			activeClass: "ui-state-default",
			hoverClass: "ui-state-hover",
			accept: ":not(.ui-sortable-helper)",
			drop: function( event, ui ) {
				$( this ).find( ".placeholder" ).remove();
				$( "<input type='text'/>" ).val( ui.draggable.text() ).appendTo( this );
			}
		}).sortable({
			items: "li:not(.placeholder)",
			sort: function() {
				// gets added unintentionally by droppable interacting with sortable
				// using connectWithSortable fixes this, but doesn't allow you to customize active/hoverClass options
				$( this ).removeClass( "ui-state-default" );
			}
		});
	});
	</script>



<div id="products">
	<h1 class="ui-widget-header">Products</h1>
	<div id="catalog">
		<h2><a href="#">T-Shirts</a></h2>
		<div>
			<ul>
				<li>Lolcat Shirt</li>
				<li>Cheezeburger Shirt</li>
				<li>Buckit Shirt</li>
			</ul>
		</div>
		<h2><a href="#">Bags</a></h2>
		<div>
			<ul>
				<li>Zebra Striped</li>
				<li>Black Leather</li>
				<li>Alligator Leather</li>
			</ul>
		</div>
		<h2><a href="#">Gadgets</a></h2>
		<div>
			<ul>
				<li>iPhone</li>
				<li>iPod</li>
				<li>iPad</li>
			</ul>
		</div>
	</div>
</div>

<div id="cart">
	<h1 class="ui-widget-header">Shopping Cart</h1>
	<div class="ui-widget-content">
		<ol>
			<li class="placeholder">Add your items here</li>
		</ol>
	</div>
</div>-->


