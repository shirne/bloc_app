import 'base.dart';

class FileModel implements Base {
  FileModel({
    required this.id,
    required this.url,
    required this.extensions,
    required this.mimeType,
    required this.path,
    required this.name,
    required this.size,
    required this.type,
    this.createdTime,
    this.updatedTime,
  });

  factory FileModel.fromJson(Json json) => FileModel(
    id: as<int>(json['id']) ?? 0,
    url: as<String>(json['url']) ?? '',
    extensions: as<String>(json['extensions']) ?? '',
    mimeType: as<String>(json['mime_type']) ?? '',
    path: as<String>(json['path']) ?? '',
    name: as<String>(json['name']) ?? '',
    size: as<int>(json['size']) ?? 0,
    type: as<int>(json['type']) ?? 0,
    createdTime: as<DateTime>(json['created_time']),
    updatedTime: as<DateTime>(json['updated_time']),
  );

  final int id;
  final String url;
  final String extensions;
  final String mimeType;
  final String path;
  final String name;
  final int size;
  final int type;
  final DateTime? createdTime;
  final DateTime? updatedTime;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'url': url,
    'extensions': extensions,
    'mime_type': mimeType,
    'path': path,
    'name': name,
    'size': size,
    'type': type,
    'created_time': createdTime,
    'updated_time': updatedTime,
  };

  @override
  FileModel clone({
    int? id,
    String? url,
    String? extensions,
    String? mimeType,
    String? path,
    String? name,
    int? size,
    int? type,
    DateTime? createdTime,
    DateTime? updatedTime,
  }) {
    return FileModel(
      id: id ?? this.id,
      url: url ?? this.url,
      extensions: extensions ?? this.extensions,
      mimeType: mimeType ?? this.mimeType,
      path: path ?? this.path,
      name: name ?? this.name,
      size: size ?? this.size,
      type: type ?? this.type,
      createdTime: createdTime ?? this.createdTime,
      updatedTime: updatedTime ?? this.updatedTime,
    );
  }
}
