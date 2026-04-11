import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../models/employee.dart';
import '../../models/event.dart';
import '../../models/role_slot.dart';
import '../../models/enums.dart';

Future<Uint8List> generateRosterPdf(
  Event event,
  List<RoleSlot> slots,
  Map<String, Employee> employees,
) async {
  final pw.Document doc = pw.Document();

  final List<RoleSlot> sorted = List<RoleSlot>.from(slots)
    ..sort((RoleSlot a, RoleSlot b) {
      final bool aCritical = a.priority == SlotPriority.critical;
      final bool bCritical = b.priority == SlotPriority.critical;
      if (aCritical != bCritical) {
        return aCritical ? -1 : 1;
      }
      return a.roleType.toLowerCase().compareTo(b.roleType.toLowerCase());
    });

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(28),
      footer: (pw.Context context) {
        return pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text('Pagina ${context.pageNumber} / ${context.pagesCount}'),
        );
      },
      build: (pw.Context context) {
        return <pw.Widget>[
          pw.Text(
            event.title,
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Text('Fecha: ${_formatDate(event.date)}'),
          pw.Text('Horario: ${event.startTime} - ${event.endTime}'),
          if ((event.callTime ?? '').trim().isNotEmpty) pw.Text('Hora de llegada: ${event.callTime}'),
          pw.SizedBox(height: 14),
          _sectionTitle('Lista de personal'),
          _line('Lugar', event.venue),
          _line('Dirección', event.address),
          _line('Aparcamiento', event.parkingNotes),
          _line('Acceso', event.accessNotes),
          pw.SizedBox(height: 10),
          _sectionTitle('Cliente'),
          _line('Cliente', event.clientName),
          _line('Contacto en evento', event.clientContact),
          if ((event.dresscode ?? '').trim().isNotEmpty) ...<pw.Widget>[
            pw.SizedBox(height: 10),
            pw.Text('Código de vestimenta: ${event.dresscode!}'),
          ],
          pw.SizedBox(height: 14),
          _sectionTitle('Lista de personal'),
          pw.Text('Hora de inicio: ${event.startTime}'),
          pw.Text('Hora de fin: ${event.endTime}'),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.8),
            columnWidths: <int, pw.TableColumnWidth>{
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(3),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(2),
            },
            children: <pw.TableRow>[
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: <pw.Widget>[
                  _cell('Función', bold: true),
                  _cell('Nombre', bold: true),
                  _cell('Teléfono', bold: true),
                  _cell('Estado', bold: true),
                ],
              ),
              ...sorted.map((RoleSlot slot) {
                final Employee? employee = employees[slot.assignedEmployeeId ?? ''];
                final bool unassigned = employee == null;

                return pw.TableRow(
                  children: <pw.Widget>[
                    _cell(slot.roleType),
                    _cell(
                      unassigned ? 'Por confirmar' : employee.name,
                      color: unassigned ? PdfColors.red : PdfColors.black,
                    ),
                    _cell(unassigned ? '-' : employee.phone),
                    _cell(slot.status.name),
                  ],
                );
              }),
            ],
          ),
          pw.SizedBox(height: 14),
          _sectionTitle('Notas:'),
          pw.Text((event.exportNotes).trim().isEmpty ? '-' : event.exportNotes),
        ];
      },
    ),
  );

  return doc.save();
}

pw.Widget _sectionTitle(String value) {
  return pw.Text(
    value,
    style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
  );
}

pw.Widget _line(String label, String? value) {
  final String text = (value ?? '').trim().isEmpty ? '-' : value!.trim();
  return pw.Padding(
    padding: const pw.EdgeInsets.only(top: 2),
    child: pw.Text('$label: $text'),
  );
}

pw.Widget _cell(
  String value, {
  bool bold = false,
  PdfColor? color,
}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(6),
    child: pw.Text(
      value,
      style: pw.TextStyle(
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        color: color,
      ),
    ),
  );
}

String _formatDate(String raw) {
  final DateTime date = DateTime.tryParse(raw) ?? DateTime.fromMillisecondsSinceEpoch(0);
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
