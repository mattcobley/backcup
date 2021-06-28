using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using System.Collections.Generic;
using Newtonsoft.Json;

namespace BackCupApi.Models
{
  public class Backup
  {

    [BsonId]
    [BsonRepresentation(BsonType.ObjectId)]
    public string Id { get; set; }
    public string Name { get; set; }

    [BsonElement("User")]
    [JsonProperty("User")]
    public string UserName { get; set; }
    public string DateTime { get; set; }
    public List<File> Files { get; set; }
  }

  public class File
  {
    public string Path { get; set; }
  }
}