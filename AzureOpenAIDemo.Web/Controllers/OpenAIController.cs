////using System.Net.Http.Headers;
////using System.Reflection;
////using System.Text;
////using Microsoft.AspNetCore.Mvc;
////using Newtonsoft.Json;
////using Newtonsoft.Json.Linq;

////namespace AzureOpenAIDemo.Web.Controllers;

////public class OpenAIController : Controller
////{
////    //private static string ApimSubscriptionKey = Environment.GetEnvironmentVariable("ApimSubscriptionKey");
////    //private static string ApimWebServiceURL = Environment.GetEnvironmentVariable("ApimWebServiceURL");
////    ////private static string OPENAPI_KEY = Environment.GetEnvironmentVariable("OpenAIAPIKey");
////    //private const string API_URL = "https://api.openai.com/v1/completions";

////    //private static string OPENAPI_KEY = "AddKeyHere";

////    public ActionResult Index()
////    {
////        // Save App Configuration Dynamic Configuration Settings
////        //ViewData["myOpenAPI_Key"] = OPENAPI_KEY;

////        return View();
////    }

////    public async Task<ActionResult> generateOpenAPI(string prompt)
////    {
////        try
////        {
////            using (var client = new HttpClient())
////            {
////                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", OPENAPI_KEY);

////                var json = JsonConvert.SerializeObject(new
////                {
////                    prompt = prompt,
////                    model = "text-davinci-003",
////                    max_tokens = 100,
////                    temperature = 0.5,
////                    top_p = 1,
////                    frequency_penalty = 0,
////                    presence_penalty = 0
////                });

////                var content = new StringContent(json, Encoding.UTF8, "application/json");
////                //var response = await client.PostAsync(API_URL, new StringContent(json.ToString()));
////                var response = await client.PostAsync(API_URL, content);

////                if (response.IsSuccessStatusCode)
////                {
////                    var responseBody = await response.Content.ReadAsStringAsync();
////                    var responseObject = JObject.Parse(responseBody);

////                    var choices = responseObject["choices"];
////                    if (choices != null && choices.Any())
////                    {
////                        var generatedText = (string)choices[0]["text"];
////                        return Json(new { success = true, generatedText = generatedText });
////                    }
////                }

////                return Json(new { success = false, errorMessage = "Failed to generate text." });
////            }
////        }
////        catch (Exception ex)
////        {
////            return Json(new { success = false, errorMessage = ex.Message });
////        }
////    }

////    public async Task<ActionResult> generateAPIM(string prompt)
////    {
////        try
////        {
////            using (var client = new HttpClient())
////            {
////                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", OPENAPI_KEY);

////                var json = JsonConvert.SerializeObject(new
////                {
////                    prompt = prompt,
////                    model = "text-davinci-003",
////                    max_tokens = 100,
////                    temperature = 0.5,
////                    top_p = 1,
////                    frequency_penalty = 0,
////                    presence_penalty = 0
////                });

////                var content = new StringContent(json, Encoding.UTF8, "application/json");
////                //var response = await client.PostAsync(API_URL, new StringContent(json.ToString()));
////                var response = await client.PostAsync(API_URL, content);

////                if (response.IsSuccessStatusCode)
////                {
////                    var responseBody = await response.Content.ReadAsStringAsync();
////                    var responseObject = JObject.Parse(responseBody);

////                    var choices = responseObject["choices"];
////                    if (choices != null && choices.Any())
////                    {
////                        var generatedText = (string)choices[0]["text"];
////                        return Json(new { success = true, generatedText = generatedText });
////                    }
////                }

////                return Json(new { success = false, errorMessage = "Failed to generate text." });
////            }
////        }
////        catch (Exception ex)
////        {
////            return Json(new { success = false, errorMessage = ex.Message });
////        }
////    }

////    // Helper Function
////    private async Task<JObject> SendApiRequestAsync(string prompt)
////    {
////        using (var client = new HttpClient())
////        {
////            client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", OPENAPI_KEY);

////            var json = JsonConvert.SerializeObject(new
////            {
////                prompt = prompt,
////                model = "text-davinci-003",
////                max_tokens = 100,
////                temperature = 0.5,
////                top_p = 1,
////                frequency_penalty = 0,
////                presence_penalty = 0
////            });

////            var content = new StringContent(json, Encoding.UTF8, "application/json");
////            var response = await client.PostAsync(API_URL, content);

////            if (response.IsSuccessStatusCode)
////            {
////                var responseBody = await response.Content.ReadAsStringAsync();
////                var responseObject = JObject.Parse(responseBody);
////                return responseObject;
////            }

////            throw new Exception("Failed to generate text.");
////        }
////    }

////}
