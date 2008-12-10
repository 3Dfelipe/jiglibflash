/*
Copyright (c) 2007 Danny Chapman 
http://www.rowlhouse.co.uk

This software is provided 'as-is', without any express or implied
warranty. In no event will the authors be held liable for any damages
arising from the use of this software.
Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:
1. The origin of this software must not be misrepresented; you must not
claim that you wrote the original software. If you use this software
in a product, an acknowledgment in the product documentation would be
appreciated but is not required.
2. Altered source versions must be plainly marked as such, and must not be
misrepresented as being the original software.
3. This notice may not be removed or altered from any source
distribution.
*/

/**
* @author Muzer(muzerly@gmail.com)
* @link http://code.google.com/p/jiglibflash
*/

package jiglib.geometry {

	import jiglib.math.*;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.primitives.Cube;
	
	public class JBox extends JObject3D {
		
		private var _sideLengths:JNumber3D;
		private var _edges:Array=new Array({ ind0:0, ind1:1 }, { ind0:3, ind1:1 }, { ind0:2, ind1:3 },
			                             { ind0:2, ind1:0 }, { ind0:4, ind1:5 }, { ind0:5, ind1:7 },
							             { ind0:6, ind1:7 }, { ind0:4, ind1:6 }, { ind0:7, ind1:1 },
							             { ind0:5, ind1:3 }, { ind0:4, ind1:2 }, { ind0:6, ind1:0 });
										 
		 
		public function JBox(materials:MaterialsList, width:Number=500, depth:Number=500, height:Number=500) {
			
			this.Type = "BOX";
			this.Skin = new Cube(materials, width, depth, height);
			_sideLengths = new JNumber3D(width, height, depth);
			 
			this.BoundingSphere = 0.5 * _sideLengths.modulo;
		}
		 
		public function get SideLengths():JNumber3D
		{
			return _sideLengths;
		}
		public function get Edges():Array
		{
			return _edges;
		}
		
		public function GetVolume():Number
		{
			return (SideLengths.x * SideLengths.y * SideLengths.z);
		}
		public function GetSurfaceArea():Number
		{
			return 2 * (SideLengths.x * SideLengths.y + SideLengths.x * SideLengths.z + SideLengths.y * SideLengths.z);
		}
		public function GetHalfSideLengths():JNumber3D
		{
			return JNumber3D.multiply(SideLengths, 0.5);
		}
		
		public function GetSpan(axis:JNumber3D):Object
		{
			var obj:Object = new Object();
			var s:Number = Math.abs(JNumber3D.dot(axis, Orientation.getCols()[0])) * (0.5 * SideLengths.x);
			var u:Number = Math.abs(JNumber3D.dot(axis, Orientation.getCols()[1])) * (0.5 * SideLengths.y);
			var d:Number = Math.abs(JNumber3D.dot(axis, Orientation.getCols()[2])) * (0.5 * SideLengths.z);
			var r:Number = s + u + d;
			var p:Number = JNumber3D.dot(Position, axis);
			obj.min = p - r;
			obj.max = p + r;
			 
			return obj;
		}
		
		public function GetCornerPoints():Array
		{
			var vertex:JNumber3D;
			var arr:Array = new Array();
			for (var i:String in this.Skin.geometry.vertices)
			{
				vertex = new JNumber3D(this.Skin.geometry.vertices[i].x, this.Skin.geometry.vertices[i].y, this.Skin.geometry.vertices[i].z);
				JMatrix3D.multiplyVector(this.getTransform(), vertex);
				arr.push(vertex);
			}
			 
			return arr;
		}
		 
		public function GetSqDistanceToPoint(closestBoxPoint:Object, point:JNumber3D):Number
		{
			closestBoxPoint.pos = JNumber3D.sub(point, this.Position);
			JMatrix3D.multiplyVector(JMatrix3D.Transpose(Orientation), closestBoxPoint.pos);
			
			var delta:Number = 0;
			var sqDistance:Number = 0;
			var halfSideLengths:JNumber3D = GetHalfSideLengths();
			
			if ( closestBoxPoint.pos.x < -halfSideLengths.x )
            {
				delta = closestBoxPoint.pos.x + halfSideLengths.x;
                sqDistance += (delta * delta);
                closestBoxPoint.pos.x = -halfSideLengths.x;
            }
            else if ( closestBoxPoint.pos.x > halfSideLengths.x )
            {
                delta = closestBoxPoint.pos.x - halfSideLengths.x;
                sqDistance += (delta * delta);
                closestBoxPoint.pos.x = halfSideLengths.x;
            }
			 
            if ( closestBoxPoint.pos.y < -halfSideLengths.y )
            {
                delta = closestBoxPoint.pos.y + halfSideLengths.y;
                sqDistance += (delta * delta);
                closestBoxPoint.pos.y = -halfSideLengths.y;
            }
            else if ( closestBoxPoint.pos.y > halfSideLengths.y )
            {
                delta = closestBoxPoint.pos.y - halfSideLengths.y;
                sqDistance += (delta * delta);
                closestBoxPoint.pos.y = halfSideLengths.y;
            }
             
            if ( closestBoxPoint.pos.z < -halfSideLengths.z )
            {
                delta = closestBoxPoint.pos.z + halfSideLengths.z;
                sqDistance += (delta * delta);
                closestBoxPoint.pos.z = -halfSideLengths.z;
            }
            else if ( closestBoxPoint.pos.z > halfSideLengths.z )
            {
                delta = (closestBoxPoint.pos.z - halfSideLengths.z);
                sqDistance += (delta * delta);
                closestBoxPoint.pos.z = halfSideLengths.z;
            }
			JMatrix3D.multiplyVector(Orientation, closestBoxPoint.pos);
			closestBoxPoint.pos = JNumber3D.add(this.Position, closestBoxPoint.pos);
            return sqDistance;
		}
		
		public function GetDistanceToPoint(closestBoxPoint:Object, point:JNumber3D):Number
		{
			return Math.sqrt(GetSqDistanceToPoint(closestBoxPoint, point));
		}
		
		public function PointIntersect(pos:JNumber3D):Boolean
		{
			var p:JNumber3D=JNumber3D.sub(pos,Position);
			var h:JNumber3D = JNumber3D.multiply(SideLengths, 0.5);
			var dirVec:JNumber3D;
			for(var dir:int;dir<3;dir++)
			{
				dirVec=Orientation.getCols()[dir].clone();
				dirVec.normalize();
				if(Math.abs(JNumber3D.dot(dirVec,p))>h.toArray()[dir]+JNumber3D.NUM_TINY)
				{
					return false;
				}
			}
			return true;
		}
		 
		public function SegmentIntersect(out:Object,seg:JSegment):Boolean
		{
			out.posOut = new JNumber3D();
			
			var frac:Number = JNumber3D.NUM_HUGE;
			var min:Number = -JNumber3D.NUM_HUGE;
			var max:Number = JNumber3D.NUM_HUGE;
			var dirMin:Number = 0;
			var dirMax:Number = 0;
			var dir:Number = 0;
			var p:JNumber3D = JNumber3D.sub(Position, seg.Origin);
			var h:JNumber3D = JNumber3D.multiply(SideLengths, 0.5);
			
			var tempV:JNumber3D;
			var e:Number;
			var f:Number;
			var t:Number;
			var t1:Number;
			var t2:Number;
			for (dir = 0; dir < 3; dir++)
			{
				e = JNumber3D.dot(Orientation.getCols()[dir], p);
				f = JNumber3D.dot(Orientation.getCols()[dir], seg.Delta);
				if (Math.abs(f) > 0)
				{
					t1 = (e + h.toArray()[dir]) / f;
					t2 = (e - h.toArray()[dir]) / f;
					if (t1 > t2)
					{
						t = t1;
						t1 = t2;
						t2 = t;
					}
					if (t1 > min)
					{
						min = t1;
                        dirMin = dir;
					}
					if (t2 < max) 
                    {
                        max = t2;
                        dirMax = dir;
                    }
					if (min > max) return false;
                    if (max < 0) return false;
				}
				else if ( -e - h.toArray()[dir] > 0 || -e + h.toArray()[dir] < 0)
				{
					return false;
				}
			}
			
			if (min > 0)
            {
                dir = dirMin;
                frac = min;
            }
			else
			{
				dir = dirMax;
                frac = max;
			}
			if (frac < 0) frac = 0;
			if (frac > 1) frac = 1;
			if(frac>0.999999)
			{
				return false;
			}
			out.posOut = seg.GetPoint(frac);
			
			return true;
		}
		
		override public function GetInertiaProperties(mass:Number):JMatrix3D
		{
			var inertiaTensor:JMatrix3D = new JMatrix3D();
			inertiaTensor.n11 = (mass / 12) * (SideLengths.y * SideLengths.y + SideLengths.z * SideLengths.z);
			inertiaTensor.n22 = (mass / 12) * (SideLengths.x * SideLengths.x + SideLengths.z * SideLengths.z);
			inertiaTensor.n33 = (mass / 12) * (SideLengths.x * SideLengths.x + SideLengths.y * SideLengths.y);
			
			return inertiaTensor;
		}
		
	}
	
}