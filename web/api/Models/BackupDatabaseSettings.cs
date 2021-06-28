namespace BackCupApi.Models
{
  public class BackupDatabaseSettings : IBackupDatabaseSettings
  {
    public string BackupCollectionName { get; set; }
    public string ConnectionString { get; set; }
    public string DatabaseName { get; set; }
  }

  public interface IBackupDatabaseSettings
  {
    string BackupCollectionName { get; set; }
    string ConnectionString { get; set; }
    string DatabaseName { get; set; }
  }
}