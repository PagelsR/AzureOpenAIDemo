using AzureOpenAIDemo.Web.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json;
using System.Configuration;
using System.Diagnostics;
using System.Net.Http.Headers;
using System.Text;

namespace AzureOpenAIDemo.Web.Controllers;

public class HomeController : Controller
{
    private readonly IConfiguration _configuration;
    private static string? myOpenAPI_URL = "https://api.openai.com/v1";
    private static string? _myOpenAPI_Key = "";
    private static string? _myApimSubscriptionKey = "";
    private static string? _myApimWebServiceURL = "";

    public HomeController(IConfiguration configuration)
    {
        _configuration = configuration;

        // Get Dynamic Configuration Settings
        _myOpenAPI_Key = _configuration["OpenAIAPIKey"]!;
        _myApimSubscriptionKey = _configuration["ApimSubscriptionKey"]!;
        _myApimWebServiceURL = _configuration["ApimWebServiceURL"]!;
    }

    public IActionResult Index()
    {
        // Pass configuration settings to View
        ViewData["myOpenAPI_Key"] = _myOpenAPI_Key;
        ViewData["myApimSubscriptionKey"] = _myApimSubscriptionKey;
        ViewData["myApimWebServiceURL"] = _myApimWebServiceURL;

        return View();
    }

    public IActionResult Privacy()
    {
        return View();
    }

    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }

    public async Task<ActionResult> generateOpenAPI(string prompt)
    {
        try
        {
            using (var client = new HttpClient())
            {
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", _myOpenAPI_Key);

                var json = JsonConvert.SerializeObject(new
                {
                    prompt = prompt,
                    model = "text-davinci-003",
                    max_tokens = 100,
                    temperature = 0.5,
                    top_p = 1,
                    frequency_penalty = 0,
                    presence_penalty = 0
                });

                // Url
                var uri = myOpenAPI_URL + "/completions";

                var content = new StringContent(json, Encoding.UTF8, "application/json");
                //var response = await client.PostAsync(API_URL, new StringContent(json.ToString()));
                var response = await client.PostAsync(uri, content);

                if (response.IsSuccessStatusCode)
                {
                    var responseBody = await response.Content.ReadAsStringAsync();
                    var responseObject = JObject.Parse(responseBody);

                    var choices = responseObject["choices"];
                    if (choices != null && choices.Any())
                    {
                        var generatedText = (string)choices[0]!["text"]!;
                        return Json(new { success = true, generatedText = generatedText });
                    }
                }

                return Json(new { success = false, errorMessage = "Failed to generate text. " + _myOpenAPI_Key + " is not a valid Key" });
            }
        }
        catch (Exception ex)
        {
            return Json(new { success = false, errorMessage = ex.Message });
        }
    }

    public async Task<ActionResult> generateAPIM(string prompt)
    {
        try
        {
            using (var client = new HttpClient())
            {
                // Request headers
                client.DefaultRequestHeaders.Add("Ocp-Apim-Subscription-Key", _myApimSubscriptionKey);

                // APIM Url
                var uri = _myApimWebServiceURL + "/completions";

                var json = JsonConvert.SerializeObject(new
                {
                    prompt = prompt,
                    model = "text-davinci-003",
                    max_tokens = 100,
                    temperature = 0.5,
                    top_p = 1,
                    frequency_penalty = 0,
                    presence_penalty = 0
                });

                var content = new StringContent(json, Encoding.UTF8, "application/json");
                var response = await client.PostAsync(uri, content);

                if (response.IsSuccessStatusCode)
                {
                    var responseBody = await response.Content.ReadAsStringAsync();
                    var responseObject = JObject.Parse(responseBody);

                    var choices = responseObject["choices"];
                    if (choices != null && choices.Any())
                    {
                        var generatedText = (string)choices[0]!["text"]!;
                        return Json(new { success = true, generatedText = generatedText });
                    }
                }

                return Json(new { success = false, errorMessage = "Failed to generate text. " + _myOpenAPI_Key + " is not a valid Key" });
            }
        }
        catch (Exception ex)
        {
            return Json(new { success = false, errorMessage = ex.Message });
        }
    }

    [HttpPost]
    public async Task<ActionResult> GenerateImageOpenAI(string prompt)
    {
        try
        {
            using (var client = new HttpClient())
            {
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", _myOpenAPI_Key);

                var json = JsonConvert.SerializeObject(new
                {
                    prompt = prompt,
                    model = "image-alpha-001",
                    num_images = 1,
                    size = "1024x1024",
                    response_format = "url"
                });

                // Url
                var uri = myOpenAPI_URL + "/images/generations";

                var content = new StringContent(json, Encoding.UTF8, "application/json");
                var response = await client.PostAsync(uri, content);

                if (response.IsSuccessStatusCode)
                {
                    var responseBody = await response.Content.ReadAsStringAsync();
                    var responseObject = JObject.Parse(responseBody);

                    dynamic responseBodyJson = JsonConvert.DeserializeObject(responseBody)!;

                    var imageUrl = (string)responseBodyJson.data[0].url;

                    var imageResponse = await client.GetAsync(imageUrl);
                    var imageBytes = await imageResponse.Content.ReadAsByteArrayAsync();

                    return File(imageBytes, "image/jpeg");

                    //var choices = responseObject["choices"];
                    //if (choices != null && choices.Any())
                    //{
                    //    var generatedText = (string)choices[0]!["text"]!;
                    //    return Json(new { success = true, generatedText = generatedText });
                    //}
                }

                return Json(new { success = false, errorMessage = "Failed to generate text. " + _myOpenAPI_Key + " is not a valid Key" });
            }
        }
        catch (Exception ex)
        {
            return Json(new { success = false, errorMessage = ex.Message });
        }
    }

    [HttpPost]
    public async Task<ActionResult> GenerateImageAPIM(string prompt)
    {
        try
        {
            using (var client = new HttpClient())
            {
                // Request headers
                client.DefaultRequestHeaders.Add("Ocp-Apim-Subscription-Key", _myApimSubscriptionKey);

                // APIM Url
                var uri = _myApimWebServiceURL + "/images/generations";

                var json = JsonConvert.SerializeObject(new
                {
                    prompt = prompt,
                    model = "image-alpha-001",
                    num_images = 1,
                    size = "1024x1024",
                    response_format = "url"
                });

                var content = new StringContent(json, Encoding.UTF8, "application/json");
                var response = await client.PostAsync(uri, content);

                if (response.IsSuccessStatusCode)
                {
                    var responseBody = await response.Content.ReadAsStringAsync();

                    dynamic responseBodyJson = JsonConvert.DeserializeObject(responseBody)!;

                    var imageUrl = (string)responseBodyJson.data[0].url;

                    var imageResponse = await client.GetAsync(imageUrl);
                    var imageBytes = await imageResponse.Content.ReadAsByteArrayAsync();

                    return File(imageBytes, "image/jpeg");

                    //var responseObject = JObject.Parse(responseBody);

                    //var choices = responseObject["choices"];
                    //if (choices != null && choices.Any())
                    //{
                    //    var generatedText = (string)choices[0]!["text"]!;
                    //    return Json(new { success = true, generatedText = generatedText });
                    //}
                }

                return Json(new { success = false, errorMessage = "Failed to generate image. " + _myOpenAPI_Key + " is not a valid Key" });
            }
        }
        catch (Exception ex)
        {
            return Json(new { success = false, errorMessage = ex.Message });
        }
    }
}


    //[HttpPost]
    //public async Task<ActionResult> GenerateImageOpenAI(string prompt)
    //{
    //    try
    //    {
    //        using (var client = new HttpClient())
    //        {
    //            client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", _myOpenAPI_Key);

    //            var json = JsonConvert.SerializeObject(new
    //            {
    //                prompt = prompt,
    //                model = "image-alpha-001",
    //                num_images = 1,
    //                size = "1024x1024",
    //                response_format = "url"
    //            });

    //            var content = new StringContent(json, Encoding.UTF8, "application/json");
    //            //var response = await client.PostAsync(API_URL, new StringContent(json.ToString()));
    //            var response = await client.PostAsync(myOpenAPI_URL, content);

    //            if (response.IsSuccessStatusCode)
    //            {
    //                var responseBody = await response.Content.ReadAsStringAsync();
    //                var responseObject = JObject.Parse(responseBody);

    //                var choices = responseObject["choices"];
    //                if (choices != null && choices.Any())
    //                {
    //                    var generatedText = (string)choices[0]!["text"]!;
    //                    return Json(new { success = true, generatedText = generatedText });
    //                }
    //            }

    //            return Json(new { success = false, errorMessage = "Failed to generate text. " + _myOpenAPI_Key + " is not a valid Key" });
    //        }
    //    }
    //    catch (Exception ex)
    //    {
    //        return Json(new { success = false, errorMessage = ex.Message });
    //    }
    //}


//    [HttpPost]
//    public async Task<IActionResult> GenerateImageHOLD(string prompt)
//    {
//        var url = "https://api.openai.com/v1/images/generations";
//        var request = new HttpRequestMessage(HttpMethod.Post, url);

//        var requestBody = new
//        {
//            model = "image-alpha-001",
//            prompt = prompt,
//            num_images = 1,
//            size = "1024x1024",
//            response_format = "url"
//        };

//        var requestBodyJson = Newtonsoft.Json.JsonConvert.SerializeObject(requestBody);

//        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", _myOpenAPI_Key);
//        request.Content = new StringContent(requestBodyJson);
//        request.Content.Headers.ContentType = new MediaTypeHeaderValue("application/json");

//        var content = new StringContent(json, Encoding.UTF8, "application/json");
//        //var response = await client.PostAsync(API_URL, new StringContent(json.ToString()));
//        var response = await client.PostAsync(myOpenAPI_URL, content);


//        var response = await client.SendAsync(request);
//        response.EnsureSuccessStatusCode();

//        var responseBody = await response.Content.ReadAsStringAsync();
//        dynamic responseBodyJson = Newtonsoft.Json.JsonConvert.DeserializeObject(responseBody);

//        var imageUrl = (string)responseBodyJson.data[0].url;

//        var imageResponse = await client.GetAsync(imageUrl);
//        var imageBytes = await imageResponse.Content.ReadAsByteArrayAsync();

//        return File(imageBytes, "image/jpeg");
//    }

//}

    // Helper Function
    //private async Task<JObject> SendApiRequestAsync(string prompt)
    //{
    //    using (var client = new HttpClient())
    //    {
    //        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", myOpenAPI_Key);

    //        var json = JsonConvert.SerializeObject(new
    //        {
    //            prompt = prompt,
    //            model = "text-davinci-003",
    //            max_tokens = 100,
    //            temperature = 0.5,
    //            top_p = 1,
    //            frequency_penalty = 0,
    //            presence_penalty = 0
    //        });

    //        var content = new StringContent(json, Encoding.UTF8, "application/json");
    //        var response = await client.PostAsync(myOpenAPI_URL, content);

    //        if (response.IsSuccessStatusCode)
    //        {
    //            var responseBody = await response.Content.ReadAsStringAsync();
    //            var responseObject = JObject.Parse(responseBody);
    //            return responseObject;
    //        }

    //        throw new Exception("Failed to generate text.");
    //    }
    //}
