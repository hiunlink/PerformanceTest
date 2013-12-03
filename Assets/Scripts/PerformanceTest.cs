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
		ResourceMover.MoveStreamingToPersistentPath(new string[]
		{
			@"/MedievalKnight/MedievalKnight", 
			@"/MedievalKnight/Idle.ani", 
			@"/MedievalKnight/Attack 01.ani", 
			@"/MedievalKnight/Idel To Defend.ani", 
			@"/MedievalKnight/Defend.ani", 
			@"/MedievalKnight/Defend To Idle.ani", 
			@"/MedievalKnight/Hit.ani", 
			@"/MedievalKnight/Die.ani", 
			@"/MedievalKnight/Jump.ani", 
			@"/MedievalKnight/Walk.ani", 
			@"/MedievalKnight/Run.ani", 
			@"/MedievalKnight/Attack 02.ani", 
			@"/MedievalKnight/Attack 03.ani", 
		});
		EventManager.Instance.AddListener(this, GameEvent.Name<ResourceRequestEvent>());
	}

	int _knightCount = 0;
	int _catCount = 0;
	int _mCount = 0;
	int _gCount = 0;
	int _bCount = 0;
	int _sCount = 0;
	int _a0001Count = 0;
	bool _physicsEnabled = false;
	void OnGUI()
	{
		if (GUI.Button (new Rect (0, 0, 200, 100), string.Format("Knight x{0}", _knightCount))) 
		{
			GameObject go = new GameObject("MedievalKnight");
			LoiteringModelNode node = go.AddComponent<LoiteringModelNode>();
			node.IdleAnimationName = "Idle";
			node.WalkAnimationName = "Walk";
			node.ModelResourcePath = Application.persistentDataPath + @"/MedievalKnight/MedievalKnight";
			node.PhysicsEnabled = _physicsEnabled;
			_knightCount++;
		}
		
		if (GUI.Button (new Rect (0, 100, 200, 100), string.Format("飛喵x{0}", _catCount))) 
		{
			GameObject go = new GameObject("a0008");
			LoiteringModelNode node = go.AddComponent<LoiteringModelNode>();
			node.IdleAnimationName = "idle01";
			node.WalkAnimationName = "walk01";
			node.ModelResourcePath = Application.streamingAssetsPath + @"/a0008/a0008";
			node.PhysicsEnabled = _physicsEnabled;
			_catCount++;
		}

		if (GUI.Button (new Rect (0, 200, 200, 100), string.Format("中男x{0}", _mCount))) 
		{
			GameObject go = new GameObject("a0103");
			LoiteringModelNode node = go.AddComponent<LoiteringModelNode>();
			node.IdleAnimationName = "create01";
			node.WalkAnimationName = "create02";
			node.ModelResourcePath = Application.streamingAssetsPath + @"/a0103/a0103";
			node.PhysicsEnabled = _physicsEnabled;
			_mCount++;
		}

		if (GUI.Button (new Rect (0, 300, 200, 100), string.Format("中女x{0}", _gCount))) 
		{
			GameObject go = new GameObject("a0104");
			LoiteringModelNode node = go.AddComponent<LoiteringModelNode>();
			node.IdleAnimationName = "create01";
			node.WalkAnimationName = "create02";
			node.ModelResourcePath = Application.streamingAssetsPath + @"/a0104/a0104";
			node.PhysicsEnabled = _physicsEnabled;
			_gCount++;
		}

		if (GUI.Button (new Rect (0, 400, 200, 100), string.Format("大男x{0}", _bCount))) 
		{
			GameObject go = new GameObject("a0105");
			LoiteringModelNode node = go.AddComponent<LoiteringModelNode>();
			node.IdleAnimationName = "create01";
			node.WalkAnimationName = "create02";
			node.ModelResourcePath = Application.streamingAssetsPath + @"/a0105/a0105";
			node.PhysicsEnabled = _physicsEnabled;
			_bCount++;
		}

		if (GUI.Button (new Rect (0, 500, 200, 100), string.Format("小女x{0}", _sCount))) 
		{
			GameObject go = new GameObject("a0106");
			LoiteringModelNode node = go.AddComponent<LoiteringModelNode>();
			node.IdleAnimationName = "create01";
			node.WalkAnimationName = "create02";
			node.ModelResourcePath = Application.streamingAssetsPath + @"/a0106/a0106";
			node.PhysicsEnabled = _physicsEnabled;
			_sCount++;
		}
		
		if (GUI.Button (new Rect (200, 0, 200, 100), string.Format("a0001 x{0}", _a0001Count))) 
		{
			GameObject go = new GameObject("a0001");
			LoiteringModelNode node = go.AddComponent<LoiteringModelNode>();
			node.IdleAnimationName = "idle01";
			node.WalkAnimationName = "walk01";
			node.ModelResourcePath = Application.streamingAssetsPath + @"/a0001/a0001";
			node.PhysicsEnabled = _physicsEnabled;
			_a0001Count++;
		}
		
		_physicsEnabled = GUI.Toggle(new Rect(400, 0, 200, 100), _physicsEnabled, _physicsEnabled? "碰撞開啟": "碰撞關閉");
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

