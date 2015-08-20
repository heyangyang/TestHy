// =================================================================================================
//
//	Starling Framework
//	Copyright 2011-2014 Gamua. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package hy.game.stage3D.texture
{
    import hy.game.stage3D.errors.AbstractClassError;

    /** A class that provides constant values for the possible smoothing algorithms of a texture. */ 
    public class STextureSmoothing
    {
        /** @private */
        public function STextureSmoothing() { throw new AbstractClassError(); }
        
        /** No smoothing, also called "Nearest Neighbor". Pixels will scale up as big rectangles. */
        public static const NONE:String      = "none";
        
        /** Bilinear filtering. Creates smooth transitions between pixels. */
        public static const BILINEAR:String  = "bilinear";
        
        /** Trilinear filtering. Highest quality by taking the next mip map level into account. */
        public static const TRILINEAR:String = "trilinear";
        
        /** Determines whether a smoothing value is valid. */
        public static function isValid(smoothing:String):Boolean
        {
            return smoothing == NONE || smoothing == BILINEAR || smoothing == TRILINEAR;
        }
    }
}