//using Microsoft.AspNetCore.Mvc;
//using Newtonsoft.Json;
//using System.Net.Http;
//using System.Text;

//namespace AzureOpenAIDemo.Api.Controllers;

//[ApiController]
//[Route("[controller]")]
//public class WeatherForecastController : ControllerBase
//{
//    private static readonly string[] Summaries = new[]
//    {
//    "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
//};

//    private readonly ILogger<WeatherForecastController> _logger;
//    private HttpClient _httpClient;

//    public WeatherForecastController(ILogger<WeatherForecastController> logger)
//    {
//        _logger = logger;
//    }

//    [HttpGet(Name = "GetWeatherForecast")]
//    public IEnumerable<WeatherForecast> Get()
//    {
//        return Enumerable.Range(1, 5).Select(index => new WeatherForecast
//        {
//            Date = DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
//            TemperatureC = Random.Shared.Next(-20, 55),
//            Summary = Summaries[Random.Shared.Next(Summaries.Length)]
//        })
//        .ToArray();
//    }

//    //[HttpGet(Name = "GetOpenAI_text-davinci-003")]
//    //public async Task<string> GetTextDavinci003()
//    //{
//    //    var json = JsonConvert.SerializeObject(new
//    //    {
//    //        prompt = "What is the meaning of life?",
//    //        temperature = 0.5,
//    //        max_tokens = 50,
//    //            model = "text-davinci-003",
//    //    });

//    //    _httpClient = new HttpClient();
//    //    var content = new StringContent(json, Encoding.UTF8, "application/json");

//    //    _httpClient.DefaultRequestHeaders.Add("Authorization", "Bearer " + "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\r\n");
//    //        //var response = await _httpClient.PostAsync("https://api.openai.com/v1/engines/davinci/completions", content);
//    //        //var response = await _httpClient.PostAsync(" https://api.openai.com/v1/completions", content);
//    //        var response = await _httpClient.PostAsync("https://api.openai.com/v1/embeddings", content);
//    //    if (!response.IsSuccessStatusCode)
//    //    {
//    //            // Handle error
//    //        }
//    //    var responseJson = await response.Content.ReadAsStringAsync();
//    //    var result = JsonConvert.DeserializeObject<dynamic>(responseJson);

//    //    return result!.choices[0].text;

//    //}

//    //[HttpGet(Name = "GetOpenAI_code-davinci-002")]
//    //public async Task<string> Get_CodeDavinci002()
//    //{
//    //    var json = JsonConvert.SerializeObject(new
//    //    {
//    //        prompt = "What is the meaning of life?",
//    //        temperature = 0.5,
//    //        max_tokens = 50,
//    //            model = "code-davinci-002"
//    //    });

//    //    _httpClient = new HttpClient();
//    //    var content = new StringContent(json, Encoding.UTF8, "application/json");

//    //    _httpClient.DefaultRequestHeaders.Add("Authorization", "Bearer " + "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");
//    //        //var response = await _httpClient.PostAsync("https://api.openai.com/v1/engines/davinci/completions", content);
//    //        //var response = await _httpClient.PostAsync(" https://api.openai.com/v1/completions", content);
//    //        var response = await _httpClient.PostAsync("https://api.openai.com/v1/embeddings", content);
//    //    if (!response.IsSuccessStatusCode)
//    //    {
//    //            // Handle error
//    //        }
//    //    var responseJson = await response.Content.ReadAsStringAsync();
//    //    var result = JsonConvert.DeserializeObject<dynamic>(responseJson);

//    //    return result!.choices[0].text;
//    //}

//    [HttpGet(Name = "GetOpenAI_code-davinci-002")]
//    public async Task<string> Get()
//    {
//        var json = JsonConvert.SerializeObject(new
//        {
//            prompt = "What is the meaning of life",
//            temperature = 0.5,
//            max_tokens = 50,
//            model = "text-davinci-003"
//        });
        
//        _httpClient = new HttpClient();
//        var content = new StringContent(json, Encoding.UTF8, "application/json");
//        _httpClient.DefaultRequestHeaders.Add("Authorization", "Bearer " + "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");
//        var response = await _httpClient.PostAsync("https://api.openai.com/v1/engines/davinci/completions", content);
//        //var response = await _httpClient.PostAsync(" https://api.openai.com/v1/completions", content);
//        var responseJson = await response.Content.ReadAsStringAsync();
//        var result = JsonConvert.DeserializeObject<dynamic>(responseJson);
        
//        return result!.choices[0].text;

//    }
//}