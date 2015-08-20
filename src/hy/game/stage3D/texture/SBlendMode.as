package hy.game.stage3D.texture
{
    import flash.display3D.Context3DBlendFactor;
    
    import hy.game.stage3D.errors.AbstractClassError;
    
    public class SBlendMode
    {
        private static var sBlendFactors:Array = [ 
            // no premultiplied alpha
            { 
                "none"     : [ Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO ],
                "normal"   : [ Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA ],
                "add"      : [ Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.DESTINATION_ALPHA ],
                "multiply" : [ Context3DBlendFactor.DESTINATION_COLOR, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA ],
                "screen"   : [ Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE ],
                "erase"    : [ Context3DBlendFactor.ZERO, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA ],
                "below"    : [ Context3DBlendFactor.ONE_MINUS_DESTINATION_ALPHA, Context3DBlendFactor.DESTINATION_ALPHA ]
            },
            // premultiplied alpha
            { 
                "none"     : [ Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO ],
                "normal"   : [ Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA ],
                "add"      : [ Context3DBlendFactor.ONE, Context3DBlendFactor.ONE ],
                "multiply" : [ Context3DBlendFactor.DESTINATION_COLOR, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA ],
                "screen"   : [ Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR ],
                "erase"    : [ Context3DBlendFactor.ZERO, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA ],
                "below"    : [ Context3DBlendFactor.ONE_MINUS_DESTINATION_ALPHA, Context3DBlendFactor.DESTINATION_ALPHA ]
            }
        ];
        
        // predifined modes
        
        /** @private */
        public function SBlendMode() { throw new AbstractClassError(); }
        
        /** Inherits the blend mode from this display object's parent. */
        public static const AUTO:String = "auto";

        /** Deactivates blending, i.e. disabling any transparency. */
        public static const NONE:String = "none";
        
        /** The display object appears in front of the background. */
        public static const NORMAL:String = "normal";
        
        /** Adds the values of the colors of the display object to the colors of its background. */
        public static const ADD:String = "add";
        
        /** Multiplies the values of the display object colors with the the background color. */
        public static const MULTIPLY:String = "multiply";
        
        /** Multiplies the complement (inverse) of the display object color with the complement of 
          * the background color, resulting in a bleaching effect. */
        public static const SCREEN:String = "screen";
        
        /** Erases the background when drawn on a RenderTexture. */
        public static const ERASE:String = "erase";
        
		/** Draws under/below existing objects; useful especially on RenderTextures. */
	    public static const BELOW:String = "below";
	
        // accessing modes
        
        /** Returns the blend factors that correspond with a certain mode and premultiplied alpha
         *  value. Throws an ArgumentError if the mode does not exist. */
        public static function getBlendFactors(mode:String, premultipliedAlpha:Boolean=true):Array
        {
            var modes:Object = sBlendFactors[int(premultipliedAlpha)];
            if (mode in modes) return modes[mode];
            else throw new ArgumentError("Invalid blend mode");
        }
        
        /** Registeres a blending mode under a certain name and for a certain premultiplied alpha
         *  (pma) value. If the mode for the other pma value was not yet registered, the factors are
         *  used for both pma settings. */
        public static function register(name:String, sourceFactor:String, destFactor:String,
                                        premultipliedAlpha:Boolean=true):void
        {
            var modes:Object = sBlendFactors[int(premultipliedAlpha)];
            modes[name] = [sourceFactor, destFactor];
            
            var otherModes:Object = sBlendFactors[int(!premultipliedAlpha)];
            if (!(name in otherModes)) otherModes[name] = [sourceFactor, destFactor];
        }
    }
}