using UnityEngine;
using System;
using System.IO;
using System.Collections;

public static class ResourceMover
{
	static IResourceLoader _wwwLoader = new WWWLoader();
	/// <summary>
	/// Moves file in StreamingAssets path to persistent path.
	/// </summary>
	/// <param name="filesToMove">The relative path of files to move</param>
	public static void MoveStreamingToPersistentPath(string[] filesToMove)
	{
		foreach (string relativePath in filesToMove)
		{
			if (!File.Exists(Application.persistentDataPath + relativePath))
			{
				_wwwLoader.Request(Application.streamingAssetsPath + relativePath, StreamingFileHandler);
			}
		}
	}
	static void StreamingFileHandler(System.Object response, string error, string requestIdentify)
	{
		if (error != null)
			return;
			
		if (response is WWW)
		{
			string fileName = Path.GetFileName(requestIdentify);
			string fileDirPath = Path.GetDirectoryName(requestIdentify).Replace(Application.streamingAssetsPath, Application.persistentDataPath);
			FileWrite(fileDirPath, fileName, response as WWW);
		}
		
	}
	
	static void FileWrite(string DirecAbsPath, string fileName, WWW loader)
	{
		string filePathName = Path.Combine(DirecAbsPath, fileName);//DirecAbsPath + fileName;
		try
		{
			if(!Directory.Exists(DirecAbsPath))
				Directory.CreateDirectory(DirecAbsPath);//建立目錄
			
			if(File.Exists(filePathName))
				File.Delete(filePathName);
			
			if(!loader.isDone)
				return;
			File.WriteAllBytes(filePathName, loader.bytes);// Creates a new file, writes the specified byte array to the file, and then closes the file.
		}
		catch(Exception e)
		{
			Debug.Log("Couldn't save file: " + Environment.NewLine + e);
		}
	}
}

