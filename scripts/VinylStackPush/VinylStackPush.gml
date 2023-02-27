/// @param name
/// @param priority
/// @param vinylID

function VinylStackPush(_name, _priority, _id)
{
    static _idToInstanceDict = __VinylGlobalData().__idToInstanceDict;
    static _stackDict        = __VinylGlobalData().__stackDict;
    
    var _instance = _idToInstanceDict[? _id];
    if (is_struct(_instance))
    {
        var _stack = _stackDict[$ _name];
        if (!is_struct(_stack))
        {
            __VinylTrace("Warning! Stack \"", _name, "\" not recognised");
            return;
        }
        
        return _stack.__Push(_priority, _instance, false);
    }
}