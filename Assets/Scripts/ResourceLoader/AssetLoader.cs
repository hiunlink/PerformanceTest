using UnityEngine;
using System;
using System.Collections;

public class AssetLoader : IResourceLoader
{
	public void Request (string resourcePath, ResourceResponse responseHandler)
	{
		CoroutineManager.Instance.StartCoroutine(CoroutineLoadResource(resourcePath, responseHandler));
	}

	IEnumerator CoroutineLoadResource(string resourcePath, ResourceResponse responseHandler)
	{
		DateTime requestTime = DateTime.Now;
		string requestResourcePath = string.Empty;
		if (resourcePath.IndexOf("file://") < 0)
			requestResourcePath = resourcePath.Insert(0, "file://");
		WWW www = new WWW(requestResourcePath);
		yield return www;
		Debug.Log(DateTime.Now.Subtract(requestTime));
		
		try
		{	
			responseHandler(www.assetBundle.mainAsset, www.error, resourcePath);
			www.assetBundle.Unload(false);
		}
		catch (System.Exception e)
		{
			Debug.Log(string.Format("{0}\n{1}", e.Message, e.StackTrace));
		}
	}
}

