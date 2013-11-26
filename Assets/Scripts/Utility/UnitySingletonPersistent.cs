using System;
using UnityEngine;

public class UnitySingletonPersistent<T> : MonoBehaviour
	where T : Component
{
	protected static T _instance;
	public static T Instance
	{
		get
		{
			if (_instance == null)
			{
				_instance = FindObjectOfType (typeof(T)) as T;
				if (_instance == null)
				{
					GameObject go = new GameObject(typeof(T).Name);;										
					_instance = go.AddComponent<T>();
				}
			}
			return _instance;
		}
	}
	
	protected virtual void Awake ()
	{
		DontDestroyOnLoad (this.gameObject);
		if (_instance == null) 
			_instance = this as T;
		else
			Destroy (gameObject);
	}
}