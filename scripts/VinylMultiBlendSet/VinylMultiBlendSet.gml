/// Sets the blend factor for a Vinyl Multi instance, or Vinyl label
/// This gain is applied multiplicatively with the overall gain of the Multi instance
/// Setting a channel gain with this function overrides VinylMultiGainSet()
/// 
/// The blend factor smoothly interpolates the gain across channels in a Multi instance. The
/// blend factor should be a value from 0 to 1 (inclusive). Vinyl internally recalculates gain
/// per channel depending on the blend factor provided
/// 
/// If this function is given a label name then all current multi instances assigned to that label
/// will have their blend factor adjusted
/// 
/// @param vinylID
/// @param blendFactor

function VinylMultiBlendSet(_id, _blendFactor)
{
    static _globalData = __VinylGlobalData();
    static _idToInstanceDict = _globalData.__idToInstanceDict;
    
    var _instance = _idToInstanceDict[? _id];
    if (is_struct(_instance)) return _instance.__MultiBlendSet(_blendFactor);
    
    var _label = _globalData.__labelDict[$ _id];
    if (is_struct(_label)) return _label.__MultiBlendSet(_blendFactor);
    
    __VinylTrace("Warning! Failed to execute VinylMultiBlendSet() for ", _id);
}