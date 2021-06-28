using BackCupApi.Models;
using BackCupApi.Services;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.OpenApi.Models;
using Microsoft.Extensions.Options;

namespace BackCupApi
{
  public class Startup
  {
    public Startup(IConfiguration configuration)
    {
      Configuration = configuration;
    }

    public IConfiguration Configuration { get; }

    // This method gets called by the runtime. Use this method to add services to the container.
    public void ConfigureServices(IServiceCollection services)
    {
      services.Configure<BackupDatabaseSettings>(
        Configuration.GetSection(nameof(BackupDatabaseSettings)));

      services.AddSingleton<IBackupDatabaseSettings>(sp =>
        sp.GetRequiredService<IOptions<BackupDatabaseSettings>>().Value);

      services.AddSingleton<BackupService>();

      AddDependencies(services);
      services.AddControllers()
        .AddNewtonsoftJson(options => options.UseMemberCasing());

      services.AddSwaggerGen(c =>
      {
        c.SwaggerDoc("v1", new OpenApiInfo { Title = "BackCupApi", Version = "v1" });
      });
    }

    private void AddDependencies(IServiceCollection services)
    {
      //services.AddScoped<IBackupService, BackupService>();
    }

    // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
    public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
    {
      if (env.IsDevelopment())
      {
        app.UseDeveloperExceptionPage();
        app.UseSwagger();
        app.UseSwaggerUI(c => c.SwaggerEndpoint("/swagger/v1/swagger.json", "BackCupApi v1"));
      }

      app.UseHttpsRedirection();

      app.UseRouting();

      app.UseAuthorization();

      app.UseEndpoints(endpoints =>
      {
        endpoints.MapControllers();
      });
    }
  }
}
