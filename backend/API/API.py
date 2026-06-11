from fastapi import FastAPI, HTTPException, status
from fastapi.responses import JSONResponse
import mysql.connector
from pydantic import BaseModel
from typing import List, Optional
from datetime import date
from mysql.connector import Error

double = float  # Python alias so signosFisicos model loads correctly

app = FastAPI(title="API de Pacientes")

# Configuración de la conexión
def get_db_connection():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="bj4U,g6P/7",
        database="caritasDB"
    )

# --- MODELOS DE DATOS ---

class Paciente(BaseModel):
    id: int
    nombre: str
    apellidoP: str
    apellidoM: str
    genero: str
    edad: int
    fechaNac: date
    curp: str
    familiares: int
    firmaPriv: bool
    domicilioID: int

class nuevoPaciente(BaseModel):
    nombre: str
    apellidoP: str
    apellidoM: str
    genero: str
    edad: int
    fechaNac: date
    curp: str
    familiares: int
    firmaPriv: bool
    domicilioID: int

class Domicilio(BaseModel):
    id: int
    ciudadID: int
    calle: str
    numCasa: int

class nuevoDomicilio(BaseModel):
    ciudadID: int
    calle: str
    numCasa: int

class PaisCreate(BaseModel):
    nombre: str

class EstadoCreate(BaseModel):
    paisID: int
    nombre: str

class MunicipioCreate(BaseModel):
    estadoID: int
    nombre: str

class CiudadCreate(BaseModel):
    municipioID: int
    nombre: str

class signosFisicos(BaseModel):
    id: int
    pacienteID: int
    peso: double
    talla: str
    perimAbdom: double
    presArterD: double
    presArterS: double
    pulso: double
    frecCard: double
    frecResp: double

class Doctor(BaseModel):
    id: int
    nombre: str
    apellidoP: str
    apellidoM: str
    genero: str
    realizandoPrac: bool
    fechaNac: date

class nuevoDoctor(BaseModel):
    nombre: str
    apellidoP: str
    apellidoM: str
    genero: str
    realizandoPrac: bool
    fechaNac: date

class Brigada(BaseModel):
    id: int
    doctorID: int
    serviciosDisp: int
    fechaOp: date
    municipioID: int
    ciudadID: int
    colonia: str

class NuevaBrigada(BaseModel):
    doctorID: int
    serviciosDisp: int
    fechaOp: date
    municipioID: int
    ciudadID: int
    colonia: Optional[str] = None

class Medicamento(BaseModel):
    id: int
    nombre: str

class NuevoMedicamento(BaseModel):
    nombre: str

class Servicio(BaseModel):
    id: int
    pacienteID: int
    doctorID: int
    brigadaID: int
    signosID: int
    medicamentosID: int
    cantMedicina: int
    tipoServicio: str
    fechaServicio: date
    imss: bool
    tipoPaciente: str

class NuevoServicio(BaseModel):
    pacienteID: int
    doctorID: int
    brigadaID: int
    signosID: int
    medicamentosID: int
    cantMedicina: int
    tipoServicio: str
    fechaServicio: date
    imss: bool
    tipoPaciente: str


# --- ENDPOINTS ---

@app.get("/")
def inicio():
    return {"mensaje": "API de Pacientes conectada"}

## PACIENTES
## ---------------------------------------------------------------

@app.get("/pacientes", response_model=List[Paciente])
def obtener_pacientes():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT id, nombre, apellidoP, apellidoM, genero, edad, fechaNac,
               curp, familiares, firmaPriv, domicilioID
        FROM Pacientes
    """)

    result = cursor.fetchall()
    cursor.close()
    conn.close()
    return result


@app.post("/pacientes", status_code=status.HTTP_201_CREATED)
def crear_paciente(paciente: nuevoPaciente):

    conn = get_db_connection()
    cursor = conn.cursor()

    try:

        query = """
            INSERT INTO Pacientes (
                nombre,
                apellidoP,
                apellidoM,
                genero,
                edad,
                fechaNac,
                curp,
                familiares,
                firmaPriv,
                domicilioID
            )
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """

        values = (
            paciente.nombre,
            paciente.apellidoP,
            paciente.apellidoM,
            paciente.genero,
            paciente.edad,
            paciente.fechaNac,
            paciente.curp,
            paciente.familiares,
            paciente.firmaPriv,
            paciente.domicilioID
        )

        cursor.execute(query, values)
        conn.commit()

        nuevo_id = cursor.lastrowid

        return {
            "mensaje": "Paciente creado correctamente",
            "id": nuevo_id
        }

    except Exception as e:

        if getattr(e, "errno", None) == 1062:

            cursor.execute("""
                SELECT id
                FROM Pacientes
                WHERE nombre = %s
                AND apellidoP = %s
                AND apellidoM = %s
                AND fechaNac = %s
                AND curp = %s
            """, (
                paciente.nombre,
                paciente.apellidoP,
                paciente.apellidoM,
                paciente.fechaNac,
                paciente.curp
            ))

            paciente_existente = cursor.fetchone()

            return {
                "mensaje": "Paciente ya existe",
                "id": paciente_existente[0]
            }

        raise HTTPException(
            status_code=400,
            detail=str(e)
        )

    finally:
        cursor.close()
        conn.close()


@app.get("/pacientes/{paciente_id}", response_model=Paciente)
def obtener_paciente(paciente_id: int):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT id, nombre, apellidoP, apellidoM, genero, edad, fechaNac,
               curp, familiares, firmaPriv, domicilioID
        FROM Pacientes WHERE id = %s
    """, (paciente_id,))

    result = cursor.fetchone()
    cursor.close()
    conn.close()

    if result is None:
        raise HTTPException(status_code=404, detail="Paciente no encontrado")

    return result


@app.put("/pacientes/{paciente_id}")
def actualizar_paciente(paciente_id: int, paciente: Paciente):
    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        query = """
            UPDATE Pacientes
            SET nombre=%s, apellidoP=%s, apellidoM=%s, genero=%s, edad=%s,
                fechaNac=%s, curp=%s, familiares=%s, firmaPriv=%s, domicilioID=%s
            WHERE id = %s
        """
        values = (
            paciente.nombre, paciente.apellidoP, paciente.apellidoM,
            paciente.genero, paciente.edad, paciente.fechaNac,
            paciente.curp, paciente.familiares, paciente.firmaPriv,
            paciente.domicilioID, paciente_id
        )

        cursor.execute(query, values)
        conn.commit()

        if cursor.rowcount == 0:
            raise HTTPException(status_code=404, detail="Paciente no encontrado")

    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

    finally:
        cursor.close()
        conn.close()

    return {"mensaje": "Paciente actualizado correctamente"}


@app.delete("/pacientes/{paciente_id}")
def borrar_paciente(paciente_id: int):
    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        cursor.execute("DELETE FROM Pacientes WHERE id = %s", (paciente_id,))
        conn.commit()

        if cursor.rowcount == 0:
            raise HTTPException(status_code=404, detail="Paciente no encontrado")

    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

    finally:
        cursor.close()
        conn.close()

    return {"mensaje": "Paciente eliminado correctamente"}


## DOMICILIO
## ---------------------------------------------------------------

@app.get("/domicilio/{domicilio_id}", response_model=Domicilio)
def obtener_domicilio_por_id(domicilio_id: int):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        cursor.execute("SELECT id, ciudadID, calle, numCasa FROM Domicilio WHERE id = %s", (domicilio_id,))
        domicilio = cursor.fetchone()

        if domicilio is None:
            raise HTTPException(status_code=404, detail="Domicilio no encontrado")

        return domicilio

    finally:
        cursor.close()
        conn.close()


@app.post("/domicilio", status_code=status.HTTP_201_CREATED)
def crear_domicilio(domicilio: nuevoDomicilio):
    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        query = "INSERT INTO Domicilio (ciudadID, calle, numCasa) VALUES (%s, %s, %s)"
        values = (domicilio.ciudadID, domicilio.calle, domicilio.numCasa)

        cursor.execute(query, values)
        conn.commit()

        nuevo_id = cursor.lastrowid

        return {"mensaje": "Domicilio creado correctamente", "id": nuevo_id}

    except Exception as e:
        if getattr(e, "errno", None) == 1062:
            cursor.execute(
                "SELECT id FROM Domicilio WHERE ciudadID=%s AND calle=%s AND numCasa=%s",
                values
            )
            existente = cursor.fetchone()
            return {"mensaje": "Domicilio ya existe", "id": existente[0]}

        raise HTTPException(status_code=400, detail=str(e))

    finally:
        cursor.close()
        conn.close()


@app.put("/domicilio/{domicilio_id}")
def actualizar_domicilio(domicilio_id: int, domicilio: Domicilio):
    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        cursor.execute("""
            UPDATE Domicilio SET ciudadID=%s, calle=%s, numCasa=%s WHERE id=%s
        """, (domicilio.ciudadID, domicilio.calle, domicilio.numCasa, domicilio_id))

        conn.commit()

        if cursor.rowcount == 0:
            raise HTTPException(status_code=404, detail="Domicilio no encontrado")

    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

    finally:
        cursor.close()
        conn.close()

    return {"mensaje": "Domicilio actualizado correctamente"}


## LUGARES
## ---------------------------------------------------------------

@app.get("/paises")
def get_paises():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT id, nombre FROM Pais WHERE nombre IS NOT NULL ORDER BY nombre")
    paises = cursor.fetchall()
    cursor.close()
    conn.close()
    return paises


@app.get("/catalogo")
def get_catalogo():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("SELECT id, nombre FROM Pais WHERE nombre IS NOT NULL ORDER BY nombre")
    paises = cursor.fetchall()

    cursor.execute("SELECT id, paisID, nombre FROM Estado WHERE nombre IS NOT NULL ORDER BY nombre")
    estados = cursor.fetchall()

    cursor.execute("SELECT id, estadoID, nombre FROM Municipio WHERE nombre IS NOT NULL ORDER BY nombre")
    municipios = cursor.fetchall()

    cursor.execute("SELECT id, municipioID, nombre FROM Ciudad WHERE nombre IS NOT NULL ORDER BY nombre")
    ciudades = cursor.fetchall()

    cursor.close()
    conn.close()

    return {"paises": paises, "estados": estados, "municipios": municipios, "ciudades": ciudades}


@app.get("/paises/{pais_id}/estados")
def get_estados(pais_id: int):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT id, paisID, nombre FROM Estado WHERE paisID=%s AND nombre IS NOT NULL ORDER BY nombre", (pais_id,))
    estados = cursor.fetchall()
    cursor.close()
    conn.close()
    return estados


@app.get("/estados/{estado_id}/municipios")
def get_municipios(estado_id: int):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT id, estadoID, nombre FROM Municipio WHERE estadoID=%s AND nombre IS NOT NULL ORDER BY nombre", (estado_id,))
    municipios = cursor.fetchall()
    cursor.close()
    conn.close()
    return municipios


@app.get("/municipios/{municipio_id}/ciudades")
def get_ciudades(municipio_id: int):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT id, municipioID, nombre FROM Ciudad WHERE municipioID=%s AND nombre IS NOT NULL ORDER BY nombre", (municipio_id,))
    ciudades = cursor.fetchall()
    cursor.close()
    conn.close()
    return ciudades


@app.post("/paises", status_code=201)
def create_pais(data: PaisCreate):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        cursor.execute("SELECT id FROM Pais WHERE nombre = %s", (data.nombre,))
        if cursor.fetchone():
            raise HTTPException(status_code=409, detail="El pais ya existe en la base de datos.")

        cursor.execute("INSERT INTO Pais(nombre) VALUES(%s)", (data.nombre,))
        conn.commit()
        return {"id": cursor.lastrowid, "nombre": data.nombre}

    finally:
        cursor.close()
        conn.close()


@app.post("/estados", status_code=201)
def create_estado(data: EstadoCreate):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        cursor.execute("SELECT id FROM Pais WHERE id = %s", (data.paisID,))
        if not cursor.fetchone():
            raise HTTPException(status_code=404, detail="El país especificado no existe")

        cursor.execute("SELECT id FROM Estado WHERE paisID=%s AND nombre=%s", (data.paisID, data.nombre))
        if cursor.fetchone():
            raise HTTPException(status_code=409, detail="El estado ya existe para ese país")

        cursor.execute("INSERT INTO Estado(paisID, nombre) VALUES(%s, %s)", (data.paisID, data.nombre))
        conn.commit()
        return {"id": cursor.lastrowid, "paisID": data.paisID, "nombre": data.nombre}

    finally:
        cursor.close()
        conn.close()


@app.post("/municipios", status_code=201)
def create_municipio(data: MunicipioCreate):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        cursor.execute("SELECT id FROM Estado WHERE id = %s", (data.estadoID,))
        if not cursor.fetchone():
            raise HTTPException(status_code=404, detail="El estado especificado no existe")

        cursor.execute("SELECT id FROM Municipio WHERE estadoID=%s AND nombre=%s", (data.estadoID, data.nombre))
        if cursor.fetchone():
            raise HTTPException(status_code=409, detail="El municipio ya existe para ese estado")

        cursor.execute("INSERT INTO Municipio(estadoID, nombre) VALUES(%s, %s)", (data.estadoID, data.nombre))
        conn.commit()
        return {"id": cursor.lastrowid, "estadoID": data.estadoID, "nombre": data.nombre}

    finally:
        cursor.close()
        conn.close()


@app.post("/ciudades", status_code=201)
def create_ciudad(data: CiudadCreate):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        cursor.execute("SELECT id FROM Municipio WHERE id = %s", (data.municipioID,))
        if not cursor.fetchone():
            raise HTTPException(status_code=404, detail="El municipio especificado no existe")

        cursor.execute("SELECT id FROM Ciudad WHERE municipioID=%s AND nombre=%s", (data.municipioID, data.nombre))
        if cursor.fetchone():
            raise HTTPException(status_code=409, detail="La ciudad ya existe para ese municipio")

        cursor.execute("INSERT INTO Ciudad(municipioID, nombre) VALUES(%s, %s)", (data.municipioID, data.nombre))
        conn.commit()
        return {"id": cursor.lastrowid, "municipioID": data.municipioID, "nombre": data.nombre}

    finally:
        cursor.close()
        conn.close()


## SIGNOS FISICOS
## ---------------------------------------------------------------

@app.get("/signosfisicos", response_model=List[signosFisicos])
def obtener_signosfisicos():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT id, pacienteID, peso, talla, perimAbdom,
               presionArterD AS presArterD, presionArterS AS presArterS,
               pulso, frecCard, frecResp
        FROM signosFisicos
    """)

    result = cursor.fetchall()
    cursor.close()
    conn.close()
    return result


@app.post("/signosfisicos", status_code=status.HTTP_201_CREATED)
def crear_signosfisicos(signosfisicos: signosFisicos):
    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        query = """
            INSERT INTO signosFisicos (
                pacienteID, peso, talla, perimAbdom,
                presionArterD, presionArterS, pulso, frecCard, frecResp
            )
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        values = (
            signosfisicos.pacienteID, signosfisicos.peso, signosfisicos.talla,
            signosfisicos.perimAbdom, signosfisicos.presArterD, signosfisicos.presArterS,
            signosfisicos.pulso, signosfisicos.frecCard, signosfisicos.frecResp
        )

        cursor.execute(query, values)
        conn.commit()

        return {"mensaje": "Signos Fisicos creados correctamente", "id": cursor.lastrowid}

    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error al crear signos fisicos: {str(e)}")

    finally:
        cursor.close()
        conn.close()


@app.put("/signosfisicos/{paciente_id}")
def actualizar_signosfisicos(paciente_id: int, signosfisicos: signosFisicos):
    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        query = """
            UPDATE signosFisicos
            SET peso=%s, talla=%s, perimAbdom=%s,
                presionArterD=%s, presionArterS=%s,
                pulso=%s, frecCard=%s, frecResp=%s
            WHERE pacienteID = %s
        """
        values = (
            signosfisicos.peso, signosfisicos.talla, signosfisicos.perimAbdom,
            signosfisicos.presArterD, signosfisicos.presArterS,
            signosfisicos.pulso, signosfisicos.frecCard, signosfisicos.frecResp,
            paciente_id
        )

        cursor.execute(query, values)
        conn.commit()

        if cursor.rowcount == 0:
            raise HTTPException(status_code=404, detail="Paciente no encontrado")

    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

    finally:
        cursor.close()
        conn.close()

    return {"mensaje": "Signos Fisicos actualizados correctamente"}


## DOCTORES
## ---------------------------------------------------------------

@app.get("/doctores", response_model=List[Doctor])
def obtener_doctores():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM Doctor")
    result = cursor.fetchall()
    cursor.close()
    conn.close()
    return result


@app.get("/doctores/{doctor_id}", response_model=Doctor)
def get_doctor(doctor_id: int):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM Doctor WHERE id = %s", (doctor_id,))
    doctor = cursor.fetchone()
    conn.close()

    if not doctor:
        raise HTTPException(status_code=404, detail="Doctor no encontrado")

    return doctor


@app.post("/doctores", response_model=Doctor)
def create_doctor(doctor: nuevoDoctor):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        cursor.execute("""
            INSERT INTO Doctor (nombre, apellidoP, apellidoM, genero, realizandoPrac, fechaNac)
            VALUES (%s, %s, %s, %s, %s, %s)
        """, (
            doctor.nombre, doctor.apellidoP, doctor.apellidoM,
            doctor.genero, doctor.realizandoPrac, doctor.fechaNac
        ))

        conn.commit()
        nuevo_id = cursor.lastrowid
        cursor.execute("SELECT * FROM Doctor WHERE id = %s", (nuevo_id,))
        return cursor.fetchone()

    except mysql.connector.Error as err:
        if err.errno == 1062:
            raise HTTPException(status_code=409, detail="Ya existe un doctor con esos datos.")
        raise

    finally:
        conn.close()


@app.put("/doctores/{doctor_id}", response_model=Doctor)
def update_doctor(doctor_id: int, doctor: nuevoDoctor):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        UPDATE Doctor
        SET nombre=%s, apellidoP=%s, apellidoM=%s, genero=%s, realizandoPrac=%s, fechaNac=%s
        WHERE id = %s
    """, (
        doctor.nombre, doctor.apellidoP, doctor.apellidoM,
        doctor.genero, doctor.realizandoPrac, doctor.fechaNac, doctor_id
    ))

    conn.commit()

    if cursor.rowcount == 0:
        conn.close()
        raise HTTPException(status_code=404, detail="Doctor no encontrado")

    cursor.execute("SELECT * FROM Doctor WHERE id = %s", (doctor_id,))
    doctor_actualizado = cursor.fetchone()
    conn.close()
    return doctor_actualizado


## BRIGADAS
## ---------------------------------------------------------------

@app.get("/brigadas", response_model=List[Brigada])
def obtener_brigadas():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM Brigada")
    brigadas = cursor.fetchall()
    cursor.close()
    conn.close()
    return brigadas


@app.get("/brigadas/{brigada_id}", response_model=Brigada)
def obtener_brigada(brigada_id: int):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM Brigada WHERE id = %s", (brigada_id,))
    brigada = cursor.fetchone()
    cursor.close()
    conn.close()

    if not brigada:
        raise HTTPException(status_code=404, detail="Brigada no encontrada")

    return brigada


@app.post("/brigadas", status_code=status.HTTP_201_CREATED)
def crear_brigada(brigada: NuevaBrigada):
    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        query = """
            INSERT INTO Brigada (doctorID, serviciosDisp, fechaOp, municipioID, ciudadID, colonia)
            VALUES (%s, %s, %s, %s, %s, %s)
        """
        values = (
            brigada.doctorID, brigada.serviciosDisp, brigada.fechaOp,
            brigada.municipioID, brigada.ciudadID, brigada.colonia
        )

        cursor.execute(query, values)
        conn.commit()

        return {"mensaje": "Brigada creada correctamente", "id": cursor.lastrowid}

    except Exception as e:
        if getattr(e, "errno", None) == 1062:
            cursor.execute("""
                SELECT id FROM Brigada
                WHERE fechaOp=%s AND municipioID=%s AND ciudadID=%s
                AND (colonia=%s OR (colonia IS NULL AND %s IS NULL))
            """, (brigada.fechaOp, brigada.municipioID, brigada.ciudadID, brigada.colonia, brigada.colonia))
            existente = cursor.fetchone()
            return {"mensaje": "La brigada ya existe", "id": existente[0]}

        raise HTTPException(status_code=400, detail=str(e))

    finally:
        cursor.close()
        conn.close()


## MEDICAMENTOS
## ---------------------------------------------------------------

@app.get("/medicamentos", response_model=List[Medicamento])
def obtener_medicamentos():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT id, nombre FROM Medicamentos ORDER BY nombre")
    medicamentos = cursor.fetchall()
    cursor.close()
    conn.close()
    return medicamentos


@app.get("/medicamentos/{medicamento_id}", response_model=Medicamento)
def obtener_medicamento(medicamento_id: int):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT id, nombre FROM Medicamentos WHERE id = %s", (medicamento_id,))
    medicamento = cursor.fetchone()
    cursor.close()
    conn.close()

    if not medicamento:
        raise HTTPException(status_code=404, detail="Medicamento no encontrado")

    return medicamento


@app.post("/medicamentos", status_code=status.HTTP_201_CREATED)
def crear_medicamento(medicamento: NuevoMedicamento):
    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        cursor.execute("INSERT INTO Medicamentos (nombre) VALUES (%s)", (medicamento.nombre,))
        conn.commit()
        return {"mensaje": "Medicamento creado correctamente", "id": cursor.lastrowid}

    except Exception as e:
        if getattr(e, "errno", None) == 1062:
            cursor.execute("SELECT id FROM Medicamentos WHERE nombre = %s", (medicamento.nombre,))
            existente = cursor.fetchone()
            return {"mensaje": "Medicamento ya existe", "id": existente[0]}

        raise HTTPException(status_code=400, detail=str(e))

    finally:
        cursor.close()
        conn.close()


## SERVICIOS
## ---------------------------------------------------------------

@app.get("/servicios", response_model=List[Servicio])
def obtener_servicios():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT id, pacienteID, doctorID, brigadaID, signosID,
               medicamentosID, cantMedicina, tipoServicio,
               fechaServicio, imss, tipoPaciente
        FROM Servicio
    """)

    servicios = cursor.fetchall()
    cursor.close()
    conn.close()
    return servicios


@app.get("/servicios/{servicio_id}", response_model=Servicio)
def obtener_servicio(servicio_id: int):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT id, pacienteID, doctorID, brigadaID, signosID,
               medicamentosID, cantMedicina, tipoServicio,
               fechaServicio, imss, tipoPaciente
        FROM Servicio WHERE id = %s
    """, (servicio_id,))

    servicio = cursor.fetchone()
    cursor.close()
    conn.close()

    if not servicio:
        raise HTTPException(status_code=404, detail="Servicio no encontrado")

    return servicio


@app.post("/servicios", status_code=status.HTTP_201_CREATED)
def crear_servicio(servicio: NuevoServicio):
    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        cursor.execute("""
            INSERT INTO Servicio (
                pacienteID, doctorID, brigadaID, signosID,
                medicamentosID, cantMedicina, tipoServicio,
                fechaServicio, imss, tipoPaciente
            )
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (
            servicio.pacienteID, servicio.doctorID, servicio.brigadaID,
            servicio.signosID, servicio.medicamentosID, servicio.cantMedicina,
            servicio.tipoServicio, servicio.fechaServicio, servicio.imss,
            servicio.tipoPaciente
        ))

        conn.commit()
        return {"mensaje": "Servicio creado correctamente", "id": cursor.lastrowid}

    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

    finally:
        cursor.close()
        conn.close()


## REPORTES
## ---------------------------------------------------------------

@app.get("/reportes/consultas")
def reporte_consultas(
    tipo: str,
    filtro: str = "",
    valor: str = ""
):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    query = """
        SELECT
            s.id, s.pacienteID, s.doctorID, s.brigadaID,
            s.signosID,
            COALESCE(s.cantMedicina, 0)                            AS cantMedicina,
            COALESCE(s.tipoServicio, '')                           AS tipoServicio,
            DATE_FORMAT(s.fechaServicio, '%Y-%m-%d')               AS fechaServicio,
            CAST(s.imss AS UNSIGNED)                               AS imss,
            COALESCE(s.tipoPaciente, '')                           AS tipoPaciente,
            CONCAT(p.nombre, ' ', p.apellidoP, ' ', p.apellidoM)  AS pacienteNombre,
            CONCAT(d.nombre, ' ', d.apellidoP)                     AS doctorNombre,
            b.colonia                                               AS brigadaColonia,
            c.nombre                                                AS ciudadNombre
        FROM Servicio s
        LEFT JOIN Pacientes p ON s.pacienteID = p.id
        LEFT JOIN Doctor    d ON s.doctorID   = d.id
        LEFT JOIN Brigada   b ON s.brigadaID  = b.id
        LEFT JOIN Ciudad    c ON b.ciudadID   = c.id
        WHERE 1=1
    """
    params = []

    if filtro and valor:
        if filtro == "servicio":
            query += " AND s.tipoServicio LIKE %s"
            params.append(f"%{valor}%")
        elif filtro == "doctor":
            query += " AND (d.nombre LIKE %s OR d.apellidoP LIKE %s)"
            params += [f"%{valor}%"] * 2
        elif filtro == "pacientes":
            query += " AND (p.nombre LIKE %s OR p.apellidoP LIKE %s)"
            params += [f"%{valor}%"] * 2
        elif filtro == "brigada":
            query += " AND b.colonia LIKE %s"
            params.append(f"%{valor}%")
        elif filtro == "ciudad":
            query += " AND c.nombre LIKE %s"
            params.append(f"%{valor}%")

    try:
        cursor.execute(query, params)
        rows = cursor.fetchall()
        return JSONResponse(content=rows)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cursor.close()
        conn.close()
