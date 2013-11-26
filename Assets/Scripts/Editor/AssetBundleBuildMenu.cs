using UnityEngine;
using UnityEditor;
using System.Collections;

public class AssetBundleBuildMenu
{
	[MenuItem("AssetBundle/Bundle FBX")]
	static void BundleFBX()
	{
		if (Selection.activeObject == null)
			return;
		
		foreach (Object fbxObject in Selection.objects)
		{
			AssetBundleBuilder.BundleFBX(fbxObject, Application.streamingAssetsPath);
		}
	}

	[MenuItem("AssetBundle/Bundle AnimationClip")]
	static void BundleAniamtionClip()
	{
		if (Selection.activeObject == null)
			return;
		
		foreach (Object selectedObject in Selection.objects)
		{
			AssetBundleBuilder.BundleAnimationClips(selectedObject, Application.streamingAssetsPath);
		}
	}
}

