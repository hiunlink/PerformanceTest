using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class ActionState: IProcess
{
	public BaseNode Owner;
	public uint OwnerID;
	public string Name;
	public float Period;
	protected float _timeLeft;
	
	public ActionState(){}
	public ActionState(string name, float period)
	{
		Name = name;
		Period = period;
		_timeLeft = Period;
	}

	#region IProcess implementation
	public virtual bool IsDone ()
	{
		return _timeLeft < 0;
	}

	public virtual void Start ()
	{
	}
	
	public virtual void Update (float deltaTime)
	{
		_timeLeft -= deltaTime;
	}

	public virtual void End ()
	{
	}
	#endregion
}

public class ActionStates: ProcessManager
{
	public bool HasState(string stateName)
	{
		foreach (IProcess process in _processList)
		{
			if (process is ActionState)
				if ((process as ActionState).Name == stateName)
					return true;
		}
		return false;
	}
	
	public void RemoveState(string stateName)
	{
		foreach (IProcess process in _processList)
		{
			if (process is ActionState)
				if ((process as ActionState).Name == stateName)
					_removeList.Add(process);
		}
		foreach (IProcess process in _removeList)
			_processList.Remove(process);
	}
	protected List<ActionState> _replaceActions = new List<ActionState>();
	public void ReplaceState(ActionState action)
	{
		_replaceActions.Add(action);
	}
	
	public override void Update (float deltaTime)
	{
		foreach(ActionState action in _replaceActions)
		{
			RemoveState(action.Name);
			action.Start();
		}
		foreach(ActionState action in _replaceActions)
			_processList.Add(action);
		_replaceActions.Clear();
		base.Update (deltaTime);
	}
}