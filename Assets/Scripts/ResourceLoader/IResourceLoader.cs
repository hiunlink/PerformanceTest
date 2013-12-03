/* 
 * 讀取資源介面
 */

public delegate void ResourceResponse(System.Object response, string error, string requestIdentify);
public interface IResourceLoader 
{
	void Request(string resourcePath, ResourceResponse responseHandler);
}
