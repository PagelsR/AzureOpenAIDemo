using System.Net.Http;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;

namespace AzureOpenAIDemo.Api.Controllers;

[ApiController]
[Route("[controller]")]
public class OpenAIController : ControllerBase
{
    private readonly HttpClient _httpClient;
    private readonly string _apiKey = "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";
    private const string _baseUrl = "https://api.openai.com/v1";

    public OpenAIController(HttpClient httpClient, string apiKey)
    {
        _httpClient = httpClient;
        _apiKey = apiKey;
    }

    [HttpGet(Name = "GetCodeDavinci002")]
    public async Task<string> GetCodeDavinci002()
    {
        //var modelEndpoint = "/engines/text-davinci-002/completions";
        var modelEndpoint = "/completions";
        var requestBody = new
        {
            prompt = "Write a program in C# to reverse a string",
            temperature = 0.5,
            max_tokens = 60,
            n = 1,
            stop = "\n",
            model = "text-davinci-002"
        };

        var response = await SendCompletionRequest(modelEndpoint, requestBody);
        var choices = response?.choices;
        var completionText = choices?[0]?.text;

        return completionText;
    }

    //[HttpGet(Name = "GetCodeDavinci003")]
    //public async Task<string> GetCodeDavinci003()
    //{
    //    //var modelEndpoint = "/engines/text-davinci-002/completions";
    //    var modelEndpoint = "/completions";
    //    var requestBody = new
    //    {
    //        prompt = "Write a program in C# to find the largest number in an array",
    //        max_tokens = 60,
    //        n = 1,
    //        stop = "\n",
    //        model = "text-davinci-003"
    //    };

    //    var response = await SendCompletionRequest(modelEndpoint, requestBody);
    //    var choices = response?.choices;
    //    var completionText = choices?[0]?.text;

    //    return completionText;
    //}

    //[HttpGet(Name = "GetCodeDavinci003")]
    //public async Task<string> GetCodeDavinci003()
    //{
    //    //var modelEndpoint = "/engines/text-davinci-002/completions";
    //    var modelEndpoint = "/completions";
    //    var requestBody = new
    //    {
    //        prompt = "Write a program in C# to find the largest number in an array",
    //        max_tokens = 60,
    //        n = 1,
    //        stop = "\n",
    //        model = "text-davinci-003"
    //    };

    //    var response = await SendCompletionRequest(modelEndpoint, requestBody);
    //    var choices = response?.choices;
    //    var completionText = choices?[0]?.text;

    //    return completionText;
    //}

    private async Task<dynamic> SendCompletionRequest(string modelEndpoint, dynamic requestBody)
    {
        var requestUrl = _baseUrl + modelEndpoint;
        var request = new HttpRequestMessage(HttpMethod.Post, requestUrl);
        request.Headers.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", _apiKey);
        request.Content = new StringContent(System.Text.Json.JsonSerializer.Serialize(requestBody), System.Text.Encoding.UTF8, "application/json");

        var response = await _httpClient.SendAsync(request);
        if (response.IsSuccessStatusCode)
        {
            var responseContent = await response.Content.ReadAsStringAsync();
            var responseData = System.Text.Json.JsonSerializer.Deserialize<dynamic>(responseContent);
            return responseData?.choices;
        }

        return null;
    }
}

