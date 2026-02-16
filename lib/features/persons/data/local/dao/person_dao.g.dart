// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person_dao.dart';

// ignore_for_file: type=lint
mixin _$PersonDaoMixin on DatabaseAccessor<AppDatabase> {
  $PersonTableTable get personTable => attachedDatabase.personTable;
  PersonDaoManager get managers => PersonDaoManager(this);
}

class PersonDaoManager {
  final _$PersonDaoMixin _db;
  PersonDaoManager(this._db);
  $$PersonTableTableTableManager get personTable =>
      $$PersonTableTableTableManager(_db.attachedDatabase, _db.personTable);
}
