package hy.game.stage3D.utils
{
    import flash.geom.Matrix;
    import flash.geom.Matrix3D;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.geom.Vector3D;
    
    public class SVertexData 
    {
        /** The total number of elements (Numbers) stored per vertex. */
        public static const ELEMENTS_PER_VERTEX:int = 4;
        
        /** The offset of position data (x, y) within a vertex. */
        public static const POSITION_OFFSET:int = 0;
        
        /** The offset of texture coordinates (u, v) within a vertex. */
        public static const TEXCOORD_OFFSET:int = 2;
        
        private var mRawData:Vector.<Number>;
        private var mNumVertices:int;

        /** Helper object. */
        private static var sHelperPoint:Point = new Point();
        private static var sHelperPoint3D:Vector3D = new Vector3D();
        
        /** Create a new VertexData object with a specified number of vertices. */
        public function SVertexData(numVertices:int)
        {
            mRawData = new <Number>[];
            this.numVertices = numVertices;
        }

        /** Creates a duplicate of either the complete vertex data object, or of a subset. 
         *  To clone all vertices, set 'numVertices' to '-1'. */
        public function clone(vertexID:int=0, numVertices:int=-1):SVertexData
        {
            if (numVertices < 0 || vertexID + numVertices > mNumVertices)
                numVertices = mNumVertices - vertexID;
            
            var clone:SVertexData = new SVertexData(0);
            clone.mNumVertices = numVertices;
            clone.mRawData = mRawData.slice(vertexID * ELEMENTS_PER_VERTEX,
                                         numVertices * ELEMENTS_PER_VERTEX);
            clone.mRawData.fixed = true;
            return clone;
        }
        
        /** Copies the vertex data (or a range of it, defined by 'vertexID' and 'numVertices') 
         *  of this instance to another vertex data object, starting at a certain index. */
        public function copyTo(targetData:SVertexData, targetVertexID:int=0,
                               vertexID:int=0, numVertices:int=-1):void
        {
            copyTransformedTo(targetData, targetVertexID, null, vertexID, numVertices);
        }
        
        /** Transforms the vertex position of this instance by a certain matrix and copies the
         *  result to another VertexData instance. Limit the operation to a range of vertices
         *  via the 'vertexID' and 'numVertices' parameters. */
        public function copyTransformedTo(targetData:SVertexData, targetVertexID:int=0,
                                          matrix:Matrix=null,
                                          vertexID:int=0, numVertices:int=-1):void
        {
            if (numVertices < 0 || vertexID + numVertices > mNumVertices)
                numVertices = mNumVertices - vertexID;
            
            var x:Number, y:Number;
            var targetRawData:Vector.<Number> = targetData.mRawData;
            var targetIndex:int = targetVertexID * ELEMENTS_PER_VERTEX;
            var sourceIndex:int = vertexID * ELEMENTS_PER_VERTEX;
            var sourceEnd:int = (vertexID + numVertices) * ELEMENTS_PER_VERTEX;
            
            if (matrix)
            {
                while (sourceIndex < sourceEnd)
                {
                    x = mRawData[int(sourceIndex++)];
                    y = mRawData[int(sourceIndex++)];
                    
                    targetRawData[int(targetIndex++)] = matrix.a * x + matrix.c * y + matrix.tx;
                    targetRawData[int(targetIndex++)] = matrix.d * y + matrix.b * x + matrix.ty;
                    targetRawData[int(targetIndex++)] = mRawData[int(sourceIndex++)];
                    targetRawData[int(targetIndex++)] = mRawData[int(sourceIndex++)];
                }
            }
            else
            {
                while (sourceIndex < sourceEnd)
                    targetRawData[int(targetIndex++)] = mRawData[int(sourceIndex++)];
            }
        }
        
        /** Appends the vertices from another VertexData object. */
        public function append(data:SVertexData):void
        {
            mRawData.fixed = false;
            
            var targetIndex:int = mRawData.length;
            var rawData:Vector.<Number> = data.mRawData;
            var rawDataLength:int = rawData.length;
            
            for (var i:int=0; i<rawDataLength; ++i)
                mRawData[int(targetIndex++)] = rawData[i];
            
            mNumVertices += data.numVertices;
            mRawData.fixed = true;
        }
        
        // functions
        
        /** Updates the position values of a vertex. */
        public function setPosition(vertexID:int, x:Number, y:Number):void
        {
            var offset:int = vertexID * ELEMENTS_PER_VERTEX + POSITION_OFFSET;
            mRawData[offset] = x;
            mRawData[int(offset+1)] = y;
        }
        
        /** Returns the position of a vertex. */
        public function getPosition(vertexID:int, position:Point):void
        {
            var offset:int = vertexID * ELEMENTS_PER_VERTEX + POSITION_OFFSET;
            position.x = mRawData[offset];
            position.y = mRawData[int(offset+1)];
        }
        
        /** Updates the texture coordinates of a vertex (range 0-1). */
        public function setTexCoords(vertexID:int, u:Number, v:Number):void
        {
            var offset:int = vertexID * ELEMENTS_PER_VERTEX + TEXCOORD_OFFSET;
            mRawData[offset]        = u;
            mRawData[int(offset+1)] = v;
        }
        
        /** Returns the texture coordinates of a vertex in the range 0-1. */
        public function getTexCoords(vertexID:int, texCoords:Point):void
        {
            var offset:int = vertexID * ELEMENTS_PER_VERTEX + TEXCOORD_OFFSET;
            texCoords.x = mRawData[offset];
            texCoords.y = mRawData[int(offset+1)];
        }
        
        // utility functions
        
        /** Translate the position of a vertex by a certain offset. */
        public function translateVertex(vertexID:int, deltaX:Number, deltaY:Number):void
        {
            var offset:int = vertexID * ELEMENTS_PER_VERTEX + POSITION_OFFSET;
            mRawData[offset]        += deltaX;
            mRawData[int(offset+1)] += deltaY;
        }

        /** Transforms the position of subsequent vertices by multiplication with a 
         *  transformation matrix. */
        public function transformVertex(vertexID:int, matrix:Matrix, numVertices:int=1):void
        {
            var x:Number, y:Number;
            var offset:int = vertexID * ELEMENTS_PER_VERTEX + POSITION_OFFSET;
            
            for (var i:int=0; i<numVertices; ++i)
            {
                x = mRawData[offset];
                y = mRawData[int(offset+1)];
                
                mRawData[offset]        = matrix.a * x + matrix.c * y + matrix.tx;
                mRawData[int(offset+1)] = matrix.d * y + matrix.b * x + matrix.ty;
                
                offset += ELEMENTS_PER_VERTEX;
            }
        }
        
        /** Calculates the bounds of the vertices, which are optionally transformed by a matrix. 
         *  If you pass a 'resultRect', the result will be stored in this rectangle 
         *  instead of creating a new object. To use all vertices for the calculation, set
         *  'numVertices' to '-1'. */
        public function getBounds(transformationMatrix:Matrix=null, 
                                  vertexID:int=0, numVertices:int=-1,
                                  resultRect:Rectangle=null):Rectangle
        {
            if (resultRect == null) resultRect = new Rectangle();
            if (numVertices < 0 || vertexID + numVertices > mNumVertices)
                numVertices = mNumVertices - vertexID;
            
            if (numVertices == 0)
            {
                if (transformationMatrix == null)
                    resultRect.setEmpty();
                else
                {
                    SMatrixUtil.transformCoords(transformationMatrix, 0, 0, sHelperPoint);
                    resultRect.setTo(sHelperPoint.x, sHelperPoint.y, 0, 0);
                }
            }
            else
            {
                var minX:Number = Number.MAX_VALUE, maxX:Number = -Number.MAX_VALUE;
                var minY:Number = Number.MAX_VALUE, maxY:Number = -Number.MAX_VALUE;
                var offset:int = vertexID * ELEMENTS_PER_VERTEX + POSITION_OFFSET;
                var x:Number, y:Number, i:int;
                
                if (transformationMatrix == null)
                {
                    for (i=0; i<numVertices; ++i)
                    {
                        x = mRawData[offset];
                        y = mRawData[int(offset+1)];
                        offset += ELEMENTS_PER_VERTEX;
                        
                        if (minX > x) minX = x;
                        if (maxX < x) maxX = x;
                        if (minY > y) minY = y;
                        if (maxY < y) maxY = y;
                    }
                }
                else
                {
                    for (i=0; i<numVertices; ++i)
                    {
                        x = mRawData[offset];
                        y = mRawData[int(offset+1)];
                        offset += ELEMENTS_PER_VERTEX;
                        
                        SMatrixUtil.transformCoords(transformationMatrix, x, y, sHelperPoint);
                        
                        if (minX > sHelperPoint.x) minX = sHelperPoint.x;
                        if (maxX < sHelperPoint.x) maxX = sHelperPoint.x;
                        if (minY > sHelperPoint.y) minY = sHelperPoint.y;
                        if (maxY < sHelperPoint.y) maxY = sHelperPoint.y;
                    }
                }
                
                resultRect.setTo(minX, minY, maxX - minX, maxY - minY);
            }
            
            return resultRect;
        }
        
        /** Calculates the bounds of the vertices, projected into the XY-plane of a certain
         *  3D space as they appear from a certain camera position. Note that 'camPos' is expected
         *  in the target coordinate system (the same that the XY-plane lies in).
         *  If you pass a 'resultRectangle', the result will be stored in this rectangle
         *  instead of creating a new object. To use all vertices for the calculation, set
         *  'numVertices' to '-1'. */
        public function getBoundsProjected(transformationMatrix:Matrix3D, camPos:Vector3D,
                                           vertexID:int=0, numVertices:int=-1,
                                           resultRect:Rectangle=null):Rectangle
        {
            if (camPos == null) throw new ArgumentError("camPos must not be null");
            if (resultRect == null) resultRect = new Rectangle();
            if (numVertices < 0 || vertexID + numVertices > mNumVertices)
                numVertices = mNumVertices - vertexID;

            if (numVertices == 0)
            {
                if (transformationMatrix)
                    SMatrixUtil.transformCoords3D(transformationMatrix, 0, 0, 0, sHelperPoint3D);
                else
                    sHelperPoint3D.setTo(0, 0, 0);

                SMathUtil.intersectLineWithXYPlane(camPos, sHelperPoint3D, sHelperPoint);
                resultRect.setTo(sHelperPoint.x, sHelperPoint.y, 0, 0);
            }
            else
            {
                var minX:Number = Number.MAX_VALUE, maxX:Number = -Number.MAX_VALUE;
                var minY:Number = Number.MAX_VALUE, maxY:Number = -Number.MAX_VALUE;
                var offset:int = vertexID * ELEMENTS_PER_VERTEX + POSITION_OFFSET;
                var x:Number, y:Number, i:int;

                for (i=0; i<numVertices; ++i)
                {
                    x = mRawData[offset];
                    y = mRawData[int(offset+1)];
                    offset += ELEMENTS_PER_VERTEX;

                    if (transformationMatrix)
                        SMatrixUtil.transformCoords3D(transformationMatrix, x, y, 0, sHelperPoint3D);
                    else
                        sHelperPoint3D.setTo(x, y, 0);

                    SMathUtil.intersectLineWithXYPlane(camPos, sHelperPoint3D, sHelperPoint);

                    if (minX > sHelperPoint.x) minX = sHelperPoint.x;
                    if (maxX < sHelperPoint.x) maxX = sHelperPoint.x;
                    if (minY > sHelperPoint.y) minY = sHelperPoint.y;
                    if (maxY < sHelperPoint.y) maxY = sHelperPoint.y;
                }
                resultRect.setTo(minX, minY, maxX - minX, maxY - minY);
            }
            return resultRect;
        }

        /** Creates a string that contains the values of all included vertices. */
        public function toString():String
        {
            var result:String = "[VertexData \n";
            var position:Point = new Point();
            var texCoords:Point = new Point();
            
            for (var i:int=0; i<numVertices; ++i)
            {
                getPosition(i, position);
                getTexCoords(i, texCoords);
                
                result += "  [Vertex " + i + ": " +
                    "x="   + position.x.toFixed(1)    + ", " +
                    "y="   + position.y.toFixed(1)    + ", " +
                    "u="   + texCoords.x.toFixed(4)   + ", " +
                    "v="   + texCoords.y.toFixed(4)   + "]"  +
                    (i == numVertices-1 ? "\n" : ",\n");
            }
            
            return result + "]";
        }
        
        
        /** The total number of vertices. */
        public function get numVertices():int { return mNumVertices; }
        public function set numVertices(value:int):void
        {
            mRawData.fixed = false;
            mRawData.length = value * ELEMENTS_PER_VERTEX;
            
            var startIndex:int = mNumVertices * ELEMENTS_PER_VERTEX  + 3;
            var endIndex:int = mRawData.length;
            
            for (var i:int=startIndex; i<endIndex; i += ELEMENTS_PER_VERTEX)
                mRawData[i] = 1.0; // alpha should be '1' per default
            
            mNumVertices = value;
            mRawData.fixed = true;
        }
        
        /** The raw vertex data; not a copy! */
        public function get rawData():Vector.<Number> { return mRawData; }
    }
}
