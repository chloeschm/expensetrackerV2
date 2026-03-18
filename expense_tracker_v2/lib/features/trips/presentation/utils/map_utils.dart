import '../../../../core/config/config.dart';

String mapUrl(String destination) {
  final encoded = Uri.encodeComponent(destination);
  return 'https://maps.googleapis.com/maps/api/staticmap'
      '?center=$encoded'
      '&zoom=11'
      '&size=300x300'
      '&scale=2'
      '&style=feature:all|element:labels.text.fill|color:0x4a6741'
      '&style=feature:water|color:0xc9e4e7'
      '&style=feature:landscape|color:0xf2f7f2'
      '&key=${Config.googleMapsApiKey}';
}
