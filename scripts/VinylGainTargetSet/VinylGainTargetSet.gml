/// Sets the input gain target for a Vinyl playback instance, or a Vinyl label
/// The input gain will approach the target smoothly over a few frames, determined by the rate
/// 
/// If this function is given a label name then all currently playing audio assigned with that label will
/// be affected by the change in the label's gain state
/// 
/// This function will not affect currently playing audio played using VinylPlaySimple()
/// 
/// @param vinylID/labelName
/// @param targetGain
/// @param [rate=VINYL_DEFAULT_GAIN_RATE]

function VinylGainTargetSet(_id, _targetGain, _rate = VINYL_DEFAULT_GAIN_RATE)
{
    static _globalData = __VinylGlobalData();
    static _idToInstanceDict = _globalData.__idToInstanceDict;
    
    var _instance = _idToInstanceDict[? _id];
    if (is_struct(_instance)) return _instance.__GainTargetSet(_targetGain, _rate);
    
    var _label = _globalData.__labelDict[$ _id];
    if (is_struct(_label)) return _label.__GainTargetSet(_targetGain, _rate);
    
    __VinylTrace("Warning! Failed to execute VinylGainTargetSet() for ", _id);
}