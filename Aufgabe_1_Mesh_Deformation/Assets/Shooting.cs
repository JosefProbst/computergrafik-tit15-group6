using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Shooting : MonoBehaviour {
	
	public GameObject bulletPrefab;
	public Transform bulletSpawn;
	public Camera cam;

	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		if (Input.GetKeyDown(KeyCode.Mouse0))
		{
			var bullet = (GameObject)Instantiate (
				bulletPrefab,
				bulletSpawn.position  + cam.transform.forward * 2,
				bulletSpawn.rotation);
			
			bullet.GetComponent<Renderer>().enabled = true;
			bullet.GetComponent<Rigidbody>().velocity = cam.transform.forward * 40;
			
			Destroy(bullet, 5.0f);
		} 
	}
}
