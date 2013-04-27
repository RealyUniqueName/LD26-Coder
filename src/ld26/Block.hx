package ld26;

import nme.geom.Point;
import nme.Lib;
import ru.stablex.ui.UIBuilder;
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

    /**
    * Create the same block
    *
    */
    public inline function clone () : Block {
        return UIBuilder.create(Block, {
            src  : this.src,
            left : this.left,
            top  : this.top,
            col  : this.col,
            row  : this.row
        });
    }//function clone()


    /**
    * Animate refactoring
    *
    */
    public function refactored () : Void {
        var p : Point = this.localToGlobal(new Point(0, 0));
        this.left = p.x;
        this.top  = p.y;
        Lib.current.addChild(this);

        this.filters = [new nme.filters.DropShadowFilter(6)];

        var destY    : Float = Lib.current.stage.stageHeight + this.h * 2;
        var distance : Float = destY - this.y;
        var duration : Float = distance / 200;

        this.tween(duration, {
            x        : p.x - 10 + 20 * Math.random(),
            rotation : -10 + 20 * Math.random()
        }, "Quad.easeOut");

        this.tween(duration, {
            y : destY
        }, "Back.easeIn").onComplete(this.free, [true]);
    }//function refactored()


    /**
    * Tween this block to specified position
    *
    */
    public function moveTo (col:Int, row:Int) : Void {
        this.col = col;
        this.row = row;
        this.tween(0.1,{
            left : this.col * Main.cfg.block.size,
            top  : this.row * Main.cfg.block.size,
        }, "Quad.easeOut");
    }//function moveTo()


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