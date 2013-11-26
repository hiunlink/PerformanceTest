using UnityEngine;
using System;
using System.IO;
using System.Collections;

public class AssetBundleLoader : IResourceLoader
{
	public void Request (string resourcePath, ResourceResponse responseHandler)
	{
		CoroutineManager.Instance.StartCoroutine(CoroutineLoadResource(resourcePath, responseHandler, resourcePath));
	}

	IEnumerator CoroutineLoadResource(string resourcePath, ResourceResponse responseHandler, string requestIdentify)
	{
		DateTime requestTime = DateTime.Now;
		AssetBundleCreateRequest assetBundleAsyncOp;
		using (FileStream fileStream = File.Open(resourcePath, FileMode.Open))
		{
			byte[] bytes = new byte[fileStream.Length];
			fileStream.Read(bytes, 0, Convert.ToInt32(fileStream.Length));
			assetBundleAsyncOp = AssetBundle.CreateFromMemory(bytes);
		}
		
		while (!assetBundleAsyncOp.isDone)
			yield return null;
		yield return assetBundleAsyncOp;
		Debug.Log(DateTime.Now.Subtract(requestTime));
		
		try
		{	
			responseHandler(assetBundleAsyncOp.assetBundle.mainAsset, null, requestIdentify);
			assetBundleAsyncOp.assetBundle.Unload(false);
		}
		catch (System.Exception e)
		{
			Debug.Log(string.Format("{0}\n{1}", e.Message, e.StackTrace));
		}
	}
}

