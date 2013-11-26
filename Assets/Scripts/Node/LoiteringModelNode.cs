using UnityEngine;
using System.Collections;

public class LoiteringModelNode : ModelNode
{
	public Vector3 boundery0 = new Vector3(-9, 0, -1);
	public Vector3 boundery1 = new Vector3(9, 0, -1);

	public string WalkAnimationName;
	public string IdleAnimationName;

	void Update ()
	{
	}

	Vector3 NextPoint
	{
		get
		{
			return boundery0 + (boundery1 - boundery0) * Random.Range(0.0f, 1.0f);
		}
	}
}

