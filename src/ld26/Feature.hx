package ld26;

import motion.Actuate;
import ru.stablex.Err;
import ru.stablex.ui.UIBuilder;
import ru.stablex.ui.widgets.Widget;


/**
* Features (figures)
*
*/
class Feature extends Widget{

    //Feature structure
    public var blocks : Array<Array<Int>>;
    private var _blocks : Array<Array<Block>>;
    //get width in blocks for this feature
    public var cols (get_cols,never): Int;
    //get height in blocks for this feature
    public var rows (get_rows,never): Int;
    //Top-left block position for this feature
    public var col : Int = 0;
    public var row : Int = 0;
    //access currnet level instance
    public var level (get_level,never) : Level;

/*******************************************************************************
*       STATIC METHODS
*******************************************************************************/

    /**
    * Create random feature
    *
    */
    static public function rnd () : Feature {
        //max 4 blocks width/height
        var rows = Std.random(4) + 1;
        var cols = Std.random(4) + 1;

        //generate blocks
        var blocks : Array<Array<Int>> = [];
        for(c in 0...cols){
            blocks.push([]);
            for(r in 0...rows){
                //put random block
                blocks[c].push( Std.random(Main.cfg.block.types.length) );
            }
        }

        //place at least one block to empty rows and columns{
            var empty : Bool;

            //check empty columns
            for(c in 0...cols){
                empty = true;
                for(r in 0...rows){
                    if( blocks[c][r] != 0 ){
                        empty = false;
                        break;
                    }
                }
                if( empty ){
                    blocks[c][ Std.random(rows) ] = Std.random(Main.cfg.block.types.length - 1) + 1;
                }
            }

            //check empty rows
            for(r in 0...rows){
                empty = true;
                for(c in 0...cols){
                    if( blocks[c][r] != 0 ){
                        empty = false;
                        break;
                    }
                }
                if( empty ){
                    blocks[ Std.random(cols) ][r] = Std.random(Main.cfg.block.types.length - 1) + 1;
                }
            }
        //}

        var f : Feature = UIBuilder.create(Feature, {
            blocks : blocks
        });

        return f;
    }//function rnd()

/*******************************************************************************
*       INSTANCE METHODS
*******************************************************************************/

    /**
    * Randomize starting position on creation is complete
    *
    */
    override public function onCreate () : Void {
        super.onCreate();
        this.col  = Std.random(Main.cfg.cols - this.cols);
        this.left = this.col * Main.cfg.block.size;
    }//function onCreate()


    /**
    * On refresh, recreate blocks
    *
    */
    override public function refresh () : Void {
        super.refresh();
        this.freeChildren();

        if( this.blocks == null ) Err.trigger(".blocks is not set for feature");

        //create blocks
        this._blocks = [];
        for(c in 0...this.cols){
            this._blocks.push([]);
            for(r in 0...this.rows){
                //create block
                if( Main.cfg.block.types[ this.blocks[c][r] ] != null ){
                    this._blocks[c][r] = UIBuilder.create(Block, {
                        col  : c,
                        row  : r,
                        left : c * Main.cfg.block.size,
                        top  : r * Main.cfg.block.size,
                        src  : Main.cfg.block.types[ this.blocks[c][r] ]
                    });
                    this.addChild(this._blocks[c][r]);
                //empty cell
                }else{
                    this._blocks[c][r] = null;
                }
            }
        }
    }//function refresh()


    /**
    * Returns block object at specified position
    *
    */
    public inline function getBlock (col:Int, row:Int) : Null<Block> {
        return this._blocks[col][row];
    }//function getBlock()


    /**
    * Perform next step moving down
    *
    */
    public function step () : Void {
        Actuate.timer(Main.cfg.speed).onComplete(this._performStep);
    }//function step()


    /**
    * Start moving
    *
    */
    private function _performStep () : Void {
        //no space for further movement
        if( !this._canMove() ){
            this.level.featureStopped(this);

        //go
        }else{
            this.tween(Main.cfg.speed,{
                top : (this.row + 1) * Main.cfg.block.size
            }, "Quad.easeOut").onComplete(this._finishStep);
        }
    }//function _performStep()


    /**
    * Finish current step
    *
    */
    private function _finishStep () : Void {
        this.row ++;
        //start next step
        this.step();
    }//function _finishStep()


    /**
    * Check if feature can move down
    *
    */
    private function _canMove () : Bool {
        //reached bottom line of game field
        if( this.rows + this.row >= Main.cfg.rows ){
            return false;
        }

        //check bottom blocks in each column
        for(c in 0...this.cols){
            var b : Block = null;
            for(r in 0...this.rows){
                b = this.getBlock(c, this.rows - 1 - r);
                //next cell for this block is occupied in project
                if(
                    b != null
                    && this.level.project.blocks[b.absCol][b.absRow + 1] != null
                ){
                    return false;
                }
            }
        }

        return true;
    }//function _canMove()


/*******************************************************************************
*       GETTERS / SETTERS
*******************************************************************************/

    /**
    * Getter `cols`.
    *
    */
    private inline function get_cols () : Int {
        return (this.blocks == null ? 0 : this.blocks.length);
    }//function get_cols


    /**
    * Getter `rows`.
    *
    */
    private inline function get_rows () : Int {
        return (this.blocks == null || this.blocks.length == 0 ? 0 : this.blocks[0].length);
    }//function get_rows


    /**
    * Getter `level`.
    *
    */
    private inline function get_level () : Level {
        return UIBuilder.getAs("level", Level);
    }//function get_level

}//class Feature