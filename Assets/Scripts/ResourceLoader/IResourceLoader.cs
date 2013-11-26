/* 
 * 讀取資源介面
 */

public delegate void ResourceResponse(UnityEngine.Object response, string error, string requestIdentify);
public interface IResourceLoader 
{
	void Request(string resourcePath, ResourceResponse responseHandler);
}
