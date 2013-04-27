package ld26;

import ru.stablex.ui.widgets.Bmp;


/**
* Blocks for features base class
*
*/
class Block extends Bmp {

    //block position in feature/project structure
    public var col : Int = 0;
    public var row : Int = 0;
    //block position in game field
    public var absCol (get_absCol,never) : Int;
    public var absRow (get_absRow,never) : Int;

/*******************************************************************************
*       STATIC METHODS
*******************************************************************************/



/*******************************************************************************
*       INSTANCE METHODS
*******************************************************************************/


/*******************************************************************************
*       GETTERS / SETTERS
*******************************************************************************/


    /**
    * Getter `absCol`.
    *
    */
    private inline function get_absCol () : Int {
        return (
            Std.is(this.parent, Feature)
                ? cast(this.parent, Feature).col + this.col
                : this.col //project positions match game field positions
        );
    }//function get_absCol


    /**
    * Getter `absRow`.
    *
    */
    private inline function get_absRow () : Int {
        return (
            Std.is(this.parent, Feature)
                ? cast(this.parent, Feature).row + this.row
                : this.row //project positions match game field positions
        );
    }//function get_absRow

}//class Block