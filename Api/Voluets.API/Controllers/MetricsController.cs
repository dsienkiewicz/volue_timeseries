using Microsoft.AspNetCore.Mvc;

namespace Voluets.API.Controllers
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Net.Http;
    using System.Net.Http.Json;
    using System.Text;
    using System.Text.Json;
    using System.Threading.Tasks;
    using Microsoft.AspNetCore.WebUtilities;

    [Route("api")]
    public class MetricsController : ControllerBase
    {
        private readonly IHttpClientFactory _clientFactory;

        public MetricsController(IHttpClientFactory clientFactory)
        {
            _clientFactory = clientFactory;
        }

        [HttpPost]
        public async Task<IActionResult> PostAsync([FromBody] IReadOnlyCollection<MetricItem> metrics)
        {
            if (metrics == null)
                return BadRequest(
                    new
                    {
                        Message = "Metrics are mandatory.",
                        Name = nameof(metrics)
                    });

            if (!metrics.Any())
                return BadRequest(
                    new
                    {
                        Message = "Collection of metrics must contain at least one element.",
                        Name = nameof(metrics)
                    });

            var convertedMetrics = metrics.Select(m => new
            {
                Name = m.Name,
                T = ConvertEpochToDateTime(m.T),
                V = m.V
            });

            var content = new StringContent(
                JsonSerializer.Serialize(convertedMetrics),
                Encoding.UTF8,
                "application/json");

            var client = _clientFactory.CreateClient("MetricsClient");
            var response = await client.PostAsync("/api/metrics", content);

            return response.IsSuccessStatusCode
                ? (IActionResult) Created("/api", "")
                : BadRequest(response.StatusCode);
        }

        [HttpGet("{name}")]
        public async Task<IActionResult> GetAsync([FromRoute] string name, [FromQuery] int from, [FromQuery] int to)
        {
            if (string.IsNullOrWhiteSpace(name))
                return BadRequest(
                    new
                    {
                        Message = "Name is mandatory.",
                        Name = nameof(name)
                    });

            if (to < from)
                return BadRequest(
                    new
                    {
                        Message = "Parameter To must be equal or greater than From.",
                        Name = nameof(to),
                        Value = to
                    });

            var client = _clientFactory.CreateClient("MetricsClient");
            var requestUri = from >= default(int) && to > default(int)
                ? CreateRequestUri(name, from, to)
                : CreateRequestUri(name, 0, (int)DateTimeOffset.Now.ToUnixTimeSeconds());

            try
            {
                var response = await client.GetFromJsonAsync<MetricsAggregateResult>(requestUri);
                return Ok(response);
            }
            catch (Exception e)
            {
                return BadRequest(e.Message);
            }
        }

        private string ConvertEpochToDateTime(int epoch)
        {
            return DateTimeOffset.FromUnixTimeSeconds(epoch).DateTime.ToString("yyyy-MM-dd HH:mm:ss");
        }

        private string CreateRequestUri(string name, int from, int to)
        {
            var fromDateTime = ConvertEpochToDateTime(from);
            var toDateTime = ConvertEpochToDateTime(to);

            var query = new Dictionary<string, string>
            {
                ["from"] = fromDateTime,
                ["to"] = toDateTime,
            };

            return QueryHelpers.AddQueryString(
                CreateRequestUri(name), 
                query);
        }

        private string CreateRequestUri(string name)
        {
            return $"api/metrics/{name}";
        }
    }
}
