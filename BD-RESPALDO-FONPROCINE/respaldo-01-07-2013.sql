--
-- PostgreSQL database dump
--

-- Dumped from database version 9.1.9
-- Dumped by pg_dump version 9.1.9
-- Started on 2013-07-02 14:26:13 VET

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 3259 (class 1262 OID 20512)
-- Dependencies: 3258
-- Name: FONPROCINE; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE "FONPROCINE" IS 'Base de datos del sistema de recaudación de Fonprocine';


--
-- TOC entry 7 (class 2615 OID 20513)
-- Name: datos; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA datos;


ALTER SCHEMA datos OWNER TO postgres;

--
-- TOC entry 3260 (class 0 OID 0)
-- Dependencies: 7
-- Name: SCHEMA datos; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA datos IS 'standard public schema';


--
-- TOC entry 8 (class 2615 OID 20514)
-- Name: historial; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA historial;


ALTER SCHEMA historial OWNER TO postgres;

--
-- TOC entry 3262 (class 0 OID 0)
-- Dependencies: 8
-- Name: SCHEMA historial; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA historial IS 'Esquema para la tabla de historial de transacciones';


--
-- TOC entry 11 (class 2615 OID 77245)
-- Name: pre_aprobacion; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA pre_aprobacion;


ALTER SCHEMA pre_aprobacion OWNER TO postgres;

--
-- TOC entry 10 (class 2615 OID 21561)
-- Name: seg; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA seg;


ALTER SCHEMA seg OWNER TO postgres;

--
-- TOC entry 9 (class 2615 OID 22843)
-- Name: segContribu; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA "segContribu";


ALTER SCHEMA "segContribu" OWNER TO postgres;

--
-- TOC entry 306 (class 3079 OID 11720)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 3266 (class 0 OID 0)
-- Dependencies: 306
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = datos, pg_catalog;

--
-- TOC entry 329 (class 1255 OID 87775)
-- Dependencies: 7 972
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
			END CASE;
			
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
			nro_autorizacion=(1||'-'||(anio_servidor+1))
			WHERE id=new.id;

			UPDATE datos.correlativos_actas
			SET  correlativo=2,anio=(select (Extract(year FROM now())+1))
			WHERE id=condicion;
				
		
		END IF;			


	END IF;
	



RETURN NULL;
END;


$$;


ALTER FUNCTION datos.crea_correlativo_actas() OWNER TO postgres;

--
-- TOC entry 318 (class 1255 OID 20515)
-- Dependencies: 972 7
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
-- TOC entry 3267 (class 0 OID 0)
-- Dependencies: 318
-- Name: FUNCTION "pa_ActUsuBitDel"("Tabla" text, "ValorID" integer, "IDUsuario" integer, OUT "Actualizado" boolean); Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON FUNCTION "pa_ActUsuBitDel"("Tabla" text, "ValorID" integer, "IDUsuario" integer, OUT "Actualizado" boolean) IS 'Funcion que actualiza el IDUsuario en la bitacora cuando se elimina un registro. Esta funcion tiene que ser llamada inmediatamente despues de eliminar una fila en cualquier tabla';


--
-- TOC entry 319 (class 1255 OID 20516)
-- Dependencies: 7 972
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
-- TOC entry 3268 (class 0 OID 0)
-- Dependencies: 319
-- Name: FUNCTION "pa_LoginContribu"("LoginUsuario" text, "PasswordUsuario" text, OUT "IDUsuarioContribuyente" integer, OUT "NombreUsuario" text, OUT "IDTipoUsuario" integer, OUT "UltimoLogin" timestamp without time zone); Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON FUNCTION "pa_LoginContribu"("LoginUsuario" text, "PasswordUsuario" text, OUT "IDUsuarioContribuyente" integer, OUT "NombreUsuario" text, OUT "IDTipoUsuario" integer, OUT "UltimoLogin" timestamp without time zone) IS 'Funcion para hacer login de un contribuyente';


--
-- TOC entry 320 (class 1255 OID 20517)
-- Dependencies: 972 7
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
-- TOC entry 3269 (class 0 OID 0)
-- Dependencies: 320
-- Name: FUNCTION "pa_LoginUsFonpro"("LoginUsuario" text, "PasswordUsuario" text, OUT "IDUsuarioFonprocine" integer, OUT "NombreUsuario" text, OUT "IDPerfilUsuario" integer, OUT "UltimoLogin" timestamp without time zone); Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON FUNCTION "pa_LoginUsFonpro"("LoginUsuario" text, "PasswordUsuario" text, OUT "IDUsuarioFonprocine" integer, OUT "NombreUsuario" text, OUT "IDPerfilUsuario" integer, OUT "UltimoLogin" timestamp without time zone) IS 'Funcion para hacer login de un usuario Fonprocine';


--
-- TOC entry 321 (class 1255 OID 20518)
-- Dependencies: 7 972
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
-- TOC entry 3270 (class 0 OID 0)
-- Dependencies: 321
-- Name: FUNCTION "pa_TokenActivoContribu"("IDToken" integer, "IDUsuario" integer, OUT "Activo" boolean, OUT "FechaCreacion" timestamp without time zone, OUT "FechaCaducidad" timestamp without time zone, OUT "FechaHoraServidor" timestamp without time zone, OUT "Observaciones" text); Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON FUNCTION "pa_TokenActivoContribu"("IDToken" integer, "IDUsuario" integer, OUT "Activo" boolean, OUT "FechaCreacion" timestamp without time zone, OUT "FechaCaducidad" timestamp without time zone, OUT "FechaHoraServidor" timestamp without time zone, OUT "Observaciones" text) IS 'Funcion que verifica si el token de usuario de contribuyente buscado esta activo a la fecha hora del servidor';


--
-- TOC entry 322 (class 1255 OID 20519)
-- Dependencies: 972 7
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
-- TOC entry 3271 (class 0 OID 0)
-- Dependencies: 322
-- Name: FUNCTION "pa_TokenActivoUsFonpro"("IDToken" integer, "IDUsuario" integer, OUT "Activo" boolean, OUT "FechaCreacion" timestamp without time zone, OUT "FechaCaducidad" timestamp without time zone, OUT "FechaHoraServidor" timestamp without time zone, OUT "Observaciones" text); Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON FUNCTION "pa_TokenActivoUsFonpro"("IDToken" integer, "IDUsuario" integer, OUT "Activo" boolean, OUT "FechaCreacion" timestamp without time zone, OUT "FechaCaducidad" timestamp without time zone, OUT "FechaHoraServidor" timestamp without time zone, OUT "Observaciones" text) IS 'Funcion que verifica si el token de usuario de forprocine buscado esta activo a la fecha hora del servidor';


--
-- TOC entry 327 (class 1255 OID 46569)
-- Dependencies: 972 7
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
-- TOC entry 323 (class 1255 OID 20520)
-- Dependencies: 7 972
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
-- TOC entry 3272 (class 0 OID 0)
-- Dependencies: 323
-- Name: FUNCTION "tf_AsiendoD_ActualizaDebeHaber_Asiento"(); Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON FUNCTION "tf_AsiendoD_ActualizaDebeHaber_Asiento"() IS 'Funcion de trigger que actualiza las columnas de debe y haber de la tabla Asientos';


--
-- TOC entry 324 (class 1255 OID 20521)
-- Dependencies: 7 972
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
-- TOC entry 3273 (class 0 OID 0)
-- Dependencies: 324
-- Name: FUNCTION "tf_Asiento_ActualizaPeriodo"(); Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON FUNCTION "tf_Asiento_ActualizaPeriodo"() IS 'Funcion de trigger para actualizar las columnas de Mes y Ano, a partir de la fecha especificada';


--
-- TOC entry 325 (class 1255 OID 20522)
-- Dependencies: 7 972
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
-- TOC entry 3274 (class 0 OID 0)
-- Dependencies: 325
-- Name: FUNCTION "tf_Asiento_ActualizaSaldo"(); Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON FUNCTION "tf_Asiento_ActualizaSaldo"() IS 'Funcion que actualiza el saldo de la tabla asiento';


--
-- TOC entry 326 (class 1255 OID 20523)
-- Dependencies: 7 972
-- Name: tf_Bitacora(); Type: FUNCTION; Schema: datos; Owner: postgres
--

CREATE FUNCTION "tf_Bitacora"() RETURNS trigger
    LANGUAGE plpgsql STRICT COST 1
    AS $$
    DECLARE
        Query VARCHAR;
        Columna TEXT;
        Campos_Cursor CURSOR FOR SELECT column_name FROM information_schema.columns WHERE table_name=TG_TABLE_NAME ORDER BY ordinal_position;
	DatosNew historial.hstore;
	DatosOld historial.hstore;
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
        DatosNew := historial.hstore(NEW);
    END IF;

    --Iniciamos hstore con los OLD
    IF TG_OP = 'UPDATE' OR TG_OP = 'DELETE' THEN
        DatosOld := historial.hstore(OLD);
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
-- TOC entry 3275 (class 0 OID 0)
-- Dependencies: 326
-- Name: FUNCTION "tf_Bitacora"(); Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON FUNCTION "tf_Bitacora"() IS 'Trigger para el insert de datos en la bitacora de cambios';


SET search_path = seg, pg_catalog;

--
-- TOC entry 328 (class 1255 OID 78873)
-- Dependencies: 972 10
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
-- TOC entry 166 (class 1259 OID 20524)
-- Dependencies: 7
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
-- TOC entry 167 (class 1259 OID 20526)
-- Dependencies: 7
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
-- TOC entry 3276 (class 0 OID 0)
-- Dependencies: 167
-- Name: TABLE actiecon; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE actiecon IS 'Tabla con las actividades económicas';


--
-- TOC entry 3277 (class 0 OID 0)
-- Dependencies: 167
-- Name: COLUMN actiecon.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN actiecon.id IS 'Identificador del tipo de actividad económica';


--
-- TOC entry 3278 (class 0 OID 0)
-- Dependencies: 167
-- Name: COLUMN actiecon.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN actiecon.nombre IS 'Nombre de la actividad económica';


--
-- TOC entry 3279 (class 0 OID 0)
-- Dependencies: 167
-- Name: COLUMN actiecon.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN actiecon.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3280 (class 0 OID 0)
-- Dependencies: 167
-- Name: COLUMN actiecon.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN actiecon.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 168 (class 1259 OID 20529)
-- Dependencies: 7 167
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
-- TOC entry 3282 (class 0 OID 0)
-- Dependencies: 168
-- Name: ActiEcon_IDActiEcon_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "ActiEcon_IDActiEcon_seq" OWNED BY actiecon.id;


--
-- TOC entry 169 (class 1259 OID 20531)
-- Dependencies: 2419 2420 2421 2422 2423 2424 2425 2426 2427 2428 2429 7
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
-- TOC entry 3283 (class 0 OID 0)
-- Dependencies: 169
-- Name: TABLE alicimp; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE alicimp IS 'Tabla con los datos de las alicuotas impositivas';


--
-- TOC entry 3284 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.id IS 'Identificador de la alicuota';


--
-- TOC entry 3285 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.tipocontid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.tipocontid IS 'Identificador del tipo de contribuyente';


--
-- TOC entry 3286 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.ano; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.ano IS 'Ano en la que aplica la alicuota';


--
-- TOC entry 3287 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.alicuota; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.alicuota IS '% de la alicuota a pagar';


--
-- TOC entry 3288 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.tipocalc; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.tipocalc IS 'Tipo de calculo a usar para seleccionar la alicuota.
0=Aplicar alicuota directamente.
1=Aplicar alicuota de acuerdo al limite inferior en UT.
2=Aplicar alicuota de acuerdo a rangos en UT';


--
-- TOC entry 3289 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.valorut; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.valorut IS 'Limite inferior en UT al cual se le aplica la alicuota. Aplica para TipoCalc=1';


--
-- TOC entry 3290 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.liminf1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.liminf1 IS 'Limite inferior 1 en UT para aplicacion de alicuota por rango. TipoCalc=2';


--
-- TOC entry 3291 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.limsup1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.limsup1 IS 'Limite superior 1 en UT para aplicacion de alicuota por rango. TipoCalc=2';


--
-- TOC entry 3292 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.alicuota1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.alicuota1 IS 'Alicuota del rango 1. TipoCalc=2';


--
-- TOC entry 3293 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.liminf2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.liminf2 IS 'Limite inferior 2 en UT para aplicacion de alicuota por rango. TipoCalc=2';


--
-- TOC entry 3294 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.limsup2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.limsup2 IS 'Limite superior 2 en UT para aplicacion de alicuota por rango. TipoCalc=2';


--
-- TOC entry 3295 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.alicuota2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.alicuota2 IS 'Alicuota del rango 2. TipoCalc=2';


--
-- TOC entry 3296 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.liminf3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.liminf3 IS 'Limite inferior 3 en UT para aplicacion de alicuota por rango. TipoCalc=2';


--
-- TOC entry 3297 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.limsup3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.limsup3 IS 'Limite superior 3 en UT para aplicacion de alicuota por rango. TipoCalc=2';


--
-- TOC entry 3298 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.alicuota3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.alicuota3 IS 'Alicuota del rango 3. TipoCalc=2';


--
-- TOC entry 3299 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.liminf4; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.liminf4 IS 'Limite inferior 4 en UT para aplicacion de alicuota por rango. TipoCalc=2';


--
-- TOC entry 3300 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.limsup4; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.limsup4 IS 'Limite superior 4 en UT para aplicacion de alicuota por rango. TipoCalc=2';


--
-- TOC entry 3301 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.alicuota4; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.alicuota4 IS 'Alicuota del rango 4. TipoCalc=2';


--
-- TOC entry 3302 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.liminf5; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.liminf5 IS 'Limite inferior 5 en UT para aplicacion de alicuota por rango. TipoCalc=2';


--
-- TOC entry 3303 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.limsup5; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.limsup5 IS 'Limite superior 5 en UT para aplicacion de alicuota por rango. TipoCalc=2';


--
-- TOC entry 3304 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.alicuota5; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.alicuota5 IS 'Alicuota del rango 5. TipoCalc=2';


--
-- TOC entry 3305 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.usuarioid IS 'Identificador del ultimo usuario en crear o modificar un registro';


--
-- TOC entry 3306 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 170 (class 1259 OID 20545)
-- Dependencies: 7 169
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
-- TOC entry 3307 (class 0 OID 0)
-- Dependencies: 170
-- Name: AlicImp_IDAlicImp_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "AlicImp_IDAlicImp_seq" OWNED BY alicimp.id;


--
-- TOC entry 171 (class 1259 OID 20547)
-- Dependencies: 2431 2432 7
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
-- TOC entry 3308 (class 0 OID 0)
-- Dependencies: 171
-- Name: TABLE asientod; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE asientod IS 'Tabla con el detalle de los asientos';


--
-- TOC entry 3309 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN asientod.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientod.id IS 'Identificador unico de registro';


--
-- TOC entry 3310 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN asientod.asientoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientod.asientoid IS 'Identificador del asiento';


--
-- TOC entry 3311 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN asientod.fecha; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientod.fecha IS 'Fecha de la transaccion';


--
-- TOC entry 3312 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN asientod.cuenta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientod.cuenta IS 'Cuenta contable';


--
-- TOC entry 3313 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN asientod.monto; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientod.monto IS 'Monto de la transaccion';


--
-- TOC entry 3314 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN asientod.sentido; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientod.sentido IS 'Sentido del monto. 0=Debe / 1=Haber';


--
-- TOC entry 3315 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN asientod.referencia; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientod.referencia IS 'Referencia de la linea';


--
-- TOC entry 3316 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN asientod.comentar; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientod.comentar IS 'Comentarios u observaciones';


--
-- TOC entry 3317 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN asientod.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientod.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3318 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN asientod.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientod.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 172 (class 1259 OID 20555)
-- Dependencies: 7 171
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
-- TOC entry 3319 (class 0 OID 0)
-- Dependencies: 172
-- Name: AsientoD_IDAsientoD_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "AsientoD_IDAsientoD_seq" OWNED BY asientod.id;


--
-- TOC entry 173 (class 1259 OID 20557)
-- Dependencies: 7
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
-- TOC entry 174 (class 1259 OID 20559)
-- Dependencies: 7
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
-- TOC entry 3320 (class 0 OID 0)
-- Dependencies: 174
-- Name: TABLE bacuenta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE bacuenta IS 'Tabla con los datos de las cuentas bancarias';


--
-- TOC entry 3321 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN bacuenta.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN bacuenta.id IS 'Identificador unico de registro';


--
-- TOC entry 3322 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN bacuenta.bancoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN bacuenta.bancoid IS 'Identificador del banco';


--
-- TOC entry 3323 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN bacuenta.cuenta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN bacuenta.cuenta IS 'Numero de cuenta bancaria';


--
-- TOC entry 3324 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN bacuenta.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN bacuenta.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3325 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN bacuenta.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN bacuenta.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 175 (class 1259 OID 20562)
-- Dependencies: 7 174
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
-- TOC entry 3326 (class 0 OID 0)
-- Dependencies: 175
-- Name: BaCuenta_IDBaCuenta_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "BaCuenta_IDBaCuenta_seq" OWNED BY bacuenta.id;


--
-- TOC entry 176 (class 1259 OID 20564)
-- Dependencies: 7
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
-- TOC entry 3327 (class 0 OID 0)
-- Dependencies: 176
-- Name: TABLE bancos; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE bancos IS 'Tabla con los datos de los bancos que maneja el organismo';


--
-- TOC entry 3328 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN bancos.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN bancos.id IS 'Identificador unico de registro';


--
-- TOC entry 3329 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN bancos.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN bancos.nombre IS 'Nombre del banco';


--
-- TOC entry 3330 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN bancos.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN bancos.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3331 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN bancos.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN bancos.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 177 (class 1259 OID 20567)
-- Dependencies: 7 176
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
-- TOC entry 3332 (class 0 OID 0)
-- Dependencies: 177
-- Name: Bancos_IDBanco_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "Bancos_IDBanco_seq" OWNED BY bancos.id;


--
-- TOC entry 178 (class 1259 OID 20569)
-- Dependencies: 7
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
-- TOC entry 3333 (class 0 OID 0)
-- Dependencies: 178
-- Name: TABLE calpagod; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE calpagod IS 'Tabla con el detalle de los calendario de pagos';


--
-- TOC entry 3334 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN calpagod.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpagod.id IS 'Identificador unico del detalle de los calendarios de pagos';


--
-- TOC entry 3335 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN calpagod.calpagoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpagod.calpagoid IS 'Identificador del calendario de pago';


--
-- TOC entry 3336 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN calpagod.fechaini; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpagod.fechaini IS 'Fecha de inicio del periodo gravable';


--
-- TOC entry 3337 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN calpagod.fechafin; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpagod.fechafin IS 'Fecha final del periodo gravable';


--
-- TOC entry 3338 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN calpagod.fechalim; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpagod.fechalim IS 'Fecha limite de pago del periodo gravable';


--
-- TOC entry 3339 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN calpagod.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpagod.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3340 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN calpagod.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpagod.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 179 (class 1259 OID 20572)
-- Dependencies: 178 7
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
-- TOC entry 3341 (class 0 OID 0)
-- Dependencies: 179
-- Name: CalPagoD_IDCalPagoD_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "CalPagoD_IDCalPagoD_seq" OWNED BY calpagod.id;


--
-- TOC entry 180 (class 1259 OID 20574)
-- Dependencies: 2437 7
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
-- TOC entry 3342 (class 0 OID 0)
-- Dependencies: 180
-- Name: TABLE calpago; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE calpago IS 'Tabla con los calendarios de pagos de los diferentes tipos de contribuyentes por año';


--
-- TOC entry 3343 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN calpago.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpago.id IS 'Identificador del calendario de pagos';


--
-- TOC entry 3344 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN calpago.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpago.nombre IS 'Nombre del calendario';


--
-- TOC entry 3345 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN calpago.ano; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpago.ano IS 'Año vigencia del calendario';


--
-- TOC entry 3346 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN calpago.tipegravid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpago.tipegravid IS 'Identificador del tipo de periodo gravable';


--
-- TOC entry 3347 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN calpago.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpago.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3348 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN calpago.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpago.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 181 (class 1259 OID 20578)
-- Dependencies: 7 180
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
-- TOC entry 3349 (class 0 OID 0)
-- Dependencies: 181
-- Name: CalPagos_IDCalPago_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "CalPagos_IDCalPago_seq" OWNED BY calpago.id;


--
-- TOC entry 182 (class 1259 OID 20580)
-- Dependencies: 7
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
-- TOC entry 3350 (class 0 OID 0)
-- Dependencies: 182
-- Name: TABLE cargos; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE cargos IS 'Tabla con los distintos cargos de la organizacion';


--
-- TOC entry 3351 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN cargos.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN cargos.id IS 'Identificador unico del cargo';


--
-- TOC entry 3352 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN cargos.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN cargos.nombre IS 'Nombre del cargo';


--
-- TOC entry 3353 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN cargos.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN cargos.usuarioid IS 'Identificador del usuario que creo el registro o del ultimo en modificarlo';


--
-- TOC entry 3354 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN cargos.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN cargos.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 183 (class 1259 OID 20583)
-- Dependencies: 7 182
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
-- TOC entry 3355 (class 0 OID 0)
-- Dependencies: 183
-- Name: Cargos_IDCargo_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "Cargos_IDCargo_seq" OWNED BY cargos.id;


--
-- TOC entry 184 (class 1259 OID 20585)
-- Dependencies: 7
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
-- TOC entry 3356 (class 0 OID 0)
-- Dependencies: 184
-- Name: TABLE ciudades; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE ciudades IS 'Tabla con las ciudades por estado geografico';


--
-- TOC entry 3357 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN ciudades.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN ciudades.id IS 'Idenficador unico de la ciudad';


--
-- TOC entry 3358 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN ciudades.estadoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN ciudades.estadoid IS 'Identificador del estado';


--
-- TOC entry 3359 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN ciudades.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN ciudades.nombre IS 'Nombre de la ciudad';


--
-- TOC entry 3360 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN ciudades.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN ciudades.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3361 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN ciudades.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN ciudades.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 185 (class 1259 OID 20588)
-- Dependencies: 7 184
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
-- TOC entry 3362 (class 0 OID 0)
-- Dependencies: 185
-- Name: Ciudades_IDCiudad_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "Ciudades_IDCiudad_seq" OWNED BY ciudades.id;


--
-- TOC entry 186 (class 1259 OID 20590)
-- Dependencies: 7
-- Name: conusuco; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE conusuco (
    id integer NOT NULL,
    conusuid integer NOT NULL,
    contribuid integer NOT NULL
);


ALTER TABLE datos.conusuco OWNER TO postgres;

--
-- TOC entry 3363 (class 0 OID 0)
-- Dependencies: 186
-- Name: TABLE conusuco; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE conusuco IS 'Tabla con la relacion entre usuarios y a los contribuyentes que representan';


--
-- TOC entry 3364 (class 0 OID 0)
-- Dependencies: 186
-- Name: COLUMN conusuco.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuco.id IS 'Identificador unico de registro';


--
-- TOC entry 3365 (class 0 OID 0)
-- Dependencies: 186
-- Name: COLUMN conusuco.conusuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuco.conusuid IS 'Identificador del usuario';


--
-- TOC entry 3366 (class 0 OID 0)
-- Dependencies: 186
-- Name: COLUMN conusuco.contribuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuco.contribuid IS 'Identificador del contribuyente';


--
-- TOC entry 187 (class 1259 OID 20593)
-- Dependencies: 7 186
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
-- TOC entry 3367 (class 0 OID 0)
-- Dependencies: 187
-- Name: ConUsuCo_IDConUsuCo_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "ConUsuCo_IDConUsuCo_seq" OWNED BY conusuco.id;


--
-- TOC entry 188 (class 1259 OID 20595)
-- Dependencies: 2442 2443 2444 7
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
-- TOC entry 3368 (class 0 OID 0)
-- Dependencies: 188
-- Name: TABLE conusuti; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE conusuti IS 'Tabla con los tipos de usuarios de los contribuyentes';


--
-- TOC entry 3369 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN conusuti.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuti.id IS 'Identificador unico del tipo de usuario de contribuyentes';


--
-- TOC entry 3370 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN conusuti.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuti.nombre IS 'Nombre del tipo de usuario';


--
-- TOC entry 3371 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN conusuti.administra; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuti.administra IS 'Si el tipo de usuario (perfil) administra la cuenta del contribuyente. Crea usuarios, elimina usuarios';


--
-- TOC entry 3372 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN conusuti.liquida; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuti.liquida IS 'Si el tipo de usuario (perfil) liquida planillas de autoliquidacion en la cuenta del contribuyente.';


--
-- TOC entry 3373 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN conusuti.visualiza; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuti.visualiza IS 'Si el tipo de usuario (perfil) solo visualiza datos  de la cuenta del contribuyente.';


--
-- TOC entry 3374 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN conusuti.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuti.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3375 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN conusuti.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuti.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 189 (class 1259 OID 20601)
-- Dependencies: 7 188
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
-- TOC entry 3376 (class 0 OID 0)
-- Dependencies: 189
-- Name: ConUsuTi_IDConUsuTi_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "ConUsuTi_IDConUsuTi_seq" OWNED BY conusuti.id;


--
-- TOC entry 190 (class 1259 OID 20603)
-- Dependencies: 2446 2448 7
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
-- TOC entry 3377 (class 0 OID 0)
-- Dependencies: 190
-- Name: TABLE conusuto; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE conusuto IS 'Tabla con los Tokens activos por usuario, es Tokens se utilizaran para validad la creacion de usuarios, recuperacion de contraseñas, etc.';


--
-- TOC entry 3378 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN conusuto.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuto.id IS 'Idendificador unico del token';


--
-- TOC entry 3379 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN conusuto.token; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuto.token IS 'Token generado';


--
-- TOC entry 3380 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN conusuto.conusuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuto.conusuid IS 'Identificador del usuario dueño del token';


--
-- TOC entry 3381 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN conusuto.fechacrea; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuto.fechacrea IS 'Fecha hora de creacion del token';


--
-- TOC entry 3382 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN conusuto.fechacadu; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuto.fechacadu IS 'Fecha hora de caducidad del token';


--
-- TOC entry 3383 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN conusuto.usado; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuto.usado IS 'Si el token fue usado por el usuario o no';


--
-- TOC entry 191 (class 1259 OID 20610)
-- Dependencies: 7 190
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
-- TOC entry 3384 (class 0 OID 0)
-- Dependencies: 191
-- Name: ConUsuTo_IDConUsuTo_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "ConUsuTo_IDConUsuTo_seq" OWNED BY conusuto.id;


--
-- TOC entry 192 (class 1259 OID 20612)
-- Dependencies: 2450 2451 2452 7
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
    fecha_registro date DEFAULT '2013-03-14'::date NOT NULL
);


ALTER TABLE datos.conusu OWNER TO postgres;

--
-- TOC entry 3385 (class 0 OID 0)
-- Dependencies: 192
-- Name: TABLE conusu; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE conusu IS 'Tabla con los datos de los usuarios por contribuyente';


--
-- TOC entry 3386 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.id IS 'Identificador del usuario del contribuyente';


--
-- TOC entry 3387 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.login; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.login IS 'Login de usuario. Puede usar su correo para hacer login';


--
-- TOC entry 3388 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.password; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.password IS 'Hash del pasword para hacer login';


--
-- TOC entry 3389 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.nombre IS 'Nombre del usuario. Este es el nombre que se muestra';


--
-- TOC entry 3390 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.inactivo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.inactivo IS 'Si el usuario esta inactivo o no. False=No / True=Si';


--
-- TOC entry 3391 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.conusutiid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.conusutiid IS 'Identificador del tipo de usuario de contribuyentes';


--
-- TOC entry 3392 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.email; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.email IS 'Direccion de email del usuario, se utilizara para validar la cuenta';


--
-- TOC entry 3393 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.pregsecrid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.pregsecrid IS 'Identificador de la pregunta secreta seleccionada por en usuario';


--
-- TOC entry 3394 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.respuesta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.respuesta IS 'Hash con la respuesta a la pregunta secreta';


--
-- TOC entry 3395 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.ultlogin; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.ultlogin IS 'Fecha y hora de la ultima vez que el usuario hizo login';


--
-- TOC entry 3396 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3397 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 193 (class 1259 OID 20619)
-- Dependencies: 7 192
-- Name: ConUsu_IDConUsu_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE "ConUsu_IDConUsu_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos."ConUsu_IDConUsu_seq" OWNER TO postgres;

--
-- TOC entry 3398 (class 0 OID 0)
-- Dependencies: 193
-- Name: ConUsu_IDConUsu_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "ConUsu_IDConUsu_seq" OWNED BY conusu.id;


--
-- TOC entry 194 (class 1259 OID 20621)
-- Dependencies: 2453 2454 2455 2456 7
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
-- TOC entry 3399 (class 0 OID 0)
-- Dependencies: 194
-- Name: TABLE contribu; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE contribu IS 'Tabla con los datos de los contribuyentes de la institución';


--
-- TOC entry 3400 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.id IS 'Identificador unico del contribuyente';


--
-- TOC entry 3401 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.razonsocia; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.razonsocia IS 'Razon social del contribuyente';


--
-- TOC entry 3402 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.dencomerci; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.dencomerci IS 'Denominacion comercial del contribuyente';


--
-- TOC entry 3403 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.actieconid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.actieconid IS 'Identificador de la actividad economica';


--
-- TOC entry 3404 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.rif; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.rif IS 'Rif del contribuyente';


--
-- TOC entry 3405 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.numregcine; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.numregcine IS 'Numero de registro cinematografico';


--
-- TOC entry 3406 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.domfiscal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.domfiscal IS 'Domicilio fiscal del contribuyente';


--
-- TOC entry 3407 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.estadoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.estadoid IS 'Identicador del estado geografico';


--
-- TOC entry 3408 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.ciudadid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.ciudadid IS 'Identificador de la ciudad';


--
-- TOC entry 3409 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.zonapostal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.zonapostal IS 'Zona postal del contribuyente';


--
-- TOC entry 3410 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.telef1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.telef1 IS 'Telefono 1 del contribuyente';


--
-- TOC entry 3411 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.telef2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.telef2 IS 'Telefono 2 del contribuyente';


--
-- TOC entry 3412 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.telef3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.telef3 IS 'Telefono 3 del contribuyente';


--
-- TOC entry 3413 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.fax1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.fax1 IS 'Fax 1 del contribuyente';


--
-- TOC entry 3414 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.fax2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.fax2 IS 'Fax 2 del contribuyente';


--
-- TOC entry 3415 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.email; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.email IS 'Direccion de email de contribuyente';


--
-- TOC entry 3416 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.pinbb; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.pinbb IS 'Pin de BlackBerry';


--
-- TOC entry 3417 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.skype; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.skype IS 'Dirección de skype';


--
-- TOC entry 3418 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.twitter; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.twitter IS 'Direccion de twitter';


--
-- TOC entry 3419 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.facebook; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.facebook IS 'Direccion de facebook';


--
-- TOC entry 3420 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.nuacciones; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.nuacciones IS 'Numero de acciones del contribuyente segun inforacion del registro mercantil';


--
-- TOC entry 3421 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.valaccion; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.valaccion IS 'Valor nominal por accion segun registro mercantil';


--
-- TOC entry 3422 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.capitalsus; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.capitalsus IS 'Capital suscrito segun registro mercantil';


--
-- TOC entry 3423 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.capitalpag; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.capitalpag IS 'Capital pagado segun registro mercantil';


--
-- TOC entry 3424 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.regmerofc; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.regmerofc IS 'Oficina de registro mercantil en donde se registro la empresa';


--
-- TOC entry 3425 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.rmnumero; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.rmnumero IS 'Numero de registro del documento de registro mercantil';


--
-- TOC entry 3426 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.rmfolio; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.rmfolio IS 'Numero de folio del documento de registro mercantil';


--
-- TOC entry 3427 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.rmtomo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.rmtomo IS 'Numero de folio del documento de registro mercantil';


--
-- TOC entry 3428 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.rmfechapro; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.rmfechapro IS 'Fecha de protocololizacion del registro del documento de registro mercantil';


--
-- TOC entry 3429 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.rmncontrol; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.rmncontrol IS 'Numero de control del documento de registro mercantil';


--
-- TOC entry 3430 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.rmobjeto; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.rmobjeto IS 'Objeto de la empresa segun registro mercantil';


--
-- TOC entry 3431 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.domcomer; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.domcomer IS 'domicilio comercial';


--
-- TOC entry 3432 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.cextra1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.cextra1 IS 'Campo extra 1';


--
-- TOC entry 3433 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.cextra2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.cextra2 IS 'Campo extra 2';


--
-- TOC entry 3434 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.cextra3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.cextra3 IS 'Campo extra 3';


--
-- TOC entry 3435 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.cextra4; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.cextra4 IS 'Campo extra 4';


--
-- TOC entry 3436 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.cextra5; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.cextra5 IS 'Campo extra 5';


--
-- TOC entry 3437 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.usuarioid IS 'identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3438 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 195 (class 1259 OID 20631)
-- Dependencies: 7 194
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
-- TOC entry 3439 (class 0 OID 0)
-- Dependencies: 195
-- Name: Contribu_IDContribu_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "Contribu_IDContribu_seq" OWNED BY contribu.id;


--
-- TOC entry 196 (class 1259 OID 20633)
-- Dependencies: 2458 2459 2460 2461 2462 2463 2464 2465 7
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
-- TOC entry 3440 (class 0 OID 0)
-- Dependencies: 196
-- Name: TABLE declara_viejo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE declara_viejo IS 'Planilla de declaracion de impuestos';


--
-- TOC entry 3441 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.id IS 'Identificador unico de la declaracion de impuestos';


--
-- TOC entry 3442 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.nudeclara; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.nudeclara IS 'Numero de planilla de declaracion de impuesto';


--
-- TOC entry 3443 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.nudeposito; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.nudeposito IS 'Numero de deposito bancario generado por el sistema';


--
-- TOC entry 3444 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.tdeclaraid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.tdeclaraid IS 'Identificador del tipo de declaracion';


--
-- TOC entry 3445 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.fechaelab; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.fechaelab IS 'Fecha de elaboracion de la planilla de pago de impuestos';


--
-- TOC entry 3446 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.fechaini; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.fechaini IS 'Fecha de inicio del periodo gravable';


--
-- TOC entry 3447 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.fechafin; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.fechafin IS 'Fecha final del periodo gravable';


--
-- TOC entry 3448 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.replegalid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.replegalid IS 'Identificador del representante legal que aparecera en la planilla y firmara la misma';


--
-- TOC entry 3449 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.baseimpo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.baseimpo IS 'Base imponible';


--
-- TOC entry 3450 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.alicuota; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.alicuota IS 'Alicuota impositiva aplicada a la declaracion de impuesto';


--
-- TOC entry 3451 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.exonera; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.exonera IS 'Exoneracion o rebaja';


--
-- TOC entry 3452 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.nuactoexon; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.nuactoexon IS 'Numero de acto en donde se establece la exoneracion o rebaja';


--
-- TOC entry 3453 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.credfiscal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.credfiscal IS 'Credito fiscal';


--
-- TOC entry 3454 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.contribant; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.contribant IS 'Monto de la contribucion pagada en periodos anteriores';


--
-- TOC entry 3455 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.plasustid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.plasustid IS 'Identificador de la planilla que se esta sustituyendo en caso de ser una declaracion sustitutiva';


--
-- TOC entry 3456 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.nuresactfi; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.nuresactfi IS 'Numero de resolucion o numero de acta fiscal';


--
-- TOC entry 3457 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.fechanoti; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.fechanoti IS 'Fecha de notificacion';


--
-- TOC entry 3458 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.intemora; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.intemora IS 'Intereses moratorios';


--
-- TOC entry 3459 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.reparofis; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.reparofis IS 'Reparo fiscal';


--
-- TOC entry 3460 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.multa; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.multa IS 'Multa aplicada';


--
-- TOC entry 3461 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.montopagar; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.montopagar IS 'Monto a pagar';


--
-- TOC entry 3462 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.fechapago; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.fechapago IS 'Fecha de pago en el banco. Se llena este campo cuando se concilian los pagos';


--
-- TOC entry 3463 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.fechaconci; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.fechaconci IS 'Fecha hora de la conciliacion contra los depositos del banco';


--
-- TOC entry 3464 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.asientoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.asientoid IS 'Identificador del asiento contable en donde se registro la informacion del pago';


--
-- TOC entry 3465 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.usuarioid IS 'Identificador del usuario que concilio el pago de la declaracion. ';


--
-- TOC entry 3466 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 197 (class 1259 OID 20645)
-- Dependencies: 7 196
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
-- TOC entry 3467 (class 0 OID 0)
-- Dependencies: 197
-- Name: Declara_IDDeclara_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "Declara_IDDeclara_seq" OWNED BY declara_viejo.id;


--
-- TOC entry 198 (class 1259 OID 20647)
-- Dependencies: 7
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
-- TOC entry 3468 (class 0 OID 0)
-- Dependencies: 198
-- Name: TABLE departam; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE departam IS 'Tabla con los departamentos / gerencia de la organizacion';


--
-- TOC entry 3469 (class 0 OID 0)
-- Dependencies: 198
-- Name: COLUMN departam.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN departam.id IS 'Identificador unico del departamento';


--
-- TOC entry 3470 (class 0 OID 0)
-- Dependencies: 198
-- Name: COLUMN departam.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN departam.nombre IS 'Nombre del departamento o gerencia';


--
-- TOC entry 3471 (class 0 OID 0)
-- Dependencies: 198
-- Name: COLUMN departam.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN departam.usuarioid IS 'Identificador del usuario que creo el registro o del ultimo en modificarlo';


--
-- TOC entry 3472 (class 0 OID 0)
-- Dependencies: 198
-- Name: COLUMN departam.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN departam.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 199 (class 1259 OID 20650)
-- Dependencies: 198 7
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
-- TOC entry 3473 (class 0 OID 0)
-- Dependencies: 199
-- Name: Departam_IDDepartam_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "Departam_IDDepartam_seq" OWNED BY departam.id;


--
-- TOC entry 200 (class 1259 OID 20652)
-- Dependencies: 2468 7
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
-- TOC entry 3474 (class 0 OID 0)
-- Dependencies: 200
-- Name: TABLE entidadd; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE entidadd IS 'Tabla con el detalle de las entidades. Acciones y procesos a verificar acceso por entidad';


--
-- TOC entry 3475 (class 0 OID 0)
-- Dependencies: 200
-- Name: COLUMN entidadd.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN entidadd.id IS 'Identificador unico del detalle de la entidad';


--
-- TOC entry 3476 (class 0 OID 0)
-- Dependencies: 200
-- Name: COLUMN entidadd.entidadid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN entidadd.entidadid IS 'Identificador de la entidad a la que pertenece la accion o preceso';


--
-- TOC entry 3477 (class 0 OID 0)
-- Dependencies: 200
-- Name: COLUMN entidadd.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN entidadd.nombre IS 'Nombre de la accion o proceso a mostrar en el arbol de permisos disponibles';


--
-- TOC entry 3478 (class 0 OID 0)
-- Dependencies: 200
-- Name: COLUMN entidadd.accion; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN entidadd.accion IS 'Nombre interno de la accion o proceso';


--
-- TOC entry 3479 (class 0 OID 0)
-- Dependencies: 200
-- Name: COLUMN entidadd.orden; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN entidadd.orden IS 'Orden en que apareceran las acciones y/o procesos dentro del arbol de una entidad';


--
-- TOC entry 201 (class 1259 OID 20656)
-- Dependencies: 7 200
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
-- TOC entry 3480 (class 0 OID 0)
-- Dependencies: 201
-- Name: EntidadD_IDEntidadD_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "EntidadD_IDEntidadD_seq" OWNED BY entidadd.id;


--
-- TOC entry 202 (class 1259 OID 20658)
-- Dependencies: 2470 7
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
-- TOC entry 3481 (class 0 OID 0)
-- Dependencies: 202
-- Name: TABLE entidad; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE entidad IS 'Tabla con las entidades del sistema';


--
-- TOC entry 3482 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN entidad.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN entidad.id IS 'Identificador de la entidad';


--
-- TOC entry 3483 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN entidad.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN entidad.nombre IS 'Nombre de la entidad a mostrar en el arbol de permisos disponibles';


--
-- TOC entry 3484 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN entidad.entidad; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN entidad.entidad IS 'Nombre interno de la entidad';


--
-- TOC entry 3485 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN entidad.orden; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN entidad.orden IS 'Orden en la que apareceran la entidades en el arbol de permisos de usuarios';


--
-- TOC entry 203 (class 1259 OID 20662)
-- Dependencies: 7 202
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
-- TOC entry 3486 (class 0 OID 0)
-- Dependencies: 203
-- Name: Entidad_IDEntidad_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "Entidad_IDEntidad_seq" OWNED BY entidad.id;


--
-- TOC entry 204 (class 1259 OID 20664)
-- Dependencies: 7
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
-- TOC entry 3487 (class 0 OID 0)
-- Dependencies: 204
-- Name: TABLE estados; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE estados IS 'Tabla con los estados geográficos';


--
-- TOC entry 3488 (class 0 OID 0)
-- Dependencies: 204
-- Name: COLUMN estados.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN estados.id IS 'Identificador unico del estado';


--
-- TOC entry 3489 (class 0 OID 0)
-- Dependencies: 204
-- Name: COLUMN estados.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN estados.nombre IS 'Nombre del estado geografico';


--
-- TOC entry 3490 (class 0 OID 0)
-- Dependencies: 204
-- Name: COLUMN estados.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN estados.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3491 (class 0 OID 0)
-- Dependencies: 204
-- Name: COLUMN estados.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN estados.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 205 (class 1259 OID 20667)
-- Dependencies: 7 204
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
-- TOC entry 3492 (class 0 OID 0)
-- Dependencies: 205
-- Name: Estados_IDEstado_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "Estados_IDEstado_seq" OWNED BY estados.id;


--
-- TOC entry 206 (class 1259 OID 20669)
-- Dependencies: 7
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
-- TOC entry 3493 (class 0 OID 0)
-- Dependencies: 206
-- Name: TABLE perusud; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE perusud IS 'Tabla con los datos del detalle de los perfiles de usuario. Detalles de entidades habilitadas para el perfil seleccionado';


--
-- TOC entry 3494 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN perusud.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN perusud.id IS 'Identificador unico del detalle de perfil de usuario';


--
-- TOC entry 3495 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN perusud.perusuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN perusud.perusuid IS 'Identificador del perfil al cual pertenece el detalle (accion o proceso permisado)';


--
-- TOC entry 3496 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN perusud.entidaddid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN perusud.entidaddid IS 'Identificador de la accion o proceso permisado (detalles de las entidades)';


--
-- TOC entry 3497 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN perusud.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN perusud.usuarioid IS 'Identificador del usuario que creo el registro o el ultimo en modificarlo';


--
-- TOC entry 3498 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN perusud.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN perusud.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 207 (class 1259 OID 20672)
-- Dependencies: 7 206
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
-- TOC entry 3499 (class 0 OID 0)
-- Dependencies: 207
-- Name: PerUsuD_IDPerUsuD_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "PerUsuD_IDPerUsuD_seq" OWNED BY perusud.id;


--
-- TOC entry 208 (class 1259 OID 20674)
-- Dependencies: 2474 7
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
-- TOC entry 3500 (class 0 OID 0)
-- Dependencies: 208
-- Name: TABLE perusu; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE perusu IS 'Tabla con los perfiles de usuarios';


--
-- TOC entry 3501 (class 0 OID 0)
-- Dependencies: 208
-- Name: COLUMN perusu.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN perusu.id IS 'Identificador del perfl de usuario';


--
-- TOC entry 3502 (class 0 OID 0)
-- Dependencies: 208
-- Name: COLUMN perusu.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN perusu.nombre IS 'Nombre del perfil de usuario';


--
-- TOC entry 3503 (class 0 OID 0)
-- Dependencies: 208
-- Name: COLUMN perusu.inactivo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN perusu.inactivo IS 'Si el pelfil de usuario esta Inactivo o no';


--
-- TOC entry 3504 (class 0 OID 0)
-- Dependencies: 208
-- Name: COLUMN perusu.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN perusu.usuarioid IS 'Identificador de usuario que creo o el ultimo que actualizo el registro';


--
-- TOC entry 3505 (class 0 OID 0)
-- Dependencies: 208
-- Name: COLUMN perusu.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN perusu.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 209 (class 1259 OID 20678)
-- Dependencies: 7 208
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
-- TOC entry 3506 (class 0 OID 0)
-- Dependencies: 209
-- Name: PerUsu_IDPerUsu_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "PerUsu_IDPerUsu_seq" OWNED BY perusu.id;


--
-- TOC entry 210 (class 1259 OID 20680)
-- Dependencies: 7
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
-- TOC entry 3507 (class 0 OID 0)
-- Dependencies: 210
-- Name: TABLE pregsecr; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE pregsecr IS 'Tablas con las preguntas secretas validas para la recuperacion de contraseñas';


--
-- TOC entry 3508 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN pregsecr.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN pregsecr.id IS 'Identificador unico de la pregunta secreta';


--
-- TOC entry 3509 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN pregsecr.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN pregsecr.nombre IS 'Texto de la pregunta secreta';


--
-- TOC entry 3510 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN pregsecr.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN pregsecr.usuarioid IS 'Identificado del ultimo usuario que creo o actualizo el registro';


--
-- TOC entry 3511 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN pregsecr.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN pregsecr.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 211 (class 1259 OID 20683)
-- Dependencies: 7 210
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
-- TOC entry 3512 (class 0 OID 0)
-- Dependencies: 211
-- Name: PregSecr_IDPregSecr_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "PregSecr_IDPregSecr_seq" OWNED BY pregsecr.id;


--
-- TOC entry 212 (class 1259 OID 20685)
-- Dependencies: 7
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
-- TOC entry 3513 (class 0 OID 0)
-- Dependencies: 212
-- Name: TABLE replegal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE replegal IS 'Tabla con los datos de los Accionistas de los contribuyentes';


--
-- TOC entry 3514 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.id IS 'Identificador unico del representante legal';


--
-- TOC entry 3515 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.contribuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.contribuid IS 'Identificador del contribuyente';


--
-- TOC entry 3516 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.nombre IS 'Nombre del representante legal';


--
-- TOC entry 3517 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.apellido; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.apellido IS 'Apellidos del representante legal';


--
-- TOC entry 3518 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.ci; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.ci IS 'Cedula de identidad, numero de pasaporte';


--
-- TOC entry 3519 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.domfiscal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.domfiscal IS 'Domicilio fiscal del representante legal';


--
-- TOC entry 3520 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.estadoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.estadoid IS 'Identificador del estado geografico';


--
-- TOC entry 3521 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.ciudadid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.ciudadid IS 'Identificador de la ciudad';


--
-- TOC entry 3522 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.zonaposta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.zonaposta IS 'Zona postal';


--
-- TOC entry 3523 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.telefhab; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.telefhab IS 'Telefono de habitacion del representante legal';


--
-- TOC entry 3524 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.telefofc; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.telefofc IS 'Telefono de oficina del representante legal';


--
-- TOC entry 3525 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.fax; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.fax IS 'Fax del representante legal';


--
-- TOC entry 3526 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.email; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.email IS 'Direccion de email del contribuyente';


--
-- TOC entry 3527 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.pinbb; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.pinbb IS 'Pin de BlackBerry';


--
-- TOC entry 3528 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.skype; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.skype IS 'Direccion de skype del representante legal';


--
-- TOC entry 3529 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.cextra1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.cextra1 IS 'Campo extra 1';


--
-- TOC entry 3530 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.cextra2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.cextra2 IS 'Campo extra 2';


--
-- TOC entry 3531 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.cextra3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.cextra3 IS 'Campo extra 3';


--
-- TOC entry 3532 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.cextra4; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.cextra4 IS 'Campo extra 4';


--
-- TOC entry 3533 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.cextra5; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.cextra5 IS 'Campo extra 5';


--
-- TOC entry 3534 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3535 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 213 (class 1259 OID 20691)
-- Dependencies: 7 212
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
-- TOC entry 3536 (class 0 OID 0)
-- Dependencies: 213
-- Name: RepLegal_IDRepLegal_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "RepLegal_IDRepLegal_seq" OWNED BY replegal.id;


--
-- TOC entry 214 (class 1259 OID 20693)
-- Dependencies: 7
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
-- TOC entry 3537 (class 0 OID 0)
-- Dependencies: 214
-- Name: TABLE tdeclara; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE tdeclara IS 'Tipo de declaracion de impuestos';


--
-- TOC entry 3538 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN tdeclara.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tdeclara.id IS 'Identificador unico de registro';


--
-- TOC entry 3539 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN tdeclara.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tdeclara.nombre IS 'Nombre del tipo de declaracion de impuesto. Ejm. Autoliquidacion, Sustitutiva, etc';


--
-- TOC entry 3540 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN tdeclara.tipo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tdeclara.tipo IS 'Tipo de declaracion a efectuar. Utilizamos este campo para activar/desactivar la seccion correspondiente a los datos de la liquidacion en la planilla de pago de impuestos.
0 = Autoliquidación / Sustitutiva
1 = Multa por pago extemporaneo / Reparo fiscal
2 = Multa
3 = Intereses Moratorios';


--
-- TOC entry 3541 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN tdeclara.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tdeclara.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro.';


--
-- TOC entry 3542 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN tdeclara.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tdeclara.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 215 (class 1259 OID 20696)
-- Dependencies: 214 7
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
-- TOC entry 3543 (class 0 OID 0)
-- Dependencies: 215
-- Name: TDeclara_IDTDeclara_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "TDeclara_IDTDeclara_seq" OWNED BY tdeclara.id;


--
-- TOC entry 216 (class 1259 OID 20698)
-- Dependencies: 2479 2480 7
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
-- TOC entry 3544 (class 0 OID 0)
-- Dependencies: 216
-- Name: TABLE tipegrav; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE tipegrav IS 'Tabla con los tipos de períodos gravables';


--
-- TOC entry 3545 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN tipegrav.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipegrav.id IS 'Identificador del tipo de periodo gravable';


--
-- TOC entry 3546 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN tipegrav.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipegrav.nombre IS 'Nombre del tipo de período gravable. Ejm. Mensual, trimestral, anual';


--
-- TOC entry 3547 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN tipegrav.tipe; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipegrav.tipe IS 'Tipo de periodo. 0=Mensual / 1=Trimestral / 2=Anual';


--
-- TOC entry 3548 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN tipegrav.peano; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipegrav.peano IS 'Numero de periodos gravables en año fiscal';


--
-- TOC entry 3549 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN tipegrav.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipegrav.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3550 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN tipegrav.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipegrav.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 217 (class 1259 OID 20703)
-- Dependencies: 216 7
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
-- TOC entry 3551 (class 0 OID 0)
-- Dependencies: 217
-- Name: TiPeGrav_IDTiPeGrav_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "TiPeGrav_IDTiPeGrav_seq" OWNED BY tipegrav.id;


--
-- TOC entry 218 (class 1259 OID 20705)
-- Dependencies: 7
-- Name: tipocont; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE tipocont (
    id integer NOT NULL,
    nombre character varying(200) NOT NULL,
    tipegravid integer NOT NULL,
    usuarioid integer NOT NULL,
    ip character varying(15) NOT NULL,
    numero_articulo integer
);


ALTER TABLE datos.tipocont OWNER TO postgres;

--
-- TOC entry 3552 (class 0 OID 0)
-- Dependencies: 218
-- Name: TABLE tipocont; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE tipocont IS 'Tabla con los tipos de contribuyentes';


--
-- TOC entry 3553 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN tipocont.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipocont.id IS 'Identificador unico del tipo de contribuyente';


--
-- TOC entry 3554 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN tipocont.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipocont.nombre IS 'Nombre o descripción del tipo de contribuyente. Ejm Exibidores cinematográficos';


--
-- TOC entry 3555 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN tipocont.tipegravid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipocont.tipegravid IS 'Identificador del tipo de periodo gravable';


--
-- TOC entry 3556 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN tipocont.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipocont.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3557 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN tipocont.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipocont.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 219 (class 1259 OID 20708)
-- Dependencies: 7 218
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
-- TOC entry 3558 (class 0 OID 0)
-- Dependencies: 219
-- Name: TipoCont_IDTipoCont_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "TipoCont_IDTipoCont_seq" OWNED BY tipocont.id;


--
-- TOC entry 220 (class 1259 OID 20710)
-- Dependencies: 2483 7
-- Name: undtrib; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE undtrib (
    id integer NOT NULL,
    fecha date NOT NULL,
    valor numeric(18,2) DEFAULT 0 NOT NULL,
    usuarioid integer NOT NULL,
    ip character varying(15) NOT NULL
);


ALTER TABLE datos.undtrib OWNER TO postgres;

--
-- TOC entry 3559 (class 0 OID 0)
-- Dependencies: 220
-- Name: TABLE undtrib; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE undtrib IS 'Tabla con los valores de conversion de las unidades tributarias';


--
-- TOC entry 3560 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN undtrib.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN undtrib.id IS 'Identificador unico de registro';


--
-- TOC entry 3561 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN undtrib.fecha; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN undtrib.fecha IS 'Fecha a partir de la cual esta vigente el valor de la unidad tributaria';


--
-- TOC entry 3562 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN undtrib.valor; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN undtrib.valor IS 'Valor en Bs de una unidad tributaria';


--
-- TOC entry 3563 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN undtrib.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN undtrib.usuarioid IS 'Identificador del ultimo usuario que creo o modifico un registro';


--
-- TOC entry 3564 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN undtrib.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN undtrib.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 221 (class 1259 OID 20714)
-- Dependencies: 220 7
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
-- TOC entry 3565 (class 0 OID 0)
-- Dependencies: 221
-- Name: UndTrib_IDUndTrib_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "UndTrib_IDUndTrib_seq" OWNED BY undtrib.id;


--
-- TOC entry 222 (class 1259 OID 20716)
-- Dependencies: 2485 7
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
-- TOC entry 3566 (class 0 OID 0)
-- Dependencies: 222
-- Name: TABLE usfonpto; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE usfonpto IS 'Tabla con los Tokens activos por usuario Fonprocine, es Tokens se utilizaran para validad la creacion de usuarios, recuperacion de contraseñas, etc.';


--
-- TOC entry 3567 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN usfonpto.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpto.id IS 'Identificador unico del Token';


--
-- TOC entry 3568 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN usfonpto.token; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpto.token IS 'Token generado';


--
-- TOC entry 3569 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN usfonpto.usfonproid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpto.usfonproid IS 'Identificador del usuario de fonprocine';


--
-- TOC entry 3570 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN usfonpto.fechacrea; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpto.fechacrea IS 'Fecha hora creacion del token';


--
-- TOC entry 3571 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN usfonpto.fechacadu; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpto.fechacadu IS 'Fecha hora caducidad del token';


--
-- TOC entry 3572 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN usfonpto.usado; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpto.usado IS 'Si el token fue usuario por el usuario o no';


--
-- TOC entry 223 (class 1259 OID 20723)
-- Dependencies: 7 222
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
-- TOC entry 3573 (class 0 OID 0)
-- Dependencies: 223
-- Name: UsFonpTo_IDUsFonpTo_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "UsFonpTo_IDUsFonpTo_seq" OWNED BY usfonpto.id;


--
-- TOC entry 224 (class 1259 OID 20725)
-- Dependencies: 2487 7
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
    respuesta character varying(100) NOT NULL,
    perusuid integer,
    ultlogin timestamp without time zone,
    usuarioid integer,
    ip character varying(15) NOT NULL,
    cedula character varying(15)
);


ALTER TABLE datos.usfonpro OWNER TO postgres;

--
-- TOC entry 3574 (class 0 OID 0)
-- Dependencies: 224
-- Name: TABLE usfonpro; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE usfonpro IS 'Tabla con los datos de los usuarios de la organizacion';


--
-- TOC entry 3575 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.id IS 'Identificador unico de usuario';


--
-- TOC entry 3576 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.login; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.login IS 'Login de usuario';


--
-- TOC entry 3577 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.password; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.password IS 'Passwrod de usuario';


--
-- TOC entry 3578 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.nombre IS 'Nombre del usuario';


--
-- TOC entry 3579 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.email; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.email IS 'Email del usuario';


--
-- TOC entry 3580 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.telefofc; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.telefofc IS 'Telefono de oficina';


--
-- TOC entry 3581 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.extension; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.extension IS 'Extension telefonica';


--
-- TOC entry 3582 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.departamid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.departamid IS 'Identificador del departamento al que pertenece el usuario';


--
-- TOC entry 3583 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.cargoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.cargoid IS 'Identificador del cargo del usuario';


--
-- TOC entry 3584 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.inactivo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.inactivo IS 'Si el usuario esta inactivo o no';


--
-- TOC entry 3585 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.pregsecrid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.pregsecrid IS 'Identificador de la pregunta secreta';


--
-- TOC entry 3586 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.respuesta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.respuesta IS 'Hash de la respuesta a la pregunta secreta';


--
-- TOC entry 3587 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.perusuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.perusuid IS 'Identificador del perfil de usuario';


--
-- TOC entry 3588 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.ultlogin; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.ultlogin IS 'Fecha hora del login del usuario al sistema';


--
-- TOC entry 3589 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.usuarioid IS 'Identificador del usuario que creo el registro o del ultimo que lo modifico';


--
-- TOC entry 3590 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 225 (class 1259 OID 20729)
-- Dependencies: 224 7
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
-- TOC entry 3591 (class 0 OID 0)
-- Dependencies: 225
-- Name: Usuarios_IDUsuario_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "Usuarios_IDUsuario_seq" OWNED BY usfonpro.id;


--
-- TOC entry 226 (class 1259 OID 20731)
-- Dependencies: 2489 2490 2491 7
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
    valaccion numeric(18,2) DEFAULT 0 NOT NULL,
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
-- TOC entry 3592 (class 0 OID 0)
-- Dependencies: 226
-- Name: TABLE accionis; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE accionis IS 'Tabla con los datos de los Accionistas de los contribuyentes';


--
-- TOC entry 3593 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.id IS 'Identificador unico del accionista';


--
-- TOC entry 3594 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.contribuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.contribuid IS 'Identificador del contribuyente';


--
-- TOC entry 3595 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.nombre IS 'Nombre del accionista';


--
-- TOC entry 3596 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.apellido; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.apellido IS 'Apellidos del accionista';


--
-- TOC entry 3597 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.ci; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.ci IS 'Cedula de identidad, numero de pasaporte';


--
-- TOC entry 3598 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.domfiscal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.domfiscal IS 'Domicilio fiscal del accionista';


--
-- TOC entry 3599 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.nuacciones; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.nuacciones IS 'Numero de acciones';


--
-- TOC entry 3600 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.valaccion; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.valaccion IS 'Valor nominal de las acciones';


--
-- TOC entry 3601 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.cextra1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.cextra1 IS 'Campo extra 1';


--
-- TOC entry 3602 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.cextra2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.cextra2 IS 'Campo extra 2';


--
-- TOC entry 3603 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.cextra3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.cextra3 IS 'Campo extra 3';


--
-- TOC entry 3604 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.cextra4; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.cextra4 IS 'Campo extra 4';


--
-- TOC entry 3605 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.cextra5; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.cextra5 IS 'Campo extra 5';


--
-- TOC entry 3606 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3607 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 227 (class 1259 OID 20740)
-- Dependencies: 2492 2493 2494 2495 2496 2497 2498 2499 7
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
-- TOC entry 3608 (class 0 OID 0)
-- Dependencies: 227
-- Name: TABLE asiento; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE asiento IS 'Tabla con los datos cabecera de los asiento contable';


--
-- TOC entry 3609 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN asiento.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.id IS 'Identificador unico de registro';


--
-- TOC entry 3610 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN asiento.nuasiento; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.nuasiento IS 'Numero de asiento. Empieza en uno al comienzo de cada mes.

Este valor de este campo lo asigna la base de datos';


--
-- TOC entry 3611 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN asiento.fecha; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.fecha IS 'Fecha del asiento';


--
-- TOC entry 3612 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN asiento.mes; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.mes IS 'Mes del asiento. Lo utilizamos para evitar que se utilice un numero de asiento repetido para un mes/año.

Este valor de este campo lo asigna la base de datos';


--
-- TOC entry 3613 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN asiento.ano; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.ano IS 'Año del asiento. Lo utilizamos para evitar que se utilice un numero de asiento repetido para un mes/año.

Este valor de este campo lo asigna la base de datos';


--
-- TOC entry 3614 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN asiento.debe; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.debe IS 'Sumatoria del debe del asiento.

Este valor de este campo lo asigna la base de datos';


--
-- TOC entry 3615 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN asiento.haber; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.haber IS 'Sumatoria del debe del asiento.

Este valor de este campo lo asigna la base de datos';


--
-- TOC entry 3616 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN asiento.saldo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.saldo IS 'Saldo del asiento.

Este valor de este campo lo asigna la base de datos.';


--
-- TOC entry 3617 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN asiento.comentar; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.comentar IS 'Comentario u observaciones del asiento';


--
-- TOC entry 3618 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN asiento.cerrado; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.cerrado IS 'Si el asiento esta cerrado o no. Solo se pueden cerrar asientos que el saldo sea 0. Un asiento cerrado no puede ser modificado';


--
-- TOC entry 3619 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN asiento.uscierreid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.uscierreid IS 'Identificador del usuario que cerro el asiento';


--
-- TOC entry 3620 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN asiento.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.usuarioid IS 'Identificador del ultimo usuario en crear o modificar el registro';


--
-- TOC entry 3621 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN asiento.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 228 (class 1259 OID 20754)
-- Dependencies: 7
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
-- TOC entry 3622 (class 0 OID 0)
-- Dependencies: 228
-- Name: TABLE asientom; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE asientom IS 'Tabla con los asientos modelos a utilizar';


--
-- TOC entry 3623 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN asientom.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientom.id IS 'Identificador unico de registro';


--
-- TOC entry 3624 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN asientom.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientom.nombre IS 'nombre del asiento modelo';


--
-- TOC entry 3625 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN asientom.comentar; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientom.comentar IS 'Comentarios u observaciones';


--
-- TOC entry 3626 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN asientom.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientom.usuarioid IS 'Identificador del usuario que creo o el ultimo en modificar el registro';


--
-- TOC entry 3627 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN asientom.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientom.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 229 (class 1259 OID 20760)
-- Dependencies: 228 7
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
-- TOC entry 3628 (class 0 OID 0)
-- Dependencies: 229
-- Name: asientom_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE asientom_id_seq OWNED BY asientom.id;


--
-- TOC entry 230 (class 1259 OID 20762)
-- Dependencies: 2501 7
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
-- TOC entry 3629 (class 0 OID 0)
-- Dependencies: 230
-- Name: TABLE asientomd; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE asientomd IS 'Tabla con el detalle de los asientos modelos';


--
-- TOC entry 3630 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN asientomd.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientomd.id IS 'Identificador unico de registro';


--
-- TOC entry 3631 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN asientomd.asientomid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientomd.asientomid IS 'Identificador del asiento';


--
-- TOC entry 3632 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN asientomd.cuenta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientomd.cuenta IS 'Cuenta contable';


--
-- TOC entry 3633 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN asientomd.sentido; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientomd.sentido IS 'Sentido del monto. 0=debe / 1=haber';


--
-- TOC entry 3634 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN asientomd.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientomd.usuarioid IS 'Identificador del usuario que creo el registro o del ultimo en modificarlo';


--
-- TOC entry 3635 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN asientomd.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientomd.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 231 (class 1259 OID 20766)
-- Dependencies: 230 7
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
-- TOC entry 3636 (class 0 OID 0)
-- Dependencies: 231
-- Name: asientomd_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE asientomd_id_seq OWNED BY asientomd.id;


--
-- TOC entry 284 (class 1259 OID 78903)
-- Dependencies: 2557 2558 7
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
-- TOC entry 283 (class 1259 OID 78901)
-- Dependencies: 7 284
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
-- TOC entry 3637 (class 0 OID 0)
-- Dependencies: 283
-- Name: asignacion_fiscales_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE asignacion_fiscales_id_seq OWNED BY asignacion_fiscales.id;


--
-- TOC entry 267 (class 1259 OID 46443)
-- Dependencies: 2541 7
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
-- TOC entry 3638 (class 0 OID 0)
-- Dependencies: 267
-- Name: TABLE con_img_doc; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE con_img_doc IS 'Tabla con las imagenes de los documentos subidos por los contribuyentes adjunto a la planilla de complementaria de datos para el registro.';


--
-- TOC entry 3639 (class 0 OID 0)
-- Dependencies: 267
-- Name: COLUMN con_img_doc.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN con_img_doc.id IS 'Campo principal, valor unico identificador.';


--
-- TOC entry 3640 (class 0 OID 0)
-- Dependencies: 267
-- Name: COLUMN con_img_doc.conusuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN con_img_doc.conusuid IS 'ID  del contribuyente al cual estan asociados los documentos guardados.';


--
-- TOC entry 266 (class 1259 OID 46441)
-- Dependencies: 267 7
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
-- TOC entry 3641 (class 0 OID 0)
-- Dependencies: 266
-- Name: con_img_doc_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE con_img_doc_id_seq OWNED BY con_img_doc.id;


--
-- TOC entry 291 (class 1259 OID 79221)
-- Dependencies: 2576 7
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
-- TOC entry 3642 (class 0 OID 0)
-- Dependencies: 291
-- Name: TABLE contrib_calc; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE contrib_calc IS 'Tabla de los contribuyentes a los que se aplicaran calculos';


--
-- TOC entry 3643 (class 0 OID 0)
-- Dependencies: 291
-- Name: COLUMN contrib_calc.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contrib_calc.id IS 'Identificador de los contribuyentes a los que se aplicaran calculos';


--
-- TOC entry 3644 (class 0 OID 0)
-- Dependencies: 291
-- Name: COLUMN contrib_calc.conusuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contrib_calc.conusuid IS 'Identificador de los contribuyentes para capturar su informacion';


--
-- TOC entry 290 (class 1259 OID 79219)
-- Dependencies: 291 7
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
-- TOC entry 3645 (class 0 OID 0)
-- Dependencies: 290
-- Name: contrib_calc_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE contrib_calc_id_seq OWNED BY contrib_calc.id;


--
-- TOC entry 232 (class 1259 OID 20768)
-- Dependencies: 7
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
-- TOC entry 3646 (class 0 OID 0)
-- Dependencies: 232
-- Name: TABLE contributi; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE contributi IS 'tabla con los tipo de contribuyentes por contribuyente';


--
-- TOC entry 3647 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN contributi.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contributi.id IS 'Identificador unico de registro';


--
-- TOC entry 3648 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN contributi.contribuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contributi.contribuid IS 'Id del contribuyente';


--
-- TOC entry 3649 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN contributi.tipocontid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contributi.tipocontid IS 'Identificador del tipo de contribuyente';


--
-- TOC entry 3650 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN contributi.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contributi.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 233 (class 1259 OID 20771)
-- Dependencies: 7 232
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
-- TOC entry 3651 (class 0 OID 0)
-- Dependencies: 233
-- Name: contributi_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE contributi_id_seq OWNED BY contributi.id;


--
-- TOC entry 301 (class 1259 OID 87735)
-- Dependencies: 2589 2590 2591 7
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
-- TOC entry 3652 (class 0 OID 0)
-- Dependencies: 301
-- Name: TABLE conusu_interno; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE conusu_interno IS 'tabla que contiene el detalle de el reistro echo en conusu cuando este lo halla echo un usuario interno en recaudacion';


--
-- TOC entry 300 (class 1259 OID 87733)
-- Dependencies: 301 7
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
-- TOC entry 3653 (class 0 OID 0)
-- Dependencies: 300
-- Name: conusu_interno_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE conusu_interno_id_seq OWNED BY conusu_interno.id;


--
-- TOC entry 270 (class 1259 OID 69000)
-- Dependencies: 2547 7
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
-- TOC entry 3654 (class 0 OID 0)
-- Dependencies: 270
-- Name: COLUMN conusu_tipocont.conusuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu_tipocont.conusuid IS 'Campo que se relaciona con la tabla del contribuyente (conusu)';


--
-- TOC entry 3655 (class 0 OID 0)
-- Dependencies: 270
-- Name: COLUMN conusu_tipocont.tipocontid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu_tipocont.tipocontid IS 'Campo que establece la relacion con los tipos de contribuyentes';


--
-- TOC entry 269 (class 1259 OID 68998)
-- Dependencies: 7 270
-- Name: conusu_tipocon_id_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE conusu_tipocon_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos.conusu_tipocon_id_seq OWNER TO postgres;

--
-- TOC entry 3656 (class 0 OID 0)
-- Dependencies: 269
-- Name: conusu_tipocon_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE conusu_tipocon_id_seq OWNED BY conusu_tipocont.id;


--
-- TOC entry 305 (class 1259 OID 87784)
-- Dependencies: 7
-- Name: correlativos_actas; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE correlativos_actas (
    id bigint NOT NULL,
    nombre character varying,
    correlativo integer,
    anio integer
);


ALTER TABLE datos.correlativos_actas OWNER TO postgres;

--
-- TOC entry 304 (class 1259 OID 87782)
-- Dependencies: 7 305
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
-- TOC entry 3657 (class 0 OID 0)
-- Dependencies: 304
-- Name: correlativos_actas_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE correlativos_actas_id_seq OWNED BY correlativos_actas.id;


--
-- TOC entry 234 (class 1259 OID 20773)
-- Dependencies: 2504 2505 7
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
-- TOC entry 3658 (class 0 OID 0)
-- Dependencies: 234
-- Name: TABLE ctaconta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE ctaconta IS 'Tabla con el plan de cuentas contables a utilizar.';


--
-- TOC entry 3659 (class 0 OID 0)
-- Dependencies: 234
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
-- TOC entry 3660 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN ctaconta.descripcion; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN ctaconta.descripcion IS 'Descripcion de la cuenta';


--
-- TOC entry 3661 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN ctaconta.usaraux; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN ctaconta.usaraux IS 'Si la cuenta usara auxiliares. Esto es para el caso de una cuenta que no use auxiliar, esta podra tener movimiento a nivel de sub-especifico';


--
-- TOC entry 3662 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN ctaconta.inactiva; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN ctaconta.inactiva IS 'Si la cuenta esta inactiva o no';


--
-- TOC entry 3663 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN ctaconta.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN ctaconta.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3664 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN ctaconta.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN ctaconta.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 285 (class 1259 OID 78994)
-- Dependencies: 2559 2560 2561 2562 2563 2564 2565 2566 7
-- Name: declara; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE declara (
    id integer DEFAULT nextval('"Declara_IDDeclara_seq"'::regclass) NOT NULL,
    nudeclara character varying(27),
    nudeposito character varying(27),
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
    bln_declaro0 boolean DEFAULT false
);


ALTER TABLE datos.declara OWNER TO postgres;

--
-- TOC entry 3665 (class 0 OID 0)
-- Dependencies: 285
-- Name: TABLE declara; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE declara IS 'Planilla de declaracion de impuestos';


--
-- TOC entry 3666 (class 0 OID 0)
-- Dependencies: 285
-- Name: COLUMN declara.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.id IS 'Identificador unico de la declaracion de impuestos';


--
-- TOC entry 3667 (class 0 OID 0)
-- Dependencies: 285
-- Name: COLUMN declara.nudeclara; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.nudeclara IS 'Numero de planilla de declaracion de impuesto';


--
-- TOC entry 3668 (class 0 OID 0)
-- Dependencies: 285
-- Name: COLUMN declara.nudeposito; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.nudeposito IS 'Numero de deposito bancario generado por el sistema';


--
-- TOC entry 3669 (class 0 OID 0)
-- Dependencies: 285
-- Name: COLUMN declara.tdeclaraid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.tdeclaraid IS 'Identificador del tipo de declaracion';


--
-- TOC entry 3670 (class 0 OID 0)
-- Dependencies: 285
-- Name: COLUMN declara.fechaelab; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.fechaelab IS 'Fecha de elaboracion de la planilla de pago de impuestos';


--
-- TOC entry 3671 (class 0 OID 0)
-- Dependencies: 285
-- Name: COLUMN declara.fechaini; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.fechaini IS 'Fecha de inicio del periodo gravable';


--
-- TOC entry 3672 (class 0 OID 0)
-- Dependencies: 285
-- Name: COLUMN declara.fechafin; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.fechafin IS 'Fecha final del periodo gravable';


--
-- TOC entry 3673 (class 0 OID 0)
-- Dependencies: 285
-- Name: COLUMN declara.replegalid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.replegalid IS 'Identificador del representante legal que aparecera en la planilla y firmara la misma';


--
-- TOC entry 3674 (class 0 OID 0)
-- Dependencies: 285
-- Name: COLUMN declara.baseimpo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.baseimpo IS 'Base imponible';


--
-- TOC entry 3675 (class 0 OID 0)
-- Dependencies: 285
-- Name: COLUMN declara.alicuota; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.alicuota IS 'Alicuota impositiva aplicada a la declaracion de impuesto';


--
-- TOC entry 3676 (class 0 OID 0)
-- Dependencies: 285
-- Name: COLUMN declara.exonera; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.exonera IS 'Exoneracion o rebaja';


--
-- TOC entry 3677 (class 0 OID 0)
-- Dependencies: 285
-- Name: COLUMN declara.nuactoexon; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.nuactoexon IS 'Numero de acto en donde se establece la exoneracion o rebaja';


--
-- TOC entry 3678 (class 0 OID 0)
-- Dependencies: 285
-- Name: COLUMN declara.credfiscal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.credfiscal IS 'Credito fiscal';


--
-- TOC entry 3679 (class 0 OID 0)
-- Dependencies: 285
-- Name: COLUMN declara.contribant; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.contribant IS 'Monto de la contribucion pagada en periodos anteriores';


--
-- TOC entry 3680 (class 0 OID 0)
-- Dependencies: 285
-- Name: COLUMN declara.plasustid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.plasustid IS 'Identificador de la planilla que se esta sustituyendo en caso de ser una declaracion sustitutiva';


--
-- TOC entry 3681 (class 0 OID 0)
-- Dependencies: 285
-- Name: COLUMN declara.montopagar; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.montopagar IS 'Monto a pagar';


--
-- TOC entry 3682 (class 0 OID 0)
-- Dependencies: 285
-- Name: COLUMN declara.fechapago; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.fechapago IS 'Fecha de pago en el banco. Se llena este campo cuando se concilian los pagos';


--
-- TOC entry 3683 (class 0 OID 0)
-- Dependencies: 285
-- Name: COLUMN declara.fechaconci; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.fechaconci IS 'Fecha hora de la conciliacion contra los depositos del banco';


--
-- TOC entry 3684 (class 0 OID 0)
-- Dependencies: 285
-- Name: COLUMN declara.asientoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.asientoid IS 'Identificador del asiento contable en donde se registro la informacion del pago';


--
-- TOC entry 3685 (class 0 OID 0)
-- Dependencies: 285
-- Name: COLUMN declara.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.usuarioid IS 'Identificador del usuario que concilio el pago de la declaracion. ';


--
-- TOC entry 3686 (class 0 OID 0)
-- Dependencies: 285
-- Name: COLUMN declara.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 278 (class 1259 OID 77332)
-- Dependencies: 7
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
    usuarioid integer
);


ALTER TABLE datos.detalle_interes OWNER TO postgres;

--
-- TOC entry 3687 (class 0 OID 0)
-- Dependencies: 278
-- Name: TABLE detalle_interes; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE detalle_interes IS 'Tabla para el registro de los detalles de los intereses';


--
-- TOC entry 3688 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN detalle_interes.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes.id IS 'Identificador del detalle de los intereses';


--
-- TOC entry 3689 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN detalle_interes.intereses; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes.intereses IS 'intereses por mes';


--
-- TOC entry 3690 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN detalle_interes.tasa; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes.tasa IS 'tasa por mes segun el bcv';


--
-- TOC entry 3691 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN detalle_interes.dias; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes.dias IS 'dias de los meses de cada periodo';


--
-- TOC entry 3692 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN detalle_interes.mes; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes.mes IS 'meses de los periodos para el pago de los intereses';


--
-- TOC entry 3693 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN detalle_interes.anio; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes.anio IS 'anio de periodos';


--
-- TOC entry 3694 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN detalle_interes.intereses_id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes.intereses_id IS 'identificador del id de  la tabla de intereses';


--
-- TOC entry 277 (class 1259 OID 77330)
-- Dependencies: 7 278
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
-- TOC entry 3695 (class 0 OID 0)
-- Dependencies: 277
-- Name: detalle_interes_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE detalle_interes_id_seq OWNED BY detalle_interes.id;


--
-- TOC entry 280 (class 1259 OID 78841)
-- Dependencies: 7
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
-- TOC entry 3696 (class 0 OID 0)
-- Dependencies: 280
-- Name: TABLE detalle_interes_viejo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE detalle_interes_viejo IS 'Tabla para el registro de los detalles de los intereses';


--
-- TOC entry 3697 (class 0 OID 0)
-- Dependencies: 280
-- Name: COLUMN detalle_interes_viejo.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes_viejo.id IS 'Identificador del detalle de los intereses';


--
-- TOC entry 3698 (class 0 OID 0)
-- Dependencies: 280
-- Name: COLUMN detalle_interes_viejo.intereses; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes_viejo.intereses IS 'intereses por mes';


--
-- TOC entry 3699 (class 0 OID 0)
-- Dependencies: 280
-- Name: COLUMN detalle_interes_viejo.tasa; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes_viejo.tasa IS 'tasa por mes segun el bcv';


--
-- TOC entry 3700 (class 0 OID 0)
-- Dependencies: 280
-- Name: COLUMN detalle_interes_viejo.dias; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes_viejo.dias IS 'dias de los meses de cada periodo';


--
-- TOC entry 3701 (class 0 OID 0)
-- Dependencies: 280
-- Name: COLUMN detalle_interes_viejo.mes; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes_viejo.mes IS 'meses de los periodos para el pago de los intereses';


--
-- TOC entry 3702 (class 0 OID 0)
-- Dependencies: 280
-- Name: COLUMN detalle_interes_viejo.anio; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes_viejo.anio IS 'anio de periodos';


--
-- TOC entry 3703 (class 0 OID 0)
-- Dependencies: 280
-- Name: COLUMN detalle_interes_viejo.intereses_id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes_viejo.intereses_id IS 'identificador del id de  la tabla de intereses';


--
-- TOC entry 279 (class 1259 OID 78839)
-- Dependencies: 7 280
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
-- TOC entry 3704 (class 0 OID 0)
-- Dependencies: 279
-- Name: detalle_interes_id_seq1; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE detalle_interes_id_seq1 OWNED BY detalle_interes_viejo.id;


--
-- TOC entry 299 (class 1259 OID 87642)
-- Dependencies: 7
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
-- TOC entry 298 (class 1259 OID 87640)
-- Dependencies: 7 299
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
-- TOC entry 3705 (class 0 OID 0)
-- Dependencies: 298
-- Name: detalles_contrib_calc_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE detalles_contrib_calc_id_seq OWNED BY detalles_contrib_calc.id;


--
-- TOC entry 287 (class 1259 OID 79062)
-- Dependencies: 2568 2569 2570 7
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
-- TOC entry 286 (class 1259 OID 79060)
-- Dependencies: 7 287
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
-- TOC entry 3706 (class 0 OID 0)
-- Dependencies: 286
-- Name: dettalles_fizcalizacion_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE dettalles_fizcalizacion_id_seq OWNED BY dettalles_fizcalizacion.id;


--
-- TOC entry 235 (class 1259 OID 20778)
-- Dependencies: 2506 7
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
-- TOC entry 3707 (class 0 OID 0)
-- Dependencies: 235
-- Name: TABLE document; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE document IS 'Tabla con los documentos legales utilizados por el sistema';


--
-- TOC entry 3708 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN document.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN document.id IS 'Identificador unico de registro';


--
-- TOC entry 3709 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN document.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN document.nombre IS 'Nombre del documento';


--
-- TOC entry 3710 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN document.docu; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN document.docu IS 'Texto del documento';


--
-- TOC entry 3711 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN document.inactivo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN document.inactivo IS 'Si el documento esta inactivo o activo';


--
-- TOC entry 3712 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN document.usfonproid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN document.usfonproid IS 'Identificador del ususario que creo o el ultimo que modifico el registro';


--
-- TOC entry 3713 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN document.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN document.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 236 (class 1259 OID 20785)
-- Dependencies: 235 7
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
-- TOC entry 3714 (class 0 OID 0)
-- Dependencies: 236
-- Name: document_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE document_id_seq OWNED BY document.id;


--
-- TOC entry 275 (class 1259 OID 77288)
-- Dependencies: 7
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
-- TOC entry 276 (class 1259 OID 77291)
-- Dependencies: 7 275
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
-- TOC entry 3715 (class 0 OID 0)
-- Dependencies: 276
-- Name: interes_bcv_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE interes_bcv_id_seq OWNED BY interes_bcv.id;


--
-- TOC entry 303 (class 1259 OID 87765)
-- Dependencies: 2593 7
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
-- TOC entry 302 (class 1259 OID 87763)
-- Dependencies: 303 7
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
-- TOC entry 3716 (class 0 OID 0)
-- Dependencies: 302
-- Name: presidente_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE presidente_id_seq OWNED BY presidente.id;


--
-- TOC entry 288 (class 1259 OID 79132)
-- Dependencies: 2571 2572 2573 2574 7
-- Name: reparos; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE reparos (
    id integer DEFAULT nextval('"Declara_IDDeclara_seq"'::regclass) NOT NULL,
    tdeclaraid integer NOT NULL,
    fechaelab timestamp without time zone NOT NULL,
    montopagar numeric(18,2) DEFAULT 0 NOT NULL,
    fechapago date,
    fechaconci timestamp without time zone,
    asientoid integer,
    usuarioid integer,
    ip character varying(15) NOT NULL,
    tipocontribuid integer NOT NULL,
    conusuid integer NOT NULL,
    bln_activo boolean DEFAULT false NOT NULL,
    proceso character varying,
    fecha_notificacion timestamp without time zone,
    bln_sumario boolean DEFAULT false NOT NULL
);


ALTER TABLE datos.reparos OWNER TO postgres;

--
-- TOC entry 3717 (class 0 OID 0)
-- Dependencies: 288
-- Name: COLUMN reparos.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN reparos.id IS 'Identificador unico de la declaracion de impuestos';


--
-- TOC entry 3718 (class 0 OID 0)
-- Dependencies: 288
-- Name: COLUMN reparos.tdeclaraid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN reparos.tdeclaraid IS 'Identificador del tipo de declaracion';


--
-- TOC entry 3719 (class 0 OID 0)
-- Dependencies: 288
-- Name: COLUMN reparos.fechaelab; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN reparos.fechaelab IS 'Fecha de elaboracion de la planilla de pago de impuestos';


--
-- TOC entry 3720 (class 0 OID 0)
-- Dependencies: 288
-- Name: COLUMN reparos.montopagar; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN reparos.montopagar IS 'Monto a pagar';


--
-- TOC entry 3721 (class 0 OID 0)
-- Dependencies: 288
-- Name: COLUMN reparos.fechapago; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN reparos.fechapago IS 'Fecha de pago en el banco. Se llena este campo cuando se concilian los pagos';


--
-- TOC entry 3722 (class 0 OID 0)
-- Dependencies: 288
-- Name: COLUMN reparos.fechaconci; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN reparos.fechaconci IS 'Fecha hora de la conciliacion contra los depositos del banco';


--
-- TOC entry 3723 (class 0 OID 0)
-- Dependencies: 288
-- Name: COLUMN reparos.asientoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN reparos.asientoid IS 'Identificador del asiento contable en donde se registro la informacion del pago';


--
-- TOC entry 3724 (class 0 OID 0)
-- Dependencies: 288
-- Name: COLUMN reparos.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN reparos.usuarioid IS 'Identificador del usuario que concilio el pago de la declaracion. ';


--
-- TOC entry 3725 (class 0 OID 0)
-- Dependencies: 288
-- Name: COLUMN reparos.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN reparos.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 237 (class 1259 OID 20787)
-- Dependencies: 2508 2509 7
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
-- TOC entry 3726 (class 0 OID 0)
-- Dependencies: 237
-- Name: TABLE tmpaccioni; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE tmpaccioni IS 'Tabla con los datos de los Accionistas de los contribuyentes';


--
-- TOC entry 3727 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN tmpaccioni.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.id IS 'Identificador unico del accionista';


--
-- TOC entry 3728 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN tmpaccioni.contribuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.contribuid IS 'Identificador del contribuyente';


--
-- TOC entry 3729 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN tmpaccioni.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.nombre IS 'Nombre del accionista';


--
-- TOC entry 3730 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN tmpaccioni.apellido; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.apellido IS 'Apellidos del accionista';


--
-- TOC entry 3731 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN tmpaccioni.ci; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.ci IS 'Cedula de identidad, numero de pasaporte';


--
-- TOC entry 3732 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN tmpaccioni.domfiscal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.domfiscal IS 'Domicilio fiscal del accionista';


--
-- TOC entry 3733 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN tmpaccioni.nuacciones; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.nuacciones IS 'Numero de acciones';


--
-- TOC entry 3734 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN tmpaccioni.valaccion; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.valaccion IS 'Valor nominal de las acciones';


--
-- TOC entry 3735 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN tmpaccioni.cextra1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.cextra1 IS 'Campo extra 1';


--
-- TOC entry 3736 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN tmpaccioni.cextra2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.cextra2 IS 'Campo extra 2';


--
-- TOC entry 3737 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN tmpaccioni.cextra3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.cextra3 IS 'Campo extra 3';


--
-- TOC entry 3738 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN tmpaccioni.cextra4; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.cextra4 IS 'Campo extra 4';


--
-- TOC entry 3739 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN tmpaccioni.cextra5; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.cextra5 IS 'Campo extra 5';


--
-- TOC entry 3740 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN tmpaccioni.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 238 (class 1259 OID 20795)
-- Dependencies: 2510 2511 2512 2513 7
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
-- TOC entry 3741 (class 0 OID 0)
-- Dependencies: 238
-- Name: TABLE tmpcontri; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE tmpcontri IS 'Tabla con los datos temporales de los contribuyentes de la institución. Esta tabla se utiliza para que los contribuyentes hagan una solicitud de actualizacion de datos';


--
-- TOC entry 3742 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.id IS 'Identificador unico del contribuyente';


--
-- TOC entry 3743 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.tipocontid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.tipocontid IS 'Identificador del tipo de contribuyente';


--
-- TOC entry 3744 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.razonsocia; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.razonsocia IS 'Razon social del contribuyente';


--
-- TOC entry 3745 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.dencomerci; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.dencomerci IS 'Denominacion comercial del contribuyente';


--
-- TOC entry 3746 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.actieconid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.actieconid IS 'Identificador de la actividad economica';


--
-- TOC entry 3747 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.rif; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.rif IS 'Rif del contribuyente';


--
-- TOC entry 3748 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.numregcine; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.numregcine IS 'Numero de registro cinematografico';


--
-- TOC entry 3749 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.domfiscal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.domfiscal IS 'Domicilio fiscal del contribuyente';


--
-- TOC entry 3750 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.estadoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.estadoid IS 'Identicador del estado geografico';


--
-- TOC entry 3751 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.ciudadid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.ciudadid IS 'Identificador de la ciudad';


--
-- TOC entry 3752 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.zonapostal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.zonapostal IS 'Zona postal del contribuyente';


--
-- TOC entry 3753 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.telef1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.telef1 IS 'Telefono 1 del contribuyente';


--
-- TOC entry 3754 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.telef2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.telef2 IS 'Telefono 2 del contribuyente';


--
-- TOC entry 3755 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.telef3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.telef3 IS 'Telefono 3 del contribuyente';


--
-- TOC entry 3756 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.fax1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.fax1 IS 'Fax 1 del contribuyente';


--
-- TOC entry 3757 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.fax2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.fax2 IS 'Fax 2 del contribuyente';


--
-- TOC entry 3758 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.email; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.email IS 'Direccion de email de contribuyente';


--
-- TOC entry 3759 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.pinbb; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.pinbb IS 'Pin de BlackBerry';


--
-- TOC entry 3760 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.skype; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.skype IS 'Dirección de skype';


--
-- TOC entry 3761 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.twitter; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.twitter IS 'Direccion de twitter';


--
-- TOC entry 3762 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.facebook; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.facebook IS 'Direccion de facebook';


--
-- TOC entry 3763 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.nuacciones; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.nuacciones IS 'Numero de acciones del contribuyente segun inforacion del registro mercantil';


--
-- TOC entry 3764 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.valaccion; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.valaccion IS 'Valor nominal por accion segun registro mercantil';


--
-- TOC entry 3765 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.capitalsus; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.capitalsus IS 'Capital suscrito segun registro mercantil';


--
-- TOC entry 3766 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.capitalpag; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.capitalpag IS 'Capital pagado segun registro mercantil';


--
-- TOC entry 3767 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.regmerofc; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.regmerofc IS 'Oficina de registro mercantil en donde se registro la empresa';


--
-- TOC entry 3768 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.rmnumero; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.rmnumero IS 'Numero de registro del documento de registro mercantil';


--
-- TOC entry 3769 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.rmfolio; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.rmfolio IS 'Numero de folio del documento de registro mercantil';


--
-- TOC entry 3770 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.rmtomo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.rmtomo IS 'Numero de folio del documento de registro mercantil';


--
-- TOC entry 3771 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.rmfechapro; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.rmfechapro IS 'Fecha de protocololizacion del registro del documento de registro mercantil';


--
-- TOC entry 3772 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.rmncontrol; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.rmncontrol IS 'Numero de control del documento de registro mercantil';


--
-- TOC entry 3773 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.rmobjeto; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.rmobjeto IS 'Objeto de la empresa segun registro mercantil';


--
-- TOC entry 3774 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.domcomer; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.domcomer IS 'domicilio comercial';


--
-- TOC entry 3775 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.conusuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.conusuid IS 'Identificador del usuario-contribuyente que creo el registro';


--
-- TOC entry 3776 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.tiporeg; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.tiporeg IS 'Tipo de registro creado. 0=Nuevo contribuyente, 1=Edicion de datos de contribuyentes';


--
-- TOC entry 3777 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.cextra1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.cextra1 IS 'Campo extra 1';


--
-- TOC entry 3778 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.cextra2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.cextra2 IS 'Campo extra 2';


--
-- TOC entry 3779 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.cextra3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.cextra3 IS 'Campo extra 3';


--
-- TOC entry 3780 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.cextra4; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.cextra4 IS 'Campo extra 4';


--
-- TOC entry 3781 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.cextra5; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.cextra5 IS 'Campo extra 5';


--
-- TOC entry 3782 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 239 (class 1259 OID 20805)
-- Dependencies: 7
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
-- TOC entry 3783 (class 0 OID 0)
-- Dependencies: 239
-- Name: TABLE tmprelegal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE tmprelegal IS 'Tabla con los datos temporales de los representantes legales de los contribuyentes. Esta tabla se utiliza para procesar una solicitud de cambio de datos. El contribuyente copia aqui los nuevos datos';


--
-- TOC entry 3784 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN tmprelegal.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.id IS 'Identificador unico del representante legal';


--
-- TOC entry 3785 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN tmprelegal.contribuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.contribuid IS 'Identificador del contribuyente';


--
-- TOC entry 3786 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN tmprelegal.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.nombre IS 'Nombre del representante legal';


--
-- TOC entry 3787 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN tmprelegal.apellido; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.apellido IS 'Apellidos del representante legal';


--
-- TOC entry 3788 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN tmprelegal.ci; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.ci IS 'Cedula de identidad, numero de pasaporte';


--
-- TOC entry 3789 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN tmprelegal.domfiscal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.domfiscal IS 'Domicilio fiscal del representante legal';


--
-- TOC entry 3790 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN tmprelegal.estadoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.estadoid IS 'Identificador del estado geografico';


--
-- TOC entry 3791 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN tmprelegal.ciudadid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.ciudadid IS 'Identificador de la ciudad';


--
-- TOC entry 3792 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN tmprelegal.zonaposta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.zonaposta IS 'Zona postal';


--
-- TOC entry 3793 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN tmprelegal.telefhab; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.telefhab IS 'Telefono de habitacion del representante legal';


--
-- TOC entry 3794 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN tmprelegal.telefofc; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.telefofc IS 'Telefono de oficina del representante legal';


--
-- TOC entry 3795 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN tmprelegal.fax; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.fax IS 'Fax del representante legal';


--
-- TOC entry 3796 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN tmprelegal.email; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.email IS 'Direccion de email del contribuyente';


--
-- TOC entry 3797 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN tmprelegal.pinbb; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.pinbb IS 'Pin de BlackBerry';


--
-- TOC entry 3798 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN tmprelegal.skype; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.skype IS 'Direccion de skype del representante legal';


--
-- TOC entry 3799 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN tmprelegal.cextra1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.cextra1 IS 'Campo extra 1 ';


--
-- TOC entry 3800 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN tmprelegal.cextra2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.cextra2 IS 'Campo extra 2 ';


--
-- TOC entry 3801 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN tmprelegal.cextra3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.cextra3 IS 'Campo extra 3 ';


--
-- TOC entry 3802 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN tmprelegal.cextra4; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.cextra4 IS 'Campo extra 4 ';


--
-- TOC entry 3803 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN tmprelegal.cextra5; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.cextra5 IS 'Campo extra 5 ';


--
-- TOC entry 3804 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN tmprelegal.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 253 (class 1259 OID 21645)
-- Dependencies: 7
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

SET search_path = historial, pg_catalog;

--
-- TOC entry 240 (class 1259 OID 20811)
-- Dependencies: 2514 8
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
-- TOC entry 3805 (class 0 OID 0)
-- Dependencies: 240
-- Name: TABLE bitacora; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON TABLE bitacora IS 'Tabla con la bitacora de los datos cambiados de todas las tablas del sistema';


--
-- TOC entry 3806 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN bitacora.id; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON COLUMN bitacora.id IS 'Identificador de la bitacora';


--
-- TOC entry 3807 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN bitacora.fecha; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON COLUMN bitacora.fecha IS 'Fecha/Hora de la transaccion';


--
-- TOC entry 3808 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN bitacora.tabla; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON COLUMN bitacora.tabla IS 'Nombre de tabla sobre la cual se ejecuto la transaccion';


--
-- TOC entry 3809 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN bitacora.idusuario; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON COLUMN bitacora.idusuario IS 'Identificador del usuario que genero la transaccion';


--
-- TOC entry 3810 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN bitacora.accion; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON COLUMN bitacora.accion IS 'Accion ejecutada sobre la tabla. 0.- Insert / 1.- Update / 2.- Delete';


--
-- TOC entry 3811 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN bitacora.datosnew; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON COLUMN bitacora.datosnew IS 'Datos nuevos para el caso de los insert y los Update';


--
-- TOC entry 3812 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN bitacora.datosold; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON COLUMN bitacora.datosold IS 'Datos originales para el caso de los Update';


--
-- TOC entry 3813 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN bitacora.datosdel; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON COLUMN bitacora.datosdel IS 'Datos eliminados para el caso de los Delete';


--
-- TOC entry 3814 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN bitacora.valdelid; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON COLUMN bitacora.valdelid IS 'ID del registro que fue borrado';


--
-- TOC entry 3815 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN bitacora.ip; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON COLUMN bitacora.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 241 (class 1259 OID 20818)
-- Dependencies: 8 240
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
-- TOC entry 3817 (class 0 OID 0)
-- Dependencies: 241
-- Name: Bitacora_IDBitacora_seq; Type: SEQUENCE OWNED BY; Schema: historial; Owner: postgres
--

ALTER SEQUENCE "Bitacora_IDBitacora_seq" OWNED BY bitacora.id;


SET search_path = pre_aprobacion, pg_catalog;

--
-- TOC entry 293 (class 1259 OID 87498)
-- Dependencies: 2578 2579 2580 2581 11
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
-- TOC entry 292 (class 1259 OID 87496)
-- Dependencies: 11 293
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
-- TOC entry 3819 (class 0 OID 0)
-- Dependencies: 292
-- Name: datos_cnac_id_seq; Type: SEQUENCE OWNED BY; Schema: pre_aprobacion; Owner: postgres
--

ALTER SEQUENCE datos_cnac_id_seq OWNED BY datos_cnac.id;


--
-- TOC entry 274 (class 1259 OID 77269)
-- Dependencies: 2550 11
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
    fecha_fin date
);


ALTER TABLE pre_aprobacion.intereses OWNER TO postgres;

--
-- TOC entry 3820 (class 0 OID 0)
-- Dependencies: 274
-- Name: COLUMN intereses.multaid; Type: COMMENT; Schema: pre_aprobacion; Owner: postgres
--

COMMENT ON COLUMN intereses.multaid IS 'campor para relacionar con la tabla de multas';


--
-- TOC entry 273 (class 1259 OID 77267)
-- Dependencies: 274 11
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
-- TOC entry 3821 (class 0 OID 0)
-- Dependencies: 273
-- Name: intereses_id_seq; Type: SEQUENCE OWNED BY; Schema: pre_aprobacion; Owner: postgres
--

ALTER SEQUENCE intereses_id_seq OWNED BY intereses.id;


--
-- TOC entry 272 (class 1259 OID 77248)
-- Dependencies: 11
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
    tipo_multa integer
);


ALTER TABLE pre_aprobacion.multas OWNER TO postgres;

--
-- TOC entry 3822 (class 0 OID 0)
-- Dependencies: 272
-- Name: TABLE multas; Type: COMMENT; Schema: pre_aprobacion; Owner: postgres
--

COMMENT ON TABLE multas IS 'tabla que contiene el calculo de las multas por declaraciones extemporaneas o reparo fiscal';


--
-- TOC entry 271 (class 1259 OID 77246)
-- Dependencies: 11 272
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
-- TOC entry 3823 (class 0 OID 0)
-- Dependencies: 271
-- Name: multas_id_seq; Type: SEQUENCE OWNED BY; Schema: pre_aprobacion; Owner: postgres
--

ALTER SEQUENCE multas_id_seq OWNED BY multas.id;


SET search_path = public, pg_catalog;

--
-- TOC entry 289 (class 1259 OID 79201)
-- Dependencies: 5
-- Name: contrib_calc; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE contrib_calc (
    id character(10) NOT NULL,
    nombre character(40)
);


ALTER TABLE public.contrib_calc OWNER TO postgres;

SET search_path = seg, pg_catalog;

--
-- TOC entry 297 (class 1259 OID 87607)
-- Dependencies: 2586 10
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
-- TOC entry 296 (class 1259 OID 87605)
-- Dependencies: 297 10
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
-- TOC entry 3824 (class 0 OID 0)
-- Dependencies: 296
-- Name: tbl_cargos_id_seq; Type: SEQUENCE OWNED BY; Schema: seg; Owner: postgres
--

ALTER SEQUENCE tbl_cargos_id_seq OWNED BY tbl_cargos.id;


--
-- TOC entry 268 (class 1259 OID 46570)
-- Dependencies: 2542 2543 2544 2545 10
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
-- TOC entry 3825 (class 0 OID 0)
-- Dependencies: 268
-- Name: TABLE tbl_ci_sessions; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON TABLE tbl_ci_sessions IS 'Sesiones manejadas por CodeIgniter';


--
-- TOC entry 242 (class 1259 OID 21562)
-- Dependencies: 2517 10
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
-- TOC entry 3826 (class 0 OID 0)
-- Dependencies: 242
-- Name: TABLE tbl_modulo; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON TABLE tbl_modulo IS 'Módulos del sistema';


--
-- TOC entry 243 (class 1259 OID 21569)
-- Dependencies: 10 242
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
-- TOC entry 3827 (class 0 OID 0)
-- Dependencies: 243
-- Name: tbl_modulo_id_modulo_seq; Type: SEQUENCE OWNED BY; Schema: seg; Owner: postgres
--

ALTER SEQUENCE tbl_modulo_id_modulo_seq OWNED BY tbl_modulo.id_modulo;


--
-- TOC entry 295 (class 1259 OID 87568)
-- Dependencies: 2583 2584 10
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
-- TOC entry 294 (class 1259 OID 87566)
-- Dependencies: 295 10
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
-- TOC entry 3828 (class 0 OID 0)
-- Dependencies: 294
-- Name: tbl_oficinas_id_seq; Type: SEQUENCE OWNED BY; Schema: seg; Owner: postgres
--

ALTER SEQUENCE tbl_oficinas_id_seq OWNED BY tbl_oficinas.id;


--
-- TOC entry 244 (class 1259 OID 21571)
-- Dependencies: 2519 10
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
-- TOC entry 3829 (class 0 OID 0)
-- Dependencies: 244
-- Name: TABLE tbl_permiso; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON TABLE tbl_permiso IS 'Permisos de los roles sobre los módulos';


--
-- TOC entry 245 (class 1259 OID 21575)
-- Dependencies: 10 244
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
-- TOC entry 3830 (class 0 OID 0)
-- Dependencies: 245
-- Name: tbl_permiso_id_permiso_seq; Type: SEQUENCE OWNED BY; Schema: seg; Owner: postgres
--

ALTER SEQUENCE tbl_permiso_id_permiso_seq OWNED BY tbl_permiso.id_permiso;


--
-- TOC entry 282 (class 1259 OID 78878)
-- Dependencies: 2555 10
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
-- TOC entry 3831 (class 0 OID 0)
-- Dependencies: 282
-- Name: TABLE tbl_permiso_trampa; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON TABLE tbl_permiso_trampa IS 'Permisos de los roles sobre los módulos';


--
-- TOC entry 281 (class 1259 OID 78876)
-- Dependencies: 10 282
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
-- TOC entry 3832 (class 0 OID 0)
-- Dependencies: 281
-- Name: tbl_permiso_trampa_id_permiso_seq; Type: SEQUENCE OWNED BY; Schema: seg; Owner: postgres
--

ALTER SEQUENCE tbl_permiso_trampa_id_permiso_seq OWNED BY tbl_permiso_trampa.id_permiso;


--
-- TOC entry 246 (class 1259 OID 21577)
-- Dependencies: 2521 10
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
-- TOC entry 3833 (class 0 OID 0)
-- Dependencies: 246
-- Name: TABLE tbl_rol; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON TABLE tbl_rol IS 'Roles de los usuarios del sistema';


--
-- TOC entry 247 (class 1259 OID 21584)
-- Dependencies: 246 10
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
-- TOC entry 3834 (class 0 OID 0)
-- Dependencies: 247
-- Name: tbl_rol_id_rol_seq; Type: SEQUENCE OWNED BY; Schema: seg; Owner: postgres
--

ALTER SEQUENCE tbl_rol_id_rol_seq OWNED BY tbl_rol.id_rol;


--
-- TOC entry 248 (class 1259 OID 21586)
-- Dependencies: 2523 10
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
-- TOC entry 3835 (class 0 OID 0)
-- Dependencies: 248
-- Name: TABLE tbl_rol_usuario; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON TABLE tbl_rol_usuario IS 'Roles de los usuarios, un usuario puede tener multiples roles dentro del sistema';


--
-- TOC entry 3836 (class 0 OID 0)
-- Dependencies: 248
-- Name: COLUMN tbl_rol_usuario.id_rol_usuario; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON COLUMN tbl_rol_usuario.id_rol_usuario IS 'Identificador del usuario';


--
-- TOC entry 3837 (class 0 OID 0)
-- Dependencies: 248
-- Name: COLUMN tbl_rol_usuario.id_rol; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON COLUMN tbl_rol_usuario.id_rol IS 'Relación con el rol';


--
-- TOC entry 3838 (class 0 OID 0)
-- Dependencies: 248
-- Name: COLUMN tbl_rol_usuario.id_usuario; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON COLUMN tbl_rol_usuario.id_usuario IS 'Relación con el usuario';


--
-- TOC entry 3839 (class 0 OID 0)
-- Dependencies: 248
-- Name: COLUMN tbl_rol_usuario.bln_borrado; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON COLUMN tbl_rol_usuario.bln_borrado IS 'Marca de borrado lógico';


--
-- TOC entry 249 (class 1259 OID 21590)
-- Dependencies: 248 10
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
-- TOC entry 3840 (class 0 OID 0)
-- Dependencies: 249
-- Name: tbl_rol_usuario_id_rol_usuario_seq; Type: SEQUENCE OWNED BY; Schema: seg; Owner: postgres
--

ALTER SEQUENCE tbl_rol_usuario_id_rol_usuario_seq OWNED BY tbl_rol_usuario.id_rol_usuario;


--
-- TOC entry 250 (class 1259 OID 21592)
-- Dependencies: 2524 2525 2526 2527 10
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
-- TOC entry 3841 (class 0 OID 0)
-- Dependencies: 250
-- Name: TABLE tbl_session_ci; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON TABLE tbl_session_ci IS 'Sesiones manejadas por CodeIgniter';


--
-- TOC entry 251 (class 1259 OID 21602)
-- Dependencies: 2529 10
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
-- TOC entry 3842 (class 0 OID 0)
-- Dependencies: 251
-- Name: TABLE tbl_usuario_rol; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON TABLE tbl_usuario_rol IS 'Permisos de los roles de usuarios sobre los módulos';


--
-- TOC entry 252 (class 1259 OID 21606)
-- Dependencies: 10 251
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
-- TOC entry 3843 (class 0 OID 0)
-- Dependencies: 252
-- Name: tbl_usuario_rol_id_usuario_rol_seq; Type: SEQUENCE OWNED BY; Schema: seg; Owner: postgres
--

ALTER SEQUENCE tbl_usuario_rol_id_usuario_rol_seq OWNED BY tbl_usuario_rol.id_usuario_rol;


--
-- TOC entry 254 (class 1259 OID 21650)
-- Dependencies: 10
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

SET search_path = "segContribu", pg_catalog;

--
-- TOC entry 255 (class 1259 OID 22844)
-- Dependencies: 2531 9
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
-- TOC entry 3844 (class 0 OID 0)
-- Dependencies: 255
-- Name: TABLE tbl_modulo_contribu; Type: COMMENT; Schema: segContribu; Owner: postgres
--

COMMENT ON TABLE tbl_modulo_contribu IS 'Módulos del sistema';


--
-- TOC entry 259 (class 1259 OID 22866)
-- Dependencies: 255 9
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
-- TOC entry 3845 (class 0 OID 0)
-- Dependencies: 259
-- Name: tbl_modulo_id_modulo_seq; Type: SEQUENCE OWNED BY; Schema: segContribu; Owner: postgres
--

ALTER SEQUENCE tbl_modulo_id_modulo_seq OWNED BY tbl_modulo_contribu.id_modulo;


--
-- TOC entry 256 (class 1259 OID 22851)
-- Dependencies: 2533 9
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
-- TOC entry 3846 (class 0 OID 0)
-- Dependencies: 256
-- Name: TABLE tbl_permiso_contribu; Type: COMMENT; Schema: segContribu; Owner: postgres
--

COMMENT ON TABLE tbl_permiso_contribu IS 'Permisos de los roles sobre los módulos';


--
-- TOC entry 260 (class 1259 OID 22868)
-- Dependencies: 256 9
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
-- TOC entry 3847 (class 0 OID 0)
-- Dependencies: 260
-- Name: tbl_permiso_id_permiso_seq; Type: SEQUENCE OWNED BY; Schema: segContribu; Owner: postgres
--

ALTER SEQUENCE tbl_permiso_id_permiso_seq OWNED BY tbl_permiso_contribu.id_permiso;


--
-- TOC entry 257 (class 1259 OID 22855)
-- Dependencies: 2535 9
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
-- TOC entry 3848 (class 0 OID 0)
-- Dependencies: 257
-- Name: TABLE tbl_rol_contribu; Type: COMMENT; Schema: segContribu; Owner: postgres
--

COMMENT ON TABLE tbl_rol_contribu IS 'Roles de los usuarios del sistema';


--
-- TOC entry 261 (class 1259 OID 22870)
-- Dependencies: 9 257
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
-- TOC entry 3849 (class 0 OID 0)
-- Dependencies: 261
-- Name: tbl_rol_id_rol_seq; Type: SEQUENCE OWNED BY; Schema: segContribu; Owner: postgres
--

ALTER SEQUENCE tbl_rol_id_rol_seq OWNED BY tbl_rol_contribu.id_rol;


--
-- TOC entry 258 (class 1259 OID 22862)
-- Dependencies: 2537 9
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
-- TOC entry 3850 (class 0 OID 0)
-- Dependencies: 258
-- Name: TABLE tbl_rol_usuario_contribu; Type: COMMENT; Schema: segContribu; Owner: postgres
--

COMMENT ON TABLE tbl_rol_usuario_contribu IS 'Roles de los usuarios, un usuario puede tener multiples roles dentro del sistema';


--
-- TOC entry 3851 (class 0 OID 0)
-- Dependencies: 258
-- Name: COLUMN tbl_rol_usuario_contribu.id_rol_usuario; Type: COMMENT; Schema: segContribu; Owner: postgres
--

COMMENT ON COLUMN tbl_rol_usuario_contribu.id_rol_usuario IS 'Identificador del usuario';


--
-- TOC entry 3852 (class 0 OID 0)
-- Dependencies: 258
-- Name: COLUMN tbl_rol_usuario_contribu.id_rol; Type: COMMENT; Schema: segContribu; Owner: postgres
--

COMMENT ON COLUMN tbl_rol_usuario_contribu.id_rol IS 'Relación con el rol';


--
-- TOC entry 3853 (class 0 OID 0)
-- Dependencies: 258
-- Name: COLUMN tbl_rol_usuario_contribu.id_usuario; Type: COMMENT; Schema: segContribu; Owner: postgres
--

COMMENT ON COLUMN tbl_rol_usuario_contribu.id_usuario IS 'Relación con el usuario';


--
-- TOC entry 3854 (class 0 OID 0)
-- Dependencies: 258
-- Name: COLUMN tbl_rol_usuario_contribu.bln_borrado; Type: COMMENT; Schema: segContribu; Owner: postgres
--

COMMENT ON COLUMN tbl_rol_usuario_contribu.bln_borrado IS 'Marca de borrado lógico';


--
-- TOC entry 262 (class 1259 OID 22872)
-- Dependencies: 258 9
-- Name: tbl_rol_usuario_id_rol_usuario_seq; Type: SEQUENCE; Schema: segContribu; Owner: postgres
--

CREATE SEQUENCE tbl_rol_usuario_id_rol_usuario_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "segContribu".tbl_rol_usuario_id_rol_usuario_seq OWNER TO postgres;

--
-- TOC entry 3855 (class 0 OID 0)
-- Dependencies: 262
-- Name: tbl_rol_usuario_id_rol_usuario_seq; Type: SEQUENCE OWNED BY; Schema: segContribu; Owner: postgres
--

ALTER SEQUENCE tbl_rol_usuario_id_rol_usuario_seq OWNED BY tbl_rol_usuario_contribu.id_rol_usuario;


--
-- TOC entry 263 (class 1259 OID 22884)
-- Dependencies: 2539 9
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
-- TOC entry 3856 (class 0 OID 0)
-- Dependencies: 263
-- Name: TABLE tbl_usuario_rol_contribu; Type: COMMENT; Schema: segContribu; Owner: postgres
--

COMMENT ON TABLE tbl_usuario_rol_contribu IS 'Permisos de los roles de usuarios sobre los módulos';


--
-- TOC entry 264 (class 1259 OID 22888)
-- Dependencies: 263 9
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
-- TOC entry 3857 (class 0 OID 0)
-- Dependencies: 264
-- Name: tbl_usuario_rol_id_usuario_rol_seq; Type: SEQUENCE OWNED BY; Schema: segContribu; Owner: postgres
--

ALTER SEQUENCE tbl_usuario_rol_id_usuario_rol_seq OWNED BY tbl_usuario_rol_contribu.id_usuario_rol;


--
-- TOC entry 265 (class 1259 OID 22890)
-- Dependencies: 9
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
-- TOC entry 2418 (class 2604 OID 20820)
-- Dependencies: 168 167
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY actiecon ALTER COLUMN id SET DEFAULT nextval('"ActiEcon_IDActiEcon_seq"'::regclass);


--
-- TOC entry 2430 (class 2604 OID 20821)
-- Dependencies: 170 169
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY alicimp ALTER COLUMN id SET DEFAULT nextval('"AlicImp_IDAlicImp_seq"'::regclass);


--
-- TOC entry 2433 (class 2604 OID 20822)
-- Dependencies: 172 171
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asientod ALTER COLUMN id SET DEFAULT nextval('"AsientoD_IDAsientoD_seq"'::regclass);


--
-- TOC entry 2500 (class 2604 OID 20823)
-- Dependencies: 229 228
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asientom ALTER COLUMN id SET DEFAULT nextval('asientom_id_seq'::regclass);


--
-- TOC entry 2502 (class 2604 OID 20824)
-- Dependencies: 231 230
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asientomd ALTER COLUMN id SET DEFAULT nextval('asientomd_id_seq'::regclass);


--
-- TOC entry 2556 (class 2604 OID 78906)
-- Dependencies: 283 284 284
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asignacion_fiscales ALTER COLUMN id SET DEFAULT nextval('asignacion_fiscales_id_seq'::regclass);


--
-- TOC entry 2434 (class 2604 OID 20825)
-- Dependencies: 175 174
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY bacuenta ALTER COLUMN id SET DEFAULT nextval('"BaCuenta_IDBaCuenta_seq"'::regclass);


--
-- TOC entry 2435 (class 2604 OID 20826)
-- Dependencies: 177 176
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY bancos ALTER COLUMN id SET DEFAULT nextval('"Bancos_IDBanco_seq"'::regclass);


--
-- TOC entry 2438 (class 2604 OID 20827)
-- Dependencies: 181 180
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY calpago ALTER COLUMN id SET DEFAULT nextval('"CalPagos_IDCalPago_seq"'::regclass);


--
-- TOC entry 2436 (class 2604 OID 20828)
-- Dependencies: 179 178
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY calpagod ALTER COLUMN id SET DEFAULT nextval('"CalPagoD_IDCalPagoD_seq"'::regclass);


--
-- TOC entry 2439 (class 2604 OID 20829)
-- Dependencies: 183 182
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY cargos ALTER COLUMN id SET DEFAULT nextval('"Cargos_IDCargo_seq"'::regclass);


--
-- TOC entry 2440 (class 2604 OID 20830)
-- Dependencies: 185 184
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY ciudades ALTER COLUMN id SET DEFAULT nextval('"Ciudades_IDCiudad_seq"'::regclass);


--
-- TOC entry 2540 (class 2604 OID 46446)
-- Dependencies: 266 267 267
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY con_img_doc ALTER COLUMN id SET DEFAULT nextval('con_img_doc_id_seq'::regclass);


--
-- TOC entry 2575 (class 2604 OID 79224)
-- Dependencies: 290 291 291
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY contrib_calc ALTER COLUMN id SET DEFAULT nextval('contrib_calc_id_seq'::regclass);


--
-- TOC entry 2457 (class 2604 OID 20831)
-- Dependencies: 195 194
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY contribu ALTER COLUMN id SET DEFAULT nextval('"Contribu_IDContribu_seq"'::regclass);


--
-- TOC entry 2503 (class 2604 OID 20832)
-- Dependencies: 233 232
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY contributi ALTER COLUMN id SET DEFAULT nextval('contributi_id_seq'::regclass);


--
-- TOC entry 2449 (class 2604 OID 20833)
-- Dependencies: 193 192
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusu ALTER COLUMN id SET DEFAULT nextval('"ConUsu_IDConUsu_seq"'::regclass);


--
-- TOC entry 2588 (class 2604 OID 87738)
-- Dependencies: 301 300 301
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusu_interno ALTER COLUMN id SET DEFAULT nextval('conusu_interno_id_seq'::regclass);


--
-- TOC entry 2546 (class 2604 OID 69003)
-- Dependencies: 269 270 270
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusu_tipocont ALTER COLUMN id SET DEFAULT nextval('conusu_tipocon_id_seq'::regclass);


--
-- TOC entry 2441 (class 2604 OID 20834)
-- Dependencies: 187 186
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusuco ALTER COLUMN id SET DEFAULT nextval('"ConUsuCo_IDConUsuCo_seq"'::regclass);


--
-- TOC entry 2445 (class 2604 OID 20835)
-- Dependencies: 189 188
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusuti ALTER COLUMN id SET DEFAULT nextval('"ConUsuTi_IDConUsuTi_seq"'::regclass);


--
-- TOC entry 2447 (class 2604 OID 20836)
-- Dependencies: 191 190
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusuto ALTER COLUMN id SET DEFAULT nextval('"ConUsuTo_IDConUsuTo_seq"'::regclass);


--
-- TOC entry 2594 (class 2604 OID 87787)
-- Dependencies: 305 304 305
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY correlativos_actas ALTER COLUMN id SET DEFAULT nextval('correlativos_actas_id_seq'::regclass);


--
-- TOC entry 2466 (class 2604 OID 20837)
-- Dependencies: 197 196
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara_viejo ALTER COLUMN id SET DEFAULT nextval('"Declara_IDDeclara_seq"'::regclass);


--
-- TOC entry 2467 (class 2604 OID 20838)
-- Dependencies: 199 198
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY departam ALTER COLUMN id SET DEFAULT nextval('"Departam_IDDepartam_seq"'::regclass);


--
-- TOC entry 2552 (class 2604 OID 77335)
-- Dependencies: 277 278 278
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY detalle_interes ALTER COLUMN id SET DEFAULT nextval('detalle_interes_id_seq'::regclass);


--
-- TOC entry 2553 (class 2604 OID 78844)
-- Dependencies: 280 279 280
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY detalle_interes_viejo ALTER COLUMN id SET DEFAULT nextval('detalle_interes_id_seq1'::regclass);


--
-- TOC entry 2587 (class 2604 OID 87645)
-- Dependencies: 299 298 299
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY detalles_contrib_calc ALTER COLUMN id SET DEFAULT nextval('detalles_contrib_calc_id_seq'::regclass);


--
-- TOC entry 2567 (class 2604 OID 79065)
-- Dependencies: 287 286 287
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY dettalles_fizcalizacion ALTER COLUMN id SET DEFAULT nextval('dettalles_fizcalizacion_id_seq'::regclass);


--
-- TOC entry 2507 (class 2604 OID 20839)
-- Dependencies: 236 235
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY document ALTER COLUMN id SET DEFAULT nextval('document_id_seq'::regclass);


--
-- TOC entry 2471 (class 2604 OID 20840)
-- Dependencies: 203 202
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY entidad ALTER COLUMN id SET DEFAULT nextval('"Entidad_IDEntidad_seq"'::regclass);


--
-- TOC entry 2469 (class 2604 OID 20841)
-- Dependencies: 201 200
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY entidadd ALTER COLUMN id SET DEFAULT nextval('"EntidadD_IDEntidadD_seq"'::regclass);


--
-- TOC entry 2472 (class 2604 OID 20842)
-- Dependencies: 205 204
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY estados ALTER COLUMN id SET DEFAULT nextval('"Estados_IDEstado_seq"'::regclass);


--
-- TOC entry 2551 (class 2604 OID 77293)
-- Dependencies: 276 275
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY interes_bcv ALTER COLUMN id SET DEFAULT nextval('interes_bcv_id_seq'::regclass);


--
-- TOC entry 2475 (class 2604 OID 20843)
-- Dependencies: 209 208
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY perusu ALTER COLUMN id SET DEFAULT nextval('"PerUsu_IDPerUsu_seq"'::regclass);


--
-- TOC entry 2473 (class 2604 OID 20844)
-- Dependencies: 207 206
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY perusud ALTER COLUMN id SET DEFAULT nextval('"PerUsuD_IDPerUsuD_seq"'::regclass);


--
-- TOC entry 2476 (class 2604 OID 20845)
-- Dependencies: 211 210
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY pregsecr ALTER COLUMN id SET DEFAULT nextval('"PregSecr_IDPregSecr_seq"'::regclass);


--
-- TOC entry 2592 (class 2604 OID 87768)
-- Dependencies: 302 303 303
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY presidente ALTER COLUMN id SET DEFAULT nextval('presidente_id_seq'::regclass);


--
-- TOC entry 2477 (class 2604 OID 20846)
-- Dependencies: 213 212
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY replegal ALTER COLUMN id SET DEFAULT nextval('"RepLegal_IDRepLegal_seq"'::regclass);


--
-- TOC entry 2478 (class 2604 OID 20847)
-- Dependencies: 215 214
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tdeclara ALTER COLUMN id SET DEFAULT nextval('"TDeclara_IDTDeclara_seq"'::regclass);


--
-- TOC entry 2481 (class 2604 OID 20848)
-- Dependencies: 217 216
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tipegrav ALTER COLUMN id SET DEFAULT nextval('"TiPeGrav_IDTiPeGrav_seq"'::regclass);


--
-- TOC entry 2482 (class 2604 OID 20849)
-- Dependencies: 219 218
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tipocont ALTER COLUMN id SET DEFAULT nextval('"TipoCont_IDTipoCont_seq"'::regclass);


--
-- TOC entry 2484 (class 2604 OID 20850)
-- Dependencies: 221 220
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY undtrib ALTER COLUMN id SET DEFAULT nextval('"UndTrib_IDUndTrib_seq"'::regclass);


--
-- TOC entry 2488 (class 2604 OID 20851)
-- Dependencies: 225 224
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY usfonpro ALTER COLUMN id SET DEFAULT nextval('"Usuarios_IDUsuario_seq"'::regclass);


--
-- TOC entry 2486 (class 2604 OID 20852)
-- Dependencies: 223 222
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY usfonpto ALTER COLUMN id SET DEFAULT nextval('"UsFonpTo_IDUsFonpTo_seq"'::regclass);


SET search_path = historial, pg_catalog;

--
-- TOC entry 2515 (class 2604 OID 20853)
-- Dependencies: 241 240
-- Name: id; Type: DEFAULT; Schema: historial; Owner: postgres
--

ALTER TABLE ONLY bitacora ALTER COLUMN id SET DEFAULT nextval('"Bitacora_IDBitacora_seq"'::regclass);


SET search_path = pre_aprobacion, pg_catalog;

--
-- TOC entry 2577 (class 2604 OID 87501)
-- Dependencies: 293 292 293
-- Name: id; Type: DEFAULT; Schema: pre_aprobacion; Owner: postgres
--

ALTER TABLE ONLY datos_cnac ALTER COLUMN id SET DEFAULT nextval('datos_cnac_id_seq'::regclass);


--
-- TOC entry 2549 (class 2604 OID 77272)
-- Dependencies: 274 273 274
-- Name: id; Type: DEFAULT; Schema: pre_aprobacion; Owner: postgres
--

ALTER TABLE ONLY intereses ALTER COLUMN id SET DEFAULT nextval('intereses_id_seq'::regclass);


--
-- TOC entry 2548 (class 2604 OID 77251)
-- Dependencies: 272 271 272
-- Name: id; Type: DEFAULT; Schema: pre_aprobacion; Owner: postgres
--

ALTER TABLE ONLY multas ALTER COLUMN id SET DEFAULT nextval('multas_id_seq'::regclass);


SET search_path = seg, pg_catalog;

--
-- TOC entry 2585 (class 2604 OID 87610)
-- Dependencies: 296 297 297
-- Name: id; Type: DEFAULT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_cargos ALTER COLUMN id SET DEFAULT nextval('tbl_cargos_id_seq'::regclass);


--
-- TOC entry 2516 (class 2604 OID 21608)
-- Dependencies: 243 242
-- Name: id_modulo; Type: DEFAULT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_modulo ALTER COLUMN id_modulo SET DEFAULT nextval('tbl_modulo_id_modulo_seq'::regclass);


--
-- TOC entry 2582 (class 2604 OID 87571)
-- Dependencies: 295 294 295
-- Name: id; Type: DEFAULT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_oficinas ALTER COLUMN id SET DEFAULT nextval('tbl_oficinas_id_seq'::regclass);


--
-- TOC entry 2518 (class 2604 OID 21609)
-- Dependencies: 245 244
-- Name: id_permiso; Type: DEFAULT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_permiso ALTER COLUMN id_permiso SET DEFAULT nextval('tbl_permiso_id_permiso_seq'::regclass);


--
-- TOC entry 2554 (class 2604 OID 78881)
-- Dependencies: 281 282 282
-- Name: id_permiso; Type: DEFAULT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_permiso_trampa ALTER COLUMN id_permiso SET DEFAULT nextval('tbl_permiso_trampa_id_permiso_seq'::regclass);


--
-- TOC entry 2520 (class 2604 OID 21610)
-- Dependencies: 247 246
-- Name: id_rol; Type: DEFAULT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_rol ALTER COLUMN id_rol SET DEFAULT nextval('tbl_rol_id_rol_seq'::regclass);


--
-- TOC entry 2522 (class 2604 OID 21611)
-- Dependencies: 249 248
-- Name: id_rol_usuario; Type: DEFAULT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_rol_usuario ALTER COLUMN id_rol_usuario SET DEFAULT nextval('tbl_rol_usuario_id_rol_usuario_seq'::regclass);


--
-- TOC entry 2528 (class 2604 OID 21612)
-- Dependencies: 252 251
-- Name: id_usuario_rol; Type: DEFAULT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_usuario_rol ALTER COLUMN id_usuario_rol SET DEFAULT nextval('tbl_usuario_rol_id_usuario_rol_seq'::regclass);


SET search_path = "segContribu", pg_catalog;

--
-- TOC entry 2530 (class 2604 OID 22895)
-- Dependencies: 259 255
-- Name: id_modulo; Type: DEFAULT; Schema: segContribu; Owner: postgres
--

ALTER TABLE ONLY tbl_modulo_contribu ALTER COLUMN id_modulo SET DEFAULT nextval('tbl_modulo_id_modulo_seq'::regclass);


--
-- TOC entry 2532 (class 2604 OID 22896)
-- Dependencies: 260 256
-- Name: id_permiso; Type: DEFAULT; Schema: segContribu; Owner: postgres
--

ALTER TABLE ONLY tbl_permiso_contribu ALTER COLUMN id_permiso SET DEFAULT nextval('tbl_permiso_id_permiso_seq'::regclass);


--
-- TOC entry 2534 (class 2604 OID 22897)
-- Dependencies: 261 257
-- Name: id_rol; Type: DEFAULT; Schema: segContribu; Owner: postgres
--

ALTER TABLE ONLY tbl_rol_contribu ALTER COLUMN id_rol SET DEFAULT nextval('tbl_rol_id_rol_seq'::regclass);


--
-- TOC entry 2536 (class 2604 OID 22898)
-- Dependencies: 262 258
-- Name: id_rol_usuario; Type: DEFAULT; Schema: segContribu; Owner: postgres
--

ALTER TABLE ONLY tbl_rol_usuario_contribu ALTER COLUMN id_rol_usuario SET DEFAULT nextval('tbl_rol_usuario_id_rol_usuario_seq'::regclass);


--
-- TOC entry 2538 (class 2604 OID 22899)
-- Dependencies: 264 263
-- Name: id_usuario_rol; Type: DEFAULT; Schema: segContribu; Owner: postgres
--

ALTER TABLE ONLY tbl_usuario_rol_contribu ALTER COLUMN id_usuario_rol SET DEFAULT nextval('tbl_usuario_rol_id_usuario_rol_seq'::regclass);


SET search_path = datos, pg_catalog;

--
-- TOC entry 3858 (class 0 OID 0)
-- Dependencies: 166
-- Name: Accionis_ID_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Accionis_ID_seq"', 74, true);


--
-- TOC entry 3859 (class 0 OID 0)
-- Dependencies: 168
-- Name: ActiEcon_IDActiEcon_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"ActiEcon_IDActiEcon_seq"', 9, true);


--
-- TOC entry 3860 (class 0 OID 0)
-- Dependencies: 170
-- Name: AlicImp_IDAlicImp_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"AlicImp_IDAlicImp_seq"', 11, true);


--
-- TOC entry 3861 (class 0 OID 0)
-- Dependencies: 172
-- Name: AsientoD_IDAsientoD_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"AsientoD_IDAsientoD_seq"', 6, true);


--
-- TOC entry 3862 (class 0 OID 0)
-- Dependencies: 173
-- Name: Asiento_IDAsiento_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Asiento_IDAsiento_seq"', 2, true);


--
-- TOC entry 3863 (class 0 OID 0)
-- Dependencies: 175
-- Name: BaCuenta_IDBaCuenta_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"BaCuenta_IDBaCuenta_seq"', 1, false);


--
-- TOC entry 3864 (class 0 OID 0)
-- Dependencies: 177
-- Name: Bancos_IDBanco_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Bancos_IDBanco_seq"', 1, false);


--
-- TOC entry 3865 (class 0 OID 0)
-- Dependencies: 179
-- Name: CalPagoD_IDCalPagoD_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"CalPagoD_IDCalPagoD_seq"', 365, true);


--
-- TOC entry 3866 (class 0 OID 0)
-- Dependencies: 181
-- Name: CalPagos_IDCalPago_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"CalPagos_IDCalPago_seq"', 51, true);


--
-- TOC entry 3867 (class 0 OID 0)
-- Dependencies: 183
-- Name: Cargos_IDCargo_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Cargos_IDCargo_seq"', 16, true);


--
-- TOC entry 3868 (class 0 OID 0)
-- Dependencies: 185
-- Name: Ciudades_IDCiudad_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Ciudades_IDCiudad_seq"', 360, true);


--
-- TOC entry 3869 (class 0 OID 0)
-- Dependencies: 187
-- Name: ConUsuCo_IDConUsuCo_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"ConUsuCo_IDConUsuCo_seq"', 1, false);


--
-- TOC entry 3870 (class 0 OID 0)
-- Dependencies: 189
-- Name: ConUsuTi_IDConUsuTi_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"ConUsuTi_IDConUsuTi_seq"', 1, true);


--
-- TOC entry 3871 (class 0 OID 0)
-- Dependencies: 191
-- Name: ConUsuTo_IDConUsuTo_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"ConUsuTo_IDConUsuTo_seq"', 130, true);


--
-- TOC entry 3872 (class 0 OID 0)
-- Dependencies: 193
-- Name: ConUsu_IDConUsu_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"ConUsu_IDConUsu_seq"', 70, true);


--
-- TOC entry 3873 (class 0 OID 0)
-- Dependencies: 195
-- Name: Contribu_IDContribu_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Contribu_IDContribu_seq"', 24, true);


--
-- TOC entry 3874 (class 0 OID 0)
-- Dependencies: 197
-- Name: Declara_IDDeclara_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Declara_IDDeclara_seq"', 243, true);


--
-- TOC entry 3875 (class 0 OID 0)
-- Dependencies: 199
-- Name: Departam_IDDepartam_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Departam_IDDepartam_seq"', 10, true);


--
-- TOC entry 3876 (class 0 OID 0)
-- Dependencies: 201
-- Name: EntidadD_IDEntidadD_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"EntidadD_IDEntidadD_seq"', 1, false);


--
-- TOC entry 3877 (class 0 OID 0)
-- Dependencies: 203
-- Name: Entidad_IDEntidad_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Entidad_IDEntidad_seq"', 1, false);


--
-- TOC entry 3878 (class 0 OID 0)
-- Dependencies: 205
-- Name: Estados_IDEstado_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Estados_IDEstado_seq"', 27, true);


--
-- TOC entry 3879 (class 0 OID 0)
-- Dependencies: 207
-- Name: PerUsuD_IDPerUsuD_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"PerUsuD_IDPerUsuD_seq"', 1, false);


--
-- TOC entry 3880 (class 0 OID 0)
-- Dependencies: 209
-- Name: PerUsu_IDPerUsu_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"PerUsu_IDPerUsu_seq"', 1, false);


--
-- TOC entry 3881 (class 0 OID 0)
-- Dependencies: 211
-- Name: PregSecr_IDPregSecr_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"PregSecr_IDPregSecr_seq"', 7, true);


--
-- TOC entry 3882 (class 0 OID 0)
-- Dependencies: 213
-- Name: RepLegal_IDRepLegal_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"RepLegal_IDRepLegal_seq"', 6, true);


--
-- TOC entry 3883 (class 0 OID 0)
-- Dependencies: 215
-- Name: TDeclara_IDTDeclara_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"TDeclara_IDTDeclara_seq"', 7, true);


--
-- TOC entry 3884 (class 0 OID 0)
-- Dependencies: 217
-- Name: TiPeGrav_IDTiPeGrav_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"TiPeGrav_IDTiPeGrav_seq"', 6, true);


--
-- TOC entry 3885 (class 0 OID 0)
-- Dependencies: 219
-- Name: TipoCont_IDTipoCont_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"TipoCont_IDTipoCont_seq"', 6, true);


--
-- TOC entry 3886 (class 0 OID 0)
-- Dependencies: 221
-- Name: UndTrib_IDUndTrib_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"UndTrib_IDUndTrib_seq"', 24, true);


--
-- TOC entry 3887 (class 0 OID 0)
-- Dependencies: 223
-- Name: UsFonpTo_IDUsFonpTo_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"UsFonpTo_IDUsFonpTo_seq"', 1, false);


--
-- TOC entry 3888 (class 0 OID 0)
-- Dependencies: 225
-- Name: Usuarios_IDUsuario_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Usuarios_IDUsuario_seq"', 50, true);


--
-- TOC entry 3177 (class 0 OID 20731)
-- Dependencies: 226 3254
-- Data for Name: accionis; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY accionis (id, contribuid, nombre, apellido, ci, domfiscal, nuacciones, valaccion, cextra1, cextra2, cextra3, cextra4, cextra5, usuarioid, ip) FROM stdin;
38	45	dsf	sdfs	45	dsfdf	545	45.00	\N	\N	\N	\N	\N	17	192.168.1.102
39	45	et	ert	46446	retert	1000	45645.00	\N	\N	\N	\N	\N	17	192.168.1.102
15	2	frederick	bustamante	15100387	la victoria	500	10000.00	\N	\N	\N	\N	\N	\N	192.168.1.101
8	43	jefferosn	lara	17042979	aqui	100	5000.00	\N	\N	\N	\N	\N	\N	192.168.1.101
16	2	jjjj	jjjjj	ddfd	jhjjjjq	4	1000.00	\N	\N	\N	\N	\N	\N	192.168.1.101
17	2	dgffdg	fdgfd	1235896	fdgfd	11	1.00	\N	\N	\N	\N	\N	\N	192.168.1.101
19	43	prueba	prueba	123456	prueba	100	10.00	\N	\N	\N	\N	\N	\N	192.168.1.101
40	45	ukk	8i8k	566	54657	5678	46.00	\N	\N	\N	\N	\N	\N	192.168.1.102
42	45	gh	fgh	446	fgh	4545	454.00	\N	\N	\N	\N	\N	\N	192.168.1.102
43	43	ttt	tttt	11111111	gfsdfsdfs	200	5000.00	\N	\N	\N	\N	\N	\N	192.168.1.101
44	62	yo	o	17042979	yo	1000	10000.00	\N	\N	\N	\N	\N	\N	192.168.1.101
45	70	Yuneray	Valladares	15941106	Valera	4	1000.00	\N	\N	\N	\N	\N	\N	192.168.1.103
46	44	Ricardo	Laos	18236546	el mismo	2000	1000.00	\N	\N	\N	\N	\N	\N	192.168.1.100
47	44	Arturo	Laos	81620470	el mismo	5000	1000.00	\N	\N	\N	\N	\N	\N	192.168.1.100
\.


--
-- TOC entry 3118 (class 0 OID 20526)
-- Dependencies: 167 3254
-- Data for Name: actiecon; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY actiecon (id, nombre, usuarioid, ip) FROM stdin;
4	EXHIBIDOR	16	192.168.1.102
5	TV SEÑAL ABIERTA	16	192.168.1.102
6	TV SUSCRIPCION	16	192.168.1.102
7	DISTRIBUIDORES	16	192.168.1.102
8	VENTA Y ALQUILER	16	192.168.1.102
9	SERVICIOS PARA LA PRODUCCION	16	192.168.1.102
\.


--
-- TOC entry 3120 (class 0 OID 20531)
-- Dependencies: 169 3254
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
-- TOC entry 3178 (class 0 OID 20740)
-- Dependencies: 227 3254
-- Data for Name: asiento; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY asiento (id, nuasiento, fecha, mes, ano, debe, haber, saldo, comentar, cerrado, uscierreid, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 3122 (class 0 OID 20547)
-- Dependencies: 171 3254
-- Data for Name: asientod; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY asientod (id, asientoid, fecha, cuenta, monto, sentido, referencia, comentar, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 3179 (class 0 OID 20754)
-- Dependencies: 228 3254
-- Data for Name: asientom; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY asientom (id, nombre, comentar, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 3889 (class 0 OID 0)
-- Dependencies: 229
-- Name: asientom_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('asientom_id_seq', 1, false);


--
-- TOC entry 3181 (class 0 OID 20762)
-- Dependencies: 230 3254
-- Data for Name: asientomd; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY asientomd (id, asientomid, cuenta, sentido, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 3890 (class 0 OID 0)
-- Dependencies: 231
-- Name: asientomd_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('asientomd_id_seq', 1, false);


--
-- TOC entry 3232 (class 0 OID 78903)
-- Dependencies: 284 3254
-- Data for Name: asignacion_fiscales; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY asignacion_fiscales (id, fecha_asignacion, usfonproid, conusuid, prioridad, estatus, fecha_fiscalizacion, usuarioid, ip, tipocontid, nro_autorizacion, periodo_afiscalizar) FROM stdin;
936	2013-06-27	48	44	t	1	2013-07-18	48	192.168.1.101	4	17-2013	2007
937	2013-06-27	48	45	t	1	2013-07-24	48	192.168.1.101	3	18-2013	2009
116	2013-06-03	48	45	t	2	2013-06-28	48	192.168.1.101	3	\N	\N
929	2013-06-26	48	43	t	1	2013-07-17	48	192.168.1.101	1	10-2013	2012
930	2013-06-26	48	43	t	1	2013-07-17	48	192.168.1.101	1	11-2013	2006
931	2013-06-26	48	45	t	1	2013-07-17	48	192.168.1.101	2	12-2013	2010
932	2013-06-27	48	46	t	1	2013-06-19	48	192.168.1.101	1	13-2013	2013
933	2013-06-27	17	45	f	1	2013-06-27	48	192.168.1.101	2	14-2013	2008
934	2013-06-27	17	45	f	1	2013-06-27	48	192.168.1.101	2	15-2013	2012
935	2013-06-27	17	47	f	1	2013-06-27	48	192.168.1.101	1	16-2013	2013
\.


--
-- TOC entry 3891 (class 0 OID 0)
-- Dependencies: 283
-- Name: asignacion_fiscales_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('asignacion_fiscales_id_seq', 937, true);


--
-- TOC entry 3125 (class 0 OID 20559)
-- Dependencies: 174 3254
-- Data for Name: bacuenta; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY bacuenta (id, bancoid, cuenta, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 3127 (class 0 OID 20564)
-- Dependencies: 176 3254
-- Data for Name: bancos; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY bancos (id, nombre, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 3131 (class 0 OID 20574)
-- Dependencies: 180 3254
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
-- TOC entry 3129 (class 0 OID 20569)
-- Dependencies: 178 3254
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
-- TOC entry 3133 (class 0 OID 20580)
-- Dependencies: 182 3254
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
-- TOC entry 3135 (class 0 OID 20585)
-- Dependencies: 184 3254
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
-- TOC entry 3215 (class 0 OID 46443)
-- Dependencies: 267 3254
-- Data for Name: con_img_doc; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY con_img_doc (id, conusuid, descripcion, usuarioid, ip, ruta_imagen, fecha) FROM stdin;
105	55	cedula	55	192.168.1.102	4edbcc3fb9cf192482c51e46d2d1efb5.png	2013-03-11
87	45	sfdg	45	192.168.1.102	d5f72a50dadedec16183c3b42943abcc.png	2013-02-15
88	45	fg	45	192.168.1.102	5ad5ce8536a386b9f270639ce423f0f3.png	2013-02-15
89	45	ghj	45	192.168.1.102	3fdeed0aa3b4622f4f744f457fdd33f1.png	2013-02-15
92	45	fdg	45	192.168.1.102	568acfe61208ac8fbc78c815afc9fe62.png	2013-02-15
93	45	dsf	45	192.168.1.102	2674438e79be4aa4c37f6641b18d64ab.png	2013-02-15
94	45	sdf	45	192.168.1.102	1718a3f1072a214295f7e870e6cccb49.png	2013-02-15
95	45	dfgf	45	192.168.1.102	729edc23bcc7817abb17e8a3ecfc010f.png	2013-02-15
96	45	sdf	45	192.168.1.102	194bfcc96984baf3e02139a7dab6b2d9.png	2013-02-15
97	45	df	45	192.168.1.102	fea5fcb3cf675c679dbbd7fa981a6143.png	2013-02-15
98	45	df	45	192.168.1.102	c807b2704dd7ee155f2885b7c67ddef6.png	2013-02-15
99	45	dfg	45	192.168.1.102	d0649b7a1bc31709c97bce3044ca3db4.png	2013-02-15
100	43	prueba cedula	43	192.168.1.102	5ba3660e9daef3eae5fbf502dd513b4d.png	2013-02-15
101	45	ret	45	192.168.1.102	05a352a024b33dcce4c298a1496e1dd0.png	2013-02-19
102	45	fthfgh	45	192.168.1.102	4e644bb564fd73ab43f9703cb09b8b4e.png	2013-02-19
103	45	tyuty	45	192.168.1.102	fb428f4a021d78f3022e94e3d8a6757e.png	2013-02-19
104	45	tyghj	45	192.168.1.102	935e7b1435948897bb55a22062ca9cfb.png	2013-02-19
\.


--
-- TOC entry 3892 (class 0 OID 0)
-- Dependencies: 266
-- Name: con_img_doc_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('con_img_doc_id_seq', 106, true);


--
-- TOC entry 3239 (class 0 OID 79221)
-- Dependencies: 291 3254
-- Data for Name: contrib_calc; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY contrib_calc (id, conusuid, usuarioid, ip, tipocontid, fecha_registro_fila, fecha_notificacion, proceso) FROM stdin;
142	45	48	192.168.1.101	1	2013-05-29 16:57:21.185043	\N	calculado
141	45	48	192.168.1.101	3	2013-05-29 16:27:47.16541	\N	calculado
143	45	48	192.168.1.101	5	2013-05-29 16:57:21.185043	\N	calculado
145	70	48	192.168.1.101	1	2013-06-04 15:32:12.561671	\N	calculado
144	45	48	192.168.1.101	4	2013-05-29 16:57:21.185043	\N	calculado
146	43	48	192.168.1.101	4	2013-06-11 11:02:54.083989	\N	enviado
147	45	48	192.168.1.101	2	2013-06-11 11:02:54.083989	\N	enviado
148	46	48	192.168.1.101	4	2013-06-11 11:02:54.083989	\N	enviado
\.


--
-- TOC entry 3893 (class 0 OID 0)
-- Dependencies: 290
-- Name: contrib_calc_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('contrib_calc_id_seq', 148, true);


--
-- TOC entry 3145 (class 0 OID 20621)
-- Dependencies: 194 3254
-- Data for Name: contribu; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY contribu (id, razonsocia, dencomerci, actieconid, rif, numregcine, domfiscal, estadoid, ciudadid, zonapostal, telef1, telef2, telef3, fax1, fax2, email, pinbb, skype, twitter, facebook, nuacciones, valaccion, capitalsus, capitalpag, regmerofc, rmnumero, rmfolio, rmtomo, rmfechapro, rmncontrol, rmobjeto, domcomer, cextra1, cextra2, cextra3, cextra4, cextra5, usuarioid, ip) FROM stdin;
5	CARLENYS CLARET VILLANUEVA PEREZ 	CARLENYS CLARET VILLANUEVA PEREZ C.A	7	V171743270	2550	URBANIZACIóN LA MORA 2, RESIDENCIAS VILLAVICA, CALLE NUMERO 18, CASA NUMERO 33, LA VICTORIA, ESTADO ARAGUA	7	43	2121	0244-3216647	0246-4314229	0414-4666418	0244-3216647		frederickdanielb@hotmail.com	dddddddd	carlenysvS	carlenysvT	www.facebook.com/carlenysv	78	144.00	50000.00	30000.00	el consejo	25689	45	4569	2012-10-04	5666	genericos y otros	URBANIZACIóN LA MORA 2, RESIDENCIAS VILLAVICA, CALLE NUMERO 18, CASA NUMERO 33, LA VICTORIA, ESTADO ARAGUA	\N	\N	\N	\N	\N	52	192.168.1.102
3	FREDERICK DANIEL BUSTAMANTE GONZALEZ	FREDERICK CA	4	V153938594	562	LA VICTORIA ESTADO ARAGUA	14	151	2121	0244-3216647	0246-4314229	0414-2680489	0244-8889999		frederickdanielb@gmail.com	android	frederickS	frederickT	frederickF	1000	2034564.00	65888.00	8.00	el centro	54	88	99	2012-06-04	8	personal		\N	\N	\N	\N	\N	45	192.168.1.102
13	WENDY YANITZA GUERRA PEREZ	JEDLYS	4	V151001005	1002	BOCONÓ-TRUJILLO	23	304	3101	0416-1319739	0416-0799712				spvsr8@gmail.com					1	1000.00	10000.00	5000.00	LCT	8	4	2	2013-01-25	2	COMERCIAL	VALERA-TRUJILLO	\N	\N	\N	\N	\N	54	192.168.1.102
11	LAOS COMPUTER TECHNOLOGY, C.A. (LAOS COMPUTER TECHNOLOGY, C.A.)	JEDLYS	4	J314725645	1001	BOCONÓ-TRUJILLO	23	304	3101	0416-1319739	0416-0799712				spvsr8@gmail.com					1	1000.00	10000.00	5000.00	LCT	8	4	2	2013-01-25	2	COMERCIAL	VALERA-TRUJILLO	\N	\N	\N	\N	\N	47	192.168.1.102
15	CARLENYS CLARET VILLANUEVA PEREZ	JEDLYS	4	V171743271	1003	BOCONÓ-TRUJILLO	23	304	3101	0416-1319739	0416-0799712				spvsr8@gmail.com					1	1000.00	10000.00	5000.00	LCT	8	4	2	2013-01-25	2	COMERCIAL	VALERA-TRUJILLO	\N	\N	\N	\N	\N	55	192.168.1.102
4	JEDLYS, C.A.	JEDLYS	4	V17829273	1111	BOCONÓ-TRUJILLO	23	304	3101	0416-1319739	0416-0799712				spvsr8@gmail.com					1	1000.00	10000.00	5000.00	LCT	785	4	2	2013-01-25	2	COMERCIAL	VALERA-TRUJILLO	\N	\N	\N	\N	\N	46	192.168.1.103
21	GRUPO INFOGUIANET,C.A (GRUPO INFOGUIANET C.A.)	GRUPO INFOGUIANET,C.A (GRUPO INFOGUIANET C.A.)	6	J308058238	85	NO SE	10	94	0254	0412-0428211					jeto_21@hotmail.com					1000	10000.00	10000.00	850000.00	no se	0125	0125	85	2012-11-22	2	no se	NO SE	\N	\N	\N	\N	\N	62	192.168.1.101
24	SILVIA PATRICIA VALLADARES SANDOVAL	TECNOLOGíA	4	V178292737	5	BOCONó, TRUJILLO	23	322	3101	0416-0799712					spvsr8@gmail.com					4	1000.00	20000.00	20000.00	Valera	NRSPVS	008	001	2009-05-24	002	Desarrollo		\N	\N	\N	\N	\N	70	192.168.1.103
2	JEFFERSON ARTURO LARA MOLINA	PRUEBA	4	V170429792	1	SANTA RITA CALLE JUNIN VEREDAD DOS CASA NUMERO 10 MUNICIPIO FRANCISCO LINARES ALCANTARASANTA RITA CALLE JUNIN VEREDAD DOS CASA NUMERO 10 MUNICIPIO FRANCISCO LINARES ALCANTARA PPPPP	7	55	0212	0412-0428211					jetox21@gmail.com				www.facebook.com/jefferosn	1000	50.00	500000.00	250000.00	REGISTRO PRINCIPAL MARACAY ESTADO ARAGUA	2013/REG-25	20	95	2012-01-26	1000	prestacion de servicio de television por cable	SANTA RITA CALLE JUNIN VEREDAD DOS CASA NUMERO 10 MUNICIPIO FRANCISCO LINARES ALCANTARA	\N	\N	\N	\N	\N	43	192.168.1.101
10	ARTURO MARIO LAOS MELGAR	LAOS	4	E816204707	1000	CARACAS	23	1	2121	0272-5760355	0416-0799777		0212-5763604		arturo.laos@gmail.com		arturo.laos		arturo.laos	7000	80000.00	10000.00	5000.00	LCT	8 de Caracas	43	2	2013-01-25	2	COMERCIAL	VALERA-TRUJILLO	\N	\N	\N	\N	\N	44	192.168.1.100
\.


--
-- TOC entry 3183 (class 0 OID 20768)
-- Dependencies: 232 3254
-- Data for Name: contributi; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY contributi (id, contribuid, tipocontid, ip) FROM stdin;
\.


--
-- TOC entry 3894 (class 0 OID 0)
-- Dependencies: 233
-- Name: contributi_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('contributi_id_seq', 1, false);


--
-- TOC entry 3143 (class 0 OID 20612)
-- Dependencies: 192 3254
-- Data for Name: conusu; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY conusu (id, login, password, nombre, inactivo, conusutiid, email, pregsecrid, respuesta, ultlogin, usuarioid, ip, rif, validado, fecha_registro) FROM stdin;
48	gdfgdfg	7c4a8d09ca3762af61e59520943dc26494f8941b	CARLENYS CLARET VILLANUEVA PEREZ	t	1	dfgdfgdfg	1	tequila	2013-02-01 16:20:40.938163	\N	192.168.1.102	gdfgdfg	f	2013-03-14
50	dfgdfgdfgdfg	7c4a8d09ca3762af61e59520943dc26494f8941b	CARLENYS CLARET VILLANUEVA PEREZ	t	1	ertfdghj	1	tequila	2013-02-01 16:25:28.043609	\N	192.168.1.102	ertert	f	2013-03-14
51	vbnvbn	7c4a8d09ca3762af61e59520943dc26494f8941b	CARLENYS CLARET VILLANUEVA PEREZ	t	1	vbnvbnvbn	1	tequila	2013-02-01 16:29:20.602782	\N	192.168.1.102	ghjghjtyu	f	2013-03-14
53	ghjghjghj	7c4a8d09ca3762af61e59520943dc26494f8941b	ghjghjghj	t	1	hgfjghj	4	dfgdfgdf	\N	\N	192.168.1.102	dfgdfgdfgd	f	2013-03-14
18	hj	v170429792	JEFFERSON ARTURO LARA MOLINA	t	1	ghghgh	1	fgfgfgffg	2013-01-18 17:25:51.303327	\N	192.168.1.102	m	f	2013-03-14
19	fffghfgh	v170429792	JEFFERSON ARTURO LARA MOLINA	t	1	fghghgh	1	fgfgfgffg	2013-01-18 17:27:01.458254	\N	192.168.1.102	k	f	2013-03-14
17	dfdg	v170429792	JEFFERSON ARTURO LARA MOLINA	t	1	ghghghgh	5	pizza	2013-01-18 17:20:05.92077	\N	192.168.1.102	n	f	2013-03-14
20	ff	v170429792	JEFFERSON ARTURO LARA MOLINA	t	1	fghfghfgh	1	fgfgfgffg	2013-01-18 17:34:28.045315	\N	192.168.1.102	lo	f	2013-03-14
2	fdg	123456	ROSA MELTROSO	t	1	dfg	2	MI MAMA ME MIMA MUCHO	\N	16	192.168.1.102	q	f	2013-03-14
65	jeto_21@hotmail.com	7c4a8d09ca3762af61e59520943dc26494f8941b	MOVIMIENTO PRIMERO JUSTICIA (MOVIMINETO PRIMERO JUSTICIA)	t	1	jeto_21@hotmail.com	2	hola	2013-05-21 12:00:04.104904	\N	192.168.1.101	J313252700	t	2013-03-14
21	878787	v170429792	JEFFERSON ARTURO LARA MOLINA	t	1	uyiuyiuy	2	878	2013-01-21 10:28:02.369281	\N	192.168.1.102	ty	f	2013-03-14
22	fghfghfghfgh	v170429792	JEFFERSON ARTURO LARA MOLINA	t	1	utyughfgh	2	878	2013-01-21 10:31:03.170657	\N	192.168.1.102	po	f	2013-03-14
23	34534534	v170429792	JEFFERSON ARTURO LARA MOLINA	t	1	34534534	2	878	2013-01-21 10:36:02.91059	\N	192.168.1.102	rt	f	2013-03-14
24	dfgdfgdfg	v170429792	JEFFERSON ARTURO LARA MOLINA	t	1	dfgdfgdf	2	878	2013-01-21 10:40:54.290183	\N	192.168.1.102	rt	f	2013-03-14
25	hjghjghjtyuty	v170429792	JEFFERSON ARTURO LARA MOLINA	t	1	ghjghghkghk	2	878	2013-01-21 10:43:03.294971	\N	192.168.1.102	df	f	2013-03-14
26	rey567	v170429792	JEFFERSON ARTURO LARA MOLINA	t	1	567tyrt	2	878	2013-01-21 10:56:16.201378	\N	192.168.1.102	dg	f	2013-03-14
27	dsfgsdgdfgdfg	v170429792	JEFFERSON ARTURO LARA MOLINA	t	1	dfgdfgdfgdftg45	2	878	2013-01-21 10:58:45.758251	\N	192.168.1.102	er	f	2013-03-14
28	dfgdfgret	v170429792	JEFFERSON ARTURO LARA MOLINA	t	1	dfgfbvc	2	878	2013-01-21 11:06:23.525337	\N	192.168.1.102	rtrtrtr	f	2013-03-14
31	rtyryrtyfgdf	v170429792	JEFFERSON ARTURO LARA MOLINA	t	1	dfgdfg	2	878	2013-01-21 13:28:06.419436	\N	192.168.1.102	trtrtrt	f	2013-03-14
32	retretdfgdfg	v170429792	JEFFERSON ARTURO LARA MOLINA	t	1	fgdfgretry	2	878	2013-01-21 13:41:37.971422	\N	192.168.1.102	gfhguy	f	2013-03-14
33	xcvxcvxcvxcvcxv	v170429792	JEFFERSON ARTURO LARA MOLINA	t	1	xcvxcvxcvxcvcxv	2	878	2013-01-21 13:47:59.167487	\N	192.168.1.102	zxcxzvxcvdfter	f	2013-03-14
42	ghghjhgj	v170429792	JEFFERSON ARTURO LARA MOLINA	t	1	ghjghjghjghjgh	2	878	2013-01-21 15:09:10.943043	\N	192.168.1.102	ghjghjghjgj	f	2013-03-14
45	frederickdanielb@gmail.com	7c4a8d09ca3762af61e59520943dc26494f8941b	FREDERICK DANIEL BUSTAMANTE GONZALEZ	f	1	frederickdanielb@gmail.com	2	yopo	2013-01-22 16:04:17.96858	\N	192.168.1.102	V153938594	t	2008-03-14
43	jetox21@gmail.com	7c4a8d09ca3762af61e59520943dc26494f8941b	JEFFERSON ARTURO LARA MOLINA	f	1	jetox21@gmail.com	1	que tal	2013-01-21 16:56:41.000428	\N	192.168.1.101	V170429792	t	2006-05-14
54	frederickdanielb@yahoo.es	7c4a8d09ca3762af61e59520943dc26494f8941b	WENDY YANITZA GUERRA PEREZ	f	1	frederickdanielb@yahoo.es	4	hola	2013-03-11 11:52:05.042428	\N	192.168.1.102	V151001005	f	2010-03-14
52	xcvxcvxcv	7c4a8d09ca3762af61e59520943dc26494f8941b	CARLENYS CLARET VILLANUEVA PEREZ	f	1	xcvxcvxcv	2	tequila	2013-02-01 16:39:59.897766	\N	192.168.1.102	xcvxcvxcv	t	2013-03-14
47	arturo.laos@yahoo.com	1234567c4a8d09ca3762af61e59520943dc26494f8941b	LAOS COMPUTER TECHNOLOGY, C.A. (LAOS COMPUTER TECHNOLOGY, C.A.)	f	1	arturo.laos@yahoo.com	1	quien	2013-01-25 16:17:53.554135	\N	192.168.1.106	J314725645	t	2011-03-14
55	frederickdanielb@hotmail.com	7c4a8d09ca3762af61e59520943dc26494f8941b	CARLENYS CLARET VILLANUEVA PEREZ	f	1	frederickdanielb@hotmail.com	5	hol	2013-03-11 11:54:38.959854	\N	192.168.1.102	V171743271	f	2006-03-14
58	jeto21@hotmail.com	7c4a8d09ca3762af61e59520943dc26494f8941b	prueba jeto	f	1	jeto21@hotmail.com	5	prueba jeto	\N	\N	192.168.1.102	V000000011	t	2013-03-14
62	jeto_22@hotmail.com	7c4a8d09ca3762af61e59520943dc26494f8941b	GRUPO INFOGUIANET,C.A (GRUPO INFOGUIANET C.A.)	f	1	jeto_22@hotmail.com	2	hola	2013-05-14 11:27:38.868119	\N	192.168.1.101	J308058238	t	2013-03-14
46	spvs_r8@gmail.com	7c4a8d09ca3762af61e59520943dc26494f8941b	empresa la locura,c.a	f	1	spvsr_8@gmail.com	6	valladares	2013-01-25 15:59:42.119081	\N	192.168.1.101	V17829273	t	2005-03-14
70	spvsr8@gmail.com	7c4a8d09ca3762af61e59520943dc26494f8941b	SILVIA PATRICIA VALLADARES SANDOVAL	f	1	spvsr8@gmail.com	2	Pity	2013-05-24 13:39:29.608972	\N	192.168.1.103	V178292737	t	2006-05-14
44	arturo.laos@gmail.com	7c4a8d09ca3762af61e59520943dc26494f8941b	ARTURO MARIO LAOS MELGAR	f	1	arturo.laos@gmail.com	2	arturo	2013-01-22 10:02:31.854064	\N	192.168.1.106	E816204707	t	2007-03-14
\.


--
-- TOC entry 3249 (class 0 OID 87735)
-- Dependencies: 301 3254
-- Data for Name: conusu_interno; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY conusu_interno (id, fecha_entrada, conusuid, bln_fiscalizado, bln_nocontribuyente, observaciones, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 3895 (class 0 OID 0)
-- Dependencies: 300
-- Name: conusu_interno_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('conusu_interno_id_seq', 1, false);


--
-- TOC entry 3896 (class 0 OID 0)
-- Dependencies: 269
-- Name: conusu_tipocon_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('conusu_tipocon_id_seq', 34, true);


--
-- TOC entry 3218 (class 0 OID 69000)
-- Dependencies: 270 3254
-- Data for Name: conusu_tipocont; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY conusu_tipocont (id, conusuid, tipocontid, ip, fecha_elaboracion) FROM stdin;
8	46	5	192.168.1.102	2013-05-14
5	44	1	192.168.1.102	2013-05-14
10	47	1	192.168.1.102	2013-05-14
11	47	5	192.168.1.102	2013-05-14
12	54	3	192.168.1.102	2013-05-14
13	54	6	192.168.1.102	2013-05-14
14	44	4	192.168.1.102	2013-05-14
2	46	1	192.168.1.102	2013-05-14
7	43	1	192.168.1.102	2013-05-14
4	43	4	192.168.1.102	2013-05-14
6	45	2	192.168.1.102	2013-05-14
15	45	1	192.168.1.102	2013-05-14
23	62	1	192.168.1.101	2013-05-15
24	62	2	192.168.1.101	2013-05-15
25	62	6	192.168.1.101	2013-05-15
9	46	4	192.168.1.102	2013-05-14
26	70	1	192.168.1.103	2013-05-24
27	70	2	192.168.1.103	2013-05-24
28	70	3	192.168.1.103	2013-05-24
29	70	4	192.168.1.103	2013-05-24
30	70	5	192.168.1.103	2013-05-24
31	70	6	192.168.1.103	2013-05-24
34	45	3	192.168.1.102	2013-05-29
\.


--
-- TOC entry 3137 (class 0 OID 20590)
-- Dependencies: 186 3254
-- Data for Name: conusuco; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY conusuco (id, conusuid, contribuid) FROM stdin;
\.


--
-- TOC entry 3139 (class 0 OID 20595)
-- Dependencies: 188 3254
-- Data for Name: conusuti; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY conusuti (id, nombre, administra, liquida, visualiza, usuarioid, ip) FROM stdin;
1	ADMINISTRADOR	t	t	f	16	192.168.1.102
\.


--
-- TOC entry 3141 (class 0 OID 20603)
-- Dependencies: 190 3254
-- Data for Name: conusuto; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY conusuto (id, token, conusuid, fechacrea, fechacadu, usado) FROM stdin;
19	99d002ea821fdd1ec651224920caaf4b1b765bcc	21	2013-01-21 10:28:02.369281	2013-01-21 10:28:02.369281	f
20	de361fb468a932dd9049a8468e6ead3e4569c9c3	22	2013-01-21 10:31:03.170657	2013-01-21 10:31:03.170657	f
21	fb026b0c1d37910a20734db2448bdffb7b8c4199	23	2013-01-21 10:36:02.91059	2013-01-21 10:36:02.91059	f
22	a65bf042ffc5a4966aaa4816ac953ce6bb585dae	24	2013-01-21 10:40:54.290183	2013-01-21 10:40:54.290183	f
23	a22a3ca859d13e9f6900c6bc44c9cdb2fe796afd	25	2013-01-21 10:43:03.294971	2013-01-21 10:43:03.294971	f
24	ead9dfd6cb1b8b3ed8b56c9161c4226cc8d807da	26	2013-01-21 10:56:16.201378	2013-01-21 10:56:16.201378	f
25	3c915db3277d9b2638d07a33dfba6c9fa079416f	27	2013-01-21 10:58:45.758251	2013-01-21 10:58:45.758251	f
27	1a7f3ded42002d800051f9f516f7add7e090fb75	31	2013-01-21 13:28:06.419436	2013-01-21 13:28:06.419436	f
28	0526c4de82ef84a5e9376ccb2d500c55549a289d	32	2013-01-21 13:41:37.971422	2013-01-21 13:41:37.971422	f
45	597f4c0b195011b89b93914d044a20e6f3ab09da	45	2013-01-29 15:13:48.238302	2013-01-30 15:13:48.238302	t
46	f385f76c3bf72cb4e340d7e2f30742f794c0b2f3	45	2013-01-29 15:20:23.037716	2013-01-30 15:20:23.037716	f
26	4d6d9750319883043cde97efcfeb5d5621be511b	28	2013-01-21 11:06:23.525337	2013-01-21 11:06:23.525337	f
47	61b5e7671003c6540da83ff4e129d3895e16abfd	45	2013-01-30 09:32:35.859606	2013-01-31 09:32:35.859606	t
49	f2aa80c69fb44a65473c73aa6f93844db0ecbd6a	45	2013-01-30 14:04:21.387371	2013-01-31 14:04:21.387371	f
48	7d84e56ab0c3152c6b05ac5fa26268c6e3d0a995	45	2013-01-30 14:04:21.385334	2013-01-31 14:04:21.385334	f
50	a44fd7110ac154f245236d304fe58698e3bb9be5	45	2013-01-30 14:06:34.746497	2013-01-31 14:06:34.746497	f
51	c4ceaf528e6963e00a7e5d5d9cc0c1dedad1cb77	45	2013-01-30 14:06:34.766883	2013-01-31 14:06:34.766883	f
29	5f201b422f5a1dad87e3dc6ccd1cfd456a58233f	33	2013-01-21 13:47:59.167487	2013-01-21 13:47:59.167487	t
52	b5e4d7bd295d777e9e2bd9294b826ba778004f09	45	2013-01-30 14:07:20.70485	2013-01-31 14:07:20.70485	f
53	650f85555e80958369d21e7e8530f8fe0627454f	45	2013-01-30 14:07:20.728488	2013-01-31 14:07:20.728488	f
54	dd63b020f139459258cff3fe722a595f8cb7b74c	45	2013-01-30 14:07:37.529604	2013-01-31 14:07:37.529604	f
55	1bc75ccb0fcbd2e2a72610e1aa82c26ca5d0c077	45	2013-01-30 14:07:37.547623	2013-01-31 14:07:37.547623	f
56	f5ab2df448bdaec74a659b71cbe73d1a04aa4b74	45	2013-01-30 14:13:37.910746	2013-01-31 14:13:37.910746	f
57	26443d8ad8ef25d526aa6d3224721b5ce842e06b	45	2013-01-30 14:13:37.912744	2013-01-31 14:13:37.912744	f
58	bb6086f506af835026dec644472100ec0b67b6d6	45	2013-01-31 15:02:34.344904	2013-02-01 15:02:34.344904	f
59	dc0e929883ac190575ae9d75b070ca890f85ed39	45	2013-01-31 15:02:34.342538	2013-02-01 15:02:34.342538	f
60	c3606b09c1d6eca60cf2d784b4487ce044d42a4c	45	2013-02-01 09:53:03.602948	2013-02-02 09:53:03.602948	f
61	1aabe03d07e1c2c455c97fc145b430486bbe8b07	45	2013-02-01 09:53:41.774078	2013-02-02 09:53:41.774078	f
62	158106ff9161666302dafc77fe4398b4754b2d89	45	2013-02-01 09:56:20.161369	2013-02-02 09:56:20.161369	f
63	f9350d01e9cdfd33d3e8e09c996332ce65a9662a	45	2013-02-01 10:58:15.415997	2013-02-02 10:58:15.415997	f
64	b0af7c59a190bd715ec8856d1743b990371dc677	45	2013-02-01 11:21:08.12146	2013-02-02 11:21:08.12146	f
65	9dcb78bbc88a87d344a171d39bc7956a35aa566b	45	2013-02-01 11:21:36.746223	2013-02-02 11:21:36.746223	f
66	5871d4198414699284994f6b96c77412f64515e6	45	2013-02-01 11:25:47.890634	2013-02-02 11:25:47.890634	f
67	a07aaac2575f87833442fb67a3859f1426ade43c	45	2013-02-01 11:28:21.186847	2013-02-02 11:28:21.186847	f
68	1cbe560007be8dccd36eaeda66dd7348cc07027a	45	2013-02-01 11:29:01.587962	2013-02-02 11:29:01.587962	f
69	e7e4a1667190f310b64755f4e86629ac996348c8	45	2013-02-01 11:35:50.969261	2013-02-02 11:35:50.969261	f
31	67b06a3fbc215f7d3367bd382af76509cb03d114	42	2013-01-21 15:09:10.943043	2013-01-21 16:25:10.943043	t
32	91222d1dd1159c01edf9e98694df63a24abd1338	43	2013-01-21 16:56:41.000428	2013-01-22 16:56:41.000428	t
70	db298bf1ab85f2e7f0d8f85191493c2d3973d81c	45	2013-02-01 11:36:19.840766	2013-02-02 11:36:19.840766	f
71	0a8b1d88f1cb20df8181f8b9eb6f0fac2aaf316d	45	2013-02-01 11:36:30.652819	2013-02-02 11:36:30.652819	f
72	f30e064eba241ca2bddc83c83efab660eeb6e6ef	45	2013-02-01 11:41:27.108357	2013-02-02 11:41:27.108357	f
73	74a3d6c037ddf4a163f37d3fe9952f21c14c8f7f	45	2013-02-01 11:46:10.900158	2013-02-02 11:46:10.900158	f
74	3b0031a8c155080d0ee8bd41b92f3a1d927a20f9	45	2013-02-01 11:47:57.306509	2013-02-02 11:47:57.306509	f
75	98919e219e87f203ddd270aa11445840603d85cf	45	2013-02-01 11:48:48.727102	2013-02-02 11:48:48.727102	f
76	0c857405cb976c4e14d999d59d7e029a0ace0e8c	45	2013-02-01 11:49:37.933	2013-02-02 11:49:37.933	f
77	9e7c13b49909c98f2de2ccb3d275f68530dea278	45	2013-02-01 11:51:58.525049	2013-02-02 11:51:58.525049	f
78	b7f031d091a9ace96863c5474a2ae059ea70415b	45	2013-02-01 11:52:09.554257	2013-02-02 11:52:09.554257	f
33	5cab50cbcc0759b8f3ca9ca6eaa532c89d9874e1	44	2013-01-22 10:02:31.854064	2013-01-24 10:02:31.854064	t
79	0100761f674622504f46231ad9de8245bd597c73	45	2013-02-01 11:52:55.892918	2013-02-02 11:52:55.892918	f
80	1165b68260a369010a4057d1dffb062ea1bce594	45	2013-02-01 11:54:59.334818	2013-02-02 11:54:59.334818	f
34	e173fcdc3782e3cec0c8ea24184cddf876102373	45	2013-01-22 16:04:17.96858	2013-01-23 16:04:17.96858	t
35	7f33f42c8c018360b5775c6f49deee95fb4e07ac	46	2013-01-25 15:59:42.119081	2013-01-26 15:59:42.119081	t
36	ee64951d65fbe22ff985526d5294f33a6fba21ea	47	2013-01-25 16:17:53.554135	2013-01-26 16:17:53.554135	t
37	cc50b7ef25b84a94dbd734e68ad2dbfc0491b379	45	2013-01-28 11:23:56.595227	2013-01-29 11:23:56.595227	f
38	7e9a2b58bc68d0e17fa7be09a4a6328cb4b0e1f2	45	2013-01-28 11:24:02.438263	2013-01-29 11:24:02.438263	f
39	9e09783718acc37d094a8e18b024a0b195eed0d4	45	2013-01-28 11:24:21.000752	2013-01-29 11:24:21.000752	f
40	94aaaecf76a83992705b674ea1617b9b01dbfe68	45	2013-01-28 11:31:43.809644	2013-01-29 11:31:43.809644	f
41	ba5b43dea8ea26de0bfb1ce8f5650d841f355e00	45	2013-01-28 11:34:38.682004	2013-01-29 11:34:38.682004	f
42	e2f579f6f1d91e35682af4e3d75b4f0cca96a4f9	45	2013-01-28 11:36:58.617119	2013-01-29 11:36:58.617119	f
43	b9beee48d42208060fc38edc07cc94a3ac60673b	45	2013-01-28 11:38:39.610784	2013-01-29 11:38:39.610784	t
44	954f406fd055a906146682d2a25a0c47859945a9	45	2013-01-28 11:54:00.702006	2013-01-29 11:54:00.702006	t
81	9ab27702e9acec6dd901e4a8e5037c676037686b	45	2013-02-01 12:35:03.702314	2013-02-02 12:35:03.702314	f
82	ca85ac7953cdd2f5eb94c81e55386c5561cf3123	45	2013-02-01 12:37:54.215325	2013-02-02 12:37:54.215325	f
83	c2a55c1e48be9f0cde5d170e61a55a8727aee7d3	45	2013-02-01 12:44:31.101034	2013-02-02 12:44:31.101034	t
84	4ce421830dc49fd97c4f75447b0baf269ee9a902	45	2013-02-01 13:28:19.524085	2013-02-02 13:28:19.524085	f
85	016f56ebec09d80cf1ec468f921ec45eb4722ea5	45	2013-02-01 13:32:10.9862	2013-02-02 13:32:10.9862	f
86	38ee52b09ee28b290892d030e56b8595a025ddfb	45	2013-02-01 13:34:23.902527	2013-02-02 13:34:23.902527	f
87	606fa125a62beffbea493831d2d25a16eefa95b5	45	2013-02-01 13:38:18.044101	2013-02-02 13:38:18.044101	f
88	198033f38a4394625177b01ab02b84fa3d8a4b5a	45	2013-02-01 13:39:39.122055	2013-02-02 13:39:39.122055	f
89	f23c5a1fb0ff23cfad3af077b3a062d0d3ac0e2f	45	2013-02-01 13:41:11.192627	2013-02-02 13:41:11.192627	f
90	d10ea592732c9a2933ae3e653eb43efb0bc49841	45	2013-02-01 13:42:52.140041	2013-02-02 13:42:52.140041	f
91	cb560bfc29be740796ae87834f65beb7b2ca539c	45	2013-02-01 13:44:04.743563	2013-02-02 13:44:04.743563	f
92	408efb2b2b8abb9013ee362fa6f03e8d0384f243	45	2013-02-01 14:16:09.569164	2013-02-02 14:16:09.569164	f
93	ee880f2724fca09f1a09aed39bfff0eed4906acc	45	2013-02-01 14:17:58.434775	2013-02-02 14:17:58.434775	t
94	3c5a82029b9976f74e498a8efec5d963e48cc5fd	48	2013-02-01 16:20:40.938163	2013-02-02 16:20:40.938163	f
95	502311b81358601e15f0b26f5e6f85b4dfd96eee	50	2013-02-01 16:25:28.043609	2013-02-02 16:25:28.043609	f
96	4f1a5f363a06043561d1dfb655c22a0fbee8993c	51	2013-02-01 16:29:20.602782	2013-02-02 16:29:20.602782	f
97	b5d13879bb585740edc24257da7a618b9e11fc5f	52	2013-02-01 16:39:59.897766	2013-02-02 16:39:59.897766	t
98	7f56ca777759b3c2eacabc310c5c19184130e844	45	2013-02-08 09:48:04.129229	2013-02-09 09:48:04.129229	f
99	8b4ec1e86ddc68446b4ebc2c8a544110c918ed62	43	2013-02-08 09:51:49.054073	2013-02-09 09:51:49.054073	f
100	fc341174d977e022ec4f6727ffb2a33e8cdd95f1	43	2013-02-08 09:51:49.170597	2013-02-09 09:51:49.170597	f
101	d3ef769da9508303b94a97021396a9feea881636	45	2013-02-08 09:54:57.653804	2013-02-09 09:54:57.653804	f
102	5ca1b9d401b8c0c8444981c933e99c5fb8e05d8a	43	2013-02-08 10:14:39.516863	2013-02-09 10:14:39.516863	f
103	05fd09b8c60203c3ffc0485165686140938ce953	43	2013-02-08 10:14:39.547103	2013-02-09 10:14:39.547103	f
104	e46d41acc88eac195ea732d532ba5fc1af3411f6	43	2013-02-08 10:15:01.266187	2013-02-09 10:15:01.266187	f
105	3a82a671714b30df746e96bb7bc9aebe0b198eac	43	2013-02-08 10:15:01.275266	2013-02-09 10:15:01.275266	f
106	0cabc5e163426885aeba95c3ec3149312b8c8723	45	2013-02-08 10:24:35.689577	2013-02-09 10:24:35.689577	f
107	0e8b26bc1e5fafd13bff03f8752c8abcaa1812da	45	2013-02-08 10:24:35.742966	2013-02-09 10:24:35.742966	f
108	7448ac80c02f7431420143421280d33106bb7d8b	43	2013-02-08 10:24:41.406433	2013-02-09 10:24:41.406433	f
109	87b174506f6d49662e7d067734734f3d46932b71	43	2013-02-08 10:24:41.415257	2013-02-09 10:24:41.415257	f
110	8ce5fe208003b4043adb5298de6259e79cb80908	45	2013-02-08 10:24:44.185635	2013-02-09 10:24:44.185635	f
111	834608e818a197a490e75848172102aeb440ef5b	45	2013-02-08 10:24:44.186113	2013-02-09 10:24:44.186113	f
112	4c0a087a90d30abec697fdb1560d072184083c98	45	2013-02-08 10:24:56.760568	2013-02-09 10:24:56.760568	f
113	8148d38fe7ba06248364facb7afe27b5c796b38f	45	2013-02-08 10:24:56.77966	2013-02-09 10:24:56.77966	f
114	c6c921509b388b7d050329746f4c912fb8f931ed	43	2013-02-08 10:31:45.48481	2013-02-09 10:31:45.48481	f
115	a4b4d46137f2bda30601d39d0a1aab9c8edff13b	43	2013-02-08 10:31:45.497096	2013-02-09 10:31:45.497096	f
116	c82d1478f4cf2d29def2abee93b9497e578d4916	43	2013-02-08 10:36:20.044743	2013-02-09 10:36:20.044743	f
117	c4879bede93f18de9b7cb121d522f5565c9084e9	43	2013-02-08 10:36:20.057308	2013-02-09 10:36:20.057308	f
118	ca91bc51b5c184d84b2355772423bc8508eaf767	53	2013-03-11 11:34:32.978187	2013-03-12 11:34:32.978187	f
119	3c91acfa807339e7c5f47aacf632227eb7538519	54	2013-03-11 11:52:05.042428	2013-03-12 11:52:05.042428	f
120	21a6f156aa30c951b302de29576c8b0e0c28e8eb	55	2013-03-11 11:54:38.959854	2013-03-12 11:54:38.959854	t
121	72a400f03d7c14a55bc6ddab3030a637990a4ab5	59	2013-05-14 11:19:26.928097	2013-05-15 11:19:26.928097	f
122	e9a0da34e3ed01c00f8c7af149686814c204624a	62	2013-05-14 11:27:38.868119	2013-05-15 11:27:38.868119	t
123	504c2764027b49bc72f68005a1d85d11fa2da717	62	2013-05-21 10:31:33.923183	2013-05-22 10:31:33.923183	f
124	554e4bbead9e3bfde013f16866412a484d2129eb	43	2013-05-21 10:35:08.166852	2013-05-22 10:35:08.166852	f
125	b56f67ecca42fe842b073c7fc8b99bb3d4984bb7	43	2013-05-21 10:35:08.167866	2013-05-22 10:35:08.167866	f
126	3d7c4f6cc276c45c1df4213031780980af7ab8e9	63	2013-05-21 11:05:55.465218	2013-05-22 11:05:55.465218	t
127	8e14ad0e4dc69d39c33d7d16978030d21068eaa6	64	2013-05-21 11:57:55.227821	2013-05-22 11:57:55.227821	f
128	fee336bf7b6d90e5ea6fbea9b5b58d31b73626c3	65	2013-05-21 12:00:04.104904	2013-05-22 12:00:04.104904	t
129	3f84dd5b9f3aaa550835fd1f161dca0b0d600e05	70	2013-05-24 13:39:29.608972	2013-05-25 13:39:29.608972	t
130	3d60f9b751f2d35f7730a8f4f5121809d668fcf0	44	2013-06-26 09:41:22.76111	2013-06-27 09:41:22.76111	t
\.


--
-- TOC entry 3253 (class 0 OID 87784)
-- Dependencies: 305 3254
-- Data for Name: correlativos_actas; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY correlativos_actas (id, nombre, correlativo, anio) FROM stdin;
1	autorizacion fiscal	19	2013
\.


--
-- TOC entry 3897 (class 0 OID 0)
-- Dependencies: 304
-- Name: correlativos_actas_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('correlativos_actas_id_seq', 1, true);


--
-- TOC entry 3185 (class 0 OID 20773)
-- Dependencies: 234 3254
-- Data for Name: ctaconta; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY ctaconta (cuenta, descripcion, usaraux, inactiva, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 3233 (class 0 OID 78994)
-- Dependencies: 285 3254
-- Data for Name: declara; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY declara (id, nudeclara, nudeposito, tdeclaraid, fechaelab, fechaini, fechafin, replegalid, baseimpo, alicuota, exonera, nuactoexon, credfiscal, contribant, plasustid, montopagar, bln_reparo, fechapago, fechaconci, asientoid, usuarioid, ip, tipocontribuid, conusuid, calpagodid, reparoid, proceso, bln_declaro0) FROM stdin;
239	\N	\N	2	2013-06-03 12:31:11.172842	2007-02-01	2007-02-14	4	50000000.00	5.00	0.00	\N	0.00	\N	\N	2500000.00	t	\N	\N	\N	17	192.168.1.101	4	43	235	238	\N	f
243	V17829273752041100000250002	V1782927375204110000025000	2	2013-06-26 11:48:43.25533	2011-05-01	2011-05-18	4	5000.00	5.00	0.00	\N	0.00	\N	\N	250.00	f	\N	\N	\N	17	192.168.1.103	5	70	195	\N	\N	f
208	V17042979212021100042500009	V1704297921202110004250000	2	2013-05-24 12:48:42.72465	2011-03-01	2011-03-22	4	850000.00	5.00	0.00	\N	0.00	\N	\N	42500.00	f	2011-03-28	\N	\N	17	192.168.1.101	1	43	181	\N	\N	f
209	V17042979212031104750000003	V1704297921203110475000000	2	2013-05-24 12:49:04.310697	2011-04-01	2011-04-26	4	95000000.00	5.00	0.00	\N	0.00	\N	\N	4750000.00	f	2012-05-20	\N	\N	17	192.168.1.101	1	43	182	\N	\N	f
210	V17042979242011200325000003	V1704297924201120032500000	2	2013-05-24 12:49:21.34711	2013-02-01	2013-02-14	4	6500000.00	5.00	0.00	\N	0.00	\N	\N	325000.00	f	2013-03-25	\N	\N	17	192.168.1.101	4	43	247	\N	\N	f
207	V17042979242011000475000001	V1704297924201100047500000	2	2013-05-24 12:46:19.505397	2011-02-01	2011-02-14	4	9500000.00	5.00	0.00	\N	0.00	\N	\N	475000.00	f	2012-02-14	\N	\N	17	192.168.1.101	4	43	243	\N	\N	f
218	V17042979242010700049277752	V1704297924201070004927775	2	2013-05-24 13:18:17.186397	2008-02-01	2008-02-15	4	985555.00	5.00	0.00	\N	0.00	\N	\N	49277.75	f	2009-02-15	\N	\N	17	192.168.1.101	4	43	237	\N	\N	f
219	V15393859422010901220328304	V1539385942201090122032830	2	2013-05-24 13:22:01.067303	2010-02-01	2010-02-17	4	85000000.00	1.50	0.00	\N	0.00	\N	\N	1220328.30	f	2011-06-20	\N	\N	17	192.168.1.101	2	45	240	\N	\N	f
211	V17829273712040800000250002	V1782927371204080000025000	2	2013-05-24 13:06:38.523009	2008-05-01	2008-05-23	4	5000.00	5.00	0.00	\N	0.00	\N	\N	250.00	f	\N	\N	\N	17	192.168.1.103	1	46	111	\N	\N	f
220	V17829273712020600000160004	V1782927371202060000016000	2	2013-05-24 13:48:41.660844	2006-03-01	2006-03-21	4	4000.00	4.00	0.00	\N	0.00	\N	\N	160.00	f	2008-04-25	\N	\N	17	192.168.1.103	1	70	50	\N	\N	f
221	V17829273712041300000250008	V1782927371204130000025000	2	2013-05-24 13:51:47.197673	2013-05-01	2013-05-23	4	5000.00	5.00	0.00	\N	0.00	\N	\N	250.00	f	\N	\N	\N	17	192.168.1.103	1	70	341	\N	\N	f
222	V17829273712021300000150009	V1782927371202130000015000	2	2013-05-24 13:52:49.042781	2013-03-01	2013-03-22	4	3000.00	5.00	0.00	\N	0.00	\N	\N	150.00	f	2013-04-25	\N	\N	17	192.168.1.103	1	70	339	\N	\N	f
206	V17042979212011100042500008	V1704297921201110004250000	2	2013-05-24 12:42:45.282989	2011-02-01	2011-02-23	4	850000.00	5.00	0.00	\N	0.00	\N	\N	42500.00	f	2012-02-25	\N	\N	17	192.168.1.101	1	43	180	\N	\N	f
212	V17829273712051000000300004	V1782927371205100000030000	2	2013-05-24 13:10:00.566889	2010-06-01	2010-06-22	4	6000.00	5.00	0.00	\N	0.00	\N	\N	300.00	f	2010-07-22	\N	\N	17	192.168.1.103	1	46	160	\N	\N	f
213	V17829273712060900000350004	V1782927371206090000035000	2	2013-05-24 13:10:29.174936	2009-07-01	2009-07-21	4	7000.00	5.00	0.00	\N	0.00	\N	\N	350.00	f	2010-07-22	\N	\N	17	192.168.1.103	1	46	137	\N	\N	f
214	V17829273742010600000350007	V1782927374201060000035000	2	2013-05-24 13:11:16.825799	2007-02-01	2007-02-14	4	7000.00	5.00	0.00	\N	0.00	\N	\N	350.00	f	2010-07-22	\N	\N	17	192.168.1.103	4	46	235	\N	\N	f
215	V17829273742010700000400002	V1782927374201070000040000	2	2013-05-24 13:11:50.341538	2008-02-01	2008-02-15	4	8000.00	5.00	0.00	\N	0.00	\N	\N	400.00	f	2010-07-22	\N	\N	17	192.168.1.103	4	46	237	\N	\N	f
216	V17829273742011100000475001	V1782927374201110000047500	2	2013-05-24 13:12:49.918841	2012-02-01	2012-02-14	4	9500.00	5.00	0.00	\N	0.00	\N	\N	475.00	f	2010-07-22	\N	\N	17	192.168.1.103	4	46	245	\N	\N	f
217	V17829273752030800000400008	V1782927375203080000040000	2	2013-05-24 13:13:22.361169	2008-04-01	2008-04-15	4	8000.00	5.00	0.00	\N	0.00	\N	\N	400.00	f	2010-07-22	\N	\N	17	192.168.1.103	5	46	122	\N	\N	f
223	V15393859432021100007385018	V1539385943202110000738501	2	2013-05-29 16:26:23.950188	2011-07-01	2011-07-15	4	492334.00	1.50	0.00	\N	0.00	\N	\N	7385.01	f	2012-11-30	\N	\N	17	192.168.1.101	3	45	289	\N	\N	f
227	\N	\N	2	2013-06-03 11:27:22.714936	2013-04-01	2013-04-15	4	5000000.00	1.50	0.00	\N	0.00	\N	\N	75000.00	t	\N	\N	\N	17	192.168.1.101	3	45	362	225	\N	f
242	\N	\N	2	2013-06-03 12:31:11.172842	2012-02-01	2012-02-14	4	98500000.00	5.00	0.00	\N	0.00	\N	\N	4925000.00	t	\N	\N	\N	17	192.168.1.101	4	43	245	238	\N	f
224	V15393859422011100036100002	V1539385942201110003610000	2	2013-05-29 17:16:32.240162	2012-02-01	2012-02-14	4	8500000.00	1.00	0.00	\N	0.00	\N	\N	36100.00	f	\N	\N	\N	17	192.168.1.101	2	45	244	\N	\N	f
226	\N	\N	2	2013-06-03 11:27:22.714936	2012-04-01	2012-04-16	4	10000000.00	1.50	0.00	\N	0.00	\N	\N	150000.00	t	\N	\N	\N	17	192.168.1.101	3	45	296	225	\N	f
241	\N	\N	2	2013-06-03 12:31:11.172842	2010-02-01	2010-02-17	4	6520000.00	5.00	0.00	\N	0.00	\N	\N	326000.00	t	\N	\N	\N	17	192.168.1.101	4	43	241	238	\N	f
240	\N	\N	2	2013-06-03 12:31:11.172842	2009-02-01	2009-02-16	4	9500000.00	5.00	0.00	\N	0.00	\N	\N	475000.00	t	\N	\N	\N	17	192.168.1.101	4	43	239	238	\N	f
\.


--
-- TOC entry 3147 (class 0 OID 20633)
-- Dependencies: 196 3254
-- Data for Name: declara_viejo; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY declara_viejo (id, nudeclara, nudeposito, tdeclaraid, fechaelab, fechaini, fechafin, replegalid, baseimpo, alicuota, exonera, nuactoexon, credfiscal, contribant, plasustid, nuresactfi, fechanoti, intemora, reparofis, multa, montopagar, fechapago, fechaconci, asientoid, usuarioid, ip, tipocontribuid, conusuid, calpagodid) FROM stdin;
\.


--
-- TOC entry 3149 (class 0 OID 20647)
-- Dependencies: 198 3254
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
-- TOC entry 3226 (class 0 OID 77332)
-- Dependencies: 278 3254
-- Data for Name: detalle_interes; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY detalle_interes (id, intereses, tasa, dias, mes, anio, intereses_id, ip, usuarioid) FROM stdin;
4127	8038.829552	0.068033	16	07	2011	367	192.168.1.101	48
4128	14606.072778	0.063800	31	08	2011	367	192.168.1.101	48
4129	14533.699680	0.065600	30	09	2011	367	192.168.1.101	48
4130	15445.502248	0.067467	31	10	2011	367	192.168.1.101	48
4131	13728.733590	0.061967	30	11	2011	367	192.168.1.101	48
4132	13659.806830	0.059667	31	12	2011	367	192.168.1.101	48
4133	14239.776282	0.062200	31	01	2012	367	192.168.1.101	48
4134	13164.026492	0.061467	29	02	2012	367	192.168.1.101	48
4135	13026.419139	0.056900	31	03	2012	367	192.168.1.101	48
4136	0.000000	0.000000	30	04	2012	367	192.168.1.101	48
4137	0.000000	0.000000	31	05	2012	367	192.168.1.101	48
4138	0.000000	0.000000	30	06	2012	367	192.168.1.101	48
4139	0.000000	0.000000	31	07	2012	367	192.168.1.101	48
4140	0.000000	0.000000	31	08	2012	367	192.168.1.101	48
4141	0.000000	0.000000	30	09	2012	367	192.168.1.101	48
4142	0.000000	0.000000	31	10	2012	367	192.168.1.101	48
4143	0.000000	0.000000	30	11	2012	367	192.168.1.101	48
4144	163.360000	0.068067	8	06	2010	368	192.168.1.103	17
4145	446.600000	0.067667	22	07	2010	368	192.168.1.103	17
4146	260.166667	0.074333	10	07	2009	369	192.168.1.103	17
4147	806.878333	0.074367	31	08	2009	369	192.168.1.103	17
4148	730.450000	0.069567	30	09	2009	369	192.168.1.103	17
4149	794.220000	0.073200	31	10	2009	369	192.168.1.103	17
4150	756.700000	0.072067	30	11	2009	369	192.168.1.103	17
4151	785.901667	0.072433	31	12	2009	369	192.168.1.103	17
4152	766.733333	0.070667	31	01	2010	369	192.168.1.103	17
4153	728.466667	0.074333	28	02	2010	369	192.168.1.103	17
4154	755.883333	0.069667	31	03	2010	369	192.168.1.103	17
4155	741.650000	0.070633	30	04	2010	369	192.168.1.103	17
4156	736.353333	0.067867	31	05	2010	369	192.168.1.103	17
4157	714.700000	0.068067	30	06	2010	369	192.168.1.103	17
4158	521.033333	0.067667	22	07	2010	369	192.168.1.103	17
4159	489.400000	0.081567	15	04	2008	370	192.168.1.101	48
4160	1073.426667	0.086567	31	05	2008	370	192.168.1.101	48
4161	991.200000	0.082600	30	06	2008	370	192.168.1.101	48
4162	1068.053333	0.086133	31	07	2008	370	192.168.1.101	48
4163	1037.053333	0.083633	31	08	2008	370	192.168.1.101	48
4164	988.800000	0.082400	30	09	2008	370	192.168.1.101	48
4165	1010.186667	0.081467	31	10	2008	370	192.168.1.101	48
4166	995.200000	0.082933	30	11	2008	370	192.168.1.101	48
4167	963.893333	0.077733	31	12	2008	370	192.168.1.101	48
4168	1091.613333	0.088033	31	01	2009	370	192.168.1.101	48
4169	1003.893333	0.089633	28	02	2009	370	192.168.1.101	48
4170	1069.293333	0.086233	31	03	2009	370	192.168.1.101	48
4171	986.000000	0.082167	30	04	2009	370	192.168.1.101	48
4172	993.653333	0.080133	31	05	2009	370	192.168.1.101	48
4173	896.800000	0.074733	30	06	2009	370	192.168.1.101	48
4174	921.733333	0.074333	31	07	2009	370	192.168.1.101	48
4175	922.146667	0.074367	31	08	2009	370	192.168.1.101	48
4176	834.800000	0.069567	30	09	2009	370	192.168.1.101	48
4177	907.680000	0.073200	31	10	2009	370	192.168.1.101	48
4178	864.800000	0.072067	30	11	2009	370	192.168.1.101	48
4179	898.173333	0.072433	31	12	2009	370	192.168.1.101	48
4180	876.266667	0.070667	31	01	2010	370	192.168.1.101	48
4181	832.533333	0.074333	28	02	2010	370	192.168.1.101	48
4182	863.866667	0.069667	31	03	2010	370	192.168.1.101	48
4183	847.600000	0.070633	30	04	2010	370	192.168.1.101	48
4184	841.546667	0.067867	31	05	2010	370	192.168.1.101	48
4185	816.800000	0.068067	30	06	2010	370	192.168.1.101	48
4186	595.466667	0.067667	22	07	2010	370	192.168.1.101	48
4187	0.000000	0.000000	9	03	2013	371	192.168.1.103	17
4188	0.000000	0.000000	25	04	2013	371	192.168.1.103	17
4189	264.273333	0.053933	14	02	2007	372	192.168.1.103	17
4190	555.520000	0.051200	31	03	2007	372	192.168.1.103	17
4191	578.900000	0.055133	30	04	2007	372	192.168.1.103	17
4192	610.131667	0.056233	31	05	2007	372	192.168.1.103	17
4193	563.500000	0.053667	30	06	2007	372	192.168.1.103	17
4194	615.556667	0.056733	31	07	2007	372	192.168.1.103	17
4195	636.895000	0.058700	31	08	2007	372	192.168.1.103	17
4196	627.200000	0.059733	30	09	2007	372	192.168.1.103	17
4197	652.808333	0.060167	31	10	2007	372	192.168.1.103	17
4198	733.250000	0.069833	30	11	2007	372	192.168.1.103	17
4199	834.726667	0.076933	31	12	2007	372	192.168.1.103	17
4200	937.801667	0.086433	31	01	2008	372	192.168.1.103	17
4201	834.668333	0.082233	29	02	2008	372	192.168.1.103	17
4202	869.085000	0.080100	31	03	2008	372	192.168.1.103	17
4203	856.450000	0.081567	30	04	2008	372	192.168.1.103	17
4204	939.248333	0.086567	31	05	2008	372	192.168.1.103	17
4205	867.300000	0.082600	30	06	2008	372	192.168.1.103	17
4206	934.546667	0.086133	31	07	2008	372	192.168.1.103	17
4207	907.421667	0.083633	31	08	2008	372	192.168.1.103	17
4208	865.200000	0.082400	30	09	2008	372	192.168.1.103	17
4209	883.913333	0.081467	31	10	2008	372	192.168.1.103	17
4210	870.800000	0.082933	30	11	2008	372	192.168.1.103	17
4211	843.406667	0.077733	31	12	2008	372	192.168.1.103	17
4212	955.161667	0.088033	31	01	2009	372	192.168.1.103	17
4213	878.406667	0.089633	28	02	2009	372	192.168.1.103	17
4214	935.631667	0.086233	31	03	2009	372	192.168.1.103	17
4215	862.750000	0.082167	30	04	2009	372	192.168.1.103	17
4216	869.446667	0.080133	31	05	2009	372	192.168.1.103	17
4217	784.700000	0.074733	30	06	2009	372	192.168.1.103	17
4218	806.516667	0.074333	31	07	2009	372	192.168.1.103	17
4219	806.878333	0.074367	31	08	2009	372	192.168.1.103	17
4220	730.450000	0.069567	30	09	2009	372	192.168.1.103	17
4221	794.220000	0.073200	31	10	2009	372	192.168.1.103	17
4222	756.700000	0.072067	30	11	2009	372	192.168.1.103	17
4223	785.901667	0.072433	31	12	2009	372	192.168.1.103	17
4224	766.733333	0.070667	31	01	2010	372	192.168.1.103	17
4225	728.466667	0.074333	28	02	2010	372	192.168.1.103	17
4226	755.883333	0.069667	31	03	2010	372	192.168.1.103	17
4227	741.650000	0.070633	30	04	2010	372	192.168.1.103	17
4228	736.353333	0.067867	31	05	2010	372	192.168.1.103	17
4229	714.700000	0.068067	30	06	2010	372	192.168.1.103	17
4230	521.033333	0.067667	22	07	2010	372	192.168.1.103	17
4231	460.506667	0.082233	14	02	2008	373	192.168.1.103	17
4232	993.240000	0.080100	31	03	2008	373	192.168.1.103	17
4233	978.800000	0.081567	30	04	2008	373	192.168.1.103	17
4234	1073.426667	0.086567	31	05	2008	373	192.168.1.103	17
4235	991.200000	0.082600	30	06	2008	373	192.168.1.103	17
4236	1068.053333	0.086133	31	07	2008	373	192.168.1.103	17
4237	1037.053333	0.083633	31	08	2008	373	192.168.1.103	17
4238	988.800000	0.082400	30	09	2008	373	192.168.1.103	17
4239	1010.186667	0.081467	31	10	2008	373	192.168.1.103	17
4240	995.200000	0.082933	30	11	2008	373	192.168.1.103	17
4241	963.893333	0.077733	31	12	2008	373	192.168.1.103	17
4242	1091.613333	0.088033	31	01	2009	373	192.168.1.103	17
4243	1003.893333	0.089633	28	02	2009	373	192.168.1.103	17
4244	1069.293333	0.086233	31	03	2009	373	192.168.1.103	17
4245	986.000000	0.082167	30	04	2009	373	192.168.1.103	17
4246	993.653333	0.080133	31	05	2009	373	192.168.1.103	17
4247	896.800000	0.074733	30	06	2009	373	192.168.1.103	17
4248	921.733333	0.074333	31	07	2009	373	192.168.1.103	17
4249	922.146667	0.074367	31	08	2009	373	192.168.1.103	17
4250	834.800000	0.069567	30	09	2009	373	192.168.1.103	17
4251	907.680000	0.073200	31	10	2009	373	192.168.1.103	17
4252	864.800000	0.072067	30	11	2009	373	192.168.1.103	17
4253	898.173333	0.072433	31	12	2009	373	192.168.1.103	17
4254	876.266667	0.070667	31	01	2010	373	192.168.1.103	17
4255	832.533333	0.074333	28	02	2010	373	192.168.1.103	17
4256	863.866667	0.069667	31	03	2010	373	192.168.1.103	17
4257	847.600000	0.070633	30	04	2010	373	192.168.1.103	17
4258	841.546667	0.067867	31	05	2010	373	192.168.1.103	17
4259	816.800000	0.068067	30	06	2010	373	192.168.1.103	17
4260	595.466667	0.067667	22	07	2010	373	192.168.1.103	17
\.


--
-- TOC entry 3898 (class 0 OID 0)
-- Dependencies: 277
-- Name: detalle_interes_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('detalle_interes_id_seq', 4260, true);


--
-- TOC entry 3899 (class 0 OID 0)
-- Dependencies: 279
-- Name: detalle_interes_id_seq1; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('detalle_interes_id_seq1', 125, true);


--
-- TOC entry 3228 (class 0 OID 78841)
-- Dependencies: 280 3254
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
-- TOC entry 3247 (class 0 OID 87642)
-- Dependencies: 299 3254
-- Data for Name: detalles_contrib_calc; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY detalles_contrib_calc (id, declaraid, contrib_calcid, proceso, observacion) FROM stdin;
63	212	142	\N	\N
62	213	142	\N	\N
61	223	141	aprobado	\N
67	222	145	\N	\N
68	218	146	\N	\N
69	207	146	\N	\N
70	210	146	\N	\N
71	219	147	\N	\N
72	214	148	\N	\N
73	215	148	\N	\N
65	214	144	\N	\N
66	215	144	\N	\N
64	217	143	notificado	\N
\.


--
-- TOC entry 3900 (class 0 OID 0)
-- Dependencies: 298
-- Name: detalles_contrib_calc_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('detalles_contrib_calc_id_seq', 73, true);


--
-- TOC entry 3235 (class 0 OID 79062)
-- Dependencies: 287 3254
-- Data for Name: dettalles_fizcalizacion; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY dettalles_fizcalizacion (id, periodo, anio, base, alicuota, total, asignacionfid, bln_borrado, calpagodid, bln_reparo_faltante, bln_identificador) FROM stdin;
89	1	2012	10000000	1.50	150000	116	f	296	f	t
90	1	2013	5000000	1.50	75000	116	f	362	f	t
95	4	2006	100000	4.00	4000	930	f	52	f	t
96	2	2013	100000	5.00	5000	932	f	339	f	t
\.


--
-- TOC entry 3901 (class 0 OID 0)
-- Dependencies: 286
-- Name: dettalles_fizcalizacion_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('dettalles_fizcalizacion_id_seq', 96, true);


--
-- TOC entry 3186 (class 0 OID 20778)
-- Dependencies: 235 3254
-- Data for Name: document; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY document (id, nombre, docu, inactivo, usfonproid, ip) FROM stdin;
\.


--
-- TOC entry 3902 (class 0 OID 0)
-- Dependencies: 236
-- Name: document_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('document_id_seq', 1, false);


--
-- TOC entry 3153 (class 0 OID 20658)
-- Dependencies: 202 3254
-- Data for Name: entidad; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY entidad (id, nombre, entidad, orden) FROM stdin;
\.


--
-- TOC entry 3151 (class 0 OID 20652)
-- Dependencies: 200 3254
-- Data for Name: entidadd; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY entidadd (id, entidadid, nombre, accion, orden) FROM stdin;
\.


--
-- TOC entry 3155 (class 0 OID 20664)
-- Dependencies: 204 3254
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
-- TOC entry 3223 (class 0 OID 77288)
-- Dependencies: 275 3254
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
\.


--
-- TOC entry 3903 (class 0 OID 0)
-- Dependencies: 276
-- Name: interes_bcv_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('interes_bcv_id_seq', 170, true);


--
-- TOC entry 3159 (class 0 OID 20674)
-- Dependencies: 208 3254
-- Data for Name: perusu; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY perusu (id, nombre, inactivo, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 3157 (class 0 OID 20669)
-- Dependencies: 206 3254
-- Data for Name: perusud; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY perusud (id, perusuid, entidaddid, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 3161 (class 0 OID 20680)
-- Dependencies: 210 3254
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
-- TOC entry 3251 (class 0 OID 87765)
-- Dependencies: 303 3254
-- Data for Name: presidente; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY presidente (id, nombres, apellidos, cedula, nro_decreto, nro_gaceta, dtm_fecha_gaceta, bln_activo, usuarioid, ip) FROM stdin;
1	Alizar	Dahdah Antar	0	7.252	39.373	24-02-2010	t	48	192.168.1.102
\.


--
-- TOC entry 3904 (class 0 OID 0)
-- Dependencies: 302
-- Name: presidente_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('presidente_id_seq', 1, true);


--
-- TOC entry 3236 (class 0 OID 79132)
-- Dependencies: 288 3254
-- Data for Name: reparos; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY reparos (id, tdeclaraid, fechaelab, montopagar, fechapago, fechaconci, asientoid, usuarioid, ip, tipocontribuid, conusuid, bln_activo, proceso, fecha_notificacion, bln_sumario) FROM stdin;
225	2	2013-06-03 11:27:22.714936	225000.00	\N	\N	\N	48	192.168.1.101	3	45	f	enviado	2013-06-03 12:21:38.392059	f
238	2	2013-06-03 12:31:11.172842	8226000.00	\N	\N	\N	48	192.168.1.101	4	43	t	enviado	2013-06-27 15:45:30.736218	f
\.


--
-- TOC entry 3163 (class 0 OID 20685)
-- Dependencies: 212 3254
-- Data for Name: replegal; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY replegal (id, contribuid, nombre, apellido, ci, domfiscal, estadoid, ciudadid, zonaposta, telefhab, telefofc, fax, email, pinbb, skype, cextra1, cextra2, cextra3, cextra4, cextra5, usuarioid, ip) FROM stdin;
4	2	jefferosn arturo	lara	17042979	dsfsfdsas	7	48	0201	0243-2158532	0412-0428211	0243-2158532	jetox21@gmail.com			\N	\N	\N	\N	\N	17	192.168.1.101
5	2	hjgjhgjh	kjhhkj	123456987	hggfjhghjgjhgjhg	3	1	0231	0243-1111111	0244-1111111	0243-1111111	hgjhgj#@jhgkjh.com	ddd544	dfgdg	\N	\N	\N	\N	\N	17	192.168.1.101
6	2	dfsdfsdf	fdgfdgdf	9878523	fdgfdgfdgfdgfd	3	1	0421	0244-2222222	0244-5555555	0244-8888888	adfdasfd@kjkls.com	454df	dfasdas	\N	\N	\N	\N	\N	17	192.168.1.101
\.


--
-- TOC entry 3165 (class 0 OID 20693)
-- Dependencies: 214 3254
-- Data for Name: tdeclara; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY tdeclara (id, nombre, tipo, usuarioid, ip) FROM stdin;
2	AUTOLIQUIDACION	0	17	192.168.1.101
3	SUSTITUTIVA	0	17	192.168.1.102
4	MULTA POR PAGO EXTEMPORANEO	1	17	192.168.1.101
5	MULTA POR REPARO FISCAL	2	17	192.168.1.101
\.


--
-- TOC entry 3167 (class 0 OID 20698)
-- Dependencies: 216 3254
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
-- TOC entry 3169 (class 0 OID 20705)
-- Dependencies: 218 3254
-- Data for Name: tipocont; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY tipocont (id, nombre, tipegravid, usuarioid, ip, numero_articulo) FROM stdin;
1	EXHIBIDORES	1	16	192.168.1.102	50
2	TV SEÑAL ABIERTA	3	17	192.168.1.101	51
3	TV SUSCRIPCION	5	17	192.168.1.101	52
4	DISTRIBUIDORES	4	17	192.168.1.101	53
5	VENTA Y ALQUILER	2	17	192.168.1.101	54
6	SERVICIOS PARA LA PRODUCCION	6	17	192.168.1.101	56
\.


--
-- TOC entry 3188 (class 0 OID 20787)
-- Dependencies: 237 3254
-- Data for Name: tmpaccioni; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY tmpaccioni (id, contribuid, nombre, apellido, ci, domfiscal, nuacciones, valaccion, cextra1, cextra2, cextra3, cextra4, cextra5, ip) FROM stdin;
\.


--
-- TOC entry 3189 (class 0 OID 20795)
-- Dependencies: 238 3254
-- Data for Name: tmpcontri; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY tmpcontri (id, tipocontid, razonsocia, dencomerci, actieconid, rif, numregcine, domfiscal, estadoid, ciudadid, zonapostal, telef1, telef2, telef3, fax1, fax2, email, pinbb, skype, twitter, facebook, nuacciones, valaccion, capitalsus, capitalpag, regmerofc, rmnumero, rmfolio, rmtomo, rmfechapro, rmncontrol, rmobjeto, domcomer, conusuid, tiporeg, cextra1, cextra2, cextra3, cextra4, cextra5, ip) FROM stdin;
\.


--
-- TOC entry 3190 (class 0 OID 20805)
-- Dependencies: 239 3254
-- Data for Name: tmprelegal; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY tmprelegal (id, contribuid, nombre, apellido, ci, domfiscal, estadoid, ciudadid, zonaposta, telefhab, telefofc, fax, email, pinbb, skype, cextra1, cextra2, cextra3, cextra4, cextra5, ip) FROM stdin;
\.


--
-- TOC entry 3171 (class 0 OID 20710)
-- Dependencies: 220 3254
-- Data for Name: undtrib; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY undtrib (id, fecha, valor, usuarioid, ip) FROM stdin;
5	1994-05-27	1.00	17	192.168.1.102
6	1995-05-27	1.70	17	192.168.1.102
7	1996-05-27	2.70	17	192.168.1.102
8	1997-05-27	5.40	17	192.168.1.102
9	1998-05-27	7.40	17	192.168.1.102
10	1999-05-27	9.60	17	192.168.1.102
11	2000-05-27	11.60	17	192.168.1.102
12	2001-05-27	13.20	17	192.168.1.102
13	2002-05-27	14.80	17	192.168.1.102
14	2003-05-27	19.40	17	192.168.1.102
15	2004-05-27	24.70	17	192.168.1.102
16	2005-05-27	29.40	17	192.168.1.102
17	2006-05-27	33.60	17	192.168.1.102
18	2007-05-27	37.63	17	192.168.1.102
19	2008-05-27	46.00	17	192.168.1.102
20	2009-05-27	55.00	17	192.168.1.102
21	2010-05-27	65.00	17	192.168.1.102
22	2011-05-27	76.00	17	192.168.1.102
23	2012-05-27	90.00	17	192.168.1.102
24	2013-05-27	107.00	17	192.168.1.102
\.


--
-- TOC entry 3175 (class 0 OID 20725)
-- Dependencies: 224 3254
-- Data for Name: usfonpro; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY usfonpro (id, login, password, nombre, email, telefofc, extension, departamid, cargoid, inactivo, pregsecrid, respuesta, perusuid, ultlogin, usuarioid, ip, cedula) FROM stdin;
49	elmio	23017a25bdf707db1707779940e00d051d84d16b	jose de la trinida	elmio@hotmail.com	0412-0428211	\N	3	9	f	4	molina	\N	\N	\N	192.168.1.101	1235698
48	jelara	652e0df6e23bd9aac8d2f5667b89f5d91cea8d15	Jefferson Arturo Lara Molina	jetox21@gmail.com	0412-0428211	\N	3	9	f	4	molina	\N	\N	\N	192.168.1.102	17042979
18	alaos	7c4a8d09ca3762af61e59520943dc26494f8941b	Arturo Laos	arturo.laos@gmail.com	02125760355	\N	10	8	f	2	Director LCT	\N	\N	1	192.168.1.103	11111111
16	fbustamante	7c4a8d09ca3762af61e59520943dc26494f8941b	frederick	frederickdanielb@gmail.com	04142680489	\N	3	9	f	7	hola	\N	\N	1	192.168.1.101	15100387
17	svalladares	7c4a8d09ca3762af61e59520943dc26494f8941b	Silvia Valladares Sandoval	spvsr8@gmail.com	04160799712	\N	3	9	f	5	pizza	\N	\N	1	192.168.1.101	17829273
47	cnac	3145f2cd4ff92c1d9a538f215d8ab61132039016	CNAC	cnac@gmail.com	0212-5342123	\N	3	9	f	2	Prueba	\N	\N	\N	192.168.1.103	111111
\.


--
-- TOC entry 3173 (class 0 OID 20716)
-- Dependencies: 222 3254
-- Data for Name: usfonpto; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY usfonpto (id, token, usfonproid, fechacrea, fechacadu, usado) FROM stdin;
\.


SET search_path = historial, pg_catalog;

--
-- TOC entry 3905 (class 0 OID 0)
-- Dependencies: 241
-- Name: Bitacora_IDBitacora_seq; Type: SEQUENCE SET; Schema: historial; Owner: postgres
--

SELECT pg_catalog.setval('"Bitacora_IDBitacora_seq"', 34, true);


--
-- TOC entry 3191 (class 0 OID 20811)
-- Dependencies: 240 3254
-- Data for Name: bitacora; Type: TABLE DATA; Schema: historial; Owner: postgres
--

COPY bitacora (id, fecha, tabla, idusuario, accion, datosnew, datosold, datosdel, valdelid, ip) FROM stdin;
\.


SET search_path = pre_aprobacion, pg_catalog;

--
-- TOC entry 3241 (class 0 OID 87498)
-- Dependencies: 293 3254
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
-- TOC entry 3906 (class 0 OID 0)
-- Dependencies: 292
-- Name: datos_cnac_id_seq; Type: SEQUENCE SET; Schema: pre_aprobacion; Owner: postgres
--

SELECT pg_catalog.setval('datos_cnac_id_seq', 19, true);


--
-- TOC entry 3222 (class 0 OID 77269)
-- Dependencies: 274 3254
-- Data for Name: intereses; Type: TABLE DATA; Schema: pre_aprobacion; Owner: postgres
--

COPY intereses (id, numresolucion, numactafiscal, felaboracion, fnotificacion, totalpagar, multaid, ip, usuarioid, fecha_inicio, fecha_fin) FROM stdin;
367	001A	\N	2013-05-29 16:28:25.437796	\N	120442.866591	56	192.168.1.101	48	2011-07-15	2012-11-30
368	001A	\N	2013-05-31 15:30:43.056322	\N	609.96	57	192.168.1.103	17	2010-06-22	2010-07-22
369	001A	\N	2013-05-31 15:30:43.056322	\N	9099.1366666667	58	192.168.1.103	17	2009-07-21	2010-07-22
370	001A	\N	2013-06-03 09:27:20.352554	\N	25681.88	59	192.168.1.101	48	2008-04-15	2010-07-22
371	001A	\N	2013-06-04 15:32:26.317154	\N	0	60	192.168.1.103	17	2013-03-22	2013-04-25
372	001A	\N	2013-06-05 11:16:40.676508	\N	32214.186666667	61	192.168.1.103	17	2007-02-14	2010-07-22
373	001A	\N	2013-06-05 11:16:40.676508	\N	27625.026666667	62	192.168.1.103	17	2008-02-15	2010-07-22
\.


--
-- TOC entry 3907 (class 0 OID 0)
-- Dependencies: 273
-- Name: intereses_id_seq; Type: SEQUENCE SET; Schema: pre_aprobacion; Owner: postgres
--

SELECT pg_catalog.setval('intereses_id_seq', 373, true);


--
-- TOC entry 3220 (class 0 OID 77248)
-- Dependencies: 272 3254
-- Data for Name: multas; Type: TABLE DATA; Schema: pre_aprobacion; Owner: postgres
--

COPY multas (id, nresolucion, fechaelaboracion, fechanotificacion, montopagar, declaraid, ip, usuarioid, tipo_multa) FROM stdin;
56	001A	2013-05-29 16:28:25.437796	\N	73.8501	223	192.168.1.101	48	4
57	001A	2013-05-31 15:30:43.056322	\N	3	212	192.168.1.103	17	4
58	001A	2013-05-31 15:30:43.056322	\N	3.5	213	192.168.1.103	17	4
59	001A	2013-06-03 09:27:20.352554	\N	4	217	192.168.1.101	48	4
60	001A	2013-06-04 15:32:26.317154	\N	1.5	222	192.168.1.103	17	4
61	001A	2013-06-05 11:16:40.676508	\N	3.5	214	192.168.1.103	17	4
62	001A	2013-06-05 11:16:40.676508	\N	4	215	192.168.1.103	17	4
\.


--
-- TOC entry 3908 (class 0 OID 0)
-- Dependencies: 271
-- Name: multas_id_seq; Type: SEQUENCE SET; Schema: pre_aprobacion; Owner: postgres
--

SELECT pg_catalog.setval('multas_id_seq', 62, true);


SET search_path = public, pg_catalog;

--
-- TOC entry 3237 (class 0 OID 79201)
-- Dependencies: 289 3254
-- Data for Name: contrib_calc; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY contrib_calc (id, nombre) FROM stdin;
\.


SET search_path = seg, pg_catalog;

--
-- TOC entry 3245 (class 0 OID 87607)
-- Dependencies: 297 3254
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
-- TOC entry 3909 (class 0 OID 0)
-- Dependencies: 296
-- Name: tbl_cargos_id_seq; Type: SEQUENCE SET; Schema: seg; Owner: postgres
--

SELECT pg_catalog.setval('tbl_cargos_id_seq', 6, true);


--
-- TOC entry 3216 (class 0 OID 46570)
-- Dependencies: 268 3254
-- Data for Name: tbl_ci_sessions; Type: TABLE DATA; Schema: seg; Owner: postgres
--

COPY tbl_ci_sessions (session_id, ip_address, user_agent, last_activity, user_data, prevent_update) FROM stdin;
728c9e6834c18f7b3059d44010afa760	192.168.1.101	Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:22.0) Gecko/20100101 Firefox/22.0	1372694824	a:7:{s:14:"prevent_update";i:0;s:9:"user_data";s:0:"";s:6:"logged";b:1;s:2:"id";s:2:"48";s:7:"usuario";s:6:"jelara";s:6:"nombre";s:28:"Jefferson Arturo Lara Molina";s:12:"info_modulos";a:25:{i:0;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:1:"5";s:10:"str_modulo";s:25:"Administracion de sistema";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:1:"#";s:8:"id_padre";s:1:"0";}i:1;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:1:"6";s:10:"str_modulo";s:8:"Usuarios";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:1:"5";}i:2;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"104";s:10:"str_modulo";s:19:"Perfiles de usuario";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:1:"5";}i:3;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"139";s:10:"str_modulo";s:18:"Gestion de modulos";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:1:"5";}i:4;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:2:"89";s:10:"str_modulo";s:11:"Recaudacion";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:1:"#";s:8:"id_padre";s:1:"0";}i:5;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:2:"90";s:10:"str_modulo";s:28:"Activacion del contribuyente";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:2:"89";}i:6;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:2:"93";s:10:"str_modulo";s:20:"Gestion Declaración";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:2:"89";}i:7;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"101";s:10:"str_modulo";s:8:"Finanzas";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:1:"#";s:8:"id_padre";s:1:"0";}i:8;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"102";s:10:"str_modulo";s:13:"Fiscalizacion";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:1:"#";s:8:"id_padre";s:1:"0";}i:9;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"103";s:10:"str_modulo";s:5:"Legal";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:1:"#";s:8:"id_padre";s:1:"0";}i:10;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"149";s:10:"str_modulo";s:17:"Consulta Avanzada";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:2:"89";}i:11;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"155";s:10:"str_modulo";s:24:"Gestion deberes formales";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:2:"89";}i:12;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"162";s:10:"str_modulo";s:17:"gestion de multas";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:2:"89";}i:13;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:2:"98";s:10:"str_modulo";s:17:"Consulta Avanzada";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"102";}i:14;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"140";s:10:"str_modulo";s:8:"Calculos";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"101";}i:15;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"133";s:10:"str_modulo";s:17:"Visitas asignadas";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"102";}i:16;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"144";s:10:"str_modulo";s:20:"Calculos por aprobar";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"101";}i:17;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"141";s:10:"str_modulo";s:18:"Reparos culminados";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"102";}i:18;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"142";s:10:"str_modulo";s:6:"prueba";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"102";}i:19;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"143";s:10:"str_modulo";s:12:"prueba legal";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"103";}i:20;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"164";s:10:"str_modulo";s:20:"Empresas Recaudacion";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"102";}i:21;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"128";s:10:"str_modulo";s:20:"Gestión de Usuarios";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:1:"#";s:8:"id_padre";s:1:"0";}i:22;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"129";s:10:"str_modulo";s:16:"Actualizar Datos";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"128";}i:23;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"130";s:10:"str_modulo";s:19:"Cambiar Contraseña";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"128";}i:24;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"131";s:10:"str_modulo";s:21:"Cambiar Preg. Secreta";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"128";}}}	0
b5498c1e02d1ad4279cc1a92ac1241a7	192.168.1.103	Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:21.0) Gecko/20100101 Firefox/21.0	1372711842		0
ace32baab0a989db7b5e01a3a857f260	192.168.1.102	Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:22.0) Gecko/20100101 Firefox/22.0	1372694693	a:7:{s:14:"prevent_update";i:0;s:9:"user_data";s:0:"";s:6:"logged";b:1;s:2:"id";s:2:"48";s:7:"usuario";s:6:"jelara";s:6:"nombre";s:28:"Jefferson Arturo Lara Molina";s:12:"info_modulos";a:25:{i:0;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:1:"5";s:10:"str_modulo";s:25:"Administracion de sistema";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:1:"#";s:8:"id_padre";s:1:"0";}i:1;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:1:"6";s:10:"str_modulo";s:8:"Usuarios";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:1:"5";}i:2;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"104";s:10:"str_modulo";s:19:"Perfiles de usuario";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:1:"5";}i:3;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"139";s:10:"str_modulo";s:18:"Gestion de modulos";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:1:"5";}i:4;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:2:"89";s:10:"str_modulo";s:11:"Recaudacion";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:1:"#";s:8:"id_padre";s:1:"0";}i:5;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:2:"90";s:10:"str_modulo";s:28:"Activacion del contribuyente";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:2:"89";}i:6;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:2:"93";s:10:"str_modulo";s:20:"Gestion Declaración";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:2:"89";}i:7;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"101";s:10:"str_modulo";s:8:"Finanzas";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:1:"#";s:8:"id_padre";s:1:"0";}i:8;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"102";s:10:"str_modulo";s:13:"Fiscalizacion";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:1:"#";s:8:"id_padre";s:1:"0";}i:9;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"103";s:10:"str_modulo";s:5:"Legal";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:1:"#";s:8:"id_padre";s:1:"0";}i:10;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"149";s:10:"str_modulo";s:17:"Consulta Avanzada";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:2:"89";}i:11;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"155";s:10:"str_modulo";s:24:"Gestion deberes formales";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:2:"89";}i:12;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"162";s:10:"str_modulo";s:17:"gestion de multas";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:2:"89";}i:13;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:2:"98";s:10:"str_modulo";s:17:"Consulta Avanzada";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"102";}i:14;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"140";s:10:"str_modulo";s:8:"Calculos";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"101";}i:15;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"133";s:10:"str_modulo";s:17:"Visitas asignadas";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"102";}i:16;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"144";s:10:"str_modulo";s:20:"Calculos por aprobar";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"101";}i:17;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"141";s:10:"str_modulo";s:18:"Reparos culminados";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"102";}i:18;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"142";s:10:"str_modulo";s:6:"prueba";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"102";}i:19;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"143";s:10:"str_modulo";s:12:"prueba legal";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"103";}i:20;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"164";s:10:"str_modulo";s:20:"Empresas Recaudacion";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"102";}i:21;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"128";s:10:"str_modulo";s:20:"Gestión de Usuarios";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:1:"#";s:8:"id_padre";s:1:"0";}i:22;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"129";s:10:"str_modulo";s:16:"Actualizar Datos";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"128";}i:23;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"130";s:10:"str_modulo";s:19:"Cambiar Contraseña";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"128";}i:24;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"131";s:10:"str_modulo";s:21:"Cambiar Preg. Secreta";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"128";}}}	0
78bef4a1c284e19fe8783a663f11e83e	192.168.1.103	Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:21.0) Gecko/20100101 Firefox/21.0	1372694821	a:7:{s:14:"prevent_update";i:0;s:9:"user_data";s:0:"";s:6:"logged";b:1;s:2:"id";s:2:"17";s:7:"usuario";s:11:"svalladares";s:6:"nombre";s:26:"Silvia Valladares Sandoval";s:12:"info_modulos";a:25:{i:0;a:7:{s:11:"str_usuario";s:26:"Silvia Valladares Sandoval";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:1:"5";s:10:"str_modulo";s:25:"Administracion de sistema";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:1:"#";s:8:"id_padre";s:1:"0";}i:1;a:7:{s:11:"str_usuario";s:26:"Silvia Valladares Sandoval";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:1:"6";s:10:"str_modulo";s:8:"Usuarios";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:1:"5";}i:2;a:7:{s:11:"str_usuario";s:26:"Silvia Valladares Sandoval";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"104";s:10:"str_modulo";s:19:"Perfiles de usuario";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:1:"5";}i:3;a:7:{s:11:"str_usuario";s:26:"Silvia Valladares Sandoval";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"139";s:10:"str_modulo";s:18:"Gestion de modulos";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:1:"5";}i:4;a:7:{s:11:"str_usuario";s:26:"Silvia Valladares Sandoval";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:2:"89";s:10:"str_modulo";s:11:"Recaudacion";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:1:"#";s:8:"id_padre";s:1:"0";}i:5;a:7:{s:11:"str_usuario";s:26:"Silvia Valladares Sandoval";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:2:"90";s:10:"str_modulo";s:28:"Activacion del contribuyente";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:2:"89";}i:6;a:7:{s:11:"str_usuario";s:26:"Silvia Valladares Sandoval";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:2:"93";s:10:"str_modulo";s:20:"Gestion Declaración";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:2:"89";}i:7;a:7:{s:11:"str_usuario";s:26:"Silvia Valladares Sandoval";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"101";s:10:"str_modulo";s:8:"Finanzas";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:1:"#";s:8:"id_padre";s:1:"0";}i:8;a:7:{s:11:"str_usuario";s:26:"Silvia Valladares Sandoval";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"102";s:10:"str_modulo";s:13:"Fiscalizacion";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:1:"#";s:8:"id_padre";s:1:"0";}i:9;a:7:{s:11:"str_usuario";s:26:"Silvia Valladares Sandoval";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"103";s:10:"str_modulo";s:5:"Legal";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:1:"#";s:8:"id_padre";s:1:"0";}i:10;a:7:{s:11:"str_usuario";s:26:"Silvia Valladares Sandoval";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"149";s:10:"str_modulo";s:17:"Consulta Avanzada";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:2:"89";}i:11;a:7:{s:11:"str_usuario";s:26:"Silvia Valladares Sandoval";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"155";s:10:"str_modulo";s:24:"Gestion deberes formales";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:2:"89";}i:12;a:7:{s:11:"str_usuario";s:26:"Silvia Valladares Sandoval";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"162";s:10:"str_modulo";s:17:"gestion de multas";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:2:"89";}i:13;a:7:{s:11:"str_usuario";s:26:"Silvia Valladares Sandoval";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:2:"98";s:10:"str_modulo";s:17:"Consulta Avanzada";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"102";}i:14;a:7:{s:11:"str_usuario";s:26:"Silvia Valladares Sandoval";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"140";s:10:"str_modulo";s:8:"Calculos";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"101";}i:15;a:7:{s:11:"str_usuario";s:26:"Silvia Valladares Sandoval";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"133";s:10:"str_modulo";s:17:"Visitas asignadas";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"102";}i:16;a:7:{s:11:"str_usuario";s:26:"Silvia Valladares Sandoval";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"144";s:10:"str_modulo";s:20:"Calculos por aprobar";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"101";}i:17;a:7:{s:11:"str_usuario";s:26:"Silvia Valladares Sandoval";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"141";s:10:"str_modulo";s:18:"Reparos culminados";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"102";}i:18;a:7:{s:11:"str_usuario";s:26:"Silvia Valladares Sandoval";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"142";s:10:"str_modulo";s:6:"prueba";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"102";}i:19;a:7:{s:11:"str_usuario";s:26:"Silvia Valladares Sandoval";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"143";s:10:"str_modulo";s:12:"prueba legal";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"103";}i:20;a:7:{s:11:"str_usuario";s:26:"Silvia Valladares Sandoval";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"164";s:10:"str_modulo";s:20:"Empresas Recaudacion";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"102";}i:21;a:7:{s:11:"str_usuario";s:26:"Silvia Valladares Sandoval";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"128";s:10:"str_modulo";s:20:"Gestión de Usuarios";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:1:"#";s:8:"id_padre";s:1:"0";}i:22;a:7:{s:11:"str_usuario";s:26:"Silvia Valladares Sandoval";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"129";s:10:"str_modulo";s:16:"Actualizar Datos";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"128";}i:23;a:7:{s:11:"str_usuario";s:26:"Silvia Valladares Sandoval";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"130";s:10:"str_modulo";s:19:"Cambiar Contraseña";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"128";}i:24;a:7:{s:11:"str_usuario";s:26:"Silvia Valladares Sandoval";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"131";s:10:"str_modulo";s:21:"Cambiar Preg. Secreta";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"128";}}}	0
f4d4946d851f7678dfabd048156edd63	192.168.1.101	Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:22.0) Gecko/20100101 Firefox/22.0	1372709868	a:7:{s:14:"prevent_update";i:0;s:9:"user_data";s:0:"";s:6:"logged";b:1;s:2:"id";s:2:"48";s:7:"usuario";s:6:"jelara";s:6:"nombre";s:28:"Jefferson Arturo Lara Molina";s:12:"info_modulos";a:25:{i:0;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:1:"5";s:10:"str_modulo";s:25:"Administracion de sistema";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:1:"#";s:8:"id_padre";s:1:"0";}i:1;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:1:"6";s:10:"str_modulo";s:8:"Usuarios";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:1:"5";}i:2;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"104";s:10:"str_modulo";s:19:"Perfiles de usuario";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:1:"5";}i:3;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"139";s:10:"str_modulo";s:18:"Gestion de modulos";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:1:"5";}i:4;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:2:"89";s:10:"str_modulo";s:11:"Recaudacion";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:1:"#";s:8:"id_padre";s:1:"0";}i:5;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:2:"90";s:10:"str_modulo";s:28:"Activacion del contribuyente";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:2:"89";}i:6;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:2:"93";s:10:"str_modulo";s:20:"Gestion Declaración";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:2:"89";}i:7;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"101";s:10:"str_modulo";s:8:"Finanzas";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:1:"#";s:8:"id_padre";s:1:"0";}i:8;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"102";s:10:"str_modulo";s:13:"Fiscalizacion";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:1:"#";s:8:"id_padre";s:1:"0";}i:9;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"103";s:10:"str_modulo";s:5:"Legal";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:1:"#";s:8:"id_padre";s:1:"0";}i:10;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"149";s:10:"str_modulo";s:17:"Consulta Avanzada";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:2:"89";}i:11;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"155";s:10:"str_modulo";s:24:"Gestion deberes formales";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:2:"89";}i:12;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"162";s:10:"str_modulo";s:17:"gestion de multas";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:2:"89";}i:13;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:2:"98";s:10:"str_modulo";s:17:"Consulta Avanzada";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"102";}i:14;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"140";s:10:"str_modulo";s:8:"Calculos";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"101";}i:15;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"133";s:10:"str_modulo";s:17:"Visitas asignadas";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"102";}i:16;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"144";s:10:"str_modulo";s:20:"Calculos por aprobar";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"101";}i:17;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"141";s:10:"str_modulo";s:18:"Reparos culminados";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"102";}i:18;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"142";s:10:"str_modulo";s:6:"prueba";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"102";}i:19;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"143";s:10:"str_modulo";s:12:"prueba legal";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"103";}i:20;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"164";s:10:"str_modulo";s:20:"Empresas Recaudacion";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"102";}i:21;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"128";s:10:"str_modulo";s:20:"Gestión de Usuarios";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:1:"#";s:8:"id_padre";s:1:"0";}i:22;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"129";s:10:"str_modulo";s:16:"Actualizar Datos";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"128";}i:23;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"130";s:10:"str_modulo";s:19:"Cambiar Contraseña";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"128";}i:24;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"131";s:10:"str_modulo";s:21:"Cambiar Preg. Secreta";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"128";}}}	0
\.


--
-- TOC entry 3193 (class 0 OID 21562)
-- Dependencies: 242 3254
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
137	0	0	0	0	f
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
142	102	prueba	PRUEBA	./mod_administrador/principal_c	f
143	103	prueba legal	prueba legal	./mod_administrador/principal_c	f
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
156	155	Registros del CNAC	listado que contienen todas las empresas que se encuentran registrada hasta la actualidad en registro nacional de cinematografia	./mod_gestioncontribuyente/listado_cnac_c	t
159	128	aaaaaaaaa aaaaaaaaaaaaa	sdsdf	./mod_administrador/principal_c	t
160	128	gggggggg vvvvvvv	dfdf	./mod_administrador/principal_c	t
161	128	ppppppp hhhhhhhhhh  hhhhhhhhhhhhhhj	,m	./mod_administrador/principal_c	t
90	89	Activacion del contribuyente	verifica planilla	./mod_administrador/principal_c	f
162	89	gestion de multas	modulo encargado de mostrar al usuario el estatus que se encuentra el calculo solicitado y si ya fue aprobado imprimi la notificacion	./mod_administrador/principal_c	f
163	162	Listado de multas segun estatus	se visulaiza el listar de los contribuyentes con multas extemporabeas segun el estatus que requiera el usuario	./mod_gestioncontribuyente/gestion_multas_recaudacion_c	f
158	155	Empresas externas	manejo de verificacion de deberes formales a partir de listados de empresas de indole externo esto quiere decir que la empresa no se encuentra en el registro del cnac pero que es un posible contribuyente potencial	./mod_gestioncontribuyente/empext	t
164	102	Empresas Recaudacion	aqui se vizualiza las empresas que arrojaron en la verificacion de los deberes formales que si son contribueyntes de fonprocine	./mod_administrador/principal_c	f
165	164	Asignacion por deberes formales	se listan todas las empresas que en los deberes formales se les determino que eran contribuyentes fonprocine	./mod_gestioncontribueyente/asignacion_deberes_formales_fiscalizacion_c	f
166	140	Reparo	Listado de contribuyentes por Reparo, donde se aplicaran los cálculos de intereses y multas	./mod_gestioncontribuyente/lista_reparo_calc_c	f
167	141	Reparos activados	listado de los reparos que fueron activados despues de la fiscalizacion	./rrrrrrr	f
\.


--
-- TOC entry 3910 (class 0 OID 0)
-- Dependencies: 243
-- Name: tbl_modulo_id_modulo_seq; Type: SEQUENCE SET; Schema: seg; Owner: postgres
--

SELECT pg_catalog.setval('tbl_modulo_id_modulo_seq', 167, true);


--
-- TOC entry 3243 (class 0 OID 87568)
-- Dependencies: 295 3254
-- Data for Name: tbl_oficinas; Type: TABLE DATA; Schema: seg; Owner: postgres
--

COPY tbl_oficinas (id, nombre, descripcion, fecha_creacion, cod_estructura, usuarioid, ip, bln_borrado) FROM stdin;
1	GERENCIA DE RECAUDACION		2013-05-09	0001	48	192.168.1.102	f
2	GERENCIA DE FISCALIZACION		2013-05-09	0002	48	192.168.1.102	f
3	GERENCIA DE FINANZAS		2013-05-09	0003	48	192.168.1.102	f
4	GERENCIA DE LEGAL		2013-05-09	0004	48	192.168.1.102	f
\.


--
-- TOC entry 3911 (class 0 OID 0)
-- Dependencies: 294
-- Name: tbl_oficinas_id_seq; Type: SEQUENCE SET; Schema: seg; Owner: postgres
--

SELECT pg_catalog.setval('tbl_oficinas_id_seq', 4, true);


--
-- TOC entry 3195 (class 0 OID 21571)
-- Dependencies: 244 3254
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
1840	103	8	1	f
1841	5	8	1	f
1842	6	8	1	f
1843	104	8	1	f
1844	139	8	1	f
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
1772	103	8	1	t
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
\.


--
-- TOC entry 3912 (class 0 OID 0)
-- Dependencies: 245
-- Name: tbl_permiso_id_permiso_seq; Type: SEQUENCE SET; Schema: seg; Owner: postgres
--

SELECT pg_catalog.setval('tbl_permiso_id_permiso_seq', 1845, true);


--
-- TOC entry 3230 (class 0 OID 78878)
-- Dependencies: 282 3254
-- Data for Name: tbl_permiso_trampa; Type: TABLE DATA; Schema: seg; Owner: postgres
--

COPY tbl_permiso_trampa (id_permiso, id_modulo, id_rol, int_permiso, bln_borrado) FROM stdin;
\.


--
-- TOC entry 3913 (class 0 OID 0)
-- Dependencies: 281
-- Name: tbl_permiso_trampa_id_permiso_seq; Type: SEQUENCE SET; Schema: seg; Owner: postgres
--

SELECT pg_catalog.setval('tbl_permiso_trampa_id_permiso_seq', 47, true);


--
-- TOC entry 3197 (class 0 OID 21577)
-- Dependencies: 246 3254
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
-- TOC entry 3914 (class 0 OID 0)
-- Dependencies: 247
-- Name: tbl_rol_id_rol_seq; Type: SEQUENCE SET; Schema: seg; Owner: postgres
--

SELECT pg_catalog.setval('tbl_rol_id_rol_seq', 16, true);


--
-- TOC entry 3199 (class 0 OID 21586)
-- Dependencies: 248 3254
-- Data for Name: tbl_rol_usuario; Type: TABLE DATA; Schema: seg; Owner: postgres
--

COPY tbl_rol_usuario (id_rol_usuario, id_rol, id_usuario, bln_borrado) FROM stdin;
1	1	16	f
19	1	17	f
54	5	47	f
34	2	18	f
56	5	49	f
55	1	48	f
\.


--
-- TOC entry 3915 (class 0 OID 0)
-- Dependencies: 249
-- Name: tbl_rol_usuario_id_rol_usuario_seq; Type: SEQUENCE SET; Schema: seg; Owner: postgres
--

SELECT pg_catalog.setval('tbl_rol_usuario_id_rol_usuario_seq', 56, true);


--
-- TOC entry 3201 (class 0 OID 21592)
-- Dependencies: 250 3254
-- Data for Name: tbl_session_ci; Type: TABLE DATA; Schema: seg; Owner: postgres
--

COPY tbl_session_ci (session_id, ip_address, user_agent, last_activity, user_data) FROM stdin;
f093f9803caa36c8160f5b08bb661a09	127.0.0.1	Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:19.0) Gecko/20100101 Firefox/19.0	1365795522	
\.


--
-- TOC entry 3202 (class 0 OID 21602)
-- Dependencies: 251 3254
-- Data for Name: tbl_usuario_rol; Type: TABLE DATA; Schema: seg; Owner: postgres
--

COPY tbl_usuario_rol (id_usuario_rol, id_usuario, id_rol, bol_borrado) FROM stdin;
\.


--
-- TOC entry 3916 (class 0 OID 0)
-- Dependencies: 252
-- Name: tbl_usuario_rol_id_usuario_rol_seq; Type: SEQUENCE SET; Schema: seg; Owner: postgres
--

SELECT pg_catalog.setval('tbl_usuario_rol_id_usuario_rol_seq', 16, true);


SET search_path = "segContribu", pg_catalog;

--
-- TOC entry 3204 (class 0 OID 22844)
-- Dependencies: 255 3254
-- Data for Name: tbl_modulo_contribu; Type: TABLE DATA; Schema: segContribu; Owner: postgres
--

COPY tbl_modulo_contribu (id_modulo, id_padre, str_nombre, str_descripcion, str_enlace, bln_borrado) FROM stdin;
89	\N	Contribuyente	Modulo Princioal del Contribuyente	#	f
90	89	Seccion	Padre	./mod_contribuyente/principal_c	f
112	101	reparos	listado de reparos	./mod_contribuyente/contribuyente_c/declaraciones_realizadas_enreparo	f
91	90	Cargar datos	carga de datos del contribuyente	./mod_contribuyente/contribuyente_c/planilla_inicial	f
92	\N	Administracion	modulo para la administracion y gestion de la sesion del contribuyente	#	f
101	99	Declaraciones por reparos	modulo para realizar las consulta del historico de sus declaraciones 	./mod_contribuyente/principal_c	f
113	99	Multas impuestas	listado de multas impuestas por procedimientos de reparos o pro periodos extemporaneos	./mod_contribuyente/principal_c	f
97	93	cambio de clave	cambio de clave tabs	./mod_contribuyente/gestion_contrasena_c	f
93	92	Seguridad	cambio de clave	./mod_contribuyente/principal_c	f
98	93	cambio pregunta secreta	cambio depregunta secreta	./mod_contribuyente/gestion_pregunta_secreta_c	f
99	\N	Declaraciones	modulo que gestiona todo lo relacionado con las declaraciones del contribuyente	#	f
100	99	Nueva declaracion	modulo para realizar la declaracion el contribuyente	./mod_contribuyente/principal_c	f
114	113	Multas extemporaneas	multas extemporaneas	./mod_contribuyente/contribuyente_c/listado_multas_extemporaneas	f
103	90	Carga de documentos	documentos complementarios del registro	./mod_contribuyente/filecontroller/documentos	f
106	89	Rep. legal	gestion de representante legal	./mod_contribuyente/principal_c	f
115	113	Multas reparo fiscal	multas por omisos	./nose	f
107	106	Carga de  Rep. legal	craga de representante legal	./mod_contribuyente/contribuyente_c/representante_legal	f
108	100	declarar	vista para la declaracion del contrribuyente	./mod_contribuyente/contribuyente_c/declaracion	f
102	90	Cargar accionistas	modulo para la carga de los accionistas	./mod_contribuyente/contribuyente_c/carga_accionistar	t
109	90	tipo de contribuyente	modulo para la carga del tipo de contribuyente que define al la empresa que se esta registrando	./mod_contribuyente/tipo_contribuyente_c	t
\.


--
-- TOC entry 3917 (class 0 OID 0)
-- Dependencies: 259
-- Name: tbl_modulo_id_modulo_seq; Type: SEQUENCE SET; Schema: segContribu; Owner: postgres
--

SELECT pg_catalog.setval('tbl_modulo_id_modulo_seq', 115, true);


--
-- TOC entry 3205 (class 0 OID 22851)
-- Dependencies: 256 3254
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
\.


--
-- TOC entry 3918 (class 0 OID 0)
-- Dependencies: 260
-- Name: tbl_permiso_id_permiso_seq; Type: SEQUENCE SET; Schema: segContribu; Owner: postgres
--

SELECT pg_catalog.setval('tbl_permiso_id_permiso_seq', 34, true);


--
-- TOC entry 3206 (class 0 OID 22855)
-- Dependencies: 257 3254
-- Data for Name: tbl_rol_contribu; Type: TABLE DATA; Schema: segContribu; Owner: postgres
--

COPY tbl_rol_contribu (id_rol, str_rol, str_descripcion, bln_borrado) FROM stdin;
1	Administrador	Administrador del sistema	f
2	Coordinador	Coordinador de la sala situacional	f
3	Analista	Analista de seguimiento	f
4	Datos Iniciales	Carga Inicial de Datos del contribuyente	f
\.


--
-- TOC entry 3919 (class 0 OID 0)
-- Dependencies: 261
-- Name: tbl_rol_id_rol_seq; Type: SEQUENCE SET; Schema: segContribu; Owner: postgres
--

SELECT pg_catalog.setval('tbl_rol_id_rol_seq', 4, true);


--
-- TOC entry 3207 (class 0 OID 22862)
-- Dependencies: 258 3254
-- Data for Name: tbl_rol_usuario_contribu; Type: TABLE DATA; Schema: segContribu; Owner: postgres
--

COPY tbl_rol_usuario_contribu (id_rol_usuario, id_rol, id_usuario, bln_borrado) FROM stdin;
29	4	43	f
30	4	45	f
32	1	43	f
33	4	46	f
34	1	46	f
35	4	47	f
36	4	44	f
37	1	43	f
38	1	43	f
39	1	43	f
40	1	43	f
41	1	43	f
42	1	43	f
43	1	43	f
44	1	43	f
45	1	43	f
46	1	43	f
47	1	43	f
48	1	43	f
49	1	43	f
50	1	43	f
51	1	45	f
52	4	48	f
53	4	50	f
54	4	51	f
55	4	52	f
56	1	52	f
57	1	43	f
58	4	53	f
59	4	54	f
60	4	55	f
61	1	52	f
62	4	59	f
63	4	62	f
64	1	62	f
65	4	63	f
66	4	64	f
67	4	65	f
68	4	70	f
69	1	70	f
\.


--
-- TOC entry 3920 (class 0 OID 0)
-- Dependencies: 262
-- Name: tbl_rol_usuario_id_rol_usuario_seq; Type: SEQUENCE SET; Schema: segContribu; Owner: postgres
--

SELECT pg_catalog.setval('tbl_rol_usuario_id_rol_usuario_seq', 69, true);


--
-- TOC entry 3212 (class 0 OID 22884)
-- Dependencies: 263 3254
-- Data for Name: tbl_usuario_rol_contribu; Type: TABLE DATA; Schema: segContribu; Owner: postgres
--

COPY tbl_usuario_rol_contribu (id_usuario_rol, id_usuario, id_rol, bol_borrado) FROM stdin;
\.


--
-- TOC entry 3921 (class 0 OID 0)
-- Dependencies: 264
-- Name: tbl_usuario_rol_id_usuario_rol_seq; Type: SEQUENCE SET; Schema: segContribu; Owner: postgres
--

SELECT pg_catalog.setval('tbl_usuario_rol_id_usuario_rol_seq', 16, true);


SET search_path = datos, pg_catalog;

--
-- TOC entry 2799 (class 2606 OID 20855)
-- Dependencies: 226 226 226 3255
-- Name: CT_Accionis_IDContribu_Ci; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY accionis
    ADD CONSTRAINT "CT_Accionis_IDContribu_Ci" UNIQUE (contribuid, ci);


--
-- TOC entry 2596 (class 2606 OID 20857)
-- Dependencies: 167 167 3255
-- Name: CT_ActiExon_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY actiecon
    ADD CONSTRAINT "CT_ActiExon_Nombre" UNIQUE (nombre);


--
-- TOC entry 2601 (class 2606 OID 20859)
-- Dependencies: 169 169 169 3255
-- Name: CT_AlicImp_IDTipoCont_Ano; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY alicimp
    ADD CONSTRAINT "CT_AlicImp_IDTipoCont_Ano" UNIQUE (tipocontid, ano);


--
-- TOC entry 2608 (class 2606 OID 20861)
-- Dependencies: 171 171 171 3255
-- Name: CT_AsiendoD_IDAsiento_Referencia; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY asientod
    ADD CONSTRAINT "CT_AsiendoD_IDAsiento_Referencia" UNIQUE (asientoid, referencia);


--
-- TOC entry 2819 (class 2606 OID 20863)
-- Dependencies: 228 228 3255
-- Name: CT_AsientoM_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY asientom
    ADD CONSTRAINT "CT_AsientoM_Nombre" UNIQUE (nombre);


--
-- TOC entry 2808 (class 2606 OID 20865)
-- Dependencies: 227 227 227 227 3255
-- Name: CT_Asiento_NuAsiento_Mes_Ano; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY asiento
    ADD CONSTRAINT "CT_Asiento_NuAsiento_Mes_Ano" UNIQUE (nuasiento, mes, ano);


--
-- TOC entry 2616 (class 2606 OID 20867)
-- Dependencies: 174 174 3255
-- Name: CT_BaCuenta_Cuenta; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY bacuenta
    ADD CONSTRAINT "CT_BaCuenta_Cuenta" UNIQUE (cuenta);


--
-- TOC entry 2622 (class 2606 OID 20869)
-- Dependencies: 176 176 3255
-- Name: CT_Bancos_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY bancos
    ADD CONSTRAINT "CT_Bancos_Nombre" UNIQUE (nombre);


--
-- TOC entry 2631 (class 2606 OID 20871)
-- Dependencies: 180 180 180 3255
-- Name: CT_CalPagos_Ano_IDTiPeGrav; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY calpago
    ADD CONSTRAINT "CT_CalPagos_Ano_IDTiPeGrav" UNIQUE (ano, tipegravid);


--
-- TOC entry 2633 (class 2606 OID 20873)
-- Dependencies: 180 180 180 3255
-- Name: CT_CalPagos_Nombre_Ano; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY calpago
    ADD CONSTRAINT "CT_CalPagos_Nombre_Ano" UNIQUE (nombre, ano);


--
-- TOC entry 2640 (class 2606 OID 20875)
-- Dependencies: 182 182 3255
-- Name: CT_Cargos_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY cargos
    ADD CONSTRAINT "CT_Cargos_Nombre" UNIQUE (nombre);


--
-- TOC entry 2645 (class 2606 OID 20877)
-- Dependencies: 184 184 184 3255
-- Name: CT_Ciudades_IDEstado_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ciudades
    ADD CONSTRAINT "CT_Ciudades_IDEstado_Nombre" UNIQUE (estadoid, nombre);


--
-- TOC entry 2651 (class 2606 OID 20879)
-- Dependencies: 186 186 186 3255
-- Name: CT_ConUsuCo_IDConUsu_IDContribu; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY conusuco
    ADD CONSTRAINT "CT_ConUsuCo_IDConUsu_IDContribu" UNIQUE (conusuid, contribuid);


--
-- TOC entry 2660 (class 2606 OID 20881)
-- Dependencies: 190 190 3255
-- Name: CT_ConUsuTo_Token; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY conusuto
    ADD CONSTRAINT "CT_ConUsuTo_Token" UNIQUE (token);


--
-- TOC entry 2665 (class 2606 OID 20883)
-- Dependencies: 192 192 3255
-- Name: CT_ConUsu_Email; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY conusu
    ADD CONSTRAINT "CT_ConUsu_Email" UNIQUE (email);


--
-- TOC entry 2667 (class 2606 OID 20885)
-- Dependencies: 192 192 3255
-- Name: CT_ConUsu_Login; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY conusu
    ADD CONSTRAINT "CT_ConUsu_Login" UNIQUE (login);


--
-- TOC entry 2829 (class 2606 OID 20887)
-- Dependencies: 232 232 232 3255
-- Name: CT_ContribuTi_ContribuID_TipoContID; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY contributi
    ADD CONSTRAINT "CT_ContribuTi_ContribuID_TipoContID" UNIQUE (contribuid, tipocontid);


--
-- TOC entry 2675 (class 2606 OID 20889)
-- Dependencies: 194 194 3255
-- Name: CT_Contribu_NumRegCine; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY contribu
    ADD CONSTRAINT "CT_Contribu_NumRegCine" UNIQUE (numregcine);


--
-- TOC entry 2677 (class 2606 OID 20891)
-- Dependencies: 194 194 3255
-- Name: CT_Contribu_RazonSocia; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY contribu
    ADD CONSTRAINT "CT_Contribu_RazonSocia" UNIQUE (razonsocia);


--
-- TOC entry 2679 (class 2606 OID 20893)
-- Dependencies: 194 194 3255
-- Name: CT_Contribu_Rif; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY contribu
    ADD CONSTRAINT "CT_Contribu_Rif" UNIQUE (rif);


--
-- TOC entry 2926 (class 2606 OID 79007)
-- Dependencies: 285 285 3255
-- Name: CT_Decla_NuDeclara; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT "CT_Decla_NuDeclara" UNIQUE (nudeclara);


--
-- TOC entry 2928 (class 2606 OID 79009)
-- Dependencies: 285 285 3255
-- Name: CT_Decla_NuDeposito; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT "CT_Decla_NuDeposito" UNIQUE (nudeposito);


--
-- TOC entry 2688 (class 2606 OID 46589)
-- Dependencies: 196 196 3255
-- Name: CT_Declara_NuDeclara; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY declara_viejo
    ADD CONSTRAINT "CT_Declara_NuDeclara" UNIQUE (nudeclara);


--
-- TOC entry 2690 (class 2606 OID 46608)
-- Dependencies: 196 196 3255
-- Name: CT_Declara_NuDeposito; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY declara_viejo
    ADD CONSTRAINT "CT_Declara_NuDeposito" UNIQUE (nudeposito);


--
-- TOC entry 2704 (class 2606 OID 20899)
-- Dependencies: 198 198 3255
-- Name: CT_Departam_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY departam
    ADD CONSTRAINT "CT_Departam_Nombre" UNIQUE (nombre);


--
-- TOC entry 2838 (class 2606 OID 20901)
-- Dependencies: 235 235 3255
-- Name: CT_Document_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY document
    ADD CONSTRAINT "CT_Document_Nombre" UNIQUE (nombre);


--
-- TOC entry 2709 (class 2606 OID 20903)
-- Dependencies: 200 200 200 3255
-- Name: CT_EntidadD_IDEntidad_Accion; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY entidadd
    ADD CONSTRAINT "CT_EntidadD_IDEntidad_Accion" UNIQUE (entidadid, accion);


--
-- TOC entry 2711 (class 2606 OID 20905)
-- Dependencies: 200 200 200 3255
-- Name: CT_EntidadD_IDEntidad_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY entidadd
    ADD CONSTRAINT "CT_EntidadD_IDEntidad_Nombre" UNIQUE (entidadid, nombre);


--
-- TOC entry 2713 (class 2606 OID 20907)
-- Dependencies: 200 200 200 3255
-- Name: CT_EntidadD_IDEntidad_Orden; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY entidadd
    ADD CONSTRAINT "CT_EntidadD_IDEntidad_Orden" UNIQUE (entidadid, orden);


--
-- TOC entry 2721 (class 2606 OID 20909)
-- Dependencies: 202 202 3255
-- Name: CT_Entidad_Entidad; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY entidad
    ADD CONSTRAINT "CT_Entidad_Entidad" UNIQUE (entidad);


--
-- TOC entry 2723 (class 2606 OID 20911)
-- Dependencies: 202 202 3255
-- Name: CT_Entidad_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY entidad
    ADD CONSTRAINT "CT_Entidad_Nombre" UNIQUE (nombre);


--
-- TOC entry 2725 (class 2606 OID 20913)
-- Dependencies: 202 202 3255
-- Name: CT_Entidad_Orden; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY entidad
    ADD CONSTRAINT "CT_Entidad_Orden" UNIQUE (orden);


--
-- TOC entry 2729 (class 2606 OID 20915)
-- Dependencies: 204 204 3255
-- Name: CT_Estados_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY estados
    ADD CONSTRAINT "CT_Estados_Nombre" UNIQUE (nombre);


--
-- TOC entry 2734 (class 2606 OID 20917)
-- Dependencies: 206 206 206 3255
-- Name: CT_PerUsuD_IDPerUsu_IDEntidadD; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY perusud
    ADD CONSTRAINT "CT_PerUsuD_IDPerUsu_IDEntidadD" UNIQUE (perusuid, entidaddid);


--
-- TOC entry 2741 (class 2606 OID 20919)
-- Dependencies: 208 208 3255
-- Name: CT_PerUsu_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY perusu
    ADD CONSTRAINT "CT_PerUsu_Nombre" UNIQUE (nombre);


--
-- TOC entry 2746 (class 2606 OID 20921)
-- Dependencies: 210 210 3255
-- Name: CT_PregSecr_Pregunta; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY pregsecr
    ADD CONSTRAINT "CT_PregSecr_Pregunta" UNIQUE (nombre);


--
-- TOC entry 2751 (class 2606 OID 20923)
-- Dependencies: 212 212 212 3255
-- Name: CT_RepLegal_IDContribu_Ci; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY replegal
    ADD CONSTRAINT "CT_RepLegal_IDContribu_Ci" UNIQUE (contribuid, ci);


--
-- TOC entry 2762 (class 2606 OID 20925)
-- Dependencies: 214 214 3255
-- Name: CT_TDeclara_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tdeclara
    ADD CONSTRAINT "CT_TDeclara_Nombre" UNIQUE (nombre);


--
-- TOC entry 2767 (class 2606 OID 20927)
-- Dependencies: 216 216 3255
-- Name: CT_TiPeGrav_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tipegrav
    ADD CONSTRAINT "CT_TiPeGrav_Nombre" UNIQUE (nombre);


--
-- TOC entry 2772 (class 2606 OID 20929)
-- Dependencies: 218 218 3255
-- Name: CT_TipoCont_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tipocont
    ADD CONSTRAINT "CT_TipoCont_Nombre" UNIQUE (nombre);


--
-- TOC entry 2851 (class 2606 OID 20931)
-- Dependencies: 238 238 3255
-- Name: CT_TmpContri_NumRegCine; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tmpcontri
    ADD CONSTRAINT "CT_TmpContri_NumRegCine" UNIQUE (numregcine);


--
-- TOC entry 2853 (class 2606 OID 20933)
-- Dependencies: 238 238 3255
-- Name: CT_TmpContri_RazonSocia; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tmpcontri
    ADD CONSTRAINT "CT_TmpContri_RazonSocia" UNIQUE (razonsocia);


--
-- TOC entry 2855 (class 2606 OID 20935)
-- Dependencies: 238 238 3255
-- Name: CT_TmpContri_Rif; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tmpcontri
    ADD CONSTRAINT "CT_TmpContri_Rif" UNIQUE (rif);


--
-- TOC entry 2865 (class 2606 OID 20937)
-- Dependencies: 239 239 239 3255
-- Name: CT_TmpReLegal_IDContribu_Ci; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tmprelegal
    ADD CONSTRAINT "CT_TmpReLegal_IDContribu_Ci" UNIQUE (contribuid, ci);


--
-- TOC entry 2788 (class 2606 OID 20939)
-- Dependencies: 224 224 3255
-- Name: CT_USFonPro_Email; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY usfonpro
    ADD CONSTRAINT "CT_USFonPro_Email" UNIQUE (email);


--
-- TOC entry 2778 (class 2606 OID 20941)
-- Dependencies: 220 220 3255
-- Name: CT_UndTrib_Fecha; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY undtrib
    ADD CONSTRAINT "CT_UndTrib_Fecha" UNIQUE (fecha);


--
-- TOC entry 2783 (class 2606 OID 20943)
-- Dependencies: 222 222 3255
-- Name: CT_UsFonpTo_Token; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY usfonpto
    ADD CONSTRAINT "CT_UsFonpTo_Token" UNIQUE (token);


--
-- TOC entry 2790 (class 2606 OID 20945)
-- Dependencies: 224 224 3255
-- Name: CT_UsFonpro_Login; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY usfonpro
    ADD CONSTRAINT "CT_UsFonpro_Login" UNIQUE (login);


--
-- TOC entry 2843 (class 2606 OID 20947)
-- Dependencies: 237 237 237 3255
-- Name: CT_tmpAccioni_ContribuID_Ci; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tmpaccioni
    ADD CONSTRAINT "CT_tmpAccioni_ContribuID_Ci" UNIQUE (contribuid, ci);


--
-- TOC entry 2806 (class 2606 OID 20949)
-- Dependencies: 226 226 3255
-- Name: PK_Accionis; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY accionis
    ADD CONSTRAINT "PK_Accionis" PRIMARY KEY (id);


--
-- TOC entry 2599 (class 2606 OID 20951)
-- Dependencies: 167 167 3255
-- Name: PK_ActiEcon; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY actiecon
    ADD CONSTRAINT "PK_ActiEcon" PRIMARY KEY (id);

ALTER TABLE actiecon CLUSTER ON "PK_ActiEcon";


--
-- TOC entry 2606 (class 2606 OID 20953)
-- Dependencies: 169 169 3255
-- Name: PK_AlicImp; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY alicimp
    ADD CONSTRAINT "PK_AlicImp" PRIMARY KEY (id);

ALTER TABLE alicimp CLUSTER ON "PK_AlicImp";


--
-- TOC entry 2817 (class 2606 OID 20955)
-- Dependencies: 227 227 3255
-- Name: PK_Asiento; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY asiento
    ADD CONSTRAINT "PK_Asiento" PRIMARY KEY (id);

ALTER TABLE asiento CLUSTER ON "PK_Asiento";


--
-- TOC entry 2614 (class 2606 OID 20957)
-- Dependencies: 171 171 3255
-- Name: PK_AsientoD; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY asientod
    ADD CONSTRAINT "PK_AsientoD" PRIMARY KEY (id);

ALTER TABLE asientod CLUSTER ON "PK_AsientoD";


--
-- TOC entry 2822 (class 2606 OID 20959)
-- Dependencies: 228 228 3255
-- Name: PK_AsientoM; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY asientom
    ADD CONSTRAINT "PK_AsientoM" PRIMARY KEY (id);

ALTER TABLE asientom CLUSTER ON "PK_AsientoM";


--
-- TOC entry 2827 (class 2606 OID 20961)
-- Dependencies: 230 230 3255
-- Name: PK_AsientoMD; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY asientomd
    ADD CONSTRAINT "PK_AsientoMD" PRIMARY KEY (id);

ALTER TABLE asientomd CLUSTER ON "PK_AsientoMD";


--
-- TOC entry 2620 (class 2606 OID 20963)
-- Dependencies: 174 174 3255
-- Name: PK_BaCuenta; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY bacuenta
    ADD CONSTRAINT "PK_BaCuenta" PRIMARY KEY (id);

ALTER TABLE bacuenta CLUSTER ON "PK_BaCuenta";


--
-- TOC entry 2625 (class 2606 OID 20965)
-- Dependencies: 176 176 3255
-- Name: PK_Bancos; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY bancos
    ADD CONSTRAINT "PK_Bancos" PRIMARY KEY (id);

ALTER TABLE bancos CLUSTER ON "PK_Bancos";


--
-- TOC entry 2629 (class 2606 OID 20967)
-- Dependencies: 178 178 3255
-- Name: PK_CalPagoD; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY calpagod
    ADD CONSTRAINT "PK_CalPagoD" PRIMARY KEY (id);

ALTER TABLE calpagod CLUSTER ON "PK_CalPagoD";


--
-- TOC entry 2638 (class 2606 OID 20969)
-- Dependencies: 180 180 3255
-- Name: PK_CalPagos; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY calpago
    ADD CONSTRAINT "PK_CalPagos" PRIMARY KEY (id);

ALTER TABLE calpago CLUSTER ON "PK_CalPagos";


--
-- TOC entry 2643 (class 2606 OID 20971)
-- Dependencies: 182 182 3255
-- Name: PK_Cargos; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY cargos
    ADD CONSTRAINT "PK_Cargos" PRIMARY KEY (id);

ALTER TABLE cargos CLUSTER ON "PK_Cargos";


--
-- TOC entry 2649 (class 2606 OID 20973)
-- Dependencies: 184 184 3255
-- Name: PK_Ciudades; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ciudades
    ADD CONSTRAINT "PK_Ciudades" PRIMARY KEY (id);

ALTER TABLE ciudades CLUSTER ON "PK_Ciudades";


--
-- TOC entry 2673 (class 2606 OID 20975)
-- Dependencies: 192 192 3255
-- Name: PK_ConUsu; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY conusu
    ADD CONSTRAINT "PK_ConUsu" PRIMARY KEY (id);

ALTER TABLE conusu CLUSTER ON "PK_ConUsu";


--
-- TOC entry 2655 (class 2606 OID 20977)
-- Dependencies: 186 186 3255
-- Name: PK_ConUsuCo; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY conusuco
    ADD CONSTRAINT "PK_ConUsuCo" PRIMARY KEY (id);

ALTER TABLE conusuco CLUSTER ON "PK_ConUsuCo";


--
-- TOC entry 2658 (class 2606 OID 20979)
-- Dependencies: 188 188 3255
-- Name: PK_ConUsuTi; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY conusuti
    ADD CONSTRAINT "PK_ConUsuTi" PRIMARY KEY (id);

ALTER TABLE conusuti CLUSTER ON "PK_ConUsuTi";


--
-- TOC entry 2663 (class 2606 OID 20981)
-- Dependencies: 190 190 3255
-- Name: PK_ConUsuTo; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY conusuto
    ADD CONSTRAINT "PK_ConUsuTo" PRIMARY KEY (id);

ALTER TABLE conusuto CLUSTER ON "PK_ConUsuTo";


--
-- TOC entry 2686 (class 2606 OID 20983)
-- Dependencies: 194 194 3255
-- Name: PK_Contribu; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY contribu
    ADD CONSTRAINT "PK_Contribu" PRIMARY KEY (id);

ALTER TABLE contribu CLUSTER ON "PK_Contribu";


--
-- TOC entry 2833 (class 2606 OID 20985)
-- Dependencies: 232 232 3255
-- Name: PK_ContribuTi; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY contributi
    ADD CONSTRAINT "PK_ContribuTi" PRIMARY KEY (id);

ALTER TABLE contributi CLUSTER ON "PK_ContribuTi";


--
-- TOC entry 2836 (class 2606 OID 20987)
-- Dependencies: 234 234 3255
-- Name: PK_CtaConta; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ctaconta
    ADD CONSTRAINT "PK_CtaConta" PRIMARY KEY (cuenta);

ALTER TABLE ctaconta CLUSTER ON "PK_CtaConta";


--
-- TOC entry 2940 (class 2606 OID 79005)
-- Dependencies: 285 285 3255
-- Name: PK_Decla; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT "PK_Decla" PRIMARY KEY (id);


--
-- TOC entry 2702 (class 2606 OID 20989)
-- Dependencies: 196 196 3255
-- Name: PK_Declara; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY declara_viejo
    ADD CONSTRAINT "PK_Declara" PRIMARY KEY (id);

ALTER TABLE declara_viejo CLUSTER ON "PK_Declara";


--
-- TOC entry 2706 (class 2606 OID 20991)
-- Dependencies: 198 198 3255
-- Name: PK_Departam; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY departam
    ADD CONSTRAINT "PK_Departam" PRIMARY KEY (id);

ALTER TABLE departam CLUSTER ON "PK_Departam";


--
-- TOC entry 2841 (class 2606 OID 20993)
-- Dependencies: 235 235 3255
-- Name: PK_Document; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY document
    ADD CONSTRAINT "PK_Document" PRIMARY KEY (id);

ALTER TABLE document CLUSTER ON "PK_Document";


--
-- TOC entry 2727 (class 2606 OID 20995)
-- Dependencies: 202 202 3255
-- Name: PK_Entidad; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY entidad
    ADD CONSTRAINT "PK_Entidad" PRIMARY KEY (id);

ALTER TABLE entidad CLUSTER ON "PK_Entidad";


--
-- TOC entry 2719 (class 2606 OID 20997)
-- Dependencies: 200 200 3255
-- Name: PK_EntidadD; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY entidadd
    ADD CONSTRAINT "PK_EntidadD" PRIMARY KEY (id);

ALTER TABLE entidadd CLUSTER ON "PK_EntidadD";


--
-- TOC entry 2732 (class 2606 OID 20999)
-- Dependencies: 204 204 3255
-- Name: PK_Estados; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY estados
    ADD CONSTRAINT "PK_Estados" PRIMARY KEY (id);

ALTER TABLE estados CLUSTER ON "PK_Estados";


--
-- TOC entry 2739 (class 2606 OID 21001)
-- Dependencies: 206 206 3255
-- Name: PK_PerUsuD; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY perusud
    ADD CONSTRAINT "PK_PerUsuD" PRIMARY KEY (id);

ALTER TABLE perusud CLUSTER ON "PK_PerUsuD";


--
-- TOC entry 2744 (class 2606 OID 21003)
-- Dependencies: 208 208 3255
-- Name: PK_PerUsu_IDPerUsu; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY perusu
    ADD CONSTRAINT "PK_PerUsu_IDPerUsu" PRIMARY KEY (id);

ALTER TABLE perusu CLUSTER ON "PK_PerUsu_IDPerUsu";


--
-- TOC entry 2749 (class 2606 OID 21005)
-- Dependencies: 210 210 3255
-- Name: PK_PregSecr; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY pregsecr
    ADD CONSTRAINT "PK_PregSecr" PRIMARY KEY (id);

ALTER TABLE pregsecr CLUSTER ON "PK_PregSecr";


--
-- TOC entry 2760 (class 2606 OID 21007)
-- Dependencies: 212 212 3255
-- Name: PK_RepLegal; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY replegal
    ADD CONSTRAINT "PK_RepLegal" PRIMARY KEY (id);

ALTER TABLE replegal CLUSTER ON "PK_RepLegal";


--
-- TOC entry 2765 (class 2606 OID 21009)
-- Dependencies: 214 214 3255
-- Name: PK_TDeclara; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tdeclara
    ADD CONSTRAINT "PK_TDeclara" PRIMARY KEY (id);

ALTER TABLE tdeclara CLUSTER ON "PK_TDeclara";


--
-- TOC entry 2770 (class 2606 OID 21011)
-- Dependencies: 216 216 3255
-- Name: PK_TiPeGrav; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tipegrav
    ADD CONSTRAINT "PK_TiPeGrav" PRIMARY KEY (id);

ALTER TABLE tipegrav CLUSTER ON "PK_TiPeGrav";


--
-- TOC entry 2776 (class 2606 OID 21013)
-- Dependencies: 218 218 3255
-- Name: PK_TipoCont; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tipocont
    ADD CONSTRAINT "PK_TipoCont" PRIMARY KEY (id);

ALTER TABLE tipocont CLUSTER ON "PK_TipoCont";


--
-- TOC entry 2863 (class 2606 OID 21015)
-- Dependencies: 238 238 3255
-- Name: PK_TmpContri; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tmpcontri
    ADD CONSTRAINT "PK_TmpContri" PRIMARY KEY (id);


--
-- TOC entry 2873 (class 2606 OID 21017)
-- Dependencies: 239 239 3255
-- Name: PK_TmpReLegal; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tmprelegal
    ADD CONSTRAINT "PK_TmpReLegal" PRIMARY KEY (id);


--
-- TOC entry 2781 (class 2606 OID 21019)
-- Dependencies: 220 220 3255
-- Name: PK_UndTrib; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY undtrib
    ADD CONSTRAINT "PK_UndTrib" PRIMARY KEY (id);

ALTER TABLE undtrib CLUSTER ON "PK_UndTrib";


--
-- TOC entry 2797 (class 2606 OID 21021)
-- Dependencies: 224 224 3255
-- Name: PK_UsFonPro; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY usfonpro
    ADD CONSTRAINT "PK_UsFonPro" PRIMARY KEY (id);

ALTER TABLE usfonpro CLUSTER ON "PK_UsFonPro";


--
-- TOC entry 2786 (class 2606 OID 21023)
-- Dependencies: 222 222 3255
-- Name: PK_UsFonpTo; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY usfonpto
    ADD CONSTRAINT "PK_UsFonpTo" PRIMARY KEY (id);

ALTER TABLE usfonpto CLUSTER ON "PK_UsFonpTo";


--
-- TOC entry 2954 (class 2606 OID 79226)
-- Dependencies: 291 291 3255
-- Name: PK_contribcalc; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY contrib_calc
    ADD CONSTRAINT "PK_contribcalc" PRIMARY KEY (id);


--
-- TOC entry 2950 (class 2606 OID 79140)
-- Dependencies: 288 288 3255
-- Name: PK_reparos; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY reparos
    ADD CONSTRAINT "PK_reparos" PRIMARY KEY (id);


--
-- TOC entry 2849 (class 2606 OID 21025)
-- Dependencies: 237 237 3255
-- Name: PK_tmpAccioni; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tmpaccioni
    ADD CONSTRAINT "PK_tmpAccioni" PRIMARY KEY (id);


--
-- TOC entry 2924 (class 2606 OID 78912)
-- Dependencies: 284 284 3255
-- Name: fk-asignacion-fiscla; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY asignacion_fiscales
    ADD CONSTRAINT "fk-asignacion-fiscla" PRIMARY KEY (id);


--
-- TOC entry 2968 (class 2606 OID 87792)
-- Dependencies: 305 305 3255
-- Name: pk-correlativo-actas; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY correlativos_actas
    ADD CONSTRAINT "pk-correlativo-actas" PRIMARY KEY (id);


--
-- TOC entry 2916 (class 2606 OID 77301)
-- Dependencies: 275 275 3255
-- Name: pk-interesbcv; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY interes_bcv
    ADD CONSTRAINT "pk-interesbcv" PRIMARY KEY (id);


--
-- TOC entry 2904 (class 2606 OID 46448)
-- Dependencies: 267 267 3255
-- Name: pk_con_img_doc; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY con_img_doc
    ADD CONSTRAINT pk_con_img_doc PRIMARY KEY (id);


--
-- TOC entry 2966 (class 2606 OID 87746)
-- Dependencies: 301 301 3255
-- Name: pk_conusu_interno; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY conusu_interno
    ADD CONSTRAINT pk_conusu_interno PRIMARY KEY (id);


--
-- TOC entry 2908 (class 2606 OID 69005)
-- Dependencies: 270 270 3255
-- Name: pk_conusu_tipocont; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY conusu_tipocont
    ADD CONSTRAINT pk_conusu_tipocont PRIMARY KEY (id);


--
-- TOC entry 2964 (class 2606 OID 87647)
-- Dependencies: 299 299 3255
-- Name: pk_deta_contirbcalc; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY detalles_contrib_calc
    ADD CONSTRAINT pk_deta_contirbcalc PRIMARY KEY (id);


--
-- TOC entry 2918 (class 2606 OID 77340)
-- Dependencies: 278 278 3255
-- Name: pk_detalle_interes; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY detalle_interes
    ADD CONSTRAINT pk_detalle_interes PRIMARY KEY (id);


--
-- TOC entry 2920 (class 2606 OID 78849)
-- Dependencies: 280 280 3255
-- Name: pk_detalle_interes_n; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY detalle_interes_viejo
    ADD CONSTRAINT pk_detalle_interes_n PRIMARY KEY (id);


--
-- TOC entry 2942 (class 2606 OID 79072)
-- Dependencies: 287 287 3255
-- Name: pk_detalles_fiscalizacion; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY dettalles_fizcalizacion
    ADD CONSTRAINT pk_detalles_fiscalizacion PRIMARY KEY (id);


--
-- TOC entry 2910 (class 2606 OID 69012)
-- Dependencies: 270 270 270 3255
-- Name: uq_tipoconid; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY conusu_tipocont
    ADD CONSTRAINT uq_tipoconid UNIQUE (conusuid, tipocontid);


SET search_path = historial, pg_catalog;

--
-- TOC entry 2880 (class 2606 OID 21027)
-- Dependencies: 240 240 3255
-- Name: PK_Bitacora; Type: CONSTRAINT; Schema: historial; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY bitacora
    ADD CONSTRAINT "PK_Bitacora" PRIMARY KEY (id);

ALTER TABLE bitacora CLUSTER ON "PK_Bitacora";


SET search_path = pre_aprobacion, pg_catalog;

--
-- TOC entry 2956 (class 2606 OID 87510)
-- Dependencies: 293 293 3255
-- Name: PK_datos_cnac; Type: CONSTRAINT; Schema: pre_aprobacion; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY datos_cnac
    ADD CONSTRAINT "PK_datos_cnac" PRIMARY KEY (id);


--
-- TOC entry 2914 (class 2606 OID 77277)
-- Dependencies: 274 274 3255
-- Name: pk-intereses; Type: CONSTRAINT; Schema: pre_aprobacion; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY intereses
    ADD CONSTRAINT "pk-intereses" PRIMARY KEY (id);


--
-- TOC entry 2912 (class 2606 OID 77256)
-- Dependencies: 272 272 3255
-- Name: pk-multa; Type: CONSTRAINT; Schema: pre_aprobacion; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY multas
    ADD CONSTRAINT "pk-multa" PRIMARY KEY (id);


SET search_path = public, pg_catalog;

--
-- TOC entry 2952 (class 2606 OID 79205)
-- Dependencies: 289 289 3255
-- Name: pk_contribucalc; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY contrib_calc
    ADD CONSTRAINT pk_contribucalc PRIMARY KEY (id);


SET search_path = seg, pg_catalog;

--
-- TOC entry 2958 (class 2606 OID 87580)
-- Dependencies: 295 295 3255
-- Name: CT_oficinas_cod_estructura; Type: CONSTRAINT; Schema: seg; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_oficinas
    ADD CONSTRAINT "CT_oficinas_cod_estructura" UNIQUE (cod_estructura);


--
-- TOC entry 2906 (class 2606 OID 46581)
-- Dependencies: 268 268 3255
-- Name: pk_ci_sessions; Type: CONSTRAINT; Schema: seg; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_ci_sessions
    ADD CONSTRAINT pk_ci_sessions PRIMARY KEY (session_id);


--
-- TOC entry 2882 (class 2606 OID 21614)
-- Dependencies: 242 242 3255
-- Name: pk_modulo; Type: CONSTRAINT; Schema: seg; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_modulo
    ADD CONSTRAINT pk_modulo PRIMARY KEY (id_modulo);


--
-- TOC entry 2960 (class 2606 OID 87578)
-- Dependencies: 295 295 3255
-- Name: pk_oficinas; Type: CONSTRAINT; Schema: seg; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_oficinas
    ADD CONSTRAINT pk_oficinas PRIMARY KEY (id);


--
-- TOC entry 2884 (class 2606 OID 21616)
-- Dependencies: 244 244 3255
-- Name: pk_permiso; Type: CONSTRAINT; Schema: seg; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_permiso
    ADD CONSTRAINT pk_permiso PRIMARY KEY (id_permiso);


--
-- TOC entry 2886 (class 2606 OID 21618)
-- Dependencies: 246 246 3255
-- Name: pk_rol; Type: CONSTRAINT; Schema: seg; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_rol
    ADD CONSTRAINT pk_rol PRIMARY KEY (id_rol);


--
-- TOC entry 2888 (class 2606 OID 21620)
-- Dependencies: 248 248 3255
-- Name: pk_rol_usuario; Type: CONSTRAINT; Schema: seg; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_rol_usuario
    ADD CONSTRAINT pk_rol_usuario PRIMARY KEY (id_rol_usuario);


--
-- TOC entry 2962 (class 2606 OID 87616)
-- Dependencies: 297 297 3255
-- Name: pk_tblcargos; Type: CONSTRAINT; Schema: seg; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_cargos
    ADD CONSTRAINT pk_tblcargos PRIMARY KEY (id);


--
-- TOC entry 2892 (class 2606 OID 21622)
-- Dependencies: 251 251 3255
-- Name: pk_usuario_rol; Type: CONSTRAINT; Schema: seg; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_usuario_rol
    ADD CONSTRAINT pk_usuario_rol PRIMARY KEY (id_usuario_rol);


--
-- TOC entry 2922 (class 2606 OID 78884)
-- Dependencies: 282 282 3255
-- Name: pkt_permiso; Type: CONSTRAINT; Schema: seg; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_permiso_trampa
    ADD CONSTRAINT pkt_permiso PRIMARY KEY (id_permiso);


--
-- TOC entry 2890 (class 2606 OID 21624)
-- Dependencies: 250 250 3255
-- Name: tbl_session_ci_pkey; Type: CONSTRAINT; Schema: seg; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_session_ci
    ADD CONSTRAINT tbl_session_ci_pkey PRIMARY KEY (session_id);


SET search_path = "segContribu", pg_catalog;

--
-- TOC entry 2894 (class 2606 OID 22901)
-- Dependencies: 255 255 3255
-- Name: pk_modulo; Type: CONSTRAINT; Schema: segContribu; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_modulo_contribu
    ADD CONSTRAINT pk_modulo PRIMARY KEY (id_modulo);


--
-- TOC entry 2896 (class 2606 OID 22903)
-- Dependencies: 256 256 3255
-- Name: pk_permiso; Type: CONSTRAINT; Schema: segContribu; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_permiso_contribu
    ADD CONSTRAINT pk_permiso PRIMARY KEY (id_permiso);


--
-- TOC entry 2898 (class 2606 OID 22905)
-- Dependencies: 257 257 3255
-- Name: pk_rol; Type: CONSTRAINT; Schema: segContribu; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_rol_contribu
    ADD CONSTRAINT pk_rol PRIMARY KEY (id_rol);


--
-- TOC entry 2900 (class 2606 OID 22907)
-- Dependencies: 258 258 3255
-- Name: pk_rol_usuario; Type: CONSTRAINT; Schema: segContribu; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_rol_usuario_contribu
    ADD CONSTRAINT pk_rol_usuario PRIMARY KEY (id_rol_usuario);


--
-- TOC entry 2902 (class 2606 OID 22909)
-- Dependencies: 263 263 3255
-- Name: pk_usuario_rol; Type: CONSTRAINT; Schema: segContribu; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_usuario_rol_contribu
    ADD CONSTRAINT pk_usuario_rol PRIMARY KEY (id_usuario_rol);


SET search_path = datos, pg_catalog;

--
-- TOC entry 2800 (class 1259 OID 46550)
-- Dependencies: 226 3255
-- Name: FKI_Accionis_IDContribu; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Accionis_IDContribu" ON accionis USING btree (contribuid);


--
-- TOC entry 2801 (class 1259 OID 21029)
-- Dependencies: 226 3255
-- Name: FKI_Accionis_UsFonpro_UsuarioID_ID; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Accionis_UsFonpro_UsuarioID_ID" ON accionis USING btree (usuarioid);


--
-- TOC entry 2597 (class 1259 OID 21031)
-- Dependencies: 167 3255
-- Name: FKI_ActiEcon_USFonpro_IDUsuario_IDUsFornpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_ActiEcon_USFonpro_IDUsuario_IDUsFornpro" ON actiecon USING btree (usuarioid);


--
-- TOC entry 2602 (class 1259 OID 21032)
-- Dependencies: 169 3255
-- Name: FKI_AlicImp_TipoCont_IDTipoCont; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_AlicImp_TipoCont_IDTipoCont" ON alicimp USING btree (tipocontid);


--
-- TOC entry 2603 (class 1259 OID 21033)
-- Dependencies: 169 3255
-- Name: FKI_AlicImp_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_AlicImp_UsFonpro_IDUsuario_IDUsFonpro" ON alicimp USING btree (usuarioid);


--
-- TOC entry 2609 (class 1259 OID 21034)
-- Dependencies: 171 3255
-- Name: FKI_AsientoD_Asiento_IDAsiento; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_AsientoD_Asiento_IDAsiento" ON asientod USING btree (asientoid);


--
-- TOC entry 2610 (class 1259 OID 21036)
-- Dependencies: 171 3255
-- Name: FKI_AsientoD_CtaConta_Cuenta; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_AsientoD_CtaConta_Cuenta" ON asientod USING btree (cuenta);


--
-- TOC entry 2611 (class 1259 OID 21037)
-- Dependencies: 171 3255
-- Name: FKI_AsientoD_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_AsientoD_UsFonpro_IDUsuario_IDUsFonpro" ON asientod USING btree (usuarioid);


--
-- TOC entry 2823 (class 1259 OID 21038)
-- Dependencies: 230 3255
-- Name: FKI_AsientoMD_AsientoM_AsientoMID_ID; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_AsientoMD_AsientoM_AsientoMID_ID" ON asientomd USING btree (asientomid);


--
-- TOC entry 2824 (class 1259 OID 21039)
-- Dependencies: 230 3255
-- Name: FKI_AsientoMD_CtaConta_Cuenta; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_AsientoMD_CtaConta_Cuenta" ON asientomd USING btree (cuenta);


--
-- TOC entry 2825 (class 1259 OID 21040)
-- Dependencies: 230 3255
-- Name: FKI_AsientoMD_UsFonpro_UsuarioID_ID; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_AsientoMD_UsFonpro_UsuarioID_ID" ON asientomd USING btree (usuarioid);


--
-- TOC entry 2820 (class 1259 OID 21041)
-- Dependencies: 228 3255
-- Name: FKI_AsientoM_UsFonpro_UsuarioID_ID; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_AsientoM_UsFonpro_UsuarioID_ID" ON asientom USING btree (usuarioid);


--
-- TOC entry 2809 (class 1259 OID 21042)
-- Dependencies: 227 3255
-- Name: FKI_Asiento_UsFonpro_IDUsCierre_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Asiento_UsFonpro_IDUsCierre_IDUsFonpro" ON asiento USING btree (uscierreid);


--
-- TOC entry 2810 (class 1259 OID 21043)
-- Dependencies: 227 3255
-- Name: FKI_Asiento_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Asiento_UsFonpro_IDUsuario_IDUsFonpro" ON asiento USING btree (usuarioid);


--
-- TOC entry 2617 (class 1259 OID 21044)
-- Dependencies: 174 3255
-- Name: FKI_BaCuenta_Bancos_IDBanco; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_BaCuenta_Bancos_IDBanco" ON bacuenta USING btree (bancoid);


--
-- TOC entry 2618 (class 1259 OID 21045)
-- Dependencies: 174 3255
-- Name: FKI_BaCuenta_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_BaCuenta_UsFonpro_IDUsuario_IDUsFonpro" ON bacuenta USING btree (usuarioid);


--
-- TOC entry 2623 (class 1259 OID 21046)
-- Dependencies: 176 3255
-- Name: FKI_Bancos_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Bancos_UsFonpro_IDUsuario_IDUsFonpro" ON bancos USING btree (usuarioid);


--
-- TOC entry 2626 (class 1259 OID 21047)
-- Dependencies: 178 3255
-- Name: FKI_CalPagoD_CalPago_IDCalPago; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_CalPagoD_CalPago_IDCalPago" ON calpagod USING btree (calpagoid);


--
-- TOC entry 2627 (class 1259 OID 21048)
-- Dependencies: 178 3255
-- Name: FKI_CalPagoD_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_CalPagoD_UsFonpro_IDUsuario_IDUsFonpro" ON calpagod USING btree (usuarioid);


--
-- TOC entry 2634 (class 1259 OID 21049)
-- Dependencies: 180 3255
-- Name: FKI_CalPago_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_CalPago_UsFonpro_IDUsuario_IDUsFonpro" ON calpago USING btree (usuarioid);


--
-- TOC entry 2635 (class 1259 OID 21050)
-- Dependencies: 180 3255
-- Name: FKI_CalPagos_TiPeGrav_IDTiPeGrav; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_CalPagos_TiPeGrav_IDTiPeGrav" ON calpago USING btree (tipegravid);


--
-- TOC entry 2641 (class 1259 OID 21051)
-- Dependencies: 182 3255
-- Name: FKI_Cargos_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Cargos_UsFonpro_IDUsuario_IDUsFonpro" ON cargos USING btree (usuarioid);


--
-- TOC entry 2646 (class 1259 OID 21052)
-- Dependencies: 184 3255
-- Name: FKI_Ciudades_Estados_IDEstado; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Ciudades_Estados_IDEstado" ON ciudades USING btree (estadoid);


--
-- TOC entry 2647 (class 1259 OID 21053)
-- Dependencies: 184 3255
-- Name: FKI_Ciudades_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Ciudades_UsFonpro_IDUsuario_IDUsFonpro" ON ciudades USING btree (usuarioid);


--
-- TOC entry 2652 (class 1259 OID 21054)
-- Dependencies: 186 3255
-- Name: FKI_ConUsuCo_ConUsu_IDConUsu; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_ConUsuCo_ConUsu_IDConUsu" ON conusuco USING btree (conusuid);


--
-- TOC entry 2653 (class 1259 OID 21055)
-- Dependencies: 186 3255
-- Name: FKI_ConUsuCo_Contribu_IDContribu; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_ConUsuCo_Contribu_IDContribu" ON conusuco USING btree (contribuid);


--
-- TOC entry 2656 (class 1259 OID 21056)
-- Dependencies: 188 3255
-- Name: FKI_ConUsuTi_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_ConUsuTi_UsFonpro_IDUsuario_IDUsFonpro" ON conusuti USING btree (usuarioid);


--
-- TOC entry 2661 (class 1259 OID 21057)
-- Dependencies: 190 3255
-- Name: FKI_ConUsuTo_ConUsu_IDConUsu; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_ConUsuTo_ConUsu_IDConUsu" ON conusuto USING btree (conusuid);


--
-- TOC entry 2668 (class 1259 OID 21058)
-- Dependencies: 192 3255
-- Name: FKI_ConUsu_ConUsuTi_IDConUsuTi; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_ConUsu_ConUsuTi_IDConUsuTi" ON conusu USING btree (conusutiid);


--
-- TOC entry 2669 (class 1259 OID 21059)
-- Dependencies: 192 3255
-- Name: FKI_ConUsu_PregSecr_IDPregSecr; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_ConUsu_PregSecr_IDPregSecr" ON conusu USING btree (pregsecrid);


--
-- TOC entry 2670 (class 1259 OID 21060)
-- Dependencies: 192 3255
-- Name: FKI_ConUsu_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_ConUsu_UsFonpro_IDUsuario_IDUsFonpro" ON conusu USING btree (usuarioid);


--
-- TOC entry 2830 (class 1259 OID 21061)
-- Dependencies: 232 3255
-- Name: FKI_ContribuTi_Contribu_ContribuID_ID; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_ContribuTi_Contribu_ContribuID_ID" ON contributi USING btree (contribuid);


--
-- TOC entry 2831 (class 1259 OID 21062)
-- Dependencies: 232 3255
-- Name: FKI_ContribuTi_TipoCont_TipoContID_ID; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_ContribuTi_TipoCont_TipoContID_ID" ON contributi USING btree (tipocontid);


--
-- TOC entry 2680 (class 1259 OID 21063)
-- Dependencies: 194 3255
-- Name: FKI_Contribu_ActiEcon_IDActiEcon; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Contribu_ActiEcon_IDActiEcon" ON contribu USING btree (actieconid);


--
-- TOC entry 2681 (class 1259 OID 21064)
-- Dependencies: 194 3255
-- Name: FKI_Contribu_Ciudades_IDCiudad; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Contribu_Ciudades_IDCiudad" ON contribu USING btree (ciudadid);


--
-- TOC entry 2682 (class 1259 OID 21065)
-- Dependencies: 194 3255
-- Name: FKI_Contribu_ConUsu_UsuarioID_ID; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Contribu_ConUsu_UsuarioID_ID" ON contribu USING btree (usuarioid);


--
-- TOC entry 2683 (class 1259 OID 21066)
-- Dependencies: 194 3255
-- Name: FKI_Contribu_Estados_IDEstado; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Contribu_Estados_IDEstado" ON contribu USING btree (estadoid);


--
-- TOC entry 2834 (class 1259 OID 21067)
-- Dependencies: 234 3255
-- Name: FKI_CtaConta_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_CtaConta_UsFonpro_IDUsuario_IDUsFonpro" ON ctaconta USING btree (usuarioid);


--
-- TOC entry 2929 (class 1259 OID 79050)
-- Dependencies: 285 3255
-- Name: FKI_Decla_Asiento_IDAsiento; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Decla_Asiento_IDAsiento" ON declara USING btree (asientoid);


--
-- TOC entry 2930 (class 1259 OID 79051)
-- Dependencies: 285 3255
-- Name: FKI_Decla_PlaSustID_ID; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Decla_PlaSustID_ID" ON declara USING btree (plasustid);


--
-- TOC entry 2931 (class 1259 OID 79052)
-- Dependencies: 285 3255
-- Name: FKI_Decla_RepLegal_IDRepLegal; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Decla_RepLegal_IDRepLegal" ON declara USING btree (replegalid);


--
-- TOC entry 2932 (class 1259 OID 79053)
-- Dependencies: 285 3255
-- Name: FKI_Decla_TDeclara_IDTDeclara; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Decla_TDeclara_IDTDeclara" ON declara USING btree (tdeclaraid);


--
-- TOC entry 2933 (class 1259 OID 79054)
-- Dependencies: 285 3255
-- Name: FKI_Decla_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Decla_UsFonpro_IDUsuario_IDUsFonpro" ON declara USING btree (usuarioid);


--
-- TOC entry 2691 (class 1259 OID 21068)
-- Dependencies: 196 3255
-- Name: FKI_Declara_Asiento_IDAsiento; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Declara_Asiento_IDAsiento" ON declara_viejo USING btree (asientoid);


--
-- TOC entry 2692 (class 1259 OID 21070)
-- Dependencies: 196 3255
-- Name: FKI_Declara_PlaSustID_ID; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Declara_PlaSustID_ID" ON declara_viejo USING btree (plasustid);


--
-- TOC entry 2693 (class 1259 OID 21071)
-- Dependencies: 196 3255
-- Name: FKI_Declara_RepLegal_IDRepLegal; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Declara_RepLegal_IDRepLegal" ON declara_viejo USING btree (replegalid);


--
-- TOC entry 2694 (class 1259 OID 21072)
-- Dependencies: 196 3255
-- Name: FKI_Declara_TDeclara_IDTDeclara; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Declara_TDeclara_IDTDeclara" ON declara_viejo USING btree (tdeclaraid);


--
-- TOC entry 2695 (class 1259 OID 21073)
-- Dependencies: 196 3255
-- Name: FKI_Declara_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Declara_UsFonpro_IDUsuario_IDUsFonpro" ON declara_viejo USING btree (usuarioid);


--
-- TOC entry 2839 (class 1259 OID 21074)
-- Dependencies: 235 3255
-- Name: FKI_Document_UsFonpro_UsFonproID_ID; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Document_UsFonpro_UsFonproID_ID" ON document USING btree (usfonproid);


--
-- TOC entry 2714 (class 1259 OID 21075)
-- Dependencies: 200 3255
-- Name: FKI_EntidadD_Entidad_IDEntidad; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_EntidadD_Entidad_IDEntidad" ON entidadd USING btree (entidadid);


--
-- TOC entry 2730 (class 1259 OID 21076)
-- Dependencies: 204 3255
-- Name: FKI_Estados_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Estados_UsFonpro_IDUsuario_IDUsFonpro" ON estados USING btree (usuarioid);


--
-- TOC entry 2735 (class 1259 OID 21077)
-- Dependencies: 206 3255
-- Name: FKI_PerUsuD_EndidadD_IDEntidadD; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_PerUsuD_EndidadD_IDEntidadD" ON perusud USING btree (entidaddid);


--
-- TOC entry 2736 (class 1259 OID 21078)
-- Dependencies: 206 3255
-- Name: FKI_PerUsuD_PerUsu_IDPerUsu; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_PerUsuD_PerUsu_IDPerUsu" ON perusud USING btree (perusuid);


--
-- TOC entry 2737 (class 1259 OID 21079)
-- Dependencies: 206 3255
-- Name: FKI_PerUsuD_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_PerUsuD_UsFonpro_IDUsuario_IDUsFonpro" ON perusud USING btree (usuarioid);


--
-- TOC entry 2742 (class 1259 OID 21080)
-- Dependencies: 208 3255
-- Name: FKI_PerUsu_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_PerUsu_UsFonpro_IDUsuario_IDUsFonpro" ON perusu USING btree (usuarioid);


--
-- TOC entry 2747 (class 1259 OID 21081)
-- Dependencies: 210 3255
-- Name: FKI_PregSecr_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_PregSecr_UsFonpro_IDUsuario_IDUsFonpro" ON pregsecr USING btree (usuarioid);


--
-- TOC entry 2752 (class 1259 OID 21082)
-- Dependencies: 212 3255
-- Name: FKI_RepLegal_IDCiudad; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_RepLegal_IDCiudad" ON replegal USING btree (ciudadid);


--
-- TOC entry 2753 (class 1259 OID 21083)
-- Dependencies: 212 3255
-- Name: FKI_RepLegal_IDContribu; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_RepLegal_IDContribu" ON replegal USING btree (contribuid);


--
-- TOC entry 2754 (class 1259 OID 21084)
-- Dependencies: 212 3255
-- Name: FKI_RepLegal_IDEstado; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_RepLegal_IDEstado" ON replegal USING btree (estadoid);


--
-- TOC entry 2755 (class 1259 OID 21085)
-- Dependencies: 212 3255
-- Name: FKI_RepLegal_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_RepLegal_UsFonpro_IDUsuario_IDUsFonpro" ON replegal USING btree (usuarioid);


--
-- TOC entry 2763 (class 1259 OID 21086)
-- Dependencies: 214 3255
-- Name: FKI_TDeclara_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TDeclara_UsFonpro_IDUsuario_IDUsFonpro" ON tdeclara USING btree (usuarioid);


--
-- TOC entry 2768 (class 1259 OID 21087)
-- Dependencies: 216 3255
-- Name: FKI_TiPeGrav_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TiPeGrav_UsFonpro_IDUsuario_IDUsFonpro" ON tipegrav USING btree (usuarioid);


--
-- TOC entry 2773 (class 1259 OID 21088)
-- Dependencies: 218 3255
-- Name: FKI_TipoCont_TiPeGrav_IDTiPeGrav; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TipoCont_TiPeGrav_IDTiPeGrav" ON tipocont USING btree (tipegravid);


--
-- TOC entry 2774 (class 1259 OID 21089)
-- Dependencies: 218 3255
-- Name: FKI_TipoCont_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TipoCont_UsFonpro_IDUsuario_IDUsFonpro" ON tipocont USING btree (usuarioid);


--
-- TOC entry 2856 (class 1259 OID 21090)
-- Dependencies: 238 3255
-- Name: FKI_TmpContri_ActiEcon_IDActiEcon; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TmpContri_ActiEcon_IDActiEcon" ON tmpcontri USING btree (actieconid);


--
-- TOC entry 2857 (class 1259 OID 21091)
-- Dependencies: 238 3255
-- Name: FKI_TmpContri_Ciudades_IDCiudad; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TmpContri_Ciudades_IDCiudad" ON tmpcontri USING btree (ciudadid);


--
-- TOC entry 2858 (class 1259 OID 21092)
-- Dependencies: 238 3255
-- Name: FKI_TmpContri_Contribu_IDContribu; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TmpContri_Contribu_IDContribu" ON tmpcontri USING btree (id);


--
-- TOC entry 2859 (class 1259 OID 21093)
-- Dependencies: 238 3255
-- Name: FKI_TmpContri_Estados_IDEstado; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TmpContri_Estados_IDEstado" ON tmpcontri USING btree (estadoid);


--
-- TOC entry 2860 (class 1259 OID 21094)
-- Dependencies: 238 3255
-- Name: FKI_TmpContri_TipoCont_IDTipoCont; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TmpContri_TipoCont_IDTipoCont" ON tmpcontri USING btree (tipocontid);


--
-- TOC entry 2866 (class 1259 OID 21095)
-- Dependencies: 239 3255
-- Name: FKI_TmpReLegal_IDCiudad; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TmpReLegal_IDCiudad" ON tmprelegal USING btree (ciudadid);


--
-- TOC entry 2867 (class 1259 OID 21096)
-- Dependencies: 239 3255
-- Name: FKI_TmpReLegal_IDContribu; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TmpReLegal_IDContribu" ON tmprelegal USING btree (contribuid);


--
-- TOC entry 2868 (class 1259 OID 21097)
-- Dependencies: 239 3255
-- Name: FKI_TmpReLegal_IDEstado; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TmpReLegal_IDEstado" ON tmprelegal USING btree (estadoid);


--
-- TOC entry 2779 (class 1259 OID 21098)
-- Dependencies: 220 3255
-- Name: FKI_UndTrib_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_UndTrib_UsFonpro_IDUsuario_IDUsFonpro" ON undtrib USING btree (usuarioid);


--
-- TOC entry 2791 (class 1259 OID 21099)
-- Dependencies: 224 3255
-- Name: FKI_UsFonPro_PregSecr_IDPregSecr; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_UsFonPro_PregSecr_IDPregSecr" ON usfonpro USING btree (pregsecrid);


--
-- TOC entry 2784 (class 1259 OID 21100)
-- Dependencies: 222 3255
-- Name: FKI_UsFonpTo_UsFonpro_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_UsFonpTo_UsFonpro_IDUsFonpro" ON usfonpto USING btree (usfonproid);


--
-- TOC entry 2792 (class 1259 OID 21101)
-- Dependencies: 224 3255
-- Name: FKI_UsFonpro_Cargos_IDCargo; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_UsFonpro_Cargos_IDCargo" ON usfonpro USING btree (cargoid);


--
-- TOC entry 2793 (class 1259 OID 21102)
-- Dependencies: 224 3255
-- Name: FKI_UsFonpro_Departam_IDDepartam; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_UsFonpro_Departam_IDDepartam" ON usfonpro USING btree (departamid);


--
-- TOC entry 2794 (class 1259 OID 21103)
-- Dependencies: 224 3255
-- Name: FKI_UsFonpro_PerUsu_IDPerUsu; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_UsFonpro_PerUsu_IDPerUsu" ON usfonpro USING btree (perusuid);


--
-- TOC entry 2943 (class 1259 OID 79166)
-- Dependencies: 288 3255
-- Name: FKI_reparos_Asiento_IDAsiento; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_reparos_Asiento_IDAsiento" ON reparos USING btree (asientoid);


--
-- TOC entry 2944 (class 1259 OID 79168)
-- Dependencies: 288 3255
-- Name: FKI_reparos_TDeclara_IDTDeclara; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_reparos_TDeclara_IDTDeclara" ON reparos USING btree (tdeclaraid);


--
-- TOC entry 2945 (class 1259 OID 79169)
-- Dependencies: 288 3255
-- Name: FKI_reparos_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_reparos_UsFonpro_IDUsuario_IDUsFonpro" ON reparos USING btree (usuarioid);


--
-- TOC entry 2844 (class 1259 OID 21104)
-- Dependencies: 237 3255
-- Name: FKI_tmpAccioni_IDContribu; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_tmpAccioni_IDContribu" ON tmpaccioni USING btree (contribuid);


--
-- TOC entry 2802 (class 1259 OID 21105)
-- Dependencies: 226 3255
-- Name: IX_Accionis_Apellido; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Accionis_Apellido" ON accionis USING btree (apellido);


--
-- TOC entry 2803 (class 1259 OID 21106)
-- Dependencies: 226 3255
-- Name: IX_Accionis_Ci; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Accionis_Ci" ON accionis USING btree (ci);


--
-- TOC entry 2804 (class 1259 OID 21107)
-- Dependencies: 226 3255
-- Name: IX_Accionis_Nombre; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Accionis_Nombre" ON accionis USING btree (nombre);


--
-- TOC entry 2604 (class 1259 OID 21108)
-- Dependencies: 169 3255
-- Name: IX_AlicImp_Ano; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_AlicImp_Ano" ON alicimp USING btree (ano);


--
-- TOC entry 2612 (class 1259 OID 21109)
-- Dependencies: 171 3255
-- Name: IX_AsientoD_Fecha; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_AsientoD_Fecha" ON asientod USING btree (fecha);


--
-- TOC entry 2811 (class 1259 OID 21110)
-- Dependencies: 227 3255
-- Name: IX_Asiento_Ano; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Asiento_Ano" ON asiento USING btree (ano);


--
-- TOC entry 2812 (class 1259 OID 21111)
-- Dependencies: 227 3255
-- Name: IX_Asiento_Cerrado; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Asiento_Cerrado" ON asiento USING btree (cerrado);


--
-- TOC entry 2813 (class 1259 OID 21112)
-- Dependencies: 227 3255
-- Name: IX_Asiento_Fecha; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Asiento_Fecha" ON asiento USING btree (fecha);


--
-- TOC entry 2814 (class 1259 OID 21113)
-- Dependencies: 227 3255
-- Name: IX_Asiento_Mes; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Asiento_Mes" ON asiento USING btree (mes);


--
-- TOC entry 2815 (class 1259 OID 21114)
-- Dependencies: 227 3255
-- Name: IX_Asiento_NuAsiento; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Asiento_NuAsiento" ON asiento USING btree (nuasiento);


--
-- TOC entry 2636 (class 1259 OID 21115)
-- Dependencies: 180 3255
-- Name: IX_CalPagos_Ano; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_CalPagos_Ano" ON calpago USING btree (ano);


--
-- TOC entry 2671 (class 1259 OID 21116)
-- Dependencies: 192 3255
-- Name: IX_ConUsu_Password; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_ConUsu_Password" ON conusu USING btree (password);


--
-- TOC entry 2684 (class 1259 OID 21117)
-- Dependencies: 194 3255
-- Name: IX_Contribu_DenComerci; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Contribu_DenComerci" ON contribu USING btree (dencomerci);


--
-- TOC entry 2934 (class 1259 OID 79055)
-- Dependencies: 285 3255
-- Name: IX_Decla_FechaConci; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Decla_FechaConci" ON declara USING btree (fechaconci);


--
-- TOC entry 2935 (class 1259 OID 79056)
-- Dependencies: 285 3255
-- Name: IX_Decla_FechaElab; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Decla_FechaElab" ON declara USING btree (fechaelab);


--
-- TOC entry 2936 (class 1259 OID 79057)
-- Dependencies: 285 3255
-- Name: IX_Decla_FechaFin; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Decla_FechaFin" ON declara USING btree (fechafin);


--
-- TOC entry 2937 (class 1259 OID 79058)
-- Dependencies: 285 3255
-- Name: IX_Decla_FechaIni; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Decla_FechaIni" ON declara USING btree (fechaini);


--
-- TOC entry 2938 (class 1259 OID 79059)
-- Dependencies: 285 3255
-- Name: IX_Decla_FechaPago; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Decla_FechaPago" ON declara USING btree (fechapago);


--
-- TOC entry 2696 (class 1259 OID 21118)
-- Dependencies: 196 3255
-- Name: IX_Declara_FechaConci; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Declara_FechaConci" ON declara_viejo USING btree (fechaconci);


--
-- TOC entry 2697 (class 1259 OID 21119)
-- Dependencies: 196 3255
-- Name: IX_Declara_FechaElab; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Declara_FechaElab" ON declara_viejo USING btree (fechaelab);


--
-- TOC entry 2698 (class 1259 OID 21120)
-- Dependencies: 196 3255
-- Name: IX_Declara_FechaFin; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Declara_FechaFin" ON declara_viejo USING btree (fechafin);


--
-- TOC entry 2699 (class 1259 OID 21121)
-- Dependencies: 196 3255
-- Name: IX_Declara_FechaIni; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Declara_FechaIni" ON declara_viejo USING btree (fechaini);


--
-- TOC entry 2700 (class 1259 OID 21122)
-- Dependencies: 196 3255
-- Name: IX_Declara_FechaPago; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Declara_FechaPago" ON declara_viejo USING btree (fechapago);


--
-- TOC entry 2715 (class 1259 OID 21123)
-- Dependencies: 200 3255
-- Name: IX_EntidadD_Accion; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_EntidadD_Accion" ON entidadd USING btree (accion);


--
-- TOC entry 2716 (class 1259 OID 21124)
-- Dependencies: 200 3255
-- Name: IX_EntidadD_Nombre; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_EntidadD_Nombre" ON entidadd USING btree (nombre);


--
-- TOC entry 2717 (class 1259 OID 21125)
-- Dependencies: 200 3255
-- Name: IX_EntidadD_Orden; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_EntidadD_Orden" ON entidadd USING btree (orden);


--
-- TOC entry 2756 (class 1259 OID 21126)
-- Dependencies: 212 3255
-- Name: IX_RepLegal_Apellido; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_RepLegal_Apellido" ON replegal USING btree (apellido);


--
-- TOC entry 2757 (class 1259 OID 21127)
-- Dependencies: 212 3255
-- Name: IX_RepLegal_Ci; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_RepLegal_Ci" ON replegal USING btree (ci);


--
-- TOC entry 2758 (class 1259 OID 21128)
-- Dependencies: 212 3255
-- Name: IX_RepLegal_Nombre; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_RepLegal_Nombre" ON replegal USING btree (nombre);


--
-- TOC entry 2861 (class 1259 OID 21129)
-- Dependencies: 238 3255
-- Name: IX_TmpContri_DenComerci; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_TmpContri_DenComerci" ON tmpcontri USING btree (dencomerci);


--
-- TOC entry 2869 (class 1259 OID 21130)
-- Dependencies: 239 3255
-- Name: IX_TmpReLegalNombre; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_TmpReLegalNombre" ON tmprelegal USING btree (nombre);


--
-- TOC entry 2870 (class 1259 OID 21131)
-- Dependencies: 239 3255
-- Name: IX_TmpReLegal_Apellido; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_TmpReLegal_Apellido" ON tmprelegal USING btree (apellido);


--
-- TOC entry 2871 (class 1259 OID 21132)
-- Dependencies: 239 3255
-- Name: IX_TmpReLegal_Ci; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_TmpReLegal_Ci" ON tmprelegal USING btree (ci);


--
-- TOC entry 2795 (class 1259 OID 21133)
-- Dependencies: 224 3255
-- Name: IX_UsFonPro_Password; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_UsFonPro_Password" ON usfonpro USING btree (password);


--
-- TOC entry 2946 (class 1259 OID 79170)
-- Dependencies: 288 3255
-- Name: IX_reparos_FechaConci; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_reparos_FechaConci" ON reparos USING btree (fechaconci);


--
-- TOC entry 2947 (class 1259 OID 79171)
-- Dependencies: 288 3255
-- Name: IX_reparos_FechaElab; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_reparos_FechaElab" ON reparos USING btree (fechaelab);


--
-- TOC entry 2948 (class 1259 OID 79172)
-- Dependencies: 288 3255
-- Name: IX_reparos_FechaPago; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_reparos_FechaPago" ON reparos USING btree (fechapago);


--
-- TOC entry 2845 (class 1259 OID 21134)
-- Dependencies: 237 3255
-- Name: IX_tmpAccioni_Apellido; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_tmpAccioni_Apellido" ON tmpaccioni USING btree (apellido);


--
-- TOC entry 2846 (class 1259 OID 21135)
-- Dependencies: 237 3255
-- Name: IX_tmpAccioni_Ci; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_tmpAccioni_Ci" ON tmpaccioni USING btree (ci);


--
-- TOC entry 2847 (class 1259 OID 21136)
-- Dependencies: 237 3255
-- Name: IX_tmpAccioni_Nombre; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_tmpAccioni_Nombre" ON tmpaccioni USING btree (nombre);


--
-- TOC entry 2707 (class 1259 OID 21137)
-- Dependencies: 198 3255
-- Name: fki_FL_Departam_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "fki_FL_Departam_UsFonpro_IDUsuario_IDUsFonpro" ON departam USING btree (usuarioid);


SET search_path = historial, pg_catalog;

--
-- TOC entry 2874 (class 1259 OID 21138)
-- Dependencies: 240 3255
-- Name: IX_Accion; Type: INDEX; Schema: historial; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Accion" ON bitacora USING btree (accion);


--
-- TOC entry 2875 (class 1259 OID 21139)
-- Dependencies: 240 3255
-- Name: IX_Fecha; Type: INDEX; Schema: historial; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Fecha" ON bitacora USING btree (fecha);


--
-- TOC entry 2876 (class 1259 OID 21140)
-- Dependencies: 240 3255
-- Name: IX_IDUsuario; Type: INDEX; Schema: historial; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_IDUsuario" ON bitacora USING btree (idusuario);


--
-- TOC entry 2877 (class 1259 OID 21141)
-- Dependencies: 240 3255
-- Name: IX_Tabla; Type: INDEX; Schema: historial; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Tabla" ON bitacora USING btree (tabla);


--
-- TOC entry 2878 (class 1259 OID 21142)
-- Dependencies: 240 3255
-- Name: IX_ValDelID; Type: INDEX; Schema: historial; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_ValDelID" ON bitacora USING btree (valdelid);


SET search_path = datos, pg_catalog;

--
-- TOC entry 2415 (class 2618 OID 21648)
-- Dependencies: 248 246 246 246 244 244 224 244 244 242 242 242 242 242 224 224 224 2797 248 248 253 3255
-- Name: _RETURN; Type: RULE; Schema: datos; Owner: postgres
--

CREATE RULE "_RETURN" AS ON SELECT TO view_modulo_usuario_contribuyente_permiso DO INSTEAD SELECT usu.id, usu.nombre, rol.str_rol, per.id_modulo, mod.str_nombre, mod.str_enlace, max(per.int_permiso) AS int_permiso, CASE WHEN (mod.id_padre IS NULL) THEN (mod.id_modulo * 10) ELSE ((mod.id_padre * 10) + mod.id_modulo) END AS int_orden, CASE WHEN (mod.id_padre IS NULL) THEN (0)::bigint ELSE mod.id_padre END AS id_padre FROM ((((usfonpro usu JOIN seg.tbl_rol_usuario rus ON ((usu.id = rus.id_usuario))) JOIN seg.tbl_rol rol ON ((rus.id_rol = rol.id_rol))) JOIN seg.tbl_permiso per ON ((rol.id_rol = per.id_rol))) JOIN seg.tbl_modulo mod ON ((per.id_modulo = mod.id_modulo))) WHERE (((((NOT usu.inactivo) AND (NOT rus.bln_borrado)) AND (NOT rol.bln_borrado)) AND (NOT per.bln_borrado)) AND (NOT mod.bln_borrado)) GROUP BY usu.id, usu.login, rol.str_rol, per.id_modulo, mod.str_nombre, mod.str_enlace, mod.id_padre, mod.id_modulo;


SET search_path = seg, pg_catalog;

--
-- TOC entry 2416 (class 2618 OID 21653)
-- Dependencies: 242 224 224 224 224 242 242 242 242 244 244 244 244 246 246 246 248 248 248 2797 254 3255
-- Name: _RETURN; Type: RULE; Schema: seg; Owner: postgres
--

CREATE RULE "_RETURN" AS ON SELECT TO view_modulo_usuario_permiso DO INSTEAD SELECT usu.id, usu.nombre, rol.str_rol, per.id_modulo, mod.str_nombre, mod.str_enlace, max(per.int_permiso) AS int_permiso, CASE WHEN (mod.id_padre IS NULL) THEN (mod.id_modulo * 10) ELSE ((mod.id_padre * 10) + mod.id_modulo) END AS int_orden, CASE WHEN (mod.id_padre IS NULL) THEN (0)::bigint ELSE mod.id_padre END AS id_padre FROM ((((datos.usfonpro usu JOIN tbl_rol_usuario rus ON ((usu.id = rus.id_usuario))) JOIN tbl_rol rol ON ((rus.id_rol = rol.id_rol))) JOIN tbl_permiso per ON ((rol.id_rol = per.id_rol))) JOIN tbl_modulo mod ON ((per.id_modulo = mod.id_modulo))) WHERE (((((NOT usu.inactivo) AND (NOT rus.bln_borrado)) AND (NOT rol.bln_borrado)) AND (NOT per.bln_borrado)) AND (NOT mod.bln_borrado)) GROUP BY usu.id, usu.login, rol.str_rol, per.id_modulo, mod.str_nombre, mod.str_enlace, mod.id_padre, mod.id_modulo;


SET search_path = "segContribu", pg_catalog;

--
-- TOC entry 2417 (class 2618 OID 22893)
-- Dependencies: 255 2673 258 258 192 255 255 255 258 257 257 257 256 256 256 256 255 192 192 265 3255
-- Name: _RETURN; Type: RULE; Schema: segContribu; Owner: postgres
--

CREATE RULE "_RETURN" AS ON SELECT TO view_modulo_usuariocontribuyente_permiso DO INSTEAD SELECT usu.id, usu.nombre, rol.str_rol, per.id_modulo, mod.str_nombre, mod.str_enlace, max(per.int_permiso) AS int_permiso, CASE WHEN (mod.id_padre IS NULL) THEN (mod.id_modulo * 10) ELSE ((mod.id_padre * 10) + mod.id_modulo) END AS int_orden, CASE WHEN (mod.id_padre IS NULL) THEN (0)::bigint ELSE mod.id_padre END AS id_padre FROM ((((datos.conusu usu JOIN tbl_rol_usuario_contribu rus ON ((usu.id = rus.id_usuario))) JOIN tbl_rol_contribu rol ON ((rus.id_rol = rol.id_rol))) JOIN tbl_permiso_contribu per ON ((rol.id_rol = per.id_rol))) JOIN tbl_modulo_contribu mod ON ((per.id_modulo = mod.id_modulo))) WHERE ((((NOT rus.bln_borrado) AND (NOT rol.bln_borrado)) AND (NOT per.bln_borrado)) AND (NOT mod.bln_borrado)) GROUP BY usu.id, usu.login, rol.str_rol, per.id_modulo, mod.str_nombre, mod.str_enlace, mod.id_padre, mod.id_modulo;


SET search_path = datos, pg_catalog;

--
-- TOC entry 3110 (class 2620 OID 21143)
-- Dependencies: 227 325 227 227 3255
-- Name: TG_Asiendo_ActualizaSaldo; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_Asiendo_ActualizaSaldo" BEFORE UPDATE OF debe, haber ON asiento FOR EACH ROW EXECUTE PROCEDURE "tf_Asiento_ActualizaSaldo"();


--
-- TOC entry 3922 (class 0 OID 0)
-- Dependencies: 3110
-- Name: TRIGGER "TG_Asiendo_ActualizaSaldo" ON asiento; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_Asiendo_ActualizaSaldo" ON asiento IS 'Trigger que actualiza el saldo del asiento';


--
-- TOC entry 3087 (class 2620 OID 21144)
-- Dependencies: 171 323 3255
-- Name: TG_AsientoD_ActualizaDebeHaber_Asiento; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_AsientoD_ActualizaDebeHaber_Asiento" AFTER INSERT OR DELETE OR UPDATE ON asientod FOR EACH ROW EXECUTE PROCEDURE "tf_AsiendoD_ActualizaDebeHaber_Asiento"();


--
-- TOC entry 3923 (class 0 OID 0)
-- Dependencies: 3087
-- Name: TRIGGER "TG_AsientoD_ActualizaDebeHaber_Asiento" ON asientod; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_AsientoD_ActualizaDebeHaber_Asiento" ON asientod IS 'Trigger que actualiza el debe y haber de la tabla de asiento';


--
-- TOC entry 3088 (class 2620 OID 21145)
-- Dependencies: 171 326 3255
-- Name: TG_AsientoD_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_AsientoD_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON asientod FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();


--
-- TOC entry 3924 (class 0 OID 0)
-- Dependencies: 3088
-- Name: TRIGGER "TG_AsientoD_Bitacora" ON asientod; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_AsientoD_Bitacora" ON asientod IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3113 (class 2620 OID 21146)
-- Dependencies: 228 326 3255
-- Name: TG_AsientoM_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_AsientoM_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON asientom FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();


--
-- TOC entry 3925 (class 0 OID 0)
-- Dependencies: 3113
-- Name: TRIGGER "TG_AsientoM_Bitacora" ON asientom; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_AsientoM_Bitacora" ON asientom IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3111 (class 2620 OID 21147)
-- Dependencies: 227 324 227 3255
-- Name: TG_Asiento_Actualiza_Mes_Ano; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_Asiento_Actualiza_Mes_Ano" BEFORE INSERT OR UPDATE OF fecha ON asiento FOR EACH ROW EXECUTE PROCEDURE "tf_Asiento_ActualizaPeriodo"();


--
-- TOC entry 3112 (class 2620 OID 21148)
-- Dependencies: 326 227 3255
-- Name: TG_Asiento_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_Asiento_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON asiento FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();


--
-- TOC entry 3926 (class 0 OID 0)
-- Dependencies: 3112
-- Name: TRIGGER "TG_Asiento_Bitacora" ON asiento; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_Asiento_Bitacora" ON asiento IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3089 (class 2620 OID 21149)
-- Dependencies: 326 174 3255
-- Name: TG_BaCuenta_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_BaCuenta_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON bacuenta FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();


--
-- TOC entry 3927 (class 0 OID 0)
-- Dependencies: 3089
-- Name: TRIGGER "TG_BaCuenta_Bitacora" ON bacuenta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_BaCuenta_Bitacora" ON bacuenta IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3090 (class 2620 OID 21150)
-- Dependencies: 326 176 3255
-- Name: TG_Bancos_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_Bancos_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON bancos FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();


--
-- TOC entry 3928 (class 0 OID 0)
-- Dependencies: 3090
-- Name: TRIGGER "TG_Bancos_Bitacora" ON bancos; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_Bancos_Bitacora" ON bancos IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3093 (class 2620 OID 21151)
-- Dependencies: 326 182 3255
-- Name: TG_Cargos_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_Cargos_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON cargos FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE cargos DISABLE TRIGGER "TG_Cargos_Bitacora";


--
-- TOC entry 3929 (class 0 OID 0)
-- Dependencies: 3093
-- Name: TRIGGER "TG_Cargos_Bitacora" ON cargos; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_Cargos_Bitacora" ON cargos IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3096 (class 2620 OID 21152)
-- Dependencies: 326 192 3255
-- Name: TG_ConUsu_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_ConUsu_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON conusu FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE conusu DISABLE TRIGGER "TG_ConUsu_Bitacora";


--
-- TOC entry 3930 (class 0 OID 0)
-- Dependencies: 3096
-- Name: TRIGGER "TG_ConUsu_Bitacora" ON conusu; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_ConUsu_Bitacora" ON conusu IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3114 (class 2620 OID 21153)
-- Dependencies: 234 326 3255
-- Name: TG_CtaConta_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_CtaConta_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON ctaconta FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();


--
-- TOC entry 3931 (class 0 OID 0)
-- Dependencies: 3114
-- Name: TRIGGER "TG_CtaConta_Bitacora" ON ctaconta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_CtaConta_Bitacora" ON ctaconta IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3098 (class 2620 OID 21154)
-- Dependencies: 326 198 3255
-- Name: TG_Departam_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_Departam_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON departam FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE departam DISABLE TRIGGER "TG_Departam_Bitacora";


--
-- TOC entry 3932 (class 0 OID 0)
-- Dependencies: 3098
-- Name: TRIGGER "TG_Departam_Bitacora" ON departam; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_Departam_Bitacora" ON departam IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3100 (class 2620 OID 21155)
-- Dependencies: 206 326 3255
-- Name: TG_PerUsuD_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_PerUsuD_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON perusud FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();


--
-- TOC entry 3933 (class 0 OID 0)
-- Dependencies: 3100
-- Name: TRIGGER "TG_PerUsuD_Bitacora" ON perusud; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_PerUsuD_Bitacora" ON perusud IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3101 (class 2620 OID 21156)
-- Dependencies: 208 326 3255
-- Name: TG_PerUsu_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_PerUsu_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON perusu FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();


--
-- TOC entry 3934 (class 0 OID 0)
-- Dependencies: 3101
-- Name: TRIGGER "TG_PerUsu_Bitacora" ON perusu; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_PerUsu_Bitacora" ON perusu IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3102 (class 2620 OID 21157)
-- Dependencies: 326 210 3255
-- Name: TG_PregSecr_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_PregSecr_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON pregsecr FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE pregsecr DISABLE TRIGGER "TG_PregSecr_Bitacora";


--
-- TOC entry 3935 (class 0 OID 0)
-- Dependencies: 3102
-- Name: TRIGGER "TG_PregSecr_Bitacora" ON pregsecr; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_PregSecr_Bitacora" ON pregsecr IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3104 (class 2620 OID 21158)
-- Dependencies: 214 326 3255
-- Name: TG_TDeclara_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_TDeclara_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON tdeclara FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE tdeclara DISABLE TRIGGER "TG_TDeclara_Bitacora";


--
-- TOC entry 3936 (class 0 OID 0)
-- Dependencies: 3104
-- Name: TRIGGER "TG_TDeclara_Bitacora" ON tdeclara; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_TDeclara_Bitacora" ON tdeclara IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3107 (class 2620 OID 21159)
-- Dependencies: 326 220 3255
-- Name: TG_UndTrib_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_UndTrib_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON undtrib FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE undtrib DISABLE TRIGGER "TG_UndTrib_Bitacora";


--
-- TOC entry 3937 (class 0 OID 0)
-- Dependencies: 3107
-- Name: TRIGGER "TG_UndTrib_Bitacora" ON undtrib; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_UndTrib_Bitacora" ON undtrib IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3108 (class 2620 OID 22974)
-- Dependencies: 224 224 224 224 224 224 224 326 224 224 224 224 224 224 3255
-- Name: TG_UsFonpro_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_UsFonpro_Bitacora" AFTER INSERT OR DELETE OR UPDATE OF id, login, password, nombre, email, telefofc, extension, departamid, cargoid, inactivo, pregsecrid, respuesta ON usfonpro FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE usfonpro DISABLE TRIGGER "TG_UsFonpro_Bitacora";


--
-- TOC entry 3938 (class 0 OID 0)
-- Dependencies: 3108
-- Name: TRIGGER "TG_UsFonpro_Bitacora" ON usfonpro; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_UsFonpro_Bitacora" ON usfonpro IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3116 (class 2620 OID 87781)
-- Dependencies: 284 329 3255
-- Name: ejecuta_crea_correlativo_actas; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER ejecuta_crea_correlativo_actas AFTER INSERT ON asignacion_fiscales FOR EACH ROW EXECUTE PROCEDURE crea_correlativo_actas();


--
-- TOC entry 3109 (class 2620 OID 21161)
-- Dependencies: 326 226 3255
-- Name: tg_Accionis_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_Accionis_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON accionis FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE accionis DISABLE TRIGGER "tg_Accionis_Bitacora";


--
-- TOC entry 3939 (class 0 OID 0)
-- Dependencies: 3109
-- Name: TRIGGER "tg_Accionis_Bitacora" ON accionis; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_Accionis_Bitacora" ON accionis IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3085 (class 2620 OID 21162)
-- Dependencies: 326 167 3255
-- Name: tg_ActiEcon_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_ActiEcon_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON actiecon FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE actiecon DISABLE TRIGGER "tg_ActiEcon_Bitacora";


--
-- TOC entry 3940 (class 0 OID 0)
-- Dependencies: 3085
-- Name: TRIGGER "tg_ActiEcon_Bitacora" ON actiecon; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_ActiEcon_Bitacora" ON actiecon IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3086 (class 2620 OID 21163)
-- Dependencies: 169 326 3255
-- Name: tg_AlicImp_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_AlicImp_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON alicimp FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE alicimp DISABLE TRIGGER "tg_AlicImp_Bitacora";


--
-- TOC entry 3941 (class 0 OID 0)
-- Dependencies: 3086
-- Name: TRIGGER "tg_AlicImp_Bitacora" ON alicimp; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_AlicImp_Bitacora" ON alicimp IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3091 (class 2620 OID 21164)
-- Dependencies: 178 326 3255
-- Name: tg_CalPagoD_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_CalPagoD_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON calpagod FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE calpagod DISABLE TRIGGER "tg_CalPagoD_Bitacora";


--
-- TOC entry 3942 (class 0 OID 0)
-- Dependencies: 3091
-- Name: TRIGGER "tg_CalPagoD_Bitacora" ON calpagod; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_CalPagoD_Bitacora" ON calpagod IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3092 (class 2620 OID 21165)
-- Dependencies: 180 326 3255
-- Name: tg_CalPago_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_CalPago_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON calpago FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE calpago DISABLE TRIGGER "tg_CalPago_Bitacora";


--
-- TOC entry 3943 (class 0 OID 0)
-- Dependencies: 3092
-- Name: TRIGGER "tg_CalPago_Bitacora" ON calpago; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_CalPago_Bitacora" ON calpago IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3094 (class 2620 OID 21166)
-- Dependencies: 184 326 3255
-- Name: tg_Ciudades_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_Ciudades_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON ciudades FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE ciudades DISABLE TRIGGER "tg_Ciudades_Bitacora";


--
-- TOC entry 3944 (class 0 OID 0)
-- Dependencies: 3094
-- Name: TRIGGER "tg_Ciudades_Bitacora" ON ciudades; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_Ciudades_Bitacora" ON ciudades IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3095 (class 2620 OID 21167)
-- Dependencies: 188 326 3255
-- Name: tg_ConUsuTi_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_ConUsuTi_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON conusuti FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE conusuti DISABLE TRIGGER "tg_ConUsuTi_Bitacora";


--
-- TOC entry 3945 (class 0 OID 0)
-- Dependencies: 3095
-- Name: TRIGGER "tg_ConUsuTi_Bitacora" ON conusuti; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_ConUsuTi_Bitacora" ON conusuti IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3097 (class 2620 OID 21168)
-- Dependencies: 326 194 3255
-- Name: tg_Contribu_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_Contribu_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON contribu FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE contribu DISABLE TRIGGER "tg_Contribu_Bitacora";


--
-- TOC entry 3946 (class 0 OID 0)
-- Dependencies: 3097
-- Name: TRIGGER "tg_Contribu_Bitacora" ON contribu; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_Contribu_Bitacora" ON contribu IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3099 (class 2620 OID 21169)
-- Dependencies: 204 326 3255
-- Name: tg_Estados_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_Estados_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON estados FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE estados DISABLE TRIGGER "tg_Estados_Bitacora";


--
-- TOC entry 3947 (class 0 OID 0)
-- Dependencies: 3099
-- Name: TRIGGER "tg_Estados_Bitacora" ON estados; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_Estados_Bitacora" ON estados IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3103 (class 2620 OID 21170)
-- Dependencies: 212 326 3255
-- Name: tg_RepLegal_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_RepLegal_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON replegal FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE replegal DISABLE TRIGGER "tg_RepLegal_Bitacora";


--
-- TOC entry 3948 (class 0 OID 0)
-- Dependencies: 3103
-- Name: TRIGGER "tg_RepLegal_Bitacora" ON replegal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_RepLegal_Bitacora" ON replegal IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3105 (class 2620 OID 21171)
-- Dependencies: 326 216 3255
-- Name: tg_TiPeGrav_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_TiPeGrav_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON tipegrav FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE tipegrav DISABLE TRIGGER "tg_TiPeGrav_Bitacora";


--
-- TOC entry 3949 (class 0 OID 0)
-- Dependencies: 3105
-- Name: TRIGGER "tg_TiPeGrav_Bitacora" ON tipegrav; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_TiPeGrav_Bitacora" ON tipegrav IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3106 (class 2620 OID 21172)
-- Dependencies: 326 218 3255
-- Name: tg_TipoCont_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_TipoCont_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON tipocont FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE tipocont DISABLE TRIGGER "tg_TipoCont_Bitacora";


--
-- TOC entry 3950 (class 0 OID 0)
-- Dependencies: 3106
-- Name: TRIGGER "tg_TipoCont_Bitacora" ON tipocont; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_TipoCont_Bitacora" ON tipocont IS 'Trigger para insertar datos en la tabla de bitacoras';


SET search_path = seg, pg_catalog;

--
-- TOC entry 3115 (class 2620 OID 78895)
-- Dependencies: 282 328 3255
-- Name: ejecutaverificamodulo; Type: TRIGGER; Schema: seg; Owner: postgres
--

CREATE TRIGGER ejecutaverificamodulo BEFORE INSERT ON tbl_permiso_trampa FOR EACH ROW EXECUTE PROCEDURE verificaperfil();


SET search_path = datos, pg_catalog;

--
-- TOC entry 3027 (class 2606 OID 46556)
-- Dependencies: 226 192 2672 3255
-- Name: FK_Accionis_IDContribu; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY accionis
    ADD CONSTRAINT "FK_Accionis_IDContribu" FOREIGN KEY (contribuid) REFERENCES conusu(id) MATCH FULL;


--
-- TOC entry 3026 (class 2606 OID 21178)
-- Dependencies: 224 2796 226 3255
-- Name: FK_Accionis_UsFonpro_UsuarioID_ID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY accionis
    ADD CONSTRAINT "FK_Accionis_UsFonpro_UsuarioID_ID" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2969 (class 2606 OID 21183)
-- Dependencies: 224 2796 167 3255
-- Name: FK_ActiEcon_USFonpro_IDUsuario_IDUsFornpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY actiecon
    ADD CONSTRAINT "FK_ActiEcon_USFonpro_IDUsuario_IDUsFornpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2970 (class 2606 OID 21188)
-- Dependencies: 2775 218 169 3255
-- Name: FK_AlicImp_TipoCont_IDTipoCont; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY alicimp
    ADD CONSTRAINT "FK_AlicImp_TipoCont_IDTipoCont" FOREIGN KEY (tipocontid) REFERENCES tipocont(id) MATCH FULL;


--
-- TOC entry 2971 (class 2606 OID 21193)
-- Dependencies: 169 2796 224 3255
-- Name: FK_AlicImp_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY alicimp
    ADD CONSTRAINT "FK_AlicImp_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2972 (class 2606 OID 21198)
-- Dependencies: 2816 171 227 3255
-- Name: FK_AsientoD_Asiento_IDAsiento; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asientod
    ADD CONSTRAINT "FK_AsientoD_Asiento_IDAsiento" FOREIGN KEY (asientoid) REFERENCES asiento(id) MATCH FULL;


--
-- TOC entry 2973 (class 2606 OID 21203)
-- Dependencies: 2835 171 234 3255
-- Name: FK_AsientoD_CtaConta_Cuenta; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asientod
    ADD CONSTRAINT "FK_AsientoD_CtaConta_Cuenta" FOREIGN KEY (cuenta) REFERENCES ctaconta(cuenta) MATCH FULL;


--
-- TOC entry 2974 (class 2606 OID 21208)
-- Dependencies: 224 171 2796 3255
-- Name: FK_AsientoD_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asientod
    ADD CONSTRAINT "FK_AsientoD_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 3031 (class 2606 OID 21213)
-- Dependencies: 2821 228 230 3255
-- Name: FK_AsientoMD_AsientoM_AsientoMID_ID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asientomd
    ADD CONSTRAINT "FK_AsientoMD_AsientoM_AsientoMID_ID" FOREIGN KEY (asientomid) REFERENCES asientom(id) MATCH FULL;


--
-- TOC entry 3032 (class 2606 OID 21218)
-- Dependencies: 230 234 2835 3255
-- Name: FK_AsientoMD_CtaConta_Cuenta; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asientomd
    ADD CONSTRAINT "FK_AsientoMD_CtaConta_Cuenta" FOREIGN KEY (cuenta) REFERENCES ctaconta(cuenta) MATCH FULL;


--
-- TOC entry 3033 (class 2606 OID 21223)
-- Dependencies: 2796 224 230 3255
-- Name: FK_AsientoMD_UsFonpro_UsuarioID_ID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asientomd
    ADD CONSTRAINT "FK_AsientoMD_UsFonpro_UsuarioID_ID" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 3030 (class 2606 OID 21228)
-- Dependencies: 2796 228 224 3255
-- Name: FK_AsientoM_UsFonpro_UsuarioID_ID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asientom
    ADD CONSTRAINT "FK_AsientoM_UsFonpro_UsuarioID_ID" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 3028 (class 2606 OID 21233)
-- Dependencies: 224 227 2796 3255
-- Name: FK_Asiento_UsFonpro_IDUsCierre_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asiento
    ADD CONSTRAINT "FK_Asiento_UsFonpro_IDUsCierre_IDUsFonpro" FOREIGN KEY (uscierreid) REFERENCES usfonpro(id);


--
-- TOC entry 3029 (class 2606 OID 21238)
-- Dependencies: 224 227 2796 3255
-- Name: FK_Asiento_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asiento
    ADD CONSTRAINT "FK_Asiento_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2975 (class 2606 OID 21243)
-- Dependencies: 176 2624 174 3255
-- Name: FK_BaCuenta_Bancos_IDBanco; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY bacuenta
    ADD CONSTRAINT "FK_BaCuenta_Bancos_IDBanco" FOREIGN KEY (bancoid) REFERENCES bancos(id) MATCH FULL;


--
-- TOC entry 2976 (class 2606 OID 21248)
-- Dependencies: 174 2796 224 3255
-- Name: FK_BaCuenta_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY bacuenta
    ADD CONSTRAINT "FK_BaCuenta_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2977 (class 2606 OID 21253)
-- Dependencies: 176 224 2796 3255
-- Name: FK_Bancos_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY bancos
    ADD CONSTRAINT "FK_Bancos_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2978 (class 2606 OID 21258)
-- Dependencies: 2637 180 178 3255
-- Name: FK_CalPagoD_CalPago_IDCalPago; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY calpagod
    ADD CONSTRAINT "FK_CalPagoD_CalPago_IDCalPago" FOREIGN KEY (calpagoid) REFERENCES calpago(id) MATCH FULL;


--
-- TOC entry 2979 (class 2606 OID 21263)
-- Dependencies: 2796 224 178 3255
-- Name: FK_CalPagoD_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY calpagod
    ADD CONSTRAINT "FK_CalPagoD_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2980 (class 2606 OID 21268)
-- Dependencies: 2796 224 180 3255
-- Name: FK_CalPago_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY calpago
    ADD CONSTRAINT "FK_CalPago_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2981 (class 2606 OID 21273)
-- Dependencies: 216 2769 180 3255
-- Name: FK_CalPagos_TiPeGrav_IDTiPeGrav; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY calpago
    ADD CONSTRAINT "FK_CalPagos_TiPeGrav_IDTiPeGrav" FOREIGN KEY (tipegravid) REFERENCES tipegrav(id) MATCH FULL;


--
-- TOC entry 2982 (class 2606 OID 21278)
-- Dependencies: 224 182 2796 3255
-- Name: FK_Cargos_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY cargos
    ADD CONSTRAINT "FK_Cargos_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2983 (class 2606 OID 21283)
-- Dependencies: 204 184 2731 3255
-- Name: FK_Ciudades_Estados_IDEstado; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY ciudades
    ADD CONSTRAINT "FK_Ciudades_Estados_IDEstado" FOREIGN KEY (estadoid) REFERENCES estados(id) MATCH FULL;


--
-- TOC entry 2984 (class 2606 OID 21288)
-- Dependencies: 184 224 2796 3255
-- Name: FK_Ciudades_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY ciudades
    ADD CONSTRAINT "FK_Ciudades_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2985 (class 2606 OID 21293)
-- Dependencies: 2672 186 192 3255
-- Name: FK_ConUsuCo_ConUsu_IDConUsu; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusuco
    ADD CONSTRAINT "FK_ConUsuCo_ConUsu_IDConUsu" FOREIGN KEY (conusuid) REFERENCES conusu(id) MATCH FULL;


--
-- TOC entry 2986 (class 2606 OID 21298)
-- Dependencies: 186 194 2685 3255
-- Name: FK_ConUsuCo_Contribu_IDContribu; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusuco
    ADD CONSTRAINT "FK_ConUsuCo_Contribu_IDContribu" FOREIGN KEY (contribuid) REFERENCES contribu(id) MATCH FULL;


--
-- TOC entry 2987 (class 2606 OID 21303)
-- Dependencies: 188 2796 224 3255
-- Name: FK_ConUsuTi_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusuti
    ADD CONSTRAINT "FK_ConUsuTi_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2988 (class 2606 OID 21308)
-- Dependencies: 190 192 2672 3255
-- Name: FK_ConUsuTo_ConUsu_IDConUsu; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusuto
    ADD CONSTRAINT "FK_ConUsuTo_ConUsu_IDConUsu" FOREIGN KEY (conusuid) REFERENCES conusu(id) MATCH FULL;


--
-- TOC entry 2989 (class 2606 OID 21313)
-- Dependencies: 2657 188 192 3255
-- Name: FK_ConUsu_ConUsuTi_IDConUsuTi; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusu
    ADD CONSTRAINT "FK_ConUsu_ConUsuTi_IDConUsuTi" FOREIGN KEY (conusutiid) REFERENCES conusuti(id) MATCH FULL;


--
-- TOC entry 2990 (class 2606 OID 21318)
-- Dependencies: 192 2748 210 3255
-- Name: FK_ConUsu_PregSecr_IDPregSecr; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusu
    ADD CONSTRAINT "FK_ConUsu_PregSecr_IDPregSecr" FOREIGN KEY (pregsecrid) REFERENCES pregsecr(id) MATCH FULL;


--
-- TOC entry 2991 (class 2606 OID 21323)
-- Dependencies: 224 2796 192 3255
-- Name: FK_ConUsu_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusu
    ADD CONSTRAINT "FK_ConUsu_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 3034 (class 2606 OID 21328)
-- Dependencies: 232 2685 194 3255
-- Name: FK_ContribuTi_Contribu_ContribuID_ID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY contributi
    ADD CONSTRAINT "FK_ContribuTi_Contribu_ContribuID_ID" FOREIGN KEY (contribuid) REFERENCES contribu(id) MATCH FULL;


--
-- TOC entry 3035 (class 2606 OID 21333)
-- Dependencies: 232 218 2775 3255
-- Name: FK_ContribuTi_TipoCont_TipoContID_ID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY contributi
    ADD CONSTRAINT "FK_ContribuTi_TipoCont_TipoContID_ID" FOREIGN KEY (tipocontid) REFERENCES tipocont(id) MATCH FULL;


--
-- TOC entry 2992 (class 2606 OID 21338)
-- Dependencies: 194 167 2598 3255
-- Name: FK_Contribu_ActiEcon_IDActiEcon; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY contribu
    ADD CONSTRAINT "FK_Contribu_ActiEcon_IDActiEcon" FOREIGN KEY (actieconid) REFERENCES actiecon(id) MATCH FULL;


--
-- TOC entry 2993 (class 2606 OID 21343)
-- Dependencies: 194 2648 184 3255
-- Name: FK_Contribu_Ciudades_IDCiudad; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY contribu
    ADD CONSTRAINT "FK_Contribu_Ciudades_IDCiudad" FOREIGN KEY (ciudadid) REFERENCES ciudades(id) MATCH FULL;


--
-- TOC entry 2994 (class 2606 OID 21348)
-- Dependencies: 2672 194 192 3255
-- Name: FK_Contribu_ConUsu_UsuarioID_ID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY contribu
    ADD CONSTRAINT "FK_Contribu_ConUsu_UsuarioID_ID" FOREIGN KEY (usuarioid) REFERENCES conusu(id) MATCH FULL;


--
-- TOC entry 2995 (class 2606 OID 21353)
-- Dependencies: 204 2731 194 3255
-- Name: FK_Contribu_Estados_IDEstado; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY contribu
    ADD CONSTRAINT "FK_Contribu_Estados_IDEstado" FOREIGN KEY (estadoid) REFERENCES estados(id) MATCH FULL;


--
-- TOC entry 3036 (class 2606 OID 21358)
-- Dependencies: 224 2796 234 3255
-- Name: FK_CtaConta_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY ctaconta
    ADD CONSTRAINT "FK_CtaConta_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 3073 (class 2606 OID 79010)
-- Dependencies: 2816 285 227 3255
-- Name: FK_Decla_Asiento_IDAsiento; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT "FK_Decla_Asiento_IDAsiento" FOREIGN KEY (asientoid) REFERENCES asiento(id);


--
-- TOC entry 3072 (class 2606 OID 79015)
-- Dependencies: 178 285 2628 3255
-- Name: FK_Decla_Calpagod_id; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT "FK_Decla_Calpagod_id" FOREIGN KEY (calpagodid) REFERENCES calpagod(id);


--
-- TOC entry 3071 (class 2606 OID 79020)
-- Dependencies: 285 285 2939 3255
-- Name: FK_Decla_PlaSustID_ID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT "FK_Decla_PlaSustID_ID" FOREIGN KEY (plasustid) REFERENCES declara(id);


--
-- TOC entry 3070 (class 2606 OID 79025)
-- Dependencies: 212 285 2759 3255
-- Name: FK_Decla_RepLegal_IDRepLegal; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT "FK_Decla_RepLegal_IDRepLegal" FOREIGN KEY (replegalid) REFERENCES replegal(id) MATCH FULL;


--
-- TOC entry 3069 (class 2606 OID 79030)
-- Dependencies: 214 285 2764 3255
-- Name: FK_Decla_TDeclara_IDTDeclara; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT "FK_Decla_TDeclara_IDTDeclara" FOREIGN KEY (tdeclaraid) REFERENCES tdeclara(id) MATCH FULL;


--
-- TOC entry 3068 (class 2606 OID 79035)
-- Dependencies: 224 285 2796 3255
-- Name: FK_Decla_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT "FK_Decla_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id);


--
-- TOC entry 3067 (class 2606 OID 79040)
-- Dependencies: 218 285 2775 3255
-- Name: FK_Decla_tipocontribuid; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT "FK_Decla_tipocontribuid" FOREIGN KEY (tipocontribuid) REFERENCES tipocont(id);


--
-- TOC entry 2996 (class 2606 OID 21363)
-- Dependencies: 196 227 2816 3255
-- Name: FK_Declara_Asiento_IDAsiento; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara_viejo
    ADD CONSTRAINT "FK_Declara_Asiento_IDAsiento" FOREIGN KEY (asientoid) REFERENCES asiento(id);


--
-- TOC entry 3003 (class 2606 OID 77240)
-- Dependencies: 2628 196 178 3255
-- Name: FK_Declara_Calpagod_id; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara_viejo
    ADD CONSTRAINT "FK_Declara_Calpagod_id" FOREIGN KEY (calpagodid) REFERENCES calpagod(id);


--
-- TOC entry 2997 (class 2606 OID 21373)
-- Dependencies: 196 196 2701 3255
-- Name: FK_Declara_PlaSustID_ID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara_viejo
    ADD CONSTRAINT "FK_Declara_PlaSustID_ID" FOREIGN KEY (plasustid) REFERENCES declara_viejo(id);


--
-- TOC entry 2998 (class 2606 OID 21378)
-- Dependencies: 212 196 2759 3255
-- Name: FK_Declara_RepLegal_IDRepLegal; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara_viejo
    ADD CONSTRAINT "FK_Declara_RepLegal_IDRepLegal" FOREIGN KEY (replegalid) REFERENCES replegal(id) MATCH FULL;


--
-- TOC entry 2999 (class 2606 OID 21383)
-- Dependencies: 214 196 2764 3255
-- Name: FK_Declara_TDeclara_IDTDeclara; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara_viejo
    ADD CONSTRAINT "FK_Declara_TDeclara_IDTDeclara" FOREIGN KEY (tdeclaraid) REFERENCES tdeclara(id) MATCH FULL;


--
-- TOC entry 3000 (class 2606 OID 21388)
-- Dependencies: 224 196 2796 3255
-- Name: FK_Declara_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara_viejo
    ADD CONSTRAINT "FK_Declara_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id);


--
-- TOC entry 3001 (class 2606 OID 46583)
-- Dependencies: 2775 218 196 3255
-- Name: FK_Declara_tipocontribuid; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara_viejo
    ADD CONSTRAINT "FK_Declara_tipocontribuid" FOREIGN KEY (tipocontribuid) REFERENCES tipocont(id);


--
-- TOC entry 3037 (class 2606 OID 21393)
-- Dependencies: 2796 224 235 3255
-- Name: FK_Document_UsFonpro_UsFonproID_ID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY document
    ADD CONSTRAINT "FK_Document_UsFonpro_UsFonproID_ID" FOREIGN KEY (usfonproid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 3005 (class 2606 OID 21398)
-- Dependencies: 2726 202 200 3255
-- Name: FK_EntidadD_Entidad_IDEntidad; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY entidadd
    ADD CONSTRAINT "FK_EntidadD_Entidad_IDEntidad" FOREIGN KEY (entidadid) REFERENCES entidad(id) MATCH FULL;


--
-- TOC entry 3006 (class 2606 OID 21403)
-- Dependencies: 204 2796 224 3255
-- Name: FK_Estados_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY estados
    ADD CONSTRAINT "FK_Estados_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 3007 (class 2606 OID 21408)
-- Dependencies: 206 200 2718 3255
-- Name: FK_PerUsuD_EndidadD_IDEntidadD; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY perusud
    ADD CONSTRAINT "FK_PerUsuD_EndidadD_IDEntidadD" FOREIGN KEY (entidaddid) REFERENCES entidadd(id) MATCH FULL;


--
-- TOC entry 3008 (class 2606 OID 21413)
-- Dependencies: 208 206 2743 3255
-- Name: FK_PerUsuD_PerUsu_IDPerUsu; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY perusud
    ADD CONSTRAINT "FK_PerUsuD_PerUsu_IDPerUsu" FOREIGN KEY (perusuid) REFERENCES perusu(id) MATCH FULL;


--
-- TOC entry 3009 (class 2606 OID 21418)
-- Dependencies: 2796 206 224 3255
-- Name: FK_PerUsuD_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY perusud
    ADD CONSTRAINT "FK_PerUsuD_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 3010 (class 2606 OID 21423)
-- Dependencies: 208 2796 224 3255
-- Name: FK_PerUsu_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY perusu
    ADD CONSTRAINT "FK_PerUsu_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 3011 (class 2606 OID 21428)
-- Dependencies: 224 210 2796 3255
-- Name: FK_PregSecr_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY pregsecr
    ADD CONSTRAINT "FK_PregSecr_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 3012 (class 2606 OID 21433)
-- Dependencies: 212 184 2648 3255
-- Name: FK_RepLegal_IDCiudad; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY replegal
    ADD CONSTRAINT "FK_RepLegal_IDCiudad" FOREIGN KEY (ciudadid) REFERENCES ciudades(id) MATCH FULL;


--
-- TOC entry 3013 (class 2606 OID 21438)
-- Dependencies: 194 212 2685 3255
-- Name: FK_RepLegal_IDContribu; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY replegal
    ADD CONSTRAINT "FK_RepLegal_IDContribu" FOREIGN KEY (contribuid) REFERENCES contribu(id) MATCH FULL;


--
-- TOC entry 3014 (class 2606 OID 21443)
-- Dependencies: 204 2731 212 3255
-- Name: FK_RepLegal_IDEstado; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY replegal
    ADD CONSTRAINT "FK_RepLegal_IDEstado" FOREIGN KEY (estadoid) REFERENCES estados(id) MATCH FULL;


--
-- TOC entry 3015 (class 2606 OID 21448)
-- Dependencies: 2796 212 224 3255
-- Name: FK_RepLegal_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY replegal
    ADD CONSTRAINT "FK_RepLegal_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 3016 (class 2606 OID 21453)
-- Dependencies: 224 2796 214 3255
-- Name: FK_TDeclara_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tdeclara
    ADD CONSTRAINT "FK_TDeclara_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 3017 (class 2606 OID 21458)
-- Dependencies: 2796 216 224 3255
-- Name: FK_TiPeGrav_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tipegrav
    ADD CONSTRAINT "FK_TiPeGrav_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 3018 (class 2606 OID 21463)
-- Dependencies: 218 216 2769 3255
-- Name: FK_TipoCont_TiPeGrav_IDTiPeGrav; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tipocont
    ADD CONSTRAINT "FK_TipoCont_TiPeGrav_IDTiPeGrav" FOREIGN KEY (tipegravid) REFERENCES tipegrav(id) MATCH FULL;


--
-- TOC entry 3019 (class 2606 OID 21468)
-- Dependencies: 224 218 2796 3255
-- Name: FK_TipoCont_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tipocont
    ADD CONSTRAINT "FK_TipoCont_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 3039 (class 2606 OID 21473)
-- Dependencies: 2598 238 167 3255
-- Name: FK_TmpContri_ActiEcon_IDActiEcon; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tmpcontri
    ADD CONSTRAINT "FK_TmpContri_ActiEcon_IDActiEcon" FOREIGN KEY (actieconid) REFERENCES actiecon(id) MATCH FULL;


--
-- TOC entry 3040 (class 2606 OID 21478)
-- Dependencies: 184 238 2648 3255
-- Name: FK_TmpContri_Ciudades_IDCiudad; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tmpcontri
    ADD CONSTRAINT "FK_TmpContri_Ciudades_IDCiudad" FOREIGN KEY (ciudadid) REFERENCES ciudades(id) MATCH FULL;


--
-- TOC entry 3041 (class 2606 OID 21483)
-- Dependencies: 238 194 2685 3255
-- Name: FK_TmpContri_Contribu_IDContribu; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tmpcontri
    ADD CONSTRAINT "FK_TmpContri_Contribu_IDContribu" FOREIGN KEY (id) REFERENCES contribu(id) MATCH FULL;


--
-- TOC entry 3042 (class 2606 OID 21488)
-- Dependencies: 238 204 2731 3255
-- Name: FK_TmpContri_Estados_IDEstado; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tmpcontri
    ADD CONSTRAINT "FK_TmpContri_Estados_IDEstado" FOREIGN KEY (estadoid) REFERENCES estados(id) MATCH FULL;


--
-- TOC entry 3043 (class 2606 OID 21493)
-- Dependencies: 2775 218 238 3255
-- Name: FK_TmpContri_TipoCont_IDTipoCont; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tmpcontri
    ADD CONSTRAINT "FK_TmpContri_TipoCont_IDTipoCont" FOREIGN KEY (tipocontid) REFERENCES tipocont(id) MATCH FULL;


--
-- TOC entry 3044 (class 2606 OID 21498)
-- Dependencies: 2648 239 184 3255
-- Name: FK_TmpReLegal_IDCiudad; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tmprelegal
    ADD CONSTRAINT "FK_TmpReLegal_IDCiudad" FOREIGN KEY (ciudadid) REFERENCES ciudades(id) MATCH FULL;


--
-- TOC entry 3045 (class 2606 OID 21503)
-- Dependencies: 239 238 2862 3255
-- Name: FK_TmpReLegal_IDContribu; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tmprelegal
    ADD CONSTRAINT "FK_TmpReLegal_IDContribu" FOREIGN KEY (contribuid) REFERENCES tmpcontri(id) MATCH FULL;


--
-- TOC entry 3046 (class 2606 OID 21508)
-- Dependencies: 239 2731 204 3255
-- Name: FK_TmpReLegal_IDEstado; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tmprelegal
    ADD CONSTRAINT "FK_TmpReLegal_IDEstado" FOREIGN KEY (estadoid) REFERENCES estados(id) MATCH FULL;


--
-- TOC entry 3047 (class 2606 OID 21513)
-- Dependencies: 239 212 2759 3255
-- Name: FK_TmpReLegal_IDRepLegal; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tmprelegal
    ADD CONSTRAINT "FK_TmpReLegal_IDRepLegal" FOREIGN KEY (id) REFERENCES replegal(id) MATCH FULL;


--
-- TOC entry 3020 (class 2606 OID 21518)
-- Dependencies: 220 2796 224 3255
-- Name: FK_UndTrib_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY undtrib
    ADD CONSTRAINT "FK_UndTrib_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 3022 (class 2606 OID 21523)
-- Dependencies: 210 224 2748 3255
-- Name: FK_UsFonPro_PregSecr_IDPregSecr; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY usfonpro
    ADD CONSTRAINT "FK_UsFonPro_PregSecr_IDPregSecr" FOREIGN KEY (pregsecrid) REFERENCES pregsecr(id) MATCH FULL;


--
-- TOC entry 3021 (class 2606 OID 21528)
-- Dependencies: 224 2796 222 3255
-- Name: FK_UsFonpTo_UsFonpro_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY usfonpto
    ADD CONSTRAINT "FK_UsFonpTo_UsFonpro_IDUsFonpro" FOREIGN KEY (usfonproid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 3023 (class 2606 OID 21533)
-- Dependencies: 224 182 2642 3255
-- Name: FK_UsFonpro_Cargos_IDCargo; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY usfonpro
    ADD CONSTRAINT "FK_UsFonpro_Cargos_IDCargo" FOREIGN KEY (cargoid) REFERENCES cargos(id) MATCH FULL;


--
-- TOC entry 3024 (class 2606 OID 21538)
-- Dependencies: 198 2705 224 3255
-- Name: FK_UsFonpro_Departam_IDDepartam; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY usfonpro
    ADD CONSTRAINT "FK_UsFonpro_Departam_IDDepartam" FOREIGN KEY (departamid) REFERENCES departam(id) MATCH FULL;


--
-- TOC entry 3025 (class 2606 OID 21543)
-- Dependencies: 224 208 2743 3255
-- Name: FK_UsFonpro_PerUsu_IDPerUsu; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY usfonpro
    ADD CONSTRAINT "FK_UsFonpro_PerUsu_IDPerUsu" FOREIGN KEY (perusuid) REFERENCES perusu(id);


--
-- TOC entry 3056 (class 2606 OID 46454)
-- Dependencies: 2672 267 192 3255
-- Name: FK_conusu_id; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY con_img_doc
    ADD CONSTRAINT "FK_conusu_id" FOREIGN KEY (conusuid) REFERENCES conusu(id) MATCH FULL;


--
-- TOC entry 3079 (class 2606 OID 79141)
-- Dependencies: 227 288 2816 3255
-- Name: FK_reparos_Asiento_IDAsiento; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY reparos
    ADD CONSTRAINT "FK_reparos_Asiento_IDAsiento" FOREIGN KEY (asientoid) REFERENCES asiento(id);


--
-- TOC entry 3078 (class 2606 OID 79151)
-- Dependencies: 214 288 2764 3255
-- Name: FK_reparos_TDeclara_IDTDeclara; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY reparos
    ADD CONSTRAINT "FK_reparos_TDeclara_IDTDeclara" FOREIGN KEY (tdeclaraid) REFERENCES tdeclara(id) MATCH FULL;


--
-- TOC entry 3077 (class 2606 OID 79156)
-- Dependencies: 2796 224 288 3255
-- Name: FK_reparos_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY reparos
    ADD CONSTRAINT "FK_reparos_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id);


--
-- TOC entry 3076 (class 2606 OID 79161)
-- Dependencies: 2775 288 218 3255
-- Name: FK_reparos_tipocontribuid; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY reparos
    ADD CONSTRAINT "FK_reparos_tipocontribuid" FOREIGN KEY (tipocontribuid) REFERENCES tipocont(id);


--
-- TOC entry 3038 (class 2606 OID 21548)
-- Dependencies: 238 237 2862 3255
-- Name: FK_tmpAccioni_ContribuID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tmpaccioni
    ADD CONSTRAINT "FK_tmpAccioni_ContribuID" FOREIGN KEY (contribuid) REFERENCES tmpcontri(id) MATCH FULL;


--
-- TOC entry 3004 (class 2606 OID 21553)
-- Dependencies: 198 2796 224 3255
-- Name: FL_Departam_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY departam
    ADD CONSTRAINT "FL_Departam_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 3065 (class 2606 OID 78913)
-- Dependencies: 284 192 2672 3255
-- Name: fk-asignacion-contribuyente; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asignacion_fiscales
    ADD CONSTRAINT "fk-asignacion-contribuyente" FOREIGN KEY (conusuid) REFERENCES conusu(id);


--
-- TOC entry 3064 (class 2606 OID 78918)
-- Dependencies: 284 224 2796 3255
-- Name: fk-asignacion-fonprocine; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asignacion_fiscales
    ADD CONSTRAINT "fk-asignacion-fonprocine" FOREIGN KEY (usfonproid) REFERENCES usfonpro(id);


--
-- TOC entry 3063 (class 2606 OID 78923)
-- Dependencies: 284 224 2796 3255
-- Name: fk-asignacion-usuario; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asignacion_fiscales
    ADD CONSTRAINT "fk-asignacion-usuario" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id);


--
-- TOC entry 3060 (class 2606 OID 77302)
-- Dependencies: 2796 275 224 3255
-- Name: fk-usuario; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY interes_bcv
    ADD CONSTRAINT "fk-usuario" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id);


--
-- TOC entry 3074 (class 2606 OID 79073)
-- Dependencies: 2923 287 284 3255
-- Name: fk_asignacion_fiscal_id; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY dettalles_fizcalizacion
    ADD CONSTRAINT fk_asignacion_fiscal_id FOREIGN KEY (asignacionfid) REFERENCES asignacion_fiscales(id);


--
-- TOC entry 3083 (class 2606 OID 87752)
-- Dependencies: 2672 192 301 3255
-- Name: fk_conusu_interno_conusu; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusu_interno
    ADD CONSTRAINT fk_conusu_interno_conusu FOREIGN KEY (conusuid) REFERENCES conusu(id);


--
-- TOC entry 3084 (class 2606 OID 87747)
-- Dependencies: 301 2796 224 3255
-- Name: fk_conusu_interno_usfonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusu_interno
    ADD CONSTRAINT fk_conusu_interno_usfonpro FOREIGN KEY (usuarioid) REFERENCES usfonpro(id);


--
-- TOC entry 3057 (class 2606 OID 69006)
-- Dependencies: 192 2672 270 3255
-- Name: fk_conusuid; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusu_tipocont
    ADD CONSTRAINT fk_conusuid FOREIGN KEY (conusuid) REFERENCES conusu(id) MATCH FULL;


--
-- TOC entry 3002 (class 2606 OID 69013)
-- Dependencies: 2672 196 192 3255
-- Name: fk_conusuid; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara_viejo
    ADD CONSTRAINT fk_conusuid FOREIGN KEY (conusuid) REFERENCES conusu(id) MATCH FULL;


--
-- TOC entry 3066 (class 2606 OID 79045)
-- Dependencies: 2672 285 192 3255
-- Name: fk_conusuid; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT fk_conusuid FOREIGN KEY (conusuid) REFERENCES conusu(id) MATCH FULL;


--
-- TOC entry 3082 (class 2606 OID 87648)
-- Dependencies: 299 2939 285 3255
-- Name: fk_declaraid_contric_calc_iddeclara; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY detalles_contrib_calc
    ADD CONSTRAINT fk_declaraid_contric_calc_iddeclara FOREIGN KEY (declaraid) REFERENCES declara(id);


--
-- TOC entry 3081 (class 2606 OID 87653)
-- Dependencies: 299 291 2953 3255
-- Name: fk_detalles_contric_calid_a_contric_calid; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY detalles_contrib_calc
    ADD CONSTRAINT fk_detalles_contric_calid_a_contric_calid FOREIGN KEY (contrib_calcid) REFERENCES contrib_calc(id);


--
-- TOC entry 3075 (class 2606 OID 79173)
-- Dependencies: 288 192 2672 3255
-- Name: fk_reparos_conusuid; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY reparos
    ADD CONSTRAINT fk_reparos_conusuid FOREIGN KEY (conusuid) REFERENCES conusu(id);


SET search_path = pre_aprobacion, pg_catalog;

--
-- TOC entry 3059 (class 2606 OID 77257)
-- Dependencies: 272 224 2796 3255
-- Name: fk-multa-usuario; Type: FK CONSTRAINT; Schema: pre_aprobacion; Owner: postgres
--

ALTER TABLE ONLY multas
    ADD CONSTRAINT "fk-multa-usuario" FOREIGN KEY (usuarioid) REFERENCES datos.usfonpro(id);


--
-- TOC entry 3058 (class 2606 OID 87523)
-- Dependencies: 285 2939 272 3255
-- Name: fk_multa_declaraid; Type: FK CONSTRAINT; Schema: pre_aprobacion; Owner: postgres
--

ALTER TABLE ONLY multas
    ADD CONSTRAINT fk_multa_declaraid FOREIGN KEY (declaraid) REFERENCES datos.declara(id);


SET search_path = seg, pg_catalog;

--
-- TOC entry 3049 (class 2606 OID 21625)
-- Dependencies: 242 2881 244 3255
-- Name: fk_permiso_modulo; Type: FK CONSTRAINT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_permiso
    ADD CONSTRAINT fk_permiso_modulo FOREIGN KEY (id_modulo) REFERENCES tbl_modulo(id_modulo) ON DELETE RESTRICT;


--
-- TOC entry 3048 (class 2606 OID 21630)
-- Dependencies: 246 2885 244 3255
-- Name: fk_permiso_rol; Type: FK CONSTRAINT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_permiso
    ADD CONSTRAINT fk_permiso_rol FOREIGN KEY (id_rol) REFERENCES tbl_rol(id_rol) ON DELETE RESTRICT;


--
-- TOC entry 3050 (class 2606 OID 21635)
-- Dependencies: 2885 246 248 3255
-- Name: fk_rol_usuario_rol; Type: FK CONSTRAINT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_rol_usuario
    ADD CONSTRAINT fk_rol_usuario_rol FOREIGN KEY (id_rol) REFERENCES tbl_rol(id_rol) ON DELETE RESTRICT;


--
-- TOC entry 3080 (class 2606 OID 87617)
-- Dependencies: 297 2959 295 3255
-- Name: fk_tblcargos; Type: FK CONSTRAINT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_cargos
    ADD CONSTRAINT fk_tblcargos FOREIGN KEY (oficinasid) REFERENCES tbl_oficinas(id);


--
-- TOC entry 3051 (class 2606 OID 21640)
-- Dependencies: 246 2885 251 3255
-- Name: fk_usuario_rol_rol; Type: FK CONSTRAINT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_usuario_rol
    ADD CONSTRAINT fk_usuario_rol_rol FOREIGN KEY (id_rol) REFERENCES tbl_rol(id_rol) ON DELETE RESTRICT;


--
-- TOC entry 3062 (class 2606 OID 78885)
-- Dependencies: 282 242 2881 3255
-- Name: fkt_permiso_modulo; Type: FK CONSTRAINT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_permiso_trampa
    ADD CONSTRAINT fkt_permiso_modulo FOREIGN KEY (id_modulo) REFERENCES tbl_modulo(id_modulo) ON DELETE RESTRICT;


--
-- TOC entry 3061 (class 2606 OID 78890)
-- Dependencies: 282 246 2885 3255
-- Name: fkt_permiso_rol; Type: FK CONSTRAINT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_permiso_trampa
    ADD CONSTRAINT fkt_permiso_rol FOREIGN KEY (id_rol) REFERENCES tbl_rol(id_rol) ON DELETE RESTRICT;


SET search_path = "segContribu", pg_catalog;

--
-- TOC entry 3053 (class 2606 OID 22912)
-- Dependencies: 2893 256 255 3255
-- Name: fk_permiso_modulo; Type: FK CONSTRAINT; Schema: segContribu; Owner: postgres
--

ALTER TABLE ONLY tbl_permiso_contribu
    ADD CONSTRAINT fk_permiso_modulo FOREIGN KEY (id_modulo) REFERENCES tbl_modulo_contribu(id_modulo) ON DELETE RESTRICT;


--
-- TOC entry 3052 (class 2606 OID 22917)
-- Dependencies: 257 256 2897 3255
-- Name: fk_permiso_rol; Type: FK CONSTRAINT; Schema: segContribu; Owner: postgres
--

ALTER TABLE ONLY tbl_permiso_contribu
    ADD CONSTRAINT fk_permiso_rol FOREIGN KEY (id_rol) REFERENCES tbl_rol_contribu(id_rol) ON DELETE RESTRICT;


--
-- TOC entry 3054 (class 2606 OID 22922)
-- Dependencies: 258 2897 257 3255
-- Name: fk_rol_usuario_rol; Type: FK CONSTRAINT; Schema: segContribu; Owner: postgres
--

ALTER TABLE ONLY tbl_rol_usuario_contribu
    ADD CONSTRAINT fk_rol_usuario_rol FOREIGN KEY (id_rol) REFERENCES tbl_rol_contribu(id_rol) ON DELETE RESTRICT;


--
-- TOC entry 3055 (class 2606 OID 22927)
-- Dependencies: 257 263 2897 3255
-- Name: fk_usuario_rol_rol; Type: FK CONSTRAINT; Schema: segContribu; Owner: postgres
--

ALTER TABLE ONLY tbl_usuario_rol_contribu
    ADD CONSTRAINT fk_usuario_rol_rol FOREIGN KEY (id_rol) REFERENCES tbl_rol_contribu(id_rol) ON DELETE RESTRICT;


--
-- TOC entry 3261 (class 0 OID 0)
-- Dependencies: 7
-- Name: datos; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA datos FROM PUBLIC;
REVOKE ALL ON SCHEMA datos FROM postgres;
GRANT ALL ON SCHEMA datos TO postgres;
GRANT ALL ON SCHEMA datos TO PUBLIC;


--
-- TOC entry 3263 (class 0 OID 0)
-- Dependencies: 8
-- Name: historial; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA historial FROM PUBLIC;
REVOKE ALL ON SCHEMA historial FROM postgres;
GRANT ALL ON SCHEMA historial TO postgres;
GRANT ALL ON SCHEMA historial TO PUBLIC;


--
-- TOC entry 3265 (class 0 OID 0)
-- Dependencies: 5
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


SET search_path = datos, pg_catalog;

--
-- TOC entry 3281 (class 0 OID 0)
-- Dependencies: 167
-- Name: actiecon; Type: ACL; Schema: datos; Owner: postgres
--

REVOKE ALL ON TABLE actiecon FROM PUBLIC;
REVOKE ALL ON TABLE actiecon FROM postgres;
GRANT ALL ON TABLE actiecon TO postgres;


SET search_path = historial, pg_catalog;

--
-- TOC entry 3816 (class 0 OID 0)
-- Dependencies: 240
-- Name: bitacora; Type: ACL; Schema: historial; Owner: postgres
--

REVOKE ALL ON TABLE bitacora FROM PUBLIC;
REVOKE ALL ON TABLE bitacora FROM postgres;
GRANT ALL ON TABLE bitacora TO postgres;
GRANT ALL ON TABLE bitacora TO PUBLIC;


--
-- TOC entry 3818 (class 0 OID 0)
-- Dependencies: 241
-- Name: Bitacora_IDBitacora_seq; Type: ACL; Schema: historial; Owner: postgres
--

REVOKE ALL ON SEQUENCE "Bitacora_IDBitacora_seq" FROM PUBLIC;
REVOKE ALL ON SEQUENCE "Bitacora_IDBitacora_seq" FROM postgres;
GRANT ALL ON SEQUENCE "Bitacora_IDBitacora_seq" TO postgres;
GRANT ALL ON SEQUENCE "Bitacora_IDBitacora_seq" TO PUBLIC;


--
-- TOC entry 1900 (class 826 OID 21558)
-- Dependencies: 8 3255
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: historial; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA historial REVOKE ALL ON SEQUENCES  FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA historial REVOKE ALL ON SEQUENCES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA historial GRANT ALL ON SEQUENCES  TO PUBLIC;


--
-- TOC entry 1901 (class 826 OID 21559)
-- Dependencies: 8 3255
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: historial; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA historial REVOKE ALL ON FUNCTIONS  FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA historial REVOKE ALL ON FUNCTIONS  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA historial GRANT ALL ON FUNCTIONS  TO PUBLIC;


--
-- TOC entry 1902 (class 826 OID 21560)
-- Dependencies: 8 3255
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: historial; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA historial REVOKE ALL ON TABLES  FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA historial REVOKE ALL ON TABLES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA historial GRANT ALL ON TABLES  TO PUBLIC;


-- Completed on 2013-07-02 14:26:16 VET

--
-- PostgreSQL database dump complete
--

