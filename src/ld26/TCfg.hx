package ld26;


/**
* Game config
*
*/
typedef TCfg = {
    cols  : Int,    //columns of blocks in game field
    rows  : Int,    //rows of blocks in game field
    speed : Float,   //time for features to move down by one block
    block : {
        size  : Int,        // block size in pixels
        types : Array<String>
    }
}