<?php
$imagen='token_usado';
$display='block';
switch($estatus){
    case 'activo':
        $imagen='token_valido';
        $display='block';
        break;
    case 'vencido':
        $imagen='token_caducado';
        break;
    case 'falso':
        $imagen='token_invalido';
        break;
    case 'usado':
        $imagen='token_usado';
        break;
    
}

?>
<script type="text/javascript" >
    $(function() {
        $(".btn").button();
        ventana_ingreso('dialogo_token','',1);
        $('div#dialogo_token').dialog('open');
        $("#btn_ir_inicio_sesion").click(function() {
            window.location='<?php print(base_url()); ?>index.php/mod_contribuyente/inicio_c';});
        $( "#btn_ir_inicio_sesion" ).button({
            icons: {
                primary: "ui-icon ui-icon-person"
            }
        });
    });
    
             
</script>

<div id="dialogo_token" title="Validaciòn del Registro de Contribuyente">
<img id="captcha_registra" src="<?php print(base_url()); ?>include/imagenes/<?php print($imagen); ?>.png" />
<!--token_caducado-->
<!--token_invalido-->
<!--token_usado-->
<!--token_valido-->

<span style="float: right;margin-top: 10%; font-weight: bold; color: red;"><?php print($mensaje); ?></span><br/>
<center><div style="display:<?php print($display); ?>">
        <button id="btn_ir_inicio_sesion" class="btn">Inicio de Sesi&oacute;n</button>
</div>
</center>
</div>
