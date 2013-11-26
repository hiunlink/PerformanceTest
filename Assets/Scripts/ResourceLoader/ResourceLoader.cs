using UnityEngine;
using System.Collections;

public class ResourceLoader : IResourceLoader
{
	public void Request (string resourcePath, ResourceResponse responseHandler)
	{
		Object obj =  Resources.Load(resourcePath);
		if (obj == null)
			responseHandler(null, string.Format("No such resource \"{0}\" in Resources."), resourcePath);
		else
			responseHandler(obj, null, resourcePath);
	}
}

