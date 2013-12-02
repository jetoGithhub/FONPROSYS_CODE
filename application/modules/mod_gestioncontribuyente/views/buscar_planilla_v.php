<?

?>
<script>
$(function() {     
        
    $("#memsajerror").hide();
    $("#planilla_contribu").hide();
    
    validador('frmbuscarcontri','<?php echo base_url()."index.php/mod_gestioncontribuyente/buscar_planilla_c/buscar_planilla"; ?>','envia_tabs');
    
   
    $( "#btn-frmbuscarcontri" ).button({
                icons: {
                    primary: "ui-icon-search"
                } 
      });
      
      $("#btn-frmbuscarcontri").click(function(){
          
          $("#frmbuscarcontri").submit();          
          
          
      });
      

      
});

 jQuery(function($){
       $.mask.definitions['#'] = '[JVGEjvge]';
       $("#rifcontri").mask("#999999999");
   });
   
    
   
    
</script>

<!-- <div style="margin-top: 20px; padding: 0 .7em;" class="ui-state-highlight ui-corner-all">
		<p><span style="float: left; margin-right: .3em;" class="ui-icon ui-icon-info"></span>
		<strong>Hey!</strong> Sample ui-state-highlight style.</p>
 </div>-->


<div id="buscar-planilla" >
    
    <form id="frmbuscarcontri">
        <label><strong>INGRESE RIF DEL CONTRIBUYENTE:</strong></label><br />   
    <input type="text" title="hola" autocomplete="off" id="rifcontri" name="rifcontri" class="requerido ui-widget-content ui-corner-all ui-state-highlight" style="width:200px; height:20px ; font-size:12px; margin-right: 10px"  />
    
    </form>
    
    <button id="btn-frmbuscarcontri" style="width:30px; height: 25px; margin-top:-25px; margin-left: 220px; position: absolute" title="Buscar planilla"></button>
</div><br />
    
 <div style="padding: 0 .7em; width: 450px; margin-left:25%; background: #A0201D" class="ui-state-error ui-corner-all" id="memsajerror">
		<p style=" font-family: sans-serif"><span style="float: left; margin-right: .3em;" class="ui-icon ui-icon-alert"></span>
		<strong>Alerta: </strong>Disculpe no se encontro ningun resultado para este contribuyente.</p>
 </div>


<div  id="planilla_contribu" style="padding: 0 .7em; width: 80%; margin-left: 10% ; ">
   
    
    
    
</div>