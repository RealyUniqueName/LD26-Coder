package ld26;

import motion.Actuate;
import ru.stablex.Err;
import ru.stablex.ui.UIBuilder;
import ru.stablex.ui.widgets.Widget;
import motion.actuators.GenericActuator;


/**
* Features (figures)
*
*/
class Feature extends Widget{

    //Feature structure
    public var blocks (default,set_blocks) : Array<Array<Int>>;
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
    //if this feature was dropped
    public var dropped : Bool = false;
    //timer for movement steps
    public var actuateTimer : IGenericActuator;

/*******************************************************************************
*       STATIC METHODS
*******************************************************************************/

    /**
    * Create random feature
    *
    * @param max - maximum feature size (cols and rows)
    *
    */
    static public function rnd (max:Int = 3, min:Int = 2) : Feature {
        var rows = Std.random(max - min + 1) + min;
        var cols = Std.random(max - min + 1) + min;
        var tile = Std.random(Main.cfg.block.types.length - 2) + 1;

        //generate blocks
        var blocks : Array<Array<Int>> = [];
        for(c in 0...cols){
            blocks.push([]);
            for(r in 0...rows){
                //put random block
                blocks[c].push( Std.random(2) == 1 ? 0 : tile );
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
                    blocks[c][ Std.random(rows) ] = tile;
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
                    blocks[ Std.random(cols) ][r] = tile;
                }
            }
        //}

        //to make it rotatable
        if( rows > cols ){
            for(c in cols...rows){
                blocks.push([]);
                for(r in 0...rows){
                    blocks[c].push(0);
                }
            }
        }else if( cols > rows ){
            for(c in 0...cols){
                for(r in rows...cols){
                    blocks[c].push(0);
                }
            }
        }

        //create feature
        var f : Feature = UIBuilder.create(Feature, {
            blocks : blocks
        });

        return f;
    }//function rnd()


    /**
    * Rotate array clockwise
    *
    */
    static public function rotateArray<T> (arr:Array<Array<T>>) : Array<Array<T>> {
        var tmp  : Array<Array<T>> = [];
        for(c in 0...arr.length){
            tmp.push([]);
        }

        for(c in 0...arr.length){
            for(r in 0...arr.length){
                tmp[arr.length - r - 1][c] = arr[c][r];
            }
        }

        return tmp;
    }//function rotateArray<T>()

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
        if( col < 0 || col >= this.blocks.length || row < 0 || row >= this.blocks[0].length ){
            return null;
        }else{
            return this._blocks[col][row];
        }
    }//function getBlock()


    /**
    * Perform next step moving down
    *
    */
    public function step () : Void {
        this.actuateTimer = Actuate.timer(Level.speed).onComplete(this.performStep);
    }//function step()


    /**
    * Start moving
    *
    */
    public function performStep () : Void {
        //no space for further movement
        if( !this.canMove() ){
            this.level.featureStopped(this);

        //go
        }else{
            this.row ++;
            this.tween(Level.speed,{
                top : this.row * Main.cfg.block.size
            }, "Quad.easeOut").onComplete(this._finishStep);
        }
    }//function performStep()


    /**
    * Finish current step
    *
    */
    private function _finishStep () : Void {
        //start next step
        this.step();
    }//function _finishStep()


    /**
    * Check if feature can move down
    *
    */
    public function canMove () : Bool {
        // //reached bottom line of game field
        // if( this.rows + this.row >= Main.cfg.rows ){
        //     return false;
        // }

        //check bottom blocks in each column
        for(c in 0...this.cols){
            var b : Block = null;
            for(r in 0...this.rows){
                b = this.getBlock(c, this.rows - 1 - r);
                //next cell for this block is occupied in project
                if(
                    b != null
                    && (
                        b.absRow + 1 >= Main.cfg.rows
                        || this.level.project.blocks[b.absCol][b.absRow + 1] != null
                    )
                ){
                    return false;
                }
            }
        }

        return true;
    }//function canMove()


    /**
    * Rotate this feature left
    *
    */
    public function rotate (left:Bool) : Void {
        var tmp : Array<Array<Int>> = [];
        for(c in 0...this.cols){
            tmp.push([]);
        }

        for(c in 0...this.cols){
            for(r in 0...this.rows){
                if( left ){
                    tmp[r][this.cols - c - 1] = this.blocks[c][r];
                }else{
                    tmp[this.cols - r - 1][c] = this.blocks[c][r];
                }
            }
        }

        //check for collisions{
            var level = this.level;
            for(c in 0...this.cols){
                for(r in 0...this.rows){
                    if( level.project.blocks[this.col + c][this.row + r] != null && tmp[c][r] > 0 ){
                        return;
                    }
                }
            }
        //}

        this.blocks = tmp;

        //animate rotation
        var b : Block;
        for(c in 0...this.cols){
            for(r in 0...this.rows){
                b = this._blocks[c][r];
                if( left ){
                    if( b != null ) b.moveTo(r, this.cols - c - 1);
                }else{
                    if( b != null ) b.moveTo(this.cols - r - 1, c);
                }
            }//for(rows)
        }//for(cols)

        // //fix this._blocks {
        //     var tmp : Array<Array<Block>> = ;
        //     for(c in 0...this.cols){
        //         for(r in 0...this.rows){
        //             tmp = this._blocks[c][r];
        //             this._blocks[c][r]                 = this._blocks[this.cols - r - 1][c];
        //             this._blocks[this.cols - r - 1][c] = this._blocks[this.cols - c - 1][this.cols - r - 1];
        //             this._blocks[r][this.cols - c - 1] = tmp;
        //         }
        //     }
        // //}
    }//function rotateLeft()


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


    /**
    * Setter `blocks`.
    *
    */
    private function set_blocks (blocks:Array<Array<Int>>) : Array<Array<Int>> {
        //rotate structure
        for(i in 0...Std.random(4)){
            blocks = Feature.rotateArray(blocks);
        }

        //choose tile
        var tile = Std.random(Main.cfg.block.types.length - 1) + 1;
        for(c in 0...blocks.length){
            for(r in 0...blocks[0].length){
                if( blocks[c][r] != 0 ){
                    blocks[c][r] = tile;
                }
            }
        }

        this.resize(
            (blocks.length == 0 ? 0 : blocks.length * Main.cfg.block.size),
            (blocks.length == 0 || blocks[0].length == 0 ? 0 : blocks[0].length * Main.cfg.block.size)
        );
        return this.blocks = blocks;
    }//function set_blocks

}//class Feature