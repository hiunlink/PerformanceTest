using UnityEngine;
using System.Collections;

public class LoiteringModelNode : ModelNode
{
	public Vector3 boundery0 = new Vector3(-3, 0, -1);
	public Vector3 boundery1 = new Vector3(3, 0, -1);

	public string WalkAnimationName;
	public string IdleAnimationName;
	LoiteringState state = LoiteringState.Idle;
	enum LoiteringState
	{
		Idle, 
		Walk, 
	}
	void Awake()
	{

	}

	float _idleTime = 0.0f;
	void Update()
	{
		if (state == LoiteringState.Idle)
		{
			if (_idleTime < 0)
			{
				state = LoiteringState.Walk;
				PlayAnimation(WalkAnimationName);
				MoveTo(NextPoint);
				_idleTime = Random.Range(1.0f, 5.0f);
			}
			else
				_idleTime -= Time.deltaTime;
		}
		else
		{
			if (!IsMoving)
			{
				state = LoiteringState.Idle;
				PlayAnimation(IdleAnimationName);
			}
		}
	}

	Vector3 NextPoint
	{
		get
		{
			return boundery0 + (boundery1 - boundery0) * Random.Range(0.0f, 1.0f);
		}
	}
}

