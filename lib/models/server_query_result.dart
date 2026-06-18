import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fladder/jellyfin/jellyfin_open_api.swagger.dart';
import 'package:fladder/models/item_base_model.dart';

class ServerQueryResult {
  final List<BaseItemDto> original;
  final List<ItemBaseModel> items;
  final int? totalRecordCount;
  final int? startIndex;
  ServerQueryResult({
    required this.original,
    required this.items,
    this.totalRecordCount,
    this.startIndex,
  });

  factory ServerQueryResult.fromBaseQuery(
    BaseItemDtoQueryResult baseQuery,
    Ref ref,
  ) {
    return ServerQueryResult(
      original: baseQuery.items ?? [],
      items: baseQuery.items
              ?.map(
                (e) => ItemBaseModel.fromBaseDto(e, ref),
              )
              .toList() ??
          [],
      totalRecordCount: baseQuery.totalRecordCount,
      startIndex: baseQuery.startIndex,
    );
  }

  ServerQueryResult copyWith({
    List<BaseItemDto>? original,
    List<ItemBaseModel>? items,
    int? totalRecordCount,
    int? startIndex,
  }) {
    return ServerQueryResult(
      original: original ?? this.original,
      items: items ?? this.items,
      totalRecordCount: totalRecordCount ?? this.totalRecordCount,
      startIndex: startIndex ?? this.startIndex,
    );
  }
}
