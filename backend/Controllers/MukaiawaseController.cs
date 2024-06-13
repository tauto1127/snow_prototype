using System.Collections;
using System.Text.Json.Serialization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers;

public class Gps
{
    [JsonPropertyName("latitude")]
    public double Latitude { get; set; }
    [JsonPropertyName("longitude")]
    public double Longitude { get; set; }
}

[ApiController]
[Route("[controller]/[action]")]
public class MukaiawaseController : ControllerBase
{

    private static Dictionary<int, Gps> gpss = new Dictionary<int, Gps>();

    [HttpPut]
    public Gps SetGps(int userid, double latitude, double longitude)
    {
        var gps = new Gps(){Latitude = latitude, Longitude = longitude};
        Console.WriteLine(latitude + longitude);
        Console.WriteLine(gps.Longitude);
        if (gpss.ContainsKey(userid))
        {
            gpss[userid] = gps;
        }
        else
        {
            gpss.Add(userid, gps);
        }

        return gps;
    }

    [HttpGet]
    public Gps GetGps(int userid)
    {
        if (gpss.ContainsKey(userid))
        {
            Console.WriteLine(gpss[userid]);
            return gpss[userid];
        }
        else
        {
            Console.WriteLine("not found gps user");
            return new Gps(){Latitude = 0, Longitude = 0};
        }
    }
}