/// @param name

function __VinylClassPatternMulti(_name) constructor
{
    static __patternType = "multi";
    
    __name = _name;
    
    
    
    static toString = function()
    {
        return "<multi " + string(__name) + ">";
    }
    
    #region Initialize
    
    static __Initialize = function(_patternData = {}, _labelDict, _knobDict)
    {
        __assetArray = _patternData[$ "assets"] ?? (_patternData[$ "asset"] ?? []);
        
        //Convert any basic patterns into audio asset indexes
        var _i = 0;
        repeat(array_length(__assetArray))
        {
            var _pattern = __assetArray[_i];
            if (asset_get_type(_pattern) == asset_sound) __assetArray[@ _i] = asset_get_index(_pattern);
            ++_i;
        }
        
        
        
        //Set the gain/pitch state from the provided struct
        var _gain            = _patternData[$ "gain"        ] ?? (VINYL_CONFIG_DECIBEL_GAIN? 0 : 1);
        var _pitch           = _patternData[$ "pitch"       ] ?? (VINYL_CONFIG_PERCENTAGE_PITCH? 100 : 1);
        var _effectChainName = _patternData[$ "effect chain"];
        var _blend           = _patternData[$ "blend"       ] ?? undefined;
        var _sync            = _patternData[$ "sync"        ] ?? false;
        
        if (VINYL_CONFIG_DECIBEL_GAIN) _gain = __VinylGainToAmplitude(_gain);
        if (VINYL_CONFIG_PERCENTAGE_PITCH) _pitch /= 100;
        
        
        
        if (!is_numeric(_gain)) __VinylError("Error in pattern ", self, "\nGain must be a number");
        __gain = _gain;
        
        if (is_numeric(_pitch) && (_pitch >= 0))
        {
            __pitchLo = _pitch;
            __pitchHi = _pitch;
        }
        else if (is_array(_pitch))
        {
            if (array_length(_pitch) != 2) __VinylError("Error in pattern ", self, "\nPitch array must have exactly two elements (length=", array_length(_pitch), ")");
            
            __pitchLo = _pitch[0];
            __pitchHi = _pitch[1];
            
            if (__pitchLo > __pitchHi)
            {
                __VinylTrace("Warning! Error in pattern ", self, ". Low pitch (", __pitchLo, ") is greater than high pitch (", __pitchHi, ")");
                var _temp = __pitchLo;
                __pitchLo = __pitchHi;
                __pitchHi = _temp;
            }
        }
        else
        {
            __VinylError("Error in pattern ", self, "\nPitch must be either a number greater than or equal to zero, or a two-element array");
        }
        
        __effectChainName = _effectChainName;
        
        if ((!is_undefined(_blend) && !is_numeric(_blend))
        ||  (is_numeric(_blend) && ((_blend < 0) || (_blend > 1))))
        {
            __VinylError("Error in pattern ", self, "\nBlend must be a number between 0 and 1 (inclusive)");
        }
        
        __blend = _blend;
        
        if (!is_bool(_sync))
        {
            __VinylError("Error in pattern ", self, "\nSync must be a boolean (<true> or <false>)");
        }
        
        __sync = _sync;
        
        __labelArray = [];
        __labelDictTemp__ = {}; //Removed at the end of VinylSystemReadConfig()
        
        
        
        //Process label string to extract each label name
        var _labelNameArray = _patternData[$ "label"] ?? _patternData[$ "labels"];
        if (is_string(_labelNameArray)) _labelNameArray = [_labelNameArray];
        
        if (is_array(_labelNameArray))
        {
            var _i = 0;
            repeat(array_length(_labelNameArray))
            {
                var _labelName =_labelNameArray[_i];
                
                var _labelData = _labelDict[$ _labelName];
                if (_labelData == undefined)
                {
                    __VinylTrace("Warning! Label \"", _labelName, "\" could not be found (", self, ")");
                }
                else
                {
                    _labelData.__BuildAssetLabelArray(__labelArray, __labelDictTemp__);
                }
                
                ++_i;
            }
        }
        
        if (VINYL_DEBUG_READ_CONFIG) __VinylTrace("Created ", self, ", gain=", __gain, ", pitch=", __pitchLo, " -> ", __pitchHi, ", label=", __VinylDebugLabelNames(_labelArray));
    }
    
    #endregion
    
    
    
    static __Play = function(_emitter, _sound, _loop = false, _gain = 1, _pitch = 1, _pan = undefined)
    {
        static __pool = __VinylGlobalData().__poolMulti;
        
        var _instance = __pool.__Depool();
        _instance.__Play(_emitter, __assetArray, _loop, _gain, _pitch, _pan, __blend,  __sync);
        
        return _instance;
    }
    
    static __PlaySimple = function(_sound, _gain = 1, _pitch = 1)
    {
        __VinylError("Cannot use VinylPlaySimple() with a multi pattern");
    }
}