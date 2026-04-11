import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('es')];

  /// No description provided for @navHome.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get navHome;

  /// No description provided for @navEmployees.
  ///
  /// In es, this message translates to:
  /// **'Personal'**
  String get navEmployees;

  /// No description provided for @navEvents.
  ///
  /// In es, this message translates to:
  /// **'Eventos'**
  String get navEvents;

  /// No description provided for @navCalendar.
  ///
  /// In es, this message translates to:
  /// **'Calendario'**
  String get navCalendar;

  /// No description provided for @navSettings.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get navSettings;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get confirm;

  /// No description provided for @edit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get edit;

  /// No description provided for @yes.
  ///
  /// In es, this message translates to:
  /// **'Sí'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In es, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @seeAll.
  ///
  /// In es, this message translates to:
  /// **'Ver todo'**
  String get seeAll;

  /// No description provided for @warning.
  ///
  /// In es, this message translates to:
  /// **'Atención'**
  String get warning;

  /// No description provided for @error.
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @confirmDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar?'**
  String get confirmDeleteTitle;

  /// No description provided for @confirmDeleteMessage.
  ///
  /// In es, this message translates to:
  /// **'Esta acción no se puede deshacer.'**
  String get confirmDeleteMessage;

  /// No description provided for @importWarningTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Importar copia de seguridad?'**
  String get importWarningTitle;

  /// No description provided for @importWarningMessage.
  ///
  /// In es, this message translates to:
  /// **'Esto reemplazará todos los datos actuales. Esta acción no se puede deshacer.'**
  String get importWarningMessage;

  /// No description provided for @importSummary.
  ///
  /// In es, this message translates to:
  /// **'La copia contiene {employees} personas, {events} eventos y {shiftLogs} registros. ¿Continuar?'**
  String importSummary(int employees, int events, int shiftLogs);

  /// No description provided for @validationRequired.
  ///
  /// In es, this message translates to:
  /// **'Este campo es obligatorio'**
  String get validationRequired;

  /// No description provided for @validationNameLength.
  ///
  /// In es, this message translates to:
  /// **'El nombre debe tener entre 2 y 80 caracteres'**
  String get validationNameLength;

  /// No description provided for @validationPhoneFormat.
  ///
  /// In es, this message translates to:
  /// **'Introduce un número de teléfono válido'**
  String get validationPhoneFormat;

  /// No description provided for @validationScoreRange.
  ///
  /// In es, this message translates to:
  /// **'La puntuación debe estar entre 0.0 y 10.0'**
  String get validationScoreRange;

  /// No description provided for @validationTimeOrder.
  ///
  /// In es, this message translates to:
  /// **'La hora de fin debe ser posterior a la de inicio'**
  String get validationTimeOrder;

  /// No description provided for @validationCallTimeOrder.
  ///
  /// In es, this message translates to:
  /// **'La hora de llegada debe ser anterior a la de inicio'**
  String get validationCallTimeOrder;

  /// No description provided for @validationPastDateWarning.
  ///
  /// In es, this message translates to:
  /// **'La fecha es anterior a hoy — ¿seguro?'**
  String get validationPastDateWarning;

  /// No description provided for @homeTitle.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get homeTitle;

  /// No description provided for @homeTodayEvents.
  ///
  /// In es, this message translates to:
  /// **'Eventos de hoy'**
  String get homeTodayEvents;

  /// No description provided for @homeThisWeek.
  ///
  /// In es, this message translates to:
  /// **'Esta semana'**
  String get homeThisWeek;

  /// No description provided for @homeAddEvent.
  ///
  /// In es, this message translates to:
  /// **'Añadir evento'**
  String get homeAddEvent;

  /// No description provided for @homeFindStaff.
  ///
  /// In es, this message translates to:
  /// **'Buscar personal disponible'**
  String get homeFindStaff;

  /// No description provided for @homeNoEventsToday.
  ///
  /// In es, this message translates to:
  /// **'Nada por hoy — a descansar'**
  String get homeNoEventsToday;

  /// No description provided for @homeOverdueShiftLogs.
  ///
  /// In es, this message translates to:
  /// **'Registros de turno pendientes'**
  String get homeOverdueShiftLogs;

  /// No description provided for @homeLogShifts.
  ///
  /// In es, this message translates to:
  /// **'Registrar turnos'**
  String get homeLogShifts;

  /// No description provided for @homeBackupReminder.
  ///
  /// In es, this message translates to:
  /// **'💾 Hace tiempo que no haces copia de seguridad'**
  String get homeBackupReminder;

  /// No description provided for @employeesTitle.
  ///
  /// In es, this message translates to:
  /// **'Personal'**
  String get employeesTitle;

  /// No description provided for @employeesAdd.
  ///
  /// In es, this message translates to:
  /// **'Añadir persona'**
  String get employeesAdd;

  /// No description provided for @employeesActive.
  ///
  /// In es, this message translates to:
  /// **'Activos'**
  String get employeesActive;

  /// No description provided for @employeesInactive.
  ///
  /// In es, this message translates to:
  /// **'Archivo'**
  String get employeesInactive;

  /// No description provided for @employeesEmpty.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay personal — añade a la primera persona'**
  String get employeesEmpty;

  /// No description provided for @employeesName.
  ///
  /// In es, this message translates to:
  /// **'Nombre completo'**
  String get employeesName;

  /// No description provided for @employeesPhone.
  ///
  /// In es, this message translates to:
  /// **'Teléfono'**
  String get employeesPhone;

  /// No description provided for @employeesEmail.
  ///
  /// In es, this message translates to:
  /// **'Email'**
  String get employeesEmail;

  /// No description provided for @employeesLocation.
  ///
  /// In es, this message translates to:
  /// **'Localidad'**
  String get employeesLocation;

  /// No description provided for @employeesRoles.
  ///
  /// In es, this message translates to:
  /// **'Funciones'**
  String get employeesRoles;

  /// No description provided for @employeesContractType.
  ///
  /// In es, this message translates to:
  /// **'Tipo de contrato'**
  String get employeesContractType;

  /// No description provided for @employeesContractFreelance.
  ///
  /// In es, this message translates to:
  /// **'Autónomo'**
  String get employeesContractFreelance;

  /// No description provided for @employeesContractStaff.
  ///
  /// In es, this message translates to:
  /// **'Plantilla'**
  String get employeesContractStaff;

  /// No description provided for @employeesContractAgency.
  ///
  /// In es, this message translates to:
  /// **'Agencia'**
  String get employeesContractAgency;

  /// No description provided for @employeesPreferredContact.
  ///
  /// In es, this message translates to:
  /// **'Contacto preferido'**
  String get employeesPreferredContact;

  /// No description provided for @employeesAvailability.
  ///
  /// In es, this message translates to:
  /// **'Disponibilidad'**
  String get employeesAvailability;

  /// No description provided for @employeesReliabilityScore.
  ///
  /// In es, this message translates to:
  /// **'Puntuación de fiabilidad'**
  String get employeesReliabilityScore;

  /// No description provided for @employeesNotes.
  ///
  /// In es, this message translates to:
  /// **'Notas'**
  String get employeesNotes;

  /// No description provided for @employeesHourlyRate.
  ///
  /// In es, this message translates to:
  /// **'Tarifa por hora'**
  String get employeesHourlyRate;

  /// No description provided for @employeesDeactivate.
  ///
  /// In es, this message translates to:
  /// **'Desactivar'**
  String get employeesDeactivate;

  /// No description provided for @employeesReactivate.
  ///
  /// In es, this message translates to:
  /// **'Reactivar'**
  String get employeesReactivate;

  /// No description provided for @employeesShiftHistory.
  ///
  /// In es, this message translates to:
  /// **'Historial de turnos'**
  String get employeesShiftHistory;

  /// No description provided for @employeesAdjustScore.
  ///
  /// In es, this message translates to:
  /// **'Ajustar puntuación'**
  String get employeesAdjustScore;

  /// No description provided for @employeesStatusActive.
  ///
  /// In es, this message translates to:
  /// **'Activo'**
  String get employeesStatusActive;

  /// No description provided for @employeesStatusInactive.
  ///
  /// In es, this message translates to:
  /// **'Inactivo'**
  String get employeesStatusInactive;

  /// No description provided for @eventsTitle.
  ///
  /// In es, this message translates to:
  /// **'Eventos'**
  String get eventsTitle;

  /// No description provided for @eventsAdd.
  ///
  /// In es, this message translates to:
  /// **'Añadir evento'**
  String get eventsAdd;

  /// No description provided for @eventsUpcoming.
  ///
  /// In es, this message translates to:
  /// **'Próximos'**
  String get eventsUpcoming;

  /// No description provided for @eventsPast.
  ///
  /// In es, this message translates to:
  /// **'Pasados'**
  String get eventsPast;

  /// No description provided for @eventsEmpty.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay eventos — añade el primero'**
  String get eventsEmpty;

  /// No description provided for @eventsName.
  ///
  /// In es, this message translates to:
  /// **'Nombre del evento'**
  String get eventsName;

  /// No description provided for @eventsDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get eventsDate;

  /// No description provided for @eventsStartTime.
  ///
  /// In es, this message translates to:
  /// **'Hora de inicio'**
  String get eventsStartTime;

  /// No description provided for @eventsEndTime.
  ///
  /// In es, this message translates to:
  /// **'Hora de fin'**
  String get eventsEndTime;

  /// No description provided for @eventsCallTime.
  ///
  /// In es, this message translates to:
  /// **'Hora de llegada del personal'**
  String get eventsCallTime;

  /// No description provided for @eventsVenue.
  ///
  /// In es, this message translates to:
  /// **'Lugar'**
  String get eventsVenue;

  /// No description provided for @eventsAddress.
  ///
  /// In es, this message translates to:
  /// **'Dirección'**
  String get eventsAddress;

  /// No description provided for @eventsParkingNotes.
  ///
  /// In es, this message translates to:
  /// **'Notas de aparcamiento'**
  String get eventsParkingNotes;

  /// No description provided for @eventsAccessNotes.
  ///
  /// In es, this message translates to:
  /// **'Instrucciones de acceso'**
  String get eventsAccessNotes;

  /// No description provided for @eventsClient.
  ///
  /// In es, this message translates to:
  /// **'Cliente'**
  String get eventsClient;

  /// No description provided for @eventsClientContact.
  ///
  /// In es, this message translates to:
  /// **'Contacto del cliente en el evento'**
  String get eventsClientContact;

  /// No description provided for @eventsType.
  ///
  /// In es, this message translates to:
  /// **'Tipo de evento'**
  String get eventsType;

  /// No description provided for @eventsTypeWedding.
  ///
  /// In es, this message translates to:
  /// **'Boda'**
  String get eventsTypeWedding;

  /// No description provided for @eventsTypeCorporate.
  ///
  /// In es, this message translates to:
  /// **'Corporativo'**
  String get eventsTypeCorporate;

  /// No description provided for @eventsTypePrivateDinner.
  ///
  /// In es, this message translates to:
  /// **'Cena privada'**
  String get eventsTypePrivateDinner;

  /// No description provided for @eventsTypeOther.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get eventsTypeOther;

  /// No description provided for @eventsDresscode.
  ///
  /// In es, this message translates to:
  /// **'Código de vestimenta'**
  String get eventsDresscode;

  /// No description provided for @eventsStatusDraft.
  ///
  /// In es, this message translates to:
  /// **'Borrador'**
  String get eventsStatusDraft;

  /// No description provided for @eventsStatusConfirmed.
  ///
  /// In es, this message translates to:
  /// **'Confirmado'**
  String get eventsStatusConfirmed;

  /// No description provided for @eventsStatusCompleted.
  ///
  /// In es, this message translates to:
  /// **'Completado'**
  String get eventsStatusCompleted;

  /// No description provided for @eventsStatusCancelled.
  ///
  /// In es, this message translates to:
  /// **'Cancelado'**
  String get eventsStatusCancelled;

  /// No description provided for @eventsInternalNotes.
  ///
  /// In es, this message translates to:
  /// **'Notas internas'**
  String get eventsInternalNotes;

  /// No description provided for @eventsExportNotes.
  ///
  /// In es, this message translates to:
  /// **'Notas para exportar'**
  String get eventsExportNotes;

  /// No description provided for @eventsPayRate.
  ///
  /// In es, this message translates to:
  /// **'Tarifa de referencia'**
  String get eventsPayRate;

  /// No description provided for @eventsRoleSlots.
  ///
  /// In es, this message translates to:
  /// **'Puestos'**
  String get eventsRoleSlots;

  /// No description provided for @eventsAddSlot.
  ///
  /// In es, this message translates to:
  /// **'Añadir puesto'**
  String get eventsAddSlot;

  /// No description provided for @eventsUncoveredCritical.
  ///
  /// In es, this message translates to:
  /// **'⚠ Puestos críticos sin cubrir'**
  String get eventsUncoveredCritical;

  /// No description provided for @eventsExportRoster.
  ///
  /// In es, this message translates to:
  /// **'Exportar lista'**
  String get eventsExportRoster;

  /// No description provided for @slotRole.
  ///
  /// In es, this message translates to:
  /// **'Función'**
  String get slotRole;

  /// No description provided for @slotUnassigned.
  ///
  /// In es, this message translates to:
  /// **'Sin asignar'**
  String get slotUnassigned;

  /// No description provided for @slotStatusConfirmed.
  ///
  /// In es, this message translates to:
  /// **'Confirmado'**
  String get slotStatusConfirmed;

  /// No description provided for @slotStatusPending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get slotStatusPending;

  /// No description provided for @slotStatusUncovered.
  ///
  /// In es, this message translates to:
  /// **'Sin cubrir'**
  String get slotStatusUncovered;

  /// No description provided for @slotPriorityCritical.
  ///
  /// In es, this message translates to:
  /// **'Crítico'**
  String get slotPriorityCritical;

  /// No description provided for @slotPriorityNormal.
  ///
  /// In es, this message translates to:
  /// **'Normal'**
  String get slotPriorityNormal;

  /// No description provided for @slotAssign.
  ///
  /// In es, this message translates to:
  /// **'Asignar'**
  String get slotAssign;

  /// No description provided for @slotConfirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get slotConfirm;

  /// No description provided for @slotRemoveAssignment.
  ///
  /// In es, this message translates to:
  /// **'Quitar asignación'**
  String get slotRemoveAssignment;

  /// No description provided for @availabilityTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Quién está disponible?'**
  String get availabilityTitle;

  /// No description provided for @availabilityDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get availabilityDate;

  /// No description provided for @availabilityTimeRange.
  ///
  /// In es, this message translates to:
  /// **'Franja horaria'**
  String get availabilityTimeRange;

  /// No description provided for @availabilityRole.
  ///
  /// In es, this message translates to:
  /// **'Función (opcional)'**
  String get availabilityRole;

  /// No description provided for @availabilitySearch.
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get availabilitySearch;

  /// No description provided for @availabilityEmpty.
  ///
  /// In es, this message translates to:
  /// **'Nadie encaja con estos criterios'**
  String get availabilityEmpty;

  /// No description provided for @availabilityConflict.
  ///
  /// In es, this message translates to:
  /// **'Posible conflicto'**
  String get availabilityConflict;

  /// No description provided for @availabilityConflictMessage.
  ///
  /// In es, this message translates to:
  /// **'{name} puede que ya esté trabajando ese día. ¿Asignar igualmente?'**
  String availabilityConflictMessage(String name);

  /// No description provided for @calendarTitle.
  ///
  /// In es, this message translates to:
  /// **'Calendario'**
  String get calendarTitle;

  /// No description provided for @calendarNoEvents.
  ///
  /// In es, this message translates to:
  /// **'Sin eventos este día'**
  String get calendarNoEvents;

  /// No description provided for @calendarAddEvent.
  ///
  /// In es, this message translates to:
  /// **'Añadir evento'**
  String get calendarAddEvent;

  /// No description provided for @shiftLogTitle.
  ///
  /// In es, this message translates to:
  /// **'Registrar turnos'**
  String get shiftLogTitle;

  /// No description provided for @shiftLogHistory.
  ///
  /// In es, this message translates to:
  /// **'Historial'**
  String get shiftLogHistory;

  /// No description provided for @shiftLogOutcomeShowedUp.
  ///
  /// In es, this message translates to:
  /// **'Asistió'**
  String get shiftLogOutcomeShowedUp;

  /// No description provided for @shiftLogOutcomeLate.
  ///
  /// In es, this message translates to:
  /// **'Llegó tarde'**
  String get shiftLogOutcomeLate;

  /// No description provided for @shiftLogOutcomeNoShow.
  ///
  /// In es, this message translates to:
  /// **'No se presentó'**
  String get shiftLogOutcomeNoShow;

  /// No description provided for @shiftLogOutcomeCancelledAdvance.
  ///
  /// In es, this message translates to:
  /// **'Canceló con antelación'**
  String get shiftLogOutcomeCancelledAdvance;

  /// No description provided for @shiftLogMinutesLate.
  ///
  /// In es, this message translates to:
  /// **'Minutos de retraso'**
  String get shiftLogMinutesLate;

  /// No description provided for @shiftLogAdvanceNotice.
  ///
  /// In es, this message translates to:
  /// **'Con más de 48h de antelación'**
  String get shiftLogAdvanceNotice;

  /// No description provided for @shiftLogNotes.
  ///
  /// In es, this message translates to:
  /// **'Notas'**
  String get shiftLogNotes;

  /// No description provided for @shiftLogAll.
  ///
  /// In es, this message translates to:
  /// **'Registrar todos'**
  String get shiftLogAll;

  /// No description provided for @shiftLogOverrideReason.
  ///
  /// In es, this message translates to:
  /// **'Motivo del ajuste (obligatorio)'**
  String get shiftLogOverrideReason;

  /// No description provided for @settingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settingsTitle;

  /// No description provided for @settingsNotificationToggle.
  ///
  /// In es, this message translates to:
  /// **'Recordatorio 48h antes de eventos con puestos sin cubrir'**
  String get settingsNotificationToggle;

  /// No description provided for @settingsReliabilityReset.
  ///
  /// In es, this message translates to:
  /// **'Restablecer todas las puntuaciones a 5.0'**
  String get settingsReliabilityReset;

  /// No description provided for @settingsExport.
  ///
  /// In es, this message translates to:
  /// **'Exportar datos'**
  String get settingsExport;

  /// No description provided for @settingsImport.
  ///
  /// In es, this message translates to:
  /// **'Importar datos'**
  String get settingsImport;

  /// No description provided for @settingsClearData.
  ///
  /// In es, this message translates to:
  /// **'Borrar todos los datos'**
  String get settingsClearData;

  /// No description provided for @settingsAbout.
  ///
  /// In es, this message translates to:
  /// **'Acerca de'**
  String get settingsAbout;

  /// No description provided for @settingsResetScoresConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Restablecer todas las puntuaciones a 5.0? Esta acción no se puede deshacer.'**
  String get settingsResetScoresConfirm;

  /// No description provided for @monday.
  ///
  /// In es, this message translates to:
  /// **'Lunes'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In es, this message translates to:
  /// **'Martes'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In es, this message translates to:
  /// **'Miércoles'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In es, this message translates to:
  /// **'Jueves'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In es, this message translates to:
  /// **'Viernes'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In es, this message translates to:
  /// **'Sábado'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In es, this message translates to:
  /// **'Domingo'**
  String get sunday;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
