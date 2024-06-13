using AgoraIO.Media;
using backend.Const;
using Microsoft.AspNetCore.Mvc;

namespace backend;

[ApiController]
[Route("[controller]/[action]")]
public class AgoraController: ControllerBase
{
    private readonly ILogger<AgoraController> _logger;
    
    public AgoraController(ILogger<AgoraController> logger)
    {
        _logger = logger;
    }

    [HttpGet(Name = "GetUid")]
    public int GetUid()
    {
        return UidUtil.getUid();
    }

    [HttpGet(Name = "GetToken")]
    public String GetToken(string channelName, int uid){
        return _generateToken(uid, channelName);
    }

    private string _generateToken(int uid, string channelId)
    {
        AccessToken accessToken =
            new AccessToken(AgoraVariables.AppId, AgoraVariables.AppCertificate, channelId, uid.ToString());
        // expiredTsってなんだろう
        var result = accessToken.Build();
        if (result == null) throw new Exception("Token build failed");
        return result;
    }
}

public class UidUtil
{
    private static int uid = 0;
    
    public static int getUid()
    {
        return uid++;
    }
}