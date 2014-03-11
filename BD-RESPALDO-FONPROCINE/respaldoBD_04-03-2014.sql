--
-- PostgreSQL database dump
--

-- Dumped from database version 9.1.11
-- Dumped by pg_dump version 9.1.11
-- Started on 2014-03-04 19:54:03 VET

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 3297 (class 1262 OID 26067)
-- Dependencies: 3296
-- Name: FONPROCINE; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE "FONPROCINE" IS 'Base de datos del sistema de recaudación de Fonprocine';


--
-- TOC entry 9 (class 2615 OID 26068)
-- Name: datos; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA datos;


ALTER SCHEMA datos OWNER TO postgres;

--
-- TOC entry 3298 (class 0 OID 0)
-- Dependencies: 9
-- Name: SCHEMA datos; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA datos IS 'standard public schema';


--
-- TOC entry 10 (class 2615 OID 26069)
-- Name: historial; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA historial;


ALTER SCHEMA historial OWNER TO postgres;

--
-- TOC entry 3300 (class 0 OID 0)
-- Dependencies: 10
-- Name: SCHEMA historial; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA historial IS 'Esquema para la tabla de historial de transacciones';


--
-- TOC entry 6 (class 2615 OID 26070)
-- Name: pre_aprobacion; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA pre_aprobacion;


ALTER SCHEMA pre_aprobacion OWNER TO postgres;

--
-- TOC entry 7 (class 2615 OID 26071)
-- Name: seg; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA seg;


ALTER SCHEMA seg OWNER TO postgres;

--
-- TOC entry 8 (class 2615 OID 26072)
-- Name: segContribu; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA "segContribu";


ALTER SCHEMA "segContribu" OWNER TO postgres;

--
-- TOC entry 316 (class 3079 OID 11716)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 3304 (class 0 OID 0)
-- Dependencies: 316
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = datos, pg_catalog;

--
-- TOC entry 339 (class 1255 OID 26073)
-- Dependencies: 9 1018
-- Name: crea_correlativo_actas(); Type: FUNCTION; Schema: datos; Owner: postgres
--

CREATE FUNCTION crea_correlativo_actas() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
anio_servidor integer;
nautori integer;
ndeclara varchar; 
condicion integer;
condicion2 VARCHAR;
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
				if(new.bln_conformida='false') then
				
					condicion2:='act-rpfis-1';
				else
				
					condicion2:='act-cfis-2';
				end if;
			
			
				anio_servidor:=(select cast(Extract(year FROM now()) as integer));
				if(SELECT count(*)  FROM datos.correlativos_actas WHERE tipo=condicion2 AND  anio=anio_servidor)>0 THEN
				  --if(SELECT count(*)  FROM datos.correlativos_actas WHERE tipo='act-rpfis-1')>0 THEN
					nautori=(select correlativo  FROM datos.correlativos_actas where tipo=condicion2 AND  anio=anio_servidor);				
				        --nautori=(select correlativo  FROM datos.correlativos_actas where tipo='act-rpfis-1');				

					UPDATE datos.actas_reparo
					SET 
					numero=(nautori||'-'||anio_servidor)
					WHERE id=new.id;

					UPDATE datos.correlativos_actas
					SET  correlativo=nautori+1
					WHERE tipo=condicion2;
				ELSE
					

					UPDATE datos.actas_reparo
					SET 
					numero=(1||'-'||(anio_servidor))
					WHERE id=new.id;

					UPDATE datos.correlativos_actas
					SET  correlativo=2,anio=(select (Extract(year FROM now())))
					WHERE tipo=condicion2;
						
				
				END IF;
			when 'declara' then
					condicion2:='n-declara';
					anio_servidor:=(select cast(Extract(year FROM now()) as integer));
					if(SELECT count(*)  FROM datos.correlativos_actas WHERE tipo=condicion2 AND  anio=anio_servidor)>0 THEN
						nautori=(select correlativo  FROM datos.correlativos_actas where tipo=condicion2 AND  anio=anio_servidor);				

						if(nautori<10)then
							ndeclara:='000'||nautori;
						end if;
						if( (nautori>=10) and (nautori<100) ) then
							ndeclara:='00'||nautori;
						end if;
						if( (nautori>=100) and (nautori<1000) ) then
							ndeclara:='0'||nautori;
						end if; 
						if(nautori>=1000) then
							ndeclara:=(select correlativo  FROM datos.correlativos_actas where tipo=condicion2 AND  anio=anio_servidor);	
						end if;

							
							UPDATE datos.declara
							SET 
							nudeclara=(ndeclara||'-'||anio_servidor)
							WHERE id=new.id;

							UPDATE datos.correlativos_actas
							SET  correlativo=nautori+1
							WHERE tipo=condicion2;
						ELSE
							

							UPDATE datos.declara
							SET 
							nudeclara=('0001'||'-'||(anio_servidor))
							WHERE id=new.id;

							UPDATE datos.correlativos_actas
							SET  correlativo=2,anio=(select (Extract(year FROM now())))
							WHERE tipo=condicion2;
								
						
					END IF;
			
			
				
		END CASE;			


	END IF;
	



RETURN NULL;
END;


$$;


ALTER FUNCTION datos.crea_correlativo_actas() OWNER TO postgres;

--
-- TOC entry 329 (class 1255 OID 26074)
-- Dependencies: 9 1018
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
-- TOC entry 3305 (class 0 OID 0)
-- Dependencies: 329
-- Name: FUNCTION "pa_ActUsuBitDel"("Tabla" text, "ValorID" integer, "IDUsuario" integer, OUT "Actualizado" boolean); Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON FUNCTION "pa_ActUsuBitDel"("Tabla" text, "ValorID" integer, "IDUsuario" integer, OUT "Actualizado" boolean) IS 'Funcion que actualiza el IDUsuario en la bitacora cuando se elimina un registro. Esta funcion tiene que ser llamada inmediatamente despues de eliminar una fila en cualquier tabla';


--
-- TOC entry 330 (class 1255 OID 26075)
-- Dependencies: 9 1018
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
-- TOC entry 3306 (class 0 OID 0)
-- Dependencies: 330
-- Name: FUNCTION "pa_LoginContribu"("LoginUsuario" text, "PasswordUsuario" text, OUT "IDUsuarioContribuyente" integer, OUT "NombreUsuario" text, OUT "IDTipoUsuario" integer, OUT "UltimoLogin" timestamp without time zone); Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON FUNCTION "pa_LoginContribu"("LoginUsuario" text, "PasswordUsuario" text, OUT "IDUsuarioContribuyente" integer, OUT "NombreUsuario" text, OUT "IDTipoUsuario" integer, OUT "UltimoLogin" timestamp without time zone) IS 'Funcion para hacer login de un contribuyente';


--
-- TOC entry 331 (class 1255 OID 26076)
-- Dependencies: 1018 9
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
-- TOC entry 3307 (class 0 OID 0)
-- Dependencies: 331
-- Name: FUNCTION "pa_LoginUsFonpro"("LoginUsuario" text, "PasswordUsuario" text, OUT "IDUsuarioFonprocine" integer, OUT "NombreUsuario" text, OUT "IDPerfilUsuario" integer, OUT "UltimoLogin" timestamp without time zone); Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON FUNCTION "pa_LoginUsFonpro"("LoginUsuario" text, "PasswordUsuario" text, OUT "IDUsuarioFonprocine" integer, OUT "NombreUsuario" text, OUT "IDPerfilUsuario" integer, OUT "UltimoLogin" timestamp without time zone) IS 'Funcion para hacer login de un usuario Fonprocine';


--
-- TOC entry 332 (class 1255 OID 26077)
-- Dependencies: 1018 9
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
-- TOC entry 3308 (class 0 OID 0)
-- Dependencies: 332
-- Name: FUNCTION "pa_TokenActivoContribu"("IDToken" integer, "IDUsuario" integer, OUT "Activo" boolean, OUT "FechaCreacion" timestamp without time zone, OUT "FechaCaducidad" timestamp without time zone, OUT "FechaHoraServidor" timestamp without time zone, OUT "Observaciones" text); Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON FUNCTION "pa_TokenActivoContribu"("IDToken" integer, "IDUsuario" integer, OUT "Activo" boolean, OUT "FechaCreacion" timestamp without time zone, OUT "FechaCaducidad" timestamp without time zone, OUT "FechaHoraServidor" timestamp without time zone, OUT "Observaciones" text) IS 'Funcion que verifica si el token de usuario de contribuyente buscado esta activo a la fecha hora del servidor';


--
-- TOC entry 333 (class 1255 OID 26078)
-- Dependencies: 1018 9
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
-- TOC entry 3309 (class 0 OID 0)
-- Dependencies: 333
-- Name: FUNCTION "pa_TokenActivoUsFonpro"("IDToken" integer, "IDUsuario" integer, OUT "Activo" boolean, OUT "FechaCreacion" timestamp without time zone, OUT "FechaCaducidad" timestamp without time zone, OUT "FechaHoraServidor" timestamp without time zone, OUT "Observaciones" text); Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON FUNCTION "pa_TokenActivoUsFonpro"("IDToken" integer, "IDUsuario" integer, OUT "Activo" boolean, OUT "FechaCreacion" timestamp without time zone, OUT "FechaCaducidad" timestamp without time zone, OUT "FechaHoraServidor" timestamp without time zone, OUT "Observaciones" text) IS 'Funcion que verifica si el token de usuario de forprocine buscado esta activo a la fecha hora del servidor';


--
-- TOC entry 334 (class 1255 OID 26079)
-- Dependencies: 9 1018
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
-- TOC entry 335 (class 1255 OID 26080)
-- Dependencies: 1018 9
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
-- TOC entry 3310 (class 0 OID 0)
-- Dependencies: 335
-- Name: FUNCTION "tf_AsiendoD_ActualizaDebeHaber_Asiento"(); Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON FUNCTION "tf_AsiendoD_ActualizaDebeHaber_Asiento"() IS 'Funcion de trigger que actualiza las columnas de debe y haber de la tabla Asientos';


--
-- TOC entry 328 (class 1255 OID 26081)
-- Dependencies: 9 1018
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
-- TOC entry 3311 (class 0 OID 0)
-- Dependencies: 328
-- Name: FUNCTION "tf_Asiento_ActualizaPeriodo"(); Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON FUNCTION "tf_Asiento_ActualizaPeriodo"() IS 'Funcion de trigger para actualizar las columnas de Mes y Ano, a partir de la fecha especificada';


--
-- TOC entry 336 (class 1255 OID 26082)
-- Dependencies: 9 1018
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
-- TOC entry 3312 (class 0 OID 0)
-- Dependencies: 336
-- Name: FUNCTION "tf_Asiento_ActualizaSaldo"(); Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON FUNCTION "tf_Asiento_ActualizaSaldo"() IS 'Funcion que actualiza el saldo de la tabla asiento';


--
-- TOC entry 337 (class 1255 OID 26083)
-- Dependencies: 9 1018
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
-- TOC entry 3313 (class 0 OID 0)
-- Dependencies: 337
-- Name: FUNCTION "tf_Bitacora"(); Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON FUNCTION "tf_Bitacora"() IS 'Trigger para el insert de datos en la bitacora de cambios';


SET search_path = seg, pg_catalog;

--
-- TOC entry 338 (class 1255 OID 26084)
-- Dependencies: 7 1018
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
		DELETE FROM seg.tbl_permiso
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
-- TOC entry 166 (class 1259 OID 26085)
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
-- TOC entry 167 (class 1259 OID 26087)
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
-- TOC entry 3314 (class 0 OID 0)
-- Dependencies: 167
-- Name: TABLE actiecon; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE actiecon IS 'Tabla con las actividades económicas';


--
-- TOC entry 3315 (class 0 OID 0)
-- Dependencies: 167
-- Name: COLUMN actiecon.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN actiecon.id IS 'Identificador del tipo de actividad económica';


--
-- TOC entry 3316 (class 0 OID 0)
-- Dependencies: 167
-- Name: COLUMN actiecon.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN actiecon.nombre IS 'Nombre de la actividad económica';


--
-- TOC entry 3317 (class 0 OID 0)
-- Dependencies: 167
-- Name: COLUMN actiecon.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN actiecon.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3318 (class 0 OID 0)
-- Dependencies: 167
-- Name: COLUMN actiecon.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN actiecon.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 168 (class 1259 OID 26090)
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
-- TOC entry 3320 (class 0 OID 0)
-- Dependencies: 168
-- Name: ActiEcon_IDActiEcon_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "ActiEcon_IDActiEcon_seq" OWNED BY actiecon.id;


--
-- TOC entry 169 (class 1259 OID 26092)
-- Dependencies: 2357 2358 2359 2360 2361 2362 2363 2364 2365 2366 2367 9
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
-- TOC entry 3321 (class 0 OID 0)
-- Dependencies: 169
-- Name: TABLE alicimp; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE alicimp IS 'Tabla con los datos de las alicuotas impositivas';


--
-- TOC entry 3322 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.id IS 'Identificador de la alicuota';


--
-- TOC entry 3323 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.tipocontid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.tipocontid IS 'Identificador del tipo de contribuyente';


--
-- TOC entry 3324 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.ano; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.ano IS 'Ano en la que aplica la alicuota';


--
-- TOC entry 3325 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.alicuota; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.alicuota IS '% de la alicuota a pagar';


--
-- TOC entry 3326 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.tipocalc; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.tipocalc IS 'Tipo de calculo a usar para seleccionar la alicuota.
0=Aplicar alicuota directamente.
1=Aplicar alicuota de acuerdo al limite inferior en UT.
2=Aplicar alicuota de acuerdo a rangos en UT';


--
-- TOC entry 3327 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.valorut; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.valorut IS 'Limite inferior en UT al cual se le aplica la alicuota. Aplica para TipoCalc=1';


--
-- TOC entry 3328 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.liminf1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.liminf1 IS 'Limite inferior 1 en UT para aplicacion de alicuota por rango. TipoCalc=2';


--
-- TOC entry 3329 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.limsup1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.limsup1 IS 'Limite superior 1 en UT para aplicacion de alicuota por rango. TipoCalc=2';


--
-- TOC entry 3330 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.alicuota1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.alicuota1 IS 'Alicuota del rango 1. TipoCalc=2';


--
-- TOC entry 3331 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.liminf2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.liminf2 IS 'Limite inferior 2 en UT para aplicacion de alicuota por rango. TipoCalc=2';


--
-- TOC entry 3332 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.limsup2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.limsup2 IS 'Limite superior 2 en UT para aplicacion de alicuota por rango. TipoCalc=2';


--
-- TOC entry 3333 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.alicuota2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.alicuota2 IS 'Alicuota del rango 2. TipoCalc=2';


--
-- TOC entry 3334 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.liminf3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.liminf3 IS 'Limite inferior 3 en UT para aplicacion de alicuota por rango. TipoCalc=2';


--
-- TOC entry 3335 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.limsup3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.limsup3 IS 'Limite superior 3 en UT para aplicacion de alicuota por rango. TipoCalc=2';


--
-- TOC entry 3336 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.alicuota3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.alicuota3 IS 'Alicuota del rango 3. TipoCalc=2';


--
-- TOC entry 3337 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.liminf4; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.liminf4 IS 'Limite inferior 4 en UT para aplicacion de alicuota por rango. TipoCalc=2';


--
-- TOC entry 3338 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.limsup4; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.limsup4 IS 'Limite superior 4 en UT para aplicacion de alicuota por rango. TipoCalc=2';


--
-- TOC entry 3339 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.alicuota4; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.alicuota4 IS 'Alicuota del rango 4. TipoCalc=2';


--
-- TOC entry 3340 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.liminf5; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.liminf5 IS 'Limite inferior 5 en UT para aplicacion de alicuota por rango. TipoCalc=2';


--
-- TOC entry 3341 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.limsup5; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.limsup5 IS 'Limite superior 5 en UT para aplicacion de alicuota por rango. TipoCalc=2';


--
-- TOC entry 3342 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.alicuota5; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.alicuota5 IS 'Alicuota del rango 5. TipoCalc=2';


--
-- TOC entry 3343 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.usuarioid IS 'Identificador del ultimo usuario en crear o modificar un registro';


--
-- TOC entry 3344 (class 0 OID 0)
-- Dependencies: 169
-- Name: COLUMN alicimp.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN alicimp.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 170 (class 1259 OID 26106)
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
-- TOC entry 3345 (class 0 OID 0)
-- Dependencies: 170
-- Name: AlicImp_IDAlicImp_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "AlicImp_IDAlicImp_seq" OWNED BY alicimp.id;


--
-- TOC entry 171 (class 1259 OID 26108)
-- Dependencies: 2369 2370 9
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
-- TOC entry 3346 (class 0 OID 0)
-- Dependencies: 171
-- Name: TABLE asientod; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE asientod IS 'Tabla con el detalle de los asientos';


--
-- TOC entry 3347 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN asientod.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientod.id IS 'Identificador unico de registro';


--
-- TOC entry 3348 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN asientod.asientoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientod.asientoid IS 'Identificador del asiento';


--
-- TOC entry 3349 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN asientod.fecha; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientod.fecha IS 'Fecha de la transaccion';


--
-- TOC entry 3350 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN asientod.cuenta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientod.cuenta IS 'Cuenta contable';


--
-- TOC entry 3351 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN asientod.monto; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientod.monto IS 'Monto de la transaccion';


--
-- TOC entry 3352 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN asientod.sentido; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientod.sentido IS 'Sentido del monto. 0=Debe / 1=Haber';


--
-- TOC entry 3353 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN asientod.referencia; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientod.referencia IS 'Referencia de la linea';


--
-- TOC entry 3354 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN asientod.comentar; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientod.comentar IS 'Comentarios u observaciones';


--
-- TOC entry 3355 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN asientod.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientod.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3356 (class 0 OID 0)
-- Dependencies: 171
-- Name: COLUMN asientod.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientod.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 172 (class 1259 OID 26116)
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
-- TOC entry 3357 (class 0 OID 0)
-- Dependencies: 172
-- Name: AsientoD_IDAsientoD_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "AsientoD_IDAsientoD_seq" OWNED BY asientod.id;


--
-- TOC entry 173 (class 1259 OID 26118)
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
-- TOC entry 174 (class 1259 OID 26120)
-- Dependencies: 2372 2373 9
-- Name: bacuenta; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE bacuenta (
    id integer NOT NULL,
    bancoid integer NOT NULL,
    tipo_cuenta character varying(20) NOT NULL,
    usuarioid integer NOT NULL,
    ip character varying(15) NOT NULL,
    num_cuenta character varying NOT NULL,
    fecha_registro date DEFAULT now() NOT NULL,
    bln_borrado boolean DEFAULT false NOT NULL
);


ALTER TABLE datos.bacuenta OWNER TO postgres;

--
-- TOC entry 3358 (class 0 OID 0)
-- Dependencies: 174
-- Name: TABLE bacuenta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE bacuenta IS 'Tabla con los datos de las cuentas bancarias';


--
-- TOC entry 3359 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN bacuenta.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN bacuenta.id IS 'Identificador unico de registro';


--
-- TOC entry 3360 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN bacuenta.bancoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN bacuenta.bancoid IS 'Identificador del banco';


--
-- TOC entry 3361 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN bacuenta.tipo_cuenta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN bacuenta.tipo_cuenta IS 'Numero de cuenta bancaria';


--
-- TOC entry 3362 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN bacuenta.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN bacuenta.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3363 (class 0 OID 0)
-- Dependencies: 174
-- Name: COLUMN bacuenta.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN bacuenta.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 175 (class 1259 OID 26128)
-- Dependencies: 174 9
-- Name: BaCuenta_IDBaCuenta_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE "BaCuenta_IDBaCuenta_seq"
    START WITH 1
    INCREMENT BY 1
    MINVALUE 0
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos."BaCuenta_IDBaCuenta_seq" OWNER TO postgres;

--
-- TOC entry 3364 (class 0 OID 0)
-- Dependencies: 175
-- Name: BaCuenta_IDBaCuenta_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "BaCuenta_IDBaCuenta_seq" OWNED BY bacuenta.id;


--
-- TOC entry 176 (class 1259 OID 26130)
-- Dependencies: 2375 9
-- Name: bancos; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE bancos (
    id integer NOT NULL,
    nombre character varying(100) NOT NULL,
    usuarioid integer NOT NULL,
    ip character varying(15) NOT NULL,
    fecha_registro date NOT NULL,
    bln_borrado boolean DEFAULT false NOT NULL
);


ALTER TABLE datos.bancos OWNER TO postgres;

--
-- TOC entry 3365 (class 0 OID 0)
-- Dependencies: 176
-- Name: TABLE bancos; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE bancos IS 'Tabla con los datos de los bancos que maneja el organismo';


--
-- TOC entry 3366 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN bancos.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN bancos.id IS 'Identificador unico de registro';


--
-- TOC entry 3367 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN bancos.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN bancos.nombre IS 'Nombre del banco';


--
-- TOC entry 3368 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN bancos.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN bancos.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3369 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN bancos.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN bancos.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 177 (class 1259 OID 26134)
-- Dependencies: 9 176
-- Name: Bancos_IDBanco_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE "Bancos_IDBanco_seq"
    START WITH 1
    INCREMENT BY 1
    MINVALUE 0
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos."Bancos_IDBanco_seq" OWNER TO postgres;

--
-- TOC entry 3370 (class 0 OID 0)
-- Dependencies: 177
-- Name: Bancos_IDBanco_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "Bancos_IDBanco_seq" OWNED BY bancos.id;


--
-- TOC entry 178 (class 1259 OID 26136)
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
-- TOC entry 3371 (class 0 OID 0)
-- Dependencies: 178
-- Name: TABLE calpagod; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE calpagod IS 'Tabla con el detalle de los calendario de pagos';


--
-- TOC entry 3372 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN calpagod.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpagod.id IS 'Identificador unico del detalle de los calendarios de pagos';


--
-- TOC entry 3373 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN calpagod.calpagoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpagod.calpagoid IS 'Identificador del calendario de pago';


--
-- TOC entry 3374 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN calpagod.fechaini; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpagod.fechaini IS 'Fecha de inicio del periodo gravable';


--
-- TOC entry 3375 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN calpagod.fechafin; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpagod.fechafin IS 'Fecha final del periodo gravable';


--
-- TOC entry 3376 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN calpagod.fechalim; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpagod.fechalim IS 'Fecha limite de pago del periodo gravable';


--
-- TOC entry 3377 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN calpagod.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpagod.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3378 (class 0 OID 0)
-- Dependencies: 178
-- Name: COLUMN calpagod.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpagod.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 179 (class 1259 OID 26139)
-- Dependencies: 9 178
-- Name: CalPagoD_IDCalPagoD_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE "CalPagoD_IDCalPagoD_seq"
    START WITH 1
    INCREMENT BY 1
    MINVALUE 0
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos."CalPagoD_IDCalPagoD_seq" OWNER TO postgres;

--
-- TOC entry 3379 (class 0 OID 0)
-- Dependencies: 179
-- Name: CalPagoD_IDCalPagoD_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "CalPagoD_IDCalPagoD_seq" OWNED BY calpagod.id;


--
-- TOC entry 180 (class 1259 OID 26141)
-- Dependencies: 2378 9
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
-- TOC entry 3380 (class 0 OID 0)
-- Dependencies: 180
-- Name: TABLE calpago; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE calpago IS 'Tabla con los calendarios de pagos de los diferentes tipos de contribuyentes por año';


--
-- TOC entry 3381 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN calpago.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpago.id IS 'Identificador del calendario de pagos';


--
-- TOC entry 3382 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN calpago.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpago.nombre IS 'Nombre del calendario';


--
-- TOC entry 3383 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN calpago.ano; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpago.ano IS 'Año vigencia del calendario';


--
-- TOC entry 3384 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN calpago.tipegravid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpago.tipegravid IS 'Identificador del tipo de periodo gravable';


--
-- TOC entry 3385 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN calpago.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpago.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3386 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN calpago.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN calpago.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 181 (class 1259 OID 26145)
-- Dependencies: 180 9
-- Name: CalPagos_IDCalPago_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE "CalPagos_IDCalPago_seq"
    START WITH 1
    INCREMENT BY 1
    MINVALUE 0
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos."CalPagos_IDCalPago_seq" OWNER TO postgres;

--
-- TOC entry 3387 (class 0 OID 0)
-- Dependencies: 181
-- Name: CalPagos_IDCalPago_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "CalPagos_IDCalPago_seq" OWNED BY calpago.id;


--
-- TOC entry 182 (class 1259 OID 26147)
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
-- TOC entry 3388 (class 0 OID 0)
-- Dependencies: 182
-- Name: TABLE cargos; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE cargos IS 'Tabla con los distintos cargos de la organizacion';


--
-- TOC entry 3389 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN cargos.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN cargos.id IS 'Identificador unico del cargo';


--
-- TOC entry 3390 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN cargos.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN cargos.nombre IS 'Nombre del cargo';


--
-- TOC entry 3391 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN cargos.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN cargos.usuarioid IS 'Identificador del usuario que creo el registro o del ultimo en modificarlo';


--
-- TOC entry 3392 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN cargos.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN cargos.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 183 (class 1259 OID 26153)
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
-- TOC entry 3393 (class 0 OID 0)
-- Dependencies: 183
-- Name: Cargos_IDCargo_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "Cargos_IDCargo_seq" OWNED BY cargos.id;


--
-- TOC entry 184 (class 1259 OID 26155)
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
-- TOC entry 3394 (class 0 OID 0)
-- Dependencies: 184
-- Name: TABLE ciudades; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE ciudades IS 'Tabla con las ciudades por estado geografico';


--
-- TOC entry 3395 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN ciudades.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN ciudades.id IS 'Idenficador unico de la ciudad';


--
-- TOC entry 3396 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN ciudades.estadoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN ciudades.estadoid IS 'Identificador del estado';


--
-- TOC entry 3397 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN ciudades.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN ciudades.nombre IS 'Nombre de la ciudad';


--
-- TOC entry 3398 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN ciudades.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN ciudades.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3399 (class 0 OID 0)
-- Dependencies: 184
-- Name: COLUMN ciudades.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN ciudades.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 185 (class 1259 OID 26158)
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
-- TOC entry 3400 (class 0 OID 0)
-- Dependencies: 185
-- Name: Ciudades_IDCiudad_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "Ciudades_IDCiudad_seq" OWNED BY ciudades.id;


--
-- TOC entry 186 (class 1259 OID 26160)
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
-- TOC entry 3401 (class 0 OID 0)
-- Dependencies: 186
-- Name: TABLE conusuco; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE conusuco IS 'Tabla con la relacion entre usuarios y a los contribuyentes que representan';


--
-- TOC entry 3402 (class 0 OID 0)
-- Dependencies: 186
-- Name: COLUMN conusuco.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuco.id IS 'Identificador unico de registro';


--
-- TOC entry 3403 (class 0 OID 0)
-- Dependencies: 186
-- Name: COLUMN conusuco.conusuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuco.conusuid IS 'Identificador del usuario';


--
-- TOC entry 3404 (class 0 OID 0)
-- Dependencies: 186
-- Name: COLUMN conusuco.contribuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuco.contribuid IS 'Identificador del contribuyente';


--
-- TOC entry 187 (class 1259 OID 26163)
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
-- TOC entry 3405 (class 0 OID 0)
-- Dependencies: 187
-- Name: ConUsuCo_IDConUsuCo_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "ConUsuCo_IDConUsuCo_seq" OWNED BY conusuco.id;


--
-- TOC entry 188 (class 1259 OID 26165)
-- Dependencies: 2383 2384 2385 9
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
-- TOC entry 3406 (class 0 OID 0)
-- Dependencies: 188
-- Name: TABLE conusuti; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE conusuti IS 'Tabla con los tipos de usuarios de los contribuyentes';


--
-- TOC entry 3407 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN conusuti.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuti.id IS 'Identificador unico del tipo de usuario de contribuyentes';


--
-- TOC entry 3408 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN conusuti.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuti.nombre IS 'Nombre del tipo de usuario';


--
-- TOC entry 3409 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN conusuti.administra; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuti.administra IS 'Si el tipo de usuario (perfil) administra la cuenta del contribuyente. Crea usuarios, elimina usuarios';


--
-- TOC entry 3410 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN conusuti.liquida; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuti.liquida IS 'Si el tipo de usuario (perfil) liquida planillas de autoliquidacion en la cuenta del contribuyente.';


--
-- TOC entry 3411 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN conusuti.visualiza; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuti.visualiza IS 'Si el tipo de usuario (perfil) solo visualiza datos  de la cuenta del contribuyente.';


--
-- TOC entry 3412 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN conusuti.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuti.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3413 (class 0 OID 0)
-- Dependencies: 188
-- Name: COLUMN conusuti.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuti.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 189 (class 1259 OID 26171)
-- Dependencies: 188 9
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
-- TOC entry 3414 (class 0 OID 0)
-- Dependencies: 189
-- Name: ConUsuTi_IDConUsuTi_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "ConUsuTi_IDConUsuTi_seq" OWNED BY conusuti.id;


--
-- TOC entry 190 (class 1259 OID 26173)
-- Dependencies: 2387 2388 9
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
-- TOC entry 3415 (class 0 OID 0)
-- Dependencies: 190
-- Name: TABLE conusuto; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE conusuto IS 'Tabla con los Tokens activos por usuario, es Tokens se utilizaran para validad la creacion de usuarios, recuperacion de contraseñas, etc.';


--
-- TOC entry 3416 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN conusuto.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuto.id IS 'Idendificador unico del token';


--
-- TOC entry 3417 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN conusuto.token; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuto.token IS 'Token generado';


--
-- TOC entry 3418 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN conusuto.conusuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuto.conusuid IS 'Identificador del usuario dueño del token';


--
-- TOC entry 3419 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN conusuto.fechacrea; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuto.fechacrea IS 'Fecha hora de creacion del token';


--
-- TOC entry 3420 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN conusuto.fechacadu; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuto.fechacadu IS 'Fecha hora de caducidad del token';


--
-- TOC entry 3421 (class 0 OID 0)
-- Dependencies: 190
-- Name: COLUMN conusuto.usado; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusuto.usado IS 'Si el token fue usado por el usuario o no';


--
-- TOC entry 191 (class 1259 OID 26181)
-- Dependencies: 190 9
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
-- TOC entry 3422 (class 0 OID 0)
-- Dependencies: 191
-- Name: ConUsuTo_IDConUsuTo_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "ConUsuTo_IDConUsuTo_seq" OWNED BY conusuto.id;


--
-- TOC entry 192 (class 1259 OID 26183)
-- Dependencies: 2390 2391 2392 2393 9
-- Name: conusu; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE conusu (
    id integer NOT NULL,
    login character varying(200) NOT NULL,
    password character varying(100) NOT NULL,
    nombre character varying(100) NOT NULL,
    inactivo boolean DEFAULT true NOT NULL,
    conusutiid integer,
    email character varying(100) NOT NULL,
    pregsecrid integer,
    respuesta character varying(100),
    ultlogin timestamp without time zone,
    usuarioid integer,
    ip character varying(15) NOT NULL,
    rif character varying(20) NOT NULL,
    validado boolean DEFAULT false NOT NULL,
    fecha_registro date DEFAULT now(),
    correo_enviado boolean DEFAULT false
);


ALTER TABLE datos.conusu OWNER TO postgres;

--
-- TOC entry 3423 (class 0 OID 0)
-- Dependencies: 192
-- Name: TABLE conusu; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE conusu IS 'Tabla con los datos de los usuarios por contribuyente';


--
-- TOC entry 3424 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.id IS 'Identificador del usuario del contribuyente';


--
-- TOC entry 3425 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.login; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.login IS 'Login de usuario. este campo es unico y es identificado un el rif del contribuyente';


--
-- TOC entry 3426 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.password; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.password IS 'Hash del pasword para hacer login';


--
-- TOC entry 3427 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.nombre IS 'Nombre del usuario. Este es el nombre que se muestra';


--
-- TOC entry 3428 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.inactivo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.inactivo IS 'Si el usuario esta inactivo o no. False=No / True=Si';


--
-- TOC entry 3429 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.conusutiid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.conusutiid IS 'Identificador del tipo de usuario de contribuyentes';


--
-- TOC entry 3430 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.email; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.email IS 'Direccion de email del usuario, se utilizara para validar la cuenta';


--
-- TOC entry 3431 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.pregsecrid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.pregsecrid IS 'Identificador de la pregunta secreta seleccionada por en usuario';


--
-- TOC entry 3432 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.respuesta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.respuesta IS 'Hash con la respuesta a la pregunta secreta';


--
-- TOC entry 3433 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.ultlogin; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.ultlogin IS 'Fecha y hora de la ultima vez que el usuario hizo login';


--
-- TOC entry 3434 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3435 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN conusu.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 193 (class 1259 OID 26193)
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
-- TOC entry 3436 (class 0 OID 0)
-- Dependencies: 193
-- Name: ConUsu_IDConUsu_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "ConUsu_IDConUsu_seq" OWNED BY conusu.id;


--
-- TOC entry 194 (class 1259 OID 26195)
-- Dependencies: 2395 2396 2397 2398 2399 9
-- Name: contribu; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE contribu (
    id integer NOT NULL,
    razonsocia character varying(350) NOT NULL,
    dencomerci character varying(200) NOT NULL,
    actieconid integer,
    rif character varying(20) NOT NULL,
    numregcine integer DEFAULT 0,
    domfiscal character varying(500) NOT NULL,
    estadoid integer NOT NULL,
    ciudadid integer,
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
    rmnumero character varying(20),
    rmfolio character varying(200) NOT NULL,
    rmtomo character varying(200) NOT NULL,
    rmfechapro date NOT NULL,
    rmncontrol character varying(200) NOT NULL,
    rmobjeto text,
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
-- TOC entry 3437 (class 0 OID 0)
-- Dependencies: 194
-- Name: TABLE contribu; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE contribu IS 'Tabla con los datos de los contribuyentes de la institución';


--
-- TOC entry 3438 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.id IS 'Identificador unico del contribuyente';


--
-- TOC entry 3439 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.razonsocia; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.razonsocia IS 'Razon social del contribuyente';


--
-- TOC entry 3440 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.dencomerci; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.dencomerci IS 'Denominacion comercial del contribuyente';


--
-- TOC entry 3441 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.actieconid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.actieconid IS 'Identificador de la actividad economica';


--
-- TOC entry 3442 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.rif; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.rif IS 'Rif del contribuyente';


--
-- TOC entry 3443 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.numregcine; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.numregcine IS 'Numero de registro cinematografico';


--
-- TOC entry 3444 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.domfiscal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.domfiscal IS 'Domicilio fiscal del contribuyente';


--
-- TOC entry 3445 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.estadoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.estadoid IS 'Identicador del estado geografico';


--
-- TOC entry 3446 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.ciudadid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.ciudadid IS 'Identificador de la ciudad';


--
-- TOC entry 3447 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.zonapostal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.zonapostal IS 'Zona postal del contribuyente';


--
-- TOC entry 3448 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.telef1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.telef1 IS 'Telefono 1 del contribuyente';


--
-- TOC entry 3449 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.telef2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.telef2 IS 'Telefono 2 del contribuyente';


--
-- TOC entry 3450 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.telef3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.telef3 IS 'Telefono 3 del contribuyente';


--
-- TOC entry 3451 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.fax1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.fax1 IS 'Fax 1 del contribuyente';


--
-- TOC entry 3452 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.fax2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.fax2 IS 'Fax 2 del contribuyente';


--
-- TOC entry 3453 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.email; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.email IS 'Direccion de email de contribuyente';


--
-- TOC entry 3454 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.pinbb; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.pinbb IS 'Pin de BlackBerry';


--
-- TOC entry 3455 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.skype; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.skype IS 'Dirección de skype';


--
-- TOC entry 3456 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.twitter; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.twitter IS 'Direccion de twitter';


--
-- TOC entry 3457 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.facebook; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.facebook IS 'Direccion de facebook';


--
-- TOC entry 3458 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.nuacciones; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.nuacciones IS 'Numero de acciones del contribuyente segun inforacion del registro mercantil';


--
-- TOC entry 3459 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.valaccion; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.valaccion IS 'Valor nominal por accion segun registro mercantil';


--
-- TOC entry 3460 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.capitalsus; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.capitalsus IS 'Capital suscrito segun registro mercantil';


--
-- TOC entry 3461 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.capitalpag; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.capitalpag IS 'Capital pagado segun registro mercantil';


--
-- TOC entry 3462 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.regmerofc; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.regmerofc IS 'Oficina de registro mercantil en donde se registro la empresa';


--
-- TOC entry 3463 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.rmnumero; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.rmnumero IS 'Numero de registro del documento de registro mercantil';


--
-- TOC entry 3464 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.rmfolio; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.rmfolio IS 'Numero de folio del documento de registro mercantil';


--
-- TOC entry 3465 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.rmtomo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.rmtomo IS 'Numero de folio del documento de registro mercantil';


--
-- TOC entry 3466 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.rmfechapro; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.rmfechapro IS 'Fecha de protocololizacion del registro del documento de registro mercantil';


--
-- TOC entry 3467 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.rmncontrol; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.rmncontrol IS 'Numero de control del documento de registro mercantil';


--
-- TOC entry 3468 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.rmobjeto; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.rmobjeto IS 'Objeto de la empresa segun registro mercantil';


--
-- TOC entry 3469 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.domcomer; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.domcomer IS 'domicilio comercial';


--
-- TOC entry 3470 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.cextra1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.cextra1 IS 'Campo extra 1';


--
-- TOC entry 3471 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.cextra2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.cextra2 IS 'Campo extra 2';


--
-- TOC entry 3472 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.cextra3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.cextra3 IS 'Campo extra 3';


--
-- TOC entry 3473 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.cextra4; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.cextra4 IS 'Campo extra 4';


--
-- TOC entry 3474 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.cextra5; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.cextra5 IS 'Campo extra 5';


--
-- TOC entry 3475 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.usuarioid IS 'identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3476 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN contribu.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contribu.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 195 (class 1259 OID 26206)
-- Dependencies: 194 9
-- Name: Contribu_IDContribu_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE "Contribu_IDContribu_seq"
    START WITH 1
    INCREMENT BY 1
    MINVALUE 0
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos."Contribu_IDContribu_seq" OWNER TO postgres;

--
-- TOC entry 3477 (class 0 OID 0)
-- Dependencies: 195
-- Name: Contribu_IDContribu_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "Contribu_IDContribu_seq" OWNED BY contribu.id;


--
-- TOC entry 196 (class 1259 OID 26208)
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
-- TOC entry 3478 (class 0 OID 0)
-- Dependencies: 196
-- Name: TABLE declara_viejo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE declara_viejo IS 'Planilla de declaracion de impuestos';


--
-- TOC entry 3479 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.id IS 'Identificador unico de la declaracion de impuestos';


--
-- TOC entry 3480 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.nudeclara; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.nudeclara IS 'Numero de planilla de declaracion de impuesto';


--
-- TOC entry 3481 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.nudeposito; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.nudeposito IS 'Numero de deposito bancario generado por el sistema';


--
-- TOC entry 3482 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.tdeclaraid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.tdeclaraid IS 'Identificador del tipo de declaracion';


--
-- TOC entry 3483 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.fechaelab; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.fechaelab IS 'Fecha de elaboracion de la planilla de pago de impuestos';


--
-- TOC entry 3484 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.fechaini; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.fechaini IS 'Fecha de inicio del periodo gravable';


--
-- TOC entry 3485 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.fechafin; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.fechafin IS 'Fecha final del periodo gravable';


--
-- TOC entry 3486 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.replegalid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.replegalid IS 'Identificador del representante legal que aparecera en la planilla y firmara la misma';


--
-- TOC entry 3487 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.baseimpo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.baseimpo IS 'Base imponible';


--
-- TOC entry 3488 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.alicuota; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.alicuota IS 'Alicuota impositiva aplicada a la declaracion de impuesto';


--
-- TOC entry 3489 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.exonera; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.exonera IS 'Exoneracion o rebaja';


--
-- TOC entry 3490 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.nuactoexon; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.nuactoexon IS 'Numero de acto en donde se establece la exoneracion o rebaja';


--
-- TOC entry 3491 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.credfiscal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.credfiscal IS 'Credito fiscal';


--
-- TOC entry 3492 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.contribant; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.contribant IS 'Monto de la contribucion pagada en periodos anteriores';


--
-- TOC entry 3493 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.plasustid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.plasustid IS 'Identificador de la planilla que se esta sustituyendo en caso de ser una declaracion sustitutiva';


--
-- TOC entry 3494 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.nuresactfi; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.nuresactfi IS 'Numero de resolucion o numero de acta fiscal';


--
-- TOC entry 3495 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.fechanoti; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.fechanoti IS 'Fecha de notificacion';


--
-- TOC entry 3496 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.intemora; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.intemora IS 'Intereses moratorios';


--
-- TOC entry 3497 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.reparofis; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.reparofis IS 'Reparo fiscal';


--
-- TOC entry 3498 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.multa; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.multa IS 'Multa aplicada';


--
-- TOC entry 3499 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.montopagar; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.montopagar IS 'Monto a pagar';


--
-- TOC entry 3500 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.fechapago; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.fechapago IS 'Fecha de pago en el banco. Se llena este campo cuando se concilian los pagos';


--
-- TOC entry 3501 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.fechaconci; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.fechaconci IS 'Fecha hora de la conciliacion contra los depositos del banco';


--
-- TOC entry 3502 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.asientoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.asientoid IS 'Identificador del asiento contable en donde se registro la informacion del pago';


--
-- TOC entry 3503 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.usuarioid IS 'Identificador del usuario que concilio el pago de la declaracion. ';


--
-- TOC entry 3504 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN declara_viejo.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara_viejo.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 197 (class 1259 OID 26219)
-- Dependencies: 9 196
-- Name: Declara_IDDeclara_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE "Declara_IDDeclara_seq"
    START WITH 1
    INCREMENT BY 1
    MINVALUE 0
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos."Declara_IDDeclara_seq" OWNER TO postgres;

--
-- TOC entry 3505 (class 0 OID 0)
-- Dependencies: 197
-- Name: Declara_IDDeclara_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "Declara_IDDeclara_seq" OWNED BY declara_viejo.id;


--
-- TOC entry 198 (class 1259 OID 26221)
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
-- TOC entry 3506 (class 0 OID 0)
-- Dependencies: 198
-- Name: TABLE departam; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE departam IS 'Tabla con los departamentos / gerencia de la organizacion';


--
-- TOC entry 3507 (class 0 OID 0)
-- Dependencies: 198
-- Name: COLUMN departam.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN departam.id IS 'Identificador unico del departamento';


--
-- TOC entry 3508 (class 0 OID 0)
-- Dependencies: 198
-- Name: COLUMN departam.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN departam.nombre IS 'Nombre del departamento o gerencia';


--
-- TOC entry 3509 (class 0 OID 0)
-- Dependencies: 198
-- Name: COLUMN departam.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN departam.usuarioid IS 'Identificador del usuario que creo el registro o del ultimo en modificarlo';


--
-- TOC entry 3510 (class 0 OID 0)
-- Dependencies: 198
-- Name: COLUMN departam.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN departam.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 199 (class 1259 OID 26227)
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
-- TOC entry 3511 (class 0 OID 0)
-- Dependencies: 199
-- Name: Departam_IDDepartam_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "Departam_IDDepartam_seq" OWNED BY departam.id;


--
-- TOC entry 200 (class 1259 OID 26229)
-- Dependencies: 2410 9
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
-- TOC entry 3512 (class 0 OID 0)
-- Dependencies: 200
-- Name: TABLE entidadd; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE entidadd IS 'Tabla con el detalle de las entidades. Acciones y procesos a verificar acceso por entidad';


--
-- TOC entry 3513 (class 0 OID 0)
-- Dependencies: 200
-- Name: COLUMN entidadd.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN entidadd.id IS 'Identificador unico del detalle de la entidad';


--
-- TOC entry 3514 (class 0 OID 0)
-- Dependencies: 200
-- Name: COLUMN entidadd.entidadid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN entidadd.entidadid IS 'Identificador de la entidad a la que pertenece la accion o preceso';


--
-- TOC entry 3515 (class 0 OID 0)
-- Dependencies: 200
-- Name: COLUMN entidadd.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN entidadd.nombre IS 'Nombre de la accion o proceso a mostrar en el arbol de permisos disponibles';


--
-- TOC entry 3516 (class 0 OID 0)
-- Dependencies: 200
-- Name: COLUMN entidadd.accion; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN entidadd.accion IS 'Nombre interno de la accion o proceso';


--
-- TOC entry 3517 (class 0 OID 0)
-- Dependencies: 200
-- Name: COLUMN entidadd.orden; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN entidadd.orden IS 'Orden en que apareceran las acciones y/o procesos dentro del arbol de una entidad';


--
-- TOC entry 201 (class 1259 OID 26233)
-- Dependencies: 200 9
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
-- TOC entry 3518 (class 0 OID 0)
-- Dependencies: 201
-- Name: EntidadD_IDEntidadD_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "EntidadD_IDEntidadD_seq" OWNED BY entidadd.id;


--
-- TOC entry 202 (class 1259 OID 26235)
-- Dependencies: 2412 9
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
-- TOC entry 3519 (class 0 OID 0)
-- Dependencies: 202
-- Name: TABLE entidad; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE entidad IS 'Tabla con las entidades del sistema';


--
-- TOC entry 3520 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN entidad.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN entidad.id IS 'Identificador de la entidad';


--
-- TOC entry 3521 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN entidad.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN entidad.nombre IS 'Nombre de la entidad a mostrar en el arbol de permisos disponibles';


--
-- TOC entry 3522 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN entidad.entidad; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN entidad.entidad IS 'Nombre interno de la entidad';


--
-- TOC entry 3523 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN entidad.orden; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN entidad.orden IS 'Orden en la que apareceran la entidades en el arbol de permisos de usuarios';


--
-- TOC entry 203 (class 1259 OID 26239)
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
-- TOC entry 3524 (class 0 OID 0)
-- Dependencies: 203
-- Name: Entidad_IDEntidad_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "Entidad_IDEntidad_seq" OWNED BY entidad.id;


--
-- TOC entry 204 (class 1259 OID 26241)
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
-- TOC entry 3525 (class 0 OID 0)
-- Dependencies: 204
-- Name: TABLE estados; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE estados IS 'Tabla con los estados geográficos';


--
-- TOC entry 3526 (class 0 OID 0)
-- Dependencies: 204
-- Name: COLUMN estados.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN estados.id IS 'Identificador unico del estado';


--
-- TOC entry 3527 (class 0 OID 0)
-- Dependencies: 204
-- Name: COLUMN estados.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN estados.nombre IS 'Nombre del estado geografico';


--
-- TOC entry 3528 (class 0 OID 0)
-- Dependencies: 204
-- Name: COLUMN estados.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN estados.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3529 (class 0 OID 0)
-- Dependencies: 204
-- Name: COLUMN estados.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN estados.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 205 (class 1259 OID 26244)
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
-- TOC entry 3530 (class 0 OID 0)
-- Dependencies: 205
-- Name: Estados_IDEstado_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "Estados_IDEstado_seq" OWNED BY estados.id;


--
-- TOC entry 206 (class 1259 OID 26246)
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
-- TOC entry 3531 (class 0 OID 0)
-- Dependencies: 206
-- Name: TABLE perusud; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE perusud IS 'Tabla con los datos del detalle de los perfiles de usuario. Detalles de entidades habilitadas para el perfil seleccionado';


--
-- TOC entry 3532 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN perusud.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN perusud.id IS 'Identificador unico del detalle de perfil de usuario';


--
-- TOC entry 3533 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN perusud.perusuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN perusud.perusuid IS 'Identificador del perfil al cual pertenece el detalle (accion o proceso permisado)';


--
-- TOC entry 3534 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN perusud.entidaddid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN perusud.entidaddid IS 'Identificador de la accion o proceso permisado (detalles de las entidades)';


--
-- TOC entry 3535 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN perusud.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN perusud.usuarioid IS 'Identificador del usuario que creo el registro o el ultimo en modificarlo';


--
-- TOC entry 3536 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN perusud.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN perusud.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 207 (class 1259 OID 26249)
-- Dependencies: 9 206
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
-- TOC entry 3537 (class 0 OID 0)
-- Dependencies: 207
-- Name: PerUsuD_IDPerUsuD_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "PerUsuD_IDPerUsuD_seq" OWNED BY perusud.id;


--
-- TOC entry 208 (class 1259 OID 26251)
-- Dependencies: 2416 9
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
-- TOC entry 3538 (class 0 OID 0)
-- Dependencies: 208
-- Name: TABLE perusu; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE perusu IS 'Tabla con los perfiles de usuarios';


--
-- TOC entry 3539 (class 0 OID 0)
-- Dependencies: 208
-- Name: COLUMN perusu.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN perusu.id IS 'Identificador del perfl de usuario';


--
-- TOC entry 3540 (class 0 OID 0)
-- Dependencies: 208
-- Name: COLUMN perusu.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN perusu.nombre IS 'Nombre del perfil de usuario';


--
-- TOC entry 3541 (class 0 OID 0)
-- Dependencies: 208
-- Name: COLUMN perusu.inactivo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN perusu.inactivo IS 'Si el pelfil de usuario esta Inactivo o no';


--
-- TOC entry 3542 (class 0 OID 0)
-- Dependencies: 208
-- Name: COLUMN perusu.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN perusu.usuarioid IS 'Identificador de usuario que creo o el ultimo que actualizo el registro';


--
-- TOC entry 3543 (class 0 OID 0)
-- Dependencies: 208
-- Name: COLUMN perusu.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN perusu.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 209 (class 1259 OID 26255)
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
-- TOC entry 3544 (class 0 OID 0)
-- Dependencies: 209
-- Name: PerUsu_IDPerUsu_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "PerUsu_IDPerUsu_seq" OWNED BY perusu.id;


--
-- TOC entry 210 (class 1259 OID 26257)
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
-- TOC entry 3545 (class 0 OID 0)
-- Dependencies: 210
-- Name: TABLE pregsecr; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE pregsecr IS 'Tablas con las preguntas secretas validas para la recuperacion de contraseñas';


--
-- TOC entry 3546 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN pregsecr.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN pregsecr.id IS 'Identificador unico de la pregunta secreta';


--
-- TOC entry 3547 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN pregsecr.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN pregsecr.nombre IS 'Texto de la pregunta secreta';


--
-- TOC entry 3548 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN pregsecr.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN pregsecr.usuarioid IS 'Identificado del ultimo usuario que creo o actualizo el registro';


--
-- TOC entry 3549 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN pregsecr.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN pregsecr.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 211 (class 1259 OID 26260)
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
-- TOC entry 3550 (class 0 OID 0)
-- Dependencies: 211
-- Name: PregSecr_IDPregSecr_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "PregSecr_IDPregSecr_seq" OWNED BY pregsecr.id;


--
-- TOC entry 212 (class 1259 OID 26262)
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
    ciudadid integer,
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
-- TOC entry 3551 (class 0 OID 0)
-- Dependencies: 212
-- Name: TABLE replegal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE replegal IS 'Tabla con los datos de los Accionistas de los contribuyentes';


--
-- TOC entry 3552 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.id IS 'Identificador unico del representante legal';


--
-- TOC entry 3553 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.contribuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.contribuid IS 'Identificador del contribuyente';


--
-- TOC entry 3554 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.nombre IS 'Nombre del representante legal';


--
-- TOC entry 3555 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.apellido; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.apellido IS 'Apellidos del representante legal';


--
-- TOC entry 3556 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.ci; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.ci IS 'Cedula de identidad, numero de pasaporte';


--
-- TOC entry 3557 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.domfiscal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.domfiscal IS 'Domicilio fiscal del representante legal';


--
-- TOC entry 3558 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.estadoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.estadoid IS 'Identificador del estado geografico';


--
-- TOC entry 3559 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.ciudadid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.ciudadid IS 'Identificador de la ciudad';


--
-- TOC entry 3560 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.zonaposta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.zonaposta IS 'Zona postal';


--
-- TOC entry 3561 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.telefhab; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.telefhab IS 'Telefono de habitacion del representante legal';


--
-- TOC entry 3562 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.telefofc; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.telefofc IS 'Telefono de oficina del representante legal';


--
-- TOC entry 3563 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.fax; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.fax IS 'Fax del representante legal';


--
-- TOC entry 3564 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.email; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.email IS 'Direccion de email del contribuyente';


--
-- TOC entry 3565 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.pinbb; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.pinbb IS 'Pin de BlackBerry';


--
-- TOC entry 3566 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.skype; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.skype IS 'Direccion de skype del representante legal';


--
-- TOC entry 3567 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.cextra1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.cextra1 IS 'Campo extra 1';


--
-- TOC entry 3568 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.cextra2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.cextra2 IS 'Campo extra 2';


--
-- TOC entry 3569 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.cextra3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.cextra3 IS 'Campo extra 3';


--
-- TOC entry 3570 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.cextra4; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.cextra4 IS 'Campo extra 4';


--
-- TOC entry 3571 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.cextra5; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.cextra5 IS 'Campo extra 5';


--
-- TOC entry 3572 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3573 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN replegal.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN replegal.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 213 (class 1259 OID 26268)
-- Dependencies: 9 212
-- Name: RepLegal_IDRepLegal_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE "RepLegal_IDRepLegal_seq"
    START WITH 1
    INCREMENT BY 1
    MINVALUE 0
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos."RepLegal_IDRepLegal_seq" OWNER TO postgres;

--
-- TOC entry 3574 (class 0 OID 0)
-- Dependencies: 213
-- Name: RepLegal_IDRepLegal_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "RepLegal_IDRepLegal_seq" OWNED BY replegal.id;


--
-- TOC entry 214 (class 1259 OID 26270)
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
-- TOC entry 3575 (class 0 OID 0)
-- Dependencies: 214
-- Name: TABLE tdeclara; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE tdeclara IS 'Tipo de declaracion de impuestos';


--
-- TOC entry 3576 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN tdeclara.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tdeclara.id IS 'Identificador unico de registro';


--
-- TOC entry 3577 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN tdeclara.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tdeclara.nombre IS 'Nombre del tipo de declaracion de impuesto. Ejm. Autoliquidacion, Sustitutiva, etc';


--
-- TOC entry 3578 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN tdeclara.tipo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tdeclara.tipo IS 'Tipo de declaracion a efectuar. Utilizamos este campo para activar/desactivar la seccion correspondiente a los datos de la liquidacion en la planilla de pago de impuestos.
0 = Autoliquidación / Sustitutiva
1 = Multa por pago extemporaneo / Reparo fiscal
2 = Multa
3 = Intereses Moratorios';


--
-- TOC entry 3579 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN tdeclara.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tdeclara.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro.';


--
-- TOC entry 3580 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN tdeclara.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tdeclara.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 215 (class 1259 OID 26273)
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
-- TOC entry 3581 (class 0 OID 0)
-- Dependencies: 215
-- Name: TDeclara_IDTDeclara_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "TDeclara_IDTDeclara_seq" OWNED BY tdeclara.id;


--
-- TOC entry 216 (class 1259 OID 26275)
-- Dependencies: 2421 2422 9
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
-- TOC entry 3582 (class 0 OID 0)
-- Dependencies: 216
-- Name: TABLE tipegrav; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE tipegrav IS 'Tabla con los tipos de períodos gravables';


--
-- TOC entry 3583 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN tipegrav.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipegrav.id IS 'Identificador del tipo de periodo gravable';


--
-- TOC entry 3584 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN tipegrav.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipegrav.nombre IS 'Nombre del tipo de período gravable. Ejm. Mensual, trimestral, anual';


--
-- TOC entry 3585 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN tipegrav.tipe; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipegrav.tipe IS 'Tipo de periodo. 0=Mensual / 1=Trimestral / 2=Anual';


--
-- TOC entry 3586 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN tipegrav.peano; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipegrav.peano IS 'Numero de periodos gravables en año fiscal';


--
-- TOC entry 3587 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN tipegrav.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipegrav.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3588 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN tipegrav.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipegrav.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 217 (class 1259 OID 26280)
-- Dependencies: 9 216
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
-- TOC entry 3589 (class 0 OID 0)
-- Dependencies: 217
-- Name: TiPeGrav_IDTiPeGrav_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "TiPeGrav_IDTiPeGrav_seq" OWNED BY tipegrav.id;


--
-- TOC entry 218 (class 1259 OID 26282)
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
-- TOC entry 3590 (class 0 OID 0)
-- Dependencies: 218
-- Name: TABLE tipocont; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE tipocont IS 'Tabla con los tipos de contribuyentes';


--
-- TOC entry 3591 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN tipocont.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipocont.id IS 'Identificador unico del tipo de contribuyente';


--
-- TOC entry 3592 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN tipocont.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipocont.nombre IS 'Nombre o descripción del tipo de contribuyente. Ejm Exibidores cinematográficos';


--
-- TOC entry 3593 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN tipocont.tipegravid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipocont.tipegravid IS 'Identificador del tipo de periodo gravable';


--
-- TOC entry 3594 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN tipocont.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipocont.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3595 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN tipocont.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tipocont.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 219 (class 1259 OID 26288)
-- Dependencies: 9 218
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
-- TOC entry 3596 (class 0 OID 0)
-- Dependencies: 219
-- Name: TipoCont_IDTipoCont_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "TipoCont_IDTipoCont_seq" OWNED BY tipocont.id;


--
-- TOC entry 220 (class 1259 OID 26290)
-- Dependencies: 2425 9
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
-- TOC entry 3597 (class 0 OID 0)
-- Dependencies: 220
-- Name: TABLE undtrib; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE undtrib IS 'Tabla con los valores de conversion de las unidades tributarias';


--
-- TOC entry 3598 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN undtrib.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN undtrib.id IS 'Identificador unico de registro';


--
-- TOC entry 3599 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN undtrib.fecha; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN undtrib.fecha IS 'Fecha a partir de la cual esta vigente el valor de la unidad tributaria';


--
-- TOC entry 3600 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN undtrib.valor; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN undtrib.valor IS 'Valor en Bs de una unidad tributaria';


--
-- TOC entry 3601 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN undtrib.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN undtrib.usuarioid IS 'Identificador del ultimo usuario que creo o modifico un registro';


--
-- TOC entry 3602 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN undtrib.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN undtrib.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 221 (class 1259 OID 26294)
-- Dependencies: 220 9
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
-- TOC entry 3603 (class 0 OID 0)
-- Dependencies: 221
-- Name: UndTrib_IDUndTrib_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "UndTrib_IDUndTrib_seq" OWNED BY undtrib.id;


--
-- TOC entry 222 (class 1259 OID 26296)
-- Dependencies: 2427 9
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
-- TOC entry 3604 (class 0 OID 0)
-- Dependencies: 222
-- Name: TABLE usfonpto; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE usfonpto IS 'Tabla con los Tokens activos por usuario Fonprocine, es Tokens se utilizaran para validad la creacion de usuarios, recuperacion de contraseñas, etc.';


--
-- TOC entry 3605 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN usfonpto.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpto.id IS 'Identificador unico del Token';


--
-- TOC entry 3606 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN usfonpto.token; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpto.token IS 'Token generado';


--
-- TOC entry 3607 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN usfonpto.usfonproid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpto.usfonproid IS 'Identificador del usuario de fonprocine';


--
-- TOC entry 3608 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN usfonpto.fechacrea; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpto.fechacrea IS 'Fecha hora creacion del token';


--
-- TOC entry 3609 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN usfonpto.fechacadu; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpto.fechacadu IS 'Fecha hora caducidad del token';


--
-- TOC entry 3610 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN usfonpto.usado; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpto.usado IS 'Si el token fue usuario por el usuario o no';


--
-- TOC entry 223 (class 1259 OID 26303)
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
-- TOC entry 3611 (class 0 OID 0)
-- Dependencies: 223
-- Name: UsFonpTo_IDUsFonpTo_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "UsFonpTo_IDUsFonpTo_seq" OWNED BY usfonpto.id;


--
-- TOC entry 224 (class 1259 OID 26305)
-- Dependencies: 2429 2430 2431 9
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
    ingreso_sistema boolean DEFAULT false,
    bln_borrado boolean DEFAULT false
);


ALTER TABLE datos.usfonpro OWNER TO postgres;

--
-- TOC entry 3612 (class 0 OID 0)
-- Dependencies: 224
-- Name: TABLE usfonpro; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE usfonpro IS 'Tabla con los datos de los usuarios de la organizacion';


--
-- TOC entry 3613 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.id IS 'Identificador unico de usuario';


--
-- TOC entry 3614 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.login; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.login IS 'Login de usuario';


--
-- TOC entry 3615 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.password; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.password IS 'Passwrod de usuario';


--
-- TOC entry 3616 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.nombre IS 'Nombre del usuario';


--
-- TOC entry 3617 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.email; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.email IS 'Email del usuario';


--
-- TOC entry 3618 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.telefofc; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.telefofc IS 'Telefono de oficina';


--
-- TOC entry 3619 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.extension; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.extension IS 'Extension telefonica';


--
-- TOC entry 3620 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.departamid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.departamid IS 'Identificador del departamento al que pertenece el usuario';


--
-- TOC entry 3621 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.cargoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.cargoid IS 'Identificador del cargo del usuario';


--
-- TOC entry 3622 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.inactivo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.inactivo IS 'Si el usuario esta inactivo o no';


--
-- TOC entry 3623 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.pregsecrid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.pregsecrid IS 'Identificador de la pregunta secreta';


--
-- TOC entry 3624 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.respuesta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.respuesta IS 'Hash de la respuesta a la pregunta secreta';


--
-- TOC entry 3625 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.perusuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.perusuid IS 'Identificador del perfil de usuario';


--
-- TOC entry 3626 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.ultlogin; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.ultlogin IS 'Fecha hora del login del usuario al sistema';


--
-- TOC entry 3627 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.usuarioid IS 'Identificador del usuario que creo el registro o del ultimo que lo modifico';


--
-- TOC entry 3628 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN usfonpro.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN usfonpro.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 225 (class 1259 OID 26314)
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
-- TOC entry 3629 (class 0 OID 0)
-- Dependencies: 225
-- Name: Usuarios_IDUsuario_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE "Usuarios_IDUsuario_seq" OWNED BY usfonpro.id;


--
-- TOC entry 226 (class 1259 OID 26316)
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
-- TOC entry 3630 (class 0 OID 0)
-- Dependencies: 226
-- Name: TABLE accionis; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE accionis IS 'Tabla con los datos de los Accionistas de los contribuyentes';


--
-- TOC entry 3631 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.id IS 'Identificador unico del accionista';


--
-- TOC entry 3632 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.contribuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.contribuid IS 'Identificador del contribuyente';


--
-- TOC entry 3633 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.nombre IS 'Nombre del accionista';


--
-- TOC entry 3634 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.apellido; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.apellido IS 'Apellidos del accionista';


--
-- TOC entry 3635 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.ci; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.ci IS 'Cedula de identidad, numero de pasaporte';


--
-- TOC entry 3636 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.domfiscal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.domfiscal IS 'Domicilio fiscal del accionista';


--
-- TOC entry 3637 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.nuacciones; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.nuacciones IS 'Numero de acciones';


--
-- TOC entry 3638 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.valaccion; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.valaccion IS 'Valor nominal de las acciones';


--
-- TOC entry 3639 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.cextra1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.cextra1 IS 'Campo extra 1';


--
-- TOC entry 3640 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.cextra2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.cextra2 IS 'Campo extra 2';


--
-- TOC entry 3641 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.cextra3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.cextra3 IS 'Campo extra 3';


--
-- TOC entry 3642 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.cextra4; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.cextra4 IS 'Campo extra 4';


--
-- TOC entry 3643 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.cextra5; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.cextra5 IS 'Campo extra 5';


--
-- TOC entry 3644 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3645 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN accionis.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN accionis.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 227 (class 1259 OID 26325)
-- Dependencies: 2436 2437 9
-- Name: actas_reparo; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE actas_reparo (
    id integer NOT NULL,
    numero character varying,
    ruta_servidor character varying,
    fecha_adjunto timestamp without time zone DEFAULT now() NOT NULL,
    usuarioid integer,
    ip character varying,
    bln_conformida boolean DEFAULT false NOT NULL
);


ALTER TABLE datos.actas_reparo OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 26333)
-- Dependencies: 9 227
-- Name: actas_reparo_id_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE actas_reparo_id_seq
    START WITH 1
    INCREMENT BY 1
    MINVALUE 0
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos.actas_reparo_id_seq OWNER TO postgres;

--
-- TOC entry 3646 (class 0 OID 0)
-- Dependencies: 228
-- Name: actas_reparo_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE actas_reparo_id_seq OWNED BY actas_reparo.id;


--
-- TOC entry 229 (class 1259 OID 26335)
-- Dependencies: 2439 2440 2441 2442 2443 2444 2445 2446 9
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
-- TOC entry 3647 (class 0 OID 0)
-- Dependencies: 229
-- Name: TABLE asiento; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE asiento IS 'Tabla con los datos cabecera de los asiento contable';


--
-- TOC entry 3648 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN asiento.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.id IS 'Identificador unico de registro';


--
-- TOC entry 3649 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN asiento.nuasiento; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.nuasiento IS 'Numero de asiento. Empieza en uno al comienzo de cada mes.

Este valor de este campo lo asigna la base de datos';


--
-- TOC entry 3650 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN asiento.fecha; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.fecha IS 'Fecha del asiento';


--
-- TOC entry 3651 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN asiento.mes; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.mes IS 'Mes del asiento. Lo utilizamos para evitar que se utilice un numero de asiento repetido para un mes/año.

Este valor de este campo lo asigna la base de datos';


--
-- TOC entry 3652 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN asiento.ano; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.ano IS 'Año del asiento. Lo utilizamos para evitar que se utilice un numero de asiento repetido para un mes/año.

Este valor de este campo lo asigna la base de datos';


--
-- TOC entry 3653 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN asiento.debe; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.debe IS 'Sumatoria del debe del asiento.

Este valor de este campo lo asigna la base de datos';


--
-- TOC entry 3654 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN asiento.haber; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.haber IS 'Sumatoria del debe del asiento.

Este valor de este campo lo asigna la base de datos';


--
-- TOC entry 3655 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN asiento.saldo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.saldo IS 'Saldo del asiento.

Este valor de este campo lo asigna la base de datos.';


--
-- TOC entry 3656 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN asiento.comentar; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.comentar IS 'Comentario u observaciones del asiento';


--
-- TOC entry 3657 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN asiento.cerrado; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.cerrado IS 'Si el asiento esta cerrado o no. Solo se pueden cerrar asientos que el saldo sea 0. Un asiento cerrado no puede ser modificado';


--
-- TOC entry 3658 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN asiento.uscierreid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.uscierreid IS 'Identificador del usuario que cerro el asiento';


--
-- TOC entry 3659 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN asiento.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.usuarioid IS 'Identificador del ultimo usuario en crear o modificar el registro';


--
-- TOC entry 3660 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN asiento.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asiento.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 230 (class 1259 OID 26349)
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
-- TOC entry 3661 (class 0 OID 0)
-- Dependencies: 230
-- Name: TABLE asientom; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE asientom IS 'Tabla con los asientos modelos a utilizar';


--
-- TOC entry 3662 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN asientom.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientom.id IS 'Identificador unico de registro';


--
-- TOC entry 3663 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN asientom.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientom.nombre IS 'nombre del asiento modelo';


--
-- TOC entry 3664 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN asientom.comentar; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientom.comentar IS 'Comentarios u observaciones';


--
-- TOC entry 3665 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN asientom.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientom.usuarioid IS 'Identificador del usuario que creo o el ultimo en modificar el registro';


--
-- TOC entry 3666 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN asientom.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientom.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 231 (class 1259 OID 26355)
-- Dependencies: 230 9
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
-- TOC entry 3667 (class 0 OID 0)
-- Dependencies: 231
-- Name: asientom_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE asientom_id_seq OWNED BY asientom.id;


--
-- TOC entry 232 (class 1259 OID 26357)
-- Dependencies: 2448 9
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
-- TOC entry 3668 (class 0 OID 0)
-- Dependencies: 232
-- Name: TABLE asientomd; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE asientomd IS 'Tabla con el detalle de los asientos modelos';


--
-- TOC entry 3669 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN asientomd.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientomd.id IS 'Identificador unico de registro';


--
-- TOC entry 3670 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN asientomd.asientomid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientomd.asientomid IS 'Identificador del asiento';


--
-- TOC entry 3671 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN asientomd.cuenta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientomd.cuenta IS 'Cuenta contable';


--
-- TOC entry 3672 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN asientomd.sentido; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientomd.sentido IS 'Sentido del monto. 0=debe / 1=haber';


--
-- TOC entry 3673 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN asientomd.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientomd.usuarioid IS 'Identificador del usuario que creo el registro o del ultimo en modificarlo';


--
-- TOC entry 3674 (class 0 OID 0)
-- Dependencies: 232
-- Name: COLUMN asientomd.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN asientomd.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 233 (class 1259 OID 26361)
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
-- TOC entry 3675 (class 0 OID 0)
-- Dependencies: 233
-- Name: asientomd_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE asientomd_id_seq OWNED BY asientomd.id;


--
-- TOC entry 234 (class 1259 OID 26363)
-- Dependencies: 2450 2451 9
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
-- TOC entry 235 (class 1259 OID 26371)
-- Dependencies: 234 9
-- Name: asignacion_fiscales_id_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE asignacion_fiscales_id_seq
    START WITH 1
    INCREMENT BY 1
    MINVALUE 0
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos.asignacion_fiscales_id_seq OWNER TO postgres;

--
-- TOC entry 3676 (class 0 OID 0)
-- Dependencies: 235
-- Name: asignacion_fiscales_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE asignacion_fiscales_id_seq OWNED BY asignacion_fiscales.id;


--
-- TOC entry 236 (class 1259 OID 26373)
-- Dependencies: 2453 9
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
-- TOC entry 3677 (class 0 OID 0)
-- Dependencies: 236
-- Name: TABLE con_img_doc; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE con_img_doc IS 'Tabla con las imagenes de los documentos subidos por los contribuyentes adjunto a la planilla de complementaria de datos para el registro.';


--
-- TOC entry 3678 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN con_img_doc.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN con_img_doc.id IS 'Campo principal, valor unico identificador.';


--
-- TOC entry 3679 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN con_img_doc.conusuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN con_img_doc.conusuid IS 'ID  del contribuyente al cual estan asociados los documentos guardados.';


--
-- TOC entry 237 (class 1259 OID 26380)
-- Dependencies: 236 9
-- Name: con_img_doc_id_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE con_img_doc_id_seq
    START WITH 1
    INCREMENT BY 1
    MINVALUE 0
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos.con_img_doc_id_seq OWNER TO postgres;

--
-- TOC entry 3680 (class 0 OID 0)
-- Dependencies: 237
-- Name: con_img_doc_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE con_img_doc_id_seq OWNED BY con_img_doc.id;


--
-- TOC entry 238 (class 1259 OID 26382)
-- Dependencies: 2455 9
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
-- TOC entry 3681 (class 0 OID 0)
-- Dependencies: 238
-- Name: TABLE contrib_calc; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE contrib_calc IS 'Tabla de los contribuyentes a los que se aplicaran calculos';


--
-- TOC entry 3682 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN contrib_calc.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contrib_calc.id IS 'Identificador de los contribuyentes a los que se aplicaran calculos';


--
-- TOC entry 3683 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN contrib_calc.conusuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contrib_calc.conusuid IS 'Identificador de los contribuyentes para capturar su informacion';


--
-- TOC entry 239 (class 1259 OID 26389)
-- Dependencies: 9 238
-- Name: contrib_calc_id_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE contrib_calc_id_seq
    START WITH 1
    INCREMENT BY 1
    MINVALUE 0
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos.contrib_calc_id_seq OWNER TO postgres;

--
-- TOC entry 3684 (class 0 OID 0)
-- Dependencies: 239
-- Name: contrib_calc_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE contrib_calc_id_seq OWNED BY contrib_calc.id;


--
-- TOC entry 240 (class 1259 OID 26391)
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
-- TOC entry 3685 (class 0 OID 0)
-- Dependencies: 240
-- Name: TABLE contributi; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE contributi IS 'tabla con los tipo de contribuyentes por contribuyente';


--
-- TOC entry 3686 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN contributi.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contributi.id IS 'Identificador unico de registro';


--
-- TOC entry 3687 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN contributi.contribuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contributi.contribuid IS 'Id del contribuyente';


--
-- TOC entry 3688 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN contributi.tipocontid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contributi.tipocontid IS 'Identificador del tipo de contribuyente';


--
-- TOC entry 3689 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN contributi.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN contributi.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 241 (class 1259 OID 26394)
-- Dependencies: 9 240
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
-- TOC entry 3690 (class 0 OID 0)
-- Dependencies: 241
-- Name: contributi_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE contributi_id_seq OWNED BY contributi.id;


--
-- TOC entry 242 (class 1259 OID 26396)
-- Dependencies: 2458 2459 2460 9
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
-- TOC entry 3691 (class 0 OID 0)
-- Dependencies: 242
-- Name: TABLE conusu_interno; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE conusu_interno IS 'tabla que contiene el detalle de el reistro echo en conusu cuando este lo halla echo un usuario interno en recaudacion';


--
-- TOC entry 243 (class 1259 OID 26405)
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
-- TOC entry 3692 (class 0 OID 0)
-- Dependencies: 243
-- Name: conusu_interno_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE conusu_interno_id_seq OWNED BY conusu_interno.id;


--
-- TOC entry 244 (class 1259 OID 26407)
-- Dependencies: 2462 9
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
-- TOC entry 3693 (class 0 OID 0)
-- Dependencies: 244
-- Name: COLUMN conusu_tipocont.conusuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu_tipocont.conusuid IS 'Campo que se relaciona con la tabla del contribuyente (conusu)';


--
-- TOC entry 3694 (class 0 OID 0)
-- Dependencies: 244
-- Name: COLUMN conusu_tipocont.tipocontid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN conusu_tipocont.tipocontid IS 'Campo que establece la relacion con los tipos de contribuyentes';


--
-- TOC entry 245 (class 1259 OID 26411)
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
-- TOC entry 3695 (class 0 OID 0)
-- Dependencies: 245
-- Name: conusu_tipocon_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE conusu_tipocon_id_seq OWNED BY conusu_tipocont.id;


--
-- TOC entry 246 (class 1259 OID 26413)
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
-- TOC entry 247 (class 1259 OID 26419)
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
-- TOC entry 3696 (class 0 OID 0)
-- Dependencies: 247
-- Name: correlativos_actas_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE correlativos_actas_id_seq OWNED BY correlativos_actas.id;


--
-- TOC entry 248 (class 1259 OID 26421)
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
-- TOC entry 249 (class 1259 OID 26427)
-- Dependencies: 248 9
-- Name: correos_enviados_id_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE correos_enviados_id_seq
    START WITH 1
    INCREMENT BY 1
    MINVALUE 0
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos.correos_enviados_id_seq OWNER TO postgres;

--
-- TOC entry 3697 (class 0 OID 0)
-- Dependencies: 249
-- Name: correos_enviados_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE correos_enviados_id_seq OWNED BY correos_enviados.id;


--
-- TOC entry 250 (class 1259 OID 26429)
-- Dependencies: 2466 2467 9
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
-- TOC entry 3698 (class 0 OID 0)
-- Dependencies: 250
-- Name: TABLE ctaconta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE ctaconta IS 'Tabla con el plan de cuentas contables a utilizar.';


--
-- TOC entry 3699 (class 0 OID 0)
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
-- TOC entry 3700 (class 0 OID 0)
-- Dependencies: 250
-- Name: COLUMN ctaconta.descripcion; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN ctaconta.descripcion IS 'Descripcion de la cuenta';


--
-- TOC entry 3701 (class 0 OID 0)
-- Dependencies: 250
-- Name: COLUMN ctaconta.usaraux; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN ctaconta.usaraux IS 'Si la cuenta usara auxiliares. Esto es para el caso de una cuenta que no use auxiliar, esta podra tener movimiento a nivel de sub-especifico';


--
-- TOC entry 3702 (class 0 OID 0)
-- Dependencies: 250
-- Name: COLUMN ctaconta.inactiva; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN ctaconta.inactiva IS 'Si la cuenta esta inactiva o no';


--
-- TOC entry 3703 (class 0 OID 0)
-- Dependencies: 250
-- Name: COLUMN ctaconta.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN ctaconta.usuarioid IS 'Identificador del ultimo usuario que creo o modifico el registro';


--
-- TOC entry 3704 (class 0 OID 0)
-- Dependencies: 250
-- Name: COLUMN ctaconta.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN ctaconta.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 251 (class 1259 OID 26434)
-- Dependencies: 2468 2469 2470 2471 2472 2473 2474 2475 9
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
    fecha_carga_pago timestamp without time zone,
    banco integer,
    cuenta integer,
    ident_banco integer,
    plasus_alicuota numeric(18,2)
);


ALTER TABLE datos.declara OWNER TO postgres;

--
-- TOC entry 3705 (class 0 OID 0)
-- Dependencies: 251
-- Name: TABLE declara; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE declara IS 'Planilla de declaracion de impuestos';


--
-- TOC entry 3706 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN declara.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.id IS 'Identificador unico de la declaracion de impuestos';


--
-- TOC entry 3707 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN declara.nudeclara; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.nudeclara IS 'Numero de planilla de declaracion de impuesto';


--
-- TOC entry 3708 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN declara.nudeposito; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.nudeposito IS 'Numero de deposito bancario generado por el sistema';


--
-- TOC entry 3709 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN declara.tdeclaraid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.tdeclaraid IS 'Identificador del tipo de declaracion';


--
-- TOC entry 3710 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN declara.fechaelab; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.fechaelab IS 'Fecha de elaboracion de la planilla de pago de impuestos';


--
-- TOC entry 3711 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN declara.fechaini; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.fechaini IS 'Fecha de inicio del periodo gravable';


--
-- TOC entry 3712 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN declara.fechafin; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.fechafin IS 'Fecha final del periodo gravable';


--
-- TOC entry 3713 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN declara.replegalid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.replegalid IS 'Identificador del representante legal que aparecera en la planilla y firmara la misma';


--
-- TOC entry 3714 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN declara.baseimpo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.baseimpo IS 'Base imponible';


--
-- TOC entry 3715 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN declara.alicuota; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.alicuota IS 'Alicuota impositiva aplicada a la declaracion de impuesto';


--
-- TOC entry 3716 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN declara.exonera; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.exonera IS 'Exoneracion o rebaja';


--
-- TOC entry 3717 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN declara.nuactoexon; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.nuactoexon IS 'Numero de acto en donde se establece la exoneracion o rebaja';


--
-- TOC entry 3718 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN declara.credfiscal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.credfiscal IS 'Credito fiscal';


--
-- TOC entry 3719 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN declara.contribant; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.contribant IS 'Monto de la contribucion pagada en periodos anteriores';


--
-- TOC entry 3720 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN declara.plasustid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.plasustid IS 'Identificador de la planilla que se esta sustituyendo en caso de ser una declaracion sustitutiva';


--
-- TOC entry 3721 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN declara.montopagar; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.montopagar IS 'Monto a pagar';


--
-- TOC entry 3722 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN declara.fechapago; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.fechapago IS 'Fecha de pago en el banco. Se llena este campo cuando se concilian los pagos';


--
-- TOC entry 3723 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN declara.fechaconci; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.fechaconci IS 'Fecha hora de la conciliacion contra los depositos del banco';


--
-- TOC entry 3724 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN declara.asientoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.asientoid IS 'Identificador del asiento contable en donde se registro la informacion del pago';


--
-- TOC entry 3725 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN declara.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.usuarioid IS 'Identificador del usuario que concilio el pago de la declaracion. ';


--
-- TOC entry 3726 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN declara.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 3727 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN declara.ident_banco; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.ident_banco IS 'numero generado por el algoritmo suministrado por el banco para validar la procedencia de la planilla de declaracion';


--
-- TOC entry 3728 (class 0 OID 0)
-- Dependencies: 251
-- Name: COLUMN declara.plasus_alicuota; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN declara.plasus_alicuota IS 'campo que contiene el monto total del calculo de la nueva base imponible en la declarcion sustitutiva, el cual es restado con el monto de la declaracion que se esta sustituyendo';


--
-- TOC entry 252 (class 1259 OID 26448)
-- Dependencies: 3142 9
-- Name: datos_planilla_declaracion; Type: VIEW; Schema: datos; Owner: postgres
--

CREATE VIEW datos_planilla_declaracion AS
    SELECT conusu.nombre AS razonsocia, contribu.dencomerci, conusu.rif, contribu.numregcine, contribu.domfiscal, contribu.zonapostal, contribu.telef1, conusu.email, actiecon.nombre AS actiecon, estados.nombre AS nestados, ciudades.nombre AS nciudades, replegal.nombre AS nrplegal, replegal.ci AS cedulareplegal, replegal.telefhab AS telereplegal, replegal.domfiscal AS direccionreplegal, replegal.email AS emailreplegal, declara.nudeclara, to_char((declara.fechaini)::timestamp with time zone, 'dd-mm-YYYY'::text) AS fechai, to_char((declara.fechafin)::timestamp with time zone, 'dd-mm-YYYY'::text) AS fechafin, declara.baseimpo, declara.montopagar, declara.alicuota, declara.id, declara.exonera, declara.credfiscal, declara.contribant, tdeclara.nombre AS ntdeclara, tipocont.nombre AS ntipocont, declara.tdeclaraid, tipocont.id AS tipocontid, tipegrav.tipe AS tipo_periodo, calpagod.periodo AS periodo_declara, calpago.ano AS anio_declara, declara.ident_banco, declara.plasus_alicuota, declara.plasustid, CASE WHEN (declara.tdeclaraid = 3) THEN (SELECT dcl.montopagar FROM declara dcl WHERE (dcl.id = declara.plasustid)) ELSE NULL::numeric END AS monto_anterior FROM (((((((((((declara JOIN conusu ON ((conusu.id = declara.conusuid))) JOIN contribu contribu ON (((conusu.rif)::text = (contribu.rif)::text))) LEFT JOIN actiecon ON ((contribu.actieconid = actiecon.id))) LEFT JOIN ciudades ON ((contribu.ciudadid = ciudades.id))) JOIN estados ON ((contribu.estadoid = estados.id))) JOIN tdeclara ON ((declara.tdeclaraid = tdeclara.id))) JOIN tipocont ON ((declara.tipocontribuid = tipocont.id))) JOIN tipegrav ON ((tipegrav.id = tipocont.tipegravid))) JOIN replegal ON ((replegal.id = declara.replegalid))) JOIN calpagod ON ((calpagod.id = declara.calpagodid))) JOIN calpago ON ((calpago.id = calpagod.calpagoid)));


ALTER TABLE datos.datos_planilla_declaracion OWNER TO postgres;

SET search_path = pre_aprobacion, pg_catalog;

--
-- TOC entry 253 (class 1259 OID 26453)
-- Dependencies: 2476 6
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
    fecha_carga_pago timestamp without time zone,
    banco integer,
    cuenta integer
);


ALTER TABLE pre_aprobacion.intereses OWNER TO postgres;

--
-- TOC entry 3729 (class 0 OID 0)
-- Dependencies: 253
-- Name: COLUMN intereses.multaid; Type: COMMENT; Schema: pre_aprobacion; Owner: postgres
--

COMMENT ON COLUMN intereses.multaid IS 'campor para relacionar con la tabla de multas';


--
-- TOC entry 254 (class 1259 OID 26460)
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
    fecha_session timestamp without time zone,
    banco integer,
    cuenta integer
);


ALTER TABLE pre_aprobacion.multas OWNER TO postgres;

--
-- TOC entry 3730 (class 0 OID 0)
-- Dependencies: 254
-- Name: TABLE multas; Type: COMMENT; Schema: pre_aprobacion; Owner: postgres
--

COMMENT ON TABLE multas IS 'tabla que contiene el calculo de las multas por declaraciones extemporaneas o reparo fiscal';


SET search_path = datos, pg_catalog;

--
-- TOC entry 255 (class 1259 OID 26466)
-- Dependencies: 3143 9
-- Name: datos_planilla_multa_interese; Type: VIEW; Schema: datos; Owner: postgres
--

CREATE VIEW datos_planilla_multa_interese AS
    SELECT multas.nresolucion, multas.fechanotificacion, multas.montopagar AS total_multa, multas.id AS id_multa, intereses.totalpagar AS total_interes, conusu.nombre AS razonsocia, contribu.dencomerci, conusu.rif, contribu.numregcine, contribu.domfiscal, contribu.zonapostal, contribu.telef1, conusu.email, actiecon.nombre AS actiecon, estados.nombre AS nestados, ciudades.nombre AS nciudades, replegal.nombre AS nrplegal, replegal.ci AS cedulareplegal, replegal.telefhab AS telereplegal, replegal.domfiscal AS direccionreplegal, replegal.email AS emailreplegal, declara.nudeclara, to_char((declara.fechaini)::timestamp with time zone, 'dd-mm-YYYY'::text) AS fechai, to_char((declara.fechafin)::timestamp with time zone, 'dd-mm-YYYY'::text) AS fechafin, declara.baseimpo, declara.montopagar, declara.alicuota, declara.id, declara.exonera, declara.credfiscal, declara.contribant, tdeclara.nombre AS ntdeclara, tipocont.nombre AS ntipocont, tipocont.numero_articulo AS narticulo, tipocont.cita_articulo AS text_articulo, tdeclara.id AS tdeclaraid, tipocont.id AS tipocontid, tipegrav.tipe AS tipo_periodo, calpagod.periodo AS periodo_declara, calpago.ano AS anio_declara FROM (((((((((((((pre_aprobacion.multas JOIN pre_aprobacion.intereses ON ((intereses.multaid = multas.id))) JOIN declara ON ((multas.declaraid = declara.id))) JOIN conusu ON ((conusu.id = declara.conusuid))) LEFT JOIN contribu contribu ON (((conusu.rif)::text = (contribu.rif)::text))) LEFT JOIN actiecon ON ((contribu.actieconid = actiecon.id))) LEFT JOIN ciudades ON ((contribu.ciudadid = ciudades.id))) LEFT JOIN estados ON ((contribu.estadoid = estados.id))) JOIN tdeclara ON ((multas.tipo_multa = tdeclara.id))) JOIN tipocont ON ((declara.tipocontribuid = tipocont.id))) JOIN tipegrav ON ((tipegrav.id = tipocont.tipegravid))) JOIN replegal ON ((replegal.id = declara.replegalid))) JOIN calpagod ON ((calpagod.id = declara.calpagodid))) JOIN calpago ON ((calpago.id = calpagod.calpagoid)));


ALTER TABLE datos.datos_planilla_multa_interese OWNER TO postgres;

--
-- TOC entry 256 (class 1259 OID 26471)
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
-- TOC entry 257 (class 1259 OID 26477)
-- Dependencies: 256 9
-- Name: descargos_id_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE descargos_id_seq
    START WITH 1
    INCREMENT BY 1
    MINVALUE 0
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos.descargos_id_seq OWNER TO postgres;

--
-- TOC entry 3731 (class 0 OID 0)
-- Dependencies: 257
-- Name: descargos_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE descargos_id_seq OWNED BY descargos.id;


--
-- TOC entry 258 (class 1259 OID 26479)
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
-- TOC entry 3732 (class 0 OID 0)
-- Dependencies: 258
-- Name: TABLE detalle_interes; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE detalle_interes IS 'Tabla para el registro de los detalles de los intereses';


--
-- TOC entry 3733 (class 0 OID 0)
-- Dependencies: 258
-- Name: COLUMN detalle_interes.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes.id IS 'Identificador del detalle de los intereses';


--
-- TOC entry 3734 (class 0 OID 0)
-- Dependencies: 258
-- Name: COLUMN detalle_interes.intereses; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes.intereses IS 'intereses por mes';


--
-- TOC entry 3735 (class 0 OID 0)
-- Dependencies: 258
-- Name: COLUMN detalle_interes.tasa; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes.tasa IS 'tasa por mes segun el bcv';


--
-- TOC entry 3736 (class 0 OID 0)
-- Dependencies: 258
-- Name: COLUMN detalle_interes.dias; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes.dias IS 'dias de los meses de cada periodo';


--
-- TOC entry 3737 (class 0 OID 0)
-- Dependencies: 258
-- Name: COLUMN detalle_interes.mes; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes.mes IS 'meses de los periodos para el pago de los intereses';


--
-- TOC entry 3738 (class 0 OID 0)
-- Dependencies: 258
-- Name: COLUMN detalle_interes.anio; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes.anio IS 'anio de periodos';


--
-- TOC entry 3739 (class 0 OID 0)
-- Dependencies: 258
-- Name: COLUMN detalle_interes.intereses_id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN detalle_interes.intereses_id IS 'identificador del id de  la tabla de intereses';


--
-- TOC entry 259 (class 1259 OID 26485)
-- Dependencies: 9 258
-- Name: detalle_interes_id_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE detalle_interes_id_seq
    START WITH 1
    INCREMENT BY 1
    MINVALUE 0
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos.detalle_interes_id_seq OWNER TO postgres;

--
-- TOC entry 3740 (class 0 OID 0)
-- Dependencies: 259
-- Name: detalle_interes_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE detalle_interes_id_seq OWNED BY detalle_interes.id;


--
-- TOC entry 260 (class 1259 OID 26487)
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
-- TOC entry 261 (class 1259 OID 26493)
-- Dependencies: 9 260
-- Name: detalles_contrib_calc_id_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE detalles_contrib_calc_id_seq
    START WITH 1
    INCREMENT BY 1
    MINVALUE 0
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos.detalles_contrib_calc_id_seq OWNER TO postgres;

--
-- TOC entry 3741 (class 0 OID 0)
-- Dependencies: 261
-- Name: detalles_contrib_calc_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE detalles_contrib_calc_id_seq OWNED BY detalles_contrib_calc.id;


--
-- TOC entry 262 (class 1259 OID 26495)
-- Dependencies: 2482 2483 2484 9
-- Name: dettalles_fizcalizacion; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE dettalles_fizcalizacion (
    id integer NOT NULL,
    periodo integer,
    anio integer,
    base numeric(18,2),
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
-- TOC entry 263 (class 1259 OID 26504)
-- Dependencies: 9 262
-- Name: dettalles_fizcalizacion_id_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE dettalles_fizcalizacion_id_seq
    START WITH 1
    INCREMENT BY 1
    MINVALUE 0
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos.dettalles_fizcalizacion_id_seq OWNER TO postgres;

--
-- TOC entry 3742 (class 0 OID 0)
-- Dependencies: 263
-- Name: dettalles_fizcalizacion_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE dettalles_fizcalizacion_id_seq OWNED BY dettalles_fizcalizacion.id;


--
-- TOC entry 264 (class 1259 OID 26506)
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
-- TOC entry 3743 (class 0 OID 0)
-- Dependencies: 264
-- Name: TABLE document; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE document IS 'Tabla con los documentos legales utilizados por el sistema';


--
-- TOC entry 3744 (class 0 OID 0)
-- Dependencies: 264
-- Name: COLUMN document.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN document.id IS 'Identificador unico de registro';


--
-- TOC entry 3745 (class 0 OID 0)
-- Dependencies: 264
-- Name: COLUMN document.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN document.nombre IS 'Nombre del documento';


--
-- TOC entry 3746 (class 0 OID 0)
-- Dependencies: 264
-- Name: COLUMN document.docu; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN document.docu IS 'Texto del documento';


--
-- TOC entry 3747 (class 0 OID 0)
-- Dependencies: 264
-- Name: COLUMN document.inactivo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN document.inactivo IS 'Si el documento esta inactivo o activo';


--
-- TOC entry 3748 (class 0 OID 0)
-- Dependencies: 264
-- Name: COLUMN document.usfonproid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN document.usfonproid IS 'Identificador del ususario que creo o el ultimo que modifico el registro';


--
-- TOC entry 3749 (class 0 OID 0)
-- Dependencies: 264
-- Name: COLUMN document.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN document.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 265 (class 1259 OID 26513)
-- Dependencies: 9 264
-- Name: document_id_seq; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE document_id_seq
    START WITH 1
    INCREMENT BY 1
    MINVALUE 0
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos.document_id_seq OWNER TO postgres;

--
-- TOC entry 3750 (class 0 OID 0)
-- Dependencies: 265
-- Name: document_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE document_id_seq OWNED BY document.id;


--
-- TOC entry 266 (class 1259 OID 26515)
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
-- TOC entry 267 (class 1259 OID 26521)
-- Dependencies: 266 9
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
-- TOC entry 3751 (class 0 OID 0)
-- Dependencies: 267
-- Name: interes_bcv_id_seq; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE interes_bcv_id_seq OWNED BY interes_bcv.id;


--
-- TOC entry 268 (class 1259 OID 26523)
-- Dependencies: 2489 2490 2491 9
-- Name: presidente; Type: TABLE; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE TABLE presidente (
    id integer NOT NULL,
    nombres character varying(255),
    apellidos character varying(255),
    cedula character varying,
    nro_decreto character varying(255),
    nro_gaceta character varying(255),
    dtm_fecha_gaceta character varying,
    bln_activo boolean DEFAULT true NOT NULL,
    usuarioid integer,
    ip character varying,
    fecha_registro date DEFAULT now() NOT NULL,
    bln_borrado boolean DEFAULT false NOT NULL
);


ALTER TABLE datos.presidente OWNER TO postgres;

--
-- TOC entry 269 (class 1259 OID 26532)
-- Dependencies: 268 9
-- Name: presidente_id_seq2; Type: SEQUENCE; Schema: datos; Owner: postgres
--

CREATE SEQUENCE presidente_id_seq2
    START WITH 1
    INCREMENT BY 1
    MINVALUE 0
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datos.presidente_id_seq2 OWNER TO postgres;

--
-- TOC entry 3752 (class 0 OID 0)
-- Dependencies: 269
-- Name: presidente_id_seq2; Type: SEQUENCE OWNED BY; Schema: datos; Owner: postgres
--

ALTER SEQUENCE presidente_id_seq2 OWNED BY presidente.id;


--
-- TOC entry 270 (class 1259 OID 26534)
-- Dependencies: 2493 2494 2495 2496 9
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
    fecha_recepcion timestamp without time zone,
    bln_conformida boolean
);


ALTER TABLE datos.reparos OWNER TO postgres;

--
-- TOC entry 3753 (class 0 OID 0)
-- Dependencies: 270
-- Name: COLUMN reparos.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN reparos.id IS 'Identificador unico de la declaracion de impuestos';


--
-- TOC entry 3754 (class 0 OID 0)
-- Dependencies: 270
-- Name: COLUMN reparos.tdeclaraid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN reparos.tdeclaraid IS 'Identificador del tipo de declaracion';


--
-- TOC entry 3755 (class 0 OID 0)
-- Dependencies: 270
-- Name: COLUMN reparos.fechaelab; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN reparos.fechaelab IS 'Fecha de elaboracion de la planilla de pago de impuestos';


--
-- TOC entry 3756 (class 0 OID 0)
-- Dependencies: 270
-- Name: COLUMN reparos.montopagar; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN reparos.montopagar IS 'Monto a pagar';


--
-- TOC entry 3757 (class 0 OID 0)
-- Dependencies: 270
-- Name: COLUMN reparos.asientoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN reparos.asientoid IS 'Identificador del asiento contable en donde se registro la informacion del pago';


--
-- TOC entry 3758 (class 0 OID 0)
-- Dependencies: 270
-- Name: COLUMN reparos.usuarioid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN reparos.usuarioid IS 'Identificador del usuario que concilio el pago de la declaracion. ';


--
-- TOC entry 3759 (class 0 OID 0)
-- Dependencies: 270
-- Name: COLUMN reparos.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN reparos.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 271 (class 1259 OID 26544)
-- Dependencies: 2497 2498 9
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
-- TOC entry 3760 (class 0 OID 0)
-- Dependencies: 271
-- Name: TABLE tmpaccioni; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE tmpaccioni IS 'Tabla con los datos de los Accionistas de los contribuyentes';


--
-- TOC entry 3761 (class 0 OID 0)
-- Dependencies: 271
-- Name: COLUMN tmpaccioni.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.id IS 'Identificador unico del accionista';


--
-- TOC entry 3762 (class 0 OID 0)
-- Dependencies: 271
-- Name: COLUMN tmpaccioni.contribuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.contribuid IS 'Identificador del contribuyente';


--
-- TOC entry 3763 (class 0 OID 0)
-- Dependencies: 271
-- Name: COLUMN tmpaccioni.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.nombre IS 'Nombre del accionista';


--
-- TOC entry 3764 (class 0 OID 0)
-- Dependencies: 271
-- Name: COLUMN tmpaccioni.apellido; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.apellido IS 'Apellidos del accionista';


--
-- TOC entry 3765 (class 0 OID 0)
-- Dependencies: 271
-- Name: COLUMN tmpaccioni.ci; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.ci IS 'Cedula de identidad, numero de pasaporte';


--
-- TOC entry 3766 (class 0 OID 0)
-- Dependencies: 271
-- Name: COLUMN tmpaccioni.domfiscal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.domfiscal IS 'Domicilio fiscal del accionista';


--
-- TOC entry 3767 (class 0 OID 0)
-- Dependencies: 271
-- Name: COLUMN tmpaccioni.nuacciones; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.nuacciones IS 'Numero de acciones';


--
-- TOC entry 3768 (class 0 OID 0)
-- Dependencies: 271
-- Name: COLUMN tmpaccioni.valaccion; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.valaccion IS 'Valor nominal de las acciones';


--
-- TOC entry 3769 (class 0 OID 0)
-- Dependencies: 271
-- Name: COLUMN tmpaccioni.cextra1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.cextra1 IS 'Campo extra 1';


--
-- TOC entry 3770 (class 0 OID 0)
-- Dependencies: 271
-- Name: COLUMN tmpaccioni.cextra2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.cextra2 IS 'Campo extra 2';


--
-- TOC entry 3771 (class 0 OID 0)
-- Dependencies: 271
-- Name: COLUMN tmpaccioni.cextra3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.cextra3 IS 'Campo extra 3';


--
-- TOC entry 3772 (class 0 OID 0)
-- Dependencies: 271
-- Name: COLUMN tmpaccioni.cextra4; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.cextra4 IS 'Campo extra 4';


--
-- TOC entry 3773 (class 0 OID 0)
-- Dependencies: 271
-- Name: COLUMN tmpaccioni.cextra5; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.cextra5 IS 'Campo extra 5';


--
-- TOC entry 3774 (class 0 OID 0)
-- Dependencies: 271
-- Name: COLUMN tmpaccioni.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpaccioni.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 272 (class 1259 OID 26552)
-- Dependencies: 2499 2500 2501 2502 9
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
-- TOC entry 3775 (class 0 OID 0)
-- Dependencies: 272
-- Name: TABLE tmpcontri; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE tmpcontri IS 'Tabla con los datos temporales de los contribuyentes de la institución. Esta tabla se utiliza para que los contribuyentes hagan una solicitud de actualizacion de datos';


--
-- TOC entry 3776 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN tmpcontri.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.id IS 'Identificador unico del contribuyente';


--
-- TOC entry 3777 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN tmpcontri.tipocontid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.tipocontid IS 'Identificador del tipo de contribuyente';


--
-- TOC entry 3778 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN tmpcontri.razonsocia; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.razonsocia IS 'Razon social del contribuyente';


--
-- TOC entry 3779 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN tmpcontri.dencomerci; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.dencomerci IS 'Denominacion comercial del contribuyente';


--
-- TOC entry 3780 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN tmpcontri.actieconid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.actieconid IS 'Identificador de la actividad economica';


--
-- TOC entry 3781 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN tmpcontri.rif; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.rif IS 'Rif del contribuyente';


--
-- TOC entry 3782 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN tmpcontri.numregcine; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.numregcine IS 'Numero de registro cinematografico';


--
-- TOC entry 3783 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN tmpcontri.domfiscal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.domfiscal IS 'Domicilio fiscal del contribuyente';


--
-- TOC entry 3784 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN tmpcontri.estadoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.estadoid IS 'Identicador del estado geografico';


--
-- TOC entry 3785 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN tmpcontri.ciudadid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.ciudadid IS 'Identificador de la ciudad';


--
-- TOC entry 3786 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN tmpcontri.zonapostal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.zonapostal IS 'Zona postal del contribuyente';


--
-- TOC entry 3787 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN tmpcontri.telef1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.telef1 IS 'Telefono 1 del contribuyente';


--
-- TOC entry 3788 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN tmpcontri.telef2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.telef2 IS 'Telefono 2 del contribuyente';


--
-- TOC entry 3789 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN tmpcontri.telef3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.telef3 IS 'Telefono 3 del contribuyente';


--
-- TOC entry 3790 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN tmpcontri.fax1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.fax1 IS 'Fax 1 del contribuyente';


--
-- TOC entry 3791 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN tmpcontri.fax2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.fax2 IS 'Fax 2 del contribuyente';


--
-- TOC entry 3792 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN tmpcontri.email; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.email IS 'Direccion de email de contribuyente';


--
-- TOC entry 3793 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN tmpcontri.pinbb; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.pinbb IS 'Pin de BlackBerry';


--
-- TOC entry 3794 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN tmpcontri.skype; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.skype IS 'Dirección de skype';


--
-- TOC entry 3795 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN tmpcontri.twitter; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.twitter IS 'Direccion de twitter';


--
-- TOC entry 3796 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN tmpcontri.facebook; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.facebook IS 'Direccion de facebook';


--
-- TOC entry 3797 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN tmpcontri.nuacciones; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.nuacciones IS 'Numero de acciones del contribuyente segun inforacion del registro mercantil';


--
-- TOC entry 3798 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN tmpcontri.valaccion; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.valaccion IS 'Valor nominal por accion segun registro mercantil';


--
-- TOC entry 3799 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN tmpcontri.capitalsus; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.capitalsus IS 'Capital suscrito segun registro mercantil';


--
-- TOC entry 3800 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN tmpcontri.capitalpag; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.capitalpag IS 'Capital pagado segun registro mercantil';


--
-- TOC entry 3801 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN tmpcontri.regmerofc; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.regmerofc IS 'Oficina de registro mercantil en donde se registro la empresa';


--
-- TOC entry 3802 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN tmpcontri.rmnumero; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.rmnumero IS 'Numero de registro del documento de registro mercantil';


--
-- TOC entry 3803 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN tmpcontri.rmfolio; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.rmfolio IS 'Numero de folio del documento de registro mercantil';


--
-- TOC entry 3804 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN tmpcontri.rmtomo; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.rmtomo IS 'Numero de folio del documento de registro mercantil';


--
-- TOC entry 3805 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN tmpcontri.rmfechapro; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.rmfechapro IS 'Fecha de protocololizacion del registro del documento de registro mercantil';


--
-- TOC entry 3806 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN tmpcontri.rmncontrol; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.rmncontrol IS 'Numero de control del documento de registro mercantil';


--
-- TOC entry 3807 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN tmpcontri.rmobjeto; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.rmobjeto IS 'Objeto de la empresa segun registro mercantil';


--
-- TOC entry 3808 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN tmpcontri.domcomer; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.domcomer IS 'domicilio comercial';


--
-- TOC entry 3809 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN tmpcontri.conusuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.conusuid IS 'Identificador del usuario-contribuyente que creo el registro';


--
-- TOC entry 3810 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN tmpcontri.tiporeg; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.tiporeg IS 'Tipo de registro creado. 0=Nuevo contribuyente, 1=Edicion de datos de contribuyentes';


--
-- TOC entry 3811 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN tmpcontri.cextra1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.cextra1 IS 'Campo extra 1';


--
-- TOC entry 3812 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN tmpcontri.cextra2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.cextra2 IS 'Campo extra 2';


--
-- TOC entry 3813 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN tmpcontri.cextra3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.cextra3 IS 'Campo extra 3';


--
-- TOC entry 3814 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN tmpcontri.cextra4; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.cextra4 IS 'Campo extra 4';


--
-- TOC entry 3815 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN tmpcontri.cextra5; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.cextra5 IS 'Campo extra 5';


--
-- TOC entry 3816 (class 0 OID 0)
-- Dependencies: 272
-- Name: COLUMN tmpcontri.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmpcontri.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 273 (class 1259 OID 26562)
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
-- TOC entry 3817 (class 0 OID 0)
-- Dependencies: 273
-- Name: TABLE tmprelegal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TABLE tmprelegal IS 'Tabla con los datos temporales de los representantes legales de los contribuyentes. Esta tabla se utiliza para procesar una solicitud de cambio de datos. El contribuyente copia aqui los nuevos datos';


--
-- TOC entry 3818 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN tmprelegal.id; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.id IS 'Identificador unico del representante legal';


--
-- TOC entry 3819 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN tmprelegal.contribuid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.contribuid IS 'Identificador del contribuyente';


--
-- TOC entry 3820 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN tmprelegal.nombre; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.nombre IS 'Nombre del representante legal';


--
-- TOC entry 3821 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN tmprelegal.apellido; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.apellido IS 'Apellidos del representante legal';


--
-- TOC entry 3822 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN tmprelegal.ci; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.ci IS 'Cedula de identidad, numero de pasaporte';


--
-- TOC entry 3823 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN tmprelegal.domfiscal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.domfiscal IS 'Domicilio fiscal del representante legal';


--
-- TOC entry 3824 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN tmprelegal.estadoid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.estadoid IS 'Identificador del estado geografico';


--
-- TOC entry 3825 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN tmprelegal.ciudadid; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.ciudadid IS 'Identificador de la ciudad';


--
-- TOC entry 3826 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN tmprelegal.zonaposta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.zonaposta IS 'Zona postal';


--
-- TOC entry 3827 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN tmprelegal.telefhab; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.telefhab IS 'Telefono de habitacion del representante legal';


--
-- TOC entry 3828 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN tmprelegal.telefofc; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.telefofc IS 'Telefono de oficina del representante legal';


--
-- TOC entry 3829 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN tmprelegal.fax; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.fax IS 'Fax del representante legal';


--
-- TOC entry 3830 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN tmprelegal.email; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.email IS 'Direccion de email del contribuyente';


--
-- TOC entry 3831 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN tmprelegal.pinbb; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.pinbb IS 'Pin de BlackBerry';


--
-- TOC entry 3832 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN tmprelegal.skype; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.skype IS 'Direccion de skype del representante legal';


--
-- TOC entry 3833 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN tmprelegal.cextra1; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.cextra1 IS 'Campo extra 1 ';


--
-- TOC entry 3834 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN tmprelegal.cextra2; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.cextra2 IS 'Campo extra 2 ';


--
-- TOC entry 3835 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN tmprelegal.cextra3; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.cextra3 IS 'Campo extra 3 ';


--
-- TOC entry 3836 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN tmprelegal.cextra4; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.cextra4 IS 'Campo extra 4 ';


--
-- TOC entry 3837 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN tmprelegal.cextra5; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.cextra5 IS 'Campo extra 5 ';


--
-- TOC entry 3838 (class 0 OID 0)
-- Dependencies: 273
-- Name: COLUMN tmprelegal.ip; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON COLUMN tmprelegal.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 274 (class 1259 OID 26568)
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
-- TOC entry 275 (class 1259 OID 26574)
-- Dependencies: 3144 9
-- Name: vista_conciliacion_bancaria_autoliquidaciones; Type: VIEW; Schema: datos; Owner: postgres
--

CREATE VIEW vista_conciliacion_bancaria_autoliquidaciones AS
    SELECT calp.id AS calpagoid, calp.nombre AS nombrecalp, calp.ano AS anio_calendario, calpd.id AS calpagodid, calpd.periodo, calpd.fechaini AS inicio_calendario, calpd.fechalim AS fin_calendario, tcon.id AS tipocontid, tgrav.tipe, tcon.nombre AS nombre_tcon, conu.id AS conusuid, conu.nombre AS contribuyente, conu.rif, conu.fecha_registro, decl.id AS declaraid, decl.fechapago, banc.nombre AS banco, bcue.tipo_cuenta AS cuenta, CASE WHEN (decl.id IS NULL) THEN 'omiso1'::text ELSE CASE WHEN (decl.fechapago IS NULL) THEN 'omiso2'::text ELSE CASE WHEN (decl.fechapago <= calpd.fechalim) THEN 'pagado'::text ELSE 'extemporaneo'::text END END END AS estado, CASE WHEN (decl.id IS NULL) THEN 'NO'::text ELSE CASE WHEN (decl.fechapago IS NULL) THEN 'NO'::text ELSE CASE WHEN (decl.fechapago <= calpd.fechalim) THEN 'SI'::text ELSE 'SI'::text END END END AS cobrada FROM ((((((((calpago calp JOIN calpagod calpd ON ((calpd.calpagoid = calp.id))) JOIN tipegrav tgrav ON ((tgrav.id = calp.tipegravid))) JOIN tipocont tcon ON ((tcon.tipegravid = tgrav.id))) JOIN conusu_tipocont conutcon ON ((conutcon.tipocontid = tcon.id))) JOIN conusu conu ON ((conu.id = conutcon.conusuid))) LEFT JOIN declara decl ON ((decl.calpagodid = calpd.id))) LEFT JOIN bancos banc ON ((banc.id = decl.banco))) LEFT JOIN bacuenta bcue ON ((bcue.id = decl.cuenta))) WHERE ((calpd.fechaini >= conu.fecha_registro) AND (calpd.fechalim < now())) ORDER BY ROW(tcon.id, calp.ano, calpd.periodo);


ALTER TABLE datos.vista_conciliacion_bancaria_autoliquidaciones OWNER TO postgres;

--
-- TOC entry 276 (class 1259 OID 26579)
-- Dependencies: 3145 9
-- Name: vista_conciliacion_bancaria_multas; Type: VIEW; Schema: datos; Owner: postgres
--

CREATE VIEW vista_conciliacion_bancaria_multas AS
    SELECT calpago.id AS calpagoid, multas.fechaelaboracion, to_char(multas.fechaelaboracion, 'YYYY'::text) AS anio_calendario, calpagod.id AS calpagodid, multas.nresolucion, calpagod.periodo, tipocont.id AS tipocontid, tipegrav.tipe, tipocont.nombre AS nombre_tcon, conusu.id AS conusuid, conusu.nombre AS contribuyente, conusu.rif, multas.fechapago, multas.fechanotificacion, multas.montopagar, multas.nudeposito, multas.fecha_carga_pago, intereses.totalpagar, intereses.id AS interesid, multas.tipo_multa, banc.nombre AS banco, bcue.num_cuenta AS cuenta, CASE WHEN (multas.fechanotificacion IS NULL) THEN 'POR NOTIFICAR'::text ELSE 'NOTIFICADA'::text END AS estado, CASE WHEN (multas.fechapago IS NULL) THEN 'NO'::text ELSE 'SI'::text END AS cobrada, (SELECT sum(m.montopagar) AS sum FROM (pre_aprobacion.multas m JOIN declara d ON ((d.id = m.declaraid))) WHERE (d.reparoid = declara.reparoid)) AS multa_pagar, (SELECT sum(i.totalpagar) AS sum FROM ((pre_aprobacion.multas m JOIN pre_aprobacion.intereses i ON ((i.multaid = m.id))) JOIN declara d ON ((d.id = m.declaraid))) WHERE (d.reparoid = declara.reparoid)) AS interes_pagar FROM (((((((((pre_aprobacion.multas JOIN declara ON ((multas.declaraid = declara.id))) JOIN conusu ON ((declara.conusuid = conusu.id))) JOIN tipocont ON ((declara.tipocontribuid = tipocont.id))) JOIN tipegrav ON ((tipocont.tipegravid = tipegrav.id))) JOIN pre_aprobacion.intereses ON ((multas.id = intereses.multaid))) JOIN calpagod ON ((declara.calpagodid = calpagod.id))) JOIN calpago ON ((calpagod.calpagoid = calpago.id))) LEFT JOIN bancos banc ON ((banc.id = multas.banco))) LEFT JOIN bacuenta bcue ON ((bcue.id = multas.cuenta)));


ALTER TABLE datos.vista_conciliacion_bancaria_multas OWNER TO postgres;

--
-- TOC entry 277 (class 1259 OID 26584)
-- Dependencies: 3146 9
-- Name: vista_conciliacion_bancaria_multas_2; Type: VIEW; Schema: datos; Owner: postgres
--

CREATE VIEW vista_conciliacion_bancaria_multas_2 AS
    SELECT calpago.id AS calpagoid, multas.fechaelaboracion, to_char(multas.fechaelaboracion, 'YYYY'::text) AS anio_calendario, calpagod.id AS calpagodid, multas.nresolucion, calpagod.periodo, tipocont.id AS tipocontid, tipegrav.tipe, tipocont.nombre AS nombre_tcon, conusu.id AS conusuid, conusu.nombre AS contribuyente, conusu.rif, multas.fechapago, multas.fechanotificacion, multas.montopagar, multas.nudeposito, multas.fecha_carga_pago, intereses.totalpagar, intereses.id AS interesid, multas.tipo_multa, CASE WHEN (multas.fechanotificacion IS NULL) THEN 'POR NOTIFICAR'::text ELSE 'NOTIFICADA'::text END AS estado, CASE WHEN (multas.fechapago IS NULL) THEN 'NO'::text ELSE 'SI'::text END AS cobrada, (SELECT sum(m.montopagar) AS sum FROM (pre_aprobacion.multas m JOIN declara d ON ((d.id = m.declaraid))) WHERE (d.reparoid = declara.reparoid)) AS multa_pagar, (SELECT sum(i.totalpagar) AS sum FROM ((pre_aprobacion.multas m JOIN pre_aprobacion.intereses i ON ((i.multaid = m.id))) JOIN declara d ON ((d.id = m.declaraid))) WHERE (d.reparoid = declara.reparoid)) AS interes_pagar FROM (((((((pre_aprobacion.multas JOIN declara ON ((multas.declaraid = declara.id))) JOIN conusu ON ((declara.conusuid = conusu.id))) JOIN tipocont ON ((declara.tipocontribuid = tipocont.id))) JOIN tipegrav ON ((tipocont.tipegravid = tipegrav.id))) JOIN pre_aprobacion.intereses ON ((multas.id = intereses.multaid))) JOIN calpagod ON ((declara.calpagodid = calpagod.id))) JOIN calpago ON ((calpagod.calpagoid = calpago.id)));


ALTER TABLE datos.vista_conciliacion_bancaria_multas_2 OWNER TO postgres;

--
-- TOC entry 278 (class 1259 OID 26589)
-- Dependencies: 3147 9
-- Name: vista_datos_multa_interes; Type: VIEW; Schema: datos; Owner: postgres
--

CREATE VIEW vista_datos_multa_interes AS
    SELECT conu.nombre AS contribuyente, conu.rif, contri.dencomerci AS denominacion_comercial, conu.email, actiecon.nombre AS actiecon, contri.rmtomo, contri.rmobjeto AS objeto_empresa, contri.numregcine, contri.domfiscal, contri.zonapostal, contri.telef1, replegal.nombre AS nrplegal, replegal.ci AS cedulareplegal, replegal.telefhab AS telereplegal, replegal.domfiscal AS direccionreplegal, replegal.email AS emailreplegal, tcont.nombre, tcont.numero_articulo AS narticulo, tcont.cita_articulo AS text_articulo, contri.domfiscal AS domicilio_fisal, est.nombre AS estado, ciu.nombre AS ciudad, contri.regmerofc AS oficina_registro, contri.rmfechapro AS fecha_registro, contri.rmnumero AS numero_registro, decl.proceso AS proceso_multa, rep.id AS idreparo, rep.fecha_notificacion AS fechanoti_reparo, rep.fecha_autorizacion, rep.fecha_recepcion, rep.fecha_requerimiento, rep.tipocontribuid AS idtipocont, rep.conusuid AS idconusu, asigf.periodo_afiscalizar, asigf.nro_autorizacion, actrp.numero AS nacta_reparo, rep.montopagar AS total_reparo, usf.nombre AS fiscal_ejecutor, usf.cedula AS cedula_fiscal, ut.valor AS valor_ut, mult.id AS idmulta, mult.nresolucion AS resol_multa, mult.fechaelaboracion, mult.tipo_multa, mult.nudeposito AS deposito_multa, mult.declaraid AS multdclaid, (SELECT sum(m.montopagar) AS sum FROM ((pre_aprobacion.multas m JOIN declara d ON ((d.id = m.declaraid))) JOIN reparos r ON ((r.id = d.reparoid))) WHERE (r.id = rep.id)) AS multa_pagar, mult.fechanotificacion AS fnoti_multa, inte.id AS idinteres, inte.numresolucion AS resol_interes, inte.totalpagar AS total_interes, (SELECT sum(i.totalpagar) AS sum FROM (((pre_aprobacion.multas m JOIN pre_aprobacion.intereses i ON ((i.multaid = m.id))) JOIN declara d ON ((d.id = m.declaraid))) JOIN reparos r ON ((r.id = d.reparoid))) WHERE (r.id = rep.id)) AS interes_pagar, mult.numero_session AS nsession, mult.fecha_session AS fsession, tdeclara.id AS tdeclaraid, tcont.id AS tipocontid, tipegrav.tipe AS tipo_periodo, calpagod.periodo AS periodo_declara, calpago.ano AS anio_declara, tdeclara.nombre AS ntdeclara, tdeclara.id AS tipodclid FROM ((((((((((((((((((pre_aprobacion.multas mult JOIN pre_aprobacion.intereses inte ON ((inte.multaid = mult.id))) JOIN declara decl ON ((decl.id = mult.declaraid))) JOIN conusu conu ON ((conu.id = decl.conusuid))) JOIN contribu contri ON (((contri.rif)::text = (conu.rif)::text))) LEFT JOIN actiecon ON ((contri.actieconid = actiecon.id))) JOIN replegal ON ((replegal.contribuid = conu.id))) JOIN estados est ON ((est.id = contri.estadoid))) LEFT JOIN ciudades ciu ON ((ciu.id = contri.ciudadid))) JOIN reparos rep ON ((rep.id = decl.reparoid))) JOIN tipocont tcont ON ((tcont.id = rep.tipocontribuid))) JOIN tipegrav ON ((tipegrav.id = tcont.tipegravid))) JOIN actas_reparo actrp ON ((actrp.id = rep.actaid))) JOIN asignacion_fiscales asigf ON ((asigf.id = rep.asignacionid))) JOIN undtrib ut ON (((ut.anio)::numeric = asigf.periodo_afiscalizar))) JOIN usfonpro usf ON ((usf.id = asigf.usfonproid))) JOIN calpagod ON ((calpagod.id = decl.calpagodid))) JOIN calpago ON ((calpago.id = calpagod.calpagoid))) JOIN tdeclara ON ((mult.tipo_multa = tdeclara.id)));


ALTER TABLE datos.vista_datos_multa_interes OWNER TO postgres;

--
-- TOC entry 279 (class 1259 OID 26594)
-- Dependencies: 3148 9
-- Name: vista_datos_rise_recaudacion; Type: VIEW; Schema: datos; Owner: postgres
--

CREATE VIEW vista_datos_rise_recaudacion AS
    SELECT d.fecha_registro_fila, d.id AS contribcalcid, dc.id AS detacontribcalcid, conu.nombre AS contribuyente, conu.rif, contri.dencomerci AS denominacion_comercial, contri.rmtomo, contri.rmobjeto AS objeto_empresa, tcont.nombre, tcont.numero_articulo, tcont.cita_articulo, contri.domfiscal AS domicilio_fisal, est.nombre AS estado, ciu.nombre AS ciudad, contri.regmerofc AS oficina_registro, contri.rmfechapro AS fecha_registro, contri.rmnumero AS numero_registro, dc.proceso AS proceso_multa, d.tipocontid AS idtipocont, mult.id AS idmulta, mult.nresolucion AS resol_multa, mult.fechaelaboracion, mult.tipo_multa, mult.nudeposito AS deposito_multa, mult.declaraid AS multdclaid, mult.montopagar AS total_multa, (SELECT sum(m.montopagar) AS sum FROM (pre_aprobacion.multas m JOIN detalles_contrib_calc con_calc ON ((con_calc.declaraid = m.declaraid))) WHERE (con_calc.contrib_calcid = d.id)) AS multa_pagar, inte.id AS idinteres, inte.numresolucion AS resol_interes, inte.totalpagar AS total_interes, (SELECT sum(i.totalpagar) AS sum FROM ((pre_aprobacion.multas m JOIN pre_aprobacion.intereses i ON ((i.multaid = m.id))) JOIN detalles_contrib_calc con_calc ON ((con_calc.declaraid = m.declaraid))) WHERE (con_calc.contrib_calcid = d.id)) AS interes_pagar, mult.numero_session AS nsession, mult.fecha_session AS fsession, contri.numregcine AS registro_cnac, usfp.nombre AS grente_reca, usfp.cedula AS cedula_reca, to_char(mult.fechaelaboracion, 'YYYY'::text) AS anio_rise FROM (((((((((contrib_calc d JOIN detalles_contrib_calc dc ON ((d.id = dc.contrib_calcid))) JOIN pre_aprobacion.multas mult ON ((mult.declaraid = dc.declaraid))) JOIN pre_aprobacion.intereses inte ON ((inte.multaid = mult.id))) JOIN conusu conu ON ((conu.id = d.conusuid))) JOIN contribu contri ON (((contri.rif)::text = (conu.rif)::text))) JOIN estados est ON ((est.id = contri.estadoid))) LEFT JOIN ciudades ciu ON ((ciu.id = contri.ciudadid))) JOIN tipocont tcont ON ((tcont.id = d.tipocontid))) JOIN usfonpro usfp ON ((usfp.id = d.usuarioid)));


ALTER TABLE datos.vista_datos_rise_recaudacion OWNER TO postgres;

--
-- TOC entry 280 (class 1259 OID 26599)
-- Dependencies: 3149 9
-- Name: vista_reporte_actas_fizcalizacion; Type: VIEW; Schema: datos; Owner: postgres
--

CREATE VIEW vista_reporte_actas_fizcalizacion AS
    SELECT to_char((asignacion_fiscales.fecha_asignacion)::timestamp with time zone, 'YYYY'::text) AS anio, conusu.nombre AS contribuyente, conusu.rif, tipocont.nombre AS tipo_contribuyente, asignacion_fiscales.fecha_asignacion, asignacion_fiscales.periodo_afiscalizar AS anio_fiscalizar, tipegrav.tipe AS tipo, asignacion_fiscales.nro_autorizacion, asignacion_fiscales.estatus AS estado_asignacion, usfonpro.nombre AS fiscal_actuante, cargos.nombre AS cargo_fiscal, CASE WHEN (reparos.id IS NULL) THEN 0 ELSE 1 END AS reparo_encendido, reparos.fechaelab AS fecha_creacion_rep, reparos.fecha_autorizacion, reparos.fecha_requerimiento, reparos.fecha_recepcion, reparos.bln_conformida, reparos.proceso AS estado_reparo, actas_reparo.numero AS numero_acta_rep, actas_reparo.bln_conformida AS tipo_reparo FROM (((((((asignacion_fiscales LEFT JOIN reparos ON ((reparos.asignacionid = asignacion_fiscales.id))) LEFT JOIN actas_reparo ON ((reparos.actaid = actas_reparo.id))) JOIN usfonpro ON ((asignacion_fiscales.usfonproid = usfonpro.id))) JOIN conusu ON ((asignacion_fiscales.conusuid = conusu.id))) JOIN tipocont ON ((asignacion_fiscales.tipocontid = tipocont.id))) JOIN tipegrav ON ((tipocont.tipegravid = tipegrav.id))) JOIN cargos ON ((usfonpro.cargoid = cargos.id)));


ALTER TABLE datos.vista_reporte_actas_fizcalizacion OWNER TO postgres;

--
-- TOC entry 281 (class 1259 OID 26604)
-- Dependencies: 3150 9
-- Name: vista_reporte_principal_recaudacion; Type: VIEW; Schema: datos; Owner: postgres
--

CREATE VIEW vista_reporte_principal_recaudacion AS
    SELECT calpd.periodo, to_char((declara.fechapago)::timestamp with time zone, 'mm'::text) AS mes, calp.ano, to_char((declara.fechapago)::timestamp with time zone, 'yyyy'::text) AS anio, tcon.id, tcon.nombre, declara.montopagar, (SELECT sum(decl.montopagar) AS sum FROM declara decl WHERE (((decl.tipocontribuid = 1) AND (NOT decl.bln_reparo)) AND (to_char((decl.fechapago)::timestamp with time zone, 'mm'::text) = to_char((declara.fechapago)::timestamp with time zone, 'mm'::text)))) AS tot_1, (SELECT sum(decl.montopagar) AS sum FROM declara decl WHERE (((decl.tipocontribuid = 2) AND (NOT decl.bln_reparo)) AND (to_char((decl.fechapago)::timestamp with time zone, 'mm'::text) = to_char((declara.fechapago)::timestamp with time zone, 'mm'::text)))) AS tot_2, (SELECT sum(decl.montopagar) AS sum FROM declara decl WHERE (((decl.tipocontribuid = 3) AND (NOT decl.bln_reparo)) AND (to_char((decl.fechapago)::timestamp with time zone, 'mm'::text) = to_char((declara.fechapago)::timestamp with time zone, 'mm'::text)))) AS tot_3, (SELECT sum(decl.montopagar) AS sum FROM declara decl WHERE (((decl.tipocontribuid = 4) AND (NOT decl.bln_reparo)) AND (to_char((decl.fechapago)::timestamp with time zone, 'mm'::text) = to_char((declara.fechapago)::timestamp with time zone, 'mm'::text)))) AS tot_4, (SELECT sum(decl.montopagar) AS sum FROM declara decl WHERE (((decl.tipocontribuid = 5) AND (NOT decl.bln_reparo)) AND (to_char((decl.fechapago)::timestamp with time zone, 'mm'::text) = to_char((declara.fechapago)::timestamp with time zone, 'mm'::text)))) AS tot_5, (SELECT sum(decl.montopagar) AS sum FROM declara decl WHERE (((decl.tipocontribuid = 6) AND (NOT decl.bln_reparo)) AND (to_char((decl.fechapago)::timestamp with time zone, 'mm'::text) = to_char((declara.fechapago)::timestamp with time zone, 'mm'::text)))) AS tot_6, (SELECT sum(decl.montopagar) AS sum FROM declara decl WHERE (((decl.tipocontribuid = 1) AND decl.bln_reparo) AND (to_char((decl.fechapago)::timestamp with time zone, 'mm'::text) = to_char((declara.fechapago)::timestamp with time zone, 'mm'::text)))) AS totr_1, (SELECT sum(decl.montopagar) AS sum FROM declara decl WHERE (((decl.tipocontribuid = 2) AND decl.bln_reparo) AND (to_char((decl.fechapago)::timestamp with time zone, 'mm'::text) = to_char((declara.fechapago)::timestamp with time zone, 'mm'::text)))) AS totr_2, (SELECT sum(decl.montopagar) AS sum FROM declara decl WHERE (((decl.tipocontribuid = 3) AND decl.bln_reparo) AND (to_char((decl.fechapago)::timestamp with time zone, 'mm'::text) = to_char((declara.fechapago)::timestamp with time zone, 'mm'::text)))) AS totr_3, (SELECT sum(decl.montopagar) AS sum FROM declara decl WHERE (((decl.tipocontribuid = 4) AND decl.bln_reparo) AND (to_char((decl.fechapago)::timestamp with time zone, 'mm'::text) = to_char((declara.fechapago)::timestamp with time zone, 'mm'::text)))) AS totr_4, (SELECT sum(decl.montopagar) AS sum FROM declara decl WHERE (((decl.tipocontribuid = 5) AND decl.bln_reparo) AND (to_char((decl.fechapago)::timestamp with time zone, 'mm'::text) = to_char((declara.fechapago)::timestamp with time zone, 'mm'::text)))) AS totr_5, (SELECT sum(decl.montopagar) AS sum FROM declara decl WHERE (((decl.tipocontribuid = 6) AND decl.bln_reparo) AND (to_char((decl.fechapago)::timestamp with time zone, 'mm'::text) = to_char((declara.fechapago)::timestamp with time zone, 'mm'::text)))) AS totr_6, (SELECT sum(decl.montopagar) AS sum FROM declara decl WHERE (((to_char((decl.fechapago)::timestamp with time zone, 'yyyy'::text) = to_char((declara.fechapago)::timestamp with time zone, 'yyyy'::text)) AND (to_char((decl.fechapago)::timestamp with time zone, 'mm'::text) = to_char((declara.fechapago)::timestamp with time zone, 'mm'::text))) AND (NOT decl.bln_reparo))) AS tot_anio, (SELECT sum(intereses.totalpagar) AS sum FROM (pre_aprobacion.multas JOIN pre_aprobacion.intereses ON ((multas.id = intereses.multaid))) WHERE ((((multas.tipo_multa = 4) AND (to_char(intereses.fecha_pago, 'yyyy'::text) = to_char((declara.fechapago)::timestamp with time zone, 'yyyy'::text))) AND (to_char(intereses.fecha_pago, 'mm'::text) = to_char((declara.fechapago)::timestamp with time zone, 'mm'::text))) AND (intereses.fecha_pago IS NOT NULL))) AS interes_rise, (SELECT sum(intereses.totalpagar) AS sum FROM (pre_aprobacion.multas JOIN pre_aprobacion.intereses ON ((multas.id = intereses.multaid))) WHERE ((((multas.tipo_multa = 5) AND (to_char(intereses.fecha_pago, 'yyyy'::text) = to_char((declara.fechapago)::timestamp with time zone, 'yyyy'::text))) AND (to_char(intereses.fecha_pago, 'mm'::text) = to_char((declara.fechapago)::timestamp with time zone, 'mm'::text))) AND (intereses.fecha_pago IS NOT NULL))) AS interes_rc, (SELECT sum(decl.montopagar) AS sum FROM declara decl WHERE (decl.bln_reparo AND (to_char((decl.fechapago)::timestamp with time zone, 'mm'::text) = to_char((declara.fechapago)::timestamp with time zone, 'mm'::text)))) AS total_af, (SELECT sum(multas.montopagar) AS sum FROM (pre_aprobacion.multas JOIN pre_aprobacion.intereses ON ((multas.id = intereses.multaid))) WHERE ((((multas.tipo_multa = 5) AND (to_char(multas.fechapago, 'yyyy'::text) = to_char((declara.fechapago)::timestamp with time zone, 'yyyy'::text))) AND (to_char(multas.fechapago, 'mm'::text) = to_char((declara.fechapago)::timestamp with time zone, 'mm'::text))) AND (multas.fechapago IS NOT NULL))) AS reparos_rc FROM (((declara JOIN calpagod calpd ON ((declara.calpagodid = calpd.id))) JOIN calpago calp ON ((calp.id = calpd.calpagoid))) JOIN tipocont tcon ON ((tcon.tipegravid = calp.tipegravid))) WHERE (declara.fechapago IS NOT NULL) GROUP BY calp.ano, tcon.id, tcon.nombre, declara.fechapago, calpd.periodo, declara.montopagar ORDER BY ROW(tcon.id, to_char((declara.fechapago)::timestamp with time zone, 'mm'::text));


ALTER TABLE datos.vista_reporte_principal_recaudacion OWNER TO postgres;

--
-- TOC entry 282 (class 1259 OID 26609)
-- Dependencies: 3151 9
-- Name: vista_reportes_recaudacion_rise; Type: VIEW; Schema: datos; Owner: postgres
--

CREATE VIEW vista_reportes_recaudacion_rise AS
    SELECT mult.fechanotificacion AS fecha_notifi, to_char((mult.fechanotificacion)::timestamp with time zone, 'mm'::text) AS mesnoti, mult.nresolucion AS numero_resolucion, conu.nombre AS contribuyente, tcont.nombre AS tipo_cont, mult.montopagar AS total_multa, inte.totalpagar AS total_interes, CASE WHEN (mult.nudeposito IS NULL) THEN 'NO'::text ELSE 'SI'::text END AS cobrada, CASE WHEN (mult.fechanotificacion IS NULL) THEN 'NO'::text ELSE 'SI'::text END AS notificada, (SELECT sum(m.montopagar) AS sum FROM (pre_aprobacion.multas m JOIN detalles_contrib_calc con_calc ON ((con_calc.declaraid = m.declaraid))) WHERE (con_calc.contrib_calcid = d.id)) AS multa_pagar, (SELECT sum(i.totalpagar) AS sum FROM ((pre_aprobacion.multas m JOIN pre_aprobacion.intereses i ON ((i.multaid = m.id))) JOIN detalles_contrib_calc con_calc ON ((con_calc.declaraid = m.declaraid))) WHERE (con_calc.contrib_calcid = d.id)) AS interes_pagar, mult.fechaelaboracion AS fecha_multa, to_char(mult.fechaelaboracion, 'YYYY'::text) AS anio, mult.tipo_multa, mult.nudeposito AS deposito_multa, mult.declaraid AS multdclaid, conu.rif, tcont.id AS tipo_contribu FROM ((((((contrib_calc d JOIN detalles_contrib_calc dc ON ((d.id = dc.contrib_calcid))) JOIN pre_aprobacion.multas mult ON ((mult.declaraid = dc.declaraid))) JOIN pre_aprobacion.intereses inte ON ((inte.multaid = mult.id))) JOIN conusu conu ON ((conu.id = d.conusuid))) JOIN tipocont tcont ON ((tcont.id = d.tipocontid))) JOIN usfonpro usfp ON ((usfp.id = d.usuarioid)));


ALTER TABLE datos.vista_reportes_recaudacion_rise OWNER TO postgres;

--
-- TOC entry 283 (class 1259 OID 26614)
-- Dependencies: 3152 9
-- Name: vista_total_recaudacion_poranio; Type: VIEW; Schema: datos; Owner: postgres
--

CREATE VIEW vista_total_recaudacion_poranio AS
    SELECT to_char((declara.fechapago)::timestamp with time zone, 'yyyy'::text) AS anio, to_char((declara.fechapago)::timestamp with time zone, 'mm'::text) AS mes, (SELECT sum(d.montopagar) AS sum FROM declara d WHERE ((to_char((declara.fechapago)::timestamp with time zone, 'mm'::text) = to_char((d.fechapago)::timestamp with time zone, 'mm'::text)) AND (to_char((declara.fechapago)::timestamp with time zone, 'yyyy'::text) = to_char((d.fechapago)::timestamp with time zone, 'yyyy'::text)))) AS total_declara, (SELECT sum(multas.montopagar) AS sum FROM pre_aprobacion.multas WHERE ((to_char((declara.fechapago)::timestamp with time zone, 'mm'::text) = to_char(multas.fechapago, 'mm'::text)) AND (to_char((declara.fechapago)::timestamp with time zone, 'yyyy'::text) = to_char(multas.fechapago, 'yyyy'::text)))) AS total_multas, (SELECT sum(intereses.totalpagar) AS sum FROM (pre_aprobacion.intereses JOIN pre_aprobacion.multas ON ((intereses.multaid = multas.id))) WHERE ((to_char((declara.fechapago)::timestamp with time zone, 'mm'::text) = to_char(intereses.fecha_pago, 'mm'::text)) AND (to_char((declara.fechapago)::timestamp with time zone, 'yyyy'::text) = to_char(intereses.fecha_pago, 'yyyy'::text)))) AS total_interes FROM declara WHERE (declara.fechapago IS NOT NULL) ORDER BY to_char((declara.fechapago)::timestamp with time zone, 'mm'::text);


ALTER TABLE datos.vista_total_recaudacion_poranio OWNER TO postgres;

SET search_path = historial, pg_catalog;

--
-- TOC entry 284 (class 1259 OID 26619)
-- Dependencies: 2503 10
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
-- TOC entry 3839 (class 0 OID 0)
-- Dependencies: 284
-- Name: TABLE bitacora; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON TABLE bitacora IS 'Tabla con la bitacora de los datos cambiados de todas las tablas del sistema';


--
-- TOC entry 3840 (class 0 OID 0)
-- Dependencies: 284
-- Name: COLUMN bitacora.id; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON COLUMN bitacora.id IS 'Identificador de la bitacora';


--
-- TOC entry 3841 (class 0 OID 0)
-- Dependencies: 284
-- Name: COLUMN bitacora.fecha; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON COLUMN bitacora.fecha IS 'Fecha/Hora de la transaccion';


--
-- TOC entry 3842 (class 0 OID 0)
-- Dependencies: 284
-- Name: COLUMN bitacora.tabla; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON COLUMN bitacora.tabla IS 'Nombre de tabla sobre la cual se ejecuto la transaccion';


--
-- TOC entry 3843 (class 0 OID 0)
-- Dependencies: 284
-- Name: COLUMN bitacora.idusuario; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON COLUMN bitacora.idusuario IS 'Identificador del usuario que genero la transaccion';


--
-- TOC entry 3844 (class 0 OID 0)
-- Dependencies: 284
-- Name: COLUMN bitacora.accion; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON COLUMN bitacora.accion IS 'Accion ejecutada sobre la tabla. 0.- Insert / 1.- Update / 2.- Delete';


--
-- TOC entry 3845 (class 0 OID 0)
-- Dependencies: 284
-- Name: COLUMN bitacora.datosnew; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON COLUMN bitacora.datosnew IS 'Datos nuevos para el caso de los insert y los Update';


--
-- TOC entry 3846 (class 0 OID 0)
-- Dependencies: 284
-- Name: COLUMN bitacora.datosold; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON COLUMN bitacora.datosold IS 'Datos originales para el caso de los Update';


--
-- TOC entry 3847 (class 0 OID 0)
-- Dependencies: 284
-- Name: COLUMN bitacora.datosdel; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON COLUMN bitacora.datosdel IS 'Datos eliminados para el caso de los Delete';


--
-- TOC entry 3848 (class 0 OID 0)
-- Dependencies: 284
-- Name: COLUMN bitacora.valdelid; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON COLUMN bitacora.valdelid IS 'ID del registro que fue borrado';


--
-- TOC entry 3849 (class 0 OID 0)
-- Dependencies: 284
-- Name: COLUMN bitacora.ip; Type: COMMENT; Schema: historial; Owner: postgres
--

COMMENT ON COLUMN bitacora.ip IS 'Direccion IP que genero la transaccion';


--
-- TOC entry 285 (class 1259 OID 26626)
-- Dependencies: 10 284
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
-- TOC entry 3851 (class 0 OID 0)
-- Dependencies: 285
-- Name: Bitacora_IDBitacora_seq; Type: SEQUENCE OWNED BY; Schema: historial; Owner: postgres
--

ALTER SEQUENCE "Bitacora_IDBitacora_seq" OWNED BY bitacora.id;


SET search_path = pre_aprobacion, pg_catalog;

--
-- TOC entry 286 (class 1259 OID 26628)
-- Dependencies: 6 253
-- Name: intereses_id_seq; Type: SEQUENCE; Schema: pre_aprobacion; Owner: postgres
--

CREATE SEQUENCE intereses_id_seq
    START WITH 1
    INCREMENT BY 1
    MINVALUE 0
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pre_aprobacion.intereses_id_seq OWNER TO postgres;

--
-- TOC entry 3853 (class 0 OID 0)
-- Dependencies: 286
-- Name: intereses_id_seq; Type: SEQUENCE OWNED BY; Schema: pre_aprobacion; Owner: postgres
--

ALTER SEQUENCE intereses_id_seq OWNED BY intereses.id;


--
-- TOC entry 287 (class 1259 OID 26630)
-- Dependencies: 6 254
-- Name: multas_id_seq; Type: SEQUENCE; Schema: pre_aprobacion; Owner: postgres
--

CREATE SEQUENCE multas_id_seq
    START WITH 1
    INCREMENT BY 1
    MINVALUE 0
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pre_aprobacion.multas_id_seq OWNER TO postgres;

--
-- TOC entry 3854 (class 0 OID 0)
-- Dependencies: 287
-- Name: multas_id_seq; Type: SEQUENCE OWNED BY; Schema: pre_aprobacion; Owner: postgres
--

ALTER SEQUENCE multas_id_seq OWNED BY multas.id;


SET search_path = public, pg_catalog;

--
-- TOC entry 288 (class 1259 OID 26632)
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
-- TOC entry 289 (class 1259 OID 26635)
-- Dependencies: 2505 2506 2507 2508 7
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
-- TOC entry 3855 (class 0 OID 0)
-- Dependencies: 289
-- Name: TABLE tbl_ci_sessions; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON TABLE tbl_ci_sessions IS 'Sesiones manejadas por CodeIgniter';


--
-- TOC entry 290 (class 1259 OID 26645)
-- Dependencies: 2509 7
-- Name: tbl_modulo; Type: TABLE; Schema: seg; Owner: postgres; Tablespace: 
--

CREATE TABLE tbl_modulo (
    id_modulo bigint NOT NULL,
    id_padre bigint,
    str_nombre character varying(300) NOT NULL,
    str_descripcion character varying(500) NOT NULL,
    str_enlace character varying(100),
    bln_borrado boolean DEFAULT false NOT NULL,
    orden_menu integer,
    orden_pestanas integer
);


ALTER TABLE seg.tbl_modulo OWNER TO postgres;

--
-- TOC entry 3856 (class 0 OID 0)
-- Dependencies: 290
-- Name: TABLE tbl_modulo; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON TABLE tbl_modulo IS 'Módulos del sistema';


--
-- TOC entry 291 (class 1259 OID 26652)
-- Dependencies: 290 7
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
-- TOC entry 3857 (class 0 OID 0)
-- Dependencies: 291
-- Name: tbl_modulo_id_modulo_seq; Type: SEQUENCE OWNED BY; Schema: seg; Owner: postgres
--

ALTER SEQUENCE tbl_modulo_id_modulo_seq OWNED BY tbl_modulo.id_modulo;


--
-- TOC entry 292 (class 1259 OID 26654)
-- Dependencies: 2511 7
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
-- TOC entry 3858 (class 0 OID 0)
-- Dependencies: 292
-- Name: TABLE tbl_permiso; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON TABLE tbl_permiso IS 'Permisos de los roles sobre los módulos';


--
-- TOC entry 293 (class 1259 OID 26658)
-- Dependencies: 7 292
-- Name: tbl_permiso_id_permiso_seq; Type: SEQUENCE; Schema: seg; Owner: postgres
--

CREATE SEQUENCE tbl_permiso_id_permiso_seq
    START WITH 1
    INCREMENT BY 1
    MINVALUE 0
    NO MAXVALUE
    CACHE 1;


ALTER TABLE seg.tbl_permiso_id_permiso_seq OWNER TO postgres;

--
-- TOC entry 3859 (class 0 OID 0)
-- Dependencies: 293
-- Name: tbl_permiso_id_permiso_seq; Type: SEQUENCE OWNED BY; Schema: seg; Owner: postgres
--

ALTER SEQUENCE tbl_permiso_id_permiso_seq OWNED BY tbl_permiso.id_permiso;


--
-- TOC entry 294 (class 1259 OID 26660)
-- Dependencies: 2513 7
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
-- TOC entry 3860 (class 0 OID 0)
-- Dependencies: 294
-- Name: TABLE tbl_permiso_trampa; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON TABLE tbl_permiso_trampa IS 'Permisos de los roles sobre los módulos';


--
-- TOC entry 295 (class 1259 OID 26664)
-- Dependencies: 294 7
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
-- TOC entry 3861 (class 0 OID 0)
-- Dependencies: 295
-- Name: tbl_permiso_trampa_id_permiso_seq; Type: SEQUENCE OWNED BY; Schema: seg; Owner: postgres
--

ALTER SEQUENCE tbl_permiso_trampa_id_permiso_seq OWNED BY tbl_permiso_trampa.id_permiso;


--
-- TOC entry 296 (class 1259 OID 26666)
-- Dependencies: 2515 7
-- Name: tbl_permiso_usuario; Type: TABLE; Schema: seg; Owner: postgres; Tablespace: 
--

CREATE TABLE tbl_permiso_usuario (
    id_permiso_usuario bigint NOT NULL,
    id_usuario bigint NOT NULL,
    id_modulo bigint NOT NULL,
    bol_borrado boolean DEFAULT false NOT NULL,
    int_permiso_usu integer
);


ALTER TABLE seg.tbl_permiso_usuario OWNER TO postgres;

--
-- TOC entry 3862 (class 0 OID 0)
-- Dependencies: 296
-- Name: TABLE tbl_permiso_usuario; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON TABLE tbl_permiso_usuario IS 'Permisos de los roles de usuarios sobre los módulos';


--
-- TOC entry 297 (class 1259 OID 26670)
-- Dependencies: 2517 7
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
-- TOC entry 3863 (class 0 OID 0)
-- Dependencies: 297
-- Name: TABLE tbl_rol; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON TABLE tbl_rol IS 'Roles de los usuarios del sistema';


--
-- TOC entry 298 (class 1259 OID 26677)
-- Dependencies: 297 7
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
-- TOC entry 3864 (class 0 OID 0)
-- Dependencies: 298
-- Name: tbl_rol_id_rol_seq; Type: SEQUENCE OWNED BY; Schema: seg; Owner: postgres
--

ALTER SEQUENCE tbl_rol_id_rol_seq OWNED BY tbl_rol.id_rol;


--
-- TOC entry 299 (class 1259 OID 26679)
-- Dependencies: 2519 7
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
-- TOC entry 3865 (class 0 OID 0)
-- Dependencies: 299
-- Name: TABLE tbl_rol_usuario; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON TABLE tbl_rol_usuario IS 'Roles de los usuarios, un usuario puede tener multiples roles dentro del sistema';


--
-- TOC entry 3866 (class 0 OID 0)
-- Dependencies: 299
-- Name: COLUMN tbl_rol_usuario.id_rol_usuario; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON COLUMN tbl_rol_usuario.id_rol_usuario IS 'Identificador del usuario';


--
-- TOC entry 3867 (class 0 OID 0)
-- Dependencies: 299
-- Name: COLUMN tbl_rol_usuario.id_rol; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON COLUMN tbl_rol_usuario.id_rol IS 'Relación con el rol';


--
-- TOC entry 3868 (class 0 OID 0)
-- Dependencies: 299
-- Name: COLUMN tbl_rol_usuario.id_usuario; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON COLUMN tbl_rol_usuario.id_usuario IS 'Relación con el usuario';


--
-- TOC entry 3869 (class 0 OID 0)
-- Dependencies: 299
-- Name: COLUMN tbl_rol_usuario.bln_borrado; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON COLUMN tbl_rol_usuario.bln_borrado IS 'Marca de borrado lógico';


--
-- TOC entry 300 (class 1259 OID 26683)
-- Dependencies: 299 7
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
-- TOC entry 3870 (class 0 OID 0)
-- Dependencies: 300
-- Name: tbl_rol_usuario_id_rol_usuario_seq; Type: SEQUENCE OWNED BY; Schema: seg; Owner: postgres
--

ALTER SEQUENCE tbl_rol_usuario_id_rol_usuario_seq OWNED BY tbl_rol_usuario.id_rol_usuario;


--
-- TOC entry 301 (class 1259 OID 26685)
-- Dependencies: 2521 2522 2523 2524 7
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
-- TOC entry 3871 (class 0 OID 0)
-- Dependencies: 301
-- Name: TABLE tbl_session_ci; Type: COMMENT; Schema: seg; Owner: postgres
--

COMMENT ON TABLE tbl_session_ci IS 'Sesiones manejadas por CodeIgniter';


--
-- TOC entry 302 (class 1259 OID 26695)
-- Dependencies: 296 7
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
-- TOC entry 3872 (class 0 OID 0)
-- Dependencies: 302
-- Name: tbl_usuario_rol_id_usuario_rol_seq; Type: SEQUENCE OWNED BY; Schema: seg; Owner: postgres
--

ALTER SEQUENCE tbl_usuario_rol_id_usuario_rol_seq OWNED BY tbl_permiso_usuario.id_permiso_usuario;


--
-- TOC entry 303 (class 1259 OID 26697)
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
    id_padre bigint,
    orden_menu integer
);


ALTER TABLE seg.view_modulo_usuario_permiso OWNER TO postgres;

--
-- TOC entry 304 (class 1259 OID 26703)
-- Dependencies: 3153 7
-- Name: vista_listado_reparos_culminados; Type: VIEW; Schema: seg; Owner: postgres
--

CREATE VIEW vista_listado_reparos_culminados AS
    SELECT rep.id AS reparoid, conu.nombre AS razon_social, conu.email, est.nombre AS nomest, usf.nombre AS fiscal, rep.fechaelab, rep.fecha_notificacion, CASE WHEN (((now())::date - date(rep.fecha_notificacion)) <= (SELECT CASE WHEN ((rep.recibido_por)::text = '3'::text) THEN 26 ELSE 21 END AS dias)) THEN 'verde'::text WHEN ((((now())::date - date(rep.fecha_notificacion)) > (SELECT CASE WHEN ((rep.recibido_por)::text = '3'::text) THEN 26 ELSE 21 END AS dias)) AND (((now())::date - date(rep.fecha_notificacion)) <= (SELECT CASE WHEN ((rep.recibido_por)::text = '3'::text) THEN 61 ELSE 56 END AS dias))) THEN 'amarillo'::text ELSE 'rojo'::text END AS semaforo, CASE WHEN ((SELECT count(*) AS count FROM datos.declara WHERE ((declara.reparoid = rep.id) AND (declara.fechapago IS NULL))) = 0) THEN 'CANCELADO'::text ELSE NULL::text END AS estado FROM ((((datos.reparos rep JOIN datos.conusu conu ON ((conu.id = rep.conusuid))) LEFT JOIN datos.contribu contri ON (((contri.rif)::text = (conu.rif)::text))) LEFT JOIN datos.estados est ON ((est.id = contri.estadoid))) JOIN datos.usfonpro usf ON ((usf.id = rep.usuarioid))) WHERE ((rep.bln_activo AND (NOT rep.bln_conformida)) AND (rep.proceso IS NULL)) ORDER BY CASE WHEN (((now())::date - date(rep.fecha_notificacion)) <= (SELECT CASE WHEN ((rep.recibido_por)::text = '3'::text) THEN 26 ELSE 21 END AS dias)) THEN 'verde'::text WHEN ((((now())::date - date(rep.fecha_notificacion)) > (SELECT CASE WHEN ((rep.recibido_por)::text = '3'::text) THEN 26 ELSE 21 END AS dias)) AND (((now())::date - date(rep.fecha_notificacion)) <= (SELECT CASE WHEN ((rep.recibido_por)::text = '3'::text) THEN 61 ELSE 56 END AS dias))) THEN 'amarillo'::text ELSE 'rojo'::text END;


ALTER TABLE seg.vista_listado_reparos_culminados OWNER TO postgres;

SET search_path = "segContribu", pg_catalog;

--
-- TOC entry 305 (class 1259 OID 26708)
-- Dependencies: 2525 8
-- Name: tbl_modulo_contribu; Type: TABLE; Schema: segContribu; Owner: postgres; Tablespace: 
--

CREATE TABLE tbl_modulo_contribu (
    id_modulo bigint NOT NULL,
    id_padre bigint,
    str_nombre character varying(300) NOT NULL,
    str_descripcion character varying(500) NOT NULL,
    str_enlace character varying(100),
    bln_borrado boolean DEFAULT false NOT NULL,
    orden_menu integer,
    orden_pestanas integer
);


ALTER TABLE "segContribu".tbl_modulo_contribu OWNER TO postgres;

--
-- TOC entry 3873 (class 0 OID 0)
-- Dependencies: 305
-- Name: TABLE tbl_modulo_contribu; Type: COMMENT; Schema: segContribu; Owner: postgres
--

COMMENT ON TABLE tbl_modulo_contribu IS 'Módulos del sistema';


--
-- TOC entry 306 (class 1259 OID 26715)
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
-- TOC entry 3874 (class 0 OID 0)
-- Dependencies: 306
-- Name: tbl_modulo_id_modulo_seq; Type: SEQUENCE OWNED BY; Schema: segContribu; Owner: postgres
--

ALTER SEQUENCE tbl_modulo_id_modulo_seq OWNED BY tbl_modulo_contribu.id_modulo;


--
-- TOC entry 307 (class 1259 OID 26717)
-- Dependencies: 2527 8
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
-- TOC entry 3875 (class 0 OID 0)
-- Dependencies: 307
-- Name: TABLE tbl_permiso_contribu; Type: COMMENT; Schema: segContribu; Owner: postgres
--

COMMENT ON TABLE tbl_permiso_contribu IS 'Permisos de los roles sobre los módulos';


--
-- TOC entry 308 (class 1259 OID 26721)
-- Dependencies: 307 8
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
-- TOC entry 3876 (class 0 OID 0)
-- Dependencies: 308
-- Name: tbl_permiso_id_permiso_seq; Type: SEQUENCE OWNED BY; Schema: segContribu; Owner: postgres
--

ALTER SEQUENCE tbl_permiso_id_permiso_seq OWNED BY tbl_permiso_contribu.id_permiso;


--
-- TOC entry 309 (class 1259 OID 26723)
-- Dependencies: 2529 8
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
-- TOC entry 3877 (class 0 OID 0)
-- Dependencies: 309
-- Name: TABLE tbl_rol_contribu; Type: COMMENT; Schema: segContribu; Owner: postgres
--

COMMENT ON TABLE tbl_rol_contribu IS 'Roles de los usuarios del sistema';


--
-- TOC entry 310 (class 1259 OID 26730)
-- Dependencies: 8 309
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
-- TOC entry 3878 (class 0 OID 0)
-- Dependencies: 310
-- Name: tbl_rol_id_rol_seq; Type: SEQUENCE OWNED BY; Schema: segContribu; Owner: postgres
--

ALTER SEQUENCE tbl_rol_id_rol_seq OWNED BY tbl_rol_contribu.id_rol;


--
-- TOC entry 311 (class 1259 OID 26732)
-- Dependencies: 2531 8
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
-- TOC entry 3879 (class 0 OID 0)
-- Dependencies: 311
-- Name: TABLE tbl_rol_usuario_contribu; Type: COMMENT; Schema: segContribu; Owner: postgres
--

COMMENT ON TABLE tbl_rol_usuario_contribu IS 'Roles de los usuarios, un usuario puede tener multiples roles dentro del sistema';


--
-- TOC entry 3880 (class 0 OID 0)
-- Dependencies: 311
-- Name: COLUMN tbl_rol_usuario_contribu.id_rol_usuario; Type: COMMENT; Schema: segContribu; Owner: postgres
--

COMMENT ON COLUMN tbl_rol_usuario_contribu.id_rol_usuario IS 'Identificador del usuario';


--
-- TOC entry 3881 (class 0 OID 0)
-- Dependencies: 311
-- Name: COLUMN tbl_rol_usuario_contribu.id_rol; Type: COMMENT; Schema: segContribu; Owner: postgres
--

COMMENT ON COLUMN tbl_rol_usuario_contribu.id_rol IS 'Relación con el rol';


--
-- TOC entry 3882 (class 0 OID 0)
-- Dependencies: 311
-- Name: COLUMN tbl_rol_usuario_contribu.id_usuario; Type: COMMENT; Schema: segContribu; Owner: postgres
--

COMMENT ON COLUMN tbl_rol_usuario_contribu.id_usuario IS 'Relación con el usuario';


--
-- TOC entry 3883 (class 0 OID 0)
-- Dependencies: 311
-- Name: COLUMN tbl_rol_usuario_contribu.bln_borrado; Type: COMMENT; Schema: segContribu; Owner: postgres
--

COMMENT ON COLUMN tbl_rol_usuario_contribu.bln_borrado IS 'Marca de borrado lógico';


--
-- TOC entry 312 (class 1259 OID 26736)
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
-- TOC entry 3884 (class 0 OID 0)
-- Dependencies: 312
-- Name: tbl_rol_usuario_id_rol_usuario_seq; Type: SEQUENCE OWNED BY; Schema: segContribu; Owner: postgres
--

ALTER SEQUENCE tbl_rol_usuario_id_rol_usuario_seq OWNED BY tbl_rol_usuario_contribu.id_rol_usuario;


--
-- TOC entry 313 (class 1259 OID 26738)
-- Dependencies: 2533 8
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
-- TOC entry 3885 (class 0 OID 0)
-- Dependencies: 313
-- Name: TABLE tbl_usuario_rol_contribu; Type: COMMENT; Schema: segContribu; Owner: postgres
--

COMMENT ON TABLE tbl_usuario_rol_contribu IS 'Permisos de los roles de usuarios sobre los módulos';


--
-- TOC entry 314 (class 1259 OID 26742)
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
-- TOC entry 3886 (class 0 OID 0)
-- Dependencies: 314
-- Name: tbl_usuario_rol_id_usuario_rol_seq; Type: SEQUENCE OWNED BY; Schema: segContribu; Owner: postgres
--

ALTER SEQUENCE tbl_usuario_rol_id_usuario_rol_seq OWNED BY tbl_usuario_rol_contribu.id_usuario_rol;


--
-- TOC entry 315 (class 1259 OID 26744)
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
-- TOC entry 2438 (class 2604 OID 26750)
-- Dependencies: 228 227
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY actas_reparo ALTER COLUMN id SET DEFAULT nextval('actas_reparo_id_seq'::regclass);


--
-- TOC entry 2356 (class 2604 OID 26751)
-- Dependencies: 168 167
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY actiecon ALTER COLUMN id SET DEFAULT nextval('"ActiEcon_IDActiEcon_seq"'::regclass);


--
-- TOC entry 2368 (class 2604 OID 26752)
-- Dependencies: 170 169
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY alicimp ALTER COLUMN id SET DEFAULT nextval('"AlicImp_IDAlicImp_seq"'::regclass);


--
-- TOC entry 2371 (class 2604 OID 26753)
-- Dependencies: 172 171
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asientod ALTER COLUMN id SET DEFAULT nextval('"AsientoD_IDAsientoD_seq"'::regclass);


--
-- TOC entry 2447 (class 2604 OID 26754)
-- Dependencies: 231 230
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asientom ALTER COLUMN id SET DEFAULT nextval('asientom_id_seq'::regclass);


--
-- TOC entry 2449 (class 2604 OID 26755)
-- Dependencies: 233 232
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asientomd ALTER COLUMN id SET DEFAULT nextval('asientomd_id_seq'::regclass);


--
-- TOC entry 2452 (class 2604 OID 26756)
-- Dependencies: 235 234
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asignacion_fiscales ALTER COLUMN id SET DEFAULT nextval('asignacion_fiscales_id_seq'::regclass);


--
-- TOC entry 2374 (class 2604 OID 26757)
-- Dependencies: 175 174
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY bacuenta ALTER COLUMN id SET DEFAULT nextval('"BaCuenta_IDBaCuenta_seq"'::regclass);


--
-- TOC entry 2376 (class 2604 OID 26758)
-- Dependencies: 177 176
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY bancos ALTER COLUMN id SET DEFAULT nextval('"Bancos_IDBanco_seq"'::regclass);


--
-- TOC entry 2379 (class 2604 OID 26759)
-- Dependencies: 181 180
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY calpago ALTER COLUMN id SET DEFAULT nextval('"CalPagos_IDCalPago_seq"'::regclass);


--
-- TOC entry 2377 (class 2604 OID 26760)
-- Dependencies: 179 178
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY calpagod ALTER COLUMN id SET DEFAULT nextval('"CalPagoD_IDCalPagoD_seq"'::regclass);


--
-- TOC entry 2380 (class 2604 OID 26761)
-- Dependencies: 183 182
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY cargos ALTER COLUMN id SET DEFAULT nextval('"Cargos_IDCargo_seq"'::regclass);


--
-- TOC entry 2381 (class 2604 OID 26762)
-- Dependencies: 185 184
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY ciudades ALTER COLUMN id SET DEFAULT nextval('"Ciudades_IDCiudad_seq"'::regclass);


--
-- TOC entry 2454 (class 2604 OID 26763)
-- Dependencies: 237 236
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY con_img_doc ALTER COLUMN id SET DEFAULT nextval('con_img_doc_id_seq'::regclass);


--
-- TOC entry 2456 (class 2604 OID 26764)
-- Dependencies: 239 238
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY contrib_calc ALTER COLUMN id SET DEFAULT nextval('contrib_calc_id_seq'::regclass);


--
-- TOC entry 2400 (class 2604 OID 26765)
-- Dependencies: 195 194
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY contribu ALTER COLUMN id SET DEFAULT nextval('"Contribu_IDContribu_seq"'::regclass);


--
-- TOC entry 2457 (class 2604 OID 26766)
-- Dependencies: 241 240
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY contributi ALTER COLUMN id SET DEFAULT nextval('contributi_id_seq'::regclass);


--
-- TOC entry 2394 (class 2604 OID 26767)
-- Dependencies: 193 192
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusu ALTER COLUMN id SET DEFAULT nextval('"ConUsu_IDConUsu_seq"'::regclass);


--
-- TOC entry 2461 (class 2604 OID 26768)
-- Dependencies: 243 242
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusu_interno ALTER COLUMN id SET DEFAULT nextval('conusu_interno_id_seq'::regclass);


--
-- TOC entry 2463 (class 2604 OID 26769)
-- Dependencies: 245 244
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusu_tipocont ALTER COLUMN id SET DEFAULT nextval('conusu_tipocon_id_seq'::regclass);


--
-- TOC entry 2382 (class 2604 OID 26770)
-- Dependencies: 187 186
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusuco ALTER COLUMN id SET DEFAULT nextval('"ConUsuCo_IDConUsuCo_seq"'::regclass);


--
-- TOC entry 2386 (class 2604 OID 26771)
-- Dependencies: 189 188
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusuti ALTER COLUMN id SET DEFAULT nextval('"ConUsuTi_IDConUsuTi_seq"'::regclass);


--
-- TOC entry 2389 (class 2604 OID 26772)
-- Dependencies: 191 190
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusuto ALTER COLUMN id SET DEFAULT nextval('"ConUsuTo_IDConUsuTo_seq"'::regclass);


--
-- TOC entry 2464 (class 2604 OID 26773)
-- Dependencies: 247 246
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY correlativos_actas ALTER COLUMN id SET DEFAULT nextval('correlativos_actas_id_seq'::regclass);


--
-- TOC entry 2465 (class 2604 OID 26774)
-- Dependencies: 249 248
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY correos_enviados ALTER COLUMN id SET DEFAULT nextval('correos_enviados_id_seq'::regclass);


--
-- TOC entry 2409 (class 2604 OID 26775)
-- Dependencies: 199 198
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY departam ALTER COLUMN id SET DEFAULT nextval('"Departam_IDDepartam_seq"'::regclass);


--
-- TOC entry 2479 (class 2604 OID 26776)
-- Dependencies: 257 256
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY descargos ALTER COLUMN id SET DEFAULT nextval('descargos_id_seq'::regclass);


--
-- TOC entry 2480 (class 2604 OID 26777)
-- Dependencies: 259 258
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY detalle_interes ALTER COLUMN id SET DEFAULT nextval('detalle_interes_id_seq'::regclass);


--
-- TOC entry 2481 (class 2604 OID 26778)
-- Dependencies: 261 260
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY detalles_contrib_calc ALTER COLUMN id SET DEFAULT nextval('detalles_contrib_calc_id_seq'::regclass);


--
-- TOC entry 2485 (class 2604 OID 26779)
-- Dependencies: 263 262
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY dettalles_fizcalizacion ALTER COLUMN id SET DEFAULT nextval('dettalles_fizcalizacion_id_seq'::regclass);


--
-- TOC entry 2487 (class 2604 OID 26780)
-- Dependencies: 265 264
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY document ALTER COLUMN id SET DEFAULT nextval('document_id_seq'::regclass);


--
-- TOC entry 2413 (class 2604 OID 26781)
-- Dependencies: 203 202
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY entidad ALTER COLUMN id SET DEFAULT nextval('"Entidad_IDEntidad_seq"'::regclass);


--
-- TOC entry 2411 (class 2604 OID 26782)
-- Dependencies: 201 200
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY entidadd ALTER COLUMN id SET DEFAULT nextval('"EntidadD_IDEntidadD_seq"'::regclass);


--
-- TOC entry 2414 (class 2604 OID 26783)
-- Dependencies: 205 204
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY estados ALTER COLUMN id SET DEFAULT nextval('"Estados_IDEstado_seq"'::regclass);


--
-- TOC entry 2488 (class 2604 OID 26784)
-- Dependencies: 267 266
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY interes_bcv ALTER COLUMN id SET DEFAULT nextval('interes_bcv_id_seq'::regclass);


--
-- TOC entry 2417 (class 2604 OID 26785)
-- Dependencies: 209 208
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY perusu ALTER COLUMN id SET DEFAULT nextval('"PerUsu_IDPerUsu_seq"'::regclass);


--
-- TOC entry 2415 (class 2604 OID 26786)
-- Dependencies: 207 206
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY perusud ALTER COLUMN id SET DEFAULT nextval('"PerUsuD_IDPerUsuD_seq"'::regclass);


--
-- TOC entry 2418 (class 2604 OID 26787)
-- Dependencies: 211 210
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY pregsecr ALTER COLUMN id SET DEFAULT nextval('"PregSecr_IDPregSecr_seq"'::regclass);


--
-- TOC entry 2492 (class 2604 OID 26788)
-- Dependencies: 269 268
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY presidente ALTER COLUMN id SET DEFAULT nextval('presidente_id_seq2'::regclass);


--
-- TOC entry 2419 (class 2604 OID 26789)
-- Dependencies: 213 212
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY replegal ALTER COLUMN id SET DEFAULT nextval('"RepLegal_IDRepLegal_seq"'::regclass);


--
-- TOC entry 2420 (class 2604 OID 26790)
-- Dependencies: 215 214
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tdeclara ALTER COLUMN id SET DEFAULT nextval('"TDeclara_IDTDeclara_seq"'::regclass);


--
-- TOC entry 2423 (class 2604 OID 26791)
-- Dependencies: 217 216
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tipegrav ALTER COLUMN id SET DEFAULT nextval('"TiPeGrav_IDTiPeGrav_seq"'::regclass);


--
-- TOC entry 2424 (class 2604 OID 26792)
-- Dependencies: 219 218
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tipocont ALTER COLUMN id SET DEFAULT nextval('"TipoCont_IDTipoCont_seq"'::regclass);


--
-- TOC entry 2426 (class 2604 OID 26793)
-- Dependencies: 221 220
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY undtrib ALTER COLUMN id SET DEFAULT nextval('"UndTrib_IDUndTrib_seq"'::regclass);


--
-- TOC entry 2432 (class 2604 OID 26794)
-- Dependencies: 225 224
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY usfonpro ALTER COLUMN id SET DEFAULT nextval('"Usuarios_IDUsuario_seq"'::regclass);


--
-- TOC entry 2428 (class 2604 OID 26795)
-- Dependencies: 223 222
-- Name: id; Type: DEFAULT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY usfonpto ALTER COLUMN id SET DEFAULT nextval('"UsFonpTo_IDUsFonpTo_seq"'::regclass);


SET search_path = historial, pg_catalog;

--
-- TOC entry 2504 (class 2604 OID 26796)
-- Dependencies: 285 284
-- Name: id; Type: DEFAULT; Schema: historial; Owner: postgres
--

ALTER TABLE ONLY bitacora ALTER COLUMN id SET DEFAULT nextval('"Bitacora_IDBitacora_seq"'::regclass);


SET search_path = pre_aprobacion, pg_catalog;

--
-- TOC entry 2477 (class 2604 OID 26797)
-- Dependencies: 286 253
-- Name: id; Type: DEFAULT; Schema: pre_aprobacion; Owner: postgres
--

ALTER TABLE ONLY intereses ALTER COLUMN id SET DEFAULT nextval('intereses_id_seq'::regclass);


--
-- TOC entry 2478 (class 2604 OID 26798)
-- Dependencies: 287 254
-- Name: id; Type: DEFAULT; Schema: pre_aprobacion; Owner: postgres
--

ALTER TABLE ONLY multas ALTER COLUMN id SET DEFAULT nextval('multas_id_seq'::regclass);


SET search_path = seg, pg_catalog;

--
-- TOC entry 2510 (class 2604 OID 26799)
-- Dependencies: 291 290
-- Name: id_modulo; Type: DEFAULT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_modulo ALTER COLUMN id_modulo SET DEFAULT nextval('tbl_modulo_id_modulo_seq'::regclass);


--
-- TOC entry 2512 (class 2604 OID 26800)
-- Dependencies: 293 292
-- Name: id_permiso; Type: DEFAULT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_permiso ALTER COLUMN id_permiso SET DEFAULT nextval('tbl_permiso_id_permiso_seq'::regclass);


--
-- TOC entry 2514 (class 2604 OID 26801)
-- Dependencies: 295 294
-- Name: id_permiso; Type: DEFAULT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_permiso_trampa ALTER COLUMN id_permiso SET DEFAULT nextval('tbl_permiso_trampa_id_permiso_seq'::regclass);


--
-- TOC entry 2516 (class 2604 OID 26802)
-- Dependencies: 302 296
-- Name: id_permiso_usuario; Type: DEFAULT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_permiso_usuario ALTER COLUMN id_permiso_usuario SET DEFAULT nextval('tbl_usuario_rol_id_usuario_rol_seq'::regclass);


--
-- TOC entry 2518 (class 2604 OID 26803)
-- Dependencies: 298 297
-- Name: id_rol; Type: DEFAULT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_rol ALTER COLUMN id_rol SET DEFAULT nextval('tbl_rol_id_rol_seq'::regclass);


--
-- TOC entry 2520 (class 2604 OID 26804)
-- Dependencies: 300 299
-- Name: id_rol_usuario; Type: DEFAULT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_rol_usuario ALTER COLUMN id_rol_usuario SET DEFAULT nextval('tbl_rol_usuario_id_rol_usuario_seq'::regclass);


SET search_path = "segContribu", pg_catalog;

--
-- TOC entry 2526 (class 2604 OID 26805)
-- Dependencies: 306 305
-- Name: id_modulo; Type: DEFAULT; Schema: segContribu; Owner: postgres
--

ALTER TABLE ONLY tbl_modulo_contribu ALTER COLUMN id_modulo SET DEFAULT nextval('tbl_modulo_id_modulo_seq'::regclass);


--
-- TOC entry 2528 (class 2604 OID 26806)
-- Dependencies: 308 307
-- Name: id_permiso; Type: DEFAULT; Schema: segContribu; Owner: postgres
--

ALTER TABLE ONLY tbl_permiso_contribu ALTER COLUMN id_permiso SET DEFAULT nextval('tbl_permiso_id_permiso_seq'::regclass);


--
-- TOC entry 2530 (class 2604 OID 26807)
-- Dependencies: 310 309
-- Name: id_rol; Type: DEFAULT; Schema: segContribu; Owner: postgres
--

ALTER TABLE ONLY tbl_rol_contribu ALTER COLUMN id_rol SET DEFAULT nextval('tbl_rol_id_rol_seq'::regclass);


--
-- TOC entry 2532 (class 2604 OID 26808)
-- Dependencies: 312 311
-- Name: id_rol_usuario; Type: DEFAULT; Schema: segContribu; Owner: postgres
--

ALTER TABLE ONLY tbl_rol_usuario_contribu ALTER COLUMN id_rol_usuario SET DEFAULT nextval('tbl_rol_usuario_id_rol_usuario_seq'::regclass);


--
-- TOC entry 2534 (class 2604 OID 26809)
-- Dependencies: 314 313
-- Name: id_usuario_rol; Type: DEFAULT; Schema: segContribu; Owner: postgres
--

ALTER TABLE ONLY tbl_usuario_rol_contribu ALTER COLUMN id_usuario_rol SET DEFAULT nextval('tbl_usuario_rol_id_usuario_rol_seq'::regclass);


SET search_path = datos, pg_catalog;

--
-- TOC entry 3887 (class 0 OID 0)
-- Dependencies: 166
-- Name: Accionis_ID_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Accionis_ID_seq"', 90, true);


--
-- TOC entry 3888 (class 0 OID 0)
-- Dependencies: 168
-- Name: ActiEcon_IDActiEcon_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"ActiEcon_IDActiEcon_seq"', 16, true);


--
-- TOC entry 3889 (class 0 OID 0)
-- Dependencies: 170
-- Name: AlicImp_IDAlicImp_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"AlicImp_IDAlicImp_seq"', 11, true);


--
-- TOC entry 3890 (class 0 OID 0)
-- Dependencies: 172
-- Name: AsientoD_IDAsientoD_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"AsientoD_IDAsientoD_seq"', 6, true);


--
-- TOC entry 3891 (class 0 OID 0)
-- Dependencies: 173
-- Name: Asiento_IDAsiento_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Asiento_IDAsiento_seq"', 2, true);


--
-- TOC entry 3892 (class 0 OID 0)
-- Dependencies: 175
-- Name: BaCuenta_IDBaCuenta_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"BaCuenta_IDBaCuenta_seq"', 7, true);


--
-- TOC entry 3893 (class 0 OID 0)
-- Dependencies: 177
-- Name: Bancos_IDBanco_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Bancos_IDBanco_seq"', 2, true);


--
-- TOC entry 3894 (class 0 OID 0)
-- Dependencies: 179
-- Name: CalPagoD_IDCalPagoD_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"CalPagoD_IDCalPagoD_seq"', 0, true);


--
-- TOC entry 3895 (class 0 OID 0)
-- Dependencies: 181
-- Name: CalPagos_IDCalPago_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"CalPagos_IDCalPago_seq"', 0, true);


--
-- TOC entry 3896 (class 0 OID 0)
-- Dependencies: 183
-- Name: Cargos_IDCargo_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Cargos_IDCargo_seq"', 18, true);


--
-- TOC entry 3897 (class 0 OID 0)
-- Dependencies: 185
-- Name: Ciudades_IDCiudad_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Ciudades_IDCiudad_seq"', 360, true);


--
-- TOC entry 3898 (class 0 OID 0)
-- Dependencies: 187
-- Name: ConUsuCo_IDConUsuCo_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"ConUsuCo_IDConUsuCo_seq"', 1, false);


--
-- TOC entry 3899 (class 0 OID 0)
-- Dependencies: 189
-- Name: ConUsuTi_IDConUsuTi_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"ConUsuTi_IDConUsuTi_seq"', 1, true);


--
-- TOC entry 3900 (class 0 OID 0)
-- Dependencies: 191
-- Name: ConUsuTo_IDConUsuTo_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"ConUsuTo_IDConUsuTo_seq"', 144, true);


--
-- TOC entry 3901 (class 0 OID 0)
-- Dependencies: 193
-- Name: ConUsu_IDConUsu_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"ConUsu_IDConUsu_seq"', 38, true);


--
-- TOC entry 3902 (class 0 OID 0)
-- Dependencies: 195
-- Name: Contribu_IDContribu_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Contribu_IDContribu_seq"', 38, true);


--
-- TOC entry 3903 (class 0 OID 0)
-- Dependencies: 197
-- Name: Declara_IDDeclara_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Declara_IDDeclara_seq"', 23, true);


--
-- TOC entry 3904 (class 0 OID 0)
-- Dependencies: 199
-- Name: Departam_IDDepartam_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Departam_IDDepartam_seq"', 12, true);


--
-- TOC entry 3905 (class 0 OID 0)
-- Dependencies: 201
-- Name: EntidadD_IDEntidadD_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"EntidadD_IDEntidadD_seq"', 1, false);


--
-- TOC entry 3906 (class 0 OID 0)
-- Dependencies: 203
-- Name: Entidad_IDEntidad_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Entidad_IDEntidad_seq"', 1, false);


--
-- TOC entry 3907 (class 0 OID 0)
-- Dependencies: 205
-- Name: Estados_IDEstado_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Estados_IDEstado_seq"', 27, true);


--
-- TOC entry 3908 (class 0 OID 0)
-- Dependencies: 207
-- Name: PerUsuD_IDPerUsuD_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"PerUsuD_IDPerUsuD_seq"', 1, false);


--
-- TOC entry 3909 (class 0 OID 0)
-- Dependencies: 209
-- Name: PerUsu_IDPerUsu_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"PerUsu_IDPerUsu_seq"', 1, false);


--
-- TOC entry 3910 (class 0 OID 0)
-- Dependencies: 211
-- Name: PregSecr_IDPregSecr_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"PregSecr_IDPregSecr_seq"', 7, true);


--
-- TOC entry 3911 (class 0 OID 0)
-- Dependencies: 213
-- Name: RepLegal_IDRepLegal_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"RepLegal_IDRepLegal_seq"', 38, true);


--
-- TOC entry 3912 (class 0 OID 0)
-- Dependencies: 215
-- Name: TDeclara_IDTDeclara_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"TDeclara_IDTDeclara_seq"', 8, true);


--
-- TOC entry 3913 (class 0 OID 0)
-- Dependencies: 217
-- Name: TiPeGrav_IDTiPeGrav_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"TiPeGrav_IDTiPeGrav_seq"', 6, true);


--
-- TOC entry 3914 (class 0 OID 0)
-- Dependencies: 219
-- Name: TipoCont_IDTipoCont_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"TipoCont_IDTipoCont_seq"', 7, true);


--
-- TOC entry 3915 (class 0 OID 0)
-- Dependencies: 221
-- Name: UndTrib_IDUndTrib_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"UndTrib_IDUndTrib_seq"', 35, true);


--
-- TOC entry 3916 (class 0 OID 0)
-- Dependencies: 223
-- Name: UsFonpTo_IDUsFonpTo_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"UsFonpTo_IDUsFonpTo_seq"', 1, false);


--
-- TOC entry 3917 (class 0 OID 0)
-- Dependencies: 225
-- Name: Usuarios_IDUsuario_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('"Usuarios_IDUsuario_seq"', 75, true);


--
-- TOC entry 3217 (class 0 OID 26316)
-- Dependencies: 226 3292
-- Data for Name: accionis; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY accionis (id, contribuid, nombre, apellido, ci, domfiscal, nuacciones, valaccion, cextra1, cextra2, cextra3, cextra4, cextra5, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 3218 (class 0 OID 26325)
-- Dependencies: 227 3292
-- Data for Name: actas_reparo; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY actas_reparo (id, numero, ruta_servidor, fecha_adjunto, usuarioid, ip, bln_conformida) FROM stdin;
\.


--
-- TOC entry 3918 (class 0 OID 0)
-- Dependencies: 228
-- Name: actas_reparo_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('actas_reparo_id_seq', 0, true);


--
-- TOC entry 3158 (class 0 OID 26087)
-- Dependencies: 167 3292
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
-- TOC entry 3160 (class 0 OID 26092)
-- Dependencies: 169 3292
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
-- TOC entry 3220 (class 0 OID 26335)
-- Dependencies: 229 3292
-- Data for Name: asiento; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY asiento (id, nuasiento, fecha, mes, ano, debe, haber, saldo, comentar, cerrado, uscierreid, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 3162 (class 0 OID 26108)
-- Dependencies: 171 3292
-- Data for Name: asientod; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY asientod (id, asientoid, fecha, cuenta, monto, sentido, referencia, comentar, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 3221 (class 0 OID 26349)
-- Dependencies: 230 3292
-- Data for Name: asientom; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY asientom (id, nombre, comentar, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 3919 (class 0 OID 0)
-- Dependencies: 231
-- Name: asientom_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('asientom_id_seq', 1, false);


--
-- TOC entry 3223 (class 0 OID 26357)
-- Dependencies: 232 3292
-- Data for Name: asientomd; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY asientomd (id, asientomid, cuenta, sentido, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 3920 (class 0 OID 0)
-- Dependencies: 233
-- Name: asientomd_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('asientomd_id_seq', 1, false);


--
-- TOC entry 3225 (class 0 OID 26363)
-- Dependencies: 234 3292
-- Data for Name: asignacion_fiscales; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY asignacion_fiscales (id, fecha_asignacion, usfonproid, conusuid, prioridad, estatus, fecha_fiscalizacion, usuarioid, ip, tipocontid, nro_autorizacion, periodo_afiscalizar) FROM stdin;
\.


--
-- TOC entry 3921 (class 0 OID 0)
-- Dependencies: 235
-- Name: asignacion_fiscales_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('asignacion_fiscales_id_seq', 0, true);


--
-- TOC entry 3165 (class 0 OID 26120)
-- Dependencies: 174 3292
-- Data for Name: bacuenta; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY bacuenta (id, bancoid, tipo_cuenta, usuarioid, ip, num_cuenta, fecha_registro, bln_borrado) FROM stdin;
1	1	CORRIENTE	48	127.0.0.1	0134-0031-88-0312118475	2014-02-03	f
2	1	CORRIENTE	48	127.0.0.1	0134-0031-88-0311126075	2014-02-03	f
3	1	CORRIENTE	48	127.0.0.1	0134-0861-18-8613000268	2014-02-03	f
4	1	CORRIENTE	48	127.0.0.1	0134-0861-18-8613000349	2014-02-03	f
5	2	CORRIENTE	48	127.0.0.1	0108-0582-13-0200023302	2014-02-03	f
6	2	CORRIENTE	48	127.0.0.1	0108-0582-19-0100031804	2014-02-03	f
7	2	AHORRO	48	127.0.0.1	0108-0582-10-0200023299	2014-02-03	f
\.


--
-- TOC entry 3167 (class 0 OID 26130)
-- Dependencies: 176 3292
-- Data for Name: bancos; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY bancos (id, nombre, usuarioid, ip, fecha_registro, bln_borrado) FROM stdin;
1	BANESCO	48	127.0.0.1	2014-02-03	f
2	PROVINCIAL	48	127.0.0.1	2014-02-03	f
\.


--
-- TOC entry 3171 (class 0 OID 26141)
-- Dependencies: 180 3292
-- Data for Name: calpago; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY calpago (id, nombre, ano, tipegravid, usuarioid, ip) FROM stdin;
59	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE TV SEÑAL  ABIERTA 2005	2005	3	48	127.0.0.1
60	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE DISTRIBUIDORES 2005	2005	4	48	127.0.0.1
61	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE TV SUSCRIPCION 2005	2005	5	48	127.0.0.1
62	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE TV SUSCRIPCION 2006	2006	5	48	127.0.0.1
63	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE PRODUCCION 2005	2005	6	48	127.0.0.1
64	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE PRODUCCION 2006	2006	6	48	127.0.0.1
65	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE EXHIBIDORES 2006	2006	1	48	127.0.0.1
66	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE VENTA Y ALQUILER 2006	2006	2	48	127.0.0.1
67	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE TV SEÑAL  ABIERTA 2006	2006	3	48	127.0.0.1
68	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE TV SEÑAL  ABIERTA 2007	2007	3	48	127.0.0.1
69	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE TV SEÑAL  ABIERTA 2008	2008	3	48	127.0.0.1
70	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE TV SEÑAL  ABIERTA 2009	2009	3	48	127.0.0.1
71	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE TV SEÑAL  ABIERTA 2010	2010	3	48	127.0.0.1
72	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE TV SEÑAL  ABIERTA 2011	2011	3	48	127.0.0.1
73	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE TV SEÑAL  ABIERTA 2012	2012	3	48	127.0.0.1
74	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE TV SEÑAL  ABIERTA 2013	2013	3	48	127.0.0.1
75	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE DISTRIBUIDORES 2006	2006	4	48	127.0.0.1
76	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE DISTRIBUIDORES 2007	2007	4	48	127.0.0.1
77	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE DISTRIBUIDORES 2008	2008	4	48	127.0.0.1
78	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE DISTRIBUIDORES 2009	2009	4	48	127.0.0.1
79	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE DISTRIBUIDORES 2010	2010	4	48	127.0.0.1
80	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE DISTRIBUIDORES 2011	2011	4	48	127.0.0.1
81	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE DISTRIBUIDORES 2012	2012	4	48	127.0.0.1
82	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE DISTRIBUIDORES 2013	2013	4	48	127.0.0.1
83	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE TV SUSCRIPCION 2007	2007	5	48	127.0.0.1
84	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE TV SUSCRIPCION 2008	2008	5	48	127.0.0.1
85	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE TV SUSCRIPCION 2009	2009	5	48	127.0.0.1
86	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE TV SUSCRIPCION 2010	2010	5	48	127.0.0.1
87	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE TV SUSCRIPCION 2011	2011	5	48	127.0.0.1
88	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE TV SUSCRIPCION 2012	2012	5	48	127.0.0.1
89	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE TV SUSCRIPCION 2013	2013	5	48	127.0.0.1
90	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE TV SUSCRIPCION 2014	2014	5	48	127.0.0.1
91	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE PRODUCCION 2007	2007	6	48	127.0.0.1
92	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE PRODUCCION 2008	2008	6	48	127.0.0.1
93	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE PRODUCCION 2009	2009	6	48	127.0.0.1
94	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE PRODUCCION 2010	2010	6	48	127.0.0.1
95	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE PRODUCCION 2011	2011	6	48	127.0.0.1
96	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE PRODUCCION 2012	2012	6	48	127.0.0.1
97	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE PRODUCCION 2013	2013	6	48	127.0.0.1
98	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE PRODUCCION 2014	2014	6	48	127.0.0.1
99	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE EXHIBIDORES 2007	2007	1	48	127.0.0.1
100	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE EXHIBIDORES 2008	2008	1	48	127.0.0.1
101	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE EXHIBIDORES 2009	2009	1	48	127.0.0.1
102	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE EXHIBIDORES 2010	2010	1	48	127.0.0.1
103	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE EXHIBIDORES 2011	2011	1	48	127.0.0.1
104	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE EXHIBIDORES 2012	2012	1	48	127.0.0.1
105	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE EXHIBIDORES 2013	2013	1	48	127.0.0.1
106	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE EXHIBIDORES 2014	2014	1	48	127.0.0.1
107	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE VENTA Y ALQUILER 2007	2007	2	48	127.0.0.1
108	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE VENTA Y ALQUILER 2008	2008	2	48	127.0.0.1
109	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE VENTA Y ALQUILER 2009	2009	2	48	127.0.0.1
110	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE VENTA Y ALQUILER 2010	2010	2	48	127.0.0.1
111	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE VENTA Y ALQUILER 2011	2011	2	48	127.0.0.1
112	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE VENTA Y ALQUILER 2012	2012	2	48	127.0.0.1
113	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE VENTA Y ALQUILER 2013	2013	2	48	127.0.0.1
114	CALENDARIO DE OBLIGACIONES TRIBUTARIAS PERIODO GRAVABLE DE VENTA Y ALQUILER 2014	2014	2	48	127.0.0.1
\.


--
-- TOC entry 3169 (class 0 OID 26136)
-- Dependencies: 178 3292
-- Data for Name: calpagod; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY calpagod (id, calpagoid, fechaini, fechafin, fechalim, usuarioid, ip, periodo) FROM stdin;
385	59	2005-01-01	2005-12-31	2006-02-14	48	127.0.0.1	01
386	60	2005-01-01	2005-12-31	2006-02-14	48	127.0.0.1	01
387	61	2005-01-01	2005-03-31	2005-04-15	48	127.0.0.1	01
388	61	2005-04-01	2005-06-30	2005-07-15	48	127.0.0.1	02
389	61	2005-07-01	2005-09-30	2005-10-17	48	127.0.0.1	03
390	61	2005-10-01	2005-12-31	2006-01-16	48	127.0.0.1	04
391	62	2006-01-01	2006-03-31	2006-04-17	48	127.0.0.1	01
392	62	2006-04-01	2006-06-30	2006-07-17	48	127.0.0.1	02
393	62	2006-07-01	2006-09-30	2006-10-16	48	127.0.0.1	03
394	62	2006-10-01	2006-12-31	2007-01-15	48	127.0.0.1	04
395	63	2005-01-01	2005-03-31	2005-04-15	48	127.0.0.1	01
396	63	2005-04-01	2005-06-30	2005-07-15	48	127.0.0.1	02
397	63	2005-07-01	2005-09-30	2005-10-17	48	127.0.0.1	03
398	63	2005-10-01	2005-12-31	2006-01-23	48	127.0.0.1	04
399	64	2006-01-01	2006-03-31	2006-04-26	48	127.0.0.1	01
400	64	2006-04-01	2006-06-30	2006-07-26	48	127.0.0.1	02
401	64	2006-07-01	2006-09-30	2006-10-23	48	127.0.0.1	03
402	64	2006-10-01	2006-12-31	2007-01-22	48	127.0.0.1	04
403	65	2006-01-01	2006-01-31	2006-02-21	48	127.0.0.1	01
404	65	2006-02-01	2006-02-28	2006-03-21	48	127.0.0.1	02
405	65	2006-03-01	2006-03-31	2006-04-26	48	127.0.0.1	03
406	65	2006-04-01	2006-04-30	2006-05-22	48	127.0.0.1	04
407	65	2006-05-01	2006-05-31	2006-06-22	48	127.0.0.1	05
408	65	2006-06-01	2006-06-30	2006-07-26	48	127.0.0.1	06
409	65	2006-07-01	2006-07-31	2006-08-22	48	127.0.0.1	07
410	65	2006-08-01	2006-08-31	2006-09-21	48	127.0.0.1	08
411	65	2006-09-01	2006-09-30	2006-10-23	48	127.0.0.1	09
412	65	2006-10-01	2006-10-31	2006-11-22	48	127.0.0.1	10
413	65	2006-11-01	2006-11-30	2006-12-22	48	127.0.0.1	11
414	65	2006-12-01	2006-12-31	2007-01-22	48	127.0.0.1	12
415	66	2006-01-01	2006-01-31	2006-02-15	48	127.0.0.1	01
416	66	2006-02-01	2006-02-28	2006-03-15	48	127.0.0.1	02
417	66	2006-03-01	2006-03-31	2006-04-17	48	127.0.0.1	03
418	66	2006-04-01	2006-04-30	2006-05-15	48	127.0.0.1	04
419	66	2006-05-01	2006-05-31	2006-06-15	48	127.0.0.1	05
420	66	2006-06-01	2006-06-30	2006-07-17	48	127.0.0.1	06
421	66	2006-07-01	2006-07-31	2006-08-15	48	127.0.0.1	07
422	66	2006-08-01	2006-08-31	2006-09-15	48	127.0.0.1	08
423	66	2006-09-01	2006-09-30	2006-10-16	48	127.0.0.1	09
424	66	2006-10-01	2006-10-31	2006-11-15	48	127.0.0.1	10
425	66	2006-11-01	2006-11-30	2006-12-15	48	127.0.0.1	11
426	66	2006-12-01	2006-12-31	2007-01-15	48	127.0.0.1	12
427	67	2006-01-01	2006-12-31	2007-02-14	48	127.0.0.1	01
428	68	2007-01-01	2007-12-31	2008-02-15	48	127.0.0.1	01
429	69	2008-01-01	2008-12-31	2009-02-16	48	127.0.0.1	01
430	70	2009-01-01	2009-12-31	2010-02-17	48	127.0.0.1	01
431	71	2010-01-01	2010-12-31	2011-02-14	48	127.0.0.1	01
432	72	2011-01-01	2011-12-31	2012-02-14	48	127.0.0.1	01
433	73	2012-01-01	2012-12-31	2013-02-14	48	127.0.0.1	01
434	74	2013-01-01	2013-12-31	2014-02-14	48	127.0.0.1	01
435	75	2006-01-01	2006-12-31	2007-02-14	48	127.0.0.1	01
436	76	2007-01-01	2007-12-31	2008-02-15	48	127.0.0.1	01
437	77	2008-01-01	2008-12-31	2009-02-16	48	127.0.0.1	01
438	78	2009-01-01	2009-01-01	2010-02-17	48	127.0.0.1	01
439	79	2010-01-01	2010-12-31	2011-02-14	48	127.0.0.1	01
440	80	2011-01-01	2011-12-31	2012-02-14	48	127.0.0.1	01
441	81	2012-01-01	2012-12-31	2013-02-14	48	127.0.0.1	01
442	82	2013-01-01	2013-12-31	2014-02-14	48	127.0.0.1	01
443	83	2007-01-01	2007-03-31	2007-04-16	48	127.0.0.1	01
444	83	2007-04-01	2007-06-30	2007-07-16	48	127.0.0.1	02
445	83	2007-07-01	2007-09-30	2007-10-15	48	127.0.0.1	03
446	83	2007-10-01	2007-12-31	2008-01-15	48	127.0.0.1	04
447	84	2008-01-01	2008-03-31	2008-04-15	48	127.0.0.1	01
448	84	2008-04-01	2008-06-30	2008-07-15	48	127.0.0.1	02
449	84	2008-07-01	2008-09-30	2008-10-15	48	127.0.0.1	03
450	84	2008-10-01	2008-12-31	2009-01-15	48	127.0.0.1	04
451	85	2009-01-01	2009-03-31	2009-04-15	48	127.0.0.1	01
452	85	2009-04-01	2009-06-30	2009-07-15	48	127.0.0.1	02
453	85	2009-07-01	2009-09-30	2009-10-15	48	127.0.0.1	03
454	85	2009-10-01	2009-12-31	2010-01-15	48	127.0.0.1	04
455	86	2010-01-01	2010-03-31	2010-04-15	48	127.0.0.1	01
456	86	2010-04-01	2010-06-30	2010-07-15	48	127.0.0.1	02
457	86	2010-07-01	2010-09-30	2010-10-15	48	127.0.0.1	03
458	86	2010-10-01	2010-12-31	2011-01-17	48	127.0.0.1	04
459	87	2011-01-01	2011-03-31	2011-04-15	48	127.0.0.1	01
460	87	2011-04-01	2011-06-30	2011-07-15	48	127.0.0.1	02
461	87	2011-07-01	2011-09-30	2011-10-17	48	127.0.0.1	03
462	87	2011-10-01	2011-12-31	2012-01-16	48	127.0.0.1	04
463	88	2012-01-01	2012-03-31	2012-04-16	48	127.0.0.1	01
464	88	2012-04-01	2012-06-30	2012-07-16	48	127.0.0.1	02
465	88	2012-07-01	2012-09-30	2012-10-15	48	127.0.0.1	03
466	88	2012-10-01	2012-12-31	2013-01-15	48	127.0.0.1	04
467	89	2013-01-01	2013-03-31	2013-04-15	48	127.0.0.1	01
468	89	2013-04-01	2013-06-30	2013-07-15	48	127.0.0.1	02
469	89	2013-07-01	2013-09-30	2013-10-15	48	127.0.0.1	03
470	89	2013-10-01	2013-12-31	2014-01-15	48	127.0.0.1	04
471	90	2014-01-01	2014-03-31	2014-04-15	48	127.0.0.1	01
472	90	2014-04-01	2014-06-30	2014-07-15	48	127.0.0.1	02
473	90	2014-07-01	2014-09-30	2014-10-15	48	127.0.0.1	03
474	90	2014-10-01	2014-12-31	2015-01-15	48	127.0.0.1	04
475	91	2007-01-01	2007-03-31	2007-04-25	48	127.0.0.1	01
476	91	2007-04-01	2007-06-30	2007-07-25	48	127.0.0.1	02
477	91	2007-07-01	2007-09-30	2007-10-22	48	127.0.0.1	03
478	91	2007-10-01	2007-12-31	2008-01-22	48	127.0.0.1	04
479	92	2008-01-01	2008-03-31	2008-04-21	48	127.0.0.1	01
480	92	2008-04-01	2008-06-30	2008-07-21	48	127.0.0.1	02
481	92	2008-07-01	2008-09-30	2008-10-21	48	127.0.0.1	03
482	92	2008-10-01	2008-12-31	2009-01-23	48	127.0.0.1	04
483	93	2009-01-01	2009-03-31	2009-04-23	48	127.0.0.1	01
484	93	2009-04-01	2009-06-30	2009-07-21	48	127.0.0.1	02
485	93	2009-07-01	2009-09-30	2009-10-22	48	127.0.0.1	03
486	93	2009-10-01	2009-12-31	2010-01-25	48	127.0.0.1	04
487	94	2010-01-01	2010-03-31	2010-04-26	48	127.0.0.1	01
488	94	2010-04-01	2010-06-30	2010-07-22	48	127.0.0.1	02
489	94	2010-07-01	2010-09-30	2010-10-22	48	127.0.0.1	03
490	94	2010-10-01	2010-12-31	2011-01-24	48	127.0.0.1	04
491	95	2011-01-01	2011-03-31	2011-04-26	48	127.0.0.1	01
492	95	2011-04-01	2011-06-30	2011-07-26	48	127.0.0.1	02
493	95	2011-07-01	2011-09-30	2011-10-24	48	127.0.0.1	03
494	95	2011-10-01	2011-12-31	2012-01-23	48	127.0.0.1	04
495	96	2012-01-01	2012-03-31	2012-04-25	48	127.0.0.1	01
496	96	2012-04-01	2012-06-30	2012-07-25	48	127.0.0.1	02
497	96	2012-07-01	2012-09-30	2012-10-22	48	127.0.0.1	03
498	96	2012-10-01	2012-12-31	2013-01-22	48	127.0.0.1	04
499	97	2013-01-01	2013-03-31	2013-04-22	48	127.0.0.1	01
500	97	2013-04-01	2013-06-30	2013-07-22	48	127.0.0.1	02
501	97	2013-07-01	2013-09-30	2013-10-21	48	127.0.0.1	03
502	97	2013-10-01	2013-12-31	2014-01-23	48	127.0.0.1	04
503	98	2014-01-01	2014-03-31	2014-04-23	48	127.0.0.1	01
504	98	2014-04-01	2014-06-30	2014-07-21	48	127.0.0.1	02
505	98	2014-07-01	2014-09-30	2014-10-21	48	127.0.0.1	03
506	98	2014-10-01	2014-12-31	2015-01-22	48	127.0.0.1	04
507	99	2007-01-01	2007-01-31	2007-02-23	48	127.0.0.1	01
508	99	2007-02-01	2007-02-28	2007-03-21	48	127.0.0.1	02
509	99	2007-03-01	2007-03-31	2007-04-25	48	127.0.0.1	03
510	99	2007-04-01	2007-04-30	2007-05-23	48	127.0.0.1	04
511	99	2007-05-01	2007-05-31	2007-06-22	48	127.0.0.1	05
512	99	2007-06-01	2007-06-30	2007-07-25	48	127.0.0.1	06
513	99	2007-07-01	2007-07-31	2007-08-22	48	127.0.0.1	07
514	99	2007-08-01	2007-08-31	2007-09-21	48	127.0.0.1	08
515	99	2007-09-01	2007-09-30	2007-10-22	48	127.0.0.1	09
516	99	2007-10-01	2007-10-31	2007-11-22	48	127.0.0.1	10
517	99	2007-11-01	2007-11-30	2007-12-21	48	127.0.0.1	11
518	99	2007-12-01	2007-12-31	2008-01-22	48	127.0.0.1	12
519	100	2008-01-01	2008-01-31	2008-02-25	48	127.0.0.1	01
520	100	2008-02-01	2008-02-29	2008-03-25	48	127.0.0.1	02
521	100	2008-03-01	2008-03-31	2008-04-21	48	127.0.0.1	03
522	100	2008-04-01	2008-04-30	2008-05-23	48	127.0.0.1	04
523	100	2008-05-01	2008-05-31	2008-06-20	48	127.0.0.1	05
524	100	2008-06-01	2008-06-30	2008-07-21	48	127.0.0.1	06
525	100	2008-07-01	2008-07-31	2008-08-22	48	127.0.0.1	07
526	100	2008-08-01	2008-08-31	2008-09-19	48	127.0.0.1	08
527	100	2008-09-01	2008-09-30	2008-10-21	48	127.0.0.1	09
528	100	2008-10-01	2008-10-31	2008-11-21	48	127.0.0.1	10
529	100	2008-11-01	2008-11-30	2008-12-22	48	127.0.0.1	11
530	100	2008-12-01	2008-12-31	2009-01-23	48	127.0.0.1	12
531	101	2009-01-01	2009-01-31	2009-02-25	48	127.0.0.1	01
532	101	2009-02-01	2009-02-28	2009-03-23	48	127.0.0.1	02
533	101	2009-03-01	2009-03-31	2009-04-23	48	127.0.0.1	03
534	101	2009-04-01	2009-04-30	2009-05-22	48	127.0.0.1	04
535	101	2009-05-01	2009-05-31	2009-06-22	48	127.0.0.1	05
536	101	2009-06-01	2009-06-30	2009-07-21	48	127.0.0.1	06
537	101	2009-07-01	2009-07-31	2009-08-21	48	127.0.0.1	07
538	101	2009-08-01	2009-08-31	2009-09-21	48	127.0.0.1	08
539	101	2009-09-01	2009-09-30	2009-10-22	48	127.0.0.1	09
540	101	2009-10-01	2009-10-31	2009-11-20	48	127.0.0.1	10
541	101	2009-11-01	2009-11-30	2009-12-22	48	127.0.0.1	11
542	101	2009-12-01	2009-12-31	2010-01-25	48	127.0.0.1	12
543	102	2010-01-01	2010-01-31	2010-02-23	48	127.0.0.1	01
544	102	2010-02-01	2010-02-28	2010-03-22	48	127.0.0.1	02
545	102	2010-03-01	2010-03-31	2010-04-26	48	127.0.0.1	03
546	102	2010-04-01	2010-04-30	2010-05-24	48	127.0.0.1	04
547	102	2010-05-01	2010-05-31	2010-06-22	48	127.0.0.1	05
548	102	2010-06-01	2010-06-30	2010-07-22	48	127.0.0.1	06
549	102	2010-07-01	2010-07-31	2010-08-20	48	127.0.0.1	07
550	102	2010-08-01	2010-08-31	2010-09-21	48	127.0.0.1	08
551	102	2010-09-01	2010-09-30	2010-10-22	48	127.0.0.1	09
552	102	2010-10-01	2010-10-31	2010-11-22	48	127.0.0.1	10
553	102	2010-11-01	2010-11-30	2010-12-22	48	127.0.0.1	11
554	102	2010-12-01	2010-12-31	2011-01-24	48	127.0.0.1	12
555	103	2011-01-01	2011-01-31	2011-02-21	48	127.0.0.1	01
556	103	2011-02-01	2011-02-28	2011-03-23	48	127.0.0.1	02
557	103	2011-03-01	2011-03-31	2011-04-26	48	127.0.0.1	03
558	103	2011-04-01	2011-04-30	2011-04-20	48	127.0.0.1	04
559	103	2011-05-01	2011-05-31	2011-06-22	48	127.0.0.1	05
560	103	2011-06-01	2011-06-30	2011-07-25	48	127.0.0.1	06
561	103	2011-07-01	2011-07-31	2011-08-22	48	127.0.0.1	07
562	103	2011-08-01	2011-08-31	2011-09-21	48	127.0.0.1	08
563	103	2011-09-01	2011-09-30	2011-10-24	48	127.0.0.1	09
564	103	2011-10-01	2011-10-31	2011-11-21	48	127.0.0.1	10
565	103	2011-11-01	2011-11-30	2011-12-22	48	127.0.0.1	11
566	103	2011-12-01	2011-12-31	2012-01-23	48	127.0.0.1	12
567	104	2012-01-01	2012-01-31	2012-02-23	48	127.0.0.1	01
568	104	2012-02-01	2012-02-29	2012-03-22	48	127.0.0.1	02
569	104	2012-03-01	2012-03-31	2012-04-25	48	127.0.0.1	03
570	104	2012-04-01	2012-04-30	2012-05-23	48	127.0.0.1	04
571	104	2012-05-01	2012-05-31	2012-06-22	48	127.0.0.1	05
572	104	2012-06-01	2012-06-30	2012-07-25	48	127.0.0.1	06
573	104	2012-07-01	2012-07-31	2012-08-22	48	127.0.0.1	07
574	104	2012-08-01	2012-08-31	2012-09-21	48	127.0.0.1	08
575	104	2012-09-01	2012-09-30	2012-10-22	48	127.0.0.1	09
576	104	2012-10-01	2012-10-31	2012-11-22	48	127.0.0.1	10
577	104	2012-11-01	2012-11-30	2012-12-21	48	127.0.0.1	11
578	104	2012-12-01	2012-12-31	2013-01-22	48	127.0.0.1	12
579	105	2013-01-01	2013-01-31	2013-02-25	48	127.0.0.1	01
580	105	2013-02-01	2013-02-28	2013-03-25	48	127.0.0.1	02
581	105	2013-03-01	2013-03-31	2013-04-22	48	127.0.0.1	03
582	105	2013-04-01	2013-04-30	2013-05-23	48	127.0.0.1	04
583	105	2013-05-01	2013-05-31	2013-06-25	48	127.0.0.1	05
584	105	2013-06-01	2013-06-30	2013-07-22	48	127.0.0.1	06
585	105	2013-07-01	2013-07-31	2013-08-22	48	127.0.0.1	07
586	105	2013-08-01	2013-08-31	2013-09-20	48	127.0.0.1	08
587	105	2013-09-01	2013-09-30	2013-10-21	48	127.0.0.1	09
588	105	2013-10-01	2013-10-31	2013-11-22	48	127.0.0.1	10
589	105	2013-11-01	2013-11-30	2013-12-20	48	127.0.0.1	11
590	105	2013-12-01	2013-12-31	2014-01-23	48	127.0.0.1	12
591	106	2014-01-01	2014-01-31	2014-02-21	48	127.0.0.1	01
592	106	2014-02-01	2014-02-28	2014-03-26	48	127.0.0.1	02
593	106	2014-03-01	2014-03-31	2014-04-23	48	127.0.0.1	03
594	106	2014-04-01	2014-04-30	2014-05-22	48	127.0.0.1	04
595	106	2014-05-01	2014-05-31	2014-06-25	48	127.0.0.1	05
596	106	2014-06-01	2014-06-30	2014-07-21	48	127.0.0.1	06
597	106	2014-07-01	2014-07-31	2014-08-22	48	127.0.0.1	07
598	106	2014-08-01	2014-08-31	2014-09-19	48	127.0.0.1	08
599	106	2014-09-01	2014-09-30	2014-10-21	48	127.0.0.1	09
600	106	2014-10-01	2014-10-31	2014-11-21	48	127.0.0.1	10
601	106	2014-11-01	2014-11-30	2014-12-22	48	127.0.0.1	11
602	106	2014-12-01	2014-12-31	2015-01-22	48	127.0.0.1	12
603	107	2007-01-01	2007-01-31	2007-02-15	48	127.0.0.1	01
604	107	2007-02-01	2007-02-28	2007-03-15	48	127.0.0.1	02
605	107	2007-03-01	2007-03-31	2007-04-16	48	127.0.0.1	03
606	107	2007-04-01	2007-04-30	2007-05-15	48	127.0.0.1	04
607	107	2007-05-01	2007-05-31	2007-06-15	48	127.0.0.1	05
608	107	2007-06-01	2007-06-30	2007-07-16	48	127.0.0.1	06
609	107	2007-07-01	2007-07-31	2007-08-15	48	127.0.0.1	07
610	107	2007-08-01	2007-08-31	2007-09-17	48	127.0.0.1	08
611	107	2007-09-01	2007-09-30	2007-10-15	48	127.0.0.1	09
612	107	2007-10-01	2007-10-31	2007-11-15	48	127.0.0.1	10
613	107	2007-11-01	2007-11-30	2007-12-17	48	127.0.0.1	11
614	107	2007-12-01	2007-12-31	2008-01-15	48	127.0.0.1	12
615	108	2008-01-01	2008-01-31	2008-02-15	48	127.0.0.1	01
616	108	2008-02-01	2008-02-29	2008-03-17	48	127.0.0.1	02
617	108	2008-03-01	2008-03-31	2008-04-15	48	127.0.0.1	03
618	108	2008-04-01	2008-04-30	2008-05-15	48	127.0.0.1	04
619	108	2008-05-01	2008-05-31	2008-06-16	48	127.0.0.1	05
620	108	2008-06-01	2008-06-30	2008-07-15	48	127.0.0.1	06
621	108	2008-07-01	2008-07-31	2008-08-15	48	127.0.0.1	07
622	108	2008-08-01	2008-08-31	2008-09-15	48	127.0.0.1	08
623	108	2008-09-01	2008-09-30	2008-10-15	48	127.0.0.1	09
624	108	2008-10-01	2008-10-31	2008-11-17	48	127.0.0.1	10
625	108	2008-11-01	2008-11-30	2008-12-15	48	127.0.0.1	11
626	108	2008-12-01	2008-12-31	2009-01-15	48	127.0.0.1	12
627	109	2009-01-01	2009-01-31	2009-02-16	48	127.0.0.1	01
628	109	2009-02-01	2009-02-28	2009-03-16	48	127.0.0.1	02
629	109	2009-03-01	2009-03-31	2009-04-15	48	127.0.0.1	03
630	109	2009-04-01	2009-04-30	2009-05-15	48	127.0.0.1	04
631	109	2009-05-01	2009-05-31	2009-06-16	48	127.0.0.1	05
632	109	2009-06-01	2009-06-30	2009-07-15	48	127.0.0.1	06
633	109	2009-07-01	2009-07-31	2009-08-17	48	127.0.0.1	07
634	109	2009-08-01	2009-08-31	2009-09-15	48	127.0.0.1	08
635	109	2009-09-01	2009-09-30	2009-10-15	48	127.0.0.1	09
636	109	2009-10-01	2009-10-31	2009-11-16	48	127.0.0.1	10
637	109	2009-11-01	2009-11-30	2009-12-15	48	127.0.0.1	11
638	109	2009-12-01	2009-12-31	2010-01-15	48	127.0.0.1	12
639	110	2010-01-01	2010-01-31	2010-02-17	48	127.0.0.1	01
640	110	2010-02-01	2010-02-28	2010-03-15	48	127.0.0.1	02
641	110	2010-03-01	2010-03-31	2010-04-15	48	127.0.0.1	03
642	110	2010-04-01	2010-04-30	2010-05-18	48	127.0.0.1	04
643	110	2010-05-01	2010-05-31	2010-06-15	48	127.0.0.1	05
644	110	2010-06-01	2010-06-30	2010-07-15	48	127.0.0.1	06
645	110	2010-07-01	2010-07-31	2010-08-16	48	127.0.0.1	07
646	110	2010-08-01	2010-08-31	2010-09-15	48	127.0.0.1	08
647	110	2010-09-01	2010-09-30	2010-10-15	48	127.0.0.1	09
648	110	2010-10-01	2010-10-31	2010-11-15	48	127.0.0.1	10
649	110	2010-11-01	2010-11-30	2010-12-15	48	127.0.0.1	11
650	110	2010-12-01	2010-12-31	2011-01-17	48	127.0.0.1	12
651	111	2011-01-01	2011-01-31	2011-02-15	48	127.0.0.1	01
652	111	2011-02-01	2011-02-28	2011-03-15	48	127.0.0.1	02
653	111	2011-03-01	2011-03-31	2011-04-15	48	127.0.0.1	03
654	111	2011-04-01	2011-04-30	2011-05-16	48	127.0.0.1	04
655	111	2011-05-01	2011-05-31	2011-06-15	48	127.0.0.1	05
656	111	2011-06-01	2011-06-30	2011-07-15	48	127.0.0.1	06
657	111	2011-07-01	2011-07-31	2011-08-15	48	127.0.0.1	07
658	111	2011-08-01	2011-08-31	2011-09-15	48	127.0.0.1	08
659	111	2011-09-01	2011-09-30	2011-10-17	48	127.0.0.1	09
660	111	2011-10-01	2011-10-31	2011-11-15	48	127.0.0.1	10
661	111	2011-11-01	2011-11-30	2011-12-15	48	127.0.0.1	11
662	111	2011-12-01	2011-12-31	2012-01-16	48	127.0.0.1	12
663	112	2012-01-01	2012-01-31	2012-02-15	48	127.0.0.1	01
664	112	2012-02-01	2012-02-29	2012-03-15	48	127.0.0.1	02
665	112	2012-03-01	2012-03-31	2012-04-16	48	127.0.0.1	03
666	112	2012-04-01	2012-04-30	2012-05-15	48	127.0.0.1	04
667	112	2012-05-01	2012-05-31	2012-06-15	48	127.0.0.1	05
668	112	2012-06-01	2012-06-30	2012-07-16	48	127.0.0.1	06
669	112	2012-07-01	2012-07-31	2012-08-15	48	127.0.0.1	07
670	112	2012-08-01	2012-08-31	2012-09-17	48	127.0.0.1	08
671	112	2012-09-01	2012-09-30	2012-10-15	48	127.0.0.1	09
672	112	2012-10-01	2012-10-31	2012-11-15	48	127.0.0.1	10
673	112	2012-11-01	2012-11-30	2012-12-17	48	127.0.0.1	11
674	112	2012-12-01	2012-12-31	2013-01-15	48	127.0.0.1	12
675	113	2013-01-01	2013-01-31	2013-02-15	48	127.0.0.1	01
676	113	2013-02-01	2013-02-28	2013-03-18	48	127.0.0.1	02
677	113	2013-03-01	2013-03-31	2013-04-15	48	127.0.0.1	03
678	113	2013-04-01	2013-04-30	2013-05-15	48	127.0.0.1	04
679	113	2013-05-01	2013-05-31	2013-06-17	48	127.0.0.1	05
680	113	2013-06-01	2013-06-30	2013-07-15	48	127.0.0.1	06
681	113	2013-07-01	2013-07-31	2013-08-15	48	127.0.0.1	07
682	113	2013-08-01	2013-08-31	2013-09-16	48	127.0.0.1	08
683	113	2013-09-01	2013-09-30	2013-10-15	48	127.0.0.1	09
684	113	2013-10-01	2013-10-31	2013-11-15	48	127.0.0.1	10
685	113	2013-11-01	2013-11-30	2013-12-16	48	127.0.0.1	11
686	113	2013-12-01	2013-12-31	2014-01-15	48	127.0.0.1	12
687	114	2014-01-01	2014-01-31	2014-02-17	48	127.0.0.1	01
688	114	2014-02-01	2014-02-28	2014-03-17	48	127.0.0.1	02
689	114	2014-03-01	2014-03-31	2014-04-15	48	127.0.0.1	03
690	114	2014-04-01	2014-04-30	2014-05-15	48	127.0.0.1	04
691	114	2014-05-01	2014-05-31	2014-06-16	48	127.0.0.1	05
692	114	2014-06-01	2014-06-30	2014-07-15	48	127.0.0.1	06
693	114	2014-07-01	2014-07-31	2014-08-15	48	127.0.0.1	07
694	114	2014-08-01	2014-08-31	2014-09-15	48	127.0.0.1	08
695	114	2014-09-01	2014-09-30	2014-10-15	48	127.0.0.1	09
696	114	2014-10-01	2014-10-31	2014-11-17	48	127.0.0.1	10
697	114	2014-11-01	2014-11-30	2014-12-15	48	127.0.0.1	11
698	114	2014-12-01	2014-12-31	2015-01-16	48	127.0.0.1	12
\.


--
-- TOC entry 3173 (class 0 OID 26147)
-- Dependencies: 182 3292
-- Data for Name: cargos; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY cargos (id, nombre, usuarioid, ip, codigo_cargo) FROM stdin;
8	GERENTE	17	192.168.1.102	C-001
9	FISCAL	17	192.168.1.102	C-002
10	ASISTENTE LEGAL	17	192.168.1.102	C-003
11	RECAUDADOR	17	192.168.1.102	C-004
15	SECRETARIA	17	192.168.1.102	C-005
16	ASISTENTE	17	192.168.1.102	C-006
18	SUPER ADMINISTRADOR	17	192.168.1.102	C-000
\.


--
-- TOC entry 3175 (class 0 OID 26155)
-- Dependencies: 184 3292
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
-- TOC entry 3227 (class 0 OID 26373)
-- Dependencies: 236 3292
-- Data for Name: con_img_doc; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY con_img_doc (id, conusuid, descripcion, usuarioid, ip, ruta_imagen, fecha) FROM stdin;
\.


--
-- TOC entry 3922 (class 0 OID 0)
-- Dependencies: 237
-- Name: con_img_doc_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('con_img_doc_id_seq', 0, true);


--
-- TOC entry 3229 (class 0 OID 26382)
-- Dependencies: 238 3292
-- Data for Name: contrib_calc; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY contrib_calc (id, conusuid, usuarioid, ip, tipocontid, fecha_registro_fila, fecha_notificacion, proceso) FROM stdin;
1	15	48	127.0.0.1	1	2014-02-07 11:19:01.040094	\N	calculado
\.


--
-- TOC entry 3923 (class 0 OID 0)
-- Dependencies: 239
-- Name: contrib_calc_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('contrib_calc_id_seq', 1, true);


--
-- TOC entry 3185 (class 0 OID 26195)
-- Dependencies: 194 3292
-- Data for Name: contribu; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY contribu (id, razonsocia, dencomerci, actieconid, rif, numregcine, domfiscal, estadoid, ciudadid, zonapostal, telef1, telef2, telef3, fax1, fax2, email, pinbb, skype, twitter, facebook, nuacciones, valaccion, capitalsus, capitalpag, regmerofc, rmnumero, rmfolio, rmtomo, rmfechapro, rmncontrol, rmobjeto, domcomer, cextra1, cextra2, cextra3, cextra4, cextra5, usuarioid, ip) FROM stdin;
1	Agropecuaria JRL, C.A.	Cine Carvajal	\N	J308336980	249	Calle 15 entre Avenidas Fraternidad y Lisandro Alvarado	15	\N	0000	0253-5145389	\N	\N	\N	\N	Agropecuariajrlca@cantv.net	\N	\N	\N	\N	0	0.00	0.00	0.00	Registro Mercantil Segundo de la Circunscripción Judicial del Estado Lara		10	44-A	2000-11-16	61	\N	Calle 15 entre Avenidas. Fraternidad y Lisandro Alvarado	\N	\N	\N	\N	\N	1	127.0.0.1
2	A.C. Cine Club Zona Colonial de Petare	A.C. Cine Club Zona Colonial de Petare	\N	J301447018	313	Calle B. Rivas,  N° 502, 1438, Petare, Zona Colonial, Caracas, Edo. Miranda	17	\N	0000	0212-2721632	\N	\N	\N	\N	cineclub@hotmail.com	\N	\N	\N	\N	0	0.00	0.00	0.00	Notaria Séptima Del Distrito Sucre Del Estado Miranda			116	1996-09-02	25	\N	Calle B. Rivas,  N° 502, 1438, Petare, Zona Colonial, Caracas, Edo. Miranda	\N	\N	\N	\N	\N	2	127.0.0.1
3	Cine Oasis, C.A.	Cine Oasis, C.A.	\N	J311591478	305	Avenida Intercomunal Guarenas-Guatire, Centro Comercial Oasis Center, Piso 5, Local MCL-01	17	\N	0000	0212-3811694	\N	\N	\N	\N	cineoasis2005@hotmail.com	\N	\N	\N	\N	0	0.00	0.00	0.00	Registro Mercantil Séptimo de la Circunscripción Judicial  del Distrito Capital y Estado Miranda		10	423-A VII	2004-06-09	60	\N	Avenida Intercomunal Guarenas-Guatire, Centro Comercial Oasis Center, Piso 5, Local MCL-01	\N	\N	\N	\N	\N	3	127.0.0.1
4	Cine Plaza Las Américas, C.A.	Cine Plaza Las Américas, C.A.	\N	J000915644	33	3era. Transversal, Las Delicias de Sabana Grande, Edificio Las Delicias, Sótano 2	3	\N	0000	0212-7629781	\N	\N	\N	\N	msaleta@blancica.com.ve	\N	\N	\N	\N	0	0.00	0.00	0.00	Registro Mercantil Primero de la Circunscripción Judicial del Distrito Federal y Estado Miranda			189-A PRO	2000-10-24	64	\N	Centro Comercial Plaza Las Américas,  I, Nivel Sótano, El Cafetal.	\N	\N	\N	\N	\N	4	127.0.0.1
5	Exhibidor de Películas La Cascada, C.A.	Exhibidor de Películas La Cascada, C.A.	\N	J307124695	890	Km 21, de la Autopista Panamericana, C.C. La Cascada, Sector Cines, Carretera los Teques-Carrizal.	17	\N	0000	0212-3830587	\N	\N	\N	\N	pablov@cantv.net	\N	\N	\N	\N	0	0.00	0.00	0.00	Registro Mercantil Tercero de la Circunscripción Judicial del Distrito Capital y Estado Miranda			11-A	2000-06-09	22	\N	Km 21, de la Autopista Panamericana, C.C. La Cascada, Sector Cines, Carretera los Teques-Carrizal.	\N	\N	\N	\N	\N	5	127.0.0.1
6	Exhibidor de Películas La Casona, C.A.	Exhibidor de Películas La Casona, C.A.	\N	J304483198	891	Km 15 de la Carretera Panamericana, C.C. La Casona, San Antonio de Los Altos, Municipios Los Salias	17	\N	0000	0212-3726118	\N	\N	\N	\N	moviecascada@cantv.net	\N	\N	\N	\N	0	0.00	0.00	0.00	Oficina Pública de Registro Tercero de la Circunscripción Judicial del Distrito Federal y Miranda			6-A Tro	1997-05-09	68	\N	Km 15 de la Carretera Panamericana, C.C. La Casona, San Antonio de Los Altos, Municipios Los Salias	\N	\N	\N	\N	\N	6	127.0.0.1
7	Fundacine Universidad de Carabobo	Fundacine Universidad de Carabobo	\N	J075877608	288	Edif. Escorpio, Mezz. Av. Andrés Eloy Blanco, c/c 137	10	\N	0000	0241-8251384	\N	\N	\N	\N	www.fundacine@uc.edu.ve	\N	\N	\N	\N	0	0.00	0.00	0.00			1 al 5	10	1990-05-10		\N	Edif. Escorpio, Mezz. Av. Andrés Eloy Blanco, c/c 137	\N	\N	\N	\N	\N	7	127.0.0.1
8	Fundación Teatro Baralt (FUNDABARALT)	Fundación Teatro Baralt (FUNDABARALT)	\N	J304603665	325	Teatro Baralt, cruce calle 95 con Av. 5, Diagonal a la Plaza Bolívar	25	\N	0000	0261-7229745	\N	\N	\N	\N	teatrobaralt@cantv.net	\N	\N	\N	\N	0	0.00	0.00	0.00	Oficina Subalterna del Tercer Circuito, Registro del Municipio Maracaibo			28	1994-09-29	6	\N	Teatro Baralt, cruce calle 95 con Av. 5, Diagonal a la Plaza Bolívar	\N	\N	\N	\N	\N	8	127.0.0.1
9	Fundación La Previsora	Fundación La Previsora	\N	J003615935	2538	Avenida Abraham Lincoln, Torre la Previsora, Nivel Mezzanina, Plaza Venezuela	3	\N	0000	0212-7091842	\N	\N	\N	\N	fundaciónprevisora@gmail.com	\N	\N	\N	\N	0	0.00	0.00	0.00	Oficina Subalterna  del Segundo Circuito de Registro del entonces Departamento Libertador del Distrito Federal			28	1986-11-05	24	\N	Avenida Abraham Lincoln, Torre la Previsora, Nivel Mezzanina, Plaza Venezuela	\N	\N	\N	\N	\N	9	127.0.0.1
10	Asociación Nacional de Salas de Arte Cinematográfica Circuito Gran Cine	Asociación Nacional de Salas de Arte Cinematográfica Circuito Gran Cine	\N	J303881130	282	Avenida Francisco de Miranda con 2da. Av. de Campo Alegre, Edif. Laino, Piso 5, Ofc. 51-53	17	\N	0000	0212-2669607	\N	\N	\N	\N	Bernardo Rotundo brotundo@grancine.net	\N	\N	\N	\N	0	0.00	0.00	0.00	Oficina Subalterna del Cuarto Circuito de Registro Público del Municipio Libertador del Distrito Capital		907 al 907	16	1996-06-13	11	\N	Avenida Francisco de Miranda con 2da. Av. de Campo Alegre, Edif. Laino, Piso 5, Ofc. 51-53	\N	\N	\N	\N	\N	10	127.0.0.1
11	Inversiones Diversas No. 37, C.A. (Cine Continental)	Inversiones Diversas No. 37, C.A. (Cine Continental)	\N	J302174210	15	Avenida Rómulo Gallegos, Edif. Torre Saman, Piso 1, Ofic. 11, Los Dos Caminos	3	\N	0000	0212-2372550	\N	\N	\N	\N	venefilm@telcel.net.ve	\N	\N	\N	\N	0	0.00	0.00	0.00	Oficina de Registro Mercantil I, de la Circunscripción Judicial del Distrito Capital y Estado Miranda			107-A-Pro	1994-10-10	56	\N	Av. Rómulo Gallegos, Edif. Torre Saman, Piso 1, Ofic. 11, Los Dos Caminos	\N	\N	\N	\N	\N	11	127.0.0.1
12	Inversiones Jumbo Plex, C.A.	Inversiones Jumbo Plex, C.A.	\N	J305874964	34	3ra. Transversal, Las Delicias de Sabana Grande, Edif. Las Delicias, Sótano 2, Sabana Grande	3	\N	0000	0212-7629781	\N	\N	\N	\N	msaleta@blancica.com.ve	\N	\N	\N	\N	0	0.00	0.00	0.00	Oficina del Registro Mercantil Primero de la Circunscripción Judicial del Distrito Capital y Estado Miranda			271-A QTO	1998-12-21	65	\N	Avenida Cuatro de Mayo, intersección con Calle Campos, de la Ciudad de Porlamar, C.C. Jumbo Ciudad, Local N° 10 del Jumbo	\N	\N	\N	\N	\N	12	127.0.0.1
13	Inversiones Maydard, C.A.	Inversiones Maydard, C.A.	\N	J308926434	1772	3ra. Transversal Delicias de Sabana Grande, Edf. Las Delicias, Piso 5, Parroquia El Recreo	3	\N	0000	0212-7642826	\N	\N	\N	\N	ltorres@cinex.com.ve	\N	\N	\N	\N	0	0.00	0.00	0.00	Registro Mercantil Cuarto de la Circunscripción Judicial del Distrito Capital y Estado Miranda			5-A Cto.	2002-01-25	16	\N	Avenida Libertador entre calles 19 y 22, Centro Comercial Babilón L. N° LC-31	\N	\N	\N	\N	\N	13	127.0.0.1
14	Multicine Las Trinitarias, C.A.	Multicine Las Trinitarias, C.A.	\N	J302626471	27	Avenida Río Caura y Av. Paragua, Núcleo Ejecutivo, Edif. La Pirámide, Nivel Planta Alta, Ofic. 1, Urb. Prados del Este	17	\N	0000	0212-9077711	\N	\N	\N	\N	ttoth@cinesunidos.com	\N	\N	\N	\N	0	0.00	0.00	0.00	Registro Mercantil II de la Circunscripción Judicial del Distrito Federal y Estado Miranda			182-A-Sgdo.	1995-05-11	51	\N	Humboldt, Sambil Ccs, Los Naranjos, Galerías Ávila, Galerías Paraiso, Metrocenter, El Marqués, Plaza Mayor, Regina, Las ámericas, Hiperjumbo, Orinokia, La Granja, Metropolis, Sambil Valencia, San Diego, Costa Azul 	\N	\N	\N	\N	\N	14	127.0.0.1
15	Multicine Las Virtudes, C.A.	Multicine Las Virtudes, C.A.	\N	J304066120	16	Avenida Rómulo Gallegos, Edif. TorreSaman, Piso 1, Ofic. 11, Los Dos Caminos	17	\N	0000	0212-2372550	\N	\N	\N	\N	venefilm@telcel.net.ve	\N	\N	\N	\N	0	0.00	0.00	0.00	Registro Mercantil Primero de la Circunscripción Judicial del Estado Miranda			306-A-Pro	1996-11-26	13	\N	Avenida Rómulo Gallegos, Edif. TorreSaman, Piso 1, Ofic. 11, Los Dos Caminos	\N	\N	\N	\N	\N	15	127.0.0.1
16	Multicine Valera Plaza, C.A.	Multicine Valera Plaza, C.A.	\N	J308213373	8	Avenida Rómulo Gallegos, Edif. TorreSaman, Piso 1, Ofic. 11, Los Dos Caminos	17	\N	0000	0212-2372550	\N	\N	\N	\N	venefilm@telcel.net.ve	\N	\N	\N	\N	0	0.00	0.00	0.00	Registro Mercantil Primero de la Circunscripción Judicial del Distrito Capital y Estado Miranda			105-A-Pro	2001-06-11	22	\N	Avenida Rómulo Gallegos, Edif. TorreSaman, Piso 1, Ofic. 11, Los Dos Caminos	\N	\N	\N	\N	\N	16	127.0.0.1
17	Multicinema El Viaducto, C.A.	Multicinema El Viaducto, C.A.	\N	J001324178	20	Avenida Rómulo Gallegos, Edif. TorreSaman, Piso 1, Ofic. 11, Los Dos Caminos	17	\N	0000	0212-2372550	\N	\N	\N	\N	venefilm@telcel.net.ve	\N	\N	\N	\N	0	0.00	0.00	0.00	Registro Mercantil Primero de la Circunscripción Judicial del Distrito Federal y Estado Miranda			71-A-Pro	1978-06-13	54	\N	Avenida Cardenal Quintero, Centro Comercial El Viaducto	\N	\N	\N	\N	\N	17	127.0.0.1
18	Multicinema Tamanaco, C.A.	Multicinema Tamanaco, C.A	\N	J001054243	23	3ra. Av. Las Delicias, Edif. Las Delicias, Nivel Semi Sótano, Sabana Grande	3	\N	0000	0212-7629781	\N	\N	\N	\N	www.cinex.com.ve	\N	\N	\N	\N	0	0.00	0.00	0.00	Registro Mercantil Primero de la Circunscripción Judicial del Distrito Federal y Estado Miranda			2-A	1974-01-31	38	\N	Centro Comercial Ciudad Tamanaco, Nivel Planta Baja, 1era. Etapa, Urb. Chuao	\N	\N	\N	\N	\N	18	127.0.0.1
19	Multicines El Valle, C.A.	Multicines El Valle, C.A.	\N	J304741510	2471	Avenida Intercomunal del Valle, Centro Comercial el Valle, piso 8, Local F-7	3	\N	0000	0212-7317818	\N	\N	\N	\N	ssharam@cantv.net	\N	\N	\N	\N	0	0.00	0.00	0.00	Registro Mercantil Quinto de la Circunscripción Judicial del Distrito Capital y Estado Miranda			145-A-QTO	1997-08-29	75	\N	Avenida Intercomunal del Valle, Centro Comercial el Valle, piso 8, Local F-7	\N	\N	\N	\N	\N	19	127.0.0.1
20	Multicine Marina Plaza, C.A.	Multicine Marina Plaza, C.A.	\N	J308213411	7	Avenida Rómulo Gallegos, Edif. TorreSaman, Piso 1, Ofic. 11, Los Dos Caminos	17	\N	0000	0212-2372550	\N	\N	\N	\N	venefilm@telcel.net.ve	\N	\N	\N	\N	0	0.00	0.00	0.00	Registro Mercantil Primero de la Circunscripción Judicial del Distrito Federal y Estado Miranda			105-A-Pro	2001-05-14	57	\N	Avenida Rómulo Gallegos, Edif. TorreSaman, Piso 1, Ofic. 11, Los Dos Caminos	\N	\N	\N	\N	\N	20	127.0.0.1
21	Multicine Monagas Plaza, C.A.	Multicine Monagas Plaza, C.A.	\N	J305308551	5	Av. Rómulo Gallegos, Edif. TorreSaman, Piso 1, Ofic. 11, Los Dos Caminos	17	\N	0000	0212-2372550	\N	\N	\N	\N	venefilm@telcel.net.ve	\N	\N	\N	\N	0	0.00	0.00	0.00	Registro Mercantil Primero de la Circunscripción Judicial del Distrito Federal y Estado Miranda			82-Pro	1998-05-06	29	\N	Avenida Rómulo Gallegos, Edif. TorreSaman, Piso 1, Ofic. 11, Los Dos Caminos	\N	\N	\N	\N	\N	21	127.0.0.1
22	Multicine Doral Plaza Center, C.A.	Multicine Doral Plaza Center, C.A.	\N	J304857527	9	Av. Rómulo Gallegos, Edif. TorreSaman, Piso 1, Ofic. 11, Los Dos Caminos	17	\N	0000	0212-2372550	\N	\N	\N	\N	venefilm@telcel.net.ve	\N	\N	\N	\N	0	0.00	0.00	0.00	Registro Mercantil Primero de la Circunscripción Judicial del Distrito Federal y Estado Miranda			276-A-Pro	1997-10-27	43	\N	Centro Comercial Doral Center Mall, 1era. Etapa, Urb. Chuao. Maracaibo	\N	\N	\N	\N	\N	22	127.0.0.1
23	A.C. Cine Club Charles Chaplin	A.C. Cine Club Charles Chaplin	\N	J312496126	628	Carrera 28 entre Calles 16 y 17, Num.16-95, Qta. Ery-Dey, Piso 1, Apto. 1-A  	15	\N	0000	0251-2678512	\N	\N	\N	\N	cinechaplin@gmail.com	\N	\N	\N	\N	0	0.00	0.00	0.00	Registro Inmobiliario del Primer Circuito del Municipio Iribarren del Estado Lara		30 al 39	11	2004-11-02	6	\N	Carrera 28 entre Calles 16 y 17, Num.16-95, Qta. Ery-Dey, Piso 1, Apto. 1-A  	\N	\N	\N	\N	\N	23	127.0.0.1
24	Suramericana de Espectáculos, S.A	Suramericana de Espectáculos, S.A	\N	J000458324	235	3ra. Av. Las Delicias, Edif. Las Delicias, Nivel Semi Sótano, Sabana Grande	3	\N	0000	0212-7628262	\N	\N	\N	\N	cinex@com.ve	\N	\N	\N	\N	0	0.00	0.00	0.00	Registro Mercantil Quinto de la Circunscripción Judicial del Distrito Federal y Estado Miranda			17	1964-06-11	54	\N	3ra. Transversal,Las Delicias, Edif. Las Delicias, Piso 6, Sabana Grande	\N	\N	\N	\N	\N	24	127.0.0.1
25	Teatro Rossini, S.R.L.	Teatro Rossini, S.R.L.	\N	J001011579	19	Avenida Rómulo Gallegos, Edif. Torresaman, Piso 1, Ofic. 11, Los Dos Caminos	17	\N	0000	0212-2372550	\N	\N	\N	\N	venefilm@telcel.net.ve	\N	\N	\N	\N	0	0.00	0.00	0.00	Registro Mercantil Primero de la Circunscripción Judicial del Distrito Federal y Estado Miranda			38-A	1975-06-09	83	\N	Avenida Rómulo Gallegos, Edif. TorreSaman, Piso 1, Ofic. 11, Los Dos Caminos	\N	\N	\N	\N	\N	25	127.0.0.1
26	Teatros de Portuguesa, S.R.L. 	Teatros de Portuguesa, S.R.L. 	\N	J001035508	11	Avenida Rómulo Gallegos, Edif. Torresaman, Piso 1, Ofic. 11, Los Dos Caminos	17	\N	0000	0212-2372550	\N	\N	\N	\N	venefilm@telcel.net.ve	\N	\N	\N	\N	0	0.00	0.00	0.00	Registro Mercantil Primero de la Circunscripción Judicial del Distrito Capital y Estado Miranda			127-A	1976-09-13	7	\N	Av. Rómulo Gallegos, Edif. TorreSaman, Piso 1, Ofic. 11, Los Dos Caminos	\N	\N	\N	\N	\N	26	127.0.0.1
27	Vencine, Venezolana de Cines, C.A.	Vencine, Venezolana de Cines, C.A.	\N	J310438510	273	Avenida Baralt, Esq. Muñoz, Cine Baralt	3	\N	0000	0212-4838729	\N	\N	\N	\N	vencineca@cantv.net	\N	\N	\N	\N	0	0.00	0.00	0.00	Registro Mercantil Cuarto de la Circunscripción Judicial del Distrito Capital y Estado Miranda			55-A-Cto	2003-08-26	15	\N	Centro Comercial la Redoma, Av. Libertador,  Maracaibo, Centro Comercial El Centro, Paseo Las Ciencias, Estado Maracaibo	\N	\N	\N	\N	\N	27	127.0.0.1
28	Cinex Tolón Multiplex, C.A.	Cinex Tolón Multiplex, C.A.	\N	J310483990	35	3ra. Transversal, Las Delicias de Sabana Grande, Edif. Las Delicias, Sótano 2, Sabana Grande	3	\N	0000	0212-7629781	\N	\N	\N	\N	msaleta@blancica.com.ve	\N	\N	\N	\N	0	0.00	0.00	0.00	Registro Mercantil Primero de la Circunscripción Judicial del Distrito Federal y Estado Miranda			124-A-Pro	2003-09-08	79	\N	Centro Comercial El Tolón, Piso6, Urbanización Las Mercedes	\N	\N	\N	\N	\N	28	127.0.0.1
29	Administradora Darmay, C.A.	Administradora Darmay, C.A.	\N	J313701394	1305	3ra. Transversal, Las Delicias de Sabana Grande, Edif. Las Delicias, Sótano 2, Sabana Grande	3	\N	0000	0212-7629262	\N	\N	\N	\N	ltorres@cinex.com.ve	\N	\N	\N	\N	0	0.00	0.00	0.00	Registro Mercantil Quinto de la Circunscripción Judicial del Distrito Capital y Estado Miranda			1132-A-Quinto	2005-07-11	60	\N	Centro Comercial El Hatillo, Nivel 4, La Lagunita	\N	\N	\N	\N	\N	29	127.0.0.1
30	Inversora 12230, C.A.	Inversora 12230, C.A.	\N	J305634947	22	3ra. Transversal, de las Delicias de Sabana Grande, Edif. Las Delicias, Sótano,Urbanización Sabana Grande	3	\N	0000	0212-7629781	\N	\N	\N	\N	msaleta@blancica.com.ve	\N	\N	\N	\N	0	0.00	0.00	0.00	Registro Mercantil Segundo de la Circunscripción Judicial del Distrito Capital y Estado Miranda			419-A-Sdo	1998-09-21	35	\N	3ra. Transversal, de las Delicias de Sabana Grande, Edif. Las Delicias, Sótano,Urbanización Sabana Grande	\N	\N	\N	\N	\N	30	127.0.0.1
31	Fundación Trasnocho Cultural 	Fundación Trasnocho Cultural 	\N	J308490865	2347	2da. Avenida de Campo Alegre con Avenida Francisvo de Miranda, Edif. Laina, Piso 5, Oficina 51-53, Campo Alegre.	17	\N	0000	0212-9910040	\N	\N	\N	\N	coordinación@trasnochocultural.com	\N	\N	\N	\N	0	0.00	0.00	0.00	Oficina Subalterna de Registro Público del Primer Circuito del Distrito Capital			20	2003-02-12	39	\N	Centro Comercial Paseo Las Mercedes, Nivel Trasnocho, Las Mercedes.	\N	\N	\N	\N	\N	31	127.0.0.1
32	Multicine Galerías 2.020, C.A.	Multicine Galerías 2.020, C.A.	\N	J314807722	1807	Avenida Rómulo Gallegos, Torresamán, Piso 1, Ofc. 11, Urb. Los Dos Caminos	17	\N	0000	0212-2372550	\N	\N	\N	\N	venefilm@telcel.net.ve	\N	\N	\N	\N	0	0.00	0.00	0.00	Oficina del Registro Mercantil Segundo de la Circunscripción Judicial del Distrito Capital y Estado Miranda 			4-A-SDO	2006-01-18	33	\N	Avenida Rómulo Gallegos, Torresamán, Piso 1, Ofc. 11, Urb. Los Dos Caminos	\N	\N	\N	\N	\N	32	127.0.0.1
33	Cines Center, C.A.	Cines Center, C.A.	\N	J294736343	2436	Av. Las Industrias cruce con calle los Paramos, Centro Comercial la Pascua Center, Nivel Recreo, Valle de la Pascua	14	\N	0000	0235-3416205	\N	\N	\N	\N	cinescenter@cantv.net	\N	\N	\N	\N	0	0.00	0.00	0.00	Registro Mercantil II de la Circunscripción Judicial del Estado Guárico			8-A	2007-08-27	93	\N	Avenida Las Industrias cruce con calle los Paramos, Centro Comercial la Pascua Center, Nivel Recreo, Valle de la Pascua	\N	\N	\N	\N	\N	33	127.0.0.1
34	Compañía Anónima Empresa Cines Unidos, C.A.	Compañía Anónima Empresa Cines Unidos, C.A.	\N	J000126518	1065	Avenida Rio Caura, Urbanización Parque Humbolt, Edif. La Piramide, Planta Alta, Prados de Este	17	\N	0000	0212-6207521	\N	\N	\N	\N	 sullivi@cinesunidos.com	\N	\N	\N	\N	0	0.00	0.00	0.00	Registro Mercantil II de la Circunscripción Judicial del Distrito Federal y Estado Miranda			3-C	1947-06-13	601	\N	Avenida Rio Caura, Urbanización Parque Humbolt, Edif. La Piramide, Planta Alta, Prados de Este	\N	\N	\N	\N	\N	34	127.0.0.1
35	Operadora Cinecity La Victoria, C.A.	Operadora Cinecity La Victoria, C.A.	\N	J294910661	2924	Avenida Negra Matea, Centro Comercial Morichal, Nivel Feria, Local Cines (LC-62, Urb. Morichal, La Victoria	7	\N	0000	0244-3231719	\N	\N	\N	\N	cinecitylavictoria@gmail.com	\N	\N	\N	\N	0	0.00	0.00	0.00	Registro Mercantil Cuarto de la Circunscripción Judicial del Distrito Capital y Estado Miranda			89-A-CTO	2007-08-21	15	\N	Calle Chacaito, entre A. Linconln y Casanova, Edif. Dos, Piso 1, Ofic.1-A, Urb. Bello Monte	\N	\N	\N	\N	\N	35	127.0.0.1
36	Multicines San Remo, C.A.	Multicines San Remo, C.A.	\N	J295750790	3164	Avenida Jesús Subero, Vía San José de Guanipa, Centro Comercial San Remo Mall,  Local 155, Sector Vea, El Tigre	5	\N	0000	0283-2317487	\N	\N	\N	\N	multicines.eltigre@cantv.net	\N	\N	\N	\N	0	0.00	0.00	0.00	Registro Mercantil  Segundo de la Circunscripción Judicial del Estado Anzoátegui			24-A	2007-12-17	45	\N	Avenida Jesús Subero, Vía San José de Guanipa, Centro Comercial San Remo Mall,  Local 155, Sector Vea, El Tigre	\N	\N	\N	\N	\N	36	127.0.0.1
37	Casona Multiplex, C.A.	Casona Multiplex, C.A.	\N	J298525070	3458	Avenida Principal La Rosaleda, Centro Comercial La Casona II, Nivel 1, Local 11, Sector La Rosaleda	17	\N	0000	0212-3726621	\N	\N	\N	\N	cinemovieplanet@gmail.com	\N	\N	\N	\N	0	0.00	0.00	0.00	Registro Mercantil de la Circunscripción Judicial del Estado Monagas			64-A RM MAT	2009-12-10	36	\N	Avenida Principal La Rosaleda, Centro Comercial La Casona II, Nivel 1, Local 11, Sector La Rosaleda	\N	\N	\N	\N	\N	37	127.0.0.1
38	SuperCines Puente Real, C.A.	SuperCines Puente Real, C.A.	\N	J307894466	4192	Avenida Costanera con Prolongación Avenida 5 de Julio, Centro Comercial Puente Real, Nivel 1 Local Cine, Nueva Barcelona	5	\N	0000	0283-5005575	\N	\N	\N	\N	rennyvieira@gmail.com	\N	\N	\N	\N	0	0.00	0.00	0.00	Registro Mercantil  Tercero del Estado Anzoátegui			68-A RM3ROBAR	2010-12-16	7	\N	Avenida Costanera con Prolongación Avenida 5 de Julio, Centro Comercial Puente Real, Nivel 1 Local Cine, Nueva Barcelona	\N	\N	\N	\N	\N	38	127.0.0.1
\.


--
-- TOC entry 3231 (class 0 OID 26391)
-- Dependencies: 240 3292
-- Data for Name: contributi; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY contributi (id, contribuid, tipocontid, ip) FROM stdin;
\.


--
-- TOC entry 3924 (class 0 OID 0)
-- Dependencies: 241
-- Name: contributi_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('contributi_id_seq', 1, false);


--
-- TOC entry 3183 (class 0 OID 26183)
-- Dependencies: 192 3292
-- Data for Name: conusu; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY conusu (id, login, password, nombre, inactivo, conusutiid, email, pregsecrid, respuesta, ultlogin, usuarioid, ip, rif, validado, fecha_registro, correo_enviado) FROM stdin;
1	J308336980	e8e57f356c63af9228041723d2eceb9674061478	Agropecuaria JRL, C.A.	f	\N	Agropecuariajrlca@cantv.net	\N	\N	\N	0	127.0.0.1	J308336980	t	2000-11-16	f
2	J301447018	175bc0ac527a8b320597622a33e30946753e1157	A.C. Cine Club Zona Colonial de Petare	f	\N	cineclub@hotmail.com	\N	\N	\N	0	127.0.0.1	J301447018	t	1996-09-02	f
3	J311591478	9bf8c86b6e5b53a0c48ed3d37b7f766c556ca41d	Cine Oasis, C.A.	f	\N	cineoasis2005@hotmail.com	\N	\N	\N	0	127.0.0.1	J311591478	t	2004-06-09	f
4	J000915644	ac7347079798140feb6cd249617805100dd910e6	Cine Plaza Las Américas, C.A.	f	\N	msaleta@blancica.com.ve	\N	\N	\N	0	127.0.0.1	J000915644	t	2000-10-24	f
5	J307124695	0b542d078f56f866df627e3e4c90500b9592429a	Exhibidor de Películas La Cascada, C.A.	f	\N	pablov@cantv.net	\N	\N	\N	0	127.0.0.1	J307124695	t	2000-06-09	f
6	J304483198	653c685fefde8976d503e84702cd8db890b0e193	Exhibidor de Películas La Casona, C.A.	f	\N	moviecascada@cantv.net	\N	\N	\N	0	127.0.0.1	J304483198	t	1997-05-09	f
7	J075877608	b410ac9f5f140c9baad3967d68ab2eb86fa93e03	Fundacine Universidad de Carabobo	f	\N	www.fundacine@uc.edu.ve	\N	\N	\N	0	127.0.0.1	J075877608	t	1990-05-10	f
8	J304603665	fd0551b9c247661abd942dc93144a0fb07515c91	Fundación Teatro Baralt (FUNDABARALT)	f	\N	teatrobaralt@cantv.net	\N	\N	\N	0	127.0.0.1	J304603665	t	1994-09-29	f
9	J003615935	2b94009731199527d8cf65c8a188dece40193d7e	Fundación La Previsora	f	\N	fundaciónprevisora@gmail.com	\N	\N	\N	0	127.0.0.1	J003615935	t	1986-11-05	f
10	J303881130	6dd14f71e9d7dde7f976493e5156a28662045ec2	Asociación Nacional de Salas de Arte Cinematográfica Circuito Gran Cine	f	\N	Bernardo Rotundo brotundo@grancine.net	\N	\N	\N	0	127.0.0.1	J303881130	t	1996-06-13	f
11	J302174210	8b9478aa6ecfece198db1202577258ba771343ca	Inversiones Diversas No. 37, C.A. (Cine Continental)	f	\N	venefilm@telcel.net.ve	\N	\N	\N	0	127.0.0.1	J302174210	t	1994-10-10	f
12	J305874964	b2307ffa1d9267ded992a7dcde3b3df4c37e5763	Inversiones Jumbo Plex, C.A.	f	\N	msaleta@blancica.com.ve	\N	\N	\N	0	127.0.0.1	J305874964	t	1998-12-21	f
13	J308926434	135396c08b79ae3fbb31034be02e34e90ce46e6e	Inversiones Maydard, C.A.	f	\N	ltorres@cinex.com.ve	\N	\N	\N	0	127.0.0.1	J308926434	t	2002-01-25	f
14	J302626471	97af76d5fc04417069e149a37691661acfbeed8d	Multicine Las Trinitarias, C.A.	f	\N	ttoth@cinesunidos.com	\N	\N	\N	0	127.0.0.1	J302626471	t	1995-05-11	f
15	J304066120	d1f524ff149aaa87febd6b7d9f575750764976c2	Multicine Las Virtudes, C.A.	f	\N	venefilm@telcel.net.ve	\N	\N	\N	0	127.0.0.1	J304066120	t	1996-11-26	f
16	J308213373	01adc91fafd36d152ae91ebf0adb283c0046be76	Multicine Valera Plaza, C.A.	f	\N	venefilm@telcel.net.ve	\N	\N	\N	0	127.0.0.1	J308213373	t	2001-06-11	f
17	J001324178	bde76f8dea1f90c2d8cdc737856039b367ed46e2	Multicinema El Viaducto, C.A.	f	\N	venefilm@telcel.net.ve	\N	\N	\N	0	127.0.0.1	J001324178	t	1978-06-13	f
18	J001054243	cec3d2e4ff6fb1593f2b5119411e32a6b23811d6	Multicinema Tamanaco, C.A.	f	\N	www.cinex.com.ve	\N	\N	\N	0	127.0.0.1	J001054243	t	1974-01-31	f
19	J304741510	e3ae3f32ee402733ec4baca707488d847ee194ee	Multicines El Valle, C.A.	f	\N	ssharam@cantv.net	\N	\N	\N	0	127.0.0.1	J304741510	t	1997-08-29	f
20	J308213411	2871fbbb2bf7dc6fdbcfa6c0cf0c07531417997e	Multicine Marina Plaza, C.A.	f	\N	venefilm@telcel.net.ve	\N	\N	\N	0	127.0.0.1	J308213411	t	2001-05-14	f
21	J305308551	9551aae86e7dc08120b8b28dc6873b8364fe5865	Multicine Monagas Plaza, C.A.	f	\N	venefilm@telcel.net.ve	\N	\N	\N	0	127.0.0.1	J305308551	t	1998-05-06	f
22	J304857527	9794e279eae097668d69a375bd1f9188a3a85833	Multicine Doral Plaza Center, C.A.	f	\N	venefilm@telcel.net.ve	\N	\N	\N	0	127.0.0.1	J304857527	t	1997-10-27	f
23	J312496126	618258fa674524bf9089aea266053bd75611d866	A.C. Cine Club Charles Chaplin	f	\N	cinechaplin@gmail.com	\N	\N	\N	0	127.0.0.1	J312496126	t	2004-11-02	f
24	J000458324	bc96098a4da7a8e18dae0666fcc76f5edb28dea4	Suramericana de Espectáculos, S.A	f	\N	cinex@com.ve	\N	\N	\N	0	127.0.0.1	J000458324	t	1964-06-11	f
25	J001011579	0fc207a6536c89cdcd654bab93270d47ba9745be	Teatro Rossini, S.R.L.	f	\N	venefilm@telcel.net.ve	\N	\N	\N	0	127.0.0.1	J001011579	t	1975-06-09	f
26	J001035508	f80b3a11e28f7fd4fb933fd5ab5df6d21edaca55	Teatros de Portuguesa, S.R.L. 	f	\N	venefilm@telcel.net.ve	\N	\N	\N	0	127.0.0.1	J001035508	t	1976-09-13	f
27	J310438510	fe69216bd43cc1766caf12f420379ad0fcc76031	Vencine, Venezolana de Cines, C.A.	f	\N	vencineca@cantv.net	\N	\N	\N	0	127.0.0.1	J310438510	t	2003-08-26	f
28	J310483990	670c4c22e5072c67510c7b42d00ebff545781f4a	Cinex Tolón Multiplex, C.A.	f	\N	msaleta@blancica.com.ve	\N	\N	\N	0	127.0.0.1	J310483990	t	2003-09-08	f
29	J313701394	7e137d8ae6eb844b95927e1b05ef94a2e0aeb395	Administradora Darmay, C.A.	f	\N	ltorres@cinex.com.ve	\N	\N	\N	0	127.0.0.1	J313701394	t	2005-07-11	f
30	J305634947	de9ed450c458c21088f1691ba135c0e3d6331e3d	Inversora 12230, C.A.	f	\N	msaleta@blancica.com.ve	\N	\N	\N	0	127.0.0.1	J305634947	t	1998-09-21	f
31	J308490865	cca7fe555cefd13df67ac930e5ae7441611edeee	Fundación Trasnocho Cultural 	f	\N	coordinación@trasnochocultural.com	\N	\N	\N	0	127.0.0.1	J308490865	t	2003-02-12	f
32	J314807722	447552c85969ddcaec1b2e3301246b592980d939	Multicine Galerías 2.020, C.A.	f	\N	venefilm@telcel.net.ve	\N	\N	\N	0	127.0.0.1	J314807722	t	2006-01-18	f
33	J294736343	1d173c7519fd31bb163608fc6bb7c7c3cd9765f3	Cines Center, C.A.	f	\N	cinescenter@cantv.net	\N	\N	\N	0	127.0.0.1	J294736343	t	2007-08-27	f
35	J294910661	204917204e69de59cdab5952795e5a1d7016c48c	Operadora Cinecity La Victoria, C.A.	f	\N	cinecitylavictoria@gmail.com	\N	\N	\N	0	127.0.0.1	J294910661	t	2007-08-21	f
36	J295750790	c899f63d4d15255b0fcb01c5e7cc58e19a7070e2	Multicines San Remo, C.A.	f	\N	multicines.eltigre@cantv.net	\N	\N	\N	0	127.0.0.1	J295750790	t	2007-12-17	f
37	J298525070	7a6457023101d3a96a932392022e63f016f0958d	Casona Multiplex, C.A.	f	\N	cinemovieplanet@gmail.com	\N	\N	\N	0	127.0.0.1	J298525070	t	2009-12-10	f
38	J307894466	3a9d2f2aa7a189919fd24b57b63a9b40beec9ffa	SuperCines Puente Real, C.A.	f	\N	rennyvieira@gmail.com	\N	\N	\N	0	127.0.0.1	J307894466	t	2010-12-16	f
34	J000126518	f2508a299b15bde1d980369bc27182a4f25b3bd6	Compañía Anónima Empresa Cines Unidos, C.A.	f	\N	sullivi@cinesunidos.com	\N	\N	\N	0	127.0.0.1	J000126518	t	1947-06-13	f
\.


--
-- TOC entry 3233 (class 0 OID 26396)
-- Dependencies: 242 3292
-- Data for Name: conusu_interno; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY conusu_interno (id, fecha_entrada, conusuid, bln_fiscalizado, bln_nocontribuyente, observaciones, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 3925 (class 0 OID 0)
-- Dependencies: 243
-- Name: conusu_interno_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('conusu_interno_id_seq', 1, false);


--
-- TOC entry 3926 (class 0 OID 0)
-- Dependencies: 245
-- Name: conusu_tipocon_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('conusu_tipocon_id_seq', 39, true);


--
-- TOC entry 3235 (class 0 OID 26407)
-- Dependencies: 244 3292
-- Data for Name: conusu_tipocont; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY conusu_tipocont (id, conusuid, tipocontid, ip, fecha_elaboracion) FROM stdin;
1	1	1	127.0.0.1	2014-02-03
2	2	1	127.0.0.1	2014-02-03
3	3	1	127.0.0.1	2014-02-03
4	4	1	127.0.0.1	2014-02-03
5	5	1	127.0.0.1	2014-02-03
6	6	1	127.0.0.1	2014-02-03
7	7	1	127.0.0.1	2014-02-03
8	8	1	127.0.0.1	2014-02-03
9	9	1	127.0.0.1	2014-02-03
10	10	1	127.0.0.1	2014-02-03
11	11	1	127.0.0.1	2014-02-03
12	12	1	127.0.0.1	2014-02-03
13	13	1	127.0.0.1	2014-02-03
14	14	1	127.0.0.1	2014-02-03
15	15	1	127.0.0.1	2014-02-03
16	16	1	127.0.0.1	2014-02-03
17	17	1	127.0.0.1	2014-02-03
18	18	1	127.0.0.1	2014-02-03
19	19	1	127.0.0.1	2014-02-03
20	20	1	127.0.0.1	2014-02-03
21	21	1	127.0.0.1	2014-02-03
22	22	1	127.0.0.1	2014-02-03
23	23	1	127.0.0.1	2014-02-03
24	24	1	127.0.0.1	2014-02-03
25	25	1	127.0.0.1	2014-02-03
26	26	1	127.0.0.1	2014-02-03
27	27	1	127.0.0.1	2014-02-03
28	28	1	127.0.0.1	2014-02-03
29	29	1	127.0.0.1	2014-02-03
30	30	1	127.0.0.1	2014-02-03
31	31	1	127.0.0.1	2014-02-03
32	32	1	127.0.0.1	2014-02-03
33	33	1	127.0.0.1	2014-02-03
34	34	1	127.0.0.1	2014-02-03
35	34	4	127.0.0.1	2014-02-03
36	35	1	127.0.0.1	2014-02-03
37	36	1	127.0.0.1	2014-02-03
38	37	1	127.0.0.1	2014-02-03
39	38	1	127.0.0.1	2014-02-03
\.


--
-- TOC entry 3177 (class 0 OID 26160)
-- Dependencies: 186 3292
-- Data for Name: conusuco; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY conusuco (id, conusuid, contribuid) FROM stdin;
\.


--
-- TOC entry 3179 (class 0 OID 26165)
-- Dependencies: 188 3292
-- Data for Name: conusuti; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY conusuti (id, nombre, administra, liquida, visualiza, usuarioid, ip) FROM stdin;
1	ADMINISTRADOR	t	t	f	16	192.168.1.102
\.


--
-- TOC entry 3181 (class 0 OID 26173)
-- Dependencies: 190 3292
-- Data for Name: conusuto; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY conusuto (id, token, conusuid, fechacrea, fechacadu, usado) FROM stdin;
\.


--
-- TOC entry 3237 (class 0 OID 26413)
-- Dependencies: 246 3292
-- Data for Name: correlativos_actas; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY correlativos_actas (id, nombre, correlativo, anio, tipo) FROM stdin;
4	acta resolucion sumario	4	2012	reso-sumario
6	acta de conformidad fiscal	2	2013	act-cfis-2
3	acta resolucion culminatoria	2	2013	reso-culminatoria
2	acta reparo	2	2013	act-rpfis-1
1	autorizacion fiscal	2	2013	\N
5	acta resolucion extemporanio	6	2014	reso-extem
7	numero de declaracion	6	2014	n-declara
\.


--
-- TOC entry 3927 (class 0 OID 0)
-- Dependencies: 247
-- Name: correlativos_actas_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('correlativos_actas_id_seq', 7, true);


--
-- TOC entry 3239 (class 0 OID 26421)
-- Dependencies: 248 3292
-- Data for Name: correos_enviados; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY correos_enviados (id, rif, email_enviar, asunto_enviar, contenido_enviar, ip, usuarioid, fecha_envio, procesado) FROM stdin;
\.


--
-- TOC entry 3928 (class 0 OID 0)
-- Dependencies: 249
-- Name: correos_enviados_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('correos_enviados_id_seq', 0, true);


--
-- TOC entry 3241 (class 0 OID 26429)
-- Dependencies: 250 3292
-- Data for Name: ctaconta; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY ctaconta (cuenta, descripcion, usaraux, inactiva, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 3242 (class 0 OID 26434)
-- Dependencies: 251 3292
-- Data for Name: declara; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY declara (id, nudeclara, nudeposito, tdeclaraid, fechaelab, fechaini, fechafin, replegalid, baseimpo, alicuota, exonera, nuactoexon, credfiscal, contribant, plasustid, montopagar, bln_reparo, fechapago, fechaconci, asientoid, usuarioid, ip, tipocontribuid, conusuid, calpagodid, reparoid, proceso, bln_declaro0, fecha_carga_pago, banco, cuenta, ident_banco, plasus_alicuota) FROM stdin;
1	J304066120120113000000000010	\N	2	2014-02-07 10:06:37.582927	2013-02-01	2013-02-25	15	0.00	5.00	0.00	\N	0.00	\N	\N	0.00	f	\N	\N	\N	15	127.0.0.1	1	15	579	\N	\N	t	\N	\N	\N	\N	\N
2	J30406612012021300017600001	123456789	2	2014-02-07 11:17:08.641028	2013-03-01	2013-03-25	15	352000.00	5.00	0.00	\N	0.00	\N	\N	17600.00	f	2014-02-04	\N	\N	15	127.0.0.1	1	15	580	\N	\N	f	2014-02-07 11:17:56.352339	1	1	\N	\N
3	J30406612012031301250000004	123456789-1	2	2014-02-07 11:17:21.513339	2013-04-01	2013-04-22	15	25000000.00	5.00	0.00	\N	0.00	\N	\N	1250000.00	f	2014-02-04	\N	\N	15	127.0.0.1	1	15	581	\N	\N	f	2014-02-07 11:18:29.504436	1	1	\N	\N
4	J304066120120413000482500010	\N	2	2014-02-07 11:25:34.728998	2013-05-01	2013-05-23	15	965000.00	5.00	0.00	\N	0.00	\N	\N	48250.00	f	\N	\N	\N	15	127.0.0.1	1	15	582	\N	\N	f	\N	\N	\N	\N	\N
6	J30406612012091001278413908	54156421656	2	2014-02-11 13:36:39.122033	2010-10-01	2010-10-22	15	25568278.00	5.00	0.00	\N	0.00	\N	\N	1278413.90	f	2014-02-01	\N	\N	15	127.0.0.1	1	15	551	\N	\N	f	2014-02-11 13:38:35.412361	1	1	\N	\N
10	J30406612012101132582728207	\N	2	2014-02-11 17:42:03.388602	2011-11-01	2011-11-21	15	651654564.65	5.00	0.00	\N	0.00	\N	\N	32582728.20	f	\N	\N	\N	15	127.0.0.1	1	15	564	\N	\N	f	\N	\N	\N	\N	\N
17	0001-2014	\N	2	2014-02-22 18:04:52.674873	2013-10-01	2013-10-21	15	970980.80	5.00	0.00	\N	0.00	\N	\N	48549.00	f	\N	\N	\N	15	127.0.0.1	1	15	587	\N	\N	f	\N	\N	\N	8	\N
20	0002-2014	\N	3	2014-02-22 18:31:17.764288	2013-03-01	2013-03-25	15	400000.00	5.00	0.00	\N	0.00	\N	2	2400.00	f	\N	\N	\N	15	127.0.0.1	1	15	580	\N	\N	f	\N	\N	\N	8	20000.00
21	0003-2014	\N	3	2014-02-22 18:37:15.226607	2013-04-01	2013-04-22	15	75238900.00	5.00	0.00	\N	0.00	\N	3	2511945.00	f	\N	\N	\N	15	127.0.0.1	1	15	581	\N	\N	f	\N	\N	\N	8	3761945.00
22	0004-2014	\N	2	2014-02-22 18:39:24.843764	2014-02-01	2014-02-21	15	450000.00	5.00	0.00	\N	0.00	\N	\N	22500.00	f	\N	\N	\N	15	127.0.0.1	1	15	591	\N	\N	f	\N	\N	\N	6	\N
23	0005-2014	\N	2	2014-03-04 18:23:39.063646	2014-02-01	2014-02-21	14	333333.33	5.00	0.00	\N	0.00	\N	\N	16666.65	f	\N	\N	\N	14	127.0.0.1	1	14	591	\N	\N	f	\N	\N	\N	4	\N
\.


--
-- TOC entry 3187 (class 0 OID 26208)
-- Dependencies: 196 3292
-- Data for Name: declara_viejo; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY declara_viejo (id, nudeclara, nudeposito, tdeclaraid, fechaelab, fechaini, fechafin, replegalid, baseimpo, alicuota, exonera, nuactoexon, credfiscal, contribant, plasustid, nuresactfi, fechanoti, intemora, reparofis, multa, montopagar, fechapago, fechaconci, asientoid, usuarioid, ip, tipocontribuid, conusuid, calpagodid) FROM stdin;
\.


--
-- TOC entry 3189 (class 0 OID 26221)
-- Dependencies: 198 3292
-- Data for Name: departam; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY departam (id, nombre, usuarioid, ip, cod_estructura) FROM stdin;
3	GERENCIA DE FISCALIZACION	17	192.168.1.102	G-FIS-01
8	GERENCIA DE FINANZAS	17	192.168.1.102	G-FIN-03
7	GERENCIA DE RECAUDACION	17	192.168.1.102	G-REC-02
9	GERENCIA DE LEGAL	17	192.168.1.102	G-LEG-04
10	GERENCIA GENERAL DE FONPROCINE	17	192.168.1.102	G-GEN-05
11	GERENCIA DE TECNOLOGIA	17	192.168.1.102	G-TEC-06
12	DESARROLLADORES	17	192.168.1.102	DESA-00
\.


--
-- TOC entry 3245 (class 0 OID 26471)
-- Dependencies: 256 3292
-- Data for Name: descargos; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY descargos (id, fecha, compareciente, cargo_comp, reparoid, usuario, ip, estatus) FROM stdin;
\.


--
-- TOC entry 3929 (class 0 OID 0)
-- Dependencies: 257
-- Name: descargos_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('descargos_id_seq', 0, true);


--
-- TOC entry 3247 (class 0 OID 26479)
-- Dependencies: 258 3292
-- Data for Name: detalle_interes; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY detalle_interes (id, intereses, tasa, dias, mes, anio, intereses_id, ip, usuarioid, capital, "tasa%") FROM stdin;
1	5241.280000	0.049633	6	03	2013	1	127.0.0.1	48	17600.00	14.89
2	26558.400000	0.050300	30	04	2013	1	127.0.0.1	48	17600.00	15.09
3	27407.306667	0.050233	31	05	2013	1	127.0.0.1	48	17600.00	15.07
4	26188.800000	0.049600	30	06	2013	1	127.0.0.1	48	17600.00	14.88
5	46648.800000	0.085500	31	07	2013	1	127.0.0.1	48	17600.00	25.65
6	0.000000	0.000000	31	08	2013	1	127.0.0.1	48	17600.00	\N
7	0.000000	0.000000	30	09	2013	1	127.0.0.1	48	17600.00	\N
8	0.000000	0.000000	31	10	2013	1	127.0.0.1	48	17600.00	\N
9	0.000000	0.000000	30	11	2013	1	127.0.0.1	48	17600.00	\N
10	0.000000	0.000000	31	12	2013	1	127.0.0.1	48	17600.00	\N
11	0.000000	0.000000	31	01	2014	1	127.0.0.1	48	17600.00	\N
12	0.000000	0.000000	4	02	2014	1	127.0.0.1	48	17600.00	\N
13	503000.000000	0.050300	8	04	2013	2	127.0.0.1	48	1250000.00	15.09
14	1946541.666667	0.050233	31	05	2013	2	127.0.0.1	48	1250000.00	15.07
15	1860000.000000	0.049600	30	06	2013	2	127.0.0.1	48	1250000.00	14.88
16	3313125.000000	0.085500	31	07	2013	2	127.0.0.1	48	1250000.00	25.65
17	0.000000	0.000000	31	08	2013	2	127.0.0.1	48	1250000.00	\N
18	0.000000	0.000000	30	09	2013	2	127.0.0.1	48	1250000.00	\N
19	0.000000	0.000000	31	10	2013	2	127.0.0.1	48	1250000.00	\N
20	0.000000	0.000000	30	11	2013	2	127.0.0.1	48	1250000.00	\N
21	0.000000	0.000000	31	12	2013	2	127.0.0.1	48	1250000.00	\N
22	0.000000	0.000000	31	01	2014	2	127.0.0.1	48	1250000.00	\N
23	0.000000	0.000000	4	02	2014	2	127.0.0.1	48	1250000.00	\N
\.


--
-- TOC entry 3930 (class 0 OID 0)
-- Dependencies: 259
-- Name: detalle_interes_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('detalle_interes_id_seq', 23, true);


--
-- TOC entry 3249 (class 0 OID 26487)
-- Dependencies: 260 3292
-- Data for Name: detalles_contrib_calc; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY detalles_contrib_calc (id, declaraid, contrib_calcid, proceso, observacion) FROM stdin;
1	2	1	aprobado	\N
2	3	1	aprobado	\N
\.


--
-- TOC entry 3931 (class 0 OID 0)
-- Dependencies: 261
-- Name: detalles_contrib_calc_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('detalles_contrib_calc_id_seq', 2, true);


--
-- TOC entry 3251 (class 0 OID 26495)
-- Dependencies: 262 3292
-- Data for Name: dettalles_fizcalizacion; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY dettalles_fizcalizacion (id, periodo, anio, base, alicuota, total, asignacionfid, bln_borrado, calpagodid, bln_reparo_faltante, bln_identificador) FROM stdin;
\.


--
-- TOC entry 3932 (class 0 OID 0)
-- Dependencies: 263
-- Name: dettalles_fizcalizacion_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('dettalles_fizcalizacion_id_seq', 0, true);


--
-- TOC entry 3253 (class 0 OID 26506)
-- Dependencies: 264 3292
-- Data for Name: document; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY document (id, nombre, docu, inactivo, usfonproid, ip) FROM stdin;
\.


--
-- TOC entry 3933 (class 0 OID 0)
-- Dependencies: 265
-- Name: document_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('document_id_seq', 0, true);


--
-- TOC entry 3193 (class 0 OID 26235)
-- Dependencies: 202 3292
-- Data for Name: entidad; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY entidad (id, nombre, entidad, orden) FROM stdin;
\.


--
-- TOC entry 3191 (class 0 OID 26229)
-- Dependencies: 200 3292
-- Data for Name: entidadd; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY entidadd (id, entidadid, nombre, accion, orden) FROM stdin;
\.


--
-- TOC entry 3195 (class 0 OID 26241)
-- Dependencies: 204 3292
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
-- TOC entry 3255 (class 0 OID 26515)
-- Dependencies: 266 3292
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
91	2006	14.79	192.168.1.103	17	05
103	2007	16.87	192.168.1.103	17	05
115	2008	25.97	192.168.1.103	17	05
127	2009	24.04	192.168.1.103	17	05
139	2010	20.36	192.168.1.103	17	05
151	2011	20.77	192.168.1.103	17	05
92	2006	14.43	192.168.1.103	17	06
104	2007	16.10	192.168.1.103	17	06
116	2008	24.78	192.168.1.103	17	06
128	2009	22.42	192.168.1.103	17	06
140	2010	20.42	192.168.1.103	17	06
152	2011	19.91	192.168.1.103	17	06
93	2006	15.04	192.168.1.103	17	07
105	2007	17.02	192.168.1.103	17	07
117	2008	25.84	192.168.1.103	17	07
129	2009	22.30	192.168.1.103	17	07
141	2010	20.30	192.168.1.103	17	07
153	2011	20.41	192.168.1.103	17	07
94	2006	15.60	192.168.1.103	17	08
106	2007	17.61	192.168.1.103	17	08
118	2008	25.09	192.168.1.103	17	08
130	2009	22.31	192.168.1.103	17	08
142	2010	20.01	192.168.1.103	17	08
154	2011	19.14	192.168.1.103	17	08
95	2006	15.20	192.168.1.103	17	09
107	2007	17.92	192.168.1.103	17	09
119	2008	24.72	192.168.1.103	17	09
131	2009	20.87	192.168.1.103	17	09
143	2010	21.02	192.168.1.103	17	09
155	2011	19.68	192.168.1.103	17	09
171	2013	14.66	162.168.1.102	17	01
172	2013	15.47	192.168.1.102	17	02
173	2013	14.89	192.168.1.102	17	03
174	2013	15.09	192.168.1.102	17	04
175	2013	15.07	192.168.1.102	17	05
176	2013	14.88	192.168.1.102	17	06
184	2013	25.65	127.0.0.1	48	07
162	2012	17.84	192.168.1.103	17	04
163	2012	18.63	192.168.1.103	17	05
164	2012	17.73	192.168.1.103	17	06
165	2012	17.30	192.168.1.103	17	07
166	2012	18.36	192.168.1.103	17	08
167	2012	18.61	192.168.1.103	17	09
168	2012	18.13	192.168.1.103	17	10
169	2012	17.26	192.168.1.103	17	11
170	2012	17.90	192.168.1.103	17	12
185	2013	16.74	127.0.0.1	48	08
186	2013	16.97	127.0.0.1	48	09
187	2013	16.70	127.0.0.1	48	10
188	2013	16.95	127.0.0.1	48	11
\.


--
-- TOC entry 3934 (class 0 OID 0)
-- Dependencies: 267
-- Name: interes_bcv_id_seq; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('interes_bcv_id_seq', 188, true);


--
-- TOC entry 3199 (class 0 OID 26251)
-- Dependencies: 208 3292
-- Data for Name: perusu; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY perusu (id, nombre, inactivo, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 3197 (class 0 OID 26246)
-- Dependencies: 206 3292
-- Data for Name: perusud; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY perusud (id, perusuid, entidaddid, usuarioid, ip) FROM stdin;
\.


--
-- TOC entry 3201 (class 0 OID 26257)
-- Dependencies: 210 3292
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
-- TOC entry 3257 (class 0 OID 26523)
-- Dependencies: 268 3292
-- Data for Name: presidente; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY presidente (id, nombres, apellidos, cedula, nro_decreto, nro_gaceta, dtm_fecha_gaceta, bln_activo, usuarioid, ip, fecha_registro, bln_borrado) FROM stdin;
\.


--
-- TOC entry 3935 (class 0 OID 0)
-- Dependencies: 269
-- Name: presidente_id_seq2; Type: SEQUENCE SET; Schema: datos; Owner: postgres
--

SELECT pg_catalog.setval('presidente_id_seq2', 0, true);


--
-- TOC entry 3259 (class 0 OID 26534)
-- Dependencies: 270 3292
-- Data for Name: reparos; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY reparos (id, tdeclaraid, fechaelab, montopagar, asientoid, usuarioid, ip, tipocontribuid, conusuid, bln_activo, proceso, fecha_notificacion, bln_sumario, actaid, recibido_por, asignacionid, fecha_autorizacion, fecha_requerimiento, fecha_recepcion, bln_conformida) FROM stdin;
\.


--
-- TOC entry 3203 (class 0 OID 26262)
-- Dependencies: 212 3292
-- Data for Name: replegal; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY replegal (id, contribuid, nombre, apellido, ci, domfiscal, estadoid, ciudadid, zonaposta, telefhab, telefofc, fax, email, pinbb, skype, cextra1, cextra2, cextra3, cextra4, cextra5, usuarioid, ip) FROM stdin;
1	1	Julio Rafael	Leal	10980103	Calle 17 entre Carreras 10 y 11, N° 10-58	15	\N	0		0253-6632576	\N	julioleal@cantv.net	\N	\N	\N	\N	\N	\N	\N	1	127.0.0.1
2	2	Rosa Virginia	Rojas	6811410	Calle B. Rivas,  N° 502, 1438, Petare, Zona Colonial, Caracas, Edo. Miranda	17	\N	0		0212-2721632	\N	virginia_rojas@hotmail.com	\N	\N	\N	\N	\N	\N	\N	2	127.0.0.1
3	3	Eduardo 	Jakubowicz Feder	1720666	Av. Intercomunal Guarenas-Guatire, Centro Comercial Oasis Center, Piso 5, Local MCL-01	17	\N	0		0212-3811694	\N	grupo2810@cantv.net	\N	\N	\N	\N	\N	\N	\N	3	127.0.0.1
4	4	Leonora	Ferrero de Blanco	4277665	C.C. Plaza Las Américas,  I, Nivel Sótano, El Cafetal.	17	\N	0		0212-7629781	\N	jacmiguez@cantv.net	\N	\N	\N	\N	\N	\N	\N	4	127.0.0.1
5	5	Herminio 	Vieira Alves	4845179	Km 21, de la Autopista Panamericana, C.C. La Cascada, Sector Cines, Carretera los Teques-Carrizal.	17	\N	0		0212-3830587	\N	pablov@cantv.net	\N	\N	\N	\N	\N	\N	\N	5	127.0.0.1
6	6	Roger Enrique	Benítez Castellano	12414700	Km 15 de la Carretera Panamericana, C.C. La Casona, San Antonio de Los Altos, Municipios Los Salias	17	\N	0			\N		\N	\N	\N	\N	\N	\N	\N	6	127.0.0.1
7	7	Daniel 	Labarca	1361476	Edif. Escorpio, Mezz. Av. Andrés Eloy Blanco, c/c 137	10	\N	0			\N		\N	\N	\N	\N	\N	\N	\N	7	127.0.0.1
8	8	Rosa María	Salom	4153664	Teatro Baralt, cruce calle 95 con Av. 5, Diagonal a la Plaza Bolívar	25	\N	0		0261-7229745	\N	prensabaralt@cantv.net	\N	\N	\N	\N	\N	\N	\N	8	127.0.0.1
9	9	Álvaro 	Maldonado	2839971	Av. Abraham Lincoln, Torre la Previsora, Nivel Mezzanina, Plaza Venezuela	3	\N	0			\N		\N	\N	\N	\N	\N	\N	\N	9	127.0.0.1
10	10	Bernardo Rotundo	Pérez	5977638	Av.Uriare, Edif. Caurimare, Piso 4, Apto. 41, El Marques	3	\N	0	0212-2374604	0212-2669607	\N	b.rotundo@gmail.com	\N	\N	\N	\N	\N	\N	\N	10	127.0.0.1
11	11	John	Parra Plaza	6824983	Av. Rómulo Gallegos, Edif. Torre Saman, Piso 1, Ofic. 11, Los Dos Caminos	3	\N	0	0212-2353147	0212-2372550	\N	jparra@cinex.com.ve	\N	\N	\N	\N	\N	\N	\N	11	127.0.0.1
12	12	Leonora 	Ferrero de Blanco	4277665	3ra. Transversal, Las Delicias de Sabana Grande, Edif. Las Delicias, Sótano 2, Sabana Grande	3	\N	0		0212-7629781	\N		\N	\N	\N	\N	\N	\N	\N	12	127.0.0.1
13	13	 Jehudi Robert	Dardik	E-944147	3ra. Transversal Delicias de Sabana Grande, Edf. Las Delicias, Piso 5, Parroquia El Recreo	3	\N	0		0212-7642826	\N		\N	\N	\N	\N	\N	\N	\N	13	127.0.0.1
14	14	Silvio 	Ulivi Capriles	294460	Av. Río Caura y Av. Paragua, Núcleo Ejecutivo, Edif. La Pirámide, Nivel Planta Alta, Ofic. 1, Urb. Prados del Este	17	\N	0	0212-6207457	0212-9077711	\N	sullivi@cinesunidos.com	\N	\N	\N	\N	\N	\N	\N	14	127.0.0.1
15	15	John Francisco	 Parra Plaza	6824983	Av. Rómulo Gallegos, Edif. TorreSaman, Piso 1, Ofic. 11, Los Dos Caminos	17	\N	0	0212-2353147	0212-2372550	\N	jparra@cinex.com.ve	\N	\N	\N	\N	\N	\N	\N	15	127.0.0.1
16	16	John Francisco	 Parra Plaza	6824983	Av. Rómulo Gallegos, Edif. TorreSaman, Piso 1, Ofic. 11, Los Dos Caminos	17	\N	0	0212-2353147	0212-2372550	\N	jparra@cinex.com.ve	\N	\N	\N	\N	\N	\N	\N	16	127.0.0.1
17	17	Aberto J	Plaza M	1736272	Av. Rómulo Gallegos, Edif. TorreSaman, Piso 1, Ofic. 11, Los Dos Caminos	17	\N	0	0212-2353147	0212-2372550	\N	jparra@cinex.com.ve	\N	\N	\N	\N	\N	\N	\N	17	127.0.0.1
18	18	Leonora 	Blanco Ferrero	9880944	3ra. Av. Las Delicias, Edif. Las Delicias, Nivel Semi Sótano, Sabana Grande	3	\N	0		0212-7629781	\N	msaleta@blancica.com.ve	\N	\N	\N	\N	\N	\N	\N	18	127.0.0.1
19	19	Hassan	Sharam Quendi	5360163	Av. Intercomunal del Valle, Centro Comercial el Valle, piso 8, Local F-7	3	\N	0		0212-7317818	\N	ssharam@cantv.net	\N	\N	\N	\N	\N	\N	\N	19	127.0.0.1
20	20	John Francisco	 Parra Plaza	6824983	Av. Rómulo Gallegos, Edif. TorreSaman, Piso 1, Ofic. 11, Los Dos Caminos	17	\N	0	0212-2353147	0212-2372550	\N	jparra@cinex.com.ve	\N	\N	\N	\N	\N	\N	\N	20	127.0.0.1
21	21	Aberto J	Plaza M	1736272	Av. Rómulo Gallegos, Edif. TorreSaman, Piso 1, Ofic. 11, Los Dos Caminos	17	\N	0	0212-2353147	0212-2372550	\N	jparra@cinex.com.ve	\N	\N	\N	\N	\N	\N	\N	21	127.0.0.1
22	22	John Francisco	 Parra Plaza	6824983	Av. Rómulo Gallegos, Edif. TorreSaman, Piso 1, Ofic. 11, Los Dos Caminos	17	\N	0	0212-2353147	0212-2372550	\N	jparra@cinex.com.ve	\N	\N	\N	\N	\N	\N	\N	22	127.0.0.1
23	23	Juan Luis 	Rodríguez Camacho	9557591	Carrera 28 entre Calles 16 y 17, Num.16-95, Qta. Ery-Dey, Piso 1, Apto. 1-A  	15	\N	0		0251-2520995	\N	juanluisrod10@yahoo.com 	\N	\N	\N	\N	\N	\N	\N	23	127.0.0.1
24	24	Thomas	Bardinet	16890479	3ra. Av. Las Delicias, Edif. Las Delicias, Nivel Semi Sótano, Sabana Grande	3	\N	0		0212-7628262	\N	itorres@cinex.com.ve	\N	\N	\N	\N	\N	\N	\N	24	127.0.0.1
25	25	Aberto J	Plaza M	1736272	Av. Rómulo Gallegos, Edif. TorreSaman, Piso 1, Ofic. 11, Los Dos Caminos	17	\N	0	0212-2353147	0212-2372550	\N		\N	\N	\N	\N	\N	\N	\N	25	127.0.0.1
26	26	Aberto J	Plaza M	1736272	Av. Rómulo Gallegos, Edif. TorreSaman, Piso 1, Ofic. 11, Los Dos Caminos	17	\N	0	0212-2353147	0212-2372550	\N		\N	\N	\N	\N	\N	\N	\N	26	127.0.0.1
27	27	Luís 	Lama	6216568	Av. Baralt, Esq. Muñoz, Cine Baralt	3	\N	0		0212-4838729	\N	lamana@cantv.net	\N	\N	\N	\N	\N	\N	\N	27	127.0.0.1
28	28	Leonora 	Blanco Ferrero	9880944	3ra. Transversal, Las Delicias de Sabana Grande, Edif. Las Delicias, Sótano 2, Sabana Grande	3	\N	0		0212-7629781	\N	jacminguez@cantv.net	\N	\N	\N	\N	\N	\N	\N	28	127.0.0.1
29	29	Jaime 	Mayol Vicioso	82211851	3ra. Transversal, Las Delicias de Sabana Grande, Edif. Las Delicias, Sótano 2, Sabana Grande	3	\N	0		0212-7629262	\N		\N	\N	\N	\N	\N	\N	\N	29	127.0.0.1
30	30	Peter	Korda Wellisch	3472308	3ra. Transversal, de las Delicias de Sabana Grande, Edif. Las Delicias, Sótano,Urbanización Sabana Grande	3	\N	0			\N	infoblan@blancica.com.ve	\N	\N	\N	\N	\N	\N	\N	30	127.0.0.1
31	31	Helena	Quibora Fonseca	60212	2da. Avenida de Campo Alegre con Av. Francisvo de Miranda, Edif. Laina, Piso 5, Oficina 51-53, Campo Alegre.	17	\N	0		0212-9910040	\N		\N	\N	\N	\N	\N	\N	\N	31	127.0.0.1
32	32	John Francisco	 Parra Plaza	6824983	A. Rómulo Gallegos, Torresamán, Piso 1, Ofc. 11, Urb. Los Dos Caminos	17	\N	0	0212-2353147	0212-2372550	\N	jparra@cinex.com.ve	\N	\N	\N	\N	\N	\N	\N	32	127.0.0.1
33	33	Angelo Antonio	Vizzi Alaimo	10980103	Av. Libertador, Sur Edif. Magaleda III, Valle de la Pascua	14	\N	0		0235-3416205	\N	angelovizzi@hotmail.com	\N	\N	\N	\N	\N	\N	\N	33	127.0.0.1
34	34	Silvio A. 	Ulivi Capriles	294460	Avenida Rio Caura, Urbanización Parque Humbolt, Edif. La Piramide, Planta Alta, Prados de Este	17	\N	0		0212-6207521	\N		\N	\N	\N	\N	\N	\N	\N	34	127.0.0.1
35	35	José Ramón 	Sánchez 	6888005	Avenida Negra Matea, Centro Comercial Morichal, Nivel Feria, Local Cines (LC-62, Urb. Morichal, La Victoria	7	\N	0		0244-3231719	\N		\N	\N	\N	\N	\N	\N	\N	35	127.0.0.1
36	36	Renny 	Vieira Fernández	6875564	Avenida Jesús Subero, Vía San José de Guanipa, Centro Comercial San Remo Mall,  Local 155, Sector Vea, El Tigre	5	\N	0		0283-2317487	\N	rennyvieira@catv.net	\N	\N	\N	\N	\N	\N	\N	36	127.0.0.1
37	37	Edicksali 	Rodríguez C.	13748717	Avenida Principal La Rosaleda, Centro Comercial La Casona II, Nivel 1, Local 11, Sector La Rosaleda	17	\N	0		0212-3726621	\N		\N	\N	\N	\N	\N	\N	\N	37	127.0.0.1
38	38	Herminio 	Viera Alves	4845179	Avenida Costanera con Prolongación Avenida 5 de Julio, Centro Comercial Puente Real, Nivel 1 Local Cine, Nueva Barcelona	5	\N	0		0283-5005575	\N	pablo@cantv.net	\N	\N	\N	\N	\N	\N	\N	38	127.0.0.1
\.


--
-- TOC entry 3205 (class 0 OID 26270)
-- Dependencies: 214 3292
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
-- TOC entry 3207 (class 0 OID 26275)
-- Dependencies: 216 3292
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
-- TOC entry 3209 (class 0 OID 26282)
-- Dependencies: 218 3292
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
-- TOC entry 3260 (class 0 OID 26544)
-- Dependencies: 271 3292
-- Data for Name: tmpaccioni; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY tmpaccioni (id, contribuid, nombre, apellido, ci, domfiscal, nuacciones, valaccion, cextra1, cextra2, cextra3, cextra4, cextra5, ip) FROM stdin;
\.


--
-- TOC entry 3261 (class 0 OID 26552)
-- Dependencies: 272 3292
-- Data for Name: tmpcontri; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY tmpcontri (id, tipocontid, razonsocia, dencomerci, actieconid, rif, numregcine, domfiscal, estadoid, ciudadid, zonapostal, telef1, telef2, telef3, fax1, fax2, email, pinbb, skype, twitter, facebook, nuacciones, valaccion, capitalsus, capitalpag, regmerofc, rmnumero, rmfolio, rmtomo, rmfechapro, rmncontrol, rmobjeto, domcomer, conusuid, tiporeg, cextra1, cextra2, cextra3, cextra4, cextra5, ip) FROM stdin;
\.


--
-- TOC entry 3262 (class 0 OID 26562)
-- Dependencies: 273 3292
-- Data for Name: tmprelegal; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY tmprelegal (id, contribuid, nombre, apellido, ci, domfiscal, estadoid, ciudadid, zonaposta, telefhab, telefofc, fax, email, pinbb, skype, cextra1, cextra2, cextra3, cextra4, cextra5, ip) FROM stdin;
\.


--
-- TOC entry 3211 (class 0 OID 26290)
-- Dependencies: 220 3292
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
35	2014-02-11	107.00	48	127.0.0.1	2014
\.


--
-- TOC entry 3215 (class 0 OID 26305)
-- Dependencies: 224 3292
-- Data for Name: usfonpro; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY usfonpro (id, login, password, nombre, email, telefofc, extension, departamid, cargoid, inactivo, pregsecrid, respuesta, perusuid, ultlogin, usuarioid, ip, cedula, ingreso_sistema, bln_borrado) FROM stdin;
16	fbustamante	7c4a8d09ca3762af61e59520943dc26494f8941b	frederick	frederickdanielb@gmail.com	04142680489	\N	12	18	f	4	hola	\N	\N	1	192.168.1.101	15100387	t	f
17	svalladares	7c4a8d09ca3762af61e59520943dc26494f8941b	Silvia Valladares Sandoval	spvsr8@gmail.com	04160799712	\N	12	18	f	2	hola	\N	\N	1	192.168.1.101	17829273	t	f
48	jelara	652e0df6e23bd9aac8d2f5667b89f5d91cea8d15	Jefferson Arturo Lara Molina	jetox21@gmail.com	0412-0428211	\N	12	18	f	4	siiiii	\N	\N	\N	192.168.1.102	17042979	t	f
71	jetolara	bfbbf9fed197771d995f3a4dcd056ae88a93d612	JEFFERSON A. LARA M	jetolara@cnac.gob.ve	0412-0428211	\N	3	9	f	2	soy yo	\N	\N	\N	127.0.0.1	V-17042979	t	f
72	aperez	00d3f84240fe5b9839bab8975926cbab4ee9347d	ARMANDO J. PEREZ P.	aperez@cnac.gob.ve	0424-3568959	\N	3	8	f	2	soy yo	\N	\N	\N	127.0.0.1	V-15100385	t	f
73	PRUEBA	c49868c59d03dc485ba93e03aa1dc1f7922a582c	PRUEBA	PRUEBA@CNAC.GOB.VE	0212-0000000	\N	9	8	f	\N	\N	\N	\N	\N	127.0.0.1	V-55555555	f	t
74	preuba2	1e9df177a7153b04b9d9f2901179bda2ea865bcb	PRUEBA	preuba2@cnac.gob.ve	0212-0000000	\N	8	16	f	\N	\N	\N	\N	\N	127.0.0.1	V-17042978	f	t
75	jeto_621	dc1ecaf09cc22a5b4ec04f3db7f9b8460271ea3b	PRUEBA3	jeto_621@hotmail.com	0232-3232333	\N	3	16	f	\N	\N	\N	\N	\N	127.0.0.1	V-18956446	f	t
\.


--
-- TOC entry 3213 (class 0 OID 26296)
-- Dependencies: 222 3292
-- Data for Name: usfonpto; Type: TABLE DATA; Schema: datos; Owner: postgres
--

COPY usfonpto (id, token, usfonproid, fechacrea, fechacadu, usado) FROM stdin;
\.


SET search_path = historial, pg_catalog;

--
-- TOC entry 3936 (class 0 OID 0)
-- Dependencies: 285
-- Name: Bitacora_IDBitacora_seq; Type: SEQUENCE SET; Schema: historial; Owner: postgres
--

SELECT pg_catalog.setval('"Bitacora_IDBitacora_seq"', 34, true);


--
-- TOC entry 3263 (class 0 OID 26619)
-- Dependencies: 284 3292
-- Data for Name: bitacora; Type: TABLE DATA; Schema: historial; Owner: postgres
--

COPY bitacora (id, fecha, tabla, idusuario, accion, datosnew, datosold, datosdel, valdelid, ip) FROM stdin;
\.


SET search_path = pre_aprobacion, pg_catalog;

--
-- TOC entry 3243 (class 0 OID 26453)
-- Dependencies: 253 3292
-- Data for Name: intereses; Type: TABLE DATA; Schema: pre_aprobacion; Owner: postgres
--

COPY intereses (id, numresolucion, numactafiscal, felaboracion, fnotificacion, totalpagar, multaid, ip, usuarioid, fecha_inicio, fecha_fin, nudeposito, fecha_pago, fecha_carga_pago, banco, cuenta) FROM stdin;
1	4-2014	\N	2014-02-07 11:19:09.863715	\N	132044.58666667	1	127.0.0.1	48	2013-03-25	2014-02-04	\N	\N	\N	\N	\N
2	5-2014	\N	2014-02-07 11:19:09.863715	\N	7622666.6666667	2	127.0.0.1	48	2013-04-22	2014-02-04	\N	\N	\N	\N	\N
\.


--
-- TOC entry 3937 (class 0 OID 0)
-- Dependencies: 286
-- Name: intereses_id_seq; Type: SEQUENCE SET; Schema: pre_aprobacion; Owner: postgres
--

SELECT pg_catalog.setval('intereses_id_seq', 2, true);


--
-- TOC entry 3244 (class 0 OID 26460)
-- Dependencies: 254 3292
-- Data for Name: multas; Type: TABLE DATA; Schema: pre_aprobacion; Owner: postgres
--

COPY multas (id, nresolucion, fechaelaboracion, fechanotificacion, montopagar, declaraid, ip, usuarioid, tipo_multa, nudeposito, fechapago, fecha_carga_pago, numero_session, fecha_session, banco, cuenta) FROM stdin;
1	4-2014	2014-02-07 11:19:09.863715	\N	176	2	127.0.0.1	48	4	\N	\N	\N	56465456	2014-02-07 00:00:00	\N	\N
2	5-2014	2014-02-07 11:19:09.863715	\N	12500	3	127.0.0.1	48	4	\N	\N	\N	56465456	2014-02-07 00:00:00	\N	\N
\.


--
-- TOC entry 3938 (class 0 OID 0)
-- Dependencies: 287
-- Name: multas_id_seq; Type: SEQUENCE SET; Schema: pre_aprobacion; Owner: postgres
--

SELECT pg_catalog.setval('multas_id_seq', 2, true);


SET search_path = public, pg_catalog;

--
-- TOC entry 3267 (class 0 OID 26632)
-- Dependencies: 288 3292
-- Data for Name: contrib_calc; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY contrib_calc (id, nombre) FROM stdin;
\.


SET search_path = seg, pg_catalog;

--
-- TOC entry 3268 (class 0 OID 26635)
-- Dependencies: 289 3292
-- Data for Name: tbl_ci_sessions; Type: TABLE DATA; Schema: seg; Owner: postgres
--

COPY tbl_ci_sessions (session_id, ip_address, user_agent, last_activity, user_data, prevent_update) FROM stdin;
8b9569e12b32d77153d1ff11df5dbec6	127.0.0.1	Mozilla/5.0 (X11; Linux i686) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/31.0.1650.63 Chrome/31.0.1650.63 Sa	1393978963	a:8:{s:14:"prevent_update";i:0;s:9:"user_data";s:0:"";s:6:"logged";b:1;s:2:"id";s:2:"48";s:7:"usuario";s:6:"jelara";s:6:"nombre";s:28:"Jefferson Arturo Lara Molina";s:15:"ingreso_sistema";s:1:"t";s:12:"info_modulos";a:34:{i:0;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:19:"SUPER_ADMINISTRADOR";s:9:"id_modulo";s:1:"5";s:10:"str_modulo";s:32:"Administraci&oacute;n de Sistema";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:1:"#";s:8:"id_padre";s:1:"0";}i:1;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:19:"SUPER_ADMINISTRADOR";s:9:"id_modulo";s:1:"6";s:10:"str_modulo";s:8:"Usuarios";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:1:"5";}i:2;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:19:"SUPER_ADMINISTRADOR";s:9:"id_modulo";s:3:"104";s:10:"str_modulo";s:19:"Perfiles de usuario";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:1:"5";}i:3;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:19:"SUPER_ADMINISTRADOR";s:9:"id_modulo";s:3:"177";s:10:"str_modulo";s:15:"Presidente CNAC";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:1:"5";}i:4;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:19:"SUPER_ADMINISTRADOR";s:9:"id_modulo";s:2:"89";s:10:"str_modulo";s:11:"Recaudacion";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:1:"#";s:8:"id_padre";s:1:"0";}i:5;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:19:"SUPER_ADMINISTRADOR";s:9:"id_modulo";s:2:"90";s:10:"str_modulo";s:35:"Activaci&oacute;n del contribuyente";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:2:"89";}i:6;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:19:"SUPER_ADMINISTRADOR";s:9:"id_modulo";s:2:"93";s:10:"str_modulo";s:10:"Calendario";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:2:"89";}i:7;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:19:"SUPER_ADMINISTRADOR";s:9:"id_modulo";s:3:"101";s:10:"str_modulo";s:8:"Finanzas";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:1:"#";s:8:"id_padre";s:1:"0";}i:8;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:19:"SUPER_ADMINISTRADOR";s:9:"id_modulo";s:3:"102";s:10:"str_modulo";s:13:"Fiscalizacion";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:1:"#";s:8:"id_padre";s:1:"0";}i:9;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:19:"SUPER_ADMINISTRADOR";s:9:"id_modulo";s:3:"103";s:10:"str_modulo";s:5:"Legal";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:1:"#";s:8:"id_padre";s:1:"0";}i:10;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:19:"SUPER_ADMINISTRADOR";s:9:"id_modulo";s:3:"149";s:10:"str_modulo";s:19:"Cont. Extemporaneos";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:2:"89";}i:11;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:19:"SUPER_ADMINISTRADOR";s:9:"id_modulo";s:3:"159";s:10:"str_modulo";s:24:"Contribuyentes en Espera";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:2:"89";}i:12;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:19:"SUPER_ADMINISTRADOR";s:9:"id_modulo";s:3:"162";s:10:"str_modulo";s:17:"gestion de multas";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:2:"89";}i:13;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:19:"SUPER_ADMINISTRADOR";s:9:"id_modulo";s:2:"98";s:10:"str_modulo";s:12:"Cont. Omisos";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"102";}i:14;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:19:"SUPER_ADMINISTRADOR";s:9:"id_modulo";s:3:"140";s:10:"str_modulo";s:15:"C&aacute;lculos";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"101";}i:15;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:19:"SUPER_ADMINISTRADOR";s:9:"id_modulo";s:3:"133";s:10:"str_modulo";s:17:"Visitas asignadas";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"102";}i:16;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:19:"SUPER_ADMINISTRADOR";s:9:"id_modulo";s:3:"144";s:10:"str_modulo";s:27:"C&aacute;lculos por Aprobar";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"101";}i:17;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:19:"SUPER_ADMINISTRADOR";s:9:"id_modulo";s:3:"141";s:10:"str_modulo";s:29:"Reparos por Activaci&oacute;n";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"102";}i:18;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:19:"SUPER_ADMINISTRADOR";s:9:"id_modulo";s:3:"143";s:10:"str_modulo";s:18:"Reparos Culminados";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"103";}i:19;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:19:"SUPER_ADMINISTRADOR";s:9:"id_modulo";s:3:"168";s:10:"str_modulo";s:18:"Inter&eacute;s BCV";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"101";}i:20;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:19:"SUPER_ADMINISTRADOR";s:9:"id_modulo";s:3:"178";s:10:"str_modulo";s:20:"Unidades Tributarias";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"101";}i:21;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:19:"SUPER_ADMINISTRADOR";s:9:"id_modulo";s:3:"179";s:10:"str_modulo";s:6:"Bancos";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"101";}i:22;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:19:"SUPER_ADMINISTRADOR";s:9:"id_modulo";s:3:"182";s:10:"str_modulo";s:17:"Cuentas Bancarias";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"101";}i:23;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:19:"SUPER_ADMINISTRADOR";s:9:"id_modulo";s:3:"171";s:10:"str_modulo";s:9:"Descargos";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"103";}i:24;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:19:"SUPER_ADMINISTRADOR";s:9:"id_modulo";s:3:"174";s:10:"str_modulo";s:24:"Gesti&oacute;n de Multas";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"103";}i:25;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:19:"SUPER_ADMINISTRADOR";s:9:"id_modulo";s:3:"128";s:10:"str_modulo";s:20:"Gestión de Usuarios";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:1:"#";s:8:"id_padre";s:1:"0";}i:26;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:19:"SUPER_ADMINISTRADOR";s:9:"id_modulo";s:3:"129";s:10:"str_modulo";s:16:"Actualizar Datos";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"128";}i:27;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:19:"SUPER_ADMINISTRADOR";s:9:"id_modulo";s:3:"130";s:10:"str_modulo";s:19:"Cambiar Contraseña";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"128";}i:28;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:19:"SUPER_ADMINISTRADOR";s:9:"id_modulo";s:3:"131";s:10:"str_modulo";s:21:"Cambiar Preg. Secreta";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"128";}i:29;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:19:"SUPER_ADMINISTRADOR";s:9:"id_modulo";s:3:"185";s:10:"str_modulo";s:8:"Reportes";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:1:"#";s:8:"id_padre";s:1:"0";}i:30;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:19:"SUPER_ADMINISTRADOR";s:9:"id_modulo";s:3:"186";s:10:"str_modulo";s:4:"RISE";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"185";}i:31;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:19:"SUPER_ADMINISTRADOR";s:9:"id_modulo";s:3:"187";s:10:"str_modulo";s:18:"Recaudaci&oacute;n";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"185";}i:32;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:19:"SUPER_ADMINISTRADOR";s:9:"id_modulo";s:3:"189";s:10:"str_modulo";s:19:"Concilios Bancarios";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"185";}i:33;a:7:{s:11:"str_usuario";s:28:"Jefferson Arturo Lara Molina";s:7:"str_rol";s:19:"SUPER_ADMINISTRADOR";s:9:"id_modulo";s:3:"192";s:10:"str_modulo";s:19:"Actas Fiscalizacion";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_administrador/principal_c";s:8:"id_padre";s:3:"185";}}}	0
a306955efe7b344f9d149123704f1090	127.0.0.1	Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:26.0) Gecko/20100101 Firefox/26.0	1393978874	a:7:{s:14:"prevent_update";i:0;s:9:"user_data";s:0:"";s:6:"logged";b:1;s:2:"id";s:2:"14";s:7:"usuario";s:10:"J302626471";s:6:"nombre";s:31:"Multicine Las Trinitarias, C.A.";s:12:"info_modulos";a:16:{i:0;a:7:{s:11:"str_usuario";s:31:"Multicine Las Trinitarias, C.A.";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:2:"89";s:10:"str_modulo";s:13:"Contribuyente";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:1:"#";s:8:"id_padre";s:1:"0";}i:1;a:7:{s:11:"str_usuario";s:31:"Multicine Las Trinitarias, C.A.";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:2:"92";s:10:"str_modulo";s:14:"Administracion";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:1:"#";s:8:"id_padre";s:1:"0";}i:2;a:7:{s:11:"str_usuario";s:31:"Multicine Las Trinitarias, C.A.";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:2:"90";s:10:"str_modulo";s:14:"Secci&oacute;n";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_contribuyente/principal_c";s:8:"id_padre";s:2:"89";}i:3;a:7:{s:11:"str_usuario";s:31:"Multicine Las Trinitarias, C.A.";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:2:"99";s:10:"str_modulo";s:13:"Declaraciones";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:1:"#";s:8:"id_padre";s:1:"0";}i:4;a:7:{s:11:"str_usuario";s:31:"Multicine Las Trinitarias, C.A.";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"107";s:10:"str_modulo";s:29:"Carga de  Representante Legal";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:55:"./mod_contribuyente/contribuyente_c/representante_legal";s:8:"id_padre";s:2:"90";}i:5;a:7:{s:11:"str_usuario";s:31:"Multicine Las Trinitarias, C.A.";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:2:"93";s:10:"str_modulo";s:9:"Seguridad";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_contribuyente/principal_c";s:8:"id_padre";s:2:"92";}i:6;a:7:{s:11:"str_usuario";s:31:"Multicine Las Trinitarias, C.A.";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"100";s:10:"str_modulo";s:17:"Nueva declaracion";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_contribuyente/principal_c";s:8:"id_padre";s:2:"99";}i:7;a:7:{s:11:"str_usuario";s:31:"Multicine Las Trinitarias, C.A.";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"101";s:10:"str_modulo";s:16:"Reparos Fiscales";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_contribuyente/principal_c";s:8:"id_padre";s:2:"99";}i:8;a:7:{s:11:"str_usuario";s:31:"Multicine Las Trinitarias, C.A.";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"102";s:10:"str_modulo";s:16:"Gestion de pagos";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_contribuyente/principal_c";s:8:"id_padre";s:2:"99";}i:9;a:7:{s:11:"str_usuario";s:31:"Multicine Las Trinitarias, C.A.";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"113";s:10:"str_modulo";s:16:"Multas impuestas";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_contribuyente/principal_c";s:8:"id_padre";s:2:"99";}i:10;a:7:{s:11:"str_usuario";s:31:"Multicine Las Trinitarias, C.A.";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"117";s:10:"str_modulo";s:22:"Declarcion Sustitutiva";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_contribuyente/principal_c";s:8:"id_padre";s:2:"99";}i:11;a:7:{s:11:"str_usuario";s:31:"Multicine Las Trinitarias, C.A.";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"109";s:10:"str_modulo";s:11:"Cargar pago";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:35:"./mod_contribuyente/gestion_pagos_c";s:8:"id_padre";s:3:"102";}i:12;a:7:{s:11:"str_usuario";s:31:"Multicine Las Trinitarias, C.A.";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"120";s:10:"str_modulo";s:9:"Consultas";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:1:"#";s:8:"id_padre";s:1:"0";}i:13;a:7:{s:11:"str_usuario";s:31:"Multicine Las Trinitarias, C.A.";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"119";s:10:"str_modulo";s:36:"Crear Declaraci&oacute;n Sustitutiva";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:45:"./mod_contribuyente/declaracion_sustitutiva_c";s:8:"id_padre";s:3:"117";}i:14;a:7:{s:11:"str_usuario";s:31:"Multicine Las Trinitarias, C.A.";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"121";s:10:"str_modulo";s:19:"Calendario de pagos";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_contribuyente/principal_c";s:8:"id_padre";s:3:"120";}i:15;a:7:{s:11:"str_usuario";s:31:"Multicine Las Trinitarias, C.A.";s:7:"str_rol";s:13:"Administrador";s:9:"id_modulo";s:3:"123";s:10:"str_modulo";s:16:"Estado de Cuenta";s:11:"int_permiso";s:1:"1";s:10:"str_enlace";s:31:"./mod_contribuyente/principal_c";s:8:"id_padre";s:3:"120";}}}	0
\.


--
-- TOC entry 3269 (class 0 OID 26645)
-- Dependencies: 290 3292
-- Data for Name: tbl_modulo; Type: TABLE DATA; Schema: seg; Owner: postgres
--

COPY tbl_modulo (id_modulo, id_padre, str_nombre, str_descripcion, str_enlace, bln_borrado, orden_menu, orden_pestanas) FROM stdin;
116	104	prueba2	prueba2	./prueba	t	\N	\N
115	104	prueba	prueba	./prueba	t	\N	\N
13	6	Usuarios	Modulo hijo que muestra el listar de Usuarios con todas las operacciones correspondientes 	./mod_administrador/usuarios_c	f	\N	\N
120	104	prueba4	prueba4	./prueba4	t	\N	\N
119	104	prueba3	prueba3	./prueba3	t	\N	\N
118	104	prueba2	prueba2	./prueba2	t	\N	\N
117	104	prueba1	prueba1	./prueba1	t	\N	\N
6	5	Usuarios	Administrar los usuarios del sistema	./mod_administrador/principal_c	f	\N	\N
97	93	Calendario de Pagos	Gestion de calendarios de pagos de la declaracion del contribuyente	./mod_gestioncontribuyente/gestion_calendarios_de_pago_c	f	\N	\N
104	5	Perfiles de usuario	modulo para la craion de los roles dentro del sistema	./mod_administrador/principal_c	f	\N	\N
88	\N	PRUEBA	SJKHBAKJHSDK	./LKJLKJLK	t	\N	\N
105	104	Crear perfil	modulo para la cracion de los perfiles en el sistemas	./mod_administrador/roles_c	f	\N	\N
7	5	Manejo de Modulos	Administrar los grupos para los usuarios del sistema	./mod_administrador/principal_c	t	\N	\N
111	110	gfhgfdgfd	fdgfdg	./oooo	t	\N	\N
123	122	silvia	silvia	./silvvia	t	\N	\N
8	5	Módulos principales	Administrar los módulos del sistema	./mod_administrador/principal_c	t	\N	\N
122	5	SILVIA	silvia	./mod_administrador/principal_c	t	\N	\N
86	7	Operaciones	modulo hijo para la creacion y manejos de modulos aguelos, padres y grupos	./mod_administrador/manejo_modulo_c	f	\N	\N
108	104	rfgfgf	fdgfdg	./	t	\N	\N
109	5	JHGJHGJHG	jhkjhkhkjh	./	t	\N	\N
121	6	prueba	prueba	./prueba	t	\N	\N
110	89	FDGFDG	fdgfdg	./mod_administrador/principal_c	t	\N	\N
135	129	prueba	recarga	./prueba	t	\N	\N
114	104	prueba3	prueba3	./pueba3	t	\N	\N
113	104	prueba2	prueba2	./pueba2	t	\N	\N
112	104	prueba	prueba	./prueba	t	\N	\N
136	130	Cambiar Contraseña	sub-modulo para la carga del formulario que permite el cambio de contraseña del usuario	./mod_administrador/gestion_usuario_c/frm_cambio_contrasenia	f	\N	\N
138	131	Cambiar Preg. Secreta	Formulario para el cambio de pregunta secreta del registro del usuario	./mod_administrador/gestion_usuario_c/frm_cambio_pregsecr	f	\N	\N
129	128	Actualizar Datos	Modulo que permite modificar los datos de los usuarios	./mod_administrador/principal_c	f	\N	\N
130	128	Cambiar Contraseña	Modulo para el cambio de contraseñas de los usuarios	./mod_administrador/principal_c	f	\N	\N
131	128	Cambiar Preg. Secreta	modulo para el cambio de pregunta secreta del usuario	./mod_administrador/principal_c	f	\N	\N
132	129	Actualizar Datos	Formulario para la actualización de datos del usuario	./mod_administrador/gestion_usuario_c	f	\N	\N
133	102	Visitas asignadas	modulo donde pueden ver los fiscales las distintas empresas que le fueron lasignadas para visitar	./mod_administrador/principal_c	f	\N	\N
134	133	asignaciones	manejo de empresas a ser fiscalizadas	./mod_gestioncontribuyente/fiscalizacion_c	f	\N	\N
145	139	modulos abuelos	creacion, eliminacion y edicion de los modulos principales del menu denominados abuelos	./nose	f	\N	\N
146	139	modulos padres	creacion, eliminacion y edicion de los modulos dependientes  de los abuelos en el menu principal	./nose	f	\N	\N
147	139	modulos hijos	creacion, eliminacion y edicion de las pestañas en la tab	./nose	f	\N	\N
107	98	Omisos	modulo para gestion de contribuyentes omisos	./mod_gestioncontribuyente/lista_contribuyentes_general_c/consulta_general/2	f	\N	\N
154	133	Periodos cancelados	modulo que se encarga de lacrag de los periodos que aparecen en le sistema omisos pero que al momento de la auditoría fueron cancelados por el contribuyente 	./fiscalizacion_c/periodos_cancelados	t	\N	\N
157	144	Extemporáneos	Listado calculo por aprobar de los extemporáneos	./mod_gestioncontribuyente/lista_por_aprobar_c	f	\N	\N
137	0	0	0	0	t	\N	\N
142	102	prueba	PRUEBA	./mod_administrador/principal_c	t	\N	\N
156	155	Registros del CNAC	listado que contienen todas las empresas que se encuentran registrada hasta la actualidad en registro nacional de cinematografia	./mod_gestioncontribuyente/listado_cnac_c	t	\N	\N
161	128	ppppppp hhhhhhhhhh  hhhhhhhhhhhhhhj	,m	./mod_administrador/principal_c	t	\N	\N
150	149	Omisos	Consulta Avanzada de Omisos para el Modulo Recaudacion	./mod_gestioncontribuyente/lista_contribuyentes_general_c/consulta_general/0	t	\N	\N
149	89	Cont. Extemporaneos	Consulta Avanzada de Contribuyentes del Modulo Recaudacion	./mod_administrador/principal_c	f	\N	\N
98	102	Cont. Omisos	Consulta Avanzada de Fiscalizacion	./mod_administrador/principal_c	f	\N	\N
153	149	Extemporáneos	Listado de contribuyentes extemporáneos para el departamento de recaudacion	./mod_gestioncontribuyente/lista_contribuyentes_general_c/consulta_general/1	f	\N	\N
139	5	Gestion de modulos	modulo la edicion eliminacion y creacion de nuvos modulos en el sistema en sus diferentes jerarquias	./mod_administrador/principal_c	t	\N	\N
89	\N	Recaudacion	gerencia de recaudacion tributaria	#	f	2	\N
102	\N	Fiscalizacion	gerencia de fiscalizacion tributaria	#	f	3	\N
101	\N	Finanzas	gerencia de finazas 	#	f	4	\N
103	\N	Legal	gerencia de legal	#	f	5	\N
5	\N	Administraci&oacute;n de Sistema	Opciones de administración del sistema	#	f	1	\N
100	\N	Recaudaci&oacute;n	gerencia de recaudacion tributaria	#	t	\N	\N
90	89	Activaci&oacute;n del contribuyente	verifica planilla	./mod_administrador/principal_c	f	\N	\N
140	101	C&aacute;lculos	Modulo para los calculos realizados por finanzas	./mod_administrador/principal_c	f	\N	\N
91	90	Contribuyentes por Activar	busqueda de planilla	./mod_gestioncontribuyente/lista_contribuyentes_inactivos_c	f	\N	\N
162	89	gestion de multas	modulo encargado de mostrar al usuario el estatus que se encuentra el calculo solicitado y si ya fue aprobado imprimi la notificacion	./mod_administrador/principal_c	f	\N	\N
151	141	Reparos por Activaci&oacute;n	listado de los reparos inpuestos a las empresas	./mod_gestioncontribuyente/reparos_c	f	\N	\N
141	102	Reparos por Activaci&oacute;n	listado de los reparos cargados por usuario	./mod_administrador/principal_c	f	\N	\N
158	155	Empresas externas	manejo de verificacion de deberes formales a partir de listados de empresas de indole externo esto quiere decir que la empresa no se encuentra en el registro del cnac pero que es un posible contribuyente potencial	./mod_gestioncontribuyente/empext	t	\N	\N
165	164	Asignacion por deberes formales	se listan todas las empresas que en los deberes formales se les determino que eran contribuyentes fonprocine	./mod_gestioncontribueyente/asignacion_deberes_formales_fiscalizacion_c	f	\N	\N
167	141	Reparos activados	listado de los reparos que fueron activados despues de la fiscalizacion	./rrrrrrr	t	\N	\N
169	168	Interes banco central	interes banco central	./mod_finanzas/interes_bcv_c	f	\N	\N
171	103	Descargos	descargos	./mod_administrador/principal_c	f	\N	\N
164	102	Empresas Recaudacion	aqui se vizualiza las empresas que arrojaron en la verificacion de los deberes formales que si son contribueyntes de fonprocine	./mod_administrador/principal_c	t	\N	\N
163	162	Listado de Multas Aprobadas	se visulaiza el listar de los contribuyentes con multas extemporabeas segun el estatus que requiera el usuario	./mod_gestioncontribuyente/gestion_multas_recaudacion_c	f	\N	\N
155	89	Gestion deberes formales	permite visualizar todas las empresas que se encuentran registradas en la data principal del cnac y por medio de ella el equipo de recaudacion verifica los deberes formales de cada una de ellas	./mod_administrador/principal_c	t	\N	\N
177	5	Presidente CNAC	modulo para la activbacion de presidentes del cnac	./mod_administrador/principal_c	f	\N	\N
179	101	Bancos	modullo para la carga y eliminacion de cuentas bancarias	./mod_administrador/principal_c	f	\N	\N
180	178	Carga de U.T	modulo para la carga de el monto de las unidades tributarias	./mod_finanzas/und_tributarias_c	f	\N	\N
181	179	Carga Bancos	modulo para la carga de los bancos con convenios en la isntitucion	./mod_finanzas/bancos_c	f	\N	\N
182	101	Cuentas Bancarias	modulo para la carga de las cuetas bancarias segun los bancos con convenios	./mod_administrador/principal_c	f	\N	\N
183	182	Carga Cuentas Banco	modulo para la carga de las cuentas bancarias	./mod_finanzas/cuentas_banc_c	f	\N	\N
184	177	Carga Presidente	modulo para la carga del presidente activo del cnac	./mod_administrador/presidentescnac_c	f	\N	\N
168	101	Inter&eacute;s BCV	interes bcv	./mod_administrador/principal_c	f	\N	\N
128	\N	Gestión de Usuarios	Secciones para la gestion de informacion de usuarios	#	f	7	\N
178	101	Unidades Tributarias	modulo para la carga de unidades tributarias	./mod_administrador/principal_c	f	\N	\N
185	\N	Reportes	modulo para la gestion de los reportes interno en fonprocine	#	f	6	\N
186	185	RISE	modulo para la gestion de repotes de las rise 	./mod_administrador/principal_c	f	\N	\N
188	186	Reporte de RISE	modulo para la busqueda de las rises segun criterios especificos	./mod_reportes/reportes_recaudacion_c/index/busqueda_rise_v	f	\N	\N
189	185	Concilios Bancarios	reportes que nos indica los pagos realizados y lo que faltan por realizar de cualquiera de los procediemientos	./mod_administrador/principal_c	f	\N	\N
190	189	Conciliaciones Bancarias	conciliaciones bancarias	./mod_reportes/reportes_concilios_bancarios_c	f	\N	\N
93	89	Calendario	Gestion de alendarios de pago para declaracion del contribuyente	./mod_administrador/principal_c	f	\N	\N
174	103	Gesti&oacute;n de Multas	modulo para tramitar las multas por culminatoria de fiscalizacion y pos sumario	./mod_administrador/principal_c	f	\N	\N
144	101	C&aacute;lculos por Aprobar	Modulo para el listar de las declaraciones que ya fueron calculadas	./mod_administrador/principal_c	f	\N	\N
143	103	Reparos Culminados	prueba legal	./mod_administrador/principal_c	f	\N	\N
159	89	Contribuyentes en Espera	Envio Correo Electrónico	./mod_administrador/principal_c	f	\N	\N
160	159	Contribuyentes en Espera de Documentos	Correos Electrónicos	./mod_gestioncontribuyente/envio_correos_c	f	\N	\N
152	140	Extempor&aacute;neos	Listar de extemporáneos, asignados a la gerencia de Finanzas	./mod_gestioncontribuyente/lista_extemp_calc_c	f	\N	\N
166	140	Culminatoria de Fiscalizaci&oacute;n	Listado de contribuyentes por Reparo, donde se aplicaran los cálculos de intereses y multas	./mod_gestioncontribuyente/lista_reparo_calc_c	f	\N	\N
173	140	Resoluci&oacute;n de Sumario	Resolucion de sumario	./mod_gestioncontribuyente/lista_reparo_calc_c/index_sumario	f	\N	\N
170	143	Listado de Reparos Culminados	aqui se visualizan todos los reparos que fueron activados por el gerente de fiscalización. la finalidad de estos es que legal le haga seguimientos a las fechas de pagos de los reparos.	./mod_legal/legal_c	f	\N	\N
172	171	Listado de Empresas en descargo	listado de enpresas en situacion de descargos	./mod_legal/legal_c/listado_descargos	f	\N	\N
176	174	Resoluci&oacute;n de Sumario	listado de multas aprobadas pasadas a finanzas por resolucion de sumario	./mod_legal/gestion_multas_legal_c/multas_sumario_aprobadas	f	\N	\N
175	174	Culminatoria de Fiscalizaci&oacute;n	listado de multas a probadas que fueron pasada por culminatoria de fiscalizacion	./mod_legal/gestion_multas_legal_c/multas_culminatoria_aprobadas	f	\N	\N
187	185	Recaudaci&oacute;n	modulo para la gestion del reporte principal de recaudacion	./mod_administrador/principal_c	f	\N	\N
191	187	Reporte de Recaudaci&oacute;n Anual	Reporte de Recaudacion Anual	./mod_reportes/reportes_recaudacion_c/reporte_principal_recaudacion	f	\N	\N
192	185	Actas Fiscalizacion	Actas Fiscalizacion	./mod_administrador/principal_c	f	\N	\N
193	192	Reporte de Actas en Fiscalizacion	modulo para generar los reportes por cada tipo de acta que se haya generado en la gerencia de fizcalizacion en cada año	./mod_reportes/reporte_actas_fiscalizacion_c	f	\N	\N
\.


--
-- TOC entry 3939 (class 0 OID 0)
-- Dependencies: 291
-- Name: tbl_modulo_id_modulo_seq; Type: SEQUENCE SET; Schema: seg; Owner: postgres
--

SELECT pg_catalog.setval('tbl_modulo_id_modulo_seq', 193, true);


--
-- TOC entry 3271 (class 0 OID 26654)
-- Dependencies: 292 3292
-- Data for Name: tbl_permiso; Type: TABLE DATA; Schema: seg; Owner: postgres
--

COPY tbl_permiso (id_permiso, id_modulo, id_rol, int_permiso, bln_borrado) FROM stdin;
1	5	1	1	f
2	6	1	1	f
3	104	1	1	f
4	139	1	1	f
5	89	1	1	f
6	90	1	1	f
7	93	1	1	f
8	149	1	1	f
9	159	1	1	f
10	162	1	1	f
11	101	1	1	f
12	140	1	1	f
13	144	1	1	f
14	168	1	1	f
15	102	1	1	f
16	98	1	1	f
17	133	1	1	f
18	141	1	1	f
19	103	1	1	f
20	143	1	1	f
21	171	1	1	f
22	174	1	1	f
23	128	1	1	f
24	129	1	1	f
25	130	1	1	f
26	131	1	1	f
73	177	1	1	f
74	178	1	1	f
75	179	1	1	f
78	182	1	1	f
118	102	19	1	f
119	141	19	1	f
120	133	19	1	f
121	98	19	1	f
122	103	19	1	f
123	143	19	1	f
124	171	19	1	f
125	174	19	1	f
126	89	19	1	f
127	149	19	1	f
128	90	19	1	f
129	162	19	1	f
130	159	19	1	f
131	93	19	1	f
132	101	19	1	f
133	140	19	1	f
134	144	19	1	f
135	168	19	1	f
136	178	19	1	f
137	179	19	1	f
138	182	19	1	f
139	5	19	1	f
140	6	19	1	f
141	104	19	1	f
142	139	19	1	f
143	128	19	1	f
144	129	19	1	f
145	130	19	1	f
146	131	19	1	f
147	185	19	1	f
148	185	1	1	f
149	186	1	1	f
150	187	1	1	f
151	189	1	1	f
152	192	1	1	f
153	102	21	1	f
154	133	21	1	f
155	128	21	1	f
156	129	21	1	f
157	130	21	1	f
158	131	21	1	f
159	185	21	1	f
160	102	20	1	f
161	133	20	1	f
162	98	20	1	f
163	141	20	1	f
164	128	20	1	f
165	129	20	1	f
166	130	20	1	f
167	131	20	1	f
168	185	20	1	f
169	192	20	1	f
\.


--
-- TOC entry 3940 (class 0 OID 0)
-- Dependencies: 293
-- Name: tbl_permiso_id_permiso_seq; Type: SEQUENCE SET; Schema: seg; Owner: postgres
--

SELECT pg_catalog.setval('tbl_permiso_id_permiso_seq', 169, true);


--
-- TOC entry 3273 (class 0 OID 26660)
-- Dependencies: 294 3292
-- Data for Name: tbl_permiso_trampa; Type: TABLE DATA; Schema: seg; Owner: postgres
--

COPY tbl_permiso_trampa (id_permiso, id_modulo, id_rol, int_permiso, bln_borrado) FROM stdin;
\.


--
-- TOC entry 3941 (class 0 OID 0)
-- Dependencies: 295
-- Name: tbl_permiso_trampa_id_permiso_seq; Type: SEQUENCE SET; Schema: seg; Owner: postgres
--

SELECT pg_catalog.setval('tbl_permiso_trampa_id_permiso_seq', 47, true);


--
-- TOC entry 3275 (class 0 OID 26666)
-- Dependencies: 296 3292
-- Data for Name: tbl_permiso_usuario; Type: TABLE DATA; Schema: seg; Owner: postgres
--

COPY tbl_permiso_usuario (id_permiso_usuario, id_usuario, id_modulo, bol_borrado, int_permiso_usu) FROM stdin;
17	48	5	f	1
18	48	6	f	1
19	48	7	f	1
20	48	8	f	1
21	48	104	f	1
22	48	109	f	1
23	48	122	f	1
25	16	5	f	1
24	48	139	f	0
\.


--
-- TOC entry 3276 (class 0 OID 26670)
-- Dependencies: 297 3292
-- Data for Name: tbl_rol; Type: TABLE DATA; Schema: seg; Owner: postgres
--

COPY tbl_rol (id_rol, str_rol, str_descripcion, bln_borrado) FROM stdin;
1	SUPER_ADMINISTRADOR	Administrador del sistema	f
18	Administrador_SIRICINE	administrador	t
19	Administrador	administrador	f
20	Gerente_Fiscalizacion	perfil que contienen los modulos permitidos dentro del sistema para el gerente de fizcalizacion	f
21	Fisclaes_de_Gerencia_de_Fiscalizacion	perfil para los usuarios de la gerencia de fiscalizacion que cumplan actividades de fiscalizar a los contribuyentes	f
22	prueba	sadfasd	t
\.


--
-- TOC entry 3942 (class 0 OID 0)
-- Dependencies: 298
-- Name: tbl_rol_id_rol_seq; Type: SEQUENCE SET; Schema: seg; Owner: postgres
--

SELECT pg_catalog.setval('tbl_rol_id_rol_seq', 22, true);


--
-- TOC entry 3278 (class 0 OID 26679)
-- Dependencies: 299 3292
-- Data for Name: tbl_rol_usuario; Type: TABLE DATA; Schema: seg; Owner: postgres
--

COPY tbl_rol_usuario (id_rol_usuario, id_rol, id_usuario, bln_borrado) FROM stdin;
1	1	16	f
19	1	17	f
55	1	48	f
34	1	18	f
57	1	51	f
56	1	49	f
63	1	59	f
64	19	60	f
61	19	57	f
66	19	62	f
67	19	64	f
68	19	65	f
69	19	67	f
70	20	68	f
65	20	61	f
71	19	69	f
72	19	70	f
73	21	71	f
74	20	72	f
75	19	73	f
76	19	74	f
77	19	75	f
\.


--
-- TOC entry 3943 (class 0 OID 0)
-- Dependencies: 300
-- Name: tbl_rol_usuario_id_rol_usuario_seq; Type: SEQUENCE SET; Schema: seg; Owner: postgres
--

SELECT pg_catalog.setval('tbl_rol_usuario_id_rol_usuario_seq', 77, true);


--
-- TOC entry 3280 (class 0 OID 26685)
-- Dependencies: 301 3292
-- Data for Name: tbl_session_ci; Type: TABLE DATA; Schema: seg; Owner: postgres
--

COPY tbl_session_ci (session_id, ip_address, user_agent, last_activity, user_data) FROM stdin;
f093f9803caa36c8160f5b08bb661a09	127.0.0.1	Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:19.0) Gecko/20100101 Firefox/19.0	1365795522	
\.


--
-- TOC entry 3944 (class 0 OID 0)
-- Dependencies: 302
-- Name: tbl_usuario_rol_id_usuario_rol_seq; Type: SEQUENCE SET; Schema: seg; Owner: postgres
--

SELECT pg_catalog.setval('tbl_usuario_rol_id_usuario_rol_seq', 25, true);


SET search_path = "segContribu", pg_catalog;

--
-- TOC entry 3282 (class 0 OID 26708)
-- Dependencies: 305 3292
-- Data for Name: tbl_modulo_contribu; Type: TABLE DATA; Schema: segContribu; Owner: postgres
--

COPY tbl_modulo_contribu (id_modulo, id_padre, str_nombre, str_descripcion, str_enlace, bln_borrado, orden_menu, orden_pestanas) FROM stdin;
89	\N	Contribuyente	Modulo Princioal del Contribuyente	#	f	\N	\N
112	101	reparos	listado de reparos	./mod_contribuyente/contribuyente_c/declaraciones_realizadas_enreparo	f	\N	\N
92	\N	Administracion	modulo para la administracion y gestion de la sesion del contribuyente	#	f	\N	\N
113	99	Multas impuestas	listado de multas impuestas por procedimientos de reparos o pro periodos extemporaneos	./mod_contribuyente/principal_c	f	\N	\N
97	93	cambio de clave	cambio de clave tabs	./mod_contribuyente/gestion_contrasena_c	f	\N	\N
93	92	Seguridad	cambio de clave	./mod_contribuyente/principal_c	f	\N	\N
98	93	cambio pregunta secreta	cambio depregunta secreta	./mod_contribuyente/gestion_pregunta_secreta_c	f	\N	\N
99	\N	Declaraciones	modulo que gestiona todo lo relacionado con las declaraciones del contribuyente	#	f	\N	\N
100	99	Nueva declaracion	modulo para realizar la declaracion el contribuyente	./mod_contribuyente/principal_c	f	\N	\N
108	100	declarar	vista para la declaracion del contrribuyente	./mod_contribuyente/contribuyente_c/declaracion	f	\N	\N
102	99	Gestion de pagos	modulo para la carga de los accionistas	./mod_contribuyente/principal_c	f	\N	\N
109	102	Cargar pago	modulo para la carga del tipo de contribuyente que define al la empresa que se esta registrando	./mod_contribuyente/gestion_pagos_c	f	\N	\N
106	90	Rep. legal	gestion de representante legal	./mod_contribuyente/principal_c	t	\N	\N
101	99	Reparos Fiscales	modulo para realizar las consulta del historico de sus declaraciones 	./mod_contribuyente/principal_c	f	\N	\N
114	113	Extemporaneas	multas extemporaneas	./mod_contribuyente/contribuyente_c/listado_multas_extemporaneas	f	\N	\N
115	113	Reparo Fiscal	multas por omisos	./mod_contribuyente/contribuyente_c/listado_multas_culminatoria	f	\N	\N
116	113	Sumario	multas por sumario	./mod_contribuyente/contribuyente_c/listado_multas_sumario	f	\N	\N
90	89	Secci&oacute;n	Padre	./mod_contribuyente/principal_c	f	\N	\N
107	90	Carga de  Representante Legal	craga de representante legal	./mod_contribuyente/contribuyente_c/representante_legal	f	\N	1
91	90	Carga de Datos	carga de datos del contribuyente	./mod_contribuyente/contribuyente_c/planilla_inicial	f	\N	3
103	90	Carga de Documentos	documentos complementarios del registro	./mod_contribuyente/filecontroller/documentos	f	\N	2
119	117	Crear Declaraci&oacute;n Sustitutiva	declracion sustitutiva	./mod_contribuyente/declaracion_sustitutiva_c	f	\N	\N
117	99	Declarcion Sustitutiva	declaracion sustitutiva	./mod_contribuyente/principal_c	f	\N	\N
120	\N	Consultas	Modulo padre de consultas	#	f	\N	\N
121	120	Calendario de pagos	calendario de pagos	./mod_contribuyente/principal_c	f	\N	\N
122	121	Calendario	calendario	./mod_reportesContribuyente/nose_c	f	\N	\N
127	123	Consulta del estado de cuenta	consulta	./mod_reportesContribuyente/estado_cuenta_c	f	\N	\N
123	120	Estado de Cuenta	estado de cuenta	./mod_contribuyente/principal_c	f	\N	\N
\.


--
-- TOC entry 3945 (class 0 OID 0)
-- Dependencies: 306
-- Name: tbl_modulo_id_modulo_seq; Type: SEQUENCE SET; Schema: segContribu; Owner: postgres
--

SELECT pg_catalog.setval('tbl_modulo_id_modulo_seq', 127, true);


--
-- TOC entry 3284 (class 0 OID 26717)
-- Dependencies: 307 3292
-- Data for Name: tbl_permiso_contribu; Type: TABLE DATA; Schema: segContribu; Owner: postgres
--

COPY tbl_permiso_contribu (id_permiso, id_modulo, id_rol, int_permiso, bln_borrado) FROM stdin;
2	89	4	1	f
3	90	4	1	f
4	92	1	1	f
5	93	1	1	f
6	99	1	1	f
7	100	1	1	f
8	101	1	1	f
9	106	1	1	f
10	107	1	1	f
11	109	1	1	f
12	113	1	1	f
13	89	1	1	f
14	90	1	1	f
15	102	1	1	f
16	109	1	1	f
17	117	1	1	f
18	119	1	1	f
19	120	1	1	f
20	121	1	1	f
21	123	1	1	f
\.


--
-- TOC entry 3946 (class 0 OID 0)
-- Dependencies: 308
-- Name: tbl_permiso_id_permiso_seq; Type: SEQUENCE SET; Schema: segContribu; Owner: postgres
--

SELECT pg_catalog.setval('tbl_permiso_id_permiso_seq', 22, true);


--
-- TOC entry 3286 (class 0 OID 26723)
-- Dependencies: 309 3292
-- Data for Name: tbl_rol_contribu; Type: TABLE DATA; Schema: segContribu; Owner: postgres
--

COPY tbl_rol_contribu (id_rol, str_rol, str_descripcion, bln_borrado) FROM stdin;
1	Administrador	Administrador del sistema	f
2	Coordinador	Coordinador de la sala situacional	f
3	Analista	Analista de seguimiento	f
4	Datos Iniciales	Carga Inicial de Datos del contribuyente	f
\.


--
-- TOC entry 3947 (class 0 OID 0)
-- Dependencies: 310
-- Name: tbl_rol_id_rol_seq; Type: SEQUENCE SET; Schema: segContribu; Owner: postgres
--

SELECT pg_catalog.setval('tbl_rol_id_rol_seq', 4, true);


--
-- TOC entry 3288 (class 0 OID 26732)
-- Dependencies: 311 3292
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
\.


--
-- TOC entry 3948 (class 0 OID 0)
-- Dependencies: 312
-- Name: tbl_rol_usuario_id_rol_usuario_seq; Type: SEQUENCE SET; Schema: segContribu; Owner: postgres
--

SELECT pg_catalog.setval('tbl_rol_usuario_id_rol_usuario_seq', 38, true);


--
-- TOC entry 3290 (class 0 OID 26738)
-- Dependencies: 313 3292
-- Data for Name: tbl_usuario_rol_contribu; Type: TABLE DATA; Schema: segContribu; Owner: postgres
--

COPY tbl_usuario_rol_contribu (id_usuario_rol, id_usuario, id_rol, bol_borrado) FROM stdin;
\.


--
-- TOC entry 3949 (class 0 OID 0)
-- Dependencies: 314
-- Name: tbl_usuario_rol_id_usuario_rol_seq; Type: SEQUENCE SET; Schema: segContribu; Owner: postgres
--

SELECT pg_catalog.setval('tbl_usuario_rol_id_usuario_rol_seq', 16, true);


SET search_path = datos, pg_catalog;

--
-- TOC entry 2733 (class 2606 OID 26811)
-- Dependencies: 226 226 226 3293
-- Name: CT_Accionis_IDContribu_Ci; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY accionis
    ADD CONSTRAINT "CT_Accionis_IDContribu_Ci" UNIQUE (contribuid, ci);


--
-- TOC entry 2536 (class 2606 OID 26813)
-- Dependencies: 167 167 3293
-- Name: CT_ActiExon_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY actiecon
    ADD CONSTRAINT "CT_ActiExon_Nombre" UNIQUE (nombre);


--
-- TOC entry 2541 (class 2606 OID 26815)
-- Dependencies: 169 169 169 3293
-- Name: CT_AlicImp_IDTipoCont_Ano; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY alicimp
    ADD CONSTRAINT "CT_AlicImp_IDTipoCont_Ano" UNIQUE (tipocontid, ano);


--
-- TOC entry 2548 (class 2606 OID 26817)
-- Dependencies: 171 171 171 3293
-- Name: CT_AsiendoD_IDAsiento_Referencia; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY asientod
    ADD CONSTRAINT "CT_AsiendoD_IDAsiento_Referencia" UNIQUE (asientoid, referencia);


--
-- TOC entry 2755 (class 2606 OID 26819)
-- Dependencies: 230 230 3293
-- Name: CT_AsientoM_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY asientom
    ADD CONSTRAINT "CT_AsientoM_Nombre" UNIQUE (nombre);


--
-- TOC entry 2744 (class 2606 OID 26821)
-- Dependencies: 229 229 229 229 3293
-- Name: CT_Asiento_NuAsiento_Mes_Ano; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY asiento
    ADD CONSTRAINT "CT_Asiento_NuAsiento_Mes_Ano" UNIQUE (nuasiento, mes, ano);


--
-- TOC entry 2567 (class 2606 OID 26823)
-- Dependencies: 180 180 180 3293
-- Name: CT_CalPagos_Ano_IDTiPeGrav; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY calpago
    ADD CONSTRAINT "CT_CalPagos_Ano_IDTiPeGrav" UNIQUE (ano, tipegravid);


--
-- TOC entry 2569 (class 2606 OID 26825)
-- Dependencies: 180 180 180 3293
-- Name: CT_CalPagos_Nombre_Ano; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY calpago
    ADD CONSTRAINT "CT_CalPagos_Nombre_Ano" UNIQUE (nombre, ano);


--
-- TOC entry 2576 (class 2606 OID 26827)
-- Dependencies: 182 182 3293
-- Name: CT_Cargos_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY cargos
    ADD CONSTRAINT "CT_Cargos_Nombre" UNIQUE (nombre);


--
-- TOC entry 2581 (class 2606 OID 26829)
-- Dependencies: 184 184 184 3293
-- Name: CT_Ciudades_IDEstado_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ciudades
    ADD CONSTRAINT "CT_Ciudades_IDEstado_Nombre" UNIQUE (estadoid, nombre);


--
-- TOC entry 2587 (class 2606 OID 26831)
-- Dependencies: 186 186 186 3293
-- Name: CT_ConUsuCo_IDConUsu_IDContribu; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY conusuco
    ADD CONSTRAINT "CT_ConUsuCo_IDConUsu_IDContribu" UNIQUE (conusuid, contribuid);


--
-- TOC entry 2596 (class 2606 OID 26833)
-- Dependencies: 190 190 3293
-- Name: CT_ConUsuTo_Token; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY conusuto
    ADD CONSTRAINT "CT_ConUsuTo_Token" UNIQUE (token);


--
-- TOC entry 2771 (class 2606 OID 26835)
-- Dependencies: 240 240 240 3293
-- Name: CT_ContribuTi_ContribuID_TipoContID; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY contributi
    ADD CONSTRAINT "CT_ContribuTi_ContribuID_TipoContID" UNIQUE (contribuid, tipocontid);


--
-- TOC entry 2609 (class 2606 OID 26837)
-- Dependencies: 194 194 3293
-- Name: CT_Contribu_RazonSocia; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY contribu
    ADD CONSTRAINT "CT_Contribu_RazonSocia" UNIQUE (razonsocia);


--
-- TOC entry 2611 (class 2606 OID 26839)
-- Dependencies: 194 194 3293
-- Name: CT_Contribu_Rif; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY contribu
    ADD CONSTRAINT "CT_Contribu_Rif" UNIQUE (rif);


--
-- TOC entry 2790 (class 2606 OID 26841)
-- Dependencies: 251 251 3293
-- Name: CT_Decla_NuDeclara; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT "CT_Decla_NuDeclara" UNIQUE (nudeclara);


--
-- TOC entry 2792 (class 2606 OID 26843)
-- Dependencies: 251 251 3293
-- Name: CT_Decla_NuDeposito; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT "CT_Decla_NuDeposito" UNIQUE (nudeposito);


--
-- TOC entry 2620 (class 2606 OID 26845)
-- Dependencies: 196 196 3293
-- Name: CT_Declara_NuDeclara; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY declara_viejo
    ADD CONSTRAINT "CT_Declara_NuDeclara" UNIQUE (nudeclara);


--
-- TOC entry 2622 (class 2606 OID 26847)
-- Dependencies: 196 196 3293
-- Name: CT_Declara_NuDeposito; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY declara_viejo
    ADD CONSTRAINT "CT_Declara_NuDeposito" UNIQUE (nudeposito);


--
-- TOC entry 2636 (class 2606 OID 26849)
-- Dependencies: 198 198 3293
-- Name: CT_Departam_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY departam
    ADD CONSTRAINT "CT_Departam_Nombre" UNIQUE (nombre);


--
-- TOC entry 2818 (class 2606 OID 26851)
-- Dependencies: 264 264 3293
-- Name: CT_Document_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY document
    ADD CONSTRAINT "CT_Document_Nombre" UNIQUE (nombre);


--
-- TOC entry 2641 (class 2606 OID 26853)
-- Dependencies: 200 200 200 3293
-- Name: CT_EntidadD_IDEntidad_Accion; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY entidadd
    ADD CONSTRAINT "CT_EntidadD_IDEntidad_Accion" UNIQUE (entidadid, accion);


--
-- TOC entry 2643 (class 2606 OID 26855)
-- Dependencies: 200 200 200 3293
-- Name: CT_EntidadD_IDEntidad_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY entidadd
    ADD CONSTRAINT "CT_EntidadD_IDEntidad_Nombre" UNIQUE (entidadid, nombre);


--
-- TOC entry 2645 (class 2606 OID 26857)
-- Dependencies: 200 200 200 3293
-- Name: CT_EntidadD_IDEntidad_Orden; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY entidadd
    ADD CONSTRAINT "CT_EntidadD_IDEntidad_Orden" UNIQUE (entidadid, orden);


--
-- TOC entry 2653 (class 2606 OID 26859)
-- Dependencies: 202 202 3293
-- Name: CT_Entidad_Entidad; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY entidad
    ADD CONSTRAINT "CT_Entidad_Entidad" UNIQUE (entidad);


--
-- TOC entry 2655 (class 2606 OID 26861)
-- Dependencies: 202 202 3293
-- Name: CT_Entidad_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY entidad
    ADD CONSTRAINT "CT_Entidad_Nombre" UNIQUE (nombre);


--
-- TOC entry 2657 (class 2606 OID 26863)
-- Dependencies: 202 202 3293
-- Name: CT_Entidad_Orden; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY entidad
    ADD CONSTRAINT "CT_Entidad_Orden" UNIQUE (orden);


--
-- TOC entry 2661 (class 2606 OID 26865)
-- Dependencies: 204 204 3293
-- Name: CT_Estados_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY estados
    ADD CONSTRAINT "CT_Estados_Nombre" UNIQUE (nombre);


--
-- TOC entry 2666 (class 2606 OID 26867)
-- Dependencies: 206 206 206 3293
-- Name: CT_PerUsuD_IDPerUsu_IDEntidadD; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY perusud
    ADD CONSTRAINT "CT_PerUsuD_IDPerUsu_IDEntidadD" UNIQUE (perusuid, entidaddid);


--
-- TOC entry 2673 (class 2606 OID 26869)
-- Dependencies: 208 208 3293
-- Name: CT_PerUsu_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY perusu
    ADD CONSTRAINT "CT_PerUsu_Nombre" UNIQUE (nombre);


--
-- TOC entry 2678 (class 2606 OID 26871)
-- Dependencies: 210 210 3293
-- Name: CT_PregSecr_Pregunta; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY pregsecr
    ADD CONSTRAINT "CT_PregSecr_Pregunta" UNIQUE (nombre);


--
-- TOC entry 2683 (class 2606 OID 26873)
-- Dependencies: 212 212 212 3293
-- Name: CT_RepLegal_IDContribu_Ci; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY replegal
    ADD CONSTRAINT "CT_RepLegal_IDContribu_Ci" UNIQUE (contribuid, ci);


--
-- TOC entry 2694 (class 2606 OID 26875)
-- Dependencies: 214 214 3293
-- Name: CT_TDeclara_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tdeclara
    ADD CONSTRAINT "CT_TDeclara_Nombre" UNIQUE (nombre);


--
-- TOC entry 2699 (class 2606 OID 26877)
-- Dependencies: 216 216 3293
-- Name: CT_TiPeGrav_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tipegrav
    ADD CONSTRAINT "CT_TiPeGrav_Nombre" UNIQUE (nombre);


--
-- TOC entry 2704 (class 2606 OID 26879)
-- Dependencies: 218 218 3293
-- Name: CT_TipoCont_Nombre; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tipocont
    ADD CONSTRAINT "CT_TipoCont_Nombre" UNIQUE (nombre);


--
-- TOC entry 2841 (class 2606 OID 26881)
-- Dependencies: 272 272 3293
-- Name: CT_TmpContri_NumRegCine; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tmpcontri
    ADD CONSTRAINT "CT_TmpContri_NumRegCine" UNIQUE (numregcine);


--
-- TOC entry 2843 (class 2606 OID 26883)
-- Dependencies: 272 272 3293
-- Name: CT_TmpContri_RazonSocia; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tmpcontri
    ADD CONSTRAINT "CT_TmpContri_RazonSocia" UNIQUE (razonsocia);


--
-- TOC entry 2845 (class 2606 OID 26885)
-- Dependencies: 272 272 3293
-- Name: CT_TmpContri_Rif; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tmpcontri
    ADD CONSTRAINT "CT_TmpContri_Rif" UNIQUE (rif);


--
-- TOC entry 2855 (class 2606 OID 26887)
-- Dependencies: 273 273 273 3293
-- Name: CT_TmpReLegal_IDContribu_Ci; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tmprelegal
    ADD CONSTRAINT "CT_TmpReLegal_IDContribu_Ci" UNIQUE (contribuid, ci);


--
-- TOC entry 2722 (class 2606 OID 26889)
-- Dependencies: 224 224 3293
-- Name: CT_USFonPro_Email; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY usfonpro
    ADD CONSTRAINT "CT_USFonPro_Email" UNIQUE (email);


--
-- TOC entry 2710 (class 2606 OID 26891)
-- Dependencies: 220 220 3293
-- Name: CT_UndTrib_Fecha; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY undtrib
    ADD CONSTRAINT "CT_UndTrib_Fecha" UNIQUE (fecha);


--
-- TOC entry 2717 (class 2606 OID 26893)
-- Dependencies: 222 222 3293
-- Name: CT_UsFonpTo_Token; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY usfonpto
    ADD CONSTRAINT "CT_UsFonpTo_Token" UNIQUE (token);


--
-- TOC entry 2724 (class 2606 OID 26895)
-- Dependencies: 224 224 3293
-- Name: CT_UsFonpro_Login; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY usfonpro
    ADD CONSTRAINT "CT_UsFonpro_Login" UNIQUE (login);


--
-- TOC entry 2833 (class 2606 OID 26897)
-- Dependencies: 271 271 271 3293
-- Name: CT_tmpAccioni_ContribuID_Ci; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tmpaccioni
    ADD CONSTRAINT "CT_tmpAccioni_ContribuID_Ci" UNIQUE (contribuid, ci);


--
-- TOC entry 2740 (class 2606 OID 26899)
-- Dependencies: 226 226 3293
-- Name: PK_Accionis; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY accionis
    ADD CONSTRAINT "PK_Accionis" PRIMARY KEY (id);


--
-- TOC entry 2539 (class 2606 OID 26901)
-- Dependencies: 167 167 3293
-- Name: PK_ActiEcon; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY actiecon
    ADD CONSTRAINT "PK_ActiEcon" PRIMARY KEY (id);

ALTER TABLE actiecon CLUSTER ON "PK_ActiEcon";


--
-- TOC entry 2546 (class 2606 OID 26903)
-- Dependencies: 169 169 3293
-- Name: PK_AlicImp; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY alicimp
    ADD CONSTRAINT "PK_AlicImp" PRIMARY KEY (id);

ALTER TABLE alicimp CLUSTER ON "PK_AlicImp";


--
-- TOC entry 2753 (class 2606 OID 26905)
-- Dependencies: 229 229 3293
-- Name: PK_Asiento; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY asiento
    ADD CONSTRAINT "PK_Asiento" PRIMARY KEY (id);

ALTER TABLE asiento CLUSTER ON "PK_Asiento";


--
-- TOC entry 2554 (class 2606 OID 26907)
-- Dependencies: 171 171 3293
-- Name: PK_AsientoD; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY asientod
    ADD CONSTRAINT "PK_AsientoD" PRIMARY KEY (id);

ALTER TABLE asientod CLUSTER ON "PK_AsientoD";


--
-- TOC entry 2758 (class 2606 OID 26909)
-- Dependencies: 230 230 3293
-- Name: PK_AsientoM; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY asientom
    ADD CONSTRAINT "PK_AsientoM" PRIMARY KEY (id);

ALTER TABLE asientom CLUSTER ON "PK_AsientoM";


--
-- TOC entry 2763 (class 2606 OID 26911)
-- Dependencies: 232 232 3293
-- Name: PK_AsientoMD; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY asientomd
    ADD CONSTRAINT "PK_AsientoMD" PRIMARY KEY (id);

ALTER TABLE asientomd CLUSTER ON "PK_AsientoMD";


--
-- TOC entry 2558 (class 2606 OID 26913)
-- Dependencies: 174 174 3293
-- Name: PK_BaCuenta; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY bacuenta
    ADD CONSTRAINT "PK_BaCuenta" PRIMARY KEY (id);

ALTER TABLE bacuenta CLUSTER ON "PK_BaCuenta";


--
-- TOC entry 2561 (class 2606 OID 26915)
-- Dependencies: 176 176 3293
-- Name: PK_Bancos; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY bancos
    ADD CONSTRAINT "PK_Bancos" PRIMARY KEY (id);

ALTER TABLE bancos CLUSTER ON "PK_Bancos";


--
-- TOC entry 2565 (class 2606 OID 26917)
-- Dependencies: 178 178 3293
-- Name: PK_CalPagoD; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY calpagod
    ADD CONSTRAINT "PK_CalPagoD" PRIMARY KEY (id);

ALTER TABLE calpagod CLUSTER ON "PK_CalPagoD";


--
-- TOC entry 2574 (class 2606 OID 26919)
-- Dependencies: 180 180 3293
-- Name: PK_CalPagos; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY calpago
    ADD CONSTRAINT "PK_CalPagos" PRIMARY KEY (id);

ALTER TABLE calpago CLUSTER ON "PK_CalPagos";


--
-- TOC entry 2579 (class 2606 OID 26921)
-- Dependencies: 182 182 3293
-- Name: PK_Cargos; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY cargos
    ADD CONSTRAINT "PK_Cargos" PRIMARY KEY (id);

ALTER TABLE cargos CLUSTER ON "PK_Cargos";


--
-- TOC entry 2585 (class 2606 OID 26923)
-- Dependencies: 184 184 3293
-- Name: PK_Ciudades; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ciudades
    ADD CONSTRAINT "PK_Ciudades" PRIMARY KEY (id);

ALTER TABLE ciudades CLUSTER ON "PK_Ciudades";


--
-- TOC entry 2605 (class 2606 OID 26925)
-- Dependencies: 192 192 3293
-- Name: PK_ConUsu; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY conusu
    ADD CONSTRAINT "PK_ConUsu" PRIMARY KEY (id);

ALTER TABLE conusu CLUSTER ON "PK_ConUsu";


--
-- TOC entry 2591 (class 2606 OID 26927)
-- Dependencies: 186 186 3293
-- Name: PK_ConUsuCo; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY conusuco
    ADD CONSTRAINT "PK_ConUsuCo" PRIMARY KEY (id);

ALTER TABLE conusuco CLUSTER ON "PK_ConUsuCo";


--
-- TOC entry 2594 (class 2606 OID 26929)
-- Dependencies: 188 188 3293
-- Name: PK_ConUsuTi; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY conusuti
    ADD CONSTRAINT "PK_ConUsuTi" PRIMARY KEY (id);

ALTER TABLE conusuti CLUSTER ON "PK_ConUsuTi";


--
-- TOC entry 2599 (class 2606 OID 26931)
-- Dependencies: 190 190 3293
-- Name: PK_ConUsuTo; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY conusuto
    ADD CONSTRAINT "PK_ConUsuTo" PRIMARY KEY (id);

ALTER TABLE conusuto CLUSTER ON "PK_ConUsuTo";


--
-- TOC entry 2618 (class 2606 OID 26933)
-- Dependencies: 194 194 3293
-- Name: PK_Contribu; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY contribu
    ADD CONSTRAINT "PK_Contribu" PRIMARY KEY (id);

ALTER TABLE contribu CLUSTER ON "PK_Contribu";


--
-- TOC entry 2775 (class 2606 OID 26935)
-- Dependencies: 240 240 3293
-- Name: PK_ContribuTi; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY contributi
    ADD CONSTRAINT "PK_ContribuTi" PRIMARY KEY (id);

ALTER TABLE contributi CLUSTER ON "PK_ContribuTi";


--
-- TOC entry 2788 (class 2606 OID 26937)
-- Dependencies: 250 250 3293
-- Name: PK_CtaConta; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ctaconta
    ADD CONSTRAINT "PK_CtaConta" PRIMARY KEY (cuenta);

ALTER TABLE ctaconta CLUSTER ON "PK_CtaConta";


--
-- TOC entry 2804 (class 2606 OID 26939)
-- Dependencies: 251 251 3293
-- Name: PK_Decla; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT "PK_Decla" PRIMARY KEY (id);


--
-- TOC entry 2634 (class 2606 OID 26941)
-- Dependencies: 196 196 3293
-- Name: PK_Declara; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY declara_viejo
    ADD CONSTRAINT "PK_Declara" PRIMARY KEY (id);

ALTER TABLE declara_viejo CLUSTER ON "PK_Declara";


--
-- TOC entry 2638 (class 2606 OID 26943)
-- Dependencies: 198 198 3293
-- Name: PK_Departam; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY departam
    ADD CONSTRAINT "PK_Departam" PRIMARY KEY (id);

ALTER TABLE departam CLUSTER ON "PK_Departam";


--
-- TOC entry 2821 (class 2606 OID 26945)
-- Dependencies: 264 264 3293
-- Name: PK_Document; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY document
    ADD CONSTRAINT "PK_Document" PRIMARY KEY (id);

ALTER TABLE document CLUSTER ON "PK_Document";


--
-- TOC entry 2659 (class 2606 OID 26947)
-- Dependencies: 202 202 3293
-- Name: PK_Entidad; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY entidad
    ADD CONSTRAINT "PK_Entidad" PRIMARY KEY (id);

ALTER TABLE entidad CLUSTER ON "PK_Entidad";


--
-- TOC entry 2651 (class 2606 OID 26949)
-- Dependencies: 200 200 3293
-- Name: PK_EntidadD; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY entidadd
    ADD CONSTRAINT "PK_EntidadD" PRIMARY KEY (id);

ALTER TABLE entidadd CLUSTER ON "PK_EntidadD";


--
-- TOC entry 2664 (class 2606 OID 26951)
-- Dependencies: 204 204 3293
-- Name: PK_Estados; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY estados
    ADD CONSTRAINT "PK_Estados" PRIMARY KEY (id);

ALTER TABLE estados CLUSTER ON "PK_Estados";


--
-- TOC entry 2671 (class 2606 OID 26953)
-- Dependencies: 206 206 3293
-- Name: PK_PerUsuD; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY perusud
    ADD CONSTRAINT "PK_PerUsuD" PRIMARY KEY (id);

ALTER TABLE perusud CLUSTER ON "PK_PerUsuD";


--
-- TOC entry 2676 (class 2606 OID 26955)
-- Dependencies: 208 208 3293
-- Name: PK_PerUsu_IDPerUsu; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY perusu
    ADD CONSTRAINT "PK_PerUsu_IDPerUsu" PRIMARY KEY (id);

ALTER TABLE perusu CLUSTER ON "PK_PerUsu_IDPerUsu";


--
-- TOC entry 2681 (class 2606 OID 26957)
-- Dependencies: 210 210 3293
-- Name: PK_PregSecr; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY pregsecr
    ADD CONSTRAINT "PK_PregSecr" PRIMARY KEY (id);

ALTER TABLE pregsecr CLUSTER ON "PK_PregSecr";


--
-- TOC entry 2692 (class 2606 OID 26959)
-- Dependencies: 212 212 3293
-- Name: PK_RepLegal; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY replegal
    ADD CONSTRAINT "PK_RepLegal" PRIMARY KEY (id);

ALTER TABLE replegal CLUSTER ON "PK_RepLegal";


--
-- TOC entry 2697 (class 2606 OID 26961)
-- Dependencies: 214 214 3293
-- Name: PK_TDeclara; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tdeclara
    ADD CONSTRAINT "PK_TDeclara" PRIMARY KEY (id);

ALTER TABLE tdeclara CLUSTER ON "PK_TDeclara";


--
-- TOC entry 2702 (class 2606 OID 26963)
-- Dependencies: 216 216 3293
-- Name: PK_TiPeGrav; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tipegrav
    ADD CONSTRAINT "PK_TiPeGrav" PRIMARY KEY (id);

ALTER TABLE tipegrav CLUSTER ON "PK_TiPeGrav";


--
-- TOC entry 2708 (class 2606 OID 26965)
-- Dependencies: 218 218 3293
-- Name: PK_TipoCont; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tipocont
    ADD CONSTRAINT "PK_TipoCont" PRIMARY KEY (id);

ALTER TABLE tipocont CLUSTER ON "PK_TipoCont";


--
-- TOC entry 2853 (class 2606 OID 26967)
-- Dependencies: 272 272 3293
-- Name: PK_TmpContri; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tmpcontri
    ADD CONSTRAINT "PK_TmpContri" PRIMARY KEY (id);


--
-- TOC entry 2863 (class 2606 OID 26969)
-- Dependencies: 273 273 3293
-- Name: PK_TmpReLegal; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tmprelegal
    ADD CONSTRAINT "PK_TmpReLegal" PRIMARY KEY (id);


--
-- TOC entry 2713 (class 2606 OID 26971)
-- Dependencies: 220 220 3293
-- Name: PK_UndTrib; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY undtrib
    ADD CONSTRAINT "PK_UndTrib" PRIMARY KEY (id);

ALTER TABLE undtrib CLUSTER ON "PK_UndTrib";


--
-- TOC entry 2731 (class 2606 OID 26973)
-- Dependencies: 224 224 3293
-- Name: PK_UsFonPro; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY usfonpro
    ADD CONSTRAINT "PK_UsFonPro" PRIMARY KEY (id);

ALTER TABLE usfonpro CLUSTER ON "PK_UsFonPro";


--
-- TOC entry 2720 (class 2606 OID 26975)
-- Dependencies: 222 222 3293
-- Name: PK_UsFonpTo; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY usfonpto
    ADD CONSTRAINT "PK_UsFonpTo" PRIMARY KEY (id);

ALTER TABLE usfonpto CLUSTER ON "PK_UsFonpTo";


--
-- TOC entry 2769 (class 2606 OID 26977)
-- Dependencies: 238 238 3293
-- Name: PK_contribcalc; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY contrib_calc
    ADD CONSTRAINT "PK_contribcalc" PRIMARY KEY (id);


--
-- TOC entry 2831 (class 2606 OID 26979)
-- Dependencies: 270 270 3293
-- Name: PK_reparos; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY reparos
    ADD CONSTRAINT "PK_reparos" PRIMARY KEY (id);


--
-- TOC entry 2839 (class 2606 OID 26981)
-- Dependencies: 271 271 3293
-- Name: PK_tmpAccioni; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tmpaccioni
    ADD CONSTRAINT "PK_tmpAccioni" PRIMARY KEY (id);


--
-- TOC entry 2715 (class 2606 OID 26983)
-- Dependencies: 220 220 3293
-- Name: UK_anio_ut; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY undtrib
    ADD CONSTRAINT "UK_anio_ut" UNIQUE (anio);


--
-- TOC entry 2765 (class 2606 OID 26985)
-- Dependencies: 234 234 3293
-- Name: fk-asignacion-fiscla; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY asignacion_fiscales
    ADD CONSTRAINT "fk-asignacion-fiscla" PRIMARY KEY (id);


--
-- TOC entry 2607 (class 2606 OID 26987)
-- Dependencies: 192 192 3293
-- Name: login_conusu_unico; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY conusu
    ADD CONSTRAINT login_conusu_unico UNIQUE (login);


--
-- TOC entry 2783 (class 2606 OID 26989)
-- Dependencies: 246 246 3293
-- Name: pk-correlativo-actas; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY correlativos_actas
    ADD CONSTRAINT "pk-correlativo-actas" PRIMARY KEY (id);


--
-- TOC entry 2823 (class 2606 OID 26991)
-- Dependencies: 266 266 3293
-- Name: pk-interesbcv; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY interes_bcv
    ADD CONSTRAINT "pk-interesbcv" PRIMARY KEY (id);


--
-- TOC entry 2742 (class 2606 OID 26993)
-- Dependencies: 227 227 3293
-- Name: pk_actas_reparo_id; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY actas_reparo
    ADD CONSTRAINT pk_actas_reparo_id PRIMARY KEY (id);


--
-- TOC entry 2767 (class 2606 OID 26995)
-- Dependencies: 236 236 3293
-- Name: pk_con_img_doc; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY con_img_doc
    ADD CONSTRAINT pk_con_img_doc PRIMARY KEY (id);


--
-- TOC entry 2777 (class 2606 OID 26997)
-- Dependencies: 242 242 3293
-- Name: pk_conusu_interno; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY conusu_interno
    ADD CONSTRAINT pk_conusu_interno PRIMARY KEY (id);


--
-- TOC entry 2779 (class 2606 OID 26999)
-- Dependencies: 244 244 3293
-- Name: pk_conusu_tipocont; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY conusu_tipocont
    ADD CONSTRAINT pk_conusu_tipocont PRIMARY KEY (id);


--
-- TOC entry 2785 (class 2606 OID 27001)
-- Dependencies: 248 248 3293
-- Name: pk_correos_enviados; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY correos_enviados
    ADD CONSTRAINT pk_correos_enviados PRIMARY KEY (id);


--
-- TOC entry 2810 (class 2606 OID 27003)
-- Dependencies: 256 256 3293
-- Name: pk_descargos; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY descargos
    ADD CONSTRAINT pk_descargos PRIMARY KEY (id);


--
-- TOC entry 2814 (class 2606 OID 27005)
-- Dependencies: 260 260 3293
-- Name: pk_deta_contirbcalc; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY detalles_contrib_calc
    ADD CONSTRAINT pk_deta_contirbcalc PRIMARY KEY (id);


--
-- TOC entry 2812 (class 2606 OID 27007)
-- Dependencies: 258 258 3293
-- Name: pk_detalle_interes; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY detalle_interes
    ADD CONSTRAINT pk_detalle_interes PRIMARY KEY (id);


--
-- TOC entry 2816 (class 2606 OID 27009)
-- Dependencies: 262 262 3293
-- Name: pk_detalles_fiscalizacion; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY dettalles_fizcalizacion
    ADD CONSTRAINT pk_detalles_fiscalizacion PRIMARY KEY (id);


--
-- TOC entry 2825 (class 2606 OID 27011)
-- Dependencies: 268 268 3293
-- Name: pk_presidente; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY presidente
    ADD CONSTRAINT pk_presidente PRIMARY KEY (id);


--
-- TOC entry 2781 (class 2606 OID 27013)
-- Dependencies: 244 244 244 3293
-- Name: uq_tipoconid; Type: CONSTRAINT; Schema: datos; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY conusu_tipocont
    ADD CONSTRAINT uq_tipoconid UNIQUE (conusuid, tipocontid);


SET search_path = historial, pg_catalog;

--
-- TOC entry 2870 (class 2606 OID 27015)
-- Dependencies: 284 284 3293
-- Name: PK_Bitacora; Type: CONSTRAINT; Schema: historial; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY bitacora
    ADD CONSTRAINT "PK_Bitacora" PRIMARY KEY (id);

ALTER TABLE bitacora CLUSTER ON "PK_Bitacora";


SET search_path = pre_aprobacion, pg_catalog;

--
-- TOC entry 2806 (class 2606 OID 27017)
-- Dependencies: 253 253 3293
-- Name: pk-intereses; Type: CONSTRAINT; Schema: pre_aprobacion; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY intereses
    ADD CONSTRAINT "pk-intereses" PRIMARY KEY (id);


--
-- TOC entry 2808 (class 2606 OID 27019)
-- Dependencies: 254 254 3293
-- Name: pk-multa; Type: CONSTRAINT; Schema: pre_aprobacion; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY multas
    ADD CONSTRAINT "pk-multa" PRIMARY KEY (id);


SET search_path = public, pg_catalog;

--
-- TOC entry 2872 (class 2606 OID 27021)
-- Dependencies: 288 288 3293
-- Name: pk_contribucalc; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY contrib_calc
    ADD CONSTRAINT pk_contribucalc PRIMARY KEY (id);


SET search_path = seg, pg_catalog;

--
-- TOC entry 2874 (class 2606 OID 27023)
-- Dependencies: 289 289 3293
-- Name: pk_ci_sessions; Type: CONSTRAINT; Schema: seg; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_ci_sessions
    ADD CONSTRAINT pk_ci_sessions PRIMARY KEY (session_id);


--
-- TOC entry 2876 (class 2606 OID 27025)
-- Dependencies: 290 290 3293
-- Name: pk_modulo; Type: CONSTRAINT; Schema: seg; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_modulo
    ADD CONSTRAINT pk_modulo PRIMARY KEY (id_modulo);


--
-- TOC entry 2878 (class 2606 OID 27027)
-- Dependencies: 292 292 3293
-- Name: pk_permiso; Type: CONSTRAINT; Schema: seg; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_permiso
    ADD CONSTRAINT pk_permiso PRIMARY KEY (id_permiso);


--
-- TOC entry 2882 (class 2606 OID 27029)
-- Dependencies: 296 296 3293
-- Name: pk_premiso_usuario; Type: CONSTRAINT; Schema: seg; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_permiso_usuario
    ADD CONSTRAINT pk_premiso_usuario PRIMARY KEY (id_permiso_usuario);


--
-- TOC entry 2884 (class 2606 OID 27031)
-- Dependencies: 297 297 3293
-- Name: pk_rol; Type: CONSTRAINT; Schema: seg; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_rol
    ADD CONSTRAINT pk_rol PRIMARY KEY (id_rol);


--
-- TOC entry 2886 (class 2606 OID 27033)
-- Dependencies: 299 299 3293
-- Name: pk_rol_usuario; Type: CONSTRAINT; Schema: seg; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_rol_usuario
    ADD CONSTRAINT pk_rol_usuario PRIMARY KEY (id_rol_usuario);


--
-- TOC entry 2880 (class 2606 OID 27035)
-- Dependencies: 294 294 3293
-- Name: pkt_permiso; Type: CONSTRAINT; Schema: seg; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_permiso_trampa
    ADD CONSTRAINT pkt_permiso PRIMARY KEY (id_permiso);


--
-- TOC entry 2888 (class 2606 OID 27037)
-- Dependencies: 301 301 3293
-- Name: tbl_session_ci_pkey; Type: CONSTRAINT; Schema: seg; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_session_ci
    ADD CONSTRAINT tbl_session_ci_pkey PRIMARY KEY (session_id);


SET search_path = "segContribu", pg_catalog;

--
-- TOC entry 2890 (class 2606 OID 27039)
-- Dependencies: 305 305 3293
-- Name: pk_modulo; Type: CONSTRAINT; Schema: segContribu; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_modulo_contribu
    ADD CONSTRAINT pk_modulo PRIMARY KEY (id_modulo);


--
-- TOC entry 2892 (class 2606 OID 27041)
-- Dependencies: 307 307 3293
-- Name: pk_permiso; Type: CONSTRAINT; Schema: segContribu; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_permiso_contribu
    ADD CONSTRAINT pk_permiso PRIMARY KEY (id_permiso);


--
-- TOC entry 2894 (class 2606 OID 27043)
-- Dependencies: 309 309 3293
-- Name: pk_rol; Type: CONSTRAINT; Schema: segContribu; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_rol_contribu
    ADD CONSTRAINT pk_rol PRIMARY KEY (id_rol);


--
-- TOC entry 2896 (class 2606 OID 27045)
-- Dependencies: 311 311 3293
-- Name: pk_rol_usuario; Type: CONSTRAINT; Schema: segContribu; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_rol_usuario_contribu
    ADD CONSTRAINT pk_rol_usuario PRIMARY KEY (id_rol_usuario);


--
-- TOC entry 2898 (class 2606 OID 27047)
-- Dependencies: 313 313 3293
-- Name: pk_usuario_rol; Type: CONSTRAINT; Schema: segContribu; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tbl_usuario_rol_contribu
    ADD CONSTRAINT pk_usuario_rol PRIMARY KEY (id_usuario_rol);


SET search_path = datos, pg_catalog;

--
-- TOC entry 2734 (class 1259 OID 27048)
-- Dependencies: 226 3293
-- Name: FKI_Accionis_IDContribu; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Accionis_IDContribu" ON accionis USING btree (contribuid);


--
-- TOC entry 2735 (class 1259 OID 27049)
-- Dependencies: 226 3293
-- Name: FKI_Accionis_UsFonpro_UsuarioID_ID; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Accionis_UsFonpro_UsuarioID_ID" ON accionis USING btree (usuarioid);


--
-- TOC entry 2537 (class 1259 OID 27050)
-- Dependencies: 167 3293
-- Name: FKI_ActiEcon_USFonpro_IDUsuario_IDUsFornpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_ActiEcon_USFonpro_IDUsuario_IDUsFornpro" ON actiecon USING btree (usuarioid);


--
-- TOC entry 2542 (class 1259 OID 27051)
-- Dependencies: 169 3293
-- Name: FKI_AlicImp_TipoCont_IDTipoCont; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_AlicImp_TipoCont_IDTipoCont" ON alicimp USING btree (tipocontid);


--
-- TOC entry 2543 (class 1259 OID 27052)
-- Dependencies: 169 3293
-- Name: FKI_AlicImp_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_AlicImp_UsFonpro_IDUsuario_IDUsFonpro" ON alicimp USING btree (usuarioid);


--
-- TOC entry 2549 (class 1259 OID 27053)
-- Dependencies: 171 3293
-- Name: FKI_AsientoD_Asiento_IDAsiento; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_AsientoD_Asiento_IDAsiento" ON asientod USING btree (asientoid);


--
-- TOC entry 2550 (class 1259 OID 27054)
-- Dependencies: 171 3293
-- Name: FKI_AsientoD_CtaConta_Cuenta; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_AsientoD_CtaConta_Cuenta" ON asientod USING btree (cuenta);


--
-- TOC entry 2551 (class 1259 OID 27055)
-- Dependencies: 171 3293
-- Name: FKI_AsientoD_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_AsientoD_UsFonpro_IDUsuario_IDUsFonpro" ON asientod USING btree (usuarioid);


--
-- TOC entry 2759 (class 1259 OID 27056)
-- Dependencies: 232 3293
-- Name: FKI_AsientoMD_AsientoM_AsientoMID_ID; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_AsientoMD_AsientoM_AsientoMID_ID" ON asientomd USING btree (asientomid);


--
-- TOC entry 2760 (class 1259 OID 27057)
-- Dependencies: 232 3293
-- Name: FKI_AsientoMD_CtaConta_Cuenta; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_AsientoMD_CtaConta_Cuenta" ON asientomd USING btree (cuenta);


--
-- TOC entry 2761 (class 1259 OID 27058)
-- Dependencies: 232 3293
-- Name: FKI_AsientoMD_UsFonpro_UsuarioID_ID; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_AsientoMD_UsFonpro_UsuarioID_ID" ON asientomd USING btree (usuarioid);


--
-- TOC entry 2756 (class 1259 OID 27059)
-- Dependencies: 230 3293
-- Name: FKI_AsientoM_UsFonpro_UsuarioID_ID; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_AsientoM_UsFonpro_UsuarioID_ID" ON asientom USING btree (usuarioid);


--
-- TOC entry 2745 (class 1259 OID 27060)
-- Dependencies: 229 3293
-- Name: FKI_Asiento_UsFonpro_IDUsCierre_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Asiento_UsFonpro_IDUsCierre_IDUsFonpro" ON asiento USING btree (uscierreid);


--
-- TOC entry 2746 (class 1259 OID 27061)
-- Dependencies: 229 3293
-- Name: FKI_Asiento_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Asiento_UsFonpro_IDUsuario_IDUsFonpro" ON asiento USING btree (usuarioid);


--
-- TOC entry 2555 (class 1259 OID 27062)
-- Dependencies: 174 3293
-- Name: FKI_BaCuenta_Bancos_IDBanco; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_BaCuenta_Bancos_IDBanco" ON bacuenta USING btree (bancoid);


--
-- TOC entry 2556 (class 1259 OID 27063)
-- Dependencies: 174 3293
-- Name: FKI_BaCuenta_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_BaCuenta_UsFonpro_IDUsuario_IDUsFonpro" ON bacuenta USING btree (usuarioid);


--
-- TOC entry 2559 (class 1259 OID 27064)
-- Dependencies: 176 3293
-- Name: FKI_Bancos_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Bancos_UsFonpro_IDUsuario_IDUsFonpro" ON bancos USING btree (usuarioid);


--
-- TOC entry 2562 (class 1259 OID 27065)
-- Dependencies: 178 3293
-- Name: FKI_CalPagoD_CalPago_IDCalPago; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_CalPagoD_CalPago_IDCalPago" ON calpagod USING btree (calpagoid);


--
-- TOC entry 2563 (class 1259 OID 27066)
-- Dependencies: 178 3293
-- Name: FKI_CalPagoD_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_CalPagoD_UsFonpro_IDUsuario_IDUsFonpro" ON calpagod USING btree (usuarioid);


--
-- TOC entry 2570 (class 1259 OID 27067)
-- Dependencies: 180 3293
-- Name: FKI_CalPago_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_CalPago_UsFonpro_IDUsuario_IDUsFonpro" ON calpago USING btree (usuarioid);


--
-- TOC entry 2571 (class 1259 OID 27068)
-- Dependencies: 180 3293
-- Name: FKI_CalPagos_TiPeGrav_IDTiPeGrav; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_CalPagos_TiPeGrav_IDTiPeGrav" ON calpago USING btree (tipegravid);


--
-- TOC entry 2577 (class 1259 OID 27069)
-- Dependencies: 182 3293
-- Name: FKI_Cargos_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Cargos_UsFonpro_IDUsuario_IDUsFonpro" ON cargos USING btree (usuarioid);


--
-- TOC entry 2582 (class 1259 OID 27070)
-- Dependencies: 184 3293
-- Name: FKI_Ciudades_Estados_IDEstado; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Ciudades_Estados_IDEstado" ON ciudades USING btree (estadoid);


--
-- TOC entry 2583 (class 1259 OID 27071)
-- Dependencies: 184 3293
-- Name: FKI_Ciudades_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Ciudades_UsFonpro_IDUsuario_IDUsFonpro" ON ciudades USING btree (usuarioid);


--
-- TOC entry 2588 (class 1259 OID 27072)
-- Dependencies: 186 3293
-- Name: FKI_ConUsuCo_ConUsu_IDConUsu; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_ConUsuCo_ConUsu_IDConUsu" ON conusuco USING btree (conusuid);


--
-- TOC entry 2589 (class 1259 OID 27073)
-- Dependencies: 186 3293
-- Name: FKI_ConUsuCo_Contribu_IDContribu; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_ConUsuCo_Contribu_IDContribu" ON conusuco USING btree (contribuid);


--
-- TOC entry 2592 (class 1259 OID 27074)
-- Dependencies: 188 3293
-- Name: FKI_ConUsuTi_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_ConUsuTi_UsFonpro_IDUsuario_IDUsFonpro" ON conusuti USING btree (usuarioid);


--
-- TOC entry 2597 (class 1259 OID 27075)
-- Dependencies: 190 3293
-- Name: FKI_ConUsuTo_ConUsu_IDConUsu; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_ConUsuTo_ConUsu_IDConUsu" ON conusuto USING btree (conusuid);


--
-- TOC entry 2600 (class 1259 OID 27076)
-- Dependencies: 192 3293
-- Name: FKI_ConUsu_ConUsuTi_IDConUsuTi; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_ConUsu_ConUsuTi_IDConUsuTi" ON conusu USING btree (conusutiid);


--
-- TOC entry 2601 (class 1259 OID 27077)
-- Dependencies: 192 3293
-- Name: FKI_ConUsu_PregSecr_IDPregSecr; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_ConUsu_PregSecr_IDPregSecr" ON conusu USING btree (pregsecrid);


--
-- TOC entry 2602 (class 1259 OID 27078)
-- Dependencies: 192 3293
-- Name: FKI_ConUsu_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_ConUsu_UsFonpro_IDUsuario_IDUsFonpro" ON conusu USING btree (usuarioid);


--
-- TOC entry 2772 (class 1259 OID 27079)
-- Dependencies: 240 3293
-- Name: FKI_ContribuTi_Contribu_ContribuID_ID; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_ContribuTi_Contribu_ContribuID_ID" ON contributi USING btree (contribuid);


--
-- TOC entry 2773 (class 1259 OID 27080)
-- Dependencies: 240 3293
-- Name: FKI_ContribuTi_TipoCont_TipoContID_ID; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_ContribuTi_TipoCont_TipoContID_ID" ON contributi USING btree (tipocontid);


--
-- TOC entry 2612 (class 1259 OID 27081)
-- Dependencies: 194 3293
-- Name: FKI_Contribu_ActiEcon_IDActiEcon; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Contribu_ActiEcon_IDActiEcon" ON contribu USING btree (actieconid);


--
-- TOC entry 2613 (class 1259 OID 27082)
-- Dependencies: 194 3293
-- Name: FKI_Contribu_Ciudades_IDCiudad; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Contribu_Ciudades_IDCiudad" ON contribu USING btree (ciudadid);


--
-- TOC entry 2614 (class 1259 OID 27083)
-- Dependencies: 194 3293
-- Name: FKI_Contribu_ConUsu_UsuarioID_ID; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Contribu_ConUsu_UsuarioID_ID" ON contribu USING btree (usuarioid);


--
-- TOC entry 2615 (class 1259 OID 27084)
-- Dependencies: 194 3293
-- Name: FKI_Contribu_Estados_IDEstado; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Contribu_Estados_IDEstado" ON contribu USING btree (estadoid);


--
-- TOC entry 2786 (class 1259 OID 27085)
-- Dependencies: 250 3293
-- Name: FKI_CtaConta_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_CtaConta_UsFonpro_IDUsuario_IDUsFonpro" ON ctaconta USING btree (usuarioid);


--
-- TOC entry 2793 (class 1259 OID 27086)
-- Dependencies: 251 3293
-- Name: FKI_Decla_Asiento_IDAsiento; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Decla_Asiento_IDAsiento" ON declara USING btree (asientoid);


--
-- TOC entry 2794 (class 1259 OID 27087)
-- Dependencies: 251 3293
-- Name: FKI_Decla_PlaSustID_ID; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Decla_PlaSustID_ID" ON declara USING btree (plasustid);


--
-- TOC entry 2795 (class 1259 OID 27088)
-- Dependencies: 251 3293
-- Name: FKI_Decla_RepLegal_IDRepLegal; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Decla_RepLegal_IDRepLegal" ON declara USING btree (replegalid);


--
-- TOC entry 2796 (class 1259 OID 27089)
-- Dependencies: 251 3293
-- Name: FKI_Decla_TDeclara_IDTDeclara; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Decla_TDeclara_IDTDeclara" ON declara USING btree (tdeclaraid);


--
-- TOC entry 2797 (class 1259 OID 27090)
-- Dependencies: 251 3293
-- Name: FKI_Decla_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Decla_UsFonpro_IDUsuario_IDUsFonpro" ON declara USING btree (usuarioid);


--
-- TOC entry 2623 (class 1259 OID 27091)
-- Dependencies: 196 3293
-- Name: FKI_Declara_Asiento_IDAsiento; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Declara_Asiento_IDAsiento" ON declara_viejo USING btree (asientoid);


--
-- TOC entry 2624 (class 1259 OID 27092)
-- Dependencies: 196 3293
-- Name: FKI_Declara_PlaSustID_ID; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Declara_PlaSustID_ID" ON declara_viejo USING btree (plasustid);


--
-- TOC entry 2625 (class 1259 OID 27093)
-- Dependencies: 196 3293
-- Name: FKI_Declara_RepLegal_IDRepLegal; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Declara_RepLegal_IDRepLegal" ON declara_viejo USING btree (replegalid);


--
-- TOC entry 2626 (class 1259 OID 27094)
-- Dependencies: 196 3293
-- Name: FKI_Declara_TDeclara_IDTDeclara; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Declara_TDeclara_IDTDeclara" ON declara_viejo USING btree (tdeclaraid);


--
-- TOC entry 2627 (class 1259 OID 27095)
-- Dependencies: 196 3293
-- Name: FKI_Declara_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Declara_UsFonpro_IDUsuario_IDUsFonpro" ON declara_viejo USING btree (usuarioid);


--
-- TOC entry 2819 (class 1259 OID 27096)
-- Dependencies: 264 3293
-- Name: FKI_Document_UsFonpro_UsFonproID_ID; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Document_UsFonpro_UsFonproID_ID" ON document USING btree (usfonproid);


--
-- TOC entry 2646 (class 1259 OID 27097)
-- Dependencies: 200 3293
-- Name: FKI_EntidadD_Entidad_IDEntidad; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_EntidadD_Entidad_IDEntidad" ON entidadd USING btree (entidadid);


--
-- TOC entry 2662 (class 1259 OID 27098)
-- Dependencies: 204 3293
-- Name: FKI_Estados_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_Estados_UsFonpro_IDUsuario_IDUsFonpro" ON estados USING btree (usuarioid);


--
-- TOC entry 2667 (class 1259 OID 27099)
-- Dependencies: 206 3293
-- Name: FKI_PerUsuD_EndidadD_IDEntidadD; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_PerUsuD_EndidadD_IDEntidadD" ON perusud USING btree (entidaddid);


--
-- TOC entry 2668 (class 1259 OID 27100)
-- Dependencies: 206 3293
-- Name: FKI_PerUsuD_PerUsu_IDPerUsu; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_PerUsuD_PerUsu_IDPerUsu" ON perusud USING btree (perusuid);


--
-- TOC entry 2669 (class 1259 OID 27101)
-- Dependencies: 206 3293
-- Name: FKI_PerUsuD_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_PerUsuD_UsFonpro_IDUsuario_IDUsFonpro" ON perusud USING btree (usuarioid);


--
-- TOC entry 2674 (class 1259 OID 27102)
-- Dependencies: 208 3293
-- Name: FKI_PerUsu_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_PerUsu_UsFonpro_IDUsuario_IDUsFonpro" ON perusu USING btree (usuarioid);


--
-- TOC entry 2679 (class 1259 OID 27103)
-- Dependencies: 210 3293
-- Name: FKI_PregSecr_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_PregSecr_UsFonpro_IDUsuario_IDUsFonpro" ON pregsecr USING btree (usuarioid);


--
-- TOC entry 2684 (class 1259 OID 27104)
-- Dependencies: 212 3293
-- Name: FKI_RepLegal_IDCiudad; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_RepLegal_IDCiudad" ON replegal USING btree (ciudadid);


--
-- TOC entry 2685 (class 1259 OID 27105)
-- Dependencies: 212 3293
-- Name: FKI_RepLegal_IDContribu; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_RepLegal_IDContribu" ON replegal USING btree (contribuid);


--
-- TOC entry 2686 (class 1259 OID 27106)
-- Dependencies: 212 3293
-- Name: FKI_RepLegal_IDEstado; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_RepLegal_IDEstado" ON replegal USING btree (estadoid);


--
-- TOC entry 2687 (class 1259 OID 27107)
-- Dependencies: 212 3293
-- Name: FKI_RepLegal_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_RepLegal_UsFonpro_IDUsuario_IDUsFonpro" ON replegal USING btree (usuarioid);


--
-- TOC entry 2695 (class 1259 OID 27108)
-- Dependencies: 214 3293
-- Name: FKI_TDeclara_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TDeclara_UsFonpro_IDUsuario_IDUsFonpro" ON tdeclara USING btree (usuarioid);


--
-- TOC entry 2700 (class 1259 OID 27109)
-- Dependencies: 216 3293
-- Name: FKI_TiPeGrav_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TiPeGrav_UsFonpro_IDUsuario_IDUsFonpro" ON tipegrav USING btree (usuarioid);


--
-- TOC entry 2705 (class 1259 OID 27110)
-- Dependencies: 218 3293
-- Name: FKI_TipoCont_TiPeGrav_IDTiPeGrav; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TipoCont_TiPeGrav_IDTiPeGrav" ON tipocont USING btree (tipegravid);


--
-- TOC entry 2706 (class 1259 OID 27111)
-- Dependencies: 218 3293
-- Name: FKI_TipoCont_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TipoCont_UsFonpro_IDUsuario_IDUsFonpro" ON tipocont USING btree (usuarioid);


--
-- TOC entry 2846 (class 1259 OID 27112)
-- Dependencies: 272 3293
-- Name: FKI_TmpContri_ActiEcon_IDActiEcon; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TmpContri_ActiEcon_IDActiEcon" ON tmpcontri USING btree (actieconid);


--
-- TOC entry 2847 (class 1259 OID 27113)
-- Dependencies: 272 3293
-- Name: FKI_TmpContri_Ciudades_IDCiudad; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TmpContri_Ciudades_IDCiudad" ON tmpcontri USING btree (ciudadid);


--
-- TOC entry 2848 (class 1259 OID 27114)
-- Dependencies: 272 3293
-- Name: FKI_TmpContri_Contribu_IDContribu; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TmpContri_Contribu_IDContribu" ON tmpcontri USING btree (id);


--
-- TOC entry 2849 (class 1259 OID 27115)
-- Dependencies: 272 3293
-- Name: FKI_TmpContri_Estados_IDEstado; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TmpContri_Estados_IDEstado" ON tmpcontri USING btree (estadoid);


--
-- TOC entry 2850 (class 1259 OID 27116)
-- Dependencies: 272 3293
-- Name: FKI_TmpContri_TipoCont_IDTipoCont; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TmpContri_TipoCont_IDTipoCont" ON tmpcontri USING btree (tipocontid);


--
-- TOC entry 2856 (class 1259 OID 27117)
-- Dependencies: 273 3293
-- Name: FKI_TmpReLegal_IDCiudad; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TmpReLegal_IDCiudad" ON tmprelegal USING btree (ciudadid);


--
-- TOC entry 2857 (class 1259 OID 27118)
-- Dependencies: 273 3293
-- Name: FKI_TmpReLegal_IDContribu; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TmpReLegal_IDContribu" ON tmprelegal USING btree (contribuid);


--
-- TOC entry 2858 (class 1259 OID 27119)
-- Dependencies: 273 3293
-- Name: FKI_TmpReLegal_IDEstado; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_TmpReLegal_IDEstado" ON tmprelegal USING btree (estadoid);


--
-- TOC entry 2711 (class 1259 OID 27120)
-- Dependencies: 220 3293
-- Name: FKI_UndTrib_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_UndTrib_UsFonpro_IDUsuario_IDUsFonpro" ON undtrib USING btree (usuarioid);


--
-- TOC entry 2725 (class 1259 OID 27121)
-- Dependencies: 224 3293
-- Name: FKI_UsFonPro_PregSecr_IDPregSecr; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_UsFonPro_PregSecr_IDPregSecr" ON usfonpro USING btree (pregsecrid);


--
-- TOC entry 2718 (class 1259 OID 27122)
-- Dependencies: 222 3293
-- Name: FKI_UsFonpTo_UsFonpro_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_UsFonpTo_UsFonpro_IDUsFonpro" ON usfonpto USING btree (usfonproid);


--
-- TOC entry 2726 (class 1259 OID 27123)
-- Dependencies: 224 3293
-- Name: FKI_UsFonpro_Cargos_IDCargo; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_UsFonpro_Cargos_IDCargo" ON usfonpro USING btree (cargoid);


--
-- TOC entry 2727 (class 1259 OID 27124)
-- Dependencies: 224 3293
-- Name: FKI_UsFonpro_Departam_IDDepartam; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_UsFonpro_Departam_IDDepartam" ON usfonpro USING btree (departamid);


--
-- TOC entry 2728 (class 1259 OID 27125)
-- Dependencies: 224 3293
-- Name: FKI_UsFonpro_PerUsu_IDPerUsu; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_UsFonpro_PerUsu_IDPerUsu" ON usfonpro USING btree (perusuid);


--
-- TOC entry 2826 (class 1259 OID 27126)
-- Dependencies: 270 3293
-- Name: FKI_reparos_Asiento_IDAsiento; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_reparos_Asiento_IDAsiento" ON reparos USING btree (asientoid);


--
-- TOC entry 2827 (class 1259 OID 27127)
-- Dependencies: 270 3293
-- Name: FKI_reparos_TDeclara_IDTDeclara; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_reparos_TDeclara_IDTDeclara" ON reparos USING btree (tdeclaraid);


--
-- TOC entry 2828 (class 1259 OID 27128)
-- Dependencies: 270 3293
-- Name: FKI_reparos_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_reparos_UsFonpro_IDUsuario_IDUsFonpro" ON reparos USING btree (usuarioid);


--
-- TOC entry 2834 (class 1259 OID 27129)
-- Dependencies: 271 3293
-- Name: FKI_tmpAccioni_IDContribu; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "FKI_tmpAccioni_IDContribu" ON tmpaccioni USING btree (contribuid);


--
-- TOC entry 2736 (class 1259 OID 27130)
-- Dependencies: 226 3293
-- Name: IX_Accionis_Apellido; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Accionis_Apellido" ON accionis USING btree (apellido);


--
-- TOC entry 2737 (class 1259 OID 27131)
-- Dependencies: 226 3293
-- Name: IX_Accionis_Ci; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Accionis_Ci" ON accionis USING btree (ci);


--
-- TOC entry 2738 (class 1259 OID 27132)
-- Dependencies: 226 3293
-- Name: IX_Accionis_Nombre; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Accionis_Nombre" ON accionis USING btree (nombre);


--
-- TOC entry 2544 (class 1259 OID 27133)
-- Dependencies: 169 3293
-- Name: IX_AlicImp_Ano; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_AlicImp_Ano" ON alicimp USING btree (ano);


--
-- TOC entry 2552 (class 1259 OID 27134)
-- Dependencies: 171 3293
-- Name: IX_AsientoD_Fecha; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_AsientoD_Fecha" ON asientod USING btree (fecha);


--
-- TOC entry 2747 (class 1259 OID 27135)
-- Dependencies: 229 3293
-- Name: IX_Asiento_Ano; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Asiento_Ano" ON asiento USING btree (ano);


--
-- TOC entry 2748 (class 1259 OID 27136)
-- Dependencies: 229 3293
-- Name: IX_Asiento_Cerrado; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Asiento_Cerrado" ON asiento USING btree (cerrado);


--
-- TOC entry 2749 (class 1259 OID 27137)
-- Dependencies: 229 3293
-- Name: IX_Asiento_Fecha; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Asiento_Fecha" ON asiento USING btree (fecha);


--
-- TOC entry 2750 (class 1259 OID 27138)
-- Dependencies: 229 3293
-- Name: IX_Asiento_Mes; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Asiento_Mes" ON asiento USING btree (mes);


--
-- TOC entry 2751 (class 1259 OID 27139)
-- Dependencies: 229 3293
-- Name: IX_Asiento_NuAsiento; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Asiento_NuAsiento" ON asiento USING btree (nuasiento);


--
-- TOC entry 2572 (class 1259 OID 27140)
-- Dependencies: 180 3293
-- Name: IX_CalPagos_Ano; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_CalPagos_Ano" ON calpago USING btree (ano);


--
-- TOC entry 2603 (class 1259 OID 27141)
-- Dependencies: 192 3293
-- Name: IX_ConUsu_Password; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_ConUsu_Password" ON conusu USING btree (password);


--
-- TOC entry 2616 (class 1259 OID 27142)
-- Dependencies: 194 3293
-- Name: IX_Contribu_DenComerci; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Contribu_DenComerci" ON contribu USING btree (dencomerci);


--
-- TOC entry 2798 (class 1259 OID 27143)
-- Dependencies: 251 3293
-- Name: IX_Decla_FechaConci; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Decla_FechaConci" ON declara USING btree (fechaconci);


--
-- TOC entry 2799 (class 1259 OID 27144)
-- Dependencies: 251 3293
-- Name: IX_Decla_FechaElab; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Decla_FechaElab" ON declara USING btree (fechaelab);


--
-- TOC entry 2800 (class 1259 OID 27145)
-- Dependencies: 251 3293
-- Name: IX_Decla_FechaFin; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Decla_FechaFin" ON declara USING btree (fechafin);


--
-- TOC entry 2801 (class 1259 OID 27146)
-- Dependencies: 251 3293
-- Name: IX_Decla_FechaIni; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Decla_FechaIni" ON declara USING btree (fechaini);


--
-- TOC entry 2802 (class 1259 OID 27147)
-- Dependencies: 251 3293
-- Name: IX_Decla_FechaPago; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Decla_FechaPago" ON declara USING btree (fechapago);


--
-- TOC entry 2628 (class 1259 OID 27148)
-- Dependencies: 196 3293
-- Name: IX_Declara_FechaConci; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Declara_FechaConci" ON declara_viejo USING btree (fechaconci);


--
-- TOC entry 2629 (class 1259 OID 27149)
-- Dependencies: 196 3293
-- Name: IX_Declara_FechaElab; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Declara_FechaElab" ON declara_viejo USING btree (fechaelab);


--
-- TOC entry 2630 (class 1259 OID 27150)
-- Dependencies: 196 3293
-- Name: IX_Declara_FechaFin; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Declara_FechaFin" ON declara_viejo USING btree (fechafin);


--
-- TOC entry 2631 (class 1259 OID 27151)
-- Dependencies: 196 3293
-- Name: IX_Declara_FechaIni; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Declara_FechaIni" ON declara_viejo USING btree (fechaini);


--
-- TOC entry 2632 (class 1259 OID 27152)
-- Dependencies: 196 3293
-- Name: IX_Declara_FechaPago; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Declara_FechaPago" ON declara_viejo USING btree (fechapago);


--
-- TOC entry 2647 (class 1259 OID 27153)
-- Dependencies: 200 3293
-- Name: IX_EntidadD_Accion; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_EntidadD_Accion" ON entidadd USING btree (accion);


--
-- TOC entry 2648 (class 1259 OID 27154)
-- Dependencies: 200 3293
-- Name: IX_EntidadD_Nombre; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_EntidadD_Nombre" ON entidadd USING btree (nombre);


--
-- TOC entry 2649 (class 1259 OID 27155)
-- Dependencies: 200 3293
-- Name: IX_EntidadD_Orden; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_EntidadD_Orden" ON entidadd USING btree (orden);


--
-- TOC entry 2688 (class 1259 OID 27156)
-- Dependencies: 212 3293
-- Name: IX_RepLegal_Apellido; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_RepLegal_Apellido" ON replegal USING btree (apellido);


--
-- TOC entry 2689 (class 1259 OID 27157)
-- Dependencies: 212 3293
-- Name: IX_RepLegal_Ci; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_RepLegal_Ci" ON replegal USING btree (ci);


--
-- TOC entry 2690 (class 1259 OID 27158)
-- Dependencies: 212 3293
-- Name: IX_RepLegal_Nombre; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_RepLegal_Nombre" ON replegal USING btree (nombre);


--
-- TOC entry 2851 (class 1259 OID 27159)
-- Dependencies: 272 3293
-- Name: IX_TmpContri_DenComerci; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_TmpContri_DenComerci" ON tmpcontri USING btree (dencomerci);


--
-- TOC entry 2859 (class 1259 OID 27160)
-- Dependencies: 273 3293
-- Name: IX_TmpReLegalNombre; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_TmpReLegalNombre" ON tmprelegal USING btree (nombre);


--
-- TOC entry 2860 (class 1259 OID 27161)
-- Dependencies: 273 3293
-- Name: IX_TmpReLegal_Apellido; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_TmpReLegal_Apellido" ON tmprelegal USING btree (apellido);


--
-- TOC entry 2861 (class 1259 OID 27162)
-- Dependencies: 273 3293
-- Name: IX_TmpReLegal_Ci; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_TmpReLegal_Ci" ON tmprelegal USING btree (ci);


--
-- TOC entry 2729 (class 1259 OID 27163)
-- Dependencies: 224 3293
-- Name: IX_UsFonPro_Password; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_UsFonPro_Password" ON usfonpro USING btree (password);


--
-- TOC entry 2829 (class 1259 OID 27164)
-- Dependencies: 270 3293
-- Name: IX_reparos_FechaElab; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_reparos_FechaElab" ON reparos USING btree (fechaelab);


--
-- TOC entry 2835 (class 1259 OID 27165)
-- Dependencies: 271 3293
-- Name: IX_tmpAccioni_Apellido; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_tmpAccioni_Apellido" ON tmpaccioni USING btree (apellido);


--
-- TOC entry 2836 (class 1259 OID 27166)
-- Dependencies: 271 3293
-- Name: IX_tmpAccioni_Ci; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_tmpAccioni_Ci" ON tmpaccioni USING btree (ci);


--
-- TOC entry 2837 (class 1259 OID 27167)
-- Dependencies: 271 3293
-- Name: IX_tmpAccioni_Nombre; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_tmpAccioni_Nombre" ON tmpaccioni USING btree (nombre);


--
-- TOC entry 2639 (class 1259 OID 27168)
-- Dependencies: 198 3293
-- Name: fki_FL_Departam_UsFonpro_IDUsuario_IDUsFonpro; Type: INDEX; Schema: datos; Owner: postgres; Tablespace: 
--

CREATE INDEX "fki_FL_Departam_UsFonpro_IDUsuario_IDUsFonpro" ON departam USING btree (usuarioid);


SET search_path = historial, pg_catalog;

--
-- TOC entry 2864 (class 1259 OID 27169)
-- Dependencies: 284 3293
-- Name: IX_Accion; Type: INDEX; Schema: historial; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Accion" ON bitacora USING btree (accion);


--
-- TOC entry 2865 (class 1259 OID 27170)
-- Dependencies: 284 3293
-- Name: IX_Fecha; Type: INDEX; Schema: historial; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Fecha" ON bitacora USING btree (fecha);


--
-- TOC entry 2866 (class 1259 OID 27171)
-- Dependencies: 284 3293
-- Name: IX_IDUsuario; Type: INDEX; Schema: historial; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_IDUsuario" ON bitacora USING btree (idusuario);


--
-- TOC entry 2867 (class 1259 OID 27172)
-- Dependencies: 284 3293
-- Name: IX_Tabla; Type: INDEX; Schema: historial; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_Tabla" ON bitacora USING btree (tabla);


--
-- TOC entry 2868 (class 1259 OID 27173)
-- Dependencies: 284 3293
-- Name: IX_ValDelID; Type: INDEX; Schema: historial; Owner: postgres; Tablespace: 
--

CREATE INDEX "IX_ValDelID" ON bitacora USING btree (valdelid);


SET search_path = datos, pg_catalog;

--
-- TOC entry 3154 (class 2618 OID 27174)
-- Dependencies: 224 224 224 224 290 290 290 290 290 292 292 292 292 297 297 297 299 299 299 2731 274 3293
-- Name: _RETURN; Type: RULE; Schema: datos; Owner: postgres
--

CREATE RULE "_RETURN" AS ON SELECT TO view_modulo_usuario_contribuyente_permiso DO INSTEAD SELECT usu.id, usu.nombre, rol.str_rol, per.id_modulo, mod.str_nombre, mod.str_enlace, max(per.int_permiso) AS int_permiso, CASE WHEN (mod.id_padre IS NULL) THEN (mod.id_modulo * 10) ELSE ((mod.id_padre * 10) + mod.id_modulo) END AS int_orden, CASE WHEN (mod.id_padre IS NULL) THEN (0)::bigint ELSE mod.id_padre END AS id_padre FROM ((((usfonpro usu JOIN seg.tbl_rol_usuario rus ON ((usu.id = rus.id_usuario))) JOIN seg.tbl_rol rol ON ((rus.id_rol = rol.id_rol))) JOIN seg.tbl_permiso per ON ((rol.id_rol = per.id_rol))) JOIN seg.tbl_modulo mod ON ((per.id_modulo = mod.id_modulo))) WHERE (((((NOT usu.inactivo) AND (NOT rus.bln_borrado)) AND (NOT rol.bln_borrado)) AND (NOT per.bln_borrado)) AND (NOT mod.bln_borrado)) GROUP BY usu.id, usu.login, rol.str_rol, per.id_modulo, mod.str_nombre, mod.str_enlace, mod.id_padre, mod.id_modulo;


SET search_path = seg, pg_catalog;

--
-- TOC entry 3155 (class 2618 OID 27176)
-- Dependencies: 224 290 290 290 290 297 297 292 290 2876 290 224 292 2731 299 292 292 224 224 299 299 297 303 3293
-- Name: _RETURN; Type: RULE; Schema: seg; Owner: postgres
--

CREATE RULE "_RETURN" AS ON SELECT TO view_modulo_usuario_permiso DO INSTEAD SELECT usu.id, usu.nombre, rol.str_rol, per.id_modulo, mod.str_nombre, mod.str_enlace, max(per.int_permiso) AS int_permiso, CASE WHEN (mod.id_padre IS NULL) THEN (mod.id_modulo * 10) ELSE ((mod.id_padre * 10) + mod.id_modulo) END AS int_orden, CASE WHEN (mod.id_padre IS NULL) THEN (0)::bigint ELSE mod.id_padre END AS id_padre, mod.orden_menu FROM ((((datos.usfonpro usu JOIN tbl_rol_usuario rus ON ((usu.id = rus.id_usuario))) JOIN tbl_rol rol ON ((rus.id_rol = rol.id_rol))) JOIN tbl_permiso per ON ((rol.id_rol = per.id_rol))) JOIN tbl_modulo mod ON ((per.id_modulo = mod.id_modulo))) WHERE (((((NOT usu.inactivo) AND (NOT rus.bln_borrado)) AND (NOT rol.bln_borrado)) AND (NOT per.bln_borrado)) AND (NOT mod.bln_borrado)) GROUP BY usu.id, usu.login, rol.str_rol, per.id_modulo, mod.str_nombre, mod.str_enlace, mod.id_padre, mod.id_modulo;


SET search_path = "segContribu", pg_catalog;

--
-- TOC entry 3156 (class 2618 OID 27178)
-- Dependencies: 2605 192 192 192 305 305 305 305 305 307 307 307 307 309 309 309 311 311 311 315 3293
-- Name: _RETURN; Type: RULE; Schema: segContribu; Owner: postgres
--

CREATE RULE "_RETURN" AS ON SELECT TO view_modulo_usuariocontribuyente_permiso DO INSTEAD SELECT usu.id, usu.nombre, rol.str_rol, per.id_modulo, mod.str_nombre, mod.str_enlace, max(per.int_permiso) AS int_permiso, CASE WHEN (mod.id_padre IS NULL) THEN (mod.id_modulo * 10) ELSE ((mod.id_padre * 10) + mod.id_modulo) END AS int_orden, CASE WHEN (mod.id_padre IS NULL) THEN (0)::bigint ELSE mod.id_padre END AS id_padre FROM ((((datos.conusu usu JOIN tbl_rol_usuario_contribu rus ON ((usu.id = rus.id_usuario))) JOIN tbl_rol_contribu rol ON ((rus.id_rol = rol.id_rol))) JOIN tbl_permiso_contribu per ON ((rol.id_rol = per.id_rol))) JOIN tbl_modulo_contribu mod ON ((per.id_modulo = mod.id_modulo))) WHERE ((((NOT rus.bln_borrado) AND (NOT rol.bln_borrado)) AND (NOT per.bln_borrado)) AND (NOT mod.bln_borrado)) GROUP BY usu.id, usu.login, rol.str_rol, per.id_modulo, mod.str_nombre, mod.str_enlace, mod.id_padre, mod.id_modulo;


SET search_path = datos, pg_catalog;

--
-- TOC entry 3033 (class 2620 OID 27180)
-- Dependencies: 229 229 336 229 3293
-- Name: TG_Asiendo_ActualizaSaldo; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_Asiendo_ActualizaSaldo" BEFORE UPDATE OF debe, haber ON asiento FOR EACH ROW EXECUTE PROCEDURE "tf_Asiento_ActualizaSaldo"();


--
-- TOC entry 3950 (class 0 OID 0)
-- Dependencies: 3033
-- Name: TRIGGER "TG_Asiendo_ActualizaSaldo" ON asiento; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_Asiendo_ActualizaSaldo" ON asiento IS 'Trigger que actualiza el saldo del asiento';


--
-- TOC entry 3009 (class 2620 OID 27181)
-- Dependencies: 335 171 3293
-- Name: TG_AsientoD_ActualizaDebeHaber_Asiento; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_AsientoD_ActualizaDebeHaber_Asiento" AFTER INSERT OR DELETE OR UPDATE ON asientod FOR EACH ROW EXECUTE PROCEDURE "tf_AsiendoD_ActualizaDebeHaber_Asiento"();


--
-- TOC entry 3951 (class 0 OID 0)
-- Dependencies: 3009
-- Name: TRIGGER "TG_AsientoD_ActualizaDebeHaber_Asiento" ON asientod; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_AsientoD_ActualizaDebeHaber_Asiento" ON asientod IS 'Trigger que actualiza el debe y haber de la tabla de asiento';


--
-- TOC entry 3010 (class 2620 OID 27182)
-- Dependencies: 171 337 3293
-- Name: TG_AsientoD_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_AsientoD_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON asientod FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();


--
-- TOC entry 3952 (class 0 OID 0)
-- Dependencies: 3010
-- Name: TRIGGER "TG_AsientoD_Bitacora" ON asientod; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_AsientoD_Bitacora" ON asientod IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3036 (class 2620 OID 27183)
-- Dependencies: 337 230 3293
-- Name: TG_AsientoM_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_AsientoM_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON asientom FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();


--
-- TOC entry 3953 (class 0 OID 0)
-- Dependencies: 3036
-- Name: TRIGGER "TG_AsientoM_Bitacora" ON asientom; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_AsientoM_Bitacora" ON asientom IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3034 (class 2620 OID 27184)
-- Dependencies: 229 229 328 3293
-- Name: TG_Asiento_Actualiza_Mes_Ano; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_Asiento_Actualiza_Mes_Ano" BEFORE INSERT OR UPDATE OF fecha ON asiento FOR EACH ROW EXECUTE PROCEDURE "tf_Asiento_ActualizaPeriodo"();


--
-- TOC entry 3035 (class 2620 OID 27185)
-- Dependencies: 229 337 3293
-- Name: TG_Asiento_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_Asiento_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON asiento FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();


--
-- TOC entry 3954 (class 0 OID 0)
-- Dependencies: 3035
-- Name: TRIGGER "TG_Asiento_Bitacora" ON asiento; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_Asiento_Bitacora" ON asiento IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3011 (class 2620 OID 27186)
-- Dependencies: 174 337 3293
-- Name: TG_BaCuenta_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_BaCuenta_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON bacuenta FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE bacuenta DISABLE TRIGGER "TG_BaCuenta_Bitacora";


--
-- TOC entry 3955 (class 0 OID 0)
-- Dependencies: 3011
-- Name: TRIGGER "TG_BaCuenta_Bitacora" ON bacuenta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_BaCuenta_Bitacora" ON bacuenta IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3012 (class 2620 OID 27187)
-- Dependencies: 337 176 3293
-- Name: TG_Bancos_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_Bancos_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON bancos FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE bancos DISABLE TRIGGER "TG_Bancos_Bitacora";


--
-- TOC entry 3956 (class 0 OID 0)
-- Dependencies: 3012
-- Name: TRIGGER "TG_Bancos_Bitacora" ON bancos; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_Bancos_Bitacora" ON bancos IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3015 (class 2620 OID 27188)
-- Dependencies: 337 182 3293
-- Name: TG_Cargos_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_Cargos_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON cargos FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE cargos DISABLE TRIGGER "TG_Cargos_Bitacora";


--
-- TOC entry 3957 (class 0 OID 0)
-- Dependencies: 3015
-- Name: TRIGGER "TG_Cargos_Bitacora" ON cargos; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_Cargos_Bitacora" ON cargos IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3018 (class 2620 OID 27189)
-- Dependencies: 337 192 3293
-- Name: TG_ConUsu_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_ConUsu_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON conusu FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE conusu DISABLE TRIGGER "TG_ConUsu_Bitacora";


--
-- TOC entry 3958 (class 0 OID 0)
-- Dependencies: 3018
-- Name: TRIGGER "TG_ConUsu_Bitacora" ON conusu; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_ConUsu_Bitacora" ON conusu IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3038 (class 2620 OID 27191)
-- Dependencies: 337 250 3293
-- Name: TG_CtaConta_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_CtaConta_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON ctaconta FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();


--
-- TOC entry 3959 (class 0 OID 0)
-- Dependencies: 3038
-- Name: TRIGGER "TG_CtaConta_Bitacora" ON ctaconta; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_CtaConta_Bitacora" ON ctaconta IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3020 (class 2620 OID 27192)
-- Dependencies: 337 198 3293
-- Name: TG_Departam_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_Departam_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON departam FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE departam DISABLE TRIGGER "TG_Departam_Bitacora";


--
-- TOC entry 3960 (class 0 OID 0)
-- Dependencies: 3020
-- Name: TRIGGER "TG_Departam_Bitacora" ON departam; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_Departam_Bitacora" ON departam IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3022 (class 2620 OID 27193)
-- Dependencies: 206 337 3293
-- Name: TG_PerUsuD_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_PerUsuD_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON perusud FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();


--
-- TOC entry 3961 (class 0 OID 0)
-- Dependencies: 3022
-- Name: TRIGGER "TG_PerUsuD_Bitacora" ON perusud; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_PerUsuD_Bitacora" ON perusud IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3023 (class 2620 OID 27194)
-- Dependencies: 337 208 3293
-- Name: TG_PerUsu_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_PerUsu_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON perusu FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();


--
-- TOC entry 3962 (class 0 OID 0)
-- Dependencies: 3023
-- Name: TRIGGER "TG_PerUsu_Bitacora" ON perusu; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_PerUsu_Bitacora" ON perusu IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3024 (class 2620 OID 27195)
-- Dependencies: 210 337 3293
-- Name: TG_PregSecr_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_PregSecr_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON pregsecr FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE pregsecr DISABLE TRIGGER "TG_PregSecr_Bitacora";


--
-- TOC entry 3963 (class 0 OID 0)
-- Dependencies: 3024
-- Name: TRIGGER "TG_PregSecr_Bitacora" ON pregsecr; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_PregSecr_Bitacora" ON pregsecr IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3026 (class 2620 OID 27196)
-- Dependencies: 337 214 3293
-- Name: TG_TDeclara_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_TDeclara_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON tdeclara FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE tdeclara DISABLE TRIGGER "TG_TDeclara_Bitacora";


--
-- TOC entry 3964 (class 0 OID 0)
-- Dependencies: 3026
-- Name: TRIGGER "TG_TDeclara_Bitacora" ON tdeclara; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_TDeclara_Bitacora" ON tdeclara IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3029 (class 2620 OID 27197)
-- Dependencies: 337 220 3293
-- Name: TG_UndTrib_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_UndTrib_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON undtrib FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE undtrib DISABLE TRIGGER "TG_UndTrib_Bitacora";


--
-- TOC entry 3965 (class 0 OID 0)
-- Dependencies: 3029
-- Name: TRIGGER "TG_UndTrib_Bitacora" ON undtrib; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_UndTrib_Bitacora" ON undtrib IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3030 (class 2620 OID 27199)
-- Dependencies: 224 224 224 224 224 224 224 224 224 224 224 224 224 337 3293
-- Name: TG_UsFonpro_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "TG_UsFonpro_Bitacora" AFTER INSERT OR DELETE OR UPDATE OF id, login, password, nombre, email, telefofc, extension, departamid, cargoid, inactivo, pregsecrid, respuesta ON usfonpro FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE usfonpro DISABLE TRIGGER "TG_UsFonpro_Bitacora";


--
-- TOC entry 3966 (class 0 OID 0)
-- Dependencies: 3030
-- Name: TRIGGER "TG_UsFonpro_Bitacora" ON usfonpro; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "TG_UsFonpro_Bitacora" ON usfonpro IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3032 (class 2620 OID 27200)
-- Dependencies: 227 339 3293
-- Name: ejecuta_crea_correlativo_actar; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER ejecuta_crea_correlativo_actar AFTER INSERT ON actas_reparo FOR EACH ROW EXECUTE PROCEDURE crea_correlativo_actas();


--
-- TOC entry 3037 (class 2620 OID 27201)
-- Dependencies: 234 339 3293
-- Name: ejecuta_crea_correlativo_actas; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER ejecuta_crea_correlativo_actas AFTER INSERT ON asignacion_fiscales FOR EACH ROW EXECUTE PROCEDURE crea_correlativo_actas();


--
-- TOC entry 3039 (class 2620 OID 27790)
-- Dependencies: 251 339 3293
-- Name: ejecuta_crea_correlativo_ndeclara; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER ejecuta_crea_correlativo_ndeclara AFTER INSERT ON declara FOR EACH ROW EXECUTE PROCEDURE crea_correlativo_actas();


--
-- TOC entry 3031 (class 2620 OID 27202)
-- Dependencies: 226 337 3293
-- Name: tg_Accionis_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_Accionis_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON accionis FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE accionis DISABLE TRIGGER "tg_Accionis_Bitacora";


--
-- TOC entry 3967 (class 0 OID 0)
-- Dependencies: 3031
-- Name: TRIGGER "tg_Accionis_Bitacora" ON accionis; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_Accionis_Bitacora" ON accionis IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3007 (class 2620 OID 27203)
-- Dependencies: 337 167 3293
-- Name: tg_ActiEcon_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_ActiEcon_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON actiecon FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE actiecon DISABLE TRIGGER "tg_ActiEcon_Bitacora";


--
-- TOC entry 3968 (class 0 OID 0)
-- Dependencies: 3007
-- Name: TRIGGER "tg_ActiEcon_Bitacora" ON actiecon; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_ActiEcon_Bitacora" ON actiecon IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3008 (class 2620 OID 27204)
-- Dependencies: 169 337 3293
-- Name: tg_AlicImp_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_AlicImp_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON alicimp FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE alicimp DISABLE TRIGGER "tg_AlicImp_Bitacora";


--
-- TOC entry 3969 (class 0 OID 0)
-- Dependencies: 3008
-- Name: TRIGGER "tg_AlicImp_Bitacora" ON alicimp; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_AlicImp_Bitacora" ON alicimp IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3013 (class 2620 OID 27205)
-- Dependencies: 337 178 3293
-- Name: tg_CalPagoD_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_CalPagoD_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON calpagod FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE calpagod DISABLE TRIGGER "tg_CalPagoD_Bitacora";


--
-- TOC entry 3970 (class 0 OID 0)
-- Dependencies: 3013
-- Name: TRIGGER "tg_CalPagoD_Bitacora" ON calpagod; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_CalPagoD_Bitacora" ON calpagod IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3014 (class 2620 OID 27207)
-- Dependencies: 180 337 3293
-- Name: tg_CalPago_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_CalPago_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON calpago FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE calpago DISABLE TRIGGER "tg_CalPago_Bitacora";


--
-- TOC entry 3971 (class 0 OID 0)
-- Dependencies: 3014
-- Name: TRIGGER "tg_CalPago_Bitacora" ON calpago; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_CalPago_Bitacora" ON calpago IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3016 (class 2620 OID 27208)
-- Dependencies: 184 337 3293
-- Name: tg_Ciudades_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_Ciudades_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON ciudades FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE ciudades DISABLE TRIGGER "tg_Ciudades_Bitacora";


--
-- TOC entry 3972 (class 0 OID 0)
-- Dependencies: 3016
-- Name: TRIGGER "tg_Ciudades_Bitacora" ON ciudades; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_Ciudades_Bitacora" ON ciudades IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3017 (class 2620 OID 27210)
-- Dependencies: 188 337 3293
-- Name: tg_ConUsuTi_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_ConUsuTi_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON conusuti FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE conusuti DISABLE TRIGGER "tg_ConUsuTi_Bitacora";


--
-- TOC entry 3973 (class 0 OID 0)
-- Dependencies: 3017
-- Name: TRIGGER "tg_ConUsuTi_Bitacora" ON conusuti; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_ConUsuTi_Bitacora" ON conusuti IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3019 (class 2620 OID 27211)
-- Dependencies: 337 194 3293
-- Name: tg_Contribu_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_Contribu_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON contribu FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE contribu DISABLE TRIGGER "tg_Contribu_Bitacora";


--
-- TOC entry 3974 (class 0 OID 0)
-- Dependencies: 3019
-- Name: TRIGGER "tg_Contribu_Bitacora" ON contribu; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_Contribu_Bitacora" ON contribu IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3021 (class 2620 OID 27212)
-- Dependencies: 337 204 3293
-- Name: tg_Estados_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_Estados_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON estados FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE estados DISABLE TRIGGER "tg_Estados_Bitacora";


--
-- TOC entry 3975 (class 0 OID 0)
-- Dependencies: 3021
-- Name: TRIGGER "tg_Estados_Bitacora" ON estados; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_Estados_Bitacora" ON estados IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3025 (class 2620 OID 27213)
-- Dependencies: 337 212 3293
-- Name: tg_RepLegal_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_RepLegal_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON replegal FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE replegal DISABLE TRIGGER "tg_RepLegal_Bitacora";


--
-- TOC entry 3976 (class 0 OID 0)
-- Dependencies: 3025
-- Name: TRIGGER "tg_RepLegal_Bitacora" ON replegal; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_RepLegal_Bitacora" ON replegal IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3027 (class 2620 OID 27214)
-- Dependencies: 216 337 3293
-- Name: tg_TiPeGrav_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_TiPeGrav_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON tipegrav FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE tipegrav DISABLE TRIGGER "tg_TiPeGrav_Bitacora";


--
-- TOC entry 3977 (class 0 OID 0)
-- Dependencies: 3027
-- Name: TRIGGER "tg_TiPeGrav_Bitacora" ON tipegrav; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_TiPeGrav_Bitacora" ON tipegrav IS 'Trigger para insertar datos en la tabla de bitacoras';


--
-- TOC entry 3028 (class 2620 OID 27215)
-- Dependencies: 337 218 3293
-- Name: tg_TipoCont_Bitacora; Type: TRIGGER; Schema: datos; Owner: postgres
--

CREATE TRIGGER "tg_TipoCont_Bitacora" AFTER INSERT OR DELETE OR UPDATE ON tipocont FOR EACH ROW EXECUTE PROCEDURE "tf_Bitacora"();

ALTER TABLE tipocont DISABLE TRIGGER "tg_TipoCont_Bitacora";


--
-- TOC entry 3978 (class 0 OID 0)
-- Dependencies: 3028
-- Name: TRIGGER "tg_TipoCont_Bitacora" ON tipocont; Type: COMMENT; Schema: datos; Owner: postgres
--

COMMENT ON TRIGGER "tg_TipoCont_Bitacora" ON tipocont IS 'Trigger para insertar datos en la tabla de bitacoras';


SET search_path = seg, pg_catalog;

--
-- TOC entry 3040 (class 2620 OID 27216)
-- Dependencies: 338 294 3293
-- Name: ejecutaverificamodulo; Type: TRIGGER; Schema: seg; Owner: postgres
--

CREATE TRIGGER ejecutaverificamodulo BEFORE INSERT ON tbl_permiso_trampa FOR EACH ROW EXECUTE PROCEDURE verificaperfil();


SET search_path = datos, pg_catalog;

--
-- TOC entry 2974 (class 2606 OID 27217)
-- Dependencies: 258 253 2805 3293
-- Name: FK-DetalleInteres-Interes_ID-InteresID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY detalle_interes
    ADD CONSTRAINT "FK-DetalleInteres-Interes_ID-InteresID" FOREIGN KEY (intereses_id) REFERENCES pre_aprobacion.intereses(id);


--
-- TOC entry 2945 (class 2606 OID 27222)
-- Dependencies: 226 192 2604 3293
-- Name: FK_Accionis_IDContribu; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY accionis
    ADD CONSTRAINT "FK_Accionis_IDContribu" FOREIGN KEY (contribuid) REFERENCES conusu(id) MATCH FULL;


--
-- TOC entry 2946 (class 2606 OID 27227)
-- Dependencies: 224 2730 226 3293
-- Name: FK_Accionis_UsFonpro_UsuarioID_ID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY accionis
    ADD CONSTRAINT "FK_Accionis_UsFonpro_UsuarioID_ID" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2899 (class 2606 OID 27232)
-- Dependencies: 224 2730 167 3293
-- Name: FK_ActiEcon_USFonpro_IDUsuario_IDUsFornpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY actiecon
    ADD CONSTRAINT "FK_ActiEcon_USFonpro_IDUsuario_IDUsFornpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2900 (class 2606 OID 27237)
-- Dependencies: 169 218 2707 3293
-- Name: FK_AlicImp_TipoCont_IDTipoCont; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY alicimp
    ADD CONSTRAINT "FK_AlicImp_TipoCont_IDTipoCont" FOREIGN KEY (tipocontid) REFERENCES tipocont(id) MATCH FULL;


--
-- TOC entry 2901 (class 2606 OID 27242)
-- Dependencies: 224 2730 169 3293
-- Name: FK_AlicImp_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY alicimp
    ADD CONSTRAINT "FK_AlicImp_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2902 (class 2606 OID 27247)
-- Dependencies: 229 2752 171 3293
-- Name: FK_AsientoD_Asiento_IDAsiento; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asientod
    ADD CONSTRAINT "FK_AsientoD_Asiento_IDAsiento" FOREIGN KEY (asientoid) REFERENCES asiento(id) MATCH FULL;


--
-- TOC entry 2903 (class 2606 OID 27252)
-- Dependencies: 2787 250 171 3293
-- Name: FK_AsientoD_CtaConta_Cuenta; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asientod
    ADD CONSTRAINT "FK_AsientoD_CtaConta_Cuenta" FOREIGN KEY (cuenta) REFERENCES ctaconta(cuenta) MATCH FULL;


--
-- TOC entry 2904 (class 2606 OID 27257)
-- Dependencies: 2730 171 224 3293
-- Name: FK_AsientoD_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asientod
    ADD CONSTRAINT "FK_AsientoD_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2951 (class 2606 OID 27262)
-- Dependencies: 230 2757 232 3293
-- Name: FK_AsientoMD_AsientoM_AsientoMID_ID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asientomd
    ADD CONSTRAINT "FK_AsientoMD_AsientoM_AsientoMID_ID" FOREIGN KEY (asientomid) REFERENCES asientom(id) MATCH FULL;


--
-- TOC entry 2952 (class 2606 OID 27267)
-- Dependencies: 232 250 2787 3293
-- Name: FK_AsientoMD_CtaConta_Cuenta; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asientomd
    ADD CONSTRAINT "FK_AsientoMD_CtaConta_Cuenta" FOREIGN KEY (cuenta) REFERENCES ctaconta(cuenta) MATCH FULL;


--
-- TOC entry 2953 (class 2606 OID 27272)
-- Dependencies: 232 224 2730 3293
-- Name: FK_AsientoMD_UsFonpro_UsuarioID_ID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asientomd
    ADD CONSTRAINT "FK_AsientoMD_UsFonpro_UsuarioID_ID" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2950 (class 2606 OID 27277)
-- Dependencies: 230 224 2730 3293
-- Name: FK_AsientoM_UsFonpro_UsuarioID_ID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asientom
    ADD CONSTRAINT "FK_AsientoM_UsFonpro_UsuarioID_ID" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2948 (class 2606 OID 27282)
-- Dependencies: 229 224 2730 3293
-- Name: FK_Asiento_UsFonpro_IDUsCierre_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asiento
    ADD CONSTRAINT "FK_Asiento_UsFonpro_IDUsCierre_IDUsFonpro" FOREIGN KEY (uscierreid) REFERENCES usfonpro(id);


--
-- TOC entry 2949 (class 2606 OID 27287)
-- Dependencies: 229 224 2730 3293
-- Name: FK_Asiento_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asiento
    ADD CONSTRAINT "FK_Asiento_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2905 (class 2606 OID 27292)
-- Dependencies: 174 176 2560 3293
-- Name: FK_BaCuenta_Bancos_IDBanco; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY bacuenta
    ADD CONSTRAINT "FK_BaCuenta_Bancos_IDBanco" FOREIGN KEY (bancoid) REFERENCES bancos(id) MATCH FULL;


--
-- TOC entry 2906 (class 2606 OID 27297)
-- Dependencies: 174 224 2730 3293
-- Name: FK_BaCuenta_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY bacuenta
    ADD CONSTRAINT "FK_BaCuenta_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2907 (class 2606 OID 27302)
-- Dependencies: 176 224 2730 3293
-- Name: FK_Bancos_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY bancos
    ADD CONSTRAINT "FK_Bancos_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2908 (class 2606 OID 27307)
-- Dependencies: 178 180 2573 3293
-- Name: FK_CalPagoD_CalPago_IDCalPago; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY calpagod
    ADD CONSTRAINT "FK_CalPagoD_CalPago_IDCalPago" FOREIGN KEY (calpagoid) REFERENCES calpago(id) MATCH FULL;


--
-- TOC entry 2909 (class 2606 OID 27312)
-- Dependencies: 178 224 2730 3293
-- Name: FK_CalPagoD_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY calpagod
    ADD CONSTRAINT "FK_CalPagoD_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2910 (class 2606 OID 27317)
-- Dependencies: 180 224 2730 3293
-- Name: FK_CalPago_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY calpago
    ADD CONSTRAINT "FK_CalPago_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2911 (class 2606 OID 27322)
-- Dependencies: 180 216 2701 3293
-- Name: FK_CalPagos_TiPeGrav_IDTiPeGrav; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY calpago
    ADD CONSTRAINT "FK_CalPagos_TiPeGrav_IDTiPeGrav" FOREIGN KEY (tipegravid) REFERENCES tipegrav(id) MATCH FULL;


--
-- TOC entry 2912 (class 2606 OID 27327)
-- Dependencies: 182 224 2730 3293
-- Name: FK_Cargos_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY cargos
    ADD CONSTRAINT "FK_Cargos_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2913 (class 2606 OID 27332)
-- Dependencies: 184 204 2663 3293
-- Name: FK_Ciudades_Estados_IDEstado; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY ciudades
    ADD CONSTRAINT "FK_Ciudades_Estados_IDEstado" FOREIGN KEY (estadoid) REFERENCES estados(id) MATCH FULL;


--
-- TOC entry 2914 (class 2606 OID 27337)
-- Dependencies: 184 224 2730 3293
-- Name: FK_Ciudades_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY ciudades
    ADD CONSTRAINT "FK_Ciudades_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2915 (class 2606 OID 27342)
-- Dependencies: 186 192 2604 3293
-- Name: FK_ConUsuCo_ConUsu_IDConUsu; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusuco
    ADD CONSTRAINT "FK_ConUsuCo_ConUsu_IDConUsu" FOREIGN KEY (conusuid) REFERENCES conusu(id) MATCH FULL;


--
-- TOC entry 2916 (class 2606 OID 27347)
-- Dependencies: 186 194 2617 3293
-- Name: FK_ConUsuCo_Contribu_IDContribu; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusuco
    ADD CONSTRAINT "FK_ConUsuCo_Contribu_IDContribu" FOREIGN KEY (contribuid) REFERENCES contribu(id) MATCH FULL;


--
-- TOC entry 2917 (class 2606 OID 27352)
-- Dependencies: 188 224 2730 3293
-- Name: FK_ConUsuTi_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusuti
    ADD CONSTRAINT "FK_ConUsuTi_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2918 (class 2606 OID 27357)
-- Dependencies: 190 192 2604 3293
-- Name: FK_ConUsuTo_ConUsu_IDConUsu; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusuto
    ADD CONSTRAINT "FK_ConUsuTo_ConUsu_IDConUsu" FOREIGN KEY (conusuid) REFERENCES conusu(id) MATCH FULL;


--
-- TOC entry 2919 (class 2606 OID 27362)
-- Dependencies: 192 188 2593 3293
-- Name: FK_ConUsu_ConUsuTi_IDConUsuTi; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusu
    ADD CONSTRAINT "FK_ConUsu_ConUsuTi_IDConUsuTi" FOREIGN KEY (conusutiid) REFERENCES conusuti(id) MATCH FULL;


--
-- TOC entry 2920 (class 2606 OID 27367)
-- Dependencies: 192 210 2680 3293
-- Name: FK_ConUsu_PregSecr_IDPregSecr; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusu
    ADD CONSTRAINT "FK_ConUsu_PregSecr_IDPregSecr" FOREIGN KEY (pregsecrid) REFERENCES pregsecr(id) MATCH FULL;


--
-- TOC entry 2958 (class 2606 OID 27372)
-- Dependencies: 240 194 2617 3293
-- Name: FK_ContribuTi_Contribu_ContribuID_ID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY contributi
    ADD CONSTRAINT "FK_ContribuTi_Contribu_ContribuID_ID" FOREIGN KEY (contribuid) REFERENCES contribu(id) MATCH FULL;


--
-- TOC entry 2959 (class 2606 OID 27377)
-- Dependencies: 240 218 2707 3293
-- Name: FK_ContribuTi_TipoCont_TipoContID_ID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY contributi
    ADD CONSTRAINT "FK_ContribuTi_TipoCont_TipoContID_ID" FOREIGN KEY (tipocontid) REFERENCES tipocont(id) MATCH FULL;


--
-- TOC entry 2921 (class 2606 OID 27382)
-- Dependencies: 194 167 2538 3293
-- Name: FK_Contribu_ActiEcon_IDActiEcon; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY contribu
    ADD CONSTRAINT "FK_Contribu_ActiEcon_IDActiEcon" FOREIGN KEY (actieconid) REFERENCES actiecon(id) MATCH FULL;


--
-- TOC entry 2922 (class 2606 OID 27387)
-- Dependencies: 194 184 2584 3293
-- Name: FK_Contribu_Ciudades_IDCiudad; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY contribu
    ADD CONSTRAINT "FK_Contribu_Ciudades_IDCiudad" FOREIGN KEY (ciudadid) REFERENCES ciudades(id) MATCH FULL;


--
-- TOC entry 2923 (class 2606 OID 27392)
-- Dependencies: 194 192 2604 3293
-- Name: FK_Contribu_ConUsu_UsuarioID_ID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY contribu
    ADD CONSTRAINT "FK_Contribu_ConUsu_UsuarioID_ID" FOREIGN KEY (usuarioid) REFERENCES conusu(id) MATCH FULL;


--
-- TOC entry 2924 (class 2606 OID 27397)
-- Dependencies: 194 204 2663 3293
-- Name: FK_Contribu_Estados_IDEstado; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY contribu
    ADD CONSTRAINT "FK_Contribu_Estados_IDEstado" FOREIGN KEY (estadoid) REFERENCES estados(id) MATCH FULL;


--
-- TOC entry 2963 (class 2606 OID 27402)
-- Dependencies: 250 224 2730 3293
-- Name: FK_CtaConta_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY ctaconta
    ADD CONSTRAINT "FK_CtaConta_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2964 (class 2606 OID 27760)
-- Dependencies: 251 229 2752 3293
-- Name: FK_Decla_Asiento_IDAsiento; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT "FK_Decla_Asiento_IDAsiento" FOREIGN KEY (asientoid) REFERENCES asiento(id);


--
-- TOC entry 2965 (class 2606 OID 27765)
-- Dependencies: 251 178 2564 3293
-- Name: FK_Decla_Calpagod_id; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT "FK_Decla_Calpagod_id" FOREIGN KEY (calpagodid) REFERENCES calpagod(id);


--
-- TOC entry 2966 (class 2606 OID 27770)
-- Dependencies: 251 251 2803 3293
-- Name: FK_Decla_PlaSustID_ID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT "FK_Decla_PlaSustID_ID" FOREIGN KEY (plasustid) REFERENCES declara(id);


--
-- TOC entry 2967 (class 2606 OID 27775)
-- Dependencies: 251 214 2696 3293
-- Name: FK_Decla_TDeclara_IDTDeclara; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT "FK_Decla_TDeclara_IDTDeclara" FOREIGN KEY (tdeclaraid) REFERENCES tdeclara(id) MATCH FULL;


--
-- TOC entry 2968 (class 2606 OID 27780)
-- Dependencies: 251 218 2707 3293
-- Name: FK_Decla_tipocontribuid; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT "FK_Decla_tipocontribuid" FOREIGN KEY (tipocontribuid) REFERENCES tipocont(id);


--
-- TOC entry 2978 (class 2606 OID 27432)
-- Dependencies: 264 224 2730 3293
-- Name: FK_Document_UsFonpro_UsFonproID_ID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY document
    ADD CONSTRAINT "FK_Document_UsFonpro_UsFonproID_ID" FOREIGN KEY (usfonproid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2926 (class 2606 OID 27437)
-- Dependencies: 200 202 2658 3293
-- Name: FK_EntidadD_Entidad_IDEntidad; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY entidadd
    ADD CONSTRAINT "FK_EntidadD_Entidad_IDEntidad" FOREIGN KEY (entidadid) REFERENCES entidad(id) MATCH FULL;


--
-- TOC entry 2927 (class 2606 OID 27442)
-- Dependencies: 204 224 2730 3293
-- Name: FK_Estados_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY estados
    ADD CONSTRAINT "FK_Estados_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2928 (class 2606 OID 27447)
-- Dependencies: 206 200 2650 3293
-- Name: FK_PerUsuD_EndidadD_IDEntidadD; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY perusud
    ADD CONSTRAINT "FK_PerUsuD_EndidadD_IDEntidadD" FOREIGN KEY (entidaddid) REFERENCES entidadd(id) MATCH FULL;


--
-- TOC entry 2929 (class 2606 OID 27452)
-- Dependencies: 206 208 2675 3293
-- Name: FK_PerUsuD_PerUsu_IDPerUsu; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY perusud
    ADD CONSTRAINT "FK_PerUsuD_PerUsu_IDPerUsu" FOREIGN KEY (perusuid) REFERENCES perusu(id) MATCH FULL;


--
-- TOC entry 2930 (class 2606 OID 27457)
-- Dependencies: 206 224 2730 3293
-- Name: FK_PerUsuD_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY perusud
    ADD CONSTRAINT "FK_PerUsuD_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2931 (class 2606 OID 27462)
-- Dependencies: 208 224 2730 3293
-- Name: FK_PerUsu_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY perusu
    ADD CONSTRAINT "FK_PerUsu_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2932 (class 2606 OID 27467)
-- Dependencies: 2730 224 210 3293
-- Name: FK_PregSecr_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY pregsecr
    ADD CONSTRAINT "FK_PregSecr_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2933 (class 2606 OID 27472)
-- Dependencies: 184 212 2584 3293
-- Name: FK_RepLegal_IDCiudad; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY replegal
    ADD CONSTRAINT "FK_RepLegal_IDCiudad" FOREIGN KEY (ciudadid) REFERENCES ciudades(id) MATCH FULL;


--
-- TOC entry 2935 (class 2606 OID 27477)
-- Dependencies: 214 224 2730 3293
-- Name: FK_TDeclara_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tdeclara
    ADD CONSTRAINT "FK_TDeclara_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2936 (class 2606 OID 27482)
-- Dependencies: 216 224 2730 3293
-- Name: FK_TiPeGrav_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tipegrav
    ADD CONSTRAINT "FK_TiPeGrav_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2937 (class 2606 OID 27487)
-- Dependencies: 218 216 2701 3293
-- Name: FK_TipoCont_TiPeGrav_IDTiPeGrav; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tipocont
    ADD CONSTRAINT "FK_TipoCont_TiPeGrav_IDTiPeGrav" FOREIGN KEY (tipegravid) REFERENCES tipegrav(id) MATCH FULL;


--
-- TOC entry 2938 (class 2606 OID 27492)
-- Dependencies: 218 224 2730 3293
-- Name: FK_TipoCont_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tipocont
    ADD CONSTRAINT "FK_TipoCont_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2987 (class 2606 OID 27497)
-- Dependencies: 272 167 2538 3293
-- Name: FK_TmpContri_ActiEcon_IDActiEcon; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tmpcontri
    ADD CONSTRAINT "FK_TmpContri_ActiEcon_IDActiEcon" FOREIGN KEY (actieconid) REFERENCES actiecon(id) MATCH FULL;


--
-- TOC entry 2988 (class 2606 OID 27502)
-- Dependencies: 272 184 2584 3293
-- Name: FK_TmpContri_Ciudades_IDCiudad; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tmpcontri
    ADD CONSTRAINT "FK_TmpContri_Ciudades_IDCiudad" FOREIGN KEY (ciudadid) REFERENCES ciudades(id) MATCH FULL;


--
-- TOC entry 2989 (class 2606 OID 27507)
-- Dependencies: 272 194 2617 3293
-- Name: FK_TmpContri_Contribu_IDContribu; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tmpcontri
    ADD CONSTRAINT "FK_TmpContri_Contribu_IDContribu" FOREIGN KEY (id) REFERENCES contribu(id) MATCH FULL;


--
-- TOC entry 2990 (class 2606 OID 27512)
-- Dependencies: 272 204 2663 3293
-- Name: FK_TmpContri_Estados_IDEstado; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tmpcontri
    ADD CONSTRAINT "FK_TmpContri_Estados_IDEstado" FOREIGN KEY (estadoid) REFERENCES estados(id) MATCH FULL;


--
-- TOC entry 2991 (class 2606 OID 27517)
-- Dependencies: 272 218 2707 3293
-- Name: FK_TmpContri_TipoCont_IDTipoCont; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tmpcontri
    ADD CONSTRAINT "FK_TmpContri_TipoCont_IDTipoCont" FOREIGN KEY (tipocontid) REFERENCES tipocont(id) MATCH FULL;


--
-- TOC entry 2992 (class 2606 OID 27522)
-- Dependencies: 273 184 2584 3293
-- Name: FK_TmpReLegal_IDCiudad; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tmprelegal
    ADD CONSTRAINT "FK_TmpReLegal_IDCiudad" FOREIGN KEY (ciudadid) REFERENCES ciudades(id) MATCH FULL;


--
-- TOC entry 2993 (class 2606 OID 27527)
-- Dependencies: 273 272 2852 3293
-- Name: FK_TmpReLegal_IDContribu; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tmprelegal
    ADD CONSTRAINT "FK_TmpReLegal_IDContribu" FOREIGN KEY (contribuid) REFERENCES tmpcontri(id) MATCH FULL;


--
-- TOC entry 2994 (class 2606 OID 27532)
-- Dependencies: 273 204 2663 3293
-- Name: FK_TmpReLegal_IDEstado; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tmprelegal
    ADD CONSTRAINT "FK_TmpReLegal_IDEstado" FOREIGN KEY (estadoid) REFERENCES estados(id) MATCH FULL;


--
-- TOC entry 2995 (class 2606 OID 27537)
-- Dependencies: 273 212 2691 3293
-- Name: FK_TmpReLegal_IDRepLegal; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tmprelegal
    ADD CONSTRAINT "FK_TmpReLegal_IDRepLegal" FOREIGN KEY (id) REFERENCES replegal(id) MATCH FULL;


--
-- TOC entry 2939 (class 2606 OID 27542)
-- Dependencies: 220 224 2730 3293
-- Name: FK_UndTrib_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY undtrib
    ADD CONSTRAINT "FK_UndTrib_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2941 (class 2606 OID 27547)
-- Dependencies: 224 210 2680 3293
-- Name: FK_UsFonPro_PregSecr_IDPregSecr; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY usfonpro
    ADD CONSTRAINT "FK_UsFonPro_PregSecr_IDPregSecr" FOREIGN KEY (pregsecrid) REFERENCES pregsecr(id) MATCH FULL;


--
-- TOC entry 2940 (class 2606 OID 27552)
-- Dependencies: 222 224 2730 3293
-- Name: FK_UsFonpTo_UsFonpro_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY usfonpto
    ADD CONSTRAINT "FK_UsFonpTo_UsFonpro_IDUsFonpro" FOREIGN KEY (usfonproid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2942 (class 2606 OID 27557)
-- Dependencies: 182 224 2578 3293
-- Name: FK_UsFonpro_Cargos_IDCargo; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY usfonpro
    ADD CONSTRAINT "FK_UsFonpro_Cargos_IDCargo" FOREIGN KEY (cargoid) REFERENCES cargos(id) MATCH FULL;


--
-- TOC entry 2943 (class 2606 OID 27562)
-- Dependencies: 224 198 2637 3293
-- Name: FK_UsFonpro_Departam_IDDepartam; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY usfonpro
    ADD CONSTRAINT "FK_UsFonpro_Departam_IDDepartam" FOREIGN KEY (departamid) REFERENCES departam(id) MATCH FULL;


--
-- TOC entry 2944 (class 2606 OID 27567)
-- Dependencies: 224 208 2675 3293
-- Name: FK_UsFonpro_PerUsu_IDPerUsu; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY usfonpro
    ADD CONSTRAINT "FK_UsFonpro_PerUsu_IDPerUsu" FOREIGN KEY (perusuid) REFERENCES perusu(id);


--
-- TOC entry 2957 (class 2606 OID 27572)
-- Dependencies: 236 192 2604 3293
-- Name: FK_conusu_id; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY con_img_doc
    ADD CONSTRAINT "FK_conusu_id" FOREIGN KEY (conusuid) REFERENCES conusu(id) MATCH FULL;


--
-- TOC entry 2981 (class 2606 OID 27577)
-- Dependencies: 270 229 2752 3293
-- Name: FK_reparos_Asiento_IDAsiento; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY reparos
    ADD CONSTRAINT "FK_reparos_Asiento_IDAsiento" FOREIGN KEY (asientoid) REFERENCES asiento(id);


--
-- TOC entry 2982 (class 2606 OID 27582)
-- Dependencies: 270 214 2696 3293
-- Name: FK_reparos_TDeclara_IDTDeclara; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY reparos
    ADD CONSTRAINT "FK_reparos_TDeclara_IDTDeclara" FOREIGN KEY (tdeclaraid) REFERENCES tdeclara(id) MATCH FULL;


--
-- TOC entry 2983 (class 2606 OID 27587)
-- Dependencies: 270 224 2730 3293
-- Name: FK_reparos_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY reparos
    ADD CONSTRAINT "FK_reparos_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id);


--
-- TOC entry 2984 (class 2606 OID 27592)
-- Dependencies: 270 218 2707 3293
-- Name: FK_reparos_tipocontribuid; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY reparos
    ADD CONSTRAINT "FK_reparos_tipocontribuid" FOREIGN KEY (tipocontribuid) REFERENCES tipocont(id);


--
-- TOC entry 2986 (class 2606 OID 27597)
-- Dependencies: 271 272 2852 3293
-- Name: FK_tmpAccioni_ContribuID; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY tmpaccioni
    ADD CONSTRAINT "FK_tmpAccioni_ContribuID" FOREIGN KEY (contribuid) REFERENCES tmpcontri(id) MATCH FULL;


--
-- TOC entry 2925 (class 2606 OID 27602)
-- Dependencies: 198 224 2730 3293
-- Name: FL_Departam_UsFonpro_IDUsuario_IDUsFonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY departam
    ADD CONSTRAINT "FL_Departam_UsFonpro_IDUsuario_IDUsFonpro" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


--
-- TOC entry 2934 (class 2606 OID 27607)
-- Dependencies: 212 192 2604 3293
-- Name: Fk_replegal_conusuid; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY replegal
    ADD CONSTRAINT "Fk_replegal_conusuid" FOREIGN KEY (contribuid) REFERENCES conusu(id);


--
-- TOC entry 2954 (class 2606 OID 27612)
-- Dependencies: 234 192 2604 3293
-- Name: fk-asignacion-contribuyente; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asignacion_fiscales
    ADD CONSTRAINT "fk-asignacion-contribuyente" FOREIGN KEY (conusuid) REFERENCES conusu(id);


--
-- TOC entry 2955 (class 2606 OID 27617)
-- Dependencies: 234 224 2730 3293
-- Name: fk-asignacion-fonprocine; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asignacion_fiscales
    ADD CONSTRAINT "fk-asignacion-fonprocine" FOREIGN KEY (usfonproid) REFERENCES usfonpro(id);


--
-- TOC entry 2956 (class 2606 OID 27622)
-- Dependencies: 234 224 2730 3293
-- Name: fk-asignacion-usuario; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY asignacion_fiscales
    ADD CONSTRAINT "fk-asignacion-usuario" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id);


--
-- TOC entry 2979 (class 2606 OID 27627)
-- Dependencies: 266 224 2730 3293
-- Name: fk-usuario; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY interes_bcv
    ADD CONSTRAINT "fk-usuario" FOREIGN KEY (usuarioid) REFERENCES usfonpro(id);


--
-- TOC entry 2947 (class 2606 OID 27632)
-- Dependencies: 227 224 2730 3293
-- Name: fk_acta_reparo_usuarioid; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY actas_reparo
    ADD CONSTRAINT fk_acta_reparo_usuarioid FOREIGN KEY (usuarioid) REFERENCES usfonpro(id);


--
-- TOC entry 2977 (class 2606 OID 27637)
-- Dependencies: 262 234 2764 3293
-- Name: fk_asignacion_fiscal_id; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY dettalles_fizcalizacion
    ADD CONSTRAINT fk_asignacion_fiscal_id FOREIGN KEY (asignacionfid) REFERENCES asignacion_fiscales(id);


--
-- TOC entry 2960 (class 2606 OID 27642)
-- Dependencies: 242 2604 192 3293
-- Name: fk_conusu_interno_conusu; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusu_interno
    ADD CONSTRAINT fk_conusu_interno_conusu FOREIGN KEY (conusuid) REFERENCES conusu(id);


--
-- TOC entry 2961 (class 2606 OID 27647)
-- Dependencies: 242 224 2730 3293
-- Name: fk_conusu_interno_usfonpro; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusu_interno
    ADD CONSTRAINT fk_conusu_interno_usfonpro FOREIGN KEY (usuarioid) REFERENCES usfonpro(id);


--
-- TOC entry 2962 (class 2606 OID 27652)
-- Dependencies: 244 192 2604 3293
-- Name: fk_conusuid; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY conusu_tipocont
    ADD CONSTRAINT fk_conusuid FOREIGN KEY (conusuid) REFERENCES conusu(id) MATCH FULL;


--
-- TOC entry 2969 (class 2606 OID 27785)
-- Dependencies: 2604 251 192 3293
-- Name: fk_conusuid; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY declara
    ADD CONSTRAINT fk_conusuid FOREIGN KEY (conusuid) REFERENCES conusu(id) MATCH FULL;


--
-- TOC entry 2975 (class 2606 OID 27662)
-- Dependencies: 260 2803 251 3293
-- Name: fk_declaraid_contric_calc_iddeclara; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY detalles_contrib_calc
    ADD CONSTRAINT fk_declaraid_contric_calc_iddeclara FOREIGN KEY (declaraid) REFERENCES declara(id);


--
-- TOC entry 2973 (class 2606 OID 27667)
-- Dependencies: 256 2830 270 3293
-- Name: fk_descargos_reparoid; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY descargos
    ADD CONSTRAINT fk_descargos_reparoid FOREIGN KEY (reparoid) REFERENCES reparos(id);


--
-- TOC entry 2976 (class 2606 OID 27672)
-- Dependencies: 238 2768 260 3293
-- Name: fk_detalles_contric_calid_a_contric_calid; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY detalles_contrib_calc
    ADD CONSTRAINT fk_detalles_contric_calid_a_contric_calid FOREIGN KEY (contrib_calcid) REFERENCES contrib_calc(id);


--
-- TOC entry 2985 (class 2606 OID 27677)
-- Dependencies: 270 192 2604 3293
-- Name: fk_reparos_conusuid; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY reparos
    ADD CONSTRAINT fk_reparos_conusuid FOREIGN KEY (conusuid) REFERENCES conusu(id);


--
-- TOC entry 2980 (class 2606 OID 27682)
-- Dependencies: 268 224 2730 3293
-- Name: fk_usuario; Type: FK CONSTRAINT; Schema: datos; Owner: postgres
--

ALTER TABLE ONLY presidente
    ADD CONSTRAINT fk_usuario FOREIGN KEY (usuarioid) REFERENCES usfonpro(id) MATCH FULL;


SET search_path = pre_aprobacion, pg_catalog;

--
-- TOC entry 2970 (class 2606 OID 27687)
-- Dependencies: 253 254 2807 3293
-- Name: FK-InteresMultaID_MultasID; Type: FK CONSTRAINT; Schema: pre_aprobacion; Owner: postgres
--

ALTER TABLE ONLY intereses
    ADD CONSTRAINT "FK-InteresMultaID_MultasID" FOREIGN KEY (multaid) REFERENCES multas(id);


--
-- TOC entry 2971 (class 2606 OID 27692)
-- Dependencies: 254 224 2730 3293
-- Name: fk-multa-usuario; Type: FK CONSTRAINT; Schema: pre_aprobacion; Owner: postgres
--

ALTER TABLE ONLY multas
    ADD CONSTRAINT "fk-multa-usuario" FOREIGN KEY (usuarioid) REFERENCES datos.usfonpro(id);


--
-- TOC entry 2972 (class 2606 OID 27697)
-- Dependencies: 254 251 2803 3293
-- Name: fk_multa_declaraid; Type: FK CONSTRAINT; Schema: pre_aprobacion; Owner: postgres
--

ALTER TABLE ONLY multas
    ADD CONSTRAINT fk_multa_declaraid FOREIGN KEY (declaraid) REFERENCES datos.declara(id);


SET search_path = seg, pg_catalog;

--
-- TOC entry 2996 (class 2606 OID 27702)
-- Dependencies: 292 290 2875 3293
-- Name: fk_permiso_modulo; Type: FK CONSTRAINT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_permiso
    ADD CONSTRAINT fk_permiso_modulo FOREIGN KEY (id_modulo) REFERENCES tbl_modulo(id_modulo) ON DELETE RESTRICT;


--
-- TOC entry 2997 (class 2606 OID 27707)
-- Dependencies: 292 297 2883 3293
-- Name: fk_permiso_rol; Type: FK CONSTRAINT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_permiso
    ADD CONSTRAINT fk_permiso_rol FOREIGN KEY (id_rol) REFERENCES tbl_rol(id_rol) ON DELETE RESTRICT;


--
-- TOC entry 3000 (class 2606 OID 27712)
-- Dependencies: 296 290 2875 3293
-- Name: fk_permiso_usuario_modulo; Type: FK CONSTRAINT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_permiso_usuario
    ADD CONSTRAINT fk_permiso_usuario_modulo FOREIGN KEY (id_modulo) REFERENCES tbl_modulo(id_modulo);


--
-- TOC entry 3001 (class 2606 OID 27717)
-- Dependencies: 296 224 2730 3293
-- Name: fk_permiso_usuario_usfonproid; Type: FK CONSTRAINT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_permiso_usuario
    ADD CONSTRAINT fk_permiso_usuario_usfonproid FOREIGN KEY (id_usuario) REFERENCES datos.usfonpro(id);


--
-- TOC entry 3002 (class 2606 OID 27722)
-- Dependencies: 2883 297 299 3293
-- Name: fk_rol_usuario_rol; Type: FK CONSTRAINT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_rol_usuario
    ADD CONSTRAINT fk_rol_usuario_rol FOREIGN KEY (id_rol) REFERENCES tbl_rol(id_rol) ON DELETE RESTRICT;


--
-- TOC entry 2998 (class 2606 OID 27727)
-- Dependencies: 294 290 2875 3293
-- Name: fkt_permiso_modulo; Type: FK CONSTRAINT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_permiso_trampa
    ADD CONSTRAINT fkt_permiso_modulo FOREIGN KEY (id_modulo) REFERENCES tbl_modulo(id_modulo) ON DELETE RESTRICT;


--
-- TOC entry 2999 (class 2606 OID 27732)
-- Dependencies: 294 297 2883 3293
-- Name: fkt_permiso_rol; Type: FK CONSTRAINT; Schema: seg; Owner: postgres
--

ALTER TABLE ONLY tbl_permiso_trampa
    ADD CONSTRAINT fkt_permiso_rol FOREIGN KEY (id_rol) REFERENCES tbl_rol(id_rol) ON DELETE RESTRICT;


SET search_path = "segContribu", pg_catalog;

--
-- TOC entry 3003 (class 2606 OID 27737)
-- Dependencies: 307 305 2889 3293
-- Name: fk_permiso_modulo; Type: FK CONSTRAINT; Schema: segContribu; Owner: postgres
--

ALTER TABLE ONLY tbl_permiso_contribu
    ADD CONSTRAINT fk_permiso_modulo FOREIGN KEY (id_modulo) REFERENCES tbl_modulo_contribu(id_modulo) ON DELETE RESTRICT;


--
-- TOC entry 3004 (class 2606 OID 27742)
-- Dependencies: 307 309 2893 3293
-- Name: fk_permiso_rol; Type: FK CONSTRAINT; Schema: segContribu; Owner: postgres
--

ALTER TABLE ONLY tbl_permiso_contribu
    ADD CONSTRAINT fk_permiso_rol FOREIGN KEY (id_rol) REFERENCES tbl_rol_contribu(id_rol) ON DELETE RESTRICT;


--
-- TOC entry 3005 (class 2606 OID 27747)
-- Dependencies: 311 309 2893 3293
-- Name: fk_rol_usuario_rol; Type: FK CONSTRAINT; Schema: segContribu; Owner: postgres
--

ALTER TABLE ONLY tbl_rol_usuario_contribu
    ADD CONSTRAINT fk_rol_usuario_rol FOREIGN KEY (id_rol) REFERENCES tbl_rol_contribu(id_rol) ON DELETE RESTRICT;


--
-- TOC entry 3006 (class 2606 OID 27752)
-- Dependencies: 313 309 2893 3293
-- Name: fk_usuario_rol_rol; Type: FK CONSTRAINT; Schema: segContribu; Owner: postgres
--

ALTER TABLE ONLY tbl_usuario_rol_contribu
    ADD CONSTRAINT fk_usuario_rol_rol FOREIGN KEY (id_rol) REFERENCES tbl_rol_contribu(id_rol) ON DELETE RESTRICT;


--
-- TOC entry 3299 (class 0 OID 0)
-- Dependencies: 9
-- Name: datos; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA datos FROM PUBLIC;
REVOKE ALL ON SCHEMA datos FROM postgres;
GRANT ALL ON SCHEMA datos TO postgres;
GRANT ALL ON SCHEMA datos TO PUBLIC;


--
-- TOC entry 3301 (class 0 OID 0)
-- Dependencies: 10
-- Name: historial; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA historial FROM PUBLIC;
REVOKE ALL ON SCHEMA historial FROM postgres;
GRANT ALL ON SCHEMA historial TO postgres;
GRANT ALL ON SCHEMA historial TO PUBLIC;


--
-- TOC entry 3303 (class 0 OID 0)
-- Dependencies: 11
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


SET search_path = datos, pg_catalog;

--
-- TOC entry 3319 (class 0 OID 0)
-- Dependencies: 167
-- Name: actiecon; Type: ACL; Schema: datos; Owner: postgres
--

REVOKE ALL ON TABLE actiecon FROM PUBLIC;
REVOKE ALL ON TABLE actiecon FROM postgres;
GRANT ALL ON TABLE actiecon TO postgres;


SET search_path = historial, pg_catalog;

--
-- TOC entry 3850 (class 0 OID 0)
-- Dependencies: 284
-- Name: bitacora; Type: ACL; Schema: historial; Owner: postgres
--

REVOKE ALL ON TABLE bitacora FROM PUBLIC;
REVOKE ALL ON TABLE bitacora FROM postgres;
GRANT ALL ON TABLE bitacora TO postgres;
GRANT ALL ON TABLE bitacora TO PUBLIC;


--
-- TOC entry 3852 (class 0 OID 0)
-- Dependencies: 285
-- Name: Bitacora_IDBitacora_seq; Type: ACL; Schema: historial; Owner: postgres
--

REVOKE ALL ON SEQUENCE "Bitacora_IDBitacora_seq" FROM PUBLIC;
REVOKE ALL ON SEQUENCE "Bitacora_IDBitacora_seq" FROM postgres;
GRANT ALL ON SEQUENCE "Bitacora_IDBitacora_seq" TO postgres;
GRANT ALL ON SEQUENCE "Bitacora_IDBitacora_seq" TO PUBLIC;


--
-- TOC entry 1946 (class 826 OID 27757)
-- Dependencies: 10 3293
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: historial; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA historial REVOKE ALL ON SEQUENCES  FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA historial REVOKE ALL ON SEQUENCES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA historial GRANT ALL ON SEQUENCES  TO PUBLIC;


--
-- TOC entry 1947 (class 826 OID 27758)
-- Dependencies: 10 3293
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: historial; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA historial REVOKE ALL ON FUNCTIONS  FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA historial REVOKE ALL ON FUNCTIONS  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA historial GRANT ALL ON FUNCTIONS  TO PUBLIC;


--
-- TOC entry 1948 (class 826 OID 27759)
-- Dependencies: 10 3293
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: historial; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA historial REVOKE ALL ON TABLES  FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA historial REVOKE ALL ON TABLES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA historial GRANT ALL ON TABLES  TO PUBLIC;


-- Completed on 2014-03-04 19:54:04 VET

--
-- PostgreSQL database dump complete
--

