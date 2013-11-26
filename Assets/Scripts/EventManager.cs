//C# Unity event manager that uses strings in a hashtable over delegates and events in order to
//allow use of events without knowing where and when they're declared/defined.
//by Billy Fletcher of Rubix Studios
using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;

public interface IEventListener
{
	bool HandleEvent(IEvent evt);
}

public interface IEvent
{
	string GetName();
	object GetData();
}

/// <summary>
/// Event manager. 和IObserver一樣的功能，不過不需要實作ISubject，使用的好處為不用一堆自己的程式碼都擠在PlayerControl或其他人的Code中...
/// 通知的方法為實作IEvent加入須要參數並藉由QueueEvent觸發
/// class LogoutEvent: IEvent
/// {
/// 	...
/// }
/// EventManager.Instance.QueueEvent(LogoutEvent.Instance);
/// 登出事件範例:
/// FriendManager需要在登出時清空好友資料，在HandleEvent實作清空資料並註冊LogoutEvent
/// class FriendManager: IEventListener
/// {
/// 	void onCreate()
/// 	{
/// 		...
/// 		EventManager.Instance.AddListener(this, GameEvent.Name<LogoutEvent>());
/// 	}
/// 	
/// 	public bool HandleEvent(IEvent evt)
/// 	{
/// 		if (evt is LogoutEvent)
/// 		{
/// 			ClearFreindData();
/// 		}
/// 	}
/// }
/// </summary>
public class EventManager : UnitySingletonPersistent<EventManager>
{
	public bool LimitQueueProcesing = false;
	public float QueueProcessTime = 0.0f;
	
	private Dictionary<string, List<IEventListener>> _listenerTable = new Dictionary<string, List<IEventListener>>();
	private Queue _eventQueue = new Queue();
	
	//Add a listener to the event manager that will receive any events of the supplied event name.
	public bool AddListener(IEventListener listener, string eventName)
	{
		if (listener == null || eventName == null)
		{
			Debug.Log("Event Manager: AddListener failed due to no listener or event name specified.");
			return false;
		}
		
		List<IEventListener> listenerList;
		
		if (!_listenerTable.TryGetValue(eventName, out listenerList))
		{
			listenerList = new List<IEventListener>();
			_listenerTable.Add(eventName, listenerList);
		}
		
		if (listenerList.Contains(listener))
		{
			Debug.Log(string.Format("Event Manager: Listener: {0} is already in list for event: {1}", listener.GetType(), eventName));
			return false; //listener already in list
		}
		
		listenerList.Add(listener);
		return true;
	}
	
	//Remove a listener from the subscribed to event.
	public bool DetachListener(IEventListener listener, string eventName)
	{
		List<IEventListener> listenerList;
		
		if (!_listenerTable.TryGetValue(eventName, out listenerList))
			return false;
		
		if (!listenerList.Contains(listener))
			return false;
		
		listenerList.Remove(listener);
		return true;
	}
	
	//Trigger the event instantly, this should only be used in specific circumstances,
	//the QueueEvent function is usually fast enough for the vast majority of uses.
	public bool TriggerEvent(IEvent evt)
	{
		bool result = true;
		string eventName = evt.GetName();
		List<IEventListener> listenerList;
		
		if (!_listenerTable.TryGetValue(eventName, out listenerList))
		{
			Debug.Log(string.Format("Event Manager: Event \"{0}\" triggered has no listeners!", eventName));
			return false; //No listeners for event so ignore it
		}
		
		listenerList.RemoveAll(listener => listener.Equals(null)); // 刪除所有null(需使用Equals作實值檢查，而非參考檢查，才能得到正確結果)
		
		foreach (IEventListener listener in listenerList)
		{
			//			if (listener.Equals(null))
			//				continue;
			
			if (!listener.HandleEvent(evt))
				result = false; 
		}
		
		return result;
	}
	
	//Inserts the event into the current queue.
	public bool QueueEvent(IEvent evt)
	{
		if (!_listenerTable.ContainsKey(evt.GetName()))
		{
			Debug.Log(string.Format("EventManager: QueueEvent failed due to no listeners for event: {0}", evt.GetName()));
			return false;
		}
		
		_eventQueue.Enqueue(evt);
		return true;
	}
	
	//Every update cycle the queue is processed, if the queue processing is limited,
	//a maximum processing time per update can be set after which the events will have
	//to be processed next update loop.
	void Update()
	{
		float timer = 0.0f;
		while (_eventQueue.Count > 0)
		{
			if (LimitQueueProcesing)
			{
				if (timer > QueueProcessTime)
					return;
			}
			
			IEvent evt = _eventQueue.Dequeue() as IEvent;
			if (!TriggerEvent(evt))
				Debug.Log(string.Format("Error when processing event: {0}", evt.GetName()));
			
			if (LimitQueueProcesing)
				timer += Time.deltaTime;
		}
	}
	
	void OnDestroy()
	{
		if (_listenerTable != null)
			_listenerTable.Clear();
		
		if (_eventQueue != null)
			_eventQueue.Clear();
		
		_listenerTable = null;
		_eventQueue = null;
		_instance = null;
	}
}

public class GameEvent
{
	public static string Name<T>() where T: IEvent, new()
	{
		return ((IEvent)new T()).GetName();
	}
}

public class ResourceRequestEvent: IEvent
{
	public string ResourcePath = string.Empty;
	public ResourceResponse ResourceHandler = null;
	public object Parameters = null;

	public ResourceRequestEvent(){}
	public ResourceRequestEvent(string resourcePath, ResourceResponse resourceHandler, object parameters)
	{
		ResourcePath = resourcePath;
		ResourceHandler = resourceHandler;
		Parameters = parameters;
	}

	public string GetName ()
	{
		return GetType().ToString();
	}

	public object GetData ()
	{
		return "Resource Request";
	}
}