<select id="ciudad" name="ciudad" class="requerido  ui-state-highlight  ui-widget-content ui-corner-all floatl" >
    <option value="">Seleccione una Ciudad</option>
<?php
if (sizeof($ciudades)>0):
    foreach ($ciudades as $ciudad):
    print("<option value='$ciudad[id]'>$ciudad[nombre]</option>");
    endforeach;
endif;

?>
</select>
