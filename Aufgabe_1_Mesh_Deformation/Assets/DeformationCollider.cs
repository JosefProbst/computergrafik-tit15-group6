using System;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using Moe.Tools;
using UnityEngine;
using Debug = UnityEngine.Debug;

public class DeformationCollider : MonoBehaviour {

	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		
	}

	private void OnCollisionEnter(Collision other)
	{
		foreach(ContactPoint cpt in other.contacts)
		{
			Vector4 collisionSourcePointVector4 = new Vector4(cpt.point.x, cpt.point.y, cpt.point.z, 1);
			gameObject.GetComponent<MeshRenderer>().material.SetVector("_CollisionSourcePoint", collisionSourcePointVector4);
			//TODO; parametrize Force
			gameObject.GetComponent<MeshRenderer>().material.SetFloat("_Force", 1f);
			gameObject.GetComponent<MeshRenderer>().material.SetVector("_CollisionDirectionNormal", other.impulse.normalized);
			gameObject.GetComponent<MeshRenderer>().material.SetFloat("_lastCollisionTime", Time.timeSinceLevelLoad);
		}
	}

	private void OnCollisionExit(Collision other)
	{

	}

	private void OnCollisionStay(Collision other)
	{

	}
}
