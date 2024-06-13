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
    public int GetUid(String channelName)
    {
        return UidUtil.GetUid(channelName);
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
    static Dictionary<string, int> _uidMap = new Dictionary<string, int>();
    
    public static int GetUid(string channelName)
    {
        if(_uidMap.ContainsKey(channelName))
            return _uidMap[channelName]++;
        else 
            return _uidMap[channelName] = 0;
    }
}