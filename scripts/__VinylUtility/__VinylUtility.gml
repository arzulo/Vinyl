function __VinylSemitoneToPitch(_semitone)
{
    return power(2, _semitone/12);
}

function __VinylPitchToSemitone(_pitch)
{
    return (_pitch <= 0)? -infinity : (ln(_pitch)*17.3123404906675608883190961); //12 * ln(2)
}

function __VinylGainToAmplitude(_gain)
{
    return power(10, _gain/20);
}

function __VinylAmplitudeToGain(_amplitudeCoeff)
{
    return ((_amplitudeCoeff <= 0)? -infinity : 20*log10(_amplitudeCoeff));
}