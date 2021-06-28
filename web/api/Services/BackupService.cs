using BackCupApi.Models;
using MongoDB.Driver;
using System.Collections.Generic;
using System.Linq;

namespace BackCupApi.Services
{
  public class BackupService
  {
    private readonly IMongoCollection<Backup> _backups;

    public BackupService(IBackupDatabaseSettings settings)
    {
      var client = new MongoClient(settings.ConnectionString);
      var database = client.GetDatabase(settings.DatabaseName);

      _backups = database.GetCollection<Backup>(settings.BackupCollectionName);
    }

    public List<Backup> Get() =>
        _backups.Find(book => true).ToList();

    public Backup Get(string id) =>
        _backups.Find<Backup>(backup => backup.Id == id).FirstOrDefault();

    public Backup Create(Backup book)
    {
      _backups.InsertOne(book);
      return book;
    }

    public void Update(string id, Backup bookIn) =>
        _backups.ReplaceOne(book => book.Id == id, bookIn);

    public void Remove(Backup bookIn) =>
        _backups.DeleteOne(book => book.Id == bookIn.Id);

    public void Remove(string id) =>
        _backups.DeleteOne(book => book.Id == id);
  }
}