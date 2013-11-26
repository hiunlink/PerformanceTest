using UnityEngine;
using System.Collections;

public class BaseNode : MonoBehaviour
{
	public float Speed = 5; 
	protected Vector3 _destination = Vector3.zero;
	protected bool _isMoving = false;
	public bool IsMoving
	{
		get {return _isMoving;}
	}
	public float TolerantDistance = 0.2f;
	public virtual void MoveTo(Vector3 destination)
	{
		_destination = destination;
	}
	public virtual void SetPosition(Vector3 position)
	{
		_destination = position;
		transform.position = position;
	}

	protected Vector3 _direction;
	protected virtual void FixedUpdate()
	{
		_direction = _destination - transform.position;
		if (_direction.magnitude > TolerantDistance)
		{
			transform.position += _direction.normalized * Speed * Time.fixedDeltaTime;
			_isMoving = true;
		}
		else
			_isMoving = false;
	}
}

