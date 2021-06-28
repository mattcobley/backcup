using BackCupApi.Models;
using BackCupApi.Services;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;

namespace BackCupApi.Controllers
{
  [Route("api/[controller]")]
  [ApiController]
  public class BackupController : ControllerBase
  {
    private readonly BackupService _backupService;

    public BackupController(BackupService bookService)
    {
      _backupService = bookService;
    }

    [HttpGet]
    public ActionResult<List<Backup>> Get() =>
        _backupService.Get();

    [HttpGet("{id:length(24)}", Name = "GetBackup")]
    public ActionResult<Backup> Get(string id)
    {
      var backup = _backupService.Get(id);

      if (backup == null)
      {
        return NotFound();
      }

      return backup;
    }

    [HttpPost]
    public ActionResult<Backup> Create(Backup backup)
    {
      _backupService.Create(backup);

      return CreatedAtRoute("GetBackup", new { id = backup.Id.ToString() }, backup);
    }

    [HttpPut("{id:length(24)}")]
    public IActionResult Update(string id, Backup backupIn)
    {
      var backup = _backupService.Get(id);

      if (backup == null)
      {
        return NotFound();
      }

      _backupService.Update(id, backupIn);

      return NoContent();
    }

    [HttpDelete("{id:length(24)}")]
    public IActionResult Delete(string id)
    {
      var backup = _backupService.Get(id);

      if (backup == null)
      {
        return NotFound();
      }

      _backupService.Remove(backup.Id);

      return NoContent();
    }
  }
}
