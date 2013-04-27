package ld26;

import ru.stablex.ui.widgets.Widget;


/**
* Player's project
*
*/
class Project extends Widget{

    //blocks in project
    public var blocks : Array<Array<Block>>;

/*******************************************************************************
*       STATIC METHODS
*******************************************************************************/



/*******************************************************************************
*       INSTANCE METHODS
*******************************************************************************/

    /**
    * Constructor
    *
    */
    public function new () : Void {
        super();

        //create empty project structure
        this.blocks = [];
        for(c in 0...Main.cfg.cols){
            this.blocks.push([]);
            for(r in 0...Main.cfg.rows){
                this.blocks[c].push(null);
            }
        }
    }//function new()


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

    }//function addFeature()

/*******************************************************************************
*       GETTERS / SETTERS
*******************************************************************************/

}//class Project