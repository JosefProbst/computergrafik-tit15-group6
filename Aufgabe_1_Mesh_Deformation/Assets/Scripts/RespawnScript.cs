using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RespawnScript : MonoBehaviour {

	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		
	}
	
	private void OnCollisionEnter(Collision other)
	{
		Debug.Log("Respawning object: " + other.gameObject.ToString());
			other.gameObject.transform.position = Vector3.zero;
	}
	
}
