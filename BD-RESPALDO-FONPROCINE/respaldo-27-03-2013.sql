--
-- PostgreSQL database dump
--

-- Dumped from database version 9.1.8
-- Dumped by pg_dump version 9.1.8
-- Started on 2013-03-27 16:58:21 VET

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 3040 (class 1262 OID 20512)
-- Dependencies: 3039
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
-- TOC entry 3041 (class 0 OID 0)
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
-- TOC entry 3043 (class 0 OID 0)
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
-- TOC entry 283 (class 3079 OID 11720)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 3047 (class 0 OID 0)
-- Dependencies: 283
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = datos, pg_catalog;

--
-- TOC entry 295 (class 1255 OID 20515)
-- Dependencies: 885 7
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
-- TOC entry 3048 (class 0 OID 0)
-- Dependencies: 295
-- Name: FUNCTION "pa_ActUsuBitDel"("Tabla" text, "ValorID" integer, "IDUsuario" integer, OUT "Actualizado" boolean); Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON FUNCTION "pa_ActUsuBitDel"("Tabla" text, "ValorID" integer, "IDUsuario" integer, OUT "Actualizado" boolean) IS 'Funcion que actualiza el IDUsuario en la bitacora cuando se elimina un registro. Esta funcion tiene que ser llamada inmediatamente despues de eliminar una fila en cualquier tabla';


--
-- TOC entry 296 (class 1255 OID 20516)
-- Dependencies: 7 885
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
-- TOC entry 3049 (class 0 OID 0)
-- Dependencies: 296
-- Name: FUNCTION "pa_LoginContribu"("LoginUsuario" text, "PasswordUsuario" text, OUT "IDUsuarioContribuyente" integer, OUT "NombreUsuario" text, OUT "IDTipoUsuario" integer, OUT "UltimoLogin" timestamp without time zone); Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON FUNCTION "pa_LoginContribu"("LoginUsuario" text, "PasswordUsuario" text, OUT "IDUsuarioContribuyente" integer, OUT "NombreUsuario" text, OUT "IDTipoUsuario" integer, OUT "UltimoLogin" timestamp without time zone) IS 'Funcion para hacer login de un contribuyente';


--
-- TOC entry 297 (class 1255 OID 20517)
-- Dependencies: 885 7
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
-- TOC entry 3050 (class 0 OID 0)
-- Dependencies: 297
-- Name: FUNCTION "pa_LoginUsFonpro"("LoginUsuario" text, "PasswordUsuario" text, OUT "IDUsuarioFonprocine" integer, OUT "NombreUsuario" text, OUT "IDPerfilUsuario" integer, OUT "UltimoLogin" timestamp without time zone); Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON FUNCTION "pa_LoginUsFonpro"("LoginUsuario" text, "PasswordUsuario" text, OUT "IDUsuarioFonprocine" integer, OUT "NombreUsuario" text, OUT "IDPerfilUsuario" integer, OUT "UltimoLogin" timestamp without time zone) IS 'Funcion para hacer login de un usuario Fonprocine';


--
-- TOC entry 298 (class 1255 OID 20518)
-- Dependencies: 885 7
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
-- TOC entry 3051 (class 0 OID 0)
-- Dependencies: 298
-- Name: FUNCTION "pa_TokenActivoContribu"("IDToken" integer, "IDUsuario" integer, OUT "Activo" boolean, OUT "FechaCreacion" timestamp without time zone, OUT "FechaCaducidad" timestamp without time zone, OUT "FechaHoraServidor" timestamp without time zone, OUT "Observaciones" text); Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON FUNCTION "pa_TokenActivoContribu"("IDToken" integer, "IDUsuario" integer, OUT "Activo" boolean, OUT "FechaCreacion" timestamp without time zone, OUT "FechaCaducidad" timestamp without time zone, OUT "FechaHoraServidor" timestamp without time zone, OUT "Observaciones" text) IS 'Funcion que verifica si el token de usuario de contribuyente buscado esta activo a la fecha hora del servidor';


--
-- TOC entry 299 (class 1255 OID 20519)
-- Dependencies: 885 7
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
-- TOC entry 3052 (class 0 OID 0)
-- Dependencies: 299
-- Name: FUNCTION "pa_TokenActivoUsFonpro"("IDToken" integer, "IDUsuario" integer, OUT "Activo" boolean, OUT "FechaCreacion" timestamp without time zone, OUT "FechaCaducidad" timestamp without time zone, OUT "FechaHoraServidor" timestamp without time zone, OUT "Observaciones" text); Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON FUNCTION "pa_TokenActivoUsFonpro"("IDToken" integer, "IDUsuario" integer, OUT "Activo" boolean, OUT "FechaCreacion" timestamp without time zone, OUT "FechaCaducidad" timestamp without time zone, OUT "FechaHoraServidor" timestamp without time zone, OUT "Observaciones" text) IS 'Funcion que verifica si el token de usuario de forprocine buscado esta activo a la fecha hora del servidor';


--
-- TOC entry 304 (class 1255 OID 46569)
-- Dependencies: 885 7
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
-- TOC entry 300 (class 1255 OID 20520)
-- Dependencies: 7 885
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
-- TOC entry 3053 (class 0 OID 0)
-- Dependencies: 300
-- Name: FUNCTION "tf_AsiendoD_ActualizaDebeHaber_Asiento"(); Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON FUNCTION "tf_AsiendoD_ActualizaDebeHaber_Asiento"() IS 'Funcion de trigger que actualiza las columnas de debe y haber de la tabla Asientos';


--
-- TOC entry 301 (class 1255 OID 20521)
-- Dependencies: 7 885
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
-- TOC entry 3054 (class 0 OID 0)
-- Dependencies: 301
-- Name: FUNCTION "tf_Asiento_ActualizaPeriodo"(); Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON FUNCTION "tf_Asiento_ActualizaPeriodo"() IS 'Funcion de trigger para actualizar las columnas de Mes y Ano, a partir de la fecha especificada';


--
-- TOC entry 302 (class 1255 OID 20522)
-- Dependencies: 7 885
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
-- TOC entry 3055 (class 0 OID 0)
-- Dependencies: 302
-- Name: FUNCTION "tf_Asiento_ActualizaSaldo"(); Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON FUNCTION "tf_Asiento_ActualizaSaldo"() IS 'Funcion que actualiza el saldo de la tabla asiento';


--
-- TOC entry 303 (class 1255 OID 20523)
-- Dependencies: 885 7
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
-- TOC entry 3056 (class 0 OID 0)
-- Dependencies: 303
-- Name: FUNCTION "tf_Bitacora"(); Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON FUNCTION "tf_Bitacora"() IS 'Trigger para el insert de datos en la bitacora de cambios';


SET search_path = seg, pg_catalog;

--
-- TOC entry 305 (class 1255 OID 78873)
-- Dependencies: 885 10
-- Name: verificaperfil(); Type: FUNCTION; Schema: seg; Owner: postgres
--

CREATE FUNCTION verificaperfil() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
modulo integer;
BEGIN
 IF (TG_OP = 'INSERT') THEN

	IF EXISTS (SELECT id_modulo FROM seg.tbl_permiso where id_rol=new.id_rol and id_modulo=new.id_modulo)THEN

		UPDATE seg.tbl_permiso
			SET  bln_borrado=true
		WHERE id_rol=new.id_rol and id_modulo=new.id_modulo;

	END IF;
INSERT INTO seg.tbl_permiso(
		id_modulo, id_rol, int_permiso)
		VALUES (new.id_modulo,new.id_rol,new.int_permiso);
	

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
-- TOC entry 3057 (class 0 OID 0)
-- Dependencies: 167
-- Name: TABLE actiecon; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE actiecon IS 'Tabla con las actividades económicas';


--
-- TOC entry 3058 (class 0 OID 0)
-- Dependencies: 167
-- Name: COLUMN actiecon.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN actiecon.id IS 'Identificador del tipo de actividad económica';


--
-- TOC entry 3059 (class 0 OID 0)
-- Dependencies: 167
-- Name: COLUMN actiecon.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN actiecon.nombre IS 'Nombre de la actividad económica';


--
-- TOC entry 3060 (class 0 OID 0)
-- Dependencies: 167
-- Name: COLUMN actiecon.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN actiecon.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3061 (class 0 OID 0)
-- Dependencies: 167
-- Name: COLUMN actiecon.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN actiecon.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 168 (class 1259 OID 20529)
-- Dependencies: 167 7
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
-- TOC entry 3063 (class 0 OID 0)
-- Dependencies: 168
-- Name: ActiEcon_IDActiEcon_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "ActiEcon_IDActiEcon_seq" OWNED BY actiecon.id;


--
-- TOC entry 169 (class 1259 OID 20531)
-- Dependencies: 2332 2333 2334 2335 2336 2337 2338 2339 2340 2341 2342 7
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
-- TOC entry 3064 (class 0 OID 0)
-- Dependencies: 169
-- Name: TABLE alicimp; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE alicimp IS 'Tabla con los datos de las alicuotas impositivas';


--
-- TOC entry 3065 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.id IS 'Identificador de la alicuota';


--
-- TOC entry 3066 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.tipocontid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.tipocontid IS 'Identificador del tipo de contribuyente';


--
-- TOC entry 3067 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.ano; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.ano IS 'Ano en la que aplica la alicuota';


--
-- TOC entry 3068 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.alicuota; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.alicuota IS '% de la alicuota a pagar';


--
-- TOC entry 3069 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.tipocalc; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.tipocalc IS 'Tipo de calculo a usar para seleccionar la alicuota.
0=Aplicar alicuota directamente.
1=Aplicar alicuota de acuerdo al limite inferior en UT.
2=Aplicar alicuota de acuerdo a rangos en UT';


--
-- TOC entry 3070 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.valorut; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.valorut IS 'Limite inferior en UT al cual se le aplica la alicuota. Aplica para TipoCalc=1';


--
-- TOC entry 3071 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.liminf1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.liminf1 IS 'Limite inferior 1 en UT para aplicacion de alicuota por rango. TipoCalc=2';


--
-- TOC entry 3072 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.limsup1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.limsup1 IS 'Limite superior 1 en UT para aplicacion de alicuota por rango. TipoCalc=2';


--
-- TOC entry 3073 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.alicuota1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.alicuota1 IS 'Alicuota del rango 1. TipoCalc=2';


--
-- TOC entry 3074 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.liminf2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.liminf2 IS 'Limite inferior 2 en UT para aplicacion de alicuota por rango. TipoCalc=2';


--
-- TOC entry 3075 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.limsup2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.limsup2 IS 'Limite superior 2 en UT para aplicacion de alicuota por rango. TipoCalc=2';


--
-- TOC entry 3076 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.alicuota2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.alicuota2 IS 'Alicuota del rango 2. TipoCalc=2';


--
-- TOC entry 3077 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.liminf3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.liminf3 IS 'Limite inferior 3 en UT para aplicacion de alicuota por rango. TipoCalc=2';


--
-- TOC entry 3078 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.limsup3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.limsup3 IS 'Limite superior 3 en UT para aplicacion de alicuota por rango. TipoCalc=2';


--
-- TOC entry 3079 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.alicuota3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.alicuota3 IS 'Alicuota del rango 3. TipoCalc=2';


--
-- TOC entry 3080 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.liminf4; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.liminf4 IS 'Limite inferior 4 en UT para aplicacion de alicuota por rango. TipoCalc=2';


--
-- TOC entry 3081 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.limsup4; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.limsup4 IS 'Limite superior 4 en UT para aplicacion de alicuota por rango. TipoCalc=2';


--
-- TOC entry 3082 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.alicuota4; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.alicuota4 IS 'Alicuota del rango 4. TipoCalc=2';


--
-- TOC entry 3083 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.liminf5; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.liminf5 IS 'Limite inferior 5 en UT para aplicacion de alicuota por rango. TipoCalc=2';


--
-- TOC entry 3084 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.limsup5; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.limsup5 IS 'Limite superior 5 en UT para aplicacion de alicuota por rango. TipoCalc=2';


--
-- TOC entry 3085 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.alicuota5; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.alicuota5 IS 'Alicuota del rango 5. TipoCalc=2';


--
-- TOC entry 3086 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.usuarioid IS 'Identificador del ultimo usuario en crear o modificar un registro';


--
-- TOC entry 3087 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 170 (class 1259 OID 20545)
-- Dependencies: 169 7
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
-- TOC entry 3088 (class 0 OID 0)
-- Dependencies: 170
-- Name: AlicImp_IDAlicImp_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "AlicImp_IDAlicImp_seq" OWNED BY alicimp.id;


--
-- TOC entry 171 (class 1259 OID 20547)
-- Dependencies: 2344 2345 7
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
-- TOC entry 3089 (class 0 OID 0)
-- Dependencies: 171
-- Name: TABLE asientod; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE asientod IS 'Tabla con el detalle de los asientos';


--
-- TOC entry 3090 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN asientod.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientod.id IS 'Identificador unico de registro';


--
-- TOC entry 3091 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN asientod.asientoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientod.asientoid IS 'Identificador del asiento';


--
-- TOC entry 3092 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN asientod.fecha; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientod.fecha IS 'Fecha de la transaccion';


--
-- TOC entry 3093 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN asientod.cuenta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientod.cuenta IS 'Cuenta contable';


--
-- TOC entry 3094 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN asientod.monto; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientod.monto IS 'Monto de la transaccion';


--
-- TOC entry 3095 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN asientod.sentido; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientod.sentido IS 'Sentido del monto. 0=Debe / 1=Haber';


--
-- TOC entry 3096 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN asientod.referencia; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientod.referencia IS 'Referencia de la linea';


--
-- TOC entry 3097 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN asientod.comentar; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientod.comentar IS 'Comentarios u observaciones';


--
-- TOC entry 3098 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN asientod.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientod.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3099 (class 0 OID 0)
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
-- TOC entry 3100 (class 0 OID 0)
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
-- TOC entry 3101 (class 0 OID 0)
-- Dependencies: 174
-- Name: TABLE bacuenta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE bacuenta IS 'Tabla con los datos de las cuentas bancarias';


--
-- TOC entry 3102 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN bacuenta.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN bacuenta.id IS 'Identificador unico de registro';


--
-- TOC entry 3103 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN bacuenta.bancoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN bacuenta.bancoid IS 'Identificador del banco';


--
-- TOC entry 3104 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN bacuenta.cuenta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN bacuenta.cuenta IS 'Numero de cuenta bancaria';


--
-- TOC entry 3105 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN bacuenta.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN bacuenta.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3106 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN bacuenta.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN bacuenta.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 175 (class 1259 OID 20562)
-- Dependencies: 174 7
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
-- TOC entry 3107 (class 0 OID 0)
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
-- TOC entry 3108 (class 0 OID 0)
-- Dependencies: 176
-- Name: TABLE bancos; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE bancos IS 'Tabla con los datos de los bancos que maneja el organismo';


--
-- TOC entry 3109 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN bancos.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN bancos.id IS 'Identificador unico de registro';


--
-- TOC entry 3110 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN bancos.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN bancos.nombre IS 'Nombre del banco';


--
-- TOC entry 3111 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN bancos.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN bancos.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3112 (class 0 OID 0)
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
-- TOC entry 3113 (class 0 OID 0)
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
-- TOC entry 3114 (class 0 OID 0)
-- Dependencies: 178
-- Name: TABLE calpagod; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE calpagod IS 'Tabla con el detalle de los calendario de pagos';


--
-- TOC entry 3115 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN calpagod.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpagod.id IS 'Identificador unico del detalle de los calendarios de pagos';


--
-- TOC entry 3116 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN calpagod.calpagoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpagod.calpagoid IS 'Identificador del calendario de pago';


--
-- TOC entry 3117 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN calpagod.fechaini; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpagod.fechaini IS 'Fecha de inicio del periodo gravable';


--
-- TOC entry 3118 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN calpagod.fechafin; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpagod.fechafin IS 'Fecha final del periodo gravable';


--
-- TOC entry 3119 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN calpagod.fechalim; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpagod.fechalim IS 'Fecha limite de pago del periodo gravable';


--
-- TOC entry 3120 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN calpagod.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpagod.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3121 (class 0 OID 0)
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
-- TOC entry 3122 (class 0 OID 0)
-- Dependencies: 179
-- Name: CalPagoD_IDCalPagoD_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "CalPagoD_IDCalPagoD_seq" OWNED BY calpagod.id;


--
-- TOC entry 180 (class 1259 OID 20574)
-- Dependencies: 2350 7
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
-- TOC entry 3123 (class 0 OID 0)
-- Dependencies: 180
-- Name: TABLE calpago; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE calpago IS 'Tabla con los calendarios de pagos de los diferentes tipos de contribuyentes por año';


--
-- TOC entry 3124 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN calpago.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpago.id IS 'Identificador del calendario de pagos';


--
-- TOC entry 3125 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN calpago.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpago.nombre IS 'Nombre del calendario';


--
-- TOC entry 3126 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN calpago.ano; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpago.ano IS 'Año vigencia del calendario';


--
-- TOC entry 3127 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN calpago.tipegravid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpago.tipegravid IS 'Identificador del tipo de periodo gravable';


--
-- TOC entry 3128 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN calpago.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpago.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3129 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN calpago.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpago.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 181 (class 1259 OID 20578)
-- Dependencies: 180 7
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
-- TOC entry 3130 (class 0 OID 0)
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
    ip character varying(15) NOT NULL
);


ALTER TABLE datos.cargos OWNER TO postgres;

--
-- TOC entry 3131 (class 0 OID 0)
-- Dependencies: 182
-- Name: TABLE cargos; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE cargos IS 'Tabla con los distintos cargos de la organizacion';


--
-- TOC entry 3132 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN cargos.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN cargos.id IS 'Identificador unico del cargo';


--
-- TOC entry 3133 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN cargos.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN cargos.nombre IS 'Nombre del cargo';


--
-- TOC entry 3134 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN cargos.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN cargos.usuarioid IS 'Identificador del usuario que creo el registro o del ultimo en modificarlo';


--
-- TOC entry 3135 (class 0 OID 0)
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
-- TOC entry 3136 (class 0 OID 0)
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
-- TOC entry 3137 (class 0 OID 0)
-- Dependencies: 184
-- Name: TABLE ciudades; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE ciudades IS 'Tabla con las ciudades por estado geografico';


--
-- TOC entry 3138 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN ciudades.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN ciudades.id IS 'Idenficador unico de la ciudad';


--
-- TOC entry 3139 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN ciudades.estadoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN ciudades.estadoid IS 'Identificador del estado';


--
-- TOC entry 3140 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN ciudades.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN ciudades.nombre IS 'Nombre de la ciudad';


--
-- TOC entry 3141 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN ciudades.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN ciudades.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3142 (class 0 OID 0)
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
-- TOC entry 3143 (class 0 OID 0)
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
-- TOC entry 3144 (class 0 OID 0)
-- Dependencies: 186
-- Name: TABLE conusuco; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE conusuco IS 'Tabla con la relacion entre usuarios y a los contribuyentes que representan';


--
-- TOC entry 3145 (class 0 OID 0)
-- Dependencies: 186
-- Name: COLUMN conusuco.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuco.id IS 'Identificador unico de registro';


--
-- TOC entry 3146 (class 0 OID 0)
-- Dependencies: 186
-- Name: COLUMN conusuco.conusuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuco.conusuid IS 'Identificador del usuario';


--
-- TOC entry 3147 (class 0 OID 0)
-- Dependencies: 186
-- Name: COLUMN conusuco.contribuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuco.contribuid IS 'Identificador del contribuyente';


--
-- TOC entry 187 (class 1259 OID 20593)
-- Dependencies: 186 7
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
-- TOC entry 3148 (class 0 OID 0)
-- Dependencies: 187
-- Name: ConUsuCo_IDConUsuCo_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "ConUsuCo_IDConUsuCo_seq" OWNED BY conusuco.id;


--
-- TOC entry 188 (class 1259 OID 20595)
-- Dependencies: 2355 2356 2357 7
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
-- TOC entry 3149 (class 0 OID 0)
-- Dependencies: 188
-- Name: TABLE conusuti; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE conusuti IS 'Tabla con los tipos de usuarios de los contribuyentes';


--
-- TOC entry 3150 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN conusuti.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuti.id IS 'Identificador unico del tipo de usuario de contribuyentes';


--
-- TOC entry 3151 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN conusuti.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuti.nombre IS 'Nombre del tipo de usuario';


--
-- TOC entry 3152 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN conusuti.administra; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuti.administra IS 'Si el tipo de usuario (perfil) administra la cuenta del contribuyente. Crea usuarios, elimina usuarios';


--
-- TOC entry 3153 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN conusuti.liquida; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuti.liquida IS 'Si el tipo de usuario (perfil) liquida planillas de autoliquidacion en la cuenta del contribuyente.';


--
-- TOC entry 3154 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN conusuti.visualiza; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuti.visualiza IS 'Si el tipo de usuario (perfil) solo visualiza datos  de la cuenta del contribuyente.';


--
-- TOC entry 3155 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN conusuti.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuti.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3156 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN conusuti.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuti.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 189 (class 1259 OID 20601)
-- Dependencies: 188 7
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
-- TOC entry 3157 (class 0 OID 0)
-- Dependencies: 189
-- Name: ConUsuTi_IDConUsuTi_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "ConUsuTi_IDConUsuTi_seq" OWNED BY conusuti.id;


--
-- TOC entry 190 (class 1259 OID 20603)
-- Dependencies: 2359 2361 7
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
-- TOC entry 3158 (class 0 OID 0)
-- Dependencies: 190
-- Name: TABLE conusuto; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE conusuto IS 'Tabla con los Tokens activos por usuario, es Tokens se utilizaran para validad la creacion de usuarios, recuperacion de contraseñas, etc.';


--
-- TOC entry 3159 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN conusuto.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuto.id IS 'Idendificador unico del token';


--
-- TOC entry 3160 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN conusuto.token; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuto.token IS 'Token generado';


--
-- TOC entry 3161 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN conusuto.conusuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuto.conusuid IS 'Identificador del usuario dueño del token';


--
-- TOC entry 3162 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN conusuto.fechacrea; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuto.fechacrea IS 'Fecha hora de creacion del token';


--
-- TOC entry 3163 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN conusuto.fechacadu; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuto.fechacadu IS 'Fecha hora de caducidad del token';


--
-- TOC entry 3164 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN conusuto.usado; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuto.usado IS 'Si el token fue usado por el usuario o no';


--
-- TOC entry 191 (class 1259 OID 20610)
-- Dependencies: 190 7
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
-- TOC entry 3165 (class 0 OID 0)
-- Dependencies: 191
-- Name: ConUsuTo_IDConUsuTo_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "ConUsuTo_IDConUsuTo_seq" OWNED BY conusuto.id;


--
-- TOC entry 192 (class 1259 OID 20612)
-- Dependencies: 2363 2364 2365 7
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
-- TOC entry 3166 (class 0 OID 0)
-- Dependencies: 192
-- Name: TABLE conusu; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE conusu IS 'Tabla con los datos de los usuarios por contribuyente';


--
-- TOC entry 3167 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.id IS 'Identificador del usuario del contribuyente';


--
-- TOC entry 3168 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.login; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.login IS 'Login de usuario. Puede usar su correo para hacer login';


--
-- TOC entry 3169 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.password; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.password IS 'Hash del pasword para hacer login';


--
-- TOC entry 3170 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.nombre IS 'Nombre del usuario. Este es el nombre que se muestra';


--
-- TOC entry 3171 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.inactivo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.inactivo IS 'Si el usuario esta inactivo o no. False=No / True=Si';


--
-- TOC entry 3172 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.conusutiid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.conusutiid IS 'Identificador del tipo de usuario de contribuyentes';


--
-- TOC entry 3173 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.email; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.email IS 'Direccion de email del usuario, se utilizara para validar la cuenta';


--
-- TOC entry 3174 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.pregsecrid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.pregsecrid IS 'Identificador de la pregunta secreta seleccionada por en usuario';


--
-- TOC entry 3175 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.respuesta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.respuesta IS 'Hash con la respuesta a la pregunta secreta';


--
-- TOC entry 3176 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.ultlogin; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.ultlogin IS 'Fecha y hora de la ultima vez que el usuario hizo login';


--
-- TOC entry 3177 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3178 (class 0 OID 0)
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
-- TOC entry 3179 (class 0 OID 0)
-- Dependencies: 193
-- Name: ConUsu_IDConUsu_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "ConUsu_IDConUsu_seq" OWNED BY conusu.id;


--
-- TOC entry 194 (class 1259 OID 20621)
-- Dependencies: 2366 2367 2368 2369 7
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
-- TOC entry 3180 (class 0 OID 0)
-- Dependencies: 194
-- Name: TABLE contribu; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE contribu IS 'Tabla con los datos de los contribuyentes de la institución';


--
-- TOC entry 3181 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.id IS 'Identificador unico del contribuyente';


--
-- TOC entry 3182 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.razonsocia; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.razonsocia IS 'Razon social del contribuyente';


--
-- TOC entry 3183 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.dencomerci; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.dencomerci IS 'Denominacion comercial del contribuyente';


--
-- TOC entry 3184 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.actieconid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.actieconid IS 'Identificador de la actividad economica';


--
-- TOC entry 3185 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.rif; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.rif IS 'Rif del contribuyente';


--
-- TOC entry 3186 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.numregcine; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.numregcine IS 'Numero de registro cinematografico';


--
-- TOC entry 3187 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.domfiscal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.domfiscal IS 'Domicilio fiscal del contribuyente';


--
-- TOC entry 3188 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.estadoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.estadoid IS 'Identicador del estado geografico';


--
-- TOC entry 3189 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.ciudadid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.ciudadid IS 'Identificador de la ciudad';


--
-- TOC entry 3190 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.zonapostal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.zonapostal IS 'Zona postal del contribuyente';


--
-- TOC entry 3191 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.telef1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.telef1 IS 'Telefono 1 del contribuyente';


--
-- TOC entry 3192 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.telef2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.telef2 IS 'Telefono 2 del contribuyente';


--
-- TOC entry 3193 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.telef3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.telef3 IS 'Telefono 3 del contribuyente';


--
-- TOC entry 3194 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.fax1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.fax1 IS 'Fax 1 del contribuyente';


--
-- TOC entry 3195 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.fax2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.fax2 IS 'Fax 2 del contribuyente';


--
-- TOC entry 3196 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.email; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.email IS 'Direccion de email de contribuyente';


--
-- TOC entry 3197 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.pinbb; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.pinbb IS 'Pin de BlackBerry';


--
-- TOC entry 3198 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.skype; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.skype IS 'Dirección de skype';


--
-- TOC entry 3199 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.twitter; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.twitter IS 'Direccion de twitter';


--
-- TOC entry 3200 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.facebook; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.facebook IS 'Direccion de facebook';


--
-- TOC entry 3201 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.nuacciones; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.nuacciones IS 'Numero de acciones del contribuyente segun inforacion del registro mercantil';


--
-- TOC entry 3202 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.valaccion; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.valaccion IS 'Valor nominal por accion segun registro mercantil';


--
-- TOC entry 3203 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.capitalsus; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.capitalsus IS 'Capital suscrito segun registro mercantil';


--
-- TOC entry 3204 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.capitalpag; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.capitalpag IS 'Capital pagado segun registro mercantil';


--
-- TOC entry 3205 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.regmerofc; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.regmerofc IS 'Oficina de registro mercantil en donde se registro la empresa';


--
-- TOC entry 3206 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.rmnumero; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.rmnumero IS 'Numero de registro del documento de registro mercantil';


--
-- TOC entry 3207 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.rmfolio; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.rmfolio IS 'Numero de folio del documento de registro mercantil';


--
-- TOC entry 3208 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.rmtomo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.rmtomo IS 'Numero de folio del documento de registro mercantil';


--
-- TOC entry 3209 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.rmfechapro; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.rmfechapro IS 'Fecha de protocololizacion del registro del documento de registro mercantil';


--
-- TOC entry 3210 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.rmncontrol; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.rmncontrol IS 'Numero de control del documento de registro mercantil';


--
-- TOC entry 3211 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.rmobjeto; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.rmobjeto IS 'Objeto de la empresa segun registro mercantil';


--
-- TOC entry 3212 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.domcomer; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.domcomer IS 'domicilio comercial';


--
-- TOC entry 3213 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.cextra1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.cextra1 IS 'Campo extra 1';


--
-- TOC entry 3214 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.cextra2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.cextra2 IS 'Campo extra 2';


--
-- TOC entry 3215 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.cextra3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.cextra3 IS 'Campo extra 3';


--
-- TOC entry 3216 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.cextra4; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.cextra4 IS 'Campo extra 4';


--
-- TOC entry 3217 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.cextra5; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.cextra5 IS 'Campo extra 5';


--
-- TOC entry 3218 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.usuarioid IS 'identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3219 (class 0 OID 0)
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
-- TOC entry 3220 (class 0 OID 0)
-- Dependencies: 195
-- Name: Contribu_IDContribu_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "Contribu_IDContribu_seq" OWNED BY contribu.id;


--
-- TOC entry 196 (class 1259 OID 20633)
-- Dependencies: 2371 2372 2373 2374 2375 2376 2377 2378 7
-- Name: declara; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE declara (
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


ALTER TABLE datos.declara OWNER TO postgres;

--
-- TOC entry 3221 (class 0 OID 0)
-- Dependencies: 196
-- Name: TABLE declara; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE declara IS 'Planilla de declaracion de impuestos';


--
-- TOC entry 3222 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.id IS 'Identificador unico de la declaracion de impuestos';


--
-- TOC entry 3223 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara.nudeclara; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.nudeclara IS 'Numero de planilla de declaracion de impuesto';


--
-- TOC entry 3224 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara.nudeposito; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.nudeposito IS 'Numero de deposito bancario generado por el sistema';


--
-- TOC entry 3225 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara.tdeclaraid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.tdeclaraid IS 'Identificador del tipo de declaracion';


--
-- TOC entry 3226 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara.fechaelab; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.fechaelab IS 'Fecha de elaboracion de la planilla de pago de impuestos';


--
-- TOC entry 3227 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara.fechaini; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.fechaini IS 'Fecha de inicio del periodo gravable';


--
-- TOC entry 3228 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara.fechafin; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.fechafin IS 'Fecha final del periodo gravable';


--
-- TOC entry 3229 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara.replegalid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.replegalid IS 'Identificador del representante legal que aparecera en la planilla y firmara la misma';


--
-- TOC entry 3230 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara.baseimpo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.baseimpo IS 'Base imponible';


--
-- TOC entry 3231 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara.alicuota; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.alicuota IS 'Alicuota impositiva aplicada a la declaracion de impuesto';


--
-- TOC entry 3232 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara.exonera; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.exonera IS 'Exoneracion o rebaja';


--
-- TOC entry 3233 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara.nuactoexon; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.nuactoexon IS 'Numero de acto en donde se establece la exoneracion o rebaja';


--
-- TOC entry 3234 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara.credfiscal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.credfiscal IS 'Credito fiscal';


--
-- TOC entry 3235 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara.contribant; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.contribant IS 'Monto de la contribucion pagada en periodos anteriores';


--
-- TOC entry 3236 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara.plasustid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.plasustid IS 'Identificador de la planilla que se esta sustituyendo en caso de ser una declaracion sustitutiva';


--
-- TOC entry 3237 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara.nuresactfi; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.nuresactfi IS 'Numero de resolucion o numero de acta fiscal';


--
-- TOC entry 3238 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara.fechanoti; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.fechanoti IS 'Fecha de notificacion';


--
-- TOC entry 3239 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara.intemora; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.intemora IS 'Intereses moratorios';


--
-- TOC entry 3240 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara.reparofis; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.reparofis IS 'Reparo fiscal';


--
-- TOC entry 3241 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara.multa; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.multa IS 'Multa aplicada';


--
-- TOC entry 3242 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara.montopagar; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.montopagar IS 'Monto a pagar';


--
-- TOC entry 3243 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara.fechapago; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.fechapago IS 'Fecha de pago en el banco. Se llena este campo cuando se concilian los pagos';


--
-- TOC entry 3244 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara.fechaconci; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.fechaconci IS 'Fecha hora de la conciliacion contra los depositos del banco';


--
-- TOC entry 3245 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara.asientoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.asientoid IS 'Identificador del asiento contable en donde se registro la informacion del pago';


--
-- TOC entry 3246 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.usuarioid IS 'Identificador del usuario que concilio el pago de la declaracion. ';


--
-- TOC entry 3247 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 197 (class 1259 OID 20645)
-- Dependencies: 196 7
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
-- TOC entry 3248 (class 0 OID 0)
-- Dependencies: 197
-- Name: Declara_IDDeclara_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "Declara_IDDeclara_seq" OWNED BY declara.id;


--
-- TOC entry 198 (class 1259 OID 20647)
-- Dependencies: 7
-- Name: departam; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE departam (
    id integer NOT NULL,
    nombre character varying(200) NOT NULL,
    usuarioid integer NOT NULL,
    ip character varying(15) NOT NULL
);


ALTER TABLE datos.departam OWNER TO postgres;

--
-- TOC entry 3249 (class 0 OID 0)
-- Dependencies: 198
-- Name: TABLE departam; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE departam IS 'Tabla con los departamentos / gerencia de la organizacion';


--
-- TOC entry 3250 (class 0 OID 0)
-- Dependencies: 198
-- Name: COLUMN departam.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN departam.id IS 'Identificador unico del departamento';


--
-- TOC entry 3251 (class 0 OID 0)
-- Dependencies: 198
-- Name: COLUMN departam.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN departam.nombre IS 'Nombre del departamento o gerencia';


--
-- TOC entry 3252 (class 0 OID 0)
-- Dependencies: 198
-- Name: COLUMN departam.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN departam.usuarioid IS 'Identificador del usuario que creo el registro o del ultimo en modificarlo';


--
-- TOC entry 3253 (class 0 OID 0)
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
-- TOC entry 3254 (class 0 OID 0)
-- Dependencies: 199
-- Name: Departam_IDDepartam_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "Departam_IDDepartam_seq" OWNED BY departam.id;


--
-- TOC entry 200 (class 1259 OID 20652)
-- Dependencies: 2381 7
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
-- TOC entry 3255 (class 0 OID 0)
-- Dependencies: 200
-- Name: TABLE entidadd; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE entidadd IS 'Tabla con el detalle de las entidades. Acciones y procesos a verificar acceso por entidad';


--
-- TOC entry 3256 (class 0 OID 0)
-- Dependencies: 200
-- Name: COLUMN entidadd.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN entidadd.id IS 'Identificador unico del detalle de la entidad';


--
-- TOC entry 3257 (class 0 OID 0)
-- Dependencies: 200
-- Name: COLUMN entidadd.entidadid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN entidadd.entidadid IS 'Identificador de la entidad a la que pertenece la accion o preceso';


--
-- TOC entry 3258 (class 0 OID 0)
-- Dependencies: 200
-- Name: COLUMN entidadd.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN entidadd.nombre IS 'Nombre de la accion o proceso a mostrar en el arbol de permisos disponibles';


--
-- TOC entry 3259 (class 0 OID 0)
-- Dependencies: 200
-- Name: COLUMN entidadd.accion; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN entidadd.accion IS 'Nombre interno de la accion o proceso';


--
-- TOC entry 3260 (class 0 OID 0)
-- Dependencies: 200
-- Name: COLUMN entidadd.orden; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN entidadd.orden IS 'Orden en que apareceran las acciones y/o procesos dentro del arbol de una entidad';


--
-- TOC entry 201 (class 1259 OID 20656)
-- Dependencies: 200 7
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
-- TOC entry 3261 (class 0 OID 0)
-- Dependencies: 201
-- Name: EntidadD_IDEntidadD_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "EntidadD_IDEntidadD_seq" OWNED BY entidadd.id;


--
-- TOC entry 202 (class 1259 OID 20658)
-- Dependencies: 2383 7
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
-- TOC entry 3262 (class 0 OID 0)
-- Dependencies: 202
-- Name: TABLE entidad; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE entidad IS 'Tabla con las entidades del sistema';


--
-- TOC entry 3263 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN entidad.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN entidad.id IS 'Identificador de la entidad';


--
-- TOC entry 3264 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN entidad.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN entidad.nombre IS 'Nombre de la entidad a mostrar en el arbol de permisos disponibles';


--
-- TOC entry 3265 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN entidad.entidad; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN entidad.entidad IS 'Nombre interno de la entidad';


--
-- TOC entry 3266 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN entidad.orden; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN entidad.orden IS 'Orden en la que apareceran la entidades en el arbol de permisos de usuarios';


--
-- TOC entry 203 (class 1259 OID 20662)
-- Dependencies: 202 7
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
-- TOC entry 3267 (class 0 OID 0)
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
-- TOC entry 3268 (class 0 OID 0)
-- Dependencies: 204
-- Name: TABLE estados; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE estados IS 'Tabla con los estados geográficos';


--
-- TOC entry 3269 (class 0 OID 0)
-- Dependencies: 204
-- Name: COLUMN estados.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN estados.id IS 'Identificador unico del estado';


--
-- TOC entry 3270 (class 0 OID 0)
-- Dependencies: 204
-- Name: COLUMN estados.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN estados.nombre IS 'Nombre del estado geografico';


--
-- TOC entry 3271 (class 0 OID 0)
-- Dependencies: 204
-- Name: COLUMN estados.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN estados.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3272 (class 0 OID 0)
-- Dependencies: 204
-- Name: COLUMN estados.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN estados.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 205 (class 1259 OID 20667)
-- Dependencies: 204 7
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
-- TOC entry 3273 (class 0 OID 0)
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
-- TOC entry 3274 (class 0 OID 0)
-- Dependencies: 206
-- Name: TABLE perusud; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE perusud IS 'Tabla con los datos del detalle de los perfiles de usuario. Detalles de entidades habilitadas para el perfil seleccionado';


--
-- TOC entry 3275 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN perusud.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN perusud.id IS 'Identificador unico del detalle de perfil de usuario';


--
-- TOC entry 3276 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN perusud.perusuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN perusud.perusuid IS 'Identificador del perfil al cual pertenece el detalle (accion o proceso permisado)';


--
-- TOC entry 3277 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN perusud.entidaddid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN perusud.entidaddid IS 'Identificador de la accion o proceso permisado (detalles de las entidades)';


--
-- TOC entry 3278 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN perusud.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN perusud.usuarioid IS 'Identificador del usuario que creo el registro o el ultimo en modificarlo';


--
-- TOC entry 3279 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN perusud.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN perusud.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 207 (class 1259 OID 20672)
-- Dependencies: 206 7
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
-- TOC entry 3280 (class 0 OID 0)
-- Dependencies: 207
-- Name: PerUsuD_IDPerUsuD_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "PerUsuD_IDPerUsuD_seq" OWNED BY perusud.id;


--
-- TOC entry 208 (class 1259 OID 20674)
-- Dependencies: 2387 7
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
-- TOC entry 3281 (class 0 OID 0)
-- Dependencies: 208
-- Name: TABLE perusu; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE perusu IS 'Tabla con los perfiles de usuarios';


--
-- TOC entry 3282 (class 0 OID 0)
-- Dependencies: 208
-- Name: COLUMN perusu.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN perusu.id IS 'Identificador del perfl de usuario';


--
-- TOC entry 3283 (class 0 OID 0)
-- Dependencies: 208
-- Name: COLUMN perusu.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN perusu.nombre IS 'Nombre del perfil de usuario';


--
-- TOC entry 3284 (class 0 OID 0)
-- Dependencies: 208
-- Name: COLUMN perusu.inactivo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN perusu.inactivo IS 'Si el pelfil de usuario esta Inactivo o no';


--
-- TOC entry 3285 (class 0 OID 0)
-- Dependencies: 208
-- Name: COLUMN perusu.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN perusu.usuarioid IS 'Identificador de usuario que creo o el ultimo que actualizo el registro';


--
-- TOC entry 3286 (class 0 OID 0)
-- Dependencies: 208
-- Name: COLUMN perusu.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN perusu.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 209 (class 1259 OID 20678)
-- Dependencies: 208 7
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
-- TOC entry 3287 (class 0 OID 0)
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
-- TOC entry 3288 (class 0 OID 0)
-- Dependencies: 210
-- Name: TABLE pregsecr; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE pregsecr IS 'Tablas con las preguntas secretas validas para la recuperacion de contraseñas';


--
-- TOC entry 3289 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN pregsecr.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN pregsecr.id IS 'Identificador unico de la pregunta secreta';


--
-- TOC entry 3290 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN pregsecr.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN pregsecr.nombre IS 'Texto de la pregunta secreta';


--
-- TOC entry 3291 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN pregsecr.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN pregsecr.usuarioid IS 'Identificado del ultimo usuario que creo o actualizo el registro';


--
-- TOC entry 3292 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN pregsecr.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN pregsecr.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 211 (class 1259 OID 20683)
-- Dependencies: 210 7
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
-- TOC entry 3293 (class 0 OID 0)
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
-- TOC entry 3294 (class 0 OID 0)
-- Dependencies: 212
-- Name: TABLE replegal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE replegal IS 'Tabla con los datos de los Accionistas de los contribuyentes';


--
-- TOC entry 3295 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.id IS 'Identificador unico del representante legal';


--
-- TOC entry 3296 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.contribuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.contribuid IS 'Identificador del contribuyente';


--
-- TOC entry 3297 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.nombre IS 'Nombre del representante legal';


--
-- TOC entry 3298 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.apellido; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.apellido IS 'Apellidos del representante legal';


--
-- TOC entry 3299 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.ci; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.ci IS 'Cedula de identidad, numero de pasaporte';


--
-- TOC entry 3300 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.domfiscal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.domfiscal IS 'Domicilio fiscal del representante legal';


--
-- TOC entry 3301 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.estadoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.estadoid IS 'Identificador del estado geografico';


--
-- TOC entry 3302 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.ciudadid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.ciudadid IS 'Identificador de la ciudad';


--
-- TOC entry 3303 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.zonaposta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.zonaposta IS 'Zona postal';


--
-- TOC entry 3304 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.telefhab; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.telefhab IS 'Telefono de habitacion del representante legal';


--
-- TOC entry 3305 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.telefofc; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.telefofc IS 'Telefono de oficina del representante legal';


--
-- TOC entry 3306 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.fax; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.fax IS 'Fax del representante legal';


--
-- TOC entry 3307 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.email; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.email IS 'Direccion de email del contribuyente';


--
-- TOC entry 3308 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.pinbb; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.pinbb IS 'Pin de BlackBerry';


--
-- TOC entry 3309 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.skype; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.skype IS 'Direccion de skype del representante legal';


--
-- TOC entry 3310 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.cextra1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.cextra1 IS 'Campo extra 1';


--
-- TOC entry 3311 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.cextra2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.cextra2 IS 'Campo extra 2';


--
-- TOC entry 3312 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.cextra3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.cextra3 IS 'Campo extra 3';


--
-- TOC entry 3313 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.cextra4; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.cextra4 IS 'Campo extra 4';


--
-- TOC entry 3314 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.cextra5; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.cextra5 IS 'Campo extra 5';


--
-- TOC entry 3315 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3316 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 213 (class 1259 OID 20691)
-- Dependencies: 212 7
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
-- TOC entry 3317 (class 0 OID 0)
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
-- TOC entry 3318 (class 0 OID 0)
-- Dependencies: 214
-- Name: TABLE tdeclara; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE tdeclara IS 'Tipo de declaracion de impuestos';


--
-- TOC entry 3319 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN tdeclara.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tdeclara.id IS 'Identificador unico de registro';


--
-- TOC entry 3320 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN tdeclara.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tdeclara.nombre IS 'Nombre del tipo de declaracion de impuesto. Ejm. Autoliquidacion, Sustitutiva, etc';


--
-- TOC entry 3321 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN tdeclara.tipo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tdeclara.tipo IS 'Tipo de declaracion a efectuar. Utilizamos este campo para activar/desactivar la seccion correspondiente a los datos de la liquidacion en la planilla de pago de impuestos.
0 = Autoliquidación / Sustitutiva
1 = Multa por pago extemporaneo / Reparo fiscal
2 = Multa
3 = Intereses Moratorios';


--
-- TOC entry 3322 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN tdeclara.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tdeclara.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro.';


--
-- TOC entry 3323 (class 0 OID 0)
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
-- TOC entry 3324 (class 0 OID 0)
-- Dependencies: 215
-- Name: TDeclara_IDTDeclara_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "TDeclara_IDTDeclara_seq" OWNED BY tdeclara.id;


--
-- TOC entry 216 (class 1259 OID 20698)
-- Dependencies: 2392 2393 7
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
-- TOC entry 3325 (class 0 OID 0)
-- Dependencies: 216
-- Name: TABLE tipegrav; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE tipegrav IS 'Tabla con los tipos de períodos gravables';


--
-- TOC entry 3326 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN tipegrav.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipegrav.id IS 'Identificador del tipo de periodo gravable';


--
-- TOC entry 3327 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN tipegrav.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipegrav.nombre IS 'Nombre del tipo de período gravable. Ejm. Mensual, trimestral, anual';


--
-- TOC entry 3328 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN tipegrav.tipe; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipegrav.tipe IS 'Tipo de periodo. 0=Mensual / 1=Trimestral / 2=Anual';


--
-- TOC entry 3329 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN tipegrav.peano; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipegrav.peano IS 'Numero de periodos gravables en año fiscal';


--
-- TOC entry 3330 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN tipegrav.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipegrav.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3331 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN tipegrav.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipegrav.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 217 (class 1259 OID 20703)
-- Dependencies: 7 216
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
-- TOC entry 3332 (class 0 OID 0)
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
    ip character varying(15) NOT NULL
);


ALTER TABLE datos.tipocont OWNER TO postgres;

--
-- TOC entry 3333 (class 0 OID 0)
-- Dependencies: 218
-- Name: TABLE tipocont; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE tipocont IS 'Tabla con los tipos de contribuyentes';


--
-- TOC entry 3334 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN tipocont.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipocont.id IS 'Identificador unico del tipo de contribuyente';


--
-- TOC entry 3335 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN tipocont.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipocont.nombre IS 'Nombre o descripción del tipo de contribuyente. Ejm Exibidores cinematográficos';


--
-- TOC entry 3336 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN tipocont.tipegravid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipocont.tipegravid IS 'Identificador del tipo de periodo gravable';


--
-- TOC entry 3337 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN tipocont.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipocont.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3338 (class 0 OID 0)
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
-- TOC entry 3339 (class 0 OID 0)
-- Dependencies: 219
-- Name: TipoCont_IDTipoCont_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "TipoCont_IDTipoCont_seq" OWNED BY tipocont.id;


--
-- TOC entry 220 (class 1259 OID 20710)
-- Dependencies: 2396 7
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
-- TOC entry 3340 (class 0 OID 0)
-- Dependencies: 220
-- Name: TABLE undtrib; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE undtrib IS 'Tabla con los valores de conversion de las unidades tributarias';


--
-- TOC entry 3341 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN undtrib.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN undtrib.id IS 'Identificador unico de registro';


--
-- TOC entry 3342 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN undtrib.fecha; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN undtrib.fecha IS 'Fecha a partir de la cual esta vigente el valor de la unidad tributaria';


--
-- TOC entry 3343 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN undtrib.valor; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN undtrib.valor IS 'Valor en Bs de una unidad tributaria';


--
-- TOC entry 3344 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN undtrib.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN undtrib.usuarioid IS 'Identificador del ultimo usuario que creo o modifico un registro';


--
-- TOC entry 3345 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN undtrib.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN undtrib.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 221 (class 1259 OID 20714)
-- Dependencies: 7 220
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
-- TOC entry 3346 (class 0 OID 0)
-- Dependencies: 221
-- Name: UndTrib_IDUndTrib_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "UndTrib_IDUndTrib_seq" OWNED BY undtrib.id;


--
-- TOC entry 222 (class 1259 OID 20716)
-- Dependencies: 2398 7
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
-- TOC entry 3347 (class 0 OID 0)
-- Dependencies: 222
-- Name: TABLE usfonpto; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE usfonpto IS 'Tabla con los Tokens activos por usuario Fonprocine, es Tokens se utilizaran para validad la creacion de usuarios, recuperacion de contraseñas, etc.';


--
-- TOC entry 3348 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN usfonpto.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpto.id IS 'Identificador unico del Token';


--
-- TOC entry 3349 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN usfonpto.token; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpto.token IS 'Token generado';


--
-- TOC entry 3350 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN usfonpto.usfonproid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpto.usfonproid IS 'Identificador del usuario de fonprocine';


--
-- TOC entry 3351 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN usfonpto.fechacrea; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpto.fechacrea IS 'Fecha hora creacion del token';


--
-- TOC entry 3352 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN usfonpto.fechacadu; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpto.fechacadu IS 'Fecha hora caducidad del token';


--
-- TOC entry 3353 (class 0 OID 0)
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
-- TOC entry 3354 (class 0 OID 0)
-- Dependencies: 223
-- Name: UsFonpTo_IDUsFonpTo_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "UsFonpTo_IDUsFonpTo_seq" OWNED BY usfonpto.id;


--
-- TOC entry 224 (class 1259 OID 20725)
-- Dependencies: 2400 7
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
-- TOC entry 3355 (class 0 OID 0)
-- Dependencies: 224
-- Name: TABLE usfonpro; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE usfonpro IS 'Tabla con los datos de los usuarios de la organizacion';


--
-- TOC entry 3356 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.id IS 'Identificador unico de usuario';


--
-- TOC entry 3357 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.login; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.login IS 'Login de usuario';


--
-- TOC entry 3358 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.password; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.password IS 'Passwrod de usuario';


--
-- TOC entry 3359 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.nombre IS 'Nombre del usuario';


--
-- TOC entry 3360 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.email; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.email IS 'Email del usuario';


--
-- TOC entry 3361 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.telefofc; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.telefofc IS 'Telefono de oficina';


--
-- TOC entry 3362 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.extension; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.extension IS 'Extension telefonica';


--
-- TOC entry 3363 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.departamid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.departamid IS 'Identificador del departamento al que pertenece el usuario';


--
-- TOC entry 3364 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.cargoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.cargoid IS 'Identificador del cargo del usuario';


--
-- TOC entry 3365 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.inactivo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.inactivo IS 'Si el usuario esta inactivo o no';


--
-- TOC entry 3366 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.pregsecrid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.pregsecrid IS 'Identificador de la pregunta secreta';


--
-- TOC entry 3367 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.respuesta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.respuesta IS 'Hash de la respuesta a la pregunta secreta';


--
-- TOC entry 3368 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.perusuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.perusuid IS 'Identificador del perfil de usuario';


--
-- TOC entry 3369 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.ultlogin; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.ultlogin IS 'Fecha hora del login del usuario al sistema';


--
-- TOC entry 3370 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.usuarioid IS 'Identificador del usuario que creo el registro o del ultimo que lo modifico';


--
-- TOC entry 3371 (class 0 OID 0)
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
-- TOC entry 3372 (class 0 OID 0)
-- Dependencies: 225
-- Name: Usuarios_IDUsuario_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "Usuarios_IDUsuario_seq" OWNED BY usfonpro.id;


--
-- TOC entry 226 (class 1259 OID 20731)
-- Dependencies: 2402 2403 2404 7
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
-- TOC entry 3373 (class 0 OID 0)
-- Dependencies: 226
-- Name: TABLE accionis; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE accionis IS 'Tabla con los datos de los Accionistas de los contribuyentes';


--
-- TOC entry 3374 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.id IS 'Identificador unico del accionista';


--
-- TOC entry 3375 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.contribuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.contribuid IS 'Identificador del contribuyente';


--
-- TOC entry 3376 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.nombre IS 'Nombre del accionista';


--
-- TOC entry 3377 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.apellido; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.apellido IS 'Apellidos del accionista';


--
-- TOC entry 3378 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.ci; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.ci IS 'Cedula de identidad, numero de pasaporte';


--
-- TOC entry 3379 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.domfiscal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.domfiscal IS 'Domicilio fiscal del accionista';


--
-- TOC entry 3380 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.nuacciones; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.nuacciones IS 'Numero de acciones';


--
-- TOC entry 3381 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.valaccion; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.valaccion IS 'Valor nominal de las acciones';


--
-- TOC entry 3382 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.cextra1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.cextra1 IS 'Campo extra 1';


--
-- TOC entry 3383 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.cextra2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.cextra2 IS 'Campo extra 2';


--
-- TOC entry 3384 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.cextra3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.cextra3 IS 'Campo extra 3';


--
-- TOC entry 3385 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.cextra4; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.cextra4 IS 'Campo extra 4';


--
-- TOC entry 3386 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.cextra5; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.cextra5 IS 'Campo extra 5';


--
-- TOC entry 3387 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3388 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 227 (class 1259 OID 20740)
-- Dependencies: 2405 2406 2407 2408 2409 2410 2411 2412 7
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
-- TOC entry 3389 (class 0 OID 0)
-- Dependencies: 227
-- Name: TABLE asiento; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE asiento IS 'Tabla con los datos cabecera de los asiento contable';


--
-- TOC entry 3390 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN asiento.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.id IS 'Identificador unico de registro';


--
-- TOC entry 3391 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN asiento.nuasiento; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.nuasiento IS 'Numero de asiento. Empieza en uno al comienzo de cada mes.

Este valor de este campo lo asigna la base de datos';


--
-- TOC entry 3392 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN asiento.fecha; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.fecha IS 'Fecha del asiento';


--
-- TOC entry 3393 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN asiento.mes; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.mes IS 'Mes del asiento. Lo utilizamos para evitar que se utilice un numero de asiento repetido para un mes/año.

Este valor de este campo lo asigna la base de datos';


--
-- TOC entry 3394 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN asiento.ano; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.ano IS 'Año del asiento. Lo utilizamos para evitar que se utilice un numero de asiento repetido para un mes/año.

Este valor de este campo lo asigna la base de datos';


--
-- TOC entry 3395 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN asiento.debe; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.debe IS 'Sumatoria del debe del asiento.

Este valor de este campo lo asigna la base de datos';


--
-- TOC entry 3396 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN asiento.haber; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.haber IS 'Sumatoria del debe del asiento.

Este valor de este campo lo asigna la base de datos';


--
-- TOC entry 3397 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN asiento.saldo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.saldo IS 'Saldo del asiento.

Este valor de este campo lo asigna la base de datos.';


--
-- TOC entry 3398 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN asiento.comentar; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.comentar IS 'Comentario u observaciones del asiento';


--
-- TOC entry 3399 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN asiento.cerrado; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.cerrado IS 'Si el asiento esta cerrado o no. Solo se pueden cerrar asientos que el saldo sea 0. Un asiento cerrado no puede ser modificado';


--
-- TOC entry 3400 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN asiento.uscierreid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.uscierreid IS 'Identificador del usuario que cerro el asiento';


--
-- TOC entry 3401 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN asiento.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.usuarioid IS 'Identificador del ultimo usuario en crear o modificar el registro';


--
-- TOC entry 3402 (class 0 OID 0)
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
-- TOC entry 3403 (class 0 OID 0)
-- Dependencies: 228
-- Name: TABLE asientom; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE asientom IS 'Tabla con los asientos modelos a utilizar';


--
-- TOC entry 3404 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN asientom.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientom.id IS 'Identificador unico de registro';


--
-- TOC entry 3405 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN asientom.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientom.nombre IS 'nombre del asiento modelo';


--
-- TOC entry 3406 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN asientom.comentar; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientom.comentar IS 'Comentarios u observaciones';


--
-- TOC entry 3407 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN asientom.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientom.usuarioid IS 'Identificador del usuario que creo o el ultimo en modificar el registro';


--
-- TOC entry 3408 (class 0 OID 0)
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
-- TOC entry 3409 (class 0 OID 0)
-- Dependencies: 229
-- Name: asientom_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE asientom_id_seq OWNED BY asientom.id;


--
-- TOC entry 230 (class 1259 OID 20762)
-- Dependencies: 2414 7
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
-- TOC entry 3410 (class 0 OID 0)
-- Dependencies: 230
-- Name: TABLE asientomd; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE asientomd IS 'Tabla con el detalle de los asientos modelos';


--
-- TOC entry 3411 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN asientomd.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientomd.id IS 'Identificador unico de registro';


--
-- TOC entry 3412 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN asientomd.asientomid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientomd.asientomid IS 'Identificador del asiento';


--
-- TOC entry 3413 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN asientomd.cuenta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientomd.cuenta IS 'Cuenta contable';


--
-- TOC entry 3414 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN asientomd.sentido; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientomd.sentido IS 'Sentido del monto. 0=debe / 1=haber';


--
-- TOC entry 3415 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN asientomd.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientomd.usuarioid IS 'Identificador del usuario que creo el registro o del ultimo en modificarlo';


--
-- TOC entry 3416 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN asientomd.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientomd.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 231 (class 1259 OID 20766)
-- Dependencies: 7 230
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
-- TOC entry 3417 (class 0 OID 0)
-- Dependencies: 231
-- Name: asientomd_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE asientomd_id_seq OWNED BY asientomd.id;


--
-- TOC entry 267 (class 1259 OID 46443)
-- Dependencies: 2454 7
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
-- TOC entry 3418 (class 0 OID 0)
-- Dependencies: 267
-- Name: TABLE con_img_doc; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE con_img_doc IS 'Tabla con las imagenes de los documentos subidos por los contribuyentes adjunto a la planilla de complementaria de datos para el registro.';


--
-- TOC entry 3419 (class 0 OID 0)
-- Dependencies: 267
-- Name: COLUMN con_img_doc.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN con_img_doc.id IS 'Campo principal, valor unico identificador.';


--
-- TOC entry 3420 (class 0 OID 0)
-- Dependencies: 267
-- Name: COLUMN con_img_doc.conusuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN con_img_doc.conusuid IS 'ID  del contribuyente al cual estan asociados los documentos guardados.';


--
-- TOC entry 266 (class 1259 OID 46441)
-- Dependencies: 7 267
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
-- TOC entry 3421 (class 0 OID 0)
-- Dependencies: 266
-- Name: con_img_doc_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE con_img_doc_id_seq OWNED BY con_img_doc.id;


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
-- TOC entry 3422 (class 0 OID 0)
-- Dependencies: 232
-- Name: TABLE contributi; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE contributi IS 'tabla con los tipo de contribuyentes por contribuyente';


--
-- TOC entry 3423 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN contributi.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contributi.id IS 'Identificador unico de registro';


--
-- TOC entry 3424 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN contributi.contribuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contributi.contribuid IS 'Id del contribuyente';


--
-- TOC entry 3425 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN contributi.tipocontid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contributi.tipocontid IS 'Identificador del tipo de contribuyente';


--
-- TOC entry 3426 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN contributi.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contributi.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 233 (class 1259 OID 20771)
-- Dependencies: 232 7
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
-- TOC entry 3427 (class 0 OID 0)
-- Dependencies: 233
-- Name: contributi_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE contributi_id_seq OWNED BY contributi.id;


--
-- TOC entry 270 (class 1259 OID 69000)
-- Dependencies: 7
-- Name: conusu_tipocont; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE conusu_tipocont (
    id integer NOT NULL,
    conusuid integer NOT NULL,
    tipocontid integer,
    ip character varying(20) NOT NULL
);


ALTER TABLE datos.conusu_tipocont OWNER TO postgres;

--
-- TOC entry 3428 (class 0 OID 0)
-- Dependencies: 270
-- Name: COLUMN conusu_tipocont.conusuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu_tipocont.conusuid IS 'Campo que se relaciona con la tabla del contribuyente (conusu)';


--
-- TOC entry 3429 (class 0 OID 0)
-- Dependencies: 270
-- Name: COLUMN conusu_tipocont.tipocontid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu_tipocont.tipocontid IS 'Campo que establece la relacion con los tipos de contribuyentes';


--
-- TOC entry 269 (class 1259 OID 68998)
-- Dependencies: 270 7
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
-- TOC entry 3430 (class 0 OID 0)
-- Dependencies: 269
-- Name: conusu_tipocon_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE conusu_tipocon_id_seq OWNED BY conusu_tipocont.id;


--
-- TOC entry 234 (class 1259 OID 20773)
-- Dependencies: 2417 2418 7
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
-- TOC entry 3431 (class 0 OID 0)
-- Dependencies: 234
-- Name: TABLE ctaconta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE ctaconta IS 'Tabla con el plan de cuentas contables a utilizar.';


--
-- TOC entry 3432 (class 0 OID 0)
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
-- TOC entry 3433 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN ctaconta.descripcion; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN ctaconta.descripcion IS 'Descripcion de la cuenta';


--
-- TOC entry 3434 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN ctaconta.usaraux; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN ctaconta.usaraux IS 'Si la cuenta usara auxiliares. Esto es para el caso de una cuenta que no use auxiliar, esta podra tener movimiento a nivel de sub-especifico';


--
-- TOC entry 3435 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN ctaconta.inactiva; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN ctaconta.inactiva IS 'Si la cuenta esta inactiva o no';


--
-- TOC entry 3436 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN ctaconta.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN ctaconta.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3437 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN ctaconta.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN ctaconta.ip IS 'Direccion IP que genero la transaccion';


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
-- TOC entry 3438 (class 0 OID 0)
-- Dependencies: 278
-- Name: TABLE detalle_interes; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE detalle_interes IS 'Tabla para el registro de los detalles de los intereses';


--
-- TOC entry 3439 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN detalle_interes.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes.id IS 'Identificador del detalle de los intereses';


--
-- TOC entry 3440 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN detalle_interes.intereses; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes.intereses IS 'intereses por mes';


--
-- TOC entry 3441 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN detalle_interes.tasa; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes.tasa IS 'tasa por mes segun el bcv';


--
-- TOC entry 3442 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN detalle_interes.dias; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes.dias IS 'dias de los meses de cada periodo';


--
-- TOC entry 3443 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN detalle_interes.mes; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes.mes IS 'meses de los periodos para el pago de los intereses';


--
-- TOC entry 3444 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN detalle_interes.anio; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes.anio IS 'anio de periodos';


--
-- TOC entry 3445 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN detalle_interes.intereses_id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes.intereses_id IS 'identificador del id de  la tabla de intereses';


--
-- TOC entry 277 (class 1259 OID 77330)
-- Dependencies: 278 7
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
-- TOC entry 3446 (class 0 OID 0)
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
-- TOC entry 3447 (class 0 OID 0)
-- Dependencies: 280
-- Name: TABLE detalle_interes_viejo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE detalle_interes_viejo IS 'Tabla para el registro de los detalles de los intereses';


--
-- TOC entry 3448 (class 0 OID 0)
-- Dependencies: 280
-- Name: COLUMN detalle_interes_viejo.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes_viejo.id IS 'Identificador del detalle de los intereses';


--
-- TOC entry 3449 (class 0 OID 0)
-- Dependencies: 280
-- Name: COLUMN detalle_interes_viejo.intereses; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes_viejo.intereses IS 'intereses por mes';


--
-- TOC entry 3450 (class 0 OID 0)
-- Dependencies: 280
-- Name: COLUMN detalle_interes_viejo.tasa; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes_viejo.tasa IS 'tasa por mes segun el bcv';


--
-- TOC entry 3451 (class 0 OID 0)
-- Dependencies: 280
-- Name: COLUMN detalle_interes_viejo.dias; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes_viejo.dias IS 'dias de los meses de cada periodo';


--
-- TOC entry 3452 (class 0 OID 0)
-- Dependencies: 280
-- Name: COLUMN detalle_interes_viejo.mes; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes_viejo.mes IS 'meses de los periodos para el pago de los intereses';


--
-- TOC entry 3453 (class 0 OID 0)
-- Dependencies: 280
-- Name: COLUMN detalle_interes_viejo.anio; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes_viejo.anio IS 'anio de periodos';


--
-- TOC entry 3454 (class 0 OID 0)
-- Dependencies: 280
-- Name: COLUMN detalle_interes_viejo.intereses_id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes_viejo.intereses_id IS 'identificador del id de  la tabla de intereses';


--
-- TOC entry 279 (class 1259 OID 78839)
-- Dependencies: 280 7
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
-- TOC entry 3455 (class 0 OID 0)
-- Dependencies: 279
-- Name: detalle_interes_id_seq1; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE detalle_interes_id_seq1 OWNED BY detalle_interes_viejo.id;


--
-- TOC entry 235 (class 1259 OID 20778)
-- Dependencies: 2419 7
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
-- TOC entry 3456 (class 0 OID 0)
-- Dependencies: 235
-- Name: TABLE document; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE document IS 'Tabla con los documentos legales utilizados por el sistema';


--
-- TOC entry 3457 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN document.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN document.id IS 'Identificador unico de registro';


--
-- TOC entry 3458 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN document.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN document.nombre IS 'Nombre del documento';


--
-- TOC entry 3459 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN document.docu; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN document.docu IS 'Texto del documento';


--
-- TOC entry 3460 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN document.inactivo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN document.inactivo IS 'Si el documento esta inactivo o activo';


--
-- TOC entry 3461 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN document.usfonproid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN document.usfonproid IS 'Identificador del ususario que creo o el ultimo que modifico el registro';


--
-- TOC entry 3462 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN document.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN document.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 236 (class 1259 OID 20785)
-- Dependencies: 7 235
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
-- TOC entry 3463 (class 0 OID 0)
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
-- TOC entry 3464 (class 0 OID 0)
-- Dependencies: 276
-- Name: interes_bcv_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE interes_bcv_id_seq OWNED BY interes_bcv.id;


--
-- TOC entry 237 (class 1259 OID 20787)
-- Dependencies: 2421 2422 7
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
-- TOC entry 3465 (class 0 OID 0)
-- Dependencies: 237
-- Name: TABLE tmpaccioni; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE tmpaccioni IS 'Tabla con los datos de los Accionistas de los contribuyentes';


--
-- TOC entry 3466 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN tmpaccioni.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.id IS 'Identificador unico del accionista';


--
-- TOC entry 3467 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN tmpaccioni.contribuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.contribuid IS 'Identificador del contribuyente';


--
-- TOC entry 3468 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN tmpaccioni.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.nombre IS 'Nombre del accionista';


--
-- TOC entry 3469 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN tmpaccioni.apellido; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.apellido IS 'Apellidos del accionista';


--
-- TOC entry 3470 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN tmpaccioni.ci; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.ci IS 'Cedula de identidad, numero de pasaporte';


--
-- TOC entry 3471 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN tmpaccioni.domfiscal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.domfiscal IS 'Domicilio fiscal del accionista';


--
-- TOC entry 3472 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN tmpaccioni.nuacciones; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.nuacciones IS 'Numero de acciones';


--
-- TOC entry 3473 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN tmpaccioni.valaccion; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.valaccion IS 'Valor nominal de las acciones';


--
-- TOC entry 3474 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN tmpaccioni.cextra1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.cextra1 IS 'Campo extra 1';


--
-- TOC entry 3475 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN tmpaccioni.cextra2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.cextra2 IS 'Campo extra 2';


--
-- TOC entry 3476 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN tmpaccioni.cextra3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.cextra3 IS 'Campo extra 3';


--
-- TOC entry 3477 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN tmpaccioni.cextra4; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.cextra4 IS 'Campo extra 4';


--
-- TOC entry 3478 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN tmpaccioni.cextra5; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.cextra5 IS 'Campo extra 5';


--
-- TOC entry 3479 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN tmpaccioni.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 238 (class 1259 OID 20795)
-- Dependencies: 2423 2424 2425 2426 7
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
-- TOC entry 3480 (class 0 OID 0)
-- Dependencies: 238
-- Name: TABLE tmpcontri; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE tmpcontri IS 'Tabla con los datos temporales de los contribuyentes de la institución. Esta tabla se utiliza para que los contribuyentes hagan una solicitud de actualizacion de datos';


--
-- TOC entry 3481 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.id IS 'Identificador unico del contribuyente';


--
-- TOC entry 3482 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.tipocontid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.tipocontid IS 'Identificador del tipo de contribuyente';


--
-- TOC entry 3483 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.razonsocia; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.razonsocia IS 'Razon social del contribuyente';


--
-- TOC entry 3484 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.dencomerci; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.dencomerci IS 'Denominacion comercial del contribuyente';


--
-- TOC entry 3485 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.actieconid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.actieconid IS 'Identificador de la actividad economica';


--
-- TOC entry 3486 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.rif; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.rif IS 'Rif del contribuyente';


--
-- TOC entry 3487 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.numregcine; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.numregcine IS 'Numero de registro cinematografico';


--
-- TOC entry 3488 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.domfiscal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.domfiscal IS 'Domicilio fiscal del contribuyente';


--
-- TOC entry 3489 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.estadoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.estadoid IS 'Identicador del estado geografico';


--
-- TOC entry 3490 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.ciudadid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.ciudadid IS 'Identificador de la ciudad';


--
-- TOC entry 3491 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.zonapostal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.zonapostal IS 'Zona postal del contribuyente';


--
-- TOC entry 3492 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.telef1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.telef1 IS 'Telefono 1 del contribuyente';


--
-- TOC entry 3493 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.telef2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.telef2 IS 'Telefono 2 del contribuyente';


--
-- TOC entry 3494 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.telef3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.telef3 IS 'Telefono 3 del contribuyente';


--
-- TOC entry 3495 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.fax1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.fax1 IS 'Fax 1 del contribuyente';


--
-- TOC entry 3496 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.fax2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.fax2 IS 'Fax 2 del contribuyente';


--
-- TOC entry 3497 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.email; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.email IS 'Direccion de email de contribuyente';


--
-- TOC entry 3498 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.pinbb; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.pinbb IS 'Pin de BlackBerry';


--
-- TOC entry 3499 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.skype; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.skype IS 'Dirección de skype';


--
-- TOC entry 3500 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.twitter; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.twitter IS 'Direccion de twitter';


--
-- TOC entry 3501 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.facebook; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.facebook IS 'Direccion de facebook';


--
-- TOC entry 3502 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.nuacciones; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.nuacciones IS 'Numero de acciones del contribuyente segun inforacion del registro mercantil';


--
-- TOC entry 3503 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.valaccion; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.valaccion IS 'Valor nominal por accion segun registro mercantil';


--
-- TOC entry 3504 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.capitalsus; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.capitalsus IS 'Capital suscrito segun registro mercantil';


--
-- TOC entry 3505 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.capitalpag; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.capitalpag IS 'Capital pagado segun registro mercantil';


--
-- TOC entry 3506 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.regmerofc; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.regmerofc IS 'Oficina de registro mercantil en donde se registro la empresa';


--
-- TOC entry 3507 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.rmnumero; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.rmnumero IS 'Numero de registro del documento de registro mercantil';


--
-- TOC entry 3508 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.rmfolio; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.rmfolio IS 'Numero de folio del documento de registro mercantil';


--
-- TOC entry 3509 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.rmtomo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.rmtomo IS 'Numero de folio del documento de registro mercantil';


--
-- TOC entry 3510 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.rmfechapro; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.rmfechapro IS 'Fecha de protocololizacion del registro del documento de registro mercantil';


--
-- TOC entry 3511 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.rmncontrol; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.rmncontrol IS 'Numero de control del documento de registro mercantil';


--
-- TOC entry 3512 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.rmobjeto; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.rmobjeto IS 'Objeto de la empresa segun registro mercantil';


--
-- TOC entry 3513 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.domcomer; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.domcomer IS 'domicilio comercial';


--
-- TOC entry 3514 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.conusuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.conusuid IS 'Identificador del usuario-contribuyente que creo el registro';


--
-- TOC entry 3515 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.tiporeg; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.tiporeg IS 'Tipo de registro creado. 0=Nuevo contribuyente, 1=Edicion de datos de contribuyentes';


--
-- TOC entry 3516 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.cextra1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.cextra1 IS 'Campo extra 1';


--
-- TOC entry 3517 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.cextra2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.cextra2 IS 'Campo extra 2';


--
-- TOC entry 3518 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.cextra3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.cextra3 IS 'Campo extra 3';


--
-- TOC entry 3519 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.cextra4; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.cextra4 IS 'Campo extra 4';


--
-- TOC entry 3520 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN tmpcontri.cextra5; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.cextra5 IS 'Campo extra 5';


--
-- TOC entry 3521 (class 0 OID 0)
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
-- TOC entry 3522 (class 0 OID 0)
-- Dependencies: 239
-- Name: TABLE tmprelegal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE tmprelegal IS 'Tabla con los datos temporales de los representantes legales de los contribuyentes. Esta tabla se utiliza para procesar una solicitud de cambio de datos. El contribuyente copia aqui los nuevos datos';


--
-- TOC entry 3523 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN tmprelegal.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.id IS 'Identificador unico del representante legal';


--
-- TOC entry 3524 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN tmprelegal.contribuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.contribuid IS 'Identificador del contribuyente';


--
-- TOC entry 3525 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN tmprelegal.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.nombre IS 'Nombre del representante legal';


--
-- TOC entry 3526 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN tmprelegal.apellido; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.apellido IS 'Apellidos del representante legal';


--
-- TOC entry 3527 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN tmprelegal.ci; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.ci IS 'Cedula de identidad, numero de pasaporte';


--
-- TOC entry 3528 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN tmprelegal.domfiscal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.domfiscal IS 'Domicilio fiscal del representante legal';


--
-- TOC entry 3529 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN tmprelegal.estadoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.estadoid IS 'Identificador del estado geografico';


--
-- TOC entry 3530 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN tmprelegal.ciudadid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.ciudadid IS 'Identificador de la ciudad';


--
-- TOC entry 3531 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN tmprelegal.zonaposta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.zonaposta IS 'Zona postal';


--
-- TOC entry 3532 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN tmprelegal.telefhab; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.telefhab IS 'Telefono de habitacion del representante legal';


--
-- TOC entry 3533 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN tmprelegal.telefofc; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.telefofc IS 'Telefono de oficina del representante legal';


--
-- TOC entry 3534 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN tmprelegal.fax; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.fax IS 'Fax del representante legal';


--
-- TOC entry 3535 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN tmprelegal.email; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.email IS 'Direccion de email del contribuyente';


--
-- TOC entry 3536 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN tmprelegal.pinbb; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.pinbb IS 'Pin de BlackBerry';


--
-- TOC entry 3537 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN tmprelegal.skype; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.skype IS 'Direccion de skype del representante legal';


--
-- TOC entry 3538 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN tmprelegal.cextra1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.cextra1 IS 'Campo extra 1 ';


--
-- TOC entry 3539 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN tmprelegal.cextra2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.cextra2 IS 'Campo extra 2 ';


--
-- TOC entry 3540 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN tmprelegal.cextra3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.cextra3 IS 'Campo extra 3 ';


--
-- TOC entry 3541 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN tmprelegal.cextra4; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.cextra4 IS 'Campo extra 4 ';


--
-- TOC entry 3542 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN tmprelegal.cextra5; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.cextra5 IS 'Campo extra 5 ';


--
-- TOC entry 3543 (class 0 OID 0)
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
-- Dependencies: 2427 8
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
-- TOC entry 3544 (class 0 OID 0)
-- Dependencies: 240
-- Name: TABLE bitacora; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON TABLE bitacora IS 'Tabla con la bitacora de los datos cambiados de todas las tablas del sistema';


--
-- TOC entry 3545 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN bitacora.id; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON COLUMN bitacora.id IS 'Identificador de la bitacora';


--
-- TOC entry 3546 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN bitacora.fecha; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON COLUMN bitacora.fecha IS 'Fecha/Hora de la transaccion';


--
-- TOC entry 3547 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN bitacora.tabla; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON COLUMN bitacora.tabla IS 'Nombre de tabla sobre la cual se ejecuto la transaccion';


--
-- TOC entry 3548 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN bitacora.idusuario; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON COLUMN bitacora.idusuario IS 'Identificador del usuario que genero la transaccion';


--
-- TOC entry 3549 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN bitacora.accion; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON COLUMN bitacora.accion IS 'Accion ejecutada sobre la tabla. 0.- Insert / 1.- Update / 2.- Delete';


--
-- TOC entry 3550 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN bitacora.datosnew; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON COLUMN bitacora.datosnew IS 'Datos nuevos para el caso de los insert y los Update';


--
-- TOC entry 3551 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN bitacora.datosold; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON COLUMN bitacora.datosold IS 'Datos originales para el caso de los Update';


--
-- TOC entry 3552 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN bitacora.datosdel; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON COLUMN bitacora.datosdel IS 'Datos eliminados para el caso de los Delete';


--
-- TOC entry 3553 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN bitacora.valdelid; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON COLUMN bitacora.valdelid IS 'ID del registro que fue borrado';


--
-- TOC entry 3554 (class 0 OID 0)
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
-- TOC entry 3556 (class 0 OID 0)
-- Dependencies: 241
-- Name: Bitacora_IDBitacora_seq; Type: SEQUENCE OWNED BY; Schema: historial; Owner: postgres
--

ALTER SEQUENCE "Bitacora_IDBitacora_seq" OWNED BY bitacora.id;


SET search_path = pre_aprobacion, pg_catalog;

--
-- TOC entry 274 (class 1259 OID 77269)
-- Dependencies: 2462 11
-- Name: intereses; Type: TABLE; Schema: pre_aprobacion; Owner: postgres; Tablespace: 
--

CREATE TABLE intereses (
    id integer NOT NULL,
    numresolucion character varying,
    numactafiscal character varying,
    felaboracion timestamp without time zone DEFAULT now(),
    fnotificacion date,
    totalpagar numeric NOT NULL,
    declaraid integer,
    ip character varying,
    usuarioid integer,
    fecha_inicio date,
    fecha_fin date
);


ALTER TABLE pre_aprobacion.intereses OWNER TO postgres;

--
-- TOC entry 273 (class 1259 OID 77267)
-- Dependencies: 11 274
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
-- TOC entry 3558 (class 0 OID 0)
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
    usuarioid integer
);


ALTER TABLE pre_aprobacion.multas OWNER TO postgres;

--
-- TOC entry 3559 (class 0 OID 0)
-- Dependencies: 272
-- Name: TABLE multas; Type: COMMENT; Schema: pre_aprobacion; Owner: postgres
--

COMMENT ON TABLE multas IS 'tabla que contiene el calculo de las multas por declaraciones extemporaneas o reparo fiscal';


--
-- TOC entry 271 (class 1259 OID 77246)
-- Dependencies: 272 11
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
-- TOC entry 3560 (class 0 OID 0)
-- Dependencies: 271
-- Name: multas_id_seq; Type: SEQUENCE OWNED BY; Schema: pre_aprobacion; Owner: postgres
--

ALTER SEQUENCE multas_id_seq OWNED BY multas.id;


SET search_path = seg, pg_catalog;

--
-- TOC entry 268 (class 1259 OID 46570)
-- Dependencies: 2455 2456 2457 2458 10
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
-- TOC entry 3561 (class 0 OID 0)
-- Dependencies: 268
-- Name: TABLE tbl_ci_sessions; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON TABLE tbl_ci_sessions IS 'Sesiones manejadas por CodeIgniter';


--
-- TOC entry 242 (class 1259 OID 21562)
-- Dependencies: 2430 10
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
-- TOC entry 3562 (class 0 OID 0)
-- Dependencies: 242
-- Name: TABLE tbl_modulo; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON TABLE tbl_modulo IS 'Módulos del sistema';


--
-- TOC entry 243 (class 1259 OID 21569)
-- Dependencies: 242 10
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
-- TOC entry 3563 (class 0 OID 0)
-- Dependencies: 243
-- Name: tbl_modulo_id_modulo_seq; Type: SEQUENCE OWNED BY; Schema: seg; Owner: postgres
--

ALTER SEQUENCE tbl_modulo_id_modulo_seq OWNED BY tbl_modulo.id_modulo;


--
-- TOC entry 244 (class 1259 OID 21571)
-- Dependencies: 2432 10
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
-- TOC entry 3564 (class 0 OID 0)
-- Dependencies: 244
-- Name: TABLE tbl_permiso; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON TABLE tbl_permiso IS 'Permisos de los roles sobre los módulos';


--
-- TOC entry 245 (class 1259 OID 21575)
-- Dependencies: 244 10
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
-- TOC entry 3565 (class 0 OID 0)
-- Dependencies: 245
-- Name: tbl_permiso_id_permiso_seq; Type: SEQUENCE OWNED BY; Schema: seg; Owner: postgres
--

ALTER SEQUENCE tbl_permiso_id_permiso_seq OWNED BY tbl_permiso.id_permiso;


--
-- TOC entry 282 (class 1259 OID 78878)
-- Dependencies: 2467 10
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
-- TOC entry 3566 (class 0 OID 0)
-- Dependencies: 282
-- Name: TABLE tbl_permiso_trampa; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON TABLE tbl_permiso_trampa IS 'Permisos de los roles sobre los módulos';


--
-- TOC entry 281 (class 1259 OID 78876)
-- Dependencies: 282 10
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
-- TOC entry 3567 (class 0 OID 0)
-- Dependencies: 281
-- Name: tbl_permiso_trampa_id_permiso_seq; Type: SEQUENCE OWNED BY; Schema: seg; Owner: postgres
--

ALTER SEQUENCE tbl_permiso_trampa_id_permiso_seq OWNED BY tbl_permiso_trampa.id_permiso;


--
-- TOC entry 246 (class 1259 OID 21577)
-- Dependencies: 2434 10
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
-- TOC entry 3568 (class 0 OID 0)
-- Dependencies: 246
-- Name: TABLE tbl_rol; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON TABLE tbl_rol IS 'Roles de los usuarios del sistema';


--
-- TOC entry 247 (class 1259 OID 21584)
-- Dependencies: 10 246
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
-- TOC entry 3569 (class 0 OID 0)
-- Dependencies: 247
-- Name: tbl_rol_id_rol_seq; Type: SEQUENCE OWNED BY; Schema: seg; Owner: postgres
--

ALTER SEQUENCE tbl_rol_id_rol_seq OWNED BY tbl_rol.id_rol;


--
-- TOC entry 248 (class 1259 OID 21586)
-- Dependencies: 2436 10
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
-- TOC entry 3570 (class 0 OID 0)
-- Dependencies: 248
-- Name: TABLE tbl_rol_usuario; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON TABLE tbl_rol_usuario IS 'Roles de los usuarios, un usuario puede tener multiples roles dentro del sistema';


--
-- TOC entry 3571 (class 0 OID 0)
-- Dependencies: 248
-- Name: COLUMN tbl_rol_usuario.id_rol_usuario; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON COLUMN tbl_rol_usuario.id_rol_usuario IS 'Identificador del usuario';


--
-- TOC entry 3572 (class 0 OID 0)
-- Dependencies: 248
-- Name: COLUMN tbl_rol_usuario.id_rol; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON COLUMN tbl_rol_usuario.id_rol IS 'Relación con el rol';


--
-- TOC entry 3573 (class 0 OID 0)
-- Dependencies: 248
-- Name: COLUMN tbl_rol_usuario.id_usuario; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON COLUMN tbl_rol_usuario.id_usuario IS 'Relación con el usuario';


--
-- TOC entry 3574 (class 0 OID 0)
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
-- TOC entry 3575 (class 0 OID 0)
-- Dependencies: 249
-- Name: tbl_rol_usuario_id_rol_usuario_seq; Type: SEQUENCE OWNED BY; Schema: seg; Owner: postgres
--

ALTER SEQUENCE tbl_rol_usuario_id_rol_usuario_seq OWNED BY tbl_rol_usuario.id_rol_usuario;


--
-- TOC entry 250 (class 1259 OID 21592)
-- Dependencies: 2437 2438 2439 2440 10
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
-- TOC entry 3576 (class 0 OID 0)
-- Dependencies: 250
-- Name: TABLE tbl_session_ci; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON TABLE tbl_session_ci IS 'Sesiones manejadas por CodeIgniter';


--
-- TOC entry 251 (class 1259 OID 21602)
-- Dependencies: 2442 10
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
-- TOC entry 3577 (class 0 OID 0)
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
-- TOC entry 3578 (class 0 OID 0)
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
-- Dependencies: 2444 9
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
-- TOC entry 3579 (class 0 OID 0)
-- Dependencies: 255
-- Name: TABLE tbl_modulo_contribu; Type: COMMENT; Schema: segContribu; Owner: postgres
--

COMMENT ON TABLE tbl_modulo_contribu IS 'Módulos del sistema';


--
-- TOC entry 259 (class 1259 OID 22866)
-- Dependencies: 9 255
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
-- TOC entry 3580 (class 0 OID 0)
-- Dependencies: 259
-- Name: tbl_modulo_id_modulo_seq; Type: SEQUENCE OWNED BY; Schema: segContribu; Owner: postgres
--

ALTER SEQUENCE tbl_modulo_id_modulo_seq OWNED BY tbl_modulo_contribu.id_modulo;


--
-- TOC entry 256 (class 1259 OID 22851)
-- Dependencies: 2446 9
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
-- TOC entry 3581 (class 0 OID 0)
-- Dependencies: 256
-- Name: TABLE tbl_permiso_contribu; Type: COMMENT; Schema: segContribu; Owner: postgres
--

COMMENT ON TABLE tbl_permiso_contribu IS 'Permisos de los roles sobre los módulos';


--
-- TOC entry 260 (class 1259 OID 22868)
-- Dependencies: 9 256
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
-- TOC entry 3582 (class 0 OID 0)
-- Dependencies: 260
-- Name: tbl_permiso_id_permiso_seq; Type: SEQUENCE OWNED BY; Schema: segContribu; Owner: postgres
--

ALTER SEQUENCE tbl_permiso_id_permiso_seq OWNED BY tbl_permiso_contribu.id_permiso;


--
-- TOC entry 257 (class 1259 OID 22855)
-- Dependencies: 2448 9
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
-- TOC entry 3583 (class 0 OID 0)
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
-- TOC entry 3584 (class 0 OID 0)
-- Dependencies: 261
-- Name: tbl_rol_id_rol_seq; Type: SEQUENCE OWNED BY; Schema: segContribu; Owner: postgres
--

ALTER SEQUENCE tbl_rol_id_rol_seq OWNED BY tbl_rol_contribu.id_rol;


--
-- TOC entry 258 (class 1259 OID 22862)
-- Dependencies: 2450 9
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
-- TOC entry 3585 (class 0 OID 0)
-- Dependencies: 258
-- Name: TABLE tbl_rol_usuario_contribu; Type: COMMENT; Schema: segContribu; Owner: postgres
--

COMMENT ON TABLE tbl_rol_usuario_contribu IS 'Roles de los usuarios, un usuario puede tener multiples roles dentro del sistema';


--
-- TOC entry 3586 (class 0 OID 0)
-- Dependencies: 258
-- Name: COLUMN tbl_rol_usuario_contribu.id_rol_usuario; Type: COMMENT; Schema: segContribu; Owner: postgres
--

COMMENT ON COLUMN tbl_rol_usuario_contribu.id_rol_usuario IS 'Identificador del usuario';


--
-- TOC entry 3587 (class 0 OID 0)
-- Dependencies: 258
-- Name: COLUMN tbl_rol_usuario_contribu.id_rol; Type: COMMENT; Schema: segContribu; Owner: postgres
--

COMMENT ON COLUMN tbl_rol_usuario_contribu.id_rol IS 'Relación con el rol';


--
-- TOC entry 3588 (class 0 OID 0)
-- Dependencies: 258
-- Name: COLUMN tbl_rol_usuario_contribu.id_usuario; Type: COMMENT; Schema: segContribu; Owner: postgres
--

COMMENT ON COLUMN tbl_rol_usuario_contribu.id_usuario IS 'Relación con el usuario';


--
-- TOC entry 3589 (class 0 OID 0)
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
-- TOC entry 3590 (class 0 OID 0)
-- Dependencies: 262
-- Name: tbl_rol_usuario_id_rol_usuario_seq; Type: SEQUENCE OWNED BY; Schema: segContribu; Owner: postgres
--

ALTER SEQUENCE tbl_rol_usuario_id_rol_usuario_seq OWNED BY tbl_rol_usuario_contribu.id_rol_usuario;


--
-- TOC entry 263 (class 1259 OID 22884)
-- Dependencies: 2452 9
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
-- TOC entry 3591 (class 0 OID 0)
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
-- TOC entry 3592 (class 0 OID 0)
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
-- TOC entry 2331 (class 2604 OID 20820)
-- Dependencies: 168 167
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY actiecon ALTER COLUMN id SET DEFAULT nextval('"ActiEcon_IDActiEcon_seq"'::regclass);


--
-- TOC entry 2343 (class 2604 OID 20821)
-- Dependencies: 170 169
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY alicimp ALTER COLUMN id SET DEFAULT nextval('"AlicImp_IDAlicImp_seq"'::regclass);


--
-- TOC entry 2346 (class 2604 OID 20822)
-- Dependencies: 172 171
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asientod ALTER COLUMN id SET DEFAULT nextval('"AsientoD_IDAsientoD_seq"'::regclass);


--
-- TOC entry 2413 (class 2604 OID 20823)
-- Dependencies: 229 228
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asientom ALTER COLUMN id SET DEFAULT nextval('asientom_id_seq'::regclass);


--
-- TOC entry 2415 (class 2604 OID 20824)
-- Dependencies: 231 230
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asientomd ALTER COLUMN id SET DEFAULT nextval('asientomd_id_seq'::regclass);


--
-- TOC entry 2347 (class 2604 OID 20825)
-- Dependencies: 175 174
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY bacuenta ALTER COLUMN id SET DEFAULT nextval('"BaCuenta_IDBaCuenta_seq"'::regclass);


--
-- TOC entry 2348 (class 2604 OID 20826)
-- Dependencies: 177 176
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY bancos ALTER COLUMN id SET DEFAULT nextval('"Bancos_IDBanco_seq"'::regclass);


--
-- TOC entry 2351 (class 2604 OID 20827)
-- Dependencies: 181 180
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY calpago ALTER COLUMN id SET DEFAULT nextval('"CalPagos_IDCalPago_seq"'::regclass);


--
-- TOC entry 2349 (class 2604 OID 20828)
-- Dependencies: 179 178
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY calpagod ALTER COLUMN id SET DEFAULT nextval('"CalPagoD_IDCalPagoD_seq"'::regclass);


--
-- TOC entry 2352 (class 2604 OID 20829)
-- Dependencies: 183 182
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY cargos ALTER COLUMN id SET DEFAULT nextval('"Cargos_IDCargo_seq"'::regclass);


--
-- TOC entry 2353 (class 2604 OID 20830)
-- Dependencies: 185 184
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY ciudades ALTER COLUMN id SET DEFAULT nextval('"Ciudades_IDCiudad_seq"'::regclass);


--
-- TOC entry 2453 (class 2604 OID 46446)
-- Dependencies: 266 267 267
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY con_img_doc ALTER COLUMN id SET DEFAULT nextval('con_img_doc_id_seq'::regclass);


--
-- TOC entry 2370 (class 2604 OID 20831)
-- Dependencies: 195 194
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY contribu ALTER COLUMN id SET DEFAULT nextval('"Contribu_IDContribu_seq"'::regclass);


--
-- TOC entry 2416 (class 2604 OID 20832)
-- Dependencies: 233 232
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY contributi ALTER COLUMN id SET DEFAULT nextval('contributi_id_seq'::regclass);


--
-- TOC entry 2362 (class 2604 OID 20833)
-- Dependencies: 193 192
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusu ALTER COLUMN id SET DEFAULT nextval('"ConUsu_IDConUsu_seq"'::regclass);


--
-- TOC entry 2459 (class 2604 OID 69003)
-- Dependencies: 269 270 270
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusu_tipocont ALTER COLUMN id SET DEFAULT nextval('conusu_tipocon_id_seq'::regclass);


--
-- TOC entry 2354 (class 2604 OID 20834)
-- Dependencies: 187 186
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusuco ALTER COLUMN id SET DEFAULT nextval('"ConUsuCo_IDConUsuCo_seq"'::regclass);


--
-- TOC entry 2358 (class 2604 OID 20835)
-- Dependencies: 189 188
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusuti ALTER COLUMN id SET DEFAULT nextval('"ConUsuTi_IDConUsuTi_seq"'::regclass);


--
-- TOC entry 2360 (class 2604 OID 20836)
-- Dependencies: 191 190
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusuto ALTER COLUMN id SET DEFAULT nextval('"ConUsuTo_IDConUsuTo_seq"'::regclass);


--
-- TOC entry 2379 (class 2604 OID 20837)
-- Dependencies: 197 196
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara ALTER COLUMN id SET DEFAULT nextval('"Declara_IDDeclara_seq"'::regclass);


--
-- TOC entry 2380 (class 2604 OID 20838)
-- Dependencies: 199 198
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY departam ALTER COLUMN id SET DEFAULT nextval('"Departam_IDDepartam_seq"'::regclass);


--
-- TOC entry 2464 (class 2604 OID 77335)
-- Dependencies: 277 278 278
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY detalle_interes ALTER COLUMN id SET DEFAULT nextval('detalle_interes_id_seq'::regclass);


--
-- TOC entry 2465 (class 2604 OID 78844)
-- Dependencies: 279 280 280
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY detalle_interes_viejo ALTER COLUMN id SET DEFAULT nextval('detalle_interes_id_seq1'::regclass);


--
-- TOC entry 2420 (class 2604 OID 20839)
-- Dependencies: 236 235
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY document ALTER COLUMN id SET DEFAULT nextval('document_id_seq'::regclass);


--
-- TOC entry 2384 (class 2604 OID 20840)
-- Dependencies: 203 202
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY entidad ALTER COLUMN id SET DEFAULT nextval('"Entidad_IDEntidad_seq"'::regclass);


--
-- TOC entry 2382 (class 2604 OID 20841)
-- Dependencies: 201 200
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY entidadd ALTER COLUMN id SET DEFAULT nextval('"EntidadD_IDEntidadD_seq"'::regclass);


--
-- TOC entry 2385 (class 2604 OID 20842)
-- Dependencies: 205 204
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY estados ALTER COLUMN id SET DEFAULT nextval('"Estados_IDEstado_seq"'::regclass);


--
-- TOC entry 2463 (class 2604 OID 77293)
-- Dependencies: 276 275
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY interes_bcv ALTER COLUMN id SET DEFAULT nextval('interes_bcv_id_seq'::regclass);


--
-- TOC entry 2388 (class 2604 OID 20843)
-- Dependencies: 209 208
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY perusu ALTER COLUMN id SET DEFAULT nextval('"PerUsu_IDPerUsu_seq"'::regclass);


--
-- TOC entry 2386 (class 2604 OID 20844)
-- Dependencies: 207 206
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY perusud ALTER COLUMN id SET DEFAULT nextval('"PerUsuD_IDPerUsuD_seq"'::regclass);


--
-- TOC entry 2389 (class 2604 OID 20845)
-- Dependencies: 211 210
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY pregsecr ALTER COLUMN id SET DEFAULT nextval('"PregSecr_IDPregSecr_seq"'::regclass);


--
-- TOC entry 2390 (class 2604 OID 20846)
-- Dependencies: 213 212
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY replegal ALTER COLUMN id SET DEFAULT nextval('"RepLegal_IDRepLegal_seq"'::regclass);


--
-- TOC entry 2391 (class 2604 OID 20847)
-- Dependencies: 215 214
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tdeclara ALTER COLUMN id SET DEFAULT nextval('"TDeclara_IDTDeclara_seq"'::regclass);


--
-- TOC entry 2394 (class 2604 OID 20848)
-- Dependencies: 217 216
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tipegrav ALTER COLUMN id SET DEFAULT nextval('"TiPeGrav_IDTiPeGrav_seq"'::regclass);


--
-- TOC entry 2395 (class 2604 OID 20849)
-- Dependencies: 219 218
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tipocont ALTER COLUMN id SET DEFAULT nextval('"TipoCont_IDTipoCont_seq"'::regclass);


--
-- TOC entry 2397 (class 2604 OID 20850)
-- Dependencies: 221 220
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY undtrib ALTER COLUMN id SET DEFAULT nextval('"UndTrib_IDUndTrib_seq"'::regclass);


--
-- TOC entry 2401 (class 2604 OID 20851)
-- Dependencies: 225 224
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY usfonpro ALTER COLUMN id SET DEFAULT nextval('"Usuarios_IDUsuario_seq"'::regclass);


--
-- TOC entry 2399 (class 2604 OID 20852)
-- Dependencies: 223 222
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY usfonpto ALTER COLUMN id SET DEFAULT nextval('"UsFonpTo_IDUsFonpTo_seq"'::regclass);


SET search_path = historial, pg_catalog;

--
-- TOC entry 2428 (class 2604 OID 20853)
-- Dependencies: 241 240
-- Name: id; Type: DEFAULT; Schema: historial; Owner: postgres
--

ALTER TABLE ONLY bitacora ALTER COLUMN id SET DEFAULT nextval('"Bitacora_IDBitacora_seq"'::regclass);


SET search_path = pre_aprobacion, pg_catalog;

--
-- TOC entry 2461 (class 2604 OID 77272)
-- Dependencies: 273 274 274
-- Name: id; Type: DEFAULT; Schema: pre_aprobacion; Owner: postgres
--

ALTER TABLE ONLY intereses ALTER COLUMN id SET DEFAULT nextval('intereses_id_seq'::regclass);


--
-- TOC entry 2460 (class 2604 OID 77251)
-- Dependencies: 272 271 272
-- Name: id; Type: DEFAULT; Schema: pre_aprobacion; Owner: postgres
--

ALTER TABLE ONLY multas ALTER COLUMN id SET DEFAULT nextval('multas_id_seq'::regclass);


SET search_path = seg, pg_catalog;

--
-- TOC entry 2429 (class 2604 OID 21608)
-- Dependencies: 243 242
-- Name: id_modulo; Type: DEFAULT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_modulo ALTER COLUMN id_modulo SET DEFAULT nextval('tbl_modulo_id_modulo_seq'::regclass);


--
-- TOC entry 2431 (class 2604 OID 21609)
-- Dependencies: 245 244
-- Name: id_permiso; Type: DEFAULT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_permiso ALTER COLUMN id_permiso SET DEFAULT nextval('tbl_permiso_id_permiso_seq'::regclass);


--
-- TOC entry 2466 (class 2604 OID 78881)
-- Dependencies: 281 282 282
-- Name: id_permiso; Type: DEFAULT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_permiso_trampa ALTER COLUMN id_permiso SET DEFAULT nextval('tbl_permiso_trampa_id_permiso_seq'::regclass);


--
-- TOC entry 2433 (class 2604 OID 21610)
-- Dependencies: 247 246
-- Name: id_rol; Type: DEFAULT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_rol ALTER COLUMN id_rol SET DEFAULT nextval('tbl_rol_id_rol_seq'::regclass);


--
-- TOC entry 2435 (class 2604 OID 21611)
-- Dependencies: 249 248
-- Name: id_rol_usuario; Type: DEFAULT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_rol_usuario ALTER COLUMN id_rol_usuario SET DEFAULT nextval('tbl_rol_usuario_id_rol_usuario_seq'::regclass);


--
-- TOC entry 2441 (class 2604 OID 21612)
-- Dependencies: 252 251
-- Name: id_usuario_rol; Type: DEFAULT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_usuario_rol ALTER COLUMN id_usuario_rol SET DEFAULT nextval('tbl_usuario_rol_id_usuario_rol_seq'::regclass);


SET search_path = "segContribu", pg_catalog;

--
-- TOC entry 2443 (class 2604 OID 22895)
-- Dependencies: 259 255
-- Name: id_modulo; Type: DEFAULT; Schema: segContribu; Owner: postgres
--

ALTER TABLE ONLY tbl_modulo_contribu ALTER COLUMN id_modulo SET DEFAULT nextval('tbl_modulo_id_modulo_seq'::regclass);


--
-- TOC entry 2445 (class 2604 OID 22896)
-- Dependencies: 260 256
-- Name: id_permiso; Type: DEFAULT; Schema: segContribu; Owner: postgres
--

ALTER TABLE ONLY tbl_permiso_contribu ALTER COLUMN id_permiso SET DEFAULT nextval('tbl_permiso_id_permiso_seq'::regclass);


--
-- TOC entry 2447 (class 2604 OID 22897)
-- Dependencies: 261 257
-- Name: id_rol; Type: DEFAULT; Schema: segContribu; Owner: postgres
--

ALTER TABLE ONLY tbl_rol_contribu ALTER COLUMN id_rol SET DEFAULT nextval('tbl_rol_id_rol_seq'::regclass);


--
-- TOC entry 2449 (class 2604 OID 22898)
-- Dependencies: 262 258
-- Name: id_rol_usuario; Type: DEFAULT; Schema: segContribu; Owner: postgres
--

ALTER TABLE ONLY tbl_rol_usuario_contribu ALTER COLUMN id_rol_usuario SET DEFAULT nextval('tbl_rol_usuario_id_rol_usuario_seq'::regclass);


--
-- TOC entry 2451 (class 2604 OID 22899)
-- Dependencies: 264 263
-- Name: id_usuario_rol; Type: DEFAULT; Schema: segContribu; Owner: postgres
--

ALTER TABLE ONLY tbl_usuario_rol_contribu ALTER COLUMN id_usuario_rol SET DEFAULT nextval('tbl_usuario_rol_id_usuario_rol_seq'::regclass);


SET search_path = datos, pg_catalog;

--
-- TOC entry 3593 (class 0 OID 0)
-- Dependencies: 166
-- Name: Accionis_ID_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Accionis_ID_seq"', 43, true);


--
-- TOC entry 3594 (class 0 OID 0)
-- Dependencies: 168
-- Name: ActiEcon_IDActiEcon_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"ActiEcon_IDActiEcon_seq"', 9, true);


--
-- TOC entry 3595 (class 0 OID 0)
-- Dependencies: 170
-- Name: AlicImp_IDAlicImp_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"AlicImp_IDAlicImp_seq"', 11, true);


--
-- TOC entry 3596 (class 0 OID 0)
-- Dependencies: 172
-- Name: AsientoD_IDAsientoD_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"AsientoD_IDAsientoD_seq"', 6, true);


--
-- TOC entry 3597 (class 0 OID 0)
-- Dependencies: 173
-- Name: Asiento_IDAsiento_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Asiento_IDAsiento_seq"', 2, true);


--
-- TOC entry 3598 (class 0 OID 0)
-- Dependencies: 175
-- Name: BaCuenta_IDBaCuenta_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"BaCuenta_IDBaCuenta_seq"', 1, false);


--
-- TOC entry 3599 (class 0 OID 0)
-- Dependencies: 177
-- Name: Bancos_IDBanco_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Bancos_IDBanco_seq"', 1, false);


--
-- TOC entry 3600 (class 0 OID 0)
-- Dependencies: 179
-- Name: CalPagoD_IDCalPagoD_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"CalPagoD_IDCalPagoD_seq"', 365, true);


--
-- TOC entry 3601 (class 0 OID 0)
-- Dependencies: 181
-- Name: CalPagos_IDCalPago_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"CalPagos_IDCalPago_seq"', 51, true);


--
-- TOC entry 3602 (class 0 OID 0)
-- Dependencies: 183
-- Name: Cargos_IDCargo_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Cargos_IDCargo_seq"', 1, false);


--
-- TOC entry 3603 (class 0 OID 0)
-- Dependencies: 185
-- Name: Ciudades_IDCiudad_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Ciudades_IDCiudad_seq"', 360, true);


--
-- TOC entry 3604 (class 0 OID 0)
-- Dependencies: 187
-- Name: ConUsuCo_IDConUsuCo_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"ConUsuCo_IDConUsuCo_seq"', 1, false);


--
-- TOC entry 3605 (class 0 OID 0)
-- Dependencies: 189
-- Name: ConUsuTi_IDConUsuTi_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"ConUsuTi_IDConUsuTi_seq"', 1, true);


--
-- TOC entry 3606 (class 0 OID 0)
-- Dependencies: 191
-- Name: ConUsuTo_IDConUsuTo_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"ConUsuTo_IDConUsuTo_seq"', 120, true);


--
-- TOC entry 3607 (class 0 OID 0)
-- Dependencies: 193
-- Name: ConUsu_IDConUsu_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"ConUsu_IDConUsu_seq"', 55, true);


--
-- TOC entry 3608 (class 0 OID 0)
-- Dependencies: 195
-- Name: Contribu_IDContribu_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Contribu_IDContribu_seq"', 5, true);


--
-- TOC entry 3609 (class 0 OID 0)
-- Dependencies: 197
-- Name: Declara_IDDeclara_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Declara_IDDeclara_seq"', 78, true);


--
-- TOC entry 3610 (class 0 OID 0)
-- Dependencies: 199
-- Name: Departam_IDDepartam_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Departam_IDDepartam_seq"', 1, false);


--
-- TOC entry 3611 (class 0 OID 0)
-- Dependencies: 201
-- Name: EntidadD_IDEntidadD_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"EntidadD_IDEntidadD_seq"', 1, false);


--
-- TOC entry 3612 (class 0 OID 0)
-- Dependencies: 203
-- Name: Entidad_IDEntidad_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Entidad_IDEntidad_seq"', 1, false);


--
-- TOC entry 3613 (class 0 OID 0)
-- Dependencies: 205
-- Name: Estados_IDEstado_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Estados_IDEstado_seq"', 27, true);


--
-- TOC entry 3614 (class 0 OID 0)
-- Dependencies: 207
-- Name: PerUsuD_IDPerUsuD_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"PerUsuD_IDPerUsuD_seq"', 1, false);


--
-- TOC entry 3615 (class 0 OID 0)
-- Dependencies: 209
-- Name: PerUsu_IDPerUsu_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"PerUsu_IDPerUsu_seq"', 1, false);


--
-- TOC entry 3616 (class 0 OID 0)
-- Dependencies: 211
-- Name: PregSecr_IDPregSecr_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"PregSecr_IDPregSecr_seq"', 7, true);


--
-- TOC entry 3617 (class 0 OID 0)
-- Dependencies: 213
-- Name: RepLegal_IDRepLegal_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"RepLegal_IDRepLegal_seq"', 6, true);


--
-- TOC entry 3618 (class 0 OID 0)
-- Dependencies: 215
-- Name: TDeclara_IDTDeclara_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"TDeclara_IDTDeclara_seq"', 7, true);


--
-- TOC entry 3619 (class 0 OID 0)
-- Dependencies: 217
-- Name: TiPeGrav_IDTiPeGrav_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"TiPeGrav_IDTiPeGrav_seq"', 6, true);


--
-- TOC entry 3620 (class 0 OID 0)
-- Dependencies: 219
-- Name: TipoCont_IDTipoCont_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"TipoCont_IDTipoCont_seq"', 6, true);


--
-- TOC entry 3621 (class 0 OID 0)
-- Dependencies: 221
-- Name: UndTrib_IDUndTrib_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"UndTrib_IDUndTrib_seq"', 4, true);


--
-- TOC entry 3622 (class 0 OID 0)
-- Dependencies: 223
-- Name: UsFonpTo_IDUsFonpTo_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"UsFonpTo_IDUsFonpTo_seq"', 1, false);


--
-- TOC entry 3623 (class 0 OID 0)
-- Dependencies: 225
-- Name: Usuarios_IDUsuario_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Usuarios_IDUsuario_seq"', 48, true);


--
-- TOC entry 2981 (class 0 OID 20731)
-- Dependencies: 226 3035
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
\.


--
-- TOC entry 2922 (class 0 OID 20526)
-- Dependencies: 167 3035
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
-- TOC entry 2924 (class 0 OID 20531)
-- Dependencies: 169 3035
-- Data for Name: alicimp; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY alicimp (id, tipocontid, ano, alicuota, tipocalc, valorut, liminf1, limsup1, alicuota1, liminf2, limsup2, alicuota2, liminf3, limsup3, alicuota3, liminf4, limsup4, alicuota4, liminf5, limsup5, alicuota5, usuarioid, ip) FROM stdin;
2	1	2005	3.00	0	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	17	192.168.1.101
3	1	2006	4.00	0	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	17	192.168.1.101
4	1	2007	5.00	0	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	17	192.168.1.101
5	2	0	0.00	2	0.00	25000.00	40000.00	0.50	40000.00	80000.00	1.00	80000.00	0.00	1.50	0.00	0.00	0.00	0.00	0.00	0.00	17	192.168.1.101
6	3	2006	0.50	0	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	17	192.168.1.101
7	3	2007	1.00	0	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	17	192.168.1.101
8	3	2008	1.50	0	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	17	192.168.1.101
10	5	0	5.00	0	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	17	192.168.1.101
11	6	0	1.00	0	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	17	192.168.1.101
9	4	0	5.00	2	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	0.00	17	192.168.1.101
\.


--
-- TOC entry 2982 (class 0 OID 20740)
-- Dependencies: 227 3035
-- Data for Name: asiento; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY asiento (id, nuasiento, fecha, mes, ano, debe, haber, saldo, comentar, cerrado, uscierreid, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 2926 (class 0 OID 20547)
-- Dependencies: 171 3035
-- Data for Name: asientod; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY asientod (id, asientoid, fecha, cuenta, monto, sentido, referencia, comentar, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 2983 (class 0 OID 20754)
-- Dependencies: 228 3035
-- Data for Name: asientom; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY asientom (id, nombre, comentar, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 3624 (class 0 OID 0)
-- Dependencies: 229
-- Name: asientom_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('asientom_id_seq', 1, false);


--
-- TOC entry 2985 (class 0 OID 20762)
-- Dependencies: 230 3035
-- Data for Name: asientomd; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY asientomd (id, asientomid, cuenta, sentido, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 3625 (class 0 OID 0)
-- Dependencies: 231
-- Name: asientomd_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('asientomd_id_seq', 1, false);


--
-- TOC entry 2929 (class 0 OID 20559)
-- Dependencies: 174 3035
-- Data for Name: bacuenta; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY bacuenta (id, bancoid, cuenta, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 2931 (class 0 OID 20564)
-- Dependencies: 176 3035
-- Data for Name: bancos; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY bancos (id, nombre, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 2935 (class 0 OID 20574)
-- Dependencies: 180 3035
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
-- TOC entry 2933 (class 0 OID 20569)
-- Dependencies: 178 3035
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
246	41	2012-02-14	2013-02-14	2013-02-14	17	192.168.1.102	01
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
\.


--
-- TOC entry 2937 (class 0 OID 20580)
-- Dependencies: 182 3035
-- Data for Name: cargos; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY cargos (id, nombre, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 2939 (class 0 OID 20585)
-- Dependencies: 184 3035
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
-- TOC entry 3019 (class 0 OID 46443)
-- Dependencies: 267 3035
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
-- TOC entry 3626 (class 0 OID 0)
-- Dependencies: 266
-- Name: con_img_doc_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('con_img_doc_id_seq', 105, true);


--
-- TOC entry 2949 (class 0 OID 20621)
-- Dependencies: 194 3035
-- Data for Name: contribu; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY contribu (id, razonsocia, dencomerci, actieconid, rif, numregcine, domfiscal, estadoid, ciudadid, zonapostal, telef1, telef2, telef3, fax1, fax2, email, pinbb, skype, twitter, facebook, nuacciones, valaccion, capitalsus, capitalpag, regmerofc, rmnumero, rmfolio, rmtomo, rmfechapro, rmncontrol, rmobjeto, domcomer, cextra1, cextra2, cextra3, cextra4, cextra5, usuarioid, ip) FROM stdin;
5	CARLENYS CLARET VILLANUEVA PEREZ 	CARLENYS CLARET VILLANUEVA PEREZ C.A	7	V171743270	2550	URBANIZACIóN LA MORA 2, RESIDENCIAS VILLAVICA, CALLE NUMERO 18, CASA NUMERO 33, LA VICTORIA, ESTADO ARAGUA	7	43	2121	0244-3216647	0246-4314229	0414-4666418	0244-3216647		frederickdanielb@hotmail.com	dddddddd	carlenysvS	carlenysvT	www.facebook.com/carlenysv	78	144.00	50000.00	30000.00	el consejo	25689	45	4569	2012-10-04	5666	genericos y otros	URBANIZACIóN LA MORA 2, RESIDENCIAS VILLAVICA, CALLE NUMERO 18, CASA NUMERO 33, LA VICTORIA, ESTADO ARAGUA	\N	\N	\N	\N	\N	52	192.168.1.102
2	JEFFERSON ARTURO LARA MOLINA	PRUEBA	4	V170429792	1	SANTA RITA CALLE JUNIN VEREDAD DOS CASA NUMERO 10 MUNICIPIO FRANCISCO\n LINARES ALCANTARA DEL ñOñO ñOñERO ñUñEZQQQQQQQQQQQQQQQQQQQQQQQ QQQQQQQQQQQQQQQQQQQQ QQQQQQQQQQQQ QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ QQQQQQQQQQQQQQQQQQQQQQ QQQQQQQQQQQa	7	55	0212	0412-0428211					jetox21@gmail.com				www.facebook.com/jefferosn	1000	50.00	10000.00	5000.00	8787	8787	67	7	2012-01-23	8778	PRUEBA	SANTA RITA CALLE JUNIN VEREDAD DOS CASA NUMERO 10 MUNICIPIO FRANCISCO LINARES ALCANTARA DEL ñOñO ñOñERO ñUñEZ QQQQQQQQQ QQQQQQQ QQQQQQQ QQQQQQQQQQQQQQQQQQQQ QQQQQQQQQQQQ QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ QQQQQQQQQQQQQQQQQQQQQQ QQQQQQQQQQQQ	\N	\N	\N	\N	\N	43	192.168.1.101
4	JEDLYS, C.A.	JEDLYS	4	V178292737	1111	BOCONÓ-TRUJILLO	23	304	3101	0416-1319739	0416-0799712				spvsr8@gmail.com					1	1000.00	10000.00	5000.00	LCT	8	4	2	2013-01-25	2	COMERCIAL	VALERA-TRUJILLO	\N	\N	\N	\N	\N	46	192.168.1.103
3	FREDERICK DANIEL BUSTAMANTE GONZALEZ	FREDERICK CA	4	V153938594	562	LA VICTORIA ESTADO ARAGUA	14	151	2121	0244-3216647	0246-4314229	0414-2680489	0244-8889999		frederickdanielb@gmail.com	android	frederickS	frederickT	frederickF	1000	2034564.00	65888.00	8.00	el centro	54	88	99	2012-06-04	8	personal		\N	\N	\N	\N	\N	45	192.168.1.102
\.


--
-- TOC entry 2987 (class 0 OID 20768)
-- Dependencies: 232 3035
-- Data for Name: contributi; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY contributi (id, contribuid, tipocontid, ip) FROM stdin;
\.


--
-- TOC entry 3627 (class 0 OID 0)
-- Dependencies: 233
-- Name: contributi_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('contributi_id_seq', 1, false);


--
-- TOC entry 2947 (class 0 OID 20612)
-- Dependencies: 192 3035
-- Data for Name: conusu; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY conusu (id, login, password, nombre, inactivo, conusutiid, email, pregsecrid, respuesta, ultlogin, usuarioid, ip, rif, validado, fecha_registro) FROM stdin;
46	spvsr8@gmail.com	7c4a8d09ca3762af61e59520943dc26494f8941b	SILVIA PATRICIA VALLADARES SANDOVAL	f	1	spvsr8@gmail.com	2	yo	2013-01-25 15:59:42.119081	\N	192.168.1.101	V178292737	t	2013-03-14
48	gdfgdfg	7c4a8d09ca3762af61e59520943dc26494f8941b	CARLENYS CLARET VILLANUEVA PEREZ	t	1	dfgdfgdfg	1	tequila	2013-02-01 16:20:40.938163	\N	192.168.1.102	gdfgdfg	f	2013-03-14
50	dfgdfgdfgdfg	7c4a8d09ca3762af61e59520943dc26494f8941b	CARLENYS CLARET VILLANUEVA PEREZ	t	1	ertfdghj	1	tequila	2013-02-01 16:25:28.043609	\N	192.168.1.102	ertert	f	2013-03-14
51	vbnvbn	7c4a8d09ca3762af61e59520943dc26494f8941b	CARLENYS CLARET VILLANUEVA PEREZ	t	1	vbnvbnvbn	1	tequila	2013-02-01 16:29:20.602782	\N	192.168.1.102	ghjghjtyu	f	2013-03-14
53	ghjghjghj	7c4a8d09ca3762af61e59520943dc26494f8941b	ghjghjghj	t	1	hgfjghj	4	dfgdfgdf	\N	\N	192.168.1.102	dfgdfgdfgd	f	2013-03-14
45	frederickdanielb@gmail.com	b24a6007b26e04bf8f4b1a914b1a322f91ddd9df	FREDERICK DANIEL BUSTAMANTE GONZALEZ	f	1	frederickdanielb@gmail.com	2	yopo	2013-01-22 16:04:17.96858	\N	192.168.1.102	V153938594	t	2008-03-14
18	hj	v170429792	JEFFERSON ARTURO LARA MOLINA	t	1	ghghgh	1	fgfgfgffg	2013-01-18 17:25:51.303327	\N	192.168.1.102	m	f	2013-03-14
19	fffghfgh	v170429792	JEFFERSON ARTURO LARA MOLINA	t	1	fghghgh	1	fgfgfgffg	2013-01-18 17:27:01.458254	\N	192.168.1.102	k	f	2013-03-14
43	jetox21@gmail.com	7c4a8d09ca3762af61e59520943dc26494f8941b	JEFFERSON ARTURO LARA MOLINA	f	1	jetox21@gmail.com	1	que tal	2013-01-21 16:56:41.000428	\N	192.168.1.101	V170429792	t	2006-05-14
20	ff	v170429792	JEFFERSON ARTURO LARA MOLINA	t	1	fghfghfgh	1	fgfgfgffg	2013-01-18 17:34:28.045315	\N	192.168.1.102	lo	f	2013-03-14
2	fdg	123456	ROSA MELTROSO	t	1	dfg	2	MI MAMA ME MIMA MUCHO	\N	16	192.168.1.102	q	f	2013-03-14
17	dfdg	v170429792	JEFFERSON ARTURO LARA MOLINA	t	1	ghghghgh	1	fgfgfgffg	2013-01-18 17:20:05.92077	\N	192.168.1.102	n	f	2013-03-14
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
52	xcvxcvxcv	7c4a8d09ca3762af61e59520943dc26494f8941b	CARLENYS CLARET VILLANUEVA PEREZ	t	1	xcvxcvxcv	2	tequila	2013-02-01 16:39:59.897766	\N	192.168.1.102	xcvxcvxcv	t	2013-03-14
54	frederickdanielb@yahoo.es	7c4a8d09ca3762af61e59520943dc26494f8941b	WENDY YANITZA GUERRA PEREZ	f	1	frederickdanielb@yahoo.es	4	hola	2013-03-11 11:52:05.042428	\N	192.168.1.102	V151001005	f	2010-03-14
55	frederickdanielb@hotmail.com	7c4a8d09ca3762af61e59520943dc26494f8941b	CARLENYS CLARET VILLANUEVA PEREZ	f	1	frederickdanielb@hotmail.com	5	hol	2013-03-11 11:54:38.959854	\N	192.168.1.102	V171743270	f	2006-03-14
44	arturo.laos@gmail.com	7c4a8d09ca3762af61e59520943dc26494f8941b	ARTURO MARIO LAOS MELGAR	f	1	arturo.laos@gmail.com	2	arturo	2013-01-22 10:02:31.854064	\N	192.168.1.106	E816204707	t	2007-03-14
47	arturo.laos@yahoo.com	1234567c4a8d09ca3762af61e59520943dc26494f8941b	LAOS COMPUTER TECHNOLOGY, C.A. (LAOS COMPUTER TECHNOLOGY, C.A.)	f	1	arturo.laos@yahoo.com	1	quien	2013-01-25 16:17:53.554135	\N	192.168.1.106	J314725645	t	2011-03-14
\.


--
-- TOC entry 3628 (class 0 OID 0)
-- Dependencies: 269
-- Name: conusu_tipocon_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('conusu_tipocon_id_seq', 15, true);


--
-- TOC entry 3022 (class 0 OID 69000)
-- Dependencies: 270 3035
-- Data for Name: conusu_tipocont; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY conusu_tipocont (id, conusuid, tipocontid, ip) FROM stdin;
9	46	6	192.168.1.102
8	46	5	192.168.1.102
5	44	1	192.168.1.102
10	47	1	192.168.1.102
11	47	5	192.168.1.102
12	54	3	192.168.1.102
13	54	6	192.168.1.102
15	55	2	192.168.1.102
14	44	4	192.168.1.102
2	46	1	192.168.1.102
7	43	1	192.168.1.102
6	45	2	192.168.1.102
4	43	4	192.168.1.102
\.


--
-- TOC entry 2941 (class 0 OID 20590)
-- Dependencies: 186 3035
-- Data for Name: conusuco; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY conusuco (id, conusuid, contribuid) FROM stdin;
\.


--
-- TOC entry 2943 (class 0 OID 20595)
-- Dependencies: 188 3035
-- Data for Name: conusuti; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY conusuti (id, nombre, administra, liquida, visualiza, usuarioid, ip) FROM stdin;
1	ADMINISTRADOR	t	t	f	16	192.168.1.102
\.


--
-- TOC entry 2945 (class 0 OID 20603)
-- Dependencies: 190 3035
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
\.


--
-- TOC entry 2989 (class 0 OID 20773)
-- Dependencies: 234 3035
-- Data for Name: ctaconta; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY ctaconta (cuenta, descripcion, usaraux, inactiva, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 2951 (class 0 OID 20633)
-- Dependencies: 196 3035
-- Data for Name: declara; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY declara (id, nudeclara, nudeposito, tdeclaraid, fechaelab, fechaini, fechafin, replegalid, baseimpo, alicuota, exonera, nuactoexon, credfiscal, contribant, plasustid, nuresactfi, fechanoti, intemora, reparofis, multa, montopagar, fechapago, fechaconci, asientoid, usuarioid, ip, tipocontribuid, conusuid, calpagodid) FROM stdin;
75	V17042979212040700000277753	V1704297921204070000027775	2	2013-03-19 14:24:00.901994	2007-05-01	2007-05-23	4	5555.00	5.00	0.00	\N	0.00	\N	\N	\N	\N	0.00	0.00	0.00	277.75	\N	\N	\N	17	192.168.1.101	1	43	87
76	V17042979212021300002777753	V1704297921202130000277775	2	2013-03-19 14:27:52.53529	2013-03-01	2013-03-22	4	55555.00	5.00	0.00	\N	0.00	\N	\N	\N	\N	0.00	0.00	0.00	2777.75	\N	\N	\N	17	192.168.1.101	1	43	339
78	V17042979222011201500000003	V1704297922201120150000000	2	2013-03-25 09:48:13.30394	2013-02-01	2010-02-17	4	100000000.00	1.50	0.00	\N	0.00	\N	\N	\N	\N	0.00	0.00	0.00	1500000.00	\N	\N	\N	17	192.168.1.101	2	43	246
77	V17042979212121200005000003	V1704297921212120000500000	2	2013-03-19 14:39:51.803309	2010-01-01	2010-01-17	4	100000.00	5.00	0.00	\N	0.00	\N	\N	\N	\N	0.00	0.00	0.00	5000.00	\N	\N	\N	17	192.168.1.101	1	45	240
74	V17042979212021200000500006	V1704297921202120000050000	2	2013-03-19 11:49:07.888497	2012-03-01	2012-03-22	4	10000.00	5.00	0.00	\N	0.00	\N	\N	\N	\N	0.00	0.00	0.00	500.00	2012-03-28	\N	\N	17	192.168.1.101	1	43	10
73	V17042979212011300002500006	V1704297921201130000250000	2	2013-03-19 11:32:11.279555	2013-02-01	2013-02-25	4	50000.00	5.00	0.00	\N	0.00	\N	\N	\N	\N	0.00	0.00	0.00	2500.00	2013-02-15	\N	\N	17	192.168.1.101	1	43	338
\.


--
-- TOC entry 2953 (class 0 OID 20647)
-- Dependencies: 198 3035
-- Data for Name: departam; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY departam (id, nombre, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 3030 (class 0 OID 77332)
-- Dependencies: 278 3035
-- Data for Name: detalle_interes; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY detalle_interes (id, intereses, tasa, dias, mes, anio, intereses_id, ip, usuarioid) FROM stdin;
2	0.000000	0.000000	1	04	2005	89	\N	\N
3	0.000000	0.000000	31	05	2005	89	\N	\N
4	0.000000	0.000000	30	06	2005	89	\N	\N
5	0.000000	0.000000	31	07	2005	89	\N	\N
6	0.000000	0.000000	31	08	2005	89	\N	\N
7	0.000000	0.000000	30	09	2005	89	\N	\N
8	0.000000	0.000000	31	10	2005	89	\N	\N
9	0.000000	0.000000	30	11	2005	89	\N	\N
10	15314.000000	0.049400	31	12	2005	89	\N	\N
11	16388.666667	0.052867	31	01	2006	89	\N	\N
12	14728.000000	0.052600	28	02	2006	89	\N	\N
13	15841.000000	0.051100	31	03	2006	89	\N	\N
14	14930.000000	0.049767	30	04	2006	89	\N	\N
15	15283.000000	0.049300	31	05	2006	89	\N	\N
16	14430.000000	0.048100	30	06	2006	89	\N	\N
17	15541.333333	0.050133	31	07	2006	89	\N	\N
18	16120.000000	0.052000	31	08	2006	89	\N	\N
19	15200.000000	0.050667	30	09	2006	89	\N	\N
20	16440.333333	0.053033	31	10	2006	89	\N	\N
21	15950.000000	0.053167	30	11	2006	89	\N	\N
22	16595.333333	0.053533	31	12	2006	89	\N	\N
23	17432.333333	0.056233	31	01	2007	89	\N	\N
24	15101.333333	0.053933	28	02	2007	89	\N	\N
25	15872.000000	0.051200	31	03	2007	89	\N	\N
26	16540.000000	0.055133	30	04	2007	89	\N	\N
27	17432.333333	0.056233	31	05	2007	89	\N	\N
28	16100.000000	0.053667	30	06	2007	89	\N	\N
29	17587.333333	0.056733	31	07	2007	89	\N	\N
30	18197.000000	0.058700	31	08	2007	89	\N	\N
31	17920.000000	0.059733	30	09	2007	89	\N	\N
32	18651.666667	0.060167	31	10	2007	89	\N	\N
33	20950.000000	0.069833	30	11	2007	89	\N	\N
34	23849.333333	0.076933	31	12	2007	89	\N	\N
35	26794.333333	0.086433	31	01	2008	89	\N	\N
36	23847.666667	0.082233	29	02	2008	89	\N	\N
37	24831.000000	0.080100	31	03	2008	89	\N	\N
38	24470.000000	0.081567	30	04	2008	89	\N	\N
39	26835.666667	0.086567	31	05	2008	89	\N	\N
40	24780.000000	0.082600	30	06	2008	89	\N	\N
41	26701.333333	0.086133	31	07	2008	89	\N	\N
42	25926.333333	0.083633	31	08	2008	89	\N	\N
43	24720.000000	0.082400	30	09	2008	89	\N	\N
44	25254.666667	0.081467	31	10	2008	89	\N	\N
45	24880.000000	0.082933	30	11	2008	89	\N	\N
46	24097.333333	0.077733	31	12	2008	89	\N	\N
47	27290.333333	0.088033	31	01	2009	89	\N	\N
48	25097.333333	0.089633	28	02	2009	89	\N	\N
49	26732.333333	0.086233	31	03	2009	89	\N	\N
50	24650.000000	0.082167	30	04	2009	89	\N	\N
51	24841.333333	0.080133	31	05	2009	89	\N	\N
52	22420.000000	0.074733	30	06	2009	89	\N	\N
53	23043.333333	0.074333	31	07	2009	89	\N	\N
54	23053.666667	0.074367	31	08	2009	89	\N	\N
55	20870.000000	0.069567	30	09	2009	89	\N	\N
56	22692.000000	0.073200	31	10	2009	89	\N	\N
57	10810.000000	0.072067	15	11	2009	89	\N	\N
58	7465.333333	0.067867	11	05	2010	90	\N	\N
59	20420.000000	0.068067	30	06	2010	90	\N	\N
60	20976.666667	0.067667	31	07	2010	90	\N	\N
61	20677.000000	0.066700	31	08	2010	90	\N	\N
62	21020.000000	0.070067	30	09	2010	90	\N	\N
63	5221.333333	0.065267	8	10	2010	90	\N	\N
64	0.000000	0.000000	11	05	2012	91	\N	\N
65	0.000000	0.000000	30	06	2012	91	\N	\N
66	0.000000	0.000000	31	07	2012	91	\N	\N
67	0.000000	0.000000	31	08	2012	91	\N	\N
68	0.000000	0.000000	30	09	2012	91	\N	\N
69	0.000000	0.000000	8	10	2012	91	\N	\N
\.


--
-- TOC entry 3629 (class 0 OID 0)
-- Dependencies: 277
-- Name: detalle_interes_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('detalle_interes_id_seq', 69, true);


--
-- TOC entry 3630 (class 0 OID 0)
-- Dependencies: 279
-- Name: detalle_interes_id_seq1; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('detalle_interes_id_seq1', 125, true);


--
-- TOC entry 3032 (class 0 OID 78841)
-- Dependencies: 280 3035
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
-- TOC entry 2990 (class 0 OID 20778)
-- Dependencies: 235 3035
-- Data for Name: document; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY document (id, nombre, docu, inactivo, usfonproid, ip) FROM stdin;
\.


--
-- TOC entry 3631 (class 0 OID 0)
-- Dependencies: 236
-- Name: document_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('document_id_seq', 1, false);


--
-- TOC entry 2957 (class 0 OID 20658)
-- Dependencies: 202 3035
-- Data for Name: entidad; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY entidad (id, nombre, entidad, orden) FROM stdin;
\.


--
-- TOC entry 2955 (class 0 OID 20652)
-- Dependencies: 200 3035
-- Data for Name: entidadd; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY entidadd (id, entidadid, nombre, accion, orden) FROM stdin;
\.


--
-- TOC entry 2959 (class 0 OID 20664)
-- Dependencies: 204 3035
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
-- TOC entry 3027 (class 0 OID 77288)
-- Dependencies: 275 3035
-- Data for Name: interes_bcv; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY interes_bcv (id, anio, tasa, ip, usuarioid, mes) FROM stdin;
1	2005	14.82	192.168.1.103	17	12
11	2006	15.91	192.168.1.103	17	10
12	2006	15.95	192.168.1.103	17	11
13	2006	16.06	192.168.1.103	17	12
23	2007	18.05	192.168.1.103	17	10
24	2007	20.95	192.168.1.103	17	11
25	2007	23.08	192.168.1.103	17	12
35	2008	24.44	192.168.1.103	17	10
36	2008	24.88	192.168.1.103	17	11
37	2008	23.32	192.168.1.103	17	12
47	2009	21.96	192.168.1.103	17	10
48	2009	21.62	192.168.1.103	17	11
49	2009	21.73	192.168.1.103	17	12
59	2010	19.58	192.168.1.103	17	10
60	2010	20.04	192.168.1.103	17	11
61	2010	20.04	192.168.1.103	17	12
71	2011	20.24	192.168.1.103	17	10
72	2011	18.59	192.168.1.103	17	11
73	2011	17.90	192.168.1.103	17	12
83	2012	0.00	192.168.1.103	17	10
84	2012	0.00	192.168.1.103	17	11
85	2012	0.00	192.168.1.103	17	12
2	2006	15.86	192.168.1.103	17	01
14	2007	16.87	192.168.1.103	17	01
26	2008	25.93	192.168.1.103	17	01
38	2009	26.41	192.168.1.103	17	01
50	2010	21.20	192.168.1.103	17	01
62	2011	19.83	192.168.1.103	17	01
74	2012	18.66	192.168.1.103	17	01
3	2006	15.78	192.168.1.103	17	02
15	2007	16.18	192.168.1.103	17	02
27	2008	24.67	192.168.1.103	17	02
39	2009	26.89	192.168.1.103	17	02
51	2010	22.30	192.168.1.103	17	02
63	2011	19.90	192.168.1.103	17	02
75	2012	18.44	192.168.1.103	17	02
4	2006	15.33	192.168.1.103	17	03
16	2007	15.36	192.168.1.103	17	03
28	2008	24.03	192.168.1.103	17	03
40	2009	25.87	192.168.1.103	17	03
52	2010	20.90	192.168.1.103	17	03
64	2011	19.88	192.168.1.103	17	03
76	2012	17.07	192.168.1.103	17	03
5	2006	14.93	192.168.1.103	17	04
17	2007	16.54	192.168.1.103	17	04
29	2008	24.47	192.168.1.103	17	04
41	2009	24.65	192.168.1.103	17	04
53	2010	21.19	192.168.1.103	17	04
65	2011	20.02	192.168.1.103	17	04
77	2012	0.00	192.168.1.103	17	04
6	2006	14.79	192.168.1.103	17	05
18	2007	16.87	192.168.1.103	17	05
30	2008	25.97	192.168.1.103	17	05
42	2009	24.04	192.168.1.103	17	05
54	2010	20.36	192.168.1.103	17	05
66	2011	20.77	192.168.1.103	17	05
78	2012	0.00	192.168.1.103	17	05
7	2006	14.43	192.168.1.103	17	06
19	2007	16.10	192.168.1.103	17	06
31	2008	24.78	192.168.1.103	17	06
43	2009	22.42	192.168.1.103	17	06
55	2010	20.42	192.168.1.103	17	06
67	2011	19.91	192.168.1.103	17	06
79	2012	0.00	192.168.1.103	17	06
8	2006	15.04	192.168.1.103	17	07
20	2007	17.02	192.168.1.103	17	07
32	2008	25.84	192.168.1.103	17	07
44	2009	22.30	192.168.1.103	17	07
56	2010	20.30	192.168.1.103	17	07
68	2011	20.41	192.168.1.103	17	07
80	2012	0.00	192.168.1.103	17	07
9	2006	15.60	192.168.1.103	17	08
21	2007	17.61	192.168.1.103	17	08
33	2008	25.09	192.168.1.103	17	08
45	2009	22.31	192.168.1.103	17	08
57	2010	20.01	192.168.1.103	17	08
69	2011	19.14	192.168.1.103	17	08
81	2012	0.00	192.168.1.103	17	08
10	2006	15.20	192.168.1.103	17	09
22	2007	17.92	192.168.1.103	17	09
34	2008	24.72	192.168.1.103	17	09
46	2009	20.87	192.168.1.103	17	09
58	2010	21.02	192.168.1.103	17	09
70	2011	19.68	192.168.1.103	17	09
82	2012	0.00	192.168.1.103	17	09
\.


--
-- TOC entry 3632 (class 0 OID 0)
-- Dependencies: 276
-- Name: interes_bcv_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('interes_bcv_id_seq', 85, true);


--
-- TOC entry 2963 (class 0 OID 20674)
-- Dependencies: 208 3035
-- Data for Name: perusu; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY perusu (id, nombre, inactivo, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 2961 (class 0 OID 20669)
-- Dependencies: 206 3035
-- Data for Name: perusud; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY perusud (id, perusuid, entidaddid, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 2965 (class 0 OID 20680)
-- Dependencies: 210 3035
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
-- TOC entry 2967 (class 0 OID 20685)
-- Dependencies: 212 3035
-- Data for Name: replegal; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY replegal (id, contribuid, nombre, apellido, ci, domfiscal, estadoid, ciudadid, zonaposta, telefhab, telefofc, fax, email, pinbb, skype, cextra1, cextra2, cextra3, cextra4, cextra5, usuarioid, ip) FROM stdin;
4	2	jefferosn arturo	lara	17042979	dsfsfdsas	7	48	0201	0243-2158532	0412-0428211	0243-2158532	jetox21@gmail.com			\N	\N	\N	\N	\N	17	192.168.1.101
5	2	hjgjhgjh	kjhhkj	123456987	hggfjhghjgjhgjhg	3	1	0231	0243-1111111	0244-1111111	0243-1111111	hgjhgj#@jhgkjh.com	ddd544	dfgdg	\N	\N	\N	\N	\N	17	192.168.1.101
6	2	dfsdfsdf	fdgfdgdf	9878523	fdgfdgfdgfdgfd	3	1	0421	0244-2222222	0244-5555555	0244-8888888	adfdasfd@kjkls.com	454df	dfasdas	\N	\N	\N	\N	\N	17	192.168.1.101
\.


--
-- TOC entry 2969 (class 0 OID 20693)
-- Dependencies: 214 3035
-- Data for Name: tdeclara; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY tdeclara (id, nombre, tipo, usuarioid, ip) FROM stdin;
2	AUTOLIQUIDACION	0	17	192.168.1.101
3	SUSTITUTIVA	0	17	192.168.1.102
4	MULTA POR PAGO EXTEMPORANEO	1	17	192.168.1.101
7	INTERESES MORATORIOS	3	17	192.168.1.101
5	MULTA POR REPARO FISCAL	1	17	192.168.1.101
\.


--
-- TOC entry 2971 (class 0 OID 20698)
-- Dependencies: 216 3035
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
-- TOC entry 2973 (class 0 OID 20705)
-- Dependencies: 218 3035
-- Data for Name: tipocont; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY tipocont (id, nombre, tipegravid, usuarioid, ip) FROM stdin;
1	EXHIBIDORES	1	16	192.168.1.102
2	TV SEÑAL ABIERTA	3	17	192.168.1.101
3	TV SUSCRIPCION	5	17	192.168.1.101
4	DISTRIBUIDORES	4	17	192.168.1.101
5	VENTA Y ALQUILER	2	17	192.168.1.101
6	SERVICIOS PARA LA PRODUCCION	6	17	192.168.1.101
\.


--
-- TOC entry 2992 (class 0 OID 20787)
-- Dependencies: 237 3035
-- Data for Name: tmpaccioni; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY tmpaccioni (id, contribuid, nombre, apellido, ci, domfiscal, nuacciones, valaccion, cextra1, cextra2, cextra3, cextra4, cextra5, ip) FROM stdin;
\.


--
-- TOC entry 2993 (class 0 OID 20795)
-- Dependencies: 238 3035
-- Data for Name: tmpcontri; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY tmpcontri (id, tipocontid, razonsocia, dencomerci, actieconid, rif, numregcine, domfiscal, estadoid, ciudadid, zonapostal, telef1, telef2, telef3, fax1, fax2, email, pinbb, skype, twitter, facebook, nuacciones, valaccion, capitalsus, capitalpag, regmerofc, rmnumero, rmfolio, rmtomo, rmfechapro, rmncontrol, rmobjeto, domcomer, conusuid, tiporeg, cextra1, cextra2, cextra3, cextra4, cextra5, ip) FROM stdin;
\.


--
-- TOC entry 2994 (class 0 OID 20805)
-- Dependencies: 239 3035
-- Data for Name: tmprelegal; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY tmprelegal (id, contribuid, nombre, apellido, ci, domfiscal, estadoid, ciudadid, zonaposta, telefhab, telefofc, fax, email, pinbb, skype, cextra1, cextra2, cextra3, cextra4, cextra5, ip) FROM stdin;
\.


--
-- TOC entry 2975 (class 0 OID 20710)
-- Dependencies: 220 3035
-- Data for Name: undtrib; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY undtrib (id, fecha, valor, usuarioid, ip) FROM stdin;
2	2013-02-06	107.07	17	192.168.1.102
3	2012-02-06	98.50	17	192.168.1.102
4	2009-02-06	75.45	17	192.168.1.102
\.


--
-- TOC entry 2979 (class 0 OID 20725)
-- Dependencies: 224 3035
-- Data for Name: usfonpro; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY usfonpro (id, login, password, nombre, email, telefofc, extension, departamid, cargoid, inactivo, pregsecrid, respuesta, perusuid, ultlogin, usuarioid, ip, cedula) FROM stdin;
16	fbustamante	7c4a8d09ca3762af61e59520943dc26494f8941b	frederick	frederickdanielb@gmail.com	04142680489	\N	\N	\N	f	1	hola	\N	\N	1	192.168.1.101	15100387
17	svalladares	7c4a8d09ca3762af61e59520943dc26494f8941b	Silvia Patricia Valladares Sandoval	spvsr8@gmail.com	04160799712	\N	\N	\N	f	1	hola	\N	\N	1	192.168.1.101	17829273
47	cnac	3145f2cd4ff92c1d9a538f215d8ab61132039016	CNAC	cnac@gmail.com	0212-5342123	\N	\N	\N	f	2	Prueba	\N	\N	\N	192.168.1.103	111111
18	alaos	7c4a8d09ca3762af61e59520943dc26494f8941b	Arturo Laos	arturo.laos@gmail.com	02125760355	\N	\N	\N	f	2	Director LCT	\N	\N	1	192.168.1.103	11111111
48	jelara	7c4a8d09ca3762af61e59520943dc26494f8941b	Jefferson Arturo Lara Molina	jetox21@gmail.com	0412-0428211	\N	\N	\N	f	4	molina	\N	\N	\N	192.168.1.102	17042979
\.


--
-- TOC entry 2977 (class 0 OID 20716)
-- Dependencies: 222 3035
-- Data for Name: usfonpto; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY usfonpto (id, token, usfonproid, fechacrea, fechacadu, usado) FROM stdin;
\.


SET search_path = historial, pg_catalog;

--
-- TOC entry 3633 (class 0 OID 0)
-- Dependencies: 241
-- Name: Bitacora_IDBitacora_seq; Type: SEQUENCE SET; Schema: historial; Owner: postgres
--

SELECT pg_catalog.setval('"Bitacora_IDBitacora_seq"', 34, true);


--
-- TOC entry 2995 (class 0 OID 20811)
-- Dependencies: 240 3035
-- Data for Name: bitacora; Type: TABLE DATA; Schema: historial; Owner: postgres
--

COPY bitacora (id, fecha, tabla, idusuario, accion, datosnew, datosold, datosdel, valdelid, ip) FROM stdin;
\.


SET search_path = pre_aprobacion, pg_catalog;

--
-- TOC entry 3026 (class 0 OID 77269)
-- Dependencies: 274 3035
-- Data for Name: intereses; Type: TABLE DATA; Schema: pre_aprobacion; Owner: postgres
--

COPY intereses (id, numresolucion, numactafiscal, felaboracion, fnotificacion, totalpagar, declaraid, ip, usuarioid, fecha_inicio, fecha_fin) FROM stdin;
71	001A	\N	2013-03-27 10:31:04.146005	\N	973033.66666666	\N	\N	\N	2005-04-29	2009-11-15
72	001A	\N	2013-03-27 10:31:04.146005	\N	95780.333333333	\N	\N	\N	2010-05-20	2010-10-08
73	001A	\N	2013-03-27 10:31:04.146005	\N	0	\N	\N	\N	2012-05-20	2012-10-08
83	001A	\N	2013-03-27 11:16:37.920774	\N	973033.66666666	\N	\N	\N	2005-04-29	2009-11-15
84	001A	\N	2013-03-27 11:16:37.920774	\N	95780.333333333	\N	\N	\N	2010-05-20	2010-10-08
85	001A	\N	2013-03-27 11:16:37.920774	\N	0	\N	\N	\N	2012-05-20	2012-10-08
86	001A	\N	2013-03-27 11:22:33.457512	\N	973033.66666667	\N	\N	\N	2005-04-29	2009-11-15
87	001A	\N	2013-03-27 11:22:33.457512	\N	95780.333333333	\N	\N	\N	2010-05-20	2010-10-08
88	001A	\N	2013-03-27 11:22:33.457512	\N	0	\N	\N	\N	2012-05-20	2012-10-08
89	001A	\N	2013-03-27 11:25:44.988595	\N	973033.66666667	\N	\N	\N	2005-04-29	2009-11-15
90	001A	\N	2013-03-27 11:25:44.988595	\N	95780.333333333	\N	\N	\N	2010-05-20	2010-10-08
91	001A	\N	2013-03-27 11:25:44.988595	\N	0	\N	\N	\N	2012-05-20	2012-10-08
\.


--
-- TOC entry 3634 (class 0 OID 0)
-- Dependencies: 273
-- Name: intereses_id_seq; Type: SEQUENCE SET; Schema: pre_aprobacion; Owner: postgres
--

SELECT pg_catalog.setval('intereses_id_seq', 91, true);


--
-- TOC entry 3024 (class 0 OID 77248)
-- Dependencies: 272 3035
-- Data for Name: multas; Type: TABLE DATA; Schema: pre_aprobacion; Owner: postgres
--

COPY multas (id, nresolucion, fechaelaboracion, fechanotificacion, montopagar, declaraid, ip, usuarioid) FROM stdin;
\.


--
-- TOC entry 3635 (class 0 OID 0)
-- Dependencies: 271
-- Name: multas_id_seq; Type: SEQUENCE SET; Schema: pre_aprobacion; Owner: postgres
--

SELECT pg_catalog.setval('multas_id_seq', 1, false);


SET search_path = seg, pg_catalog;

--
-- TOC entry 3020 (class 0 OID 46570)
-- Dependencies: 268 3035
-- Data for Name: tbl_ci_sessions; Type: TABLE DATA; Schema: seg; Owner: postgres
--

COPY tbl_ci_sessions (session_id, ip_address, user_agent, last_activity, user_data, prevent_update) FROM stdin;
90e669ac0125fd4321d13f9a82fe4f81	192.168.1.102	Mozilla/5.0 (X11; Linux i686) AppleWebKit/537.31 (KHTML, like Gecko) Chrome/26.0.1410.43 Safari/537.31	1364419202		0
e6e13fd99e31ac0f9ea7ce187341fc49	192.168.1.101	Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:19.0) Gecko/20100101 Firefox/19.0	1364419421	a:7:{s:14:"prevent_update";i:0;s:9:"user_data";s:0:"";s:6:"logged";b:1;s:2:"id";s:2:"48";s:7:"usuario";s:6:"jelara";s:6:"nombre";s:28:"Jefferson Arturo Lara Molina";s:12:"info_modulos";a:12:{i:0;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:1:"5";s:10:"str_modulo";s:15:"Administración";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:1:"#";s:8:"id_padre";s:1:"0";}i:1;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:1:"6";s:10:"str_modulo";s:8:"Usuarios";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:1:"5";}i:2;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:2:"13";s:10:"str_modulo";s:8:"Usuarios";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:30:"./mod_administrador/usuarios_c";s:8:"id_padre";s:1:"6";}i:3;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"104";s:10:"str_modulo";s:19:"Perfiles de usuario";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:1:"5";}i:4;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:2:"89";s:10:"str_modulo";s:11:"Recaudacion";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:1:"#";s:8:"id_padre";s:1:"0";}i:5;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:2:"90";s:10:"str_modulo";s:22:"Registro contribuyente";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:2:"89";}i:6;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:2:"93";s:10:"str_modulo";s:20:"Gestion Declaración";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:2:"89";}i:7;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:2:"98";s:10:"str_modulo";s:14:"Listado Omisos";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:43:"./mod_gestioncontribuyente/gestion_omisos_c";s:8:"id_padre";s:2:"89";}i:8;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"101";s:10:"str_modulo";s:7:"Finazas";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:1:"#";s:8:"id_padre";s:1:"0";}i:9;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"102";s:10:"str_modulo";s:13:"Fiscalizacion";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:1:"#";s:8:"id_padre";s:1:"0";}i:10;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"103";s:10:"str_modulo";s:5:"Legal";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:1:"#";s:8:"id_padre";s:1:"0";}i:11;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"105";s:10:"str_modulo";s:12:"Crear perfil";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:27:"./mod_administrador/roles_c";s:8:"id_padre";s:3:"104";}}}	0
\.


--
-- TOC entry 2997 (class 0 OID 21562)
-- Dependencies: 242 3035
-- Data for Name: tbl_modulo; Type: TABLE DATA; Schema: seg; Owner: postgres
--

COPY tbl_modulo (id_modulo, id_padre, str_nombre, str_descripcion, str_enlace, bln_borrado) FROM stdin;
90	89	Registro contribuyente	verifica planilla	./mod_administrador/principal_c	f
91	90	Contribuyentes inactivos	busqueda de planilla	./mod_gestioncontribuyente/lista_contribuyentes_inactivos_c	f
13	6	Usuarios	Modulo hijo que muestra el listar de Usuarios con todas las operacciones correspondientes 	./mod_administrador/usuarios_c	f
6	5	Usuarios	Administrar los usuarios del sistema	./mod_administrador/principal_c	f
93	89	Gestion Declaración	Gestion de alendarios de pago para declaracion del contribuyente	./mod_administrador/principal_c	f
97	93	Calendario de Pagos	Gestion de calendarios de pagos de la declaracion del contribuyente	./mod_gestioncontribuyente/gestion_calendarios_de_pago_c	f
98	89	Listado Omisos	Listado para los contribuyentes omisos	./mod_gestioncontribuyente/gestion_omisos_c	f
101	\N	Finazas	gerencia de finazas 	#	f
102	\N	Fiscalizacion	gerencia de fiscalizacion tributaria	#	f
103	\N	Legal	gerencia de legal	#	f
104	5	Perfiles de usuario	modulo para la craion de los roles dentro del sistema	./mod_administrador/principal_c	f
88	\N	PRUEBA	SJKHBAKJHSDK	./LKJLKJLK	t
105	104	Crear perfil	modulo para la cracion de los perfiles en el sistemas	./mod_administrador/roles_c	f
7	5	Manejo de Modulos	Administrar los grupos para los usuarios del sistema	./mod_administrador/principal_c	t
89	\N	Recaudacion	gerencia de recaudacion tributaria	#	f
100	\N	Recaudacion	gerencia de recaudacion tributaria	#	t
8	5	Módulos principales	Administrar los módulos del sistema	./mod_administrador/principal_c	t
86	7	Operaciones	modulo hijo para la creacion y manejos de modulos aguelos, padres y grupos	./mod_administrador/manejo_modulo_c	f
5	\N	Administración	Opciones de administración del sistema	#	f
\.


--
-- TOC entry 3636 (class 0 OID 0)
-- Dependencies: 243
-- Name: tbl_modulo_id_modulo_seq; Type: SEQUENCE SET; Schema: seg; Owner: postgres
--

SELECT pg_catalog.setval('tbl_modulo_id_modulo_seq', 105, true);


--
-- TOC entry 2999 (class 0 OID 21571)
-- Dependencies: 244 3035
-- Data for Name: tbl_permiso; Type: TABLE DATA; Schema: seg; Owner: postgres
--

COPY tbl_permiso (id_permiso, id_modulo, id_rol, int_permiso, bln_borrado) FROM stdin;
7	7	1	1	f
8	8	1	1	f
1635	5	8	1	t
1638	5	8	1	f
1636	6	8	1	t
15	13	1	1	f
1639	6	8	1	f
5	5	1	1	f
6	6	1	1	f
1637	104	8	1	t
1640	104	8	1	f
22	5	4	1	t
1641	5	4	1	f
23	6	4	1	t
24	89	1	1	f
25	90	1	1	f
26	5	2	1	f
27	6	2	1	f
28	5	3	1	f
31	6	3	1	f
32	89	5	1	f
33	90	5	1	f
34	93	1	1	f
36	100	1	1	f
37	101	1	1	f
38	102	1	1	f
39	103	1	1	f
35	98	1	1	f
40	104	1	1	f
41	105	1	1	f
1642	6	4	1	f
1643	104	4	1	f
60	103	2	1	f
61	101	5	1	f
\.


--
-- TOC entry 3637 (class 0 OID 0)
-- Dependencies: 245
-- Name: tbl_permiso_id_permiso_seq; Type: SEQUENCE SET; Schema: seg; Owner: postgres
--

SELECT pg_catalog.setval('tbl_permiso_id_permiso_seq', 1643, true);


--
-- TOC entry 3034 (class 0 OID 78878)
-- Dependencies: 282 3035
-- Data for Name: tbl_permiso_trampa; Type: TABLE DATA; Schema: seg; Owner: postgres
--

COPY tbl_permiso_trampa (id_permiso, id_modulo, id_rol, int_permiso, bln_borrado) FROM stdin;
\.


--
-- TOC entry 3638 (class 0 OID 0)
-- Dependencies: 281
-- Name: tbl_permiso_trampa_id_permiso_seq; Type: SEQUENCE SET; Schema: seg; Owner: postgres
--

SELECT pg_catalog.setval('tbl_permiso_trampa_id_permiso_seq', 9, true);


--
-- TOC entry 3001 (class 0 OID 21577)
-- Dependencies: 246 3035
-- Data for Name: tbl_rol; Type: TABLE DATA; Schema: seg; Owner: postgres
--

COPY tbl_rol (id_rol, str_rol, str_descripcion, bln_borrado) FROM stdin;
1	Administrador	Administrador del sistema	f
2	Coordinador	Coordinador de la sala situacional	f
3	Analista	Analista de seguimiento	f
4	Contribuyente	Rol para todos losn usuarios externo osea para los contribuyentes	f
5	CNAC	Rol para usuarios CNAC	f
7	prueba2	prueba2	t
6	prueba	prueba	t
8	Recaudacion	perfil para los funcionarios publicos que trabajan en la gererncia de recaudacion	f
\.


--
-- TOC entry 3639 (class 0 OID 0)
-- Dependencies: 247
-- Name: tbl_rol_id_rol_seq; Type: SEQUENCE SET; Schema: seg; Owner: postgres
--

SELECT pg_catalog.setval('tbl_rol_id_rol_seq', 8, true);


--
-- TOC entry 3003 (class 0 OID 21586)
-- Dependencies: 248 3035
-- Data for Name: tbl_rol_usuario; Type: TABLE DATA; Schema: seg; Owner: postgres
--

COPY tbl_rol_usuario (id_rol_usuario, id_rol, id_usuario, bln_borrado) FROM stdin;
1	1	16	f
19	1	17	f
54	5	47	f
34	2	18	f
55	1	48	f
\.


--
-- TOC entry 3640 (class 0 OID 0)
-- Dependencies: 249
-- Name: tbl_rol_usuario_id_rol_usuario_seq; Type: SEQUENCE SET; Schema: seg; Owner: postgres
--

SELECT pg_catalog.setval('tbl_rol_usuario_id_rol_usuario_seq', 55, true);


--
-- TOC entry 3005 (class 0 OID 21592)
-- Dependencies: 250 3035
-- Data for Name: tbl_session_ci; Type: TABLE DATA; Schema: seg; Owner: postgres
--

COPY tbl_session_ci (session_id, ip_address, user_agent, last_activity, user_data) FROM stdin;
182136f56912be47bda0cdb68bb380a0	192.168.1.102	Mozilla/5.0 (X11; Linux i686) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1312.70 Safari/537.17	1361557560	
6c9fdf344448e19d6c9cf9f75c27ebb7	192.168.1.102	Mozilla/5.0 (X11; Linux i686) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1312.70 Safari/537.17	1361557529	
\.


--
-- TOC entry 3006 (class 0 OID 21602)
-- Dependencies: 251 3035
-- Data for Name: tbl_usuario_rol; Type: TABLE DATA; Schema: seg; Owner: postgres
--

COPY tbl_usuario_rol (id_usuario_rol, id_usuario, id_rol, bol_borrado) FROM stdin;
\.


--
-- TOC entry 3641 (class 0 OID 0)
-- Dependencies: 252
-- Name: tbl_usuario_rol_id_usuario_rol_seq; Type: SEQUENCE SET; Schema: seg; Owner: postgres
--

SELECT pg_catalog.setval('tbl_usuario_rol_id_usuario_rol_seq', 16, true);


SET search_path = "segContribu", pg_catalog;

--
-- TOC entry 3008 (class 0 OID 22844)
-- Dependencies: 255 3035
-- Data for Name: tbl_modulo_contribu; Type: TABLE DATA; Schema: segContribu; Owner: postgres
--

COPY tbl_modulo_contribu (id_modulo, id_padre, str_nombre, str_descripcion, str_enlace, bln_borrado) FROM stdin;
89	\N	Contribuyente	Modulo Princioal del Contribuyente	#	f
90	89	Seccion	Padre	./mod_contribuyente/principal_c	f
91	90	Cargar datos	carga de datos del contribuyente	./mod_contribuyente/contribuyente_c/planilla_inicial	f
92	\N	Administracion	modulo para la administracion y gestion de la sesion del contribuyente	#	f
97	93	cambio de clave	cambio de clave tabs	./mod_contribuyente/gestion_contrasena_c	f
93	92	Seguridad	cambio de clave	./mod_contribuyente/principal_c	f
98	93	cambio pregunta secreta	cambio depregunta secreta	./mod_contribuyente/gestion_pregunta_secreta_c	f
99	\N	Declaraciones	modulo que gestiona todo lo relacionado con las declaraciones del contribuyente	#	f
100	99	Nueva declaracion	modulo para realizar la declaracion el contribuyente	./mod_contribuyente/principal_c	f
101	99	Consultar historico	modulo para realizar las consulta del historico de sus declaraciones 	./mod_contribuyente/principal_c	f
103	90	Carga de documentos	documentos complementarios del registro	./mod_contribuyente/filecontroller/documentos	f
106	89	Rep. legal	gestion de representante legal	./mod_contribuyente/principal_c	f
107	106	Carga de  Rep. legal	craga de representante legal	./mod_contribuyente/contribuyente_c/representante_legal	f
108	100	declarar	vista para la declaracion del contrribuyente	./mod_contribuyente/contribuyente_c/declaracion	f
102	90	Cargar accionistas	modulo para la carga de los accionistas	./mod_contribuyente/contribuyente_c/carga_accionistar	t
\.


--
-- TOC entry 3642 (class 0 OID 0)
-- Dependencies: 259
-- Name: tbl_modulo_id_modulo_seq; Type: SEQUENCE SET; Schema: segContribu; Owner: postgres
--

SELECT pg_catalog.setval('tbl_modulo_id_modulo_seq', 108, true);


--
-- TOC entry 3009 (class 0 OID 22851)
-- Dependencies: 256 3035
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
\.


--
-- TOC entry 3643 (class 0 OID 0)
-- Dependencies: 260
-- Name: tbl_permiso_id_permiso_seq; Type: SEQUENCE SET; Schema: segContribu; Owner: postgres
--

SELECT pg_catalog.setval('tbl_permiso_id_permiso_seq', 32, true);


--
-- TOC entry 3010 (class 0 OID 22855)
-- Dependencies: 257 3035
-- Data for Name: tbl_rol_contribu; Type: TABLE DATA; Schema: segContribu; Owner: postgres
--

COPY tbl_rol_contribu (id_rol, str_rol, str_descripcion, bln_borrado) FROM stdin;
1	Administrador	Administrador del sistema	f
2	Coordinador	Coordinador de la sala situacional	f
3	Analista	Analista de seguimiento	f
4	Datos Iniciales	Carga Inicial de Datos del contribuyente	f
\.


--
-- TOC entry 3644 (class 0 OID 0)
-- Dependencies: 261
-- Name: tbl_rol_id_rol_seq; Type: SEQUENCE SET; Schema: segContribu; Owner: postgres
--

SELECT pg_catalog.setval('tbl_rol_id_rol_seq', 4, true);


--
-- TOC entry 3011 (class 0 OID 22862)
-- Dependencies: 258 3035
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
\.


--
-- TOC entry 3645 (class 0 OID 0)
-- Dependencies: 262
-- Name: tbl_rol_usuario_id_rol_usuario_seq; Type: SEQUENCE SET; Schema: segContribu; Owner: postgres
--

SELECT pg_catalog.setval('tbl_rol_usuario_id_rol_usuario_seq', 60, true);


--
-- TOC entry 3016 (class 0 OID 22884)
-- Dependencies: 263 3035
-- Data for Name: tbl_usuario_rol_contribu; Type: TABLE DATA; Schema: segContribu; Owner: postgres
--

COPY tbl_usuario_rol_contribu (id_usuario_rol, id_usuario, id_rol, bol_borrado) FROM stdin;
\.


--
-- TOC entry 3646 (class 0 OID 0)
-- Dependencies: 264
-- Name: tbl_usuario_rol_id_usuario_rol_seq; Type: SEQUENCE SET; Schema: segContribu; Owner: postgres
--

SELECT pg_catalog.setval('tbl_usuario_rol_id_usuario_rol_seq', 16, true);


SET search_path = datos, pg_catalog;

--
-- TOC entry 2672 (class 2606 OID 20855)
-- Dependencies: 226 226 226 3036
-- Name: CT_Accionis_IDContribu_Ci; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY accionis
    ADD CONSTRAINT "CT_Accionis_IDContribu_Ci" UNIQUE (contribuid, ci);


--
-- TOC entry 2469 (class 2606 OID 20857)
-- Dependencies: 167 167 3036
-- Name: CT_ActiExon_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY actiecon
    ADD CONSTRAINT "CT_ActiExon_Nombre" UNIQUE (nombre);


--
-- TOC entry 2474 (class 2606 OID 20859)
-- Dependencies: 169 169 169 3036
-- Name: CT_AlicImp_IDTipoCont_Ano; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY alicimp
    ADD CONSTRAINT "CT_AlicImp_IDTipoCont_Ano" UNIQUE (tipocontid, ano);


--
-- TOC entry 2481 (class 2606 OID 20861)
-- Dependencies: 171 171 171 3036
-- Name: CT_AsiendoD_IDAsiento_Referencia; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY asientod
    ADD CONSTRAINT "CT_AsiendoD_IDAsiento_Referencia" UNIQUE (asientoid, referencia);


--
-- TOC entry 2692 (class 2606 OID 20863)
-- Dependencies: 228 228 3036
-- Name: CT_AsientoM_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY asientom
    ADD CONSTRAINT "CT_AsientoM_Nombre" UNIQUE (nombre);


--
-- TOC entry 2681 (class 2606 OID 20865)
-- Dependencies: 227 227 227 227 3036
-- Name: CT_Asiento_NuAsiento_Mes_Ano; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY asiento
    ADD CONSTRAINT "CT_Asiento_NuAsiento_Mes_Ano" UNIQUE (nuasiento, mes, ano);


--
-- TOC entry 2489 (class 2606 OID 20867)
-- Dependencies: 174 174 3036
-- Name: CT_BaCuenta_Cuenta; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY bacuenta
    ADD CONSTRAINT "CT_BaCuenta_Cuenta" UNIQUE (cuenta);


--
-- TOC entry 2495 (class 2606 OID 20869)
-- Dependencies: 176 176 3036
-- Name: CT_Bancos_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY bancos
    ADD CONSTRAINT "CT_Bancos_Nombre" UNIQUE (nombre);


--
-- TOC entry 2504 (class 2606 OID 20871)
-- Dependencies: 180 180 180 3036
-- Name: CT_CalPagos_Ano_IDTiPeGrav; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY calpago
    ADD CONSTRAINT "CT_CalPagos_Ano_IDTiPeGrav" UNIQUE (ano, tipegravid);


--
-- TOC entry 2506 (class 2606 OID 20873)
-- Dependencies: 180 180 180 3036
-- Name: CT_CalPagos_Nombre_Ano; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY calpago
    ADD CONSTRAINT "CT_CalPagos_Nombre_Ano" UNIQUE (nombre, ano);


--
-- TOC entry 2513 (class 2606 OID 20875)
-- Dependencies: 182 182 3036
-- Name: CT_Cargos_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY cargos
    ADD CONSTRAINT "CT_Cargos_Nombre" UNIQUE (nombre);


--
-- TOC entry 2518 (class 2606 OID 20877)
-- Dependencies: 184 184 184 3036
-- Name: CT_Ciudades_IDEstado_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ciudades
    ADD CONSTRAINT "CT_Ciudades_IDEstado_Nombre" UNIQUE (estadoid, nombre);


--
-- TOC entry 2524 (class 2606 OID 20879)
-- Dependencies: 186 186 186 3036
-- Name: CT_ConUsuCo_IDConUsu_IDContribu; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY conusuco
    ADD CONSTRAINT "CT_ConUsuCo_IDConUsu_IDContribu" UNIQUE (conusuid, contribuid);


--
-- TOC entry 2533 (class 2606 OID 20881)
-- Dependencies: 190 190 3036
-- Name: CT_ConUsuTo_Token; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY conusuto
    ADD CONSTRAINT "CT_ConUsuTo_Token" UNIQUE (token);


--
-- TOC entry 2538 (class 2606 OID 20883)
-- Dependencies: 192 192 3036
-- Name: CT_ConUsu_Email; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY conusu
    ADD CONSTRAINT "CT_ConUsu_Email" UNIQUE (email);


--
-- TOC entry 2540 (class 2606 OID 20885)
-- Dependencies: 192 192 3036
-- Name: CT_ConUsu_Login; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY conusu
    ADD CONSTRAINT "CT_ConUsu_Login" UNIQUE (login);


--
-- TOC entry 2702 (class 2606 OID 20887)
-- Dependencies: 232 232 232 3036
-- Name: CT_ContribuTi_ContribuID_TipoContID; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY contributi
    ADD CONSTRAINT "CT_ContribuTi_ContribuID_TipoContID" UNIQUE (contribuid, tipocontid);


--
-- TOC entry 2548 (class 2606 OID 20889)
-- Dependencies: 194 194 3036
-- Name: CT_Contribu_NumRegCine; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY contribu
    ADD CONSTRAINT "CT_Contribu_NumRegCine" UNIQUE (numregcine);


--
-- TOC entry 2550 (class 2606 OID 20891)
-- Dependencies: 194 194 3036
-- Name: CT_Contribu_RazonSocia; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY contribu
    ADD CONSTRAINT "CT_Contribu_RazonSocia" UNIQUE (razonsocia);


--
-- TOC entry 2552 (class 2606 OID 20893)
-- Dependencies: 194 194 3036
-- Name: CT_Contribu_Rif; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY contribu
    ADD CONSTRAINT "CT_Contribu_Rif" UNIQUE (rif);


--
-- TOC entry 2561 (class 2606 OID 46589)
-- Dependencies: 196 196 3036
-- Name: CT_Declara_NuDeclara; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT "CT_Declara_NuDeclara" UNIQUE (nudeclara);


--
-- TOC entry 2563 (class 2606 OID 46608)
-- Dependencies: 196 196 3036
-- Name: CT_Declara_NuDeposito; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT "CT_Declara_NuDeposito" UNIQUE (nudeposito);


--
-- TOC entry 2577 (class 2606 OID 20899)
-- Dependencies: 198 198 3036
-- Name: CT_Departam_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY departam
    ADD CONSTRAINT "CT_Departam_Nombre" UNIQUE (nombre);


--
-- TOC entry 2711 (class 2606 OID 20901)
-- Dependencies: 235 235 3036
-- Name: CT_Document_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY document
    ADD CONSTRAINT "CT_Document_Nombre" UNIQUE (nombre);


--
-- TOC entry 2582 (class 2606 OID 20903)
-- Dependencies: 200 200 200 3036
-- Name: CT_EntidadD_IDEntidad_Accion; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY entidadd
    ADD CONSTRAINT "CT_EntidadD_IDEntidad_Accion" UNIQUE (entidadid, accion);


--
-- TOC entry 2584 (class 2606 OID 20905)
-- Dependencies: 200 200 200 3036
-- Name: CT_EntidadD_IDEntidad_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY entidadd
    ADD CONSTRAINT "CT_EntidadD_IDEntidad_Nombre" UNIQUE (entidadid, nombre);


--
-- TOC entry 2586 (class 2606 OID 20907)
-- Dependencies: 200 200 200 3036
-- Name: CT_EntidadD_IDEntidad_Orden; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY entidadd
    ADD CONSTRAINT "CT_EntidadD_IDEntidad_Orden" UNIQUE (entidadid, orden);


--
-- TOC entry 2594 (class 2606 OID 20909)
-- Dependencies: 202 202 3036
-- Name: CT_Entidad_Entidad; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY entidad
    ADD CONSTRAINT "CT_Entidad_Entidad" UNIQUE (entidad);


--
-- TOC entry 2596 (class 2606 OID 20911)
-- Dependencies: 202 202 3036
-- Name: CT_Entidad_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY entidad
    ADD CONSTRAINT "CT_Entidad_Nombre" UNIQUE (nombre);


--
-- TOC entry 2598 (class 2606 OID 20913)
-- Dependencies: 202 202 3036
-- Name: CT_Entidad_Orden; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY entidad
    ADD CONSTRAINT "CT_Entidad_Orden" UNIQUE (orden);


--
-- TOC entry 2602 (class 2606 OID 20915)
-- Dependencies: 204 204 3036
-- Name: CT_Estados_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY estados
    ADD CONSTRAINT "CT_Estados_Nombre" UNIQUE (nombre);


--
-- TOC entry 2607 (class 2606 OID 20917)
-- Dependencies: 206 206 206 3036
-- Name: CT_PerUsuD_IDPerUsu_IDEntidadD; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY perusud
    ADD CONSTRAINT "CT_PerUsuD_IDPerUsu_IDEntidadD" UNIQUE (perusuid, entidaddid);


--
-- TOC entry 2614 (class 2606 OID 20919)
-- Dependencies: 208 208 3036
-- Name: CT_PerUsu_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY perusu
    ADD CONSTRAINT "CT_PerUsu_Nombre" UNIQUE (nombre);


--
-- TOC entry 2619 (class 2606 OID 20921)
-- Dependencies: 210 210 3036
-- Name: CT_PregSecr_Pregunta; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY pregsecr
    ADD CONSTRAINT "CT_PregSecr_Pregunta" UNIQUE (nombre);


--
-- TOC entry 2624 (class 2606 OID 20923)
-- Dependencies: 212 212 212 3036
-- Name: CT_RepLegal_IDContribu_Ci; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY replegal
    ADD CONSTRAINT "CT_RepLegal_IDContribu_Ci" UNIQUE (contribuid, ci);


--
-- TOC entry 2635 (class 2606 OID 20925)
-- Dependencies: 214 214 3036
-- Name: CT_TDeclara_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tdeclara
    ADD CONSTRAINT "CT_TDeclara_Nombre" UNIQUE (nombre);


--
-- TOC entry 2640 (class 2606 OID 20927)
-- Dependencies: 216 216 3036
-- Name: CT_TiPeGrav_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tipegrav
    ADD CONSTRAINT "CT_TiPeGrav_Nombre" UNIQUE (nombre);


--
-- TOC entry 2645 (class 2606 OID 20929)
-- Dependencies: 218 218 3036
-- Name: CT_TipoCont_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tipocont
    ADD CONSTRAINT "CT_TipoCont_Nombre" UNIQUE (nombre);


--
-- TOC entry 2724 (class 2606 OID 20931)
-- Dependencies: 238 238 3036
-- Name: CT_TmpContri_NumRegCine; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tmpcontri
    ADD CONSTRAINT "CT_TmpContri_NumRegCine" UNIQUE (numregcine);


--
-- TOC entry 2726 (class 2606 OID 20933)
-- Dependencies: 238 238 3036
-- Name: CT_TmpContri_RazonSocia; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tmpcontri
    ADD CONSTRAINT "CT_TmpContri_RazonSocia" UNIQUE (razonsocia);


--
-- TOC entry 2728 (class 2606 OID 20935)
-- Dependencies: 238 238 3036
-- Name: CT_TmpContri_Rif; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tmpcontri
    ADD CONSTRAINT "CT_TmpContri_Rif" UNIQUE (rif);


--
-- TOC entry 2738 (class 2606 OID 20937)
-- Dependencies: 239 239 239 3036
-- Name: CT_TmpReLegal_IDContribu_Ci; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tmprelegal
    ADD CONSTRAINT "CT_TmpReLegal_IDContribu_Ci" UNIQUE (contribuid, ci);


--
-- TOC entry 2661 (class 2606 OID 20939)
-- Dependencies: 224 224 3036
-- Name: CT_USFonPro_Email; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY usfonpro
    ADD CONSTRAINT "CT_USFonPro_Email" UNIQUE (email);


--
-- TOC entry 2651 (class 2606 OID 20941)
-- Dependencies: 220 220 3036
-- Name: CT_UndTrib_Fecha; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY undtrib
    ADD CONSTRAINT "CT_UndTrib_Fecha" UNIQUE (fecha);


--
-- TOC entry 2656 (class 2606 OID 20943)
-- Dependencies: 222 222 3036
-- Name: CT_UsFonpTo_Token; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY usfonpto
    ADD CONSTRAINT "CT_UsFonpTo_Token" UNIQUE (token);


--
-- TOC entry 2663 (class 2606 OID 20945)
-- Dependencies: 224 224 3036
-- Name: CT_UsFonpro_Login; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY usfonpro
    ADD CONSTRAINT "CT_UsFonpro_Login" UNIQUE (login);


--
-- TOC entry 2716 (class 2606 OID 20947)
-- Dependencies: 237 237 237 3036
-- Name: CT_tmpAccioni_ContribuID_Ci; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tmpaccioni
    ADD CONSTRAINT "CT_tmpAccioni_ContribuID_Ci" UNIQUE (contribuid, ci);


--
-- TOC entry 2679 (class 2606 OID 20949)
-- Dependencies: 226 226 3036
-- Name: PK_Accionis; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY accionis
    ADD CONSTRAINT "PK_Accionis" PRIMARY KEY (id);


--
-- TOC entry 2472 (class 2606 OID 20951)
-- Dependencies: 167 167 3036
-- Name: PK_ActiEcon; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY actiecon
    ADD CONSTRAINT "PK_ActiEcon" PRIMARY KEY (id);

ALTER TABLE actiecon CLUSTER ON "PK_ActiEcon";


--
-- TOC entry 2479 (class 2606 OID 20953)
-- Dependencies: 169 169 3036
-- Name: PK_AlicImp; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY alicimp
    ADD CONSTRAINT "PK_AlicImp" PRIMARY KEY (id);

ALTER TABLE alicimp CLUSTER ON "PK_AlicImp";


--
-- TOC entry 2690 (class 2606 OID 20955)
-- Dependencies: 227 227 3036
-- Name: PK_Asiento; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY asiento
    ADD CONSTRAINT "PK_Asiento" PRIMARY KEY (id);

ALTER TABLE asiento CLUSTER ON "PK_Asiento";


--
-- TOC entry 2487 (class 2606 OID 20957)
-- Dependencies: 171 171 3036
-- Name: PK_AsientoD; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY asientod
    ADD CONSTRAINT "PK_AsientoD" PRIMARY KEY (id);

ALTER TABLE asientod CLUSTER ON "PK_AsientoD";


--
-- TOC entry 2695 (class 2606 OID 20959)
-- Dependencies: 228 228 3036
-- Name: PK_AsientoM; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY asientom
    ADD CONSTRAINT "PK_AsientoM" PRIMARY KEY (id);

ALTER TABLE asientom CLUSTER ON "PK_AsientoM";


--
-- TOC entry 2700 (class 2606 OID 20961)
-- Dependencies: 230 230 3036
-- Name: PK_AsientoMD; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY asientomd
    ADD CONSTRAINT "PK_AsientoMD" PRIMARY KEY (id);

ALTER TABLE asientomd CLUSTER ON "PK_AsientoMD";


--
-- TOC entry 2493 (class 2606 OID 20963)
-- Dependencies: 174 174 3036
-- Name: PK_BaCuenta; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY bacuenta
    ADD CONSTRAINT "PK_BaCuenta" PRIMARY KEY (id);

ALTER TABLE bacuenta CLUSTER ON "PK_BaCuenta";


--
-- TOC entry 2498 (class 2606 OID 20965)
-- Dependencies: 176 176 3036
-- Name: PK_Bancos; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY bancos
    ADD CONSTRAINT "PK_Bancos" PRIMARY KEY (id);

ALTER TABLE bancos CLUSTER ON "PK_Bancos";


--
-- TOC entry 2502 (class 2606 OID 20967)
-- Dependencies: 178 178 3036
-- Name: PK_CalPagoD; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY calpagod
    ADD CONSTRAINT "PK_CalPagoD" PRIMARY KEY (id);

ALTER TABLE calpagod CLUSTER ON "PK_CalPagoD";


--
-- TOC entry 2511 (class 2606 OID 20969)
-- Dependencies: 180 180 3036
-- Name: PK_CalPagos; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY calpago
    ADD CONSTRAINT "PK_CalPagos" PRIMARY KEY (id);

ALTER TABLE calpago CLUSTER ON "PK_CalPagos";


--
-- TOC entry 2516 (class 2606 OID 20971)
-- Dependencies: 182 182 3036
-- Name: PK_Cargos; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY cargos
    ADD CONSTRAINT "PK_Cargos" PRIMARY KEY (id);

ALTER TABLE cargos CLUSTER ON "PK_Cargos";


--
-- TOC entry 2522 (class 2606 OID 20973)
-- Dependencies: 184 184 3036
-- Name: PK_Ciudades; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ciudades
    ADD CONSTRAINT "PK_Ciudades" PRIMARY KEY (id);

ALTER TABLE ciudades CLUSTER ON "PK_Ciudades";


--
-- TOC entry 2546 (class 2606 OID 20975)
-- Dependencies: 192 192 3036
-- Name: PK_ConUsu; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY conusu
    ADD CONSTRAINT "PK_ConUsu" PRIMARY KEY (id);

ALTER TABLE conusu CLUSTER ON "PK_ConUsu";


--
-- TOC entry 2528 (class 2606 OID 20977)
-- Dependencies: 186 186 3036
-- Name: PK_ConUsuCo; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY conusuco
    ADD CONSTRAINT "PK_ConUsuCo" PRIMARY KEY (id);

ALTER TABLE conusuco CLUSTER ON "PK_ConUsuCo";


--
-- TOC entry 2531 (class 2606 OID 20979)
-- Dependencies: 188 188 3036
-- Name: PK_ConUsuTi; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY conusuti
    ADD CONSTRAINT "PK_ConUsuTi" PRIMARY KEY (id);

ALTER TABLE conusuti CLUSTER ON "PK_ConUsuTi";


--
-- TOC entry 2536 (class 2606 OID 20981)
-- Dependencies: 190 190 3036
-- Name: PK_ConUsuTo; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY conusuto
    ADD CONSTRAINT "PK_ConUsuTo" PRIMARY KEY (id);

ALTER TABLE conusuto CLUSTER ON "PK_ConUsuTo";


--
-- TOC entry 2559 (class 2606 OID 20983)
-- Dependencies: 194 194 3036
-- Name: PK_Contribu; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY contribu
    ADD CONSTRAINT "PK_Contribu" PRIMARY KEY (id);

ALTER TABLE contribu CLUSTER ON "PK_Contribu";


--
-- TOC entry 2706 (class 2606 OID 20985)
-- Dependencies: 232 232 3036
-- Name: PK_ContribuTi; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY contributi
    ADD CONSTRAINT "PK_ContribuTi" PRIMARY KEY (id);

ALTER TABLE contributi CLUSTER ON "PK_ContribuTi";


--
-- TOC entry 2709 (class 2606 OID 20987)
-- Dependencies: 234 234 3036
-- Name: PK_CtaConta; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ctaconta
    ADD CONSTRAINT "PK_CtaConta" PRIMARY KEY (cuenta);

ALTER TABLE ctaconta CLUSTER ON "PK_CtaConta";


--
-- TOC entry 2575 (class 2606 OID 20989)
-- Dependencies: 196 196 3036
-- Name: PK_Declara; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT "PK_Declara" PRIMARY KEY (id);

ALTER TABLE declara CLUSTER ON "PK_Declara";


--
-- TOC entry 2579 (class 2606 OID 20991)
-- Dependencies: 198 198 3036
-- Name: PK_Departam; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY departam
    ADD CONSTRAINT "PK_Departam" PRIMARY KEY (id);

ALTER TABLE departam CLUSTER ON "PK_Departam";


--
-- TOC entry 2714 (class 2606 OID 20993)
-- Dependencies: 235 235 3036
-- Name: PK_Document; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY document
    ADD CONSTRAINT "PK_Document" PRIMARY KEY (id);

ALTER TABLE document CLUSTER ON "PK_Document";


--
-- TOC entry 2600 (class 2606 OID 20995)
-- Dependencies: 202 202 3036
-- Name: PK_Entidad; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY entidad
    ADD CONSTRAINT "PK_Entidad" PRIMARY KEY (id);

ALTER TABLE entidad CLUSTER ON "PK_Entidad";


--
-- TOC entry 2592 (class 2606 OID 20997)
-- Dependencies: 200 200 3036
-- Name: PK_EntidadD; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY entidadd
    ADD CONSTRAINT "PK_EntidadD" PRIMARY KEY (id);

ALTER TABLE entidadd CLUSTER ON "PK_EntidadD";


--
-- TOC entry 2605 (class 2606 OID 20999)
-- Dependencies: 204 204 3036
-- Name: PK_Estados; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY estados
    ADD CONSTRAINT "PK_Estados" PRIMARY KEY (id);

ALTER TABLE estados CLUSTER ON "PK_Estados";


--
-- TOC entry 2612 (class 2606 OID 21001)
-- Dependencies: 206 206 3036
-- Name: PK_PerUsuD; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY perusud
    ADD CONSTRAINT "PK_PerUsuD" PRIMARY KEY (id);

ALTER TABLE perusud CLUSTER ON "PK_PerUsuD";


--
-- TOC entry 2617 (class 2606 OID 21003)
-- Dependencies: 208 208 3036
-- Name: PK_PerUsu_IDPerUsu; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY perusu
    ADD CONSTRAINT "PK_PerUsu_IDPerUsu" PRIMARY KEY (id);

ALTER TABLE perusu CLUSTER ON "PK_PerUsu_IDPerUsu";


--
-- TOC entry 2622 (class 2606 OID 21005)
-- Dependencies: 210 210 3036
-- Name: PK_PregSecr; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY pregsecr
    ADD CONSTRAINT "PK_PregSecr" PRIMARY KEY (id);

ALTER TABLE pregsecr CLUSTER ON "PK_PregSecr";


--
-- TOC entry 2633 (class 2606 OID 21007)
-- Dependencies: 212 212 3036
-- Name: PK_RepLegal; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY replegal
    ADD CONSTRAINT "PK_RepLegal" PRIMARY KEY (id);

ALTER TABLE replegal CLUSTER ON "PK_RepLegal";


--
-- TOC entry 2638 (class 2606 OID 21009)
-- Dependencies: 214 214 3036
-- Name: PK_TDeclara; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tdeclara
    ADD CONSTRAINT "PK_TDeclara" PRIMARY KEY (id);

ALTER TABLE tdeclara CLUSTER ON "PK_TDeclara";


--
-- TOC entry 2643 (class 2606 OID 21011)
-- Dependencies: 216 216 3036
-- Name: PK_TiPeGrav; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tipegrav
    ADD CONSTRAINT "PK_TiPeGrav" PRIMARY KEY (id);

ALTER TABLE tipegrav CLUSTER ON "PK_TiPeGrav";


--
-- TOC entry 2649 (class 2606 OID 21013)
-- Dependencies: 218 218 3036
-- Name: PK_TipoCont; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tipocont
    ADD CONSTRAINT "PK_TipoCont" PRIMARY KEY (id);

ALTER TABLE tipocont CLUSTER ON "PK_TipoCont";


--
-- TOC entry 2736 (class 2606 OID 21015)
-- Dependencies: 238 238 3036
-- Name: PK_TmpContri; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tmpcontri
    ADD CONSTRAINT "PK_TmpContri" PRIMARY KEY (id);


--
-- TOC entry 2746 (class 2606 OID 21017)
-- Dependencies: 239 239 3036
-- Name: PK_TmpReLegal; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tmprelegal
    ADD CONSTRAINT "PK_TmpReLegal" PRIMARY KEY (id);


--
-- TOC entry 2654 (class 2606 OID 21019)
-- Dependencies: 220 220 3036
-- Name: PK_UndTrib; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY undtrib
    ADD CONSTRAINT "PK_UndTrib" PRIMARY KEY (id);

ALTER TABLE undtrib CLUSTER ON "PK_UndTrib";


--
-- TOC entry 2670 (class 2606 OID 21021)
-- Dependencies: 224 224 3036
-- Name: PK_UsFonPro; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY usfonpro
    ADD CONSTRAINT "PK_UsFonPro" PRIMARY KEY (id);

ALTER TABLE usfonpro CLUSTER ON "PK_UsFonPro";


--
-- TOC entry 2659 (class 2606 OID 21023)
-- Dependencies: 222 222 3036
-- Name: PK_UsFonpTo; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY usfonpto
    ADD CONSTRAINT "PK_UsFonpTo" PRIMARY KEY (id);

ALTER TABLE usfonpto CLUSTER ON "PK_UsFonpTo";


--
-- TOC entry 2722 (class 2606 OID 21025)
-- Dependencies: 237 237 3036
-- Name: PK_tmpAccioni; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tmpaccioni
    ADD CONSTRAINT "PK_tmpAccioni" PRIMARY KEY (id);


--
-- TOC entry 2789 (class 2606 OID 77301)
-- Dependencies: 275 275 3036
-- Name: pk-interesbcv; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY interes_bcv
    ADD CONSTRAINT "pk-interesbcv" PRIMARY KEY (id);


--
-- TOC entry 2777 (class 2606 OID 46448)
-- Dependencies: 267 267 3036
-- Name: pk_con_img_doc; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY con_img_doc
    ADD CONSTRAINT pk_con_img_doc PRIMARY KEY (id);


--
-- TOC entry 2781 (class 2606 OID 69005)
-- Dependencies: 270 270 3036
-- Name: pk_conusu_tipocont; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY conusu_tipocont
    ADD CONSTRAINT pk_conusu_tipocont PRIMARY KEY (id);


--
-- TOC entry 2791 (class 2606 OID 77340)
-- Dependencies: 278 278 3036
-- Name: pk_detalle_interes; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY detalle_interes
    ADD CONSTRAINT pk_detalle_interes PRIMARY KEY (id);


--
-- TOC entry 2793 (class 2606 OID 78849)
-- Dependencies: 280 280 3036
-- Name: pk_detalle_interes_n; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY detalle_interes_viejo
    ADD CONSTRAINT pk_detalle_interes_n PRIMARY KEY (id);


--
-- TOC entry 2783 (class 2606 OID 69012)
-- Dependencies: 270 270 270 3036
-- Name: uq_tipoconid; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY conusu_tipocont
    ADD CONSTRAINT uq_tipoconid UNIQUE (conusuid, tipocontid);


SET search_path = historial, pg_catalog;

--
-- TOC entry 2753 (class 2606 OID 21027)
-- Dependencies: 240 240 3036
-- Name: PK_Bitacora; Type: CONSTRAINT; Schema: historial; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY bitacora
    ADD CONSTRAINT "PK_Bitacora" PRIMARY KEY (id);

ALTER TABLE bitacora CLUSTER ON "PK_Bitacora";


SET search_path = pre_aprobacion, pg_catalog;

--
-- TOC entry 2787 (class 2606 OID 77277)
-- Dependencies: 274 274 3036
-- Name: pk-intereses; Type: CONSTRAINT; Schema: pre_aprobacion; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY intereses
    ADD CONSTRAINT "pk-intereses" PRIMARY KEY (id);


--
-- TOC entry 2785 (class 2606 OID 77256)
-- Dependencies: 272 272 3036
-- Name: pk-multa; Type: CONSTRAINT; Schema: pre_aprobacion; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY multas
    ADD CONSTRAINT "pk-multa" PRIMARY KEY (id);


SET search_path = seg, pg_catalog;

--
-- TOC entry 2779 (class 2606 OID 46581)
-- Dependencies: 268 268 3036
-- Name: pk_ci_sessions; Type: CONSTRAINT; Schema: seg; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_ci_sessions
    ADD CONSTRAINT pk_ci_sessions PRIMARY KEY (session_id);


--
-- TOC entry 2755 (class 2606 OID 21614)
-- Dependencies: 242 242 3036
-- Name: pk_modulo; Type: CONSTRAINT; Schema: seg; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_modulo
    ADD CONSTRAINT pk_modulo PRIMARY KEY (id_modulo);


--
-- TOC entry 2757 (class 2606 OID 21616)
-- Dependencies: 244 244 3036
-- Name: pk_permiso; Type: CONSTRAINT; Schema: seg; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_permiso
    ADD CONSTRAINT pk_permiso PRIMARY KEY (id_permiso);


--
-- TOC entry 2759 (class 2606 OID 21618)
-- Dependencies: 246 246 3036
-- Name: pk_rol; Type: CONSTRAINT; Schema: seg; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_rol
    ADD CONSTRAINT pk_rol PRIMARY KEY (id_rol);


--
-- TOC entry 2761 (class 2606 OID 21620)
-- Dependencies: 248 248 3036
-- Name: pk_rol_usuario; Type: CONSTRAINT; Schema: seg; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_rol_usuario
    ADD CONSTRAINT pk_rol_usuario PRIMARY KEY (id_rol_usuario);


--
-- TOC entry 2765 (class 2606 OID 21622)
-- Dependencies: 251 251 3036
-- Name: pk_usuario_rol; Type: CONSTRAINT; Schema: seg; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_usuario_rol
    ADD CONSTRAINT pk_usuario_rol PRIMARY KEY (id_usuario_rol);


--
-- TOC entry 2795 (class 2606 OID 78884)
-- Dependencies: 282 282 3036
-- Name: pkt_permiso; Type: CONSTRAINT; Schema: seg; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_permiso_trampa
    ADD CONSTRAINT pkt_permiso PRIMARY KEY (id_permiso);


--
-- TOC entry 2763 (class 2606 OID 21624)
-- Dependencies: 250 250 3036
-- Name: tbl_session_ci_pkey; Type: CONSTRAINT; Schema: seg; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_session_ci
    ADD CONSTRAINT tbl_session_ci_pkey PRIMARY KEY (session_id);


SET search_path = "segContribu", pg_catalog;

--
-- TOC entry 2767 (class 2606 OID 22901)
-- Dependencies: 255 255 3036
-- Name: pk_modulo; Type: CONSTRAINT; Schema: segContribu; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_modulo_contribu
    ADD CONSTRAINT pk_modulo PRIMARY KEY (id_modulo);


--
-- TOC entry 2769 (class 2606 OID 22903)
-- Dependencies: 256 256 3036
-- Name: pk_permiso; Type: CONSTRAINT; Schema: segContribu; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_permiso_contribu
    ADD CONSTRAINT pk_permiso PRIMARY KEY (id_permiso);


--
-- TOC entry 2771 (class 2606 OID 22905)
-- Dependencies: 257 257 3036
-- Name: pk_rol; Type: CONSTRAINT; Schema: segContribu; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_rol_contribu
    ADD CONSTRAINT pk_rol PRIMARY KEY (id_rol);


--
-- TOC entry 2773 (class 2606 OID 22907)
-- Dependencies: 258 258 3036
-- Name: pk_rol_usuario; Type: CONSTRAINT; Schema: segContribu; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_rol_usuario_contribu
    ADD CONSTRAINT pk_rol_usuario PRIMARY KEY (id_rol_usuario);


--
-- TOC entry 2775 (class 2606 OID 22909)
-- Dependencies: 263 263 3036
-- Name: pk_usuario_rol; Type: CONSTRAINT; Schema: segContribu; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_usuario_rol_contribu
    ADD CONSTRAINT pk_usuario_rol PRIMARY KEY (id_usuario_rol);


SET search_path = datos, pg_catalog;

--
-- TOC entry 2673 (class 1259 OID 46550)
-- Dependencies: 226 3036
-- Name: FKI_Accionis_IDContribu; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Accionis_IDContribu" ON accionis USING btree (contribuid);


--
-- TOC entry 2674 (class 1259 OID 21029)
-- Dependencies: 226 3036
-- Name: FKI_Accionis_UsFonpro_UsuarioID_ID; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Accionis_UsFonpro_UsuarioID_ID" ON accionis USING btree (usuarioid);


--
-- TOC entry 2470 (class 1259 OID 21031)
-- Dependencies: 167 3036
-- Name: FKI_ActiEcon_USFonpro_IDUsuario_IDUsFornpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_ActiEcon_USFonpro_IDUsuario_IDUsFornpro" ON actiecon USING btree (usuarioid);


--
-- TOC entry 2475 (class 1259 OID 21032)
-- Dependencies: 169 3036
-- Name: FKI_AlicImp_TipoCont_IDTipoCont; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_AlicImp_TipoCont_IDTipoCont" ON alicimp USING btree (tipocontid);


--
-- TOC entry 2476 (class 1259 OID 21033)
-- Dependencies: 169 3036
-- Name: FKI_AlicImp_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_AlicImp_UsFonpro_IDUsuario_IDUsFonpro" ON alicimp USING btree (usuarioid);


--
-- TOC entry 2482 (class 1259 OID 21034)
-- Dependencies: 171 3036
-- Name: FKI_AsientoD_Asiento_IDAsiento; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_AsientoD_Asiento_IDAsiento" ON asientod USING btree (asientoid);


--
-- TOC entry 2483 (class 1259 OID 21036)
-- Dependencies: 171 3036
-- Name: FKI_AsientoD_CtaConta_Cuenta; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_AsientoD_CtaConta_Cuenta" ON asientod USING btree (cuenta);


--
-- TOC entry 2484 (class 1259 OID 21037)
-- Dependencies: 171 3036
-- Name: FKI_AsientoD_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_AsientoD_UsFonpro_IDUsuario_IDUsFonpro" ON asientod USING btree (usuarioid);


--
-- TOC entry 2696 (class 1259 OID 21038)
-- Dependencies: 230 3036
-- Name: FKI_AsientoMD_AsientoM_AsientoMID_ID; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_AsientoMD_AsientoM_AsientoMID_ID" ON asientomd USING btree (asientomid);


--
-- TOC entry 2697 (class 1259 OID 21039)
-- Dependencies: 230 3036
-- Name: FKI_AsientoMD_CtaConta_Cuenta; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_AsientoMD_CtaConta_Cuenta" ON asientomd USING btree (cuenta);


--
-- TOC entry 2698 (class 1259 OID 21040)
-- Dependencies: 230 3036
-- Name: FKI_AsientoMD_UsFonpro_UsuarioID_ID; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_AsientoMD_UsFonpro_UsuarioID_ID" ON asientomd USING btree (usuarioid);


--
-- TOC entry 2693 (class 1259 OID 21041)
-- Dependencies: 228 3036
-- Name: FKI_AsientoM_UsFonpro_UsuarioID_ID; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_AsientoM_UsFonpro_UsuarioID_ID" ON asientom USING btree (usuarioid);


--
-- TOC entry 2682 (class 1259 OID 21042)
-- Dependencies: 227 3036
-- Name: FKI_Asiento_UsFonpro_IDUsCierre_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Asiento_UsFonpro_IDUsCierre_IDUsFonpro" ON asiento USING btree (uscierreid);


--
-- TOC entry 2683 (class 1259 OID 21043)
-- Dependencies: 227 3036
-- Name: FKI_Asiento_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Asiento_UsFonpro_IDUsuario_IDUsFonpro" ON asiento USING btree (usuarioid);


--
-- TOC entry 2490 (class 1259 OID 21044)
-- Dependencies: 174 3036
-- Name: FKI_BaCuenta_Bancos_IDBanco; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_BaCuenta_Bancos_IDBanco" ON bacuenta USING btree (bancoid);


--
-- TOC entry 2491 (class 1259 OID 21045)
-- Dependencies: 174 3036
-- Name: FKI_BaCuenta_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_BaCuenta_UsFonpro_IDUsuario_IDUsFonpro" ON bacuenta USING btree (usuarioid);


--
-- TOC entry 2496 (class 1259 OID 21046)
-- Dependencies: 176 3036
-- Name: FKI_Bancos_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Bancos_UsFonpro_IDUsuario_IDUsFonpro" ON bancos USING btree (usuarioid);


--
-- TOC entry 2499 (class 1259 OID 21047)
-- Dependencies: 178 3036
-- Name: FKI_CalPagoD_CalPago_IDCalPago; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_CalPagoD_CalPago_IDCalPago" ON calpagod USING btree (calpagoid);


--
-- TOC entry 2500 (class 1259 OID 21048)
-- Dependencies: 178 3036
-- Name: FKI_CalPagoD_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_CalPagoD_UsFonpro_IDUsuario_IDUsFonpro" ON calpagod USING btree (usuarioid);


--
-- TOC entry 2507 (class 1259 OID 21049)
-- Dependencies: 180 3036
-- Name: FKI_CalPago_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_CalPago_UsFonpro_IDUsuario_IDUsFonpro" ON calpago USING btree (usuarioid);


--
-- TOC entry 2508 (class 1259 OID 21050)
-- Dependencies: 180 3036
-- Name: FKI_CalPagos_TiPeGrav_IDTiPeGrav; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_CalPagos_TiPeGrav_IDTiPeGrav" ON calpago USING btree (tipegravid);


--
-- TOC entry 2514 (class 1259 OID 21051)
-- Dependencies: 182 3036
-- Name: FKI_Cargos_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Cargos_UsFonpro_IDUsuario_IDUsFonpro" ON cargos USING btree (usuarioid);


--
-- TOC entry 2519 (class 1259 OID 21052)
-- Dependencies: 184 3036
-- Name: FKI_Ciudades_Estados_IDEstado; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Ciudades_Estados_IDEstado" ON ciudades USING btree (estadoid);


--
-- TOC entry 2520 (class 1259 OID 21053)
-- Dependencies: 184 3036
-- Name: FKI_Ciudades_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Ciudades_UsFonpro_IDUsuario_IDUsFonpro" ON ciudades USING btree (usuarioid);


--
-- TOC entry 2525 (class 1259 OID 21054)
-- Dependencies: 186 3036
-- Name: FKI_ConUsuCo_ConUsu_IDConUsu; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_ConUsuCo_ConUsu_IDConUsu" ON conusuco USING btree (conusuid);


--
-- TOC entry 2526 (class 1259 OID 21055)
-- Dependencies: 186 3036
-- Name: FKI_ConUsuCo_Contribu_IDContribu; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_ConUsuCo_Contribu_IDContribu" ON conusuco USING btree (contribuid);


--
-- TOC entry 2529 (class 1259 OID 21056)
-- Dependencies: 188 3036
-- Name: FKI_ConUsuTi_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_ConUsuTi_UsFonpro_IDUsuario_IDUsFonpro" ON conusuti USING btree (usuarioid);


--
-- TOC entry 2534 (class 1259 OID 21057)
-- Dependencies: 190 3036
-- Name: FKI_ConUsuTo_ConUsu_IDConUsu; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_ConUsuTo_ConUsu_IDConUsu" ON conusuto USING btree (conusuid);


--
-- TOC entry 2541 (class 1259 OID 21058)
-- Dependencies: 192 3036
-- Name: FKI_ConUsu_ConUsuTi_IDConUsuTi; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_ConUsu_ConUsuTi_IDConUsuTi" ON conusu USING btree (conusutiid);


--
-- TOC entry 2542 (class 1259 OID 21059)
-- Dependencies: 192 3036
-- Name: FKI_ConUsu_PregSecr_IDPregSecr; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_ConUsu_PregSecr_IDPregSecr" ON conusu USING btree (pregsecrid);


--
-- TOC entry 2543 (class 1259 OID 21060)
-- Dependencies: 192 3036
-- Name: FKI_ConUsu_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_ConUsu_UsFonpro_IDUsuario_IDUsFonpro" ON conusu USING btree (usuarioid);


--
-- TOC entry 2703 (class 1259 OID 21061)
-- Dependencies: 232 3036
-- Name: FKI_ContribuTi_Contribu_ContribuID_ID; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_ContribuTi_Contribu_ContribuID_ID" ON contributi USING btree (contribuid);


--
-- TOC entry 2704 (class 1259 OID 21062)
-- Dependencies: 232 3036
-- Name: FKI_ContribuTi_TipoCont_TipoContID_ID; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_ContribuTi_TipoCont_TipoContID_ID" ON contributi USING btree (tipocontid);


--
-- TOC entry 2553 (class 1259 OID 21063)
-- Dependencies: 194 3036
-- Name: FKI_Contribu_ActiEcon_IDActiEcon; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Contribu_ActiEcon_IDActiEcon" ON contribu USING btree (actieconid);


--
-- TOC entry 2554 (class 1259 OID 21064)
-- Dependencies: 194 3036
-- Name: FKI_Contribu_Ciudades_IDCiudad; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Contribu_Ciudades_IDCiudad" ON contribu USING btree (ciudadid);


--
-- TOC entry 2555 (class 1259 OID 21065)
-- Dependencies: 194 3036
-- Name: FKI_Contribu_ConUsu_UsuarioID_ID; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Contribu_ConUsu_UsuarioID_ID" ON contribu USING btree (usuarioid);


--
-- TOC entry 2556 (class 1259 OID 21066)
-- Dependencies: 194 3036
-- Name: FKI_Contribu_Estados_IDEstado; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Contribu_Estados_IDEstado" ON contribu USING btree (estadoid);


--
-- TOC entry 2707 (class 1259 OID 21067)
-- Dependencies: 234 3036
-- Name: FKI_CtaConta_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_CtaConta_UsFonpro_IDUsuario_IDUsFonpro" ON ctaconta USING btree (usuarioid);


--
-- TOC entry 2564 (class 1259 OID 21068)
-- Dependencies: 196 3036
-- Name: FKI_Declara_Asiento_IDAsiento; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Declara_Asiento_IDAsiento" ON declara USING btree (asientoid);


--
-- TOC entry 2565 (class 1259 OID 21070)
-- Dependencies: 196 3036
-- Name: FKI_Declara_PlaSustID_ID; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Declara_PlaSustID_ID" ON declara USING btree (plasustid);


--
-- TOC entry 2566 (class 1259 OID 21071)
-- Dependencies: 196 3036
-- Name: FKI_Declara_RepLegal_IDRepLegal; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Declara_RepLegal_IDRepLegal" ON declara USING btree (replegalid);


--
-- TOC entry 2567 (class 1259 OID 21072)
-- Dependencies: 196 3036
-- Name: FKI_Declara_TDeclara_IDTDeclara; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Declara_TDeclara_IDTDeclara" ON declara USING btree (tdeclaraid);


--
-- TOC entry 2568 (class 1259 OID 21073)
-- Dependencies: 196 3036
-- Name: FKI_Declara_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Declara_UsFonpro_IDUsuario_IDUsFonpro" ON declara USING btree (usuarioid);


--
-- TOC entry 2712 (class 1259 OID 21074)
-- Dependencies: 235 3036
-- Name: FKI_Document_UsFonpro_UsFonproID_ID; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Document_UsFonpro_UsFonproID_ID" ON document USING btree (usfonproid);


--
-- TOC entry 2587 (class 1259 OID 21075)
-- Dependencies: 200 3036
-- Name: FKI_EntidadD_Entidad_IDEntidad; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_EntidadD_Entidad_IDEntidad" ON entidadd USING btree (entidadid);


--
-- TOC entry 2603 (class 1259 OID 21076)
-- Dependencies: 204 3036
-- Name: FKI_Estados_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Estados_UsFonpro_IDUsuario_IDUsFonpro" ON estados USING btree (usuarioid);


--
-- TOC entry 2608 (class 1259 OID 21077)
-- Dependencies: 206 3036
-- Name: FKI_PerUsuD_EndidadD_IDEntidadD; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_PerUsuD_EndidadD_IDEntidadD" ON perusud USING btree (entidaddid);


--
-- TOC entry 2609 (class 1259 OID 21078)
-- Dependencies: 206 3036
-- Name: FKI_PerUsuD_PerUsu_IDPerUsu; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_PerUsuD_PerUsu_IDPerUsu" ON perusud USING btree (perusuid);


--
-- TOC entry 2610 (class 1259 OID 21079)
-- Dependencies: 206 3036
-- Name: FKI_PerUsuD_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_PerUsuD_UsFonpro_IDUsuario_IDUsFonpro" ON perusud USING btree (usuarioid);


--
-- TOC entry 2615 (class 1259 OID 21080)
-- Dependencies: 208 3036
-- Name: FKI_PerUsu_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_PerUsu_UsFonpro_IDUsuario_IDUsFonpro" ON perusu USING btree (usuarioid);


--
-- TOC entry 2620 (class 1259 OID 21081)
-- Dependencies: 210 3036
-- Name: FKI_PregSecr_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_PregSecr_UsFonpro_IDUsuario_IDUsFonpro" ON pregsecr USING btree (usuarioid);


--
-- TOC entry 2625 (class 1259 OID 21082)
-- Dependencies: 212 3036
-- Name: FKI_RepLegal_IDCiudad; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_RepLegal_IDCiudad" ON replegal USING btree (ciudadid);


--
-- TOC entry 2626 (class 1259 OID 21083)
-- Dependencies: 212 3036
-- Name: FKI_RepLegal_IDContribu; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_RepLegal_IDContribu" ON replegal USING btree (contribuid);


--
-- TOC entry 2627 (class 1259 OID 21084)
-- Dependencies: 212 3036
-- Name: FKI_RepLegal_IDEstado; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_RepLegal_IDEstado" ON replegal USING btree (estadoid);


--
-- TOC entry 2628 (class 1259 OID 21085)
-- Dependencies: 212 3036
-- Name: FKI_RepLegal_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_RepLegal_UsFonpro_IDUsuario_IDUsFonpro" ON replegal USING btree (usuarioid);


--
-- TOC entry 2636 (class 1259 OID 21086)
-- Dependencies: 214 3036
-- Name: FKI_TDeclara_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TDeclara_UsFonpro_IDUsuario_IDUsFonpro" ON tdeclara USING btree (usuarioid);


--
-- TOC entry 2641 (class 1259 OID 21087)
-- Dependencies: 216 3036
-- Name: FKI_TiPeGrav_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TiPeGrav_UsFonpro_IDUsuario_IDUsFonpro" ON tipegrav USING btree (usuarioid);


--
-- TOC entry 2646 (class 1259 OID 21088)
-- Dependencies: 218 3036
-- Name: FKI_TipoCont_TiPeGrav_IDTiPeGrav; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TipoCont_TiPeGrav_IDTiPeGrav" ON tipocont USING btree (tipegravid);


--
-- TOC entry 2647 (class 1259 OID 21089)
-- Dependencies: 218 3036
-- Name: FKI_TipoCont_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TipoCont_UsFonpro_IDUsuario_IDUsFonpro" ON tipocont USING btree (usuarioid);


--
-- TOC entry 2729 (class 1259 OID 21090)
-- Dependencies: 238 3036
-- Name: FKI_TmpContri_ActiEcon_IDActiEcon; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TmpContri_ActiEcon_IDActiEcon" ON tmpcontri USING btree (actieconid);


--
-- TOC entry 2730 (class 1259 OID 21091)
-- Dependencies: 238 3036
-- Name: FKI_TmpContri_Ciudades_IDCiudad; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TmpContri_Ciudades_IDCiudad" ON tmpcontri USING btree (ciudadid);


--
-- TOC entry 2731 (class 1259 OID 21092)
-- Dependencies: 238 3036
-- Name: FKI_TmpContri_Contribu_IDContribu; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TmpContri_Contribu_IDContribu" ON tmpcontri USING btree (id);


--
-- TOC entry 2732 (class 1259 OID 21093)
-- Dependencies: 238 3036
-- Name: FKI_TmpContri_Estados_IDEstado; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TmpContri_Estados_IDEstado" ON tmpcontri USING btree (estadoid);


--
-- TOC entry 2733 (class 1259 OID 21094)
-- Dependencies: 238 3036
-- Name: FKI_TmpContri_TipoCont_IDTipoCont; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TmpContri_TipoCont_IDTipoCont" ON tmpcontri USING btree (tipocontid);


--
-- TOC entry 2739 (class 1259 OID 21095)
-- Dependencies: 239 3036
-- Name: FKI_TmpReLegal_IDCiudad; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TmpReLegal_IDCiudad" ON tmprelegal USING btree (ciudadid);


--
-- TOC entry 2740 (class 1259 OID 21096)
-- Dependencies: 239 3036
-- Name: FKI_TmpReLegal_IDContribu; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TmpReLegal_IDContribu" ON tmprelegal USING btree (contribuid);


--
-- TOC entry 2741 (class 1259 OID 21097)
-- Dependencies: 239 3036
-- Name: FKI_TmpReLegal_IDEstado; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TmpReLegal_IDEstado" ON tmprelegal USING btree (estadoid);


--
-- TOC entry 2652 (class 1259 OID 21098)
-- Dependencies: 220 3036
-- Name: FKI_UndTrib_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_UndTrib_UsFonpro_IDUsuario_IDUsFonpro" ON undtrib USING btree (usuarioid);


--
-- TOC entry 2664 (class 1259 OID 21099)
-- Dependencies: 224 3036
-- Name: FKI_UsFonPro_PregSecr_IDPregSecr; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_UsFonPro_PregSecr_IDPregSecr" ON usfonpro USING btree (pregsecrid);


--
-- TOC entry 2657 (class 1259 OID 21100)
-- Dependencies: 222 3036
-- Name: FKI_UsFonpTo_UsFonpro_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_UsFonpTo_UsFonpro_IDUsFonpro" ON usfonpto USING btree (usfonproid);


--
-- TOC entry 2665 (class 1259 OID 21101)
-- Dependencies: 224 3036
-- Name: FKI_UsFonpro_Cargos_IDCargo; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_UsFonpro_Cargos_IDCargo" ON usfonpro USING btree (cargoid);


--
-- TOC entry 2666 (class 1259 OID 21102)
-- Dependencies: 224 3036
-- Name: FKI_UsFonpro_Departam_IDDepartam; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_UsFonpro_Departam_IDDepartam" ON usfonpro USING btree (departamid);


--
-- TOC entry 2667 (class 1259 OID 21103)
-- Dependencies: 224 3036
-- Name: FKI_UsFonpro_PerUsu_IDPerUsu; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_UsFonpro_PerUsu_IDPerUsu" ON usfonpro USING btree (perusuid);


--
-- TOC entry 2717 (class 1259 OID 21104)
-- Dependencies: 237 3036
-- Name: FKI_tmpAccioni_IDContribu; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_tmpAccioni_IDContribu" ON tmpaccioni USING btree (contribuid);


--
-- TOC entry 2675 (class 1259 OID 21105)
-- Dependencies: 226 3036
-- Name: IX_Accionis_Apellido; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Accionis_Apellido" ON accionis USING btree (apellido);


--
-- TOC entry 2676 (class 1259 OID 21106)
-- Dependencies: 226 3036
-- Name: IX_Accionis_Ci; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Accionis_Ci" ON accionis USING btree (ci);


--
-- TOC entry 2677 (class 1259 OID 21107)
-- Dependencies: 226 3036
-- Name: IX_Accionis_Nombre; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Accionis_Nombre" ON accionis USING btree (nombre);


--
-- TOC entry 2477 (class 1259 OID 21108)
-- Dependencies: 169 3036
-- Name: IX_AlicImp_Ano; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_AlicImp_Ano" ON alicimp USING btree (ano);


--
-- TOC entry 2485 (class 1259 OID 21109)
-- Dependencies: 171 3036
-- Name: IX_AsientoD_Fecha; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_AsientoD_Fecha" ON asientod USING btree (fecha);


--
-- TOC entry 2684 (class 1259 OID 21110)
-- Dependencies: 227 3036
-- Name: IX_Asiento_Ano; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Asiento_Ano" ON asiento USING btree (ano);


--
-- TOC entry 2685 (class 1259 OID 21111)
-- Dependencies: 227 3036
-- Name: IX_Asiento_Cerrado; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Asiento_Cerrado" ON asiento USING btree (cerrado);


--
-- TOC entry 2686 (class 1259 OID 21112)
-- Dependencies: 227 3036
-- Name: IX_Asiento_Fecha; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Asiento_Fecha" ON asiento USING btree (fecha);


--
-- TOC entry 2687 (class 1259 OID 21113)
-- Dependencies: 227 3036
-- Name: IX_Asiento_Mes; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Asiento_Mes" ON asiento USING btree (mes);


--
-- TOC entry 2688 (class 1259 OID 21114)
-- Dependencies: 227 3036
-- Name: IX_Asiento_NuAsiento; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Asiento_NuAsiento" ON asiento USING btree (nuasiento);


--
-- TOC entry 2509 (class 1259 OID 21115)
-- Dependencies: 180 3036
-- Name: IX_CalPagos_Ano; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_CalPagos_Ano" ON calpago USING btree (ano);


--
-- TOC entry 2544 (class 1259 OID 21116)
-- Dependencies: 192 3036
-- Name: IX_ConUsu_Password; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_ConUsu_Password" ON conusu USING btree (password);


--
-- TOC entry 2557 (class 1259 OID 21117)
-- Dependencies: 194 3036
-- Name: IX_Contribu_DenComerci; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Contribu_DenComerci" ON contribu USING btree (dencomerci);


--
-- TOC entry 2569 (class 1259 OID 21118)
-- Dependencies: 196 3036
-- Name: IX_Declara_FechaConci; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Declara_FechaConci" ON declara USING btree (fechaconci);


--
-- TOC entry 2570 (class 1259 OID 21119)
-- Dependencies: 196 3036
-- Name: IX_Declara_FechaElab; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Declara_FechaElab" ON declara USING btree (fechaelab);


--
-- TOC entry 2571 (class 1259 OID 21120)
-- Dependencies: 196 3036
-- Name: IX_Declara_FechaFin; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Declara_FechaFin" ON declara USING btree (fechafin);


--
-- TOC entry 2572 (class 1259 OID 21121)
-- Dependencies: 196 3036
-- Name: IX_Declara_FechaIni; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Declara_FechaIni" ON declara USING btree (fechaini);


--
-- TOC entry 2573 (class 1259 OID 21122)
-- Dependencies: 196 3036
-- Name: IX_Declara_FechaPago; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Declara_FechaPago" ON declara USING btree (fechapago);


--
-- TOC entry 2588 (class 1259 OID 21123)
-- Dependencies: 200 3036
-- Name: IX_EntidadD_Accion; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_EntidadD_Accion" ON entidadd USING btree (accion);


--
-- TOC entry 2589 (class 1259 OID 21124)
-- Dependencies: 200 3036
-- Name: IX_EntidadD_Nombre; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_EntidadD_Nombre" ON entidadd USING btree (nombre);


--
-- TOC entry 2590 (class 1259 OID 21125)
-- Dependencies: 200 3036
-- Name: IX_EntidadD_Orden; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_EntidadD_Orden" ON entidadd USING btree (orden);


--
-- TOC entry 2629 (class 1259 OID 21126)
-- Dependencies: 212 3036
-- Name: IX_RepLegal_Apellido; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_RepLegal_Apellido" ON replegal USING btree (apellido);


--
-- TOC entry 2630 (class 1259 OID 21127)
-- Dependencies: 212 3036
-- Name: IX_RepLegal_Ci; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_RepLegal_Ci" ON replegal USING btree (ci);


--
-- TOC entry 2631 (class 1259 OID 21128)
-- Dependencies: 212 3036
-- Name: IX_RepLegal_Nombre; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_RepLegal_Nombre" ON replegal USING btree (nombre);


--
-- TOC entry 2734 (class 1259 OID 21129)
-- Dependencies: 238 3036
-- Name: IX_TmpContri_DenComerci; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_TmpContri_DenComerci" ON tmpcontri USING btree (dencomerci);


--
-- TOC entry 2742 (class 1259 OID 21130)
-- Dependencies: 239 3036
-- Name: IX_TmpReLegalNombre; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_TmpReLegalNombre" ON tmprelegal USING btree (nombre);


--
-- TOC entry 2743 (class 1259 OID 21131)
-- Dependencies: 239 3036
-- Name: IX_TmpReLegal_Apellido; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_TmpReLegal_Apellido" ON tmprelegal USING btree (apellido);


--
-- TOC entry 2744 (class 1259 OID 21132)
-- Dependencies: 239 3036
-- Name: IX_TmpReLegal_Ci; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_TmpReLegal_Ci" ON tmprelegal USING btree (ci);


--
-- TOC entry 2668 (class 1259 OID 21133)
-- Dependencies: 224 3036
-- Name: IX_UsFonPro_Password; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_UsFonPro_Password" ON usfonpro USING btree (password);


--
-- TOC entry 2718 (class 1259 OID 21134)
-- Dependencies: 237 3036
-- Name: IX_tmpAccioni_Apellido; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_tmpAccioni_Apellido" ON tmpaccioni USING btree (apellido);


--
-- TOC entry 2719 (class 1259 OID 21135)
-- Dependencies: 237 3036
-- Name: IX_tmpAccioni_Ci; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_tmpAccioni_Ci" ON tmpaccioni USING btree (ci);


--
-- TOC entry 2720 (class 1259 OID 21136)
-- Dependencies: 237 3036
-- Name: IX_tmpAccioni_Nombre; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_tmpAccioni_Nombre" ON tmpaccioni USING btree (nombre);


--
-- TOC entry 2580 (class 1259 OID 21137)
-- Dependencies: 198 3036
-- Name: fki_FL_Departam_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "fki_FL_Departam_UsFonpro_IDUsuario_IDUsFonpro" ON departam USING btree (usuarioid);


SET search_path = historial, pg_catalog;

--
-- TOC entry 2747 (class 1259 OID 21138)
-- Dependencies: 240 3036
-- Name: IX_Accion; Type: INDEX; Schema: historial; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Accion" ON bitacora USING btree (accion);


--
-- TOC entry 2748 (class 1259 OID 21139)
-- Dependencies: 240 3036
-- Name: IX_Fecha; Type: INDEX; Schema: historial; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Fecha" ON bitacora USING btree (fecha);


--
-- TOC entry 2749 (class 1259 OID 21140)
-- Dependencies: 240 3036
-- Name: IX_IDUsuario; Type: INDEX; Schema: historial; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_IDUsuario" ON bitacora USING btree (idusuario);


--
-- TOC entry 2750 (class 1259 OID 21141)
-- Dependencies: 240 3036
-- Name: IX_Tabla; Type: INDEX; Schema: historial; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Tabla" ON bitacora USING btree (tabla);


--
-- TOC entry 2751 (class 1259 OID 21142)
-- Dependencies: 240 3036
-- Name: IX_ValDelID; Type: INDEX; Schema: historial; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_ValDelID" ON bitacora USING btree (valdelid);


SET search_path = datos, pg_catalog;

--
-- TOC entry 2328 (class 2618 OID 21648)
-- Dependencies: 246 246 246 244 244 244 244 242 242 242 242 242 224 224 224 224 248 2670 248 248 253 3036
-- Name: _RETURN; Type: RULE; Schema: datos; Owner: postgres
--

CREATE RULE "_RETURN" AS ON SELECT TO view_modulo_usuario_contribuyente_permiso DO INSTEAD SELECT usu.id, usu.nombre, rol.str_rol, per.id_modulo, mod.str_nombre, mod.str_enlace, max(per.int_permiso) AS int_permiso, CASE WHEN (mod.id_padre IS NULL) THEN (mod.id_modulo * 10) ELSE ((mod.id_padre * 10) + mod.id_modulo) END AS int_orden, CASE WHEN (mod.id_padre IS NULL) THEN (0)::bigint ELSE mod.id_padre END AS id_padre FROM ((((usfonpro usu JOIN seg.tbl_rol_usuario rus ON ((usu.id = rus.id_usuario))) JOIN seg.tbl_rol rol ON ((rus.id_rol = rol.id_rol))) JOIN seg.tbl_permiso per ON ((rol.id_rol = per.id_rol))) JOIN seg.tbl_modulo mod ON ((per.id_modulo = mod.id_modulo))) WHERE (((((NOT usu.inactivo) AND (NOT rus.bln_borrado)) AND (NOT rol.bln_borrado)) AND (NOT per.bln_borrado)) AND (NOT mod.bln_borrado)) GROUP BY usu.id, usu.login, rol.str_rol, per.id_modulo, mod.str_nombre, mod.str_enlace, mod.id_padre, mod.id_modulo;


SET search_path = seg, pg_catalog;

--
-- TOC entry 2329 (class 2618 OID 21653)
-- Dependencies: 244 224 224 224 224 242 242 242 242 242 244 244 244 246 246 246 248 248 248 2670 254 3036
-- Name: _RETURN; Type: RULE; Schema: seg; Owner: postgres
--

CREATE RULE "_RETURN" AS ON SELECT TO view_modulo_usuario_permiso DO INSTEAD SELECT usu.id, usu.nombre, rol.str_rol, per.id_modulo, mod.str_nombre, mod.str_enlace, max(per.int_permiso) AS int_permiso, CASE WHEN (mod.id_padre IS NULL) THEN (mod.id_modulo * 10) ELSE ((mod.id_padre * 10) + mod.id_modulo) END AS int_orden, CASE WHEN (mod.id_padre IS NULL) THEN (0)::bigint ELSE mod.id_padre END AS id_padre FROM ((((datos.usfonpro usu JOIN tbl_rol_usuario rus ON ((usu.id = rus.id_usuario))) JOIN tbl_rol rol ON ((rus.id_rol = rol.id_rol))) JOIN tbl_permiso per ON ((rol.id_rol = per.id_rol))) JOIN tbl_modulo mod ON ((per.id_modulo = mod.id_modulo))) WHERE (((((NOT usu.inactivo) AND (NOT rus.bln_borrado)) AND (NOT rol.bln_borrado)) AND (NOT per.bln_borrado)) AND (NOT mod.bln_borrado)) GROUP BY usu.id, usu.login, rol.str_rol, per.id_modulo, mod.str_nombre, mod.str_enlace, mod.id_padre, mod.id_modulo;


SET search_path = "segContribu", pg_catalog;

--
-- TOC entry 2330 (class 2618 OID 22893)
-- Dependencies: 255 192 192 257 257 258 258 258 2546 256 192 257 256 256 256 255 255 255 255 265 3036
-- Name: _RETURN; Type: RULE; Schema: segContribu; Owner: postgres
--

CREATE RULE "_RETURN" AS ON SELECT TO view_modulo_usuariocontribuyente_permiso DO INSTEAD SELECT usu.id, usu.nombre, rol.str_rol, per.id_modulo, mod.str_nombre, mod.str_enlace, max(per.int_permiso) AS int_permiso, CASE WHEN (mod.id_padre IS NULL) THEN (mod.id_modulo * 10) ELSE ((mod.id_padre * 10) + mod.id_modulo) END AS int_orden, CASE WHEN (mod.id_padre IS NULL) THEN (0)::bigint ELSE mod.id_padre END AS id_padre FROM ((((datos.conusu usu JOIN tbl_rol_usuario_contribu rus ON ((usu.id = rus.id_usuario))) JOIN tbl_rol_contribu rol ON ((rus.id_rol = rol.id_rol))) JOIN tbl_permiso_contribu per ON ((rol.id_rol = per.id_rol))) JOIN tbl_modulo_contribu mod ON ((per.id_modulo = mod.id_modulo))) WHERE ((((NOT rus.bln_borrado) AND (NOT rol.bln_borrado)) AND (NOT per.bln_borrado)) AND (NOT mod.bln_borrado)) GROUP BY usu.id, usu.login, rol.str_rol, per.id_modulo, mod.str_nombre, mod.str_enlace, mod.id_padre, mod.id_modulo;


SET search_path = datos, pg_catalog;

--
-- TOC entry 2915 (class 2620 OID 21143)
-- Dependencies: 227 227 302 227 3036
-- Name: TG_Asiendo_ActualizaSaldo; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_Asiendo_ActualizaSaldo" BEFORE UPDATE OF debe, haber ON asiento FOR EACH ROW EXECUTE PROCEDURE "tf_Asiento_ActualizaSaldo"();


--
-- TOC entry 3647 (class 0 OID 0)
-- Dependencies: 2915
-- Name: TRIGGER "TG_Asiendo_ActualizaSaldo" ON asiento; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_Asiendo_ActualizaSaldo" ON asiento IS 'Trigger que actualiza el saldo del asiento';


--
-- TOC entry 2892 (class 2620 OID 21144)
-- Dependencies: 171 300 3036
-- Name: TG_AsientoD_ActualizaDebeHaber_Asiento; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_AsientoD_ActualizaDebeHaber_Asiento" AFTER INSERT OR DELETE OR UPDATE ON asientod FOR EACH ROW EXECUTE PROCEDURE "tf_AsiendoD_ActualizaDebeHaber_Asiento"();


--
-- TOC entry 3648 (class 0 OID 0)
-- Dependencies: 2892
-- Name: TRIGGER "TG_AsientoD_ActualizaDebeHaber_Asiento" ON asientod; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_AsientoD_ActualizaDebeHaber_Asiento" ON asientod IS 'Trigger que actualiza el debe y haber de la tabla de asiento';


--
-- TOC entry 2893 (class 2620 OID 21145)
-- Dependencies: 171 303 3036
-- Name: TG_AsientoD_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_AsientoD_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON asientod FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();


--
-- TOC entry 3649 (class 0 OID 0)
-- Dependencies: 2893
-- Name: TRIGGER "TG_AsientoD_Bitacora" ON asientod; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_AsientoD_Bitacora" ON asientod IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 2918 (class 2620 OID 21146)
-- Dependencies: 303 228 3036
-- Name: TG_AsientoM_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_AsientoM_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON asientom FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();


--
-- TOC entry 3650 (class 0 OID 0)
-- Dependencies: 2918
-- Name: TRIGGER "TG_AsientoM_Bitacora" ON asientom; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_AsientoM_Bitacora" ON asientom IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 2916 (class 2620 OID 21147)
-- Dependencies: 227 227 301 3036
-- Name: TG_Asiento_Actualiza_Mes_Ano; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_Asiento_Actualiza_Mes_Ano" BEFORE INSERT OR UPDATE OF fecha ON asiento FOR EACH ROW EXECUTE PROCEDURE "tf_Asiento_ActualizaPeriodo"();


--
-- TOC entry 2917 (class 2620 OID 21148)
-- Dependencies: 227 303 3036
-- Name: TG_Asiento_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_Asiento_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON asiento FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();


--
-- TOC entry 3651 (class 0 OID 0)
-- Dependencies: 2917
-- Name: TRIGGER "TG_Asiento_Bitacora" ON asiento; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_Asiento_Bitacora" ON asiento IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 2894 (class 2620 OID 21149)
-- Dependencies: 174 303 3036
-- Name: TG_BaCuenta_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_BaCuenta_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON bacuenta FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();


--
-- TOC entry 3652 (class 0 OID 0)
-- Dependencies: 2894
-- Name: TRIGGER "TG_BaCuenta_Bitacora" ON bacuenta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_BaCuenta_Bitacora" ON bacuenta IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 2895 (class 2620 OID 21150)
-- Dependencies: 176 303 3036
-- Name: TG_Bancos_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_Bancos_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON bancos FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();


--
-- TOC entry 3653 (class 0 OID 0)
-- Dependencies: 2895
-- Name: TRIGGER "TG_Bancos_Bitacora" ON bancos; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_Bancos_Bitacora" ON bancos IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 2898 (class 2620 OID 21151)
-- Dependencies: 182 303 3036
-- Name: TG_Cargos_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_Cargos_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON cargos FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();


--
-- TOC entry 3654 (class 0 OID 0)
-- Dependencies: 2898
-- Name: TRIGGER "TG_Cargos_Bitacora" ON cargos; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_Cargos_Bitacora" ON cargos IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 2901 (class 2620 OID 21152)
-- Dependencies: 192 303 3036
-- Name: TG_ConUsu_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_ConUsu_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON conusu FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE conusu DISABLE TRIGGER "TG_ConUsu_Bitacora";


--
-- TOC entry 3655 (class 0 OID 0)
-- Dependencies: 2901
-- Name: TRIGGER "TG_ConUsu_Bitacora" ON conusu; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_ConUsu_Bitacora" ON conusu IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 2919 (class 2620 OID 21153)
-- Dependencies: 234 303 3036
-- Name: TG_CtaConta_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_CtaConta_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON ctaconta FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();


--
-- TOC entry 3656 (class 0 OID 0)
-- Dependencies: 2919
-- Name: TRIGGER "TG_CtaConta_Bitacora" ON ctaconta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_CtaConta_Bitacora" ON ctaconta IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 2903 (class 2620 OID 21154)
-- Dependencies: 198 303 3036
-- Name: TG_Departam_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_Departam_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON departam FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();


--
-- TOC entry 3657 (class 0 OID 0)
-- Dependencies: 2903
-- Name: TRIGGER "TG_Departam_Bitacora" ON departam; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_Departam_Bitacora" ON departam IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 2905 (class 2620 OID 21155)
-- Dependencies: 303 206 3036
-- Name: TG_PerUsuD_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_PerUsuD_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON perusud FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();


--
-- TOC entry 3658 (class 0 OID 0)
-- Dependencies: 2905
-- Name: TRIGGER "TG_PerUsuD_Bitacora" ON perusud; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_PerUsuD_Bitacora" ON perusud IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 2906 (class 2620 OID 21156)
-- Dependencies: 208 303 3036
-- Name: TG_PerUsu_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_PerUsu_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON perusu FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();


--
-- TOC entry 3659 (class 0 OID 0)
-- Dependencies: 2906
-- Name: TRIGGER "TG_PerUsu_Bitacora" ON perusu; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_PerUsu_Bitacora" ON perusu IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 2907 (class 2620 OID 21157)
-- Dependencies: 303 210 3036
-- Name: TG_PregSecr_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_PregSecr_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON pregsecr FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE pregsecr DISABLE TRIGGER "TG_PregSecr_Bitacora";


--
-- TOC entry 3660 (class 0 OID 0)
-- Dependencies: 2907
-- Name: TRIGGER "TG_PregSecr_Bitacora" ON pregsecr; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_PregSecr_Bitacora" ON pregsecr IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 2909 (class 2620 OID 21158)
-- Dependencies: 303 214 3036
-- Name: TG_TDeclara_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_TDeclara_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON tdeclara FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE tdeclara DISABLE TRIGGER "TG_TDeclara_Bitacora";


--
-- TOC entry 3661 (class 0 OID 0)
-- Dependencies: 2909
-- Name: TRIGGER "TG_TDeclara_Bitacora" ON tdeclara; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_TDeclara_Bitacora" ON tdeclara IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 2912 (class 2620 OID 21159)
-- Dependencies: 220 303 3036
-- Name: TG_UndTrib_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_UndTrib_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON undtrib FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE undtrib DISABLE TRIGGER "TG_UndTrib_Bitacora";


--
-- TOC entry 3662 (class 0 OID 0)
-- Dependencies: 2912
-- Name: TRIGGER "TG_UndTrib_Bitacora" ON undtrib; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_UndTrib_Bitacora" ON undtrib IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 2913 (class 2620 OID 22974)
-- Dependencies: 303 224 224 224 224 224 224 224 224 224 224 224 224 224 3036
-- Name: TG_UsFonpro_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_UsFonpro_Bitacora" AFTER INSERT OR DELETE OR UPDATE OF id, login, password, nombre, email, telefofc, extension, departamid, cargoid, inactivo, pregsecrid, respuesta ON usfonpro FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE usfonpro DISABLE TRIGGER "TG_UsFonpro_Bitacora";


--
-- TOC entry 3663 (class 0 OID 0)
-- Dependencies: 2913
-- Name: TRIGGER "TG_UsFonpro_Bitacora" ON usfonpro; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_UsFonpro_Bitacora" ON usfonpro IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 2914 (class 2620 OID 21161)
-- Dependencies: 226 303 3036
-- Name: tg_Accionis_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_Accionis_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON accionis FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE accionis DISABLE TRIGGER "tg_Accionis_Bitacora";


--
-- TOC entry 3664 (class 0 OID 0)
-- Dependencies: 2914
-- Name: TRIGGER "tg_Accionis_Bitacora" ON accionis; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_Accionis_Bitacora" ON accionis IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 2890 (class 2620 OID 21162)
-- Dependencies: 167 303 3036
-- Name: tg_ActiEcon_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_ActiEcon_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON actiecon FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE actiecon DISABLE TRIGGER "tg_ActiEcon_Bitacora";


--
-- TOC entry 3665 (class 0 OID 0)
-- Dependencies: 2890
-- Name: TRIGGER "tg_ActiEcon_Bitacora" ON actiecon; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_ActiEcon_Bitacora" ON actiecon IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 2891 (class 2620 OID 21163)
-- Dependencies: 169 303 3036
-- Name: tg_AlicImp_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_AlicImp_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON alicimp FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE alicimp DISABLE TRIGGER "tg_AlicImp_Bitacora";


--
-- TOC entry 3666 (class 0 OID 0)
-- Dependencies: 2891
-- Name: TRIGGER "tg_AlicImp_Bitacora" ON alicimp; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_AlicImp_Bitacora" ON alicimp IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 2896 (class 2620 OID 21164)
-- Dependencies: 178 303 3036
-- Name: tg_CalPagoD_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_CalPagoD_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON calpagod FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE calpagod DISABLE TRIGGER "tg_CalPagoD_Bitacora";


--
-- TOC entry 3667 (class 0 OID 0)
-- Dependencies: 2896
-- Name: TRIGGER "tg_CalPagoD_Bitacora" ON calpagod; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_CalPagoD_Bitacora" ON calpagod IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 2897 (class 2620 OID 21165)
-- Dependencies: 303 180 3036
-- Name: tg_CalPago_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_CalPago_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON calpago FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE calpago DISABLE TRIGGER "tg_CalPago_Bitacora";


--
-- TOC entry 3668 (class 0 OID 0)
-- Dependencies: 2897
-- Name: TRIGGER "tg_CalPago_Bitacora" ON calpago; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_CalPago_Bitacora" ON calpago IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 2899 (class 2620 OID 21166)
-- Dependencies: 184 303 3036
-- Name: tg_Ciudades_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_Ciudades_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON ciudades FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE ciudades DISABLE TRIGGER "tg_Ciudades_Bitacora";


--
-- TOC entry 3669 (class 0 OID 0)
-- Dependencies: 2899
-- Name: TRIGGER "tg_Ciudades_Bitacora" ON ciudades; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_Ciudades_Bitacora" ON ciudades IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 2900 (class 2620 OID 21167)
-- Dependencies: 188 303 3036
-- Name: tg_ConUsuTi_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_ConUsuTi_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON conusuti FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE conusuti DISABLE TRIGGER "tg_ConUsuTi_Bitacora";


--
-- TOC entry 3670 (class 0 OID 0)
-- Dependencies: 2900
-- Name: TRIGGER "tg_ConUsuTi_Bitacora" ON conusuti; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_ConUsuTi_Bitacora" ON conusuti IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 2902 (class 2620 OID 21168)
-- Dependencies: 303 194 3036
-- Name: tg_Contribu_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_Contribu_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON contribu FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE contribu DISABLE TRIGGER "tg_Contribu_Bitacora";


--
-- TOC entry 3671 (class 0 OID 0)
-- Dependencies: 2902
-- Name: TRIGGER "tg_Contribu_Bitacora" ON contribu; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_Contribu_Bitacora" ON contribu IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 2904 (class 2620 OID 21169)
-- Dependencies: 204 303 3036
-- Name: tg_Estados_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_Estados_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON estados FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE estados DISABLE TRIGGER "tg_Estados_Bitacora";


--
-- TOC entry 3672 (class 0 OID 0)
-- Dependencies: 2904
-- Name: TRIGGER "tg_Estados_Bitacora" ON estados; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_Estados_Bitacora" ON estados IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 2908 (class 2620 OID 21170)
-- Dependencies: 212 303 3036
-- Name: tg_RepLegal_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_RepLegal_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON replegal FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE replegal DISABLE TRIGGER "tg_RepLegal_Bitacora";


--
-- TOC entry 3673 (class 0 OID 0)
-- Dependencies: 2908
-- Name: TRIGGER "tg_RepLegal_Bitacora" ON replegal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_RepLegal_Bitacora" ON replegal IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 2910 (class 2620 OID 21171)
-- Dependencies: 303 216 3036
-- Name: tg_TiPeGrav_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_TiPeGrav_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON tipegrav FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE tipegrav DISABLE TRIGGER "tg_TiPeGrav_Bitacora";


--
-- TOC entry 3674 (class 0 OID 0)
-- Dependencies: 2910
-- Name: TRIGGER "tg_TiPeGrav_Bitacora" ON tipegrav; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_TiPeGrav_Bitacora" ON tipegrav IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 2911 (class 2620 OID 21172)
-- Dependencies: 218 303 3036
-- Name: tg_TipoCont_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_TipoCont_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON tipocont FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE tipocont DISABLE TRIGGER "tg_TipoCont_Bitacora";


--
-- TOC entry 3675 (class 0 OID 0)
-- Dependencies: 2911
-- Name: TRIGGER "tg_TipoCont_Bitacora" ON tipocont; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_TipoCont_Bitacora" ON tipocont IS 'Trigger para insertar datos en la tabla de bitacoras';


SET search_path = seg, pg_catalog;

--
-- TOC entry 2920 (class 2620 OID 78895)
-- Dependencies: 305 282 3036
-- Name: ejecutaverificamodulo; Type: TRIGGER; Schema: seg; Owner: postgres
--

CREATE TRIGGER ejecutaverificamodulo BEFORE INSERT ON tbl_permiso_trampa FOR EACH ROW EXECUTE PROCEDURE verificaperfil();


SET search_path = datos, pg_catalog;

--
-- TOC entry 2854 (class 2606 OID 46556)
-- Dependencies: 2545 226 192 3036
-- Name: FK_Accionis_IDContribu; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY accionis
    ADD CONSTRAINT "FK_Accionis_IDContribu" FOREIGN KEY (contribuid) REFERENCES conusu(id) MATCH FULL;


--
-- TOC entry 2853 (class 2606 OID 21178)
-- Dependencies: 224 226 2669 3036
-- Name: FK_Accionis_UsFonpro_UsuarioID_ID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY accionis
    ADD CONSTRAINT "FK_Accionis_UsFonpro_UsuarioID_ID" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2796 (class 2606 OID 21183)
-- Dependencies: 224 167 2669 3036
-- Name: FK_ActiEcon_USFonpro_IDUsuario_IDUsFornpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY actiecon
    ADD CONSTRAINT "FK_ActiEcon_USFonpro_IDUsuario_IDUsFornpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2797 (class 2606 OID 21188)
-- Dependencies: 218 169 2648 3036
-- Name: FK_AlicImp_TipoCont_IDTipoCont; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY alicimp
    ADD CONSTRAINT "FK_AlicImp_TipoCont_IDTipoCont" FOREIGN KEY (tipocontid) REFERENCES tipocont(id) MATCH FULL;


--
-- TOC entry 2798 (class 2606 OID 21193)
-- Dependencies: 169 224 2669 3036
-- Name: FK_AlicImp_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY alicimp
    ADD CONSTRAINT "FK_AlicImp_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2799 (class 2606 OID 21198)
-- Dependencies: 227 171 2689 3036
-- Name: FK_AsientoD_Asiento_IDAsiento; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asientod
    ADD CONSTRAINT "FK_AsientoD_Asiento_IDAsiento" FOREIGN KEY (asientoid) REFERENCES asiento(id) MATCH FULL;


--
-- TOC entry 2800 (class 2606 OID 21203)
-- Dependencies: 234 171 2708 3036
-- Name: FK_AsientoD_CtaConta_Cuenta; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asientod
    ADD CONSTRAINT "FK_AsientoD_CtaConta_Cuenta" FOREIGN KEY (cuenta) REFERENCES ctaconta(cuenta) MATCH FULL;


--
-- TOC entry 2801 (class 2606 OID 21208)
-- Dependencies: 2669 224 171 3036
-- Name: FK_AsientoD_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asientod
    ADD CONSTRAINT "FK_AsientoD_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2858 (class 2606 OID 21213)
-- Dependencies: 230 2694 228 3036
-- Name: FK_AsientoMD_AsientoM_AsientoMID_ID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asientomd
    ADD CONSTRAINT "FK_AsientoMD_AsientoM_AsientoMID_ID" FOREIGN KEY (asientomid) REFERENCES asientom(id) MATCH FULL;


--
-- TOC entry 2859 (class 2606 OID 21218)
-- Dependencies: 230 2708 234 3036
-- Name: FK_AsientoMD_CtaConta_Cuenta; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asientomd
    ADD CONSTRAINT "FK_AsientoMD_CtaConta_Cuenta" FOREIGN KEY (cuenta) REFERENCES ctaconta(cuenta) MATCH FULL;


--
-- TOC entry 2860 (class 2606 OID 21223)
-- Dependencies: 2669 224 230 3036
-- Name: FK_AsientoMD_UsFonpro_UsuarioID_ID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asientomd
    ADD CONSTRAINT "FK_AsientoMD_UsFonpro_UsuarioID_ID" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2857 (class 2606 OID 21228)
-- Dependencies: 2669 224 228 3036
-- Name: FK_AsientoM_UsFonpro_UsuarioID_ID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asientom
    ADD CONSTRAINT "FK_AsientoM_UsFonpro_UsuarioID_ID" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2855 (class 2606 OID 21233)
-- Dependencies: 2669 227 224 3036
-- Name: FK_Asiento_UsFonpro_IDUsCierre_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asiento
    ADD CONSTRAINT "FK_Asiento_UsFonpro_IDUsCierre_IDUsFonpro" FOREIGN KEY (uscierreid) REFERENCES usfonpro(id);


--
-- TOC entry 2856 (class 2606 OID 21238)
-- Dependencies: 227 224 2669 3036
-- Name: FK_Asiento_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asiento
    ADD CONSTRAINT "FK_Asiento_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2802 (class 2606 OID 21243)
-- Dependencies: 2497 174 176 3036
-- Name: FK_BaCuenta_Bancos_IDBanco; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY bacuenta
    ADD CONSTRAINT "FK_BaCuenta_Bancos_IDBanco" FOREIGN KEY (bancoid) REFERENCES bancos(id) MATCH FULL;


--
-- TOC entry 2803 (class 2606 OID 21248)
-- Dependencies: 224 174 2669 3036
-- Name: FK_BaCuenta_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY bacuenta
    ADD CONSTRAINT "FK_BaCuenta_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2804 (class 2606 OID 21253)
-- Dependencies: 224 176 2669 3036
-- Name: FK_Bancos_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY bancos
    ADD CONSTRAINT "FK_Bancos_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2805 (class 2606 OID 21258)
-- Dependencies: 180 178 2510 3036
-- Name: FK_CalPagoD_CalPago_IDCalPago; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY calpagod
    ADD CONSTRAINT "FK_CalPagoD_CalPago_IDCalPago" FOREIGN KEY (calpagoid) REFERENCES calpago(id) MATCH FULL;


--
-- TOC entry 2806 (class 2606 OID 21263)
-- Dependencies: 2669 224 178 3036
-- Name: FK_CalPagoD_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY calpagod
    ADD CONSTRAINT "FK_CalPagoD_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2807 (class 2606 OID 21268)
-- Dependencies: 224 2669 180 3036
-- Name: FK_CalPago_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY calpago
    ADD CONSTRAINT "FK_CalPago_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2808 (class 2606 OID 21273)
-- Dependencies: 216 180 2642 3036
-- Name: FK_CalPagos_TiPeGrav_IDTiPeGrav; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY calpago
    ADD CONSTRAINT "FK_CalPagos_TiPeGrav_IDTiPeGrav" FOREIGN KEY (tipegravid) REFERENCES tipegrav(id) MATCH FULL;


--
-- TOC entry 2809 (class 2606 OID 21278)
-- Dependencies: 224 182 2669 3036
-- Name: FK_Cargos_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY cargos
    ADD CONSTRAINT "FK_Cargos_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2810 (class 2606 OID 21283)
-- Dependencies: 2604 204 184 3036
-- Name: FK_Ciudades_Estados_IDEstado; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY ciudades
    ADD CONSTRAINT "FK_Ciudades_Estados_IDEstado" FOREIGN KEY (estadoid) REFERENCES estados(id) MATCH FULL;


--
-- TOC entry 2811 (class 2606 OID 21288)
-- Dependencies: 2669 184 224 3036
-- Name: FK_Ciudades_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY ciudades
    ADD CONSTRAINT "FK_Ciudades_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2812 (class 2606 OID 21293)
-- Dependencies: 2545 186 192 3036
-- Name: FK_ConUsuCo_ConUsu_IDConUsu; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusuco
    ADD CONSTRAINT "FK_ConUsuCo_ConUsu_IDConUsu" FOREIGN KEY (conusuid) REFERENCES conusu(id) MATCH FULL;


--
-- TOC entry 2813 (class 2606 OID 21298)
-- Dependencies: 186 194 2558 3036
-- Name: FK_ConUsuCo_Contribu_IDContribu; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusuco
    ADD CONSTRAINT "FK_ConUsuCo_Contribu_IDContribu" FOREIGN KEY (contribuid) REFERENCES contribu(id) MATCH FULL;


--
-- TOC entry 2814 (class 2606 OID 21303)
-- Dependencies: 224 188 2669 3036
-- Name: FK_ConUsuTi_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusuti
    ADD CONSTRAINT "FK_ConUsuTi_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2815 (class 2606 OID 21308)
-- Dependencies: 192 2545 190 3036
-- Name: FK_ConUsuTo_ConUsu_IDConUsu; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusuto
    ADD CONSTRAINT "FK_ConUsuTo_ConUsu_IDConUsu" FOREIGN KEY (conusuid) REFERENCES conusu(id) MATCH FULL;


--
-- TOC entry 2816 (class 2606 OID 21313)
-- Dependencies: 188 192 2530 3036
-- Name: FK_ConUsu_ConUsuTi_IDConUsuTi; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusu
    ADD CONSTRAINT "FK_ConUsu_ConUsuTi_IDConUsuTi" FOREIGN KEY (conusutiid) REFERENCES conusuti(id) MATCH FULL;


--
-- TOC entry 2817 (class 2606 OID 21318)
-- Dependencies: 192 210 2621 3036
-- Name: FK_ConUsu_PregSecr_IDPregSecr; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusu
    ADD CONSTRAINT "FK_ConUsu_PregSecr_IDPregSecr" FOREIGN KEY (pregsecrid) REFERENCES pregsecr(id) MATCH FULL;


--
-- TOC entry 2818 (class 2606 OID 21323)
-- Dependencies: 2669 192 224 3036
-- Name: FK_ConUsu_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusu
    ADD CONSTRAINT "FK_ConUsu_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2861 (class 2606 OID 21328)
-- Dependencies: 194 232 2558 3036
-- Name: FK_ContribuTi_Contribu_ContribuID_ID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY contributi
    ADD CONSTRAINT "FK_ContribuTi_Contribu_ContribuID_ID" FOREIGN KEY (contribuid) REFERENCES contribu(id) MATCH FULL;


--
-- TOC entry 2862 (class 2606 OID 21333)
-- Dependencies: 218 2648 232 3036
-- Name: FK_ContribuTi_TipoCont_TipoContID_ID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY contributi
    ADD CONSTRAINT "FK_ContribuTi_TipoCont_TipoContID_ID" FOREIGN KEY (tipocontid) REFERENCES tipocont(id) MATCH FULL;


--
-- TOC entry 2819 (class 2606 OID 21338)
-- Dependencies: 167 2471 194 3036
-- Name: FK_Contribu_ActiEcon_IDActiEcon; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY contribu
    ADD CONSTRAINT "FK_Contribu_ActiEcon_IDActiEcon" FOREIGN KEY (actieconid) REFERENCES actiecon(id) MATCH FULL;


--
-- TOC entry 2820 (class 2606 OID 21343)
-- Dependencies: 184 194 2521 3036
-- Name: FK_Contribu_Ciudades_IDCiudad; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY contribu
    ADD CONSTRAINT "FK_Contribu_Ciudades_IDCiudad" FOREIGN KEY (ciudadid) REFERENCES ciudades(id) MATCH FULL;


--
-- TOC entry 2821 (class 2606 OID 21348)
-- Dependencies: 192 194 2545 3036
-- Name: FK_Contribu_ConUsu_UsuarioID_ID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY contribu
    ADD CONSTRAINT "FK_Contribu_ConUsu_UsuarioID_ID" FOREIGN KEY (usuarioid) REFERENCES conusu(id) MATCH FULL;


--
-- TOC entry 2822 (class 2606 OID 21353)
-- Dependencies: 2604 204 194 3036
-- Name: FK_Contribu_Estados_IDEstado; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY contribu
    ADD CONSTRAINT "FK_Contribu_Estados_IDEstado" FOREIGN KEY (estadoid) REFERENCES estados(id) MATCH FULL;


--
-- TOC entry 2863 (class 2606 OID 21358)
-- Dependencies: 224 234 2669 3036
-- Name: FK_CtaConta_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY ctaconta
    ADD CONSTRAINT "FK_CtaConta_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2823 (class 2606 OID 21363)
-- Dependencies: 2689 196 227 3036
-- Name: FK_Declara_Asiento_IDAsiento; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT "FK_Declara_Asiento_IDAsiento" FOREIGN KEY (asientoid) REFERENCES asiento(id);


--
-- TOC entry 2830 (class 2606 OID 77240)
-- Dependencies: 196 178 2501 3036
-- Name: FK_Declara_Calpagod_id; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT "FK_Declara_Calpagod_id" FOREIGN KEY (calpagodid) REFERENCES calpagod(id);


--
-- TOC entry 2824 (class 2606 OID 21373)
-- Dependencies: 196 196 2574 3036
-- Name: FK_Declara_PlaSustID_ID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT "FK_Declara_PlaSustID_ID" FOREIGN KEY (plasustid) REFERENCES declara(id);


--
-- TOC entry 2825 (class 2606 OID 21378)
-- Dependencies: 196 212 2632 3036
-- Name: FK_Declara_RepLegal_IDRepLegal; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT "FK_Declara_RepLegal_IDRepLegal" FOREIGN KEY (replegalid) REFERENCES replegal(id) MATCH FULL;


--
-- TOC entry 2826 (class 2606 OID 21383)
-- Dependencies: 196 214 2637 3036
-- Name: FK_Declara_TDeclara_IDTDeclara; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT "FK_Declara_TDeclara_IDTDeclara" FOREIGN KEY (tdeclaraid) REFERENCES tdeclara(id) MATCH FULL;


--
-- TOC entry 2827 (class 2606 OID 21388)
-- Dependencies: 196 224 2669 3036
-- Name: FK_Declara_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT "FK_Declara_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id);


--
-- TOC entry 2828 (class 2606 OID 46583)
-- Dependencies: 196 218 2648 3036
-- Name: FK_Declara_tipocontribuid; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT "FK_Declara_tipocontribuid" FOREIGN KEY (tipocontribuid) REFERENCES tipocont(id);


--
-- TOC entry 2864 (class 2606 OID 21393)
-- Dependencies: 235 224 2669 3036
-- Name: FK_Document_UsFonpro_UsFonproID_ID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY document
    ADD CONSTRAINT "FK_Document_UsFonpro_UsFonproID_ID" FOREIGN KEY (usfonproid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2832 (class 2606 OID 21398)
-- Dependencies: 200 202 2599 3036
-- Name: FK_EntidadD_Entidad_IDEntidad; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY entidadd
    ADD CONSTRAINT "FK_EntidadD_Entidad_IDEntidad" FOREIGN KEY (entidadid) REFERENCES entidad(id) MATCH FULL;


--
-- TOC entry 2833 (class 2606 OID 21403)
-- Dependencies: 204 224 2669 3036
-- Name: FK_Estados_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY estados
    ADD CONSTRAINT "FK_Estados_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2834 (class 2606 OID 21408)
-- Dependencies: 206 200 2591 3036
-- Name: FK_PerUsuD_EndidadD_IDEntidadD; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY perusud
    ADD CONSTRAINT "FK_PerUsuD_EndidadD_IDEntidadD" FOREIGN KEY (entidaddid) REFERENCES entidadd(id) MATCH FULL;


--
-- TOC entry 2835 (class 2606 OID 21413)
-- Dependencies: 206 208 2616 3036
-- Name: FK_PerUsuD_PerUsu_IDPerUsu; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY perusud
    ADD CONSTRAINT "FK_PerUsuD_PerUsu_IDPerUsu" FOREIGN KEY (perusuid) REFERENCES perusu(id) MATCH FULL;


--
-- TOC entry 2836 (class 2606 OID 21418)
-- Dependencies: 206 224 2669 3036
-- Name: FK_PerUsuD_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY perusud
    ADD CONSTRAINT "FK_PerUsuD_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2837 (class 2606 OID 21423)
-- Dependencies: 208 224 2669 3036
-- Name: FK_PerUsu_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY perusu
    ADD CONSTRAINT "FK_PerUsu_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2838 (class 2606 OID 21428)
-- Dependencies: 210 224 2669 3036
-- Name: FK_PregSecr_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY pregsecr
    ADD CONSTRAINT "FK_PregSecr_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2839 (class 2606 OID 21433)
-- Dependencies: 212 184 2521 3036
-- Name: FK_RepLegal_IDCiudad; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY replegal
    ADD CONSTRAINT "FK_RepLegal_IDCiudad" FOREIGN KEY (ciudadid) REFERENCES ciudades(id) MATCH FULL;


--
-- TOC entry 2840 (class 2606 OID 21438)
-- Dependencies: 212 194 2558 3036
-- Name: FK_RepLegal_IDContribu; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY replegal
    ADD CONSTRAINT "FK_RepLegal_IDContribu" FOREIGN KEY (contribuid) REFERENCES contribu(id) MATCH FULL;


--
-- TOC entry 2841 (class 2606 OID 21443)
-- Dependencies: 2604 204 212 3036
-- Name: FK_RepLegal_IDEstado; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY replegal
    ADD CONSTRAINT "FK_RepLegal_IDEstado" FOREIGN KEY (estadoid) REFERENCES estados(id) MATCH FULL;


--
-- TOC entry 2842 (class 2606 OID 21448)
-- Dependencies: 2669 224 212 3036
-- Name: FK_RepLegal_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY replegal
    ADD CONSTRAINT "FK_RepLegal_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2843 (class 2606 OID 21453)
-- Dependencies: 224 214 2669 3036
-- Name: FK_TDeclara_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tdeclara
    ADD CONSTRAINT "FK_TDeclara_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2844 (class 2606 OID 21458)
-- Dependencies: 224 216 2669 3036
-- Name: FK_TiPeGrav_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tipegrav
    ADD CONSTRAINT "FK_TiPeGrav_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2845 (class 2606 OID 21463)
-- Dependencies: 2642 216 218 3036
-- Name: FK_TipoCont_TiPeGrav_IDTiPeGrav; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tipocont
    ADD CONSTRAINT "FK_TipoCont_TiPeGrav_IDTiPeGrav" FOREIGN KEY (tipegravid) REFERENCES tipegrav(id) MATCH FULL;


--
-- TOC entry 2846 (class 2606 OID 21468)
-- Dependencies: 2669 218 224 3036
-- Name: FK_TipoCont_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tipocont
    ADD CONSTRAINT "FK_TipoCont_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2866 (class 2606 OID 21473)
-- Dependencies: 2471 238 167 3036
-- Name: FK_TmpContri_ActiEcon_IDActiEcon; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tmpcontri
    ADD CONSTRAINT "FK_TmpContri_ActiEcon_IDActiEcon" FOREIGN KEY (actieconid) REFERENCES actiecon(id) MATCH FULL;


--
-- TOC entry 2867 (class 2606 OID 21478)
-- Dependencies: 2521 184 238 3036
-- Name: FK_TmpContri_Ciudades_IDCiudad; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tmpcontri
    ADD CONSTRAINT "FK_TmpContri_Ciudades_IDCiudad" FOREIGN KEY (ciudadid) REFERENCES ciudades(id) MATCH FULL;


--
-- TOC entry 2868 (class 2606 OID 21483)
-- Dependencies: 194 2558 238 3036
-- Name: FK_TmpContri_Contribu_IDContribu; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tmpcontri
    ADD CONSTRAINT "FK_TmpContri_Contribu_IDContribu" FOREIGN KEY (id) REFERENCES contribu(id) MATCH FULL;


--
-- TOC entry 2869 (class 2606 OID 21488)
-- Dependencies: 238 204 2604 3036
-- Name: FK_TmpContri_Estados_IDEstado; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tmpcontri
    ADD CONSTRAINT "FK_TmpContri_Estados_IDEstado" FOREIGN KEY (estadoid) REFERENCES estados(id) MATCH FULL;


--
-- TOC entry 2870 (class 2606 OID 21493)
-- Dependencies: 238 218 2648 3036
-- Name: FK_TmpContri_TipoCont_IDTipoCont; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tmpcontri
    ADD CONSTRAINT "FK_TmpContri_TipoCont_IDTipoCont" FOREIGN KEY (tipocontid) REFERENCES tipocont(id) MATCH FULL;


--
-- TOC entry 2871 (class 2606 OID 21498)
-- Dependencies: 239 184 2521 3036
-- Name: FK_TmpReLegal_IDCiudad; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tmprelegal
    ADD CONSTRAINT "FK_TmpReLegal_IDCiudad" FOREIGN KEY (ciudadid) REFERENCES ciudades(id) MATCH FULL;


--
-- TOC entry 2872 (class 2606 OID 21503)
-- Dependencies: 239 238 2735 3036
-- Name: FK_TmpReLegal_IDContribu; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tmprelegal
    ADD CONSTRAINT "FK_TmpReLegal_IDContribu" FOREIGN KEY (contribuid) REFERENCES tmpcontri(id) MATCH FULL;


--
-- TOC entry 2873 (class 2606 OID 21508)
-- Dependencies: 239 204 2604 3036
-- Name: FK_TmpReLegal_IDEstado; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tmprelegal
    ADD CONSTRAINT "FK_TmpReLegal_IDEstado" FOREIGN KEY (estadoid) REFERENCES estados(id) MATCH FULL;


--
-- TOC entry 2874 (class 2606 OID 21513)
-- Dependencies: 239 212 2632 3036
-- Name: FK_TmpReLegal_IDRepLegal; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tmprelegal
    ADD CONSTRAINT "FK_TmpReLegal_IDRepLegal" FOREIGN KEY (id) REFERENCES replegal(id) MATCH FULL;


--
-- TOC entry 2847 (class 2606 OID 21518)
-- Dependencies: 220 224 2669 3036
-- Name: FK_UndTrib_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY undtrib
    ADD CONSTRAINT "FK_UndTrib_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2849 (class 2606 OID 21523)
-- Dependencies: 224 210 2621 3036
-- Name: FK_UsFonPro_PregSecr_IDPregSecr; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY usfonpro
    ADD CONSTRAINT "FK_UsFonPro_PregSecr_IDPregSecr" FOREIGN KEY (pregsecrid) REFERENCES pregsecr(id) MATCH FULL;


--
-- TOC entry 2848 (class 2606 OID 21528)
-- Dependencies: 222 224 2669 3036
-- Name: FK_UsFonpTo_UsFonpro_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY usfonpto
    ADD CONSTRAINT "FK_UsFonpTo_UsFonpro_IDUsFonpro" FOREIGN KEY (usfonproid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2850 (class 2606 OID 21533)
-- Dependencies: 224 182 2515 3036
-- Name: FK_UsFonpro_Cargos_IDCargo; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY usfonpro
    ADD CONSTRAINT "FK_UsFonpro_Cargos_IDCargo" FOREIGN KEY (cargoid) REFERENCES cargos(id) MATCH FULL;


--
-- TOC entry 2851 (class 2606 OID 21538)
-- Dependencies: 2578 224 198 3036
-- Name: FK_UsFonpro_Departam_IDDepartam; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY usfonpro
    ADD CONSTRAINT "FK_UsFonpro_Departam_IDDepartam" FOREIGN KEY (departamid) REFERENCES departam(id) MATCH FULL;


--
-- TOC entry 2852 (class 2606 OID 21543)
-- Dependencies: 208 224 2616 3036
-- Name: FK_UsFonpro_PerUsu_IDPerUsu; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY usfonpro
    ADD CONSTRAINT "FK_UsFonpro_PerUsu_IDPerUsu" FOREIGN KEY (perusuid) REFERENCES perusu(id);


--
-- TOC entry 2883 (class 2606 OID 46454)
-- Dependencies: 192 2545 267 3036
-- Name: FK_conusu_id; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY con_img_doc
    ADD CONSTRAINT "FK_conusu_id" FOREIGN KEY (conusuid) REFERENCES conusu(id) MATCH FULL;


--
-- TOC entry 2865 (class 2606 OID 21548)
-- Dependencies: 237 238 2735 3036
-- Name: FK_tmpAccioni_ContribuID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tmpaccioni
    ADD CONSTRAINT "FK_tmpAccioni_ContribuID" FOREIGN KEY (contribuid) REFERENCES tmpcontri(id) MATCH FULL;


--
-- TOC entry 2831 (class 2606 OID 21553)
-- Dependencies: 198 224 2669 3036
-- Name: FL_Departam_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY departam
    ADD CONSTRAINT "FL_Departam_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2887 (class 2606 OID 77302)
-- Dependencies: 224 275 2669 3036
-- Name: fk-usuario; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY interes_bcv
    ADD CONSTRAINT "fk-usuario" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id);


--
-- TOC entry 2884 (class 2606 OID 69006)
-- Dependencies: 270 192 2545 3036
-- Name: fk_conusuid; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusu_tipocont
    ADD CONSTRAINT fk_conusuid FOREIGN KEY (conusuid) REFERENCES conusu(id) MATCH FULL;


--
-- TOC entry 2829 (class 2606 OID 69013)
-- Dependencies: 196 192 2545 3036
-- Name: fk_conusuid; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT fk_conusuid FOREIGN KEY (conusuid) REFERENCES conusu(id) MATCH FULL;


SET search_path = pre_aprobacion, pg_catalog;

--
-- TOC entry 2885 (class 2606 OID 77262)
-- Dependencies: 272 196 2574 3036
-- Name: fk-multa-declaracion; Type: FK CONSTRAINT; Schema: pre_aprobacion; Owner: postgres
--

ALTER TABLE ONLY multas
    ADD CONSTRAINT "fk-multa-declaracion" FOREIGN KEY (declaraid) REFERENCES datos.declara(id);


--
-- TOC entry 2886 (class 2606 OID 77257)
-- Dependencies: 272 224 2669 3036
-- Name: fk-multa-usuario; Type: FK CONSTRAINT; Schema: pre_aprobacion; Owner: postgres
--

ALTER TABLE ONLY multas
    ADD CONSTRAINT "fk-multa-usuario" FOREIGN KEY (usuarioid) REFERENCES datos.usfonpro(id);


SET search_path = seg, pg_catalog;

--
-- TOC entry 2876 (class 2606 OID 21625)
-- Dependencies: 244 2754 242 3036
-- Name: fk_permiso_modulo; Type: FK CONSTRAINT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_permiso
    ADD CONSTRAINT fk_permiso_modulo FOREIGN KEY (id_modulo) REFERENCES tbl_modulo(id_modulo) ON DELETE RESTRICT;


--
-- TOC entry 2875 (class 2606 OID 21630)
-- Dependencies: 2758 246 244 3036
-- Name: fk_permiso_rol; Type: FK CONSTRAINT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_permiso
    ADD CONSTRAINT fk_permiso_rol FOREIGN KEY (id_rol) REFERENCES tbl_rol(id_rol) ON DELETE RESTRICT;


--
-- TOC entry 2877 (class 2606 OID 21635)
-- Dependencies: 248 2758 246 3036
-- Name: fk_rol_usuario_rol; Type: FK CONSTRAINT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_rol_usuario
    ADD CONSTRAINT fk_rol_usuario_rol FOREIGN KEY (id_rol) REFERENCES tbl_rol(id_rol) ON DELETE RESTRICT;


--
-- TOC entry 2878 (class 2606 OID 21640)
-- Dependencies: 2758 246 251 3036
-- Name: fk_usuario_rol_rol; Type: FK CONSTRAINT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_usuario_rol
    ADD CONSTRAINT fk_usuario_rol_rol FOREIGN KEY (id_rol) REFERENCES tbl_rol(id_rol) ON DELETE RESTRICT;


--
-- TOC entry 2889 (class 2606 OID 78885)
-- Dependencies: 2754 242 282 3036
-- Name: fkt_permiso_modulo; Type: FK CONSTRAINT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_permiso_trampa
    ADD CONSTRAINT fkt_permiso_modulo FOREIGN KEY (id_modulo) REFERENCES tbl_modulo(id_modulo) ON DELETE RESTRICT;


--
-- TOC entry 2888 (class 2606 OID 78890)
-- Dependencies: 246 282 2758 3036
-- Name: fkt_permiso_rol; Type: FK CONSTRAINT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_permiso_trampa
    ADD CONSTRAINT fkt_permiso_rol FOREIGN KEY (id_rol) REFERENCES tbl_rol(id_rol) ON DELETE RESTRICT;


SET search_path = "segContribu", pg_catalog;

--
-- TOC entry 2880 (class 2606 OID 22912)
-- Dependencies: 256 255 2766 3036
-- Name: fk_permiso_modulo; Type: FK CONSTRAINT; Schema: segContribu; Owner: postgres
--

ALTER TABLE ONLY tbl_permiso_contribu
    ADD CONSTRAINT fk_permiso_modulo FOREIGN KEY (id_modulo) REFERENCES tbl_modulo_contribu(id_modulo) ON DELETE RESTRICT;


--
-- TOC entry 2879 (class 2606 OID 22917)
-- Dependencies: 257 256 2770 3036
-- Name: fk_permiso_rol; Type: FK CONSTRAINT; Schema: segContribu; Owner: postgres
--

ALTER TABLE ONLY tbl_permiso_contribu
    ADD CONSTRAINT fk_permiso_rol FOREIGN KEY (id_rol) REFERENCES tbl_rol_contribu(id_rol) ON DELETE RESTRICT;


--
-- TOC entry 2881 (class 2606 OID 22922)
-- Dependencies: 257 258 2770 3036
-- Name: fk_rol_usuario_rol; Type: FK CONSTRAINT; Schema: segContribu; Owner: postgres
--

ALTER TABLE ONLY tbl_rol_usuario_contribu
    ADD CONSTRAINT fk_rol_usuario_rol FOREIGN KEY (id_rol) REFERENCES tbl_rol_contribu(id_rol) ON DELETE RESTRICT;


--
-- TOC entry 2882 (class 2606 OID 22927)
-- Dependencies: 2770 257 263 3036
-- Name: fk_usuario_rol_rol; Type: FK CONSTRAINT; Schema: segContribu; Owner: postgres
--

ALTER TABLE ONLY tbl_usuario_rol_contribu
    ADD CONSTRAINT fk_usuario_rol_rol FOREIGN KEY (id_rol) REFERENCES tbl_rol_contribu(id_rol) ON DELETE RESTRICT;


--
-- TOC entry 3042 (class 0 OID 0)
-- Dependencies: 7
-- Name: datos; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA datos FROM PUBLIC;
REVOKE ALL ON SCHEMA datos FROM postgres;
GRANT ALL ON SCHEMA datos TO postgres;
GRANT ALL ON SCHEMA datos TO PUBLIC;


--
-- TOC entry 3044 (class 0 OID 0)
-- Dependencies: 8
-- Name: historial; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA historial FROM PUBLIC;
REVOKE ALL ON SCHEMA historial FROM postgres;
GRANT ALL ON SCHEMA historial TO postgres;
GRANT ALL ON SCHEMA historial TO PUBLIC;


--
-- TOC entry 3046 (class 0 OID 0)
-- Dependencies: 5
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


SET search_path = datos, pg_catalog;

--
-- TOC entry 3062 (class 0 OID 0)
-- Dependencies: 167
-- Name: actiecon; Type: ACL; Schema: datos; Owner: postgres
--

REVOKE ALL ON TABLE actiecon FROM PUBLIC;
REVOKE ALL ON TABLE actiecon FROM postgres;
GRANT ALL ON TABLE actiecon TO postgres;


SET search_path = historial, pg_catalog;

--
-- TOC entry 3555 (class 0 OID 0)
-- Dependencies: 240
-- Name: bitacora; Type: ACL; Schema: historial; Owner: postgres
--

REVOKE ALL ON TABLE bitacora FROM PUBLIC;
REVOKE ALL ON TABLE bitacora FROM postgres;
GRANT ALL ON TABLE bitacora TO postgres;
GRANT ALL ON TABLE bitacora TO PUBLIC;


--
-- TOC entry 3557 (class 0 OID 0)
-- Dependencies: 241
-- Name: Bitacora_IDBitacora_seq; Type: ACL; Schema: historial; Owner: postgres
--

REVOKE ALL ON SEQUENCE "Bitacora_IDBitacora_seq" FROM PUBLIC;
REVOKE ALL ON SEQUENCE "Bitacora_IDBitacora_seq" FROM postgres;
GRANT ALL ON SEQUENCE "Bitacora_IDBitacora_seq" TO postgres;
GRANT ALL ON SEQUENCE "Bitacora_IDBitacora_seq" TO PUBLIC;


--
-- TOC entry 1813 (class 826 OID 21558)
-- Dependencies: 8 3036
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: historial; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA historial REVOKE ALL ON SEQUENCES  FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA historial REVOKE ALL ON SEQUENCES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA historial GRANT ALL ON SEQUENCES  TO PUBLIC;


--
-- TOC entry 1814 (class 826 OID 21559)
-- Dependencies: 8 3036
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: historial; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA historial REVOKE ALL ON FUNCTIONS  FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA historial REVOKE ALL ON FUNCTIONS  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA historial GRANT ALL ON FUNCTIONS  TO PUBLIC;


--
-- TOC entry 1815 (class 826 OID 21560)
-- Dependencies: 8 3036
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: historial; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA historial REVOKE ALL ON TABLES  FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA historial REVOKE ALL ON TABLES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA historial GRANT ALL ON TABLES  TO PUBLIC;


-- Completed on 2013-03-27 16:58:22 VET

--
-- PostgreSQL database dump complete
--

