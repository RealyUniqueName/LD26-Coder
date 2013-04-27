package ld26;

import nme.events.KeyboardEvent;
import nme.Lib;
import nme.ui.Keyboard;
import ru.stablex.ui.UIBuilder;
import ru.stablex.ui.widgets.Widget;


/**
* Player's project
*
*/
class Project extends Widget{

    //blocks in project
    public var blocks : Array<Array<Block>>;
    //Selector widget, which highlights user selection
    public var selector : Widget;
    //currently selected row
    public var selectedRow : Int = 0;
    //access currnet level instance
    public var level (get_level,never) : Level;

/*******************************************************************************
*       STATIC METHODS
*******************************************************************************/

    /**
    * Generate random project
    *
    */
    static public function rnd (complexity:Int) : Array<Array<Int>> {
        //create empty structure
        var blocks : Array<Array<Int>> = [];
        for(c in 0...Main.cfg.cols){
            blocks.push([]);
            for(r in 0...Main.cfg.rows){
                blocks[c].push(0);
            }
        }

        //calculate settings based on complexity{
            var rows  : Int = (complexity < 6 ? 3 : Std.int(complexity / 2));
            var holes : Int = Math.ceil(rows / 2);
        //}

        //fill structure
        var h : Array<Int> = [];
        for(r in 0...Main.cfg.rows){
            if( r + rows >= Main.cfg.rows ){
                //generate holes positions
                for(i in 0...holes) h[i] = Std.random(Main.cfg.cols);

                //set blocks types
                for(c in 0...Main.cfg.cols){
                    blocks[c][r] = (
                        Lambda.indexOf(h, c) >= 0
                            ? 0
                            : Std.random(Main.cfg.block.types.length - 1) + 1
                    );
                }//for(cols)
            }//if()
        }//for(rows)

        return blocks;
    }//function rnd()


/*******************************************************************************
*       INSTANCE METHODS
*******************************************************************************/

    /**
    * Constructor
    *
    */
    public function new () : Void {
        super();

        this.selectedRow = Main.cfg.rows - 1;

        //create empty project structure
        this.blocks = [];
        for(c in 0...Main.cfg.cols){
            this.blocks.push([]);
            for(r in 0...Main.cfg.rows){
                this.blocks[c].push(null);
            }
        }

        //listen to keyboard
        Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, this._onKeyDown);
    }//function new()


    /**
    * Handle creation
    *
    */
    override public function onCreate () : Void {
        super.onCreate();
        this.selector = this.getChild("selector");
    }//function onCreate()


    /**
    * Load project config
    *
    */
    public function load (blocks:Array<Array<Int>>) : Void {
        for(c in 0...blocks.length){
            for(r in 0...blocks[c].length){
                //create block
                if( Main.cfg.block.types[ blocks[c][r] ] != null ){
                    this.blocks[c][r] = UIBuilder.create(Block, {
                        col  : c,
                        row  : r,
                        left : c * Main.cfg.block.size,
                        top  : r * Main.cfg.block.size,
                        src  : Main.cfg.block.types[ blocks[c][r] ]
                    });
                    this.addChild(this.blocks[c][r]);
                //empty cell
                }else{
                    this.blocks[c][r] = null;
                }
            }
        }
    }//function load()


    /**
    * Add feature's blocks to project
    *
    */
    public function addFeature (f:Feature) : Void {
        var b : Block;

        for(c in 0...f.cols){
            for(r in 0...f.rows){

                b = f.getBlock(c, r);

                if( b != null ){
                    this.blocks[b.absCol][b.absRow] = b;
                    b.col  = b.absCol;
                    b.row  = b.absRow;
                    b.left = b.col * Main.cfg.block.size;
                    b.top  = b.row * Main.cfg.block.size;
                    this.addChild(b);
                }
            }
        }

        this.checkRefactoring();
    }//function addFeature()


    /**
    * Handle keys
    *
    */
    private function _onKeyDown (e:KeyboardEvent) : Void {
        //move selector up
        if( e.keyCode == Keyboard.UP && this.selectedRow > 0 ){
            this.selectedRow --;
            this.selector.tween(0.1, {top : this.selectedRow * Main.cfg.block.size});

        //move selector down
        }else if( e.keyCode == Keyboard.DOWN && this.selectedRow < Main.cfg.rows - 1 ){
            this.selectedRow ++;
            this.selector.tween(0.1, {top : this.selectedRow * Main.cfg.block.size});

        //move blocks left
        }else if( e.keyCode == Keyboard.LEFT ){
            this._moveBlocks(-1);

        //move blocks right
        }else if( e.keyCode == Keyboard.RIGHT ){
            this._moveBlocks(1);

        //drop feature
        }else if( e.keyCode == Keyboard.SPACE ){
            this.level.dropFeature();
        }
    }//function _onKeyDown()


    /**
    * Move blocks under selector
    * @param by - can be 1 or -1
    */
    private function _moveBlocks (by:Int) : Void {
        if( Math.abs(by) != 1 ) return;

        //copy row
        var row : Array<Block> = [];
        for(c in 0...Main.cfg.cols){
            row.push(this.blocks[c][this.selectedRow]);
        }

        //we don't want to collide with feature{
            var feature : Feature = this.level.current;
            if( this.selectedRow <= feature.row + feature.rows ){
                for(c in 0...row.length){
                    //if collision is dectected, don't move blocks
                    if(
                        row[c] != null
                        && feature.getBlock(c + by - feature.col, this.selectedRow - feature.row) != null
                    ){
                        return;
                    }
                }//for(cols)
                if(
                    by > 0 && row[row.length - 1] != null && feature.col == 0
                    && feature.getBlock(0, this.selectedRow - feature.row) != null
                ) return;
                if(
                    by < 0 && row[0] != null && feature.col + feature.cols >= row.length
                    && feature.getBlock(feature.cols - 1, this.selectedRow - feature.row) != null
                ) return;
            }//if()
        //}

        //move blocks
        for(c in 0...row.length){
            if( row[c] == null ){
                if( c + by >= 0 && c + by < Main.cfg.cols ){
                    this.blocks[ c + by ][ this.selectedRow ] = null;
                }
            }else{
                row[c].col += by;
                row[c].tween(0.1,{
                    left : row[c].col * Main.cfg.block.size
                }).onComplete(this._checkBlock, [row[c]]);
                if( row[c].col >= 0 && row[c].col < Main.cfg.cols ){
                    this.blocks[ row[c].col ][ this.selectedRow ] = row[c];
                }
            }
        }

        //if moving right, check rightmost block
        if( by > 0 ){
            if( row[ row.length - 1 ] == null ){
                this.blocks[0][ this.selectedRow ] = null;
            }else{
                var b  = row[ row.length - 1 ].clone();
                b.col  = 0;
                b.left = - b.w;
                b.tween(0.1, {left:0}).onComplete(this._checkBlock, [b]);
                this.addChild(b);
                this.blocks[0][ this.selectedRow ] = b;
            }

        //if moving left, check leftmost block
        }else{
            if( row[0] == null ){
                this.blocks[ row.length - 1 ][ this.selectedRow ] = null;
            }else{
                var b   = row[0].clone();
                b.col   = Main.cfg.cols - 1;
                b.right = -b.w;
                b.tween(0.1, {left:b.col * Main.cfg.block.size}).onComplete(this._checkBlock, [b]);
                this.addChild(b);
                this.blocks[ row.length - 1 ][ this.selectedRow ] = b;
            }
        }
    }//function _moveBlocks()


    /**
    * This method is called for each block user moved that block
    *
    */
    private function _checkBlock (b:Block) : Void {
        if( b == null ) return;
        if( b.col < 0 || b.col >= Main.cfg.cols ) b.free();
    }//function _checkBlock()


    /**
    * Check if any row can be refactored
    *
    */
    public function checkRefactoring () : Void {
        //move higher blocks by this amount of rows
        var moveBy : Int = 0;

        //check from bottom to top
        var r        : Int;
        var refactor : Bool;
        for(row in 0...Main.cfg.rows){
            refactor = true;
            r = Main.cfg.rows - 1 - row;

            for(c in 0...Main.cfg.cols){
                if( this.blocks[c][r] == null ){
                    refactor = false;
                    break;
                }
            }

            //refactor this row
            if( refactor ){
                moveBy ++;
                for(c in 0...Main.cfg.cols){
                    if( this.blocks[c][r] != null ){
                        this.blocks[c][r].free();
                    }
                }
            //move this row
            }else if( moveBy > 0 ){
                for(c in 0...Main.cfg.cols){
                    this.blocks[c][r + moveBy] = this.blocks[c][r];
                    if( this.blocks[c][r] != null ){
                        this.blocks[c][r].row += moveBy;
                        this.blocks[c][r].tween(Main.cfg.speed, {
                            top : this.blocks[c][r].row * Main.cfg.block.size
                        }, "Quad.easeOut");
                    }
                }
            }
        }//for(rows)
    }//function checkRefactoring()


    /**
    * On destroy, remove listeners from stage
    *
    */
    override public function free (r:Bool = true) : Void {
        Lib.current.stage.removeEventListener(KeyboardEvent.KEY_DOWN, this._onKeyDown);
        super.free(r);
    }//function free()



/*******************************************************************************
*       GETTERS / SETTERS
*******************************************************************************/

    /**
    * Getter `level`.
    *
    */
    private inline function get_level () : Level {
        return UIBuilder.getAs("level", Level);
    }//function get_level

}//class Project