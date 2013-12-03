--
-- PostgreSQL database dump
--

-- Dumped from database version 9.1.10
-- Dumped by pg_dump version 9.1.10
-- Started on 2013-11-15 14:53:04 VET

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 3326 (class 1262 OID 128358)
-- Dependencies: 3325
-- Name: FONPROCINE; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE "FONPROCINE" IS 'Base de datos del sistema de recaudación de Fonprocine';


--
-- TOC entry 9 (class 2615 OID 128359)
-- Name: datos; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA datos;


ALTER SCHEMA datos OWNER TO postgres;

--
-- TOC entry 3327 (class 0 OID 0)
-- Dependencies: 9
-- Name: SCHEMA datos; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA datos IS 'standard public schema';


--
-- TOC entry 10 (class 2615 OID 128360)
-- Name: historial; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA historial;


ALTER SCHEMA historial OWNER TO postgres;

--
-- TOC entry 3329 (class 0 OID 0)
-- Dependencies: 10
-- Name: SCHEMA historial; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA historial IS 'Esquema para la tabla de historial de transacciones';


--
-- TOC entry 6 (class 2615 OID 128361)
-- Name: pre_aprobacion; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA pre_aprobacion;


ALTER SCHEMA pre_aprobacion OWNER TO postgres;

--
-- TOC entry 7 (class 2615 OID 128362)
-- Name: seg; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA seg;


ALTER SCHEMA seg OWNER TO postgres;

--
-- TOC entry 8 (class 2615 OID 128363)
-- Name: segContribu; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA "segContribu";


ALTER SCHEMA "segContribu" OWNER TO postgres;

--
-- TOC entry 318 (class 3079 OID 11716)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 3333 (class 0 OID 0)
-- Dependencies: 318
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = datos, pg_catalog;

--
-- TOC entry 331 (class 1255 OID 128364)
-- Dependencies: 9 1022
-- Name: crea_correlativo_actas(); Type: FUNCTION; Schema: datos; Owner: postgres
--

CREATE FUNCTION crea_correlativo_actas() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
anio_servidor integer;
nautori integer;
condicion integer;
BEGIN
	/*anio=(select substring('0001-2012',(position('-' in '0001-2012')+1)));
			
	  correlativo=(substring('0001-2012',0,(position('-' in '0001-2012'))));*/
	  
	/******************************************************************
	*  TG_OP CONTIENE EL NOMBRE DE LA ACCION QUE SE EJECUTO EN LA TABLA
	*******************************************************************/
	IF(TG_OP = 'INSERT') THEN
		/***************************************************************************
		*  TG_TABLE_NAME CONTIENE EL NOMBRE DE LA TABLA EN  QUE SE EJECUTOLA ACCION
		****************************************************************************/
		CASE TG_TABLE_NAME
			WHEN 'asignacion_fiscales' THEN			
				condicion:=1;
			
			
				anio_servidor:=(select cast(Extract(year FROM now()) as integer));
				if(SELECT count(*)  FROM datos.correlativos_actas WHERE id=condicion AND  anio=anio_servidor)>0 THEN

					nautori=(select correlativo  FROM datos.correlativos_actas where id=condicion AND  anio=anio_servidor);				

					UPDATE datos.asignacion_fiscales
					SET 
					nro_autorizacion=(nautori||'-'||anio_servidor)
					WHERE id=new.id;

					UPDATE datos.correlativos_actas
					SET  correlativo=nautori+1
					WHERE id=condicion;
				ELSE
					

					UPDATE datos.asignacion_fiscales
					SET 
					nro_autorizacion=(1||'-'||(anio_servidor))
					WHERE id=new.id;

					UPDATE datos.correlativos_actas
					SET  correlativo=2,anio=(select (Extract(year FROM now())))
					WHERE id=condicion;
						
				
				END IF;
			WHEN 'actas_reparo' THEN
				/*condicion:='act-rpfis-1';*/
			
			
				anio_servidor:=(select cast(Extract(year FROM now()) as integer));
				if(SELECT count(*)  FROM datos.correlativos_actas WHERE tipo='act-rpfis-1' AND  anio=anio_servidor)>0 THEN

					nautori=(select correlativo  FROM datos.correlativos_actas where tipo='act-rpfis-1' AND  anio=anio_servidor);				

					UPDATE datos.actas_reparo
					SET 
					numero=(nautori||'-'||anio_servidor)
					WHERE id=new.id;

					UPDATE datos.correlativos_actas
					SET  correlativo=nautori+1
					WHERE tipo='act-rpfis-1';
				ELSE
					

					UPDATE datos.actas_reparo
					SET 
					numero=(1||'-'||(anio_servidor))
					WHERE id=new.id;

					UPDATE datos.correlativos_actas
					SET  correlativo=2,anio=(select (Extract(year FROM now())))
					WHERE tipo='act-rpfis-1';
						
				
				END IF;	
				
		END CASE;			


	END IF;
	



RETURN NULL;
END;


$$;


ALTER FUNCTION datos.crea_correlativo_actas() OWNER TO postgres;

--
-- TOC entry 332 (class 1255 OID 128365)
-- Dependencies: 9 1022
-- Name: pa_ActUsuBitDel(text, integer, integer); Type: FUNCTION; Schema: datos; Owner: postgres
--

CREATE FUNCTION "pa_ActUsuBitDel"("Tabla" text, "ValorID" integer, "IDUsuario" integer, OUT "Actualizado" boolean) RETURNS boolean
    LANGUAGE plpgsql STRICT COST 1
    AS $$
    DECLARE
        Query TEXT;
        FilasAfectadas INTEGER;
BEGIN
    --Contruimos el Query
    Query := 'UPDATE historial."bitacora" SET "usuarioid"=' || CAST("IDUsuario" AS TEXT) || ' WHERE "tabla"=' || '''' || "Tabla" || '''' || ' AND "accion"=2 AND "valdelid"=' || CAST("ValorID" AS TEXT);

    --Ejecutamos
    EXECUTE Query;

    GET DIAGNOSTICS FilasAfectadas = ROW_COUNT;

    --Verificamos si se actualizo el registro buscado
    IF FilasAfectadas>=1 THEN
       --Se actualizo
        "Actualizado" := True;
    ELSE
        --No se actualizo
        "Actualizado" := False;
    END IF;
END;
$$;


ALTER FUNCTION datos."pa_ActUsuBitDel"("Tabla" text, "ValorID" integer, "IDUsuario" integer, OUT "Actualizado" boolean) OWNER TO postgres;

--
-- TOC entry 3334 (class 0 OID 0)
-- Dependencies: 332
-- Name: FUNCTION "pa_ActUsuBitDel"("Tabla" text, "ValorID" integer, "IDUsuario" integer, OUT "Actualizado" boolean); Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON FUNCTION "pa_ActUsuBitDel"("Tabla" text, "ValorID" integer, "IDUsuario" integer, OUT "Actualizado" boolean) IS 'Funcion que actualiza el IDUsuario en la bitacora cuando se elimina un registro. Esta funcion tiene que ser llamada inmediatamente despues de eliminar una fila en cualquier tabla';


--
-- TOC entry 333 (class 1255 OID 128366)
-- Dependencies: 1022 9
-- Name: pa_LoginContribu(text, text); Type: FUNCTION; Schema: datos; Owner: postgres
--

CREATE FUNCTION "pa_LoginContribu"("LoginUsuario" text, "PasswordUsuario" text, OUT "IDUsuarioContribuyente" integer, OUT "NombreUsuario" text, OUT "IDTipoUsuario" integer, OUT "UltimoLogin" timestamp without time zone) RETURNS record
    LANGUAGE plpgsql STRICT COST 1
    AS $$
DECLARE
    IDRegistro INTEGER;
BEGIN
    --Ejecutamos query
    SELECT "ID", "nombre", "conusutiid", "ultlogin" FROM datos."conusu" WHERE "login"=TRIM("LoginUsuario") AND "password"=TRIM("PasswordUsuario") AND "inactivo"=False INTO "IDUsuarioContribuyente", "NombreUsuario", "IDTipoUsuario", "UltimoLogin";

    --Verificamos si se hizo login para cambiar la fecha de login
    IF NOT "NombreUsuario" IS NULL THEN
        --Deshabilitamos el trigger
        ALTER TABLE datos."conusu" DISABLE TRIGGER "TG_ConUsu_Bitacora";

        --Actualizamos fecha de ultimo login
        UPDATE datos."conusu" SET "ultlogin"=LOCALTIMESTAMP WHERE "id"="IDUsuarioContribuyente";

        --Habilitamos trigger
        ALTER TABLE datos."conusu" ENABLE TRIGGER "TG_ConUsu_Bitacora";
    END IF;
END
$$;


ALTER FUNCTION datos."pa_LoginContribu"("LoginUsuario" text, "PasswordUsuario" text, OUT "IDUsuarioContribuyente" integer, OUT "NombreUsuario" text, OUT "IDTipoUsuario" integer, OUT "UltimoLogin" timestamp without time zone) OWNER TO postgres;

--
-- TOC entry 3335 (class 0 OID 0)
-- Dependencies: 333
-- Name: FUNCTION "pa_LoginContribu"("LoginUsuario" text, "PasswordUsuario" text, OUT "IDUsuarioContribuyente" integer, OUT "NombreUsuario" text, OUT "IDTipoUsuario" integer, OUT "UltimoLogin" timestamp without time zone); Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON FUNCTION "pa_LoginContribu"("LoginUsuario" text, "PasswordUsuario" text, OUT "IDUsuarioContribuyente" integer, OUT "NombreUsuario" text, OUT "IDTipoUsuario" integer, OUT "UltimoLogin" timestamp without time zone) IS 'Funcion para hacer login de un contribuyente';


--
-- TOC entry 334 (class 1255 OID 128367)
-- Dependencies: 9 1022
-- Name: pa_LoginUsFonpro(text, text); Type: FUNCTION; Schema: datos; Owner: postgres
--

CREATE FUNCTION "pa_LoginUsFonpro"("LoginUsuario" text, "PasswordUsuario" text, OUT "IDUsuarioFonprocine" integer, OUT "NombreUsuario" text, OUT "IDPerfilUsuario" integer, OUT "UltimoLogin" timestamp without time zone) RETURNS record
    LANGUAGE plpgsql STRICT COST 1
    AS $$
DECLARE
    IDRegistro INTEGER;
BEGIN
    --Ejecutamos query
    SELECT "id", "nombre", "perusuid", "ultlogin" FROM datos."usfonpro" WHERE "login"=TRIM("LoginUsuario") AND "password"=TRIM("PasswordUsuario") AND "inactivo"=False INTO "IDUsuarioFonprocine", "NombreUsuario", "IDPerfilUsuario", "UltimoLogin";

    --Verificamos si se hizo login para cambiar la fecha de login
    IF NOT "NombreUsuario" IS NULL THEN
        --Deshabilitamos el trigger
        ALTER TABLE datos."usfonpro" DISABLE TRIGGER "TG_UsFonpro_Bitacora";

        --Actualizamos fecha de ultimo login
        UPDATE datos."usfonpro" SET "ultlogin"=LOCALTIMESTAMP WHERE "ID"="IDUsuarioFonprocine";

        --Habilitamos trigger
        ALTER TABLE datos."usfonpro" ENABLE TRIGGER "TG_UsFonpro_Bitacora";
    END IF;
END
$$;


ALTER FUNCTION datos."pa_LoginUsFonpro"("LoginUsuario" text, "PasswordUsuario" text, OUT "IDUsuarioFonprocine" integer, OUT "NombreUsuario" text, OUT "IDPerfilUsuario" integer, OUT "UltimoLogin" timestamp without time zone) OWNER TO postgres;

--
-- TOC entry 3336 (class 0 OID 0)
-- Dependencies: 334
-- Name: FUNCTION "pa_LoginUsFonpro"("LoginUsuario" text, "PasswordUsuario" text, OUT "IDUsuarioFonprocine" integer, OUT "NombreUsuario" text, OUT "IDPerfilUsuario" integer, OUT "UltimoLogin" timestamp without time zone); Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON FUNCTION "pa_LoginUsFonpro"("LoginUsuario" text, "PasswordUsuario" text, OUT "IDUsuarioFonprocine" integer, OUT "NombreUsuario" text, OUT "IDPerfilUsuario" integer, OUT "UltimoLogin" timestamp without time zone) IS 'Funcion para hacer login de un usuario Fonprocine';


--
-- TOC entry 335 (class 1255 OID 128368)
-- Dependencies: 1022 9
-- Name: pa_TokenActivoContribu(integer, integer); Type: FUNCTION; Schema: datos; Owner: postgres
--

CREATE FUNCTION "pa_TokenActivoContribu"("IDToken" integer, "IDUsuario" integer, OUT "Activo" boolean, OUT "FechaCreacion" timestamp without time zone, OUT "FechaCaducidad" timestamp without time zone, OUT "FechaHoraServidor" timestamp without time zone, OUT "Observaciones" text) RETURNS record
    LANGUAGE plpgsql STRICT COST 1
    AS $$
    DECLARE
        Usado BOOLEAN;
        UsuarioInactivo BOOLEAN;
BEGIN
    --Fecha hora del servidor
    "FechaHoraServidor" := LOCALTIMESTAMP;
    
    --Buscamos el Token
    SELECT "fechacrea", "fechacadu", "usado" FROM datos."conusuto" WHERE "id"="IDToken" AND "conusuid"="IDUsuario" INTO "FechaCreacion", "FechaCaducidad", Usado;

    --Verificamos si el token existe para terminar de poblar las variables de retorno
    IF NOT "FechaCreacion" IS NULL THEN
        --Existe

        --Verificamos si el token esta usado
        IF Usado=True THEN
            --Token ya usado
            "Activo" := false;
            "Observaciones" := 'El Token solicitado ya fue usado';
        ELSE
            --Token no usuado

            --Verificamos si esta caducado
            IF "FechaCaducidad"<"FechaHoraServidor" THEN
                --Token no caducado

                --Verificamos si el usuario propietario del token esta activo
                SELECT "Inactivo" FROM datos."ConUsu" WHERE "IDConUsu"="IDUsuario" INTO UsuarioInactivo;
                IF UsuarioInactivo=False Then
                    --Usuario activo
                    "Activo" := true;
                    "Observaciones" := '';
                ELSE
                    --Usuario inactivo
                    "Activo" := false;
                    "Observaciones" := 'Usuario inactivo';
                END IF;
            ELSE
	        --Token caducado
               "Activo" := false;
               "Observaciones" := 'El Token solicitado está caducado';
            END IF;
        END IF;
    ELSE
        --No Existe
        "Activo" := false;
        "Observaciones" := 'El Token solicitado no existe';
    END IF;
END;
$$;


ALTER FUNCTION datos."pa_TokenActivoContribu"("IDToken" integer, "IDUsuario" integer, OUT "Activo" boolean, OUT "FechaCreacion" timestamp without time zone, OUT "FechaCaducidad" timestamp without time zone, OUT "FechaHoraServidor" timestamp without time zone, OUT "Observaciones" text) OWNER TO postgres;

--
-- TOC entry 3337 (class 0 OID 0)
-- Dependencies: 335
-- Name: FUNCTION "pa_TokenActivoContribu"("IDToken" integer, "IDUsuario" integer, OUT "Activo" boolean, OUT "FechaCreacion" timestamp without time zone, OUT "FechaCaducidad" timestamp without time zone, OUT "FechaHoraServidor" timestamp without time zone, OUT "Observaciones" text); Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON FUNCTION "pa_TokenActivoContribu"("IDToken" integer, "IDUsuario" integer, OUT "Activo" boolean, OUT "FechaCreacion" timestamp without time zone, OUT "FechaCaducidad" timestamp without time zone, OUT "FechaHoraServidor" timestamp without time zone, OUT "Observaciones" text) IS 'Funcion que verifica si el token de usuario de contribuyente buscado esta activo a la fecha hora del servidor';


--
-- TOC entry 336 (class 1255 OID 128369)
-- Dependencies: 1022 9
-- Name: pa_TokenActivoUsFonpro(integer, integer); Type: FUNCTION; Schema: datos; Owner: postgres
--

CREATE FUNCTION "pa_TokenActivoUsFonpro"("IDToken" integer, "IDUsuario" integer, OUT "Activo" boolean, OUT "FechaCreacion" timestamp without time zone, OUT "FechaCaducidad" timestamp without time zone, OUT "FechaHoraServidor" timestamp without time zone, OUT "Observaciones" text) RETURNS record
    LANGUAGE plpgsql STRICT COST 1
    AS $$
    DECLARE
        Usado BOOLEAN;
        UsuarioInactivo BOOLEAN;
BEGIN
    --Fecha hora del servidor
    "FechaHoraServidor" := LOCALTIMESTAMP;
    
    --Buscamos el Token
    SELECT "fechacrea", "fechacadu", "usado" FROM datos."usfonpto" WHERE "id"="IDToken" AND "usfonproid"="IDUsuario" INTO "FechaCreacion", "FechaCaducidad", Usado;

    --Verificamos si el token existe para terminar de poblar las variables de retorno
    IF NOT "FechaCreacion" IS NULL THEN
        --Existe

        --Verificamos si el token esta usado
        IF Usado=True THEN
            --Token ya usado
            "Activo" := false;
            "Observaciones" := 'El Token solicitado ya fue usado';
        ELSE
            --Token no usuado

            --Verificamos si esta caducado
            IF "FechaCaducidad"<"FechaHoraServidor" THEN
                --Token no caducado

                --Verificamos si el usuario propietario del token esta activo
                SELECT "Inactivo" FROM datos."UsFonpro" WHERE "IDUsFonpro"="IDUsuario" INTO UsuarioInactivo;
                IF UsuarioInactivo=False Then
                    --Usuario activo
                    "Activo" := true;
                    "Observaciones" := '';
                ELSE
                    --Usuario inactivo
                    "Activo" := false;
                    "Observaciones" := 'Usuario inactivo';
                END IF;
            ELSE
	        --Token caducado
               "Activo" := false;
               "Observaciones" := 'El Token solicitado está caducado';
            END IF;
        END IF;
    ELSE
        --No Existe
        "Activo" := false;
        "Observaciones" := 'El Token solicitado no existe';
    END IF;
END;
$$;


ALTER FUNCTION datos."pa_TokenActivoUsFonpro"("IDToken" integer, "IDUsuario" integer, OUT "Activo" boolean, OUT "FechaCreacion" timestamp without time zone, OUT "FechaCaducidad" timestamp without time zone, OUT "FechaHoraServidor" timestamp without time zone, OUT "Observaciones" text) OWNER TO postgres;

--
-- TOC entry 3338 (class 0 OID 0)
-- Dependencies: 336
-- Name: FUNCTION "pa_TokenActivoUsFonpro"("IDToken" integer, "IDUsuario" integer, OUT "Activo" boolean, OUT "FechaCreacion" timestamp without time zone, OUT "FechaCaducidad" timestamp without time zone, OUT "FechaHoraServidor" timestamp without time zone, OUT "Observaciones" text); Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON FUNCTION "pa_TokenActivoUsFonpro"("IDToken" integer, "IDUsuario" integer, OUT "Activo" boolean, OUT "FechaCreacion" timestamp without time zone, OUT "FechaCaducidad" timestamp without time zone, OUT "FechaHoraServidor" timestamp without time zone, OUT "Observaciones" text) IS 'Funcion que verifica si el token de usuario de forprocine buscado esta activo a la fecha hora del servidor';


--
-- TOC entry 337 (class 1255 OID 128370)
-- Dependencies: 1022 9
-- Name: retorna-alicuota(integer); Type: FUNCTION; Schema: datos; Owner: postgres
--

CREATE FUNCTION "retorna-alicuota"(integer) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
declare
tcalculo integer;
BEGIN

tcalculo=(SELECT tipocalc FROM datos.alicimp where tipocontid=$1);



END;
$_$;


ALTER FUNCTION datos."retorna-alicuota"(integer) OWNER TO postgres;

--
-- TOC entry 338 (class 1255 OID 128371)
-- Dependencies: 1022 9
-- Name: tf_AsiendoD_ActualizaDebeHaber_Asiento(); Type: FUNCTION; Schema: datos; Owner: postgres
--

CREATE FUNCTION "tf_AsiendoD_ActualizaDebeHaber_Asiento"() RETURNS trigger
    LANGUAGE plpgsql STRICT COST 1
    AS $$
    DECLARE
        numDebe NUMERIC(18,2);
        numHaber NUMERIC(18,2);
BEGIN
    --Calculamos el Debe
    if TG_OP='DELETE' Then
        SELECT SUM("monto") FROM datos."asientod" WHERE "asientoid"=OLD."asientoid" AND "sentido"=0 INTO numDebe;
    Else
        SELECT SUM("monto") FROM datos."asientod" WHERE "asientoid"=NEW."asientoid" AND "sentido"=0 INTO numDebe;
    End If;

    --Calculamos el Haber
    if TG_OP='DELETE' Then
        SELECT SUM("monto") FROM datos."asientod" WHERE "asientoid"=OLD."asientoid" AND "sentido"=1 INTO numHaber;
    Else
        SELECT SUM("monto") FROM datos."asientod" WHERE "asientoid"=NEW."asientoid" AND "sentido"=1 INTO numHaber;
    End if;

    --Actualizamos Debe y Haber de la tabla Asiento
    if TG_OP='DELETE' Then
        UPDATE datos."asiento" SET "debe"=Coalesce(numDebe,0), "haber"=Coalesce(numHaber,0) WHERE "ID"=OLD."asientoid";
    Else
        UPDATE datos."asiento" SET "debe"=Coalesce(numDebe,0), "haber"=Coalesce(numHaber,0) WHERE "ID"=NEW."asientoid";
    End if;

    --Retornamos
    Return NULL;
END
$$;


ALTER FUNCTION datos."tf_AsiendoD_ActualizaDebeHaber_Asiento"() OWNER TO postgres;

--
-- TOC entry 3339 (class 0 OID 0)
-- Dependencies: 338
-- Name: FUNCTION "tf_AsiendoD_ActualizaDebeHaber_Asiento"(); Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON FUNCTION "tf_AsiendoD_ActualizaDebeHaber_Asiento"() IS 'Funcion de trigger que actualiza las columnas de debe y haber de la tabla Asientos';


--
-- TOC entry 330 (class 1255 OID 128372)
-- Dependencies: 9 1022
-- Name: tf_Asiento_ActualizaPeriodo(); Type: FUNCTION; Schema: datos; Owner: postgres
--

CREATE FUNCTION "tf_Asiento_ActualizaPeriodo"() RETURNS trigger
    LANGUAGE plpgsql STRICT COST 1
    AS $$
BEGIN
    --Calculamos el mes de la fecha
    NEW."mes" := Extract(Month FROM NEW."fecha");
    
    --Calculamos el año de la fecha
    NEW."ano" := Extract(Year FROM NEW."fecha");
    
    --Retornamos fila NEW
    Return NEW;
END
$$;


ALTER FUNCTION datos."tf_Asiento_ActualizaPeriodo"() OWNER TO postgres;

--
-- TOC entry 3340 (class 0 OID 0)
-- Dependencies: 330
-- Name: FUNCTION "tf_Asiento_ActualizaPeriodo"(); Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON FUNCTION "tf_Asiento_ActualizaPeriodo"() IS 'Funcion de trigger para actualizar las columnas de Mes y Ano, a partir de la fecha especificada';


--
-- TOC entry 339 (class 1255 OID 128373)
-- Dependencies: 1022 9
-- Name: tf_Asiento_ActualizaSaldo(); Type: FUNCTION; Schema: datos; Owner: postgres
--

CREATE FUNCTION "tf_Asiento_ActualizaSaldo"() RETURNS trigger
    LANGUAGE plpgsql STRICT COST 1
    AS $$
BEGIN
    --Actualizamos Saldo
    NEW."saldo" := NEW."debe" - NEW."haber";

    --Retornamos resultado
    Return NEW;
END
$$;


ALTER FUNCTION datos."tf_Asiento_ActualizaSaldo"() OWNER TO postgres;

--
-- TOC entry 3341 (class 0 OID 0)
-- Dependencies: 339
-- Name: FUNCTION "tf_Asiento_ActualizaSaldo"(); Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON FUNCTION "tf_Asiento_ActualizaSaldo"() IS 'Funcion que actualiza el saldo de la tabla asiento';


--
-- TOC entry 340 (class 1255 OID 128374)
-- Dependencies: 1022 9
-- Name: tf_Bitacora(); Type: FUNCTION; Schema: datos; Owner: postgres
--

CREATE FUNCTION "tf_Bitacora"() RETURNS trigger
    LANGUAGE plpgsql STRICT COST 1
    AS $$
    DECLARE
        Query VARCHAR;
        Columna TEXT;
        Campos_Cursor CURSOR FOR SELECT column_name FROM information_schema.columns WHERE table_name=TG_TABLE_NAME ORDER BY ordinal_position;
	DatosNew hstore;
	DatosOld hstore;
	ValorPK TEXT;
BEGIN
    --Iniciamos contruccion del query que insertara datos en la bitacora
    IF TG_OP = 'INSERT' THEN
        Query := 'INSERT INTO historial."bitacora" ("fecha","tabla","idusuario","accion","datosnew","datosold","datosdel","valdelid","ip") VALUES (LOCALTIMESTAMP,' || '''' || TG_TABLE_NAME || '''' || ',' || CAST(NEW."usuarioid" AS VARCHAR) || ',0,' || '''';    
    END IF;
    IF TG_OP = 'UPDATE' THEN
        Query := 'INSERT INTO historial."bitacora" ("fecha","tabla","idusuario","accion","datosnew","datosold","datosdel","valdelid","ip") VALUES (LOCALTIMESTAMP,' || '''' || TG_TABLE_NAME || '''' || ',' || CAST(NEW."usuarioid" AS VARCHAR) || ',1,' || '''';    
    END IF;
    IF TG_OP = 'DELETE' THEN
        Query := 'INSERT INTO historial."bitacora" ("fecha","tabla","idusuario","accion","datosnew","datosold","datosdel","valdelid","ip") VALUES (LOCALTIMESTAMP,' || '''' || TG_TABLE_NAME || '''' || ',NULL,2,NULL,NULL,' || '''';    
    END IF;

    --Iniciamos hstore con los NEW
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        DatosNew := hstore(NEW);
    END IF;

    --Iniciamos hstore con los OLD
    IF TG_OP = 'UPDATE' OR TG_OP = 'DELETE' THEN
        DatosOld := hstore(OLD);
    END IF;
    
    --Ciclamos cursor para construir nombre de campos y valores del NEW
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        -- Abrimos cursor para procesar los valores NEW
        OPEN Campos_Cursor;

        --Nos posicionamos en la primera fila
        FETCH NEXT FROM Campos_Cursor INTO Columna;

        --Ciclamos
        LOOP
            Query := Query || Columna || '=' || datos."pa_BuscaItemHstore"(DatosNew, Columna) AS VARCHAR;
        
            -- Obtenemos nombre de campo
            FETCH NEXT FROM Campos_Cursor INTO Columna;

            --Preguntamos si existe el valor, en caso de no existir salimos del bucle
            IF NOT FOUND THEN
                EXIT;
            ELSE
                Query := Query || ' <||> ';
            END IF; 
        END LOOP;

        --Completamos query
        IF TG_OP = 'INSERT' THEN
	    Query := Query || '''' || ',NULL,NULL,NULL,' || '''' || CAST(NEW."ip" AS VARCHAR) || '''' || ')';
        END IF;

        IF TG_OP = 'UPDATE' THEN
	    Query := Query || '''' || ',' || '''';
        END IF;

        -- cerramos cursor
        CLOSE Campos_Cursor;
    END IF;


    --Ciclamos cursor para construir nombre de campos y valores del OLD
    IF TG_OP = 'UPDATE' OR TG_OP = 'DELETE' THEN
        -- Abrimos cursor para procesar los valores OLD
        OPEN Campos_Cursor;

        --Nos posicionamos en la primera fila
        FETCH NEXT FROM Campos_Cursor INTO Columna;

        --Capturamos valor del la clave primaria
        ValorPK := datos."pa_BuscaItemHstore"(DatosOld, Columna);

        --Ciclamos
        LOOP
            Query := Query || Columna || '=' || datos."pa_BuscaItemHstore"(DatosOld, Columna) AS VARCHAR;
        
            -- Obtenemos nombre de campo
            FETCH NEXT FROM Campos_Cursor INTO Columna;

            --Preguntamos si existe el valor, en caso de no existir salimos del bucle
            IF NOT FOUND THEN
                EXIT;
            ELSE
                Query := Query || ' <||> ';
            END IF; 
        END LOOP;

        --Completamos query
        IF TG_OP = 'UPDATE' THEN
	    Query := Query || '''' || ',NULL,NULL,' || '''' || CAST(NEW."ip" AS VARCHAR) || '''' || ')';
        END IF;

        IF TG_OP = 'DELETE' THEN
	    Query := Query || '''' || ',' || ValorPK || ',NULL)';
        END IF;

        -- cerramos cursor
        CLOSE Campos_Cursor;
    END IF;

    --Ejecutamos Insert dentro de la tabla de bitacora
    EXECUTE Query;

    RETURN NULL;
END
$$;


ALTER FUNCTION datos."tf_Bitacora"() OWNER TO postgres;

--
-- TOC entry 3342 (class 0 OID 0)
-- Dependencies: 340
-- Name: FUNCTION "tf_Bitacora"(); Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON FUNCTION "tf_Bitacora"() IS 'Trigger para el insert de datos en la bitacora de cambios';


SET search_path = seg, pg_catalog;

--
-- TOC entry 341 (class 1255 OID 128375)
-- Dependencies: 7 1022
-- Name: verificaperfil(); Type: FUNCTION; Schema: seg; Owner: postgres
--

CREATE FUNCTION verificaperfil() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
modulo integer;
BEGIN
 IF (TG_OP = 'INSERT') THEN
--DELETE FROM seg.tbl_permiso WHERE id_rol=new.id_rol;
	IF NOT EXISTS (SELECT id_modulo FROM seg.tbl_permiso where id_rol=new.id_rol and id_modulo=new.id_modulo)THEN
		

		INSERT INTO seg.tbl_permiso(
		id_modulo, id_rol, int_permiso)
		VALUES (new.id_modulo,new.id_rol,new.int_permiso);

	ELSE
		UPDATE seg.tbl_permiso
			SET  bln_borrado=true
		WHERE id_rol=new.id_rol and id_modulo=new.id_modulo;

		INSERT INTO seg.tbl_permiso(
		id_modulo, id_rol, int_permiso)
		VALUES (new.id_modulo,new.id_rol,new.int_permiso);

	END IF;
/*INSERT INTO seg.tbl_permiso(
		id_modulo, id_rol, int_permiso)
		VALUES (new.id_modulo,new.id_rol,new.int_permiso);*/
	

END IF;

	

RETURN NULL;
END;
$$;


ALTER FUNCTION seg.verificaperfil() OWNER TO postgres;

SET search_path = datos, pg_catalog;

--
-- TOC entry 166 (class 1259 OID 128376)
-- Dependencies: 9
-- Name: Accionis_ID_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE "Accionis_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos."Accionis_ID_seq" OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 167 (class 1259 OID 128378)
-- Dependencies: 9
-- Name: actiecon; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE actiecon (
    id integer NOT NULL,
    nombre character varying(300) NOT NULL,
    usuarioid integer NOT NULL,
    ip character varying(15) NOT NULL
);


ALTER TABLE datos.actiecon OWNER TO postgres;

--
-- TOC entry 3343 (class 0 OID 0)
-- Dependencies: 167
-- Name: TABLE actiecon; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE actiecon IS 'Tabla con las actividades económicas';


--
-- TOC entry 3344 (class 0 OID 0)
-- Dependencies: 167
-- Name: COLUMN actiecon.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN actiecon.id IS 'Identificador del tipo de actividad económica';


--
-- TOC entry 3345 (class 0 OID 0)
-- Dependencies: 167
-- Name: COLUMN actiecon.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN actiecon.nombre IS 'Nombre de la actividad económica';


--
-- TOC entry 3346 (class 0 OID 0)
-- Dependencies: 167
-- Name: COLUMN actiecon.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN actiecon.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3347 (class 0 OID 0)
-- Dependencies: 167
-- Name: COLUMN actiecon.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN actiecon.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 168 (class 1259 OID 128381)
-- Dependencies: 9 167
-- Name: ActiEcon_IDActiEcon_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE "ActiEcon_IDActiEcon_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos."ActiEcon_IDActiEcon_seq" OWNER TO postgres;

--
-- TOC entry 3349 (class 0 OID 0)
-- Dependencies: 168
-- Name: ActiEcon_IDActiEcon_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "ActiEcon_IDActiEcon_seq" OWNED BY actiecon.id;


--
-- TOC entry 169 (class 1259 OID 128383)
-- Dependencies: 2361 2362 2363 2364 2365 2366 2367 2368 2369 2370 2371 9
-- Name: alicimp; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE alicimp (
    id integer NOT NULL,
    tipocontid integer NOT NULL,
    ano smallint DEFAULT 0 NOT NULL,
    alicuota numeric(18,2) DEFAULT 0 NOT NULL,
    tipocalc smallint DEFAULT 0 NOT NULL,
    valorut numeric(18,2) DEFAULT 0 NOT NULL,
    liminf1 numeric(18,2) DEFAULT 0 NOT NULL,
    limsup1 numeric(18,2),
    alicuota1 numeric(18,2) DEFAULT 0 NOT NULL,
    liminf2 numeric(18,2),
    limsup2 numeric(18,2),
    alicuota2 numeric(18,2),
    liminf3 numeric(18,2) DEFAULT 0 NOT NULL,
    limsup3 numeric(18,2),
    alicuota3 numeric(18,2),
    liminf4 numeric(18,2) DEFAULT 0 NOT NULL,
    limsup4 numeric(18,2) DEFAULT 0 NOT NULL,
    alicuota4 numeric(18,2),
    liminf5 numeric(18,2) DEFAULT 0 NOT NULL,
    limsup5 numeric(18,2),
    alicuota5 numeric(18,2) DEFAULT 0 NOT NULL,
    usuarioid integer NOT NULL,
    ip character varying(15) NOT NULL
);


ALTER TABLE datos.alicimp OWNER TO postgres;

--
-- TOC entry 3350 (class 0 OID 0)
-- Dependencies: 169
-- Name: TABLE alicimp; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE alicimp IS 'Tabla con los datos de las alicuotas impositivas';


--
-- TOC entry 3351 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.id IS 'Identificador de la alicuota';


--
-- TOC entry 3352 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.tipocontid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.tipocontid IS 'Identificador del tipo de contribuyente';


--
-- TOC entry 3353 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.ano; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.ano IS 'Ano en la que aplica la alicuota';


--
-- TOC entry 3354 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.alicuota; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.alicuota IS '% de la alicuota a pagar';


--
-- TOC entry 3355 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.tipocalc; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.tipocalc IS 'Tipo de calculo a usar para seleccionar la alicuota.
0=Aplicar alicuota directamente.
1=Aplicar alicuota de acuerdo al limite inferior en UT.
2=Aplicar alicuota de acuerdo a rangos en UT';


--
-- TOC entry 3356 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.valorut; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.valorut IS 'Limite inferior en UT al cual se le aplica la alicuota. Aplica para TipoCalc=1';


--
-- TOC entry 3357 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.liminf1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.liminf1 IS 'Limite inferior 1 en UT para aplicacion de alicuota por rango. TipoCalc=2';


--
-- TOC entry 3358 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.limsup1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.limsup1 IS 'Limite superior 1 en UT para aplicacion de alicuota por rango. TipoCalc=2';


--
-- TOC entry 3359 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.alicuota1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.alicuota1 IS 'Alicuota del rango 1. TipoCalc=2';


--
-- TOC entry 3360 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.liminf2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.liminf2 IS 'Limite inferior 2 en UT para aplicacion de alicuota por rango. TipoCalc=2';


--
-- TOC entry 3361 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.limsup2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.limsup2 IS 'Limite superior 2 en UT para aplicacion de alicuota por rango. TipoCalc=2';


--
-- TOC entry 3362 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.alicuota2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.alicuota2 IS 'Alicuota del rango 2. TipoCalc=2';


--
-- TOC entry 3363 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.liminf3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.liminf3 IS 'Limite inferior 3 en UT para aplicacion de alicuota por rango. TipoCalc=2';


--
-- TOC entry 3364 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.limsup3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.limsup3 IS 'Limite superior 3 en UT para aplicacion de alicuota por rango. TipoCalc=2';


--
-- TOC entry 3365 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.alicuota3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.alicuota3 IS 'Alicuota del rango 3. TipoCalc=2';


--
-- TOC entry 3366 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.liminf4; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.liminf4 IS 'Limite inferior 4 en UT para aplicacion de alicuota por rango. TipoCalc=2';


--
-- TOC entry 3367 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.limsup4; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.limsup4 IS 'Limite superior 4 en UT para aplicacion de alicuota por rango. TipoCalc=2';


--
-- TOC entry 3368 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.alicuota4; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.alicuota4 IS 'Alicuota del rango 4. TipoCalc=2';


--
-- TOC entry 3369 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.liminf5; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.liminf5 IS 'Limite inferior 5 en UT para aplicacion de alicuota por rango. TipoCalc=2';


--
-- TOC entry 3370 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.limsup5; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.limsup5 IS 'Limite superior 5 en UT para aplicacion de alicuota por rango. TipoCalc=2';


--
-- TOC entry 3371 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.alicuota5; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.alicuota5 IS 'Alicuota del rango 5. TipoCalc=2';


--
-- TOC entry 3372 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.usuarioid IS 'Identificador del ultimo usuario en crear o modificar un registro';


--
-- TOC entry 3373 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 170 (class 1259 OID 128397)
-- Dependencies: 169 9
-- Name: AlicImp_IDAlicImp_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE "AlicImp_IDAlicImp_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos."AlicImp_IDAlicImp_seq" OWNER TO postgres;

--
-- TOC entry 3374 (class 0 OID 0)
-- Dependencies: 170
-- Name: AlicImp_IDAlicImp_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "AlicImp_IDAlicImp_seq" OWNED BY alicimp.id;


--
-- TOC entry 171 (class 1259 OID 128399)
-- Dependencies: 2373 2374 9
-- Name: asientod; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE asientod (
    id integer NOT NULL,
    asientoid integer NOT NULL,
    fecha date NOT NULL,
    cuenta character varying(14) NOT NULL,
    monto numeric(18,2) DEFAULT 0 NOT NULL,
    sentido smallint DEFAULT 0 NOT NULL,
    referencia character varying(5) NOT NULL,
    comentar character varying(500),
    usuarioid integer NOT NULL,
    ip character varying(15) NOT NULL
);


ALTER TABLE datos.asientod OWNER TO postgres;

--
-- TOC entry 3375 (class 0 OID 0)
-- Dependencies: 171
-- Name: TABLE asientod; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE asientod IS 'Tabla con el detalle de los asientos';


--
-- TOC entry 3376 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN asientod.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientod.id IS 'Identificador unico de registro';


--
-- TOC entry 3377 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN asientod.asientoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientod.asientoid IS 'Identificador del asiento';


--
-- TOC entry 3378 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN asientod.fecha; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientod.fecha IS 'Fecha de la transaccion';


--
-- TOC entry 3379 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN asientod.cuenta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientod.cuenta IS 'Cuenta contable';


--
-- TOC entry 3380 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN asientod.monto; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientod.monto IS 'Monto de la transaccion';


--
-- TOC entry 3381 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN asientod.sentido; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientod.sentido IS 'Sentido del monto. 0=Debe / 1=Haber';


--
-- TOC entry 3382 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN asientod.referencia; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientod.referencia IS 'Referencia de la linea';


--
-- TOC entry 3383 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN asientod.comentar; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientod.comentar IS 'Comentarios u observaciones';


--
-- TOC entry 3384 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN asientod.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientod.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3385 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN asientod.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientod.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 172 (class 1259 OID 128407)
-- Dependencies: 171 9
-- Name: AsientoD_IDAsientoD_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE "AsientoD_IDAsientoD_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos."AsientoD_IDAsientoD_seq" OWNER TO postgres;

--
-- TOC entry 3386 (class 0 OID 0)
-- Dependencies: 172
-- Name: AsientoD_IDAsientoD_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "AsientoD_IDAsientoD_seq" OWNED BY asientod.id;


--
-- TOC entry 173 (class 1259 OID 128409)
-- Dependencies: 9
-- Name: Asiento_IDAsiento_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE "Asiento_IDAsiento_seq"
    START WITH 67
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos."Asiento_IDAsiento_seq" OWNER TO postgres;

--
-- TOC entry 174 (class 1259 OID 128411)
-- Dependencies: 9
-- Name: bacuenta; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE bacuenta (
    id integer NOT NULL,
    bancoid integer NOT NULL,
    cuenta character varying(20) NOT NULL,
    usuarioid integer NOT NULL,
    ip character varying(15) NOT NULL
);


ALTER TABLE datos.bacuenta OWNER TO postgres;

--
-- TOC entry 3387 (class 0 OID 0)
-- Dependencies: 174
-- Name: TABLE bacuenta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE bacuenta IS 'Tabla con los datos de las cuentas bancarias';


--
-- TOC entry 3388 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN bacuenta.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN bacuenta.id IS 'Identificador unico de registro';


--
-- TOC entry 3389 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN bacuenta.bancoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN bacuenta.bancoid IS 'Identificador del banco';


--
-- TOC entry 3390 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN bacuenta.cuenta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN bacuenta.cuenta IS 'Numero de cuenta bancaria';


--
-- TOC entry 3391 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN bacuenta.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN bacuenta.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3392 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN bacuenta.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN bacuenta.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 175 (class 1259 OID 128414)
-- Dependencies: 9 174
-- Name: BaCuenta_IDBaCuenta_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE "BaCuenta_IDBaCuenta_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos."BaCuenta_IDBaCuenta_seq" OWNER TO postgres;

--
-- TOC entry 3393 (class 0 OID 0)
-- Dependencies: 175
-- Name: BaCuenta_IDBaCuenta_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "BaCuenta_IDBaCuenta_seq" OWNED BY bacuenta.id;


--
-- TOC entry 176 (class 1259 OID 128416)
-- Dependencies: 9
-- Name: bancos; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE bancos (
    id integer NOT NULL,
    nombre character varying(100) NOT NULL,
    usuarioid integer NOT NULL,
    ip character varying(15) NOT NULL
);


ALTER TABLE datos.bancos OWNER TO postgres;

--
-- TOC entry 3394 (class 0 OID 0)
-- Dependencies: 176
-- Name: TABLE bancos; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE bancos IS 'Tabla con los datos de los bancos que maneja el organismo';


--
-- TOC entry 3395 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN bancos.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN bancos.id IS 'Identificador unico de registro';


--
-- TOC entry 3396 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN bancos.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN bancos.nombre IS 'Nombre del banco';


--
-- TOC entry 3397 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN bancos.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN bancos.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3398 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN bancos.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN bancos.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 177 (class 1259 OID 128419)
-- Dependencies: 9 176
-- Name: Bancos_IDBanco_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE "Bancos_IDBanco_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos."Bancos_IDBanco_seq" OWNER TO postgres;

--
-- TOC entry 3399 (class 0 OID 0)
-- Dependencies: 177
-- Name: Bancos_IDBanco_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "Bancos_IDBanco_seq" OWNED BY bancos.id;


--
-- TOC entry 178 (class 1259 OID 128421)
-- Dependencies: 9
-- Name: calpagod; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE calpagod (
    id integer NOT NULL,
    calpagoid integer NOT NULL,
    fechaini date NOT NULL,
    fechafin date NOT NULL,
    fechalim date NOT NULL,
    usuarioid integer NOT NULL,
    ip character varying(15) NOT NULL,
    periodo character varying(5) NOT NULL
);


ALTER TABLE datos.calpagod OWNER TO postgres;

--
-- TOC entry 3400 (class 0 OID 0)
-- Dependencies: 178
-- Name: TABLE calpagod; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE calpagod IS 'Tabla con el detalle de los calendario de pagos';


--
-- TOC entry 3401 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN calpagod.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpagod.id IS 'Identificador unico del detalle de los calendarios de pagos';


--
-- TOC entry 3402 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN calpagod.calpagoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpagod.calpagoid IS 'Identificador del calendario de pago';


--
-- TOC entry 3403 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN calpagod.fechaini; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpagod.fechaini IS 'Fecha de inicio del periodo gravable';


--
-- TOC entry 3404 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN calpagod.fechafin; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpagod.fechafin IS 'Fecha final del periodo gravable';


--
-- TOC entry 3405 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN calpagod.fechalim; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpagod.fechalim IS 'Fecha limite de pago del periodo gravable';


--
-- TOC entry 3406 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN calpagod.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpagod.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3407 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN calpagod.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpagod.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 179 (class 1259 OID 128424)
-- Dependencies: 178 9
-- Name: CalPagoD_IDCalPagoD_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE "CalPagoD_IDCalPagoD_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos."CalPagoD_IDCalPagoD_seq" OWNER TO postgres;

--
-- TOC entry 3408 (class 0 OID 0)
-- Dependencies: 179
-- Name: CalPagoD_IDCalPagoD_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "CalPagoD_IDCalPagoD_seq" OWNED BY calpagod.id;


--
-- TOC entry 180 (class 1259 OID 128426)
-- Dependencies: 2379 9
-- Name: calpago; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE calpago (
    id integer NOT NULL,
    nombre character varying(200) NOT NULL,
    ano smallint DEFAULT 0 NOT NULL,
    tipegravid integer NOT NULL,
    usuarioid integer NOT NULL,
    ip character varying(15) NOT NULL
);


ALTER TABLE datos.calpago OWNER TO postgres;

--
-- TOC entry 3409 (class 0 OID 0)
-- Dependencies: 180
-- Name: TABLE calpago; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE calpago IS 'Tabla con los calendarios de pagos de los diferentes tipos de contribuyentes por año';


--
-- TOC entry 3410 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN calpago.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpago.id IS 'Identificador del calendario de pagos';


--
-- TOC entry 3411 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN calpago.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpago.nombre IS 'Nombre del calendario';


--
-- TOC entry 3412 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN calpago.ano; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpago.ano IS 'Año vigencia del calendario';


--
-- TOC entry 3413 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN calpago.tipegravid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpago.tipegravid IS 'Identificador del tipo de periodo gravable';


--
-- TOC entry 3414 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN calpago.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpago.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3415 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN calpago.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpago.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 181 (class 1259 OID 128430)
-- Dependencies: 180 9
-- Name: CalPagos_IDCalPago_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE "CalPagos_IDCalPago_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos."CalPagos_IDCalPago_seq" OWNER TO postgres;

--
-- TOC entry 3416 (class 0 OID 0)
-- Dependencies: 181
-- Name: CalPagos_IDCalPago_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "CalPagos_IDCalPago_seq" OWNED BY calpago.id;


--
-- TOC entry 182 (class 1259 OID 128432)
-- Dependencies: 9
-- Name: cargos; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE cargos (
    id integer NOT NULL,
    nombre character varying(200) NOT NULL,
    usuarioid integer NOT NULL,
    ip character varying(15) NOT NULL,
    codigo_cargo character varying
);


ALTER TABLE datos.cargos OWNER TO postgres;

--
-- TOC entry 3417 (class 0 OID 0)
-- Dependencies: 182
-- Name: TABLE cargos; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE cargos IS 'Tabla con los distintos cargos de la organizacion';


--
-- TOC entry 3418 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN cargos.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN cargos.id IS 'Identificador unico del cargo';


--
-- TOC entry 3419 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN cargos.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN cargos.nombre IS 'Nombre del cargo';


--
-- TOC entry 3420 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN cargos.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN cargos.usuarioid IS 'Identificador del usuario que creo el registro o del ultimo en modificarlo';


--
-- TOC entry 3421 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN cargos.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN cargos.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 183 (class 1259 OID 128438)
-- Dependencies: 9 182
-- Name: Cargos_IDCargo_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE "Cargos_IDCargo_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos."Cargos_IDCargo_seq" OWNER TO postgres;

--
-- TOC entry 3422 (class 0 OID 0)
-- Dependencies: 183
-- Name: Cargos_IDCargo_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "Cargos_IDCargo_seq" OWNED BY cargos.id;


--
-- TOC entry 184 (class 1259 OID 128440)
-- Dependencies: 9
-- Name: ciudades; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE ciudades (
    id integer NOT NULL,
    estadoid integer NOT NULL,
    nombre character varying(100) NOT NULL,
    usuarioid integer NOT NULL,
    ip character varying(15) NOT NULL
);


ALTER TABLE datos.ciudades OWNER TO postgres;

--
-- TOC entry 3423 (class 0 OID 0)
-- Dependencies: 184
-- Name: TABLE ciudades; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE ciudades IS 'Tabla con las ciudades por estado geografico';


--
-- TOC entry 3424 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN ciudades.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN ciudades.id IS 'Idenficador unico de la ciudad';


--
-- TOC entry 3425 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN ciudades.estadoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN ciudades.estadoid IS 'Identificador del estado';


--
-- TOC entry 3426 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN ciudades.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN ciudades.nombre IS 'Nombre de la ciudad';


--
-- TOC entry 3427 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN ciudades.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN ciudades.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3428 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN ciudades.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN ciudades.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 185 (class 1259 OID 128443)
-- Dependencies: 184 9
-- Name: Ciudades_IDCiudad_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE "Ciudades_IDCiudad_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos."Ciudades_IDCiudad_seq" OWNER TO postgres;

--
-- TOC entry 3429 (class 0 OID 0)
-- Dependencies: 185
-- Name: Ciudades_IDCiudad_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "Ciudades_IDCiudad_seq" OWNED BY ciudades.id;


--
-- TOC entry 186 (class 1259 OID 128445)
-- Dependencies: 9
-- Name: conusuco; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE conusuco (
    id integer NOT NULL,
    conusuid integer NOT NULL,
    contribuid integer NOT NULL
);


ALTER TABLE datos.conusuco OWNER TO postgres;

--
-- TOC entry 3430 (class 0 OID 0)
-- Dependencies: 186
-- Name: TABLE conusuco; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE conusuco IS 'Tabla con la relacion entre usuarios y a los contribuyentes que representan';


--
-- TOC entry 3431 (class 0 OID 0)
-- Dependencies: 186
-- Name: COLUMN conusuco.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuco.id IS 'Identificador unico de registro';


--
-- TOC entry 3432 (class 0 OID 0)
-- Dependencies: 186
-- Name: COLUMN conusuco.conusuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuco.conusuid IS 'Identificador del usuario';


--
-- TOC entry 3433 (class 0 OID 0)
-- Dependencies: 186
-- Name: COLUMN conusuco.contribuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuco.contribuid IS 'Identificador del contribuyente';


--
-- TOC entry 187 (class 1259 OID 128448)
-- Dependencies: 9 186
-- Name: ConUsuCo_IDConUsuCo_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE "ConUsuCo_IDConUsuCo_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos."ConUsuCo_IDConUsuCo_seq" OWNER TO postgres;

--
-- TOC entry 3434 (class 0 OID 0)
-- Dependencies: 187
-- Name: ConUsuCo_IDConUsuCo_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "ConUsuCo_IDConUsuCo_seq" OWNED BY conusuco.id;


--
-- TOC entry 188 (class 1259 OID 128450)
-- Dependencies: 2384 2385 2386 9
-- Name: conusuti; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE conusuti (
    id integer NOT NULL,
    nombre character varying(50) NOT NULL,
    administra boolean DEFAULT false NOT NULL,
    liquida boolean DEFAULT false NOT NULL,
    visualiza boolean DEFAULT false NOT NULL,
    usuarioid integer NOT NULL,
    ip character varying(15) NOT NULL
);


ALTER TABLE datos.conusuti OWNER TO postgres;

--
-- TOC entry 3435 (class 0 OID 0)
-- Dependencies: 188
-- Name: TABLE conusuti; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE conusuti IS 'Tabla con los tipos de usuarios de los contribuyentes';


--
-- TOC entry 3436 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN conusuti.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuti.id IS 'Identificador unico del tipo de usuario de contribuyentes';


--
-- TOC entry 3437 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN conusuti.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuti.nombre IS 'Nombre del tipo de usuario';


--
-- TOC entry 3438 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN conusuti.administra; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuti.administra IS 'Si el tipo de usuario (perfil) administra la cuenta del contribuyente. Crea usuarios, elimina usuarios';


--
-- TOC entry 3439 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN conusuti.liquida; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuti.liquida IS 'Si el tipo de usuario (perfil) liquida planillas de autoliquidacion en la cuenta del contribuyente.';


--
-- TOC entry 3440 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN conusuti.visualiza; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuti.visualiza IS 'Si el tipo de usuario (perfil) solo visualiza datos  de la cuenta del contribuyente.';


--
-- TOC entry 3441 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN conusuti.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuti.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3442 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN conusuti.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuti.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 189 (class 1259 OID 128456)
-- Dependencies: 9 188
-- Name: ConUsuTi_IDConUsuTi_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE "ConUsuTi_IDConUsuTi_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos."ConUsuTi_IDConUsuTi_seq" OWNER TO postgres;

--
-- TOC entry 3443 (class 0 OID 0)
-- Dependencies: 189
-- Name: ConUsuTi_IDConUsuTi_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "ConUsuTi_IDConUsuTi_seq" OWNED BY conusuti.id;


--
-- TOC entry 190 (class 1259 OID 128458)
-- Dependencies: 2388 2389 9
-- Name: conusuto; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE conusuto (
    id integer NOT NULL,
    token text NOT NULL,
    conusuid integer NOT NULL,
    fechacrea timestamp without time zone NOT NULL,
    fechacadu timestamp without time zone DEFAULT (now() + '1 day'::interval) NOT NULL,
    usado boolean DEFAULT false NOT NULL
);


ALTER TABLE datos.conusuto OWNER TO postgres;

--
-- TOC entry 3444 (class 0 OID 0)
-- Dependencies: 190
-- Name: TABLE conusuto; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE conusuto IS 'Tabla con los Tokens activos por usuario, es Tokens se utilizaran para validad la creacion de usuarios, recuperacion de contraseñas, etc.';


--
-- TOC entry 3445 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN conusuto.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuto.id IS 'Idendificador unico del token';


--
-- TOC entry 3446 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN conusuto.token; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuto.token IS 'Token generado';


--
-- TOC entry 3447 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN conusuto.conusuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuto.conusuid IS 'Identificador del usuario dueño del token';


--
-- TOC entry 3448 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN conusuto.fechacrea; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuto.fechacrea IS 'Fecha hora de creacion del token';


--
-- TOC entry 3449 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN conusuto.fechacadu; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuto.fechacadu IS 'Fecha hora de caducidad del token';


--
-- TOC entry 3450 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN conusuto.usado; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuto.usado IS 'Si el token fue usado por el usuario o no';


--
-- TOC entry 191 (class 1259 OID 128466)
-- Dependencies: 9 190
-- Name: ConUsuTo_IDConUsuTo_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE "ConUsuTo_IDConUsuTo_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos."ConUsuTo_IDConUsuTo_seq" OWNER TO postgres;

--
-- TOC entry 3451 (class 0 OID 0)
-- Dependencies: 191
-- Name: ConUsuTo_IDConUsuTo_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "ConUsuTo_IDConUsuTo_seq" OWNED BY conusuto.id;


--
-- TOC entry 192 (class 1259 OID 128468)
-- Dependencies: 2391 2392 2393 2394 9
-- Name: conusu; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE conusu (
    id integer NOT NULL,
    login character varying(200) NOT NULL,
    password character varying(100) NOT NULL,
    nombre character varying(100) NOT NULL,
    inactivo boolean DEFAULT true NOT NULL,
    conusutiid integer NOT NULL,
    email character varying(100) NOT NULL,
    pregsecrid integer NOT NULL,
    respuesta character varying(100) NOT NULL,
    ultlogin timestamp without time zone,
    usuarioid integer,
    ip character varying(15) NOT NULL,
    rif character varying(20) NOT NULL,
    validado boolean DEFAULT false NOT NULL,
    fecha_registro date DEFAULT '2013-03-14'::date NOT NULL,
    correo_enviado boolean DEFAULT false
);


ALTER TABLE datos.conusu OWNER TO postgres;

--
-- TOC entry 3452 (class 0 OID 0)
-- Dependencies: 192
-- Name: TABLE conusu; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE conusu IS 'Tabla con los datos de los usuarios por contribuyente';


--
-- TOC entry 3453 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.id IS 'Identificador del usuario del contribuyente';


--
-- TOC entry 3454 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.login; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.login IS 'Login de usuario. este campo es unico y es identificado un el rif del contribuyente';


--
-- TOC entry 3455 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.password; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.password IS 'Hash del pasword para hacer login';


--
-- TOC entry 3456 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.nombre IS 'Nombre del usuario. Este es el nombre que se muestra';


--
-- TOC entry 3457 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.inactivo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.inactivo IS 'Si el usuario esta inactivo o no. False=No / True=Si';


--
-- TOC entry 3458 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.conusutiid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.conusutiid IS 'Identificador del tipo de usuario de contribuyentes';


--
-- TOC entry 3459 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.email; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.email IS 'Direccion de email del usuario, se utilizara para validar la cuenta';


--
-- TOC entry 3460 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.pregsecrid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.pregsecrid IS 'Identificador de la pregunta secreta seleccionada por en usuario';


--
-- TOC entry 3461 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.respuesta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.respuesta IS 'Hash con la respuesta a la pregunta secreta';


--
-- TOC entry 3462 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.ultlogin; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.ultlogin IS 'Fecha y hora de la ultima vez que el usuario hizo login';


--
-- TOC entry 3463 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3464 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 193 (class 1259 OID 128478)
-- Dependencies: 192 9
-- Name: ConUsu_IDConUsu_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE "ConUsu_IDConUsu_seq"
    START WITH 1
    INCREMENT BY 1
    MINVALUE 0
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos."ConUsu_IDConUsu_seq" OWNER TO postgres;

--
-- TOC entry 3465 (class 0 OID 0)
-- Dependencies: 193
-- Name: ConUsu_IDConUsu_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "ConUsu_IDConUsu_seq" OWNED BY conusu.id;


--
-- TOC entry 194 (class 1259 OID 128480)
-- Dependencies: 2396 2397 2398 2399 9
-- Name: contribu; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE contribu (
    id integer NOT NULL,
    razonsocia character varying(350) NOT NULL,
    dencomerci character varying(200) NOT NULL,
    actieconid integer NOT NULL,
    rif character varying(20) NOT NULL,
    numregcine integer NOT NULL,
    domfiscal character varying(500) NOT NULL,
    estadoid integer NOT NULL,
    ciudadid integer NOT NULL,
    zonapostal character varying(10),
    telef1 character varying(12) NOT NULL,
    telef2 character varying(12),
    telef3 character varying(12),
    fax1 character varying(12),
    fax2 character varying(12),
    email character varying(100) NOT NULL,
    pinbb character varying(8),
    skype character varying(100),
    twitter character varying(100),
    facebook character varying(200),
    nuacciones integer DEFAULT 0 NOT NULL,
    valaccion numeric(18,2) DEFAULT 0 NOT NULL,
    capitalsus numeric(18,2) DEFAULT 0 NOT NULL,
    capitalpag numeric(18,2) DEFAULT 0 NOT NULL,
    regmerofc character varying(300) NOT NULL,
    rmnumero character varying(20) NOT NULL,
    rmfolio character varying(20) NOT NULL,
    rmtomo character varying(10) NOT NULL,
    rmfechapro date NOT NULL,
    rmncontrol character varying(20) NOT NULL,
    rmobjeto text NOT NULL,
    domcomer character varying(350),
    cextra1 character varying(200),
    cextra2 character varying(200),
    cextra3 character varying(200),
    cextra4 character varying(200),
    cextra5 character varying(200),
    usuarioid integer NOT NULL,
    ip character varying(15) NOT NULL
);


ALTER TABLE datos.contribu OWNER TO postgres;

--
-- TOC entry 3466 (class 0 OID 0)
-- Dependencies: 194
-- Name: TABLE contribu; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE contribu IS 'Tabla con los datos de los contribuyentes de la institución';


--
-- TOC entry 3467 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.id IS 'Identificador unico del contribuyente';


--
-- TOC entry 3468 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.razonsocia; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.razonsocia IS 'Razon social del contribuyente';


--
-- TOC entry 3469 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.dencomerci; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.dencomerci IS 'Denominacion comercial del contribuyente';


--
-- TOC entry 3470 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.actieconid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.actieconid IS 'Identificador de la actividad economica';


--
-- TOC entry 3471 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.rif; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.rif IS 'Rif del contribuyente';


--
-- TOC entry 3472 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.numregcine; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.numregcine IS 'Numero de registro cinematografico';


--
-- TOC entry 3473 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.domfiscal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.domfiscal IS 'Domicilio fiscal del contribuyente';


--
-- TOC entry 3474 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.estadoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.estadoid IS 'Identicador del estado geografico';


--
-- TOC entry 3475 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.ciudadid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.ciudadid IS 'Identificador de la ciudad';


--
-- TOC entry 3476 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.zonapostal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.zonapostal IS 'Zona postal del contribuyente';


--
-- TOC entry 3477 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.telef1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.telef1 IS 'Telefono 1 del contribuyente';


--
-- TOC entry 3478 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.telef2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.telef2 IS 'Telefono 2 del contribuyente';


--
-- TOC entry 3479 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.telef3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.telef3 IS 'Telefono 3 del contribuyente';


--
-- TOC entry 3480 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.fax1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.fax1 IS 'Fax 1 del contribuyente';


--
-- TOC entry 3481 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.fax2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.fax2 IS 'Fax 2 del contribuyente';


--
-- TOC entry 3482 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.email; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.email IS 'Direccion de email de contribuyente';


--
-- TOC entry 3483 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.pinbb; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.pinbb IS 'Pin de BlackBerry';


--
-- TOC entry 3484 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.skype; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.skype IS 'Dirección de skype';


--
-- TOC entry 3485 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.twitter; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.twitter IS 'Direccion de twitter';


--
-- TOC entry 3486 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.facebook; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.facebook IS 'Direccion de facebook';


--
-- TOC entry 3487 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.nuacciones; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.nuacciones IS 'Numero de acciones del contribuyente segun inforacion del registro mercantil';


--
-- TOC entry 3488 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.valaccion; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.valaccion IS 'Valor nominal por accion segun registro mercantil';


--
-- TOC entry 3489 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.capitalsus; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.capitalsus IS 'Capital suscrito segun registro mercantil';


--
-- TOC entry 3490 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.capitalpag; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.capitalpag IS 'Capital pagado segun registro mercantil';


--
-- TOC entry 3491 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.regmerofc; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.regmerofc IS 'Oficina de registro mercantil en donde se registro la empresa';


--
-- TOC entry 3492 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.rmnumero; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.rmnumero IS 'Numero de registro del documento de registro mercantil';


--
-- TOC entry 3493 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.rmfolio; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.rmfolio IS 'Numero de folio del documento de registro mercantil';


--
-- TOC entry 3494 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.rmtomo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.rmtomo IS 'Numero de folio del documento de registro mercantil';


--
-- TOC entry 3495 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.rmfechapro; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.rmfechapro IS 'Fecha de protocololizacion del registro del documento de registro mercantil';


--
-- TOC entry 3496 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.rmncontrol; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.rmncontrol IS 'Numero de control del documento de registro mercantil';


--
-- TOC entry 3497 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.rmobjeto; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.rmobjeto IS 'Objeto de la empresa segun registro mercantil';


--
-- TOC entry 3498 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.domcomer; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.domcomer IS 'domicilio comercial';


--
-- TOC entry 3499 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.cextra1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.cextra1 IS 'Campo extra 1';


--
-- TOC entry 3500 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.cextra2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.cextra2 IS 'Campo extra 2';


--
-- TOC entry 3501 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.cextra3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.cextra3 IS 'Campo extra 3';


--
-- TOC entry 3502 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.cextra4; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.cextra4 IS 'Campo extra 4';


--
-- TOC entry 3503 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.cextra5; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.cextra5 IS 'Campo extra 5';


--
-- TOC entry 3504 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.usuarioid IS 'identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3505 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 195 (class 1259 OID 128490)
-- Dependencies: 194 9
-- Name: Contribu_IDContribu_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE "Contribu_IDContribu_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos."Contribu_IDContribu_seq" OWNER TO postgres;

--
-- TOC entry 3506 (class 0 OID 0)
-- Dependencies: 195
-- Name: Contribu_IDContribu_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "Contribu_IDContribu_seq" OWNED BY contribu.id;


--
-- TOC entry 196 (class 1259 OID 128492)
-- Dependencies: 2401 2402 2403 2404 2405 2406 2407 2408 9
-- Name: declara_viejo; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE declara_viejo (
    id integer NOT NULL,
    nudeclara character varying(27) NOT NULL,
    nudeposito character varying(27) NOT NULL,
    tdeclaraid integer NOT NULL,
    fechaelab timestamp without time zone NOT NULL,
    fechaini date NOT NULL,
    fechafin date NOT NULL,
    replegalid integer NOT NULL,
    baseimpo numeric(18,2) DEFAULT 0 NOT NULL,
    alicuota numeric(18,2) DEFAULT 0 NOT NULL,
    exonera numeric(18,2) DEFAULT 0 NOT NULL,
    nuactoexon character varying(10),
    credfiscal numeric(18,2) DEFAULT 0 NOT NULL,
    contribant numeric(18,2),
    plasustid integer,
    nuresactfi character varying(10),
    fechanoti date,
    intemora numeric(18,2) DEFAULT 0 NOT NULL,
    reparofis numeric(18,2) DEFAULT 0 NOT NULL,
    multa numeric(18,2) DEFAULT 0 NOT NULL,
    montopagar numeric(18,2) DEFAULT 0 NOT NULL,
    fechapago date,
    fechaconci timestamp without time zone,
    asientoid integer,
    usuarioid integer,
    ip character varying(15) NOT NULL,
    tipocontribuid integer NOT NULL,
    conusuid integer,
    calpagodid integer NOT NULL
);


ALTER TABLE datos.declara_viejo OWNER TO postgres;

--
-- TOC entry 3507 (class 0 OID 0)
-- Dependencies: 196
-- Name: TABLE declara_viejo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE declara_viejo IS 'Planilla de declaracion de impuestos';


--
-- TOC entry 3508 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.id IS 'Identificador unico de la declaracion de impuestos';


--
-- TOC entry 3509 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.nudeclara; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.nudeclara IS 'Numero de planilla de declaracion de impuesto';


--
-- TOC entry 3510 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.nudeposito; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.nudeposito IS 'Numero de deposito bancario generado por el sistema';


--
-- TOC entry 3511 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.tdeclaraid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.tdeclaraid IS 'Identificador del tipo de declaracion';


--
-- TOC entry 3512 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.fechaelab; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.fechaelab IS 'Fecha de elaboracion de la planilla de pago de impuestos';


--
-- TOC entry 3513 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.fechaini; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.fechaini IS 'Fecha de inicio del periodo gravable';


--
-- TOC entry 3514 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.fechafin; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.fechafin IS 'Fecha final del periodo gravable';


--
-- TOC entry 3515 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.replegalid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.replegalid IS 'Identificador del representante legal que aparecera en la planilla y firmara la misma';


--
-- TOC entry 3516 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.baseimpo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.baseimpo IS 'Base imponible';


--
-- TOC entry 3517 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.alicuota; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.alicuota IS 'Alicuota impositiva aplicada a la declaracion de impuesto';


--
-- TOC entry 3518 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.exonera; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.exonera IS 'Exoneracion o rebaja';


--
-- TOC entry 3519 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.nuactoexon; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.nuactoexon IS 'Numero de acto en donde se establece la exoneracion o rebaja';


--
-- TOC entry 3520 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.credfiscal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.credfiscal IS 'Credito fiscal';


--
-- TOC entry 3521 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.contribant; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.contribant IS 'Monto de la contribucion pagada en periodos anteriores';


--
-- TOC entry 3522 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.plasustid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.plasustid IS 'Identificador de la planilla que se esta sustituyendo en caso de ser una declaracion sustitutiva';


--
-- TOC entry 3523 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.nuresactfi; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.nuresactfi IS 'Numero de resolucion o numero de acta fiscal';


--
-- TOC entry 3524 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.fechanoti; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.fechanoti IS 'Fecha de notificacion';


--
-- TOC entry 3525 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.intemora; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.intemora IS 'Intereses moratorios';


--
-- TOC entry 3526 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.reparofis; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.reparofis IS 'Reparo fiscal';


--
-- TOC entry 3527 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.multa; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.multa IS 'Multa aplicada';


--
-- TOC entry 3528 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.montopagar; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.montopagar IS 'Monto a pagar';


--
-- TOC entry 3529 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.fechapago; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.fechapago IS 'Fecha de pago en el banco. Se llena este campo cuando se concilian los pagos';


--
-- TOC entry 3530 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.fechaconci; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.fechaconci IS 'Fecha hora de la conciliacion contra los depositos del banco';


--
-- TOC entry 3531 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.asientoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.asientoid IS 'Identificador del asiento contable en donde se registro la informacion del pago';


--
-- TOC entry 3532 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.usuarioid IS 'Identificador del usuario que concilio el pago de la declaracion. ';


--
-- TOC entry 3533 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 197 (class 1259 OID 128503)
-- Dependencies: 196 9
-- Name: Declara_IDDeclara_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE "Declara_IDDeclara_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos."Declara_IDDeclara_seq" OWNER TO postgres;

--
-- TOC entry 3534 (class 0 OID 0)
-- Dependencies: 197
-- Name: Declara_IDDeclara_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "Declara_IDDeclara_seq" OWNED BY declara_viejo.id;


--
-- TOC entry 198 (class 1259 OID 128505)
-- Dependencies: 9
-- Name: departam; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE departam (
    id integer NOT NULL,
    nombre character varying(200) NOT NULL,
    usuarioid integer NOT NULL,
    ip character varying(15) NOT NULL,
    cod_estructura character varying
);


ALTER TABLE datos.departam OWNER TO postgres;

--
-- TOC entry 3535 (class 0 OID 0)
-- Dependencies: 198
-- Name: TABLE departam; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE departam IS 'Tabla con los departamentos / gerencia de la organizacion';


--
-- TOC entry 3536 (class 0 OID 0)
-- Dependencies: 198
-- Name: COLUMN departam.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN departam.id IS 'Identificador unico del departamento';


--
-- TOC entry 3537 (class 0 OID 0)
-- Dependencies: 198
-- Name: COLUMN departam.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN departam.nombre IS 'Nombre del departamento o gerencia';


--
-- TOC entry 3538 (class 0 OID 0)
-- Dependencies: 198
-- Name: COLUMN departam.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN departam.usuarioid IS 'Identificador del usuario que creo el registro o del ultimo en modificarlo';


--
-- TOC entry 3539 (class 0 OID 0)
-- Dependencies: 198
-- Name: COLUMN departam.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN departam.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 199 (class 1259 OID 128511)
-- Dependencies: 198 9
-- Name: Departam_IDDepartam_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE "Departam_IDDepartam_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos."Departam_IDDepartam_seq" OWNER TO postgres;

--
-- TOC entry 3540 (class 0 OID 0)
-- Dependencies: 199
-- Name: Departam_IDDepartam_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "Departam_IDDepartam_seq" OWNED BY departam.id;


--
-- TOC entry 200 (class 1259 OID 128513)
-- Dependencies: 2411 9
-- Name: entidadd; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE entidadd (
    id integer NOT NULL,
    entidadid integer NOT NULL,
    nombre character varying(200) NOT NULL,
    accion character varying(100) NOT NULL,
    orden smallint DEFAULT 0 NOT NULL
);


ALTER TABLE datos.entidadd OWNER TO postgres;

--
-- TOC entry 3541 (class 0 OID 0)
-- Dependencies: 200
-- Name: TABLE entidadd; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE entidadd IS 'Tabla con el detalle de las entidades. Acciones y procesos a verificar acceso por entidad';


--
-- TOC entry 3542 (class 0 OID 0)
-- Dependencies: 200
-- Name: COLUMN entidadd.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN entidadd.id IS 'Identificador unico del detalle de la entidad';


--
-- TOC entry 3543 (class 0 OID 0)
-- Dependencies: 200
-- Name: COLUMN entidadd.entidadid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN entidadd.entidadid IS 'Identificador de la entidad a la que pertenece la accion o preceso';


--
-- TOC entry 3544 (class 0 OID 0)
-- Dependencies: 200
-- Name: COLUMN entidadd.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN entidadd.nombre IS 'Nombre de la accion o proceso a mostrar en el arbol de permisos disponibles';


--
-- TOC entry 3545 (class 0 OID 0)
-- Dependencies: 200
-- Name: COLUMN entidadd.accion; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN entidadd.accion IS 'Nombre interno de la accion o proceso';


--
-- TOC entry 3546 (class 0 OID 0)
-- Dependencies: 200
-- Name: COLUMN entidadd.orden; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN entidadd.orden IS 'Orden en que apareceran las acciones y/o procesos dentro del arbol de una entidad';


--
-- TOC entry 201 (class 1259 OID 128517)
-- Dependencies: 9 200
-- Name: EntidadD_IDEntidadD_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE "EntidadD_IDEntidadD_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos."EntidadD_IDEntidadD_seq" OWNER TO postgres;

--
-- TOC entry 3547 (class 0 OID 0)
-- Dependencies: 201
-- Name: EntidadD_IDEntidadD_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "EntidadD_IDEntidadD_seq" OWNED BY entidadd.id;


--
-- TOC entry 202 (class 1259 OID 128519)
-- Dependencies: 2413 9
-- Name: entidad; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE entidad (
    id integer NOT NULL,
    nombre character varying(200) NOT NULL,
    entidad character varying(100) NOT NULL,
    orden smallint DEFAULT 0 NOT NULL
);


ALTER TABLE datos.entidad OWNER TO postgres;

--
-- TOC entry 3548 (class 0 OID 0)
-- Dependencies: 202
-- Name: TABLE entidad; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE entidad IS 'Tabla con las entidades del sistema';


--
-- TOC entry 3549 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN entidad.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN entidad.id IS 'Identificador de la entidad';


--
-- TOC entry 3550 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN entidad.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN entidad.nombre IS 'Nombre de la entidad a mostrar en el arbol de permisos disponibles';


--
-- TOC entry 3551 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN entidad.entidad; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN entidad.entidad IS 'Nombre interno de la entidad';


--
-- TOC entry 3552 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN entidad.orden; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN entidad.orden IS 'Orden en la que apareceran la entidades en el arbol de permisos de usuarios';


--
-- TOC entry 203 (class 1259 OID 128523)
-- Dependencies: 9 202
-- Name: Entidad_IDEntidad_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE "Entidad_IDEntidad_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos."Entidad_IDEntidad_seq" OWNER TO postgres;

--
-- TOC entry 3553 (class 0 OID 0)
-- Dependencies: 203
-- Name: Entidad_IDEntidad_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "Entidad_IDEntidad_seq" OWNED BY entidad.id;


--
-- TOC entry 204 (class 1259 OID 128525)
-- Dependencies: 9
-- Name: estados; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE estados (
    id integer NOT NULL,
    nombre character varying(100) NOT NULL,
    usuarioid integer NOT NULL,
    ip character varying(15) NOT NULL
);


ALTER TABLE datos.estados OWNER TO postgres;

--
-- TOC entry 3554 (class 0 OID 0)
-- Dependencies: 204
-- Name: TABLE estados; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE estados IS 'Tabla con los estados geográficos';


--
-- TOC entry 3555 (class 0 OID 0)
-- Dependencies: 204
-- Name: COLUMN estados.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN estados.id IS 'Identificador unico del estado';


--
-- TOC entry 3556 (class 0 OID 0)
-- Dependencies: 204
-- Name: COLUMN estados.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN estados.nombre IS 'Nombre del estado geografico';


--
-- TOC entry 3557 (class 0 OID 0)
-- Dependencies: 204
-- Name: COLUMN estados.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN estados.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3558 (class 0 OID 0)
-- Dependencies: 204
-- Name: COLUMN estados.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN estados.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 205 (class 1259 OID 128528)
-- Dependencies: 9 204
-- Name: Estados_IDEstado_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE "Estados_IDEstado_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos."Estados_IDEstado_seq" OWNER TO postgres;

--
-- TOC entry 3559 (class 0 OID 0)
-- Dependencies: 205
-- Name: Estados_IDEstado_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "Estados_IDEstado_seq" OWNED BY estados.id;


--
-- TOC entry 206 (class 1259 OID 128530)
-- Dependencies: 9
-- Name: perusud; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE perusud (
    id integer NOT NULL,
    perusuid integer NOT NULL,
    entidaddid integer NOT NULL,
    usuarioid integer NOT NULL,
    ip character varying(15) NOT NULL
);


ALTER TABLE datos.perusud OWNER TO postgres;

--
-- TOC entry 3560 (class 0 OID 0)
-- Dependencies: 206
-- Name: TABLE perusud; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE perusud IS 'Tabla con los datos del detalle de los perfiles de usuario. Detalles de entidades habilitadas para el perfil seleccionado';


--
-- TOC entry 3561 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN perusud.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN perusud.id IS 'Identificador unico del detalle de perfil de usuario';


--
-- TOC entry 3562 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN perusud.perusuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN perusud.perusuid IS 'Identificador del perfil al cual pertenece el detalle (accion o proceso permisado)';


--
-- TOC entry 3563 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN perusud.entidaddid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN perusud.entidaddid IS 'Identificador de la accion o proceso permisado (detalles de las entidades)';


--
-- TOC entry 3564 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN perusud.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN perusud.usuarioid IS 'Identificador del usuario que creo el registro o el ultimo en modificarlo';


--
-- TOC entry 3565 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN perusud.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN perusud.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 207 (class 1259 OID 128533)
-- Dependencies: 206 9
-- Name: PerUsuD_IDPerUsuD_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE "PerUsuD_IDPerUsuD_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos."PerUsuD_IDPerUsuD_seq" OWNER TO postgres;

--
-- TOC entry 3566 (class 0 OID 0)
-- Dependencies: 207
-- Name: PerUsuD_IDPerUsuD_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "PerUsuD_IDPerUsuD_seq" OWNED BY perusud.id;


--
-- TOC entry 208 (class 1259 OID 128535)
-- Dependencies: 2417 9
-- Name: perusu; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE perusu (
    id integer NOT NULL,
    nombre character varying(200) NOT NULL,
    inactivo boolean DEFAULT false NOT NULL,
    usuarioid integer NOT NULL,
    ip character varying(15) NOT NULL
);


ALTER TABLE datos.perusu OWNER TO postgres;

--
-- TOC entry 3567 (class 0 OID 0)
-- Dependencies: 208
-- Name: TABLE perusu; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE perusu IS 'Tabla con los perfiles de usuarios';


--
-- TOC entry 3568 (class 0 OID 0)
-- Dependencies: 208
-- Name: COLUMN perusu.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN perusu.id IS 'Identificador del perfl de usuario';


--
-- TOC entry 3569 (class 0 OID 0)
-- Dependencies: 208
-- Name: COLUMN perusu.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN perusu.nombre IS 'Nombre del perfil de usuario';


--
-- TOC entry 3570 (class 0 OID 0)
-- Dependencies: 208
-- Name: COLUMN perusu.inactivo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN perusu.inactivo IS 'Si el pelfil de usuario esta Inactivo o no';


--
-- TOC entry 3571 (class 0 OID 0)
-- Dependencies: 208
-- Name: COLUMN perusu.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN perusu.usuarioid IS 'Identificador de usuario que creo o el ultimo que actualizo el registro';


--
-- TOC entry 3572 (class 0 OID 0)
-- Dependencies: 208
-- Name: COLUMN perusu.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN perusu.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 209 (class 1259 OID 128539)
-- Dependencies: 208 9
-- Name: PerUsu_IDPerUsu_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE "PerUsu_IDPerUsu_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos."PerUsu_IDPerUsu_seq" OWNER TO postgres;

--
-- TOC entry 3573 (class 0 OID 0)
-- Dependencies: 209
-- Name: PerUsu_IDPerUsu_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "PerUsu_IDPerUsu_seq" OWNED BY perusu.id;


--
-- TOC entry 210 (class 1259 OID 128541)
-- Dependencies: 9
-- Name: pregsecr; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE pregsecr (
    id integer NOT NULL,
    nombre character varying(150) NOT NULL,
    usuarioid integer NOT NULL,
    ip character varying(15) NOT NULL
);


ALTER TABLE datos.pregsecr OWNER TO postgres;

--
-- TOC entry 3574 (class 0 OID 0)
-- Dependencies: 210
-- Name: TABLE pregsecr; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE pregsecr IS 'Tablas con las preguntas secretas validas para la recuperacion de contraseñas';


--
-- TOC entry 3575 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN pregsecr.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN pregsecr.id IS 'Identificador unico de la pregunta secreta';


--
-- TOC entry 3576 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN pregsecr.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN pregsecr.nombre IS 'Texto de la pregunta secreta';


--
-- TOC entry 3577 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN pregsecr.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN pregsecr.usuarioid IS 'Identificado del ultimo usuario que creo o actualizo el registro';


--
-- TOC entry 3578 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN pregsecr.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN pregsecr.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 211 (class 1259 OID 128544)
-- Dependencies: 210 9
-- Name: PregSecr_IDPregSecr_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE "PregSecr_IDPregSecr_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos."PregSecr_IDPregSecr_seq" OWNER TO postgres;

--
-- TOC entry 3579 (class 0 OID 0)
-- Dependencies: 211
-- Name: PregSecr_IDPregSecr_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "PregSecr_IDPregSecr_seq" OWNED BY pregsecr.id;


--
-- TOC entry 212 (class 1259 OID 128546)
-- Dependencies: 9
-- Name: replegal; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE replegal (
    id integer NOT NULL,
    contribuid integer NOT NULL,
    nombre character varying(100) NOT NULL,
    apellido character varying(100) NOT NULL,
    ci character varying(20) NOT NULL,
    domfiscal character varying(500) NOT NULL,
    estadoid integer NOT NULL,
    ciudadid integer NOT NULL,
    zonaposta character varying(10),
    telefhab character varying(12),
    telefofc character varying(12),
    fax character varying(12),
    email character varying(100),
    pinbb character varying(8),
    skype character varying(100),
    cextra1 character varying(200),
    cextra2 character varying(200),
    cextra3 character varying(200),
    cextra4 character varying(200),
    cextra5 character varying(200),
    usuarioid integer NOT NULL,
    ip character varying(15) NOT NULL
);


ALTER TABLE datos.replegal OWNER TO postgres;

--
-- TOC entry 3580 (class 0 OID 0)
-- Dependencies: 212
-- Name: TABLE replegal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE replegal IS 'Tabla con los datos de los Accionistas de los contribuyentes';


--
-- TOC entry 3581 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.id IS 'Identificador unico del representante legal';


--
-- TOC entry 3582 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.contribuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.contribuid IS 'Identificador del contribuyente';


--
-- TOC entry 3583 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.nombre IS 'Nombre del representante legal';


--
-- TOC entry 3584 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.apellido; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.apellido IS 'Apellidos del representante legal';


--
-- TOC entry 3585 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.ci; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.ci IS 'Cedula de identidad, numero de pasaporte';


--
-- TOC entry 3586 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.domfiscal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.domfiscal IS 'Domicilio fiscal del representante legal';


--
-- TOC entry 3587 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.estadoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.estadoid IS 'Identificador del estado geografico';


--
-- TOC entry 3588 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.ciudadid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.ciudadid IS 'Identificador de la ciudad';


--
-- TOC entry 3589 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.zonaposta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.zonaposta IS 'Zona postal';


--
-- TOC entry 3590 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.telefhab; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.telefhab IS 'Telefono de habitacion del representante legal';


--
-- TOC entry 3591 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.telefofc; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.telefofc IS 'Telefono de oficina del representante legal';


--
-- TOC entry 3592 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.fax; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.fax IS 'Fax del representante legal';


--
-- TOC entry 3593 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.email; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.email IS 'Direccion de email del contribuyente';


--
-- TOC entry 3594 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.pinbb; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.pinbb IS 'Pin de BlackBerry';


--
-- TOC entry 3595 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.skype; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.skype IS 'Direccion de skype del representante legal';


--
-- TOC entry 3596 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.cextra1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.cextra1 IS 'Campo extra 1';


--
-- TOC entry 3597 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.cextra2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.cextra2 IS 'Campo extra 2';


--
-- TOC entry 3598 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.cextra3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.cextra3 IS 'Campo extra 3';


--
-- TOC entry 3599 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.cextra4; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.cextra4 IS 'Campo extra 4';


--
-- TOC entry 3600 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.cextra5; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.cextra5 IS 'Campo extra 5';


--
-- TOC entry 3601 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3602 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 213 (class 1259 OID 128552)
-- Dependencies: 212 9
-- Name: RepLegal_IDRepLegal_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE "RepLegal_IDRepLegal_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos."RepLegal_IDRepLegal_seq" OWNER TO postgres;

--
-- TOC entry 3603 (class 0 OID 0)
-- Dependencies: 213
-- Name: RepLegal_IDRepLegal_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "RepLegal_IDRepLegal_seq" OWNED BY replegal.id;


--
-- TOC entry 214 (class 1259 OID 128554)
-- Dependencies: 9
-- Name: tdeclara; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE tdeclara (
    id integer NOT NULL,
    nombre character varying(100) NOT NULL,
    tipo smallint,
    usuarioid integer NOT NULL,
    ip character varying(15) NOT NULL
);


ALTER TABLE datos.tdeclara OWNER TO postgres;

--
-- TOC entry 3604 (class 0 OID 0)
-- Dependencies: 214
-- Name: TABLE tdeclara; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE tdeclara IS 'Tipo de declaracion de impuestos';


--
-- TOC entry 3605 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN tdeclara.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tdeclara.id IS 'Identificador unico de registro';


--
-- TOC entry 3606 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN tdeclara.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tdeclara.nombre IS 'Nombre del tipo de declaracion de impuesto. Ejm. Autoliquidacion, Sustitutiva, etc';


--
-- TOC entry 3607 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN tdeclara.tipo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tdeclara.tipo IS 'Tipo de declaracion a efectuar. Utilizamos este campo para activar/desactivar la seccion correspondiente a los datos de la liquidacion en la planilla de pago de impuestos.
0 = Autoliquidación / Sustitutiva
1 = Multa por pago extemporaneo / Reparo fiscal
2 = Multa
3 = Intereses Moratorios';


--
-- TOC entry 3608 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN tdeclara.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tdeclara.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro.';


--
-- TOC entry 3609 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN tdeclara.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tdeclara.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 215 (class 1259 OID 128557)
-- Dependencies: 214 9
-- Name: TDeclara_IDTDeclara_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE "TDeclara_IDTDeclara_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos."TDeclara_IDTDeclara_seq" OWNER TO postgres;

--
-- TOC entry 3610 (class 0 OID 0)
-- Dependencies: 215
-- Name: TDeclara_IDTDeclara_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "TDeclara_IDTDeclara_seq" OWNED BY tdeclara.id;


--
-- TOC entry 216 (class 1259 OID 128559)
-- Dependencies: 2422 2423 9
-- Name: tipegrav; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE tipegrav (
    id integer NOT NULL,
    nombre character varying(50) NOT NULL,
    tipe smallint DEFAULT 0 NOT NULL,
    peano smallint DEFAULT 12 NOT NULL,
    usuarioid integer NOT NULL,
    ip character varying(15) NOT NULL
);


ALTER TABLE datos.tipegrav OWNER TO postgres;

--
-- TOC entry 3611 (class 0 OID 0)
-- Dependencies: 216
-- Name: TABLE tipegrav; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE tipegrav IS 'Tabla con los tipos de períodos gravables';


--
-- TOC entry 3612 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN tipegrav.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipegrav.id IS 'Identificador del tipo de periodo gravable';


--
-- TOC entry 3613 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN tipegrav.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipegrav.nombre IS 'Nombre del tipo de período gravable. Ejm. Mensual, trimestral, anual';


--
-- TOC entry 3614 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN tipegrav.tipe; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipegrav.tipe IS 'Tipo de periodo. 0=Mensual / 1=Trimestral / 2=Anual';


--
-- TOC entry 3615 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN tipegrav.peano; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipegrav.peano IS 'Numero de periodos gravables en año fiscal';


--
-- TOC entry 3616 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN tipegrav.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipegrav.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3617 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN tipegrav.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipegrav.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 217 (class 1259 OID 128564)
-- Dependencies: 216 9
-- Name: TiPeGrav_IDTiPeGrav_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE "TiPeGrav_IDTiPeGrav_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos."TiPeGrav_IDTiPeGrav_seq" OWNER TO postgres;

--
-- TOC entry 3618 (class 0 OID 0)
-- Dependencies: 217
-- Name: TiPeGrav_IDTiPeGrav_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "TiPeGrav_IDTiPeGrav_seq" OWNED BY tipegrav.id;


--
-- TOC entry 218 (class 1259 OID 128566)
-- Dependencies: 9
-- Name: tipocont; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE tipocont (
    id integer NOT NULL,
    nombre character varying(200) NOT NULL,
    tipegravid integer NOT NULL,
    usuarioid integer NOT NULL,
    ip character varying(15) NOT NULL,
    numero_articulo integer,
    cita_articulo character varying
);


ALTER TABLE datos.tipocont OWNER TO postgres;

--
-- TOC entry 3619 (class 0 OID 0)
-- Dependencies: 218
-- Name: TABLE tipocont; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE tipocont IS 'Tabla con los tipos de contribuyentes';


--
-- TOC entry 3620 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN tipocont.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipocont.id IS 'Identificador unico del tipo de contribuyente';


--
-- TOC entry 3621 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN tipocont.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipocont.nombre IS 'Nombre o descripción del tipo de contribuyente. Ejm Exibidores cinematográficos';


--
-- TOC entry 3622 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN tipocont.tipegravid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipocont.tipegravid IS 'Identificador del tipo de periodo gravable';


--
-- TOC entry 3623 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN tipocont.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipocont.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3624 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN tipocont.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipocont.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 219 (class 1259 OID 128572)
-- Dependencies: 218 9
-- Name: TipoCont_IDTipoCont_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE "TipoCont_IDTipoCont_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos."TipoCont_IDTipoCont_seq" OWNER TO postgres;

--
-- TOC entry 3625 (class 0 OID 0)
-- Dependencies: 219
-- Name: TipoCont_IDTipoCont_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "TipoCont_IDTipoCont_seq" OWNED BY tipocont.id;


--
-- TOC entry 220 (class 1259 OID 128574)
-- Dependencies: 2426 9
-- Name: undtrib; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE undtrib (
    id integer NOT NULL,
    fecha date NOT NULL,
    valor numeric(18,2) DEFAULT 0 NOT NULL,
    usuarioid integer NOT NULL,
    ip character varying(15) NOT NULL,
    anio integer
);


ALTER TABLE datos.undtrib OWNER TO postgres;

--
-- TOC entry 3626 (class 0 OID 0)
-- Dependencies: 220
-- Name: TABLE undtrib; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE undtrib IS 'Tabla con los valores de conversion de las unidades tributarias';


--
-- TOC entry 3627 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN undtrib.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN undtrib.id IS 'Identificador unico de registro';


--
-- TOC entry 3628 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN undtrib.fecha; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN undtrib.fecha IS 'Fecha a partir de la cual esta vigente el valor de la unidad tributaria';


--
-- TOC entry 3629 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN undtrib.valor; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN undtrib.valor IS 'Valor en Bs de una unidad tributaria';


--
-- TOC entry 3630 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN undtrib.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN undtrib.usuarioid IS 'Identificador del ultimo usuario que creo o modifico un registro';


--
-- TOC entry 3631 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN undtrib.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN undtrib.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 221 (class 1259 OID 128578)
-- Dependencies: 9 220
-- Name: UndTrib_IDUndTrib_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE "UndTrib_IDUndTrib_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos."UndTrib_IDUndTrib_seq" OWNER TO postgres;

--
-- TOC entry 3632 (class 0 OID 0)
-- Dependencies: 221
-- Name: UndTrib_IDUndTrib_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "UndTrib_IDUndTrib_seq" OWNED BY undtrib.id;


--
-- TOC entry 222 (class 1259 OID 128580)
-- Dependencies: 2428 9
-- Name: usfonpto; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE usfonpto (
    id integer NOT NULL,
    token text NOT NULL,
    usfonproid integer NOT NULL,
    fechacrea timestamp without time zone NOT NULL,
    fechacadu timestamp without time zone,
    usado boolean DEFAULT false NOT NULL
);


ALTER TABLE datos.usfonpto OWNER TO postgres;

--
-- TOC entry 3633 (class 0 OID 0)
-- Dependencies: 222
-- Name: TABLE usfonpto; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE usfonpto IS 'Tabla con los Tokens activos por usuario Fonprocine, es Tokens se utilizaran para validad la creacion de usuarios, recuperacion de contraseñas, etc.';


--
-- TOC entry 3634 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN usfonpto.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpto.id IS 'Identificador unico del Token';


--
-- TOC entry 3635 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN usfonpto.token; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpto.token IS 'Token generado';


--
-- TOC entry 3636 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN usfonpto.usfonproid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpto.usfonproid IS 'Identificador del usuario de fonprocine';


--
-- TOC entry 3637 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN usfonpto.fechacrea; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpto.fechacrea IS 'Fecha hora creacion del token';


--
-- TOC entry 3638 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN usfonpto.fechacadu; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpto.fechacadu IS 'Fecha hora caducidad del token';


--
-- TOC entry 3639 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN usfonpto.usado; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpto.usado IS 'Si el token fue usuario por el usuario o no';


--
-- TOC entry 223 (class 1259 OID 128587)
-- Dependencies: 9 222
-- Name: UsFonpTo_IDUsFonpTo_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE "UsFonpTo_IDUsFonpTo_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos."UsFonpTo_IDUsFonpTo_seq" OWNER TO postgres;

--
-- TOC entry 3640 (class 0 OID 0)
-- Dependencies: 223
-- Name: UsFonpTo_IDUsFonpTo_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "UsFonpTo_IDUsFonpTo_seq" OWNED BY usfonpto.id;


--
-- TOC entry 224 (class 1259 OID 128589)
-- Dependencies: 2430 2431 9
-- Name: usfonpro; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE usfonpro (
    id integer NOT NULL,
    login character varying(50) NOT NULL,
    password character varying(100) NOT NULL,
    nombre character varying(100) NOT NULL,
    email character varying(100) NOT NULL,
    telefofc character varying(12),
    extension character varying(6),
    departamid integer,
    cargoid integer,
    inactivo boolean DEFAULT false NOT NULL,
    pregsecrid integer,
    respuesta character varying(100),
    perusuid integer,
    ultlogin timestamp without time zone,
    usuarioid integer,
    ip character varying(15) NOT NULL,
    cedula character varying(15),
    ingreso_sistema boolean DEFAULT false
);


ALTER TABLE datos.usfonpro OWNER TO postgres;

--
-- TOC entry 3641 (class 0 OID 0)
-- Dependencies: 224
-- Name: TABLE usfonpro; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE usfonpro IS 'Tabla con los datos de los usuarios de la organizacion';


--
-- TOC entry 3642 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.id IS 'Identificador unico de usuario';


--
-- TOC entry 3643 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.login; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.login IS 'Login de usuario';


--
-- TOC entry 3644 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.password; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.password IS 'Passwrod de usuario';


--
-- TOC entry 3645 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.nombre IS 'Nombre del usuario';


--
-- TOC entry 3646 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.email; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.email IS 'Email del usuario';


--
-- TOC entry 3647 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.telefofc; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.telefofc IS 'Telefono de oficina';


--
-- TOC entry 3648 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.extension; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.extension IS 'Extension telefonica';


--
-- TOC entry 3649 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.departamid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.departamid IS 'Identificador del departamento al que pertenece el usuario';


--
-- TOC entry 3650 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.cargoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.cargoid IS 'Identificador del cargo del usuario';


--
-- TOC entry 3651 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.inactivo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.inactivo IS 'Si el usuario esta inactivo o no';


--
-- TOC entry 3652 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.pregsecrid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.pregsecrid IS 'Identificador de la pregunta secreta';


--
-- TOC entry 3653 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.respuesta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.respuesta IS 'Hash de la respuesta a la pregunta secreta';


--
-- TOC entry 3654 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.perusuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.perusuid IS 'Identificador del perfil de usuario';


--
-- TOC entry 3655 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.ultlogin; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.ultlogin IS 'Fecha hora del login del usuario al sistema';


--
-- TOC entry 3656 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.usuarioid IS 'Identificador del usuario que creo el registro o del ultimo que lo modifico';


--
-- TOC entry 3657 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 225 (class 1259 OID 128597)
-- Dependencies: 9 224
-- Name: Usuarios_IDUsuario_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE "Usuarios_IDUsuario_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos."Usuarios_IDUsuario_seq" OWNER TO postgres;

--
-- TOC entry 3658 (class 0 OID 0)
-- Dependencies: 225
-- Name: Usuarios_IDUsuario_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "Usuarios_IDUsuario_seq" OWNED BY usfonpro.id;


--
-- TOC entry 226 (class 1259 OID 128599)
-- Dependencies: 2433 2434 2435 9
-- Name: accionis; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE accionis (
    id integer DEFAULT nextval('"Accionis_ID_seq"'::regclass) NOT NULL,
    contribuid integer NOT NULL,
    nombre character varying(100) NOT NULL,
    apellido character varying(100) NOT NULL,
    ci character varying(20) NOT NULL,
    domfiscal character varying(500),
    nuacciones integer DEFAULT 0 NOT NULL,
    valaccion numeric(18,2) DEFAULT 0,
    cextra1 character varying(200),
    cextra2 character varying(200),
    cextra3 character varying(200),
    cextra4 character varying(200),
    cextra5 character varying(200),
    usuarioid integer,
    ip character varying(15) NOT NULL
);


ALTER TABLE datos.accionis OWNER TO postgres;

--
-- TOC entry 3659 (class 0 OID 0)
-- Dependencies: 226
-- Name: TABLE accionis; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE accionis IS 'Tabla con los datos de los Accionistas de los contribuyentes';


--
-- TOC entry 3660 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.id IS 'Identificador unico del accionista';


--
-- TOC entry 3661 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.contribuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.contribuid IS 'Identificador del contribuyente';


--
-- TOC entry 3662 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.nombre IS 'Nombre del accionista';


--
-- TOC entry 3663 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.apellido; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.apellido IS 'Apellidos del accionista';


--
-- TOC entry 3664 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.ci; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.ci IS 'Cedula de identidad, numero de pasaporte';


--
-- TOC entry 3665 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.domfiscal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.domfiscal IS 'Domicilio fiscal del accionista';


--
-- TOC entry 3666 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.nuacciones; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.nuacciones IS 'Numero de acciones';


--
-- TOC entry 3667 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.valaccion; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.valaccion IS 'Valor nominal de las acciones';


--
-- TOC entry 3668 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.cextra1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.cextra1 IS 'Campo extra 1';


--
-- TOC entry 3669 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.cextra2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.cextra2 IS 'Campo extra 2';


--
-- TOC entry 3670 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.cextra3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.cextra3 IS 'Campo extra 3';


--
-- TOC entry 3671 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.cextra4; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.cextra4 IS 'Campo extra 4';


--
-- TOC entry 3672 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.cextra5; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.cextra5 IS 'Campo extra 5';


--
-- TOC entry 3673 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3674 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 227 (class 1259 OID 128608)
-- Dependencies: 2436 9
-- Name: actas_reparo; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE actas_reparo (
    id integer NOT NULL,
    numero character varying,
    ruta_servidor character varying,
    fecha_adjunto timestamp without time zone DEFAULT now() NOT NULL,
    usuarioid integer,
    ip character varying
);


ALTER TABLE datos.actas_reparo OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 128615)
-- Dependencies: 9 227
-- Name: actas_reparo_id_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE actas_reparo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos.actas_reparo_id_seq OWNER TO postgres;

--
-- TOC entry 3675 (class 0 OID 0)
-- Dependencies: 228
-- Name: actas_reparo_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE actas_reparo_id_seq OWNED BY actas_reparo.id;


--
-- TOC entry 229 (class 1259 OID 128617)
-- Dependencies: 2438 2439 2440 2441 2442 2443 2444 2445 9
-- Name: asiento; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE asiento (
    id integer DEFAULT nextval('"Asiento_IDAsiento_seq"'::regclass) NOT NULL,
    nuasiento integer DEFAULT 0 NOT NULL,
    fecha date NOT NULL,
    mes smallint DEFAULT 0 NOT NULL,
    ano smallint DEFAULT 0 NOT NULL,
    debe numeric(18,2) DEFAULT 0 NOT NULL,
    haber numeric(18,2) DEFAULT 0 NOT NULL,
    saldo numeric(18,2) DEFAULT 0 NOT NULL,
    comentar character varying(500) NOT NULL,
    cerrado boolean DEFAULT false NOT NULL,
    uscierreid integer,
    usuarioid integer NOT NULL,
    ip character varying(15) NOT NULL
);


ALTER TABLE datos.asiento OWNER TO postgres;

--
-- TOC entry 3676 (class 0 OID 0)
-- Dependencies: 229
-- Name: TABLE asiento; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE asiento IS 'Tabla con los datos cabecera de los asiento contable';


--
-- TOC entry 3677 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN asiento.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.id IS 'Identificador unico de registro';


--
-- TOC entry 3678 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN asiento.nuasiento; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.nuasiento IS 'Numero de asiento. Empieza en uno al comienzo de cada mes.

Este valor de este campo lo asigna la base de datos';


--
-- TOC entry 3679 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN asiento.fecha; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.fecha IS 'Fecha del asiento';


--
-- TOC entry 3680 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN asiento.mes; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.mes IS 'Mes del asiento. Lo utilizamos para evitar que se utilice un numero de asiento repetido para un mes/año.

Este valor de este campo lo asigna la base de datos';


--
-- TOC entry 3681 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN asiento.ano; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.ano IS 'Año del asiento. Lo utilizamos para evitar que se utilice un numero de asiento repetido para un mes/año.

Este valor de este campo lo asigna la base de datos';


--
-- TOC entry 3682 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN asiento.debe; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.debe IS 'Sumatoria del debe del asiento.

Este valor de este campo lo asigna la base de datos';


--
-- TOC entry 3683 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN asiento.haber; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.haber IS 'Sumatoria del debe del asiento.

Este valor de este campo lo asigna la base de datos';


--
-- TOC entry 3684 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN asiento.saldo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.saldo IS 'Saldo del asiento.

Este valor de este campo lo asigna la base de datos.';


--
-- TOC entry 3685 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN asiento.comentar; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.comentar IS 'Comentario u observaciones del asiento';


--
-- TOC entry 3686 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN asiento.cerrado; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.cerrado IS 'Si el asiento esta cerrado o no. Solo se pueden cerrar asientos que el saldo sea 0. Un asiento cerrado no puede ser modificado';


--
-- TOC entry 3687 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN asiento.uscierreid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.uscierreid IS 'Identificador del usuario que cerro el asiento';


--
-- TOC entry 3688 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN asiento.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.usuarioid IS 'Identificador del ultimo usuario en crear o modificar el registro';


--
-- TOC entry 3689 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN asiento.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 230 (class 1259 OID 128631)
-- Dependencies: 9
-- Name: asientom; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE asientom (
    id integer NOT NULL,
    nombre character varying(200) NOT NULL,
    comentar character varying(500),
    usuarioid integer NOT NULL,
    ip character varying(15) NOT NULL
);


ALTER TABLE datos.asientom OWNER TO postgres;

--
-- TOC entry 3690 (class 0 OID 0)
-- Dependencies: 230
-- Name: TABLE asientom; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE asientom IS 'Tabla con los asientos modelos a utilizar';


--
-- TOC entry 3691 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN asientom.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientom.id IS 'Identificador unico de registro';


--
-- TOC entry 3692 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN asientom.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientom.nombre IS 'nombre del asiento modelo';


--
-- TOC entry 3693 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN asientom.comentar; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientom.comentar IS 'Comentarios u observaciones';


--
-- TOC entry 3694 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN asientom.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientom.usuarioid IS 'Identificador del usuario que creo o el ultimo en modificar el registro';


--
-- TOC entry 3695 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN asientom.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientom.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 231 (class 1259 OID 128637)
-- Dependencies: 9 230
-- Name: asientom_id_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE asientom_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos.asientom_id_seq OWNER TO postgres;

--
-- TOC entry 3696 (class 0 OID 0)
-- Dependencies: 231
-- Name: asientom_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE asientom_id_seq OWNED BY asientom.id;


--
-- TOC entry 232 (class 1259 OID 128639)
-- Dependencies: 2447 9
-- Name: asientomd; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE asientomd (
    id integer NOT NULL,
    asientomid integer NOT NULL,
    cuenta character varying(14) NOT NULL,
    sentido smallint DEFAULT 0 NOT NULL,
    usuarioid integer NOT NULL,
    ip character varying(15)
);


ALTER TABLE datos.asientomd OWNER TO postgres;

--
-- TOC entry 3697 (class 0 OID 0)
-- Dependencies: 232
-- Name: TABLE asientomd; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE asientomd IS 'Tabla con el detalle de los asientos modelos';


--
-- TOC entry 3698 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN asientomd.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientomd.id IS 'Identificador unico de registro';


--
-- TOC entry 3699 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN asientomd.asientomid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientomd.asientomid IS 'Identificador del asiento';


--
-- TOC entry 3700 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN asientomd.cuenta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientomd.cuenta IS 'Cuenta contable';


--
-- TOC entry 3701 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN asientomd.sentido; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientomd.sentido IS 'Sentido del monto. 0=debe / 1=haber';


--
-- TOC entry 3702 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN asientomd.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientomd.usuarioid IS 'Identificador del usuario que creo el registro o del ultimo en modificarlo';


--
-- TOC entry 3703 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN asientomd.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientomd.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 233 (class 1259 OID 128643)
-- Dependencies: 232 9
-- Name: asientomd_id_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE asientomd_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos.asientomd_id_seq OWNER TO postgres;

--
-- TOC entry 3704 (class 0 OID 0)
-- Dependencies: 233
-- Name: asientomd_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE asientomd_id_seq OWNED BY asientomd.id;


--
-- TOC entry 234 (class 1259 OID 128645)
-- Dependencies: 2449 2450 9
-- Name: asignacion_fiscales; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE asignacion_fiscales (
    id integer NOT NULL,
    fecha_asignacion date DEFAULT now(),
    usfonproid integer,
    conusuid integer,
    prioridad boolean DEFAULT false NOT NULL,
    estatus integer,
    fecha_fiscalizacion date,
    usuarioid integer,
    ip character varying,
    tipocontid integer,
    nro_autorizacion character varying,
    periodo_afiscalizar numeric
);


ALTER TABLE datos.asignacion_fiscales OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 128653)
-- Dependencies: 234 9
-- Name: asignacion_fiscales_id_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE asignacion_fiscales_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos.asignacion_fiscales_id_seq OWNER TO postgres;

--
-- TOC entry 3705 (class 0 OID 0)
-- Dependencies: 235
-- Name: asignacion_fiscales_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE asignacion_fiscales_id_seq OWNED BY asignacion_fiscales.id;


--
-- TOC entry 236 (class 1259 OID 128655)
-- Dependencies: 2452 9
-- Name: con_img_doc; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE con_img_doc (
    id integer NOT NULL,
    conusuid integer,
    descripcion character varying(255),
    usuarioid integer NOT NULL,
    ip character varying(255) NOT NULL,
    ruta_imagen character varying(255),
    fecha date DEFAULT now() NOT NULL
);


ALTER TABLE datos.con_img_doc OWNER TO postgres;

--
-- TOC entry 3706 (class 0 OID 0)
-- Dependencies: 236
-- Name: TABLE con_img_doc; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE con_img_doc IS 'Tabla con las imagenes de los documentos subidos por los contribuyentes adjunto a la planilla de complementaria de datos para el registro.';


--
-- TOC entry 3707 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN con_img_doc.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN con_img_doc.id IS 'Campo principal, valor unico identificador.';


--
-- TOC entry 3708 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN con_img_doc.conusuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN con_img_doc.conusuid IS 'ID  del contribuyente al cual estan asociados los documentos guardados.';


--
-- TOC entry 237 (class 1259 OID 128662)
-- Dependencies: 236 9
-- Name: con_img_doc_id_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE con_img_doc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos.con_img_doc_id_seq OWNER TO postgres;

--
-- TOC entry 3709 (class 0 OID 0)
-- Dependencies: 237
-- Name: con_img_doc_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE con_img_doc_id_seq OWNED BY con_img_doc.id;


--
-- TOC entry 238 (class 1259 OID 128664)
-- Dependencies: 2454 9
-- Name: contrib_calc; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE contrib_calc (
    id integer NOT NULL,
    conusuid integer,
    usuarioid integer,
    ip character varying(255),
    tipocontid integer,
    fecha_registro_fila timestamp without time zone DEFAULT now() NOT NULL,
    fecha_notificacion timestamp without time zone,
    proceso character varying
);


ALTER TABLE datos.contrib_calc OWNER TO postgres;

--
-- TOC entry 3710 (class 0 OID 0)
-- Dependencies: 238
-- Name: TABLE contrib_calc; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE contrib_calc IS 'Tabla de los contribuyentes a los que se aplicaran calculos';


--
-- TOC entry 3711 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN contrib_calc.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contrib_calc.id IS 'Identificador de los contribuyentes a los que se aplicaran calculos';


--
-- TOC entry 3712 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN contrib_calc.conusuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contrib_calc.conusuid IS 'Identificador de los contribuyentes para capturar su informacion';


--
-- TOC entry 239 (class 1259 OID 128671)
-- Dependencies: 9 238
-- Name: contrib_calc_id_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE contrib_calc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos.contrib_calc_id_seq OWNER TO postgres;

--
-- TOC entry 3713 (class 0 OID 0)
-- Dependencies: 239
-- Name: contrib_calc_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE contrib_calc_id_seq OWNED BY contrib_calc.id;


--
-- TOC entry 240 (class 1259 OID 128673)
-- Dependencies: 9
-- Name: contributi; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE contributi (
    id integer NOT NULL,
    contribuid integer NOT NULL,
    tipocontid integer NOT NULL,
    ip character varying(15) NOT NULL
);


ALTER TABLE datos.contributi OWNER TO postgres;

--
-- TOC entry 3714 (class 0 OID 0)
-- Dependencies: 240
-- Name: TABLE contributi; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE contributi IS 'tabla con los tipo de contribuyentes por contribuyente';


--
-- TOC entry 3715 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN contributi.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contributi.id IS 'Identificador unico de registro';


--
-- TOC entry 3716 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN contributi.contribuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contributi.contribuid IS 'Id del contribuyente';


--
-- TOC entry 3717 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN contributi.tipocontid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contributi.tipocontid IS 'Identificador del tipo de contribuyente';


--
-- TOC entry 3718 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN contributi.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contributi.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 241 (class 1259 OID 128676)
-- Dependencies: 240 9
-- Name: contributi_id_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE contributi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos.contributi_id_seq OWNER TO postgres;

--
-- TOC entry 3719 (class 0 OID 0)
-- Dependencies: 241
-- Name: contributi_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE contributi_id_seq OWNED BY contributi.id;


--
-- TOC entry 242 (class 1259 OID 128678)
-- Dependencies: 2457 2458 2459 9
-- Name: conusu_interno; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE conusu_interno (
    id bigint NOT NULL,
    fecha_entrada timestamp without time zone DEFAULT now() NOT NULL,
    conusuid integer,
    bln_fiscalizado boolean DEFAULT false NOT NULL,
    bln_nocontribuyente boolean DEFAULT false NOT NULL,
    observaciones character varying,
    usuarioid integer,
    ip character varying
);


ALTER TABLE datos.conusu_interno OWNER TO postgres;

--
-- TOC entry 3720 (class 0 OID 0)
-- Dependencies: 242
-- Name: TABLE conusu_interno; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE conusu_interno IS 'tabla que contiene el detalle de el reistro echo en conusu cuando este lo halla echo un usuario interno en recaudacion';


--
-- TOC entry 243 (class 1259 OID 128687)
-- Dependencies: 242 9
-- Name: conusu_interno_id_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE conusu_interno_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos.conusu_interno_id_seq OWNER TO postgres;

--
-- TOC entry 3721 (class 0 OID 0)
-- Dependencies: 243
-- Name: conusu_interno_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE conusu_interno_id_seq OWNED BY conusu_interno.id;


--
-- TOC entry 244 (class 1259 OID 128689)
-- Dependencies: 2461 9
-- Name: conusu_tipocont; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE conusu_tipocont (
    id integer NOT NULL,
    conusuid integer NOT NULL,
    tipocontid integer,
    ip character varying(20) NOT NULL,
    fecha_elaboracion date DEFAULT now()
);


ALTER TABLE datos.conusu_tipocont OWNER TO postgres;

--
-- TOC entry 3722 (class 0 OID 0)
-- Dependencies: 244
-- Name: COLUMN conusu_tipocont.conusuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu_tipocont.conusuid IS 'Campo que se relaciona con la tabla del contribuyente (conusu)';


--
-- TOC entry 3723 (class 0 OID 0)
-- Dependencies: 244
-- Name: COLUMN conusu_tipocont.tipocontid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu_tipocont.tipocontid IS 'Campo que establece la relacion con los tipos de contribuyentes';


--
-- TOC entry 245 (class 1259 OID 128693)
-- Dependencies: 244 9
-- Name: conusu_tipocon_id_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE conusu_tipocon_id_seq
    START WITH 1
    INCREMENT BY 1
    MINVALUE 0
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos.conusu_tipocon_id_seq OWNER TO postgres;

--
-- TOC entry 3724 (class 0 OID 0)
-- Dependencies: 245
-- Name: conusu_tipocon_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE conusu_tipocon_id_seq OWNED BY conusu_tipocont.id;


--
-- TOC entry 246 (class 1259 OID 128695)
-- Dependencies: 9
-- Name: correlativos_actas; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE correlativos_actas (
    id bigint NOT NULL,
    nombre character varying,
    correlativo integer,
    anio integer,
    tipo character varying
);


ALTER TABLE datos.correlativos_actas OWNER TO postgres;

--
-- TOC entry 247 (class 1259 OID 128701)
-- Dependencies: 246 9
-- Name: correlativos_actas_id_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE correlativos_actas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos.correlativos_actas_id_seq OWNER TO postgres;

--
-- TOC entry 3725 (class 0 OID 0)
-- Dependencies: 247
-- Name: correlativos_actas_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE correlativos_actas_id_seq OWNED BY correlativos_actas.id;


--
-- TOC entry 248 (class 1259 OID 128703)
-- Dependencies: 9
-- Name: correos_enviados; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE correos_enviados (
    id integer NOT NULL,
    rif character varying(255),
    email_enviar character varying(255),
    asunto_enviar character varying(255),
    contenido_enviar text,
    ip character varying(255),
    usuarioid integer,
    fecha_envio timestamp without time zone,
    procesado boolean
);


ALTER TABLE datos.correos_enviados OWNER TO postgres;

--
-- TOC entry 249 (class 1259 OID 128709)
-- Dependencies: 248 9
-- Name: correos_enviados_id_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE correos_enviados_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos.correos_enviados_id_seq OWNER TO postgres;

--
-- TOC entry 3726 (class 0 OID 0)
-- Dependencies: 249
-- Name: correos_enviados_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE correos_enviados_id_seq OWNED BY correos_enviados.id;


--
-- TOC entry 250 (class 1259 OID 128711)
-- Dependencies: 2465 2466 9
-- Name: ctaconta; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE ctaconta (
    cuenta character varying(14) NOT NULL,
    descripcion character varying(200),
    usaraux boolean DEFAULT false NOT NULL,
    inactiva boolean DEFAULT false NOT NULL,
    usuarioid integer NOT NULL,
    ip character varying(15) NOT NULL
);


ALTER TABLE datos.ctaconta OWNER TO postgres;

--
-- TOC entry 3727 (class 0 OID 0)
-- Dependencies: 250
-- Name: TABLE ctaconta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE ctaconta IS 'Tabla con el plan de cuentas contables a utilizar.';


--
-- TOC entry 3728 (class 0 OID 0)
-- Dependencies: 250
-- Name: COLUMN ctaconta.cuenta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN ctaconta.cuenta IS 'Codigo de cuenta contable en formato:
X.XX.XX.XX.XX.XXXXX
X=Grupo
X.XX=Rubro
X.XX.XX=Generico
X.XX.XX.XX=Especifico
X.XX.XX.XX.XX=Sub-Especifico
X.XX.XX.XX.XX.XXXXX=Auxiliares';


--
-- TOC entry 3729 (class 0 OID 0)
-- Dependencies: 250
-- Name: COLUMN ctaconta.descripcion; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN ctaconta.descripcion IS 'Descripcion de la cuenta';


--
-- TOC entry 3730 (class 0 OID 0)
-- Dependencies: 250
-- Name: COLUMN ctaconta.usaraux; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN ctaconta.usaraux IS 'Si la cuenta usara auxiliares. Esto es para el caso de una cuenta que no use auxiliar, esta podra tener movimiento a nivel de sub-especifico';


--
-- TOC entry 3731 (class 0 OID 0)
-- Dependencies: 250
-- Name: COLUMN ctaconta.inactiva; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN ctaconta.inactiva IS 'Si la cuenta esta inactiva o no';


--
-- TOC entry 3732 (class 0 OID 0)
-- Dependencies: 250
-- Name: COLUMN ctaconta.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN ctaconta.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3733 (class 0 OID 0)
-- Dependencies: 250
-- Name: COLUMN ctaconta.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN ctaconta.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 251 (class 1259 OID 128716)
-- Dependencies: 2467 2468 2469 2470 2471 2472 2473 2474 9
-- Name: declara; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE declara (
    id integer DEFAULT nextval('"Declara_IDDeclara_seq"'::regclass) NOT NULL,
    nudeclara character varying,
    nudeposito character varying,
    tdeclaraid integer NOT NULL,
    fechaelab timestamp without time zone NOT NULL,
    fechaini date NOT NULL,
    fechafin date NOT NULL,
    replegalid integer NOT NULL,
    baseimpo numeric(18,2) DEFAULT 0 NOT NULL,
    alicuota numeric(18,2) DEFAULT 0 NOT NULL,
    exonera numeric(18,2) DEFAULT 0 NOT NULL,
    nuactoexon character varying(10),
    credfiscal numeric(18,2) DEFAULT 0 NOT NULL,
    contribant numeric(18,2),
    plasustid integer,
    montopagar numeric(18,2) DEFAULT 0 NOT NULL,
    bln_reparo boolean DEFAULT false NOT NULL,
    fechapago date,
    fechaconci timestamp without time zone,
    asientoid integer,
    usuarioid integer,
    ip character varying(15) NOT NULL,
    tipocontribuid integer NOT NULL,
    conusuid integer,
    calpagodid integer NOT NULL,
    reparoid integer,
    proceso character varying,
    bln_declaro0 boolean DEFAULT false,
    fecha_carga_pago timestamp without time zone
);


ALTER TABLE datos.declara OWNER TO postgres;

--
-- TOC entry 3734 (class 0 OID 0)
-- Dependencies: 251
-- Name: TABLE declara; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE declara IS 'Planilla de declaracion de impuestos';


--
-- TOC entry 3735 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN declara.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.id IS 'Identificador unico de la declaracion de impuestos';


--
-- TOC entry 3736 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN declara.nudeclara; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.nudeclara IS 'Numero de planilla de declaracion de impuesto';


--
-- TOC entry 3737 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN declara.nudeposito; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.nudeposito IS 'Numero de deposito bancario generado por el sistema';


--
-- TOC entry 3738 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN declara.tdeclaraid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.tdeclaraid IS 'Identificador del tipo de declaracion';


--
-- TOC entry 3739 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN declara.fechaelab; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.fechaelab IS 'Fecha de elaboracion de la planilla de pago de impuestos';


--
-- TOC entry 3740 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN declara.fechaini; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.fechaini IS 'Fecha de inicio del periodo gravable';


--
-- TOC entry 3741 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN declara.fechafin; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.fechafin IS 'Fecha final del periodo gravable';


--
-- TOC entry 3742 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN declara.replegalid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.replegalid IS 'Identificador del representante legal que aparecera en la planilla y firmara la misma';


--
-- TOC entry 3743 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN declara.baseimpo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.baseimpo IS 'Base imponible';


--
-- TOC entry 3744 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN declara.alicuota; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.alicuota IS 'Alicuota impositiva aplicada a la declaracion de impuesto';


--
-- TOC entry 3745 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN declara.exonera; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.exonera IS 'Exoneracion o rebaja';


--
-- TOC entry 3746 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN declara.nuactoexon; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.nuactoexon IS 'Numero de acto en donde se establece la exoneracion o rebaja';


--
-- TOC entry 3747 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN declara.credfiscal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.credfiscal IS 'Credito fiscal';


--
-- TOC entry 3748 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN declara.contribant; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.contribant IS 'Monto de la contribucion pagada en periodos anteriores';


--
-- TOC entry 3749 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN declara.plasustid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.plasustid IS 'Identificador de la planilla que se esta sustituyendo en caso de ser una declaracion sustitutiva';


--
-- TOC entry 3750 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN declara.montopagar; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.montopagar IS 'Monto a pagar';


--
-- TOC entry 3751 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN declara.fechapago; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.fechapago IS 'Fecha de pago en el banco. Se llena este campo cuando se concilian los pagos';


--
-- TOC entry 3752 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN declara.fechaconci; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.fechaconci IS 'Fecha hora de la conciliacion contra los depositos del banco';


--
-- TOC entry 3753 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN declara.asientoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.asientoid IS 'Identificador del asiento contable en donde se registro la informacion del pago';


--
-- TOC entry 3754 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN declara.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.usuarioid IS 'Identificador del usuario que concilio el pago de la declaracion. ';


--
-- TOC entry 3755 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN declara.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 252 (class 1259 OID 128730)
-- Dependencies: 3169 9
-- Name: datos_planilla_declaracion; Type: VIEW; Schema: datos; Owner: postgres
--

CREATE VIEW datos_planilla_declaracion AS
    SELECT conusu.nombre AS razonsocia, contribu.dencomerci, conusu.rif, contribu.numregcine, contribu.domfiscal, contribu.zonapostal, contribu.telef1, conusu.email, actiecon.nombre AS actiecon, estados.nombre AS nestados, ciudades.nombre AS nciudades, replegal.nombre AS nrplegal, replegal.ci AS cedulareplegal, replegal.telefhab AS telereplegal, replegal.domfiscal AS direccionreplegal, replegal.email AS emailreplegal, declara.nudeclara, to_char((declara.fechaini)::timestamp with time zone, 'dd-mm-YYYY'::text) AS fechai, to_char((declara.fechafin)::timestamp with time zone, 'dd-mm-YYYY'::text) AS fechafin, declara.baseimpo, declara.montopagar, declara.alicuota, declara.id, declara.exonera, declara.credfiscal, declara.contribant, tdeclara.nombre AS ntdeclara, tipocont.nombre AS ntipocont, declara.tdeclaraid, tipocont.id AS tipocontid, tipegrav.tipe AS tipo_periodo, calpagod.periodo AS periodo_declara, calpago.ano AS anio_declara FROM (((((((((((declara JOIN conusu ON ((conusu.id = declara.conusuid))) JOIN contribu ON (((conusu.rif)::text = (contribu.rif)::text))) JOIN actiecon ON ((contribu.actieconid = actiecon.id))) JOIN ciudades ON ((contribu.ciudadid = ciudades.id))) JOIN estados ON ((contribu.estadoid = estados.id))) JOIN tdeclara ON ((declara.tdeclaraid = tdeclara.id))) JOIN tipocont ON ((declara.tipocontribuid = tipocont.id))) JOIN tipegrav ON ((tipegrav.id = tipocont.tipegravid))) JOIN replegal ON ((replegal.id = declara.replegalid))) JOIN calpagod ON ((calpagod.id = declara.calpagodid))) JOIN calpago ON ((calpago.id = calpagod.calpagoid)));


ALTER TABLE datos.datos_planilla_declaracion OWNER TO postgres;

SET search_path = pre_aprobacion, pg_catalog;

--
-- TOC entry 253 (class 1259 OID 128735)
-- Dependencies: 2475 6
-- Name: intereses; Type: TABLE; Schema: pre_aprobacion; Owner: postgres; Tablespace: 
--

CREATE TABLE intereses (
    id integer NOT NULL,
    numresolucion character varying,
    numactafiscal character varying,
    felaboracion timestamp without time zone DEFAULT now(),
    fnotificacion date,
    totalpagar numeric NOT NULL,
    multaid integer,
    ip character varying,
    usuarioid integer,
    fecha_inicio date,
    fecha_fin date,
    nudeposito character varying,
    fecha_pago timestamp without time zone,
    fecha_carga_pago timestamp without time zone
);


ALTER TABLE pre_aprobacion.intereses OWNER TO postgres;

--
-- TOC entry 3756 (class 0 OID 0)
-- Dependencies: 253
-- Name: COLUMN intereses.multaid; Type: COMMENT; Schema: pre_aprobacion; Owner: postgres
--

COMMENT ON COLUMN intereses.multaid IS 'campor para relacionar con la tabla de multas';


--
-- TOC entry 254 (class 1259 OID 128742)
-- Dependencies: 6
-- Name: multas; Type: TABLE; Schema: pre_aprobacion; Owner: postgres; Tablespace: 
--

CREATE TABLE multas (
    id integer NOT NULL,
    nresolucion character varying NOT NULL,
    fechaelaboracion timestamp without time zone,
    fechanotificacion date,
    montopagar numeric,
    declaraid integer,
    ip character varying,
    usuarioid integer,
    tipo_multa integer,
    nudeposito character varying,
    fechapago timestamp without time zone,
    fecha_carga_pago timestamp without time zone,
    numero_session character varying,
    fecha_session timestamp without time zone
);


ALTER TABLE pre_aprobacion.multas OWNER TO postgres;

--
-- TOC entry 3757 (class 0 OID 0)
-- Dependencies: 254
-- Name: TABLE multas; Type: COMMENT; Schema: pre_aprobacion; Owner: postgres
--

COMMENT ON TABLE multas IS 'tabla que contiene el calculo de las multas por declaraciones extemporaneas o reparo fiscal';


SET search_path = datos, pg_catalog;

--
-- TOC entry 255 (class 1259 OID 128748)
-- Dependencies: 3170 9
-- Name: datos_planilla_multa_interese; Type: VIEW; Schema: datos; Owner: postgres
--

CREATE VIEW datos_planilla_multa_interese AS
    SELECT multas.nresolucion, multas.fechanotificacion, multas.montopagar AS total_multa, multas.id AS id_multa, intereses.totalpagar AS total_interes, conusu.nombre AS razonsocia, contribu.dencomerci, conusu.rif, contribu.numregcine, contribu.domfiscal, contribu.zonapostal, contribu.telef1, conusu.email, actiecon.nombre AS actiecon, estados.nombre AS nestados, ciudades.nombre AS nciudades, replegal.nombre AS nrplegal, replegal.ci AS cedulareplegal, replegal.telefhab AS telereplegal, replegal.domfiscal AS direccionreplegal, replegal.email AS emailreplegal, declara.nudeclara, to_char((declara.fechaini)::timestamp with time zone, 'dd-mm-YYYY'::text) AS fechai, to_char((declara.fechafin)::timestamp with time zone, 'dd-mm-YYYY'::text) AS fechafin, declara.baseimpo, declara.montopagar, declara.alicuota, declara.id, declara.exonera, declara.credfiscal, declara.contribant, tdeclara.nombre AS ntdeclara, tipocont.nombre AS ntipocont, tipocont.numero_articulo AS narticulo, tipocont.cita_articulo AS text_articulo, tdeclara.id AS tdeclaraid, tipocont.id AS tipocontid, tipegrav.tipe AS tipo_periodo, calpagod.periodo AS periodo_declara, calpago.ano AS anio_declara FROM (((((((((((((pre_aprobacion.multas JOIN pre_aprobacion.intereses ON ((intereses.multaid = multas.id))) JOIN declara ON ((multas.declaraid = declara.id))) JOIN conusu ON ((conusu.id = declara.conusuid))) LEFT JOIN contribu ON (((conusu.rif)::text = (contribu.rif)::text))) LEFT JOIN actiecon ON ((contribu.actieconid = actiecon.id))) LEFT JOIN ciudades ON ((contribu.ciudadid = ciudades.id))) LEFT JOIN estados ON ((contribu.estadoid = estados.id))) JOIN tdeclara ON ((multas.tipo_multa = tdeclara.id))) JOIN tipocont ON ((declara.tipocontribuid = tipocont.id))) JOIN tipegrav ON ((tipegrav.id = tipocont.tipegravid))) JOIN replegal ON ((replegal.id = declara.replegalid))) JOIN calpagod ON ((calpagod.id = declara.calpagodid))) JOIN calpago ON ((calpago.id = calpagod.calpagoid)));


ALTER TABLE datos.datos_planilla_multa_interese OWNER TO postgres;

--
-- TOC entry 256 (class 1259 OID 128753)
-- Dependencies: 9
-- Name: descargos; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE descargos (
    id bigint NOT NULL,
    fecha timestamp without time zone,
    compareciente character varying,
    cargo_comp character varying,
    reparoid integer,
    usuario integer,
    ip character varying,
    estatus character varying NOT NULL
);


ALTER TABLE datos.descargos OWNER TO postgres;

--
-- TOC entry 257 (class 1259 OID 128759)
-- Dependencies: 9 256
-- Name: descargos_id_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE descargos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos.descargos_id_seq OWNER TO postgres;

--
-- TOC entry 3758 (class 0 OID 0)
-- Dependencies: 257
-- Name: descargos_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE descargos_id_seq OWNED BY descargos.id;


--
-- TOC entry 258 (class 1259 OID 128761)
-- Dependencies: 9
-- Name: detalle_interes; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE detalle_interes (
    id integer NOT NULL,
    intereses numeric(18,6),
    tasa numeric(18,6),
    dias integer,
    mes character varying,
    anio integer,
    intereses_id integer,
    ip character varying,
    usuarioid integer,
    capital numeric,
    "tasa%" numeric
);


ALTER TABLE datos.detalle_interes OWNER TO postgres;

--
-- TOC entry 3759 (class 0 OID 0)
-- Dependencies: 258
-- Name: TABLE detalle_interes; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE detalle_interes IS 'Tabla para el registro de los detalles de los intereses';


--
-- TOC entry 3760 (class 0 OID 0)
-- Dependencies: 258
-- Name: COLUMN detalle_interes.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes.id IS 'Identificador del detalle de los intereses';


--
-- TOC entry 3761 (class 0 OID 0)
-- Dependencies: 258
-- Name: COLUMN detalle_interes.intereses; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes.intereses IS 'intereses por mes';


--
-- TOC entry 3762 (class 0 OID 0)
-- Dependencies: 258
-- Name: COLUMN detalle_interes.tasa; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes.tasa IS 'tasa por mes segun el bcv';


--
-- TOC entry 3763 (class 0 OID 0)
-- Dependencies: 258
-- Name: COLUMN detalle_interes.dias; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes.dias IS 'dias de los meses de cada periodo';


--
-- TOC entry 3764 (class 0 OID 0)
-- Dependencies: 258
-- Name: COLUMN detalle_interes.mes; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes.mes IS 'meses de los periodos para el pago de los intereses';


--
-- TOC entry 3765 (class 0 OID 0)
-- Dependencies: 258
-- Name: COLUMN detalle_interes.anio; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes.anio IS 'anio de periodos';


--
-- TOC entry 3766 (class 0 OID 0)
-- Dependencies: 258
-- Name: COLUMN detalle_interes.intereses_id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes.intereses_id IS 'identificador del id de  la tabla de intereses';


--
-- TOC entry 259 (class 1259 OID 128767)
-- Dependencies: 258 9
-- Name: detalle_interes_id_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE detalle_interes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos.detalle_interes_id_seq OWNER TO postgres;

--
-- TOC entry 3767 (class 0 OID 0)
-- Dependencies: 259
-- Name: detalle_interes_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE detalle_interes_id_seq OWNED BY detalle_interes.id;


--
-- TOC entry 260 (class 1259 OID 128769)
-- Dependencies: 9
-- Name: detalle_interes_viejo; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE detalle_interes_viejo (
    id integer NOT NULL,
    intereses character varying,
    tasa character varying,
    dias integer,
    mes character varying,
    anio integer,
    intereses_id integer,
    ip character varying,
    usuarioid integer
);


ALTER TABLE datos.detalle_interes_viejo OWNER TO postgres;

--
-- TOC entry 3768 (class 0 OID 0)
-- Dependencies: 260
-- Name: TABLE detalle_interes_viejo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE detalle_interes_viejo IS 'Tabla para el registro de los detalles de los intereses';


--
-- TOC entry 3769 (class 0 OID 0)
-- Dependencies: 260
-- Name: COLUMN detalle_interes_viejo.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes_viejo.id IS 'Identificador del detalle de los intereses';


--
-- TOC entry 3770 (class 0 OID 0)
-- Dependencies: 260
-- Name: COLUMN detalle_interes_viejo.intereses; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes_viejo.intereses IS 'intereses por mes';


--
-- TOC entry 3771 (class 0 OID 0)
-- Dependencies: 260
-- Name: COLUMN detalle_interes_viejo.tasa; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes_viejo.tasa IS 'tasa por mes segun el bcv';


--
-- TOC entry 3772 (class 0 OID 0)
-- Dependencies: 260
-- Name: COLUMN detalle_interes_viejo.dias; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes_viejo.dias IS 'dias de los meses de cada periodo';


--
-- TOC entry 3773 (class 0 OID 0)
-- Dependencies: 260
-- Name: COLUMN detalle_interes_viejo.mes; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes_viejo.mes IS 'meses de los periodos para el pago de los intereses';


--
-- TOC entry 3774 (class 0 OID 0)
-- Dependencies: 260
-- Name: COLUMN detalle_interes_viejo.anio; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes_viejo.anio IS 'anio de periodos';


--
-- TOC entry 3775 (class 0 OID 0)
-- Dependencies: 260
-- Name: COLUMN detalle_interes_viejo.intereses_id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes_viejo.intereses_id IS 'identificador del id de  la tabla de intereses';


--
-- TOC entry 261 (class 1259 OID 128775)
-- Dependencies: 260 9
-- Name: detalle_interes_id_seq1; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE detalle_interes_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos.detalle_interes_id_seq1 OWNER TO postgres;

--
-- TOC entry 3776 (class 0 OID 0)
-- Dependencies: 261
-- Name: detalle_interes_id_seq1; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE detalle_interes_id_seq1 OWNED BY detalle_interes_viejo.id;


--
-- TOC entry 262 (class 1259 OID 128777)
-- Dependencies: 9
-- Name: detalles_contrib_calc; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE detalles_contrib_calc (
    id integer NOT NULL,
    declaraid integer,
    contrib_calcid integer,
    proceso character varying,
    observacion character varying
);


ALTER TABLE datos.detalles_contrib_calc OWNER TO postgres;

--
-- TOC entry 263 (class 1259 OID 128783)
-- Dependencies: 262 9
-- Name: detalles_contrib_calc_id_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE detalles_contrib_calc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos.detalles_contrib_calc_id_seq OWNER TO postgres;

--
-- TOC entry 3777 (class 0 OID 0)
-- Dependencies: 263
-- Name: detalles_contrib_calc_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE detalles_contrib_calc_id_seq OWNED BY detalles_contrib_calc.id;


--
-- TOC entry 264 (class 1259 OID 128785)
-- Dependencies: 2482 2483 2484 9
-- Name: dettalles_fizcalizacion; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE dettalles_fizcalizacion (
    id integer NOT NULL,
    periodo integer,
    anio integer,
    base numeric,
    alicuota numeric(18,2),
    total numeric,
    asignacionfid integer,
    bln_borrado boolean DEFAULT false,
    calpagodid integer,
    bln_reparo_faltante boolean DEFAULT false,
    bln_identificador boolean DEFAULT true
);


ALTER TABLE datos.dettalles_fizcalizacion OWNER TO postgres;

--
-- TOC entry 265 (class 1259 OID 128794)
-- Dependencies: 264 9
-- Name: dettalles_fizcalizacion_id_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE dettalles_fizcalizacion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos.dettalles_fizcalizacion_id_seq OWNER TO postgres;

--
-- TOC entry 3778 (class 0 OID 0)
-- Dependencies: 265
-- Name: dettalles_fizcalizacion_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE dettalles_fizcalizacion_id_seq OWNED BY dettalles_fizcalizacion.id;


--
-- TOC entry 266 (class 1259 OID 128796)
-- Dependencies: 2486 9
-- Name: document; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE document (
    id integer NOT NULL,
    nombre character varying(200) NOT NULL,
    docu text NOT NULL,
    inactivo boolean DEFAULT false NOT NULL,
    usfonproid integer NOT NULL,
    ip character varying(15) NOT NULL
);


ALTER TABLE datos.document OWNER TO postgres;

--
-- TOC entry 3779 (class 0 OID 0)
-- Dependencies: 266
-- Name: TABLE document; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE document IS 'Tabla con los documentos legales utilizados por el sistema';


--
-- TOC entry 3780 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN document.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN document.id IS 'Identificador unico de registro';


--
-- TOC entry 3781 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN document.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN document.nombre IS 'Nombre del documento';


--
-- TOC entry 3782 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN document.docu; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN document.docu IS 'Texto del documento';


--
-- TOC entry 3783 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN document.inactivo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN document.inactivo IS 'Si el documento esta inactivo o activo';


--
-- TOC entry 3784 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN document.usfonproid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN document.usfonproid IS 'Identificador del ususario que creo o el ultimo que modifico el registro';


--
-- TOC entry 3785 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN document.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN document.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 267 (class 1259 OID 128803)
-- Dependencies: 266 9
-- Name: document_id_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE document_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos.document_id_seq OWNER TO postgres;

--
-- TOC entry 3786 (class 0 OID 0)
-- Dependencies: 267
-- Name: document_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE document_id_seq OWNED BY document.id;


--
-- TOC entry 268 (class 1259 OID 128805)
-- Dependencies: 9
-- Name: interes_bcv; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE interes_bcv (
    id integer NOT NULL,
    anio integer,
    tasa numeric(18,2),
    ip character varying,
    usuarioid integer,
    mes character varying
);


ALTER TABLE datos.interes_bcv OWNER TO postgres;

--
-- TOC entry 269 (class 1259 OID 128811)
-- Dependencies: 9
-- Name: interes_bcv2; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE interes_bcv2 (
    id integer NOT NULL,
    anio integer,
    tasa numeric(18,2),
    ip character varying,
    usuarioid integer,
    mes character varying
);


ALTER TABLE datos.interes_bcv2 OWNER TO postgres;

--
-- TOC entry 270 (class 1259 OID 128817)
-- Dependencies: 268 9
-- Name: interes_bcv_id_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE interes_bcv_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos.interes_bcv_id_seq OWNER TO postgres;

--
-- TOC entry 3787 (class 0 OID 0)
-- Dependencies: 270
-- Name: interes_bcv_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE interes_bcv_id_seq OWNED BY interes_bcv.id;


--
-- TOC entry 271 (class 1259 OID 128819)
-- Dependencies: 2489 9
-- Name: presidente; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE presidente (
    id bigint NOT NULL,
    nombres character varying,
    apellidos character varying,
    cedula integer,
    nro_decreto character varying,
    nro_gaceta character varying,
    dtm_fecha_gaceta character varying,
    bln_activo boolean DEFAULT true NOT NULL,
    usuarioid integer,
    ip character varying
);


ALTER TABLE datos.presidente OWNER TO postgres;

--
-- TOC entry 272 (class 1259 OID 128826)
-- Dependencies: 271 9
-- Name: presidente_id_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE presidente_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos.presidente_id_seq OWNER TO postgres;

--
-- TOC entry 3788 (class 0 OID 0)
-- Dependencies: 272
-- Name: presidente_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE presidente_id_seq OWNED BY presidente.id;


--
-- TOC entry 273 (class 1259 OID 128828)
-- Dependencies: 2491 2492 2493 2494 9
-- Name: reparos; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE reparos (
    id integer DEFAULT nextval('"Declara_IDDeclara_seq"'::regclass) NOT NULL,
    tdeclaraid integer NOT NULL,
    fechaelab timestamp without time zone NOT NULL,
    montopagar numeric(18,2) DEFAULT 0 NOT NULL,
    asientoid integer,
    usuarioid integer,
    ip character varying(15) NOT NULL,
    tipocontribuid integer NOT NULL,
    conusuid integer NOT NULL,
    bln_activo boolean DEFAULT false NOT NULL,
    proceso character varying,
    fecha_notificacion timestamp without time zone,
    bln_sumario boolean DEFAULT false NOT NULL,
    actaid integer,
    recibido_por character varying,
    asignacionid integer,
    fecha_autorizacion timestamp without time zone,
    fecha_requerimiento timestamp without time zone,
    fecha_recepcion timestamp without time zone
);


ALTER TABLE datos.reparos OWNER TO postgres;

--
-- TOC entry 3789 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN reparos.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN reparos.id IS 'Identificador unico de la declaracion de impuestos';


--
-- TOC entry 3790 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN reparos.tdeclaraid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN reparos.tdeclaraid IS 'Identificador del tipo de declaracion';


--
-- TOC entry 3791 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN reparos.fechaelab; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN reparos.fechaelab IS 'Fecha de elaboracion de la planilla de pago de impuestos';


--
-- TOC entry 3792 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN reparos.montopagar; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN reparos.montopagar IS 'Monto a pagar';


--
-- TOC entry 3793 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN reparos.asientoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN reparos.asientoid IS 'Identificador del asiento contable en donde se registro la informacion del pago';


--
-- TOC entry 3794 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN reparos.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN reparos.usuarioid IS 'Identificador del usuario que concilio el pago de la declaracion. ';


--
-- TOC entry 3795 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN reparos.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN reparos.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 274 (class 1259 OID 128838)
-- Dependencies: 2495 2496 9
-- Name: tmpaccioni; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE tmpaccioni (
    id integer NOT NULL,
    contribuid integer NOT NULL,
    nombre character varying(100) NOT NULL,
    apellido character varying(100) NOT NULL,
    ci character varying(20) NOT NULL,
    domfiscal character varying(500),
    nuacciones integer DEFAULT 0 NOT NULL,
    valaccion numeric(18,2) DEFAULT 0 NOT NULL,
    cextra1 character varying(200),
    cextra2 character varying(200),
    cextra3 character varying(200),
    cextra4 character varying(200),
    cextra5 character varying(200),
    ip character varying(15) NOT NULL
);


ALTER TABLE datos.tmpaccioni OWNER TO postgres;

--
-- TOC entry 3796 (class 0 OID 0)
-- Dependencies: 274
-- Name: TABLE tmpaccioni; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE tmpaccioni IS 'Tabla con los datos de los Accionistas de los contribuyentes';


--
-- TOC entry 3797 (class 0 OID 0)
-- Dependencies: 274
-- Name: COLUMN tmpaccioni.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.id IS 'Identificador unico del accionista';


--
-- TOC entry 3798 (class 0 OID 0)
-- Dependencies: 274
-- Name: COLUMN tmpaccioni.contribuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.contribuid IS 'Identificador del contribuyente';


--
-- TOC entry 3799 (class 0 OID 0)
-- Dependencies: 274
-- Name: COLUMN tmpaccioni.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.nombre IS 'Nombre del accionista';


--
-- TOC entry 3800 (class 0 OID 0)
-- Dependencies: 274
-- Name: COLUMN tmpaccioni.apellido; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.apellido IS 'Apellidos del accionista';


--
-- TOC entry 3801 (class 0 OID 0)
-- Dependencies: 274
-- Name: COLUMN tmpaccioni.ci; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.ci IS 'Cedula de identidad, numero de pasaporte';


--
-- TOC entry 3802 (class 0 OID 0)
-- Dependencies: 274
-- Name: COLUMN tmpaccioni.domfiscal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.domfiscal IS 'Domicilio fiscal del accionista';


--
-- TOC entry 3803 (class 0 OID 0)
-- Dependencies: 274
-- Name: COLUMN tmpaccioni.nuacciones; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.nuacciones IS 'Numero de acciones';


--
-- TOC entry 3804 (class 0 OID 0)
-- Dependencies: 274
-- Name: COLUMN tmpaccioni.valaccion; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.valaccion IS 'Valor nominal de las acciones';


--
-- TOC entry 3805 (class 0 OID 0)
-- Dependencies: 274
-- Name: COLUMN tmpaccioni.cextra1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.cextra1 IS 'Campo extra 1';


--
-- TOC entry 3806 (class 0 OID 0)
-- Dependencies: 274
-- Name: COLUMN tmpaccioni.cextra2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.cextra2 IS 'Campo extra 2';


--
-- TOC entry 3807 (class 0 OID 0)
-- Dependencies: 274
-- Name: COLUMN tmpaccioni.cextra3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.cextra3 IS 'Campo extra 3';


--
-- TOC entry 3808 (class 0 OID 0)
-- Dependencies: 274
-- Name: COLUMN tmpaccioni.cextra4; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.cextra4 IS 'Campo extra 4';


--
-- TOC entry 3809 (class 0 OID 0)
-- Dependencies: 274
-- Name: COLUMN tmpaccioni.cextra5; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.cextra5 IS 'Campo extra 5';


--
-- TOC entry 3810 (class 0 OID 0)
-- Dependencies: 274
-- Name: COLUMN tmpaccioni.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 275 (class 1259 OID 128846)
-- Dependencies: 2497 2498 2499 2500 9
-- Name: tmpcontri; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE tmpcontri (
    id integer NOT NULL,
    tipocontid integer NOT NULL,
    razonsocia character varying(350) NOT NULL,
    dencomerci character varying(200) NOT NULL,
    actieconid integer NOT NULL,
    rif character varying(20) NOT NULL,
    numregcine integer,
    domfiscal character varying(500) NOT NULL,
    estadoid integer NOT NULL,
    ciudadid integer NOT NULL,
    zonapostal character varying(10),
    telef1 character varying(11) NOT NULL,
    telef2 character varying(11),
    telef3 character varying(11),
    fax1 character varying(11),
    fax2 character varying(11),
    email character varying(100) NOT NULL,
    pinbb character varying(8),
    skype character varying(100),
    twitter character varying(100),
    facebook character varying(200),
    nuacciones integer DEFAULT 0 NOT NULL,
    valaccion numeric(18,2) DEFAULT 0 NOT NULL,
    capitalsus numeric(18,2) DEFAULT 0 NOT NULL,
    capitalpag numeric(18,2) DEFAULT 0 NOT NULL,
    regmerofc character varying(300) NOT NULL,
    rmnumero character varying(20) NOT NULL,
    rmfolio character varying(20) NOT NULL,
    rmtomo character varying(10) NOT NULL,
    rmfechapro date NOT NULL,
    rmncontrol character varying(20) NOT NULL,
    rmobjeto text NOT NULL,
    domcomer character varying(350),
    conusuid integer NOT NULL,
    tiporeg smallint,
    cextra1 character varying(200),
    cextra2 character varying(200),
    cextra3 character varying(200),
    cextra4 character varying(200),
    cextra5 character varying(200),
    ip character varying(15) NOT NULL
);


ALTER TABLE datos.tmpcontri OWNER TO postgres;

--
-- TOC entry 3811 (class 0 OID 0)
-- Dependencies: 275
-- Name: TABLE tmpcontri; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE tmpcontri IS 'Tabla con los datos temporales de los contribuyentes de la institución. Esta tabla se utiliza para que los contribuyentes hagan una solicitud de actualizacion de datos';


--
-- TOC entry 3812 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN tmpcontri.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.id IS 'Identificador unico del contribuyente';


--
-- TOC entry 3813 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN tmpcontri.tipocontid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.tipocontid IS 'Identificador del tipo de contribuyente';


--
-- TOC entry 3814 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN tmpcontri.razonsocia; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.razonsocia IS 'Razon social del contribuyente';


--
-- TOC entry 3815 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN tmpcontri.dencomerci; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.dencomerci IS 'Denominacion comercial del contribuyente';


--
-- TOC entry 3816 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN tmpcontri.actieconid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.actieconid IS 'Identificador de la actividad economica';


--
-- TOC entry 3817 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN tmpcontri.rif; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.rif IS 'Rif del contribuyente';


--
-- TOC entry 3818 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN tmpcontri.numregcine; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.numregcine IS 'Numero de registro cinematografico';


--
-- TOC entry 3819 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN tmpcontri.domfiscal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.domfiscal IS 'Domicilio fiscal del contribuyente';


--
-- TOC entry 3820 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN tmpcontri.estadoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.estadoid IS 'Identicador del estado geografico';


--
-- TOC entry 3821 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN tmpcontri.ciudadid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.ciudadid IS 'Identificador de la ciudad';


--
-- TOC entry 3822 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN tmpcontri.zonapostal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.zonapostal IS 'Zona postal del contribuyente';


--
-- TOC entry 3823 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN tmpcontri.telef1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.telef1 IS 'Telefono 1 del contribuyente';


--
-- TOC entry 3824 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN tmpcontri.telef2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.telef2 IS 'Telefono 2 del contribuyente';


--
-- TOC entry 3825 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN tmpcontri.telef3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.telef3 IS 'Telefono 3 del contribuyente';


--
-- TOC entry 3826 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN tmpcontri.fax1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.fax1 IS 'Fax 1 del contribuyente';


--
-- TOC entry 3827 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN tmpcontri.fax2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.fax2 IS 'Fax 2 del contribuyente';


--
-- TOC entry 3828 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN tmpcontri.email; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.email IS 'Direccion de email de contribuyente';


--
-- TOC entry 3829 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN tmpcontri.pinbb; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.pinbb IS 'Pin de BlackBerry';


--
-- TOC entry 3830 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN tmpcontri.skype; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.skype IS 'Dirección de skype';


--
-- TOC entry 3831 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN tmpcontri.twitter; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.twitter IS 'Direccion de twitter';


--
-- TOC entry 3832 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN tmpcontri.facebook; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.facebook IS 'Direccion de facebook';


--
-- TOC entry 3833 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN tmpcontri.nuacciones; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.nuacciones IS 'Numero de acciones del contribuyente segun inforacion del registro mercantil';


--
-- TOC entry 3834 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN tmpcontri.valaccion; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.valaccion IS 'Valor nominal por accion segun registro mercantil';


--
-- TOC entry 3835 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN tmpcontri.capitalsus; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.capitalsus IS 'Capital suscrito segun registro mercantil';


--
-- TOC entry 3836 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN tmpcontri.capitalpag; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.capitalpag IS 'Capital pagado segun registro mercantil';


--
-- TOC entry 3837 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN tmpcontri.regmerofc; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.regmerofc IS 'Oficina de registro mercantil en donde se registro la empresa';


--
-- TOC entry 3838 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN tmpcontri.rmnumero; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.rmnumero IS 'Numero de registro del documento de registro mercantil';


--
-- TOC entry 3839 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN tmpcontri.rmfolio; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.rmfolio IS 'Numero de folio del documento de registro mercantil';


--
-- TOC entry 3840 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN tmpcontri.rmtomo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.rmtomo IS 'Numero de folio del documento de registro mercantil';


--
-- TOC entry 3841 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN tmpcontri.rmfechapro; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.rmfechapro IS 'Fecha de protocololizacion del registro del documento de registro mercantil';


--
-- TOC entry 3842 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN tmpcontri.rmncontrol; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.rmncontrol IS 'Numero de control del documento de registro mercantil';


--
-- TOC entry 3843 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN tmpcontri.rmobjeto; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.rmobjeto IS 'Objeto de la empresa segun registro mercantil';


--
-- TOC entry 3844 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN tmpcontri.domcomer; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.domcomer IS 'domicilio comercial';


--
-- TOC entry 3845 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN tmpcontri.conusuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.conusuid IS 'Identificador del usuario-contribuyente que creo el registro';


--
-- TOC entry 3846 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN tmpcontri.tiporeg; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.tiporeg IS 'Tipo de registro creado. 0=Nuevo contribuyente, 1=Edicion de datos de contribuyentes';


--
-- TOC entry 3847 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN tmpcontri.cextra1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.cextra1 IS 'Campo extra 1';


--
-- TOC entry 3848 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN tmpcontri.cextra2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.cextra2 IS 'Campo extra 2';


--
-- TOC entry 3849 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN tmpcontri.cextra3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.cextra3 IS 'Campo extra 3';


--
-- TOC entry 3850 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN tmpcontri.cextra4; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.cextra4 IS 'Campo extra 4';


--
-- TOC entry 3851 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN tmpcontri.cextra5; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.cextra5 IS 'Campo extra 5';


--
-- TOC entry 3852 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN tmpcontri.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 276 (class 1259 OID 128856)
-- Dependencies: 9
-- Name: tmprelegal; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE tmprelegal (
    id integer NOT NULL,
    contribuid integer NOT NULL,
    nombre character varying(100) NOT NULL,
    apellido character varying(100) NOT NULL,
    ci character varying(20) NOT NULL,
    domfiscal character varying(500) NOT NULL,
    estadoid integer NOT NULL,
    ciudadid integer NOT NULL,
    zonaposta character varying(10),
    telefhab character varying(11),
    telefofc character varying(11),
    fax character varying(11),
    email character varying(100),
    pinbb character varying(8),
    skype character varying(100),
    cextra1 character varying(200),
    cextra2 character varying(200),
    cextra3 character varying(200),
    cextra4 character varying(200),
    cextra5 character varying(200),
    ip character varying(15) NOT NULL
);


ALTER TABLE datos.tmprelegal OWNER TO postgres;

--
-- TOC entry 3853 (class 0 OID 0)
-- Dependencies: 276
-- Name: TABLE tmprelegal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE tmprelegal IS 'Tabla con los datos temporales de los representantes legales de los contribuyentes. Esta tabla se utiliza para procesar una solicitud de cambio de datos. El contribuyente copia aqui los nuevos datos';


--
-- TOC entry 3854 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN tmprelegal.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.id IS 'Identificador unico del representante legal';


--
-- TOC entry 3855 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN tmprelegal.contribuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.contribuid IS 'Identificador del contribuyente';


--
-- TOC entry 3856 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN tmprelegal.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.nombre IS 'Nombre del representante legal';


--
-- TOC entry 3857 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN tmprelegal.apellido; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.apellido IS 'Apellidos del representante legal';


--
-- TOC entry 3858 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN tmprelegal.ci; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.ci IS 'Cedula de identidad, numero de pasaporte';


--
-- TOC entry 3859 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN tmprelegal.domfiscal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.domfiscal IS 'Domicilio fiscal del representante legal';


--
-- TOC entry 3860 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN tmprelegal.estadoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.estadoid IS 'Identificador del estado geografico';


--
-- TOC entry 3861 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN tmprelegal.ciudadid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.ciudadid IS 'Identificador de la ciudad';


--
-- TOC entry 3862 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN tmprelegal.zonaposta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.zonaposta IS 'Zona postal';


--
-- TOC entry 3863 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN tmprelegal.telefhab; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.telefhab IS 'Telefono de habitacion del representante legal';


--
-- TOC entry 3864 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN tmprelegal.telefofc; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.telefofc IS 'Telefono de oficina del representante legal';


--
-- TOC entry 3865 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN tmprelegal.fax; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.fax IS 'Fax del representante legal';


--
-- TOC entry 3866 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN tmprelegal.email; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.email IS 'Direccion de email del contribuyente';


--
-- TOC entry 3867 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN tmprelegal.pinbb; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.pinbb IS 'Pin de BlackBerry';


--
-- TOC entry 3868 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN tmprelegal.skype; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.skype IS 'Direccion de skype del representante legal';


--
-- TOC entry 3869 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN tmprelegal.cextra1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.cextra1 IS 'Campo extra 1 ';


--
-- TOC entry 3870 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN tmprelegal.cextra2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.cextra2 IS 'Campo extra 2 ';


--
-- TOC entry 3871 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN tmprelegal.cextra3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.cextra3 IS 'Campo extra 3 ';


--
-- TOC entry 3872 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN tmprelegal.cextra4; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.cextra4 IS 'Campo extra 4 ';


--
-- TOC entry 3873 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN tmprelegal.cextra5; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.cextra5 IS 'Campo extra 5 ';


--
-- TOC entry 3874 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN tmprelegal.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 277 (class 1259 OID 128862)
-- Dependencies: 9
-- Name: view_modulo_usuario_contribuyente_permiso; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE view_modulo_usuario_contribuyente_permiso (
    id integer,
    nombre character varying(100),
    str_rol character varying(100),
    id_modulo bigint,
    str_nombre character varying(300),
    str_enlace character varying(100),
    int_permiso integer,
    int_orden bigint,
    id_padre bigint
);


ALTER TABLE datos.view_modulo_usuario_contribuyente_permiso OWNER TO postgres;

--
-- TOC entry 317 (class 1259 OID 130363)
-- Dependencies: 3176 9
-- Name: vista_datos_multa_interes; Type: VIEW; Schema: datos; Owner: postgres
--

CREATE VIEW vista_datos_multa_interes AS
    SELECT conu.nombre AS contribuyente, conu.rif, contri.dencomerci AS denominacion_comercial, conu.email, actiecon.nombre AS actiecon, contri.rmtomo, contri.rmobjeto AS objeto_empresa, contri.numregcine, contri.domfiscal, contri.zonapostal, contri.telef1, replegal.nombre AS nrplegal, replegal.ci AS cedulareplegal, replegal.telefhab AS telereplegal, replegal.domfiscal AS direccionreplegal, replegal.email AS emailreplegal, tcont.nombre, tcont.numero_articulo AS narticulo, tcont.cita_articulo AS text_articulo, contri.domfiscal AS domicilio_fisal, est.nombre AS estado, ciu.nombre AS ciudad, contri.regmerofc AS oficina_registro, contri.rmfechapro AS fecha_registro, contri.rmnumero AS numero_registro, decl.proceso AS proceso_multa, rep.id AS idreparo, rep.fecha_notificacion AS fechanoti_reparo, rep.fecha_autorizacion, rep.fecha_recepcion, rep.fecha_requerimiento, rep.tipocontribuid AS idtipocont, rep.conusuid AS idconusu, asigf.periodo_afiscalizar, asigf.nro_autorizacion, actrp.numero AS nacta_reparo, rep.montopagar AS total_reparo, usf.nombre AS fiscal_ejecutor, usf.cedula AS cedula_fiscal, ut.valor AS valor_ut, mult.id AS idmulta, mult.nresolucion AS resol_multa, mult.fechaelaboracion, mult.tipo_multa, mult.nudeposito AS deposito_multa, mult.declaraid AS multdclaid, (SELECT sum(m.montopagar) AS sum FROM ((pre_aprobacion.multas m JOIN declara d ON ((d.id = m.declaraid))) JOIN reparos r ON ((r.id = d.reparoid))) WHERE (r.id = rep.id)) AS multa_pagar, mult.fechanotificacion AS fnoti_multa, inte.id AS idinteres, inte.numresolucion AS resol_interes, inte.totalpagar AS total_interes, (SELECT sum(i.totalpagar) AS sum FROM (((pre_aprobacion.multas m JOIN pre_aprobacion.intereses i ON ((i.multaid = m.id))) JOIN declara d ON ((d.id = m.declaraid))) JOIN reparos r ON ((r.id = d.reparoid))) WHERE (r.id = rep.id)) AS interes_pagar, mult.numero_session AS nsession, mult.fecha_session AS fsession, tdeclara.id AS tdeclaraid, tcont.id AS tipocontid, tipegrav.tipe AS tipo_periodo, calpagod.periodo AS periodo_declara, calpago.ano AS anio_declara, tdeclara.nombre AS ntdeclara, tdeclara.id AS tipodclid FROM ((((((((((((((((((pre_aprobacion.multas mult JOIN pre_aprobacion.intereses inte ON ((inte.multaid = mult.id))) JOIN declara decl ON ((decl.id = mult.declaraid))) JOIN conusu conu ON ((conu.id = decl.conusuid))) JOIN contribu contri ON (((contri.rif)::text = (conu.rif)::text))) JOIN actiecon ON ((contri.actieconid = actiecon.id))) JOIN replegal ON ((replegal.contribuid = conu.id))) JOIN estados est ON ((est.id = contri.estadoid))) JOIN ciudades ciu ON ((ciu.id = contri.ciudadid))) JOIN reparos rep ON ((rep.id = decl.reparoid))) JOIN tipocont tcont ON ((tcont.id = rep.tipocontribuid))) JOIN tipegrav ON ((tipegrav.id = tcont.tipegravid))) JOIN actas_reparo actrp ON ((actrp.id = rep.actaid))) JOIN asignacion_fiscales asigf ON ((asigf.id = rep.asignacionid))) JOIN undtrib ut ON (((ut.anio)::numeric = asigf.periodo_afiscalizar))) JOIN usfonpro usf ON ((usf.id = asigf.usfonproid))) JOIN calpagod ON ((calpagod.id = decl.calpagodid))) JOIN calpago ON ((calpago.id = calpagod.calpagoid))) JOIN tdeclara ON ((mult.tipo_multa = tdeclara.id)));


ALTER TABLE datos.vista_datos_multa_interes OWNER TO postgres;

--
-- TOC entry 316 (class 1259 OID 130284)
-- Dependencies: 3175 9
-- Name: vista_datos_rise_recaudacion; Type: VIEW; Schema: datos; Owner: postgres
--

CREATE VIEW vista_datos_rise_recaudacion AS
    SELECT d.fecha_registro_fila, d.id AS contribcalcid, dc.id AS detacontribcalcid, conu.nombre AS contribuyente, conu.rif, contri.dencomerci AS denominacion_comercial, contri.rmtomo, contri.rmobjeto AS objeto_empresa, tcont.nombre, tcont.numero_articulo, tcont.cita_articulo, contri.domfiscal AS domicilio_fisal, est.nombre AS estado, ciu.nombre AS ciudad, contri.regmerofc AS oficina_registro, contri.rmfechapro AS fecha_registro, contri.rmnumero AS numero_registro, dc.proceso AS proceso_multa, d.tipocontid AS idtipocont, mult.id AS idmulta, mult.nresolucion AS resol_multa, mult.fechaelaboracion, mult.tipo_multa, mult.nudeposito AS deposito_multa, mult.declaraid AS multdclaid, mult.montopagar AS total_multa, (SELECT sum(m.montopagar) AS sum FROM (pre_aprobacion.multas m JOIN detalles_contrib_calc con_calc ON ((con_calc.declaraid = m.declaraid))) WHERE (con_calc.contrib_calcid = d.id)) AS multa_pagar, inte.id AS idinteres, inte.numresolucion AS resol_interes, inte.totalpagar AS total_interes, (SELECT sum(i.totalpagar) AS sum FROM ((pre_aprobacion.multas m JOIN pre_aprobacion.intereses i ON ((i.multaid = m.id))) JOIN detalles_contrib_calc con_calc ON ((con_calc.declaraid = m.declaraid))) WHERE (con_calc.contrib_calcid = d.id)) AS interes_pagar, mult.numero_session AS nsession, mult.fecha_session AS fsession FROM ((((((((contrib_calc d JOIN detalles_contrib_calc dc ON ((d.id = dc.contrib_calcid))) JOIN pre_aprobacion.multas mult ON ((mult.declaraid = dc.declaraid))) JOIN pre_aprobacion.intereses inte ON ((inte.multaid = mult.id))) JOIN conusu conu ON ((conu.id = d.conusuid))) JOIN contribu contri ON (((contri.rif)::text = (conu.rif)::text))) JOIN estados est ON ((est.id = contri.estadoid))) JOIN ciudades ciu ON ((ciu.id = contri.ciudadid))) JOIN tipocont tcont ON ((tcont.id = d.tipocontid)));


ALTER TABLE datos.vista_datos_rise_recaudacion OWNER TO postgres;

SET search_path = historial, pg_catalog;

--
-- TOC entry 278 (class 1259 OID 128878)
-- Dependencies: 2501 10
-- Name: bitacora; Type: TABLE; Schema: historial; Owner: postgres; Tablespace: 
--

CREATE TABLE bitacora (
    id integer NOT NULL,
    fecha timestamp without time zone NOT NULL,
    tabla character varying(50) NOT NULL,
    idusuario integer,
    accion smallint DEFAULT 0 NOT NULL,
    datosnew text,
    datosold text,
    datosdel text,
    valdelid character varying(20),
    ip character varying(15)
);


ALTER TABLE historial.bitacora OWNER TO postgres;

--
-- TOC entry 3875 (class 0 OID 0)
-- Dependencies: 278
-- Name: TABLE bitacora; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON TABLE bitacora IS 'Tabla con la bitacora de los datos cambiados de todas las tablas del sistema';


--
-- TOC entry 3876 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN bitacora.id; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON COLUMN bitacora.id IS 'Identificador de la bitacora';


--
-- TOC entry 3877 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN bitacora.fecha; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON COLUMN bitacora.fecha IS 'Fecha/Hora de la transaccion';


--
-- TOC entry 3878 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN bitacora.tabla; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON COLUMN bitacora.tabla IS 'Nombre de tabla sobre la cual se ejecuto la transaccion';


--
-- TOC entry 3879 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN bitacora.idusuario; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON COLUMN bitacora.idusuario IS 'Identificador del usuario que genero la transaccion';


--
-- TOC entry 3880 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN bitacora.accion; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON COLUMN bitacora.accion IS 'Accion ejecutada sobre la tabla. 0.- Insert / 1.- Update / 2.- Delete';


--
-- TOC entry 3881 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN bitacora.datosnew; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON COLUMN bitacora.datosnew IS 'Datos nuevos para el caso de los insert y los Update';


--
-- TOC entry 3882 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN bitacora.datosold; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON COLUMN bitacora.datosold IS 'Datos originales para el caso de los Update';


--
-- TOC entry 3883 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN bitacora.datosdel; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON COLUMN bitacora.datosdel IS 'Datos eliminados para el caso de los Delete';


--
-- TOC entry 3884 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN bitacora.valdelid; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON COLUMN bitacora.valdelid IS 'ID del registro que fue borrado';


--
-- TOC entry 3885 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN bitacora.ip; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON COLUMN bitacora.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 279 (class 1259 OID 128885)
-- Dependencies: 278 10
-- Name: Bitacora_IDBitacora_seq; Type: SEQUENCE; Schema: historial; Owner: postgres
--

CREATE SEQUENCE "Bitacora_IDBitacora_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE historial."Bitacora_IDBitacora_seq" OWNER TO postgres;

--
-- TOC entry 3887 (class 0 OID 0)
-- Dependencies: 279
-- Name: Bitacora_IDBitacora_seq; Type: SEQUENCE OWNED BY; Schema: historial; Owner: postgres
--

ALTER SEQUENCE "Bitacora_IDBitacora_seq" OWNED BY bitacora.id;


SET search_path = pre_aprobacion, pg_catalog;

--
-- TOC entry 280 (class 1259 OID 128887)
-- Dependencies: 2503 2504 2505 2506 6
-- Name: datos_cnac; Type: TABLE; Schema: pre_aprobacion; Owner: postgres; Tablespace: 
--

CREATE TABLE datos_cnac (
    id integer NOT NULL,
    razonsocia character varying(350) NOT NULL,
    dencomerci character varying(200) NOT NULL,
    actieconid integer NOT NULL,
    rif character varying(20) NOT NULL,
    numregcine integer NOT NULL,
    domfiscal character varying(500) NOT NULL,
    estadoid integer NOT NULL,
    ciudadid integer NOT NULL,
    zonapostal character varying(10),
    telef1 character varying(12) NOT NULL,
    telef2 character varying(12),
    telef3 character varying(12),
    fax1 character varying(12),
    fax2 character varying(12),
    email character varying(100) NOT NULL,
    pinbb character varying(8),
    skype character varying(100),
    twitter character varying(100),
    facebook character varying(200),
    nuacciones integer DEFAULT 0 NOT NULL,
    valaccion numeric(18,2) DEFAULT 0 NOT NULL,
    capitalsus numeric(18,2) DEFAULT 0 NOT NULL,
    capitalpag numeric(18,2) DEFAULT 0 NOT NULL,
    regmerofc character varying(300) NOT NULL,
    rmnumero character varying(20) NOT NULL,
    rmfolio character varying(20) NOT NULL,
    rmtomo character varying(10) NOT NULL,
    rmfechapro date NOT NULL,
    rmncontrol character varying(20) NOT NULL,
    rmobjeto text NOT NULL,
    domcomer character varying(350),
    cextra1 character varying(200),
    cextra2 character varying(200),
    cextra3 character varying(200),
    cextra4 character varying(200),
    cextra5 character varying(200),
    usuarioid integer NOT NULL,
    ip character varying(15) NOT NULL
);


ALTER TABLE pre_aprobacion.datos_cnac OWNER TO postgres;

--
-- TOC entry 281 (class 1259 OID 128897)
-- Dependencies: 6 280
-- Name: datos_cnac_id_seq; Type: SEQUENCE; Schema: pre_aprobacion; Owner: postgres
--

CREATE SEQUENCE datos_cnac_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pre_aprobacion.datos_cnac_id_seq OWNER TO postgres;

--
-- TOC entry 3889 (class 0 OID 0)
-- Dependencies: 281
-- Name: datos_cnac_id_seq; Type: SEQUENCE OWNED BY; Schema: pre_aprobacion; Owner: postgres
--

ALTER SEQUENCE datos_cnac_id_seq OWNED BY datos_cnac.id;


--
-- TOC entry 282 (class 1259 OID 128899)
-- Dependencies: 253 6
-- Name: intereses_id_seq; Type: SEQUENCE; Schema: pre_aprobacion; Owner: postgres
--

CREATE SEQUENCE intereses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pre_aprobacion.intereses_id_seq OWNER TO postgres;

--
-- TOC entry 3890 (class 0 OID 0)
-- Dependencies: 282
-- Name: intereses_id_seq; Type: SEQUENCE OWNED BY; Schema: pre_aprobacion; Owner: postgres
--

ALTER SEQUENCE intereses_id_seq OWNED BY intereses.id;


--
-- TOC entry 283 (class 1259 OID 128901)
-- Dependencies: 6 254
-- Name: multas_id_seq; Type: SEQUENCE; Schema: pre_aprobacion; Owner: postgres
--

CREATE SEQUENCE multas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pre_aprobacion.multas_id_seq OWNER TO postgres;

--
-- TOC entry 3891 (class 0 OID 0)
-- Dependencies: 283
-- Name: multas_id_seq; Type: SEQUENCE OWNED BY; Schema: pre_aprobacion; Owner: postgres
--

ALTER SEQUENCE multas_id_seq OWNED BY multas.id;


SET search_path = public, pg_catalog;

--
-- TOC entry 284 (class 1259 OID 128903)
-- Dependencies: 11
-- Name: contrib_calc; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE contrib_calc (
    id character(10) NOT NULL,
    nombre character(40)
);


ALTER TABLE public.contrib_calc OWNER TO postgres;

SET search_path = seg, pg_catalog;

--
-- TOC entry 285 (class 1259 OID 128906)
-- Dependencies: 2508 7
-- Name: tbl_cargos; Type: TABLE; Schema: seg; Owner: postgres; Tablespace: 
--

CREATE TABLE tbl_cargos (
    id integer NOT NULL,
    nombre character varying,
    descripcion character varying,
    oficinasid integer,
    usuarioid integer,
    ip character varying,
    bln_borrado boolean DEFAULT false NOT NULL
);


ALTER TABLE seg.tbl_cargos OWNER TO postgres;

--
-- TOC entry 286 (class 1259 OID 128913)
-- Dependencies: 7 285
-- Name: tbl_cargos_id_seq; Type: SEQUENCE; Schema: seg; Owner: postgres
--

CREATE SEQUENCE tbl_cargos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE seg.tbl_cargos_id_seq OWNER TO postgres;

--
-- TOC entry 3892 (class 0 OID 0)
-- Dependencies: 286
-- Name: tbl_cargos_id_seq; Type: SEQUENCE OWNED BY; Schema: seg; Owner: postgres
--

ALTER SEQUENCE tbl_cargos_id_seq OWNED BY tbl_cargos.id;


--
-- TOC entry 287 (class 1259 OID 128915)
-- Dependencies: 2510 2511 2512 2513 7
-- Name: tbl_ci_sessions; Type: TABLE; Schema: seg; Owner: postgres; Tablespace: 
--

CREATE TABLE tbl_ci_sessions (
    session_id character varying(40) DEFAULT 0 NOT NULL,
    ip_address character varying(16) DEFAULT 0 NOT NULL,
    user_agent character varying(150) NOT NULL,
    last_activity integer DEFAULT 0 NOT NULL,
    user_data text,
    prevent_update integer,
    CONSTRAINT ckeck_last_activity CHECK ((last_activity >= 0))
);


ALTER TABLE seg.tbl_ci_sessions OWNER TO postgres;

--
-- TOC entry 3893 (class 0 OID 0)
-- Dependencies: 287
-- Name: TABLE tbl_ci_sessions; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON TABLE tbl_ci_sessions IS 'Sesiones manejadas por CodeIgniter';


--
-- TOC entry 288 (class 1259 OID 128925)
-- Dependencies: 2514 7
-- Name: tbl_modulo; Type: TABLE; Schema: seg; Owner: postgres; Tablespace: 
--

CREATE TABLE tbl_modulo (
    id_modulo bigint NOT NULL,
    id_padre bigint,
    str_nombre character varying(300) NOT NULL,
    str_descripcion character varying(500) NOT NULL,
    str_enlace character varying(100),
    bln_borrado boolean DEFAULT false NOT NULL
);


ALTER TABLE seg.tbl_modulo OWNER TO postgres;

--
-- TOC entry 3894 (class 0 OID 0)
-- Dependencies: 288
-- Name: TABLE tbl_modulo; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON TABLE tbl_modulo IS 'Módulos del sistema';


--
-- TOC entry 289 (class 1259 OID 128932)
-- Dependencies: 288 7
-- Name: tbl_modulo_id_modulo_seq; Type: SEQUENCE; Schema: seg; Owner: postgres
--

CREATE SEQUENCE tbl_modulo_id_modulo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE seg.tbl_modulo_id_modulo_seq OWNER TO postgres;

--
-- TOC entry 3895 (class 0 OID 0)
-- Dependencies: 289
-- Name: tbl_modulo_id_modulo_seq; Type: SEQUENCE OWNED BY; Schema: seg; Owner: postgres
--

ALTER SEQUENCE tbl_modulo_id_modulo_seq OWNED BY tbl_modulo.id_modulo;


--
-- TOC entry 290 (class 1259 OID 128934)
-- Dependencies: 2516 2517 7
-- Name: tbl_oficinas; Type: TABLE; Schema: seg; Owner: postgres; Tablespace: 
--

CREATE TABLE tbl_oficinas (
    id integer NOT NULL,
    nombre character varying,
    descripcion character varying,
    fecha_creacion date DEFAULT now() NOT NULL,
    cod_estructura character varying,
    usuarioid integer NOT NULL,
    ip character varying,
    bln_borrado boolean DEFAULT false NOT NULL
);


ALTER TABLE seg.tbl_oficinas OWNER TO postgres;

--
-- TOC entry 291 (class 1259 OID 128942)
-- Dependencies: 7 290
-- Name: tbl_oficinas_id_seq; Type: SEQUENCE; Schema: seg; Owner: postgres
--

CREATE SEQUENCE tbl_oficinas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE seg.tbl_oficinas_id_seq OWNER TO postgres;

--
-- TOC entry 3896 (class 0 OID 0)
-- Dependencies: 291
-- Name: tbl_oficinas_id_seq; Type: SEQUENCE OWNED BY; Schema: seg; Owner: postgres
--

ALTER SEQUENCE tbl_oficinas_id_seq OWNED BY tbl_oficinas.id;


--
-- TOC entry 292 (class 1259 OID 128944)
-- Dependencies: 2519 7
-- Name: tbl_permiso; Type: TABLE; Schema: seg; Owner: postgres; Tablespace: 
--

CREATE TABLE tbl_permiso (
    id_permiso bigint NOT NULL,
    id_modulo bigint NOT NULL,
    id_rol bigint NOT NULL,
    int_permiso integer NOT NULL,
    bln_borrado boolean DEFAULT false NOT NULL
);


ALTER TABLE seg.tbl_permiso OWNER TO postgres;

--
-- TOC entry 3897 (class 0 OID 0)
-- Dependencies: 292
-- Name: TABLE tbl_permiso; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON TABLE tbl_permiso IS 'Permisos de los roles sobre los módulos';


--
-- TOC entry 293 (class 1259 OID 128948)
-- Dependencies: 292 7
-- Name: tbl_permiso_id_permiso_seq; Type: SEQUENCE; Schema: seg; Owner: postgres
--

CREATE SEQUENCE tbl_permiso_id_permiso_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE seg.tbl_permiso_id_permiso_seq OWNER TO postgres;

--
-- TOC entry 3898 (class 0 OID 0)
-- Dependencies: 293
-- Name: tbl_permiso_id_permiso_seq; Type: SEQUENCE OWNED BY; Schema: seg; Owner: postgres
--

ALTER SEQUENCE tbl_permiso_id_permiso_seq OWNED BY tbl_permiso.id_permiso;


--
-- TOC entry 294 (class 1259 OID 128950)
-- Dependencies: 2521 7
-- Name: tbl_permiso_trampa; Type: TABLE; Schema: seg; Owner: postgres; Tablespace: 
--

CREATE TABLE tbl_permiso_trampa (
    id_permiso bigint NOT NULL,
    id_modulo bigint NOT NULL,
    id_rol bigint NOT NULL,
    int_permiso integer NOT NULL,
    bln_borrado boolean DEFAULT false NOT NULL
);


ALTER TABLE seg.tbl_permiso_trampa OWNER TO postgres;

--
-- TOC entry 3899 (class 0 OID 0)
-- Dependencies: 294
-- Name: TABLE tbl_permiso_trampa; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON TABLE tbl_permiso_trampa IS 'Permisos de los roles sobre los módulos';


--
-- TOC entry 295 (class 1259 OID 128954)
-- Dependencies: 7 294
-- Name: tbl_permiso_trampa_id_permiso_seq; Type: SEQUENCE; Schema: seg; Owner: postgres
--

CREATE SEQUENCE tbl_permiso_trampa_id_permiso_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE seg.tbl_permiso_trampa_id_permiso_seq OWNER TO postgres;

--
-- TOC entry 3900 (class 0 OID 0)
-- Dependencies: 295
-- Name: tbl_permiso_trampa_id_permiso_seq; Type: SEQUENCE OWNED BY; Schema: seg; Owner: postgres
--

ALTER SEQUENCE tbl_permiso_trampa_id_permiso_seq OWNED BY tbl_permiso_trampa.id_permiso;


--
-- TOC entry 296 (class 1259 OID 128956)
-- Dependencies: 2523 7
-- Name: tbl_rol; Type: TABLE; Schema: seg; Owner: postgres; Tablespace: 
--

CREATE TABLE tbl_rol (
    id_rol bigint NOT NULL,
    str_rol character varying(100) NOT NULL,
    str_descripcion character varying(500),
    bln_borrado boolean DEFAULT false NOT NULL
);


ALTER TABLE seg.tbl_rol OWNER TO postgres;

--
-- TOC entry 3901 (class 0 OID 0)
-- Dependencies: 296
-- Name: TABLE tbl_rol; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON TABLE tbl_rol IS 'Roles de los usuarios del sistema';


--
-- TOC entry 297 (class 1259 OID 128963)
-- Dependencies: 7 296
-- Name: tbl_rol_id_rol_seq; Type: SEQUENCE; Schema: seg; Owner: postgres
--

CREATE SEQUENCE tbl_rol_id_rol_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE seg.tbl_rol_id_rol_seq OWNER TO postgres;

--
-- TOC entry 3902 (class 0 OID 0)
-- Dependencies: 297
-- Name: tbl_rol_id_rol_seq; Type: SEQUENCE OWNED BY; Schema: seg; Owner: postgres
--

ALTER SEQUENCE tbl_rol_id_rol_seq OWNED BY tbl_rol.id_rol;


--
-- TOC entry 298 (class 1259 OID 128965)
-- Dependencies: 2525 7
-- Name: tbl_rol_usuario; Type: TABLE; Schema: seg; Owner: postgres; Tablespace: 
--

CREATE TABLE tbl_rol_usuario (
    id_rol_usuario bigint NOT NULL,
    id_rol bigint NOT NULL,
    id_usuario bigint NOT NULL,
    bln_borrado boolean DEFAULT false NOT NULL
);


ALTER TABLE seg.tbl_rol_usuario OWNER TO postgres;

--
-- TOC entry 3903 (class 0 OID 0)
-- Dependencies: 298
-- Name: TABLE tbl_rol_usuario; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON TABLE tbl_rol_usuario IS 'Roles de los usuarios, un usuario puede tener multiples roles dentro del sistema';


--
-- TOC entry 3904 (class 0 OID 0)
-- Dependencies: 298
-- Name: COLUMN tbl_rol_usuario.id_rol_usuario; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON COLUMN tbl_rol_usuario.id_rol_usuario IS 'Identificador del usuario';


--
-- TOC entry 3905 (class 0 OID 0)
-- Dependencies: 298
-- Name: COLUMN tbl_rol_usuario.id_rol; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON COLUMN tbl_rol_usuario.id_rol IS 'Relación con el rol';


--
-- TOC entry 3906 (class 0 OID 0)
-- Dependencies: 298
-- Name: COLUMN tbl_rol_usuario.id_usuario; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON COLUMN tbl_rol_usuario.id_usuario IS 'Relación con el usuario';


--
-- TOC entry 3907 (class 0 OID 0)
-- Dependencies: 298
-- Name: COLUMN tbl_rol_usuario.bln_borrado; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON COLUMN tbl_rol_usuario.bln_borrado IS 'Marca de borrado lógico';


--
-- TOC entry 299 (class 1259 OID 128969)
-- Dependencies: 7 298
-- Name: tbl_rol_usuario_id_rol_usuario_seq; Type: SEQUENCE; Schema: seg; Owner: postgres
--

CREATE SEQUENCE tbl_rol_usuario_id_rol_usuario_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE seg.tbl_rol_usuario_id_rol_usuario_seq OWNER TO postgres;

--
-- TOC entry 3908 (class 0 OID 0)
-- Dependencies: 299
-- Name: tbl_rol_usuario_id_rol_usuario_seq; Type: SEQUENCE OWNED BY; Schema: seg; Owner: postgres
--

ALTER SEQUENCE tbl_rol_usuario_id_rol_usuario_seq OWNED BY tbl_rol_usuario.id_rol_usuario;


--
-- TOC entry 300 (class 1259 OID 128971)
-- Dependencies: 2527 2528 2529 2530 7
-- Name: tbl_session_ci; Type: TABLE; Schema: seg; Owner: postgres; Tablespace: 
--

CREATE TABLE tbl_session_ci (
    session_id character varying(40) DEFAULT 0 NOT NULL,
    ip_address character varying(16) DEFAULT 0 NOT NULL,
    user_agent character varying(150) NOT NULL,
    last_activity integer DEFAULT 0 NOT NULL,
    user_data text,
    CONSTRAINT ckeck_last_activity CHECK ((last_activity >= 0))
);


ALTER TABLE seg.tbl_session_ci OWNER TO postgres;

--
-- TOC entry 3909 (class 0 OID 0)
-- Dependencies: 300
-- Name: TABLE tbl_session_ci; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON TABLE tbl_session_ci IS 'Sesiones manejadas por CodeIgniter';


--
-- TOC entry 301 (class 1259 OID 128981)
-- Dependencies: 2531 7
-- Name: tbl_usuario_rol; Type: TABLE; Schema: seg; Owner: postgres; Tablespace: 
--

CREATE TABLE tbl_usuario_rol (
    id_usuario_rol bigint NOT NULL,
    id_usuario bigint NOT NULL,
    id_rol bigint NOT NULL,
    bol_borrado boolean DEFAULT false NOT NULL
);


ALTER TABLE seg.tbl_usuario_rol OWNER TO postgres;

--
-- TOC entry 3910 (class 0 OID 0)
-- Dependencies: 301
-- Name: TABLE tbl_usuario_rol; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON TABLE tbl_usuario_rol IS 'Permisos de los roles de usuarios sobre los módulos';


--
-- TOC entry 302 (class 1259 OID 128985)
-- Dependencies: 301 7
-- Name: tbl_usuario_rol_id_usuario_rol_seq; Type: SEQUENCE; Schema: seg; Owner: postgres
--

CREATE SEQUENCE tbl_usuario_rol_id_usuario_rol_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE seg.tbl_usuario_rol_id_usuario_rol_seq OWNER TO postgres;

--
-- TOC entry 3911 (class 0 OID 0)
-- Dependencies: 302
-- Name: tbl_usuario_rol_id_usuario_rol_seq; Type: SEQUENCE OWNED BY; Schema: seg; Owner: postgres
--

ALTER SEQUENCE tbl_usuario_rol_id_usuario_rol_seq OWNED BY tbl_usuario_rol.id_usuario_rol;


--
-- TOC entry 303 (class 1259 OID 128987)
-- Dependencies: 7
-- Name: view_modulo_usuario_permiso; Type: TABLE; Schema: seg; Owner: postgres; Tablespace: 
--

CREATE TABLE view_modulo_usuario_permiso (
    id integer,
    nombre character varying(100),
    str_rol character varying(100),
    id_modulo bigint,
    str_nombre character varying(300),
    str_enlace character varying(100),
    int_permiso integer,
    int_orden bigint,
    id_padre bigint
);


ALTER TABLE seg.view_modulo_usuario_permiso OWNER TO postgres;

--
-- TOC entry 304 (class 1259 OID 128993)
-- Dependencies: 3171 7
-- Name: vista_listado_reparos_culminados; Type: VIEW; Schema: seg; Owner: postgres
--

CREATE VIEW vista_listado_reparos_culminados AS
    SELECT rep.id AS reparoid, conu.nombre AS razon_social, conu.email, est.nombre AS nomest, usf.nombre AS fiscal, rep.fechaelab, rep.fecha_notificacion, CASE WHEN (((now())::date - date(rep.fecha_notificacion)) <= (SELECT CASE WHEN ((rep.recibido_por)::text = '3'::text) THEN 26 ELSE 21 END AS dias)) THEN 'verde'::text WHEN ((((now())::date - date(rep.fecha_notificacion)) > (SELECT CASE WHEN ((rep.recibido_por)::text = '3'::text) THEN 26 ELSE 21 END AS dias)) AND (((now())::date - date(rep.fecha_notificacion)) <= (SELECT CASE WHEN ((rep.recibido_por)::text = '3'::text) THEN 61 ELSE 56 END AS dias))) THEN 'amarillo'::text ELSE 'rojo'::text END AS semaforo, CASE WHEN ((SELECT count(*) AS count FROM datos.declara WHERE ((declara.reparoid = rep.id) AND (declara.fechapago IS NULL))) = 0) THEN 'CANCELADO'::text ELSE NULL::text END AS estado FROM ((((datos.reparos rep JOIN datos.conusu conu ON ((conu.id = rep.conusuid))) LEFT JOIN datos.contribu contri ON (((contri.rif)::text = (conu.rif)::text))) LEFT JOIN datos.estados est ON ((est.id = contri.estadoid))) JOIN datos.usfonpro usf ON ((usf.id = rep.usuarioid))) WHERE (rep.bln_activo AND (rep.proceso IS NULL)) ORDER BY CASE WHEN (((now())::date - date(rep.fecha_notificacion)) <= (SELECT CASE WHEN ((rep.recibido_por)::text = '3'::text) THEN 26 ELSE 21 END AS dias)) THEN 'verde'::text WHEN ((((now())::date - date(rep.fecha_notificacion)) > (SELECT CASE WHEN ((rep.recibido_por)::text = '3'::text) THEN 26 ELSE 21 END AS dias)) AND (((now())::date - date(rep.fecha_notificacion)) <= (SELECT CASE WHEN ((rep.recibido_por)::text = '3'::text) THEN 61 ELSE 56 END AS dias))) THEN 'amarillo'::text ELSE 'rojo'::text END;


ALTER TABLE seg.vista_listado_reparos_culminados OWNER TO postgres;

SET search_path = "segContribu", pg_catalog;

--
-- TOC entry 305 (class 1259 OID 128998)
-- Dependencies: 2533 8
-- Name: tbl_modulo_contribu; Type: TABLE; Schema: segContribu; Owner: postgres; Tablespace: 
--

CREATE TABLE tbl_modulo_contribu (
    id_modulo bigint NOT NULL,
    id_padre bigint,
    str_nombre character varying(300) NOT NULL,
    str_descripcion character varying(500) NOT NULL,
    str_enlace character varying(100),
    bln_borrado boolean DEFAULT false NOT NULL
);


ALTER TABLE "segContribu".tbl_modulo_contribu OWNER TO postgres;

--
-- TOC entry 3912 (class 0 OID 0)
-- Dependencies: 305
-- Name: TABLE tbl_modulo_contribu; Type: COMMENT; Schema: segContribu; Owner: postgres
--

COMMENT ON TABLE tbl_modulo_contribu IS 'Módulos del sistema';


--
-- TOC entry 306 (class 1259 OID 129005)
-- Dependencies: 8 305
-- Name: tbl_modulo_id_modulo_seq; Type: SEQUENCE; Schema: segContribu; Owner: postgres
--

CREATE SEQUENCE tbl_modulo_id_modulo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "segContribu".tbl_modulo_id_modulo_seq OWNER TO postgres;

--
-- TOC entry 3913 (class 0 OID 0)
-- Dependencies: 306
-- Name: tbl_modulo_id_modulo_seq; Type: SEQUENCE OWNED BY; Schema: segContribu; Owner: postgres
--

ALTER SEQUENCE tbl_modulo_id_modulo_seq OWNED BY tbl_modulo_contribu.id_modulo;


--
-- TOC entry 307 (class 1259 OID 129007)
-- Dependencies: 2535 8
-- Name: tbl_permiso_contribu; Type: TABLE; Schema: segContribu; Owner: postgres; Tablespace: 
--

CREATE TABLE tbl_permiso_contribu (
    id_permiso bigint NOT NULL,
    id_modulo bigint NOT NULL,
    id_rol bigint NOT NULL,
    int_permiso integer NOT NULL,
    bln_borrado boolean DEFAULT false NOT NULL
);


ALTER TABLE "segContribu".tbl_permiso_contribu OWNER TO postgres;

--
-- TOC entry 3914 (class 0 OID 0)
-- Dependencies: 307
-- Name: TABLE tbl_permiso_contribu; Type: COMMENT; Schema: segContribu; Owner: postgres
--

COMMENT ON TABLE tbl_permiso_contribu IS 'Permisos de los roles sobre los módulos';


--
-- TOC entry 308 (class 1259 OID 129011)
-- Dependencies: 8 307
-- Name: tbl_permiso_id_permiso_seq; Type: SEQUENCE; Schema: segContribu; Owner: postgres
--

CREATE SEQUENCE tbl_permiso_id_permiso_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "segContribu".tbl_permiso_id_permiso_seq OWNER TO postgres;

--
-- TOC entry 3915 (class 0 OID 0)
-- Dependencies: 308
-- Name: tbl_permiso_id_permiso_seq; Type: SEQUENCE OWNED BY; Schema: segContribu; Owner: postgres
--

ALTER SEQUENCE tbl_permiso_id_permiso_seq OWNED BY tbl_permiso_contribu.id_permiso;


--
-- TOC entry 309 (class 1259 OID 129013)
-- Dependencies: 2537 8
-- Name: tbl_rol_contribu; Type: TABLE; Schema: segContribu; Owner: postgres; Tablespace: 
--

CREATE TABLE tbl_rol_contribu (
    id_rol bigint NOT NULL,
    str_rol character varying(100) NOT NULL,
    str_descripcion character varying(500),
    bln_borrado boolean DEFAULT false NOT NULL
);


ALTER TABLE "segContribu".tbl_rol_contribu OWNER TO postgres;

--
-- TOC entry 3916 (class 0 OID 0)
-- Dependencies: 309
-- Name: TABLE tbl_rol_contribu; Type: COMMENT; Schema: segContribu; Owner: postgres
--

COMMENT ON TABLE tbl_rol_contribu IS 'Roles de los usuarios del sistema';


--
-- TOC entry 310 (class 1259 OID 129020)
-- Dependencies: 309 8
-- Name: tbl_rol_id_rol_seq; Type: SEQUENCE; Schema: segContribu; Owner: postgres
--

CREATE SEQUENCE tbl_rol_id_rol_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "segContribu".tbl_rol_id_rol_seq OWNER TO postgres;

--
-- TOC entry 3917 (class 0 OID 0)
-- Dependencies: 310
-- Name: tbl_rol_id_rol_seq; Type: SEQUENCE OWNED BY; Schema: segContribu; Owner: postgres
--

ALTER SEQUENCE tbl_rol_id_rol_seq OWNED BY tbl_rol_contribu.id_rol;


--
-- TOC entry 311 (class 1259 OID 129022)
-- Dependencies: 2539 8
-- Name: tbl_rol_usuario_contribu; Type: TABLE; Schema: segContribu; Owner: postgres; Tablespace: 
--

CREATE TABLE tbl_rol_usuario_contribu (
    id_rol_usuario bigint NOT NULL,
    id_rol bigint NOT NULL,
    id_usuario bigint NOT NULL,
    bln_borrado boolean DEFAULT false NOT NULL
);


ALTER TABLE "segContribu".tbl_rol_usuario_contribu OWNER TO postgres;

--
-- TOC entry 3918 (class 0 OID 0)
-- Dependencies: 311
-- Name: TABLE tbl_rol_usuario_contribu; Type: COMMENT; Schema: segContribu; Owner: postgres
--

COMMENT ON TABLE tbl_rol_usuario_contribu IS 'Roles de los usuarios, un usuario puede tener multiples roles dentro del sistema';


--
-- TOC entry 3919 (class 0 OID 0)
-- Dependencies: 311
-- Name: COLUMN tbl_rol_usuario_contribu.id_rol_usuario; Type: COMMENT; Schema: segContribu; Owner: postgres
--

COMMENT ON COLUMN tbl_rol_usuario_contribu.id_rol_usuario IS 'Identificador del usuario';


--
-- TOC entry 3920 (class 0 OID 0)
-- Dependencies: 311
-- Name: COLUMN tbl_rol_usuario_contribu.id_rol; Type: COMMENT; Schema: segContribu; Owner: postgres
--

COMMENT ON COLUMN tbl_rol_usuario_contribu.id_rol IS 'Relación con el rol';


--
-- TOC entry 3921 (class 0 OID 0)
-- Dependencies: 311
-- Name: COLUMN tbl_rol_usuario_contribu.id_usuario; Type: COMMENT; Schema: segContribu; Owner: postgres
--

COMMENT ON COLUMN tbl_rol_usuario_contribu.id_usuario IS 'Relación con el usuario';


--
-- TOC entry 3922 (class 0 OID 0)
-- Dependencies: 311
-- Name: COLUMN tbl_rol_usuario_contribu.bln_borrado; Type: COMMENT; Schema: segContribu; Owner: postgres
--

COMMENT ON COLUMN tbl_rol_usuario_contribu.bln_borrado IS 'Marca de borrado lógico';


--
-- TOC entry 312 (class 1259 OID 129026)
-- Dependencies: 311 8
-- Name: tbl_rol_usuario_id_rol_usuario_seq; Type: SEQUENCE; Schema: segContribu; Owner: postgres
--

CREATE SEQUENCE tbl_rol_usuario_id_rol_usuario_seq
    START WITH 1
    INCREMENT BY 1
    MINVALUE 0
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "segContribu".tbl_rol_usuario_id_rol_usuario_seq OWNER TO postgres;

--
-- TOC entry 3923 (class 0 OID 0)
-- Dependencies: 312
-- Name: tbl_rol_usuario_id_rol_usuario_seq; Type: SEQUENCE OWNED BY; Schema: segContribu; Owner: postgres
--

ALTER SEQUENCE tbl_rol_usuario_id_rol_usuario_seq OWNED BY tbl_rol_usuario_contribu.id_rol_usuario;


--
-- TOC entry 313 (class 1259 OID 129028)
-- Dependencies: 2541 8
-- Name: tbl_usuario_rol_contribu; Type: TABLE; Schema: segContribu; Owner: postgres; Tablespace: 
--

CREATE TABLE tbl_usuario_rol_contribu (
    id_usuario_rol bigint NOT NULL,
    id_usuario bigint NOT NULL,
    id_rol bigint NOT NULL,
    bol_borrado boolean DEFAULT false NOT NULL
);


ALTER TABLE "segContribu".tbl_usuario_rol_contribu OWNER TO postgres;

--
-- TOC entry 3924 (class 0 OID 0)
-- Dependencies: 313
-- Name: TABLE tbl_usuario_rol_contribu; Type: COMMENT; Schema: segContribu; Owner: postgres
--

COMMENT ON TABLE tbl_usuario_rol_contribu IS 'Permisos de los roles de usuarios sobre los módulos';


--
-- TOC entry 314 (class 1259 OID 129032)
-- Dependencies: 8 313
-- Name: tbl_usuario_rol_id_usuario_rol_seq; Type: SEQUENCE; Schema: segContribu; Owner: postgres
--

CREATE SEQUENCE tbl_usuario_rol_id_usuario_rol_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "segContribu".tbl_usuario_rol_id_usuario_rol_seq OWNER TO postgres;

--
-- TOC entry 3925 (class 0 OID 0)
-- Dependencies: 314
-- Name: tbl_usuario_rol_id_usuario_rol_seq; Type: SEQUENCE OWNED BY; Schema: segContribu; Owner: postgres
--

ALTER SEQUENCE tbl_usuario_rol_id_usuario_rol_seq OWNED BY tbl_usuario_rol_contribu.id_usuario_rol;


--
-- TOC entry 315 (class 1259 OID 129034)
-- Dependencies: 8
-- Name: view_modulo_usuariocontribuyente_permiso; Type: TABLE; Schema: segContribu; Owner: postgres; Tablespace: 
--

CREATE TABLE view_modulo_usuariocontribuyente_permiso (
    id integer,
    nombre character varying(100),
    str_rol character varying(100),
    id_modulo bigint,
    str_nombre character varying(300),
    str_enlace character varying(100),
    int_permiso integer,
    int_orden bigint,
    id_padre bigint
);


ALTER TABLE "segContribu".view_modulo_usuariocontribuyente_permiso OWNER TO postgres;

SET search_path = datos, pg_catalog;

--
-- TOC entry 2437 (class 2604 OID 129040)
-- Dependencies: 228 227
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY actas_reparo ALTER COLUMN id SET DEFAULT nextval('actas_reparo_id_seq'::regclass);


--
-- TOC entry 2360 (class 2604 OID 129041)
-- Dependencies: 168 167
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY actiecon ALTER COLUMN id SET DEFAULT nextval('"ActiEcon_IDActiEcon_seq"'::regclass);


--
-- TOC entry 2372 (class 2604 OID 129042)
-- Dependencies: 170 169
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY alicimp ALTER COLUMN id SET DEFAULT nextval('"AlicImp_IDAlicImp_seq"'::regclass);


--
-- TOC entry 2375 (class 2604 OID 129043)
-- Dependencies: 172 171
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asientod ALTER COLUMN id SET DEFAULT nextval('"AsientoD_IDAsientoD_seq"'::regclass);


--
-- TOC entry 2446 (class 2604 OID 129044)
-- Dependencies: 231 230
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asientom ALTER COLUMN id SET DEFAULT nextval('asientom_id_seq'::regclass);


--
-- TOC entry 2448 (class 2604 OID 129045)
-- Dependencies: 233 232
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asientomd ALTER COLUMN id SET DEFAULT nextval('asientomd_id_seq'::regclass);


--
-- TOC entry 2451 (class 2604 OID 129046)
-- Dependencies: 235 234
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asignacion_fiscales ALTER COLUMN id SET DEFAULT nextval('asignacion_fiscales_id_seq'::regclass);


--
-- TOC entry 2376 (class 2604 OID 129047)
-- Dependencies: 175 174
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY bacuenta ALTER COLUMN id SET DEFAULT nextval('"BaCuenta_IDBaCuenta_seq"'::regclass);


--
-- TOC entry 2377 (class 2604 OID 129048)
-- Dependencies: 177 176
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY bancos ALTER COLUMN id SET DEFAULT nextval('"Bancos_IDBanco_seq"'::regclass);


--
-- TOC entry 2380 (class 2604 OID 129049)
-- Dependencies: 181 180
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY calpago ALTER COLUMN id SET DEFAULT nextval('"CalPagos_IDCalPago_seq"'::regclass);


--
-- TOC entry 2378 (class 2604 OID 129050)
-- Dependencies: 179 178
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY calpagod ALTER COLUMN id SET DEFAULT nextval('"CalPagoD_IDCalPagoD_seq"'::regclass);


--
-- TOC entry 2381 (class 2604 OID 129051)
-- Dependencies: 183 182
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY cargos ALTER COLUMN id SET DEFAULT nextval('"Cargos_IDCargo_seq"'::regclass);


--
-- TOC entry 2382 (class 2604 OID 129052)
-- Dependencies: 185 184
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY ciudades ALTER COLUMN id SET DEFAULT nextval('"Ciudades_IDCiudad_seq"'::regclass);


--
-- TOC entry 2453 (class 2604 OID 129053)
-- Dependencies: 237 236
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY con_img_doc ALTER COLUMN id SET DEFAULT nextval('con_img_doc_id_seq'::regclass);


--
-- TOC entry 2455 (class 2604 OID 129054)
-- Dependencies: 239 238
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY contrib_calc ALTER COLUMN id SET DEFAULT nextval('contrib_calc_id_seq'::regclass);


--
-- TOC entry 2400 (class 2604 OID 129055)
-- Dependencies: 195 194
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY contribu ALTER COLUMN id SET DEFAULT nextval('"Contribu_IDContribu_seq"'::regclass);


--
-- TOC entry 2456 (class 2604 OID 129056)
-- Dependencies: 241 240
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY contributi ALTER COLUMN id SET DEFAULT nextval('contributi_id_seq'::regclass);


--
-- TOC entry 2395 (class 2604 OID 129057)
-- Dependencies: 193 192
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusu ALTER COLUMN id SET DEFAULT nextval('"ConUsu_IDConUsu_seq"'::regclass);


--
-- TOC entry 2460 (class 2604 OID 129058)
-- Dependencies: 243 242
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusu_interno ALTER COLUMN id SET DEFAULT nextval('conusu_interno_id_seq'::regclass);


--
-- TOC entry 2462 (class 2604 OID 129059)
-- Dependencies: 245 244
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusu_tipocont ALTER COLUMN id SET DEFAULT nextval('conusu_tipocon_id_seq'::regclass);


--
-- TOC entry 2383 (class 2604 OID 129060)
-- Dependencies: 187 186
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusuco ALTER COLUMN id SET DEFAULT nextval('"ConUsuCo_IDConUsuCo_seq"'::regclass);


--
-- TOC entry 2387 (class 2604 OID 129061)
-- Dependencies: 189 188
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusuti ALTER COLUMN id SET DEFAULT nextval('"ConUsuTi_IDConUsuTi_seq"'::regclass);


--
-- TOC entry 2390 (class 2604 OID 129062)
-- Dependencies: 191 190
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusuto ALTER COLUMN id SET DEFAULT nextval('"ConUsuTo_IDConUsuTo_seq"'::regclass);


--
-- TOC entry 2463 (class 2604 OID 129063)
-- Dependencies: 247 246
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY correlativos_actas ALTER COLUMN id SET DEFAULT nextval('correlativos_actas_id_seq'::regclass);


--
-- TOC entry 2464 (class 2604 OID 129064)
-- Dependencies: 249 248
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY correos_enviados ALTER COLUMN id SET DEFAULT nextval('correos_enviados_id_seq'::regclass);


--
-- TOC entry 2409 (class 2604 OID 129065)
-- Dependencies: 197 196
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara_viejo ALTER COLUMN id SET DEFAULT nextval('"Declara_IDDeclara_seq"'::regclass);


--
-- TOC entry 2410 (class 2604 OID 129066)
-- Dependencies: 199 198
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY departam ALTER COLUMN id SET DEFAULT nextval('"Departam_IDDepartam_seq"'::regclass);


--
-- TOC entry 2478 (class 2604 OID 129067)
-- Dependencies: 257 256
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY descargos ALTER COLUMN id SET DEFAULT nextval('descargos_id_seq'::regclass);


--
-- TOC entry 2479 (class 2604 OID 129068)
-- Dependencies: 259 258
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY detalle_interes ALTER COLUMN id SET DEFAULT nextval('detalle_interes_id_seq'::regclass);


--
-- TOC entry 2480 (class 2604 OID 129069)
-- Dependencies: 261 260
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY detalle_interes_viejo ALTER COLUMN id SET DEFAULT nextval('detalle_interes_id_seq1'::regclass);


--
-- TOC entry 2481 (class 2604 OID 129070)
-- Dependencies: 263 262
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY detalles_contrib_calc ALTER COLUMN id SET DEFAULT nextval('detalles_contrib_calc_id_seq'::regclass);


--
-- TOC entry 2485 (class 2604 OID 129071)
-- Dependencies: 265 264
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY dettalles_fizcalizacion ALTER COLUMN id SET DEFAULT nextval('dettalles_fizcalizacion_id_seq'::regclass);


--
-- TOC entry 2487 (class 2604 OID 129072)
-- Dependencies: 267 266
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY document ALTER COLUMN id SET DEFAULT nextval('document_id_seq'::regclass);


--
-- TOC entry 2414 (class 2604 OID 129073)
-- Dependencies: 203 202
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY entidad ALTER COLUMN id SET DEFAULT nextval('"Entidad_IDEntidad_seq"'::regclass);


--
-- TOC entry 2412 (class 2604 OID 129074)
-- Dependencies: 201 200
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY entidadd ALTER COLUMN id SET DEFAULT nextval('"EntidadD_IDEntidadD_seq"'::regclass);


--
-- TOC entry 2415 (class 2604 OID 129075)
-- Dependencies: 205 204
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY estados ALTER COLUMN id SET DEFAULT nextval('"Estados_IDEstado_seq"'::regclass);


--
-- TOC entry 2488 (class 2604 OID 129076)
-- Dependencies: 270 268
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY interes_bcv ALTER COLUMN id SET DEFAULT nextval('interes_bcv_id_seq'::regclass);


--
-- TOC entry 2418 (class 2604 OID 129077)
-- Dependencies: 209 208
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY perusu ALTER COLUMN id SET DEFAULT nextval('"PerUsu_IDPerUsu_seq"'::regclass);


--
-- TOC entry 2416 (class 2604 OID 129078)
-- Dependencies: 207 206
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY perusud ALTER COLUMN id SET DEFAULT nextval('"PerUsuD_IDPerUsuD_seq"'::regclass);


--
-- TOC entry 2419 (class 2604 OID 129079)
-- Dependencies: 211 210
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY pregsecr ALTER COLUMN id SET DEFAULT nextval('"PregSecr_IDPregSecr_seq"'::regclass);


--
-- TOC entry 2490 (class 2604 OID 129080)
-- Dependencies: 272 271
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY presidente ALTER COLUMN id SET DEFAULT nextval('presidente_id_seq'::regclass);


--
-- TOC entry 2420 (class 2604 OID 129081)
-- Dependencies: 213 212
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY replegal ALTER COLUMN id SET DEFAULT nextval('"RepLegal_IDRepLegal_seq"'::regclass);


--
-- TOC entry 2421 (class 2604 OID 129082)
-- Dependencies: 215 214
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tdeclara ALTER COLUMN id SET DEFAULT nextval('"TDeclara_IDTDeclara_seq"'::regclass);


--
-- TOC entry 2424 (class 2604 OID 129083)
-- Dependencies: 217 216
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tipegrav ALTER COLUMN id SET DEFAULT nextval('"TiPeGrav_IDTiPeGrav_seq"'::regclass);


--
-- TOC entry 2425 (class 2604 OID 129084)
-- Dependencies: 219 218
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tipocont ALTER COLUMN id SET DEFAULT nextval('"TipoCont_IDTipoCont_seq"'::regclass);


--
-- TOC entry 2427 (class 2604 OID 129085)
-- Dependencies: 221 220
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY undtrib ALTER COLUMN id SET DEFAULT nextval('"UndTrib_IDUndTrib_seq"'::regclass);


--
-- TOC entry 2432 (class 2604 OID 129086)
-- Dependencies: 225 224
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY usfonpro ALTER COLUMN id SET DEFAULT nextval('"Usuarios_IDUsuario_seq"'::regclass);


--
-- TOC entry 2429 (class 2604 OID 129087)
-- Dependencies: 223 222
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY usfonpto ALTER COLUMN id SET DEFAULT nextval('"UsFonpTo_IDUsFonpTo_seq"'::regclass);


SET search_path = historial, pg_catalog;

--
-- TOC entry 2502 (class 2604 OID 129088)
-- Dependencies: 279 278
-- Name: id; Type: DEFAULT; Schema: historial; Owner: postgres
--

ALTER TABLE ONLY bitacora ALTER COLUMN id SET DEFAULT nextval('"Bitacora_IDBitacora_seq"'::regclass);


SET search_path = pre_aprobacion, pg_catalog;

--
-- TOC entry 2507 (class 2604 OID 129089)
-- Dependencies: 281 280
-- Name: id; Type: DEFAULT; Schema: pre_aprobacion; Owner: postgres
--

ALTER TABLE ONLY datos_cnac ALTER COLUMN id SET DEFAULT nextval('datos_cnac_id_seq'::regclass);


--
-- TOC entry 2476 (class 2604 OID 129090)
-- Dependencies: 282 253
-- Name: id; Type: DEFAULT; Schema: pre_aprobacion; Owner: postgres
--

ALTER TABLE ONLY intereses ALTER COLUMN id SET DEFAULT nextval('intereses_id_seq'::regclass);


--
-- TOC entry 2477 (class 2604 OID 129091)
-- Dependencies: 283 254
-- Name: id; Type: DEFAULT; Schema: pre_aprobacion; Owner: postgres
--

ALTER TABLE ONLY multas ALTER COLUMN id SET DEFAULT nextval('multas_id_seq'::regclass);


SET search_path = seg, pg_catalog;

--
-- TOC entry 2509 (class 2604 OID 129092)
-- Dependencies: 286 285
-- Name: id; Type: DEFAULT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_cargos ALTER COLUMN id SET DEFAULT nextval('tbl_cargos_id_seq'::regclass);


--
-- TOC entry 2515 (class 2604 OID 129093)
-- Dependencies: 289 288
-- Name: id_modulo; Type: DEFAULT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_modulo ALTER COLUMN id_modulo SET DEFAULT nextval('tbl_modulo_id_modulo_seq'::regclass);


--
-- TOC entry 2518 (class 2604 OID 129094)
-- Dependencies: 291 290
-- Name: id; Type: DEFAULT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_oficinas ALTER COLUMN id SET DEFAULT nextval('tbl_oficinas_id_seq'::regclass);


--
-- TOC entry 2520 (class 2604 OID 129095)
-- Dependencies: 293 292
-- Name: id_permiso; Type: DEFAULT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_permiso ALTER COLUMN id_permiso SET DEFAULT nextval('tbl_permiso_id_permiso_seq'::regclass);


--
-- TOC entry 2522 (class 2604 OID 129096)
-- Dependencies: 295 294
-- Name: id_permiso; Type: DEFAULT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_permiso_trampa ALTER COLUMN id_permiso SET DEFAULT nextval('tbl_permiso_trampa_id_permiso_seq'::regclass);


--
-- TOC entry 2524 (class 2604 OID 129097)
-- Dependencies: 297 296
-- Name: id_rol; Type: DEFAULT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_rol ALTER COLUMN id_rol SET DEFAULT nextval('tbl_rol_id_rol_seq'::regclass);


--
-- TOC entry 2526 (class 2604 OID 129098)
-- Dependencies: 299 298
-- Name: id_rol_usuario; Type: DEFAULT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_rol_usuario ALTER COLUMN id_rol_usuario SET DEFAULT nextval('tbl_rol_usuario_id_rol_usuario_seq'::regclass);


--
-- TOC entry 2532 (class 2604 OID 129099)
-- Dependencies: 302 301
-- Name: id_usuario_rol; Type: DEFAULT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_usuario_rol ALTER COLUMN id_usuario_rol SET DEFAULT nextval('tbl_usuario_rol_id_usuario_rol_seq'::regclass);


SET search_path = "segContribu", pg_catalog;

--
-- TOC entry 2534 (class 2604 OID 129100)
-- Dependencies: 306 305
-- Name: id_modulo; Type: DEFAULT; Schema: segContribu; Owner: postgres
--

ALTER TABLE ONLY tbl_modulo_contribu ALTER COLUMN id_modulo SET DEFAULT nextval('tbl_modulo_id_modulo_seq'::regclass);


--
-- TOC entry 2536 (class 2604 OID 129101)
-- Dependencies: 308 307
-- Name: id_permiso; Type: DEFAULT; Schema: segContribu; Owner: postgres
--

ALTER TABLE ONLY tbl_permiso_contribu ALTER COLUMN id_permiso SET DEFAULT nextval('tbl_permiso_id_permiso_seq'::regclass);


--
-- TOC entry 2538 (class 2604 OID 129102)
-- Dependencies: 310 309
-- Name: id_rol; Type: DEFAULT; Schema: segContribu; Owner: postgres
--

ALTER TABLE ONLY tbl_rol_contribu ALTER COLUMN id_rol SET DEFAULT nextval('tbl_rol_id_rol_seq'::regclass);


--
-- TOC entry 2540 (class 2604 OID 129103)
-- Dependencies: 312 311
-- Name: id_rol_usuario; Type: DEFAULT; Schema: segContribu; Owner: postgres
--

ALTER TABLE ONLY tbl_rol_usuario_contribu ALTER COLUMN id_rol_usuario SET DEFAULT nextval('tbl_rol_usuario_id_rol_usuario_seq'::regclass);


--
-- TOC entry 2542 (class 2604 OID 129104)
-- Dependencies: 314 313
-- Name: id_usuario_rol; Type: DEFAULT; Schema: segContribu; Owner: postgres
--

ALTER TABLE ONLY tbl_usuario_rol_contribu ALTER COLUMN id_usuario_rol SET DEFAULT nextval('tbl_usuario_rol_id_usuario_rol_seq'::regclass);


SET search_path = datos, pg_catalog;

--
-- TOC entry 3926 (class 0 OID 0)
-- Dependencies: 166
-- Name: Accionis_ID_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Accionis_ID_seq"', 87, true);


--
-- TOC entry 3927 (class 0 OID 0)
-- Dependencies: 168
-- Name: ActiEcon_IDActiEcon_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"ActiEcon_IDActiEcon_seq"', 16, true);


--
-- TOC entry 3928 (class 0 OID 0)
-- Dependencies: 170
-- Name: AlicImp_IDAlicImp_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"AlicImp_IDAlicImp_seq"', 11, true);


--
-- TOC entry 3929 (class 0 OID 0)
-- Dependencies: 172
-- Name: AsientoD_IDAsientoD_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"AsientoD_IDAsientoD_seq"', 6, true);


--
-- TOC entry 3930 (class 0 OID 0)
-- Dependencies: 173
-- Name: Asiento_IDAsiento_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Asiento_IDAsiento_seq"', 2, true);


--
-- TOC entry 3931 (class 0 OID 0)
-- Dependencies: 175
-- Name: BaCuenta_IDBaCuenta_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"BaCuenta_IDBaCuenta_seq"', 1, false);


--
-- TOC entry 3932 (class 0 OID 0)
-- Dependencies: 177
-- Name: Bancos_IDBanco_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Bancos_IDBanco_seq"', 1, false);


--
-- TOC entry 3933 (class 0 OID 0)
-- Dependencies: 179
-- Name: CalPagoD_IDCalPagoD_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"CalPagoD_IDCalPagoD_seq"', 365, true);


--
-- TOC entry 3934 (class 0 OID 0)
-- Dependencies: 181
-- Name: CalPagos_IDCalPago_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"CalPagos_IDCalPago_seq"', 51, true);


--
-- TOC entry 3935 (class 0 OID 0)
-- Dependencies: 183
-- Name: Cargos_IDCargo_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Cargos_IDCargo_seq"', 16, true);


--
-- TOC entry 3936 (class 0 OID 0)
-- Dependencies: 185
-- Name: Ciudades_IDCiudad_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Ciudades_IDCiudad_seq"', 360, true);


--
-- TOC entry 3937 (class 0 OID 0)
-- Dependencies: 187
-- Name: ConUsuCo_IDConUsuCo_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"ConUsuCo_IDConUsuCo_seq"', 1, false);


--
-- TOC entry 3938 (class 0 OID 0)
-- Dependencies: 189
-- Name: ConUsuTi_IDConUsuTi_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"ConUsuTi_IDConUsuTi_seq"', 1, true);


--
-- TOC entry 3939 (class 0 OID 0)
-- Dependencies: 191
-- Name: ConUsuTo_IDConUsuTo_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"ConUsuTo_IDConUsuTo_seq"', 139, true);


--
-- TOC entry 3940 (class 0 OID 0)
-- Dependencies: 193
-- Name: ConUsu_IDConUsu_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"ConUsu_IDConUsu_seq"', 153, true);


--
-- TOC entry 3941 (class 0 OID 0)
-- Dependencies: 195
-- Name: Contribu_IDContribu_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Contribu_IDContribu_seq"', 47, true);


--
-- TOC entry 3942 (class 0 OID 0)
-- Dependencies: 197
-- Name: Declara_IDDeclara_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Declara_IDDeclara_seq"', 618, true);


--
-- TOC entry 3943 (class 0 OID 0)
-- Dependencies: 199
-- Name: Departam_IDDepartam_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Departam_IDDepartam_seq"', 10, true);


--
-- TOC entry 3944 (class 0 OID 0)
-- Dependencies: 201
-- Name: EntidadD_IDEntidadD_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"EntidadD_IDEntidadD_seq"', 1, false);


--
-- TOC entry 3945 (class 0 OID 0)
-- Dependencies: 203
-- Name: Entidad_IDEntidad_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Entidad_IDEntidad_seq"', 1, false);


--
-- TOC entry 3946 (class 0 OID 0)
-- Dependencies: 205
-- Name: Estados_IDEstado_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Estados_IDEstado_seq"', 27, true);


--
-- TOC entry 3947 (class 0 OID 0)
-- Dependencies: 207
-- Name: PerUsuD_IDPerUsuD_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"PerUsuD_IDPerUsuD_seq"', 1, false);


--
-- TOC entry 3948 (class 0 OID 0)
-- Dependencies: 209
-- Name: PerUsu_IDPerUsu_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"PerUsu_IDPerUsu_seq"', 1, false);


--
-- TOC entry 3949 (class 0 OID 0)
-- Dependencies: 211
-- Name: PregSecr_IDPregSecr_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"PregSecr_IDPregSecr_seq"', 7, true);


--
-- TOC entry 3950 (class 0 OID 0)
-- Dependencies: 213
-- Name: RepLegal_IDRepLegal_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"RepLegal_IDRepLegal_seq"', 9, true);


--
-- TOC entry 3951 (class 0 OID 0)
-- Dependencies: 215
-- Name: TDeclara_IDTDeclara_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"TDeclara_IDTDeclara_seq"', 8, true);


--
-- TOC entry 3952 (class 0 OID 0)
-- Dependencies: 217
-- Name: TiPeGrav_IDTiPeGrav_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"TiPeGrav_IDTiPeGrav_seq"', 6, true);


--
-- TOC entry 3953 (class 0 OID 0)
-- Dependencies: 219
-- Name: TipoCont_IDTipoCont_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"TipoCont_IDTipoCont_seq"', 7, true);


--
-- TOC entry 3954 (class 0 OID 0)
-- Dependencies: 221
-- Name: UndTrib_IDUndTrib_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"UndTrib_IDUndTrib_seq"', 24, true);


--
-- TOC entry 3955 (class 0 OID 0)
-- Dependencies: 223
-- Name: UsFonpTo_IDUsFonpTo_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"UsFonpTo_IDUsFonpTo_seq"', 1, false);


--
-- TOC entry 3956 (class 0 OID 0)
-- Dependencies: 225
-- Name: Usuarios_IDUsuario_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Usuarios_IDUsuario_seq"', 51, true);


--
-- TOC entry 3237 (class 0 OID 128599)
-- Dependencies: 226 3321
-- Data for Name: accionis; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY accionis (id, contribuid, nombre, apellido, ci, domfiscal, nuacciones, valaccion, cextra1, cextra2, cextra3, cextra4, cextra5, usuarioid, ip) FROM stdin;
75	144	yo	yo	17042979	yo	1000	500000.00	\N	\N	\N	\N	\N	\N	127.0.0.1
77	146	jeisy	palacios	18164390	jkdfhvjksdhlfd	10000	50000.00	\N	\N	\N	\N	\N	\N	127.0.0.1
81	145	jefferson arturo 	lara molina	17042979	jhagkskajsgaks	1000	0.00	\N	\N	\N	\N	\N	\N	127.0.0.1
82	147	jefferosn	lara	17042979	caracs	1000	0.00	\N	\N	\N	\N	\N	\N	127.0.0.1
86	148	jefferson arturo	lara molina	17042979	los teques	1000	0.00	\N	\N	\N	\N	\N	\N	127.0.0.1
87	153	jose antonio	paez andara	15100385	urbanizacion los rosales casa numero 35 san juan de los morros estado guarico	100	0.00	\N	\N	\N	\N	\N	\N	127.0.0.1
\.


--
-- TOC entry 3238 (class 0 OID 128608)
-- Dependencies: 227 3321
-- Data for Name: actas_reparo; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY actas_reparo (id, numero, ruta_servidor, fecha_adjunto, usuarioid, ip) FROM stdin;
119	1-2013	./archivos/fiscalizacion/2013/18e0eb5ea9f49210a030b04df7bf159f.doc	2013-11-12 11:51:10.457519	48	127.0.0.1
120	2-2013	./archivos/fiscalizacion/2013/685e9c110bad8415c096de105c5d131a.pdf	2013-11-12 14:58:45.949083	48	127.0.0.1
122	4-2013	./archivos/fiscalizacion/2013/83eb23fb9600cc1cae61debb9d33cc42.pdf	2013-11-12 15:45:42.788351	48	127.0.0.1
123	5-2013	./archivos/fiscalizacion/2013/c08df47ce301925c7a326eaf8a1bf14e.pdf	2013-11-12 15:48:40.298082	48	127.0.0.1
124	6-2013	./archivos/fiscalizacion/2013/30bbec9473dfb297a88df4822e626084.pdf	2013-11-12 16:03:52.843383	48	127.0.0.1
125	7-2013	./archivos/fiscalizacion/2013/e4c2f3cbd4618b41bdb86ec5670bab9e.pdf	2013-11-13 15:08:37.633536	48	127.0.0.1
126	8-2013	./archivos/fiscalizacion/2013/0238efad6229569353981efc28c26d24.pdf	2013-11-13 15:13:37.270381	48	127.0.0.1
127	9-2013	./archivos/fiscalizacion/2013/97c307076bff81df6778d09bbe04c7a3.pdf	2013-11-13 15:23:55.522806	48	127.0.0.1
128	10-2013	./archivos/fiscalizacion/2013/92f46e315e81b00b74aea2ed7eccc071.pdf	2013-11-14 16:57:58.527318	48	127.0.0.1
129	11-2013	./archivos/fiscalizacion/2013/f2aae5040e377d95ad170831e859fc8d.pdf	2013-11-15 10:00:58.017283	48	127.0.0.1
\.


--
-- TOC entry 3957 (class 0 OID 0)
-- Dependencies: 228
-- Name: actas_reparo_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('actas_reparo_id_seq', 129, true);


--
-- TOC entry 3178 (class 0 OID 128378)
-- Dependencies: 167 3321
-- Data for Name: actiecon; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY actiecon (id, nombre, usuarioid, ip) FROM stdin;
4	Ferias de exposición de productos de la industria, agricultura, etc.\n	16	192.168.1.102
5	Producción de películas cinematográficas	16	192.168.1.102
6	Emisiones de radio y televisión	16	192.168.1.102
7	Productores teatrales\n	16	192.168.1.102
8	Escenografía e iluminación	16	192.168.1.102
9	 Cines, teatros y distribución de películas cinematográficas	16	192.168.1.102
10	Autores, compositores y otros artistas independientes, no clasificados en otra parte\n	16	192.168.1.102
13	Agencias periodisticas, de información y noticias	16	192.168.1.102
14	Periodistas\n	16	192.168.1.102
15	Bibliotecas, museos, jardines botánicos y zoológicos e instituciones análogas\n	16	192.168.1.102
16	otro	16	192.168.1.102
\.


--
-- TOC entry 3180 (class 0 OID 128383)
-- Dependencies: 169 3321
-- Data for Name: alicimp; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY alicimp (id, tipocontid, ano, alicuota, tipocalc, valorut, liminf1, limsup1, alicuota1, liminf2, limsup2, alicuota2, liminf3, limsup3, alicuota3, liminf4, limsup4, alicuota4, liminf5, limsup5, alicuota5, usuarioid, ip) FROM stdin;
2	1	2005	3.00	0	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	17	192.168.1.101
3	1	2006	4.00	0	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	17	192.168.1.101
4	1	2007	5.00	0	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	17	192.168.1.101
6	3	2006	0.50	0	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	17	192.168.1.101
7	3	2007	1.00	0	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	17	192.168.1.101
8	3	2008	1.50	0	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	17	192.168.1.101
10	5	0	5.00	0	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	17	192.168.1.101
11	6	0	1.00	0	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	17	192.168.1.101
9	4	0	5.00	2	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	17	192.168.1.101
5	2	0	0.00	2	0.00	25000.00	40000.00	0.50	40000.00	80000.00	1.00	80000.00	0.00	1.50	0.00	0.00	0.00	0.00	0.00	0.00	17	192.168.1.101
\.


--
-- TOC entry 3240 (class 0 OID 128617)
-- Dependencies: 229 3321
-- Data for Name: asiento; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY asiento (id, nuasiento, fecha, mes, ano, debe, haber, saldo, comentar, cerrado, uscierreid, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 3182 (class 0 OID 128399)
-- Dependencies: 171 3321
-- Data for Name: asientod; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY asientod (id, asientoid, fecha, cuenta, monto, sentido, referencia, comentar, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 3241 (class 0 OID 128631)
-- Dependencies: 230 3321
-- Data for Name: asientom; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY asientom (id, nombre, comentar, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 3958 (class 0 OID 0)
-- Dependencies: 231
-- Name: asientom_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('asientom_id_seq', 1, false);


--
-- TOC entry 3243 (class 0 OID 128639)
-- Dependencies: 232 3321
-- Data for Name: asientomd; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY asientomd (id, asientomid, cuenta, sentido, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 3959 (class 0 OID 0)
-- Dependencies: 233
-- Name: asientomd_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('asientomd_id_seq', 1, false);


--
-- TOC entry 3245 (class 0 OID 128645)
-- Dependencies: 234 3321
-- Data for Name: asignacion_fiscales; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY asignacion_fiscales (id, fecha_asignacion, usfonproid, conusuid, prioridad, estatus, fecha_fiscalizacion, usuarioid, ip, tipocontid, nro_autorizacion, periodo_afiscalizar) FROM stdin;
963	2013-11-12	48	146	t	2	2013-11-12	48	127.0.0.1	1	44-2013	2008
964	2013-11-12	48	146	t	2	2013-11-12	48	127.0.0.1	2	45-2013	2011
965	2013-11-12	48	146	f	2	2013-11-12	48	127.0.0.1	4	46-2013	2010
967	2013-11-13	48	146	f	2	2013-11-13	48	127.0.0.1	3	48-2013	2011
968	2013-11-13	48	146	t	2	2013-11-13	48	127.0.0.1	1	49-2013	2012
966	2013-11-13	48	146	t	2	2013-11-13	48	127.0.0.1	2	47-2013	2012
969	2013-11-14	48	1	t	2	2013-11-14	48	127.0.0.1	1	50-2013	2008
970	2013-11-15	48	146	t	2	2013-11-15	48	127.0.0.1	2	51-2013	2009
\.


--
-- TOC entry 3960 (class 0 OID 0)
-- Dependencies: 235
-- Name: asignacion_fiscales_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('asignacion_fiscales_id_seq', 970, true);


--
-- TOC entry 3185 (class 0 OID 128411)
-- Dependencies: 174 3321
-- Data for Name: bacuenta; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY bacuenta (id, bancoid, cuenta, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 3187 (class 0 OID 128416)
-- Dependencies: 176 3321
-- Data for Name: bancos; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY bancos (id, nombre, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 3191 (class 0 OID 128426)
-- Dependencies: 180 3321
-- Data for Name: calpago; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY calpago (id, nombre, ano, tipegravid, usuarioid, ip) FROM stdin;
4	CALENDARIO DE OBLIGACIONES TRIBUTARIAS EXHIBIDORES 2012	2012	1	17	192.168.1.102
5	CALENDARIO DE OBLIGACIONES TRIBUTARIAS EXHIBIDORES 2006	2006	1	17	192.168.1.102
6	CALENDARIO DE OBLIGACIONES TRIBUTARIAS TV Señal Abierta 2006	2006	3	17	192,168,1,102
7	CALENDARIO DE OBLIGACIONES TRIBUTARIAS TV Suscripción 2006	2006	5	17	192,168,1,102
8	CALENDARIO DE OBLIGACIONES TRIBUTARIAS Distribuidores 2006	2006	4	17	192,168,1,102
9	CALENDARIO DE OBLIGACIONES TRIBUTARIAS Venta y Alquiler 2006	2006	2	17	192,168,1,102
10	CALENDARIO DE OBLIGACIONES TRIBUTARIAS Producción 2006	2006	6	17	192,168,1,102
11	CALENDARIO DE OBLIGACIONES TRIBUTARIAS Exhibidores  2007	2007	1	17	192,168,1,102
12	CALENDARIO DE OBLIGACIONES TRIBUTARIAS TV Señal Abierta  2007	2007	3	17	192,168,1,102
13	CALENDARIO DE OBLIGACIONES TRIBUTARIAS TV Suscripción  2007	2007	5	17	192,168,1,102
14	CALENDARIO DE OBLIGACIONES TRIBUTARIAS Distribuidores  2007	2007	4	17	192,168,1,102
15	CALENDARIO DE OBLIGACIONES TRIBUTARIAS Venta y Alquiler  2007	2007	2	17	192,168,1,102
16	CALENDARIO DE OBLIGACIONES TRIBUTARIAS Producción  2007	2007	6	17	192,168,1,102
17	CALENDARIO DE OBLIGACIONES TRIBUTARIAS Exhibidores  2008	2008	1	17	192,168,1,102
18	CALENDARIO DE OBLIGACIONES TRIBUTARIAS TV Señal Abierta  2008	2008	3	17	192,168,1,102
19	CALENDARIO DE OBLIGACIONES TRIBUTARIAS TV Suscripción  2008	2008	5	17	192,168,1,102
20	CALENDARIO DE OBLIGACIONES TRIBUTARIAS Distribuidores  2008	2008	4	17	192,168,1,102
21	CALENDARIO DE OBLIGACIONES TRIBUTARIAS Venta y Alquiler  2008	2008	2	17	192,168,1,102
22	CALENDARIO DE OBLIGACIONES TRIBUTARIAS Producción  2008	2008	6	17	192,168,1,102
23	CALENDARIO DE OBLIGACIONES TRIBUTARIAS Exhibidores  2009	2009	1	17	192,168,1,102
24	CALENDARIO DE OBLIGACIONES TRIBUTARIAS TV Señal Abierta  2009	2009	3	17	192,168,1,102
25	CALENDARIO DE OBLIGACIONES TRIBUTARIAS TV Suscripción  2009	2009	5	17	192,168,1,102
26	CALENDARIO DE OBLIGACIONES TRIBUTARIAS Distribuidores  2009	2009	4	17	192,168,1,102
27	CALENDARIO DE OBLIGACIONES TRIBUTARIAS Venta y Alquiler  2009	2009	2	17	192,168,1,102
28	CALENDARIO DE OBLIGACIONES TRIBUTARIAS Producción  2009	2009	6	17	192,168,1,102
29	CALENDARIO DE OBLIGACIONES TRIBUTARIAS Exhibidores  2010	2010	1	17	192,168,1,102
30	CALENDARIO DE OBLIGACIONES TRIBUTARIAS TV Señal Abierta  2010	2010	3	17	192,168,1,102
31	CALENDARIO DE OBLIGACIONES TRIBUTARIAS TV Suscripción  2010	2010	5	17	192,168,1,102
32	CALENDARIO DE OBLIGACIONES TRIBUTARIAS Distribuidores  2010	2010	4	17	192,168,1,102
33	CALENDARIO DE OBLIGACIONES TRIBUTARIAS Venta y Alquiler  2010	2010	2	17	192,168,1,102
34	CALENDARIO DE OBLIGACIONES TRIBUTARIAS Producción  2010	2010	6	17	192,168,1,102
35	CALENDARIO DE OBLIGACIONES TRIBUTARIAS Exhibidores  2011	2011	1	17	192,168,1,102
36	CALENDARIO DE OBLIGACIONES TRIBUTARIAS TV Señal Abierta  2011	2011	3	17	192,168,1,102
37	CALENDARIO DE OBLIGACIONES TRIBUTARIAS TV Suscripción  2011	2011	5	17	192,168,1,102
38	CALENDARIO DE OBLIGACIONES TRIBUTARIAS Distribuidores  2011	2011	4	17	192,168,1,102
39	CALENDARIO DE OBLIGACIONES TRIBUTARIAS Venta y Alquiler  2011	2011	2	17	192,168,1,102
40	CALENDARIO DE OBLIGACIONES TRIBUTARIAS Producción  2011	2011	6	17	192,168,1,102
41	CALENDARIO DE OBLIGACIONES TRIBUTARIAS TV Señal Abierta  2012	2012	3	17	192,168,1,102
42	CALENDARIO DE OBLIGACIONES TRIBUTARIAS TV Suscripción  2012	2012	5	17	192,168,1,102
43	CALENDARIO DE OBLIGACIONES TRIBUTARIAS Distribuidores  2012	2012	4	17	192,168,1,102
44	CALENDARIO DE OBLIGACIONES TRIBUTARIAS Venta y Alquiler  2012	2012	2	17	192,168,1,102
45	CALENDARIO DE OBLIGACIONES TRIBUTARIAS Producción  2012	2012	6	17	192,168,1,102
46	CALENDARIO DE OBLIGACIONES TRIBUTARIAS Exhibidores  2013	2013	1	17	192,168,1,102
47	CALENDARIO DE OBLIGACIONES TRIBUTARIAS TV Señal Abierta  2013	2013	3	17	192,168,1,102
48	CALENDARIO DE OBLIGACIONES TRIBUTARIAS TV Suscripción  2013	2013	5	17	192,168,1,102
49	CALENDARIO DE OBLIGACIONES TRIBUTARIAS Distribuidores  2013	2013	4	17	192,168,1,102
50	CALENDARIO DE OBLIGACIONES TRIBUTARIAS Venta y Alquiler  2013	2013	2	17	192,168,1,102
51	CALENDARIO DE OBLIGACIONES TRIBUTARIAS Producción  2013	2013	6	17	192,168,1,102
\.


--
-- TOC entry 3189 (class 0 OID 128421)
-- Dependencies: 178 3321
-- Data for Name: calpagod; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY calpagod (id, calpagoid, fechaini, fechafin, fechalim, usuarioid, ip, periodo) FROM stdin;
354	50	2013-05-15	2013-06-17	2013-06-17	17	192.168.1.102	05
342	46	2013-05-23	2013-06-25	2013-06-25	17	192.168.1.102	05
53	5	2006-05-22	2006-06-22	2006-06-22	17	192.168.1.102	05
76	9	2006-05-15	2006-06-15	2006-06-15	17	192.168.1.102	05
88	11	2007-05-23	2007-06-22	2007-06-22	17	192.168.1.102	05
100	15	2007-05-15	2007-06-15	2007-06-15	17	192.168.1.102	05
355	50	2013-06-17	2013-07-22	2013-07-22	17	192.168.1.102	06
343	46	2013-06-25	2013-07-22	2013-07-22	17	192.168.1.102	06
54	5	2006-06-22	2006-07-26	2006-07-26	17	192.168.1.102	06
77	9	2006-06-15	2006-07-17	2006-07-17	17	192.168.1.102	06
89	11	2007-06-22	2007-07-25	2007-07-25	17	192.168.1.102	06
101	15	2007-06-15	2007-07-16	2007-07-16	17	192.168.1.102	06
356	50	2013-07-15	2013-08-15	2013-08-15	17	192.168.1.102	07
344	46	2013-07-22	2013-08-22	2013-08-22	17	192.168.1.102	07
55	5	2006-07-26	2006-08-22	2006-08-22	17	192.168.1.102	07
78	9	2006-07-17	2006-08-15	2006-08-15	17	192.168.1.102	07
90	11	2007-07-25	2007-08-22	2007-08-22	17	192.168.1.102	07
102	15	2007-07-16	2007-08-15	2007-08-15	17	192.168.1.102	07
357	50	2013-08-15	2013-09-16	2013-09-16	17	192.168.1.102	08
345	46	2013-08-22	2013-09-20	2013-09-20	17	192.168.1.102	08
56	5	2006-08-22	2006-09-21	2006-09-21	17	192.168.1.102	08
359	50	2013-10-15	2013-11-15	2013-11-15	17	192.168.1.102	10
360	50	2013-11-16	2013-11-16	2013-12-16	17	192.168.1.102	11
361	50	2013-12-16	2014-01-15	2014-01-15	17	192.168.1.102	12
347	46	2013-10-21	2013-11-22	2013-11-22	17	192.168.1.102	10
348	46	2013-11-22	2013-12-20	2013-12-20	17	192.168.1.102	11
349	46	2013-12-20	2014-01-22	2014-01-22	17	192.168.1.102	12
79	9	2006-08-15	2006-09-15	2006-09-15	17	192.168.1.102	08
91	11	2007-08-22	2007-09-21	2007-09-21	17	192.168.1.102	08
103	15	2007-08-15	2007-09-17	2007-09-17	17	192.168.1.102	08
358	50	2013-09-16	2013-10-15	2013-10-15	17	192.168.1.102	09
20	4	2012-12-21	2013-01-23	2013-01-23	17	192.168.1.102	12
58	5	2006-10-23	2006-11-22	2006-11-22	17	192.168.1.102	10
59	5	2006-11-22	2006-12-22	2006-12-22	17	192.168.1.102	11
60	5	2006-12-22	2007-01-23	2007-01-23	17	192.168.1.102	12
81	9	2006-10-16	2006-11-15	2006-11-15	17	192.168.1.102	10
82	9	2006-11-15	2006-12-15	2006-12-15	17	192.168.1.102	11
83	9	2006-12-15	2007-01-15	2007-01-15	17	192.168.1.102	12
93	11	2007-10-22	2007-11-22	2007-11-22	17	192.168.1.102	10
94	11	2007-11-22	2007-12-21	2007-12-21	17	192.168.1.102	11
95	11	2007-12-21	2008-01-22	2008-01-22	17	192.168.1.102	12
105	15	2007-10-15	2007-11-15	2007-11-15	17	192.168.1.102	10
106	15	2007-11-15	2007-12-17	2007-12-17	17	192.168.1.102	11
107	15	2007-12-17	2008-01-15	2008-01-15	17	192.168.1.102	12
346	46	2013-09-20	2013-10-21	2013-10-21	17	192.168.1.102	09
57	5	2006-09-21	2006-10-23	2006-10-23	17	192.168.1.102	09
80	9	2006-09-15	2006-10-16	2006-10-16	17	192.168.1.102	09
351	50	2013-02-15	2013-03-15	2013-03-15	17	192.168.1.102	02
339	46	2013-02-25	2013-03-22	2013-03-22	17	192.168.1.102	02
363	48	2013-04-15	2013-07-15	2013-07-15	17	192.168.1.102	02
50	5	2006-02-21	2006-03-21	2006-03-21	17	192.168.1.102	02
73	9	2006-02-15	2006-03-15	2006-03-15	17	192.168.1.102	02
85	11	2007-02-23	2007-03-21	2007-03-21	17	192.168.1.102	02
97	15	2007-02-15	2007-03-15	2007-03-15	17	192.168.1.102	02
257	13	2007-04-16	2007-07-16	2007-07-16	17	192.168.1.102	02
261	16	2007-04-25	2007-07-25	2007-07-25	17	192.168.1.102	02
265	19	2008-04-15	2008-07-15	2008-07-15	17	192.168.1.102	02
269	22	2008-04-21	2008-07-21	2008-07-21	17	192.168.1.102	02
273	25	2009-04-15	2009-07-15	2009-07-15	17	192.168.1.102	02
277	28	2009-04-23	2009-07-21	2009-07-21	17	192.168.1.102	02
352	50	2013-03-15	2013-04-15	2013-04-15	17	192.168.1.102	03
340	46	2013-03-22	2013-04-22	2013-04-22	17	192.168.1.102	03
364	48	2013-07-15	2013-10-15	2013-10-15	17	192.168.1.102	03
51	5	2006-03-21	2006-04-26	2006-04-26	17	192.168.1.102	03
74	9	2006-03-15	2006-04-17	2006-04-17	17	192.168.1.102	03
86	11	2007-03-21	2007-04-25	2007-04-25	17	192.168.1.102	03
98	15	2007-03-15	2007-04-16	2007-04-16	17	192.168.1.102	03
254	10	2006-07-26	2006-10-23	2006-10-23	17	192.168.1.102	03
258	13	2007-07-16	2007-10-15	2007-10-15	17	192.168.1.102	03
262	16	2007-07-25	2007-10-22	2007-10-22	17	192.168.1.102	03
266	19	2008-07-15	2008-10-15	2008-10-15	17	192.168.1.102	03
270	22	2008-07-21	2008-10-21	2008-10-21	17	192.168.1.102	03
274	25	2009-07-15	2009-10-15	2009-10-15	17	192.168.1.102	03
278	28	2009-07-21	2009-10-22	2009-10-22	17	192.168.1.102	03
353	50	2013-04-15	2013-05-15	2013-05-15	17	192.168.1.102	04
341	46	2013-04-22	2013-05-23	2013-05-23	17	192.168.1.102	04
365	48	2013-10-15	2014-01-15	2014-01-15	17	192.168.1.102	04
52	5	2006-04-26	2006-05-22	2006-05-22	17	192.168.1.102	04
75	9	2006-04-17	2006-05-15	2006-05-15	17	192.168.1.102	04
87	11	2007-04-25	2007-05-23	2007-05-23	17	192.168.1.102	04
99	15	2007-04-16	2007-05-15	2007-05-15	17	192.168.1.102	04
255	10	2006-10-23	2007-01-22	2007-01-22	17	192.168.1.102	04
259	13	2007-10-15	2008-01-15	2008-01-15	17	192.168.1.102	04
263	16	2007-10-22	2008-01-22	2008-01-22	17	192.168.1.102	04
267	19	2008-10-15	2009-01-15	2009-01-15	17	192.168.1.102	04
271	22	2008-10-21	2009-01-23	2009-01-23	17	192.168.1.102	04
275	25	2009-10-15	2010-01-15	2010-01-15	17	192.168.1.102	04
92	11	2007-09-21	2007-10-22	2007-10-22	17	192.168.1.102	09
104	15	2007-09-17	2007-10-15	2007-10-15	17	192.168.1.102	09
18	4	2012-10-22	2012-11-22	2012-11-22	17	192.168.1.102	10
19	4	2012-11-22	2012-12-21	2012-12-21	17	192.168.1.102	11
201	39	2011-10-15	2011-11-15	2011-11-15	17	192.168.1.102	10
202	39	2011-11-15	2011-12-15	2011-12-15	17	192.168.1.102	11
203	39	2011-12-15	2012-01-16	2012-01-16	17	192.168.1.102	12
117	17	2008-10-21	2008-11-21	2008-11-21	17	192.168.1.102	10
118	17	2008-11-21	2008-12-22	2008-12-22	17	192.168.1.102	11
119	17	2008-12-22	2009-01-22	2009-01-22	17	192.168.1.102	12
13	4	2012-05-23	2012-06-22	2012-06-22	17	192.168.1.102	05
112	17	2008-05-23	2008-06-20	2008-06-20	17	192.168.1.102	05
124	21	2008-05-15	2008-06-16	2008-06-16	17	192.168.1.102	05
136	23	2009-05-22	2009-06-22	2009-06-22	17	192.168.1.102	05
148	27	2009-05-15	2009-06-16	2009-06-16	17	192.168.1.102	05
160	29	2010-05-24	2010-06-22	2010-06-22	17	192.168.1.102	05
172	33	2010-05-18	2010-06-15	2010-06-15	17	192.168.1.102	05
14	4	2012-06-22	2012-07-25	2012-07-25	17	192.168.1.102	06
113	17	2008-06-20	2008-07-21	2008-07-21	17	192.168.1.102	06
125	21	2008-06-16	2008-07-15	2008-07-15	17	192.168.1.102	06
137	23	2009-06-22	2009-07-21	2009-07-21	17	192.168.1.102	06
149	27	2009-06-16	2009-07-15	2009-07-15	17	192.168.1.102	06
161	29	2010-06-22	2010-07-22	2010-07-22	17	192.168.1.102	06
129	21	2008-10-15	2008-11-17	2008-11-17	17	192.168.1.102	10
130	21	2008-11-17	2008-12-15	2008-12-15	17	192.168.1.102	11
131	21	2008-12-15	2009-01-15	2009-01-15	17	192.168.1.102	12
173	33	2010-06-15	2010-07-15	2010-07-15	17	192.168.1.102	06
141	23	2009-10-22	2009-11-20	2009-11-20	17	192.168.1.102	10
142	23	2009-11-20	2009-12-22	2009-12-22	17	192.168.1.102	11
143	23	2009-12-22	2010-01-25	2010-01-25	17	192.168.1.102	12
15	4	2012-07-25	2012-08-22	2012-08-22	17	192.168.1.102	07
114	17	2008-07-21	2008-08-22	2008-08-22	17	192.168.1.102	07
153	27	2009-10-15	2009-11-16	2009-11-16	17	192.168.1.102	10
154	27	2009-11-16	2009-12-15	2009-12-15	17	192.168.1.102	11
155	27	2009-12-15	2010-01-15	2010-01-15	17	192.168.1.102	12
126	21	2008-07-15	2008-08-15	2008-08-15	17	192.168.1.102	07
138	23	2009-07-21	2009-08-21	2009-08-21	17	192.168.1.102	07
165	29	2010-10-22	2010-11-22	2010-11-22	17	192.168.1.102	10
166	29	2010-11-22	2010-12-22	2010-12-22	17	192.168.1.102	11
167	29	2010-12-22	2011-01-25	2011-01-25	17	192.168.1.102	12
150	27	2009-07-15	2009-08-17	2009-08-17	17	192.168.1.102	07
162	29	2010-07-22	2010-08-20	2010-08-20	17	192.168.1.102	07
174	33	2010-07-15	2010-08-16	2010-08-16	17	192.168.1.102	07
281	31	2010-04-15	2010-07-15	2010-07-15	17	192.168.1.102	02
285	34	2010-04-26	2010-07-22	2010-07-22	17	192.168.1.102	02
289	37	2011-04-15	2011-07-15	2011-07-15	17	192.168.1.102	02
293	40	2011-04-26	2011-07-26	2011-07-26	17	192.168.1.102	02
297	42	2012-04-16	2012-07-16	2012-07-16	17	192.168.1.102	02
301	45	2012-04-25	2012-07-25	2012-07-25	17	192.168.1.102	02
10	4	2012-02-23	2012-03-22	2012-03-22	17	192.168.1.102	02
109	17	2008-02-25	2008-03-25	2008-03-25	17	192.168.1.102	02
121	21	2008-02-15	2008-03-17	2008-03-17	17	192.168.1.102	02
309	51	2013-04-22	2013-07-22	2013-07-22	17	192.168.1.102	02
249	7	2006-04-17	2006-07-17	2006-07-17	17	192.168.1.102	02
253	10	2006-04-26	2006-07-26	2006-07-26	17	192.168.1.102	02
282	31	2010-07-15	2010-10-15	2010-10-15	17	192.168.1.102	03
286	34	2010-07-22	2010-10-22	2010-10-22	17	192.168.1.102	03
290	37	2011-07-15	2011-10-17	2011-10-17	17	192.168.1.102	03
294	40	2011-07-26	2011-10-24	2011-10-24	17	192.168.1.102	03
298	42	2012-07-16	2012-10-15	2012-10-15	17	192.168.1.102	03
302	45	2012-07-25	2012-10-22	2012-10-22	17	192.168.1.102	03
11	4	2012-03-22	2012-04-25	2012-04-25	17	192.168.1.102	03
110	17	2008-03-25	2008-04-21	2008-04-21	17	192.168.1.102	03
122	21	2008-03-17	2008-04-15	2008-04-15	17	192.168.1.102	03
310	51	2013-07-22	2013-10-21	2013-10-21	17	192.168.1.102	03
250	7	2006-07-17	2006-10-16	2006-10-16	17	192.168.1.102	03
134	23	2009-03-23	2009-04-23	2009-04-23	17	192.168.1.102	03
146	27	2009-03-16	2009-04-15	2009-04-15	17	192.168.1.102	03
158	29	2010-03-22	2010-04-26	2010-04-26	17	192.168.1.102	03
279	28	2009-10-22	2010-01-25	2010-01-25	17	192.168.1.102	04
283	31	2010-10-15	2011-01-17	2011-01-17	17	192.168.1.102	04
287	34	2010-10-22	2011-01-24	2011-01-24	17	192.168.1.102	04
291	37	2011-10-17	2012-01-17	2012-01-17	17	192.168.1.102	04
295	40	2011-10-24	2012-01-24	2012-01-24	17	192.168.1.102	04
299	42	2012-10-15	2013-01-15	2013-01-22	17	192.168.1.102	04
303	45	2012-10-22	2013-01-23	2013-01-23	17	192.168.1.102	04
12	4	2012-04-25	2012-05-23	2012-05-23	17	192.168.1.102	04
111	17	2008-04-21	2008-05-23	2008-05-23	17	192.168.1.102	04
123	21	2008-04-15	2008-05-15	2008-05-15	17	192.168.1.102	04
311	51	2013-10-21	2014-01-22	2014-01-22	17	192.168.1.102	04
251	7	2006-10-16	2007-01-15	2007-01-15	17	192.168.1.102	04
135	23	2009-04-23	2009-05-22	2009-05-22	17	192.168.1.102	04
16	4	2012-08-22	2012-09-21	2012-09-21	17	192.168.1.102	08
199	39	2011-08-16	2011-09-15	2011-09-15	17	192.168.1.102	08
115	17	2008-08-22	2008-09-19	2008-09-19	17	192.168.1.102	08
127	21	2008-08-15	2008-09-15	2008-09-15	17	192.168.1.102	08
139	23	2009-08-21	2009-09-21	2009-09-21	17	192.168.1.102	08
151	27	2009-08-17	2009-09-15	2009-09-15	17	192.168.1.102	08
163	29	2010-08-20	2010-09-21	2010-09-21	17	192.168.1.102	08
175	33	2010-08-16	2010-09-15	2010-09-15	17	192.168.1.102	08
17	4	2012-09-21	2012-10-22	2012-10-22	17	192.168.1.102	09
200	39	2011-09-15	2011-10-15	2011-10-15	17	192.168.1.102	09
116	17	2008-09-19	2008-10-21	2008-10-21	17	192.168.1.102	09
128	21	2008-09-15	2008-10-15	2008-10-15	17	192.168.1.102	09
140	23	2009-09-21	2009-10-22	2009-10-22	17	192.168.1.102	09
152	27	2009-09-15	2009-10-15	2009-10-15	17	192.168.1.102	09
164	29	2010-09-21	2010-10-22	2010-10-22	17	192.168.1.102	09
176	33	2010-09-15	2010-10-15	2010-10-15	17	192.168.1.102	09
177	33	2010-10-15	2010-11-15	2010-11-15	17	192.168.1.102	10
178	33	2010-11-15	2010-12-15	2010-12-15	17	192.168.1.102	11
179	33	2010-12-15	2011-01-25	2011-01-25	17	192.168.1.102	12
189	35	2011-10-22	2011-11-22	2011-11-22	17	192.168.1.102	10
190	35	2011-11-22	2011-12-22	2011-12-22	17	192.168.1.102	11
191	35	2011-12-22	2012-01-23	2012-01-23	17	192.168.1.102	12
225	44	2012-10-15	2012-11-15	2012-11-15	17	192.168.1.102	10
226	44	2012-11-15	2012-12-17	2012-12-17	17	192.168.1.102	11
227	44	2012-12-17	2013-01-16	2013-01-16	17	192.168.1.102	12
183	35	2011-04-26	2011-05-24	2011-05-24	17	192.168.1.102	04
195	39	2011-04-15	2011-05-18	2011-05-18	17	192.168.1.102	04
350	50	2013-01-15	2013-02-25	2013-02-25	17	192.168.1.102	01
336	47	2013-02-14	2014-02-14	2014-02-14	17	192.168.1.102	01
337	49	2013-02-14	2014-02-14	2014-02-14	17	192.168.1.102	01
234	6	2006-02-14	2007-02-14	2007-02-14	17	192.168.1.102	01
235	8	2006-02-14	2007-02-14	2007-02-14	17	192.168.1.102	01
338	46	2013-01-22	2013-02-25	2013-02-25	17	192.168.1.102	01
362	48	2013-01-15	2013-04-15	2013-04-15	17	192.168.1.102	01
260	16	2007-01-22	2007-04-25	2007-04-25	17	192.168.1.102	01
264	19	2008-01-15	2008-04-15	2008-04-15	17	192.168.1.102	01
268	22	2008-01-22	2008-04-21	2008-04-21	17	192.168.1.102	01
272	25	2009-01-15	2009-04-15	2009-04-15	17	192.168.1.102	01
276	28	2009-01-23	2009-04-23	2009-04-23	17	192.168.1.102	01
280	31	2010-01-15	2010-04-15	2010-04-15	17	192.168.1.102	01
284	34	2010-01-25	2010-04-26	2010-04-26	17	192.168.1.102	01
288	37	2011-01-17	2011-04-15	2011-04-15	17	192.168.1.102	01
292	40	2011-01-24	2011-04-26	2011-04-26	17	192.168.1.102	01
296	42	2012-01-16	2012-04-16	2012-04-16	17	192.168.1.102	01
300	45	2012-01-23	2012-04-25	2012-04-25	17	192.168.1.102	01
108	17	2008-01-22	2008-02-25	2008-02-25	17	192.168.1.102	01
120	21	2008-01-15	2008-02-15	2008-02-15	17	192.168.1.102	01
308	51	2013-01-22	2013-04-22	2013-04-22	17	192.168.1.102	01
49	5	2006-01-23	2006-02-21	2006-02-21	17	192.168.1.102	01
72	9	2006-01-16	2006-02-15	2006-02-15	17	192.168.1.102	01
84	11	2007-01-22	2007-02-23	2007-02-23	17	192.168.1.102	01
96	15	2007-01-15	2007-02-15	2007-02-15	17	192.168.1.102	01
236	12	2007-02-14	2008-02-15	2008-02-15	17	192.168.1.102	01
256	13	2007-01-15	2007-04-16	2007-04-16	17	192.168.1.102	01
237	14	2007-02-14	2008-02-15	2008-02-15	17	192.168.1.102	01
238	18	2008-02-15	2009-02-16	2009-02-16	17	192.168.1.102	01
239	20	2008-02-15	2009-02-16	2009-02-16	17	192.168.1.102	01
240	24	2009-02-16	2010-02-17	2010-02-17	17	192.168.1.102	01
241	26	2009-02-16	2010-02-17	2010-02-17	17	192.168.1.102	01
242	30	2010-02-17	2011-02-14	2011-02-14	17	192.168.1.102	01
243	32	2010-02-17	2011-02-14	2011-02-14	17	192.168.1.102	01
244	36	2011-02-14	2012-02-14	2012-02-14	17	192.168.1.102	01
245	38	2011-02-14	2012-02-14	2012-02-14	17	192.168.1.102	01
247	43	2012-02-14	2013-02-14	2013-02-14	17	192.168.1.102	01
248	7	2006-01-16	2006-04-17	2006-04-17	17	192.168.1.102	01
252	10	2006-01-23	2006-04-26	2006-04-26	17	192.168.1.102	01
132	23	2009-01-23	2009-02-25	2009-02-25	17	192.168.1.102	01
144	27	2009-01-15	2009-02-16	2009-02-16	17	192.168.1.102	01
156	29	2010-01-25	2010-02-23	2010-02-23	17	192.168.1.102	01
168	33	2010-01-15	2010-02-17	2010-02-17	17	192.168.1.102	01
180	35	2011-01-25	2011-02-23	2011-02-23	17	192.168.1.102	01
192	39	2011-01-15	2011-02-17	2011-02-17	17	192.168.1.102	01
216	44	2012-01-16	2012-02-15	2012-02-15	17	192.168.1.102	01
9	4	2012-01-23	2012-02-23	2012-02-23	17	192.168.1.102	01
133	23	2009-02-25	2009-03-23	2009-03-23	17	192.168.1.102	02
145	27	2009-02-16	2009-03-16	2009-03-16	17	192.168.1.102	02
157	29	2010-02-23	2010-03-22	2010-03-22	17	192.168.1.102	02
169	33	2010-02-17	2010-03-15	2010-03-15	17	192.168.1.102	02
181	35	2011-02-23	2011-03-22	2011-03-22	17	192.168.1.102	02
193	39	2011-02-17	2011-03-15	2011-03-15	17	192.168.1.102	02
217	44	2012-02-15	2012-03-15	2012-03-15	17	192.168.1.102	02
170	33	2010-03-15	2010-04-15	2010-04-15	17	192.168.1.102	03
182	35	2011-03-22	2011-04-26	2011-04-26	17	192.168.1.102	03
194	39	2011-03-15	2011-04-15	2011-04-15	17	192.168.1.102	03
218	44	2012-03-15	2012-04-16	2012-04-16	17	192.168.1.102	03
147	27	2009-04-15	2009-05-15	2009-05-15	17	192.168.1.102	04
159	29	2010-04-26	2010-05-24	2010-05-24	17	192.168.1.102	04
171	33	2010-04-15	2010-05-18	2010-05-18	17	192.168.1.102	04
219	44	2012-04-16	2012-05-15	2012-05-15	17	192.168.1.102	04
184	35	2011-05-24	2011-06-22	2011-06-22	17	192.168.1.102	05
196	39	2011-05-18	2011-06-15	2011-06-15	17	192.168.1.102	05
220	44	2012-05-15	2012-06-15	2012-06-15	17	192.168.1.102	05
185	35	2011-06-22	2011-07-22	2011-07-22	17	192.168.1.102	06
197	39	2011-06-15	2011-07-15	2011-07-15	17	192.168.1.102	06
221	44	2012-06-15	2012-07-16	2012-07-16	17	192.168.1.102	06
186	35	2011-07-22	2011-08-20	2011-08-20	17	192.168.1.102	07
198	39	2011-07-15	2011-08-16	2011-08-16	17	192.168.1.102	07
222	44	2012-07-16	2012-08-15	2012-08-15	17	192.168.1.102	07
187	35	2011-08-20	2011-09-21	2011-09-21	17	192.168.1.102	08
223	44	2012-08-15	2012-09-17	2012-09-17	17	192.168.1.102	08
188	35	2011-09-21	2011-10-22	2011-10-22	17	192.168.1.102	09
224	44	2012-09-17	2012-10-15	2012-10-15	17	192.168.1.102	09
246	41	2012-02-14	2012-12-31	2013-02-14	17	192.168.1.102	01
\.


--
-- TOC entry 3193 (class 0 OID 128432)
-- Dependencies: 182 3321
-- Data for Name: cargos; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY cargos (id, nombre, usuarioid, ip, codigo_cargo) FROM stdin;
8	GERENTE	17	192.168.1.102	C-001
9	FISCAL	17	192.168.1.102	C-002
10	ASISTENTE LEGAL	17	192.168.1.102	C-003
11	RECAUDADOR	17	192.168.1.102	C-004
15	SECRETARIA	17	192.168.1.102	C-005
16	ASISTENTE	17	192.168.1.102	C-006
\.


--
-- TOC entry 3195 (class 0 OID 128440)
-- Dependencies: 184 3321
-- Data for Name: ciudades; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY ciudades (id, estadoid, nombre, usuarioid, ip) FROM stdin;
1	3	LIBERTADOR	16	192.168.1.102
2	4	ALTO ORINOCO	17	192.168.1.101
3	4	AUTONOMO ATABAPO	17	192.168.1.101
4	4	AUTONOMO ATURES	17	192.168.1.101
5	4	AUTONOMO AUTANA	17	192.168.1.101
6	4	AUTONOMO MAROA	17	192.168.1.101
7	4	AUTONOMO MANAPIARE	17	192.168.1.101
8	4	AUTONOMO RÍO NEGRO	17	192.168.1.101
9	4	MUNICIPIO DESCONOCIDO	17	192.168.1.101
10	5	ANACO	17	192.168.1.101
11	5	ARAGUA	17	192.168.1.101
12	5	FERNANDO DE PEÑALVER	17	192.168.1.101
13	5	FRANCISCO DEL CARMEN CARVAJAL	17	192.168.1.101
14	5	FRANCISCO DE MIRANDA	17	192.168.1.101
15	5	GUANTA	17	192.168.1.101
16	5	INDEPENDENCIA	17	192.168.1.101
17	5	JUAN ANTONIO SOTILLO	17	192.168.1.101
18	5	JUAN MANUEL CAJIGAL	17	192.168.1.101
19	5	JOSE GREGORIO MONAGAS	17	192.168.1.101
20	5	LIBERTAD	17	192.168.1.101
21	5	MANUEL EZEQUIEL BRUZUAL	17	192.168.1.101
22	5	PEDRO MARIA FREITES	17	192.168.1.101
23	5	PIRITU	17	192.168.1.101
24	5	SAN JOSÉ DE GUANIPA	17	192.168.1.101
25	5	SAN JUAN DE CAPISTRANO	17	192.168.1.101
26	5	SANTA ANA	17	192.168.1.101
27	5	SIMÓN BOLÍVAR	17	192.168.1.101
28	5	SIMÓN RODRIGUEZ	17	192.168.1.101
29	5	SIR ARTUR MC GREGOR	17	192.168.1.101
30	5	T D B URBANEJA	17	192.168.1.101
31	6	ACHAGUAS	17	192.168.1.101
32	6	BIRUACA	17	192.168.1.101
33	6	MUÑOZ	17	192.168.1.101
34	6	PÁEZ	17	192.168.1.101
35	6	PEDRO CAMEJO	17	192.168.1.101
36	6	ROMULO GALLEGOS	17	192.168.1.101
37	6	SAN FERNANDO	17	192.168.1.101
38	6	MUNICIPIO DESCONOCIDO	17	192.168.1.101
39	7	BOLÍVAR	17	192.168.1.101
40	7	CAMATAGUA	17	192.168.1.101
41	7	GIRARDOT	17	192.168.1.101
42	7	JOSÉ ANGEL LAMAS	17	192.168.1.101
43	7	JOSE FELIX RIBAS	17	192.168.1.101
44	7	JOSE RAFAEL REVENGA	17	192.168.1.101
45	7	LIBERTADOR	17	192.168.1.101
46	7	MARIO BRICEÑO IRAGORRY	17	192.168.1.101
47	7	SAN CASIMIRO	17	192.168.1.101
48	7	SAN SEBASTIAN	17	192.168.1.101
49	7	SANTIAGO MARIÑO	17	192.168.1.101
50	7	SANTOS MICHELENA	17	192.168.1.101
51	7	SUCRE	17	192.168.1.101
52	7	TOVAR	17	192.168.1.101
53	7	M. CAPITAL R. G. URDANETA	17	192.168.1.101
54	7	ZAMORA	17	192.168.1.101
55	7	FRANCISCO LINARES ALCANTARA	17	192.168.1.101
56	7	OCUMARE DE LA COSTA DE ORO	17	192.168.1.101
57	7	MUNICIPIO DESCONOCIDO	17	192.168.1.101
58	8	ALBERTO ARVELO TORREALBA	17	192.168.1.101
59	8	ANTONIO JOSE DE SUCRE	17	192.168.1.101
60	8	ARISMENDI	17	192.168.1.101
61	8	BARINAS	17	192.168.1.101
62	8	BOLÍVAR	17	192.168.1.101
63	8	CRUZ PAREDES	17	192.168.1.101
64	8	EZEQUIEL ZAMORA	17	192.168.1.101
65	8	OBISPOS	17	192.168.1.101
66	8	PEDRAZA	17	192.168.1.101
67	8	ROJAS	17	192.168.1.101
68	8	SOSA	17	192.168.1.101
69	8	ANDRÉS ELOY BLANCO	17	192.168.1.101
70	8	MUNICIPIO DESCONOCIDO	17	192.168.1.101
71	9	CARONI	17	192.168.1.101
72	9	CEDEÑO	17	192.168.1.101
73	9	EL CALLAO	17	192.168.1.101
74	9	GRAN SABANA	17	192.168.1.101
75	9	HERES	17	192.168.1.101
76	9	PIAR	17	192.168.1.101
77	9	RAUL LEONI	17	192.168.1.101
78	9	ROSCIO	17	192.168.1.101
79	9	SIFONTES	17	192.168.1.101
80	9	SUCRE	17	192.168.1.101
81	9	PADRE PEDRO CHIEN	17	192.168.1.101
82	9	MUNICIPIO DESCONOCIDO	17	192.168.1.101
83	9		17	192.168.1.101
84	10	BEJUMA	17	192.168.1.101
85	10	CARLOS ARVELO	17	192.168.1.101
86	10	DIEGO IBARRA	17	192.168.1.101
87	10	GUACARA	17	192.168.1.101
88	10	JUAN JOSE MORA	17	192.168.1.101
89	10	LIBERTADOR	17	192.168.1.101
90	10	LOS GUAYOS	17	192.168.1.101
91	10	MIRANDA	17	192.168.1.101
92	10	MONTALBAN	17	192.168.1.101
93	10	NAGUANAGUA	17	192.168.1.101
94	10	PUERTO CABELLO	17	192.168.1.101
95	10	SAN DIEGO	17	192.168.1.101
96	10	SAN JOAQUIN	17	192.168.1.101
97	10	VALENCIA	17	192.168.1.101
98	10	MUNICIPIO DESCONOCIDO	17	192.168.1.101
99	11	ANZOÁTEGUI	17	192.168.1.101
100	11	FALCON	17	192.168.1.101
101	11	GIRARDOT	17	192.168.1.101
102	11	LIMA BLANCO	17	192.168.1.101
103	11	PAO DE SAN JUAN BAUTISTA	17	192.168.1.101
104	11	RICAURTE	17	192.168.1.101
105	11	ROMULO GALLEGOS	17	192.168.1.101
106	11	SAN CARLOS	17	192.168.1.101
107	11	TINACO	17	192.168.1.101
108	11	MUNICIPIO DESCONOCIDO	17	192.168.1.101
109	12	ANTONIO DÍAZ	17	192.168.1.101
110	12	CASACOIMA	17	192.168.1.101
111	12	PEDERNALES	17	192.168.1.101
112	12	TUCUPITA	17	192.168.1.101
113	12	MUNICIPIO DESCONOCIDO	17	192.168.1.101
114	13	ACOSTA	17	192.168.1.101
115	13	BOLÍVAR	17	192.168.1.101
116	13	BUCHIVACOA	17	192.168.1.101
117	13	CACIQUE MANAURE	17	192.168.1.101
118	13	CARIRUBANA	17	192.168.1.101
119	13	COLINA	17	192.168.1.101
120	13	DABAJURO	17	192.168.1.101
121	13	DEMOCRACIA	17	192.168.1.101
122	13	FALCON	17	192.168.1.101
123	13	FEDERACION	17	192.168.1.101
124	13	JACURA	17	192.168.1.101
125	13	LOS TAQUES	17	192.168.1.101
126	13	MAUROA	17	192.168.1.101
127	13	MIRANDA	17	192.168.1.101
128	13	MONSEÑOR ITURRIZA	17	192.168.1.101
129	13	PALMASOLA	17	192.168.1.101
130	13	PETIT	17	192.168.1.101
131	13	PIRITU	17	192.168.1.101
132	13	SAN FRANCISCO	17	192.168.1.101
133	13	SILVA	17	192.168.1.101
134	13	SUCRE	17	192.168.1.101
135	13	TOCOPERO	17	192.168.1.101
136	13	UNION	17	192.168.1.101
137	13	URUMACO	17	192.168.1.101
138	13	ZAMORA	17	192.168.1.101
139	13	MUNICIPIO DESCONOCIDO	17	192.168.1.101
140	14	CAMAGUAN	17	192.168.1.101
141	14	CHAGUARAMAS	17	192.168.1.101
142	14	EL SOCORRO	17	192.168.1.101
143	14	SAN GERONIMO DE GUAYABAL	17	192.168.1.101
144	14	LEONARDO INFANTE	17	192.168.1.101
145	14	LAS MERCEDES	17	192.168.1.101
146	14	JULIAN MELLADO	17	192.168.1.101
147	14	FRANCISCO DE MIRANDA	17	192.168.1.101
148	14	JOSE TADEO MONAGAS	17	192.168.1.101
149	14	ORTIZ	17	192.168.1.101
150	14	JOSE FELIX RIBAS	17	192.168.1.101
151	14	JUAN GERMAN ROSCIO	17	192.168.1.101
152	14	SAN JOSE DE GUARIBE	17	192.168.1.101
153	14	SANTA MARIA DE IPIRE	17	192.168.1.101
154	14	PEDRO ZARAZA	17	192.168.1.101
155	14	MUNICIPIO DESCONOCIDO	17	192.168.1.101
156	15	ANDRÉS ELOY BLANCO	17	192.168.1.101
157	15	CRESPO	17	192.168.1.101
158	15	IRIBARREN	17	192.168.1.101
159	15	JIMENEZ	17	192.168.1.101
160	15	MORAN	17	192.168.1.101
161	15	PALAVECINO	17	192.168.1.101
162	15	SIMÓN PLANAS	17	192.168.1.101
163	15	TORRES	17	192.168.1.101
164	15	URDANETA	17	192.168.1.101
165	15	MUNICIPIO DESCONOCIDO	17	192.168.1.101
181	16	JULIO CESAR SALAS	17	192.168.1.103
182	16	JUSTO BRICEÑO	17	192.168.1.103
183	16	LIBERTADOR	17	192.168.1.103
184	16	MIRANDA	17	192.168.1.103
185	16	OBISPO RAMOS DE LORA	17	192.168.1.103
186	16	PADRE NOGUERA	17	192.168.1.103
187	16	PUEBLO LLANO	17	192.168.1.103
188	16	RANGEL	17	192.168.1.103
189	16	RIVAS DAVILA	17	192.168.1.103
190	16	SANTOS MARQUINA	17	192.168.1.103
191	16	SUCRE	17	192.168.1.103
192	16	TOVAR	17	192.168.1.103
193	16	TULIO FEBRES CORDERO	17	192.168.1.103
194	16	ZEA	17	192.168.1.103
195	16	MUNICIPIO DESCONOCIDO	17	192.168.1.103
196	17	ACEVEDO	17	192.168.1.103
197	17	ANDRÉS BELLO	17	192.168.1.103
198	17	BARUTA	17	192.168.1.103
199	17	BRION	17	192.168.1.103
200	17	BUROZ	17	192.168.1.103
201	17	CARRIZAL	17	192.168.1.103
202	17	CHACAO	17	192.168.1.103
203	17	CRISTOBAL ROJAS	17	192.168.1.103
204	17	EL HATILLO	17	192.168.1.103
205	17	GUAICAIPURO	17	192.168.1.103
206	17	INDEPENDENCIA	17	192.168.1.103
207	17	LANDER	17	192.168.1.103
208	17	LOS SALIAS	17	192.168.1.103
209	17	PÁEZ	17	192.168.1.103
210	17	PAZ CASTILLO	17	192.168.1.103
211	17	PEDRO GUAL	17	192.168.1.103
212	17	PLAZA	17	192.168.1.103
213	17	SIMÓN BOLÍVAR	17	192.168.1.103
214	17	SUCRE	17	192.168.1.103
215	17	URDANETA	17	192.168.1.103
216	17	ZAMORA	17	192.168.1.103
217	17	MUNICIPIO DESCONOCIDO	17	192.168.1.103
218	18	ACOSTA	17	192.168.1.103
219	18	AGUASAY	17	192.168.1.103
220	18	BOLÍVAR	17	192.168.1.103
221	18	CARIPE	17	192.168.1.103
222	18	CEDEÑO	17	192.168.1.103
223	18	EZEQUIEL ZAMORA	17	192.168.1.103
224	18	LIBERTADOR	17	192.168.1.103
225	18	MATURÍN	17	192.168.1.103
226	18	PIAR	17	192.168.1.103
227	18	PUNCERES	17	192.168.1.103
228	18	SANTA BÁRBARA	17	192.168.1.103
229	18	SOTILLO	17	192.168.1.103
230	18	URACOA	17	192.168.1.103
231	18	MUNICIPIO DESCONOCIDO	17	192.168.1.103
232	19	ANTOLIN DEL CAMPO	17	192.168.1.103
233	19	ARISMENDI	17	192.168.1.103
234	19	DÍAZ	17	192.168.1.103
235	19	GARCÍA	17	192.168.1.103
236	19	GÓMEZ	17	192.168.1.103
237	19	MANEIRO	17	192.168.1.103
238	19	MARCANO	17	192.168.1.103
239	19	MARIÑO	17	192.168.1.103
240	19	PENINSULA DE MACANAO	17	192.168.1.103
241	19	TUBORES	17	192.168.1.103
242	19	VILLALBA	17	192.168.1.103
243	19	MUNICIPIO DESCONOCIDO	17	192.168.1.103
244	20	AGUA BLANCA	17	192.168.1.103
245	20	ARAURE	17	192.168.1.103
246	20	ESTELLER	17	192.168.1.103
247	20	GUANARE	17	192.168.1.103
248	20	GUANARITO	17	192.168.1.103
249	20	MONSEÑOR JOSE VICENTE DE UNDA	17	192.168.1.103
250	20	OSPINO	17	192.168.1.103
251	20	PÁEZ	17	192.168.1.103
252	20	PAPELON	17	192.168.1.103
253	20	SAN GENARO DE BOCONOITO	17	192.168.1.103
254	20	SAN RAFAEL DE ONOTO	17	192.168.1.103
255	20	SANTA ROSALIA	17	192.168.1.103
256	20	SUCRE	17	192.168.1.103
257	20	TUREN	17	192.168.1.103
258	20	MUNICIPIO DESCONOCIDO	17	192.168.1.103
259	21	ANDRÉS ELOY BLANCO	17	192.168.1.103
260	21	ANDRÉS MATA	17	192.168.1.103
261	21	ARISMENDI	17	192.168.1.103
262	21	BENITEZ	17	192.168.1.103
263	21	BERMUDEZ	17	192.168.1.103
264	21	BOLÍVAR	17	192.168.1.103
265	21	CAJIGAL	17	192.168.1.103
266	21	CRUZ SALMERON ACOSTA	17	192.168.1.103
267	21	LIBERTADOR	17	192.168.1.103
268	21	MARIÑO	17	192.168.1.103
269	21	MEJIA	17	192.168.1.103
270	21	MONTES	17	192.168.1.103
271	21	RIBERO	17	192.168.1.103
272	21	SUCRE	17	192.168.1.103
273	21	VALDEZ	17	192.168.1.103
274	22	ANDRÉS BELLO	17	192.168.1.103
275	22	ANTONIO ROMULO COSTA	17	192.168.1.103
276	22	AYACUCHO	17	192.168.1.103
277	22	BOLÍVAR	17	192.168.1.103
278	22	CARDENAS	17	192.168.1.103
279	22	CORDOBA	17	192.168.1.103
280	22	FERNANDEZ FEO	17	192.168.1.103
281	22	FRANCISCO DE MIRANDA	17	192.168.1.103
282	22	GARCÍA DE HEVIA	17	192.168.1.103
283	22	GUASIMOS	17	192.168.1.103
284	22	INDEPENDENCIA	17	192.168.1.103
285	22	JAUREGUI	17	192.168.1.103
286	22	JOSE MARIA VARGAS	17	192.168.1.103
287	22	JUNIN	17	192.168.1.103
288	22	LIBERTAD	17	192.168.1.103
289	22	LIBERTADOR	17	192.168.1.103
290	22	LOBATERA	17	192.168.1.103
291	22	MICHELENA	17	192.168.1.103
292	22	PANAMERICANO	17	192.168.1.103
293	22	PEDRO MARIA UREÑA	17	192.168.1.103
294	22	RAFAEL URDANETA	17	192.168.1.103
295	22	SAMUEL DARIO MALDONADO	17	192.168.1.103
296	22	SAN CRISTOBAL	17	192.168.1.103
297	22	SEBORUCO	17	192.168.1.103
298	22	SIMÓN RODRÍGUEZ	17	192.168.1.103
299	22	SUCRE	17	192.168.1.103
300	22	TORBES	17	192.168.1.103
301	22	URIBANTE	17	192.168.1.103
302	22	MUNICIPO SAN JUDAS TADEO	17	192.168.1.103
303	23	ANDRÉS BELLO	17	192.168.1.103
304	23	BOCONÓ	17	192.168.1.103
305	23	BOLÍVAR	17	192.168.1.103
306	23	CANDELARIA	17	192.168.1.103
307	23	CARACHE	17	192.168.1.103
308	23	ESCUQUE	17	192.168.1.103
309	23	JOSE FELIPE MARQUEZ CAÑIZALES	17	192.168.1.103
310	23	JUAN VICENTE CAMPO ELIAS	17	192.168.1.103
311	23	LA CEIBA	17	192.168.1.103
312	23	MIRANDA	17	192.168.1.103
313	23	MONTE CARMELO	17	192.168.1.103
314	23	MOTATAN	17	192.168.1.103
315	23	PAMPAN	17	192.168.1.103
316	23	PAMPANITO	17	192.168.1.103
317	23	RAFAEL RANGEL	17	192.168.1.103
318	23	SAN RAFAEL DE CARVAJAL	17	192.168.1.103
319	23	SUCRE	17	192.168.1.103
320	23	TRUJILLO	17	192.168.1.103
321	23	URDANETA	17	192.168.1.103
322	23	VALERA	17	192.168.1.103
323	24	ARISTIDES BASTIDAS	17	192.168.1.103
324	24	BOLÍVAR	17	192.168.1.103
325	24	BRUZUAL	17	192.168.1.103
326	24	COCOROTE	17	192.168.1.103
327	24	INDEPENDENCIA	17	192.168.1.103
328	24	JOSÉ ANTONIO PÁEZ	17	192.168.1.103
329	24	LA TRINIDAD	17	192.168.1.103
330	24	MANUEL MONGE	17	192.168.1.103
331	24	NIRGUA	17	192.168.1.103
332	24	PEÑA	17	192.168.1.103
333	24	SAN FELIPE	17	192.168.1.103
334	24	SUCRE	17	192.168.1.103
335	24	URACHICHE	17	192.168.1.103
336	24	VEROES	17	192.168.1.103
337	25	ALMIRANTE PADILLA	17	192.168.1.103
338	25	BARALT	17	192.168.1.103
339	25	CABIMAS	17	192.168.1.103
340	25	CATATUMBO	17	192.168.1.103
341	25	COLÓN	17	192.168.1.103
342	25	FRANCISCO JAVIER PULGAR	17	192.168.1.103
343	25	JESÚS ENRIQUE LOSSADA	17	192.168.1.103
344	25	JESÚS MARIA SEMPRUN	17	192.168.1.103
345	25	LA CAÑADA DE URDANETA	17	192.168.1.103
346	25	LAGUNILLAS	17	192.168.1.103
347	25	MACHIQUES DE PERIJA	17	192.168.1.103
348	25	MARA	17	192.168.1.103
349	25	CARACCIOLO PARRA PÉREZ	17	192.168.1.103
350	25	MIRANDA	17	192.168.1.103
351	25	PÁEZ	17	192.168.1.103
352	25	ROSARIO DE PERIJA	17	192.168.1.103
353	25	SAN FRANCISCO	17	192.168.1.103
354	25	SANTA RITA	17	192.168.1.103
355	25	SIMÓN BOLÍVAR	17	192.168.1.103
356	25	SUCRE	17	192.168.1.103
357	25	VALMORE RODRIGUEZ	17	192.168.1.103
358	25	MARACAIBO	17	192.168.1.103
359	26	VARGAS	17	192.168.1.103
360	27	DEPENDENCIAS FEDERALES	17	192.168.1.103
\.


--
-- TOC entry 3247 (class 0 OID 128655)
-- Dependencies: 236 3321
-- Data for Name: con_img_doc; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY con_img_doc (id, conusuid, descripcion, usuarioid, ip, ruta_imagen, fecha) FROM stdin;
107	1	hkhlkh	1	127.0.0.1	b1f3860cd72063510459a24447ca14be.png	2013-07-13
108	145	jhghjhghg	145	127.0.0.1	53d04fb0245334933b9dcc110a2bdd20.jpg	2013-07-24
109	146	registro	146	127.0.0.1	091b20b501139572014fa0bb33acd036.png	2013-09-26
110	147	cedula	147	127.0.0.1	82eddc980ee5f062b4ac498d3a17aa2f.png	2013-09-27
111	148	pagina uno	148	127.0.0.1	60eac20baf6cbe0841654730c607ba1a.png	2013-11-08
112	153	regitro mercantil	153	127.0.0.1	a4d9b5efd0750b5d747cf9abbd895220.jpg	2013-11-13
\.


--
-- TOC entry 3961 (class 0 OID 0)
-- Dependencies: 237
-- Name: con_img_doc_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('con_img_doc_id_seq', 112, true);


--
-- TOC entry 3249 (class 0 OID 128664)
-- Dependencies: 238 3321
-- Data for Name: contrib_calc; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY contrib_calc (id, conusuid, usuarioid, ip, tipocontid, fecha_registro_fila, fecha_notificacion, proceso) FROM stdin;
155	146	48	127.0.0.1	1	2013-11-12 11:33:38.703794	\N	calculado
156	146	48	127.0.0.1	1	2013-11-13 09:17:52.261633	\N	calculado
157	146	48	127.0.0.1	6	2013-11-13 10:10:31.583306	\N	calculado
158	146	48	127.0.0.1	1	2013-11-13 10:15:37.571854	\N	calculado
160	146	48	127.0.0.1	6	2013-11-13 14:42:18.137947	\N	calculado
159	146	48	127.0.0.1	3	2013-11-13 14:42:18.137947	\N	calculado
161	146	48	127.0.0.1	3	2013-11-15 10:34:12.638543	\N	calculado
\.


--
-- TOC entry 3962 (class 0 OID 0)
-- Dependencies: 239
-- Name: contrib_calc_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('contrib_calc_id_seq', 161, true);


--
-- TOC entry 3205 (class 0 OID 128480)
-- Dependencies: 194 3321
-- Data for Name: contribu; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY contribu (id, razonsocia, dencomerci, actieconid, rif, numregcine, domfiscal, estadoid, ciudadid, zonapostal, telef1, telef2, telef3, fax1, fax2, email, pinbb, skype, twitter, facebook, nuacciones, valaccion, capitalsus, capitalpag, regmerofc, rmnumero, rmfolio, rmtomo, rmfechapro, rmncontrol, rmobjeto, domcomer, cextra1, cextra2, cextra3, cextra4, cextra5, usuarioid, ip) FROM stdin;
44	GRUPO INFOGUIANET,C.A (GRUPO INFOGUIANET C.A.)	GRUPO INFOGUIANET,C.A	4	J308058238	111111	AV. FRANCISCO DE MIRANDA SECTOR CHACAITO	3	1	0202	0212-0000000					jetox21@gmail.com					1000	500000.00	25000000.00	25000000.00	registro principal	2	20	5	2013-09-09	25	venta de señal satelital	AV.  LOS PALOS GRANDES CARACAS	\N	\N	\N	\N	\N	147	127.0.0.1
30	JEISY COROMOTO PALACIOS MATOS	RTERWTWER	5	V181643907	234156	sector el codo kilometro 31 de la panamericana	4	4	2020	0412-2504898					jeto_21@hotmail.com					10000	5000000.00	2500000.00	250000.00	kjcghvsdkhvks	0666	656	6	2013-09-09	2341	jkhgjkdfhlkgsdf	DFGDFSGDFGDFGDFGDSF	\N	\N	\N	\N	\N	146	127.0.0.1
29	JEFFERSON ARTURO LARA MOLINA	DFGDFGDS	6	V170429792	6466	sector el codo kilometro 31 de la panamericana	7	44	0165	0412-0428211					jetox21@gmail.com					1000	1000.00	25000.00	25000.00	jkgbjkhjhk	25	25	25	2013-09-09	25	hkjgjgkjgkjg	JGHKJGKGKGJJKG	\N	\N	\N	\N	\N	145	127.0.0.1
45	ORGANIZACIÓN VIEWMED, C.A. (ORGANIZACIÓN VIEWMED C.A.)	 VIEWMED	16	J306982434	0	AV FRANCISCO DE MIRANDA CHACAITO	3	1	2020	0412-0428211	0412-0428211				jetox21@gmail.com					1000	5000000.00	1000000.00	10000000.00	registo principal de los teques	516	564	4	2013-10-08	5	cine y venta de pleiculas	AV FRANCISCO DE MIRANDA CHACAITO	\N	\N	\N	\N	\N	148	127.0.0.1
47	MERCADOLIBRE VENEZUELA, S.R.L (MERCADOLIBRE VENEZUELA, S.R.L. )	MERCADOLIBRE	16	J306842675	1	AV ACOSTA CARLES LOCAL 35-B SAN JUAN DE LOS MORROS	14	151	1212	0246-4312403	0246-4310201		0042-6431020		jetox21@gmail.com					100	5000000.00	1500000.00	1500000.00	registro mercantil primero	856	8	25	2012-03-14	6	ventas y alquileres de peliculas	AV ACOSTA CARLES LOCAL 35-B SAN JUAN DE LOS MORROS	\N	\N	\N	\N	\N	153	127.0.0.1
\.


--
-- TOC entry 3251 (class 0 OID 128673)
-- Dependencies: 240 3321
-- Data for Name: contributi; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY contributi (id, contribuid, tipocontid, ip) FROM stdin;
\.


--
-- TOC entry 3963 (class 0 OID 0)
-- Dependencies: 241
-- Name: contributi_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('contributi_id_seq', 1, false);


--
-- TOC entry 3203 (class 0 OID 128468)
-- Dependencies: 192 3321
-- Data for Name: conusu; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY conusu (id, login, password, nombre, inactivo, conusutiid, email, pregsecrid, respuesta, ultlogin, usuarioid, ip, rif, validado, fecha_registro, correo_enviado) FROM stdin;
3	J085059920	7c4a8d09ca3762af61e59520943dc26494f8941b	Administradora de Cines Acarigua, C.A.	f	1	cines@cinesacarigua.com	2	MI MAMA	\N	\N	192,168,1,101	J085059920	t	2013-03-14	f
4	J308336980	7c4a8d09ca3762af61e59520943dc26494f8941b	Agropecuaria J.R.L. Cine Carvajal	f	1	juanleal70@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J308336980	t	2013-03-14	f
5	J001450181	7c4a8d09ca3762af61e59520943dc26494f8941b	A.C. Ateneo de Caracas	f	1	diradmon@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J001450181	t	2013-03-14	f
6	V053442486	7c4a8d09ca3762af61e59520943dc26494f8941b	Cine Center La Grita	f	1	oscarlubo@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	V053442486	t	2013-03-14	f
7	V118783634	7c4a8d09ca3762af61e59520943dc26494f8941b	Sala de Cine Charles Chaplin Oropeza	f	1	yv3-fdr@latinmail.com	2	MI MAMA	\N	\N	192,168,1,101	V118783634	t	2013-03-14	f
8	J301447018	7c4a8d09ca3762af61e59520943dc26494f8941b	A.C. Cine Club Zona Colonial de Petare	f	1	cineclub@hotmail.com virginia_rojas@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J301447018	t	2013-03-14	f
9	J311140492	7c4a8d09ca3762af61e59520943dc26494f8941b	Cines Magia C.A.	f	1	cinesmagia6@latinmail.com	2	MI MAMA	\N	\N	192,168,1,101	J311140492	t	2013-03-14	f
10	J311591478	7c4a8d09ca3762af61e59520943dc26494f8941b	Cine Oasis, C.A.	f	1	grupo2810@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J311591478	t	2013-03-14	f
11	J000915644	7c4a8d09ca3762af61e59520943dc26494f8941b	Cine Plaza Las Américas, C.A.	f	1	msaleta@blancica.com.ve	2	MI MAMA	\N	\N	192,168,1,101	J000915644	t	2013-03-14	f
12	J310160376	7c4a8d09ca3762af61e59520943dc26494f8941b	Cinematográfica Las Terrazas, C.A. (antiguamente Roraimex)	f	1	cinescca@gmail.com	2	MI MAMA	\N	\N	192,168,1,101	J310160376	t	2013-03-14	f
13	J308702528	7c4a8d09ca3762af61e59520943dc26494f8941b	Cumboto Cinema 3, S.R.L.	f	1	juancarloa@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J308702528	t	2013-03-14	f
14	J307124695	7c4a8d09ca3762af61e59520943dc26494f8941b	Exhibidor de Películas La Cascada C.A.	f	1	pablov@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J307124695	t	2013-03-14	f
15	J304483198	7c4a8d09ca3762af61e59520943dc26494f8941b	Exhibidor de Películas La Casona C.A.	f	1	moviecascada@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J304483198	t	2013-03-14	f
16	J300846199	7c4a8d09ca3762af61e59520943dc26494f8941b	Fremel Cine Los Salias, C.A.	f	1	defreitascj@gmail.com	2	MI MAMA	\N	\N	192,168,1,101	J300846199	t	2013-03-14	f
17	J075877608	7c4a8d09ca3762af61e59520943dc26494f8941b	Fundacine Universidad de Carabobo	f	1	www.fundacine@uc.edu.ve	2	MI MAMA	\N	\N	192,168,1,101	J075877608	t	2013-03-14	f
18	J304603665	7c4a8d09ca3762af61e59520943dc26494f8941b	Fundación Teatro Baralt (FUNDABARALT)	f	1	teatrobaralt@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J304603665	t	2013-03-14	f
19	J003615935	7c4a8d09ca3762af61e59520943dc26494f8941b	Fundación La Previsora	f	1	fundaciónprevisora@gmail.com	2	MI MAMA	\N	\N	192,168,1,101	J003615935	t	2013-03-14	f
20	J303881130	7c4a8d09ca3762af61e59520943dc26494f8941b	Asociación Nacional de Salas de Arte Cinematográfica Circuito Gran Cine	f	1	circuitograncine@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J303881130	t	2013-03-14	f
21	J300443230	7c4a8d09ca3762af61e59520943dc26494f8941b	Inversiones Cines Principal, C.A.	f	1	mafercine@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J300443230	t	2013-03-14	f
22	J302174210	7c4a8d09ca3762af61e59520943dc26494f8941b	Inversiones Diversas Nº 37 C.A.                 (Cine Continental)	f	1	venefilm@telcel.net.ve	2	MI MAMA	\N	\N	192,168,1,101	J302174210	t	2013-03-14	f
23	J305874964	7c4a8d09ca3762af61e59520943dc26494f8941b	Inversiones Jumbo Plex C.A.	f	1	msaleta@blancica.com.ve	2	MI MAMA	\N	\N	192,168,1,101	J305874964	t	2013-03-14	f
24	J308926434	7c4a8d09ca3762af61e59520943dc26494f8941b	Inversiones Maydard, C.A.	f	1	ltorres@cinex.com.ve	2	MI MAMA	\N	\N	192,168,1,101	J308926434	t	2013-03-14	f
25	J303031526	7c4a8d09ca3762af61e59520943dc26494f8941b	Inversiones Plaza Mayor 2019, C.A.	f	1	venefilm@telcel.net.ve	2	MI MAMA	\N	\N	192,168,1,101	J303031526	t	2013-03-14	f
26	J302626471	7c4a8d09ca3762af61e59520943dc26494f8941b	Multicine Las Trinitarias C.A.	f	1	ttoth@cinesunidos.com	2	MI MAMA	\N	\N	192,168,1,101	J302626471	t	2013-03-14	f
27	J304066120	7c4a8d09ca3762af61e59520943dc26494f8941b	Multicine Las Virtudes, C.A.	f	1	venefilm@telcel.net.ve	2	MI MAMA	\N	\N	192,168,1,101	J304066120	t	2013-03-14	f
28	J3057185279	7c4a8d09ca3762af61e59520943dc26494f8941b	Multicine Plaza Alto Prado, C.A.	f	1	venefilm@telcel.net.ve	2	MI MAMA	\N	\N	192,168,1,101	J3057185279	t	2013-03-14	f
29	J308213373	7c4a8d09ca3762af61e59520943dc26494f8941b	Multicine Valera Plaza, C.A.	f	1	venefilm@telcel.net.ve	2	MI MAMA	\N	\N	192,168,1,101	J308213373	t	2013-03-14	f
30	J001324178	7c4a8d09ca3762af61e59520943dc26494f8941b	Multicinema El Viaducto	f	1	venefilm@telcel.net.ve	2	MI MAMA	\N	\N	192,168,1,101	J001324178	t	2013-03-14	f
31	J001054243	7c4a8d09ca3762af61e59520943dc26494f8941b	Multicinema Tamanaco, C.A.	f	1	msaleta@blancica.com.ve	2	MI MAMA	\N	\N	192,168,1,101	J001054243	t	2013-03-14	f
32	J304741510	7c4a8d09ca3762af61e59520943dc26494f8941b	Multicines El Valle	f	1	ssharam@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J304741510	t	2013-03-14	f
33	J308213411	7c4a8d09ca3762af61e59520943dc26494f8941b	Multicines Marina Plaza, C.A.	f	1	venefilm@telcel.net.ve	2	MI MAMA	\N	\N	192,168,1,101	J308213411	t	2013-03-14	f
34	J305308551	7c4a8d09ca3762af61e59520943dc26494f8941b	Multicines Monagas Plaza, C.A.	f	1	Miranda	2	MI MAMA	\N	\N	192,168,1,101	J305308551	t	2013-03-14	f
35	J304857527	7c4a8d09ca3762af61e59520943dc26494f8941b	Multicine Doral Plaza Center, C.A.	f	1	venefilm@telcel.net.ve	2	MI MAMA	\N	\N	192,168,1,101	J304857527	t	2013-03-14	f
36	J312496126	7c4a8d09ca3762af61e59520943dc26494f8941b	A.C. Cine Club Charles Chaplin	f	1	juanl3@hotmail.com / cinechaplin@gmail.com	2	MI MAMA	\N	\N	192,168,1,101	J312496126	t	2013-03-14	f
37	J000458324	7c4a8d09ca3762af61e59520943dc26494f8941b	Sur Americana de Espectáculos	f	1	cinex@com.ve	2	MI MAMA	\N	\N	192,168,1,101	J000458324	t	2013-03-14	f
38	J300492621	7c4a8d09ca3762af61e59520943dc26494f8941b	Teatro Olímpico	f	1	teatro-olimpico@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J300492621	t	2013-03-14	f
39	J001011579	7c4a8d09ca3762af61e59520943dc26494f8941b	Teatro Rossini, S.R.L.	f	1	venefilm@telcel.net.ve	2	MI MAMA	\N	\N	192,168,1,101	J001011579	t	2013-03-14	f
40	J001035508	7c4a8d09ca3762af61e59520943dc26494f8941b	Teatros de Portuguesa, S.R.L.    (Multicines Pirineos)	f	1	venefilm@telcel.net.ve	2	MI MAMA	\N	\N	192,168,1,101	J001035508	t	2013-03-14	f
42	J310483990	7c4a8d09ca3762af61e59520943dc26494f8941b	Cinex Tolón C.A.	f	1	msaleta@blancica.com.ve	2	MI MAMA	\N	\N	192,168,1,101	J310483990	t	2013-03-14	f
43	J313701394	7c4a8d09ca3762af61e59520943dc26494f8941b	Administradora Darmay	f	1	ltorres@cinex.com.ve	2	MI MAMA	\N	\N	192,168,1,101	J313701394	t	2013-03-14	f
86	J301866525	7c4a8d09ca3762af61e59520943dc26494f8941b	Canal Plus, C.A.	f	1	canalplus.bejuma@gmail.com	2	MI MAMA	\N	\N	192,168,1,101	J301866525	t	2013-03-14	f
44	G200054620	7c4a8d09ca3762af61e59520943dc26494f8941b	Fundación Cinemateca Nacional	f	1	programacion@cinemateca.gob.ve	2	MI MAMA	\N	\N	192,168,1,101	G200054620	t	2013-03-14	f
45	J310535590	7c4a8d09ca3762af61e59520943dc26494f8941b	A.C. Cinedigital	f	1	cinedigital2000@yahoo.es	2	MI MAMA	\N	\N	192,168,1,101	J310535590	t	2013-03-14	f
46	J305634947	7c4a8d09ca3762af61e59520943dc26494f8941b	Inversora 12230, C.A.	f	1	msaleta@blancica.com.ve	2	MI MAMA	\N	\N	192,168,1,101	J305634947	t	2013-03-14	f
47	J308926035	7c4a8d09ca3762af61e59520943dc26494f8941b	Cine La Cascada C.A.	f	1	moviecascada@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J308926035	t	2013-03-14	f
48	J308490865	7c4a8d09ca3762af61e59520943dc26494f8941b	Fundación Trasnocho Cultural - Cines Paseo 1, 2 y Plus	f	1	coordinación@trasnochocultural.com	2	MI MAMA	\N	\N	192,168,1,101	J308490865	t	2013-03-14	f
49	J314807722	7c4a8d09ca3762af61e59520943dc26494f8941b	Multicine Galerías 2020, C.A.	f	1	jparra@cinex2.com.ve	2	MI MAMA	\N	\N	192,168,1,101	J314807722	t	2013-03-14	f
50	J314177869	7c4a8d09ca3762af61e59520943dc26494f8941b	Exhibiciones Fílmicas, C.A.	f	1	maruciaca@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J314177869	t	2013-03-14	f
51	J294049206	7c4a8d09ca3762af61e59520943dc26494f8941b	Multicine Santa Barbara	f	1	argenisulbaran520@hotail.com	2	MI MAMA	\N	\N	192,168,1,101	J294049206	t	2013-03-14	f
52	J316200035	7c4a8d09ca3762af61e59520943dc26494f8941b	Cines Atlántico R.P., C.A.	f	1	pablov@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J316200035	t	2013-03-14	f
53	J294736343	7c4a8d09ca3762af61e59520943dc26494f8941b	Cines Center, C.A.	f	1	cinescenter@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J294736343	t	2013-03-14	f
54	J000126518	7c4a8d09ca3762af61e59520943dc26494f8941b	C.A. Empresas Cines Unidos	f	1	 sullivi@cinesunidos.com	2	MI MAMA	\N	\N	192,168,1,101	J000126518	t	2013-03-14	f
55	J294910661	7c4a8d09ca3762af61e59520943dc26494f8941b	Operadora Cinecity la Victoria, C.A.	f	1	cinecitylavictoria@gmail.com	2	MI MAMA	\N	\N	192,168,1,101	J294910661	t	2013-03-14	f
56	J295750790	7c4a8d09ca3762af61e59520943dc26494f8941b	Multicines San Remo, C.A.	f	1	rennyvieira@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J295750790	t	2013-03-14	f
57	J314807803	7c4a8d09ca3762af61e59520943dc26494f8941b	Multicines Cimaplaza, C.A.	f	1	jparra@cinex.com.ve	2	MI MAMA	\N	\N	192,168,1,101	J314807803	t	2013-03-14	f
58	J297680306	7c4a8d09ca3762af61e59520943dc26494f8941b	Cinemall, C.A.	f	1	anamfernandez3@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J297680306	t	2013-03-14	f
59	J298525070	7c4a8d09ca3762af61e59520943dc26494f8941b	Casona Multiplex, C.A.	f	1	cinemovieplanet@gmail.com	2	MI MAMA	\N	\N	192,168,1,101	J298525070	t	2013-03-14	f
60	J307894466	7c4a8d09ca3762af61e59520943dc26494f8941b	Supercine Puente Real, C.A.	f	1	rennyvieira@gmail.com	2	MI MAMA	\N	\N	192,168,1,101	J307894466	t	2013-03-14	f
61	J293588618	7c4a8d09ca3762af61e59520943dc26494f8941b	Cines Anaco Center, C.A.	f	1	minigonzalez@msn.com	2	MI MAMA	\N	\N	192,168,1,101	J293588618	t	2013-03-14	f
62	J003697362	7c4a8d09ca3762af61e59520943dc26494f8941b	Continental TV, C.A.   (MERIDIANO TV)	f	1	meridianotv@dearmas.com	2	MI MAMA	\N	\N	192,168,1,101	J003697362	t	2013-03-14	f
63	J301743024	7c4a8d09ca3762af61e59520943dc26494f8941b	GLOBOVISIÓN TELE C.A.	f	1	info@globovision.com	2	MI MAMA	\N	\N	192,168,1,101	J301743024	t	2013-03-14	f
64	J000305617	7c4a8d09ca3762af61e59520943dc26494f8941b	RCTV C.A.	f	1	IMORILLO@ RCTV.NET	2	MI MAMA	\N	\N	192,168,1,101	J000305617	t	2013-03-14	f
65	J000089337	7c4a8d09ca3762af61e59520943dc26494f8941b	CORPORACIÓN VENEZOLANA DE TELEVISIÓN, C.A. (VENEVISIÓN)	f	1	clinares@venevision.com.ve	2	MI MAMA	\N	\N	192,168,1,101	J000089337	t	2013-03-14	f
66	J002376163	7c4a8d09ca3762af61e59520943dc26494f8941b	Corporación Televen	f	1	msarria@televentv.com.ve	2	MI MAMA	\N	\N	192,168,1,101	J002376163	t	2013-03-14	f
67	J002987235	7c4a8d09ca3762af61e59520943dc26494f8941b	La Tele Televisión, C.A.	f	1	mgranados@latele.com.ve	2	MI MAMA	\N	\N	192,168,1,101	J002987235	t	2013-03-14	f
68	J305630577	7c4a8d09ca3762af61e59520943dc26494f8941b	Barlovento TV, C.A.	f	1	soltelevision@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J305630577	t	2013-03-14	f
69	J300975339	7c4a8d09ca3762af61e59520943dc26494f8941b	Promociones Telemaracay, C.A. (TVS)	f	1	asindoni@elaragueno.com.ve	2	MI MAMA	\N	\N	192,168,1,101	J300975339	t	2013-03-14	f
70	J300020380	7c4a8d09ca3762af61e59520943dc26494f8941b	Televisión de Guayana, C.A.      (TV Guayana)	f	1	admincorreo@telcel.net.vel	2	MI MAMA	\N	\N	192,168,1,101	J300020380	t	2013-03-14	f
71	J304756771	7c4a8d09ca3762af61e59520943dc26494f8941b	Televisión de Margarita, C.A. (TELECARIBE)	f	1	Aquiles.gatas@telecaribe.tv	2	MI MAMA	\N	\N	192,168,1,101	J304756771	t	2013-03-14	f
72	J307557370	7c4a8d09ca3762af61e59520943dc26494f8941b	Canal 21 TV, C.A.	f	1		2	MI MAMA	\N	\N	192,168,1,101	J307557370	t	2013-03-14	f
73	J070523271	7c4a8d09ca3762af61e59520943dc26494f8941b	Zuliana de Televisión, S.A.	f	1	asuarez@zulianatv.com	2	MI MAMA	\N	\N	192,168,1,101	J070523271	t	2013-03-14	f
74	J001279768	7c4a8d09ca3762af61e59520943dc26494f8941b	C.A. Venezolana de Televisión	f	1	www.vtv.gob.ve	2	MI MAMA	\N	\N	192,168,1,101	J001279768	t	2013-03-14	f
75	J305083410	7c4a8d09ca3762af61e59520943dc26494f8941b	EWTN Familia Asociación Civil (TV Familia A.C)	f	1	tvfamilia@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J305083410	t	2013-03-14	f
76	G200076879	7c4a8d09ca3762af61e59520943dc26494f8941b	Fundacion Televisora Venezolana Social TVES	f	1	geleric@gmail.com	2	MI MAMA	\N	\N	192,168,1,101	G200076879	t	2013-03-14	f
77	J308322636	7c4a8d09ca3762af61e59520943dc26494f8941b	Acom 3000, C.A.	f	1	lacomlivia@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J308322636	t	2013-03-14	f
78	J308288500	7c4a8d09ca3762af61e59520943dc26494f8941b	Cable Bahias, C.A	f	1	cablebahias@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J308288500	t	2013-03-14	f
79	J30596884	7c4a8d09ca3762af61e59520943dc26494f8941b	Cable Balcón TV, C.A.	f	1		2	MI MAMA	\N	\N	192,168,1,101	J30596884	t	2013-03-14	f
80	J305740321	7c4a8d09ca3762af61e59520943dc26494f8941b	Cable C.R.B. Caribe Internacional	f	1	magnamar@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J305740321	t	2013-03-14	f
81	J307921730	7c4a8d09ca3762af61e59520943dc26494f8941b	Cable Hogar, C.A.	f	1	marcodelgado@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J307921730	t	2013-03-14	f
82	J304381034	7c4a8d09ca3762af61e59520943dc26494f8941b	Cable Tuy, C.A.	f	1	cabletuyarturo@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J304381034	t	2013-03-14	f
83	J308765201	7c4a8d09ca3762af61e59520943dc26494f8941b	Cable Uno, C.A.	f	1	moralesmiguel1@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J308765201	t	2013-03-14	f
84	J304886470	7c4a8d09ca3762af61e59520943dc26494f8941b	Cable Zulia, C.A.	f	1	agustínbecerra@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J304886470	t	2013-03-14	f
85	J304789088	7c4a8d09ca3762af61e59520943dc26494f8941b	Cablexpress TV,  C.A.	f	1	rbracho@unitel.com.ve	2	MI MAMA	\N	\N	192,168,1,101	J304789088	t	2013-03-14	f
87	J306142649	7c4a8d09ca3762af61e59520943dc26494f8941b	Comunicaciones Milenium I, C.A.	f	1	comillenium@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J306142649	t	2013-03-14	f
88	J304392940	7c4a8d09ca3762af61e59520943dc26494f8941b	Corporación Multivisión, C.A.	f	1	multivica@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J304392940	t	2013-03-14	f
89	J302406641	7c4a8d09ca3762af61e59520943dc26494f8941b	Corporación Telemic, C.A.	f	1	mroberto@intercable.com.ve	2	MI MAMA	\N	\N	192,168,1,101	J302406641	t	2013-03-14	f
90	J307607513	7c4a8d09ca3762af61e59520943dc26494f8941b	Corporación Visual Nueva Esparta, C.A. UNICABLE	f	1	unicablela@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J307607513	t	2013-03-14	f
91	J302565510	7c4a8d09ca3762af61e59520943dc26494f8941b	Cosmovisión, C.A.	f	1	cosmovision@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J302565510	t	2013-03-14	f
92	J003438286	7c4a8d09ca3762af61e59520943dc26494f8941b	Editorial Imagen, C.A.	f	1	hoker96@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J003438286	t	2013-03-14	f
93	J305709386	7c4a8d09ca3762af61e59520943dc26494f8941b	Enlace TV, C.A.	f	1	ENLACETVCA@CANTV.NET	2	MI MAMA	\N	\N	192,168,1,101	J305709386	t	2013-03-14	f
94	J302597005	7c4a8d09ca3762af61e59520943dc26494f8941b	Galaxy Entertaiment de Vzla, C.A.	f	1	dpto_impuestos@directvla.com.ve	2	MI MAMA	\N	\N	192,168,1,101	J302597005	t	2013-03-14	f
95	J312738545	7c4a8d09ca3762af61e59520943dc26494f8941b	Imagen Televisión, S.A.	f	1	multivica@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J312738545	t	2013-03-14	f
96	J308834874	7c4a8d09ca3762af61e59520943dc26494f8941b	Inversiones Cable Centro, C.A.	f	1	gerenciacablecentro@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J308834874	t	2013-03-14	f
97	J308224685	7c4a8d09ca3762af61e59520943dc26494f8941b	Medium Televisión por Cable, C.A.	f	1	medium_ve@yahoo.com	2	MI MAMA	\N	\N	192,168,1,101	J308224685	t	2013-03-14	f
98	J308804746	7c4a8d09ca3762af61e59520943dc26494f8941b	Mega Cable, C.A. (Tachira)	f	1	megacable@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J308804746	t	2013-03-14	f
99	J304633173	7c4a8d09ca3762af61e59520943dc26494f8941b	R.G.O. Somos Cable, C.A.	f	1	info@rgosomocable.com	2	MI MAMA	\N	\N	192,168,1,101	J304633173	t	2013-03-14	f
100	J308728217	7c4a8d09ca3762af61e59520943dc26494f8941b	San Casimiro TV, C.A.	f	1	juanmontoya2@msn.com	2	MI MAMA	\N	\N	192,168,1,101	J308728217	t	2013-03-14	f
101	J301687809	7c4a8d09ca3762af61e59520943dc26494f8941b	Sat- Páez, S.A. Televisión Por Cable	f	1	satpaez@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J301687809	t	2013-03-14	f
102	J306117270	7c4a8d09ca3762af61e59520943dc26494f8941b	Sistem Cable, C.A.	f	1	sistemcable@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J306117270	t	2013-03-14	f
103	J305119660	7c4a8d09ca3762af61e59520943dc26494f8941b	Skay In TV Internacional, C.A.	f	1	skay_in_tv_i@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J305119660	t	2013-03-14	f
104	J303087671	7c4a8d09ca3762af61e59520943dc26494f8941b	TV Cable, C.A.	f	1	fgonfer@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J303087671	t	2013-03-14	f
105	J305950334	7c4a8d09ca3762af61e59520943dc26494f8941b	TV Cable.com, C.A.	f	1	Tvcablecom@hotmail.cpm	2	MI MAMA	\N	\N	192,168,1,101	J305950334	t	2013-03-14	f
106	J301177156	7c4a8d09ca3762af61e59520943dc26494f8941b	TV Star Satélite, C.A.	f	1	asilvamoreno@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J301177156	t	2013-03-14	f
107	J310286183	7c4a8d09ca3762af61e59520943dc26494f8941b	Corporación Los Cortijos, C.A.	f	1	telecablebna@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J310286183	t	2013-03-14	f
108	J003311346	7c4a8d09ca3762af61e59520943dc26494f8941b	Sistemas Cablevisión, C.A.	f	1	mcmoros@vepaco.com	2	MI MAMA	\N	\N	192,168,1,101	J003311346	t	2013-03-14	f
109	J311274944	7c4a8d09ca3762af61e59520943dc26494f8941b	Reperesentaciones Inversat C.A.	f	1	inversat10@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J311274944	t	2013-03-14	f
110	J312200162	7c4a8d09ca3762af61e59520943dc26494f8941b	Cable TV Premier, C.A.	f	1	cabletvpremier@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J312200162	t	2013-03-14	f
111	J308726141	7c4a8d09ca3762af61e59520943dc26494f8941b	TV Cable Millennium, C.A.	f	1	www.cablemillenium@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J308726141	t	2013-03-14	f
112	J003439940	7c4a8d09ca3762af61e59520943dc26494f8941b	Telcel, C.A.	f	1	luis.martinez@telefonica.com.ve	2	MI MAMA	\N	\N	192,168,1,101	J003439940	t	2013-03-14	f
113	J308809985	7c4a8d09ca3762af61e59520943dc26494f8941b	TV Cable Litoral, C.A.	f	1	zoda-76@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J308809985	t	2013-03-14	f
114	J308182516	7c4a8d09ca3762af61e59520943dc26494f8941b	The House´s Televisión C.A.	f	1	administracion@cablehogar.net	2	MI MAMA	\N	\N	192,168,1,101	J308182516	t	2013-03-14	f
115	J308730246	7c4a8d09ca3762af61e59520943dc26494f8941b	Inversiones Puerto Ayacucho C.A	f	1	halberto80@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J308730246	t	2013-03-14	f
116	J309077694	7c4a8d09ca3762af61e59520943dc26494f8941b	Inversiones & Telecomunicaciones Open T.V. C.A.	f	1	opentv@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J309077694	t	2013-03-14	f
117	J310106410	7c4a8d09ca3762af61e59520943dc26494f8941b	Norte Vision C.A.	f	1	nortevision09@gmail.com	2	MI MAMA	\N	\N	192,168,1,101	J310106410	t	2013-03-14	f
118	J308200492	7c4a8d09ca3762af61e59520943dc26494f8941b	Divercable, C.A.	f	1	divercable1@gmail.com	2	MI MAMA	\N	\N	192,168,1,101	J308200492	t	2013-03-14	f
119	J309109448	7c4a8d09ca3762af61e59520943dc26494f8941b	Telecomunicaciones Network C.A.	f	1	telecomnetwork@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J309109448	t	2013-03-14	f
120	J295300301	7c4a8d09ca3762af61e59520943dc26494f8941b	Fibra TV. C.A.	f	1	diegotirado@yahoo.com	2	MI MAMA	\N	\N	192,168,1,101	J295300301	t	2013-03-14	f
121	J311611568	7c4a8d09ca3762af61e59520943dc26494f8941b	Cablecel Plus, C.A.	f	1	cablecel-plus@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J311611568	t	2013-03-14	f
122	J294943152	7c4a8d09ca3762af61e59520943dc26494f8941b	TTC Telecom Calabozo, C.A.	f	1	halberto80@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J294943152	t	2013-03-14	f
123	J306838791	7c4a8d09ca3762af61e59520943dc26494f8941b	Corporación Sombrero COM Satelital, C.A.	f	1	halberto80@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J306838791	t	2013-03-14	f
124	J306796584	7c4a8d09ca3762af61e59520943dc26494f8941b	Corporación Tucupita Satelital, C.A.	f	1	halberto80@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J306796584	t	2013-03-14	f
125	J307213000	7c4a8d09ca3762af61e59520943dc26494f8941b	Corporación Altagracia Satelital, C.A.	f	1	halberto80@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J307213000	t	2013-03-14	f
126	J304521367	7c4a8d09ca3762af61e59520943dc26494f8941b	ABA Cantaura Visión C.A.	f	1	halberto80@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J304521367	t	2013-03-14	f
127	J306763937	7c4a8d09ca3762af61e59520943dc26494f8941b	Corporación Intercaicara Satelital, C.A.	f	1	halberto80@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J306763937	t	2013-03-14	f
128	J295212925	7c4a8d09ca3762af61e59520943dc26494f8941b	Cabel Visión 21, C.A.	f	1	cabelvision21@yahoo.es	2	MI MAMA	\N	\N	192,168,1,101	J295212925	t	2013-03-14	f
129	J297059172	7c4a8d09ca3762af61e59520943dc26494f8941b	Viginet, C.A.	f	1	viginetca@gmail.com	2	MI MAMA	\N	\N	192,168,1,101	J297059172	t	2013-03-14	f
130	J295171668	7c4a8d09ca3762af61e59520943dc26494f8941b	COHERY VISIÓN, C.A.	f	1	coheryvision@yahoo.es	2	MI MAMA	\N	\N	192,168,1,101	J295171668	t	2013-03-14	f
131	J297655948	7c4a8d09ca3762af61e59520943dc26494f8941b	Corporación Matrix, C.A.	f	1	tibisaymatrix@gmail.com	2	MI MAMA	\N	\N	192,168,1,101	J297655948	t	2013-03-14	f
132	J296612676	7c4a8d09ca3762af61e59520943dc26494f8941b	C- Agua Visión	f	1	caguavision@yahoo.es	2	MI MAMA	\N	\N	192,168,1,101	J296612676	t	2013-03-14	f
133	J306630430	7c4a8d09ca3762af61e59520943dc26494f8941b	TTC Telecom Turmero, C.A	f	1	halberto80@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J306630430	t	2013-03-14	f
134	J295627580	7c4a8d09ca3762af61e59520943dc26494f8941b	Maxi Cable, C.A.	f	1	maxicablec.a@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J295627580	t	2013-03-14	f
138	J000841918	7c4a8d09ca3762af61e59520943dc26494f8941b	C.A. Cinematográfica Blancica	f	1	msaleta@blancica.com.ve	2	MI MAMA	\N	\N	192,168,1,101	J000841918	t	2013-03-14	f
139	J302092086	7c4a8d09ca3762af61e59520943dc26494f8941b	The Walt Disney Company Venezuela, S.A.	f	1	anibal.codebo@email.disney.com	2	MI MAMA	\N	\N	192,168,1,101	J302092086	t	2013-03-14	f
140	J001819134	7c4a8d09ca3762af61e59520943dc26494f8941b	Blancic Video, C.A	f	1	msaleta@blancica.com.ve	2	MI MAMA	\N	\N	192,168,1,101	J001819134	t	2013-03-14	f
141	J314914871	7c4a8d09ca3762af61e59520943dc26494f8941b	Films Sin Fronteras C.A.	f	1	graffea2000@yahoo.com	2	MI MAMA	\N	\N	192,168,1,101	J314914871	t	2013-03-14	f
142	J001241531	7c4a8d09ca3762af61e59520943dc26494f8941b	Distribuidora Sonográfica, C.A.	f	1	rpetrocelli@recorland.com	2	MI MAMA	\N	\N	192,168,1,101	J001241531	t	2013-03-14	f
143	J002745762	7c4a8d09ca3762af61e59520943dc26494f8941b	Club de Video Veroes, C.A.	f	1	ivanvideoveroes@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J002745762	t	2013-03-14	f
41	J310438510	7c4a8d09ca3762af61e59520943dc26494f8941b	Vencine, C.A.	f	1	vencineca@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J310438510	t	2013-03-14	f
2	J085096477	7c4a8d09ca3762af61e59520943dc26494f8941b	Administradora de Cines Barquisimeto C.A.	f	1	mafercine@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J085096477	t	2005-03-14	f
1	J090188975	7c4a8d09ca3762af61e59520943dc26494f8941b	Administradora de Cines Barinas, C.A.	f	1	cines@cinesacarigua.com	2	MI MAMA	\N	\N	192,168,1,101	J090188975	t	2008-03-14	f
147	J308058238	7c4a8d09ca3762af61e59520943dc26494f8941b	GRUPO INFOGUIANET,C.A (GRUPO INFOGUIANET C.A.)	f	1	jetox21@gmail.com	2	123456	2013-09-27 13:49:20.419821	\N	127.0.0.1	J308058238	t	2013-03-14	f
146	V181643907	7c4a8d09ca3762af61e59520943dc26494f8941b	JEISY COROMOTO PALACIOS MATOS	f	1	jeto_21@hotmail.com	2	no se	2013-09-26 15:29:46.697988	\N	127.0.0.1	V181643907	t	2008-03-14	f
145	V170429792	7c4a8d09ca3762af61e59520943dc26494f8941b	JEFFERSON ARTURO LARA MOLINA	t	1	jetox21@gmail.com	2	soy yo	2013-07-09 16:33:57.785188	\N	192.168.1.101	V170429792	t	2004-03-14	t
148	J306982434	e0047776358d70409f598efd4596bfa27d629e66	ORGANIZACIÓN VIEWMED, C.A. (ORGANIZACIÓN VIEWMED C.A.)	f	1	jetox21@gmail.com	2	soy yo	2013-11-08 11:33:21.976219	\N	127.0.0.1	J306982434	t	2013-03-14	f
153	J306842675	f7c3bc1d808e04732adf679965ccc34ca7ae3441	MERCADOLIBRE VENEZUELA, S.R.L (MERCADOLIBRE VENEZUELA, S.R.L. )	f	1	jetox21@gmail.com	2	123456789	2013-11-13 16:18:11.13488	\N	127.0.0.1	J306842675	t	2013-03-14	f
144	J090161244	7c4a8d09ca3762af61e59520943dc26494f8941b	Sonido Impacto 22, C.A.	f	1	avinci57@gmail.com	2	MI MAMA	\N	\N	192,168,1,101	J090161244	t	2013-03-14	f
\.


--
-- TOC entry 3253 (class 0 OID 128678)
-- Dependencies: 242 3321
-- Data for Name: conusu_interno; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY conusu_interno (id, fecha_entrada, conusuid, bln_fiscalizado, bln_nocontribuyente, observaciones, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 3964 (class 0 OID 0)
-- Dependencies: 243
-- Name: conusu_interno_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('conusu_interno_id_seq', 1, false);


--
-- TOC entry 3965 (class 0 OID 0)
-- Dependencies: 245
-- Name: conusu_tipocon_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('conusu_tipocon_id_seq', 200, true);


--
-- TOC entry 3255 (class 0 OID 128689)
-- Dependencies: 244 3321
-- Data for Name: conusu_tipocont; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY conusu_tipocont (id, conusuid, tipocontid, ip, fecha_elaboracion) FROM stdin;
1	1	1	192.168.1.101	2013-07-09
2	2	1	192.168.1.101	2013-07-09
3	3	1	192.168.1.101	2013-07-09
4	4	1	192.168.1.101	2013-07-09
5	5	1	192.168.1.101	2013-07-09
6	6	1	192.168.1.101	2013-07-09
7	7	1	192.168.1.101	2013-07-09
8	8	1	192.168.1.101	2013-07-09
9	9	1	192.168.1.101	2013-07-09
10	10	1	192.168.1.101	2013-07-09
11	11	1	192.168.1.101	2013-07-09
12	12	1	192.168.1.101	2013-07-09
13	13	1	192.168.1.101	2013-07-09
14	14	1	192.168.1.101	2013-07-09
15	15	1	192.168.1.101	2013-07-09
16	16	1	192.168.1.101	2013-07-09
17	17	1	192.168.1.101	2013-07-09
18	18	1	192.168.1.101	2013-07-09
19	19	1	192.168.1.101	2013-07-09
20	20	1	192.168.1.101	2013-07-09
21	21	1	192.168.1.101	2013-07-09
22	22	1	192.168.1.101	2013-07-09
23	23	1	192.168.1.101	2013-07-09
24	24	1	192.168.1.101	2013-07-09
25	25	1	192.168.1.101	2013-07-09
26	26	1	192.168.1.101	2013-07-09
27	27	1	192.168.1.101	2013-07-09
28	28	1	192.168.1.101	2013-07-09
29	29	1	192.168.1.101	2013-07-09
30	30	1	192.168.1.101	2013-07-09
31	31	1	192.168.1.101	2013-07-09
32	32	1	192.168.1.101	2013-07-09
33	33	1	192.168.1.101	2013-07-09
34	34	1	192.168.1.101	2013-07-09
35	35	1	192.168.1.101	2013-07-09
36	36	1	192.168.1.101	2013-07-09
37	37	1	192.168.1.101	2013-07-09
38	38	1	192.168.1.101	2013-07-09
39	39	1	192.168.1.101	2013-07-09
40	40	1	192.168.1.101	2013-07-09
41	41	1	192.168.1.101	2013-07-09
42	42	1	192.168.1.101	2013-07-09
43	43	1	192.168.1.101	2013-07-09
44	44	1	192.168.1.101	2013-07-09
45	45	1	192.168.1.101	2013-07-09
46	46	1	192.168.1.101	2013-07-09
47	47	1	192.168.1.101	2013-07-09
48	48	1	192.168.1.101	2013-07-09
49	49	1	192.168.1.101	2013-07-09
50	50	1	192.168.1.101	2013-07-09
51	51	1	192.168.1.101	2013-07-09
52	52	1	192.168.1.101	2013-07-09
53	53	1	192.168.1.101	2013-07-09
54	54	1	192.168.1.101	2013-07-09
55	55	1	192.168.1.101	2013-07-09
56	56	1	192.168.1.101	2013-07-09
57	57	1	192.168.1.101	2013-07-09
58	58	1	192.168.1.101	2013-07-09
59	59	1	192.168.1.101	2013-07-09
60	60	1	192.168.1.101	2013-07-09
61	61	1	192.168.1.101	2013-07-09
62	62	2	192.168.1.101	2013-07-09
63	63	2	192.168.1.101	2013-07-09
64	64	2	192.168.1.101	2013-07-09
65	65	2	192.168.1.101	2013-07-09
66	66	2	192.168.1.101	2013-07-09
67	67	2	192.168.1.101	2013-07-09
68	68	2	192.168.1.101	2013-07-09
69	69	2	192.168.1.101	2013-07-09
70	70	2	192.168.1.101	2013-07-09
71	71	2	192.168.1.101	2013-07-09
72	72	2	192.168.1.101	2013-07-09
73	73	2	192.168.1.101	2013-07-09
74	74	2	192.168.1.101	2013-07-09
75	75	2	192.168.1.101	2013-07-09
76	76	2	192.168.1.101	2013-07-09
77	77	3	192.168.1.101	2013-07-09
78	78	3	192.168.1.101	2013-07-09
79	79	3	192.168.1.101	2013-07-09
80	80	3	192.168.1.101	2013-07-09
81	81	3	192.168.1.101	2013-07-09
82	82	3	192.168.1.101	2013-07-09
83	83	3	192.168.1.101	2013-07-09
84	84	3	192.168.1.101	2013-07-09
85	85	3	192.168.1.101	2013-07-09
86	86	3	192.168.1.101	2013-07-09
87	87	3	192.168.1.101	2013-07-09
88	88	3	192.168.1.101	2013-07-09
89	89	3	192.168.1.101	2013-07-09
90	90	3	192.168.1.101	2013-07-09
91	91	3	192.168.1.101	2013-07-09
92	92	3	192.168.1.101	2013-07-09
93	93	3	192.168.1.101	2013-07-09
94	94	3	192.168.1.101	2013-07-09
95	95	3	192.168.1.101	2013-07-09
96	96	3	192.168.1.101	2013-07-09
97	97	3	192.168.1.101	2013-07-09
98	98	3	192.168.1.101	2013-07-09
99	99	3	192.168.1.101	2013-07-09
100	100	3	192.168.1.101	2013-07-09
101	101	3	192.168.1.101	2013-07-09
102	102	3	192.168.1.101	2013-07-09
103	103	3	192.168.1.101	2013-07-09
104	104	3	192.168.1.101	2013-07-09
105	105	3	192.168.1.101	2013-07-09
106	106	3	192.168.1.101	2013-07-09
107	107	3	192.168.1.101	2013-07-09
108	108	3	192.168.1.101	2013-07-09
109	109	3	192.168.1.101	2013-07-09
110	110	3	192.168.1.101	2013-07-09
111	111	3	192.168.1.101	2013-07-09
112	112	3	192.168.1.101	2013-07-09
113	113	3	192.168.1.101	2013-07-09
114	114	3	192.168.1.101	2013-07-09
115	115	3	192.168.1.101	2013-07-09
116	116	3	192.168.1.101	2013-07-09
117	117	3	192.168.1.101	2013-07-09
118	118	3	192.168.1.101	2013-07-09
119	119	3	192.168.1.101	2013-07-09
120	120	3	192.168.1.101	2013-07-09
121	121	3	192.168.1.101	2013-07-09
122	122	3	192.168.1.101	2013-07-09
123	123	3	192.168.1.101	2013-07-09
124	124	3	192.168.1.101	2013-07-09
125	125	3	192.168.1.101	2013-07-09
126	126	3	192.168.1.101	2013-07-09
127	127	3	192.168.1.101	2013-07-09
128	128	3	192.168.1.101	2013-07-09
129	129	3	192.168.1.101	2013-07-09
130	130	3	192.168.1.101	2013-07-09
131	131	3	192.168.1.101	2013-07-09
132	132	3	192.168.1.101	2013-07-09
133	133	3	192.168.1.101	2013-07-09
134	134	3	192.168.1.101	2013-07-09
136	54	4	192.168.1.101	2013-07-09
137	138	4	192.168.1.101	2013-07-09
138	139	4	192.168.1.101	2013-07-09
139	140	4	192.168.1.101	2013-07-09
140	141	4	192.168.1.101	2013-07-09
141	142	5	192.168.1.101	2013-07-09
142	143	5	192.168.1.101	2013-07-09
143	144	5	192.168.1.101	2013-07-09
154	144	1	192.168.1.102	2013-08-20
155	144	2	192.168.1.102	2013-08-20
156	144	3	192.168.1.102	2013-08-20
157	144	4	192.168.1.102	2013-08-20
160	145	1	127.0.0.1	2013-09-20
161	145	2	127.0.0.1	2013-09-20
162	145	3	127.0.0.1	2013-09-20
163	145	4	127.0.0.1	2013-09-20
164	145	5	127.0.0.1	2013-09-20
165	145	6	127.0.0.1	2013-09-20
166	146	1	127.0.0.1	2013-09-26
167	146	2	127.0.0.1	2013-09-26
168	146	3	127.0.0.1	2013-09-26
169	146	4	127.0.0.1	2013-09-26
170	146	5	127.0.0.1	2013-09-26
171	146	6	127.0.0.1	2013-09-26
195	147	2	127.0.0.1	2013-09-27
196	147	4	127.0.0.1	2013-09-27
197	148	1	127.0.0.1	2013-11-08
198	148	3	127.0.0.1	2013-11-08
199	148	4	127.0.0.1	2013-11-08
200	153	5	127.0.0.1	2013-11-13
\.


--
-- TOC entry 3197 (class 0 OID 128445)
-- Dependencies: 186 3321
-- Data for Name: conusuco; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY conusuco (id, conusuid, contribuid) FROM stdin;
\.


--
-- TOC entry 3199 (class 0 OID 128450)
-- Dependencies: 188 3321
-- Data for Name: conusuti; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY conusuti (id, nombre, administra, liquida, visualiza, usuarioid, ip) FROM stdin;
1	ADMINISTRADOR	t	t	f	16	192.168.1.102
\.


--
-- TOC entry 3201 (class 0 OID 128458)
-- Dependencies: 190 3321
-- Data for Name: conusuto; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY conusuto (id, token, conusuid, fechacrea, fechacadu, usado) FROM stdin;
131	90a14de88990b8fbf342bd3a177a0fb100c8b1f0	145	2013-07-09 16:33:57.785188	2013-07-10 16:33:57.785188	t
132	0a257c748b77e4a382d0107d696f7d7aa41c1180	146	2013-09-26 15:29:46.697988	2013-09-27 15:29:46.697988	t
133	96d4a3df4467c25fbf4bd6fa19c59d8cef6ddfb9	147	2013-09-27 13:49:20.419821	2013-09-28 13:49:20.419821	t
135	c98aa7133829795343c733017434bdd58b9cb034	146	2013-09-27 15:04:15.270496	2013-09-28 15:04:15.270496	t
134	4ffebd4abeeb61946832d782341546a891d24864	146	2013-09-27 15:04:15.237264	2013-09-28 15:04:15.237264	t
136	496352cd9510bb7047adf11d28913b517f39d740	148	2013-11-08 11:33:21.976219	2013-11-09 11:33:21.976219	t
138	ab05821f360064f22583dfb19446a4f2e75b2668	145	2013-11-08 15:18:23.686736	2013-11-09 15:18:23.686736	f
137	983887d86d766f811985ff7e15271867359007fe	145	2013-11-08 15:18:23.680572	2013-11-09 15:18:23.680572	t
139	37238d0fc2b790de559117877640ded11e5bd697	153	2013-11-13 16:18:11.13488	2013-11-14 16:18:11.13488	t
\.


--
-- TOC entry 3257 (class 0 OID 128695)
-- Dependencies: 246 3321
-- Data for Name: correlativos_actas; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY correlativos_actas (id, nombre, correlativo, anio, tipo) FROM stdin;
3	acta resolucion culminatoria	6	2013	reso-culminatoria
4	acta resolucion sumario	4	2013	reso-sumario
1	autorizacion fiscal	52	2013	\N
2	acta reparo	12	2013	act-rpfis-1
5	acta resolucion extemporanio	10	2013	reso-extem
\.


--
-- TOC entry 3966 (class 0 OID 0)
-- Dependencies: 247
-- Name: correlativos_actas_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('correlativos_actas_id_seq', 5, true);


--
-- TOC entry 3259 (class 0 OID 128703)
-- Dependencies: 248 3321
-- Data for Name: correos_enviados; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY correos_enviados (id, rif, email_enviar, asunto_enviar, contenido_enviar, ip, usuarioid, fecha_envio, procesado) FROM stdin;
16	V170429792	jetox21@gmail.com	rweqvqwervwe	eqrvrqerfqwfefwqdqwdqfefrfgre ergweqqwefqw wefrfwefweq wefwefqwewefwef  wefwef	127.0.0.1	48	2013-09-26 15:07:21	t
18	V170429792	jetox21@gmail.com	rtgwerger	ergwergerwgwer	127.0.0.1	48	2013-09-26 15:11:44	t
17	V170429792	jetox21@gmail.com	retgwergewr	erwgewrgewge	127.0.0.1	48	2013-09-26 15:10:35	t
19	V170429792	jetox21@gmail.com	vsdfd	gsdfgsd	127.0.0.1	48	2013-11-15 11:32:18	f
20	V170429792	jetox21@gmail.com	prueba	no tengo ni idea de lo que t estoy mandando	127.0.0.1	48	2013-11-15 13:46:51	f
21	V170429792	jetox21@gmail.com	prueba	vamos a ver si arre gle este saperoco	127.0.0.1	48	2013-11-15 13:59:09	f
22	V170429792	jetox21@gmail.com	prueba 	otra vez la burra vuelve al trigo	127.0.0.1	48	2013-11-15 14:01:26	f
23	V170429792	jetox21@gmail.com	fghfgdhdf	otra vez menor probando esta jodia	127.0.0.1	48	2013-11-15 14:03:05	f
24	V170429792	jetox21@gmail.com	fdssdfhg	sghfgd sghdhdf hsghg gshfghf	127.0.0.1	48	2013-11-15 14:05:21	f
25	V170429792	jetox21@gmail.com	prueba final 	vamos a ver como llega el mensaje ahorita 	127.0.0.1	48	2013-11-15 14:07:27	f
26	V170429792	jetox21@gmail.com	otra vez 	vamos de nuevo en esta jodia no sabes cunato tiempo	127.0.0.1	48	2013-11-15 14:08:42	f
27	V170429792	jetox21@gmail.com	come como un rey	kdjgsda jkghdsfjklasdk jkgdslfkhas jksdghlfjhas kjsdhfljkas jkdgsfklasd jsdglafjkas jkldgslfbasdjkl	127.0.0.1	48	2013-11-15 14:12:14	f
28	V170429792	jetox21@gmail.com	fdgsdfg	dsfgsdf dfshgfdj gfjdh gfjdhjhf gsfjhdfjdf sghdhd fgjhdgjdf fgjdhjd	127.0.0.1	48	2013-11-15 14:13:13	f
29	V170429792	jetox21@gmail.com	GSDFGSDFG	SDFGDF SDGHSDF SDHSGH SHDFHSDG	127.0.0.1	48	2013-11-15 14:17:21	f
30	V170429792	jetox21@gmail.com	FDSDGH	GFHDDF	127.0.0.1	48	2013-11-15 14:18:45	f
31	V170429792	jetox21@gmail.com	FGBNFG	FGDHFH FGDJDFGHDF	127.0.0.1	48	2013-11-15 14:21:57	f
\.


--
-- TOC entry 3967 (class 0 OID 0)
-- Dependencies: 249
-- Name: correos_enviados_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('correos_enviados_id_seq', 31, true);


--
-- TOC entry 3261 (class 0 OID 128711)
-- Dependencies: 250 3321
-- Data for Name: ctaconta; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY ctaconta (cuenta, descripcion, usaraux, inactiva, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 3262 (class 0 OID 128716)
-- Dependencies: 251 3321
-- Data for Name: declara; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY declara (id, nudeclara, nudeposito, tdeclaraid, fechaelab, fechaini, fechafin, replegalid, baseimpo, alicuota, exonera, nuactoexon, credfiscal, contribant, plasustid, montopagar, bln_reparo, fechapago, fechaconci, asientoid, usuarioid, ip, tipocontribuid, conusuid, calpagodid, reparoid, proceso, bln_declaro0, fecha_carga_pago) FROM stdin;
568	V181643907120913005000000010	123456789	2	2013-11-12 11:31:46.060939	2013-10-01	2013-10-21	4	10000000.00	5.00	0.00	\N	0.00	\N	\N	500000.00	f	2013-11-12	\N	\N	17	127.0.0.1	1	146	346	\N	\N	f	2013-11-12 11:32:56.97506
591	V18164390762021200050000009	56754634634	2	2013-11-13 10:08:17.128815	2012-07-01	2012-07-25	4	5000000.00	1.00	0.00	\N	0.00	\N	\N	50000.00	f	2013-11-13	\N	\N	17	127.0.0.1	6	146	301	\N	\N	f	2013-11-13 10:09:44.922431
580	V18164390712011300005000004	1245643131	2	2013-11-12 14:09:54.53114	2013-02-01	2013-02-25	4	100000.00	5.00	0.00	\N	0.00	\N	\N	5000.00	f	2013-11-12	\N	\N	17	127.0.0.1	1	146	338	\N	\N	f	2013-11-12 16:26:26.628888
593	V18164390712041300100000005	o879897	2	2013-11-13 10:14:46.077327	2013-05-01	2013-05-23	4	2000000.00	5.00	0.00	\N	0.00	\N	\N	100000.00	f	2013-11-13	\N	\N	17	127.0.0.1	1	146	341	\N	\N	f	2013-11-13 10:15:13.812113
595	V18164390732041200009750006	23412342314fsdfsa	2	2013-11-13 14:33:44.100768	2013-01-01	2013-01-22	4	650000.00	1.50	0.00	\N	0.00	\N	\N	9750.00	f	2013-11-13	\N	\N	17	127.0.0.1	3	146	299	\N	\N	f	2013-11-13 14:35:55.055728
598	V18164390732031200015000006	67432345654	2	2013-11-13 14:53:56.453329	2012-10-01	2012-10-15	4	1000000.00	1.50	0.00	\N	0.00	\N	\N	15000.00	f	2013-11-13	\N	\N	17	127.0.0.1	3	146	298	\N	\N	f	2013-11-13 14:54:18.500077
608	V18164390716041200050000006	q53453523	6	2013-11-13 15:13:42.598738	2012-05-01	2012-05-23	4	1000000.00	5.00	0.00	\N	0.00	\N	\N	50000.00	t	2013-11-13	\N	\N	17	127.0.0.1	1	146	12	604	aprobado	f	2013-11-13 15:15:14.18401
609	V18164390716051200050000005	23235452	6	2013-11-13 15:13:42.598738	2012-06-01	2012-06-22	4	1000000.00	5.00	0.00	\N	0.00	\N	\N	50000.00	t	2013-11-13	\N	\N	17	127.0.0.1	1	146	13	604	aprobado	f	2013-11-13 15:16:23.927522
611	V18164390726011200684720002	\N	6	2013-11-13 15:24:00.88771	2013-02-01	2013-02-14	4	50000000.00	1.50	0.00	\N	0.00	\N	\N	684720.00	t	\N	\N	\N	17	127.0.0.1	2	146	246	610	notificado	f	\N
613	\N	\N	2	2013-11-14 16:50:23.831234	2008-03-01	2008-03-25	4	1000000.00	5.00	0.00	\N	0.00	\N	\N	5000.00	f	2013-11-14	\N	\N	17	127.0.0.1	1	1	109	0	\N	f	\N
615	J09018897516010800050000006	\N	6	2013-11-14 16:58:03.942091	2008-02-01	2008-02-25	4	1000000.00	5.00	0.00	\N	0.00	\N	\N	50000.00	t	\N	\N	\N	17	127.0.0.1	1	1	108	614	\N	f	\N
616	J09018897516080800250000009	\N	6	2013-11-14 16:58:03.942091	2008-09-01	2008-09-19	4	5000000.00	5.00	0.00	\N	0.00	\N	\N	250000.00	t	\N	\N	\N	17	127.0.0.1	1	1	115	614	\N	f	\N
618	V18164390726010911960135005	\N	6	2013-11-15 10:01:03.408378	2010-02-01	2010-02-17	4	800000000.00	1.50	0.00	\N	0.00	\N	\N	11960135.00	t	\N	\N	\N	17	127.0.0.1	2	146	240	617	\N	f	\N
592	V18164390712031300005000008	67456456dft	2	2013-11-13 10:14:30.092032	2013-04-01	2013-04-22	4	100000.00	5.00	0.00	\N	0.00	\N	\N	5000.00	f	2013-11-13	\N	\N	17	127.0.0.1	1	146	340	\N	\N	f	2013-11-13 10:15:00.966776
590	V18164390746011000250000006	\N	6	2013-11-12 16:03:58.273616	2011-02-01	2011-02-14	4	5000000.00	5.00	0.00	\N	0.00	\N	\N	250000.00	t	\N	\N	\N	17	127.0.0.1	4	146	243	589	notificado	f	\N
594	V18164390732011300000750007	342534534tt5	2	2013-11-13 14:33:24.579988	2013-04-01	2013-04-15	4	50000.00	1.50	0.00	\N	0.00	\N	\N	750.00	f	2013-11-13	\N	\N	17	127.0.0.1	3	146	362	\N	\N	f	2013-11-13 14:36:06.592232
596	V18164390732021300135000007	23454235234	2	2013-11-13 14:39:27.330862	2013-07-01	2013-07-15	4	9000000.00	1.50	0.00	\N	0.00	\N	\N	135000.00	f	2013-11-13	\N	\N	17	127.0.0.1	3	146	363	\N	\N	f	2013-11-13 14:39:57.818753
597	V18164390762031300009500008	898857658765	2	2013-11-13 14:40:31.361774	2013-10-01	2013-10-21	4	950000.00	1.00	0.00	\N	0.00	\N	\N	9500.00	f	2013-11-13	\N	\N	17	127.0.0.1	6	146	310	\N	\N	f	2013-11-13 14:40:56.772914
570	\N	2342354	6	2013-11-12 11:51:15.850271	2008-04-01	2008-04-21	4	100000.00	5.00	0.00	\N	0.00	\N	\N	5000.00	t	2013-11-12	\N	\N	17	127.0.0.1	1	146	110	569	notificado	f	2013-11-12 11:56:03.924504
600	V18164390736011100007500009	56734534	6	2013-11-13 15:08:43.122852	2011-04-01	2011-04-15	4	500000.00	1.50	0.00	\N	0.00	\N	\N	7500.00	t	2013-11-13	\N	\N	17	127.0.0.1	3	146	288	599	aprobado	f	2013-11-13 15:09:40.752791
601	V18164390736021100015000008	6346546543	6	2013-11-13 15:08:43.122852	2011-07-01	2011-07-15	4	1000000.00	1.50	0.00	\N	0.00	\N	\N	15000.00	t	2013-11-13	\N	\N	17	127.0.0.1	3	146	289	599	aprobado	f	2013-11-13 15:10:00.779027
602	V18164390736031100120000004	456234342	6	2013-11-13 15:08:43.122852	2011-10-01	2011-10-17	4	8000000.00	1.50	0.00	\N	0.00	\N	\N	120000.00	t	2013-11-13	\N	\N	17	127.0.0.1	3	146	290	599	aprobado	f	2013-11-13 15:10:16.15934
603	V18164390736041100014400003	3452345234534	6	2013-11-13 15:08:43.122852	2012-01-01	2012-01-17	4	960000.00	1.50	0.00	\N	0.00	\N	\N	14400.00	t	2013-11-13	\N	\N	17	127.0.0.1	3	146	291	599	aprobado	f	2013-11-13 15:10:28.28585
605	V18164390716011200050000007	435453443	6	2013-11-13 15:13:42.598738	2012-02-01	2012-02-23	4	1000000.00	5.00	0.00	\N	0.00	\N	\N	50000.00	t	2013-11-13	\N	\N	17	127.0.0.1	1	146	9	604	aprobado	f	2013-11-13 15:14:32.724999
606	V18164390716021200050000008	4364673434	6	2013-11-13 15:13:42.598738	2012-03-01	2012-03-22	4	1000000.00	5.00	0.00	\N	0.00	\N	\N	50000.00	t	2013-11-13	\N	\N	17	127.0.0.1	1	146	10	604	aprobado	f	2013-11-13 15:14:45.005045
607	V18164390716031200050000001	463634634	6	2013-11-13 15:13:42.598738	2012-04-01	2012-04-25	4	1000000.00	5.00	0.00	\N	0.00	\N	\N	50000.00	t	2013-11-13	\N	\N	17	127.0.0.1	1	146	11	604	aprobado	f	2013-11-13 15:14:58.740546
571	\N	5452352345	6	2013-11-12 11:51:15.850271	2008-05-01	2008-05-23	4	2000000.00	5.00	0.00	\N	0.00	\N	\N	100000.00	t	2013-11-12	\N	\N	17	127.0.0.1	1	146	111	569	notificado	f	2013-11-12 11:57:42.652784
572	\N	5623462346	6	2013-11-12 11:51:15.850271	2008-06-01	2008-06-20	4	300000.00	5.00	0.00	\N	0.00	\N	\N	15000.00	t	2013-11-12	\N	\N	17	127.0.0.1	1	146	112	569	notificado	f	2013-11-12 11:57:58.819776
579	\N	f3r55354425	6	2013-11-12 11:51:15.850271	2009-01-01	2009-01-22	4	989000000.00	5.00	0.00	\N	0.00	\N	\N	49450000.00	t	2013-11-12	\N	\N	17	127.0.0.1	1	146	119	569	notificado	f	2013-11-12 12:00:46.287465
578	\N	fg23423	6	2013-11-12 11:51:15.850271	2008-12-01	2008-12-22	4	1000000000.00	5.00	0.00	\N	0.00	\N	\N	50000000.00	t	2013-11-12	\N	\N	17	127.0.0.1	1	146	118	569	notificado	f	2013-11-12 12:00:25.132443
577	\N	2354234134f	6	2013-11-12 11:51:15.850271	2008-11-01	2008-11-21	4	90000000.00	5.00	0.00	\N	0.00	\N	\N	4500000.00	t	2013-11-12	\N	\N	17	127.0.0.1	1	146	117	569	notificado	f	2013-11-12 12:00:09.839584
576	\N	45234523453	6	2013-11-12 11:51:15.850271	2008-10-01	2008-10-21	4	10000000.00	5.00	0.00	\N	0.00	\N	\N	500000.00	t	2013-11-12	\N	\N	17	127.0.0.1	1	146	116	569	notificado	f	2013-11-12 11:59:19.41966
575	\N	4523452345	6	2013-11-12 11:51:15.850271	2008-09-01	2008-09-19	4	6000000.00	5.00	0.00	\N	0.00	\N	\N	300000.00	t	2013-11-12	\N	\N	17	127.0.0.1	1	146	115	569	notificado	f	2013-11-12 11:59:04.944104
574	\N	2315123454	6	2013-11-12 11:51:15.850271	2008-08-01	2008-08-22	4	5000000.00	5.00	0.00	\N	0.00	\N	\N	250000.00	t	2013-11-12	\N	\N	17	127.0.0.1	1	146	114	569	notificado	f	2013-11-12 11:58:39.312504
573	\N	3453425341252	6	2013-11-12 11:51:15.850271	2008-07-01	2008-07-21	4	40000000.00	5.00	0.00	\N	0.00	\N	\N	2000000.00	t	2013-11-12	\N	\N	17	127.0.0.1	1	146	113	569	notificado	f	2013-11-12 11:58:14.26078
582	\N	34534534	6	2013-11-12 14:58:51.338053	2012-02-01	2012-02-14	4	100000000.00	1.50	0.00	\N	0.00	\N	\N	1444912.00	t	2013-11-12	\N	\N	17	127.0.0.1	2	146	244	581	notificado	f	2013-11-12 16:11:26.759803
\.


--
-- TOC entry 3207 (class 0 OID 128492)
-- Dependencies: 196 3321
-- Data for Name: declara_viejo; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY declara_viejo (id, nudeclara, nudeposito, tdeclaraid, fechaelab, fechaini, fechafin, replegalid, baseimpo, alicuota, exonera, nuactoexon, credfiscal, contribant, plasustid, nuresactfi, fechanoti, intemora, reparofis, multa, montopagar, fechapago, fechaconci, asientoid, usuarioid, ip, tipocontribuid, conusuid, calpagodid) FROM stdin;
\.


--
-- TOC entry 3209 (class 0 OID 128505)
-- Dependencies: 198 3321
-- Data for Name: departam; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY departam (id, nombre, usuarioid, ip, cod_estructura) FROM stdin;
3	GERENCIA DE FISCALIZACION	17	192.168.1.102	G-FIS-01
8	GERENCIA DE FINANZAS	17	192.168.1.102	G-FIN-03
7	GERENCIA DE RECAUDACION	17	192.168.1.102	G-REC-02
9	GERENCIA DE LEGAL	17	192.168.1.102	G-LEG-04
10	GERENCIA GENERAL DE FONPROCINE	17	192.168.1.102	G-GEN-05
\.


--
-- TOC entry 3265 (class 0 OID 128753)
-- Dependencies: 256 3321
-- Data for Name: descargos; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY descargos (id, fecha, compareciente, cargo_comp, reparoid, usuario, ip, estatus) FROM stdin;
\.


--
-- TOC entry 3968 (class 0 OID 0)
-- Dependencies: 257
-- Name: descargos_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('descargos_id_seq', 2, true);


--
-- TOC entry 3267 (class 0 OID 128761)
-- Dependencies: 258 3321
-- Data for Name: detalle_interes; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY detalle_interes (id, intereses, tasa, dias, mes, anio, intereses_id, ip, usuarioid, capital, "tasa%") FROM stdin;
6069	0.000000	0.000000	10	10	2013	450	127.0.0.1	48	500000.00	\N
6070	0.000000	0.000000	12	11	2013	450	127.0.0.1	48	500000.00	\N
6071	3670.500000	0.081567	9	04	2008	451	127.0.0.1	48	5000.00	24.47
6072	13417.833333	0.086567	31	05	2008	451	127.0.0.1	48	5000.00	25.97
6073	12390.000000	0.082600	30	06	2008	451	127.0.0.1	48	5000.00	24.78
6074	13350.666667	0.086133	31	07	2008	451	127.0.0.1	48	5000.00	25.84
6075	12963.166667	0.083633	31	08	2008	451	127.0.0.1	48	5000.00	25.09
6076	12360.000000	0.082400	30	09	2008	451	127.0.0.1	48	5000.00	24.72
6077	12627.333333	0.081467	31	10	2008	451	127.0.0.1	48	5000.00	24.44
6078	12440.000000	0.082933	30	11	2008	451	127.0.0.1	48	5000.00	24.88
6079	12048.666667	0.077733	31	12	2008	451	127.0.0.1	48	5000.00	23.32
6080	13645.166667	0.088033	31	01	2009	451	127.0.0.1	48	5000.00	26.41
6081	12548.666667	0.089633	28	02	2009	451	127.0.0.1	48	5000.00	26.89
6082	13366.166667	0.086233	31	03	2009	451	127.0.0.1	48	5000.00	25.87
6083	12325.000000	0.082167	30	04	2009	451	127.0.0.1	48	5000.00	24.65
6084	12420.666667	0.080133	31	05	2009	451	127.0.0.1	48	5000.00	24.04
6085	11210.000000	0.074733	30	06	2009	451	127.0.0.1	48	5000.00	22.42
6086	11521.666667	0.074333	31	07	2009	451	127.0.0.1	48	5000.00	22.30
6087	11526.833333	0.074367	31	08	2009	451	127.0.0.1	48	5000.00	22.31
6088	10435.000000	0.069567	30	09	2009	451	127.0.0.1	48	5000.00	20.87
6089	11346.000000	0.073200	31	10	2009	451	127.0.0.1	48	5000.00	21.96
6090	10810.000000	0.072067	30	11	2009	451	127.0.0.1	48	5000.00	21.62
6091	11227.166667	0.072433	31	12	2009	451	127.0.0.1	48	5000.00	21.73
6092	10953.333333	0.070667	31	01	2010	451	127.0.0.1	48	5000.00	21.20
6093	10406.666667	0.074333	28	02	2010	451	127.0.0.1	48	5000.00	22.30
6094	10798.333333	0.069667	31	03	2010	451	127.0.0.1	48	5000.00	20.90
6095	10595.000000	0.070633	30	04	2010	451	127.0.0.1	48	5000.00	21.19
6096	10519.333333	0.067867	31	05	2010	451	127.0.0.1	48	5000.00	20.36
6097	10210.000000	0.068067	30	06	2010	451	127.0.0.1	48	5000.00	20.42
6098	10488.333333	0.067667	31	07	2010	451	127.0.0.1	48	5000.00	20.30
6099	10338.500000	0.066700	31	08	2010	451	127.0.0.1	48	5000.00	20.01
6100	10510.000000	0.070067	30	09	2010	451	127.0.0.1	48	5000.00	21.02
6101	10116.333333	0.065267	31	10	2010	451	127.0.0.1	48	5000.00	19.58
6102	10020.000000	0.066800	30	11	2010	451	127.0.0.1	48	5000.00	20.04
6103	10354.000000	0.066800	31	12	2010	451	127.0.0.1	48	5000.00	20.04
6104	10245.500000	0.066100	31	01	2011	451	127.0.0.1	48	5000.00	19.83
6105	9286.666667	0.066333	28	02	2011	451	127.0.0.1	48	5000.00	19.90
6106	10271.333333	0.066267	31	03	2011	451	127.0.0.1	48	5000.00	19.88
6107	10010.000000	0.066733	30	04	2011	451	127.0.0.1	48	5000.00	20.02
6108	10731.166667	0.069233	31	05	2011	451	127.0.0.1	48	5000.00	20.77
6109	9955.000000	0.066367	30	06	2011	451	127.0.0.1	48	5000.00	19.91
6110	10545.166667	0.068033	31	07	2011	451	127.0.0.1	48	5000.00	20.41
6111	9889.000000	0.063800	31	08	2011	451	127.0.0.1	48	5000.00	19.14
6112	9840.000000	0.065600	30	09	2011	451	127.0.0.1	48	5000.00	19.68
6113	10457.333333	0.067467	31	10	2011	451	127.0.0.1	48	5000.00	20.24
6114	9295.000000	0.061967	30	11	2011	451	127.0.0.1	48	5000.00	18.59
6115	9248.333333	0.059667	31	12	2011	451	127.0.0.1	48	5000.00	17.90
6116	9641.000000	0.062200	31	01	2012	451	127.0.0.1	48	5000.00	18.66
6117	8912.666667	0.061467	29	02	2012	451	127.0.0.1	48	5000.00	18.44
6118	8819.500000	0.056900	31	03	2012	451	127.0.0.1	48	5000.00	17.07
6119	0.000000	0.000000	30	04	2012	451	127.0.0.1	48	5000.00	0.00
6120	0.000000	0.000000	31	05	2012	451	127.0.0.1	48	5000.00	0.00
6121	0.000000	0.000000	30	06	2012	451	127.0.0.1	48	5000.00	0.00
6122	0.000000	0.000000	31	07	2012	451	127.0.0.1	48	5000.00	0.00
6123	0.000000	0.000000	31	08	2012	451	127.0.0.1	48	5000.00	0.00
6124	0.000000	0.000000	30	09	2012	451	127.0.0.1	48	5000.00	0.00
6125	0.000000	0.000000	31	10	2012	451	127.0.0.1	48	5000.00	0.00
6126	0.000000	0.000000	30	11	2012	451	127.0.0.1	48	5000.00	0.00
6127	0.000000	0.000000	31	12	2012	451	127.0.0.1	48	5000.00	0.00
6128	7574.333333	0.048867	31	01	2013	451	127.0.0.1	48	5000.00	14.66
6129	7219.333333	0.051567	28	02	2013	451	127.0.0.1	48	5000.00	15.47
6130	7693.166667	0.049633	31	03	2013	451	127.0.0.1	48	5000.00	14.89
6131	7545.000000	0.050300	30	04	2013	451	127.0.0.1	48	5000.00	15.09
6132	7786.166667	0.050233	31	05	2013	451	127.0.0.1	48	5000.00	15.07
6133	7440.000000	0.049600	30	06	2013	451	127.0.0.1	48	5000.00	14.88
6134	0.000000	0.000000	31	07	2013	451	127.0.0.1	48	5000.00	\N
6135	0.000000	0.000000	31	08	2013	451	127.0.0.1	48	5000.00	\N
6136	0.000000	0.000000	30	09	2013	451	127.0.0.1	48	5000.00	\N
6137	0.000000	0.000000	31	10	2013	451	127.0.0.1	48	5000.00	\N
6138	0.000000	0.000000	12	11	2013	451	127.0.0.1	48	5000.00	\N
6139	69253.333333	0.086567	8	05	2008	452	127.0.0.1	48	100000.00	25.97
6140	247800.000000	0.082600	30	06	2008	452	127.0.0.1	48	100000.00	24.78
6141	267013.333333	0.086133	31	07	2008	452	127.0.0.1	48	100000.00	25.84
6142	259263.333333	0.083633	31	08	2008	452	127.0.0.1	48	100000.00	25.09
6143	247200.000000	0.082400	30	09	2008	452	127.0.0.1	48	100000.00	24.72
6144	252546.666667	0.081467	31	10	2008	452	127.0.0.1	48	100000.00	24.44
6145	248800.000000	0.082933	30	11	2008	452	127.0.0.1	48	100000.00	24.88
6146	240973.333333	0.077733	31	12	2008	452	127.0.0.1	48	100000.00	23.32
6147	272903.333333	0.088033	31	01	2009	452	127.0.0.1	48	100000.00	26.41
6148	250973.333333	0.089633	28	02	2009	452	127.0.0.1	48	100000.00	26.89
6149	267323.333333	0.086233	31	03	2009	452	127.0.0.1	48	100000.00	25.87
6150	246500.000000	0.082167	30	04	2009	452	127.0.0.1	48	100000.00	24.65
6151	248413.333333	0.080133	31	05	2009	452	127.0.0.1	48	100000.00	24.04
6152	224200.000000	0.074733	30	06	2009	452	127.0.0.1	48	100000.00	22.42
6153	230433.333333	0.074333	31	07	2009	452	127.0.0.1	48	100000.00	22.30
6154	230536.666667	0.074367	31	08	2009	452	127.0.0.1	48	100000.00	22.31
6155	208700.000000	0.069567	30	09	2009	452	127.0.0.1	48	100000.00	20.87
6156	226920.000000	0.073200	31	10	2009	452	127.0.0.1	48	100000.00	21.96
6157	216200.000000	0.072067	30	11	2009	452	127.0.0.1	48	100000.00	21.62
6158	224543.333333	0.072433	31	12	2009	452	127.0.0.1	48	100000.00	21.73
6159	219066.666667	0.070667	31	01	2010	452	127.0.0.1	48	100000.00	21.20
6160	208133.333333	0.074333	28	02	2010	452	127.0.0.1	48	100000.00	22.30
6161	215966.666667	0.069667	31	03	2010	452	127.0.0.1	48	100000.00	20.90
6162	211900.000000	0.070633	30	04	2010	452	127.0.0.1	48	100000.00	21.19
6163	210386.666667	0.067867	31	05	2010	452	127.0.0.1	48	100000.00	20.36
6164	204200.000000	0.068067	30	06	2010	452	127.0.0.1	48	100000.00	20.42
6165	209766.666667	0.067667	31	07	2010	452	127.0.0.1	48	100000.00	20.30
6166	206770.000000	0.066700	31	08	2010	452	127.0.0.1	48	100000.00	20.01
6167	210200.000000	0.070067	30	09	2010	452	127.0.0.1	48	100000.00	21.02
6168	202326.666667	0.065267	31	10	2010	452	127.0.0.1	48	100000.00	19.58
6169	200400.000000	0.066800	30	11	2010	452	127.0.0.1	48	100000.00	20.04
6170	207080.000000	0.066800	31	12	2010	452	127.0.0.1	48	100000.00	20.04
6171	204910.000000	0.066100	31	01	2011	452	127.0.0.1	48	100000.00	19.83
6172	185733.333333	0.066333	28	02	2011	452	127.0.0.1	48	100000.00	19.90
6173	205426.666667	0.066267	31	03	2011	452	127.0.0.1	48	100000.00	19.88
6174	200200.000000	0.066733	30	04	2011	452	127.0.0.1	48	100000.00	20.02
6175	214623.333333	0.069233	31	05	2011	452	127.0.0.1	48	100000.00	20.77
6176	199100.000000	0.066367	30	06	2011	452	127.0.0.1	48	100000.00	19.91
6177	210903.333333	0.068033	31	07	2011	452	127.0.0.1	48	100000.00	20.41
6178	197780.000000	0.063800	31	08	2011	452	127.0.0.1	48	100000.00	19.14
6179	196800.000000	0.065600	30	09	2011	452	127.0.0.1	48	100000.00	19.68
6180	209146.666667	0.067467	31	10	2011	452	127.0.0.1	48	100000.00	20.24
6181	185900.000000	0.061967	30	11	2011	452	127.0.0.1	48	100000.00	18.59
6182	184966.666667	0.059667	31	12	2011	452	127.0.0.1	48	100000.00	17.90
6183	192820.000000	0.062200	31	01	2012	452	127.0.0.1	48	100000.00	18.66
6184	178253.333333	0.061467	29	02	2012	452	127.0.0.1	48	100000.00	18.44
6185	176390.000000	0.056900	31	03	2012	452	127.0.0.1	48	100000.00	17.07
6186	0.000000	0.000000	30	04	2012	452	127.0.0.1	48	100000.00	0.00
6187	0.000000	0.000000	31	05	2012	452	127.0.0.1	48	100000.00	0.00
6188	0.000000	0.000000	30	06	2012	452	127.0.0.1	48	100000.00	0.00
6189	0.000000	0.000000	31	07	2012	452	127.0.0.1	48	100000.00	0.00
6190	0.000000	0.000000	31	08	2012	452	127.0.0.1	48	100000.00	0.00
6191	0.000000	0.000000	30	09	2012	452	127.0.0.1	48	100000.00	0.00
6192	0.000000	0.000000	31	10	2012	452	127.0.0.1	48	100000.00	0.00
6193	0.000000	0.000000	30	11	2012	452	127.0.0.1	48	100000.00	0.00
6194	0.000000	0.000000	31	12	2012	452	127.0.0.1	48	100000.00	0.00
6195	151486.666667	0.048867	31	01	2013	452	127.0.0.1	48	100000.00	14.66
6196	144386.666667	0.051567	28	02	2013	452	127.0.0.1	48	100000.00	15.47
6197	153863.333333	0.049633	31	03	2013	452	127.0.0.1	48	100000.00	14.89
6198	150900.000000	0.050300	30	04	2013	452	127.0.0.1	48	100000.00	15.09
6199	155723.333333	0.050233	31	05	2013	452	127.0.0.1	48	100000.00	15.07
6200	148800.000000	0.049600	30	06	2013	452	127.0.0.1	48	100000.00	14.88
6201	0.000000	0.000000	31	07	2013	452	127.0.0.1	48	100000.00	\N
6202	0.000000	0.000000	31	08	2013	452	127.0.0.1	48	100000.00	\N
6203	0.000000	0.000000	30	09	2013	452	127.0.0.1	48	100000.00	\N
6204	0.000000	0.000000	31	10	2013	452	127.0.0.1	48	100000.00	\N
6205	0.000000	0.000000	12	11	2013	452	127.0.0.1	48	100000.00	\N
6206	12390.000000	0.082600	10	06	2008	453	127.0.0.1	48	15000.00	24.78
6207	40052.000000	0.086133	31	07	2008	453	127.0.0.1	48	15000.00	25.84
6208	38889.500000	0.083633	31	08	2008	453	127.0.0.1	48	15000.00	25.09
6209	37080.000000	0.082400	30	09	2008	453	127.0.0.1	48	15000.00	24.72
6210	37882.000000	0.081467	31	10	2008	453	127.0.0.1	48	15000.00	24.44
6211	37320.000000	0.082933	30	11	2008	453	127.0.0.1	48	15000.00	24.88
6212	36146.000000	0.077733	31	12	2008	453	127.0.0.1	48	15000.00	23.32
6213	40935.500000	0.088033	31	01	2009	453	127.0.0.1	48	15000.00	26.41
6214	37646.000000	0.089633	28	02	2009	453	127.0.0.1	48	15000.00	26.89
6215	40098.500000	0.086233	31	03	2009	453	127.0.0.1	48	15000.00	25.87
6216	36975.000000	0.082167	30	04	2009	453	127.0.0.1	48	15000.00	24.65
6217	37262.000000	0.080133	31	05	2009	453	127.0.0.1	48	15000.00	24.04
6218	33630.000000	0.074733	30	06	2009	453	127.0.0.1	48	15000.00	22.42
6219	34565.000000	0.074333	31	07	2009	453	127.0.0.1	48	15000.00	22.30
6220	34580.500000	0.074367	31	08	2009	453	127.0.0.1	48	15000.00	22.31
6221	31305.000000	0.069567	30	09	2009	453	127.0.0.1	48	15000.00	20.87
6222	34038.000000	0.073200	31	10	2009	453	127.0.0.1	48	15000.00	21.96
6223	32430.000000	0.072067	30	11	2009	453	127.0.0.1	48	15000.00	21.62
6224	33681.500000	0.072433	31	12	2009	453	127.0.0.1	48	15000.00	21.73
6225	32860.000000	0.070667	31	01	2010	453	127.0.0.1	48	15000.00	21.20
6226	31220.000000	0.074333	28	02	2010	453	127.0.0.1	48	15000.00	22.30
6227	32395.000000	0.069667	31	03	2010	453	127.0.0.1	48	15000.00	20.90
6228	31785.000000	0.070633	30	04	2010	453	127.0.0.1	48	15000.00	21.19
6229	31558.000000	0.067867	31	05	2010	453	127.0.0.1	48	15000.00	20.36
6230	30630.000000	0.068067	30	06	2010	453	127.0.0.1	48	15000.00	20.42
6231	31465.000000	0.067667	31	07	2010	453	127.0.0.1	48	15000.00	20.30
6232	31015.500000	0.066700	31	08	2010	453	127.0.0.1	48	15000.00	20.01
6233	31530.000000	0.070067	30	09	2010	453	127.0.0.1	48	15000.00	21.02
6234	30349.000000	0.065267	31	10	2010	453	127.0.0.1	48	15000.00	19.58
6235	30060.000000	0.066800	30	11	2010	453	127.0.0.1	48	15000.00	20.04
6236	31062.000000	0.066800	31	12	2010	453	127.0.0.1	48	15000.00	20.04
6237	30736.500000	0.066100	31	01	2011	453	127.0.0.1	48	15000.00	19.83
6238	27860.000000	0.066333	28	02	2011	453	127.0.0.1	48	15000.00	19.90
6239	30814.000000	0.066267	31	03	2011	453	127.0.0.1	48	15000.00	19.88
6240	30030.000000	0.066733	30	04	2011	453	127.0.0.1	48	15000.00	20.02
6241	32193.500000	0.069233	31	05	2011	453	127.0.0.1	48	15000.00	20.77
6242	29865.000000	0.066367	30	06	2011	453	127.0.0.1	48	15000.00	19.91
6243	31635.500000	0.068033	31	07	2011	453	127.0.0.1	48	15000.00	20.41
6244	29667.000000	0.063800	31	08	2011	453	127.0.0.1	48	15000.00	19.14
6245	29520.000000	0.065600	30	09	2011	453	127.0.0.1	48	15000.00	19.68
6246	31372.000000	0.067467	31	10	2011	453	127.0.0.1	48	15000.00	20.24
6247	27885.000000	0.061967	30	11	2011	453	127.0.0.1	48	15000.00	18.59
6248	27745.000000	0.059667	31	12	2011	453	127.0.0.1	48	15000.00	17.90
6249	28923.000000	0.062200	31	01	2012	453	127.0.0.1	48	15000.00	18.66
6250	26738.000000	0.061467	29	02	2012	453	127.0.0.1	48	15000.00	18.44
6251	26458.500000	0.056900	31	03	2012	453	127.0.0.1	48	15000.00	17.07
6252	0.000000	0.000000	30	04	2012	453	127.0.0.1	48	15000.00	0.00
6253	0.000000	0.000000	31	05	2012	453	127.0.0.1	48	15000.00	0.00
6254	0.000000	0.000000	30	06	2012	453	127.0.0.1	48	15000.00	0.00
6255	0.000000	0.000000	31	07	2012	453	127.0.0.1	48	15000.00	0.00
6256	0.000000	0.000000	31	08	2012	453	127.0.0.1	48	15000.00	0.00
6257	0.000000	0.000000	30	09	2012	453	127.0.0.1	48	15000.00	0.00
6258	0.000000	0.000000	31	10	2012	453	127.0.0.1	48	15000.00	0.00
6259	0.000000	0.000000	30	11	2012	453	127.0.0.1	48	15000.00	0.00
6260	0.000000	0.000000	31	12	2012	453	127.0.0.1	48	15000.00	0.00
6261	22723.000000	0.048867	31	01	2013	453	127.0.0.1	48	15000.00	14.66
6262	21658.000000	0.051567	28	02	2013	453	127.0.0.1	48	15000.00	15.47
6263	23079.500000	0.049633	31	03	2013	453	127.0.0.1	48	15000.00	14.89
6264	22635.000000	0.050300	30	04	2013	453	127.0.0.1	48	15000.00	15.09
6265	23358.500000	0.050233	31	05	2013	453	127.0.0.1	48	15000.00	15.07
6266	22320.000000	0.049600	30	06	2013	453	127.0.0.1	48	15000.00	14.88
6267	0.000000	0.000000	31	07	2013	453	127.0.0.1	48	15000.00	\N
6268	0.000000	0.000000	31	08	2013	453	127.0.0.1	48	15000.00	\N
6269	0.000000	0.000000	30	09	2013	453	127.0.0.1	48	15000.00	\N
6270	0.000000	0.000000	31	10	2013	453	127.0.0.1	48	15000.00	\N
6271	0.000000	0.000000	12	11	2013	453	127.0.0.1	48	15000.00	\N
6272	1722666.666667	0.086133	10	07	2008	454	127.0.0.1	48	2000000.00	25.84
6273	5185266.666667	0.083633	31	08	2008	454	127.0.0.1	48	2000000.00	25.09
6274	4944000.000000	0.082400	30	09	2008	454	127.0.0.1	48	2000000.00	24.72
6275	5050933.333333	0.081467	31	10	2008	454	127.0.0.1	48	2000000.00	24.44
6276	4976000.000000	0.082933	30	11	2008	454	127.0.0.1	48	2000000.00	24.88
6277	4819466.666667	0.077733	31	12	2008	454	127.0.0.1	48	2000000.00	23.32
6278	5458066.666667	0.088033	31	01	2009	454	127.0.0.1	48	2000000.00	26.41
6279	5019466.666667	0.089633	28	02	2009	454	127.0.0.1	48	2000000.00	26.89
6280	5346466.666667	0.086233	31	03	2009	454	127.0.0.1	48	2000000.00	25.87
6281	4930000.000000	0.082167	30	04	2009	454	127.0.0.1	48	2000000.00	24.65
6282	4968266.666667	0.080133	31	05	2009	454	127.0.0.1	48	2000000.00	24.04
6283	4484000.000000	0.074733	30	06	2009	454	127.0.0.1	48	2000000.00	22.42
6284	4608666.666667	0.074333	31	07	2009	454	127.0.0.1	48	2000000.00	22.30
6285	4610733.333333	0.074367	31	08	2009	454	127.0.0.1	48	2000000.00	22.31
6286	4174000.000000	0.069567	30	09	2009	454	127.0.0.1	48	2000000.00	20.87
6287	4538400.000000	0.073200	31	10	2009	454	127.0.0.1	48	2000000.00	21.96
6288	4324000.000000	0.072067	30	11	2009	454	127.0.0.1	48	2000000.00	21.62
6289	4490866.666667	0.072433	31	12	2009	454	127.0.0.1	48	2000000.00	21.73
6290	4381333.333333	0.070667	31	01	2010	454	127.0.0.1	48	2000000.00	21.20
6291	4162666.666667	0.074333	28	02	2010	454	127.0.0.1	48	2000000.00	22.30
6292	4319333.333333	0.069667	31	03	2010	454	127.0.0.1	48	2000000.00	20.90
6293	4238000.000000	0.070633	30	04	2010	454	127.0.0.1	48	2000000.00	21.19
6294	4207733.333333	0.067867	31	05	2010	454	127.0.0.1	48	2000000.00	20.36
6295	4084000.000000	0.068067	30	06	2010	454	127.0.0.1	48	2000000.00	20.42
6296	4195333.333333	0.067667	31	07	2010	454	127.0.0.1	48	2000000.00	20.30
6297	4135400.000000	0.066700	31	08	2010	454	127.0.0.1	48	2000000.00	20.01
6298	4204000.000000	0.070067	30	09	2010	454	127.0.0.1	48	2000000.00	21.02
6299	4046533.333333	0.065267	31	10	2010	454	127.0.0.1	48	2000000.00	19.58
6300	4008000.000000	0.066800	30	11	2010	454	127.0.0.1	48	2000000.00	20.04
6301	4141600.000000	0.066800	31	12	2010	454	127.0.0.1	48	2000000.00	20.04
6302	4098200.000000	0.066100	31	01	2011	454	127.0.0.1	48	2000000.00	19.83
6303	3714666.666667	0.066333	28	02	2011	454	127.0.0.1	48	2000000.00	19.90
6304	4108533.333333	0.066267	31	03	2011	454	127.0.0.1	48	2000000.00	19.88
6305	4004000.000000	0.066733	30	04	2011	454	127.0.0.1	48	2000000.00	20.02
6306	4292466.666667	0.069233	31	05	2011	454	127.0.0.1	48	2000000.00	20.77
6307	3982000.000000	0.066367	30	06	2011	454	127.0.0.1	48	2000000.00	19.91
6308	4218066.666667	0.068033	31	07	2011	454	127.0.0.1	48	2000000.00	20.41
6309	3955600.000000	0.063800	31	08	2011	454	127.0.0.1	48	2000000.00	19.14
6310	3936000.000000	0.065600	30	09	2011	454	127.0.0.1	48	2000000.00	19.68
6311	4182933.333333	0.067467	31	10	2011	454	127.0.0.1	48	2000000.00	20.24
6312	3718000.000000	0.061967	30	11	2011	454	127.0.0.1	48	2000000.00	18.59
6313	3699333.333333	0.059667	31	12	2011	454	127.0.0.1	48	2000000.00	17.90
6314	3856400.000000	0.062200	31	01	2012	454	127.0.0.1	48	2000000.00	18.66
6315	3565066.666667	0.061467	29	02	2012	454	127.0.0.1	48	2000000.00	18.44
6316	3527800.000000	0.056900	31	03	2012	454	127.0.0.1	48	2000000.00	17.07
6317	0.000000	0.000000	30	04	2012	454	127.0.0.1	48	2000000.00	0.00
6318	0.000000	0.000000	31	05	2012	454	127.0.0.1	48	2000000.00	0.00
6319	0.000000	0.000000	30	06	2012	454	127.0.0.1	48	2000000.00	0.00
6320	0.000000	0.000000	31	07	2012	454	127.0.0.1	48	2000000.00	0.00
6321	0.000000	0.000000	31	08	2012	454	127.0.0.1	48	2000000.00	0.00
6322	0.000000	0.000000	30	09	2012	454	127.0.0.1	48	2000000.00	0.00
6323	0.000000	0.000000	31	10	2012	454	127.0.0.1	48	2000000.00	0.00
6324	0.000000	0.000000	30	11	2012	454	127.0.0.1	48	2000000.00	0.00
6325	0.000000	0.000000	31	12	2012	454	127.0.0.1	48	2000000.00	0.00
6326	3029733.333333	0.048867	31	01	2013	454	127.0.0.1	48	2000000.00	14.66
6327	2887733.333333	0.051567	28	02	2013	454	127.0.0.1	48	2000000.00	15.47
6328	3077266.666667	0.049633	31	03	2013	454	127.0.0.1	48	2000000.00	14.89
6329	3018000.000000	0.050300	30	04	2013	454	127.0.0.1	48	2000000.00	15.09
6330	3114466.666667	0.050233	31	05	2013	454	127.0.0.1	48	2000000.00	15.07
6331	2976000.000000	0.049600	30	06	2013	454	127.0.0.1	48	2000000.00	14.88
6332	0.000000	0.000000	31	07	2013	454	127.0.0.1	48	2000000.00	\N
6333	0.000000	0.000000	31	08	2013	454	127.0.0.1	48	2000000.00	\N
6334	0.000000	0.000000	30	09	2013	454	127.0.0.1	48	2000000.00	\N
6335	0.000000	0.000000	31	10	2013	454	127.0.0.1	48	2000000.00	\N
6336	0.000000	0.000000	12	11	2013	454	127.0.0.1	48	2000000.00	\N
6337	188175.000000	0.083633	9	08	2008	455	127.0.0.1	48	250000.00	25.09
6338	618000.000000	0.082400	30	09	2008	455	127.0.0.1	48	250000.00	24.72
6339	631366.666667	0.081467	31	10	2008	455	127.0.0.1	48	250000.00	24.44
6340	622000.000000	0.082933	30	11	2008	455	127.0.0.1	48	250000.00	24.88
6341	602433.333333	0.077733	31	12	2008	455	127.0.0.1	48	250000.00	23.32
6342	682258.333333	0.088033	31	01	2009	455	127.0.0.1	48	250000.00	26.41
6343	627433.333333	0.089633	28	02	2009	455	127.0.0.1	48	250000.00	26.89
6344	668308.333333	0.086233	31	03	2009	455	127.0.0.1	48	250000.00	25.87
6345	616250.000000	0.082167	30	04	2009	455	127.0.0.1	48	250000.00	24.65
6346	621033.333333	0.080133	31	05	2009	455	127.0.0.1	48	250000.00	24.04
6347	560500.000000	0.074733	30	06	2009	455	127.0.0.1	48	250000.00	22.42
6348	576083.333333	0.074333	31	07	2009	455	127.0.0.1	48	250000.00	22.30
6349	576341.666667	0.074367	31	08	2009	455	127.0.0.1	48	250000.00	22.31
6350	521750.000000	0.069567	30	09	2009	455	127.0.0.1	48	250000.00	20.87
6351	567300.000000	0.073200	31	10	2009	455	127.0.0.1	48	250000.00	21.96
6352	540500.000000	0.072067	30	11	2009	455	127.0.0.1	48	250000.00	21.62
6353	561358.333333	0.072433	31	12	2009	455	127.0.0.1	48	250000.00	21.73
6354	547666.666667	0.070667	31	01	2010	455	127.0.0.1	48	250000.00	21.20
6355	520333.333333	0.074333	28	02	2010	455	127.0.0.1	48	250000.00	22.30
6356	539916.666667	0.069667	31	03	2010	455	127.0.0.1	48	250000.00	20.90
6357	529750.000000	0.070633	30	04	2010	455	127.0.0.1	48	250000.00	21.19
6358	525966.666667	0.067867	31	05	2010	455	127.0.0.1	48	250000.00	20.36
6359	510500.000000	0.068067	30	06	2010	455	127.0.0.1	48	250000.00	20.42
6360	524416.666667	0.067667	31	07	2010	455	127.0.0.1	48	250000.00	20.30
6361	516925.000000	0.066700	31	08	2010	455	127.0.0.1	48	250000.00	20.01
6362	525500.000000	0.070067	30	09	2010	455	127.0.0.1	48	250000.00	21.02
6363	505816.666667	0.065267	31	10	2010	455	127.0.0.1	48	250000.00	19.58
6364	501000.000000	0.066800	30	11	2010	455	127.0.0.1	48	250000.00	20.04
6365	517700.000000	0.066800	31	12	2010	455	127.0.0.1	48	250000.00	20.04
6366	512275.000000	0.066100	31	01	2011	455	127.0.0.1	48	250000.00	19.83
6367	464333.333333	0.066333	28	02	2011	455	127.0.0.1	48	250000.00	19.90
6368	513566.666667	0.066267	31	03	2011	455	127.0.0.1	48	250000.00	19.88
6369	500500.000000	0.066733	30	04	2011	455	127.0.0.1	48	250000.00	20.02
6370	536558.333333	0.069233	31	05	2011	455	127.0.0.1	48	250000.00	20.77
6371	497750.000000	0.066367	30	06	2011	455	127.0.0.1	48	250000.00	19.91
6372	527258.333333	0.068033	31	07	2011	455	127.0.0.1	48	250000.00	20.41
6373	494450.000000	0.063800	31	08	2011	455	127.0.0.1	48	250000.00	19.14
6374	492000.000000	0.065600	30	09	2011	455	127.0.0.1	48	250000.00	19.68
6375	522866.666667	0.067467	31	10	2011	455	127.0.0.1	48	250000.00	20.24
6376	464750.000000	0.061967	30	11	2011	455	127.0.0.1	48	250000.00	18.59
6377	462416.666667	0.059667	31	12	2011	455	127.0.0.1	48	250000.00	17.90
6378	482050.000000	0.062200	31	01	2012	455	127.0.0.1	48	250000.00	18.66
6379	445633.333333	0.061467	29	02	2012	455	127.0.0.1	48	250000.00	18.44
6380	440975.000000	0.056900	31	03	2012	455	127.0.0.1	48	250000.00	17.07
6381	0.000000	0.000000	30	04	2012	455	127.0.0.1	48	250000.00	0.00
6382	0.000000	0.000000	31	05	2012	455	127.0.0.1	48	250000.00	0.00
6383	0.000000	0.000000	30	06	2012	455	127.0.0.1	48	250000.00	0.00
6384	0.000000	0.000000	31	07	2012	455	127.0.0.1	48	250000.00	0.00
6385	0.000000	0.000000	31	08	2012	455	127.0.0.1	48	250000.00	0.00
6386	0.000000	0.000000	30	09	2012	455	127.0.0.1	48	250000.00	0.00
6387	0.000000	0.000000	31	10	2012	455	127.0.0.1	48	250000.00	0.00
6388	0.000000	0.000000	30	11	2012	455	127.0.0.1	48	250000.00	0.00
6389	0.000000	0.000000	31	12	2012	455	127.0.0.1	48	250000.00	0.00
6390	378716.666667	0.048867	31	01	2013	455	127.0.0.1	48	250000.00	14.66
6391	360966.666667	0.051567	28	02	2013	455	127.0.0.1	48	250000.00	15.47
6392	384658.333333	0.049633	31	03	2013	455	127.0.0.1	48	250000.00	14.89
6393	377250.000000	0.050300	30	04	2013	455	127.0.0.1	48	250000.00	15.09
6394	389308.333333	0.050233	31	05	2013	455	127.0.0.1	48	250000.00	15.07
6395	372000.000000	0.049600	30	06	2013	455	127.0.0.1	48	250000.00	14.88
6396	0.000000	0.000000	31	07	2013	455	127.0.0.1	48	250000.00	\N
6397	0.000000	0.000000	31	08	2013	455	127.0.0.1	48	250000.00	\N
6398	0.000000	0.000000	30	09	2013	455	127.0.0.1	48	250000.00	\N
6399	0.000000	0.000000	31	10	2013	455	127.0.0.1	48	250000.00	\N
6400	0.000000	0.000000	12	11	2013	455	127.0.0.1	48	250000.00	\N
6401	271920.000000	0.082400	11	09	2008	456	127.0.0.1	48	300000.00	24.72
6402	757640.000000	0.081467	31	10	2008	456	127.0.0.1	48	300000.00	24.44
6403	746400.000000	0.082933	30	11	2008	456	127.0.0.1	48	300000.00	24.88
6404	722920.000000	0.077733	31	12	2008	456	127.0.0.1	48	300000.00	23.32
6405	818710.000000	0.088033	31	01	2009	456	127.0.0.1	48	300000.00	26.41
6406	752920.000000	0.089633	28	02	2009	456	127.0.0.1	48	300000.00	26.89
6407	801970.000000	0.086233	31	03	2009	456	127.0.0.1	48	300000.00	25.87
6408	739500.000000	0.082167	30	04	2009	456	127.0.0.1	48	300000.00	24.65
6409	745240.000000	0.080133	31	05	2009	456	127.0.0.1	48	300000.00	24.04
6410	672600.000000	0.074733	30	06	2009	456	127.0.0.1	48	300000.00	22.42
6411	691300.000000	0.074333	31	07	2009	456	127.0.0.1	48	300000.00	22.30
6412	691610.000000	0.074367	31	08	2009	456	127.0.0.1	48	300000.00	22.31
6413	626100.000000	0.069567	30	09	2009	456	127.0.0.1	48	300000.00	20.87
6414	680760.000000	0.073200	31	10	2009	456	127.0.0.1	48	300000.00	21.96
6415	648600.000000	0.072067	30	11	2009	456	127.0.0.1	48	300000.00	21.62
6416	673630.000000	0.072433	31	12	2009	456	127.0.0.1	48	300000.00	21.73
6417	657200.000000	0.070667	31	01	2010	456	127.0.0.1	48	300000.00	21.20
6418	624400.000000	0.074333	28	02	2010	456	127.0.0.1	48	300000.00	22.30
6419	647900.000000	0.069667	31	03	2010	456	127.0.0.1	48	300000.00	20.90
6420	635700.000000	0.070633	30	04	2010	456	127.0.0.1	48	300000.00	21.19
6421	631160.000000	0.067867	31	05	2010	456	127.0.0.1	48	300000.00	20.36
6422	612600.000000	0.068067	30	06	2010	456	127.0.0.1	48	300000.00	20.42
6423	629300.000000	0.067667	31	07	2010	456	127.0.0.1	48	300000.00	20.30
6424	620310.000000	0.066700	31	08	2010	456	127.0.0.1	48	300000.00	20.01
6425	630600.000000	0.070067	30	09	2010	456	127.0.0.1	48	300000.00	21.02
6426	606980.000000	0.065267	31	10	2010	456	127.0.0.1	48	300000.00	19.58
6427	601200.000000	0.066800	30	11	2010	456	127.0.0.1	48	300000.00	20.04
6428	621240.000000	0.066800	31	12	2010	456	127.0.0.1	48	300000.00	20.04
6429	614730.000000	0.066100	31	01	2011	456	127.0.0.1	48	300000.00	19.83
6430	557200.000000	0.066333	28	02	2011	456	127.0.0.1	48	300000.00	19.90
6431	616280.000000	0.066267	31	03	2011	456	127.0.0.1	48	300000.00	19.88
6432	600600.000000	0.066733	30	04	2011	456	127.0.0.1	48	300000.00	20.02
6433	643870.000000	0.069233	31	05	2011	456	127.0.0.1	48	300000.00	20.77
6434	597300.000000	0.066367	30	06	2011	456	127.0.0.1	48	300000.00	19.91
6435	632710.000000	0.068033	31	07	2011	456	127.0.0.1	48	300000.00	20.41
6436	593340.000000	0.063800	31	08	2011	456	127.0.0.1	48	300000.00	19.14
6437	590400.000000	0.065600	30	09	2011	456	127.0.0.1	48	300000.00	19.68
6438	627440.000000	0.067467	31	10	2011	456	127.0.0.1	48	300000.00	20.24
6439	557700.000000	0.061967	30	11	2011	456	127.0.0.1	48	300000.00	18.59
6440	554900.000000	0.059667	31	12	2011	456	127.0.0.1	48	300000.00	17.90
6441	578460.000000	0.062200	31	01	2012	456	127.0.0.1	48	300000.00	18.66
6442	534760.000000	0.061467	29	02	2012	456	127.0.0.1	48	300000.00	18.44
6443	529170.000000	0.056900	31	03	2012	456	127.0.0.1	48	300000.00	17.07
6444	0.000000	0.000000	30	04	2012	456	127.0.0.1	48	300000.00	0.00
6445	0.000000	0.000000	31	05	2012	456	127.0.0.1	48	300000.00	0.00
6446	0.000000	0.000000	30	06	2012	456	127.0.0.1	48	300000.00	0.00
6447	0.000000	0.000000	31	07	2012	456	127.0.0.1	48	300000.00	0.00
6448	0.000000	0.000000	31	08	2012	456	127.0.0.1	48	300000.00	0.00
6449	0.000000	0.000000	30	09	2012	456	127.0.0.1	48	300000.00	0.00
6450	0.000000	0.000000	31	10	2012	456	127.0.0.1	48	300000.00	0.00
6451	0.000000	0.000000	30	11	2012	456	127.0.0.1	48	300000.00	0.00
6452	0.000000	0.000000	31	12	2012	456	127.0.0.1	48	300000.00	0.00
6453	454460.000000	0.048867	31	01	2013	456	127.0.0.1	48	300000.00	14.66
6454	433160.000000	0.051567	28	02	2013	456	127.0.0.1	48	300000.00	15.47
6455	461590.000000	0.049633	31	03	2013	456	127.0.0.1	48	300000.00	14.89
6456	452700.000000	0.050300	30	04	2013	456	127.0.0.1	48	300000.00	15.09
6457	467170.000000	0.050233	31	05	2013	456	127.0.0.1	48	300000.00	15.07
6458	446400.000000	0.049600	30	06	2013	456	127.0.0.1	48	300000.00	14.88
6459	0.000000	0.000000	31	07	2013	456	127.0.0.1	48	300000.00	\N
6460	0.000000	0.000000	31	08	2013	456	127.0.0.1	48	300000.00	\N
6461	0.000000	0.000000	30	09	2013	456	127.0.0.1	48	300000.00	\N
6462	0.000000	0.000000	31	10	2013	456	127.0.0.1	48	300000.00	\N
6463	0.000000	0.000000	12	11	2013	456	127.0.0.1	48	300000.00	\N
6464	407333.333333	0.081467	10	10	2008	457	127.0.0.1	48	500000.00	24.44
6465	1244000.000000	0.082933	30	11	2008	457	127.0.0.1	48	500000.00	24.88
6466	1204866.666667	0.077733	31	12	2008	457	127.0.0.1	48	500000.00	23.32
6467	1364516.666667	0.088033	31	01	2009	457	127.0.0.1	48	500000.00	26.41
6468	1254866.666667	0.089633	28	02	2009	457	127.0.0.1	48	500000.00	26.89
6469	1336616.666667	0.086233	31	03	2009	457	127.0.0.1	48	500000.00	25.87
6470	1232500.000000	0.082167	30	04	2009	457	127.0.0.1	48	500000.00	24.65
6471	1242066.666667	0.080133	31	05	2009	457	127.0.0.1	48	500000.00	24.04
6472	1121000.000000	0.074733	30	06	2009	457	127.0.0.1	48	500000.00	22.42
6473	1152166.666667	0.074333	31	07	2009	457	127.0.0.1	48	500000.00	22.30
6474	1152683.333333	0.074367	31	08	2009	457	127.0.0.1	48	500000.00	22.31
6475	1043500.000000	0.069567	30	09	2009	457	127.0.0.1	48	500000.00	20.87
6476	1134600.000000	0.073200	31	10	2009	457	127.0.0.1	48	500000.00	21.96
6477	1081000.000000	0.072067	30	11	2009	457	127.0.0.1	48	500000.00	21.62
6478	1122716.666667	0.072433	31	12	2009	457	127.0.0.1	48	500000.00	21.73
6479	1095333.333333	0.070667	31	01	2010	457	127.0.0.1	48	500000.00	21.20
6480	1040666.666667	0.074333	28	02	2010	457	127.0.0.1	48	500000.00	22.30
6481	1079833.333333	0.069667	31	03	2010	457	127.0.0.1	48	500000.00	20.90
6482	1059500.000000	0.070633	30	04	2010	457	127.0.0.1	48	500000.00	21.19
6483	1051933.333333	0.067867	31	05	2010	457	127.0.0.1	48	500000.00	20.36
6484	1021000.000000	0.068067	30	06	2010	457	127.0.0.1	48	500000.00	20.42
6485	1048833.333333	0.067667	31	07	2010	457	127.0.0.1	48	500000.00	20.30
6486	1033850.000000	0.066700	31	08	2010	457	127.0.0.1	48	500000.00	20.01
6487	1051000.000000	0.070067	30	09	2010	457	127.0.0.1	48	500000.00	21.02
6488	1011633.333333	0.065267	31	10	2010	457	127.0.0.1	48	500000.00	19.58
6489	1002000.000000	0.066800	30	11	2010	457	127.0.0.1	48	500000.00	20.04
6490	1035400.000000	0.066800	31	12	2010	457	127.0.0.1	48	500000.00	20.04
6491	1024550.000000	0.066100	31	01	2011	457	127.0.0.1	48	500000.00	19.83
6492	928666.666667	0.066333	28	02	2011	457	127.0.0.1	48	500000.00	19.90
6493	1027133.333333	0.066267	31	03	2011	457	127.0.0.1	48	500000.00	19.88
6494	1001000.000000	0.066733	30	04	2011	457	127.0.0.1	48	500000.00	20.02
6495	1073116.666667	0.069233	31	05	2011	457	127.0.0.1	48	500000.00	20.77
6496	995500.000000	0.066367	30	06	2011	457	127.0.0.1	48	500000.00	19.91
6497	1054516.666667	0.068033	31	07	2011	457	127.0.0.1	48	500000.00	20.41
6498	988900.000000	0.063800	31	08	2011	457	127.0.0.1	48	500000.00	19.14
6499	984000.000000	0.065600	30	09	2011	457	127.0.0.1	48	500000.00	19.68
6500	1045733.333333	0.067467	31	10	2011	457	127.0.0.1	48	500000.00	20.24
6501	929500.000000	0.061967	30	11	2011	457	127.0.0.1	48	500000.00	18.59
6502	924833.333333	0.059667	31	12	2011	457	127.0.0.1	48	500000.00	17.90
6503	964100.000000	0.062200	31	01	2012	457	127.0.0.1	48	500000.00	18.66
6504	891266.666667	0.061467	29	02	2012	457	127.0.0.1	48	500000.00	18.44
6505	881950.000000	0.056900	31	03	2012	457	127.0.0.1	48	500000.00	17.07
6506	0.000000	0.000000	30	04	2012	457	127.0.0.1	48	500000.00	0.00
6507	0.000000	0.000000	31	05	2012	457	127.0.0.1	48	500000.00	0.00
6508	0.000000	0.000000	30	06	2012	457	127.0.0.1	48	500000.00	0.00
6509	0.000000	0.000000	31	07	2012	457	127.0.0.1	48	500000.00	0.00
6510	0.000000	0.000000	31	08	2012	457	127.0.0.1	48	500000.00	0.00
6511	0.000000	0.000000	30	09	2012	457	127.0.0.1	48	500000.00	0.00
6512	0.000000	0.000000	31	10	2012	457	127.0.0.1	48	500000.00	0.00
6513	0.000000	0.000000	30	11	2012	457	127.0.0.1	48	500000.00	0.00
6514	0.000000	0.000000	31	12	2012	457	127.0.0.1	48	500000.00	0.00
6515	757433.333333	0.048867	31	01	2013	457	127.0.0.1	48	500000.00	14.66
6516	721933.333333	0.051567	28	02	2013	457	127.0.0.1	48	500000.00	15.47
6517	769316.666667	0.049633	31	03	2013	457	127.0.0.1	48	500000.00	14.89
6518	754500.000000	0.050300	30	04	2013	457	127.0.0.1	48	500000.00	15.09
6519	778616.666667	0.050233	31	05	2013	457	127.0.0.1	48	500000.00	15.07
6520	744000.000000	0.049600	30	06	2013	457	127.0.0.1	48	500000.00	14.88
6521	0.000000	0.000000	31	07	2013	457	127.0.0.1	48	500000.00	\N
6522	0.000000	0.000000	31	08	2013	457	127.0.0.1	48	500000.00	\N
6523	0.000000	0.000000	30	09	2013	457	127.0.0.1	48	500000.00	\N
6524	0.000000	0.000000	31	10	2013	457	127.0.0.1	48	500000.00	\N
6525	0.000000	0.000000	12	11	2013	457	127.0.0.1	48	500000.00	\N
6526	3358800.000000	0.082933	9	11	2008	458	127.0.0.1	48	4500000.00	24.88
6527	10843800.000000	0.077733	31	12	2008	458	127.0.0.1	48	4500000.00	23.32
6528	12280650.000000	0.088033	31	01	2009	458	127.0.0.1	48	4500000.00	26.41
6529	11293800.000000	0.089633	28	02	2009	458	127.0.0.1	48	4500000.00	26.89
6530	12029550.000000	0.086233	31	03	2009	458	127.0.0.1	48	4500000.00	25.87
6531	11092500.000000	0.082167	30	04	2009	458	127.0.0.1	48	4500000.00	24.65
6532	11178600.000000	0.080133	31	05	2009	458	127.0.0.1	48	4500000.00	24.04
6533	10089000.000000	0.074733	30	06	2009	458	127.0.0.1	48	4500000.00	22.42
6534	10369500.000000	0.074333	31	07	2009	458	127.0.0.1	48	4500000.00	22.30
6535	10374150.000000	0.074367	31	08	2009	458	127.0.0.1	48	4500000.00	22.31
6536	9391500.000000	0.069567	30	09	2009	458	127.0.0.1	48	4500000.00	20.87
6537	10211400.000000	0.073200	31	10	2009	458	127.0.0.1	48	4500000.00	21.96
6538	9729000.000000	0.072067	30	11	2009	458	127.0.0.1	48	4500000.00	21.62
6539	10104450.000000	0.072433	31	12	2009	458	127.0.0.1	48	4500000.00	21.73
6540	9858000.000000	0.070667	31	01	2010	458	127.0.0.1	48	4500000.00	21.20
6541	9366000.000000	0.074333	28	02	2010	458	127.0.0.1	48	4500000.00	22.30
6542	9718500.000000	0.069667	31	03	2010	458	127.0.0.1	48	4500000.00	20.90
6543	9535500.000000	0.070633	30	04	2010	458	127.0.0.1	48	4500000.00	21.19
6544	9467400.000000	0.067867	31	05	2010	458	127.0.0.1	48	4500000.00	20.36
6545	9189000.000000	0.068067	30	06	2010	458	127.0.0.1	48	4500000.00	20.42
6546	9439500.000000	0.067667	31	07	2010	458	127.0.0.1	48	4500000.00	20.30
6547	9304650.000000	0.066700	31	08	2010	458	127.0.0.1	48	4500000.00	20.01
6548	9459000.000000	0.070067	30	09	2010	458	127.0.0.1	48	4500000.00	21.02
6549	9104700.000000	0.065267	31	10	2010	458	127.0.0.1	48	4500000.00	19.58
6550	9018000.000000	0.066800	30	11	2010	458	127.0.0.1	48	4500000.00	20.04
6551	9318600.000000	0.066800	31	12	2010	458	127.0.0.1	48	4500000.00	20.04
6552	9220950.000000	0.066100	31	01	2011	458	127.0.0.1	48	4500000.00	19.83
6553	8358000.000000	0.066333	28	02	2011	458	127.0.0.1	48	4500000.00	19.90
6554	9244200.000000	0.066267	31	03	2011	458	127.0.0.1	48	4500000.00	19.88
6555	9009000.000000	0.066733	30	04	2011	458	127.0.0.1	48	4500000.00	20.02
6556	9658050.000000	0.069233	31	05	2011	458	127.0.0.1	48	4500000.00	20.77
6557	8959500.000000	0.066367	30	06	2011	458	127.0.0.1	48	4500000.00	19.91
6558	9490650.000000	0.068033	31	07	2011	458	127.0.0.1	48	4500000.00	20.41
6559	8900100.000000	0.063800	31	08	2011	458	127.0.0.1	48	4500000.00	19.14
6560	8856000.000000	0.065600	30	09	2011	458	127.0.0.1	48	4500000.00	19.68
6561	9411600.000000	0.067467	31	10	2011	458	127.0.0.1	48	4500000.00	20.24
6562	8365500.000000	0.061967	30	11	2011	458	127.0.0.1	48	4500000.00	18.59
6563	8323500.000000	0.059667	31	12	2011	458	127.0.0.1	48	4500000.00	17.90
6564	8676900.000000	0.062200	31	01	2012	458	127.0.0.1	48	4500000.00	18.66
6565	8021400.000000	0.061467	29	02	2012	458	127.0.0.1	48	4500000.00	18.44
6566	7937550.000000	0.056900	31	03	2012	458	127.0.0.1	48	4500000.00	17.07
6567	0.000000	0.000000	30	04	2012	458	127.0.0.1	48	4500000.00	0.00
6568	0.000000	0.000000	31	05	2012	458	127.0.0.1	48	4500000.00	0.00
6569	0.000000	0.000000	30	06	2012	458	127.0.0.1	48	4500000.00	0.00
6570	0.000000	0.000000	31	07	2012	458	127.0.0.1	48	4500000.00	0.00
6571	0.000000	0.000000	31	08	2012	458	127.0.0.1	48	4500000.00	0.00
6572	0.000000	0.000000	30	09	2012	458	127.0.0.1	48	4500000.00	0.00
6573	0.000000	0.000000	31	10	2012	458	127.0.0.1	48	4500000.00	0.00
6574	0.000000	0.000000	30	11	2012	458	127.0.0.1	48	4500000.00	0.00
6575	0.000000	0.000000	31	12	2012	458	127.0.0.1	48	4500000.00	0.00
6576	6816900.000000	0.048867	31	01	2013	458	127.0.0.1	48	4500000.00	14.66
6577	6497400.000000	0.051567	28	02	2013	458	127.0.0.1	48	4500000.00	15.47
6578	6923850.000000	0.049633	31	03	2013	458	127.0.0.1	48	4500000.00	14.89
6579	6790500.000000	0.050300	30	04	2013	458	127.0.0.1	48	4500000.00	15.09
6580	7007550.000000	0.050233	31	05	2013	458	127.0.0.1	48	4500000.00	15.07
6581	6696000.000000	0.049600	30	06	2013	458	127.0.0.1	48	4500000.00	14.88
6582	0.000000	0.000000	31	07	2013	458	127.0.0.1	48	4500000.00	\N
6583	0.000000	0.000000	31	08	2013	458	127.0.0.1	48	4500000.00	\N
6584	0.000000	0.000000	30	09	2013	458	127.0.0.1	48	4500000.00	\N
6585	0.000000	0.000000	31	10	2013	458	127.0.0.1	48	4500000.00	\N
6586	0.000000	0.000000	12	11	2013	458	127.0.0.1	48	4500000.00	\N
6587	34980000.000000	0.077733	9	12	2008	459	127.0.0.1	48	50000000.00	23.32
6588	136451666.666670	0.088033	31	01	2009	459	127.0.0.1	48	50000000.00	26.41
6589	125486666.666670	0.089633	28	02	2009	459	127.0.0.1	48	50000000.00	26.89
6590	133661666.666670	0.086233	31	03	2009	459	127.0.0.1	48	50000000.00	25.87
6591	123250000.000000	0.082167	30	04	2009	459	127.0.0.1	48	50000000.00	24.65
6592	124206666.666670	0.080133	31	05	2009	459	127.0.0.1	48	50000000.00	24.04
6593	112100000.000000	0.074733	30	06	2009	459	127.0.0.1	48	50000000.00	22.42
6594	115216666.666670	0.074333	31	07	2009	459	127.0.0.1	48	50000000.00	22.30
6595	115268333.333330	0.074367	31	08	2009	459	127.0.0.1	48	50000000.00	22.31
6596	104350000.000000	0.069567	30	09	2009	459	127.0.0.1	48	50000000.00	20.87
6597	113460000.000000	0.073200	31	10	2009	459	127.0.0.1	48	50000000.00	21.96
6598	108100000.000000	0.072067	30	11	2009	459	127.0.0.1	48	50000000.00	21.62
6599	112271666.666670	0.072433	31	12	2009	459	127.0.0.1	48	50000000.00	21.73
6600	109533333.333330	0.070667	31	01	2010	459	127.0.0.1	48	50000000.00	21.20
6601	104066666.666670	0.074333	28	02	2010	459	127.0.0.1	48	50000000.00	22.30
6602	107983333.333330	0.069667	31	03	2010	459	127.0.0.1	48	50000000.00	20.90
6603	105950000.000000	0.070633	30	04	2010	459	127.0.0.1	48	50000000.00	21.19
6604	105193333.333330	0.067867	31	05	2010	459	127.0.0.1	48	50000000.00	20.36
6605	102100000.000000	0.068067	30	06	2010	459	127.0.0.1	48	50000000.00	20.42
6606	104883333.333330	0.067667	31	07	2010	459	127.0.0.1	48	50000000.00	20.30
6607	103385000.000000	0.066700	31	08	2010	459	127.0.0.1	48	50000000.00	20.01
6608	105100000.000000	0.070067	30	09	2010	459	127.0.0.1	48	50000000.00	21.02
6609	101163333.333330	0.065267	31	10	2010	459	127.0.0.1	48	50000000.00	19.58
6610	100200000.000000	0.066800	30	11	2010	459	127.0.0.1	48	50000000.00	20.04
6611	103540000.000000	0.066800	31	12	2010	459	127.0.0.1	48	50000000.00	20.04
6612	102455000.000000	0.066100	31	01	2011	459	127.0.0.1	48	50000000.00	19.83
6613	92866666.666667	0.066333	28	02	2011	459	127.0.0.1	48	50000000.00	19.90
6614	102713333.333330	0.066267	31	03	2011	459	127.0.0.1	48	50000000.00	19.88
6615	100100000.000000	0.066733	30	04	2011	459	127.0.0.1	48	50000000.00	20.02
6616	107311666.666670	0.069233	31	05	2011	459	127.0.0.1	48	50000000.00	20.77
6617	99550000.000000	0.066367	30	06	2011	459	127.0.0.1	48	50000000.00	19.91
6618	105451666.666670	0.068033	31	07	2011	459	127.0.0.1	48	50000000.00	20.41
6619	98890000.000000	0.063800	31	08	2011	459	127.0.0.1	48	50000000.00	19.14
6620	98400000.000000	0.065600	30	09	2011	459	127.0.0.1	48	50000000.00	19.68
6621	104573333.333330	0.067467	31	10	2011	459	127.0.0.1	48	50000000.00	20.24
6622	92950000.000000	0.061967	30	11	2011	459	127.0.0.1	48	50000000.00	18.59
6623	92483333.333333	0.059667	31	12	2011	459	127.0.0.1	48	50000000.00	17.90
6624	96410000.000000	0.062200	31	01	2012	459	127.0.0.1	48	50000000.00	18.66
6625	89126666.666667	0.061467	29	02	2012	459	127.0.0.1	48	50000000.00	18.44
6626	88195000.000000	0.056900	31	03	2012	459	127.0.0.1	48	50000000.00	17.07
6627	0.000000	0.000000	30	04	2012	459	127.0.0.1	48	50000000.00	0.00
6628	0.000000	0.000000	31	05	2012	459	127.0.0.1	48	50000000.00	0.00
6629	0.000000	0.000000	30	06	2012	459	127.0.0.1	48	50000000.00	0.00
6630	0.000000	0.000000	31	07	2012	459	127.0.0.1	48	50000000.00	0.00
6631	0.000000	0.000000	31	08	2012	459	127.0.0.1	48	50000000.00	0.00
6632	0.000000	0.000000	30	09	2012	459	127.0.0.1	48	50000000.00	0.00
6633	0.000000	0.000000	31	10	2012	459	127.0.0.1	48	50000000.00	0.00
6634	0.000000	0.000000	30	11	2012	459	127.0.0.1	48	50000000.00	0.00
6635	0.000000	0.000000	31	12	2012	459	127.0.0.1	48	50000000.00	0.00
6636	75743333.333333	0.048867	31	01	2013	459	127.0.0.1	48	50000000.00	14.66
6637	72193333.333333	0.051567	28	02	2013	459	127.0.0.1	48	50000000.00	15.47
6638	76931666.666667	0.049633	31	03	2013	459	127.0.0.1	48	50000000.00	14.89
6639	75450000.000000	0.050300	30	04	2013	459	127.0.0.1	48	50000000.00	15.09
6640	77861666.666667	0.050233	31	05	2013	459	127.0.0.1	48	50000000.00	15.07
6641	74400000.000000	0.049600	30	06	2013	459	127.0.0.1	48	50000000.00	14.88
6642	0.000000	0.000000	31	07	2013	459	127.0.0.1	48	50000000.00	\N
6643	0.000000	0.000000	31	08	2013	459	127.0.0.1	48	50000000.00	\N
6644	0.000000	0.000000	30	09	2013	459	127.0.0.1	48	50000000.00	\N
6645	0.000000	0.000000	31	10	2013	459	127.0.0.1	48	50000000.00	\N
6646	0.000000	0.000000	12	11	2013	459	127.0.0.1	48	50000000.00	\N
6647	39179235.000000	0.088033	9	01	2009	460	127.0.0.1	48	49450000.00	26.41
6648	124106313.333330	0.089633	28	02	2009	460	127.0.0.1	48	49450000.00	26.89
6649	132191388.333330	0.086233	31	03	2009	460	127.0.0.1	48	49450000.00	25.87
6650	121894250.000000	0.082167	30	04	2009	460	127.0.0.1	48	49450000.00	24.65
6651	122840393.333330	0.080133	31	05	2009	460	127.0.0.1	48	49450000.00	24.04
6652	110866900.000000	0.074733	30	06	2009	460	127.0.0.1	48	49450000.00	22.42
6653	113949283.333330	0.074333	31	07	2009	460	127.0.0.1	48	49450000.00	22.30
6654	114000381.666670	0.074367	31	08	2009	460	127.0.0.1	48	49450000.00	22.31
6655	103202150.000000	0.069567	30	09	2009	460	127.0.0.1	48	49450000.00	20.87
6656	112211940.000000	0.073200	31	10	2009	460	127.0.0.1	48	49450000.00	21.96
6657	106910900.000000	0.072067	30	11	2009	460	127.0.0.1	48	49450000.00	21.62
6658	111036678.333330	0.072433	31	12	2009	460	127.0.0.1	48	49450000.00	21.73
6659	108328466.666670	0.070667	31	01	2010	460	127.0.0.1	48	49450000.00	21.20
6660	102921933.333330	0.074333	28	02	2010	460	127.0.0.1	48	49450000.00	22.30
6661	106795516.666670	0.069667	31	03	2010	460	127.0.0.1	48	49450000.00	20.90
6662	104784550.000000	0.070633	30	04	2010	460	127.0.0.1	48	49450000.00	21.19
6663	104036206.666670	0.067867	31	05	2010	460	127.0.0.1	48	49450000.00	20.36
6664	100976900.000000	0.068067	30	06	2010	460	127.0.0.1	48	49450000.00	20.42
6665	103729616.666670	0.067667	31	07	2010	460	127.0.0.1	48	49450000.00	20.30
6666	102247765.000000	0.066700	31	08	2010	460	127.0.0.1	48	49450000.00	20.01
6667	103943900.000000	0.070067	30	09	2010	460	127.0.0.1	48	49450000.00	21.02
6668	100050536.666670	0.065267	31	10	2010	460	127.0.0.1	48	49450000.00	19.58
6669	99097800.000000	0.066800	30	11	2010	460	127.0.0.1	48	49450000.00	20.04
6670	102401060.000000	0.066800	31	12	2010	460	127.0.0.1	48	49450000.00	20.04
6671	101327995.000000	0.066100	31	01	2011	460	127.0.0.1	48	49450000.00	19.83
6672	91845133.333333	0.066333	28	02	2011	460	127.0.0.1	48	49450000.00	19.90
6673	101583486.666670	0.066267	31	03	2011	460	127.0.0.1	48	49450000.00	19.88
6674	98998900.000000	0.066733	30	04	2011	460	127.0.0.1	48	49450000.00	20.02
6675	106131238.333330	0.069233	31	05	2011	460	127.0.0.1	48	49450000.00	20.77
6676	98454950.000000	0.066367	30	06	2011	460	127.0.0.1	48	49450000.00	19.91
6677	104291698.333330	0.068033	31	07	2011	460	127.0.0.1	48	49450000.00	20.41
6678	97802210.000000	0.063800	31	08	2011	460	127.0.0.1	48	49450000.00	19.14
6679	97317600.000000	0.065600	30	09	2011	460	127.0.0.1	48	49450000.00	19.68
6680	103423026.666670	0.067467	31	10	2011	460	127.0.0.1	48	49450000.00	20.24
6681	91927550.000000	0.061967	30	11	2011	460	127.0.0.1	48	49450000.00	18.59
6682	91466016.666667	0.059667	31	12	2011	460	127.0.0.1	48	49450000.00	17.90
6683	95349490.000000	0.062200	31	01	2012	460	127.0.0.1	48	49450000.00	18.66
6684	88146273.333333	0.061467	29	02	2012	460	127.0.0.1	48	49450000.00	18.44
6685	87224855.000000	0.056900	31	03	2012	460	127.0.0.1	48	49450000.00	17.07
6686	0.000000	0.000000	30	04	2012	460	127.0.0.1	48	49450000.00	0.00
6687	0.000000	0.000000	31	05	2012	460	127.0.0.1	48	49450000.00	0.00
6688	0.000000	0.000000	30	06	2012	460	127.0.0.1	48	49450000.00	0.00
6689	0.000000	0.000000	31	07	2012	460	127.0.0.1	48	49450000.00	0.00
6690	0.000000	0.000000	31	08	2012	460	127.0.0.1	48	49450000.00	0.00
6691	0.000000	0.000000	30	09	2012	460	127.0.0.1	48	49450000.00	0.00
6692	0.000000	0.000000	31	10	2012	460	127.0.0.1	48	49450000.00	0.00
6693	0.000000	0.000000	30	11	2012	460	127.0.0.1	48	49450000.00	0.00
6694	0.000000	0.000000	31	12	2012	460	127.0.0.1	48	49450000.00	0.00
6695	74910156.666667	0.048867	31	01	2013	460	127.0.0.1	48	49450000.00	14.66
6696	71399206.666667	0.051567	28	02	2013	460	127.0.0.1	48	49450000.00	15.47
6697	76085418.333333	0.049633	31	03	2013	460	127.0.0.1	48	49450000.00	14.89
6698	74620050.000000	0.050300	30	04	2013	460	127.0.0.1	48	49450000.00	15.09
6699	77005188.333333	0.050233	31	05	2013	460	127.0.0.1	48	49450000.00	15.07
6700	73581600.000000	0.049600	30	06	2013	460	127.0.0.1	48	49450000.00	14.88
6701	0.000000	0.000000	31	07	2013	460	127.0.0.1	48	49450000.00	\N
6702	0.000000	0.000000	31	08	2013	460	127.0.0.1	48	49450000.00	\N
6703	0.000000	0.000000	30	09	2013	460	127.0.0.1	48	49450000.00	\N
6704	0.000000	0.000000	31	10	2013	460	127.0.0.1	48	49450000.00	\N
6705	0.000000	0.000000	12	11	2013	460	127.0.0.1	48	49450000.00	\N
6706	1332208.864000	0.061467	15	02	2012	461	127.0.0.1	48	1444912.00	18.44
6707	2548680.276800	0.056900	31	03	2012	461	127.0.0.1	48	1444912.00	17.07
6708	0.000000	0.000000	30	04	2012	461	127.0.0.1	48	1444912.00	0.00
6709	0.000000	0.000000	31	05	2012	461	127.0.0.1	48	1444912.00	0.00
6710	0.000000	0.000000	30	06	2012	461	127.0.0.1	48	1444912.00	0.00
6711	0.000000	0.000000	31	07	2012	461	127.0.0.1	48	1444912.00	0.00
6712	0.000000	0.000000	31	08	2012	461	127.0.0.1	48	1444912.00	0.00
6713	0.000000	0.000000	30	09	2012	461	127.0.0.1	48	1444912.00	0.00
6714	0.000000	0.000000	31	10	2012	461	127.0.0.1	48	1444912.00	0.00
6715	0.000000	0.000000	30	11	2012	461	127.0.0.1	48	1444912.00	0.00
6716	0.000000	0.000000	31	12	2012	461	127.0.0.1	48	1444912.00	0.00
6717	2188849.025067	0.048867	31	01	2013	461	127.0.0.1	48	1444912.00	14.66
6718	2086260.273067	0.051567	28	02	2013	461	127.0.0.1	48	1444912.00	15.47
6719	2223189.766933	0.049633	31	03	2013	461	127.0.0.1	48	1444912.00	14.89
6720	2180372.208000	0.050300	30	04	2013	461	127.0.0.1	48	1444912.00	15.09
6721	2250065.130133	0.050233	31	05	2013	461	127.0.0.1	48	1444912.00	15.07
6722	2150029.056000	0.049600	30	06	2013	461	127.0.0.1	48	1444912.00	14.88
6723	0.000000	0.000000	31	07	2013	461	127.0.0.1	48	1444912.00	\N
6724	0.000000	0.000000	31	08	2013	461	127.0.0.1	48	1444912.00	\N
6725	0.000000	0.000000	30	09	2013	461	127.0.0.1	48	1444912.00	\N
6726	0.000000	0.000000	31	10	2013	461	127.0.0.1	48	1444912.00	\N
6727	0.000000	0.000000	12	11	2013	461	127.0.0.1	48	1444912.00	\N
6728	773.500000	0.051567	3	02	2013	462	127.0.0.1	48	5000.00	15.47
6729	7693.166667	0.049633	31	03	2013	462	127.0.0.1	48	5000.00	14.89
6730	7545.000000	0.050300	30	04	2013	462	127.0.0.1	48	5000.00	15.09
6731	7786.166667	0.050233	31	05	2013	462	127.0.0.1	48	5000.00	15.07
6732	7440.000000	0.049600	30	06	2013	462	127.0.0.1	48	5000.00	14.88
6733	0.000000	0.000000	31	07	2013	462	127.0.0.1	48	5000.00	\N
6734	0.000000	0.000000	31	08	2013	462	127.0.0.1	48	5000.00	\N
6735	0.000000	0.000000	30	09	2013	462	127.0.0.1	48	5000.00	\N
6736	0.000000	0.000000	31	10	2013	462	127.0.0.1	48	5000.00	\N
6737	0.000000	0.000000	12	11	2013	462	127.0.0.1	48	5000.00	\N
6738	0.000000	0.000000	6	07	2012	463	127.0.0.1	48	50000.00	0.00
6739	0.000000	0.000000	31	08	2012	463	127.0.0.1	48	50000.00	0.00
6740	0.000000	0.000000	30	09	2012	463	127.0.0.1	48	50000.00	0.00
6741	0.000000	0.000000	31	10	2012	463	127.0.0.1	48	50000.00	0.00
6742	0.000000	0.000000	30	11	2012	463	127.0.0.1	48	50000.00	0.00
6743	0.000000	0.000000	31	12	2012	463	127.0.0.1	48	50000.00	0.00
6744	75743.333333	0.048867	31	01	2013	463	127.0.0.1	48	50000.00	14.66
6745	72193.333333	0.051567	28	02	2013	463	127.0.0.1	48	50000.00	15.47
6746	76931.666667	0.049633	31	03	2013	463	127.0.0.1	48	50000.00	14.89
6747	75450.000000	0.050300	30	04	2013	463	127.0.0.1	48	50000.00	15.09
6748	77861.666667	0.050233	31	05	2013	463	127.0.0.1	48	50000.00	15.07
6749	74400.000000	0.049600	30	06	2013	463	127.0.0.1	48	50000.00	14.88
6750	0.000000	0.000000	31	07	2013	463	127.0.0.1	48	50000.00	\N
6751	0.000000	0.000000	31	08	2013	463	127.0.0.1	48	50000.00	\N
6752	0.000000	0.000000	30	09	2013	463	127.0.0.1	48	50000.00	\N
6753	0.000000	0.000000	31	10	2013	463	127.0.0.1	48	50000.00	\N
6754	0.000000	0.000000	13	11	2013	463	127.0.0.1	48	50000.00	\N
6755	40186.666667	0.050233	8	05	2013	464	127.0.0.1	48	100000.00	15.07
6756	148800.000000	0.049600	30	06	2013	464	127.0.0.1	48	100000.00	14.88
6757	0.000000	0.000000	31	07	2013	464	127.0.0.1	48	100000.00	\N
6758	0.000000	0.000000	31	08	2013	464	127.0.0.1	48	100000.00	\N
6759	0.000000	0.000000	30	09	2013	464	127.0.0.1	48	100000.00	\N
6760	0.000000	0.000000	31	10	2013	464	127.0.0.1	48	100000.00	\N
6761	0.000000	0.000000	13	11	2013	464	127.0.0.1	48	100000.00	\N
6762	2012.000000	0.050300	8	04	2013	465	127.0.0.1	48	5000.00	15.09
6763	7786.166667	0.050233	31	05	2013	465	127.0.0.1	48	5000.00	15.07
6764	7440.000000	0.049600	30	06	2013	465	127.0.0.1	48	5000.00	14.88
6765	0.000000	0.000000	31	07	2013	465	127.0.0.1	48	5000.00	\N
6766	0.000000	0.000000	31	08	2013	465	127.0.0.1	48	5000.00	\N
6767	0.000000	0.000000	30	09	2013	465	127.0.0.1	48	5000.00	\N
6768	0.000000	0.000000	31	10	2013	465	127.0.0.1	48	5000.00	\N
6769	0.000000	0.000000	13	11	2013	465	127.0.0.1	48	5000.00	\N
6792	232166.666667	0.066333	14	02	2011	467	127.0.0.1	48	250000.00	19.90
6793	513566.666667	0.066267	31	03	2011	467	127.0.0.1	48	250000.00	19.88
6794	500500.000000	0.066733	30	04	2011	467	127.0.0.1	48	250000.00	20.02
6795	536558.333333	0.069233	31	05	2011	467	127.0.0.1	48	250000.00	20.77
6796	497750.000000	0.066367	30	06	2011	467	127.0.0.1	48	250000.00	19.91
6797	527258.333333	0.068033	31	07	2011	467	127.0.0.1	48	250000.00	20.41
6798	494450.000000	0.063800	31	08	2011	467	127.0.0.1	48	250000.00	19.14
6799	492000.000000	0.065600	30	09	2011	467	127.0.0.1	48	250000.00	19.68
6800	522866.666667	0.067467	31	10	2011	467	127.0.0.1	48	250000.00	20.24
6801	464750.000000	0.061967	30	11	2011	467	127.0.0.1	48	250000.00	18.59
6802	462416.666667	0.059667	31	12	2011	467	127.0.0.1	48	250000.00	17.90
6803	0.000000	0.000000	31	01	13	467	127.0.0.1	48	250000.00	\N
6804	0.000000	0.000000	28	02	13	467	127.0.0.1	48	250000.00	\N
6805	0.000000	0.000000	31	03	13	467	127.0.0.1	48	250000.00	\N
6806	0.000000	0.000000	30	04	13	467	127.0.0.1	48	250000.00	\N
6807	0.000000	0.000000	31	05	13	467	127.0.0.1	48	250000.00	\N
6808	0.000000	0.000000	30	06	13	467	127.0.0.1	48	250000.00	\N
6809	0.000000	0.000000	31	07	13	467	127.0.0.1	48	250000.00	\N
6810	0.000000	0.000000	31	08	13	467	127.0.0.1	48	250000.00	\N
6811	0.000000	0.000000	30	09	13	467	127.0.0.1	48	250000.00	\N
6812	0.000000	0.000000	31	10	13	467	127.0.0.1	48	250000.00	\N
6813	0.000000	0.000000	2013	11	13	467	127.0.0.1	48	250000.00	\N
6814	0.000000	0.000000	10	10	2013	468	127.0.0.1	48	9500.00	\N
6815	0.000000	0.000000	13	11	2013	468	127.0.0.1	48	9500.00	\N
6816	4288.050000	0.048867	9	01	2013	469	127.0.0.1	48	9750.00	14.66
6817	14077.700000	0.051567	28	02	2013	469	127.0.0.1	48	9750.00	15.47
6818	15001.675000	0.049633	31	03	2013	469	127.0.0.1	48	9750.00	14.89
6819	14712.750000	0.050300	30	04	2013	469	127.0.0.1	48	9750.00	15.09
6820	15183.025000	0.050233	31	05	2013	469	127.0.0.1	48	9750.00	15.07
6821	14508.000000	0.049600	30	06	2013	469	127.0.0.1	48	9750.00	14.88
6822	0.000000	0.000000	31	07	2013	469	127.0.0.1	48	9750.00	\N
6823	0.000000	0.000000	31	08	2013	469	127.0.0.1	48	9750.00	\N
6824	0.000000	0.000000	30	09	2013	469	127.0.0.1	48	9750.00	\N
6825	0.000000	0.000000	31	10	2013	469	127.0.0.1	48	9750.00	\N
6826	0.000000	0.000000	13	11	2013	469	127.0.0.1	48	9750.00	\N
6827	565.875000	0.050300	15	04	2013	470	127.0.0.1	48	750.00	15.09
6828	1167.925000	0.050233	31	05	2013	470	127.0.0.1	48	750.00	15.07
6829	1116.000000	0.049600	30	06	2013	470	127.0.0.1	48	750.00	14.88
6830	0.000000	0.000000	31	07	2013	470	127.0.0.1	48	750.00	\N
6831	0.000000	0.000000	31	08	2013	470	127.0.0.1	48	750.00	\N
6832	0.000000	0.000000	30	09	2013	470	127.0.0.1	48	750.00	\N
6833	0.000000	0.000000	31	10	2013	470	127.0.0.1	48	750.00	\N
6834	0.000000	0.000000	13	11	2013	470	127.0.0.1	48	750.00	\N
6835	0.000000	0.000000	16	07	2013	471	127.0.0.1	48	135000.00	\N
6836	0.000000	0.000000	31	08	2013	471	127.0.0.1	48	135000.00	\N
6837	0.000000	0.000000	30	09	2013	471	127.0.0.1	48	135000.00	\N
6838	0.000000	0.000000	31	10	2013	471	127.0.0.1	48	135000.00	\N
6839	0.000000	0.000000	13	11	2013	471	127.0.0.1	48	135000.00	\N
6840	7507.500000	0.066733	15	04	2011	472	127.0.0.1	48	7500.00	20.02
6841	16096.750000	0.069233	31	05	2011	472	127.0.0.1	48	7500.00	20.77
6842	14932.500000	0.066367	30	06	2011	472	127.0.0.1	48	7500.00	19.91
6843	15817.750000	0.068033	31	07	2011	472	127.0.0.1	48	7500.00	20.41
6844	14833.500000	0.063800	31	08	2011	472	127.0.0.1	48	7500.00	19.14
6845	14760.000000	0.065600	30	09	2011	472	127.0.0.1	48	7500.00	19.68
6846	15686.000000	0.067467	31	10	2011	472	127.0.0.1	48	7500.00	20.24
6847	13942.500000	0.061967	30	11	2011	472	127.0.0.1	48	7500.00	18.59
6848	13872.500000	0.059667	31	12	2011	472	127.0.0.1	48	7500.00	17.90
6849	14461.500000	0.062200	31	01	2012	472	127.0.0.1	48	7500.00	18.66
6850	13369.000000	0.061467	29	02	2012	472	127.0.0.1	48	7500.00	18.44
6851	13229.250000	0.056900	31	03	2012	472	127.0.0.1	48	7500.00	17.07
6852	0.000000	0.000000	30	04	2012	472	127.0.0.1	48	7500.00	0.00
6853	0.000000	0.000000	31	05	2012	472	127.0.0.1	48	7500.00	0.00
6854	0.000000	0.000000	30	06	2012	472	127.0.0.1	48	7500.00	0.00
6855	18440.000000	0.061467	6	02	2012	473	127.0.0.1	48	50000.00	18.44
6856	0.000000	0.000000	31	07	2012	472	127.0.0.1	48	7500.00	0.00
6857	0.000000	0.000000	31	08	2012	472	127.0.0.1	48	7500.00	0.00
6858	88195.000000	0.056900	31	03	2012	473	127.0.0.1	48	50000.00	17.07
6859	0.000000	0.000000	30	09	2012	472	127.0.0.1	48	7500.00	0.00
6860	0.000000	0.000000	30	04	2012	473	127.0.0.1	48	50000.00	0.00
6861	0.000000	0.000000	31	10	2012	472	127.0.0.1	48	7500.00	0.00
6862	0.000000	0.000000	31	05	2012	473	127.0.0.1	48	50000.00	0.00
6863	0.000000	0.000000	30	11	2012	472	127.0.0.1	48	7500.00	0.00
6864	0.000000	0.000000	30	06	2012	473	127.0.0.1	48	50000.00	0.00
6865	0.000000	0.000000	31	12	2012	472	127.0.0.1	48	7500.00	0.00
6866	0.000000	0.000000	31	07	2012	473	127.0.0.1	48	50000.00	0.00
6867	11361.500000	0.048867	31	01	2013	472	127.0.0.1	48	7500.00	14.66
6868	0.000000	0.000000	31	08	2012	473	127.0.0.1	48	50000.00	0.00
6869	10829.000000	0.051567	28	02	2013	472	127.0.0.1	48	7500.00	15.47
6870	0.000000	0.000000	30	09	2012	473	127.0.0.1	48	50000.00	0.00
6871	11539.750000	0.049633	31	03	2013	472	127.0.0.1	48	7500.00	14.89
6872	0.000000	0.000000	31	10	2012	473	127.0.0.1	48	50000.00	0.00
6873	11317.500000	0.050300	30	04	2013	472	127.0.0.1	48	7500.00	15.09
6874	0.000000	0.000000	30	11	2012	473	127.0.0.1	48	50000.00	0.00
6875	11679.250000	0.050233	31	05	2013	472	127.0.0.1	48	7500.00	15.07
6876	0.000000	0.000000	31	12	2012	473	127.0.0.1	48	50000.00	0.00
6877	11160.000000	0.049600	30	06	2013	472	127.0.0.1	48	7500.00	14.88
6878	0.000000	0.000000	31	07	2013	472	127.0.0.1	48	7500.00	\N
6879	0.000000	0.000000	31	08	2013	472	127.0.0.1	48	7500.00	\N
6880	0.000000	0.000000	30	09	2013	472	127.0.0.1	48	7500.00	\N
6881	0.000000	0.000000	31	10	2013	472	127.0.0.1	48	7500.00	\N
6882	0.000000	0.000000	13	11	2013	472	127.0.0.1	48	7500.00	\N
6883	75743.333333	0.048867	31	01	2013	473	127.0.0.1	48	50000.00	14.66
6884	16328.000000	0.068033	16	07	2011	474	127.0.0.1	48	15000.00	20.41
6886	29667.000000	0.063800	31	08	2011	474	127.0.0.1	48	15000.00	19.14
6888	29520.000000	0.065600	30	09	2011	474	127.0.0.1	48	15000.00	19.68
6890	31372.000000	0.067467	31	10	2011	474	127.0.0.1	48	15000.00	20.24
6892	27885.000000	0.061967	30	11	2011	474	127.0.0.1	48	15000.00	18.59
6894	27745.000000	0.059667	31	12	2011	474	127.0.0.1	48	15000.00	17.90
6896	28923.000000	0.062200	31	01	2012	474	127.0.0.1	48	15000.00	18.66
6898	26738.000000	0.061467	29	02	2012	474	127.0.0.1	48	15000.00	18.44
6900	26458.500000	0.056900	31	03	2012	474	127.0.0.1	48	15000.00	17.07
6902	0.000000	0.000000	30	04	2012	474	127.0.0.1	48	15000.00	0.00
6904	0.000000	0.000000	31	05	2012	474	127.0.0.1	48	15000.00	0.00
6905	0.000000	0.000000	30	06	2012	474	127.0.0.1	48	15000.00	0.00
6906	0.000000	0.000000	31	07	2012	474	127.0.0.1	48	15000.00	0.00
6907	0.000000	0.000000	31	08	2012	474	127.0.0.1	48	15000.00	0.00
6908	0.000000	0.000000	30	09	2012	474	127.0.0.1	48	15000.00	0.00
6910	0.000000	0.000000	31	10	2012	474	127.0.0.1	48	15000.00	0.00
6912	0.000000	0.000000	30	11	2012	474	127.0.0.1	48	15000.00	0.00
6914	0.000000	0.000000	31	12	2012	474	127.0.0.1	48	15000.00	0.00
6916	22723.000000	0.048867	31	01	2013	474	127.0.0.1	48	15000.00	14.66
6918	21658.000000	0.051567	28	02	2013	474	127.0.0.1	48	15000.00	15.47
6920	23079.500000	0.049633	31	03	2013	474	127.0.0.1	48	15000.00	14.89
6922	22635.000000	0.050300	30	04	2013	474	127.0.0.1	48	15000.00	15.09
6924	23358.500000	0.050233	31	05	2013	474	127.0.0.1	48	15000.00	15.07
6926	22320.000000	0.049600	30	06	2013	474	127.0.0.1	48	15000.00	14.88
6928	0.000000	0.000000	31	07	2013	474	127.0.0.1	48	15000.00	\N
6930	0.000000	0.000000	31	08	2013	474	127.0.0.1	48	15000.00	\N
6932	0.000000	0.000000	30	09	2013	474	127.0.0.1	48	15000.00	\N
6934	0.000000	0.000000	31	10	2013	474	127.0.0.1	48	15000.00	\N
6936	0.000000	0.000000	13	11	2013	474	127.0.0.1	48	15000.00	\N
6943	113344.000000	0.067467	14	10	2011	476	127.0.0.1	48	120000.00	20.24
6945	223080.000000	0.061967	30	11	2011	476	127.0.0.1	48	120000.00	18.59
6946	221960.000000	0.059667	31	12	2011	476	127.0.0.1	48	120000.00	17.90
6947	231384.000000	0.062200	31	01	2012	476	127.0.0.1	48	120000.00	18.66
6948	213904.000000	0.061467	29	02	2012	476	127.0.0.1	48	120000.00	18.44
6950	211668.000000	0.056900	31	03	2012	476	127.0.0.1	48	120000.00	17.07
6952	0.000000	0.000000	30	04	2012	476	127.0.0.1	48	120000.00	0.00
6954	0.000000	0.000000	31	05	2012	476	127.0.0.1	48	120000.00	0.00
6956	0.000000	0.000000	30	06	2012	476	127.0.0.1	48	120000.00	0.00
6958	0.000000	0.000000	31	07	2012	476	127.0.0.1	48	120000.00	0.00
6960	0.000000	0.000000	31	08	2012	476	127.0.0.1	48	120000.00	0.00
6962	0.000000	0.000000	30	09	2012	476	127.0.0.1	48	120000.00	0.00
6964	0.000000	0.000000	31	10	2012	476	127.0.0.1	48	120000.00	0.00
6966	0.000000	0.000000	30	11	2012	476	127.0.0.1	48	120000.00	0.00
6968	0.000000	0.000000	31	12	2012	476	127.0.0.1	48	120000.00	0.00
6970	181784.000000	0.048867	31	01	2013	476	127.0.0.1	48	120000.00	14.66
6972	173264.000000	0.051567	28	02	2013	476	127.0.0.1	48	120000.00	15.47
6974	184636.000000	0.049633	31	03	2013	476	127.0.0.1	48	120000.00	14.89
6976	181080.000000	0.050300	30	04	2013	476	127.0.0.1	48	120000.00	15.09
6978	186868.000000	0.050233	31	05	2013	476	127.0.0.1	48	120000.00	15.07
6980	178560.000000	0.049600	30	06	2013	476	127.0.0.1	48	120000.00	14.88
6982	0.000000	0.000000	31	07	2013	476	127.0.0.1	48	120000.00	\N
6984	0.000000	0.000000	31	08	2013	476	127.0.0.1	48	120000.00	\N
6986	0.000000	0.000000	30	09	2013	476	127.0.0.1	48	120000.00	\N
6988	0.000000	0.000000	31	10	2013	476	127.0.0.1	48	120000.00	\N
6989	0.000000	0.000000	13	11	2013	476	127.0.0.1	48	120000.00	\N
6992	12539.520000	0.062200	14	01	2012	479	127.0.0.1	48	14400.00	18.66
6994	25668.480000	0.061467	29	02	2012	479	127.0.0.1	48	14400.00	18.44
6996	25400.160000	0.056900	31	03	2012	479	127.0.0.1	48	14400.00	17.07
6998	0.000000	0.000000	30	04	2012	479	127.0.0.1	48	14400.00	0.00
7000	0.000000	0.000000	31	05	2012	479	127.0.0.1	48	14400.00	0.00
7002	0.000000	0.000000	30	06	2012	479	127.0.0.1	48	14400.00	0.00
7004	0.000000	0.000000	31	07	2012	479	127.0.0.1	48	14400.00	0.00
7006	0.000000	0.000000	31	08	2012	479	127.0.0.1	48	14400.00	0.00
7008	0.000000	0.000000	30	09	2012	479	127.0.0.1	48	14400.00	0.00
7010	0.000000	0.000000	31	10	2012	479	127.0.0.1	48	14400.00	0.00
7012	0.000000	0.000000	30	11	2012	479	127.0.0.1	48	14400.00	0.00
7014	0.000000	0.000000	31	12	2012	479	127.0.0.1	48	14400.00	0.00
7016	21814.080000	0.048867	31	01	2013	479	127.0.0.1	48	14400.00	14.66
7018	20791.680000	0.051567	28	02	2013	479	127.0.0.1	48	14400.00	15.47
7020	22156.320000	0.049633	31	03	2013	479	127.0.0.1	48	14400.00	14.89
7022	21729.600000	0.050300	30	04	2013	479	127.0.0.1	48	14400.00	15.09
7024	22424.160000	0.050233	31	05	2013	479	127.0.0.1	48	14400.00	15.07
7026	21427.200000	0.049600	30	06	2013	479	127.0.0.1	48	14400.00	14.88
7027	0.000000	0.000000	31	07	2013	479	127.0.0.1	48	14400.00	\N
7028	0.000000	0.000000	31	08	2013	479	127.0.0.1	48	14400.00	\N
7029	0.000000	0.000000	30	09	2013	479	127.0.0.1	48	14400.00	\N
7030	0.000000	0.000000	31	10	2013	479	127.0.0.1	48	14400.00	\N
7032	0.000000	0.000000	13	11	2013	479	127.0.0.1	48	14400.00	\N
6885	72193.333333	0.051567	28	02	2013	473	127.0.0.1	48	50000.00	15.47
6887	76931.666667	0.049633	31	03	2013	473	127.0.0.1	48	50000.00	14.89
6889	75450.000000	0.050300	30	04	2013	473	127.0.0.1	48	50000.00	15.09
6891	77861.666667	0.050233	31	05	2013	473	127.0.0.1	48	50000.00	15.07
6893	74400.000000	0.049600	30	06	2013	473	127.0.0.1	48	50000.00	14.88
6895	0.000000	0.000000	31	07	2013	473	127.0.0.1	48	50000.00	\N
6897	0.000000	0.000000	31	08	2013	473	127.0.0.1	48	50000.00	\N
6899	0.000000	0.000000	30	09	2013	473	127.0.0.1	48	50000.00	\N
6901	0.000000	0.000000	31	10	2013	473	127.0.0.1	48	50000.00	\N
6903	0.000000	0.000000	13	11	2013	473	127.0.0.1	48	50000.00	\N
6909	25605.000000	0.056900	9	03	2012	475	127.0.0.1	48	50000.00	17.07
6911	0.000000	0.000000	30	04	2012	475	127.0.0.1	48	50000.00	0.00
6913	0.000000	0.000000	31	05	2012	475	127.0.0.1	48	50000.00	0.00
6915	0.000000	0.000000	30	06	2012	475	127.0.0.1	48	50000.00	0.00
6917	0.000000	0.000000	31	07	2012	475	127.0.0.1	48	50000.00	0.00
6919	0.000000	0.000000	31	08	2012	475	127.0.0.1	48	50000.00	0.00
6921	0.000000	0.000000	30	09	2012	475	127.0.0.1	48	50000.00	0.00
6923	0.000000	0.000000	31	10	2012	475	127.0.0.1	48	50000.00	0.00
6925	0.000000	0.000000	30	11	2012	475	127.0.0.1	48	50000.00	0.00
6927	0.000000	0.000000	31	12	2012	475	127.0.0.1	48	50000.00	0.00
6929	75743.333333	0.048867	31	01	2013	475	127.0.0.1	48	50000.00	14.66
6931	72193.333333	0.051567	28	02	2013	475	127.0.0.1	48	50000.00	15.47
6933	76931.666667	0.049633	31	03	2013	475	127.0.0.1	48	50000.00	14.89
6935	75450.000000	0.050300	30	04	2013	475	127.0.0.1	48	50000.00	15.09
6937	77861.666667	0.050233	31	05	2013	475	127.0.0.1	48	50000.00	15.07
6938	74400.000000	0.049600	30	06	2013	475	127.0.0.1	48	50000.00	14.88
6939	0.000000	0.000000	31	07	2013	475	127.0.0.1	48	50000.00	\N
6940	0.000000	0.000000	31	08	2013	475	127.0.0.1	48	50000.00	\N
6941	0.000000	0.000000	30	09	2013	475	127.0.0.1	48	50000.00	\N
6942	0.000000	0.000000	31	10	2013	475	127.0.0.1	48	50000.00	\N
6944	0.000000	0.000000	13	11	2013	475	127.0.0.1	48	50000.00	\N
6949	0.000000	0.000000	5	04	2012	477	127.0.0.1	48	50000.00	0.00
6951	0.000000	0.000000	31	05	2012	477	127.0.0.1	48	50000.00	0.00
6953	0.000000	0.000000	30	06	2012	477	127.0.0.1	48	50000.00	0.00
6955	0.000000	0.000000	31	07	2012	477	127.0.0.1	48	50000.00	0.00
6957	0.000000	0.000000	31	08	2012	477	127.0.0.1	48	50000.00	0.00
6959	0.000000	0.000000	30	09	2012	477	127.0.0.1	48	50000.00	0.00
6961	0.000000	0.000000	31	10	2012	477	127.0.0.1	48	50000.00	0.00
6963	0.000000	0.000000	30	11	2012	477	127.0.0.1	48	50000.00	0.00
6965	0.000000	0.000000	31	12	2012	477	127.0.0.1	48	50000.00	0.00
6967	75743.333333	0.048867	31	01	2013	477	127.0.0.1	48	50000.00	14.66
6969	72193.333333	0.051567	28	02	2013	477	127.0.0.1	48	50000.00	15.47
6971	76931.666667	0.049633	31	03	2013	477	127.0.0.1	48	50000.00	14.89
6973	75450.000000	0.050300	30	04	2013	477	127.0.0.1	48	50000.00	15.09
6975	77861.666667	0.050233	31	05	2013	477	127.0.0.1	48	50000.00	15.07
6977	74400.000000	0.049600	30	06	2013	477	127.0.0.1	48	50000.00	14.88
6979	0.000000	0.000000	31	07	2013	477	127.0.0.1	48	50000.00	\N
6981	0.000000	0.000000	31	08	2013	477	127.0.0.1	48	50000.00	\N
6983	0.000000	0.000000	30	09	2013	477	127.0.0.1	48	50000.00	\N
6985	0.000000	0.000000	31	10	2013	477	127.0.0.1	48	50000.00	\N
6987	0.000000	0.000000	13	11	2013	477	127.0.0.1	48	50000.00	\N
6990	0.000000	0.000000	8	05	2012	478	127.0.0.1	48	50000.00	0.00
6991	0.000000	0.000000	30	06	2012	478	127.0.0.1	48	50000.00	0.00
6993	0.000000	0.000000	31	07	2012	478	127.0.0.1	48	50000.00	0.00
6995	0.000000	0.000000	31	08	2012	478	127.0.0.1	48	50000.00	0.00
6997	0.000000	0.000000	30	09	2012	478	127.0.0.1	48	50000.00	0.00
6999	0.000000	0.000000	31	10	2012	478	127.0.0.1	48	50000.00	0.00
7001	0.000000	0.000000	30	11	2012	478	127.0.0.1	48	50000.00	0.00
7003	0.000000	0.000000	31	12	2012	478	127.0.0.1	48	50000.00	0.00
7005	75743.333333	0.048867	31	01	2013	478	127.0.0.1	48	50000.00	14.66
7007	72193.333333	0.051567	28	02	2013	478	127.0.0.1	48	50000.00	15.47
7009	76931.666667	0.049633	31	03	2013	478	127.0.0.1	48	50000.00	14.89
7011	75450.000000	0.050300	30	04	2013	478	127.0.0.1	48	50000.00	15.09
7013	77861.666667	0.050233	31	05	2013	478	127.0.0.1	48	50000.00	15.07
7015	74400.000000	0.049600	30	06	2013	478	127.0.0.1	48	50000.00	14.88
7017	0.000000	0.000000	31	07	2013	478	127.0.0.1	48	50000.00	\N
7019	0.000000	0.000000	31	08	2013	478	127.0.0.1	48	50000.00	\N
7021	0.000000	0.000000	30	09	2013	478	127.0.0.1	48	50000.00	\N
7023	0.000000	0.000000	31	10	2013	478	127.0.0.1	48	50000.00	\N
7025	0.000000	0.000000	13	11	2013	478	127.0.0.1	48	50000.00	\N
7031	0.000000	0.000000	8	06	2012	480	127.0.0.1	48	50000.00	0.00
7033	0.000000	0.000000	31	07	2012	480	127.0.0.1	48	50000.00	0.00
7034	0.000000	0.000000	31	08	2012	480	127.0.0.1	48	50000.00	0.00
7035	0.000000	0.000000	30	09	2012	480	127.0.0.1	48	50000.00	0.00
7036	0.000000	0.000000	31	10	2012	480	127.0.0.1	48	50000.00	0.00
7037	0.000000	0.000000	30	11	2012	480	127.0.0.1	48	50000.00	0.00
7038	0.000000	0.000000	31	12	2012	480	127.0.0.1	48	50000.00	0.00
7039	75743.333333	0.048867	31	01	2013	480	127.0.0.1	48	50000.00	14.66
7040	72193.333333	0.051567	28	02	2013	480	127.0.0.1	48	50000.00	15.47
7041	76931.666667	0.049633	31	03	2013	480	127.0.0.1	48	50000.00	14.89
7042	75450.000000	0.050300	30	04	2013	480	127.0.0.1	48	50000.00	15.09
7043	77861.666667	0.050233	31	05	2013	480	127.0.0.1	48	50000.00	15.07
7044	74400.000000	0.049600	30	06	2013	480	127.0.0.1	48	50000.00	14.88
7045	0.000000	0.000000	31	07	2013	480	127.0.0.1	48	50000.00	\N
7046	0.000000	0.000000	31	08	2013	480	127.0.0.1	48	50000.00	\N
7047	0.000000	0.000000	30	09	2013	480	127.0.0.1	48	50000.00	\N
7048	0.000000	0.000000	31	10	2013	480	127.0.0.1	48	50000.00	\N
7049	0.000000	0.000000	13	11	2013	480	127.0.0.1	48	50000.00	\N
7050	494322.192000	0.051567	14	02	2013	481	127.0.0.1	48	684720.00	15.47
7051	1053533.016000	0.049633	31	03	2013	481	127.0.0.1	48	684720.00	14.89
7052	1033242.480000	0.050300	30	04	2013	481	127.0.0.1	48	684720.00	15.09
7053	1066268.808000	0.050233	31	05	2013	481	127.0.0.1	48	684720.00	15.07
7054	1018863.360000	0.049600	30	06	2013	481	127.0.0.1	48	684720.00	14.88
7055	0.000000	0.000000	31	07	2013	481	127.0.0.1	48	684720.00	\N
7056	0.000000	0.000000	31	08	2013	481	127.0.0.1	48	684720.00	\N
7057	0.000000	0.000000	30	09	2013	481	127.0.0.1	48	684720.00	\N
7058	0.000000	0.000000	31	10	2013	481	127.0.0.1	48	684720.00	\N
7059	0.000000	0.000000	30	11	2013	481	127.0.0.1	48	684720.00	\N
7060	0.000000	0.000000	31	12	2013	481	127.0.0.1	48	684720.00	\N
7061	0.000000	0.000000	31	01	13	481	127.0.0.1	48	684720.00	\N
7062	0.000000	0.000000	28	02	13	481	127.0.0.1	48	684720.00	\N
7063	0.000000	0.000000	31	03	13	481	127.0.0.1	48	684720.00	\N
7064	0.000000	0.000000	30	04	13	481	127.0.0.1	48	684720.00	\N
7065	0.000000	0.000000	31	05	13	481	127.0.0.1	48	684720.00	\N
7066	0.000000	0.000000	30	06	13	481	127.0.0.1	48	684720.00	\N
7067	0.000000	0.000000	31	07	13	481	127.0.0.1	48	684720.00	\N
7068	0.000000	0.000000	31	08	13	481	127.0.0.1	48	684720.00	\N
7069	0.000000	0.000000	30	09	13	481	127.0.0.1	48	684720.00	\N
7070	0.000000	0.000000	31	10	13	481	127.0.0.1	48	684720.00	\N
7071	0.000000	0.000000	2013	11	13	481	127.0.0.1	48	684720.00	\N
7072	0.000000	0.000000	16	10	2012	482	127.0.0.1	48	15000.00	0.00
7073	0.000000	0.000000	30	11	2012	482	127.0.0.1	48	15000.00	0.00
7074	0.000000	0.000000	31	12	2012	482	127.0.0.1	48	15000.00	0.00
7075	22723.000000	0.048867	31	01	2013	482	127.0.0.1	48	15000.00	14.66
7076	21658.000000	0.051567	28	02	2013	482	127.0.0.1	48	15000.00	15.47
7077	23079.500000	0.049633	31	03	2013	482	127.0.0.1	48	15000.00	14.89
7078	22635.000000	0.050300	30	04	2013	482	127.0.0.1	48	15000.00	15.09
7079	23358.500000	0.050233	31	05	2013	482	127.0.0.1	48	15000.00	15.07
7080	22320.000000	0.049600	30	06	2013	482	127.0.0.1	48	15000.00	14.88
7081	0.000000	0.000000	31	07	2013	482	127.0.0.1	48	15000.00	\N
7082	0.000000	0.000000	31	08	2013	482	127.0.0.1	48	15000.00	\N
7083	0.000000	0.000000	30	09	2013	482	127.0.0.1	48	15000.00	\N
7084	0.000000	0.000000	31	10	2013	482	127.0.0.1	48	15000.00	\N
7085	0.000000	0.000000	13	11	2013	482	127.0.0.1	48	15000.00	\N
\.


--
-- TOC entry 3969 (class 0 OID 0)
-- Dependencies: 259
-- Name: detalle_interes_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('detalle_interes_id_seq', 7085, true);


--
-- TOC entry 3970 (class 0 OID 0)
-- Dependencies: 261
-- Name: detalle_interes_id_seq1; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('detalle_interes_id_seq1', 125, true);


--
-- TOC entry 3269 (class 0 OID 128769)
-- Dependencies: 260 3321
-- Data for Name: detalle_interes_viejo; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY detalle_interes_viejo (id, intereses, tasa, dias, mes, anio, intereses_id, ip, usuarioid) FROM stdin;
37	16388.666666667\n	0.052866666666667\n	31	01	2006	80	\N	\N
38	16388.666666667\n	0.052866666666667\n	31	01	2006	80	\N	\N
39	16388.666666667	0.052866666666667	31	01	2006	80	\N	\N
58	0	0	1	4	2005	83	\N	\N
59	0	0	31	5	2005	83	\N	\N
60	0	0	30	6	2005	83	\N	\N
61	0	0	31	7	2005	83	\N	\N
62	0	0	31	8	2005	83	\N	\N
63	0	0	30	9	2005	83	\N	\N
64	0	0	31	10	2005	83	\N	\N
65	0	0	30	11	2005	83	\N	\N
66	15314	0.0494	31	12	2005	83	\N	\N
67	16388.666666667<br>	0.052866666666667<br>	31	1	2006	83	\N	\N
68	14728<br>	0.0526<br>	28	2	2006	83	\N	\N
69	15841<br>	0.0511<br>	31	3	2006	83	\N	\N
70	14930<br>	0.049766666666667<br>	30	4	2006	83	\N	\N
71	15283<br>	0.0493<br>	31	5	2006	83	\N	\N
72	14430<br>	0.0481<br>	30	6	2006	83	\N	\N
73	15541.333333333<br>	0.050133333333333<br>	31	7	2006	83	\N	\N
74	16120<br>	0.052<br>	31	8	2006	83	\N	\N
75	15200<br>	0.050666666666667<br>	30	9	2006	83	\N	\N
76	16440.333333333<br>	0.053033333333333<br>	31	10	2006	83	\N	\N
77	15950<br>	0.053166666666667<br>	30	11	2006	83	\N	\N
78	16595.333333333<br>	0.053533333333333<br>	31	12	2006	83	\N	\N
79	17432.333333333<br>	0.056233333333333<br>	31	1	2007	83	\N	\N
80	15101.333333333<br>	0.053933333333333<br>	28	2	2007	83	\N	\N
81	15872<br>	0.0512<br>	31	3	2007	83	\N	\N
82	16540<br>	0.055133333333333<br>	30	4	2007	83	\N	\N
83	17432.333333333<br>	0.056233333333333<br>	31	5	2007	83	\N	\N
84	16100<br>	0.053666666666667<br>	30	6	2007	83	\N	\N
85	17587.333333333<br>	0.056733333333333<br>	31	7	2007	83	\N	\N
86	18197<br>	0.0587<br>	31	8	2007	83	\N	\N
87	17920<br>	0.059733333333333<br>	30	9	2007	83	\N	\N
88	18651.666666667<br>	0.060166666666667<br>	31	10	2007	83	\N	\N
89	20950<br>	0.069833333333333<br>	30	11	2007	83	\N	\N
90	23849.333333333<br>	0.076933333333333<br>	31	12	2007	83	\N	\N
91	26794.333333333<br>	0.086433333333333<br>	31	1	2008	83	\N	\N
92	23847.666666667<br>	0.082233333333333<br>	29	2	2008	83	\N	\N
93	24831<br>	0.0801<br>	31	3	2008	83	\N	\N
94	24470<br>	0.081566666666667<br>	30	4	2008	83	\N	\N
95	26835.666666667<br>	0.086566666666667<br>	31	5	2008	83	\N	\N
96	24780<br>	0.0826<br>	30	6	2008	83	\N	\N
97	26701.333333333<br>	0.086133333333333<br>	31	7	2008	83	\N	\N
98	25926.333333333<br>	0.083633333333333<br>	31	8	2008	83	\N	\N
99	24720<br>	0.0824<br>	30	9	2008	83	\N	\N
100	25254.666666667<br>	0.081466666666667<br>	31	10	2008	83	\N	\N
101	24880<br>	0.082933333333333<br>	30	11	2008	83	\N	\N
102	24097.333333333<br>	0.077733333333333<br>	31	12	2008	83	\N	\N
103	27290.333333333	0.088033333333333	31	1	2009	83	\N	\N
104	25097.333333333	0.089633333333333	28	2	2009	83	\N	\N
105	26732.333333333	0.086233333333333	31	3	2009	83	\N	\N
106	24650	0.082166666666667	30	4	2009	83	\N	\N
107	24841.333333333	0.080133333333333	31	5	2009	83	\N	\N
108	22420	0.074733333333333	30	6	2009	83	\N	\N
109	23043.333333333	0.074333333333333	31	7	2009	83	\N	\N
110	23053.666666667	0.074366666666667	31	8	2009	83	\N	\N
111	20870	0.069566666666667	30	9	2009	83	\N	\N
112	22692	0.0732	31	10	2009	83	\N	\N
113	10810	0.072066666666667	15	11	2009	83	\N	\N
114	7465.3333333333	0.067866666666667	11	5	2010	84	\N	\N
115	20420	0.068066666666667	30	6	2010	84	\N	\N
116	20976.666666667	0.067666666666667	31	7	2010	84	\N	\N
117	20677	0.0667	31	8	2010	84	\N	\N
118	21020	0.070066666666667	30	9	2010	84	\N	\N
119	5221.3333333333	0.065266666666667	8	10	2010	84	\N	\N
120	0	0	11	5	2012	85	\N	\N
121	0	0	30	6	2012	85	\N	\N
122	0	0	31	7	2012	85	\N	\N
123	0	0	31	8	2012	85	\N	\N
124	0	0	30	9	2012	85	\N	\N
125	0	0	8	10	2012	85	\N	\N
\.


--
-- TOC entry 3271 (class 0 OID 128777)
-- Dependencies: 262 3321
-- Data for Name: detalles_contrib_calc; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY detalles_contrib_calc (id, declaraid, contrib_calcid, proceso, observacion) FROM stdin;
83	568	155	notificado	\N
84	580	156	notificado	\N
85	591	157	notificado	\N
86	592	158	notificado	\N
87	593	158	notificado	\N
88	595	159	\N	\N
89	594	159	\N	\N
90	596	159	\N	\N
91	597	160	\N	\N
92	598	161	\N	\N
\.


--
-- TOC entry 3971 (class 0 OID 0)
-- Dependencies: 263
-- Name: detalles_contrib_calc_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('detalles_contrib_calc_id_seq', 92, true);


--
-- TOC entry 3273 (class 0 OID 128785)
-- Dependencies: 264 3321
-- Data for Name: dettalles_fizcalizacion; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY dettalles_fizcalizacion (id, periodo, anio, base, alicuota, total, asignacionfid, bln_borrado, calpagodid, bln_reparo_faltante, bln_identificador) FROM stdin;
160	3	2008	100000	5.00	5000	963	f	110	f	t
161	4	2008	2000000	5.00	100000	963	f	111	f	t
162	5	2008	300000	5.00	15000	963	f	112	f	t
163	6	2008	40000000	5.00	2000000	963	f	113	f	t
164	7	2008	5000000	5.00	250000	963	f	114	f	t
165	8	2008	6000000	5.00	300000	963	f	115	f	t
166	9	2008	10000000	5.00	500000	963	f	116	f	t
167	10	2008	90000000	5.00	4500000	963	f	117	f	t
168	11	2008	1000000000	5.00	50000000	963	f	118	f	t
169	12	2008	989000000	5.00	49450000	963	f	119	f	t
170	2011	0	100000000	1.50	1444912	964	f	244	f	t
171	2010	0	5000000	5.00	250000	965	f	243	f	t
172	1	2011	500000	1.50	7500	967	f	288	f	t
173	2	2011	1000000	1.50	15000	967	f	289	f	t
174	3	2011	8000000	1.50	120000	967	f	290	f	t
175	4	2011	960000	1.50	14400	967	f	291	f	t
176	1	2012	1000000	5.00	50000	968	f	9	f	t
177	2	2012	1000000	5.00	50000	968	f	10	f	t
178	3	2012	1000000	5.00	50000	968	f	11	f	t
179	4	2012	1000000	5.00	50000	968	f	12	f	t
180	5	2012	1000000	5.00	50000	968	f	13	f	t
181	2012	0	50000000	1.50	684720	966	f	246	f	t
182	1	2008	1000000	5.00	50000	969	f	108	f	t
183	8	2008	5000000	5.00	250000	969	f	115	f	t
184	1	2008	1200000	5.00	120000	969	t	108	f	f
185	2	2008	1000000	5.00	5000	969	f	109	f	f
186	2009	0	800000000	1.50	11960135	970	f	240	f	t
\.


--
-- TOC entry 3972 (class 0 OID 0)
-- Dependencies: 265
-- Name: dettalles_fizcalizacion_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('dettalles_fizcalizacion_id_seq', 186, true);


--
-- TOC entry 3275 (class 0 OID 128796)
-- Dependencies: 266 3321
-- Data for Name: document; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY document (id, nombre, docu, inactivo, usfonproid, ip) FROM stdin;
\.


--
-- TOC entry 3973 (class 0 OID 0)
-- Dependencies: 267
-- Name: document_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('document_id_seq', 1, false);


--
-- TOC entry 3213 (class 0 OID 128519)
-- Dependencies: 202 3321
-- Data for Name: entidad; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY entidad (id, nombre, entidad, orden) FROM stdin;
\.


--
-- TOC entry 3211 (class 0 OID 128513)
-- Dependencies: 200 3321
-- Data for Name: entidadd; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY entidadd (id, entidadid, nombre, accion, orden) FROM stdin;
\.


--
-- TOC entry 3215 (class 0 OID 128525)
-- Dependencies: 204 3321
-- Data for Name: estados; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY estados (id, nombre, usuarioid, ip) FROM stdin;
3	DISTRITO CAPITAL	17	192.168.1.101
4	AMAZONAS	17	192.168.1.101
5	ANZOÁTEGUI	17	192.168.1.101
6	APURE	17	192.168.1.101
7	ARAGUA	17	192.168.1.101
8	BARINAS	17	192.168.1.101
9	BOLÍVAR	17	192.168.1.101
10	CARABOBO	17	192.168.1.101
11	COJEDES	17	192.168.1.101
12	DELTA AMACURO	17	192.168.1.101
13	FALCON	17	192.168.1.101
14	GUARICO	17	192.168.1.101
15	LARA	17	192.168.1.101
16	MERIDA	17	192.168.1.101
17	MIRANDA	17	192.168.1.101
18	MONAGAS	17	192.168.1.101
19	NUEVA ESPARTA	17	192.168.1.101
20	PORTUGUESA	17	192.168.1.101
21	SUCRE	17	192.168.1.101
22	TACHIRA	17	192.168.1.101
23	TRUJILLO	17	192.168.1.101
24	YARACUY	17	192.168.1.101
25	ZULIA	17	192.168.1.101
26	VARGAS	17	192.168.1.101
27	DEPENDENCIAS FEDERALES	17	192.168.1.101
\.


--
-- TOC entry 3277 (class 0 OID 128805)
-- Dependencies: 268 3321
-- Data for Name: interes_bcv; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY interes_bcv (id, anio, tasa, ip, usuarioid, mes) FROM stdin;
86	2005	14.82	192.168.1.103	17	12
96	2006	15.91	192.168.1.103	17	10
97	2006	15.95	192.168.1.103	17	11
98	2006	16.06	192.168.1.103	17	12
108	2007	18.05	192.168.1.103	17	10
109	2007	20.95	192.168.1.103	17	11
110	2007	23.08	192.168.1.103	17	12
120	2008	24.44	192.168.1.103	17	10
121	2008	24.88	192.168.1.103	17	11
122	2008	23.32	192.168.1.103	17	12
132	2009	21.96	192.168.1.103	17	10
133	2009	21.62	192.168.1.103	17	11
134	2009	21.73	192.168.1.103	17	12
144	2010	19.58	192.168.1.103	17	10
145	2010	20.04	192.168.1.103	17	11
146	2010	20.04	192.168.1.103	17	12
156	2011	20.24	192.168.1.103	17	10
157	2011	18.59	192.168.1.103	17	11
158	2011	17.90	192.168.1.103	17	12
168	2012	0.00	192.168.1.103	17	10
169	2012	0.00	192.168.1.103	17	11
170	2012	0.00	192.168.1.103	17	12
87	2006	15.86	192.168.1.103	17	01
99	2007	16.87	192.168.1.103	17	01
111	2008	25.93	192.168.1.103	17	01
123	2009	26.41	192.168.1.103	17	01
135	2010	21.20	192.168.1.103	17	01
147	2011	19.83	192.168.1.103	17	01
159	2012	18.66	192.168.1.103	17	01
88	2006	15.78	192.168.1.103	17	02
100	2007	16.18	192.168.1.103	17	02
112	2008	24.67	192.168.1.103	17	02
124	2009	26.89	192.168.1.103	17	02
136	2010	22.30	192.168.1.103	17	02
148	2011	19.90	192.168.1.103	17	02
160	2012	18.44	192.168.1.103	17	02
89	2006	15.33	192.168.1.103	17	03
101	2007	15.36	192.168.1.103	17	03
113	2008	24.03	192.168.1.103	17	03
125	2009	25.87	192.168.1.103	17	03
137	2010	20.90	192.168.1.103	17	03
149	2011	19.88	192.168.1.103	17	03
161	2012	17.07	192.168.1.103	17	03
90	2006	14.93	192.168.1.103	17	04
102	2007	16.54	192.168.1.103	17	04
114	2008	24.47	192.168.1.103	17	04
126	2009	24.65	192.168.1.103	17	04
138	2010	21.19	192.168.1.103	17	04
150	2011	20.02	192.168.1.103	17	04
162	2012	0.00	192.168.1.103	17	04
91	2006	14.79	192.168.1.103	17	05
103	2007	16.87	192.168.1.103	17	05
115	2008	25.97	192.168.1.103	17	05
127	2009	24.04	192.168.1.103	17	05
139	2010	20.36	192.168.1.103	17	05
151	2011	20.77	192.168.1.103	17	05
163	2012	0.00	192.168.1.103	17	05
92	2006	14.43	192.168.1.103	17	06
104	2007	16.10	192.168.1.103	17	06
116	2008	24.78	192.168.1.103	17	06
128	2009	22.42	192.168.1.103	17	06
140	2010	20.42	192.168.1.103	17	06
152	2011	19.91	192.168.1.103	17	06
164	2012	0.00	192.168.1.103	17	06
93	2006	15.04	192.168.1.103	17	07
105	2007	17.02	192.168.1.103	17	07
117	2008	25.84	192.168.1.103	17	07
129	2009	22.30	192.168.1.103	17	07
141	2010	20.30	192.168.1.103	17	07
153	2011	20.41	192.168.1.103	17	07
165	2012	0.00	192.168.1.103	17	07
94	2006	15.60	192.168.1.103	17	08
106	2007	17.61	192.168.1.103	17	08
118	2008	25.09	192.168.1.103	17	08
130	2009	22.31	192.168.1.103	17	08
142	2010	20.01	192.168.1.103	17	08
154	2011	19.14	192.168.1.103	17	08
166	2012	0.00	192.168.1.103	17	08
95	2006	15.20	192.168.1.103	17	09
107	2007	17.92	192.168.1.103	17	09
119	2008	24.72	192.168.1.103	17	09
131	2009	20.87	192.168.1.103	17	09
143	2010	21.02	192.168.1.103	17	09
155	2011	19.68	192.168.1.103	17	09
167	2012	0.00	192.168.1.103	17	09
171	2013	14.66	162.168.1.102	17	01
172	2013	15.47	192.168.1.102	17	02
173	2013	14.89	192.168.1.102	17	03
174	2013	15.09	192.168.1.102	17	04
175	2013	15.07	192.168.1.102	17	05
176	2013	14.88	192.168.1.102	17	06
\.


--
-- TOC entry 3278 (class 0 OID 128811)
-- Dependencies: 269 3321
-- Data for Name: interes_bcv2; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY interes_bcv2 (id, anio, tasa, ip, usuarioid, mes) FROM stdin;
90	2006	14.93	192.168.1.103	17	Abril
102	2007	16.54	192.168.1.103	17	Abril
114	2008	24.47	192.168.1.103	17	Abril
126	2009	24.65	192.168.1.103	17	Abril
138	2010	21.19	192.168.1.103	17	Abril
150	2011	20.02	192.168.1.103	17	Abril
162	2012	0.00	192.168.1.103	17	Abril
89	2006	15.33	192.168.1.103	17	Marzo
87	2006	15.86	192.168.1.103	17	Enero
99	2007	16.87	192.168.1.103	17	Enero
111	2008	25.93	192.168.1.103	17	Enero
123	2009	26.41	192.168.1.103	17	Enero
135	2010	21.20	192.168.1.103	17	Enero
147	2011	19.83	192.168.1.103	17	Enero
159	2012	18.66	192.168.1.103	17	Enero
88	2006	15.78	192.168.1.103	17	Febrero
100	2007	16.18	192.168.1.103	17	Febrero
112	2008	24.67	192.168.1.103	17	Febrero
124	2009	26.89	192.168.1.103	17	Febrero
136	2010	22.30	192.168.1.103	17	Febrero
148	2011	19.90	192.168.1.103	17	Febrero
160	2012	18.44	192.168.1.103	17	Febrero
101	2007	15.36	192.168.1.103	17	Marzo
113	2008	24.03	192.168.1.103	17	Marzo
125	2009	25.87	192.168.1.103	17	Marzo
137	2010	20.90	192.168.1.103	17	Marzo
149	2011	19.88	192.168.1.103	17	Marzo
161	2012	17.07	192.168.1.103	17	Marzo
91	2006	14.79	192.168.1.103	17	Mayo
103	2007	16.87	192.168.1.103	17	Mayo
115	2008	25.97	192.168.1.103	17	Mayo
127	2009	24.04	192.168.1.103	17	Mayo
139	2010	20.36	192.168.1.103	17	Mayo
151	2011	20.77	192.168.1.103	17	Mayo
163	2012	0.00	192.168.1.103	17	Mayo
92	2006	14.43	192.168.1.103	17	Junio
104	2007	16.10	192.168.1.103	17	Junio
116	2008	24.78	192.168.1.103	17	Junio
128	2009	22.42	192.168.1.103	17	Junio
140	2010	20.42	192.168.1.103	17	Junio
152	2011	19.91	192.168.1.103	17	Junio
164	2012	0.00	192.168.1.103	17	Junio
93	2006	15.04	192.168.1.103	17	Julio
105	2007	17.02	192.168.1.103	17	Julio
117	2008	25.84	192.168.1.103	17	Julio
129	2009	22.30	192.168.1.103	17	Julio
141	2010	20.30	192.168.1.103	17	Julio
153	2011	20.41	192.168.1.103	17	Julio
165	2012	0.00	192.168.1.103	17	Julio
95	2006	15.20	192.168.1.103	17	Septiembre
107	2007	17.92	192.168.1.103	17	Septiembre
119	2008	24.72	192.168.1.103	17	Septiembre
131	2009	20.87	192.168.1.103	17	Septiembre
143	2010	21.02	192.168.1.103	17	Septiembre
155	2011	19.68	192.168.1.103	17	Septiembre
167	2012	0.00	192.168.1.103	17	Septiembre
96	2006	15.91	192.168.1.103	17	Octubre
108	2007	18.05	192.168.1.103	17	Octubre
120	2008	24.44	192.168.1.103	17	Octubre
132	2009	21.96	192.168.1.103	17	Octubre
144	2010	19.58	192.168.1.103	17	Octubre
156	2011	20.24	192.168.1.103	17	Octubre
168	2012	0.00	192.168.1.103	17	Octubre
97	2006	15.95	192.168.1.103	17	Noviembre
109	2007	20.95	192.168.1.103	17	Noviembre
121	2008	24.88	192.168.1.103	17	Noviembre
133	2009	21.62	192.168.1.103	17	Noviembre
145	2010	20.04	192.168.1.103	17	Noviembre
157	2011	18.59	192.168.1.103	17	Noviembre
169	2012	0.00	192.168.1.103	17	Noviembre
98	2006	16.06	192.168.1.103	17	Diciembre
110	2007	23.08	192.168.1.103	17	Diciembre
122	2008	23.32	192.168.1.103	17	Diciembre
134	2009	21.73	192.168.1.103	17	Diciembre
146	2010	20.04	192.168.1.103	17	Diciembre
158	2011	17.90	192.168.1.103	17	Diciembre
170	2012	0.00	192.168.1.103	17	Diciembre
94	2006	15.60	192.168.1.103	17	Agosto
106	2007	17.61	192.168.1.103	17	Agosto
118	2008	25.09	192.168.1.103	17	Agosto
130	2009	22.31	192.168.1.103	17	Agosto
142	2010	20.01	192.168.1.103	17	Agosto
154	2011	19.14	192.168.1.103	17	Agosto
166	2012	0.00	192.168.1.103	17	Agosto
90	2006	14.93	192.168.1.103	17	Abril
102	2007	16.54	192.168.1.103	17	Abril
114	2008	24.47	192.168.1.103	17	Abril
126	2009	24.65	192.168.1.103	17	Abril
138	2010	21.19	192.168.1.103	17	Abril
150	2011	20.02	192.168.1.103	17	Abril
162	2012	0.00	192.168.1.103	17	Abril
89	2006	15.33	192.168.1.103	17	Marzo
87	2006	15.86	192.168.1.103	17	Enero
99	2007	16.87	192.168.1.103	17	Enero
111	2008	25.93	192.168.1.103	17	Enero
123	2009	26.41	192.168.1.103	17	Enero
135	2010	21.20	192.168.1.103	17	Enero
147	2011	19.83	192.168.1.103	17	Enero
159	2012	18.66	192.168.1.103	17	Enero
88	2006	15.78	192.168.1.103	17	Febrero
100	2007	16.18	192.168.1.103	17	Febrero
112	2008	24.67	192.168.1.103	17	Febrero
124	2009	26.89	192.168.1.103	17	Febrero
136	2010	22.30	192.168.1.103	17	Febrero
148	2011	19.90	192.168.1.103	17	Febrero
160	2012	18.44	192.168.1.103	17	Febrero
101	2007	15.36	192.168.1.103	17	Marzo
113	2008	24.03	192.168.1.103	17	Marzo
125	2009	25.87	192.168.1.103	17	Marzo
137	2010	20.90	192.168.1.103	17	Marzo
149	2011	19.88	192.168.1.103	17	Marzo
161	2012	17.07	192.168.1.103	17	Marzo
91	2006	14.79	192.168.1.103	17	Mayo
103	2007	16.87	192.168.1.103	17	Mayo
115	2008	25.97	192.168.1.103	17	Mayo
127	2009	24.04	192.168.1.103	17	Mayo
139	2010	20.36	192.168.1.103	17	Mayo
151	2011	20.77	192.168.1.103	17	Mayo
163	2012	0.00	192.168.1.103	17	Mayo
92	2006	14.43	192.168.1.103	17	Junio
104	2007	16.10	192.168.1.103	17	Junio
116	2008	24.78	192.168.1.103	17	Junio
128	2009	22.42	192.168.1.103	17	Junio
140	2010	20.42	192.168.1.103	17	Junio
152	2011	19.91	192.168.1.103	17	Junio
164	2012	0.00	192.168.1.103	17	Junio
93	2006	15.04	192.168.1.103	17	Julio
105	2007	17.02	192.168.1.103	17	Julio
117	2008	25.84	192.168.1.103	17	Julio
129	2009	22.30	192.168.1.103	17	Julio
141	2010	20.30	192.168.1.103	17	Julio
153	2011	20.41	192.168.1.103	17	Julio
165	2012	0.00	192.168.1.103	17	Julio
95	2006	15.20	192.168.1.103	17	Septiembre
107	2007	17.92	192.168.1.103	17	Septiembre
119	2008	24.72	192.168.1.103	17	Septiembre
131	2009	20.87	192.168.1.103	17	Septiembre
143	2010	21.02	192.168.1.103	17	Septiembre
155	2011	19.68	192.168.1.103	17	Septiembre
167	2012	0.00	192.168.1.103	17	Septiembre
96	2006	15.91	192.168.1.103	17	Octubre
108	2007	18.05	192.168.1.103	17	Octubre
120	2008	24.44	192.168.1.103	17	Octubre
132	2009	21.96	192.168.1.103	17	Octubre
144	2010	19.58	192.168.1.103	17	Octubre
156	2011	20.24	192.168.1.103	17	Octubre
168	2012	0.00	192.168.1.103	17	Octubre
97	2006	15.95	192.168.1.103	17	Noviembre
109	2007	20.95	192.168.1.103	17	Noviembre
121	2008	24.88	192.168.1.103	17	Noviembre
133	2009	21.62	192.168.1.103	17	Noviembre
145	2010	20.04	192.168.1.103	17	Noviembre
157	2011	18.59	192.168.1.103	17	Noviembre
169	2012	0.00	192.168.1.103	17	Noviembre
98	2006	16.06	192.168.1.103	17	Diciembre
110	2007	23.08	192.168.1.103	17	Diciembre
122	2008	23.32	192.168.1.103	17	Diciembre
134	2009	21.73	192.168.1.103	17	Diciembre
146	2010	20.04	192.168.1.103	17	Diciembre
158	2011	17.90	192.168.1.103	17	Diciembre
170	2012	0.00	192.168.1.103	17	Diciembre
94	2006	15.60	192.168.1.103	17	Agosto
106	2007	17.61	192.168.1.103	17	Agosto
118	2008	25.09	192.168.1.103	17	Agosto
130	2009	22.31	192.168.1.103	17	Agosto
142	2010	20.01	192.168.1.103	17	Agosto
154	2011	19.14	192.168.1.103	17	Agosto
166	2012	0.00	192.168.1.103	17	Agosto
\.


--
-- TOC entry 3974 (class 0 OID 0)
-- Dependencies: 270
-- Name: interes_bcv_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('interes_bcv_id_seq', 176, true);


--
-- TOC entry 3219 (class 0 OID 128535)
-- Dependencies: 208 3321
-- Data for Name: perusu; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY perusu (id, nombre, inactivo, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 3217 (class 0 OID 128530)
-- Dependencies: 206 3321
-- Data for Name: perusud; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY perusud (id, perusuid, entidaddid, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 3221 (class 0 OID 128541)
-- Dependencies: 210 3321
-- Data for Name: pregsecr; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY pregsecr (id, nombre, usuarioid, ip) FROM stdin;
2	¿Nombre de tú primera mascota?	17	192.168.1.103
4	¿Apellido materno?	17	192.168.1.103
5	¿Cuál es tu comida favorita?	17	192.168.1.103
6	¿Apellido paterno?	17	192.168.1.103
7	¿Modelo de tú primer teléfono móvil?	17	192.168.1.103
\.


--
-- TOC entry 3280 (class 0 OID 128819)
-- Dependencies: 271 3321
-- Data for Name: presidente; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY presidente (id, nombres, apellidos, cedula, nro_decreto, nro_gaceta, dtm_fecha_gaceta, bln_activo, usuarioid, ip) FROM stdin;
1	Alizar	Dahdah Antar	0	7.252	39.373	24-02-2010	t	48	192.168.1.102
1	Alizar	Dahdah Antar	0	7.252	39.373	24-02-2010	t	48	192.168.1.102
\.


--
-- TOC entry 3975 (class 0 OID 0)
-- Dependencies: 272
-- Name: presidente_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('presidente_id_seq', 1, true);


--
-- TOC entry 3282 (class 0 OID 128828)
-- Dependencies: 273 3321
-- Data for Name: reparos; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY reparos (id, tdeclaraid, fechaelab, montopagar, asientoid, usuarioid, ip, tipocontribuid, conusuid, bln_activo, proceso, fecha_notificacion, bln_sumario, actaid, recibido_por, asignacionid, fecha_autorizacion, fecha_requerimiento, fecha_recepcion) FROM stdin;
589	6	2013-11-12 16:03:58.273616	250000.00	\N	48	127.0.0.1	4	146	t	calculado	2013-09-12 00:00:00	t	124	3	965	2013-11-12 00:00:00	2013-11-12 00:00:00	2013-11-12 00:00:00
599	6	2013-11-13 15:08:43.122852	156900.00	\N	48	127.0.0.1	3	146	t	calculado	2013-11-13 00:00:00	f	125	3	967	2013-11-13 00:00:00	2013-11-13 00:00:00	2013-11-13 00:00:00
604	6	2013-11-13 15:13:42.598738	250000.00	\N	48	127.0.0.1	1	146	t	calculado	2013-11-13 00:00:00	f	126	2	968	2013-11-13 00:00:00	2013-11-13 00:00:00	2013-11-13 00:00:00
610	6	2013-11-13 15:24:00.88771	684720.00	\N	48	127.0.0.1	2	146	t	calculado	2013-09-02 00:00:00	t	127	3	966	2013-11-13 00:00:00	2013-11-13 00:00:00	2013-11-13 00:00:00
614	6	2013-11-14 16:58:03.942091	305000.00	\N	48	127.0.0.1	1	1	f	\N	2013-11-15 00:00:00	f	128	3	969	2013-11-14 00:00:00	2013-11-14 00:00:00	2013-11-14 00:00:00
617	6	2013-11-15 10:01:03.408378	11960135.00	\N	48	127.0.0.1	2	146	t	\N	2013-11-15 00:00:00	f	129	3	970	2013-11-15 00:00:00	2013-11-15 00:00:00	2013-11-15 00:00:00
569	2	2013-11-12 11:51:15.850271	107120000.00	\N	48	127.0.0.1	1	146	t	calculado	2013-11-12 00:00:00	f	119	3	963	2013-11-12 00:00:00	2013-11-12 00:00:00	2013-11-12 00:00:00
581	2	2013-11-12 14:58:51.338053	1444912.00	\N	48	127.0.0.1	2	146	t	calculado	2013-11-12 00:00:00	f	120	3	964	2013-11-12 00:00:00	2013-11-12 00:00:00	2013-11-12 00:00:00
\.


--
-- TOC entry 3223 (class 0 OID 128546)
-- Dependencies: 212 3321
-- Data for Name: replegal; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY replegal (id, contribuid, nombre, apellido, ci, domfiscal, estadoid, ciudadid, zonaposta, telefhab, telefofc, fax, email, pinbb, skype, cextra1, cextra2, cextra3, cextra4, cextra5, usuarioid, ip) FROM stdin;
6	146	jefferson	lara	17042979	kjfhjklasdghvksdhk	4	4	20	04120428211	04120428211	02120000000	jetox21@gmail.com	lkh6664	jeto_21	\N	\N	\N	\N	\N	17	127.0.0.1
4	145	Jefferosn Arturo	Lara molina	17042979	Carretra panamericana sector el codo los teques	17	205	0212				jetox21@gmail.com			\N	\N	\N	\N	\N	1	192.168.1.101
7	147	jefferosn	lara	17042979	chacaito av frabcisco de misranda	3	1			04120428211	02125235698	jetox21@gmail.com			\N	\N	\N	\N	\N	17	127.0.0.1
8	148	jefferson arturo 	lara molina	17042979	los teuqes 	17	205	0121	021200000	021200000	021200000	jetox21@gmail.com			\N	\N	\N	\N	\N	17	127.0.0.1
9	153	Marjorie 	Armas de Heredia	12154369	urbanización Antonio Miguel martines calle principal casa numero 20	14	151	1212	04242552362	02462569878	02464312403	marjorieaermas@gmail.com			\N	\N	\N	\N	\N	17	127.0.0.1
\.


--
-- TOC entry 3225 (class 0 OID 128554)
-- Dependencies: 214 3321
-- Data for Name: tdeclara; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY tdeclara (id, nombre, tipo, usuarioid, ip) FROM stdin;
2	AUTOLIQUIDACION	0	17	192.168.1.101
3	SUSTITUTIVA	0	17	192.168.1.102
4	MULTA POR PAGO EXTEMPORANEO	1	17	192.168.1.101
5	MULTA POR CULMINATORIA DE FISCALIZACION	2	17	192.168.1.101
8	MULTA POR SUMARIO	3	17	192.168.1.102
6	AUTOLIQUIDACION POR REPARO FIZCAL	4	17	192.168.1.102
\.


--
-- TOC entry 3227 (class 0 OID 128559)
-- Dependencies: 216 3321
-- Data for Name: tipegrav; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY tipegrav (id, nombre, tipe, peano, usuarioid, ip) FROM stdin;
1	PERIODO GRAVABLE DE EXHIBIDORES	0	12	16	192.168.1.102
2	PERIODO GRAVABLE DE VENTA Y ALQUILER	0	12	16	192.168.1.102
3	PERIODO GRAVABLE DE TV SEÑAL  ABIERTA	2	1	16	192.168.1.102
4	PERIODO GRAVABLE DE DISTRIBUIDORES	2	1	16	192.168.1.101
5	PERIODO GRAVABLE DE TV SUSCRIPCION	1	4	16	192.168.1.102
6	PERIODO GRAVABLE DE PRODUCCION	1	4	16	192.168.1.101
\.


--
-- TOC entry 3229 (class 0 OID 128566)
-- Dependencies: 218 3321
-- Data for Name: tipocont; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY tipocont (id, nombre, tipegravid, usuarioid, ip, numero_articulo, cita_articulo) FROM stdin;
3	TV SUSCRIPCION	5	17	192.168.1.101	52	Las empresas que presten servicios de difusión de señal de televisión por suscripción con fines comerciales, sea esta por cable, por satélite o por cualquier otra vía creada o por crearse, pagarán al Fondo de Promoción y Financiamiento del Cine (FONPROCINE), una contribución especial que se recaudará de la forma siguiente: Cero coma cincuenta por ciento (0.50%) el primer año de entrada en vigencia de la presente Ley, uno por ciento (1%) el segundo año y uno coma cinco por ciento (1.5%) a partir del tercer año, calculado sobre los ingresos brutos de su facturación comercial por suscripción de ese servicio, que se liquidará y pagará de forma trimestral dentro de los primeros quince días continuos del mes subsiguiente al trimestre en que se produjo el hecho imponible.
1	EXHIBIDORES	1	16	192.168.1.102	50	Se crea una contribución especial que pagarán las personas \n\nnaturales o jurídicas cuya actividad económica sea la exhibición de obras \n\ncinematográficas en salas de cine con fines comerciales, al Fondo de Promoción \n\ny Financiamiento del Cine (FONPROCINE), equivalente al tres por ciento (3%) en \n\nel año 2005; cuatro por ciento (4%) en el año 2006 y cinco por ciento (5%) a partir \n\ndel año 2007, del valor del boleto o billete de entrada. \n\nLa base de su cálculo, será la cifra neta obtenida de restar del monto total del \n\nboleto o billete, la cantidad que corresponda al impuesto municipal por ese rubro. \n\nLos que se dediquen a la exhibición de obras cinematográficas de naturaleza \n\nartística y cultural en salas alternativas o independientes podrán quedar exentos \n\ndel cumplimiento de la respectiva obligación causada. \n\nEl Centro Nacional Autónomo de Cinematografía (CNAC), otorgará el certificado \n\ncorrespondiente a los fines de la aplicación del beneficio establecido en este \n\nLa contribución especial se autoliquidará y deberá ser pagada dentro de los \n\nprimeros quince (15) días del mes siguiente, en el que efectivamente se produjo el
5	VENTA Y ALQUILER	2	17	192.168.1.101	54	Las personas naturales o jurídicas que se dediquen al alquiler o \n\nventa de videogramas, discos de video digital, así como cualquier otro sistema \n\nde duplicación existente o por existir, pagarán al Fondo de Promoción y \n\nFinanciamiento al Cine (FONPROCINE), una contribución especial, equivalente \n\nal cinco por ciento (5%) de su facturación mensual, sin afectación del impuesto \n\nal valor agregado correspondiente, exigible dentro de los primeros quince días \n\ncontinuos siguientes al mes de la ocurrencia del hecho imponible.
2	TV SEÑAL ABIERTA	3	17	192.168.1.101	51	Las empresas que presten servicio de televisión de señal abierta con \n\nfines comerciales, pagarán al Fondo de Promoción y Financiamiento del Cine, \n\nFONPROCINE, una contribución especial, calculada sobre los ingresos brutos \n\npercibidos por la venta de espacios para publicidad, que se liquidará y pagará \n\nde forma anual dentro de los primeros cuarenta y cinco días continuos del año \n\ncalendario siguiente a aquel en que se produjo el hecho gravable, con base en la \n\nsiguiente tarifa, expresada en unidades tributarias (UT): \n\nPor la fracción comprendida desde 25.000 hasta 40.000 UT...... 0.5% \n\nPor la fracción que exceda de 40.000 hasta 80.000 UT............... 1 % \n\nPor la fracción que exceda de 80.000 UT................................... 1.5% \n\nLa presente disposición no se aplicará a las empresas que presten servicio de \n\ntelevisión de señal abierta, con fines exclusivamente informativos, musicales, \n\neducativos y deportivos.
4	DISTRIBUIDORES	4	17	192.168.1.101	53	Los distribuidores de obras cinematográficas con fines comerciales, \n\npagarán al Fondo de Promoción y Financiamiento al Cine (FONPROCINE) una \n\ncontribución especial, equivalente al cinco por ciento (5%) de sus ingresos brutos \n\npor ese rubro, exigible dentro de los primeros cuarenta y cinco días continuos \n\nsiguientes al vencimiento del año respectivo. \n\nLa presente disposición no se aplicará a aquellas personas cuyos ingresos \n\nbrutos obtenidos en el período fiscal respectivo, no superen las diez mil unidades \n\ntributarias (10.000 U.T.)
6	SERVICIOS PARA LA PRODUCCION	6	17	192.168.1.101	56	Las empresas que se dediquen de forma habitual, con fines de \n\nlucro al servicio técnico, tecnológico, logístico o de cualquier naturaleza para \n\nla producción y realización de obras cinematográficas en el territorio nacional, \n\npagarán al Fondo de Promoción y Financiamiento del Cine, FONPROCINE, una \n\ncontribución especial, equivalente al uno por ciento (1%) de los ingresos brutos \n\nobtenidos en esas actividades, pagaderos de forma trimestral, dentro de los \n\nquince (15) días siguientes al vencimiento del período.
\.


--
-- TOC entry 3283 (class 0 OID 128838)
-- Dependencies: 274 3321
-- Data for Name: tmpaccioni; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY tmpaccioni (id, contribuid, nombre, apellido, ci, domfiscal, nuacciones, valaccion, cextra1, cextra2, cextra3, cextra4, cextra5, ip) FROM stdin;
\.


--
-- TOC entry 3284 (class 0 OID 128846)
-- Dependencies: 275 3321
-- Data for Name: tmpcontri; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY tmpcontri (id, tipocontid, razonsocia, dencomerci, actieconid, rif, numregcine, domfiscal, estadoid, ciudadid, zonapostal, telef1, telef2, telef3, fax1, fax2, email, pinbb, skype, twitter, facebook, nuacciones, valaccion, capitalsus, capitalpag, regmerofc, rmnumero, rmfolio, rmtomo, rmfechapro, rmncontrol, rmobjeto, domcomer, conusuid, tiporeg, cextra1, cextra2, cextra3, cextra4, cextra5, ip) FROM stdin;
\.


--
-- TOC entry 3285 (class 0 OID 128856)
-- Dependencies: 276 3321
-- Data for Name: tmprelegal; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY tmprelegal (id, contribuid, nombre, apellido, ci, domfiscal, estadoid, ciudadid, zonaposta, telefhab, telefofc, fax, email, pinbb, skype, cextra1, cextra2, cextra3, cextra4, cextra5, ip) FROM stdin;
\.


--
-- TOC entry 3231 (class 0 OID 128574)
-- Dependencies: 220 3321
-- Data for Name: undtrib; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY undtrib (id, fecha, valor, usuarioid, ip, anio) FROM stdin;
5	1994-05-27	1.00	17	192.168.1.102	1994
6	1995-05-27	1.70	17	192.168.1.102	1995
7	1996-05-27	2.70	17	192.168.1.102	1996
8	1997-05-27	5.40	17	192.168.1.102	1997
9	1998-05-27	7.40	17	192.168.1.102	1998
10	1999-05-27	9.60	17	192.168.1.102	1999
11	2000-05-27	11.60	17	192.168.1.102	2000
12	2001-05-27	13.20	17	192.168.1.102	2001
13	2002-05-27	14.80	17	192.168.1.102	2002
14	2003-05-27	19.40	17	192.168.1.102	2003
15	2004-05-27	24.70	17	192.168.1.102	2004
16	2005-05-27	29.40	17	192.168.1.102	2005
17	2006-05-27	33.60	17	192.168.1.102	2006
18	2007-05-27	37.63	17	192.168.1.102	2007
19	2008-05-27	46.00	17	192.168.1.102	2008
20	2009-05-27	55.00	17	192.168.1.102	2009
21	2010-05-27	65.00	17	192.168.1.102	2010
22	2011-05-27	76.00	17	192.168.1.102	2011
23	2012-05-27	90.00	17	192.168.1.102	2012
24	2013-05-27	107.00	17	192.168.1.102	2013
\.


--
-- TOC entry 3235 (class 0 OID 128589)
-- Dependencies: 224 3321
-- Data for Name: usfonpro; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY usfonpro (id, login, password, nombre, email, telefofc, extension, departamid, cargoid, inactivo, pregsecrid, respuesta, perusuid, ultlogin, usuarioid, ip, cedula, ingreso_sistema) FROM stdin;
18	alaos	7c4a8d09ca3762af61e59520943dc26494f8941b	Arturo Laos	arturo.laos@gmail.com	02125760355	\N	10	8	f	2	Director LCT	\N	\N	1	192.168.1.103	11111111	f
17	svalladares	7c4a8d09ca3762af61e59520943dc26494f8941b	Silvia Valladares Sandoval	spvsr8@gmail.com	04160799712	\N	3	9	f	5	pizza	\N	\N	1	192.168.1.101	17829273	f
47	cnac	3145f2cd4ff92c1d9a538f215d8ab61132039016	CNAC	cnac@gmail.com	0212-5342123	\N	3	9	f	2	Prueba	\N	\N	\N	192.168.1.103	111111	f
48	jelara	652e0df6e23bd9aac8d2f5667b89f5d91cea8d15	Jefferson Arturo Lara Molina	jetox21@gmail.com	0412-0428211	\N	3	9	f	2	soy yo	\N	\N	\N	192.168.1.102	17042979	t
51	jeisyp_25	11437e64990ca1e7c9f150019a6fcbd92896a585	jeisy palacios	jeisyp_25@hotmail.com	0416-1083041	\N	\N	\N	f	\N	\N	\N	\N	\N	127.0.0.1	18164390	f
49	elmio	23017a25bdf707db1707779940e00d051d84d16b	jose de la trinida	elmio@hotmail.com	0412-0428211	\N	3	9	f	4	molina	\N	\N	\N	192.168.1.101	1235698	f
16	fbustamante	7c4a8d09ca3762af61e59520943dc26494f8941b	frederick	frederickdanielb@gmail.com	04142680489	\N	3	9	f	4	hola	\N	\N	1	192.168.1.101	15100387	t
\.


--
-- TOC entry 3233 (class 0 OID 128580)
-- Dependencies: 222 3321
-- Data for Name: usfonpto; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY usfonpto (id, token, usfonproid, fechacrea, fechacadu, usado) FROM stdin;
\.


SET search_path = historial, pg_catalog;

--
-- TOC entry 3976 (class 0 OID 0)
-- Dependencies: 279
-- Name: Bitacora_IDBitacora_seq; Type: SEQUENCE SET; Schema: historial; Owner: postgres
--

SELECT pg_catalog.setval('"Bitacora_IDBitacora_seq"', 34, true);


--
-- TOC entry 3286 (class 0 OID 128878)
-- Dependencies: 278 3321
-- Data for Name: bitacora; Type: TABLE DATA; Schema: historial; Owner: postgres
--

COPY bitacora (id, fecha, tabla, idusuario, accion, datosnew, datosold, datosdel, valdelid, ip) FROM stdin;
\.


SET search_path = pre_aprobacion, pg_catalog;

--
-- TOC entry 3288 (class 0 OID 128887)
-- Dependencies: 280 3321
-- Data for Name: datos_cnac; Type: TABLE DATA; Schema: pre_aprobacion; Owner: postgres
--

COPY datos_cnac (id, razonsocia, dencomerci, actieconid, rif, numregcine, domfiscal, estadoid, ciudadid, zonapostal, telef1, telef2, telef3, fax1, fax2, email, pinbb, skype, twitter, facebook, nuacciones, valaccion, capitalsus, capitalpag, regmerofc, rmnumero, rmfolio, rmtomo, rmfechapro, rmncontrol, rmobjeto, domcomer, cextra1, cextra2, cextra3, cextra4, cextra5, usuarioid, ip) FROM stdin;
4	empresa4	empres4	4	V178292737	4	caracas	1	1	1	414000001	\N	\N	\N	\N		\N	\N	\N	\N	100	10000.00	50000.00	25000.00	1	2	8	3	2012-05-05	1	objeto1	\N	\N	\N	\N	\N	\N	1	192.168.1.103
5	empresa5	empres5	5	J314725645	5	caracas	1	1	1	414000001	\N	\N	\N	\N		\N	\N	\N	\N	100	10000.00	50000.00	25000.00	1	2	8	3	2012-05-05	1	objeto1	\N	\N	\N	\N	\N	\N	1	192.168.1.103
6	empresa6	empres6	6	V151001005	6	caracas	1	1	1	414000001	\N	\N	\N	\N		\N	\N	\N	\N	100	10000.00	50000.00	25000.00	1	2	8	3	2012-05-05	1	objeto1	\N	\N	\N	\N	\N	\N	1	192.168.1.103
7	empresa7	empres7	7	V171743271	7	caracas	1	1	1	414000001	\N	\N	\N	\N		\N	\N	\N	\N	100	10000.00	50000.00	25000.00	1	2	8	3	2012-05-05	1	objeto1	\N	\N	\N	\N	\N	\N	1	192.168.1.103
1	empresa1	empresa1	1	V170429792	1	caracas	1	1	1	414000001	\N	\N	\N	\N		\N	\N	\N	\N	100	10000.00	50000.00	25000.00	1	2	8	3	2012-05-05	1	objeto1	\N	\N	\N	\N	\N	\N	1	192.168.1.103
8	empresa8	empres8	8	V170429792	8	caracas	1	1	1	414000001	\N	\N	\N	\N		\N	\N	\N	\N	100	10000.00	50000.00	25000.00	1	2	8	3	2012-05-05	1	objeto1	\N	\N	\N	\N	\N	\N	1	192.168.1.103
10	empresa10	empres10	9	V000000003	10	caracas	1	1	1	414000001	\N	\N	\N	\N		\N	\N	\N	\N	100	10000.00	50000.00	25000.00	1	2	8	3	2012-05-05	1	objeto1	\N	\N	\N	\N	\N	\N	1	192.168.1.103
11	empresa12	empres12	12	V000000004	12	caracas	1	1	1	414000001	\N	\N	\N	\N		\N	\N	\N	\N	100	10000.00	50000.00	25000.00	1	2	8	3	2012-05-05	1	objeto1	\N	\N	\N	\N	\N	\N	1	192.168.1.103
12	empresa13	empres13	13	V000000005	13	caracas	1	1	1	414000001	\N	\N	\N	\N		\N	\N	\N	\N	100	10000.00	50000.00	25000.00	1	2	8	3	2012-05-05	1	objeto1	\N	\N	\N	\N	\N	\N	1	192.168.1.103
13	empresa14	empres14	14	V000000006	14	caracas	1	1	1	414000001	\N	\N	\N	\N		\N	\N	\N	\N	100	10000.00	50000.00	25000.00	1	2	8	3	2012-05-05	1	objeto1	\N	\N	\N	\N	\N	\N	1	192.168.1.103
14	empresa15	empres15	15	V000000007	15	caracas	1	1	1	414000001	\N	\N	\N	\N		\N	\N	\N	\N	100	10000.00	50000.00	25000.00	1	2	8	3	2012-05-05	1	objeto1	\N	\N	\N	\N	\N	\N	1	192.168.1.103
15	empresa16	empres16	16	V000000008	16	caracas	1	1	1	414000001	\N	\N	\N	\N		\N	\N	\N	\N	100	10000.00	50000.00	25000.00	1	2	8	3	2012-05-05	1	objeto1	\N	\N	\N	\N	\N	\N	1	192.168.1.103
19	empresa20	empres20	20	E816204707	20	caracas	1	1	1	414000001	\N	\N	\N	\N		\N	\N	\N	\N	100	10000.00	50000.00	25000.00	1	2	8	3	2012-05-05	1	objeto1	\N	\N	\N	\N	\N	\N	1	192.168.1.103
16	empresa17	empres17	17	V000000009	17	caracas	1	1	1	414000001	\N	\N	\N	\N		\N	\N	\N	\N	100	10000.00	50000.00	25000.00	1	2	8	3	2012-05-05	1	objeto1	\N	\N	\N	\N	\N	\N	1	192.168.1.103
18	empresa19	empres19	19	V000000011	19	caracas	1	1	1	414000001	\N	\N	\N	\N		\N	\N	\N	\N	100	10000.00	50000.00	25000.00	1	2	8	3	2012-05-05	1	objeto1	\N	\N	\N	\N	\N	\N	1	192.168.1.103
2	empresa2	empres21	2	V000000001	2	caracas	1	1	1	414000001	\N	\N	\N	\N		\N	\N	\N	\N	100	10000.00	50000.00	25000.00	1	2	8	3	2012-05-05	1	objeto1	\N	\N	\N	\N	\N	\N	1	192.168.1.103
17	empresa18	empres18	18	V000000010	18	caracas	1	1	1	414000001	\N	\N	\N	\N		\N	\N	\N	\N	100	10000.00	50000.00	25000.00	1	2	8	3	2012-05-05	1	objeto1	\N	\N	\N	\N	\N	\N	1	192.168.1.103
9	empresa9	empres9	9	V000000002	9	caracas	1	1	1	414000001	\N	\N	\N	\N		\N	\N	\N	\N	100	10000.00	50000.00	25000.00	1	2	8	3	2012-05-05	1	objeto1	\N	\N	\N	\N	\N	\N	1	192.168.1.103
3	empresa3	empres3	3	V153938594	3	caracas	1	1	1	414000001	\N	\N	\N	\N		\N	\N	\N	\N	100	10000.00	50000.00	25000.00	1	2	8	3	2012-05-05	1	objeto1	\N	\N	\N	\N	\N	\N	1	192.168.1.103
\.


--
-- TOC entry 3977 (class 0 OID 0)
-- Dependencies: 281
-- Name: datos_cnac_id_seq; Type: SEQUENCE SET; Schema: pre_aprobacion; Owner: postgres
--

SELECT pg_catalog.setval('datos_cnac_id_seq', 19, true);


--
-- TOC entry 3263 (class 0 OID 128735)
-- Dependencies: 253 3321
-- Data for Name: intereses; Type: TABLE DATA; Schema: pre_aprobacion; Owner: postgres
--

COPY intereses (id, numresolucion, numactafiscal, felaboracion, fnotificacion, totalpagar, multaid, ip, usuarioid, fecha_inicio, fecha_fin, nudeposito, fecha_pago, fecha_carga_pago) FROM stdin;
450	3-2013	\N	2013-11-12 11:33:49.640816	\N	0	140	127.0.0.1	48	2013-10-21	2013-11-12	1123412341	2013-11-12 00:00:00	2013-11-12 11:38:58.571783
451	3-2013	\N	2013-11-12 12:01:36.641886	2013-11-12	565366	141	127.0.0.1	48	2008-04-21	2013-11-12	5454634	2013-11-12 00:00:00	2013-11-12 12:10:18.911569
452	3-2013	\N	2013-11-12 12:01:36.641886	2013-11-12	11034806.666667	142	127.0.0.1	48	2008-05-23	2013-11-12	5454634	2013-11-12 00:00:00	2013-11-12 12:10:18.911569
453	3-2013	\N	2013-11-12 12:01:36.641886	2013-11-12	1620053	143	127.0.0.1	48	2008-06-20	2013-11-12	5454634	2013-11-12 00:00:00	2013-11-12 12:10:18.911569
454	3-2013	\N	2013-11-12 12:01:36.641886	2013-11-12	210737466.66667	144	127.0.0.1	48	2008-07-21	2013-11-12	5454634	2013-11-12 00:00:00	2013-11-12 12:10:18.911569
455	3-2013	\N	2013-11-12 12:01:36.641886	2013-11-12	25666866.666667	145	127.0.0.1	48	2008-08-22	2013-11-12	5454634	2013-11-12 00:00:00	2013-11-12 12:10:18.911569
456	3-2013	\N	2013-11-12 12:01:36.641886	2013-11-12	30104750	146	127.0.0.1	48	2008-09-19	2013-11-12	5454634	2013-11-12 00:00:00	2013-11-12 12:10:18.911569
457	3-2013	\N	2013-11-12 12:01:36.641886	2013-11-12	48865983.333333	147	127.0.0.1	48	2008-10-21	2013-11-12	5454634	2013-11-12 00:00:00	2013-11-12 12:10:18.911569
458	3-2013	\N	2013-11-12 12:01:36.641886	2013-11-12	428290650	148	127.0.0.1	48	2008-11-21	2013-11-12	5454634	2013-11-12 00:00:00	2013-11-12 12:10:18.911569
459	3-2013	\N	2013-11-12 12:01:36.641886	2013-11-12	4635958333.3333	149	127.0.0.1	48	2008-12-22	2013-11-12	5454634	2013-11-12 00:00:00	2013-11-12 12:10:18.911569
460	3-2013	\N	2013-11-12 12:01:36.641886	2013-11-12	4454596108.3333	150	127.0.0.1	48	2009-01-22	2013-11-12	5454634	2013-11-12 00:00:00	2013-11-12 12:10:18.911569
461	4-2013	\N	2013-11-12 16:12:28.079477	2013-11-12	16959654.6	151	127.0.0.1	48	2012-02-14	2013-11-12	\N	\N	\N
462	1-2013	\N	2013-11-13 09:18:04.924772	\N	31237.833333333	152	127.0.0.1	48	2013-02-25	2013-11-12	\N	\N	\N
463	2-2013	\N	2013-11-13 10:10:43.149388	\N	452580	153	127.0.0.1	48	2012-07-25	2013-11-13	\N	\N	\N
464	3-2013	\N	2013-11-13 10:15:54.086904	\N	188986.66666667	154	127.0.0.1	48	2013-05-23	2013-11-13	\N	\N	\N
465	4-2013	\N	2013-11-13 10:15:54.086904	\N	17238.166666667	155	127.0.0.1	48	2013-04-22	2013-11-13	\N	\N	\N
467	2-2013	\N	2013-11-13 13:49:15.643919	2013-11-13	5244283.3333333	157	127.0.0.1	48	2011-02-14	2013-11-13	\N	\N	\N
468	5-2013	\N	2013-11-13 14:55:27.450467	\N	0	158	127.0.0.1	48	2013-10-21	2013-11-13	\N	\N	\N
469	6-2013	\N	2013-11-13 14:55:27.533356	\N	77771.2	159	127.0.0.1	48	2013-01-22	2013-11-13	\N	\N	\N
470	7-2013	\N	2013-11-13 14:55:27.533356	\N	2849.8	160	127.0.0.1	48	2013-04-15	2013-11-13	\N	\N	\N
471	8-2013	\N	2013-11-13 14:55:27.533356	\N	0	161	127.0.0.1	48	2013-07-15	2013-11-13	\N	\N	\N
472	5-2013	\N	2013-11-13 15:26:28.047877	\N	236395.75	162	127.0.0.1	48	2011-04-15	2013-11-13	\N	\N	\N
473	5-2013	\N	2013-11-13 15:26:28.055038	\N	559215	163	127.0.0.1	48	2012-02-23	2013-11-13	\N	\N	\N
474	5-2013	\N	2013-11-13 15:26:28.047877	\N	380410.5	164	127.0.0.1	48	2011-07-15	2013-11-13	\N	\N	\N
475	5-2013	\N	2013-11-13 15:26:28.055038	\N	478185	165	127.0.0.1	48	2012-03-22	2013-11-13	\N	\N	\N
476	5-2013	\N	2013-11-13 15:26:28.047877	\N	2301532	166	127.0.0.1	48	2011-10-17	2013-11-13	\N	\N	\N
477	5-2013	\N	2013-11-13 15:26:28.055038	\N	452580	167	127.0.0.1	48	2012-04-25	2013-11-13	\N	\N	\N
478	5-2013	\N	2013-11-13 15:26:28.055038	\N	452580	168	127.0.0.1	48	2012-05-23	2013-11-13	\N	\N	\N
479	5-2013	\N	2013-11-13 15:26:28.047877	\N	193951.2	169	127.0.0.1	48	2012-01-17	2013-11-13	\N	\N	\N
480	5-2013	\N	2013-11-13 15:26:28.055038	\N	452580	170	127.0.0.1	48	2012-06-22	2013-11-13	\N	\N	\N
481	3-2013	\N	2013-11-13 15:26:38.243336	2013-11-13	4666229.856	171	127.0.0.1	48	2013-02-14	2013-11-13	\N	\N	\N
482	9-2013	\N	2013-11-15 10:56:34.619372	\N	135774	172	127.0.0.1	48	2012-10-15	2013-11-13	\N	\N	\N
\.


--
-- TOC entry 3978 (class 0 OID 0)
-- Dependencies: 282
-- Name: intereses_id_seq; Type: SEQUENCE SET; Schema: pre_aprobacion; Owner: postgres
--

SELECT pg_catalog.setval('intereses_id_seq', 482, true);


--
-- TOC entry 3264 (class 0 OID 128742)
-- Dependencies: 254 3321
-- Data for Name: multas; Type: TABLE DATA; Schema: pre_aprobacion; Owner: postgres
--

COPY multas (id, nresolucion, fechaelaboracion, fechanotificacion, montopagar, declaraid, ip, usuarioid, tipo_multa, nudeposito, fechapago, fecha_carga_pago, numero_session, fecha_session) FROM stdin;
140	3-2013	2013-11-12 11:33:49.640816	2013-11-12	5000	568	127.0.0.1	48	4	234513452	2013-11-12 00:00:00	2013-11-12 11:38:58.571783	00001-2013	2013-11-12 00:00:00
152	1-2013	2013-11-13 09:18:04.924772	2013-11-13	50	580	127.0.0.1	48	4	\N	\N	\N	000003	2013-11-13 00:00:00
153	2-2013	2013-11-13 10:10:43.149388	2013-11-13	500	591	127.0.0.1	48	4	\N	\N	\N	00006-2013	2013-11-13 00:00:00
155	4-2013	2013-11-13 10:15:54.086904	2013-11-13	50	592	127.0.0.1	48	4	\N	\N	\N	00009-2013	2013-11-13 00:00:00
154	3-2013	2013-11-13 10:15:54.086904	2013-11-13	1000	593	127.0.0.1	48	4	\N	\N	\N	00009-2013	2013-11-13 00:00:00
157	2-2013	2013-11-13 13:49:15.643919	2013-11-13	28125000	590	127.0.0.1	48	8	\N	\N	\N	0000009-2013	2013-11-13 00:00:00
158	5-2013	2013-11-13 14:55:27.450467	\N	95	597	127.0.0.1	48	4	\N	\N	\N	\N	\N
159	6-2013	2013-11-13 14:55:27.533356	\N	97.5	595	127.0.0.1	48	4	\N	\N	\N	\N	\N
160	7-2013	2013-11-13 14:55:27.533356	\N	7.5	594	127.0.0.1	48	4	\N	\N	\N	\N	\N
161	8-2013	2013-11-13 14:55:27.533356	\N	1350	596	127.0.0.1	48	4	\N	\N	\N	\N	\N
162	5-2013	2013-11-13 15:26:28.047877	\N	750	600	127.0.0.1	48	5	\N	\N	\N	0000020-2013	2013-11-13 00:00:00
163	5-2013	2013-11-13 15:26:28.055038	\N	5000	605	127.0.0.1	48	5	\N	\N	\N	0000020-2013	2013-11-13 00:00:00
164	5-2013	2013-11-13 15:26:28.047877	\N	1500	601	127.0.0.1	48	5	\N	\N	\N	0000020-2013	2013-11-13 00:00:00
165	5-2013	2013-11-13 15:26:28.055038	\N	5000	606	127.0.0.1	48	5	\N	\N	\N	0000020-2013	2013-11-13 00:00:00
166	5-2013	2013-11-13 15:26:28.047877	\N	12000	602	127.0.0.1	48	5	\N	\N	\N	0000020-2013	2013-11-13 00:00:00
167	5-2013	2013-11-13 15:26:28.055038	\N	5000	607	127.0.0.1	48	5	\N	\N	\N	0000020-2013	2013-11-13 00:00:00
168	5-2013	2013-11-13 15:26:28.055038	\N	5000	608	127.0.0.1	48	5	\N	\N	\N	0000020-2013	2013-11-13 00:00:00
169	5-2013	2013-11-13 15:26:28.047877	\N	1440	603	127.0.0.1	48	5	\N	\N	\N	0000020-2013	2013-11-13 00:00:00
170	5-2013	2013-11-13 15:26:28.055038	\N	5000	609	127.0.0.1	48	5	\N	\N	\N	0000020-2013	2013-11-13 00:00:00
171	3-2013	2013-11-13 15:26:38.243336	2013-11-13	77031000	611	127.0.0.1	48	8	\N	\N	\N	00000020-2013	2013-11-13 00:00:00
141	3-2013	2013-11-12 12:01:36.641886	2013-11-12	500	570	127.0.0.1	48	5	\N	\N	\N	0000001-2013	2013-11-12 00:00:00
142	3-2013	2013-11-12 12:01:36.641886	2013-11-12	10000	571	127.0.0.1	48	5	\N	\N	\N	0000001-2013	2013-11-12 00:00:00
143	3-2013	2013-11-12 12:01:36.641886	2013-11-12	1500	572	127.0.0.1	48	5	\N	\N	\N	0000001-2013	2013-11-12 00:00:00
144	3-2013	2013-11-12 12:01:36.641886	2013-11-12	200000	573	127.0.0.1	48	5	\N	\N	\N	0000001-2013	2013-11-12 00:00:00
145	3-2013	2013-11-12 12:01:36.641886	2013-11-12	25000	574	127.0.0.1	48	5	\N	\N	\N	0000001-2013	2013-11-12 00:00:00
146	3-2013	2013-11-12 12:01:36.641886	2013-11-12	30000	575	127.0.0.1	48	5	\N	\N	\N	0000001-2013	2013-11-12 00:00:00
147	3-2013	2013-11-12 12:01:36.641886	2013-11-12	50000	576	127.0.0.1	48	5	\N	\N	\N	0000001-2013	2013-11-12 00:00:00
148	3-2013	2013-11-12 12:01:36.641886	2013-11-12	450000	577	127.0.0.1	48	5	\N	\N	\N	0000001-2013	2013-11-12 00:00:00
149	3-2013	2013-11-12 12:01:36.641886	2013-11-12	5000000	578	127.0.0.1	48	5	\N	\N	\N	0000001-2013	2013-11-12 00:00:00
150	3-2013	2013-11-12 12:01:36.641886	2013-11-12	4945000	579	127.0.0.1	48	5	\N	\N	\N	0000001-2013	2013-11-12 00:00:00
151	4-2013	2013-11-12 16:12:28.079477	2013-11-12	144491.2	582	127.0.0.1	48	5	\N	\N	\N	0005-2013	2013-11-12 00:00:00
172	9-2013	2013-11-15 10:56:34.619372	\N	150	598	127.0.0.1	48	4	\N	\N	\N	\N	\N
\.


--
-- TOC entry 3979 (class 0 OID 0)
-- Dependencies: 283
-- Name: multas_id_seq; Type: SEQUENCE SET; Schema: pre_aprobacion; Owner: postgres
--

SELECT pg_catalog.setval('multas_id_seq', 172, true);


SET search_path = public, pg_catalog;

--
-- TOC entry 3292 (class 0 OID 128903)
-- Dependencies: 284 3321
-- Data for Name: contrib_calc; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY contrib_calc (id, nombre) FROM stdin;
\.


SET search_path = seg, pg_catalog;

--
-- TOC entry 3293 (class 0 OID 128906)
-- Dependencies: 285 3321
-- Data for Name: tbl_cargos; Type: TABLE DATA; Schema: seg; Owner: postgres
--

COPY tbl_cargos (id, nombre, descripcion, oficinasid, usuarioid, ip, bln_borrado) FROM stdin;
1	Gerente de recaudacion		1	48	192.168.1.102	f
2	Recaudador		1	48	192.168.1.102	f
3	Gerente de fiscalizacion		2	48	192.168.1.102	f
4	Fiscal		2	48	192.168.1.102	f
5	Gerente de finanzas		3	48	192.168.1.102	f
6	Gerente de legal		4	48	192.168.1.102	f
\.


--
-- TOC entry 3980 (class 0 OID 0)
-- Dependencies: 286
-- Name: tbl_cargos_id_seq; Type: SEQUENCE SET; Schema: seg; Owner: postgres
--

SELECT pg_catalog.setval('tbl_cargos_id_seq', 6, true);


--
-- TOC entry 3295 (class 0 OID 128915)
-- Dependencies: 287 3321
-- Data for Name: tbl_ci_sessions; Type: TABLE DATA; Schema: seg; Owner: postgres
--

COPY tbl_ci_sessions (session_id, ip_address, user_agent, last_activity, user_data, prevent_update) FROM stdin;
29c875f886f996abdcffcc8ee8be3ff0	127.0.0.1	Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:25.0) Gecko/20100101 Firefox/25.0	1384543175		0
\.


--
-- TOC entry 3296 (class 0 OID 128925)
-- Dependencies: 288 3321
-- Data for Name: tbl_modulo; Type: TABLE DATA; Schema: seg; Owner: postgres
--

COPY tbl_modulo (id_modulo, id_padre, str_nombre, str_descripcion, str_enlace, bln_borrado) FROM stdin;
116	104	prueba2	prueba2	./prueba	t
115	104	prueba	prueba	./prueba	t
141	102	Reparos culminados	listado de los reparos cargados por usuario	./mod_administrador/principal_c	f
91	90	Contribuyentes inactivos	busqueda de planilla	./mod_gestioncontribuyente/lista_contribuyentes_inactivos_c	f
13	6	Usuarios	Modulo hijo que muestra el listar de Usuarios con todas las operacciones correspondientes 	./mod_administrador/usuarios_c	f
120	104	prueba4	prueba4	./prueba4	t
119	104	prueba3	prueba3	./prueba3	t
118	104	prueba2	prueba2	./prueba2	t
117	104	prueba1	prueba1	./prueba1	t
6	5	Usuarios	Administrar los usuarios del sistema	./mod_administrador/principal_c	f
93	89	Gestion Declaración	Gestion de alendarios de pago para declaracion del contribuyente	./mod_administrador/principal_c	f
97	93	Calendario de Pagos	Gestion de calendarios de pagos de la declaracion del contribuyente	./mod_gestioncontribuyente/gestion_calendarios_de_pago_c	f
102	\N	Fiscalizacion	gerencia de fiscalizacion tributaria	#	f
103	\N	Legal	gerencia de legal	#	f
104	5	Perfiles de usuario	modulo para la craion de los roles dentro del sistema	./mod_administrador/principal_c	f
88	\N	PRUEBA	SJKHBAKJHSDK	./LKJLKJLK	t
105	104	Crear perfil	modulo para la cracion de los perfiles en el sistemas	./mod_administrador/roles_c	f
7	5	Manejo de Modulos	Administrar los grupos para los usuarios del sistema	./mod_administrador/principal_c	t
111	110	gfhgfdgfd	fdgfdg	./oooo	t
89	\N	Recaudacion	gerencia de recaudacion tributaria	#	f
100	\N	Recaudacion	gerencia de recaudacion tributaria	#	t
123	122	silvia	silvia	./silvvia	t
151	141	Reparos por activacion	listado de los reparos inpuestos a las empresas	./mod_gestioncontribuyente/reparos_c	f
8	5	Módulos principales	Administrar los módulos del sistema	./mod_administrador/principal_c	t
122	5	SILVIA	silvia	./mod_administrador/principal_c	t
86	7	Operaciones	modulo hijo para la creacion y manejos de modulos aguelos, padres y grupos	./mod_administrador/manejo_modulo_c	f
101	\N	Finanzas	gerencia de finazas 	#	f
108	104	rfgfgf	fdgfdg	./	t
109	5	JHGJHGJHG	jhkjhkhkjh	./	t
121	6	prueba	prueba	./prueba	t
110	89	FDGFDG	fdgfdg	./mod_administrador/principal_c	t
135	129	prueba	recarga	./prueba	t
5	\N	Administracion de sistema	Opciones de administración del sistema	#	f
114	104	prueba3	prueba3	./pueba3	t
113	104	prueba2	prueba2	./pueba2	t
112	104	prueba	prueba	./prueba	t
136	130	Cambiar Contraseña	sub-modulo para la carga del formulario que permite el cambio de contraseña del usuario	./mod_administrador/gestion_usuario_c/frm_cambio_contrasenia	f
138	131	Cambiar Preg. Secreta	Formulario para el cambio de pregunta secreta del registro del usuario	./mod_administrador/gestion_usuario_c/frm_cambio_pregsecr	f
149	89	Consulta Avanzada	Consulta Avanzada de Contribuyentes del Modulo Recaudacion	./mod_administrador/principal_c	f
139	5	Gestion de modulos	modulo la edicion eliminacion y creacion de nuvos modulos en el sistema en sus diferentes jerarquias	./mod_administrador/principal_c	f
128	\N	Gestión de Usuarios	Secciones para la gestion de informacion de usuarios	#	f
129	128	Actualizar Datos	Modulo que permite modificar los datos de los usuarios	./mod_administrador/principal_c	f
130	128	Cambiar Contraseña	Modulo para el cambio de contraseñas de los usuarios	./mod_administrador/principal_c	f
131	128	Cambiar Preg. Secreta	modulo para el cambio de pregunta secreta del usuario	./mod_administrador/principal_c	f
132	129	Actualizar Datos	Formulario para la actualización de datos del usuario	./mod_administrador/gestion_usuario_c	f
133	102	Visitas asignadas	modulo donde pueden ver los fiscales las distintas empresas que le fueron lasignadas para visitar	./mod_administrador/principal_c	f
134	133	asignaciones	manejo de empresas a ser fiscalizadas	./mod_gestioncontribuyente/fiscalizacion_c	f
140	101	Calculos	Modulo para los calculos realizados por finanzas	./mod_administrador/principal_c	f
98	102	Consulta Avanzada	Consulta Avanzada de Fiscalizacion	./mod_administrador/principal_c	f
145	139	modulos abuelos	creacion, eliminacion y edicion de los modulos principales del menu denominados abuelos	./nose	f
146	139	modulos padres	creacion, eliminacion y edicion de los modulos dependientes  de los abuelos en el menu principal	./nose	f
147	139	modulos hijos	creacion, eliminacion y edicion de las pestañas en la tab	./nose	f
150	149	Omisos	Consulta Avanzada de Omisos para el Modulo Recaudacion	./mod_gestioncontribuyente/lista_contribuyentes_general_c/consulta_general/0	f
153	149	Extemporáneos	Listado de contribuyentes extemporáneos para el departamento de recaudacion	./mod_gestioncontribuyente/lista_contribuyentes_general_c/consulta_general/1	f
152	140	Extemporáneos	Listar de extemporáneos, asignados a la gerencia de Finanzas	./mod_gestioncontribuyente/lista_extemp_calc_c	f
107	98	Omisos	modulo para gestion de contribuyentes omisos	./mod_gestioncontribuyente/lista_contribuyentes_general_c/consulta_general/2	f
154	133	Periodos cancelados	modulo que se encarga de lacrag de los periodos que aparecen en le sistema omisos pero que al momento de la auditoría fueron cancelados por el contribuyente 	./fiscalizacion_c/periodos_cancelados	t
144	101	Calculos por aprobar	Modulo para el listar de las declaraciones que ya fueron calculadas	./mod_administrador/principal_c	f
157	144	Extemporáneos	Listado calculo por aprobar de los extemporáneos	./mod_gestioncontribuyente/lista_por_aprobar_c	f
155	89	Gestion deberes formales	permite visualizar todas las empresas que se encuentran registradas en la data principal del cnac y por medio de ella el equipo de recaudacion verifica los deberes formales de cada una de ellas	./mod_administrador/principal_c	f
137	0	0	0	0	t
142	102	prueba	PRUEBA	./mod_administrador/principal_c	t
156	155	Registros del CNAC	listado que contienen todas las empresas que se encuentran registrada hasta la actualidad en registro nacional de cinematografia	./mod_gestioncontribuyente/listado_cnac_c	t
161	128	ppppppp hhhhhhhhhh  hhhhhhhhhhhhhhj	,m	./mod_administrador/principal_c	t
90	89	Activacion del contribuyente	verifica planilla	./mod_administrador/principal_c	f
162	89	gestion de multas	modulo encargado de mostrar al usuario el estatus que se encuentra el calculo solicitado y si ya fue aprobado imprimi la notificacion	./mod_administrador/principal_c	f
158	155	Empresas externas	manejo de verificacion de deberes formales a partir de listados de empresas de indole externo esto quiere decir que la empresa no se encuentra en el registro del cnac pero que es un posible contribuyente potencial	./mod_gestioncontribuyente/empext	t
165	164	Asignacion por deberes formales	se listan todas las empresas que en los deberes formales se les determino que eran contribuyentes fonprocine	./mod_gestioncontribueyente/asignacion_deberes_formales_fiscalizacion_c	f
167	141	Reparos activados	listado de los reparos que fueron activados despues de la fiscalizacion	./rrrrrrr	t
168	101	Interes BCV	interes bcv	./mod_administrador/principal_c	f
169	168	Interes banco central	interes banco central	./mod_finanzas/interes_bcv_c	f
143	103	Reparos culminados	prueba legal	./mod_administrador/principal_c	f
170	143	listado de reparos culminados	aqui se visualizan todos los reparos que fueron activados por el gerente de fiscalización. la finalidad de estos es que legal le haga seguimientos a las fechas de pagos de los reparos.	./mod_legal/legal_c	f
171	103	Descargos	descargos	./mod_administrador/principal_c	f
172	171	Listado de empresas en descargo	listado de enpresas en situacion de descargos	./mod_legal/legal_c/listado_descargos	f
166	140	Culminatoria de fiscalizacion	Listado de contribuyentes por Reparo, donde se aplicaran los cálculos de intereses y multas	./mod_gestioncontribuyente/lista_reparo_calc_c	f
173	140	Resolucion de sumario	Resolucion de sumario	./mod_gestioncontribuyente/lista_reparo_calc_c/index_sumario	f
164	102	Empresas Recaudacion	aqui se vizualiza las empresas que arrojaron en la verificacion de los deberes formales que si son contribueyntes de fonprocine	./mod_administrador/principal_c	t
159	89	Envio Correo Electrónico	Envio Correo Electrónico	./mod_administrador/principal_c	f
160	159	Correos Electrónicos	Correos Electrónicos	./mod_gestioncontribuyente/envio_correos_c	f
174	103	Gestion de Multas	modulo para tramitar las multas por culminatoria de fiscalizacion y pos sumario	./mod_administrador/principal_c	f
176	174	Resolucion de Sumario	listado de multas aprobadas pasadas a finanzas por resolucion de sumario	./mod_legal/gestion_multas_legal_c/multas_sumario_aprobadas	f
175	174	Culminatoria de fiscalizacion	listado de multas a probadas que fueron pasada por culminatoria de fiscalizacion	./mod_legal/gestion_multas_legal_c/multas_culminatoria_aprobadas	f
163	162	Listado de Multas Aprobadas	se visulaiza el listar de los contribuyentes con multas extemporabeas segun el estatus que requiera el usuario	./mod_gestioncontribuyente/gestion_multas_recaudacion_c	f
\.


--
-- TOC entry 3981 (class 0 OID 0)
-- Dependencies: 289
-- Name: tbl_modulo_id_modulo_seq; Type: SEQUENCE SET; Schema: seg; Owner: postgres
--

SELECT pg_catalog.setval('tbl_modulo_id_modulo_seq', 176, true);


--
-- TOC entry 3298 (class 0 OID 128934)
-- Dependencies: 290 3321
-- Data for Name: tbl_oficinas; Type: TABLE DATA; Schema: seg; Owner: postgres
--

COPY tbl_oficinas (id, nombre, descripcion, fecha_creacion, cod_estructura, usuarioid, ip, bln_borrado) FROM stdin;
1	GERENCIA DE RECAUDACION		2013-05-09	0001	48	192.168.1.102	f
2	GERENCIA DE FISCALIZACION		2013-05-09	0002	48	192.168.1.102	f
3	GERENCIA DE FINANZAS		2013-05-09	0003	48	192.168.1.102	f
4	GERENCIA DE LEGAL		2013-05-09	0004	48	192.168.1.102	f
\.


--
-- TOC entry 3982 (class 0 OID 0)
-- Dependencies: 291
-- Name: tbl_oficinas_id_seq; Type: SEQUENCE SET; Schema: seg; Owner: postgres
--

SELECT pg_catalog.setval('tbl_oficinas_id_seq', 4, true);


--
-- TOC entry 3300 (class 0 OID 128944)
-- Dependencies: 292 3321
-- Data for Name: tbl_permiso; Type: TABLE DATA; Schema: seg; Owner: postgres
--

COPY tbl_permiso (id_permiso, id_modulo, id_rol, int_permiso, bln_borrado) FROM stdin;
1833	158	1	1	f
1836	161	1	1	f
32	89	5	1	t
33	90	5	1	t
61	101	5	1	t
1741	5	5	1	t
1742	6	5	1	t
1743	104	5	1	t
1759	5	5	1	t
1760	6	5	1	t
1761	104	5	1	t
1765	5	5	1	t
1766	6	5	1	t
1767	104	5	1	t
1768	89	5	1	t
1769	90	5	1	t
1770	93	5	1	t
1771	98	5	1	t
1837	162	1	1	f
1751	89	10	1	t
1752	90	10	1	t
60	103	2	1	t
1644	103	2	1	t
26	5	2	1	t
1645	5	2	1	t
1753	93	10	1	t
1754	98	10	1	t
27	6	2	1	t
1672	5	1	1	t
1646	6	2	1	t
1647	89	2	1	t
22	5	4	1	t
1641	5	4	1	t
23	6	4	1	t
1642	6	4	1	t
1643	104	4	1	t
28	5	3	1	t
31	6	3	1	t
1648	90	2	1	t
1649	93	2	1	t
1650	98	2	1	t
1706	103	2	1	t
1805	5	2	1	f
1675	5	1	1	t
1673	6	1	1	t
1676	6	1	1	t
1671	104	1	1	t
1674	104	1	1	t
1677	104	1	1	t
1678	89	1	1	t
1679	90	1	1	t
1806	6	2	1	f
1680	93	1	1	t
1681	98	1	1	t
1682	89	1	1	t
1683	90	1	1	t
1684	93	1	1	t
1685	98	1	1	t
1686	5	1	1	t
1687	6	1	1	t
1763	110	1	1	t
1688	104	1	1	t
1689	101	1	1	t
1690	102	1	1	t
1783	5	1	1	t
1784	6	1	1	t
1785	104	1	1	t
1786	101	1	1	t
1787	102	1	1	t
1788	103	1	1	t
1789	89	1	1	t
1790	90	1	1	t
1791	93	1	1	t
1807	104	2	1	f
1808	139	2	1	f
1792	98	1	1	t
1794	129	1	1	t
1797	133	1	1	t
1798	139	1	1	t
1800	141	1	1	t
1801	142	1	1	t
1803	144	1	1	t
1834	159	1	1	f
1737	101	5	1	t
1755	89	14	1	t
1756	90	14	1	t
1757	93	14	1	t
1758	98	14	1	t
1744	5	5	1	t
1748	5	11	1	t
1749	6	11	1	t
1750	104	11	1	t
1845	164	1	1	f
1739	5	4	1	f
1740	5	3	1	f
1804	149	1	1	t
1762	109	1	1	t
1764	122	1	1	t
1691	103	1	1	t
1692	5	1	1	t
1793	128	1	1	t
1693	6	1	1	t
1694	104	1	1	t
1695	5	1	1	t
1696	6	1	1	t
1697	104	1	1	t
1698	89	1	1	t
1699	90	1	1	t
1700	93	1	1	t
1701	98	1	1	t
1702	101	1	1	t
1703	102	1	1	t
1704	103	1	1	t
1705	101	1	1	t
1707	5	1	1	t
1708	6	1	1	t
1709	104	1	1	t
1710	89	1	1	t
1711	90	1	1	t
1712	93	1	1	t
1713	98	1	1	t
1714	101	1	1	t
1715	102	1	1	t
1716	103	1	1	t
1717	5	1	1	t
1718	6	1	1	t
1719	104	1	1	t
1720	89	1	1	t
1721	98	1	1	t
1722	101	1	1	t
1723	102	1	1	t
1724	103	1	1	t
1725	5	1	1	t
1726	6	1	1	t
1795	130	1	1	t
1796	131	1	1	t
1799	140	1	1	t
1802	143	1	1	t
1727	104	1	1	t
1728	101	1	1	t
1729	102	1	1	t
1730	103	1	1	t
1731	89	1	1	t
1732	90	1	1	t
1733	93	1	1	t
1734	98	1	1	t
1773	5	1	1	t
1774	6	1	1	t
1775	104	1	1	t
1776	101	1	1	t
1777	102	1	1	t
1778	103	1	1	t
1779	89	1	1	t
1780	90	1	1	t
1781	93	1	1	t
1782	98	1	1	t
1810	5	1	1	f
1811	6	1	1	f
1812	104	1	1	f
1813	139	1	1	f
1814	101	1	1	f
1815	144	1	1	f
1816	140	1	1	f
1817	102	1	1	f
1818	98	1	1	f
1819	133	1	1	f
1820	141	1	1	f
1821	142	1	1	f
1822	103	1	1	f
1823	143	1	1	f
1824	128	1	1	f
1825	129	1	1	f
1826	130	1	1	f
1827	131	1	1	f
1828	89	1	1	f
1829	90	1	1	f
1830	93	1	1	f
1831	149	1	1	f
1832	155	1	1	f
1835	160	1	1	f
1846	168	1	1	f
1847	171	1	1	f
1848	172	1	1	f
1859	174	1	1	f
1809	155	8	1	t
1635	5	8	1	t
1638	5	8	1	t
1636	6	8	1	t
1639	6	8	1	t
1637	104	8	1	t
1640	104	8	1	t
1651	5	8	1	t
1652	6	8	1	t
1653	104	8	1	t
1654	89	8	1	t
1655	90	8	1	t
1656	93	8	1	t
1657	98	8	1	t
1840	103	8	1	t
1841	5	8	1	t
1842	6	8	1	t
1843	104	8	1	t
1844	139	8	1	t
1772	103	8	1	t
1849	89	8	1	t
1850	90	8	1	t
1851	93	8	1	t
1852	149	8	1	t
1853	155	8	1	t
1854	162	8	1	t
1855	128	8	1	t
1856	129	8	1	t
1857	130	8	1	t
1858	131	8	1	t
1860	89	8	1	f
1861	90	8	1	f
1862	149	8	1	f
1863	162	8	1	f
1864	128	8	1	f
1865	129	8	1	f
1866	130	8	1	f
1867	131	8	1	f
\.


--
-- TOC entry 3983 (class 0 OID 0)
-- Dependencies: 293
-- Name: tbl_permiso_id_permiso_seq; Type: SEQUENCE SET; Schema: seg; Owner: postgres
--

SELECT pg_catalog.setval('tbl_permiso_id_permiso_seq', 1867, true);


--
-- TOC entry 3302 (class 0 OID 128950)
-- Dependencies: 294 3321
-- Data for Name: tbl_permiso_trampa; Type: TABLE DATA; Schema: seg; Owner: postgres
--

COPY tbl_permiso_trampa (id_permiso, id_modulo, id_rol, int_permiso, bln_borrado) FROM stdin;
\.


--
-- TOC entry 3984 (class 0 OID 0)
-- Dependencies: 295
-- Name: tbl_permiso_trampa_id_permiso_seq; Type: SEQUENCE SET; Schema: seg; Owner: postgres
--

SELECT pg_catalog.setval('tbl_permiso_trampa_id_permiso_seq', 47, true);


--
-- TOC entry 3304 (class 0 OID 128956)
-- Dependencies: 296 3321
-- Data for Name: tbl_rol; Type: TABLE DATA; Schema: seg; Owner: postgres
--

COPY tbl_rol (id_rol, str_rol, str_descripcion, bln_borrado) FROM stdin;
1	Administrador	Administrador del sistema	f
2	Coordinador	Coordinador de la sala situacional	f
3	Analista	Analista de seguimiento	f
4	Contribuyente	Rol para todos losn usuarios externo osea para los contribuyentes	f
7	prueba2	prueba2	t
6	prueba	prueba	t
8	Recaudacion	perfil para los funcionarios publicos que trabajan en la gererncia de recaudacion	f
12	prueba4	sdgfzsfasdfdasd	t
9	prueba 	jhgkjgkkjhk	t
11	prueba3	vvvvvvvv	t
10	prueba2	kjhkjjhkhkj	t
13	gerente recaudacion	asdfsdfsdf	t
14	otra prueba	asdfadasda	t
15	dandole 	dsfdadasda	t
16	nuevoooo	ooooooo	t
5	CNAC	Rol para usuarios CNAC	t
\.


--
-- TOC entry 3985 (class 0 OID 0)
-- Dependencies: 297
-- Name: tbl_rol_id_rol_seq; Type: SEQUENCE SET; Schema: seg; Owner: postgres
--

SELECT pg_catalog.setval('tbl_rol_id_rol_seq', 16, true);


--
-- TOC entry 3306 (class 0 OID 128965)
-- Dependencies: 298 3321
-- Data for Name: tbl_rol_usuario; Type: TABLE DATA; Schema: seg; Owner: postgres
--

COPY tbl_rol_usuario (id_rol_usuario, id_rol, id_usuario, bln_borrado) FROM stdin;
1	1	16	f
19	1	17	f
54	5	47	f
55	1	48	f
34	1	18	f
57	1	51	f
56	1	49	f
\.


--
-- TOC entry 3986 (class 0 OID 0)
-- Dependencies: 299
-- Name: tbl_rol_usuario_id_rol_usuario_seq; Type: SEQUENCE SET; Schema: seg; Owner: postgres
--

SELECT pg_catalog.setval('tbl_rol_usuario_id_rol_usuario_seq', 57, true);


--
-- TOC entry 3308 (class 0 OID 128971)
-- Dependencies: 300 3321
-- Data for Name: tbl_session_ci; Type: TABLE DATA; Schema: seg; Owner: postgres
--

COPY tbl_session_ci (session_id, ip_address, user_agent, last_activity, user_data) FROM stdin;
f093f9803caa36c8160f5b08bb661a09	127.0.0.1	Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:19.0) Gecko/20100101 Firefox/19.0	1365795522	
\.


--
-- TOC entry 3309 (class 0 OID 128981)
-- Dependencies: 301 3321
-- Data for Name: tbl_usuario_rol; Type: TABLE DATA; Schema: seg; Owner: postgres
--

COPY tbl_usuario_rol (id_usuario_rol, id_usuario, id_rol, bol_borrado) FROM stdin;
\.


--
-- TOC entry 3987 (class 0 OID 0)
-- Dependencies: 302
-- Name: tbl_usuario_rol_id_usuario_rol_seq; Type: SEQUENCE SET; Schema: seg; Owner: postgres
--

SELECT pg_catalog.setval('tbl_usuario_rol_id_usuario_rol_seq', 16, true);


SET search_path = "segContribu", pg_catalog;

--
-- TOC entry 3311 (class 0 OID 128998)
-- Dependencies: 305 3321
-- Data for Name: tbl_modulo_contribu; Type: TABLE DATA; Schema: segContribu; Owner: postgres
--

COPY tbl_modulo_contribu (id_modulo, id_padre, str_nombre, str_descripcion, str_enlace, bln_borrado) FROM stdin;
89	\N	Contribuyente	Modulo Princioal del Contribuyente	#	f
90	89	Seccion	Padre	./mod_contribuyente/principal_c	f
112	101	reparos	listado de reparos	./mod_contribuyente/contribuyente_c/declaraciones_realizadas_enreparo	f
91	90	Cargar datos	carga de datos del contribuyente	./mod_contribuyente/contribuyente_c/planilla_inicial	f
92	\N	Administracion	modulo para la administracion y gestion de la sesion del contribuyente	#	f
113	99	Multas impuestas	listado de multas impuestas por procedimientos de reparos o pro periodos extemporaneos	./mod_contribuyente/principal_c	f
97	93	cambio de clave	cambio de clave tabs	./mod_contribuyente/gestion_contrasena_c	f
93	92	Seguridad	cambio de clave	./mod_contribuyente/principal_c	f
98	93	cambio pregunta secreta	cambio depregunta secreta	./mod_contribuyente/gestion_pregunta_secreta_c	f
99	\N	Declaraciones	modulo que gestiona todo lo relacionado con las declaraciones del contribuyente	#	f
100	99	Nueva declaracion	modulo para realizar la declaracion el contribuyente	./mod_contribuyente/principal_c	f
103	90	Carga de documentos	documentos complementarios del registro	./mod_contribuyente/filecontroller/documentos	f
108	100	declarar	vista para la declaracion del contrribuyente	./mod_contribuyente/contribuyente_c/declaracion	f
102	99	Gestion de pagos	modulo para la carga de los accionistas	./mod_contribuyente/principal_c	f
109	102	Cargar pago	modulo para la carga del tipo de contribuyente que define al la empresa que se esta registrando	./mod_contribuyente/gestion_pagos_c	f
106	90	Rep. legal	gestion de representante legal	./mod_contribuyente/principal_c	t
107	90	Carga de  Rep. legal	craga de representante legal	./mod_contribuyente/contribuyente_c/representante_legal	f
101	99	Reparos Fiscales	modulo para realizar las consulta del historico de sus declaraciones 	./mod_contribuyente/principal_c	f
114	113	Extemporaneas	multas extemporaneas	./mod_contribuyente/contribuyente_c/listado_multas_extemporaneas	f
115	113	Reparo Fiscal	multas por omisos	./mod_contribuyente/contribuyente_c/listado_multas_culminatoria	f
116	113	Sumario	multas por sumario	./mod_contribuyente/contribuyente_c/listado_multas_sumario	f
\.


--
-- TOC entry 3988 (class 0 OID 0)
-- Dependencies: 306
-- Name: tbl_modulo_id_modulo_seq; Type: SEQUENCE SET; Schema: segContribu; Owner: postgres
--

SELECT pg_catalog.setval('tbl_modulo_id_modulo_seq', 116, true);


--
-- TOC entry 3313 (class 0 OID 129007)
-- Dependencies: 307 3321
-- Data for Name: tbl_permiso_contribu; Type: TABLE DATA; Schema: segContribu; Owner: postgres
--

COPY tbl_permiso_contribu (id_permiso, id_modulo, id_rol, int_permiso, bln_borrado) FROM stdin;
24	89	4	1	f
25	90	4	1	f
26	92	1	1	f
27	93	1	1	f
28	99	1	1	f
29	100	1	1	f
30	101	1	1	f
31	106	1	1	f
32	107	1	1	f
33	109	1	1	t
34	113	1	1	f
35	89	1	1	f
36	90	1	1	f
37	102	1	1	f
38	109	1	1	f
\.


--
-- TOC entry 3989 (class 0 OID 0)
-- Dependencies: 308
-- Name: tbl_permiso_id_permiso_seq; Type: SEQUENCE SET; Schema: segContribu; Owner: postgres
--

SELECT pg_catalog.setval('tbl_permiso_id_permiso_seq', 38, true);


--
-- TOC entry 3315 (class 0 OID 129013)
-- Dependencies: 309 3321
-- Data for Name: tbl_rol_contribu; Type: TABLE DATA; Schema: segContribu; Owner: postgres
--

COPY tbl_rol_contribu (id_rol, str_rol, str_descripcion, bln_borrado) FROM stdin;
1	Administrador	Administrador del sistema	f
2	Coordinador	Coordinador de la sala situacional	f
3	Analista	Analista de seguimiento	f
4	Datos Iniciales	Carga Inicial de Datos del contribuyente	f
\.


--
-- TOC entry 3990 (class 0 OID 0)
-- Dependencies: 310
-- Name: tbl_rol_id_rol_seq; Type: SEQUENCE SET; Schema: segContribu; Owner: postgres
--

SELECT pg_catalog.setval('tbl_rol_id_rol_seq', 4, true);


--
-- TOC entry 3317 (class 0 OID 129022)
-- Dependencies: 311 3321
-- Data for Name: tbl_rol_usuario_contribu; Type: TABLE DATA; Schema: segContribu; Owner: postgres
--

COPY tbl_rol_usuario_contribu (id_rol_usuario, id_rol, id_usuario, bln_borrado) FROM stdin;
1	1	1	f
2	1	2	f
3	1	3	f
4	1	4	f
5	1	5	f
6	1	6	f
7	1	7	f
8	1	8	f
9	1	9	f
10	1	10	f
11	1	11	f
12	1	12	f
13	1	13	f
14	1	14	f
15	1	15	f
16	1	16	f
17	1	17	f
18	1	18	f
19	1	19	f
20	1	20	f
21	1	21	f
22	1	22	f
23	1	23	f
24	1	24	f
25	1	25	f
26	1	26	f
27	1	27	f
28	1	28	f
29	1	29	f
30	1	30	f
31	1	31	f
32	1	32	f
33	1	33	f
34	1	34	f
35	1	35	f
36	1	36	f
37	1	37	f
38	1	38	f
39	1	39	f
40	1	40	f
41	1	41	f
42	1	42	f
43	1	43	f
44	1	44	f
45	1	45	f
46	1	46	f
47	1	47	f
48	1	48	f
49	1	49	f
50	1	50	f
51	1	51	f
52	1	52	f
53	1	53	f
54	1	54	f
55	1	55	f
56	1	56	f
57	1	57	f
58	1	58	f
59	1	60	f
60	1	61	f
61	1	62	f
62	1	63	f
63	1	64	f
64	1	65	f
65	1	66	f
66	1	67	f
67	1	68	f
68	1	69	f
69	1	70	f
70	1	71	f
71	1	72	f
72	1	73	f
73	1	74	f
74	1	75	f
75	1	76	f
76	1	77	f
77	1	78	f
78	1	79	f
79	1	80	f
80	1	81	f
81	1	82	f
82	1	83	f
83	1	84	f
84	1	85	f
85	1	86	f
86	1	87	f
87	1	88	f
88	1	89	f
89	1	90	f
90	1	91	f
91	1	92	f
92	1	93	f
93	1	94	f
94	1	95	f
95	1	96	f
96	1	97	f
97	1	98	f
98	1	99	f
99	1	100	f
100	1	101	f
101	1	102	f
102	1	103	f
103	1	104	f
104	1	105	f
105	1	106	f
106	1	107	f
107	1	108	f
108	1	109	f
109	1	110	f
110	1	111	f
111	1	112	f
112	1	113	f
113	1	114	f
114	1	115	f
115	1	116	f
116	1	117	f
117	1	118	f
118	1	119	f
119	1	120	f
120	1	121	f
121	1	122	f
122	1	123	f
123	1	124	f
124	1	125	f
125	1	126	f
126	1	127	f
127	1	128	f
128	1	129	f
129	1	130	f
130	1	131	f
131	1	132	f
132	1	133	f
133	1	134	f
134	1	138	f
135	1	139	f
136	1	140	f
137	1	141	f
138	1	142	f
139	1	143	f
140	1	144	f
143	4	146	f
144	1	146	f
145	1	147	f
146	1	148	f
147	1	153	f
142	1	145	f
141	1	145	t
\.


--
-- TOC entry 3991 (class 0 OID 0)
-- Dependencies: 312
-- Name: tbl_rol_usuario_id_rol_usuario_seq; Type: SEQUENCE SET; Schema: segContribu; Owner: postgres
--

SELECT pg_catalog.setval('tbl_rol_usuario_id_rol_usuario_seq', 147, true);


--
-- TOC entry 3319 (class 0 OID 129028)
-- Dependencies: 313 3321
-- Data for Name: tbl_usuario_rol_contribu; Type: TABLE DATA; Schema: segContribu; Owner: postgres
--

COPY tbl_usuario_rol_contribu (id_usuario_rol, id_usuario, id_rol, bol_borrado) FROM stdin;
\.


--
-- TOC entry 3992 (class 0 OID 0)
-- Dependencies: 314
-- Name: tbl_usuario_rol_id_usuario_rol_seq; Type: SEQUENCE SET; Schema: segContribu; Owner: postgres
--

SELECT pg_catalog.setval('tbl_usuario_rol_id_usuario_rol_seq', 16, true);


SET search_path = datos, pg_catalog;

--
-- TOC entry 2745 (class 2606 OID 129106)
-- Dependencies: 226 226 226 3322
-- Name: CT_Accionis_IDContribu_Ci; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY accionis
    ADD CONSTRAINT "CT_Accionis_IDContribu_Ci" UNIQUE (contribuid, ci);


--
-- TOC entry 2544 (class 2606 OID 129108)
-- Dependencies: 167 167 3322
-- Name: CT_ActiExon_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY actiecon
    ADD CONSTRAINT "CT_ActiExon_Nombre" UNIQUE (nombre);


--
-- TOC entry 2549 (class 2606 OID 129110)
-- Dependencies: 169 169 169 3322
-- Name: CT_AlicImp_IDTipoCont_Ano; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY alicimp
    ADD CONSTRAINT "CT_AlicImp_IDTipoCont_Ano" UNIQUE (tipocontid, ano);


--
-- TOC entry 2556 (class 2606 OID 129112)
-- Dependencies: 171 171 171 3322
-- Name: CT_AsiendoD_IDAsiento_Referencia; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY asientod
    ADD CONSTRAINT "CT_AsiendoD_IDAsiento_Referencia" UNIQUE (asientoid, referencia);


--
-- TOC entry 2767 (class 2606 OID 129114)
-- Dependencies: 230 230 3322
-- Name: CT_AsientoM_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY asientom
    ADD CONSTRAINT "CT_AsientoM_Nombre" UNIQUE (nombre);


--
-- TOC entry 2756 (class 2606 OID 129116)
-- Dependencies: 229 229 229 229 3322
-- Name: CT_Asiento_NuAsiento_Mes_Ano; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY asiento
    ADD CONSTRAINT "CT_Asiento_NuAsiento_Mes_Ano" UNIQUE (nuasiento, mes, ano);


--
-- TOC entry 2564 (class 2606 OID 129118)
-- Dependencies: 174 174 3322
-- Name: CT_BaCuenta_Cuenta; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY bacuenta
    ADD CONSTRAINT "CT_BaCuenta_Cuenta" UNIQUE (cuenta);


--
-- TOC entry 2570 (class 2606 OID 129120)
-- Dependencies: 176 176 3322
-- Name: CT_Bancos_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY bancos
    ADD CONSTRAINT "CT_Bancos_Nombre" UNIQUE (nombre);


--
-- TOC entry 2579 (class 2606 OID 129122)
-- Dependencies: 180 180 180 3322
-- Name: CT_CalPagos_Ano_IDTiPeGrav; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY calpago
    ADD CONSTRAINT "CT_CalPagos_Ano_IDTiPeGrav" UNIQUE (ano, tipegravid);


--
-- TOC entry 2581 (class 2606 OID 129124)
-- Dependencies: 180 180 180 3322
-- Name: CT_CalPagos_Nombre_Ano; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY calpago
    ADD CONSTRAINT "CT_CalPagos_Nombre_Ano" UNIQUE (nombre, ano);


--
-- TOC entry 2588 (class 2606 OID 129126)
-- Dependencies: 182 182 3322
-- Name: CT_Cargos_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY cargos
    ADD CONSTRAINT "CT_Cargos_Nombre" UNIQUE (nombre);


--
-- TOC entry 2593 (class 2606 OID 129128)
-- Dependencies: 184 184 184 3322
-- Name: CT_Ciudades_IDEstado_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ciudades
    ADD CONSTRAINT "CT_Ciudades_IDEstado_Nombre" UNIQUE (estadoid, nombre);


--
-- TOC entry 2599 (class 2606 OID 129130)
-- Dependencies: 186 186 186 3322
-- Name: CT_ConUsuCo_IDConUsu_IDContribu; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY conusuco
    ADD CONSTRAINT "CT_ConUsuCo_IDConUsu_IDContribu" UNIQUE (conusuid, contribuid);


--
-- TOC entry 2608 (class 2606 OID 129132)
-- Dependencies: 190 190 3322
-- Name: CT_ConUsuTo_Token; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY conusuto
    ADD CONSTRAINT "CT_ConUsuTo_Token" UNIQUE (token);


--
-- TOC entry 2783 (class 2606 OID 129134)
-- Dependencies: 240 240 240 3322
-- Name: CT_ContribuTi_ContribuID_TipoContID; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY contributi
    ADD CONSTRAINT "CT_ContribuTi_ContribuID_TipoContID" UNIQUE (contribuid, tipocontid);


--
-- TOC entry 2621 (class 2606 OID 129136)
-- Dependencies: 194 194 3322
-- Name: CT_Contribu_NumRegCine; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY contribu
    ADD CONSTRAINT "CT_Contribu_NumRegCine" UNIQUE (numregcine);


--
-- TOC entry 2623 (class 2606 OID 129138)
-- Dependencies: 194 194 3322
-- Name: CT_Contribu_RazonSocia; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY contribu
    ADD CONSTRAINT "CT_Contribu_RazonSocia" UNIQUE (razonsocia);


--
-- TOC entry 2625 (class 2606 OID 129140)
-- Dependencies: 194 194 3322
-- Name: CT_Contribu_Rif; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY contribu
    ADD CONSTRAINT "CT_Contribu_Rif" UNIQUE (rif);


--
-- TOC entry 2802 (class 2606 OID 129142)
-- Dependencies: 251 251 3322
-- Name: CT_Decla_NuDeclara; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT "CT_Decla_NuDeclara" UNIQUE (nudeclara);


--
-- TOC entry 2804 (class 2606 OID 129144)
-- Dependencies: 251 251 3322
-- Name: CT_Decla_NuDeposito; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT "CT_Decla_NuDeposito" UNIQUE (nudeposito);


--
-- TOC entry 2634 (class 2606 OID 129146)
-- Dependencies: 196 196 3322
-- Name: CT_Declara_NuDeclara; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY declara_viejo
    ADD CONSTRAINT "CT_Declara_NuDeclara" UNIQUE (nudeclara);


--
-- TOC entry 2636 (class 2606 OID 129148)
-- Dependencies: 196 196 3322
-- Name: CT_Declara_NuDeposito; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY declara_viejo
    ADD CONSTRAINT "CT_Declara_NuDeposito" UNIQUE (nudeposito);


--
-- TOC entry 2650 (class 2606 OID 129150)
-- Dependencies: 198 198 3322
-- Name: CT_Departam_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY departam
    ADD CONSTRAINT "CT_Departam_Nombre" UNIQUE (nombre);


--
-- TOC entry 2832 (class 2606 OID 129152)
-- Dependencies: 266 266 3322
-- Name: CT_Document_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY document
    ADD CONSTRAINT "CT_Document_Nombre" UNIQUE (nombre);


--
-- TOC entry 2655 (class 2606 OID 129154)
-- Dependencies: 200 200 200 3322
-- Name: CT_EntidadD_IDEntidad_Accion; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY entidadd
    ADD CONSTRAINT "CT_EntidadD_IDEntidad_Accion" UNIQUE (entidadid, accion);


--
-- TOC entry 2657 (class 2606 OID 129156)
-- Dependencies: 200 200 200 3322
-- Name: CT_EntidadD_IDEntidad_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY entidadd
    ADD CONSTRAINT "CT_EntidadD_IDEntidad_Nombre" UNIQUE (entidadid, nombre);


--
-- TOC entry 2659 (class 2606 OID 129158)
-- Dependencies: 200 200 200 3322
-- Name: CT_EntidadD_IDEntidad_Orden; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY entidadd
    ADD CONSTRAINT "CT_EntidadD_IDEntidad_Orden" UNIQUE (entidadid, orden);


--
-- TOC entry 2667 (class 2606 OID 129160)
-- Dependencies: 202 202 3322
-- Name: CT_Entidad_Entidad; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY entidad
    ADD CONSTRAINT "CT_Entidad_Entidad" UNIQUE (entidad);


--
-- TOC entry 2669 (class 2606 OID 129162)
-- Dependencies: 202 202 3322
-- Name: CT_Entidad_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY entidad
    ADD CONSTRAINT "CT_Entidad_Nombre" UNIQUE (nombre);


--
-- TOC entry 2671 (class 2606 OID 129164)
-- Dependencies: 202 202 3322
-- Name: CT_Entidad_Orden; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY entidad
    ADD CONSTRAINT "CT_Entidad_Orden" UNIQUE (orden);


--
-- TOC entry 2675 (class 2606 OID 129166)
-- Dependencies: 204 204 3322
-- Name: CT_Estados_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY estados
    ADD CONSTRAINT "CT_Estados_Nombre" UNIQUE (nombre);


--
-- TOC entry 2680 (class 2606 OID 129168)
-- Dependencies: 206 206 206 3322
-- Name: CT_PerUsuD_IDPerUsu_IDEntidadD; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY perusud
    ADD CONSTRAINT "CT_PerUsuD_IDPerUsu_IDEntidadD" UNIQUE (perusuid, entidaddid);


--
-- TOC entry 2687 (class 2606 OID 129170)
-- Dependencies: 208 208 3322
-- Name: CT_PerUsu_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY perusu
    ADD CONSTRAINT "CT_PerUsu_Nombre" UNIQUE (nombre);


--
-- TOC entry 2692 (class 2606 OID 129172)
-- Dependencies: 210 210 3322
-- Name: CT_PregSecr_Pregunta; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY pregsecr
    ADD CONSTRAINT "CT_PregSecr_Pregunta" UNIQUE (nombre);


--
-- TOC entry 2697 (class 2606 OID 129174)
-- Dependencies: 212 212 212 3322
-- Name: CT_RepLegal_IDContribu_Ci; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY replegal
    ADD CONSTRAINT "CT_RepLegal_IDContribu_Ci" UNIQUE (contribuid, ci);


--
-- TOC entry 2708 (class 2606 OID 129176)
-- Dependencies: 214 214 3322
-- Name: CT_TDeclara_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tdeclara
    ADD CONSTRAINT "CT_TDeclara_Nombre" UNIQUE (nombre);


--
-- TOC entry 2713 (class 2606 OID 129178)
-- Dependencies: 216 216 3322
-- Name: CT_TiPeGrav_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tipegrav
    ADD CONSTRAINT "CT_TiPeGrav_Nombre" UNIQUE (nombre);


--
-- TOC entry 2718 (class 2606 OID 129180)
-- Dependencies: 218 218 3322
-- Name: CT_TipoCont_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tipocont
    ADD CONSTRAINT "CT_TipoCont_Nombre" UNIQUE (nombre);


--
-- TOC entry 2853 (class 2606 OID 129182)
-- Dependencies: 275 275 3322
-- Name: CT_TmpContri_NumRegCine; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tmpcontri
    ADD CONSTRAINT "CT_TmpContri_NumRegCine" UNIQUE (numregcine);


--
-- TOC entry 2855 (class 2606 OID 129184)
-- Dependencies: 275 275 3322
-- Name: CT_TmpContri_RazonSocia; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tmpcontri
    ADD CONSTRAINT "CT_TmpContri_RazonSocia" UNIQUE (razonsocia);


--
-- TOC entry 2857 (class 2606 OID 129186)
-- Dependencies: 275 275 3322
-- Name: CT_TmpContri_Rif; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tmpcontri
    ADD CONSTRAINT "CT_TmpContri_Rif" UNIQUE (rif);


--
-- TOC entry 2867 (class 2606 OID 129188)
-- Dependencies: 276 276 276 3322
-- Name: CT_TmpReLegal_IDContribu_Ci; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tmprelegal
    ADD CONSTRAINT "CT_TmpReLegal_IDContribu_Ci" UNIQUE (contribuid, ci);


--
-- TOC entry 2734 (class 2606 OID 129190)
-- Dependencies: 224 224 3322
-- Name: CT_USFonPro_Email; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY usfonpro
    ADD CONSTRAINT "CT_USFonPro_Email" UNIQUE (email);


--
-- TOC entry 2724 (class 2606 OID 129192)
-- Dependencies: 220 220 3322
-- Name: CT_UndTrib_Fecha; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY undtrib
    ADD CONSTRAINT "CT_UndTrib_Fecha" UNIQUE (fecha);


--
-- TOC entry 2729 (class 2606 OID 129194)
-- Dependencies: 222 222 3322
-- Name: CT_UsFonpTo_Token; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY usfonpto
    ADD CONSTRAINT "CT_UsFonpTo_Token" UNIQUE (token);


--
-- TOC entry 2736 (class 2606 OID 129196)
-- Dependencies: 224 224 3322
-- Name: CT_UsFonpro_Login; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY usfonpro
    ADD CONSTRAINT "CT_UsFonpro_Login" UNIQUE (login);


--
-- TOC entry 2845 (class 2606 OID 129198)
-- Dependencies: 274 274 274 3322
-- Name: CT_tmpAccioni_ContribuID_Ci; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tmpaccioni
    ADD CONSTRAINT "CT_tmpAccioni_ContribuID_Ci" UNIQUE (contribuid, ci);


--
-- TOC entry 2752 (class 2606 OID 129200)
-- Dependencies: 226 226 3322
-- Name: PK_Accionis; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY accionis
    ADD CONSTRAINT "PK_Accionis" PRIMARY KEY (id);


--
-- TOC entry 2547 (class 2606 OID 129202)
-- Dependencies: 167 167 3322
-- Name: PK_ActiEcon; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY actiecon
    ADD CONSTRAINT "PK_ActiEcon" PRIMARY KEY (id);

ALTER TABLE actiecon CLUSTER ON "PK_ActiEcon";


--
-- TOC entry 2554 (class 2606 OID 129204)
-- Dependencies: 169 169 3322
-- Name: PK_AlicImp; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY alicimp
    ADD CONSTRAINT "PK_AlicImp" PRIMARY KEY (id);

ALTER TABLE alicimp CLUSTER ON "PK_AlicImp";


--
-- TOC entry 2765 (class 2606 OID 129206)
-- Dependencies: 229 229 3322
-- Name: PK_Asiento; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY asiento
    ADD CONSTRAINT "PK_Asiento" PRIMARY KEY (id);

ALTER TABLE asiento CLUSTER ON "PK_Asiento";


--
-- TOC entry 2562 (class 2606 OID 129208)
-- Dependencies: 171 171 3322
-- Name: PK_AsientoD; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY asientod
    ADD CONSTRAINT "PK_AsientoD" PRIMARY KEY (id);

ALTER TABLE asientod CLUSTER ON "PK_AsientoD";


--
-- TOC entry 2770 (class 2606 OID 129210)
-- Dependencies: 230 230 3322
-- Name: PK_AsientoM; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY asientom
    ADD CONSTRAINT "PK_AsientoM" PRIMARY KEY (id);

ALTER TABLE asientom CLUSTER ON "PK_AsientoM";


--
-- TOC entry 2775 (class 2606 OID 129212)
-- Dependencies: 232 232 3322
-- Name: PK_AsientoMD; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY asientomd
    ADD CONSTRAINT "PK_AsientoMD" PRIMARY KEY (id);

ALTER TABLE asientomd CLUSTER ON "PK_AsientoMD";


--
-- TOC entry 2568 (class 2606 OID 129214)
-- Dependencies: 174 174 3322
-- Name: PK_BaCuenta; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY bacuenta
    ADD CONSTRAINT "PK_BaCuenta" PRIMARY KEY (id);

ALTER TABLE bacuenta CLUSTER ON "PK_BaCuenta";


--
-- TOC entry 2573 (class 2606 OID 129216)
-- Dependencies: 176 176 3322
-- Name: PK_Bancos; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY bancos
    ADD CONSTRAINT "PK_Bancos" PRIMARY KEY (id);

ALTER TABLE bancos CLUSTER ON "PK_Bancos";


--
-- TOC entry 2577 (class 2606 OID 129218)
-- Dependencies: 178 178 3322
-- Name: PK_CalPagoD; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY calpagod
    ADD CONSTRAINT "PK_CalPagoD" PRIMARY KEY (id);

ALTER TABLE calpagod CLUSTER ON "PK_CalPagoD";


--
-- TOC entry 2586 (class 2606 OID 129220)
-- Dependencies: 180 180 3322
-- Name: PK_CalPagos; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY calpago
    ADD CONSTRAINT "PK_CalPagos" PRIMARY KEY (id);

ALTER TABLE calpago CLUSTER ON "PK_CalPagos";


--
-- TOC entry 2591 (class 2606 OID 129222)
-- Dependencies: 182 182 3322
-- Name: PK_Cargos; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY cargos
    ADD CONSTRAINT "PK_Cargos" PRIMARY KEY (id);

ALTER TABLE cargos CLUSTER ON "PK_Cargos";


--
-- TOC entry 2597 (class 2606 OID 129224)
-- Dependencies: 184 184 3322
-- Name: PK_Ciudades; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ciudades
    ADD CONSTRAINT "PK_Ciudades" PRIMARY KEY (id);

ALTER TABLE ciudades CLUSTER ON "PK_Ciudades";


--
-- TOC entry 2617 (class 2606 OID 129226)
-- Dependencies: 192 192 3322
-- Name: PK_ConUsu; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY conusu
    ADD CONSTRAINT "PK_ConUsu" PRIMARY KEY (id);

ALTER TABLE conusu CLUSTER ON "PK_ConUsu";


--
-- TOC entry 2603 (class 2606 OID 129228)
-- Dependencies: 186 186 3322
-- Name: PK_ConUsuCo; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY conusuco
    ADD CONSTRAINT "PK_ConUsuCo" PRIMARY KEY (id);

ALTER TABLE conusuco CLUSTER ON "PK_ConUsuCo";


--
-- TOC entry 2606 (class 2606 OID 129230)
-- Dependencies: 188 188 3322
-- Name: PK_ConUsuTi; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY conusuti
    ADD CONSTRAINT "PK_ConUsuTi" PRIMARY KEY (id);

ALTER TABLE conusuti CLUSTER ON "PK_ConUsuTi";


--
-- TOC entry 2611 (class 2606 OID 129232)
-- Dependencies: 190 190 3322
-- Name: PK_ConUsuTo; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY conusuto
    ADD CONSTRAINT "PK_ConUsuTo" PRIMARY KEY (id);

ALTER TABLE conusuto CLUSTER ON "PK_ConUsuTo";


--
-- TOC entry 2632 (class 2606 OID 129234)
-- Dependencies: 194 194 3322
-- Name: PK_Contribu; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY contribu
    ADD CONSTRAINT "PK_Contribu" PRIMARY KEY (id);

ALTER TABLE contribu CLUSTER ON "PK_Contribu";


--
-- TOC entry 2787 (class 2606 OID 129236)
-- Dependencies: 240 240 3322
-- Name: PK_ContribuTi; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY contributi
    ADD CONSTRAINT "PK_ContribuTi" PRIMARY KEY (id);

ALTER TABLE contributi CLUSTER ON "PK_ContribuTi";


--
-- TOC entry 2800 (class 2606 OID 129238)
-- Dependencies: 250 250 3322
-- Name: PK_CtaConta; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ctaconta
    ADD CONSTRAINT "PK_CtaConta" PRIMARY KEY (cuenta);

ALTER TABLE ctaconta CLUSTER ON "PK_CtaConta";


--
-- TOC entry 2816 (class 2606 OID 129240)
-- Dependencies: 251 251 3322
-- Name: PK_Decla; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT "PK_Decla" PRIMARY KEY (id);


--
-- TOC entry 2648 (class 2606 OID 129242)
-- Dependencies: 196 196 3322
-- Name: PK_Declara; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY declara_viejo
    ADD CONSTRAINT "PK_Declara" PRIMARY KEY (id);

ALTER TABLE declara_viejo CLUSTER ON "PK_Declara";


--
-- TOC entry 2652 (class 2606 OID 129244)
-- Dependencies: 198 198 3322
-- Name: PK_Departam; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY departam
    ADD CONSTRAINT "PK_Departam" PRIMARY KEY (id);

ALTER TABLE departam CLUSTER ON "PK_Departam";


--
-- TOC entry 2835 (class 2606 OID 129246)
-- Dependencies: 266 266 3322
-- Name: PK_Document; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY document
    ADD CONSTRAINT "PK_Document" PRIMARY KEY (id);

ALTER TABLE document CLUSTER ON "PK_Document";


--
-- TOC entry 2673 (class 2606 OID 129248)
-- Dependencies: 202 202 3322
-- Name: PK_Entidad; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY entidad
    ADD CONSTRAINT "PK_Entidad" PRIMARY KEY (id);

ALTER TABLE entidad CLUSTER ON "PK_Entidad";


--
-- TOC entry 2665 (class 2606 OID 129250)
-- Dependencies: 200 200 3322
-- Name: PK_EntidadD; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY entidadd
    ADD CONSTRAINT "PK_EntidadD" PRIMARY KEY (id);

ALTER TABLE entidadd CLUSTER ON "PK_EntidadD";


--
-- TOC entry 2678 (class 2606 OID 129252)
-- Dependencies: 204 204 3322
-- Name: PK_Estados; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY estados
    ADD CONSTRAINT "PK_Estados" PRIMARY KEY (id);

ALTER TABLE estados CLUSTER ON "PK_Estados";


--
-- TOC entry 2685 (class 2606 OID 129254)
-- Dependencies: 206 206 3322
-- Name: PK_PerUsuD; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY perusud
    ADD CONSTRAINT "PK_PerUsuD" PRIMARY KEY (id);

ALTER TABLE perusud CLUSTER ON "PK_PerUsuD";


--
-- TOC entry 2690 (class 2606 OID 129256)
-- Dependencies: 208 208 3322
-- Name: PK_PerUsu_IDPerUsu; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY perusu
    ADD CONSTRAINT "PK_PerUsu_IDPerUsu" PRIMARY KEY (id);

ALTER TABLE perusu CLUSTER ON "PK_PerUsu_IDPerUsu";


--
-- TOC entry 2695 (class 2606 OID 129258)
-- Dependencies: 210 210 3322
-- Name: PK_PregSecr; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY pregsecr
    ADD CONSTRAINT "PK_PregSecr" PRIMARY KEY (id);

ALTER TABLE pregsecr CLUSTER ON "PK_PregSecr";


--
-- TOC entry 2706 (class 2606 OID 129260)
-- Dependencies: 212 212 3322
-- Name: PK_RepLegal; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY replegal
    ADD CONSTRAINT "PK_RepLegal" PRIMARY KEY (id);

ALTER TABLE replegal CLUSTER ON "PK_RepLegal";


--
-- TOC entry 2711 (class 2606 OID 129262)
-- Dependencies: 214 214 3322
-- Name: PK_TDeclara; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tdeclara
    ADD CONSTRAINT "PK_TDeclara" PRIMARY KEY (id);

ALTER TABLE tdeclara CLUSTER ON "PK_TDeclara";


--
-- TOC entry 2716 (class 2606 OID 129264)
-- Dependencies: 216 216 3322
-- Name: PK_TiPeGrav; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tipegrav
    ADD CONSTRAINT "PK_TiPeGrav" PRIMARY KEY (id);

ALTER TABLE tipegrav CLUSTER ON "PK_TiPeGrav";


--
-- TOC entry 2722 (class 2606 OID 129266)
-- Dependencies: 218 218 3322
-- Name: PK_TipoCont; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tipocont
    ADD CONSTRAINT "PK_TipoCont" PRIMARY KEY (id);

ALTER TABLE tipocont CLUSTER ON "PK_TipoCont";


--
-- TOC entry 2865 (class 2606 OID 129268)
-- Dependencies: 275 275 3322
-- Name: PK_TmpContri; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tmpcontri
    ADD CONSTRAINT "PK_TmpContri" PRIMARY KEY (id);


--
-- TOC entry 2875 (class 2606 OID 129270)
-- Dependencies: 276 276 3322
-- Name: PK_TmpReLegal; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tmprelegal
    ADD CONSTRAINT "PK_TmpReLegal" PRIMARY KEY (id);


--
-- TOC entry 2727 (class 2606 OID 129272)
-- Dependencies: 220 220 3322
-- Name: PK_UndTrib; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY undtrib
    ADD CONSTRAINT "PK_UndTrib" PRIMARY KEY (id);

ALTER TABLE undtrib CLUSTER ON "PK_UndTrib";


--
-- TOC entry 2743 (class 2606 OID 129274)
-- Dependencies: 224 224 3322
-- Name: PK_UsFonPro; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY usfonpro
    ADD CONSTRAINT "PK_UsFonPro" PRIMARY KEY (id);

ALTER TABLE usfonpro CLUSTER ON "PK_UsFonPro";


--
-- TOC entry 2732 (class 2606 OID 129276)
-- Dependencies: 222 222 3322
-- Name: PK_UsFonpTo; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY usfonpto
    ADD CONSTRAINT "PK_UsFonpTo" PRIMARY KEY (id);

ALTER TABLE usfonpto CLUSTER ON "PK_UsFonpTo";


--
-- TOC entry 2781 (class 2606 OID 129278)
-- Dependencies: 238 238 3322
-- Name: PK_contribcalc; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY contrib_calc
    ADD CONSTRAINT "PK_contribcalc" PRIMARY KEY (id);


--
-- TOC entry 2843 (class 2606 OID 129280)
-- Dependencies: 273 273 3322
-- Name: PK_reparos; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY reparos
    ADD CONSTRAINT "PK_reparos" PRIMARY KEY (id);


--
-- TOC entry 2851 (class 2606 OID 129282)
-- Dependencies: 274 274 3322
-- Name: PK_tmpAccioni; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tmpaccioni
    ADD CONSTRAINT "PK_tmpAccioni" PRIMARY KEY (id);


--
-- TOC entry 2777 (class 2606 OID 129284)
-- Dependencies: 234 234 3322
-- Name: fk-asignacion-fiscla; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY asignacion_fiscales
    ADD CONSTRAINT "fk-asignacion-fiscla" PRIMARY KEY (id);


--
-- TOC entry 2619 (class 2606 OID 129286)
-- Dependencies: 192 192 3322
-- Name: login_conusu_unico; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY conusu
    ADD CONSTRAINT login_conusu_unico UNIQUE (login);


--
-- TOC entry 2795 (class 2606 OID 129288)
-- Dependencies: 246 246 3322
-- Name: pk-correlativo-actas; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY correlativos_actas
    ADD CONSTRAINT "pk-correlativo-actas" PRIMARY KEY (id);


--
-- TOC entry 2837 (class 2606 OID 129290)
-- Dependencies: 268 268 3322
-- Name: pk-interesbcv; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY interes_bcv
    ADD CONSTRAINT "pk-interesbcv" PRIMARY KEY (id);


--
-- TOC entry 2754 (class 2606 OID 129292)
-- Dependencies: 227 227 3322
-- Name: pk_actas_reparo_id; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY actas_reparo
    ADD CONSTRAINT pk_actas_reparo_id PRIMARY KEY (id);


--
-- TOC entry 2779 (class 2606 OID 129294)
-- Dependencies: 236 236 3322
-- Name: pk_con_img_doc; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY con_img_doc
    ADD CONSTRAINT pk_con_img_doc PRIMARY KEY (id);


--
-- TOC entry 2789 (class 2606 OID 129296)
-- Dependencies: 242 242 3322
-- Name: pk_conusu_interno; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY conusu_interno
    ADD CONSTRAINT pk_conusu_interno PRIMARY KEY (id);


--
-- TOC entry 2791 (class 2606 OID 129298)
-- Dependencies: 244 244 3322
-- Name: pk_conusu_tipocont; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY conusu_tipocont
    ADD CONSTRAINT pk_conusu_tipocont PRIMARY KEY (id);


--
-- TOC entry 2797 (class 2606 OID 129300)
-- Dependencies: 248 248 3322
-- Name: pk_correos_enviados; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY correos_enviados
    ADD CONSTRAINT pk_correos_enviados PRIMARY KEY (id);


--
-- TOC entry 2822 (class 2606 OID 129302)
-- Dependencies: 256 256 3322
-- Name: pk_descargos; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY descargos
    ADD CONSTRAINT pk_descargos PRIMARY KEY (id);


--
-- TOC entry 2828 (class 2606 OID 129304)
-- Dependencies: 262 262 3322
-- Name: pk_deta_contirbcalc; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY detalles_contrib_calc
    ADD CONSTRAINT pk_deta_contirbcalc PRIMARY KEY (id);


--
-- TOC entry 2824 (class 2606 OID 129306)
-- Dependencies: 258 258 3322
-- Name: pk_detalle_interes; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY detalle_interes
    ADD CONSTRAINT pk_detalle_interes PRIMARY KEY (id);


--
-- TOC entry 2826 (class 2606 OID 129308)
-- Dependencies: 260 260 3322
-- Name: pk_detalle_interes_n; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY detalle_interes_viejo
    ADD CONSTRAINT pk_detalle_interes_n PRIMARY KEY (id);


--
-- TOC entry 2830 (class 2606 OID 129310)
-- Dependencies: 264 264 3322
-- Name: pk_detalles_fiscalizacion; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY dettalles_fizcalizacion
    ADD CONSTRAINT pk_detalles_fiscalizacion PRIMARY KEY (id);


--
-- TOC entry 2793 (class 2606 OID 129312)
-- Dependencies: 244 244 244 3322
-- Name: uq_tipoconid; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY conusu_tipocont
    ADD CONSTRAINT uq_tipoconid UNIQUE (conusuid, tipocontid);


SET search_path = historial, pg_catalog;

--
-- TOC entry 2882 (class 2606 OID 129314)
-- Dependencies: 278 278 3322
-- Name: PK_Bitacora; Type: CONSTRAINT; Schema: historial; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY bitacora
    ADD CONSTRAINT "PK_Bitacora" PRIMARY KEY (id);

ALTER TABLE bitacora CLUSTER ON "PK_Bitacora";


SET search_path = pre_aprobacion, pg_catalog;

--
-- TOC entry 2884 (class 2606 OID 129316)
-- Dependencies: 280 280 3322
-- Name: PK_datos_cnac; Type: CONSTRAINT; Schema: pre_aprobacion; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY datos_cnac
    ADD CONSTRAINT "PK_datos_cnac" PRIMARY KEY (id);


--
-- TOC entry 2818 (class 2606 OID 129318)
-- Dependencies: 253 253 3322
-- Name: pk-intereses; Type: CONSTRAINT; Schema: pre_aprobacion; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY intereses
    ADD CONSTRAINT "pk-intereses" PRIMARY KEY (id);


--
-- TOC entry 2820 (class 2606 OID 129320)
-- Dependencies: 254 254 3322
-- Name: pk-multa; Type: CONSTRAINT; Schema: pre_aprobacion; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY multas
    ADD CONSTRAINT "pk-multa" PRIMARY KEY (id);


SET search_path = public, pg_catalog;

--
-- TOC entry 2886 (class 2606 OID 129322)
-- Dependencies: 284 284 3322
-- Name: pk_contribucalc; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY contrib_calc
    ADD CONSTRAINT pk_contribucalc PRIMARY KEY (id);


SET search_path = seg, pg_catalog;

--
-- TOC entry 2894 (class 2606 OID 129324)
-- Dependencies: 290 290 3322
-- Name: CT_oficinas_cod_estructura; Type: CONSTRAINT; Schema: seg; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_oficinas
    ADD CONSTRAINT "CT_oficinas_cod_estructura" UNIQUE (cod_estructura);


--
-- TOC entry 2890 (class 2606 OID 129326)
-- Dependencies: 287 287 3322
-- Name: pk_ci_sessions; Type: CONSTRAINT; Schema: seg; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_ci_sessions
    ADD CONSTRAINT pk_ci_sessions PRIMARY KEY (session_id);


--
-- TOC entry 2892 (class 2606 OID 129328)
-- Dependencies: 288 288 3322
-- Name: pk_modulo; Type: CONSTRAINT; Schema: seg; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_modulo
    ADD CONSTRAINT pk_modulo PRIMARY KEY (id_modulo);


--
-- TOC entry 2896 (class 2606 OID 129330)
-- Dependencies: 290 290 3322
-- Name: pk_oficinas; Type: CONSTRAINT; Schema: seg; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_oficinas
    ADD CONSTRAINT pk_oficinas PRIMARY KEY (id);


--
-- TOC entry 2898 (class 2606 OID 129332)
-- Dependencies: 292 292 3322
-- Name: pk_permiso; Type: CONSTRAINT; Schema: seg; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_permiso
    ADD CONSTRAINT pk_permiso PRIMARY KEY (id_permiso);


--
-- TOC entry 2902 (class 2606 OID 129334)
-- Dependencies: 296 296 3322
-- Name: pk_rol; Type: CONSTRAINT; Schema: seg; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_rol
    ADD CONSTRAINT pk_rol PRIMARY KEY (id_rol);


--
-- TOC entry 2904 (class 2606 OID 129336)
-- Dependencies: 298 298 3322
-- Name: pk_rol_usuario; Type: CONSTRAINT; Schema: seg; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_rol_usuario
    ADD CONSTRAINT pk_rol_usuario PRIMARY KEY (id_rol_usuario);


--
-- TOC entry 2888 (class 2606 OID 129338)
-- Dependencies: 285 285 3322
-- Name: pk_tblcargos; Type: CONSTRAINT; Schema: seg; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_cargos
    ADD CONSTRAINT pk_tblcargos PRIMARY KEY (id);


--
-- TOC entry 2908 (class 2606 OID 129340)
-- Dependencies: 301 301 3322
-- Name: pk_usuario_rol; Type: CONSTRAINT; Schema: seg; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_usuario_rol
    ADD CONSTRAINT pk_usuario_rol PRIMARY KEY (id_usuario_rol);


--
-- TOC entry 2900 (class 2606 OID 129342)
-- Dependencies: 294 294 3322
-- Name: pkt_permiso; Type: CONSTRAINT; Schema: seg; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_permiso_trampa
    ADD CONSTRAINT pkt_permiso PRIMARY KEY (id_permiso);


--
-- TOC entry 2906 (class 2606 OID 129344)
-- Dependencies: 300 300 3322
-- Name: tbl_session_ci_pkey; Type: CONSTRAINT; Schema: seg; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_session_ci
    ADD CONSTRAINT tbl_session_ci_pkey PRIMARY KEY (session_id);


SET search_path = "segContribu", pg_catalog;

--
-- TOC entry 2910 (class 2606 OID 129346)
-- Dependencies: 305 305 3322
-- Name: pk_modulo; Type: CONSTRAINT; Schema: segContribu; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_modulo_contribu
    ADD CONSTRAINT pk_modulo PRIMARY KEY (id_modulo);


--
-- TOC entry 2912 (class 2606 OID 129348)
-- Dependencies: 307 307 3322
-- Name: pk_permiso; Type: CONSTRAINT; Schema: segContribu; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_permiso_contribu
    ADD CONSTRAINT pk_permiso PRIMARY KEY (id_permiso);


--
-- TOC entry 2914 (class 2606 OID 129350)
-- Dependencies: 309 309 3322
-- Name: pk_rol; Type: CONSTRAINT; Schema: segContribu; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_rol_contribu
    ADD CONSTRAINT pk_rol PRIMARY KEY (id_rol);


--
-- TOC entry 2916 (class 2606 OID 129352)
-- Dependencies: 311 311 3322
-- Name: pk_rol_usuario; Type: CONSTRAINT; Schema: segContribu; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_rol_usuario_contribu
    ADD CONSTRAINT pk_rol_usuario PRIMARY KEY (id_rol_usuario);


--
-- TOC entry 2918 (class 2606 OID 129354)
-- Dependencies: 313 313 3322
-- Name: pk_usuario_rol; Type: CONSTRAINT; Schema: segContribu; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_usuario_rol_contribu
    ADD CONSTRAINT pk_usuario_rol PRIMARY KEY (id_usuario_rol);


SET search_path = datos, pg_catalog;

--
-- TOC entry 2746 (class 1259 OID 129355)
-- Dependencies: 226 3322
-- Name: FKI_Accionis_IDContribu; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Accionis_IDContribu" ON accionis USING btree (contribuid);


--
-- TOC entry 2747 (class 1259 OID 129356)
-- Dependencies: 226 3322
-- Name: FKI_Accionis_UsFonpro_UsuarioID_ID; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Accionis_UsFonpro_UsuarioID_ID" ON accionis USING btree (usuarioid);


--
-- TOC entry 2545 (class 1259 OID 129357)
-- Dependencies: 167 3322
-- Name: FKI_ActiEcon_USFonpro_IDUsuario_IDUsFornpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_ActiEcon_USFonpro_IDUsuario_IDUsFornpro" ON actiecon USING btree (usuarioid);


--
-- TOC entry 2550 (class 1259 OID 129358)
-- Dependencies: 169 3322
-- Name: FKI_AlicImp_TipoCont_IDTipoCont; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_AlicImp_TipoCont_IDTipoCont" ON alicimp USING btree (tipocontid);


--
-- TOC entry 2551 (class 1259 OID 129359)
-- Dependencies: 169 3322
-- Name: FKI_AlicImp_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_AlicImp_UsFonpro_IDUsuario_IDUsFonpro" ON alicimp USING btree (usuarioid);


--
-- TOC entry 2557 (class 1259 OID 129360)
-- Dependencies: 171 3322
-- Name: FKI_AsientoD_Asiento_IDAsiento; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_AsientoD_Asiento_IDAsiento" ON asientod USING btree (asientoid);


--
-- TOC entry 2558 (class 1259 OID 129361)
-- Dependencies: 171 3322
-- Name: FKI_AsientoD_CtaConta_Cuenta; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_AsientoD_CtaConta_Cuenta" ON asientod USING btree (cuenta);


--
-- TOC entry 2559 (class 1259 OID 129362)
-- Dependencies: 171 3322
-- Name: FKI_AsientoD_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_AsientoD_UsFonpro_IDUsuario_IDUsFonpro" ON asientod USING btree (usuarioid);


--
-- TOC entry 2771 (class 1259 OID 129363)
-- Dependencies: 232 3322
-- Name: FKI_AsientoMD_AsientoM_AsientoMID_ID; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_AsientoMD_AsientoM_AsientoMID_ID" ON asientomd USING btree (asientomid);


--
-- TOC entry 2772 (class 1259 OID 129364)
-- Dependencies: 232 3322
-- Name: FKI_AsientoMD_CtaConta_Cuenta; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_AsientoMD_CtaConta_Cuenta" ON asientomd USING btree (cuenta);


--
-- TOC entry 2773 (class 1259 OID 129365)
-- Dependencies: 232 3322
-- Name: FKI_AsientoMD_UsFonpro_UsuarioID_ID; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_AsientoMD_UsFonpro_UsuarioID_ID" ON asientomd USING btree (usuarioid);


--
-- TOC entry 2768 (class 1259 OID 129366)
-- Dependencies: 230 3322
-- Name: FKI_AsientoM_UsFonpro_UsuarioID_ID; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_AsientoM_UsFonpro_UsuarioID_ID" ON asientom USING btree (usuarioid);


--
-- TOC entry 2757 (class 1259 OID 129367)
-- Dependencies: 229 3322
-- Name: FKI_Asiento_UsFonpro_IDUsCierre_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Asiento_UsFonpro_IDUsCierre_IDUsFonpro" ON asiento USING btree (uscierreid);


--
-- TOC entry 2758 (class 1259 OID 129368)
-- Dependencies: 229 3322
-- Name: FKI_Asiento_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Asiento_UsFonpro_IDUsuario_IDUsFonpro" ON asiento USING btree (usuarioid);


--
-- TOC entry 2565 (class 1259 OID 129369)
-- Dependencies: 174 3322
-- Name: FKI_BaCuenta_Bancos_IDBanco; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_BaCuenta_Bancos_IDBanco" ON bacuenta USING btree (bancoid);


--
-- TOC entry 2566 (class 1259 OID 129370)
-- Dependencies: 174 3322
-- Name: FKI_BaCuenta_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_BaCuenta_UsFonpro_IDUsuario_IDUsFonpro" ON bacuenta USING btree (usuarioid);


--
-- TOC entry 2571 (class 1259 OID 129371)
-- Dependencies: 176 3322
-- Name: FKI_Bancos_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Bancos_UsFonpro_IDUsuario_IDUsFonpro" ON bancos USING btree (usuarioid);


--
-- TOC entry 2574 (class 1259 OID 129372)
-- Dependencies: 178 3322
-- Name: FKI_CalPagoD_CalPago_IDCalPago; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_CalPagoD_CalPago_IDCalPago" ON calpagod USING btree (calpagoid);


--
-- TOC entry 2575 (class 1259 OID 129373)
-- Dependencies: 178 3322
-- Name: FKI_CalPagoD_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_CalPagoD_UsFonpro_IDUsuario_IDUsFonpro" ON calpagod USING btree (usuarioid);


--
-- TOC entry 2582 (class 1259 OID 129374)
-- Dependencies: 180 3322
-- Name: FKI_CalPago_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_CalPago_UsFonpro_IDUsuario_IDUsFonpro" ON calpago USING btree (usuarioid);


--
-- TOC entry 2583 (class 1259 OID 129375)
-- Dependencies: 180 3322
-- Name: FKI_CalPagos_TiPeGrav_IDTiPeGrav; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_CalPagos_TiPeGrav_IDTiPeGrav" ON calpago USING btree (tipegravid);


--
-- TOC entry 2589 (class 1259 OID 129376)
-- Dependencies: 182 3322
-- Name: FKI_Cargos_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Cargos_UsFonpro_IDUsuario_IDUsFonpro" ON cargos USING btree (usuarioid);


--
-- TOC entry 2594 (class 1259 OID 129377)
-- Dependencies: 184 3322
-- Name: FKI_Ciudades_Estados_IDEstado; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Ciudades_Estados_IDEstado" ON ciudades USING btree (estadoid);


--
-- TOC entry 2595 (class 1259 OID 129378)
-- Dependencies: 184 3322
-- Name: FKI_Ciudades_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Ciudades_UsFonpro_IDUsuario_IDUsFonpro" ON ciudades USING btree (usuarioid);


--
-- TOC entry 2600 (class 1259 OID 129379)
-- Dependencies: 186 3322
-- Name: FKI_ConUsuCo_ConUsu_IDConUsu; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_ConUsuCo_ConUsu_IDConUsu" ON conusuco USING btree (conusuid);


--
-- TOC entry 2601 (class 1259 OID 129380)
-- Dependencies: 186 3322
-- Name: FKI_ConUsuCo_Contribu_IDContribu; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_ConUsuCo_Contribu_IDContribu" ON conusuco USING btree (contribuid);


--
-- TOC entry 2604 (class 1259 OID 129381)
-- Dependencies: 188 3322
-- Name: FKI_ConUsuTi_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_ConUsuTi_UsFonpro_IDUsuario_IDUsFonpro" ON conusuti USING btree (usuarioid);


--
-- TOC entry 2609 (class 1259 OID 129382)
-- Dependencies: 190 3322
-- Name: FKI_ConUsuTo_ConUsu_IDConUsu; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_ConUsuTo_ConUsu_IDConUsu" ON conusuto USING btree (conusuid);


--
-- TOC entry 2612 (class 1259 OID 129383)
-- Dependencies: 192 3322
-- Name: FKI_ConUsu_ConUsuTi_IDConUsuTi; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_ConUsu_ConUsuTi_IDConUsuTi" ON conusu USING btree (conusutiid);


--
-- TOC entry 2613 (class 1259 OID 129384)
-- Dependencies: 192 3322
-- Name: FKI_ConUsu_PregSecr_IDPregSecr; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_ConUsu_PregSecr_IDPregSecr" ON conusu USING btree (pregsecrid);


--
-- TOC entry 2614 (class 1259 OID 129385)
-- Dependencies: 192 3322
-- Name: FKI_ConUsu_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_ConUsu_UsFonpro_IDUsuario_IDUsFonpro" ON conusu USING btree (usuarioid);


--
-- TOC entry 2784 (class 1259 OID 129386)
-- Dependencies: 240 3322
-- Name: FKI_ContribuTi_Contribu_ContribuID_ID; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_ContribuTi_Contribu_ContribuID_ID" ON contributi USING btree (contribuid);


--
-- TOC entry 2785 (class 1259 OID 129387)
-- Dependencies: 240 3322
-- Name: FKI_ContribuTi_TipoCont_TipoContID_ID; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_ContribuTi_TipoCont_TipoContID_ID" ON contributi USING btree (tipocontid);


--
-- TOC entry 2626 (class 1259 OID 129388)
-- Dependencies: 194 3322
-- Name: FKI_Contribu_ActiEcon_IDActiEcon; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Contribu_ActiEcon_IDActiEcon" ON contribu USING btree (actieconid);


--
-- TOC entry 2627 (class 1259 OID 129389)
-- Dependencies: 194 3322
-- Name: FKI_Contribu_Ciudades_IDCiudad; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Contribu_Ciudades_IDCiudad" ON contribu USING btree (ciudadid);


--
-- TOC entry 2628 (class 1259 OID 129390)
-- Dependencies: 194 3322
-- Name: FKI_Contribu_ConUsu_UsuarioID_ID; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Contribu_ConUsu_UsuarioID_ID" ON contribu USING btree (usuarioid);


--
-- TOC entry 2629 (class 1259 OID 129391)
-- Dependencies: 194 3322
-- Name: FKI_Contribu_Estados_IDEstado; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Contribu_Estados_IDEstado" ON contribu USING btree (estadoid);


--
-- TOC entry 2798 (class 1259 OID 129392)
-- Dependencies: 250 3322
-- Name: FKI_CtaConta_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_CtaConta_UsFonpro_IDUsuario_IDUsFonpro" ON ctaconta USING btree (usuarioid);


--
-- TOC entry 2805 (class 1259 OID 129393)
-- Dependencies: 251 3322
-- Name: FKI_Decla_Asiento_IDAsiento; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Decla_Asiento_IDAsiento" ON declara USING btree (asientoid);


--
-- TOC entry 2806 (class 1259 OID 129394)
-- Dependencies: 251 3322
-- Name: FKI_Decla_PlaSustID_ID; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Decla_PlaSustID_ID" ON declara USING btree (plasustid);


--
-- TOC entry 2807 (class 1259 OID 129395)
-- Dependencies: 251 3322
-- Name: FKI_Decla_RepLegal_IDRepLegal; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Decla_RepLegal_IDRepLegal" ON declara USING btree (replegalid);


--
-- TOC entry 2808 (class 1259 OID 129396)
-- Dependencies: 251 3322
-- Name: FKI_Decla_TDeclara_IDTDeclara; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Decla_TDeclara_IDTDeclara" ON declara USING btree (tdeclaraid);


--
-- TOC entry 2809 (class 1259 OID 129397)
-- Dependencies: 251 3322
-- Name: FKI_Decla_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Decla_UsFonpro_IDUsuario_IDUsFonpro" ON declara USING btree (usuarioid);


--
-- TOC entry 2637 (class 1259 OID 129398)
-- Dependencies: 196 3322
-- Name: FKI_Declara_Asiento_IDAsiento; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Declara_Asiento_IDAsiento" ON declara_viejo USING btree (asientoid);


--
-- TOC entry 2638 (class 1259 OID 129399)
-- Dependencies: 196 3322
-- Name: FKI_Declara_PlaSustID_ID; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Declara_PlaSustID_ID" ON declara_viejo USING btree (plasustid);


--
-- TOC entry 2639 (class 1259 OID 129400)
-- Dependencies: 196 3322
-- Name: FKI_Declara_RepLegal_IDRepLegal; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Declara_RepLegal_IDRepLegal" ON declara_viejo USING btree (replegalid);


--
-- TOC entry 2640 (class 1259 OID 129401)
-- Dependencies: 196 3322
-- Name: FKI_Declara_TDeclara_IDTDeclara; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Declara_TDeclara_IDTDeclara" ON declara_viejo USING btree (tdeclaraid);


--
-- TOC entry 2641 (class 1259 OID 129402)
-- Dependencies: 196 3322
-- Name: FKI_Declara_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Declara_UsFonpro_IDUsuario_IDUsFonpro" ON declara_viejo USING btree (usuarioid);


--
-- TOC entry 2833 (class 1259 OID 129403)
-- Dependencies: 266 3322
-- Name: FKI_Document_UsFonpro_UsFonproID_ID; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Document_UsFonpro_UsFonproID_ID" ON document USING btree (usfonproid);


--
-- TOC entry 2660 (class 1259 OID 129404)
-- Dependencies: 200 3322
-- Name: FKI_EntidadD_Entidad_IDEntidad; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_EntidadD_Entidad_IDEntidad" ON entidadd USING btree (entidadid);


--
-- TOC entry 2676 (class 1259 OID 129405)
-- Dependencies: 204 3322
-- Name: FKI_Estados_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Estados_UsFonpro_IDUsuario_IDUsFonpro" ON estados USING btree (usuarioid);


--
-- TOC entry 2681 (class 1259 OID 129406)
-- Dependencies: 206 3322
-- Name: FKI_PerUsuD_EndidadD_IDEntidadD; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_PerUsuD_EndidadD_IDEntidadD" ON perusud USING btree (entidaddid);


--
-- TOC entry 2682 (class 1259 OID 129407)
-- Dependencies: 206 3322
-- Name: FKI_PerUsuD_PerUsu_IDPerUsu; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_PerUsuD_PerUsu_IDPerUsu" ON perusud USING btree (perusuid);


--
-- TOC entry 2683 (class 1259 OID 129408)
-- Dependencies: 206 3322
-- Name: FKI_PerUsuD_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_PerUsuD_UsFonpro_IDUsuario_IDUsFonpro" ON perusud USING btree (usuarioid);


--
-- TOC entry 2688 (class 1259 OID 129409)
-- Dependencies: 208 3322
-- Name: FKI_PerUsu_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_PerUsu_UsFonpro_IDUsuario_IDUsFonpro" ON perusu USING btree (usuarioid);


--
-- TOC entry 2693 (class 1259 OID 129410)
-- Dependencies: 210 3322
-- Name: FKI_PregSecr_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_PregSecr_UsFonpro_IDUsuario_IDUsFonpro" ON pregsecr USING btree (usuarioid);


--
-- TOC entry 2698 (class 1259 OID 129411)
-- Dependencies: 212 3322
-- Name: FKI_RepLegal_IDCiudad; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_RepLegal_IDCiudad" ON replegal USING btree (ciudadid);


--
-- TOC entry 2699 (class 1259 OID 129412)
-- Dependencies: 212 3322
-- Name: FKI_RepLegal_IDContribu; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_RepLegal_IDContribu" ON replegal USING btree (contribuid);


--
-- TOC entry 2700 (class 1259 OID 129413)
-- Dependencies: 212 3322
-- Name: FKI_RepLegal_IDEstado; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_RepLegal_IDEstado" ON replegal USING btree (estadoid);


--
-- TOC entry 2701 (class 1259 OID 129414)
-- Dependencies: 212 3322
-- Name: FKI_RepLegal_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_RepLegal_UsFonpro_IDUsuario_IDUsFonpro" ON replegal USING btree (usuarioid);


--
-- TOC entry 2709 (class 1259 OID 129415)
-- Dependencies: 214 3322
-- Name: FKI_TDeclara_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TDeclara_UsFonpro_IDUsuario_IDUsFonpro" ON tdeclara USING btree (usuarioid);


--
-- TOC entry 2714 (class 1259 OID 129416)
-- Dependencies: 216 3322
-- Name: FKI_TiPeGrav_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TiPeGrav_UsFonpro_IDUsuario_IDUsFonpro" ON tipegrav USING btree (usuarioid);


--
-- TOC entry 2719 (class 1259 OID 129417)
-- Dependencies: 218 3322
-- Name: FKI_TipoCont_TiPeGrav_IDTiPeGrav; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TipoCont_TiPeGrav_IDTiPeGrav" ON tipocont USING btree (tipegravid);


--
-- TOC entry 2720 (class 1259 OID 129418)
-- Dependencies: 218 3322
-- Name: FKI_TipoCont_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TipoCont_UsFonpro_IDUsuario_IDUsFonpro" ON tipocont USING btree (usuarioid);


--
-- TOC entry 2858 (class 1259 OID 129419)
-- Dependencies: 275 3322
-- Name: FKI_TmpContri_ActiEcon_IDActiEcon; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TmpContri_ActiEcon_IDActiEcon" ON tmpcontri USING btree (actieconid);


--
-- TOC entry 2859 (class 1259 OID 129420)
-- Dependencies: 275 3322
-- Name: FKI_TmpContri_Ciudades_IDCiudad; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TmpContri_Ciudades_IDCiudad" ON tmpcontri USING btree (ciudadid);


--
-- TOC entry 2860 (class 1259 OID 129421)
-- Dependencies: 275 3322
-- Name: FKI_TmpContri_Contribu_IDContribu; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TmpContri_Contribu_IDContribu" ON tmpcontri USING btree (id);


--
-- TOC entry 2861 (class 1259 OID 129422)
-- Dependencies: 275 3322
-- Name: FKI_TmpContri_Estados_IDEstado; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TmpContri_Estados_IDEstado" ON tmpcontri USING btree (estadoid);


--
-- TOC entry 2862 (class 1259 OID 129423)
-- Dependencies: 275 3322
-- Name: FKI_TmpContri_TipoCont_IDTipoCont; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TmpContri_TipoCont_IDTipoCont" ON tmpcontri USING btree (tipocontid);


--
-- TOC entry 2868 (class 1259 OID 129424)
-- Dependencies: 276 3322
-- Name: FKI_TmpReLegal_IDCiudad; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TmpReLegal_IDCiudad" ON tmprelegal USING btree (ciudadid);


--
-- TOC entry 2869 (class 1259 OID 129425)
-- Dependencies: 276 3322
-- Name: FKI_TmpReLegal_IDContribu; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TmpReLegal_IDContribu" ON tmprelegal USING btree (contribuid);


--
-- TOC entry 2870 (class 1259 OID 129426)
-- Dependencies: 276 3322
-- Name: FKI_TmpReLegal_IDEstado; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TmpReLegal_IDEstado" ON tmprelegal USING btree (estadoid);


--
-- TOC entry 2725 (class 1259 OID 129427)
-- Dependencies: 220 3322
-- Name: FKI_UndTrib_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_UndTrib_UsFonpro_IDUsuario_IDUsFonpro" ON undtrib USING btree (usuarioid);


--
-- TOC entry 2737 (class 1259 OID 129428)
-- Dependencies: 224 3322
-- Name: FKI_UsFonPro_PregSecr_IDPregSecr; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_UsFonPro_PregSecr_IDPregSecr" ON usfonpro USING btree (pregsecrid);


--
-- TOC entry 2730 (class 1259 OID 129429)
-- Dependencies: 222 3322
-- Name: FKI_UsFonpTo_UsFonpro_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_UsFonpTo_UsFonpro_IDUsFonpro" ON usfonpto USING btree (usfonproid);


--
-- TOC entry 2738 (class 1259 OID 129430)
-- Dependencies: 224 3322
-- Name: FKI_UsFonpro_Cargos_IDCargo; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_UsFonpro_Cargos_IDCargo" ON usfonpro USING btree (cargoid);


--
-- TOC entry 2739 (class 1259 OID 129431)
-- Dependencies: 224 3322
-- Name: FKI_UsFonpro_Departam_IDDepartam; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_UsFonpro_Departam_IDDepartam" ON usfonpro USING btree (departamid);


--
-- TOC entry 2740 (class 1259 OID 129432)
-- Dependencies: 224 3322
-- Name: FKI_UsFonpro_PerUsu_IDPerUsu; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_UsFonpro_PerUsu_IDPerUsu" ON usfonpro USING btree (perusuid);


--
-- TOC entry 2838 (class 1259 OID 129433)
-- Dependencies: 273 3322
-- Name: FKI_reparos_Asiento_IDAsiento; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_reparos_Asiento_IDAsiento" ON reparos USING btree (asientoid);


--
-- TOC entry 2839 (class 1259 OID 129434)
-- Dependencies: 273 3322
-- Name: FKI_reparos_TDeclara_IDTDeclara; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_reparos_TDeclara_IDTDeclara" ON reparos USING btree (tdeclaraid);


--
-- TOC entry 2840 (class 1259 OID 129435)
-- Dependencies: 273 3322
-- Name: FKI_reparos_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_reparos_UsFonpro_IDUsuario_IDUsFonpro" ON reparos USING btree (usuarioid);


--
-- TOC entry 2846 (class 1259 OID 129436)
-- Dependencies: 274 3322
-- Name: FKI_tmpAccioni_IDContribu; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_tmpAccioni_IDContribu" ON tmpaccioni USING btree (contribuid);


--
-- TOC entry 2748 (class 1259 OID 129437)
-- Dependencies: 226 3322
-- Name: IX_Accionis_Apellido; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Accionis_Apellido" ON accionis USING btree (apellido);


--
-- TOC entry 2749 (class 1259 OID 129438)
-- Dependencies: 226 3322
-- Name: IX_Accionis_Ci; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Accionis_Ci" ON accionis USING btree (ci);


--
-- TOC entry 2750 (class 1259 OID 129439)
-- Dependencies: 226 3322
-- Name: IX_Accionis_Nombre; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Accionis_Nombre" ON accionis USING btree (nombre);


--
-- TOC entry 2552 (class 1259 OID 129440)
-- Dependencies: 169 3322
-- Name: IX_AlicImp_Ano; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_AlicImp_Ano" ON alicimp USING btree (ano);


--
-- TOC entry 2560 (class 1259 OID 129441)
-- Dependencies: 171 3322
-- Name: IX_AsientoD_Fecha; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_AsientoD_Fecha" ON asientod USING btree (fecha);


--
-- TOC entry 2759 (class 1259 OID 129442)
-- Dependencies: 229 3322
-- Name: IX_Asiento_Ano; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Asiento_Ano" ON asiento USING btree (ano);


--
-- TOC entry 2760 (class 1259 OID 129443)
-- Dependencies: 229 3322
-- Name: IX_Asiento_Cerrado; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Asiento_Cerrado" ON asiento USING btree (cerrado);


--
-- TOC entry 2761 (class 1259 OID 129444)
-- Dependencies: 229 3322
-- Name: IX_Asiento_Fecha; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Asiento_Fecha" ON asiento USING btree (fecha);


--
-- TOC entry 2762 (class 1259 OID 129445)
-- Dependencies: 229 3322
-- Name: IX_Asiento_Mes; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Asiento_Mes" ON asiento USING btree (mes);


--
-- TOC entry 2763 (class 1259 OID 129446)
-- Dependencies: 229 3322
-- Name: IX_Asiento_NuAsiento; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Asiento_NuAsiento" ON asiento USING btree (nuasiento);


--
-- TOC entry 2584 (class 1259 OID 129447)
-- Dependencies: 180 3322
-- Name: IX_CalPagos_Ano; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_CalPagos_Ano" ON calpago USING btree (ano);


--
-- TOC entry 2615 (class 1259 OID 129448)
-- Dependencies: 192 3322
-- Name: IX_ConUsu_Password; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_ConUsu_Password" ON conusu USING btree (password);


--
-- TOC entry 2630 (class 1259 OID 129449)
-- Dependencies: 194 3322
-- Name: IX_Contribu_DenComerci; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Contribu_DenComerci" ON contribu USING btree (dencomerci);


--
-- TOC entry 2810 (class 1259 OID 129450)
-- Dependencies: 251 3322
-- Name: IX_Decla_FechaConci; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Decla_FechaConci" ON declara USING btree (fechaconci);


--
-- TOC entry 2811 (class 1259 OID 129451)
-- Dependencies: 251 3322
-- Name: IX_Decla_FechaElab; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Decla_FechaElab" ON declara USING btree (fechaelab);


--
-- TOC entry 2812 (class 1259 OID 129452)
-- Dependencies: 251 3322
-- Name: IX_Decla_FechaFin; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Decla_FechaFin" ON declara USING btree (fechafin);


--
-- TOC entry 2813 (class 1259 OID 129453)
-- Dependencies: 251 3322
-- Name: IX_Decla_FechaIni; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Decla_FechaIni" ON declara USING btree (fechaini);


--
-- TOC entry 2814 (class 1259 OID 129454)
-- Dependencies: 251 3322
-- Name: IX_Decla_FechaPago; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Decla_FechaPago" ON declara USING btree (fechapago);


--
-- TOC entry 2642 (class 1259 OID 129455)
-- Dependencies: 196 3322
-- Name: IX_Declara_FechaConci; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Declara_FechaConci" ON declara_viejo USING btree (fechaconci);


--
-- TOC entry 2643 (class 1259 OID 129456)
-- Dependencies: 196 3322
-- Name: IX_Declara_FechaElab; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Declara_FechaElab" ON declara_viejo USING btree (fechaelab);


--
-- TOC entry 2644 (class 1259 OID 129457)
-- Dependencies: 196 3322
-- Name: IX_Declara_FechaFin; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Declara_FechaFin" ON declara_viejo USING btree (fechafin);


--
-- TOC entry 2645 (class 1259 OID 129458)
-- Dependencies: 196 3322
-- Name: IX_Declara_FechaIni; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Declara_FechaIni" ON declara_viejo USING btree (fechaini);


--
-- TOC entry 2646 (class 1259 OID 129459)
-- Dependencies: 196 3322
-- Name: IX_Declara_FechaPago; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Declara_FechaPago" ON declara_viejo USING btree (fechapago);


--
-- TOC entry 2661 (class 1259 OID 129460)
-- Dependencies: 200 3322
-- Name: IX_EntidadD_Accion; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_EntidadD_Accion" ON entidadd USING btree (accion);


--
-- TOC entry 2662 (class 1259 OID 129461)
-- Dependencies: 200 3322
-- Name: IX_EntidadD_Nombre; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_EntidadD_Nombre" ON entidadd USING btree (nombre);


--
-- TOC entry 2663 (class 1259 OID 129462)
-- Dependencies: 200 3322
-- Name: IX_EntidadD_Orden; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_EntidadD_Orden" ON entidadd USING btree (orden);


--
-- TOC entry 2702 (class 1259 OID 129463)
-- Dependencies: 212 3322
-- Name: IX_RepLegal_Apellido; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_RepLegal_Apellido" ON replegal USING btree (apellido);


--
-- TOC entry 2703 (class 1259 OID 129464)
-- Dependencies: 212 3322
-- Name: IX_RepLegal_Ci; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_RepLegal_Ci" ON replegal USING btree (ci);


--
-- TOC entry 2704 (class 1259 OID 129465)
-- Dependencies: 212 3322
-- Name: IX_RepLegal_Nombre; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_RepLegal_Nombre" ON replegal USING btree (nombre);


--
-- TOC entry 2863 (class 1259 OID 129466)
-- Dependencies: 275 3322
-- Name: IX_TmpContri_DenComerci; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_TmpContri_DenComerci" ON tmpcontri USING btree (dencomerci);


--
-- TOC entry 2871 (class 1259 OID 129467)
-- Dependencies: 276 3322
-- Name: IX_TmpReLegalNombre; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_TmpReLegalNombre" ON tmprelegal USING btree (nombre);


--
-- TOC entry 2872 (class 1259 OID 129468)
-- Dependencies: 276 3322
-- Name: IX_TmpReLegal_Apellido; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_TmpReLegal_Apellido" ON tmprelegal USING btree (apellido);


--
-- TOC entry 2873 (class 1259 OID 129469)
-- Dependencies: 276 3322
-- Name: IX_TmpReLegal_Ci; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_TmpReLegal_Ci" ON tmprelegal USING btree (ci);


--
-- TOC entry 2741 (class 1259 OID 129470)
-- Dependencies: 224 3322
-- Name: IX_UsFonPro_Password; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_UsFonPro_Password" ON usfonpro USING btree (password);


--
-- TOC entry 2841 (class 1259 OID 129471)
-- Dependencies: 273 3322
-- Name: IX_reparos_FechaElab; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_reparos_FechaElab" ON reparos USING btree (fechaelab);


--
-- TOC entry 2847 (class 1259 OID 129472)
-- Dependencies: 274 3322
-- Name: IX_tmpAccioni_Apellido; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_tmpAccioni_Apellido" ON tmpaccioni USING btree (apellido);


--
-- TOC entry 2848 (class 1259 OID 129473)
-- Dependencies: 274 3322
-- Name: IX_tmpAccioni_Ci; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_tmpAccioni_Ci" ON tmpaccioni USING btree (ci);


--
-- TOC entry 2849 (class 1259 OID 129474)
-- Dependencies: 274 3322
-- Name: IX_tmpAccioni_Nombre; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_tmpAccioni_Nombre" ON tmpaccioni USING btree (nombre);


--
-- TOC entry 2653 (class 1259 OID 129475)
-- Dependencies: 198 3322
-- Name: fki_FL_Departam_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "fki_FL_Departam_UsFonpro_IDUsuario_IDUsFonpro" ON departam USING btree (usuarioid);


SET search_path = historial, pg_catalog;

--
-- TOC entry 2876 (class 1259 OID 129476)
-- Dependencies: 278 3322
-- Name: IX_Accion; Type: INDEX; Schema: historial; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Accion" ON bitacora USING btree (accion);


--
-- TOC entry 2877 (class 1259 OID 129477)
-- Dependencies: 278 3322
-- Name: IX_Fecha; Type: INDEX; Schema: historial; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Fecha" ON bitacora USING btree (fecha);


--
-- TOC entry 2878 (class 1259 OID 129478)
-- Dependencies: 278 3322
-- Name: IX_IDUsuario; Type: INDEX; Schema: historial; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_IDUsuario" ON bitacora USING btree (idusuario);


--
-- TOC entry 2879 (class 1259 OID 129479)
-- Dependencies: 278 3322
-- Name: IX_Tabla; Type: INDEX; Schema: historial; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Tabla" ON bitacora USING btree (tabla);


--
-- TOC entry 2880 (class 1259 OID 129480)
-- Dependencies: 278 3322
-- Name: IX_ValDelID; Type: INDEX; Schema: historial; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_ValDelID" ON bitacora USING btree (valdelid);


SET search_path = datos, pg_catalog;

--
-- TOC entry 3172 (class 2618 OID 129481)
-- Dependencies: 288 2743 298 298 298 296 296 296 292 292 292 292 288 288 288 288 224 224 224 224 277 3322
-- Name: _RETURN; Type: RULE; Schema: datos; Owner: postgres
--

CREATE RULE "_RETURN" AS ON SELECT TO view_modulo_usuario_contribuyente_permiso DO INSTEAD SELECT usu.id, usu.nombre, rol.str_rol, per.id_modulo, mod.str_nombre, mod.str_enlace, max(per.int_permiso) AS int_permiso, CASE WHEN (mod.id_padre IS NULL) THEN (mod.id_modulo * 10) ELSE ((mod.id_padre * 10) + mod.id_modulo) END AS int_orden, CASE WHEN (mod.id_padre IS NULL) THEN (0)::bigint ELSE mod.id_padre END AS id_padre FROM ((((usfonpro usu JOIN seg.tbl_rol_usuario rus ON ((usu.id = rus.id_usuario))) JOIN seg.tbl_rol rol ON ((rus.id_rol = rol.id_rol))) JOIN seg.tbl_permiso per ON ((rol.id_rol = per.id_rol))) JOIN seg.tbl_modulo mod ON ((per.id_modulo = mod.id_modulo))) WHERE (((((NOT usu.inactivo) AND (NOT rus.bln_borrado)) AND (NOT rol.bln_borrado)) AND (NOT per.bln_borrado)) AND (NOT mod.bln_borrado)) GROUP BY usu.id, usu.login, rol.str_rol, per.id_modulo, mod.str_nombre, mod.str_enlace, mod.id_padre, mod.id_modulo;


SET search_path = seg, pg_catalog;

--
-- TOC entry 3173 (class 2618 OID 129483)
-- Dependencies: 288 288 288 288 288 224 224 224 224 292 2743 298 298 298 296 296 296 292 292 292 303 3322
-- Name: _RETURN; Type: RULE; Schema: seg; Owner: postgres
--

CREATE RULE "_RETURN" AS ON SELECT TO view_modulo_usuario_permiso DO INSTEAD SELECT usu.id, usu.nombre, rol.str_rol, per.id_modulo, mod.str_nombre, mod.str_enlace, max(per.int_permiso) AS int_permiso, CASE WHEN (mod.id_padre IS NULL) THEN (mod.id_modulo * 10) ELSE ((mod.id_padre * 10) + mod.id_modulo) END AS int_orden, CASE WHEN (mod.id_padre IS NULL) THEN (0)::bigint ELSE mod.id_padre END AS id_padre FROM ((((datos.usfonpro usu JOIN tbl_rol_usuario rus ON ((usu.id = rus.id_usuario))) JOIN tbl_rol rol ON ((rus.id_rol = rol.id_rol))) JOIN tbl_permiso per ON ((rol.id_rol = per.id_rol))) JOIN tbl_modulo mod ON ((per.id_modulo = mod.id_modulo))) WHERE (((((NOT usu.inactivo) AND (NOT rus.bln_borrado)) AND (NOT rol.bln_borrado)) AND (NOT per.bln_borrado)) AND (NOT mod.bln_borrado)) GROUP BY usu.id, usu.login, rol.str_rol, per.id_modulo, mod.str_nombre, mod.str_enlace, mod.id_padre, mod.id_modulo;


SET search_path = "segContribu", pg_catalog;

--
-- TOC entry 3174 (class 2618 OID 129485)
-- Dependencies: 307 305 305 305 305 305 192 192 192 2617 311 311 311 309 309 309 307 307 307 315 3322
-- Name: _RETURN; Type: RULE; Schema: segContribu; Owner: postgres
--

CREATE RULE "_RETURN" AS ON SELECT TO view_modulo_usuariocontribuyente_permiso DO INSTEAD SELECT usu.id, usu.nombre, rol.str_rol, per.id_modulo, mod.str_nombre, mod.str_enlace, max(per.int_permiso) AS int_permiso, CASE WHEN (mod.id_padre IS NULL) THEN (mod.id_modulo * 10) ELSE ((mod.id_padre * 10) + mod.id_modulo) END AS int_orden, CASE WHEN (mod.id_padre IS NULL) THEN (0)::bigint ELSE mod.id_padre END AS id_padre FROM ((((datos.conusu usu JOIN tbl_rol_usuario_contribu rus ON ((usu.id = rus.id_usuario))) JOIN tbl_rol_contribu rol ON ((rus.id_rol = rol.id_rol))) JOIN tbl_permiso_contribu per ON ((rol.id_rol = per.id_rol))) JOIN tbl_modulo_contribu mod ON ((per.id_modulo = mod.id_modulo))) WHERE ((((NOT rus.bln_borrado) AND (NOT rol.bln_borrado)) AND (NOT per.bln_borrado)) AND (NOT mod.bln_borrado)) GROUP BY usu.id, usu.login, rol.str_rol, per.id_modulo, mod.str_nombre, mod.str_enlace, mod.id_padre, mod.id_modulo;


SET search_path = datos, pg_catalog;

--
-- TOC entry 3061 (class 2620 OID 129487)
-- Dependencies: 229 339 229 229 3322
-- Name: TG_Asiendo_ActualizaSaldo; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_Asiendo_ActualizaSaldo" BEFORE UPDATE OF debe, haber ON asiento FOR EACH ROW EXECUTE PROCEDURE "tf_Asiento_ActualizaSaldo"();


--
-- TOC entry 3993 (class 0 OID 0)
-- Dependencies: 3061
-- Name: TRIGGER "TG_Asiendo_ActualizaSaldo" ON asiento; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_Asiendo_ActualizaSaldo" ON asiento IS 'Trigger que actualiza el saldo del asiento';


--
-- TOC entry 3037 (class 2620 OID 129488)
-- Dependencies: 338 171 3322
-- Name: TG_AsientoD_ActualizaDebeHaber_Asiento; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_AsientoD_ActualizaDebeHaber_Asiento" AFTER INSERT OR DELETE OR UPDATE ON asientod FOR EACH ROW EXECUTE PROCEDURE "tf_AsiendoD_ActualizaDebeHaber_Asiento"();


--
-- TOC entry 3994 (class 0 OID 0)
-- Dependencies: 3037
-- Name: TRIGGER "TG_AsientoD_ActualizaDebeHaber_Asiento" ON asientod; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_AsientoD_ActualizaDebeHaber_Asiento" ON asientod IS 'Trigger que actualiza el debe y haber de la tabla de asiento';


--
-- TOC entry 3038 (class 2620 OID 129489)
-- Dependencies: 171 340 3322
-- Name: TG_AsientoD_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_AsientoD_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON asientod FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();


--
-- TOC entry 3995 (class 0 OID 0)
-- Dependencies: 3038
-- Name: TRIGGER "TG_AsientoD_Bitacora" ON asientod; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_AsientoD_Bitacora" ON asientod IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3064 (class 2620 OID 129490)
-- Dependencies: 230 340 3322
-- Name: TG_AsientoM_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_AsientoM_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON asientom FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();


--
-- TOC entry 3996 (class 0 OID 0)
-- Dependencies: 3064
-- Name: TRIGGER "TG_AsientoM_Bitacora" ON asientom; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_AsientoM_Bitacora" ON asientom IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3062 (class 2620 OID 129491)
-- Dependencies: 229 229 330 3322
-- Name: TG_Asiento_Actualiza_Mes_Ano; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_Asiento_Actualiza_Mes_Ano" BEFORE INSERT OR UPDATE OF fecha ON asiento FOR EACH ROW EXECUTE PROCEDURE "tf_Asiento_ActualizaPeriodo"();


--
-- TOC entry 3063 (class 2620 OID 129492)
-- Dependencies: 340 229 3322
-- Name: TG_Asiento_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_Asiento_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON asiento FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();


--
-- TOC entry 3997 (class 0 OID 0)
-- Dependencies: 3063
-- Name: TRIGGER "TG_Asiento_Bitacora" ON asiento; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_Asiento_Bitacora" ON asiento IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3039 (class 2620 OID 129493)
-- Dependencies: 340 174 3322
-- Name: TG_BaCuenta_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_BaCuenta_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON bacuenta FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();


--
-- TOC entry 3998 (class 0 OID 0)
-- Dependencies: 3039
-- Name: TRIGGER "TG_BaCuenta_Bitacora" ON bacuenta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_BaCuenta_Bitacora" ON bacuenta IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3040 (class 2620 OID 129494)
-- Dependencies: 340 176 3322
-- Name: TG_Bancos_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_Bancos_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON bancos FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();


--
-- TOC entry 3999 (class 0 OID 0)
-- Dependencies: 3040
-- Name: TRIGGER "TG_Bancos_Bitacora" ON bancos; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_Bancos_Bitacora" ON bancos IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3043 (class 2620 OID 129495)
-- Dependencies: 340 182 3322
-- Name: TG_Cargos_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_Cargos_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON cargos FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE cargos DISABLE TRIGGER "TG_Cargos_Bitacora";


--
-- TOC entry 4000 (class 0 OID 0)
-- Dependencies: 3043
-- Name: TRIGGER "TG_Cargos_Bitacora" ON cargos; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_Cargos_Bitacora" ON cargos IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3046 (class 2620 OID 129496)
-- Dependencies: 192 340 3322
-- Name: TG_ConUsu_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_ConUsu_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON conusu FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE conusu DISABLE TRIGGER "TG_ConUsu_Bitacora";


--
-- TOC entry 4001 (class 0 OID 0)
-- Dependencies: 3046
-- Name: TRIGGER "TG_ConUsu_Bitacora" ON conusu; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_ConUsu_Bitacora" ON conusu IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3066 (class 2620 OID 129497)
-- Dependencies: 340 250 3322
-- Name: TG_CtaConta_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_CtaConta_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON ctaconta FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();


--
-- TOC entry 4002 (class 0 OID 0)
-- Dependencies: 3066
-- Name: TRIGGER "TG_CtaConta_Bitacora" ON ctaconta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_CtaConta_Bitacora" ON ctaconta IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3048 (class 2620 OID 129498)
-- Dependencies: 340 198 3322
-- Name: TG_Departam_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_Departam_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON departam FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE departam DISABLE TRIGGER "TG_Departam_Bitacora";


--
-- TOC entry 4003 (class 0 OID 0)
-- Dependencies: 3048
-- Name: TRIGGER "TG_Departam_Bitacora" ON departam; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_Departam_Bitacora" ON departam IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3050 (class 2620 OID 129499)
-- Dependencies: 206 340 3322
-- Name: TG_PerUsuD_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_PerUsuD_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON perusud FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();


--
-- TOC entry 4004 (class 0 OID 0)
-- Dependencies: 3050
-- Name: TRIGGER "TG_PerUsuD_Bitacora" ON perusud; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_PerUsuD_Bitacora" ON perusud IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3051 (class 2620 OID 129500)
-- Dependencies: 340 208 3322
-- Name: TG_PerUsu_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_PerUsu_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON perusu FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();


--
-- TOC entry 4005 (class 0 OID 0)
-- Dependencies: 3051
-- Name: TRIGGER "TG_PerUsu_Bitacora" ON perusu; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_PerUsu_Bitacora" ON perusu IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3052 (class 2620 OID 129501)
-- Dependencies: 340 210 3322
-- Name: TG_PregSecr_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_PregSecr_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON pregsecr FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE pregsecr DISABLE TRIGGER "TG_PregSecr_Bitacora";


--
-- TOC entry 4006 (class 0 OID 0)
-- Dependencies: 3052
-- Name: TRIGGER "TG_PregSecr_Bitacora" ON pregsecr; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_PregSecr_Bitacora" ON pregsecr IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3054 (class 2620 OID 129502)
-- Dependencies: 340 214 3322
-- Name: TG_TDeclara_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_TDeclara_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON tdeclara FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE tdeclara DISABLE TRIGGER "TG_TDeclara_Bitacora";


--
-- TOC entry 4007 (class 0 OID 0)
-- Dependencies: 3054
-- Name: TRIGGER "TG_TDeclara_Bitacora" ON tdeclara; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_TDeclara_Bitacora" ON tdeclara IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3057 (class 2620 OID 129503)
-- Dependencies: 340 220 3322
-- Name: TG_UndTrib_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_UndTrib_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON undtrib FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE undtrib DISABLE TRIGGER "TG_UndTrib_Bitacora";


--
-- TOC entry 4008 (class 0 OID 0)
-- Dependencies: 3057
-- Name: TRIGGER "TG_UndTrib_Bitacora" ON undtrib; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_UndTrib_Bitacora" ON undtrib IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3058 (class 2620 OID 129504)
-- Dependencies: 224 340 224 224 224 224 224 224 224 224 224 224 224 224 3322
-- Name: TG_UsFonpro_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_UsFonpro_Bitacora" AFTER INSERT OR DELETE OR UPDATE OF id, login, password, nombre, email, telefofc, extension, departamid, cargoid, inactivo, pregsecrid, respuesta ON usfonpro FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE usfonpro DISABLE TRIGGER "TG_UsFonpro_Bitacora";


--
-- TOC entry 4009 (class 0 OID 0)
-- Dependencies: 3058
-- Name: TRIGGER "TG_UsFonpro_Bitacora" ON usfonpro; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_UsFonpro_Bitacora" ON usfonpro IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3060 (class 2620 OID 129505)
-- Dependencies: 331 227 3322
-- Name: ejecuta_crea_correlativo_actar; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER ejecuta_crea_correlativo_actar AFTER INSERT ON actas_reparo FOR EACH ROW EXECUTE PROCEDURE crea_correlativo_actas();


--
-- TOC entry 3065 (class 2620 OID 129506)
-- Dependencies: 331 234 3322
-- Name: ejecuta_crea_correlativo_actas; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER ejecuta_crea_correlativo_actas AFTER INSERT ON asignacion_fiscales FOR EACH ROW EXECUTE PROCEDURE crea_correlativo_actas();


--
-- TOC entry 3059 (class 2620 OID 129507)
-- Dependencies: 340 226 3322
-- Name: tg_Accionis_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_Accionis_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON accionis FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE accionis DISABLE TRIGGER "tg_Accionis_Bitacora";


--
-- TOC entry 4010 (class 0 OID 0)
-- Dependencies: 3059
-- Name: TRIGGER "tg_Accionis_Bitacora" ON accionis; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_Accionis_Bitacora" ON accionis IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3035 (class 2620 OID 129508)
-- Dependencies: 340 167 3322
-- Name: tg_ActiEcon_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_ActiEcon_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON actiecon FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE actiecon DISABLE TRIGGER "tg_ActiEcon_Bitacora";


--
-- TOC entry 4011 (class 0 OID 0)
-- Dependencies: 3035
-- Name: TRIGGER "tg_ActiEcon_Bitacora" ON actiecon; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_ActiEcon_Bitacora" ON actiecon IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3036 (class 2620 OID 129509)
-- Dependencies: 340 169 3322
-- Name: tg_AlicImp_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_AlicImp_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON alicimp FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE alicimp DISABLE TRIGGER "tg_AlicImp_Bitacora";


--
-- TOC entry 4012 (class 0 OID 0)
-- Dependencies: 3036
-- Name: TRIGGER "tg_AlicImp_Bitacora" ON alicimp; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_AlicImp_Bitacora" ON alicimp IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3041 (class 2620 OID 129510)
-- Dependencies: 340 178 3322
-- Name: tg_CalPagoD_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_CalPagoD_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON calpagod FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE calpagod DISABLE TRIGGER "tg_CalPagoD_Bitacora";


--
-- TOC entry 4013 (class 0 OID 0)
-- Dependencies: 3041
-- Name: TRIGGER "tg_CalPagoD_Bitacora" ON calpagod; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_CalPagoD_Bitacora" ON calpagod IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3042 (class 2620 OID 129511)
-- Dependencies: 180 340 3322
-- Name: tg_CalPago_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_CalPago_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON calpago FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE calpago DISABLE TRIGGER "tg_CalPago_Bitacora";


--
-- TOC entry 4014 (class 0 OID 0)
-- Dependencies: 3042
-- Name: TRIGGER "tg_CalPago_Bitacora" ON calpago; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_CalPago_Bitacora" ON calpago IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3044 (class 2620 OID 129512)
-- Dependencies: 340 184 3322
-- Name: tg_Ciudades_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_Ciudades_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON ciudades FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE ciudades DISABLE TRIGGER "tg_Ciudades_Bitacora";


--
-- TOC entry 4015 (class 0 OID 0)
-- Dependencies: 3044
-- Name: TRIGGER "tg_Ciudades_Bitacora" ON ciudades; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_Ciudades_Bitacora" ON ciudades IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3045 (class 2620 OID 129513)
-- Dependencies: 340 188 3322
-- Name: tg_ConUsuTi_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_ConUsuTi_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON conusuti FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE conusuti DISABLE TRIGGER "tg_ConUsuTi_Bitacora";


--
-- TOC entry 4016 (class 0 OID 0)
-- Dependencies: 3045
-- Name: TRIGGER "tg_ConUsuTi_Bitacora" ON conusuti; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_ConUsuTi_Bitacora" ON conusuti IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3047 (class 2620 OID 129514)
-- Dependencies: 340 194 3322
-- Name: tg_Contribu_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_Contribu_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON contribu FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE contribu DISABLE TRIGGER "tg_Contribu_Bitacora";


--
-- TOC entry 4017 (class 0 OID 0)
-- Dependencies: 3047
-- Name: TRIGGER "tg_Contribu_Bitacora" ON contribu; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_Contribu_Bitacora" ON contribu IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3049 (class 2620 OID 129515)
-- Dependencies: 340 204 3322
-- Name: tg_Estados_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_Estados_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON estados FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE estados DISABLE TRIGGER "tg_Estados_Bitacora";


--
-- TOC entry 4018 (class 0 OID 0)
-- Dependencies: 3049
-- Name: TRIGGER "tg_Estados_Bitacora" ON estados; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_Estados_Bitacora" ON estados IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3053 (class 2620 OID 129516)
-- Dependencies: 340 212 3322
-- Name: tg_RepLegal_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_RepLegal_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON replegal FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE replegal DISABLE TRIGGER "tg_RepLegal_Bitacora";


--
-- TOC entry 4019 (class 0 OID 0)
-- Dependencies: 3053
-- Name: TRIGGER "tg_RepLegal_Bitacora" ON replegal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_RepLegal_Bitacora" ON replegal IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3055 (class 2620 OID 129517)
-- Dependencies: 340 216 3322
-- Name: tg_TiPeGrav_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_TiPeGrav_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON tipegrav FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE tipegrav DISABLE TRIGGER "tg_TiPeGrav_Bitacora";


--
-- TOC entry 4020 (class 0 OID 0)
-- Dependencies: 3055
-- Name: TRIGGER "tg_TiPeGrav_Bitacora" ON tipegrav; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_TiPeGrav_Bitacora" ON tipegrav IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3056 (class 2620 OID 129518)
-- Dependencies: 340 218 3322
-- Name: tg_TipoCont_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_TipoCont_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON tipocont FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE tipocont DISABLE TRIGGER "tg_TipoCont_Bitacora";


--
-- TOC entry 4021 (class 0 OID 0)
-- Dependencies: 3056
-- Name: TRIGGER "tg_TipoCont_Bitacora" ON tipocont; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_TipoCont_Bitacora" ON tipocont IS 'Trigger para insertar datos en la tabla de bitacoras';


SET search_path = seg, pg_catalog;

--
-- TOC entry 3067 (class 2620 OID 129519)
-- Dependencies: 341 294 3322
-- Name: ejecutaverificamodulo; Type: TRIGGER; Schema: seg; Owner: postgres
--

CREATE TRIGGER ejecutaverificamodulo BEFORE INSERT ON tbl_permiso_trampa FOR EACH ROW EXECUTE PROCEDURE verificaperfil();


SET search_path = datos, pg_catalog;

--
-- TOC entry 2974 (class 2606 OID 129520)
-- Dependencies: 192 2616 226 3322
-- Name: FK_Accionis_IDContribu; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY accionis
    ADD CONSTRAINT "FK_Accionis_IDContribu" FOREIGN KEY (contribuid) REFERENCES conusu(id) MATCH FULL;


--
-- TOC entry 2975 (class 2606 OID 129525)
-- Dependencies: 224 2742 226 3322
-- Name: FK_Accionis_UsFonpro_UsuarioID_ID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY accionis
    ADD CONSTRAINT "FK_Accionis_UsFonpro_UsuarioID_ID" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2919 (class 2606 OID 129530)
-- Dependencies: 167 224 2742 3322
-- Name: FK_ActiEcon_USFonpro_IDUsuario_IDUsFornpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY actiecon
    ADD CONSTRAINT "FK_ActiEcon_USFonpro_IDUsuario_IDUsFornpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2920 (class 2606 OID 129535)
-- Dependencies: 2721 169 218 3322
-- Name: FK_AlicImp_TipoCont_IDTipoCont; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY alicimp
    ADD CONSTRAINT "FK_AlicImp_TipoCont_IDTipoCont" FOREIGN KEY (tipocontid) REFERENCES tipocont(id) MATCH FULL;


--
-- TOC entry 2921 (class 2606 OID 129540)
-- Dependencies: 224 2742 169 3322
-- Name: FK_AlicImp_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY alicimp
    ADD CONSTRAINT "FK_AlicImp_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2922 (class 2606 OID 129545)
-- Dependencies: 171 229 2764 3322
-- Name: FK_AsientoD_Asiento_IDAsiento; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asientod
    ADD CONSTRAINT "FK_AsientoD_Asiento_IDAsiento" FOREIGN KEY (asientoid) REFERENCES asiento(id) MATCH FULL;


--
-- TOC entry 2923 (class 2606 OID 129550)
-- Dependencies: 250 2799 171 3322
-- Name: FK_AsientoD_CtaConta_Cuenta; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asientod
    ADD CONSTRAINT "FK_AsientoD_CtaConta_Cuenta" FOREIGN KEY (cuenta) REFERENCES ctaconta(cuenta) MATCH FULL;


--
-- TOC entry 2924 (class 2606 OID 129555)
-- Dependencies: 224 2742 171 3322
-- Name: FK_AsientoD_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asientod
    ADD CONSTRAINT "FK_AsientoD_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2980 (class 2606 OID 129560)
-- Dependencies: 230 232 2769 3322
-- Name: FK_AsientoMD_AsientoM_AsientoMID_ID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asientomd
    ADD CONSTRAINT "FK_AsientoMD_AsientoM_AsientoMID_ID" FOREIGN KEY (asientomid) REFERENCES asientom(id) MATCH FULL;


--
-- TOC entry 2981 (class 2606 OID 129565)
-- Dependencies: 2799 250 232 3322
-- Name: FK_AsientoMD_CtaConta_Cuenta; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asientomd
    ADD CONSTRAINT "FK_AsientoMD_CtaConta_Cuenta" FOREIGN KEY (cuenta) REFERENCES ctaconta(cuenta) MATCH FULL;


--
-- TOC entry 2982 (class 2606 OID 129570)
-- Dependencies: 232 2742 224 3322
-- Name: FK_AsientoMD_UsFonpro_UsuarioID_ID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asientomd
    ADD CONSTRAINT "FK_AsientoMD_UsFonpro_UsuarioID_ID" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2979 (class 2606 OID 129575)
-- Dependencies: 224 230 2742 3322
-- Name: FK_AsientoM_UsFonpro_UsuarioID_ID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asientom
    ADD CONSTRAINT "FK_AsientoM_UsFonpro_UsuarioID_ID" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2977 (class 2606 OID 129580)
-- Dependencies: 2742 229 224 3322
-- Name: FK_Asiento_UsFonpro_IDUsCierre_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asiento
    ADD CONSTRAINT "FK_Asiento_UsFonpro_IDUsCierre_IDUsFonpro" FOREIGN KEY (uscierreid) REFERENCES usfonpro(id);


--
-- TOC entry 2978 (class 2606 OID 129585)
-- Dependencies: 224 2742 229 3322
-- Name: FK_Asiento_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asiento
    ADD CONSTRAINT "FK_Asiento_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2925 (class 2606 OID 129590)
-- Dependencies: 2572 174 176 3322
-- Name: FK_BaCuenta_Bancos_IDBanco; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY bacuenta
    ADD CONSTRAINT "FK_BaCuenta_Bancos_IDBanco" FOREIGN KEY (bancoid) REFERENCES bancos(id) MATCH FULL;


--
-- TOC entry 2926 (class 2606 OID 129595)
-- Dependencies: 224 174 2742 3322
-- Name: FK_BaCuenta_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY bacuenta
    ADD CONSTRAINT "FK_BaCuenta_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2927 (class 2606 OID 129600)
-- Dependencies: 224 176 2742 3322
-- Name: FK_Bancos_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY bancos
    ADD CONSTRAINT "FK_Bancos_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2928 (class 2606 OID 129605)
-- Dependencies: 178 180 2585 3322
-- Name: FK_CalPagoD_CalPago_IDCalPago; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY calpagod
    ADD CONSTRAINT "FK_CalPagoD_CalPago_IDCalPago" FOREIGN KEY (calpagoid) REFERENCES calpago(id) MATCH FULL;


--
-- TOC entry 2929 (class 2606 OID 129610)
-- Dependencies: 224 2742 178 3322
-- Name: FK_CalPagoD_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY calpagod
    ADD CONSTRAINT "FK_CalPagoD_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2930 (class 2606 OID 129615)
-- Dependencies: 224 2742 180 3322
-- Name: FK_CalPago_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY calpago
    ADD CONSTRAINT "FK_CalPago_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2931 (class 2606 OID 129620)
-- Dependencies: 180 216 2715 3322
-- Name: FK_CalPagos_TiPeGrav_IDTiPeGrav; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY calpago
    ADD CONSTRAINT "FK_CalPagos_TiPeGrav_IDTiPeGrav" FOREIGN KEY (tipegravid) REFERENCES tipegrav(id) MATCH FULL;


--
-- TOC entry 2932 (class 2606 OID 129625)
-- Dependencies: 2742 182 224 3322
-- Name: FK_Cargos_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY cargos
    ADD CONSTRAINT "FK_Cargos_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2933 (class 2606 OID 129630)
-- Dependencies: 204 2677 184 3322
-- Name: FK_Ciudades_Estados_IDEstado; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY ciudades
    ADD CONSTRAINT "FK_Ciudades_Estados_IDEstado" FOREIGN KEY (estadoid) REFERENCES estados(id) MATCH FULL;


--
-- TOC entry 2934 (class 2606 OID 129635)
-- Dependencies: 184 224 2742 3322
-- Name: FK_Ciudades_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY ciudades
    ADD CONSTRAINT "FK_Ciudades_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2935 (class 2606 OID 129640)
-- Dependencies: 192 2616 186 3322
-- Name: FK_ConUsuCo_ConUsu_IDConUsu; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusuco
    ADD CONSTRAINT "FK_ConUsuCo_ConUsu_IDConUsu" FOREIGN KEY (conusuid) REFERENCES conusu(id) MATCH FULL;


--
-- TOC entry 2936 (class 2606 OID 129645)
-- Dependencies: 194 2631 186 3322
-- Name: FK_ConUsuCo_Contribu_IDContribu; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusuco
    ADD CONSTRAINT "FK_ConUsuCo_Contribu_IDContribu" FOREIGN KEY (contribuid) REFERENCES contribu(id) MATCH FULL;


--
-- TOC entry 2937 (class 2606 OID 129650)
-- Dependencies: 224 188 2742 3322
-- Name: FK_ConUsuTi_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusuti
    ADD CONSTRAINT "FK_ConUsuTi_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2938 (class 2606 OID 129655)
-- Dependencies: 192 2616 190 3322
-- Name: FK_ConUsuTo_ConUsu_IDConUsu; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusuto
    ADD CONSTRAINT "FK_ConUsuTo_ConUsu_IDConUsu" FOREIGN KEY (conusuid) REFERENCES conusu(id) MATCH FULL;


--
-- TOC entry 2939 (class 2606 OID 129660)
-- Dependencies: 192 2605 188 3322
-- Name: FK_ConUsu_ConUsuTi_IDConUsuTi; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusu
    ADD CONSTRAINT "FK_ConUsu_ConUsuTi_IDConUsuTi" FOREIGN KEY (conusutiid) REFERENCES conusuti(id) MATCH FULL;


--
-- TOC entry 2940 (class 2606 OID 129665)
-- Dependencies: 192 210 2694 3322
-- Name: FK_ConUsu_PregSecr_IDPregSecr; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusu
    ADD CONSTRAINT "FK_ConUsu_PregSecr_IDPregSecr" FOREIGN KEY (pregsecrid) REFERENCES pregsecr(id) MATCH FULL;


--
-- TOC entry 2941 (class 2606 OID 129670)
-- Dependencies: 224 2742 192 3322
-- Name: FK_ConUsu_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusu
    ADD CONSTRAINT "FK_ConUsu_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2987 (class 2606 OID 129675)
-- Dependencies: 194 240 2631 3322
-- Name: FK_ContribuTi_Contribu_ContribuID_ID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY contributi
    ADD CONSTRAINT "FK_ContribuTi_Contribu_ContribuID_ID" FOREIGN KEY (contribuid) REFERENCES contribu(id) MATCH FULL;


--
-- TOC entry 2988 (class 2606 OID 129680)
-- Dependencies: 2721 218 240 3322
-- Name: FK_ContribuTi_TipoCont_TipoContID_ID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY contributi
    ADD CONSTRAINT "FK_ContribuTi_TipoCont_TipoContID_ID" FOREIGN KEY (tipocontid) REFERENCES tipocont(id) MATCH FULL;


--
-- TOC entry 2942 (class 2606 OID 129685)
-- Dependencies: 2546 194 167 3322
-- Name: FK_Contribu_ActiEcon_IDActiEcon; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY contribu
    ADD CONSTRAINT "FK_Contribu_ActiEcon_IDActiEcon" FOREIGN KEY (actieconid) REFERENCES actiecon(id) MATCH FULL;


--
-- TOC entry 2943 (class 2606 OID 129690)
-- Dependencies: 194 184 2596 3322
-- Name: FK_Contribu_Ciudades_IDCiudad; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY contribu
    ADD CONSTRAINT "FK_Contribu_Ciudades_IDCiudad" FOREIGN KEY (ciudadid) REFERENCES ciudades(id) MATCH FULL;


--
-- TOC entry 2944 (class 2606 OID 129695)
-- Dependencies: 2616 192 194 3322
-- Name: FK_Contribu_ConUsu_UsuarioID_ID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY contribu
    ADD CONSTRAINT "FK_Contribu_ConUsu_UsuarioID_ID" FOREIGN KEY (usuarioid) REFERENCES conusu(id) MATCH FULL;


--
-- TOC entry 2945 (class 2606 OID 129700)
-- Dependencies: 194 204 2677 3322
-- Name: FK_Contribu_Estados_IDEstado; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY contribu
    ADD CONSTRAINT "FK_Contribu_Estados_IDEstado" FOREIGN KEY (estadoid) REFERENCES estados(id) MATCH FULL;


--
-- TOC entry 2992 (class 2606 OID 129705)
-- Dependencies: 250 224 2742 3322
-- Name: FK_CtaConta_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY ctaconta
    ADD CONSTRAINT "FK_CtaConta_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2993 (class 2606 OID 130301)
-- Dependencies: 251 229 2764 3322
-- Name: FK_Decla_Asiento_IDAsiento; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT "FK_Decla_Asiento_IDAsiento" FOREIGN KEY (asientoid) REFERENCES asiento(id);


--
-- TOC entry 2994 (class 2606 OID 130306)
-- Dependencies: 178 2576 251 3322
-- Name: FK_Decla_Calpagod_id; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT "FK_Decla_Calpagod_id" FOREIGN KEY (calpagodid) REFERENCES calpagod(id);


--
-- TOC entry 2995 (class 2606 OID 130311)
-- Dependencies: 251 2815 251 3322
-- Name: FK_Decla_PlaSustID_ID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT "FK_Decla_PlaSustID_ID" FOREIGN KEY (plasustid) REFERENCES declara(id);


--
-- TOC entry 2996 (class 2606 OID 130316)
-- Dependencies: 2705 251 212 3322
-- Name: FK_Decla_RepLegal_IDRepLegal; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT "FK_Decla_RepLegal_IDRepLegal" FOREIGN KEY (replegalid) REFERENCES replegal(id) MATCH FULL;


--
-- TOC entry 2997 (class 2606 OID 130321)
-- Dependencies: 251 214 2710 3322
-- Name: FK_Decla_TDeclara_IDTDeclara; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT "FK_Decla_TDeclara_IDTDeclara" FOREIGN KEY (tdeclaraid) REFERENCES tdeclara(id) MATCH FULL;


--
-- TOC entry 2998 (class 2606 OID 130326)
-- Dependencies: 2742 224 251 3322
-- Name: FK_Decla_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT "FK_Decla_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id);


--
-- TOC entry 2999 (class 2606 OID 130331)
-- Dependencies: 2721 251 218 3322
-- Name: FK_Decla_tipocontribuid; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT "FK_Decla_tipocontribuid" FOREIGN KEY (tipocontribuid) REFERENCES tipocont(id);


--
-- TOC entry 2946 (class 2606 OID 129745)
-- Dependencies: 229 196 2764 3322
-- Name: FK_Declara_Asiento_IDAsiento; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara_viejo
    ADD CONSTRAINT "FK_Declara_Asiento_IDAsiento" FOREIGN KEY (asientoid) REFERENCES asiento(id);


--
-- TOC entry 2947 (class 2606 OID 129750)
-- Dependencies: 196 178 2576 3322
-- Name: FK_Declara_Calpagod_id; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara_viejo
    ADD CONSTRAINT "FK_Declara_Calpagod_id" FOREIGN KEY (calpagodid) REFERENCES calpagod(id);


--
-- TOC entry 2948 (class 2606 OID 129755)
-- Dependencies: 2647 196 196 3322
-- Name: FK_Declara_PlaSustID_ID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara_viejo
    ADD CONSTRAINT "FK_Declara_PlaSustID_ID" FOREIGN KEY (plasustid) REFERENCES declara_viejo(id);


--
-- TOC entry 2949 (class 2606 OID 129760)
-- Dependencies: 212 2705 196 3322
-- Name: FK_Declara_RepLegal_IDRepLegal; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara_viejo
    ADD CONSTRAINT "FK_Declara_RepLegal_IDRepLegal" FOREIGN KEY (replegalid) REFERENCES replegal(id) MATCH FULL;


--
-- TOC entry 2950 (class 2606 OID 129765)
-- Dependencies: 196 214 2710 3322
-- Name: FK_Declara_TDeclara_IDTDeclara; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara_viejo
    ADD CONSTRAINT "FK_Declara_TDeclara_IDTDeclara" FOREIGN KEY (tdeclaraid) REFERENCES tdeclara(id) MATCH FULL;


--
-- TOC entry 2951 (class 2606 OID 129770)
-- Dependencies: 196 2742 224 3322
-- Name: FK_Declara_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara_viejo
    ADD CONSTRAINT "FK_Declara_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id);


--
-- TOC entry 2952 (class 2606 OID 129775)
-- Dependencies: 218 196 2721 3322
-- Name: FK_Declara_tipocontribuid; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara_viejo
    ADD CONSTRAINT "FK_Declara_tipocontribuid" FOREIGN KEY (tipocontribuid) REFERENCES tipocont(id);


--
-- TOC entry 3007 (class 2606 OID 129780)
-- Dependencies: 224 2742 266 3322
-- Name: FK_Document_UsFonpro_UsFonproID_ID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY document
    ADD CONSTRAINT "FK_Document_UsFonpro_UsFonproID_ID" FOREIGN KEY (usfonproid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2955 (class 2606 OID 129785)
-- Dependencies: 202 2672 200 3322
-- Name: FK_EntidadD_Entidad_IDEntidad; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY entidadd
    ADD CONSTRAINT "FK_EntidadD_Entidad_IDEntidad" FOREIGN KEY (entidadid) REFERENCES entidad(id) MATCH FULL;


--
-- TOC entry 2956 (class 2606 OID 129790)
-- Dependencies: 2742 224 204 3322
-- Name: FK_Estados_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY estados
    ADD CONSTRAINT "FK_Estados_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2957 (class 2606 OID 129795)
-- Dependencies: 2664 206 200 3322
-- Name: FK_PerUsuD_EndidadD_IDEntidadD; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY perusud
    ADD CONSTRAINT "FK_PerUsuD_EndidadD_IDEntidadD" FOREIGN KEY (entidaddid) REFERENCES entidadd(id) MATCH FULL;


--
-- TOC entry 2958 (class 2606 OID 129800)
-- Dependencies: 206 208 2689 3322
-- Name: FK_PerUsuD_PerUsu_IDPerUsu; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY perusud
    ADD CONSTRAINT "FK_PerUsuD_PerUsu_IDPerUsu" FOREIGN KEY (perusuid) REFERENCES perusu(id) MATCH FULL;


--
-- TOC entry 2959 (class 2606 OID 129805)
-- Dependencies: 224 206 2742 3322
-- Name: FK_PerUsuD_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY perusud
    ADD CONSTRAINT "FK_PerUsuD_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2960 (class 2606 OID 129810)
-- Dependencies: 208 2742 224 3322
-- Name: FK_PerUsu_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY perusu
    ADD CONSTRAINT "FK_PerUsu_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2961 (class 2606 OID 129815)
-- Dependencies: 2742 210 224 3322
-- Name: FK_PregSecr_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY pregsecr
    ADD CONSTRAINT "FK_PregSecr_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2962 (class 2606 OID 129820)
-- Dependencies: 2596 184 212 3322
-- Name: FK_RepLegal_IDCiudad; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY replegal
    ADD CONSTRAINT "FK_RepLegal_IDCiudad" FOREIGN KEY (ciudadid) REFERENCES ciudades(id) MATCH FULL;


--
-- TOC entry 2964 (class 2606 OID 129825)
-- Dependencies: 224 214 2742 3322
-- Name: FK_TDeclara_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tdeclara
    ADD CONSTRAINT "FK_TDeclara_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2965 (class 2606 OID 129830)
-- Dependencies: 224 2742 216 3322
-- Name: FK_TiPeGrav_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tipegrav
    ADD CONSTRAINT "FK_TiPeGrav_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2966 (class 2606 OID 129835)
-- Dependencies: 2715 216 218 3322
-- Name: FK_TipoCont_TiPeGrav_IDTiPeGrav; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tipocont
    ADD CONSTRAINT "FK_TipoCont_TiPeGrav_IDTiPeGrav" FOREIGN KEY (tipegravid) REFERENCES tipegrav(id) MATCH FULL;


--
-- TOC entry 2967 (class 2606 OID 129840)
-- Dependencies: 224 218 2742 3322
-- Name: FK_TipoCont_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tipocont
    ADD CONSTRAINT "FK_TipoCont_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 3015 (class 2606 OID 129845)
-- Dependencies: 2546 275 167 3322
-- Name: FK_TmpContri_ActiEcon_IDActiEcon; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tmpcontri
    ADD CONSTRAINT "FK_TmpContri_ActiEcon_IDActiEcon" FOREIGN KEY (actieconid) REFERENCES actiecon(id) MATCH FULL;


--
-- TOC entry 3016 (class 2606 OID 129850)
-- Dependencies: 275 184 2596 3322
-- Name: FK_TmpContri_Ciudades_IDCiudad; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tmpcontri
    ADD CONSTRAINT "FK_TmpContri_Ciudades_IDCiudad" FOREIGN KEY (ciudadid) REFERENCES ciudades(id) MATCH FULL;


--
-- TOC entry 3017 (class 2606 OID 129855)
-- Dependencies: 275 2631 194 3322
-- Name: FK_TmpContri_Contribu_IDContribu; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tmpcontri
    ADD CONSTRAINT "FK_TmpContri_Contribu_IDContribu" FOREIGN KEY (id) REFERENCES contribu(id) MATCH FULL;


--
-- TOC entry 3018 (class 2606 OID 129860)
-- Dependencies: 204 2677 275 3322
-- Name: FK_TmpContri_Estados_IDEstado; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tmpcontri
    ADD CONSTRAINT "FK_TmpContri_Estados_IDEstado" FOREIGN KEY (estadoid) REFERENCES estados(id) MATCH FULL;


--
-- TOC entry 3019 (class 2606 OID 129865)
-- Dependencies: 2721 275 218 3322
-- Name: FK_TmpContri_TipoCont_IDTipoCont; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tmpcontri
    ADD CONSTRAINT "FK_TmpContri_TipoCont_IDTipoCont" FOREIGN KEY (tipocontid) REFERENCES tipocont(id) MATCH FULL;


--
-- TOC entry 3020 (class 2606 OID 129870)
-- Dependencies: 276 2596 184 3322
-- Name: FK_TmpReLegal_IDCiudad; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tmprelegal
    ADD CONSTRAINT "FK_TmpReLegal_IDCiudad" FOREIGN KEY (ciudadid) REFERENCES ciudades(id) MATCH FULL;


--
-- TOC entry 3021 (class 2606 OID 129875)
-- Dependencies: 275 276 2864 3322
-- Name: FK_TmpReLegal_IDContribu; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tmprelegal
    ADD CONSTRAINT "FK_TmpReLegal_IDContribu" FOREIGN KEY (contribuid) REFERENCES tmpcontri(id) MATCH FULL;


--
-- TOC entry 3022 (class 2606 OID 129880)
-- Dependencies: 204 276 2677 3322
-- Name: FK_TmpReLegal_IDEstado; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tmprelegal
    ADD CONSTRAINT "FK_TmpReLegal_IDEstado" FOREIGN KEY (estadoid) REFERENCES estados(id) MATCH FULL;


--
-- TOC entry 3023 (class 2606 OID 129885)
-- Dependencies: 212 276 2705 3322
-- Name: FK_TmpReLegal_IDRepLegal; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tmprelegal
    ADD CONSTRAINT "FK_TmpReLegal_IDRepLegal" FOREIGN KEY (id) REFERENCES replegal(id) MATCH FULL;


--
-- TOC entry 2968 (class 2606 OID 129890)
-- Dependencies: 2742 224 220 3322
-- Name: FK_UndTrib_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY undtrib
    ADD CONSTRAINT "FK_UndTrib_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2970 (class 2606 OID 129895)
-- Dependencies: 2694 224 210 3322
-- Name: FK_UsFonPro_PregSecr_IDPregSecr; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY usfonpro
    ADD CONSTRAINT "FK_UsFonPro_PregSecr_IDPregSecr" FOREIGN KEY (pregsecrid) REFERENCES pregsecr(id) MATCH FULL;


--
-- TOC entry 2969 (class 2606 OID 129900)
-- Dependencies: 2742 222 224 3322
-- Name: FK_UsFonpTo_UsFonpro_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY usfonpto
    ADD CONSTRAINT "FK_UsFonpTo_UsFonpro_IDUsFonpro" FOREIGN KEY (usfonproid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2971 (class 2606 OID 129905)
-- Dependencies: 182 224 2590 3322
-- Name: FK_UsFonpro_Cargos_IDCargo; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY usfonpro
    ADD CONSTRAINT "FK_UsFonpro_Cargos_IDCargo" FOREIGN KEY (cargoid) REFERENCES cargos(id) MATCH FULL;


--
-- TOC entry 2972 (class 2606 OID 129910)
-- Dependencies: 224 198 2651 3322
-- Name: FK_UsFonpro_Departam_IDDepartam; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY usfonpro
    ADD CONSTRAINT "FK_UsFonpro_Departam_IDDepartam" FOREIGN KEY (departamid) REFERENCES departam(id) MATCH FULL;


--
-- TOC entry 2973 (class 2606 OID 129915)
-- Dependencies: 224 2689 208 3322
-- Name: FK_UsFonpro_PerUsu_IDPerUsu; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY usfonpro
    ADD CONSTRAINT "FK_UsFonpro_PerUsu_IDPerUsu" FOREIGN KEY (perusuid) REFERENCES perusu(id);


--
-- TOC entry 2986 (class 2606 OID 129920)
-- Dependencies: 192 236 2616 3322
-- Name: FK_conusu_id; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY con_img_doc
    ADD CONSTRAINT "FK_conusu_id" FOREIGN KEY (conusuid) REFERENCES conusu(id) MATCH FULL;


--
-- TOC entry 3009 (class 2606 OID 129925)
-- Dependencies: 229 273 2764 3322
-- Name: FK_reparos_Asiento_IDAsiento; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY reparos
    ADD CONSTRAINT "FK_reparos_Asiento_IDAsiento" FOREIGN KEY (asientoid) REFERENCES asiento(id);


--
-- TOC entry 3010 (class 2606 OID 129930)
-- Dependencies: 273 214 2710 3322
-- Name: FK_reparos_TDeclara_IDTDeclara; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY reparos
    ADD CONSTRAINT "FK_reparos_TDeclara_IDTDeclara" FOREIGN KEY (tdeclaraid) REFERENCES tdeclara(id) MATCH FULL;


--
-- TOC entry 3011 (class 2606 OID 129935)
-- Dependencies: 2742 273 224 3322
-- Name: FK_reparos_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY reparos
    ADD CONSTRAINT "FK_reparos_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id);


--
-- TOC entry 3012 (class 2606 OID 129940)
-- Dependencies: 218 273 2721 3322
-- Name: FK_reparos_tipocontribuid; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY reparos
    ADD CONSTRAINT "FK_reparos_tipocontribuid" FOREIGN KEY (tipocontribuid) REFERENCES tipocont(id);


--
-- TOC entry 3014 (class 2606 OID 129945)
-- Dependencies: 275 274 2864 3322
-- Name: FK_tmpAccioni_ContribuID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tmpaccioni
    ADD CONSTRAINT "FK_tmpAccioni_ContribuID" FOREIGN KEY (contribuid) REFERENCES tmpcontri(id) MATCH FULL;


--
-- TOC entry 2954 (class 2606 OID 129950)
-- Dependencies: 224 2742 198 3322
-- Name: FL_Departam_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY departam
    ADD CONSTRAINT "FL_Departam_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2963 (class 2606 OID 129955)
-- Dependencies: 212 2616 192 3322
-- Name: Fk_replegal_conusuid; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY replegal
    ADD CONSTRAINT "Fk_replegal_conusuid" FOREIGN KEY (contribuid) REFERENCES conusu(id);


--
-- TOC entry 2983 (class 2606 OID 129960)
-- Dependencies: 234 2616 192 3322
-- Name: fk-asignacion-contribuyente; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asignacion_fiscales
    ADD CONSTRAINT "fk-asignacion-contribuyente" FOREIGN KEY (conusuid) REFERENCES conusu(id);


--
-- TOC entry 2984 (class 2606 OID 129965)
-- Dependencies: 234 2742 224 3322
-- Name: fk-asignacion-fonprocine; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asignacion_fiscales
    ADD CONSTRAINT "fk-asignacion-fonprocine" FOREIGN KEY (usfonproid) REFERENCES usfonpro(id);


--
-- TOC entry 2985 (class 2606 OID 129970)
-- Dependencies: 234 2742 224 3322
-- Name: fk-asignacion-usuario; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asignacion_fiscales
    ADD CONSTRAINT "fk-asignacion-usuario" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id);


--
-- TOC entry 3008 (class 2606 OID 129975)
-- Dependencies: 268 2742 224 3322
-- Name: fk-usuario; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY interes_bcv
    ADD CONSTRAINT "fk-usuario" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id);


--
-- TOC entry 2976 (class 2606 OID 129980)
-- Dependencies: 2742 224 227 3322
-- Name: fk_acta_reparo_usuarioid; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY actas_reparo
    ADD CONSTRAINT fk_acta_reparo_usuarioid FOREIGN KEY (usuarioid) REFERENCES usfonpro(id);


--
-- TOC entry 3006 (class 2606 OID 129985)
-- Dependencies: 264 2776 234 3322
-- Name: fk_asignacion_fiscal_id; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY dettalles_fizcalizacion
    ADD CONSTRAINT fk_asignacion_fiscal_id FOREIGN KEY (asignacionfid) REFERENCES asignacion_fiscales(id);


--
-- TOC entry 2989 (class 2606 OID 129990)
-- Dependencies: 192 2616 242 3322
-- Name: fk_conusu_interno_conusu; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusu_interno
    ADD CONSTRAINT fk_conusu_interno_conusu FOREIGN KEY (conusuid) REFERENCES conusu(id);


--
-- TOC entry 2990 (class 2606 OID 129995)
-- Dependencies: 224 2742 242 3322
-- Name: fk_conusu_interno_usfonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusu_interno
    ADD CONSTRAINT fk_conusu_interno_usfonpro FOREIGN KEY (usuarioid) REFERENCES usfonpro(id);


--
-- TOC entry 2991 (class 2606 OID 130000)
-- Dependencies: 192 2616 244 3322
-- Name: fk_conusuid; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusu_tipocont
    ADD CONSTRAINT fk_conusuid FOREIGN KEY (conusuid) REFERENCES conusu(id) MATCH FULL;


--
-- TOC entry 2953 (class 2606 OID 130005)
-- Dependencies: 192 2616 196 3322
-- Name: fk_conusuid; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara_viejo
    ADD CONSTRAINT fk_conusuid FOREIGN KEY (conusuid) REFERENCES conusu(id) MATCH FULL;


--
-- TOC entry 3000 (class 2606 OID 130336)
-- Dependencies: 2616 251 192 3322
-- Name: fk_conusuid; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT fk_conusuid FOREIGN KEY (conusuid) REFERENCES conusu(id) MATCH FULL;


--
-- TOC entry 3004 (class 2606 OID 130015)
-- Dependencies: 262 251 2815 3322
-- Name: fk_declaraid_contric_calc_iddeclara; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY detalles_contrib_calc
    ADD CONSTRAINT fk_declaraid_contric_calc_iddeclara FOREIGN KEY (declaraid) REFERENCES declara(id);


--
-- TOC entry 3003 (class 2606 OID 130020)
-- Dependencies: 256 273 2842 3322
-- Name: fk_descargos_reparoid; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY descargos
    ADD CONSTRAINT fk_descargos_reparoid FOREIGN KEY (reparoid) REFERENCES reparos(id);


--
-- TOC entry 3005 (class 2606 OID 130025)
-- Dependencies: 2780 262 238 3322
-- Name: fk_detalles_contric_calid_a_contric_calid; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY detalles_contrib_calc
    ADD CONSTRAINT fk_detalles_contric_calid_a_contric_calid FOREIGN KEY (contrib_calcid) REFERENCES contrib_calc(id);


--
-- TOC entry 3013 (class 2606 OID 130030)
-- Dependencies: 2616 273 192 3322
-- Name: fk_reparos_conusuid; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY reparos
    ADD CONSTRAINT fk_reparos_conusuid FOREIGN KEY (conusuid) REFERENCES conusu(id);


SET search_path = pre_aprobacion, pg_catalog;

--
-- TOC entry 3001 (class 2606 OID 130289)
-- Dependencies: 254 2742 224 3322
-- Name: fk-multa-usuario; Type: FK CONSTRAINT; Schema: pre_aprobacion; Owner: postgres
--

ALTER TABLE ONLY multas
    ADD CONSTRAINT "fk-multa-usuario" FOREIGN KEY (usuarioid) REFERENCES datos.usfonpro(id);


--
-- TOC entry 3002 (class 2606 OID 130294)
-- Dependencies: 2815 251 254 3322
-- Name: fk_multa_declaraid; Type: FK CONSTRAINT; Schema: pre_aprobacion; Owner: postgres
--

ALTER TABLE ONLY multas
    ADD CONSTRAINT fk_multa_declaraid FOREIGN KEY (declaraid) REFERENCES datos.declara(id);


SET search_path = seg, pg_catalog;

--
-- TOC entry 3025 (class 2606 OID 130045)
-- Dependencies: 2891 288 292 3322
-- Name: fk_permiso_modulo; Type: FK CONSTRAINT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_permiso
    ADD CONSTRAINT fk_permiso_modulo FOREIGN KEY (id_modulo) REFERENCES tbl_modulo(id_modulo) ON DELETE RESTRICT;


--
-- TOC entry 3026 (class 2606 OID 130050)
-- Dependencies: 296 292 2901 3322
-- Name: fk_permiso_rol; Type: FK CONSTRAINT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_permiso
    ADD CONSTRAINT fk_permiso_rol FOREIGN KEY (id_rol) REFERENCES tbl_rol(id_rol) ON DELETE RESTRICT;


--
-- TOC entry 3029 (class 2606 OID 130055)
-- Dependencies: 296 298 2901 3322
-- Name: fk_rol_usuario_rol; Type: FK CONSTRAINT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_rol_usuario
    ADD CONSTRAINT fk_rol_usuario_rol FOREIGN KEY (id_rol) REFERENCES tbl_rol(id_rol) ON DELETE RESTRICT;


--
-- TOC entry 3024 (class 2606 OID 130060)
-- Dependencies: 290 2895 285 3322
-- Name: fk_tblcargos; Type: FK CONSTRAINT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_cargos
    ADD CONSTRAINT fk_tblcargos FOREIGN KEY (oficinasid) REFERENCES tbl_oficinas(id);


--
-- TOC entry 3030 (class 2606 OID 130065)
-- Dependencies: 296 2901 301 3322
-- Name: fk_usuario_rol_rol; Type: FK CONSTRAINT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_usuario_rol
    ADD CONSTRAINT fk_usuario_rol_rol FOREIGN KEY (id_rol) REFERENCES tbl_rol(id_rol) ON DELETE RESTRICT;


--
-- TOC entry 3027 (class 2606 OID 130070)
-- Dependencies: 288 294 2891 3322
-- Name: fkt_permiso_modulo; Type: FK CONSTRAINT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_permiso_trampa
    ADD CONSTRAINT fkt_permiso_modulo FOREIGN KEY (id_modulo) REFERENCES tbl_modulo(id_modulo) ON DELETE RESTRICT;


--
-- TOC entry 3028 (class 2606 OID 130075)
-- Dependencies: 2901 296 294 3322
-- Name: fkt_permiso_rol; Type: FK CONSTRAINT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_permiso_trampa
    ADD CONSTRAINT fkt_permiso_rol FOREIGN KEY (id_rol) REFERENCES tbl_rol(id_rol) ON DELETE RESTRICT;


SET search_path = "segContribu", pg_catalog;

--
-- TOC entry 3031 (class 2606 OID 130080)
-- Dependencies: 2909 307 305 3322
-- Name: fk_permiso_modulo; Type: FK CONSTRAINT; Schema: segContribu; Owner: postgres
--

ALTER TABLE ONLY tbl_permiso_contribu
    ADD CONSTRAINT fk_permiso_modulo FOREIGN KEY (id_modulo) REFERENCES tbl_modulo_contribu(id_modulo) ON DELETE RESTRICT;


--
-- TOC entry 3032 (class 2606 OID 130085)
-- Dependencies: 309 307 2913 3322
-- Name: fk_permiso_rol; Type: FK CONSTRAINT; Schema: segContribu; Owner: postgres
--

ALTER TABLE ONLY tbl_permiso_contribu
    ADD CONSTRAINT fk_permiso_rol FOREIGN KEY (id_rol) REFERENCES tbl_rol_contribu(id_rol) ON DELETE RESTRICT;


--
-- TOC entry 3033 (class 2606 OID 130090)
-- Dependencies: 2913 311 309 3322
-- Name: fk_rol_usuario_rol; Type: FK CONSTRAINT; Schema: segContribu; Owner: postgres
--

ALTER TABLE ONLY tbl_rol_usuario_contribu
    ADD CONSTRAINT fk_rol_usuario_rol FOREIGN KEY (id_rol) REFERENCES tbl_rol_contribu(id_rol) ON DELETE RESTRICT;


--
-- TOC entry 3034 (class 2606 OID 130095)
-- Dependencies: 2913 309 313 3322
-- Name: fk_usuario_rol_rol; Type: FK CONSTRAINT; Schema: segContribu; Owner: postgres
--

ALTER TABLE ONLY tbl_usuario_rol_contribu
    ADD CONSTRAINT fk_usuario_rol_rol FOREIGN KEY (id_rol) REFERENCES tbl_rol_contribu(id_rol) ON DELETE RESTRICT;


--
-- TOC entry 3328 (class 0 OID 0)
-- Dependencies: 9
-- Name: datos; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA datos FROM PUBLIC;
REVOKE ALL ON SCHEMA datos FROM postgres;
GRANT ALL ON SCHEMA datos TO postgres;
GRANT ALL ON SCHEMA datos TO PUBLIC;


--
-- TOC entry 3330 (class 0 OID 0)
-- Dependencies: 10
-- Name: historial; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA historial FROM PUBLIC;
REVOKE ALL ON SCHEMA historial FROM postgres;
GRANT ALL ON SCHEMA historial TO postgres;
GRANT ALL ON SCHEMA historial TO PUBLIC;


--
-- TOC entry 3332 (class 0 OID 0)
-- Dependencies: 11
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


SET search_path = datos, pg_catalog;

--
-- TOC entry 3348 (class 0 OID 0)
-- Dependencies: 167
-- Name: actiecon; Type: ACL; Schema: datos; Owner: postgres
--

REVOKE ALL ON TABLE actiecon FROM PUBLIC;
REVOKE ALL ON TABLE actiecon FROM postgres;
GRANT ALL ON TABLE actiecon TO postgres;


SET search_path = historial, pg_catalog;

--
-- TOC entry 3886 (class 0 OID 0)
-- Dependencies: 278
-- Name: bitacora; Type: ACL; Schema: historial; Owner: postgres
--

REVOKE ALL ON TABLE bitacora FROM PUBLIC;
REVOKE ALL ON TABLE bitacora FROM postgres;
GRANT ALL ON TABLE bitacora TO postgres;
GRANT ALL ON TABLE bitacora TO PUBLIC;


--
-- TOC entry 3888 (class 0 OID 0)
-- Dependencies: 279
-- Name: Bitacora_IDBitacora_seq; Type: ACL; Schema: historial; Owner: postgres
--

REVOKE ALL ON SEQUENCE "Bitacora_IDBitacora_seq" FROM PUBLIC;
REVOKE ALL ON SEQUENCE "Bitacora_IDBitacora_seq" FROM postgres;
GRANT ALL ON SEQUENCE "Bitacora_IDBitacora_seq" TO postgres;
GRANT ALL ON SEQUENCE "Bitacora_IDBitacora_seq" TO PUBLIC;


--
-- TOC entry 1950 (class 826 OID 130100)
-- Dependencies: 10 3322
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: historial; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA historial REVOKE ALL ON SEQUENCES  FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA historial REVOKE ALL ON SEQUENCES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA historial GRANT ALL ON SEQUENCES  TO PUBLIC;


--
-- TOC entry 1951 (class 826 OID 130101)
-- Dependencies: 10 3322
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: historial; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA historial REVOKE ALL ON FUNCTIONS  FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA historial REVOKE ALL ON FUNCTIONS  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA historial GRANT ALL ON FUNCTIONS  TO PUBLIC;


--
-- TOC entry 1952 (class 826 OID 130102)
-- Dependencies: 10 3322
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: historial; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA historial REVOKE ALL ON TABLES  FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA historial REVOKE ALL ON TABLES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA historial GRANT ALL ON TABLES  TO PUBLIC;


-- Completed on 2013-11-15 14:53:04 VET

--
-- PostgreSQL database dump complete
--

