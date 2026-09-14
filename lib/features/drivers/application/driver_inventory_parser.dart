import 'package:xml/xml.dart';

import '../domain/driver_package.dart';

class DriverInventoryParser {
  const DriverInventoryParser();

  List<DriverPackage> parse(String xml) {
    final document = XmlDocument.parse(xml);
    return document
        .findAllElements('Driver')
        .map((driver) {
          String value(String name) =>
              driver.getElement(name)?.innerText.trim() ?? '';
          final publishedName = driver.getAttribute('DriverName')?.trim() ?? '';
          if (publishedName.isEmpty) {
            throw const FormatException('DriverName is missing.');
          }
          final signer = value('SignerName');
          return DriverPackage(
            publishedName: publishedName,
            infName: value('OriginalName'),
            version: value('DriverVersion'),
            publisher: value('ProviderName'),
            hardwareIds: driver
                .findAllElements('DeviceID')
                .map((element) => element.innerText.trim().toUpperCase())
                .where((id) => id.isNotEmpty)
                .toSet(),
            signed: signer.isNotEmpty,
          );
        })
        .toList(growable: false);
  }
}
