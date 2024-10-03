class SongModel {
  final String title;
  final String artist;
  final String albumArtUrl;
  final String streamingUrl;

  SongModel(
      {required this.title,
      required this.artist,
      required this.albumArtUrl,
      required this.streamingUrl});

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      title: json['title'],
      artist: json['artist']['name'],
      albumArtUrl: json['album']['cover'],
      streamingUrl: json['preview'],
    );
  }
}
