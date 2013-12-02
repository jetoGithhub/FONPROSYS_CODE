<style type="text/css">
    body,p,label,table{
        font-family:Arial, Helvetica, sans-serif;
        font-style: normal;
        font-size: 12px;
        text-align: justify;
        line-height: 1.5;
    }
/*    p{
        text-align: justify;
    }*/
    .page_footer {width: 87%; border: none; background-color: red; border-top: solid 1mm black; padding:1mm; margin-left:55px}
</style>

<page backtop="12mm" backbottom="16mm" backleft="16mm" backright="16mm" style="font-size: 12pt" >
                            <!-- seccion de la cabecera con el logo de la institucion-->
    <page_header>
        <div style=" position: absolute; width: 87%;  margin-left:55px">
            <img src="<?php echo base_url()."/include/imagenes/encabezado_viejo.png"; ?>" style=" width:100%; height: 55px ;"/>
        </div>        
    </page_header>
                             <!-- seccion del pie de pagina del acta-->    
    <page_footer>
        <div class="page_footer" >
            <p style=" text-align: center; color: white"><b>Avenida Francisco de Miranda con Calle Los Laboratorios, Centro Empresarial 
            Quórum, Piso 1, Oficinas 1F, 1G y 1H, Urbanización Los Ruices. Estado Miranda 
            Teléfonos: (0212)  235 21 94 / 238 24 84 / 239 21 71. Correo electrónico 
            fiscalizaciontributaria@cnac.gob.ve</b>
            </p>
        </div>
    <p style=" text-align: right">Pagina [[page_cu]]/[[page_nb]]</p> 
    </page_footer>
    
    <p style=" text-align: left; margin-top: 10px"><b>FORMATO: <?php echo $cuerpo['nro_autorizacion'] ?></b></p>
    <p style=" text-align: right;"><b>Caracas,</b></p>
    <br /><br />
                            <!-- Titulo del acta de autorizacion fiscal-->
    <p style=" text-align: center;"><b>AUTORIZACIÓN FISCAL</b></p>
    <br />
                                <!-- datos del contribuyente a fiscalizar-->
    <p style=" text-align: left;line-height:130%"><b>Sociedad mercantil:</b>&nbsp; <?php echo $principales['nombre'] ?><br />   
        <b>Representante Legal:</b>&nbsp; <?php echo $principales['nombre'] ?><br /> 
    <b>Domicilio Fiscal:</b>&nbsp; <?php echo $principales['domfiscal'] ?><br /> 
    <b>Teléfono(s):</b>&nbsp; <?php echo $principales['telefono'] ?><br /> 
    <b>R.I.F. Nº:</b>&nbsp; <?php echo $principales['rif'] ?><br /> 
    <b>R.N.C. N°:</b>&nbsp; <?php echo $principales['rif'] ?></p>
    
    
                                    <!-- contenido de la autorizacion fiscal-->
    <p>
         El Fondo de Promoción y Financiamiento del Cine (FONPROCINE) actuando como órgano integrante
         del Centro Nacional Autónomo de Cinematografía (CNAC), de conformidad con el artículo 6 
         de la Ley de la Cinematografía Nacional publicada en Gaceta Oficial Nº 38.281, de fecha 27
         de septiembre de 2005  y reimpresa, por error del ente emisor, en fecha 26 de octubre de 2005,
         Gaceta Oficial Extraordinaria Nº 5.789, este último adscrito al Ministerio del Poder Popular
         para la Cultura, en ejercicio de la competencia atribuida en el artículo 41 de la Ley de la
         Cinematografía Nacional y los artículos <b>121, 127, 129, 130, 131, y 169 al 193</b> del Código 
         Orgánico Tributario publicado en la Gaceta Oficial Nº 37.305 de fecha 17 de octubre de 2001, 
         en concordancia con el artículo 27 del Decreto N° 6.217 con Rango, Valor y Fuerza de Ley 
         Orgánica de Administración Pública, publicado en Gaceta Oficial Extraordinaria N° 5.890, 
         de fecha 31 de julio de 2008, y con el fin de velar por la sinceridad de los aportes descritos 
         en el numeral 4 del artículo 36 de la Ley de la Cinematografía Nacional, autoriza al (a los) 
         funcionario(s): <?php echo '<b>'.$cuerpo['variable0'].'</b>'?>, titular de la C.I. Nº  <?php echo '<b>'.$cuerpo['variable1'].'</b>'?>, 
         adscrito a la Gerencia de Fiscalización Tributaria del Fondo de Promoción y Financiamiento del 
         Cine (FONPROCINE), a verificar y determinar el cumplimiento de las obligaciones fiscales a las que 
         se encuentra sujeto el contribuyente anteriormente identificado; con relación a las autoliquidaciones
         y pagos de la contribución especial que grava a las empresas que presten servicio de 
         <?php echo '<b>'.$cuerpo['tipocont'].'</b>'?> con fines comerciales, previsto en el artículo <?php echo '<b>'.$cuerpo['articulo'].'</b>'?> de la Ley de 
         la Cinematografía Nacional, así como también verificar y determinar la cuantía y deberes de 
         cualquier otra contribución contemplada en ella, para el período comprendido entre el <b>01/01/<?php echo $principales['anio_fis']?> 
         al 31/12/<?php echo $principales['anio_fis']?></b>, tomando como base los libros de contabilidad, comprobantes (facturas u otro documento equivalente) 
         y demás registros contables, legales y administrativos. La información deberá ser suministrada en 
         la fecha indicada para tal fin por el CNAC.

        El funcionario autorizado estará bajo la supervisión de la funcionario(a) <?php echo '<b>'.$cuerpo['gerenteg'].'</b>'?>  
        titular de la C.I. Nº  <?php echo '<b>'.$cuerpo['cedulagg'].'</b>'?>, quien se desempeña en el cargo de Gerente General (E) de 
        FONPROCINE, el cual queda facultado para constatar las actuaciones efectuadas en el domicilio 
        fiscal del contribuyente.
        
        
    </p>
    <br /><br /><br /><br />
                            <!-- seccion de la firma del presidente del CNAC-->
    <p style=" text-align: center; line-height:150% ">
        <b><?php echo $firma['variable0']." ".$firma['variable1'] ?></b><br />
        <b>Presidenta (E)</b><br />
        <b>Centro Nacional Autónomo de Cinematografía (CNAC)</b><br />
        <b>Designada mediante Decreto No. <?php echo $firma['variable2'] ?></b><br />
        <b>Publicada en la Gaceta Oficial de la República Bolivariana de Venezuela</b><br />
        <b>No.<?php echo $firma['variable3']." del ".$firma['variable4'] ?></b>
        
    </p>
    <p style=" text-align: left"><b>SIGLAS PERSONAS QUE REVISAN EL DOCUMENTO Ej.: ADA/CL/hv</b></p>

</page>