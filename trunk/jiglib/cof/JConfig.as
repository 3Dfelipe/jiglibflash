/**
* ...
* @author Default
* @version 0.1
*/

package jiglib.cof {

	public class JConfig {
		
		public static var solverType:String = "NORMAL";
		public static var allowedPenetration:Number = 0.001;
		public static var collToll:Number = 0.05;
		public static var velThreshold:Number = 0.4;
		public static var angVelThreshold:Number = 0.4;
		public static var posThreshold:Number = 0.2;
		public static var orientThreshold:Number = 0.2;
		public static var deactivationTime:Number = 0.5;
		public static var numPenetrationRelaxationTimesteps:Number = 10;
		public static var numCollisionIterations:Number = 4;
		public static var numContactIterations:Number = 16;
	}
	
}