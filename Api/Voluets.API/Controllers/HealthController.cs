using Microsoft.AspNetCore.Mvc;
using System;

namespace Voluets.API.Controllers
{
    using System.Net.Http;
    using System.Threading.Tasks;

    [Route("health")]
    public class HealthController : ControllerBase
    {
        private readonly IHttpClientFactory _clientFactory;

        public HealthController(IHttpClientFactory clientFactory)
        {
            _clientFactory = clientFactory;
        }

        [HttpGet]
        public async Task<IActionResult> IndexAsync()
        {
            try
            {
                var client = _clientFactory.CreateClient("MetricsClient");
                var response = await client.GetAsync("/api/health");

                return response.IsSuccessStatusCode
                    ? (IActionResult) Ok()
                    : BadRequest("Calculation service is not healthy.");
            }
            catch (Exception e)
            {
                return BadRequest(e.Message);
            }
        }
    }
}
