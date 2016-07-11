using UnityEngine;
using System.Collections;
using DaburuTools.Action;

public class ActionDemo : MonoBehaviour
{
	void Start()
	{
		MoveToAction move1 = new MoveToAction(this.transform, new Vector3(0.0f, 2.0f, 0.0f), 1.0f);
		MoveToAction move2 = new MoveToAction(this.transform, new Vector3(2.0f, 2.0f, 0.0f), 1.0f);
		MoveToAction move3 = new MoveToAction(this.transform, new Vector3(0.0f, 0.0f, 0.0f), 1.0f);
		MoveToAction move4 = new MoveToAction(this.transform, new Vector3(2.0f, 0.0f, 0.0f), 1.0f);

		ActionSequence actionSequence = new ActionSequence(move1, move2, move3, move4);
		ActionHandler.RunAction(actionSequence);
	}
	
	void Update()
	{
	
	}
}
