--
-- PostgreSQL database dump
--

-- Dumped from database version 9.1.9
-- Dumped by pg_dump version 9.1.9
-- Started on 2013-07-24 20:38:51 VET

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 3267 (class 1262 OID 24710)
-- Dependencies: 3266
-- Name: FONPROCINE; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE "FONPROCINE" IS 'Base de datos del sistema de recaudación de Fonprocine';


--
-- TOC entry 9 (class 2615 OID 24711)
-- Name: datos; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA datos;


ALTER SCHEMA datos OWNER TO postgres;

--
-- TOC entry 3268 (class 0 OID 0)
-- Dependencies: 9
-- Name: SCHEMA datos; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA datos IS 'standard public schema';


--
-- TOC entry 10 (class 2615 OID 24712)
-- Name: historial; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA historial;


ALTER SCHEMA historial OWNER TO postgres;

--
-- TOC entry 3270 (class 0 OID 0)
-- Dependencies: 10
-- Name: SCHEMA historial; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA historial IS 'Esquema para la tabla de historial de transacciones';


--
-- TOC entry 6 (class 2615 OID 24713)
-- Name: pre_aprobacion; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA pre_aprobacion;


ALTER SCHEMA pre_aprobacion OWNER TO postgres;

--
-- TOC entry 7 (class 2615 OID 24714)
-- Name: seg; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA seg;


ALTER SCHEMA seg OWNER TO postgres;

--
-- TOC entry 8 (class 2615 OID 24715)
-- Name: segContribu; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA "segContribu";


ALTER SCHEMA "segContribu" OWNER TO postgres;

--
-- TOC entry 308 (class 3079 OID 11716)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 3274 (class 0 OID 0)
-- Dependencies: 308
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = datos, pg_catalog;

--
-- TOC entry 321 (class 1255 OID 24716)
-- Dependencies: 9 982
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
					SET  correlativo=2,anio=(select (Extract(year FROM now())+1))
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
-- TOC entry 322 (class 1255 OID 24717)
-- Dependencies: 982 9
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
-- TOC entry 3275 (class 0 OID 0)
-- Dependencies: 322
-- Name: FUNCTION "pa_ActUsuBitDel"("Tabla" text, "ValorID" integer, "IDUsuario" integer, OUT "Actualizado" boolean); Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON FUNCTION "pa_ActUsuBitDel"("Tabla" text, "ValorID" integer, "IDUsuario" integer, OUT "Actualizado" boolean) IS 'Funcion que actualiza el IDUsuario en la bitacora cuando se elimina un registro. Esta funcion tiene que ser llamada inmediatamente despues de eliminar una fila en cualquier tabla';


--
-- TOC entry 323 (class 1255 OID 24718)
-- Dependencies: 982 9
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
-- TOC entry 3276 (class 0 OID 0)
-- Dependencies: 323
-- Name: FUNCTION "pa_LoginContribu"("LoginUsuario" text, "PasswordUsuario" text, OUT "IDUsuarioContribuyente" integer, OUT "NombreUsuario" text, OUT "IDTipoUsuario" integer, OUT "UltimoLogin" timestamp without time zone); Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON FUNCTION "pa_LoginContribu"("LoginUsuario" text, "PasswordUsuario" text, OUT "IDUsuarioContribuyente" integer, OUT "NombreUsuario" text, OUT "IDTipoUsuario" integer, OUT "UltimoLogin" timestamp without time zone) IS 'Funcion para hacer login de un contribuyente';


--
-- TOC entry 324 (class 1255 OID 24719)
-- Dependencies: 982 9
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
-- TOC entry 3277 (class 0 OID 0)
-- Dependencies: 324
-- Name: FUNCTION "pa_LoginUsFonpro"("LoginUsuario" text, "PasswordUsuario" text, OUT "IDUsuarioFonprocine" integer, OUT "NombreUsuario" text, OUT "IDPerfilUsuario" integer, OUT "UltimoLogin" timestamp without time zone); Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON FUNCTION "pa_LoginUsFonpro"("LoginUsuario" text, "PasswordUsuario" text, OUT "IDUsuarioFonprocine" integer, OUT "NombreUsuario" text, OUT "IDPerfilUsuario" integer, OUT "UltimoLogin" timestamp without time zone) IS 'Funcion para hacer login de un usuario Fonprocine';


--
-- TOC entry 325 (class 1255 OID 24720)
-- Dependencies: 9 982
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
-- TOC entry 3278 (class 0 OID 0)
-- Dependencies: 325
-- Name: FUNCTION "pa_TokenActivoContribu"("IDToken" integer, "IDUsuario" integer, OUT "Activo" boolean, OUT "FechaCreacion" timestamp without time zone, OUT "FechaCaducidad" timestamp without time zone, OUT "FechaHoraServidor" timestamp without time zone, OUT "Observaciones" text); Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON FUNCTION "pa_TokenActivoContribu"("IDToken" integer, "IDUsuario" integer, OUT "Activo" boolean, OUT "FechaCreacion" timestamp without time zone, OUT "FechaCaducidad" timestamp without time zone, OUT "FechaHoraServidor" timestamp without time zone, OUT "Observaciones" text) IS 'Funcion que verifica si el token de usuario de contribuyente buscado esta activo a la fecha hora del servidor';


--
-- TOC entry 326 (class 1255 OID 24721)
-- Dependencies: 982 9
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
-- TOC entry 3279 (class 0 OID 0)
-- Dependencies: 326
-- Name: FUNCTION "pa_TokenActivoUsFonpro"("IDToken" integer, "IDUsuario" integer, OUT "Activo" boolean, OUT "FechaCreacion" timestamp without time zone, OUT "FechaCaducidad" timestamp without time zone, OUT "FechaHoraServidor" timestamp without time zone, OUT "Observaciones" text); Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON FUNCTION "pa_TokenActivoUsFonpro"("IDToken" integer, "IDUsuario" integer, OUT "Activo" boolean, OUT "FechaCreacion" timestamp without time zone, OUT "FechaCaducidad" timestamp without time zone, OUT "FechaHoraServidor" timestamp without time zone, OUT "Observaciones" text) IS 'Funcion que verifica si el token de usuario de forprocine buscado esta activo a la fecha hora del servidor';


--
-- TOC entry 327 (class 1255 OID 24722)
-- Dependencies: 982 9
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
-- TOC entry 328 (class 1255 OID 24723)
-- Dependencies: 9 982
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
-- TOC entry 3280 (class 0 OID 0)
-- Dependencies: 328
-- Name: FUNCTION "tf_AsiendoD_ActualizaDebeHaber_Asiento"(); Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON FUNCTION "tf_AsiendoD_ActualizaDebeHaber_Asiento"() IS 'Funcion de trigger que actualiza las columnas de debe y haber de la tabla Asientos';


--
-- TOC entry 320 (class 1255 OID 24724)
-- Dependencies: 9 982
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
-- TOC entry 3281 (class 0 OID 0)
-- Dependencies: 320
-- Name: FUNCTION "tf_Asiento_ActualizaPeriodo"(); Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON FUNCTION "tf_Asiento_ActualizaPeriodo"() IS 'Funcion de trigger para actualizar las columnas de Mes y Ano, a partir de la fecha especificada';


--
-- TOC entry 329 (class 1255 OID 24725)
-- Dependencies: 9 982
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
-- TOC entry 3282 (class 0 OID 0)
-- Dependencies: 329
-- Name: FUNCTION "tf_Asiento_ActualizaSaldo"(); Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON FUNCTION "tf_Asiento_ActualizaSaldo"() IS 'Funcion que actualiza el saldo de la tabla asiento';


--
-- TOC entry 330 (class 1255 OID 24726)
-- Dependencies: 9 982
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
-- TOC entry 3283 (class 0 OID 0)
-- Dependencies: 330
-- Name: FUNCTION "tf_Bitacora"(); Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON FUNCTION "tf_Bitacora"() IS 'Trigger para el insert de datos en la bitacora de cambios';


SET search_path = seg, pg_catalog;

--
-- TOC entry 331 (class 1255 OID 24727)
-- Dependencies: 982 7
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
-- TOC entry 166 (class 1259 OID 24728)
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
-- TOC entry 167 (class 1259 OID 24730)
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
-- TOC entry 3284 (class 0 OID 0)
-- Dependencies: 167
-- Name: TABLE actiecon; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE actiecon IS 'Tabla con las actividades económicas';


--
-- TOC entry 3285 (class 0 OID 0)
-- Dependencies: 167
-- Name: COLUMN actiecon.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN actiecon.id IS 'Identificador del tipo de actividad económica';


--
-- TOC entry 3286 (class 0 OID 0)
-- Dependencies: 167
-- Name: COLUMN actiecon.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN actiecon.nombre IS 'Nombre de la actividad económica';


--
-- TOC entry 3287 (class 0 OID 0)
-- Dependencies: 167
-- Name: COLUMN actiecon.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN actiecon.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3288 (class 0 OID 0)
-- Dependencies: 167
-- Name: COLUMN actiecon.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN actiecon.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 168 (class 1259 OID 24733)
-- Dependencies: 167 9
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
-- TOC entry 3290 (class 0 OID 0)
-- Dependencies: 168
-- Name: ActiEcon_IDActiEcon_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "ActiEcon_IDActiEcon_seq" OWNED BY actiecon.id;


--
-- TOC entry 169 (class 1259 OID 24735)
-- Dependencies: 2425 2426 2427 2428 2429 2430 2431 2432 2433 2434 2435 9
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
-- TOC entry 3291 (class 0 OID 0)
-- Dependencies: 169
-- Name: TABLE alicimp; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE alicimp IS 'Tabla con los datos de las alicuotas impositivas';


--
-- TOC entry 3292 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.id IS 'Identificador de la alicuota';


--
-- TOC entry 3293 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.tipocontid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.tipocontid IS 'Identificador del tipo de contribuyente';


--
-- TOC entry 3294 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.ano; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.ano IS 'Ano en la que aplica la alicuota';


--
-- TOC entry 3295 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.alicuota; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.alicuota IS '% de la alicuota a pagar';


--
-- TOC entry 3296 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.tipocalc; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.tipocalc IS 'Tipo de calculo a usar para seleccionar la alicuota.
0=Aplicar alicuota directamente.
1=Aplicar alicuota de acuerdo al limite inferior en UT.
2=Aplicar alicuota de acuerdo a rangos en UT';


--
-- TOC entry 3297 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.valorut; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.valorut IS 'Limite inferior en UT al cual se le aplica la alicuota. Aplica para TipoCalc=1';


--
-- TOC entry 3298 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.liminf1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.liminf1 IS 'Limite inferior 1 en UT para aplicacion de alicuota por rango. TipoCalc=2';


--
-- TOC entry 3299 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.limsup1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.limsup1 IS 'Limite superior 1 en UT para aplicacion de alicuota por rango. TipoCalc=2';


--
-- TOC entry 3300 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.alicuota1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.alicuota1 IS 'Alicuota del rango 1. TipoCalc=2';


--
-- TOC entry 3301 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.liminf2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.liminf2 IS 'Limite inferior 2 en UT para aplicacion de alicuota por rango. TipoCalc=2';


--
-- TOC entry 3302 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.limsup2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.limsup2 IS 'Limite superior 2 en UT para aplicacion de alicuota por rango. TipoCalc=2';


--
-- TOC entry 3303 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.alicuota2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.alicuota2 IS 'Alicuota del rango 2. TipoCalc=2';


--
-- TOC entry 3304 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.liminf3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.liminf3 IS 'Limite inferior 3 en UT para aplicacion de alicuota por rango. TipoCalc=2';


--
-- TOC entry 3305 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.limsup3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.limsup3 IS 'Limite superior 3 en UT para aplicacion de alicuota por rango. TipoCalc=2';


--
-- TOC entry 3306 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.alicuota3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.alicuota3 IS 'Alicuota del rango 3. TipoCalc=2';


--
-- TOC entry 3307 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.liminf4; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.liminf4 IS 'Limite inferior 4 en UT para aplicacion de alicuota por rango. TipoCalc=2';


--
-- TOC entry 3308 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.limsup4; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.limsup4 IS 'Limite superior 4 en UT para aplicacion de alicuota por rango. TipoCalc=2';


--
-- TOC entry 3309 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.alicuota4; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.alicuota4 IS 'Alicuota del rango 4. TipoCalc=2';


--
-- TOC entry 3310 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.liminf5; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.liminf5 IS 'Limite inferior 5 en UT para aplicacion de alicuota por rango. TipoCalc=2';


--
-- TOC entry 3311 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.limsup5; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.limsup5 IS 'Limite superior 5 en UT para aplicacion de alicuota por rango. TipoCalc=2';


--
-- TOC entry 3312 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.alicuota5; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.alicuota5 IS 'Alicuota del rango 5. TipoCalc=2';


--
-- TOC entry 3313 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.usuarioid IS 'Identificador del ultimo usuario en crear o modificar un registro';


--
-- TOC entry 3314 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 170 (class 1259 OID 24749)
-- Dependencies: 9 169
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
-- TOC entry 3315 (class 0 OID 0)
-- Dependencies: 170
-- Name: AlicImp_IDAlicImp_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "AlicImp_IDAlicImp_seq" OWNED BY alicimp.id;


--
-- TOC entry 171 (class 1259 OID 24751)
-- Dependencies: 2437 2438 9
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
-- TOC entry 3316 (class 0 OID 0)
-- Dependencies: 171
-- Name: TABLE asientod; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE asientod IS 'Tabla con el detalle de los asientos';


--
-- TOC entry 3317 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN asientod.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientod.id IS 'Identificador unico de registro';


--
-- TOC entry 3318 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN asientod.asientoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientod.asientoid IS 'Identificador del asiento';


--
-- TOC entry 3319 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN asientod.fecha; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientod.fecha IS 'Fecha de la transaccion';


--
-- TOC entry 3320 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN asientod.cuenta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientod.cuenta IS 'Cuenta contable';


--
-- TOC entry 3321 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN asientod.monto; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientod.monto IS 'Monto de la transaccion';


--
-- TOC entry 3322 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN asientod.sentido; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientod.sentido IS 'Sentido del monto. 0=Debe / 1=Haber';


--
-- TOC entry 3323 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN asientod.referencia; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientod.referencia IS 'Referencia de la linea';


--
-- TOC entry 3324 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN asientod.comentar; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientod.comentar IS 'Comentarios u observaciones';


--
-- TOC entry 3325 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN asientod.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientod.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3326 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN asientod.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientod.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 172 (class 1259 OID 24759)
-- Dependencies: 9 171
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
-- TOC entry 3327 (class 0 OID 0)
-- Dependencies: 172
-- Name: AsientoD_IDAsientoD_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "AsientoD_IDAsientoD_seq" OWNED BY asientod.id;


--
-- TOC entry 173 (class 1259 OID 24761)
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
-- TOC entry 174 (class 1259 OID 24763)
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
-- TOC entry 3328 (class 0 OID 0)
-- Dependencies: 174
-- Name: TABLE bacuenta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE bacuenta IS 'Tabla con los datos de las cuentas bancarias';


--
-- TOC entry 3329 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN bacuenta.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN bacuenta.id IS 'Identificador unico de registro';


--
-- TOC entry 3330 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN bacuenta.bancoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN bacuenta.bancoid IS 'Identificador del banco';


--
-- TOC entry 3331 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN bacuenta.cuenta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN bacuenta.cuenta IS 'Numero de cuenta bancaria';


--
-- TOC entry 3332 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN bacuenta.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN bacuenta.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3333 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN bacuenta.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN bacuenta.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 175 (class 1259 OID 24766)
-- Dependencies: 174 9
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
-- TOC entry 3334 (class 0 OID 0)
-- Dependencies: 175
-- Name: BaCuenta_IDBaCuenta_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "BaCuenta_IDBaCuenta_seq" OWNED BY bacuenta.id;


--
-- TOC entry 176 (class 1259 OID 24768)
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
-- TOC entry 3335 (class 0 OID 0)
-- Dependencies: 176
-- Name: TABLE bancos; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE bancos IS 'Tabla con los datos de los bancos que maneja el organismo';


--
-- TOC entry 3336 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN bancos.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN bancos.id IS 'Identificador unico de registro';


--
-- TOC entry 3337 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN bancos.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN bancos.nombre IS 'Nombre del banco';


--
-- TOC entry 3338 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN bancos.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN bancos.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3339 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN bancos.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN bancos.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 177 (class 1259 OID 24771)
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
-- TOC entry 3340 (class 0 OID 0)
-- Dependencies: 177
-- Name: Bancos_IDBanco_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "Bancos_IDBanco_seq" OWNED BY bancos.id;


--
-- TOC entry 178 (class 1259 OID 24773)
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
-- TOC entry 3341 (class 0 OID 0)
-- Dependencies: 178
-- Name: TABLE calpagod; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE calpagod IS 'Tabla con el detalle de los calendario de pagos';


--
-- TOC entry 3342 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN calpagod.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpagod.id IS 'Identificador unico del detalle de los calendarios de pagos';


--
-- TOC entry 3343 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN calpagod.calpagoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpagod.calpagoid IS 'Identificador del calendario de pago';


--
-- TOC entry 3344 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN calpagod.fechaini; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpagod.fechaini IS 'Fecha de inicio del periodo gravable';


--
-- TOC entry 3345 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN calpagod.fechafin; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpagod.fechafin IS 'Fecha final del periodo gravable';


--
-- TOC entry 3346 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN calpagod.fechalim; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpagod.fechalim IS 'Fecha limite de pago del periodo gravable';


--
-- TOC entry 3347 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN calpagod.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpagod.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3348 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN calpagod.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpagod.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 179 (class 1259 OID 24776)
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
-- TOC entry 3349 (class 0 OID 0)
-- Dependencies: 179
-- Name: CalPagoD_IDCalPagoD_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "CalPagoD_IDCalPagoD_seq" OWNED BY calpagod.id;


--
-- TOC entry 180 (class 1259 OID 24778)
-- Dependencies: 2443 9
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
-- TOC entry 3350 (class 0 OID 0)
-- Dependencies: 180
-- Name: TABLE calpago; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE calpago IS 'Tabla con los calendarios de pagos de los diferentes tipos de contribuyentes por año';


--
-- TOC entry 3351 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN calpago.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpago.id IS 'Identificador del calendario de pagos';


--
-- TOC entry 3352 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN calpago.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpago.nombre IS 'Nombre del calendario';


--
-- TOC entry 3353 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN calpago.ano; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpago.ano IS 'Año vigencia del calendario';


--
-- TOC entry 3354 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN calpago.tipegravid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpago.tipegravid IS 'Identificador del tipo de periodo gravable';


--
-- TOC entry 3355 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN calpago.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpago.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3356 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN calpago.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpago.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 181 (class 1259 OID 24782)
-- Dependencies: 9 180
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
-- TOC entry 3357 (class 0 OID 0)
-- Dependencies: 181
-- Name: CalPagos_IDCalPago_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "CalPagos_IDCalPago_seq" OWNED BY calpago.id;


--
-- TOC entry 182 (class 1259 OID 24784)
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
-- TOC entry 3358 (class 0 OID 0)
-- Dependencies: 182
-- Name: TABLE cargos; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE cargos IS 'Tabla con los distintos cargos de la organizacion';


--
-- TOC entry 3359 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN cargos.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN cargos.id IS 'Identificador unico del cargo';


--
-- TOC entry 3360 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN cargos.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN cargos.nombre IS 'Nombre del cargo';


--
-- TOC entry 3361 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN cargos.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN cargos.usuarioid IS 'Identificador del usuario que creo el registro o del ultimo en modificarlo';


--
-- TOC entry 3362 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN cargos.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN cargos.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 183 (class 1259 OID 24790)
-- Dependencies: 182 9
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
-- TOC entry 3363 (class 0 OID 0)
-- Dependencies: 183
-- Name: Cargos_IDCargo_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "Cargos_IDCargo_seq" OWNED BY cargos.id;


--
-- TOC entry 184 (class 1259 OID 24792)
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
-- TOC entry 3364 (class 0 OID 0)
-- Dependencies: 184
-- Name: TABLE ciudades; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE ciudades IS 'Tabla con las ciudades por estado geografico';


--
-- TOC entry 3365 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN ciudades.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN ciudades.id IS 'Idenficador unico de la ciudad';


--
-- TOC entry 3366 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN ciudades.estadoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN ciudades.estadoid IS 'Identificador del estado';


--
-- TOC entry 3367 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN ciudades.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN ciudades.nombre IS 'Nombre de la ciudad';


--
-- TOC entry 3368 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN ciudades.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN ciudades.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3369 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN ciudades.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN ciudades.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 185 (class 1259 OID 24795)
-- Dependencies: 9 184
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
-- TOC entry 3370 (class 0 OID 0)
-- Dependencies: 185
-- Name: Ciudades_IDCiudad_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "Ciudades_IDCiudad_seq" OWNED BY ciudades.id;


--
-- TOC entry 186 (class 1259 OID 24797)
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
-- TOC entry 3371 (class 0 OID 0)
-- Dependencies: 186
-- Name: TABLE conusuco; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE conusuco IS 'Tabla con la relacion entre usuarios y a los contribuyentes que representan';


--
-- TOC entry 3372 (class 0 OID 0)
-- Dependencies: 186
-- Name: COLUMN conusuco.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuco.id IS 'Identificador unico de registro';


--
-- TOC entry 3373 (class 0 OID 0)
-- Dependencies: 186
-- Name: COLUMN conusuco.conusuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuco.conusuid IS 'Identificador del usuario';


--
-- TOC entry 3374 (class 0 OID 0)
-- Dependencies: 186
-- Name: COLUMN conusuco.contribuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuco.contribuid IS 'Identificador del contribuyente';


--
-- TOC entry 187 (class 1259 OID 24800)
-- Dependencies: 186 9
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
-- TOC entry 3375 (class 0 OID 0)
-- Dependencies: 187
-- Name: ConUsuCo_IDConUsuCo_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "ConUsuCo_IDConUsuCo_seq" OWNED BY conusuco.id;


--
-- TOC entry 188 (class 1259 OID 24802)
-- Dependencies: 2448 2449 2450 9
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
-- TOC entry 3376 (class 0 OID 0)
-- Dependencies: 188
-- Name: TABLE conusuti; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE conusuti IS 'Tabla con los tipos de usuarios de los contribuyentes';


--
-- TOC entry 3377 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN conusuti.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuti.id IS 'Identificador unico del tipo de usuario de contribuyentes';


--
-- TOC entry 3378 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN conusuti.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuti.nombre IS 'Nombre del tipo de usuario';


--
-- TOC entry 3379 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN conusuti.administra; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuti.administra IS 'Si el tipo de usuario (perfil) administra la cuenta del contribuyente. Crea usuarios, elimina usuarios';


--
-- TOC entry 3380 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN conusuti.liquida; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuti.liquida IS 'Si el tipo de usuario (perfil) liquida planillas de autoliquidacion en la cuenta del contribuyente.';


--
-- TOC entry 3381 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN conusuti.visualiza; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuti.visualiza IS 'Si el tipo de usuario (perfil) solo visualiza datos  de la cuenta del contribuyente.';


--
-- TOC entry 3382 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN conusuti.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuti.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3383 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN conusuti.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuti.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 189 (class 1259 OID 24808)
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
-- TOC entry 3384 (class 0 OID 0)
-- Dependencies: 189
-- Name: ConUsuTi_IDConUsuTi_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "ConUsuTi_IDConUsuTi_seq" OWNED BY conusuti.id;


--
-- TOC entry 190 (class 1259 OID 24810)
-- Dependencies: 2452 2453 9
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
-- TOC entry 3385 (class 0 OID 0)
-- Dependencies: 190
-- Name: TABLE conusuto; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE conusuto IS 'Tabla con los Tokens activos por usuario, es Tokens se utilizaran para validad la creacion de usuarios, recuperacion de contraseñas, etc.';


--
-- TOC entry 3386 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN conusuto.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuto.id IS 'Idendificador unico del token';


--
-- TOC entry 3387 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN conusuto.token; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuto.token IS 'Token generado';


--
-- TOC entry 3388 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN conusuto.conusuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuto.conusuid IS 'Identificador del usuario dueño del token';


--
-- TOC entry 3389 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN conusuto.fechacrea; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuto.fechacrea IS 'Fecha hora de creacion del token';


--
-- TOC entry 3390 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN conusuto.fechacadu; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuto.fechacadu IS 'Fecha hora de caducidad del token';


--
-- TOC entry 3391 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN conusuto.usado; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuto.usado IS 'Si el token fue usado por el usuario o no';


--
-- TOC entry 191 (class 1259 OID 24818)
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
-- TOC entry 3392 (class 0 OID 0)
-- Dependencies: 191
-- Name: ConUsuTo_IDConUsuTo_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "ConUsuTo_IDConUsuTo_seq" OWNED BY conusuto.id;


--
-- TOC entry 192 (class 1259 OID 24820)
-- Dependencies: 2455 2456 2457 9
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
-- TOC entry 3393 (class 0 OID 0)
-- Dependencies: 192
-- Name: TABLE conusu; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE conusu IS 'Tabla con los datos de los usuarios por contribuyente';


--
-- TOC entry 3394 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.id IS 'Identificador del usuario del contribuyente';


--
-- TOC entry 3395 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.login; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.login IS 'Login de usuario. este campo es unico y es identificado un el rif del contribuyente';


--
-- TOC entry 3396 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.password; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.password IS 'Hash del pasword para hacer login';


--
-- TOC entry 3397 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.nombre IS 'Nombre del usuario. Este es el nombre que se muestra';


--
-- TOC entry 3398 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.inactivo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.inactivo IS 'Si el usuario esta inactivo o no. False=No / True=Si';


--
-- TOC entry 3399 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.conusutiid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.conusutiid IS 'Identificador del tipo de usuario de contribuyentes';


--
-- TOC entry 3400 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.email; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.email IS 'Direccion de email del usuario, se utilizara para validar la cuenta';


--
-- TOC entry 3401 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.pregsecrid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.pregsecrid IS 'Identificador de la pregunta secreta seleccionada por en usuario';


--
-- TOC entry 3402 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.respuesta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.respuesta IS 'Hash con la respuesta a la pregunta secreta';


--
-- TOC entry 3403 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.ultlogin; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.ultlogin IS 'Fecha y hora de la ultima vez que el usuario hizo login';


--
-- TOC entry 3404 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3405 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 193 (class 1259 OID 24829)
-- Dependencies: 9 192
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
-- TOC entry 3406 (class 0 OID 0)
-- Dependencies: 193
-- Name: ConUsu_IDConUsu_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "ConUsu_IDConUsu_seq" OWNED BY conusu.id;


--
-- TOC entry 194 (class 1259 OID 24831)
-- Dependencies: 2459 2460 2461 2462 9
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
-- TOC entry 3407 (class 0 OID 0)
-- Dependencies: 194
-- Name: TABLE contribu; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE contribu IS 'Tabla con los datos de los contribuyentes de la institución';


--
-- TOC entry 3408 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.id IS 'Identificador unico del contribuyente';


--
-- TOC entry 3409 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.razonsocia; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.razonsocia IS 'Razon social del contribuyente';


--
-- TOC entry 3410 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.dencomerci; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.dencomerci IS 'Denominacion comercial del contribuyente';


--
-- TOC entry 3411 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.actieconid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.actieconid IS 'Identificador de la actividad economica';


--
-- TOC entry 3412 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.rif; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.rif IS 'Rif del contribuyente';


--
-- TOC entry 3413 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.numregcine; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.numregcine IS 'Numero de registro cinematografico';


--
-- TOC entry 3414 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.domfiscal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.domfiscal IS 'Domicilio fiscal del contribuyente';


--
-- TOC entry 3415 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.estadoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.estadoid IS 'Identicador del estado geografico';


--
-- TOC entry 3416 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.ciudadid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.ciudadid IS 'Identificador de la ciudad';


--
-- TOC entry 3417 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.zonapostal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.zonapostal IS 'Zona postal del contribuyente';


--
-- TOC entry 3418 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.telef1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.telef1 IS 'Telefono 1 del contribuyente';


--
-- TOC entry 3419 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.telef2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.telef2 IS 'Telefono 2 del contribuyente';


--
-- TOC entry 3420 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.telef3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.telef3 IS 'Telefono 3 del contribuyente';


--
-- TOC entry 3421 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.fax1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.fax1 IS 'Fax 1 del contribuyente';


--
-- TOC entry 3422 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.fax2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.fax2 IS 'Fax 2 del contribuyente';


--
-- TOC entry 3423 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.email; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.email IS 'Direccion de email de contribuyente';


--
-- TOC entry 3424 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.pinbb; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.pinbb IS 'Pin de BlackBerry';


--
-- TOC entry 3425 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.skype; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.skype IS 'Dirección de skype';


--
-- TOC entry 3426 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.twitter; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.twitter IS 'Direccion de twitter';


--
-- TOC entry 3427 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.facebook; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.facebook IS 'Direccion de facebook';


--
-- TOC entry 3428 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.nuacciones; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.nuacciones IS 'Numero de acciones del contribuyente segun inforacion del registro mercantil';


--
-- TOC entry 3429 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.valaccion; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.valaccion IS 'Valor nominal por accion segun registro mercantil';


--
-- TOC entry 3430 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.capitalsus; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.capitalsus IS 'Capital suscrito segun registro mercantil';


--
-- TOC entry 3431 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.capitalpag; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.capitalpag IS 'Capital pagado segun registro mercantil';


--
-- TOC entry 3432 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.regmerofc; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.regmerofc IS 'Oficina de registro mercantil en donde se registro la empresa';


--
-- TOC entry 3433 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.rmnumero; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.rmnumero IS 'Numero de registro del documento de registro mercantil';


--
-- TOC entry 3434 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.rmfolio; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.rmfolio IS 'Numero de folio del documento de registro mercantil';


--
-- TOC entry 3435 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.rmtomo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.rmtomo IS 'Numero de folio del documento de registro mercantil';


--
-- TOC entry 3436 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.rmfechapro; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.rmfechapro IS 'Fecha de protocololizacion del registro del documento de registro mercantil';


--
-- TOC entry 3437 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.rmncontrol; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.rmncontrol IS 'Numero de control del documento de registro mercantil';


--
-- TOC entry 3438 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.rmobjeto; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.rmobjeto IS 'Objeto de la empresa segun registro mercantil';


--
-- TOC entry 3439 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.domcomer; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.domcomer IS 'domicilio comercial';


--
-- TOC entry 3440 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.cextra1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.cextra1 IS 'Campo extra 1';


--
-- TOC entry 3441 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.cextra2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.cextra2 IS 'Campo extra 2';


--
-- TOC entry 3442 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.cextra3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.cextra3 IS 'Campo extra 3';


--
-- TOC entry 3443 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.cextra4; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.cextra4 IS 'Campo extra 4';


--
-- TOC entry 3444 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.cextra5; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.cextra5 IS 'Campo extra 5';


--
-- TOC entry 3445 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.usuarioid IS 'identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3446 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 195 (class 1259 OID 24841)
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
-- TOC entry 3447 (class 0 OID 0)
-- Dependencies: 195
-- Name: Contribu_IDContribu_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "Contribu_IDContribu_seq" OWNED BY contribu.id;


--
-- TOC entry 196 (class 1259 OID 24843)
-- Dependencies: 2464 2465 2466 2467 2468 2469 2470 2471 9
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
-- TOC entry 3448 (class 0 OID 0)
-- Dependencies: 196
-- Name: TABLE declara_viejo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE declara_viejo IS 'Planilla de declaracion de impuestos';


--
-- TOC entry 3449 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.id IS 'Identificador unico de la declaracion de impuestos';


--
-- TOC entry 3450 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.nudeclara; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.nudeclara IS 'Numero de planilla de declaracion de impuesto';


--
-- TOC entry 3451 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.nudeposito; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.nudeposito IS 'Numero de deposito bancario generado por el sistema';


--
-- TOC entry 3452 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.tdeclaraid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.tdeclaraid IS 'Identificador del tipo de declaracion';


--
-- TOC entry 3453 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.fechaelab; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.fechaelab IS 'Fecha de elaboracion de la planilla de pago de impuestos';


--
-- TOC entry 3454 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.fechaini; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.fechaini IS 'Fecha de inicio del periodo gravable';


--
-- TOC entry 3455 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.fechafin; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.fechafin IS 'Fecha final del periodo gravable';


--
-- TOC entry 3456 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.replegalid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.replegalid IS 'Identificador del representante legal que aparecera en la planilla y firmara la misma';


--
-- TOC entry 3457 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.baseimpo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.baseimpo IS 'Base imponible';


--
-- TOC entry 3458 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.alicuota; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.alicuota IS 'Alicuota impositiva aplicada a la declaracion de impuesto';


--
-- TOC entry 3459 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.exonera; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.exonera IS 'Exoneracion o rebaja';


--
-- TOC entry 3460 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.nuactoexon; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.nuactoexon IS 'Numero de acto en donde se establece la exoneracion o rebaja';


--
-- TOC entry 3461 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.credfiscal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.credfiscal IS 'Credito fiscal';


--
-- TOC entry 3462 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.contribant; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.contribant IS 'Monto de la contribucion pagada en periodos anteriores';


--
-- TOC entry 3463 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.plasustid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.plasustid IS 'Identificador de la planilla que se esta sustituyendo en caso de ser una declaracion sustitutiva';


--
-- TOC entry 3464 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.nuresactfi; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.nuresactfi IS 'Numero de resolucion o numero de acta fiscal';


--
-- TOC entry 3465 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.fechanoti; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.fechanoti IS 'Fecha de notificacion';


--
-- TOC entry 3466 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.intemora; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.intemora IS 'Intereses moratorios';


--
-- TOC entry 3467 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.reparofis; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.reparofis IS 'Reparo fiscal';


--
-- TOC entry 3468 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.multa; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.multa IS 'Multa aplicada';


--
-- TOC entry 3469 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.montopagar; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.montopagar IS 'Monto a pagar';


--
-- TOC entry 3470 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.fechapago; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.fechapago IS 'Fecha de pago en el banco. Se llena este campo cuando se concilian los pagos';


--
-- TOC entry 3471 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.fechaconci; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.fechaconci IS 'Fecha hora de la conciliacion contra los depositos del banco';


--
-- TOC entry 3472 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.asientoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.asientoid IS 'Identificador del asiento contable en donde se registro la informacion del pago';


--
-- TOC entry 3473 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.usuarioid IS 'Identificador del usuario que concilio el pago de la declaracion. ';


--
-- TOC entry 3474 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 197 (class 1259 OID 24854)
-- Dependencies: 9 196
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
-- TOC entry 3475 (class 0 OID 0)
-- Dependencies: 197
-- Name: Declara_IDDeclara_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "Declara_IDDeclara_seq" OWNED BY declara_viejo.id;


--
-- TOC entry 198 (class 1259 OID 24856)
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
-- TOC entry 3476 (class 0 OID 0)
-- Dependencies: 198
-- Name: TABLE departam; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE departam IS 'Tabla con los departamentos / gerencia de la organizacion';


--
-- TOC entry 3477 (class 0 OID 0)
-- Dependencies: 198
-- Name: COLUMN departam.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN departam.id IS 'Identificador unico del departamento';


--
-- TOC entry 3478 (class 0 OID 0)
-- Dependencies: 198
-- Name: COLUMN departam.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN departam.nombre IS 'Nombre del departamento o gerencia';


--
-- TOC entry 3479 (class 0 OID 0)
-- Dependencies: 198
-- Name: COLUMN departam.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN departam.usuarioid IS 'Identificador del usuario que creo el registro o del ultimo en modificarlo';


--
-- TOC entry 3480 (class 0 OID 0)
-- Dependencies: 198
-- Name: COLUMN departam.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN departam.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 199 (class 1259 OID 24862)
-- Dependencies: 9 198
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
-- TOC entry 3481 (class 0 OID 0)
-- Dependencies: 199
-- Name: Departam_IDDepartam_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "Departam_IDDepartam_seq" OWNED BY departam.id;


--
-- TOC entry 200 (class 1259 OID 24864)
-- Dependencies: 2474 9
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
-- TOC entry 3482 (class 0 OID 0)
-- Dependencies: 200
-- Name: TABLE entidadd; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE entidadd IS 'Tabla con el detalle de las entidades. Acciones y procesos a verificar acceso por entidad';


--
-- TOC entry 3483 (class 0 OID 0)
-- Dependencies: 200
-- Name: COLUMN entidadd.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN entidadd.id IS 'Identificador unico del detalle de la entidad';


--
-- TOC entry 3484 (class 0 OID 0)
-- Dependencies: 200
-- Name: COLUMN entidadd.entidadid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN entidadd.entidadid IS 'Identificador de la entidad a la que pertenece la accion o preceso';


--
-- TOC entry 3485 (class 0 OID 0)
-- Dependencies: 200
-- Name: COLUMN entidadd.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN entidadd.nombre IS 'Nombre de la accion o proceso a mostrar en el arbol de permisos disponibles';


--
-- TOC entry 3486 (class 0 OID 0)
-- Dependencies: 200
-- Name: COLUMN entidadd.accion; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN entidadd.accion IS 'Nombre interno de la accion o proceso';


--
-- TOC entry 3487 (class 0 OID 0)
-- Dependencies: 200
-- Name: COLUMN entidadd.orden; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN entidadd.orden IS 'Orden en que apareceran las acciones y/o procesos dentro del arbol de una entidad';


--
-- TOC entry 201 (class 1259 OID 24868)
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
-- TOC entry 3488 (class 0 OID 0)
-- Dependencies: 201
-- Name: EntidadD_IDEntidadD_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "EntidadD_IDEntidadD_seq" OWNED BY entidadd.id;


--
-- TOC entry 202 (class 1259 OID 24870)
-- Dependencies: 2476 9
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
-- TOC entry 3489 (class 0 OID 0)
-- Dependencies: 202
-- Name: TABLE entidad; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE entidad IS 'Tabla con las entidades del sistema';


--
-- TOC entry 3490 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN entidad.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN entidad.id IS 'Identificador de la entidad';


--
-- TOC entry 3491 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN entidad.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN entidad.nombre IS 'Nombre de la entidad a mostrar en el arbol de permisos disponibles';


--
-- TOC entry 3492 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN entidad.entidad; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN entidad.entidad IS 'Nombre interno de la entidad';


--
-- TOC entry 3493 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN entidad.orden; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN entidad.orden IS 'Orden en la que apareceran la entidades en el arbol de permisos de usuarios';


--
-- TOC entry 203 (class 1259 OID 24874)
-- Dependencies: 202 9
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
-- TOC entry 3494 (class 0 OID 0)
-- Dependencies: 203
-- Name: Entidad_IDEntidad_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "Entidad_IDEntidad_seq" OWNED BY entidad.id;


--
-- TOC entry 204 (class 1259 OID 24876)
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
-- TOC entry 3495 (class 0 OID 0)
-- Dependencies: 204
-- Name: TABLE estados; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE estados IS 'Tabla con los estados geográficos';


--
-- TOC entry 3496 (class 0 OID 0)
-- Dependencies: 204
-- Name: COLUMN estados.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN estados.id IS 'Identificador unico del estado';


--
-- TOC entry 3497 (class 0 OID 0)
-- Dependencies: 204
-- Name: COLUMN estados.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN estados.nombre IS 'Nombre del estado geografico';


--
-- TOC entry 3498 (class 0 OID 0)
-- Dependencies: 204
-- Name: COLUMN estados.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN estados.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3499 (class 0 OID 0)
-- Dependencies: 204
-- Name: COLUMN estados.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN estados.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 205 (class 1259 OID 24879)
-- Dependencies: 204 9
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
-- TOC entry 3500 (class 0 OID 0)
-- Dependencies: 205
-- Name: Estados_IDEstado_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "Estados_IDEstado_seq" OWNED BY estados.id;


--
-- TOC entry 206 (class 1259 OID 24881)
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
-- TOC entry 3501 (class 0 OID 0)
-- Dependencies: 206
-- Name: TABLE perusud; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE perusud IS 'Tabla con los datos del detalle de los perfiles de usuario. Detalles de entidades habilitadas para el perfil seleccionado';


--
-- TOC entry 3502 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN perusud.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN perusud.id IS 'Identificador unico del detalle de perfil de usuario';


--
-- TOC entry 3503 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN perusud.perusuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN perusud.perusuid IS 'Identificador del perfil al cual pertenece el detalle (accion o proceso permisado)';


--
-- TOC entry 3504 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN perusud.entidaddid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN perusud.entidaddid IS 'Identificador de la accion o proceso permisado (detalles de las entidades)';


--
-- TOC entry 3505 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN perusud.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN perusud.usuarioid IS 'Identificador del usuario que creo el registro o el ultimo en modificarlo';


--
-- TOC entry 3506 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN perusud.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN perusud.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 207 (class 1259 OID 24884)
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
-- TOC entry 3507 (class 0 OID 0)
-- Dependencies: 207
-- Name: PerUsuD_IDPerUsuD_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "PerUsuD_IDPerUsuD_seq" OWNED BY perusud.id;


--
-- TOC entry 208 (class 1259 OID 24886)
-- Dependencies: 2480 9
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
-- TOC entry 3508 (class 0 OID 0)
-- Dependencies: 208
-- Name: TABLE perusu; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE perusu IS 'Tabla con los perfiles de usuarios';


--
-- TOC entry 3509 (class 0 OID 0)
-- Dependencies: 208
-- Name: COLUMN perusu.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN perusu.id IS 'Identificador del perfl de usuario';


--
-- TOC entry 3510 (class 0 OID 0)
-- Dependencies: 208
-- Name: COLUMN perusu.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN perusu.nombre IS 'Nombre del perfil de usuario';


--
-- TOC entry 3511 (class 0 OID 0)
-- Dependencies: 208
-- Name: COLUMN perusu.inactivo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN perusu.inactivo IS 'Si el pelfil de usuario esta Inactivo o no';


--
-- TOC entry 3512 (class 0 OID 0)
-- Dependencies: 208
-- Name: COLUMN perusu.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN perusu.usuarioid IS 'Identificador de usuario que creo o el ultimo que actualizo el registro';


--
-- TOC entry 3513 (class 0 OID 0)
-- Dependencies: 208
-- Name: COLUMN perusu.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN perusu.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 209 (class 1259 OID 24890)
-- Dependencies: 9 208
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
-- TOC entry 3514 (class 0 OID 0)
-- Dependencies: 209
-- Name: PerUsu_IDPerUsu_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "PerUsu_IDPerUsu_seq" OWNED BY perusu.id;


--
-- TOC entry 210 (class 1259 OID 24892)
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
-- TOC entry 3515 (class 0 OID 0)
-- Dependencies: 210
-- Name: TABLE pregsecr; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE pregsecr IS 'Tablas con las preguntas secretas validas para la recuperacion de contraseñas';


--
-- TOC entry 3516 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN pregsecr.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN pregsecr.id IS 'Identificador unico de la pregunta secreta';


--
-- TOC entry 3517 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN pregsecr.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN pregsecr.nombre IS 'Texto de la pregunta secreta';


--
-- TOC entry 3518 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN pregsecr.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN pregsecr.usuarioid IS 'Identificado del ultimo usuario que creo o actualizo el registro';


--
-- TOC entry 3519 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN pregsecr.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN pregsecr.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 211 (class 1259 OID 24895)
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
-- TOC entry 3520 (class 0 OID 0)
-- Dependencies: 211
-- Name: PregSecr_IDPregSecr_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "PregSecr_IDPregSecr_seq" OWNED BY pregsecr.id;


--
-- TOC entry 212 (class 1259 OID 24897)
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
-- TOC entry 3521 (class 0 OID 0)
-- Dependencies: 212
-- Name: TABLE replegal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE replegal IS 'Tabla con los datos de los Accionistas de los contribuyentes';


--
-- TOC entry 3522 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.id IS 'Identificador unico del representante legal';


--
-- TOC entry 3523 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.contribuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.contribuid IS 'Identificador del contribuyente';


--
-- TOC entry 3524 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.nombre IS 'Nombre del representante legal';


--
-- TOC entry 3525 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.apellido; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.apellido IS 'Apellidos del representante legal';


--
-- TOC entry 3526 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.ci; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.ci IS 'Cedula de identidad, numero de pasaporte';


--
-- TOC entry 3527 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.domfiscal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.domfiscal IS 'Domicilio fiscal del representante legal';


--
-- TOC entry 3528 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.estadoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.estadoid IS 'Identificador del estado geografico';


--
-- TOC entry 3529 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.ciudadid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.ciudadid IS 'Identificador de la ciudad';


--
-- TOC entry 3530 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.zonaposta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.zonaposta IS 'Zona postal';


--
-- TOC entry 3531 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.telefhab; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.telefhab IS 'Telefono de habitacion del representante legal';


--
-- TOC entry 3532 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.telefofc; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.telefofc IS 'Telefono de oficina del representante legal';


--
-- TOC entry 3533 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.fax; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.fax IS 'Fax del representante legal';


--
-- TOC entry 3534 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.email; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.email IS 'Direccion de email del contribuyente';


--
-- TOC entry 3535 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.pinbb; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.pinbb IS 'Pin de BlackBerry';


--
-- TOC entry 3536 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.skype; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.skype IS 'Direccion de skype del representante legal';


--
-- TOC entry 3537 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.cextra1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.cextra1 IS 'Campo extra 1';


--
-- TOC entry 3538 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.cextra2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.cextra2 IS 'Campo extra 2';


--
-- TOC entry 3539 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.cextra3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.cextra3 IS 'Campo extra 3';


--
-- TOC entry 3540 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.cextra4; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.cextra4 IS 'Campo extra 4';


--
-- TOC entry 3541 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.cextra5; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.cextra5 IS 'Campo extra 5';


--
-- TOC entry 3542 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3543 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 213 (class 1259 OID 24903)
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
-- TOC entry 3544 (class 0 OID 0)
-- Dependencies: 213
-- Name: RepLegal_IDRepLegal_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "RepLegal_IDRepLegal_seq" OWNED BY replegal.id;


--
-- TOC entry 214 (class 1259 OID 24905)
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
-- TOC entry 3545 (class 0 OID 0)
-- Dependencies: 214
-- Name: TABLE tdeclara; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE tdeclara IS 'Tipo de declaracion de impuestos';


--
-- TOC entry 3546 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN tdeclara.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tdeclara.id IS 'Identificador unico de registro';


--
-- TOC entry 3547 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN tdeclara.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tdeclara.nombre IS 'Nombre del tipo de declaracion de impuesto. Ejm. Autoliquidacion, Sustitutiva, etc';


--
-- TOC entry 3548 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN tdeclara.tipo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tdeclara.tipo IS 'Tipo de declaracion a efectuar. Utilizamos este campo para activar/desactivar la seccion correspondiente a los datos de la liquidacion en la planilla de pago de impuestos.
0 = Autoliquidación / Sustitutiva
1 = Multa por pago extemporaneo / Reparo fiscal
2 = Multa
3 = Intereses Moratorios';


--
-- TOC entry 3549 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN tdeclara.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tdeclara.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro.';


--
-- TOC entry 3550 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN tdeclara.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tdeclara.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 215 (class 1259 OID 24908)
-- Dependencies: 9 214
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
-- TOC entry 3551 (class 0 OID 0)
-- Dependencies: 215
-- Name: TDeclara_IDTDeclara_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "TDeclara_IDTDeclara_seq" OWNED BY tdeclara.id;


--
-- TOC entry 216 (class 1259 OID 24910)
-- Dependencies: 2485 2486 9
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
-- TOC entry 3552 (class 0 OID 0)
-- Dependencies: 216
-- Name: TABLE tipegrav; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE tipegrav IS 'Tabla con los tipos de períodos gravables';


--
-- TOC entry 3553 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN tipegrav.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipegrav.id IS 'Identificador del tipo de periodo gravable';


--
-- TOC entry 3554 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN tipegrav.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipegrav.nombre IS 'Nombre del tipo de período gravable. Ejm. Mensual, trimestral, anual';


--
-- TOC entry 3555 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN tipegrav.tipe; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipegrav.tipe IS 'Tipo de periodo. 0=Mensual / 1=Trimestral / 2=Anual';


--
-- TOC entry 3556 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN tipegrav.peano; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipegrav.peano IS 'Numero de periodos gravables en año fiscal';


--
-- TOC entry 3557 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN tipegrav.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipegrav.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3558 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN tipegrav.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipegrav.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 217 (class 1259 OID 24915)
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
-- TOC entry 3559 (class 0 OID 0)
-- Dependencies: 217
-- Name: TiPeGrav_IDTiPeGrav_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "TiPeGrav_IDTiPeGrav_seq" OWNED BY tipegrav.id;


--
-- TOC entry 218 (class 1259 OID 24917)
-- Dependencies: 9
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
-- TOC entry 3560 (class 0 OID 0)
-- Dependencies: 218
-- Name: TABLE tipocont; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE tipocont IS 'Tabla con los tipos de contribuyentes';


--
-- TOC entry 3561 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN tipocont.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipocont.id IS 'Identificador unico del tipo de contribuyente';


--
-- TOC entry 3562 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN tipocont.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipocont.nombre IS 'Nombre o descripción del tipo de contribuyente. Ejm Exibidores cinematográficos';


--
-- TOC entry 3563 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN tipocont.tipegravid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipocont.tipegravid IS 'Identificador del tipo de periodo gravable';


--
-- TOC entry 3564 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN tipocont.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipocont.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3565 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN tipocont.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipocont.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 219 (class 1259 OID 24920)
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
-- TOC entry 3566 (class 0 OID 0)
-- Dependencies: 219
-- Name: TipoCont_IDTipoCont_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "TipoCont_IDTipoCont_seq" OWNED BY tipocont.id;


--
-- TOC entry 220 (class 1259 OID 24922)
-- Dependencies: 2489 9
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
-- TOC entry 3567 (class 0 OID 0)
-- Dependencies: 220
-- Name: TABLE undtrib; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE undtrib IS 'Tabla con los valores de conversion de las unidades tributarias';


--
-- TOC entry 3568 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN undtrib.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN undtrib.id IS 'Identificador unico de registro';


--
-- TOC entry 3569 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN undtrib.fecha; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN undtrib.fecha IS 'Fecha a partir de la cual esta vigente el valor de la unidad tributaria';


--
-- TOC entry 3570 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN undtrib.valor; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN undtrib.valor IS 'Valor en Bs de una unidad tributaria';


--
-- TOC entry 3571 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN undtrib.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN undtrib.usuarioid IS 'Identificador del ultimo usuario que creo o modifico un registro';


--
-- TOC entry 3572 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN undtrib.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN undtrib.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 221 (class 1259 OID 24926)
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
-- TOC entry 3573 (class 0 OID 0)
-- Dependencies: 221
-- Name: UndTrib_IDUndTrib_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "UndTrib_IDUndTrib_seq" OWNED BY undtrib.id;


--
-- TOC entry 222 (class 1259 OID 24928)
-- Dependencies: 2491 9
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
-- TOC entry 3574 (class 0 OID 0)
-- Dependencies: 222
-- Name: TABLE usfonpto; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE usfonpto IS 'Tabla con los Tokens activos por usuario Fonprocine, es Tokens se utilizaran para validad la creacion de usuarios, recuperacion de contraseñas, etc.';


--
-- TOC entry 3575 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN usfonpto.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpto.id IS 'Identificador unico del Token';


--
-- TOC entry 3576 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN usfonpto.token; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpto.token IS 'Token generado';


--
-- TOC entry 3577 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN usfonpto.usfonproid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpto.usfonproid IS 'Identificador del usuario de fonprocine';


--
-- TOC entry 3578 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN usfonpto.fechacrea; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpto.fechacrea IS 'Fecha hora creacion del token';


--
-- TOC entry 3579 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN usfonpto.fechacadu; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpto.fechacadu IS 'Fecha hora caducidad del token';


--
-- TOC entry 3580 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN usfonpto.usado; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpto.usado IS 'Si el token fue usuario por el usuario o no';


--
-- TOC entry 223 (class 1259 OID 24935)
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
-- TOC entry 3581 (class 0 OID 0)
-- Dependencies: 223
-- Name: UsFonpTo_IDUsFonpTo_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "UsFonpTo_IDUsFonpTo_seq" OWNED BY usfonpto.id;


--
-- TOC entry 224 (class 1259 OID 24937)
-- Dependencies: 2493 9
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
-- TOC entry 3582 (class 0 OID 0)
-- Dependencies: 224
-- Name: TABLE usfonpro; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE usfonpro IS 'Tabla con los datos de los usuarios de la organizacion';


--
-- TOC entry 3583 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.id IS 'Identificador unico de usuario';


--
-- TOC entry 3584 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.login; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.login IS 'Login de usuario';


--
-- TOC entry 3585 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.password; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.password IS 'Passwrod de usuario';


--
-- TOC entry 3586 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.nombre IS 'Nombre del usuario';


--
-- TOC entry 3587 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.email; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.email IS 'Email del usuario';


--
-- TOC entry 3588 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.telefofc; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.telefofc IS 'Telefono de oficina';


--
-- TOC entry 3589 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.extension; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.extension IS 'Extension telefonica';


--
-- TOC entry 3590 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.departamid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.departamid IS 'Identificador del departamento al que pertenece el usuario';


--
-- TOC entry 3591 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.cargoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.cargoid IS 'Identificador del cargo del usuario';


--
-- TOC entry 3592 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.inactivo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.inactivo IS 'Si el usuario esta inactivo o no';


--
-- TOC entry 3593 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.pregsecrid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.pregsecrid IS 'Identificador de la pregunta secreta';


--
-- TOC entry 3594 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.respuesta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.respuesta IS 'Hash de la respuesta a la pregunta secreta';


--
-- TOC entry 3595 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.perusuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.perusuid IS 'Identificador del perfil de usuario';


--
-- TOC entry 3596 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.ultlogin; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.ultlogin IS 'Fecha hora del login del usuario al sistema';


--
-- TOC entry 3597 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.usuarioid IS 'Identificador del usuario que creo el registro o del ultimo que lo modifico';


--
-- TOC entry 3598 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 225 (class 1259 OID 24944)
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
-- TOC entry 3599 (class 0 OID 0)
-- Dependencies: 225
-- Name: Usuarios_IDUsuario_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "Usuarios_IDUsuario_seq" OWNED BY usfonpro.id;


--
-- TOC entry 226 (class 1259 OID 24946)
-- Dependencies: 2495 2496 2497 9
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
-- TOC entry 3600 (class 0 OID 0)
-- Dependencies: 226
-- Name: TABLE accionis; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE accionis IS 'Tabla con los datos de los Accionistas de los contribuyentes';


--
-- TOC entry 3601 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.id IS 'Identificador unico del accionista';


--
-- TOC entry 3602 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.contribuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.contribuid IS 'Identificador del contribuyente';


--
-- TOC entry 3603 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.nombre IS 'Nombre del accionista';


--
-- TOC entry 3604 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.apellido; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.apellido IS 'Apellidos del accionista';


--
-- TOC entry 3605 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.ci; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.ci IS 'Cedula de identidad, numero de pasaporte';


--
-- TOC entry 3606 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.domfiscal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.domfiscal IS 'Domicilio fiscal del accionista';


--
-- TOC entry 3607 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.nuacciones; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.nuacciones IS 'Numero de acciones';


--
-- TOC entry 3608 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.valaccion; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.valaccion IS 'Valor nominal de las acciones';


--
-- TOC entry 3609 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.cextra1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.cextra1 IS 'Campo extra 1';


--
-- TOC entry 3610 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.cextra2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.cextra2 IS 'Campo extra 2';


--
-- TOC entry 3611 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.cextra3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.cextra3 IS 'Campo extra 3';


--
-- TOC entry 3612 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.cextra4; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.cextra4 IS 'Campo extra 4';


--
-- TOC entry 3613 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.cextra5; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.cextra5 IS 'Campo extra 5';


--
-- TOC entry 3614 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3615 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 227 (class 1259 OID 24955)
-- Dependencies: 2498 9
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
-- TOC entry 228 (class 1259 OID 24962)
-- Dependencies: 227 9
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
-- TOC entry 3616 (class 0 OID 0)
-- Dependencies: 228
-- Name: actas_reparo_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE actas_reparo_id_seq OWNED BY actas_reparo.id;


--
-- TOC entry 229 (class 1259 OID 24964)
-- Dependencies: 2500 2501 2502 2503 2504 2505 2506 2507 9
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
-- TOC entry 3617 (class 0 OID 0)
-- Dependencies: 229
-- Name: TABLE asiento; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE asiento IS 'Tabla con los datos cabecera de los asiento contable';


--
-- TOC entry 3618 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN asiento.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.id IS 'Identificador unico de registro';


--
-- TOC entry 3619 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN asiento.nuasiento; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.nuasiento IS 'Numero de asiento. Empieza en uno al comienzo de cada mes.

Este valor de este campo lo asigna la base de datos';


--
-- TOC entry 3620 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN asiento.fecha; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.fecha IS 'Fecha del asiento';


--
-- TOC entry 3621 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN asiento.mes; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.mes IS 'Mes del asiento. Lo utilizamos para evitar que se utilice un numero de asiento repetido para un mes/año.

Este valor de este campo lo asigna la base de datos';


--
-- TOC entry 3622 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN asiento.ano; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.ano IS 'Año del asiento. Lo utilizamos para evitar que se utilice un numero de asiento repetido para un mes/año.

Este valor de este campo lo asigna la base de datos';


--
-- TOC entry 3623 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN asiento.debe; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.debe IS 'Sumatoria del debe del asiento.

Este valor de este campo lo asigna la base de datos';


--
-- TOC entry 3624 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN asiento.haber; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.haber IS 'Sumatoria del debe del asiento.

Este valor de este campo lo asigna la base de datos';


--
-- TOC entry 3625 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN asiento.saldo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.saldo IS 'Saldo del asiento.

Este valor de este campo lo asigna la base de datos.';


--
-- TOC entry 3626 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN asiento.comentar; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.comentar IS 'Comentario u observaciones del asiento';


--
-- TOC entry 3627 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN asiento.cerrado; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.cerrado IS 'Si el asiento esta cerrado o no. Solo se pueden cerrar asientos que el saldo sea 0. Un asiento cerrado no puede ser modificado';


--
-- TOC entry 3628 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN asiento.uscierreid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.uscierreid IS 'Identificador del usuario que cerro el asiento';


--
-- TOC entry 3629 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN asiento.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.usuarioid IS 'Identificador del ultimo usuario en crear o modificar el registro';


--
-- TOC entry 3630 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN asiento.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 230 (class 1259 OID 24978)
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
-- TOC entry 3631 (class 0 OID 0)
-- Dependencies: 230
-- Name: TABLE asientom; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE asientom IS 'Tabla con los asientos modelos a utilizar';


--
-- TOC entry 3632 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN asientom.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientom.id IS 'Identificador unico de registro';


--
-- TOC entry 3633 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN asientom.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientom.nombre IS 'nombre del asiento modelo';


--
-- TOC entry 3634 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN asientom.comentar; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientom.comentar IS 'Comentarios u observaciones';


--
-- TOC entry 3635 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN asientom.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientom.usuarioid IS 'Identificador del usuario que creo o el ultimo en modificar el registro';


--
-- TOC entry 3636 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN asientom.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientom.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 231 (class 1259 OID 24984)
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
-- TOC entry 3637 (class 0 OID 0)
-- Dependencies: 231
-- Name: asientom_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE asientom_id_seq OWNED BY asientom.id;


--
-- TOC entry 232 (class 1259 OID 24986)
-- Dependencies: 2509 9
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
-- TOC entry 3638 (class 0 OID 0)
-- Dependencies: 232
-- Name: TABLE asientomd; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE asientomd IS 'Tabla con el detalle de los asientos modelos';


--
-- TOC entry 3639 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN asientomd.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientomd.id IS 'Identificador unico de registro';


--
-- TOC entry 3640 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN asientomd.asientomid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientomd.asientomid IS 'Identificador del asiento';


--
-- TOC entry 3641 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN asientomd.cuenta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientomd.cuenta IS 'Cuenta contable';


--
-- TOC entry 3642 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN asientomd.sentido; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientomd.sentido IS 'Sentido del monto. 0=debe / 1=haber';


--
-- TOC entry 3643 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN asientomd.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientomd.usuarioid IS 'Identificador del usuario que creo el registro o del ultimo en modificarlo';


--
-- TOC entry 3644 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN asientomd.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientomd.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 233 (class 1259 OID 24990)
-- Dependencies: 9 232
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
-- TOC entry 3645 (class 0 OID 0)
-- Dependencies: 233
-- Name: asientomd_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE asientomd_id_seq OWNED BY asientomd.id;


--
-- TOC entry 234 (class 1259 OID 24992)
-- Dependencies: 2511 2512 9
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
-- TOC entry 235 (class 1259 OID 25000)
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
-- TOC entry 3646 (class 0 OID 0)
-- Dependencies: 235
-- Name: asignacion_fiscales_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE asignacion_fiscales_id_seq OWNED BY asignacion_fiscales.id;


--
-- TOC entry 236 (class 1259 OID 25002)
-- Dependencies: 2514 9
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
-- TOC entry 3647 (class 0 OID 0)
-- Dependencies: 236
-- Name: TABLE con_img_doc; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE con_img_doc IS 'Tabla con las imagenes de los documentos subidos por los contribuyentes adjunto a la planilla de complementaria de datos para el registro.';


--
-- TOC entry 3648 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN con_img_doc.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN con_img_doc.id IS 'Campo principal, valor unico identificador.';


--
-- TOC entry 3649 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN con_img_doc.conusuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN con_img_doc.conusuid IS 'ID  del contribuyente al cual estan asociados los documentos guardados.';


--
-- TOC entry 237 (class 1259 OID 25009)
-- Dependencies: 9 236
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
-- TOC entry 3650 (class 0 OID 0)
-- Dependencies: 237
-- Name: con_img_doc_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE con_img_doc_id_seq OWNED BY con_img_doc.id;


--
-- TOC entry 238 (class 1259 OID 25011)
-- Dependencies: 2516 9
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
-- TOC entry 3651 (class 0 OID 0)
-- Dependencies: 238
-- Name: TABLE contrib_calc; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE contrib_calc IS 'Tabla de los contribuyentes a los que se aplicaran calculos';


--
-- TOC entry 3652 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN contrib_calc.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contrib_calc.id IS 'Identificador de los contribuyentes a los que se aplicaran calculos';


--
-- TOC entry 3653 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN contrib_calc.conusuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contrib_calc.conusuid IS 'Identificador de los contribuyentes para capturar su informacion';


--
-- TOC entry 239 (class 1259 OID 25018)
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
-- TOC entry 3654 (class 0 OID 0)
-- Dependencies: 239
-- Name: contrib_calc_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE contrib_calc_id_seq OWNED BY contrib_calc.id;


--
-- TOC entry 240 (class 1259 OID 25020)
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
-- TOC entry 3655 (class 0 OID 0)
-- Dependencies: 240
-- Name: TABLE contributi; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE contributi IS 'tabla con los tipo de contribuyentes por contribuyente';


--
-- TOC entry 3656 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN contributi.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contributi.id IS 'Identificador unico de registro';


--
-- TOC entry 3657 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN contributi.contribuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contributi.contribuid IS 'Id del contribuyente';


--
-- TOC entry 3658 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN contributi.tipocontid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contributi.tipocontid IS 'Identificador del tipo de contribuyente';


--
-- TOC entry 3659 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN contributi.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contributi.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 241 (class 1259 OID 25023)
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
-- TOC entry 3660 (class 0 OID 0)
-- Dependencies: 241
-- Name: contributi_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE contributi_id_seq OWNED BY contributi.id;


--
-- TOC entry 242 (class 1259 OID 25025)
-- Dependencies: 2519 2520 2521 9
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
-- TOC entry 3661 (class 0 OID 0)
-- Dependencies: 242
-- Name: TABLE conusu_interno; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE conusu_interno IS 'tabla que contiene el detalle de el reistro echo en conusu cuando este lo halla echo un usuario interno en recaudacion';


--
-- TOC entry 243 (class 1259 OID 25034)
-- Dependencies: 9 242
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
-- TOC entry 3662 (class 0 OID 0)
-- Dependencies: 243
-- Name: conusu_interno_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE conusu_interno_id_seq OWNED BY conusu_interno.id;


--
-- TOC entry 244 (class 1259 OID 25036)
-- Dependencies: 2523 9
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
-- TOC entry 3663 (class 0 OID 0)
-- Dependencies: 244
-- Name: COLUMN conusu_tipocont.conusuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu_tipocont.conusuid IS 'Campo que se relaciona con la tabla del contribuyente (conusu)';


--
-- TOC entry 3664 (class 0 OID 0)
-- Dependencies: 244
-- Name: COLUMN conusu_tipocont.tipocontid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu_tipocont.tipocontid IS 'Campo que establece la relacion con los tipos de contribuyentes';


--
-- TOC entry 245 (class 1259 OID 25040)
-- Dependencies: 9 244
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
-- TOC entry 3665 (class 0 OID 0)
-- Dependencies: 245
-- Name: conusu_tipocon_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE conusu_tipocon_id_seq OWNED BY conusu_tipocont.id;


--
-- TOC entry 246 (class 1259 OID 25042)
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
-- TOC entry 247 (class 1259 OID 25048)
-- Dependencies: 9 246
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
-- TOC entry 3666 (class 0 OID 0)
-- Dependencies: 247
-- Name: correlativos_actas_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE correlativos_actas_id_seq OWNED BY correlativos_actas.id;


--
-- TOC entry 248 (class 1259 OID 25050)
-- Dependencies: 2526 2527 9
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
-- TOC entry 3667 (class 0 OID 0)
-- Dependencies: 248
-- Name: TABLE ctaconta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE ctaconta IS 'Tabla con el plan de cuentas contables a utilizar.';


--
-- TOC entry 3668 (class 0 OID 0)
-- Dependencies: 248
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
-- TOC entry 3669 (class 0 OID 0)
-- Dependencies: 248
-- Name: COLUMN ctaconta.descripcion; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN ctaconta.descripcion IS 'Descripcion de la cuenta';


--
-- TOC entry 3670 (class 0 OID 0)
-- Dependencies: 248
-- Name: COLUMN ctaconta.usaraux; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN ctaconta.usaraux IS 'Si la cuenta usara auxiliares. Esto es para el caso de una cuenta que no use auxiliar, esta podra tener movimiento a nivel de sub-especifico';


--
-- TOC entry 3671 (class 0 OID 0)
-- Dependencies: 248
-- Name: COLUMN ctaconta.inactiva; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN ctaconta.inactiva IS 'Si la cuenta esta inactiva o no';


--
-- TOC entry 3672 (class 0 OID 0)
-- Dependencies: 248
-- Name: COLUMN ctaconta.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN ctaconta.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3673 (class 0 OID 0)
-- Dependencies: 248
-- Name: COLUMN ctaconta.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN ctaconta.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 249 (class 1259 OID 25055)
-- Dependencies: 2528 2529 2530 2531 2532 2533 2534 2535 9
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
-- TOC entry 3674 (class 0 OID 0)
-- Dependencies: 249
-- Name: TABLE declara; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE declara IS 'Planilla de declaracion de impuestos';


--
-- TOC entry 3675 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN declara.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.id IS 'Identificador unico de la declaracion de impuestos';


--
-- TOC entry 3676 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN declara.nudeclara; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.nudeclara IS 'Numero de planilla de declaracion de impuesto';


--
-- TOC entry 3677 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN declara.nudeposito; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.nudeposito IS 'Numero de deposito bancario generado por el sistema';


--
-- TOC entry 3678 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN declara.tdeclaraid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.tdeclaraid IS 'Identificador del tipo de declaracion';


--
-- TOC entry 3679 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN declara.fechaelab; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.fechaelab IS 'Fecha de elaboracion de la planilla de pago de impuestos';


--
-- TOC entry 3680 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN declara.fechaini; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.fechaini IS 'Fecha de inicio del periodo gravable';


--
-- TOC entry 3681 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN declara.fechafin; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.fechafin IS 'Fecha final del periodo gravable';


--
-- TOC entry 3682 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN declara.replegalid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.replegalid IS 'Identificador del representante legal que aparecera en la planilla y firmara la misma';


--
-- TOC entry 3683 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN declara.baseimpo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.baseimpo IS 'Base imponible';


--
-- TOC entry 3684 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN declara.alicuota; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.alicuota IS 'Alicuota impositiva aplicada a la declaracion de impuesto';


--
-- TOC entry 3685 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN declara.exonera; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.exonera IS 'Exoneracion o rebaja';


--
-- TOC entry 3686 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN declara.nuactoexon; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.nuactoexon IS 'Numero de acto en donde se establece la exoneracion o rebaja';


--
-- TOC entry 3687 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN declara.credfiscal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.credfiscal IS 'Credito fiscal';


--
-- TOC entry 3688 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN declara.contribant; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.contribant IS 'Monto de la contribucion pagada en periodos anteriores';


--
-- TOC entry 3689 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN declara.plasustid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.plasustid IS 'Identificador de la planilla que se esta sustituyendo en caso de ser una declaracion sustitutiva';


--
-- TOC entry 3690 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN declara.montopagar; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.montopagar IS 'Monto a pagar';


--
-- TOC entry 3691 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN declara.fechapago; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.fechapago IS 'Fecha de pago en el banco. Se llena este campo cuando se concilian los pagos';


--
-- TOC entry 3692 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN declara.fechaconci; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.fechaconci IS 'Fecha hora de la conciliacion contra los depositos del banco';


--
-- TOC entry 3693 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN declara.asientoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.asientoid IS 'Identificador del asiento contable en donde se registro la informacion del pago';


--
-- TOC entry 3694 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN declara.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.usuarioid IS 'Identificador del usuario que concilio el pago de la declaracion. ';


--
-- TOC entry 3695 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN declara.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 250 (class 1259 OID 25069)
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
    usuarioid integer
);


ALTER TABLE datos.detalle_interes OWNER TO postgres;

--
-- TOC entry 3696 (class 0 OID 0)
-- Dependencies: 250
-- Name: TABLE detalle_interes; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE detalle_interes IS 'Tabla para el registro de los detalles de los intereses';


--
-- TOC entry 3697 (class 0 OID 0)
-- Dependencies: 250
-- Name: COLUMN detalle_interes.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes.id IS 'Identificador del detalle de los intereses';


--
-- TOC entry 3698 (class 0 OID 0)
-- Dependencies: 250
-- Name: COLUMN detalle_interes.intereses; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes.intereses IS 'intereses por mes';


--
-- TOC entry 3699 (class 0 OID 0)
-- Dependencies: 250
-- Name: COLUMN detalle_interes.tasa; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes.tasa IS 'tasa por mes segun el bcv';


--
-- TOC entry 3700 (class 0 OID 0)
-- Dependencies: 250
-- Name: COLUMN detalle_interes.dias; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes.dias IS 'dias de los meses de cada periodo';


--
-- TOC entry 3701 (class 0 OID 0)
-- Dependencies: 250
-- Name: COLUMN detalle_interes.mes; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes.mes IS 'meses de los periodos para el pago de los intereses';


--
-- TOC entry 3702 (class 0 OID 0)
-- Dependencies: 250
-- Name: COLUMN detalle_interes.anio; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes.anio IS 'anio de periodos';


--
-- TOC entry 3703 (class 0 OID 0)
-- Dependencies: 250
-- Name: COLUMN detalle_interes.intereses_id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes.intereses_id IS 'identificador del id de  la tabla de intereses';


--
-- TOC entry 251 (class 1259 OID 25075)
-- Dependencies: 9 250
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
-- TOC entry 3704 (class 0 OID 0)
-- Dependencies: 251
-- Name: detalle_interes_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE detalle_interes_id_seq OWNED BY detalle_interes.id;


--
-- TOC entry 252 (class 1259 OID 25077)
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
-- TOC entry 3705 (class 0 OID 0)
-- Dependencies: 252
-- Name: TABLE detalle_interes_viejo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE detalle_interes_viejo IS 'Tabla para el registro de los detalles de los intereses';


--
-- TOC entry 3706 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN detalle_interes_viejo.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes_viejo.id IS 'Identificador del detalle de los intereses';


--
-- TOC entry 3707 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN detalle_interes_viejo.intereses; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes_viejo.intereses IS 'intereses por mes';


--
-- TOC entry 3708 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN detalle_interes_viejo.tasa; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes_viejo.tasa IS 'tasa por mes segun el bcv';


--
-- TOC entry 3709 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN detalle_interes_viejo.dias; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes_viejo.dias IS 'dias de los meses de cada periodo';


--
-- TOC entry 3710 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN detalle_interes_viejo.mes; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes_viejo.mes IS 'meses de los periodos para el pago de los intereses';


--
-- TOC entry 3711 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN detalle_interes_viejo.anio; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes_viejo.anio IS 'anio de periodos';


--
-- TOC entry 3712 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN detalle_interes_viejo.intereses_id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes_viejo.intereses_id IS 'identificador del id de  la tabla de intereses';


--
-- TOC entry 253 (class 1259 OID 25083)
-- Dependencies: 252 9
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
-- TOC entry 3713 (class 0 OID 0)
-- Dependencies: 253
-- Name: detalle_interes_id_seq1; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE detalle_interes_id_seq1 OWNED BY detalle_interes_viejo.id;


--
-- TOC entry 254 (class 1259 OID 25085)
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
-- TOC entry 255 (class 1259 OID 25091)
-- Dependencies: 254 9
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
-- TOC entry 3714 (class 0 OID 0)
-- Dependencies: 255
-- Name: detalles_contrib_calc_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE detalles_contrib_calc_id_seq OWNED BY detalles_contrib_calc.id;


--
-- TOC entry 256 (class 1259 OID 25093)
-- Dependencies: 2539 2540 2541 9
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
-- TOC entry 257 (class 1259 OID 25102)
-- Dependencies: 9 256
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
-- TOC entry 3715 (class 0 OID 0)
-- Dependencies: 257
-- Name: dettalles_fizcalizacion_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE dettalles_fizcalizacion_id_seq OWNED BY dettalles_fizcalizacion.id;


--
-- TOC entry 258 (class 1259 OID 25104)
-- Dependencies: 2543 9
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
-- TOC entry 3716 (class 0 OID 0)
-- Dependencies: 258
-- Name: TABLE document; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE document IS 'Tabla con los documentos legales utilizados por el sistema';


--
-- TOC entry 3717 (class 0 OID 0)
-- Dependencies: 258
-- Name: COLUMN document.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN document.id IS 'Identificador unico de registro';


--
-- TOC entry 3718 (class 0 OID 0)
-- Dependencies: 258
-- Name: COLUMN document.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN document.nombre IS 'Nombre del documento';


--
-- TOC entry 3719 (class 0 OID 0)
-- Dependencies: 258
-- Name: COLUMN document.docu; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN document.docu IS 'Texto del documento';


--
-- TOC entry 3720 (class 0 OID 0)
-- Dependencies: 258
-- Name: COLUMN document.inactivo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN document.inactivo IS 'Si el documento esta inactivo o activo';


--
-- TOC entry 3721 (class 0 OID 0)
-- Dependencies: 258
-- Name: COLUMN document.usfonproid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN document.usfonproid IS 'Identificador del ususario que creo o el ultimo que modifico el registro';


--
-- TOC entry 3722 (class 0 OID 0)
-- Dependencies: 258
-- Name: COLUMN document.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN document.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 259 (class 1259 OID 25111)
-- Dependencies: 9 258
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
-- TOC entry 3723 (class 0 OID 0)
-- Dependencies: 259
-- Name: document_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE document_id_seq OWNED BY document.id;


--
-- TOC entry 260 (class 1259 OID 25113)
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
-- TOC entry 261 (class 1259 OID 25119)
-- Dependencies: 260 9
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
-- TOC entry 3724 (class 0 OID 0)
-- Dependencies: 261
-- Name: interes_bcv_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE interes_bcv_id_seq OWNED BY interes_bcv.id;


--
-- TOC entry 262 (class 1259 OID 25121)
-- Dependencies: 2546 9
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
-- TOC entry 263 (class 1259 OID 25128)
-- Dependencies: 9 262
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
-- TOC entry 3725 (class 0 OID 0)
-- Dependencies: 263
-- Name: presidente_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE presidente_id_seq OWNED BY presidente.id;


--
-- TOC entry 264 (class 1259 OID 25130)
-- Dependencies: 2548 2549 2550 2551 9
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
    recibido_por character varying
);


ALTER TABLE datos.reparos OWNER TO postgres;

--
-- TOC entry 3726 (class 0 OID 0)
-- Dependencies: 264
-- Name: COLUMN reparos.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN reparos.id IS 'Identificador unico de la declaracion de impuestos';


--
-- TOC entry 3727 (class 0 OID 0)
-- Dependencies: 264
-- Name: COLUMN reparos.tdeclaraid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN reparos.tdeclaraid IS 'Identificador del tipo de declaracion';


--
-- TOC entry 3728 (class 0 OID 0)
-- Dependencies: 264
-- Name: COLUMN reparos.fechaelab; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN reparos.fechaelab IS 'Fecha de elaboracion de la planilla de pago de impuestos';


--
-- TOC entry 3729 (class 0 OID 0)
-- Dependencies: 264
-- Name: COLUMN reparos.montopagar; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN reparos.montopagar IS 'Monto a pagar';


--
-- TOC entry 3730 (class 0 OID 0)
-- Dependencies: 264
-- Name: COLUMN reparos.asientoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN reparos.asientoid IS 'Identificador del asiento contable en donde se registro la informacion del pago';


--
-- TOC entry 3731 (class 0 OID 0)
-- Dependencies: 264
-- Name: COLUMN reparos.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN reparos.usuarioid IS 'Identificador del usuario que concilio el pago de la declaracion. ';


--
-- TOC entry 3732 (class 0 OID 0)
-- Dependencies: 264
-- Name: COLUMN reparos.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN reparos.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 265 (class 1259 OID 25140)
-- Dependencies: 2552 2553 9
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
-- TOC entry 3733 (class 0 OID 0)
-- Dependencies: 265
-- Name: TABLE tmpaccioni; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE tmpaccioni IS 'Tabla con los datos de los Accionistas de los contribuyentes';


--
-- TOC entry 3734 (class 0 OID 0)
-- Dependencies: 265
-- Name: COLUMN tmpaccioni.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.id IS 'Identificador unico del accionista';


--
-- TOC entry 3735 (class 0 OID 0)
-- Dependencies: 265
-- Name: COLUMN tmpaccioni.contribuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.contribuid IS 'Identificador del contribuyente';


--
-- TOC entry 3736 (class 0 OID 0)
-- Dependencies: 265
-- Name: COLUMN tmpaccioni.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.nombre IS 'Nombre del accionista';


--
-- TOC entry 3737 (class 0 OID 0)
-- Dependencies: 265
-- Name: COLUMN tmpaccioni.apellido; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.apellido IS 'Apellidos del accionista';


--
-- TOC entry 3738 (class 0 OID 0)
-- Dependencies: 265
-- Name: COLUMN tmpaccioni.ci; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.ci IS 'Cedula de identidad, numero de pasaporte';


--
-- TOC entry 3739 (class 0 OID 0)
-- Dependencies: 265
-- Name: COLUMN tmpaccioni.domfiscal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.domfiscal IS 'Domicilio fiscal del accionista';


--
-- TOC entry 3740 (class 0 OID 0)
-- Dependencies: 265
-- Name: COLUMN tmpaccioni.nuacciones; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.nuacciones IS 'Numero de acciones';


--
-- TOC entry 3741 (class 0 OID 0)
-- Dependencies: 265
-- Name: COLUMN tmpaccioni.valaccion; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.valaccion IS 'Valor nominal de las acciones';


--
-- TOC entry 3742 (class 0 OID 0)
-- Dependencies: 265
-- Name: COLUMN tmpaccioni.cextra1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.cextra1 IS 'Campo extra 1';


--
-- TOC entry 3743 (class 0 OID 0)
-- Dependencies: 265
-- Name: COLUMN tmpaccioni.cextra2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.cextra2 IS 'Campo extra 2';


--
-- TOC entry 3744 (class 0 OID 0)
-- Dependencies: 265
-- Name: COLUMN tmpaccioni.cextra3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.cextra3 IS 'Campo extra 3';


--
-- TOC entry 3745 (class 0 OID 0)
-- Dependencies: 265
-- Name: COLUMN tmpaccioni.cextra4; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.cextra4 IS 'Campo extra 4';


--
-- TOC entry 3746 (class 0 OID 0)
-- Dependencies: 265
-- Name: COLUMN tmpaccioni.cextra5; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.cextra5 IS 'Campo extra 5';


--
-- TOC entry 3747 (class 0 OID 0)
-- Dependencies: 265
-- Name: COLUMN tmpaccioni.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 266 (class 1259 OID 25148)
-- Dependencies: 2554 2555 2556 2557 9
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
-- TOC entry 3748 (class 0 OID 0)
-- Dependencies: 266
-- Name: TABLE tmpcontri; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE tmpcontri IS 'Tabla con los datos temporales de los contribuyentes de la institución. Esta tabla se utiliza para que los contribuyentes hagan una solicitud de actualizacion de datos';


--
-- TOC entry 3749 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN tmpcontri.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.id IS 'Identificador unico del contribuyente';


--
-- TOC entry 3750 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN tmpcontri.tipocontid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.tipocontid IS 'Identificador del tipo de contribuyente';


--
-- TOC entry 3751 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN tmpcontri.razonsocia; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.razonsocia IS 'Razon social del contribuyente';


--
-- TOC entry 3752 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN tmpcontri.dencomerci; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.dencomerci IS 'Denominacion comercial del contribuyente';


--
-- TOC entry 3753 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN tmpcontri.actieconid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.actieconid IS 'Identificador de la actividad economica';


--
-- TOC entry 3754 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN tmpcontri.rif; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.rif IS 'Rif del contribuyente';


--
-- TOC entry 3755 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN tmpcontri.numregcine; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.numregcine IS 'Numero de registro cinematografico';


--
-- TOC entry 3756 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN tmpcontri.domfiscal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.domfiscal IS 'Domicilio fiscal del contribuyente';


--
-- TOC entry 3757 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN tmpcontri.estadoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.estadoid IS 'Identicador del estado geografico';


--
-- TOC entry 3758 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN tmpcontri.ciudadid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.ciudadid IS 'Identificador de la ciudad';


--
-- TOC entry 3759 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN tmpcontri.zonapostal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.zonapostal IS 'Zona postal del contribuyente';


--
-- TOC entry 3760 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN tmpcontri.telef1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.telef1 IS 'Telefono 1 del contribuyente';


--
-- TOC entry 3761 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN tmpcontri.telef2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.telef2 IS 'Telefono 2 del contribuyente';


--
-- TOC entry 3762 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN tmpcontri.telef3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.telef3 IS 'Telefono 3 del contribuyente';


--
-- TOC entry 3763 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN tmpcontri.fax1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.fax1 IS 'Fax 1 del contribuyente';


--
-- TOC entry 3764 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN tmpcontri.fax2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.fax2 IS 'Fax 2 del contribuyente';


--
-- TOC entry 3765 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN tmpcontri.email; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.email IS 'Direccion de email de contribuyente';


--
-- TOC entry 3766 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN tmpcontri.pinbb; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.pinbb IS 'Pin de BlackBerry';


--
-- TOC entry 3767 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN tmpcontri.skype; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.skype IS 'Dirección de skype';


--
-- TOC entry 3768 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN tmpcontri.twitter; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.twitter IS 'Direccion de twitter';


--
-- TOC entry 3769 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN tmpcontri.facebook; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.facebook IS 'Direccion de facebook';


--
-- TOC entry 3770 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN tmpcontri.nuacciones; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.nuacciones IS 'Numero de acciones del contribuyente segun inforacion del registro mercantil';


--
-- TOC entry 3771 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN tmpcontri.valaccion; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.valaccion IS 'Valor nominal por accion segun registro mercantil';


--
-- TOC entry 3772 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN tmpcontri.capitalsus; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.capitalsus IS 'Capital suscrito segun registro mercantil';


--
-- TOC entry 3773 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN tmpcontri.capitalpag; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.capitalpag IS 'Capital pagado segun registro mercantil';


--
-- TOC entry 3774 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN tmpcontri.regmerofc; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.regmerofc IS 'Oficina de registro mercantil en donde se registro la empresa';


--
-- TOC entry 3775 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN tmpcontri.rmnumero; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.rmnumero IS 'Numero de registro del documento de registro mercantil';


--
-- TOC entry 3776 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN tmpcontri.rmfolio; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.rmfolio IS 'Numero de folio del documento de registro mercantil';


--
-- TOC entry 3777 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN tmpcontri.rmtomo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.rmtomo IS 'Numero de folio del documento de registro mercantil';


--
-- TOC entry 3778 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN tmpcontri.rmfechapro; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.rmfechapro IS 'Fecha de protocololizacion del registro del documento de registro mercantil';


--
-- TOC entry 3779 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN tmpcontri.rmncontrol; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.rmncontrol IS 'Numero de control del documento de registro mercantil';


--
-- TOC entry 3780 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN tmpcontri.rmobjeto; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.rmobjeto IS 'Objeto de la empresa segun registro mercantil';


--
-- TOC entry 3781 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN tmpcontri.domcomer; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.domcomer IS 'domicilio comercial';


--
-- TOC entry 3782 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN tmpcontri.conusuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.conusuid IS 'Identificador del usuario-contribuyente que creo el registro';


--
-- TOC entry 3783 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN tmpcontri.tiporeg; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.tiporeg IS 'Tipo de registro creado. 0=Nuevo contribuyente, 1=Edicion de datos de contribuyentes';


--
-- TOC entry 3784 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN tmpcontri.cextra1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.cextra1 IS 'Campo extra 1';


--
-- TOC entry 3785 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN tmpcontri.cextra2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.cextra2 IS 'Campo extra 2';


--
-- TOC entry 3786 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN tmpcontri.cextra3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.cextra3 IS 'Campo extra 3';


--
-- TOC entry 3787 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN tmpcontri.cextra4; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.cextra4 IS 'Campo extra 4';


--
-- TOC entry 3788 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN tmpcontri.cextra5; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.cextra5 IS 'Campo extra 5';


--
-- TOC entry 3789 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN tmpcontri.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 267 (class 1259 OID 25158)
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
-- TOC entry 3790 (class 0 OID 0)
-- Dependencies: 267
-- Name: TABLE tmprelegal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE tmprelegal IS 'Tabla con los datos temporales de los representantes legales de los contribuyentes. Esta tabla se utiliza para procesar una solicitud de cambio de datos. El contribuyente copia aqui los nuevos datos';


--
-- TOC entry 3791 (class 0 OID 0)
-- Dependencies: 267
-- Name: COLUMN tmprelegal.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.id IS 'Identificador unico del representante legal';


--
-- TOC entry 3792 (class 0 OID 0)
-- Dependencies: 267
-- Name: COLUMN tmprelegal.contribuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.contribuid IS 'Identificador del contribuyente';


--
-- TOC entry 3793 (class 0 OID 0)
-- Dependencies: 267
-- Name: COLUMN tmprelegal.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.nombre IS 'Nombre del representante legal';


--
-- TOC entry 3794 (class 0 OID 0)
-- Dependencies: 267
-- Name: COLUMN tmprelegal.apellido; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.apellido IS 'Apellidos del representante legal';


--
-- TOC entry 3795 (class 0 OID 0)
-- Dependencies: 267
-- Name: COLUMN tmprelegal.ci; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.ci IS 'Cedula de identidad, numero de pasaporte';


--
-- TOC entry 3796 (class 0 OID 0)
-- Dependencies: 267
-- Name: COLUMN tmprelegal.domfiscal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.domfiscal IS 'Domicilio fiscal del representante legal';


--
-- TOC entry 3797 (class 0 OID 0)
-- Dependencies: 267
-- Name: COLUMN tmprelegal.estadoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.estadoid IS 'Identificador del estado geografico';


--
-- TOC entry 3798 (class 0 OID 0)
-- Dependencies: 267
-- Name: COLUMN tmprelegal.ciudadid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.ciudadid IS 'Identificador de la ciudad';


--
-- TOC entry 3799 (class 0 OID 0)
-- Dependencies: 267
-- Name: COLUMN tmprelegal.zonaposta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.zonaposta IS 'Zona postal';


--
-- TOC entry 3800 (class 0 OID 0)
-- Dependencies: 267
-- Name: COLUMN tmprelegal.telefhab; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.telefhab IS 'Telefono de habitacion del representante legal';


--
-- TOC entry 3801 (class 0 OID 0)
-- Dependencies: 267
-- Name: COLUMN tmprelegal.telefofc; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.telefofc IS 'Telefono de oficina del representante legal';


--
-- TOC entry 3802 (class 0 OID 0)
-- Dependencies: 267
-- Name: COLUMN tmprelegal.fax; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.fax IS 'Fax del representante legal';


--
-- TOC entry 3803 (class 0 OID 0)
-- Dependencies: 267
-- Name: COLUMN tmprelegal.email; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.email IS 'Direccion de email del contribuyente';


--
-- TOC entry 3804 (class 0 OID 0)
-- Dependencies: 267
-- Name: COLUMN tmprelegal.pinbb; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.pinbb IS 'Pin de BlackBerry';


--
-- TOC entry 3805 (class 0 OID 0)
-- Dependencies: 267
-- Name: COLUMN tmprelegal.skype; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.skype IS 'Direccion de skype del representante legal';


--
-- TOC entry 3806 (class 0 OID 0)
-- Dependencies: 267
-- Name: COLUMN tmprelegal.cextra1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.cextra1 IS 'Campo extra 1 ';


--
-- TOC entry 3807 (class 0 OID 0)
-- Dependencies: 267
-- Name: COLUMN tmprelegal.cextra2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.cextra2 IS 'Campo extra 2 ';


--
-- TOC entry 3808 (class 0 OID 0)
-- Dependencies: 267
-- Name: COLUMN tmprelegal.cextra3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.cextra3 IS 'Campo extra 3 ';


--
-- TOC entry 3809 (class 0 OID 0)
-- Dependencies: 267
-- Name: COLUMN tmprelegal.cextra4; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.cextra4 IS 'Campo extra 4 ';


--
-- TOC entry 3810 (class 0 OID 0)
-- Dependencies: 267
-- Name: COLUMN tmprelegal.cextra5; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.cextra5 IS 'Campo extra 5 ';


--
-- TOC entry 3811 (class 0 OID 0)
-- Dependencies: 267
-- Name: COLUMN tmprelegal.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 268 (class 1259 OID 25164)
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

SET search_path = historial, pg_catalog;

--
-- TOC entry 269 (class 1259 OID 25170)
-- Dependencies: 2558 10
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
-- TOC entry 3812 (class 0 OID 0)
-- Dependencies: 269
-- Name: TABLE bitacora; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON TABLE bitacora IS 'Tabla con la bitacora de los datos cambiados de todas las tablas del sistema';


--
-- TOC entry 3813 (class 0 OID 0)
-- Dependencies: 269
-- Name: COLUMN bitacora.id; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON COLUMN bitacora.id IS 'Identificador de la bitacora';


--
-- TOC entry 3814 (class 0 OID 0)
-- Dependencies: 269
-- Name: COLUMN bitacora.fecha; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON COLUMN bitacora.fecha IS 'Fecha/Hora de la transaccion';


--
-- TOC entry 3815 (class 0 OID 0)
-- Dependencies: 269
-- Name: COLUMN bitacora.tabla; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON COLUMN bitacora.tabla IS 'Nombre de tabla sobre la cual se ejecuto la transaccion';


--
-- TOC entry 3816 (class 0 OID 0)
-- Dependencies: 269
-- Name: COLUMN bitacora.idusuario; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON COLUMN bitacora.idusuario IS 'Identificador del usuario que genero la transaccion';


--
-- TOC entry 3817 (class 0 OID 0)
-- Dependencies: 269
-- Name: COLUMN bitacora.accion; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON COLUMN bitacora.accion IS 'Accion ejecutada sobre la tabla. 0.- Insert / 1.- Update / 2.- Delete';


--
-- TOC entry 3818 (class 0 OID 0)
-- Dependencies: 269
-- Name: COLUMN bitacora.datosnew; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON COLUMN bitacora.datosnew IS 'Datos nuevos para el caso de los insert y los Update';


--
-- TOC entry 3819 (class 0 OID 0)
-- Dependencies: 269
-- Name: COLUMN bitacora.datosold; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON COLUMN bitacora.datosold IS 'Datos originales para el caso de los Update';


--
-- TOC entry 3820 (class 0 OID 0)
-- Dependencies: 269
-- Name: COLUMN bitacora.datosdel; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON COLUMN bitacora.datosdel IS 'Datos eliminados para el caso de los Delete';


--
-- TOC entry 3821 (class 0 OID 0)
-- Dependencies: 269
-- Name: COLUMN bitacora.valdelid; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON COLUMN bitacora.valdelid IS 'ID del registro que fue borrado';


--
-- TOC entry 3822 (class 0 OID 0)
-- Dependencies: 269
-- Name: COLUMN bitacora.ip; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON COLUMN bitacora.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 270 (class 1259 OID 25177)
-- Dependencies: 10 269
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
-- TOC entry 3824 (class 0 OID 0)
-- Dependencies: 270
-- Name: Bitacora_IDBitacora_seq; Type: SEQUENCE OWNED BY; Schema: historial; Owner: postgres
--

ALTER SEQUENCE "Bitacora_IDBitacora_seq" OWNED BY bitacora.id;


SET search_path = pre_aprobacion, pg_catalog;

--
-- TOC entry 271 (class 1259 OID 25179)
-- Dependencies: 2560 2561 2562 2563 6
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
-- TOC entry 272 (class 1259 OID 25189)
-- Dependencies: 6 271
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
-- TOC entry 3826 (class 0 OID 0)
-- Dependencies: 272
-- Name: datos_cnac_id_seq; Type: SEQUENCE OWNED BY; Schema: pre_aprobacion; Owner: postgres
--

ALTER SEQUENCE datos_cnac_id_seq OWNED BY datos_cnac.id;


--
-- TOC entry 273 (class 1259 OID 25191)
-- Dependencies: 2565 6
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
-- TOC entry 3827 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN intereses.multaid; Type: COMMENT; Schema: pre_aprobacion; Owner: postgres
--

COMMENT ON COLUMN intereses.multaid IS 'campor para relacionar con la tabla de multas';


--
-- TOC entry 274 (class 1259 OID 25198)
-- Dependencies: 6 273
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
-- TOC entry 3828 (class 0 OID 0)
-- Dependencies: 274
-- Name: intereses_id_seq; Type: SEQUENCE OWNED BY; Schema: pre_aprobacion; Owner: postgres
--

ALTER SEQUENCE intereses_id_seq OWNED BY intereses.id;


--
-- TOC entry 275 (class 1259 OID 25200)
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
    tipo_multa integer
);


ALTER TABLE pre_aprobacion.multas OWNER TO postgres;

--
-- TOC entry 3829 (class 0 OID 0)
-- Dependencies: 275
-- Name: TABLE multas; Type: COMMENT; Schema: pre_aprobacion; Owner: postgres
--

COMMENT ON TABLE multas IS 'tabla que contiene el calculo de las multas por declaraciones extemporaneas o reparo fiscal';


--
-- TOC entry 276 (class 1259 OID 25206)
-- Dependencies: 6 275
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
-- TOC entry 3830 (class 0 OID 0)
-- Dependencies: 276
-- Name: multas_id_seq; Type: SEQUENCE OWNED BY; Schema: pre_aprobacion; Owner: postgres
--

ALTER SEQUENCE multas_id_seq OWNED BY multas.id;


SET search_path = public, pg_catalog;

--
-- TOC entry 277 (class 1259 OID 25208)
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
-- TOC entry 278 (class 1259 OID 25211)
-- Dependencies: 2568 7
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
-- TOC entry 279 (class 1259 OID 25218)
-- Dependencies: 278 7
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
-- TOC entry 3831 (class 0 OID 0)
-- Dependencies: 279
-- Name: tbl_cargos_id_seq; Type: SEQUENCE OWNED BY; Schema: seg; Owner: postgres
--

ALTER SEQUENCE tbl_cargos_id_seq OWNED BY tbl_cargos.id;


--
-- TOC entry 280 (class 1259 OID 25220)
-- Dependencies: 2570 2571 2572 2573 7
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
-- TOC entry 3832 (class 0 OID 0)
-- Dependencies: 280
-- Name: TABLE tbl_ci_sessions; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON TABLE tbl_ci_sessions IS 'Sesiones manejadas por CodeIgniter';


--
-- TOC entry 281 (class 1259 OID 25230)
-- Dependencies: 2574 7
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
-- TOC entry 3833 (class 0 OID 0)
-- Dependencies: 281
-- Name: TABLE tbl_modulo; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON TABLE tbl_modulo IS 'Módulos del sistema';


--
-- TOC entry 282 (class 1259 OID 25237)
-- Dependencies: 281 7
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
-- TOC entry 3834 (class 0 OID 0)
-- Dependencies: 282
-- Name: tbl_modulo_id_modulo_seq; Type: SEQUENCE OWNED BY; Schema: seg; Owner: postgres
--

ALTER SEQUENCE tbl_modulo_id_modulo_seq OWNED BY tbl_modulo.id_modulo;


--
-- TOC entry 283 (class 1259 OID 25239)
-- Dependencies: 2576 2577 7
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
-- TOC entry 284 (class 1259 OID 25247)
-- Dependencies: 283 7
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
-- TOC entry 3835 (class 0 OID 0)
-- Dependencies: 284
-- Name: tbl_oficinas_id_seq; Type: SEQUENCE OWNED BY; Schema: seg; Owner: postgres
--

ALTER SEQUENCE tbl_oficinas_id_seq OWNED BY tbl_oficinas.id;


--
-- TOC entry 285 (class 1259 OID 25249)
-- Dependencies: 2579 7
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
-- TOC entry 3836 (class 0 OID 0)
-- Dependencies: 285
-- Name: TABLE tbl_permiso; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON TABLE tbl_permiso IS 'Permisos de los roles sobre los módulos';


--
-- TOC entry 286 (class 1259 OID 25253)
-- Dependencies: 285 7
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
-- TOC entry 3837 (class 0 OID 0)
-- Dependencies: 286
-- Name: tbl_permiso_id_permiso_seq; Type: SEQUENCE OWNED BY; Schema: seg; Owner: postgres
--

ALTER SEQUENCE tbl_permiso_id_permiso_seq OWNED BY tbl_permiso.id_permiso;


--
-- TOC entry 287 (class 1259 OID 25255)
-- Dependencies: 2581 7
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
-- TOC entry 3838 (class 0 OID 0)
-- Dependencies: 287
-- Name: TABLE tbl_permiso_trampa; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON TABLE tbl_permiso_trampa IS 'Permisos de los roles sobre los módulos';


--
-- TOC entry 288 (class 1259 OID 25259)
-- Dependencies: 7 287
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
-- TOC entry 3839 (class 0 OID 0)
-- Dependencies: 288
-- Name: tbl_permiso_trampa_id_permiso_seq; Type: SEQUENCE OWNED BY; Schema: seg; Owner: postgres
--

ALTER SEQUENCE tbl_permiso_trampa_id_permiso_seq OWNED BY tbl_permiso_trampa.id_permiso;


--
-- TOC entry 289 (class 1259 OID 25261)
-- Dependencies: 2583 7
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
-- TOC entry 3840 (class 0 OID 0)
-- Dependencies: 289
-- Name: TABLE tbl_rol; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON TABLE tbl_rol IS 'Roles de los usuarios del sistema';


--
-- TOC entry 290 (class 1259 OID 25268)
-- Dependencies: 289 7
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
-- TOC entry 3841 (class 0 OID 0)
-- Dependencies: 290
-- Name: tbl_rol_id_rol_seq; Type: SEQUENCE OWNED BY; Schema: seg; Owner: postgres
--

ALTER SEQUENCE tbl_rol_id_rol_seq OWNED BY tbl_rol.id_rol;


--
-- TOC entry 291 (class 1259 OID 25270)
-- Dependencies: 2585 7
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
-- TOC entry 3842 (class 0 OID 0)
-- Dependencies: 291
-- Name: TABLE tbl_rol_usuario; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON TABLE tbl_rol_usuario IS 'Roles de los usuarios, un usuario puede tener multiples roles dentro del sistema';


--
-- TOC entry 3843 (class 0 OID 0)
-- Dependencies: 291
-- Name: COLUMN tbl_rol_usuario.id_rol_usuario; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON COLUMN tbl_rol_usuario.id_rol_usuario IS 'Identificador del usuario';


--
-- TOC entry 3844 (class 0 OID 0)
-- Dependencies: 291
-- Name: COLUMN tbl_rol_usuario.id_rol; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON COLUMN tbl_rol_usuario.id_rol IS 'Relación con el rol';


--
-- TOC entry 3845 (class 0 OID 0)
-- Dependencies: 291
-- Name: COLUMN tbl_rol_usuario.id_usuario; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON COLUMN tbl_rol_usuario.id_usuario IS 'Relación con el usuario';


--
-- TOC entry 3846 (class 0 OID 0)
-- Dependencies: 291
-- Name: COLUMN tbl_rol_usuario.bln_borrado; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON COLUMN tbl_rol_usuario.bln_borrado IS 'Marca de borrado lógico';


--
-- TOC entry 292 (class 1259 OID 25274)
-- Dependencies: 7 291
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
-- TOC entry 3847 (class 0 OID 0)
-- Dependencies: 292
-- Name: tbl_rol_usuario_id_rol_usuario_seq; Type: SEQUENCE OWNED BY; Schema: seg; Owner: postgres
--

ALTER SEQUENCE tbl_rol_usuario_id_rol_usuario_seq OWNED BY tbl_rol_usuario.id_rol_usuario;


--
-- TOC entry 293 (class 1259 OID 25276)
-- Dependencies: 2587 2588 2589 2590 7
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
-- TOC entry 3848 (class 0 OID 0)
-- Dependencies: 293
-- Name: TABLE tbl_session_ci; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON TABLE tbl_session_ci IS 'Sesiones manejadas por CodeIgniter';


--
-- TOC entry 294 (class 1259 OID 25286)
-- Dependencies: 2591 7
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
-- TOC entry 3849 (class 0 OID 0)
-- Dependencies: 294
-- Name: TABLE tbl_usuario_rol; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON TABLE tbl_usuario_rol IS 'Permisos de los roles de usuarios sobre los módulos';


--
-- TOC entry 295 (class 1259 OID 25290)
-- Dependencies: 294 7
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
-- TOC entry 3850 (class 0 OID 0)
-- Dependencies: 295
-- Name: tbl_usuario_rol_id_usuario_rol_seq; Type: SEQUENCE OWNED BY; Schema: seg; Owner: postgres
--

ALTER SEQUENCE tbl_usuario_rol_id_usuario_rol_seq OWNED BY tbl_usuario_rol.id_usuario_rol;


--
-- TOC entry 296 (class 1259 OID 25292)
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

SET search_path = "segContribu", pg_catalog;

--
-- TOC entry 297 (class 1259 OID 25298)
-- Dependencies: 2593 8
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
-- TOC entry 3851 (class 0 OID 0)
-- Dependencies: 297
-- Name: TABLE tbl_modulo_contribu; Type: COMMENT; Schema: segContribu; Owner: postgres
--

COMMENT ON TABLE tbl_modulo_contribu IS 'Módulos del sistema';


--
-- TOC entry 298 (class 1259 OID 25305)
-- Dependencies: 297 8
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
-- TOC entry 3852 (class 0 OID 0)
-- Dependencies: 298
-- Name: tbl_modulo_id_modulo_seq; Type: SEQUENCE OWNED BY; Schema: segContribu; Owner: postgres
--

ALTER SEQUENCE tbl_modulo_id_modulo_seq OWNED BY tbl_modulo_contribu.id_modulo;


--
-- TOC entry 299 (class 1259 OID 25307)
-- Dependencies: 2595 8
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
-- TOC entry 3853 (class 0 OID 0)
-- Dependencies: 299
-- Name: TABLE tbl_permiso_contribu; Type: COMMENT; Schema: segContribu; Owner: postgres
--

COMMENT ON TABLE tbl_permiso_contribu IS 'Permisos de los roles sobre los módulos';


--
-- TOC entry 300 (class 1259 OID 25311)
-- Dependencies: 299 8
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
-- TOC entry 3854 (class 0 OID 0)
-- Dependencies: 300
-- Name: tbl_permiso_id_permiso_seq; Type: SEQUENCE OWNED BY; Schema: segContribu; Owner: postgres
--

ALTER SEQUENCE tbl_permiso_id_permiso_seq OWNED BY tbl_permiso_contribu.id_permiso;


--
-- TOC entry 301 (class 1259 OID 25313)
-- Dependencies: 2597 8
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
-- TOC entry 3855 (class 0 OID 0)
-- Dependencies: 301
-- Name: TABLE tbl_rol_contribu; Type: COMMENT; Schema: segContribu; Owner: postgres
--

COMMENT ON TABLE tbl_rol_contribu IS 'Roles de los usuarios del sistema';


--
-- TOC entry 302 (class 1259 OID 25320)
-- Dependencies: 301 8
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
-- TOC entry 3856 (class 0 OID 0)
-- Dependencies: 302
-- Name: tbl_rol_id_rol_seq; Type: SEQUENCE OWNED BY; Schema: segContribu; Owner: postgres
--

ALTER SEQUENCE tbl_rol_id_rol_seq OWNED BY tbl_rol_contribu.id_rol;


--
-- TOC entry 303 (class 1259 OID 25322)
-- Dependencies: 2599 8
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
-- TOC entry 3857 (class 0 OID 0)
-- Dependencies: 303
-- Name: TABLE tbl_rol_usuario_contribu; Type: COMMENT; Schema: segContribu; Owner: postgres
--

COMMENT ON TABLE tbl_rol_usuario_contribu IS 'Roles de los usuarios, un usuario puede tener multiples roles dentro del sistema';


--
-- TOC entry 3858 (class 0 OID 0)
-- Dependencies: 303
-- Name: COLUMN tbl_rol_usuario_contribu.id_rol_usuario; Type: COMMENT; Schema: segContribu; Owner: postgres
--

COMMENT ON COLUMN tbl_rol_usuario_contribu.id_rol_usuario IS 'Identificador del usuario';


--
-- TOC entry 3859 (class 0 OID 0)
-- Dependencies: 303
-- Name: COLUMN tbl_rol_usuario_contribu.id_rol; Type: COMMENT; Schema: segContribu; Owner: postgres
--

COMMENT ON COLUMN tbl_rol_usuario_contribu.id_rol IS 'Relación con el rol';


--
-- TOC entry 3860 (class 0 OID 0)
-- Dependencies: 303
-- Name: COLUMN tbl_rol_usuario_contribu.id_usuario; Type: COMMENT; Schema: segContribu; Owner: postgres
--

COMMENT ON COLUMN tbl_rol_usuario_contribu.id_usuario IS 'Relación con el usuario';


--
-- TOC entry 3861 (class 0 OID 0)
-- Dependencies: 303
-- Name: COLUMN tbl_rol_usuario_contribu.bln_borrado; Type: COMMENT; Schema: segContribu; Owner: postgres
--

COMMENT ON COLUMN tbl_rol_usuario_contribu.bln_borrado IS 'Marca de borrado lógico';


--
-- TOC entry 304 (class 1259 OID 25326)
-- Dependencies: 303 8
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
-- TOC entry 3862 (class 0 OID 0)
-- Dependencies: 304
-- Name: tbl_rol_usuario_id_rol_usuario_seq; Type: SEQUENCE OWNED BY; Schema: segContribu; Owner: postgres
--

ALTER SEQUENCE tbl_rol_usuario_id_rol_usuario_seq OWNED BY tbl_rol_usuario_contribu.id_rol_usuario;


--
-- TOC entry 305 (class 1259 OID 25328)
-- Dependencies: 2601 8
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
-- TOC entry 3863 (class 0 OID 0)
-- Dependencies: 305
-- Name: TABLE tbl_usuario_rol_contribu; Type: COMMENT; Schema: segContribu; Owner: postgres
--

COMMENT ON TABLE tbl_usuario_rol_contribu IS 'Permisos de los roles de usuarios sobre los módulos';


--
-- TOC entry 306 (class 1259 OID 25332)
-- Dependencies: 8 305
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
-- TOC entry 3864 (class 0 OID 0)
-- Dependencies: 306
-- Name: tbl_usuario_rol_id_usuario_rol_seq; Type: SEQUENCE OWNED BY; Schema: segContribu; Owner: postgres
--

ALTER SEQUENCE tbl_usuario_rol_id_usuario_rol_seq OWNED BY tbl_usuario_rol_contribu.id_usuario_rol;


--
-- TOC entry 307 (class 1259 OID 25334)
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
-- TOC entry 2499 (class 2604 OID 25340)
-- Dependencies: 228 227
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY actas_reparo ALTER COLUMN id SET DEFAULT nextval('actas_reparo_id_seq'::regclass);


--
-- TOC entry 2424 (class 2604 OID 25341)
-- Dependencies: 168 167
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY actiecon ALTER COLUMN id SET DEFAULT nextval('"ActiEcon_IDActiEcon_seq"'::regclass);


--
-- TOC entry 2436 (class 2604 OID 25342)
-- Dependencies: 170 169
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY alicimp ALTER COLUMN id SET DEFAULT nextval('"AlicImp_IDAlicImp_seq"'::regclass);


--
-- TOC entry 2439 (class 2604 OID 25343)
-- Dependencies: 172 171
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asientod ALTER COLUMN id SET DEFAULT nextval('"AsientoD_IDAsientoD_seq"'::regclass);


--
-- TOC entry 2508 (class 2604 OID 25344)
-- Dependencies: 231 230
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asientom ALTER COLUMN id SET DEFAULT nextval('asientom_id_seq'::regclass);


--
-- TOC entry 2510 (class 2604 OID 25345)
-- Dependencies: 233 232
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asientomd ALTER COLUMN id SET DEFAULT nextval('asientomd_id_seq'::regclass);


--
-- TOC entry 2513 (class 2604 OID 25346)
-- Dependencies: 235 234
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asignacion_fiscales ALTER COLUMN id SET DEFAULT nextval('asignacion_fiscales_id_seq'::regclass);


--
-- TOC entry 2440 (class 2604 OID 25347)
-- Dependencies: 175 174
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY bacuenta ALTER COLUMN id SET DEFAULT nextval('"BaCuenta_IDBaCuenta_seq"'::regclass);


--
-- TOC entry 2441 (class 2604 OID 25348)
-- Dependencies: 177 176
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY bancos ALTER COLUMN id SET DEFAULT nextval('"Bancos_IDBanco_seq"'::regclass);


--
-- TOC entry 2444 (class 2604 OID 25349)
-- Dependencies: 181 180
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY calpago ALTER COLUMN id SET DEFAULT nextval('"CalPagos_IDCalPago_seq"'::regclass);


--
-- TOC entry 2442 (class 2604 OID 25350)
-- Dependencies: 179 178
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY calpagod ALTER COLUMN id SET DEFAULT nextval('"CalPagoD_IDCalPagoD_seq"'::regclass);


--
-- TOC entry 2445 (class 2604 OID 25351)
-- Dependencies: 183 182
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY cargos ALTER COLUMN id SET DEFAULT nextval('"Cargos_IDCargo_seq"'::regclass);


--
-- TOC entry 2446 (class 2604 OID 25352)
-- Dependencies: 185 184
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY ciudades ALTER COLUMN id SET DEFAULT nextval('"Ciudades_IDCiudad_seq"'::regclass);


--
-- TOC entry 2515 (class 2604 OID 25353)
-- Dependencies: 237 236
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY con_img_doc ALTER COLUMN id SET DEFAULT nextval('con_img_doc_id_seq'::regclass);


--
-- TOC entry 2517 (class 2604 OID 25354)
-- Dependencies: 239 238
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY contrib_calc ALTER COLUMN id SET DEFAULT nextval('contrib_calc_id_seq'::regclass);


--
-- TOC entry 2463 (class 2604 OID 25355)
-- Dependencies: 195 194
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY contribu ALTER COLUMN id SET DEFAULT nextval('"Contribu_IDContribu_seq"'::regclass);


--
-- TOC entry 2518 (class 2604 OID 25356)
-- Dependencies: 241 240
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY contributi ALTER COLUMN id SET DEFAULT nextval('contributi_id_seq'::regclass);


--
-- TOC entry 2458 (class 2604 OID 25357)
-- Dependencies: 193 192
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusu ALTER COLUMN id SET DEFAULT nextval('"ConUsu_IDConUsu_seq"'::regclass);


--
-- TOC entry 2522 (class 2604 OID 25358)
-- Dependencies: 243 242
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusu_interno ALTER COLUMN id SET DEFAULT nextval('conusu_interno_id_seq'::regclass);


--
-- TOC entry 2524 (class 2604 OID 25359)
-- Dependencies: 245 244
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusu_tipocont ALTER COLUMN id SET DEFAULT nextval('conusu_tipocon_id_seq'::regclass);


--
-- TOC entry 2447 (class 2604 OID 25360)
-- Dependencies: 187 186
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusuco ALTER COLUMN id SET DEFAULT nextval('"ConUsuCo_IDConUsuCo_seq"'::regclass);


--
-- TOC entry 2451 (class 2604 OID 25361)
-- Dependencies: 189 188
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusuti ALTER COLUMN id SET DEFAULT nextval('"ConUsuTi_IDConUsuTi_seq"'::regclass);


--
-- TOC entry 2454 (class 2604 OID 25362)
-- Dependencies: 191 190
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusuto ALTER COLUMN id SET DEFAULT nextval('"ConUsuTo_IDConUsuTo_seq"'::regclass);


--
-- TOC entry 2525 (class 2604 OID 25363)
-- Dependencies: 247 246
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY correlativos_actas ALTER COLUMN id SET DEFAULT nextval('correlativos_actas_id_seq'::regclass);


--
-- TOC entry 2472 (class 2604 OID 25364)
-- Dependencies: 197 196
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara_viejo ALTER COLUMN id SET DEFAULT nextval('"Declara_IDDeclara_seq"'::regclass);


--
-- TOC entry 2473 (class 2604 OID 25365)
-- Dependencies: 199 198
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY departam ALTER COLUMN id SET DEFAULT nextval('"Departam_IDDepartam_seq"'::regclass);


--
-- TOC entry 2536 (class 2604 OID 25366)
-- Dependencies: 251 250
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY detalle_interes ALTER COLUMN id SET DEFAULT nextval('detalle_interes_id_seq'::regclass);


--
-- TOC entry 2537 (class 2604 OID 25367)
-- Dependencies: 253 252
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY detalle_interes_viejo ALTER COLUMN id SET DEFAULT nextval('detalle_interes_id_seq1'::regclass);


--
-- TOC entry 2538 (class 2604 OID 25368)
-- Dependencies: 255 254
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY detalles_contrib_calc ALTER COLUMN id SET DEFAULT nextval('detalles_contrib_calc_id_seq'::regclass);


--
-- TOC entry 2542 (class 2604 OID 25369)
-- Dependencies: 257 256
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY dettalles_fizcalizacion ALTER COLUMN id SET DEFAULT nextval('dettalles_fizcalizacion_id_seq'::regclass);


--
-- TOC entry 2544 (class 2604 OID 25370)
-- Dependencies: 259 258
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY document ALTER COLUMN id SET DEFAULT nextval('document_id_seq'::regclass);


--
-- TOC entry 2477 (class 2604 OID 25371)
-- Dependencies: 203 202
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY entidad ALTER COLUMN id SET DEFAULT nextval('"Entidad_IDEntidad_seq"'::regclass);


--
-- TOC entry 2475 (class 2604 OID 25372)
-- Dependencies: 201 200
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY entidadd ALTER COLUMN id SET DEFAULT nextval('"EntidadD_IDEntidadD_seq"'::regclass);


--
-- TOC entry 2478 (class 2604 OID 25373)
-- Dependencies: 205 204
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY estados ALTER COLUMN id SET DEFAULT nextval('"Estados_IDEstado_seq"'::regclass);


--
-- TOC entry 2545 (class 2604 OID 25374)
-- Dependencies: 261 260
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY interes_bcv ALTER COLUMN id SET DEFAULT nextval('interes_bcv_id_seq'::regclass);


--
-- TOC entry 2481 (class 2604 OID 25375)
-- Dependencies: 209 208
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY perusu ALTER COLUMN id SET DEFAULT nextval('"PerUsu_IDPerUsu_seq"'::regclass);


--
-- TOC entry 2479 (class 2604 OID 25376)
-- Dependencies: 207 206
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY perusud ALTER COLUMN id SET DEFAULT nextval('"PerUsuD_IDPerUsuD_seq"'::regclass);


--
-- TOC entry 2482 (class 2604 OID 25377)
-- Dependencies: 211 210
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY pregsecr ALTER COLUMN id SET DEFAULT nextval('"PregSecr_IDPregSecr_seq"'::regclass);


--
-- TOC entry 2547 (class 2604 OID 25378)
-- Dependencies: 263 262
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY presidente ALTER COLUMN id SET DEFAULT nextval('presidente_id_seq'::regclass);


--
-- TOC entry 2483 (class 2604 OID 25379)
-- Dependencies: 213 212
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY replegal ALTER COLUMN id SET DEFAULT nextval('"RepLegal_IDRepLegal_seq"'::regclass);


--
-- TOC entry 2484 (class 2604 OID 25380)
-- Dependencies: 215 214
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tdeclara ALTER COLUMN id SET DEFAULT nextval('"TDeclara_IDTDeclara_seq"'::regclass);


--
-- TOC entry 2487 (class 2604 OID 25381)
-- Dependencies: 217 216
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tipegrav ALTER COLUMN id SET DEFAULT nextval('"TiPeGrav_IDTiPeGrav_seq"'::regclass);


--
-- TOC entry 2488 (class 2604 OID 25382)
-- Dependencies: 219 218
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tipocont ALTER COLUMN id SET DEFAULT nextval('"TipoCont_IDTipoCont_seq"'::regclass);


--
-- TOC entry 2490 (class 2604 OID 25383)
-- Dependencies: 221 220
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY undtrib ALTER COLUMN id SET DEFAULT nextval('"UndTrib_IDUndTrib_seq"'::regclass);


--
-- TOC entry 2494 (class 2604 OID 25384)
-- Dependencies: 225 224
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY usfonpro ALTER COLUMN id SET DEFAULT nextval('"Usuarios_IDUsuario_seq"'::regclass);


--
-- TOC entry 2492 (class 2604 OID 25385)
-- Dependencies: 223 222
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY usfonpto ALTER COLUMN id SET DEFAULT nextval('"UsFonpTo_IDUsFonpTo_seq"'::regclass);


SET search_path = historial, pg_catalog;

--
-- TOC entry 2559 (class 2604 OID 25386)
-- Dependencies: 270 269
-- Name: id; Type: DEFAULT; Schema: historial; Owner: postgres
--

ALTER TABLE ONLY bitacora ALTER COLUMN id SET DEFAULT nextval('"Bitacora_IDBitacora_seq"'::regclass);


SET search_path = pre_aprobacion, pg_catalog;

--
-- TOC entry 2564 (class 2604 OID 25387)
-- Dependencies: 272 271
-- Name: id; Type: DEFAULT; Schema: pre_aprobacion; Owner: postgres
--

ALTER TABLE ONLY datos_cnac ALTER COLUMN id SET DEFAULT nextval('datos_cnac_id_seq'::regclass);


--
-- TOC entry 2566 (class 2604 OID 25388)
-- Dependencies: 274 273
-- Name: id; Type: DEFAULT; Schema: pre_aprobacion; Owner: postgres
--

ALTER TABLE ONLY intereses ALTER COLUMN id SET DEFAULT nextval('intereses_id_seq'::regclass);


--
-- TOC entry 2567 (class 2604 OID 25389)
-- Dependencies: 276 275
-- Name: id; Type: DEFAULT; Schema: pre_aprobacion; Owner: postgres
--

ALTER TABLE ONLY multas ALTER COLUMN id SET DEFAULT nextval('multas_id_seq'::regclass);


SET search_path = seg, pg_catalog;

--
-- TOC entry 2569 (class 2604 OID 25390)
-- Dependencies: 279 278
-- Name: id; Type: DEFAULT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_cargos ALTER COLUMN id SET DEFAULT nextval('tbl_cargos_id_seq'::regclass);


--
-- TOC entry 2575 (class 2604 OID 25391)
-- Dependencies: 282 281
-- Name: id_modulo; Type: DEFAULT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_modulo ALTER COLUMN id_modulo SET DEFAULT nextval('tbl_modulo_id_modulo_seq'::regclass);


--
-- TOC entry 2578 (class 2604 OID 25392)
-- Dependencies: 284 283
-- Name: id; Type: DEFAULT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_oficinas ALTER COLUMN id SET DEFAULT nextval('tbl_oficinas_id_seq'::regclass);


--
-- TOC entry 2580 (class 2604 OID 25393)
-- Dependencies: 286 285
-- Name: id_permiso; Type: DEFAULT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_permiso ALTER COLUMN id_permiso SET DEFAULT nextval('tbl_permiso_id_permiso_seq'::regclass);


--
-- TOC entry 2582 (class 2604 OID 25394)
-- Dependencies: 288 287
-- Name: id_permiso; Type: DEFAULT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_permiso_trampa ALTER COLUMN id_permiso SET DEFAULT nextval('tbl_permiso_trampa_id_permiso_seq'::regclass);


--
-- TOC entry 2584 (class 2604 OID 25395)
-- Dependencies: 290 289
-- Name: id_rol; Type: DEFAULT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_rol ALTER COLUMN id_rol SET DEFAULT nextval('tbl_rol_id_rol_seq'::regclass);


--
-- TOC entry 2586 (class 2604 OID 25396)
-- Dependencies: 292 291
-- Name: id_rol_usuario; Type: DEFAULT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_rol_usuario ALTER COLUMN id_rol_usuario SET DEFAULT nextval('tbl_rol_usuario_id_rol_usuario_seq'::regclass);


--
-- TOC entry 2592 (class 2604 OID 25397)
-- Dependencies: 295 294
-- Name: id_usuario_rol; Type: DEFAULT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_usuario_rol ALTER COLUMN id_usuario_rol SET DEFAULT nextval('tbl_usuario_rol_id_usuario_rol_seq'::regclass);


SET search_path = "segContribu", pg_catalog;

--
-- TOC entry 2594 (class 2604 OID 25398)
-- Dependencies: 298 297
-- Name: id_modulo; Type: DEFAULT; Schema: segContribu; Owner: postgres
--

ALTER TABLE ONLY tbl_modulo_contribu ALTER COLUMN id_modulo SET DEFAULT nextval('tbl_modulo_id_modulo_seq'::regclass);


--
-- TOC entry 2596 (class 2604 OID 25399)
-- Dependencies: 300 299
-- Name: id_permiso; Type: DEFAULT; Schema: segContribu; Owner: postgres
--

ALTER TABLE ONLY tbl_permiso_contribu ALTER COLUMN id_permiso SET DEFAULT nextval('tbl_permiso_id_permiso_seq'::regclass);


--
-- TOC entry 2598 (class 2604 OID 25400)
-- Dependencies: 302 301
-- Name: id_rol; Type: DEFAULT; Schema: segContribu; Owner: postgres
--

ALTER TABLE ONLY tbl_rol_contribu ALTER COLUMN id_rol SET DEFAULT nextval('tbl_rol_id_rol_seq'::regclass);


--
-- TOC entry 2600 (class 2604 OID 25401)
-- Dependencies: 304 303
-- Name: id_rol_usuario; Type: DEFAULT; Schema: segContribu; Owner: postgres
--

ALTER TABLE ONLY tbl_rol_usuario_contribu ALTER COLUMN id_rol_usuario SET DEFAULT nextval('tbl_rol_usuario_id_rol_usuario_seq'::regclass);


--
-- TOC entry 2602 (class 2604 OID 25402)
-- Dependencies: 306 305
-- Name: id_usuario_rol; Type: DEFAULT; Schema: segContribu; Owner: postgres
--

ALTER TABLE ONLY tbl_usuario_rol_contribu ALTER COLUMN id_usuario_rol SET DEFAULT nextval('tbl_usuario_rol_id_usuario_rol_seq'::regclass);


SET search_path = datos, pg_catalog;

--
-- TOC entry 3865 (class 0 OID 0)
-- Dependencies: 166
-- Name: Accionis_ID_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Accionis_ID_seq"', 74, true);


--
-- TOC entry 3866 (class 0 OID 0)
-- Dependencies: 168
-- Name: ActiEcon_IDActiEcon_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"ActiEcon_IDActiEcon_seq"', 9, true);


--
-- TOC entry 3867 (class 0 OID 0)
-- Dependencies: 170
-- Name: AlicImp_IDAlicImp_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"AlicImp_IDAlicImp_seq"', 11, true);


--
-- TOC entry 3868 (class 0 OID 0)
-- Dependencies: 172
-- Name: AsientoD_IDAsientoD_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"AsientoD_IDAsientoD_seq"', 6, true);


--
-- TOC entry 3869 (class 0 OID 0)
-- Dependencies: 173
-- Name: Asiento_IDAsiento_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Asiento_IDAsiento_seq"', 2, true);


--
-- TOC entry 3870 (class 0 OID 0)
-- Dependencies: 175
-- Name: BaCuenta_IDBaCuenta_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"BaCuenta_IDBaCuenta_seq"', 1, false);


--
-- TOC entry 3871 (class 0 OID 0)
-- Dependencies: 177
-- Name: Bancos_IDBanco_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Bancos_IDBanco_seq"', 1, false);


--
-- TOC entry 3872 (class 0 OID 0)
-- Dependencies: 179
-- Name: CalPagoD_IDCalPagoD_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"CalPagoD_IDCalPagoD_seq"', 365, true);


--
-- TOC entry 3873 (class 0 OID 0)
-- Dependencies: 181
-- Name: CalPagos_IDCalPago_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"CalPagos_IDCalPago_seq"', 51, true);


--
-- TOC entry 3874 (class 0 OID 0)
-- Dependencies: 183
-- Name: Cargos_IDCargo_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Cargos_IDCargo_seq"', 16, true);


--
-- TOC entry 3875 (class 0 OID 0)
-- Dependencies: 185
-- Name: Ciudades_IDCiudad_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Ciudades_IDCiudad_seq"', 360, true);


--
-- TOC entry 3876 (class 0 OID 0)
-- Dependencies: 187
-- Name: ConUsuCo_IDConUsuCo_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"ConUsuCo_IDConUsuCo_seq"', 1, false);


--
-- TOC entry 3877 (class 0 OID 0)
-- Dependencies: 189
-- Name: ConUsuTi_IDConUsuTi_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"ConUsuTi_IDConUsuTi_seq"', 1, true);


--
-- TOC entry 3878 (class 0 OID 0)
-- Dependencies: 191
-- Name: ConUsuTo_IDConUsuTo_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"ConUsuTo_IDConUsuTo_seq"', 131, true);


--
-- TOC entry 3879 (class 0 OID 0)
-- Dependencies: 193
-- Name: ConUsu_IDConUsu_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"ConUsu_IDConUsu_seq"', 145, true);


--
-- TOC entry 3880 (class 0 OID 0)
-- Dependencies: 195
-- Name: Contribu_IDContribu_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Contribu_IDContribu_seq"', 24, true);


--
-- TOC entry 3881 (class 0 OID 0)
-- Dependencies: 197
-- Name: Declara_IDDeclara_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Declara_IDDeclara_seq"', 465, true);


--
-- TOC entry 3882 (class 0 OID 0)
-- Dependencies: 199
-- Name: Departam_IDDepartam_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Departam_IDDepartam_seq"', 10, true);


--
-- TOC entry 3883 (class 0 OID 0)
-- Dependencies: 201
-- Name: EntidadD_IDEntidadD_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"EntidadD_IDEntidadD_seq"', 1, false);


--
-- TOC entry 3884 (class 0 OID 0)
-- Dependencies: 203
-- Name: Entidad_IDEntidad_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Entidad_IDEntidad_seq"', 1, false);


--
-- TOC entry 3885 (class 0 OID 0)
-- Dependencies: 205
-- Name: Estados_IDEstado_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Estados_IDEstado_seq"', 27, true);


--
-- TOC entry 3886 (class 0 OID 0)
-- Dependencies: 207
-- Name: PerUsuD_IDPerUsuD_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"PerUsuD_IDPerUsuD_seq"', 1, false);


--
-- TOC entry 3887 (class 0 OID 0)
-- Dependencies: 209
-- Name: PerUsu_IDPerUsu_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"PerUsu_IDPerUsu_seq"', 1, false);


--
-- TOC entry 3888 (class 0 OID 0)
-- Dependencies: 211
-- Name: PregSecr_IDPregSecr_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"PregSecr_IDPregSecr_seq"', 7, true);


--
-- TOC entry 3889 (class 0 OID 0)
-- Dependencies: 213
-- Name: RepLegal_IDRepLegal_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"RepLegal_IDRepLegal_seq"', 4, true);


--
-- TOC entry 3890 (class 0 OID 0)
-- Dependencies: 215
-- Name: TDeclara_IDTDeclara_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"TDeclara_IDTDeclara_seq"', 7, true);


--
-- TOC entry 3891 (class 0 OID 0)
-- Dependencies: 217
-- Name: TiPeGrav_IDTiPeGrav_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"TiPeGrav_IDTiPeGrav_seq"', 6, true);


--
-- TOC entry 3892 (class 0 OID 0)
-- Dependencies: 219
-- Name: TipoCont_IDTipoCont_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"TipoCont_IDTipoCont_seq"', 6, true);


--
-- TOC entry 3893 (class 0 OID 0)
-- Dependencies: 221
-- Name: UndTrib_IDUndTrib_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"UndTrib_IDUndTrib_seq"', 24, true);


--
-- TOC entry 3894 (class 0 OID 0)
-- Dependencies: 223
-- Name: UsFonpTo_IDUsFonpTo_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"UsFonpTo_IDUsFonpTo_seq"', 1, false);


--
-- TOC entry 3895 (class 0 OID 0)
-- Dependencies: 225
-- Name: Usuarios_IDUsuario_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Usuarios_IDUsuario_seq"', 50, true);


--
-- TOC entry 3183 (class 0 OID 24946)
-- Dependencies: 226 3262
-- Data for Name: accionis; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY accionis (id, contribuid, nombre, apellido, ci, domfiscal, nuacciones, valaccion, cextra1, cextra2, cextra3, cextra4, cextra5, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 3184 (class 0 OID 24955)
-- Dependencies: 227 3262
-- Data for Name: actas_reparo; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY actas_reparo (id, numero, ruta_servidor, fecha_adjunto, usuarioid, ip) FROM stdin;
98	1-2013	./archivos/fiscalizacion/2013/558ba84544677dfe3bc4a8b5dffed2f1.doc	2013-07-24 17:20:29.883177	48	127.0.0.1
99	2-2013	./archivos/fiscalizacion/2013/7aaac764da206077b7150e63b8f2f3b2.doc	2013-07-24 17:55:49.255666	48	127.0.0.1
\.


--
-- TOC entry 3896 (class 0 OID 0)
-- Dependencies: 228
-- Name: actas_reparo_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('actas_reparo_id_seq', 99, true);


--
-- TOC entry 3124 (class 0 OID 24730)
-- Dependencies: 167 3262
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
-- TOC entry 3126 (class 0 OID 24735)
-- Dependencies: 169 3262
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
-- TOC entry 3186 (class 0 OID 24964)
-- Dependencies: 229 3262
-- Data for Name: asiento; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY asiento (id, nuasiento, fecha, mes, ano, debe, haber, saldo, comentar, cerrado, uscierreid, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 3128 (class 0 OID 24751)
-- Dependencies: 171 3262
-- Data for Name: asientod; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY asientod (id, asientoid, fecha, cuenta, monto, sentido, referencia, comentar, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 3187 (class 0 OID 24978)
-- Dependencies: 230 3262
-- Data for Name: asientom; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY asientom (id, nombre, comentar, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 3897 (class 0 OID 0)
-- Dependencies: 231
-- Name: asientom_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('asientom_id_seq', 1, false);


--
-- TOC entry 3189 (class 0 OID 24986)
-- Dependencies: 232 3262
-- Data for Name: asientomd; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY asientomd (id, asientomid, cuenta, sentido, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 3898 (class 0 OID 0)
-- Dependencies: 233
-- Name: asientomd_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('asientomd_id_seq', 1, false);


--
-- TOC entry 3191 (class 0 OID 24992)
-- Dependencies: 234 3262
-- Data for Name: asignacion_fiscales; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY asignacion_fiscales (id, fecha_asignacion, usfonproid, conusuid, prioridad, estatus, fecha_fiscalizacion, usuarioid, ip, tipocontid, nro_autorizacion, periodo_afiscalizar) FROM stdin;
944	2013-07-12	48	11	t	1	2013-07-18	48	192.168.1.101	1	25-2013	2013
943	2013-07-10	48	4	f	1	2013-07-10	48	192.168.1.101	1	24-2013	2013
945	2013-07-12	48	6	t	1	2013-07-25	48	192.168.1.101	1	26-2013	2013
946	2013-07-13	48	3	t	1	2013-07-18	48	127.0.0.1	1	27-2013	2013
940	2013-07-10	48	1	t	1	2013-07-24	48	192.168.1.101	1	21-2013	2013
941	2013-07-10	48	2	t	2	2013-07-16	48	192.168.1.101	1	22-2013	2013
942	2013-07-10	48	3	f	2	2013-07-10	48	192.168.1.101	1	23-2013	2013
\.


--
-- TOC entry 3899 (class 0 OID 0)
-- Dependencies: 235
-- Name: asignacion_fiscales_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('asignacion_fiscales_id_seq', 946, true);


--
-- TOC entry 3131 (class 0 OID 24763)
-- Dependencies: 174 3262
-- Data for Name: bacuenta; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY bacuenta (id, bancoid, cuenta, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 3133 (class 0 OID 24768)
-- Dependencies: 176 3262
-- Data for Name: bancos; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY bancos (id, nombre, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 3137 (class 0 OID 24778)
-- Dependencies: 180 3262
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
-- TOC entry 3135 (class 0 OID 24773)
-- Dependencies: 178 3262
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
-- TOC entry 3139 (class 0 OID 24784)
-- Dependencies: 182 3262
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
-- TOC entry 3141 (class 0 OID 24792)
-- Dependencies: 184 3262
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
-- TOC entry 3193 (class 0 OID 25002)
-- Dependencies: 236 3262
-- Data for Name: con_img_doc; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY con_img_doc (id, conusuid, descripcion, usuarioid, ip, ruta_imagen, fecha) FROM stdin;
107	1	hkhlkh	1	127.0.0.1	b1f3860cd72063510459a24447ca14be.png	2013-07-13
108	145	jhghjhghg	145	127.0.0.1	53d04fb0245334933b9dcc110a2bdd20.jpg	2013-07-24
\.


--
-- TOC entry 3900 (class 0 OID 0)
-- Dependencies: 237
-- Name: con_img_doc_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('con_img_doc_id_seq', 108, true);


--
-- TOC entry 3195 (class 0 OID 25011)
-- Dependencies: 238 3262
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
149	2	48	192.168.1.101	1	2013-07-10 11:54:39.194584	\N	calculado
\.


--
-- TOC entry 3901 (class 0 OID 0)
-- Dependencies: 239
-- Name: contrib_calc_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('contrib_calc_id_seq', 149, true);


--
-- TOC entry 3151 (class 0 OID 24831)
-- Dependencies: 194 3262
-- Data for Name: contribu; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY contribu (id, razonsocia, dencomerci, actieconid, rif, numregcine, domfiscal, estadoid, ciudadid, zonapostal, telef1, telef2, telef3, fax1, fax2, email, pinbb, skype, twitter, facebook, nuacciones, valaccion, capitalsus, capitalpag, regmerofc, rmnumero, rmfolio, rmtomo, rmfechapro, rmncontrol, rmobjeto, domcomer, cextra1, cextra2, cextra3, cextra4, cextra5, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 3197 (class 0 OID 25020)
-- Dependencies: 240 3262
-- Data for Name: contributi; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY contributi (id, contribuid, tipocontid, ip) FROM stdin;
\.


--
-- TOC entry 3902 (class 0 OID 0)
-- Dependencies: 241
-- Name: contributi_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('contributi_id_seq', 1, false);


--
-- TOC entry 3149 (class 0 OID 24820)
-- Dependencies: 192 3262
-- Data for Name: conusu; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY conusu (id, login, password, nombre, inactivo, conusutiid, email, pregsecrid, respuesta, ultlogin, usuarioid, ip, rif, validado, fecha_registro) FROM stdin;
145	V170429792	7c4a8d09ca3762af61e59520943dc26494f8941b	JEFFERSON ARTURO LARA MOLINA	t	1	jetox21@gmail.com	2	soy yo	2013-07-09 16:33:57.785188	\N	192.168.1.101	V170429792	t	2013-03-14
2	J085096477	7c4a8d09ca3762af61e59520943dc26494f8941b	Administradora de Cines Barquisimeto C.A.	f	1	mafercine@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J085096477	t	2013-03-14
3	J085059920	7c4a8d09ca3762af61e59520943dc26494f8941b	Administradora de Cines Acarigua, C.A.	f	1	cines@cinesacarigua.com	2	MI MAMA	\N	\N	192,168,1,101	J085059920	t	2013-03-14
4	J308336980	7c4a8d09ca3762af61e59520943dc26494f8941b	Agropecuaria J.R.L. Cine Carvajal	f	1	juanleal70@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J308336980	t	2013-03-14
5	J001450181	7c4a8d09ca3762af61e59520943dc26494f8941b	A.C. Ateneo de Caracas	f	1	diradmon@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J001450181	t	2013-03-14
6	V053442486	7c4a8d09ca3762af61e59520943dc26494f8941b	Cine Center La Grita	f	1	oscarlubo@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	V053442486	t	2013-03-14
7	V118783634	7c4a8d09ca3762af61e59520943dc26494f8941b	Sala de Cine Charles Chaplin Oropeza	f	1	yv3-fdr@latinmail.com	2	MI MAMA	\N	\N	192,168,1,101	V118783634	t	2013-03-14
8	J301447018	7c4a8d09ca3762af61e59520943dc26494f8941b	A.C. Cine Club Zona Colonial de Petare	f	1	cineclub@hotmail.com virginia_rojas@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J301447018	t	2013-03-14
9	J311140492	7c4a8d09ca3762af61e59520943dc26494f8941b	Cines Magia C.A.	f	1	cinesmagia6@latinmail.com	2	MI MAMA	\N	\N	192,168,1,101	J311140492	t	2013-03-14
10	J311591478	7c4a8d09ca3762af61e59520943dc26494f8941b	Cine Oasis, C.A.	f	1	grupo2810@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J311591478	t	2013-03-14
11	J000915644	7c4a8d09ca3762af61e59520943dc26494f8941b	Cine Plaza Las Américas, C.A.	f	1	msaleta@blancica.com.ve	2	MI MAMA	\N	\N	192,168,1,101	J000915644	t	2013-03-14
12	J310160376	7c4a8d09ca3762af61e59520943dc26494f8941b	Cinematográfica Las Terrazas, C.A. (antiguamente Roraimex)	f	1	cinescca@gmail.com	2	MI MAMA	\N	\N	192,168,1,101	J310160376	t	2013-03-14
13	J308702528	7c4a8d09ca3762af61e59520943dc26494f8941b	Cumboto Cinema 3, S.R.L.	f	1	juancarloa@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J308702528	t	2013-03-14
14	J307124695	7c4a8d09ca3762af61e59520943dc26494f8941b	Exhibidor de Películas La Cascada C.A.	f	1	pablov@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J307124695	t	2013-03-14
15	J304483198	7c4a8d09ca3762af61e59520943dc26494f8941b	Exhibidor de Películas La Casona C.A.	f	1	moviecascada@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J304483198	t	2013-03-14
16	J300846199	7c4a8d09ca3762af61e59520943dc26494f8941b	Fremel Cine Los Salias, C.A.	f	1	defreitascj@gmail.com	2	MI MAMA	\N	\N	192,168,1,101	J300846199	t	2013-03-14
17	J075877608	7c4a8d09ca3762af61e59520943dc26494f8941b	Fundacine Universidad de Carabobo	f	1	www.fundacine@uc.edu.ve	2	MI MAMA	\N	\N	192,168,1,101	J075877608	t	2013-03-14
18	J304603665	7c4a8d09ca3762af61e59520943dc26494f8941b	Fundación Teatro Baralt (FUNDABARALT)	f	1	teatrobaralt@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J304603665	t	2013-03-14
19	J003615935	7c4a8d09ca3762af61e59520943dc26494f8941b	Fundación La Previsora	f	1	fundaciónprevisora@gmail.com	2	MI MAMA	\N	\N	192,168,1,101	J003615935	t	2013-03-14
20	J303881130	7c4a8d09ca3762af61e59520943dc26494f8941b	Asociación Nacional de Salas de Arte Cinematográfica Circuito Gran Cine	f	1	circuitograncine@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J303881130	t	2013-03-14
21	J300443230	7c4a8d09ca3762af61e59520943dc26494f8941b	Inversiones Cines Principal, C.A.	f	1	mafercine@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J300443230	t	2013-03-14
22	J302174210	7c4a8d09ca3762af61e59520943dc26494f8941b	Inversiones Diversas Nº 37 C.A.                 (Cine Continental)	f	1	venefilm@telcel.net.ve	2	MI MAMA	\N	\N	192,168,1,101	J302174210	t	2013-03-14
23	J305874964	7c4a8d09ca3762af61e59520943dc26494f8941b	Inversiones Jumbo Plex C.A.	f	1	msaleta@blancica.com.ve	2	MI MAMA	\N	\N	192,168,1,101	J305874964	t	2013-03-14
24	J308926434	7c4a8d09ca3762af61e59520943dc26494f8941b	Inversiones Maydard, C.A.	f	1	ltorres@cinex.com.ve	2	MI MAMA	\N	\N	192,168,1,101	J308926434	t	2013-03-14
25	J303031526	7c4a8d09ca3762af61e59520943dc26494f8941b	Inversiones Plaza Mayor 2019, C.A.	f	1	venefilm@telcel.net.ve	2	MI MAMA	\N	\N	192,168,1,101	J303031526	t	2013-03-14
26	J302626471	7c4a8d09ca3762af61e59520943dc26494f8941b	Multicine Las Trinitarias C.A.	f	1	ttoth@cinesunidos.com	2	MI MAMA	\N	\N	192,168,1,101	J302626471	t	2013-03-14
27	J304066120	7c4a8d09ca3762af61e59520943dc26494f8941b	Multicine Las Virtudes, C.A.	f	1	venefilm@telcel.net.ve	2	MI MAMA	\N	\N	192,168,1,101	J304066120	t	2013-03-14
28	J3057185279	7c4a8d09ca3762af61e59520943dc26494f8941b	Multicine Plaza Alto Prado, C.A.	f	1	venefilm@telcel.net.ve	2	MI MAMA	\N	\N	192,168,1,101	J3057185279	t	2013-03-14
29	J308213373	7c4a8d09ca3762af61e59520943dc26494f8941b	Multicine Valera Plaza, C.A.	f	1	venefilm@telcel.net.ve	2	MI MAMA	\N	\N	192,168,1,101	J308213373	t	2013-03-14
30	J001324178	7c4a8d09ca3762af61e59520943dc26494f8941b	Multicinema El Viaducto	f	1	venefilm@telcel.net.ve	2	MI MAMA	\N	\N	192,168,1,101	J001324178	t	2013-03-14
31	J001054243	7c4a8d09ca3762af61e59520943dc26494f8941b	Multicinema Tamanaco, C.A.	f	1	msaleta@blancica.com.ve	2	MI MAMA	\N	\N	192,168,1,101	J001054243	t	2013-03-14
32	J304741510	7c4a8d09ca3762af61e59520943dc26494f8941b	Multicines El Valle	f	1	ssharam@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J304741510	t	2013-03-14
33	J308213411	7c4a8d09ca3762af61e59520943dc26494f8941b	Multicines Marina Plaza, C.A.	f	1	venefilm@telcel.net.ve	2	MI MAMA	\N	\N	192,168,1,101	J308213411	t	2013-03-14
34	J305308551	7c4a8d09ca3762af61e59520943dc26494f8941b	Multicines Monagas Plaza, C.A.	f	1	Miranda	2	MI MAMA	\N	\N	192,168,1,101	J305308551	t	2013-03-14
35	J304857527	7c4a8d09ca3762af61e59520943dc26494f8941b	Multicine Doral Plaza Center, C.A.	f	1	venefilm@telcel.net.ve	2	MI MAMA	\N	\N	192,168,1,101	J304857527	t	2013-03-14
36	J312496126	7c4a8d09ca3762af61e59520943dc26494f8941b	A.C. Cine Club Charles Chaplin	f	1	juanl3@hotmail.com / cinechaplin@gmail.com	2	MI MAMA	\N	\N	192,168,1,101	J312496126	t	2013-03-14
37	J000458324	7c4a8d09ca3762af61e59520943dc26494f8941b	Sur Americana de Espectáculos	f	1	cinex@com.ve	2	MI MAMA	\N	\N	192,168,1,101	J000458324	t	2013-03-14
38	J300492621	7c4a8d09ca3762af61e59520943dc26494f8941b	Teatro Olímpico	f	1	teatro-olimpico@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J300492621	t	2013-03-14
39	J001011579	7c4a8d09ca3762af61e59520943dc26494f8941b	Teatro Rossini, S.R.L.	f	1	venefilm@telcel.net.ve	2	MI MAMA	\N	\N	192,168,1,101	J001011579	t	2013-03-14
40	J001035508	7c4a8d09ca3762af61e59520943dc26494f8941b	Teatros de Portuguesa, S.R.L.    (Multicines Pirineos)	f	1	venefilm@telcel.net.ve	2	MI MAMA	\N	\N	192,168,1,101	J001035508	t	2013-03-14
42	J310483990	7c4a8d09ca3762af61e59520943dc26494f8941b	Cinex Tolón C.A.	f	1	msaleta@blancica.com.ve	2	MI MAMA	\N	\N	192,168,1,101	J310483990	t	2013-03-14
43	J313701394	7c4a8d09ca3762af61e59520943dc26494f8941b	Administradora Darmay	f	1	ltorres@cinex.com.ve	2	MI MAMA	\N	\N	192,168,1,101	J313701394	t	2013-03-14
44	G200054620	7c4a8d09ca3762af61e59520943dc26494f8941b	Fundación Cinemateca Nacional	f	1	programacion@cinemateca.gob.ve	2	MI MAMA	\N	\N	192,168,1,101	G200054620	t	2013-03-14
45	J310535590	7c4a8d09ca3762af61e59520943dc26494f8941b	A.C. Cinedigital	f	1	cinedigital2000@yahoo.es	2	MI MAMA	\N	\N	192,168,1,101	J310535590	t	2013-03-14
46	J305634947	7c4a8d09ca3762af61e59520943dc26494f8941b	Inversora 12230, C.A.	f	1	msaleta@blancica.com.ve	2	MI MAMA	\N	\N	192,168,1,101	J305634947	t	2013-03-14
47	J308926035	7c4a8d09ca3762af61e59520943dc26494f8941b	Cine La Cascada C.A.	f	1	moviecascada@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J308926035	t	2013-03-14
48	J308490865	7c4a8d09ca3762af61e59520943dc26494f8941b	Fundación Trasnocho Cultural - Cines Paseo 1, 2 y Plus	f	1	coordinación@trasnochocultural.com	2	MI MAMA	\N	\N	192,168,1,101	J308490865	t	2013-03-14
49	J314807722	7c4a8d09ca3762af61e59520943dc26494f8941b	Multicine Galerías 2020, C.A.	f	1	jparra@cinex2.com.ve	2	MI MAMA	\N	\N	192,168,1,101	J314807722	t	2013-03-14
50	J314177869	7c4a8d09ca3762af61e59520943dc26494f8941b	Exhibiciones Fílmicas, C.A.	f	1	maruciaca@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J314177869	t	2013-03-14
51	J294049206	7c4a8d09ca3762af61e59520943dc26494f8941b	Multicine Santa Barbara	f	1	argenisulbaran520@hotail.com	2	MI MAMA	\N	\N	192,168,1,101	J294049206	t	2013-03-14
52	J316200035	7c4a8d09ca3762af61e59520943dc26494f8941b	Cines Atlántico R.P., C.A.	f	1	pablov@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J316200035	t	2013-03-14
53	J294736343	7c4a8d09ca3762af61e59520943dc26494f8941b	Cines Center, C.A.	f	1	cinescenter@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J294736343	t	2013-03-14
54	J000126518	7c4a8d09ca3762af61e59520943dc26494f8941b	C.A. Empresas Cines Unidos	f	1	 sullivi@cinesunidos.com	2	MI MAMA	\N	\N	192,168,1,101	J000126518	t	2013-03-14
55	J294910661	7c4a8d09ca3762af61e59520943dc26494f8941b	Operadora Cinecity la Victoria, C.A.	f	1	cinecitylavictoria@gmail.com	2	MI MAMA	\N	\N	192,168,1,101	J294910661	t	2013-03-14
56	J295750790	7c4a8d09ca3762af61e59520943dc26494f8941b	Multicines San Remo, C.A.	f	1	rennyvieira@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J295750790	t	2013-03-14
57	J314807803	7c4a8d09ca3762af61e59520943dc26494f8941b	Multicines Cimaplaza, C.A.	f	1	jparra@cinex.com.ve	2	MI MAMA	\N	\N	192,168,1,101	J314807803	t	2013-03-14
58	J297680306	7c4a8d09ca3762af61e59520943dc26494f8941b	Cinemall, C.A.	f	1	anamfernandez3@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J297680306	t	2013-03-14
59	J298525070	7c4a8d09ca3762af61e59520943dc26494f8941b	Casona Multiplex, C.A.	f	1	cinemovieplanet@gmail.com	2	MI MAMA	\N	\N	192,168,1,101	J298525070	t	2013-03-14
60	J307894466	7c4a8d09ca3762af61e59520943dc26494f8941b	Supercine Puente Real, C.A.	f	1	rennyvieira@gmail.com	2	MI MAMA	\N	\N	192,168,1,101	J307894466	t	2013-03-14
61	J293588618	7c4a8d09ca3762af61e59520943dc26494f8941b	Cines Anaco Center, C.A.	f	1	minigonzalez@msn.com	2	MI MAMA	\N	\N	192,168,1,101	J293588618	t	2013-03-14
62	J003697362	7c4a8d09ca3762af61e59520943dc26494f8941b	Continental TV, C.A.   (MERIDIANO TV)	f	1	meridianotv@dearmas.com	2	MI MAMA	\N	\N	192,168,1,101	J003697362	t	2013-03-14
63	J301743024	7c4a8d09ca3762af61e59520943dc26494f8941b	GLOBOVISIÓN TELE C.A.	f	1	info@globovision.com	2	MI MAMA	\N	\N	192,168,1,101	J301743024	t	2013-03-14
64	J000305617	7c4a8d09ca3762af61e59520943dc26494f8941b	RCTV C.A.	f	1	IMORILLO@ RCTV.NET	2	MI MAMA	\N	\N	192,168,1,101	J000305617	t	2013-03-14
65	J000089337	7c4a8d09ca3762af61e59520943dc26494f8941b	CORPORACIÓN VENEZOLANA DE TELEVISIÓN, C.A. (VENEVISIÓN)	f	1	clinares@venevision.com.ve	2	MI MAMA	\N	\N	192,168,1,101	J000089337	t	2013-03-14
66	J002376163	7c4a8d09ca3762af61e59520943dc26494f8941b	Corporación Televen	f	1	msarria@televentv.com.ve	2	MI MAMA	\N	\N	192,168,1,101	J002376163	t	2013-03-14
67	J002987235	7c4a8d09ca3762af61e59520943dc26494f8941b	La Tele Televisión, C.A.	f	1	mgranados@latele.com.ve	2	MI MAMA	\N	\N	192,168,1,101	J002987235	t	2013-03-14
68	J305630577	7c4a8d09ca3762af61e59520943dc26494f8941b	Barlovento TV, C.A.	f	1	soltelevision@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J305630577	t	2013-03-14
69	J300975339	7c4a8d09ca3762af61e59520943dc26494f8941b	Promociones Telemaracay, C.A. (TVS)	f	1	asindoni@elaragueno.com.ve	2	MI MAMA	\N	\N	192,168,1,101	J300975339	t	2013-03-14
70	J300020380	7c4a8d09ca3762af61e59520943dc26494f8941b	Televisión de Guayana, C.A.      (TV Guayana)	f	1	admincorreo@telcel.net.vel	2	MI MAMA	\N	\N	192,168,1,101	J300020380	t	2013-03-14
71	J304756771	7c4a8d09ca3762af61e59520943dc26494f8941b	Televisión de Margarita, C.A. (TELECARIBE)	f	1	Aquiles.gatas@telecaribe.tv	2	MI MAMA	\N	\N	192,168,1,101	J304756771	t	2013-03-14
72	J307557370	7c4a8d09ca3762af61e59520943dc26494f8941b	Canal 21 TV, C.A.	f	1		2	MI MAMA	\N	\N	192,168,1,101	J307557370	t	2013-03-14
73	J070523271	7c4a8d09ca3762af61e59520943dc26494f8941b	Zuliana de Televisión, S.A.	f	1	asuarez@zulianatv.com	2	MI MAMA	\N	\N	192,168,1,101	J070523271	t	2013-03-14
74	J001279768	7c4a8d09ca3762af61e59520943dc26494f8941b	C.A. Venezolana de Televisión	f	1	www.vtv.gob.ve	2	MI MAMA	\N	\N	192,168,1,101	J001279768	t	2013-03-14
75	J305083410	7c4a8d09ca3762af61e59520943dc26494f8941b	EWTN Familia Asociación Civil (TV Familia A.C)	f	1	tvfamilia@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J305083410	t	2013-03-14
76	G200076879	7c4a8d09ca3762af61e59520943dc26494f8941b	Fundacion Televisora Venezolana Social TVES	f	1	geleric@gmail.com	2	MI MAMA	\N	\N	192,168,1,101	G200076879	t	2013-03-14
77	J308322636	7c4a8d09ca3762af61e59520943dc26494f8941b	Acom 3000, C.A.	f	1	lacomlivia@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J308322636	t	2013-03-14
78	J308288500	7c4a8d09ca3762af61e59520943dc26494f8941b	Cable Bahias, C.A	f	1	cablebahias@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J308288500	t	2013-03-14
79	J30596884	7c4a8d09ca3762af61e59520943dc26494f8941b	Cable Balcón TV, C.A.	f	1		2	MI MAMA	\N	\N	192,168,1,101	J30596884	t	2013-03-14
80	J305740321	7c4a8d09ca3762af61e59520943dc26494f8941b	Cable C.R.B. Caribe Internacional	f	1	magnamar@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J305740321	t	2013-03-14
81	J307921730	7c4a8d09ca3762af61e59520943dc26494f8941b	Cable Hogar, C.A.	f	1	marcodelgado@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J307921730	t	2013-03-14
82	J304381034	7c4a8d09ca3762af61e59520943dc26494f8941b	Cable Tuy, C.A.	f	1	cabletuyarturo@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J304381034	t	2013-03-14
83	J308765201	7c4a8d09ca3762af61e59520943dc26494f8941b	Cable Uno, C.A.	f	1	moralesmiguel1@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J308765201	t	2013-03-14
84	J304886470	7c4a8d09ca3762af61e59520943dc26494f8941b	Cable Zulia, C.A.	f	1	agustínbecerra@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J304886470	t	2013-03-14
85	J304789088	7c4a8d09ca3762af61e59520943dc26494f8941b	Cablexpress TV,  C.A.	f	1	rbracho@unitel.com.ve	2	MI MAMA	\N	\N	192,168,1,101	J304789088	t	2013-03-14
86	J301866525	7c4a8d09ca3762af61e59520943dc26494f8941b	Canal Plus, C.A.	f	1	canalplus.bejuma@gmail.com	2	MI MAMA	\N	\N	192,168,1,101	J301866525	t	2013-03-14
87	J306142649	7c4a8d09ca3762af61e59520943dc26494f8941b	Comunicaciones Milenium I, C.A.	f	1	comillenium@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J306142649	t	2013-03-14
88	J304392940	7c4a8d09ca3762af61e59520943dc26494f8941b	Corporación Multivisión, C.A.	f	1	multivica@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J304392940	t	2013-03-14
89	J302406641	7c4a8d09ca3762af61e59520943dc26494f8941b	Corporación Telemic, C.A.	f	1	mroberto@intercable.com.ve	2	MI MAMA	\N	\N	192,168,1,101	J302406641	t	2013-03-14
90	J307607513	7c4a8d09ca3762af61e59520943dc26494f8941b	Corporación Visual Nueva Esparta, C.A. UNICABLE	f	1	unicablela@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J307607513	t	2013-03-14
91	J302565510	7c4a8d09ca3762af61e59520943dc26494f8941b	Cosmovisión, C.A.	f	1	cosmovision@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J302565510	t	2013-03-14
92	J003438286	7c4a8d09ca3762af61e59520943dc26494f8941b	Editorial Imagen, C.A.	f	1	hoker96@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J003438286	t	2013-03-14
93	J305709386	7c4a8d09ca3762af61e59520943dc26494f8941b	Enlace TV, C.A.	f	1	ENLACETVCA@CANTV.NET	2	MI MAMA	\N	\N	192,168,1,101	J305709386	t	2013-03-14
94	J302597005	7c4a8d09ca3762af61e59520943dc26494f8941b	Galaxy Entertaiment de Vzla, C.A.	f	1	dpto_impuestos@directvla.com.ve	2	MI MAMA	\N	\N	192,168,1,101	J302597005	t	2013-03-14
95	J312738545	7c4a8d09ca3762af61e59520943dc26494f8941b	Imagen Televisión, S.A.	f	1	multivica@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J312738545	t	2013-03-14
96	J308834874	7c4a8d09ca3762af61e59520943dc26494f8941b	Inversiones Cable Centro, C.A.	f	1	gerenciacablecentro@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J308834874	t	2013-03-14
97	J308224685	7c4a8d09ca3762af61e59520943dc26494f8941b	Medium Televisión por Cable, C.A.	f	1	medium_ve@yahoo.com	2	MI MAMA	\N	\N	192,168,1,101	J308224685	t	2013-03-14
98	J308804746	7c4a8d09ca3762af61e59520943dc26494f8941b	Mega Cable, C.A. (Tachira)	f	1	megacable@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J308804746	t	2013-03-14
99	J304633173	7c4a8d09ca3762af61e59520943dc26494f8941b	R.G.O. Somos Cable, C.A.	f	1	info@rgosomocable.com	2	MI MAMA	\N	\N	192,168,1,101	J304633173	t	2013-03-14
100	J308728217	7c4a8d09ca3762af61e59520943dc26494f8941b	San Casimiro TV, C.A.	f	1	juanmontoya2@msn.com	2	MI MAMA	\N	\N	192,168,1,101	J308728217	t	2013-03-14
101	J301687809	7c4a8d09ca3762af61e59520943dc26494f8941b	Sat- Páez, S.A. Televisión Por Cable	f	1	satpaez@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J301687809	t	2013-03-14
102	J306117270	7c4a8d09ca3762af61e59520943dc26494f8941b	Sistem Cable, C.A.	f	1	sistemcable@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J306117270	t	2013-03-14
103	J305119660	7c4a8d09ca3762af61e59520943dc26494f8941b	Skay In TV Internacional, C.A.	f	1	skay_in_tv_i@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J305119660	t	2013-03-14
104	J303087671	7c4a8d09ca3762af61e59520943dc26494f8941b	TV Cable, C.A.	f	1	fgonfer@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J303087671	t	2013-03-14
105	J305950334	7c4a8d09ca3762af61e59520943dc26494f8941b	TV Cable.com, C.A.	f	1	Tvcablecom@hotmail.cpm	2	MI MAMA	\N	\N	192,168,1,101	J305950334	t	2013-03-14
106	J301177156	7c4a8d09ca3762af61e59520943dc26494f8941b	TV Star Satélite, C.A.	f	1	asilvamoreno@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J301177156	t	2013-03-14
107	J310286183	7c4a8d09ca3762af61e59520943dc26494f8941b	Corporación Los Cortijos, C.A.	f	1	telecablebna@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J310286183	t	2013-03-14
108	J003311346	7c4a8d09ca3762af61e59520943dc26494f8941b	Sistemas Cablevisión, C.A.	f	1	mcmoros@vepaco.com	2	MI MAMA	\N	\N	192,168,1,101	J003311346	t	2013-03-14
109	J311274944	7c4a8d09ca3762af61e59520943dc26494f8941b	Reperesentaciones Inversat C.A.	f	1	inversat10@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J311274944	t	2013-03-14
110	J312200162	7c4a8d09ca3762af61e59520943dc26494f8941b	Cable TV Premier, C.A.	f	1	cabletvpremier@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J312200162	t	2013-03-14
111	J308726141	7c4a8d09ca3762af61e59520943dc26494f8941b	TV Cable Millennium, C.A.	f	1	www.cablemillenium@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J308726141	t	2013-03-14
112	J003439940	7c4a8d09ca3762af61e59520943dc26494f8941b	Telcel, C.A.	f	1	luis.martinez@telefonica.com.ve	2	MI MAMA	\N	\N	192,168,1,101	J003439940	t	2013-03-14
113	J308809985	7c4a8d09ca3762af61e59520943dc26494f8941b	TV Cable Litoral, C.A.	f	1	zoda-76@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J308809985	t	2013-03-14
114	J308182516	7c4a8d09ca3762af61e59520943dc26494f8941b	The House´s Televisión C.A.	f	1	administracion@cablehogar.net	2	MI MAMA	\N	\N	192,168,1,101	J308182516	t	2013-03-14
115	J308730246	7c4a8d09ca3762af61e59520943dc26494f8941b	Inversiones Puerto Ayacucho C.A	f	1	halberto80@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J308730246	t	2013-03-14
116	J309077694	7c4a8d09ca3762af61e59520943dc26494f8941b	Inversiones & Telecomunicaciones Open T.V. C.A.	f	1	opentv@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J309077694	t	2013-03-14
117	J310106410	7c4a8d09ca3762af61e59520943dc26494f8941b	Norte Vision C.A.	f	1	nortevision09@gmail.com	2	MI MAMA	\N	\N	192,168,1,101	J310106410	t	2013-03-14
118	J308200492	7c4a8d09ca3762af61e59520943dc26494f8941b	Divercable, C.A.	f	1	divercable1@gmail.com	2	MI MAMA	\N	\N	192,168,1,101	J308200492	t	2013-03-14
119	J309109448	7c4a8d09ca3762af61e59520943dc26494f8941b	Telecomunicaciones Network C.A.	f	1	telecomnetwork@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J309109448	t	2013-03-14
120	J295300301	7c4a8d09ca3762af61e59520943dc26494f8941b	Fibra TV. C.A.	f	1	diegotirado@yahoo.com	2	MI MAMA	\N	\N	192,168,1,101	J295300301	t	2013-03-14
121	J311611568	7c4a8d09ca3762af61e59520943dc26494f8941b	Cablecel Plus, C.A.	f	1	cablecel-plus@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J311611568	t	2013-03-14
122	J294943152	7c4a8d09ca3762af61e59520943dc26494f8941b	TTC Telecom Calabozo, C.A.	f	1	halberto80@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J294943152	t	2013-03-14
123	J306838791	7c4a8d09ca3762af61e59520943dc26494f8941b	Corporación Sombrero COM Satelital, C.A.	f	1	halberto80@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J306838791	t	2013-03-14
124	J306796584	7c4a8d09ca3762af61e59520943dc26494f8941b	Corporación Tucupita Satelital, C.A.	f	1	halberto80@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J306796584	t	2013-03-14
125	J307213000	7c4a8d09ca3762af61e59520943dc26494f8941b	Corporación Altagracia Satelital, C.A.	f	1	halberto80@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J307213000	t	2013-03-14
126	J304521367	7c4a8d09ca3762af61e59520943dc26494f8941b	ABA Cantaura Visión C.A.	f	1	halberto80@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J304521367	t	2013-03-14
127	J306763937	7c4a8d09ca3762af61e59520943dc26494f8941b	Corporación Intercaicara Satelital, C.A.	f	1	halberto80@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J306763937	t	2013-03-14
128	J295212925	7c4a8d09ca3762af61e59520943dc26494f8941b	Cabel Visión 21, C.A.	f	1	cabelvision21@yahoo.es	2	MI MAMA	\N	\N	192,168,1,101	J295212925	t	2013-03-14
129	J297059172	7c4a8d09ca3762af61e59520943dc26494f8941b	Viginet, C.A.	f	1	viginetca@gmail.com	2	MI MAMA	\N	\N	192,168,1,101	J297059172	t	2013-03-14
130	J295171668	7c4a8d09ca3762af61e59520943dc26494f8941b	COHERY VISIÓN, C.A.	f	1	coheryvision@yahoo.es	2	MI MAMA	\N	\N	192,168,1,101	J295171668	t	2013-03-14
131	J297655948	7c4a8d09ca3762af61e59520943dc26494f8941b	Corporación Matrix, C.A.	f	1	tibisaymatrix@gmail.com	2	MI MAMA	\N	\N	192,168,1,101	J297655948	t	2013-03-14
132	J296612676	7c4a8d09ca3762af61e59520943dc26494f8941b	C- Agua Visión	f	1	caguavision@yahoo.es	2	MI MAMA	\N	\N	192,168,1,101	J296612676	t	2013-03-14
133	J306630430	7c4a8d09ca3762af61e59520943dc26494f8941b	TTC Telecom Turmero, C.A	f	1	halberto80@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J306630430	t	2013-03-14
134	J295627580	7c4a8d09ca3762af61e59520943dc26494f8941b	Maxi Cable, C.A.	f	1	maxicablec.a@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J295627580	t	2013-03-14
138	J000841918	7c4a8d09ca3762af61e59520943dc26494f8941b	C.A. Cinematográfica Blancica	f	1	msaleta@blancica.com.ve	2	MI MAMA	\N	\N	192,168,1,101	J000841918	t	2013-03-14
139	J302092086	7c4a8d09ca3762af61e59520943dc26494f8941b	The Walt Disney Company Venezuela, S.A.	f	1	anibal.codebo@email.disney.com	2	MI MAMA	\N	\N	192,168,1,101	J302092086	t	2013-03-14
140	J001819134	7c4a8d09ca3762af61e59520943dc26494f8941b	Blancic Video, C.A	f	1	msaleta@blancica.com.ve	2	MI MAMA	\N	\N	192,168,1,101	J001819134	t	2013-03-14
141	J314914871	7c4a8d09ca3762af61e59520943dc26494f8941b	Films Sin Fronteras C.A.	f	1	graffea2000@yahoo.com	2	MI MAMA	\N	\N	192,168,1,101	J314914871	t	2013-03-14
142	J001241531	7c4a8d09ca3762af61e59520943dc26494f8941b	Distribuidora Sonográfica, C.A.	f	1	rpetrocelli@recorland.com	2	MI MAMA	\N	\N	192,168,1,101	J001241531	t	2013-03-14
144	J090161244	7c4a8d09ca3762af61e59520943dc26494f8941b	Sonido Impacto 22, C.A.	f	1	avinci57@gmail.com	2	MI MAMA	\N	\N	192,168,1,101	J090161244	t	2013-03-14
143	J002745762	7c4a8d09ca3762af61e59520943dc26494f8941b	Club de Video Veroes, C.A.	f	1	ivanvideoveroes@hotmail.com	2	MI MAMA	\N	\N	192,168,1,101	J002745762	t	2013-03-14
41	J310438510	7c4a8d09ca3762af61e59520943dc26494f8941b	Vencine, C.A.	f	1	vencineca@cantv.net	2	MI MAMA	\N	\N	192,168,1,101	J310438510	t	2013-03-14
1	J090188975	7c4a8d09ca3762af61e59520943dc26494f8941b	Administradora de Cines Barinas, C.A.	f	1	cines@cinesacarigua.com	2	MI MAMA	\N	\N	192,168,1,101	J090188975	t	2013-03-14
\.


--
-- TOC entry 3199 (class 0 OID 25025)
-- Dependencies: 242 3262
-- Data for Name: conusu_interno; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY conusu_interno (id, fecha_entrada, conusuid, bln_fiscalizado, bln_nocontribuyente, observaciones, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 3903 (class 0 OID 0)
-- Dependencies: 243
-- Name: conusu_interno_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('conusu_interno_id_seq', 1, false);


--
-- TOC entry 3904 (class 0 OID 0)
-- Dependencies: 245
-- Name: conusu_tipocon_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('conusu_tipocon_id_seq', 143, true);


--
-- TOC entry 3201 (class 0 OID 25036)
-- Dependencies: 244 3262
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
\.


--
-- TOC entry 3143 (class 0 OID 24797)
-- Dependencies: 186 3262
-- Data for Name: conusuco; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY conusuco (id, conusuid, contribuid) FROM stdin;
\.


--
-- TOC entry 3145 (class 0 OID 24802)
-- Dependencies: 188 3262
-- Data for Name: conusuti; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY conusuti (id, nombre, administra, liquida, visualiza, usuarioid, ip) FROM stdin;
1	ADMINISTRADOR	t	t	f	16	192.168.1.102
\.


--
-- TOC entry 3147 (class 0 OID 24810)
-- Dependencies: 190 3262
-- Data for Name: conusuto; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY conusuto (id, token, conusuid, fechacrea, fechacadu, usado) FROM stdin;
131	90a14de88990b8fbf342bd3a177a0fb100c8b1f0	145	2013-07-09 16:33:57.785188	2013-07-10 16:33:57.785188	t
\.


--
-- TOC entry 3203 (class 0 OID 25042)
-- Dependencies: 246 3262
-- Data for Name: correlativos_actas; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY correlativos_actas (id, nombre, correlativo, anio, tipo) FROM stdin;
1	autorizacion fiscal	28	2013	\N
2	acta reparo	3	2013	act-rpfis-1
\.


--
-- TOC entry 3905 (class 0 OID 0)
-- Dependencies: 247
-- Name: correlativos_actas_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('correlativos_actas_id_seq', 2, true);


--
-- TOC entry 3205 (class 0 OID 25050)
-- Dependencies: 248 3262
-- Data for Name: ctaconta; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY ctaconta (cuenta, descripcion, usaraux, inactiva, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 3206 (class 0 OID 25055)
-- Dependencies: 249 3262
-- Data for Name: declara; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY declara (id, nudeclara, nudeposito, tdeclaraid, fechaelab, fechaini, fechafin, replegalid, baseimpo, alicuota, exonera, nuactoexon, credfiscal, contribant, plasustid, montopagar, bln_reparo, fechapago, fechaconci, asientoid, usuarioid, ip, tipocontribuid, conusuid, calpagodid, reparoid, proceso, bln_declaro0) FROM stdin;
255	120113000047500010	1201130000475000	2	2013-07-10 11:30:19.740971	2013-02-01	2013-02-25	4	95000.00	5.00	0.00	\N	0.00	\N	\N	4750.00	f	2013-07-10	\N	\N	17	192.168.1.101	1	2	338	\N	\N	f
256	12051342500000007	1205134250000000	2	2013-07-10 11:50:43.043922	2013-06-01	2013-06-25	4	850000000.00	5.00	0.00	\N	0.00	\N	\N	42500000.00	f	2013-07-10	\N	\N	17	192.168.1.101	1	2	342	\N	\N	f
401	\N	\N	2	2013-07-12 17:44:41.414688	2013-04-01	2013-04-22	4	150000.00	5.00	0.00	\N	0.00	\N	\N	7500.00	t	\N	\N	\N	17	192.168.1.101	1	1	340	400	\N	f
402	\N	\N	2	2013-07-12 17:44:41.414688	2013-05-01	2013-05-23	4	5200000.00	5.00	0.00	\N	0.00	\N	\N	260000.00	t	\N	\N	\N	17	192.168.1.101	1	1	341	400	\N	f
403	\N	\N	2	2013-07-12 17:44:41.414688	2013-06-01	2013-06-25	4	650000.00	5.00	0.00	\N	0.00	\N	\N	32500.00	t	\N	\N	\N	17	192.168.1.101	1	1	342	400	\N	f
404	\N	\N	2	2013-07-12 17:44:41.414688	2013-07-01	2013-07-22	4	9500000.00	5.00	0.00	\N	0.00	\N	\N	475000.00	t	\N	\N	\N	17	192.168.1.101	1	1	343	400	\N	f
406	\N	\N	2	2013-07-12 17:46:21.225721	2013-03-01	2013-03-22	4	5000000.00	5.00	0.00	\N	0.00	\N	\N	250000.00	t	\N	\N	\N	17	192.168.1.101	1	3	339	405	\N	f
407	\N	\N	2	2013-07-12 17:46:21.225721	2013-04-01	2013-04-22	4	96555.00	5.00	0.00	\N	0.00	\N	\N	4827.75	t	\N	\N	\N	17	192.168.1.101	1	3	340	405	\N	f
408	\N	\N	2	2013-07-12 17:46:21.225721	2013-05-01	2013-05-23	4	521545.00	5.00	0.00	\N	0.00	\N	\N	26077.25	t	\N	\N	\N	17	192.168.1.101	1	3	341	405	\N	f
409	12121000450000008	1212100045000000	2	2013-07-21 12:21:24.683205	2011-01-01	2011-01-25	4	9000000.00	5.00	0.00	\N	0.00	\N	\N	450000.00	f	\N	\N	\N	17	127.0.0.1	1	1	167	\N	\N	f
410	12111000350000002	1211100035000000	2	2013-07-21 12:22:31.000422	2010-12-01	2010-12-22	4	7000000.00	5.00	0.00	\N	0.00	\N	\N	350000.00	f	\N	\N	\N	17	127.0.0.1	1	1	166	\N	\N	f
459	\N	\N	2	2013-07-24 17:20:35.273705	2013-04-01	2013-04-22	4	950000.00	5.00	0.00	\N	0.00	\N	\N	47500.00	t	\N	\N	\N	17	127.0.0.1	1	2	340	458	\N	f
460	\N	\N	2	2013-07-24 17:20:35.273705	2013-05-01	2013-05-23	4	1000000.00	5.00	0.00	\N	0.00	\N	\N	50000.00	t	\N	\N	\N	17	127.0.0.1	1	2	341	458	\N	f
461	\N	\N	2	2013-07-24 17:20:35.273705	2013-07-01	2013-07-22	4	900000.00	5.00	0.00	\N	0.00	\N	\N	45000.00	t	\N	\N	\N	17	127.0.0.1	1	2	343	458	\N	f
463	\N	\N	2	2013-07-24 17:55:54.659565	2013-03-01	2013-03-22	4	5000000.00	5.00	0.00	\N	0.00	\N	\N	250000.00	t	\N	\N	\N	17	127.0.0.1	1	3	339	462	\N	f
464	\N	\N	2	2013-07-24 17:55:54.659565	2013-04-01	2013-04-22	4	96555.00	5.00	0.00	\N	0.00	\N	\N	4827.75	t	\N	\N	\N	17	127.0.0.1	1	3	340	462	\N	f
465	\N	\N	2	2013-07-24 17:55:54.659565	2013-05-01	2013-05-23	4	521545.00	5.00	0.00	\N	0.00	\N	\N	26077.25	t	\N	\N	\N	17	127.0.0.1	1	3	341	462	\N	f
\.


--
-- TOC entry 3153 (class 0 OID 24843)
-- Dependencies: 196 3262
-- Data for Name: declara_viejo; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY declara_viejo (id, nudeclara, nudeposito, tdeclaraid, fechaelab, fechaini, fechafin, replegalid, baseimpo, alicuota, exonera, nuactoexon, credfiscal, contribant, plasustid, nuresactfi, fechanoti, intemora, reparofis, multa, montopagar, fechapago, fechaconci, asientoid, usuarioid, ip, tipocontribuid, conusuid, calpagodid) FROM stdin;
\.


--
-- TOC entry 3155 (class 0 OID 24856)
-- Dependencies: 198 3262
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
-- TOC entry 3207 (class 0 OID 25069)
-- Dependencies: 250 3262
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
4261	0.000000	0.000000	5	06	2013	374	192.168.1.101	48
4262	0.000000	0.000000	10	07	2013	374	192.168.1.101	48
\.


--
-- TOC entry 3906 (class 0 OID 0)
-- Dependencies: 251
-- Name: detalle_interes_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('detalle_interes_id_seq', 4262, true);


--
-- TOC entry 3907 (class 0 OID 0)
-- Dependencies: 253
-- Name: detalle_interes_id_seq1; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('detalle_interes_id_seq1', 125, true);


--
-- TOC entry 3209 (class 0 OID 25077)
-- Dependencies: 252 3262
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
-- TOC entry 3211 (class 0 OID 25085)
-- Dependencies: 254 3262
-- Data for Name: detalles_contrib_calc; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY detalles_contrib_calc (id, declaraid, contrib_calcid, proceso, observacion) FROM stdin;
74	256	149	aprobado	\N
\.


--
-- TOC entry 3908 (class 0 OID 0)
-- Dependencies: 255
-- Name: detalles_contrib_calc_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('detalles_contrib_calc_id_seq', 74, true);


--
-- TOC entry 3213 (class 0 OID 25093)
-- Dependencies: 256 3262
-- Data for Name: dettalles_fizcalizacion; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY dettalles_fizcalizacion (id, periodo, anio, base, alicuota, total, asignacionfid, bln_borrado, calpagodid, bln_reparo_faltante, bln_identificador) FROM stdin;
97	3	2013	520000	5.00	26000	940	t	340	f	t
98	3	2013	150000	5.00	7500	940	f	340	f	t
99	4	2013	5200000	5.00	260000	940	f	341	f	t
100	5	2013	650000	5.00	32500	940	f	342	f	t
101	6	2013	9500000	5.00	475000	940	f	343	f	t
102	2	2013	5000000	5.00	250000	942	f	339	f	t
103	3	2013	96555	5.00	4827.75	942	f	340	f	t
104	4	2013	521545	5.00	26077.25	942	f	341	f	t
105	3	2013	950000	5.00	47500	941	f	340	f	t
106	4	2013	1000000	5.00	50000	941	f	341	f	t
107	6	2013	200000	5.00	10000	944	f	343	f	t
108	6	2013	900000	5.00	45000	941	f	343	f	t
109	3	2013	3000000	5.00	150000	945	f	340	f	t
\.


--
-- TOC entry 3909 (class 0 OID 0)
-- Dependencies: 257
-- Name: dettalles_fizcalizacion_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('dettalles_fizcalizacion_id_seq', 109, true);


--
-- TOC entry 3215 (class 0 OID 25104)
-- Dependencies: 258 3262
-- Data for Name: document; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY document (id, nombre, docu, inactivo, usfonproid, ip) FROM stdin;
\.


--
-- TOC entry 3910 (class 0 OID 0)
-- Dependencies: 259
-- Name: document_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('document_id_seq', 1, false);


--
-- TOC entry 3159 (class 0 OID 24870)
-- Dependencies: 202 3262
-- Data for Name: entidad; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY entidad (id, nombre, entidad, orden) FROM stdin;
\.


--
-- TOC entry 3157 (class 0 OID 24864)
-- Dependencies: 200 3262
-- Data for Name: entidadd; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY entidadd (id, entidadid, nombre, accion, orden) FROM stdin;
\.


--
-- TOC entry 3161 (class 0 OID 24876)
-- Dependencies: 204 3262
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
-- TOC entry 3217 (class 0 OID 25113)
-- Dependencies: 260 3262
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
-- TOC entry 3911 (class 0 OID 0)
-- Dependencies: 261
-- Name: interes_bcv_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('interes_bcv_id_seq', 170, true);


--
-- TOC entry 3165 (class 0 OID 24886)
-- Dependencies: 208 3262
-- Data for Name: perusu; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY perusu (id, nombre, inactivo, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 3163 (class 0 OID 24881)
-- Dependencies: 206 3262
-- Data for Name: perusud; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY perusud (id, perusuid, entidaddid, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 3167 (class 0 OID 24892)
-- Dependencies: 210 3262
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
-- TOC entry 3219 (class 0 OID 25121)
-- Dependencies: 262 3262
-- Data for Name: presidente; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY presidente (id, nombres, apellidos, cedula, nro_decreto, nro_gaceta, dtm_fecha_gaceta, bln_activo, usuarioid, ip) FROM stdin;
1	Alizar	Dahdah Antar	0	7.252	39.373	24-02-2010	t	48	192.168.1.102
\.


--
-- TOC entry 3912 (class 0 OID 0)
-- Dependencies: 263
-- Name: presidente_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('presidente_id_seq', 1, true);


--
-- TOC entry 3221 (class 0 OID 25130)
-- Dependencies: 264 3262
-- Data for Name: reparos; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY reparos (id, tdeclaraid, fechaelab, montopagar, asientoid, usuarioid, ip, tipocontribuid, conusuid, bln_activo, proceso, fecha_notificacion, bln_sumario, actaid, recibido_por) FROM stdin;
462	2	2013-07-24 17:55:54.659565	280905.00	\N	48	127.0.0.1	1	3	f	\N	\N	f	99	\N
458	2	2013-07-24 17:20:35.273705	142500.00	\N	48	127.0.0.1	1	2	f	\N	\N	f	98	\N
\.


--
-- TOC entry 3169 (class 0 OID 24897)
-- Dependencies: 212 3262
-- Data for Name: replegal; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY replegal (id, contribuid, nombre, apellido, ci, domfiscal, estadoid, ciudadid, zonaposta, telefhab, telefofc, fax, email, pinbb, skype, cextra1, cextra2, cextra3, cextra4, cextra5, usuarioid, ip) FROM stdin;
4	1	prueba	prueba	17042979	no se	1	5	0212	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	192.168.1.101
\.


--
-- TOC entry 3171 (class 0 OID 24905)
-- Dependencies: 214 3262
-- Data for Name: tdeclara; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY tdeclara (id, nombre, tipo, usuarioid, ip) FROM stdin;
2	AUTOLIQUIDACION	0	17	192.168.1.101
3	SUSTITUTIVA	0	17	192.168.1.102
4	MULTA POR PAGO EXTEMPORANEO	1	17	192.168.1.101
5	MULTA POR REPARO FISCAL	2	17	192.168.1.101
\.


--
-- TOC entry 3173 (class 0 OID 24910)
-- Dependencies: 216 3262
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
-- TOC entry 3175 (class 0 OID 24917)
-- Dependencies: 218 3262
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
-- TOC entry 3222 (class 0 OID 25140)
-- Dependencies: 265 3262
-- Data for Name: tmpaccioni; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY tmpaccioni (id, contribuid, nombre, apellido, ci, domfiscal, nuacciones, valaccion, cextra1, cextra2, cextra3, cextra4, cextra5, ip) FROM stdin;
\.


--
-- TOC entry 3223 (class 0 OID 25148)
-- Dependencies: 266 3262
-- Data for Name: tmpcontri; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY tmpcontri (id, tipocontid, razonsocia, dencomerci, actieconid, rif, numregcine, domfiscal, estadoid, ciudadid, zonapostal, telef1, telef2, telef3, fax1, fax2, email, pinbb, skype, twitter, facebook, nuacciones, valaccion, capitalsus, capitalpag, regmerofc, rmnumero, rmfolio, rmtomo, rmfechapro, rmncontrol, rmobjeto, domcomer, conusuid, tiporeg, cextra1, cextra2, cextra3, cextra4, cextra5, ip) FROM stdin;
\.


--
-- TOC entry 3224 (class 0 OID 25158)
-- Dependencies: 267 3262
-- Data for Name: tmprelegal; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY tmprelegal (id, contribuid, nombre, apellido, ci, domfiscal, estadoid, ciudadid, zonaposta, telefhab, telefofc, fax, email, pinbb, skype, cextra1, cextra2, cextra3, cextra4, cextra5, ip) FROM stdin;
\.


--
-- TOC entry 3177 (class 0 OID 24922)
-- Dependencies: 220 3262
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
-- TOC entry 3181 (class 0 OID 24937)
-- Dependencies: 224 3262
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
-- TOC entry 3179 (class 0 OID 24928)
-- Dependencies: 222 3262
-- Data for Name: usfonpto; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY usfonpto (id, token, usfonproid, fechacrea, fechacadu, usado) FROM stdin;
\.


SET search_path = historial, pg_catalog;

--
-- TOC entry 3913 (class 0 OID 0)
-- Dependencies: 270
-- Name: Bitacora_IDBitacora_seq; Type: SEQUENCE SET; Schema: historial; Owner: postgres
--

SELECT pg_catalog.setval('"Bitacora_IDBitacora_seq"', 34, true);


--
-- TOC entry 3225 (class 0 OID 25170)
-- Dependencies: 269 3262
-- Data for Name: bitacora; Type: TABLE DATA; Schema: historial; Owner: postgres
--

COPY bitacora (id, fecha, tabla, idusuario, accion, datosnew, datosold, datosdel, valdelid, ip) FROM stdin;
\.


SET search_path = pre_aprobacion, pg_catalog;

--
-- TOC entry 3227 (class 0 OID 25179)
-- Dependencies: 271 3262
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
-- TOC entry 3914 (class 0 OID 0)
-- Dependencies: 272
-- Name: datos_cnac_id_seq; Type: SEQUENCE SET; Schema: pre_aprobacion; Owner: postgres
--

SELECT pg_catalog.setval('datos_cnac_id_seq', 19, true);


--
-- TOC entry 3229 (class 0 OID 25191)
-- Dependencies: 273 3262
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
374	001A	\N	2013-07-10 11:55:59.912457	\N	0	63	192.168.1.101	48	2013-06-25	2013-07-10
\.


--
-- TOC entry 3915 (class 0 OID 0)
-- Dependencies: 274
-- Name: intereses_id_seq; Type: SEQUENCE SET; Schema: pre_aprobacion; Owner: postgres
--

SELECT pg_catalog.setval('intereses_id_seq', 374, true);


--
-- TOC entry 3231 (class 0 OID 25200)
-- Dependencies: 275 3262
-- Data for Name: multas; Type: TABLE DATA; Schema: pre_aprobacion; Owner: postgres
--

COPY multas (id, nresolucion, fechaelaboracion, fechanotificacion, montopagar, declaraid, ip, usuarioid, tipo_multa) FROM stdin;
63	001A	2013-07-10 11:55:59.912457	\N	425000	256	192.168.1.101	48	4
\.


--
-- TOC entry 3916 (class 0 OID 0)
-- Dependencies: 276
-- Name: multas_id_seq; Type: SEQUENCE SET; Schema: pre_aprobacion; Owner: postgres
--

SELECT pg_catalog.setval('multas_id_seq', 63, true);


SET search_path = public, pg_catalog;

--
-- TOC entry 3233 (class 0 OID 25208)
-- Dependencies: 277 3262
-- Data for Name: contrib_calc; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY contrib_calc (id, nombre) FROM stdin;
\.


SET search_path = seg, pg_catalog;

--
-- TOC entry 3234 (class 0 OID 25211)
-- Dependencies: 278 3262
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
-- TOC entry 3917 (class 0 OID 0)
-- Dependencies: 279
-- Name: tbl_cargos_id_seq; Type: SEQUENCE SET; Schema: seg; Owner: postgres
--

SELECT pg_catalog.setval('tbl_cargos_id_seq', 6, true);


--
-- TOC entry 3236 (class 0 OID 25220)
-- Dependencies: 280 3262
-- Data for Name: tbl_ci_sessions; Type: TABLE DATA; Schema: seg; Owner: postgres
--

COPY tbl_ci_sessions (session_id, ip_address, user_agent, last_activity, user_data, prevent_update) FROM stdin;
ea4c82547e3bda9bb0e5c8913a322219	127.0.0.1	Mozilla/5.0 (X11; Linux i686) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/28.0.1500.52 Chrome/28.0.1500.52 Sa	1374712833		0
1b6d11dd0bd5b125bd27249d4622f970	127.0.0.1	Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:22.0) Gecko/20100101 Firefox/22.0	1374714501		0
\.


--
-- TOC entry 3237 (class 0 OID 25230)
-- Dependencies: 281 3262
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
167	141	Reparos activados	listado de los reparos que fueron activados despues de la fiscalizacion	./rrrrrrr	t
\.


--
-- TOC entry 3918 (class 0 OID 0)
-- Dependencies: 282
-- Name: tbl_modulo_id_modulo_seq; Type: SEQUENCE SET; Schema: seg; Owner: postgres
--

SELECT pg_catalog.setval('tbl_modulo_id_modulo_seq', 167, true);


--
-- TOC entry 3239 (class 0 OID 25239)
-- Dependencies: 283 3262
-- Data for Name: tbl_oficinas; Type: TABLE DATA; Schema: seg; Owner: postgres
--

COPY tbl_oficinas (id, nombre, descripcion, fecha_creacion, cod_estructura, usuarioid, ip, bln_borrado) FROM stdin;
1	GERENCIA DE RECAUDACION		2013-05-09	0001	48	192.168.1.102	f
2	GERENCIA DE FISCALIZACION		2013-05-09	0002	48	192.168.1.102	f
3	GERENCIA DE FINANZAS		2013-05-09	0003	48	192.168.1.102	f
4	GERENCIA DE LEGAL		2013-05-09	0004	48	192.168.1.102	f
\.


--
-- TOC entry 3919 (class 0 OID 0)
-- Dependencies: 284
-- Name: tbl_oficinas_id_seq; Type: SEQUENCE SET; Schema: seg; Owner: postgres
--

SELECT pg_catalog.setval('tbl_oficinas_id_seq', 4, true);


--
-- TOC entry 3241 (class 0 OID 25249)
-- Dependencies: 285 3262
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
-- TOC entry 3920 (class 0 OID 0)
-- Dependencies: 286
-- Name: tbl_permiso_id_permiso_seq; Type: SEQUENCE SET; Schema: seg; Owner: postgres
--

SELECT pg_catalog.setval('tbl_permiso_id_permiso_seq', 1845, true);


--
-- TOC entry 3243 (class 0 OID 25255)
-- Dependencies: 287 3262
-- Data for Name: tbl_permiso_trampa; Type: TABLE DATA; Schema: seg; Owner: postgres
--

COPY tbl_permiso_trampa (id_permiso, id_modulo, id_rol, int_permiso, bln_borrado) FROM stdin;
\.


--
-- TOC entry 3921 (class 0 OID 0)
-- Dependencies: 288
-- Name: tbl_permiso_trampa_id_permiso_seq; Type: SEQUENCE SET; Schema: seg; Owner: postgres
--

SELECT pg_catalog.setval('tbl_permiso_trampa_id_permiso_seq', 47, true);


--
-- TOC entry 3245 (class 0 OID 25261)
-- Dependencies: 289 3262
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
-- TOC entry 3922 (class 0 OID 0)
-- Dependencies: 290
-- Name: tbl_rol_id_rol_seq; Type: SEQUENCE SET; Schema: seg; Owner: postgres
--

SELECT pg_catalog.setval('tbl_rol_id_rol_seq', 16, true);


--
-- TOC entry 3247 (class 0 OID 25270)
-- Dependencies: 291 3262
-- Data for Name: tbl_rol_usuario; Type: TABLE DATA; Schema: seg; Owner: postgres
--

COPY tbl_rol_usuario (id_rol_usuario, id_rol, id_usuario, bln_borrado) FROM stdin;
1	1	16	f
19	1	17	f
54	5	47	f
56	5	49	f
55	1	48	f
34	1	18	f
\.


--
-- TOC entry 3923 (class 0 OID 0)
-- Dependencies: 292
-- Name: tbl_rol_usuario_id_rol_usuario_seq; Type: SEQUENCE SET; Schema: seg; Owner: postgres
--

SELECT pg_catalog.setval('tbl_rol_usuario_id_rol_usuario_seq', 56, true);


--
-- TOC entry 3249 (class 0 OID 25276)
-- Dependencies: 293 3262
-- Data for Name: tbl_session_ci; Type: TABLE DATA; Schema: seg; Owner: postgres
--

COPY tbl_session_ci (session_id, ip_address, user_agent, last_activity, user_data) FROM stdin;
f093f9803caa36c8160f5b08bb661a09	127.0.0.1	Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:19.0) Gecko/20100101 Firefox/19.0	1365795522	
\.


--
-- TOC entry 3250 (class 0 OID 25286)
-- Dependencies: 294 3262
-- Data for Name: tbl_usuario_rol; Type: TABLE DATA; Schema: seg; Owner: postgres
--

COPY tbl_usuario_rol (id_usuario_rol, id_usuario, id_rol, bol_borrado) FROM stdin;
\.


--
-- TOC entry 3924 (class 0 OID 0)
-- Dependencies: 295
-- Name: tbl_usuario_rol_id_usuario_rol_seq; Type: SEQUENCE SET; Schema: seg; Owner: postgres
--

SELECT pg_catalog.setval('tbl_usuario_rol_id_usuario_rol_seq', 16, true);


SET search_path = "segContribu", pg_catalog;

--
-- TOC entry 3252 (class 0 OID 25298)
-- Dependencies: 297 3262
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
-- TOC entry 3925 (class 0 OID 0)
-- Dependencies: 298
-- Name: tbl_modulo_id_modulo_seq; Type: SEQUENCE SET; Schema: segContribu; Owner: postgres
--

SELECT pg_catalog.setval('tbl_modulo_id_modulo_seq', 115, true);


--
-- TOC entry 3254 (class 0 OID 25307)
-- Dependencies: 299 3262
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
\.


--
-- TOC entry 3926 (class 0 OID 0)
-- Dependencies: 300
-- Name: tbl_permiso_id_permiso_seq; Type: SEQUENCE SET; Schema: segContribu; Owner: postgres
--

SELECT pg_catalog.setval('tbl_permiso_id_permiso_seq', 36, true);


--
-- TOC entry 3256 (class 0 OID 25313)
-- Dependencies: 301 3262
-- Data for Name: tbl_rol_contribu; Type: TABLE DATA; Schema: segContribu; Owner: postgres
--

COPY tbl_rol_contribu (id_rol, str_rol, str_descripcion, bln_borrado) FROM stdin;
1	Administrador	Administrador del sistema	f
2	Coordinador	Coordinador de la sala situacional	f
3	Analista	Analista de seguimiento	f
4	Datos Iniciales	Carga Inicial de Datos del contribuyente	f
\.


--
-- TOC entry 3927 (class 0 OID 0)
-- Dependencies: 302
-- Name: tbl_rol_id_rol_seq; Type: SEQUENCE SET; Schema: segContribu; Owner: postgres
--

SELECT pg_catalog.setval('tbl_rol_id_rol_seq', 4, true);


--
-- TOC entry 3258 (class 0 OID 25322)
-- Dependencies: 303 3262
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
141	4	145	f
\.


--
-- TOC entry 3928 (class 0 OID 0)
-- Dependencies: 304
-- Name: tbl_rol_usuario_id_rol_usuario_seq; Type: SEQUENCE SET; Schema: segContribu; Owner: postgres
--

SELECT pg_catalog.setval('tbl_rol_usuario_id_rol_usuario_seq', 141, true);


--
-- TOC entry 3260 (class 0 OID 25328)
-- Dependencies: 305 3262
-- Data for Name: tbl_usuario_rol_contribu; Type: TABLE DATA; Schema: segContribu; Owner: postgres
--

COPY tbl_usuario_rol_contribu (id_usuario_rol, id_usuario, id_rol, bol_borrado) FROM stdin;
\.


--
-- TOC entry 3929 (class 0 OID 0)
-- Dependencies: 306
-- Name: tbl_usuario_rol_id_usuario_rol_seq; Type: SEQUENCE SET; Schema: segContribu; Owner: postgres
--

SELECT pg_catalog.setval('tbl_usuario_rol_id_usuario_rol_seq', 16, true);


SET search_path = datos, pg_catalog;

--
-- TOC entry 2805 (class 2606 OID 25404)
-- Dependencies: 226 226 226 3263
-- Name: CT_Accionis_IDContribu_Ci; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY accionis
    ADD CONSTRAINT "CT_Accionis_IDContribu_Ci" UNIQUE (contribuid, ci);


--
-- TOC entry 2604 (class 2606 OID 25406)
-- Dependencies: 167 167 3263
-- Name: CT_ActiExon_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY actiecon
    ADD CONSTRAINT "CT_ActiExon_Nombre" UNIQUE (nombre);


--
-- TOC entry 2609 (class 2606 OID 25408)
-- Dependencies: 169 169 169 3263
-- Name: CT_AlicImp_IDTipoCont_Ano; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY alicimp
    ADD CONSTRAINT "CT_AlicImp_IDTipoCont_Ano" UNIQUE (tipocontid, ano);


--
-- TOC entry 2616 (class 2606 OID 25410)
-- Dependencies: 171 171 171 3263
-- Name: CT_AsiendoD_IDAsiento_Referencia; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY asientod
    ADD CONSTRAINT "CT_AsiendoD_IDAsiento_Referencia" UNIQUE (asientoid, referencia);


--
-- TOC entry 2827 (class 2606 OID 25412)
-- Dependencies: 230 230 3263
-- Name: CT_AsientoM_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY asientom
    ADD CONSTRAINT "CT_AsientoM_Nombre" UNIQUE (nombre);


--
-- TOC entry 2816 (class 2606 OID 25414)
-- Dependencies: 229 229 229 229 3263
-- Name: CT_Asiento_NuAsiento_Mes_Ano; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY asiento
    ADD CONSTRAINT "CT_Asiento_NuAsiento_Mes_Ano" UNIQUE (nuasiento, mes, ano);


--
-- TOC entry 2624 (class 2606 OID 25416)
-- Dependencies: 174 174 3263
-- Name: CT_BaCuenta_Cuenta; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY bacuenta
    ADD CONSTRAINT "CT_BaCuenta_Cuenta" UNIQUE (cuenta);


--
-- TOC entry 2630 (class 2606 OID 25418)
-- Dependencies: 176 176 3263
-- Name: CT_Bancos_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY bancos
    ADD CONSTRAINT "CT_Bancos_Nombre" UNIQUE (nombre);


--
-- TOC entry 2639 (class 2606 OID 25420)
-- Dependencies: 180 180 180 3263
-- Name: CT_CalPagos_Ano_IDTiPeGrav; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY calpago
    ADD CONSTRAINT "CT_CalPagos_Ano_IDTiPeGrav" UNIQUE (ano, tipegravid);


--
-- TOC entry 2641 (class 2606 OID 25422)
-- Dependencies: 180 180 180 3263
-- Name: CT_CalPagos_Nombre_Ano; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY calpago
    ADD CONSTRAINT "CT_CalPagos_Nombre_Ano" UNIQUE (nombre, ano);


--
-- TOC entry 2648 (class 2606 OID 25424)
-- Dependencies: 182 182 3263
-- Name: CT_Cargos_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY cargos
    ADD CONSTRAINT "CT_Cargos_Nombre" UNIQUE (nombre);


--
-- TOC entry 2653 (class 2606 OID 25426)
-- Dependencies: 184 184 184 3263
-- Name: CT_Ciudades_IDEstado_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ciudades
    ADD CONSTRAINT "CT_Ciudades_IDEstado_Nombre" UNIQUE (estadoid, nombre);


--
-- TOC entry 2659 (class 2606 OID 25428)
-- Dependencies: 186 186 186 3263
-- Name: CT_ConUsuCo_IDConUsu_IDContribu; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY conusuco
    ADD CONSTRAINT "CT_ConUsuCo_IDConUsu_IDContribu" UNIQUE (conusuid, contribuid);


--
-- TOC entry 2668 (class 2606 OID 25430)
-- Dependencies: 190 190 3263
-- Name: CT_ConUsuTo_Token; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY conusuto
    ADD CONSTRAINT "CT_ConUsuTo_Token" UNIQUE (token);


--
-- TOC entry 2843 (class 2606 OID 25432)
-- Dependencies: 240 240 240 3263
-- Name: CT_ContribuTi_ContribuID_TipoContID; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY contributi
    ADD CONSTRAINT "CT_ContribuTi_ContribuID_TipoContID" UNIQUE (contribuid, tipocontid);


--
-- TOC entry 2681 (class 2606 OID 25434)
-- Dependencies: 194 194 3263
-- Name: CT_Contribu_NumRegCine; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY contribu
    ADD CONSTRAINT "CT_Contribu_NumRegCine" UNIQUE (numregcine);


--
-- TOC entry 2683 (class 2606 OID 25436)
-- Dependencies: 194 194 3263
-- Name: CT_Contribu_RazonSocia; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY contribu
    ADD CONSTRAINT "CT_Contribu_RazonSocia" UNIQUE (razonsocia);


--
-- TOC entry 2685 (class 2606 OID 25438)
-- Dependencies: 194 194 3263
-- Name: CT_Contribu_Rif; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY contribu
    ADD CONSTRAINT "CT_Contribu_Rif" UNIQUE (rif);


--
-- TOC entry 2860 (class 2606 OID 25440)
-- Dependencies: 249 249 3263
-- Name: CT_Decla_NuDeclara; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT "CT_Decla_NuDeclara" UNIQUE (nudeclara);


--
-- TOC entry 2862 (class 2606 OID 25442)
-- Dependencies: 249 249 3263
-- Name: CT_Decla_NuDeposito; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT "CT_Decla_NuDeposito" UNIQUE (nudeposito);


--
-- TOC entry 2694 (class 2606 OID 25444)
-- Dependencies: 196 196 3263
-- Name: CT_Declara_NuDeclara; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY declara_viejo
    ADD CONSTRAINT "CT_Declara_NuDeclara" UNIQUE (nudeclara);


--
-- TOC entry 2696 (class 2606 OID 25446)
-- Dependencies: 196 196 3263
-- Name: CT_Declara_NuDeposito; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY declara_viejo
    ADD CONSTRAINT "CT_Declara_NuDeposito" UNIQUE (nudeposito);


--
-- TOC entry 2710 (class 2606 OID 25448)
-- Dependencies: 198 198 3263
-- Name: CT_Departam_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY departam
    ADD CONSTRAINT "CT_Departam_Nombre" UNIQUE (nombre);


--
-- TOC entry 2884 (class 2606 OID 25450)
-- Dependencies: 258 258 3263
-- Name: CT_Document_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY document
    ADD CONSTRAINT "CT_Document_Nombre" UNIQUE (nombre);


--
-- TOC entry 2715 (class 2606 OID 25452)
-- Dependencies: 200 200 200 3263
-- Name: CT_EntidadD_IDEntidad_Accion; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY entidadd
    ADD CONSTRAINT "CT_EntidadD_IDEntidad_Accion" UNIQUE (entidadid, accion);


--
-- TOC entry 2717 (class 2606 OID 25454)
-- Dependencies: 200 200 200 3263
-- Name: CT_EntidadD_IDEntidad_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY entidadd
    ADD CONSTRAINT "CT_EntidadD_IDEntidad_Nombre" UNIQUE (entidadid, nombre);


--
-- TOC entry 2719 (class 2606 OID 25456)
-- Dependencies: 200 200 200 3263
-- Name: CT_EntidadD_IDEntidad_Orden; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY entidadd
    ADD CONSTRAINT "CT_EntidadD_IDEntidad_Orden" UNIQUE (entidadid, orden);


--
-- TOC entry 2727 (class 2606 OID 25458)
-- Dependencies: 202 202 3263
-- Name: CT_Entidad_Entidad; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY entidad
    ADD CONSTRAINT "CT_Entidad_Entidad" UNIQUE (entidad);


--
-- TOC entry 2729 (class 2606 OID 25460)
-- Dependencies: 202 202 3263
-- Name: CT_Entidad_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY entidad
    ADD CONSTRAINT "CT_Entidad_Nombre" UNIQUE (nombre);


--
-- TOC entry 2731 (class 2606 OID 25462)
-- Dependencies: 202 202 3263
-- Name: CT_Entidad_Orden; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY entidad
    ADD CONSTRAINT "CT_Entidad_Orden" UNIQUE (orden);


--
-- TOC entry 2735 (class 2606 OID 25464)
-- Dependencies: 204 204 3263
-- Name: CT_Estados_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY estados
    ADD CONSTRAINT "CT_Estados_Nombre" UNIQUE (nombre);


--
-- TOC entry 2740 (class 2606 OID 25466)
-- Dependencies: 206 206 206 3263
-- Name: CT_PerUsuD_IDPerUsu_IDEntidadD; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY perusud
    ADD CONSTRAINT "CT_PerUsuD_IDPerUsu_IDEntidadD" UNIQUE (perusuid, entidaddid);


--
-- TOC entry 2747 (class 2606 OID 25468)
-- Dependencies: 208 208 3263
-- Name: CT_PerUsu_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY perusu
    ADD CONSTRAINT "CT_PerUsu_Nombre" UNIQUE (nombre);


--
-- TOC entry 2752 (class 2606 OID 25470)
-- Dependencies: 210 210 3263
-- Name: CT_PregSecr_Pregunta; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY pregsecr
    ADD CONSTRAINT "CT_PregSecr_Pregunta" UNIQUE (nombre);


--
-- TOC entry 2757 (class 2606 OID 25472)
-- Dependencies: 212 212 212 3263
-- Name: CT_RepLegal_IDContribu_Ci; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY replegal
    ADD CONSTRAINT "CT_RepLegal_IDContribu_Ci" UNIQUE (contribuid, ci);


--
-- TOC entry 2768 (class 2606 OID 25474)
-- Dependencies: 214 214 3263
-- Name: CT_TDeclara_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tdeclara
    ADD CONSTRAINT "CT_TDeclara_Nombre" UNIQUE (nombre);


--
-- TOC entry 2773 (class 2606 OID 25476)
-- Dependencies: 216 216 3263
-- Name: CT_TiPeGrav_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tipegrav
    ADD CONSTRAINT "CT_TiPeGrav_Nombre" UNIQUE (nombre);


--
-- TOC entry 2778 (class 2606 OID 25478)
-- Dependencies: 218 218 3263
-- Name: CT_TipoCont_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tipocont
    ADD CONSTRAINT "CT_TipoCont_Nombre" UNIQUE (nombre);


--
-- TOC entry 2905 (class 2606 OID 25480)
-- Dependencies: 266 266 3263
-- Name: CT_TmpContri_NumRegCine; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tmpcontri
    ADD CONSTRAINT "CT_TmpContri_NumRegCine" UNIQUE (numregcine);


--
-- TOC entry 2907 (class 2606 OID 25482)
-- Dependencies: 266 266 3263
-- Name: CT_TmpContri_RazonSocia; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tmpcontri
    ADD CONSTRAINT "CT_TmpContri_RazonSocia" UNIQUE (razonsocia);


--
-- TOC entry 2909 (class 2606 OID 25484)
-- Dependencies: 266 266 3263
-- Name: CT_TmpContri_Rif; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tmpcontri
    ADD CONSTRAINT "CT_TmpContri_Rif" UNIQUE (rif);


--
-- TOC entry 2919 (class 2606 OID 25486)
-- Dependencies: 267 267 267 3263
-- Name: CT_TmpReLegal_IDContribu_Ci; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tmprelegal
    ADD CONSTRAINT "CT_TmpReLegal_IDContribu_Ci" UNIQUE (contribuid, ci);


--
-- TOC entry 2794 (class 2606 OID 25488)
-- Dependencies: 224 224 3263
-- Name: CT_USFonPro_Email; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY usfonpro
    ADD CONSTRAINT "CT_USFonPro_Email" UNIQUE (email);


--
-- TOC entry 2784 (class 2606 OID 25490)
-- Dependencies: 220 220 3263
-- Name: CT_UndTrib_Fecha; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY undtrib
    ADD CONSTRAINT "CT_UndTrib_Fecha" UNIQUE (fecha);


--
-- TOC entry 2789 (class 2606 OID 25492)
-- Dependencies: 222 222 3263
-- Name: CT_UsFonpTo_Token; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY usfonpto
    ADD CONSTRAINT "CT_UsFonpTo_Token" UNIQUE (token);


--
-- TOC entry 2796 (class 2606 OID 25494)
-- Dependencies: 224 224 3263
-- Name: CT_UsFonpro_Login; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY usfonpro
    ADD CONSTRAINT "CT_UsFonpro_Login" UNIQUE (login);


--
-- TOC entry 2897 (class 2606 OID 25496)
-- Dependencies: 265 265 265 3263
-- Name: CT_tmpAccioni_ContribuID_Ci; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tmpaccioni
    ADD CONSTRAINT "CT_tmpAccioni_ContribuID_Ci" UNIQUE (contribuid, ci);


--
-- TOC entry 2812 (class 2606 OID 25498)
-- Dependencies: 226 226 3263
-- Name: PK_Accionis; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY accionis
    ADD CONSTRAINT "PK_Accionis" PRIMARY KEY (id);


--
-- TOC entry 2607 (class 2606 OID 25500)
-- Dependencies: 167 167 3263
-- Name: PK_ActiEcon; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY actiecon
    ADD CONSTRAINT "PK_ActiEcon" PRIMARY KEY (id);

ALTER TABLE actiecon CLUSTER ON "PK_ActiEcon";


--
-- TOC entry 2614 (class 2606 OID 25502)
-- Dependencies: 169 169 3263
-- Name: PK_AlicImp; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY alicimp
    ADD CONSTRAINT "PK_AlicImp" PRIMARY KEY (id);

ALTER TABLE alicimp CLUSTER ON "PK_AlicImp";


--
-- TOC entry 2825 (class 2606 OID 25504)
-- Dependencies: 229 229 3263
-- Name: PK_Asiento; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY asiento
    ADD CONSTRAINT "PK_Asiento" PRIMARY KEY (id);

ALTER TABLE asiento CLUSTER ON "PK_Asiento";


--
-- TOC entry 2622 (class 2606 OID 25506)
-- Dependencies: 171 171 3263
-- Name: PK_AsientoD; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY asientod
    ADD CONSTRAINT "PK_AsientoD" PRIMARY KEY (id);

ALTER TABLE asientod CLUSTER ON "PK_AsientoD";


--
-- TOC entry 2830 (class 2606 OID 25508)
-- Dependencies: 230 230 3263
-- Name: PK_AsientoM; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY asientom
    ADD CONSTRAINT "PK_AsientoM" PRIMARY KEY (id);

ALTER TABLE asientom CLUSTER ON "PK_AsientoM";


--
-- TOC entry 2835 (class 2606 OID 25510)
-- Dependencies: 232 232 3263
-- Name: PK_AsientoMD; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY asientomd
    ADD CONSTRAINT "PK_AsientoMD" PRIMARY KEY (id);

ALTER TABLE asientomd CLUSTER ON "PK_AsientoMD";


--
-- TOC entry 2628 (class 2606 OID 25512)
-- Dependencies: 174 174 3263
-- Name: PK_BaCuenta; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY bacuenta
    ADD CONSTRAINT "PK_BaCuenta" PRIMARY KEY (id);

ALTER TABLE bacuenta CLUSTER ON "PK_BaCuenta";


--
-- TOC entry 2633 (class 2606 OID 25514)
-- Dependencies: 176 176 3263
-- Name: PK_Bancos; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY bancos
    ADD CONSTRAINT "PK_Bancos" PRIMARY KEY (id);

ALTER TABLE bancos CLUSTER ON "PK_Bancos";


--
-- TOC entry 2637 (class 2606 OID 25516)
-- Dependencies: 178 178 3263
-- Name: PK_CalPagoD; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY calpagod
    ADD CONSTRAINT "PK_CalPagoD" PRIMARY KEY (id);

ALTER TABLE calpagod CLUSTER ON "PK_CalPagoD";


--
-- TOC entry 2646 (class 2606 OID 25518)
-- Dependencies: 180 180 3263
-- Name: PK_CalPagos; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY calpago
    ADD CONSTRAINT "PK_CalPagos" PRIMARY KEY (id);

ALTER TABLE calpago CLUSTER ON "PK_CalPagos";


--
-- TOC entry 2651 (class 2606 OID 25520)
-- Dependencies: 182 182 3263
-- Name: PK_Cargos; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY cargos
    ADD CONSTRAINT "PK_Cargos" PRIMARY KEY (id);

ALTER TABLE cargos CLUSTER ON "PK_Cargos";


--
-- TOC entry 2657 (class 2606 OID 25522)
-- Dependencies: 184 184 3263
-- Name: PK_Ciudades; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ciudades
    ADD CONSTRAINT "PK_Ciudades" PRIMARY KEY (id);

ALTER TABLE ciudades CLUSTER ON "PK_Ciudades";


--
-- TOC entry 2677 (class 2606 OID 25524)
-- Dependencies: 192 192 3263
-- Name: PK_ConUsu; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY conusu
    ADD CONSTRAINT "PK_ConUsu" PRIMARY KEY (id);

ALTER TABLE conusu CLUSTER ON "PK_ConUsu";


--
-- TOC entry 2663 (class 2606 OID 25526)
-- Dependencies: 186 186 3263
-- Name: PK_ConUsuCo; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY conusuco
    ADD CONSTRAINT "PK_ConUsuCo" PRIMARY KEY (id);

ALTER TABLE conusuco CLUSTER ON "PK_ConUsuCo";


--
-- TOC entry 2666 (class 2606 OID 25528)
-- Dependencies: 188 188 3263
-- Name: PK_ConUsuTi; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY conusuti
    ADD CONSTRAINT "PK_ConUsuTi" PRIMARY KEY (id);

ALTER TABLE conusuti CLUSTER ON "PK_ConUsuTi";


--
-- TOC entry 2671 (class 2606 OID 25530)
-- Dependencies: 190 190 3263
-- Name: PK_ConUsuTo; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY conusuto
    ADD CONSTRAINT "PK_ConUsuTo" PRIMARY KEY (id);

ALTER TABLE conusuto CLUSTER ON "PK_ConUsuTo";


--
-- TOC entry 2692 (class 2606 OID 25532)
-- Dependencies: 194 194 3263
-- Name: PK_Contribu; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY contribu
    ADD CONSTRAINT "PK_Contribu" PRIMARY KEY (id);

ALTER TABLE contribu CLUSTER ON "PK_Contribu";


--
-- TOC entry 2847 (class 2606 OID 25534)
-- Dependencies: 240 240 3263
-- Name: PK_ContribuTi; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY contributi
    ADD CONSTRAINT "PK_ContribuTi" PRIMARY KEY (id);

ALTER TABLE contributi CLUSTER ON "PK_ContribuTi";


--
-- TOC entry 2858 (class 2606 OID 25536)
-- Dependencies: 248 248 3263
-- Name: PK_CtaConta; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ctaconta
    ADD CONSTRAINT "PK_CtaConta" PRIMARY KEY (cuenta);

ALTER TABLE ctaconta CLUSTER ON "PK_CtaConta";


--
-- TOC entry 2874 (class 2606 OID 25538)
-- Dependencies: 249 249 3263
-- Name: PK_Decla; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT "PK_Decla" PRIMARY KEY (id);


--
-- TOC entry 2708 (class 2606 OID 25540)
-- Dependencies: 196 196 3263
-- Name: PK_Declara; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY declara_viejo
    ADD CONSTRAINT "PK_Declara" PRIMARY KEY (id);

ALTER TABLE declara_viejo CLUSTER ON "PK_Declara";


--
-- TOC entry 2712 (class 2606 OID 25542)
-- Dependencies: 198 198 3263
-- Name: PK_Departam; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY departam
    ADD CONSTRAINT "PK_Departam" PRIMARY KEY (id);

ALTER TABLE departam CLUSTER ON "PK_Departam";


--
-- TOC entry 2887 (class 2606 OID 25544)
-- Dependencies: 258 258 3263
-- Name: PK_Document; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY document
    ADD CONSTRAINT "PK_Document" PRIMARY KEY (id);

ALTER TABLE document CLUSTER ON "PK_Document";


--
-- TOC entry 2733 (class 2606 OID 25546)
-- Dependencies: 202 202 3263
-- Name: PK_Entidad; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY entidad
    ADD CONSTRAINT "PK_Entidad" PRIMARY KEY (id);

ALTER TABLE entidad CLUSTER ON "PK_Entidad";


--
-- TOC entry 2725 (class 2606 OID 25548)
-- Dependencies: 200 200 3263
-- Name: PK_EntidadD; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY entidadd
    ADD CONSTRAINT "PK_EntidadD" PRIMARY KEY (id);

ALTER TABLE entidadd CLUSTER ON "PK_EntidadD";


--
-- TOC entry 2738 (class 2606 OID 25550)
-- Dependencies: 204 204 3263
-- Name: PK_Estados; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY estados
    ADD CONSTRAINT "PK_Estados" PRIMARY KEY (id);

ALTER TABLE estados CLUSTER ON "PK_Estados";


--
-- TOC entry 2745 (class 2606 OID 25552)
-- Dependencies: 206 206 3263
-- Name: PK_PerUsuD; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY perusud
    ADD CONSTRAINT "PK_PerUsuD" PRIMARY KEY (id);

ALTER TABLE perusud CLUSTER ON "PK_PerUsuD";


--
-- TOC entry 2750 (class 2606 OID 25554)
-- Dependencies: 208 208 3263
-- Name: PK_PerUsu_IDPerUsu; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY perusu
    ADD CONSTRAINT "PK_PerUsu_IDPerUsu" PRIMARY KEY (id);

ALTER TABLE perusu CLUSTER ON "PK_PerUsu_IDPerUsu";


--
-- TOC entry 2755 (class 2606 OID 25556)
-- Dependencies: 210 210 3263
-- Name: PK_PregSecr; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY pregsecr
    ADD CONSTRAINT "PK_PregSecr" PRIMARY KEY (id);

ALTER TABLE pregsecr CLUSTER ON "PK_PregSecr";


--
-- TOC entry 2766 (class 2606 OID 25558)
-- Dependencies: 212 212 3263
-- Name: PK_RepLegal; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY replegal
    ADD CONSTRAINT "PK_RepLegal" PRIMARY KEY (id);

ALTER TABLE replegal CLUSTER ON "PK_RepLegal";


--
-- TOC entry 2771 (class 2606 OID 25560)
-- Dependencies: 214 214 3263
-- Name: PK_TDeclara; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tdeclara
    ADD CONSTRAINT "PK_TDeclara" PRIMARY KEY (id);

ALTER TABLE tdeclara CLUSTER ON "PK_TDeclara";


--
-- TOC entry 2776 (class 2606 OID 25562)
-- Dependencies: 216 216 3263
-- Name: PK_TiPeGrav; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tipegrav
    ADD CONSTRAINT "PK_TiPeGrav" PRIMARY KEY (id);

ALTER TABLE tipegrav CLUSTER ON "PK_TiPeGrav";


--
-- TOC entry 2782 (class 2606 OID 25564)
-- Dependencies: 218 218 3263
-- Name: PK_TipoCont; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tipocont
    ADD CONSTRAINT "PK_TipoCont" PRIMARY KEY (id);

ALTER TABLE tipocont CLUSTER ON "PK_TipoCont";


--
-- TOC entry 2917 (class 2606 OID 25566)
-- Dependencies: 266 266 3263
-- Name: PK_TmpContri; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tmpcontri
    ADD CONSTRAINT "PK_TmpContri" PRIMARY KEY (id);


--
-- TOC entry 2927 (class 2606 OID 25568)
-- Dependencies: 267 267 3263
-- Name: PK_TmpReLegal; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tmprelegal
    ADD CONSTRAINT "PK_TmpReLegal" PRIMARY KEY (id);


--
-- TOC entry 2787 (class 2606 OID 25570)
-- Dependencies: 220 220 3263
-- Name: PK_UndTrib; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY undtrib
    ADD CONSTRAINT "PK_UndTrib" PRIMARY KEY (id);

ALTER TABLE undtrib CLUSTER ON "PK_UndTrib";


--
-- TOC entry 2803 (class 2606 OID 25572)
-- Dependencies: 224 224 3263
-- Name: PK_UsFonPro; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY usfonpro
    ADD CONSTRAINT "PK_UsFonPro" PRIMARY KEY (id);

ALTER TABLE usfonpro CLUSTER ON "PK_UsFonPro";


--
-- TOC entry 2792 (class 2606 OID 25574)
-- Dependencies: 222 222 3263
-- Name: PK_UsFonpTo; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY usfonpto
    ADD CONSTRAINT "PK_UsFonpTo" PRIMARY KEY (id);

ALTER TABLE usfonpto CLUSTER ON "PK_UsFonpTo";


--
-- TOC entry 2841 (class 2606 OID 25576)
-- Dependencies: 238 238 3263
-- Name: PK_contribcalc; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY contrib_calc
    ADD CONSTRAINT "PK_contribcalc" PRIMARY KEY (id);


--
-- TOC entry 2895 (class 2606 OID 25578)
-- Dependencies: 264 264 3263
-- Name: PK_reparos; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY reparos
    ADD CONSTRAINT "PK_reparos" PRIMARY KEY (id);


--
-- TOC entry 2903 (class 2606 OID 25580)
-- Dependencies: 265 265 3263
-- Name: PK_tmpAccioni; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tmpaccioni
    ADD CONSTRAINT "PK_tmpAccioni" PRIMARY KEY (id);


--
-- TOC entry 2837 (class 2606 OID 25582)
-- Dependencies: 234 234 3263
-- Name: fk-asignacion-fiscla; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY asignacion_fiscales
    ADD CONSTRAINT "fk-asignacion-fiscla" PRIMARY KEY (id);


--
-- TOC entry 2679 (class 2606 OID 25584)
-- Dependencies: 192 192 3263
-- Name: login_conusu_unico; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY conusu
    ADD CONSTRAINT login_conusu_unico UNIQUE (login);


--
-- TOC entry 2855 (class 2606 OID 25586)
-- Dependencies: 246 246 3263
-- Name: pk-correlativo-actas; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY correlativos_actas
    ADD CONSTRAINT "pk-correlativo-actas" PRIMARY KEY (id);


--
-- TOC entry 2889 (class 2606 OID 25588)
-- Dependencies: 260 260 3263
-- Name: pk-interesbcv; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY interes_bcv
    ADD CONSTRAINT "pk-interesbcv" PRIMARY KEY (id);


--
-- TOC entry 2814 (class 2606 OID 25590)
-- Dependencies: 227 227 3263
-- Name: pk_actas_reparo_id; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY actas_reparo
    ADD CONSTRAINT pk_actas_reparo_id PRIMARY KEY (id);


--
-- TOC entry 2839 (class 2606 OID 25592)
-- Dependencies: 236 236 3263
-- Name: pk_con_img_doc; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY con_img_doc
    ADD CONSTRAINT pk_con_img_doc PRIMARY KEY (id);


--
-- TOC entry 2849 (class 2606 OID 25594)
-- Dependencies: 242 242 3263
-- Name: pk_conusu_interno; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY conusu_interno
    ADD CONSTRAINT pk_conusu_interno PRIMARY KEY (id);


--
-- TOC entry 2851 (class 2606 OID 25596)
-- Dependencies: 244 244 3263
-- Name: pk_conusu_tipocont; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY conusu_tipocont
    ADD CONSTRAINT pk_conusu_tipocont PRIMARY KEY (id);


--
-- TOC entry 2880 (class 2606 OID 25598)
-- Dependencies: 254 254 3263
-- Name: pk_deta_contirbcalc; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY detalles_contrib_calc
    ADD CONSTRAINT pk_deta_contirbcalc PRIMARY KEY (id);


--
-- TOC entry 2876 (class 2606 OID 25600)
-- Dependencies: 250 250 3263
-- Name: pk_detalle_interes; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY detalle_interes
    ADD CONSTRAINT pk_detalle_interes PRIMARY KEY (id);


--
-- TOC entry 2878 (class 2606 OID 25602)
-- Dependencies: 252 252 3263
-- Name: pk_detalle_interes_n; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY detalle_interes_viejo
    ADD CONSTRAINT pk_detalle_interes_n PRIMARY KEY (id);


--
-- TOC entry 2882 (class 2606 OID 25604)
-- Dependencies: 256 256 3263
-- Name: pk_detalles_fiscalizacion; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY dettalles_fizcalizacion
    ADD CONSTRAINT pk_detalles_fiscalizacion PRIMARY KEY (id);


--
-- TOC entry 2853 (class 2606 OID 25606)
-- Dependencies: 244 244 244 3263
-- Name: uq_tipoconid; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY conusu_tipocont
    ADD CONSTRAINT uq_tipoconid UNIQUE (conusuid, tipocontid);


SET search_path = historial, pg_catalog;

--
-- TOC entry 2934 (class 2606 OID 25608)
-- Dependencies: 269 269 3263
-- Name: PK_Bitacora; Type: CONSTRAINT; Schema: historial; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY bitacora
    ADD CONSTRAINT "PK_Bitacora" PRIMARY KEY (id);

ALTER TABLE bitacora CLUSTER ON "PK_Bitacora";


SET search_path = pre_aprobacion, pg_catalog;

--
-- TOC entry 2936 (class 2606 OID 25610)
-- Dependencies: 271 271 3263
-- Name: PK_datos_cnac; Type: CONSTRAINT; Schema: pre_aprobacion; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY datos_cnac
    ADD CONSTRAINT "PK_datos_cnac" PRIMARY KEY (id);


--
-- TOC entry 2938 (class 2606 OID 25612)
-- Dependencies: 273 273 3263
-- Name: pk-intereses; Type: CONSTRAINT; Schema: pre_aprobacion; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY intereses
    ADD CONSTRAINT "pk-intereses" PRIMARY KEY (id);


--
-- TOC entry 2940 (class 2606 OID 25614)
-- Dependencies: 275 275 3263
-- Name: pk-multa; Type: CONSTRAINT; Schema: pre_aprobacion; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY multas
    ADD CONSTRAINT "pk-multa" PRIMARY KEY (id);


SET search_path = public, pg_catalog;

--
-- TOC entry 2942 (class 2606 OID 25616)
-- Dependencies: 277 277 3263
-- Name: pk_contribucalc; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY contrib_calc
    ADD CONSTRAINT pk_contribucalc PRIMARY KEY (id);


SET search_path = seg, pg_catalog;

--
-- TOC entry 2950 (class 2606 OID 25618)
-- Dependencies: 283 283 3263
-- Name: CT_oficinas_cod_estructura; Type: CONSTRAINT; Schema: seg; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_oficinas
    ADD CONSTRAINT "CT_oficinas_cod_estructura" UNIQUE (cod_estructura);


--
-- TOC entry 2946 (class 2606 OID 25620)
-- Dependencies: 280 280 3263
-- Name: pk_ci_sessions; Type: CONSTRAINT; Schema: seg; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_ci_sessions
    ADD CONSTRAINT pk_ci_sessions PRIMARY KEY (session_id);


--
-- TOC entry 2948 (class 2606 OID 25622)
-- Dependencies: 281 281 3263
-- Name: pk_modulo; Type: CONSTRAINT; Schema: seg; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_modulo
    ADD CONSTRAINT pk_modulo PRIMARY KEY (id_modulo);


--
-- TOC entry 2952 (class 2606 OID 25624)
-- Dependencies: 283 283 3263
-- Name: pk_oficinas; Type: CONSTRAINT; Schema: seg; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_oficinas
    ADD CONSTRAINT pk_oficinas PRIMARY KEY (id);


--
-- TOC entry 2954 (class 2606 OID 25626)
-- Dependencies: 285 285 3263
-- Name: pk_permiso; Type: CONSTRAINT; Schema: seg; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_permiso
    ADD CONSTRAINT pk_permiso PRIMARY KEY (id_permiso);


--
-- TOC entry 2958 (class 2606 OID 25628)
-- Dependencies: 289 289 3263
-- Name: pk_rol; Type: CONSTRAINT; Schema: seg; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_rol
    ADD CONSTRAINT pk_rol PRIMARY KEY (id_rol);


--
-- TOC entry 2960 (class 2606 OID 25630)
-- Dependencies: 291 291 3263
-- Name: pk_rol_usuario; Type: CONSTRAINT; Schema: seg; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_rol_usuario
    ADD CONSTRAINT pk_rol_usuario PRIMARY KEY (id_rol_usuario);


--
-- TOC entry 2944 (class 2606 OID 25632)
-- Dependencies: 278 278 3263
-- Name: pk_tblcargos; Type: CONSTRAINT; Schema: seg; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_cargos
    ADD CONSTRAINT pk_tblcargos PRIMARY KEY (id);


--
-- TOC entry 2964 (class 2606 OID 25634)
-- Dependencies: 294 294 3263
-- Name: pk_usuario_rol; Type: CONSTRAINT; Schema: seg; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_usuario_rol
    ADD CONSTRAINT pk_usuario_rol PRIMARY KEY (id_usuario_rol);


--
-- TOC entry 2956 (class 2606 OID 25636)
-- Dependencies: 287 287 3263
-- Name: pkt_permiso; Type: CONSTRAINT; Schema: seg; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_permiso_trampa
    ADD CONSTRAINT pkt_permiso PRIMARY KEY (id_permiso);


--
-- TOC entry 2962 (class 2606 OID 25638)
-- Dependencies: 293 293 3263
-- Name: tbl_session_ci_pkey; Type: CONSTRAINT; Schema: seg; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_session_ci
    ADD CONSTRAINT tbl_session_ci_pkey PRIMARY KEY (session_id);


SET search_path = "segContribu", pg_catalog;

--
-- TOC entry 2966 (class 2606 OID 25640)
-- Dependencies: 297 297 3263
-- Name: pk_modulo; Type: CONSTRAINT; Schema: segContribu; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_modulo_contribu
    ADD CONSTRAINT pk_modulo PRIMARY KEY (id_modulo);


--
-- TOC entry 2968 (class 2606 OID 25642)
-- Dependencies: 299 299 3263
-- Name: pk_permiso; Type: CONSTRAINT; Schema: segContribu; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_permiso_contribu
    ADD CONSTRAINT pk_permiso PRIMARY KEY (id_permiso);


--
-- TOC entry 2970 (class 2606 OID 25644)
-- Dependencies: 301 301 3263
-- Name: pk_rol; Type: CONSTRAINT; Schema: segContribu; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_rol_contribu
    ADD CONSTRAINT pk_rol PRIMARY KEY (id_rol);


--
-- TOC entry 2972 (class 2606 OID 25646)
-- Dependencies: 303 303 3263
-- Name: pk_rol_usuario; Type: CONSTRAINT; Schema: segContribu; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_rol_usuario_contribu
    ADD CONSTRAINT pk_rol_usuario PRIMARY KEY (id_rol_usuario);


--
-- TOC entry 2974 (class 2606 OID 25648)
-- Dependencies: 305 305 3263
-- Name: pk_usuario_rol; Type: CONSTRAINT; Schema: segContribu; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_usuario_rol_contribu
    ADD CONSTRAINT pk_usuario_rol PRIMARY KEY (id_usuario_rol);


SET search_path = datos, pg_catalog;

--
-- TOC entry 2806 (class 1259 OID 25649)
-- Dependencies: 226 3263
-- Name: FKI_Accionis_IDContribu; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Accionis_IDContribu" ON accionis USING btree (contribuid);


--
-- TOC entry 2807 (class 1259 OID 25650)
-- Dependencies: 226 3263
-- Name: FKI_Accionis_UsFonpro_UsuarioID_ID; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Accionis_UsFonpro_UsuarioID_ID" ON accionis USING btree (usuarioid);


--
-- TOC entry 2605 (class 1259 OID 25651)
-- Dependencies: 167 3263
-- Name: FKI_ActiEcon_USFonpro_IDUsuario_IDUsFornpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_ActiEcon_USFonpro_IDUsuario_IDUsFornpro" ON actiecon USING btree (usuarioid);


--
-- TOC entry 2610 (class 1259 OID 25652)
-- Dependencies: 169 3263
-- Name: FKI_AlicImp_TipoCont_IDTipoCont; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_AlicImp_TipoCont_IDTipoCont" ON alicimp USING btree (tipocontid);


--
-- TOC entry 2611 (class 1259 OID 25653)
-- Dependencies: 169 3263
-- Name: FKI_AlicImp_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_AlicImp_UsFonpro_IDUsuario_IDUsFonpro" ON alicimp USING btree (usuarioid);


--
-- TOC entry 2617 (class 1259 OID 25654)
-- Dependencies: 171 3263
-- Name: FKI_AsientoD_Asiento_IDAsiento; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_AsientoD_Asiento_IDAsiento" ON asientod USING btree (asientoid);


--
-- TOC entry 2618 (class 1259 OID 25655)
-- Dependencies: 171 3263
-- Name: FKI_AsientoD_CtaConta_Cuenta; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_AsientoD_CtaConta_Cuenta" ON asientod USING btree (cuenta);


--
-- TOC entry 2619 (class 1259 OID 25656)
-- Dependencies: 171 3263
-- Name: FKI_AsientoD_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_AsientoD_UsFonpro_IDUsuario_IDUsFonpro" ON asientod USING btree (usuarioid);


--
-- TOC entry 2831 (class 1259 OID 25657)
-- Dependencies: 232 3263
-- Name: FKI_AsientoMD_AsientoM_AsientoMID_ID; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_AsientoMD_AsientoM_AsientoMID_ID" ON asientomd USING btree (asientomid);


--
-- TOC entry 2832 (class 1259 OID 25658)
-- Dependencies: 232 3263
-- Name: FKI_AsientoMD_CtaConta_Cuenta; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_AsientoMD_CtaConta_Cuenta" ON asientomd USING btree (cuenta);


--
-- TOC entry 2833 (class 1259 OID 25659)
-- Dependencies: 232 3263
-- Name: FKI_AsientoMD_UsFonpro_UsuarioID_ID; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_AsientoMD_UsFonpro_UsuarioID_ID" ON asientomd USING btree (usuarioid);


--
-- TOC entry 2828 (class 1259 OID 25660)
-- Dependencies: 230 3263
-- Name: FKI_AsientoM_UsFonpro_UsuarioID_ID; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_AsientoM_UsFonpro_UsuarioID_ID" ON asientom USING btree (usuarioid);


--
-- TOC entry 2817 (class 1259 OID 25661)
-- Dependencies: 229 3263
-- Name: FKI_Asiento_UsFonpro_IDUsCierre_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Asiento_UsFonpro_IDUsCierre_IDUsFonpro" ON asiento USING btree (uscierreid);


--
-- TOC entry 2818 (class 1259 OID 25662)
-- Dependencies: 229 3263
-- Name: FKI_Asiento_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Asiento_UsFonpro_IDUsuario_IDUsFonpro" ON asiento USING btree (usuarioid);


--
-- TOC entry 2625 (class 1259 OID 25663)
-- Dependencies: 174 3263
-- Name: FKI_BaCuenta_Bancos_IDBanco; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_BaCuenta_Bancos_IDBanco" ON bacuenta USING btree (bancoid);


--
-- TOC entry 2626 (class 1259 OID 25664)
-- Dependencies: 174 3263
-- Name: FKI_BaCuenta_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_BaCuenta_UsFonpro_IDUsuario_IDUsFonpro" ON bacuenta USING btree (usuarioid);


--
-- TOC entry 2631 (class 1259 OID 25665)
-- Dependencies: 176 3263
-- Name: FKI_Bancos_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Bancos_UsFonpro_IDUsuario_IDUsFonpro" ON bancos USING btree (usuarioid);


--
-- TOC entry 2634 (class 1259 OID 25666)
-- Dependencies: 178 3263
-- Name: FKI_CalPagoD_CalPago_IDCalPago; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_CalPagoD_CalPago_IDCalPago" ON calpagod USING btree (calpagoid);


--
-- TOC entry 2635 (class 1259 OID 25667)
-- Dependencies: 178 3263
-- Name: FKI_CalPagoD_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_CalPagoD_UsFonpro_IDUsuario_IDUsFonpro" ON calpagod USING btree (usuarioid);


--
-- TOC entry 2642 (class 1259 OID 25668)
-- Dependencies: 180 3263
-- Name: FKI_CalPago_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_CalPago_UsFonpro_IDUsuario_IDUsFonpro" ON calpago USING btree (usuarioid);


--
-- TOC entry 2643 (class 1259 OID 25669)
-- Dependencies: 180 3263
-- Name: FKI_CalPagos_TiPeGrav_IDTiPeGrav; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_CalPagos_TiPeGrav_IDTiPeGrav" ON calpago USING btree (tipegravid);


--
-- TOC entry 2649 (class 1259 OID 25670)
-- Dependencies: 182 3263
-- Name: FKI_Cargos_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Cargos_UsFonpro_IDUsuario_IDUsFonpro" ON cargos USING btree (usuarioid);


--
-- TOC entry 2654 (class 1259 OID 25671)
-- Dependencies: 184 3263
-- Name: FKI_Ciudades_Estados_IDEstado; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Ciudades_Estados_IDEstado" ON ciudades USING btree (estadoid);


--
-- TOC entry 2655 (class 1259 OID 25672)
-- Dependencies: 184 3263
-- Name: FKI_Ciudades_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Ciudades_UsFonpro_IDUsuario_IDUsFonpro" ON ciudades USING btree (usuarioid);


--
-- TOC entry 2660 (class 1259 OID 25673)
-- Dependencies: 186 3263
-- Name: FKI_ConUsuCo_ConUsu_IDConUsu; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_ConUsuCo_ConUsu_IDConUsu" ON conusuco USING btree (conusuid);


--
-- TOC entry 2661 (class 1259 OID 25674)
-- Dependencies: 186 3263
-- Name: FKI_ConUsuCo_Contribu_IDContribu; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_ConUsuCo_Contribu_IDContribu" ON conusuco USING btree (contribuid);


--
-- TOC entry 2664 (class 1259 OID 25675)
-- Dependencies: 188 3263
-- Name: FKI_ConUsuTi_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_ConUsuTi_UsFonpro_IDUsuario_IDUsFonpro" ON conusuti USING btree (usuarioid);


--
-- TOC entry 2669 (class 1259 OID 25676)
-- Dependencies: 190 3263
-- Name: FKI_ConUsuTo_ConUsu_IDConUsu; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_ConUsuTo_ConUsu_IDConUsu" ON conusuto USING btree (conusuid);


--
-- TOC entry 2672 (class 1259 OID 25677)
-- Dependencies: 192 3263
-- Name: FKI_ConUsu_ConUsuTi_IDConUsuTi; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_ConUsu_ConUsuTi_IDConUsuTi" ON conusu USING btree (conusutiid);


--
-- TOC entry 2673 (class 1259 OID 25678)
-- Dependencies: 192 3263
-- Name: FKI_ConUsu_PregSecr_IDPregSecr; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_ConUsu_PregSecr_IDPregSecr" ON conusu USING btree (pregsecrid);


--
-- TOC entry 2674 (class 1259 OID 25679)
-- Dependencies: 192 3263
-- Name: FKI_ConUsu_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_ConUsu_UsFonpro_IDUsuario_IDUsFonpro" ON conusu USING btree (usuarioid);


--
-- TOC entry 2844 (class 1259 OID 25680)
-- Dependencies: 240 3263
-- Name: FKI_ContribuTi_Contribu_ContribuID_ID; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_ContribuTi_Contribu_ContribuID_ID" ON contributi USING btree (contribuid);


--
-- TOC entry 2845 (class 1259 OID 25681)
-- Dependencies: 240 3263
-- Name: FKI_ContribuTi_TipoCont_TipoContID_ID; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_ContribuTi_TipoCont_TipoContID_ID" ON contributi USING btree (tipocontid);


--
-- TOC entry 2686 (class 1259 OID 25682)
-- Dependencies: 194 3263
-- Name: FKI_Contribu_ActiEcon_IDActiEcon; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Contribu_ActiEcon_IDActiEcon" ON contribu USING btree (actieconid);


--
-- TOC entry 2687 (class 1259 OID 25683)
-- Dependencies: 194 3263
-- Name: FKI_Contribu_Ciudades_IDCiudad; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Contribu_Ciudades_IDCiudad" ON contribu USING btree (ciudadid);


--
-- TOC entry 2688 (class 1259 OID 25684)
-- Dependencies: 194 3263
-- Name: FKI_Contribu_ConUsu_UsuarioID_ID; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Contribu_ConUsu_UsuarioID_ID" ON contribu USING btree (usuarioid);


--
-- TOC entry 2689 (class 1259 OID 25685)
-- Dependencies: 194 3263
-- Name: FKI_Contribu_Estados_IDEstado; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Contribu_Estados_IDEstado" ON contribu USING btree (estadoid);


--
-- TOC entry 2856 (class 1259 OID 25686)
-- Dependencies: 248 3263
-- Name: FKI_CtaConta_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_CtaConta_UsFonpro_IDUsuario_IDUsFonpro" ON ctaconta USING btree (usuarioid);


--
-- TOC entry 2863 (class 1259 OID 25687)
-- Dependencies: 249 3263
-- Name: FKI_Decla_Asiento_IDAsiento; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Decla_Asiento_IDAsiento" ON declara USING btree (asientoid);


--
-- TOC entry 2864 (class 1259 OID 25688)
-- Dependencies: 249 3263
-- Name: FKI_Decla_PlaSustID_ID; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Decla_PlaSustID_ID" ON declara USING btree (plasustid);


--
-- TOC entry 2865 (class 1259 OID 25689)
-- Dependencies: 249 3263
-- Name: FKI_Decla_RepLegal_IDRepLegal; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Decla_RepLegal_IDRepLegal" ON declara USING btree (replegalid);


--
-- TOC entry 2866 (class 1259 OID 25690)
-- Dependencies: 249 3263
-- Name: FKI_Decla_TDeclara_IDTDeclara; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Decla_TDeclara_IDTDeclara" ON declara USING btree (tdeclaraid);


--
-- TOC entry 2867 (class 1259 OID 25691)
-- Dependencies: 249 3263
-- Name: FKI_Decla_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Decla_UsFonpro_IDUsuario_IDUsFonpro" ON declara USING btree (usuarioid);


--
-- TOC entry 2697 (class 1259 OID 25692)
-- Dependencies: 196 3263
-- Name: FKI_Declara_Asiento_IDAsiento; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Declara_Asiento_IDAsiento" ON declara_viejo USING btree (asientoid);


--
-- TOC entry 2698 (class 1259 OID 25693)
-- Dependencies: 196 3263
-- Name: FKI_Declara_PlaSustID_ID; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Declara_PlaSustID_ID" ON declara_viejo USING btree (plasustid);


--
-- TOC entry 2699 (class 1259 OID 25694)
-- Dependencies: 196 3263
-- Name: FKI_Declara_RepLegal_IDRepLegal; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Declara_RepLegal_IDRepLegal" ON declara_viejo USING btree (replegalid);


--
-- TOC entry 2700 (class 1259 OID 25695)
-- Dependencies: 196 3263
-- Name: FKI_Declara_TDeclara_IDTDeclara; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Declara_TDeclara_IDTDeclara" ON declara_viejo USING btree (tdeclaraid);


--
-- TOC entry 2701 (class 1259 OID 25696)
-- Dependencies: 196 3263
-- Name: FKI_Declara_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Declara_UsFonpro_IDUsuario_IDUsFonpro" ON declara_viejo USING btree (usuarioid);


--
-- TOC entry 2885 (class 1259 OID 25697)
-- Dependencies: 258 3263
-- Name: FKI_Document_UsFonpro_UsFonproID_ID; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Document_UsFonpro_UsFonproID_ID" ON document USING btree (usfonproid);


--
-- TOC entry 2720 (class 1259 OID 25698)
-- Dependencies: 200 3263
-- Name: FKI_EntidadD_Entidad_IDEntidad; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_EntidadD_Entidad_IDEntidad" ON entidadd USING btree (entidadid);


--
-- TOC entry 2736 (class 1259 OID 25699)
-- Dependencies: 204 3263
-- Name: FKI_Estados_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Estados_UsFonpro_IDUsuario_IDUsFonpro" ON estados USING btree (usuarioid);


--
-- TOC entry 2741 (class 1259 OID 25700)
-- Dependencies: 206 3263
-- Name: FKI_PerUsuD_EndidadD_IDEntidadD; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_PerUsuD_EndidadD_IDEntidadD" ON perusud USING btree (entidaddid);


--
-- TOC entry 2742 (class 1259 OID 25701)
-- Dependencies: 206 3263
-- Name: FKI_PerUsuD_PerUsu_IDPerUsu; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_PerUsuD_PerUsu_IDPerUsu" ON perusud USING btree (perusuid);


--
-- TOC entry 2743 (class 1259 OID 25702)
-- Dependencies: 206 3263
-- Name: FKI_PerUsuD_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_PerUsuD_UsFonpro_IDUsuario_IDUsFonpro" ON perusud USING btree (usuarioid);


--
-- TOC entry 2748 (class 1259 OID 25703)
-- Dependencies: 208 3263
-- Name: FKI_PerUsu_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_PerUsu_UsFonpro_IDUsuario_IDUsFonpro" ON perusu USING btree (usuarioid);


--
-- TOC entry 2753 (class 1259 OID 25704)
-- Dependencies: 210 3263
-- Name: FKI_PregSecr_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_PregSecr_UsFonpro_IDUsuario_IDUsFonpro" ON pregsecr USING btree (usuarioid);


--
-- TOC entry 2758 (class 1259 OID 25705)
-- Dependencies: 212 3263
-- Name: FKI_RepLegal_IDCiudad; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_RepLegal_IDCiudad" ON replegal USING btree (ciudadid);


--
-- TOC entry 2759 (class 1259 OID 25706)
-- Dependencies: 212 3263
-- Name: FKI_RepLegal_IDContribu; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_RepLegal_IDContribu" ON replegal USING btree (contribuid);


--
-- TOC entry 2760 (class 1259 OID 25707)
-- Dependencies: 212 3263
-- Name: FKI_RepLegal_IDEstado; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_RepLegal_IDEstado" ON replegal USING btree (estadoid);


--
-- TOC entry 2761 (class 1259 OID 25708)
-- Dependencies: 212 3263
-- Name: FKI_RepLegal_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_RepLegal_UsFonpro_IDUsuario_IDUsFonpro" ON replegal USING btree (usuarioid);


--
-- TOC entry 2769 (class 1259 OID 25709)
-- Dependencies: 214 3263
-- Name: FKI_TDeclara_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TDeclara_UsFonpro_IDUsuario_IDUsFonpro" ON tdeclara USING btree (usuarioid);


--
-- TOC entry 2774 (class 1259 OID 25710)
-- Dependencies: 216 3263
-- Name: FKI_TiPeGrav_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TiPeGrav_UsFonpro_IDUsuario_IDUsFonpro" ON tipegrav USING btree (usuarioid);


--
-- TOC entry 2779 (class 1259 OID 25711)
-- Dependencies: 218 3263
-- Name: FKI_TipoCont_TiPeGrav_IDTiPeGrav; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TipoCont_TiPeGrav_IDTiPeGrav" ON tipocont USING btree (tipegravid);


--
-- TOC entry 2780 (class 1259 OID 25712)
-- Dependencies: 218 3263
-- Name: FKI_TipoCont_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TipoCont_UsFonpro_IDUsuario_IDUsFonpro" ON tipocont USING btree (usuarioid);


--
-- TOC entry 2910 (class 1259 OID 25713)
-- Dependencies: 266 3263
-- Name: FKI_TmpContri_ActiEcon_IDActiEcon; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TmpContri_ActiEcon_IDActiEcon" ON tmpcontri USING btree (actieconid);


--
-- TOC entry 2911 (class 1259 OID 25714)
-- Dependencies: 266 3263
-- Name: FKI_TmpContri_Ciudades_IDCiudad; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TmpContri_Ciudades_IDCiudad" ON tmpcontri USING btree (ciudadid);


--
-- TOC entry 2912 (class 1259 OID 25715)
-- Dependencies: 266 3263
-- Name: FKI_TmpContri_Contribu_IDContribu; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TmpContri_Contribu_IDContribu" ON tmpcontri USING btree (id);


--
-- TOC entry 2913 (class 1259 OID 25716)
-- Dependencies: 266 3263
-- Name: FKI_TmpContri_Estados_IDEstado; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TmpContri_Estados_IDEstado" ON tmpcontri USING btree (estadoid);


--
-- TOC entry 2914 (class 1259 OID 25717)
-- Dependencies: 266 3263
-- Name: FKI_TmpContri_TipoCont_IDTipoCont; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TmpContri_TipoCont_IDTipoCont" ON tmpcontri USING btree (tipocontid);


--
-- TOC entry 2920 (class 1259 OID 25718)
-- Dependencies: 267 3263
-- Name: FKI_TmpReLegal_IDCiudad; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TmpReLegal_IDCiudad" ON tmprelegal USING btree (ciudadid);


--
-- TOC entry 2921 (class 1259 OID 25719)
-- Dependencies: 267 3263
-- Name: FKI_TmpReLegal_IDContribu; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TmpReLegal_IDContribu" ON tmprelegal USING btree (contribuid);


--
-- TOC entry 2922 (class 1259 OID 25720)
-- Dependencies: 267 3263
-- Name: FKI_TmpReLegal_IDEstado; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TmpReLegal_IDEstado" ON tmprelegal USING btree (estadoid);


--
-- TOC entry 2785 (class 1259 OID 25721)
-- Dependencies: 220 3263
-- Name: FKI_UndTrib_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_UndTrib_UsFonpro_IDUsuario_IDUsFonpro" ON undtrib USING btree (usuarioid);


--
-- TOC entry 2797 (class 1259 OID 25722)
-- Dependencies: 224 3263
-- Name: FKI_UsFonPro_PregSecr_IDPregSecr; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_UsFonPro_PregSecr_IDPregSecr" ON usfonpro USING btree (pregsecrid);


--
-- TOC entry 2790 (class 1259 OID 25723)
-- Dependencies: 222 3263
-- Name: FKI_UsFonpTo_UsFonpro_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_UsFonpTo_UsFonpro_IDUsFonpro" ON usfonpto USING btree (usfonproid);


--
-- TOC entry 2798 (class 1259 OID 25724)
-- Dependencies: 224 3263
-- Name: FKI_UsFonpro_Cargos_IDCargo; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_UsFonpro_Cargos_IDCargo" ON usfonpro USING btree (cargoid);


--
-- TOC entry 2799 (class 1259 OID 25725)
-- Dependencies: 224 3263
-- Name: FKI_UsFonpro_Departam_IDDepartam; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_UsFonpro_Departam_IDDepartam" ON usfonpro USING btree (departamid);


--
-- TOC entry 2800 (class 1259 OID 25726)
-- Dependencies: 224 3263
-- Name: FKI_UsFonpro_PerUsu_IDPerUsu; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_UsFonpro_PerUsu_IDPerUsu" ON usfonpro USING btree (perusuid);


--
-- TOC entry 2890 (class 1259 OID 25727)
-- Dependencies: 264 3263
-- Name: FKI_reparos_Asiento_IDAsiento; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_reparos_Asiento_IDAsiento" ON reparos USING btree (asientoid);


--
-- TOC entry 2891 (class 1259 OID 25728)
-- Dependencies: 264 3263
-- Name: FKI_reparos_TDeclara_IDTDeclara; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_reparos_TDeclara_IDTDeclara" ON reparos USING btree (tdeclaraid);


--
-- TOC entry 2892 (class 1259 OID 25729)
-- Dependencies: 264 3263
-- Name: FKI_reparos_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_reparos_UsFonpro_IDUsuario_IDUsFonpro" ON reparos USING btree (usuarioid);


--
-- TOC entry 2898 (class 1259 OID 25730)
-- Dependencies: 265 3263
-- Name: FKI_tmpAccioni_IDContribu; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_tmpAccioni_IDContribu" ON tmpaccioni USING btree (contribuid);


--
-- TOC entry 2808 (class 1259 OID 25731)
-- Dependencies: 226 3263
-- Name: IX_Accionis_Apellido; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Accionis_Apellido" ON accionis USING btree (apellido);


--
-- TOC entry 2809 (class 1259 OID 25732)
-- Dependencies: 226 3263
-- Name: IX_Accionis_Ci; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Accionis_Ci" ON accionis USING btree (ci);


--
-- TOC entry 2810 (class 1259 OID 25733)
-- Dependencies: 226 3263
-- Name: IX_Accionis_Nombre; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Accionis_Nombre" ON accionis USING btree (nombre);


--
-- TOC entry 2612 (class 1259 OID 25734)
-- Dependencies: 169 3263
-- Name: IX_AlicImp_Ano; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_AlicImp_Ano" ON alicimp USING btree (ano);


--
-- TOC entry 2620 (class 1259 OID 25735)
-- Dependencies: 171 3263
-- Name: IX_AsientoD_Fecha; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_AsientoD_Fecha" ON asientod USING btree (fecha);


--
-- TOC entry 2819 (class 1259 OID 25736)
-- Dependencies: 229 3263
-- Name: IX_Asiento_Ano; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Asiento_Ano" ON asiento USING btree (ano);


--
-- TOC entry 2820 (class 1259 OID 25737)
-- Dependencies: 229 3263
-- Name: IX_Asiento_Cerrado; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Asiento_Cerrado" ON asiento USING btree (cerrado);


--
-- TOC entry 2821 (class 1259 OID 25738)
-- Dependencies: 229 3263
-- Name: IX_Asiento_Fecha; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Asiento_Fecha" ON asiento USING btree (fecha);


--
-- TOC entry 2822 (class 1259 OID 25739)
-- Dependencies: 229 3263
-- Name: IX_Asiento_Mes; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Asiento_Mes" ON asiento USING btree (mes);


--
-- TOC entry 2823 (class 1259 OID 25740)
-- Dependencies: 229 3263
-- Name: IX_Asiento_NuAsiento; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Asiento_NuAsiento" ON asiento USING btree (nuasiento);


--
-- TOC entry 2644 (class 1259 OID 25741)
-- Dependencies: 180 3263
-- Name: IX_CalPagos_Ano; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_CalPagos_Ano" ON calpago USING btree (ano);


--
-- TOC entry 2675 (class 1259 OID 25742)
-- Dependencies: 192 3263
-- Name: IX_ConUsu_Password; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_ConUsu_Password" ON conusu USING btree (password);


--
-- TOC entry 2690 (class 1259 OID 25743)
-- Dependencies: 194 3263
-- Name: IX_Contribu_DenComerci; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Contribu_DenComerci" ON contribu USING btree (dencomerci);


--
-- TOC entry 2868 (class 1259 OID 25744)
-- Dependencies: 249 3263
-- Name: IX_Decla_FechaConci; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Decla_FechaConci" ON declara USING btree (fechaconci);


--
-- TOC entry 2869 (class 1259 OID 25745)
-- Dependencies: 249 3263
-- Name: IX_Decla_FechaElab; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Decla_FechaElab" ON declara USING btree (fechaelab);


--
-- TOC entry 2870 (class 1259 OID 25746)
-- Dependencies: 249 3263
-- Name: IX_Decla_FechaFin; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Decla_FechaFin" ON declara USING btree (fechafin);


--
-- TOC entry 2871 (class 1259 OID 25747)
-- Dependencies: 249 3263
-- Name: IX_Decla_FechaIni; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Decla_FechaIni" ON declara USING btree (fechaini);


--
-- TOC entry 2872 (class 1259 OID 25748)
-- Dependencies: 249 3263
-- Name: IX_Decla_FechaPago; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Decla_FechaPago" ON declara USING btree (fechapago);


--
-- TOC entry 2702 (class 1259 OID 25749)
-- Dependencies: 196 3263
-- Name: IX_Declara_FechaConci; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Declara_FechaConci" ON declara_viejo USING btree (fechaconci);


--
-- TOC entry 2703 (class 1259 OID 25750)
-- Dependencies: 196 3263
-- Name: IX_Declara_FechaElab; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Declara_FechaElab" ON declara_viejo USING btree (fechaelab);


--
-- TOC entry 2704 (class 1259 OID 25751)
-- Dependencies: 196 3263
-- Name: IX_Declara_FechaFin; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Declara_FechaFin" ON declara_viejo USING btree (fechafin);


--
-- TOC entry 2705 (class 1259 OID 25752)
-- Dependencies: 196 3263
-- Name: IX_Declara_FechaIni; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Declara_FechaIni" ON declara_viejo USING btree (fechaini);


--
-- TOC entry 2706 (class 1259 OID 25753)
-- Dependencies: 196 3263
-- Name: IX_Declara_FechaPago; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Declara_FechaPago" ON declara_viejo USING btree (fechapago);


--
-- TOC entry 2721 (class 1259 OID 25754)
-- Dependencies: 200 3263
-- Name: IX_EntidadD_Accion; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_EntidadD_Accion" ON entidadd USING btree (accion);


--
-- TOC entry 2722 (class 1259 OID 25755)
-- Dependencies: 200 3263
-- Name: IX_EntidadD_Nombre; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_EntidadD_Nombre" ON entidadd USING btree (nombre);


--
-- TOC entry 2723 (class 1259 OID 25756)
-- Dependencies: 200 3263
-- Name: IX_EntidadD_Orden; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_EntidadD_Orden" ON entidadd USING btree (orden);


--
-- TOC entry 2762 (class 1259 OID 25757)
-- Dependencies: 212 3263
-- Name: IX_RepLegal_Apellido; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_RepLegal_Apellido" ON replegal USING btree (apellido);


--
-- TOC entry 2763 (class 1259 OID 25758)
-- Dependencies: 212 3263
-- Name: IX_RepLegal_Ci; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_RepLegal_Ci" ON replegal USING btree (ci);


--
-- TOC entry 2764 (class 1259 OID 25759)
-- Dependencies: 212 3263
-- Name: IX_RepLegal_Nombre; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_RepLegal_Nombre" ON replegal USING btree (nombre);


--
-- TOC entry 2915 (class 1259 OID 25760)
-- Dependencies: 266 3263
-- Name: IX_TmpContri_DenComerci; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_TmpContri_DenComerci" ON tmpcontri USING btree (dencomerci);


--
-- TOC entry 2923 (class 1259 OID 25761)
-- Dependencies: 267 3263
-- Name: IX_TmpReLegalNombre; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_TmpReLegalNombre" ON tmprelegal USING btree (nombre);


--
-- TOC entry 2924 (class 1259 OID 25762)
-- Dependencies: 267 3263
-- Name: IX_TmpReLegal_Apellido; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_TmpReLegal_Apellido" ON tmprelegal USING btree (apellido);


--
-- TOC entry 2925 (class 1259 OID 25763)
-- Dependencies: 267 3263
-- Name: IX_TmpReLegal_Ci; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_TmpReLegal_Ci" ON tmprelegal USING btree (ci);


--
-- TOC entry 2801 (class 1259 OID 25764)
-- Dependencies: 224 3263
-- Name: IX_UsFonPro_Password; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_UsFonPro_Password" ON usfonpro USING btree (password);


--
-- TOC entry 2893 (class 1259 OID 25765)
-- Dependencies: 264 3263
-- Name: IX_reparos_FechaElab; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_reparos_FechaElab" ON reparos USING btree (fechaelab);


--
-- TOC entry 2899 (class 1259 OID 25766)
-- Dependencies: 265 3263
-- Name: IX_tmpAccioni_Apellido; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_tmpAccioni_Apellido" ON tmpaccioni USING btree (apellido);


--
-- TOC entry 2900 (class 1259 OID 25767)
-- Dependencies: 265 3263
-- Name: IX_tmpAccioni_Ci; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_tmpAccioni_Ci" ON tmpaccioni USING btree (ci);


--
-- TOC entry 2901 (class 1259 OID 25768)
-- Dependencies: 265 3263
-- Name: IX_tmpAccioni_Nombre; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_tmpAccioni_Nombre" ON tmpaccioni USING btree (nombre);


--
-- TOC entry 2713 (class 1259 OID 25769)
-- Dependencies: 198 3263
-- Name: fki_FL_Departam_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "fki_FL_Departam_UsFonpro_IDUsuario_IDUsFonpro" ON departam USING btree (usuarioid);


SET search_path = historial, pg_catalog;

--
-- TOC entry 2928 (class 1259 OID 25771)
-- Dependencies: 269 3263
-- Name: IX_Accion; Type: INDEX; Schema: historial; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Accion" ON bitacora USING btree (accion);


--
-- TOC entry 2929 (class 1259 OID 25772)
-- Dependencies: 269 3263
-- Name: IX_Fecha; Type: INDEX; Schema: historial; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Fecha" ON bitacora USING btree (fecha);


--
-- TOC entry 2930 (class 1259 OID 25773)
-- Dependencies: 269 3263
-- Name: IX_IDUsuario; Type: INDEX; Schema: historial; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_IDUsuario" ON bitacora USING btree (idusuario);


--
-- TOC entry 2931 (class 1259 OID 25775)
-- Dependencies: 269 3263
-- Name: IX_Tabla; Type: INDEX; Schema: historial; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Tabla" ON bitacora USING btree (tabla);


--
-- TOC entry 2932 (class 1259 OID 25776)
-- Dependencies: 269 3263
-- Name: IX_ValDelID; Type: INDEX; Schema: historial; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_ValDelID" ON bitacora USING btree (valdelid);


SET search_path = datos, pg_catalog;

--
-- TOC entry 2421 (class 2618 OID 25778)
-- Dependencies: 285 224 224 224 224 281 281 281 281 281 285 2803 291 291 289 289 291 289 285 285 268 3263
-- Name: _RETURN; Type: RULE; Schema: datos; Owner: postgres
--

CREATE RULE "_RETURN" AS ON SELECT TO view_modulo_usuario_contribuyente_permiso DO INSTEAD SELECT usu.id, usu.nombre, rol.str_rol, per.id_modulo, mod.str_nombre, mod.str_enlace, max(per.int_permiso) AS int_permiso, CASE WHEN (mod.id_padre IS NULL) THEN (mod.id_modulo * 10) ELSE ((mod.id_padre * 10) + mod.id_modulo) END AS int_orden, CASE WHEN (mod.id_padre IS NULL) THEN (0)::bigint ELSE mod.id_padre END AS id_padre FROM ((((usfonpro usu JOIN seg.tbl_rol_usuario rus ON ((usu.id = rus.id_usuario))) JOIN seg.tbl_rol rol ON ((rus.id_rol = rol.id_rol))) JOIN seg.tbl_permiso per ON ((rol.id_rol = per.id_rol))) JOIN seg.tbl_modulo mod ON ((per.id_modulo = mod.id_modulo))) WHERE (((((NOT usu.inactivo) AND (NOT rus.bln_borrado)) AND (NOT rol.bln_borrado)) AND (NOT per.bln_borrado)) AND (NOT mod.bln_borrado)) GROUP BY usu.id, usu.login, rol.str_rol, per.id_modulo, mod.str_nombre, mod.str_enlace, mod.id_padre, mod.id_modulo;


SET search_path = seg, pg_catalog;

--
-- TOC entry 2422 (class 2618 OID 25780)
-- Dependencies: 291 2803 291 291 289 289 289 285 285 285 285 281 281 281 281 281 224 224 224 224 296 3263
-- Name: _RETURN; Type: RULE; Schema: seg; Owner: postgres
--

CREATE RULE "_RETURN" AS ON SELECT TO view_modulo_usuario_permiso DO INSTEAD SELECT usu.id, usu.nombre, rol.str_rol, per.id_modulo, mod.str_nombre, mod.str_enlace, max(per.int_permiso) AS int_permiso, CASE WHEN (mod.id_padre IS NULL) THEN (mod.id_modulo * 10) ELSE ((mod.id_padre * 10) + mod.id_modulo) END AS int_orden, CASE WHEN (mod.id_padre IS NULL) THEN (0)::bigint ELSE mod.id_padre END AS id_padre FROM ((((datos.usfonpro usu JOIN tbl_rol_usuario rus ON ((usu.id = rus.id_usuario))) JOIN tbl_rol rol ON ((rus.id_rol = rol.id_rol))) JOIN tbl_permiso per ON ((rol.id_rol = per.id_rol))) JOIN tbl_modulo mod ON ((per.id_modulo = mod.id_modulo))) WHERE (((((NOT usu.inactivo) AND (NOT rus.bln_borrado)) AND (NOT rol.bln_borrado)) AND (NOT per.bln_borrado)) AND (NOT mod.bln_borrado)) GROUP BY usu.id, usu.login, rol.str_rol, per.id_modulo, mod.str_nombre, mod.str_enlace, mod.id_padre, mod.id_modulo;


SET search_path = "segContribu", pg_catalog;

--
-- TOC entry 2423 (class 2618 OID 25783)
-- Dependencies: 297 303 192 303 301 301 192 297 301 299 299 297 297 299 299 297 2677 192 303 307 3263
-- Name: _RETURN; Type: RULE; Schema: segContribu; Owner: postgres
--

CREATE RULE "_RETURN" AS ON SELECT TO view_modulo_usuariocontribuyente_permiso DO INSTEAD SELECT usu.id, usu.nombre, rol.str_rol, per.id_modulo, mod.str_nombre, mod.str_enlace, max(per.int_permiso) AS int_permiso, CASE WHEN (mod.id_padre IS NULL) THEN (mod.id_modulo * 10) ELSE ((mod.id_padre * 10) + mod.id_modulo) END AS int_orden, CASE WHEN (mod.id_padre IS NULL) THEN (0)::bigint ELSE mod.id_padre END AS id_padre FROM ((((datos.conusu usu JOIN tbl_rol_usuario_contribu rus ON ((usu.id = rus.id_usuario))) JOIN tbl_rol_contribu rol ON ((rus.id_rol = rol.id_rol))) JOIN tbl_permiso_contribu per ON ((rol.id_rol = per.id_rol))) JOIN tbl_modulo_contribu mod ON ((per.id_modulo = mod.id_modulo))) WHERE ((((NOT rus.bln_borrado) AND (NOT rol.bln_borrado)) AND (NOT per.bln_borrado)) AND (NOT mod.bln_borrado)) GROUP BY usu.id, usu.login, rol.str_rol, per.id_modulo, mod.str_nombre, mod.str_enlace, mod.id_padre, mod.id_modulo;


SET search_path = datos, pg_catalog;

--
-- TOC entry 3116 (class 2620 OID 25785)
-- Dependencies: 229 229 229 329 3263
-- Name: TG_Asiendo_ActualizaSaldo; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_Asiendo_ActualizaSaldo" BEFORE UPDATE OF debe, haber ON asiento FOR EACH ROW EXECUTE PROCEDURE "tf_Asiento_ActualizaSaldo"();


--
-- TOC entry 3930 (class 0 OID 0)
-- Dependencies: 3116
-- Name: TRIGGER "TG_Asiendo_ActualizaSaldo" ON asiento; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_Asiendo_ActualizaSaldo" ON asiento IS 'Trigger que actualiza el saldo del asiento';


--
-- TOC entry 3092 (class 2620 OID 25788)
-- Dependencies: 328 171 3263
-- Name: TG_AsientoD_ActualizaDebeHaber_Asiento; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_AsientoD_ActualizaDebeHaber_Asiento" AFTER INSERT OR DELETE OR UPDATE ON asientod FOR EACH ROW EXECUTE PROCEDURE "tf_AsiendoD_ActualizaDebeHaber_Asiento"();


--
-- TOC entry 3931 (class 0 OID 0)
-- Dependencies: 3092
-- Name: TRIGGER "TG_AsientoD_ActualizaDebeHaber_Asiento" ON asientod; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_AsientoD_ActualizaDebeHaber_Asiento" ON asientod IS 'Trigger que actualiza el debe y haber de la tabla de asiento';


--
-- TOC entry 3093 (class 2620 OID 25789)
-- Dependencies: 171 330 3263
-- Name: TG_AsientoD_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_AsientoD_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON asientod FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();


--
-- TOC entry 3932 (class 0 OID 0)
-- Dependencies: 3093
-- Name: TRIGGER "TG_AsientoD_Bitacora" ON asientod; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_AsientoD_Bitacora" ON asientod IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3119 (class 2620 OID 25790)
-- Dependencies: 230 330 3263
-- Name: TG_AsientoM_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_AsientoM_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON asientom FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();


--
-- TOC entry 3933 (class 0 OID 0)
-- Dependencies: 3119
-- Name: TRIGGER "TG_AsientoM_Bitacora" ON asientom; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_AsientoM_Bitacora" ON asientom IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3117 (class 2620 OID 25791)
-- Dependencies: 229 320 229 3263
-- Name: TG_Asiento_Actualiza_Mes_Ano; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_Asiento_Actualiza_Mes_Ano" BEFORE INSERT OR UPDATE OF fecha ON asiento FOR EACH ROW EXECUTE PROCEDURE "tf_Asiento_ActualizaPeriodo"();


--
-- TOC entry 3118 (class 2620 OID 25792)
-- Dependencies: 330 229 3263
-- Name: TG_Asiento_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_Asiento_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON asiento FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();


--
-- TOC entry 3934 (class 0 OID 0)
-- Dependencies: 3118
-- Name: TRIGGER "TG_Asiento_Bitacora" ON asiento; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_Asiento_Bitacora" ON asiento IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3094 (class 2620 OID 25794)
-- Dependencies: 330 174 3263
-- Name: TG_BaCuenta_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_BaCuenta_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON bacuenta FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();


--
-- TOC entry 3935 (class 0 OID 0)
-- Dependencies: 3094
-- Name: TRIGGER "TG_BaCuenta_Bitacora" ON bacuenta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_BaCuenta_Bitacora" ON bacuenta IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3095 (class 2620 OID 25795)
-- Dependencies: 330 176 3263
-- Name: TG_Bancos_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_Bancos_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON bancos FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();


--
-- TOC entry 3936 (class 0 OID 0)
-- Dependencies: 3095
-- Name: TRIGGER "TG_Bancos_Bitacora" ON bancos; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_Bancos_Bitacora" ON bancos IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3098 (class 2620 OID 25796)
-- Dependencies: 330 182 3263
-- Name: TG_Cargos_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_Cargos_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON cargos FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE cargos DISABLE TRIGGER "TG_Cargos_Bitacora";


--
-- TOC entry 3937 (class 0 OID 0)
-- Dependencies: 3098
-- Name: TRIGGER "TG_Cargos_Bitacora" ON cargos; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_Cargos_Bitacora" ON cargos IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3101 (class 2620 OID 25797)
-- Dependencies: 192 330 3263
-- Name: TG_ConUsu_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_ConUsu_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON conusu FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE conusu DISABLE TRIGGER "TG_ConUsu_Bitacora";


--
-- TOC entry 3938 (class 0 OID 0)
-- Dependencies: 3101
-- Name: TRIGGER "TG_ConUsu_Bitacora" ON conusu; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_ConUsu_Bitacora" ON conusu IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3121 (class 2620 OID 25798)
-- Dependencies: 248 330 3263
-- Name: TG_CtaConta_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_CtaConta_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON ctaconta FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();


--
-- TOC entry 3939 (class 0 OID 0)
-- Dependencies: 3121
-- Name: TRIGGER "TG_CtaConta_Bitacora" ON ctaconta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_CtaConta_Bitacora" ON ctaconta IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3103 (class 2620 OID 25799)
-- Dependencies: 330 198 3263
-- Name: TG_Departam_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_Departam_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON departam FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE departam DISABLE TRIGGER "TG_Departam_Bitacora";


--
-- TOC entry 3940 (class 0 OID 0)
-- Dependencies: 3103
-- Name: TRIGGER "TG_Departam_Bitacora" ON departam; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_Departam_Bitacora" ON departam IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3105 (class 2620 OID 25800)
-- Dependencies: 206 330 3263
-- Name: TG_PerUsuD_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_PerUsuD_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON perusud FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();


--
-- TOC entry 3941 (class 0 OID 0)
-- Dependencies: 3105
-- Name: TRIGGER "TG_PerUsuD_Bitacora" ON perusud; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_PerUsuD_Bitacora" ON perusud IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3106 (class 2620 OID 25801)
-- Dependencies: 330 208 3263
-- Name: TG_PerUsu_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_PerUsu_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON perusu FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();


--
-- TOC entry 3942 (class 0 OID 0)
-- Dependencies: 3106
-- Name: TRIGGER "TG_PerUsu_Bitacora" ON perusu; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_PerUsu_Bitacora" ON perusu IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3107 (class 2620 OID 25802)
-- Dependencies: 210 330 3263
-- Name: TG_PregSecr_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_PregSecr_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON pregsecr FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE pregsecr DISABLE TRIGGER "TG_PregSecr_Bitacora";


--
-- TOC entry 3943 (class 0 OID 0)
-- Dependencies: 3107
-- Name: TRIGGER "TG_PregSecr_Bitacora" ON pregsecr; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_PregSecr_Bitacora" ON pregsecr IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3109 (class 2620 OID 25803)
-- Dependencies: 214 330 3263
-- Name: TG_TDeclara_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_TDeclara_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON tdeclara FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE tdeclara DISABLE TRIGGER "TG_TDeclara_Bitacora";


--
-- TOC entry 3944 (class 0 OID 0)
-- Dependencies: 3109
-- Name: TRIGGER "TG_TDeclara_Bitacora" ON tdeclara; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_TDeclara_Bitacora" ON tdeclara IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3112 (class 2620 OID 25804)
-- Dependencies: 220 330 3263
-- Name: TG_UndTrib_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_UndTrib_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON undtrib FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE undtrib DISABLE TRIGGER "TG_UndTrib_Bitacora";


--
-- TOC entry 3945 (class 0 OID 0)
-- Dependencies: 3112
-- Name: TRIGGER "TG_UndTrib_Bitacora" ON undtrib; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_UndTrib_Bitacora" ON undtrib IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3113 (class 2620 OID 25805)
-- Dependencies: 224 224 224 224 224 224 224 224 330 224 224 224 224 224 3263
-- Name: TG_UsFonpro_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_UsFonpro_Bitacora" AFTER INSERT OR DELETE OR UPDATE OF id, login, password, nombre, email, telefofc, extension, departamid, cargoid, inactivo, pregsecrid, respuesta ON usfonpro FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE usfonpro DISABLE TRIGGER "TG_UsFonpro_Bitacora";


--
-- TOC entry 3946 (class 0 OID 0)
-- Dependencies: 3113
-- Name: TRIGGER "TG_UsFonpro_Bitacora" ON usfonpro; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_UsFonpro_Bitacora" ON usfonpro IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3115 (class 2620 OID 25806)
-- Dependencies: 321 227 3263
-- Name: ejecuta_crea_correlativo_actar; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER ejecuta_crea_correlativo_actar AFTER INSERT ON actas_reparo FOR EACH ROW EXECUTE PROCEDURE crea_correlativo_actas();


--
-- TOC entry 3120 (class 2620 OID 25807)
-- Dependencies: 321 234 3263
-- Name: ejecuta_crea_correlativo_actas; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER ejecuta_crea_correlativo_actas AFTER INSERT ON asignacion_fiscales FOR EACH ROW EXECUTE PROCEDURE crea_correlativo_actas();


--
-- TOC entry 3114 (class 2620 OID 25808)
-- Dependencies: 330 226 3263
-- Name: tg_Accionis_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_Accionis_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON accionis FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE accionis DISABLE TRIGGER "tg_Accionis_Bitacora";


--
-- TOC entry 3947 (class 0 OID 0)
-- Dependencies: 3114
-- Name: TRIGGER "tg_Accionis_Bitacora" ON accionis; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_Accionis_Bitacora" ON accionis IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3090 (class 2620 OID 25809)
-- Dependencies: 167 330 3263
-- Name: tg_ActiEcon_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_ActiEcon_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON actiecon FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE actiecon DISABLE TRIGGER "tg_ActiEcon_Bitacora";


--
-- TOC entry 3948 (class 0 OID 0)
-- Dependencies: 3090
-- Name: TRIGGER "tg_ActiEcon_Bitacora" ON actiecon; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_ActiEcon_Bitacora" ON actiecon IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3091 (class 2620 OID 25810)
-- Dependencies: 330 169 3263
-- Name: tg_AlicImp_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_AlicImp_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON alicimp FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE alicimp DISABLE TRIGGER "tg_AlicImp_Bitacora";


--
-- TOC entry 3949 (class 0 OID 0)
-- Dependencies: 3091
-- Name: TRIGGER "tg_AlicImp_Bitacora" ON alicimp; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_AlicImp_Bitacora" ON alicimp IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3096 (class 2620 OID 25811)
-- Dependencies: 178 330 3263
-- Name: tg_CalPagoD_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_CalPagoD_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON calpagod FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE calpagod DISABLE TRIGGER "tg_CalPagoD_Bitacora";


--
-- TOC entry 3950 (class 0 OID 0)
-- Dependencies: 3096
-- Name: TRIGGER "tg_CalPagoD_Bitacora" ON calpagod; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_CalPagoD_Bitacora" ON calpagod IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3097 (class 2620 OID 25812)
-- Dependencies: 330 180 3263
-- Name: tg_CalPago_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_CalPago_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON calpago FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE calpago DISABLE TRIGGER "tg_CalPago_Bitacora";


--
-- TOC entry 3951 (class 0 OID 0)
-- Dependencies: 3097
-- Name: TRIGGER "tg_CalPago_Bitacora" ON calpago; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_CalPago_Bitacora" ON calpago IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3099 (class 2620 OID 25813)
-- Dependencies: 184 330 3263
-- Name: tg_Ciudades_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_Ciudades_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON ciudades FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE ciudades DISABLE TRIGGER "tg_Ciudades_Bitacora";


--
-- TOC entry 3952 (class 0 OID 0)
-- Dependencies: 3099
-- Name: TRIGGER "tg_Ciudades_Bitacora" ON ciudades; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_Ciudades_Bitacora" ON ciudades IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3100 (class 2620 OID 25814)
-- Dependencies: 188 330 3263
-- Name: tg_ConUsuTi_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_ConUsuTi_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON conusuti FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE conusuti DISABLE TRIGGER "tg_ConUsuTi_Bitacora";


--
-- TOC entry 3953 (class 0 OID 0)
-- Dependencies: 3100
-- Name: TRIGGER "tg_ConUsuTi_Bitacora" ON conusuti; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_ConUsuTi_Bitacora" ON conusuti IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3102 (class 2620 OID 25815)
-- Dependencies: 330 194 3263
-- Name: tg_Contribu_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_Contribu_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON contribu FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE contribu DISABLE TRIGGER "tg_Contribu_Bitacora";


--
-- TOC entry 3954 (class 0 OID 0)
-- Dependencies: 3102
-- Name: TRIGGER "tg_Contribu_Bitacora" ON contribu; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_Contribu_Bitacora" ON contribu IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3104 (class 2620 OID 25816)
-- Dependencies: 330 204 3263
-- Name: tg_Estados_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_Estados_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON estados FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE estados DISABLE TRIGGER "tg_Estados_Bitacora";


--
-- TOC entry 3955 (class 0 OID 0)
-- Dependencies: 3104
-- Name: TRIGGER "tg_Estados_Bitacora" ON estados; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_Estados_Bitacora" ON estados IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3108 (class 2620 OID 25817)
-- Dependencies: 212 330 3263
-- Name: tg_RepLegal_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_RepLegal_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON replegal FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE replegal DISABLE TRIGGER "tg_RepLegal_Bitacora";


--
-- TOC entry 3956 (class 0 OID 0)
-- Dependencies: 3108
-- Name: TRIGGER "tg_RepLegal_Bitacora" ON replegal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_RepLegal_Bitacora" ON replegal IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3110 (class 2620 OID 25818)
-- Dependencies: 216 330 3263
-- Name: tg_TiPeGrav_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_TiPeGrav_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON tipegrav FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE tipegrav DISABLE TRIGGER "tg_TiPeGrav_Bitacora";


--
-- TOC entry 3957 (class 0 OID 0)
-- Dependencies: 3110
-- Name: TRIGGER "tg_TiPeGrav_Bitacora" ON tipegrav; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_TiPeGrav_Bitacora" ON tipegrav IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3111 (class 2620 OID 25819)
-- Dependencies: 330 218 3263
-- Name: tg_TipoCont_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_TipoCont_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON tipocont FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE tipocont DISABLE TRIGGER "tg_TipoCont_Bitacora";


--
-- TOC entry 3958 (class 0 OID 0)
-- Dependencies: 3111
-- Name: TRIGGER "tg_TipoCont_Bitacora" ON tipocont; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_TipoCont_Bitacora" ON tipocont IS 'Trigger para insertar datos en la tabla de bitacoras';


SET search_path = seg, pg_catalog;

--
-- TOC entry 3122 (class 2620 OID 25820)
-- Dependencies: 331 287 3263
-- Name: ejecutaverificamodulo; Type: TRIGGER; Schema: seg; Owner: postgres
--

CREATE TRIGGER ejecutaverificamodulo BEFORE INSERT ON tbl_permiso_trampa FOR EACH ROW EXECUTE PROCEDURE verificaperfil();


SET search_path = datos, pg_catalog;

--
-- TOC entry 3030 (class 2606 OID 25821)
-- Dependencies: 192 226 2676 3263
-- Name: FK_Accionis_IDContribu; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY accionis
    ADD CONSTRAINT "FK_Accionis_IDContribu" FOREIGN KEY (contribuid) REFERENCES conusu(id) MATCH FULL;


--
-- TOC entry 3031 (class 2606 OID 25826)
-- Dependencies: 224 226 2802 3263
-- Name: FK_Accionis_UsFonpro_UsuarioID_ID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY accionis
    ADD CONSTRAINT "FK_Accionis_UsFonpro_UsuarioID_ID" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2975 (class 2606 OID 25831)
-- Dependencies: 224 167 2802 3263
-- Name: FK_ActiEcon_USFonpro_IDUsuario_IDUsFornpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY actiecon
    ADD CONSTRAINT "FK_ActiEcon_USFonpro_IDUsuario_IDUsFornpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2976 (class 2606 OID 25836)
-- Dependencies: 218 169 2781 3263
-- Name: FK_AlicImp_TipoCont_IDTipoCont; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY alicimp
    ADD CONSTRAINT "FK_AlicImp_TipoCont_IDTipoCont" FOREIGN KEY (tipocontid) REFERENCES tipocont(id) MATCH FULL;


--
-- TOC entry 2977 (class 2606 OID 25841)
-- Dependencies: 224 169 2802 3263
-- Name: FK_AlicImp_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY alicimp
    ADD CONSTRAINT "FK_AlicImp_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2978 (class 2606 OID 25846)
-- Dependencies: 229 171 2824 3263
-- Name: FK_AsientoD_Asiento_IDAsiento; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asientod
    ADD CONSTRAINT "FK_AsientoD_Asiento_IDAsiento" FOREIGN KEY (asientoid) REFERENCES asiento(id) MATCH FULL;


--
-- TOC entry 2979 (class 2606 OID 25851)
-- Dependencies: 2857 248 171 3263
-- Name: FK_AsientoD_CtaConta_Cuenta; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asientod
    ADD CONSTRAINT "FK_AsientoD_CtaConta_Cuenta" FOREIGN KEY (cuenta) REFERENCES ctaconta(cuenta) MATCH FULL;


--
-- TOC entry 2980 (class 2606 OID 25856)
-- Dependencies: 224 2802 171 3263
-- Name: FK_AsientoD_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asientod
    ADD CONSTRAINT "FK_AsientoD_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 3036 (class 2606 OID 25861)
-- Dependencies: 232 230 2829 3263
-- Name: FK_AsientoMD_AsientoM_AsientoMID_ID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asientomd
    ADD CONSTRAINT "FK_AsientoMD_AsientoM_AsientoMID_ID" FOREIGN KEY (asientomid) REFERENCES asientom(id) MATCH FULL;


--
-- TOC entry 3037 (class 2606 OID 25866)
-- Dependencies: 248 232 2857 3263
-- Name: FK_AsientoMD_CtaConta_Cuenta; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asientomd
    ADD CONSTRAINT "FK_AsientoMD_CtaConta_Cuenta" FOREIGN KEY (cuenta) REFERENCES ctaconta(cuenta) MATCH FULL;


--
-- TOC entry 3038 (class 2606 OID 25871)
-- Dependencies: 224 2802 232 3263
-- Name: FK_AsientoMD_UsFonpro_UsuarioID_ID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asientomd
    ADD CONSTRAINT "FK_AsientoMD_UsFonpro_UsuarioID_ID" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 3035 (class 2606 OID 25876)
-- Dependencies: 230 2802 224 3263
-- Name: FK_AsientoM_UsFonpro_UsuarioID_ID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asientom
    ADD CONSTRAINT "FK_AsientoM_UsFonpro_UsuarioID_ID" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 3033 (class 2606 OID 25881)
-- Dependencies: 224 2802 229 3263
-- Name: FK_Asiento_UsFonpro_IDUsCierre_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asiento
    ADD CONSTRAINT "FK_Asiento_UsFonpro_IDUsCierre_IDUsFonpro" FOREIGN KEY (uscierreid) REFERENCES usfonpro(id);


--
-- TOC entry 3034 (class 2606 OID 25886)
-- Dependencies: 229 2802 224 3263
-- Name: FK_Asiento_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asiento
    ADD CONSTRAINT "FK_Asiento_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2981 (class 2606 OID 25891)
-- Dependencies: 2632 176 174 3263
-- Name: FK_BaCuenta_Bancos_IDBanco; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY bacuenta
    ADD CONSTRAINT "FK_BaCuenta_Bancos_IDBanco" FOREIGN KEY (bancoid) REFERENCES bancos(id) MATCH FULL;


--
-- TOC entry 2982 (class 2606 OID 25896)
-- Dependencies: 2802 174 224 3263
-- Name: FK_BaCuenta_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY bacuenta
    ADD CONSTRAINT "FK_BaCuenta_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2983 (class 2606 OID 25901)
-- Dependencies: 2802 176 224 3263
-- Name: FK_Bancos_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY bancos
    ADD CONSTRAINT "FK_Bancos_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2984 (class 2606 OID 25906)
-- Dependencies: 180 178 2645 3263
-- Name: FK_CalPagoD_CalPago_IDCalPago; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY calpagod
    ADD CONSTRAINT "FK_CalPagoD_CalPago_IDCalPago" FOREIGN KEY (calpagoid) REFERENCES calpago(id) MATCH FULL;


--
-- TOC entry 2985 (class 2606 OID 25911)
-- Dependencies: 178 224 2802 3263
-- Name: FK_CalPagoD_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY calpagod
    ADD CONSTRAINT "FK_CalPagoD_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2986 (class 2606 OID 25916)
-- Dependencies: 224 180 2802 3263
-- Name: FK_CalPago_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY calpago
    ADD CONSTRAINT "FK_CalPago_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2987 (class 2606 OID 25921)
-- Dependencies: 2775 216 180 3263
-- Name: FK_CalPagos_TiPeGrav_IDTiPeGrav; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY calpago
    ADD CONSTRAINT "FK_CalPagos_TiPeGrav_IDTiPeGrav" FOREIGN KEY (tipegravid) REFERENCES tipegrav(id) MATCH FULL;


--
-- TOC entry 2988 (class 2606 OID 25926)
-- Dependencies: 182 2802 224 3263
-- Name: FK_Cargos_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY cargos
    ADD CONSTRAINT "FK_Cargos_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2989 (class 2606 OID 25931)
-- Dependencies: 204 2737 184 3263
-- Name: FK_Ciudades_Estados_IDEstado; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY ciudades
    ADD CONSTRAINT "FK_Ciudades_Estados_IDEstado" FOREIGN KEY (estadoid) REFERENCES estados(id) MATCH FULL;


--
-- TOC entry 2990 (class 2606 OID 25936)
-- Dependencies: 2802 224 184 3263
-- Name: FK_Ciudades_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY ciudades
    ADD CONSTRAINT "FK_Ciudades_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2991 (class 2606 OID 25941)
-- Dependencies: 186 192 2676 3263
-- Name: FK_ConUsuCo_ConUsu_IDConUsu; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusuco
    ADD CONSTRAINT "FK_ConUsuCo_ConUsu_IDConUsu" FOREIGN KEY (conusuid) REFERENCES conusu(id) MATCH FULL;


--
-- TOC entry 2992 (class 2606 OID 25946)
-- Dependencies: 186 194 2691 3263
-- Name: FK_ConUsuCo_Contribu_IDContribu; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusuco
    ADD CONSTRAINT "FK_ConUsuCo_Contribu_IDContribu" FOREIGN KEY (contribuid) REFERENCES contribu(id) MATCH FULL;


--
-- TOC entry 2993 (class 2606 OID 25951)
-- Dependencies: 188 224 2802 3263
-- Name: FK_ConUsuTi_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusuti
    ADD CONSTRAINT "FK_ConUsuTi_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2994 (class 2606 OID 25956)
-- Dependencies: 2676 190 192 3263
-- Name: FK_ConUsuTo_ConUsu_IDConUsu; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusuto
    ADD CONSTRAINT "FK_ConUsuTo_ConUsu_IDConUsu" FOREIGN KEY (conusuid) REFERENCES conusu(id) MATCH FULL;


--
-- TOC entry 2995 (class 2606 OID 25961)
-- Dependencies: 2665 192 188 3263
-- Name: FK_ConUsu_ConUsuTi_IDConUsuTi; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusu
    ADD CONSTRAINT "FK_ConUsu_ConUsuTi_IDConUsuTi" FOREIGN KEY (conusutiid) REFERENCES conusuti(id) MATCH FULL;


--
-- TOC entry 2996 (class 2606 OID 25966)
-- Dependencies: 210 192 2754 3263
-- Name: FK_ConUsu_PregSecr_IDPregSecr; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusu
    ADD CONSTRAINT "FK_ConUsu_PregSecr_IDPregSecr" FOREIGN KEY (pregsecrid) REFERENCES pregsecr(id) MATCH FULL;


--
-- TOC entry 2997 (class 2606 OID 25971)
-- Dependencies: 2802 224 192 3263
-- Name: FK_ConUsu_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusu
    ADD CONSTRAINT "FK_ConUsu_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 3043 (class 2606 OID 25976)
-- Dependencies: 240 194 2691 3263
-- Name: FK_ContribuTi_Contribu_ContribuID_ID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY contributi
    ADD CONSTRAINT "FK_ContribuTi_Contribu_ContribuID_ID" FOREIGN KEY (contribuid) REFERENCES contribu(id) MATCH FULL;


--
-- TOC entry 3044 (class 2606 OID 25981)
-- Dependencies: 240 218 2781 3263
-- Name: FK_ContribuTi_TipoCont_TipoContID_ID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY contributi
    ADD CONSTRAINT "FK_ContribuTi_TipoCont_TipoContID_ID" FOREIGN KEY (tipocontid) REFERENCES tipocont(id) MATCH FULL;


--
-- TOC entry 2998 (class 2606 OID 25986)
-- Dependencies: 2606 194 167 3263
-- Name: FK_Contribu_ActiEcon_IDActiEcon; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY contribu
    ADD CONSTRAINT "FK_Contribu_ActiEcon_IDActiEcon" FOREIGN KEY (actieconid) REFERENCES actiecon(id) MATCH FULL;


--
-- TOC entry 2999 (class 2606 OID 25991)
-- Dependencies: 2656 194 184 3263
-- Name: FK_Contribu_Ciudades_IDCiudad; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY contribu
    ADD CONSTRAINT "FK_Contribu_Ciudades_IDCiudad" FOREIGN KEY (ciudadid) REFERENCES ciudades(id) MATCH FULL;


--
-- TOC entry 3000 (class 2606 OID 25996)
-- Dependencies: 192 194 2676 3263
-- Name: FK_Contribu_ConUsu_UsuarioID_ID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY contribu
    ADD CONSTRAINT "FK_Contribu_ConUsu_UsuarioID_ID" FOREIGN KEY (usuarioid) REFERENCES conusu(id) MATCH FULL;


--
-- TOC entry 3001 (class 2606 OID 26001)
-- Dependencies: 204 194 2737 3263
-- Name: FK_Contribu_Estados_IDEstado; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY contribu
    ADD CONSTRAINT "FK_Contribu_Estados_IDEstado" FOREIGN KEY (estadoid) REFERENCES estados(id) MATCH FULL;


--
-- TOC entry 3048 (class 2606 OID 26006)
-- Dependencies: 224 248 2802 3263
-- Name: FK_CtaConta_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY ctaconta
    ADD CONSTRAINT "FK_CtaConta_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 3049 (class 2606 OID 26011)
-- Dependencies: 2824 229 249 3263
-- Name: FK_Decla_Asiento_IDAsiento; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT "FK_Decla_Asiento_IDAsiento" FOREIGN KEY (asientoid) REFERENCES asiento(id);


--
-- TOC entry 3050 (class 2606 OID 26016)
-- Dependencies: 2636 249 178 3263
-- Name: FK_Decla_Calpagod_id; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT "FK_Decla_Calpagod_id" FOREIGN KEY (calpagodid) REFERENCES calpagod(id);


--
-- TOC entry 3051 (class 2606 OID 26021)
-- Dependencies: 249 249 2873 3263
-- Name: FK_Decla_PlaSustID_ID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT "FK_Decla_PlaSustID_ID" FOREIGN KEY (plasustid) REFERENCES declara(id);


--
-- TOC entry 3052 (class 2606 OID 26026)
-- Dependencies: 2765 212 249 3263
-- Name: FK_Decla_RepLegal_IDRepLegal; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT "FK_Decla_RepLegal_IDRepLegal" FOREIGN KEY (replegalid) REFERENCES replegal(id) MATCH FULL;


--
-- TOC entry 3053 (class 2606 OID 26031)
-- Dependencies: 249 2770 214 3263
-- Name: FK_Decla_TDeclara_IDTDeclara; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT "FK_Decla_TDeclara_IDTDeclara" FOREIGN KEY (tdeclaraid) REFERENCES tdeclara(id) MATCH FULL;


--
-- TOC entry 3054 (class 2606 OID 26036)
-- Dependencies: 249 224 2802 3263
-- Name: FK_Decla_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT "FK_Decla_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id);


--
-- TOC entry 3055 (class 2606 OID 26041)
-- Dependencies: 249 218 2781 3263
-- Name: FK_Decla_tipocontribuid; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT "FK_Decla_tipocontribuid" FOREIGN KEY (tipocontribuid) REFERENCES tipocont(id);


--
-- TOC entry 3002 (class 2606 OID 26046)
-- Dependencies: 196 2824 229 3263
-- Name: FK_Declara_Asiento_IDAsiento; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara_viejo
    ADD CONSTRAINT "FK_Declara_Asiento_IDAsiento" FOREIGN KEY (asientoid) REFERENCES asiento(id);


--
-- TOC entry 3003 (class 2606 OID 26051)
-- Dependencies: 2636 178 196 3263
-- Name: FK_Declara_Calpagod_id; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara_viejo
    ADD CONSTRAINT "FK_Declara_Calpagod_id" FOREIGN KEY (calpagodid) REFERENCES calpagod(id);


--
-- TOC entry 3004 (class 2606 OID 26056)
-- Dependencies: 196 196 2707 3263
-- Name: FK_Declara_PlaSustID_ID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara_viejo
    ADD CONSTRAINT "FK_Declara_PlaSustID_ID" FOREIGN KEY (plasustid) REFERENCES declara_viejo(id);


--
-- TOC entry 3005 (class 2606 OID 26061)
-- Dependencies: 196 212 2765 3263
-- Name: FK_Declara_RepLegal_IDRepLegal; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara_viejo
    ADD CONSTRAINT "FK_Declara_RepLegal_IDRepLegal" FOREIGN KEY (replegalid) REFERENCES replegal(id) MATCH FULL;


--
-- TOC entry 3006 (class 2606 OID 26066)
-- Dependencies: 196 214 2770 3263
-- Name: FK_Declara_TDeclara_IDTDeclara; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara_viejo
    ADD CONSTRAINT "FK_Declara_TDeclara_IDTDeclara" FOREIGN KEY (tdeclaraid) REFERENCES tdeclara(id) MATCH FULL;


--
-- TOC entry 3007 (class 2606 OID 26071)
-- Dependencies: 196 224 2802 3263
-- Name: FK_Declara_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara_viejo
    ADD CONSTRAINT "FK_Declara_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id);


--
-- TOC entry 3008 (class 2606 OID 26076)
-- Dependencies: 196 218 2781 3263
-- Name: FK_Declara_tipocontribuid; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara_viejo
    ADD CONSTRAINT "FK_Declara_tipocontribuid" FOREIGN KEY (tipocontribuid) REFERENCES tipocont(id);


--
-- TOC entry 3060 (class 2606 OID 26081)
-- Dependencies: 258 224 2802 3263
-- Name: FK_Document_UsFonpro_UsFonproID_ID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY document
    ADD CONSTRAINT "FK_Document_UsFonpro_UsFonproID_ID" FOREIGN KEY (usfonproid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 3011 (class 2606 OID 26086)
-- Dependencies: 200 202 2732 3263
-- Name: FK_EntidadD_Entidad_IDEntidad; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY entidadd
    ADD CONSTRAINT "FK_EntidadD_Entidad_IDEntidad" FOREIGN KEY (entidadid) REFERENCES entidad(id) MATCH FULL;


--
-- TOC entry 3012 (class 2606 OID 26091)
-- Dependencies: 204 224 2802 3263
-- Name: FK_Estados_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY estados
    ADD CONSTRAINT "FK_Estados_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 3013 (class 2606 OID 26096)
-- Dependencies: 206 200 2724 3263
-- Name: FK_PerUsuD_EndidadD_IDEntidadD; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY perusud
    ADD CONSTRAINT "FK_PerUsuD_EndidadD_IDEntidadD" FOREIGN KEY (entidaddid) REFERENCES entidadd(id) MATCH FULL;


--
-- TOC entry 3014 (class 2606 OID 26101)
-- Dependencies: 206 208 2749 3263
-- Name: FK_PerUsuD_PerUsu_IDPerUsu; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY perusud
    ADD CONSTRAINT "FK_PerUsuD_PerUsu_IDPerUsu" FOREIGN KEY (perusuid) REFERENCES perusu(id) MATCH FULL;


--
-- TOC entry 3015 (class 2606 OID 26106)
-- Dependencies: 206 224 2802 3263
-- Name: FK_PerUsuD_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY perusud
    ADD CONSTRAINT "FK_PerUsuD_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 3016 (class 2606 OID 26111)
-- Dependencies: 208 224 2802 3263
-- Name: FK_PerUsu_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY perusu
    ADD CONSTRAINT "FK_PerUsu_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 3017 (class 2606 OID 26116)
-- Dependencies: 210 224 2802 3263
-- Name: FK_PregSecr_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY pregsecr
    ADD CONSTRAINT "FK_PregSecr_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 3018 (class 2606 OID 26121)
-- Dependencies: 2656 212 184 3263
-- Name: FK_RepLegal_IDCiudad; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY replegal
    ADD CONSTRAINT "FK_RepLegal_IDCiudad" FOREIGN KEY (ciudadid) REFERENCES ciudades(id) MATCH FULL;


--
-- TOC entry 3020 (class 2606 OID 26136)
-- Dependencies: 224 214 2802 3263
-- Name: FK_TDeclara_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tdeclara
    ADD CONSTRAINT "FK_TDeclara_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 3021 (class 2606 OID 26141)
-- Dependencies: 224 216 2802 3263
-- Name: FK_TiPeGrav_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tipegrav
    ADD CONSTRAINT "FK_TiPeGrav_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 3022 (class 2606 OID 26146)
-- Dependencies: 2775 216 218 3263
-- Name: FK_TipoCont_TiPeGrav_IDTiPeGrav; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tipocont
    ADD CONSTRAINT "FK_TipoCont_TiPeGrav_IDTiPeGrav" FOREIGN KEY (tipegravid) REFERENCES tipegrav(id) MATCH FULL;


--
-- TOC entry 3023 (class 2606 OID 26151)
-- Dependencies: 2802 218 224 3263
-- Name: FK_TipoCont_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tipocont
    ADD CONSTRAINT "FK_TipoCont_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 3068 (class 2606 OID 26156)
-- Dependencies: 2606 266 167 3263
-- Name: FK_TmpContri_ActiEcon_IDActiEcon; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tmpcontri
    ADD CONSTRAINT "FK_TmpContri_ActiEcon_IDActiEcon" FOREIGN KEY (actieconid) REFERENCES actiecon(id) MATCH FULL;


--
-- TOC entry 3069 (class 2606 OID 26161)
-- Dependencies: 266 184 2656 3263
-- Name: FK_TmpContri_Ciudades_IDCiudad; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tmpcontri
    ADD CONSTRAINT "FK_TmpContri_Ciudades_IDCiudad" FOREIGN KEY (ciudadid) REFERENCES ciudades(id) MATCH FULL;


--
-- TOC entry 3070 (class 2606 OID 26166)
-- Dependencies: 266 194 2691 3263
-- Name: FK_TmpContri_Contribu_IDContribu; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tmpcontri
    ADD CONSTRAINT "FK_TmpContri_Contribu_IDContribu" FOREIGN KEY (id) REFERENCES contribu(id) MATCH FULL;


--
-- TOC entry 3071 (class 2606 OID 26171)
-- Dependencies: 266 204 2737 3263
-- Name: FK_TmpContri_Estados_IDEstado; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tmpcontri
    ADD CONSTRAINT "FK_TmpContri_Estados_IDEstado" FOREIGN KEY (estadoid) REFERENCES estados(id) MATCH FULL;


--
-- TOC entry 3072 (class 2606 OID 26176)
-- Dependencies: 266 218 2781 3263
-- Name: FK_TmpContri_TipoCont_IDTipoCont; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tmpcontri
    ADD CONSTRAINT "FK_TmpContri_TipoCont_IDTipoCont" FOREIGN KEY (tipocontid) REFERENCES tipocont(id) MATCH FULL;


--
-- TOC entry 3073 (class 2606 OID 26181)
-- Dependencies: 267 184 2656 3263
-- Name: FK_TmpReLegal_IDCiudad; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tmprelegal
    ADD CONSTRAINT "FK_TmpReLegal_IDCiudad" FOREIGN KEY (ciudadid) REFERENCES ciudades(id) MATCH FULL;


--
-- TOC entry 3074 (class 2606 OID 26186)
-- Dependencies: 267 266 2916 3263
-- Name: FK_TmpReLegal_IDContribu; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tmprelegal
    ADD CONSTRAINT "FK_TmpReLegal_IDContribu" FOREIGN KEY (contribuid) REFERENCES tmpcontri(id) MATCH FULL;


--
-- TOC entry 3075 (class 2606 OID 26191)
-- Dependencies: 267 204 2737 3263
-- Name: FK_TmpReLegal_IDEstado; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tmprelegal
    ADD CONSTRAINT "FK_TmpReLegal_IDEstado" FOREIGN KEY (estadoid) REFERENCES estados(id) MATCH FULL;


--
-- TOC entry 3076 (class 2606 OID 26196)
-- Dependencies: 267 212 2765 3263
-- Name: FK_TmpReLegal_IDRepLegal; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tmprelegal
    ADD CONSTRAINT "FK_TmpReLegal_IDRepLegal" FOREIGN KEY (id) REFERENCES replegal(id) MATCH FULL;


--
-- TOC entry 3024 (class 2606 OID 26201)
-- Dependencies: 220 224 2802 3263
-- Name: FK_UndTrib_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY undtrib
    ADD CONSTRAINT "FK_UndTrib_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 3026 (class 2606 OID 26206)
-- Dependencies: 224 210 2754 3263
-- Name: FK_UsFonPro_PregSecr_IDPregSecr; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY usfonpro
    ADD CONSTRAINT "FK_UsFonPro_PregSecr_IDPregSecr" FOREIGN KEY (pregsecrid) REFERENCES pregsecr(id) MATCH FULL;


--
-- TOC entry 3025 (class 2606 OID 26211)
-- Dependencies: 222 224 2802 3263
-- Name: FK_UsFonpTo_UsFonpro_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY usfonpto
    ADD CONSTRAINT "FK_UsFonpTo_UsFonpro_IDUsFonpro" FOREIGN KEY (usfonproid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 3027 (class 2606 OID 26216)
-- Dependencies: 224 182 2650 3263
-- Name: FK_UsFonpro_Cargos_IDCargo; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY usfonpro
    ADD CONSTRAINT "FK_UsFonpro_Cargos_IDCargo" FOREIGN KEY (cargoid) REFERENCES cargos(id) MATCH FULL;


--
-- TOC entry 3028 (class 2606 OID 26221)
-- Dependencies: 224 198 2711 3263
-- Name: FK_UsFonpro_Departam_IDDepartam; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY usfonpro
    ADD CONSTRAINT "FK_UsFonpro_Departam_IDDepartam" FOREIGN KEY (departamid) REFERENCES departam(id) MATCH FULL;


--
-- TOC entry 3029 (class 2606 OID 26226)
-- Dependencies: 224 208 2749 3263
-- Name: FK_UsFonpro_PerUsu_IDPerUsu; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY usfonpro
    ADD CONSTRAINT "FK_UsFonpro_PerUsu_IDPerUsu" FOREIGN KEY (perusuid) REFERENCES perusu(id);


--
-- TOC entry 3042 (class 2606 OID 26231)
-- Dependencies: 236 192 2676 3263
-- Name: FK_conusu_id; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY con_img_doc
    ADD CONSTRAINT "FK_conusu_id" FOREIGN KEY (conusuid) REFERENCES conusu(id) MATCH FULL;


--
-- TOC entry 3062 (class 2606 OID 26459)
-- Dependencies: 2824 229 264 3263
-- Name: FK_reparos_Asiento_IDAsiento; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY reparos
    ADD CONSTRAINT "FK_reparos_Asiento_IDAsiento" FOREIGN KEY (asientoid) REFERENCES asiento(id);


--
-- TOC entry 3063 (class 2606 OID 26464)
-- Dependencies: 2770 214 264 3263
-- Name: FK_reparos_TDeclara_IDTDeclara; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY reparos
    ADD CONSTRAINT "FK_reparos_TDeclara_IDTDeclara" FOREIGN KEY (tdeclaraid) REFERENCES tdeclara(id) MATCH FULL;


--
-- TOC entry 3064 (class 2606 OID 26469)
-- Dependencies: 264 2802 224 3263
-- Name: FK_reparos_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY reparos
    ADD CONSTRAINT "FK_reparos_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id);


--
-- TOC entry 3065 (class 2606 OID 26474)
-- Dependencies: 264 218 2781 3263
-- Name: FK_reparos_tipocontribuid; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY reparos
    ADD CONSTRAINT "FK_reparos_tipocontribuid" FOREIGN KEY (tipocontribuid) REFERENCES tipocont(id);


--
-- TOC entry 3067 (class 2606 OID 26256)
-- Dependencies: 2916 266 265 3263
-- Name: FK_tmpAccioni_ContribuID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tmpaccioni
    ADD CONSTRAINT "FK_tmpAccioni_ContribuID" FOREIGN KEY (contribuid) REFERENCES tmpcontri(id) MATCH FULL;


--
-- TOC entry 3010 (class 2606 OID 26261)
-- Dependencies: 198 224 2802 3263
-- Name: FL_Departam_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY departam
    ADD CONSTRAINT "FL_Departam_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 3019 (class 2606 OID 26266)
-- Dependencies: 212 192 2676 3263
-- Name: Fk_replegal_conusuid; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY replegal
    ADD CONSTRAINT "Fk_replegal_conusuid" FOREIGN KEY (contribuid) REFERENCES conusu(id);


--
-- TOC entry 3039 (class 2606 OID 26271)
-- Dependencies: 234 192 2676 3263
-- Name: fk-asignacion-contribuyente; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asignacion_fiscales
    ADD CONSTRAINT "fk-asignacion-contribuyente" FOREIGN KEY (conusuid) REFERENCES conusu(id);


--
-- TOC entry 3040 (class 2606 OID 26276)
-- Dependencies: 234 224 2802 3263
-- Name: fk-asignacion-fonprocine; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asignacion_fiscales
    ADD CONSTRAINT "fk-asignacion-fonprocine" FOREIGN KEY (usfonproid) REFERENCES usfonpro(id);


--
-- TOC entry 3041 (class 2606 OID 26281)
-- Dependencies: 234 224 2802 3263
-- Name: fk-asignacion-usuario; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asignacion_fiscales
    ADD CONSTRAINT "fk-asignacion-usuario" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id);


--
-- TOC entry 3061 (class 2606 OID 26286)
-- Dependencies: 260 224 2802 3263
-- Name: fk-usuario; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY interes_bcv
    ADD CONSTRAINT "fk-usuario" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id);


--
-- TOC entry 3032 (class 2606 OID 26291)
-- Dependencies: 227 224 2802 3263
-- Name: fk_acta_reparo_usuarioid; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY actas_reparo
    ADD CONSTRAINT fk_acta_reparo_usuarioid FOREIGN KEY (usuarioid) REFERENCES usfonpro(id);


--
-- TOC entry 3059 (class 2606 OID 26296)
-- Dependencies: 256 234 2836 3263
-- Name: fk_asignacion_fiscal_id; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY dettalles_fizcalizacion
    ADD CONSTRAINT fk_asignacion_fiscal_id FOREIGN KEY (asignacionfid) REFERENCES asignacion_fiscales(id);


--
-- TOC entry 3045 (class 2606 OID 26301)
-- Dependencies: 242 192 2676 3263
-- Name: fk_conusu_interno_conusu; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusu_interno
    ADD CONSTRAINT fk_conusu_interno_conusu FOREIGN KEY (conusuid) REFERENCES conusu(id);


--
-- TOC entry 3046 (class 2606 OID 26306)
-- Dependencies: 242 224 2802 3263
-- Name: fk_conusu_interno_usfonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusu_interno
    ADD CONSTRAINT fk_conusu_interno_usfonpro FOREIGN KEY (usuarioid) REFERENCES usfonpro(id);


--
-- TOC entry 3047 (class 2606 OID 26311)
-- Dependencies: 244 192 2676 3263
-- Name: fk_conusuid; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusu_tipocont
    ADD CONSTRAINT fk_conusuid FOREIGN KEY (conusuid) REFERENCES conusu(id) MATCH FULL;


--
-- TOC entry 3009 (class 2606 OID 26316)
-- Dependencies: 196 192 2676 3263
-- Name: fk_conusuid; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara_viejo
    ADD CONSTRAINT fk_conusuid FOREIGN KEY (conusuid) REFERENCES conusu(id) MATCH FULL;


--
-- TOC entry 3056 (class 2606 OID 26321)
-- Dependencies: 249 192 2676 3263
-- Name: fk_conusuid; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT fk_conusuid FOREIGN KEY (conusuid) REFERENCES conusu(id) MATCH FULL;


--
-- TOC entry 3057 (class 2606 OID 26326)
-- Dependencies: 254 249 2873 3263
-- Name: fk_declaraid_contric_calc_iddeclara; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY detalles_contrib_calc
    ADD CONSTRAINT fk_declaraid_contric_calc_iddeclara FOREIGN KEY (declaraid) REFERENCES declara(id);


--
-- TOC entry 3058 (class 2606 OID 26331)
-- Dependencies: 254 238 2840 3263
-- Name: fk_detalles_contric_calid_a_contric_calid; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY detalles_contrib_calc
    ADD CONSTRAINT fk_detalles_contric_calid_a_contric_calid FOREIGN KEY (contrib_calcid) REFERENCES contrib_calc(id);


--
-- TOC entry 3066 (class 2606 OID 26479)
-- Dependencies: 264 192 2676 3263
-- Name: fk_reparos_conusuid; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY reparos
    ADD CONSTRAINT fk_reparos_conusuid FOREIGN KEY (conusuid) REFERENCES conusu(id);


SET search_path = pre_aprobacion, pg_catalog;

--
-- TOC entry 3077 (class 2606 OID 26341)
-- Dependencies: 275 224 2802 3263
-- Name: fk-multa-usuario; Type: FK CONSTRAINT; Schema: pre_aprobacion; Owner: postgres
--

ALTER TABLE ONLY multas
    ADD CONSTRAINT "fk-multa-usuario" FOREIGN KEY (usuarioid) REFERENCES datos.usfonpro(id);


--
-- TOC entry 3078 (class 2606 OID 26346)
-- Dependencies: 275 249 2873 3263
-- Name: fk_multa_declaraid; Type: FK CONSTRAINT; Schema: pre_aprobacion; Owner: postgres
--

ALTER TABLE ONLY multas
    ADD CONSTRAINT fk_multa_declaraid FOREIGN KEY (declaraid) REFERENCES datos.declara(id);


SET search_path = seg, pg_catalog;

--
-- TOC entry 3080 (class 2606 OID 26351)
-- Dependencies: 285 281 2947 3263
-- Name: fk_permiso_modulo; Type: FK CONSTRAINT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_permiso
    ADD CONSTRAINT fk_permiso_modulo FOREIGN KEY (id_modulo) REFERENCES tbl_modulo(id_modulo) ON DELETE RESTRICT;


--
-- TOC entry 3081 (class 2606 OID 26356)
-- Dependencies: 285 289 2957 3263
-- Name: fk_permiso_rol; Type: FK CONSTRAINT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_permiso
    ADD CONSTRAINT fk_permiso_rol FOREIGN KEY (id_rol) REFERENCES tbl_rol(id_rol) ON DELETE RESTRICT;


--
-- TOC entry 3084 (class 2606 OID 26361)
-- Dependencies: 291 2957 289 3263
-- Name: fk_rol_usuario_rol; Type: FK CONSTRAINT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_rol_usuario
    ADD CONSTRAINT fk_rol_usuario_rol FOREIGN KEY (id_rol) REFERENCES tbl_rol(id_rol) ON DELETE RESTRICT;


--
-- TOC entry 3079 (class 2606 OID 26366)
-- Dependencies: 2951 278 283 3263
-- Name: fk_tblcargos; Type: FK CONSTRAINT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_cargos
    ADD CONSTRAINT fk_tblcargos FOREIGN KEY (oficinasid) REFERENCES tbl_oficinas(id);


--
-- TOC entry 3085 (class 2606 OID 26371)
-- Dependencies: 2957 289 294 3263
-- Name: fk_usuario_rol_rol; Type: FK CONSTRAINT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_usuario_rol
    ADD CONSTRAINT fk_usuario_rol_rol FOREIGN KEY (id_rol) REFERENCES tbl_rol(id_rol) ON DELETE RESTRICT;


--
-- TOC entry 3082 (class 2606 OID 26376)
-- Dependencies: 2947 287 281 3263
-- Name: fkt_permiso_modulo; Type: FK CONSTRAINT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_permiso_trampa
    ADD CONSTRAINT fkt_permiso_modulo FOREIGN KEY (id_modulo) REFERENCES tbl_modulo(id_modulo) ON DELETE RESTRICT;


--
-- TOC entry 3083 (class 2606 OID 26381)
-- Dependencies: 287 289 2957 3263
-- Name: fkt_permiso_rol; Type: FK CONSTRAINT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_permiso_trampa
    ADD CONSTRAINT fkt_permiso_rol FOREIGN KEY (id_rol) REFERENCES tbl_rol(id_rol) ON DELETE RESTRICT;


SET search_path = "segContribu", pg_catalog;

--
-- TOC entry 3086 (class 2606 OID 26386)
-- Dependencies: 299 2965 297 3263
-- Name: fk_permiso_modulo; Type: FK CONSTRAINT; Schema: segContribu; Owner: postgres
--

ALTER TABLE ONLY tbl_permiso_contribu
    ADD CONSTRAINT fk_permiso_modulo FOREIGN KEY (id_modulo) REFERENCES tbl_modulo_contribu(id_modulo) ON DELETE RESTRICT;


--
-- TOC entry 3087 (class 2606 OID 26391)
-- Dependencies: 2969 301 299 3263
-- Name: fk_permiso_rol; Type: FK CONSTRAINT; Schema: segContribu; Owner: postgres
--

ALTER TABLE ONLY tbl_permiso_contribu
    ADD CONSTRAINT fk_permiso_rol FOREIGN KEY (id_rol) REFERENCES tbl_rol_contribu(id_rol) ON DELETE RESTRICT;


--
-- TOC entry 3088 (class 2606 OID 26396)
-- Dependencies: 303 2969 301 3263
-- Name: fk_rol_usuario_rol; Type: FK CONSTRAINT; Schema: segContribu; Owner: postgres
--

ALTER TABLE ONLY tbl_rol_usuario_contribu
    ADD CONSTRAINT fk_rol_usuario_rol FOREIGN KEY (id_rol) REFERENCES tbl_rol_contribu(id_rol) ON DELETE RESTRICT;


--
-- TOC entry 3089 (class 2606 OID 26401)
-- Dependencies: 2969 301 305 3263
-- Name: fk_usuario_rol_rol; Type: FK CONSTRAINT; Schema: segContribu; Owner: postgres
--

ALTER TABLE ONLY tbl_usuario_rol_contribu
    ADD CONSTRAINT fk_usuario_rol_rol FOREIGN KEY (id_rol) REFERENCES tbl_rol_contribu(id_rol) ON DELETE RESTRICT;


--
-- TOC entry 3269 (class 0 OID 0)
-- Dependencies: 9
-- Name: datos; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA datos FROM PUBLIC;
REVOKE ALL ON SCHEMA datos FROM postgres;
GRANT ALL ON SCHEMA datos TO postgres;
GRANT ALL ON SCHEMA datos TO PUBLIC;


--
-- TOC entry 3271 (class 0 OID 0)
-- Dependencies: 10
-- Name: historial; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA historial FROM PUBLIC;
REVOKE ALL ON SCHEMA historial FROM postgres;
GRANT ALL ON SCHEMA historial TO postgres;
GRANT ALL ON SCHEMA historial TO PUBLIC;


--
-- TOC entry 3273 (class 0 OID 0)
-- Dependencies: 11
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


SET search_path = datos, pg_catalog;

--
-- TOC entry 3289 (class 0 OID 0)
-- Dependencies: 167
-- Name: actiecon; Type: ACL; Schema: datos; Owner: postgres
--

REVOKE ALL ON TABLE actiecon FROM PUBLIC;
REVOKE ALL ON TABLE actiecon FROM postgres;
GRANT ALL ON TABLE actiecon TO postgres;


SET search_path = historial, pg_catalog;

--
-- TOC entry 3823 (class 0 OID 0)
-- Dependencies: 269
-- Name: bitacora; Type: ACL; Schema: historial; Owner: postgres
--

REVOKE ALL ON TABLE bitacora FROM PUBLIC;
REVOKE ALL ON TABLE bitacora FROM postgres;
GRANT ALL ON TABLE bitacora TO postgres;
GRANT ALL ON TABLE bitacora TO PUBLIC;


--
-- TOC entry 3825 (class 0 OID 0)
-- Dependencies: 270
-- Name: Bitacora_IDBitacora_seq; Type: ACL; Schema: historial; Owner: postgres
--

REVOKE ALL ON SEQUENCE "Bitacora_IDBitacora_seq" FROM PUBLIC;
REVOKE ALL ON SEQUENCE "Bitacora_IDBitacora_seq" FROM postgres;
GRANT ALL ON SEQUENCE "Bitacora_IDBitacora_seq" TO postgres;
GRANT ALL ON SEQUENCE "Bitacora_IDBitacora_seq" TO PUBLIC;


--
-- TOC entry 1910 (class 826 OID 26406)
-- Dependencies: 10 3263
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: historial; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA historial REVOKE ALL ON SEQUENCES  FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA historial REVOKE ALL ON SEQUENCES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA historial GRANT ALL ON SEQUENCES  TO PUBLIC;


--
-- TOC entry 1911 (class 826 OID 26407)
-- Dependencies: 10 3263
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: historial; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA historial REVOKE ALL ON FUNCTIONS  FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA historial REVOKE ALL ON FUNCTIONS  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA historial GRANT ALL ON FUNCTIONS  TO PUBLIC;


--
-- TOC entry 1912 (class 826 OID 26408)
-- Dependencies: 10 3263
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: historial; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA historial REVOKE ALL ON TABLES  FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA historial REVOKE ALL ON TABLES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA historial GRANT ALL ON TABLES  TO PUBLIC;


-- Completed on 2013-07-24 20:38:52 VET

--
-- PostgreSQL database dump complete
--

