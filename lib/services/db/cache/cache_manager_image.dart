import 'package:flutter_cache_manager/flutter_cache_manager.dart';

final customCacheManager = CacheManager(
  Config(
    'imageCacheKey',
    maxNrOfCacheObjects: 500,
    stalePeriod: const Duration(days: 30),
  ),
);
