import 'dart:convert';
import 'dart:typed_data';

class Nft {
  const Nft({
    required this.id,
    required this.name,
    required this.image,
    this.creator = 'caseykaspol',
    this.price = .15,
    this.likes = 20,
    this.category = 'Art',
    this.description =
        'A study in color, space and imagination. A unique piece of digital art from the CoralSea collection.',
    this.collection = 'Untitled Collection',
    this.isCreated = false,
    this.imageBase64,
    this.royalties = 0,
    this.saleType = 'Fixed Price',
    this.properties = const {},
    this.altText = '',
  });
  final String id, name, image, creator, category, description, collection;
  final double price, royalties;
  final int likes;
  final bool isCreated;
  final String? imageBase64;
  final String saleType, altText;
  final Map<String, String> properties;
  Uint8List? get imageBytes =>
      imageBase64 == null ? null : base64Decode(imageBase64!);
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'image': image,
    'creator': creator,
    'price': price,
    'likes': likes,
    'category': category,
    'description': description,
    'collection': collection,
    'isCreated': isCreated,
    'imageBase64': imageBase64,
    'royalties': royalties,
    'saleType': saleType,
    'properties': properties,
    'altText': altText,
  };
  factory Nft.fromJson(Map<String, dynamic> json) => Nft(
    id: json['id'] as String,
    name: json['name'] as String,
    image: json['image'] as String,
    creator: json['creator'] as String,
    price: (json['price'] as num).toDouble(),
    likes: json['likes'] as int,
    category: json['category'] as String,
    description: json['description'] as String,
    collection: json['collection'] as String,
    isCreated: json['isCreated'] == true,
    imageBase64: json['imageBase64'] as String?,
    royalties: (json['royalties'] as num? ?? 0).toDouble(),
    saleType: json['saleType'] as String? ?? 'Fixed Price',
    properties: Map<String, String>.from(json['properties'] as Map? ?? {}),
    altText: json['altText'] as String? ?? '',
  );
}

class MarketEvent {
  const MarketEvent({
    required this.nftId,
    required this.title,
    required this.amount,
    required this.time,
    this.expiresAt,
  });
  final String nftId, title;
  final double amount;
  final DateTime time;
  final DateTime? expiresAt;
  Map<String, dynamic> toJson() => {
    'nftId': nftId,
    'title': title,
    'amount': amount,
    'time': time.toIso8601String(),
    'expiresAt': expiresAt?.toIso8601String(),
  };
  factory MarketEvent.fromJson(Map<String, dynamic> json) => MarketEvent(
    nftId: json['nftId'] as String,
    title: json['title'] as String,
    amount: (json['amount'] as num).toDouble(),
    time: DateTime.parse(json['time'] as String),
    expiresAt: json['expiresAt'] == null
        ? null
        : DateTime.parse(json['expiresAt'] as String),
  );
}

const categories = [
  'Trending',
  'Art',
  'Collectibles',
  'Domain Name',
  'Music',
  'Photography',
];
const seedNfts = [
  Nft(
    id: 'door',
    name: '3D door dash',
    image: 'door',
    price: .05,
    category: 'Collectibles',
    collection: 'The Architecture Series',
    description:
        'A doorway to somewhere extraordinary. Soft light, quiet geometry and endless possibilities. An original work from The Architecture Series.',
  ),
  Nft(
    id: 'arches',
    name: 'Infinite passage',
    image: 'arches',
    price: .18,
    category: 'Collectibles',
    collection: 'The Architecture Series',
  ),
  Nft(id: 'purple', name: 'Abstract Painting', image: 'art_purple', price: .15),
  Nft(id: 'blue', name: 'Ocean in motion', image: 'art_blue', price: .12),
  Nft(
    id: 'wave',
    name: 'Electric dreams',
    image: 'art_wave',
    price: .24,
    category: 'Music',
  ),
  Nft(
    id: 'yellow',
    name: 'A little sunshine',
    image: 'art_yellow',
    price: .09,
    category: 'Photography',
  ),
];
String eth(double value) => value
    .toStringAsFixed(6)
    .replaceFirst(RegExp(r'0+$'), '')
    .replaceFirst(RegExp(r'\.$'), '');
