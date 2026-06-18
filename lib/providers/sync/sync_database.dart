import 'dart:async';

import 'package:flutter/material.dart';
import 'package:drift_db_viewer/drift_db_viewer.dart';

import 'package:fladder/models/syncing/database_item.dart';
import 'package:fladder/models/syncing/sync_item.dart';

/// Pure database access layer for synced items.
/// Wraps AppDatabase (Drift) queries. No file I/O, no API calls, no state management.
class SyncDatabase {
  final AppDatabase _db;

  SyncDatabase(this._db);

  Future<List<SyncedItem>> getAllItems() => _db.getAllItems.get();

  Stream<List<SyncedItem>> watchAllItems() => _db.getAllItems.watch();

  Future<SyncedItem?> getItem(String id) => _db.getItem(id).getSingleOrNull();

  Stream<SyncedItem?> watchItem(String id) => _db.getItem(id).watchSingleOrNull();

  Future<List<SyncedItem>> getChildren(String parentId) => _db.getChildren(parentId).get();

  Future<SyncedItem?> getParent(String id) => _db.getParent(id).getSingleOrNull();

  Future<List<SyncedItem>> getNestedChildren(SyncedItem item) async {
    return _db.getNestedChildren(item);
  }

  Future<List<SyncedItem>> getSiblings(String parentId) async {
    if (parentId.isEmpty) return [];
    return getChildren(parentId);
  }

  Future<int> insertItem(SyncedItem item) => _db.insertItem(item);

  Future<void> insertMultipleEntries(List<SyncedItem> items) => _db.insertMultipleEntries(items);

  Future<void> deleteAllItems(List<SyncedItem> items) => _db.deleteAllItems(items);

  Future<void> clearDatabase() => _db.clearDatabase();

  void viewDatabase(BuildContext context) =>
      Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (context) => DriftDbViewer(_db)));
}
