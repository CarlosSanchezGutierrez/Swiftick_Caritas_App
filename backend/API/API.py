from fastapi import FastAPI, HTTPException, status
import mysql.connector
from pydantic import BaseModel
from typing import List, Optional
from datetime import date  # Mejor opción para manejar DATE de MySQL
from mysql.connector import Error

app = FastAPI(title="API de Pacientes")

# Configuración de la conexión
def get_db_connection():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="bj4U,g6P/7",
        database="caritasDB"
    )

# --- MODELO DE DATOS ---

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

class Brigada(BaseModel):
    id: int
    doctorID: int
    serviciosDisp: str
    fechaOp: date
    municipioID: int
    ciudadID: int
    colonia: str

class NuevaBrigada(BaseModel):
    doctorID: int
    serviciosDisp: str
    fechaOp: date
    municipioID: int
    ciudadID: int
    colonia: Optional[str] = None

class Medicamento(BaseModel):
    id: int
    nombre: str
    descripcion: Optional[str] = None

class NuevoMedicamento(BaseModel):
    nombre: str
    descripcion: Optional[str] = None

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


# --- ENDPOINTS ---

@app.get("/")
def inicio():
    return {"mensaje": "API de Pacientes conectada"}

##
## PACIENTES ----------------------------------------

# 1. Listar Pacientes
@app.get("/pacientes", response_model=List[Paciente])
def obtener_pacientes():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT
            id,
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
        FROM Pacientes
    """)

    result = cursor.fetchall()

    cursor.close()
    conn.close()

    return result


# 2. Crear Paciente
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

    except Exception as e:
        raise HTTPException(
            status_code=400,
            detail=f"Error al crear paciente: {str(e)}"
        )

    finally:
        cursor.close()
        conn.close()

    return {"mensaje": "Paciente creado correctamente"}


# 3. Obtener Paciente por ID
@app.get("/pacientes/{paciente_id}", response_model=Paciente)
def obtener_paciente(paciente_id: int):

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    query = """
        SELECT
            id,
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
        FROM Pacientes
        WHERE id = %s
    """

    cursor.execute(query, (paciente_id,))
    result = cursor.fetchone()

    cursor.close()
    conn.close()

    if result is None:
        raise HTTPException(
            status_code=404,
            detail="Paciente no encontrado"
        )

    return result


# 4. Actualizar Paciente
@app.put("/pacientes/{paciente_id}")
def actualizar_paciente(paciente_id: int, paciente: Paciente):

    conn = get_db_connection()
    cursor = conn.cursor()

    try:

        query = """
            UPDATE Pacientes
            SET
                nombre = %s,
                apellidoP = %s,
                apellidoM = %s,
                genero = %s,
                edad = %s,
                fechaNac = %s,
                curp = %s,
                familiares = %s,
                firmaPriv = %s,
                domicilioID = %s
            WHERE id = %s
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
            paciente.domicilioID,
            paciente_id
        )

        cursor.execute(query, values)
        conn.commit()

        if cursor.rowcount == 0:
            raise HTTPException(
                status_code=404,
                detail="Paciente no encontrado"
            )

    except Exception as e:
        raise HTTPException(
            status_code=400,
            detail=str(e)
        )

    finally:
        cursor.close()
        conn.close()

    return {"mensaje": "Paciente actualizado correctamente"}


# 5. Borrar Paciente
@app.delete("/pacientes/{paciente_id}")
def borrar_paciente(paciente_id: int):

    conn = get_db_connection()
    cursor = conn.cursor()

    try:

        query = "DELETE FROM Pacientes WHERE id = %s"

        cursor.execute(query, (paciente_id,))
        conn.commit()

        if cursor.rowcount == 0:
            raise HTTPException(
                status_code=404,
                detail="Paciente no encontrado"
            )

    except Exception as e:
        raise HTTPException(
            status_code=400,
            detail=str(e)
        )

    finally:
        cursor.close()
        conn.close()

    return {"mensaje": "Paciente eliminado correctamente"}

## DOMICILIOENDPOINTS
## -----------------------------------------------------------

#1 Obtener Domicilio por ID
@app.get("/domicilio/{domicilio_id}", response_model=Domicilio)
def obtener_domicilio_por_id(domicilio_id: int):

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    try:

        cursor.execute("""
            SELECT
                ciudadID,
                calle,
                numCasa
            FROM Domicilio
            WHERE id = %s
        """, (domicilio_id,))

        domicilio = cursor.fetchone()

        if domicilio is None:
            raise HTTPException(
                status_code=404,
                detail="Domicilio no encontrado"
            )

        return domicilio

    finally:
        cursor.close()
        conn.close()

#2 Crear nuevo domicilio
@app.post("/domicilio", status_code=status.HTTP_201_CREATED)
def crear_domicilio(domicilio: nuevoDomicilio):

    conn = get_db_connection()
    cursor = conn.cursor()

    try:

        query = """
            INSERT INTO Domicilio (
                ciudadID,
                calle,
                numCasa
            )
            VALUES (%s, %s, %s)
        """

        values = (
            domicilio.ciudadID,
            domicilio.calle,
            domicilio.numCasa
        )

        cursor.execute(query, values)
        conn.commit()

        nuevo_id = cursor.lastrowid
        
        return {
            "mensaje": "Domicilio creado correctamente",
            "id": nuevo_id
        }

    except Exception as e:
        if getattr(e, "errno", None) == 1062:

            cursor.execute("""
                SELECT id
                FROM Domicilio
                WHERE ciudadID = %s
                AND calle = %s
                AND numCasa = %s
            """, values)

            domicilio_existente = cursor.fetchone()

            return {
                "mensaje": "Domicilio ya existe",
                "id": domicilio_existente[0]
            }

        raise HTTPException(
            status_code=400,
            detail=str(e)
        )

    finally:
        cursor.close()
        conn.close()

#3 Actualizar domicilio por ID
@app.put("/domicilio/{domicilio_id}")
def actualizar_domicilio(domicilio_id: int, domicilio: Domicilio):

    conn = get_db_connection()
    cursor = conn.cursor()

    try:

        query = """
            UPDATE Domicilio
            SET
                ciudadID = %s,
                calle = %s,
                numCasa = %s
            WHERE id = %s
        """

        values = (
            domicilio.ciudadID,
            domicilio.calle,
            domicilio.numCasa,
            domicilio_id
        )

        cursor.execute(query, values)
        conn.commit()

        if cursor.rowcount == 0:
            raise HTTPException(
                status_code=404,
                detail="Domicilio no encontrado"
            )

    except Exception as e:
        raise HTTPException(
            status_code=400,
            detail=str(e)
        )

    finally:
        cursor.close()
        conn.close()

    nuevo_id = cursor.lastrowid

    return {
        "mensaje": "Domicilio actualizado correctamente",
        "id": nuevo_id
}

## LUGARES ENDPOINTS
## -------------------------------------------------------

# Obtener lista de paises
@app.get("/paises")
def get_paises():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT id, nombre
        FROM Pais
        WHERE nombre IS NOT NULL
        ORDER BY nombre
    """)

    paises = cursor.fetchall()

    cursor.close()
    conn.close()

    return paises

# Obtener catalogo de lugares
@app.get("/catalogo")
def get_catalogo():
    conn = get_db_connection()

    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT id, nombre
        FROM Pais
        WHERE nombre IS NOT NULL
        ORDER BY nombre
    """)

    paises = cursor.fetchall()

    cursor.execute("""
        SELECT id, paisID, nombre
        FROM Estado
        WHERE nombre IS NOT NULL
        ORDER BY nombre
    """)

    estados = cursor.fetchall()

    cursor.execute("""
        SELECT id, estadoID, nombre
        FROM Municipio
        WHERE nombre IS NOT NULL
        ORDER BY nombre
    """)

    municipios = cursor.fetchall()

    cursor.execute("""
        SELECT id, municipioID, nombre
        FROM Ciudad
        WHERE nombre IS NOT NULL
        ORDER BY nombre
    """)

    ciudades = cursor.fetchall()

    cursor.close()
    conn.close()

    return {
        "paises": paises,
        "estados": estados,
        "municipios": municipios,
        "ciudades": ciudades
}

# Obtener lista de estados de un pais
@app.get("/paises/{pais_id}/estados")
def get_estados(pais_id: int):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT id, paisID, nombre
        FROM Estado
        WHERE paisID = %s AND nombre IS NOT NULL
        ORDER BY nombre
    """, (pais_id,))

    estados = cursor.fetchall()

    cursor.close()
    conn.close()

    return estados

# Obtener lista de municipios de un estado
@app.get("/estados/{estado_id}/municipios")
def get_municipios(estado_id: int):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT id, estadoID, nombre
        FROM Municipio
        WHERE estadoID = %s AND nombre IS NOT NULL
        ORDER BY nombre
    """, (estado_id,))

    municipios = cursor.fetchall()

    cursor.close()
    conn.close()

    return municipios

# Obtener lista de ciudades de un municipio
@app.get("/municipios/{municipio_id}/ciudades")
def get_ciudades(municipio_id: int):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT id, municipioID, nombre
        FROM Ciudad
        WHERE municipioID = %s AND nombre IS NOT NULL
        ORDER BY nombre
    """, (municipio_id,))

    ciudades = cursor.fetchall()

    cursor.close()
    conn.close()

    return ciudades

# Crear un pais (WOW!)
@app.post("/paises", status_code=201)
def create_pais(data: PaisCreate):

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        # Verificar que no exista ya un pais con el mismo nombre
        cursor.execute("""
            SELECT id
            FROM Pais
            WHERE nombre = %s
        """, (
            data.nombre
        ))

        pais_existente = cursor.fetchone()

        if pais_existente:
            raise HTTPException(
                status_code=409,
                detail="El pais ya existe en la base de datos."
            )

        # Crear pais
        cursor.execute("""
            INSERT INTO Pais(
                nombre
            )
            VALUES(%s)
        """, (
            data.nombre
        ))

        conn.commit()

        nuevo_id = cursor.lastrowid

        return {
            "id": nuevo_id,
            "nombre": data.nombre
        }

    finally:
        cursor.close()
        conn.close()

# Crear un estado
@app.post("/estados", status_code=201)
def create_estado(data: EstadoCreate):

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        cursor.execute("""
            SELECT id
            FROM Pais
            WHERE id = %s
        """, (data.paisID,))

        pais = cursor.fetchone()

        if not pais:
            raise HTTPException(
                status_code=404,
                detail="El país especificado no existe"
            )
        cursor.execute("""
            SELECT id
            FROM Estado
            WHERE paisID = %s
            AND nombre = %s
        """, (
            data.paisID,
            data.nombre
        ))

        estado_existente = cursor.fetchone()

        if estado_existente:
            raise HTTPException(
                status_code=409,
                detail="El estado ya existe para ese país"
            )
        cursor.execute("""
            INSERT INTO Estado(
                paisID,
                nombre
            )
            VALUES(%s, %s)
        """, (
            data.paisID,
            data.nombre
        ))

        conn.commit()

        nuevo_id = cursor.lastrowid

        return {
            "id": nuevo_id,
            "paisID": data.paisID,
            "nombre": data.nombre
        }

    finally:
        cursor.close()
        conn.close()

# Crear un nuevo municipio para un estado
@app.post("/municipios", status_code=201)
def create_municipio(data: MunicipioCreate):

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        # Verificar que el estado exista
        cursor.execute("""
            SELECT id
            FROM Estado
            WHERE id = %s
        """, (data.estadoID,))

        estado = cursor.fetchone()

        if not estado:
            raise HTTPException(
                status_code=404,
                detail="El estado especificado no existe"
            )

        # Verificar que no exista ya un municipio con el mismo nombre
        # dentro de ese estado
        cursor.execute("""
            SELECT id
            FROM Municipio
            WHERE estadoID = %s
            AND nombre = %s
        """, (
            data.estadoID,
            data.nombre
        ))

        municipio_existente = cursor.fetchone()

        if municipio_existente:
            raise HTTPException(
                status_code=409,
                detail="El municipio ya existe para ese estado"
            )

        # Crear estado
        cursor.execute("""
            INSERT INTO Municipio(
                estadoID,
                nombre
            )
            VALUES(%s, %s)
        """, (
            data.estadoID,
            data.nombre
        ))

        conn.commit()

        nuevo_id = cursor.lastrowid

        return {
            "id": nuevo_id,
            "estadoID": data.estadoID,
            "nombre": data.nombre
        }

    finally:
        cursor.close()
        conn.close()

# Crear una nueva ciudad para un municipio
@app.post("/ciudades", status_code=201)
def create_ciudad(data: CiudadCreate):

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    try:

        # Verificar que el municipio exista
        cursor.execute("""
            SELECT id
            FROM Municipio
            WHERE id = %s
        """, (data.municipioID,))

        municipio = cursor.fetchone()

        if not municipio:
            raise HTTPException(
                status_code=404,
                detail="El municipio especificado no existe"
            )

        # Verificar que no exista ya una ciudad con el mismo nombre
        # dentro de ese municipio
        cursor.execute("""
            SELECT id
            FROM Ciudad
            WHERE municipioID = %s
            AND nombre = %s
        """, (
            data.municipioID,
            data.nombre
        ))

        ciudad_existente = cursor.fetchone()

        if ciudad_existente:
            raise HTTPException(
                status_code=409,
                detail="La ciudad ya existe para ese municipio"
            )

        # Crear ciudad
        cursor.execute("""
            INSERT INTO Ciudad(
                municipioID,
                nombre
            )
            VALUES(%s, %s)
        """, (
            data.municipioID,
            data.nombre
        ))

        conn.commit()

        nuevo_id = cursor.lastrowid

        return {
            "id": nuevo_id,
            "municipioID": data.municipioID,
            "nombre": data.nombre
        }

    finally:
        cursor.close()
        conn.close()


## SIGNOS FISICOS ENDPOINTS
## -------------------------------------------------------

#1 Obtener Signos Fisicos
@app.get("/signosfisicos", response_model=List[signosFisicos])
def obtener_signosfisicos():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT
            id,
            pacienteID,
            peso,
            talla,
            perimAbdom,
            presionArterD,
            presionArterS,
            pulso,
            frecCard,
            frecResp
        FROM signosFisicos
    """)

    result = cursor.fetchall()

    cursor.close()
    conn.close()

    return result

#2 Registrar nuevos signos fisicos
@app.post("/signosfisicos", status_code=status.HTTP_201_CREATED)
def crear_signosfisicos(signosfisicos: signosFisicos):

    conn = get_db_connection()
    cursor = conn.cursor()

    try:

        query = """
            INSERT INTO signosFisicos (
                pacienteID,
                peso,
                talla,
                perimAbdom,
                presionArterD,
                presionArterS,
                pulso,
                frecCard,
                frecResp
            )
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        """

        values = (
            signosfisicos.pacienteID,
            signosfisicos.peso,
            signosfisicos.talla,
            signosfisicos.perimAbdom,
            signosfisicos.presionArterD,
            signosfisicos.presionArterS,
            signosfisicos.pulso,
            signosfisicos.frecCard,
            signosfisicos.frecResp
        )

        cursor.execute(query, values)
        conn.commit()

    except Exception as e:
        raise HTTPException(
            status_code=400,
            detail=f"Error al crear signos fisicos: {str(e)}"
        )

    finally:
        cursor.close()
        conn.close()

    return {"mensaje": "Signos Fisicos creados correctamente"}

#3 Actualizar signos fisicos por id
@app.put("/signosfisicos/{paciente_id}")
def actualizar_signosfisicos(paciente_id: int, signosfisicos: signosFisicos):

    conn = get_db_connection()
    cursor = conn.cursor()

    try:

        query = """
            UPDATE signosFisicos
            SET
                peso = %s,
                talla = %s,
                perimAbdom = %s,
                presArterD = %s,
                presArterS = %s,
                pulso = %s,
                frecCard = %s,
                frecResp = %s
            WHERE pacienteID = %s
        """

        values = (
            signosfisicos.peso,
            signosfisicos.talla,
            signosfisicos.perimAbdom,
            signosfisicos.presArterD,
            signosfisicos.presArterS,
            signosfisicos.pulso,
            signosfisicos.frecCard,
            signosfisicos.frecResp,
            paciente_id
        )

        cursor.execute(query, values)
        conn.commit()

        if cursor.rowcount == 0:
            raise HTTPException(
                status_code=404,
                detail="Paciente no encontrado"
            )

    except Exception as e:
        raise HTTPException(
            status_code=400,
            detail=str(e)
        )

    finally:
        cursor.close()
        conn.close()

    return {"mensaje": "Signos Fisicos actualizados correctamente"}

## Doctores
## ---------------------------------------------------------------

#1 Obtener doctor por id
@app.get("/doctores/{doctor_id}", response_model=Doctor)
def get_doctor(doctor_id: int):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute(
        "SELECT * FROM Doctor WHERE id = %s",
        (doctor_id,)
    )

    doctor = cursor.fetchone()

    conn.close()

    if not doctor:
        raise HTTPException(
            status_code=404,
            detail="Doctor no encontrado"
        )

    return doctor

# Agregar nuevo Doctor
@app.post("/doctores", response_model=Doctor)
def create_doctor(doctor: nuevoDoctor):

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        cursor.execute("""
            INSERT INTO Doctor
            (nombre, apellidoP, apellidoM, genero,
             realizandoPrac, fechaNac)
            VALUES (%s, %s, %s, %s, %s, %s)
        """, (
            doctor.nombre,
            doctor.apellidoP,
            doctor.apellidoM,
            doctor.genero,
            doctor.realizandoPrac,
            doctor.fechaNac
        ))

        conn.commit()

        nuevo_id = cursor.lastrowid

        cursor.execute(
            "SELECT * FROM Doctor WHERE id = %s",
            (nuevo_id,)
        )

        return cursor.fetchone()

    except mysql.connector.Error as err:
        if err.errno == 1062:  # Duplicate entry
            raise HTTPException(
                status_code=409,
                detail="Ya existe un doctor con esos datos."
            )
        raise

    finally:
        conn.close()

#3 Actualizar un doctor
@app.put("/doctores/{doctor_id}", response_model=Doctor)
def update_doctor(
    doctor_id: int,
    doctor: nuevoDoctor
):

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        UPDATE Doctor
        SET nombre = %s,
            apellidoP = %s,
            apellidoM = %s,
            genero = %s,
            realizandoPrac = %s,
            fechaNac = %s
        WHERE id = %s
    """, (
        doctor.nombre,
        doctor.apellidoP,
        doctor.apellidoM,
        doctor.genero,
        doctor.realizandoPrac,
        doctor.fechaNac,
        doctor_id
    ))

    conn.commit()

    if cursor.rowcount == 0:
        conn.close()
        raise HTTPException(
            status_code=404,
            detail="Doctor no encontrado"
        )

    cursor.execute(
        "SELECT * FROM Doctor WHERE id = %s",
        (doctor_id,)
    )

    doctor_actualizado = cursor.fetchone()

    conn.close()

    return doctor_actualizado


## BRIGADAS ENDPOINTS
## ---------------------------------------------------------------

# 1. Obtener todas las brigadas
@app.get("/brigadas", response_model=List[Brigada])
def obtener_brigadas():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT id, doctorID, serviciosDisp, fechaOp,
               municipioID, ciudadID, colonia
        FROM Brigada
    """)

    result = cursor.fetchall()

    cursor.close()
    conn.close()

    return result

# 2. Obtener brigada por ID
@app.get("/brigadas/{brigada_id}", response_model=Brigada)
def obtener_brigada(brigada_id: int):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT id, doctorID, serviciosDisp, fechaOp,
               municipioID, ciudadID, colonia
        FROM Brigada
        WHERE id = %s
    """, (brigada_id,))

    result = cursor.fetchone()

    cursor.close()
    conn.close()

    if result is None:
        raise HTTPException(status_code=404, detail="Brigada no encontrada")

    return result

# 3. Crear nueva brigada
@app.post("/brigadas", status_code=status.HTTP_201_CREATED)
def crear_brigada(brigada: NuevaBrigada):
    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        query = """
            INSERT INTO Brigada (doctorID, serviciosDisp, fechaOp,
                                 municipioID, ciudadID, colonia)
            VALUES (%s, %s, %s, %s, %s, %s)
        """
        values = (
            brigada.doctorID,
            brigada.serviciosDisp,
            brigada.fechaOp,
            brigada.municipioID,
            brigada.ciudadID,
            brigada.colonia
        )

        cursor.execute(query, values)
        conn.commit()

        nuevo_id = cursor.lastrowid

    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error al crear brigada: {str(e)}")

    finally:
        cursor.close()
        conn.close()

    return {"mensaje": "Brigada creada correctamente", "id": nuevo_id}


## MEDICAMENTOS ENDPOINTS
## ---------------------------------------------------------------

# 1. Obtener todos los medicamentos
@app.get("/medicamentos", response_model=List[Medicamento])
def obtener_medicamentos():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("SELECT id, nombre, descripcion FROM Medicamento")

    result = cursor.fetchall()

    cursor.close()
    conn.close()

    return result

# 2. Obtener medicamento por ID
@app.get("/medicamentos/{medicamento_id}", response_model=Medicamento)
def obtener_medicamento(medicamento_id: int):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute(
        "SELECT id, nombre, descripcion FROM Medicamento WHERE id = %s",
        (medicamento_id,)
    )

    result = cursor.fetchone()

    cursor.close()
    conn.close()

    if result is None:
        raise HTTPException(status_code=404, detail="Medicamento no encontrado")

    return result

# 3. Crear nuevo medicamento
@app.post("/medicamentos", status_code=status.HTTP_201_CREATED)
def crear_medicamento(medicamento: NuevoMedicamento):
    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        cursor.execute(
            "INSERT INTO Medicamento (nombre, descripcion) VALUES (%s, %s)",
            (medicamento.nombre, medicamento.descripcion)
        )
        conn.commit()

        nuevo_id = cursor.lastrowid

    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error al crear medicamento: {str(e)}")

    finally:
        cursor.close()
        conn.close()

    return {"mensaje": "Medicamento creado correctamente", "id": nuevo_id}


## SERVICIOS ENDPOINTS
## ---------------------------------------------------------------

# 1. Obtener todos los servicios
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

    result = cursor.fetchall()

    cursor.close()
    conn.close()

    return result

# 2. Obtener servicio por ID
@app.get("/servicios/{servicio_id}", response_model=Servicio)
def obtener_servicio(servicio_id: int):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT id, pacienteID, doctorID, brigadaID, signosID,
               medicamentosID, cantMedicina, tipoServicio,
               fechaServicio, imss, tipoPaciente
        FROM Servicio
        WHERE id = %s
    """, (servicio_id,))

    result = cursor.fetchone()

    cursor.close()
    conn.close()

    if result is None:
        raise HTTPException(status_code=404, detail="Servicio no encontrado")

    return result

# 3. Crear nuevo servicio
@app.post("/servicios", status_code=status.HTTP_201_CREATED)
def crear_servicio(servicio: NuevoServicio):
    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        query = """
            INSERT INTO Servicio (
                pacienteID, doctorID, brigadaID, signosID,
                medicamentosID, cantMedicina, tipoServicio,
                fechaServicio, imss, tipoPaciente
            )
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        values = (
            servicio.pacienteID,
            servicio.doctorID,
            servicio.brigadaID,
            servicio.signosID,
            servicio.medicamentosID,
            servicio.cantMedicina,
            servicio.tipoServicio,
            servicio.fechaServicio,
            servicio.imss,
            servicio.tipoPaciente
        )

        cursor.execute(query, values)
        conn.commit()

        nuevo_id = cursor.lastrowid

    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error al crear servicio: {str(e)}")

    finally:
        cursor.close()
        conn.close()

    return {"mensaje": "Servicio creado correctamente", "id": nuevo_id}