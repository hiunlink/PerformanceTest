using UnityEngine;
using System;
using System.Collections;

public class AssetLoader : IResourceLoader
{
	DateTime _requestTime = DateTime.Now;
	public void Request (string resourcePath, ResourceResponse responseHandler)
	{
		_requestTime = DateTime.Now;
		CoroutineManager.Instance.StartCoroutine(CoroutineLoadResource(resourcePath, responseHandler));
	}

	bool isInCoroutine = false;
	IEnumerator CoroutineLoadResource(string resourcePath, ResourceResponse responseHandler)
	{
		while (isInCoroutine)
			yield return null;

		isInCoroutine = true;
		string requestResourcePath = string.Empty;
		if (resourcePath.IndexOf("file://") < 0)
			requestResourcePath = resourcePath.Insert(0, "file://");
		WWW www = new WWW(requestResourcePath);
		yield return www;
		Debug.Log(DateTime.Now.Subtract(_requestTime));
		
		try
		{	
			responseHandler(www.assetBundle.mainAsset, www.error, resourcePath);
			www.assetBundle.Unload(false);
		}
		catch (System.Exception e)
		{
			Debug.Log(string.Format("{0}\n{1}", e.Message, e.StackTrace));
		}

		isInCoroutine = false;
	}
}

