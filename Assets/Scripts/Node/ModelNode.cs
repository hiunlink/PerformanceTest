using UnityEngine;
using System;
using System.IO;
using System.Collections;

public class ModelNode : BaseNode
{
	string _modelResourcePath;
	string _fbxFileName;
	GameObject _modelObject;
	Animation _animation;
	Material _mainMaterial = null;
	bool _physicsEnabled = false;

	string _shaderName = "Unlit/Texture";
	public string ShaderName
	{
		set
		{
			_shaderName = value;
			ChangeShader(_shaderName);
		}

		get {return _shaderName;}
	}
	public string ModelResourcePath
	{
		set
		{
			_modelResourcePath = value;
			string directoryName = Path.GetDirectoryName(_modelResourcePath);
			string _fbxFileName = Path.GetFileName(_modelResourcePath);

			string[] files = Directory.GetFiles(directoryName, "*.ani", SearchOption.AllDirectories);
			EventManager.Instance.QueueEvent(new ResourceRequestEvent(_modelResourcePath, ModelResponseHandler, null));

			// Request Animations
			foreach (string filePath in files)
			{
				if (Path.GetFileName(filePath) != _fbxFileName)
					EventManager.Instance.QueueEvent(new ResourceRequestEvent(Path.GetDirectoryName(filePath) + "/" + System.IO.Path.GetFileName(filePath), ModelResponseHandler, null));
			}
		}
		get {return _modelResourcePath;}
	}
	public bool PhysicsEnabled 
	{
		set
		{
			_physicsEnabled = value;
		
			InitPhysicsComponents();
			_collider.enabled = value;
			_rigibody.detectCollisions = value;
		}
		get {return _physicsEnabled;}
	}
	
	protected Collider _collider;
	protected Rigidbody _rigibody;
	protected void Start()
	{
		InitPhysicsComponents();
	}
	void InitPhysicsComponents()
	{
		if (_collider == null)
			_collider = gameObject.AddComponent<CapsuleCollider>();
		if (_rigibody == null)
		{
			_rigibody = gameObject.AddComponent<Rigidbody>();
			_rigibody.useGravity = false;
		}
	}

	void ModelResponseHandler(System.Object response, string error, string requestIdentify)
	{
		if (error != null)
		{
			Debug.Log(error);
			return;
		}
		
		UnityEngine.Object responseObject = null;
		if (response is UnityEngine.Object)
			responseObject = response as UnityEngine.Object;
		else
			return;
			
		if (responseObject is GameObject)
		{
			try
			{
				_modelObject = Instantiate(responseObject) as GameObject;
				_animation = _modelObject.AddComponent<Animation>();
				_mainMaterial = _modelObject.GetComponentInChildren<SkinnedMeshRenderer>().sharedMaterial;
				ChangeShader(_shaderName);
				_modelObject.transform.parent = transform;
				_modelObject.transform.localPosition = Vector3.zero;
			}
			catch (Exception e)
			{
				Debug.Log(string.Format("{0}\n{1}", e.Message, e.StackTrace));
			}
		}
		else if (responseObject is AnimationClip)
		{
			if (_animation != null)
				_animation.AddClip(responseObject as AnimationClip, responseObject.name);
		}
	}

	public void ChangeShader(string shaderName)
	{
		if (_mainMaterial != null)
			_mainMaterial.shader = Shader.Find(shaderName);
	}

	protected override void FixedUpdate ()
	{
		base.FixedUpdate ();
		if (_modelObject != null && _direction != Vector3.zero)
			_modelObject.transform.forward = _direction;
	}

	public void PlayAnimation(string animationName)
	{
		if (_animation == null)
			return;

		AnimationState animationState = _animation[animationName];
		if (animationState != null)
		{
			animationState.wrapMode = WrapMode.Loop;
			_animation.Play(animationState.clip.name);
		}
	}
	
	void OnCollisionEnter()
	{
		if (PhysicsEnabled)
		{
			_rigibody.velocity = Vector3.zero;
			_rigibody.angularVelocity = Vector3.zero;
		}
	}
	void OnCollisionExit()
	{
		if (PhysicsEnabled)
		{
			_rigibody.velocity = Vector3.zero;
			_rigibody.angularVelocity = Vector3.zero;
		}
	}
}

