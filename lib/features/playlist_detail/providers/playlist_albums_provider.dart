import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/album_info.dart';
import '../models/track.dart';
import 'playlist_tracks_provider.dart';

/// プレイリストからアルバム情報を抽出するプロバイダー
/// トラックをアルバムごとにグループ化し、重複を除去
final playlistAlbumsProvider = FutureProvider.family<List<AlbumInfo>, String>((
  ref,
  playlistId,
) async {
  // トラック一覧を取得
  final tracks = await ref.watch(playlistTracksProvider(playlistId).future);

  // アルバムIDごとにトラックをグループ化
  final albumTracksMap = <String, List<Track>>{};

  for (final track in tracks) {
    final albumId = track.albumId;
    if (!albumTracksMap.containsKey(albumId)) {
      albumTracksMap[albumId] = [];
    }
    albumTracksMap[albumId]!.add(track);
  }

  // 各アルバムの情報を作成
  final albums =
      albumTracksMap.entries
          .map((entry) => AlbumInfo.fromTracks(entry.value))
          .toList();

  // リリース日順にソート（新しい順）
  albums.sort((a, b) => b.releaseDate.compareTo(a.releaseDate));

  return albums;
});

/// シングルを含めるかどうかの状態を管理するプロバイダー
final includeSinglesProvider = StateProvider<bool>((ref) => false);

/// フィルタリングされたアルバム一覧を提供するプロバイダー
/// シングルの表示/非表示を切り替え可能
final filteredAlbumsProvider = FutureProvider.family<List<AlbumInfo>, String>((
  ref,
  playlistId,
) async {
  final albums = await ref.watch(playlistAlbumsProvider(playlistId).future);
  final includeSingles = ref.watch(includeSinglesProvider);

  if (includeSingles) {
    return albums;
  } else {
    // シングルを除外
    return albums.where((album) => !album.isSingle).toList();
  }
});
