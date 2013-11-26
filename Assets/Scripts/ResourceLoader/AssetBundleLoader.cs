using UnityEngine;
using System;
using System.IO;
using System.Collections;

public class AssetBundleLoader : IResourceLoader
{
	DateTime _requestTime = DateTime.Now;
	AssetBundleCreateRequest _assetBundleAsyncOp;
	public void Request (string resourcePath, ResourceResponse responseHandler)
	{
		_requestTime = DateTime.Now;

		CoroutineManager.Instance.StartCoroutine(CoroutineLoadResource(resourcePath, responseHandler, resourcePath));
	}

	bool isInCoroutine = false;
	IEnumerator CoroutineLoadResource(string resourcePath, ResourceResponse responseHandler, string requestIdentify)
	{
		while (isInCoroutine)
			yield return null;

		isInCoroutine = true;
		using (FileStream fileStream = File.Open(resourcePath, FileMode.Open))
		{
			byte[] bytes = new byte[fileStream.Length];
			fileStream.Read(bytes, 0, Convert.ToInt32(fileStream.Length));
			_assetBundleAsyncOp = AssetBundle.CreateFromMemory(bytes);
		}
		yield return _assetBundleAsyncOp;
		Debug.Log(DateTime.Now.Subtract(_requestTime));
		
		try
		{	
			responseHandler(_assetBundleAsyncOp.assetBundle.mainAsset, null, requestIdentify);
			_assetBundleAsyncOp.assetBundle.Unload(false);
		}
		catch (System.Exception e)
		{
			Debug.Log(string.Format("{0}\n{1}", e.Message, e.StackTrace));
		}

		isInCoroutine = false;
	}
}

