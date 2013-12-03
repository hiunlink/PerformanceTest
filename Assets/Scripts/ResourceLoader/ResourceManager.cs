using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class ResourceManager : IResourceLoader
{
	IResourceLoader _resourceLoader;
	Dictionary<string, System.Object> _cachedResources = new Dictionary<string, System.Object>();
	public ResourceManager()
	{
		_resourceLoader = new AssetLoader();
	}

	public void Request (string resourcePath, ResourceResponse responseHandler)
	{
		responseHandler += AddToCachedPool;
		if (!_cachedResources.ContainsKey(resourcePath))
			_resourceLoader.Request(resourcePath, responseHandler);
		else
			responseHandler(_cachedResources[resourcePath], null, resourcePath);
	}

	void AddToCachedPool(System.Object response, string error, string resourceIdentify)
	{
		if (!_cachedResources.ContainsKey(resourceIdentify))
			_cachedResources.Add(resourceIdentify, response);
	}
}

