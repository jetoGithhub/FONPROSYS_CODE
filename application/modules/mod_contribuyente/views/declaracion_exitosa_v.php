<?php



?>
<script>
    $(function() {     
        $( "#btnvolver" ).button({
                       icons: {
                           primary: "ui-icon-circle-arrow-w"
                       }

             });
              $( "#btnimprimir" ).button({
                       icons: {
                           primary: "ui-icon-print"
                       }

             });
             
              $("#btnimprimir").click(function() {
                  
                  window.open('<?php echo base_url()."index.php/mod_contribuyente/contribuyente_c/imprime_declaracion/?id_declara=".$declaracionid ?>'); 

//                    window.open('<?php // print(base_url().'include/librerias/phpjasperxml_0.8c/phpjasperxml_0.8c/sample1.php?archivo=planilla_autoliquidacion.jrxml&id_declaracion='.$declaracionid);?>'); 
                 }); 
     });
     
     volver=function(){
//         ./mod_contribuyente/contribuyente_c/declaracion
          $('#a0').attr('href','<?php echo base_url()."index.php/mod_contribuyente/contribuyente_c/declaracion"?>');                    
          $("#tabs").tabs("load",0);
         
         
     }
 </script>
<style>
      #contenedor-frmdeclara{
      width: 500px;
      left:20%;
      margin-top:50px;
      position: relative;
      /*background:#CFCFCF;*/
      border:1px solid #654B24;    
      -moz-box-shadow: 3px 3px 4px #111;
      -webkit-box-shadow: 3px 3px 4px #111;
      box-shadow: 3px 3px 4px #111;
      /* IE 8 */
     -ms-filter: "progid:DXImageTransform.Microsoft.Shadow(Strength=4, Direction=135, Color='#111111')";
    /* IE 5.5 - 7 */
    filter: progid:DXImageTransform.Microsoft.Shadow(Strength=4, Direction=135, Color='#111111'); 
    margin-bottom: 50px ;
    color: #000;
    font: 62.5% "arial", sans-serif; 
    font-size: 11px;    
    }
    #contenedor-frmdeclara ,label{
        
       text-align: left;
       /*margin-left: 10px*/
       
       
    }
   
    
    #tbldeclara{        
       width: 100%;    
       
    } 
    .linea-right{
        
        border-right: 2px solid;
        border-right-color: darkgrey;
    }
 
    
    #tedeclara, label{
        
        float: left
    }
    #tedeclara, select, input{
        
        float:right;
        margin-bottom:3px
    }

   
    
    </style>
 
<center><h3 style=" color: #E21E27">Codigo Identificador: <b><?php echo $declaracionid?></b></h3></center>    
<div id="contenedor-frmdeclara"  class="ui-widget-content ui-corner-all"  >
  
<!--<form id="frmdeclara">-->    
    <fieldset class="secciones" style="margin-top:-30px; border:none; "><legend class="ui-widget-content ui-corner-all" style=" color: #654B24; font-size: 10px" align="center"><h4>FORMULARIO PARA DECLARACIONES</h4></legend><br />

        
        <table id="tdeclara" style=" border-top: 2px solid; border-top-color: darkgray; width:300px; margin-left: 20%" class="ui-corner-top">
            <tr >
                <td class="linea-right">
                    <label><strong>N&deg; de declaracion:</strong></label><br />   
                </td>
                <td>
                  <strong><?php echo $nplanilla ?></strong>
                </td>
                
            </tr>
            <tr >
                <td class="linea-right">
                 <label><strong>Tipo de contribuyente:</strong></label><br />   
                </td>
                <td>
                  <strong><?php echo $tipocon ?></strong>
                </td>
                
            </tr>
            <tr>
                <td class="linea-right">
                    <label><strong>Tipo de declaracion:</strong></label><br />
                    
                </td>
                
                 <td>
                    <strong><?php echo $tipodeclara ?></strong> 
               
                </td>
                
            </tr>
<!--            <tr id="anio-declara">
                <td class="linea-right">
                    <label><strong>Inicio periodo gravable:</strong></label><br />
                </td>
                <td>
                   <strong><?php // echo $fechaini ?></strong>  
                </td>
            
            </tr>
            <tr>
                <td class="linea-right">
                     <label><strong>Fin periodo gravable:</strong></label><br />
                </td>
                <td class="">
                     <strong><?php // echo $fechafin ?></strong>
                </td>
                
            </tr>-->
            <tr>
                <td class="linea-right">
                     <label><strong>Base imponible:</strong></label><br />
                </td>
                <td class="">
                    <strong><?php echo $base ?></strong>
                </td>
                
            </tr>
            <tr>
            <td class="linea-right">
                     <label><strong>Alicuota impositiva :</strong></label><br />
                </td>
                <td class="">
                     <strong><?php echo $alicuota ?></strong>
                </td>
            </tr>
            <tr>
            <td class="linea-right">
                <label><strong>N acto exhoneracion:</strong></label><br />
                </td>
                <td class="">
                    <strong><?php echo $exoneracion ?></strong>
                </td>
            </tr>
             <tr>
            <td class="linea-right">
                <label><strong>Credito Fiscal:</strong></label><br />
                </td>
                <td class="">
                    <strong><?php echo $cfiscal ?></strong>
                </td>
            </tr>
            <tr>
                 <td class="linea-right">
                    <label><strong>Total contribucion a pagar:</strong></label><br />
                </td>
                <td class="">
                    <strong><?php echo $total  ?></strong>
                </td>
            </tr>
            <tr>
                 <td class="linea-right">
                    <label><strong>Estado:</strong></label><br />
                </td>
                <td class="">
                    <strong>Declarcion exitosa</strong>
                </td>
            </tr>

            
         </table>
 
  </fieldset><br /><br />  
    <center>
        <button type="button" id="btnvolver" onclick="volver()">Volver</button>
         <button type="button" id="btnimprimir">Imprimir</button>
    </center>
<!--</form>-->

 <br />
 <!--<center><button id="btn-frmcontrasena" style="width:100px; height: 25px; margin-top:-10px; margin-left: 20px; position: relative" title="">Actualizar</button><br /><br /></center>-->
<!--<div style="padding: 0 .7em; width: 450px; margin-top: 15px; margin-left:20%; margin-bottom: 10px" class="ui-corner-all" id="memsajerror">
		
 </div>-->
</div>
