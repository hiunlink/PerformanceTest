using UnityEngine;
using System.Collections;

public class PerformanceTest : MonoBehaviour, IEventListener
{
	static IResourceLoader _resourceLoader;
	public static IResourceLoader ResourceLoader
	{
		get {return _resourceLoader;}
	}

	void Awake()
	{
		_resourceLoader = new ResourceManager();
		
		EventManager.Instance.AddListener(this, GameEvent.Name<ResourceRequestEvent>());
	}

	void OnGUI()
	{
		if (GUI.Button (new Rect (0, 0, 200, 100), "飛喵")) 
		{
			GameObject go = new GameObject("a0008");
			ModelNode node = go.AddComponent<ModelNode>();
			node.ModelResourcePath = Application.streamingAssetsPath + @"/a0008/a0008";
		}

		if (GUI.Button (new Rect (0, 100, 200, 100), "中男")) 
		{
			GameObject go = new GameObject("a0103");
			ModelNode node = go.AddComponent<ModelNode>();
			node.ModelResourcePath = Application.streamingAssetsPath + @"/a0103/a0103";
		}

		if (GUI.Button (new Rect (0, 200, 200, 100), "中女")) 
		{
			GameObject go = new GameObject("a0104");
			ModelNode node = go.AddComponent<ModelNode>();
			node.ModelResourcePath = Application.streamingAssetsPath + @"/a0104/a0104";
		}

		if (GUI.Button (new Rect (0, 300, 200, 100), "大男")) 
		{
			GameObject go = new GameObject("a0105");
			ModelNode node = go.AddComponent<ModelNode>();
			node.ModelResourcePath = Application.streamingAssetsPath + @"/a0105/a0105";
		}

		if (GUI.Button (new Rect (0, 400, 200, 100), "小女")) 
		{
			GameObject go = new GameObject("a0106");
			ModelNode node = go.AddComponent<ModelNode>();
			node.ModelResourcePath = Application.streamingAssetsPath + @"/a0106/a0106";
		}
	}


	#region IEventListener implementation
	bool IEventListener.HandleEvent (IEvent evt)
	{
		if (evt is ResourceRequestEvent)
		{
			ResourceRequestEvent resourceRequestEvent = evt as ResourceRequestEvent;
			PerformanceTest.ResourceLoader.Request(resourceRequestEvent.ResourcePath, resourceRequestEvent.ResourceHandler);

			return true;
		}
		return false;
	}
	#endregion
}

