using UnityEngine;
using UnityEditor;
using System.IO;
using System.Collections;

public class AssetBundleBuilder
{
#if UNITY_ANDROID
	public static BuildTarget TargetPlatform = BuildTarget.Android;
#elif UNITY_IPHONE
	public static BuildTarget TargetPlatform = BuildTarget.iPhone;
#endif
	
	public static void BundleFBX(Object fbxObject, string outputDirPath)
	{
		GameObject fbxGameObject = fbxObject as GameObject;
		if (fbxGameObject == null)
			return;
			
		GameObject fbxGameObjectClone = GameObject.Instantiate(fbxGameObject) as GameObject;
		// Build Animations Seperated
		outputDirPath += "/" + fbxGameObject.name;
		BundleAnimationClips(fbxGameObjectClone, outputDirPath);
		
		// Remove animation & build model assetbundle
		GameObject.DestroyImmediate(fbxGameObjectClone.animation);
		string outputPath = outputDirPath + "/" + fbxGameObject.name;
		Object fbxAsset = GetPrefab(fbxGameObjectClone, fbxGameObject.name);
		BuildPipeline.BuildAssetBundle(fbxAsset, null, outputPath, BuildAssetBundleOptions.CollectDependencies | BuildAssetBundleOptions.UncompressedAssetBundle | BuildAssetBundleOptions.CompleteAssets, TargetPlatform);
		AssetDatabase.DeleteAsset(AssetDatabase.GetAssetPath(fbxAsset));
	}
	
	public static void BundleFBX(string assetPath, string outputPath)
	{
		Object fbxObject = AssetDatabase.LoadAssetAtPath(assetPath, typeof(GameObject));
		BundleFBX(fbxObject, outputPath);
	}

	public static void BundleAnimationClips(Object rootObject, string outputDirPath)
	{
		if (!(rootObject is GameObject))
			return;

		GameObject rootGameObject = rootObject as GameObject;
		Animation animationComponent = rootGameObject.GetComponent<Animation>();

		CreateDir(outputDirPath);

		if (animationComponent != null)
		{
			foreach (AnimationState animationState in animationComponent)
				BundleAnimationClip(animationState.clip, outputDirPath);
		}
	}


	public static void BundleAnimationClip(Object animationClipObject, string outputDirPath)
	{
		if (animationClipObject is AnimationClip)
		{
			AnimationClip animationClip = animationClipObject as AnimationClip;
			string outputPath = outputDirPath + "/" + animationClip.name + ".ani";

			// Remove Scale Curves
			AnimationClipCurveData[] curves = AnimationUtility.GetAllCurves(animationClip);
			AnimationClip newClip = new AnimationClip();
			foreach (AnimationClipCurveData curve in curves) {
				// Weed out Scale
				if ( ! curve.propertyName.Contains("Scale") && curve.curve.keys.Length > 0 )
				{
					newClip.SetCurve( curve.path, curve.type, curve.propertyName, curve.curve );
					Debug.Log(curve.propertyName);
				}
			}

			string assetPath = AssetDatabase.GenerateUniqueAssetPath("Assets/"+ animationClip.name +".asset");
			AssetDatabase.CreateAsset(newClip, assetPath);
			AssetDatabase.Refresh();
			Object outputAsset = AssetDatabase.LoadAssetAtPath(assetPath, typeof(AnimationClip));
			BuildPipeline.BuildAssetBundle(outputAsset, null, outputPath, BuildAssetBundleOptions.CollectDependencies | BuildAssetBundleOptions.UncompressedAssetBundle |  BuildAssetBundleOptions.DeterministicAssetBundle | BuildAssetBundleOptions.CompleteAssets, TargetPlatform);
			AssetDatabase.DeleteAsset(AssetDatabase.GetAssetPath(outputAsset));
		}
	}
	
	public static void CreateDir(string dir)
	{
		if (!Directory.Exists(dir))
			Directory.CreateDirectory(dir);
	}
	
	static Object GetPrefab(GameObject go, string name)
	{
		Object tempPrefab = PrefabUtility.CreateEmptyPrefab("Assets/" + name + ".prefab");
		tempPrefab = PrefabUtility.ReplacePrefab(go, tempPrefab);
		Object.DestroyImmediate(go);
		return tempPrefab;
	}
}

