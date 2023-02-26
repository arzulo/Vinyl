/// @param name

function __VinylClassEffectChain(_name) constructor
{
    static __globalData = __VinylGlobalData();
    
    
    
    __name = _name;
    
    if (_name == "main")
    {
        __bus     = audio_bus_main;
        __emitter = undefined;
    }
    else
    {
        __bus = audio_bus_create();
        
        audio_falloff_set_model(audio_falloff_none);
        __emitter = audio_emitter_create();
        audio_emitter_position(__emitter, __globalData.__listenerX, __globalData.__listenerY, 0);
        audio_emitter_velocity(__emitter, 0, 0, 0);
        audio_emitter_gain(__emitter, 1);
        audio_emitter_falloff(__emitter, 1000, 1001, 1);
        audio_emitter_bus(__emitter, __bus);
        audio_falloff_set_model(__VINYL_FALLOFF_MODEL);
    }
    
    
    
    static toString = function()
    {
        return "<effect chain " + string(__name) + ">";
    }
    
    static __GetEmitter = function()
    {
        return __emitter;
    }
    
    static __InstanceAdd = function(_id)
    {
        //Do nothing
    }
    
    static __InstanceRemove = function(_id)
    {
        //Do nothing
    }
    
    static __Update = function(_busEffectArray)
    {
        var _knobDict = __VinylGlobalData().__knobDict;
        
        var _i = 0;
        repeat(array_length(_busEffectArray))
        {
            var _effectData = _busEffectArray[_i];
            var _effectType = string_lower(_effectData.type);
            
            var _effect = __bus.effects[_i];
            var _gmType = undefined;
            
            //Determine which effect to use
            if (_effectType == "bitcrusher")
            {
                _gmType = AudioEffectType.Bitcrusher;
            }
            else if (_effectType == "delay")
            {
                _gmType = AudioEffectType.Delay;
            }
            else if (_effectType == "gain")
            {
                _gmType = AudioEffectType.Gain;
            }
            else if ((_effectType == "hpf") || (_effectType == "hpf2"))
            {
                _gmType = AudioEffectType.HPF2;
            }
            else if ((_effectType == "lpf") || (_effectType == "lpf2"))
            {
                _gmType = AudioEffectType.LPF2;
            }
            else if ((_effectType == "reverb") || (_effectType == "reverb1"))
            {
                _gmType = AudioEffectType.Reverb1;
            }
            else if (_effectType == "tremolo")
            {
                _gmType = AudioEffectType.Tremolo;
            }
            else
            {
                __VinylError("Effect type \"", _effectType, "\" not recognised (", self, " index=", _i, ")");
            }
            
            //If the old effect is of a different type, make a new one
            if ((_effect == undefined) || (_effect.type != _gmType))
            {
                _effect = audio_effect_create(_gmType);
                __bus.effects[_i] = _effect;
            }
            
            //Set values for the effect
            var _effectDataNameArray = variable_struct_get_names(_effectData);
            var _j = 0;
            repeat(array_length(_effectDataNameArray))
            {
                var _effectDataField = _effectDataNameArray[_j];
                if (_effectDataField != "type")
                {
                    var _value = _effectData[$ _effectDataField];
                    
                    //Special case for tremolo shape
                    if (_effectDataField == "shape")
                    {
                        if (_value == "sine")
                        {
                            _effect[$ _effectDataField] = AudioLFOType.Sine;
                        }
                        else if (_value == "square")
                        {
                            _effect[$ _effectDataField] = AudioLFOType.Square;
                        }
                        else if (_value == "triangle")
                        {
                            _effect[$ _effectDataField] = AudioLFOType.Triangle;
                        }
                        else if (_value == "sawtooth")
                        {
                            _effect[$ _effectDataField] = AudioLFOType.Sawtooth;
                        }
                        else if (_value == "inverse sawtooth")
                        {
                            _effect[$ _effectDataField] = AudioLFOType.InvSawtooth;
                        }
                        else
                        {
                            __VinylError("Tremolo effect shape type \"", _value, "\" not recognised");
                        }
                    }
                    else
                    {
                        //Handle knobs
                        if (is_string(_value))
                        {
                            if (string_char_at(_value, 1) == "@")
                            {
                                var _knobName = string_delete(_value, 1, 1);
                                var _knob = _knobDict[$ _knobName];
                                if (!is_struct(_knob)) __VinylError("Error in ", self, " for effect ", _i, "'s ", _effectDataField, " property\nKnob \"", _knobName, "\" doesn't exist");
                                
                                _knob.__TargetCreate(_effect, _effectDataField);
                                _value = _knob.__OutputGet(); //Set parameter to the current value of the knob
                            }
                            else
                            {
                                __VinylError("Error in ", self, " for effect ", _i, "'s ", _effectDataField, " property\nEffect parameters must be a number or a knob name");
                            }
                        }
                        
                        //Set the actual value, finally
                        _effect[$ _effectDataField] = _value;
                    }
                }
                
                ++_j;
            }
            
            if (VINYL_DEBUG_READ_CONFIG) __VinylTrace("Effect chain ", self, " effects[", _i, "] = ", json_stringify(_effect));
            
            ++_i;
        }
        
        //Finish out the rest of the effect chain with <undefined>
        repeat(8 - _i)
        {
            __bus.effects[_i] = undefined;
            if (VINYL_DEBUG_READ_CONFIG) __VinylTrace("Effect chain ", self, " effects[", _i, "] = undefined");
            
            ++_i;
        }
    }
    
    static __Destroy = function()
    {
        if (__emitter != undefined)
        {
            audio_emitter_free(__emitter);
            __emitter = undefined;
        }
    }
    
    static __UpdatePosition = function()
    {
        //Keep this emitter right underneath the listener
        if (__emitter != undefined) audio_emitter_position(__emitter, __globalData.__listenerX, __globalData.__listenerY, 0);
    }
}