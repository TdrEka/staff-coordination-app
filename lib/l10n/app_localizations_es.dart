// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get navHome => 'Inicio';

  @override
  String get navEmployees => 'Personal';

  @override
  String get navEvents => 'Eventos';

  @override
  String get navCalendar => 'Calendario';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get edit => 'Editar';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get seeAll => 'Ver todo';

  @override
  String get warning => 'Atención';

  @override
  String get error => 'Error';

  @override
  String get confirmDeleteTitle => '¿Eliminar?';

  @override
  String get confirmDeleteMessage => 'Esta acción no se puede deshacer.';

  @override
  String get importWarningTitle => '¿Importar copia de seguridad?';

  @override
  String get importWarningMessage =>
      'Esto reemplazará todos los datos actuales. Esta acción no se puede deshacer.';

  @override
  String importSummary(int employees, int events, int shiftLogs) {
    return 'La copia contiene $employees personas, $events eventos y $shiftLogs registros. ¿Continuar?';
  }

  @override
  String get validationRequired => 'Este campo es obligatorio';

  @override
  String get validationNameLength =>
      'El nombre debe tener entre 2 y 80 caracteres';

  @override
  String get validationPhoneFormat => 'Introduce un número de teléfono válido';

  @override
  String get validationScoreRange =>
      'La puntuación debe estar entre 0.0 y 10.0';

  @override
  String get validationTimeOrder =>
      'La hora de fin debe ser posterior a la de inicio';

  @override
  String get validationCallTimeOrder =>
      'La hora de llegada debe ser anterior a la de inicio';

  @override
  String get validationPastDateWarning =>
      'La fecha es anterior a hoy — ¿seguro?';

  @override
  String get homeTitle => 'Inicio';

  @override
  String get homeTodayEvents => 'Eventos de hoy';

  @override
  String get homeThisWeek => 'Esta semana';

  @override
  String get homeAddEvent => 'Añadir evento';

  @override
  String get homeFindStaff => 'Buscar personal disponible';

  @override
  String get homeNoEventsToday => 'Nada por hoy — a descansar';

  @override
  String get homeOverdueShiftLogs => 'Registros de turno pendientes';

  @override
  String get homeLogShifts => 'Registrar turnos';

  @override
  String get homeBackupReminder =>
      '💾 Hace tiempo que no haces copia de seguridad';

  @override
  String get employeesTitle => 'Personal';

  @override
  String get employeesAdd => 'Añadir persona';

  @override
  String get employeesActive => 'Activos';

  @override
  String get employeesInactive => 'Archivo';

  @override
  String get employeesEmpty =>
      'Aún no hay personal — añade a la primera persona';

  @override
  String get employeesName => 'Nombre completo';

  @override
  String get employeesPhone => 'Teléfono';

  @override
  String get employeesEmail => 'Email';

  @override
  String get employeesLocation => 'Localidad';

  @override
  String get employeesRoles => 'Funciones';

  @override
  String get employeesContractType => 'Tipo de contrato';

  @override
  String get employeesContractFreelance => 'Autónomo';

  @override
  String get employeesContractStaff => 'Plantilla';

  @override
  String get employeesContractAgency => 'Agencia';

  @override
  String get employeesPreferredContact => 'Contacto preferido';

  @override
  String get employeesAvailability => 'Disponibilidad';

  @override
  String get employeesReliabilityScore => 'Puntuación de fiabilidad';

  @override
  String get employeesNotes => 'Notas';

  @override
  String get employeesHourlyRate => 'Tarifa por hora';

  @override
  String get employeesDeactivate => 'Desactivar';

  @override
  String get employeesReactivate => 'Reactivar';

  @override
  String get employeesShiftHistory => 'Historial de turnos';

  @override
  String get employeesAdjustScore => 'Ajustar puntuación';

  @override
  String get employeesStatusActive => 'Activo';

  @override
  String get employeesStatusInactive => 'Inactivo';

  @override
  String get eventsTitle => 'Eventos';

  @override
  String get eventsAdd => 'Añadir evento';

  @override
  String get eventsUpcoming => 'Próximos';

  @override
  String get eventsPast => 'Pasados';

  @override
  String get eventsEmpty => 'Aún no hay eventos — añade el primero';

  @override
  String get eventsName => 'Nombre del evento';

  @override
  String get eventsDate => 'Fecha';

  @override
  String get eventsStartTime => 'Hora de inicio';

  @override
  String get eventsEndTime => 'Hora de fin';

  @override
  String get eventsCallTime => 'Hora de llegada del personal';

  @override
  String get eventsVenue => 'Lugar';

  @override
  String get eventsAddress => 'Dirección';

  @override
  String get eventsParkingNotes => 'Notas de aparcamiento';

  @override
  String get eventsAccessNotes => 'Instrucciones de acceso';

  @override
  String get eventsClient => 'Cliente';

  @override
  String get eventsClientContact => 'Contacto del cliente en el evento';

  @override
  String get eventsType => 'Tipo de evento';

  @override
  String get eventsTypeWedding => 'Boda';

  @override
  String get eventsTypeCorporate => 'Corporativo';

  @override
  String get eventsTypePrivateDinner => 'Cena privada';

  @override
  String get eventsTypeOther => 'Otro';

  @override
  String get eventsDresscode => 'Código de vestimenta';

  @override
  String get eventsStatusDraft => 'Borrador';

  @override
  String get eventsStatusConfirmed => 'Confirmado';

  @override
  String get eventsStatusCompleted => 'Completado';

  @override
  String get eventsStatusCancelled => 'Cancelado';

  @override
  String get eventsInternalNotes => 'Notas internas';

  @override
  String get eventsExportNotes => 'Notas para exportar';

  @override
  String get eventsPayRate => 'Tarifa de referencia';

  @override
  String get eventsRoleSlots => 'Puestos';

  @override
  String get eventsAddSlot => 'Añadir puesto';

  @override
  String get eventsUncoveredCritical => '⚠ Puestos críticos sin cubrir';

  @override
  String get eventsExportRoster => 'Exportar lista';

  @override
  String get slotRole => 'Función';

  @override
  String get slotUnassigned => 'Sin asignar';

  @override
  String get slotStatusConfirmed => 'Confirmado';

  @override
  String get slotStatusPending => 'Pendiente';

  @override
  String get slotStatusUncovered => 'Sin cubrir';

  @override
  String get slotPriorityCritical => 'Crítico';

  @override
  String get slotPriorityNormal => 'Normal';

  @override
  String get slotAssign => 'Asignar';

  @override
  String get slotConfirm => 'Confirmar';

  @override
  String get slotRemoveAssignment => 'Quitar asignación';

  @override
  String get availabilityTitle => '¿Quién está disponible?';

  @override
  String get availabilityDate => 'Fecha';

  @override
  String get availabilityTimeRange => 'Franja horaria';

  @override
  String get availabilityRole => 'Función (opcional)';

  @override
  String get availabilitySearch => 'Buscar';

  @override
  String get availabilityEmpty => 'Nadie encaja con estos criterios';

  @override
  String get availabilityConflict => 'Posible conflicto';

  @override
  String availabilityConflictMessage(String name) {
    return '$name puede que ya esté trabajando ese día. ¿Asignar igualmente?';
  }

  @override
  String get calendarTitle => 'Calendario';

  @override
  String get calendarNoEvents => 'Sin eventos este día';

  @override
  String get calendarAddEvent => 'Añadir evento';

  @override
  String get shiftLogTitle => 'Registrar turnos';

  @override
  String get shiftLogHistory => 'Historial';

  @override
  String get shiftLogOutcomeShowedUp => 'Asistió';

  @override
  String get shiftLogOutcomeLate => 'Llegó tarde';

  @override
  String get shiftLogOutcomeNoShow => 'No se presentó';

  @override
  String get shiftLogOutcomeCancelledAdvance => 'Canceló con antelación';

  @override
  String get shiftLogMinutesLate => 'Minutos de retraso';

  @override
  String get shiftLogAdvanceNotice => 'Con más de 48h de antelación';

  @override
  String get shiftLogNotes => 'Notas';

  @override
  String get shiftLogAll => 'Registrar todos';

  @override
  String get shiftLogOverrideReason => 'Motivo del ajuste (obligatorio)';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsNotificationToggle =>
      'Recordatorio 48h antes de eventos con puestos sin cubrir';

  @override
  String get settingsReliabilityReset =>
      'Restablecer todas las puntuaciones a 5.0';

  @override
  String get settingsExport => 'Exportar datos';

  @override
  String get settingsImport => 'Importar datos';

  @override
  String get settingsClearData => 'Borrar todos los datos';

  @override
  String get settingsAbout => 'Acerca de';

  @override
  String get settingsResetScoresConfirm =>
      '¿Restablecer todas las puntuaciones a 5.0? Esta acción no se puede deshacer.';

  @override
  String get monday => 'Lunes';

  @override
  String get tuesday => 'Martes';

  @override
  String get wednesday => 'Miércoles';

  @override
  String get thursday => 'Jueves';

  @override
  String get friday => 'Viernes';

  @override
  String get saturday => 'Sábado';

  @override
  String get sunday => 'Domingo';
}
