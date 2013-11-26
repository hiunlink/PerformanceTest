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
			string directoryName = System.IO.Path.GetDirectoryName(_modelResourcePath);
			string _fbxFileName = System.IO.Path.GetFileName(_modelResourcePath);

			string[] files = System.IO.Directory.GetFiles(directoryName, "*.ani", System.IO.SearchOption.AllDirectories);
			EventManager.Instance.QueueEvent(new ResourceRequestEvent(_modelResourcePath, ModelResponseHandler, null));

			// Request Animations
			foreach (string filePath in files)
			{
				if (System.IO.Path.GetFileName(filePath) != _fbxFileName)
					EventManager.Instance.QueueEvent(new ResourceRequestEvent(System.IO.Path.GetDirectoryName(filePath) + "/" + System.IO.Path.GetFileName(filePath), ModelResponseHandler, null));
			}
		}
		get {return _modelResourcePath;}
	}

	void ModelResponseHandler(UnityEngine.Object response, string error, string requestIdentify)
	{
		if (error != null)
		{
			Debug.Log(error);
			return;
		}

		if (response is GameObject)
		{
			try
			{
				_modelObject = Instantiate(response) as GameObject;
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
		else if (response is AnimationClip)
		{
			if (_animation != null)
			{
				_animation.AddClip(response as AnimationClip, response.name);
				if (_animation.GetClipCount() == 1)
					_animation.Play(response.name);
			}
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
}

