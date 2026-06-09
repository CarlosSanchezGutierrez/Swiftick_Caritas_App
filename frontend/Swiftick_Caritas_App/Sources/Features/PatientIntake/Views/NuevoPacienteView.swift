//
//  NuevoPacienteView.swift
//  Swiftick_Caritas_App
//

import SwiftUI
import SwiftData

struct NuevoPacienteView: View {
    var paciente: Paciente? = nil

    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss

    @State private var mostrarFormulario = false
    @State private var firmaPriv = false
    @State private var firmaPrivacidad = false

    @State private var nombre = ""
    @State private var apellidoP = ""
    @State private var apellidoM = ""
    @State private var genero = ""
    @State private var fechaNacimiento = Date()
    @State private var curp = ""
    @State private var familiares = ""

    @State private var pais = ""
    @State private var estado = ""
    @State private var municipio = ""
    @State private var ciudad = ""
    @State private var calle = ""
    @State private var numCasa = ""

    @State private var nombreDoc = ""
    @State private var apellidoPDOC = ""
    @State private var apellidoMDOC = ""
    @State private var generoDoc = ""
    @State private var realizandoPrac = false
    @State private var fechaNacDoc = Date()

    @State private var errorNombre = false
    @State private var errorApellidoP = false
    @State private var errorApellidoM = false
    @State private var errorGenero = false
    @State private var errorFamiliares = false
    @State private var errorNombreDoc = false
    @State private var errorApellidoPDoc = false
    @State private var errorApellidoMDoc = false
    @State private var errorGeneroDoc = false
    @State private var mensajeError = ""

    let opcionesGenero = ["Masculino", "Femenino", "No binario", "Prefiero no decir"]

    var isCreating: Bool { paciente == nil }

    var body: some View {
        Group {
            if !mostrarFormulario {
                privacyView
            } else {
                formView
            }
        }
        .onAppear {
            if let p = paciente {
                prefill(from: p)
                mostrarFormulario = true
            }
        }
    }

    // MARK: - Privacy Screen

    private var privacyView: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("AVISO DE PRIVACIDAD")
                        .font(.title2).fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .center)

                    Text("CÁRITAS DE MONTERREY, A.B.P., hace de su conocimiento el presente Aviso de Privacidad de acuerdo a lo dispuesto por la Ley Federal de Protección de Datos Personales en Posesión de los Particulares (LFPDPPP) y su Reglamento, para informarle cuáles son los datos personales que podemos obtener, sus finalidades, así como los términos en que los estaremos utilizando, buscando garantizar su confidencialidad y protección de acuerdo a las medidas de seguridad físicas, técnicas y administrativas que hemos dispuesto para dicho fin.")

                    Text("Se cuidarán en todo momento los datos personales de nuestros beneficiarios, donantes, voluntarios, prestadores de servicio social y personal que labora en nuestra institución.")

                    Group {
                        Text("¿Quién es el responsable de proteger los Datos Personales recabados?")
                            .fontWeight(.semibold)
                        Text("CÁRITAS DE MONTERREY, A.B.P con domicilio en FRANCISCO G. SADA PTE 2810 OBISPADO MONTERREY, NUEVO LEON, MEXICO 64040 es responsable de recabar sus datos personales, del uso que se le dé a los mismos y de su protección.")
                    }

                    Group {
                        Text("¿Para qué fines utilizaremos sus datos personales?")
                            .fontWeight(.semibold)
                        Text("1. Captación de donativos.\n2. Ofrecer servicio de registro de donantes y pagos en línea.\n3. Trámite de recibo deducible.\n4. Difusión de información de áreas de servicio y campañas.\n5. Donativos directos: únicos y/o recurrentes.\n6. Invitaciones para presentación de campañas y nuevos programas.\n7. Programas de apadrinamiento.\n8. Voluntariado.\n9. Generación de bases de datos.")
                    }

                    Group {
                        Text("De manera adicional, utilizaremos su información personal para las siguientes ")
                            .fontWeight(.regular)
                        + Text("finalidades secundarias").fontWeight(.bold)
                        + Text(" que no son indispensables para servirle, pero que nos permiten y facilitan brindarle una mejor atención:\n\n1. Evaluar la calidad del servicio que brindamos.\n2. Envío de Boletines Electrónicos.\n3. Mercadotecnia o publicidad.\n4. Elaborar estudios y programas que son necesarios para determinar hábitos de consumo.")
                    }

                    Group {
                        Text("¿Cómo puede limitar el uso de sus datos personales para finalidades secundarias?")
                            .fontWeight(.semibold)
                        Text("En caso de que no desee que sus datos personales sean utilizados para las finalidades secundarias descritas en el presente Aviso de Privacidad, ponemos a su disposición el siguiente correo electrónico para manifestar su negativa: caritas@caritas.org.mx")
                    }

                    Group {
                        Text("Cambios al Aviso de Privacidad")
                            .fontWeight(.semibold)
                        Text("Los cambios que se pudieran realizar al Aviso de Privacidad derivados de cambios en la administración, operación y/o actualizaciones a la propia Ley y Reglamento que lo sustentan, se los estaremos notificando a través de nuestro sitio web.\n\nEl titular de los datos personales podrá ejercer en todo momento su derecho de acceso, rectificación, cancelación y oposición (A.R.C.O.) de datos personales que proporcione, pudiendo ejercer tal derecho mediante aviso por escrito en las oficinas de la institución, debidamente identificado.")
                        Text("Fecha de última actualización: 08/01/2025.")
                            .fontWeight(.semibold)
                    }
                }
                .font(.footnote)
                .padding()
            }

            VStack(spacing: 12) {
                Divider()
                Toggle("He leído y acepto el aviso de privacidad.", isOn: $firmaPriv)
                    .padding(.horizontal)
                Button("Confirmar") {
                    firmaPrivacidad = true
                    mostrarFormulario = true
                }
                .disabled(!firmaPriv)
                .padding()
                .frame(maxWidth: .infinity)
                .background(firmaPriv ? Color(red: 0/255, green: 156/255, blue: 166/255) : Color.gray)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            .background(Color(UIColor.systemBackground))
        }
        .navigationTitle("Aviso de Privacidad")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Form

    private var formView: some View {
        ScrollView {
            VStack(spacing: 5) {
                pacienteSection
                domicilioSection
                doctorSection

                if !mensajeError.isEmpty {
                    Text(mensajeError)
                        .foregroundStyle(Color.red)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                }

                Button {
                    if validarFormulario() {
                        guardarPaciente()
                        guardarDoctor()
                        dismiss()
                    }
                } label: {
                    HStack {
                        Image(systemName: "checkmark")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.white)
                        Text("Guardar y continuar")
                            .font(.headline)
                            .foregroundStyle(Color.white)
                    }
                }
                .padding(3)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(red: 0/255, green: 156/255, blue: 166/255))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding()
        }
        .background(Color(red: 242/255, green: 242/255, blue: 247/255))
        .navigationTitle(isCreating ? "Nuevo Paciente" : "Editar Paciente")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Paciente Section

    private var pacienteSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Información del paciente")
                .font(.title2)
                .fontWeight(.bold)

            campoTexto("Nombre(s)", texto: $nombre, placeholder: "Ingrese el nombre", error: errorNombre)
            campoTexto("Apellido paterno", texto: $apellidoP, placeholder: "Ingrese el apellido paterno", error: errorApellidoP)
            campoTexto("Apellido materno", texto: $apellidoM, placeholder: "Ingrese el apellido materno", error: errorApellidoM)

            VStack(alignment: .leading, spacing: 8) {
                Text("Género").fontWeight(.semibold)
                Picker("Género", selection: $genero) {
                    Text("Seleccionar").tag("")
                    ForEach(opcionesGenero, id: \.self) { Text($0).tag($0) }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.gray.opacity(0.1))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(errorGenero ? Color.red : Color.clear, lineWidth: 2))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                if errorGenero { errorCaption }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Fecha de nacimiento").fontWeight(.semibold)
                DatePicker("", selection: $fechaNacimiento, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("CURP").fontWeight(.semibold)
                TextField("Ingrese la CURP", text: $curp)
                    .textInputAutocapitalization(.characters)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            campoTexto("Número de familiares", texto: $familiares, placeholder: "Ingrese el número", soloNumeros: true, error: errorFamiliares)
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(radius: 5)
    }

    // MARK: - Domicilio Section

    private var domicilioSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Domicilio")
                .font(.title2)
                .fontWeight(.bold)

            campoTexto("País", texto: $pais, placeholder: "Ej. México")
            campoTexto("Estado", texto: $estado, placeholder: "Ej. Nuevo León")
            campoTexto("Municipio", texto: $municipio, placeholder: "Ej. Monterrey")
            campoTexto("Ciudad", texto: $ciudad, placeholder: "Ej. Monterrey")
            campoTexto("Calle", texto: $calle, placeholder: "Ej. Av. Insurgentes")
            campoTexto("Número de casa", texto: $numCasa, placeholder: "Ej. 123", soloNumeros: true)
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(radius: 5)
    }

    // MARK: - Doctor Section

    private var doctorSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Información del doctor")
                .font(.title2)
                .fontWeight(.bold)

            campoTexto("Nombre(s)", texto: $nombreDoc, placeholder: "Ingrese el nombre", error: errorNombreDoc)
            campoTexto("Apellido paterno", texto: $apellidoPDOC, placeholder: "Ingrese el apellido paterno", error: errorApellidoPDoc)
            campoTexto("Apellido materno", texto: $apellidoMDOC, placeholder: "Ingrese el apellido materno", error: errorApellidoMDoc)

            VStack(alignment: .leading, spacing: 8) {
                Text("Género").fontWeight(.semibold)
                Picker("Género", selection: $generoDoc) {
                    Text("Seleccionar").tag("")
                    ForEach(opcionesGenero, id: \.self) { Text($0).tag($0) }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.gray.opacity(0.1))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(errorGeneroDoc ? Color.red : Color.clear, lineWidth: 2))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                if errorGeneroDoc { errorCaption }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Fecha de nacimiento").fontWeight(.semibold)
                DatePicker("", selection: $fechaNacDoc, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Toggle("¿Se encuentra realizando prácticas?", isOn: $realizandoPrac)
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(radius: 5)
    }

    // MARK: - Helpers

    private var errorCaption: some View {
        Text("Este campo es obligatorio")
            .foregroundStyle(Color.red)
            .font(.caption)
    }

    @ViewBuilder
    private func campoTexto(
        _ label: String,
        texto: Binding<String>,
        placeholder: String,
        soloNumeros: Bool = false,
        error: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).fontWeight(.semibold)
            Group {
                if soloNumeros {
                    TextField(placeholder, text: texto).keyboardType(.numberPad)
                } else {
                    TextField(placeholder, text: texto)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(error ? Color.red : Color.clear, lineWidth: 2))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            if error { errorCaption }
        }
    }

    // MARK: - Logic

    private func prefill(from p: Paciente) {
        nombre = p.nombre
        apellidoP = p.apellidoP
        apellidoM = p.apellidoM
        genero = p.genero
        fechaNacimiento = p.fechaNac
        curp = p.curp == "Sin CURP" ? "" : p.curp
        familiares = "\(p.familiares)"
        firmaPrivacidad = p.firmaPrivacidad
        pais = p.pais
        estado = p.estado
        municipio = p.municipio
        ciudad = p.ciudad
        calle = p.calle
        numCasa = p.numCasa
    }

    private func validarFormulario() -> Bool {
        errorNombre      = nombre.trimmingCharacters(in: .whitespaces).isEmpty
        errorApellidoP   = apellidoP.trimmingCharacters(in: .whitespaces).isEmpty
        errorApellidoM   = apellidoM.trimmingCharacters(in: .whitespaces).isEmpty
        errorGenero      = genero.isEmpty
        errorFamiliares  = familiares.isEmpty
        errorNombreDoc   = nombreDoc.trimmingCharacters(in: .whitespaces).isEmpty
        errorApellidoPDoc = apellidoPDOC.trimmingCharacters(in: .whitespaces).isEmpty
        errorApellidoMDoc = apellidoMDOC.trimmingCharacters(in: .whitespaces).isEmpty
        errorGeneroDoc   = generoDoc.isEmpty

        let hayErrores = errorNombre || errorApellidoP || errorApellidoM || errorGenero ||
            errorFamiliares || errorNombreDoc || errorApellidoPDoc || errorApellidoMDoc || errorGeneroDoc
        mensajeError = hayErrores ? "Por favor complete todos los campos obligatorios." : ""
        return !hayErrores
    }

    private func guardarPaciente() {
        let edadCalculada = Calendar.current.dateComponents([.year], from: fechaNacimiento, to: Date()).year ?? 0
        let intFam = Int(familiares) ?? 0

        if let existente = paciente {
            existente.nombre = nombre
            existente.apellidoP = apellidoP
            existente.apellidoM = apellidoM
            existente.genero = genero
            existente.edad = edadCalculada
            existente.fechaNac = fechaNacimiento
            existente.curp = curp.isEmpty ? "Sin CURP" : curp
            existente.familiares = intFam
            existente.firmaPrivacidad = firmaPrivacidad
            existente.pais = pais
            existente.estado = estado
            existente.municipio = municipio
            existente.ciudad = ciudad
            existente.calle = calle
            existente.numCasa = numCasa
            existente.isSynced = false
        } else {
            let nuevo = Paciente(
                nombre: nombre, apellidoP: apellidoP, apellidoM: apellidoM,
                genero: genero, edad: edadCalculada, fechaNac: fechaNacimiento,
                familiares: intFam, curp: curp
            )
            nuevo.firmaPrivacidad = firmaPrivacidad
            nuevo.pais = pais
            nuevo.estado = estado
            nuevo.municipio = municipio
            nuevo.ciudad = ciudad
            nuevo.calle = calle
            nuevo.numCasa = numCasa
            modelContext.insert(nuevo)
        }
        try? modelContext.save()
    }

    private func guardarDoctor() {
        guard !nombreDoc.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let doctor = Doctor(
            nombre: nombreDoc, apellidoP: apellidoPDOC, apellidoM: apellidoMDOC,
            genero: generoDoc, fechaNac: fechaNacDoc, realizandoPrac: realizandoPrac
        )
        modelContext.insert(doctor)
        try? modelContext.save()
    }
}

#Preview {
    NavigationStack {
        NuevoPacienteView()
    }
    .modelContainer(for: [Paciente.self, Doctor.self], inMemory: true)
}
