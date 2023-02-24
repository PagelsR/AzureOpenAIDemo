//using Microsoft.AspNetCore.Mvc;
//using Newtonsoft.Json;
//using System.Net.Http;
//using System.Text;
//namespace ChatGPTDemo.Controllers
//{
//    [ApiController]
//    [Route("[controller]")]
//    public class WeatherForecastController : ControllerBase
//    {
//        private HttpClient _httpClient;

//        private readonly ILogger<WeatherForecastController> _logger;

//        public WeatherForecastController(ILogger<WeatherForecastController> logger)
//        {
//            _logger = logger;
//        }

//        [HttpGet(Name = "GetTextDavinci003")]
//        public async Task<string> Get()
//        {
//            var json = JsonConvert.SerializeObject(new
//            {
//                prompt = "What is the meaning of life",
//                temperature = 0.5,
//                max_tokens = 50,
//                model = "text-davinci-003"
//            });

//            _httpClient = new HttpClient();
//            var content = new StringContent(json, Encoding.UTF8, "application/json");
//            _httpClient.DefaultRequestHeaders.Add("Authorization", "Bearer " + "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");
//            //var response = await _httpClient.PostAsync("https://api.openai.com/v1/engines/davinci/completions", content);
//            var response = await _httpClient.PostAsync(" https://api.openai.com/v1/completions", content);
//            var responseJson = await response.Content.ReadAsStringAsync();
//            var result = JsonConvert.DeserializeObject<dynamic>(responseJson);

//            return result!.choices[0].text;
//        }

//    }
//}