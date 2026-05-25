import '../database/dao/connection_dao.dart';
import '../models/connection_info.dart';

class ConnectionRepository {
  Future<int> saveConnection(ConnectionInfo info) => ConnectionDao.insert(info);

  Future<void> updateDisconnection(int id, DateTime disconnectedAt, int duration) =>
      ConnectionDao.updateDisconnection(id, disconnectedAt, duration);

  Future<List<ConnectionInfo>> getHistory({int limit = 20}) =>
      ConnectionDao.getHistory(limit: limit);

  Future<int> deleteAll() => ConnectionDao.deleteAll();
}