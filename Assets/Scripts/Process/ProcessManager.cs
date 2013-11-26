using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public interface IProcess
{
	bool IsDone();
	void Start();
	void Update(float deltaTime);
	void End();
}

public class ProcessManager: IProcess
{
	protected List<IProcess> _processList = new List<IProcess>();
	protected List<IProcess> _removeList = new List<IProcess>();
	
	public virtual void Add(IProcess process)
	{
		process.Start();
		_processList.Add(process);
	}
	
	public virtual void Update (float deltaTime)
	{
		foreach (IProcess process in _processList)
		{
			if (process == null)
				continue;
			process.Update(deltaTime);
		}
		
		foreach (IProcess process in _processList)
		{
			if (process == null)
				continue;
			if (process.IsDone())
				_removeList.Add(process);
		}
		if (_removeList.Count > 0)
		{
			foreach (IProcess process in _removeList)
			{
				_processList.Remove(process);
				process.End();
			}
			_removeList.Clear();
		}		
	}
	
	#region IProcess implementation
	bool IProcess.IsDone ()
	{
		return false;
	}

	void IProcess.Start (){}
	void IProcess.End (){}

	void IProcess.Update (float deltaTime)
	{
		this.Update(deltaTime);
	}
	#endregion
}

public class ProcessManagerStation: UnitySingletonPersistent<ProcessManagerStation>
{
	public List<ProcessManager> Managers = new List<ProcessManager>();
	public static T Create<T>() where T: ProcessManager, new()
	{
		T manager = new T();
		Instance.Managers.Add(manager);
		return manager;
	}
	
	private float _prevUpdateTime = 0.0f;
	void FixedUpdate()
	{
		if (_prevUpdateTime == 0.0f)
			_prevUpdateTime = Time.time;
		foreach (ProcessManager manager in Managers)
			manager.Update(Time.time - _prevUpdateTime);
		_prevUpdateTime = Time.time;
	}
}