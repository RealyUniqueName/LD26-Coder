package ld26;


typedef TLevelCfg = {
    complexity : Int,   //initial project complexity
    speed      : Float, //from 0 to 1. Multiplier for default feature movement speed
    deadline   : Int,   //deadline time (seconds)
    features   : Int    //amount of features to implement to beat the level
}