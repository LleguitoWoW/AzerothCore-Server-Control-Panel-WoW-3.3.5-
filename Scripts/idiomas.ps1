# ==========================================
# DICCIONARIO GLOBAL DE IDIOMAS (ES / EN)
# ==========================================
$Global:Textos = @{
    "ES" = @{
        "Titulo"       = "PANEL DE CONTROL DEL SERVIDOR"
        "BtnIniciar"   = "Iniciar"
        "BtnApagar"    = "Apagar"
        "BtnWow"       = "Iniciar Juego"
        "BtnStartAll"  = "INICIAR TODO"
        "BtnStopAll"   = "APAGAR TODO"
        "BtnConfig"    = "Cambiar Rutas"
        "StatusWait"   = "Esperando acciones..."
        "StatusStartM" = "[1/3] Iniciar MySQL..."
        "StatusStartA" = "[2/3] Iniciar AuthServer..."
        "StatusStartW" = "[3/3] Iniciar WorldServer..."
        "StatusStopW"  = "[1/3] Apagando WorldServer..."
        "StatusStopA"  = "[2/3] Apagando AuthServer..."
        "StatusStopM"  = "[3/3] Apagando MySQL..."
        "DbWait"       = "Esperando a que la Base de Datos cargue..."
        "AuthWait"     = "Esperando a que el autenticador este listo..."
        "WorldWait"    = "Entorno lanzado correctamente."
        "AllStarted"   = "Todo iniciado!"
        "AllStopped"   = "Entorno apagado de forma segura!"
        "Myson"        = "Apagando MySQL de forma limpia..."
        "Mysfail"      = "Finalizando proceso residual de MySQL..."
        "MsgMysqlCierreForzado2" = "El apagado limpio de MySQL (mysqladmin -u{0} shutdown) no ha funcionado a tiempo, asi que se ha tenido que forzar el cierre del proceso (no fue un apagado limpio)."
        "MsgMysqlShutdownDetalle" = "Mensaje de mysqladmin:"
        "MsgMysqlShutdownDetalle2" = "Mensaje de SHUTDOWN por SQL:"
        "TituloAviso"  = "Aviso"
        "CtrlC"        = "Enviando Ctrl+C a"
        "Listo"        = "Listo."
        "ConfigIn"     = "Faltan rutas de configuracion. Se abrira el asistente."
        "ConfigSave"   = "Rutas guardadas correctamente."
        "ConfigCancel" = "Configuracion incompleta. El panel se cerrara."
        
        # MÓDULO DE CUENTAS
        "BtnCuentas"   = "Cuentas y Rangos"
        "GrpCrear"     = "Crear Nueva Cuenta"
        "GrpGM"        = "Convertir Cuenta en GM"
        "LblUsuario"   = "Usuario:"
        "LblPassword"  = "Contrasena:"
        "BtnAccion"    = "Crear"
        "MsgNoWorld"   = "¡Error! El WorldServer debe estar encendido para enviar comandos."
        "MsgCreada"    = "¡Cuenta creada correctamente!"
        "MsgGMOK"      = "¡Rango GM de nivel 3 asignado de forma segura!"

        # MÓDULO DE PERSONAJES (NUEVO)
        "BtnPersonajes"   = "Personajes (Pdump)"
        "GrpSalvar"       = "Salvar Personaje"
        "GrpCargar"       = "Cargar Personaje Guardado"
        "LblTxtPjSalvar"  = "Nombre del personaje:"
        "LblTxtFile"      = "Nombre del archivo:"
        "LblTxtAccCargar" = "Nombre de la cuenta:"
        "BtnSalvar"       = "Salvar"
        "BtnCargar"       = "Cargar"
        "MsgFileExists"   = "¡Error! Ya existe un archivo con ese mismo nombre en la carpeta del servidor."
        "MsgCargarAviso"  = "¡Aviso! El archivo salvado del antiguo servidor debe estar guardado previamente dentro del nuevo servidor (carpeta WorldServer)."
        "MsgDumpOK"       = "¡Comando de volcado (pdump write) enviado con éxito!"
        "MsgLoadOK"       = "¡Comando de carga (pdump load) enviado con éxito!"

        # SUBMÓDULO: HERMANDAD / GUILD (SISTEMA SQL SIMPLIFICADO)
        "GrpHermandad"            = "Hermandad (Guild)"
        "MsgGuildInfoBoton"       = "Exporta o inyecta una hermandad completa (miembros, banco, objetos y dinero) mediante SQL generado, con marcadores de ID que puedes sustituir tu mismo."
        "BtnAbrirHermandadSQL"    = "Abrir Hermandad (SQL)"
        "TituloHermandadSQL"      = "Hermandad: Generar / Inyectar SQL"
        "LblNombreGuildExportar"  = "Hermandad a exportar:"
        "BtnGenerarSql"           = "Generar SQL"
        "BtnGuardarHermandadDirecto" = "Guardar Hermandad (genera + guarda .sql)"
        "MsgFaltaNombreGuild"     = "Escribe el nombre de la hermandad primero."
        "BtnAbrirSqlGuardado"     = "Abrir .sql guardado..."
        "LblIdGuildNuevo"         = "Nuevo ID Hermandad:"
        "BtnAuto"                 = "Auto"
        "LblGmNombreExistente"    = "Nombre del GM (ya cargado aqui):"
        "LblGmGuidCampo"          = "GUID:"
        "BtnBuscar"               = "Buscar"
        "LblItemBase"             = "GUID base para objetos del banco:"
        "MsgAvisoHermandadSQL"    = "El personaje del GM debe existir YA en este servidor. RECOMENDADO: para el WorldServer antes de pulsar 'Inyectar' (evita que el objeto choque con GUIDs que el servidor reserva en memoria mientras esta encendido) y vuelve a arrancarlo despues."
        "BtnAplicarIds"           = "Aplicar IDs al texto"
        "BtnGuardarSqlArchivo"    = "Guardar texto actual en .sql"
        "BtnInyectarSql"          = "Inyectar en este servidor"
        "BtnVerificarSql"         = "Verificar hermandad"
        "BtnAyudaHermandad"       = "Como se exporta? (Ayuda)"
        "TituloAyudaHermandad"    = "Ayuda: como exportar una hermandad"
        "MsgAyudaHermandadTexto"  = @"
COMO MIGRAR UNA HERMANDAD A OTRO SERVIDOR
============================================

PASOS A SEGUIR:


===== EN EL SERVIDOR ANTIGUO =====

1. Guardar Personaje
   Guarda tu personaje (el que es GM de la hermandad) desde
   Personajes > Guardar Personaje.

2. Guardar tu Hermandad
   Ve a Hermandad, escribe el nombre y pulsa el boton
   "Guardar Hermandad (genera + guarda .sql)".


>>> Una vez hechos estos 2 pasos, copia LOS ARCHIVOS GENERADOS <<<
>>> a la carpeta donde esta el WorldServer del servidor NUEVO. <<<


===== EN EL SERVIDOR NUEVO =====

3. Cargar Personaje
   Carga tu personaje en el nuevo servidor.

4. Verificar el personaje
   Entra en el juego y comprueba que esta cargado. Puede
   pedirte que le cambies el nombre (si ya existe otro igual
   en este servidor); es normal, hazlo sin miedo.

5. Apaga el WorldServer.

6. Cargar tu Hermandad
   Pulsa el boton "Abrir .sql guardado..." y elige el archivo.

7. Rellena los campos:
     - Nombre del GM  ->  boton "Buscar" (rellena su GUID solo)
     - Nuevo ID Hermandad  ->  boton "Auto"
     - GUID base para objetos del banco  ->  boton "Auto"

8. Pulsa "Aplicar IDs al texto".

9. Pulsa "Inyectar en este servidor" (asi se guarda la hermandad).

10. Enciende el WorldServer y, una vez cargado, entra al juego.


FIN


NOTAS:

- Solo se exporta al GM como miembro. El resto de la gente debera
  volver a unirse a la hermandad dentro del juego.
- Puedes usar "Verificar hermandad" en cualquier momento para
  comprobar que el GM esta bien enlazado, sin tocar nada.
"@
        "MsgSqlGuardadoOK"        = "Guardado como '{0}' en la carpeta del WorldServer."
        "MsgAvisoGuardarModificado" = "Este texto ya tiene los IDs aplicados (los marcadores @@...@@ ya no estan). Si lo guardas asi, sobrescribiras el archivo con esta version y no podras volver a aplicarle otros IDs distintos despues. Si quieres conservar el original para reutilizarlo en otro servidor, pulsa 'Generar SQL' de nuevo antes de guardar. Continuar y guardar tal cual esta ahora?"
        "MsgFaltaAplicarIds"      = "El texto todavia tiene marcadores @@...@@ sin sustituir. Pulsa 'Aplicar IDs al texto' primero."
        "MsgConfirmarInyectar"    = "Esto va a ejecutar el SQL directamente sobre la base de datos de este servidor. Se recomienda tener el WorldServer PARADO mientras se hace esto, para evitar choques de GUID con objetos que el servidor cree en memoria mientras esta encendido. Continuar?"
        "MsgInyectadoOK"          = "Hermandad inyectada correctamente. Reinicia el WorldServer para que el juego la cargue."
        "MsgGuildError"           = "Error al procesar la hermandad."
        "MsgPersonajeNoEncontrado" = "No se encontro ningun personaje con ese nombre en este servidor."
        "TituloListaGuildDumps"   = "Backups de hermandad guardados"
        "MsgNoGuildDumps"         = "No se encontraron backups de hermandad en esa carpeta."

        # MÓDULO DE DESCARGA DEL CLIENTE HD (NUEVO)
        "BtnDescargarHD"    = "Descargar Cliente HD y Servidor"
        "BtnCredencialesMysql"   = "Credenciales de MySQL (usuario / contrasena)"
        "BtnMods"                = "Mods"
        "TituloSeleccionarMods"  = "Selecciona la carpeta de Mods"
        "MsgModsCarpetaNoExiste" = "La carpeta de Mods configurada ya no existe. Vuelve a pulsar el boton para seleccionarla de nuevo."
        "TituloCredencialesMysql" = "Credenciales de MySQL"
        "GrpMysqlApp"       = "Usuario de la aplicacion (hermandades, personajes...)"
        "GrpMysqlAdmin"     = "Usuario administrador (apagar MySQL, permisos)"
        "LblContrasena"     = "Contrasena:"
        "ChkVerContrasenas" = "Mostrar contrasenas"
        "MsgAvisoCredencialesMysql" = "El usuario administrador necesita el privilegio SHUTDOWN para poder apagar MySQL limpiamente. Estos datos se guardan solo en este equipo, en config_server.txt."
        "BtnGuardar"        = "Guardar"
        "MsgCredencialesGuardadas" = "Credenciales guardadas correctamente."
        "LblSeparadorNPCBots" = "NPCBOTS"
        "BtnNPCBots"        = "Generador de NPCBots"
        "MsgAvisoNPCBots"   = "AVISO OBLIGATORIO: este generador solo funciona en servidores AzerothCore que tengan instalado el modulo NPCBots (mod-npcbots). Si tu servidor NO lo tiene instalado, el SQL generado no servira de nada y podria dar errores al inyectarlo. Deseas abrir el generador?"
        "MsgNPCBotsNoEncontrado" = "No se encontro el archivo NPCBotsGenerator.html en la carpeta Scripts."
        "BtnInyectarSqlPrincipal" = "Inyectar SQL"
        "TituloInyectarSQL"      = "Inyectar SQL"
        "LblBaseDatos"           = "Base de datos destino:"
        "MsgAvisoNPCBotsDB"      = "Nota: el SQL del Generador de NPCBots normalmente va en 'acore_world' (creature_template y similares)."
        "BtnPegarPortapapeles"   = "Pegar del portapapeles"
        "BtnCargarSqlArchivo"    = "Cargar SQL..."
        "TituloCargarSqlArchivo" = "Selecciona un archivo SQL"
        "MsgErrorLeerArchivo"    = "No se pudo leer el archivo seleccionado."
        "BtnLimpiar"             = "Limpiar"
        "BtnFormatearSql"        = "Formatear SQL"
        "MsgFaltaBaseDatos"      = "Indica una base de datos destino."
        "MsgConfirmarInyectarGenerico" = "Esto va a ejecutar el SQL directamente sobre la base de datos '{0}' de este servidor. Continuar?"
        "MsgInyectadoOKGenerico" = "SQL inyectado correctamente."
        "MsgAvisoInyectarSql"    = "Revisa siempre el SQL antes de inyectarlo: se ejecuta tal cual, sin comprobaciones adicionales."
        "TituloDescargarHD" = "Descargar Cliente HD"
        "MsgDescargarInfo"  = "Elige la parte que quieras descargar:"
        "LblParte1"         = "Parte 1"
        "LblParte2"         = "Parte 2"
        "LblParte3"         = "Parte 3"
        "TituloServidor"    = "Servidor"
        "LblServidor"       = "Descargar Servidor"
        "BtnCerrar"         = "Cerrar"

        # MÓDULO DE CONFIGURACIÓN DE RATES (NUEVO)
        "BtnRates"                = "Configurar Rates"
        "TituloRates"             = "Configuracion de Rates"
        "TituloBuscarConf"        = "Selecciona el archivo worldserver.conf"
        "MsgConfNoEncontrado"     = "No se pudo localizar el archivo worldserver.conf."
        "GrpSkill"                = "Habilidades (Skill)"
        "GrpReputacion"           = "Reputacion"
        "GrpExperiencia"          = "Experiencia (XP)"
        "GrpGuild"                = "Hermandad (Guild)"
        "LblMaxPrimaryTradeSkill" = "Max. profesiones primarias:"
        "LblSkillCrafting"        = "Ganancia de Crafteo:"
        "LblSkillDefense"         = "Ganancia de Defensa:"
        "LblSkillGathering"       = "Ganancia de Recoleccion:"
        "LblSkillWeapon"          = "Ganancia de Armas:"
        "LblRepGain"              = "Ganancia de Reputacion:"
        "LblXPKill"               = "XP por Matar:"
        "LblXPQuest"              = "XP por Mision:"
        "LblXPQuestDF"            = "XP por Mision (LFG):"
        "LblXPExplore"            = "XP por Explorar:"
        "LblMinPetitionSigns"     = "Firmas min. para peticion:"
        "BtnGuardarRates"         = "Guardar Rates"
        "MsgRatesGuardado"        = "Rates guardados correctamente en el archivo de configuracion!"
        "MsgRatesError"           = "Error al guardar los rates."

        # SUBMÓDULO: RUTAS DE VUELO (NUEVO)
        "GrpVuelos"               = "Rutas de Vuelo"
        "LblAllFlightPaths"       = "Todas las Rutas de Vuelo:"
        "DescAllFlightPaths"      = "0 = Desactivado. 1 = Activado (todas las rutas de vuelo disponibles desde el principio)."
        "LblInstantFlightPaths"   = "Vuelos Instantaneos:"
        "DescInstantFlightPaths"  = "0 = Desactivado. 1 = Activado (vuelo instantaneo). 2 = El jugador elige en el juego si vuela o se teletransporta al destino."

        # SUBMÓDULO: CRIATURAS (NUEVO)
        "GrpCriaturas"            = "Criaturas"
        "ColNormal"               = "Normal"
        "ColElite"                = "Elite"
        "ColRara"                 = "Rara"
        "ColRareElite"            = "R.Elite"
        "ColJefe"                 = "Jefe"
        "LblCreatureDamage"       = "Dano:"
        "LblCreatureSpellDamage"  = "Dano Magico:"
        "LblCreatureHP"           = "Vida:"
        "DescCriaturas"           = "1 = valor por defecto (normal). Cuanto mayor el numero, mayor la dificultad (ej: 5). Admite decimales (ej: 0.75)."

        # SUBMÓDULO: PLAYERBOTS
        "GrpPlayerbots"               = "Playerbots (poblacion)"
        "DescPlayerbotsArchivo"       = "Archivo:"
        "MsgPlayerbotsNoEncontrado"   = "No se encontro Playerbots.conf (mod no instalado o ruta distinta)."
        "LblMinRandomBots"            = "Min. bots en el mundo:"
        "LblMaxRandomBots"            = "Max. bots en el mundo:"
        "LblRandomBotMinLevel"        = "Nivel minimo bots:"
        "LblRandomBotMaxLevel"        = "Nivel maximo bots:"
        "LblDeleteRandomBotAccounts"  = "Borrar cuentas bots (0/1):"
        "DescDeleteRandomBotAccounts" = "Borrar cuentas: 0 = desactivado, 1 = activado (reinicio de poblacion)."
        "MsgPlayerbotsGuardado"       = "Playerbots.conf tambien actualizado."

        # MÓDULO DE ARMERÍA (NUEVO)
        "BtnArmeria"                 = "Armeria de Personajes"
        "TituloArmeria"              = "Armeria de Personajes"
        "LblNombrePersonajeArmeria"  = "Nombre del personaje:"
        "LblBaseDatosPersonajes"     = "Base de datos de personajes:"
        "LblNivel"                   = "Nivel:"
        "LblRaza"                    = "Raza:"
        "LblClase"                   = "Clase:"
        "LblGuildArmeria"            = "Hermandad:"
        "LblHonor"                   = "Honor:"
        "LblArena"                   = "Puntos de Arena:"
        "LblOro"                     = "Oro:"
        "LblEquipo"                  = "Equipo:"
        "LblSlotVacio"               = "(vacio)"
        "MsgBuscandoArmeria"         = "Buscando..."
        "MsgErrorConsultaArmeria"    = "No se pudo consultar la base de datos. Revisa las credenciales de MySQL, el nombre de la base de datos y que el servicio MySQL este encendido."

        # TEXTOS INTERFAZ ARMERÍA
        "TituloVentanaArmeria"       = "Armeria de Personajes"
        "TituloEstadisticas"         = "Estadisticas"
        "LblNombrePersonajeArmeria2" = "Nombre del personaje:"
        "LblPvp"                     = "PvP"
        "LblProfesiones"             = "Profesiones"
        "LblBuscando"                = "Buscando..."
        "LblCargandoIconos"          = "Cargando iconos y stats..."
        "LblKills"                   = "Kills:"
        "LblNivelRazaClase"          = "Nivel {0}  ·  {1}  ·  {2}"
        "LblIconosCargados"          = "Iconos: {0}  |  Desde cache: {1}"
        "LblSinProfesiones"          = "Sin profesiones"
        "LblHabilidadesArmas"        = "── Habilidades de armas ──"
        "LblSinStats"                = "Sin datos de estadisticas.`r`n`r`nPara activarlas edita worldserver.conf y cambia:`r`nPlayerSave.Stats.MinLevel = 0`r`na:`r`nPlayerSave.Stats.MinLevel = 1`r`n`r`nDespues conectate con el personaje al menos una vez."
        "LblStatsCache"              = "Personaje (cache)"
        "LblStatsOnline"             = "Personaje"
        "LblVidaMax"                 = "Vida maxima"
        "LblManaMax"                 = "Mana/Poder"
        "LblFuerza"                  = "Fuerza"
        "LblAgilidad"                = "Agilidad"
        "LblAguante"                 = "Aguante"
        "LblIntelecto"               = "Intelecto"
        "LblEspiritu"                = "Espiritu"
        "LblArmadura"                = "Armadura"
        "LblPoderAtaque"             = "Poder de ataque"
        "LblPADistancia"             = "PA distancia"
        "LblPoderHechizos"           = "Poder hechizos"
        "LblCriticoCC"               = "Critico C/C"
        "LblCriticoDistancia"        = "Critico distancia"
        "LblCriticoHechizo"          = "Critico hechizo"
        "LblSeccionCombate"          = "Combate"
        "LblSeccionDefensa"          = "Defensa"
        "LblSeccionEquipo"           = "Equipo"
        "LblSeccionOtros"            = "Otros"
        "LblSeccionAtributos"        = "Atributos"
        "LblSeccionResistencias"     = "Resistencias"
        "LblEsquiva"                 = "Esquiva"
        "LblParada"                  = "Parada"
        "LblBloqueo"                 = "Bloqueo"
        "LblResiliencia"             = "Resiliencia"
        "LbliLvlMedio"               = "iLvl medio"
        "LblDesdeCache"              = "Desde cache:"
    }
    "EN" = @{
        "Titulo"       = "SERVER CONTROL PANEL"
        "BtnIniciar"   = "Start"
        "BtnApagar"    = "Stop"
        "BtnWow"       = "Launch Game"
        "BtnStartAll"  = "START ALL"
        "BtnStopAll"   = "STOP ALL"
        "BtnConfig"    = "Change Paths"
        "StatusWait"   = "Waiting for actions..."
        "StatusStartM" = "[1/3] Starting MySQL..."
        "StatusStartA" = "[2/3] Starting AuthServer..."
        "StatusStartW" = "[3/3] Starting WorldServer..."
        "StatusStopW"  = "[1/3] Stopping WorldServer..."
        "StatusStopA" = "[2/3] Stopping AuthServer..."
        "StatusStopM"  = "[3/3] Stopping MySQL..."
        "DbWait"       = "Waiting for Database to load..."
        "AuthWait"     = "Waiting for AuthServer to be ready..."
        "WorldWait"    = "Environment launched successfully."
        "AllStarted"   = "All services started!"
        "AllStopped"   = "Environment safely stopped!"
        "Myson"        = "Stopping MySQL gracefully..."
        "Mysfail"      = "Killing residual MySQL process..."
        "MsgMysqlCierreForzado2" = "The clean MySQL shutdown (mysqladmin -u{0} shutdown) didn't finish in time, so the process had to be force-killed (this was not a clean shutdown)."
        "MsgMysqlShutdownDetalle" = "mysqladmin message:"
        "MsgMysqlShutdownDetalle2" = "SQL SHUTDOWN message:"
        "TituloAviso"  = "Warning"
        "CtrlC"        = "Sending Ctrl+C to"
        "Listo"        = "Done."
        "ConfigIn"     = "Missing configuration paths. Wizard will open."
        "ConfigSave"   = "Paths saved successfully."
        "ConfigCancel" = "Incomplete configuration. Panel will close."
        
        # ACCOUNT MODULE
        "BtnCuentas"   = "Accounts & Ranks"
        "GrpCrear"     = "Create New Account"
        "GrpGM"        = "Convert Account to GM"
        "LblUsuario"   = "Username:"
        "LblPassword"  = "Password:"
        "BtnAccion"    = "Create"
        "MsgNoWorld"   = "Error! WorldServer must be online to execute commands."
        "MsgCreada"    = "Account created successfully!"
        "MsgGMOK"      = "GM level 3 rank assigned successfully!"

        # CHARACTER MODULE (NEW)
        "BtnPersonajes"   = "Characters (Pdump)"
        "GrpSalvar"       = "Save Character"
        "GrpCargar"       = "Load Saved Character"
        "LblTxtPjSalvar"  = "Character name to save:"
        "LblTxtFile"      = "File name:"
        "LblTxtAccCargar" = "Account name:"
        "BtnSalvar"       = "Save"
        "BtnCargar"       = "Load"
        "MsgFileExists"   = "Error! A file with that name already exists in the server folder."
        "MsgCargarAviso"  = "Warning! The saved file from the old server must be placed inside the new server directory (WorldServer folder) beforehand."
        "MsgDumpOK"       = "Dump command (pdump write) successfully executed!"
        "MsgLoadOK"       = "Load command (pdump load) successfully executed!"

                # GUILD SUBMODULE (SIMPLIFIED SQL SYSTEM)
        "GrpHermandad"            = "Guild"
        "MsgGuildInfoBoton"       = "Export or inject a full guild (members, bank, items and money) via generated SQL, with ID markers you can substitute yourself."
        "BtnAbrirHermandadSQL"    = "Open Guild (SQL)"
        "TituloHermandadSQL"      = "Guild: Generate / Inject SQL"
        "LblNombreGuildExportar"  = "Guild to export:"
        "BtnGenerarSql"           = "Generate SQL"
        "BtnGuardarHermandadDirecto" = "Save Guild (generate + save .sql)"
        "MsgFaltaNombreGuild"     = "Type the guild name first."
        "BtnAbrirSqlGuardado"     = "Open saved .sql..."
        "LblIdGuildNuevo"         = "New Guild ID:"
        "BtnAuto"                 = "Auto"
        "LblGmNombreExistente"    = "GM name (already loaded here):"
        "LblGmGuidCampo"          = "GUID:"
        "BtnBuscar"               = "Search"
        "LblItemBase"             = "Base GUID for bank items:"
        "MsgAvisoHermandadSQL"    = "The GM's character must already exist on this server. RECOMMENDED: stop the WorldServer before clicking 'Inject' (avoids item GUID clashes with what the server reserves in memory while running) and start it again afterwards."
        "BtnAplicarIds"           = "Apply IDs to text"
        "BtnGuardarSqlArchivo"    = "Save current text to .sql"
        "BtnInyectarSql"          = "Inject on this server"
        "BtnVerificarSql"         = "Verify guild"
        "BtnAyudaHermandad"       = "How does this work? (Help)"
        "TituloAyudaHermandad"    = "Help: how to export a guild"
        "MsgAyudaHermandadTexto"  = @"
HOW TO MIGRATE A GUILD TO ANOTHER SERVER
============================================

STEPS TO FOLLOW:


===== ON THE OLD SERVER =====

1. Save Character
   Save your character (the guild's GM) from
   Characters > Save Character.

2. Save your Guild
   Go to Guild, type the name and click the
   "Save Guild (generate + save .sql)" button.


>>> Once these 2 steps are done, copy THE GENERATED FILES     <<<
>>> to the folder where the WorldServer of the NEW server is. <<<


===== ON THE NEW SERVER =====

3. Load Character
   Load your character on the new server.

4. Check the character
   Log into the game and check it loaded fine. It may ask
   you to change its name (if another one already exists on
   this server); that's normal, go ahead and do it.

5. Stop the WorldServer.

6. Load your Guild
   Click the "Open saved .sql..." button and pick the file.

7. Fill in the fields:
     - GM name  ->  "Search" button (fills in their GUID by itself)
     - New Guild ID  ->  "Auto" button
     - Base GUID for bank items  ->  "Auto" button

8. Click "Apply IDs to text".

9. Click "Inject on this server" (this saves the guild).

10. Start the WorldServer and, once it's loaded, launch the game.


THE END


NOTES:

- Only the GM is exported as a member. Everyone else will need
  to rejoin the guild in-game.
- You can use "Verify guild" at any time to check that the GM is
  properly linked, without changing anything.
"@
        "MsgSqlGuardadoOK"        = "Saved as '{0}' in the WorldServer folder."
        "MsgAvisoGuardarModificado" = "This text already has the IDs applied (the @@...@@ markers are gone). Saving it like this will overwrite the file with this version, and you won't be able to apply different IDs to it later. If you want to keep the original for reuse on another server, click 'Generate SQL' again before saving. Continue and save as it is now?"
        "MsgFaltaAplicarIds"      = "The text still has @@...@@ markers unreplaced. Click 'Apply IDs to text' first."
        "MsgConfirmarInyectar"    = "This will execute the SQL directly on this server's database. It's recommended to have the WorldServer STOPPED while doing this, to avoid GUID clashes with items the server creates in memory while running. Continue?"
        "MsgInyectadoOK"          = "Guild injected successfully. Restart the WorldServer so the game loads it."
        "MsgGuildError"           = "Error processing the guild."
        "MsgPersonajeNoEncontrado" = "No character with that name was found on this server."
        "TituloListaGuildDumps"   = "Saved guild backups"
        "MsgNoGuildDumps"         = "No guild backups were found in that folder."

        # HD CLIENT DOWNLOAD MODULE (NEW)
        "BtnDescargarHD"    = "Download HD Client and Server"
        "BtnCredencialesMysql"   = "MySQL Credentials (username / password)"
        "BtnMods"                = "Mods"
        "TituloSeleccionarMods"  = "Select the Mods folder"
        "MsgModsCarpetaNoExiste" = "The configured Mods folder no longer exists. Click the button again to select it."
        "TituloCredencialesMysql" = "MySQL Credentials"
        "GrpMysqlApp"       = "Application user (guilds, characters...)"
        "GrpMysqlAdmin"     = "Admin user (shutting down MySQL, permissions)"
        "LblContrasena"     = "Password:"
        "ChkVerContrasenas" = "Show passwords"
        "MsgAvisoCredencialesMysql" = "The admin user needs the SHUTDOWN privilege to be able to cleanly shut down MySQL. This data is saved only on this computer, in config_server.txt."
        "BtnGuardar"        = "Save"
        "MsgCredencialesGuardadas" = "Credentials saved successfully."
        "LblSeparadorNPCBots" = "NPCBOTS"
        "BtnNPCBots"        = "NPCBots Generator"
        "MsgAvisoNPCBots"   = "MANDATORY NOTICE: this generator only works on AzerothCore servers that have the NPCBots module (mod-npcbots) installed. If your server does NOT have it installed, the generated SQL will be useless and may cause errors when injected. Do you want to open the generator?"
        "MsgNPCBotsNoEncontrado" = "NPCBotsGenerator.html was not found in the Scripts folder."
        "BtnInyectarSqlPrincipal" = "Inject SQL"
        "TituloInyectarSQL"      = "Inject SQL"
        "LblBaseDatos"           = "Target database:"
        "MsgAvisoNPCBotsDB"      = "Note: the SQL from the NPCBots Generator usually goes into 'acore_world' (creature_template and similar)."
        "BtnPegarPortapapeles"   = "Paste from clipboard"
        "BtnCargarSqlArchivo"    = "Load SQL..."
        "TituloCargarSqlArchivo" = "Select a SQL file"
        "MsgErrorLeerArchivo"    = "Could not read the selected file."
        "BtnLimpiar"             = "Clear"
        "BtnFormatearSql"        = "Format SQL"
        "MsgFaltaBaseDatos"      = "Enter a target database."
        "MsgConfirmarInyectarGenerico" = "This will execute the SQL directly on the '{0}' database of this server. Continue?"
        "MsgInyectadoOKGenerico" = "SQL injected successfully."
        "MsgAvisoInyectarSql"    = "Always review the SQL before injecting it: it runs as-is, with no additional checks."
        "TituloDescargarHD" = "Download HD Client"
        "MsgDescargarInfo"  = "Choose the part you want to download:"
        "LblParte1"         = "Part 1"
        "LblParte2"         = "Part 2"
        "LblParte3"         = "Part 3"
        "TituloServidor"    = "Server"
        "LblServidor"       = "Download Server"
        "BtnCerrar"         = "Close"

        # RATES CONFIGURATION MODULE (NEW)
        "BtnRates"                = "Config Rates"
        "TituloRates"             = "Rates Configuration"
        "TituloBuscarConf"        = "Select the worldserver.conf file"
        "MsgConfNoEncontrado"     = "Could not locate the worldserver.conf file."
        "GrpSkill"                = "Skill"
        "GrpReputacion"           = "Reputation"
        "GrpExperiencia"          = "Experience (XP)"
        "GrpGuild"                = "Guild"
        "LblMaxPrimaryTradeSkill" = "Max. primary trade skills:"
        "LblSkillCrafting"        = "Crafting skill gain:"
        "LblSkillDefense"         = "Defense skill gain:"
        "LblSkillGathering"       = "Gathering skill gain:"
        "LblSkillWeapon"          = "Weapon skill gain:"
        "LblRepGain"              = "Reputation gain:"
        "LblXPKill"               = "XP from kills:"
        "LblXPQuest"              = "XP from quests:"
        "LblXPQuestDF"            = "XP from quests (LFG):"
        "LblXPExplore"            = "XP from exploring:"
        "LblMinPetitionSigns"     = "Min. signatures for petition:"
        "BtnGuardarRates"         = "Save Rates"
        "MsgRatesGuardado"        = "Rates saved successfully to the configuration file!"
        "MsgRatesError"           = "Error saving the rates."

        # FLIGHT PATHS SUBMODULE (NEW)
        "GrpVuelos"               = "Flight Paths"
        "LblAllFlightPaths"       = "All Flight Paths:"
        "DescAllFlightPaths"      = "0 = Disabled. 1 = Enabled (all flight paths available from the start)."
        "LblInstantFlightPaths"   = "Instant Flight Paths:"
        "DescInstantFlightPaths"  = "0 = Disabled. 1 = Enabled (instant flight). 2 = The player chooses in-game whether to fly or teleport to the destination."

        # CREATURES SUBMODULE (NEW)
        "GrpCriaturas"            = "Creatures"
        "ColNormal"               = "Normal"
        "ColElite"                = "Elite"
        "ColRara"                 = "Rare"
        "ColRareElite"            = "R.Elite"
        "ColJefe"                 = "Boss"
        "LblCreatureDamage"       = "Damage:"
        "LblCreatureSpellDamage"  = "Spell Damage:"
        "LblCreatureHP"           = "Health:"
        "DescCriaturas"           = "1 = default value (normal). The higher the number, the harder the difficulty (e.g. 5). Decimals are allowed (e.g. 0.75)."

        # SUBMODULE: PLAYERBOTS
        "GrpPlayerbots"               = "Playerbots (population)"
        "DescPlayerbotsArchivo"       = "File:"
        "MsgPlayerbotsNoEncontrado"   = "Playerbots.conf not found (mod not installed or different path)."
        "LblMinRandomBots"            = "Min. bots in world:"
        "LblMaxRandomBots"            = "Max. bots in world:"
        "LblRandomBotMinLevel"        = "Min. bot level:"
        "LblRandomBotMaxLevel"        = "Max. bot level:"
        "LblDeleteRandomBotAccounts"  = "Delete bot accounts (0/1):"
        "DescDeleteRandomBotAccounts" = "Delete accounts: 0 = disabled, 1 = enabled (population reset)."
        "MsgPlayerbotsGuardado"       = "Playerbots.conf also updated."

        # CHARACTER ARMORY MODULE (NEW)
        "BtnArmeria"                 = "Character Armory"
        "TituloArmeria"              = "Character Armory"
        "LblNombrePersonajeArmeria"  = "Character name:"
        "LblBaseDatosPersonajes"     = "Characters database:"
        "LblNivel"                   = "Level:"
        "LblRaza"                    = "Race:"
        "LblClase"                   = "Class:"
        "LblGuildArmeria"            = "Guild:"
        "LblHonor"                   = "Honor:"
        "LblArena"                   = "Arena Points:"
        "LblOro"                     = "Gold:"
        "LblEquipo"                  = "Equipment:"
        "LblSlotVacio"               = "(empty)"
        "MsgBuscandoArmeria"         = "Searching..."
        "MsgErrorConsultaArmeria"    = "Could not query the database. Check the MySQL credentials, the database name, and that the MySQL service is running."

        # ARMORY INTERFACE TEXTS
        "TituloVentanaArmeria"       = "Character Armory"
        "TituloEstadisticas"         = "Statistics"
        "LblNombrePersonajeArmeria2" = "Character name:"
        "LblPvp"                     = "PvP"
        "LblProfesiones"             = "Professions"
        "LblBuscando"                = "Searching..."
        "LblCargandoIconos"          = "Loading icons and stats..."
        "LblKills"                   = "Kills:"
        "LblNivelRazaClase"          = "Level {0}  ·  {1}  ·  {2}"
        "LblIconosCargados"          = "Icons: {0}  |  From cache: {1}"
        "LblSinProfesiones"          = "No professions"
        "LblHabilidadesArmas"        = "── Weapon skills ──"
        "LblSinStats"                = "No stats available.`r`n`r`nTo enable them edit worldserver.conf and change:`r`nPlayerSave.Stats.MinLevel = 0`r`nto:`r`nPlayerSave.Stats.MinLevel = 1`r`n`r`nThen log in with the character at least once."
        "LblStatsCache"              = "Character (cached)"
        "LblStatsOnline"             = "Character"
        "LblVidaMax"                 = "Max health"
        "LblManaMax"                 = "Mana/Power"
        "LblFuerza"                  = "Strength"
        "LblAgilidad"                = "Agility"
        "LblAguante"                 = "Stamina"
        "LblIntelecto"               = "Intellect"
        "LblEspiritu"                = "Spirit"
        "LblArmadura"                = "Armor"
        "LblPoderAtaque"             = "Attack power"
        "LblPADistancia"             = "Ranged AP"
        "LblPoderHechizos"           = "Spell power"
        "LblCriticoCC"               = "Melee crit"
        "LblCriticoDistancia"        = "Ranged crit"
        "LblCriticoHechizo"          = "Spell crit"
        "LblSeccionCombate"          = "Combat"
        "LblSeccionDefensa"          = "Defense"
        "LblSeccionEquipo"           = "Equipment"
        "LblSeccionOtros"            = "Other"
        "LblSeccionAtributos"        = "Attributes"
        "LblSeccionResistencias"     = "Resistances"
        "LblEsquiva"                 = "Dodge"
        "LblParada"                  = "Parry"
        "LblBloqueo"                 = "Block"
        "LblResiliencia"             = "Resilience"
        "LbliLvlMedio"               = "Avg iLvl"
        "LblDesdeCache"              = "From cache:"
    }
}