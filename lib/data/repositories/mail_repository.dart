import '../database/dao/mail_dao.dart';
import '../models/mail_record.dart';

class MailRepository {
  Future<int> addRecord(MailRecord record) => MailDao.insert(record);

  Future<List<MailRecord>> getAll({int limit = 100, int offset = 0}) =>
      MailDao.getAll(limit: limit, offset: offset);

  Future<List<MailRecord>> getByDateRange(DateTime start, DateTime end) =>
      MailDao.getByDateRange(start, end);

  Future<List<MailRecord>> search(String query) => MailDao.search(query);

  Future<int> getTotalCount() => MailDao.getTotalCount();

  Future<int> getTodayCount() => MailDao.getTodayCount();

  Future<Map<String, int>> getWeeklyCounts() => MailDao.getWeeklyCounts();

  Future<Map<String, int>> getMonthlyCounts() => MailDao.getMonthlyCounts();

  Future<MailRecord?> getLatest() => MailDao.getLatest();

  Future<int> deleteAll() => MailDao.deleteAll();
}