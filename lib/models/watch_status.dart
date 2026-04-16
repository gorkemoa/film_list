enum WatchStatus {
  toWatch,
  watching,
  watched,
  dropped,
  rewatch,
}

extension WatchStatusExtension on WatchStatus {
  String toJson() {
    switch (this) {
      case WatchStatus.toWatch:
        return 'to_watch';
      case WatchStatus.watching:
        return 'watching';
      case WatchStatus.watched:
        return 'watched';
      case WatchStatus.dropped:
        return 'dropped';
      case WatchStatus.rewatch:
        return 'rewatch';
    }
  }

  static WatchStatus fromJson(String? value, {bool isWatched = false}) {
    switch (value) {
      case 'to_watch':
        return WatchStatus.toWatch;
      case 'watching':
        return WatchStatus.watching;
      case 'watched':
        return WatchStatus.watched;
      case 'dropped':
        return WatchStatus.dropped;
      case 'rewatch':
        return WatchStatus.rewatch;
      default:
        return isWatched ? WatchStatus.watched : WatchStatus.toWatch;
    }
  }
}
