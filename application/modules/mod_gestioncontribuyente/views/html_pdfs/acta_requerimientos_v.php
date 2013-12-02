<style type="text/css">
    body,p,label,table{
        font-family:Arial, Helvetica, sans-serif;
        font-style: normal;
        font-size: 10px;
        text-align: justify;
        line-height: 1.5;
    }
/*    p{
        text-align: justify;
    }*/
    .page_footer {
                    width: 87%; 
                    border: none; 
                    background-color: red; 
                    border-top: solid 1mm black; 
                    padding:1mm; 
                    margin-left:55px
    }
    .firma{width: 100%;}
    .firma table{ width: 100%}
    .right p{ padding-left: 70px}
</style>

<page backtop="16mm" backbottom="16mm" backleft="16mm" backright="16mm" style="font-size: 12pt" >
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
    
    <p style=" text-align: left; margin-top: 1px"><b>FORMATO: <?php echo $cuerpo['nro_autorizacion'] ?></b></p>
    <p style=" text-align: right;"><b>Caracas,</b></p>
    <br />
                            <!-- Titulo del acta de autorizacion fiscal-->
    <p style=" text-align: center;"><b>ACTA DE REQUERIMIENTOS</b></p>
    <br />
          
    
                                    <!-- contenido de la autorizacion fiscal-->
    <p>
         El Fondo de Promoción y Financiamiento del Cine (FONPROCINE) actuando como órgano integrante
         del Centro Nacional Autónomo de Cinematografía (CNAC), de conformidad con el artículo 6 
         de la Ley de la Cinematografía Nacional publicada en Gaceta Oficial Nº 38.281, de fecha 27
         de septiembre de 2005  y reimpresa, por error del ente emisor, en fecha 26 de octubre de 2005,
         Gaceta Oficial Extraordinaria Nº 5.789, este último adscrito al Ministerio del Poder Popular
         para la Cultura, actuando de conformidad con la Autorización Fiscal identificada con las 
         letras y números <b>CNAC/FONPROCINE/GFT/AF-<?php echo $cuerpo['correlativo']?></b>, de fecha FECHA DE LA AUTORIZA
         CION FISCAL, notificada en fecha ___/___/2010, en el domicilio fiscal de la sociedad 
         mercantil <b><?php echo $cuerpo['nombre']?></b>, ubicado en <b><?php echo $cuerpo['domfiscal']?></b>, representado en
         este acto por el (la) ciudadano (a) _NOMBRE DEL REPRESENTANTE DEL CONTRIBUYENTE_____, 
         titular de la C.I. Nº _CEDULA DE IDENTIDAD DEL REPRESENTANTE DEL CONTRIBUYENTE_, 
         en su carácter de _CARGO DENTRO DE LA EMPRESA DEL REPRESENTANTE DEL CONTRIBUYENTE__ del 
         citado contribuyente, a fin de dar inicio a la fiscalización ordenada en la autorización 
         antes mencionada, conforme lo establecen los artículos 121 y 127, numerales 1, 2 y 3 del 
         vigente Código Orgánico Tributario publicado en Gaceta Oficial Nº 37.305 de fecha 
         17/10/2001, en concordancia con lo dispuesto en el artículo 41 de La Ley de la Cinematografía
         Nacional publicada en Gaceta Oficial Nº 38.281 de fecha 27/09/2005, reimpresa por error del 
         ente emisor en Gaceta Oficial Nº 5.789, Extraordinario, de fecha 26/10/2005, a requerir los 
         siguientes documentos del período comprendido desde<b> 01/01/<?php echo $cuerpo['anio_fis']?> hasta 31/12/<?php echo $cuerpo['anio_fis']?></b>,
         a saber:
        <br /><br /><br />

        1. Copia del Registro Mercantil (estatutario) y su (s) última (s) modificación (es) (Aumento o Disminución de Capital, Cambio de Junta Directiva, Sustitución de Representante Legal o Cambio de Razón y Objeto Social). 
        <br /><br />
        2. 	Copia de los Contratos que surtan efectos en la determinación de la base imponible de la Contribución Especial que corresponda.
        <br /><br />
        3. Copia de las facturas, notas de crédito y notas de débito sobre las ventas (medios magnéticos).
        <br /><br />
        4. Copia de la (s) declaración (es) Jurada (s) de Ingresos Brutos presentadas ante el  Municipio que corresponda. En caso de que el contribuyente posea más de un establecimiento permanente, debe suministrar copia de todas las declaraciones de ingresos brutos a las que esté sujeto.
        <br /><br />
        5. Copia de la declaración definitiva del Impuestos sobre la Renta (SENIAT). 
        <br /><br />
        6. Copia de las Declaraciones del Impuesto al Valor Agregado (SENIAT), acompañadas de sus respectivos libros de venta en forma digital en formato Excel ó xls (CD, Diskette, o cualquier otro medio).
        <br /><br />
        7. 	Autoliquidaciones y depósitos bancarios presentados a FONPROCINE y detalle sobre el cálculo de los ingresos declarados.
        <br /><br />
        8. Copia del Balance General, Balances de Comprobación trimestrales, Mayor (es) Analítico (s) de la (s) cuenta (s) de ingreso (s) y Estado de Ganancias y Pérdidas trimestrales. En caso de que el contribuyente no posea el Balance General, Estado de Ganancias y Pérdidas y Balance de Comprobación correspondientes al período fiscalizado porque su presentación es distinta a este período, el contribuyente deberá entregar copia del último Balance General, Estado de Ganancias y Pérdidas y Balance de Comprobación que posea.
        <br /><br />
        9. En caso que realice actividades distintas a las de difusión de señal de televisión por suscripción, facilitar los mayores analíticos de las cuentas de ingresos discriminando cada una de las partidas.
        <br /><br />
        10. Copia del Registro de Información Fiscal (RIF). 
        <br /><br />
        11. Copia del Certificado de Registro de Cinematografía Nacional.
        <br /><br />

        Se concede el plazo de tres (3) días hábiles contados a partir de la fecha de notificación de la presente acta, para la entrega de la información antes requerida al fiscal actuante.
        <br /><br />
        La revisión de la facturación podrá ser realizada en las instalaciones del establecimiento del contribuyente. Si durante la fiscalización se evidencia la necesidad de solicitar cualquier otra información, la misma podrá ser efectuada mediante acta de requerimientos dirigida al contribuyente.
        <br /><br />
        El contribuyente, de conformidad con lo establecido en los artículos 145 y 147 del Código Orgánico Tributario vigente, está obligado a cumplir con los deberes formales relativos a las tareas de fiscalización e investigación que realice la Administración Tributaria, cuya inobservancia se considera tipificada como Ilícitos Formales, lo cual genera la aplicación de las sanciones mencionadas en el artículo 105 del citado Código.
        <br /><br />
        La presente acta se emite en dos (2) ejemplares de un mismo tenor y a un solo efecto, uno de los cuales queda en poder del contribuyente que firma en señal de notificación.
    </p>
    <br />
                            <!-- seccion de la firma de la notificacion-->

    <div class="firma">
        <table >
            <tr>
               <td><p><b>POR EL CONTRIBUYENTE</b></p></td><td><p  style="padding-left: 120px"><b>EL FUNCIONARIO ACTUANTE</b></p></td> 
            </tr>
            <tr>
                <td colspan="2">
                    <table >
                        <tr>
                            <td>
                               <p>Nombre y Apellido:__________________ </p>
                            </td>
                            <td class="right">
                                <p>Nombre y Apellido:__________________</p>
                            </td>
                        </tr>
                         <tr>
                            <td>
                               <p>Cedula de Identidad:_________________ </p>
                            </td>
                            <td class="right">
                                <p>Cedula de Identidad:_________________</p>
                            </td>
                        </tr>
                         <tr>
                            <td>
                               <p>Cargo:____________________________ </p>
                            </td>
                            <td class="right">
                               <p>Firma:____________________________</p>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2">
                               <p>Telefonos:_________________________</p> 
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2">
                               <p>Feha de Notificacion:________________</p>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>

    </div>

    
                            
    
</page>