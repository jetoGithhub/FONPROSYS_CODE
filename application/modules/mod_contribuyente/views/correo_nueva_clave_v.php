<?php
if($modo=='html'):?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//ES" "http://
www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <title></title>
    <style type="text/css">
        #outlook a{padding:0;} /* para Outlook */
        body{width:100% !important;} 
        .ReadMsgBody{width:100%;} .ExternalClass{width:100%;} /* Fueza a que Hotmail lo pueda ver en todo lo ancho */
        body{-webkit-text-size-adjust:none;} /* previene que Webkit cambie los tamaños de texto preestablecidos. */
        body{margin:0; padding:0;}
        img{border:0; height:auto; line-height:100%; outline:none; text-decoration:none;}
        table td{border-collapse:collapse;}
        #tabla_fondo{height:100% !important; margin:0; padding:0; width:100% !important;}
        body, #tabla_fondo { background-color:#FAFAFA; }
        #contenedor { border:0; }
        h1, .h1{
            color:#202020;
            display:block;
            font-family:Arial;
            font-size:40px;
            font-weight:bold;
            line-height:100%;
            margin-top:2%;
            margin-right:0;
            margin-bottom:1%;
            margin-left:0;
            text-align:left;}
        h2, .h2{
            color:#404040;
            display:block;
            font-family:Arial;
            font-size:18px;
            font-weight:bold;
            line-height:100%;
            margin-top:2%;
            margin-right:0;
            margin-bottom:1%;
            margin-left:0;
            text-align:left;
                }
        h3, .h3{
            color:#606060;
            display:block;
            font-family:Arial;
            font-size:16px;
            font-weight:bold;
            line-height:100%;
            margin-top:2%;
            margin-right:0;
            margin-bottom:1%;
            margin-left:0;
            text-align:left;}
        h4, .h4{
            color:#808080;
            display:block;
            font-family:Arial;
            font-size:14px;
            font-weight:bold;
            line-height:100%;
            margin-top:2%;
            margin-right:0;
            margin-bottom:1%;
            margin-left:0;
            text-align:left;}
        #social div{ text-align:right; }
        #cabecera { background-color:#FFFFFF; border-bottom:5px solid #505050; }
        .cab_contenido{
            color:#202020;
            font-family:Arial;
            font-size:34px;
            font-weight:bold;
            line-height:100%;
            padding:0;
            text-align:right;
            vertical-align:middle;}
        .cab_contenido a:link, .cab_contenido a:visited, .cab_contenido a .yshortcuts {
            color:#336699;
            font-weight:normal;
            text-decoration:underline;}
        #cab_imagen { height:auto; max-width:600px !important; }
        #contenedor, .contenido{ background-color:#FDFDFD; }
        .contenido div {
            color:#505050;
            font-family:Arial;
            font-size:14px;
            line-height:150%;
            text-align:justify;}
        .contenido div a:link, .contenido div a:visited, .contenido div a .yshortcuts {
            color:#336699;
            font-weight:normal;
            text-decoration:underline;}
        .contenido img { display:inline; height:auto; }
        #datos { background-color:#FDFDFD; }
        .datos_generales{ border-right:1px solid #DDDDDD; }
        .datos_generales div {
            color:#505050;
            font-family:Arial;
            font-size:10px;
            line-height:150%;
            text-align:left;}
        .datos_generales div a:link, .datos_generales div a:visited, .datos_generales div a .yshortcuts {
            color:#336699;
            font-weight:normal;
            text-decoration:underline;}
        .datos_generales img { display:inline; height:auto; }
        #pie{ background-color:#FAFAFA; border-top:3px solid #909090; }
        .contenido_pie div{
            color:#707070;
            font-family:Arial;
            font-size:11px;
            line-height:125%;
            text-align:left;}
        .contenido_pie div a:link, .contenido_pie div a:visited, .contenido_pie div a .yshortcuts {
            color:#336699;
            font-weight:normal;
            text-decoration:underline;}
        .contenido_pie img { display:inline; }
        #social { background-color:#FFFFFF;  border:0; }
        #social div { text-align:left; }
        #utility { background-color:#FAFAFA; border-top:0; }
    </style>
</head>
<body leftmargin="0" marginwidth="0" topmargin="0" marginheight="0" offset="0">
<center>
    <table border="0" cellpadding="0" cellspacing="0" height="100%" width="100%" id="tabla_fondo">
        <tr>
            <td align="center" valign="top">
                <table border="0" cellpadding="0" cellspacing="0" width="600" id="contenedor">
                    <tr>
                        <td align="center" valign="top">
                            <table border="0" cellpadding="0" cellspacing="0" width="600px" id="cabecera">
                                <tr>
                                    <td class="cab_contenido">
                                        <!--<img src="<?php // echo base_url() ?>imagenes/cab_email.png" style="max-width:600px;" id="cab_imagen"/>-->
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td align="center" valign="top">
                            <table border="0" cellpadding="10" cellspacing="0" width="600" id="contenido">
                                <tr>
                                    <td valign="top" width="180" id="datos">
                                        <table border="0" cellpadding="20" cellspacing="0" width="100%" class="datos_generales">
                                            <tr>
                                                <td valign="top" style="padding-left:10px;">
                                                    <div >
                                                        <h3 class="h3">Datos de Usuario</h3>
                                                        <strong>Usuario:</strong>
                                                        <br/>
                                                            <?php print ($login); ?>
                                                        <br/>
                                                        <strong>Nueva Contrase&ntilde;a:</strong>
                                                        <br/>
                                                            <?php print ($nuevaclave); ?>
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                    <td valign="top" class="contenido">
                                        <table border="0" cellpadding="10" cellspacing="0" width="100%">
                                            <tr>
                                                <td valign="top" style="padding-left:0;">
                                                    <div mc:edit="std_content00">
                                                        <h2 class="h2">ASIGNACION DE NUEVA CONTRASE&Ntilde;A</h2>
                                                        <h3 class="h3">Indicaciones</h3>
                                                        Su nueva contrase&ntilde;a ha sido generada satistactoriamente.<br/>
                                                        Recuerde cambiarla por una personalizada.<br/>
                                                        Ya puede iniciar sesion <a href="<?php print(base_url().'index.php/mod_contribuyente/inicio_c'); ?>">Iniciar Session</a>
                                                        
                                                        
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td align="center" valign="top">
                            <table border="0" cellpadding="0" cellspacing="0" width="600" id="pie">
                                <tr>
                                    <td valign="top" class="contenido_pie">
                                        <table border="0" cellpadding="5" cellspacing="0" width="100%">
                                            <tr>
                                                <td valign="top" width="350">
                                                    <div mc:edit="std_footer">
                                                       
                                                    </div>
                                                </td>
                                                <td valign="top" width="190">
                                                    <div mc:edit="std_utility">
                                                        
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
                <br/>                                                    
                <div mc:edit="std_footer">
                    <b>NOTA: </b>Si usted no ha efectuado dicha solicitud ignore este mensaje.<br/>
                    No responda este mensaje, esta es una cuenta de correo no monitoreada!<br/><br/>
                    Enviado desde el Sitio Web Fonprocine.
                </div>
            </td>
        </tr>
    </table>
</center>
</body>
</html> 

<?php elseif($modo=='text'):?>
ASIGNACION DE NUEVA CONTRASEÑA 
    
    La nueva contraseña para el <?php print ($login); ?> ha sido generada satistactoriamente.
    Su nueva contraseña es <?php print ($nuevaclave); ?>
    Recuerde cambiarla por una personalizada.
    Ya puede iniciar sesion <?php print(base_url().'index.php/mod_contribuyente/inicio_c'); ?>



   NOTA:Si usted no ha efectuado dicha solicitud ignore este mensaje.



    No responda este mensaje, esta es una cuenta de correo no monitoreada!


    Enviado desde el Sitio Web Fonprocine.
<?php
endif;
?>
